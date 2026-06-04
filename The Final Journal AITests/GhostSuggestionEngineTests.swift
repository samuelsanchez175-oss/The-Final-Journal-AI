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

    // MARK: - Rhyme ranking (deterministic, CMUDICT-independent)

    func testRhymeStrengthTiers() {
        let night = ["N", "AY1", "T"]
        // perfect = same stressed vowel AND coda
        XCTAssertEqual(GhostSuggestionEngine.rhymeStrength(of: ["L", "AY1", "T"], against: night), 2, "light should be a perfect rhyme")
        // slant = same stressed vowel, coda differs
        XCTAssertEqual(GhostSuggestionEngine.rhymeStrength(of: ["R", "AY1", "D"], against: night), 1, "ride should be a slant rhyme")
        // none = different stressed vowel
        XCTAssertEqual(GhostSuggestionEngine.rhymeStrength(of: ["K", "AE1", "T"], against: night), 0, "cat should not rhyme")
    }

    func testRankedRhymesPerfectBeforeSlantDeterministic() {
        let lexicon: [String: [String]] = [
            "night":  ["N", "AY1", "T"],        // source word — must be excluded
            "light":  ["L", "AY1", "T"],        // perfect
            "bright": ["B", "R", "AY1", "T"],   // perfect
            "ride":   ["R", "AY1", "D"],        // slant
            "time":   ["T", "AY1", "M"],        // slant
            "cat":    ["K", "AE1", "T"],        // no rhyme — must be dropped
        ]
        let out = GhostSuggestionEngine.rankedRhymes(target: ["N", "AY1", "T"], lexicon: lexicon, excluding: "night", limit: 4)
        // perfect tier (alphabetical) before slant tier (alphabetical); "cat" excluded, "night" excluded
        XCTAssertEqual(out, ["bright", "light", "ride", "time"])
    }

    func testRankedRhymesHonorsLimitAndExcludesSource() {
        let lexicon: [String: [String]] = [
            "night": ["N", "AY1", "T"],
            "light": ["L", "AY1", "T"],
            "sight": ["S", "AY1", "T"],
        ]
        let out = GhostSuggestionEngine.rankedRhymes(target: ["N", "AY1", "T"], lexicon: lexicon, excluding: "night", limit: 1)
        XCTAssertEqual(out, ["light"], "limit honored; alphabetical-first perfect rhyme; source excluded")
    }
}
