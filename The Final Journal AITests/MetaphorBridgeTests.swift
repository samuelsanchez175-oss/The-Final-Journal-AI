import XCTest
@testable import XJournal_AI

private struct DictionaryEmbedding: LineEmbedding {
    let map: [String: [Float]]
    func embed(_ text: String) -> [Float]? {
        map[text.lowercased()]
    }
}

final class MetaphorBridgeTests: XCTestCase {

    func testGlassHalfEmptySeedsScarcityTerms() {
        let terms = MetaphorBridge.shared.extraSearchTerms(for: "glass half empty")
        XCTAssertTrue(terms.contains(where: { $0 == "bowl" || $0 == "mill" || $0 == "tank" || $0 == "dry" }))
    }

    func testJetFuelLowSeedsAviationPictures() {
        let terms = MetaphorBridge.shared.extraSearchTerms(for: "jet fuel low")
        XCTAssertTrue(
            terms.contains(where: { ["plane", "runway", "fumes", "tank", "altitude"].contains($0) }),
            "jet fuel low should pull aviation/scarcity pictures, not only the words jet/fuel"
        )
    }

    func testLexicalLabelFindsScarcityWithoutEmbeddings() {
        let bridge = MetaphorBridge(embedding: DictionaryEmbedding(map: [:]))
        XCTAssertEqual(bridge.label("the glass is half empty")?.id, "scarcity")
        XCTAssertEqual(bridge.label("last mill in the bowl")?.id, "scarcity")
    }

    func testInjectedVectorsRankSamePictureAboveUnrelatedFlex() {
        let scarcity = MetaphorPrototypeCatalog.prototype(id: "scarcity")!
        let luxury = MetaphorPrototypeCatalog.prototype(id: "luxury")!
        let map: [String: [Float]] = [
            scarcity.picture.lowercased(): [1, 0, 0],
            luxury.picture.lowercased(): [0, 1, 0],
            "money running low": [0.95, 0.05, 0],
            "last mill in the bowl": [0.9, 0.1, 0],
            "ice on my neck": [0.05, 0.95, 0],
        ]
        let bridge = MetaphorBridge(embedding: DictionaryEmbedding(map: map))
        let ranked = bridge.rerank(
            query: "money running low",
            lines: ["ice on my neck", "last mill in the bowl"]
        )
        XCTAssertEqual(ranked.first, "last mill in the bowl")
    }

    func testSeedTokensExpandBeyondExactWords() {
        let tokens = SimilarMeaningPipeline.seedTokens(for: "jet fuel low")
        XCTAssertTrue(tokens.contains { $0 == "plane" || $0 == "fumes" || $0 == "runway" || $0 == "tank" })
    }
}
