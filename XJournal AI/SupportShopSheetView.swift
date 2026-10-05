//
//  SupportShopSheetView.swift
//  The Final Journal AI
//
//  Extracted from ContentView.swift
//

import SwiftUI

// MARK: - PAGE 1.1.2: Support / Shop Sheet (Segment 1)
// NOTE: GlassSettings is defined in ContentView.swift

struct SupportShopSheetView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    @State private var showThankYou: Bool = false
    @State private var lastActionTitle: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Support the Creators")
                        .font(.largeTitle.weight(.bold))

                    Text("Your support helps keep \(Momentum.appName) independent, thoughtful, and evolving.")
                        .font(.headline)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .padding(.top, 12)

                MomentumSectionHeader(title: "Donate")

                VStack(spacing: 10) {
                    supportRow(
                        title: "Cash App",
                        subtitle: "Send a donation to $samleumas",
                        symbol: "dollarsign.circle.fill"
                    ) {
                        openSupport(SupportLinks.cashApp, titled: "Cash App")
                    }
                }

                MomentumSectionHeader(title: "Follow")

                // Tight stack so the social buttons sit close together rather than
                // inheriting the loose 28pt section spacing.
                VStack(spacing: 10) {
                    supportRow(
                        title: "Instagram",
                        subtitle: "@samuelorsamuel",
                        symbol: "camera"
                    ) {
                        openSupport(SupportLinks.instagram, titled: "Instagram")
                    }

                    supportRow(
                        title: "X (Twitter)",
                        subtitle: "@samodayx",
                        symbol: "xmark"
                    ) {
                        openSupport(SupportLinks.twitter, titled: "X (Twitter)")
                    }
                }

                MomentumSectionHeader(title: "Feedback")

                Text("Spotted a bug or have an idea? We read every message.")
                    .font(.callout)
                    .foregroundStyle(Momentum.contentSecondary)

                Button {
                    sendFeedback()
                } label: {
                    Label("Send Feedback", systemImage: "envelope")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))

                if showThankYou {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Momentum.accent)

                        Text("Thank you for supporting \(Momentum.appName) via \(lastActionTitle).")
                            .font(.callout)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Momentum.surfaceElevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showThankYou = false
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(AtmosphereGlow())
        .animation(.easeInOut(duration: 0.2), value: showThankYou)
    }

    private enum SupportLinks {
        static let cashApp = URL(string: "https://cash.app/$samleumas")!
        static let instagram = URL(string: "https://www.instagram.com/samuelorsamuel")!
        static let twitter = URL(string: "https://x.com/samodayx")!
    }

    private func openSupport(_ url: URL, titled title: String) {
        lastActionTitle = title
        showThankYou = true
        openURL(url)
    }

    private func sendFeedback() {
        // TODO: Replace with the real feedback recipient address (e.g., "hello@thefinaljournalai.app")
        let recipient = "feedback@example.com"
        let subject = "\(Momentum.appName) — Feedback"
        let encoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        if let url = URL(string: "mailto:\(recipient)?subject=\(encoded)") {
            openURL(url)
        }
    }

    @ViewBuilder
    private func supportRow(
        title: String,
        subtitle: String,
        symbol: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Momentum.accent.opacity(0.12))

                    Image(systemName: symbol)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Momentum.accent)
                }
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(Momentum.contentSecondary)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Momentum.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
            )
        }
        .buttonStyle(.plain)
    }
}
