import Foundation

nonisolated enum RemindsMeOfVault: Sendable {
    static let filename = "reminds_me_of_vault.csv"

    static func growingFileURL(fileManager: FileManager = .default) -> URL {
        if let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.finaljournal.app") {
            return container.appendingPathComponent(filename)
        }
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(filename)
    }

    static func loadGrowing(from url: URL) -> [RemindsMeOfCandidate] {
        guard let data = try? Data(contentsOf: url),
              let text = String(data: data, encoding: .utf8) else { return [] }
        return parse(text)
    }

    static func append(_ rows: [RemindsMeOfCandidate], to url: URL) {
        var existing = loadGrowing(from: url)
        var seen = Set(existing.map(\.id))
        var added = false
        for row in rows where seen.insert(row.id).inserted {
            existing.append(row)
            added = true
        }
        guard added else { return }
        let dir = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try? serialize(existing).write(to: url, atomically: true, encoding: .utf8)
    }

    @MainActor
    static func bundledCandidates() -> [RemindsMeOfCandidate] {
        var rows: [RemindsMeOfCandidate] = []
        if EditorialGroundTruth.shared.isLoaded {
            rows += EditorialGroundTruth.shared.groundTruthBars.compactMap(candidate(from:))
        }
        if let store = ModelGCorpusStore.shared {
            rows += store.corpus.bars.compactMap(candidate(from:))
        }
        return rows
    }

    static func candidate(from bar: GroundTruthBar) -> RemindsMeOfCandidate? {
        let line = bar.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard RemindsMeOfScorer.isLyricBar(line) else { return nil }
        return RemindsMeOfCandidate(
            id: "csv-\(bar.id)",
            line: line,
            artist: bar.artist,
            song: bar.song,
            syllableCount: LineSyllableCounter.syllableCount(forLine: line),
            source: .csv,
            geniusID: nil,
            url: nil
        )
    }

    static func candidate(from bar: CorpusBar) -> RemindsMeOfCandidate? {
        let line = bar.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard RemindsMeOfScorer.isLyricBar(line) else { return nil }
        return RemindsMeOfCandidate(
            id: "corpus-\(bar.id)",
            line: line,
            artist: bar.artist ?? bar.activeArtist,
            song: bar.song,
            syllableCount: LineSyllableCounter.syllableCount(forLine: line),
            source: .csv,
            geniusID: nil,
            url: nil
        )
    }

    static func candidate(from song: GeniusSongHit) -> RemindsMeOfCandidate {
        let line = song.displayLine
        return RemindsMeOfCandidate(
            id: "genius-\(song.id)-\(RemindsMeOfScorer.normalizedLine(line))",
            line: line,
            artist: song.artist,
            song: song.title,
            syllableCount: LineSyllableCounter.syllableCount(forLine: line),
            source: .genius,
            geniusID: song.id,
            url: song.url
        )
    }

    static func parse(_ csv: String) -> [RemindsMeOfCandidate] {
        let lines = csv.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard let header = lines.first else { return [] }
        let cols = splitCSVLine(header).map { $0.lowercased() }
        func idx(_ names: String...) -> Int? {
            cols.firstIndex { names.contains($0) }
        }
        let idI = idx("id") ?? 0
        let lineI = idx("line", "text", "bar") ?? 1
        let artistI = idx("artist")
        let songI = idx("song")
        let sylI = idx("syllables", "syllablecount", "syllable_count")
        let sourceI = idx("source")
        let geniusI = idx("genius_id", "geniusid")
        let urlI = idx("url")

        var rows: [RemindsMeOfCandidate] = []
        for raw in lines.dropFirst() where !raw.trimmingCharacters(in: .whitespaces).isEmpty {
            let c = splitCSVLine(raw)
            func at(_ i: Int?) -> String? {
                guard let i, i < c.count else { return nil }
                let v = c[i].trimmingCharacters(in: .whitespaces)
                return v.isEmpty ? nil : v
            }
            let line = at(lineI) ?? ""
            guard !line.isEmpty else { continue }
            let source = RemindsMeOfSource(rawValue: at(sourceI) ?? "csv") ?? .csv
            if source != .genius, !RemindsMeOfScorer.isLyricBar(line) { continue }
            rows.append(
                RemindsMeOfCandidate(
                    id: at(idI) ?? line,
                    line: line,
                    artist: at(artistI),
                    song: at(songI),
                    syllableCount: at(sylI).flatMap(Int.init) ?? LineSyllableCounter.syllableCount(forLine: line),
                    source: source,
                    geniusID: at(geniusI).flatMap(Int.init),
                    url: at(urlI).flatMap(URL.init(string:))
                )
            )
        }
        return rows
    }

    static func serialize(_ rows: [RemindsMeOfCandidate]) -> String {
        var out = "id,line,artist,song,syllables,source,genius_id,url\n"
        for row in rows {
            let fields = [
                row.id,
                row.line,
                row.artist ?? "",
                row.song ?? "",
                String(row.syllableCount),
                row.source.rawValue,
                row.geniusID.map(String.init) ?? "",
                row.url?.absoluteString ?? ""
            ]
            out += fields.map(escape).joined(separator: ",") + "\n"
        }
        return out
    }

    private static func escape(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }

    static func splitCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var quoted = false
        for char in line {
            if char == "\"" {
                quoted.toggle()
            } else if char == "," && !quoted {
                fields.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current)
        return fields
    }
}
