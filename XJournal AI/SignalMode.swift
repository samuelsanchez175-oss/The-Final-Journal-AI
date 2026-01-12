import Foundation

// MARK: - Signal Mode

enum SignalMode: String, Codable {
    case uncontainedVulnerability      // High emotion, high explanation, no closure
    case lossAcknowledgmentWithoutAttribution  // Loss admitted, cause withheld
    case voluntaryIsolation             // Distance without hostility
    case noRepair                       // Relationship closure, no reconciliation
    case informationRefusal             // Explanation blocked, ambiguity preferred
    case declarativeClosureWithoutEvidence  // Finality without proof
    case postChaosStabilization         // Structure, logistics, responsibility
    case defaultExpressive              // Low risk, exploratory writing
    
    var displayName: String {
        switch self {
        case .uncontainedVulnerability:
            return "Uncontained Vulnerability"
        case .lossAcknowledgmentWithoutAttribution:
            return "Loss Acknowledgment"
        case .voluntaryIsolation:
            return "Voluntary Isolation"
        case .noRepair:
            return "No Repair"
        case .informationRefusal:
            return "Information Refusal"
        case .declarativeClosureWithoutEvidence:
            return "Declarative Closure"
        case .postChaosStabilization:
            return "Post-Chaos Stabilization"
        case .defaultExpressive:
            return "Default Expressive"
        }
    }
    
    var description: String {
        switch self {
        case .uncontainedVulnerability:
            return "High emotion and explanation without closure. Authority unstable."
        case .lossAcknowledgmentWithoutAttribution:
            return "Loss admitted without naming cause or blame."
        case .voluntaryIsolation:
            return "Language of distance without hostility."
        case .noRepair:
            return "Relationship closure. No reconciliation allowed."
        case .informationRefusal:
            return "Explanation blocked. Ambiguity preferred."
        case .declarativeClosureWithoutEvidence:
            return "Finality without proof. Statements end discussion."
        case .postChaosStabilization:
            return "Structure, logistics, responsibility over spectacle."
        case .defaultExpressive:
            return "Low risk, exploratory writing."
        }
    }
}

// MARK: - Signal Constraints

struct SignalConstraints {
    let blockedPatterns: [String]      // Language patterns that cannot appear
    let requiredImplications: [String]  // What must be implied, not stated
    let preferredOutcomes: [String]    // Prefer outcomes over processes
    let reductionRules: [String]       // What must be reduced, not silenced
    
    static func empty() -> SignalConstraints {
        return SignalConstraints(
            blockedPatterns: [],
            requiredImplications: [],
            preferredOutcomes: [],
            reductionRules: []
        )
    }
}

// MARK: - Signal Mode Resolver

class SignalModeResolver {
    static let shared = SignalModeResolver()
    
    private init() {}
    
    // MARK: - Mode Resolution
    
    func resolveMode(from profile: SignalProfile) -> SignalMode {
        // Priority order matters - check most specific first
        
        // 1. Uncontained Vulnerability: High emotion + high explanation + no closure
        if profile.hasHighEmotion && profile.hasHighExplanation && profile.hasWeakAuthority {
            return .uncontainedVulnerability
        }
        
        // 2. Information Refusal: Low explanation + high ambiguity (low specificity)
        if !profile.hasHighExplanation && !profile.hasHighSpecificity && profile.authorityPosture > 0.5 {
            return .informationRefusal
        }
        
        // 3. No Repair: Defensive tone + relationship closure language (detected via defensive framing)
        if profile.hasDefensiveTone && profile.explanationDensity > 0.4 {
            // Additional check: look for relationship closure markers in text analysis
            // For now, defensive + explanation suggests relationship issues
            return .noRepair
        }
        
        // 4. Voluntary Isolation: Distance without hostility (low emotion, low defensive)
        if !profile.hasHighEmotion && !profile.hasDefensiveTone && profile.authorityPosture > 0.4 {
            return .voluntaryIsolation
        }
        
        // 5. Loss Acknowledgment Without Attribution: High emotion but low specificity
        if profile.hasHighEmotion && !profile.hasHighSpecificity && profile.hasWeakAuthority {
            return .lossAcknowledgmentWithoutAttribution
        }
        
        // 6. Declarative Closure Without Evidence: High authority but low explanation
        if profile.authorityPosture > 0.6 && !profile.hasHighExplanation {
            return .declarativeClosureWithoutEvidence
        }
        
        // 7. Post-Chaos Stabilization: Low emotion, moderate authority, low specificity
        if !profile.hasHighEmotion && profile.authorityPosture > 0.4 && !profile.hasHighSpecificity {
            return .postChaosStabilization
        }
        
        // 8. Default: Everything else
        return .defaultExpressive
    }
    
    // MARK: - Constraint Generation
    
    func getConstraints(for mode: SignalMode) -> SignalConstraints {
        switch mode {
        case .uncontainedVulnerability:
            return SignalConstraints(
                blockedPatterns: [
                    "repeated grievance narration",
                    "loyalty justification",
                    "emotional redundancy"
                ],
                requiredImplications: [
                    "single-instance emotional admission",
                    "abstract pain language"
                ],
                preferredOutcomes: [
                    "reduction over silencing",
                    "containment over suppression"
                ],
                reductionRules: [
                    "reduce explanation density",
                    "reduce emotional repetition",
                    "maintain single emotional admission"
                ]
            )
            
        case .lossAcknowledgmentWithoutAttribution:
            return SignalConstraints(
                blockedPatterns: [
                    "naming cause",
                    "assigning blame",
                    "attribution language"
                ],
                requiredImplications: [
                    "loss without source",
                    "pain without perpetrator"
                ],
                preferredOutcomes: [
                    "acknowledgment over explanation",
                    "feeling over fact"
                ],
                reductionRules: [
                    "remove attribution",
                    "maintain loss acknowledgment"
                ]
            )
            
        case .voluntaryIsolation:
            return SignalConstraints(
                blockedPatterns: [
                    "hostile language",
                    "accusation",
                    "confrontation"
                ],
                requiredImplications: [
                    "distance without anger",
                    "separation without conflict"
                ],
                preferredOutcomes: [
                    "calm distance",
                    "peaceful separation"
                ],
                reductionRules: [
                    "remove hostility markers",
                    "maintain distance tone"
                ]
            )
            
        case .noRepair:
            return SignalConstraints(
                blockedPatterns: [
                    "reconciliation language",
                    "apology",
                    "outreach",
                    "repair attempts"
                ],
                requiredImplications: [
                    "closure without repair",
                    "finality without negotiation"
                ],
                preferredOutcomes: [
                    "closure over connection",
                    "end over repair"
                ],
                reductionRules: [
                    "remove repair language",
                    "maintain closure"
                ]
            )
            
        case .informationRefusal:
            return SignalConstraints(
                blockedPatterns: [
                    "explanation",
                    "justification",
                    "detail",
                    "specificity"
                ],
                requiredImplications: [
                    "ambiguity",
                    "implication over statement"
                ],
                preferredOutcomes: [
                    "silence over explanation",
                    "mystery over clarity"
                ],
                reductionRules: [
                    "remove explanation markers",
                    "prefer ambiguity"
                ]
            )
            
        case .declarativeClosureWithoutEvidence:
            return SignalConstraints(
                blockedPatterns: [
                    "proof",
                    "evidence",
                    "justification",
                    "explanation"
                ],
                requiredImplications: [
                    "statement without support",
                    "claim without proof"
                ],
                preferredOutcomes: [
                    "declaration over argument",
                    "finality over debate"
                ],
                reductionRules: [
                    "remove evidence markers",
                    "maintain declarative tone"
                ]
            )
            
        case .postChaosStabilization:
            return SignalConstraints(
                blockedPatterns: [
                    "spectacle",
                    "drama",
                    "emotional display"
                ],
                requiredImplications: [
                    "structure",
                    "logistics",
                    "responsibility"
                ],
                preferredOutcomes: [
                    "order over chaos",
                    "function over form"
                ],
                reductionRules: [
                    "remove dramatic language",
                    "maintain structural tone"
                ]
            )
            
        case .defaultExpressive:
            return SignalConstraints.empty()
        }
    }
}

// MARK: - Convenience Extension

extension SignalMode {
    static func resolveMode(from profile: SignalProfile) -> SignalMode {
        return SignalModeResolver.shared.resolveMode(from: profile)
    }
    
    func getConstraints() -> SignalConstraints {
        return SignalModeResolver.shared.getConstraints(for: self)
    }
}
