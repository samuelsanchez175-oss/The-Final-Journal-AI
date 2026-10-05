import SwiftUI

/// Session flag so "Punch on 3 and 4" only appears once per app launch.
enum BarClockPunchHint {
    static var shownThisLaunch = false
}

/// 1–4 tiles. Dark = default downbeat. Purple = punch. Tap to flip. The live beat scales up.
struct BarClockStrip: View {
    let activeBeat: Int
    var punchBeats: Set<Int> = [3, 4]
    var onTogglePunch: ((Int) -> Void)? = nil

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...4, id: \.self) { beat in
                BarClockTile(
                    beat: beat,
                    isActive: beat == activeBeat,
                    isPunch: punchBeats.contains(beat),
                    onTap: { onTogglePunch?(beat) }
                )
            }
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Bar clock, beat \(activeBeat) of 4")
    }
}

private struct BarClockTile: View {
    let beat: Int
    let isActive: Bool
    let isPunch: Bool
    let onTap: () -> Void

    var body: some View {
        Text("\(beat)")
            .font(.system(size: isActive ? 24 : 16, weight: .heavy, design: .rounded))
            .foregroundStyle(isActive ? Color.white : (isPunch ? Color.white.opacity(0.55) : Color.secondary))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isActive ? Color.white.opacity(0.7) : Color.clear, lineWidth: 2.5)
            )
            .scaleEffect(isActive ? 1.18 : 0.90)
            .shadow(
                color: isActive ? (isPunch ? Momentum.accent : Color.white).opacity(0.65) : .clear,
                radius: isActive ? 12 : 0
            )
            .zIndex(isActive ? 1 : 0)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .animation(.spring(response: 0.22, dampingFraction: 0.58), value: isActive)
            .animation(.easeInOut(duration: 0.18), value: isPunch)
            .accessibilityLabel(isPunch ? "Punch beat \(beat)" : "Beat \(beat)")
            .accessibilityHint(isPunch ? "Tap to make this a dark downbeat" : "Tap to highlight this as a punch beat")
            .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private var fill: Color {
        if isPunch {
            return isActive ? Momentum.accent : Momentum.accent.opacity(0.32)
        }
        return isActive ? Color(.systemGray) : Color(.systemGray5)
    }
}
