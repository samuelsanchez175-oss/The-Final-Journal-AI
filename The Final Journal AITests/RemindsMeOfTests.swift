import XCTest
@testable import XJournal_AI

final class RemindsMeOfTests: XCTestCase {

    func testMeaningNeighborhoodUsesPriorsNotFollowingBars() {
        func row(_ id: String, _ line: String) -> BarHitsCatalogStore.Row {
            BarHitsCatalogStore.Row(
                id: id, line: line, artist: "NoCap", song: "On Purpose",
                syllables: 8, endWord: "x", phoneticClass: ""
            )
        }
        let rows = [
            row("1", "I been on my last for weeks"),
            row("2", "Was tryna get them mills and take 'em back to the hood"),
            row("3", "Then I copped the chain and iced the watch")
        ]
        let hood = SimilarMeaningPipeline.neighborhood(from: rows, anchor: rows[1])
        XCTAssertEqual(hood?.priorLines, ["I been on my last for weeks"])
        XCTAssertEqual(hood?.anchor, rows[1].line)
        XCTAssertFalse(hood?.priorLines.contains(rows[2].line) ?? true)
        XCTAssertTrue(hood?.rubricIds.contains("poverty") ?? false)
    }

    func testBrokeBowlMatchesPovertyWindowAcrossDifferentWrap() {
        let punch = "I was so broke I couldn't get a bowl"
        let catalog = SimilarMeaningPipeline.makeNeighborhood(
            song: "100 Years",
            artist: "NoCap",
            priorLines: ["I been on my last for weeks"],
            anchor: "Was tryna get them mills and take 'em back to the hood",
            anchorId: "nocap.100.2"
        )
        let cards = SimilarMeaningPipeline.score(
            inputPriorLines: ["Rent due and the fridge is empty"],
            inputAnchor: punch,
            candidates: [catalog]
        )
        XCTAssertFalse(cards.isEmpty, "struggle windows should match without sharing wrap")
        XCTAssertTrue(cards[0].neighborhood.reason.contains("struggle") || cards[0].neighborhood.rubricIds.contains("poverty"))
        XCTAssertEqual(cards[0].neighborhood.priorLines.count, 1)
    }

    func testNounBankIncludesCatalogDescriptors() {
        let jewelry = NounBankStore.words(for: .jewelry)
        let brands = NounBankStore.words(for: .brands)
        XCTAssertTrue(jewelry.contains(where: { $0.localizedCaseInsensitiveContains("flooded") }))
        XCTAssertTrue(brands.contains(where: { $0.localizedCaseInsensitiveContains("Damier") }))
        XCTAssertTrue(NounBankStore.words(for: .guns).contains(where: { $0.localizedCaseInsensitiveContains("Glock") }))
        XCTAssertTrue(NounBankStore.words(for: .kill).contains(where: { $0.localizedCaseInsensitiveContains("body") }))
        XCTAssertTrue(NounBankStore.words(for: .woman).contains(where: { $0.localizedCaseInsensitiveContains("bad bitch") }))
        let money = NounBankStore.words(for: .money)
        XCTAssertEqual(money.filter { $0.localizedCaseInsensitiveCompare("racks") == .orderedSame }.count, 1)
        XCTAssertFalse(money.contains(where: {
            $0.localizedCaseInsensitiveCompare("racks") != .orderedSame
                && $0.localizedCaseInsensitiveContains("racks")
        }))
        XCTAssertEqual(money.filter { $0.localizedCaseInsensitiveCompare("bands") == .orderedSame }.count, 1)
        XCTAssertFalse(money.contains(where: {
            $0.localizedCaseInsensitiveCompare("bands") != .orderedSame
                && $0.localizedCaseInsensitiveCompare("rubber bands") != .orderedSame
                && $0.localizedCaseInsensitiveContains("bands")
        }))
        XCTAssertTrue(NounBankStore.words(for: .cars).contains(where: { $0.localizedCaseInsensitiveContains("Benz") }))
        XCTAssertTrue(NounBankCategory.allCases.allSatisfy { !NounBankStore.words(for: $0).isEmpty })
        let total = NounBankCategory.allCases.map { NounBankStore.words(for: $0).count }.reduce(0, +)
        XCTAssertGreaterThan(total, 400)
        let jewelers = NounBankStore.words(for: .jewelers)
        XCTAssertTrue(jewelers.contains(where: { $0.localizedCaseInsensitiveCompare("Johnny Dang") == .orderedSame }))
        XCTAssertTrue(jewelers.contains(where: { $0.localizedCaseInsensitiveCompare("Eliantte") == .orderedSame }))
        XCTAssertFalse(jewelers.contains(where: { $0.localizedCaseInsensitiveCompare("Johnny") == .orderedSame }))
        XCTAssertTrue(jewelers.contains(where: { $0.localizedCaseInsensitiveCompare("Icebox") == .orderedSame }))
        XCTAssertFalse(jewelry.contains(where: { $0.localizedCaseInsensitiveCompare("icebox") == .orderedSame }))
        let kill = NounBankStore.words(for: .kill)
        XCTAssertFalse(kill.contains(where: {
            $0.localizedCaseInsensitiveCompare("opps") == .orderedSame
                || $0.localizedCaseInsensitiveCompare("opp pack") == .orderedSame
        }))
        let producers = NounBankStore.words(for: .producers)
        XCTAssertTrue(producers.contains(where: { $0.localizedCaseInsensitiveCompare("Metro Boomin") == .orderedSame }))
        XCTAssertTrue(producers.contains(where: { $0.localizedCaseInsensitiveCompare("Wheezy") == .orderedSame }))
        let artists = NounBankStore.words(for: .artists)
        XCTAssertTrue(artists.contains(where: { $0.localizedCaseInsensitiveCompare("Drake") == .orderedSame }))
        XCTAssertTrue(artists.contains(where: { $0.localizedCaseInsensitiveCompare("Unfoonk") == .orderedSame }))
        XCTAssertFalse(artists.contains(where: { $0.localizedCaseInsensitiveCompare("baby") == .orderedSame }))
        let opps = NounBankStore.words(for: .opps)
        XCTAssertTrue(opps.contains(where: { $0.localizedCaseInsensitiveCompare("Opp pack") == .orderedSame }))
        XCTAssertTrue(brands.contains(where: { $0.localizedCaseInsensitiveCompare("Heron Preston") == .orderedSame }))
        XCTAssertTrue(brands.contains(where: { $0.localizedCaseInsensitiveCompare("Goyard") == .orderedSame }))
        XCTAssertTrue(brands.contains(where: {
            $0.compare("Louis V", options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                || $0.localizedCaseInsensitiveCompare("LV") == .orderedSame
        }))
    }

    func testNounBankMinesFullVaultNotGunnaSlice() {
        let cars = NounBankStore.words(for: .cars)
        let places = NounBankStore.words(for: .places)
        let brands = NounBankStore.words(for: .brands)
        let jewelry = NounBankStore.words(for: .jewelry)
        let syrups = NounBankStore.words(for: .syrups)
        XCTAssertTrue(cars.contains(where: { $0.localizedCaseInsensitiveContains("Hellcat") }))
        XCTAssertTrue(cars.contains(where: { $0.localizedCaseInsensitiveContains("Rari") }))
        XCTAssertTrue(cars.contains(where: { $0.localizedCaseInsensitiveContains("Trackhawk") }))
        XCTAssertTrue(places.contains(where: { $0.localizedCaseInsensitiveContains("Atlanta") }))
        XCTAssertTrue(places.contains(where: { $0.localizedCaseInsensitiveContains("Miami") }))
        XCTAssertTrue(brands.contains(where: { $0.localizedCaseInsensitiveContains("Damier") }))
        XCTAssertTrue(brands.contains(where: { $0.localizedCaseInsensitiveCompare("Heron Preston") == .orderedSame }))
        XCTAssertTrue(brands.contains(where: { $0.localizedCaseInsensitiveCompare("Goyard") == .orderedSame }))
        XCTAssertTrue(brands.contains(where: { $0.localizedCaseInsensitiveContains("Off-White") }))
        XCTAssertTrue(brands.contains(where: {
            $0.compare("Louis V", options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                || $0.localizedCaseInsensitiveCompare("LV") == .orderedSame
        }))
        XCTAssertTrue(jewelry.contains(where: { $0.localizedCaseInsensitiveContains("100k") || $0.localizedCaseInsensitiveContains("bezel") }))
        XCTAssertFalse(jewelry.contains(where: { $0.localizedCaseInsensitiveCompare("icebox") == .orderedSame }))
        XCTAssertTrue(syrups.contains(where: { $0.localizedCaseInsensitiveContains("daiquiri") }))
        let jewelers = NounBankStore.words(for: .jewelers)
        XCTAssertTrue(jewelers.contains(where: { $0.localizedCaseInsensitiveCompare("Johnny Dang") == .orderedSame }))
        XCTAssertTrue(jewelers.contains(where: { $0.localizedCaseInsensitiveCompare("Eliantte") == .orderedSame }))
        XCTAssertFalse(jewelers.contains(where: { $0.localizedCaseInsensitiveCompare("Johnny") == .orderedSame }))
        let kill = NounBankStore.words(for: .kill)
        XCTAssertFalse(kill.contains(where: {
            $0.localizedCaseInsensitiveCompare("opps") == .orderedSame
                || $0.localizedCaseInsensitiveCompare("opp pack") == .orderedSame
        }))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains(where: {
            $0.localizedCaseInsensitiveCompare("Opp pack") == .orderedSame
        }))
        let producers = NounBankStore.words(for: .producers)
        XCTAssertTrue(producers.contains(where: { $0.localizedCaseInsensitiveCompare("Metro Boomin") == .orderedSame }))
        XCTAssertTrue(producers.contains(where: { $0.localizedCaseInsensitiveCompare("Wheezy") == .orderedSame }))
        let artists = NounBankStore.words(for: .artists)
        XCTAssertTrue(artists.contains(where: { $0.localizedCaseInsensitiveCompare("Drake") == .orderedSame }))
        XCTAssertTrue(artists.contains(where: { $0.localizedCaseInsensitiveCompare("Unfoonk") == .orderedSame }))
        XCTAssertFalse(artists.contains(where: { $0.localizedCaseInsensitiveCompare("baby") == .orderedSame }))
        XCTAssertTrue(NounBankCategory.allCases.allSatisfy { !NounBankStore.words(for: $0).isEmpty })
        let total = NounBankCategory.allCases.map { NounBankStore.words(for: $0).count }.reduce(0, +)
        XCTAssertGreaterThan(total, 400)
        XCTAssertGreaterThan(cars.count, 40)
        XCTAssertGreaterThan(places.count, 40)
        XCTAssertFalse(syrups.contains(where: { $0.localizedCaseInsensitiveCompare("the lean") == .orderedSame }))
        XCTAssertFalse(NounBankStore.words(for: .guns).contains(where: {
            $0.localizedCaseInsensitiveCompare("the Glock") == .orderedSame
                || $0.localizedCaseInsensitiveCompare("a Glock") == .orderedSame
        }))
    }

    func testNounBankLiquorsKeepDistinctWordsDropTheHenny() {
        let liquors = NounBankStore.words(for: .liquors)
        XCTAssertTrue(liquors.contains(where: { $0.localizedCaseInsensitiveCompare("Henny") == .orderedSame }))
        XCTAssertFalse(liquors.contains(where: { $0.localizedCaseInsensitiveCompare("Hennessy") == .orderedSame }))
        XCTAssertFalse(liquors.contains(where: { $0.localizedCaseInsensitiveCompare("the Henny") == .orderedSame }))
        XCTAssertFalse(liquors.contains(where: { $0.localizedCaseInsensitiveCompare("that Henny") == .orderedSame }))
        let cirocHead = liquors.filter {
            $0.localizedCaseInsensitiveCompare("Ciroc") == .orderedSame
                || $0.localizedCaseInsensitiveCompare("Cîroc") == .orderedSame
        }
        XCTAssertEqual(cirocHead.count, 1)
    }

    func testCatalogStyleTagsFromLyricsDoNotInventBPM() {
        let tags = CatalogMIRBatchService.styleTags(
            lyrics: "this trap 808 skrrt, no drums, just the melody",
            bpm: nil,
            hadAudio: false
        )
        XCTAssertTrue(tags.contains("trap"))
        XCTAssertTrue(tags.contains("no-drums") || tags.contains("melody-rap") || tags.contains("beat-driven"))
        let withAudio = CatalogMIRBatchService.styleTags(lyrics: nil, bpm: 72, hadAudio: true)
        XCTAssertTrue(withAudio.contains("ballad"))
        XCTAssertFalse(withAudio.contains("trap"))
    }

    @MainActor
    func testVaultMIRPersistsUnderArtistPipeTitleKey() throws {
        XCTAssertEqual(CatalogMIRBatchService.userDefaultsStorageKey, "catalog_mir_batch_v1")
        XCTAssertEqual(
            CatalogMIRBatchService.songRecordKey(artist: "Gunna", title: "fukumean"),
            "Gunna|fukumean"
        )
        let song = BarHitsCatalogStore.CatalogSong(artist: "Gunna", title: "fukumean", barCount: 12)
        XCTAssertEqual(song.id, "Gunna|fukumean")
        let record = CatalogMIRBatchService.SongMIR(
            bpm: nil,
            key: nil,
            scale: nil,
            styleTags: ["trap", "beat-driven"],
            styleTagConfidence: 0.32,
            analyzedAt: Date(timeIntervalSince1970: 1_700_000_000),
            hadAudio: false
        )
        let key = CatalogMIRBatchService.songRecordKey(artist: "Gunna", title: "fukumean")
        let data = try XCTUnwrap(CatalogMIRBatchService.encodeRecords([key: record]))
        let decoded = try XCTUnwrap(CatalogMIRBatchService.decodeRecords(data))
        XCTAssertEqual(decoded[key]?.bpm, nil)
        XCTAssertEqual(decoded[key]?.hadAudio, false)
        XCTAssertEqual(decoded[key]?.styleTags, ["trap", "beat-driven"])
        XCTAssertGreaterThanOrEqual(CatalogMIRBatchService.fullVaultSongLimit, 40_940)
    }

    func testWrapHitsDoesNotRankByNoteOrCatalogBPM() {
        let query = "The city hums in flesh and bone"
        let n = LineSyllableCounter.syllableCount(forLine: query)
        let candidate = RemindsMeOfCandidate(
            id: "bone-1",
            line: "I left the flesh and bone",
            artist: "Drake",
            song: "A",
            syllableCount: 7,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let hits = RemindsMeOfScorer.wrapHits(
            from: [candidate],
            queryLine: query,
            syllables: n,
            nearWords: ["bone"]
        )
        XCTAssertEqual(hits.map(\.line), [candidate.line])
        // wrapHits has no BPM/key/scale argument. Note BPM cannot change this ranking.
        XCTAssertEqual(hits[0].score, RemindsMeOfScorer.wrapHits(
            from: [candidate],
            queryLine: query,
            syllables: n,
            nearWords: ["bone"]
        )[0].score, accuracy: 0.0001)
    }

    func testCloserSyllableCountScoresHigher() {
        let query = ["The city hums in flesh and bone"]
        let querySyl = [LineSyllableCounter.syllableCount(forLine: query[0])]
        let close = RemindsMeOfScorer.score(
            candidate: "The night still moves in flesh and chrome",
            against: query,
            querySyllables: querySyl,
            wrapTarget: querySyl[0]
        )
        let far = RemindsMeOfScorer.score(
            candidate: "I",
            against: query,
            querySyllables: querySyl,
            wrapTarget: querySyl[0]
        )
        XCTAssertGreaterThan(close, far)
        XCTAssertGreaterThan(close, 0.3)
    }

    func testWrapWindowBoostsBarsWithinTwoSyllables() {
        let query = ["Each step I take, the rhythm counts"]
        let n = LineSyllableCounter.syllableCount(forLine: query[0])
        let inPocket = RemindsMeOfScorer.wrapScore(candidateSyllables: n, target: n)
        let outside = RemindsMeOfScorer.wrapScore(candidateSyllables: n + 6, target: n)
        XCTAssertEqual(inPocket, 1, accuracy: 0.01)
        XCTAssertLessThan(outside, 0.5)
    }

    func testGroupsBySyllablePocketAndAssignsPaletteColor() {
        let hits = [
            RemindsMeOfHit.stub(line: "eight count bar in the pocket now", syllables: 8, source: .csv),
            RemindsMeOfHit.stub(line: "another eight on the same clock", syllables: 8, source: .csv),
            RemindsMeOfHit.stub(line: "a much longer line that sits in a different wrap altogether", syllables: 14, source: .csv),
            RemindsMeOfHit.stub(line: "pushin P", syllables: 3, source: .genius, song: "pushin P", artist: "Gunna")
        ]
        let groups = RemindsMeOfScorer.group(hits)
        XCTAssertGreaterThanOrEqual(groups.count, 2)
        XCTAssertTrue(groups.contains { $0.hits.count == 2 && $0.hits.allSatisfy { $0.syllableCount == 8 } })
        XCTAssertTrue(groups.allSatisfy { (0..<RhymeColorPalette.colors.count).contains($0.colorIndex) })
    }

    @MainActor
    func testGrowingVaultRoundTrip() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("reminds-\(UUID().uuidString).csv")
        defer { try? FileManager.default.removeItem(at: url) }
        let row = RemindsMeOfCandidate(
            id: "g-1",
            line: "Wunna Wunna, they workin' my nerves",
            artist: "Gunna",
            song: "fukumean",
            syllableCount: 8,
            source: .genius,
            geniusID: 123,
            url: URL(string: "https://genius.com/Gunna-fukumean-lyrics")
        )
        RemindsMeOfVault.append([row], to: url)
        RemindsMeOfVault.append([row], to: url) // duplicate id ignored
        let loaded = RemindsMeOfVault.loadGrowing(from: url)
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].line, row.line)
        XCTAssertEqual(loaded[0].geniusID, 123)
        XCTAssertEqual(loaded[0].source, .genius)
    }

    func testGeniusSearchParsesHits() throws {
        let json = """
        {"response":{"hits":[{"type":"song","result":{"id":99,"title":"WUNNA","url":"https://genius.com/Gunna-wunna-lyrics","primary_artist":{"name":"Gunna"}}}]}}
        """.data(using: .utf8)!
        let hits = try GeniusReferenceClient.parseSearch(data: json)
        XCTAssertEqual(hits.count, 1)
        XCTAssertEqual(hits[0].title, "WUNNA")
        XCTAssertEqual(hits[0].artist, "Gunna")
        XCTAssertEqual(hits[0].id, 99)
    }

    func testGeniusAPIClientsURLIsTheOfficialKeyPage() {
        XCTAssertEqual(GeniusReferenceClient.developersURL.host, "genius.com")
        XCTAssertTrue(GeniusReferenceClient.developersURL.path.contains("developers"))
        XCTAssertEqual(GeniusReferenceClient.newAPIClientURL.host, "genius.com")
        XCTAssertTrue(GeniusReferenceClient.newAPIClientURL.path.contains("api-clients/new"))
        XCTAssertEqual(GeniusReferenceClient.apiClientsURL, GeniusReferenceClient.newAPIClientURL)
    }

    func testGeniusSearchUsesPublicWebWhenNoUserKey() {
        XCTAssertEqual(GeniusReferenceClient.searchEndpoint(apiKey: nil).host, "genius.com")
        XCTAssertEqual(GeniusReferenceClient.searchEndpoint(apiKey: "").host, "genius.com")
        XCTAssertEqual(GeniusReferenceClient.searchEndpoint(apiKey: "token").host, "api.genius.com")
    }

    func testQueryUsesLastNonEmptyLines() {
        let text = "I walk the block\nEach step I take\n\n"
        let lines = RemindsMeOfScorer.queryLines(from: text)
        XCTAssertEqual(lines.last, "Each step I take")
        XCTAssertEqual(lines.count, 2)
    }

    func testLineSpansArePerLineWithRanges() {
        let text = "I walk the block\n\nEach step I take, the rhythm counts"
        let spans = RemindsMeOfScorer.lineSpans(in: text)
        XCTAssertEqual(spans.map(\.text), [
            "I walk the block",
            "Each step I take, the rhythm counts"
        ])
        XCTAssertEqual(spans[0].index, 0)
        XCTAssertEqual(spans[1].index, 2)
        let first = String((text as NSString).substring(with: NSRange(location: spans[0].location, length: spans[0].length)))
        let second = String((text as NSString).substring(with: NSRange(location: spans[1].location, length: spans[1].length)))
        XCTAssertEqual(first, "I walk the block")
        XCTAssertEqual(second, "Each step I take, the rhythm counts")
    }

    func testShortAdlibLinesAreNotSearched() {
        let text = "Yeah\nWunna Wunna, they workin' my nerves"
        let spans = RemindsMeOfScorer.lineSpans(in: text)
        XCTAssertEqual(spans.map(\.text), ["Wunna Wunna, they workin' my nerves"])
    }

    func testGeniusSearchQueryIsTheLineItself() {
        let line = "The city hums in flesh and bone"
        XCTAssertEqual(GeniusReferenceClient.searchQuery(forLine: line), line)
    }

    func testHeldLineQueriesAreLineEndWordAndWrap() {
        let line = "The city hums in flesh and bone"
        XCTAssertEqual(GeniusReferenceClient.searchQuery(forLine: line), line)
        XCTAssertEqual(GhostSuggestionEngine.endWord(of: line), "bone")
        XCTAssertEqual(LineSyllableCounter.syllableCount(forLine: line), 8)
    }

    func testWrapBucketKeepsSameSyllableCount() {
        let line = "The city hums in flesh and bone"
        let n = LineSyllableCounter.syllableCount(forLine: line)
        let keep = "I walk the block where echoes bounce"
        XCTAssertEqual(LineSyllableCounter.syllableCount(forLine: keep), n)
        XCTAssertNotEqual(LineSyllableCounter.syllableCount(forLine: "I"), n)
    }

    func testLinePopsOnGeniusWhenHitsExist() {
        XCTAssertTrue(RemindsMeOfScorer.linePopsOnGenius(hitCount: 1))
        XCTAssertTrue(RemindsMeOfScorer.linePopsOnGenius(hitCount: 4))
        XCTAssertFalse(RemindsMeOfScorer.linePopsOnGenius(hitCount: 0))
    }

    func testMatchContainingUTF16FindsTheLine() {
        let match = RemindsMeOfLineMatch(
            index: 0,
            line: "I walk the block",
            location: 0,
            length: 16,
            hits: [GeniusSongHit(id: 1, title: "Walk It", artist: "Gunna", url: nil)]
        )
        XCTAssertEqual(RemindsMeOfScorer.match(containingUTF16: 3, in: [match])?.index, 0)
        XCTAssertNil(RemindsMeOfScorer.match(containingUTF16: 99, in: [match]))
    }

    func testArtistCreditIsNotALyricBar() {
        XCTAssertTrue(RemindsMeOfScorer.looksLikeArtistCredit("Young Stoner Life, Young Thug & Gunna"))
        XCTAssertFalse(RemindsMeOfScorer.isLyricBar("Young Stoner Life, Young Thug & Gunna"))
        XCTAssertFalse(RemindsMeOfScorer.isLyricBar("| Paid the Fine"))
        XCTAssertFalse(RemindsMeOfScorer.isLyricBar("| aria-label: Cover art for Paid the Fine by Young Stoner Life, Young Thug & Gunna |"))
        XCTAssertTrue(RemindsMeOfScorer.isLyricBar("Trying to rhyme my way through the night"))
    }

    func testGroundTruthParserReadsLyricNotArtist() throws {
        let csv = """
        REAL LYRICS 2026 NEW JAN 24,artist,song,album,section_type,repeat_count,text_bar_line,rhyme_word,year
        youngstonerlifeyoungthuggunna.paidthefine.8,"Young Stoner Life, Young Thug & Gunna",Paid the Fine,Slime Language 2 (Deluxe),unknown,1,And that's just what the people know,know,2021
        """
        let bars = try EditorialGroundTruth.parseCSVFile(data: Data(csv.utf8))
        XCTAssertEqual(bars.count, 1)
        XCTAssertEqual(bars[0].text, "And that's just what the people know")
        XCTAssertEqual(bars[0].artist, "Young Stoner Life, Young Thug & Gunna")
        XCTAssertEqual(bars[0].song, "Paid the Fine")
        XCTAssertNotEqual(bars[0].text, bars[0].artist)
    }

    func testHeldWrapRejectsCreditAndKeepsRelatedBar() {
        let query = "Trying to rhyme my way through the night"
        let syllables = LineSyllableCounter.syllableCount(forLine: query)
        XCTAssertEqual(syllables, 8)

        let credit = RemindsMeOfCandidate(
            id: "credit",
            line: "Young Stoner Life, Young Thug & Gunna",
            artist: "Young Stoner Life, Young Thug & Gunna",
            song: "Paid the Fine",
            syllableCount: syllables,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let unrelated = RemindsMeOfCandidate(
            id: "unrelated",
            line: "And that's just what the people know",
            artist: "Gunna",
            song: "Paid the Fine",
            syllableCount: syllables,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let related = RemindsMeOfCandidate(
            id: "related",
            line: "Trying rhyme my way through this night",
            artist: "Gunna",
            song: "Night Cycle",
            syllableCount: syllables,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let relatedDup = RemindsMeOfCandidate(
            id: "related-dup",
            line: "Trying rhyme my way through this night",
            artist: "Gunna",
            song: "Night Cycle (Deluxe)",
            syllableCount: syllables,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let geniusTitle = RemindsMeOfCandidate(
            id: "genius",
            line: "Paid the Fine",
            artist: "Young Stoner Life, Young Thug & Gunna",
            song: "Paid the Fine",
            syllableCount: syllables,
            source: .genius,
            geniusID: 1,
            url: nil
        )

        let hits = RemindsMeOfScorer.wrapHits(
            from: [credit, unrelated, related, relatedDup, geniusTitle],
            queryLine: query,
            syllables: syllables
        )
        XCTAssertEqual(hits.map(\.line), ["Trying rhyme my way through this night"])
        XCTAssertFalse(hits.contains { $0.line.localizedCaseInsensitiveContains("Young Stoner Life") })
        XCTAssertFalse(hits.contains { $0.line == "And that's just what the people know" })
        XCTAssertGreaterThan(hits[0].score, 0.65)
    }

    func testWrapHitsKeepsGeniusLyricBarNotSongTitle() {
        let query = "Trying to rhyme my way through the night"
        let syllables = LineSyllableCounter.syllableCount(forLine: query)
        let lyric = RemindsMeOfCandidate(
            id: "genius-lyric",
            line: "Trying rhyme my way through this night",
            artist: "Gunna",
            song: "Night Cycle",
            syllableCount: syllables,
            source: .genius,
            geniusID: 9,
            url: nil
        )
        let title = RemindsMeOfCandidate(
            id: "genius-title",
            line: "Night Cycle",
            artist: "Gunna",
            song: "Night Cycle",
            syllableCount: syllables,
            source: .genius,
            geniusID: 9,
            url: nil
        )
        let hits = RemindsMeOfScorer.wrapHits(
            from: [lyric, title],
            queryLine: query,
            syllables: syllables
        )
        XCTAssertEqual(hits.map(\.line), ["Trying rhyme my way through this night"])
        XCTAssertFalse(hits.contains { $0.line == "Night Cycle" })
    }

    func testThemeHitsMatchMeaningWithoutSameSyllableCount() {
        let query = "Trying to rhyme my way through the night"
        let related = RemindsMeOfCandidate(
            id: "theme-related",
            line: "I rhyme my way through every night we take",
            artist: "Gunna",
            song: "Night Cycle",
            syllableCount: 12,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let unrelated = RemindsMeOfCandidate(
            id: "theme-unrelated",
            line: "And that's just what the people know",
            artist: "Gunna",
            song: "Paid the Fine",
            syllableCount: 8,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let hits = RemindsMeOfScorer.themeHits(
            from: [related, unrelated],
            queryLine: query,
            excluding: []
        )
        XCTAssertEqual(hits.map(\.line), [related.line])
        XCTAssertNotEqual(hits[0].syllableCount, LineSyllableCounter.syllableCount(forLine: query))
    }

    func testHeldLineGroupsLeadWithWrapThenMeaningThenRecords() {
        let result = RemindsMeOfHeldLineResult(
            line: "Trying to rhyme my way through the night",
            syllables: 8,
            wrap: [.stub(line: "Trying rhyme my way through this night", syllables: 8, source: .csv)],
            meaning: [.stub(line: "I rhyme my way through every night we take", syllables: 12, source: .csv)],
            tracks: [.stub(line: "Night Cycle", syllables: 0, source: .genius, song: "Night Cycle", artist: "Gunna")]
        )
        XCTAssertEqual(result.groups().map(\.id), [
            "held-wrap-8",
            "held-meaning",
            "held-tracks"
        ])
        XCTAssertEqual(result.groups().first?.title, "Same wrap (8 syllables)")
        XCTAssertEqual(result.groups()[1].title, "Similar meaning")
        XCTAssertEqual(result.groups().last?.title, "Genius")
    }

    func testHeldWrapSplitsExactCountThenNeighbors() {
        let result = RemindsMeOfHeldLineResult(
            line: "All the money, I really earned it",
            syllables: 10,
            wrap: [
                .stub(line: "nine count neighbor bar here now", syllables: 9, source: .csv),
                .stub(line: "this money forever, inherit it", syllables: 10, source: .csv),
                .stub(line: "eleven syllable nearby wrap bar yes", syllables: 11, source: .csv),
                .stub(line: "twelve count nearby wrap bar line here", syllables: 12, source: .csv)
            ],
            meaning: [.stub(line: "got racks all inside the safe tonight", syllables: 8, source: .csv)],
            tracks: []
        )
        XCTAssertEqual(result.groups().map(\.id), [
            "held-wrap-10",
            "held-wrap-9",
            "held-wrap-11",
            "held-wrap-12",
            "held-meaning"
        ])
        XCTAssertEqual(result.groups().map(\.title), [
            "Same wrap (10 syllables)",
            "Nearby wrap (9 syllables)",
            "Nearby wrap (11 syllables)",
            "Nearby wrap (12 syllables)",
            "Similar meaning"
        ])
    }

    func testWrapHitsFirstPageIsTen() {
        let query = "The city hums in flesh and bone"
        let n = LineSyllableCounter.syllableCount(forLine: query)
        let pool = (0..<25).map { i in
            RemindsMeOfCandidate(
                id: "bone-\(i)",
                line: "I left the flesh \(i) bone",
                artist: "Drake",
                song: "A",
                syllableCount: 8,
                source: .csv,
                geniusID: nil,
                url: nil
            )
        }
        let first = RemindsMeOfScorer.wrapHits(from: pool, queryLine: query, syllables: n, limit: 10)
        XCTAssertLessThanOrEqual(first.count, 10)
        let grown = RemindsMeOfScorer.wrapHits(from: pool, queryLine: query, syllables: n, limit: 20)
        XCTAssertGreaterThanOrEqual(grown.count, first.count)
        XCTAssertLessThanOrEqual(grown.count, 20)
    }

    func testWrapWindowForEightIsSevenThroughTen() {
        XCTAssertEqual(RemindsMeOfScorer.wrapSyllableWindow(around: 8), 7...10)
        XCTAssertEqual(RemindsMeOfScorer.wrapSyllableWindow(around: 1), 1...3)
    }

    func testWrapHitsKeepsNearbyCountWhenEndRhymes() {
        let query = "The city hums in flesh and bone"
        let n = LineSyllableCounter.syllableCount(forLine: query)
        XCTAssertEqual(n, 8)
        let seven = RemindsMeOfCandidate(
            id: "seven",
            line: "I left the flesh and bone",
            artist: "Drake",
            song: "Test",
            syllableCount: 7,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let ten = RemindsMeOfCandidate(
            id: "ten",
            line: "Walking through the city in flesh and bone",
            artist: "Lil Wayne",
            song: "Test",
            syllableCount: 10,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let six = RemindsMeOfCandidate(
            id: "six",
            line: "Flesh and bone tonight",
            artist: "Future",
            song: "Test",
            syllableCount: 6,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let unrelated = RemindsMeOfCandidate(
            id: "no-rhyme",
            line: "The city hums in flesh and paper",
            artist: "Gunna",
            song: "Test",
            syllableCount: 8,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let hits = RemindsMeOfScorer.wrapHits(
            from: [seven, ten, six, unrelated],
            queryLine: query,
            syllables: n,
            nearWords: ["bone"]
        )
        XCTAssertEqual(Set(hits.map(\.syllableCount)).isSubset(of: Set([7, 8, 9, 10])), true)
        XCTAssertFalse(hits.contains { $0.syllableCount == 6 })
        XCTAssertTrue(hits.contains { $0.line == seven.line })
        XCTAssertTrue(hits.contains { $0.line == ten.line })
        XCTAssertFalse(hits.contains { $0.line == unrelated.line })
    }

    func testWrapHitsFallbackKeepsSameEndWhenJunkFiltersEmptyTheList() {
        let query = "The city hums in flesh and bone"
        let n = LineSyllableCounter.syllableCount(forLine: query)
        let junk = RemindsMeOfCandidate(
            id: "junk",
            line: "boo-hoo sheesh play my song bone",
            artist: "Gunna",
            song: "Adlib",
            syllableCount: n,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        XCTAssertTrue(RemindsMeOfScorer.isJunkAdlibLine(junk.line))
        let hits = RemindsMeOfScorer.wrapHits(
            from: [junk],
            queryLine: query,
            syllables: n
        )
        XCTAssertEqual(hits.map(\.line), [junk.line], "same-end wrap must still surface after junk filters empty the first pass")
    }

    func testForbiddenWebSearchDoesNotShowRaw403() {
        let issue = RemindsMeOfCopy.searchIssue(
            for: RapAPIError.serverError(statusCode: 403, message: nil)
        )
        XCTAssertEqual(issue.kind, .token)
        XCTAssertTrue(issue.showsTokenField)
        XCTAssertFalse(issue.headline.contains("403"))
        XCTAssertFalse(issue.detail.contains("403"))
        XCTAssertTrue(issue.headline.lowercased().contains("token"))
        XCTAssertTrue(issue.detail.lowercased().contains("vault"))
        XCTAssertEqual(
            RemindsMeOfCopy.searchFailureMessage(
                for: RapAPIError.serverError(statusCode: 403, message: nil)
            ),
            issue.headline
        )
    }

    func testRateLimitIssueDoesNotAskForAToken() {
        let issue = RemindsMeOfCopy.searchIssue(for: RapAPIError.rateLimitExceeded(retryAfterSeconds: 30))
        XCTAssertEqual(issue.kind, .rateLimit)
        XCTAssertFalse(issue.showsTokenField)
        XCTAssertTrue(issue.detail.lowercased().contains("wait"))
    }

    func testTitleLeakRejectsSongNameAsABar() {
        XCTAssertTrue(RemindsMeOfScorer.isTitleLeak("Bounce Back", song: "Bounce Back"))
        XCTAssertTrue(RemindsMeOfScorer.isTitleLeak("bounce back", song: "Bounce Back"))
        XCTAssertFalse(RemindsMeOfScorer.isTitleLeak("I bounce back from the dirt", song: "Bounce Back"))
    }

    func testTrackSearchUsesDistinctiveWordsNotTheWholeSentence() {
        let tokens = RemindsMeOfScorer.trackSearchTokens(
            forLine: "I walk the block where echoes bounce"
        )
        XCTAssertEqual(tokens, ["block", "echoes", "bounce"])
        XCTAssertFalse(tokens.contains("walk") && tokens.contains("where"))
        XCTAssertEqual(
            GeniusReferenceClient.trackSearchQuery(forLine: "I walk the block where echoes bounce"),
            "block echoes bounce"
        )
    }

    func testLandingKeepsSameEndWordAndRejectsTitle() {
        let query = "I walk the block where echoes bounce"
        let sameWord = RemindsMeOfCandidate(
            id: "same",
            line: "Let the whole club hear that bass bounce",
            artist: "Gunna",
            song: "Who You Foolin",
            syllableCount: 9,
            source: .csv,
            geniusID: nil,
            url: nil
        )
        let title = RemindsMeOfCandidate(
            id: "title",
            line: "Bounce Back",
            artist: "Big Sean",
            song: "Bounce Back",
            syllableCount: 2,
            source: .genius,
            geniusID: 1,
            url: nil
        )
        let hits = RemindsMeOfScorer.landingHits(
            from: [sameWord, title],
            queryLine: query,
            excluding: []
        )
        XCTAssertEqual(hits.map(\.line), [sameWord.line])
        XCTAssertFalse(hits.contains { $0.line == "Bounce Back" })
    }

    func testPickSnippetLinePrefersTheRapBar() {
        let snippet = """
        ha
        Ha, ha, ha, ha
        (Chorus)
        Fuck you mean?
        Young Gunna Wunna, they workin' my nerves
        I'm about to pour
        """
        let query = "Wunna Wunna, they workin' my nerves"
        let picked = RemindsMeOfScorer.pickSnippetLine(
            snippet,
            queryLine: query,
            syllables: LineSyllableCounter.syllableCount(forLine: query)
        )
        XCTAssertEqual(picked, "Young Gunna Wunna, they workin' my nerves")
    }

    func testGeniusLyricSearchParsesSnippetNotTitle() throws {
        let json = """
        {"response":{"sections":[{"type":"lyric","hits":[{"highlights":[{"property":"lyrics","value":"ha\\nYoung Gunna Wunna, they workin' my nerves\\nI'm about to pour"}],"result":{"id":42,"title":"fukumean","url":"https://genius.com/Gunna-fukumean-lyrics","primary_artist":{"name":"Gunna"}}}]}]}}
        """.data(using: .utf8)!
        let hits = try GeniusReferenceClient.parseLyricSearch(data: json)
        XCTAssertEqual(hits.count, 1)
        XCTAssertEqual(hits[0].title, "fukumean")
        XCTAssertEqual(hits[0].artist, "Gunna")
        XCTAssertTrue(hits[0].snippet.contains("Young Gunna Wunna, they workin' my nerves"))
        let line = RemindsMeOfScorer.pickSnippetLine(
            hits[0].snippet,
            queryLine: "Wunna Wunna, they workin' my nerves",
            syllables: 8
        )
        XCTAssertEqual(line, "Young Gunna Wunna, they workin' my nerves")
    }

    func testLyricSearchEndpointIsPublicGeniusLyricSearch() {
        XCTAssertEqual(GeniusReferenceClient.lyricSearchEndpoint().host, "genius.com")
        XCTAssertTrue(GeniusReferenceClient.lyricSearchEndpoint().path.contains("search/lyric"))
    }

    func testGeniusSongHitDisplayLinePrefersLyricBar() {
        let titled = GeniusSongHit(id: 1, title: "fukumean", artist: "Gunna", url: nil)
        XCTAssertEqual(titled.displayLine, "fukumean")
        let lyric = GeniusSongHit(
            id: 1,
            title: "fukumean",
            artist: "Gunna",
            url: nil,
            lyricLine: "Young Gunna Wunna, they workin' my nerves"
        )
        XCTAssertEqual(lyric.displayLine, "Young Gunna Wunna, they workin' my nerves")
    }

    func testSpreadArtistsRoundRobinsSoGunnaDoesNotFillTheFirstTen() {
        let hits = (0..<8).map { i in
            RemindsMeOfHit.stub(line: "gunna bar number \(i) in the pocket", syllables: 8, source: .csv, artist: "Gunna")
        } + [
            RemindsMeOfHit.stub(line: "wayne bar riding through the smoke now", syllables: 8, source: .csv, artist: "Lil Wayne"),
            RemindsMeOfHit.stub(line: "uzi bar spinning in the night air", syllables: 8, source: .csv, artist: "Lil Uzi Vert"),
            RemindsMeOfHit.stub(line: "drake bar humming in the city lights", syllables: 8, source: .csv, artist: "Drake")
        ]
        let spread = RemindsMeOfScorer.spreadArtists(hits, limit: 4)
        XCTAssertEqual(spread.map(\.artist), ["Gunna", "Lil Wayne", "Lil Uzi Vert", "Drake"])
    }

    func testSourceLabelSaysCatalogNotRecords() {
        XCTAssertEqual(RemindsMeOfSource.csv.label, "Catalog")
        XCTAssertEqual(RemindsMeOfSource.genius.label, "Genius")
    }
}

private extension RemindsMeOfHit {
    static func stub(line: String, syllables: Int, source: RemindsMeOfSource, song: String? = nil, artist: String? = nil) -> RemindsMeOfHit {
        RemindsMeOfHit(
            id: line,
            line: line,
            artist: artist,
            song: song,
            source: source,
            url: nil,
            syllableCount: syllables,
            score: 0.7
        )
    }
}
