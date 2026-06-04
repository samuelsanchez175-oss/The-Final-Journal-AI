import XCTest
@testable import XJournal_AI

final class ProviderRoutingTests: XCTestCase {
    func testProviderDetectionByKeyPrefix() {
        XCTAssertEqual(ModelGLLMService.provider(forKey: "AIzaSyXXXX"), .gemini)
        XCTAssertEqual(ModelGLLMService.provider(forKey: "sk-ant-api03-XXXX"), .anthropic)
        XCTAssertEqual(ModelGLLMService.provider(forKey: "sk-proj-XXXX"), .openAI)
        XCTAssertEqual(ModelGLLMService.provider(forKey: ""), .openAI)
    }
    func testPricingCoversAllThreeProviders() {
        let providers = Set(ProviderPricing.all.map(\.provider))
        XCTAssertTrue(providers.isSuperset(of: ["OpenAI", "Google", "Anthropic"]))
        XCTAssertTrue(ProviderPricing.all.allSatisfy { $0.perSuggestion.contains("$") })
    }
}
