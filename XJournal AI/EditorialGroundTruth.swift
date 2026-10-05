import Foundation
import Combine

// MARK: - Ground Truth Rap Bar
// Represents a proven rap bar from the cultural conscience CSV

nonisolated struct GroundTruthBar: Codable, Identifiable {
    let id: String
    let text: String
    let artist: String?
    let song: String?
    let year: Int?
    
    // Signal/register/axis data (if present in CSV)
    let signalMode: String?
    let registerProfile: RegisterProfile?
    let axisProfile: AxisProfile?
    let culturalContext: String?
    
    nonisolated init(id: String, text: String, artist: String? = nil, song: String? = nil, year: Int? = nil, signalMode: String? = nil, registerProfile: RegisterProfile? = nil, axisProfile: AxisProfile? = nil, culturalContext: String? = nil) {
        self.id = id
        self.text = text
        self.artist = artist
        self.song = song
        self.year = year
        self.signalMode = signalMode
        self.registerProfile = registerProfile
        self.axisProfile = axisProfile
        self.culturalContext = culturalContext
    }
}

// MARK: - Editorial Ground Truth
// Cultural conscience - remembers what has worked in the world

class EditorialGroundTruth: ObservableObject {
    static let shared = EditorialGroundTruth()
    
    @Published private(set) var groundTruthBars: [GroundTruthBar] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoaded: Bool = false
    
    private let appGroupID = "group.com.finaljournal.app"
    private let csvFilename = "ground_truth_rap_bars_MODEL_G.csv"
    
    private init() {}
    
    // MARK: - CSV Loading
    
    /// Load ground truth CSV from app group container or bundle
    /// This is the cultural conscience - what has worked in the world
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
            print("⚠️ EditorialGroundTruth: App Group container not found - trying bundle")
            // Try bundle instead
            try await loadFromBundle()
            return
        }
        
        let csvURL = containerURL.appendingPathComponent(csvFilename)
        
        // Check if file exists, if not, copy from bundle
        if !FileManager.default.fileExists(atPath: csvURL.path) {
            do {
                try await copyCSVFromBundleIfNeeded(filename: csvFilename, to: csvURL)
            } catch {
                print("⚠️ EditorialGroundTruth: Could not copy CSV - \(error.localizedDescription)")
                // Try bundle as fallback
                try await loadFromBundle()
                return
            }
        }
        
        // Load and parse CSV on background thread
        let parsedBars = try await Task.detached(priority: .utility) { [csvURL] in
            let csvData = try Data(contentsOf: csvURL)
            return try Self.parseCSVFile(data: csvData)
        }.value
        
        await MainActor.run {
            self.groundTruthBars = parsedBars
            print("✅ EditorialGroundTruth: Loaded \(parsedBars.count) ground truth bars")
        }
    }
    
    /// Load CSV from app bundle as fallback
    private func loadFromBundle() async throws {
        guard let bundleURL = Bundle.main.url(forResource: csvFilename.replacingOccurrences(of: ".csv", with: ""), withExtension: "csv") else {
            print("⚠️ EditorialGroundTruth: CSV not found in bundle - continuing without ground truth")
            await MainActor.run {
                self.groundTruthBars = []
            }
            return
        }
        
        let csvData = try Data(contentsOf: bundleURL)
        let parsedBars = try await Task.detached(priority: .utility) {
            return try Self.parseCSVFile(data: csvData)
        }.value
        
        await MainActor.run {
            self.groundTruthBars = parsedBars
            print("✅ EditorialGroundTruth: Loaded \(parsedBars.count) ground truth bars from bundle")
        }
    }
    
    private func copyCSVFromBundleIfNeeded(filename: String, to destination: URL) async throws {
        // First try Desktop (for development)
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: desktopURL.path) {
            try FileManager.default.copyItem(at: desktopURL, to: destination)
            return
        }
        
        // Fallback: try app bundle
        guard let bundleURL = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".csv", with: ""), withExtension: "csv") else {
            throw GroundTruthError.fileNotFound(filename)
        }
        
        try FileManager.default.copyItem(at: bundleURL, to: destination)
    }
    
    // MARK: - CSV Parsing
    
    /// Public for tests. The vault header names the lyric `text_bar_line` and the first
    /// column is an unlabeled id (`REAL LYRICS…`) — never treat artist as the bar text.
    nonisolated static func parseCSVFile(data: Data) throws -> [GroundTruthBar] {
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw GroundTruthError.invalidEncoding
        }

        let lines = csvString.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            throw GroundTruthError.emptyFile
        }

        let header = parseCSVLine(lines[0]).map { $0.lowercased() }
        let textIndex = lyricColumnIndex(in: header)
        let idIndex = headerIndex(in: header, exact: ["id", "text_id"], containing: ["_id"]) ?? 0
        let artistIndex = headerIndex(in: header, exact: ["artist"], containing: ["artist"])
        let songIndex = headerIndex(in: header, exact: ["song", "track"], containing: [])
        let yearIndex = headerIndex(in: header, exact: ["year"], containing: ["year"])

        var bars: [GroundTruthBar] = []
        for (index, line) in lines.enumerated() {
            guard index > 0, !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            let components = parseCSVLine(line)
            func at(_ i: Int?) -> String {
                guard let i, i < components.count else { return "" }
                return components[i].trimmingCharacters(in: .whitespaces)
            }
            let id = at(idIndex)
            let text: String
            if let textIndex, textIndex < components.count {
                text = at(textIndex)
            } else if components.count > 1 {
                // Unlabeled simple dump: id,text,artist,song,year
                text = at(1)
            } else {
                continue
            }
            guard !id.isEmpty, !text.isEmpty else { continue }
            let artist = at(artistIndex)
            let song = at(songIndex)
            let yearRaw = at(yearIndex)
            bars.append(GroundTruthBar(
                id: id,
                text: text,
                artist: artist.isEmpty ? nil : artist,
                song: song.isEmpty ? nil : song,
                year: Int(yearRaw)
            ))
        }
        return bars
    }

    /// Lyric column is `text_bar_line` (or `text`/`line`). Never `bar_index` / `bar_group_*`.
    nonisolated private static func lyricColumnIndex(in header: [String]) -> Int? {
        let exact = ["text_bar_line", "text", "line", "bar", "lyric", "lyrics"]
        if let i = header.firstIndex(where: { exact.contains($0) }) { return i }
        return header.firstIndex { col in
            (col.contains("text") || col.contains("lyric"))
                && !col.contains("id")
                && !col.contains("index")
                && !col.contains("group")
        }
    }

    nonisolated private static func headerIndex(in header: [String], exact: [String], containing: [String]) -> Int? {
        if let i = header.firstIndex(where: { exact.contains($0) }) { return i }
        return header.firstIndex { col in
            containing.contains { col.contains($0) }
        }
    }
    
    nonisolated private static func parseCSVLine(_ line: String) -> [String] {
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
        
        if !currentField.isEmpty || line.last == "," {
            components.append(currentField)
        }
        
        return components
    }
    
    // MARK: - Query Methods
    
    /// Find similar ground truth bars by register/axis proximity
    func findSimilarBars(registers: RegisterProfile, axes: AxisProfile, limit: Int = 10) -> [GroundTruthBar] {
        // For now, return all bars (will be enhanced with actual similarity matching)
        // In future, this will match by register/axis proximity
        return Array(groundTruthBars.prefix(limit))
    }
}

// MARK: - Errors

enum GroundTruthError: LocalizedError {
    case fileNotFound(String)
    case invalidEncoding
    case emptyFile
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Ground truth CSV file not found: \(filename)"
        case .invalidEncoding:
            return "Invalid CSV encoding"
        case .emptyFile:
            return "CSV file is empty"
        }
    }
}
