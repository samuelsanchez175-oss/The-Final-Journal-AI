import Foundation
import SwiftData

// MARK: - Suggestion Feedback Manager
// Stores user feedback to improve future AI suggestions

class SuggestionFeedbackManager {
    static let shared = SuggestionFeedbackManager()
    
    private let feedbackKey = "suggestion_feedback"
    private let feedbackLimit = 1000 // Keep last 1000 feedback entries
    
    private init() {}
    
    // MARK: - Store Feedback
    
    func recordFeedback(
        suggestionId: UUID,
        feedback: RapSuggestion.SuggestionFeedback,
        suggestionText: String,
        context: String,
        noteKey: String? = nil,
        generationId: UUID? = nil
    ) {
        recordEnhancedFeedback(
            suggestionId: suggestionId,
            feedback: feedback,
            suggestionText: suggestionText,
            context: context,
            categories: nil,
            qualityMetricCorrections: nil,
            specificIssues: nil,
            expectedVsActual: nil,
            sessionId: UserBehaviorTracker.shared.sessionId ?? UUID().uuidString,
            noteKey: noteKey,
            generationId: generationId
        )
        AIGenerationLedger.applyFeedbackGrade(
            generationId: generationId,
            suggestionId: suggestionId,
            feedback: feedback
        )
    }
    
    func recordEnhancedFeedback(
        suggestionId: UUID,
        feedback: RapSuggestion.SuggestionFeedback,
        suggestionText: String,
        context: String,
        categories: [FeedbackCategory]? = nil,
        qualityMetricCorrections: QualityMetricFeedback? = nil,
        specificIssues: [String]? = nil,
        expectedVsActual: String? = nil,
        sessionId: String? = nil,
        noteKey: String? = nil,
        generationId: UUID? = nil
    ) {
        var allFeedback = loadAllFeedback()
        
        let feedbackEntry = EnhancedFeedbackEntry(
            id: suggestionId,
            suggestionId: suggestionId,
            feedback: feedback,
            categories: categories ?? [],
            qualityMetricCorrections: qualityMetricCorrections,
            specificIssues: specificIssues ?? [],
            expectedVsActual: expectedVsActual,
            suggestionText: suggestionText,
            context: context,
            timestamp: Date(),
            sessionId: sessionId ?? UserBehaviorTracker.shared.sessionId ?? UUID().uuidString,
            noteKey: noteKey,
            generationId: generationId
        )
        
        allFeedback.append(feedbackEntry)
        
        // Keep only recent feedback
        if allFeedback.count > feedbackLimit {
            allFeedback = Array(allFeedback.suffix(feedbackLimit))
        }
        
        saveFeedback(allFeedback)
    }
    
    // MARK: - Analyze Feedback
    
    func getFeedbackStats() -> FeedbackStats {
        let allFeedback = loadAllFeedback()
        let liked = allFeedback.filter { $0.feedback == .liked }.count
        let disliked = allFeedback.filter { $0.feedback == .disliked }.count
        let total = allFeedback.count
        
        return FeedbackStats(
            totalFeedback: total,
            likedCount: liked,
            dislikedCount: disliked,
            acceptanceRate: total > 0 ? Double(liked) / Double(total) : 0.0
        )
    }
    
    func getRecentFeedback(limit: Int = 50) -> [EnhancedFeedbackEntry] {
        let allFeedback = loadAllFeedback()
        return Array(allFeedback.suffix(limit))
    }

    func feedback(forNoteKey noteKey: String, limit: Int = 30) -> [EnhancedFeedbackEntry] {
        let allFeedback = loadAllFeedback()
        return Array(allFeedback.filter { $0.noteKey == noteKey }.suffix(limit))
    }
    
    func getFeedbackByCategory() -> [FeedbackCategory: Int] {
        let allFeedback = loadAllFeedback()
        var categoryCounts: [FeedbackCategory: Int] = [:]
        
        for entry in allFeedback {
            for category in entry.categories {
                categoryCounts[category, default: 0] += 1
            }
        }
        
        return categoryCounts
    }
    
    func getFeedbackStatsByCategory() -> FeedbackCategoryStats {
        let allFeedback = loadAllFeedback()
        var categoryStats: [FeedbackCategory: (liked: Int, disliked: Int)] = [:]
        
        for entry in allFeedback {
            for category in entry.categories {
                var stats = categoryStats[category] ?? (liked: 0, disliked: 0)
                if entry.feedback == .liked {
                    stats.liked += 1
                } else {
                    stats.disliked += 1
                }
                categoryStats[category] = stats
            }
        }
        
        return FeedbackCategoryStats(categoryStats: categoryStats)
    }
    
    // MARK: - Private Helpers
    
    private func loadAllFeedback() -> [EnhancedFeedbackEntry] {
        guard let data = UserDefaults.standard.data(forKey: feedbackKey) else {
            return []
        }
        
        // Try to decode as EnhancedFeedbackEntry first
        if let decoded = try? JSONDecoder().decode([EnhancedFeedbackEntry].self, from: data) {
            return decoded
        }
        
        // Fallback: try to decode as old FeedbackEntry and migrate
        if let oldEntries = try? JSONDecoder().decode([FeedbackEntry].self, from: data) {
            let migrated = oldEntries.map { oldEntry in
                EnhancedFeedbackEntry(
                    id: oldEntry.id,
                    suggestionId: oldEntry.id,
                    feedback: oldEntry.feedback,
                    categories: [],
                    qualityMetricCorrections: nil,
                    specificIssues: [],
                    expectedVsActual: nil,
                    suggestionText: oldEntry.suggestionText,
                    context: oldEntry.context,
                    timestamp: oldEntry.timestamp,
                    sessionId: UUID().uuidString,
                    noteKey: nil,
                    generationId: nil
                )
            }
            saveFeedback(migrated)
            return migrated
        }
        
        return []
    }
    
    private func saveFeedback(_ feedback: [EnhancedFeedbackEntry]) {
        if let encoded = try? JSONEncoder().encode(feedback) {
            UserDefaults.standard.set(encoded, forKey: feedbackKey)
        }
    }
}

// MARK: - Feedback Entry

struct FeedbackEntry: Codable {
    let id: UUID
    let feedback: RapSuggestion.SuggestionFeedback
    let suggestionText: String
    let context: String // The text that prompted this suggestion
    let timestamp: Date
}

// MARK: - Enhanced Feedback Entry

struct EnhancedFeedbackEntry: Codable {
    let id: UUID
    let suggestionId: UUID
    let feedback: RapSuggestion.SuggestionFeedback
    let categories: [FeedbackCategory] // Why it was good/bad
    let qualityMetricCorrections: QualityMetricFeedback?
    let specificIssues: [String] // User-provided text
    let expectedVsActual: String? // What user wanted vs got
    let suggestionText: String
    let context: String
    let timestamp: Date
    let sessionId: String
    let noteKey: String?
    let generationId: UUID?
}

// MARK: - Feedback Category

enum FeedbackCategory: String, Codable, CaseIterable {
    case rhymeQuality = "rhyme_quality"
    case flowRhythm = "flow_rhythm"
    case styleMismatch = "style_mismatch"
    case themeInconsistency = "theme_inconsistency"
    case voiceMismatch = "voice_mismatch"
    case contentQuality = "content_quality"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .rhymeQuality: return "Rhyme Quality"
        case .flowRhythm: return "Flow/Rhythm"
        case .styleMismatch: return "Style Mismatch"
        case .themeInconsistency: return "Theme Inconsistency"
        case .voiceMismatch: return "Voice Mismatch"
        case .contentQuality: return "Content Quality"
        case .other: return "Other"
        }
    }
}

// MARK: - Quality Metric Feedback

struct QualityMetricFeedback: Codable {
    let rhymeStrengthCorrection: Double? // User's corrected rhyme strength (0.0-1.0)
    let flowMatchCorrection: Double? // User's corrected flow match (0.0-1.0)
    let styleMatchCorrection: Double? // User's corrected style match (0.0-1.0)
    let confidenceCorrection: Double? // User's corrected confidence (0.0-1.0)
}

// MARK: - Feedback Category Stats

struct FeedbackCategoryStats {
    let categoryStats: [FeedbackCategory: (liked: Int, disliked: Int)]
    
    func getAcceptanceRate(for category: FeedbackCategory) -> Double {
        guard let stats = categoryStats[category] else { return 0.0 }
        let total = stats.liked + stats.disliked
        return total > 0 ? Double(stats.liked) / Double(total) : 0.0
    }
}

// MARK: - Feedback Stats

struct FeedbackStats {
    let totalFeedback: Int
    let likedCount: Int
    let dislikedCount: Int
    let acceptanceRate: Double // Percentage of suggestions that were liked
}
