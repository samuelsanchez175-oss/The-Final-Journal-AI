//
//  HardRejectionEngine.swift
//  XJournal AI
//
//  Model G Core v1.0 — Hard rejection rules.
//

import Foundation

// MARK: - Rejection Reason

enum RejectionReason: String, Codable {
    case bannedLexicon
    case syllableMismatch
    case lowIntentAlignment
    case abstractDensityTooHigh
    case clichéDetected
    case beatMisalignment
    case scoreBelowThreshold
}

// MARK: - Hard Rejection Engine

class HardRejectionEngine {
    private let scoringEngine = ScoringEngine()
    private let syllableTolerance = 2
    private let intentAlignmentThreshold = 0.6
    private let beatAlignmentFloor = 70.0  // 0-100 scale (spec says 7.0 on 0-10, equivalent)

    /// Returns nil if valid, explicit reason if rejected.
    func rejectIfNecessary(
        _ text: String,
        score: ScoreBreakdown,
        context: GenerationContext
    ) -> RejectionReason? {
        // 1. Score below threshold
        if score.totalScore < 72 {
            return .scoreBelowThreshold
        }

        // 2. Banned lexicon (stub: empty list for now)
        if containsBannedLexicon(text) {
            return .bannedLexicon
        }

        // 3. Syllable deviation > ±2
        let syllables = countSyllables(text)
        let deviation = abs(syllables - context.syllableTarget)
        if deviation > syllableTolerance {
            return .syllableMismatch
        }

        // 4. Intent misalignment below threshold
        if score.intentAlignment / 100.0 < intentAlignmentThreshold {
            return .lowIntentAlignment
        }

        // 5. Abstract density too high (stub: placeholder)
        if hasAbstractDensityTooHigh(text) {
            return .abstractDensityTooHigh
        }

        // 6. Cliché detected (stub: placeholder)
        if containsCliché(text) {
            return .clichéDetected
        }

        // 7. Beat alignment below 7.0 if beat active
        if context.beatFingerprint != nil && score.beatAlignment < beatAlignmentFloor {
            return .beatMisalignment
        }

        return nil
    }

    private func containsBannedLexicon(_ text: String) -> Bool {
        BannedLexiconStore.shared.containsBannedTerm(text)
    }

    private func countSyllables(_ text: String) -> Int {
        // Simple heuristic: approximate syllables from vowels
        let vowels = CharacterSet(charactersIn: "aeiouyAEIOUY")
        var count = 0
        for scalar in text.unicodeScalars {
            if vowels.contains(scalar) { count += 1 }
        }
        return max(1, count)
    }

    private func hasAbstractDensityTooHigh(_ text: String) -> Bool {
        // Stub: placeholder
        false
    }

    private func containsCliché(_ text: String) -> Bool {
        ClichéPhraseStore.shared.containsCliché(text)
    }
}
