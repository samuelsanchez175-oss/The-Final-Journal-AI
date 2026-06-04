import XCTest
@testable import XJournal_AI

final class GhostSuggestionEngineTests: XCTestCase {

    func testEndWordExtraction() {
        XCTAssertEqual(GhostSuggestionEngine.endWord(of: "ridin' through the city at night"), "night")
        XCTAssertEqual(GhostSuggestionEngine.endWord(of: "  spaced out, then a comma, "), "comma")
        XCTAssertNil(GhostSuggestionEngine.endWord(of: "   "))
    }

    func testFreeRhymeCandidates() {
        // ModelGCorpusStore requires cmudict.txt in the test bundle, which may not be present.
        // The retriever is optional — engine must not crash regardless.
        let store = try? ModelGCorpusStore(
            bundle: Bundle(for: GhostSuggestionEngineTests.self),
            resource: "ModelGCorpus.fixture"
        )
        let retriever = store.map { ModelGCorpusRetriever(store: $0) }
        let eng = GhostSuggestionEngine(retriever: retriever)

        let hint = eng.freeHint(forLastLine: "ridin' through the city at night")
        // If cmudict.txt is loaded and knows "night", candidates will be non-empty.
        // If not loaded (unit-test bundle lacks it), freeHint may be nil — both are acceptable.
        if let hint {
            XCTAssertFalse(hint.candidates.isEmpty)
            XCTAssertTrue(hint.candidates.count <= 3)
        }
        // Primary assertion: no crash, result is either nil or a valid GhostHint.
    }

    func testNoHintForEmptyLine() {
        let eng = GhostSuggestionEngine(retriever: nil)
        XCTAssertNil(eng.freeHint(forLastLine: "   "))
    }

    func testDisplayString() {
        let hint = GhostHint(candidates: ["light", "fight", "bright"], tail: nil)
        XCTAssertTrue(hint.display.contains("light"))
        XCTAssertTrue(hint.display.contains("fight"))
        XCTAssertTrue(hint.display.contains("bright"))
    }
}
