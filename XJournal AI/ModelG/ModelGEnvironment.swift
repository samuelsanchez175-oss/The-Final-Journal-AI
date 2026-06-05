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

    /// When true (and useModelGCore is true), use Model G v3: planned single-call verse
    /// (~3 calls/verse instead of ~17). Takes precedence over v2 when enabled.
    static var useModelGv3: Bool {
        get { UserDefaults.standard.bool(forKey: "model_g_v3_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_v3_enabled") }
    }

    /// When true (and useModelGCore is true), use Model G v4: v3's planned verse GROUNDED in
    /// retrieved real ground-truth bars (the RAG). Takes precedence over v3 when enabled; if v4
    /// fails or yields nothing it falls back to v3 at runtime. Defaults ON.
    static var useModelGv4: Bool {
        get { (UserDefaults.standard.object(forKey: "model_g_v4_enabled") as? Bool) ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_v4_enabled") }
    }

    /// Originality/inspiration target (0 = lean hard on the culture's idioms & the training lyrics;
    /// 1 = more novel). Default 0.6: fresh but grounded — sterile-original loses the voice.
    static var originalityBias: Double {
        get { (UserDefaults.standard.object(forKey: "model_g_originality_bias") as? Double) ?? 0.6 }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_originality_bias") }
    }

    private static let v3OnlyDefaultsAppliedKey = "ai_product_defaults_v3_only_applied"

    /// One-time migration: toolbar + settings → Model G v3; pin Core + v3 engine flags.
    static func applyV3OnlyProductDefaultsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: v3OnlyDefaultsAppliedKey) else { return }

        let toolbarKey = "toolbar_ai_last_suggestion_model"
        if UserDefaults.standard.string(forKey: toolbarKey) != SuggestionModel.modelGv3.rawValue {
            UserDefaults.standard.set(SuggestionModel.modelGv3.rawValue, forKey: toolbarKey)
        }

        if UserDefaults.standard.data(forKey: "modelGv3_settings") == nil {
            if let legacy = UserDefaults.standard.data(forKey: "modelG_settings") {
                UserDefaults.standard.set(legacy, forKey: "modelGv3_settings")
            } else if let legacyY = UserDefaults.standard.data(forKey: "modelY_settings") {
                UserDefaults.standard.set(legacyY, forKey: "modelGv3_settings")
            }
        }

        useModelGCore = true
        useModelGv3 = true

        UserDefaults.standard.set(true, forKey: v3OnlyDefaultsAppliedKey)
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
    /// Entry musical metadata (BPM/key/scale) — auto-scales the cadence target & biases mood.
    /// Nil when the entry has none. Trailing defaults keep the memberwise init back-compatible.
    var musicalBPM: Int? = nil
    var musicalKey: String? = nil
    var musicalScale: String? = nil
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
