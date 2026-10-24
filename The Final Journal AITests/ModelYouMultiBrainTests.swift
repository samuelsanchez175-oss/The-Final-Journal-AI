import XCTest
@testable import XJournal_AI

@MainActor
final class ModelYouMultiBrainTests: XCTestCase {
    private var tempDirectory: URL!
    private var savedLegacyBrain: Data?
    private var savedActiveID: String?

    override func setUp() async throws {
        try await super.setUp()
        savedLegacyBrain = UserDefaults.standard.data(forKey: ArtistBrainStore.brainKey)
        savedActiveID = UserDefaults.standard.string(forKey: ArtistBrainStore.activeBrainIDKey)

        let tempBase = FileManager.default.temporaryDirectory
        tempDirectory = tempBase.appendingPathComponent("ModelYouMultiBrainTests_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        ArtistBrainStore.shared.customBrainsDirectory = tempDirectory
    }

    override func tearDown() async throws {
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        ArtistBrainStore.shared.customBrainsDirectory = nil

        UserDefaults.standard.removeObject(forKey: ModelYouSettings.key(for: "gunna_voice"))
        UserDefaults.standard.removeObject(forKey: ModelYouSettings.key(for: "drake_voice"))
        UserDefaults.standard.removeObject(forKey: ModelYouSettings.key(for: "test_voice_1"))
        UserDefaults.standard.removeObject(forKey: ModelYouSettings.key(for: "test_voice_2"))
        UserDefaults.standard.removeObject(forKey: ModelYouSettings.key(for: "voice_to_delete"))
        UserDefaults.standard.removeObject(forKey: ModelYouSettings.key(for: "default"))

        if let savedLegacyBrain {
            UserDefaults.standard.set(savedLegacyBrain, forKey: ArtistBrainStore.brainKey)
        } else {
            UserDefaults.standard.removeObject(forKey: ArtistBrainStore.brainKey)
        }
        if let savedActiveID {
            UserDefaults.standard.set(savedActiveID, forKey: ArtistBrainStore.activeBrainIDKey)
        } else {
            UserDefaults.standard.removeObject(forKey: ArtistBrainStore.activeBrainIDKey)
        }
        ArtistBrainStore.shared.reload()

        try await super.tearDown()
    }

    private func makeSong(id: String, title: String, artist: String) -> ArtistSong {
        ArtistSong(
            id: id,
            title: title,
            primaryArtist: artist,
            isFeature: false,
            included: true,
            source: "spotify"
        )
    }

    private func makeBrain(id: String, artist: String, barTexts: [String]) -> ArtistBrain {
        var brain = ArtistBrain(id: id)
        brain.artistName = artist
        let track = makeSong(id: "s_\(id)", title: "\(artist) Track", artist: artist)
        brain.songs = [track]
        brain.confirmedCards = [
            ArtistBrainCard(title: "Identity", body: "Persona for \(artist)", source: "answer", status: .kept)
        ]
        brain.ingestedBars = barTexts.map {
            ArtistLyricIngest.makeBar(text: $0, song: track, sourceURL: nil, ingestSource: "test")
        }
        brain.chunks = ArtistBrainStore.rebuildChunks(from: brain)
        return brain
    }

    // 1. Acceptance test: Old brain in UserDefaults migrates to default.json with zero data loss
    func testLegacyBrainMigratesToDefaultJsonWithoutDataLoss() throws {
        var legacy = makeBrain(id: "legacy_src", artist: "Legacy Gunna", barTexts: [
            "Penthouse is large, gotta fast car",
            "Maximum withdraws, blue audamar"
        ])
        legacy.talkingTo = .theCity
        legacy.leaveOut = "cheap cars, fake jewelry"
        legacy.noLongerWriteLike = "mumble flow"
        let legacyData = try JSONEncoder().encode(legacy)
        UserDefaults.standard.set(legacyData, forKey: ArtistBrainStore.brainKey)

        let store = ArtistBrainStore.shared
        let defaultURL = store.fileURL(for: "default")
        XCTAssertFalse(FileManager.default.fileExists(atPath: defaultURL.path))

        let migrated = store.migrateLegacyBrainIfNeeded()
        XCTAssertTrue(migrated, "Expected migration to succeed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: defaultURL.path), "default.json should exist")

        guard let loaded = store.load(id: "default") else {
            XCTFail("default brain should be loadable after migration")
            return
        }
        XCTAssertEqual(loaded.artistName, "Legacy Gunna")
        XCTAssertEqual(loaded.lyricBars.count, 2)
        XCTAssertEqual(loaded.lyricBars[0].text, "Penthouse is large, gotta fast car")
        XCTAssertEqual(loaded.lyricBars[1].text, "Maximum withdraws, blue audamar")
        XCTAssertEqual(loaded.talkingTo, .theCity)
        XCTAssertEqual(loaded.leaveOut, "cheap cars, fake jewelry")
        XCTAssertEqual(loaded.noLongerWriteLike, "mumble flow")
        XCTAssertEqual(loaded.confirmedCards.count, 1)

        let secondRun = store.migrateLegacyBrainIfNeeded()
        XCTAssertFalse(secondRun, "Second migration run should be an idempotent no-op")
    }

    // 2. Acceptance test: Create two brains, switch, assert store & reload reads the right one
    func testCreateTwoBrainsAndSwitchActiveBrain() throws {
        let store = ArtistBrainStore.shared

        let gunnaBrain = makeBrain(id: "gunna_voice", artist: "Gunna", barTexts: [
            "Penthouse is large, gotta fast car, maximum withdraws, blue audamar"
        ])
        let drakeBrain = makeBrain(id: "drake_voice", artist: "Drake", barTexts: [
            "Started from the bottom now the whole team here"
        ])

        store.save(brain: gunnaBrain)
        store.save(brain: drakeBrain)

        let summaries = store.allBrainSummaries()
        XCTAssertTrue(summaries.contains { $0.id == "gunna_voice" && $0.name == "Gunna" })
        XCTAssertTrue(summaries.contains { $0.id == "drake_voice" && $0.name == "Drake" })

        // Switch to Gunna
        store.switchBrain(to: "gunna_voice")
        XCTAssertEqual(store.activeBrainID, "gunna_voice")
        XCTAssertEqual(store.brain.artistName, "Gunna")
        XCTAssertEqual(store.brain.lyricBars.first?.text, "Penthouse is large, gotta fast car, maximum withdraws, blue audamar")

        store.reload()
        XCTAssertEqual(store.brain.artistName, "Gunna")

        // Switch to Drake
        store.switchBrain(to: "drake_voice")
        XCTAssertEqual(store.activeBrainID, "drake_voice")
        XCTAssertEqual(store.brain.artistName, "Drake")
        XCTAssertEqual(store.brain.lyricBars.first?.text, "Started from the bottom now the whole team here")

        store.reload()
        XCTAssertEqual(store.brain.artistName, "Drake")
    }

    // 3. Acceptance test: Settings keys (modelYou_settings_<brainID>) don't collide
    func testSettingsKeysDoNotCollideBetweenBrains() throws {
        let brainAID = "test_voice_1"
        let brainBID = "test_voice_2"

        XCTAssertEqual(ModelYouSettings.key(for: brainAID), "modelYou_settings_test_voice_1")
        XCTAssertEqual(ModelYouSettings.key(for: brainBID), "modelYou_settings_test_voice_2")
        XCTAssertNotEqual(ModelYouSettings.key(for: brainAID), ModelYouSettings.key(for: brainBID))

        let settingsA = ModelYouSettings(usePeople: false, useBottle: false, streetOnly: true)
        settingsA.save(for: brainAID)

        let settingsB = ModelYouSettings(usePeople: true, useBottle: true, streetOnly: false)
        settingsB.save(for: brainBID)

        let loadedA = ModelYouSettings.load(for: brainAID)
        let loadedB = ModelYouSettings.load(for: brainBID)

        XCTAssertEqual(loadedA.streetOnly, true)
        XCTAssertEqual(loadedA.usePeople, false)
        XCTAssertEqual(loadedA.useBottle, false)

        XCTAssertEqual(loadedB.streetOnly, false)
        XCTAssertEqual(loadedB.usePeople, true)
        XCTAssertEqual(loadedB.useBottle, true)

        var updatedB = loadedB
        updatedB.useBottle = false
        updatedB.save(for: brainBID)

        let reloadedA = ModelYouSettings.load(for: brainAID)
        XCTAssertEqual(reloadedA.streetOnly, true)
        XCTAssertEqual(reloadedA.useBottle, false)

        let reloadedB = ModelYouSettings.load(for: brainBID)
        XCTAssertEqual(reloadedB.useBottle, false)
        XCTAssertEqual(reloadedB.usePeople, true)
    }

    // 4. Acceptance test: Delete brain removes file and settings key
    func testDeleteBrainRemovesFileAndSettings() throws {
        let store = ArtistBrainStore.shared
        let brain = makeBrain(id: "voice_to_delete", artist: "Temporary Voice", barTexts: ["Temp bar"])
        store.save(brain: brain)

        let settings = ModelYouSettings(usePeople: true, useBottle: false, streetOnly: false)
        settings.save(for: "voice_to_delete")

        let file = store.fileURL(for: "voice_to_delete")
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
        XCTAssertNotNil(UserDefaults.standard.data(forKey: ModelYouSettings.key(for: "voice_to_delete")))

        store.delete(id: "voice_to_delete")

        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
        XCTAssertNil(UserDefaults.standard.data(forKey: ModelYouSettings.key(for: "voice_to_delete")))
        XCTAssertNil(store.load(id: "voice_to_delete"))
    }

    // 5. Acceptance test: Sparkle picker models remain intact
    func testSparklePickerModelsRemainIntact() {
        XCTAssertEqual(SuggestionModel.sparklePickerModels, [.modelG, .modelYou])
    }
}
