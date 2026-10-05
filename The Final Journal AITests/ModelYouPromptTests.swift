import XCTest
@testable import XJournal_AI

final class ModelYouPromptTests: XCTestCase {

    func testSparklePickerIsGAndYouOnly() {
        XCTAssertEqual(SuggestionModel.sparklePickerModels, [.modelG, .modelYou])
        XCTAssertFalse(SuggestionModel.sparklePickerModels.contains(.modelY))
    }

    func testYouSettingsKeyIsNotSharedWithG() {
        XCTAssertEqual(ModelYouWriterPolicy.settingsKey(for: .modelYou), "modelYou_settings")
        XCTAssertEqual(ModelYouWriterPolicy.settingsKey(for: .modelG), "modelGv3_settings")
        XCTAssertNotEqual(
            ModelYouWriterPolicy.settingsKey(for: .modelYou),
            ModelYouWriterPolicy.settingsKey(for: .modelG)
        )
    }

    func testEmptyBrainInjectionHasNoHouseIdentity() {
        let prompt = ArtistBrainPrompt.injection(brain: ArtistBrain(), noteText: "today I miss home", noteAxes: nil)
        XCTAssertTrue(prompt.contains("Write like a pro") || prompt.lowercased().contains("only what they told"))
        XCTAssertFalse(ModelYouWriterPolicy.containsHouseIdentityNouns(prompt))
    }

    func testFilledBrainInjectionUsesArtistBarsNotTitlesOnly() {
        let track = ArtistSong(
            id: "1",
            title: "Night Walk",
            primaryArtist: "Test Artist",
            isFeature: false,
            included: true,
            source: "spotify"
        )
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.songs = [track]
        brain.confirmedCards = [
            ArtistBrainCard(title: "Name", body: "Write as Test Artist.", source: "answer", status: .kept)
        ]
        brain.ingestedBars = [
            ArtistLyricIngest.makeBar(
                text: "The city hums in flesh and bone",
                song: track,
                sourceURL: nil,
                ingestSource: "paste"
            )
        ]
        let prompt = ArtistBrainPrompt.injection(
            brain: brain,
            noteText: "The city hums in flesh and bone",
            noteAxes: nil
        )
        XCTAssertTrue(prompt.contains("Test Artist"))
        XCTAssertTrue(prompt.contains("flesh") || prompt.contains("confirmed"))
        XCTAssertFalse(prompt.contains("titles only"))
        XCTAssertTrue(ModelYouWriterPolicy.usesArtistSeat(artistBrainPrompt: prompt))
        XCTAssertFalse(ModelYouWriterPolicy.shouldLoadHouseExemplars(artistBrainPrompt: prompt))
        XCTAssertFalse(ModelYouWriterPolicy.usesHouseLuxury(artistBrainPrompt: prompt))
    }

    func testHouseLuxuryAndPaletteAreOffOnYouSeat() {
        XCTAssertTrue(ModelYouWriterPolicy.usesHouseLuxury(artistBrainPrompt: nil))
        XCTAssertFalse(ModelYouWriterPolicy.usesHouseLuxury(artistBrainPrompt: "Artist: Test."))
        let luxury = ModelYouWriterPolicy.luxuryPromptLine(
            layer: LuxuryLayer(brands: ["Roley"], specs: [], environments: [], provenance: [], archives: []),
            usingArtistBrain: true
        )
        XCTAssertTrue(luxury.isEmpty)
        XCTAssertFalse(luxury.lowercased().contains("roley"))
        let palette = ModelYouWriterPolicy.housePaletteLine(
            palette: ["Wunna", "Roley"],
            usingArtistBrain: true
        )
        XCTAssertTrue(palette.isEmpty)
        XCTAssertFalse(ModelYouWriterPolicy.containsHouseIdentityNouns(
            ModelYouWriterPolicy.concreteRule(usingArtistBrain: true)
        ))
    }

    func testReferenceSeatPrefersArtistChunks() {
        let seat = ModelYouWriterPolicy.referenceSeat(artistChunks: ["The city hums in flesh and bone", "  "])
        XCTAssertEqual(seat, ["The city hums in flesh and bone"])
        XCTAssertEqual(ModelYouWriterPolicy.referenceSeat(artistChunks: []), [])
    }

    func testThinBrainCaption() {
        XCTAssertTrue(
            ModelYouWriterPolicy.controlSurfaceCaption(brain: ArtistBrain()).contains("getting to know you")
        )
        var brain = ArtistBrain()
        let track = ArtistSong(
            id: "1",
            title: "Night Walk",
            primaryArtist: "Test Artist",
            isFeature: false,
            included: true,
            source: "spotify"
        )
        brain.songs = [track]
        brain.ingestedBars = [
            ArtistLyricIngest.makeBar(
                text: "The city hums in flesh and bone",
                song: track,
                sourceURL: nil,
                ingestSource: "paste"
            )
        ]
        XCTAssertFalse(ModelYouWriterPolicy.controlSurfaceCaption(brain: brain).contains("getting to know you"))
        XCTAssertTrue(ModelYouWriterPolicy.controlSurfaceCaption(brain: brain).contains("Model You"))
    }

    func testReferenceBarsDirectiveNamesTheirCatalog() {
        let line = ModelYouWriterPolicy.referenceBarsDirective(usingArtistBrain: true, inspiration: 0.8)
        XCTAssertTrue(line.lowercased().contains("this is you") || line.lowercased().contains("their catalog"))
        XCTAssertFalse(line.lowercased().contains("gunna"))
    }

    func testStreetOnlyInjectionDropsPeopleBottleAndIG() {
        let track = ArtistSong(
            id: "1",
            title: "Night Walk",
            primaryArtist: "Test Artist",
            isFeature: false,
            included: true,
            source: "spotify"
        )
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.talkingTo = .aGirl
        brain.instagramHandle = "testartist"
        brain.songs = [track]
        brain.confirmedCards = [
            ArtistBrainCard(
                title: "Sister",
                body: "Keep Maya on the punch.",
                source: "answer",
                status: .kept,
                mentionRole: .punch
            )
        ]
        brain.ingestedBars = [
            ArtistLyricIngest.makeBar(
                text: "I pour a cup of henny",
                song: track,
                sourceURL: nil,
                ingestSource: "paste"
            ),
            ArtistLyricIngest.makeBar(
                text: "The city hums in flesh and bone",
                song: track,
                sourceURL: nil,
                ingestSource: "paste"
            )
        ]
        let prompt = ArtistBrainPrompt.injection(
            brain: brain,
            noteText: "The city hums in flesh and bone",
            noteAxes: nil,
            filters: ModelYouVerseFilters(streetOnly: true)
        )
        XCTAssertFalse(prompt.lowercased().contains("maya"))
        XCTAssertFalse(prompt.lowercased().contains("sister"))
        XCTAssertFalse(prompt.lowercased().contains("talk to a girl"))
        XCTAssertFalse(prompt.lowercased().contains("henny"))
        XCTAssertFalse(prompt.lowercased().contains("instagram") || prompt.contains("@testartist"))
        XCTAssertTrue(prompt.lowercased().contains("street only") || prompt.lowercased().contains("not a person"))
        let rule = ModelYouWriterPolicy.concreteRule(
            usingArtistBrain: true,
            filters: ModelYouVerseFilters(streetOnly: true)
        )
        XCTAssertFalse(rule.contains("their places, people, bottles"))
        XCTAssertTrue(rule.lowercased().contains("street") || rule.lowercased().contains("block"))
    }

    func testDefaultInjectionKeepsPeopleAndBottle() {
        let track = ArtistSong(
            id: "1",
            title: "Night Walk",
            primaryArtist: "Test Artist",
            isFeature: false,
            included: true,
            source: "spotify"
        )
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.talkingTo = .aGirl
        brain.songs = [track]
        brain.confirmedCards = [
            ArtistBrainCard(
                title: "Sister",
                body: "Keep Maya on the punch.",
                source: "answer",
                status: .kept
            )
        ]
        brain.ingestedBars = [
            ArtistLyricIngest.makeBar(
                text: "I pour a cup of henny",
                song: track,
                sourceURL: nil,
                ingestSource: "paste"
            )
        ]
        let prompt = ArtistBrainPrompt.injection(
            brain: brain,
            noteText: "I pour a cup of henny",
            noteAxes: nil
        )
        XCTAssertTrue(prompt.contains("Maya") || prompt.contains("Sister"))
        XCTAssertTrue(prompt.lowercased().contains("talk to a girl"))
        XCTAssertTrue(prompt.lowercased().contains("henny"))
        XCTAssertFalse(prompt.lowercased().contains("instagram"))
    }
}
