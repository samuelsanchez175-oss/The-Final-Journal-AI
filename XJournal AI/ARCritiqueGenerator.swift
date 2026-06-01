import Foundation
import NaturalLanguage

// MARK: - Line Critique

struct LineCritique {
    let lineText: String
    let lineRange: Range<String.Index>
    let critique: String
    let critiqueType: CritiqueType
}

enum CritiqueType {
    case oversharing
    case narrativeProgression
    case emotionalLeakage
    case defensiveFraming
    case weakAuthority
    case informationRefusalViolation
    // PR 10: GeneratorPolicy violations
    case forbiddenVerb(String)
    case clauseTooLong(Int)
    case tooManyBrands(Int)
    case missingPriceAnchor
}

// MARK: - A&R Critique Generator

class ARCritiqueGenerator {
    static let shared = ARCritiqueGenerator()
    
    private init() {}
    
    // MARK: - Main Analysis Function
    
    /// Analyzes text line-by-line and generates critiques using signal layer analysis
    /// PR 10: Updated to accept optional GeneratorPolicy for policy-aware critiques
    func analyzeTextForCritiques(text: String, policy: GeneratorPolicy? = nil) -> [LineCritique] {
        var critiques: [LineCritique] = []
        
        // Split text into lines (sentences or actual line breaks)
        let lines = splitIntoLines(text: text)
        
        for line in lines {
            // Skip empty lines
            guard !line.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                continue
            }
            
            // Analyze this line using signal layer
            let metrics = SignalIngest.shared.analyzeBehavior(text: line.text)
            
            // Check for various critique types
            if let critique = checkOversharing(line: line, metrics: metrics) {
                critiques.append(critique)
            } else if let critique = checkNarrativeProgression(line: line, metrics: metrics) {
                critiques.append(critique)
            } else if let critique = checkEmotionalLeakage(line: line, metrics: metrics) {
                critiques.append(critique)
            } else if let critique = checkDefensiveFraming(line: line, metrics: metrics) {
                critiques.append(critique)
            } else if let critique = checkWeakAuthority(line: line, metrics: metrics) {
                critiques.append(critique)
            } else if let critique = checkInformationRefusalViolation(line: line, metrics: metrics) {
                critiques.append(critique)
            }
            
            // PR 10: Check GeneratorPolicy violations (if policy provided)
            if let policy = policy, policy.artistBias == .gunna {
                if let critique = checkForbiddenVerbs(line: line, policy: policy) {
                    critiques.append(critique)
                } else if let critique = checkClauseLength(line: line, policy: policy) {
                    critiques.append(critique)
                } else if let critique = checkBrandCount(line: line, policy: policy) {
                    critiques.append(critique)
                }
            }
        }
        
        // PR 10: Check price anchoring (text-level check)
        if let policy = policy, policy.artistBias == .gunna {
            if let critique = checkPriceAnchoring(text: text, policy: policy) {
                critiques.append(critique)
            }
        }
        
        return critiques
    }
    
    // MARK: - Line Splitting
    
    private struct TextLine {
        let text: String
        let range: Range<String.Index>
    }
    
    private func splitIntoLines(text: String) -> [TextLine] {
        var lines: [TextLine] = []
        
        // First, try to split by actual line breaks
        let lineBreakComponents = text.components(separatedBy: .newlines)
        var currentIndex = text.startIndex
        
        for component in lineBreakComponents {
            if !component.isEmpty {
                let endIndex = text.index(currentIndex, offsetBy: component.count)
                let range = currentIndex..<endIndex
                lines.append(TextLine(text: component, range: range))
                currentIndex = endIndex
            } else {
                // Empty line - still advance index
                if currentIndex < text.endIndex {
                    currentIndex = text.index(after: currentIndex)
                }
            }
        }
        
        // If no line breaks found, split by sentences
        if lines.isEmpty || (lines.count == 1 && lines[0].text == text) {
            let sentenceDetector = NLTokenizer(unit: .sentence)
            sentenceDetector.string = text
            
            sentenceDetector.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                let sentenceText = String(text[tokenRange])
                lines.append(TextLine(text: sentenceText, range: tokenRange))
                return true
            }
        }
        
        return lines
    }
    
    // MARK: - Critique Type Checks
    
    private func checkOversharing(line: TextLine, metrics: SignalMetrics) -> LineCritique? {
        // Oversharing: high specificity load + explanation density
        if metrics.specificityLoad > 0.7 && metrics.explanationDensity > 0.6 {
            let critique = generateOversharingCritique(line: line.text, metrics: metrics)
            return LineCritique(
                lineText: line.text,
                lineRange: line.range,
                critique: critique,
                critiqueType: .oversharing
            )
        }
        return nil
    }
    
    private func checkNarrativeProgression(line: TextLine, metrics: SignalMetrics) -> LineCritique? {
        // Narrative progression issues: repetitive emotional leakage
        if metrics.emotionalLeakage > 0.7 {
            let critique = generateNarrativeProgressionCritique(line: line.text, metrics: metrics)
            return LineCritique(
                lineText: line.text,
                lineRange: line.range,
                critique: critique,
                critiqueType: .narrativeProgression
            )
        }
        return nil
    }
    
    private func checkEmotionalLeakage(line: TextLine, metrics: SignalMetrics) -> LineCritique? {
        // Emotional leakage: high emotional repetition
        if metrics.emotionalLeakage > 0.6 && metrics.emotionalLeakage <= 0.7 {
            let critique = generateEmotionalLeakageCritique(line: line.text, metrics: metrics)
            return LineCritique(
                lineText: line.text,
                lineRange: line.range,
                critique: critique,
                critiqueType: .emotionalLeakage
            )
        }
        return nil
    }
    
    private func checkDefensiveFraming(line: TextLine, metrics: SignalMetrics) -> LineCritique? {
        // Defensive framing: preemptive rebuttals
        if metrics.defensiveFraming > 0.6 {
            let critique = generateDefensiveFramingCritique(line: line.text, metrics: metrics)
            return LineCritique(
                lineText: line.text,
                lineRange: line.range,
                critique: critique,
                critiqueType: .defensiveFraming
            )
        }
        return nil
    }
    
    private func checkWeakAuthority(line: TextLine, metrics: SignalMetrics) -> LineCritique? {
        // Weak authority: low authority posture
        if metrics.authorityPosture < 0.4 {
            let critique = generateWeakAuthorityCritique(line: line.text, metrics: metrics)
            return LineCritique(
                lineText: line.text,
                lineRange: line.range,
                critique: critique,
                critiqueType: .weakAuthority
            )
        }
        return nil
    }
    
    private func checkInformationRefusalViolation(line: TextLine, metrics: SignalMetrics) -> LineCritique? {
        // Information refusal violation: explaining when you should be mysterious
        if metrics.explanationDensity > 0.7 && metrics.specificityLoad > 0.5 {
            let critique = generateInformationRefusalViolationCritique(line: line.text, metrics: metrics)
            return LineCritique(
                lineText: line.text,
                lineRange: line.range,
                critique: critique,
                critiqueType: .informationRefusalViolation
            )
        }
        return nil
    }
    
    // MARK: - Critique Generation (A&R Tone)
    
    private func generateOversharingCritique(line: String, metrics: SignalMetrics) -> String {
        let lowercased = line.lowercased()
        
        // FIX 5: Concise A&R critique format (1 sentence on authority, 1 sentence on structure, 1 actionable note)
        if metrics.specificityLoad > 0.8 {
            if lowercased.contains("yesterday") || lowercased.contains("today") || lowercased.contains("monday") || lowercased.contains("tuesday") {
                return "Oversharing. Time markers weaken authority. Remove specific dates—let the moment stand without the calendar."
            } else if hasProperNouns(line) {
                return "Oversharing. Names lock the narrative. Remove proper nouns—let them infer the context."
            } else {
                return "Oversharing. Too many specific details weaken authority. Remove names, times, places—let them infer."
            }
        } else {
            let explanationWords = ["because", "since", "so that", "in order to", "that's why", "the reason"]
            let foundExplanation = explanationWords.first { lowercased.contains($0) }
            if let word = foundExplanation {
                return "Oversharing. '\(word)' weakens authority. Remove explanation—state it, don't justify it."
            } else {
                return "Oversharing. Explanation language weakens authority. Remove 'because' and 'why'—state it, don't justify it."
            }
        }
    }
    
    private func generateNarrativeProgressionCritique(line: String, metrics: SignalMetrics) -> String {
        let lowercased = line.lowercased()
        
        // FIX 5: Concise A&R critique format
        let emotionalWords = ["hurt", "pain", "angry", "sad", "upset", "lonely", "scared", "love", "hate", "feel", "feeling"]
        let foundEmotions = emotionalWords.filter { lowercased.contains($0) }
        
        if foundEmotions.count > 2 {
            return "Lines don't push narrative forward. Repeating emotional beats ('\(foundEmotions.prefix(2).joined(separator: "', '"))'). Move the story—add new information or escalate."
        } else if foundEmotions.count > 0 {
            return "Lines don't push narrative forward. Repeating '\(foundEmotions.first!)'. Move the story—add new information or escalate."
        } else {
            return "Lines don't push narrative forward. Repeating emotional beats. Move the story—add new information or escalate."
        }
    }
    
    private func generateEmotionalLeakageCritique(line: String, metrics: SignalMetrics) -> String {
        let lowercased = line.lowercased()
        let emotionalWords = ["hurt", "pain", "angry", "sad", "upset", "lonely", "scared", "love", "hate", "feel", "feeling", "crying", "tears"]
        let foundEmotions = emotionalWords.filter { lowercased.contains($0) }
        
        if foundEmotions.count > 1 {
            return "Emotional leakage. You're repeating emotional language ('\(foundEmotions.prefix(2).joined(separator: "', '"))'). One admission is stronger than multiple. Contain the feeling—don't let it spill."
        } else if foundEmotions.count == 1 {
            return "Emotional leakage. The word '\(foundEmotions.first!)' repeats an emotional beat you've already hit. One admission is stronger than multiple."
        } else {
            return "Emotional leakage. You're repeating emotional language. One admission is stronger than multiple. Contain the feeling—don't let it spill."
        }
    }
    
    private func generateDefensiveFramingCritique(line: String, metrics: SignalMetrics) -> String {
        let lowercased = line.lowercased()
        
        // Check for specific defensive markers
        let defensiveMarkers = [
            ("i'm not saying", "I'm not saying"),
            ("i'm not trying to", "I'm not trying to"),
            ("i don't mean to", "I don't mean to"),
            ("it's not like", "It's not like"),
            ("you might think", "You might think"),
            ("you don't understand", "You don't understand")
        ]
        
        for (marker, display) in defensiveMarkers {
            if lowercased.contains(marker) {
                return "Defensive framing. '\(display)' preemptively defends your position and weakens authority. State your position without justification."
            }
        }
        
        return "Defensive framing. You're preemptively defending yourself. 'I'm not saying' and 'you might think' weakens authority. State your position without justification."
    }
    
    private func generateWeakAuthorityCritique(line: String, metrics: SignalMetrics) -> String {
        let lowercased = line.lowercased()
        
        // FIX 5: Concise A&R critique format
        let weakMarkers = [
            ("i think", "I think"),
            ("i guess", "I guess"),
            ("i suppose", "I suppose"),
            ("maybe", "maybe"),
            ("perhaps", "perhaps"),
            ("i'm not sure", "I'm not sure"),
            ("i don't know", "I don't know"),
            ("i hope", "I hope"),
            ("i wish", "I wish")
        ]
        
        for (marker, display) in weakMarkers {
            if lowercased.contains(marker) {
                return "Weak authority. '\(display)' makes position tentative. Replace with declarative: 'I am' or 'I have'."
            }
        }
        
        let authorityMarkers = ["i am", "i'm", "i got", "i have", "i own", "i control", "i run", "i lead", "i make", "i decide", "i know", "i see"]
        let hasAuthority = authorityMarkers.contains { lowercased.contains($0) }
        
        if !hasAuthority && metrics.authorityPosture < 0.3 {
            return "Weak authority. Line lacks declarative strength. Add 'I am' or 'I have'—own your position."
        }
        
        return "Weak authority. Too much tentative language. Replace with declarative statements—own your position."
    }
    
    private func generateInformationRefusalViolationCritique(line: String, metrics: SignalMetrics) -> String {
        let lowercased = line.lowercased()
        
        // Check for explanation markers
        let explanationMarkers = ["because", "since", "so that", "in order to", "that's why", "the reason", "explain"]
        let foundExplanation = explanationMarkers.first { lowercased.contains($0) }
        
        if let word = foundExplanation {
            return "Information refusal violation. You're explaining with '\(word)' when you should be mysterious. Mystery is the point—let them infer. Don't spell it out."
        }
        
        return "Information refusal violation. You're explaining when you should be mysterious. Mystery is the point—let them infer. Don't spell it out."
    }
    
    // MARK: - Helper Functions
    
    private func extractTimeMarker(from line: String) -> String {
        let timeMarkers = ["yesterday", "today", "tomorrow", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        let lowercased = line.lowercased()
        for marker in timeMarkers {
            if lowercased.contains(marker) {
                return marker.capitalized
            }
        }
        return "time marker"
    }
    
    private func hasProperNouns(_ text: String) -> Bool {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        var hasName = false
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, _ in
            if tag != nil {
                hasName = true
                return false // Stop enumeration
            }
            return true
        }
        return hasName
    }
    
    // MARK: - PR 10: GeneratorPolicy Violation Checks
    
    private func checkForbiddenVerbs(line: TextLine, policy: GeneratorPolicy) -> LineCritique? {
        let lowercased = line.text.lowercased()
        for forbiddenVerb in policy.forbiddenVerbs {
            if lowercased.contains(forbiddenVerb) {
                let critique = "GeneratorPolicy violation. Forbidden verb '\(forbiddenVerb)' appears. Model G (Gunna) does not allow reflection verbs like 'learn', 'feel', 'think'. Use transactional verbs instead: 'buy', 'spend', 'cop', 'drop'."
                return LineCritique(
                    lineText: line.text,
                    lineRange: line.range,
                    critique: critique,
                    critiqueType: .forbiddenVerb(forbiddenVerb)
                )
            }
        }
        return nil
    }
    
    private func checkClauseLength(line: TextLine, policy: GeneratorPolicy) -> LineCritique? {
        // Simple syllable estimation (can be enhanced)
        let words = line.text.components(separatedBy: .whitespaces)
        let estimatedSyllables = Double(words.count) * 1.5  // Rough estimate
        
        if Int(estimatedSyllables) > policy.maxClauseSyllables {
            let critique = "GeneratorPolicy violation. Clause too long (\(Int(estimatedSyllables)) estimated syllables, max \(policy.maxClauseSyllables)). Model G (Gunna) requires punchy, concise lines. Trim or split this clause."
            return LineCritique(
                lineText: line.text,
                lineRange: line.range,
                critique: critique,
                critiqueType: .clauseTooLong(Int(estimatedSyllables))
            )
        }
        return nil
    }
    
    private func checkBrandCount(line: TextLine, policy: GeneratorPolicy) -> LineCritique? {
        let lowercased = line.text.lowercased()
        let commonBrands = ["gucci", "prada", "versace", "louis", "vuitton", "dior", "chanel", "balenciaga", "fendi", "hermes", "rolex"]
        let brandCount = commonBrands.filter { lowercased.contains($0) }.count
        
        if brandCount > policy.brandPerBarMax {
            let critique = "GeneratorPolicy violation. Too many brands (\(brandCount), max \(policy.brandPerBarMax)). Model G (Gunna) prefers restraint—one brand per bar is enough."
            return LineCritique(
                lineText: line.text,
                lineRange: line.range,
                critique: critique,
                critiqueType: .tooManyBrands(brandCount)
            )
        }
        return nil
    }
    
    private func checkPriceAnchoring(text: String, policy: GeneratorPolicy) -> LineCritique? {
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let lastNBars = Array(lines.suffix(policy.priceAnchorEveryNBars))
        
        let pricePattern = #"\$?\d+[KMB]?"#
        let hasPrice = lastNBars.contains { bar in
            bar.range(of: pricePattern, options: .regularExpression) != nil
        }
        
        if !hasPrice && lastNBars.count >= policy.priceAnchorEveryNBars {
            let critique = "GeneratorPolicy violation. No price mentioned in last \(policy.priceAnchorEveryNBars) bars. Model G (Gunna) requires price anchoring every \(policy.priceAnchorEveryNBars) bars. Add a price reference (e.g., '$50K', '100K', '2M')."
            // Create a critique for the last line
            if let lastLine = lines.last, let lastRange = text.range(of: lastLine) {
                return LineCritique(
                    lineText: lastLine,
                    lineRange: lastRange,
                    critique: critique,
                    critiqueType: .missingPriceAnchor
                )
            }
        }
        return nil
    }
}
