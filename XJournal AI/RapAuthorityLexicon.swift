import Foundation

// MARK: - Lexicon Term Category

enum LexiconTermCategory: String, Codable {
    case contextualSignal = "contextual_signal"
    case codedLogistics = "coded/logistics"
    case declarativeFinality = "declarative_finality"
    case luxuryList = "luxury_list"
    case aftermath = "aftermath"
    case maintenance = "maintenance"
    case acquisition = "acquisition"
    case wealthAccess = "wealth/access"
    case other = "other"
}

// MARK: - Lexicon Scene

enum LexiconScene: String, Codable {
    case atlanta = "Atlanta"
    case modern = "modern"
    case scene = "scene"
    case other = "other"
    
    static func fromString(_ str: String) -> LexiconScene {
        let lower = str.lowercased()
        if lower.contains("atlanta") || lower == "atlanta" {
            return .atlanta
        } else if lower.contains("modern") {
            return .modern
        } else if lower.contains("scene") {
            return .scene
        }
        return .other
    }
}

// MARK: - Proof Type

enum ProofType: String, Codable {
    case implication = "implication"
    case proof = "proof"
    case none = "none"
}

// MARK: - Usage Mode

enum UsageMode: String, Codable {
    case implication = "implication"
    case explicit = "explicit"
    case contextual = "contextual"
}

// MARK: - Lexicon Term

struct LexiconTerm: Codable, Identifiable {
    let id: UUID
    let term: String
    let definition: String?
    let notes: String?
    let category: LexiconTermCategory
    let themePrimary: String?  // e.g., "wealth_lifestyle"
    let register: String?      // e.g., "coded"
    let authorityRequirement: Double  // 0.0-1.0: Minimum speaker authority needed
    let proofType: ProofType
    let exposureCost: Double          // 0.0-1.0: Cost to axis exposure guarding
    let overusePenalty: Double        // 0.0-1.0: Penalty for repetitive use
    let silencePreferredWhenBlocked: Bool
    let replacementIfBlocked: String? // Alternative term if blocked
    let culturalSpecificity: String? // e.g., "scene"
    let sceneWeight: Double?         // 0.0-1.0: Scene relevance weight
    let eraScene: String?            // e.g., "modern"
    let usageMode: UsageMode
    
    init(
        id: UUID = UUID(),
        term: String,
        definition: String? = nil,
        notes: String? = nil,
        category: LexiconTermCategory,
        themePrimary: String? = nil,
        register: String? = nil,
        authorityRequirement: Double,
        proofType: ProofType = .implication,
        exposureCost: Double,
        overusePenalty: Double,
        silencePreferredWhenBlocked: Bool = true,
        replacementIfBlocked: String? = nil,
        culturalSpecificity: String? = nil,
        sceneWeight: Double? = nil,
        eraScene: String? = nil,
        usageMode: UsageMode = .implication
    ) {
        self.id = id
        self.term = term
        self.definition = definition
        self.notes = notes
        self.category = category
        self.themePrimary = themePrimary
        self.register = register
        self.authorityRequirement = authorityRequirement
        self.proofType = proofType
        self.exposureCost = exposureCost
        self.overusePenalty = overusePenalty
        self.silencePreferredWhenBlocked = silencePreferredWhenBlocked
        self.replacementIfBlocked = replacementIfBlocked
        self.culturalSpecificity = culturalSpecificity
        self.sceneWeight = sceneWeight
        self.eraScene = eraScene
        self.usageMode = usageMode
    }
}

// MARK: - Scene Lexicon

struct SceneLexicon {
    let scene: LexiconScene
    let terms: [LexiconTerm]
    
    func terms(for category: LexiconTermCategory) -> [LexiconTerm] {
        return terms.filter { $0.category == category }
    }
    
    func term(named: String) -> LexiconTerm? {
        return terms.first { $0.term.lowercased() == named.lowercased() }
    }
    
    func terms(forTheme theme: String) -> [LexiconTerm] {
        return terms.filter { $0.themePrimary?.lowercased() == theme.lowercased() }
    }
    
    func terms(forRegister register: String) -> [LexiconTerm] {
        return terms.filter { $0.register?.lowercased() == register.lowercased() }
    }
    
    // Get all terms (for general use in generation)
    func allTerms() -> [LexiconTerm] {
        return terms
    }
}

// MARK: - Lexicon Store

class LexiconStore {
    static let shared = LexiconStore()
    
    private var lexicons: [LexiconScene: SceneLexicon] = [:]
    private var defaultScene: LexiconScene = .atlanta

    /// Strip a raw lexicon headword to a clean surface form, preserving case.
    /// `"Water" (diamonds…)` → `Water`; `Cartier ("Cartis").` → `Cartier`; `AP (Audemars Piguet)` → `AP`.
    static func cleanReference(_ s: String) -> String {
        var t = s
        if let r = t.range(of: "[(\\[]", options: .regularExpression) { t = String(t[..<r.lowerBound]) }
        t = t.trimmingCharacters(in: .whitespaces)
        t = t.trimmingCharacters(in: CharacterSet(charactersIn: "\"“”‘’'.,;:!?-—()[] "))
        return t.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    /// A token that can plausibly be matched in a verse: starts with a letter, ≤2 words, no junk.
    private static func isMatchableRef(_ t: String) -> Bool {
        t.count > 2 && t.count < 30 && t.split(separator: " ").count <= 2 &&
            t.range(of: "^[A-Za-z][A-Za-z0-9'.\\- ]*$", options: .regularExpression) != nil
    }

    /// Every distinct matchable reference token across all scenes — cleaned + lowercased, for scoring.
    func allTermStrings() -> [String] {
        Array(Set(lexicons.values.flatMap { $0.terms.compactMap { term -> String? in
            let c = Self.cleanReference(term.term)
            return Self.isMatchableRef(c) ? c.lowercased() : nil
        } }))
    }

    /// A presentable menu of specific references (proper case), spread across the lexicon's clusters
    /// for diversity — fed to generation so verses name concrete brands/places/coded terms.
    func referencePalette(limit: Int = 28) -> [String] {
        var seen = Set<String>(); var refs: [String] = []
        for term in lexicons.values.flatMap({ $0.terms }) {
            let c = Self.cleanReference(term.term)
            guard Self.isMatchableRef(c) else { continue }
            let k = c.lowercased()
            if !seen.contains(k) { seen.insert(k); refs.append(c) }
        }
        guard refs.count > limit else { return refs }
        let step = max(1, refs.count / limit)
        return stride(from: 0, to: refs.count, by: step).prefix(limit).map { refs[$0] }
    }

    private init() {
        // Try to load from bundle first, then Downloads folder
        do {
            try loadLexicon()
        } catch {
            // Try Downloads folder
            do {
                try loadLexiconFromDownloads()
            } catch {
                // Fall back to default
                loadDefaultLexicon()
                print("⚠️ Lexicon: Using default lexicon (CSV not found)")
            }
        }
    }
    
    // MARK: - Load Lexicon
    
    func loadLexicon(from csvPath: String) throws {
        guard let csvData = try? String(contentsOfFile: csvPath, encoding: .utf8) else {
            throw LexiconError.fileNotFound
        }
        
        let parsedLexicons = try parseCSV(csvData: csvData)
        lexicons = parsedLexicons
    }
    
    func loadLexicon(from bundle: Bundle = .main, filename: String = "jargon_authority_lexicon_v8.csv") throws {
        guard let path = bundle.path(forResource: filename, ofType: nil) else {
            // Try alternative filename
            if let altPath = bundle.path(forResource: "Rap_Authority_Lexicon_v2_Scenes", ofType: "csv") {
                try loadLexicon(from: altPath)
                return
            }
            // If file not found, use default lexicon
            loadDefaultLexicon()
            return
        }
        
        try loadLexicon(from: path)
    }
    
    func loadLexiconFromDownloads(filename: String = "jargon_authority_lexicon_v8.csv") throws {
        let downloadsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let filePath = downloadsPath.appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            // Fall back to bundle
            try loadLexicon()
            return
        }
        
        try loadLexicon(from: filePath.path)
    }
    
    // MARK: - Get Lexicon
    
    func getLexicon(for scene: LexiconScene? = nil) -> SceneLexicon? {
        let targetScene = scene ?? defaultScene
        return lexicons[targetScene]
    }
    
    func getTerm(_ termName: String, scene: LexiconScene? = nil) -> LexiconTerm? {
        let targetScene = scene ?? defaultScene
        return lexicons[targetScene]?.term(named: termName)
    }
    
    func getTerms(category: LexiconTermCategory, scene: LexiconScene? = nil) -> [LexiconTerm] {
        let targetScene = scene ?? defaultScene
        return lexicons[targetScene]?.terms(for: category) ?? []
    }
    
    // MARK: - Set Default Scene
    
    func setDefaultScene(_ scene: LexiconScene) {
        defaultScene = scene
    }
    
    // MARK: - CSV Parser
    
    private func parseCSV(csvData: String) throws -> [LexiconScene: SceneLexicon] {
        let lines = csvData.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }
        
        guard !lines.isEmpty else {
            throw LexiconError.invalidFormat
        }
        
        // Parse header
        let header = lines[0]
        let headerColumns = parseCSVLine(header)
        
        // Find column indices
        var indices: [String: Int] = [:]
        for (index, column) in headerColumns.enumerated() {
            let lowercased = column.lowercased().replacingOccurrences(of: " ", with: "_")
            indices[lowercased] = index
        }
        
        // Required columns
        guard let termIndex = indices["term"] else {
            throw LexiconError.invalidFormat
        }
        
        // Parse data rows - group by scene_weight or era_scene
        var allTerms: [LexiconTerm] = []
        
        for line in lines.dropFirst() {
            let columns = parseCSVLine(line)
            
            guard columns.count > termIndex else { continue }
            
            let term = columns[termIndex].trimmingCharacters(in: .whitespaces)
            guard !term.isEmpty && term != "Common Themes / Specific Terms" else { continue }
            
            // Parse all fields
            let definition = indices["definition"].flatMap { idx in
                idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            let notes = indices["notes"].flatMap { idx in
                idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            let categoryStr = indices["category"].flatMap { idx in
                idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : nil
            } ?? "contextual_signal"
            let category = LexiconTermCategory(rawValue: categoryStr) ?? .contextualSignal
            
            let themePrimary = indices["theme_primary"].flatMap { idx in
                idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            let register = indices["register"].flatMap { idx in
                idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            
            let authorityReq = indices["authority_requirement"].flatMap { idx in
                idx < columns.count ? Double(columns[idx].trimmingCharacters(in: .whitespaces)) : nil
            } ?? 0.6
            
            let proofTypeStr = indices["proof_type"].flatMap { idx in
                idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : nil
            } ?? "implication"
            let proofType = ProofType(rawValue: proofTypeStr) ?? .implication
            
            let exposureCost = indices["exposure_cost"].flatMap { idx in
                idx < columns.count ? Double(columns[idx].trimmingCharacters(in: .whitespaces)) : nil
            } ?? 0.6
            
            let overusePenalty = indices["overuse_penalty"].flatMap { idx in
                idx < columns.count ? Double(columns[idx].trimmingCharacters(in: .whitespaces)) : nil
            } ?? 0.7
            
            let silencePreferred = indices["silence_preferred_when_blocked"].flatMap { idx in
                idx < columns.count ? (columns[idx].trimmingCharacters(in: .whitespaces).lowercased() == "true") : nil
            } ?? true
            
            let replacement = indices["replacement_if_blocked"].flatMap { idx in
                let val = idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : ""
                return val.isEmpty ? nil : val
            }
            
            let culturalSpecificity = indices["cultural_specificity"].flatMap { idx in
                idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            
            let sceneWeight = indices["scene_weight"].flatMap { idx in
                idx < columns.count ? Double(columns[idx].trimmingCharacters(in: .whitespaces)) : nil
            }
            
            let eraScene = indices["era_scene"].flatMap { idx in
                idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : nil
            }
            
            let usageModeStr = indices["usage_mode"].flatMap { idx in
                idx < columns.count ? columns[idx].trimmingCharacters(in: .whitespaces) : nil
            } ?? "implication"
            let usageMode = UsageMode(rawValue: usageModeStr) ?? .implication
            
            // Determine scene - use era_scene or default to modern
            _ = eraScene.flatMap { LexiconScene.fromString($0) } ?? .modern
            
            let lexiconTerm = LexiconTerm(
                term: term,
                definition: definition,
                notes: notes,
                category: category,
                themePrimary: themePrimary,
                register: register,
                authorityRequirement: max(0.0, min(1.0, authorityReq)),
                proofType: proofType,
                exposureCost: max(0.0, min(1.0, exposureCost)),
                overusePenalty: max(0.0, min(1.0, overusePenalty)),
                silencePreferredWhenBlocked: silencePreferred,
                replacementIfBlocked: replacement,
                culturalSpecificity: culturalSpecificity,
                sceneWeight: sceneWeight,
                eraScene: eraScene,
                usageMode: usageMode
            )
            
            allTerms.append(lexiconTerm)
        }
        
        // Group terms by scene
        var sceneTerms: [LexiconScene: [LexiconTerm]] = [:]
        for term in allTerms {
            let scene = term.eraScene.flatMap { LexiconScene.fromString($0) } ?? .modern
            if sceneTerms[scene] == nil {
                sceneTerms[scene] = []
            }
            sceneTerms[scene]?.append(term)
        }
        
        // Build SceneLexicon objects
        var result: [LexiconScene: SceneLexicon] = [:]
        for (scene, terms) in sceneTerms {
            result[scene] = SceneLexicon(scene: scene, terms: terms)
        }
        
        // Also create a combined "modern" lexicon with all terms for easy access
        if !allTerms.isEmpty {
            result[.modern] = SceneLexicon(scene: .modern, terms: allTerms)
        }
        
        return result
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        
        return result.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) }
    }
    
    // MARK: - Default Lexicon (Fallback)
    
    private func loadDefaultLexicon() {
        // Default modern scene lexicon with sample terms
        // In production, this would be replaced by CSV loading
        let defaultTerms: [LexiconTerm] = [
            // Sample terms - these would come from CSV in production
            LexiconTerm(
                term: "cashing checks",
                definition: "Making money",
                category: .contextualSignal,
                themePrimary: "wealth_lifestyle",
                register: "coded",
                authorityRequirement: 0.5,
                proofType: .implication,
                exposureCost: 0.3,
                overusePenalty: 0.2,
                replacementIfBlocked: "making money",
                usageMode: .implication
            ),
            LexiconTerm(
                term: "on the road",
                definition: "Traveling for work",
                category: .contextualSignal,
                themePrimary: "wealth_lifestyle",
                register: "coded",
                authorityRequirement: 0.4,
                proofType: .implication,
                exposureCost: 0.2,
                overusePenalty: 0.15,
                usageMode: .implication
            ),
            LexiconTerm(
                term: "designer",
                definition: "High-end fashion",
                category: .contextualSignal,
                themePrimary: "wealth_lifestyle",
                register: "coded",
                authorityRequirement: 0.7,
                proofType: .implication,
                exposureCost: 0.5,
                overusePenalty: 0.4,
                replacementIfBlocked: "fashion",
                usageMode: .implication
            )
        ]
        
        lexicons[.modern] = SceneLexicon(scene: .modern, terms: defaultTerms)
        defaultScene = .modern
    }
}

// MARK: - Lexicon Errors

enum LexiconError: Error {
    case fileNotFound
    case invalidFormat
    case parsingFailed
}
