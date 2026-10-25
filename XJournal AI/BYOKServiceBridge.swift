//
//  BYOKServiceBridge.swift
//  PennWork Studios
//
//  Task T14d: High-level generation service bridge for Bring-Your-Own-Key (BYOK).
//  Connects iOS app generation call sites directly to BYOKRequestRouter.
//  Zero local models. Bypasses OmniRoute in generation when user provides an API key.
//  Preserves strict file isolation: does NOT touch ModelG/ or ModelYou/.
//

import Foundation

public final class BYOKServiceBridge {
    public static let shared = BYOKServiceBridge()

    public let router: BYOKRequestRouter
    public let userDefaults: UserDefaults

    public init(
        router: BYOKRequestRouter = BYOKRequestRouter(),
        userDefaults: UserDefaults = .standard
    ) {
        self.router = router
        self.userDefaults = userDefaults
    }

    /// Primary entry point for text generation across Planner, Polish, and Sparkle tasks.
    /// Routes directly to frontier providers via BYOKRequestRouter when in .ownKey mode.
    public func generate(
        prompt: String,
        systemPrompt: String? = nil,
        feature: BYOKFeatureRole = .sparkle,
        temperature: Double = 0.7,
        maxTokens: Int = 1024
    ) async throws -> LLMResponse {
        var messages: [LLMRequestMessage] = []
        if let sys = systemPrompt, !sys.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            messages.append(LLMRequestMessage(role: .system, content: sys))
        }
        messages.append(LLMRequestMessage(role: .user, content: prompt))

        let request = LLMRequest(
            messages: messages,
            model: nil, // Will be resolved from feature override or keychain by router
            temperature: temperature,
            maxTokens: maxTokens,
            feature: feature
        )

        return try await router.send(request: request)
    }

    /// Convenience overload returning generated text directly.
    public func generateText(
        prompt: String,
        systemPrompt: String? = nil,
        feature: BYOKFeatureRole = .sparkle,
        temperature: Double = 0.7,
        maxTokens: Int = 1024
    ) async throws -> String {
        let response = try await generate(
            prompt: prompt,
            systemPrompt: systemPrompt,
            feature: feature,
            temperature: temperature,
            maxTokens: maxTokens
        )
        return response.text
    }

    /// Checks whether the user has at least one valid BYOK provider key configured.
    public func hasConfiguredKey() -> Bool {
        for provider in BYOKProvider.allCases {
            if let key = try? BYOKKeychain.loadKey(for: provider), !key.isEmpty {
                return true
            }
        }
        return false
    }

    /// Returns the currently active provider based on configured keys and settings.
    public func activeProvider() -> BYOKProvider? {
        for provider in BYOKProvider.allCases {
            if let key = try? BYOKKeychain.loadKey(for: provider), !key.isEmpty {
                return provider
            }
        }
        return nil
    }
}
