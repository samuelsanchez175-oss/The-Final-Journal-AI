import XCTest
@testable import XJournal_AI

final class ModelYouWiringTests: XCTestCase {

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: ModelYouWriterPolicy.sparkleDefaultedKey)
        super.tearDown()
    }

    private func track() -> ArtistSong {
        ArtistSong(
            id: "1",
            title: "Night Walk",
            primaryArtist: "Test Artist",
            isFeature: false,
            included: true,
            source: "spotify"
        )
    }

    private func filledBrain() -> ArtistBrain {
        var brain = ArtistBrain()
        let song = track()
        brain.artistName = "Test Artist"
        brain.songs = [song]
        brain.confirmedCards = [
            ArtistBrainCard(title: "Name", body: "Write as Test Artist.", source: "answer", status: .kept)
        ]
        brain.ingestedBars = [
            ArtistLyricIngest.makeBar(
                text: "I pour a cup of henny",
                song: song,
                sourceURL: nil,
                ingestSource: "paste"
            ),
            ArtistLyricIngest.makeBar(
                text: "The city hums in flesh and bone",
                song: song,
                sourceURL: nil,
                ingestSource: "paste"
            )
        ]
        return brain
    }

    func testDefaultSparkleFlipsOnceAfterKeep() {
        UserDefaults.standard.removeObject(forKey: ModelYouWriterPolicy.sparkleDefaultedKey)
        let first = ModelYouWriterPolicy.adoptDefaultSparkleIfNeeded(
            brain: filledBrain(),
            currentRaw: SuggestionModel.modelG.rawValue
        )
        XCTAssertEqual(first, SuggestionModel.modelYou.rawValue)
        let second = ModelYouWriterPolicy.adoptDefaultSparkleIfNeeded(
            brain: filledBrain(),
            currentRaw: SuggestionModel.modelG.rawValue
        )
        XCTAssertEqual(second, SuggestionModel.modelG.rawValue)
    }

    func testEmptyBrainDoesNotStealSparkle() {
        UserDefaults.standard.removeObject(forKey: ModelYouWriterPolicy.sparkleDefaultedKey)
        let raw = ModelYouWriterPolicy.adoptDefaultSparkleIfNeeded(
            brain: ArtistBrain(),
            currentRaw: SuggestionModel.modelG.rawValue
        )
        XCTAssertEqual(raw, SuggestionModel.modelG.rawValue)
    }

    func testStreetOnlyDropsPeopleAndBottle() {
        let brain = filledBrain()
        let note = "The city hums in flesh and bone"
        let all = ArtistBrainRAG.retrieve(brain: brain, noteText: note, limit: 8)
        XCTAssertTrue(all.contains { $0.kind == .confirmedCard } || all.contains { $0.text.lowercased().contains("henny") })
        let street = ArtistBrainRAG.retrieve(
            brain: brain,
            noteText: note,
            limit: 8,
            filters: ModelYouVerseFilters(streetOnly: true)
        )
        XCTAssertFalse(street.contains { $0.kind == .confirmedCard })
        XCTAssertFalse(street.contains { RemindsMeOfScorer.contentTokens($0.text).contains("henny") })
    }

    func testHousePathDoesNotUseArtistSeat() {
        XCTAssertFalse(ModelYouWriterPolicy.usesArtistSeat(artistBrainPrompt: nil))
        XCTAssertTrue(ModelYouWriterPolicy.shouldLoadHouseExemplars(artistBrainPrompt: nil))
        XCTAssertEqual(ModelYouWriterPolicy.referenceSeat(artistChunks: []), [])
    }

    func testYouBranchDoesNotShareGSettingsKey() {
        XCTAssertNotEqual(
            ModelYouWriterPolicy.settingsKey(for: .modelYou),
            ModelYouWriterPolicy.settingsKey(for: .modelG)
        )
        XCTAssertEqual(SuggestionModel.sparklePickerModels, [.modelG, .modelYou])
    }
}
