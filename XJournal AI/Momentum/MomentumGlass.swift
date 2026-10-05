//
//  MomentumGlass.swift
//  XJournal AI
//
//  P6 — tasteful glass REINTRODUCED (Samuel 2026-05-31), used only on the 3 chrome surfaces:
//  the dynamic-island keyboard toolbar, the bottom-of-page buttons, and the note creator/editor.
//  Refined, not the old forced muddy glass: ultraThinMaterial + a whisper of warmth + a soft
//  top-light hairline + a gentle shadow, soft-cornered. Reads as deliberate chrome floating over
//  the light Momentum surface. Content surfaces (lists/cards) stay flat.
//

import SwiftUI

extension View {
    /// Tasteful frosted chrome for P6 surfaces. `tint` adds a faint accent wash (coral by default).
    func momentumGlass(cornerRadius: CGFloat = Momentum.corner, tint: Color = Momentum.accent) -> some View {
        modifier(MomentumFrostedChrome(
            shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
            tint: tint
        ))
    }

    /// Full-pill variant for circular/again-rounded chrome (e.g. a floating compose button).
    func momentumGlassCapsule(tint: Color = Momentum.accent) -> some View {
        modifier(MomentumFrostedChrome(shape: Capsule(style: .continuous), tint: tint))
    }

    /// iOS 26 liquid glass that stays readable in Dark. Apple's default samples the
    /// page behind it — on a dark list/editor that goes nearly black. We lift the
    /// fill and brighten the hairline so search, compose, pills, and the island still read.
    func momentumLiquidGlass<S: InsettableShape>(in shape: S, tint: Color = Color.white) -> some View {
        modifier(MomentumLiquidGlass(shape: shape, tint: tint))
    }
}

/// Shared Dark-vs-Light glass recipe. Dark gets a white lift so chrome does not
/// melt into `#0C1417` / `#16201F`.
enum MomentumGlassChrome {
    static func lift(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.28) : Color.white.opacity(0.10)
    }

    static func fill(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.22) : Color.white.opacity(0.42)
    }

    static func edge(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.58) : Color.white.opacity(0.55)
    }

    /// Keep glass silver in Dark. A coral/Lagoon wash was painting icons purple on the island and pills.
    static func accentWash(_ scheme: ColorScheme) -> Double {
        scheme == .dark ? 0.0 : 0.05
    }
}

private struct MomentumFrostedChrome<S: InsettableShape>: ViewModifier {
    var shape: S
    var tint: Color
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.background(
            ZStack {
                shape.fill(.ultraThinMaterial)
                shape.fill(MomentumGlassChrome.fill(scheme))
                shape.fill(tint.opacity(MomentumGlassChrome.accentWash(scheme)))
                shape.strokeBorder(MomentumGlassChrome.edge(scheme), lineWidth: Momentum.lineThin)
            }
            .shadow(color: .black.opacity(scheme == .dark ? 0.35 : 0.06), radius: 12, y: 4)
        )
    }
}

/// Capsule fill for filter/metadata pills (material + Dark lift, no iOS 26 glassEffect).
struct MomentumChromeCapsule: View {
    var isActive: Bool = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay(Capsule().fill(MomentumGlassChrome.fill(scheme)))
            .overlay(
                Capsule().strokeBorder(
                    isActive ? Momentum.accent : MomentumGlassChrome.edge(scheme),
                    lineWidth: Momentum.lineThin
                )
            )
    }
}

private struct MomentumLiquidGlass<S: InsettableShape>: ViewModifier {
    var shape: S
    var tint: Color
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .background(shape.fill(MomentumGlassChrome.fill(scheme)))
            .background(shape.fill(tint.opacity(MomentumGlassChrome.accentWash(scheme))))
            .glassEffect(.regular.tint(MomentumGlassChrome.lift(scheme)), in: shape)
            .overlay(shape.strokeBorder(MomentumGlassChrome.edge(scheme), lineWidth: Momentum.lineThin))
    }
}
