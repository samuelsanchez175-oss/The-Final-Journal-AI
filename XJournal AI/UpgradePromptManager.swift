import Foundation
import SwiftUI

// MARK: - Upgrade Prompt Manager (Phase 4: Contextual Upgrade Prompts)

class UpgradePromptManager {
    static let shared = UpgradePromptManager()
    
    private let promptDismissalKey = "upgrade_prompt_dismissals"
    private let featureUsageKey = "feature_usage_counts"
    private let lastPromptDateKey = "last_upgrade_prompt_date"
    
    private init() {}
    
    // MARK: - Prompt Triggers
    
    enum PromptTrigger {
        case usageLimitReached(feature: PremiumFeature)
        case featureAttempted(feature: PremiumFeature)
        case featureUsedMultipleTimes(feature: PremiumFeature, count: Int)
        case afterSuccessfulFeature(feature: PremiumFeature)
    }
    
    // MARK: - Check if Should Show Prompt
    
    func shouldShowPrompt(for trigger: PromptTrigger) -> Bool {
        // Don't show if user is already premium
        if SubscriptionManager.shared.isPremium() {
            return false
        }
        
        // Check if prompt was dismissed for this trigger
        if isPromptDismissed(for: trigger) {
            return false
        }
        
        // Rate limiting - don't show more than once per day
        if let lastPromptDate = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date {
            if Calendar.current.isDateInToday(lastPromptDate) {
                return false
            }
        }
        
        switch trigger {
        case .usageLimitReached:
            return true
        case .featureAttempted:
            return true
        case .featureUsedMultipleTimes(_, let count):
            return count >= 3 // Show after 3 uses
        case .afterSuccessfulFeature:
            return true
        }
    }
    
    // MARK: - Record Feature Usage
    
    func recordFeatureUsage(_ feature: PremiumFeature) {
        let key = "feature_\(feature.displayName)"
        let currentCount = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(currentCount + 1, forKey: key)
        
        // Check if we should show prompt
        let newCount = currentCount + 1
        if newCount >= 3 && shouldShowPrompt(for: .featureUsedMultipleTimes(feature: feature, count: newCount)) {
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowUpgradePrompt"),
                object: nil,
                userInfo: ["feature": feature.displayName, "trigger": "multiple_uses"]
            )
        }
    }
    
    // MARK: - Dismiss Prompt
    
    func dismissPrompt(for trigger: PromptTrigger, permanently: Bool = false) {
        let key = promptKey(for: trigger)
        
        if permanently {
            UserDefaults.standard.set(true, forKey: "\(key)_permanent")
        } else {
            // Mark as dismissed for today
            UserDefaults.standard.set(Date(), forKey: lastPromptDateKey)
        }
    }
    
    // MARK: - Private Helpers
    
    private func isPromptDismissed(for trigger: PromptTrigger) -> Bool {
        let key = promptKey(for: trigger)
        
        // Check permanent dismissal
        if UserDefaults.standard.bool(forKey: "\(key)_permanent") {
            return true
        }
        
        // Check today's dismissal
        if let lastPromptDate = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date {
            if Calendar.current.isDateInToday(lastPromptDate) {
                return true
            }
        }
        
        return false
    }
    
    private func promptKey(for trigger: PromptTrigger) -> String {
        switch trigger {
        case .usageLimitReached(let feature):
            return "prompt_limit_\(feature.displayName)"
        case .featureAttempted(let feature):
            return "prompt_attempted_\(feature.displayName)"
        case .featureUsedMultipleTimes(let feature, _):
            return "prompt_multiple_\(feature.displayName)"
        case .afterSuccessfulFeature(let feature):
            return "prompt_success_\(feature.displayName)"
        }
    }
}
