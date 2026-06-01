import Foundation

// MARK: - Tasteful Constraint Examples
// This file contains examples of how to add new tasteful constraints to the SIGNAL LAYER

// =======================================================
// EXAMPLE 1: Generic Comparison Constraint
// =======================================================

extension SignalMode {
    // Add to existing mode or create new mode
    
    static func addGenericComparisonConstraint(to constraints: SignalConstraints) -> SignalConstraints {
        // Create new instance with combined arrays
        return SignalConstraints(
            blockedPatterns: constraints.blockedPatterns + [
                "generic comparison markers",
                "borrowed comparisons",
                "unearned references"
            ],
            requiredImplications: constraints.requiredImplications + [
                "comparison must be earned through experience",
                "reference must be lived, not borrowed"
            ],
            preferredOutcomes: constraints.preferredOutcomes + [
                "earned reference over borrowed",
                "lived comparison over generic"
            ],
            reductionRules: constraints.reductionRules + [
                "remove generic comparison markers",
                "ground references in personal experience"
            ]
        )
    }
}

// Signal Note Template:
// "This reference sounds borrowed, not lived. Either ground it in your experience or remove it."

// =======================================================
// EXAMPLE 2: Show Don't Tell Constraint
// =======================================================

extension SignalMode {
    static func addShowDontTellConstraint(to constraints: SignalConstraints) -> SignalConstraints {
        // Create new instance with combined arrays
        return SignalConstraints(
            blockedPatterns: constraints.blockedPatterns + [
                "direct emotion statements",
                "I feel",
                "I'm sad",
                "I'm angry",
                "stating emotion instead of showing"
            ],
            requiredImplications: constraints.requiredImplications + [
                "emotion through action",
                "feeling through behavior",
                "state through implication"
            ],
            preferredOutcomes: constraints.preferredOutcomes + [
                "showing over telling",
                "action over statement",
                "behavior over declaration"
            ],
            reductionRules: constraints.reductionRules + [
                "remove direct emotion statements",
                "show emotion through action or imagery"
            ]
        )
    }
}

// Signal Note Template:
// "This states the emotion instead of showing it. Let the action carry the feeling."

// =======================================================
// EXAMPLE 3: Earned Flex Constraint
// =======================================================

extension SignalMode {
    static func addEarnedFlexConstraint(to constraints: SignalConstraints) -> SignalConstraints {
        // Create new instance with combined arrays
        return SignalConstraints(
            blockedPatterns: constraints.blockedPatterns + [
                "unearned status claims",
                "flexing without consequence",
                "naming success without showing cost",
                "status without proof"
            ],
            requiredImplications: constraints.requiredImplications + [
                "status through consequence",
                "success through cost",
                "flex through implication, not statement"
            ],
            preferredOutcomes: constraints.preferredOutcomes + [
                "earned flex over named flex",
                "consequence over claim",
                "proof over statement"
            ],
            reductionRules: constraints.reductionRules + [
                "remove unearned status claims",
                "show the cost or consequence of success"
            ]
        )
    }
}

// Signal Note Template:
// "This flex names success without showing consequence. Show the cost, not just the win."

// =======================================================
// EXAMPLE 4: Temporal Restraint Constraint
// =======================================================

extension SignalMode {
    static func addTemporalRestraintConstraint(to constraints: SignalConstraints) -> SignalConstraints {
        // Create new instance with combined arrays
        return SignalConstraints(
            blockedPatterns: constraints.blockedPatterns + [
                "excessive time markers",
                "specific dates",
                "chronological sequences",
                "yesterday",
                "today",
                "tomorrow",
                "last week"
            ],
            requiredImplications: constraints.requiredImplications + [
                "time through implication",
                "sequence through suggestion",
                "temporal flow without markers"
            ],
            preferredOutcomes: constraints.preferredOutcomes + [
                "timeless over dated",
                "implication over marker",
                "suggestion over statement"
            ],
            reductionRules: constraints.reductionRules + [
                "remove specific time markers",
                "let sequence imply itself"
            ]
        )
    }
}

// Signal Note Template:
// "Time markers here reduce mystique. Let the sequence imply itself."

// =======================================================
// EXAMPLE 5: Process Over Outcome Constraint
// =======================================================

extension SignalMode {
    static func addProcessOverOutcomeConstraint(to constraints: SignalConstraints) -> SignalConstraints {
        // Create new instance with combined arrays
        return SignalConstraints(
            blockedPatterns: constraints.blockedPatterns + [
                "explaining how or why",
                "process description",
                "method explanation"
            ],
            requiredImplications: constraints.requiredImplications + [
                "outcome over process",
                "result over method",
                "what over how"
            ],
            preferredOutcomes: constraints.preferredOutcomes + [
                "outcome over process",
                "result over explanation",
                "what happened over how it happened"
            ],
            reductionRules: constraints.reductionRules + [
                "remove process explanation",
                "keep outcome, remove method"
            ]
        )
    }
}

// Signal Note Template:
// "This explains the process instead of showing the outcome. Remove the 'how' and keep the 'what'."

// =======================================================
// EXAMPLE 6: Borrowed Authority Constraint
// =======================================================

extension SignalMode {
    static func addBorrowedAuthorityConstraint(to constraints: SignalConstraints) -> SignalConstraints {
        // Create new instance with combined arrays
        return SignalConstraints(
            blockedPatterns: constraints.blockedPatterns + [
                "name-dropping without context",
                "borrowed cultural references",
                "unearned comparisons",
                "generic cultural markers"
            ],
            requiredImplications: constraints.requiredImplications + [
                "reference must be earned through experience",
                "comparison must be lived, not borrowed",
                "cultural marker must be personal"
            ],
            preferredOutcomes: constraints.preferredOutcomes + [
                "earned reference over borrowed",
                "lived comparison over generic",
                "personal marker over cultural"
            ],
            reductionRules: constraints.reductionRules + [
                "remove generic cultural references",
                "ground references in personal experience"
            ]
        )
    }
}

// Signal Note Template:
// "This reference sounds borrowed, not lived. Either ground it in your experience or remove it."

// =======================================================
// EXAMPLE 7: Audience Confusion Constraint
// =======================================================

extension SignalMode {
    static func addAudienceConfusionConstraint(to constraints: SignalConstraints) -> SignalConstraints {
        // Create new instance with combined arrays
        return SignalConstraints(
            blockedPatterns: constraints.blockedPatterns + [
                "generic audience language",
                "speaking to everyone and no one",
                "unclear target audience"
            ],
            requiredImplications: constraints.requiredImplications + [
                "specific audience",
                "targeted communication",
                "clear recipient"
            ],
            preferredOutcomes: constraints.preferredOutcomes + [
                "narrow audience over broad",
                "specific over generic",
                "targeted over universal"
            ],
            reductionRules: constraints.reductionRules + [
                "remove generic audience language",
                "narrow the audience"
            ]
        )
    }
}

// Signal Note Template:
// "It's not clear who this line is for. Narrowing the audience would sharpen the impact."

// =======================================================
// HOW TO INTEGRATE THESE EXAMPLES
// =======================================================

/*
 To add any of these constraints:

 1. Add to SignalMode.getConstraints() for specific mode:
 
    case .uncontainedVulnerability:
        var constraints = SignalConstraints(...)
        constraints = SignalMode.addGenericComparisonConstraint(to: constraints)
        return constraints

 2. Or add to SignalConstraintEngine.generateConstraints():
 
    if axes.socialAction == .flex {
        constraints = SignalMode.addEarnedFlexConstraint(to: constraints)
    }

 3. Add corresponding Signal Note Type:
 
    enum SignalNoteType {
        case borrowedReference
        case showDontTell
        case earnedFlex
        // etc.
    }

 4. Add detection logic in SignalNotes.determineDominantWeakness()
*/
