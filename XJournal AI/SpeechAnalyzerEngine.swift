//
//  SpeechAnalyzerEngine.swift
//  The Final Journal AI
//
//  iOS 26 SpeechAnalyzer + SpeechTranscriber for file transcription with
//  real audioTimeRange timestamps (Apple Notes-style).
//

import Foundation
import Speech
import AVFoundation
import CoreMedia
import os

@available(iOS 26.0, *)
enum SpeechAnalyzerEngine {

    static func transcribe(
        audioURL: URL,
        onUpdate: (@Sendable ([TranscriptionSegment], String) -> Void)? = nil
    ) async throws -> TranscriptionResult {
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw TranscriptionError.audioFileNotFound
        }

        guard SpeechTranscriber.isAvailable else {
            throw TranscriptionError.onDeviceNotAvailable
        }

        let locale = await preferredLocale()
        let transcriber = SpeechTranscriber(
            locale: locale,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )

        let installed = await SpeechTranscriber.installedLocales
        if !installed.contains(where: { $0.identifier == locale.identifier }) {
            if let request = try? await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                try await withTimeout(seconds: 15) {
                    try await request.downloadAndInstall()
                }
            }
        }

        let analyzer = SpeechAnalyzer(
            modules: [transcriber],
            options: .init(priority: .userInitiated, modelRetention: .processLifetime)
        )

        struct TranscriptionState {
            var segments: [TranscriptionSegment] = []
            var fullText = ""
            var pendingText = ""
            var pendingStart: TimeInterval = 0
        }
        let lock = OSAllocatedUnfairLock(initialState: TranscriptionState())

        let resultsTask = Task {
            for try await result in transcriber.results {
                let pieces = segments(from: result)
                let plain = String(result.text.characters)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard !plain.isEmpty || !pieces.isEmpty else { continue }

                let snapshot: (segments: [TranscriptionSegment], text: String)? = lock.withLock { state in
                    if result.isFinal {
                        if let phrase = phraseSegment(plain: plain, words: pieces, result: result) {
                            state.segments = TranscriptRevision.absorb(state.segments, phrase)
                        }
                        state.fullText = state.segments.map(\.text).joined(separator: " ")
                        state.pendingText = ""
                        return (state.segments, state.fullText)
                    } else {
                        state.pendingText = plain
                        state.pendingStart = timeSeconds(result.range.start)
                        var live = state.segments
                        if let pending = phraseSegment(plain: plain, words: pieces, result: result) {
                            live = TranscriptRevision.absorb(live, pending)
                        }
                        let liveText = live.map(\.text).joined(separator: " ")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        return (live, liveText)
                    }
                }
                if let snapshot, let onUpdate {
                    await MainActor.run {
                        onUpdate(snapshot.segments, snapshot.text)
                    }
                }
            }
        }

        let accessed = audioURL.startAccessingSecurityScopedResource()
        defer {
            if accessed { audioURL.stopAccessingSecurityScopedResource() }
        }

        let audioFile = try AVAudioFile(forReading: audioURL)
        let endTime = try await analyzer.analyzeSequence(from: audioFile)
        try await analyzer.finalize(through: endTime)

        do {
            try await resultsTask.value
        } catch is CancellationError {
        } catch {
            // Keep whatever we already captured.
        }

        let (finalSegments, finalFullText) = lock.withLock { state in
            if !state.pendingText.isEmpty {
                state.segments = TranscriptRevision.absorb(
                    state.segments,
                    TranscriptionSegment(
                        text: state.pendingText,
                        timestamp: state.pendingStart,
                        duration: 0.4,
                        wordTimings: nil
                    )
                )
                state.fullText = state.segments.map(\.text).joined(separator: " ")
            }
            return (state.segments, state.fullText)
        }

        let trimmed = finalFullText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty && finalSegments.isEmpty {
            throw TranscriptionError.transcriptionFailed("No speech recognized. Check audio quality, language, and that the recording contains clear speech.")
        }

        return TranscriptionResult(
            fullText: trimmed.isEmpty ? finalSegments.map(\.text).joined(separator: " ") : trimmed,
            segments: finalSegments
        )
    }

    private static func preferredLocale() async -> Locale {
        let installed = await SpeechTranscriber.installedLocales
        let current = Locale.current
        let supported = await SpeechTranscriber.supportedLocale(equivalentTo: current)
        return installed.first { loc in
            current.language.languageCode?.identifier == loc.language.languageCode?.identifier
        }
        ?? installed.first { $0.identifier.lowercased().hasPrefix("en") }
        ?? installed.first
        ?? supported
        ?? Locale(identifier: "en-US")
    }

    /// Word timings from AttributedString runs. Display grouping happens later.
    private static func segments(from result: SpeechTranscriber.Result) -> [WordTiming] {
        let attributed = result.text
        var out: [WordTiming] = []
        for run in attributed.runs {
            let piece = String(attributed[run.range].characters)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !piece.isEmpty else { continue }
            let start: TimeInterval
            let duration: TimeInterval
            if let timeRange = run.audioTimeRange {
                start = timeSeconds(timeRange.start)
                duration = max(0.05, timeSeconds(timeRange.duration))
            } else {
                start = timeSeconds(result.range.start)
                duration = max(0.05, timeSeconds(result.range.duration))
            }
            out.append(WordTiming(text: piece, timestamp: start, duration: duration))
        }
        return out
    }

    /// One Notes-style phrase per SpeechTranscriber result, with word timings as children.
    nonisolated private static func phraseSegment(
        plain: String,
        words: [WordTiming],
        result: SpeechTranscriber.Result
    ) -> TranscriptionSegment? {
        let text = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || !words.isEmpty else { return nil }
        let phraseText = text.isEmpty ? words.map(\.text).joined(separator: " ") : text
        let start = words.first?.timestamp ?? timeSeconds(result.range.start)
        let end = words.last.map { $0.timestamp + $0.duration }
            ?? (start + max(0.15, timeSeconds(result.range.duration)))
        return TranscriptionSegment(
            text: phraseText,
            timestamp: start,
            duration: max(0.15, end - start),
            wordTimings: words.isEmpty ? nil : words
        )
    }

    nonisolated private static func timeSeconds(_ time: CMTime) -> TimeInterval {
        let seconds = CMTimeGetSeconds(time)
        return seconds.isFinite ? max(0, seconds) : 0
    }

    private static func withTimeout<T: Sendable>(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TranscriptionError.transcriptionFailed("Speech model download timed out. Try again on Wi‑Fi.")
            }
            guard let value = try await group.next() else {
                throw TranscriptionError.transcriptionFailed("Speech model download timed out. Try again on Wi‑Fi.")
            }
            group.cancelAll()
            return value
        }
    }
}
