import Foundation

/// One lightbulb hit from the bundled rhyme index.
struct RhymeIndexHit: Sendable, Equatable {
    let word: String
    let count: Int
    let exampleBar: String
    let song: String
}

/// Loads `RhymeIndex/rhyme_index.json` and `artists.json` off the main thread.
/// The XJournal AI folder is the app target's synchronized group, so both files
/// are bundle resources. This type does not rewrite those files.
nonisolated final class RhymeIndexStore: @unchecked Sendable {
    static let shared = RhymeIndexStore()

    private let queue = DispatchQueue(label: "penwork.rhyme-index", qos: .userInitiated)
    private let lock = NSLock()
    private var artistMap: [String: [String: [RhymeIndexHit]]] = [:]
    private var allArtists: [String: [RhymeIndexHit]] = [:]
    private var names: [String] = []
    private var indexReady = false
    private var namesReady = false

    private init() {}

    /// Artist display names from artists.json, in file order.
    func artistNames() async -> [String] {
        await withCheckedContinuation { continuation in
            queue.async {
                self.loadNamesIfNeeded()
                self.lock.lock()
                let copy = self.names
                self.lock.unlock()
                continuation.resume(returning: copy)
            }
        }
    }

    /// Blocks the caller until the index has been read once. Call off the main thread.
    func load() async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.loadIndexIfNeeded()
                continuation.resume()
            }
        }
    }

    /// `artist == nil` reads the "All artists" map. Empty when the key is absent or the file is not loaded.
    func suggestions(for key: String, artist: String?) -> [RhymeIndexHit] {
        lock.lock()
        defer { lock.unlock() }
        guard indexReady else { return [] }
        let table = artist == nil ? allArtists : (artistMap[artist ?? ""] ?? [:])
        return table[key] ?? []
    }

    private func loadNamesIfNeeded() {
        lock.lock()
        let ready = namesReady
        lock.unlock()
        guard !ready else { return }
        let decoded = Self.readArtists()
        lock.lock()
        names = decoded
        namesReady = true
        lock.unlock()
    }

    private func loadIndexIfNeeded() {
        lock.lock()
        let ready = indexReady
        lock.unlock()
        guard !ready else { return }
        let parsed = Self.readIndex()
        lock.lock()
        artistMap = parsed.artists
        allArtists = parsed.all
        if names.isEmpty {
            names = parsed.artists.keys.sorted()
        }
        indexReady = true
        lock.unlock()
    }

    private static func bundleURL(name: String) -> URL? {
        let bundle = Bundle.main
        return bundle.url(forResource: name, withExtension: "json", subdirectory: "RhymeIndex")
            ?? bundle.url(forResource: name, withExtension: "json", subdirectory: "Resources/RhymeIndex")
            ?? bundle.url(forResource: name, withExtension: "json")
    }

    private static func readArtists() -> [String] {
        guard let url = bundleURL(name: "artists"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(ArtistFile.self, from: data) else {
            return []
        }
        return file.artists.map(\.name)
    }

    private static func readIndex() -> (artists: [String: [String: [RhymeIndexHit]]], all: [String: [RhymeIndexHit]]) {
        guard let url = bundleURL(name: "rhyme_index"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(IndexFile.self, from: data) else {
            return ([:], [:])
        }
        return (file.artists.mapValues(Self.hits), Self.hits(file.all))
    }

    private static func hits(_ table: [String: [IndexWord]]) -> [String: [RhymeIndexHit]] {
        table.mapValues { words in
            words.map {
                RhymeIndexHit(word: $0.word, count: $0.count, exampleBar: $0.bar, song: $0.song)
            }
        }
    }

    private struct ArtistFile: Decodable {
        struct Row: Decodable { let name: String }
        let artists: [Row]
    }

    private struct IndexWord: Decodable {
        let word: String
        let count: Int
        let bar: String
        let song: String
    }

    private struct IndexFile: Decodable {
        let artists: [String: [String: [IndexWord]]]
        let all: [String: [IndexWord]]

        enum CodingKeys: String, CodingKey {
            case artists
            case all = "All artists"
        }
    }
}

/// Lightbulb lookup. Dictionary work stays off the main thread. Artist hits use endGroupKey, then each word's rime.
enum RhymeLightbulbSearch {
    static let suggestionCap = 12

    struct Request: Sendable {
        let id: UUID
        let key: String
        let words: [String]
    }

    struct Chip: Sendable, Equatable, Identifiable {
        let word: String
        let count: Int
        let exampleBar: String
        let song: String
        var id: String { word.lowercased() }
    }

    struct Result: Sendable {
        let chips: [UUID: [Chip]]
        let label: String
    }

    static func run(source: String, requests: [Request], textWords: [String]) async -> Result {
        let dictionarySource = source == "Dictionary"
        let artist: String? = source == "All artists" ? nil : source
        if !dictionarySource {
            await RhymeIndexStore.shared.load()
        }
        var chips: [UUID: [Chip]] = [:]
        var artistHits = 0
        var fallbacks = 0
        let dict = dictionarySource ? await dictionary() : [:]
        for request in requests {
            if Task.isCancelled { break }
            if dictionarySource {
                chips[request.id] = dictionaryChips(for: request, textWords: textWords, dict: dict)
                continue
            }
            let found = artistChips(for: request, artist: artist)
            if found.isEmpty {
                let filled = dictionaryChips(for: request, textWords: textWords, dict: await dictionary())
                chips[request.id] = filled
                if !filled.isEmpty { fallbacks += 1 }
            } else {
                chips[request.id] = found
                artistHits += 1
            }
        }
        return Result(chips: chips, label: label(source: source, artistHits: artistHits, fallbacks: fallbacks))
    }

    private static func label(source: String, artistHits: Int, fallbacks: Int) -> String {
        if source == "Dictionary" { return "Dictionary" }
        if artistHits == 0 && fallbacks > 0 {
            return "\(source) has none. Dictionary."
        }
        if fallbacks > 0 {
            return "\(source) · Dictionary where empty"
        }
        return source
    }

    private static func artistChips(for request: Request, artist: String?) -> [Chip] {
        let skip = Set(request.words.map { $0.lowercased() })
        var best: [String: RhymeIndexHit] = [:]
        func absorb(_ hits: [RhymeIndexHit]) {
            for hit in hits {
                let key = hit.word.lowercased()
                guard key.count >= 2, !skip.contains(key) else { continue }
                if let existing = best[key], existing.count >= hit.count { continue }
                best[key] = hit
            }
        }
        absorb(RhymeIndexStore.shared.suggestions(for: request.key, artist: artist))
        if best.isEmpty {
            for word in request.words {
                guard let rime = rimeKey(for: word) else { continue }
                absorb(RhymeIndexStore.shared.suggestions(for: rime, artist: artist))
            }
        }
        return best.values.sorted { lhs, rhs in
            if lhs.count != rhs.count { return lhs.count > rhs.count }
            return lhs.word.localizedStandardCompare(rhs.word) == .orderedAscending
        }
        .prefix(suggestionCap)
        .map { Chip(word: $0.word, count: $0.count, exampleBar: $0.exampleBar, song: $0.song) }
    }

    /// Phonetic rime (`PhoneticSignature.rimeKey`), after the same phoneme path the highlighter uses.
    private static func rimeKey(for word: String) -> String? {
        guard let phonemes = RhymeHighlighterEngine.phonemes(for: word),
              let signature = RhymeHighlighterEngine.extractSignature(from: phonemes) else {
            return nil
        }
        return signature.rimeKey
    }

    private static func dictionaryChips(
        for request: Request,
        textWords: [String],
        dict: [String: [String]]
    ) -> [Chip] {
        guard let first = request.words.first,
              let phonemes = RhymeHighlighterEngine.phonemes(for: first),
              let signature = RhymeHighlighterEngine.extractSignature(from: phonemes) else {
            return []
        }
        let skip = Set(textWords.map { $0.lowercased() }).union(request.words.map { $0.lowercased() })
        var perfect: [String] = []
        var near: [String] = []
        for word in dict.keys.sorted() {
            if skip.contains(word) { continue }
            guard let phones = dict[word],
                  let wordSignature = RhymeHighlighterEngine.extractSignature(from: phones),
                  let strength = RhymeHighlighterEngine.rhymeScore(signature, wordSignature) else {
                continue
            }
            switch strength {
            case .perfect:
                perfect.append(word.capitalized)
                if perfect.count == suggestionCap { break }
            case .near:
                near.append(word.capitalized)
            case .slant:
                continue
            }
        }
        let room = suggestionCap - perfect.count
        let filled = perfect + (room > 0 ? Array(near.prefix(room)) : [])
        return filled.map { Chip(word: $0, count: 0, exampleBar: "", song: "") }
    }

    private static func dictionary() async -> [String: [String]] {
        let first = FJCMUDICTStore.shared.phonemesByWord
        if !first.isEmpty { return first }
        preloadGlobalCMUDICTStore()
        for _ in 0..<100 {
            if Task.isCancelled { return [:] }
            try? await Task.sleep(nanoseconds: 100_000_000)
            let snap = FJCMUDICTStore.shared.phonemesByWord
            if !snap.isEmpty { return snap }
        }
        return FJCMUDICTStore.shared.phonemesByWord
    }
}
