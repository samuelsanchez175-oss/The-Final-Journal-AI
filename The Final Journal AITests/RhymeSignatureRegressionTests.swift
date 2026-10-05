import XCTest
@testable import XJournal_AI

/// Regression: the app's rhyme detection must anchor on the last **stressed** vowel, not the last vowel.
///
/// CMUDICT marks EVERY vowel with a stress digit (0/1/2), so anchoring the rhyme on the last
/// digit-bearing phoneme grabs the *unstressed* final vowel — e.g. "crazy" `K R EY1 Z IY0` → `IY0`
/// with an empty coda, collapsing the rhyme key to a bare "-y" that "rhymes" with any word ending
/// in unstressed -y (abbe, abadi…). The exact bug was found in the Ghost Bar and fixed in
/// `GhostSuggestionEngine.phoneticSignature` (558937e); the same latent pattern lived in the app's
/// rhyme-highlighting / rhyme-groups path — `RapAnalysisEngine` and `RhymeFinder`.
///
/// These cases are CMUDICT-independent (literal phoneme arrays) so they're deterministic regardless
/// of whether cmudict.txt is in the test bundle. `rhymeTier` is the real classifier both
/// `wordsRhyme` and `RhymeFinder.findRhymes` route through.
final class RhymeSignatureRegressionTests: XCTestCase {

    // Multi-syllable words whose FINAL vowel is unstressed — the case single-syllable tests miss
    // (there, the last vowel *is* the stressed vowel, so the old code happened to be correct).
    private let crazy = ["K", "R", "EY1", "Z", "IY0"]   // primary stress EY1, unstressed final IY0
    private let lazyW = ["L", "EY1", "Z", "IY0"]        // perfect rhyme for crazy
    private let hazy  = ["HH", "EY1", "Z", "IY0"]       // perfect rhyme for crazy
    private let abbe  = ["AE1", "B", "IY0"]             // shares ONLY the unstressed final IY0 — NOT a rhyme

    func testRapAnalysisEngineAnchorsOnStressedVowel() {
        XCTAssertEqual(RapAnalysisEngine.rhymeTier(lazyW, crazy), 3, "lazy is a perfect rhyme for crazy")
        XCTAssertEqual(RapAnalysisEngine.rhymeTier(hazy, crazy), 3, "hazy is a perfect rhyme for crazy")
        XCTAssertEqual(RapAnalysisEngine.rhymeTier(abbe, crazy), 0,
                       "abbe must NOT rhyme with crazy — it only shares the unstressed final IY0")
    }

    func testRhymeFinderAnchorsOnStressedVowel() {
        XCTAssertEqual(RhymeFinder.rhymeTier(lazyW, crazy), 3, "lazy is a perfect rhyme for crazy")
        XCTAssertEqual(RhymeFinder.rhymeTier(hazy, crazy), 3, "hazy is a perfect rhyme for crazy")
        XCTAssertEqual(RhymeFinder.rhymeTier(abbe, crazy), 0,
                       "abbe must NOT rhyme with crazy — it only shares the unstressed final IY0")
    }

    // Sanity: single-syllable rhymes (where last vowel == stressed vowel) are unchanged by the fix —
    // these are the cases the original tests covered, which is why the bug went unnoticed.
    func testSingleSyllableRhymesUnaffected() {
        let night = ["N", "AY1", "T"]
        let light = ["L", "AY1", "T"]
        let cat   = ["K", "AE1", "T"]
        XCTAssertEqual(RapAnalysisEngine.rhymeTier(light, night), 3, "light/night perfect")
        XCTAssertEqual(RapAnalysisEngine.rhymeTier(cat, night), 0, "cat/night no rhyme")
        XCTAssertEqual(RhymeFinder.rhymeTier(light, night), 3, "light/night perfect")
        XCTAssertEqual(RhymeFinder.rhymeTier(cat, night), 0, "cat/night no rhyme")
    }

    func testGroupedBySyllableMatchesRhymeZoneBuckets() {
        let groups = RhymeFinder.groupedBySyllable(words: [
            ("count", 1), ("mount", 1), ("account", 2), ("discount", 2), ("paramount", 3)
        ])
        XCTAssertEqual(groups.map(\.syllables), [1, 2, 3])
        XCTAssertEqual(groups[0].words, ["count", "mount"])
        XCTAssertEqual(groups[1].words, ["account", "discount"])
        XCTAssertEqual(groups[2].words, ["paramount"])
    }

    func testRhymeZoneAdvancedURLPointsAtOfficialAdvancedView() {
        let url = RhymeFinder.rhymeZoneAdvancedURL(for: "amount")
        XCTAssertEqual(url?.host, "www.rhymezone.com")
        XCTAssertTrue(url?.absoluteString.contains("typeofrhyme=adv") == true)
        XCTAssertTrue(url?.absoluteString.contains("Word=amount") == true)
    }

    func testFindRhymesReturnsEmptyForUnknownWord() {
        XCTAssertTrue(RhymeFinder.findRhymes(for: "zzzzqx", limit: 8).isEmpty)
    }

    func testIndexedRhymesIncludeKnownPerfectPair() throws {
        let dict = getGlobalCMUDICTStore()
        guard dict["night"] != nil, dict["light"] != nil else {
            throw XCTSkip("cmudict not loaded in test bundle")
        }
        let words = RhymeFinder.rankedRhymeWords(for: "night", limit: 80)
        XCTAssertTrue(words.contains("light"), "indexed lookup must still return light for night")
        XCTAssertFalse(words.contains("night"))
        XCTAssertEqual(RhymeFinder.rhymeTier(dict["light"]!, dict["night"]!), 3)
    }
}
