//
//  ScoringEngine.swift
//  XJournal AI
//
//  Model G Core v1.0 — Weighted bar scoring.
//

import Foundation

// MARK: - Score Breakdown

struct ScoreBreakdown {
    let specificity: Double
    let glide: Double
    let intentAlignment: Double
    let culturalIntegration: Double
    let internalEcho: Double
    let edgeConfidence: Double
    let beatAlignment: Double
    let totalScore: Double

    /// Hard threshold: reject if totalScore < 72.
    var passesThreshold: Bool {
        totalScore >= 72
    }
}

// MARK: - Scoring Engine

class ScoringEngine {
    private let scoreThreshold: Double = 72

    /// Evaluate a bar and return structured score breakdown.
    /// Base weights: Specificity 0.28, Glide 0.22, IntentAlignment 0.18, CulturalIntegration 0.14,
    /// InternalEcho 0.10, EdgeConfidence 0.08, BeatAlignment 0.12 (if beat present).
    func evaluateBar(_ text: String, context: GenerationContext) -> ScoreBreakdown {
        let specificity = scoreSpecificity(text)
        let glide = scoreGlide(text)
        let intentAlignment = scoreIntentAlignment(text, intent: context.intent)
        let culturalIntegration = scoreCulturalIntegration(text, context: context)
        let internalEcho = scoreInternalEcho(text, existingBars: context.existingBars)
        let edgeConfidence = scoreEdgeConfidence(text)
        var beatAlignment = context.beatFingerprint != nil ? scoreBeatAlignment(text, context: context) : 0
        if context.flowDNAFeatures != nil || context.perBarSyllableTargets != nil {
            beatAlignment = scoreBeatAlignment(text, context: context)
        }
        var cadenceBonus: Double = 0
        if context.flowDNAFeatures != nil {
            cadenceBonus = scoreCadenceAlignment(text, context: context)
        }

        var weights = getWeights(for: context)
        applyStyleModifiers(&weights, style: context.styleProfile)
        applyUserTasteModifiers(&weights, taste: context.userTasteVector)

        let total = specificity * weights.specificity +
            glide * weights.glide +
            intentAlignment * weights.intentAlignment +
            culturalIntegration * weights.culturalIntegration +
            internalEcho * weights.internalEcho +
            edgeConfidence * weights.edgeConfidence +
            beatAlignment * weights.beatAlignment +
            cadenceBonus * (context.flowDNAFeatures != nil ? 0.05 : 0)

        let cadenceWeight = context.flowDNAFeatures != nil ? 0.05 : 0.0
        let sum = weights.specificity + weights.glide + weights.intentAlignment +
            weights.culturalIntegration + weights.internalEcho + weights.edgeConfidence + weights.beatAlignment + cadenceWeight
        let normalizedTotal = sum > 0 ? total / sum : 75

        return ScoreBreakdown(
            specificity: specificity,
            glide: glide,
            intentAlignment: intentAlignment,
            culturalIntegration: culturalIntegration,
            internalEcho: internalEcho,
            edgeConfidence: edgeConfidence,
            beatAlignment: beatAlignment,
            totalScore: min(100, max(0, normalizedTotal))
        )
    }

    func shouldReject(breakdown: ScoreBreakdown) -> Bool {
        breakdown.totalScore < scoreThreshold
    }

    // MARK: - Dimension Scorers

    private func scoreSpecificity(_ text: String) -> Double {
        let words = text.lowercased().components(separatedBy: .whitespaces).filter { $0.count > 1 }
        guard !words.isEmpty else { return 50 }
        var score = 50.0
        for word in words {
            if word.rangeOfCharacter(from: .decimalDigits) != nil { score += 5 }
            if word.count > 6 { score += 3 }
        }
        return min(100, score + Double(words.count) * 2)
    }

    private func scoreGlide(_ text: String) -> Double {
        let vowels = CharacterSet(charactersIn: "aeiouyAEIOUY")
        var vowelCount = 0
        var total = 0
        for scalar in text.unicodeScalars where CharacterSet.letters.contains(scalar) {
            total += 1
            if vowels.contains(scalar) { vowelCount += 1 }
        }
        guard total > 0 else { return 50 }
        let ratio = Double(vowelCount) / Double(total)
        return 40 + ratio * 60
    }

    private func scoreIntentAlignment(_ text: String, intent: GenerationIntent) -> Double {
        let lower = text.lowercased()
        let mustInclude = Set(intent.mustInclude.map { $0.lowercased() })
        let mustAvoid = Set(intent.mustAvoid.map { $0.lowercased() })

        var score = 70.0
        for term in mustInclude {
            if lower.contains(term) { score += 10 }
        }
        for term in mustAvoid {
            if lower.contains(term) { score -= 25 }
        }
        return min(100, max(0, score))
    }

    private func scoreCulturalIntegration(_ text: String, context: GenerationContext) -> Double {
        let words = text.components(separatedBy: .whitespaces).filter { $0.count > 2 }
        guard !words.isEmpty else { return 50 }
        let baseScore = min(100, 50 + Double(words.count) * 3)

        guard let layer = context.luxuryLayer else {
            return baseScore
        }

        let lowercased = text.lowercased()
        let uniqueTerms = Array(Set(layer.allTerms.map { $0.lowercased() }))
        let matchedCount = uniqueTerms.filter { term in
            !term.isEmpty && lowercased.contains(term)
        }.count
        let luxuryBoost = min(15.0, Double(matchedCount) * 5.0)
        return min(100, baseScore + luxuryBoost)
    }

    private func scoreInternalEcho(_ text: String, existingBars: [String]) -> Double {
        guard let lastBar = existingBars.last else { return 70 }
        let lastWords = Set(lastBar.lowercased().components(separatedBy: .whitespaces).filter { $0.count > 2 })
        let currWords = Set(text.lowercased().components(separatedBy: .whitespaces).filter { $0.count > 2 })
        let overlap = Double(lastWords.intersection(currWords).count) / Double(max(1, lastWords.count))
        return 50 + overlap * 50
    }

    private func scoreEdgeConfidence(_ text: String) -> Double {
        let words = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard !words.isEmpty else { return 50 }
        let avgLen = Double(words.map(\.count).reduce(0, +)) / Double(words.count)
        return min(100, 40 + avgLen * 4)
    }

    private func scoreBeatAlignment(_ text: String, context: GenerationContext) -> Double {
        let syllables = countSyllables(text)
        let target = context.syllableTarget
        let deviation = abs(syllables - target)
        if deviation == 0 { return 90 }
        if deviation <= 1 { return 80 }
        if deviation <= 2 { return 70 }
        return max(0, 70 - Double(deviation) * 10)
    }

    private func scoreCadenceAlignment(_ text: String, context: GenerationContext) -> Double {
        guard context.flowDNAFeatures != nil else { return 0 }
        let syllables = countSyllables(text)
        let target = context.syllableTarget
        let deviation = abs(syllables - target)
        if deviation <= 1 { return 80 }
        if deviation <= 2 { return 60 }
        return max(0, 60 - Double(deviation) * 10)
    }

    private func countSyllables(_ text: String) -> Int {
        let phonemes = getGlobalCMUDICTStore()
        let words = text.lowercased().components(separatedBy: .whitespaces)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
        var total = 0
        for word in words {
            if let ph = phonemes[word] {
                let syll = ph.filter { $0.last?.isNumber == true }.count
                total += syll > 0 ? syll : 1
            } else {
                let vowels = CharacterSet(charactersIn: "aeiouy")
                let v = word.unicodeScalars.filter { vowels.contains($0) }.count
                total += v > 0 ? v : 1
            }
        }
        return max(1, total)
    }

    // MARK: - Weight Modifiers

    private func getWeights(for context: GenerationContext) -> (specificity: Double, glide: Double, intentAlignment: Double, culturalIntegration: Double, internalEcho: Double, edgeConfidence: Double, beatAlignment: Double) {
        let hasBeat = context.beatFingerprint != nil || context.flowDNAFeatures != nil || context.perBarSyllableTargets != nil
        return (
            specificity: 0.28,
            glide: 0.22,
            intentAlignment: 0.18,
            culturalIntegration: 0.14,
            internalEcho: 0.10,
            edgeConfidence: 0.08,
            beatAlignment: hasBeat ? 0.12 : 0.0
        )
    }

    private func applyStyleModifiers(_ weights: inout (specificity: Double, glide: Double, intentAlignment: Double, culturalIntegration: Double, internalEcho: Double, edgeConfidence: Double, beatAlignment: Double), style: StyleProfile) {
        weights.specificity *= style.specificityModifier
        weights.glide *= style.glideModifier
        weights.edgeConfidence *= style.edgeModifier
    }

    private func applyUserTasteModifiers(_ weights: inout (specificity: Double, glide: Double, intentAlignment: Double, culturalIntegration: Double, internalEcho: Double, edgeConfidence: Double, beatAlignment: Double), taste: UserTasteVector) {
        let cap: Double = 0.15
        weights.specificity = max(0, weights.specificity + min(cap, taste.specificityBias * 0.01))
        weights.glide = max(0, weights.glide + min(cap, taste.glideBias * 0.01))
        weights.edgeConfidence = max(0, weights.edgeConfidence + min(cap, taste.edgeBias * 0.01))
        weights.culturalIntegration = max(0, weights.culturalIntegration + min(cap, taste.culturalBias * 0.01))
    }
}
