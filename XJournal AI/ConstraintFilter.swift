import Foundation
import NaturalLanguage

// MARK: - Scored Candidate

struct ScoredCandidate: Identifiable {
    let id: UUID
    let line: RapLine
    let score: Double
    let rhymeScore: Double
    let syllableScore: Double
    let semanticScore: Double
    let flowScore: Double
}

// MARK: - Constraint Filter

class ConstraintFilter {
    // Provider for CMUdict phoneme map to avoid hard dependency on a concrete type
    private let phonemeStoreProvider: () -> [String: [String]]
    
    init(phonemeStoreProvider: @escaping () -> [String: [String]]) {
        // Require provider to be passed in explicitly to avoid direct dependency on FJCMUDICTStore
        self.phonemeStoreProvider = phonemeStoreProvider
    }

    // Scoring weights - prioritize rhyme matching
    private let semanticWeight: Double = 0.2
    private let rhymeWeight: Double = 0.6 // Increased from 0.3 to prioritize rhymes
    private let syllableWeight: Double = 0.15
    private let flowWeight: Double = 0.05
    
    // Syllable tolerance
    private let syllableTolerance: Int = 1
    
    func filterCandidates(
        candidates: [RapLine],
        metrics: RapMetrics
    ) -> [ScoredCandidate] {
        var scored: [ScoredCandidate] = []
        
        // If we have a rhyme target, prioritize candidates that rhyme
        let hasRhymeTarget = metrics.rhymeTarget != nil && !metrics.rhymeTarget!.isEmpty
        
        for candidate in candidates {
            // Filter by syllable tolerance (relaxed if we have a rhyme target)
            let syllableDiff = abs(candidate.syllableCount - (metrics.syllableTarget ?? 0))
            let maxSyllableDiff = hasRhymeTarget ? syllableTolerance + 1 : syllableTolerance
            guard syllableDiff <= maxSyllableDiff else { continue }
            
            // Calculate scores
            let rhymeScore = calculateRhymeScore(
                candidate: candidate,
                target: metrics.rhymeTarget
            )
            
            let syllableScore = calculateSyllableScore(
                candidate: candidate,
                target: metrics.syllableTarget
            )
            
            // Semantic score (placeholder - would use embeddings in production)
            let semanticScore = 0.5 // Default neutral score
            
            // Flow score (based on syllable variance)
            let flowScore = calculateFlowScore(
                candidate: candidate,
                targetVariance: metrics.syllableVariance
            )
            
            // Weighted total score
            let totalScore = (semanticScore * semanticWeight) +
                            (rhymeScore * rhymeWeight) +
                            (syllableScore * syllableWeight) +
                            (flowScore * flowWeight)
            
            scored.append(ScoredCandidate(
                id: UUID(),
                line: candidate,
                score: totalScore,
                rhymeScore: rhymeScore,
                syllableScore: syllableScore,
                semanticScore: semanticScore,
                flowScore: flowScore
            ))
        }
        
        // Sort by score (highest first) and return top 30
        return scored.sorted { $0.score > $1.score }.prefix(30).map { $0 }
    }
    
    // MARK: - Score Calculations
    
    private func calculateRhymeScore(
        candidate: RapLine,
        target: String?
    ) -> Double {
        guard let target = target?.lowercased() else {
            // No target, return neutral score
            return 0.5
        }
        
        // Extract last word from candidate text
        let lastWord = extractLastWord(from: candidate.text)?.lowercased()
        guard let lastWord = lastWord else {
            return 0.0
        }
        
        // Access the provided CMUdict phoneme store
        let cmudictStore = phonemeStoreProvider()
        
        guard let targetPhonemes = cmudictStore[target],
              let candidatePhonemes =  cmudictStore[lastWord] else {
            return 0.0
        }
        
        // Extract phonetic signatures
        guard let targetSig = extractPhoneticSignature(from: targetPhonemes),
              let candidateSig = extractPhoneticSignature(from: candidatePhonemes) else {
            return 0.0
        }
        
        // Check rhyme strength
        let strength = calculateRhymeStrength(targetSig: targetSig, candidateSig: candidateSig)
        switch strength {
        case .perfect:
            return 1.0
        case .near:
            return 0.75
        case .slant:
            return 0.55
        case .none:
            return 0.0
        }
    }
    
    // Extract phonetic signature from phonemes
    private func extractPhoneticSignature(from phonemes: [String]) -> (stressedVowel: String, coda: [String])? {
        // Find the stressed vowel (phoneme ending in 0, 1, or 2)
        guard let stressedIndex = phonemes.firstIndex(where: { $0.hasSuffix("0") || $0.hasSuffix("1") || $0.hasSuffix("2") }) else {
            return nil
        }
        
        let stressedVowel = phonemes[stressedIndex]
        let coda = Array(phonemes[(stressedIndex + 1)...])
        
        return (stressedVowel: stressedVowel, coda: coda)
    }
    
    // Calculate rhyme strength between two signatures
    private func calculateRhymeStrength(
        targetSig: (stressedVowel: String, coda: [String]),
        candidateSig: (stressedVowel: String, coda: [String])
    ) -> RhymeStrength {
        // Perfect rhyme: same stressed vowel and coda
        if targetSig.stressedVowel == candidateSig.stressedVowel && targetSig.coda == candidateSig.coda {
            return .perfect
        }
        
        // Near rhyme: same stressed vowel, different coda
        if targetSig.stressedVowel == candidateSig.stressedVowel {
            return .near
        }
        
        // Slant rhyme: similar stressed vowel
        let targetVowelBase = String(targetSig.stressedVowel.dropLast())
        let candidateVowelBase = String(candidateSig.stressedVowel.dropLast())
        if targetVowelBase == candidateVowelBase {
            return .slant
        }
        
        return .none
    }
    
    enum RhymeStrength {
        case perfect
        case near
        case slant
        case none
    }
    
    private func calculateSyllableScore(
        candidate: RapLine,
        target: Int?
    ) -> Double {
        guard let target = target else {
            return 0.5 // Neutral if no target
        }
        
        let diff = abs(candidate.syllableCount - target)
        
        if diff == 0 {
            return 1.0
        } else if diff == 1 {
            return 0.8
        } else if diff == 2 {
            return 0.5
        } else {
            return 0.2
        }
    }
    
    private func calculateFlowScore(
        candidate: RapLine,
        targetVariance: Double
    ) -> Double {
        // Simple flow score based on syllable count consistency
        // Lower variance = better flow
        // For now, return neutral score (would need line-by-line analysis)
        return 0.5
    }
    
    private func extractLastWord(from text: String) -> String? {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        
        var lastWord: String?
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            lastWord = String(text[range])
            return true
        }
        
        return lastWord
    }
}


