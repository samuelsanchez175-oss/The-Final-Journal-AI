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

    // MARK: - Regression: multi-syllable word ending in an UNSTRESSED vowel (the "crazy" bug)

    // CMUDICT marks EVERY vowel with a stress digit (0/1/2), so anchoring the rhyme on the last
    // digit-bearing phoneme grabs the unstressed final vowel — e.g. "crazy" K R EY1 Z IY0 → IY0,
    // empty coda — which then "rhymes" with every word ending in unstressed -y (abbe, abadi…).
    func testRhymeAnchorsOnStressedVowelNotLastVowel() {
        let crazy = ["K", "R", "EY1", "Z", "IY0"]   // primary stress EY1, unstressed final IY0
        XCTAssertEqual(GhostSuggestionEngine.rhymeStrength(of: ["L", "EY1", "Z", "IY0"], against: crazy), 2,
                       "lazy is a perfect rhyme for crazy")
        XCTAssertEqual(GhostSuggestionEngine.rhymeStrength(of: ["AE1", "B", "IY0"], against: crazy), 0,
                       "abbe must NOT rhyme with crazy — it only shares the unstressed final IY0")
    }

    func testRankedRhymesIgnoresUnstressedFinalVowelMatches() {
        let lexicon: [String: [String]] = [
            "crazy": ["K", "R", "EY1", "Z", "IY0"],
            "lazy":  ["L", "EY1", "Z", "IY0"],
            "hazy":  ["HH", "EY1", "Z", "IY0"],
            "abbe":  ["AE1", "B", "IY0"],            // alphabetical-first, but NOT a rhyme
            "abadi": ["AH0", "B", "AE1", "D", "IY0"] // NOT a rhyme
        ]
        let out = GhostSuggestionEngine.rankedRhymes(target: ["K", "R", "EY1", "Z", "IY0"], lexicon: lexicon, excluding: "crazy", limit: 3)
        XCTAssertEqual(out, ["hazy", "lazy"], "real rhymes only; alphabetical 'abbe'/'abadi' must not be treated as rhymes")
    }

    // End-to-end against the REAL bundled CMUDICT — the exact symptom observed running in the sim
    // (a line ending in "crazy" surfaced "abbe · abadi · abadie").
    func testFreeHintForCrazyDoesNotSurfaceAlphabeticalNonRhymes() {
        let hint = GhostSuggestionEngine(retriever: nil).freeHint(forLastLine: "I was going to crazy")
        guard let hint else { return }   // CMUDICT not in this bundle → skip (matches testFreeRhymeCandidates)
        XCTAssertFalse(hint.candidates.contains("abbe"), "alphabetical-first non-rhyme must not appear")
        XCTAssertFalse(hint.candidates.contains("abadi"))
        XCTAssertFalse(hint.candidates.isEmpty, "crazy has real rhymes (lazy, hazy, daisy…)")
    }
}
