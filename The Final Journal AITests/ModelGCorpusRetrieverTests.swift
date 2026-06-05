import XCTest
@testable import XJournal_AI

final class ModelGCorpusRetrieverTests: XCTestCase {
    private func store() throws -> ModelGCorpusStore {
        try ModelGCorpusStore(bundle: Bundle(for: ModelGCorpusRetrieverTests.self),
                              resource: "ModelGCorpus.fixture")
    }

    // Tone → corpus `themes` (the corpus theme vocab IS the tone vocab: confident/luxurious/…).
    func testRetrievesByToneAndCapsK() throws {
        let r = ModelGCorpusRetriever(store: try store())
        let out = r.retrieve(tones: ["confident"], draft: "garments worn", k: 5)
        XCTAssertFalse(out.exemplars.isEmpty)
        XCTAssertLessThanOrEqual(out.exemplars.count, 5)
        XCTAssertTrue(out.exemplars.allSatisfy { !$0.text.isEmpty })
    }

    // Topic → master-concept `tags` (corpus themes are tones, so topical retrieval goes via tags).
    // Fixture bar "Got garments…" carries tag "master-concept/wealth-brands".
    func testRetrievesByTopicTag() throws {
        let r = ModelGCorpusRetriever(store: try store())
        let out = r.retrieve(topics: ["wealth"], draft: "", k: 5)
        XCTAssertTrue(out.exemplars.contains { $0.text.contains("garments") },
                      "topic 'wealth' should hit the wealth-brands-tagged bar via bars(tag:)")
    }

    func testBrandVocabPullsAttributes() throws {
        let r = ModelGCorpusRetriever(store: try store())
        let out = r.retrieve(draft: "", brands: ["Birkin"], k: 5)
        XCTAssertEqual(out.vocab, ["Exotic Leathers"])
    }

    func testDedupesByNorm() throws {
        let r = ModelGCorpusRetriever(store: try store())
        let out = r.retrieve(tones: ["confident"], draft: "", k: 10)
        XCTAssertEqual(out.exemplars.map(\.norm).count, Set(out.exemplars.map(\.norm)).count)
    }

    // A known tone always grounds the result (the v4 floor), even when the draft matches nothing.
    func testKnownToneAlwaysGrounds() throws {
        let r = ModelGCorpusRetriever(store: try store())
        let out = r.retrieve(tones: ["confident"], topics: [], draft: "zxqwvun", k: 3)
        XCTAssertFalse(out.exemplars.isEmpty, "a known tone must always ground retrieval")
    }

    // Ghost semantics preserved: no tone + a draft that matches nothing → empty (so the
    // "is this word on-brand?" check stays meaningful).
    func testNoToneNoMatchStaysEmpty() throws {
        let r = ModelGCorpusRetriever(store: try store())
        let out = r.retrieve(draft: "zxqwvun", k: 1)
        XCTAssertTrue(out.exemplars.isEmpty, "no tone + no match must NOT force-ground (Ghost relies on this)")
    }
}
