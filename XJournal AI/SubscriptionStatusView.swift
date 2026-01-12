import SwiftUI
import StoreKit

// MARK: - Subscription Status View (Phase 3: Enhanced StoreKit Integration)

struct SubscriptionStatusView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    @State private var paywallFeature = "Premium Features"
    
    var body: some View {
        Group {
            if subscriptionManager.subscriptionStatus == .subscribed {
                let currentTier = subscriptionManager.currentTier
                Button {
                    // Navigate to subscription management
                    NotificationCenter.default.post(name: NSNotification.Name("ShowSubscriptionManagement"), object: nil)
                } label: {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(tierColor(for: currentTier))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(currentTier.displayName) Active")
                                .font(.subheadline.weight(.medium))
                            Text(tierDescription(for: currentTier))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            if let expirationDate = getExpirationDate() {
                                Text("Renews: \(formatDate(expirationDate))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
                .buttonStyle(.plain)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Free Tier")
                        .font(.subheadline.weight(.medium))
                    
                    let usage = UsageTracker.shared.getTodayUsage()
                    UsageInfoRow(label: "AI Suggestions", used: usage.aiSuggestionsUsed, limit: UsageTracker.shared.freeLimit)
                    UsageInfoRow(label: "Rewrite Line", used: usage.rewriteLineUsed, limit: 5)
                    UsageInfoRow(label: "Improve Flow", used: usage.improveFlowUsed, limit: 5)
                    
                    Button {
                        paywallFeature = "Premium Features"
                        showPaywall = true
                    } label: {
                        HStack {
                            Label("Upgrade to Premium", systemImage: "sparkles")
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                featureName: paywallFeature,
                onDismiss: { showPaywall = false },
                onSubscribe: {
                    Task {
                        await subscriptionManager.checkSubscriptionStatus()
                    }
                }
            )
        }
        .task {
            await subscriptionManager.checkSubscriptionStatus()
        }
    }
    
    private func tierColor(for tier: SubscriptionTier) -> Color {
        switch tier {
        case .basic: return .blue
        case .pro: return .purple
        case .team: return .orange
        default: return .green
        }
    }
    
    private func tierDescription(for tier: SubscriptionTier) -> String {
        switch tier {
        case .basic:
            return "Unlimited AI features"
        case .pro:
            return "Advanced AI + Analytics"
        case .team:
            return "Team collaboration features"
        default:
            return "Unlimited AI features"
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
}
