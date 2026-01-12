import SwiftUI
import StoreKit

// MARK: - Product Extension

extension Product {
    var subscriptionTier: SubscriptionTier {
        if id.contains("team") {
            return .team
        } else if id.contains("pro") {
            return .pro
        } else if id.contains("basic") {
            return .basic
        }
        return .none
    }
    
    var billingPeriod: String {
        if id.contains("yearly") {
            return "year"
        } else {
            return "month"
        }
    }
    
    var friendlyDisplayName: String {
        let tier = subscriptionTier.displayName
        let period = billingPeriod == "year" ? "Yearly" : "Monthly"
        return "\(period) \(tier)"
    }
    
    var formattedPrice: String {
        return displayPrice
    }
}

// MARK: - Paywall View (Phase 2: Monetization Foundation)

struct PaywallView: View {
    let featureName: String
    let onDismiss: () -> Void
    let onSubscribe: (() -> Void)? // Optional callback for external handling
    
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProduct: Product?
    @State private var isPurchasing: Bool = false
    @State private var purchaseError: String?
    
    init(featureName: String, onDismiss: @escaping () -> Void, onSubscribe: (() -> Void)? = nil) {
        self.featureName = featureName
        self.onDismiss = onDismiss
        self.onSubscribe = onSubscribe
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)
                        
                        Text("Unlock \(featureName)")
                            .font(.title.weight(.bold))
                        
                        Text("Upgrade to Premium for unlimited access")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Usage Info
                    UsageInfoView()
                    
                    // Subscription Products
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .padding()
                    } else if subscriptionManager.availableProducts.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundStyle(.orange)
                            Text("Products unavailable")
                                .font(.headline)
                            Text("Please check your internet connection")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else {
                        // Group products by tier
                        VStack(spacing: 24) {
                            ForEach(SubscriptionTier.allCases.filter { $0 != .none }, id: \.self) { tier in
                                let tierProducts = subscriptionManager.getProducts(for: tier)
                                if !tierProducts.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(tier.displayName)
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                        VStack(spacing: 12) {
                                            ForEach(tierProducts, id: \.id) { product in
                                                TierProductCard(
                                                    product: product,
                                                    tier: tier,
                                                    isSelected: selectedProduct?.id == product.id,
                                                    onSelect: { selectedProduct = product }
                                                )
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        
                        // Subscribe Button
                        Button {
                            guard let product = selectedProduct ?? subscriptionManager.availableProducts.first else { return }
                            Task {
                                await purchaseProduct(product)
                            }
                        } label: {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(isPurchasing ? "Processing..." : "Subscribe")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(isPurchasing ? Color.gray : Color.accentColor)
                            )
                        }
                        .disabled(isPurchasing || selectedProduct == nil)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        
                        if let error = purchaseError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }
                        
                        // Restore Purchases
                        Button {
                            Task {
                                await subscriptionManager.restorePurchases()
                                if subscriptionManager.subscriptionStatus == .subscribed {
                                    onDismiss()
                                }
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
            .onAppear {
                // Select first product by default
                if selectedProduct == nil, let firstProduct = subscriptionManager.availableProducts.first {
                    selectedProduct = firstProduct
                }
            }
        }
    }
    
    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        purchaseError = nil
        
        do {
            let success = try await subscriptionManager.purchase(product)
            if success {
                // Update UsageTracker
                UsageTracker.shared.setPremiumStatus(true)
                
                // Store tier for quick access
                let tier = product.subscriptionTier
                UserDefaults.standard.set(tier.rawValue, forKey: "subscription_tier")
                
                // Refresh subscription status
                await subscriptionManager.checkSubscriptionStatus()
                
                // Call external callback if provided
                onSubscribe?()
                onDismiss()
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        
        isPurchasing = false
    }
}

// MARK: - Usage Info View (Phase 3: Enhanced Usage Visualization)

struct UsageInfoView: View {
    @State private var timeUntilReset: String = ""
    @State private var timer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Usage")
                    .font(.headline)
                
                Spacer()
                
                if !UsageTracker.shared.isPremium() {
                    Text("Resets in \(timeUntilReset)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                let usage = UsageTracker.shared.getTodayUsage()
                
                EnhancedUsageRow(
                    label: "AI Suggestions",
                    used: usage.aiSuggestionsUsed,
                    limit: UsageTracker.shared.isPremium() ? nil : UsageTracker.shared.freeLimit
                )
                
                EnhancedUsageRow(
                    label: "Rewrite Line",
                    used: usage.rewriteLineUsed,
                    limit: UsageTracker.shared.isPremium() ? nil : 5
                )
                
                EnhancedUsageRow(
                    label: "Improve Flow",
                    used: usage.improveFlowUsed,
                    limit: UsageTracker.shared.isPremium() ? nil : 5
                )
            }
            .padding(.horizontal)
        }
        .onAppear {
            updateResetTimer()
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                updateResetTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func updateResetTimer() {
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        let components = calendar.dateComponents([.hour, .minute], from: now, to: tomorrow)
        
        if let hours = components.hour, let minutes = components.minute {
            timeUntilReset = String(format: "%dh %dm", hours, minutes)
        }
    }
}

struct EnhancedUsageRow: View {
    let label: String
    let used: Int
    let limit: Int?
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var usagePercentage: Double {
        guard let limit = limit, limit > 0 else { return 0 }
        return min(1.0, Double(used) / Double(limit))
    }
    
    private var progressColor: Color {
        if usagePercentage >= 1.0 {
            return .red
        } else if usagePercentage >= 0.8 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                
                Spacer()
                
                if let limit = limit {
                    Text("\(used)/\(limit)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(used >= limit ? .red : .primary)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "infinity")
                            .font(.caption)
                        Text("Unlimited")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(.green)
                }
            }
            
            if let limit = limit {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [progressColor, progressColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * usagePercentage, height: 6)
                            .animation(.spring(response: 0.3), value: usagePercentage)
                    }
                }
                .frame(height: 6)
                
                // Warning text when near limit
                if used >= limit {
                    Text("Limit reached - Upgrade for unlimited access")
                        .font(.caption2)
                        .foregroundStyle(.red)
                } else if usagePercentage >= 0.8 {
                    Text("\(limit - used) remaining")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
    }
}

// Keep old UsageRow for backward compatibility
struct UsageRow: View {
    let label: String
    let used: Int
    let limit: Int?
    
    var body: some View {
        EnhancedUsageRow(label: label, used: used, limit: limit)
    }
}

// MARK: - Tier Product Card

struct TierProductCard: View {
    let product: Product
    let tier: SubscriptionTier
    let isSelected: Bool
    let onSelect: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var tierColor: Color {
        switch tier {
        case .basic: return .blue
        case .pro: return .purple
        case .team: return .orange
        default: return .blue
        }
    }
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.friendlyDisplayName)
                            .font(.title3.weight(.bold))
                        
                        Text(product.formattedPrice)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(tierColor)
                    }
                }
                
                // Show tier features
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(tier.features.prefix(3)), id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundStyle(tierColor)
                            Text(feature)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                isSelected ? tierColor : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
