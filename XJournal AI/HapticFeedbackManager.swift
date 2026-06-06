import UIKit

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
}
