//
//  GenerateLyricsFromFlowService.swift
//  XJournal AI
//
//  Orchestrates Scenario A (clear speech) and Scenario B (mumble) for Generate Lyrics from Flow.
//

import Foundation

enum GenerateLyricsFromFlowError: LocalizedError {
    case noAudio
    case transcriptionFailed(String)
    case noBPM
    case backendUnavailable
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .noAudio: return "No audio attached to this entry."
        case .transcriptionFailed(let msg): return "Transcription failed: \(msg)"
        case .noBPM: return "Could not detect BPM. Try analyzing audio first."
        case .backendUnavailable: return "Flow detection service is unavailable."
        case .generationFailed(let msg): return "Generation failed: \(msg)"
        }
    }
}

enum GenerateLyricsFromFlowService {
    /// Scenario A: Use existing transcription + BPM to build rhythm map, then generate lyrics.
    static func runScenarioA(item: Item, theme: String?) async throws -> String {
        guard item.audioPath != nil, !(item.audioPath?.isEmpty ?? true) else {
            throw GenerateLyricsFromFlowError.noAudio
        }
        // Implemented in step 2: transcribe if needed, assemble, call RapSuggestionAPI.generateLyricsFromFlow
        return try await ScenarioARunner.run(item: item, theme: theme)
    }

    /// Scenario B: Send audio to onset-detection backend, get skeleton, then generate lyrics.
    static func runScenarioB(item: Item, theme: String?) async throws -> String {
        guard item.audioPath != nil, !(item.audioPath?.isEmpty ?? true) else {
            throw GenerateLyricsFromFlowError.noAudio
        }
        // Implemented in step 5: FlowSkeletonService + generateLyricsFromFlow
        return try await ScenarioBRunner.run(item: item, theme: theme)
    }
}

// MARK: - Scenario A (clear speech) – wired in step 2
private enum ScenarioARunner {
    static func run(item: Item, theme: String?) async throws -> String {
        guard let segments = item.transcriptionSegments, !segments.isEmpty else {
            throw GenerateLyricsFromFlowError.transcriptionFailed("No transcript. Transcribe the audio first from the audio detail view.")
        }
        let bpm = item.bpm
        let rhythmResult = TranscriptionAssembler.assemble(
            segments: segments,
            bpm: bpm,
            timeSignature: .fourFour,
            barOffsetMs: 0,
            audioId: item.audioPath
        )
        return try await RapSuggestionAPI.shared.generateLyricsFromFlow(
            rhythmResult: rhythmResult,
            theme: theme
        )
    }
}

// MARK: - Scenario B (mumble) – wired in step 5
private enum ScenarioBRunner {
    static func run(item: Item, theme: String?) async throws -> String {
        guard let path = item.audioPath, !path.isEmpty else {
            throw GenerateLyricsFromFlowError.noAudio
        }
        let audioURL = URL(fileURLWithPath: path)
        let rhythmResult = try await FlowSkeletonService.extractSkeleton(audioURL: audioURL, bpm: item.bpm)
        return try await RapSuggestionAPI.shared.generateLyricsFromFlow(
            rhythmResult: rhythmResult,
            theme: theme
        )
    }
}
