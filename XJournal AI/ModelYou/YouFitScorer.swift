import Foundation

struct YouFitScore: Equatable {
    var total: Double
    var wrap: Double
    var endings: Double
    var lexicon: Double
    var punch: Double
    var housePenalty: Double
    var neverUseHits: Int
    var unconfirmedGriefHits: Int
    var punchDemoted: Bool

    var passesFloor: Bool {
        total >= YouFitScorer.floor && neverUseHits == 0 && unconfirmedGriefHits == 0 && !punchDemoted
    }
}

/// Phase 5: a 90 G / 20 You is a fail. Empty brain is honest, not a house-wrap disguise.
enum YouFitScorer {
    static let floor: Double = 55
    static let gCraftFloor: Double = 70

    static func score(verse: String, brain: ArtistBrain, graph: ArtistBrainGraph? = nil) -> YouFitScore {
        let graph = graph ?? ArtistBrainGraph.rebuild(from: brain)
        let lines = verse
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let neverUseHits = countHits(in: verse, terms: brain.neverUse)
        let griefHits = countHits(in: verse, terms: pendingTerms(brain))
        let houseHits = houseNouns(in: verse, brain: brain)
        let housePenalty = min(100, Double(houseHits) * 25)

        let thin = brain.lyricBars.isEmpty
        let wrap = thin ? 70 : wrapScore(lines: lines, bars: brain.lyricBars)
        let endings = thin ? 70 : endingScore(lines: lines, bars: brain.lyricBars)
        let lexicon = thin ? 70 : lexiconScore(verse: verse, brain: brain)
        let punchPair = punchScore(lines: lines, graph: graph)
        let punch = thin ? 70 : punchPair.score
        let punchDemoted = !thin && punchPair.demoted

        var total = 0.25 * wrap + 0.20 * endings + 0.25 * lexicon + 0.15 * punch + 0.15 * (100 - housePenalty)
        if neverUseHits > 0 || griefHits > 0 || punchDemoted {
            total = 0
        }
        return YouFitScore(
            total: min(100, max(0, total)),
            wrap: wrap,
            endings: endings,
            lexicon: lexicon,
            punch: punch,
            housePenalty: housePenalty,
            neverUseHits: neverUseHits,
            unconfirmedGriefHits: griefHits,
            punchDemoted: punchDemoted
        )
    }

    static func reject(_ score: YouFitScore) -> RejectionReason? {
        if score.neverUseHits > 0 { return .neverUseHit }
        if score.unconfirmedGriefHits > 0 { return .unconfirmedGrief }
        if score.punchDemoted { return .punchDemoted }
        if score.total < floor { return .youFitTooLow }
        return nil
    }

    static func passesGCraft(_ averageBarScore: Double, brain: ArtistBrain) -> Bool {
        if brain.lyricBars.isEmpty { return true }
        return averageBarScore >= gCraftFloor
    }

    static func pick(
        candidates: [(text: String, gScore: Double)],
        brain: ArtistBrain
    ) -> (text: String, gScore: Double, you: YouFitScore)? {
        let graph = ArtistBrainGraph.rebuild(from: brain)
        var best: (text: String, gScore: Double, you: YouFitScore)?
        for candidate in candidates {
            guard passesGCraft(candidate.gScore, brain: brain) else { continue }
            let you = score(verse: candidate.text, brain: brain, graph: graph)
            guard you.passesFloor else { continue }
            if let current = best {
                let currentBlend = current.gScore + current.you.total
                let nextBlend = candidate.gScore + you.total
                if nextBlend > currentBlend {
                    best = (candidate.text, candidate.gScore, you)
                }
            } else {
                best = (candidate.text, candidate.gScore, you)
            }
        }
        return best
    }

    private static func wrapScore(lines: [String], bars: [ArtistBrainChunk]) -> Double {
        guard !lines.isEmpty, !bars.isEmpty else { return 70 }
        let catalog = Set(bars.map(\.syllableCount))
        let hits = lines.filter { line in
            let n = LineSyllableCounter.syllableCount(forLine: line)
            return catalog.contains(where: { abs($0 - n) <= 2 })
        }
        return 100 * Double(hits.count) / Double(lines.count)
    }

    private static func endingScore(lines: [String], bars: [ArtistBrainChunk]) -> Double {
        guard !lines.isEmpty, !bars.isEmpty else { return 70 }
        let catalog = Set(bars.compactMap { ArtistBrainRAG.endWord(of: $0.text) })
        guard !catalog.isEmpty else { return 70 }
        let hits = lines.filter { line in
            guard let end = ArtistBrainRAG.endWord(of: line) else { return false }
            return catalog.contains(end)
        }
        return 100 * Double(hits.count) / Double(lines.count)
    }

    private static func lexiconScore(verse: String, brain: ArtistBrain) -> Double {
        let theirs = theirsTokens(brain)
        let ours = RemindsMeOfScorer.contentTokens(verse)
        guard !theirs.isEmpty, !ours.isEmpty else { return 70 }
        let overlap = ours.intersection(theirs)
        return 100 * Double(overlap.count) / Double(ours.union(theirs).count)
    }

    private static func punchScore(lines: [String], graph: ArtistBrainGraph) -> (score: Double, demoted: Bool) {
        let punches = Set(graph.punchLabels)
        guard !punches.isEmpty else { return (70, false) }
        let verseTokens = Set(lines.flatMap { RemindsMeOfScorer.contentTokens($0) })
        let used = punches.intersection(verseTokens)
        guard !used.isEmpty else { return (70, false) }
        let endWords = Set(lines.compactMap { ArtistBrainRAG.endWord(of: $0) })
        let landed = used.intersection(endWords)
        if landed.isEmpty {
            return (0, true)
        }
        return (100, false)
    }

    private static func theirsTokens(_ brain: ArtistBrain) -> Set<String> {
        var tokens = Set<String>()
        for bar in brain.lyricBars {
            tokens.formUnion(RemindsMeOfScorer.contentTokens(bar.text))
        }
        for card in brain.confirmedCards where card.status == .kept || card.status == .edited {
            tokens.formUnion(RemindsMeOfScorer.contentTokens("\(card.title) \(card.body)"))
        }
        return tokens
    }

    private static func houseNouns(in verse: String, brain: ArtistBrain) -> Int {
        let theirs = theirsTokens(brain)
        let lower = verse.lowercased()
        let nouns = ["gunna", "wunna", "young thug", "thugger", "lil baby", "roley", "atlanta"]
        return nouns.filter { noun in
            lower.contains(noun) && !theirs.contains(noun)
        }.count
    }

    private static func pendingTerms(_ brain: ArtistBrain) -> [String] {
        brain.pendingCards.flatMap { card -> [String] in
            RemindsMeOfScorer.contentTokens("\(card.title) \(card.body)").sorted()
        }
    }

    private static func countHits(in verse: String, terms: [String]) -> Int {
        let lower = verse.lowercased()
        let tokens = RemindsMeOfScorer.contentTokens(verse)
        return terms.filter { term in
            let t = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard t.count >= 2 else { return false }
            return tokens.contains(t) || lower.contains(t)
        }.count
    }
}
