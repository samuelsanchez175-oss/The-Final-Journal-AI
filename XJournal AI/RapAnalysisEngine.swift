import Foundation
import NaturalLanguage

// MARK: - Rap Metrics

struct RapMetrics: Codable {
    let fullText: String
    let lastNLines: [String]
    let currentLineIndex: Int
    let syllableTarget: Int?
    let rhymeTarget: String?
    let rhymeScheme: String? // ABAB, AABB, etc.
    let cadence: CadenceSummary
    let averageSyllables: Double
    let syllableVariance: Double
    let bpm: Int? // Musical tempo (60-220)
    let key: String? // Musical key (e.g., "C", "D", "A#")
    let scale: String? // Scale type (e.g., "Major", "Dorian", "Chromatic")
    let syllableMin: Int? // User-set lower bound (nil = auto)
    let syllableMax: Int? // User-set upper bound (nil = auto)
}

struct CadenceSummary: Codable {
    let averageSyllables: Double
    let syllableVariance: Double
    let lineCount: Int
}

// MARK: - Local Type Definitions (to avoid type resolution issues)

private struct PhoneticSignature {
    let stressedVowel: String
    let coda: [String]
}

private enum RhymeStrength: Double {
    case perfect = 1.0
    case near = 0.75
    case slant = 0.55
}

// NOTE: Highlight is defined in ContentView.CCV.3.swift

private struct CadenceMetrics {
    struct LineMetrics {
        let lineIndex: Int
        let syllableCount: Int
        let stressCount: Int
        let rhymeCount: Int
    }
    let lines: [LineMetrics]
    
    var averageSyllables: Double {
        guard !lines.isEmpty else { return 0 }
        return Double(lines.map(\.syllableCount).reduce(0, +)) / Double(lines.count)
    }
    var syllableVariance: Double {
        let avg = averageSyllables
        return lines.map { pow(Double($0.syllableCount) - avg, 2) }.reduce(0, +) / Double(lines.count)
    }
}

private struct SyllableStressAnalyzer {
    func analyze(word: String) -> (syllables: Int, stresses: [Int]) {
        guard let phonemes = getCMUDICTPhonemes(for: word.lowercased()) else { return (0, []) }
        var syllableIndex = 0
        var stresses: [Int] = []
        for phone in phonemes {
            if let last = phone.last, last.isNumber {
                if last == "1" { stresses.append(syllableIndex) }
                syllableIndex += 1
            }
        }
        return (syllableIndex, stresses)
    }
}

private struct CadenceAnalyzer {
    private let syllableAnalyzer = SyllableStressAnalyzer()
    func analyze(text: String, highlights: [Highlight]) -> CadenceMetrics {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var results: [CadenceMetrics.LineMetrics] = []
        for (index, line) in lines.enumerated() {
            let words = line.split { !$0.isLetter }
            var syllables = 0, stresses = 0, rhymeCount = 0
            for wordSub in words {
                let word = String(wordSub).lowercased()
                let analysis = syllableAnalyzer.analyze(word: word)
                syllables += analysis.syllables
                stresses += analysis.stresses.count
            }
            rhymeCount = highlights.filter { highlight in
                let rangeText = text[highlight.range]
                return line.contains(rangeText)
            }.count
            results.append(CadenceMetrics.LineMetrics(lineIndex: index, syllableCount: syllables, stressCount: stresses, rhymeCount: rhymeCount))
        }
        return CadenceMetrics(lines: results)
    }
}

// MARK: - Helper Functions for CMUDICT Access

private func getCMUDICTPhonemes(for word: String) -> [String]? {
    return getGlobalCMUDICTStore()[word.lowercased()]
}

private func extractSignature(from phonemes: [String]) -> PhoneticSignature? {
    // Anchor on the last STRESSED vowel (CMUDICT stress marker 1 or 2), not the last vowel.
    // CMUDICT marks EVERY vowel with a stress digit (0/1/2), so the last digit-bearing phoneme is
    // often an unstressed final vowel — e.g. "crazy" K R EY1 Z IY0 → IY0 with an empty coda —
    // which over-loosens rhyme matching to bare assonance ("-y" endings). Fall back to the last
    // vowel of any stress only when none is stressed.
    // (Mirrors GhostSuggestionEngine.phoneticSignature, fixed in 558937e.)
    let stressed = phonemes.lastIndex { $0.last == "1" || $0.last == "2" }
    guard let idx = stressed ?? phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
        return nil
    }
    let vowel = phonemes[idx]
    let coda = Array(phonemes.dropFirst(idx + 1))
    return PhoneticSignature(stressedVowel: vowel, coda: coda)
}

private func rhymeScore(_ a: PhoneticSignature, _ b: PhoneticSignature) -> RhymeStrength? {
    if a.stressedVowel == b.stressedVowel && a.coda == b.coda {
        return .perfect
    }
    if a.stressedVowel == b.stressedVowel {
        return .near
    }
    // Check for slant rhyme (similar vowels)
    let baseA = String(a.stressedVowel.dropLast())
    let baseB = String(b.stressedVowel.dropLast())
    if baseA == baseB {
        return .slant
    }
    return nil
}

// MARK: - Rap Analysis Engine

struct RapAnalysisEngine {
    private let cadenceAnalyzer = CadenceAnalyzer()
    private let syllableAnalyzer = SyllableStressAnalyzer()
    
    // MARK: - Main Analysis Function
    
    func extractMetrics(text: String, highlights: [Highlight], bpm: Int? = nil, key: String? = nil, scale: String? = nil, syllableMin: Int? = nil, syllableMax: Int? = nil) -> RapMetrics {
        // Use existing CadenceAnalyzer
        let cadence = cadenceAnalyzer.analyze(text: text, highlights: highlights)
        
        // Extract last N lines (last 3 for context)
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        let lastNLines = Array(lines.suffix(3)).map { String($0) }
        
        // Calculate syllable target (average of last 2 lines, rounded)
        let last2Lines = Array(lines.suffix(2))
        var last2SyllableCounts: [Int] = []
        for lineSubstring in last2Lines {
            let line = String(lineSubstring)
            let words = line.split { !$0.isLetter }
            var syllables = 0
            for wordSub in words {
                let word = String(wordSub).lowercased()
                let analysis = syllableAnalyzer.analyze(word: word)
                syllables += analysis.syllables
            }
            if syllables > 0 {
                last2SyllableCounts.append(syllables)
            }
        }
        let syllableTarget: Int?
        if !last2SyllableCounts.isEmpty {
            let avg = Double(last2SyllableCounts.reduce(0, +)) / Double(last2SyllableCounts.count)
            syllableTarget = Int(avg.rounded())
        } else {
            syllableTarget = Int(cadence.averageSyllables.rounded())
        }
        
        // Extract rhyme target (last word of last line)
        let rhymeTarget = extractLastRhymeWord(text: text)
        
        // Detect rhyme scheme
        let rhymeScheme = detectRhymeScheme(text: text, highlights: highlights)
        
        // Build cadence summary
        let cadenceSummary = CadenceSummary(
            averageSyllables: cadence.averageSyllables,
            syllableVariance: cadence.syllableVariance,
            lineCount: lines.count
        )
        
        return RapMetrics(
            fullText: text,
            lastNLines: lastNLines,
            currentLineIndex: lines.count,
            syllableTarget: syllableTarget,
            rhymeTarget: rhymeTarget,
            rhymeScheme: rhymeScheme,
            cadence: cadenceSummary,
            averageSyllables: cadence.averageSyllables,
            syllableVariance: cadence.syllableVariance,
            bpm: bpm,
            key: key,
            scale: scale,
            syllableMin: syllableMin,
            syllableMax: syllableMax
        )
    }
    
    // MARK: - Helper Functions
    
    private func extractLastRhymeWord(text: String) -> String? {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        guard let lastLineSubstring = lines.last else { return nil }
        
        // Convert to String first, then use its indices
        let lastLine = String(lastLineSubstring)
        guard !lastLine.isEmpty else { return nil }
        
        // Tokenize last line to get last word
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = lastLine
        
        var lastWord: String?
        tokenizer.enumerateTokens(in: lastLine.startIndex..<lastLine.endIndex) { range, _ in
            lastWord = String(lastLine[range]).lowercased()
            return true
        }
        
        return lastWord
    }
    
    private func detectRhymeScheme(text: String, highlights: [Highlight]) -> String? {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count >= 2 else { return nil }
        
        // Get last word of each line
        var lineEndWords: [String?] = []
        let tokenizer = NLTokenizer(unit: .word)
        
        for lineSubstring in lines {
            // Convert to String first, then use its indices
            let line = String(lineSubstring)
            guard !line.isEmpty else {
                lineEndWords.append(nil)
                continue
            }
            
            tokenizer.string = line
            var lastWord: String?
            tokenizer.enumerateTokens(in: line.startIndex..<line.endIndex) { range, _ in
                lastWord = String(line[range]).lowercased()
                return true
            }
            lineEndWords.append(lastWord)
        }
        
        // Check if words rhyme using existing rhyme engine
        var rhymePattern: [String] = []
        var letterMap: [String: String] = [:]
        var currentLetter = "A"
        
        for (index, word) in lineEndWords.enumerated() {
            guard let word = word else {
                rhymePattern.append("?")
                continue
            }
            
            // Check if this word rhymes with any previous word
            var foundMatch = false
            for (prevIndex, prevWord) in lineEndWords.enumerated() {
                guard prevIndex < index, let prevWord = prevWord else { continue }
                
                if wordsRhyme(word, prevWord) {
                    // Use the same letter as the previous match
                    if prevIndex < rhymePattern.count {
                        rhymePattern.append(rhymePattern[prevIndex])
                        foundMatch = true
                        break
                    }
                }
            }
            
            if !foundMatch {
                rhymePattern.append(currentLetter)
                letterMap[word] = currentLetter
                // Move to next letter
                if let lastChar = currentLetter.last, let ascii = lastChar.asciiValue, ascii < 90 {
                    let nextScalar = UnicodeScalar(ascii + 1)
                    currentLetter = String(Character(nextScalar))
                }
            }
        }
        
        guard !rhymePattern.isEmpty else { return nil }
        return rhymePattern.joined()
    }
    
    /// Rhyme tier over raw CMUDICT phoneme arrays — the single rhyme classifier shared by
    /// `wordsRhyme` and exercised directly (CMUDICT-independent) by tests.
    /// 3 = perfect (same stressed vowel + coda), 2 = near (same stressed vowel, different coda),
    /// 1 = slant (same base vowel), 0 = no rhyme.
    static func rhymeTier(_ a: [String], _ b: [String]) -> Int {
        guard let sigA = extractSignature(from: a),
              let sigB = extractSignature(from: b),
              let strength = rhymeScore(sigA, sigB) else {
            return 0
        }
        switch strength {
        case .perfect: return 3
        case .near:    return 2
        case .slant:   return 1
        }
    }

    private func wordsRhyme(_ word1: String, _ word2: String) -> Bool {
        // Use existing CMUDICT to check if words rhyme
        guard let phonemes1 = getCMUDICTPhonemes(for: word1),
              let phonemes2 = getCMUDICTPhonemes(for: word2) else {
            return false
        }
        // Perfect or near rhyme (matches the prior threshold).
        return RapAnalysisEngine.rhymeTier(phonemes1, phonemes2) >= 2
    }
}
