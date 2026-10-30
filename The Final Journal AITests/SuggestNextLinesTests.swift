import XCTest
@testable import XJournal_AI

final class SuggestNextLinesTests: XCTestCase {
    func testEmotionalToneCasesStayTheNarrativeEight() {
        XCTAssertEqual(
            EmotionalTone.allCases.map(\.rawValue),
            ["neutral", "confident", "aggressive", "melancholic", "reflective", "detached", "hopeful", "resentful"]
        )
    }

    func testDirectCorpusTonesMatchEmotionalTone() {
        XCTAssertEqual(CorpusTone.confident.emotionalTone, .confident)
        XCTAssertEqual(CorpusTone.aggressive.emotionalTone, .aggressive)
        XCTAssertEqual(CorpusTone.detached.emotionalTone, .detached)
    }

    func testCorpusNamesReachThePromptAndMapForOldCode() {
        let params = DirectedGenerationParams(corpusTones: [.luxurious, .paranoid, .calculated])
        XCTAssertEqual(params.promptToneNames, ["luxurious", "paranoid", "calculated"])
        XCTAssertEqual(params.selectedTones, [.confident, .melancholic, .detached])

        let metrics = RapMetrics(
            fullText: "one line",
            lastNLines: ["one line"],
            currentLineIndex: 0,
            syllableTarget: 12,
            rhymeTarget: nil,
            rhymeScheme: nil,
            cadence: CadenceSummary(averageSyllables: 12, syllableVariance: 0, lineCount: 1),
            averageSyllables: 12,
            syllableVariance: 0,
            bpm: nil,
            key: nil,
            scale: nil,
            syllableMin: 11,
            syllableMax: 13
        )
        let intent = GenerationIntent(
            theme: "continue",
            tone: .confident,
            perspective: .flexing,
            energyLevel: .medium,
            mustInclude: [],
            mustAvoid: []
        )
        let prompt = DirectedGenerationPromptBuilder.buildUserPrompt(
            params: params,
            metrics: metrics,
            intent: intent
        )
        XCTAssertTrue(prompt.contains("luxurious"))
        XCTAssertTrue(prompt.contains("paranoid"))
        XCTAssertTrue(prompt.contains("calculated"))
    }

    func testEmptyNoteUsesTheNeutralDirection() {
        XCTAssertEqual(
            DirectedGenerationParams.directionFromOpenNote(noteText: "  ", transcript: nil),
            DirectedGenerationParams.defaultUserPromptWhenEmpty
        )
    }

    func testDirectionUsesTheNoteAndTheTranscript() {
        let direction = DirectedGenerationParams.directionFromOpenNote(
            noteText: "ice on the wrist",
            transcript: "yeah I said it"
        )
        XCTAssertTrue(direction.contains("ice on the wrist"))
        XCTAssertTrue(direction.contains("yeah I said it"))
        XCTAssertFalse(direction.contains("What should the next lines"))
    }

    func testSyllableBandsMatchTheVaultGroups() {
        XCTAssertEqual(SyllableBand.tight.low, 8)
        XCTAssertEqual(SyllableBand.tight.high, 10)
        XCTAssertEqual(SyllableBand.standard.low, 11)
        XCTAssertEqual(SyllableBand.standard.high, 13)
        XCTAssertEqual(SyllableBand.dense.low, 14)
        XCTAssertEqual(SyllableBand.dense.high, 16)
        XCTAssertEqual(SyllableBand.matching(min: 11, max: 13), .standard)
        XCTAssertNil(SyllableBand.matching(min: nil, max: nil))
    }

    func testV7IsNotCallable() {
        XCTAssertEqual(SuggestNextLinesModel.v6.title, "Current (Model G v4)")
        XCTAssertEqual(SuggestNextLinesModel.v7.title, "V7")
        XCTAssertTrue(SuggestNextLinesModel.v6.isCallable)
        XCTAssertFalse(SuggestNextLinesModel.v7.isCallable)
    }
}
