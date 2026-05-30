//
//  ThemeContextBuilder.swift
//  XJournal AI
//
//  Theme-aware generation context for Model G. Detects the journal entry's dominant theme
//  from the 232-theme taxonomy (NewRapDatabase), attaches its jargon palette, emotional tone,
//  and an in-theme few-shot example, and biases detection by the user's journaling taste.
//  This is what makes Model G draw on the curated theme/jargon data instead of a one-word topic.
//

import Foundation

// MARK: - Theme Context (injected into the Model G prompt)

struct ThemeContext: Codable {
    let themeName: String
    let emotionalTone: String
    let jargonPalette: [String]   // theme-appropriate slang/brands to weave in
    let example: String?          // few-shot anchor line in this theme's style
}

// MARK: - Theme Taste Tracker  (the "create taste" goal)

/// Counts which taxonomy themes the user journals about so detection can lean toward
/// their taste over time. Backed by UserDefaults. Separate from `TasteMemory`
/// (which tracks accept/reject of individual suggestions).
final class ThemeTasteTracker {
    static let shared = ThemeTasteTracker()
    private let key = "model_g_theme_taste_counts"
    private init() {}

    private var counts: [String: Int] {
        get { (UserDefaults.standard.dictionary(forKey: key) as? [String: Int]) ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    func record(_ theme: String) {
        let t = theme.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        var c = counts
        c[t, default: 0] += 1
        counts = c
    }

    /// Up to +0.3 score bonus for the user's most-journaled themes.
    func weight(for theme: String) -> Double {
        let c = counts
        guard let n = c[theme], let maxN = c.values.max(), maxN > 0 else { return 0 }
        return 0.3 * (Double(n) / Double(maxN))
    }

    var favoriteTheme: String? {
        counts.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Theme Example Store  (few-shot anchors)

/// Loads one curated in-theme example line per theme category from `theme_examples.csv`.
final class ThemeExampleStore {
    static let shared = ThemeExampleStore()
    private var byCategory: [String: String] = [:]
    private var loaded = false
    private init() {}

    func example(forTheme theme: String) -> String? {
        loadIfNeeded()
        return byCategory[theme.lowercased()]
    }

    private func loadIfNeeded() {
        guard !loaded else { return }
        loaded = true
        guard let url = Bundle.main.url(forResource: "theme_examples", withExtension: "csv"),
              let raw = try? String(contentsOf: url, encoding: .utf8) else { return }
        let rows = ThemeExampleStore.parseCSV(raw)
        guard rows.count > 1 else { return }
        // header: Theme Category, Common Jargon / Brands, Meaning & Cultural Context, Rap Lyric Example
        for row in rows.dropFirst() where row.count >= 4 {
            let category = row[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let example = row[3]
                .trimmingCharacters(in: CharacterSet(charactersIn: " \""))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !category.isEmpty && !example.isEmpty {
                byCategory[category.lowercased()] = example
            }
        }
    }

    /// Minimal RFC-4180-ish parser: handles quoted fields and quoted newlines.
    static func parseCSV(_ raw: String) -> [[String]] {
        var rows: [[String]] = []
        var field = ""
        var row: [String] = []
        var inQuotes = false
        let chars = Array(raw)
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c == "\"" {
                if inQuotes, i + 1 < chars.count, chars[i + 1] == "\"" {
                    field.append("\"")
                    i += 1
                } else {
                    inQuotes.toggle()
                }
            } else if c == ",", !inQuotes {
                row.append(field); field = ""
            } else if (c == "\n" || c == "\r"), !inQuotes {
                if c == "\r", i + 1 < chars.count, chars[i + 1] == "\n" { i += 1 }
                row.append(field); field = ""
                rows.append(row); row = []
            } else {
                field.append(c)
            }
            i += 1
        }
        if !field.isEmpty || !row.isEmpty {
            row.append(field); rows.append(row)
        }
        return rows
    }
}

// MARK: - Theme Context Builder

enum ThemeContextBuilder {
    /// Detect the entry's dominant theme and build the Model G theme context.
    /// Always-on but accuracy-preserving: best content match → taste favorite → none.
    static func build(from entry: String, record: Bool = true) -> ThemeContext? {
        let text = entry.lowercased()
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let themes = NewRapDatabase.shared.themes
        guard !themes.isEmpty else { return nil }

        func score(_ t: Theme) -> Double {
            var s = 0.0
            for term in t.jargonTerms {
                let cleaned = term.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if cleaned.count > 2, text.contains(cleaned) { s += 3 }
            }
            for token in t.name.lowercased().split(separator: " ").map(String.init) where token.count > 3 {
                if text.contains(token) { s += 2 }
            }
            for token in t.contextDescription.lowercased()
                .split(whereSeparator: { !$0.isLetter }).map(String.init) where token.count > 4 {
                if text.contains(token) { s += 0.25 }
            }
            return s + ThemeTasteTracker.shared.weight(for: t.name)
        }

        var best: Theme?
        var bestScore = 0.0
        for t in themes {
            let sc = score(t)
            if sc > bestScore { bestScore = sc; best = t }
        }

        let chosen: Theme?
        if let b = best, bestScore > 0 {
            chosen = b
        } else if let fav = ThemeTasteTracker.shared.favoriteTheme {
            chosen = themes.first { $0.name == fav }   // fall back to what the user usually writes
        } else {
            chosen = nil                                // no signal — don't fabricate a theme
        }
        guard let theme = chosen else { return nil }

        if record { ThemeTasteTracker.shared.record(theme.name) }

        let palette = theme.jargonTerms
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 1 }
            .prefix(8)

        return ThemeContext(
            themeName: theme.name,
            emotionalTone: theme.emotionalTone,
            jargonPalette: Array(palette),
            example: ThemeExampleStore.shared.example(forTheme: theme.name)
        )
    }
}
