import Foundation

// MARK: - Achievement System
// Tracks and manages user achievements (badges & milestones)

class AchievementSystem {
    static let shared = AchievementSystem()
    
    private let achievementsKey = "user_achievements"
    private let unlockedAchievementsKey = "unlocked_achievements"
    
    private init() {
        // Initialize all achievements if first launch
        if UserDefaults.standard.data(forKey: achievementsKey) == nil {
            initializeAllAchievements()
        }
    }
    
    // MARK: - Achievement Definitions
    
    func getAllAchievements() -> [Achievement] {
        guard let data = UserDefaults.standard.data(forKey: achievementsKey),
              let achievements = try? JSONDecoder().decode([Achievement].self, from: data) else {
            initializeAllAchievements()
            return getAllAchievements()
        }
        return achievements
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return getAllAchievements().filter { $0.unlockedAt != nil }
    }
    
    func getLockedAchievements() -> [Achievement] {
        return getAllAchievements().filter { $0.unlockedAt == nil }
    }
    
    func getAchievementsByCategory(_ category: AchievementCategory) -> [Achievement] {
        return getAllAchievements().filter { $0.category == category }
    }
    
    // MARK: - Check and Unlock Achievements
    
    /// Check achievements with provided stats
    func checkAchievements(notesCount: Int, totalWords: Int, streak: Int, featureUsage: [FeatureType: Int]) {
        var achievements = getAllAchievements()
        var newlyUnlocked: [Achievement] = []
        
        for index in achievements.indices {
            var achievement = achievements[index]
            
            // Skip if already unlocked
            if achievement.unlockedAt != nil {
                continue
            }
            
            // Check if achievement should be unlocked
            var shouldUnlock = false
            var progress: Double = 0.0
            
            switch achievement.id {
            // Writing milestones
            case "notes_10", "notes_50", "notes_100", "notes_500":
                let target = achievement.targetValue
                progress = min(1.0, Double(notesCount) / Double(target))
                shouldUnlock = notesCount >= target
                
            // Word count milestones
            case "words_1k", "words_10k", "words_50k", "words_100k":
                let target = achievement.targetValue
                progress = min(1.0, Double(totalWords) / Double(target))
                shouldUnlock = totalWords >= target
                
            // Streak achievements
            case "streak_3", "streak_7", "streak_14", "streak_30", "streak_100":
                let target = achievement.targetValue
                progress = min(1.0, Double(streak) / Double(target))
                shouldUnlock = streak >= target
                
            // Feature usage badges
            case "ai_suggestions_10", "ai_suggestions_50", "ai_suggestions_100":
                let count = featureUsage[.aiSuggestions] ?? 0
                let target = achievement.targetValue
                progress = min(1.0, Double(count) / Double(target))
                shouldUnlock = count >= target
                
            case "rhyme_highlighting_10", "rhyme_highlighting_50":
                let count = featureUsage[.rhymeHighlighting] ?? 0
                let target = achievement.targetValue
                progress = min(1.0, Double(count) / Double(target))
                shouldUnlock = count >= target
                
            case "rewrite_line_10", "rewrite_line_50":
                let count = featureUsage[.rewriteLine] ?? 0
                let target = achievement.targetValue
                progress = min(1.0, Double(count) / Double(target))
                shouldUnlock = count >= target
                
            case "improve_flow_10", "improve_flow_50":
                let count = featureUsage[.improveFlow] ?? 0
                let target = achievement.targetValue
                progress = min(1.0, Double(count) / Double(target))
                shouldUnlock = count >= target
                
            default:
                break
            }
            
            // Update progress
            achievement.progress = progress
            
            // Unlock if criteria met
            if shouldUnlock {
                achievement.unlockedAt = Date()
                newlyUnlocked.append(achievement)
            }
            
            achievements[index] = achievement
        }
        
        // Save updated achievements
        saveAchievements(achievements)
        
        // Notify about newly unlocked achievements
        if !newlyUnlocked.isEmpty {
            NotificationCenter.default.post(
                name: NSNotification.Name("AchievementUnlocked"),
                object: nil,
                userInfo: ["achievements": newlyUnlocked]
            )
        }
    }
    
    // MARK: - Initialize All Achievements
    
    private func initializeAllAchievements() {
        let allAchievements: [Achievement] = [
            // Writing milestones
            Achievement(
                id: "notes_10",
                title: "Getting Started",
                description: "Created 10 notes",
                icon: "square.and.pencil",
                category: .writing,
                targetValue: 10,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "notes_50",
                title: "Dedicated Writer",
                description: "Created 50 notes",
                icon: "book.fill",
                category: .writing,
                targetValue: 50,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "notes_100",
                title: "Century Club",
                description: "Created 100 notes",
                icon: "book.closed.fill",
                category: .writing,
                targetValue: 100,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "notes_500",
                title: "Master Writer",
                description: "Created 500 notes",
                icon: "books.vertical.fill",
                category: .writing,
                targetValue: 500,
                unlockedAt: nil,
                progress: 0.0
            ),
            
            // Word count milestones
            Achievement(
                id: "words_1k",
                title: "Thousand Words",
                description: "Written 1,000 words",
                icon: "text.word.spacing",
                category: .words,
                targetValue: 1000,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "words_10k",
                title: "Ten Thousand",
                description: "Written 10,000 words",
                icon: "textformat",
                category: .words,
                targetValue: 10000,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "words_50k",
                title: "Novel Writer",
                description: "Written 50,000 words",
                icon: "text.book.closed",
                category: .words,
                targetValue: 50000,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "words_100k",
                title: "Word Master",
                description: "Written 100,000 words",
                icon: "text.magnifyingglass",
                category: .words,
                targetValue: 100000,
                unlockedAt: nil,
                progress: 0.0
            ),
            
            // Streak achievements
            Achievement(
                id: "streak_3",
                title: "Three Day Streak",
                description: "Wrote for 3 days in a row",
                icon: "flame.fill",
                category: .streak,
                targetValue: 3,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "streak_7",
                title: "Week Warrior",
                description: "Wrote for 7 days in a row",
                icon: "flame.fill",
                category: .streak,
                targetValue: 7,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "streak_14",
                title: "Two Week Champion",
                description: "Wrote for 14 days in a row",
                icon: "flame.fill",
                category: .streak,
                targetValue: 14,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "streak_30",
                title: "Monthly Master",
                description: "Wrote for 30 days in a row",
                icon: "flame.fill",
                category: .streak,
                targetValue: 30,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "streak_100",
                title: "Century Streak",
                description: "Wrote for 100 days in a row",
                icon: "flame.fill",
                category: .streak,
                targetValue: 100,
                unlockedAt: nil,
                progress: 0.0
            ),
            
            // Feature usage badges
            Achievement(
                id: "ai_suggestions_10",
                title: "AI Explorer",
                description: "Used AI suggestions 10 times",
                icon: "sparkles",
                category: .features,
                targetValue: 10,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "ai_suggestions_50",
                title: "AI Enthusiast",
                description: "Used AI suggestions 50 times",
                icon: "sparkles.rectangle.stack",
                category: .features,
                targetValue: 50,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "ai_suggestions_100",
                title: "AI Master",
                description: "Used AI suggestions 100 times",
                icon: "sparkles.tv",
                category: .features,
                targetValue: 100,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "rhyme_highlighting_10",
                title: "Rhyme Seeker",
                description: "Used rhyme highlighting 10 times",
                icon: "eye.fill",
                category: .features,
                targetValue: 10,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "rhyme_highlighting_50",
                title: "Rhyme Master",
                description: "Used rhyme highlighting 50 times",
                icon: "eye.circle.fill",
                category: .features,
                targetValue: 50,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "rewrite_line_10",
                title: "Line Refiner",
                description: "Rewrote lines 10 times",
                icon: "arrow.triangle.2.circlepath",
                category: .features,
                targetValue: 10,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "rewrite_line_50",
                title: "Line Perfectionist",
                description: "Rewrote lines 50 times",
                icon: "arrow.triangle.2.circlepath.circle.fill",
                category: .features,
                targetValue: 50,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "improve_flow_10",
                title: "Flow Enhancer",
                description: "Improved flow 10 times",
                icon: "waveform.path",
                category: .features,
                targetValue: 10,
                unlockedAt: nil,
                progress: 0.0
            ),
            Achievement(
                id: "improve_flow_50",
                title: "Flow Master",
                description: "Improved flow 50 times",
                icon: "waveform.path.ecg",
                category: .features,
                targetValue: 50,
                unlockedAt: nil,
                progress: 0.0
            )
        ]
        
        saveAchievements(allAchievements)
    }
    
    // MARK: - Private Helpers
    
    private func saveAchievements(_ achievements: [Achievement]) {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
}

// MARK: - Data Models

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let targetValue: Int
    var unlockedAt: Date?
    var progress: Double // 0.0-1.0
}

enum AchievementCategory: String, Codable {
    case writing = "Writing"
    case words = "Words"
    case streak = "Streak"
    case features = "Features"
    case quality = "Quality"
}
