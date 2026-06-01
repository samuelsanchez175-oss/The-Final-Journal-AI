import Foundation
import StoreKit
import Combine

// MARK: - Subscription Manager (Phase 2: Monetization Foundation)
// Handles StoreKit 2 subscription management

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var subscriptionStatus: SubscriptionStatus = .unknown
    @Published var availableProducts: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var expirationDate: Date?
    @Published var renewalDate: Date?
    @Published var isInTrialPeriod: Bool = false
    @Published var trialEndDate: Date?
    
    // Product IDs - Update these with your actual App Store Connect product IDs
    private let productIDs = [
        "com.finaljournal.basic.monthly",
        "com.finaljournal.basic.yearly",
        "com.finaljournal.pro.monthly",
        "com.finaljournal.pro.yearly",
        "com.finaljournal.team.monthly",
        "com.finaljournal.team.yearly"
    ]
    
    @Published var currentTier: SubscriptionTier = .none
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Load products and check subscription status
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
        
        // Periodic subscription status refresh (Phase 7: Status Sync)
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3600 * 1_000_000_000) // Every hour
                await checkSubscriptionStatus()
            }
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        var retryCount = 0
        let maxRetries = 3
        
        while retryCount < maxRetries {
            do {
                let products = try await Product.products(for: productIDs)
                availableProducts = products.sorted { $0.price < $1.price }
                errorMessage = nil
                return
            } catch {
                retryCount += 1
                
                if retryCount >= maxRetries {
                    // Final attempt failed
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet, .networkConnectionLost:
                            errorMessage = "No internet connection. Please check your network and try again."
                        case .timedOut:
                            errorMessage = "Request timed out. Please try again."
                        default:
                            errorMessage = "Failed to load products: \(error.localizedDescription)"
                        }
                    } else {
                        errorMessage = "Failed to load products: \(error.localizedDescription)"
                    }
                    print("❌ Failed to load products after \(retryCount) attempts: \(error)")
                } else {
                    // Wait before retry (exponential backoff)
                    try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                }
            }
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Update subscription status
            await transaction.finish()
            await checkSubscriptionStatus()
            
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            errorMessage = "Purchase is pending approval"
            return false
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - Subscription Status
    
    func checkSubscriptionStatus() async {
        var status: SubscriptionStatus = .notSubscribed
        var detectedTier: SubscriptionTier = .none
        
        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if subscription is still active
                if transaction.revocationDate == nil && transaction.expirationDate ?? Date.distantFuture > Date() {
                    status = .subscribed
                    
                    // Determine tier from product ID
                    let productID = transaction.productID
                    if productID.contains("team") {
                        detectedTier = .team
                    } else if productID.contains("pro") {
                        detectedTier = .pro
                    } else if productID.contains("basic") {
                        detectedTier = .basic
                    }
                    
                    // Store expiration and renewal dates (Phase 2: Enhanced Status Display)
                    let expiration = transaction.expirationDate
                    expirationDate = expiration
                    renewalDate = expiration
                    
                    // Check for trial period (Phase 6: Trial Support)
                    let purchaseDate = transaction.purchaseDate
                    // If purchase was recent (within 7 days) and expiration is soon, likely a trial
                    let daysSincePurchase = Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 0
                    if let expiration = expiration {
                        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expiration).day ?? 0
                        
                        if daysSincePurchase <= 7 && daysUntilExpiration <= 7 {
                            isInTrialPeriod = true
                            trialEndDate = expiration
                            
                            // Track trial start if this is the first time
                            if !UserDefaults.standard.bool(forKey: "trial_started_\(productID)") {
                                UserDefaults.standard.set(true, forKey: "trial_started_\(productID)")
                                SubscriptionAnalytics.shared.trackSubscription(
                                    eventType: .trialStarted,
                                    tier: detectedTier,
                                    productID: productID
                                )
                            }
                        }
                        
                        // Check if trial converted to paid (Phase 6: Trial Support)
                        // If purchase was more than 7 days ago and still active, trial likely converted
                        if daysSincePurchase > 7 && !isInTrialPeriod {
                            if UserDefaults.standard.bool(forKey: "trial_started_\(productID)") &&
                               !UserDefaults.standard.bool(forKey: "trial_converted_\(productID)") {
                                UserDefaults.standard.set(true, forKey: "trial_converted_\(productID)")
                                SubscriptionAnalytics.shared.trackSubscription(
                                    eventType: .trialConverted,
                                    tier: detectedTier,
                                    productID: productID
                                )
                            }
                        }
                    }
                    
                    // Update UsageTracker
                    UsageTracker.shared.setPremiumStatus(true)
                    
                    // Store tier in UserDefaults for quick access
                    UserDefaults.standard.set(detectedTier.rawValue, forKey: "subscription_tier")
                    
                    // Don't break - check all transactions to find highest tier
                    if detectedTier > currentTier {
                        // Track upgrade if moving to higher tier
                        if currentTier != .none {
                            SubscriptionAnalytics.shared.trackSubscription(
                                eventType: .upgraded,
                                tier: detectedTier,
                                productID: productID
                            )
                        }
                        currentTier = detectedTier
                    }
                } else if transaction.revocationDate != nil {
                    // Subscription was cancelled
                    SubscriptionAnalytics.shared.trackChurn(
                        tier: detectedTier,
                        reason: "Cancelled"
                    )
                }
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
        
        // If no active subscription found, check if user is premium via UsageTracker
        // (for testing purposes - remove in production)
        if status == .notSubscribed {
            if UsageTracker.shared.isPremium() {
                status = .subscribed
                // Try to determine tier from UserDefaults (for testing)
                if let tierString = UserDefaults.standard.string(forKey: "subscription_tier"),
                   let tier = SubscriptionTier(rawValue: tierString) {
                    currentTier = tier
                } else {
                    currentTier = .basic // Default to basic for testing
                }
            } else {
                UsageTracker.shared.setPremiumStatus(false)
                currentTier = .none
                expirationDate = nil
                renewalDate = nil
                isInTrialPeriod = false
                trialEndDate = nil
            }
        }
        
        subscriptionStatus = status
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
            
            if subscriptionStatus == .subscribed {
                errorMessage = nil
            } else {
                errorMessage = "No active subscriptions found. If you recently purchased, it may take a few moments to appear."
            }
        } catch {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    errorMessage = "No internet connection. Please check your network and try again."
                case .timedOut:
                    errorMessage = "Restore request timed out. Please try again."
                default:
                    errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
                }
            } else {
                errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            }
            print("❌ Restore purchases error: \(error)")
        }
    }
    
    // MARK: - Transaction Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await MainActor.run {
                        try self.checkVerified(result)
                    }
                    await transaction.finish()
                    await self.checkSubscriptionStatus()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func isPremium() -> Bool {
        return subscriptionStatus == .subscribed
    }
    
    func getProducts(for tier: SubscriptionTier) -> [Product] {
        let tierString = tier.rawValue
        return availableProducts.filter { $0.id.contains(tierString) }
    }
    
    func getMonthlyProduct(for tier: SubscriptionTier) -> Product? {
        return availableProducts.first { $0.id.contains(tier.rawValue) && $0.id.contains("monthly") }
    }
    
    func getYearlyProduct(for tier: SubscriptionTier) -> Product? {
        return availableProducts.first { $0.id.contains(tier.rawValue) && $0.id.contains("yearly") }
    }
    
    func hasTier(_ tier: SubscriptionTier) -> Bool {
        return currentTier >= tier
    }
}

// MARK: - Subscription Status Enum

enum SubscriptionStatus {
    case unknown
    case subscribed
    case notSubscribed
    case expired
}

// MARK: - Subscription Tier Enum

enum SubscriptionTier: String, CaseIterable, Comparable, Codable {
    case none = "none"
    case basic = "basic"
    case pro = "pro"
    case team = "team"
    
    var displayName: String {
        switch self {
        case .none: return "Free"
        case .basic: return "Basic"
        case .pro: return "Pro"
        case .team: return "Team"
        }
    }
    
    var features: [String] {
        switch self {
        case .none:
            return [
                "Limited AI suggestions (10/day)",
                "Basic rhyme detection",
                "Note organization"
            ]
        case .basic:
            return [
                "Unlimited AI suggestions",
                "Cloud sync",
                "Export to PDF/Word",
                "Priority support",
                "All free features"
            ]
        case .pro:
            return [
                "Everything in Basic",
                "Custom AI model training",
                "Advanced analytics",
                "Style transfer",
                "Theme expansion",
                "Advanced rhyme diagnostics"
            ]
        case .team:
            return [
                "Everything in Pro",
                "Collaboration features",
                "Team workspace",
                "Shared folders",
                "Team analytics",
                "Admin controls"
            ]
        }
    }
    
    static func < (lhs: SubscriptionTier, rhs: SubscriptionTier) -> Bool {
        let order: [SubscriptionTier] = [.none, .basic, .pro, .team]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Subscription Error

enum SubscriptionError: Error {
    case unverifiedTransaction
    case purchaseFailed
    case productNotFound
}
