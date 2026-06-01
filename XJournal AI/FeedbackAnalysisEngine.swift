import Foundation

// MARK: - Feedback Analysis Engine
// Analyzes feedback patterns to identify improvements

class FeedbackAnalysisEngine {
    static let shared = FeedbackAnalysisEngine()
    
    private init() {}
    
    // MARK: - Pattern Detection
    
    func analyzeFeedbackPatterns() -> FeedbackPatternAnalysis {
        let allFeedback = SuggestionFeedbackManager.shared.getRecentFeedback(limit: 500)
        let categoryStats = SuggestionFeedbackManager.shared.getFeedbackStatsByCategory()
        
        // Identify common issues
        let commonIssues = identifyCommonIssues(feedback: allFeedback)
        
        // Analyze trends over time
        let trends = analyzeTrends(feedback: allFeedback)
        
        // Model performance comparison
        let modelPerformance = analyzeModelPerformance(feedback: allFeedback)
        
        // Quality metric accuracy
        let metricAccuracy = analyzeQualityMetricAccuracy(feedback: allFeedback)
        
        // Category-based insights
        let categoryInsights = analyzeCategoryInsights(categoryStats: categoryStats)
        
        return FeedbackPatternAnalysis(
            commonIssues: commonIssues,
            trends: trends,
            modelPerformance: modelPerformance,
            qualityMetricAccuracy: metricAccuracy,
            categoryInsights: categoryInsights,
            totalFeedbackAnalyzed: allFeedback.count
        )
    }
    
    // MARK: - Issue Identification
    
    func identifyCommonIssues(feedback: [EnhancedFeedbackEntry]) -> [CommonIssue] {
        var issueCounts: [FeedbackCategory: Int] = [:]
        
        for entry in feedback where entry.feedback == .disliked {
            for category in entry.categories {
                issueCounts[category, default: 0] += 1
            }
        }
        
        let totalDisliked = feedback.filter { $0.feedback == .disliked }.count
        let threshold = max(3, totalDisliked / 10) // At least 10% of disliked feedback
        
        return issueCounts
            .filter { $0.value >= threshold }
            .sorted { $0.value > $1.value }
            .map { category, count in
                CommonIssue(
                    category: category,
                    occurrenceCount: count,
                    percentage: Double(count) / Double(totalDisliked)
                )
            }
    }
    
    // MARK: - Trend Analysis
    
    func analyzeTrends(feedback: [EnhancedFeedbackEntry]) -> FeedbackTrends {
        guard feedback.count >= 20 else {
            return FeedbackTrends(
                acceptanceRateTrend: .stable,
                categoryTrends: [:],
                qualityTrend: .stable
            )
        }
        
        // Split into two halves
        let sortedFeedback = feedback.sorted { $0.timestamp < $1.timestamp }
        let midpoint = sortedFeedback.count / 2
        let firstHalf = Array(sortedFeedback.prefix(midpoint))
        let secondHalf = Array(sortedFeedback.suffix(sortedFeedback.count - midpoint))
        
        // Calculate acceptance rates
        let firstHalfRate = calculateAcceptanceRate(feedback: firstHalf)
        let secondHalfRate = calculateAcceptanceRate(feedback: secondHalf)
        
        let acceptanceRateTrend: TrendDirection
        if secondHalfRate > firstHalfRate + 0.1 {
            acceptanceRateTrend = .improving
        } else if secondHalfRate < firstHalfRate - 0.1 {
            acceptanceRateTrend = .declining
        } else {
            acceptanceRateTrend = .stable
        }
        
        // Analyze category trends
        var categoryTrends: [FeedbackCategory: TrendDirection] = [:]
        for category in FeedbackCategory.allCases {
            let firstHalfCount = firstHalf.filter { $0.categories.contains(category) }.count
            let secondHalfCount = secondHalf.filter { $0.categories.contains(category) }.count
            
            let firstHalfRate = Double(firstHalfCount) / Double(firstHalf.count)
            let secondHalfRate = Double(secondHalfCount) / Double(secondHalf.count)
            
            if secondHalfRate > firstHalfRate + 0.05 {
                categoryTrends[category] = .improving
            } else if secondHalfRate < firstHalfRate - 0.05 {
                categoryTrends[category] = .declining
            } else {
                categoryTrends[category] = .stable
            }
        }
        
        // Quality trend (based on quality metric corrections)
        let qualityTrend = analyzeQualityTrend(feedback: feedback)
        
        return FeedbackTrends(
            acceptanceRateTrend: acceptanceRateTrend,
            categoryTrends: categoryTrends,
            qualityTrend: qualityTrend
        )
    }
    
    // MARK: - Model Performance
    
    func analyzeModelPerformance(feedback: [EnhancedFeedbackEntry]) -> ModelPerformanceAnalysis {
        // Group feedback by model (would need to track model in feedback)
        // For now, return placeholder
        return ModelPerformanceAnalysis(
            modelAcceptanceRates: [:],
            modelCommonIssues: [:]
        )
    }
    
    // MARK: - Quality Metric Accuracy
    
    func analyzeQualityMetricAccuracy(feedback: [EnhancedFeedbackEntry]) -> QualityMetricAccuracy {
        let feedbackWithCorrections = feedback.filter { $0.qualityMetricCorrections != nil }
        
        guard !feedbackWithCorrections.isEmpty else {
            return QualityMetricAccuracy(
                rhymeStrengthAccuracy: nil,
                flowMatchAccuracy: nil,
                styleMatchAccuracy: nil,
                averageCorrectionMagnitude: nil
            )
        }
        
        let _: [Double] = []
        let _: [Double] = []
        let _: [Double] = []
        
        for entry in feedbackWithCorrections {
            guard entry.qualityMetricCorrections != nil else { continue }
            
            // Would need original metrics from suggestion - placeholder for now
            // In real implementation, would compare original vs corrected values
        }
        
        return QualityMetricAccuracy(
            rhymeStrengthAccuracy: nil,
            flowMatchAccuracy: nil,
            styleMatchAccuracy: nil,
            averageCorrectionMagnitude: nil
        )
    }
    
    // MARK: - Category Insights
    
    func analyzeCategoryInsights(categoryStats: FeedbackCategoryStats) -> [CategoryInsight] {
        var insights: [CategoryInsight] = []
        
        for category in FeedbackCategory.allCases {
            let acceptanceRate = categoryStats.getAcceptanceRate(for: category)
            
            if acceptanceRate < 0.3 {
                insights.append(CategoryInsight(
                    category: category,
                    insight: "Low acceptance rate (\(Int(acceptanceRate * 100))%). This area needs improvement.",
                    priority: .high
                ))
            } else if acceptanceRate > 0.7 {
                insights.append(CategoryInsight(
                    category: category,
                    insight: "High acceptance rate (\(Int(acceptanceRate * 100))%). This area is performing well.",
                    priority: .low
                ))
            }
        }
        
        return insights.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    // MARK: - Private Helpers
    
    private func calculateAcceptanceRate(feedback: [EnhancedFeedbackEntry]) -> Double {
        guard !feedback.isEmpty else { return 0.0 }
        let likedCount = feedback.filter { $0.feedback == .liked }.count
        return Double(likedCount) / Double(feedback.count)
    }
    
    private func analyzeQualityTrend(feedback: [EnhancedFeedbackEntry]) -> TrendDirection {
        // Analyze if quality metric corrections are decreasing (improving) or increasing (declining)
        let sortedFeedback = feedback.sorted { $0.timestamp < $1.timestamp }
        let midpoint = sortedFeedback.count / 2
        
        guard midpoint > 0 else { return .stable }
        
        let firstHalf = Array(sortedFeedback.prefix(midpoint))
        let secondHalf = Array(sortedFeedback.suffix(sortedFeedback.count - midpoint))
        
        let firstHalfCorrections = firstHalf.filter { $0.qualityMetricCorrections != nil }.count
        let secondHalfCorrections = secondHalf.filter { $0.qualityMetricCorrections != nil }.count
        
        let firstHalfRate = Double(firstHalfCorrections) / Double(firstHalf.count)
        let secondHalfRate = Double(secondHalfCorrections) / Double(secondHalf.count)
        
        if secondHalfRate < firstHalfRate - 0.05 {
            return .improving // Fewer corrections needed
        } else if secondHalfRate > firstHalfRate + 0.05 {
            return .declining // More corrections needed
        } else {
            return .stable
        }
    }
}

// MARK: - Data Models

struct FeedbackPatternAnalysis {
    let commonIssues: [CommonIssue]
    let trends: FeedbackTrends
    let modelPerformance: ModelPerformanceAnalysis
    let qualityMetricAccuracy: QualityMetricAccuracy
    let categoryInsights: [CategoryInsight]
    let totalFeedbackAnalyzed: Int
}

struct CommonIssue {
    let category: FeedbackCategory
    let occurrenceCount: Int
    let percentage: Double // Percentage of disliked feedback with this issue
}

struct FeedbackTrends {
    let acceptanceRateTrend: TrendDirection
    let categoryTrends: [FeedbackCategory: TrendDirection]
    let qualityTrend: TrendDirection
}

enum TrendDirection {
    case improving
    case stable
    case declining
}

struct ModelPerformanceAnalysis {
    let modelAcceptanceRates: [String: Double] // Model identifier -> acceptance rate
    let modelCommonIssues: [String: [FeedbackCategory]] // Model identifier -> common issues
}

struct QualityMetricAccuracy {
    let rhymeStrengthAccuracy: Double? // 0.0-1.0, how accurate AI's rhyme strength is
    let flowMatchAccuracy: Double?
    let styleMatchAccuracy: Double?
    let averageCorrectionMagnitude: Double? // Average difference between AI and user corrections
}

struct CategoryInsight {
    let category: FeedbackCategory
    let insight: String
    let priority: InsightPriority
}

enum InsightPriority: Int {
    case low = 1
    case medium = 2
    case high = 3
}
