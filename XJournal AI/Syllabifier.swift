//
//  Syllabifier.swift
//  XJournal AI
//
//  Heuristic syllable count (vowel groups) plus optional exception list.
//

import Foundation

enum Syllabifier {
    private static let vowelSet = CharacterSet(charactersIn: "aeiouAEIOUàèìòùáéíóúâêîôûäëïöü")
    
    /// Exception list: word (lowercased) -> syllable count. Add common mis-counts here.
    private static let exceptions: [String: Int] = [
        "the": 1,
        "something": 3,
        "everything": 4,
        "business": 2,
        "different": 3,
        "every": 3,
        "really": 2,
        "probably": 3,
        "actually": 4,
        "beautiful": 3,
        "coupe": 2,
        "fire": 2,
        "hour": 1,
        "our": 1,
        "they're": 1,
        "we're": 1,
        "you're": 1,
        "i'm": 1,
        "don't": 1,
        "won't": 1,
        "can't": 1,
        "isn't": 1,
        "aren't": 1,
        "wasn't": 1,
        "weren't": 1,
        "haven't": 1,
        "hasn't": 1,
        "hadn't": 1,
        "wouldn't": 2,
        "couldn't": 2,
        "shouldn't": 2,
        "doesn't": 2,
        "didn't": 1,
        "let's": 1,
        "that's": 1,
        "it's": 1,
        "what's": 1,
        "there's": 1,
        "here's": 1,
    ]
    
    /// Returns syllable count for a single word using heuristic (vowel groups) and exceptions.
    static func syllableCount(word: String) -> Int {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0 }
        
        let lower = trimmed.lowercased()
        if let count = exceptions[lower] {
            return count
        }
        
        return heuristicSyllableCount(word: trimmed)
    }
    
    /// Vowel-group heuristic: count maximal runs of vowels (and trailing silent e when appropriate).
    private static func heuristicSyllableCount(word: String) -> Int {
        var count = 0
        var i = word.unicodeScalars.startIndex
        let end = word.unicodeScalars.endIndex
        
        while i < end {
            let scalar = word.unicodeScalars[i]
            _ = Character(scalar)
            if vowelSet.contains(scalar) {
                count += 1
                // Skip rest of this vowel cluster
                while i < end && vowelSet.contains(word.unicodeScalars[i]) {
                    i = word.unicodeScalars.index(after: i)
                }
                continue
            }
            i = word.unicodeScalars.index(after: i)
        }
        
        // Silent e: final "e" often doesn't add a syllable (e.g. "take" = 1)
        let chars = Array(word.lowercased())
        if count > 1 && chars.last == "e" && chars.count >= 2 {
            let prev = chars[chars.count - 2]
            if prev != "e" && !"aeiou".contains(prev) {
                count -= 1
            }
        }
        
        return max(1, count)
    }
}
