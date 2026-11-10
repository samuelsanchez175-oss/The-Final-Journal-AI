//
//  BYOKRequestRouterTests.swift
//  The Final Journal AITests
//
//  Unit tests for Task T14c: BYOKRequestRouter.
//

import XCTest
@testable import XJournal_AI

// MARK: - Mock URLSession for Router Testing

private final class MockBYOKURLSession: BYOKURLSessionProtocol {
    var nextData: Data = Data()
    var nextStatusCode: Int = 200
    var nextError: Error?
    var lastRequest: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        if let error = nextError {
            throw error
        }
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://mock.pennworkstudios.com")!,
            statusCode: nextStatusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (nextData, response)
    }
}

final class BYOKRequestRouterTests: XCTestCase {
    private var mockSession: MockBYOKURLSession!
    private var testDefaults: UserDefaults!
    private var router: BYOKRequestRouter!

    override func setUp() {
        super.setUp()
        mockSession = MockBYOKURLSession()
        testDefaults = UserDefaults(suiteName: "com.pennworkstudios.byok.tests")!
        testDefaults.removePersistentDomain(forName: "com.pennworkstudios.byok.tests")
        router = BYOKRequestRouter(session: mockSession, userDefaults: testDefaults)

        // Clear keys
        for p in BYOKProvider.allCases {
            try? BYOKKeychain.deleteKey(for: p)
        }
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "com.pennworkstudios.byok.tests")
        for p in BYOKProvider.allCases {
            try? BYOKKeychain.deleteKey(for: p)
        }
        super.tearDown()
    }

    func testProviderInference() {
        XCTAssertEqual(BYOKRequestRouter.inferProvider(for: "claude-opus-4-7"), .anthropic)
        XCTAssertEqual(BYOKRequestRouter.inferProvider(for: "claude-sonnet-5-5"), .anthropic)
        XCTAssertEqual(BYOKRequestRouter.inferProvider(for: "gpt-5"), .openai)
        XCTAssertEqual(BYOKRequestRouter.inferProvider(for: "gpt-4o-mini"), .openai)
        XCTAssertEqual(BYOKRequestRouter.inferProvider(for: "gemini-2.5-pro"), .google)
        XCTAssertNil(BYOKRequestRouter.inferProvider(for: "unsupported-model"))
    }

    func testResolveProviderAndModelExplicit() throws {
        let req = LLMRequest(
            messages: [LLMRequestMessage(role: .user, content: "hi")],
            model: "claude-opus-4-7"
        )
        let (provider, model) = try router.resolveProviderAndModel(for: req)
        XCTAssertEqual(provider, .anthropic)
        XCTAssertEqual(model, "claude-opus-4-7")
    }

    func testResolveProviderFeatureOverride() throws {
        testDefaults.set("gpt-5-reasoning", forKey: BYOKFeatureRole.planner.userDefaultsKey)
        let req = LLMRequest(
            messages: [LLMRequestMessage(role: .user, content: "plan")],
            feature: .planner
        )
        let (provider, model) = try router.resolveProviderAndModel(for: req)
        XCTAssertEqual(provider, .openai)
        XCTAssertEqual(model, "gpt-5-reasoning")
    }

    func testAnthropicDirectDispatch() async throws {
        try BYOKKeychain.save(key: "sk-ant-test-key-12345", for: .anthropic)

        let mockJSON = """
        {
            "content": [{"type": "text", "text": "Bentley rims and marble floors, countin' blessings."}],
            "usage": {"input_tokens": 15, "output_tokens": 10}
        }
        """
        mockSession.nextData = mockJSON.data(using: .utf8)!
        mockSession.nextStatusCode = 200

        let req = LLMRequest(
            messages: [
                LLMRequestMessage(role: .system, content: "You are Gunna."),
                LLMRequestMessage(role: .user, content: "Write a bar.")
            ],
            model: "claude-opus-4-7"
        )

        let response = try await router.send(request: req)
        XCTAssertEqual(response.provider, .anthropic)
        XCTAssertEqual(response.model, "claude-opus-4-7")
        XCTAssertEqual(response.text, "Bentley rims and marble floors, countin' blessings.")
        XCTAssertEqual(response.promptTokens, 15)
        XCTAssertEqual(response.completionTokens, 10)
        XCTAssertEqual(response.totalTokens, 25)

        // Verify request headers
        let lastReq = mockSession.lastRequest
        XCTAssertNotNil(lastReq)
        XCTAssertEqual(lastReq?.value(forHTTPHeaderField: "x-api-key"), "sk-ant-test-key-12345")
        XCTAssertEqual(lastReq?.value(forHTTPHeaderField: "anthropic-version"), "2023-06-01")
    }

    func testOpenAIDirectDispatch() async throws {
        try BYOKKeychain.save(key: "sk-proj-test-key-67890", for: .openai)

        let mockJSON = """
        {
            "choices": [{
                "message": {"role": "assistant", "content": "Hop inside the jet, never break a sweat."}
            }],
            "usage": {"prompt_tokens": 20, "completion_tokens": 9, "total_tokens": 29}
        }
        """
        mockSession.nextData = mockJSON.data(using: .utf8)!
        mockSession.nextStatusCode = 200

        let req = LLMRequest(
            messages: [LLMRequestMessage(role: .user, content: "Write a bar.")],
            model: "gpt-5"
        )

        let response = try await router.send(request: req)
        XCTAssertEqual(response.provider, .openai)
        XCTAssertEqual(response.model, "gpt-5")
        XCTAssertEqual(response.text, "Hop inside the jet, never break a sweat.")
        XCTAssertEqual(response.totalTokens, 29)

        let lastReq = mockSession.lastRequest
        XCTAssertEqual(lastReq?.value(forHTTPHeaderField: "Authorization"), "Bearer sk-proj-test-key-67890")
    }

    func testGoogleGeminiDirectDispatch() async throws {
        try BYOKKeychain.save(key: "AIzaSyTestGoogleKey", for: .google)

        let mockJSON = """
        {
            "candidates": [{
                "content": {
                    "parts": [{"text": "Patek on the wrist, ice on top of ice."}]
                }
            }],
            "usageMetadata": {"promptTokenCount": 14, "candidatesTokenCount": 9, "totalTokenCount": 23}
        }
        """
        mockSession.nextData = mockJSON.data(using: .utf8)!
        mockSession.nextStatusCode = 200

        let req = LLMRequest(
            messages: [LLMRequestMessage(role: .user, content: "Write a bar.")],
            model: "gemini-2.5-pro"
        )

        let response = try await router.send(request: req)
        XCTAssertEqual(response.provider, .google)
        XCTAssertEqual(response.model, "gemini-2.5-pro")
        XCTAssertEqual(response.text, "Patek on the wrist, ice on top of ice.")
        XCTAssertEqual(response.totalTokens, 23)

        let lastReq = mockSession.lastRequest
        XCTAssertTrue(lastReq?.url?.absoluteString.contains("key=AIzaSyTestGoogleKey") == true)
    }

    func testMissingAPIKeyThrowsError() async {
        let req = LLMRequest(
            messages: [LLMRequestMessage(role: .user, content: "hi")],
            model: "claude-opus-4-7"
        )
        do {
            _ = try await router.send(request: req)
            XCTFail("Expected missingAPIKey error")
        } catch let BYOKRequestRouterError.missingAPIKey(provider) {
            XCTAssertEqual(provider, .anthropic)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testHTTPErrorSanitizesAPIKey() async throws {
        let secretKey = "sk-ant-super-secret-key-to-redact"
        try BYOKKeychain.save(key: secretKey, for: .anthropic)

        mockSession.nextStatusCode = 401
        mockSession.nextData = "Invalid key: \(secretKey)".data(using: .utf8)!

        let req = LLMRequest(
            messages: [LLMRequestMessage(role: .user, content: "hi")],
            model: "claude-opus-4-7"
        )

        do {
            _ = try await router.send(request: req)
            XCTFail("Expected httpError")
        } catch let BYOKRequestRouterError.httpError(status, body) {
            XCTAssertEqual(status, 401)
            XCTAssertFalse(body.contains(secretKey), "Error body must NOT leak the secret key!")
            XCTAssertTrue(body.contains("[REDACTED_API_KEY]"), "Error body must redact the key")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
