import Foundation

/// Last eight successful noun inserts, newest first. UserDefaults-backed.
enum NounBankRecents {
    static let defaultsKey = "nounBank.recents"
    static let cap = 8

    private struct Record: Codable, Equatable {
        var word: String
        var category: String
    }

    static var items: [(word: String, category: NounBankCategory)] {
        liveEntries()
    }

    static func record(word: String, category: NounBankCategory) {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var next = liveEntries()
        next.removeAll {
            $0.word.localizedCaseInsensitiveCompare(trimmed) == .orderedSame
        }
        next.insert((trimmed, category), at: 0)
        if next.count > cap {
            next = Array(next.prefix(cap))
        }
        save(next)
    }

    /// Drops entries whose category or word is no longer in the catalog.
    private static func liveEntries() -> [(word: String, category: NounBankCategory)] {
        load().compactMap { rec in
            guard let category = NounBankCategory(rawValue: rec.category) else { return nil }
            let stillThere = NounBankCatalog.items(for: category).contains {
                $0.insertWord.localizedCaseInsensitiveCompare(rec.word) == .orderedSame
            }
            guard stillThere else { return nil }
            return (rec.word, category)
        }
    }

    private static func load() -> [Record] {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([Record].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func save(_ items: [(word: String, category: NounBankCategory)]) {
        let records = items.map { Record(word: $0.word, category: $0.category.rawValue) }
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
