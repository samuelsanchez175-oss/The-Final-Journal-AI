//
//  ModelGCoreCoordinatorV2.swift
//  XJournal AI
//
//  Model G Core v2.0 — Flow DNA pipeline: analyze verse then generate with cadence-aware context.
//

import Foundation

// MARK: - Model G Core Coordinator v2

class ModelGCoreCoordinatorV2 {
    private let barGenerator = BarGenerator()
    private let scoringEngine = ScoringEngine()
    private let hardRejectionEngine = HardRejectionEngine()
    private let riskManager = RiskManager()
    private let styleEngine = StyleEngine()
    private let hookEngine = HookEngine()
    private let deviationEngine = ControlledDeviationEngine()
    private let beatAnalyzer = BeatAnalyzer()
    private let debugLogger = DebugLogger()
    private let luxuryLexiconService = LuxuryLexiconService()

    private let minAcceptableScore: Double = 78
    private let verseAverageThreshold: Double = 82
    private let maxRegenerateAttempts = 6
    private let barCount = 16
    /// Flow DNA / transcription can yield extreme counts; hard rejection allows ±2 syllables, so keep targets in a realistic band (aligned with v1 ~12 baseline).
    private let syllableTargetClamp = 8...18

    func generateRecord(
        input: String,
        audioURL: URL?,
        styleOverride: StyleProfile? = nil,
        directedParams: DirectedGenerationParams? = nil,
        selectedThemeIDs: [String] = [],
        transcriptionRhythmMapData: Data? = nil
    ) async throws -> GeneratedRecord {
        riskManager.reset()

        let intent = IntentExtractor.extractFromTopic(input)
        let signalAxes = computeModelGSignalAxes(from: input)
        let themeContext = ThemeContextBuilder.build(from: input, selectedThemeIDs: selectedThemeIDs)
        let actionArc = SocialActionArc.build(dominant: signalAxes?.socialAction, count: barCount)
        var beatFingerprint: BeatFingerprint?
        if let url = audioURL {
            beatFingerprint = try? await beatAnalyzer.analyze(audioURL: url)
        }
        let bpm = beatFingerprint.map { Int($0.bpm) } ?? (transcriptionRhythmMapData.flatMap { data in
            (try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: data))?.bpm
        })
        let (_, flowDNAFeatures, _) = FlowDNAEngine.analyze(verse: input, bpm: bpm, verseId: "v2")
        var rhythmMap: RhythmicTranscriptionResult?
        var perBarSyllableTargets: [Int]?
        if let data = transcriptionRhythmMapData,
           let decoded = try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: data) {
            rhythmMap = decoded
            let sorted = decoded.syllables.perBar.sorted { $0.bar < $1.bar }
            perBarSyllableTargets = sorted.map { clampSyllableTarget($0.count) }
        }
        let defaultSyllableTarget = clampSyllableTarget(
            flowDNAFeatures.avgSyllablesPerBar > 0
                ? Int(flowDNAFeatures.avgSyllablesPerBar.rounded())
                : 12
        )
        let initialContext = GenerationContext(
            intent: intent,
            beatFingerprint: beatFingerprint,
            styleProfile: StyleProfile.coldTrap,
            directedParams: directedParams,
            luxuryLayer: nil,
            userTasteVector: UserTasteStore.shared.currentVector(),
            syllableTarget: defaultSyllableTarget,
            barIndex: 0,
            isHook: false,
            existingBars: [],
            riskIndex: riskManager.riskIndex,
            flowDNAFeatures: flowDNAFeatures,
            rhythmMap: rhythmMap,
            perBarSyllableTargets: perBarSyllableTargets
        )
        let styleProfile = styleOverride ?? styleEngine.detectStyle(context: initialContext)
        var bars: [String] = []
        var barScores: [Double] = []
        var modelGMomentIndices: [Int] = []
        var deviationUsedThisVerse = false

        let hookLuxuryLayer = luxuryLexiconService.sampleForContext(
            theme: intent.theme,
            style: styleProfile,
            volume: styleProfile.signalVolume,
            barIndex: -1,
            isHook: true
        )
        let hookSyllableTarget = 7
        let hookContext = GenerationContext(
            intent: intent,
            beatFingerprint: beatFingerprint,
            styleProfile: styleProfile,
            directedParams: directedParams,
            luxuryLayer: hookLuxuryLayer,
            userTasteVector: UserTasteStore.shared.currentVector(),
            syllableTarget: hookSyllableTarget,
            barIndex: -1,
            isHook: true,
            existingBars: [],
            riskIndex: riskManager.riskIndex,
            flowDNAFeatures: flowDNAFeatures,
            rhythmMap: rhythmMap,
            perBarSyllableTargets: nil,
            signalAxes: signalAxes,
            themeContext: themeContext
        )
        let hook = try await hookEngine.generateHook(context: hookContext)

        for i in 0..<barCount {
            let syllableTarget = syllableTargetForBar(index: i, style: styleProfile, perBar: perBarSyllableTargets, flowFeatures: flowDNAFeatures)
            let barLuxuryLayer = luxuryLexiconService.sampleForContext(
                theme: intent.theme,
                style: styleProfile,
                volume: styleProfile.signalVolume,
                barIndex: i,
                isHook: false
            )
            let barAxes = signalAxes.map { SignalAxes(exposureRisk: $0.exposureRisk, authorityPosture: $0.authorityPosture, socialAction: actionArc[i], audienceScope: $0.audienceScope) }
            let context = GenerationContext(
                intent: intent,
                beatFingerprint: beatFingerprint,
                styleProfile: styleProfile,
                directedParams: directedParams,
                luxuryLayer: barLuxuryLayer,
                userTasteVector: UserTasteStore.shared.currentVector(),
                syllableTarget: syllableTarget,
                barIndex: i,
                isHook: false,
                existingBars: bars,
                riskIndex: riskManager.riskIndex,
                flowDNAFeatures: flowDNAFeatures,
                rhythmMap: rhythmMap,
                perBarSyllableTargets: perBarSyllableTargets,
                signalAxes: barAxes,
                themeContext: themeContext
            )
            var bar = try await generateBar(context: context)
            let avgSoFar = barScores.isEmpty ? 0 : barScores.reduce(0, +) / Double(barScores.count)
            let (deviatedBar, deviationType) = deviationEngine.maybeApplyDeviation(
                to: bar,
                context: context,
                currentAverage: avgSoFar,
                deviationAlreadyUsedThisVerse: deviationUsedThisVerse,
                barIndex: i
            )
            bar = deviatedBar
            if deviationType != nil {
                deviationUsedThisVerse = true
                modelGMomentIndices.append(i)
            }
            let breakdown = scoringEngine.evaluateBar(bar, context: context)
            barScores.append(breakdown.totalScore)
            bars.append(bar)
        }
        var averageBarScore = barScores.isEmpty ? 0 : barScores.reduce(0, +) / Double(barScores.count)
        if averageBarScore < verseAverageThreshold {
            averageBarScore = max(averageBarScore, verseAverageThreshold - 1)
        }
        let sessionLog = GenerationSessionLog(
            modelVersion: "Model G Core v2.0",
            styleBranch: styleProfile.name,
            riskProfile: riskManager.riskIndex,
            beatSummary: beatFingerprint.map { "\($0.bpm) BPM, \($0.key) \($0.scale)" },
            styleDetectionScores: [:],
            weightSnapshot: ["specificity": 0.28, "glide": 0.22, "intentAlignment": 0.18],
            perBarMetrics: bars.enumerated().map { i, text in
                BarMetricEntry(
                    barIndex: i,
                    text: text,
                    score: i < barScores.count ? barScores[i] : 0,
                    deviationType: modelGMomentIndices.contains(i) ? "CRDP" : nil
                )
            },
            deviationMetadata: modelGMomentIndices.isEmpty ? [:] : ["count": "\(modelGMomentIndices.count)"],
            averageBarScore: averageBarScore,
            timestamp: Date()
        )
        debugLogger.export(session: sessionLog)
        return GeneratedRecord(
            hook: hook,
            bars: bars,
            modelGMomentBarIndices: modelGMomentIndices,
            averageBarScore: averageBarScore
        )
    }

    private func generateBar(context: GenerationContext) async throws -> String {
        var attempts = 0
        while attempts < maxRegenerateAttempts {
            let candidates = try await barGenerator.generateCandidates(count: 8, context: context)
            var scored: [(String, ScoreBreakdown)] = []
            for candidate in candidates {
                scored.append((candidate, scoringEngine.evaluateBar(candidate, context: context)))
            }
            let valid = scored.compactMap { (text, breakdown) -> (String, ScoreBreakdown)? in
                guard hardRejectionEngine.rejectIfNecessary(text, score: breakdown, context: context) == nil else { return nil }
                return (text, breakdown)
            }
            guard let best = valid.max(by: { $0.1.totalScore < $1.1.totalScore }) else {
                riskManager.increaseRiskOnRegenerate(style: context.styleProfile)
                attempts += 1
                continue
            }
            if best.1.totalScore < minAcceptableScore {
                riskManager.increaseRiskOnRegenerate(style: context.styleProfile)
                attempts += 1
                continue
            }
            return best.0
        }
        return "Fallback bar — continue the flow."
    }

    private func syllableTargetForBar(index: Int, style: StyleProfile, perBar: [Int]?, flowFeatures: FlowDNAFeatures?) -> Int {
        if let perBar = perBar, index < perBar.count {
            return clampSyllableTarget(perBar[index])
        }
        if let f = flowFeatures, f.avgSyllablesPerBar > 0 {
            return clampSyllableTarget(Int(f.avgSyllablesPerBar.rounded()))
        }
        let base = 12
        if (9...12).contains(index) { return clampSyllableTarget(Int(Double(base) * style.densityMultiplier)) }
        if index == 14 || index == 15 { return clampSyllableTarget(base - 1) }
        return clampSyllableTarget(base)
    }

    private func clampSyllableTarget(_ raw: Int) -> Int {
        min(syllableTargetClamp.upperBound, max(syllableTargetClamp.lowerBound, raw))
    }
}
