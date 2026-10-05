import XCTest
@testable import XJournal_AI

final class BreathCommaFormatterTests: XCTestCase {

    func testScreenshotLineGainsACommaBeforeYea() {
        let bare = "I been running from my opps yea i do my own stunts"
        let edits = BreathCommaFormatter.edits(in: bare)
        XCTAssertEqual(edits.count, 1)
        XCTAssertEqual(edits[0].revised, "I been running from my opps, yea i do my own stunts")
        XCTAssertEqual(edits[0].setup, "I been running from my opps")
        XCTAssertEqual(edits[0].punch, "yea i do my own stunts")
        let again = BreathCommaFormatter.edits(in: edits[0].revised)
        XCTAssertTrue(again.isEmpty)
    }

    func testMoneyInMoneyOutGetsAComma() {
        let edits = BreathCommaFormatter.edits(in: "money in money out")
        XCTAssertEqual(edits.count, 1)
        XCTAssertEqual(edits[0].revised, "money in, money out")
        XCTAssertEqual(edits[0].setupEndPicture, "in")
        XCTAssertEqual(LyricClause.split(edits[0].revised)?.punch, "money out")
    }

    func testExistingBreakAndListsStayUntouched() {
        let text = "I been running from my opps, yea i do my own stunts\nice, chain, watch\nMr. Drake said hi"
        XCTAssertTrue(BreathCommaFormatter.edits(in: text).isEmpty)
        XCTAssertEqual(BreathCommaFormatter.applying([], to: text), text)
    }

    func testFullBarWithoutABreakSignalStaysBare() {
        let line = "the whole team really wanted me to stay home tonight"
        XCTAssertGreaterThanOrEqual(LineSyllableCounter.syllableCount(forLine: line), 11)
        XCTAssertTrue(BreathCommaFormatter.edits(in: line).isEmpty)
    }

    func testShortLineAgainstALongerWrapStaysBare() {
        let line = "I walk the block yea"
        let count = LineSyllableCounter.syllableCount(forLine: line)
        XCTAssertLessThan(count, 11)
        XCTAssertTrue(BreathCommaFormatter.edits(in: line, wrapSyllables: 14).isEmpty)
    }

    func testDoesNotCutAfterADanglingWord() {
        let line = "I got the work from the city yea we lit the night"
        let edits = BreathCommaFormatter.edits(in: line, wrapSyllables: 14)
        for edit in edits {
            XCTAssertFalse(edit.revised.contains("from,"))
            XCTAssertFalse(edit.revised.contains("the,"))
            XCTAssertFalse(edit.setup.hasSuffix("from"))
            XCTAssertFalse(edit.setup.hasSuffix("the"))
        }
    }

    func testSurroundingBreathsKeepTheSameSetupCount() throws {
        let breathed = "I been running from my opps, yea i do my own stunts"
        let bare = "I been running from my opps yea i do my own stunts"
        let text = [breathed, breathed, bare].joined(separator: "\n")
        let neighbor = try XCTUnwrap(LyricClause.split(breathed))
        let wrap = LineSyllableCounter.syllableCount(forLine: breathed)
        let edits = BreathCommaFormatter.edits(in: text, wrapSyllables: wrap)
        XCTAssertEqual(edits.map(\.lineIndex), [2])
        XCTAssertEqual(edits[0].setupSyllables, neighbor.setupSyllables)
        XCTAssertEqual(edits[0].punchSyllables, neighbor.punchSyllables)
    }

    func testApplyingKeepsTheOtherLinesAndATrailingNewline() {
        let first = "ice on me"
        let second = "I been running from my opps yea i do my own stunts"
        let text = first + "\n" + second + "\n"
        let edits = BreathCommaFormatter.edits(in: text)
        XCTAssertEqual(edits.map(\.lineIndex), [1])
        let applied = BreathCommaFormatter.applying(edits, to: text)
        XCTAssertTrue(applied.hasPrefix(first + "\n"))
        XCTAssertTrue(applied.hasSuffix("\n"))
        XCTAssertTrue(applied.contains("opps, yea"))
        XCTAssertEqual(BreathCommaFormatter.applying(edits, to: applied), applied)
    }

    func testWrapCountUsesTheNoteTarget() {
        XCTAssertEqual(BreathCommaFormatter.wrapCount(min: 12, max: 12), 12)
        XCTAssertEqual(BreathCommaFormatter.wrapCount(min: 12, max: 16), 14)
        XCTAssertEqual(BreathCommaFormatter.wrapCount(min: 10, max: nil), 10)
        XCTAssertNil(BreathCommaFormatter.wrapCount(min: nil, max: nil))
        XCTAssertNil(BreathCommaFormatter.wrapCount(min: 0, max: 0))
    }
}

private extension BreathCommaEdit {
    var setupEndPicture: String {
        setup.split(whereSeparator: \.isWhitespace).last.map(String.init) ?? ""
    }
}
