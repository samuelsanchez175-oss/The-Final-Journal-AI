import SwiftUI

// MARK: - Usage Widget View (Phase 3: Usage Widget Component)

struct UsageWidgetView: View {
    @State private var usage: UsageTracker.DailyUsage = UsageTracker.shared.getTodayUsage()
    @State private var timer: Timer?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if UsageTracker.shared.isPremium() {
                HStack {
                    Image(systemName: "infinity")
                        .foregroundStyle(.green)
                    Text("Unlimited")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.green)
                }
            } else {
                let remaining = UsageTracker.shared.getRemainingAISuggestions()
                let total = UsageTracker.shared.freeLimit
                let used = total - remaining
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("AI Usage")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(used)/\(total)")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(remaining == 0 ? .red : .primary)
                    }
                    
                    // Compact progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(remaining == 0 ? Color.red : (Double(used) / Double(total) >= 0.8 ? Color.orange : Color.green))
                                .frame(width: geometry.size.width * min(1.0, Double(used) / Double(total)), height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    if remaining == 0 {
                        Text("Upgrade for more")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    } else if remaining <= 2 {
                        Text("\(remaining) left")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Momentum.surfaceElevated)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
        .onAppear {
            updateUsage()
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                updateUsage()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func updateUsage() {
        usage = UsageTracker.shared.getTodayUsage()
    }
}
