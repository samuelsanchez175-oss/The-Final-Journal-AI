import Foundation

// MARK: - Usage Tracker
// Tracks AI feature usage for freemium limits

class UsageTracker {
    static let shared = UsageTracker()
    
    private let usageKey = "ai_usage_tracking"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private init() {}
    
    // MARK: - Daily Limits (Freemium Model)
    
    struct DailyUsage {
        let date: String
        var aiSuggestionsUsed: Int
        var rewriteLineUsed: Int
        var improveFlowUsed: Int
        var suggestRhymesUsed: Int
        
        init(date: String, aiSuggestionsUsed: Int = 0, rewriteLineUsed: Int = 0, improveFlowUsed: Int = 0, suggestRhymesUsed: Int = 0) {
            self.date = date
            self.aiSuggestionsUsed = aiSuggestionsUsed
            self.rewriteLineUsed = rewriteLineUsed
            self.improveFlowUsed = improveFlowUsed
            self.suggestRhymesUsed = suggestRhymesUsed
        }
    }
    
    // Free tier limits
    private let freeTierLimits = (
        aiSuggestions: 10,
        rewriteLine: 5,
        improveFlow: 5,
        suggestRhymes: 20
    )
    
    // MARK: - Track Usage
    
    func trackAISuggestion() {
        incrementUsage(type: .aiSuggestion)
    }
    
    func trackRewriteLine() {
        incrementUsage(type: .rewriteLine)
    }
    
    func trackImproveFlow() {
        incrementUsage(type: .improveFlow)
    }
    
    func trackSuggestRhymes() {
        incrementUsage(type: .suggestRhymes)
    }
    
    private enum UsageType {
        case aiSuggestion
        case rewriteLine
        case improveFlow
        case suggestRhymes
    }
    
    private func incrementUsage(type: UsageType) {
        let today = dateFormatter.string(from: Date())
        var usage = loadUsage()
        
        // Reset if new day
        if usage.date != today {
            usage = DailyUsage(date: today)
        }
        
        switch type {
        case .aiSuggestion:
            usage.aiSuggestionsUsed += 1
        case .rewriteLine:
            usage.rewriteLineUsed += 1
        case .improveFlow:
            usage.improveFlowUsed += 1
        case .suggestRhymes:
            usage.suggestRhymesUsed += 1
        }
        
        saveUsage(usage)
    }
    
    // MARK: - Check Limits
    
    func canUseAISuggestion() -> Bool {
        if isPremiumUser() { return true }
        let usage = getTodayUsage()
        return usage.aiSuggestionsUsed < freeTierLimits.aiSuggestions
    }
    
    func canUseRewriteLine() -> Bool {
        if isPremiumUser() { return true }
        let usage = getTodayUsage()
        return usage.rewriteLineUsed < freeTierLimits.rewriteLine
    }
    
    func canUseImproveFlow() -> Bool {
        if isPremiumUser() { return true }
        let usage = getTodayUsage()
        return usage.improveFlowUsed < freeTierLimits.improveFlow
    }
    
    func canUseSuggestRhymes() -> Bool {
        if isPremiumUser() { return true }
        let usage = getTodayUsage()
        return usage.suggestRhymesUsed < freeTierLimits.suggestRhymes
    }
    
    // MARK: - Get Usage Info
    
    func getTodayUsage() -> DailyUsage {
        let today = dateFormatter.string(from: Date())
        let usage = loadUsage()
        
        if usage.date != today {
            return DailyUsage(date: today)
        }
        
        return usage
    }
    
    func getRemainingAISuggestions() -> Int {
        if isPremiumUser() { return Int.max }
        let usage = getTodayUsage()
        return max(0, freeTierLimits.aiSuggestions - usage.aiSuggestionsUsed)
    }
    
    func getRemainingRewriteLine() -> Int {
        if isPremiumUser() { return Int.max }
        let usage = getTodayUsage()
        return max(0, freeTierLimits.rewriteLine - usage.rewriteLineUsed)
    }
    
    func getRemainingImproveFlow() -> Int {
        if isPremiumUser() { return Int.max }
        let usage = getTodayUsage()
        return max(0, freeTierLimits.improveFlow - usage.improveFlowUsed)
    }
    
    func getRemainingSuggestRhymes() -> Int {
        if isPremiumUser() { return Int.max }
        let usage = getTodayUsage()
        return max(0, freeTierLimits.suggestRhymes - usage.suggestRhymesUsed)
    }
    
    // MARK: - Premium Status
    
    func isPremiumUser() -> Bool {
        // Check subscription status via SubscriptionManager (Phase 2)
        return SubscriptionManager.shared.isPremium()
    }
    
    func isPremium() -> Bool {
        return isPremiumUser()
    }
    
    func setPremiumStatus(_ isPremium: Bool) {
        // This is called by SubscriptionManager when subscription status changes
        // Keep UserDefaults for backward compatibility/testing
        UserDefaults.standard.set(isPremium, forKey: "is_premium_user")
    }
    
    // Expose free limit for UI
    var freeLimit: Int {
        return freeTierLimits.aiSuggestions
    }
    
    // Expose aiSuggestionCount for UI
    var aiSuggestionCount: Int {
        return getTodayUsage().aiSuggestionsUsed
    }
    
    // MARK: - Private Helpers
    
    private func loadUsage() -> DailyUsage {
        guard let data = UserDefaults.standard.data(forKey: usageKey),
              let decoded = try? JSONDecoder().decode(DailyUsage.self, from: data) else {
            return DailyUsage(date: dateFormatter.string(from: Date()))
        }
        return decoded
    }
    
    private func saveUsage(_ usage: DailyUsage) {
        if let encoded = try? JSONEncoder().encode(usage) {
            UserDefaults.standard.set(encoded, forKey: usageKey)
        }
    }
}

// MARK: - DailyUsage Codable Extension

extension UsageTracker.DailyUsage: Codable {}
