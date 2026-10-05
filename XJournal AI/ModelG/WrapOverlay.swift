//
//  WrapOverlay.swift
//  XJournal AI
//
//  Soft wrap signals for the suggestion card. Advisory + close-score tie-break.
//  Never a regenerate-until-pass veto.
//

import Foundation

nonisolated enum WrapRimeGrade: String, Equatable, Sendable {
    case none
    case identical
    case slant
    case nearPerfect
    case perfect

    var meetsNear: Bool {
        self == .nearPerfect || self == .perfect
    }
}

struct WrapVerseOverlay: Equatable {
    var punchWindowHits: Int
    var punchWindowTotal: Int
    var setupPunchShares: Int
    var setupPunchTotal: Int
    var rimeAtLeastNear: Int
    var rimeTotal: Int
    var identicalEchoes: Int
    var pocketRepeatHits: Int
    var pocketRepeatTotal: Int
    var conceptCarry: Bool
    var tieBreak: Double
    var summary: String
}

enum WrapOverlayEngine {
    private static let stop: Set<String> = [
        "the", "a", "an", "and", "or", "to", "of", "in", "on", "my", "i", "im", "i'm",
        "you", "your", "it", "is", "was", "for", "with", "that", "this", "me", "we",
        "they", "just", "like", "got", "get", "ain't", "aint", "yeah", "uh", "oh"
    ]

    static func evaluate(bars: [String], grammar: PunchGrammar = .couplet) -> WrapVerseOverlay {
        let lines = bars.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let n = lines.count
        var punchHits = 0
        var punchTotal = 0
        for line in lines {
            punchTotal += 1
            if lastStressInPunchWindow(line) { punchHits += 1 }
        }

        let pairs = punchPairs(count: n, grammar: grammar)
        var shares = 0
        var rimeNear = 0
        var identical = 0
        for (a, b) in pairs {
            if sharesLemmaOrRime(setup: lines[a], punch: lines[b]) { shares += 1 }
            let grade = rimeGrade(lastWord(lines[a]), lastWord(lines[b]))
            if grade.meetsNear { rimeNear += 1 }
            if grade == .identical { identical += 1 }
        }

        var pocketHits = 0
        var pocketTotal = 0
        if n >= 3 {
            for i in 2..<n {
                pocketTotal += 1
                let sa = SyllableEngine.lineSyllableCount(lines[i])
                let sb = SyllableEngine.lineSyllableCount(lines[i - 2])
                if abs(sa - sb) <= 2 { pocketHits += 1 }
            }
        }

        let concept = conceptCarried(lines: lines)

        let punchFrac = fraction(punchHits, punchTotal)
        let shareFrac = fraction(shares, max(pairs.count, 1))
        let rimeFrac = fraction(rimeNear, max(pairs.count, 1))
        let pocketFrac = fraction(pocketHits, max(pocketTotal, 1))
        let identicalPenalty = min(0.15, Double(identical) * 0.05)
        let tie = min(1, max(0,
            punchFrac * 0.30 + shareFrac * 0.25 + rimeFrac * 0.20 + pocketFrac * 0.15
            + (concept ? 0.10 : 0) - identicalPenalty
        ))

        let conceptBit = concept ? "yes" : "no"
        let summary = "Wrap: punch \(punchHits)/\(punchTotal) · setup↔punch \(shares)/\(pairs.count) · rime near+ \(rimeNear)/\(pairs.count) · pocket \(pocketHits)/\(pocketTotal) · concept \(conceptBit)"

        return WrapVerseOverlay(
            punchWindowHits: punchHits,
            punchWindowTotal: punchTotal,
            setupPunchShares: shares,
            setupPunchTotal: pairs.count,
            rimeAtLeastNear: rimeNear,
            rimeTotal: pairs.count,
            identicalEchoes: identical,
            pocketRepeatHits: pocketHits,
            pocketRepeatTotal: pocketTotal,
            conceptCarry: concept,
            tieBreak: tie,
            summary: summary
        )
    }

    /// Last primary stress sits in the back half of the bar (beats 3–4 proxy).
    /// A one-word bar is the punch — Ohm's "special" — even if CMUDICT stresses the first syllable.
    static func lastStressInPunchWindow(_ line: String) -> Bool {
        let words = tokens(line)
        guard !words.isEmpty else { return false }
        if words.count == 1 { return true }
        var total = 0
        var lastPrimaryAt = 0
        for word in words {
            let (count, lastPrimaryOffset) = stressLayout(word)
            if count == 0 { continue }
            if let offset = lastPrimaryOffset {
                lastPrimaryAt = total + offset
            } else {
                lastPrimaryAt = total + count - 1
            }
            total += count
        }
        guard total > 0 else { return true }
        return Double(lastPrimaryAt) >= Double(total - 1) * 0.55
    }

    nonisolated static func rimeGrade(_ a: String, _ b: String) -> WrapRimeGrade {
        let wa = normalize(a)
        let wb = normalize(b)
        guard !wa.isEmpty, !wb.isEmpty else { return .none }
        if wa == wb { return .identical }
        if let pa = phonemes(wa), let pb = phonemes(wb) {
            switch RhymeFinder.rhymeTier(pa, pb) {
            case 3: return .perfect
            case 2: return .nearPerfect
            case 1: return .slant
            default: break
            }
        }
        let ta = String(wa.suffix(3))
        let tb = String(wb.suffix(3))
        if ta.count >= 2, ta == tb { return .nearPerfect }
        return .none
    }

    static func sharesLemmaOrRime(setup: String, punch: String) -> Bool {
        let grade = rimeGrade(lastWord(setup), lastWord(punch))
        if grade == .perfect || grade == .nearPerfect || grade == .slant { return true }
        let a = Set(contentLemmas(setup))
        let b = Set(contentLemmas(punch))
        return !a.isDisjoint(with: b)
    }

    static func lastWord(_ line: String) -> String {
        tokens(line).last ?? ""
    }

    // MARK: - Private

    private static func punchPairs(count: Int, grammar: PunchGrammar) -> [(Int, Int)] {
        guard count >= 2 else { return [] }
        switch grammar {
        case .couplet:
            var pairs: [(Int, Int)] = []
            var i = 0
            while i + 1 < count {
                pairs.append((i, i + 1))
                i += 2
            }
            return pairs
        case .threePlusOne:
            var pairs: [(Int, Int)] = []
            var i = 0
            while i + 3 < count {
                pairs.append((i + 2, i + 3))
                i += 4
            }
            if pairs.isEmpty, count >= 2 { pairs.append((count - 2, count - 1)) }
            return pairs
        case .closedLoop4:
            var pairs: [(Int, Int)] = []
            var i = 0
            while i + 3 < count {
                pairs.append((i, i + 1))
                pairs.append((i + 1, i + 2))
                pairs.append((i + 2, i + 3))
                i += 4
            }
            if pairs.isEmpty, count >= 2 { pairs.append((0, 1)) }
            return pairs
        }
    }

    private static func conceptCarried(lines: [String]) -> Bool {
        guard lines.count >= 2 else { return false }
        let groups: [[String]]
        if lines.count >= 4 {
            var chunks: [[String]] = []
            var i = 0
            while i + 3 < lines.count {
                chunks.append(Array(lines[i..<(i + 4)]))
                i += 4
            }
            groups = chunks.isEmpty ? [lines] : chunks
        } else {
            groups = [lines]
        }
        for group in groups {
            var freq: [String: Int] = [:]
            for line in group {
                for lemma in Set(contentLemmas(line)) {
                    freq[lemma, default: 0] += 1
                }
            }
            if freq.values.contains(where: { $0 >= 2 }) { return true }
        }
        return false
    }

    private static func tokens(_ line: String) -> [String] {
        line.split { !$0.isLetter && $0 != "'" }
            .map { $0.lowercased() }
            .filter { $0.count > 1 }
    }

    private static func contentLemmas(_ line: String) -> [String] {
        tokens(line)
            .filter { !stop.contains($0) }
            .map { String($0.prefix(5)) }
    }

    nonisolated private static func normalize(_ word: String) -> String {
        word.trimmingCharacters(in: .punctuationCharacters).lowercased()
    }

    nonisolated private static func phonemes(_ word: String) -> [String]? {
        RapSlangPhonemes.phonemes(for: word) ?? getGlobalCMUDICTStore()[word]
    }

    /// Syllable count + index of last primary stress (1 or 2) within the word.
    private static func stressLayout(_ word: String) -> (count: Int, lastPrimary: Int?) {
        if let p = phonemes(word) {
            let nuclei = p.enumerated().compactMap { idx, ph -> (Int, Character)? in
                guard let d = ph.last, d.isNumber else { return nil }
                return (idx, d)
            }
            let count = max(nuclei.count, 1)
            let lastPrimary = nuclei.lastIndex(where: { $0.1 == "1" || $0.1 == "2" }).map { $0 }
            return (count, lastPrimary)
        }
        let count = max(SyllableEngine.syllableCount(word: word), 1)
        return (count, count - 1)
    }

    private static func fraction(_ hits: Int, _ total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(hits) / Double(total)
    }
}
