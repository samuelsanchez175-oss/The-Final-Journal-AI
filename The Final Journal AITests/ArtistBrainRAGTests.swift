import XCTest
@testable import XJournal_AI

final class ArtistBrainRAGTests: XCTestCase {

    private func song(id: String, title: String, included: Bool = true) -> ArtistSong {
        ArtistSong(
            id: id,
            title: title,
            primaryArtist: "Test Artist",
            isFeature: false,
            included: included,
            source: "spotify"
        )
    }

    private func bar(_ text: String, song: ArtistSong) -> ArtistBrainChunk {
        ArtistLyricIngest.makeBar(text: text, song: song, sourceURL: nil, ingestSource: "paste")
    }

    func testWrapPocketBeatsFarSyllable() {
        let track = song(id: "1", title: "Night Walk")
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.songs = [track]
        let close = "The night still moves in flesh and chrome"
        let far = "Jump kick punch block grab spin toss"
        brain.ingestedBars = [
            bar(close, song: track),
            bar(far, song: track)
        ]
        let query = "The city hums in flesh and bone"
        let retrieved = ArtistBrainRAG.retrieve(brain: brain, noteText: query, limit: 8)
        XCTAssertTrue(retrieved.contains { $0.text == close })
        XCTAssertFalse(retrieved.contains { $0.text == far })
    }

    func testTitleChunksNeverRetrieve() {
        let track = song(id: "1", title: "Bounce Back")
        var brain = ArtistBrain()
        brain.songs = [track]
        brain.ingestedBars = [
            bar("Bounce Back", song: track),
            bar("The city hums in flesh and bone", song: track)
        ]
        let retrieved = ArtistBrainRAG.retrieve(
            brain: brain,
            noteText: "The city hums in flesh and bone",
            limit: 8
        )
        XCTAssertFalse(retrieved.contains { $0.text == "Bounce Back" })
        XCTAssertFalse(retrieved.contains { RemindsMeOfScorer.isTitleLeak($0.text, song: "Bounce Back") })
    }

    func testNeverUseIsExcluded() {
        let track = song(id: "1", title: "Night Walk")
        var brain = ArtistBrain()
        brain.songs = [track]
        brain.leaveOut = "mama"
        brain.ingestedBars = [
            bar("I still call mama from the city block", song: track),
            bar("The city hums in flesh and bone", song: track)
        ]
        let retrieved = ArtistBrainRAG.retrieve(
            brain: brain,
            noteText: "The city hums in flesh and bone",
            limit: 8
        )
        XCTAssertFalse(retrieved.contains { $0.text.lowercased().contains("mama") })
        XCTAssertTrue(retrieved.contains { $0.text == "The city hums in flesh and bone" })
    }

    func testPendingCardsNeverRetrieve() {
        let track = song(id: "1", title: "Night Walk")
        var brain = ArtistBrain()
        brain.songs = [track]
        brain.ingestedBars = [bar("The city hums in flesh and bone", song: track)]
        brain.pendingCards = [
            ArtistBrainCard(
                title: "Possible loss",
                body: "cousin who might be gone",
                source: "infer",
                status: .pending
            )
        ]
        brain.confirmedCards = [
            ArtistBrainCard(
                title: "Who you're talking to",
                body: "Talk to the city.",
                source: "answer",
                status: .kept,
                mentionRole: .casual
            )
        ]
        let graph = ArtistBrainGraph.rebuild(from: brain)
        XCTAssertFalse(graph.retrieveChunks.contains { $0.text.lowercased().contains("cousin") })
        let retrieved = ArtistBrainRAG.retrieve(
            brain: brain,
            noteText: "The city hums in flesh and bone",
            limit: 8
        )
        XCTAssertFalse(retrieved.contains { $0.text.lowercased().contains("cousin") })
        XCTAssertTrue(retrieved.contains { $0.kind == .confirmedCard && $0.text.contains("city") }
            || retrieved.contains { $0.kind == .lyricBar })
    }

    func testEmptyRetrieveIsHonestWhenNoBarsOrCards() {
        var brain = ArtistBrain()
        brain.talkingTo = .theCity
        brain.chunks = [
            ArtistBrainRAG.makeChunk(kind: .answer, text: brain.talkingTo.promptLine)
        ]
        let retrieved = ArtistBrainRAG.retrieve(
            brain: brain,
            noteText: "The city hums in flesh and bone",
            limit: 8
        )
        XCTAssertTrue(retrieved.isEmpty)
    }

    func testPunchIsEndWordAndCasualIsMidBar() {
        let track = song(id: "1", title: "Night Walk")
        var brain = ArtistBrain()
        brain.songs = [track]
        brain.ingestedBars = [
            bar("I pour a cup of henny", song: track),
            bar("The henny sits inside the cup", song: track),
            bar("The city hums in flesh and bone", song: track)
        ]
        let graph = ArtistBrainGraph.rebuild(from: brain)
        let henny = graph.objects.first { $0.token == "henny" }
        XCTAssertNotNil(henny)
        XCTAssertGreaterThanOrEqual(henny?.punch ?? 0, 1)
        let city = graph.objects.first { $0.token == "city" }
        XCTAssertEqual(city?.role, .casual)
        XCTAssertEqual(city?.punch ?? 0, 0)
    }

    func testUncheckedSongDropsFromGraph() {
        let keep = song(id: "1", title: "Night Walk", included: true)
        let drop = song(id: "2", title: "Echoes", included: false)
        var brain = ArtistBrain()
        brain.songs = [keep, drop]
        brain.ingestedBars = [
            bar("The city hums in flesh and bone", song: keep),
            bar("I walk the block where echoes bounce", song: drop)
        ]
        let graph = ArtistBrainGraph.rebuild(from: brain)
        XCTAssertTrue(graph.retrieveChunks.contains { $0.songId == "1" })
        XCTAssertFalse(graph.retrieveChunks.contains { $0.songId == "2" })
    }
}
