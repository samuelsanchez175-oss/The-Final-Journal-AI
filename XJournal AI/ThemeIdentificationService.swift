import Foundation

// MARK: - Theme Identification (keyword + optional AI — identification only, no lyric generation)

enum ThemeIdentificationService {
    struct Result {
        let themeIDs: Set<String>
        let detectedNames: [String]
        let keywordMatches: [ThemeCatalog.MatchResult]
        let aiMatchedIDs: Set<String>
        let source: Source

        enum Source: String {
            case keywords
            case ai
            case combined
        }
    }

    /// Keyword-only identification (fast, works offline).
    static func identifyFromKeywords(in text: String) -> Result {
        let matches = ThemeCatalog.matchThemes(in: text)
        let ids = Set(matches.map(\.id))
        return Result(
            themeIDs: ids,
            detectedNames: matches.map(\.theme.name),
            keywordMatches: matches,
            aiMatchedIDs: [],
            source: .keywords
        )
    }

    /// Keyword match first, then AI supplement for themes keywords may miss.
    static func identify(in text: String, useAI: Bool = true) async -> Result {
        let keywordResult = identifyFromKeywords(in: text)
        guard useAI, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return keywordResult
        }

        do {
            let aiIDs = try await RapSuggestionAPI.shared.identifyThemesFromLyrics(
                text: text,
                availableThemes: ThemeCatalog.all
            )
            let combined = keywordResult.themeIDs.union(aiIDs)
            let aiOnly = aiIDs.subtracting(keywordResult.themeIDs)
            let names = ThemeCatalog.all
                .filter { combined.contains($0.id) }
                .map(\.name)

            return Result(
                themeIDs: combined,
                detectedNames: names,
                keywordMatches: keywordResult.keywordMatches,
                aiMatchedIDs: aiOnly,
                source: aiOnly.isEmpty ? .keywords : (keywordResult.themeIDs.isEmpty ? .ai : .combined)
            )
        } catch {
            return keywordResult
        }
    }

    /// Convenience for ContentView — returns display names only.
    static func detectedThemeNames(in text: String) -> [String] {
        identifyFromKeywords(in: text).detectedNames
    }

    static func matchedThemeIDs(in text: String) -> Set<String> {
        identifyFromKeywords(in: text).themeIDs
    }
}
