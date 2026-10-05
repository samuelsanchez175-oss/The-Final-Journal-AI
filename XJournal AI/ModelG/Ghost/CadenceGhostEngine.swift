import Foundation

enum CadenceBucket: String, Equatable, Sendable {
    case exact, stretch, twist, signature

    var chipTitle: String {
        switch self {
        case .exact: return "Exact"
        case .stretch: return "Stretch"
        case .twist: return "Twist"
        case .signature: return "Signature"
        }
    }
}

struct CadenceQuery: Equatable, Sendable {
    var currentLine: String
    var priorLine: String?
    var syllablesSoFar: Int
    var targetSyllables: Int
    var elasticity: Int
    var rhymeClass: String
}

struct CadenceSuggestion: Equatable, Identifiable, Sendable {
    var id: String { bucket.rawValue + "|" + insert }
    var insert: String
    var display: String
    var replacesLine: Bool
    var syllables: Int
    var bucket: CadenceBucket
    var sourceLine: String
    var artist: String?
    var metaphor: String?
    var isOriginal: Bool
    var personId: String
    var aspectId: String

    init(
        insert: String,
        display: String,
        replacesLine: Bool,
        syllables: Int,
        bucket: CadenceBucket,
        sourceLine: String,
        artist: String? = nil,
        metaphor: String? = nil,
        isOriginal: Bool,
        personId: String = "",
        aspectId: String = ""
    ) {
        self.insert = insert
        self.display = display
        self.replacesLine = replacesLine
        self.syllables = syllables
        self.bucket = bucket
        self.sourceLine = sourceLine
        self.artist = artist
        self.metaphor = metaphor
        self.isOriginal = isOriginal
        self.personId = personId
        self.aspectId = aspectId
    }
}

struct CadenceResult: Equatable, Sendable {
    var ghostTail: String
    var suggestions: [CadenceSuggestion]

    static let empty = CadenceResult(ghostTail: "", suggestions: [])
}

struct CadenceCatalogSlice: Equatable, Sendable {
    var wrap: [BarHitsCatalogStore.Row]
    var meaning: [BarHitsCatalogStore.Row]
}

enum CadenceGhostEngine {
    static let borrowStorageKey = "cadence_borrow"

    /// 0 = original landing / rewrite. 1 = paste the catalog bar.
    static func clampBorrow(_ value: Double) -> Double {
        min(1, max(0, value))
    }

    static func borrowCaption(_ value: Double) -> String {
        let v = clampBorrow(value)
        if v <= 0.25 { return "Original — just the landing. Rewrite the rest." }
        if v >= 0.8 { return "Copy — drop the catalog bar in. Rewrite as you go." }
        return "Blend — keep the pocket, borrow a few words."
    }

    static func makeQuery(from text: String, elasticity: Int = 1) -> CadenceQuery? {
        let parts = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let lastRaw = parts.last ?? ""
        let typingNewLine = lastRaw.trimmingCharacters(in: .whitespaces).isEmpty && parts.count >= 2
        let current: String
        let prior: String?
        if typingNewLine {
            current = lastRaw
            prior = GhostSuggestionEngine.justCompletedLine(in: text)
        } else {
            current = GhostSuggestionEngine.lastNonEmptyLine(in: text) ?? lastRaw
            let filled = parts
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            prior = filled.count >= 2 ? filled[filled.count - 2] : nil
        }
        let trimmedCurrent = current.trimmingCharacters(in: .whitespaces)
        guard !trimmedCurrent.isEmpty || prior != nil else { return nil }
        let soFar = LineSyllableCounter.syllableCount(forLine: current)
        let priorCount = prior.map { LineSyllableCounter.syllableCount(forLine: $0) } ?? 0
        let target = priorCount > 0 ? priorCount : max(soFar, 1)
        let rhymeClass: String
        if let prior, let end = GhostSuggestionEngine.endWord(of: prior) {
            rhymeClass = BarHitsCatalogStore.phoneticClass(for: end)
        } else {
            rhymeClass = ""
        }
        return CadenceQuery(
            currentLine: current,
            priorLine: prior,
            syllablesSoFar: soFar,
            targetSyllables: target,
            elasticity: max(0, elasticity),
            rhymeClass: rhymeClass
        )
    }

    static func loadSlice(
        query: CadenceQuery,
        catalog: BarHitsCatalogStore,
        artists: [String] = []
    ) -> CadenceCatalogSlice {
        let window = BarHitsCatalogStore.wrapWindow(around: query.targetSyllables)
        let wrap = catalog.wrapCandidates(
            syllableMin: window.lowerBound,
            syllableMax: window.upperBound,
            endWord: GhostSuggestionEngine.endWord(of: query.priorLine ?? "") ?? "",
            phoneticClass: query.rhymeClass,
            nearWords: [],
            artists: artists,
            limit: 120
        )
        let tokens = SimilarMeaningPipeline.seedTokens(for: query.currentLine.isEmpty ? (query.priorLine ?? "") : query.currentLine)
        let meaning = catalog.meaningCandidates(tokens: tokens, artists: artists, limit: 80)
        return CadenceCatalogSlice(wrap: wrap, meaning: meaning)
    }

    static func suggest(
        query: CadenceQuery,
        slice: CadenceCatalogSlice,
        borrow: Double,
        metaphor: MetaphorBridge = .shared
    ) -> CadenceResult {
        let borrow = clampBorrow(borrow)
        let exactRows = slice.wrap.filter { $0.syllables == query.targetSyllables && rhymeMatches($0, query: query) }
        let stretchRows = slice.wrap.filter {
            $0.syllables != query.targetSyllables && rhymeMatches($0, query: query)
        }
        let twistRows = slice.meaning.filter { row in
            query.rhymeClass.isEmpty || row.phoneticClass != query.rhymeClass
        }

        var suggestions: [CadenceSuggestion] = []
        if let row = pick(exactRows, typed: query.currentLine) {
            suggestions.append(makeSuggestion(row: row, query: query, bucket: .exact, borrow: borrow, metaphor: metaphor))
        }
        if let row = pick(stretchRows, typed: query.currentLine) {
            suggestions.append(makeSuggestion(row: row, query: query, bucket: .stretch, borrow: borrow, metaphor: metaphor))
        }
        if let row = pick(twistRows, typed: query.currentLine) {
            suggestions.append(makeSuggestion(row: row, query: query, bucket: .twist, borrow: borrow, metaphor: metaphor))
        }
        let open = max(0, query.targetSyllables - query.syllablesSoFar)
        let ranked = rankSignatures(
            SignatureBridge.offers(in: query.currentLine),
            open: open,
            rhymeClass: query.rhymeClass
        )
        for tail in ranked.prefix(3) {
            let syllables = LineSyllableCounter.syllableCount(forLine: tail.insert)
            suggestions.append(CadenceSuggestion(
                insert: tail.insert,
                display: tail.insert,
                replacesLine: false,
                syllables: syllables,
                bucket: .signature,
                sourceLine: query.currentLine,
                artist: tail.spoken,
                metaphor: tail.aspectLabel,
                isOriginal: true,
                personId: tail.personId,
                aspectId: tail.aspectId
            ))
        }

        let fittingSignature = suggestions.first { suggestion in
            suggestion.bucket == .signature && signatureFits(suggestion, open: open, rhymeClass: query.rhymeClass)
        }
        let ghost = suggestions.first { $0.bucket == .exact && !$0.replacesLine }
            ?? fittingSignature
            ?? suggestions.first { $0.bucket != .signature && !$0.replacesLine }
        return CadenceResult(ghostTail: ghost?.insert ?? "", suggestions: suggestions)
    }

    static func completionSuffix(typed: String, catalog: String) -> String {
        let typedWords = words(typed)
        let catalogWords = words(catalog)
        guard !catalogWords.isEmpty else { return "" }
        var i = 0
        while i < typedWords.count, i < catalogWords.count,
              typedWords[i].lowercased() == catalogWords[i].lowercased() {
            i += 1
        }
        if i == 0, let last = typedWords.last {
            let needle = last.lowercased()
            if let idx = catalogWords.firstIndex(where: { $0.lowercased().hasPrefix(needle) && $0.count >= needle.count }) {
                let rest = Array(catalogWords[idx...])
                if rest[0].lowercased() == needle {
                    return rest.dropFirst().joined(separator: " ")
                }
                let leftover = String(rest[0].dropFirst(needle.count))
                let tail = rest.dropFirst().joined(separator: " ")
                return leftover.isEmpty ? tail : (tail.isEmpty ? leftover : leftover + " " + tail)
            }
            return catalogWords.suffix(min(3, catalogWords.count)).joined(separator: " ")
        }
        return catalogWords.dropFirst(i).joined(separator: " ")
    }

    static func applying(_ suggestion: CadenceSuggestion, to body: String) -> String {
        let lines = body.split(separator: "\n", omittingEmptySubsequences: false)
        let onFreshLine = lines.last.map { $0.trimmingCharacters(in: .whitespaces).isEmpty } ?? false
        if suggestion.replacesLine || onFreshLine {
            return GhostSuggestionEngine.replacingCurrentLine(suggestion.insert, in: body)
        }
        return GhostSuggestionEngine.insertingCandidate(suggestion.insert, into: body)
    }

    // MARK: - Private

    private static func rankSignatures(
        _ tails: [SignatureTail],
        open: Int,
        rhymeClass: String
    ) -> [SignatureTail] {
        tails.enumerated().sorted { lhs, rhs in
            let left = signatureScore(lhs.element, open: open, rhymeClass: rhymeClass)
            let right = signatureScore(rhs.element, open: open, rhymeClass: rhymeClass)
            if left != right { return left < right }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    /// Lower is a better fit. Syllable distance leads. A kept chip can move up. A skip moves it down.
    private static func signatureScore(_ tail: SignatureTail, open: Int, rhymeClass: String) -> Int {
        let syllables = LineSyllableCounter.syllableCount(forLine: tail.insert)
        let distance = abs(syllables - open) * 10
        let memory = SignatureMemory.adjustment(personId: tail.personId, aspectId: tail.aspectId)
        return distance + rhymePenalty(for: tail.insert, rhymeClass: rhymeClass) + memory
    }

    private static func signatureFits(_ suggestion: CadenceSuggestion, open: Int, rhymeClass: String) -> Bool {
        suggestion.syllables == open && rhymePenalty(for: suggestion.insert, rhymeClass: rhymeClass) == 0
    }

    private static func rhymePenalty(for insert: String, rhymeClass: String) -> Int {
        guard !rhymeClass.isEmpty else { return 0 }
        let end = insert.split { !$0.isLetter && $0 != "'" }.last.map(String.init) ?? ""
        guard !end.isEmpty else { return 5 }
        let klass = BarHitsCatalogStore.phoneticClass(for: end)
        if klass.isEmpty || klass == rhymeClass { return 0 }
        return 5
    }

    private static func rhymeMatches(_ row: BarHitsCatalogStore.Row, query: CadenceQuery) -> Bool {
        if query.rhymeClass.isEmpty { return true }
        if !row.phoneticClass.isEmpty { return row.phoneticClass == query.rhymeClass }
        guard let end = GhostSuggestionEngine.endWord(of: row.line) else { return false }
        return BarHitsCatalogStore.phoneticClass(for: end) == query.rhymeClass
    }

    private static func pick(_ rows: [BarHitsCatalogStore.Row], typed: String) -> BarHitsCatalogStore.Row? {
        let typedNorm = RemindsMeOfScorer.normalizedLine(typed)
        let usable = rows.filter { RemindsMeOfScorer.normalizedLine($0.line) != typedNorm }
        guard !usable.isEmpty else { return nil }
        return usable.max { a, b in
            let sa = prefixScore(typed: typed, catalog: a.line)
            let sb = prefixScore(typed: typed, catalog: b.line)
            if sa != sb { return sa < sb }
            return a.line.count > b.line.count
        }
    }

    private static func prefixScore(typed: String, catalog: String) -> Int {
        let tw = words(typed)
        let cw = words(catalog)
        var n = 0
        while n < tw.count, n < cw.count, tw[n].lowercased() == cw[n].lowercased() { n += 1 }
        return n
    }

    private static func makeSuggestion(
        row: BarHitsCatalogStore.Row,
        query: CadenceQuery,
        bucket: CadenceBucket,
        borrow: Double,
        metaphor: MetaphorBridge
    ) -> CadenceSuggestion {
        let planned = insertPlan(typed: query.currentLine, catalog: row.line, borrow: borrow)
        let picture = metaphor.label(row.line)?.label
        return CadenceSuggestion(
            insert: planned.insert,
            display: planned.replacesLine ? row.line : planned.insert,
            replacesLine: planned.replacesLine,
            syllables: row.syllables,
            bucket: bucket,
            sourceLine: row.line,
            artist: row.artist,
            metaphor: picture,
            isOriginal: false
        )
    }

    private static func insertPlan(typed: String, catalog: String, borrow: Double) -> (insert: String, replacesLine: Bool) {
        let suffix = completionSuffix(typed: typed, catalog: catalog)
        let landing = GhostSuggestionEngine.endWord(of: catalog) ?? suffix
        if borrow >= 0.8 {
            let trimmed = typed.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, catalog.lowercased().hasPrefix(trimmed.lowercased()), !suffix.isEmpty {
                return (suffix, false)
            }
            return (catalog, true)
        }
        if borrow <= 0.25 {
            return (landing, false)
        }
        let bits = suffix.split(whereSeparator: \.isWhitespace).map(String.init)
        if borrow < 0.5 {
            let short = bits.prefix(2).joined(separator: " ")
            return (short.isEmpty ? landing : short, false)
        }
        return (suffix.isEmpty ? landing : suffix, false)
    }

    private static func words(_ line: String) -> [String] {
        line.split(whereSeparator: \.isWhitespace).map(String.init).filter { !$0.isEmpty }
    }
}
