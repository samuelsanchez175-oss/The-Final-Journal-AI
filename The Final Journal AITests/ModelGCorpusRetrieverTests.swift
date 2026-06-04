import XCTest
@testable import XJournal_AI

final class ModelGCorpusRetrieverTests: XCTestCase {
    private func store() throws -> ModelGCorpusStore {
        try ModelGCorpusStore(bundle: Bundle(for: ModelGCorpusRetrieverTests.self),
                              resource: "ModelGCorpus.fixture")
    }
    func testRetrievesByThemeAndCapsK() throws {
        let r = ModelGCorpusRetriever(store: try store())
        let out = r.retrieve(theme: "confident", draft: "garments worn", brands: [], k: 5)
        XCTAssertFalse(out.exemplars.isEmpty)
        XCTAssertLessThanOrEqual(out.exemplars.count, 5)
        XCTAssertTrue(out.exemplars.allSatisfy { !$0.text.isEmpty })
    }
    func testBrandVocabPullsAttributes() throws {
        let r = ModelGCorpusRetriever(store: try store())
        let out = r.retrieve(theme: nil, draft: "", brands: ["Birkin"], k: 5)
        XCTAssertEqual(out.vocab, ["Exotic Leathers"])
    }
    func testDedupesByNorm() throws {
        let r = ModelGCorpusRetriever(store: try store())
        let out = r.retrieve(theme: "confident", draft: "", brands: [], k: 10)
        XCTAssertEqual(out.exemplars.map(\.norm).count, Set(out.exemplars.map(\.norm)).count)
    }
}
