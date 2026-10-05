import XCTest
@testable import XJournal_AI

final class AudioSummaryServiceTests: XCTestCase {

    func testExtractiveSummaryKeepsEarlySentences() {
        let text = "First bar hits the pocket. Second bar talks money. Third bar is the hook. Fourth bar fades out. Fifth bar is extra."
        let summary = AudioSummaryService.shared.extractiveSummary(from: text)
        XCTAssertTrue(summary.contains("First bar"))
        XCTAssertFalse(summary.contains("Fifth bar"))
    }

    func testEmptyTranscriptionThrows() async {
        do {
            _ = try await AudioSummaryService.shared.generateSummary(from: "   ")
            XCTFail("Expected empty transcription to fail")
        } catch {
            XCTAssertTrue(error.localizedDescription.lowercased().contains("transcribe")
                          || error.localizedDescription.lowercased().contains("nothing"))
        }
    }
}
