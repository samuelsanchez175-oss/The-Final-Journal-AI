//
//  MomentumTheme.swift
//  XJournal AI
//
//  Momentum design system — light-first, warm-accent. Single source of truth for the reskin
//  (see the design-*.html mockups). Tokens, theme modes (Light/Dark/Warm), the signature
//  "atmosphere" glow, and reusable pill/bar styles. Additive — no behavior change.
//

import SwiftUI

// MARK: - Hex color helper

extension Color {
    /// `Color(hex: 0xFF8C66)` — sRGB from a 24-bit hex literal.
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255.0,
                  green: Double((hex >> 8) & 0xFF) / 255.0,
                  blue: Double(hex & 0xFF) / 255.0,
                  opacity: alpha)
    }
}

// MARK: - Tokens

enum MomentumTheme {
    // Core surfaces / text
    static let bg            = Color(hex: 0xF8F8F8)
    static let surface       = Color.white
    static let surfaceMuted  = Color(hex: 0xF0F0F0)
    static let textMain      = Color(hex: 0x1C1C1E)
    static let textSecondary = Color(hex: 0x1C1C1E, alpha: 0.6)
    static let hairline      = Color(hex: 0x000000, alpha: 0.08)

    // Accent
    static let accent = Color(hex: 0xFF8C66)   // coral
    static let peach  = Color(hex: 0xFFCC99)

    // Rhyme highlights (lyric word groups)
    static let highlightPink   = Color(hex: 0xFCE7F3)
    static let highlightGreen  = Color(hex: 0xDCFCE7)
    static let highlightYellow = Color(hex: 0xFEF08A)

    // Metadata pills (background, foreground)
    static let pillBPM    = (bg: Color(hex: 0xF0F4F8), fg: Color(hex: 0x6CA0E2))
    static let pillKey    = (bg: Color(hex: 0xF4F0F8), fg: Color(hex: 0xA282D2))
    static let pillScale  = (bg: Color(hex: 0xF0F8F6), fg: Color(hex: 0x6CB5A4))
    static let pillURL    = (bg: Color(hex: 0xF4F8FC), fg: Color(hex: 0x72A6DF))
    static let pillFolder = (bg: Color(hex: 0xF8F4F0), fg: Color(hex: 0xC89574))
    static let toolbarTint = Color(hex: 0x72A6DF)

    // Folder card tints (pink/green/yellow/blue)
    static let folderTints: [Color] = [
        Color(hex: 0xFCE7F3), Color(hex: 0xDCFCE7), Color(hex: 0xFEF08A), Color(hex: 0xDBEAFE)
    ]
}

// MARK: - Theme mode (Light / Dark / Warm / System)

enum ThemeMode: String, CaseIterable, Identifiable {
    case light, dark, warm, system
    var id: String { rawValue }
    var label: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .warm: return "Warm"
        case .system: return "Auto"
        }
    }
    /// Light & Warm render in the light scheme (Warm just adds a stronger coral wash).
    var colorScheme: ColorScheme? {
        switch self {
        case .light, .warm: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    var isWarm: Bool { self == .warm }
}
// Appearance is persisted via @AppStorage("appTheme") at the app root and in Settings —
// no separate store needed (avoids a Combine dependency here).

// MARK: - Atmosphere (signature warm radial glow)

struct AtmosphereBackground: View {
    @Environment(\.colorScheme) private var scheme
    var warm: Bool = false
    private var base: Color { scheme == .dark ? Color(hex: 0x121214) : MomentumTheme.bg }
    var body: some View {
        base
            .overlay(alignment: .top) {
                RadialGradient(
                    gradient: Gradient(colors: [
                        MomentumTheme.accent.opacity(scheme == .dark ? 0.22 : (warm ? 0.50 : 0.40)),
                        MomentumTheme.peach.opacity(scheme == .dark ? 0.10 : (warm ? 0.28 : 0.20)),
                        base.opacity(0)
                    ]),
                    center: UnitPoint(x: 0.7, y: 0.08),
                    startRadius: 0,
                    endRadius: warm ? 540 : 460
                )
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()
    }
}

// MARK: - Reusable controls

/// A Momentum filter pill (Created / Folders / BPM / Scale). Selected = white + hairline + shadow.
struct MomentumFilterPill: View {
    let title: String
    var systemImage: String? = nil
    var selected: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage { Image(systemName: systemImage).font(.system(size: 13, weight: .semibold)) }
                Text(title).font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16).padding(.vertical, 7)
            .foregroundStyle(selected ? MomentumTheme.textMain : Color(hex: 0x8E8E93))
            .background(
                Capsule().fill(selected ? MomentumTheme.surface : MomentumTheme.surfaceMuted)
            )
            .overlay(Capsule().stroke(MomentumTheme.hairline, lineWidth: selected ? 1 : 0))
            .shadow(color: selected ? .black.opacity(0.05) : .clear, radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    /// Frosted floating-bar container (search bar, editor toolbar).
    func momentumFloatingBar() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(MomentumTheme.hairline, lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 24, y: 4)
    }
}

#Preview {
    ZStack {
        AtmosphereBackground()
        VStack(alignment: .leading, spacing: 16) {
            Text("Journal").font(.system(size: 34, weight: .heavy)).foregroundStyle(MomentumTheme.textMain)
            HStack {
                MomentumFilterPill(title: "Created", systemImage: "arrow.down.circle", selected: true)
                MomentumFilterPill(title: "Folders", systemImage: "folder")
                MomentumFilterPill(title: "BPM", systemImage: "metronome")
            }
            Text("Street Echo").font(.system(size: 18, weight: .bold)).foregroundStyle(MomentumTheme.textMain)
            Text("I walk the block where echoes bounce…").foregroundStyle(MomentumTheme.textSecondary)
        }.padding(24)
    }
}
