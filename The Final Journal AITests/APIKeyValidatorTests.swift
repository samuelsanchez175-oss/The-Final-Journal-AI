import XCTest
@testable import XJournal_AI

final class APIKeyValidatorTests: XCTestCase {
    func testDetectsGeminiAndOpenAIPrefixes() {
        XCTAssertEqual(APIKeyValidator.provider(for: "AIzaSyAbc"), .gemini)
        XCTAssertEqual(APIKeyValidator.provider(for: "sk-proj-abc"), .openAI)
        XCTAssertEqual(APIKeyValidator.provider(for: "  sk-abc  "), .openAI)
        XCTAssertEqual(APIKeyValidator.provider(for: "not-a-key"), .unknown)
    }

    func testLooksReadyOnceThePasteIsLongEnough() {
        XCTAssertFalse(APIKeyValidator.looksReady("sk-short", kind: .openAIOrGemini))
        XCTAssertTrue(APIKeyValidator.looksReady(
            "sk-" + String(repeating: "x", count: 40),
            kind: .openAIOrGemini
        ))
        XCTAssertTrue(APIKeyValidator.looksReady(
            "AIza" + String(repeating: "y", count: 35),
            kind: .openAIOrGemini
        ))
        XCTAssertFalse(APIKeyValidator.looksReady("AIzaShort", kind: .openAIOrGemini))
        XCTAssertTrue(APIKeyValidator.looksReady(String(repeating: "G", count: 32), kind: .genius))
        XCTAssertFalse(APIKeyValidator.looksReady("short", kind: .genius))
    }

    func testWrongFieldWarnings() {
        XCTAssertNotNil(APIKeyValidator.wrongFieldMessage(for: "sk-abc", kind: .genius))
        XCTAssertNotNil(APIKeyValidator.wrongFieldMessage(for: "AIzaSyAbc", kind: .genius))
        XCTAssertNotNil(APIKeyValidator.wrongFieldMessage(
            for: String(repeating: "g", count: 20),
            kind: .openAIOrGemini
        ))
        XCTAssertNil(APIKeyValidator.wrongFieldMessage(for: "sk-abc", kind: .openAIOrGemini))
    }

    func testValidationRequestsUseTheMatchingProvider() {
        let gemini = APIKeyValidator.validationRequest(
            for: "AIza" + String(repeating: "y", count: 35),
            kind: .openAIOrGemini
        )
        XCTAssertTrue(gemini?.url?.host?.contains("googleapis.com") == true)

        let openAI = APIKeyValidator.validationRequest(
            for: "sk-" + String(repeating: "x", count: 40),
            kind: .openAIOrGemini
        )
        XCTAssertEqual(openAI?.url?.host, "api.openai.com")
        XCTAssertTrue(openAI?.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer sk-") == true)

        let genius = APIKeyValidator.validationRequest(
            for: String(repeating: "G", count: 32),
            kind: .genius
        )
        XCTAssertEqual(genius?.url?.host, "api.genius.com")
        XCTAssertTrue(genius?.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer ") == true)
    }
}
