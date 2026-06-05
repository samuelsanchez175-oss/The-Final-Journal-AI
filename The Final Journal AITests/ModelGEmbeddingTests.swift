import XCTest
@testable import XJournal_AI

final class ModelGEmbeddingTests: XCTestCase {
    func testCosine() {
        XCTAssertEqual(VectorMath.cosine([1, 0], [1, 0]), 1.0, accuracy: 0.0001)
        XCTAssertEqual(VectorMath.cosine([1, 0], [0, 1]), 0.0, accuracy: 0.0001)
        XCTAssertEqual(VectorMath.cosine([1, 0], [-1, 0]), -1.0, accuracy: 0.0001)
        XCTAssertEqual(VectorMath.cosine([1, 2, 3], []), 0.0, accuracy: 0.0001)
        XCTAssertEqual(VectorMath.cosine([0, 0], [0, 0]), 0.0, accuracy: 0.0001)
    }

    func testRankByVectorsOrdersByCosine() {
        func bar(_ id: String) -> CorpusBar {
            CorpusBar(id: id, text: id, adlib: nil, norm: id, artist: nil, activeArtist: nil, song: nil, album: nil, section: nil, themes: [], tags: [], bpm: nil, scale: nil, tier: nil, concepts: [], context: [])
        }
        let bars = [bar("a"), bar("b"), bar("c")]
        let vectors: [String: [Float]] = ["a": [1, 0], "b": [0.9, 0.1], "c": [0, 1]]
        let ranked = ModelGEmbeddingIndex.rankByVectors(bars: bars, vectors: vectors, query: [1, 0], k: 2)
        XCTAssertEqual(ranked.map(\.id), ["a", "b"])
    }

    func testRetrieverLexicalWhenNoIndex() throws {
        let store = try ModelGCorpusStore(bundle: Bundle(for: ModelGEmbeddingTests.self), resource: "ModelGCorpus.fixture")
        let r = ModelGCorpusRetriever(store: store)
        XCTAssertFalse(r.retrieve(tones: ["confident"], draft: "garments", k: 5).exemplars.isEmpty)
    }
}
