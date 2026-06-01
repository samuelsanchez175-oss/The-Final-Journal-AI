//
//  AppErrorRecovery.swift
//  XJournal AI
//
//  Maps API / AI errors to in-app fix destinations and coordinates navigation.
//

import Foundation

// MARK: - Fix destinations

enum AppErrorFixDestination: String, Equatable {
    case none
    case profileAI
    case modelPreferences

    var fixButtonTitle: String? {
        switch self {
        case .none:
            return nil
        case .profileAI:
            return "Open API Settings"
        case .modelPreferences:
            return "Open Model Preferences"
        }
    }
}

// MARK: - In-app error notification payload

extension Notification.Name {
    static let inAppAPIError = Notification.Name("InAppAPIError")
    static let showProfile = Notification.Name("ShowProfile")
}

struct InAppAPIErrorPayload {
    static let messageKey = "message"
    static let destinationKey = "fixDestination"
}

// MARK: - Navigation (pending state for profile sheet)

enum AppNavigation {
    static var pendingProfileTab: ProfileTab?
    static var pendingOpenModelPreferences = false

    @MainActor
    static func navigate(to destination: AppErrorFixDestination) {
        guard destination != .none else { return }

        switch destination {
        case .none:
            break
        case .profileAI:
            pendingProfileTab = .ai
            pendingOpenModelPreferences = false
        case .modelPreferences:
            pendingProfileTab = .ai
            pendingOpenModelPreferences = true
        }

        NotificationCenter.default.post(name: .showProfile, object: nil)
    }

    @MainActor
    static func applyPendingProfileRouting(selectedTab: inout ProfileTab) -> Bool {
        if let tab = pendingProfileTab {
            selectedTab = tab
            pendingProfileTab = nil
        }
        let openPrefs = pendingOpenModelPreferences
        if openPrefs {
            pendingOpenModelPreferences = false
        }
        return openPrefs
    }
}

// MARK: - Classification

enum AppErrorRecovery {

    static func destination(for error: Error) -> AppErrorFixDestination {
        if let api = error as? RapAPIError {
            return destination(for: api)
        }
        if let modelG = error as? ModelGLLMError {
            return destination(for: modelG)
        }
        return destination(forMessage: error.localizedDescription)
    }

    static func destination(for error: RapAPIError) -> AppErrorFixDestination {
        switch error {
        case .missingAPIKey:
            return .profileAI
        case .rateLimitExceeded:
            return .profileAI
        case .serverError(let code, _):
            if code == 401 || code == 403 || code == 402 {
                return .profileAI
            }
            return .none
        case .modelGCoreFailed:
            return .modelPreferences
        case .silence:
            return .modelPreferences
        case .emptyResponse:
            return .modelPreferences
        case .requestFailed, .invalidResponse, .jsonParsingFailed:
            return .none
        }
    }

    static func destination(for error: ModelGLLMError) -> AppErrorFixDestination {
        switch error {
        case .missingAPIKey:
            return .profileAI
        case .rateLimitExceeded:
            return .profileAI
        case .requestFailed:
            return .none
        }
    }

    static func destination(forMessage message: String) -> AppErrorFixDestination {
        let lower = message.lowercased()
        if lower.contains("api key") || lower.contains("missing key") || lower.contains("add your openai")
            || (lower.contains("key") && lower.contains("settings")) {
            return .profileAI
        }
        if lower.contains("rate limit") || lower.contains("too many requests") || lower.contains("429") {
            return .profileAI
        }
        if lower.contains("model preferences")
            || (lower.contains("model g") && lower.contains("settings"))
            || lower.contains("silence")
            || (lower.contains("register") && lower.contains("adjust")) {
            return .modelPreferences
        }
        if lower.contains("401") || lower.contains("403") || lower.contains("unauthorized") {
            return .profileAI
        }
        return .none
    }

    static func shortMessage(for error: Error) -> String {
        if let api = error as? RapAPIError, !api.inAppNotificationMessage.isEmpty {
            return api.inAppNotificationMessage
        }
        if let modelG = error as? ModelGLLMError {
            switch modelG {
            case .missingAPIKey:
                return "API key missing. Add your OpenAI key in Settings."
            case .rateLimitExceeded(let sec):
                let wait = sec ?? 60
                return "Too many requests. Wait \(wait)s and try again."
            case .requestFailed:
                return "Request failed. Check your connection and try again."
            }
        }
        return destination(forMessage: error.localizedDescription) == .profileAI
            ? "API issue. Check your key in Settings."
            : "Something went wrong. Try again."
    }

    @MainActor
    static func postInAppError(from error: Error) {
        let message = shortMessage(for: error)
        guard !message.isEmpty else { return }
        postInAppError(message: message, destination: destination(for: error))
    }

    @MainActor
    static func postInAppError(from error: RapAPIError) {
        let message = error.inAppNotificationMessage
        guard !message.isEmpty else { return }
        postInAppError(message: message, destination: destination(for: error))
    }

    @MainActor
    static func postInAppError(message: String, destination: AppErrorFixDestination) {
        guard !message.isEmpty else { return }
        var userInfo: [String: Any] = [InAppAPIErrorPayload.messageKey: message]
        if destination != .none {
            userInfo[InAppAPIErrorPayload.destinationKey] = destination.rawValue
        }
        NotificationCenter.default.post(name: .inAppAPIError, object: nil, userInfo: userInfo)
    }

    static func destination(from notification: Notification) -> AppErrorFixDestination {
        guard let raw = notification.userInfo?[InAppAPIErrorPayload.destinationKey] as? String,
              let dest = AppErrorFixDestination(rawValue: raw) else {
            if let msg = notification.userInfo?[InAppAPIErrorPayload.messageKey] as? String {
                return destination(forMessage: msg)
            }
            return .none
        }
        return dest
    }
}

extension RapAPIError {
    var fixDestination: AppErrorFixDestination {
        AppErrorRecovery.destination(for: self)
    }
}
