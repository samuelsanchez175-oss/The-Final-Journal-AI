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
}

struct CadenceSummary: Codable {
    let averageSyllables: Double
    let syllableVariance: Double
    let lineCount: Int
}

// MARK: - Rap Analysis Engine

struct RapAnalysisEngine {
    private let cadenceAnalyzer = CadenceAnalyzer()
    private let syllableAnalyzer = SyllableStressAnalyzer()
    
    // MARK: - Main Analysis Function
    
    func extractMetrics(text: String, highlights: [Highlight]) -> RapMetrics {
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
            syllableVariance: cadence.syllableVariance
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
    
    private func wordsRhyme(_ word1: String, _ word2: String) -> Bool {
        // Use existing CMUDICT to check if words rhyme
        guard let phonemes1 = FJCMUDICTStore.shared.phonemesByWord[word1.lowercased()],
              let phonemes2 = FJCMUDICTStore.shared.phonemesByWord[word2.lowercased()],
              let sig1 = RhymeHighlighterEngine.extractSignature(from: phonemes1),
              let sig2 = RhymeHighlighterEngine.extractSignature(from: phonemes2) else {
            return false
        }
        
        // Check rhyme strength
        if let strength = RhymeHighlighterEngine.rhymeScore(sig1, sig2) {
            return strength == .perfect || strength == .near
        }
        
        return false
    }
}
