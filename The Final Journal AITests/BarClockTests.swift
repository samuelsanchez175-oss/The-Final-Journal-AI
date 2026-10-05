import XCTest
@testable import XJournal_AI

final class BarClockTests: XCTestCase {
    func testDefaultWrapPocketIs92() {
        let clock = BarClock.resolve(userBPM: nil)
        XCTAssertEqual(clock.bpm, 92, accuracy: 0.01)
        XCTAssertFalse(clock.hatsFolded)
        XCTAssertEqual(clock.barsPerMinute, 23, accuracy: 0.01)
        XCTAssertEqual(clock.secondsPerBar, 240.0 / 92.0, accuracy: 0.01)
        XCTAssertEqual(clock.pocket, .behind)
        XCTAssertEqual(clock.generateChunkBars, 4)
    }

    func testHatBed140FoldsOutOfDoubleTime() {
        let clock = BarClock.resolve(userBPM: 140)
        XCTAssertTrue(clock.hatsFolded)
        XCTAssertEqual(clock.bpm, 70, accuracy: 0.01)
        XCTAssertLessThan(clock.bpm, 118)
    }

    func testWrapCluster92DoesNotFold() {
        let clock = BarClock.resolve(userBPM: 92)
        XCTAssertFalse(clock.hatsFolded)
        XCTAssertEqual(clock.bpm, 92, accuracy: 0.01)
    }

    func testCoryGunz128DoesNotFoldTo64() {
        let (folded, didFold) = BarClock.foldHats(128)
        XCTAssertFalse(didFold)
        XCTAssertEqual(folded, 128, accuracy: 0.01)
    }

    func testFoldDisabledKeepsHatBed() {
        let clock = BarClock.resolve(userBPM: 140, foldHatsEnabled: false)
        XCTAssertFalse(clock.hatsFolded)
        XCTAssertEqual(clock.bpm, 140, accuracy: 0.01)
    }

    func testTrap180FoldsToWriteAt90() {
        let (folded, didFold) = BarClock.foldHats(180)
        XCTAssertTrue(didFold)
        XCTAssertEqual(folded, 90, accuracy: 0.01)
        let write = BarClock.resolve(userBPM: 180)
        XCTAssertTrue(write.hatsFolded)
        XCTAssertEqual(write.bpm, 90, accuracy: 0.01)
    }

    func testHeardClockDoesNotFoldHats() {
        let heard = BarClock.resolve(userBPM: 140, foldHatsEnabled: false)
        XCTAssertFalse(heard.hatsFolded)
        XCTAssertEqual(heard.bpm, 140, accuracy: 0.01)
    }

    func testQuickSelectIncludes180() {
        XCTAssertTrue(BarClock.quickSelectBPMs.contains(180))
    }

    func testPocketOnTopIsHonored() {
        let clock = BarClock.resolve(userBPM: 92, pocket: .onTop)
        XCTAssertEqual(clock.pocket, .onTop)
    }

    func testPunchBeatsParseAndToggle() {
        XCTAssertEqual(BarClock.punchBeats(from: "3,4"), [3, 4])
        XCTAssertEqual(BarClock.punchBeats(from: " 1 , 5 , 2 "), [1, 2])
        XCTAssertTrue(BarClock.punchBeats(from: "").isEmpty)
        let flipped = BarClock.togglingPunch([3, 4], beat: 3)
        XCTAssertEqual(flipped, [4])
        XCTAssertEqual(BarClock.togglingPunch(flipped, beat: 1), [1, 4])
        XCTAssertEqual(BarClock.encodePunchBeats([4, 1]), "1,4")
    }
}
