import Foundation

// MARK: - PR 14: Rhyme Anchor Engine (Mode C)

struct RhymeAnchorEngine {
    struct RhymeAnchor: Codable {
        let ending: String  // Phonetic ending (e.g., "AY1-T")
        let syllableCount: Int
        let stressPattern: [Int]  // Stress positions
        let rhymeClass: String?  // Rhyme class (e.g., "ood")
    }
    
    /// Extract rhyme anchors from ground truth bars
    static func extractAnchors(from bars: [GroundTruthIndex]) -> [RhymeAnchor] {
        var anchors: [RhymeAnchor] = []
        
        for bar in bars {
            // Extract phonetic ending
            let ending = bar.rhymeEnding ?? bar.normalizedMetrics.phoneticEnding
            
            // Get syllable count
            let syllableCount = bar.syllableCount > 0 ? bar.syllableCount : bar.normalizedMetrics.syllableCount
            
            // Get stress pattern
            let stressPattern = !bar.normalizedMetrics.stressPattern.isEmpty 
                ? bar.normalizedMetrics.stressPattern 
                : extractStressPattern(from: bar.text)
            
            // Get rhyme class
            let rhymeClass = bar.normalizedMetrics.rhymeClass
            
            if let ending = ending {
                anchors.append(RhymeAnchor(
                    ending: ending,
                    syllableCount: syllableCount,
                    stressPattern: stressPattern,
                    rhymeClass: rhymeClass
                ))
            }
        }
        
        return anchors
    }
    
    /// Extract stress pattern from text using CMUDICT
    private static func extractStressPattern(from text: String) -> [Int] {
        var pattern: [Int] = []
        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty }
        
        for word in words {
            guard let phonemes = getCMUDICTPhonemes(for: word.lowercased()) else { continue }
            var syllableIndex = 0
            for phone in phonemes {
                if let last = phone.last, last.isNumber {
                    let stress = last == "1" ? 1 : 0
                    pattern.append(stress)
                    syllableIndex += 1
                }
            }
        }
        
        return pattern
    }
    
    /// Helper to get CMUDICT phonemes
    private static func getCMUDICTPhonemes(for word: String) -> [String]? {
        return getGlobalCMUDICTStore()[word.lowercased()]
    }
    
    /// Generate prompt constraints from anchors
    static func buildAnchorConstraints(anchors: [RhymeAnchor], metrics: RapMetrics) -> String {
        guard !anchors.isEmpty else { return "" }
        
        var constraints = "\n\n=== RHYME ANCHOR CONSTRAINTS (MODE C) ===\n"
        constraints += "You MUST match the following rhyme and cadence anchors:\n\n"
        
        for (index, anchor) in anchors.enumerated() {
            constraints += "Anchor \(index + 1):\n"
            constraints += "- Rhyme ending: \(anchor.ending)\n"
            constraints += "- Syllable count: \(anchor.syllableCount)\n"
            if !anchor.stressPattern.isEmpty {
                let stressStr = anchor.stressPattern.map { $0 == 1 ? "●" : "○" }.joined()
                constraints += "- Stress pattern: \(stressStr)\n"
            }
            if let rhymeClass = anchor.rhymeClass {
                constraints += "- Rhyme class: \(rhymeClass)\n"
            }
            constraints += "\n"
        }
        
        constraints += "CRITICAL: Each generated line must match one of these anchors exactly:\n"
        constraints += "- Same rhyme ending (phonetic match)\n"
        constraints += "- Same syllable count (±1 allowed)\n"
        constraints += "- Similar stress pattern\n"
        constraints += "- Maintain BPM consistency with existing cadence\n"
        constraints += "\n"
        
        if let bpm = metrics.bpm {
            constraints += "BPM: \(bpm) - Match the rhythm and pacing to maintain consistency.\n"
        }
        
        return constraints
    }
    
    /// Find matching anchor for a target syllable count and rhyme ending
    static func findMatchingAnchor(
        anchors: [RhymeAnchor],
        targetSyllables: Int,
        targetRhymeEnding: String?
    ) -> RhymeAnchor? {
        // First try exact rhyme ending match
        if let targetEnding = targetRhymeEnding {
            if let exactMatch = anchors.first(where: { $0.ending == targetEnding }) {
                return exactMatch
            }
        }
        
        // Then try syllable count match (±2 tolerance)
        let syllableMatches = anchors.filter { abs($0.syllableCount - targetSyllables) <= 2 }
        if !syllableMatches.isEmpty {
            return syllableMatches.first
        }
        
        // Fallback: return first anchor
        return anchors.first
    }
}
