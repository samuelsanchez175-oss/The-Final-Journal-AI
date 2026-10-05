import XCTest
@testable import XJournal_AI

final class YouFitScorerTests: XCTestCase {

    private func song(id: String = "1") -> ArtistSong {
        ArtistSong(
            id: id,
            title: "Night Walk",
            primaryArtist: "Test Artist",
            isFeature: false,
            included: true,
            source: "spotify"
        )
    }

    private func brainWithBars(_ lines: [String], leaveOut: String = "") -> ArtistBrain {
        let track = song()
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.leaveOut = leaveOut
        brain.songs = [track]
        brain.ingestedBars = lines.map {
            ArtistLyricIngest.makeBar(text: $0, song: track, sourceURL: nil, ingestSource: "paste")
        }
        return brain
    }

    func testTeacherSoundingVerseFailsYouFit() {
        let brain = brainWithBars(["The city hums in flesh and bone"])
        let verse = """
        Wunna Wunna, they workin my nerves
        I hop out a 911 in Atlanta
        Roley on the wrist, that's a flex
        """
        let score = YouFitScorer.score(verse: verse, brain: brain)
        XCTAssertLessThan(score.total, YouFitScorer.floor)
        XCTAssertGreaterThan(score.housePenalty, 0)
        XCTAssertEqual(YouFitScorer.reject(score), .youFitTooLow)
    }

    func testNeverUseMamaRejects() {
        let brain = brainWithBars(["The city hums in flesh and bone"], leaveOut: "mama")
        let verse = "I still call mama from the city block"
        let score = YouFitScorer.score(verse: verse, brain: brain)
        XCTAssertEqual(score.neverUseHits, 1)
        XCTAssertEqual(score.total, 0)
        XCTAssertEqual(YouFitScorer.reject(score), .neverUseHit)
        XCTAssertEqual(HardRejectionEngine().rejectYouVerse(verse, brain: brain), .neverUseHit)
    }

    func testUnconfirmedGriefRejects() {
        var brain = brainWithBars(["The city hums in flesh and bone"])
        brain.pendingCards = [
            ArtistBrainCard(
                title: "Possible loss",
                body: "cousin who might be gone",
                source: "infer",
                status: .pending
            )
        ]
        let verse = "I still talk to cousin in the quiet room"
        let score = YouFitScorer.score(verse: verse, brain: brain)
        XCTAssertGreaterThan(score.unconfirmedGriefHits, 0)
        XCTAssertEqual(YouFitScorer.reject(score), .unconfirmedGrief)
    }

    func testPunchDemotedWhenPayoffIsTexture() {
        let brain = brainWithBars([
            "I pour a cup of henny",
            "The city hums in flesh and bone"
        ])
        let graph = ArtistBrainGraph.rebuild(from: brain)
        XCTAssertTrue(graph.punchLabels.contains("henny") || graph.objects.contains { $0.token == "henny" && $0.punch >= 1 })
        XCTAssertTrue(graph.punchLabels.contains("henny") || (graph.objects.first { $0.token == "henny" }?.punch ?? 0) >= 1)
        let verse = "The henny sits inside the cup"
        let score = YouFitScorer.score(verse: verse, brain: brain, graph: graph)
        XCTAssertTrue(score.punchDemoted)
        XCTAssertEqual(YouFitScorer.reject(score), .punchDemoted)
    }

    func testMatchingCatalogVersePasses() {
        let brain = brainWithBars(["The city hums in flesh and bone"])
        let verse = "The city hums in flesh and bone\nEach step I take, the rhythm counts"
        let score = YouFitScorer.score(verse: verse, brain: brain)
        XCTAssertGreaterThanOrEqual(score.total, YouFitScorer.floor)
        XCTAssertNil(YouFitScorer.reject(score))
    }

    func testPickPrefersHighGAndHighYou() {
        let brain = brainWithBars(["The city hums in flesh and bone"])
        let teacher = "Wunna Wunna, they workin my nerves\nRoley on the wrist in Atlanta"
        let theirs = "The city hums in flesh and bone\nEach step I take, the rhythm counts"
        let picked = YouFitScorer.pick(
            candidates: [
                (text: teacher, gScore: 92),
                (text: theirs, gScore: 78)
            ],
            brain: brain
        )
        XCTAssertEqual(picked?.text, theirs)
        XCTAssertGreaterThanOrEqual(picked?.you.total ?? 0, YouFitScorer.floor)
    }

    func testHomeStanceReadsLyricBars() {
        var brain = brainWithBars([
            "I keep the city at a distance now",
            "Don't ask me nothing, I won't explain"
        ])
        brain.talkingTo = .theCity
        let stance = ArtistBrainStore.inferHomeStance(from: brain)
        XCTAssertEqual(stance.audienceScope, .public)
    }
}
