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
        self.background(
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tint.opacity(0.05))                      // whisper of warmth
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.55), lineWidth: Momentum.lineThin)  // soft top-light edge
            }
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        )
    }

    /// Full-pill variant for circular/again-rounded chrome (e.g. a floating compose button).
    func momentumGlassCapsule(tint: Color = Momentum.accent) -> some View {
        self.background(
            ZStack {
                Capsule(style: .continuous).fill(.ultraThinMaterial)
                Capsule(style: .continuous).fill(tint.opacity(0.05))
                Capsule(style: .continuous).stroke(Color.white.opacity(0.55), lineWidth: Momentum.lineThin)
            }
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        )
    }
}
