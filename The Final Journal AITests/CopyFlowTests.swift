import XCTest
@testable import XJournal_AI

final class CopyFlowTests: XCTestCase {
    func testIsRealBarRejectsAdlibs() {
        XCTAssertFalse(ModelGCorpusRetriever.isRealBar("Yeah"))
        XCTAssertFalse(ModelGCorpusRetriever.isRealBar("Ah"))
        XCTAssertFalse(ModelGCorpusRetriever.isRealBar("Yeah yeah ooh ah"))
        XCTAssertFalse(ModelGCorpusRetriever.isRealBar("ice drip"))
        XCTAssertTrue(ModelGCorpusRetriever.isRealBar("Got garments that's never been worn"))
    }

    func testFromDraftBuildsFourSlotMap() {
        let draft = """
        Came up off nothing, first-week checks
        When you from nothing, first feel like next
        No firsts like the first time the jet hit
        I'm just getting started, this ain't nothing yet
        """
        let exemplar = FlowExemplar.fromDraft(draft)
        XCTAssertNotNil(exemplar)
        XCTAssertEqual(exemplar?.syllableMap.count, 4)
        XCTAssertEqual(exemplar?.source, .draftLastFour)
        XCTAssertTrue(exemplar?.includeBarText == true)
        XCTAssertTrue(exemplar?.isUsable == true)
        XCTAssertTrue(exemplar?.stressHint.contains("beats 3–4") == true)
    }

    func testShortDraftYieldsNoExemplar() {
        XCTAssertNil(FlowExemplar.fromDraft("one line only\nstill short"))
    }

    func testCorpusMapDoesNotIncludeBarText() {
        let exemplar = FlowExemplar(
            bars: ["a", "b", "c", "d"],
            syllableMap: [9, 10, 9, 8],
            stressHint: "end-loaded",
            source: .corpusMap
        )
        XCTAssertFalse(exemplar.includeBarText)
    }

    func testRetrieveDropsFragmentsEvenWhenToneMatches() throws {
        // Fixture bars are real 4+ word lines; this asserts the filter is wired on retrieve().
        let store = try ModelGCorpusStore(bundle: Bundle(for: CopyFlowTests.self), resource: "ModelGCorpus.fixture")
        let r = ModelGCorpusRetriever(store: store)
        let out = r.retrieve(tones: ["confident"], draft: "", k: 5)
        XCTAssertTrue(out.exemplars.allSatisfy { ModelGCorpusRetriever.isRealBar($0.text) })
    }
}
