import Foundation
import Combine

@MainActor
final class RemindsMeOfService: ObservableObject {
    @Published private(set) var lastMeaningCards: [SimilarMeaningPipeline.ScoredCard] = []

    @Published private(set) var groups: [RemindsMeOfGroup] = []
    @Published private(set) var matches: [RemindsMeOfLineMatch] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isScanning = false
    /// More tens are still appending; the list stays visible.
    @Published private(set) var isFilling = false
    @Published private(set) var fillingCopy = "Loading 10 more…"
    @Published private(set) var scannedDoneCount = 0
    @Published private(set) var scannedLineCount = 0
    @Published private(set) var missingGeniusKey = false
    @Published var errorMessage: String?
    @Published var searchIssue: RemindsMeOfSearchIssue?
    @Published private(set) var heldLineResult: RemindsMeOfHeldLineResult?
    @Published var preferGeniusTab = false
    /// Empty = whole on-device vault. Set from the Catalog picker.
    @Published var selectedCatalogArtists: Set<String> = []

    var isActive: Bool { isScanning || isFilling || !matches.isEmpty || heldLineResult != nil }

    private var lastSignature: String = ""
    private var lastScanSignature: String = ""
    private var bundled: [RemindsMeOfCandidate] = []
    private var bundledReady = false
    private var scanTask: Task<Void, Never>?
    private var heldTask: Task<Void, Never>?
    private var heldSearchID = UUID()

    /// Stops the in-flight hold lookup so a dismissed sheet cannot publish later.
    func cancelHeldLookup() {
        heldSearchID = UUID()
        heldTask?.cancel()
        heldTask = nil
        isScanning = false
        isFilling = false
    }

    func startHeldLookup(line: String, syllables: Int, priorNoteLines: [String] = []) {
        heldTask?.cancel()
        heldTask = Task { @MainActor in
            await searchHeldLine(line: line, syllables: syllables, priorNoteLines: priorNoteLines)
        }
    }

    /// Catalog reads are synchronous sqlite. Hop them so a swipe can dismiss while they run.
    private static func catalogRows(
        _ body: @escaping @Sendable () -> [BarHitsCatalogStore.Row]
    ) async -> [BarHitsCatalogStore.Row] {
        await Task.detached(priority: .userInitiated, operation: body).value
    }

    func match(containingUTF16 location: Int) -> RemindsMeOfLineMatch? {
        RemindsMeOfScorer.match(containingUTF16: location, in: matches)
    }

    func highlights(in text: String) -> [Highlight] {
        matches.compactMap { match in
            let ns = NSRange(location: match.location, length: match.length)
            guard ns.length > 0, ns.location + ns.length <= (text as NSString).length else { return nil }
            return Highlight(
                utf16: ns,
                colorIndex: 2,
                strength: .perfect,
                rhymeType: .geniusEcho
            )
        }
    }

    func clearScan() {
        scanTask?.cancel()
        scanTask = nil
        heldTask?.cancel()
        heldTask = nil
        heldSearchID = UUID()
        matches = []
        heldLineResult = nil
        preferGeniusTab = false
        isScanning = false
        isFilling = false
        fillingCopy = "Loading 10 more…"
        scannedDoneCount = 0
        scannedLineCount = 0
        lastScanSignature = ""
        errorMessage = nil
        searchIssue = nil
    }

    /// Hold a gutter count: first 10 wrap hits from sqlite, then tens, then records.
    /// Note BPM/key/scale is not a ranking input — the Genius vault is lyrics-only.
    func searchHeldLine(line: String, syllables: Int, priorNoteLines: [String] = []) async {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if Task.isCancelled { return }

        let searchID = UUID()
        heldSearchID = searchID
        guard !Task.isCancelled, heldSearchID == searchID else { return }
        preferGeniusTab = false
        isScanning = heldLineResult == nil
        isFilling = true
        fillingCopy = "Loading 10 more…"
        scannedDoneCount = 0
        scannedLineCount = 2
        errorMessage = nil
        searchIssue = nil
        defer {
            if heldSearchID == searchID {
                isScanning = false
                isFilling = false
                fillingCopy = "Loading 10 more…"
            }
        }

        let end = GhostSuggestionEngine.endWord(of: trimmed) ?? ""
        let window = RemindsMeOfScorer.wrapSyllableWindow(around: syllables)
        let phonetic = BarHitsCatalogStore.phoneticClass(for: end)
        let catalog = BarHitsCatalogStore.shared
        let artistFilter = Array(selectedCatalogArtists)
        lastMeaningCards = []

        var pool: [RemindsMeOfCandidate] = []
        var meaningSeedRows: [BarHitsCatalogStore.Row] = []
        var ids = Set<String>()
        func absorb(_ rows: [BarHitsCatalogStore.Row]) {
            for row in rows where ids.insert(row.id).inserted {
                pool.append(row.candidate())
            }
        }
        func absorbMeaning(_ rows: [BarHitsCatalogStore.Row]) {
            for row in rows where ids.insert(row.id).inserted {
                pool.append(row.candidate())
                meaningSeedRows.append(row)
            }
        }

        var wrapHits: [RemindsMeOfHit] = []
        var meaningHits: [RemindsMeOfHit] = []
        let trackHits: [RemindsMeOfHit] = []
        func publish() {
            guard !Task.isCancelled, heldSearchID == searchID else { return }
            heldLineResult = RemindsMeOfHeldLineResult(
                line: trimmed,
                syllables: syllables,
                wrap: wrapHits,
                meaning: meaningHits,
                tracks: trackHits,
                meaningCards: lastMeaningCards
            )
        }

        func stillCurrent() -> Bool {
            !Task.isCancelled && heldSearchID == searchID
        }

        let lower = window.lowerBound
        let upper = window.upperBound
        let endWord = end
        let phoneticClass = phonetic
        let artists = artistFilter

        // Phase 1 — wrap only. Exact end-word + phonetic family. Publish before any meaning/embedding work.
        // The sqlite read runs off the main actor so the sheet can be swiped away mid-load.
        let firstWrap = await Self.catalogRows {
            catalog?.wrapCandidates(
                syllableMin: lower,
                syllableMax: upper,
                endWord: endWord,
                phoneticClass: phoneticClass,
                nearWords: [],
                artists: artists,
                limit: 80
            ) ?? []
        }
        guard stillCurrent() else { return }
        absorb(firstWrap)
        // Artist filter must not empty wrap. Retry the same window across the whole vault.
        if pool.isEmpty, !artists.isEmpty, catalog != nil {
            let retry = await Self.catalogRows {
                catalog?.wrapCandidates(
                    syllableMin: lower,
                    syllableMax: upper,
                    endWord: endWord,
                    phoneticClass: phoneticClass,
                    nearWords: [],
                    artists: [],
                    limit: 80
                ) ?? []
            }
            guard stillCurrent() else { return }
            absorb(retry)
        }
        wrapHits = Array(RemindsMeOfScorer.wrapHits(
            from: pool,
            queryLine: trimmed,
            syllables: syllables,
            nearWords: []
        ).prefix(20))
        wrapHits = Self.tagMetaphors(wrapHits)
        publish()
        isScanning = false
        scannedDoneCount = 1
        await Task.yield()
        guard stillCurrent() else { return }

        // Phase 2 — similar meaning / imagery. Must not block wrap from staying on screen.
        fillingCopy = "Loading 10 more…"
        let tokens = SimilarMeaningPipeline.seedTokens(for: trimmed)
        let meaningRows = await Self.catalogRows {
            catalog?.meaningCandidates(tokens: tokens, artists: artists, limit: 80) ?? []
        }
        guard stillCurrent() else { return }
        absorbMeaning(meaningRows)
        meaningHits = await sameSongMeaningHits(
            queryLine: trimmed,
            priorNoteLines: priorNoteLines,
            seedRows: meaningSeedRows,
            catalog: catalog,
            limit: 12
        )
        guard stillCurrent() else { return }
        if meaningHits.isEmpty {
            let used = Set(wrapHits.map { RemindsMeOfScorer.normalizedLine($0.line) })
                .union([RemindsMeOfScorer.normalizedLine(trimmed)])
            meaningHits = Array(RemindsMeOfScorer.themeHits(
                from: pool,
                queryLine: trimmed,
                excluding: used,
                limit: 10
            ).prefix(10))
            lastMeaningCards = MetaphorBridge.shared.decorate(
                meaningHits.map { hit in
                    SimilarMeaningPipeline.ScoredCard(
                        neighborhood: SimilarMeaningPipeline.makeNeighborhood(
                            song: hit.song ?? "",
                            artist: hit.artist,
                            priorLines: [],
                            anchor: hit.line,
                            anchorId: hit.id
                        ),
                        score: hit.score
                    )
                },
                query: trimmed
            )
        }
        publish()
        await Task.yield()
        guard stillCurrent() else { return }

        fillingCopy = "Loading 10 more…"
        let nearHeads = await Self.nearRhymeHeads(for: end)
        guard stillCurrent() else { return }
        if let catalog, !nearHeads.isEmpty {
            let nearList = Array(nearHeads)
            let nearRows = await Self.catalogRows {
                catalog.wrapCandidates(
                    syllableMin: lower,
                    syllableMax: upper,
                    endWord: endWord,
                    phoneticClass: phoneticClass,
                    nearWords: nearList,
                    artists: artists,
                    limit: 40
                )
            }
            guard stillCurrent() else { return }
            absorb(nearRows)
            wrapHits = Array(RemindsMeOfScorer.wrapHits(
                from: pool,
                queryLine: trimmed,
                syllables: syllables,
                nearWords: nearHeads
            ).prefix(30))
            wrapHits = Self.tagMetaphors(wrapHits)
            if lastMeaningCards.isEmpty {
                let used = Set(wrapHits.map { RemindsMeOfScorer.normalizedLine($0.line) })
                    .union([RemindsMeOfScorer.normalizedLine(trimmed)])
                meaningHits = Array(RemindsMeOfScorer.themeHits(
                    from: pool,
                    queryLine: trimmed,
                    excluding: used,
                    limit: 10
                ).prefix(10))
            }
            publish()
        }

        scannedDoneCount = 2
        guard stillCurrent() else { return }
        publish()
    }

    /// Live Genius search — only when the Genius tab is opened.
    func searchGeniusForHeldLine() async {
        guard let held = heldLineResult else { return }
        let key = KeychainHelper.shared.getGeniusAPIKey()
        missingGeniusKey = false
        isFilling = true
        fillingCopy = "Looking up Genius…"
        defer { isFilling = false }
        let query = GeniusReferenceClient.searchQuery(forLine: held.line)
        guard !query.isEmpty else { return }
        do {
            let songs = try await GeniusReferenceClient.searchLyrics(
                query: query,
                matching: held.line,
                syllables: held.syllables,
                apiKey: key
            )
            var seen = Set<Int>()
            let tracks = songs.compactMap { song -> RemindsMeOfHit? in
                guard seen.insert(song.id).inserted else { return nil }
                return Self.lyricHit(from: song, queryLine: held.line, syllables: held.syllables)
            }
            heldLineResult = RemindsMeOfHeldLineResult(
                line: held.line,
                syllables: held.syllables,
                wrap: held.wrap,
                meaning: held.meaning,
                tracks: Array(tracks.prefix(12)),
                meaningCards: held.meaningCards
            )
        } catch {
            recordSearchFailure(error)
        }
    }

    /// Datamuse is optional. Don't block the list if it hangs.

    private func sameSongMeaningHits(
        queryLine: String,
        priorNoteLines: [String],
        seedRows: [BarHitsCatalogStore.Row],
        catalog: BarHitsCatalogStore?,
        limit: Int = 12
    ) async -> [RemindsMeOfHit] {
        guard let catalog else {
            return RemindsMeOfScorer.themeHits(
                from: seedRows.map { $0.candidate() },
                queryLine: queryLine,
                excluding: [],
                limit: limit
            )
        }
        var neighborhoods: [SimilarMeaningPipeline.Neighborhood] = []
        var seenAnchors = Set<String>()
        var songCache: [String: [BarHitsCatalogStore.Row]] = [:]
        for row in seedRows {
            if Task.isCancelled { return [] }
            await Task.yield()
            if Task.isCancelled { return [] }
            guard let song = row.song, !song.isEmpty else { continue }
            guard seenAnchors.insert(row.id).inserted else { continue }
            let cacheKey = "\(row.artist ?? "")|\(song)"
            let songRows: [BarHitsCatalogStore.Row]
            if let cached = songCache[cacheKey] {
                songRows = cached
            } else {
                let songName = song
                let artistName = row.artist
                songRows = await Self.catalogRows {
                    catalog.bars(forSong: songName, artist: artistName)
                }
                if Task.isCancelled { return [] }
                songCache[cacheKey] = songRows
            }
            guard let hood = SimilarMeaningPipeline.neighborhood(from: songRows, anchor: row) else { continue }
            neighborhoods.append(hood)
        }
        let cards = MetaphorBridge.shared.decorate(
            SimilarMeaningPipeline.score(
                inputPriorLines: priorNoteLines,
                inputAnchor: queryLine,
                candidates: neighborhoods,
                limit: limit
            ),
            query: queryLine
        )
        lastMeaningCards = cards
        return cards.map { card in
            RemindsMeOfHit(
                id: card.neighborhood.anchorId,
                line: card.neighborhood.anchor,
                artist: card.neighborhood.artist,
                song: card.neighborhood.song,
                source: .csv,
                url: nil,
                syllableCount: LineSyllableCounter.syllableCount(forLine: card.neighborhood.anchor),
                score: card.score
            )
        }
    }

    private static func nearRhymeHeads(for end: String) async -> Set<String> {
        let word = end.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else { return [] }
        return await withTaskGroup(of: Set<String>.self) { group in
            group.addTask {
                let sounds = await DatamuseRhymeClient.soundsLike(word)
                let consonants = await DatamuseRhymeClient.sameConsonants(as: word)
                return Set((sounds + consonants).map { $0.word.lowercased() }.filter { !$0.isEmpty })
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                return []
            }
            let first = await group.next() ?? []
            group.cancelAll()
            return first
        }
    }

    private static func tagMetaphors(_ hits: [RemindsMeOfHit]) -> [RemindsMeOfHit] {
        hits.map { hit in
            var tagged = hit
            tagged.metaphor = MetaphorBridge.shared.lexicalMatches(in: hit.line).first?.label
            return tagged
        }
    }

    private static func trackHit(from song: GeniusSongHit) -> RemindsMeOfHit {
        lyricHit(from: song, queryLine: song.displayLine, syllables: 0)
    }

    /// Genius lyric-search row: the matched bar is `line`, the song title stays in `song`.
    private static func lyricHit(from song: GeniusSongHit, queryLine: String, syllables: Int) -> RemindsMeOfHit {
        let bar = song.displayLine
        return RemindsMeOfHit(
            id: "genius-\(song.id)",
            line: bar,
            artist: song.artist,
            song: song.title,
            source: .genius,
            url: song.url,
            syllableCount: LineSyllableCounter.syllableCount(forLine: bar),
            score: RemindsMeOfScorer.snippetLineScore(
                bar,
                queryLine: queryLine,
                syllables: max(syllables, 1)
            )
        )
    }

    /// One Genius search per verse line. Hits paint green on the writing surface.
    func scanVerse(text: String, force: Bool = false) async {
        let key = KeychainHelper.shared.getGeniusAPIKey()
        missingGeniusKey = false

        let spans = RemindsMeOfScorer.lineSpans(in: text)
        let signature = spans.map(\.text).joined(separator: "\n")
        guard force || signature != lastScanSignature || matches.isEmpty else { return }
        lastScanSignature = signature

        isScanning = true
        scannedDoneCount = 0
        scannedLineCount = spans.count
        matches = []
        errorMessage = nil
        searchIssue = nil
        defer { isScanning = false }

        guard !spans.isEmpty else { return }

        var found: [RemindsMeOfLineMatch] = []
        for span in spans {
            if Task.isCancelled { return }
            scannedDoneCount += 1
            let query = GeniusReferenceClient.trackSearchQuery(forLine: span.text)
            guard !query.isEmpty else { continue }
            do {
                let songs = try await GeniusReferenceClient.search(query: query, apiKey: key)
                guard RemindsMeOfScorer.linePopsOnGenius(hitCount: songs.count) else { continue }
                let match = RemindsMeOfLineMatch(
                    index: span.index,
                    line: span.text,
                    location: span.location,
                    length: span.length,
                    hits: Array(songs.prefix(8))
                )
                found.append(match)
                matches = found
            } catch {
                recordSearchFailure(error)
                return
            }
        }
    }

    func refresh(text: String, bpm: Int?, syllableMin: Int?, syllableMax: Int?, force: Bool = false) async {
        let lines = RemindsMeOfScorer.queryLines(from: text)
        let signature = lines.suffix(4).joined(separator: "\n") + "|\(bpm ?? 0)"
        guard force || signature != lastSignature || groups.isEmpty else { return }
        lastSignature = signature

        isLoading = true
        errorMessage = nil
        searchIssue = nil
        defer { isLoading = false }

        guard !lines.isEmpty else {
            groups = []
            return
        }

        await loadBundledIfNeeded()

        let querySyllables = lines.map { LineSyllableCounter.syllableCount(forLine: $0) }
        let writeBPM = Int(BarClock.resolve(userBPM: bpm).bpm.rounded())
        let wrapTarget = ModelGCoreCoordinatorV4.effectiveTarget(
            min: syllableMin,
            max: syllableMax,
            bpm: writeBPM
        ) ?? (querySyllables.last ?? 8)

        let growingURL = RemindsMeOfVault.growingFileURL()
        let growing = RemindsMeOfVault.loadGrowing(from: growingURL)
        var unique: [RemindsMeOfCandidate] = []
        var ids = Set<String>()
        for row in bundled + growing where ids.insert(row.id).inserted {
            unique.append(row)
        }

        let querySet = Set(lines.map { $0.lowercased() })
        let scored = unique
            .filter { !querySet.contains($0.line.lowercased()) }
            .map { RemindsMeOfScorer.score(candidate: $0, against: lines, querySyllables: querySyllables, wrapTarget: wrapTarget) }
            .filter { $0.score >= 0.28 }
            .sorted { $0.score > $1.score }

        var top = Array(scored.prefix(24))

        let key = KeychainHelper.shared.getGeniusAPIKey()
        missingGeniusKey = false
        let q = GeniusReferenceClient.searchQuery(from: lines)
        do {
            let songs = try await GeniusReferenceClient.search(query: q, apiKey: key)
            let geniusRows = songs.map(RemindsMeOfVault.candidate(from:))
            RemindsMeOfVault.append(geniusRows, to: growingURL)
            top = merge(genius: songs, into: top, queryLines: lines, querySyllables: querySyllables, wrapTarget: wrapTarget)
        } catch {
            recordSearchFailure(error)
        }

        groups = RemindsMeOfScorer.group(top)
    }

    func clearSearchIssue() {
        searchIssue = nil
        errorMessage = nil
        missingGeniusKey = false
    }

    private func recordSearchFailure(_ error: Error) {
        let issue = RemindsMeOfCopy.searchIssue(for: error)
        searchIssue = issue
        errorMessage = issue.headline
    }

    private func loadBundledIfNeeded() async {
        guard !bundledReady else { return }
        if !EditorialGroundTruth.shared.isLoaded {
            try? await EditorialGroundTruth.shared.loadFromAppGroup()
        }
        bundled = RemindsMeOfVault.bundledCandidates()
        bundledReady = true
    }

    private func merge(
        genius songs: [GeniusSongHit],
        into hits: [RemindsMeOfHit],
        queryLines: [String],
        querySyllables: [Int],
        wrapTarget: Int
    ) -> [RemindsMeOfHit] {
        var merged = hits
        for song in songs {
            let artist = song.artist.lowercased()
            let title = song.title.lowercased()
            if let idx = merged.firstIndex(where: { hit in
                let a = hit.artist?.lowercased() ?? ""
                let s = hit.song?.lowercased() ?? ""
                return (!artist.isEmpty && a.contains(artist) && (s.contains(title) || title.contains(s)))
                    || hit.line.lowercased() == title
            }) {
                let old = merged[idx]
                merged[idx] = RemindsMeOfHit(
                    id: old.id,
                    line: old.line,
                    artist: old.artist ?? song.artist,
                    song: old.song ?? song.title,
                    source: .both,
                    url: old.url ?? song.url,
                    syllableCount: old.syllableCount,
                    score: min(1, old.score + 0.08)
                )
            } else {
                let candidate = RemindsMeOfVault.candidate(from: song)
                merged.append(
                    RemindsMeOfScorer.score(
                        candidate: candidate,
                        against: queryLines,
                        querySyllables: querySyllables,
                        wrapTarget: wrapTarget
                    )
                )
            }
        }
        return Array(merged.sorted { $0.score > $1.score }.prefix(28))
    }
}
