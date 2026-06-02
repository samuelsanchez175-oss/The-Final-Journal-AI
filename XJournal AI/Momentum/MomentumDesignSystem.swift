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
import UIKit
import CoreMotion
import Combine

// MARK: - Hex helper

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255.0,
                  green: Double((hex >> 8) & 0xFF) / 255.0,
                  blue: Double(hex & 0xFF) / 255.0,
                  opacity: alpha)
    }

    /// A color that resolves to a different value in Light vs Dark mode, backed by a dynamic
    /// `UIColor`. Lets static token constants (`Momentum.surface`, …) flip automatically with
    /// the color scheme — no `@Environment` plumbing at the call sites. Dark = the "Lagoon" palette.
    init(light: UInt, dark: UInt, lightAlpha: Double = 1.0, darkAlpha: Double = 1.0) {
        self = Color(UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark
            return UIColor(Color(hex: isDark ? dark : light, alpha: isDark ? darkAlpha : lightAlpha))
        })
    }
}

// MARK: - Tokens

enum Momentum {
    // Surfaces / content — Light value | Dark value ("Lagoon"). Dynamic, so the whole app
    // flips when the color scheme does (the accent picker writes `appTheme`).
    static let surface          = Color(light: 0xF8F8F8, dark: 0x0C1417)
    static let surfaceElevated   = Color(light: 0xFFFFFF, dark: 0x16201F)
    static let contentPrimary    = Color(light: 0x1C1C1E, dark: 0xE6EEF0)
    static let contentSecondary  = Color(light: 0x1C1C1E, dark: 0xE6EEF0, lightAlpha: 0.6, darkAlpha: 0.6)
    // Accent
    static var accent: Color { CoralSettings.preset.color }   // follows the selected preset — warm (Light) or Lagoon cool (Dark)
    static let accentCalm        = Color(light: 0x6688FF, dark: 0x7E9FE0)   // empathy / reset states only
    // Inverse (emphasis banner, primary button) — flips in Dark
    static let inverseSurface    = Color(light: 0x1C1C1E, dark: 0xE6EEF0)
    static let onInverse         = Color(light: 0xF8F8F8, dark: 0x0C1417)
    // Line work
    static let lineThin: CGFloat  = 1
    static let lineThick: CGFloat = 3
    static let hairline          = Color(light: 0x1C1C1E, dark: 0xE6EEF0, lightAlpha: 0.10, darkAlpha: 0.12)
    static let edge: CGFloat      = 24
    static let corner: CGFloat    = 14   // soft button/card radius (chips use a full pill / Capsule)

    // Rhyme-highlight + metadata-pill tints — solid pastels in Light; translucent jewel/amber
    // washes in Dark so they read on the dark surface (editor retune may refine these).
    static let highlightPink   = Color(light: 0xFCE7F3, dark: 0x3A6CE4, darkAlpha: 0.20)
    static let highlightGreen  = Color(light: 0xDCFCE7, dark: 0x1AB082, darkAlpha: 0.20)
    static let highlightYellow = Color(light: 0xFEF08A, dark: 0xE8C24A, darkAlpha: 0.18)
}

// MARK: - Type scale (≥16pt for content; sub-16 only for true metadata)
//
// Dynamic Type: the ramp maps to semantic text styles so it scales with the iOS Text Size slider
// AND re-renders live (SwiftUI tracks the dependency for semantic fonts; a static UIFontMetrics
// read would not update live). Base sizes preserved: body 16 = .callout, metadata 13 = .footnote,
// section 12 = .caption, cardTitle = .headline (17 semibold; was 18 — locked 1pt drop). Hero scales
// relative to .largeTitle, clamped (display text shouldn't run away).

extension Font {
    static func momentumHero(_ size: CGFloat = 72) -> Font {
        let scaled = UIFontMetrics(forTextStyle: .largeTitle).scaledValue(for: size)
        return .system(size: min(scaled, size * 1.6), weight: .bold)
    }
    static let momentumCardTitle = Font.headline                    // 17 semibold (was .system(size: 18, .semibold))
    static let momentumBody      = Font.callout                     // 16 (exact)
    static let momentumMetadata  = Font.footnote                    // 13 (exact)
    static let momentumSection   = Font.caption.weight(.semibold)   // 12 (+ .tracking in MomentumSectionHeader)
}

// MARK: - Dynamic Type helpers

extension View {
    /// Cap Dynamic Type growth for dense chrome (toolbars, chip bars, tab rows, metadata rows) so it
    /// stays usable at large text sizes. Reading surfaces stay UNclamped (full accessibility range).
    func chromeClamp() -> some View {
        dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    /// Keep an icon button's tappable area at ≥44pt, scaled with Dynamic Type. Apply to the button's
    /// label so the hit area grows with text (within any `chromeClamp()` ceiling on the subtree).
    func scaledHitTarget() -> some View { modifier(ScaledHitTarget()) }
}

/// Backs `scaledHitTarget()`. `@ScaledMetric` lives in a view, so the minimum grows with the
/// effective `dynamicTypeSize` (and respects a parent `chromeClamp()`).
private struct ScaledHitTarget: ViewModifier {
    @ScaledMetric(relativeTo: .body) private var minSide: CGFloat = 44
    func body(content: Content) -> some View {
        content.frame(minWidth: minSide, minHeight: minSide)
    }
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

/// Accent presets. Warm "Coral" siblings (Light mode) + cool "Lagoon" siblings (Dark mode).
/// `classic` is the locked Momentum coral (#FF8C66). Selecting a cool preset switches the app
/// to Dark mode — see `isDark` and `CoralAppearanceSection`.
enum CoralPreset: String, CaseIterable, Identifiable {
    // Warm — Light mode
    case classic, blush, ember, apricot, rose, plum
    // Cool — "Lagoon" (Dark mode)
    case mint, jade, viridian, teal, marine, cobalt, iris

    var id: String { rawValue }

    /// Cool presets drive Dark mode; warm presets drive Light.
    var isDark: Bool {
        switch self {
        case .classic, .blush, .ember, .apricot, .rose, .plum: return false
        case .mint, .jade, .viridian, .teal, .marine, .cobalt, .iris: return true
        }
    }

    /// Split for the two-row picker (Light row / Dark row).
    static var lightCases: [CoralPreset] { allCases.filter { !$0.isDark } }
    static var darkCases:  [CoralPreset] { allCases.filter {  $0.isDark } }

    var label: String {
        switch self {
        case .classic: return "Coral"
        case .blush:   return "Blush"
        case .ember:   return "Ember"
        case .apricot: return "Apricot"
        case .rose:    return "Rose"
        case .plum:    return "Plum"
        case .mint:     return "Mint"
        case .jade:     return "Jade"
        case .viridian: return "Viridian"
        case .teal:     return "Teal"
        case .marine:   return "Marine"
        case .cobalt:   return "Cobalt"
        case .iris:     return "Iris"
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
        case .mint:     return 0x2BD49A
        case .jade:     return 0x1AB082
        case .viridian: return 0x0E9E92
        case .teal:     return 0x0C97B4
        case .marine:   return 0x1E8AD4
        case .cobalt:   return 0x3A6CE4
        case .iris:     return 0x5F66EA
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

/// Editor chrome toggles (Page 2 toolbar). Separate from coral — these don't tint the glow.
enum EditorChromeSettings {
    /// When true (default), the Note Editor's undo/redo/add pill drops its iOS 26
    /// liquid-glass background (`sharedBackgroundVisibility(.hidden)`) and sits flat on
    /// the coral — the weak header coral made that platter read muddy gray.
    static let hideToolbarGlassKey = "hide_editor_toolbar_glass"

    /// Writing-area font size in points. Global across all notes. Default 17 ≈ `.body`.
    /// Drives the TextEditor, the rhyme-highlight overlay, and the slam animation so all
    /// three stay pixel-aligned. Adjusted via the Page 3 toolbar font-size popover.
    static let writingFontSizeKey = "editor_writing_font_size"
    static let defaultWritingFontSize: Double = 17
}

/// Compact − / value / + stepper for the writing-area font size, shown in the Page 3
/// toolbar popover. Concrete + self-contained; theme-adaptive (light + dark).
struct FontSizeStepperPopover: View {
    @Binding var fontSize: Double
    private let range: ClosedRange<Double> = 12...34

    var body: some View {
        HStack(spacing: 14) {
            stepButton("minus", disabled: fontSize <= range.lowerBound) {
                fontSize = max(range.lowerBound, fontSize - 1)
            }
            Text("\(Int(fontSize))")
                .font(.system(size: 17, weight: .semibold).monospacedDigit())
                .frame(minWidth: 26)
            stepButton("plus", disabled: fontSize >= range.upperBound) {
                fontSize = min(range.upperBound, fontSize + 1)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func stepButton(_ symbol: String, disabled: Bool, _ action: @escaping () -> Void) -> some View {
        Button {
            HapticFeedbackManager.shared.lightTap()
            action()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .frame(width: 38, height: 38)
                .background(Circle().fill(Color(.secondarySystemFill)))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.35 : 1.0)
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
    private var base: Color { Momentum.surface }   // dynamic — Light #F8F8F8 / Dark Lagoon #0C1417
    // strength (0…1) scales the glow; 0.5 reproduces the original 0.42 / 0.22 peak.
    private var peakOpacity: Double { (scheme == .dark ? 0.44 : 0.84) * strength }
    private var midOpacity: Double { 0.24 * strength }
    @State private var breathe = false
    // Subtle full-bleed wash so the otherwise-white areas pick up a faint coral
    // too — deliberately much lighter than the top radial glow, a touch stronger
    // toward the bottom for depth.
    private var washTop: Double { 0.05 * strength * 2 }
    private var washBottom: Double { (scheme == .dark ? 0.12 : 0.11) * strength * 2 }
    var body: some View {
        base
            .overlay {
                LinearGradient(
                    colors: [glow.opacity(washTop), glow.opacity(washBottom)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            }
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

/// Full-height coral wash for the note editor header (nav bar → title → pills → divider).
/// The breathing radial alone fades out around the title; this adds a vertical tint so the
/// bloom continues through the pill row and stops cleanly at the gray divider below.
struct EditorHeaderCoralBackground: View {
    var bpm: Int?
    @Environment(\.colorScheme) private var scheme
    @AppStorage(CoralSettings.presetKey) private var presetRaw: String = CoralPreset.classic.rawValue
    @AppStorage(CoralSettings.strengthKey) private var strength: Double = CoralSettings.defaultStrength

    private var glow: Color { (CoralPreset(rawValue: presetRaw) ?? .classic).color }
    private var washTop: Double { (scheme == .dark ? 0.16 : 0.24) * strength }
    private var washMid: Double { (scheme == .dark ? 0.11 : 0.17) * strength }
    private var washLower: Double { (scheme == .dark ? 0.07 : 0.11) * strength }

    var body: some View {
        ZStack(alignment: .top) {
            Momentum.surfaceElevated
            LinearGradient(
                stops: [
                    .init(color: glow.opacity(washTop), location: 0.0),
                    .init(color: glow.opacity(washMid), location: 0.38),
                    .init(color: glow.opacity(washLower), location: 0.88),
                    // Hairline fade at the very bottom — hard stop at the divider line.
                    .init(color: glow.opacity(washLower * 0.35), location: 0.97),
                    .init(color: glow.opacity(0), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            EditorCoralGlow(bpm: bpm)
        }
    }
}

// MARK: - Coral appearance controls (Profile → App)

/// Preset swatches (Light row + Dark row) + strength + breathing. The picker doubles as the
/// Light/Dark switch — a cool "Lagoon" swatch flips the app to Dark. Concrete + self-contained
/// so the large profile body in CCV.12 keeps type-checking fast.
struct CoralAppearanceSection: View {
    @AppStorage(CoralSettings.presetKey) private var presetRaw: String = CoralPreset.classic.rawValue
    @AppStorage(CoralSettings.strengthKey) private var strength: Double = CoralSettings.defaultStrength
    @AppStorage(CoralSettings.editorBreathingKey) private var breatheInEditor: Bool = true
    /// Same key the app root reads for `.preferredColorScheme`. Warm swatch → Light, cool → Dark.
    @AppStorage("appTheme") private var appTheme: String = ThemeMode.light.rawValue

    private var selected: CoralPreset { CoralPreset(rawValue: presetRaw) ?? .classic }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            swatchRow(title: "Light", presets: CoralPreset.lightCases)
            swatchRow(title: "Dark",  presets: CoralPreset.darkCases)

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
                    Text("A gentle pulse behind your writing.")
                        .font(.momentumMetadata)
                        .foregroundStyle(Momentum.contentSecondary)
                }
            }
            .tint(selected.color)
        }
    }

    /// One labeled row of swatches. Tapping sets the accent and flips the app between Light and
    /// Dark to match the swatch (cool = Dark).
    private func swatchRow(title: String, presets: [CoralPreset]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.momentumSection)
                .tracking(1.4)
                .foregroundStyle(Momentum.contentSecondary)
            HStack(spacing: 12) {
                ForEach(presets) { preset in
                    Button {
                        presetRaw = preset.rawValue
                        appTheme = (preset.isDark ? ThemeMode.dark : ThemeMode.light).rawValue
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
        }
    }
}

/// Page 1.1 Profile → Page 2 editor chrome. Concrete + self-contained so the large
/// profile body in CCV.12 keeps type-checking fast.
struct EditorButtonsSection: View {
    @AppStorage(EditorChromeSettings.hideToolbarGlassKey) private var flatten: Bool = true

    var body: some View {
        Toggle(isOn: $flatten) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Flatten editor buttons").font(.momentumBody)
                Text("Removes the frosted-glass panel behind the editor's undo, redo, and add buttons so they sit flat on the coral. On by default.")
                    .font(.momentumMetadata)
                    .foregroundStyle(Momentum.contentSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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

// MARK: - Gyro Specular Edge (iOS 26-style glass light)

/// Shared device-motion source. A single CoreMotion stream drives every glass
/// edge highlight in the app so we never spin up more than one `CMMotionManager`.
final class GyroMotionManager: ObservableObject {
    static let shared = GyroMotionManager()

    private let manager = CMMotionManager()
    let isAvailable: Bool

    /// Device roll (left/right tilt) in radians, lightly smoothed.
    @Published var roll: Double = 0
    /// Device pitch (forward/back tilt) in radians, lightly smoothed.
    @Published var pitch: Double = 0

    private init() {
        isAvailable = manager.isDeviceMotionAvailable
        guard isAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let attitude = motion?.attitude else { return }
            // Low-pass filter so the highlight glides instead of jittering.
            self.roll = self.roll * 0.82 + attitude.roll * 0.18
            self.pitch = self.pitch * 0.82 + attitude.pitch * 0.18
        }
    }
}

/// A thin, bright reflection that rides the edge of a glass shape and tracks the
/// device's tilt — the small moving "specular" glint Apple uses on iOS 26 glass.
/// Falls back to a slow auto-rotation on devices/simulators without a gyro.
struct GyroSpecularEdge<S: InsettableShape>: View {
    let shape: S
    var lineWidth: CGFloat = 1.4
    var tint: Color = .white
    var intensity: Double = 1.0

    @ObservedObject private var motion = GyroMotionManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var autoAngle: Double = 0

    private var angle: Angle {
        if motion.isAvailable && !reduceMotion {
            return .radians(motion.roll * 1.7 + motion.pitch * 0.8)
        }
        return .degrees(autoAngle)
    }

    var body: some View {
        shape
            .strokeBorder(
                AngularGradient(
                    gradient: Gradient(stops: [
                        .init(color: tint.opacity(0),                  location: 0.00),
                        .init(color: tint.opacity(0.95 * intensity),   location: 0.05),
                        .init(color: tint.opacity(0.30 * intensity),   location: 0.11),
                        .init(color: tint.opacity(0),                  location: 0.22),
                        .init(color: tint.opacity(0),                  location: 0.55),
                        .init(color: tint.opacity(0.45 * intensity),   location: 0.60),
                        .init(color: tint.opacity(0),                  location: 0.68),
                        .init(color: tint.opacity(0),                  location: 1.00)
                    ]),
                    center: .center,
                    angle: angle
                ),
                lineWidth: lineWidth
            )
            .blendMode(.screen)
            .allowsHitTesting(false)
            .onAppear {
                guard !(motion.isAvailable && !reduceMotion), !reduceMotion else { return }
                withAnimation(.linear(duration: 5.5).repeatForever(autoreverses: false)) {
                    autoAngle = 360
                }
            }
    }
}

extension View {
    /// Adds an iOS 26-style moving specular glint to the edge of a glass shape.
    func gyroSpecularEdge<S: InsettableShape>(
        _ shape: S,
        lineWidth: CGFloat = 1.4,
        tint: Color = .white,
        intensity: Double = 1.0
    ) -> some View {
        overlay(GyroSpecularEdge(shape: shape, lineWidth: lineWidth, tint: tint, intensity: intensity))
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
