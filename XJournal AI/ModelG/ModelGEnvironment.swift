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

    static var useModelGv4: Bool {
        get { UserDefaults.standard.bool(forKey: "model_g_v4_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_v4_enabled") }
    }

    /// When true (and useModelGCore is true), use Model G v4.1 (Punchline Mode).
    static var useModelGv4_1: Bool {
        get { UserDefaults.standard.bool(forKey: "model_g_v4_1_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_v4_1_enabled") }
    }

    /// When true, bypass Model G Core and use the Gemini Light (Model GL) pipeline.
    static var useModelGL: Bool {
        get { UserDefaults.standard.bool(forKey: "model_gl_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "model_gl_enabled") }
    }

    /// Originality/inspiration target (0 = lean hard on the culture's idioms & the training lyrics;
    /// 1 = more novel). Default 0.6: fresh but grounded — sterile-original loses the voice.
    static var originalityBias: Double {
        get { (UserDefaults.standard.object(forKey: "model_g_originality_bias") as? Double) ?? 0.6 }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_originality_bias") }
    }

    /// Creativity (v3): sampling-temperature spread for verse candidates. 0 = safe/tight, 1 = wild.
    /// Default 0.5 reproduces the legacy candidate temps [0.7, 0.95].
    static var creativity: Double {
        get { (UserDefaults.standard.object(forKey: "model_g_creativity") as? Double) ?? 0.5 }
        set { UserDefaults.standard.set(min(max(newValue, 0), 1), forKey: "model_g_creativity") }
    }

    /// Effort (v3): how many full-verse candidates to generate in parallel and pick the best of
    /// (best-of-N). Higher = better pick but slower + more API cost. 1…4, default 2 (legacy).
    static var effortCandidates: Int {
        get { let v = (UserDefaults.standard.object(forKey: "model_g_effort") as? Int) ?? 2; return min(max(v, 1), 4) }
        set { UserDefaults.standard.set(min(max(newValue, 1), 4), forKey: "model_g_effort") }
    }

    /// Quality bar (v3): if the best candidate's score is below this target, run one extra round
    /// of candidates and re-pick (slower, higher quality). 0 = off (default = legacy behavior),
    /// 1 = retry toward a top score.
    static var qualityBar: Double {
        get { (UserDefaults.standard.object(forKey: "model_g_quality_bar") as? Double) ?? 0.0 }
        set { UserDefaults.standard.set(min(max(newValue, 0), 1), forKey: "model_g_quality_bar") }
    }

    /// ModelGLLMService already calls these. They were missing on this branch, so the app target did not compile.
    /// Off by default. Suggest next lines does not turn this on, and it does not call frontier_v5.py.
    static var useLocalMLXAdapter: Bool {
        get { (UserDefaults.standard.object(forKey: "model_g_local_mlx_enabled") as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_local_mlx_enabled") }
    }

    static var localMLXBaseURL: String {
        get { UserDefaults.standard.string(forKey: "model_g_local_mlx_url") ?? "http://127.0.0.1:8766" }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_local_mlx_url") }
    }

    static var localMLXVoice: String {
        get { UserDefaults.standard.string(forKey: "model_g_local_mlx_voice") ?? "Drake" }
        set { UserDefaults.standard.set(newValue, forKey: "model_g_local_mlx_voice") }
    }

    private static let v3OnlyDefaultsAppliedKey = "ai_product_defaults_v3_only_applied"

    /// Pin the product to a single Model G path (planned verse + corpus). Legacy engine flags stay in UserDefaults but are forced off.
    static func pinSingleModelGPipeline() {
        UserDefaults.standard.set(SuggestionModel.modelG.rawValue, forKey: "toolbar_ai_last_suggestion_model")
        useModelGCore = true
        useModelGv4 = true
        useModelGv3 = false
        useModelGv2 = false
        useModelGv4_1 = false
        useModelGL = false
    }

    /// One-time settings copy, then re-pin the single Model G pipeline on every call so old toggles cannot resurrect.
    static func applyV3OnlyProductDefaultsIfNeeded() {
        if !UserDefaults.standard.bool(forKey: v3OnlyDefaultsAppliedKey) {
            if UserDefaults.standard.data(forKey: "modelGv3_settings") == nil {
                if let legacy = UserDefaults.standard.data(forKey: "modelG_settings") {
                    UserDefaults.standard.set(legacy, forKey: "modelGv3_settings")
                } else if let legacyY = UserDefaults.standard.data(forKey: "modelY_settings") {
                    UserDefaults.standard.set(legacyY, forKey: "modelGv3_settings")
                }
            }
            UserDefaults.standard.set(true, forKey: v3OnlyDefaultsAppliedKey)
        }
        pinSingleModelGPipeline()
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
    /// User-set syllables-per-bar range (nil = auto). Drives candidate selection + the bar rule.
    var syllableMin: Int? = nil
    var syllableMax: Int? = nil
    /// Wrap pocket clock. Default 92 BPM, last stress on beats 3–4. Distinct from syllable *count*.
    var barClock: BarClock? = nil
    /// Model You: confirmed ArtistBrain prompt. Nil on Model G (house wrap).
    var artistBrainPrompt: String? = nil
    /// Model You RAG bars (confirmed chunks). Empty on Model G.
    var artistBrainChunks: [String] = []
}

/// Compute Signal Layer axes (exposure / social action / register / audience) from the
/// journal entry so Model G generation can condition on voice — not just theme/rhyme.
/// Reuses the existing SignalIngest → SignalMode → SignalAxes pipeline. Nil for empty input.
nonisolated func computeModelGSignalAxes(from text: String) -> SignalAxes? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    let metrics = SignalIngest.shared.analyzeBehavior(text: trimmed)
    let mode = SignalMode.resolveMode(from: metrics)
    return SignalAxes.calibrateAxes(metrics: metrics, mode: mode)
}
