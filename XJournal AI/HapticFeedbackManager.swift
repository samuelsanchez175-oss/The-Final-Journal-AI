import UIKit
import CoreHaptics

/// Centralized haptic feedback for consistent, low-latency tactile responses throughout the app.
///
/// Every haptic in the app should go through this manager (not raw `UIFeedbackGenerator`s) so that:
///   - a single user setting (`hapticsEnabled`) can gate all of them, and
///   - generators are retained + re-`prepare()`d, which cuts first-fire latency.
///
/// The OS-level *System Haptics* setting is still respected automatically by UIKit on top of this.
final class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()

    /// UserDefaults key for the in-app haptics toggle (see HapticsSettingsToggle in settings).
    static let enabledKey = "hapticsEnabled"

    private init() {}

    // Retained generators — reused and re-prepared so the Taptic Engine stays warm.
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    /// App-level haptics switch (in addition to the OS System Haptics setting). Defaults to on
    /// when the user has never set it.
    var isEnabled: Bool {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: Self.enabledKey) != nil else { return true }
        return defaults.bool(forKey: Self.enabledKey)
    }

    /// Semantic description of a haptic — call sites ask for an intent, not a specific generator.
    enum Haptic {
        case selection                                       // pickers, segment/tab/toggle changes
        case impact(UIImpactFeedbackGenerator.FeedbackStyle) // taps, drags, snaps
        case success, warning, error                         // operation outcomes
        case toggle(Bool)                                    // on = medium, off = light
    }

    private func impactGenerator(_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
        if let existing = impactGenerators[style] { return existing }
        let generator = UIImpactFeedbackGenerator(style: style)
        impactGenerators[style] = generator
        return generator
    }

    /// Warm the Taptic Engine just before an imminent haptic to reduce latency. Safe to call often.
    func prepare(_ haptic: Haptic) {
        guard isEnabled else { return }
        switch haptic {
        case .selection:                 selectionGenerator.prepare()
        case .impact(let style):         impactGenerator(style).prepare()
        case .success, .warning, .error: notificationGenerator.prepare()
        case .toggle(let on):            impactGenerator(on ? .medium : .light).prepare()
        }
    }

    /// Fire a haptic (no-op when the user has disabled haptics). Re-prepares afterwards so a
    /// rapid follow-up fire stays low-latency.
    func fire(_ haptic: Haptic) {
        guard isEnabled else { return }
        switch haptic {
        case .selection:
            selectionGenerator.selectionChanged()
            selectionGenerator.prepare()
        case .impact(let style):
            let generator = impactGenerator(style)
            generator.impactOccurred()
            generator.prepare()
        case .success:
            notificationGenerator.notificationOccurred(.success)
            notificationGenerator.prepare()
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
            notificationGenerator.prepare()
        case .error:
            notificationGenerator.notificationOccurred(.error)
            notificationGenerator.prepare()
        case .toggle(let on):
            let generator = impactGenerator(on ? .medium : .light)
            generator.impactOccurred()
            generator.prepare()
        }
    }

    // MARK: - Backwards-compatible semantic wrappers (now gated + prepared)

    /// Light tap for button presses
    func lightTap()  { fire(.impact(.light)) }
    /// Medium tap for expand/collapse and important actions
    func mediumTap() { fire(.impact(.medium)) }
    /// Heavy tap for significant actions
    func heavyTap()  { fire(.impact(.heavy)) }
    /// Soft tap for gentle, low-emphasis feedback
    func softTap()   { fire(.impact(.soft)) }
    /// Rigid tap for crisp, mechanical feedback
    func rigidTap()  { fire(.impact(.rigid)) }
    /// Success haptic for AI completion and successful operations
    func success()   { fire(.success) }
    /// Warning haptic for warnings
    func warning()   { fire(.warning) }
    /// Error haptic for failed operations
    func error()     { fire(.error) }
    /// Selection haptic for menu items and pickers
    func selection() { fire(.selection) }

    // MARK: - Signature (Core Haptics) patterns

    /// Distinctive, *composed* haptics for standout moments — these are meant to feel different
    /// from the everyday taps above so the user can recognize them by touch. Falls back to a
    /// sequence of simple generators when Core Haptics isn't supported (e.g. older devices,
    /// Simulator) or the engine can't start, so there's never a regression to "no feedback".
    enum Signature {
        case achievement   // celebratory rising triple-tap (badge unlocked)
        case aiReady       // soft anticipation → crisp arrival (AI results landed)
        case love          // quick crisp double-pop (favorite / like)
        case sparkle       // tiny high-sharpness tick (a standout "Model G moment")
        case recordStart   // soft build → firm commit (recording armed)
        case recordStop    // firm release → soft settle (recording ended)
        case newNote       // gentle bloom (a fresh page)
    }

    private var hapticEngine: CHHapticEngine?
    private lazy var supportsCoreHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    /// Play a composed signature haptic (gated by the user setting, with a graceful fallback).
    func play(_ signature: Signature) {
        guard isEnabled else { return }
        guard supportsCoreHaptics, let pattern = try? Self.pattern(for: signature) else {
            playFallback(for: signature)
            return
        }
        do {
            let engine = try runningEngine()
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            playFallback(for: signature)
        }
    }

    private func runningEngine() throws -> CHHapticEngine {
        if let engine = hapticEngine {
            try? engine.start() // no-op if already running; cheap to ensure it's up
            return engine
        }
        let engine = try CHHapticEngine()
        engine.isAutoShutdownEnabled = true
        engine.resetHandler = { [weak self] in try? self?.hapticEngine?.start() }
        try engine.start()
        hapticEngine = engine
        return engine
    }

    private static func pattern(for signature: Signature) throws -> CHHapticPattern {
        func tap(_ time: TimeInterval, intensity: Float, sharpness: Float) -> CHHapticEvent {
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: time)
        }
        func swell(_ time: TimeInterval, duration: TimeInterval, intensity: Float, sharpness: Float) -> CHHapticEvent {
            CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: time, duration: duration)
        }
        let events: [CHHapticEvent]
        switch signature {
        case .achievement:                       // three rising taps — a little triumph
            events = [
                tap(0.00, intensity: 0.6, sharpness: 0.30),
                tap(0.10, intensity: 0.8, sharpness: 0.50),
                tap(0.20, intensity: 1.0, sharpness: 0.80)
            ]
        case .aiReady:                           // soft lead-in, then a crisp "it's here"
            events = [
                tap(0.00, intensity: 0.4, sharpness: 0.20),
                tap(0.13, intensity: 0.9, sharpness: 0.60)
            ]
        case .love:                              // quick crisp double-pop
            events = [
                tap(0.00, intensity: 0.7, sharpness: 0.70),
                tap(0.07, intensity: 1.0, sharpness: 0.90)
            ]
        case .sparkle:                           // single tiny, very crisp tick
            events = [
                tap(0.00, intensity: 0.5, sharpness: 1.00)
            ]
        case .recordStart:                       // soft build, then a firm "armed" commit
            events = [
                swell(0.00, duration: 0.16, intensity: 0.40, sharpness: 0.25),
                tap(0.16, intensity: 0.95, sharpness: 0.50)
            ]
        case .recordStop:                        // firm release, then a soft settle
            events = [
                tap(0.00, intensity: 0.95, sharpness: 0.60),
                swell(0.04, duration: 0.14, intensity: 0.35, sharpness: 0.20)
            ]
        case .newNote:                           // gentle bloom for a fresh page
            events = [
                tap(0.00, intensity: 0.45, sharpness: 0.25),
                swell(0.05, duration: 0.12, intensity: 0.28, sharpness: 0.15)
            ]
        }
        return try CHHapticPattern(events: events, parameters: [])
    }

    /// Approximate each signature with the simple generators when Core Haptics is unavailable.
    private func playFallback(for signature: Signature) {
        switch signature {
        case .achievement:
            fire(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in self?.fire(.impact(.light)) }
        case .aiReady:
            fire(.impact(.light))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) { [weak self] in self?.fire(.success) }
        case .love:
            fire(.impact(.rigid))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) { [weak self] in self?.fire(.impact(.light)) }
        case .sparkle:
            fire(.impact(.soft))
        case .recordStart:
            fire(.impact(.soft))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { [weak self] in self?.fire(.impact(.heavy)) }
        case .recordStop:
            fire(.impact(.medium))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { [weak self] in self?.fire(.impact(.soft)) }
        case .newNote:
            fire(.impact(.soft))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { [weak self] in self?.fire(.impact(.light)) }
        }
    }
}
