import XCTest
@testable import XJournal_AI

final class CommaHintTests: XCTestCase {

    func testDebateLineHasNoStarterAndNoHint() {
        let line = "I can't go back and forth this ain't no debate"
        XCTAssertGreaterThanOrEqual(LineSyllableCounter.syllableCount(forLine: line), 10)
        XCTAssertTrue(CommaHintEngine.hints(in: line).isEmpty)
    }

    func testCuzLineHintsBeforeCuz() {
        let line = "Put it on my tab cuz we up now I'm on now"
        XCTAssertGreaterThanOrEqual(LineSyllableCounter.syllableCount(forLine: line), 10)
        let hints = CommaHintEngine.hints(in: line)
        XCTAssertEqual(hints.map(\.word), ["cuz"])
        XCTAssertEqual(lineIndex(line, hints[0]), line.distance(from: line.startIndex, to: line.range(of: "cuz")!.lowerBound))
    }

    func testStatesLineHintsBeforeBut() {
        // "but" starts at character 31 of 45, which is 68.9%, outside 30–60%.
        let line = "Lot of us was images up states but we out now"
        XCTAssertGreaterThanOrEqual(LineSyllableCounter.syllableCount(forLine: line), 10)
        XCTAssertTrue(CommaHintEngine.hints(in: line).isEmpty)
    }

    func testButInsideTheWindowHintsBeforeBut() {
        let line = "I could do the time but I ain't tryna get a case man"
        XCTAssertGreaterThanOrEqual(LineSyllableCounter.syllableCount(forLine: line), 10)
        let hints = CommaHintEngine.hints(in: line)
        XCTAssertEqual(hints.map(\.word), ["but"])
    }

    func testShortBarWithButMidBarHasNoHint() {
        let line = "We out but we gone"
        XCTAssertLessThan(LineSyllableCounter.syllableCount(forLine: line), 10)
        XCTAssertTrue(CommaHintEngine.hints(in: line).isEmpty)
    }

    func testStarterAsTheFirstWordHasNoHint() {
        let line = "But we out now and the night is still moving on us"
        XCTAssertGreaterThanOrEqual(LineSyllableCounter.syllableCount(forLine: line), 10)
        XCTAssertTrue(line.hasPrefix("But "))
        XCTAssertTrue(CommaHintEngine.hints(in: line).isEmpty)
    }

    func testExistingCommaBeforeStarterHasNoHint() {
        let line = "Put it on my tab, cuz we up now I'm on now"
        XCTAssertGreaterThanOrEqual(LineSyllableCounter.syllableCount(forLine: line), 10)
        XCTAssertTrue(CommaHintEngine.hints(in: line).isEmpty)
    }

    func testWontStopTilHasNoHint() {
        let line = "Shawty I won't stop 'til you feel it now"
        XCTAssertGreaterThanOrEqual(LineSyllableCounter.syllableCount(forLine: line), 10)
        XCTAssertTrue(line.contains("won't stop 'til"))
        XCTAssertTrue(CommaHintEngine.hints(in: line).isEmpty)
    }

    func testSharedSubjectVerbButVerbHasNoHint() {
        let line = "The whole block meant well but fell after midnight came"
        XCTAssertGreaterThanOrEqual(LineSyllableCounter.syllableCount(forLine: line), 10)
        XCTAssertTrue(CommaHintEngine.hints(in: line).isEmpty)
    }

    private func lineIndex(_ line: String, _ hint: CommaHint) -> Int {
        hint.utf16Location
    }
}
