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
        // Initialize recognizer with current locale
        self.recognizer = SFSpeechRecognizer(locale: Locale.current)
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
    
    /// Transcribe audio file with word-level timestamps
    func transcribe(audioURL: URL) async throws -> TranscriptionResult {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw TranscriptionError.audioFileNotFound
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
            request.requiresOnDeviceRecognition = true // Additional safety check
            
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
                
                // Extract word-level timestamps from segments
                var segments: [TranscriptionSegment] = []
                for segment in result.bestTranscription.segments {
                    let transcriptionSegment = TranscriptionSegment(
                        text: segment.substring,
                        timestamp: segment.timestamp,
                        duration: segment.duration
                    )
                    segments.append(transcriptionSegment)
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
