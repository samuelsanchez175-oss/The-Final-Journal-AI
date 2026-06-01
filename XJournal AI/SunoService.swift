//
//  SunoService.swift
//  XJournal AI
//
//  Sends generated rap lyrics to the Suno API to produce a backing beat/track.
//  Returns a URL to the generated audio file, which is then handed to RapTrackPlaybackView.
//
//  SETUP:
//  1. Get a Suno API key from https://sunoapi.org or https://docs.sunoapi.org
//  2. Store it in Keychain via KeychainHelper: KeychainHelper.shared.saveSunoAPIKey("your-key")
//  3. The Profile settings UI should surface a "Suno API Key" field (same pattern as Genius key)
//
//  INTEGRATION:
//  Call SunoService.shared.generateBeat(lyrics:style:title:) after rap lines are generated.
//  Pass the returned SunoBeatResult to RapTrackPlaybackView.
//

import Foundation
import Combine

// MARK: - Models

struct SunoGenerationRequest: Codable {
    let prompt: String          // The rap lyrics
    let style: String           // e.g. "trap, dark, 140bpm, melodic"
    let title: String
    let make_instrumental: Bool // false = include vocals layer; true = beat only
    let wait_audio: Bool        // true = poll until done (simpler for app use)
}

struct SunoGenerationResponse: Codable {
    let id: String?
    let audio_url: String?
    let status: String?         // "complete", "streaming", "error"
    let error_message: String?

    // Some Suno API wrappers return an array
    struct Item: Codable {
        let id: String?
        let audio_url: String?
        let status: String?
        let error_message: String?
    }
}

struct SunoBeatResult {
    let audioURL: URL
    let title: String
    let style: String
    let lyrics: String
}

// MARK: - Errors

enum SunoError: LocalizedError {
    case missingAPIKey
    case requestFailed(String)
    case noAudioURL
    case generationTimeout
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Suno API key not set. Add it in Profile → API Settings."
        case .requestFailed(let msg):
            return "Suno request failed: \(msg)"
        case .noAudioURL:
            return "Suno returned no audio URL. Try again."
        case .generationTimeout:
            return "Beat generation timed out. The Suno API may be busy."
        case .apiError(let msg):
            return "Suno API error: \(msg)"
        }
    }
}

// MARK: - Service

@MainActor
final class SunoService: ObservableObject {

    static let shared = SunoService()
    private init() {}

    // Suno API base — third-party wrapper used by most iOS integrations
    // Official: https://docs.sunoapi.org
    private let baseURL = "https://api.sunoapi.org"

    // How long to wait for beat generation (Suno usually takes 20–60s)
    private let timeoutSeconds: Double = 120

    // ── API Key ──────────────────────────────────────────────────

    private var apiKey: String? {
        KeychainHelper.shared.getSunoAPIKey()
    }

    // ── Main Entry Point ─────────────────────────────────────────

    /// Generate a beat from rap lyrics.
    /// - Parameters:
    ///   - lyrics: The generated rap bars to set to music
    ///   - style: Musical style tag, e.g. "trap, dark, 140bpm" or "melodic trap, piano"
    ///   - title: Song title for the generation
    ///   - instrumentalOnly: true = beat only, false = Suno also tries to sing the lyrics
    func generateBeat(
        lyrics: String,
        style: String = "melodic trap, dark, 140bpm",
        title: String = "Final Journal Track",
        instrumentalOnly: Bool = true
    ) async throws -> SunoBeatResult {

        guard let key = apiKey, !key.isEmpty else {
            throw SunoError.missingAPIKey
        }

        // Step 1: Submit generation request
        let generationID = try await submitGeneration(
            lyrics: lyrics,
            style: style,
            title: title,
            instrumentalOnly: instrumentalOnly,
            apiKey: key
        )

        // Step 2: Poll for completion
        let audioURL = try await pollForAudio(generationID: generationID, apiKey: key)

        return SunoBeatResult(
            audioURL: audioURL,
            title: title,
            style: style,
            lyrics: lyrics
        )
    }

    // ── Submit ───────────────────────────────────────────────────

    private func submitGeneration(
        lyrics: String,
        style: String,
        title: String,
        instrumentalOnly: Bool,
        apiKey: String
    ) async throws -> String {

        let url = URL(string: "\(baseURL)/api/v1/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "prompt": lyrics,
            "style": style,
            "title": title,
            "make_instrumental": instrumentalOnly,
            "wait_audio": false   // we poll manually for better UX
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw SunoError.requestFailed("No HTTP response")
        }
        guard http.statusCode == 200 else {
            let raw = String(data: data, encoding: .utf8) ?? "unknown"
            throw SunoError.apiError("HTTP \(http.statusCode): \(raw)")
        }

        // Response is either { "id": "..." } or an array [{ "id": "..." }]
        if let single = try? JSONDecoder().decode(SunoGenerationResponse.self, from: data),
           let id = single.id {
            return id
        }
        if let array = try? JSONDecoder().decode([SunoGenerationResponse.Item].self, from: data),
           let id = array.first?.id {
            return id
        }
        // Some wrappers return { "data": [{ "id": "..." }] }
        if let wrapper = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataArr = wrapper["data"] as? [[String: Any]],
           let id = dataArr.first?["id"] as? String {
            return id
        }

        throw SunoError.requestFailed("Could not parse generation ID from response")
    }

    // ── Poll ─────────────────────────────────────────────────────

    private func pollForAudio(generationID: String, apiKey: String) async throws -> URL {
        let deadline = Date().addingTimeInterval(timeoutSeconds)
        let pollInterval: UInt64 = 5_000_000_000  // 5 seconds in nanoseconds

        while Date() < deadline {
            try await Task.sleep(nanoseconds: pollInterval)

            let url = URL(string: "\(baseURL)/api/v1/get?ids=\(generationID)")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)

            // Parse response — try array first, then single
            var audioURLString: String?
            var status: String?

            if let array = try? JSONDecoder().decode([SunoGenerationResponse.Item].self, from: data),
               let item = array.first {
                audioURLString = item.audio_url
                status = item.status
                if let err = item.error_message, !err.isEmpty {
                    throw SunoError.apiError(err)
                }
            } else if let single = try? JSONDecoder().decode(SunoGenerationResponse.self, from: data) {
                audioURLString = single.audio_url
                status = single.status
                if let err = single.error_message, !err.isEmpty {
                    throw SunoError.apiError(err)
                }
            }

            if let urlString = audioURLString,
               !urlString.isEmpty,
               let audioURL = URL(string: urlString) {
                return audioURL
            }

            if status == "error" {
                throw SunoError.apiError("Generation failed on Suno's end. Try again.")
            }
        }

        throw SunoError.generationTimeout
    }
}
