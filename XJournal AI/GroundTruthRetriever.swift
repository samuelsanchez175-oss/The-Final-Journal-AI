import Foundation
import NaturalLanguage

// MARK: - PR 11: Ground Truth Retriever

class GroundTruthRetriever {
    static let shared = GroundTruthRetriever()
    
    private var indexedBars: [GroundTruthIndex] = []
    private(set) var isIndexed: Bool = false  // PR 15: Make accessible for integration
    
    // Indexes for fast lookup
    private var indexByAuthorityVector: [String: [GroundTruthIndex]] = [:]
    private var indexBySyllableBucket: [Int: [GroundTruthIndex]] = [:]  // Bucket = syllableCount / 3
    private var indexByRhymeEnding: [String: [GroundTruthIndex]] = [:]
    private var indexByVerbDensityBucket: [Int: [GroundTruthIndex]] = [:]  // Bucket = Int(verbDensity * 5)
    
    private init() {}
    
    // MARK: - Initialization
    
    /// Load and index ground truth bars from CSV
    func loadAndIndex() async throws {
        guard !isIndexed else { return }
        
        // Load bars from EditorialGroundTruth
        if !EditorialGroundTruth.shared.isLoaded {
            try await EditorialGroundTruth.shared.loadFromAppGroup()
        }
        
        let bars = EditorialGroundTruth.shared.groundTruthBars
        
        // Parse CSV file directly to get additional columns
        let csvFilename = "ground_truth_rap_bars_MODEL_G.csv"
        guard let csvURL = Bundle.main.url(forResource: csvFilename.replacingOccurrences(of: ".csv", with: ""), withExtension: "csv") else {
            print("⚠️ GroundTruthRetriever: CSV file not found, using basic indexing")
            // Fallback: index with basic info
            indexedBars = bars.map { Self.createBasicIndex(from: $0) }
            isIndexed = true
            return
        }
        
        // Parse CSV with full column support
        let csvData = try Data(contentsOf: csvURL)
        let indexed = try await Task.detached(priority: .utility) {
            return try Self.parseAndIndexCSV(data: csvData, bars: bars)
        }.value
        
        indexedBars = indexed
        buildIndexes()
        isIndexed = true
        
        print("✅ GroundTruthRetriever: Indexed \(indexedBars.count) bars")
    }
    
    // MARK: - CSV Parsing with Full Columns
    
    private nonisolated static func parseAndIndexCSV(data: Data, bars: [GroundTruthBar]) throws -> [GroundTruthIndex] {
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw GroundTruthError.invalidEncoding
        }
        
        let lines = csvString.components(separatedBy: .newlines)
        guard lines.count > 2 else {
            throw GroundTruthError.emptyFile
        }
        
        // Skip first two lines (header info), parse actual header on line 3
        guard lines.count > 3 else {
            return bars.map { createBasicIndex(from: $0) }
        }
        
        let headerLine = lines[2]  // Line 3 (0-indexed = 2)
        let header = parseCSVLine(headerLine)
        
        // Find column indices
        let textIdIndex = header.firstIndex(where: { $0.lowercased().contains("text_id") || $0.lowercased() == "id" })
        let flowVectorIndex = header.firstIndex(where: { $0.lowercased().contains("flow_vector") })
        let syllableCountIndex = header.firstIndex(where: { $0.lowercased().contains("syllable_count_recalc") || $0.lowercased().contains("syllable_count") })
        let stressPatternIndex = header.firstIndex(where: { $0.lowercased().contains("stress_pattern") })
        let phoneticEndingIndex = header.firstIndex(where: { $0.lowercased().contains("phonetic_ending") })
        let rhymeClassIndex = header.firstIndex(where: { $0.lowercased().contains("rhyme_class") || $0.lowercased().contains("phonetic_rhyme_class") })
        
        // Create lookup map for bars by ID
        let barsById = Dictionary(uniqueKeysWithValues: bars.map { ($0.id, $0) })
        
        var indexed: [GroundTruthIndex] = []
        
        // Parse data rows (starting from line 4, index 3)
        for i in 3..<lines.count {
            let line = lines[i]
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            
            let components = parseCSVLine(line)
            guard components.count > 0 else { continue }
            
            // Get text_id to match with GroundTruthBar
            let textId: String
            if let idIdx = textIdIndex, idIdx < components.count {
                textId = components[idIdx].trimmingCharacters(in: .whitespaces)
            } else if components.count > 0 {
                textId = components[0].trimmingCharacters(in: .whitespaces)
            } else {
                continue
            }
            
            guard let bar = barsById[textId] else {
                // Create basic index if bar not found
                indexed.append(createBasicIndex(from: GroundTruthBar(id: textId, text: components.count > 6 ? components[6].trimmingCharacters(in: .whitespaces) : "")))
                continue
            }
            
            // Extract additional columns
            let flowVector = flowVectorIndex.flatMap { idx in
                idx < components.count ? components[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            
            let syllableCount: Int
            if let idx = syllableCountIndex, idx < components.count {
                syllableCount = Int(components[idx].trimmingCharacters(in: .whitespaces)) ?? 0
            } else {
                syllableCount = 0
            }
            
            let stressPatternStr = stressPatternIndex.flatMap { idx in
                idx < components.count ? components[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            let stressPattern = parseStressPattern(stressPatternStr ?? "")
            
            let phoneticEnding = phoneticEndingIndex.flatMap { idx in
                idx < components.count ? components[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            
            let rhymeClass = rhymeClassIndex.flatMap { idx in
                idx < components.count ? components[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            
            // Normalize metrics
            let normalizedMetrics = NormalizedMetrics(
                syllableCount: syllableCount,
                stressPattern: stressPattern,
                rhymeClass: rhymeClass,
                phoneticEnding: phoneticEnding
            )
            
            // Extract AuthorityVector from flow_vector (if present)
            let authorityVector = extractAuthorityVector(from: flowVector, artist: bar.artist)
            
            // Classify verbs and calculate verb density
            let (verbClasses, verbDensity) = analyzeVerbs(in: bar.text)
            
            // Create index
            let index = GroundTruthIndex(
                id: bar.id,
                bar: bar,
                normalizedMetrics: normalizedMetrics,
                authorityVector: authorityVector,
                syllableCount: syllableCount > 0 ? syllableCount : estimateSyllables(bar.text),
                rhymeEnding: phoneticEnding ?? rhymeClass,
                verbDensity: verbDensity,
                verbClasses: verbClasses
            )
            
            indexed.append(index)
        }
        
        return indexed
    }
    
    // MARK: - Helper Functions
    
    private nonisolated static func parseCSVLine(_ line: String) -> [String] {
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
    
    private nonisolated static func parseStressPattern(_ pattern: String) -> [Int] {
        // Parse binary stress pattern (e.g., "1110111101" -> [1,1,1,0,1,1,1,1,0,1])
        return pattern.compactMap { char in
            Int(String(char))
        }
    }
    
    private nonisolated static func extractAuthorityVector(from flowVector: String?, artist: String?) -> String? {
        // Try to extract AuthorityVector from flow_vector column
        // For now, infer from artist (Gunna -> control_hierarchy/capital_flow)
        if let artist = artist?.lowercased() {
            if artist.contains("gunna") {
                return "control_hierarchy"  // Default for Gunna
            } else if artist.contains("thug") {
                return "expressive_chaos"  // Default for Young Thug
            }
        }
        
        // Could parse flow_vector if it contains AuthorityVector info
        // For now, return nil if not inferrable
        return nil
    }
    
    private nonisolated static func analyzeVerbs(in text: String) -> ([VerbClass], Double) {
        let words = text.lowercased()
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty }
        
        var verbClasses: [VerbClass] = []
        var verbCount = 0
        
        for word in words {
            if let verbClass = classifyVerb(word) {
                verbClasses.append(verbClass)
                verbCount += 1
            }
        }
        
        let verbDensity = words.isEmpty ? 0.0 : Double(verbCount) / Double(words.count)
        return (verbClasses, verbDensity)
    }
    
    private nonisolated static func classifyVerb(_ word: String) -> VerbClass? {
        let lowercased = word.lowercased()
        
        // Transaction verbs
        let transactionVerbs = ["buy", "spend", "cop", "drop", "pay", "invest", "purchase", "acquire", "obtain", "get", "grab"]
        if transactionVerbs.contains(lowercased) {
            return .transaction
        }
        
        // Motion verbs
        let motionVerbs = ["pull", "push", "move", "drive", "fly", "ride", "walk", "run", "go", "come", "leave", "arrive"]
        if motionVerbs.contains(lowercased) {
            return .motion
        }
        
        // Reflection verbs
        let reflectionVerbs = ["learn", "feel", "think", "realize", "understand", "believe", "know", "remember", "wonder"]
        if reflectionVerbs.contains(lowercased) {
            return .reflection
        }
        
        return nil
    }
    
    private nonisolated static func estimateSyllables(_ text: String) -> Int {
        // Simple estimation: average 1.5 syllables per word
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return Int(Double(words.count) * 1.5)
    }
    
    private nonisolated static func createBasicIndex(from bar: GroundTruthBar) -> GroundTruthIndex {
        let (verbClasses, verbDensity) = analyzeVerbs(in: bar.text)
        let syllableCount = estimateSyllables(bar.text)
        
        return GroundTruthIndex(
            id: bar.id,
            bar: bar,
            normalizedMetrics: NormalizedMetrics(
                syllableCount: syllableCount,
                stressPattern: [],
                rhymeClass: nil,
                phoneticEnding: nil
            ),
            authorityVector: extractAuthorityVector(from: nil, artist: bar.artist),
            syllableCount: syllableCount,
            rhymeEnding: nil,
            verbDensity: verbDensity,
            verbClasses: verbClasses
        )
    }
    
    // MARK: - Index Building
    
    private func buildIndexes() {
        indexByAuthorityVector.removeAll()
        indexBySyllableBucket.removeAll()
        indexByRhymeEnding.removeAll()
        indexByVerbDensityBucket.removeAll()
        
        for index in indexedBars {
            // Index by AuthorityVector
            if let auth = index.authorityVector {
                if indexByAuthorityVector[auth] == nil {
                    indexByAuthorityVector[auth] = []
                }
                indexByAuthorityVector[auth]?.append(index)
            }
            
            // Index by syllable bucket (buckets of 3: 8-10, 11-13, 14-16, etc.)
            let syllableBucket = index.syllableCount / 3
            if indexBySyllableBucket[syllableBucket] == nil {
                indexBySyllableBucket[syllableBucket] = []
            }
            indexBySyllableBucket[syllableBucket]?.append(index)
            
            // Index by rhyme ending
            if let ending = index.rhymeEnding {
                if indexByRhymeEnding[ending] == nil {
                    indexByRhymeEnding[ending] = []
                }
                indexByRhymeEnding[ending]?.append(index)
            }
            
            // Index by verb density bucket (0.0-0.2, 0.2-0.4, etc.)
            let verbDensityBucket = Int(index.verbDensity * 5)
            if indexByVerbDensityBucket[verbDensityBucket] == nil {
                indexByVerbDensityBucket[verbDensityBucket] = []
            }
            indexByVerbDensityBucket[verbDensityBucket]?.append(index)
        }
    }
    
    // MARK: - Query Methods
    
    /// Retrieve candidates matching criteria
    func retrieveCandidates(
        authorityVector: String? = nil,
        syllableRange: Range<Int>? = nil,
        rhymeEnding: String? = nil,
        verbDensityRange: Range<Double>? = nil,
        limit: Int = 10
    ) -> [GroundTruthIndex] {
        guard isIndexed else {
            print("⚠️ GroundTruthRetriever: Not indexed yet, returning empty")
            return []
        }
        
        var candidates: Set<GroundTruthIndex> = []
        
        // Filter by AuthorityVector
        if let auth = authorityVector, let authBars = indexByAuthorityVector[auth] {
            candidates.formUnion(authBars)
        } else if authorityVector == nil {
            // If no AuthorityVector specified, include all
            candidates.formUnion(indexedBars)
        }
        
        // Filter by syllable range
        if let range = syllableRange {
            let filtered = candidates.filter { range.contains($0.syllableCount) }
            candidates = Set(filtered)
        }
        
        // Filter by rhyme ending
        if let ending = rhymeEnding, let rhymeBars = indexByRhymeEnding[ending] {
            candidates.formIntersection(Set(rhymeBars))
        }
        
        // Filter by verb density range
        if let range = verbDensityRange {
            let filtered = candidates.filter { range.contains($0.verbDensity) }
            candidates = Set(filtered)
        }
        
        // If no filters applied, return all (up to limit)
        if candidates.isEmpty && authorityVector == nil && syllableRange == nil && rhymeEnding == nil && verbDensityRange == nil {
            return Array(indexedBars.prefix(limit))
        }
        
        return Array(candidates.prefix(limit))
    }
    
    // MARK: - PR 12: Behavior Filter Layer
    
    /// Filter candidates using GeneratorPolicy constraints
    func filterCandidates(
        _ candidates: [GroundTruthIndex],
        policy: GeneratorPolicy
    ) -> [GroundTruthIndex] {
        guard policy.artistBias == .gunna else {
            // For non-Gunna, return all candidates (no filtering)
            return candidates
        }
        
        var filtered: [GroundTruthIndex] = []
        var scored: [(index: GroundTruthIndex, score: Double)] = []
        
        for candidate in candidates {
            var score: Double = 1.0
            var shouldReject = false
            
            // Check 1: Authority match
            if let policyAuth = candidate.authorityVector {
                // Prefer matching AuthorityVector
                let gunnaAuthVectors = ["control_hierarchy", "capital_flow", "fashion_rank", "loyalty_infrastructure"]
                if gunnaAuthVectors.contains(policyAuth) {
                    score += 0.3  // Bonus for matching authority
                }
            }
            
            // Check 2: Syllable limits
            if candidate.syllableCount > policy.maxClauseSyllables {
                shouldReject = true
                continue
            }
            
            // Check 3: Reflection limits
            let hasReflectionVerb = candidate.verbClasses.contains(.reflection)
            if hasReflectionVerb && !policy.allowedVerbClasses.contains(.reflection) {
                shouldReject = true
                continue
            }
            
            // Check 4: Forbidden verbs
            let lowercased = candidate.text.lowercased()
            for forbiddenVerb in policy.forbiddenVerbs {
                if lowercased.contains(forbiddenVerb) {
                    shouldReject = true
                    break
                }
            }
            if shouldReject {
                continue
            }
            
            // Check 5: Brand count (simple heuristic)
            let commonBrands = ["gucci", "prada", "versace", "louis", "vuitton", "dior", "chanel", "balenciaga", "fendi", "hermes", "rolex"]
            let brandCount = commonBrands.filter { lowercased.contains($0) }.count
            if brandCount > policy.brandPerBarMax {
                shouldReject = true
                continue
            }
            
            // Check 6: Verb class compliance
            let hasOnlyAllowedVerbs = candidate.verbClasses.allSatisfy { policy.allowedVerbClasses.contains($0) }
            if !hasOnlyAllowedVerbs && !candidate.verbClasses.isEmpty {
                score -= 0.2  // Penalty but don't reject
            }
            
            // Check 7: Syllable count proximity (prefer closer to target)
            let syllableDiff = abs(candidate.syllableCount - 12)  // Target ~12 for Gunna
            if syllableDiff > 3 {
                score -= 0.1  // Penalty for being far from target
            }
            
            if !shouldReject {
                scored.append((candidate, score))
            }
        }
        
        // Sort by score (highest first) and return
        scored.sort { $0.score > $1.score }
        filtered = scored.map { $0.index }
        
        return filtered
    }
}
