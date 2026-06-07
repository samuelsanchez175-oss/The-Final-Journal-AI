import Foundation
import Combine

// MARK: - Splash Screen Manager

class SplashScreenManager: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    static let shared = SplashScreenManager()
    
    private let userDefaults = UserDefaults.standard
    private let dismissedKeyPrefix = "splash_dismissed_"
    private let neverShowKeyPrefix = "splash_never_show_"
    
    private init() {}
    
    // MARK: - Check if splash should be shown
    
    func shouldShowSplash(_ id: SplashScreenID) -> Bool {
        // Check if user selected "Never show again"
        if userDefaults.bool(forKey: neverShowKeyPrefix + id.rawValue) {
            return false
        }
        
        // Check if splash has been dismissed
        if userDefaults.bool(forKey: dismissedKeyPrefix + id.rawValue) {
            return false
        }
        
        return true
    }
    
    // MARK: - Dismiss splash (temporary - will show again next time)
    
    func dismissSplash(_ id: SplashScreenID) {
        userDefaults.set(true, forKey: dismissedKeyPrefix + id.rawValue)
    }
    
    // MARK: - Never show again
    
    func neverShowSplash(_ id: SplashScreenID) {
        userDefaults.set(true, forKey: neverShowKeyPrefix + id.rawValue)
        userDefaults.set(true, forKey: dismissedKeyPrefix + id.rawValue)
    }
    
    // MARK: - Reset all splash screens
    
    func resetAllSplashScreens() {
        // Get all splash screen IDs
        let allIDs = SplashScreenID.allCases
        
        for id in allIDs {
            userDefaults.removeObject(forKey: dismissedKeyPrefix + id.rawValue)
            userDefaults.removeObject(forKey: neverShowKeyPrefix + id.rawValue)
        }
    }
    
    // MARK: - Reset specific splash screen
    
    func resetSplash(_ id: SplashScreenID) {
        userDefaults.removeObject(forKey: dismissedKeyPrefix + id.rawValue)
        userDefaults.removeObject(forKey: neverShowKeyPrefix + id.rawValue)
    }
    
    // MARK: - Onboarding State Management
    
    var hasCompletedOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: "has_completed_onboarding")
        }
        set {
            userDefaults.set(newValue, forKey: "has_completed_onboarding")
        }
    }
    
    func markOnboardingComplete() {
        hasCompletedOnboarding = true
    }

    /// Reset the first-run welcome so it can be viewed again: clears the onboarding flag and the
    /// toolbar coachmark tour it unlocks. Post `.showOnboardingAgain` afterwards to present it now.
    func resetOnboarding() {
        hasCompletedOnboarding = false
        resetAllSplashScreens()
    }
    
    func getNextToolbarButtonSplash() -> SplashScreenID? {
        let buttonSplashes: [SplashScreenID] = [
            .toolbarPaperclip,
            .toolbarAISparkle,
            .toolbarUndoRedo,
            .toolbarEyeToggle,
            .toolbarMagnifyingGlass,
            .toolbarGhost,
            .toolbarDiagnostics
        ]
        
        for splashID in buttonSplashes {
            if shouldShowSplash(splashID) {
                return splashID
            }
        }
        
        return nil
    }
}

// MARK: - Notifications

extension Notification.Name {
    /// Posted when the user asks to view the first-run welcome again (from Settings).
    /// The app root observes this to re-present `OnboardingWelcomeFlow` without a relaunch.
    static let showOnboardingAgain = Notification.Name("showOnboardingAgain")
}

// MARK: - Global Accessor Functions

/// Global accessor function to check if onboarding has been completed
/// This allows The_Final_Journal_AIApp.swift to access hasCompletedOnboarding without direct property access
func hasCompletedOnboarding() -> Bool {
    // #region agent log
    let result = SplashScreenManager.shared.hasCompletedOnboarding
    let logData: [String: Any] = [
        "location": "SplashScreenManager.swift:hasCompletedOnboarding",
        "message": "hasCompletedOnboarding wrapper called",
        "data": ["result": result],
        "timestamp": Date().timeIntervalSince1970 * 1000,
        "sessionId": "debug-session",
        "runId": "run1",
        "hypothesisId": "B"
    ]
    if let jsonData = try? JSONSerialization.data(withJSONObject: logData),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        let logPath = "/Users/samuel/Documents/The Final Journal AI/.cursor/debug.log"
        if let fileHandle = FileHandle(forWritingAtPath: logPath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(jsonString.data(using: .utf8)!)
            fileHandle.write("\n".data(using: .utf8)!)
            fileHandle.closeFile()
        } else {
            try? jsonString.write(toFile: logPath, atomically: true, encoding: .utf8)
        }
    }
    // #endregion
    
    return result
}

// MARK: - Splash Screen IDs

enum SplashScreenID: String, CaseIterable {
    case heroScreen = "hero_screen"
    case toolbarOverview = "toolbar_overview"
    case homeOverview = "home_overview"
    case toolbarPaperclip = "toolbar_paperclip"
    case toolbarAISparkle = "toolbar_ai_sparkle"
    case toolbarUndoRedo = "toolbar_undo_redo"
    case toolbarEyeToggle = "toolbar_eye_toggle"
    case toolbarMagnifyingGlass = "toolbar_magnifying_glass"
    case toolbarGhost = "toolbar_ghost"
    case toolbarDiagnostics = "toolbar_diagnostics"
    case aiSparkleButton = "ai_sparkle_button"
    
    var title: String {
        switch self {
        case .heroScreen:
            return "Welcome"
        case .toolbarOverview:
            return "Your Writing Toolbar"
        case .homeOverview:
            return "This is your home"
        case .toolbarPaperclip:
            return "Attach & Import"
        case .toolbarAISparkle:
            return "AI Writing Assistant"
        case .toolbarUndoRedo:
            return "Undo & Redo"
        case .toolbarEyeToggle:
            return "Rhyme Overlay"
        case .toolbarMagnifyingGlass:
            return "Rhyme Groups"
        case .toolbarGhost:
            return "Meet the Ghost"
        case .toolbarDiagnostics:
            return "Rhyme Diagnostics"
        case .aiSparkleButton:
            return "AI Sparkle Button"
        }
    }
}
