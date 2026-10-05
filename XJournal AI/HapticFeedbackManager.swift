import UIKit

/// Centralized haptic feedback manager for consistent tactile responses throughout the app
class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notify = UINotificationFeedbackGenerator()
    private let select = UISelectionFeedbackGenerator()

    private init() {
        prepareHold()
    }

    /// Warm the motors so the next hold/tap actually fires on-device.
    func prepareHold() {
        light.prepare()
        medium.prepare()
        select.prepare()
    }

    /// Light tap for button presses
    func lightTap() {
        light.impactOccurred()
        light.prepare()
    }

    /// Medium tap for expand/collapse and important actions
    func mediumTap() {
        medium.impactOccurred()
        medium.prepare()
    }

    /// Heavy tap for significant actions
    func heavyTap() {
        heavy.impactOccurred()
        heavy.prepare()
    }

    /// Success haptic for AI completion and successful operations
    func success() {
        notify.notificationOccurred(.success)
    }

    /// Error haptic for failed operations
    func error() {
        notify.notificationOccurred(.error)
    }

    /// Warning haptic for warnings
    func warning() {
        notify.notificationOccurred(.warning)
    }

    /// Selection haptic for menu items and pickers
    func selection() {
        select.selectionChanged()
        select.prepare()
    }
}
