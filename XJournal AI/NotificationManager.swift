import Foundation
import UserNotifications
import Combine

// MARK: - Notification Manager
// Handles push notifications for user retention

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let preferencesKey = "notification_preferences"
    private let lastAppOpenKey = "last_app_open"
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // MARK: - Permission Management
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            await MainActor.run {
                checkAuthorizationStatus()
            }
            
            if granted {
                await MainActor.run {
                    UNUserNotificationCenter.current().delegate = self
                }
            }
            
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - Notification Preferences
    
    func getPreferences() -> NotificationPreferences {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let preferences = try? JSONDecoder().decode(NotificationPreferences.self, from: data) else {
            return NotificationPreferences()
        }
        return preferences
    }
    
    func savePreferences(_ preferences: NotificationPreferences) {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
            // Reschedule notifications with new preferences
            scheduleNotifications()
        }
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleNotifications() {
        // Cancel all existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard authorizationStatus == .authorized else { return }
        
        let preferences = getPreferences()
        
        // Daily writing reminders
        if preferences.dailyReminders {
            scheduleDailyReminder(quietHoursStart: preferences.quietHoursStart, quietHoursEnd: preferences.quietHoursEnd)
        }
        
        // Streak reminders (if streak is at risk)
        if preferences.streakReminders {
            scheduleStreakReminder(quietHoursStart: preferences.quietHoursStart, quietHoursEnd: preferences.quietHoursEnd)
        }
        
        // Weekly summary (every Sunday at 6 PM)
        if preferences.weeklySummary {
            scheduleWeeklySummary()
        }
    }
    
    private func scheduleDailyReminder(quietHoursStart: Int, quietHoursEnd: Int) {
        let _ = getPreferences()
        
        // Schedule for 2 PM (outside quiet hours)
        var dateComponents = DateComponents()
        dateComponents.hour = 14 // 2 PM
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Write!"
        content.body = "Don't forget to add to your journal today. Every word counts!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }
    
    private func scheduleStreakReminder(quietHoursStart: Int, quietHoursEnd: Int) {
        // Check if user has an active streak
        let _ = UserBehaviorTracker.shared.getEngagementMetrics()
        // This would need to check actual streak from AnalyticsManager
        // For now, schedule a generic reminder
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM (before quiet hours)
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Alive!"
        content.body = "Write something today to maintain your writing streak."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "streak_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling streak reminder: \(error)")
            }
        }
    }
    
    private func scheduleWeeklySummary() {
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 18 // 6 PM
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Summary"
        content.body = "Check out your writing stats for this week!"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "weekly_summary",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weekly summary: \(error)")
            }
        }
    }
    
    // MARK: - Achievement Notifications
    
    func scheduleAchievementNotification(_ achievement: Achievement) {
        guard authorizationStatus == .authorized else { return }
        
        let preferences = getPreferences()
        guard preferences.achievementNotifications else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🎉"
        content.body = "\(achievement.title): \(achievement.description)"
        content.sound = .default
        content.badge = 1
        
        // Show immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "achievement_\(achievement.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling achievement notification: \(error)")
            }
        }
    }
    
    // MARK: - App Open Tracking
    
    func recordAppOpen() {
        UserDefaults.standard.set(Date(), forKey: lastAppOpenKey)
        // Clear badge when app opens
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    func getLastAppOpen() -> Date? {
        return UserDefaults.standard.object(forKey: lastAppOpenKey) as? Date
    }
    
    func shouldSendReminder() -> Bool {
        guard let lastOpen = getLastAppOpen() else { return true }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastOpenDay = calendar.startOfDay(for: lastOpen)
        
        // Send reminder if user hasn't opened app today
        return !calendar.isDate(lastOpenDay, inSameDayAs: today)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        let identifier = response.notification.request.identifier
        
        if identifier.hasPrefix("achievement_") {
            // Post notification to show achievement view
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowAchievements"),
                object: nil
            )
        } else if identifier == "weekly_summary" {
            // Post notification to show analytics
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowAnalytics"),
                object: nil
            )
        }
        
        completionHandler()
    }
}

// MARK: - Notification Preferences Model

struct NotificationPreferences: Codable {
    var dailyReminders: Bool = true
    var streakReminders: Bool = true
    var achievementNotifications: Bool = true
    var weeklySummary: Bool = true
    var quietHoursStart: Int = 21 // 9 PM
    var quietHoursEnd: Int = 8 // 8 AM
}
