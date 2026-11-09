import Foundation

/// Sourced bullets for a noun chip, from NounCharacteristics.json.
/// The noun page shows these where the short description used to sit.
enum NounCharacteristics {
    static func bullets(category: NounBankCategory, word: String) -> [String] {
        table[key(category.rawValue, word)] ?? []
    }

    private static func key(_ category: String, _ word: String) -> String {
        category + "\u{1f}" + word
    }

    private static let table: [String: [String]] = {
        guard let url = Bundle.main.url(forResource: "NounCharacteristics", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rows = try? JSONSerialization.jsonObject(with: data) as? [Any] else {
            return [:]
        }
        var table: [String: [String]] = [:]
        table.reserveCapacity(rows.count)
        for row in rows {
            guard let parts = row as? [Any],
                  parts.count == 3,
                  let category = parts[0] as? String,
                  let noun = parts[1] as? String,
                  let bullets = parts[2] as? [String],
                  !bullets.isEmpty else { continue }
            table[key(category, noun)] = bullets
        }
        return table
    }()
}
