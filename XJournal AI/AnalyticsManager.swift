import Foundation
import SwiftData

// MARK: - Analytics Manager (Phase 6: Analytics Dashboard)

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - Writing Statistics
    
    struct WritingStats {
        let totalNotes: Int
        let totalWords: Int
        let averageWordsPerNote: Double
        let notesPerDay: Double
        let writingStreak: Int
        let mostActiveDay: String
        let mostActiveHour: Int
        let mostUsedWords: [(word: String, count: Int)]
        let commonThemes: [String]
        let averageBPM: Double?
        let mostUsedKey: String?
        let totalAudioDuration: TimeInterval?
        
        // Churn metrics
        let churnRisk: ChurnRiskLevel?
        let sessionFrequency: Double?
        let featureAdoptionRate: Double?
        let suggestionAcceptanceRate: Double?
    }
    
    func calculateStats(items: [Item]) -> WritingStats {
        let totalNotes = items.count
        
        // Calculate total words
        let totalWords = items.reduce(0) { total, item in
            let words = item.body.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
            return total + words.count
        }
        
        let averageWordsPerNote = totalNotes > 0 ? Double(totalWords) / Double(totalNotes) : 0.0
        
        // Calculate notes per day
        guard let oldestDate = items.map({ $0.timestamp }).min(),
              let newestDate = items.map({ $0.timestamp }).max() else {
            // Churn metrics (default values when no data)
            let churnAssessment = ChurnRiskAnalyzer.shared.assessChurnRisk()
            let engagementMetrics = UserBehaviorTracker.shared.getEngagementMetrics()
            let feedbackStats = SuggestionFeedbackManager.shared.getFeedbackStats()
            
            return WritingStats(
                totalNotes: totalNotes,
                totalWords: totalWords,
                averageWordsPerNote: averageWordsPerNote,
                notesPerDay: 0,
                writingStreak: 0,
                mostActiveDay: "N/A",
                mostActiveHour: 0,
                mostUsedWords: [],
                commonThemes: [],
                averageBPM: nil,
                mostUsedKey: nil,
                totalAudioDuration: nil,
                churnRisk: churnAssessment.riskLevel,
                sessionFrequency: engagementMetrics.sessionFrequency,
                featureAdoptionRate: engagementMetrics.featureAdoptionRate,
                suggestionAcceptanceRate: feedbackStats.acceptanceRate
            )
        }
        
        let daysDiff = Calendar.current.dateComponents([.day], from: oldestDate, to: newestDate).day ?? 1
        let notesPerDay = Double(totalNotes) / Double(max(daysDiff, 1))
        
        // Calculate writing streak
        let writingStreak = calculateWritingStreak(items: items)
        
        // Find most active day
        let dayOfWeekCounts = Dictionary(grouping: items) { item in
            Calendar.current.component(.weekday, from: item.timestamp)
        }.mapValues { $0.count }
        
        let mostActiveDayNumber = dayOfWeekCounts.max(by: { $0.value < $1.value })?.key ?? 1
        let mostActiveDay = Calendar.current.weekdaySymbols[mostActiveDayNumber - 1]
        
        // Find most active hour
        let hourCounts = Dictionary(grouping: items) { item in
            Calendar.current.component(.hour, from: item.timestamp)
        }.mapValues { $0.count }
        
        let mostActiveHour = hourCounts.max(by: { $0.value < $1.value })?.key ?? 12
        
        // Most used words
        let allWords = items.flatMap { item in
            item.body.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty && $0.count > 3 } // Filter short words
        }
        
        let wordCounts = Dictionary(grouping: allWords) { $0 }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { (word: $0.key, count: $0.value) }
        
        // Common themes (simplified - would use AI in production)
        let commonThemes = extractCommonThemes(items: items)
        
        // Average BPM
        let bpms = items.compactMap { $0.bpm }
        let averageBPM = bpms.isEmpty ? nil : Double(bpms.reduce(0, +)) / Double(bpms.count)
        
        // Most used key
        let keys = items.compactMap { $0.key }
        let keyCounts = Dictionary(grouping: keys) { $0 }.mapValues { $0.count }
        let mostUsedKey = keyCounts.max(by: { $0.value < $1.value })?.key
        
        // Total audio duration
        let totalAudioDuration = items.compactMap { $0.audioDuration }.reduce(0, +)
        
        // Churn metrics
        let churnAssessment = ChurnRiskAnalyzer.shared.assessChurnRisk()
        let engagementMetrics = UserBehaviorTracker.shared.getEngagementMetrics()
        let feedbackStats = SuggestionFeedbackManager.shared.getFeedbackStats()
        
        return WritingStats(
            totalNotes: totalNotes,
            totalWords: totalWords,
            averageWordsPerNote: averageWordsPerNote,
            notesPerDay: notesPerDay,
            writingStreak: writingStreak,
            mostActiveDay: mostActiveDay,
            mostActiveHour: mostActiveHour,
            mostUsedWords: Array(wordCounts),
            commonThemes: commonThemes,
            averageBPM: averageBPM,
            mostUsedKey: mostUsedKey,
            totalAudioDuration: totalAudioDuration > 0 ? totalAudioDuration : nil,
            churnRisk: churnAssessment.riskLevel,
            sessionFrequency: engagementMetrics.sessionFrequency,
            featureAdoptionRate: engagementMetrics.featureAdoptionRate,
            suggestionAcceptanceRate: feedbackStats.acceptanceRate
        )
    }
    
    // MARK: - Private Helpers
    
    private func calculateWritingStreak(items: [Item]) -> Int {
        guard !items.isEmpty else { return 0 }
        
        let sortedItems = items.sorted { $0.timestamp < $1.timestamp }
        var streak = 1
        var currentStreak = 1
        
        for i in 1..<sortedItems.count {
            let previousDate = sortedItems[i - 1].timestamp
            let currentDate = sortedItems[i].timestamp
            
            if Calendar.current.isDate(previousDate, inSameDayAs: currentDate) {
                // Same day, continue streak
                continue
            } else if let daysBetween = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day,
                      daysBetween == 1 {
                // Consecutive days
                currentStreak += 1
                streak = max(streak, currentStreak)
            } else {
                // Streak broken
                currentStreak = 1
            }
        }
        
        return streak
    }
    
    private func extractCommonThemes(items: [Item]) -> [String] {
        // Simplified theme extraction - would use AI/NLP in production
        let commonWords = items.flatMap { item in
            item.body.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { $0.count > 4 }
        }
        
        let wordCounts = Dictionary(grouping: commonWords) { $0 }
            .mapValues { $0.count }
            .filter { $0.value >= 3 } // Appears in at least 3 notes
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
        
        return Array(wordCounts)
    }
}
