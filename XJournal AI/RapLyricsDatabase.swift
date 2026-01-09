import Foundation
import Combine

// MARK: - Data Models

struct RapLine: Codable, Identifiable, Hashable {
    let id: String // text_id from CSV
    let text: String
    let artist: String?
    let song: String?
    let album: String?
    let syllableCount: Int
    let rhymeWord: String?
    let rhymeClass: String?
    let primaryTone: String
    let secondaryTone: String?
    let themeID: String? // Links to Theme CSV
    let phoneticEnding: String?
    let phoneticRhymeClass: String?
    let year: Int?
    let context: String?
    
    // For semantic search
    var embedding: [Float]? = nil
}

struct Theme: Codable, Identifiable, Hashable {
    let id: String // THEME_ID
    let name: String
    let jargonTerms: [String]
    let contextDescription: String
    let relatedThemes: [String]
    let emotionalTone: String
}

// MARK: - Rap Lyrics Database

class RapLyricsDatabase: ObservableObject {
    static let shared = RapLyricsDatabase()
    
    @Published var lyrics: [RapLine] = []
    @Published var themes: [Theme] = []
    @Published var isLoading: Bool = false
    @Published var isLoaded: Bool = false
    
    private let appGroupID = "group.com.finaljournal.app"
    
    private init() {}
    
    // MARK: - CSV Loading
    
    func loadFromAppGroup() async throws {
        await MainActor.run {
            isLoading = true
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
                isLoaded = true
            }
        }
        
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            throw RapDatabaseError.containerNotFound
        }
        
        let themesURL = containerURL.appendingPathComponent("2.0 THEME_CSV_AI_BRAIN_with_THEME_ID.csv")
        let lyricsURL = containerURL.appendingPathComponent("2.0 REAL_LYRICS_AI_with_THEME_ID_reference.csv")
        
        // Check if files exist, if not, copy from bundle
        if !FileManager.default.fileExists(atPath: themesURL.path) {
            try await copyCSVFromBundleIfNeeded(filename: "2.0 THEME_CSV_AI_BRAIN_with_THEME_ID.csv", to: themesURL)
        }
        
        if !FileManager.default.fileExists(atPath: lyricsURL.path) {
            try await copyCSVFromBundleIfNeeded(filename: "2.0 REAL_LYRICS_AI_with_THEME_ID_reference.csv", to: lyricsURL)
        }
        
        // Parse themes
        let themesData = try Data(contentsOf: themesURL)
        let parsedThemes = try parseThemesCSV(data: themesData)
        
        // Parse lyrics
        let lyricsData = try Data(contentsOf: lyricsURL)
        let parsedLyrics = try parseLyricsCSV(data: lyricsData)
        
        await MainActor.run {
            self.themes = parsedThemes
            self.lyrics = parsedLyrics
        }
    }
    
    private func copyCSVFromBundleIfNeeded(filename: String, to destination: URL) async throws {
        // First try to copy from Desktop (for development)
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: desktopURL.path) {
            try FileManager.default.copyItem(at: desktopURL, to: destination)
            return
        }
        
        // Fallback: try app bundle
        guard let bundleURL = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".csv", with: ""), withExtension: "csv") else {
            throw RapDatabaseError.fileNotFound(filename)
        }
        
        try FileManager.default.copyItem(at: bundleURL, to: destination)
    }
    
    // MARK: - CSV Parsing
    
    private func parseThemesCSV(data: Data) throws -> [Theme] {
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw RapDatabaseError.invalidEncoding
        }
        
        let lines = csvString.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            throw RapDatabaseError.emptyFile
        }
        
        // Parse header
        let header = lines[0].components(separatedBy: ",")
        guard header.count >= 6 else {
            throw RapDatabaseError.invalidFormat
        }
        
        var themes: [Theme] = []
        
        for (index, line) in lines.enumerated() {
            guard index > 0, !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            
            // Handle CSV with quoted fields that may contain commas
            let components = parseCSVLine(line)
            guard components.count >= 6 else { continue }
            
            let themeID = components[0].trimmingCharacters(in: .whitespaces)
            let themeName = components[1].trimmingCharacters(in: .whitespaces)
            
            // Skip empty rows
            if themeID.isEmpty || themeName.isEmpty || themeID == "THEME_ID" {
                continue
            }
            
            // Parse jargon terms (comma-separated, may be quoted)
            let jargonString = components[2].trimmingCharacters(in: .whitespaces)
            let jargonTerms = jargonString
                .replacingOccurrences(of: "\"", with: "")
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            let contextDescription = components[3].trimmingCharacters(in: .whitespaces)
            
            // Parse related themes (comma-separated)
            let relatedThemesString = components[4].trimmingCharacters(in: .whitespaces)
            let relatedThemes = relatedThemesString
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            let emotionalTone = components[5].trimmingCharacters(in: .whitespaces)
            
            let theme = Theme(
                id: themeID,
                name: themeName,
                jargonTerms: jargonTerms,
                contextDescription: contextDescription,
                relatedThemes: relatedThemes,
                emotionalTone: emotionalTone
            )
            
            themes.append(theme)
        }
        
        return themes
    }
    
    private func parseLyricsCSV(data: Data) throws -> [RapLine] {
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw RapDatabaseError.invalidEncoding
        }
        
        let lines = csvString.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            throw RapDatabaseError.emptyFile
        }
        
        var rapLines: [RapLine] = []
        
        for (index, line) in lines.enumerated() {
            guard index > 0, !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            
            // Handle CSV with quoted fields
            let components = parseCSVLine(line)
            guard components.count >= 29 else { continue }
            
            let textID = components[0].trimmingCharacters(in: .whitespaces)
            guard !textID.isEmpty, textID != "text_id" else { continue }
            
            let artist = components[1].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[1].trimmingCharacters(in: .whitespaces)
            let song = components[2].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[2].trimmingCharacters(in: .whitespaces)
            let album = components[3].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[3].trimmingCharacters(in: .whitespaces)
            let text = components[6].trimmingCharacters(in: .whitespaces)
            
            guard !text.isEmpty else { continue }
            
            // Parse syllable count (use syllable_count_recalc if available, fallback to syllable_count)
            let syllableCountRecalc = Int(components[10].trimmingCharacters(in: .whitespaces)) ?? 0
            let syllableCount = Int(components[23].trimmingCharacters(in: .whitespaces)) ?? syllableCountRecalc
            
            let rhymeWord = components[13].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[13].trimmingCharacters(in: .whitespaces)
            let rhymeClass = components[14].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[14].trimmingCharacters(in: .whitespaces)
            let primaryTone = components[16].trimmingCharacters(in: .whitespaces).isEmpty ? "confident" : components[16].trimmingCharacters(in: .whitespaces)
            let secondaryTone = components[17].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[17].trimmingCharacters(in: .whitespaces)
            let year = Int(components[22].trimmingCharacters(in: .whitespaces))
            let context = components[24].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[24].trimmingCharacters(in: .whitespaces)
            let phoneticEnding = components[25].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[25].trimmingCharacters(in: .whitespaces)
            let phoneticRhymeClass = components[26].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[26].trimmingCharacters(in: .whitespaces)
            let themeID = components[28].trimmingCharacters(in: .whitespaces).isEmpty ? nil : components[28].trimmingCharacters(in: .whitespaces)
            
            let rapLine = RapLine(
                id: textID,
                text: text,
                artist: artist,
                song: song,
                album: album,
                syllableCount: syllableCount,
                rhymeWord: rhymeWord,
                rhymeClass: rhymeClass,
                primaryTone: primaryTone,
                secondaryTone: secondaryTone,
                themeID: themeID,
                phoneticEnding: phoneticEnding,
                phoneticRhymeClass: phoneticRhymeClass,
                year: year,
                context: context
            )
            
            rapLines.append(rapLine)
        }
        
        return rapLines
    }
    
    // MARK: - CSV Line Parser (handles quoted fields with commas)
    
    private func parseCSVLine(_ line: String) -> [String] {
        var components: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                components.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        // Add the last field
        if !currentField.isEmpty || line.last == "," {
            components.append(currentField)
        }
        
        return components
    }
    
    // MARK: - Query Methods
    
    func getTheme(by id: String) -> Theme? {
        themes.first { $0.id == id }
    }
    
    func getLyrics(by themeID: String) -> [RapLine] {
        lyrics.filter { $0.themeID == themeID }
    }
    
    func searchLyricsByTheme(_ themeNames: [String]) -> [RapLine] {
        let matchingThemeIDs = themes.filter { theme in
            themeNames.contains { name in
                theme.name.localizedCaseInsensitiveContains(name) ||
                theme.jargonTerms.contains { $0.localizedCaseInsensitiveContains(name) }
            }
        }.map { $0.id }
        
        return lyrics.filter { line in
            if let themeID = line.themeID {
                return matchingThemeIDs.contains(themeID)
            }
            return false
        }
    }
}

// MARK: - Errors

enum RapDatabaseError: LocalizedError {
    case containerNotFound
    case fileNotFound(String)
    case invalidEncoding
    case emptyFile
    case invalidFormat
    
    var errorDescription: String? {
        switch self {
        case .containerNotFound:
            return "App Group container not found"
        case .fileNotFound(let filename):
            return "CSV file not found: \(filename)"
        case .invalidEncoding:
            return "Invalid CSV encoding"
        case .emptyFile:
            return "CSV file is empty"
        case .invalidFormat:
            return "Invalid CSV format"
        }
    }
}
