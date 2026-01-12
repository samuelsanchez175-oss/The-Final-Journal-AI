import Foundation
import NaturalLanguage

// MARK: - Signal Profile

struct SignalProfile {
    let explanationDensity: Double      // 0.0-1.0: Frequency of causal language, justification
    let specificityLoad: Double          // 0.0-1.0: Names, acts, sequences, detailed grievances
    let emotionalLeakage: Double        // 0.0-1.0: Repetition of affect, sentiment volatility
    let defensiveFraming: Double        // 0.0-1.0: Preemptive rebuttals, grievance validation
    let authorityPosture: Double        // 0.0-1.0: Confidence indicators, position strength
    
    // Computed properties for mode detection
    var hasHighExplanation: Bool { explanationDensity > 0.6 }
    var hasHighEmotion: Bool { emotionalLeakage > 0.6 }
    var hasHighSpecificity: Bool { specificityLoad > 0.6 }
    var hasDefensiveTone: Bool { defensiveFraming > 0.5 }
    var hasWeakAuthority: Bool { authorityPosture < 0.4 }
}

// MARK: - Signal Ingest

class SignalIngest {
    static let shared = SignalIngest()
    
    private init() {}
    
    // MARK: - Main Analysis Function
    
    func analyzeBehavior(text: String) -> SignalProfile {
        let explanationDensity = extractExplanationDensity(text: text)
        let specificityLoad = extractSpecificityLoad(text: text)
        let emotionalLeakage = detectEmotionalLeakage(text: text)
        let defensiveFraming = detectDefensiveFraming(text: text)
        let authorityPosture = detectAuthorityPosture(text: text)
        
        return SignalProfile(
            explanationDensity: explanationDensity,
            specificityLoad: specificityLoad,
            emotionalLeakage: emotionalLeakage,
            defensiveFraming: defensiveFraming,
            authorityPosture: authorityPosture
        )
    }
    
    // MARK: - Explanation Density
    
    /// Detects frequency of causal language, justification, narrative reasoning
    func extractExplanationDensity(text: String) -> Double {
        let explanationMarkers = [
            "because", "since", "so that", "in order to", "due to", "as a result",
            "therefore", "thus", "hence", "consequently", "for this reason",
            "that's why", "which is why", "the reason", "explain", "justify",
            "I had to", "I needed to", "I was forced", "I had no choice",
            "I did it because", "I did this because", "I'm saying", "I'm telling you"
        ]
        
        let lowercased = text.lowercased()
        var matchCount = 0
        var totalWords = 0
        
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            totalWords += 1
            let word = String(text[range]).lowercased()
            
            // Check for exact matches
            if explanationMarkers.contains(word) {
                matchCount += 1
            }
            
            // Check for phrases
            for marker in explanationMarkers where marker.contains(" ") {
                if lowercased.contains(marker) {
                    matchCount += 1
                    break
                }
            }
            
            return true
        }
        
        guard totalWords > 0 else { return 0.0 }
        
        // Normalize to 0.0-1.0 scale
        let rawDensity = Double(matchCount) / Double(totalWords)
        return min(rawDensity * 10.0, 1.0) // Scale up since matches are relatively rare
    }
    
    // MARK: - Specificity Load
    
    /// Detects names, acts, sequences, detailed grievances
    func extractSpecificityLoad(text: String) -> Double {
        var specificityScore = 0.0
        
        // Check for proper nouns (names)
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        var nameCount = 0
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            if tag != nil {
                nameCount += 1
            }
            return true
        }
        
        // Check for specific time markers
        let timeMarkers = [
            "yesterday", "today", "tomorrow", "last week", "last month", "last year",
            "at 3am", "at midnight", "in the morning", "in the afternoon",
            "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday",
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        let lowercased = text.lowercased()
        var timeMarkerCount = 0
        for marker in timeMarkers {
            if lowercased.contains(marker) {
                timeMarkerCount += 1
            }
        }
        
        // Check for specific locations
        let locationMarkers = [
            "at the", "in the", "on the", "downtown", "uptown", "street", "avenue",
            "building", "apartment", "house", "room", "corner", "block"
        ]
        var locationCount = 0
        for marker in locationMarkers {
            if lowercased.contains(marker) {
                locationCount += 1
            }
        }
        
        // Check for specific actions/verbs (detailed acts)
        let actionVerbs = [
            "grabbed", "threw", "pushed", "pulled", "ran", "walked", "drove",
            "called", "texted", "sent", "received", "bought", "sold", "gave", "took"
        ]
        var actionCount = 0
        for verb in actionVerbs {
            if lowercased.contains(verb) {
                actionCount += 1
            }
        }
        
        // Count total words
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var wordCount = 0
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { _, _ in
            wordCount += 1
            return true
        }
        
        guard wordCount > 0 else { return 0.0 }
        
        // Weighted specificity score
        let totalSpecificity = Double(nameCount * 3 + timeMarkerCount * 2 + locationCount + actionCount)
        specificityScore = min(totalSpecificity / Double(wordCount) * 5.0, 1.0)
        
        return specificityScore
    }
    
    // MARK: - Emotional Leakage
    
    /// Detects repetition of affect, sentiment volatility, emotional redundancy
    func detectEmotionalLeakage(text: String) -> Double {
        let emotionalWords = [
            "hurt", "pain", "angry", "mad", "sad", "upset", "frustrated", "disappointed",
            "betrayed", "abandoned", "lonely", "scared", "afraid", "worried", "anxious",
            "love", "hate", "care", "feel", "feeling", "emotion", "emotional",
            "crying", "tears", "heart", "soul", "broken", "damaged", "destroyed"
        ]
        
        let lowercased = text.lowercased()
        var emotionalWordCount = 0
        var uniqueEmotionalWords = Set<String>()
        
        for word in emotionalWords {
            if lowercased.contains(word) {
                emotionalWordCount += 1
                uniqueEmotionalWords.insert(word)
            }
        }
        
        // Check for repetition of emotional words
        var repetitionScore = 0.0
        for word in uniqueEmotionalWords {
            let occurrences = lowercased.components(separatedBy: word).count - 1
            if occurrences > 1 {
                repetitionScore += Double(occurrences - 1) * 0.1
            }
        }
        
        // Count total words
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var wordCount = 0
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { _, _ in
            wordCount += 1
            return true
        }
        
        guard wordCount > 0 else { return 0.0 }
        
        // Combine frequency and repetition
        let frequencyScore = min(Double(emotionalWordCount) / Double(wordCount) * 10.0, 1.0)
        let repetitionPenalty = min(repetitionScore, 0.5)
        
        return min(frequencyScore + repetitionPenalty, 1.0)
    }
    
    // MARK: - Defensive Framing
    
    /// Detects preemptive rebuttals, grievance validation, self-justification
    func detectDefensiveFraming(text: String) -> Double {
        let defensiveMarkers = [
            "I'm not saying", "I'm not trying to", "I don't mean to", "I didn't mean",
            "it's not like", "it's not that", "I know you think", "you might think",
            "but I", "but you", "I had to", "I had no choice", "I was forced",
            "I didn't want to", "I didn't ask for", "I never asked for",
            "I'm not the one", "I'm not the type", "I'm not like",
            "you don't understand", "you don't know", "you can't understand",
            "I deserve", "I earned", "I worked for", "I deserve this",
            "I'm not wrong", "I'm right", "I did nothing wrong"
        ]
        
        let lowercased = text.lowercased()
        var matchCount = 0
        
        for marker in defensiveMarkers {
            if lowercased.contains(marker) {
                matchCount += 1
            }
        }
        
        // Count total words
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var wordCount = 0
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { _, _ in
            wordCount += 1
            return true
        }
        
        guard wordCount > 0 else { return 0.0 }
        
        // Normalize to 0.0-1.0
        let rawDensity = Double(matchCount) / Double(wordCount)
        return min(rawDensity * 20.0, 1.0) // Scale up since matches are relatively rare
    }
    
    // MARK: - Authority Posture
    
    /// Detects confidence indicators, position strength
    func detectAuthorityPosture(text: String) -> Double {
        let authorityMarkers = [
            "I am", "I'm", "I got", "I have", "I own", "I control",
            "I run", "I lead", "I make", "I decide", "I choose",
            "I know", "I see", "I understand", "I get it",
            "I don't care", "I don't need", "I don't want",
            "I'm the", "I'm a", "I'm one of", "I'm the only",
            "they know", "they see", "they understand",
            "nobody can", "nobody will", "nobody does",
            "I move", "I go", "I do", "I act", "I make moves"
        ]
        
        let weakMarkers = [
            "I think", "I guess", "I suppose", "maybe", "perhaps", "might",
            "I'm not sure", "I don't know", "I'm not certain",
            "I hope", "I wish", "I want", "I need", "I wish I could",
            "I'm trying", "I'm trying to", "I'm working on",
            "I should", "I could", "I would", "I might"
        ]
        
        let lowercased = text.lowercased()
        var authorityCount = 0
        var weakCount = 0
        
        for marker in authorityMarkers {
            if lowercased.contains(marker) {
                authorityCount += 1
            }
        }
        
        for marker in weakMarkers {
            if lowercased.contains(marker) {
                weakCount += 1
            }
        }
        
        // Count total words
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var wordCount = 0
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { _, _ in
            wordCount += 1
            return true
        }
        
        guard wordCount > 0 else { return 0.5 }
        
        // Calculate authority score
        let authorityScore = min(Double(authorityCount) / Double(wordCount) * 15.0, 1.0)
        let weaknessPenalty = min(Double(weakCount) / Double(wordCount) * 10.0, 0.5)
        
        return max(0.0, min(1.0, authorityScore - weaknessPenalty))
    }
}
