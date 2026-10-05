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
        // perfect before slant; inside a tier, shorter rap-usable words first
        XCTAssertEqual(out, ["light", "bright", "ride", "time"])
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

    // MARK: - Refresh trigger (Enter / indent; robust to predictive-text batching the newline)

    func testDidTakeBreathFiresOnCommaNotOnTypingAfter() {
        XCTAssertTrue(GhostSuggestionEngine.didTakeBreath(old: "I walk the block", new: "I walk the block,"))
        XCTAssertTrue(GhostSuggestionEngine.didTakeBreath(old: "I walk the block", new: "I walk the block, "))
        XCTAssertFalse(GhostSuggestionEngine.didTakeBreath(old: "I walk the block,", new: "I walk the block, where"))
        XCTAssertFalse(GhostSuggestionEngine.didTakeBreath(old: "I walk the block", new: "I walk the block"))
    }

    func testBreathSetupIsTextBeforeComma() {
        XCTAssertEqual(GhostSuggestionEngine.breathSetup(in: "I walk the block,"), "I walk the block")
        XCTAssertEqual(GhostSuggestionEngine.breathSetup(in: "I walk the block, "), "I walk the block")
        XCTAssertNil(GhostSuggestionEngine.breathSetup(in: "I walk the block"))
    }

    func testPunchFragmentTakesCatalogPostComma() {
        XCTAssertEqual(
            GhostSuggestionEngine.punchFragment(
                from: "I walk the block, where the echoes bounce",
                setup: "I walk the block"
            ),
            "where the echoes bounce"
        )
        XCTAssertEqual(
            GhostSuggestionEngine.punchFragment(
                from: "I'm what a bitch needs",
                setup: "I don't need a bitch"
            )?.lowercased(),
            "i'm what a bitch needs"
        )
        XCTAssertEqual(
            GhostSuggestionEngine.punchFragment(
                from: "I don't need a bitch, I'm what a bitch needs",
                setup: "i dont need a bitch"
            )?.lowercased(),
            "i'm what a bitch needs"
        )
        XCTAssertEqual(
            GhostSuggestionEngine.punchFragment(
                from: "I'm what a bitch need, I'll never need a bitch, yeah",
                setup: "I don't need a bitch"
            )?.lowercased().contains("bitch"),
            true
        )
    }

    func testRankCadencePunchesSurfacesWeekndFlipOverLooseBitchBars() {
        let rows: [BarHitsCatalogStore.Row] = [
            BarHitsCatalogStore.Row(
                id: "weeknd",
                line: "I don't need a bitch, I'm what a bitch needs",
                artist: "The Weeknd",
                song: "The Hills",
                syllables: 12,
                endWord: "needs",
                phoneticClass: ""
            ),
            BarHitsCatalogStore.Row(
                id: "noise",
                line: "Bitch niggas dont get that",
                artist: "G Herbo",
                song: "X",
                syllables: 6,
                endWord: "that",
                phoneticClass: ""
            ),
        ]
        let out = GhostSuggestionEngine.rankCadencePunches(
            setup: "i dont need a bitch",
            wrap: LineSyllableCounter.syllableCount(forLine: "i dont need a bitch"),
            rows: rows,
            limit: 8
        )
        XCTAssertFalse(out.isEmpty)
        XCTAssertTrue(out.contains { $0.text.lowercased().contains("what a bitch need") })
        XCTAssertTrue(out.first?.text.lowercased().contains("what a bitch need") == true)
        XCTAssertEqual(out.first?.artist, "The Weeknd")
    }

    func testCollapsePunchDupesDropsNeedVsNeedsAndSubsets() {
        let wrap = 6
        let chips = [
            GhostPunchChip(text: "i'm what a bitch needs", syllables: 6, targetWrap: wrap, artist: "The Weeknd", song: "The Hills", preferred: false),
            GhostPunchChip(text: "i'm what a bitch need", syllables: 6, targetWrap: wrap, artist: "Tory Lanez", song: "Staccato", preferred: false),
            GhostPunchChip(text: "what a bitch needs", syllables: 5, targetWrap: wrap, artist: nil, song: nil, preferred: false),
        ]
        let out = GhostSuggestionEngine.collapsePunchDupes(chips)
        XCTAssertEqual(out.count, 1)
        XCTAssertTrue(out[0].text.lowercased().contains("i'm what a bitch need"))
    }

    func testCadenceCacheFoldsDontContractionsAndSeedsTheHillsFlip() {
        XCTAssertEqual(CadenceGhostCache.normalize("I don't need a bitch"), "i dont need a bitch")
        let seeds = CadenceGhostCache.seedPunches(for: "I don't need a bitch")
        XCTAssertTrue(seeds.contains { $0.lowercased().contains("what a bitch needs") })
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cg-\(UUID().uuidString).json")
        let cache = CadenceGhostCache(storageURL: url)
        cache.store(["i'm what a bitch needs"], setup: "i dont need a bitch", wrap: 6, solved: true)
        let hit = cache.punches(for: "I don't need a bitch", wrap: 6)
        XCTAssertEqual(hit?.solved, true)
        XCTAssertTrue(hit?.punches.contains { $0.lowercased().contains("what a bitch needs") } == true)
    }

    func testPreferPutsTappedPunchFirstNextTime() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cg-\(UUID().uuidString).json")
        let cache = CadenceGhostCache(storageURL: url)
        cache.store(["nobody needs me like i need me", "i'm what a bitch needs"], setup: "i dont need a bitch", wrap: 6, solved: true)
        cache.prefer("i'm what a bitch needs", setup: "i dont need a bitch", wrap: 6)
        let hit = cache.chips(for: "I don't need a bitch", wrap: 6)
        XCTAssertEqual(hit?.preferred?.lowercased().contains("what a bitch needs"), true)
        XCTAssertTrue(hit?.chips.first?.preferred == true)
        XCTAssertTrue(hit?.chips.first?.text.lowercased().contains("what a bitch needs") == true)
    }

    func testInsertingCandidateReplacesPunchAfterComma() {
        XCTAssertEqual(
            GhostSuggestionEngine.insertingCandidate("where echoes bounce", into: "I walk the block,"),
            "I walk the block, where echoes bounce"
        )
        XCTAssertEqual(
            GhostSuggestionEngine.insertingCandidate("i'm what a bitch needs", into: "i dont need a bitch,"),
            "i dont need a bitch, i'm what a bitch needs"
        )
    }

    func testCadencePunchSetupUsesCurrentLineNotPreviousWhenComma() {
        let verse = """
        I been running from my opps, yea i do my own stunts
        I don't need a bitch,
        """
        let setup = GhostSuggestionEngine.cadencePunchSetup(in: verse, completed: true)
        XCTAssertEqual(CadenceGhostCache.normalize(setup ?? ""), "i dont need a bitch")
        XCTAssertFalse((setup ?? "").localizedCaseInsensitiveContains("opps"))
        XCTAssertTrue(GhostSuggestionEngine.didTakeBreath(
            old: "I been running from my opps, yea i do my own stunts\nI don't need a bitch",
            new: verse
        ))
    }

    func testInstantCadenceChipsSurfaceHillsSeedWithoutCatalog() {
        let chips = GhostSuggestionEngine.instantCadenceChips(
            setup: "I don't need a bitch",
            wrap: LineSyllableCounter.syllableCount(forLine: "I don't need a bitch")
        )
        XCTAssertTrue(chips.contains { $0.text.lowercased().contains("what a bitch need") })
    }

    func testCadencePunchSetupUsesCommaOrNewlineBreath() {
        XCTAssertEqual(
            GhostSuggestionEngine.cadencePunchSetup(in: "i dont need a bitch,", completed: false),
            "i dont need a bitch"
        )
        XCTAssertEqual(
            GhostSuggestionEngine.cadencePunchSetup(in: "i dont need a bitch\n", completed: true),
            "i dont need a bitch"
        )
        XCTAssertNil(GhostSuggestionEngine.cadencePunchSetup(in: "i dont need a bitch", completed: false))
        XCTAssertEqual(
            GhostSuggestionEngine.cadencePunchSetup(
                in: "i dont need a bitch, i'm what a bitch needs",
                completed: false
            ),
            "i dont need a bitch"
        )
    }

    func testStillPunchingAfterNewlineInsert() {
        let setup = "i dont need a bitch"
        XCTAssertTrue(GhostSuggestionEngine.stillPunching(in: "i dont need a bitch\n", heldSetup: setup))
        XCTAssertTrue(GhostSuggestionEngine.stillPunching(
            in: "i dont need a bitch\ni'm what a bitch needs",
            heldSetup: setup
        ))
        XCTAssertTrue(GhostSuggestionEngine.stillPunching(
            in: "i dont need a bitch, i'm what a bitch needs",
            heldSetup: setup
        ))
        XCTAssertFalse(GhostSuggestionEngine.stillPunching(in: "money in the bag\n", heldSetup: setup))
    }

    func testInsertingCandidateAsPunchBarGoesOnNextLine() {
        XCTAssertEqual(
            GhostSuggestionEngine.insertingCandidate("i'm what a bitch needs", into: "i dont need a bitch\n", asPunchBar: true),
            "i dont need a bitch\ni'm what a bitch needs"
        )
        XCTAssertEqual(
            GhostSuggestionEngine.insertingCandidate("what a bitch need", into: "i dont need a bitch\ni'm what a bitch needs", asPunchBar: true),
            "i dont need a bitch\nwhat a bitch need"
        )
        XCTAssertEqual(
            GhostSuggestionEngine.insertingCandidate("i'm what a bitch needs", into: "i dont need a bitch,", asPunchBar: true),
            "i dont need a bitch, i'm what a bitch needs"
        )
    }

    func testTechniqueOverlayHeatsInnerMosaicChain() {
        let text = "Im standing ten toes,\nhoes know how i let it go"
        let hits = TechniqueOverlayEngine.hits(in: text)
        XCTAssertFalse(hits.isEmpty)
        let words = hits.map { String(text[$0.range]).lowercased() }
        XCTAssertTrue(words.contains { $0.contains("toes") || $0.contains("hoes") || $0.contains("know") || $0.contains("go") })
        XCTAssertGreaterThanOrEqual(hits.map(\.heat).max() ?? 0, 0.70)
    }

    /// The pronunciation list loads on a background queue. Hits that share a vowel
    /// are empty until it finishes, which looks like a missed inner rhyme.
    private func waitUntilPronunciationsLoad() {
        preloadGlobalCMUDICTStore()
        let start = Date()
        while getGlobalCMUDICTStore()["eye"] == nil, Date().timeIntervalSince(start) < 20 {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        XCTAssertNotNil(getGlobalCMUDICTStore()["eye"])
    }

    func testEyeAndMyHighlightAsInnerRhymes() {
        waitUntilPronunciationsLoad()
        let text = "Eye over my shoulder like a immigrant"
        let hits = TechniqueOverlayEngine.hits(in: text)
        let words = Set(hits.map { String(text[$0.range]).lowercased() })
        XCTAssertTrue(words.contains("eye"), "highlighted \(words.sorted())")
        XCTAssertTrue(words.contains("my"), "highlighted \(words.sorted())")
        XCTAssertTrue(words.contains("over"), "highlighted \(words.sorted())")
        XCTAssertTrue(words.contains("shoulder"), "highlighted \(words.sorted())")
        XCTAssertFalse(words.contains("a"))
        XCTAssertFalse(words.contains("immigrant"))
        let eyeHeat = hits.first { String(text[$0.range]).lowercased() == "eye" }?.heat
        let myHeat = hits.first { String(text[$0.range]).lowercased() == "my" }?.heat
        XCTAssertEqual(eyeHeat, myHeat)
    }

    func testWorldAndGirlHeatAsInnerRhymes() {
        waitUntilPronunciationsLoad()
        let text = "Money run the world took my girl out to Bombay"
        let hits = TechniqueOverlayEngine.hits(in: text)
        let words = Set(hits.map { String(text[$0.range]).lowercased() })
        XCTAssertTrue(words.contains("world"), "highlighted \(words.sorted())")
        XCTAssertTrue(words.contains("girl"), "highlighted \(words.sorted())")
    }

    func testLoneFunctionWordsStayDark() {
        waitUntilPronunciationsLoad()
        let text = "I got the bag for the block"
        let hits = TechniqueOverlayEngine.hits(in: text)
        let words = Set(hits.map { String(text[$0.range]).lowercased() })
        XCTAssertTrue(words.contains("got"))
        XCTAssertTrue(words.contains("block"))
        XCTAssertFalse(words.contains("the"))
        XCTAssertFalse(words.contains("for"))
        XCTAssertFalse(words.contains("i"))
    }

    func testTechniqueColorsStayApart() {
        func hue(_ t: CGFloat) -> CGFloat {
            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            CraftHeatPalette.uiColor(t).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            return h
        }
        let inner = hue(0.48)
        let mosaic = hue(0.72)
        let chain = hue(0.92)
        XCTAssertGreaterThan(inner, 0.50)
        XCTAssertLessThan(inner, 0.66)
        XCTAssertGreaterThan(mosaic, 0.08)
        XCTAssertLessThan(mosaic, 0.18)
        XCTAssertLessThan(chain, 0.05)
    }

    func testVersePocketUsesRecentBarsNotTheShortSetup() {
        let setup = "I don't need a bitch"
        let setupN = LineSyllableCounter.syllableCount(forLine: setup)
        XCTAssertEqual(setupN, 5)
        let verse = """
        I run down the block creeping
        She wanted to cheat me some
        I hope you ain't reach in for some
        I was tryna see if I can get sum
        I gotta girl I was fucking, now she on the run
        If I was to crash out, I hope i got my gun
        I been running from my opps, yea i do my own stunts
        I don't need a bitch,
        """
        let pocket = GhostSuggestionEngine.cadencePunchWrap(setup: setup, in: verse)
        XCTAssertTrue(pocket.fromVerse)
        XCTAssertTrue(pocket.fillingHalf)
        XCTAssertGreaterThanOrEqual(pocket.bar, 12)
        XCTAssertLessThanOrEqual(pocket.bar, 13)
        XCTAssertEqual(pocket.punchWrap, pocket.bar - setupN)
        XCTAssertGreaterThanOrEqual(pocket.punchWrap, 7)
        XCTAssertTrue(pocket.caption.contains("verse"))
    }

    func testVersePocketOnShortOpeningBarsStillAimsAtTheGutter() {
        let setup = "I don't need a bitch"
        let setupN = LineSyllableCounter.syllableCount(forLine: setup)
        XCTAssertEqual(setupN, 5)
        let verse = """
        I run down the block creeping
        She wanted to cheat me some
        I don't need a bitch,
        """
        let pocket = GhostSuggestionEngine.cadencePunchWrap(setup: setup, in: verse)
        XCTAssertTrue(pocket.fromVerse)
        XCTAssertEqual(pocket.bar, LineSyllableCounter.syllableCount(forLine: "I run down the block creeping"))
        XCTAssertGreaterThanOrEqual(pocket.punchWrap, 3)
        XCTAssertNotEqual(pocket.punchWrap, setupN)
    }

    func testVersePocketFallsBackWhenThereIsNoGroove() {
        let setup = "I don't need a bitch"
        let pocket = GhostSuggestionEngine.cadencePunchWrap(setup: setup, in: "I don't need a bitch,")
        XCTAssertFalse(pocket.fromVerse)
        XCTAssertEqual(pocket.punchWrap, LineSyllableCounter.syllableCount(forLine: setup))
    }

    func testNewlineBreathUsesFullBarPocketNotTheRemainder() {
        let verse = """
        I gotta girl I was fucking, now she on the run
        If I was to crash out, I hope i got my gun
        I been running from my opps, yea i do my own stunts
        I don't need a bitch
        """
        let pocket = GhostSuggestionEngine.cadencePunchWrap(
            setup: "I don't need a bitch",
            in: verse + "\n"
        )
        XCTAssertTrue(pocket.fromVerse)
        XCTAssertFalse(pocket.fillingHalf)
        XCTAssertGreaterThanOrEqual(pocket.punchWrap, 12)
    }

    func testRhymeChainPutsInternalToEndMosaicFirst() {
        let setup = "im standing ten toes"
        let chained = GhostSuggestionEngine.rhymeChain(
            setup: setup,
            punch: "hoes know how i let it go"
        )
        let endOnly = GhostSuggestionEngine.rhymeChain(
            setup: setup,
            punch: "i never let it go"
        )
        XCTAssertTrue(chained.chained)
        XCTAssertGreaterThanOrEqual(chained.internals, 1)
        XCTAssertGreaterThan(chained.score, endOnly.score)
        let wrap = LineSyllableCounter.syllableCount(forLine: setup)
        let rows = [
            BarHitsCatalogStore.Row(
                id: "weak",
                line: "i keep the money in the bag",
                artist: nil, song: nil, syllables: 8, endWord: "bag", phoneticClass: ""
            ),
            BarHitsCatalogStore.Row(
                id: "end",
                line: "i never let it go",
                artist: nil, song: nil, syllables: 6, endWord: "go", phoneticClass: ""
            ),
            BarHitsCatalogStore.Row(
                id: "chain",
                line: "hoes know how i let it go",
                artist: nil, song: nil, syllables: 7, endWord: "go", phoneticClass: ""
            ),
        ]
        let out = GhostSuggestionEngine.rankCadencePunches(setup: setup, wrap: wrap, rows: rows, limit: 8)
        XCTAssertEqual(out.first?.text.lowercased(), "hoes know how i let it go")
        XCTAssertEqual(out.first?.chained, true)
    }

    func testFittingPunchesKeepsNearWrapWhenFewExact() {
        let wrap = 6
        let chips = [
            GhostPunchChip(text: "one two three four five six", syllables: 6, targetWrap: wrap, artist: nil, song: nil, preferred: false),
            GhostPunchChip(text: "one two three four five six seven eight nine", syllables: 9, targetWrap: wrap, artist: nil, song: nil, preferred: false),
        ]
        let out = GhostSuggestionEngine.fittingPunches(chips, wrap: wrap)
        XCTAssertTrue(out.contains { $0.syllables == 6 })
        XCTAssertTrue(out.contains { $0.syllables == 9 }, "gutter wrap does not have to be exact")
    }

    func testFittingPunchesDropsGutterMissesWhenEnoughFit() {
        let wrap = 6
        let chips = [
            GhostPunchChip(text: "i'm what a bitch needs", syllables: 6, targetWrap: wrap, artist: nil, song: nil, preferred: false),
            GhostPunchChip(text: "what a bitch needs", syllables: 5, targetWrap: wrap, artist: nil, song: nil, preferred: false),
            GhostPunchChip(text: "i already got me", syllables: 5, targetWrap: wrap, artist: nil, song: nil, preferred: false),
            GhostPunchChip(text: "a whole extra bar that blows the wrap gutter tonight", syllables: 14, targetWrap: wrap, artist: nil, song: nil, preferred: false),
        ]
        let out = GhostSuggestionEngine.fittingPunches(chips, wrap: wrap)
        XCTAssertEqual(out.count, 3)
        XCTAssertFalse(out.contains { $0.syllables == 14 })
    }

    func testDidCompleteLineOrIndentFiresOnEnterAndIndentNotPlainTyping() {
        XCTAssertTrue(GhostSuggestionEngine.didCompleteLineOrIndent(old: "the city", new: "the city\n"), "Enter at end")
        XCTAssertTrue(GhostSuggestionEngine.didCompleteLineOrIndent(old: "the city", new: "the city\nI talk"), "batched newline + next word")
        XCTAssertTrue(GhostSuggestionEngine.didCompleteLineOrIndent(old: "the city", new: "\tthe city"), "indent (tab)")
        XCTAssertFalse(GhostSuggestionEngine.didCompleteLineOrIndent(old: "the cit", new: "the city"), "plain typing must not refresh")
    }

    func testJustCompletedLineIsTheLineBeforeTheLatestNewline() {
        XCTAssertEqual(GhostSuggestionEngine.justCompletedLine(in: "shooting star\n"), "shooting star")
        XCTAssertEqual(GhostSuggestionEngine.justCompletedLine(in: "shooting star\nI talk"), "shooting star") // not "I talk"
        XCTAssertEqual(GhostSuggestionEngine.justCompletedLine(in: "line one\nline two\n"), "line two")
        XCTAssertNil(GhostSuggestionEngine.justCompletedLine(in: "\n\n"))
    }

    // MARK: - Rotating rhyme pool (fresh options on each new line)

    func testBoneDoesNotSurfaceCMUDICTRespellings() {
        XCTAssertTrue(GhostSuggestionEngine.isDictionarySpellingVariant("boan", of: "bone"))
        XCTAssertTrue(GhostSuggestionEngine.isDictionarySpellingVariant("boen", of: "bone"))
        XCTAssertTrue(GhostSuggestionEngine.isDictionarySpellingVariant("bohn", of: "bone"))
        XCTAssertFalse(GhostSuggestionEngine.isDictionarySpellingVariant("own", of: "bone"))
        XCTAssertFalse(GhostSuggestionEngine.isDictionarySpellingVariant("phone", of: "bone"))
        let pool = GhostSuggestionEngine.freeRhymePool(forLastLine: "flesh and bone", limit: 40)
        if !pool.isEmpty {
            XCTAssertFalse(pool.contains("boan"))
            XCTAssertFalse(pool.contains("boen"))
            XCTAssertFalse(pool.contains("bohn"))
            XCTAssertGreaterThanOrEqual(pool.count, 8, "Ghost should keep a long sticky list")
        }
    }

    func testWindowPagesThroughPoolWithWrap() {
        let pool = ["a", "b", "c", "d", "e"]
        XCTAssertEqual(GhostSuggestionEngine.window(pool, rotation: 0), ["a", "b", "c"])
        XCTAssertEqual(GhostSuggestionEngine.window(pool, rotation: 1), ["d", "e", "a"]) // fresh set; wraps
        XCTAssertEqual(GhostSuggestionEngine.window(pool, rotation: 2), ["b", "c", "d"])
        XCTAssertEqual(GhostSuggestionEngine.window([], rotation: 3), [])
        XCTAssertEqual(GhostSuggestionEngine.window(["x"], rotation: 5), ["x"])
    }

    func testRhymeKeyGroupsRhymingLinesAndSeparatesOthers() {
        guard let star = GhostSuggestionEngine.rhymeKey(forLastLine: "be a shooting star") else { return } // needs CMUDICT
        XCTAssertEqual(star, GhostSuggestionEngine.rhymeKey(forLastLine: "got me a car"),
                       "star & car share a rhyme family → same key (pool reused, no re-scan)")
        XCTAssertNotEqual(star, GhostSuggestionEngine.rhymeKey(forLastLine: "flesh and bone"),
                          "bone is a different family → key changes (pool re-scanned)")
    }

    func testLastNonEmptyLineIsTheCurrentTypingLine() {
        XCTAssertEqual(GhostSuggestionEngine.lastNonEmptyLine(in: "one\ntwo\nthree"), "three")
        XCTAssertEqual(GhostSuggestionEngine.lastNonEmptyLine(in: "I'm typing smart"), "I'm typing smart")
        XCTAssertEqual(GhostSuggestionEngine.lastNonEmptyLine(in: "done\n"), "done")
        XCTAssertNil(GhostSuggestionEngine.lastNonEmptyLine(in: "   \n  "))
    }

    // MARK: - Enter / empty-line traps (Ghost on)

    func testFreeRhymePoolEmptyOrPunctuationLineDoesNotTrap() {
        XCTAssertEqual(GhostSuggestionEngine.freeRhymePool(forLastLine: ""), [])
        XCTAssertEqual(GhostSuggestionEngine.freeRhymePool(forLastLine: "   "), [])
        XCTAssertEqual(GhostSuggestionEngine.freeRhymePool(forLastLine: "\n"), [])
        XCTAssertEqual(GhostSuggestionEngine.freeRhymePool(forLastLine: "!!!"), [])
        XCTAssertEqual(GhostSuggestionEngine.window([], rotation: 0), [])
        XCTAssertEqual(GhostSuggestionEngine.window(["a"], rotation: 0, count: 0), [])
    }

    func testEnterOnBlankNextLineStillResolvesTheFinishedBar() {
        XCTAssertEqual(GhostSuggestionEngine.justCompletedLine(in: "shooting star\n"), "shooting star")
        XCTAssertEqual(GhostSuggestionEngine.justCompletedLine(in: "shooting star\n\n"), "shooting star")
        XCTAssertTrue(GhostSuggestionEngine.didCompleteLineOrIndent(old: "shooting star", new: "shooting star\n"))
        XCTAssertTrue(GhostSuggestionEngine.didCompleteLineOrIndent(old: "shooting star\n", new: "shooting star\n\n"))
    }

    func testGhostHintEqualitySkipsIdenticalCatalogLists() {
        let a = GhostHint(candidates: ["light", "fight", "bright"], tail: nil)
        let b = GhostHint(candidates: ["light", "fight", "bright"], tail: nil)
        let c = GhostHint(candidates: ["night"], tail: nil)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testInsertingCandidateOnFreshNewlineKeepsTheBreak() {
        XCTAssertEqual(
            GhostSuggestionEngine.insertingCandidate("light", into: "the city at night\n"),
            "the city at night light\n"
        )
    }
}
