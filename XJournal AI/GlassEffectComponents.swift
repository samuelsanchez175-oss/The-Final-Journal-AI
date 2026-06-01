//
//  GlassEffectComponents.swift
//  The Final Journal AI
//
//  Glass effect components for Silk Boys aesthetic
//

import SwiftUI

// MARK: - Glass Effect Container

struct GlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    @Environment(\.colorScheme) private var colorScheme
    
    init(spacing: CGFloat = 0, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.15 : 0.25),
                                    Color.white.opacity(colorScheme == .dark ? 0.12 : 0.20),
                                    Color.white.opacity(colorScheme == .dark ? 0.15 : 0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                )
                .overlay(
                    Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0.05)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
    }
}

// MARK: - Glass Prominent Button Style

struct GlassProminentButtonStyle: ButtonStyle {
    let tint: Color
    @Environment(\.colorScheme) private var colorScheme
    
    init(tint: Color = .yellow) {
        self.tint = tint
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                tint.opacity(0.9),
                                tint.opacity(0.8),
                                tint.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(configuration.isPressed ? 0.2 : 0.1),
                                        Color.white.opacity(configuration.isPressed ? 0.15 : 0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .blendMode(.overlay)
                    )
                    .shadow(
                        color: tint.opacity(0.4),
                        radius: configuration.isPressed ? 4 : 8,
                        x: 0,
                        y: configuration.isPressed ? 2 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassProminentButtonStyle {
    static func glassProminent(tint: Color = .yellow) -> GlassProminentButtonStyle {
        GlassProminentButtonStyle(tint: tint)
    }
}

// MARK: - Background Extension Effect

struct BackgroundExtensionEffect: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base dark background
                    Color.black
                        .ignoresSafeArea()
                    
                    // Glass material overlay
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(colorScheme == .dark ? 0.08 : 0.15),
                                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.10),
                                            Color.white.opacity(colorScheme == .dark ? 0.08 : 0.15)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .blendMode(.overlay)
                        )
                        .overlay(
                            Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening * 1.5 : 0.1)
                        )
                }
                .ignoresSafeArea()
            )
    }
}

extension View {
    func backgroundExtensionEffect() -> some View {
        modifier(BackgroundExtensionEffect())
    }
}

// MARK: - Micro-Compression Button Style (Segment 4)

struct MicroCompressionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == MicroCompressionButtonStyle {
    static var microCompression: MicroCompressionButtonStyle {
        MicroCompressionButtonStyle()
    }
}

// MARK: - Smooth Animation Modifier

struct SmoothAnimationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: UUID())
    }
}

extension View {
    func smoothAnimation() -> some View {
        modifier(SmoothAnimationModifier())
    }
}
