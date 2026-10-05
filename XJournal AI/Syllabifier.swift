//
//  Syllabifier.swift
//  XJournal AI
//
//  Heuristic syllable count (vowel groups) plus optional exception list.
//

import Foundation

nonisolated enum Syllabifier: Sendable {
    private static let vowelSet = CharacterSet(charactersIn: "aeiouyAEIOUYàèìòùáéíóúâêîôûäëïöü")
    
    /// Exception list: word (lowercased) -> syllable count. Add common mis-counts here.
    private static let exceptions: [String: Int] = [
        "the": 1,
        "rhythm": 2,
        "rhythms": 2,
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
    
    /// Spoken letter names. W is “double-u”.
    private static let letterNameSyllables: [Character: Int] = [
        "a": 1, "b": 1, "c": 1, "d": 1, "e": 1, "f": 1, "g": 1, "h": 1,
        "i": 1, "j": 1, "k": 1, "l": 1, "m": 1, "n": 1, "o": 1, "p": 1,
        "q": 1, "r": 1, "s": 1, "t": 1, "u": 1, "v": 1, "w": 3, "x": 1,
        "y": 1, "z": 1
    ]

    private static let spellOut: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .spellOut
        f.locale = Locale(identifier: "en_US")
        return f
    }()

    /// Returns syllable count for a single word using heuristic (vowel groups) and exceptions.
    /// Digits use English number names (“3” → three). A lone letter uses its letter name (“s” → ess, “w” → double-u).
    static func syllableCount(word: String) -> Int {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0 }

        let lower = trimmed.lowercased()
        if let count = exceptions[lower] {
            return count
        }
        if lower.count == 1, let letter = lower.first, let named = letterNameSyllables[letter] {
            return named
        }
        if lower.allSatisfy({ $0.isNumber }) {
            return spokenNumberSyllables(lower)
        }

        return heuristicSyllableCount(word: trimmed)
    }

    private static func spokenNumberSyllables(_ digits: String) -> Int {
        if digits.contains(where: { $0 != "0" }) == false {
            return digits.count * 2
        }
        if digits.hasPrefix("0") {
            return digits.reduce(0) { sum, ch in
                sum + (ch == "0" ? 2 : spokenNumberSyllables(String(ch)))
            }
        }
        guard let n = Int(digits),
              let spoken = spellOut.string(from: NSNumber(value: n)) else {
            return max(1, digits.count)
        }
        let parts = spoken.split { !$0.isLetter && $0 != "-" }
        return parts.reduce(0) { sum, part in
            let piece = String(part).replacingOccurrences(of: "-", with: " ")
            return sum + piece.split(separator: " ").reduce(0) { $0 + heuristicSyllableCount(word: String($1)) }
        }
    }
    
    /// Y is a vowel except as the first letter ("yellow" vs "city" / "rhythm").
    private static func isVowel(_ scalar: UnicodeScalar, atStart: Bool) -> Bool {
        let c = Character(scalar)
        if c == "y" || c == "Y" { return !atStart }
        return vowelSet.contains(scalar)
    }

    /// Vowel-group heuristic: count maximal runs of vowels (and trailing silent e when appropriate).
    private static func heuristicSyllableCount(word: String) -> Int {
        var count = 0
        var i = word.unicodeScalars.startIndex
        let end = word.unicodeScalars.endIndex
        var isStart = true
        
        while i < end {
            let scalar = word.unicodeScalars[i]
            if isVowel(scalar, atStart: isStart) {
                count += 1
                isStart = false
                i = word.unicodeScalars.index(after: i)
                while i < end && isVowel(word.unicodeScalars[i], atStart: false) {
                    i = word.unicodeScalars.index(after: i)
                }
                continue
            }
            isStart = false
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
