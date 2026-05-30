import Foundation
import Combine

// MARK: - New Rap Database
// This class loads the three new CSV files:
// 1. ground_truth_rap_bars_MODEL_G.csv - Real rap lyrics from Gunna
// 2. jargon_Authority_Lexicon_phrases + brands.v2.csv - Rap music jargon
// 3. behavioral control layer grammar governor themes.csv - Themes for AI pipeline

class NewRapDatabase: ObservableObject {
    static let shared = NewRapDatabase()
    
    // MARK: - Published Properties
    @Published private(set) var groundTruthBars: [GroundTruthBar] = []
    @Published private(set) var lexiconTerms: [LexiconTerm] = []
    @Published private(set) var themes: [Theme] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoaded: Bool = false
    
    // MARK: - File Names
    private let groundTruthFilename = "ground_truth_rap_bars_MODEL_G.csv"
    private let lexiconFilename = "jargon_authority_lexicon_v8.csv"
    private let themeFilename = "behavioral control layer grammar governor themes.csv"
    
    private let appGroupID = "group.com.finaljournal.app"
    
    private init() {}
    
    // MARK: - Load All CSV Files
    
    func loadAllCSVs() async throws {
        await MainActor.run {
            isLoading = true
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
                isLoaded = true
            }
        }
        
        // Load ground truth bars
        try await loadGroundTruthBars()
        
        // Load lexicon
        try await loadLexicon()
        
        // Load themes
        try await loadThemes()
        
        print("✅ NewRapDatabase: Loaded \(groundTruthBars.count) ground truth bars, \(lexiconTerms.count) lexicon terms, \(themes.count) themes")
    }
    
    // MARK: - Load Ground Truth Bars
    
    private func loadGroundTruthBars() async throws {
        let csvData = try await loadCSVFile(filename: groundTruthFilename)
        groundTruthBars = try parseGroundTruthCSV(csvData: csvData)
    }
    
    // MARK: - Load Lexicon
    
    private func loadLexicon() async throws {
        let csvData = try await loadCSVFile(filename: lexiconFilename)
        lexiconTerms = try parseLexiconCSV(csvData: csvData)
    }
    
    // MARK: - Load Themes
    
    private func loadThemes() async throws {
        let csvData = try await loadCSVFile(filename: themeFilename)
        themes = try parseThemeCSV(csvData: csvData)
    }
    
    // MARK: - CSV File Loading
    
    private func loadCSVFile(filename: String) async throws -> String {
        // Try app group first
        if let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) {
            let fileURL = containerURL.appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let data = try? Data(contentsOf: fileURL),
                   let content = String(data: data, encoding: .utf8) {
                    return content
                }
            }
        }
        
        // Try bundle
        if let bundleURL = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".csv", with: ""), withExtension: "csv") {
            if let data = try? Data(contentsOf: bundleURL),
               let content = String(data: data, encoding: .utf8) {
                return content
            }
        }
        
        // Try direct path in XJournal AI directory
        let projectPath = "/Users/samuel/Documents/The Final Journal AI/XJournal AI/\(filename)"
        if FileManager.default.fileExists(atPath: projectPath) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: projectPath)),
               let content = String(data: data, encoding: .utf8) {
                return content
            }
        }
        
        throw DatabaseError.fileNotFound(filename)
    }
    
    // MARK: - CSV Parsing
    
    private func parseGroundTruthCSV(csvData: String) throws -> [GroundTruthBar] {
        let lines = csvData.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }
        
        guard !lines.isEmpty else {
            throw DatabaseError.invalidFormat
        }
        
        let header = lines[0]
        let headerColumns = parseCSVLine(header)
        var columnIndices: [String: Int] = [:]
        
        for (index, column) in headerColumns.enumerated() {
            let normalized = column.lowercased().replacingOccurrences(of: " ", with: "_")
            columnIndices[normalized] = index
        }
        
        var bars: [GroundTruthBar] = []
        
        for line in lines.dropFirst() {
            let columns = parseCSVLine(line)
            guard columns.count >= 2 else { continue }
            
            let id = columns[columnIndices["id"] ?? 0]
            let text = columns[columnIndices["text"] ?? 1]
            let artist = columns[safe: columnIndices["artist"] ?? -1]
            let song = columns[safe: columnIndices["song"] ?? -1]
            let year = columns[safe: columnIndices["year"] ?? -1].flatMap { Int($0) }
            let signalMode = columns[safe: columnIndices["signal_mode"] ?? -1]
            let culturalContext = columns[safe: columnIndices["cultural_context"] ?? -1]
            
            // Parse register and axis profiles if present
            var registerProfile: RegisterProfile? = nil
            var axisProfile: AxisProfile? = nil
            
            if let registerData = columns[safe: columnIndices["register_profile"] ?? -1] {
                // Parse register profile JSON if present
                if let data = registerData.data(using: .utf8),
                   let profile = try? JSONDecoder().decode(RegisterProfile.self, from: data) {
                    registerProfile = profile
                }
            }
            
            if let axisData = columns[safe: columnIndices["axis_profile"] ?? -1] {
                // Parse axis profile JSON if present
                if let data = axisData.data(using: .utf8),
                   let profile = try? JSONDecoder().decode(AxisProfile.self, from: data) {
                    axisProfile = profile
                }
            }
            
            let bar = GroundTruthBar(
                id: id,
                text: text,
                artist: artist?.isEmpty == false ? artist : nil,
                song: song?.isEmpty == false ? song : nil,
                year: year,
                signalMode: signalMode?.isEmpty == false ? signalMode : nil,
                registerProfile: registerProfile,
                axisProfile: axisProfile,
                culturalContext: culturalContext?.isEmpty == false ? culturalContext : nil
            )
            
            bars.append(bar)
        }
        
        return bars
    }
    
    private func parseLexiconCSV(csvData: String) throws -> [LexiconTerm] {
        // The lexicon is already handled by RapAuthorityLexicon.shared
        // This method is kept for consistency but the lexicon loading
        // should be done through RapAuthorityLexicon directly
        // We'll integrate with it by ensuring the CSV is available
        return []
    }
    
    private func parseThemeCSV(csvData: String) throws -> [Theme] {
        let lines = csvData.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }
        
        guard !lines.isEmpty else {
            throw DatabaseError.invalidFormat
        }
        
        let header = lines[0]
        let headerColumns = parseCSVLine(header)
        var columnIndices: [String: Int] = [:]
        
        for (index, column) in headerColumns.enumerated() {
            let normalized = column.lowercased().replacingOccurrences(of: " ", with: "_")
            columnIndices[normalized] = index
        }
        
        var themes: [Theme] = []
        
        for line in lines.dropFirst() {
            let columns = parseCSVLine(line)
            guard columns.count >= 2 else { continue }
            
            let id = columns[columnIndices["theme_id"] ?? columnIndices["id"] ?? 0]
            let name = columns[columnIndices["name"] ?? columnIndices["theme_name"] ?? 1]
            let jargonTermsStr = columns[safe: columnIndices["jargon_terms"] ?? -1] ?? ""
            let jargonTerms = jargonTermsStr.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            let contextDescription = columns[safe: columnIndices["context_description"] ?? columnIndices["description"] ?? -1] ?? ""
            
            let relatedThemesStr = columns[safe: columnIndices["related_themes"] ?? -1] ?? ""
            let relatedThemes = relatedThemesStr.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            let emotionalTone = columns[safe: columnIndices["emotional_tone"] ?? columnIndices["tone"] ?? -1] ?? "neutral"
            
            let theme = Theme(
                id: id,
                name: name,
                jargonTerms: jargonTerms,
                contextDescription: contextDescription,
                relatedThemes: relatedThemes,
                emotionalTone: emotionalTone
            )
            
            themes.append(theme)
        }
        
        return themes
    }
    
    // MARK: - Helper Methods
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current.trimmingCharacters(in: .whitespaces))
        return result
    }
    
    // MARK: - Errors
    
    enum DatabaseError: LocalizedError {
        case fileNotFound(String)
        case invalidFormat
        case parseError(String)
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let filename):
                return "CSV file not found: \(filename)"
            case .invalidFormat:
                return "Invalid CSV format"
            case .parseError(let message):
                return "Parse error: \(message)"
            }
        }
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
