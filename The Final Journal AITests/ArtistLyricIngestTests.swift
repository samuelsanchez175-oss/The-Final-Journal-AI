import XCTest
@testable import XJournal_AI

final class ArtistLyricIngestTests: XCTestCase {

    private func song(
        id: String,
        title: String,
        artist: String,
        included: Bool,
        feature: Bool = false
    ) -> ArtistSong {
        ArtistSong(
            id: id,
            title: title,
            primaryArtist: artist,
            isFeature: feature,
            included: included,
            source: "spotify"
        )
    }

    private func lyricJSON(artist: String, title: String, snippet: String, id: Int = 1) -> Data {
        """
        {"response":{"sections":[{"type":"lyric","hits":[{"highlights":[{"property":"lyrics","value":\(jsonString(snippet))}],"result":{"id":\(id),"title":\(jsonString(title)),"url":"https://genius.com/x","primary_artist":{"name":\(jsonString(artist))}}}]}]}}
        """.data(using: .utf8)!
    }

    private func jsonString(_ raw: String) -> String {
        let escaped = raw
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        return "\"\(escaped)\""
    }

    func testLyricSearchYieldsBarsNotTitle() throws {
        let snippet = "ha\nThe city hums in flesh and bone\nI'm about to pour"
        let data = lyricJSON(artist: "Test Artist", title: "Night Walk", snippet: snippet)
        let claimed = song(id: "1", title: "Night Walk", artist: "Test Artist", included: true)
        let bars = try ArtistLyricIngest.chunks(fromLyricSearch: data, song: claimed, catalogArtist: "Test Artist")
        XCTAssertFalse(bars.isEmpty)
        XCTAssertTrue(bars.allSatisfy { $0.kind == .lyricBar })
        XCTAssertTrue(bars.contains { $0.text == "The city hums in flesh and bone" })
        XCTAssertFalse(bars.contains { $0.text == "Night Walk" })
        XCTAssertEqual(bars.first?.songId, "1")
    }

    func testTitleOnlySnippetIsDropped() throws {
        let data = lyricJSON(artist: "Test Artist", title: "Bounce Back", snippet: "Bounce Back")
        let claimed = song(id: "1", title: "Bounce Back", artist: "Test Artist", included: true)
        let bars = try ArtistLyricIngest.chunks(fromLyricSearch: data, song: claimed, catalogArtist: "Test Artist")
        XCTAssertTrue(bars.isEmpty)
    }

    func testOtherArtistHitIsDropped() throws {
        let snippet = "I walk the block where echoes bounce"
        let data = lyricJSON(artist: "Some Other Rapper", title: "Night Walk", snippet: snippet)
        let claimed = song(id: "1", title: "Night Walk", artist: "Test Artist", included: true)
        let bars = try ArtistLyricIngest.chunks(fromLyricSearch: data, song: claimed, catalogArtist: "Test Artist")
        XCTAssertTrue(bars.isEmpty)
    }

    func testUncheckedFeatureDoesNotIngest() throws {
        let snippet = "I walk the block where echoes bounce"
        let data = lyricJSON(artist: "Other", title: "Feature Hop", snippet: snippet)
        let feature = song(id: "2", title: "Feature Hop", artist: "Other", included: false, feature: true)
        let bars = try ArtistLyricIngest.chunks(fromLyricSearch: data, song: feature, catalogArtist: "Test Artist")
        XCTAssertTrue(bars.isEmpty)
    }

    func testPasteSplitsRealBarsAndDropsAdlibs() {
        let paste = """
        Yeah
        The city hums in flesh and bone
        Each step I take, the rhythm counts
        Bounce Back
        """
        let claimed = song(id: "1", title: "Bounce Back", artist: "Test Artist", included: true)
        let bars = ArtistLyricIngest.chunks(fromPaste: paste, song: claimed)
        XCTAssertEqual(bars.map(\.text), [
            "The city hums in flesh and bone",
            "Each step I take, the rhythm counts"
        ])
        XCTAssertTrue(bars.allSatisfy { $0.ingestSource == "paste" })
    }

    func testPasteOnUncheckedSongIsEmpty() {
        let claimed = song(id: "1", title: "Night Walk", artist: "Test Artist", included: false)
        let bars = ArtistLyricIngest.chunks(
            fromPaste: "The city hums in flesh and bone",
            song: claimed
        )
        XCTAssertTrue(bars.isEmpty)
    }

    func testThreeClaimedTracksBuildLyricChunks() throws {
        var brain = ArtistBrain()
        brain.artistName = "Test Artist"
        brain.songs = [
            song(id: "1", title: "Night Walk", artist: "Test Artist", included: true),
            song(id: "2", title: "Echoes", artist: "Test Artist", included: true),
            song(id: "3", title: "Quiet Room", artist: "Test Artist", included: true),
            song(id: "4", title: "Feature Hop", artist: "Other", included: false, feature: true)
        ]
        let fixtures: [(String, String, String)] = [
            ("1", "Night Walk", "The city hums in flesh and bone"),
            ("2", "Echoes", "I walk the block where echoes bounce"),
            ("3", "Quiet Room", "Each step I take, the rhythm counts")
        ]
        var ingested: [ArtistBrainChunk] = []
        for (id, title, line) in fixtures {
            let song = brain.songs.first { $0.id == id }!
            let data = lyricJSON(artist: "Test Artist", title: title, snippet: "ha\n\(line)\nI'm about to pour")
            ingested += try ArtistLyricIngest.chunks(fromLyricSearch: data, song: song, catalogArtist: "Test Artist")
        }
        let feature = brain.songs.first { $0.id == "4" }!
        let featureData = lyricJSON(artist: "Other", title: "Feature Hop", snippet: "Somebody else's whole verse in here now")
        ingested += try ArtistLyricIngest.chunks(fromLyricSearch: featureData, song: feature, catalogArtist: "Test Artist")
        brain.ingestedBars = ingested
        let chunks = ArtistBrainStore.rebuildChunks(from: brain)
        let lyric = chunks.filter { $0.kind == .lyricBar }
        XCTAssertGreaterThanOrEqual(lyric.count, 3)
        XCTAssertFalse(lyric.contains { RemindsMeOfScorer.isTitleLeak($0.text, song: $0.songTitle) })
        XCTAssertFalse(lyric.contains { $0.songId == "4" })
    }

    func testUncheckDropsChunksOnRebuild() {
        var brain = ArtistBrain()
        let kept = song(id: "1", title: "Night Walk", artist: "Test Artist", included: true)
        let drop = song(id: "2", title: "Echoes", artist: "Test Artist", included: true)
        brain.songs = [kept, drop]
        brain.ingestedBars = [
            ArtistLyricIngest.makeBar(
                text: "The city hums in flesh and bone",
                song: kept,
                sourceURL: nil,
                ingestSource: "paste"
            ),
            ArtistLyricIngest.makeBar(
                text: "I walk the block where echoes bounce",
                song: drop,
                sourceURL: nil,
                ingestSource: "paste"
            )
        ]
        XCTAssertEqual(ArtistBrainStore.rebuildChunks(from: brain).filter { $0.kind == .lyricBar }.count, 2)
        brain.songs[1].included = false
        let after = ArtistBrainStore.rebuildChunks(from: brain).filter { $0.kind == .lyricBar }
        XCTAssertEqual(after.map(\.songId), ["1"])
        XCTAssertEqual(brain.lyricBars.map(\.songId), ["1"])
    }

    func testMergeReplacesOneSongOnly() {
        let a = song(id: "1", title: "Night Walk", artist: "Test Artist", included: true)
        let b = song(id: "2", title: "Echoes", artist: "Test Artist", included: true)
        let existing = [
            ArtistLyricIngest.makeBar(text: "The city hums in flesh and bone", song: a, sourceURL: nil, ingestSource: "genius"),
            ArtistLyricIngest.makeBar(text: "I walk the block where echoes bounce", song: b, sourceURL: nil, ingestSource: "genius")
        ]
        let incoming = [
            ArtistLyricIngest.makeBar(text: "Each step I take, the rhythm counts", song: a, sourceURL: nil, ingestSource: "paste")
        ]
        let merged = ArtistLyricIngest.merge(existing, with: incoming, replacingSongId: "1")
        XCTAssertEqual(merged.filter { $0.songId == "1" }.map(\.text), ["Each step I take, the rhythm counts"])
        XCTAssertEqual(merged.filter { $0.songId == "2" }.map(\.text), ["I walk the block where echoes bounce"])
    }
}
