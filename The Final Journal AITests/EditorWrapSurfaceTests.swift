import XCTest
@testable import XJournal_AI

final class EditorWrapSurfaceTests: XCTestCase {

    // MARK: BarClock beat-in-bar

    func testBeatInBarStartsOnOne() {
        let clock = BarClock.resolve(userBPM: 92, foldHatsEnabled: false)
        XCTAssertEqual(clock.beatInBar(elapsed: 0), 1)
    }

    func testBeatInBarHitsPunchOnThreeAndFour() {
        let clock = BarClock.resolve(userBPM: 60, foldHatsEnabled: false)
        // 60 BPM → 1s per beat. t=0 → 1, t=1 → 2, t=2 → 3, t=3 → 4, t=4 → 1
        XCTAssertEqual(clock.beatInBar(elapsed: 0.0), 1)
        XCTAssertEqual(clock.beatInBar(elapsed: 1.0), 2)
        XCTAssertEqual(clock.beatInBar(elapsed: 2.0), 3)
        XCTAssertEqual(clock.beatInBar(elapsed: 3.0), 4)
        XCTAssertEqual(clock.beatInBar(elapsed: 4.0), 1)
        XCTAssertTrue(clock.isPunchBeat(3))
        XCTAssertTrue(clock.isPunchBeat(4))
        XCTAssertFalse(clock.isPunchBeat(1))
        XCTAssertFalse(clock.isPunchBeat(2))
    }

    // MARK: Syllable count buttons

    func testWritingRowHeightTracksFontSizeAndStaysUnderOldFortyFourFloor() {
        let small = EditorWritingMetrics.rowHeight(fontSize: 12)
        let body = EditorWritingMetrics.rowHeight(fontSize: 17)
        let large = EditorWritingMetrics.rowHeight(fontSize: 28)
        XCTAssertLessThan(small, body)
        XCTAssertLessThan(body, large)
        XCTAssertLessThan(body, 44)
        let square = SyllableCountButtonMetrics.size(visualHeight: body, rowHeight: body)
        XCTAssertEqual(square.width, body, accuracy: 0.5)
        XCTAssertEqual(square.height, body, accuracy: 0.5)
    }

    func testSyllableCountButtonIsSquareLikeForOneVisualLine() {
        let rowH: CGFloat = 28
        let size = SyllableCountButtonMetrics.size(visualHeight: rowH, rowHeight: rowH)
        XCTAssertEqual(size.width, rowH)
        XCTAssertEqual(size.height, rowH)
        XCTAssertEqual(size.width, size.height)
        XCTAssertTrue(SyllableCountButtonMetrics.isSquareLike(visualHeight: rowH, rowHeight: rowH))
    }

    func testSyllableCountButtonIsTallerRectangleWhenBarWrapsTwoLines() {
        let rowH: CGFloat = 28
        let oneLine = SyllableCountButtonMetrics.size(visualHeight: rowH, rowHeight: rowH)
        let size = SyllableCountButtonMetrics.size(visualHeight: rowH * 2, rowHeight: rowH)
        XCTAssertEqual(size.width, oneLine.width)
        XCTAssertEqual(size.width, rowH)
        XCTAssertEqual(size.height, rowH * 2)
        XCTAssertEqual(size.height, size.width * 2)
        XCTAssertFalse(SyllableCountButtonMetrics.isSquareLike(visualHeight: rowH * 2, rowHeight: rowH))
    }

    func testSyllableCountButtonSitsInTheLeftGutter() {
        let rowH: CGFloat = 28
        let frame = SyllableCountButtonMetrics.frame(originY: 10, visualHeight: rowH, rowHeight: rowH)
        XCTAssertEqual(frame.minX, SyllableCountButtonMetrics.inset)
        XCTAssertLessThan(frame.maxX, SyllableCountButtonMetrics.gutterWidth)
        XCTAssertEqual(frame.minY, 10 + SyllableCountButtonMetrics.verticalInset)
    }

    func testSyllableCountButtonsUseExactCounts() {
        XCTAssertEqual(SyllableCountButtonMetrics.quickSelectCounts, [6, 7, 8, 9, 10, 11, 12, 13, 14, 16])
        XCTAssertTrue(SyllableCountButtonMetrics.isExactCount(10, min: 10, max: 10))
        XCTAssertFalse(SyllableCountButtonMetrics.isExactCount(10, min: 8, max: 10))
        XCTAssertFalse(SyllableCountButtonMetrics.isExactCount(10, min: nil, max: nil))
    }

    func testSyllableCountPillShowsOneNumberForExactCount() {
        XCTAssertEqual(SyllableCountButtonMetrics.pillLabel(min: 10, max: 10), "10 / bar")
        XCTAssertEqual(SyllableCountButtonMetrics.pillLabel(min: 8, max: 10), "8–10 / bar")
        XCTAssertEqual(SyllableCountButtonMetrics.pillLabel(min: nil, max: nil), "Bar length")
    }

    func testSyllableCountHitTargetMeetsFortyFourPoints() {
        let rowH: CGFloat = 28
        let visual = SyllableCountButtonMetrics.frame(originY: 0, visualHeight: rowH, rowHeight: rowH)
        let hit = SyllableCountButtonMetrics.hitFrame(for: visual)
        XCTAssertGreaterThanOrEqual(hit.width, 44)
        XCTAssertGreaterThanOrEqual(hit.height, 44)
        XCTAssertLessThanOrEqual(hit.maxX, SyllableCountButtonMetrics.gutterWidth)
        XCTAssertEqual(visual.width, rowH)
        XCTAssertEqual(visual.height, rowH - SyllableCountButtonMetrics.verticalInset * 2)
    }

    func testOverlappingHitsResolveToTheNearestBar() {
        let rowH: CGFloat = 28
        let top = SyllableCountButtonMetrics.frame(originY: 0, visualHeight: rowH, rowHeight: rowH)
        let bottom = SyllableCountButtonMetrics.frame(originY: rowH, visualHeight: rowH, rowHeight: rowH)
        let frames = [top, bottom]
        let inTop = CGPoint(x: top.midX, y: top.midY)
        let inBottom = CGPoint(x: bottom.midX, y: bottom.midY)
        XCTAssertEqual(SyllableCountButtonMetrics.nearestIndex(to: inTop, visualFrames: frames), 0)
        XCTAssertEqual(SyllableCountButtonMetrics.nearestIndex(to: inBottom, visualFrames: frames), 1)
    }

    // MARK: Line syllable counts

    func testLineSyllableCountsMatchVerseLines() {
        let verse = """
        I walk the block
        Each step I take
        """
        let counts = LineSyllableCounter.counts(for: verse)
        XCTAssertEqual(counts.count, 2)
        XCTAssertEqual(counts[0], ["I", "walk", "the", "block"].map { Syllabifier.syllableCount(word: $0) }.reduce(0, +))
        XCTAssertEqual(counts[1], ["Each", "step", "I", "take"].map { Syllabifier.syllableCount(word: $0) }.reduce(0, +))
        XCTAssertGreaterThan(counts[0], 0)
        XCTAssertGreaterThan(counts[1], 0)
    }

    func testEmptyLineCountsAsZero() {
        XCTAssertEqual(LineSyllableCounter.counts(for: "hello\n\nworld"), [2, 0, 1])
    }

    func testRhythmAndCityCountTwoSyllables() {
        XCTAssertEqual(Syllabifier.syllableCount(word: "rhythm"), 2)
        XCTAssertEqual(Syllabifier.syllableCount(word: "rhythms"), 2)
        XCTAssertEqual(Syllabifier.syllableCount(word: "city"), 2)
        XCTAssertEqual(Syllabifier.syllableCount(word: "counts"), 1)
    }

    func testStreetEchoLineTwoIsEightSyllables() {
        let line = "Each step I take, the rhythm counts"
        XCTAssertEqual(LineSyllableCounter.syllableCount(forLine: line), 8)
    }

    func testStreetEchoLastLineIsEightSyllables() {
        let line = "The city hums in flesh and bone"
        XCTAssertEqual(LineSyllableCounter.syllableCount(forLine: line), 8)
    }

    func testDigitsCountAsSpokenSyllables() {
        XCTAssertEqual(Syllabifier.syllableCount(word: "3"), 1)
        XCTAssertEqual(Syllabifier.syllableCount(word: "7"), 2)
        XCTAssertEqual(Syllabifier.syllableCount(word: "24"), 3)
    }

    func testLoneLettersCountAsLetterNames() {
        XCTAssertEqual(Syllabifier.syllableCount(word: "s"), 1)
        XCTAssertEqual(Syllabifier.syllableCount(word: "S"), 1)
        XCTAssertEqual(Syllabifier.syllableCount(word: "w"), 3)
    }

    func testThreeSSummerCountsNumberAndLetter() {
        // It's(1) a(1) three(1) ess(1) sum-mer(2)
        XCTAssertEqual(LineSyllableCounter.syllableCount(forLine: "It's a 3 s summer"), 6)
    }

    // MARK: Honest 429

    func testRateLimitDoesNotSendYouToAPIKeySettings() {
        XCTAssertEqual(AppErrorRecovery.destination(for: RapAPIError.rateLimitExceeded(retryAfterSeconds: 30)), .retryGenerate)
        XCTAssertEqual(AppErrorRecovery.destination(for: ModelGLLMError.rateLimitExceeded(retryAfterSeconds: 12)), .retryGenerate)
        XCTAssertEqual(AppErrorRecovery.destination(forMessage: "HTTP 429 Too Many Requests"), .retryGenerate)
        XCTAssertEqual(AppErrorRecovery.destination(forMessage: "rate limit exceeded"), .retryGenerate)
    }

    func testRateLimitCopyDoesNotBlameTheKey() {
        let api = AppErrorRecovery.shortMessage(for: RapAPIError.rateLimitExceeded(retryAfterSeconds: 60))
        XCTAssertFalse(api.lowercased().contains("api key"))
        XCTAssertTrue(api.lowercased().contains("usage limit") || api.lowercased().contains("wait"))

        let llm = AppErrorRecovery.shortMessage(for: ModelGLLMError.rateLimitExceeded(retryAfterSeconds: 20))
        XCTAssertFalse(llm.lowercased().contains("api key"))
        XCTAssertTrue(llm.lowercased().contains("key is fine") || llm.lowercased().contains("usage limit"))
    }

    func testMissingKeyStillOpensAPISettings() {
        XCTAssertEqual(AppErrorRecovery.destination(for: RapAPIError.missingAPIKey), .profileAI)
    }

    func testModelGCoreFailedCopyDoesNotBlameTheKey() {
        let msg = RapAPIError.modelGCoreFailed.inAppNotificationMessage.lowercased()
        XCTAssertFalse(msg.contains("api key"))
        let long = RapAPIError.modelGCoreFailed.errorDescription?.lowercased() ?? ""
        XCTAssertFalse(long.contains("api key"))
    }

    // MARK: Same pocket, new nouns

    func testSamePocketNewNounsKeepsWrapAndCopyFlow() {
        let params = DirectedGenerationParams.samePocketNewNouns()
        XCTAssertTrue(params.gunnaWrap)
        XCTAssertTrue(params.copyLastFourRhythm)
        XCTAssertTrue(params.scatFirst)
        XCTAssertTrue(params.userPrompt.lowercased().contains("pocket"))
        XCTAssertTrue(params.userPrompt.lowercased().contains("noun"))
    }

    // MARK: One syllable system

    func testGenerateLineCountMatchesGutterForDigitsAndLetters() {
        let line = "It's a 3 s summer"
        XCTAssertEqual(SyllableEngine.lineSyllableCount(line), 6)
        XCTAssertEqual(LineSyllableCounter.syllableCount(forLine: line), 6)
    }

    func testRapMetricsTargetUsesGutterCounts() {
        let text = "It's a 3 s summer\nIt's a 3 s summer"
        let metrics = RapAnalysisEngine().extractMetrics(text: text, highlights: [])
        XCTAssertEqual(metrics.syllableTarget, 6)
        XCTAssertEqual(metrics.averageSyllables, 6, accuracy: 0.01)
    }

    // MARK: 429 surfaces, not Model G failed

    func testEmptyCoreSetsWith429ThrowRateLimitNotCoreFailed() {
        let err = RapAPIError.rateLimitExceeded(retryAfterSeconds: 12)
        XCTAssertThrowsError(try ModelGCoreSetResult.recordsOrThrow([.failure(err), .failure(err)])) { thrown in
            guard let api = thrown as? RapAPIError, case .rateLimitExceeded(let seconds) = api else {
                return XCTFail("expected rateLimitExceeded, got \(thrown)")
            }
            XCTAssertEqual(seconds, 12)
        }
    }

    func testOneGoodSetWinsEvenIfSibling429s() throws {
        let record = GeneratedRecord(
            hook: "",
            bars: ["keep the pocket moving"],
            modelGMomentBarIndices: [],
            averageBarScore: 80
        )
        let records = try ModelGCoreSetResult.recordsOrThrow([
            .success(record),
            .failure(RapAPIError.rateLimitExceeded(retryAfterSeconds: 8))
        ])
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].bars, ["keep the pocket moving"])
    }

    // MARK: Shared rhyme list

    func testDictionaryNoiseIsNotARhymeHeadword() {
        XCTAssertFalse(RhymeFinder.isUsableRhymeHeadword("a.d."))
        XCTAssertFalse(RhymeFinder.isUsableRhymeHeadword("ab(2)"))
        XCTAssertFalse(RhymeFinder.isUsableRhymeHeadword("ab"))
        XCTAssertTrue(RhymeFinder.isUsableRhymeHeadword("light"))
        XCTAssertTrue(RhymeFinder.isUsableRhymeHeadword("tonight"))
    }

    func testRapUsefulSortPutsShorterWordsFirst() {
        XCTAssertEqual(RhymeFinder.sortRapUseful(["bright", "light", "nightlight"]), ["light", "bright", "nightlight"])
    }

    func testGhostInsertsOnTheLineNotAfterTrailingNewlines() {
        let body = "the city at night\n\n"
        let out = GhostSuggestionEngine.insertingCandidate("light", into: body)
        XCTAssertEqual(out, "the city at night light\n\n")
    }
}
