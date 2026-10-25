//
//  BYOKSettingsViewTests.swift
//  The Final Journal AITests
//
//  Unit tests for Task T14b: BYOKSettingsViewModel, state transitions, key test ping, and pricing manifest.
//

import XCTest
@testable import XJournal_AI

final class BYOKSettingsViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        BYOKKeychain.resetAllForTesting()
        UserDefaults.standard.removeObject(forKey: "byok_model_source")
        UserDefaults.standard.removeObject(forKey: "byok_model_anthropic")
        UserDefaults.standard.removeObject(forKey: "byok_model_openai")
        UserDefaults.standard.removeObject(forKey: "byok_model_google")
        UserDefaults.standard.removeObject(forKey: "byok_override_planner")
        UserDefaults.standard.removeObject(forKey: "byok_override_polish")
        UserDefaults.standard.removeObject(forKey: "byok_override_sparkle")
    }

    override func tearDown() {
        BYOKKeychain.resetAllForTesting()
        super.tearDown()
    }

    func testDefaultStateIsFreeTier() {
        let vm = BYOKSettingsViewModel()
        XCTAssertEqual(vm.modelSource, .free)
        XCTAssertFalse(vm.hasAnthropicKey)
        XCTAssertFalse(vm.hasOpenAIKey)
        XCTAssertFalse(vm.hasGoogleKey)
    }

    func testManifestDefaultModelsAreFlagshipTiers() {
        let manifest = BYOKPricingManifest.load()
        XCTAssertEqual(manifest.providers["anthropic"]?.defaultModel, "claude-opus-4-7")
        XCTAssertEqual(manifest.providers["openai"]?.defaultModel, "gpt-5")
        XCTAssertEqual(manifest.providers["google"]?.defaultModel, "gemini-2.5-pro")

        let anthropicModels = manifest.providers["anthropic"]?.models ?? []
        XCTAssertTrue(anthropicModels.contains { $0.id == "claude-opus-4-7" })
        XCTAssertTrue(anthropicModels.contains { $0.id == "claude-sonnet-5-5" })
    }

    func testTestingValidKeySavesToKeychainAndFlipsToOwnKey() async {
        let vm = BYOKSettingsViewModel()
        vm.testPingHandler = { provider, key in
            return true
        }

        vm.anthropicKeyInput = "sk-ant-test-valid-key-999"
        await vm.testKey(for: .anthropic)

        XCTAssertEqual(vm.testStatus[.anthropic], .success("Key verified"))
        XCTAssertTrue(vm.hasAnthropicKey)
        XCTAssertEqual(BYOKKeychain.load(for: .anthropic), "sk-ant-test-valid-key-999")
        // Must auto-flip to ownKey
        XCTAssertEqual(vm.modelSource, .ownKey)
    }

    func testTestingInvalidKeyShowsErrorAndDoesNotSave() async {
        let vm = BYOKSettingsViewModel()
        vm.testPingHandler = { provider, key in
            return false
        }

        vm.openaiKeyInput = "sk-invalid-dummy"
        await vm.testKey(for: .openai)

        XCTAssertEqual(vm.testStatus[.openai], .error("Invalid API key"))
        XCTAssertFalse(vm.hasOpenAIKey)
        XCTAssertNil(BYOKKeychain.load(for: .openai))
        XCTAssertEqual(vm.modelSource, .free)
    }

    func testClearKeyRemovesFromKeychainAndFlipsBackToFreeWhenEmpty() throws {
        try BYOKKeychain.save(key: "valid-key-123", for: .google)
        let vm = BYOKSettingsViewModel()
        vm.refreshKeysFromKeychain()
        XCTAssertTrue(vm.hasGoogleKey)

        vm.clearKey(for: .google)
        XCTAssertFalse(vm.hasGoogleKey)
        XCTAssertNil(BYOKKeychain.load(for: .google))
        XCTAssertEqual(vm.modelSource, .free)
    }

    func testFeatureOverridesPersist() {
        let vm = BYOKSettingsViewModel()
        vm.plannerModel = "gpt-5-reasoning"
        vm.polishModel = "claude-opus-4-7"
        vm.sparkleModel = "claude-sonnet-5-5"

        let vm2 = BYOKSettingsViewModel()
        XCTAssertEqual(vm2.plannerModel, "gpt-5-reasoning")
        XCTAssertEqual(vm2.polishModel, "claude-opus-4-7")
        XCTAssertEqual(vm2.sparkleModel, "claude-sonnet-5-5")
    }
}
