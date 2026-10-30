import XCTest
@testable import XJournal_AI

final class WrapSurfaceTests: XCTestCase {
    func testNote140ResolvesToFolded70WhenWrapOn() {
        let params = DirectedGenerationParams(gunnaWrap: true, wrapBpmSource: .note)
        XCTAssertEqual(params.resolvedWrapBPM(noteBPM: 140), 140)
        let clock = BarClock.resolve(userBPM: params.resolvedWrapBPM(noteBPM: 140), pocket: params.wrapPocket)
        XCTAssertTrue(clock.hatsFolded)
        XCTAssertEqual(clock.bpm, 70, accuracy: 0.01)
    }

    func testForce92IgnoresNoteBPM() {
        let params = DirectedGenerationParams(gunnaWrap: true, wrapBpmSource: .wrap92)
        XCTAssertEqual(params.resolvedWrapBPM(noteBPM: 140), 92)
    }

    func testTargetBarCountClampsTo4Or16() {
        XCTAssertEqual(DirectedGenerationParams(targetBarCount: 4).targetBarCount, 4)
        XCTAssertEqual(DirectedGenerationParams(targetBarCount: 16).targetBarCount, 16)
        XCTAssertEqual(DirectedGenerationParams(targetBarCount: 8).targetBarCount, 16)
    }

    func testWrapOffDefaultStillTrueOnEmptyInit() {
        XCTAssertTrue(DirectedGenerationParams().gunnaWrap)
        XCTAssertEqual(DirectedGenerationParams().punchGrammar, .couplet)
        XCTAssertEqual(DirectedGenerationParams().wrapPocket, .onTop)
        XCTAssertEqual(DirectedGenerationParams().targetBarCount, 16)
    }

    func testTempoSyllableTargetFollowsBeatNotFourWords() {
        let at92 = ModelGCoreCoordinatorV4.tempoSyllableTarget(bpm: 92)
        let at70 = ModelGCoreCoordinatorV4.tempoSyllableTarget(bpm: 70)
        XCTAssertEqual(at92, 10)
        XCTAssertEqual(at70, 11)
        XCTAssertGreaterThanOrEqual(at92 ?? 0, 7)
        XCTAssertNotEqual(at92, 4)
    }
}
