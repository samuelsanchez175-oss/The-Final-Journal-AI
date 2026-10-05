import Foundation

/// Datamuse is a public word API (no key). Used to fill Related / Similar sound /
/// Same consonants the way RhymeZone's extra tabs do — we don't scrape RhymeZone.
enum DatamuseRhymeClient {
    struct Hit: Decodable, Equatable {
        let word: String
        let numSyllables: Int?
    }

    static func related(to word: String) async -> [Hit] {
        await fetch(word: word, items: [URLQueryItem(name: "ml", value: word)])
    }

    static func soundsLike(_ word: String) async -> [Hit] {
        await fetch(word: word, items: [URLQueryItem(name: "sl", value: word)])
    }

    static func sameConsonants(as word: String) async -> [Hit] {
        await fetch(word: word, items: [URLQueryItem(name: "rel_cns", value: word)])
    }

    static func fetch(word: String, items: [URLQueryItem], session: URLSession = .shared) async -> [Hit] {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        var comps = URLComponents(string: "https://api.datamuse.com/words")
        var query = items
        query.append(URLQueryItem(name: "md", value: "s"))
        query.append(URLQueryItem(name: "max", value: "80"))
        comps?.queryItems = query
        guard let url = comps?.url else { return [] }
        do {
            let (data, _) = try await session.data(from: url)
            return try JSONDecoder().decode([Hit].self, from: data)
                .filter { RhymeFinder.isUsableRhymeHeadword($0.word) || $0.word.contains(" ") }
        } catch {
            return []
        }
    }
}
