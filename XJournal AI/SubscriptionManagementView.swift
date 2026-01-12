import SwiftUI
import StoreKit

// MARK: - Subscription Management View (Phase 2: Subscription Management UI)

struct SubscriptionManagementView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    @State private var showCancelConfirmation = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Subscription Status
                    currentSubscriptionCard
                    
                    // Subscription Benefits
                    if subscriptionManager.subscriptionStatus == .subscribed {
                        benefitsCard
                    }
                    
                    // Manage Subscription
                    if subscriptionManager.subscriptionStatus == .subscribed {
                        managementActionsCard
                    } else {
                        upgradeCard
                    }
                    
                    // Transaction History
                    transactionHistoryCard
                    
                    // Restore Purchases
                    restorePurchasesCard
                }
                .padding()
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(
                    featureName: "Premium Features",
                    onDismiss: { showPaywall = false },
                    onSubscribe: {
                        Task {
                            await subscriptionManager.checkSubscriptionStatus()
                        }
                    }
                )
            }
            .alert("Cancel Subscription", isPresented: $showCancelConfirmation) {
                Button("Cancel Subscription", role: .destructive) {
                    openSubscriptionManagement()
                }
                Button("Keep Subscription", role: .cancel) {}
            } message: {
                Text("You can manage or cancel your subscription in the App Store settings. Your subscription will remain active until the end of the current billing period.")
            }
            .task {
                await subscriptionManager.checkSubscriptionStatus()
            }
        }
    }
    
    // MARK: - Current Subscription Card
    
    private var currentSubscriptionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Subscription")
                .font(.headline)
            
            if subscriptionManager.subscriptionStatus == .subscribed {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(tierColor(for: subscriptionManager.currentTier))
                            Text(subscriptionManager.currentTier.displayName)
                                .font(.title2.weight(.bold))
                        }
                        
                        Text("Active")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                        
                        if let expirationDate = getExpirationDate() {
                            Text("Renews: \(formatDate(expirationDate))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Free Tier")
                        .font(.title2.weight(.bold))
                    Text("Limited features")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
    }
    
    // MARK: - Benefits Card
    
    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Benefits")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(subscriptionManager.currentTier.features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(feature)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
    }
    
    // MARK: - Management Actions Card
    
    private var managementActionsCard: some View {
        VStack(spacing: 12) {
            Button {
                openSubscriptionManagement()
            } label: {
                HStack {
                    Label("Manage Subscription", systemImage: "gearshape.fill")
                        .font(.body)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                }
                .foregroundStyle(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
            .buttonStyle(.plain)
            
            Button {
                showCancelConfirmation = true
            } label: {
                HStack {
                    Label("Cancel Subscription", systemImage: "xmark.circle")
                        .font(.body)
                    Spacer()
                }
                .foregroundStyle(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
            .buttonStyle(.plain)
            
            // Upgrade/Downgrade options
            if subscriptionManager.currentTier != .team {
                Divider()
                
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Label("Upgrade Plan", systemImage: "arrow.up.circle.fill")
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
    }
    
    // MARK: - Upgrade Card
    
    private var upgradeCard: some View {
        VStack(spacing: 12) {
            Text("Upgrade to Premium")
                .font(.headline)
            
            Text("Unlock unlimited AI features and advanced tools")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showPaywall = true
            } label: {
                Text("View Plans")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.accentColor)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
    }
    
    // MARK: - Transaction History Card
    
    private var transactionHistoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transaction History")
                .font(.headline)
            
            Text("View your purchase history in the App Store")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                openSubscriptionManagement()
            } label: {
                HStack {
                    Text("View in App Store")
                        .font(.body)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                }
                .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
    }
    
    // MARK: - Restore Purchases Card
    
    private var restorePurchasesCard: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            } label: {
                HStack {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                        .font(.body)
                    Spacer()
                }
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
            .buttonStyle(.plain)
            .disabled(subscriptionManager.isLoading)
            
            if subscriptionManager.isLoading {
                ProgressView()
                    .padding()
            }
            
            if let error = subscriptionManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
    }
    
    // MARK: - Helper Methods
    
    private func tierColor(for tier: SubscriptionTier) -> Color {
        switch tier {
        case .basic: return .blue
        case .pro: return .purple
        case .team: return .orange
        default: return .green
        }
    }
    
    private func getExpirationDate() -> Date? {
        // In a real implementation, this would come from the transaction
        // For now, return nil - would need to store expiration date from transactions
        return nil
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func openSubscriptionManagement() {
        // Open App Store subscription management
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}
