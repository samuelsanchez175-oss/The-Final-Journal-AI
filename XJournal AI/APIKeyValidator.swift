//
//  APIKeyValidator.swift
//  XJournal AI
//
//  Detects OpenAI vs Gemini vs Genius tokens and checks them against a free
//  provider endpoint (no generation cost).
//

import Foundation

nonisolated enum APIKeyKind: Equatable, Sendable {
    case openAIOrGemini
    case genius
}

nonisolated enum APIKeyProvider: Equatable, Sendable {
    case gemini
    case openAI
    case genius
    case unknown

    var displayName: String {
        switch self {
        case .gemini: return "Gemini (Google AI)"
        case .openAI: return "OpenAI"
        case .genius: return "Genius"
        case .unknown: return ""
        }
    }
}

nonisolated enum APIKeyValidator: Sendable {
    static func trimmed(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func provider(for raw: String) -> APIKeyProvider {
        let key = trimmed(raw)
        if key.hasPrefix("AIza") { return .gemini }
        if key.hasPrefix("sk-") { return .openAI }
        return .unknown
    }

    /// True once the paste looks complete enough to hit the network.
    static func looksReady(_ raw: String, kind: APIKeyKind) -> Bool {
        let key = trimmed(raw)
        guard !key.isEmpty else { return false }
        switch kind {
        case .openAIOrGemini:
            if key.hasPrefix("AIza") { return key.count >= 35 }
            if key.hasPrefix("sk-") { return key.count >= 40 }
            return false
        case .genius:
            if key.hasPrefix("AIza") || key.hasPrefix("sk-") { return false }
            return key.count >= 32
        }
    }

    static func wrongFieldMessage(for raw: String, kind: APIKeyKind) -> String? {
        let key = trimmed(raw)
        guard !key.isEmpty else { return nil }
        switch kind {
        case .openAIOrGemini:
            if key.hasPrefix("AIza") || key.hasPrefix("sk-") { return nil }
            if key.count >= 16 {
                return "This doesn't look like an OpenAI (sk-…) or Gemini (AIza…) key."
            }
            return nil
        case .genius:
            if key.hasPrefix("AIza") || key.hasPrefix("sk-") {
                return "This looks like an OpenAI or Gemini key. Paste it in the field above."
            }
            return nil
        }
    }

    /// Free check: models list for OpenAI/Gemini, a dummy search for Genius.
    static func validate(_ raw: String, kind: APIKeyKind, session: URLSession = .shared) async -> Bool {
        let key = trimmed(raw)
        guard !key.isEmpty else { return false }
        guard let request = validationRequest(for: key, kind: kind) else { return false }
        do {
            let (_, response) = try await session.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    static func validationRequest(for key: String, kind: APIKeyKind) -> URLRequest? {
        var request: URLRequest
        switch kind {
        case .openAIOrGemini:
            if key.hasPrefix("AIza") {
                guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models?key=\(key)") else {
                    return nil
                }
                request = URLRequest(url: url)
            } else if key.hasPrefix("sk-") {
                guard let url = URL(string: "https://api.openai.com/v1/models") else { return nil }
                request = URLRequest(url: url)
                request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
            } else {
                return nil
            }
        case .genius:
            guard let url = URL(string: "https://api.genius.com/search?q=ok") else { return nil }
            request = URLRequest(url: url)
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.timeoutInterval = 15
        return request
    }
}
