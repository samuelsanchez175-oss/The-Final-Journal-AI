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
    static var accent: Color { CoralSettings.preset.color }   // coral — follows the user's Coral preset (default #FF8C66)
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

// MARK: - Coral appearance (user-adjustable accent preset + glow strength)

/// Curated warm/coral accent presets. `classic` is the locked Momentum coral (#FF8C66);
/// the rest are warm siblings so the picker stays on-brand and hard to make ugly.
enum CoralPreset: String, CaseIterable, Identifiable {
    case classic, blush, ember, apricot, rose, plum
    var id: String { rawValue }
    var label: String {
        switch self {
        case .classic: return "Coral"
        case .blush:   return "Blush"
        case .ember:   return "Ember"
        case .apricot: return "Apricot"
        case .rose:    return "Rose"
        case .plum:    return "Plum"
        }
    }
    var hex: UInt {
        switch self {
        case .classic: return 0xFF8C66
        case .blush:   return 0xF7849B
        case .ember:   return 0xF2542D
        case .apricot: return 0xFF9F45
        case .rose:    return 0xE0566E
        case .plum:    return 0xB56576
        }
    }
    var color: Color { Color(hex: hex) }
}

/// Shared keys + defaults for the coral appearance settings. Views bind via `@AppStorage`;
/// non-View contexts (e.g. the app-wide accent, Phase 3D) read the resolvers below.
enum CoralSettings {
    static let presetKey          = "coral_preset"
    static let strengthKey        = "coral_strength"          // 0…1; 0.5 ≈ the original glow
    static let editorBreathingKey = "coral_breathing_in_editor"
    static let defaultStrength: Double = 0.5

    static var preset: CoralPreset {
        CoralPreset(rawValue: UserDefaults.standard.string(forKey: presetKey) ?? "") ?? .classic
    }
    static var strength: Double {
        (UserDefaults.standard.object(forKey: strengthKey) as? Double) ?? defaultStrength
    }
}

// MARK: - 2. AtmosphereGlow (signature soft coral radial top-glow; blue calm variant)

struct AtmosphereGlow: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(CoralSettings.presetKey) private var presetRaw: String = CoralPreset.classic.rawValue
    @AppStorage(CoralSettings.strengthKey) private var strength: Double = CoralSettings.defaultStrength
    var calm: Bool = false                                   // blue accentCalm for empathy/reset
    private var glow: Color { calm ? Momentum.accentCalm : (CoralPreset(rawValue: presetRaw) ?? .classic).color }
    private var base: Color { scheme == .dark ? Color(hex: 0x121214) : Momentum.surface }
    // strength (0…1) scales the glow; 0.5 reproduces the original 0.42 / 0.22 peak.
    private var peakOpacity: Double { (scheme == .dark ? 0.44 : 0.84) * strength }
    private var midOpacity: Double { 0.24 * strength }
    @State private var breathe = false
    var body: some View {
        base
            .overlay(alignment: .top) {
                RadialGradient(
                    gradient: Gradient(colors: [
                        glow.opacity(peakOpacity),
                        glow.opacity(midOpacity),
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

// MARK: - Editor coral glow (breathing behind the writing surface; BPM-damped)

/// The signature coral atmosphere, scoped to the note editor and gently *breathing*. The pulse
/// period is loosely tied to the note's BPM (damped — an interactive feel, never the literal
/// tempo). Honors the "Breathe inside notes" preference; renders nothing when it's off.
struct EditorCoralGlow: View {
    var bpm: Int?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(CoralSettings.presetKey) private var presetRaw: String = CoralPreset.classic.rawValue
    @AppStorage(CoralSettings.strengthKey) private var strength: Double = CoralSettings.defaultStrength
    @AppStorage(CoralSettings.editorBreathingKey) private var enabled: Bool = true
    @State private var breathe = false

    private var glow: Color { (CoralPreset(rawValue: presetRaw) ?? .classic).color }
    // Subtler than the home background so it never fights the text.
    private var peak: Double { (scheme == .dark ? 0.16 : 0.26) * strength }
    private var mid: Double { 0.08 * strength }
    // Damped BPM → period: 60bpm→12s, 220bpm→6s, unset→9s. Deliberately NOT the literal beat.
    private var period: Double {
        guard let bpm else { return 9 }
        let c = Double(min(max(bpm, 60), 220))
        return 12 - (c - 60) / 160 * 6
    }

    var body: some View {
        ZStack {
            if enabled {
                RadialGradient(
                    gradient: Gradient(colors: [glow.opacity(peak), glow.opacity(mid), glow.opacity(0)]),
                    center: UnitPoint(x: 0.7, y: 0.12),
                    startRadius: 0,
                    endRadius: 440
                )
                .scaleEffect(breathe ? 1.05 : 1.0, anchor: .top)
                .opacity(breathe ? 0.78 : 1.0)
                .allowsHitTesting(false)
                .onAppear { animate() }
                .onChange(of: period) { _, _ in animate() }
            }
        }
    }

    private func animate() {
        guard enabled, !reduceMotion else { return }
        breathe = false
        withAnimation(.easeInOut(duration: period).repeatForever(autoreverses: true)) {
            breathe = true
        }
    }
}

// MARK: - Coral appearance controls (Profile → App)

/// Preset swatches + strength + breathing toggle. Concrete + self-contained so the large
/// profile body in CCV.12 keeps type-checking fast.
struct CoralAppearanceSection: View {
    @AppStorage(CoralSettings.presetKey) private var presetRaw: String = CoralPreset.classic.rawValue
    @AppStorage(CoralSettings.strengthKey) private var strength: Double = CoralSettings.defaultStrength
    @AppStorage(CoralSettings.editorBreathingKey) private var breatheInEditor: Bool = true

    private var selected: CoralPreset { CoralPreset(rawValue: presetRaw) ?? .classic }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ForEach(CoralPreset.allCases) { preset in
                    Button {
                        presetRaw = preset.rawValue
                    } label: {
                        Circle()
                            .fill(preset.color)
                            .frame(width: 34, height: 34)
                            .overlay(Circle().strokeBorder(Momentum.hairline, lineWidth: Momentum.lineThin))
                            .overlay(Circle().strokeBorder(Momentum.contentPrimary,
                                                           lineWidth: preset == selected ? 2.5 : 0))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(preset.label)
                    .accessibilityAddTraits(preset == selected ? .isSelected : [])
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Strength")
                        .font(.momentumMetadata)
                        .foregroundStyle(Momentum.contentSecondary)
                    Spacer()
                    Text("\(Int((strength * 100).rounded()))%")
                        .font(.momentumMetadata)
                        .foregroundStyle(Momentum.contentSecondary)
                        .monospacedDigit()
                }
                Slider(value: $strength, in: 0...1).tint(selected.color)
            }

            Toggle(isOn: $breatheInEditor) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Breathe inside notes").font(.momentumBody)
                    Text("A gentle coral pulse behind your writing.")
                        .font(.momentumMetadata)
                        .foregroundStyle(Momentum.contentSecondary)
                }
            }
            .tint(selected.color)
        }
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
