import Foundation
import Speech
import Combine
import AVFoundation
import os

enum TranscriptionError: LocalizedError {
    case recognizerUnavailable
    case onDeviceNotAvailable
    case authorizationDenied
    case transcriptionFailed(String)
    case audioFileNotFound
    
    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            return "Speech recognizer is not available for this locale."
        case .onDeviceNotAvailable:
            return "On-device recognition is not available. Please check your device settings."
        case .authorizationDenied:
            return "Speech recognition permission was denied. Please enable it in Settings."
        case .transcriptionFailed(let message):
            return "Transcription failed: \(message)"
        case .audioFileNotFound:
            return "Audio file not found."
        }
    }
}

struct TranscriptionResult {
    let fullText: String
    let segments: [TranscriptionSegment]
}

@MainActor
class AudioTranscriptionService: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @Published var isTranscribing = false
    @Published var progress: Double = 0.0
    
    private let recognizer: SFSpeechRecognizer?
    
    init() {
        // Use a locale that Speech has allocated to avoid "unallocated locales" warning.
        // Prefer current, then en-US, then first supported so we never rely on an unallocated locale.
        let current = Locale.current
        if let r = SFSpeechRecognizer(locale: current) {
            self.recognizer = r
            return
        }
        let enUS = Locale(identifier: "en-US")
        if let r = SFSpeechRecognizer(locale: enUS) {
            self.recognizer = r
            return
        }
        let supported = SFSpeechRecognizer.supportedLocales()
        if let en = supported.first(where: { $0.identifier.lowercased().hasPrefix("en") }),
           let r = SFSpeechRecognizer(locale: en) {
            self.recognizer = r
            return
        }
        if let any = supported.first, let r = SFSpeechRecognizer(locale: any) {
            self.recognizer = r
            return
        }
        self.recognizer = nil
    }
    
    /// Request speech recognition authorization
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    /// Check if on-device recognition is available
    func supportsOnDeviceRecognition() async -> Bool {
        guard let recognizer = recognizer else { return false }
        if #available(iOS 16.0, *) {
            return recognizer.supportsOnDeviceRecognition
        } else {
            // On-device availability can't be queried directly before iOS 16.
            // We'll assume not available to be safe and rely on request.requiresOnDeviceRecognition at runtime.
            return false
        }
    }
    
    /// Transcribe audio file with word-level timestamps.
    /// Backend is chosen by the `transcription_backend` setting:
    ///  - `"whisper"` + a valid OpenAI (`sk-…`) key → OpenAI Whisper API.
    ///  - otherwise → on-device Apple Speech (SpeechAnalyzer on iOS 26+, else SFSpeechRecognizer).
    /// Whisper requires an OpenAI key specifically; Gemini (`AIza…`) keys are not supported and
    /// transparently fall back to Apple so transcription never silently breaks.
    func transcribe(
        audioURL: URL,
        onUpdate: (@Sendable ([TranscriptionSegment], String) -> Void)? = nil
    ) async throws -> TranscriptionResult {
        let backend = UserDefaults.standard.string(forKey: "transcription_backend") ?? "apple"
        if backend == "whisper",
           let apiKey = KeychainHelper.shared.getAPIKey(),
           apiKey.hasPrefix("sk-") {
            return try await transcribeWithWhisper(audioURL: audioURL, apiKey: apiKey)
        }

        guard await requestAuthorization() else {
            throw TranscriptionError.authorizationDenied
        }

        let limit = listenLimit(for: audioURL)
        let delivered = OSAllocatedUnfairLock(initialState: false)
        let forward: @Sendable ([TranscriptionSegment], String) -> Void = { segments, text in
            if !text.isEmpty || !segments.isEmpty {
                delivered.withLock { $0 = true }
            }
            onUpdate?(segments, text)
        }

        if #available(iOS 26.0, *) {
            do {
                return try await withTimeout(seconds: limit) {
                    try await SpeechAnalyzerEngine.transcribe(audioURL: audioURL, onUpdate: forward)
                }
            } catch let error as TranscriptionError {
                if case .authorizationDenied = error { throw error }
                if case .audioFileNotFound = error { throw error }
                if delivered.withLock({ $0 }) { throw error }
                print("📝 SpeechAnalyzer failed (\(error.localizedDescription)) — falling back to SFSpeechRecognizer")
            } catch {
                if delivered.withLock({ $0 }) { throw error }
                print("📝 SpeechAnalyzer failed (\(error.localizedDescription)) — falling back to SFSpeechRecognizer")
            }
        }
        // Legacy path: SFSpeechRecognizer
        // Check if file exists (same URL we use for playback)
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw TranscriptionError.audioFileNotFound
        }
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: audioURL.path)[.size] as? Int64) ?? 0
        if #available(iOS 16.0, *), let rec = recognizer {
            print("📝 AudioTranscriptionService: File exists, passing to Speech. size: \(fileSize) bytes, locale: \(rec.locale.identifier), onDeviceAvailable: \(rec.supportsOnDeviceRecognition). Request allows server (like Notes).")
        } else {
            print("📝 AudioTranscriptionService: File exists, passing to Speech. size: \(fileSize) bytes. Request allows server (like Notes).")
        }
        
        // Check authorization
        guard await requestAuthorization() else {
            throw TranscriptionError.authorizationDenied
        }
        
        // Verify recognizer is available
        guard let recognizer = recognizer else {
            throw TranscriptionError.recognizerUnavailable
        }
        
        isTranscribing = true
        progress = 0.0
        defer {
            isTranscribing = false
            progress = 0.0
        }
        
        return try await withTimeout(seconds: limit) {
            try await self.transcribeWithSFSpeech(audioURL: audioURL, recognizer: recognizer, onUpdate: forward)
        }
    }

    /// File length plus a short buffer. A 3:35 recording is not cut off at 90 seconds.
    private func listenLimit(for audioURL: URL) -> TimeInterval {
        let buffer: TimeInterval = 30
        guard let file = try? AVAudioFile(forReading: audioURL) else { return 120 }
        let rate = file.fileFormat.sampleRate
        guard rate > 0 else { return 120 }
        let seconds = Double(file.length) / rate
        guard seconds.isFinite, seconds > 0 else { return 120 }
        return seconds + buffer
    }

    private func transcribeWithSFSpeech(
        audioURL: URL,
        recognizer: SFSpeechRecognizer,
        onUpdate: (@Sendable ([TranscriptionSegment], String) -> Void)?
    ) async throws -> TranscriptionResult {
        try await withCheckedThrowingContinuation { continuation in
            let request = SFSpeechURLRecognitionRequest(url: audioURL)
            request.shouldReportPartialResults = true
            request.requiresOnDeviceRecognition = false
            var finished = false

            let task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }
                if finished { return }

                if let error {
                    finished = true
                    continuation.resume(throwing: TranscriptionError.transcriptionFailed(error.localizedDescription))
                    return
                }

                guard let result else { return }
                let segments = self.segments(from: result)
                let fullText = result.bestTranscription.formattedString
                if !result.isFinal {
                    self.progress = 0.5
                    if let onUpdate, !fullText.isEmpty {
                        onUpdate(segments, fullText)
                    }
                    return
                }

                let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty || segments.isEmpty {
                    finished = true
                    continuation.resume(throwing: TranscriptionError.transcriptionFailed("No speech recognized. Check audio quality, language, and that the recording contains clear speech."))
                    return
                }

                finished = true
                self.progress = 1.0
                continuation.resume(returning: TranscriptionResult(fullText: fullText, segments: segments))
            }

            if task.isCancelled, !finished {
                finished = true
                continuation.resume(throwing: TranscriptionError.transcriptionFailed("Recognition task was cancelled"))
            }
        }
    }

    private func segments(from result: SFSpeechRecognitionResult) -> [TranscriptionSegment] {
        let fullText = result.bestTranscription.formattedString
        var segments: [TranscriptionSegment] = []
        for segment in result.bestTranscription.segments {
            let text = segment.substring.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { continue }
            var startIndex: Int?
            var length: Int?
            let nsRange = segment.substringRange
            if nsRange.length > 0, let range = Range(nsRange, in: fullText) {
                startIndex = fullText.distance(from: fullText.startIndex, to: range.lowerBound)
                length = fullText.distance(from: range.lowerBound, to: range.upperBound)
            }
            segments.append(
                TranscriptionSegment(
                    text: segment.substring,
                    timestamp: segment.timestamp,
                    duration: segment.duration,
                    startIndex: startIndex,
                    length: length
                )
            )
        }
        return segments
    }

    private func withTimeout<T: Sendable>(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TranscriptionError.transcriptionFailed("Transcription took too long. Tap Restart to try again.")
            }
            guard let value = try await group.next() else {
                throw TranscriptionError.transcriptionFailed("Transcription took too long. Tap Restart to try again.")
            }
            group.cancelAll()
            return value
        }
    }

    // MARK: - OpenAI Whisper

    /// Transcribe via the OpenAI Whisper API (`whisper-1`, verbose_json for segment timings).
    /// Uses the same OpenAI key as Model G (Keychain `openai_api_key`).
    private func transcribeWithWhisper(audioURL: URL, apiKey: String) async throws -> TranscriptionResult {
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw TranscriptionError.audioFileNotFound
        }

        isTranscribing = true
        progress = 0.1
        defer {
            isTranscribing = false
            progress = 0.0
        }

        let fileData = try Data(contentsOf: audioURL)
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func appendField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        appendField("model", "whisper-1")
        appendField("response_format", "verbose_json")
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(audioURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        progress = 0.4
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        guard let http = response as? HTTPURLResponse else {
            throw TranscriptionError.transcriptionFailed("No response from the Whisper API.")
        }
        guard http.statusCode == 200 else {
            switch http.statusCode {
            case 401:
                throw TranscriptionError.transcriptionFailed("OpenAI rejected the API key (401). Re-check your key in Profile → AI.")
            case 429:
                throw TranscriptionError.transcriptionFailed("OpenAI rate limit reached (429). Try again shortly, or switch to on-device transcription.")
            default:
                let detail = String(data: data, encoding: .utf8) ?? "status \(http.statusCode)"
                throw TranscriptionError.transcriptionFailed("Whisper API error \(http.statusCode): \(detail.prefix(200))")
            }
        }

        progress = 0.8
        let parsed = try JSONDecoder().decode(WhisperVerboseResponse.self, from: data)

        var fullText = ""
        var segments: [TranscriptionSegment] = []
        let whisperSegments = parsed.segments ?? []
        if whisperSegments.isEmpty {
            fullText = parsed.text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            for seg in whisperSegments {
                let text = seg.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { continue }
                if !fullText.isEmpty { fullText += " " }
                let startIndex = fullText.count
                fullText += text
                segments.append(TranscriptionSegment(
                    text: text,
                    timestamp: seg.start,
                    duration: max(0, seg.end - seg.start),
                    startIndex: startIndex,
                    length: text.count
                ))
            }
        }

        let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TranscriptionError.transcriptionFailed("Whisper returned no speech. Check the recording contains clear audio.")
        }

        progress = 1.0
        return TranscriptionResult(fullText: fullText, segments: segments)
    }
}

// MARK: - Whisper verbose_json response

private struct WhisperVerboseResponse: Decodable {
    let text: String
    let segments: [WhisperSegment]?

    struct WhisperSegment: Decodable {
        let start: Double
        let end: Double
        let text: String
    }
}
