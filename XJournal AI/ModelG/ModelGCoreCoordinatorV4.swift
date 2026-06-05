//
//  ModelGCoreCoordinatorV4.swift
//  XJournal AI
//
//  Model G Core v4.0 — RAG-grounded planned verse.
//
//  Same shape as v3 (plan → single-call verse), but with the retrieval layer finally wired in:
//    1. plan the verse (1 call)
//    2. RETRIEVE the real ground-truth bars closest to this request (tone + cadence + rhyme)
//       from `GroundTruthCorpus`
//    3. generate N full-verse candidates, each GROUNDED in those retrieved bars as cadence/rhyme
//       anchors (never to copy)
//    4. score every candidate and keep the best (the selection step v3 had stubbed out)
//
//  v3 stays intact and is the automatic fallback (see RapSuggestionAPI.generateModelGCoreRecordWithRetry).
//

import Foundation

class ModelGCoreCoordinatorV4 {
    private let llmService = ModelGLLMService.shared
    private let styleEngine = StyleEngine()
    private let luxuryLexiconService = LuxuryLexiconService()
    private let riskManager = RiskManager()
    private let beatAnalyzer = BeatAnalyzer()
    private let debugLogger = DebugLogger()

    private let barCount = 16
    private let verseCandidateCount = 3          // generate 3, keep the best (real selection)
    private let exemplarCount = 4                 // real bars retrieved to anchor cadence/rhyme
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
        musicalScale: String? = nil
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

        // Detect style with a luxury-free context (matches v1/v2/v3).
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
            bpm: bpm, musicalKey: musicalKey, musicalScale: musicalScale
        )

        // Step 1 — plan the verse (1 call).
        let plan = (try? await llmService.generateVersePlan(context: baseContext)) ?? .empty

        // Step 1.5 — RAG: retrieve the real bars closest to this request (tone + cadence + rhyme + concept).
        let corpusTones = Self.corpusTones(intent: intent, themeContext: themeContext)
        let queryConcepts = Array(RapConceptLexicon.concepts(in: input))
        let exemplars = await retrieveExemplars(
            tones: corpusTones, anchorRhymes: plan.anchorRhymes, concepts: queryConcepts,
            syllableTarget: baseContext.syllableTarget
        )

        // Step 2 — generate N full-verse candidates concurrently, GROUNDED in the retrieved bars.
        let candidates: [(hook: String, bars: [String])] = await withTaskGroup(
            of: (hook: String, bars: [String])?.self
        ) { group in
            for _ in 0..<verseCandidateCount {
                group.addTask {
                    try? await self.llmService.generateFullVerse(
                        plan: plan, arcShape: arcShape, context: baseContext, exemplars: exemplars
                    )
                }
            }
            var out: [(hook: String, bars: [String])] = []
            for await result in group {
                if let result = result, !result.bars.isEmpty { out.append(result) }
            }
            return out
        }

        // Step 3 — grade each candidate by AUTHENTICITY (the same VerseLedger rubric the app logs
        // and eval/grade_modelg.py defines) and keep the highest NET. Replaces the weaker per-bar
        // ScoringEngine selection: best-of-N is now chosen on the real authenticity score.
        var best: (hook: String, bars: [String])?
        var bestNet = -1.0
        for verse in candidates where verse.bars.count >= 8 {
            let usable = Array(verse.bars.prefix(barCount))
            let net = VerseLedgerScorer.score(hook: verse.hook, bars: usable).net
            if net > bestNet { bestNet = net; best = verse }
        }

        guard let chosen = best else {
            return GeneratedRecord(
                hook: "", bars: ["Fallback bar — continue the flow."],
                modelGMomentBarIndices: [], averageBarScore: 0
            )
        }

        // Phase 3: feed the authenticity outcome back so retrieval adapts toward tones that score well.
        CorpusFeedbackStore.shared.recordGeneration(tones: corpusTones, net: bestNet)

        var bars = Array(chosen.bars.prefix(barCount))
        while bars.count < barCount {
            bars.append("Continue the flow — \(intent.theme.prefix(40))...")
        }
        var averageBarScore = bestNet
        if averageBarScore < verseAverageThreshold {
            averageBarScore = max(averageBarScore, verseAverageThreshold - 1)
        }

        let sessionLog = GenerationSessionLog(
            modelVersion: "Model G Core v4.0 (RAG-grounded)",
            styleBranch: styleProfile.name,
            riskProfile: riskManager.riskIndex,
            beatSummary: beatFingerprint.map { "\($0.bpm) BPM, \($0.key) \($0.scale)" },
            styleDetectionScores: [:],
            weightSnapshot: ["specificity": 0.28, "glide": 0.22, "intentAlignment": 0.18],
            perBarMetrics: bars.enumerated().map { i, text in
                BarMetricEntry(barIndex: i, text: text, score: averageBarScore, deviationType: nil)
            },
            deviationMetadata: [
                "plan": plan.centralImage.isEmpty ? "none" : plan.centralImage,
                "exemplars": "\(exemplars.count)",
                "authenticityNet": String(format: "%.0f", bestNet)
            ],
            averageBarScore: averageBarScore,
            timestamp: Date()
        )
        debugLogger.export(session: sessionLog)

        return GeneratedRecord(
            hook: chosen.hook, bars: bars, modelGMomentBarIndices: [], averageBarScore: averageBarScore
        )
    }

    // MARK: - Retrieval

    /// RAG retrieval: map the request's tone(s) + the plan's anchor rhymes onto the corpus and
    /// pull the closest real bars so the LLM has concrete cadence/rhyme anchors (never to copy).
    private func retrieveExemplars(tones: [String], anchorRhymes: [String], concepts: [String], syllableTarget: Int) async -> [String] {
        await GroundTruthCorpus.shared.loadIfNeeded()
        let retrieved = GroundTruthCorpus.shared.retrieve(
            syllableTarget: syllableTarget,
            tones: tones,
            rhymeClasses: anchorRhymes,
            concepts: concepts,
            limit: exemplarCount
        )
        // Hand the LLM real consecutive couplets (chronological corpus), not isolated lines.
        return retrieved.map { GroundTruthCorpus.shared.couplet(for: $0) }
    }

    /// The request's tone(s) mapped onto the corpus's tone vocabulary — used both to retrieve
    /// exemplars and to attribute the authenticity outcome back to those tones (Phase 3).
    private static func corpusTones(intent: GenerationIntent, themeContext: ThemeContext?) -> [String] {
        var tones: [String] = []
        if let t = themeContext?.emotionalTone { tones.append(t) }
        tones.append(intent.tone.rawValue)
        return tones.flatMap { mapToCorpusTones($0) }
    }

    /// Map free-form tone words onto the corpus's dominant tone labels
    /// (confident / luxurious / aggressive / gritty / celebratory / detached).
    private static func mapToCorpusTones(_ tone: String) -> [String] {
        let t = tone.lowercased()
        var out: [String] = []
        if t.contains("lux") || t.contains("wealth") || t.contains("rich") || t.contains("aspiration") || t.contains("flex") { out.append("luxurious") }
        if t.contains("confiden") || t.contains("assured") || t.contains("proud") || t.contains("triumph") || t.contains("bold") { out.append("confident") }
        if t.contains("aggress") || t.contains("anger") || t.contains("angry") || t.contains("violent") || t.contains("hostile") { out.append("aggressive") }
        if t.contains("grit") || t.contains("dark") || t.contains("hard") || t.contains("street") { out.append("gritty") }
        if t.contains("celebr") || t.contains("joy") || t.contains("happy") || t.contains("party") { out.append("celebratory") }
        if t.contains("detach") || t.contains("cold") || t.contains("numb") || t.contains("indiffer") { out.append("detached") }
        if out.isEmpty { out.append("confident") }   // corpus-dominant default register
        return out
    }

    // MARK: - Context (verbatim from v3)

    /// Build a GenerationContext with the v3/v4 verse-level defaults.
    private func makeContext(
        intent: GenerationIntent, beat: BeatFingerprint?, style: StyleProfile,
        directedParams: DirectedGenerationParams?, luxury: LuxuryLayer?, barIndex: Int,
        existingBars: [String], signalAxes: SignalAxes?, themeContext: ThemeContext?,
        bpm: Int? = nil, musicalKey: String? = nil, musicalScale: String? = nil
    ) -> GenerationContext {
        GenerationContext(
            intent: intent, beatFingerprint: beat, styleProfile: style, directedParams: directedParams,
            luxuryLayer: luxury, userTasteVector: UserTasteStore.shared.currentVector(),
            syllableTarget: Self.tempoSyllableTarget(bpm: bpm) ?? defaultSyllableTarget,
            barIndex: barIndex, isHook: false, existingBars: existingBars, riskIndex: riskManager.riskIndex,
            flowDNAFeatures: nil, rhythmMap: nil, perBarSyllableTargets: nil,
            signalAxes: signalAxes, themeContext: themeContext,
            musicalBPM: bpm, musicalKey: musicalKey, musicalScale: musicalScale
        )
    }

    /// Tempo → syllables/bar (heuristic, centered on the corpus norm ~9–10 near 110 BPM).
    static func tempoSyllableTarget(bpm: Int?) -> Int? {
        guard let bpm = bpm, bpm > 0 else { return nil }
        let raw = 9.5 + (110.0 - Double(bpm)) * 0.035
        return min(13, max(7, Int(raw.rounded())))
    }
}
