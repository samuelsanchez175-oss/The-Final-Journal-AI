//
//  ControlledDeviationEngine.swift
//  XJournal AI
//
//  Model G Core v1.0 — CRDP (Controlled Rule Deviation Protocol).
//

import Foundation

// MARK: - Deviation Type

enum DeviationType {
    case hyperSpecific
    case cadenceSwitch
    case coldMinimal
    case culturalDeepCut
    case elevatedMetaphor
}

// MARK: - Controlled Deviation Engine

class ControlledDeviationEngine {
    private let brillianceTriggerProbability: Double = 0.06
    private let deviationScoreThreshold: Double = 85
    private let scoringEngine = ScoringEngine()

    /// Maybe apply deviation. Returns (bar, deviationType) or (originalBar, nil).
    /// Rules: probability 0.06, only once per verse, not hook, not bars 15–16, must score ≥ 85.
    func maybeApplyDeviation(
        to bar: String,
        context: GenerationContext,
        currentAverage: Double,
        deviationAlreadyUsedThisVerse: Bool,
        barIndex: Int
    ) -> (String, DeviationType?) {
        // Not hook
        guard !context.isHook else { return (bar, nil) }

        // Not bars 15–16
        guard barIndex != 14 && barIndex != 15 else { return (bar, nil) }

        // Only once per verse
        guard !deviationAlreadyUsedThisVerse else { return (bar, nil) }

        // Average score ≥ 82
        guard currentAverage >= 82 else { return (bar, nil) }

        // Probability check
        guard Double.random(in: 0...1) < brillianceTriggerProbability else {
            return (bar, nil)
        }

        // Stub: for now return original. Full implementation would generate deviation variants.
        let breakdown = scoringEngine.evaluateBar(bar, context: context)
        guard breakdown.totalScore >= deviationScoreThreshold else {
            return (bar, nil)
        }

        // Stub: no actual deviation generation yet — would need LLM call
        return (bar, nil)
    }
}
