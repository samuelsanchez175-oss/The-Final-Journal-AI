//
//  ReleaseNotesSheetView.swift
//  The Final Journal AI
//
//  Extracted from ContentView.swift
//

import SwiftUI

// MARK: - PAGE 1.1.1: Release Notes Sheet (Segment 1)
// NOTE: GlassSettings is defined in ContentView.swift

struct ReleaseNotesSheetView: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's New")
                        .font(.largeTitle.weight(.bold))

                    Text("The Final Journal AI")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 12)

                featureCard(
                    symbolName: "sparkles.rectangle.stack",
                    version: "1.3.0",
                    title: "Onboarding & Enhanced AI Tools",
                    description: "Welcome new users with guided tours and powerful new writing assistance features.",
                    bullets: [
                        "Interactive onboarding: Hero screen and toolbar tutorials",
                        "Rewrite Line: AI suggests single-line replacements matching rhyme and syllables",
                        "Suggest Rhymes: Find 8 rhyming words for your last word",
                        "Improve Flow: Focus on maintaining rhyme scheme patterns",
                        "Model Preferences: Customize Model G and Model Y behaviors",
                        "Undo/Redo: Easily revert or restore your changes",
                        "Audio Import: Import audio files with automatic transcription"
                    ]
                )

                featureCard(
                    symbolName: "tray.and.arrow.down",
                    version: "1.2.0",
                    title: "Metadata & Import Update",
                    description: "Enhanced note organization and seamless import workflows.",
                    bullets: [
                        "Metadata system: BPM, Key, Scale, URL, and Folder tags",
                        "Import from Notes with guided workflow",
                        "Welcome Back screen for imported content",
                        "Metadata-based filtering (Folders, BPM, Scale, URL)",
                        "iOS 26 style glassmorphic containers"
                    ]
                )

                featureCard(
                    symbolName: "sparkles.rectangle.stack",
                    version: "1.1.0",
                    title: "Writing Intelligence Update",
                    description: "Smarter rhyme awareness and clearer creative feedback.",
                    bullets: [
                        "Group‑based rhyme coloring",
                        "Magnifying‑glass rhyme map with suggestions",
                        "Slant rhyme detection",
                        "Keyboard‑aware adaptive glass bars",
                        "Improved dark‑mode contrast"
                    ]
                )

                featureCard(
                    symbolName: "gauge.high",
                    version: "1.1.1",
                    title: "Performance Enhancements",
                    description: "Faster, smoother rhyme analysis and rendering.",
                    bullets: [
                        "Incremental rhyme analysis for stability",
                        "Attributed string caching to prevent rebuilds",
                        "Optimized eye toggle performance",
                        "Reduced CPU usage during text editing"
                    ]
                )

                featureCard(
                    symbolName: "checkmark.seal",
                    version: "1.0.5",
                    title: "Stability & Polish",
                    description: "Smoother interactions and visual refinement.",
                    bullets: [
                        "Navigation stability improvements",
                        "Cleaner editor alignment",
                        "Performance optimizations"
                    ]
                )
            }
            .padding(24)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .ignoresSafeArea()
        )
    }

    @ViewBuilder
    private func featureCard(
        symbolName: String,
        version: String,
        title: String,
        description: String,
        bullets: [String]
    ) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .overlay(
                        LinearGradient(
                            colors: [
                                .white.opacity((GlassSettings.gloss - 0.6) / 3),
                                .white.opacity((GlassSettings.gloss - 0.6) / 4),
                                .white.opacity((GlassSettings.gloss - 0.6) / 3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .blendMode(.overlay)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    )

                Image(systemName: symbolName)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(width: 120, height: 120)

            VStack(alignment: .leading, spacing: 8) {
                Text("Version \(version)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(title)
                    .font(.title3.weight(.semibold))

                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(bullets, id: \.self) { bullet in
                        Text("• \(bullet)")
                            .font(.callout)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .white.opacity((GlassSettings.gloss - 0.6) / 4),
                            .white.opacity((GlassSettings.gloss - 0.6) / 3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                )
        )
    }
}
