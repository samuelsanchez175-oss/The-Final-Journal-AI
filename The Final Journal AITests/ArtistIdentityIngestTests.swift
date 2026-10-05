import XCTest
@testable import XJournal_AI

@MainActor
final class ArtistIdentityIngestTests: XCTestCase {
    private var previousBrain: Data?

    override func setUp() {
        super.setUp()
        previousBrain = UserDefaults.standard.data(forKey: ArtistBrainStore.brainKey)
        UserDefaults.standard.removeObject(forKey: ArtistBrainStore.brainKey)
        ArtistBrainStore.shared.reload()
    }

    override func tearDown() {
        if let previousBrain {
            UserDefaults.standard.set(previousBrain, forKey: ArtistBrainStore.brainKey)
        } else {
            UserDefaults.standard.removeObject(forKey: ArtistBrainStore.brainKey)
        }
        ArtistBrainStore.shared.reload()
        super.tearDown()
    }

    private func song() -> ArtistSong {
        ArtistSong(
            id: "1",
            title: "Night Walk",
            primaryArtist: "Test Artist",
            isFeature: false,
            included: true,
            source: "spotify"
        )
    }

    private func brainWithBars(_ lines: [String]) -> ArtistBrain {
        let track = song()
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.songs = [track]
        brain.ingestedBars = lines.map {
            ArtistLyricIngest.makeBar(text: $0, song: track, sourceURL: nil, ingestSource: "paste")
        }
        brain.identitySketch = ArtistIdentityIngest.sketch(from: brain)
        return brain
    }

    func testLyricsFillCityBottleLoveAndAudience() {
        let brain = brainWithBars([
            "I met that girl last night",
            "Shawty keep calling my phone",
            "I pour a cup of henny",
            "The city hums in flesh and bone"
        ])
        XCTAssertTrue(brain.identitySketch.loveTokens.contains("girl") || brain.identitySketch.loveTokens.contains("shawty"))
        XCTAssertTrue(brain.identitySketch.viceTokens.contains("henny"))
        XCTAssertTrue(brain.identitySketch.cityTokens.contains("city"))
        XCTAssertEqual(brain.identitySketch.talkingTo, .aGirl)
        let cards = ArtistIdentityIngest.pendingCards(from: brain)
        XCTAssertTrue(cards.contains { $0.title == ArtistIdentityIngest.loveTitle })
        XCTAssertTrue(cards.contains { $0.title == ArtistIdentityIngest.bottleTitle })
        XCTAssertTrue(cards.contains { $0.title == ArtistIdentityIngest.cityTitle })
        XCTAssertTrue(cards.contains { $0.title == "Who you're talking to" })
        XCTAssertTrue(cards.allSatisfy { $0.status == .pending })
        XCTAssertFalse(cards.contains { $0.title == "Catalog pocket" })
    }

    func testGriefTokensDoNotMintALossCard() {
        let brain = brainWithBars([
            "The city hums in flesh and bone",
            "I still see rip in the night",
            "rip on the wall again"
        ])
        XCTAssertFalse(brain.identitySketch.topicTokens.contains("rip"))
        let cards = ArtistIdentityIngest.pendingCards(from: brain)
        XCTAssertFalse(cards.contains { $0.body.lowercased().contains("rip") })
        XCTAssertFalse(cards.contains { $0.title.lowercased().contains("grief") })
        XCTAssertFalse(cards.contains { $0.title.lowercased().contains("loss") })
    }

    func testWipeRemovesSavedBrain() {
        var brain = brainWithBars(["The city hums in flesh and bone"])
        brain.confirmedCards = [
            ArtistBrainCard(title: "Name", body: "Write as Test Artist.", source: "answer", status: .kept)
        ]
        let store = ArtistBrainStore.shared
        store.save(brain)
        XCTAssertFalse(store.brain.lyricBars.isEmpty)
        store.wipeArtistBrain()
        XCTAssertEqual(store.brain, ArtistBrain())
        XCTAssertNil(UserDefaults.standard.data(forKey: ArtistBrainStore.brainKey))
        XCTAssertTrue(ArtistBrainStore.load().lyricBars.isEmpty)
    }

    func testAbsorbSongSavesBarsImmediately() {
        let track = song()
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.songs = [track]
        let store = ArtistBrainStore.shared
        store.save(brain)
        let bars = [
            ArtistLyricIngest.makeBar(
                text: "The city hums in flesh and bone",
                song: track,
                sourceURL: nil,
                ingestSource: "genius"
            )
        ]
        store.absorbSongIngest(song: track, bars: bars)
        XCTAssertEqual(store.brain.lyricBars.count, 1)
        XCTAssertFalse(store.brain.identitySketch.isEmpty)
        XCTAssertNotNil(UserDefaults.standard.data(forKey: ArtistBrainStore.brainKey))
    }

    func testMissingLyricsCountIsPerSong() {
        let track = song()
        var brain = ArtistBrain()
        brain.songs = [track]
        XCTAssertEqual(brain.barCount(forSongId: "1"), 0)
        brain.ingestedBars = [
            ArtistLyricIngest.makeBar(
                text: "The city hums in flesh and bone",
                song: track,
                sourceURL: nil,
                ingestSource: "paste"
            )
        ]
        XCTAssertEqual(brain.barCount(forSongId: "1"), 1)
        XCTAssertEqual(brain.barCount(forSongId: "missing"), 0)
    }

    func testIdentityCardsStayWithinAllowedTitles() {
        let brain = brainWithBars([
            "I met that girl last night",
            "Shawty keep calling my phone",
            "I pour a cup of henny",
            "The city hums in flesh and bone"
        ])
        let cards = ArtistIdentityIngest.pendingCards(from: brain)
        XCTAssertTrue(Set(cards.map(\.title)).isSubset(of: ArtistOnboardingContract.allowedPendingTitles))
        XCTAssertTrue(cards.allSatisfy { !ArtistOnboardingContract.isTitlePersonaClaim($0) })
    }
}
