import Foundation

/// Phase 2: claimed tracks → their bars. Spotify is the map. Genius snippets + paste are the gold.
/// Does not scrape HTML. Does not ingest related-artist lyrics. Features stay out unless included.
enum ArtistLyricIngest {
    static let maxSongs = 20
    static let maxBarsPerSong = 24

    static func artistMatches(hitArtist: String, catalogArtist: String, songArtist: String) -> Bool {
        let hit = folded(hitArtist)
        let catalog = folded(catalogArtist)
        let song = folded(songArtist)
        if catalog.count >= 3, hit.contains(catalog) || catalog.contains(hit) { return true }
        if song.count >= 3, hit.contains(song) || song.contains(hit) { return true }
        return false
    }

    static func titleMatches(hitTitle: String, songTitle: String) -> Bool {
        let hit = folded(hitTitle)
        let song = folded(songTitle)
        guard hit.count >= 4, song.count >= 4 else { return hit == song && !hit.isEmpty }
        return hit == song || hit.contains(song) || song.contains(hit)
    }

    static func barsFromSnippet(_ snippet: String, songTitle: String) -> [String] {
        let cleaned = snippet
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
        var seen = Set<String>()
        var bars: [String] = []
        for raw in cleaned.components(separatedBy: .newlines) {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            guard !RemindsMeOfScorer.isSnippetNoise(line) else { continue }
            guard RemindsMeOfScorer.isLyricBar(line) else { continue }
            guard !RemindsMeOfScorer.isTitleLeak(line, song: songTitle) else { continue }
            let key = RemindsMeOfScorer.normalizedLine(line)
            guard seen.insert(key).inserted else { continue }
            bars.append(line)
            if bars.count >= maxBarsPerSong { break }
        }
        return bars
    }

    static func barsFromPaste(_ text: String, songTitle: String) -> [String] {
        barsFromSnippet(text, songTitle: songTitle)
    }

    static func chunks(
        fromLyricSearch data: Data,
        song: ArtistSong,
        catalogArtist: String
    ) throws -> [ArtistBrainChunk] {
        let hits = try GeniusReferenceClient.parseLyricSearch(data: data)
        return chunks(fromHits: hits, song: song, catalogArtist: catalogArtist)
    }

    static func chunks(
        fromHits hits: [GeniusLyricHit],
        song: ArtistSong,
        catalogArtist: String
    ) -> [ArtistBrainChunk] {
        guard song.included else { return [] }
        var bars: [ArtistBrainChunk] = []
        var seen = Set<String>()
        for hit in hits {
            guard artistMatches(hitArtist: hit.artist, catalogArtist: catalogArtist, songArtist: song.primaryArtist) else {
                continue
            }
            guard titleMatches(hitTitle: hit.title, songTitle: song.title) else { continue }
            for line in barsFromSnippet(hit.snippet, songTitle: song.title) {
                let key = RemindsMeOfScorer.normalizedLine(line)
                guard seen.insert(key).inserted else { continue }
                bars.append(makeBar(
                    text: line,
                    song: song,
                    sourceURL: hit.url,
                    ingestSource: "genius"
                ))
                if bars.count >= maxBarsPerSong { return bars }
            }
        }
        return bars
    }

    static func chunks(fromPaste text: String, song: ArtistSong) -> [ArtistBrainChunk] {
        guard song.included else { return [] }
        return barsFromPaste(text, songTitle: song.title).map { line in
            makeBar(text: line, song: song, sourceURL: nil, ingestSource: "paste")
        }
    }

    static func merge(
        _ existing: [ArtistBrainChunk],
        with incoming: [ArtistBrainChunk],
        replacingSongId songId: String
    ) -> [ArtistBrainChunk] {
        existing.filter { $0.songId != songId } + incoming
    }

    static func prune(_ bars: [ArtistBrainChunk], includedSongIDs: Set<String>) -> [ArtistBrainChunk] {
        bars.filter { bar in
            guard let id = bar.songId else { return false }
            return includedSongIDs.contains(id)
        }
    }

    static func makeBar(
        text: String,
        song: ArtistSong,
        sourceURL: URL?,
        ingestSource: String
    ) -> ArtistBrainChunk {
        ArtistBrainChunk(
            kind: .lyricBar,
            text: text,
            songId: song.id,
            songTitle: song.title,
            sourceURL: sourceURL?.absoluteString,
            ingestSource: ingestSource
        )
    }

    static func ingestQuery(artistName: String, songTitle: String) -> String {
        "\(artistName) \(songTitle)"
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Live Genius lyric search for claimed tracks only. Tests use the fixture parsers above.
    /// One song at a time so the You tab can save as it goes and stay responsive.
    static func ingestIncludedSongs(
        _ songs: [ArtistSong],
        catalogArtist: String,
        apiKey: String?,
        session: URLSession = .shared,
        onSong: (@Sendable (ArtistSong, [ArtistBrainChunk], Int, Int) async -> Void)? = nil
    ) async -> [ArtistBrainChunk] {
        let claimed = Array(songs.filter(\.included).prefix(maxSongs))
        var collected: [ArtistBrainChunk] = []
        for (index, song) in claimed.enumerated() {
            if Task.isCancelled { break }
            let query = ingestQuery(artistName: catalogArtist, songTitle: song.title)
            var songBars: [ArtistBrainChunk] = []
            if !query.isEmpty {
                do {
                    let hits = try await GeniusReferenceClient.searchLyricHits(
                        query: query,
                        apiKey: apiKey,
                        session: session
                    )
                    songBars = chunks(fromHits: hits, song: song, catalogArtist: catalogArtist)
                    collected.append(contentsOf: songBars)
                } catch {
                    songBars = []
                }
            }
            if let onSong {
                await onSong(song, songBars, index + 1, claimed.count)
            }
            await Task.yield()
        }
        return collected
    }

    private static func folded(_ raw: String) -> String {
        raw.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
    }
}
