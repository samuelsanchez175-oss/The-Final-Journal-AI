import SwiftUI

// MARK: - GLASS EFFECT
// File: ContentView.CCV.7.swift
// Dependencies: CCV.2 (GlassSettings)
// Used by: ContentView.swift, various views

struct GlassView<S: Shape>: View {
    @Environment(\.colorScheme) private var colorScheme
    let shape: S
    var applyGloss: Bool = false

    var body: some View {
        let material = shape.fill(.ultraThinMaterial)
            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))

        if applyGloss {
            material
                .overlay(
                    LinearGradient(
                        colors: [.white.opacity(0.4 * (GlassSettings.gloss - 0.6)), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                    .clipShape(shape)
                )
        } else {
            material
        }
    }
}
