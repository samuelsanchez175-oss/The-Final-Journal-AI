import Foundation

// MARK: - Narrative Validator
// Hard structural gate - validates only NarrativeAnalysis (never NarrativeDraft)
// Single entry point for validation

enum NarrativeValidationError: Error, LocalizedError {
    case emptyPrimaryThemes
    case invalidEmotionalTone(String)
    case invalidNarrativePhase(String)
    case invalidPerspective(String)
    case invalidEntityType(String)
    case summaryTooShort(Int)
    case missingRequiredField(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyPrimaryThemes:
            return "primaryThemes must contain at least 1 item"
        case .invalidEmotionalTone(let value):
            return "emotionalTone must be one of: neutral, confident, aggressive, melancholic, reflective, detached, hopeful, resentful (got: \(value))"
        case .invalidNarrativePhase(let value):
            return "narrativePhase must be one of: setup, assertion, conflict, reflection, resolution, aftermath (got: \(value))"
        case .invalidPerspective(let value):
            return "perspective must be one of: first_person, second_person, third_person, collective (got: \(value))"
        case .invalidEntityType(let value):
            return "entity type must be one of: person, place, object, concept, brand (got: \(value))"
        case .summaryTooShort(let length):
            return "summary must be at least 10 characters long (got \(length))"
        case .missingRequiredField(let field):
            return "Required field '\(field)' is missing"
        }
    }
}

struct NarrativeValidator {
    
    /// Validates a NarrativeAnalysis struct
    /// Throws NarrativeValidationError if validation fails
    static func validate(_ analysis: NarrativeAnalysis) throws {
        // Validate primaryThemes: minItems: 1
        if analysis.primaryThemes.isEmpty {
            throw NarrativeValidationError.emptyPrimaryThemes
        }
        
        // Validate all themes are non-empty strings
        for (index, theme) in analysis.primaryThemes.enumerated() {
            if theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw NarrativeValidationError.missingRequiredField("primaryThemes[\(index)]")
            }
        }
        
        for (index, theme) in analysis.secondaryThemes.enumerated() {
            if theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw NarrativeValidationError.missingRequiredField("secondaryThemes[\(index)]")
            }
        }
        
        // Validate detectedTones: allow empty (assembler/analysis default to [.neutral])
        let _ = analysis.detectedTones
        // Validate emotionalTone (legacy): derived from detectedTones.first
        let _ = analysis.emotionalTone
        
        // Validate narrativePhase enum
        let _ = analysis.narrativePhase // Will compile-time check enum
        
        // Validate perspective enum
        let _ = analysis.perspective // Will compile-time check enum
        
        // Validate entities
        for (index, entity) in analysis.entities.enumerated() {
            // Entity type is already validated by enum, but check value
            if entity.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw NarrativeValidationError.missingRequiredField("entities[\(index)].value")
            }
        }
        
        // Validate summary: minLength: 10
        if analysis.summary.count < 10 {
            throw NarrativeValidationError.summaryTooShort(analysis.summary.count)
        }
    }
}
