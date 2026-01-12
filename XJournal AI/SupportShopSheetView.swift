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

                    Text("Your support helps keep The Final Journal AI independent, thoughtful, and evolving.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 12)

                sectionHeader("Follow & Support")

                // TODO: Replace placeholder URLs with actual social media account URLs
                supportRow(
                    title: "X (Twitter)",
                    subtitle: "Follow updates and design progress",
                    symbol: "xmark"
                ) {
                    // TODO: Replace with actual Twitter/X account URL (e.g., "https://twitter.com/yourhandle")
                    if let url = URL(string: "https://twitter.com") {
                    lastActionTitle = "X (Twitter)"
                    showThankYou = true
                        openURL(url)
                    }
                }

                supportRow(
                    title: "Instagram",
                    subtitle: "Visual updates and behind-the-scenes",
                    symbol: "camera"
                ) {
                    // TODO: Replace with actual Instagram account URL (e.g., "https://instagram.com/yourhandle")
                    if let url = URL(string: "https://instagram.com") {
                    lastActionTitle = "Instagram"
                    showThankYou = true
                        openURL(url)
                    }
                }

                supportRow(
                    title: "Patreon",
                    subtitle: "Directly support ongoing development",
                    symbol: "heart.fill"
                ) {
                    // TODO: Replace with actual Patreon creator page URL (e.g., "https://patreon.com/yourpage")
                    if let url = URL(string: "https://patreon.com") {
                    lastActionTitle = "Patreon"
                    showThankYou = true
                        openURL(url)
                    }
                }

                supportRow(
                    title: "Facebook",
                    subtitle: "Community updates and announcements",
                    symbol: "person.2.fill"
                ) {
                    // TODO: Replace with actual Facebook page URL (e.g., "https://facebook.com/yourpage")
                    if let url = URL(string: "https://facebook.com") {
                    lastActionTitle = "Facebook"
                    showThankYou = true
                        openURL(url)
                    }
                }

                sectionHeader("Affiliate Support")

                Text(
                    "Some links may be affiliate links. Purchases made through these links help support development at no extra cost to you."
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                supportRow(
                    title: "Amazon",
                    subtitle: "Support via affiliate purchases",
                    symbol: "cart.fill"
                ) {
                    // TODO: Replace with actual Amazon affiliate link
                    if let url = URL(string: "https://amazon.com") {
                    lastActionTitle = "Amazon"
                    showThankYou = true
                        openURL(url)
                    }
                }

                if showThankYou {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)

                        Text("Thank you for supporting The Final Journal AI via \(lastActionTitle).")
                            .font(.callout)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
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
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .ignoresSafeArea()
        )
        .animation(.easeInOut(duration: 0.2), value: showThankYou)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .padding(.top, 12)
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
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))

                    Image(systemName: symbol)
                        .font(.system(size: 28, weight: .semibold))
                }
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
            )
        }
        .buttonStyle(.plain)
    }
}
