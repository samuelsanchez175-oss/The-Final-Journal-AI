import Foundation
import Combine

/// Persistent Free Ghost end-word index biased by claimed catalog lyrics.
/// Stores word + phones + rhyme class + artist/song + wrap syllables.
/// Rebuilds when the on-device catalog changes; never pastes full bars.
struct CatalogEndWordEntry: Codable, Equatable, Identifiable, Sendable {
    var id: String { "\(artistId)|\(songId)|\(word)|\(wrapSyllables)" }
    var word: String
    var phones: [String]
    var rhymeClass: String
    var artistId: String
    var songId: String
    var wrapSyllables: Int
}

@MainActor
final class CatalogEndWordIndex: ObservableObject {
    static let shared = CatalogEndWordIndex()
    static let storageName = "CatalogEndWordIndex-v1.json"

    @Published private(set) var entries: [CatalogEndWordEntry] = []
    @Published private(set) var lastBuiltAt: Date?
    @Published private(set) var isBuilding = false

    /// Nonisolated mirror for GhostSuggestionEngine (Free Ghost) lookups.
    nonisolated(unsafe) private static var snapshotByClass: [String: [CatalogEndWordEntry]] = [:]
    nonisolated(unsafe) private static var snapshotLock = NSLock()

    private var byRhymeClass: [String: [CatalogEndWordEntry]] = [:]

    private init() {
        load()
        if entries.isEmpty {
            Task { await rebuildIfNeeded(force: true) }
        }
    }

    nonisolated static func normalizedClass(_ raw: String) -> String {
        raw.uppercased().filter { $0.isLetter || $0.isWhitespace }
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    func words(matchingRhymeClass rhymeClass: String, wrapSyllables: Int?, limit: Int = 40) -> [String] {
        Self.pickWords(from: byRhymeClass, rhymeClass: rhymeClass, wrapSyllables: wrapSyllables, limit: limit)
    }

    func rebuildIfNeeded(force: Bool = false) async {
        if isBuilding { return }
        if !force, !entries.isEmpty, let last = lastBuiltAt, Date().timeIntervalSince(last) < 3600 {
            return
        }
        isBuilding = true
        defer { isBuilding = false }

        let built: [CatalogEndWordEntry] = await Task.detached(priority: .utility) {
            Self.scanCatalog()
        }.value

        entries = built
        reindex()
        lastBuiltAt = Date()
        save()
    }

    private func reindex() {
        var map: [String: [CatalogEndWordEntry]] = [:]
        for e in entries {
            let key = Self.normalizedClass(e.rhymeClass)
            guard !key.isEmpty else { continue }
            map[key, default: []].append(e)
            if e.rhymeClass != key {
                map[e.rhymeClass, default: []].append(e)
            }
        }
        byRhymeClass = map
        Self.snapshotLock.lock()
        Self.snapshotByClass = map
        Self.snapshotLock.unlock()
    }

    /// Safe for Free Ghost pool building off the main actor.
    nonisolated static func snapshotWords(matchingRhymeClass rhymeClass: String, wrapSyllables: Int?, limit: Int = 40) -> [String] {
        snapshotLock.lock()
        let map = snapshotByClass
        snapshotLock.unlock()
        return pickWords(from: map, rhymeClass: rhymeClass, wrapSyllables: wrapSyllables, limit: limit)
    }

    /// Wrap is a preference, not a gate — same-class catalog landings still follow.
    nonisolated private static func pickWords(
        from map: [String: [CatalogEndWordEntry]],
        rhymeClass: String,
        wrapSyllables: Int?,
        limit: Int
    ) -> [String] {
        let raw = rhymeClass.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return [] }
        let norm = normalizedClass(raw)
        var pool = map[raw] ?? []
        if let extra = map[norm] {
            pool.append(contentsOf: extra)
        }
        var preferred: [CatalogEndWordEntry] = []
        var rest: [CatalogEndWordEntry] = []
        if let wrap = wrapSyllables {
            let window = max(1, wrap - 1)...(wrap + 2)
            for row in pool {
                if window.contains(row.wrapSyllables) { preferred.append(row) }
                else { rest.append(row) }
            }
        } else {
            preferred = pool
        }
        var seen = Set<String>()
        var out: [String] = []
        for row in preferred + rest {
            let w = row.word.lowercased()
            guard seen.insert(w).inserted else { continue }
            out.append(row.word)
            if out.count >= limit { break }
        }
        return out
    }

    private nonisolated static func scanCatalog() -> [CatalogEndWordEntry] {
        guard let store = BarHitsCatalogStore.shared else { return [] }
        var rows: [CatalogEndWordEntry] = []
        var seen = Set<String>()
        for hit in store.sampleEndWordRows(perArtist: 80, artistLimit: 80) {
            let word = hit.endWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard word.count >= 2 else { continue }
            let klass = hit.phoneticClass.isEmpty
                ? BarHitsCatalogStore.phoneticClass(for: word)
                : hit.phoneticClass
            guard !klass.isEmpty else { continue }
            let artist = hit.artist ?? ""
            let key = "\(klass)|\(word)|\(artist)"
            guard seen.insert(key).inserted else { continue }
            let phones = getGlobalCMUDICTStore()[word]
                ?? RapSlangPhonemes.phonemes(for: word)
                ?? klass.split(separator: " ").map(String.init)
            rows.append(
                CatalogEndWordEntry(
                    word: word,
                    phones: phones,
                    rhymeClass: klass,
                    artistId: artist,
                    songId: hit.song ?? hit.id,
                    wrapSyllables: hit.syllables
                )
            )
        }
        return rows
    }

    private func save() {
        guard let url = Self.fileURL() else { return }
        do {
            let payload = PersistPayload(builtAt: lastBuiltAt ?? Date(), entries: entries)
            let data = try JSONEncoder().encode(payload)
            try data.write(to: url, options: .atomic)
        } catch {
            print("CatalogEndWordIndex save failed: \(error)")
        }
    }

    private func load() {
        guard let url = Self.fileURL(),
              let data = try? Data(contentsOf: url),
              let payload = try? JSONDecoder().decode(PersistPayload.self, from: data) else { return }
        entries = payload.entries
        lastBuiltAt = payload.builtAt
        reindex()
    }

    private static func fileURL() -> URL? {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        guard let dir else { return nil }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(storageName)
    }

    private struct PersistPayload: Codable {
        var builtAt: Date
        var entries: [CatalogEndWordEntry]
    }
}
