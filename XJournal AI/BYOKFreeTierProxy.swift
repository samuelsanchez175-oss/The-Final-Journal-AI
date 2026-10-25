//
//  BYOKFreeTierProxy.swift
//  PennWork Studios
//
//  Task T14e: Shared-tier rate-limited free proxy for iOS Bring-Your-Own-Key (BYOK).
//  Routes through OmniRoute proxy (https://api.omniroute.ai/v1/chat/completions)
//  with strict device-ID daily rate limiting (10 verses/day stored in UserDefaults).
//  Returns soft error when rate limit is exceeded.
//  Bypassed automatically when user configures their own provider key.
//  Preserves strict file isolation: does NOT touch ModelG/ or ModelYou/.
//

import Foundation

// MARK: - Free Tier Error

public enum BYOKFreeTierError: LocalizedError, Equatable {
    case dailyLimitExceeded
    case invalidEndpoint(String)
    case networkError(String)
    case httpError(statusCode: Int, body: String)
    case emptyResponse
    case decodingError(String)

    public var errorDescription: String? {
        switch self {
        case .dailyLimitExceeded:
            return "Daily free limit hit — add a key in Settings to keep sparkling today."
        case .invalidEndpoint(let url):
            return "Invalid OmniRoute proxy endpoint: \(url)"
        case .networkError(let message):
            return "Free tier network error: \(message)"
        case .httpError(let statusCode, let body):
            return "OmniRoute proxy HTTP \(statusCode): \(body)"
        case .emptyResponse:
            return "Received empty response from free-tier proxy."
        case .decodingError(let details):
            return "Failed to parse proxy response: \(details)"
        }
    }
}

// MARK: - Free Tier Proxy

public final class BYOKFreeTierProxy {
    public static let defaultEndpoint = "https://api.omniroute.ai/v1/chat/completions"
    public static let maxDailyGenerations = 10
    public static let defaultBudgetModel = "claude-sonnet-5-5"

    public static let deviceIdKey = "byok_free_tier_device_id"
    public static let usageCountPrefix = "byok_free_tier_count_"

    public let session: BYOKURLSessionProtocol
    public let userDefaults: UserDefaults
    public let endpoint: String
    public let budgetModel: String
    public let currentDateProvider: () -> Date

    public init(
        session: BYOKURLSessionProtocol = URLSession.shared,
        userDefaults: UserDefaults = .standard,
        endpoint: String = BYOKFreeTierProxy.defaultEndpoint,
        budgetModel: String = BYOKFreeTierProxy.defaultBudgetModel,
        currentDateProvider: @escaping () -> Date = { Date() }
    ) {
        self.session = session
        self.userDefaults = userDefaults
        self.endpoint = endpoint
        self.budgetModel = budgetModel
        self.currentDateProvider = currentDateProvider
    }

    // MARK: - Device ID

    /// Unique per-installation anonymous device identifier passed in X-Device-ID.
    public var deviceId: String {
        if let existing = userDefaults.string(forKey: Self.deviceIdKey), !existing.isEmpty {
            return existing
        }
        let fresh = UUID().uuidString
        userDefaults.set(fresh, forKey: Self.deviceIdKey)
        return fresh
    }

    // MARK: - Date Formatting & Daily Tracking

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    public func dateKey(for date: Date) -> String {
        return Self.dateFormatter.string(from: date)
    }

    public func dailyUsageCount(for date: Date? = nil) -> Int {
        let targetDate = date ?? currentDateProvider()
        let key = Self.usageCountPrefix + dateKey(for: targetDate)
        return userDefaults.integer(forKey: key)
    }

    public func remainingDailyGenerations(for date: Date? = nil) -> Int {
        let current = dailyUsageCount(for: date)
        return max(0, Self.maxDailyGenerations - current)
    }

    public func isRateLimited(for date: Date? = nil) -> Bool {
        return dailyUsageCount(for: date) >= Self.maxDailyGenerations
    }

    public func recordUsage(for date: Date? = nil) {
        let targetDate = date ?? currentDateProvider()
        let key = Self.usageCountPrefix + dateKey(for: targetDate)
        let current = userDefaults.integer(forKey: key)
        userDefaults.set(current + 1, forKey: key)
    }

    public func resetDailyUsage(for date: Date? = nil) {
        let targetDate = date ?? currentDateProvider()
        let key = Self.usageCountPrefix + dateKey(for: targetDate)
        userDefaults.removeObject(forKey: key)
    }

    // MARK: - Bypass Checking

    /// Checks whether requests should bypass this proxy and route directly to user's keys.
    public static func shouldBypass(
        userDefaults: UserDefaults = .standard,
        hasConfiguredKey: Bool
    ) -> Bool {
        let savedSource = userDefaults.string(forKey: "byok_model_source")
        if savedSource == "own_key" {
            return true
        }
        return hasConfiguredKey
    }

    // MARK: - Request Generation via OmniRoute

    public func generate(request: LLMRequest) async throws -> LLMResponse {
        // 1. Rate Limit Enforcement (10/day)
        if isRateLimited() {
            throw BYOKFreeTierError.dailyLimitExceeded
        }

        // 2. Validate URL Endpoint
        guard let url = URL(string: endpoint) else {
            throw BYOKFreeTierError.invalidEndpoint(endpoint)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
        urlRequest.setValue("PennWorkStudios-iOS/BYOKFreeTier", forHTTPHeaderField: "User-Agent")

        // 3. Serialize OpenAI-compatible Payload
        let wireMessages = request.messages.map { msg in
            ["role": msg.role.rawValue, "content": msg.content]
        }

        var payload: [String: Any] = [
            "model": budgetModel,
            "messages": wireMessages,
            "temperature": request.temperature ?? 0.7,
            "max_tokens": request.maxTokens ?? 1024
        ]

        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            throw BYOKFreeTierError.decodingError("Request body serialization failed: \(error.localizedDescription)")
        }

        // 4. Dispatch via URLSession
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw BYOKFreeTierError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BYOKFreeTierError.networkError("Invalid non-HTTP response received.")
        }

        // 5. Handle HTTP Status Codes
        if httpResponse.statusCode == 429 {
            throw BYOKFreeTierError.dailyLimitExceeded
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
            throw BYOKFreeTierError.httpError(statusCode: httpResponse.statusCode, body: errorBody)
        }

        // 6. Parse OpenAI-compatible Response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw BYOKFreeTierError.decodingError("Response was not valid JSON.")
        }

        guard let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let text = message["content"] as? String,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BYOKFreeTierError.emptyResponse
        }

        let usage = json["usage"] as? [String: Any]
        let promptTokens = usage?["prompt_tokens"] as? Int
        let completionTokens = usage?["completion_tokens"] as? Int
        let totalTokens = usage?["total_tokens"] as? Int

        // 7. Record Usage
        recordUsage()

        return LLMResponse(
            text: text,
            model: budgetModel,
            provider: .anthropic, // Free tier default budget provider tag
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            totalTokens: totalTokens
        )
    }
}
