import Foundation

// MARK: - Subscription Analytics (Phase 5: Analytics & Tracking)

class SubscriptionAnalytics {
    static let shared = SubscriptionAnalytics()
    
    private let analyticsKey = "subscription_analytics"
    
    private init() {}
    
    // MARK: - Analytics Data Structure
    
    struct AnalyticsData: Codable {
        var subscriptionEvents: [SubscriptionEvent] = []
        var featureUsage: [String: Int] = [:]
        var conversionEvents: [ConversionEvent] = []
        var firstSubscriptionDate: Date?
        var lastSubscriptionDate: Date?
        var totalRevenue: Double = 0
        var churnEvents: [ChurnEvent] = []
    }
    
    struct SubscriptionEvent: Codable {
        let date: Date
        let eventType: EventType
        let tier: SubscriptionTier
        let productID: String?
        
        enum EventType: String, Codable {
            case subscribed
            case renewed
            case cancelled
            case upgraded
            case downgraded
            case trialStarted
            case trialConverted
        }
    }
    
    struct ConversionEvent: Codable {
        let date: Date
        let fromTier: SubscriptionTier
        let toTier: SubscriptionTier
        let trigger: String // e.g., "paywall", "usage_limit", "feature_attempt"
    }
    
    struct ChurnEvent: Codable {
        let date: Date
        let tier: SubscriptionTier
        let reason: String? // If available
    }
    
    // MARK: - Track Events
    
    func trackSubscription(eventType: SubscriptionEvent.EventType, tier: SubscriptionTier, productID: String? = nil) {
        var data = loadAnalytics()
        
        let event = SubscriptionEvent(
            date: Date(),
            eventType: eventType,
            tier: tier,
            productID: productID
        )
        
        data.subscriptionEvents.append(event)
        
        if eventType == .subscribed || eventType == .trialConverted {
            if data.firstSubscriptionDate == nil {
                data.firstSubscriptionDate = Date()
            }
            data.lastSubscriptionDate = Date()
        }
        
        saveAnalytics(data)
    }
    
    func trackFeatureUsage(_ feature: PremiumFeature) {
        var data = loadAnalytics()
        let key = feature.displayName
        data.featureUsage[key, default: 0] += 1
        saveAnalytics(data)
    }
    
    func trackConversion(fromTier: SubscriptionTier, toTier: SubscriptionTier, trigger: String) {
        var data = loadAnalytics()
        
        let event = ConversionEvent(
            date: Date(),
            fromTier: fromTier,
            toTier: toTier,
            trigger: trigger
        )
        
        data.conversionEvents.append(event)
        saveAnalytics(data)
    }
    
    func trackChurn(tier: SubscriptionTier, reason: String? = nil) {
        var data = loadAnalytics()
        
        let event = ChurnEvent(
            date: Date(),
            tier: tier,
            reason: reason
        )
        
        data.churnEvents.append(event)
        saveAnalytics(data)
    }
    
    // MARK: - Get Analytics
    
    func getConversionRate() -> Double {
        let data = loadAnalytics()
        let totalUsers = data.subscriptionEvents.filter { $0.eventType == .subscribed }.count
        let conversions = data.conversionEvents.count
        
        guard totalUsers > 0 else { return 0 }
        return Double(conversions) / Double(totalUsers) * 100
    }
    
    func getFeatureUsageStats() -> [(feature: String, count: Int)] {
        let data = loadAnalytics()
        return data.featureUsage.map { (feature: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    func getTierDistribution() -> [SubscriptionTier: Int] {
        let data = loadAnalytics()
        var distribution: [SubscriptionTier: Int] = [:]
        
        for event in data.subscriptionEvents {
            if event.eventType == .subscribed || event.eventType == .renewed {
                distribution[event.tier, default: 0] += 1
            }
        }
        
        return distribution
    }
    
    func getChurnRate() -> Double {
        let data = loadAnalytics()
        let totalSubscriptions = data.subscriptionEvents.filter { 
            $0.eventType == .subscribed || $0.eventType == .renewed 
        }.count
        let churns = data.churnEvents.count
        
        guard totalSubscriptions > 0 else { return 0 }
        return Double(churns) / Double(totalSubscriptions) * 100
    }
    
    // MARK: - Private Helpers
    
    private func loadAnalytics() -> AnalyticsData {
        guard let data = UserDefaults.standard.data(forKey: analyticsKey),
              let decoded = try? JSONDecoder().decode(AnalyticsData.self, from: data) else {
            return AnalyticsData()
        }
        return decoded
    }
    
    private func saveAnalytics(_ data: AnalyticsData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: analyticsKey)
        }
    }
}
