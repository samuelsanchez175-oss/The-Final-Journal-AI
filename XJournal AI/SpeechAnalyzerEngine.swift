//
//  SpeechAnalyzerEngine.swift
//  The Final Journal AI
//
//  iOS 26 SpeechAnalyzer integration for on-device, phrase-aware transcription.
//  Uses SpeechTranscriber (and optionally AssetInventory for locale packs).
//  Callers use AudioTranscriptionService.transcribe(audioURL:) which branches here on iOS 26+.
//

import Foundation
import Speech
import AVFoundation
import os

/// On iOS 26+, transcribes an audio file using SpeechAnalyzer and SpeechTranscriber,
/// returning the same TranscriptionResult shape as the legacy SFSpeechRecognizer path.
@available(iOS 26.0, *)
enum SpeechAnalyzerEngine {

    /// Transcribe audio at the given URL. Uses on-device SpeechTranscriber for
    /// punctuation-aware, sentence-structured output. AssetInventory can be used
    /// to preload/reserve locale packs for offline use.
    static func transcribe(audioURL: URL) async throws -> TranscriptionResult {
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw TranscriptionError.audioFileNotFound
        }

        guard SpeechTranscriber.isAvailable else {
            throw TranscriptionError.onDeviceNotAvailable
        }

        // Prefer an installed locale to avoid "Cannot use modules with unallocated locales" warning.
        let installed = await SpeechTranscriber.installedLocales
        let current = Locale.current
        let supportedEnUS = await SpeechTranscriber.supportedLocale(equivalentTo: Locale(identifier: "en-US"))
        let locale: Locale = installed.first { loc in
            current.language.languageCode?.identifier == loc.language.languageCode?.identifier
        }
        ?? installed.first { $0.identifier.lowercased().hasPrefix("en") }
        ?? installed.first
        ?? supportedEnUS
        ?? Locale(identifier: "en-US")
        let transcriber = SpeechTranscriber(
            locale: locale,
            preset: .timeIndexedProgressiveTranscription
        )
        if !installed.contains(locale) {
            if let request = try? await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                try? await request.downloadAndInstall()
            }
        }
        let analyzer = SpeechAnalyzer(
            modules: [transcriber],
            options: .init(priority: .userInitiated, modelRetention: .processLifetime)
        )

        struct TranscriptionState {
            var fullText = ""
            var pendingText = ""
            var segments: [TranscriptionSegment] = []
            var runningTime: TimeInterval = 0
        }
        let lock = OSAllocatedUnfairLock(initialState: TranscriptionState())

        let resultsTask = Task {
            do {
                for try await result in transcriber.results {
                    let rawText: String = result.text.description
                    let whitespace = CharacterSet.whitespacesAndNewlines
                    let trimmedText = rawText.trimmingCharacters(in: whitespace)
                    guard !trimmedText.isEmpty else { continue }
                    let resultText = rawText

                    if result.isFinal {
                        lock.withLock { state in
                            let duration: TimeInterval = 1.0
                            let segment = TranscriptionSegment(
                                text: resultText,
                                timestamp: state.runningTime,
                                duration: duration,
                                startIndex: nil,
                                length: nil
                            )
                            state.segments.append(segment)
                            state.runningTime += duration
                            state.fullText = (state.fullText + (state.fullText.isEmpty ? "" : " ") + resultText).trimmingCharacters(in: whitespace)
                            state.pendingText = ""
                        }
                    } else {
                        lock.withLock { state in
                            state.pendingText = resultText.trimmingCharacters(in: whitespace)
                        }
                    }
                }
            } catch is CancellationError {
                return
            } catch let err {
                throw err
            }
        }

        let audioFile: AVAudioFile
        if audioURL.startAccessingSecurityScopedResource() == false {}
        defer { audioURL.stopAccessingSecurityScopedResource() }
        audioFile = try AVAudioFile(forReading: audioURL)

        let endTime = try await analyzer.analyzeSequence(from: audioFile)
        try await analyzer.finalize(through: endTime)

        do {
            try await resultsTask.value
        } catch is CancellationError {
            // Stream ended normally when session finished
        } catch {
            // Still use whatever we captured
        }

        let (finalSegments, finalFullText) = lock.withLock { state in
            if !state.pendingText.isEmpty {
                state.fullText = (state.fullText + (state.fullText.isEmpty ? "" : " ") + state.pendingText).trimmingCharacters(in: .whitespacesAndNewlines)
                let duration: TimeInterval = 1.0
                state.segments.append(TranscriptionSegment(
                    text: state.pendingText,
                    timestamp: state.runningTime,
                    duration: duration,
                    startIndex: nil,
                    length: nil
                ))
            }
            let segs = state.segments
            let full = state.fullText.isEmpty ? segs.map(\.text).joined(separator: " ") : state.fullText
            return (segs, full)
        }

        if finalFullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            finalSegments.isEmpty {
            throw TranscriptionError.transcriptionFailed("No speech recognized. Check audio quality, language, and that the recording contains clear speech.")
        }

        return TranscriptionResult(
            fullText: finalFullText,
            segments: finalSegments.isEmpty ? [TranscriptionSegment(text: finalFullText, timestamp: 0, duration: 1)] : finalSegments
        )
    }
}
