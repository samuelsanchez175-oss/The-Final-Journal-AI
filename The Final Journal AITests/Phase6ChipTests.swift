import XCTest
@testable import XJournal_AI

final class Phase6ChipTests: XCTestCase {
    func testDefaultsStaySparseExceptSetupOnlyRefs() {
        let params = DirectedGenerationParams()
        XCTAssertTrue(params.setupOnlyRefs)
        XCTAssertFalse(params.storyArc)
        XCTAssertFalse(params.lyricalPainting)
        XCTAssertFalse(params.breakTheRun)
        XCTAssertTrue(params.scatFirst)
        XCTAssertTrue(params.acrosticWord.isEmpty)
        XCTAssertEqual(params.wrapPocket, .onTop)
        let block = params.schemeChipBlock()
        XCTAssertTrue(block.contains("SETUP-ONLY REFS"))
        XCTAssertTrue(block.contains("RHYTHM FIRST"))
        XCTAssertFalse(block.contains("ACROSTIC"))
        XCTAssertFalse(block.contains("STORY ARC"))
        XCTAssertFalse(block.contains("DESCRIBE THE FLOW"))
        XCTAssertFalse(block.contains("BREAK THE RUN"))
    }

    func testSetupOnlyRefsCanTurnOff() {
        let params = DirectedGenerationParams(scatFirst: false, setupOnlyRefs: false)
        XCTAssertEqual(params.schemeChipBlock(), "")
    }

    func testAcrosticStripsToLetters() {
        let params = DirectedGenerationParams(acrosticWord: "Gunna 16", setupOnlyRefs: false)
        XCTAssertEqual(params.resolvedAcrostic, "GUNNA")
        XCTAssertTrue(params.schemeChipBlock().contains("ACROSTIC"))
        XCTAssertTrue(params.schemeChipBlock().contains("spells GUNNA"))
        XCTAssertFalse(params.resolvedAcrostic.contains("16"))
    }

    func testStoryArcForcesSixteen() {
        let params = DirectedGenerationParams(targetBarCount: 4, storyArc: true)
        XCTAssertEqual(params.targetBarCount, 16)
        XCTAssertTrue(params.schemeChipBlock().contains("STORY ARC"))
    }

    func testFourBarJobStaysFourWithoutStoryArc() {
        XCTAssertEqual(DirectedGenerationParams(targetBarCount: 4).targetBarCount, 4)
    }

    func testEachOptionalChipIsOneFlag() {
        let painting = DirectedGenerationParams(lyricalPainting: true, setupOnlyRefs: false)
        XCTAssertTrue(painting.schemeChipBlock().contains("DESCRIBE THE FLOW"))

        let brk = DirectedGenerationParams(breakTheRun: true, scatFirst: false, setupOnlyRefs: false, minEndRhymeLines: 4)
        XCTAssertTrue(brk.schemeChipBlock().contains("BREAK THE RUN"))
        XCTAssertTrue(brk.schemeChipBlock().contains("3–4 bars"))
        XCTAssertFalse(brk.schemeChipBlock().contains("after 4 bars"))

        let scat = DirectedGenerationParams(scatFirst: true, setupOnlyRefs: false)
        XCTAssertTrue(scat.schemeChipBlock().contains("RHYTHM FIRST"))
        XCTAssertTrue(scat.schemeChipBlock().contains("COPY-FLOW"))
    }
}
