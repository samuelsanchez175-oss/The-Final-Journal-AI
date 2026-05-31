import SwiftUI

// MARK: - Upgrade Prompt View (Phase 4: Upgrade Prompt UI)

struct UpgradePromptView: View {
    let featureName: String
    let trigger: String
    let onUpgrade: () -> Void
    let onDismiss: () -> Void
    let onNeverShow: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(.blue)
            
            // Title
            Text("Unlock \(featureName)")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            // Message based on trigger
            Text(promptMessage)
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Actions
            VStack(spacing: 12) {
                Button {
                    onUpgrade()
                } label: {
                    Text("Upgrade Now")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)
                
                HStack(spacing: 16) {
                    Button {
                        onDismiss()
                    } label: {
                        Text("Not Now")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        onNeverShow()
                    } label: {
                        Text("Don't Show Again")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private var promptMessage: String {
        switch trigger {
        case "limit_reached":
            return "You've reached your daily limit for \(featureName). Upgrade to unlock unlimited access!"
        case "feature_attempted":
            return "\(featureName) is a premium feature. Upgrade to access this and more!"
        case "multiple_uses":
            return "You're using \(featureName) a lot! Upgrade for unlimited access."
        case "after_success":
            return "Loved \(featureName)? Upgrade to use it unlimited times!"
        default:
            return "Upgrade to unlock \(featureName) and all premium features!"
        }
    }
}

// MARK: - Banner Prompt View

struct BannerUpgradePromptView: View {
    let featureName: String
    let onUpgrade: () -> Void
    let onDismiss: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Upgrade for unlimited \(featureName)")
                    .font(.subheadline.weight(.medium))
                Text("Tap to view plans")
                    .font(.caption2)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            
            Spacer()
            
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
        .onTapGesture {
            onUpgrade()
        }
    }
}
