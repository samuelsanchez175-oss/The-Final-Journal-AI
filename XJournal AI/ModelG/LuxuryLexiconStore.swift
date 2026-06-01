//
//  LuxuryLexiconStore.swift
//  XJournal AI
//
//  Model G Core v1.0 — Luxury lexicon storage and sampling models.
//

import Foundation

enum SignalVolume: String, Codable {
    case loud
    case subtle
    case mixed
}

enum LuxuryLexiconCategory: String, Codable, CaseIterable {
    case brand
    case spec
    case environment
    case provenance
    case archive
}

enum LuxuryLexiconVolume: String, Codable {
    case loud
    case subtle
    case both

    func matches(_ signalVolume: SignalVolume) -> Bool {
        switch (self, signalVolume) {
        case (.both, _):
            return true
        case (.loud, .loud):
            return true
        case (.subtle, .subtle):
            return true
        case (.loud, .mixed), (.subtle, .mixed):
            return true
        default:
            return false
        }
    }
}

struct LuxuryLexiconEntry: Codable {
    let category: LuxuryLexiconCategory
    let term: String
    let objectType: String?
    let volume: LuxuryLexiconVolume
    let styleHint: String?
}

struct LuxuryLayer: Codable, Equatable {
    let brands: [String]
    let specs: [String]
    let environments: [String]
    let provenance: [String]
    let archives: [String]

    static let empty = LuxuryLayer(
        brands: [],
        specs: [],
        environments: [],
        provenance: [],
        archives: []
    )

    var allTerms: [String] {
        brands + specs + environments + provenance + archives
    }
}

final class LuxuryLexiconStore {
    static let shared = LuxuryLexiconStore()

    private(set) var entries: [LuxuryLexiconEntry] = []

    private init() {
        loadEntries()
    }

    func sample(
        category: LuxuryLexiconCategory,
        volume: SignalVolume,
        styleHint: String?,
        limit: Int
    ) -> [String] {
        guard limit > 0 else { return [] }
        let styleHintLower = styleHint?.lowercased()
        let filtered = entries.filter { entry in
            guard entry.category == category else { return false }
            guard entry.volume.matches(volume) else { return false }
            guard let styleHintLower else { return true }
            guard let entryStyle = entry.styleHint?.lowercased(), !entryStyle.isEmpty else { return true }
            return entryStyle.contains(styleHintLower) || styleHintLower.contains(entryStyle)
        }

        var unique: [String] = []
        var seen = Set<String>()
        for entry in filtered {
            let normalized = entry.term.lowercased()
            if !normalized.isEmpty && !seen.contains(normalized) {
                seen.insert(normalized)
                unique.append(entry.term)
            }
        }
        return Array(unique.prefix(limit))
    }

    private func loadEntries() {
        if let path = Bundle.main.path(forResource: "luxury_lexicon", ofType: "csv"),
           let csv = try? String(contentsOfFile: path, encoding: .utf8) {
            let parsed = parseCSV(csv)
            if !parsed.isEmpty {
                entries = parsed
                return
            }
        }
        entries = defaultEntries()
    }

    private func parseCSV(_ csv: String) -> [LuxuryLexiconEntry] {
        let rows = csv.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard rows.count > 1 else { return [] }

        let header = parseCSVLine(rows[0]).map { $0.lowercased() }
        let categoryIndex = header.firstIndex(of: "category")
        let termIndex = header.firstIndex(of: "term")
        let objectTypeIndex = header.firstIndex(of: "object_type")
        let volumeIndex = header.firstIndex(of: "volume")
        let styleHintIndex = header.firstIndex(of: "style_hint")

        guard let categoryIndex, let termIndex, let volumeIndex else {
            return []
        }

        var result: [LuxuryLexiconEntry] = []
        for row in rows.dropFirst() {
            let columns = parseCSVLine(row)
            guard columns.indices.contains(categoryIndex),
                  columns.indices.contains(termIndex),
                  columns.indices.contains(volumeIndex) else {
                continue
            }

            let categoryRaw = columns[categoryIndex].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let term = columns[termIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            let volumeRaw = columns[volumeIndex].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard let category = LuxuryLexiconCategory(rawValue: categoryRaw),
                  let volume = LuxuryLexiconVolume(rawValue: volumeRaw),
                  !term.isEmpty else {
                continue
            }

            let objectType = objectTypeIndex.flatMap { idx in
                columns.indices.contains(idx) ? columns[idx].trimmingCharacters(in: .whitespacesAndNewlines) : nil
            }
            let styleHint = styleHintIndex.flatMap { idx in
                columns.indices.contains(idx) ? columns[idx].trimmingCharacters(in: .whitespacesAndNewlines) : nil
            }

            result.append(
                LuxuryLexiconEntry(
                    category: category,
                    term: term,
                    objectType: objectType?.isEmpty == true ? nil : objectType,
                    volume: volume,
                    styleHint: styleHint?.isEmpty == true ? nil : styleHint
                )
            )
        }
        return result
    }

    private func parseCSVLine(_ line: String) -> [String] {
        var values: [String] = []
        var current = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                values.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        values.append(current)
        return values
    }

    private func defaultEntries() -> [LuxuryLexiconEntry] {
        [
            .init(category: .brand, term: "Rolex", objectType: "watch", volume: .loud, styleHint: "ColdTrap"),
            .init(category: .brand, term: "Audemars Piguet", objectType: "watch", volume: .loud, styleHint: "DarkAggressiveTrap"),
            .init(category: .brand, term: "Patek", objectType: "watch", volume: .loud, styleHint: "LuxuryCinematicTrap"),
            .init(category: .brand, term: "Richard Mille", objectType: "watch", volume: .loud, styleHint: "DarkAggressiveTrap"),
            .init(category: .spec, term: "plain jane", objectType: "watch", volume: .subtle, styleHint: "LuxuryCinematicTrap"),
            .init(category: .spec, term: "bust down", objectType: "watch", volume: .loud, styleHint: "DarkAggressiveTrap"),
            .init(category: .spec, term: "50K face", objectType: "watch", volume: .both, styleHint: nil),
            .init(category: .spec, term: "V12", objectType: "car", volume: .both, styleHint: nil),
            .init(category: .environment, term: "penthouse", objectType: nil, volume: .both, styleHint: "LuxuryCinematicTrap"),
            .init(category: .environment, term: "valet lane", objectType: nil, volume: .loud, styleHint: "DarkAggressiveTrap"),
            .init(category: .environment, term: "private terminal", objectType: nil, volume: .both, styleHint: nil),
            .init(category: .provenance, term: "copped at the source", objectType: nil, volume: .both, styleHint: nil),
            .init(category: .provenance, term: "gifted from day one", objectType: nil, volume: .subtle, styleHint: nil),
            .init(category: .provenance, term: "archive pull", objectType: nil, volume: .subtle, styleHint: "LuxuryCinematicTrap"),
            .init(category: .archive, term: "Y2K cut", objectType: nil, volume: .subtle, styleHint: "LuxuryCinematicTrap"),
            .init(category: .archive, term: "pre-season sample", objectType: nil, volume: .both, styleHint: nil)
        ]
    }
}
