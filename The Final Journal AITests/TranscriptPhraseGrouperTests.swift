import XCTest
@testable import XJournal_AI

final class TranscriptPhraseGrouperTests: XCTestCase {

    func testWordsSharingTheSameTimestampBecomeOneRow() {
        let segments = (0..<8).map { i in
            TranscriptionSegment(
                text: ["yeah", "I", "been", "running", "this", "block", "since", "noon"][i],
                timestamp: 160.05 + Double(i) * 0.08,
                duration: 0.12
            )
        }
        let phrases = TranscriptPhraseGrouper.phrases(from: segments).filter { !$0.isPause }
        XCTAssertEqual(phrases.count, 1)
        XCTAssertEqual(TranscriptPhraseGrouper.displayTimestamp(phrases[0].timestamp), "2:40")
        XCTAssertEqual(phrases[0].text, "yeah I been running this block since noon")
        XCTAssertEqual(phrases[0].wordTimings.count, 8)
    }

    func testShortPeriodStaysWithTheNextWordsWhenTheyFit() {
        let segments = [
            TranscriptionSegment(text: "Hold up.", timestamp: 12.0, duration: 0.8),
            TranscriptionSegment(text: "Let me cook", timestamp: 12.9, duration: 0.7)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments).filter { !$0.isPause }
        XCTAssertEqual(phrases.count, 1)
        XCTAssertEqual(phrases[0].text, "Hold up. Let me cook")
    }

    func testPeriodAfterAHalfBarStartsANewRow() {
        let words = ["city", "water", "under."]
        let syllables = words.reduce(0) { $0 + Syllabifier.syllableCount(word: $1) }
        XCTAssertGreaterThanOrEqual(syllables, TranscriptPhraseGrouper.halfBarSyllables)
        let segments = words.enumerated().map { index, word in
            TranscriptionSegment(text: word, timestamp: 4.0 + Double(index) * 0.3, duration: 0.25)
        } + [TranscriptionSegment(text: "now", timestamp: 5.0, duration: 0.25)]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments).filter { !$0.isPause }
        XCTAssertEqual(phrases.count, 2)
        XCTAssertEqual(phrases[0].text, "city water under.")
        XCTAssertEqual(phrases[1].text, "now")
    }

    func testBreathKeepsAShortAsideOnItsOwnRow() {
        let segments = [
            TranscriptionSegment(text: "Okay.", timestamp: 5.0, duration: 0.3),
            TranscriptionSegment(text: "Next line here", timestamp: 6.2, duration: 0.6)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments).filter { !$0.isPause }
        XCTAssertEqual(phrases.map(\.text), ["Okay.", "Next line here"])
    }

    func testOverflowWordsMoveToTheNextRow() {
        let segments = [
            TranscriptionSegment(text: "One time now", timestamp: 10.0, duration: 0.4),
            TranscriptionSegment(text: "let's get up", timestamp: 10.45, duration: 0.4),
            TranscriptionSegment(text: "in this bitch.", timestamp: 10.90, duration: 0.4)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments, fitsLine: { $0.count <= 25 }).filter { !$0.isPause }
        XCTAssertEqual(phrases.map(\.text), ["One time now let's get up", "in this bitch."])
    }

    func testWideBarSplitsAtBeatThree() {
        let fits: @Sendable (String) -> Bool = { $0.count <= 24 }
        let segments = [
            TranscriptionSegment(text: "alpha", timestamp: 0.20, duration: 0.35),
            TranscriptionSegment(text: "bravo", timestamp: 0.70, duration: 0.35),
            TranscriptionSegment(text: "charlie", timestamp: 1.20, duration: 0.35),
            TranscriptionSegment(text: "delta", timestamp: 2.05, duration: 0.35),
            TranscriptionSegment(text: "echo", timestamp: 2.50, duration: 0.35),
            TranscriptionSegment(text: "foxtrot", timestamp: 2.95, duration: 0.35)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments, bpm: 63, fitsLine: fits).filter { !$0.isPause }
        XCTAssertEqual(phrases.map(\.text), ["alpha bravo charlie", "delta echo foxtrot"])
        XCTAssertEqual(TranscriptPhraseGrouper.beatInBar(time: phrases[1].timestamp, bpm: 63), 3)
    }

    func testSetupPunchSplitStaysSplitWhenTheHalvesWouldFitTogether() {
        let segments = [
            TranscriptionSegment(text: "yo", timestamp: 1.70, duration: 0.25),
            TranscriptionSegment(text: "city", timestamp: 2.05, duration: 0.22),
            TranscriptionSegment(text: "water", timestamp: 2.32, duration: 0.22),
            TranscriptionSegment(text: "under.", timestamp: 2.59, duration: 0.22),
            TranscriptionSegment(text: "now", timestamp: 2.95, duration: 0.22),
            TranscriptionSegment(text: "we", timestamp: 3.20, duration: 0.18),
            TranscriptionSegment(text: "roll", timestamp: 3.42, duration: 0.18)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments, bpm: 63, fitsLine: { $0.count <= 24 })
            .filter { !$0.isPause }
        XCTAssertEqual(phrases.map(\.text), ["yo", "city water under.", "now we roll"])
    }

    func testFullBarStaysOneRowWhenItFits() {
        let segments = [
            TranscriptionSegment(text: "alpha", timestamp: 0.20, duration: 0.35),
            TranscriptionSegment(text: "bravo", timestamp: 0.70, duration: 0.35),
            TranscriptionSegment(text: "charlie", timestamp: 1.20, duration: 0.35),
            TranscriptionSegment(text: "delta", timestamp: 2.05, duration: 0.35),
            TranscriptionSegment(text: "echo", timestamp: 2.50, duration: 0.35),
            TranscriptionSegment(text: "foxtrot", timestamp: 2.95, duration: 0.35)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments, bpm: 63, fitsLine: { $0.count <= 80 }).filter { !$0.isPause }
        XCTAssertEqual(phrases.count, 1)
        XCTAssertEqual(phrases[0].text, "alpha bravo charlie delta echo foxtrot")
    }

    func testMeasuredColumnRejectsALineWiderThanTheColumn() {
        XCTAssertTrue(TranscriptPhraseGrouper.fits("I", columnWidth: 200))
        XCTAssertFalse(TranscriptPhraseGrouper.fits("One time now, let's get up in this bitch.", columnWidth: 40))
    }

    func testThreeSecondBreathSplitsPhrases() {
        let segments = [
            TranscriptionSegment(text: "first bar", timestamp: 10.0, duration: 0.8),
            TranscriptionSegment(text: "second bar", timestamp: 14.0, duration: 0.8)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments).filter { !$0.isPause }
        XCTAssertEqual(phrases.count, 2)
        XCTAssertEqual(phrases[0].text, "first bar")
        XCTAssertEqual(phrases[1].text, "second bar")
    }

    func testSameClockLabelMergesWhenThereIsNoSentenceOrBreath() {
        let segments = [
            TranscriptionSegment(text: "running", timestamp: 160.10, duration: 0.2),
            TranscriptionSegment(text: "laps", timestamp: 160.80, duration: 0.2)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments).filter { !$0.isPause }
        XCTAssertEqual(phrases.count, 1)
        XCTAssertEqual(phrases[0].text, "running laps")
        XCTAssertEqual(TranscriptPhraseGrouper.displayTimestamp(phrases[0].timestamp), "2:40")
    }

    func testSixSecondGapInsertsPauseMark() {
        let segments = [
            TranscriptionSegment(text: "hook", timestamp: 5.0, duration: 1.0),
            TranscriptionSegment(text: "verse", timestamp: 13.0, duration: 1.0)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments)
        XCTAssertEqual(phrases.count, 3)
        XCTAssertTrue(phrases[1].isPause)
        XCTAssertEqual(phrases[1].text, "···")
        XCTAssertEqual(phrases[0].text, "hook")
        XCTAssertEqual(phrases[2].text, "verse")
    }

    func testTwoSecondGapIsParagraphNotALyric() {
        let segments = [
            TranscriptionSegment(text: "one", timestamp: 1.0, duration: 0.4),
            TranscriptionSegment(text: "two", timestamp: 3.6, duration: 0.4)
        ]
        let phrases = TranscriptPhraseGrouper.phrases(from: segments)
        XCTAssertEqual(phrases.count, 3)
        XCTAssertTrue(phrases[1].isPause)
        XCTAssertEqual(phrases[1].text, "")
        XCTAssertEqual(phrases[0].text, "one")
        XCTAssertEqual(phrases[2].text, "two")
    }

    func testPhraseWithWordTimingsStaysOneRow() {
        let words = [
            WordTiming(text: "keep", timestamp: 30.0, duration: 0.2),
            WordTiming(text: "it", timestamp: 30.2, duration: 0.15),
            WordTiming(text: "tucked", timestamp: 30.4, duration: 0.3)
        ]
        let segment = TranscriptionSegment(
            text: "keep it tucked",
            timestamp: 30.0,
            duration: 0.7,
            wordTimings: words
        )
        let phrases = TranscriptPhraseGrouper.phrases(from: [segment]).filter { !$0.isPause }
        XCTAssertEqual(phrases.count, 1)
        XCTAssertEqual(phrases[0].text, "keep it tucked")
        XCTAssertEqual(phrases[0].wordTimings.count, 3)
    }

    func testLongPhraseSplitsNearTwoLines() {
        let words = (0..<40).map { i in
            TranscriptionSegment(
                text: "word\(i)",
                timestamp: Double(i) * 0.12,
                duration: 0.1
            )
        }
        let phrases = TranscriptPhraseGrouper.phrases(from: words).filter { !$0.isPause }
        XCTAssertGreaterThan(phrases.count, 1)
        for phrase in phrases {
            XCTAssertLessThanOrEqual(phrase.text.count, TranscriptPhraseGrouper.maxPhraseChars + 12)
        }
    }

    func testDisplayTimestampFormat() {
        XCTAssertEqual(TranscriptPhraseGrouper.displayTimestamp(0), "0:00")
        XCTAssertEqual(TranscriptPhraseGrouper.displayTimestamp(160), "2:40")
        XCTAssertEqual(TranscriptPhraseGrouper.displayTimestamp(3723), "1:02:03")
    }

    func testTimelineGroupsAboutEveryFiveSeconds() {
        let segments = (0..<13).map { index in
            TranscriptionSegment(text: "w\(index)", timestamp: Double(index), duration: 0.25)
        }
        let phrases = TranscriptPhraseGrouper.timelinePhrases(from: segments)
        XCTAssertEqual(phrases.map { TranscriptPhraseGrouper.displayTimestamp($0.timestamp) }, ["0:00", "0:05", "0:10"])
        XCTAssertEqual(phrases[0].text, "w0 w1 w2 w3 w4")
        XCTAssertEqual(phrases[1].text, "w5 w6 w7 w8 w9")
        XCTAssertEqual(phrases[2].text, "w10 w11 w12")
    }

    func testTimelineKeepsAPunchWithItsSetupWhenItCrossesFiveSeconds() {
        let segments = [
            TranscriptionSegment(text: "eye", timestamp: 3.2, duration: 0.3),
            TranscriptionSegment(text: "over", timestamp: 4.0, duration: 0.3),
            TranscriptionSegment(text: "my", timestamp: 4.7, duration: 0.3),
            TranscriptionSegment(text: "shoulder", timestamp: 5.2, duration: 0.3),
            TranscriptionSegment(text: "like", timestamp: 5.9, duration: 0.3),
            TranscriptionSegment(text: "next", timestamp: 9.0, duration: 0.3)
        ]
        let phrases = TranscriptPhraseGrouper.timelinePhrases(from: segments)
        XCTAssertEqual(phrases.count, 2)
        XCTAssertEqual(phrases[0].text, "eye over my shoulder like")
        XCTAssertEqual(phrases[1].text, "next")
    }

    func testTimelineKeepsOneBarTogether() {
        let segments = [
            TranscriptionSegment(text: "set", timestamp: 0.3, duration: 0.3),
            TranscriptionSegment(text: "up", timestamp: 1.2, duration: 0.3),
            TranscriptionSegment(text: "punch", timestamp: 2.4, duration: 0.3),
            TranscriptionSegment(text: "line", timestamp: 3.2, duration: 0.3),
            TranscriptionSegment(text: "next", timestamp: 4.1, duration: 0.3),
            TranscriptionSegment(text: "bar", timestamp: 5.2, duration: 0.3)
        ]
        let phrases = TranscriptPhraseGrouper.timelinePhrases(from: segments, bpm: 63)
        XCTAssertEqual(phrases.count, 2)
        XCTAssertEqual(phrases[0].text, "set up punch line")
        XCTAssertEqual(phrases[1].text, "next bar")
        XCTAssertEqual(TranscriptPhraseGrouper.beatInBar(time: phrases[1].timestamp, bpm: 63), 1)
    }

    func testIncomingWordsDoNotResplitAnEarlierTimelineRow() {
        let earlier = [
            TranscriptionSegment(text: "keep", timestamp: 0.2, duration: 0.3),
            TranscriptionSegment(text: "this", timestamp: 1.0, duration: 0.3),
            TranscriptionSegment(text: "row", timestamp: 3.5, duration: 0.3)
        ]
        let first = TranscriptPhraseGrouper.timelinePhrases(from: earlier)
        let later = earlier + [
            TranscriptionSegment(text: "new", timestamp: 6.2, duration: 0.3),
            TranscriptionSegment(text: "line", timestamp: 7.0, duration: 0.3)
        ]
        let second = TranscriptPhraseGrouper.timelinePhrases(from: later)
        XCTAssertEqual(first.count, 1)
        XCTAssertEqual(second.count, 2)
        XCTAssertEqual(second[0].text, first[0].text)
        XCTAssertEqual(second[1].text, "new line")
    }
}
