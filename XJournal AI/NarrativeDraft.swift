import Foundation

// MARK: - Narrative Draft
// Probabilistic, incomplete inference output
// All fields are optional - represents incomplete analysis

struct NarrativeDraft: Codable {
    let primaryThemes: [String]?
    let secondaryThemes: [String]?
    /// Multi-tone: array of tones detected in the verse. If missing, derived from emotionalTone as [emotionalTone].
    let detectedTones: [EmotionalTone]?
    let emotionalTone: EmotionalTone?
    let narrativePhase: NarrativePhase?
    let perspective: Perspective?
    let entities: [Entity]?
    
    // Legacy optional fields (for backward compatibility)
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
    let summary: String? // Optional in draft, required in final analysis
    
    init(
        primaryThemes: [String]? = nil,
        secondaryThemes: [String]? = nil,
        detectedTones: [EmotionalTone]? = nil,
        emotionalTone: EmotionalTone? = nil,
        narrativePhase: NarrativePhase? = nil,
        perspective: Perspective? = nil,
        entities: [Entity]? = nil,
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
        summary: String? = nil
    ) {
        self.primaryThemes = primaryThemes
        self.secondaryThemes = secondaryThemes
        self.detectedTones = detectedTones
        self.emotionalTone = emotionalTone
        self.narrativePhase = narrativePhase
        self.perspective = perspective
        self.entities = entities
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
        self.summary = summary
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode optional fields
        primaryThemes = try container.decodeIfPresent([String].self, forKey: .primaryThemes)
        secondaryThemes = try container.decodeIfPresent([String].self, forKey: .secondaryThemes)
        
        // Decode detectedTones (array of strings → [EmotionalTone]); if missing, set nil (derived after emotionalTone)
        if let toneStrings = try? container.decode([String].self, forKey: .detectedTones) {
            detectedTones = toneStrings.compactMap { EmotionalTone(rawValue: $0) }
        } else {
            detectedTones = nil
        }
        
        // Decode emotionalTone (string → enum, with fallback)
        if let toneString = try? container.decode(String.self, forKey: .emotionalTone) {
            emotionalTone = EmotionalTone(rawValue: toneString)
        } else {
            emotionalTone = nil
        }
        
        // Decode narrativePhase (string → enum, with legacy mapping)
        if let phaseString = try? container.decode(String.self, forKey: .narrativePhase) {
            // Map legacy values to new enum values
            let mappedPhase = Self.mapLegacyNarrativePhase(phaseString)
            narrativePhase = NarrativePhase(rawValue: mappedPhase)
        } else {
            narrativePhase = nil
        }
        
        // Decode perspective (string → enum, with legacy mapping)
        if let perspectiveString = try? container.decode(String.self, forKey: .perspective) {
            // Handle legacy format (first-person vs first_person)
            let normalizedPerspective = perspectiveString.replacingOccurrences(of: "-", with: "_")
            perspective = Perspective(rawValue: normalizedPerspective)
        } else {
            perspective = nil
        }
        
        // Decode entities
        if let entityObjects = try? container.decode([Entity].self, forKey: .entities) {
            entities = entityObjects
        } else if let entityStrings = try? container.decode([String].self, forKey: .entities) {
            // Convert legacy format to new format
            entities = entityStrings.map { Entity(type: .concept, value: $0) }
        } else {
            entities = nil
        }
        
        // Legacy optional fields
        underlyingThemes = try container.decodeIfPresent([String].self, forKey: .underlyingThemes)
        topicTreatmentModes = try container.decodeIfPresent(TopicTreatmentModes.self, forKey: .topicTreatmentModes)
        voiceType = try container.decodeIfPresent(String.self, forKey: .voiceType)
        thematicContradictions = try container.decodeIfPresent([String].self, forKey: .thematicContradictions)
        narrativeMomentum = try container.decodeIfPresent(String.self, forKey: .narrativeMomentum)
        contextualPlacement = try container.decodeIfPresent(String.self, forKey: .contextualPlacement)
        styleCharacteristics = try container.decodeIfPresent(StyleCharacteristics.self, forKey: .styleCharacteristics)
        keyPhrases = try container.decodeIfPresent([String].self, forKey: .keyPhrases)
        storyElements = try container.decodeIfPresent([String].self, forKey: .storyElements)
        continuationNeeds = try container.decodeIfPresent(String.self, forKey: .continuationNeeds)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode optional fields
        try container.encodeIfPresent(primaryThemes, forKey: .primaryThemes)
        try container.encodeIfPresent(secondaryThemes, forKey: .secondaryThemes)
        try container.encodeIfPresent(detectedTones?.map(\.rawValue), forKey: .detectedTones)
        try container.encodeIfPresent(emotionalTone?.rawValue, forKey: .emotionalTone)
        try container.encodeIfPresent(narrativePhase?.rawValue, forKey: .narrativePhase)
        try container.encodeIfPresent(perspective?.rawValue, forKey: .perspective)
        try container.encodeIfPresent(entities, forKey: .entities)
        
        // Legacy optional fields
        try container.encodeIfPresent(underlyingThemes, forKey: .underlyingThemes)
        try container.encodeIfPresent(topicTreatmentModes, forKey: .topicTreatmentModes)
        try container.encodeIfPresent(voiceType, forKey: .voiceType)
        try container.encodeIfPresent(thematicContradictions, forKey: .thematicContradictions)
        try container.encodeIfPresent(narrativeMomentum, forKey: .narrativeMomentum)
        try container.encodeIfPresent(contextualPlacement, forKey: .contextualPlacement)
        try container.encodeIfPresent(styleCharacteristics, forKey: .styleCharacteristics)
        try container.encodeIfPresent(keyPhrases, forKey: .keyPhrases)
        try container.encodeIfPresent(storyElements, forKey: .storyElements)
        try container.encodeIfPresent(continuationNeeds, forKey: .continuationNeeds)
        try container.encodeIfPresent(summary, forKey: .summary)
    }
    
    enum CodingKeys: String, CodingKey {
        case primaryThemes
        case secondaryThemes
        case detectedTones
        case emotionalTone
        case narrativePhase
        case perspective
        case entities
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
        case summary
    }
    
    // MARK: - Legacy Value Mapping
    
    private static func mapLegacyNarrativePhase(_ legacyValue: String) -> String {
        // Map legacy API values to enum values
        switch legacyValue.lowercased() {
        case "intro", "setup":
            return "setup"
        case "build", "assertion":
            return "assertion"
        case "conflict":
            return "conflict"
        case "reflection":
            return "reflection"
        case "outro", "resolution":
            return "resolution"
        case "bridge", "aftermath":
            return "aftermath"
        default:
            // If it matches an enum value, use it; otherwise default to reflection
            return NarrativePhase(rawValue: legacyValue)?.rawValue ?? "reflection"
        }
    }
}
