//
//  StressMapBuilder.swift
//  XJournal AI
//
//  Builds stress map (stressed/unstressed per syllable) for a line.
//

import Foundation

enum StressMapBuilder {
    /// Returns stressed syllables for a single line. Tokenize by whitespace, then per-word syllables + stress.
    static func build(line: String) -> [StressedSyllable] {
        let tokens = line.split(separator: " ").map(String.init).filter { !$0.isEmpty }
        var result: [StressedSyllable] = []
        for word in tokens {
            let sylls = SyllableEngine.syllables(word: word)
            let stressIndices = stressIndicesForWord(word)
            for (i, syl) in sylls.enumerated() {
                let stress = stressIndices.contains(i) ? 1 : 0
                result.append(StressedSyllable(text: syl, stress: stress))
            }
        }
        return result
    }

    /// Stress indices (syllable index with primary stress) from slang or CMUDICT.
    private static func stressIndicesForWord(_ word: String) -> [Int] {
        let lower = word.lowercased()
        let phonemes: [String]? = RapSlangPhonemes.phonemes(for: lower) ?? getGlobalCMUDICTStore()[lower]
        guard let phonemes = phonemes else { return [0] }
        var indices: [Int] = []
        var syllableIndex = 0
        for p in phonemes {
            if let last = p.last, last.isNumber {
                if last == "1" { indices.append(syllableIndex) }
                syllableIndex += 1
            }
        }
        return indices.isEmpty ? [0] : indices
    }
}
