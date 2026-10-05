import XCTest
@testable import XJournal_AI

final class ArtistOnboardingContractTests: XCTestCase {

    func testSpotifyArtistURLParsesID() {
        XCTAssertEqual(
            ArtistCatalogClient.parseSpotifyArtistID(from: "https://open.spotify.com/artist/3TVXtAsR1Inumwj472S9r4"),
            "3TVXtAsR1Inumwj472S9r4"
        )
        XCTAssertEqual(
            ArtistCatalogClient.parseSpotifyArtistID(from: "spotify:artist:3TVXtAsR1Inumwj472S9r4"),
            "3TVXtAsR1Inumwj472S9r4"
        )
        XCTAssertNil(ArtistCatalogClient.parseSpotifyArtistID(from: "https://music.apple.com/us/artist/drake/2715720"))
    }

    func testAppleMusicArtistURLParsesID() {
        XCTAssertEqual(
            ArtistCatalogClient.parseAppleMusicArtistID(from: "https://music.apple.com/us/artist/drake/2715720"),
            "2715720"
        )
        XCTAssertNil(ArtistCatalogClient.parseAppleMusicArtistID(from: "https://open.spotify.com/artist/abc"))
    }

    func testNeverUseSplitsLeaveOut() {
        XCTAssertEqual(
            ArtistOnboardingContract.neverUseTerms(from: "mama, the old city; kids"),
            ["mama", "the old city", "kids"]
        )
        XCTAssertEqual(ArtistOnboardingContract.neverUseTerms(from: "  "), [])
    }

    func testTitlesOnlyBrainDoesNotMintPersonaClaims() {
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.songs = [
            ArtistSong(id: "1", title: "Bounce Back", primaryArtist: "Test Artist", isFeature: false, included: true, source: "spotify"),
            ArtistSong(id: "2", title: "Feature Hop (feat. Other)", primaryArtist: "Other", isFeature: true, included: false, source: "spotify")
        ]
        let cards = ArtistBrainStore.inferPendingCards(from: brain)
        XCTAssertFalse(cards.contains { ArtistOnboardingContract.isTitlePersonaClaim($0) })
        XCTAssertFalse(cards.contains { $0.title == "Catalog pocket" })
        XCTAssertFalse(cards.contains { $0.title == "Home stance" })
        XCTAssertFalse(cards.contains { $0.title == "Punch stays punch" })
        XCTAssertEqual(Set(cards.map(\.title)).isSubset(of: ArtistOnboardingContract.allowedPendingTitles), true)
        XCTAssertTrue(cards.contains { $0.title == "Name" })
        XCTAssertTrue(cards.contains { $0.title == "Who you're talking to" })
    }

    func testRebuildChunksDoesNotTreatTitlesAsBars() {
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.talkingTo = .theCity
        brain.songs = [
            ArtistSong(id: "1", title: "Bounce Back", primaryArtist: "Test Artist", isFeature: false, included: true, source: "spotify")
        ]
        brain.confirmedCards = [
            ArtistBrainCard(title: "Name", body: "Write as Test Artist.", source: "answer", status: .kept)
        ]
        let chunks = ArtistBrainStore.rebuildChunks(from: brain)
        XCTAssertFalse(chunks.contains { $0.kind == .lyricBar })
        XCTAssertFalse(chunks.contains { $0.kind == .caption && $0.text == "Bounce Back" })
        XCTAssertTrue(chunks.contains { $0.kind == .confirmedCard })
        XCTAssertTrue(chunks.contains { $0.kind == .answer && $0.text.contains("city") })
    }

    func testFeatureToggleDoesNotAutoKeepCards() {
        var brain = ArtistBrain()
        brain.songs = [
            ArtistSong(id: "1", title: "Solo", primaryArtist: "A", isFeature: false, included: true, source: "spotify")
        ]
        let before = ArtistBrainStore.inferPendingCards(from: brain)
        XCTAssertTrue(before.allSatisfy { $0.status == .pending })
        brain.songs[0].included = false
        let after = ArtistBrainStore.inferPendingCards(from: brain)
        XCTAssertTrue(after.allSatisfy { $0.status == .pending })
        XCTAssertTrue(brain.confirmedCards.isEmpty)
    }

    func testArtistBrainNeverUseMirrorsLeaveOut() {
        var brain = ArtistBrain()
        brain.leaveOut = "mama\nkids"
        XCTAssertEqual(brain.neverUse, ["mama", "kids"])
    }

    func testItunesDropsOtherArtistsFromCatalogSearch() throws {
        let json = """
        {"results":[
          {"wrapperType":"track","trackName":"BRIT POP SUMMER'S PINK SAUCE","artistName":"Summertime Sam","trackId":1},
          {"wrapperType":"track","trackName":"Summertime","artistName":"Sam Cooke","trackId":2}
        ]}
        """.data(using: .utf8)!
        let songs = ArtistCatalogClient.parseItunesSongs(
            data: json,
            artistName: "Summertime Sam",
            source: "apple"
        )
        XCTAssertEqual(songs.map(\.title), ["BRIT POP SUMMER'S PINK SAUCE"])
        XCTAssertFalse(songs.contains { $0.primaryArtist == "Sam Cooke" })
    }

    func testIngestProgressAsksUserToReturn() {
        var progress = ArtistIngestProgress(
            isRunning: true,
            currentIndex: 3,
            total: 12,
            currentTitle: "24"
        )
        XCTAssertTrue(progress.returnWhenReadyCopy.lowercased().contains("leave"))
        XCTAssertTrue(progress.returnWhenReadyCopy.contains("3 of 12"))
        XCTAssertEqual(progress.fraction, 0.25, accuracy: 0.001)
        progress.isRunning = false
        progress.finishedAt = Date()
        progress.currentIndex = 12
        XCTAssertTrue(progress.returnWhenReadyCopy.lowercased().contains("paste"))
    }
}
