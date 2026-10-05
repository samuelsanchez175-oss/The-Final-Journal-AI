import SQLite3
import XCTest
@testable import XJournal_AI

final class BarHitsCatalogStoreTests: XCTestCase {
    private var url: URL!

    override func setUpWithError() throws {
        url = FileManager.default.temporaryDirectory.appendingPathComponent("barhits-\(UUID().uuidString).sqlite")
        try Self.buildFixture(at: url)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: url)
    }

    func testWrapWindowQueryReturnsSevenToTenAndSkipsSix() throws {
        let store = try BarHitsCatalogStore(databaseURL: url)
        let rows = store.wrapCandidates(
            syllableMin: 7,
            syllableMax: 10,
            endWord: "bone",
            phoneticClass: "OW1 N",
            nearWords: ["tone"]
        )
        let lines = Set(rows.map(\.line))
        XCTAssertTrue(lines.contains("The city hums in flesh and bone"))
        XCTAssertTrue(lines.contains("I left the flesh and bone"))
        XCTAssertTrue(lines.contains("Walking through the city in flesh and bone"))
        XCTAssertTrue(lines.contains("Hear the speaker tone"))
        XCTAssertFalse(lines.contains("Flesh and bone tonight"))
        XCTAssertFalse(lines.contains("Unrelated paper line in the city"))
        XCTAssertTrue(rows.allSatisfy { (7...10).contains($0.syllables) })
    }

    func testWrapQuerySpreadsArtistsInsteadOfGunnaFirstRowid() throws {
        let store = try BarHitsCatalogStore(databaseURL: url)
        let rows = store.wrapCandidates(
            syllableMin: 7,
            syllableMax: 10,
            endWord: "smoke",
            phoneticClass: "",
            nearWords: [],
            limit: 12
        )
        let artists = Set(rows.compactMap(\.artist))
        XCTAssertTrue(artists.contains("Lil Wayne"))
        XCTAssertTrue(artists.contains("Lil Uzi Vert"))
        XCTAssertTrue(artists.contains("Drake"))
        XCTAssertGreaterThanOrEqual(artists.count, 3)
    }

    func testArtistNamesComeFromCatalog() throws {
        let store = try BarHitsCatalogStore(databaseURL: url)
        let names = store.artistNames()
        XCTAssertTrue(names.contains("Gunna"))
        XCTAssertTrue(names.contains("Lil Wayne"))
        XCTAssertGreaterThanOrEqual(names.count, 5)
    }

    func testCatalogSongIdIsArtistPipeTitleForMIRLookup() throws {
        let store = try BarHitsCatalogStore(databaseURL: url)
        let songs = store.catalogSongs()
        XCTAssertTrue(songs.contains { $0.id == "Drake|A" })
        XCTAssertEqual(
            songs.first { $0.artist == "Drake" && $0.title == "A" }?.id,
            CatalogMIRBatchService.songRecordKey(artist: "Drake", title: "A")
        )
        XCTAssertFalse(songs.contains { $0.id.contains("bpm") })
    }

    func testGeniusVaultSqliteHasNoAudioOrBPMColumns() throws {
        let catalog = URL(fileURLWithPath: "/Users/samuel/Documents/The Final Journal AI.nosync/tools/bar-hits-catalog/BarHitsCatalog.sqlite")
        try XCTSkipUnless(FileManager.default.fileExists(atPath: catalog.path), "vault sqlite not on disk")
        var db: OpaquePointer?
        guard sqlite3_open_v2(catalog.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK, let db else {
            XCTFail("open vault sqlite")
            return
        }
        defer { sqlite3_close(db) }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, "PRAGMA table_info(bars)", -1, &statement, nil) == SQLITE_OK else {
            XCTFail("pragma")
            return
        }
        defer { sqlite3_finalize(statement) }
        var columns: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            if let ptr = sqlite3_column_text(statement, 1) {
                columns.append(String(cString: ptr))
            }
        }
        XCTAssertEqual(Set(columns), Set(["id", "line", "artist", "song", "syllables", "end_word", "phonetic_class"]))
        XCTAssertFalse(columns.contains("bpm"))
        XCTAssertFalse(columns.contains("key"))
        XCTAssertFalse(columns.contains("scale"))
        XCTAssertFalse(columns.contains("audio"))
        var countStatement: OpaquePointer?
        guard sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM (SELECT DISTINCT artist, song FROM bars WHERE artist != '' AND song != '')", -1, &countStatement, nil) == SQLITE_OK else {
            XCTFail("count songs")
            return
        }
        defer { sqlite3_finalize(countStatement) }
        XCTAssertEqual(sqlite3_step(countStatement), SQLITE_ROW)
        let songCount = sqlite3_column_int(countStatement, 0)
        XCTAssertGreaterThanOrEqual(songCount, 40_940)
    }

    func testCadencePunchRowsFindFlipEvenWhenFullBarIsLongerThanWrap() throws {
        let store = try BarHitsCatalogStore(databaseURL: url)
        let rows = store.cadencePunchRows(
            setupTokens: ["bitch", "dont", "need"],
            syllableMin: 5,
            syllableMax: 8,
            limit: 20,
            setupNorm: "i dont need a bitch"
        )
        XCTAssertTrue(rows.contains { $0.line.localizedCaseInsensitiveContains("what a bitch needs") })
        XCTAssertTrue(rows.contains { $0.artist == "The Weeknd" })
        XCTAssertTrue(rows.contains { $0.id.hasPrefix("cp-") }, "punch book rows, not the 12-syllable full bar")
    }

    func testCadencePunchBookPrefersExactSetupThenFlip() throws {
        let store = try BarHitsCatalogStore(databaseURL: url)
        let rows = store.cadencePunchBookRows(
            lastNoun: "bitch",
            setupNorm: "i dont need a bitch",
            syllableMin: 5,
            syllableMax: 8,
            limit: 8,
            flipsOnly: false
        )
        XCTAssertEqual(rows.first?.artist, "The Weeknd")
        XCTAssertTrue(rows.contains { $0.artist == "Tory Lanez" })
    }

    func testMeaningQueryFindsSharedWordsAcrossSyllableCounts() throws {
        let store = try BarHitsCatalogStore(databaseURL: url)
        let rows = store.meaningCandidates(tokens: ["rhyme", "night"])
        XCTAssertTrue(rows.contains { $0.line.contains("rhyme") && $0.line.contains("night") })
        XCTAssertTrue(rows.contains { $0.syllables != 8 })
    }

    #if os(macOS)
    func testGunzipRoundTrip() throws {
        let raw = Data("hello bar hits catalog".utf8)
        let gz = try Self.gzip(raw)
        let plain = BarHitsCatalogStore.gunzip(gz)
        XCTAssertEqual(plain, raw)
    }
    #endif

    private static func buildFixture(at url: URL) throws {
        var db: OpaquePointer?
        guard sqlite3_open(url.path, &db) == SQLITE_OK, let db else {
            XCTFail("open fixture")
            return
        }
        defer { sqlite3_close(db) }
        let schema = """
        CREATE TABLE bars (
            id TEXT PRIMARY KEY,
            line TEXT NOT NULL,
            artist TEXT,
            song TEXT,
            syllables INTEGER NOT NULL,
            end_word TEXT,
            phonetic_class TEXT
        );
        CREATE INDEX idx_bars_syl ON bars(syllables);
        CREATE INDEX idx_bars_end ON bars(end_word);
        CREATE INDEX idx_bars_class ON bars(phonetic_class);
        CREATE VIRTUAL TABLE bars_fts USING fts5(line, content='bars', content_rowid='rowid');
        """
        guard sqlite3_exec(db, schema, nil, nil, nil) == SQLITE_OK else {
            XCTFail("schema")
            return
        }
        let rows: [(String, String, String, String, Int, String, String)] = [
            ("8", "The city hums in flesh and bone", "Drake", "A", 8, "bone", "OW1 N"),
            ("7", "I left the flesh and bone", "Drake", "A", 7, "bone", "OW1 N"),
            ("10", "Walking through the city in flesh and bone", "Lil Wayne", "A", 10, "bone", "OW1 N"),
            ("6", "Flesh and bone tonight", "Future", "A", 6, "tonight", "AY1 T"),
            ("near", "Hear the speaker tone", "Uzi", "A", 8, "tone", "OW1 N"),
            ("paper", "Unrelated paper line in the city", "Gunna", "A", 8, "city", "IH1 T IY0"),
            ("theme", "I rhyme my way through every night we take", "Gunna", "B", 12, "take", "EY1 K"),
            ("adlib", "Yeah yeah yeah yeah", "Gunna", "C", 4, "yeah", ""),
            ("g-smoke-1", "I blow that pack of smoke", "Gunna", "D", 8, "smoke", "OW1 K"),
            ("g-smoke-2", "Another night of smoke", "Gunna", "D", 7, "smoke", "OW1 K"),
            ("g-smoke-3", "Count a hundred in the smoke", "Gunna", "D", 8, "smoke", "OW1 K"),
            ("g-smoke-4", "Push the coupe through smoke", "Gunna", "D", 7, "smoke", "OW1 K"),
            ("g-smoke-5", "Wunna standing in the smoke", "Gunna", "D", 8, "smoke", "OW1 K"),
            ("g-smoke-6", "Keep a drac in the smoke", "Gunna", "D", 8, "smoke", "OW1 K"),
            ("g-smoke-7", "Pour the four in the smoke", "Gunna", "D", 8, "smoke", "OW1 K"),
            ("g-smoke-8", "Yellow diamonds in the smoke", "Gunna", "D", 8, "smoke", "OW1 K"),
            ("w-smoke", "Tunechi riding through the smoke", "Lil Wayne", "E", 8, "smoke", "OW1 K"),
            ("u-smoke", "Uzi spinning in the smoke", "Lil Uzi Vert", "E", 8, "smoke", "OW1 K"),
            ("d-smoke", "The city humming in the smoke", "Drake", "E", 8, "smoke", "OW1 K"),
            ("weeknd", "I don't need a bitch, I'm what a bitch needs", "The Weeknd", "The Hills", 12, "needs", ""),
            ("tory", "Fuck needin' a bitch, I'm what a bitch need", "Tory Lanez", "Staccato", 10, "need", ""),
        ]
        func q(_ s: String) -> String { s.replacingOccurrences(of: "'", with: "''") }
        for row in rows {
            let sql = "INSERT INTO bars VALUES ('\(q(row.0))','\(q(row.1))','\(q(row.2))','\(q(row.3))',\(row.4),'\(q(row.5))','\(q(row.6))')"
            sqlite3_exec(db, sql, nil, nil, nil)
        }
        sqlite3_exec(db, "INSERT INTO bars_fts(rowid, line) SELECT rowid, line FROM bars;", nil, nil, nil)
        let punches = """
        CREATE TABLE cadence_punches (
            setup TEXT NOT NULL,
            punch TEXT NOT NULL,
            setup_norm TEXT NOT NULL,
            last_noun TEXT NOT NULL,
            punch_syllables INTEGER NOT NULL,
            setup_syllables INTEGER NOT NULL,
            artist TEXT,
            song TEXT,
            punch_has_noun INTEGER NOT NULL DEFAULT 0
        );
        CREATE INDEX idx_cp_setup ON cadence_punches(setup_norm, punch_syllables);
        CREATE INDEX idx_cp_noun_wrap ON cadence_punches(last_noun, punch_syllables, punch_has_noun);
        INSERT INTO cadence_punches VALUES
        ('I don''t need a bitch','I''m what a bitch needs','i dont need a bitch','bitch',6,6,'The Weeknd','The Hills',1),
        ('Fuck needin'' a bitch','I''m what a bitch need','fuck needin a bitch','bitch',6,5,'Tory Lanez','Staccato',1);
        """
        sqlite3_exec(db, punches, nil, nil, nil)
    }

    #if os(macOS)
    private static func gzip(_ data: Data) throws -> Data {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).gz")
        let raw = tmp.deletingPathExtension()
        try data.write(to: raw)
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/gzip")
        proc.arguments = ["-c", raw.path]
        let out = Pipe()
        proc.standardOutput = out
        try proc.run()
        proc.waitUntilExit()
        let gz = out.fileHandleForReading.readDataToEndOfFile()
        try? FileManager.default.removeItem(at: raw)
        XCTAssertFalse(gz.isEmpty)
        return gz
    }
    #endif
}
