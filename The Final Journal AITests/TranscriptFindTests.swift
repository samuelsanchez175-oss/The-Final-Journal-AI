import XCTest
@testable import XJournal_AI

final class TranscriptFindTests: XCTestCase {

    private let rows: [(id: Int, text: String, isPause: Bool)] = [
        (0, "yeah I been running this block since noon", false),
        (1, "···", true),
        (2, "Hold up. Let me cook", false),
        (3, "RUNNING laps around the beat", false)
    ]

    func testEmptyQueryReturnsNoMatches() {
        XCTAssertTrue(TranscriptFind.matchingIDs(query: "   ", rows: rows).isEmpty)
        XCTAssertTrue(TranscriptFind.matchingIDs(query: "", rows: rows).isEmpty)
    }

    func testFindIsCaseInsensitiveAndSkipsPauses() {
        XCTAssertEqual(TranscriptFind.matchingIDs(query: "running", rows: rows), [0, 3])
        XCTAssertEqual(TranscriptFind.matchingIDs(query: "HOLD", rows: rows), [2])
    }

    func testNoMatch() {
        XCTAssertTrue(TranscriptFind.matchingIDs(query: "xylophone", rows: rows).isEmpty)
    }
}
