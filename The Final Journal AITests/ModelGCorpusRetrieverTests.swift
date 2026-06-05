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

    // MARK: - Integration against the REAL bundled corpus (the actual vault data the app ships)

    /// Proves the v4 retrieval path returns relevant, on-tone, real lyric exemplars from the
    /// shipped 6,376-bar corpus — not just the 2-bar fixture.
    func testRealCorpusReturnsOnToneExemplars() throws {
        guard let store = ModelGCorpusStore.shared else { throw XCTSkip("bundled corpus unavailable in test host") }
        let r = ModelGCorpusRetriever(store: store)
        let out = r.retrieve(tones: ["luxurious"], topics: ["wealth", "money"],
                             draft: "diamonds on my wrist, foreign car in the lot", k: 8)
        XCTAssertFalse(out.exemplars.isEmpty, "luxurious draft should yield exemplars from the real corpus")
        XCTAssertLessThanOrEqual(out.exemplars.count, 8)
        XCTAssertTrue(out.exemplars.allSatisfy { !$0.text.isEmpty && !$0.norm.isEmpty }, "exemplars are real lyrics")
        XCTAssertTrue(out.exemplars.contains { $0.themes.contains("luxurious") }, "at least one exemplar carries the requested tone")
    }

    /// On the real corpus, a known tone always grounds retrieval (the v4 floor) even when the
    /// draft/topics match nothing — so v4 never silently degrades to an empty prompt.
    func testRealCorpusToneFloorNeverEmpty() throws {
        guard let store = ModelGCorpusStore.shared else { throw XCTSkip("bundled corpus unavailable in test host") }
        let r = ModelGCorpusRetriever(store: store)
        let out = r.retrieve(tones: ["confident"], topics: [], draft: "zzqxv mxqzpf unmatchable", k: 5)
        XCTAssertFalse(out.exemplars.isEmpty, "a known tone must always ground retrieval on the real corpus")
    }
}
