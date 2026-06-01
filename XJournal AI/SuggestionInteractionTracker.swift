import Foundation
import SwiftUI

// MARK: - Suggestion Interaction Tracker
// Tracks detailed user interactions with suggestions for quality analysis

class SuggestionInteractionTracker {
    static let shared = SuggestionInteractionTracker()
    
    private let interactionsKey = "suggestion_interactions"
    private let interactionLimit = 500 // Keep last 500 interactions
    
    private init() {}
    
    // MARK: - Track Interactions
    
    func trackSuggestionView(suggestionId: UUID, timestamp: Date = Date()) {
        let interaction = SuggestionInteractionData(
            suggestionId: suggestionId,
            action: .viewed,
            timestamp: timestamp,
            viewDuration: nil,
            scrollPosition: nil,
            metadata: nil
        )
        recordInteraction(interaction)
    }
    
    func trackSuggestionViewDuration(suggestionId: UUID, duration: TimeInterval) {
        // Update existing view interaction with duration
        var interactions = loadInteractions()
        if let index = interactions.lastIndex(where: { $0.suggestionId == suggestionId && $0.action == .viewed }) {
            interactions[index].viewDuration = duration
            saveInteractions(interactions)
        }
    }
    
    func trackScrollPosition(suggestionId: UUID, position: Double) {
        // Track scroll position (0.0-1.0, where 1.0 is bottom)
        var interactions = loadInteractions()
        if let index = interactions.lastIndex(where: { $0.suggestionId == suggestionId && $0.action == .viewed }) {
            interactions[index].scrollPosition = position
            saveInteractions(interactions)
        }
    }
    
    func trackSuggestionAction(suggestionId: UUID, action: SuggestionInteractionAction, metadata: [String: Any]? = nil) {
        let interaction = SuggestionInteractionData(
            suggestionId: suggestionId,
            action: action,
            timestamp: Date(),
            viewDuration: nil,
            scrollPosition: nil,
            metadata: metadata?.mapValues { String(describing: $0) }
        )
        recordInteraction(interaction)
    }
    
    func trackRegenerate(context: String, previousSuggestionIds: [UUID]) {
        let interaction = SuggestionInteractionData(
            suggestionId: UUID(), // New suggestion being generated
            action: .regenerated,
            timestamp: Date(),
            viewDuration: nil,
            scrollPosition: nil,
            metadata: [
                "previous_suggestion_count": String(previousSuggestionIds.count),
                "context_length": String(context.count)
            ]
        )
        recordInteraction(interaction)
    }
    
    func trackFeedbackTiming(suggestionId: UUID, timeSinceView: TimeInterval, feedback: RapSuggestion.SuggestionFeedback) {
        let interaction = SuggestionInteractionData(
            suggestionId: suggestionId,
            action: feedback == .liked ? .liked : .disliked,
            timestamp: Date(),
            viewDuration: timeSinceView,
            scrollPosition: nil,
            metadata: [
                "feedback_timing": String(timeSinceView),
                "immediate_feedback": timeSinceView < 5.0 ? "true" : "false"
            ]
        )
        recordInteraction(interaction)
    }
    
    // MARK: - Implicit Feedback Tracking
    
    /// Track when a suggestion is inserted (for time-to-acceptance calculation)
    private var insertionTimestamps: [UUID: Date] = [:]
    
    func trackSuggestionInsertion(suggestionId: UUID, suggestionText: String, context: String) {
        let insertionTime = Date()
        insertionTimestamps[suggestionId] = insertionTime
        
        // Track insertion action
        trackSuggestionAction(
            suggestionId: suggestionId,
            action: .inserted,
            metadata: [
                "suggestion_length": String(suggestionText.count),
                "context_length": String(context.count),
                "insertion_timestamp": String(insertionTime.timeIntervalSince1970)
            ]
        )
    }
    
    /// Track edits to inserted suggestions (implicit negative feedback)
    func trackSuggestionEdit(suggestionId: UUID, originalText: String, editedText: String, editTime: TimeInterval) {
        let editRatio = calculateEditRatio(original: originalText, edited: editedText)
        let wasSignificantlyEdited = editRatio > 0.3 // More than 30% changed
        
        // Record implicit negative feedback if significantly edited
        if wasSignificantlyEdited {
            // Convert to explicit feedback entry
            SuggestionFeedbackManager.shared.recordFeedback(
                suggestionId: suggestionId,
                feedback: .disliked,
                suggestionText: originalText,
                context: ""
            )
        }
        
        trackSuggestionAction(
            suggestionId: suggestionId,
            action: .edited,
            metadata: [
                "edit_ratio": String(editRatio),
                "edit_time_seconds": String(editTime),
                "was_significantly_edited": wasSignificantlyEdited ? "true" : "false",
                "original_length": String(originalText.count),
                "edited_length": String(editedText.count)
            ]
        )
    }
    
    /// Track time-to-acceptance (time from insertion to first edit or acceptance)
    func trackTimeToAcceptance(suggestionId: UUID, wasAccepted: Bool, timeToAcceptance: TimeInterval) {
        // Fast acceptance (< 5 seconds) = positive signal
        // Slow acceptance (> 30 seconds) or edits = negative signal
        let isFastAcceptance = timeToAcceptance < 5.0
        let isSlowAcceptance = timeToAcceptance > 30.0
        
        trackSuggestionAction(
            suggestionId: suggestionId,
            action: wasAccepted ? .accepted : .edited,
            metadata: [
                "time_to_acceptance": String(timeToAcceptance),
                "is_fast_acceptance": isFastAcceptance ? "true" : "false",
                "is_slow_acceptance": isSlowAcceptance ? "true" : "false",
                "was_accepted": wasAccepted ? "true" : "false"
            ]
        )
        
        // Record implicit feedback based on acceptance time
        if wasAccepted {
            if isFastAcceptance {
                // Fast acceptance = positive implicit feedback
                // Could record as liked, but we'll let explicit feedback override
            } else if isSlowAcceptance {
                // Slow acceptance might indicate hesitation
                // Don't record as negative, but track for analysis
            }
        }
    }
    
    /// Get implicit feedback signals for a suggestion
    func getImplicitFeedbackSignals(suggestionId: UUID) -> ImplicitFeedbackSignals {
        let interactions = loadInteractions().filter { $0.suggestionId == suggestionId }
        
        let insertionInteraction = interactions.first { $0.action == .inserted }
        let editInteractions = interactions.filter { $0.action == .edited }
        let acceptanceInteraction = interactions.first { $0.action == .accepted }
        
        var timeToAcceptance: TimeInterval? = nil
        if let insertion = insertionInteraction, let acceptance = acceptanceInteraction {
            timeToAcceptance = acceptance.timestamp.timeIntervalSince(insertion.timestamp)
        }
        
        let editRatio = editInteractions.compactMap { interaction -> Double? in
            guard let ratioStr = interaction.metadata?["edit_ratio"],
                  let ratio = Double(ratioStr) else { return nil }
            return ratio
        }.reduce(0.0, +) / Double(max(editInteractions.count, 1))
        
        let wasSignificantlyEdited = editInteractions.contains {
            ($0.metadata?["was_significantly_edited"] ?? "false") == "true"
        }
        
        return ImplicitFeedbackSignals(
            suggestionId: suggestionId,
            timeToAcceptance: timeToAcceptance,
            editCount: editInteractions.count,
            averageEditRatio: editRatio,
            wasSignificantlyEdited: wasSignificantlyEdited,
            regenerationCount: interactions.filter { $0.action == .regenerated }.count
        )
    }
    
    // MARK: - Private Helpers for Implicit Feedback
    
    private func calculateEditRatio(original: String, edited: String) -> Double {
        // Calculate how much of the original text was changed
        // Using Levenshtein distance as a simple metric
        let distance = levenshteinDistance(original, edited)
        let maxLength = max(original.count, edited.count)
        return maxLength > 0 ? Double(distance) / Double(maxLength) : 0.0
    }
    
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count
        
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            dp[i][0] = i
        }
        
        for j in 0...n {
            dp[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                if s1Array[i - 1] == s2Array[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]) + 1
                }
            }
        }
        
        return dp[m][n]
    }
    
    // MARK: - Analytics
    
    func getInteractionStats(for suggestionId: UUID) -> SuggestionInteractionStats {
        let interactions = loadInteractions().filter { $0.suggestionId == suggestionId }
        
        let viewCount = interactions.filter { $0.action == .viewed }.count
        let averageViewDuration = interactions
            .compactMap { $0.viewDuration }
            .reduce(0.0, +) / Double(max(interactions.count, 1))
        
        let copyCount = interactions.filter { $0.action == .copied }.count
        let insertCount = interactions.filter { $0.action == .inserted }.count
        let likeCount = interactions.filter { $0.action == .liked }.count
        let dislikeCount = interactions.filter { $0.action == .disliked }.count
        
        let copyVsInsertRatio = insertCount > 0 ? Double(copyCount) / Double(insertCount) : (copyCount > 0 ? Double.greatestFiniteMagnitude : 0.0)
        
        return SuggestionInteractionStats(
            suggestionId: suggestionId,
            viewCount: viewCount,
            averageViewDuration: averageViewDuration,
            copyCount: copyCount,
            insertCount: insertCount,
            likeCount: likeCount,
            dislikeCount: dislikeCount,
            copyVsInsertRatio: copyVsInsertRatio,
            wasFavorited: interactions.contains { $0.action == .favorited },
            wasCompared: interactions.contains { $0.action == .compared },
            wasRegenerated: interactions.contains { $0.action == .regenerated }
        )
    }
    
    func getRegenerateFrequency(context: String) -> Double {
        let interactions = loadInteractions()
        let regenerateCount = interactions.filter { $0.action == .regenerated }.count
        let totalSuggestions = interactions.filter { $0.action == .viewed }.count
        
        return totalSuggestions > 0 ? Double(regenerateCount) / Double(totalSuggestions) : 0.0
    }
    
    func getFeedbackTimingStats() -> FeedbackTimingStats {
        let interactions = loadInteractions()
        let feedbackInteractions = interactions.filter { $0.action == .liked || $0.action == .disliked }
        
        let immediateFeedback = feedbackInteractions.filter {
            ($0.metadata?["immediate_feedback"] ?? "false") == "true"
        }.count
        
        let delayedFeedback = feedbackInteractions.count - immediateFeedback
        
        let averageFeedbackTime = feedbackInteractions
            .compactMap { $0.viewDuration }
            .reduce(0.0, +) / Double(max(feedbackInteractions.count, 1))
        
        return FeedbackTimingStats(
            immediateFeedbackCount: immediateFeedback,
            delayedFeedbackCount: delayedFeedback,
            averageFeedbackTime: averageFeedbackTime
        )
    }
    
    // MARK: - Private Helpers
    
    private func recordInteraction(_ interaction: SuggestionInteractionData) {
        var interactions = loadInteractions()
        interactions.append(interaction)
        
        // Keep only recent interactions
        if interactions.count > interactionLimit {
            interactions = Array(interactions.suffix(interactionLimit))
        }
        
        saveInteractions(interactions)
    }
    
    private func loadInteractions() -> [SuggestionInteractionData] {
        guard let data = UserDefaults.standard.data(forKey: interactionsKey),
              let decoded = try? JSONDecoder().decode([SuggestionInteractionData].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private func saveInteractions(_ interactions: [SuggestionInteractionData]) {
        if let encoded = try? JSONEncoder().encode(interactions) {
            UserDefaults.standard.set(encoded, forKey: interactionsKey)
        }
    }
}

// MARK: - Data Models

struct SuggestionInteractionData: Codable {
    let suggestionId: UUID
    let action: SuggestionInteractionAction
    let timestamp: Date
    var viewDuration: TimeInterval?
    var scrollPosition: Double? // 0.0-1.0
    let metadata: [String: String]?
}

enum SuggestionInteractionAction: String, Codable {
    case viewed = "viewed"
    case copied = "copied"
    case inserted = "inserted"
    case liked = "liked"
    case disliked = "disliked"
    case favorited = "favorited"
    case regenerated = "regenerated"
    case compared = "compared"
    case edited = "edited"
    case accepted = "accepted"
}

struct SuggestionInteractionStats {
    let suggestionId: UUID
    let viewCount: Int
    let averageViewDuration: TimeInterval
    let copyCount: Int
    let insertCount: Int
    let likeCount: Int
    let dislikeCount: Int
    let copyVsInsertRatio: Double
    let wasFavorited: Bool
    let wasCompared: Bool
    let wasRegenerated: Bool
}

struct FeedbackTimingStats {
    let immediateFeedbackCount: Int
    let delayedFeedbackCount: Int
    let averageFeedbackTime: TimeInterval
}

struct ImplicitFeedbackSignals {
    let suggestionId: UUID
    let timeToAcceptance: TimeInterval? // Time from insertion to acceptance/edit
    let editCount: Int // Number of times suggestion was edited
    let averageEditRatio: Double // Average ratio of text changed (0.0-1.0)
    let wasSignificantlyEdited: Bool // True if edit ratio > 0.3
    let regenerationCount: Int // Number of times user regenerated before accepting
}
