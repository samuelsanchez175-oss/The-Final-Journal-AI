import XCTest
@testable import XJournal_AI

final class TranscriptRevisionTests: XCTestCase {

    func testOverlappingRevisionKeepsLaterWordingAndEarlierTime() {
        let first = TranscriptionSegment(text: "What going on?", timestamp: 0.0, duration: 0.8)
        let revised = TranscriptionSegment(text: "What the fuck going on?", timestamp: 1.0, duration: 1.1)
        let kept = TranscriptRevision.absorb([first], revised)
        XCTAssertEqual(kept.count, 1)
        XCTAssertEqual(kept[0].text, "What the fuck going on?")
        XCTAssertEqual(kept[0].timestamp, 0.0, accuracy: 0.001)
    }

    func testRevisionPullsTheFirstWordBackToTheEarlierTime() {
        let first = TranscriptionSegment(
            text: "What going on?",
            timestamp: 0.0,
            duration: 0.8,
            wordTimings: [
                WordTiming(text: "What", timestamp: 0.0, duration: 0.25),
                WordTiming(text: "going", timestamp: 0.25, duration: 0.25),
                WordTiming(text: "on?", timestamp: 0.50, duration: 0.30)
            ]
        )
        let revised = TranscriptionSegment(
            text: "What the fuck going on?",
            timestamp: 1.0,
            duration: 1.1,
            wordTimings: [
                WordTiming(text: "What", timestamp: 1.0, duration: 0.2),
                WordTiming(text: "the", timestamp: 1.2, duration: 0.2),
                WordTiming(text: "fuck", timestamp: 1.4, duration: 0.2),
                WordTiming(text: "going", timestamp: 1.6, duration: 0.2),
                WordTiming(text: "on?", timestamp: 1.8, duration: 0.3)
            ]
        )
        let kept = TranscriptRevision.absorb([first], revised)
        XCTAssertEqual(kept.count, 1)
        XCTAssertEqual(kept[0].wordTimings?.first?.timestamp ?? -1, 0.0, accuracy: 0.01)
        XCTAssertGreaterThan(kept[0].wordTimings?.first?.duration ?? 0, 1.0)
    }

    func testOpenPhraseReplacesInPlaceWhenItSettles() {
        let open = TranscriptionSegment(
            text: "What going",
            timestamp: 0.2,
            duration: 0.6,
            wordTimings: [
                WordTiming(text: "What", timestamp: 0.2, duration: 0.3),
                WordTiming(text: "going", timestamp: 0.5, duration: 0.3)
            ]
        )
        let settled = TranscriptionSegment(
            text: "What going on?",
            timestamp: 0.2,
            duration: 0.9,
            wordTimings: [
                WordTiming(text: "What", timestamp: 0.2, duration: 0.2),
                WordTiming(text: "going", timestamp: 0.4, duration: 0.3),
                WordTiming(text: "on?", timestamp: 0.7, duration: 0.4)
            ]
        )
        let kept = TranscriptRevision.absorb([open], settled)
        XCTAssertEqual(kept.count, 1)
        XCTAssertEqual(kept[0].text, "What going on?")
        XCTAssertEqual(kept[0].wordTimings?.count, 3)
    }

    func testALaterDifferentLineStays() {
        let first = TranscriptionSegment(text: "I'm saying.", timestamp: 4.0, duration: 0.4)
        let next = TranscriptionSegment(text: "Okay.", timestamp: 5.0, duration: 0.3)
        let kept = TranscriptRevision.absorb([first], next)
        XCTAssertEqual(kept.count, 2)
        XCTAssertEqual(kept.map(\.text), ["I'm saying.", "Okay."])
    }
}
