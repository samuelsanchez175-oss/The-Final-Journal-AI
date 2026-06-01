import Foundation

// MARK: - User Behavior Tracker
// Tracks user engagement patterns, session data, and feature usage for churn analysis

class UserBehaviorTracker {
    static let shared = UserBehaviorTracker()
    
    private let sessionKey = "user_sessions"
    private let engagementKey = "user_engagement"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var currentSessionId: String?
    private var currentSessionStartTime: Date?
    
    private init() {
        // DO NOT start session on initialization - it blocks startup
        // Session will be started lazily when first accessed
    }
    
    // MARK: - Session Management
    
    /// Get the current session ID (if available)
    var sessionId: String? {
        return currentSessionId
    }
    
    func startSession() {
        let sessionId = UUID().uuidString
        currentSessionId = sessionId
        currentSessionStartTime = Date()
        
        // Record session start
        recordSessionEvent(type: .sessionStart, sessionId: sessionId)
    }
    
    func endSession() {
        guard let sessionId = currentSessionId,
              let startTime = currentSessionStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        recordSessionEvent(type: .sessionEnd, sessionId: sessionId, duration: duration)
        
        currentSessionId = nil
        currentSessionStartTime = nil
    }
    
    // MARK: - Engagement Tracking
    
    func trackFeatureUsage(feature: FeatureType) {
        let today = dateFormatter.string(from: Date())
        var engagement = loadEngagement()
        
        // Update today's engagement
        if engagement.date != today {
            engagement = EngagementData(date: today)
        }
        
        switch feature {
        case .aiSuggestions:
            engagement.aiSuggestionsUsed += 1
        case .rewriteLine:
            engagement.rewriteLineUsed += 1
        case .improveFlow:
            engagement.improveFlowUsed += 1
        case .suggestRhymes:
            engagement.suggestRhymesUsed += 1
        case .rhymeHighlighting:
            engagement.rhymeHighlightingUsed += 1
        case .analytics:
            engagement.analyticsUsed += 1
        }
        
        engagement.lastFeatureUsed = feature.rawValue
        engagement.lastFeatureUseTime = Date()
        
        saveEngagement(engagement)
        
        // Check achievements after feature usage
        checkAchievements()
    }
    
    // MARK: - Achievement Checking
    
    /// Check achievements using engagement data
    func checkAchievements() {
        let allEngagement = loadAllEngagementHistory()
        
        // Calculate totals from engagement history
        let totalNotes = allEngagement.reduce(0) { $0 + $1.notesCreated }
        let totalWords = allEngagement.reduce(0) { $0 + $1.wordsWritten }
        
        // Calculate streak from sessions
        let sessions = loadSessions()
        let streak = calculateStreak(from: sessions)
        
        // Get feature usage counts
        var featureUsage: [FeatureType: Int] = [:]
        for entry in allEngagement {
            if entry.aiSuggestionsUsed > 0 {
                featureUsage[.aiSuggestions, default: 0] += entry.aiSuggestionsUsed
            }
            if entry.rewriteLineUsed > 0 {
                featureUsage[.rewriteLine, default: 0] += entry.rewriteLineUsed
            }
            if entry.improveFlowUsed > 0 {
                featureUsage[.improveFlow, default: 0] += entry.improveFlowUsed
            }
            if entry.suggestRhymesUsed > 0 {
                featureUsage[.suggestRhymes, default: 0] += entry.suggestRhymesUsed
            }
            if entry.rhymeHighlightingUsed > 0 {
                featureUsage[.rhymeHighlighting, default: 0] += entry.rhymeHighlightingUsed
            }
        }
        
        // Check achievements
        AchievementSystem.shared.checkAchievements(
            notesCount: totalNotes,
            totalWords: totalWords,
            streak: streak,
            featureUsage: featureUsage
        )
    }
    
    /// Check achievements with actual items data (more accurate)
    func checkAchievementsWithItems(items: [Item]) {
        let totalNotes = items.count
        
        // Calculate total words
        let totalWords = items.reduce(0) { total, item in
            let words = item.body.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
            return total + words.count
        }
        
        // Calculate streak from items
        let streak = calculateStreakFromItems(items: items)
        
        // Get feature usage from engagement
        let allEngagement = loadAllEngagementHistory()
        var featureUsage: [FeatureType: Int] = [:]
        for entry in allEngagement {
            if entry.aiSuggestionsUsed > 0 {
                featureUsage[.aiSuggestions, default: 0] += entry.aiSuggestionsUsed
            }
            if entry.rewriteLineUsed > 0 {
                featureUsage[.rewriteLine, default: 0] += entry.rewriteLineUsed
            }
            if entry.improveFlowUsed > 0 {
                featureUsage[.improveFlow, default: 0] += entry.improveFlowUsed
            }
            if entry.suggestRhymesUsed > 0 {
                featureUsage[.suggestRhymes, default: 0] += entry.suggestRhymesUsed
            }
            if entry.rhymeHighlightingUsed > 0 {
                featureUsage[.rhymeHighlighting, default: 0] += entry.rhymeHighlightingUsed
            }
        }
        
        // Check achievements
        AchievementSystem.shared.checkAchievements(
            notesCount: totalNotes,
            totalWords: totalWords,
            streak: streak,
            featureUsage: featureUsage
        )
    }
    
    private func calculateStreak(from sessions: [SessionData]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let sortedSessions = sessions.sorted { $0.startTime < $1.startTime }
        var streak = 1
        var currentStreak = 1
        
        for i in 1..<sortedSessions.count {
            let previousDate = sortedSessions[i - 1].startTime
            let currentDate = sortedSessions[i].startTime
            
            if Calendar.current.isDate(previousDate, inSameDayAs: currentDate) {
                continue
            } else if let daysBetween = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day,
                      daysBetween == 1 {
                currentStreak += 1
                streak = max(streak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return streak
    }
    
    private func calculateStreakFromItems(items: [Item]) -> Int {
        guard !items.isEmpty else { return 0 }
        
        let sortedItems = items.sorted { $0.timestamp < $1.timestamp }
        var streak = 1
        var currentStreak = 1
        
        for i in 1..<sortedItems.count {
            let previousDate = sortedItems[i - 1].timestamp
            let currentDate = sortedItems[i].timestamp
            
            if Calendar.current.isDate(previousDate, inSameDayAs: currentDate) {
                continue
            } else if let daysBetween = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day,
                      daysBetween == 1 {
                currentStreak += 1
                streak = max(streak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return streak
    }
    
    private func loadAllEngagementHistory() -> [EngagementData] {
        // For now, just return current engagement
        // In a production app, you'd want to store historical daily engagement
        return [loadEngagement()]
    }
    
    func trackWritingActivity(wordsWritten: Int, noteCreated: Bool = false) {
        let today = dateFormatter.string(from: Date())
        var engagement = loadEngagement()
        
        if engagement.date != today {
            engagement = EngagementData(date: today)
        }
        
        engagement.wordsWritten += wordsWritten
        if noteCreated {
            engagement.notesCreated += 1
        }
        engagement.lastWritingActivity = Date()
        
        saveEngagement(engagement)
        
        // Check achievements after tracking activity
        checkAchievements()
    }
    
    func trackSuggestionInteraction(action: SuggestionAction, suggestionId: UUID? = nil) {
        guard let sessionId = currentSessionId else { return }
        
        let interaction = SuggestionInteraction(
            sessionId: sessionId,
            action: action,
            suggestionId: suggestionId,
            timestamp: Date()
        )
        
        recordInteraction(interaction)
    }
    
    // MARK: - Engagement Metrics
    
    func getEngagementMetrics() -> EngagementMetrics {
        let sessions = loadSessions()
        let engagement = loadEngagement()
        
        // Calculate session frequency
        let sessionDates = sessions.map { dateFormatter.string(from: $0.startTime) }
        let uniqueDays = Set(sessionDates).count
        let daysSinceFirstSession = sessions.first.map { 
            Calendar.current.dateComponents([.day], from: $0.startTime, to: Date()).day ?? 1
        } ?? 1
        
        let sessionFrequency = daysSinceFirstSession > 0 ? Double(uniqueDays) / Double(daysSinceFirstSession) : 0.0
        
        // Calculate average session duration
        let completedSessions = sessions.filter { $0.duration != nil }
        let avgSessionDuration = completedSessions.isEmpty ? 0.0 :
            completedSessions.map { $0.duration! }.reduce(0, +) / Double(completedSessions.count)
        
        // Calculate time to first suggestion
        let firstSuggestionTime = sessions.first { $0.firstSuggestionTime != nil }?.firstSuggestionTime
        let timeToFirstSuggestion = firstSuggestionTime.map { 
            $0.timeIntervalSince(sessions.first?.startTime ?? Date())
        } ?? 0.0
        
        // Feature adoption
        let totalFeaturesUsed = (engagement.aiSuggestionsUsed > 0 ? 1 : 0) +
                               (engagement.rewriteLineUsed > 0 ? 1 : 0) +
                               (engagement.improveFlowUsed > 0 ? 1 : 0) +
                               (engagement.suggestRhymesUsed > 0 ? 1 : 0) +
                               (engagement.rhymeHighlightingUsed > 0 ? 1 : 0) +
                               (engagement.analyticsUsed > 0 ? 1 : 0)
        
        // Convert date string to Date for lastActiveDate
        let lastActiveDate: Date
        if let featureUseTime = engagement.lastFeatureUseTime {
            lastActiveDate = featureUseTime
        } else {
            // Parse the date string to Date
            lastActiveDate = dateFormatter.date(from: engagement.date) ?? Date()
        }
        
        return EngagementMetrics(
            totalSessions: sessions.count,
            sessionFrequency: sessionFrequency,
            averageSessionDuration: avgSessionDuration,
            timeToFirstSuggestion: timeToFirstSuggestion,
            featureAdoptionRate: Double(totalFeaturesUsed) / 6.0,
            lastActiveDate: lastActiveDate,
            wordsWrittenToday: engagement.wordsWritten,
            notesCreatedToday: engagement.notesCreated
        )
    }
    
    func getRecentSessions(limit: Int = 30) -> [SessionData] {
        let sessions = loadSessions()
        return Array(sessions.suffix(limit))
    }
    
    // MARK: - Private Helpers
    
    private func recordSessionEvent(type: SessionEventType, sessionId: String, duration: TimeInterval? = nil) {
        var sessions = loadSessions()
        
        if type == .sessionStart {
            let session = SessionData(
                id: sessionId,
                startTime: Date(),
                endTime: nil,
                duration: nil,
                firstSuggestionTime: nil
            )
            sessions.append(session)
        } else if type == .sessionEnd, let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            sessions[index].endTime = Date()
            sessions[index].duration = duration
        }
        
        // Keep only last 100 sessions
        if sessions.count > 100 {
            sessions = Array(sessions.suffix(100))
        }
        
        saveSessions(sessions)
    }
    
    private func recordInteraction(_ interaction: SuggestionInteraction) {
        var sessions = loadSessions()
        guard let index = sessions.firstIndex(where: { $0.id == interaction.sessionId }) else { return }
        
        // Track first suggestion time
        if sessions[index].firstSuggestionTime == nil {
            sessions[index].firstSuggestionTime = interaction.timestamp
        }
        
        saveSessions(sessions)
    }
    
    private func loadSessions() -> [SessionData] {
        guard let data = UserDefaults.standard.data(forKey: sessionKey),
              let decoded = try? JSONDecoder().decode([SessionData].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private func saveSessions(_ sessions: [SessionData]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionKey)
        }
    }
    
    private func loadEngagement() -> EngagementData {
        guard let data = UserDefaults.standard.data(forKey: engagementKey),
              let decoded = try? JSONDecoder().decode(EngagementData.self, from: data) else {
            return EngagementData(date: dateFormatter.string(from: Date()))
        }
        return decoded
    }
    
    private func saveEngagement(_ engagement: EngagementData) {
        if let encoded = try? JSONEncoder().encode(engagement) {
            UserDefaults.standard.set(encoded, forKey: engagementKey)
        }
    }
}

// MARK: - Data Models

struct SessionData: Codable {
    var id: String
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval?
    var firstSuggestionTime: Date?
}

struct EngagementData: Codable {
    var date: String
    var aiSuggestionsUsed: Int = 0
    var rewriteLineUsed: Int = 0
    var improveFlowUsed: Int = 0
    var suggestRhymesUsed: Int = 0
    var rhymeHighlightingUsed: Int = 0
    var analyticsUsed: Int = 0
    var wordsWritten: Int = 0
    var notesCreated: Int = 0
    var lastFeatureUsed: String?
    var lastFeatureUseTime: Date?
    var lastWritingActivity: Date?
}

struct EngagementMetrics {
    let totalSessions: Int
    let sessionFrequency: Double // Sessions per day
    let averageSessionDuration: TimeInterval
    let timeToFirstSuggestion: TimeInterval
    let featureAdoptionRate: Double // 0.0-1.0
    let lastActiveDate: Date
    let wordsWrittenToday: Int
    let notesCreatedToday: Int
}

struct SuggestionInteraction {
    let sessionId: String
    let action: SuggestionAction
    let suggestionId: UUID?
    let timestamp: Date
}

enum SessionEventType {
    case sessionStart
    case sessionEnd
}

enum FeatureType: String, Codable {
    case aiSuggestions = "ai_suggestions"
    case rewriteLine = "rewrite_line"
    case improveFlow = "improve_flow"
    case suggestRhymes = "suggest_rhymes"
    case rhymeHighlighting = "rhyme_highlighting"
    case analytics = "analytics"
}

enum SuggestionAction: String, Codable {
    case viewed = "viewed"
    case copied = "copied"
    case inserted = "inserted"
    case liked = "liked"
    case disliked = "disliked"
    case favorited = "favorited"
    case regenerated = "regenerated"
    case compared = "compared"
}
