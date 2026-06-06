//
//  AIErrorBanner.swift
//  XJournal AI
//
//  Top-of-screen error banner that:
//  - Sits under the notch / Dynamic Island using safe-area-aware padding
//  - Swipe up to dismiss (with rubber-band feel)
//  - X button to dismiss
//  - Auto-dismisses after 6 seconds
//  Styled with Momentum tokens.
//

import SwiftUI

struct AIErrorBanner: View {
    let message: String
    var fixButtonTitle: String? = nil
    let onDismiss: () -> Void
    var onFix: (() -> Void)? = nil

    @State private var dragOffset: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme

    /// How far the user must drag up before triggering dismiss
    private let dismissThreshold: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.red.opacity(0.85))
                        .font(.system(size: 18, weight: .semibold))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("AI Error")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Momentum.contentPrimary)

                        Text(message)
                            .font(.system(size: 13))
                            .foregroundStyle(Momentum.contentSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }

                    Spacer(minLength: 8)

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Momentum.contentSecondary)
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Dismiss error")
                }

                if let fixButtonTitle, let onFix {
                    Button {
                        HapticFeedbackManager.shared.mediumTap()
                        onFix()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle.fill")
                            Text(fixButtonTitle)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color.accentColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens the screen where you can fix this issue")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                            .strokeBorder(Color.red.opacity(0.25), lineWidth: Momentum.lineThin)
                    )
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.10), radius: 12, y: 4)
            )
            .padding(.horizontal, 12)
            .padding(.top, 8)

            Capsule()
                .fill(Momentum.hairline)
                .frame(width: 36, height: 4)
                .padding(.top, 6)
        }
        .offset(y: rubberBand(dragOffset))
        .gesture(
            DragGesture(minimumDistance: 6)
                .onChanged { value in
                    // Only track upward drags
                    if value.translation.height < 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height < -dismissThreshold {
                        // Enough upward pull — dismiss
                        withAnimation(.easeOut(duration: 0.2)) { dragOffset = -200 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { onDismiss() }
                    } else {
                        // Snap back
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { dragOffset = 0 }
                    }
                }
        )
        .onAppear {
            // Auto-dismiss after 6 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                withAnimation(.easeOut(duration: 0.25)) { onDismiss() }
            }
        }
    }

    /// Light rubber-band resistance for overscroll
    private func rubberBand(_ offset: CGFloat) -> CGFloat {
        guard offset < 0 else { return 0 }
        // Past the threshold, resist with sqrt curve
        let absOffset = abs(offset)
        if absOffset < dismissThreshold {
            return offset
        } else {
            let extra = absOffset - dismissThreshold
            return -(dismissThreshold + extra * 0.4)
        }
    }
}

#Preview {
    VStack {
        AIErrorBanner(
            message: "API key missing. Add your OpenAI key in Settings.",
            fixButtonTitle: "Open API Settings",
            onDismiss: {},
            onFix: {}
        )
        AIErrorBanner(
            message: "Too many requests. Wait 60s and try again.",
            onDismiss: {}
        )
        Spacer()
    }
    .background(Color(.systemBackground))
}
