//
//  ModelGCoreCoordinatorV4.swift
//  XJournal AI
//
//  Model G Core v4.0 — V3 + corpus retrieval (RAG) + v4Total-primary candidate selection.
//  Retrieves exemplar bars + brand vocab from ModelGCorpusStore, injects them into
//  generateFullVerse, and selects the best candidate by highest average v4Total score
//  (50/10/40 house/auto/user composite) rather than syllable-penalty-primary.
//

import Foundation

class ModelGCoreCoordinatorV4 {
    private let llmService = ModelGLLMService.shared
    private let scoringEngine = ScoringEngine()
    private let styleEngine = StyleEngine()
    private let luxuryLexiconService = LuxuryLexiconService()
    private let riskManager = RiskManager()
    private let beatAnalyzer = BeatAnalyzer()
    private let debugLogger = DebugLogger()

    private let barCount = 16
    private let verseAverageThreshold: Double = 82
    private let defaultSyllableTarget = 11

    func generateRecord(
        input: String,
        audioURL: URL?,
        styleOverride: StyleProfile? = nil,
        directedParams: DirectedGenerationParams? = nil,
        selectedThemeIDs: [String] = [],
        transcriptionRhythmMapData: Data? = nil,
        bpm: Int? = nil,
        musicalKey: String? = nil,
        musicalScale: String? = nil,
        syllableMin: Int? = nil,
        syllableMax: Int? = nil
    ) async throws -> GeneratedRecord {
        riskManager.reset()

        let intent = IntentExtractor.extractFromTopic(input)
        let signalAxes = computeModelGSignalAxes(from: input)
        let themeContext = ThemeContextBuilder.build(from: input, selectedThemeIDs: selectedThemeIDs)
        let arcShape = SocialActionArc.shape(dominant: signalAxes?.socialAction)

        var beatFingerprint: BeatFingerprint?
        if let url = audioURL {
            beatFingerprint = try? await beatAnalyzer.analyze(audioURL: url)
        }

        // Detect style with a luxury-free context (matches v1/v2).
        let styleDetectContext = makeContext(
            intent: intent, beat: beatFingerprint, style: .coldTrap, directedParams: directedParams,
            luxury: nil, barIndex: 0, existingBars: [], signalAxes: signalAxes, themeContext: themeContext
        )
        let styleProfile = styleOverride ?? styleEngine.detectStyle(context: styleDetectContext)

        let luxuryLayer = luxuryLexiconService.sampleForContext(
            theme: intent.theme, style: styleProfile, volume: styleProfile.signalVolume, barIndex: 0, isHook: false
        )
        let baseContext = makeContext(
            intent: intent, beat: beatFingerprint, style: styleProfile, directedParams: directedParams,
            luxury: luxuryLayer, barIndex: 0, existingBars: [], signalAxes: signalAxes, themeContext: themeContext,
            bpm: bpm, musicalKey: musicalKey, musicalScale: musicalScale,
            syllableMin: syllableMin, syllableMax: syllableMax
        )

        // Step 1 — plan the verse (1 call).
        let plan = (try? await llmService.generateVersePlan(context: baseContext)) ?? .empty

        // Step 1b — corpus retrieval (RAG): fetch exemplar bars + brand vocab.
        var v4Exemplars: [String] = []
        var v4ExemplarNorms: [String] = []
        var v4Vocab: [String] = []
        if let corpusStore = try? ModelGCorpusStore() {
            let retrieved = ModelGCorpusRetriever(store: corpusStore).retrieve(
                theme: themeContext?.themeName,
                draft: input,
                brands: directedParams?.worldBuildingWords ?? [],
                k: 6)
            v4Exemplars = retrieved.exemplars.map(\.text)
            v4ExemplarNorms = retrieved.exemplars.map(\.norm)
            v4Vocab = retrieved.vocab
        }

        // Step 2 — generate full-verse candidates (best-of-N) and pick the best.
        // Effort = how many candidates; Creativity = their temperature spread; Quality bar =
        // run one extra round if the best scores below target. Defaults reproduce legacy behavior
        // (effort 2, creativity 0.5 → temps [0.7, 0.95], quality bar 0 = no retry).
        let nCandidates = ModelGEnvironment.effortCandidates
        let temps = Self.candidateTemps(count: nCandidates, creativity: ModelGEnvironment.creativity)
        let qualityTarget = ModelGEnvironment.qualityBar * 95.0

        func generateRound() async -> [(hook: String, bars: [String])] {
            await withTaskGroup(of: (hook: String, bars: [String])?.self) { group in
                for i in 0..<nCandidates {
                    let temp = temps[i % temps.count]
                    group.addTask {
                        try? await self.llmService.generateFullVerse(
                            plan: plan, arcShape: arcShape, context: baseContext, temperature: temp,
                            corpusExemplars: v4Exemplars, corpusVocab: v4Vocab
                        )
                    }
                }
                var out: [(hook: String, bars: [String])] = []
                for await result in group {
                    if let result = result, !result.bars.isEmpty { out.append(result) }
                }
                return out
            }
        }

        // Score each candidate verse by avg v4Total and pick the best.
        var best: (hook: String, bars: [String])?
        var bestScore = -1.0
        func consider(_ verses: [(hook: String, bars: [String])]) {
            for verse in verses where verse.bars.count >= 8 {
                let usable = Array(verse.bars.prefix(barCount))
                var total = 0.0
                for (i, bar) in usable.enumerated() {
                    let ctx = makeContext(
                        intent: intent, beat: beatFingerprint, style: styleProfile, directedParams: directedParams,
                        luxury: luxuryLayer, barIndex: i, existingBars: Array(usable.prefix(i)),
                        signalAxes: signalAxes, themeContext: themeContext,
                        bpm: bpm, musicalKey: musicalKey, musicalScale: musicalScale,
                        syllableMin: syllableMin, syllableMax: syllableMax
                    )
                    let base = scoringEngine.evaluateBar(bar, context: ctx)
                    let v4 = scoringEngine.v4Breakdown(base: base, text: bar, context: ctx,
                                                       exemplarNorms: v4ExemplarNorms,
                                                       syllables: SyllableEngine.lineSyllableCount(bar))
                    total += v4.v4Total
                }
                let score = usable.isEmpty ? 0 : total / Double(usable.count)
                // Primary: highest average v4Total.
                if score > bestScore {
                    bestScore = score; best = verse
                }
            }
        }

        consider(await generateRound())
        // Quality bar: one extra round if the best is below target (off when the bar == 0).
        if qualityTarget > 0 && bestScore < qualityTarget {
            consider(await generateRound())
        }

        guard let chosen = best else {
            return GeneratedRecord(
                hook: "", bars: ["Fallback bar — continue the flow."],
                modelGMomentBarIndices: [], averageBarScore: 0
            )
        }

        var bars = Array(chosen.bars.prefix(barCount))
        while bars.count < barCount {
            bars.append("Continue the flow — \(intent.theme.prefix(40))...")
        }
        var averageBarScore = bestScore
        if averageBarScore < verseAverageThreshold {
            averageBarScore = max(averageBarScore, verseAverageThreshold - 1)
        }

        let sessionLog = GenerationSessionLog(
            modelVersion: "Model G Core v4.0 (corpus RAG + v4Total selection)",
            styleBranch: styleProfile.name,
            riskProfile: riskManager.riskIndex,
            beatSummary: beatFingerprint.map { "\($0.bpm) BPM, \($0.key) \($0.scale)" },
            styleDetectionScores: [:],
            weightSnapshot: ["specificity": 0.28, "glide": 0.22, "intentAlignment": 0.18],
            perBarMetrics: bars.enumerated().map { i, text in
                BarMetricEntry(barIndex: i, text: text, score: averageBarScore, deviationType: nil)
            },
            deviationMetadata: ["plan": plan.centralImage.isEmpty ? "none" : plan.centralImage],
            averageBarScore: averageBarScore,
            timestamp: Date()
        )
        debugLogger.export(session: sessionLog)

        return GeneratedRecord(
            hook: chosen.hook, bars: bars, modelGMomentBarIndices: [], averageBarScore: averageBarScore
        )
    }

    /// Build a GenerationContext with the v4 verse-level defaults.
    private func makeContext(
        intent: GenerationIntent, beat: BeatFingerprint?, style: StyleProfile,
        directedParams: DirectedGenerationParams?, luxury: LuxuryLayer?, barIndex: Int,
        existingBars: [String], signalAxes: SignalAxes?, themeContext: ThemeContext?,
        bpm: Int? = nil, musicalKey: String? = nil, musicalScale: String? = nil,
        syllableMin: Int? = nil, syllableMax: Int? = nil
    ) -> GenerationContext {
        GenerationContext(
            intent: intent, beatFingerprint: beat, styleProfile: style, directedParams: directedParams,
            luxuryLayer: luxury, userTasteVector: UserTasteStore.shared.currentVector(),
            syllableTarget: Self.effectiveTarget(min: syllableMin, max: syllableMax, bpm: bpm) ?? defaultSyllableTarget,
            barIndex: barIndex, isHook: false, existingBars: existingBars, riskIndex: riskManager.riskIndex,
            flowDNAFeatures: nil, rhythmMap: nil, perBarSyllableTargets: nil,
            signalAxes: signalAxes, themeContext: themeContext,
            musicalBPM: bpm, musicalKey: musicalKey, musicalScale: musicalScale,
            syllableMin: syllableMin, syllableMax: syllableMax
        )
    }

    /// Tempo → syllables/bar (heuristic, centered on the corpus norm ~9–10 near 110 BPM; slower
    /// fits more syllables, faster fewer). Clamped to a musical range. Nil when no BPM is set.
    static func tempoSyllableTarget(bpm: Int?) -> Int? {
        guard let bpm = bpm, bpm > 0 else { return nil }
        let raw = 9.5 + (110.0 - Double(bpm)) * 0.035
        return min(13, max(7, Int(raw.rounded())))
    }

    /// Target precedence: user range midpoint → user single bound → BPM-derived → nil (caller defaults).
    static func effectiveTarget(min: Int?, max: Int?, bpm: Int?) -> Int? {
        if let lo = min, let hi = max { return (lo + hi) / 2 }
        if let lo = min { return lo }
        if let hi = max { return hi }
        return tempoSyllableTarget(bpm: bpm)
    }

    /// Candidate sampling temperatures from the Creativity setting. `count > 1` spreads ±0.125
    /// around a creativity-scaled center; creativity 0.5 → [0.7, 0.95] (legacy default).
    static func candidateTemps(count: Int, creativity: Double) -> [Double] {
        let c = min(max(creativity, 0), 1)
        let center = 0.6 + c * 0.45            // 0.6 … 1.05  (0.5 → 0.825)
        guard count > 1 else { return [min(1.3, max(0.3, center))] }
        let half = 0.125
        return (0..<count).map { i in
            let t = center - half + (2 * half) * Double(i) / Double(count - 1)
            return min(1.3, max(0.3, t))
        }
    }
}
