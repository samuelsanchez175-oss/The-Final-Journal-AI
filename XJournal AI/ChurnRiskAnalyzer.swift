import Foundation

// MARK: - Churn Risk Analyzer
// Identifies users at risk of churning based on engagement patterns

class ChurnRiskAnalyzer {
    static let shared = ChurnRiskAnalyzer()
    
    private init() {}
    
    // MARK: - Churn Risk Assessment
    
    func assessChurnRisk() -> ChurnRiskAssessment {
        let behaviorTracker = UserBehaviorTracker.shared
        let engagementMetrics = behaviorTracker.getEngagementMetrics()
        let recentSessions = behaviorTracker.getRecentSessions(limit: 30)
        
        // Calculate week-over-week session frequency change
        let sessionFrequencyChange = calculateSessionFrequencyChange(sessions: recentSessions)
        
        // Check for feature abandonment
        let featureAbandonment = checkFeatureAbandonment(metrics: engagementMetrics)
        
        // Check for negative feedback trends
        let _ = SuggestionFeedbackManager.shared.getFeedbackStats()
        let recentFeedback = SuggestionFeedbackManager.shared.getRecentFeedback(limit: 10)
        let negativeFeedbackTrend = checkNegativeFeedbackTrend(recentFeedback: recentFeedback)
        
        // Check dormancy
        let dormancyDays = calculateDormancyDays(lastActive: engagementMetrics.lastActiveDate)
        
        // Check regenerate frequency (frustration indicator)
        let interactionTracker = SuggestionInteractionTracker.shared
        let regenerateFrequency = interactionTracker.getRegenerateFrequency(context: "")
        
        // Calculate risk score
        var riskScore: Double = 0.0
        var riskFactors: [ChurnRiskFactor] = []
        
        // Session frequency drop >50%
        if sessionFrequencyChange < -0.5 {
            riskScore += 0.25
            riskFactors.append(.sessionFrequencyDecline)
        }
        
        // Feature abandonment
        if featureAbandonment {
            riskScore += 0.20
            riskFactors.append(.featureAbandonment)
        }
        
        // Negative feedback trend
        if negativeFeedbackTrend {
            riskScore += 0.20
            riskFactors.append(.negativeFeedbackTrend)
        }
        
        // Dormancy >14 days
        if dormancyDays > 14 {
            riskScore += 0.20
            riskFactors.append(.dormancy)
        }
        
        // High regenerate frequency (>3x per suggestion)
        if regenerateFrequency > 3.0 {
            riskScore += 0.15
            riskFactors.append(.highRegenerateFrequency)
        }
        
        // Determine risk level
        let riskLevel: ChurnRiskLevel
        if riskScore >= 0.6 {
            riskLevel = .high
        } else if riskScore >= 0.3 {
            riskLevel = .medium
        } else {
            riskLevel = .low
        }
        
        return ChurnRiskAssessment(
            riskLevel: riskLevel,
            riskScore: riskScore,
            riskFactors: riskFactors,
            sessionFrequencyChange: sessionFrequencyChange,
            featureAbandonment: featureAbandonment,
            negativeFeedbackTrend: negativeFeedbackTrend,
            dormancyDays: dormancyDays,
            regenerateFrequency: regenerateFrequency,
            lastActiveDate: engagementMetrics.lastActiveDate
        )
    }
    
    // MARK: - Private Helpers
    
    private func calculateSessionFrequencyChange(sessions: [SessionData]) -> Double {
        guard sessions.count >= 14 else { return 0.0 } // Need at least 2 weeks of data
        
        let sortedSessions = sessions.sorted { $0.startTime < $1.startTime }
        let midpoint = sortedSessions.count / 2
        
        let firstWeek = Array(sortedSessions.prefix(midpoint))
        let secondWeek = Array(sortedSessions.suffix(sortedSessions.count - midpoint))
        
        let firstWeekDays = Set(firstWeek.map { Calendar.current.startOfDay(for: $0.startTime) }).count
        let secondWeekDays = Set(secondWeek.map { Calendar.current.startOfDay(for: $0.startTime) }).count
        
        guard firstWeekDays > 0 else { return 0.0 }
        
        return Double(secondWeekDays - firstWeekDays) / Double(firstWeekDays)
    }
    
    private func checkFeatureAbandonment(metrics: EngagementMetrics) -> Bool {
        // Check if user was active but stopped using AI features
        let daysSinceLastActive = Calendar.current.dateComponents([.day], from: metrics.lastActiveDate, to: Date()).day ?? 0
        
        // If user was active in last 7 days but feature adoption is low
        if daysSinceLastActive <= 7 && metrics.featureAdoptionRate < 0.3 {
            return true
        }
        
        return false
    }
    
    private func checkNegativeFeedbackTrend(recentFeedback: [EnhancedFeedbackEntry]) -> Bool {
        guard recentFeedback.count >= 10 else { return false }
        
        let dislikedCount = recentFeedback.filter { $0.feedback == .disliked }.count
        let dislikeRate = Double(dislikedCount) / Double(recentFeedback.count)
        
        // Dislike rate >60% indicates negative trend
        return dislikeRate > 0.6
    }
    
    private func calculateDormancyDays(lastActive: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: lastActive, to: Date()).day ?? 0
    }
}

// MARK: - Data Models

struct ChurnRiskAssessment {
    let riskLevel: ChurnRiskLevel
    let riskScore: Double // 0.0-1.0
    let riskFactors: [ChurnRiskFactor]
    let sessionFrequencyChange: Double // Week-over-week change
    let featureAbandonment: Bool
    let negativeFeedbackTrend: Bool
    let dormancyDays: Int
    let regenerateFrequency: Double
    let lastActiveDate: Date
}

enum ChurnRiskLevel {
    case low
    case medium
    case high
    
    var displayName: String {
        switch self {
        case .low: return "Low Risk"
        case .medium: return "Medium Risk"
        case .high: return "High Risk"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

enum ChurnRiskFactor: String, Codable {
    case sessionFrequencyDecline = "session_frequency_decline"
    case featureAbandonment = "feature_abandonment"
    case negativeFeedbackTrend = "negative_feedback_trend"
    case dormancy = "dormancy"
    case highRegenerateFrequency = "high_regenerate_frequency"
    
    var displayName: String {
        switch self {
        case .sessionFrequencyDecline: return "Session frequency declining"
        case .featureAbandonment: return "Stopped using AI features"
        case .negativeFeedbackTrend: return "Increasing negative feedback"
        case .dormancy: return "Inactive for extended period"
        case .highRegenerateFrequency: return "Frequently regenerating suggestions"
        }
    }
}
