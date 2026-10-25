//
//  BYOKKeychainTests.swift
//  The Final Journal AITests
//
//  Unit tests for Task T14a: BYOKKeychain CRUD, provider enumeration, and isolation.
//

import XCTest
@testable import XJournal_AI

final class BYOKKeychainTests: XCTestCase {

    override func setUp() {
        super.setUp()
        BYOKKeychain.resetAllForTesting()
    }

    override func tearDown() {
        BYOKKeychain.resetAllForTesting()
        super.tearDown()
    }

    func testRoundTripSaveLoadDeleteAnthropic() throws {
        XCTAssertNil(BYOKKeychain.load(for: .anthropic))

        let testKey = "sk-ant-api03-test-token-12345"
        try BYOKKeychain.save(key: testKey, for: .anthropic)

        let loaded = BYOKKeychain.load(for: .anthropic)
        XCTAssertEqual(loaded, testKey)

        try BYOKKeychain.delete(for: .anthropic)
        XCTAssertNil(BYOKKeychain.load(for: .anthropic))
    }

    func testRoundTripSaveLoadDeleteOpenAI() throws {
        XCTAssertNil(BYOKKeychain.load(for: .openai))

        let testKey = "sk-proj-openai-test-token-67890"
        try BYOKKeychain.save(key: testKey, for: .openai)

        let loaded = BYOKKeychain.load(for: .openai)
        XCTAssertEqual(loaded, testKey)

        try BYOKKeychain.delete(for: .openai)
        XCTAssertNil(BYOKKeychain.load(for: .openai))
    }

    func testRoundTripSaveLoadDeleteGoogle() throws {
        XCTAssertNil(BYOKKeychain.load(for: .google))

        let testKey = "AIzaSyTestGoogleGeminiKey123"
        try BYOKKeychain.save(key: testKey, for: .google)

        let loaded = BYOKKeychain.load(for: .google)
        XCTAssertEqual(loaded, testKey)

        try BYOKKeychain.delete(for: .google)
        XCTAssertNil(BYOKKeychain.load(for: .google))
    }

    func testUpdateExistingKeyOverwritesValue() throws {
        try BYOKKeychain.save(key: "initial-key", for: .anthropic)
        XCTAssertEqual(BYOKKeychain.load(for: .anthropic), "initial-key")

        try BYOKKeychain.save(key: "updated-key", for: .anthropic)
        XCTAssertEqual(BYOKKeychain.load(for: .anthropic), "updated-key")
    }

    func testTrimmingWhitespaceOnSave() throws {
        try BYOKKeychain.save(key: "  sk-with-spaces  \n", for: .openai)
        XCTAssertEqual(BYOKKeychain.load(for: .openai), "sk-with-spaces")
    }

    func testProviderEnumerationMatchesSavedKeys() throws {
        XCTAssertTrue(BYOKKeychain.providers().isEmpty)

        try BYOKKeychain.save(key: "key-1", for: .anthropic)
        var current = BYOKKeychain.providers()
        XCTAssertEqual(current, [.anthropic])

        try BYOKKeychain.save(key: "key-2", for: .google)
        current = BYOKKeychain.providers()
        XCTAssertTrue(current.contains(.anthropic))
        XCTAssertTrue(current.contains(.google))
        XCTAssertFalse(current.contains(.openai))
        XCTAssertEqual(current.count, 2)

        try BYOKKeychain.delete(for: .anthropic)
        current = BYOKKeychain.providers()
        XCTAssertEqual(current, [.google])

        try BYOKKeychain.delete(for: .google)
        XCTAssertTrue(BYOKKeychain.providers().isEmpty)
    }
}
