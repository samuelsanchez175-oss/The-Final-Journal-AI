import Foundation
import UserNotifications

// MARK: - Smart Notification Manager
// Context-aware notifications based on user behavior

class SmartNotificationManager {
    static let shared = SmartNotificationManager()
    
    private var hasRequestedPermission = false
    
    private init() {
        // DO NOT request permission synchronously - it blocks startup
        // Will be requested lazily when first needed
    }
    
    // MARK: - Notification Permission
    
    func requestNotificationPermission() {
        // Only request once
        guard !hasRequestedPermission else { return }
        hasRequestedPermission = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Schedule Notifications
    
    /// Schedule contextual notifications asynchronously on background thread
    /// This should be called after UI is fully rendered to avoid blocking startup
    func scheduleContextualNotifications() async {
        StartupPerformanceTracker.shared.recordMilestone("smart_notifications_start")
        
        // Perform churn analysis on background thread
        let assessment = ChurnRiskAnalyzer.shared.assessChurnRisk()
        StartupPerformanceTracker.shared.recordMilestone("churn_analysis_complete")
        
        // Get engagement metrics on background thread
        let engagementMetrics = UserBehaviorTracker.shared.getEngagementMetrics()
        StartupPerformanceTracker.shared.recordMilestone("engagement_metrics_complete")
        
        // Schedule notifications (these are async operations)
        await MainActor.run {
            // Check for writing streak reminders
            self.scheduleWritingStreakReminder(engagementMetrics: engagementMetrics)
            
            // Check for feature tips
            self.scheduleFeatureTips(engagementMetrics: engagementMetrics)
            
            // Check for churn interventions
            if assessment.riskLevel == .high || assessment.riskLevel == .medium {
                self.scheduleChurnIntervention(assessment: assessment)
            }
        }
        
        StartupPerformanceTracker.shared.recordMilestone("smart_notifications_complete")
    }
    
    // MARK: - Writing Streak Reminders
    
    private func scheduleWritingStreakReminder(engagementMetrics: EngagementMetrics) {
        let daysSinceLastActive = Calendar.current.dateComponents([.day], from: engagementMetrics.lastActiveDate, to: Date()).day ?? 0
        
        // Remind if streak is at risk (2 days inactive)
        if daysSinceLastActive == 2 {
            let content = UNMutableNotificationContent()
            content.title = "Keep Your Streak Going!"
            content.body = "You're on a \(engagementMetrics.wordsWrittenToday > 0 ? "writing" : "potential") streak. Don't break it!"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 1 hour from now
            let request = UNNotificationRequest(identifier: "streak_reminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    // MARK: - Feature Tips
    
    private func scheduleFeatureTips(engagementMetrics: EngagementMetrics) {
        // Schedule tips for unused features
        if engagementMetrics.featureAdoptionRate < 0.5 {
            let content = UNMutableNotificationContent()
            content.title = "Discover New Features"
            content.body = "There are powerful AI features you haven't tried yet. Check them out!"
            content.sound = .default
            
            // Schedule for tomorrow at a good time (e.g., 6 PM)
            var components = DateComponents()
            components.hour = 18
            components.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "feature_tip", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    // MARK: - Churn Interventions
    
    private func scheduleChurnIntervention(assessment: ChurnRiskAssessment) {
        let interventionManager = ChurnInterventionManager.shared
        // Pass assessment to avoid duplicate churn analysis
        interventionManager.checkAndTriggerInterventions(assessment: assessment)
        
        if let intervention = interventionManager.getNextIntervention() {
            let content = UNMutableNotificationContent()
            content.title = intervention.title
            content.body = intervention.message
            content.sound = .default
            content.userInfo = [
                "intervention_id": intervention.id.uuidString,
                "intervention_type": intervention.type.rawValue
            ]
            
            // Schedule for a good time (e.g., 2 hours from now)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: false)
            let request = UNNotificationRequest(identifier: "churn_intervention_\(intervention.id.uuidString)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
