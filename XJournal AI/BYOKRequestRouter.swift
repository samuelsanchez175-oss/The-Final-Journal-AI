//
//  BYOKRequestRouter.swift
//  PennWork Studios
//
//  Task T14c: Direct frontier LLM request router for Bring-Your-Own-Key (BYOK).
//  Direct URLSession dispatch for Anthropic Messages, OpenAI Chat Completions, and Google Gemini API.
//  Zero local models. Zero OmniRoute proxy in generation.
//  Keys retrieved securely from BYOKKeychain. Never logs API keys.
//

import Foundation

// MARK: - Protocols for Testing & Injection

public protocol BYOKURLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: BYOKURLSessionProtocol {}

// MARK: - Shared LLM Data Models

public struct LLMRequestMessage: Codable, Equatable {
    public enum Role: String, Codable {
        case system
        case user
        case assistant
    }

    public let role: Role
    public let content: String

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

public struct LLMRequest: Codable, Equatable {
    public let messages: [LLMRequestMessage]
    public let model: String?
    public let temperature: Double?
    public let maxTokens: Int?
    public let feature: BYOKFeatureRole?

    public init(
        messages: [LLMRequestMessage],
        model: String? = nil,
        temperature: Double? = 0.7,
        maxTokens: Int? = 1024,
        feature: BYOKFeatureRole? = nil
    ) {
        self.messages = messages
        self.model = model
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.feature = feature
    }
}

public struct LLMResponse: Codable, Equatable {
    public let text: String
    public let model: String
    public let provider: BYOKProvider
    public let promptTokens: Int?
    public let completionTokens: Int?
    public let totalTokens: Int?

    public init(
        text: String,
        model: String,
        provider: BYOKProvider,
        promptTokens: Int? = nil,
        completionTokens: Int? = nil,
        totalTokens: Int? = nil
    ) {
        self.text = text
        self.model = model
        self.provider = provider
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

// MARK: - Errors

public enum BYOKRequestRouterError: LocalizedError, Equatable {
    case missingAPIKey(BYOKProvider)
    case invalidEndpoint(String)
    case serializationError(String)
    case httpError(statusCode: Int, body: String)
    case emptyResponse
    case unsupportedModel(String)

    public var errorDescription: String? {
        switch self {
        case .missingAPIKey(let provider):
            return "No API key configured for \(provider.displayName). Please add one in Settings."
        case .invalidEndpoint(let url):
            return "Invalid API endpoint: \(url)"
        case .serializationError(let details):
            return "Failed to serialize request body: \(details)"
        case .httpError(let statusCode, let body):
            return "API returned HTTP \(statusCode): \(body)"
        case .emptyResponse:
            return "Received empty text response from model provider."
        case .unsupportedModel(let model):
            return "Unsupported model identifier: \(model)"
        }
    }
}

// MARK: - BYOK Request Router

public final class BYOKRequestRouter {
    public let session: BYOKURLSessionProtocol
    public let userDefaults: UserDefaults

    public init(session: BYOKURLSessionProtocol = URLSession.shared, userDefaults: UserDefaults = .standard) {
        self.session = session
        self.userDefaults = userDefaults
    }

    // MARK: - Provider & Model Resolution

    /// Infers the appropriate BYOKProvider for a given model identifier.
    public static func inferProvider(for model: String) -> BYOKProvider? {
        let m = model.lowercased()
        if m.hasPrefix("claude-") {
            return .anthropic
        } else if m.hasPrefix("gpt-") || m.hasPrefix("o1") || m.hasPrefix("o3") {
            return .openai
        } else if m.hasPrefix("gemini-") {
            return .google
        }
        return nil
    }

    /// Resolves the model and provider for a request based on explicit model, feature override, or Keychain availability.
    public func resolveProviderAndModel(for request: LLMRequest) throws -> (BYOKProvider, String) {
        // 1. Explicit model on the request
        if let explicitModel = request.model, !explicitModel.isEmpty {
            guard let provider = Self.inferProvider(for: explicitModel) else {
                throw BYOKRequestRouterError.unsupportedModel(explicitModel)
            }
            return (provider, explicitModel)
        }

        // 2. Feature role override (e.g. planner, polish, sparkle)
        if let feature = request.feature,
           let featureModel = userDefaults.string(forKey: feature.userDefaultsKey),
           !featureModel.isEmpty {
            if let provider = Self.inferProvider(for: featureModel) {
                return (provider, featureModel)
            }
        }

        // 3. Check configured provider keys in order of priority (Anthropic -> OpenAI -> Google)
        let manifest = BYOKPricingManifest.loadFromBundle()
        for provider in BYOKProvider.allCases {
            if let key = try? BYOKKeychain.loadKey(for: provider), !key.isEmpty {
                let defaultModel = manifest.providers[provider.rawValue]?.defaultModel
                    ?? (provider == .anthropic ? "claude-opus-4-7" : (provider == .openai ? "gpt-5" : "gemini-2.5-pro"))
                let savedModel = userDefaults.string(forKey: "com.pennworkstudios.byok.model.\(provider.rawValue)") ?? defaultModel
                return (provider, savedModel)
            }
        }

        // Default to Anthropic Opus 4.7 if no key exists yet
        throw BYOKRequestRouterError.missingAPIKey(.anthropic)
    }

    // MARK: - Main Dispatch

    /// Sends an LLMRequest directly to the target frontier provider via URLSession.
    public func send(request: LLMRequest) async throws -> LLMResponse {
        let (provider, model) = try resolveProviderAndModel(for: request)
        guard let apiKey = try? BYOKKeychain.loadKey(for: provider), !apiKey.isEmpty else {
            throw BYOKRequestRouterError.missingAPIKey(provider)
        }

        let urlRequest = try buildURLRequest(provider: provider, model: model, apiKey: apiKey, request: request)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BYOKRequestRouterError.httpError(statusCode: -1, body: "Non-HTTP response received")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "(Unable to decode response body)"
            // Sanitize potential key leakage in error response
            let sanitized = errorBody.replacingOccurrences(of: apiKey, with: "[REDACTED_API_KEY]")
            throw BYOKRequestRouterError.httpError(statusCode: httpResponse.statusCode, body: sanitized)
        }

        return try parseResponse(data: data, provider: provider, model: model)
    }

    // MARK: - HTTP Request Builders

    public func buildURLRequest(
        provider: BYOKProvider,
        model: String,
        apiKey: String,
        request: LLMRequest
    ) throws -> URLRequest {
        switch provider {
        case .anthropic:
            return try buildAnthropicRequest(model: model, apiKey: apiKey, request: request)
        case .openai:
            return try buildOpenAIRequest(model: model, apiKey: apiKey, request: request)
        case .google:
            return try buildGoogleRequest(model: model, apiKey: apiKey, request: request)
        }
    }

    // MARK: Anthropic Messages API
    private func buildAnthropicRequest(model: String, apiKey: String, request: LLMRequest) throws -> URLRequest {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw BYOKRequestRouterError.invalidEndpoint("https://api.anthropic.com/v1/messages")
        }

        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlReq.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        // Split system message from conversation messages
        var systemContent: String?
        var messagesPayload: [[String: String]] = []

        for msg in request.messages {
            if msg.role == .system {
                systemContent = (systemContent == nil) ? msg.content : "\(systemContent!)\n\(msg.content)"
            } else {
                let roleStr = (msg.role == .assistant) ? "assistant" : "user"
                messagesPayload.append(["role": roleStr, "content": msg.content])
            }
        }

        var body: [String: Any] = [
            "model": model,
            "max_tokens": request.maxTokens ?? 1024,
            "messages": messagesPayload
        ]

        if let systemContent = systemContent, !systemContent.isEmpty {
            body["system"] = systemContent
        }
        if let temp = request.temperature {
            body["temperature"] = temp
        }

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            throw BYOKRequestRouterError.serializationError("Anthropic request payload")
        }
        urlReq.httpBody = httpBody
        return urlReq
    }

    // MARK: OpenAI Chat Completions API
    private func buildOpenAIRequest(model: String, apiKey: String, request: LLMRequest) throws -> URLRequest {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw BYOKRequestRouterError.invalidEndpoint("https://api.openai.com/v1/chat/completions")
        }

        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let messagesPayload: [[String: String]] = request.messages.map { msg in
            ["role": msg.role.rawValue, "content": msg.content]
        }

        var body: [String: Any] = [
            "model": model,
            "messages": messagesPayload
        ]

        if let temp = request.temperature {
            body["temperature"] = temp
        }
        if let maxTokens = request.maxTokens {
            body["max_tokens"] = maxTokens
        }

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            throw BYOKRequestRouterError.serializationError("OpenAI request payload")
        }
        urlReq.httpBody = httpBody
        return urlReq
    }

    // MARK: Google Gemini API
    private func buildGoogleRequest(model: String, apiKey: String, request: LLMRequest) throws -> URLRequest {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)") else {
            throw BYOKRequestRouterError.invalidEndpoint("https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")
        }

        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var contentsPayload: [[String: Any]] = []
        var systemInstructionPayload: [String: Any]?

        for msg in request.messages {
            if msg.role == .system {
                systemInstructionPayload = [
                    "parts": [["text": msg.content]]
                ]
            } else {
                let roleStr = (msg.role == .assistant) ? "model" : "user"
                contentsPayload.append([
                    "role": roleStr,
                    "parts": [["text": msg.content]]
                ])
            }
        }

        var body: [String: Any] = [
            "contents": contentsPayload
        ]

        if let sys = systemInstructionPayload {
            body["system_instruction"] = sys
        }

        var genConfig: [String: Any] = [:]
        if let temp = request.temperature {
            genConfig["temperature"] = temp
        }
        if let maxTokens = request.maxTokens {
            genConfig["maxOutputTokens"] = maxTokens
        }
        if !genConfig.isEmpty {
            body["generationConfig"] = genConfig
        }

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            throw BYOKRequestRouterError.serializationError("Google Gemini request payload")
        }
        urlReq.httpBody = httpBody
        return urlReq
    }

    // MARK: - Response Parsing

    public func parseResponse(data: Data, provider: BYOKProvider, model: String) throws -> LLMResponse {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw BYOKRequestRouterError.emptyResponse
        }

        switch provider {
        case .anthropic:
            return try parseAnthropicResponse(json: json, model: model)
        case .openai:
            return try parseOpenAIResponse(json: json, model: model)
        case .google:
            return try parseGoogleResponse(json: json, model: model)
        }
    }

    private func parseAnthropicResponse(json: [String: Any], model: String) throws -> LLMResponse {
        guard let contentArray = json["content"] as? [[String: Any]] else {
            throw BYOKRequestRouterError.emptyResponse
        }

        let fullText = contentArray.compactMap { $0["text"] as? String }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !fullText.isEmpty else {
            throw BYOKRequestRouterError.emptyResponse
        }

        var promptTokens: Int?
        var completionTokens: Int?
        var totalTokens: Int?
        if let usage = json["usage"] as? [String: Any] {
            promptTokens = usage["input_tokens"] as? Int
            completionTokens = usage["output_tokens"] as? Int
            if let p = promptTokens, let c = completionTokens {
                totalTokens = p + c
            }
        }

        return LLMResponse(
            text: fullText,
            model: model,
            provider: .anthropic,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            totalTokens: totalTokens
        )
    }

    private func parseOpenAIResponse(json: [String: Any], model: String) throws -> LLMResponse {
        guard let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw BYOKRequestRouterError.emptyResponse
        }

        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw BYOKRequestRouterError.emptyResponse
        }

        var promptTokens: Int?
        var completionTokens: Int?
        var totalTokens: Int?
        if let usage = json["usage"] as? [String: Any] {
            promptTokens = usage["prompt_tokens"] as? Int
            completionTokens = usage["completion_tokens"] as? Int
            totalTokens = usage["total_tokens"] as? Int
        }

        return LLMResponse(
            text: trimmed,
            model: model,
            provider: .openai,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            totalTokens: totalTokens
        )
    }

    private func parseGoogleResponse(json: [String: Any], model: String) throws -> LLMResponse {
        guard let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            throw BYOKRequestRouterError.emptyResponse
        }

        let fullText = parts.compactMap { $0["text"] as? String }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !fullText.isEmpty else {
            throw BYOKRequestRouterError.emptyResponse
        }

        var promptTokens: Int?
        var completionTokens: Int?
        var totalTokens: Int?
        if let usage = json["usageMetadata"] as? [String: Any] {
            promptTokens = usage["promptTokenCount"] as? Int
            completionTokens = usage["candidatesTokenCount"] as? Int
            totalTokens = usage["totalTokenCount"] as? Int
        }

        return LLMResponse(
            text: fullText,
            model: model,
            provider: .google,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            totalTokens: totalTokens
        )
    }
}
