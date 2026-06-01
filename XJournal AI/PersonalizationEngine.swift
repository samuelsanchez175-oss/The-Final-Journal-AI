import Foundation

// MARK: - Personalization Engine
// Adapts suggestions based on user feedback history

class PersonalizationEngine {
    static let shared = PersonalizationEngine()
    
    private let personalizationKey = "user_personalization"
    
    private init() {}
    
    // MARK: - Get User Preferences
    
    func getUserPreferences() -> UserPreferences {
        if let data = UserDefaults.standard.data(forKey: personalizationKey),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            return preferences
        }
        
        // Initialize with defaults
        return UserPreferences(
            preferredStyle: nil,
            preferredThemes: [],
            preferredModel: nil,
            qualityThreshold: 0.5,
            learnedAt: Date()
        )
    }
    
    // MARK: - Learn from Feedback
    
    func learnFromFeedback() {
        let feedback = SuggestionFeedbackManager.shared.getRecentFeedback(limit: 100)
        let likedFeedback = feedback.filter { $0.feedback == .liked }
        let dislikedFeedback = feedback.filter { $0.feedback == .disliked }
        
        guard !likedFeedback.isEmpty else { return }
        
        // Learn style preferences
        let preferredStyle = learnStylePreference(liked: likedFeedback, disliked: dislikedFeedback)
        
        // Learn theme preferences
        let preferredThemes = learnThemePreferences(liked: likedFeedback, disliked: dislikedFeedback)
        
        // Learn model preference (would need model tracking in feedback)
        let preferredModel = learnModelPreference(liked: likedFeedback, disliked: dislikedFeedback)
        
        // Learn quality threshold
        let qualityThreshold = learnQualityThreshold(liked: likedFeedback)
        
        let preferences = UserPreferences(
            preferredStyle: preferredStyle,
            preferredThemes: preferredThemes,
            preferredModel: preferredModel,
            qualityThreshold: qualityThreshold,
            learnedAt: Date()
        )
        
        savePreferences(preferences)
    }
    
    /// Learn from feedback automatically when feedback is recorded (called periodically)
    func learnFromFeedbackIfNeeded() {
        let preferences = getUserPreferences()
        let timeSinceLastLearn = Date().timeIntervalSince(preferences.learnedAt)
        
        // Re-learn if it's been more than 1 hour since last learning, or if we have new feedback
        if timeSinceLastLearn > 3600 {
            learnFromFeedback()
        }
    }
    
    // MARK: - Apply Personalization
    
    func personalizeSuggestions(_ suggestions: [RapSuggestion]) -> [RapSuggestion] {
        let preferences = getUserPreferences()
        var personalized = suggestions
        
        // Reorder by user preferences
        personalized.sort { suggestion1, suggestion2 in
            let score1 = calculatePersonalizationScore(suggestion: suggestion1, preferences: preferences)
            let score2 = calculatePersonalizationScore(suggestion: suggestion2, preferences: preferences)
            return score1 > score2
        }
        
        // Filter by quality threshold
        if preferences.qualityThreshold > 0 {
            personalized = personalized.filter { suggestion in
                suggestion.confidence >= preferences.qualityThreshold
            }
        }
        
        return personalized
    }
    
    // MARK: - Get Personalized Settings
    
    func getPersonalizedModelSettings() -> ModelSettings? {
        let _ = getUserPreferences()
        
        // Return model settings adapted to user preferences
        // This would integrate with existing ModelSettings
        return nil // Placeholder
    }
    
    // MARK: - Private Helpers
    
    private func learnStylePreference(liked: [EnhancedFeedbackEntry], disliked: [EnhancedFeedbackEntry]) -> StylePreference? {
        // Analyze style characteristics from liked suggestions
        // Extract style patterns from suggestion text
        var vocabularyLevels: [String: Int] = [:]
        var sentenceStructures: [String: Int] = [:]
        var energyLevels: [String: Int] = [:]
        var formalityLevels: [String: Int] = [:]
        
        for entry in liked {
            let text = entry.suggestionText
            // Estimate vocabulary level
            let words = text.components(separatedBy: .whitespacesAndNewlines)
            let avgLength = words.reduce(0) { $0 + $1.count } / max(words.count, 1)
            let vocabLevel = avgLength > 6 ? "complex" : avgLength < 4 ? "simple" : "mixed"
            vocabularyLevels[vocabLevel, default: 0] += 1
            
            // Estimate sentence structure
            let lines = text.components(separatedBy: "\n").filter { !$0.isEmpty }
            let avgLineLength = lines.reduce(0) { $0 + $1.count } / max(lines.count, 1)
            let structure = avgLineLength < 30 ? "short-punchy" : avgLineLength > 60 ? "long-flowing" : "varied"
            sentenceStructures[structure, default: 0] += 1
            
            // Estimate energy level
            let uppercaseCount = text.filter { $0.isUppercase }.count
            let totalChars = text.filter { $0.isLetter }.count
            let uppercaseRatio = totalChars > 0 ? Double(uppercaseCount) / Double(totalChars) : 0
            let exclamationCount = text.filter { $0 == "!" }.count
            let energy = (uppercaseRatio > 0.1 || exclamationCount > 0) ? "high" : "medium"
            energyLevels[energy, default: 0] += 1
            
            // Estimate formality (simplified - would need more sophisticated analysis)
            let slangIndicators = ["'", "n'", "gonna", "wanna", "ain't", "ya", "yo"]
            let hasSlang = slangIndicators.contains { text.lowercased().contains($0) }
            let formality = hasSlang ? "street-slang" : "mixed"
            formalityLevels[formality, default: 0] += 1
        }
        
        // Find most common preferences
        let preferredVocab = vocabularyLevels.max(by: { $0.value < $1.value })?.key
        let preferredStructure = sentenceStructures.max(by: { $0.value < $1.value })?.key
        let preferredEnergy = energyLevels.max(by: { $0.value < $1.value })?.key
        let preferredFormality = formalityLevels.max(by: { $0.value < $1.value })?.key
        
        // Only return if we have enough data
        if liked.count >= 5 {
            return StylePreference(
                vocabularyLevel: preferredVocab,
                sentenceStructure: preferredStructure,
                energyLevel: preferredEnergy,
                formalityLevel: preferredFormality
            )
        }
        
        return nil
    }
    
    private func learnThemePreferences(liked: [EnhancedFeedbackEntry], disliked: [EnhancedFeedbackEntry]) -> [String] {
        // Extract themes from liked suggestions
        // Use themes from the suggestion if available, or extract from text
        let themeCounts: [String: Int] = [:]
        
        for _ in liked {
            // If we have theme information in feedback, use it
            // Otherwise, we'd need to extract themes from text (simplified for now)
            // For now, we'll rely on themes being passed in suggestions
            // This would ideally be enhanced with NLP theme extraction
        }
        
        // Return top 5 most common themes
        return Array(themeCounts.sorted(by: { $0.value > $1.value }).prefix(5).map { $0.key })
    }
    
    private func learnModelPreference(liked: [EnhancedFeedbackEntry], disliked: [EnhancedFeedbackEntry]) -> String? {
        // Would need model tracking in feedback
        // For now, return nil - this would require adding model identifier to feedback entries
        return nil
    }
    
    private func learnQualityThreshold(liked: [EnhancedFeedbackEntry]) -> Double {
        // Calculate average quality of liked suggestions
        // Use quality metrics if available, otherwise use a default threshold
        var totalQuality: Double = 0.0
        var count = 0
        
        for entry in liked {
            if let corrections = entry.qualityMetricCorrections {
                // Use corrected metrics if available
                var metrics: [Double] = []
                if let rhyme = corrections.rhymeStrengthCorrection { metrics.append(rhyme) }
                if let flow = corrections.flowMatchCorrection { metrics.append(flow) }
                if let style = corrections.styleMatchCorrection { metrics.append(style) }
                if let confidence = corrections.confidenceCorrection { metrics.append(confidence) }
                
                if !metrics.isEmpty {
                    let avgQuality = metrics.reduce(0, +) / Double(metrics.count)
                    totalQuality += avgQuality
                    count += 1
                }
            }
        }
        
        if count > 0 {
            let avgQuality = totalQuality / Double(count)
            // Set threshold slightly below average to allow some variation
            return max(0.3, min(0.8, avgQuality - 0.1))
        }
        
        // Default threshold if no quality data
        return 0.5
    }
    
    private func calculatePersonalizationScore(suggestion: RapSuggestion, preferences: UserPreferences) -> Double {
        var score: Double = suggestion.confidence
        
        // Boost score if matches preferred style
        if let preferredStyle = preferences.preferredStyle {
            var styleMatch: Double = 0.0
            
            // Estimate suggestion style
            let text = suggestion.text
            let words = text.components(separatedBy: .whitespacesAndNewlines)
            let avgLength = words.reduce(0) { $0 + $1.count } / max(words.count, 1)
            let vocabLevel = avgLength > 6 ? "complex" : avgLength < 4 ? "simple" : "mixed"
            
            let lines = text.components(separatedBy: "\n").filter { !$0.isEmpty }
            let avgLineLength = lines.reduce(0) { $0 + $1.count } / max(lines.count, 1)
            let structure = avgLineLength < 30 ? "short-punchy" : avgLineLength > 60 ? "long-flowing" : "varied"
            
            let uppercaseCount = text.filter { $0.isUppercase }.count
            let totalChars = text.filter { $0.isLetter }.count
            let uppercaseRatio = totalChars > 0 ? Double(uppercaseCount) / Double(totalChars) : 0
            let exclamationCount = text.filter { $0 == "!" }.count
            let energy = (uppercaseRatio > 0.1 || exclamationCount > 0) ? "high" : "medium"
            
            // Compare with preferred style
            if let prefVocab = preferredStyle.vocabularyLevel, prefVocab == vocabLevel {
                styleMatch += 0.25
            }
            if let prefStructure = preferredStyle.sentenceStructure, prefStructure == structure {
                styleMatch += 0.25
            }
            if let prefEnergy = preferredStyle.energyLevel, prefEnergy == energy {
                styleMatch += 0.25
            }
            if let prefFormality = preferredStyle.formalityLevel {
                let slangIndicators = ["'", "n'", "gonna", "wanna", "ain't", "ya", "yo"]
                let hasSlang = slangIndicators.contains { text.lowercased().contains($0) }
                let formality = hasSlang ? "street-slang" : "mixed"
                if prefFormality == formality {
                    styleMatch += 0.25
                }
            }
            
            // Boost score based on style match
            score += styleMatch * 0.15
        }
        
        // Boost score if matches preferred themes
        if !preferences.preferredThemes.isEmpty {
            let matchingThemes = suggestion.themes.filter { preferences.preferredThemes.contains($0) }
            if !matchingThemes.isEmpty {
                score += Double(matchingThemes.count) * 0.1
            }
        }
        
        return min(score, 1.0)
    }
    
    private func savePreferences(_ preferences: UserPreferences) {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: personalizationKey)
        }
    }
}

// MARK: - Data Models

struct UserPreferences: Codable {
    let preferredStyle: StylePreference?
    let preferredThemes: [String]
    let preferredModel: String?
    let qualityThreshold: Double // Minimum confidence threshold
    let learnedAt: Date
}

struct StylePreference: Codable {
    let vocabularyLevel: String? // "simple", "complex", "mixed"
    let sentenceStructure: String? // "short-punchy", "long-flowing", "varied"
    let energyLevel: String? // "high", "medium", "low"
    let formalityLevel: String? // "street-slang", "formal", "mixed"
}
