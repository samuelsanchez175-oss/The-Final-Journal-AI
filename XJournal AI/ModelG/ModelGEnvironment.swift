//
//  ModelGEnvironment.swift
//  XJournal AI
//
//  Model G Core v1.0 — Environment and mode configuration.
//

import Foundation

/// Model G runtime mode. Debug enables JSON export.
enum ModelGMode: String, Codable {
    case production
    case debug
}

/// Model G environment configuration.
enum ModelGEnvironment {
    static var mode: ModelGMode {
        #if DEBUG
        return .debug
        #else
        return .production
        #endif
    }

    /// When true, use Model G Core v1.0 pipeline instead of legacy batch generation.
    static var useModelGCore: Bool {
        get { UserDefaults.standard.bool(forKey: "model_g_core_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_core_enabled") }
    }

    /// When true (and useModelGCore is true), use Model G v2 pipeline with Flow DNA analysis.
    static var useModelGv2: Bool {
        get { UserDefaults.standard.bool(forKey: "model_g_v2_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_v2_enabled") }
    }
}

// MARK: - Generation Context

/// Context passed through the Model G pipeline for bar/hook generation.
struct GenerationContext {
    let intent: GenerationIntent
    let beatFingerprint: BeatFingerprint?
    let styleProfile: StyleProfile
    let directedParams: DirectedGenerationParams?
    let luxuryLayer: LuxuryLayer?
    let userTasteVector: UserTasteVector
    let syllableTarget: Int
    let barIndex: Int
    let isHook: Bool
    let existingBars: [String]
    let riskIndex: Double
    /// Flow DNA feature vector (Model G v2).
    let flowDNAFeatures: FlowDNAFeatures?
    /// Rhythm map from transcription (Model G v2).
    let rhythmMap: RhythmicTranscriptionResult?
    /// Per-bar syllable counts from rhythm map; index = bar index.
    let perBarSyllableTargets: [Int]?
    /// Signal Layer axes (exposure / social action / register / audience) for this verse.
    /// Nil = not supplied (e.g. legacy callers); the prompt builder then omits the voice block.
    var signalAxes: SignalAxes? = nil
    /// Detected theme + jargon palette + emotional tone + few-shot example for this verse.
    var themeContext: ThemeContext? = nil
}

/// Compute Signal Layer axes (exposure / social action / register / audience) from the
/// journal entry so Model G generation can condition on voice — not just theme/rhyme.
/// Reuses the existing SignalIngest → SignalMode → SignalAxes pipeline. Nil for empty input.
func computeModelGSignalAxes(from text: String) -> SignalAxes? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    let metrics = SignalIngest.shared.analyzeBehavior(text: trimmed)
    let mode = SignalMode.resolveMode(from: metrics)
    return SignalAxes.calibrateAxes(metrics: metrics, mode: mode)
}
