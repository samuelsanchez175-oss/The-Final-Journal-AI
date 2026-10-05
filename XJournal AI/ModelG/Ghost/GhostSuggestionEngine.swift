import Foundation

// MARK: - GhostHint

nonisolated struct GhostPunchChip: Equatable, Sendable, Identifiable {
    var id: String { text.lowercased() }
    var text: String
    var syllables: Int
    var targetWrap: Int
    var artist: String?
    var song: String?
    var preferred: Bool
    /// Internal-to-end chain: setup landing is hit inside the punch and at the end.
    var chained: Bool = false

    enum WrapFit: Equatable {
        case exact, near, miss
        static func of(punch: Int, target: Int) -> WrapFit {
            let d = abs(punch - max(target, 1))
            if d == 0 { return .exact }
            if d <= 3 { return .near }
            return .miss
        }
    }

    var wrapFit: WrapFit { WrapFit.of(punch: syllables, target: targetWrap) }

    var sourceLabel: String? {
        let a = artist?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let s = song?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if a.isEmpty, s.isEmpty { return nil }
        if s.isEmpty { return a }
        if a.isEmpty { return s }
        return "\(a) · \(s)"
    }
}

struct GhostHint: Equatable {
    let candidates: [String]
    let punches: [GhostPunchChip]
    let tail: String?
    let targetWrap: Int?

    init(candidates: [String], punches: [GhostPunchChip] = [], tail: String?, targetWrap: Int? = nil) {
        self.candidates = candidates
        self.punches = punches
        self.tail = tail
        self.targetWrap = targetWrap
    }

    var display: String { "↳ rhymes: " + candidates.prefix(3).joined(separator: " · ") }
}

// MARK: - LyricClause

/// A pause used as a breath on one newline: setup, then punch.
/// Lists, trailing cuts, and tiny clauses are not caesuras.
/// Newline is still the only bar break.
nonisolated struct LyricClause: Equatable, Sendable {
    var setup: String
    var punch: String
    var setupEnd: String
    var punchEnd: String
    var setupSyllables: Int
    var punchSyllables: Int
    /// Slant or stronger between the two landings.
    var rhymesAcross: Bool
    /// Slant between tokens touching the pause (not only the two end words).
    var nearRhymes: Bool
    /// Punch re-reads a content word from the setup.
    var pictureReRead: Bool

    var pocketCaption: String { "\(setupSyllables) + \(punchSyllables)" }

    enum Wash: Equatable, Sendable {
        case setup
        case punch
    }

    /// UTF-16 ranges to paint Ohm green/red on the writing surface. One newline stays one bar.
    static func washes(in text: String) -> [(utf16: NSRange, wash: Wash)] {
        var out: [(NSRange, Wash)] = []
        var location = 0
        let parts = text.split(separator: "\n", omittingEmptySubsequences: false)
        for (i, raw) in parts.enumerated() {
            let line = String(raw)
            let lineLen = (line as NSString).length
            if let clause = split(line) {
                let ns = line as NSString
                let setup = ns.range(of: clause.setup)
                let punch = ns.range(of: clause.punch, options: .backwards)
                if setup.location != NSNotFound {
                    out.append((NSRange(location: location + setup.location, length: setup.length), .setup))
                }
                if punch.location != NSNotFound {
                    out.append((NSRange(location: location + punch.location, length: punch.length), .punch))
                }
            }
            location += lineLen + (i < parts.count - 1 ? 1 : 0)
        }
        return out
    }

    /// Logical caesura on a single bar, or nil.
    static func split(_ line: String) -> LyricClause? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        // A comma still wins. With no breath mark, an inner rhyme is the caesura
        // even when the halves are uneven (world | … Bombay is 5 + 7, not 6 + 6).
        guard let cut = lastBreathCut(in: trimmed) ?? innerRhymeCut(in: trimmed) else { return nil }
        let setup = String(trimmed[..<cut.lowerBound]).trimmingCharacters(in: .whitespaces)
        let punch = String(trimmed[cut.upperBound...]).trimmingCharacters(in: .whitespaces)
        let setupToks = contentTokens(setup)
        let punchToks = contentTokens(punch)
        guard setupToks.count >= 2, punchToks.count >= 2 else { return nil }
        guard let setupEnd = GhostSuggestionEngine.endWord(of: setup),
              let punchEnd = GhostSuggestionEngine.endWord(of: punch),
              !setupEnd.isEmpty, !punchEnd.isEmpty
        else { return nil }
        let nearSetup = Array(setupToks.suffix(2))
        let nearPunch = Array(punchToks.prefix(2))
        return LyricClause(
            setup: setup,
            punch: punch,
            setupEnd: setupEnd,
            punchEnd: punchEnd,
            setupSyllables: LineSyllableCounter.syllableCount(forLine: setup),
            punchSyllables: LineSyllableCounter.syllableCount(forLine: punch),
            rhymesAcross: landsRhyme(setupEnd, punchEnd),
            nearRhymes: tokensRhyme(nearSetup, nearPunch),
            pictureReRead: sharesPicture(setupToks, punchToks)
        )
    }

    /// Cadence Ghost / wrap-swap target: punch half when the pause is a real breath.
    static func cadenceLine(for line: String) -> String {
        split(line)?.punch ?? line
    }

    static func contentTokens(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 2 }
    }

    static func landsRhyme(_ a: String, _ b: String) -> Bool {
        let grade = WrapOverlayEngine.rimeGrade(a, b)
        if grade == .perfect || grade == .nearPerfect || grade == .slant { return true }
        let ka = BarHitsCatalogStore.phoneticClass(for: a)
        let kb = BarHitsCatalogStore.phoneticClass(for: b)
        return !ka.isEmpty && ka == kb
    }

    /// Breath boost only when the writer used a technique at the pause.
    /// A comma by itself is not a match. Need picture re-read or slant at the cut.
    static func styleScore(candidate: String, query: LyricClause?) -> Int {
        guard let query else { return 0 }
        guard let cand = split(candidate) else { return 0 }
        var n = 0
        if query.pictureReRead, cand.pictureReRead { n += 3 }
        if query.nearRhymes, cand.nearRhymes { n += 3 }
        if query.rhymesAcross, cand.rhymesAcross { n += 2 }
        return n
    }

    /// Pocket of each half. Setup ±1 and punch ±1 is a cadence match, not a wrap replacement.
    static func cadenceScore(candidate: String, query: LyricClause?) -> Int {
        guard let query else { return 0 }
        guard let cand = split(candidate) else { return 0 }
        var n = 0
        if abs(cand.setupSyllables - query.setupSyllables) <= 1 { n += 1 }
        if abs(cand.punchSyllables - query.punchSyllables) <= 1 { n += 2 }
        return n
    }

    /// Earlier word of an inner-rhyme pair ends the setup. The echo can sit inside the punch.
    /// "Money run the world took my girl out to Bombay" breaks after world, not at syllable 6.
    private static func innerRhymeCut(in line: String) -> Range<String.Index>? {
        let words = barWords(in: line)
        guard words.count >= 4 else { return nil }
        var best: (end: String.Index, balance: Int)?
        for index in words.indices {
            let setupWords = contentTokens(String(line[..<words[index].upperBound]))
            let rest = line[words[index].upperBound...]
            let punchWords = contentTokens(String(rest))
            guard setupWords.count >= 2, punchWords.count >= 2 else { continue }
            let landing = words[index].text
            let echoed = words[(index + 1)...].contains { later in
                later.text != landing && strictRhyme(landing, later.text)
            }
            guard echoed else { continue }
            let setupN = LineSyllableCounter.syllableCount(forLine: String(line[..<words[index].upperBound]))
            let punchN = LineSyllableCounter.syllableCount(forLine: String(rest))
            guard setupN > 0, punchN > 0 else { continue }
            let balance = abs(setupN - punchN)
            if best == nil || balance < best!.balance {
                var gap = words[index].upperBound
                while gap < line.endIndex, line[gap].isWhitespace {
                    gap = line.index(after: gap)
                }
                guard gap > words[index].upperBound else { continue }
                best = (gap, balance)
            }
        }
        guard let best else { return nil }
        let setupEnd = line[..<best.end].lastIndex(where: { !$0.isWhitespace }) ?? line.startIndex
        let cutStart = line.index(after: setupEnd)
        guard cutStart < best.end else { return nil }
        return cutStart..<best.end
    }

    private struct BarWord {
        var text: String
        var upperBound: String.Index
    }

    private static func barWords(in line: String) -> [BarWord] {
        var words: [BarWord] = []
        var i = line.startIndex
        while i < line.endIndex {
            let ch = line[i]
            if ch.isLetter || ch.isNumber || ch == "'" || ch == "\u{2019}" {
                let start = i
                i = line.index(after: i)
                while i < line.endIndex {
                    let c = line[i]
                    if c.isLetter || c.isNumber || c == "'" || c == "\u{2019}" {
                        i = line.index(after: i)
                    } else {
                        break
                    }
                }
                words.append(BarWord(text: String(line[start..<i]).lowercased(), upperBound: i))
            } else {
                i = line.index(after: i)
            }
        }
        return words
    }

    /// Perfect or near only. Same-vowel assonance is not a caesura.
    private static func strictRhyme(_ a: String, _ b: String) -> Bool {
        guard let pa = RhymeHighlighterEngine.phonemes(for: a),
              let pb = RhymeHighlighterEngine.phonemes(for: b),
              let sa = RhymeHighlighterEngine.extractSignature(from: pa),
              let sb = RhymeHighlighterEngine.extractSignature(from: pb),
              let score = RhymeHighlighterEngine.rhymeScore(sa, sb)
        else { return false }
        return score == .perfect || score == .near
    }

    /// Rightmost comma / ". " / em-dash that can still be setup-then-punch.
    private static func lastBreathCut(in line: String) -> Range<String.Index>? {
        var hits: [(index: String.Index, length: Int)] = []
        var i = line.startIndex
        while i < line.endIndex {
            let ch = line[i]
            if ch == "," {
                hits.append((i, 1))
            } else if ch == "." {
                let next = line.index(after: i)
                if next < line.endIndex, line[next] == " " {
                    hits.append((i, 2))
                }
            } else if ch == "—" || ch == "–" {
                hits.append((i, 1))
            }
            i = line.index(after: i)
        }
        for hit in hits.reversed() {
            let end = line.index(hit.index, offsetBy: hit.length, limitedBy: line.endIndex) ?? line.endIndex
            let setup = String(line[..<hit.index]).trimmingCharacters(in: .whitespaces)
            let punch = String(line[end...]).trimmingCharacters(in: .whitespaces)
            let setupToks = contentTokens(setup)
            let punchToks = contentTokens(punch)
            guard setupToks.count >= 2, punchToks.count >= 2 else { continue }
            if line[hit.index] == ".", let last = setupToks.last, last.count <= 2 {
                continue
            }
            return hit.index..<end
        }
        return nil
    }

    private static let pictureStops: Set<String> = [
        "the", "a", "an", "and", "or", "to", "of", "in", "on", "my", "i", "im", "i'm",
        "you", "your", "it", "is", "was", "for", "with", "that", "this", "me", "we",
        "they", "just", "like", "got", "get", "yea", "yeah", "do", "own", "from",
        "been", "then", "but", "not", "ain", "aint"
    ]

    private static func tokensRhyme(_ a: [String], _ b: [String]) -> Bool {
        for x in a {
            for y in b where x != y && landsRhyme(x, y) { return true }
        }
        return false
    }

    private static func sharesPicture(_ setup: [String], _ punch: [String]) -> Bool {
        let a = Set(setup.filter { !pictureStops.contains($0) })
        let b = Set(punch.filter { !pictureStops.contains($0) })
        if !a.isDisjoint(with: b) { return true }
        for x in a {
            for y in b {
                if x.count >= 4, y.count >= 4, x.hasPrefix(String(y.prefix(4))) || y.hasPrefix(String(x.prefix(4))) {
                    return true
                }
            }
        }
        return false
    }
}

// MARK: - GhostSuggestionEngine

/// Free-tier rhyme-ending suggester.
/// Scans `getGlobalCMUDICTStore()` ([String:[String]] keyed by word) for words
/// whose stressed-vowel + coda match the target end-word, then ranks on-brand
/// candidates first via `ModelGCorpusRetriever`. Pure — no UI, no network.
struct GhostSuggestionEngine {
    let retriever: ModelGCorpusRetriever?

    // MARK: - Public API

    nonisolated static func endWord(of line: String) -> String? {
        line.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .last
    }

    /// True when a body edit just finished a line (Enter) or added an indent (Tab) — the moment to
    /// recompute rhymes. Counts newlines/tabs rather than checking a trailing "\n": predictive text
    /// routinely batches the newline with the next word ("…star\nI talk"), so the old suffix check
    /// missed most line completions and the rhymes went stale.
    static func didCompleteLineOrIndent(old: String, new: String) -> Bool {
        func count(_ s: String, _ c: Character) -> Int { s.reduce(0) { $1 == c ? $0 + 1 : $0 } }
        return count(new, "\n") > count(old, "\n") || count(new, "\t") > count(old, "\t")
    }

    /// Comma on the line being written — setup, breath, then a punch.
    static func didTakeBreath(old: String, new: String) -> Bool {
        func trailingComma(_ text: String) -> Bool {
            guard let line = lastNonEmptyLine(in: text) else { return false }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasSuffix(",") || trimmed.hasSuffix(", ")
        }
        return trailingComma(new) && !trailingComma(old)
    }

    /// Text before the last comma on the current line.
    static func breathSetup(in line: String) -> String? {
        guard let comma = line.lastIndex(of: ",") else { return nil }
        let setup = String(line[..<comma]).trimmingCharacters(in: .whitespaces)
        return setup.isEmpty ? nil : setup
    }

    /// Setup for Cadence Ghost punches: comma breath, finished couplet, or Enter after a bar.
    static func cadencePunchSetup(in text: String, completed: Bool) -> String? {
        let current = lastNonEmptyLine(in: text)
        if let current {
            if let clause = LyricClause.split(current) { return clause.setup }
            if let setup = breathSetup(in: current) { return setup }
        }
        if completed, let finished = justCompletedLine(in: text), isNewlineSetup(finished) {
            return finished.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let current, (text.hasSuffix("\n") || text.hasSuffix("\n ")), isNewlineSetup(current) {
            return current.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    /// True while the writer is still filling the punch for `heldSetup` (empty next line, comma punch, or the next bar).
    static func stillPunching(in text: String, heldSetup: String) -> Bool {
        let held = CadenceGhostCache.normalize(heldSetup)
        guard !held.isEmpty else { return false }
        if let current = lastNonEmptyLine(in: text) {
            if CadenceGhostCache.normalize(current) == held { return true }
            if let clause = LyricClause.split(current), CadenceGhostCache.normalize(clause.setup) == held { return true }
            if let breath = breathSetup(in: current), CadenceGhostCache.normalize(breath) == held { return true }
        }
        if let previous = previousNonEmptyLine(in: text), CadenceGhostCache.normalize(previous) == held {
            return true
        }
        return false
    }

    static func previousNonEmptyLine(in text: String) -> String? {
        let segs = text.components(separatedBy: "\n")
        guard segs.count >= 2 else { return nil }
        return segs.dropLast().reversed().first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    static func isNewlineSetup(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.split(whereSeparator: \.isWhitespace).count >= 3 else { return false }
        if LyricClause.split(trimmed) != nil { return false }
        if breathSetup(in: trimmed) != nil { return false }
        return true
    }

    /// Full-bar gutter the verse is living at, from finished lines above the current setup.
    /// Nil when there aren't enough bars yet or they don't cluster.
    struct VersePocket: Equatable, Sendable {
        var bar: Int
        var punchWrap: Int
        var fromVerse: Bool
        var fillingHalf: Bool
        var caption: String {
            if fromVerse, fillingHalf {
                return "verse \(bar) · punch \(punchWrap)"
            }
            if fromVerse {
                return "verse \(bar)"
            }
            return "\(punchWrap)"
        }
    }

    /// Punch syllable target. Uses the verse pocket when prior bars agree; otherwise the setup count.
    static func cadencePunchWrap(setup: String, in text: String) -> VersePocket {
        let setupN = max(1, LineSyllableCounter.syllableCount(forLine: setup))
        let current = lastNonEmptyLine(in: text) ?? ""
        let fillingHalf = breathSetup(in: current) != nil || LyricClause.split(current) != nil
        let bar = verseBarPocket(in: text, excludingSetup: setup)
        if let bar {
            if fillingHalf {
                let punch = bar - setupN
                if punch >= 3 {
                    return VersePocket(bar: bar, punchWrap: punch, fromVerse: true, fillingHalf: true)
                }
                if punch >= 1 {
                    return VersePocket(bar: bar, punchWrap: max(3, punch), fromVerse: true, fillingHalf: true)
                }
                return VersePocket(bar: bar, punchWrap: bar, fromVerse: true, fillingHalf: false)
            } else {
                return VersePocket(bar: bar, punchWrap: bar, fromVerse: true, fillingHalf: false)
            }
        }
        return VersePocket(bar: setupN, punchWrap: setupN, fromVerse: false, fillingHalf: fillingHalf)
    }

    /// Mode of the last finished bars (±1). Prefers the most recent four when they cluster.
    static func verseBarPocket(in text: String, excludingSetup: String) -> Int? {
        var lines = text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        if let last = lines.last {
            let lastNorm = CadenceGhostCache.normalize(last)
            let setupNorm = CadenceGhostCache.normalize(excludingSetup)
            if lastNorm == setupNorm
                || lastNorm.hasPrefix(setupNorm)
                || breathSetup(in: last) != nil
                || LyricClause.split(last) != nil {
                lines.removeLast()
            }
        }
        let counts = lines.suffix(8).map { LineSyllableCounter.syllableCount(forLine: $0) }.filter { $0 >= 3 }
        guard counts.count >= 2 else { return nil }
        func cluster(_ values: [Int]) -> (n: Int, hits: Int)? {
            guard values.count >= 2 else { return nil }
            var bestN = 0
            var bestHits = 0
            for n in Set(values) {
                let hits = values.filter { abs($0 - n) <= 1 }.count
                if hits > bestHits || (hits == bestHits && n > bestN) {
                    bestHits = hits
                    bestN = n
                }
            }
            return bestHits >= 2 ? (bestN, bestHits) : nil
        }
        let recent = Array(counts.suffix(4))
        if let rec = cluster(recent), rec.hits >= 2 {
            return rec.n
        }
        return cluster(Array(counts))?.n
    }

    /// The line the user most recently finished — the segment terminated by the latest newline.
    /// Robust to predictive-text batching ("…star\nI talk" still yields "…star"). Falls back to the
    /// last non-empty line.
    static func justCompletedLine(in text: String) -> String? {
        let segments = text.components(separatedBy: "\n")
        if segments.count >= 2 {
            let candidate = segments[segments.count - 2]
            if !candidate.trimmingCharacters(in: .whitespaces).isEmpty { return candidate }
        }
        return segments.reversed().first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    /// The last non-empty line — the line the user is currently typing. Used for the live (debounced)
    /// refresh so rhymes appear as you type, before you hit Enter.
    static func lastNonEmptyLine(in text: String) -> String? {
        text.components(separatedBy: "\n").reversed().first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    func freeHint(forLastLine line: String) -> GhostHint? {
        guard let end = Self.endWord(of: line) else { return nil }
        let phonetic = Self.rhymeCandidates(for: end)
        guard !phonetic.isEmpty else { return nil }

        // Promote on-brand words (corpus hit) to the front.
        let onBrand: [String] = retriever.map { r in
            phonetic.filter { w in
                !r.retrieve(draft: w, k: 1).exemplars.isEmpty
            }
        } ?? []

        var ranked: [String] = []
        for w in (onBrand + phonetic) where !ranked.contains(w) {
            ranked.append(w)
        }
        return GhostHint(candidates: Array(ranked.prefix(3)), tail: nil)
    }

    // MARK: - Rhyme ranking (pure + testable; CMUDICT-independent)

    /// Rhyme strength between two phoneme arrays, matching the app's canonical `rhymeScore`
    /// (RapAnalysisEngine.swift:117): **2** = perfect (same stressed vowel *and* coda),
    /// **1** = slant (same stressed vowel, different coda), **0** = no rhyme.
    static func rhymeStrength(of candidate: [String], against target: [String]) -> Int {
        guard let t = phoneticSignature(from: target),
              let c = phoneticSignature(from: candidate),
              c.stressedVowel == t.stressedVowel else { return 0 }
        return c.coda == t.coda ? 2 : 1
    }

    /// Words from `lexicon` that rhyme with `target`, **perfect rhymes first**, then slant,
    /// shorter rap-usable words first within each tier. Drops CMUDICT noise (`a.d.`, `ab(2)`).
    static func rankedRhymes(target: [String], lexicon: [String: [String]], excluding: String, limit: Int) -> [String] {
        guard phoneticSignature(from: target) != nil else { return [] }
        var perfect: [String] = [], slant: [String] = []
        for (word, phonemes) in lexicon where word != excluding {
            switch rhymeStrength(of: phonemes, against: target) {
            case 2: perfect.append(word)
            case 1: slant.append(word)
            default: break
            }
        }
        let usablePerfect = RhymeFinder.sortRapUseful(perfect.filter { RhymeFinder.isUsableRhymeHeadword($0) })
        let usableSlant = RhymeFinder.sortRapUseful(slant.filter { RhymeFinder.isUsableRhymeHeadword($0) })
        return Array((usablePerfect + usableSlant).prefix(limit))
    }

    // MARK: - Private helpers

    /// CMUDICT-backed rhyme lookup. Perfect-first + deterministic via `rankedRhymes`.
    private static func rhymeCandidates(for word: String, limit: Int = 12) -> [String] {
        RhymeFinder.rankedRhymeWords(for: word, limit: limit)
    }

    // MARK: - Live ghost: pooled + rotating rhymes (responsive, fresh options each line)

    /// Ordered rhyme pool for a line's end word.
    /// Catalog landings first (70-artist index + live SQL), then usable CMUDICT.
    /// Dictionary respellings of the seed (`boan`/`boen` for bone) are dropped.
    /// Empty / punctuation-only lines return `[]` — never trap on a missing end word.
    nonisolated static func freeRhymePool(forLastLine line: String, limit: Int = 40, matchCadence: Bool = false) -> [String] {
        guard let end = endWord(of: line), !end.isEmpty else { return [] }
        let cadenceSeed = matchCadence ? LyricClause.cadenceLine(for: line) : line
        let wrap = LineSyllableCounter.syllableCount(forLine: cadenceSeed)
        let klass = BarHitsCatalogStore.phoneticClass(for: end)
        var ranked: [String] = []
        var seen = Set<String>()
        func accept(_ raw: String) -> Bool {
            let key = raw.lowercased()
            guard key != end, seen.insert(key).inserted else { return false }
            guard RhymeFinder.isUsableRhymeHeadword(key) else { return false }
            guard !isDictionarySpellingVariant(key, of: end) else { return false }
            ranked.append(raw)
            return ranked.count < limit
        }
        let wrapHint: Int? = matchCadence ? wrap : wrap
        for w in CatalogEndWordIndex.snapshotWords(
            matchingRhymeClass: klass,
            wrapSyllables: wrapHint,
            limit: limit
        ) {
            if matchCadence, !cadenceFits(w, line: cadenceSeed, targetWrap: wrap) { continue }
            if !accept(w) && ranked.count >= limit { return ranked }
        }
        if ranked.count < limit, let store = BarHitsCatalogStore.shared {
            for w in store.popularEndWords(phoneticClass: klass, limit: limit) {
                if matchCadence, !cadenceFits(w, line: cadenceSeed, targetWrap: wrap) { continue }
                if !accept(w) && ranked.count >= limit { return ranked }
            }
        }
        if ranked.count < limit {
            for w in RhymeFinder.rankedRhymeWords(for: end, limit: limit * 3) {
                if matchCadence, !cadenceFits(w, line: cadenceSeed, targetWrap: wrap) { continue }
                if !accept(w) && ranked.count >= limit { break }
            }
        }
        if let clause = LyricClause.split(line),
           clause.setupEnd != clause.punchEnd,
           ranked.count >= 3 {
            let setupPool = freeRhymePool(forLastLine: clause.setup, limit: 8, matchCadence: matchCadence)
            return mixingBreathRhymes(punch: ranked, setup: setupPool)
        }
        return ranked
    }

    /// Punch-family chips first, then a couple of setup-family chips so a comma breath is visible.
    nonisolated static func mixingBreathRhymes(punch: [String], setup: [String], punchLead: Int = 3, setupTake: Int = 2) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        func put(_ w: String) {
            let key = w.lowercased()
            guard seen.insert(key).inserted else { return }
            out.append(w)
        }
        let lead = min(max(punchLead, 0), punch.count)
        for w in punch.prefix(lead) { put(w) }
        for w in setup.prefix(max(setupTake, 0)) { put(w) }
        for w in punch.dropFirst(lead) { put(w) }
        return out
    }

    /// Keep the bar in the same wrap window when swapping the end word.
    nonisolated static func cadenceFits(_ word: String, line: String, targetWrap: Int) -> Bool {
        guard targetWrap > 0 else { return true }
        let swapped = replacingEndWord(of: line, with: word)
        let n = LineSyllableCounter.syllableCount(forLine: swapped)
        return abs(n - targetWrap) <= 1
    }

    nonisolated static func replacingEndWord(of line: String, with word: String) -> String {
        guard let end = endWord(of: line),
              let range = line.range(of: end, options: [.caseInsensitive, .backwards])
        else { return line + " " + word }
        return line.replacingCharacters(in: range, with: word)
    }

    /// `boan`/`boen`/`bohn` vs `bone` — CMUDICT respellings, not catalog landings.
    nonisolated static func isDictionarySpellingVariant(_ word: String, of seed: String) -> Bool {
        let a = Array(word.lowercased())
        let b = Array(seed.lowercased())
        guard abs(a.count - b.count) <= 1 else { return false }
        return editDistance(a, b) <= 1
    }

    nonisolated private static func editDistance(_ a: [Character], _ b: [Character]) -> Int {
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var prev = Array(0...b.count)
        var curr = Array(repeating: 0, count: b.count + 1)
        for i in 1...a.count {
            curr[0] = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                curr[j] = min(prev[j] + 1, curr[j - 1] + 1, prev[j - 1] + cost)
            }
            swap(&prev, &curr)
        }
        return prev[b.count]
    }

    /// Put `insert` on the line being written.
    /// A trailing blank line (Enter) is filled. Otherwise the current line is replaced.
    static func replacingCurrentLine(_ insert: String, in body: String) -> String {
        let cleaned = insert.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return body }
        if body.isEmpty { return cleaned }
        var lines = body.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard !lines.isEmpty else { return cleaned }
        lines[lines.count - 1] = cleaned
        return lines.joined(separator: "\n")
    }

    /// Drop the word on the line being written, not after trailing blank lines.
    /// After a comma-breath, replace the punch side instead of appending a second end word.
    /// `asPunchBar` writes the chip onto the next bar (newline breath) instead of gluing it on.
    static func insertingCandidate(_ word: String, into body: String, asPunchBar: Bool = false) -> String {
        let cleaned = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return body }
        var lines = body.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard let idx = lines.lastIndex(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) else {
            return cleaned
        }
        if asPunchBar {
            let line = lines[idx]
            if let comma = line.lastIndex(of: ",") {
                lines[idx] = String(line[...comma]) + " " + cleaned
            } else if idx + 1 < lines.count {
                lines[idx + 1] = cleaned
            } else if idx > 0 {
                lines[idx] = cleaned
            } else {
                lines.append(cleaned)
            }
            return lines.joined(separator: "\n")
        }
        var line = lines[idx]
        if let comma = line.lastIndex(of: ",") {
            line = String(line[...comma]) + " " + cleaned
        } else {
            if !line.hasSuffix(" ") { line += " " }
            line += cleaned
        }
        lines[idx] = line
        return lines.joined(separator: "\n")
    }

    /// Cache + seed only. Used to swap rhyme chips off the dock the instant a comma lands.
    nonisolated static func instantCadenceChips(setup: String, wrap: Int, limit: Int = 16) -> [GhostPunchChip] {
        if let cached = CadenceGhostCache.shared.chips(for: setup, wrap: wrap) {
            return Array(cached.chips.prefix(limit))
        }
        return rankCadencePunches(setup: setup, wrap: wrap, rows: [], limit: limit)
    }

    /// Punch fragments from the 1.7M catalog that share wrap + setup words.
    /// Last setup noun (`bitch`) is searched first so flips like "I'm what a bitch needs" surface.
    nonisolated static func cadencePunchPool(setup: String, limit: Int = 24, preferred: String? = nil, wrap: Int? = nil) -> [GhostPunchChip] {
        let wrap = wrap ?? LineSyllableCounter.syllableCount(forLine: setup)
        var tokens = CadenceGhostCache.normalize(setup)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 3 }
        if let last = tokens.last {
            tokens.removeAll { $0 == last }
            tokens.insert(last, at: 0)
        }
        guard let store = BarHitsCatalogStore.shared else {
            return rankCadencePunches(setup: setup, wrap: wrap, rows: [], limit: limit, preferred: preferred)
        }
        let window = BarHitsCatalogStore.wrapWindow(around: max(wrap, 4))
        let setupNorm = CadenceGhostCache.normalize(setup)
        var rows = store.cadencePunchRows(
            setupTokens: tokens,
            syllableMin: window.lowerBound,
            syllableMax: window.upperBound,
            limit: max(limit * 4, 80),
            setupNorm: setupNorm
        )
        if rows.count < 12 {
            rows += store.cadencePunchRows(
                setupTokens: tokens,
                syllableMin: 1,
                syllableMax: 16,
                limit: 80,
                setupNorm: setupNorm
            )
        }
        if rows.count < 12, let end = endWord(of: setup) {
            rows += store.wrapCandidates(
                syllableMin: window.lowerBound,
                syllableMax: window.upperBound,
                endWord: "",
                phoneticClass: BarHitsCatalogStore.phoneticClass(for: end),
                nearWords: [end],
                limit: 80
            )
        }
        return rankCadencePunches(setup: setup, wrap: wrap, rows: rows, limit: limit, preferred: preferred)
    }

    /// Rank catalog rows into punch chips. Wrap is scored on the fragment, not the full bar.
    nonisolated static func rankCadencePunches(
        setup: String,
        wrap: Int,
        rows: [BarHitsCatalogStore.Row],
        limit: Int = 24,
        preferred: String? = nil
    ) -> [GhostPunchChip] {
        let lastNoun = endWord(of: CadenceGhostCache.normalize(setup))?.lowercased() ?? ""
        struct Scored { var chip: GhostPunchChip; var score: Int }
        var scored: [Scored] = []
        var seen = Set<String>()
        func consider(_ punch: String, commaSource: Bool, artist: String?, song: String?) {
            let trimmed = punch.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = trimmed.lowercased()
            guard trimmed.split(whereSeparator: \.isWhitespace).count >= 2 else { return }
            guard seen.insert(key).inserted else { return }
            guard CadenceGhostCache.normalize(trimmed) != CadenceGhostCache.normalize(setup) else { return }
            var score = 0
            if !lastNoun.isEmpty, key.contains(lastNoun) { score += 10 }
            if key.contains("what") && (key.contains("need") || key.contains("needs")) { score += 6 }
            let n = LineSyllableCounter.syllableCount(forLine: trimmed)
            let delta = abs(n - max(wrap, 1))
            if delta <= 1 { score += 6 }
            else if delta <= 2 { score += 3 }
            else { score -= min(4, delta - 2) }
            if commaSource { score += 3 }
            let chain = rhymeChain(setup: setup, punch: trimmed)
            score += chain.score
            if let preferred, CadenceGhostCache.normalize(preferred) == CadenceGhostCache.normalize(trimmed) {
                score += 20
            }
            scored.append(
                Scored(
                    chip: GhostPunchChip(
                        text: trimmed,
                        syllables: n,
                        targetWrap: wrap,
                        artist: artist,
                        song: song,
                        preferred: preferred.map { CadenceGhostCache.normalize($0) == CadenceGhostCache.normalize(trimmed) } ?? false,
                        chained: chain.chained
                    ),
                    score: score
                )
            )
        }
        for row in rows {
            let fragments = punchFragments(from: row.line, setup: setup)
            let comma = row.line.contains(",")
            for frag in fragments {
                consider(frag, commaSource: comma, artist: row.artist, song: row.song)
            }
        }
        for seed in CadenceGhostCache.seedRecords(for: setup) {
            consider(seed.text, commaSource: true, artist: seed.artist, song: seed.song)
        }
        scored.sort {
            if $0.score != $1.score { return $0.score > $1.score }
            return $0.chip.text.split(whereSeparator: \.isWhitespace).count
                > $1.chip.text.split(whereSeparator: \.isWhitespace).count
        }
        return Array(fittingPunches(collapsePunchDupes(scored.map(\.chip)), wrap: wrap).prefix(limit))
    }

    /// Internal-to-end rhyme chain: setup landing (`toes`) is hit inside the punch (`hoes know`)
    /// and again at the end (`go`). Mosaic = two-word setup tail echoes a two-word punch pair.
    nonisolated static func rhymeChain(setup: String, punch: String) -> (score: Int, chained: Bool, internals: Int) {
        let setupWords = LyricClause.contentTokens(setup)
        let punchWords = LyricClause.contentTokens(punch)
        guard let setupEnd = setupWords.last, punchWords.count >= 2 else {
            return (0, false, 0)
        }
        let internals = Array(punchWords.dropLast())
        var score = 0
        var internalHits = 0
        var seen = Set<String>()
        for word in internals {
            let k = word.lowercased()
            guard seen.insert(k).inserted else { continue }
            guard k != setupEnd.lowercased() else { continue }
            if chainRhyme(setupEnd, word) {
                internalHits += 1
            }
        }
        internalHits = min(internalHits, 2)
        score += internalHits * 8
        var lands = false
        if let punchEnd = punchWords.last, chainRhyme(setupEnd, punchEnd) {
            lands = true
            score += 8
        }
        if setupWords.count >= 2 {
            let a = setupWords[setupWords.count - 2]
            let b = setupWords[setupWords.count - 1]
            let p = punchWords
            if p.count >= 2 {
                for i in 0..<(p.count - 1) {
                    let x = p[i], y = p[i + 1]
                    if chainRhyme(a, x), chainRhyme(b, y) {
                        score += 12
                        break
                    }
                    if chainRhyme(b, x), chainRhyme(b, y) {
                        score += 8
                        break
                    }
                }
            }
        }
        let chained = internalHits >= 1 && lands
        if chained { score += 10 }
        return (score, chained, internalHits)
    }

    /// Setup landing vs punch word. CMUDICT nucleus first, then the OW family (`toes`/`hoes`/`know`/`go`).
    nonisolated static func chainRhyme(_ a: String, _ b: String) -> Bool {
        let left = RhymeHighlighterEngine.spokenDigitWords(a.lowercased())?.last ?? a
        let right = RhymeHighlighterEngine.spokenDigitWords(b.lowercased())?.last ?? b
        if LyricClause.landsRhyme(left, right) { return true }
        let na = chainNucleus(left), nb = chainNucleus(right)
        if !na.isEmpty, na == nb { return true }
        return owFamily(left) && owFamily(right)
    }

    nonisolated static func chainNucleus(_ word: String) -> String {
        let klass = BarHitsCatalogStore.phoneticClass(for: word)
        let first = klass.split(separator: " ").first.map(String.init) ?? ""
        return first.filter { !$0.isNumber }
    }

    nonisolated static func owFamily(_ word: String) -> Bool {
        let x = word.lowercased()
        if x.hasSuffix("oes") || x.hasSuffix("ows") || x.hasSuffix("ow") || x.hasSuffix("oe") { return true }
        return ["go", "no", "so", "though", "oh", "know"].contains(x)
    }

    /// Keep scored order. Gutter wrap does not have to be exact — drop only far misses.
    nonisolated static func fittingPunches(_ chips: [GhostPunchChip], wrap: Int) -> [GhostPunchChip] {
        let target = max(wrap, 1)
        let near = chips.filter { abs($0.syllables - target) <= 3 }
        if !near.isEmpty { return near }
        return Array(chips.prefix(12))
    }

    /// Same stem (`needs`/`need`) or a token subset of a longer punch → one chip.
    nonisolated static func collapsePunchDupes(_ chips: [GhostPunchChip]) -> [GhostPunchChip] {
        var byStem: [String: GhostPunchChip] = [:]
        var order: [String] = []
        for chip in chips {
            let stem = punchStem(chip.text)
            guard !stem.isEmpty else { continue }
            if byStem[stem] == nil {
                byStem[stem] = chip
                order.append(stem)
            }
        }
        var kept: [GhostPunchChip] = []
        var keptTokens: [Set<String>] = []
        for stem in order {
            guard let chip = byStem[stem] else { continue }
            let tokens = punchTokenSet(chip.text)
            if keptTokens.contains(where: { tokens.isSubset(of: $0) && tokens != $0 }) { continue }
            kept.append(chip)
            keptTokens.append(tokens)
        }
        return kept
    }

    nonisolated static func punchStem(_ punch: String) -> String {
        punchTokenSet(punch).sorted().joined(separator: " ")
    }

    nonisolated static func punchTokenSet(_ punch: String) -> Set<String> {
        Set(
            CadenceGhostCache.normalize(punch)
                .split(separator: " ")
                .map { stemWord(String($0)) }
                .filter { $0.count >= 2 }
        )
    }

    nonisolated static func stemWord(_ word: String) -> String {
        if word.hasSuffix("s"), word.count > 3, !word.hasSuffix("ss") {
            return String(word.dropLast())
        }
        return word
    }

    nonisolated static func chips(fromTexts texts: [String], wrap: Int, preferred: String? = nil) -> [GhostPunchChip] {
        collapsePunchDupes(
            texts.map { raw in
                let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                return GhostPunchChip(
                    text: text,
                    syllables: LineSyllableCounter.syllableCount(forLine: text),
                    targetWrap: wrap,
                    artist: nil,
                    song: nil,
                    preferred: preferred.map { CadenceGhostCache.normalize($0) == CadenceGhostCache.normalize(text) } ?? false
                )
            }
        )
    }

    /// Best punch fragment for tests and single-line previews.
    nonisolated static func punchFragment(from catalogLine: String, setup: String) -> String? {
        punchFragments(from: catalogLine, setup: setup).first
    }

    /// Comma clauses plus the whole bar. Prefer the clause that still holds the setup noun.
    nonisolated static func punchFragments(from catalogLine: String, setup: String) -> [String] {
        let line = catalogLine.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !line.isEmpty else { return [] }
        let quotes = CharacterSet(charactersIn: "\"'“”")
        let lastNoun = endWord(of: CadenceGhostCache.normalize(setup))?.lowercased() ?? ""
        func wordCount(_ s: String) -> Int { s.split(whereSeparator: \.isWhitespace).count }
        let clauses = line.split(separator: ",", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: quotes) }
            .filter { wordCount($0) >= 2 }
        var out: [String] = []
        var seen = Set<String>()
        func put(_ raw: String) {
            let s = raw.trimmingCharacters(in: quotes)
            let key = CadenceGhostCache.normalize(s)
            guard !key.isEmpty, seen.insert(key).inserted else { return }
            guard key != CadenceGhostCache.normalize(setup) else { return }
            out.append(s)
        }
        if clauses.count >= 2 {
            let punches = Array(clauses.dropFirst())
            if !lastNoun.isEmpty {
                for p in punches where p.lowercased().contains(lastNoun) { put(p) }
                for c in clauses where c.lowercased().contains(lastNoun) { put(c) }
            }
            for p in punches { put(p) }
        }
        let whole = line.trimmingCharacters(in: quotes)
        if wordCount(whole) >= 3 { put(whole) }
        if out.isEmpty, wordCount(whole) >= 3 { return [whole] }
        return out
    }

    /// Stable key for the rhyme FAMILY of a line's end word. The live path keeps the SAME pool while
    /// this key is unchanged (a run of rhyming lines) — no CMUDICT re-scan, so it stays responsive —
    /// and re-scans only when the rhyme group changes.
    static func rhymeKey(forLastLine line: String) -> String? {
        guard let end = endWord(of: line),
              let phonemes = getGlobalCMUDICTStore()[end],
              let sig = phoneticSignature(from: phonemes) else { return nil }
        return sig.stressedVowel + "|" + sig.coda.joined(separator: " ")
    }

    /// `count` options from `pool`, advanced by `rotation` (pages by `count`, wraps) — so each
    /// Enter/indent surfaces fresh words from the same rhyme group.
    /// `% 0` is a Swift trap (EXC_BREAKPOINT); empty pools and non-positive counts return `[]`.
    static func window(_ pool: [String], rotation: Int, count: Int = 3) -> [String] {
        let n = pool.count
        guard n > 0, count > 0 else { return [] }
        let start = ((rotation * count) % n + n) % n
        return (0..<min(count, n)).map { pool[(start + $0) % n] }
    }

    private struct PhoneticSig {
        let stressedVowel: String
        let coda: [String]
    }

    /// The rhyme is anchored on the last **stressed** vowel (CMUDICT stress marker `1` or `2`);
    /// everything after it is the coda. CMUDICT marks EVERY vowel with a stress digit (0/1/2), so
    /// matching the last *digit-bearing* phoneme would grab an unstressed final vowel — e.g.
    /// "crazy" `K R EY1 Z IY0` → `IY0` with an empty coda — collapsing the rhyme key to a bare
    /// "-y" that "rhymes" with thousands of words (abbe, abadi…). Fall back to the last vowel of
    /// any stress only when no stressed vowel exists (rare; all-unstressed function words).
    /// (The canonical `extractSignature`, RapAnalysisEngine.swift:108, has the same latent pattern;
    /// corrected here because the Ghost scans the whole dictionary, where it surfaces.)
    private static func phoneticSignature(from phonemes: [String]) -> PhoneticSig? {
        let stressed = phonemes.lastIndex { $0.last == "1" || $0.last == "2" }
        guard let idx = stressed ?? phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
            return nil
        }
        return PhoneticSig(
            stressedVowel: phonemes[idx],
            coda: Array(phonemes.dropFirst(idx + 1))
        )
    }
}
