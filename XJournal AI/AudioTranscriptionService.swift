import Foundation
import Speech
import Combine

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
    /// On iOS 26+, uses SpeechAnalyzer + SpeechTranscriber for on-device, phrase-aware transcription.
    /// Otherwise uses SFSpeechRecognizer.
    func transcribe(audioURL: URL) async throws -> TranscriptionResult {
        if #available(iOS 26.0, *) {
            return try await SpeechAnalyzerEngine.transcribe(audioURL: audioURL)
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
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = SFSpeechURLRecognitionRequest(url: audioURL)
            request.shouldReportPartialResults = false // Get final results only
            // Do not require on-device: Notes uses server when needed. On-device requires
            // Settings > Keyboard > Enable Dictation + dictation language downloaded for the locale,
            // otherwise recognition can return empty even when the same file works in Notes.
            request.requiresOnDeviceRecognition = false
            
            let task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isTranscribing = false
                    continuation.resume(throwing: TranscriptionError.transcriptionFailed(error.localizedDescription))
                    return
                }
                
                guard let result = result, result.isFinal else {
                    // Update progress for partial results
                    if result != nil {
                        // Estimate progress based on result
                        self.progress = 0.5 // Partial results indicate ~50% progress
                    }
                    return
                }
                
                // Extract full transcription text
                let fullText = result.bestTranscription.formattedString
                
                // Extract word-level timestamps from segments (filter out empty segments)
                // Persist substringRange so we can map phrases to timestamps in the UI.
                var segments: [TranscriptionSegment] = []
                for segment in result.bestTranscription.segments {
                    let text = segment.substring.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { continue }
                    var startIndex: Int? = nil
                    var length: Int? = nil
                    let nsRange = segment.substringRange
                    if nsRange.length > 0, let range = Range(nsRange, in: fullText), range.lowerBound >= fullText.startIndex, range.upperBound <= fullText.endIndex {
                        startIndex = fullText.distance(from: fullText.startIndex, to: range.lowerBound)
                        length = fullText.distance(from: range.lowerBound, to: range.upperBound)
                    }
                    let transcriptionSegment = TranscriptionSegment(
                        text: segment.substring,
                        timestamp: segment.timestamp,
                        duration: segment.duration,
                        startIndex: startIndex,
                        length: length
                    )
                    segments.append(transcriptionSegment)
                }
                
                // Reject empty final result so user sees an error instead of "success with nothing"
                let trimmedFullText = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
                let allSegmentsEmpty = segments.isEmpty || segments.allSatisfy { $0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                if trimmedFullText.isEmpty || allSegmentsEmpty {
                    self.isTranscribing = false
                    print("📝 AudioTranscriptionService: Rejecting empty final result (fullText.isEmpty: \(trimmedFullText.isEmpty), segmentsAfterFilter: \(segments.count), rawSegmentCount: \(result.bestTranscription.segments.count))")
                    print("📝 AudioTranscriptionService: Speech framework did not detect any speech in this file. Common causes: file is mostly music, language does not match device, or no clear speech. The same file is used for playback — loading is not the issue.")
                    continuation.resume(throwing: TranscriptionError.transcriptionFailed("No speech recognized. Check audio quality, language, and that the recording contains clear speech."))
                    return
                }
                
                self.progress = 1.0
                self.isTranscribing = false
                
                let transcriptionResult = TranscriptionResult(
                    fullText: fullText,
                    segments: segments
                )
                
                continuation.resume(returning: transcriptionResult)
            }
            
            // Handle task cancellation if needed
            if task.isCancelled {
                continuation.resume(throwing: TranscriptionError.transcriptionFailed("Recognition task was cancelled"))
            }
        }
    }
}
