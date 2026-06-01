//
//  TasteScorer.swift
//  XJournal AI
//
//  Taste scoring for melodic trap: intent consistency, verse quality, hook quality.
//  Used to select best-of-N candidates and reject low-quality output.
//

import Foundation

// MARK: - Taste Score Result

struct TasteScore {
    let composite: Double
    let intentConsistency: Double
    let internalRhyme: Double
    let specificity: Double
    let novelty: Double
    let imagery: Double
    let effortlessTone: Double
    /// For hooks only: emotional clarity, catchiness, syllable fit
    let hookScore: Double?
    
    var passesThreshold: Bool { composite >= 0.5 }
}

// MARK: - Taste Scorer

class TasteScorer {
    static let shared = TasteScorer()
    
    private var previousBarsThisSession: [String] = []
    private let maxPreviousBars = 20
    
    private init() {}
    
    // MARK: - Verse Scoring
    
    /// Score a candidate bar for verse quality.
    /// Weights: intent consistency 0.20, internal rhyme 0.15, specificity 0.20, novelty 0.10, imagery 0.20, effortless tone 0.15
    func scoreVerse(
        bar: String,
        intent: GenerationIntent,
        previousBars: [String] = []
    ) -> TasteScore {
        let intentConsistency = scoreIntentConsistency(bar: bar, intent: intent)
        let internalRhyme = scoreInternalRhyme(bar: bar)
        let specificity = scoreSpecificity(bar: bar)
        let novelty = scoreNovelty(bar: bar, previousBars: previousBars)
        let imagery = scoreImagery(bar: bar)
        let effortlessTone = scoreEffortlessTone(bar: bar)
        
        let composite = (intentConsistency * 0.20) +
            (internalRhyme * 0.15) +
            (specificity * 0.20) +
            (novelty * 0.10) +
            (imagery * 0.20) +
            (effortlessTone * 0.15)
        
        return TasteScore(
            composite: min(1.0, composite),
            intentConsistency: intentConsistency,
            internalRhyme: internalRhyme,
            specificity: specificity,
            novelty: novelty,
            imagery: imagery,
            effortlessTone: effortlessTone,
            hookScore: nil
        )
    }
    
    // MARK: - Hook Scoring
    
    /// Score a hook line. Different priorities: emotional clarity, catchiness, 6-10 syllables.
    func scoreHook(
        line: String,
        intent: GenerationIntent
    ) -> TasteScore {
        let intentConsistency = scoreIntentConsistency(bar: line, intent: intent)
        let emotionalClarity = scoreEmotionalClarity(line: line, intent: intent)
        let catchiness = scoreCatchiness(line: line)
        let syllableFit = scoreHookSyllableFit(line: line)
        
        let hookScore = (emotionalClarity * 0.35) + (catchiness * 0.35) + (syllableFit * 0.30)
        let composite = (intentConsistency * 0.40) + (hookScore * 0.60)
        
        return TasteScore(
            composite: min(1.0, composite),
            intentConsistency: intentConsistency,
            internalRhyme: 0,
            specificity: 0,
            novelty: 0,
            imagery: 0,
            effortlessTone: 0,
            hookScore: hookScore
        )
    }
    
    // MARK: - Intent Consistency Score
    
    private func scoreIntentConsistency(bar: String, intent: GenerationIntent) -> Double {
        let lower = bar.lowercased()
        var score = 0.5
        
        // Reward: must-include concepts present
        for concept in intent.mustInclude {
            if lower.contains(concept.lowercased()) {
                score += 0.15
            }
        }
        score = min(1.0, score)
        
        // Penalty: must-avoid present
        for avoid in intent.mustAvoid {
            if lower.contains(avoid.lowercased()) {
                score -= 0.3
            }
        }
        
        // Penalty: tone mismatch markers
        let toneMismatchMarkers: [String: [String]] = [
            "reflective": ["party time", "let's go", "turn up", "lit"],
            "dark": ["sunshine", "happy", "celebrate", "amazing"],
            "toxic": ["i love", "forever", "together"],
            "numb": ["i feel", "i'm so", "so emotional"]
        ]
        if let mismatches = toneMismatchMarkers[intent.tone.rawValue] {
            for m in mismatches {
                if lower.contains(m) {
                    score -= 0.2
                }
            }
        }
        
        // Reward: theme keyword overlap
        let themeWords = intent.theme.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }
        var overlap = 0
        for word in themeWords {
            if lower.contains(word) {
                overlap += 1
            }
        }
        if overlap > 0 {
            score += Double(overlap) * 0.05
        }
        
        return max(0.0, min(1.0, score))
    }
    
    // MARK: - Internal Rhyme
    
    private func scoreInternalRhyme(bar: String) -> Double {
        let words = bar.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { $0.count > 2 }
        
        guard words.count >= 2 else { return 0.5 }
        
        var rhymeCount = 0
        for i in 0..<words.count {
            for j in (i+1)..<words.count {
                if wordsShareRhyme(words[i], words[j]) {
                    rhymeCount += 1
                }
            }
        }
        
        if rhymeCount >= 2 { return 1.0 }
        if rhymeCount >= 1 { return 0.7 }
        return 0.4
    }
    
    private func wordsShareRhyme(_ a: String, _ b: String) -> Bool {
        let dict = FJCMUDICTStore.shared.phonemesByWord
        guard let phonemesA = dict[a.lowercased()],
              let phonemesB = dict[b.lowercased()] else {
            return false
        }
        let vowelA = phonemesA.first { $0.last?.isNumber == true }
        let vowelB = phonemesB.first { $0.last?.isNumber == true }
        guard let va = vowelA, let vb = vowelB else { return false }
        return va == vb
    }
    
    // MARK: - Specificity
    
    private func scoreSpecificity(bar: String) -> Double {
        let lower = bar.lowercased()
        var score = 0.3
        
        let rewardTerms = ["gucci", "prada", "maybach", "phantom", "rolex", "diamond", "chrome", "velvet", "syrup", "double cup", "carbon", "marble"]
        for term in rewardTerms {
            if lower.contains(term) { score += 0.1 }
        }
        
        let penalizeTerms = ["hustle", "grind", "success", "vision", "power", "dreams", "ambition", "winning"]
        for term in penalizeTerms {
            if lower.contains(term) { score -= 0.15 }
        }
        
        let numbers = bar.filter { $0.isNumber }
        if !numbers.isEmpty { score += 0.1 }
        
        return max(0.0, min(1.0, score))
    }
    
    // MARK: - Novelty
    
    private func scoreNovelty(bar: String, previousBars: [String]) -> Double {
        let lower = bar.lowercased()
        let words = Set(lower.components(separatedBy: .whitespacesAndNewlines).filter { $0.count > 2 })
        
        var overlapCount = 0
        for prev in previousBars {
            let prevWords = Set(prev.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { $0.count > 2 })
            overlapCount += words.intersection(prevWords).count
        }
        
        let overlapRatio = previousBars.isEmpty ? 0 : Double(overlapCount) / Double(max(1, words.count * previousBars.count))
        return max(0.0, 1.0 - overlapRatio)
    }
    
    // MARK: - Imagery
    
    private func scoreImagery(bar: String) -> Double {
        let lower = bar.lowercased()
        var score = 0.4
        
        let movementVerbs = ["pull", "push", "drive", "slide", "roll", "flow", "drip", "pour"]
        let sensory = ["chrome", "velvet", "ice", "diamond", "marble", "carbon", "syrup", "flooded"]
        for term in movementVerbs + sensory {
            if lower.contains(term) { score += 0.08 }
        }
        
        let abstract = ["success", "dreams", "vision", "hustle", "grind"]
        for term in abstract {
            if lower.contains(term) { score -= 0.1 }
        }
        
        return max(0.0, min(1.0, score))
    }
    
    // MARK: - Effortless Tone
    
    private func scoreEffortlessTone(bar: String) -> Double {
        let lower = bar.lowercased()
        var score = 0.8
        
        let penalize = ["i just", "i'm really", "because", "so that", "in order to", "that's why", "the reason"]
        for p in penalize {
            if lower.contains(p) { score -= 0.2 }
        }
        
        let reward = ["i got", "i run", "i own", "i control", "i don't care"]
        for r in reward {
            if lower.contains(r) { score += 0.05 }
        }
        
        return max(0.0, min(1.0, score))
    }
    
    // MARK: - Hook-Specific Scores
    
    private func scoreEmotionalClarity(line: String, intent: GenerationIntent) -> Double {
        let lower = line.lowercased()
        var score = 0.5
        
        for concept in intent.mustInclude.prefix(3) {
            if lower.contains(concept.lowercased()) {
                score += 0.15
            }
        }
        
        let emotionalMarkers = ["when", "now", "same", "switch", "quiet", "down", "up", "feel", "know"]
        for m in emotionalMarkers {
            if lower.contains(m) { score += 0.03 }
        }
        
        return min(1.0, score)
    }
    
    private func scoreCatchiness(line: String) -> Double {
        let words = line.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        guard !words.isEmpty else { return 0.5 }
        
        var score = 0.5
        if words.count <= 8 { score += 0.2 }
        if line.contains(",") || line.contains("'") { score += 0.1 }
        if words.count >= 4 && words.count <= 10 { score += 0.1 }
        
        return min(1.0, score)
    }
    
    private func scoreHookSyllableFit(line: String) -> Double {
        let count = Syllabifier.syllableCount(line: line)
        if count >= 6 && count <= 10 { return 1.0 }
        if count >= 5 && count <= 11 { return 0.7 }
        if count >= 4 && count <= 12 { return 0.5 }
        return 0.3
    }
    
    // MARK: - Session Tracking
    
    func recordBar(_ bar: String) {
        previousBarsThisSession.append(bar)
        if previousBarsThisSession.count > maxPreviousBars {
            previousBarsThisSession.removeFirst()
        }
    }
    
    func resetSession() {
        previousBarsThisSession.removeAll()
    }
}

// MARK: - Syllabifier Line Extension

extension Syllabifier {
    static func syllableCount(line: String) -> Int {
        line.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .map { syllableCount(word: $0) }
            .reduce(0, +)
    }
}
