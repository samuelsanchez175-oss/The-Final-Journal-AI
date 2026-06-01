//
//  FlowSkeletonService.swift
//  XJournal AI
//
//  Scenario B: POST audio to onset-detection backend, get syllable-per-bar skeleton.
//

import Foundation

/// Backend response for /skeleton endpoint.
private struct SkeletonResponse: Decodable {
    let perBar: [PerBarCount]
    let bpm: Int?
}

enum FlowSkeletonService {
    /// Base URL for the flow skeleton backend (e.g. https://your-app.railway.app or http://localhost:8000).
    static var baseURL: String {
        UserDefaults.standard.string(forKey: "flow_skeleton_backend_url")
            ?? "http://localhost:8000"
    }

    /// Extract flow skeleton from mumble audio via backend. Returns a rhythm result suitable for generateLyricsFromFlow.
    static func extractSkeleton(audioURL: URL, bpm: Int?) async throws -> RhythmicTranscriptionResult {
        guard let url = URL(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines)),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw GenerateLyricsFromFlowError.backendUnavailable
        }
        if components.path.isEmpty || !components.path.hasSuffix("skeleton") {
            let base = components.path.isEmpty ? "/" : (components.path.hasSuffix("/") ? components.path : components.path + "/")
            components.path = base + "skeleton"
        }
        var queryItems: [URLQueryItem] = []
        if let b = bpm, b > 0 {
            queryItems.append(URLQueryItem(name: "bpm", value: "\(b)"))
        }
        queryItems.append(URLQueryItem(name: "bar_offset_ms", value: "0"))
        if !queryItems.isEmpty { components.queryItems = queryItems }
        guard let requestURL = components.url else {
            throw GenerateLyricsFromFlowError.backendUnavailable
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 30

        let boundary = "FlowSkeletonBoundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let audioData: Data
        do {
            audioData = try Data(contentsOf: audioURL)
        } catch {
            throw GenerateLyricsFromFlowError.generationFailed("Could not read audio file: \(error.localizedDescription)")
        }
        let filename = audioURL.lastPathComponent
        // Use octet-stream so backend accepts any format (m4a, caf, mp3, etc.)
        let mimeType = "application/octet-stream"
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw GenerateLyricsFromFlowError.generationFailed("Network error: \(error.localizedDescription)")
        }

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GenerateLyricsFromFlowError.generationFailed("Backend returned \(code): \(message)")
        }

        let decoded: SkeletonResponse
        do {
            decoded = try JSONDecoder().decode(SkeletonResponse.self, from: data)
        } catch {
            throw GenerateLyricsFromFlowError.generationFailed("Invalid response: \(error.localizedDescription)")
        }

        guard !decoded.perBar.isEmpty else {
            throw GenerateLyricsFromFlowError.generationFailed("Backend returned no bars.")
        }

        let bpmValue = decoded.bpm ?? bpm ?? 90
        let syllables = SyllablesResult(
            method: "onset_backend",
            events: [],
            perBar: decoded.perBar
        )
        let transcript = TranscriptWithWords(
            language: nil,
            segments: []
        )
        return RhythmicTranscriptionResult(
            audioId: audioURL.lastPathComponent,
            bpm: bpmValue,
            timeSignature: .fourFour,
            barOffsetMs: 0,
            transcript: transcript,
            syllables: syllables
        )
    }
}
