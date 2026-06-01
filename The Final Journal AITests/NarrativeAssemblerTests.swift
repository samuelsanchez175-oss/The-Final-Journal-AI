import XCTest
@testable import The_Final_Journal_AI

final class NarrativeAssemblerTests: XCTestCase {

    func testEmptyDraftStillValidates() {
        let emptyDraft = NarrativeDraft(
            primaryThemes: nil,
            secondaryThemes: nil,
            emotionalTone: nil,
            narrativePhase: nil,
            perspective: nil,
            entities: nil
        )

        let emptySignal = SignalProfile(
            themeCandidates: nil,
            emotionalCues: nil,
            perspectiveHint: nil,
            entityHints: nil
        )

        let analysis = NarrativeAssembler.assemble(
            from: emptyDraft,
            signal: emptySignal
        )

        XCTAssertFalse(analysis.primaryThemes.isEmpty)
        XCTAssertEqual(analysis.emotionalTone, .neutral)
        XCTAssertEqual(analysis.narrativePhase, .reflection)
        XCTAssertFalse(analysis.summary.isEmpty)
    }

    func testMissingThemesNeverCrash() {
        let draftWithoutThemes = NarrativeDraft(
            primaryThemes: [],
            secondaryThemes: nil,
            emotionalTone: .confident,
            narrativePhase: nil,
            perspective: nil,
            entities: nil
        )

        let signalWithFallback = SignalProfile(
            themeCandidates: ["resilience"],
            emotionalCues: nil,
            perspectiveHint: nil,
            entityHints: nil
        )

        let analysis = NarrativeAssembler.assemble(
            from: draftWithoutThemes,
            signal: signalWithFallback
        )

        XCTAssertEqual(analysis.primaryThemes.first, "resilience")
        XCTAssertNoThrow(analysis.summary)
    }
}
