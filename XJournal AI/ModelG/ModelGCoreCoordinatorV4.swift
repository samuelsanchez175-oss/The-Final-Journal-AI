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

    private let defaultBarCount = 16
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
        syllableMax: Int? = nil,
        artistBrainPrompt: String? = nil,
        artistBrainChunks: [String] = []
    ) async throws -> GeneratedRecord {
        riskManager.reset()

        let intent = IntentExtractor.extractForModelG(draft: input, directedParams: directedParams)
        let signalAxes = computeModelGSignalAxes(from: input)
        let themeContext = ThemeContextBuilder.build(from: input, selectedThemeIDs: selectedThemeIDs)
        let arcShape = directedParams?.storyArc == true
            ? DirectedGenerationParams.storyArcPrompt
            : SocialActionArc.shape(dominant: signalAxes?.socialAction)
        let wrapOn = directedParams?.gunnaWrap != false
        let targetBarCount = directedParams?.targetBarCount == 4 ? 4 : defaultBarCount

        var beatFingerprint: BeatFingerprint?
        if let url = audioURL {
            beatFingerprint = try? await beatAnalyzer.analyze(audioURL: url)
        }
        // Note fields first; if the beat is attached but BPM/key never saved, use the live fingerprint.
        let liveBPM = beatFingerprint.flatMap { $0.bpm > 0 ? Int($0.bpm.rounded()) : nil }
        let liveKey = nonempty(beatFingerprint?.key)
        let liveScale = nonempty(beatFingerprint?.scale)
        let noteBPM = bpm ?? liveBPM
        let noteKey = nonempty(musicalKey) ?? liveKey
        let noteScale = nonempty(musicalScale) ?? liveScale

        let resolvedBPM = wrapOn
            ? (directedParams?.resolvedWrapBPM(noteBPM: noteBPM) ?? noteBPM)
            : noteBPM
        let barClock: BarClock? = wrapOn
            ? BarClock.resolve(
                userBPM: resolvedBPM,
                pocket: directedParams?.wrapPocket ?? .behind,
                foldHatsEnabled: true
            )
            : nil

        // Detect style with a luxury-free context (matches v1/v2).
        let styleDetectContext = makeContext(
            intent: intent, beat: beatFingerprint, style: .coldTrap, directedParams: directedParams,
            luxury: nil, barIndex: 0, existingBars: [], signalAxes: signalAxes, themeContext: themeContext,
            barClock: barClock
        )
        let styleProfile = styleOverride ?? styleEngine.detectStyle(context: styleDetectContext)

        let usingArtistBrain = ModelYouWriterPolicy.usesArtistSeat(artistBrainPrompt: artistBrainPrompt)
        let luxuryLayer: LuxuryLayer? = ModelYouWriterPolicy.usesHouseLuxury(artistBrainPrompt: artistBrainPrompt)
            ? luxuryLexiconService.sampleForContext(
                theme: intent.theme, style: styleProfile, volume: styleProfile.signalVolume, barIndex: 0, isHook: false
            )
            : nil
        let writeBPM = barClock.map { Int($0.bpm.rounded()) } ?? noteBPM
        let baseContext = makeContext(
            intent: intent, beat: beatFingerprint, style: styleProfile, directedParams: directedParams,
            luxury: luxuryLayer, barIndex: 0, existingBars: [], signalAxes: signalAxes, themeContext: themeContext,
            bpm: writeBPM, musicalKey: noteKey, musicalScale: noteScale,
            syllableMin: syllableMin, syllableMax: syllableMax, barClock: barClock,
            artistBrainPrompt: artistBrainPrompt, artistBrainChunks: artistBrainChunks
        )

        // Step 1 — plan the verse (1 call).
        let plan: VersePlan
        do {
            plan = try await llmService.generateVersePlan(context: baseContext)
        } catch {
            #if DEBUG
            print("⚠️ [ModelG v4] generateVersePlan failed: \(error) — using empty plan")
            #endif
            plan = .empty
        }

        // Inspiration (0 = novel … 1 = max "inspired"/grounded) from the Originality slider.
        // Drives how hard v4 leans on the vault: more exemplars + stronger prompt grounding.
        let inspiration = 1.0 - ModelGEnvironment.originalityBias
        let kExemplars = 4 + Int((inspiration * 8).rounded())   // 4 (novel) … 12 (max inspired)

        // Copy-flow: last 4 draft bars → pasted 4 → corpus syllable map (no Gunna nouns in the prompt).
        var flowExemplar: FlowExemplar? = Self.resolveFlowExemplar(
            draft: input, params: directedParams, bpm: writeBPM
        )

        // Step 1b — corpus retrieval (RAG): tone → corpus themes, topics → tags, draft → keywords.
        var v4Exemplars: [String] = []
        var v4ExemplarNorms: [String] = []
        var v4Vocab: [String] = []
        if usingArtistBrain {
            v4Exemplars = ModelYouWriterPolicy.referenceSeat(artistChunks: artistBrainChunks)
            v4ExemplarNorms = v4Exemplars.map { $0.lowercased() }
            v4Vocab = []
        }
        if !usingArtistBrain {
        do {
            let corpusStore = try ModelGCorpusStore()
            ModelGEmbeddingIndex.shared.buildIfNeeded(bars: corpusStore.corpus.bars)
            // emotionalTone is a "|"-separated list whose values ARE the corpus theme vocab
            // (confident/luxurious/…) — so this reliably matches, unlike the topic `themeName`.
            let tones = (themeContext?.emotionalTone ?? "")
                .split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            let topics = ((themeContext?.themeName ?? "").split(separator: " ").map(String.init)
                + (themeContext?.jargonPalette ?? [])
                + (directedParams?.selectedTopics ?? [])
                + (directedParams?.worldBuildingWords ?? []))
                .filter { $0.count >= 3 }
            let retriever = ModelGCorpusRetriever(store: corpusStore, embeddingIndex: ModelGEmbeddingIndex.shared)
            let retrieved = retriever.retrieve(
                tones: tones, topics: topics, draft: input,
                brands: directedParams?.worldBuildingWords ?? [], k: kExemplars)
            v4Exemplars = retrieved.exemplars.map(\.text)
            v4ExemplarNorms = retrieved.exemplars.map(\.norm)
            v4Vocab = retrieved.vocab
            if flowExemplar == nil {
                let clockBPM = barClock.map { Int($0.bpm.rounded()) } ?? bpm
                let target = Self.effectiveTarget(min: syllableMin, max: syllableMax, bpm: clockBPM) ?? defaultSyllableTarget
                flowExemplar = retriever.retrieveFlow(targetSyllables: target, k: 1).first
            }
        } catch {
            #if DEBUG
            print("⚠️ [ModelG v4] corpus load/retrieve failed: \(error) — proceeding with empty exemplars (== v3 prompt)")
            #endif
        }
        } else if flowExemplar == nil {
            // House corpus as a CLOCK only — syllable map, no Gunna nouns in the You seat.
            do {
                let corpusStore = try ModelGCorpusStore()
                let retriever = ModelGCorpusRetriever(store: corpusStore)
                let clockBPM = barClock.map { Int($0.bpm.rounded()) } ?? bpm
                let target = Self.effectiveTarget(min: syllableMin, max: syllableMax, bpm: clockBPM) ?? defaultSyllableTarget
                flowExemplar = retriever.retrieveFlow(targetSyllables: target, k: 1).first
            } catch {
                #if DEBUG
                print("⚠️ [ModelYou] house flow map failed: \(error) — continuing without it")
                #endif
            }
        }
        #if DEBUG
        let flowDesc = flowExemplar.map { "\($0.source.rawValue):\($0.syllableMap.map(String.init).joined(separator: "/"))" } ?? "none"
        print("🔎 [ModelG v4] inspiration=\(String(format: "%.2f", inspiration)) k=\(kExemplars) exemplars=\(v4Exemplars.count) vocab=\(v4Vocab.count) flow=\(flowDesc) embeddingsReady=\(ModelGEmbeddingIndex.shared.isReady)")
        #endif

        // Pre-embed the exemplars once for the SEMANTIC signature score (cosine). Empty when the
        // on-device index isn't warm yet → scoring falls back to Jaccard word overlap per bar.
        let v4ExemplarVectors: [[Float]] = ModelGEmbeddingIndex.shared.isReady
            ? v4Exemplars.compactMap { ModelGEmbeddingIndex.shared.embed($0) } : []

        // Step 2 — generate full-verse candidates (best-of-N) and pick the best.
        // Effort = how many candidates; Creativity = their temperature spread; Quality bar =
        // run one extra round if the best scores below target. Defaults reproduce legacy behavior
        // (effort 2, creativity 0.5 → temps [0.7, 0.95], quality bar 0 = no retry).
        let nCandidates = ModelGEnvironment.effortCandidates
        let temps = Self.candidateTemps(count: nCandidates, creativity: ModelGEnvironment.creativity)
        let qualityTarget = ModelGEnvironment.qualityBar * 95.0

        func generateRound(useCorpus: Bool) async -> [(hook: String, bars: [String])] {
            await withTaskGroup(of: (hook: String, bars: [String])?.self) { group in
                for i in 0..<nCandidates {
                    let temp = temps[i % temps.count]
                    group.addTask {
                        do {
                            return try await self.llmService.generateFullVerse(
                                plan: plan, arcShape: arcShape, context: baseContext, temperature: temp,
                                corpusExemplars: useCorpus ? v4Exemplars : [],
                                corpusVocab: useCorpus ? v4Vocab : [],
                                inspiration: inspiration,
                                flowExemplar: flowExemplar
                            )
                        } catch {
                            #if DEBUG
                            print("⚠️ [ModelG v4] generateFullVerse candidate (temp \(temp), corpus=\(useCorpus)) failed: \(error)")
                            #endif
                            return nil
                        }
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
        // Wrap overlay is a close-score tie-break only — never discards a witty short line.
        var best: (hook: String, bars: [String])?
        var bestScore = -1.0
        var bestWrapTie = -1.0
        let minBars = min(4, targetBarCount)
        let grammar = directedParams?.punchGrammar ?? .couplet
        func consider(_ verses: [(hook: String, bars: [String])]) {
            for verse in verses where verse.bars.count >= minBars {
                let usable = Array(verse.bars.prefix(targetBarCount))
                var total = 0.0
                for (i, bar) in usable.enumerated() {
                    let ctx = makeContext(
                        intent: intent, beat: beatFingerprint, style: styleProfile, directedParams: directedParams,
                        luxury: luxuryLayer, barIndex: i, existingBars: Array(usable.prefix(i)),
                        signalAxes: signalAxes, themeContext: themeContext,
                        bpm: noteBPM, musicalKey: noteKey, musicalScale: noteScale,
                        syllableMin: syllableMin, syllableMax: syllableMax, barClock: barClock
                    )
                    let base = scoringEngine.evaluateBar(bar, context: ctx)
                    let v4 = scoringEngine.v4Breakdown(base: base, text: bar, context: ctx,
                                                       exemplarNorms: v4ExemplarNorms,
                                                       syllables: SyllableEngine.lineSyllableCount(bar),
                                                       inspiration: inspiration,
                                                       exemplarVectors: v4ExemplarVectors,
                                                       candidateVector: v4ExemplarVectors.isEmpty ? nil : ModelGEmbeddingIndex.shared.embed(bar))
                    total += v4.v4Total
                }
                let score = usable.isEmpty ? 0 : total / Double(usable.count)
                let overlay = WrapOverlayEngine.evaluate(bars: usable, grammar: grammar)
                let wrapTie = overlay.tieBreak
                let takesLead: Bool
                if best == nil {
                    takesLead = true
                } else if abs(score - bestScore) <= 1.5 {
                    takesLead = wrapTie > bestWrapTie || (wrapTie == bestWrapTie && score > bestScore)
                } else {
                    takesLead = score > bestScore
                }
                if takesLead {
                    bestScore = score
                    bestWrapTie = wrapTie
                    best = verse
                }
            }
        }

        consider(await generateRound(useCorpus: true))
        // Quality bar: one extra round if the best is below target (off when the bar == 0).
        if qualityTarget > 0 && bestScore < qualityTarget {
            consider(await generateRound(useCorpus: true))
        }
        // ROBUSTNESS (ship-blocker fix): if corpus-injected generation produced no usable verse —
        // e.g. a provider safety-blocked the explicit reference lyrics, or returned non-JSON — retry
        // WITHOUT the corpus, which is the exact v3 prompt that already works. This guarantees v4 is
        // never worse than v3 and never silently falls through to the legacy path's "API request
        // failed" toast for any corpus-specific reason. (A genuine outage still fails, like v3 would.)
        if best == nil {
            #if DEBUG
            print("⚠️ [ModelG v4] no usable candidate WITH corpus — retrying WITHOUT corpus (v3-equivalent prompt)")
            #endif
            consider(await generateRound(useCorpus: false))
        }

        #if DEBUG
        print("🔎 [ModelG v4] bestScore=\(bestScore) chosen=\(best != nil)")
        #endif
        guard let chosen = best else {
            #if DEBUG
            print("❌ [ModelG v4] no usable candidate even without corpus — genuine provider/network failure (v3 would fail too)")
            #endif
            return GeneratedRecord(
                hook: "", bars: ["Fallback bar — continue the flow."],
                modelGMomentBarIndices: [], averageBarScore: 0
            )
        }

        let bars = Array(chosen.bars.prefix(targetBarCount))
        // Do not pad dummy captions. A 4-bar cycle is a valid wrap; Phase 1 still *asks* for 16.
        var averageBarScore = bestScore
        if averageBarScore < verseAverageThreshold {
            averageBarScore = max(averageBarScore, verseAverageThreshold - 1)
        }
        let wrapOverlay = WrapOverlayEngine.evaluate(bars: bars, grammar: grammar)
        #if DEBUG
        print("🎧 [ModelG wrap] \(wrapOverlay.summary) tie=\(String(format: "%.2f", wrapOverlay.tieBreak))")
        #endif

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
            hook: chosen.hook, bars: bars, modelGMomentBarIndices: [], averageBarScore: averageBarScore,
            wrapNote: wrapOverlay.summary, wrapTieBreak: wrapOverlay.tieBreak
        )
    }

    /// Build a GenerationContext with the v4 verse-level defaults.
    private func makeContext(
        intent: GenerationIntent, beat: BeatFingerprint?, style: StyleProfile,
        directedParams: DirectedGenerationParams?, luxury: LuxuryLayer?, barIndex: Int,
        existingBars: [String], signalAxes: SignalAxes?, themeContext: ThemeContext?,
        bpm: Int? = nil, musicalKey: String? = nil, musicalScale: String? = nil,
        syllableMin: Int? = nil, syllableMax: Int? = nil,
        barClock: BarClock? = nil,
        artistBrainPrompt: String? = nil,
        artistBrainChunks: [String] = []
    ) -> GenerationContext {
        let bpmForSyllables = barClock.map { Int($0.bpm.rounded()) } ?? bpm
        return GenerationContext(
            intent: intent, beatFingerprint: beat, styleProfile: style, directedParams: directedParams,
            luxuryLayer: luxury, userTasteVector: UserTasteStore.shared.currentVector(),
            syllableTarget: Self.effectiveTarget(min: syllableMin, max: syllableMax, bpm: bpmForSyllables) ?? defaultSyllableTarget,
            barIndex: barIndex, isHook: false, existingBars: existingBars, riskIndex: riskManager.riskIndex,
            flowDNAFeatures: nil, rhythmMap: nil, perBarSyllableTargets: nil,
            signalAxes: signalAxes, themeContext: themeContext,
            musicalBPM: bpm, musicalKey: musicalKey, musicalScale: musicalScale,
            syllableMin: syllableMin, syllableMax: syllableMax,
            barClock: barClock,
            artistBrainPrompt: artistBrainPrompt,
            artistBrainChunks: artistBrainChunks
        )
    }

    static func resolveFlowExemplar(draft: String, params: DirectedGenerationParams?, bpm: Int?) -> FlowExemplar? {
        if params?.copyLastFourRhythm != false, let fromDraft = FlowExemplar.fromDraft(draft, bpm: bpm) {
            return fromDraft
        }
        let pasted = params?.pastedFlowText ?? ""
        if !pasted.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lines = pasted.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            if let fromPaste = FlowExemplar.fromLines(lines, source: .pasted, bpm: bpm) {
                return fromPaste
            }
        }
        return nil
    }

    private func nonempty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    /// Tempo → syllables/bar. Pass already-folded wrap BPM when Gunna wrap is on.
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
