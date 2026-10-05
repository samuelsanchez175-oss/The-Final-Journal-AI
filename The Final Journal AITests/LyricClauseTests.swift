import XCTest
@testable import XJournal_AI

final class LyricClauseTests: XCTestCase {

    func testScreenshotLineIsOneCaesura() {
        let line = "I been running from my opps, yea i do my own stunts"
        XCTAssertEqual(LineSyllableCounter.syllableCount(forLine: line), 13)
        let clause = LyricClause.split(line)
        XCTAssertEqual(clause?.setupEnd, "opps")
        XCTAssertEqual(clause?.punchEnd, "stunts")
        XCTAssertEqual(clause?.setup, "I been running from my opps")
        XCTAssertEqual(clause?.punch, "yea i do my own stunts")
        XCTAssertEqual(GhostSuggestionEngine.endWord(of: line), "stunts")
        XCTAssertEqual(LyricClause.cadenceLine(for: line), "yea i do my own stunts")
        XCTAssertEqual(clause?.setupSyllables, LineSyllableCounter.syllableCount(forLine: "I been running from my opps"))
        XCTAssertEqual(clause?.punchSyllables, LineSyllableCounter.syllableCount(forLine: "yea i do my own stunts"))
        XCTAssertGreaterThan(clause?.punchSyllables ?? 0, 0)
        XCTAssertEqual(clause?.pocketCaption, "\(clause!.setupSyllables) + \(clause!.punchSyllables)")
    }

    func testPeriodIsABreathWhenBothSidesAreClauses() {
        let clause = LyricClause.split("I'm just getting started. This is nothing special")
        XCTAssertEqual(clause?.setupEnd, "started")
        XCTAssertEqual(clause?.punchEnd, "special")
        XCTAssertTrue(clause?.pictureReRead == false || clause != nil)
    }

    func testLastCommaWinsWhenThereAreTwo() {
        let clause = LyricClause.split("ran from the opps, yeah, I do my stunts")
        XCTAssertEqual(clause?.punchEnd, "stunts")
        XCTAssertEqual(clause?.setupEnd, "yeah")
    }

    func testPictureReReadRanksAboveCommaOnly() {
        let query = "Came up off nothing, this is nothing special"
        let q = LyricClause.split(query)
        XCTAssertEqual(q?.pictureReRead, true)
        let reread = "Came up off nothing, still nothing special"
        let commaOnly = "I duck the cops, then I hit my own stunts"
        XCTAssertGreaterThan(
            LyricClause.styleScore(candidate: reread, query: q),
            LyricClause.styleScore(candidate: commaOnly, query: q)
        )
        XCTAssertEqual(LyricClause.styleScore(candidate: commaOnly, query: q), 0)
    }

    func testWashesPaintSetupThenPunchOnOneLine() {
        let text = "I been running from my opps, yea i do my own stunts"
        let washes = LyricClause.washes(in: text)
        XCTAssertEqual(washes.count, 2)
        XCTAssertEqual(washes[0].wash, .setup)
        XCTAssertEqual(washes[1].wash, .punch)
        let ns = text as NSString
        XCTAssertEqual(ns.substring(with: washes[0].utf16), "I been running from my opps")
        XCTAssertEqual(ns.substring(with: washes[1].utf16), "yea i do my own stunts")
        XCTAssertTrue(LyricClause.washes(in: "ice, chain, watch").isEmpty)
    }

    func testCommaAloneDoesNotBoostStyle() {
        let query = "I been running from my opps, yea i do my own stunts"
        let q = LyricClause.split(query)
        XCTAssertEqual(q?.pictureReRead, false)
        XCTAssertEqual(
            LyricClause.styleScore(
                candidate: "I duck the cops, then I hit my own stunts",
                query: q
            ),
            0
        )
    }

    func testCadencePrefersMatchingPunchPocket() {
        let query = "I been running from my opps, yea i do my own stunts"
        let clause = LyricClause.split(query)
        let close = "I duck the cops, then I hit my own stunts"
        let stretched = "I been running from my opps, yea I really do my own stunts tonight"
        XCTAssertGreaterThan(
            LyricClause.cadenceScore(candidate: close, query: clause),
            LyricClause.cadenceScore(candidate: stretched, query: clause)
        )
        XCTAssertEqual(LyricClause.cadenceLine(for: "flesh and bone"), "flesh and bone")
    }

    func testInnerRhymeBreaksAnUnevenTwelve() {
        preloadGlobalCMUDICTStore()
        let start = Date()
        var phones = RhymeHighlighterEngine.phonemes(for: "world") ?? []
        while !phones.contains("ER1"), Date().timeIntervalSince(start) < 20 {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            phones = RhymeHighlighterEngine.phonemes(for: "world") ?? []
        }
        XCTAssertTrue(
            phones.contains("ER1"),
            "world must use the dictionary vowel before the caesura runs, got \(phones)"
        )
        let line = "Money run the world took my girl out to Bombay"
        let clause = LyricClause.split(line)
        XCTAssertEqual(clause?.setup, "Money run the world")
        XCTAssertEqual(clause?.punch, "took my girl out to Bombay")
        XCTAssertEqual(clause?.setupEnd, "world")
        XCTAssertEqual(clause?.punchEnd, "bombay")
        XCTAssertEqual(clause?.setupSyllables, 5)
        XCTAssertEqual(clause?.punchSyllables, 7)
        let washes = LyricClause.washes(in: line)
        XCTAssertEqual(washes.map(\.wash), [.setup, .punch])
    }

    func testListCommasAreNotABreath() {
        XCTAssertNil(LyricClause.split("ice, chain, watch"))
        XCTAssertNil(LyricClause.split("Mr. Drake said hi"))
        XCTAssertNil(LyricClause.split("I walk the block,"))
        XCTAssertNil(LyricClause.split("I walk the block"))
    }

    func testMoneyInMoneyOutIsABreath() {
        let clause = LyricClause.split("money in, money out")
        XCTAssertEqual(clause?.setupEnd, "in")
        XCTAssertEqual(clause?.punchEnd, "out")
    }

    func testWrapHitsStillSurfaceSameEndWhenQueryHasABreath() {
        let query = "I been running from my opps, yea i do my own stunts"
        let n = LineSyllableCounter.syllableCount(forLine: query)
        let sameEnd = RemindsMeOfCandidate(
            id: "stunts",
            line: "I do my own stunts",
            artist: "Drake",
            song: "Test",
            syllableCount: n,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let commaStyle = RemindsMeOfCandidate(
            id: "comma",
            line: "I duck the cops, then I hit my own stunts",
            artist: "Wayne",
            song: "Test",
            syllableCount: n,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let hits = RemindsMeOfScorer.wrapHits(
            from: [sameEnd, commaStyle],
            queryLine: query,
            syllables: n
        )
        XCTAssertTrue(hits.contains { $0.line == sameEnd.line })
        XCTAssertTrue(hits.contains { $0.line == commaStyle.line })
    }

    func testEyePopoverKeepsRhymesDefaultAndNamesSetupAndPunch() {
        XCTAssertEqual(EyeHighlightOption.rhymes.label, "Rhymes")
        XCTAssertEqual(EyeHighlightOption.setupAndPunch.label, "Setup and punch")
        XCTAssertEqual(EyeHighlightOption.allCases.map(\.id), ["rhymes", "setupAndPunch", "techniques"])
    }

    func testGhostKeepsPunchFamilyFirstThenMixesSetup() {
        let mixed = GhostSuggestionEngine.mixingBreathRhymes(
            punch: ["blunts", "hunts", "punts", "fronts"],
            setup: ["drops", "blocks"]
        )
        XCTAssertEqual(Array(mixed.prefix(3)), ["blunts", "hunts", "punts"])
        XCTAssertTrue(mixed.contains("drops"))
        XCTAssertTrue(mixed.contains("blocks"))
        XCTAssertEqual(mixed.first, "blunts")
    }
}
