import Foundation

// MARK: - RapLine
// Represents a single line of rap text with metadata
struct RapLine {
    let text: String
    let syllableCount: Int
}

// MARK: - Entity

struct Entity: Codable {
    let type: EntityType
    let value: String
}

// MARK: - Generator Policy Enums

enum ArtistBias: String, Codable {
    case gunna
    case youngThug
    case neutral
}

enum VerbClass: String, Codable {
    case transaction  // buy, spend, cop, drop
    case motion       // pull, push, move, drive
    case reflection   // learn, feel, think, realize (forbidden for Gunna)
}

enum StatementMode: String, Codable {
    case declarative  // I am, I have, I own
    case transactional // I buy, I spend, I cop
    case descriptive  // It is, They are
}

enum TemplateType: String, Codable {
    case car
    case spending
    case brand
    case loyalty
    case priceOnObject
}

// MARK: - Generator Policy

struct GeneratorPolicy: Codable {
    let artistBias: ArtistBias
    let allowedVerbClasses: [VerbClass]
    let forbiddenVerbs: [String]
    let maxClauseSyllables: Int
    let brandPerBarMax: Int
    let priceAnchorEveryNBars: Int
    let templateBias: [TemplateType]
    let indifferencePressure: Double  // 0.0-1.0
    
    // SuperGunna Mode fields
    let superGunnaEnabled: Bool
    let stylePriority: Double  // 0.0-1.0
    let userProfileWeight: Double  // 0.0-1.0
    let signalProfileExposure: SignalExposure
    let repeatMotifEveryNBars: Int  // 0 = disabled
    let motifPool: [String]
    
    static let `default` = GeneratorPolicy(
        artistBias: .neutral,
        allowedVerbClasses: [.transaction, .motion, .reflection],  // All allowed by default
        forbiddenVerbs: [],
        maxClauseSyllables: 20,  // No limit by default
        brandPerBarMax: 3,  // No strict limit by default
        priceAnchorEveryNBars: 10,  // No requirement by default
        templateBias: [],  // No template bias by default
        indifferencePressure: 0.0,  // No pressure by default
        superGunnaEnabled: false,
        stylePriority: 0.0,
        userProfileWeight: 0.0,
        signalProfileExposure: .full,
        repeatMotifEveryNBars: 0,  // Disabled by default
        motifPool: []
    )
    
    init(
        artistBias: ArtistBias,
        allowedVerbClasses: [VerbClass],
        forbiddenVerbs: [String],
        maxClauseSyllables: Int,
        brandPerBarMax: Int,
        priceAnchorEveryNBars: Int,
        templateBias: [TemplateType],
        indifferencePressure: Double,
        superGunnaEnabled: Bool = false,
        stylePriority: Double = 0.0,
        userProfileWeight: Double = 0.0,
        signalProfileExposure: SignalExposure = .full,
        repeatMotifEveryNBars: Int = 0,
        motifPool: [String] = []
    ) {
        self.artistBias = artistBias
        self.allowedVerbClasses = allowedVerbClasses
        self.forbiddenVerbs = forbiddenVerbs
        self.maxClauseSyllables = maxClauseSyllables
        self.brandPerBarMax = brandPerBarMax
        self.priceAnchorEveryNBars = priceAnchorEveryNBars
        self.templateBias = templateBias
        self.indifferencePressure = indifferencePressure
        self.superGunnaEnabled = superGunnaEnabled
        self.stylePriority = stylePriority
        self.userProfileWeight = userProfileWeight
        self.signalProfileExposure = signalProfileExposure
        self.repeatMotifEveryNBars = repeatMotifEveryNBars
        self.motifPool = motifPool
    }
}

// MARK: - Narrative Analysis
// Validated output model (never optional)
// Matches strict JSON Schema: https://json-schema.org/draft-07/schema#

struct NarrativeAnalysis: Codable {
    let primaryThemes: [String]
    let secondaryThemes: [String]
    /// Multi-tone: tones detected in the verse. Prefer this over emotionalTone.
    let detectedTones: [EmotionalTone]
    /// Prefer detectedTones; use emotionalTone only for legacy single-tone call sites. Derived as detectedTones.first ?? .neutral.
    let emotionalTone: EmotionalTone
    let narrativePhase: NarrativePhase
    let perspective: Perspective
    let entities: [Entity]
    let summary: String
    
    // Legacy optional fields (not in schema, but kept for backward compatibility)
    // These will be ignored during validation (additionalProperties: false)
    let underlyingThemes: [String]?
    let topicTreatmentModes: TopicTreatmentModes?
    let voiceType: String?
    let thematicContradictions: [String]?
    let narrativeMomentum: String?
    let contextualPlacement: String?
    let styleCharacteristics: StyleCharacteristics?
    let keyPhrases: [String]?
    let storyElements: [String]?
    let continuationNeeds: String?
    let generatorPolicy: GeneratorPolicy  // Generator policy for behavioral constraints
    
    enum CodingKeys: String, CodingKey {
        case primaryThemes
        case secondaryThemes
        case detectedTones
        case emotionalTone
        case narrativePhase
        case perspective
        case entities
        case summary
        // Legacy fields
        case underlyingThemes
        case topicTreatmentModes
        case voiceType
        case thematicContradictions
        case narrativeMomentum
        case contextualPlacement
        case styleCharacteristics
        case keyPhrases
        case storyElements
        case continuationNeeds
        case generatorPolicy
    }
    
    init(
        primaryThemes: [String],
        secondaryThemes: [String],
        detectedTones: [EmotionalTone],
        narrativePhase: NarrativePhase,
        perspective: Perspective,
        entities: [Entity],
        summary: String,
        underlyingThemes: [String]? = nil,
        topicTreatmentModes: TopicTreatmentModes? = nil,
        voiceType: String? = nil,
        thematicContradictions: [String]? = nil,
        narrativeMomentum: String? = nil,
        contextualPlacement: String? = nil,
        styleCharacteristics: StyleCharacteristics? = nil,
        keyPhrases: [String]? = nil,
        storyElements: [String]? = nil,
        continuationNeeds: String? = nil,
        generatorPolicy: GeneratorPolicy = .default
    ) {
        self.primaryThemes = primaryThemes
        self.secondaryThemes = secondaryThemes
        self.detectedTones = detectedTones.isEmpty ? [.neutral] : detectedTones
        self.emotionalTone = detectedTones.first ?? .neutral
        self.narrativePhase = narrativePhase
        self.perspective = perspective
        self.entities = entities
        self.summary = summary
        self.underlyingThemes = underlyingThemes
        self.topicTreatmentModes = topicTreatmentModes
        self.voiceType = voiceType
        self.thematicContradictions = thematicContradictions
        self.narrativeMomentum = narrativeMomentum
        self.contextualPlacement = contextualPlacement
        self.styleCharacteristics = styleCharacteristics
        self.keyPhrases = keyPhrases
        self.storyElements = storyElements
        self.continuationNeeds = continuationNeeds
        self.generatorPolicy = generatorPolicy
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields - decode as strings and convert to enums
        let primaryThemesArray = try container.decode([String].self, forKey: .primaryThemes)
        let secondaryThemesArray = try container.decode([String].self, forKey: .secondaryThemes)
        
        // Decode detectedTones (array of strings → [EmotionalTone]); if missing, fall back to single emotionalTone
        let detectedTonesArray: [EmotionalTone]
        if let toneStrings = try? container.decode([String].self, forKey: .detectedTones) {
            detectedTonesArray = toneStrings.compactMap { EmotionalTone(rawValue: $0) }
        } else {
            detectedTonesArray = []
        }
        // Decode emotional tone (string → enum) for legacy single-tone API responses
        let emotionalToneString = try container.decode(String.self, forKey: .emotionalTone)
        guard let emotionalToneEnum = EmotionalTone(rawValue: emotionalToneString) else {
            throw DecodingError.dataCorruptedError(forKey: .emotionalTone, in: container, debugDescription: "Invalid emotionalTone: \(emotionalToneString)")
        }
        let resolvedDetectedTones = detectedTonesArray.isEmpty ? [emotionalToneEnum] : detectedTonesArray
        
        // Decode narrative phase (string → enum)
        let narrativePhaseString = try container.decode(String.self, forKey: .narrativePhase)
        guard let narrativePhaseEnum = NarrativePhase(rawValue: narrativePhaseString) else {
            throw DecodingError.dataCorruptedError(forKey: .narrativePhase, in: container, debugDescription: "Invalid narrativePhase: \(narrativePhaseString)")
        }
        
        // Decode perspective (string → enum)
        let perspectiveString = try container.decode(String.self, forKey: .perspective)
        // Handle legacy format (first-person vs first_person)
        let normalizedPerspective = perspectiveString.replacingOccurrences(of: "-", with: "_")
        guard let perspectiveEnum = Perspective(rawValue: normalizedPerspective) else {
            throw DecodingError.dataCorruptedError(forKey: .perspective, in: container, debugDescription: "Invalid perspective: \(perspectiveString)")
        }
        
        // Handle entities: can be Array<Object> or legacy Array<String>
        let entitiesArray: [Entity]
        if let entityObjects = try? container.decode([Entity].self, forKey: .entities) {
            entitiesArray = entityObjects
        } else if let entityStrings = try? container.decode([String].self, forKey: .entities) {
            // Convert legacy format to new format
            entitiesArray = entityStrings.map { Entity(type: .concept, value: $0) }
        } else {
            entitiesArray = []
        }
        
        let summaryString = try container.decode(String.self, forKey: .summary)
        
        // Optional legacy fields
        self.underlyingThemes = try container.decodeIfPresent([String].self, forKey: .underlyingThemes)
        self.topicTreatmentModes = try container.decodeIfPresent(TopicTreatmentModes.self, forKey: .topicTreatmentModes)
        self.voiceType = try container.decodeIfPresent(String.self, forKey: .voiceType)
        self.thematicContradictions = try container.decodeIfPresent([String].self, forKey: .thematicContradictions)
        self.narrativeMomentum = try container.decodeIfPresent(String.self, forKey: .narrativeMomentum)
        self.contextualPlacement = try container.decodeIfPresent(String.self, forKey: .contextualPlacement)
        self.styleCharacteristics = try container.decodeIfPresent(StyleCharacteristics.self, forKey: .styleCharacteristics)
        self.keyPhrases = try container.decodeIfPresent([String].self, forKey: .keyPhrases)
        self.storyElements = try container.decodeIfPresent([String].self, forKey: .storyElements)
        self.continuationNeeds = try container.decodeIfPresent(String.self, forKey: .continuationNeeds)
        
        // Decode generatorPolicy (with default fallback)
        self.generatorPolicy = try container.decodeIfPresent(GeneratorPolicy.self, forKey: .generatorPolicy) ?? .default
        
        // Initialize required fields
        self.primaryThemes = primaryThemesArray
        self.secondaryThemes = secondaryThemesArray
        self.detectedTones = resolvedDetectedTones
        self.emotionalTone = resolvedDetectedTones.first ?? emotionalToneEnum
        self.narrativePhase = narrativePhaseEnum
        self.perspective = perspectiveEnum
        self.entities = entitiesArray
        self.summary = summaryString
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        try container.encode(primaryThemes, forKey: .primaryThemes)
        try container.encode(secondaryThemes, forKey: .secondaryThemes)
        try container.encode(detectedTones.map(\.rawValue), forKey: .detectedTones)
        try container.encode(emotionalTone.rawValue, forKey: .emotionalTone)
        try container.encode(narrativePhase.rawValue, forKey: .narrativePhase)
        try container.encode(perspective.rawValue, forKey: .perspective)
        try container.encode(entities, forKey: .entities)
        try container.encode(summary, forKey: .summary)
        try container.encode(generatorPolicy, forKey: .generatorPolicy)
        
        // Don't encode legacy fields (additionalProperties: false)
    }

    /// Minimal placeholder for Model G Core when narrative analysis is skipped.
    static var modelGCorePlaceholder: NarrativeAnalysis {
        NarrativeAnalysis(
            primaryThemes: ["melodic", "flow"],
            secondaryThemes: [],
            detectedTones: [.neutral],
            narrativePhase: .assertion,
            perspective: .first_person,
            entities: [],
            summary: "Model G Core placeholder — intent derived from user text.",
            generatorPolicy: GeneratorPolicy(
                artistBias: .gunna,
                allowedVerbClasses: [.transaction, .motion, .reflection],
                forbiddenVerbs: ["learn", "understand", "because", "so", "since", "picked up"],
                maxClauseSyllables: 14,
                brandPerBarMax: 1,
                priceAnchorEveryNBars: 3,
                templateBias: [.car, .spending, .brand, .loyalty, .priceOnObject],
                indifferencePressure: 0.8,
                superGunnaEnabled: true,
                stylePriority: 1.0,
                userProfileWeight: 0.01,
                signalProfileExposure: .none,
                repeatMotifEveryNBars: 4,
                motifPool: ["depend on my mood", "backend huge", "based on the mood"]
            )
        )
    }
}

// MARK: - Supporting Types

// These types are defined here to avoid duplication
// Other files should use NarrativeModels.StyleCharacteristics or import this module

struct StyleCharacteristics: Codable {
    let vocabularyLevel: String? // "simple", "complex", "mixed"
    let sentenceStructure: String? // "short-punchy", "long-flowing", "varied"
    let figurativeLanguage: String? // "heavy", "moderate", "minimal"
    let energyLevel: String? // "high", "medium", "low", "varied"
    let formalityLevel: String? // "street-slang", "formal", "mixed"
    let repetitionPatterns: String? // Description of repetition style
    let punctuationStyle: String? // Description of punctuation usage
}

struct TopicTreatmentModes: Codable {
    let women: String? // "aesthetic", "relational", "mixed", "not-present"
    let wealth: String? // "flexing", "burden", "ironic", "straightforward"
    let success: String? // "celebration", "obligation", "isolation", "mixed"
}
