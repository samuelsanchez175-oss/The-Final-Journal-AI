//
//  BYOKServiceBridgeTests.swift
//  The Final Journal AITests
//
//  Unit tests for Task T14d: BYOKServiceBridge.
//

import XCTest
@testable import PennWork_Studios

private final class MockBridgeURLSession: BYOKURLSessionProtocol {
    var nextData: Data = Data()
    var nextStatusCode: Int = 200
    var lastRequest: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://mock.pennworkstudios.com")!,
            statusCode: nextStatusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (nextData, response)
    }
}

final class BYOKServiceBridgeTests: XCTestCase {
    private var mockSession: MockBridgeURLSession!
    private var testDefaults: UserDefaults!
    private var router: BYOKRequestRouter!
    private var bridge: BYOKServiceBridge!

    override func setUp() {
        super.setUp()
        mockSession = MockBridgeURLSession()
        testDefaults = UserDefaults(suiteName: "com.pennworkstudios.byok.bridge.tests")!
        testDefaults.removePersistentDomain(forName: "com.pennworkstudios.byok.bridge.tests")

        router = BYOKRequestRouter(session: mockSession, userDefaults: testDefaults)
        bridge = BYOKServiceBridge(router: router, userDefaults: testDefaults)

        for p in BYOKProvider.allCases {
            try? BYOKKeychain.deleteKey(for: p)
        }
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "com.pennworkstudios.byok.bridge.tests")
        for p in BYOKProvider.allCases {
            try? BYOKKeychain.deleteKey(for: p)
        }
        super.tearDown()
    }

    func testHasConfiguredKey() throws {
        XCTAssertFalse(bridge.hasConfiguredKey())
        XCTAssertNil(bridge.activeProvider())

        try BYOKKeychain.save(key: "sk-ant-test-bridge-key", for: .anthropic)
        XCTAssertTrue(bridge.hasConfiguredKey())
        XCTAssertEqual(bridge.activeProvider(), .anthropic)
    }

    func testGenerateConvenience() async throws {
        try BYOKKeychain.save(key: "sk-ant-test-bridge-key", for: .anthropic)

        let mockJSON = """
        {
            "content": [{"type": "text", "text": "Cash in the vault, lock down the city."}],
            "usage": {"input_tokens": 12, "output_tokens": 8}
        }
        """
        mockSession.nextData = mockJSON.data(using: .utf8)!

        let response = try await bridge.generate(
            prompt: "Give me two bars on cash.",
            systemPrompt: "You are Gunna.",
            feature: .sparkle
        )

        XCTAssertEqual(response.text, "Cash in the vault, lock down the city.")
        XCTAssertEqual(response.provider, .anthropic)
        XCTAssertEqual(response.model, "claude-opus-4-7")

        let textOnly = try await bridge.generateText(
            prompt: "Give me two bars on cash.",
            feature: .sparkle
        )
        XCTAssertEqual(textOnly, "Cash in the vault, lock down the city.")
    }
}
