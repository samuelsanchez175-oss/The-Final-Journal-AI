import XCTest
@testable import XJournal_AI

final class LyricPlainTextTests: XCTestCase {
    func testNormalizeLineBreaksKeepsBars() {
        let raw = "a\u{2028}b\r\nc\rd\u{2029}e\u{0085}f"
        XCTAssertEqual(LyricPlainText.normalizeLineBreaks(raw), "a\nb\nc\nd\ne\nf")
    }

    func testLineRangeTakesTheBarUnderTheCaret() {
        let bars = "first bar only\nsecond bar only" as NSString

        let first = LyricPlainText.lineRange(in: bars, caret: 3)
        XCTAssertEqual(bars.substring(with: first), "first bar only\n")

        let onBreak = bars.range(of: "\n").location
        XCTAssertEqual(bars.substring(with: LyricPlainText.lineRange(in: bars, caret: onBreak)), "first bar only\n")

        let secondStart = onBreak + 1
        XCTAssertEqual(bars.substring(with: LyricPlainText.lineRange(in: bars, caret: secondStart)), "second bar only")

        let end = LyricPlainText.lineRange(in: bars, caret: bars.length)
        XCTAssertEqual(bars.substring(with: end), "second bar only")
    }

    func testLineRangeAfterAFinalNewlineDoesNotStealThePreviousBar() {
        let trail = "hello\n" as NSString
        let empty = LyricPlainText.lineRange(in: trail, caret: trail.length)
        XCTAssertEqual(empty.location, trail.length)
        XCTAssertEqual(empty.length, 0)

        let onBreak = LyricPlainText.lineRange(in: trail, caret: trail.length - 1)
        XCTAssertEqual(trail.substring(with: onBreak), "hello\n")
    }

    func testLineRangeKeepsABlankBarInTheMiddle() {
        let mid = "a\n\nb" as NSString
        let blank = LyricPlainText.lineRange(in: mid, caret: 2)
        XCTAssertEqual(mid.substring(with: blank), "\n")
        XCTAssertEqual(mid.substring(with: LyricPlainText.lineRange(in: mid, caret: 0)), "a\n")
        XCTAssertEqual(mid.substring(with: LyricPlainText.lineRange(in: mid, caret: 3)), "b")
    }

    func testLineRangeOfAnEmptyNoteIsEmpty() {
        let empty = "" as NSString
        XCTAssertEqual(LyricPlainText.lineRange(in: empty, caret: 0), NSRange(location: 0, length: 0))
    }

    func testWordRangeTakesTheWordTouchingTheCaret() {
        let line = "Money run the world took my girl" as NSString
        let world = line.range(of: "world")
        XCTAssertEqual(LyricPlainText.wordRange(in: line, caret: world.location + 2), world)
        XCTAssertEqual(LyricPlainText.wordRange(in: line, caret: world.location + world.length), world)

        let girl = line.range(of: "girl")
        XCTAssertEqual(LyricPlainText.wordRange(in: line, caret: girl.location), girl)
    }

    func testWordRangeKeepsApostrophesAndDigits() throws {
        let dont = "don't stop" as NSString
        let contraction = LyricPlainText.wordRange(in: dont, caret: 2)
        XCTAssertEqual(dont.substring(with: try XCTUnwrap(contraction)), "don't")
        XCTAssertEqual(LyricPlainText.wordRange(in: dont, caret: 5), contraction)

        let curly = "I\u{2019}m here" as NSString
        XCTAssertEqual(curly.substring(with: try XCTUnwrap(LyricPlainText.wordRange(in: curly, caret: 1))), "I\u{2019}m")

        let eight = "hate 8 date" as NSString
        let digit = eight.range(of: "8")
        XCTAssertEqual(LyricPlainText.wordRange(in: eight, caret: digit.location), digit)
    }

    func testWordRangeOnAGapAfterPunctuationTakesTheWord() throws {
        let line = "world, girl" as NSString
        let comma = line.range(of: ",").location
        let world = LyricPlainText.wordRange(in: line, caret: comma)
        XCTAssertEqual(line.substring(with: try XCTUnwrap(world)), "world")
        XCTAssertNil(LyricPlainText.wordRange(in: "   " as NSString, caret: 1))
    }
}
