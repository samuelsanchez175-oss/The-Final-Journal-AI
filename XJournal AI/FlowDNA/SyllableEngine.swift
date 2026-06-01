//
//  SyllableEngine.swift
//  XJournal AI
//
//  Syllable count and segmentation. CMUDICT + slang fallback.
//

import Foundation

enum SyllableEngine {
    private static let vowelSet = CharacterSet(charactersIn: "aeiouAEIOUàèìòùáéíóúâêîôûäëïöü")

    /// Returns syllable count for a word. Uses slang first, then CMUDICT, then Syllabifier.
    static func syllableCount(word: String) -> Int {
        let w = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !w.isEmpty else { return 0 }
        if let phonemes = RapSlangPhonemes.phonemes(for: w) {
            return phonemes.filter { $0.last?.isNumber == true }.count
        }
        if let phonemes = getGlobalCMUDICTStore()[w] {
            let n = phonemes.filter { $0.last?.isNumber == true }.count
            return n > 0 ? n : 1
        }
        return Syllabifier.syllableCount(word: w)
    }

    /// Returns word split into syllable strings. Uses phoneme boundaries when available, else heuristic.
    static func syllables(word: String) -> [String] {
        let w = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !w.isEmpty else { return [] }
        let lower = w.lowercased()
        let phonemes: [String]? = RapSlangPhonemes.phonemes(for: lower) ?? getGlobalCMUDICTStore()[lower]
        if let phonemes = phonemes, !phonemes.isEmpty {
            return syllablesFromPhonemes(word: w, phonemes: phonemes)
        }
        return heuristicSyllableSplit(word: w)
    }

    /// Derive syllable strings from CMU phonemes (vowel nuclei = syllable boundaries).
    private static func syllablesFromPhonemes(word: String, phonemes: [String]) -> [String] {
        var syllableIndices: [Int] = []
        for (i, p) in phonemes.enumerated() {
            if p.last?.isNumber == true {
                syllableIndices.append(i)
            }
        }
        if syllableIndices.isEmpty {
            return [word]
        }
        // Approximate character boundaries: distribute word length by syllable count.
        let chars = Array(word)
        let n = syllableIndices.count
        var result: [String] = []
        var start = 0
        for i in 0..<n {
            let end = i == n - 1 ? chars.count : (chars.count * (i + 1)) / n
            if end > start {
                result.append(String(chars[start..<end]))
            }
            start = end
        }
        return result.isEmpty ? [word] : result
    }

    /// Heuristic split by vowel groups when no phonemes available.
    private static func heuristicSyllableSplit(word: String) -> [String] {
        let count = Syllabifier.syllableCount(word: word)
        if count <= 1 { return [word] }
        let chars = Array(word)
        var result: [String] = []
        var start = 0
        for i in 0..<count {
            let end = i == count - 1 ? chars.count : (chars.count * (i + 1)) / count
            if end > start {
                result.append(String(chars[start..<end]))
            }
            start = end
        }
        return result.isEmpty ? [word] : result
    }
}
