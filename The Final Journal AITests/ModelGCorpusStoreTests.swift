import XCTest
@testable import XJournal_AI

final class ModelGCorpusStoreTests: XCTestCase {
    private func fixtureStore() throws -> ModelGCorpusStore {
        try ModelGCorpusStore(bundle: Bundle(for: ModelGCorpusStoreTests.self),
                              resource: "ModelGCorpus.fixture")
    }

    func testLoadsAndCounts() throws {
        let store = try fixtureStore()
        XCTAssertEqual(store.barCount, 2)
    }

    func testFilterByTheme() throws {
        let store = try fixtureStore()
        XCTAssertEqual(store.bars(theme: "confident").map(\.id), ["b1"])
    }

    func testKeywordSearchUsesNorm() throws {
        let store = try fixtureStore()
        XCTAssertEqual(store.bars(matching: "VVS").map(\.id), ["b2"])
    }

    func testConceptLookupAndBrandAttributes() throws {
        let store = try fixtureStore()
        XCTAssertEqual(store.concept(named: "birkin")?.category, "Brand")
        XCTAssertEqual(store.brandAttributes(brand: "Birkin"), ["Exotic Leathers"])
    }

    func testRealBundledCorpusLoads() throws {
        let store = try ModelGCorpusStore()
        XCTAssertGreaterThan(store.barCount, 12_000)
        XCTAssertFalse(store.bars(matching: "diamond").isEmpty)
    }
}
