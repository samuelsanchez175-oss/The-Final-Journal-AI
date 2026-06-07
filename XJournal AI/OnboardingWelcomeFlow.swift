//
//  OnboardingWelcomeFlow.swift
//  XJournal AI
//
//  First-run onboarding. Two steps:
//    1. Welcome — a soft coral "bloom" drifts across the screen and beats like a heart
//       behind the welcome message (reduced-motion aware).
//    2. Connect your AI — a skippable bring-your-own-key step (OpenAI / Gemini), stored
//       in the device Keychain via KeychainHelper. No accounts in v1.
//
//  Coral comes from the user's Momentum CoralPreset (Momentum.accent, default #FF8C66),
//  so this stays on-brand if the accent preset changes.
//
//  Presented from The_Final_Journal_AIApp while SplashScreenManager.hasCompletedOnboarding
//  is false. On completion the app calls markOnboardingComplete(), which also unlocks the
//  existing per-button toolbar coachmark tour (see ContentView.CCV.13 + SplashScreenView).
//

import SwiftUI
import Foundation

// MARK: - Traveling coral bloom (drifts + heartbeat)

/// A single soft coral radial bloom that slowly drifts across the screen and pulses with a
/// cardiac "lub-dub" rhythm. Ambient only — never intercepts touches. Static under Reduce Motion.
struct TravelingCoralBloom: View {
    var color: Color = Momentum.accent
    /// 0…1 overall strength of the bloom.
    var intensity: Double = 1.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Heartbeat period. ~62 bpm → ≈0.97s per beat.
    private let beatPeriod: Double = 0.97

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let radius = max(w, h) * 0.55

            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let beat = reduceMotion
                    ? 0
                    : heartbeat(phase: t.truncatingRemainder(dividingBy: beatPeriod) / beatPeriod)
                let scale = 1.0 + beat * 0.06
                let glowBoost = beat * 0.12

                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                color.opacity((0.32 + glowBoost) * intensity),
                                color.opacity(0.15 * intensity),
                                color.opacity(0.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: radius
                        )
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .scaleEffect(scale)
                    .position(bloomPosition(t: t, w: w, h: h))
                    .blur(radius: 36)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// Slow elliptical (Lissajous) drift around the upper-center of the screen.
    private func bloomPosition(t: Double, w: CGFloat, h: CGFloat) -> CGPoint {
        guard !reduceMotion else { return CGPoint(x: w * 0.5, y: h * 0.42) }
        let cx = w * 0.5
        let cy = h * 0.42
        let ampX = w * 0.32
        let ampY = h * 0.20
        let x = cx + CGFloat(sin(t * 0.12)) * ampX
        let y = cy + CGFloat(cos(t * 0.085)) * ampY
        return CGPoint(x: x, y: y)
    }

    /// Cardiac "lub-dub" envelope. phase ∈ [0,1) → amplitude ∈ [0,1].
    private func heartbeat(phase p: Double) -> Double {
        let lub = exp(-pow((p - 0.10) / 0.045, 2))
        let dub = 0.62 * exp(-pow((p - 0.26) / 0.050, 2))
        return min(1.0, lub + dub)
    }
}

// MARK: - Onboarding welcome flow

struct OnboardingWelcomeFlow: View {
    /// Called when the user finishes (or skips) the flow.
    var onComplete: () -> Void

    private enum Step { case welcome, connectAI }

    @State private var step: Step = .welcome
    @State private var apiKeyDraft: String = ""
    @State private var keychainSaveError: String? = nil

    private var trimmedKey: String {
        apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack {
            // Base + ambient coral atmosphere. Pinned to the light Momentum surface
            // (the brand palette + fixed text tokens are built for a light surface),
            // so the welcome reads correctly even if the device is in dark mode.
            Momentum.surface
                .ignoresSafeArea()

            LinearGradient(
                colors: [Momentum.accent.opacity(0.06), .clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            TravelingCoralBloom(intensity: step == .welcome ? 1.0 : 0.7)

            // Foreground content.
            Group {
                switch step {
                case .welcome:   welcomeStep
                case .connectAI: connectAIStep
                }
            }
            .frame(maxWidth: 460)
            .padding(.horizontal, 28)
        }
        .transition(.opacity)
        .alert("Couldn't save key", isPresented: Binding(
            get: { keychainSaveError != nil },
            set: { if !$0 { keychainSaveError = nil } }
        )) {
            Button("Try again", role: .cancel) { keychainSaveError = nil }
            Button("Skip for now") { keychainSaveError = nil; onComplete() }
        } message: {
            Text(keychainSaveError ?? "")
        }
    }

    // MARK: Step 1 — Welcome

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: 16) {
                Text("WELCOME TO")
                    .font(.momentumSection)
                    .tracking(2)
                    .foregroundStyle(Momentum.contentSecondary)

                Text("Penwork Studios")
                    .font(.momentumHero(48))
                    .foregroundStyle(Momentum.contentPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)

                Text("Your AI writing & journaling companion.")
                    .font(.momentumBody)
                    .foregroundStyle(Momentum.contentSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 14) {
                OnboardingFeatureRow(icon: "sparkles", text: "AI writing help, tuned to your voice")
                OnboardingFeatureRow(icon: "text.magnifyingglass", text: "Live rhyme analysis & rhyme groups")
                OnboardingFeatureRow(icon: "lock.shield", text: "Your keys stay private, in your Keychain")
            }
            .padding(.top, 34)
            .padding(.horizontal, 8)

            Spacer(minLength: 0)

            Button {
                withAnimation(.easeInOut(duration: 0.45)) { step = .connectAI }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Momentum.accent))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 18)
        }
        .padding(.vertical, 40)
    }

    // MARK: Step 2 — Connect your AI (skippable)

    private var connectAIStep: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 12) {
                Text("Connect your AI")
                    .font(.momentumHero(34))
                    .foregroundStyle(Momentum.contentPrimary)

                Text("Penwork Studios uses your own OpenAI or Google Gemini key for AI features. It's stored only on this device — you can add it later in Settings.")
                    .font(.momentumBody)
                    .foregroundStyle(Momentum.contentSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                APIKeyField(
                    label: "Your API key",
                    placeholder: "sk-…   or   AIza…",
                    helperText: "Stored in your device Keychain — never sent to our servers.",
                    detectProvider: true,
                    draft: $apiKeyDraft
                )
                .padding(.top, 6)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Momentum.surfaceElevated.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Momentum.hairline, lineWidth: Momentum.lineThin)
                    )
            )

            Spacer(minLength: 0)

            VStack(spacing: 12) {
                Button {
                    if trimmedKey.isEmpty {
                        onComplete()
                    } else {
                        do {
                            try KeychainHelper.shared.saveAPIKey(trimmedKey)
                            onComplete()
                        } catch {
                            print("Onboarding Keychain save failed: \(error)")
                            keychainSaveError = "We couldn't save your key to your device Keychain. You can try again, or skip and add it later in Settings."
                        }
                    }
                } label: {
                    Text(trimmedKey.isEmpty ? "Skip for now" : "Save & Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Momentum.accent))
                }
                .buttonStyle(.plain)

                if !trimmedKey.isEmpty {
                    Button { onComplete() } label: {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 18)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Feature row

private struct OnboardingFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.callout.weight(.semibold))
                .foregroundStyle(Momentum.accent)
                .frame(width: 26)

            Text(text)
                .font(.momentumBody)
                .foregroundStyle(Momentum.contentPrimary)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Home intro coachmark

/// Shown once over the real home screen right after onboarding completes ("This is your home").
/// A centered coral card over a dimmed backdrop — the actual home stays visible behind it.
struct HomeIntroCoachmark: View {
    var onDismiss: () -> Void

    @State private var show = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 18) {
                Image(systemName: "house.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Momentum.accent)
                    .frame(width: 84, height: 84)
                    .background(Circle().fill(Momentum.accent.opacity(0.12)))

                Text("This is your home")
                    .font(.momentumCardTitle)
                    .foregroundStyle(Momentum.contentPrimary)

                Text("Your journal entries live here. Tap the + to start a new one — your writing tools appear the moment you're inside an entry.")
                    .font(.momentumBody)
                    .foregroundStyle(Momentum.contentSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button { onDismiss() } label: {
                    Text("Got it")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Momentum.accent))
                }
                .buttonStyle(.plain)
            }
            .padding(28)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Momentum.hairline, lineWidth: Momentum.lineThin)
                    )
            )
            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 12)
            .padding(.horizontal, 28)
            .scaleEffect(show ? 1.0 : 0.92)
            .opacity(show ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { show = true }
        }
    }
}

// MARK: - Preview

#Preview("Welcome") {
    OnboardingWelcomeFlow(onComplete: {})
}

#Preview("Home intro") {
    HomeIntroCoachmark(onDismiss: {})
}
