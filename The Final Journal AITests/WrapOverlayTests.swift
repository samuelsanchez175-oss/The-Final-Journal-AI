import XCTest
@testable import XJournal_AI

final class WrapOverlayTests: XCTestCase {
    func testIdenticalLastWordIsIdenticalNotPerfect() {
        XCTAssertEqual(WrapOverlayEngine.rimeGrade("seconds", "seconds"), .identical)
        XCTAssertFalse(WrapOverlayEngine.rimeGrade("seconds", "seconds").meetsNear)
    }

    func testSuffixFallbackNearRimeWithoutDict() {
        let grade = WrapOverlayEngine.rimeGrade("night", "sight")
        XCTAssertTrue(grade == .nearPerfect || grade == .perfect || grade == .slant)
    }

    func testSetupSharesLemma() {
        let setup = "Came up off nothing like the first seconds"
        let punch = "When you come from nothing you know firsts second"
        XCTAssertTrue(WrapOverlayEngine.sharesLemmaOrRime(setup: setup, punch: punch))
    }

    func testLastWordExtract() {
        XCTAssertEqual(WrapOverlayEngine.lastWord("I'm just getting started. This is nothing special"), "special")
    }

    func testSingleWordLineCountsAsLateStress() {
        XCTAssertTrue(WrapOverlayEngine.lastStressInPunchWindow("special"))
        XCTAssertTrue(WrapOverlayEngine.lastStressInPunchWindow("ice"))
    }

    func testEndLoadedBarHitsPunchWindow() {
        XCTAssertTrue(WrapOverlayEngine.lastStressInPunchWindow("I'm just getting started this is nothing special"))
    }

    func testPocketAndConceptOnSeedLoop() {
        let bars = [
            "Came up off nothing like the first seconds",
            "When you come from nothing you know firsts second",
            "You know no firsts like the first seconds",
            "I'm just getting started this is nothing special"
        ]
        let overlay = WrapOverlayEngine.evaluate(bars: bars, grammar: .couplet)
        XCTAssertEqual(overlay.setupPunchTotal, 2)
        XCTAssertGreaterThanOrEqual(overlay.setupPunchShares, 1)
        XCTAssertTrue(overlay.conceptCarry)
        XCTAssertGreaterThan(overlay.tieBreak, 0.2)
        XCTAssertTrue(overlay.summary.contains("Wrap:"))
    }

    func testShortWittyLineIsNotDropped() {
        let overlay = WrapOverlayEngine.evaluate(bars: ["ice", "twice", "nice", "vice"], grammar: .couplet)
        XCTAssertEqual(overlay.punchWindowTotal, 4)
        XCTAssertGreaterThan(overlay.tieBreak, 0)
    }
}
