//
//  MomentumDesignSystem.swift
//  XJournal AI
//
//  Momentum reskin — the canonical design system (per docs/superpowers/specs/
//  2026-05-31-momentum-ui-reskin-design.md). Light, editorial, FLAT. Signature must-keeps
//  (locked w/ Samuel): line work (1px/3px rules + line-art circles), the soft coral
//  AtmosphereGlow, and SOFT / pill buttons (rounded edges — updated 2026-05-31, were too square).
//
//  Layer 0 foundation only (tokens · AtmosphereGlow · MomentumSectionHeader · MainDivider + soft
//  control styles). Layers 1–4 components land per phase.
//

import SwiftUI

// MARK: - Hex helper

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255.0,
                  green: Double((hex >> 8) & 0xFF) / 255.0,
                  blue: Double(hex & 0xFF) / 255.0,
                  opacity: alpha)
    }
}

// MARK: - Tokens

enum Momentum {
    // Surfaces / content
    static let surface          = Color(hex: 0xF8F8F8)
    static let surfaceElevated   = Color.white
    static let contentPrimary    = Color(hex: 0x1C1C1E)
    static let contentSecondary  = Color(hex: 0x1C1C1E, alpha: 0.6)
    // Accent
    static let accent            = Color(hex: 0xFF8C66)   // coral
    static let accentCalm        = Color(hex: 0x6688FF)   // empathy / reset states only
    // Inverse (emphasis banner, primary button)
    static let inverseSurface    = Color(hex: 0x1C1C1E)
    static let onInverse         = Color(hex: 0xF8F8F8)
    // Line work
    static let lineThin: CGFloat  = 1
    static let lineThick: CGFloat = 3
    static let hairline          = Color(hex: 0x1C1C1E, alpha: 0.10)
    static let edge: CGFloat      = 24
    static let corner: CGFloat    = 14   // soft button/card radius (chips use a full pill / Capsule)

    // Rhyme-highlight + metadata-pill tints — retained for the editor re-tune (P5) and the
    // detail-view metadata pills; NOT used in Layer 0.
    static let highlightPink   = Color(hex: 0xFCE7F3)
    static let highlightGreen  = Color(hex: 0xDCFCE7)
    static let highlightYellow = Color(hex: 0xFEF08A)
}

// MARK: - Type scale (≥16pt for content; sub-16 only for true metadata)

extension Font {
    static func momentumHero(_ size: CGFloat = 72) -> Font { .system(size: size, weight: .bold) }
    static let momentumCardTitle = Font.system(size: 18, weight: .semibold)
    static let momentumBody      = Font.system(size: 16)
    static let momentumMetadata  = Font.system(size: 13)
    static let momentumSection   = Font.system(size: 12, weight: .semibold)   // + .tracking in MomentumSectionHeader
}

// MARK: - Theme mode (Light default; editorial-dark deferred, seam kept)

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
    var colorScheme: ColorScheme? {
        switch self {
        case .light, .warm: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - 2. AtmosphereGlow (signature soft coral radial top-glow; blue calm variant)

struct AtmosphereGlow: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var calm: Bool = false                                   // blue accentCalm for empathy/reset
    private var glow: Color { calm ? Momentum.accentCalm : Momentum.accent }
    private var base: Color { scheme == .dark ? Color(hex: 0x121214) : Momentum.surface }
    @State private var breathe = false
    var body: some View {
        base
            .overlay(alignment: .top) {
                RadialGradient(
                    gradient: Gradient(colors: [
                        glow.opacity(scheme == .dark ? 0.22 : 0.42),
                        glow.opacity(0.12),
                        base.opacity(0)
                    ]),
                    center: UnitPoint(x: 0.72, y: 0.05),
                    startRadius: 0,
                    endRadius: 470
                )
                .scaleEffect(breathe ? 1.06 : 1.0, anchor: .top)
                .opacity(breathe ? 0.72 : 1.0)
                .allowsHitTesting(false)
                .onAppear {
                    guard !reduceMotion else { return }   // respect Reduce Motion
                    withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                        breathe = true
                    }
                }
            }
            .ignoresSafeArea()
    }
}

// MARK: - 3. MomentumSectionHeader (UPPERCASE label + thin rule)

struct MomentumSectionHeader: View {
    let title: String
    let accessory: AnyView?

    init(title: String) {
        self.title = title
        self.accessory = nil
    }

    /// Header with a trailing action (e.g. a "View All" button) on the label row.
    /// Type-erased so the struct stays concrete — keeps large view bodies type-checking fast.
    init<Accessory: View>(title: String, @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.accessory = AnyView(accessory())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title.uppercased())
                    .font(.momentumSection)
                    .tracking(1.4)
                    .foregroundStyle(Momentum.contentSecondary)
                if let accessory {
                    Spacer(minLength: 8)
                    accessory
                }
            }
            Rectangle().fill(Momentum.contentPrimary).frame(height: Momentum.lineThin)
        }
    }
}

// MARK: - 4. MainDivider (3px rule)

struct MainDivider: View {
    var body: some View { Rectangle().fill(Momentum.contentPrimary).frame(height: Momentum.lineThick) }
}

// MARK: - Soft controls (rounded edges + border, fill-on-press — updated 2026-05-31, were too square)

/// Flat **pill** filter chip — thin border, coral when active. (Home filter row.)
struct MomentumChip: View {
    let title: String
    var systemImage: String? = nil
    var active: Bool = false
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage { Image(systemName: systemImage).font(.system(size: 12, weight: .semibold)) }
                Text(title).font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .foregroundStyle(active ? Momentum.accent : Momentum.contentSecondary)
            .background(Capsule().fill(Momentum.surfaceElevated))
            .overlay(Capsule().stroke(active ? Momentum.accent : Momentum.hairline, lineWidth: Momentum.lineThin))
        }
        .buttonStyle(.plain)
    }
}

/// Soft-cornered button — outline by default, fills (accent or inverse) on press.
struct MomentumSquareButtonStyle: ButtonStyle {
    enum Fill { case outline, accent, inverse }
    var fill: Fill = .outline
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let bg: Color = {
            switch fill {
            case .outline: return pressed ? Momentum.accent : .clear
            case .accent:  return Momentum.accent
            case .inverse: return Momentum.inverseSurface
            }
        }()
        let fg: Color = {
            switch fill {
            case .outline: return pressed ? Momentum.onInverse : Momentum.contentPrimary
            case .accent:  return Momentum.onInverse
            case .inverse: return Momentum.onInverse
            }
        }()
        return configuration.label
            .font(.system(size: 16, weight: .semibold))
            .padding(.horizontal, 18).padding(.vertical, 13)
            .frame(minHeight: 44)
            .background(RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous).fill(bg))
            .overlay(RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous).stroke(Momentum.contentPrimary, lineWidth: Momentum.lineThin))
            .foregroundStyle(fg)
            .contentShape(RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous))
            .opacity(pressed && fill != .outline ? 0.9 : 1)
            .scaleEffect(pressed ? 0.98 : 1)                  // micro-compression (Segment 4)
            .animation(.easeOut(duration: 0.12), value: pressed)
    }
}

#Preview {
    ZStack {
        AtmosphereGlow()
        VStack(alignment: .leading, spacing: 18) {
            Text("Journal").font(.momentumHero(40)).foregroundStyle(Momentum.contentPrimary)
            HStack(spacing: 8) {
                MomentumChip(title: "Created", systemImage: "arrow.down.circle", active: true)
                MomentumChip(title: "Folders", systemImage: "folder")
                MomentumChip(title: "BPM", systemImage: "metronome")
            }
            MomentumSectionHeader(title: "Recent")
            Text("Street Echo").font(.momentumCardTitle).foregroundStyle(Momentum.contentPrimary)
            Text("I walk the block where echoes bounce…").font(.momentumBody).foregroundStyle(Momentum.contentSecondary)
            MainDivider()
            Button("Generate") {}.buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
        }.padding(Momentum.edge)
    }
}
