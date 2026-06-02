//
//  ReleaseNotesSheetView.swift
//  The Final Journal AI
//
//  Extracted from ContentView.swift
//  Momentum reskin (2026-05-31): flat hairline cards on the signature coral
//  AtmosphereGlow, coral accents throughout. Retired the old glassmorphic gloss.
//

import SwiftUI

// MARK: - PAGE 1.1.1: Release Notes Sheet (Segment 1)

struct ReleaseNotesSheetView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's New")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Momentum.contentPrimary)

                    Text("The Final Journal AI")
                        .font(.headline)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .padding(.top, 12)
                .padding(.bottom, 4)

                featureCard(
                    symbolName: "paintpalette",
                    version: "1.5.0",
                    title: "Momentum Redesign & Dark Mode",
                    description: "A bold new coral redesign, full dark mode, and a rebuilt AI suggestions experience.",
                    isLatest: true,
                    bullets: [
                        "Brand-new \"Momentum\" look — a warm coral redesign with iOS 26 glass, flat hairline cards, and a cleaner editor header",
                        "Full Dark Mode with the new \"Lagoon\" palette — your accent color doubles as a one-tap light/dark switch",
                        "Rebuilt Rap Suggestions — swipe a deck of generations with a floating island toolbar for rhyme, stress, and the rhyme map",
                        "Stress emphasis: a \"Stack\" view that highlights the hardest-hitting syllables in every line",
                        "Cascade layout steps long bars into breath-sized phrases for easier reading at large text sizes",
                        "Human Critic — plain-language feedback on your lyrics in a Calm editor, Friend, or Hype voice",
                        "Theme-aware suggestions — the app reads your song's themes and steers Model G to match",
                        "Model G v3: a more capable generation engine with a simpler AI setup",
                        "Smoother first-run onboarding, plus clearer AI error handling and recovery"
                    ]
                )

                featureCard(
                    symbolName: "waveform.path",
                    version: "1.4.0",
                    title: "Audio Intelligence & Analytics",
                    description: "Advanced audio transcription, interactive playback, and comprehensive analytics dashboard.",
                    bullets: [
                        "High-fidelity on-device audio transcription with timestamped segments",
                        "Interactive audio detail sheet with synchronized text highlighting",
                        "Audio waveform visualization and playback controls",
                        "Comprehensive analytics dashboard with multiple tabs",
                        "Error tracking and storage with detailed analytics",
                        "Social feed integration for tips and guides",
                        "Improved AI suggestion reliability with robust JSON parsing",
                        "Real-time title editing with instant library updates"
                    ]
                )

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
                        "Model Preferences: Customize Model G, Model G Core, and Model Y behaviors",
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
        .background(AtmosphereGlow())
    }

    @ViewBuilder
    private func featureCard(
        symbolName: String,
        version: String,
        title: String,
        description: String,
        isLatest: Bool = false,
        bullets: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Momentum.accent.opacity(0.14))
                    Image(systemName: symbolName)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(Momentum.accent)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("VERSION \(version)")
                            .font(.momentumSection)
                            .tracking(1.2)
                            .foregroundStyle(Momentum.accent)

                        if isLatest {
                            Text("LATEST")
                                .font(.caption2.weight(.bold))
                                .tracking(0.8)
                                .foregroundStyle(Momentum.onInverse)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color(red: 0.13, green: 0.52, blue: 1.0))) // blue = notification alert
                        }
                    }

                    Text(title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Momentum.contentPrimary)
                }

                Spacer(minLength: 0)
            }

            Text(description)
                .font(.callout)
                .foregroundStyle(Momentum.contentSecondary)

            Rectangle()
                .fill(Momentum.hairline)
                .frame(height: Momentum.lineThin)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(bullets, id: \.self) { bullet in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Circle()
                            .fill(Momentum.accent)
                            .frame(width: 6, height: 6)
                            .offset(y: -1)
                        Text(bullet)
                            .font(.callout)
                            .foregroundStyle(Momentum.contentPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            // Subtle coral glow that blooms in only from the bottom-right corner,
            // not down the middle / full length of the card.
            SoftGlowCardBackground(
                color: Momentum.accent,
                cornerRadius: 20,
                glowStrength: 0.13,
                center: UnitPoint(x: 0.95, y: 1.08),
                endRadius: 170
            )
        )
    }
}
