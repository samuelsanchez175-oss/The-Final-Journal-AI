import Foundation

/// Local store of solved Cadence Ghost setups. Same comma-breath should not hit the network twice.
/// Seeded with pre-trialed flips so the first comma still has chips before catalog/AI return.
nonisolated final class CadenceGhostCache: @unchecked Sendable {
    static let shared = CadenceGhostCache()
    static let filename = "CadenceGhostCache-v1.json"

    struct CachedPunch: Codable, Sendable, Equatable {
        var text: String
        var artist: String?
        var song: String?
    }

    struct SeedPunch: Sendable, Equatable, Codable {
        var text: String
        var artist: String?
        var song: String?
    }

    struct Entry: Codable, Sendable {
        var punches: [CachedPunch]
        var updatedAt: Date
        var solved: Bool
        var preferred: String?
        enum CodingKeys: String, CodingKey { case punches, updatedAt, solved, preferred }
        init(punches: [CachedPunch], updatedAt: Date, solved: Bool, preferred: String? = nil) {
            self.punches = punches
            self.updatedAt = updatedAt
            self.solved = solved
            self.preferred = preferred
        }
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            if let rich = try? c.decode([CachedPunch].self, forKey: .punches) {
                punches = rich
            } else {
                let texts = (try? c.decode([String].self, forKey: .punches)) ?? []
                punches = texts.map { CachedPunch(text: $0, artist: nil, song: nil) }
            }
            updatedAt = try c.decode(Date.self, forKey: .updatedAt)
            solved = try c.decodeIfPresent(Bool.self, forKey: .solved) ?? true
            preferred = try c.decodeIfPresent(String.self, forKey: .preferred)
        }
        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(punches, forKey: .punches)
            try c.encode(updatedAt, forKey: .updatedAt)
            try c.encode(solved, forKey: .solved)
            try c.encodeIfPresent(preferred, forKey: .preferred)
        }
    }

    private let lock = NSLock()
    private var map: [String: Entry] = [:]
    private let storageURL: URL?

    private init() {
        storageURL = Self.defaultFileURL()
        load()
    }

    init(storageURL: URL?) {
        self.storageURL = storageURL
        load()
    }

    /// Apostrophes fold so "don't" and "dont" share a cache key.
    static func normalize(_ setup: String) -> String {
        setup.lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: "‘", with: "")
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    static func key(setup: String, wrap: Int) -> String {
        "\(wrap)|\(normalize(setup))"
    }

    /// Famous setup → punch pairs that ship with the app. Wrap is applied at lookup.
    static let seedBySetup: [String: [SeedPunch]] = [
        "i dont need a bitch": [
            SeedPunch(text: "i'm what a bitch needs", artist: "The Weeknd", song: "The Hills"),
            SeedPunch(text: "i'm what a bitch need", artist: "Tory Lanez", song: "Staccato"),
            SeedPunch(text: "what a bitch needs", artist: "The Weeknd", song: "The Hills"),
        ],
        "i dont need nobody": [
            SeedPunch(text: "nobody needs me like i need me", artist: nil, song: nil),
            SeedPunch(text: "i already got me", artist: nil, song: nil),
        ],
        "i aint never been the type": [
            SeedPunch(text: "i been the type they write about", artist: nil, song: nil),
        ],
        "im standing ten toes": [
            SeedPunch(text: "hoes know how i let it go", artist: nil, song: nil),
            SeedPunch(text: "hoes know i never fold", artist: nil, song: nil),
        ],
        "i am standing ten toes": [
            SeedPunch(text: "hoes know how i let it go", artist: nil, song: nil),
        ],
    ]

    private static let bundledSeeds: [String: [SeedPunch]] = {
        let bundle = Bundle.main
        let url = bundle.url(forResource: "CadenceGhostSeed", withExtension: "json")
            ?? bundle.url(forResource: "CadenceGhostSeed", withExtension: "json", subdirectory: "ModelG/Ghost")
        guard let url,
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [SeedPunch]].self, from: data)
        else { return [:] }
        return decoded
    }()

    static func seedRecords(for setup: String) -> [SeedPunch] {
        let norm = normalize(setup)
        if let exact = seedBySetup[norm] { return exact }
        if let bundled = bundledSeeds[norm], !bundled.isEmpty { return bundled }
        if let prefix = seedBySetup.first(where: { norm.hasPrefix($0.key) || $0.key.hasPrefix(norm) })?.value {
            return prefix
        }
        return bundledSeeds.first { norm.hasPrefix($0.key) || $0.key.hasPrefix(norm) }?.value ?? []
    }

    static func seedPunches(for setup: String) -> [String] {
        seedRecords(for: setup).map(\.text)
    }

    /// Persisted solve first, then wrap ±1, then bundled seed. `solved` is true only for disk hits.
    func punches(for setup: String, wrap: Int) -> (punches: [String], solved: Bool, preferred: String?)? {
        lock.lock()
        defer { lock.unlock() }
        let wraps = [wrap, wrap - 1, wrap + 1, wrap - 2, wrap + 2].filter { $0 > 0 }
        var seen = Set<String>()
        var merged: [String] = []
        var solved = false
        var preferred: String?
        for w in wraps {
            let k = Self.key(setup: setup, wrap: w)
            guard let entry = map[k] else { continue }
            if entry.solved { solved = true }
            if preferred == nil { preferred = entry.preferred }
            for p in entry.punches {
                let key = p.text.lowercased()
                guard seen.insert(key).inserted, !p.text.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
                merged.append(p.text)
            }
        }
        if merged.isEmpty {
            let seed = Self.seedPunches(for: setup)
            let fitted = seed.filter {
                abs(LineSyllableCounter.syllableCount(forLine: $0) - max(wrap, 1)) <= 2
            }
            let picks = fitted.isEmpty ? seed : fitted
            return picks.isEmpty ? nil : (picks, false, preferred)
        }
        if let preferred {
            merged.removeAll { CadenceGhostCache.normalize($0) == CadenceGhostCache.normalize(preferred) }
            merged.insert(preferred, at: 0)
            seen.insert(preferred.lowercased())
        }
        for p in Self.seedPunches(for: setup) where seen.insert(p.lowercased()).inserted {
            merged.insert(p, at: preferred == nil ? 0 : 1)
        }
        return (Array(merged.prefix(32)), solved, preferred)
    }

    func chips(for setup: String, wrap: Int) -> (chips: [GhostPunchChip], solved: Bool, preferred: String?)? {
        guard let hit = punches(for: setup, wrap: wrap) else { return nil }
        lock.lock()
        var artistByText: [String: (String?, String?)] = [:]
        for w in [wrap, wrap - 1, wrap + 1] where w > 0 {
            if let entry = map[Self.key(setup: setup, wrap: w)] {
                for p in entry.punches {
                    artistByText[p.text.lowercased()] = (p.artist, p.song)
                }
            }
        }
        lock.unlock()
        for seed in Self.seedRecords(for: setup) {
            if artistByText[seed.text.lowercased()] == nil {
                artistByText[seed.text.lowercased()] = (seed.artist, seed.song)
            }
        }
        var chips = hit.punches.map { text in
            GhostPunchChip(
                text: text,
                syllables: LineSyllableCounter.syllableCount(forLine: text),
                targetWrap: wrap,
                artist: artistByText[text.lowercased()]?.0,
                song: artistByText[text.lowercased()]?.1,
                preferred: hit.preferred.map { Self.normalize($0) == Self.normalize(text) } ?? false
            )
        }
        chips = GhostSuggestionEngine.collapsePunchDupes(chips)
        if let preferred = hit.preferred {
            chips.sort {
                let a = Self.normalize($0.text) == Self.normalize(preferred)
                let b = Self.normalize($1.text) == Self.normalize(preferred)
                if a != b { return a }
                return false
            }
        }
        return (chips, hit.solved, hit.preferred)
    }

    func store(_ punches: [String], setup: String, wrap: Int, solved: Bool = true) {
        store(
            punches.map { GhostPunchChip(text: $0, syllables: 0, targetWrap: wrap, artist: nil, song: nil, preferred: false) },
            setup: setup,
            wrap: wrap,
            solved: solved
        )
    }

    func store(_ punches: [GhostPunchChip], setup: String, wrap: Int, solved: Bool = true) {
        let cleaned = punches
            .map { CachedPunch(text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines), artist: $0.artist, song: $0.song) }
            .filter { $0.text.split(whereSeparator: \.isWhitespace).count >= 2 }
        guard !cleaned.isEmpty else { return }
        let k = Self.key(setup: setup, wrap: wrap)
        lock.lock()
        var merged = map[k]?.punches ?? []
        var seen = Set(merged.map { $0.text.lowercased() })
        for p in cleaned where seen.insert(p.text.lowercased()).inserted {
            merged.append(p)
        }
        let alreadySolved = map[k]?.solved ?? false
        let preferred = map[k]?.preferred
        map[k] = Entry(
            punches: Array(merged.prefix(32)),
            updatedAt: Date(),
            solved: alreadySolved || solved,
            preferred: preferred
        )
        let snapshot = map
        lock.unlock()
        save(snapshot)
    }

    /// The punch the writer tapped. Leads the dock the next time this setup+wrap appears.
    func prefer(_ punch: String, setup: String, wrap: Int) {
        let cleaned = punch.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.split(whereSeparator: \.isWhitespace).count >= 2 else { return }
        store([cleaned], setup: setup, wrap: wrap, solved: true)
        let k = Self.key(setup: setup, wrap: wrap)
        lock.lock()
        if var entry = map[k] {
            entry.preferred = cleaned
            entry.solved = true
            if !entry.punches.contains(where: { $0.text.lowercased() == cleaned.lowercased() }) {
                entry.punches.insert(CachedPunch(text: cleaned, artist: nil, song: nil), at: 0)
            }
            map[k] = entry
        }
        let snapshot = map
        lock.unlock()
        save(snapshot)
    }

    private func load() {
        guard let url = storageURL,
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: Entry].self, from: data)
        else { return }
        lock.lock()
        map = decoded
        lock.unlock()
    }

    private func save(_ snapshot: [String: Entry]) {
        guard let url = storageURL else { return }
        DispatchQueue.global(qos: .utility).async {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            try? data.write(to: url, options: .atomic)
        }
    }

    private static func defaultFileURL() -> URL? {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(filename)
    }
}
