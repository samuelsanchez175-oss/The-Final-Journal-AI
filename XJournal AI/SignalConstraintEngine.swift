import Foundation

// MARK: - Constraint Rules

struct ConstraintRules {
    let blockedLanguagePatterns: [String]      // Specific phrases/patterns to block
    let requiredImplications: [String]         // What must be implied, not stated
    let preferredOutcomes: [String]             // Prefer outcomes over processes
    let reductionRules: [String]                // What must be reduced, not silenced
    let promptInstructions: String             // Instructions for AI generation
    
    static func empty() -> ConstraintRules {
        return ConstraintRules(
            blockedLanguagePatterns: [],
            requiredImplications: [],
            preferredOutcomes: [],
            reductionRules: [],
            promptInstructions: ""
        )
    }
}

// MARK: - Signal Constraint Engine

class SignalConstraintEngine {
    static let shared = SignalConstraintEngine()
    
    private init() {}
    
    // MARK: - Main Constraint Generation
    
    func generateConstraints(mode: SignalMode, axes: SignalAxes) -> ConstraintRules {
        let baseConstraints = mode.getConstraints()
        
        // Build blocked patterns
        var blockedPatterns: [String] = []
        blockedPatterns.append(contentsOf: baseConstraints.blockedPatterns)
        
        // Add axis-specific blocks
        switch axes.exposureRisk {
        case .high:
            blockedPatterns.append("specific time markers")
            blockedPatterns.append("named locations")
            blockedPatterns.append("detailed sequences")
        case .medium:
            blockedPatterns.append("excessive detail")
        case .low:
            break
        }
        
        switch axes.authorityPosture {
        case .unstable:
            blockedPatterns.append("over-confident claims")
            blockedPatterns.append("unearned authority")
        case .emerging:
            blockedPatterns.append("excessive justification")
        case .established:
            break
        }
        
        // Build required implications
        var requiredImplications: [String] = []
        requiredImplications.append(contentsOf: baseConstraints.requiredImplications)
        
        // Add axis-specific implications
        switch axes.socialAction {
        case .withdraw:
            requiredImplications.append("distance without explanation")
        case .distance:
            requiredImplications.append("separation without hostility")
        case .assert:
            requiredImplications.append("position without justification")
        case .confess:
            requiredImplications.append("emotion without excess")
        case .warn:
            requiredImplications.append("threat without detail")
        case .flex:
            requiredImplications.append("status without explanation")
        }
        
        // Build preferred outcomes
        var preferredOutcomes: [String] = []
        preferredOutcomes.append(contentsOf: baseConstraints.preferredOutcomes)
        
        // Add axis-specific preferences
        if axes.exposureRisk == .high {
            preferredOutcomes.append("implication over statement")
            preferredOutcomes.append("outcome over process")
        }
        
        if axes.authorityPosture == .unstable {
            preferredOutcomes.append("restraint over expansion")
            preferredOutcomes.append("containment over expression")
        }
        
        // Build reduction rules
        var reductionRules: [String] = []
        reductionRules.append(contentsOf: baseConstraints.reductionRules)
        
        // Build prompt instructions
        let promptInstructions = buildPromptInstructions(
            mode: mode,
            axes: axes,
            blockedPatterns: blockedPatterns,
            requiredImplications: requiredImplications,
            preferredOutcomes: preferredOutcomes,
            reductionRules: reductionRules
        )
        
        return ConstraintRules(
            blockedLanguagePatterns: blockedPatterns,
            requiredImplications: requiredImplications,
            preferredOutcomes: preferredOutcomes,
            reductionRules: reductionRules,
            promptInstructions: promptInstructions
        )
    }
    
    // MARK: - Prompt Instructions Builder
    
    private func buildPromptInstructions(
        mode: SignalMode,
        axes: SignalAxes,
        blockedPatterns: [String],
        requiredImplications: [String],
        preferredOutcomes: [String],
        reductionRules: [String]
    ) -> String {
        var instructions: [String] = []
        
        // Mode context
        instructions.append("SIGNAL MODE: \(mode.displayName)")
        instructions.append("Mode Description: \(mode.description)")
        
        // Axes context
        instructions.append("CONTEXT AXES:")
        instructions.append("- Exposure Risk: \(axes.exposureRisk.rawValue)")
        instructions.append("- Authority Posture: \(axes.authorityPosture.rawValue)")
        instructions.append("- Social Action: \(axes.socialAction.rawValue)")
        instructions.append("- Audience Scope: \(axes.audienceScope.rawValue)")
        
        // Constraints
        if !blockedPatterns.isEmpty {
            instructions.append("")
            instructions.append("BLOCKED PATTERNS (DO NOT USE):")
            for pattern in blockedPatterns {
                instructions.append("- \(pattern)")
            }
        }
        
        if !requiredImplications.isEmpty {
            instructions.append("")
            instructions.append("REQUIRED IMPLICATIONS (MUST BE IMPLIED, NOT STATED):")
            for implication in requiredImplications {
                instructions.append("- \(implication)")
            }
        }
        
        if !preferredOutcomes.isEmpty {
            instructions.append("")
            instructions.append("PREFERRED OUTCOMES:")
            for outcome in preferredOutcomes {
                instructions.append("- \(outcome)")
            }
        }
        
        if !reductionRules.isEmpty {
            instructions.append("")
            instructions.append("REDUCTION RULES (REDUCE, DO NOT SILENCE):")
            for rule in reductionRules {
                instructions.append("- \(rule)")
            }
        }
        
        // Core principle
        instructions.append("")
        instructions.append("CORE PRINCIPLE: The SIGNAL LAYER enforces what must be removed, not what should be added. Generate language that operates within these constraints. Prefer implication over explanation, outcomes over processes, restraint over expansion.")
        
        return instructions.joined(separator: "\n")
    }
    
    // MARK: - Constraint Validation
    
    func validateText(text: String, against rules: ConstraintRules) -> (isValid: Bool, violations: [String]) {
        var violations: [String] = []
        let lowercased = text.lowercased()
        
        // Check blocked patterns
        for pattern in rules.blockedLanguagePatterns {
            // Simple substring check - in production, use more sophisticated NLP
            if lowercased.contains(pattern.lowercased()) {
                violations.append("Contains blocked pattern: \(pattern)")
            }
        }
        
        return (violations.isEmpty, violations)
    }
}
