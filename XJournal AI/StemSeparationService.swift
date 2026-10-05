//
//  StemSeparationService.swift
//  The Final Journal AI
//
//  #4 — Separate a mixed recording (e.g. a freestyle over a beat) into stems
//  (vocals / drums / bass / other) via fal.ai hosted Demucs (`fal-ai/demucs`).
//
//  SETUP STATUS: the architecture + UI are wired. To make it actually run you must:
//    1. Set a fal.ai key in UserDefaults under `fal_api_key` (move to Keychain before shipping).
//    2. Verify the request/response shapes below against fal.ai's live API (storage upload
//       fields, queue status keys, and the demucs result stem keys) — they follow fal's docs
//       but have NOT been confirmed against a real response yet.
//

import Foundation

/// One separated stem saved to a local file.
struct StemResult: Identifiable, Hashable {
    var id: String { name }
    let name: String        // "vocals", "drums", "bass", "other"
    let localPath: String   // absolute path in the app container
}

enum StemSeparationError: LocalizedError {
    case missingKey
    case fileNotFound
    case uploadFailed
    case requestFailed(String)
    case timedOut
    case noStems

    var errorDescription: String? {
        switch self {
        case .missingKey:           return "Add your fal.ai key to separate stems."
        case .fileNotFound:         return "Audio file not found."
        case .uploadFailed:         return "Couldn't upload the audio for separation."
        case .requestFailed(let m): return "Stem separation failed: \(m)"
        case .timedOut:             return "Stem separation timed out — try again."
        case .noStems:              return "No stems were returned."
        }
    }
}

protocol StemSeparator {
    /// `requestedStems`: 2 (vocals/instrumental) or 4 (vocals/drums/bass/other).
    func separate(audioURL: URL, requestedStems: Int, progress: @escaping @Sendable (Double) -> Void) async throws -> [StemResult]
}

/// Cloud stem separation via fal.ai hosted Demucs.
final class FalStemSeparator: StemSeparator {
    static let shared = FalStemSeparator()
    private init() {}

    static let apiKeyDefaultsKey = "fal_api_key"
    private var apiKey: String? {
        let k = UserDefaults.standard.string(forKey: Self.apiKeyDefaultsKey)
        return (k?.isEmpty == false) ? k : nil
    }

    func separate(audioURL: URL, requestedStems: Int, progress: @escaping @Sendable (Double) -> Void) async throws -> [StemResult] {
        guard let key = apiKey else { throw StemSeparationError.missingKey }
        guard FileManager.default.fileExists(atPath: audioURL.path) else { throw StemSeparationError.fileNotFound }
        progress(0.05)

        // 1) Upload the local recording so Demucs can read it by URL.
        let hostedURL = try await uploadToFalStorage(fileURL: audioURL, key: key)
        progress(0.25)

        // 2) Submit the job (queue API).
        let job = try await submitJob(audioURL: hostedURL, key: key)
        progress(0.35)

        // 3) Poll until the job completes, then fetch the result payload.
        let resultObj = try await pollUntilDone(status: job.statusURL, result: job.resultURL, key: key) { p in
            progress(0.35 + 0.45 * p)
        }
        progress(0.85)

        // 4) Download each stem to the app container.
        let names = requestedStems <= 2 ? ["vocals", "other"] : ["vocals", "drums", "bass", "other"]
        let base = audioURL.deletingPathExtension().lastPathComponent
        var out: [StemResult] = []
        for (i, name) in names.enumerated() {
            if let s = extractStemURL(from: resultObj, name: name), let u = URL(string: s) {
                let path = try await download(url: u, stem: name, base: base)
                out.append(StemResult(name: name, localPath: path))
            }
            progress(0.85 + 0.15 * Double(i + 1) / Double(names.count))
        }
        guard !out.isEmpty else { throw StemSeparationError.noStems }
        return out
    }

    // MARK: - fal.ai REST (verify shapes against fal.ai docs once a key is available)

    private func uploadToFalStorage(fileURL: URL, key: String) async throws -> URL {
        let initiate = URL(string: "https://rest.alpha.fal.ai/storage/upload/initiate")!
        var req = URLRequest(url: initiate)
        req.httpMethod = "POST"
        req.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let ct = contentType(for: fileURL)
        req.httpBody = try JSONSerialization.data(withJSONObject: ["content_type": ct, "file_name": fileURL.lastPathComponent])
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let uploadURLStr = obj["upload_url"] as? String, let uploadURL = URL(string: uploadURLStr),
              let fileURLStr = obj["file_url"] as? String, let publicURL = URL(string: fileURLStr) else {
            throw StemSeparationError.uploadFailed
        }
        var put = URLRequest(url: uploadURL)
        put.httpMethod = "PUT"
        put.setValue(ct, forHTTPHeaderField: "Content-Type")
        let fileData = try Data(contentsOf: fileURL)
        let (_, putResp) = try await URLSession.shared.upload(for: put, from: fileData)
        guard let ph = putResp as? HTTPURLResponse, (200..<300).contains(ph.statusCode) else {
            throw StemSeparationError.uploadFailed
        }
        return publicURL
    }

    private struct Job { let statusURL: URL; let resultURL: URL }

    private func submitJob(audioURL: URL, key: String) async throws -> Job {
        let queue = URL(string: "https://queue.fal.run/fal-ai/demucs")!
        var req = URLRequest(url: queue)
        req.httpMethod = "POST"
        req.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["audio_url": audioURL.absoluteString])
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw StemSeparationError.requestFailed("submit \((resp as? HTTPURLResponse)?.statusCode ?? -1)")
        }
        let rid = obj["request_id"] as? String ?? ""
        let statusURL = URL(string: obj["status_url"] as? String ?? "https://queue.fal.run/fal-ai/demucs/requests/\(rid)/status")!
        let resultURL = URL(string: obj["response_url"] as? String ?? "https://queue.fal.run/fal-ai/demucs/requests/\(rid)")!
        return Job(statusURL: statusURL, resultURL: resultURL)
    }

    private func pollUntilDone(status: URL, result: URL, key: String, progress: @escaping @Sendable (Double) -> Void) async throws -> [String: Any] {
        for attempt in 0..<150 { // up to ~2.5 min
            try await Task.sleep(nanoseconds: 1_000_000_000)
            var req = URLRequest(url: status)
            req.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: req)
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let s = obj["status"] as? String {
                if s == "COMPLETED" {
                    var rReq = URLRequest(url: result)
                    rReq.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
                    let (rData, _) = try await URLSession.shared.data(for: rReq)
                    return ((try? JSONSerialization.jsonObject(with: rData)) as? [String: Any]) ?? [:]
                }
                if s == "FAILED" { throw StemSeparationError.requestFailed("job failed") }
            }
            progress(min(1.0, Double(attempt) / 60.0))
        }
        throw StemSeparationError.timedOut
    }

    private func extractStemURL(from obj: [String: Any], name: String) -> String? {
        if let d = obj[name] as? [String: Any], let u = d["url"] as? String { return u }
        if let s = obj[name] as? String { return s }
        if let stems = obj["stems"] as? [String: Any] {
            if let d = stems[name] as? [String: Any], let u = d["url"] as? String { return u }
            if let s = stems[name] as? String { return s }
        }
        return nil
    }

    private func download(url: URL, stem: String, base: String) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let ext = url.pathExtension.isEmpty ? "wav" : url.pathExtension
        let dest = docs.appendingPathComponent("\(base)_\(stem).\(ext)")
        try? FileManager.default.removeItem(at: dest)
        try data.write(to: dest)
        return dest.path
    }

    private func contentType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "mp3":          return "audio/mpeg"
        case "wav":          return "audio/wav"
        case "m4a", "aac":   return "audio/mp4"
        case "caf":          return "audio/x-caf"
        default:             return "application/octet-stream"
        }
    }
}
