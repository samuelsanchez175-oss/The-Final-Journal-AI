import Foundation

nonisolated enum RemindsMeOfScorer: Sendable {
    struct LineSpan: Equatable {
        let index: Int
        let text: String
        let location: Int
        let length: Int
    }

    static func queryLines(from text: String) -> [String] {
        lineSpans(in: text).map(\.text)
    }

    /// Real bars only (skips blanks and short ad-libs). Ranges are UTF-16 for UITextView taps.
    static func lineSpans(in text: String) -> [LineSpan] {
        let parts = text.split(separator: "\n", omittingEmptySubsequences: false)
        var spans: [LineSpan] = []
        var location = 0
        for (index, part) in parts.enumerated() {
            let line = String(part)
            let length = (line as NSString).length
            if isSearchableLine(line) {
                spans.append(LineSpan(index: index, text: line, location: location, length: length))
            }
            location += length
            if index < parts.count - 1 { location += 1 }
        }
        return spans
    }

    static func isSearchableLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let tokens = trimmed
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 2 }
        return tokens.count >= 3
    }

    static func linePopsOnGenius(hitCount: Int) -> Bool {
        hitCount > 0
    }

    static func match(containingUTF16 location: Int, in matches: [RemindsMeOfLineMatch]) -> RemindsMeOfLineMatch? {
        matches.first { location >= $0.location && location < $0.location + $0.length }
    }

    static func contentTokens(_ text: String) -> Set<String> {
        let fragments: Set<String> = ["the", "a", "an", "and", "or", "to", "of", "in", "on", "my", "i", "you", "it"]
        return Set(
            text.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { $0.count >= 3 && !fragments.contains($0) }
        )
    }

    static func wrapScore(candidateSyllables: Int, target: Int) -> Double {
        let delta = abs(candidateSyllables - target)
        if delta <= 2 { return 1 }
        return max(0, 1 - Double(delta - 2) / 6.0)
    }

    static func syllableScore(candidateSyllables: Int, querySyllables: [Int]) -> Double {
        guard let nearest = querySyllables.min(by: { abs($0 - candidateSyllables) < abs($1 - candidateSyllables) }) else {
            return 0.5
        }
        return max(0, 1 - Double(abs(candidateSyllables - nearest)) / 8.0)
    }

    static func overlapScore(candidate: String, queryLines: [String]) -> Double {
        let cand = contentTokens(candidate)
        let query = Set(queryLines.flatMap { contentTokens($0) })
        guard !cand.isEmpty, !query.isEmpty else { return 0 }
        return Double(cand.intersection(query).count) / Double(cand.union(query).count)
    }

    static func normalizedLine(_ line: String) -> String {
        line.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    /// Real sung/rapped bars only — drops ad-libs, scrape junk, and artist-credit rows.
    static func isLyricBar(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ModelGCorpusRetriever.isRealBar(trimmed) else { return false }
        let lower = trimmed.lowercased()
        if trimmed.hasPrefix("|") { return false }
        if lower.contains("aria-label") || lower.contains("cover art for") || lower.contains("you might also like") {
            return false
        }
        if looksLikeArtistCredit(trimmed) { return false }
        return true
    }

    /// "Young Stoner Life, Young Thug & Gunna" — comma + & and every token is a name.
    static func looksLikeArtistCredit(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.contains(",") else { return false }
        let hasAnd = trimmed.contains("&") || trimmed.range(of: " and ", options: .caseInsensitive) != nil
        guard hasAnd else { return false }
        let tokens = trimmed
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        guard tokens.count >= 3 else { return false }
        let allow: Set<String> = ["and", "the", "of", "y", "n"]
        return tokens.allSatisfy { token in
            allow.contains(token.lowercased()) || token.first?.isUppercase == true
        }
    }

    /// 8-count wrap also shows 7, 9, and 10 so there are options.
    static func wrapSyllableWindow(around syllables: Int) -> ClosedRange<Int> {
        BarHitsCatalogStore.wrapWindow(around: syllables)
    }

    static func openingTokens(_ line: String) -> [String] {
        let toks = line.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        guard toks.count >= 2 else { return toks }
        return Array(toks.dropLast())
    }

    /// How much of the held line's start the candidate shares (`I drip` → 2).
    static func prefixOverlap(_ query: String, _ candidate: String) -> Int {
        let a = openingTokens(query)
        let b = openingTokens(candidate)
        var n = 0
        for (x, y) in zip(a, b) {
            let ax = (x == "im" || x == "i") ? "i" : x
            let by = (y == "im" || y == "i") ? "i" : y
            if ax == by { n += 1 } else { break }
        }
        return n
    }

    /// Internal rhymes and repeated punches. End-word echoing an earlier word counts.
    static func innerRhymeScore(_ line: String) -> Int {
        let skip: Set<String> = [
            "the", "a", "an", "and", "or", "to", "of", "in", "on", "my", "i", "im",
            "you", "it", "we", "that", "this", "me"
        ]
        let toks = line.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 2 && !skip.contains($0) }
        guard toks.count >= 2 else { return 0 }
        var score = 0
        for i in 0..<toks.count {
            for j in (i + 1)..<toks.count {
                if toks[i] == toks[j] {
                    score += 2
                    continue
                }
                guard let a = getGlobalCMUDICTStore()[toks[i]],
                      let b = getGlobalCMUDICTStore()[toks[j]]
                else { continue }
                switch RhymeFinder.rhymeTier(a, b) {
                case 3: score += 3
                case 2: score += 2
                case 1: score += 1
                default: break
                }
            }
        }
        for i in 0..<(toks.count - 1) where toks[i].count > 2 && toks[i].first == toks[i + 1].first {
            score += 1
        }
        return score
    }

    /// Concrete picture words — long tokens plus catalog theme hits.
    static func imageryScore(_ line: String) -> Int {
        let skip: Set<String> = [
            "the", "a", "an", "and", "or", "to", "of", "in", "on", "my", "i", "you", "it"
        ]
        let toks = line.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 3 && !skip.contains($0) }
        var n = toks.filter { $0.count >= 6 }.count
        n += ThemeCatalog.matchedThemeIDs(in: line, minimumScore: 2).count
        return n
    }

    static func isWeakLanding(_ line: String) -> Bool {
        let weak: Set<String> = ["yeah", "yea", "uh", "woo", "ayy", "hey", "ah", "ooh", "ya"]
        guard let end = GhostSuggestionEngine.endWord(of: line) else { return false }
        return weak.contains(end)
    }

    static func isJunkAdlibLine(_ line: String) -> Bool {
        let lower = line.lowercased()
        if lower.contains("boo-hoo") || lower.contains("sheesh") { return true }
        if lower.contains("play my song") { return true }
        return false
    }

    /// Wrap-window bars whose endings rhyme or almost-rhyme with the held line.
    /// Catalog MIR BPM/key/scale is NOT a ranking input. Sqlite proof (2026-09):
    /// 42,560 unique artist|song rows, 40,940 in the top-70-artist vault, 0 audio
    /// columns — BPM/key/scale are null without local Model You audio. Wiring note
    /// BPM would gate almost every hit on missing numbers and cannot improve accuracy.
    static func wrapHits(
        from pool: [RemindsMeOfCandidate],
        queryLine: String,
        syllables: Int,
        nearWords: Set<String> = [],
        limit: Int = 24
    ) -> [RemindsMeOfHit] {
        let query = queryLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let queryKey = normalizedLine(query)
        guard !query.isEmpty, syllables > 0 else { return [] }
        let window = wrapSyllableWindow(around: syllables)
        let queryEnd = GhostSuggestionEngine.endWord(of: query)
        let near = Set(nearWords.map { $0.lowercased() })

        var seen = Set<String>()
        var scored: [(hit: RemindsMeOfHit, exact: Bool, perfect: Bool)] = []
        for row in pool {
            let n = row.syllableCount > 0
                ? row.syllableCount
                : LineSyllableCounter.syllableCount(forLine: row.line)
            guard window.contains(n) else { continue }
            guard isLyricBar(row.line) else { continue }
            guard !isTitleLeak(row.line, song: row.song) else { continue }
            guard !isWeakLanding(row.line) else { continue }
            guard !isJunkAdlibLine(row.line) else { continue }
            let key = normalizedLine(row.line)
            guard key != queryKey, seen.insert(key).inserted else { continue }
            let candEnd = GhostSuggestionEngine.endWord(of: row.line)
            let sameEnd = queryEnd != nil && candEnd == queryEnd
            let almost = endRhymeBonus(candidate: row.line, queryLines: [query]) > 0
                || (candEnd != nil && near.contains(candEnd!))
            let overlap = overlapScore(candidate: row.line, queryLines: [query])
            // Same end-word still counts as a wrap hit even without extra overlap.
            guard sameEnd || almost || overlap > 0 else { continue }
            guard sameEnd || almost || near.isEmpty else { continue }
            if !sameEnd && !almost && overlap > 0 && n != syllables { continue }
            let hit = score(
                candidate: row,
                against: [query],
                querySyllables: [syllables],
                wrapTarget: syllables
            )
            scored.append((hit, n == syllables, sameEnd || almost && endRhymeBonus(candidate: row.line, queryLines: [query]) >= 0.15))
        }
        // Same-end wrap-window bars must still surface if junk/ad-lib filters emptied the list.
        if scored.isEmpty, let queryEnd {
            seen.removeAll()
            for row in pool {
                let n = row.syllableCount > 0
                    ? row.syllableCount
                    : LineSyllableCounter.syllableCount(forLine: row.line)
                guard window.contains(n) else { continue }
                let key = normalizedLine(row.line)
                guard key != queryKey, seen.insert(key).inserted else { continue }
                guard GhostSuggestionEngine.endWord(of: row.line) == queryEnd else { continue }
                let hit = score(
                    candidate: row,
                    against: [query],
                    querySyllables: [syllables],
                    wrapTarget: syllables
                )
                scored.append((hit, n == syllables, true))
            }
        }
        // Wrap distance first, then inner rhyme / imagery, then end-rhyme quality.
        scored.sort { a, b in
            let da = abs(a.hit.syllableCount - syllables)
            let db = abs(b.hit.syllableCount - syllables)
            if da != db { return da < db }
            let ia = innerRhymeScore(a.hit.line)
            let ib = innerRhymeScore(b.hit.line)
            if ia != ib { return ia > ib }
            let ga = imageryScore(a.hit.line)
            let gb = imageryScore(b.hit.line)
            if ga != gb { return ga > gb }
            if a.perfect != b.perfect { return a.perfect && !b.perfect }
            return a.hit.score > b.hit.score
        }
        return spreadArtistsPreservingWrap(scored.map(\.hit), targetSyllables: syllables, limit: limit)
    }

    /// Round-robin artists inside each wrap-count bucket so Δ0 isn't buried under Gunna Δ1.
    static func spreadArtistsPreservingWrap(_ hits: [RemindsMeOfHit], targetSyllables: Int, limit: Int) -> [RemindsMeOfHit] {
        guard hits.count > 1, limit > 0 else { return Array(hits.prefix(limit)) }
        let window = wrapSyllableWindow(around: targetSyllables)
        var order = [targetSyllables]
        for count in window where count != targetSyllables {
            order.append(count)
        }
        let buckets = Dictionary(grouping: hits, by: \.syllableCount)
        var out: [RemindsMeOfHit] = []
        for count in order {
            guard let slice = buckets[count], !slice.isEmpty else { continue }
            out.append(contentsOf: spreadArtists(slice, limit: limit - out.count))
            if out.count >= limit { break }
        }
        return Array(out.prefix(limit))
    }

    /// Round-robin by artist so the first 10 aren't all Gunna just because those rows sit first.
    static func spreadArtists(_ hits: [RemindsMeOfHit], limit: Int) -> [RemindsMeOfHit] {
        guard hits.count > 1, limit > 0 else { return Array(hits.prefix(limit)) }
        var buckets: [[RemindsMeOfHit]] = []
        var index: [String: Int] = [:]
        for hit in hits {
            let raw = hit.artist?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let key = raw.isEmpty ? "_" : raw.lowercased()
            if let i = index[key] {
                buckets[i].append(hit)
            } else {
                index[key] = buckets.count
                buckets.append([hit])
            }
        }
        var out: [RemindsMeOfHit] = []
        var round = 0
        while out.count < limit {
            var added = false
            for bucket in buckets {
                if round < bucket.count {
                    out.append(bucket[round])
                    added = true
                    if out.count == limit { return out }
                }
            }
            if !added { break }
            round += 1
        }
        return out
    }

    /// Song title leaked in as if it were a sung bar.
    static func isTitleLeak(_ line: String, song: String?) -> Bool {
        let bar = normalizedLine(line)
        let title = normalizedLine(song ?? "")
        guard !bar.isEmpty, !title.isEmpty else { return false }
        return bar == title
    }

    /// Distinctive words from the bar, last few in order — not the whole sentence.
    static func trackSearchTokens(forLine line: String) -> [String] {
        let skip: Set<String> = [
            "the", "a", "an", "and", "or", "to", "of", "in", "on", "my", "i", "you", "it",
            "we", "they", "that", "this", "with", "from", "for", "where", "when", "but", "not",
            "just", "like", "your", "our", "all"
        ]
        let tokens = line.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 4 && !skip.contains($0) }
        if tokens.isEmpty {
            return Array(contentTokens(line)).sorted()
        }
        return Array(tokens.suffix(3))
    }

    /// True when the candidate lands on the same end word, or rhymes with it.
    static func landingScore(candidate: String, queryLine: String) -> Double {
        guard let candEnd = GhostSuggestionEngine.endWord(of: candidate),
              let queryEnd = GhostSuggestionEngine.endWord(of: queryLine)
        else { return 0 }
        if candEnd == queryEnd { return 1 }
        return endRhymeBonus(candidate: candidate, queryLines: [queryLine])
    }

    /// Same end-word family, not necessarily the same syllable count.
    static func endRhymeHits(
        from pool: [RemindsMeOfCandidate],
        queryLine: String,
        excluding excludedKeys: Set<String>,
        limit: Int = 12
    ) -> [RemindsMeOfHit] {
        landingHits(from: pool, queryLine: queryLine, excluding: excludedKeys, limit: limit)
    }

    /// Real bars that land on the same word or rhyme with it. Song titles are not bars.
    static func landingHits(
        from pool: [RemindsMeOfCandidate],
        queryLine: String,
        excluding excludedKeys: Set<String>,
        limit: Int = 12
    ) -> [RemindsMeOfHit] {
        let query = queryLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let queryKey = normalizedLine(query)
        guard !query.isEmpty, GhostSuggestionEngine.endWord(of: query) != nil else { return [] }

        var seen = excludedKeys
        seen.insert(queryKey)
        var scored: [(hit: RemindsMeOfHit, value: Double)] = []
        for row in pool {
            guard isLyricBar(row.line) else { continue }
            guard !isTitleLeak(row.line, song: row.song) else { continue }
            let key = normalizedLine(row.line)
            guard seen.insert(key).inserted else { continue }
            let value = landingScore(candidate: row.line, queryLine: query)
            guard value > 0 else { continue }
            let n = row.syllableCount > 0
                ? row.syllableCount
                : LineSyllableCounter.syllableCount(forLine: row.line)
            let hit = score(
                candidate: row,
                against: [query],
                querySyllables: [n],
                wrapTarget: n
            )
            scored.append((hit, value))
        }
        let rankedLanding = scored.sorted { $0.value > $1.value }.map(\.hit)
        return spreadArtists(rankedLanding, limit: limit)
    }

    /// Same meaning — shared content words or the same catalog theme. Syllable count can differ.
    static func themeHits(
        from pool: [RemindsMeOfCandidate],
        queryLine: String,
        excluding excludedKeys: Set<String>,
        limit: Int = 12
    ) -> [RemindsMeOfHit] {
        let query = queryLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let queryKey = normalizedLine(query)
        guard !query.isEmpty else { return [] }

        var seen = excludedKeys
        seen.insert(queryKey)
        var scored: [(hit: RemindsMeOfHit, value: Double)] = []
        for row in pool {
            guard isLyricBar(row.line) else { continue }
            let key = normalizedLine(row.line)
            guard seen.insert(key).inserted else { continue }
            guard let value = themeScore(candidate: row.line, queryLine: query), value > 0 else { continue }
            let n = row.syllableCount > 0
                ? row.syllableCount
                : LineSyllableCounter.syllableCount(forLine: row.line)
            let hit = RemindsMeOfHit(
                id: row.id,
                line: row.line,
                artist: row.artist,
                song: row.song,
                source: row.source,
                url: row.url,
                syllableCount: n,
                score: min(1, value)
            )
            scored.append((hit, value))
        }
        let rankedTheme = scored.sorted { $0.value > $1.value }.map(\.hit)
        return spreadArtists(rankedTheme, limit: limit)
    }

    static func sharesTheme(_ candidate: String, _ queryLine: String) -> Bool {
        themeScore(candidate: candidate, queryLine: queryLine) != nil
    }

    /// Catalog theme overlap, or at least two shared content words.
    /// Catalog-only matches still need one shared word so unrelated bars don't collide on a generic theme.
    static func themeScore(candidate: String, queryLine: String) -> Double? {
        let queryThemes = ThemeCatalog.matchedThemeIDs(in: queryLine, minimumScore: 2)
        let candThemes = ThemeCatalog.matchedThemeIDs(in: candidate, minimumScore: 2)
        let sharedThemes = queryThemes.intersection(candThemes)
        let queryTokens = contentTokens(queryLine)
        let candTokens = contentTokens(candidate)
        let sharedTokens = queryTokens.intersection(candTokens)
        let overlap = overlapScore(candidate: candidate, queryLines: [queryLine])
        let catalogHit = !sharedThemes.isEmpty && !sharedTokens.isEmpty
        let meaningHit = sharedTokens.count >= 2
        guard catalogHit || meaningHit else { return nil }
        let catalogBonus = catalogHit ? 0.22 : 0
        return min(1, overlap * 0.78 + catalogBonus)
    }

    /// Best sung/rapped line inside a Genius lyric snippet (skips chorus tags and ad-libs).
    static func pickSnippetLine(_ snippet: String, queryLine: String, syllables: Int) -> String? {
        let cleaned = snippet
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
        let parts = cleaned
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !isSnippetNoise($0) }
        let bars = parts.filter { isLyricBar($0) }
        let pool = bars.isEmpty ? parts.filter { isSearchableLine($0) } : bars
        guard !pool.isEmpty else { return nil }
        return pool.max { a, b in
            snippetLineScore(a, queryLine: queryLine, syllables: syllables)
                < snippetLineScore(b, queryLine: queryLine, syllables: syllables)
        }
    }

    static func snippetLineScore(_ line: String, queryLine: String, syllables: Int) -> Double {
        let n = LineSyllableCounter.syllableCount(forLine: line)
        return 0.45 * wrapScore(candidateSyllables: n, target: max(syllables, 1))
            + 0.35 * overlapScore(candidate: line, queryLines: [queryLine])
            + endRhymeBonus(candidate: line, queryLines: [queryLine])
    }

    static func isSnippetNoise(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        if lower.hasPrefix("[") && lower.hasSuffix("]") { return true }
        if lower.hasPrefix("(") && lower.hasSuffix(")") {
            let inner = String(lower.dropFirst().dropLast())
            let markers = ["chorus", "verse", "hook", "bridge", "intro", "outro", "pre-chorus", "refrain", "ad-lib"]
            if markers.contains(where: { inner.contains($0) }) { return true }
        }
        let tokens = trimmed
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        if !tokens.isEmpty && tokens.allSatisfy({ $0.lowercased() == "ha" }) { return true }
        return false
    }

    static func endRhymeBonus(candidate: String, queryLines: [String]) -> Double {
        guard let candEnd = GhostSuggestionEngine.endWord(of: candidate),
              let queryEnd = queryLines.last.flatMap({ GhostSuggestionEngine.endWord(of: $0) }),
              candEnd != queryEnd,
              let a = getGlobalCMUDICTStore()[candEnd],
              let b = getGlobalCMUDICTStore()[queryEnd]
        else { return 0 }
        switch RhymeFinder.rhymeTier(a, b) {
        case 3: return 0.25
        case 2: return 0.15
        case 1: return 0.08
        default: return 0
        }
    }

    /// 0...1. Syllable pocket + wrap window + shared words + end-rhyme.
    static func score(candidate: String, against queryLines: [String], querySyllables: [Int], wrapTarget: Int) -> Double {
        let n = LineSyllableCounter.syllableCount(forLine: candidate)
        let raw = 0.40 * syllableScore(candidateSyllables: n, querySyllables: querySyllables)
            + 0.25 * wrapScore(candidateSyllables: n, target: wrapTarget)
            + 0.25 * overlapScore(candidate: candidate, queryLines: queryLines)
            + endRhymeBonus(candidate: candidate, queryLines: queryLines)
        return min(1, max(0, raw))
    }

    static func score(candidate: RemindsMeOfCandidate, against queryLines: [String], querySyllables: [Int], wrapTarget: Int) -> RemindsMeOfHit {
        let n = candidate.syllableCount > 0
            ? candidate.syllableCount
            : LineSyllableCounter.syllableCount(forLine: candidate.line)
        let value = score(
            candidate: candidate.line,
            against: queryLines,
            querySyllables: querySyllables,
            wrapTarget: wrapTarget
        )
        return RemindsMeOfHit(
            id: candidate.id,
            line: candidate.line,
            artist: candidate.artist,
            song: candidate.song,
            source: candidate.source,
            url: candidate.url,
            syllableCount: n,
            score: value
        )
    }

    static func group(_ hits: [RemindsMeOfHit]) -> [RemindsMeOfGroup] {
        let lyric = hits.filter { $0.source != .genius || $0.syllableCount >= 4 }
        let connections = hits.filter { $0.source == .genius && $0.syllableCount < 4 }

        var buckets: [Int: [RemindsMeOfHit]] = [:]
        for hit in lyric {
            buckets[hit.syllableCount, default: []].append(hit)
        }

        var groups: [RemindsMeOfGroup] = buckets.keys.sorted().map { count in
            let title = count == 1 ? "1-syllable pocket" : "\(count)-syllable wrap"
            return RemindsMeOfGroup(
                id: "syl-\(count)",
                title: title,
                colorIndex: abs(count.hashValue) % RhymeColorPalette.colors.count,
                hits: (buckets[count] ?? []).sorted { $0.score > $1.score }
            )
        }

        if !connections.isEmpty {
            groups.append(
                RemindsMeOfGroup(
                    id: "genius",
                    title: "Genius",
                    colorIndex: 0,
                    hits: connections.sorted { $0.score > $1.score }
                )
            )
        }
        return groups.filter { !$0.hits.isEmpty }
    }
}
