//
//  UberduckService.swift
//  XJournal AI
//
//  Sends generated rap bars to the Uberduck API to produce a synthesized rap vocal track.
//  Returns a URL to an audio file which is then handed to RapTrackPlaybackView.
//
//  SETUP:
//  1. Get API credentials from https://uberduck.ai (Creator plan includes API access)
//  2. Store key + secret in Keychain via KeychainHelper:
//       KeychainHelper.shared.saveUberduckAPIKey("your-key")
//       KeychainHelper.shared.saveUberduckAPISecret("your-secret")
//  3. Surface both fields in Profile → API Settings (same pattern as Genius/Suno keys)
//
//  VOICE SELECTION:
//  Use UberduckService.shared.fetchVoices() to get available voices.
//  Rap-specific voices include: "zwf9p4v2" (trap style) and others listed at uberduck.ai/voices
//  Store preferred voice UUID in UserDefaults key "uberduck_preferred_voice"
//
//  INTEGRATION:
//  Call UberduckService.shared.synthesizeRap(lyrics:voiceUUID:) after bars are generated.
//  Pass the returned URL to RapTrackPlaybackView for inline playback.
//

import Foundation
import Combine

// MARK: - Models

struct UberduckSynthesizeRequest: Codable {
    let speech: String          // The rap lyrics to voice
    let voice: String           // Voice UUID from Uberduck's library
    let pace: Double            // 0.75 = slightly slower for clarity; 1.0 = natural pace
    let pitch_shift: Int?       // Optional semitone pitch shift (-12 to +12)
}

struct UberduckSynthesizeResponse: Codable {
    let uuid: String?           // Job UUID — used to poll for completion
    let path: String?           // Direct audio path (if returned immediately)
    let error: String?
}

struct UberduckStatusResponse: Codable {
    let started_at: String?
    let failed_at: String?
    let finished_at: String?
    let path: String?           // Audio URL when complete
    let error: String?
}

struct UberduckVoice: Codable, Identifiable {
    let name: String
    let voicemodel_uuid: String
    let category: String?
    let language: String?

    var id: String { voicemodel_uuid }
}

struct UberduckRapResult {
    let audioURL: URL
    let lyrics: String
    let voiceName: String
}

// MARK: - Errors

enum UberduckError: LocalizedError {
    case missingCredentials
    case requestFailed(String)
    case noAudioPath
    case synthesisTimeout
    case synthesisError(String)

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Uberduck API credentials not set. Add them in Profile → API Settings."
        case .requestFailed(let msg):
            return "Uberduck request failed: \(msg)"
        case .noAudioPath:
            return "Uberduck returned no audio. Try a different voice or shorter lyrics."
        case .synthesisTimeout:
            return "Voice synthesis timed out. Uberduck may be busy — try again."
        case .synthesisError(let msg):
            return "Uberduck synthesis error: \(msg)"
        }
    }
}

// MARK: - Service

@MainActor
final class UberduckService: ObservableObject {

    static let shared = UberduckService()
    private init() {}

    private let baseURL = "https://api.uberduck.ai"
    private let timeoutSeconds: Double = 90
    private let pollInterval: UInt64 = 4_000_000_000  // 4 seconds

    // Default voice UUID — a trap/rap adjacent voice from Uberduck's library
    // Update this after calling fetchVoices() to find the best match
    static let defaultRapVoiceUUID = "zwf9p4v2"

    // ── Credentials ──────────────────────────────────────────────

    private var apiKey: String? { KeychainHelper.shared.getUberduckAPIKey() }
    private var apiSecret: String? { KeychainHelper.shared.getUberduckAPISecret() }

    private var authHeader: String? {
        guard let key = apiKey, let secret = apiSecret,
              !key.isEmpty, !secret.isEmpty else { return nil }
        let creds = "\(key):\(secret)"
        guard let data = creds.data(using: .utf8) else { return nil }
        return "Basic \(data.base64EncodedString())"
    }

    // ── Preferred Voice ──────────────────────────────────────────

    var preferredVoiceUUID: String {
        get { UserDefaults.standard.string(forKey: "uberduck_preferred_voice") ?? Self.defaultRapVoiceUUID }
        set { UserDefaults.standard.set(newValue, forKey: "uberduck_preferred_voice") }
    }

    // ── Main Entry Point ─────────────────────────────────────────

    /// Synthesize rap lyrics into a vocal audio file.
    /// - Parameters:
    ///   - lyrics: The rap bars to voice (plain text, line breaks okay)
    ///   - voiceUUID: Uberduck voice UUID; defaults to preferredVoiceUUID
    ///   - pace: Playback speed (0.75–1.0 recommended for rap)
    ///   - voiceName: Display name for the result
    func synthesizeRap(
        lyrics: String,
        voiceUUID: String? = nil,
        pace: Double = 0.85,
        voiceName: String = "Rap Voice"
    ) async throws -> UberduckRapResult {

        guard let auth = authHeader else {
            throw UberduckError.missingCredentials
        }

        let voice = voiceUUID ?? preferredVoiceUUID

        // Step 1: Submit synthesis job
        let jobUUID = try await submitSynthesis(
            lyrics: lyrics,
            voiceUUID: voice,
            pace: pace,
            auth: auth
        )

        // Step 2: Poll for audio URL
        let audioURL = try await pollForAudio(jobUUID: jobUUID, auth: auth)

        return UberduckRapResult(
            audioURL: audioURL,
            lyrics: lyrics,
            voiceName: voiceName
        )
    }

    // ── Submit Synthesis Job ─────────────────────────────────────

    private func submitSynthesis(
        lyrics: String,
        voiceUUID: String,
        pace: Double,
        auth: String
    ) async throws -> String {

        let url = URL(string: "\(baseURL)/speak")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "speech": lyrics,
            "voice": voiceUUID,
            "pace": pace
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw UberduckError.requestFailed("No HTTP response")
        }
        guard http.statusCode == 200 else {
            let raw = String(data: data, encoding: .utf8) ?? "unknown"
            throw UberduckError.requestFailed("HTTP \(http.statusCode): \(raw)")
        }

        let decoded = try JSONDecoder().decode(UberduckSynthesizeResponse.self, from: data)

        if let err = decoded.error, !err.isEmpty {
            throw UberduckError.synthesisError(err)
        }

        // If audio path came back immediately (some voices), use it directly
        if let directPath = decoded.path,
           !directPath.isEmpty,
           let directURL = URL(string: directPath) {
            return directURL.absoluteString  // store as "uuid" for poll to short-circuit
        }

        guard let uuid = decoded.uuid, !uuid.isEmpty else {
            throw UberduckError.requestFailed("No job UUID returned by Uberduck")
        }

        return uuid
    }

    // ── Poll for Audio ───────────────────────────────────────────

    private func pollForAudio(jobUUID: String, auth: String) async throws -> URL {

        // Short-circuit: if jobUUID is already a URL (immediate response above)
        if jobUUID.hasPrefix("http"), let immediateURL = URL(string: jobUUID) {
            return immediateURL
        }

        let deadline = Date().addingTimeInterval(timeoutSeconds)

        while Date() < deadline {
            try await Task.sleep(nanoseconds: pollInterval)

            let url = URL(string: "\(baseURL)/speak-status?uuid=\(jobUUID)")!
            var request = URLRequest(url: url)
            request.setValue(auth, forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)
            let status = try JSONDecoder().decode(UberduckStatusResponse.self, from: data)

            if let err = status.error, !err.isEmpty {
                throw UberduckError.synthesisError(err)
            }

            if status.failed_at != nil {
                throw UberduckError.synthesisError("Synthesis failed on Uberduck's end.")
            }

            if let path = status.path, !path.isEmpty, let audioURL = URL(string: path) {
                return audioURL
            }

            // finished_at set but no path yet — keep polling one more cycle
        }

        throw UberduckError.synthesisTimeout
    }

    // ── Fetch Available Voices ───────────────────────────────────

    /// Fetch Uberduck's voice list so the user can pick a rap voice.
    /// Filter results by category == "rap" or "trap" for relevant options.
    func fetchVoices() async throws -> [UberduckVoice] {
        guard let auth = authHeader else {
            throw UberduckError.missingCredentials
        }

        let url = URL(string: "\(baseURL)/voices")!
        var request = URLRequest(url: url)
        request.setValue(auth, forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let voices = try JSONDecoder().decode([UberduckVoice].self, from: data)

        // Return rap/trap voices first
        return voices.sorted {
            let aIsRap = ($0.category?.lowercased().contains("rap") ?? false) ||
                         ($0.category?.lowercased().contains("trap") ?? false)
            let bIsRap = ($1.category?.lowercased().contains("rap") ?? false) ||
                         ($1.category?.lowercased().contains("trap") ?? false)
            if aIsRap != bIsRap { return aIsRap }
            return $0.name < $1.name
        }
    }
}
