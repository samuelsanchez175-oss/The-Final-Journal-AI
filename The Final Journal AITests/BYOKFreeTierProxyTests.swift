//
//  BYOKFreeTierProxyTests.swift
//  The Final Journal AITests
//
//  Unit tests for Task T14e: Shared-tier rate-limited free proxy (OmniRoute).
//  Validates:
//  - Device ID persistence in UserDefaults
//  - 10 verses/day rate limiting and date rollover
//  - Soft error message when rate limit hit
//  - Proxy endpoint URL and request payload serialization
//  - Direct bypass when user has configured own key
//

import XCTest
@testable import XJournal_AI

// MARK: - Mock URLSession for Free Tier Testing

private final class MockFreeTierURLSession: BYOKURLSessionProtocol {
    var statusCode: Int
    var responseBody: String
    var capturedRequest: URLRequest?
    var injectedError: Error?

    init(statusCode: Int = 200, responseBody: String = "{}") {
        self.statusCode = statusCode
        self.responseBody = responseBody
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequest = request
        if let err = injectedError {
            throw err
        }
        let data = responseBody.data(using: .utf8) ?? Data()
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://api.omniroute.ai/v1/chat/completions")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data, response)
    }
}

final class BYOKFreeTierProxyTests: XCTestCase {
    private var testUserDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "test_byok_free_tier_\(UUID().uuidString)"
        testUserDefaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    // MARK: - Device ID Tests

    func testDeviceIdGeneratesAndPersists() {
        let proxy1 = BYOKFreeTierProxy(userDefaults: testUserDefaults)
        let id1 = proxy1.deviceId
        XCTAssertFalse(id1.isEmpty)

        // Second read from same defaults returns identical device ID
        let proxy2 = BYOKFreeTierProxy(userDefaults: testUserDefaults)
        let id2 = proxy2.deviceId
        XCTAssertEqual(id1, id2)
    }

    // MARK: - Rate Limiting & Tracking Tests

    func testDailyRateLimitCounter() {
        let proxy = BYOKFreeTierProxy(userDefaults: testUserDefaults)
        XCTAssertEqual(proxy.dailyUsageCount(), 0)
        XCTAssertEqual(proxy.remainingDailyGenerations(), 10)
        XCTAssertFalse(proxy.isRateLimited())

        // Record 5 usages
        for _ in 1...5 {
            proxy.recordUsage()
        }
        XCTAssertEqual(proxy.dailyUsageCount(), 5)
        XCTAssertEqual(proxy.remainingDailyGenerations(), 5)
        XCTAssertFalse(proxy.isRateLimited())

        // Record 5 more usages to hit limit of 10
        for _ in 1...5 {
            proxy.recordUsage()
        }
        XCTAssertEqual(proxy.dailyUsageCount(), 10)
        XCTAssertEqual(proxy.remainingDailyGenerations(), 0)
        XCTAssertTrue(proxy.isRateLimited())
    }

    func testSoftErrorWhenRateLimitExceeded() async {
        let proxy = BYOKFreeTierProxy(userDefaults: testUserDefaults)

        // Exhaust quota
        for _ in 1...10 {
            proxy.recordUsage()
        }
        XCTAssertTrue(proxy.isRateLimited())

        let request = LLMRequest(
            messages: [LLMRequestMessage(role: .user, content: "Give me 8 bars")]
        )

        do {
            _ = try await proxy.generate(request: request)
            XCTFail("Expected dailyLimitExceeded error")
        } catch let error as BYOKFreeTierError {
            XCTAssertEqual(error, .dailyLimitExceeded)
            XCTAssertEqual(
                error.localizedDescription,
                "Daily free limit hit — add a key in Settings to keep sparkling today."
            )
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testResetDailyUsage() {
        let proxy = BYOKFreeTierProxy(userDefaults: testUserDefaults)
        for _ in 1...8 {
            proxy.recordUsage()
        }
        XCTAssertEqual(proxy.dailyUsageCount(), 8)

        proxy.resetDailyUsage()
        XCTAssertEqual(proxy.dailyUsageCount(), 0)
        XCTAssertEqual(proxy.remainingDailyGenerations(), 10)
    }

    func testDayTransitionRollover() {
        var currentDate = Date(timeIntervalSince1970: 1761400000) // Day 1
        let proxy = BYOKFreeTierProxy(
            userDefaults: testUserDefaults,
            currentDateProvider: { currentDate }
        )

        for _ in 1...10 {
            proxy.recordUsage()
        }
        XCTAssertTrue(proxy.isRateLimited())

        // Fast forward 24 hours (86400 seconds) -> Day 2
        currentDate = currentDate.addingTimeInterval(86400)
        XCTAssertFalse(proxy.isRateLimited())
        XCTAssertEqual(proxy.dailyUsageCount(), 0)
        XCTAssertEqual(proxy.remainingDailyGenerations(), 10)
    }

    // MARK: - OmniRoute Proxy Network Tests

    func testOmniRouteProxySuccessRequest() async throws {
        let mockResponseJSON = """
        {
          "id": "chatcmpl-test-123",
          "object": "chat.completion",
          "model": "claude-sonnet-5-5",
          "choices": [
            {
              "index": 0,
              "message": {
                "role": "assistant",
                "content": "on the block, stackin' knots, pushin' weight, in the mercedes"
              },
              "finish_reason": "stop"
            }
          ],
          "usage": {
            "prompt_tokens": 42,
            "completion_tokens": 15,
            "total_tokens": 57
          }
        }
        """

        let mockSession = MockFreeTierURLSession(
            statusCode: 200,
            responseBody: mockResponseJSON
        )

        let proxy = BYOKFreeTierProxy(
            session: mockSession,
            userDefaults: testUserDefaults
        )

        let request = LLMRequest(
            messages: [
                LLMRequestMessage(role: .system, content: "You are an executive ghostwriter."),
                LLMRequestMessage(role: .user, content: "Write a Gunna couplet")
            ],
            temperature: 0.72,
            maxTokens: 500
        )

        let response = try await proxy.generate(request: request)

        XCTAssertEqual(response.text, "on the block, stackin' knots, pushin' weight, in the mercedes")
        XCTAssertEqual(response.model, "claude-sonnet-5-5")
        XCTAssertEqual(response.promptTokens, 42)
        XCTAssertEqual(response.completionTokens, 15)

        // Verify request headers and URL
        guard let sentRequest = mockSession.capturedRequest else {
            return XCTFail("No request captured")
        }
        XCTAssertEqual(sentRequest.url?.absoluteString, "https://api.omniroute.ai/v1/chat/completions")
        XCTAssertEqual(sentRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(sentRequest.value(forHTTPHeaderField: "X-Device-ID"), proxy.deviceId)

        // Verify usage was recorded
        XCTAssertEqual(proxy.dailyUsageCount(), 1)
    }

    func testProxyHTTP429MapsToDailyLimitExceeded() async {
        let mockSession = MockFreeTierURLSession(
            statusCode: 429,
            responseBody: "Rate limit exceeded"
        )
        let proxy = BYOKFreeTierProxy(
            session: mockSession,
            userDefaults: testUserDefaults
        )

        let request = LLMRequest(
            messages: [LLMRequestMessage(role: .user, content: "Verse")]
        )

        do {
            _ = try await proxy.generate(request: request)
            XCTFail("Expected dailyLimitExceeded")
        } catch let error as BYOKFreeTierError {
            XCTAssertEqual(error, .dailyLimitExceeded)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Bypass Tests

    func testShouldBypassFreeTier() {
        // 1. Own key setting enabled -> bypass = true
        testUserDefaults.set("own_key", forKey: "byok_model_source")
        XCTAssertTrue(BYOKFreeTierProxy.shouldBypass(userDefaults: testUserDefaults, hasConfiguredKey: false))

        // 2. Free setting but user has key -> bypass = true
        testUserDefaults.set("free", forKey: "byok_model_source")
        XCTAssertTrue(BYOKFreeTierProxy.shouldBypass(userDefaults: testUserDefaults, hasConfiguredKey: true))

        // 3. Free setting and user has NO key -> bypass = false (use free tier proxy)
        testUserDefaults.set("free", forKey: "byok_model_source")
        XCTAssertFalse(BYOKFreeTierProxy.shouldBypass(userDefaults: testUserDefaults, hasConfiguredKey: false))
    }

    // MARK: - ServiceBridge Integration Tests

    func testServiceBridgeDispatchesToFreeProxyWhenFreeMode() async throws {
        testUserDefaults.set("free", forKey: "byok_model_source")

        let mockResponseJSON = """
        {
          "choices": [
            {
              "message": { "content": "Free proxy bar response" }
            }
          ]
        }
        """
        let mockSession = MockFreeTierURLSession(statusCode: 200, responseBody: mockResponseJSON)
        let freeProxy = BYOKFreeTierProxy(session: mockSession, userDefaults: testUserDefaults)
        let router = BYOKRequestRouter(session: mockSession, userDefaults: testUserDefaults)

        let bridge = BYOKServiceBridge(
            router: router,
            freeTierProxy: freeProxy,
            userDefaults: testUserDefaults
        )

        let text = try await bridge.generateText(prompt: "Write a line")
        XCTAssertEqual(text, "Free proxy bar response")
        XCTAssertEqual(freeProxy.dailyUsageCount(), 1)
    }
}
