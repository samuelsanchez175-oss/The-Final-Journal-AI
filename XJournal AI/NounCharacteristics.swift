import Foundation

/// Traits for a noun chip, from NounCharacteristics.json.
/// A row is [category, noun, bullets] or [category, noun, bullets, [line, artist, song]].
/// The fourth slot is the signature quote. It is not a bullet.
/// A noun with no lyric row keeps the bullets already in the file.
enum NounCharacteristics {
    struct Signature {
        let line: String
        let artist: String
        let song: String
    }

    static func bullets(category: NounBankCategory, word: String) -> [String] {
        table[key(category.rawValue, word)]?.bullets ?? []
    }

    static func signature(category: NounBankCategory, word: String) -> Signature? {
        table[key(category.rawValue, word)]?.signature
    }

    private struct Entry {
        var bullets: [String]
        var signature: Signature?
    }

    private static func key(_ category: String, _ word: String) -> String {
        category + "\u{1f}" + word
    }

    private static let table: [String: Entry] = {
        guard let url = Bundle.main.url(forResource: "NounCharacteristics", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rows = try? JSONSerialization.jsonObject(with: data) as? [Any] else {
            return [:]
        }
        var table: [String: Entry] = [:]
        table.reserveCapacity(rows.count)
        for row in rows {
            guard let parts = row as? [Any],
                  parts.count == 3 || parts.count == 4,
                  let category = parts[0] as? String,
                  let noun = parts[1] as? String,
                  let bullets = parts[2] as? [String] else { continue }
            var signature: Signature?
            if parts.count == 4,
               let quote = parts[3] as? [String],
               quote.count == 3,
               !quote[0].isEmpty,
               !quote[1].isEmpty,
               !quote[2].isEmpty {
                signature = Signature(line: quote[0], artist: quote[1], song: quote[2])
            }
            guard !bullets.isEmpty || signature != nil else { continue }
            table[key(category, noun)] = Entry(bullets: bullets, signature: signature)
        }
        return table
    }()
}
