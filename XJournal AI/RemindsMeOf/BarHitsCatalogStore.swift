import Compression
import Foundation
import SQLite3

/// Gzipped SQLite of Genius catalog bars. Hold-a-count queries this instead of
/// loading the 557 MB CSV into memory.
nonisolated final class BarHitsCatalogStore: @unchecked Sendable {
    static let filename = "BarHitsCatalog.sqlite"
    static let gzipFilename = "BarHitsCatalog.sqlite.gz"
    /// Versioned so a new vault replaces a stale Application Support copy.
    static let installedName = "BarHitsCatalog-20260916.sqlite"
    private static let lock = NSLock()
    private static var _shared: BarHitsCatalogStore?

    /// Set when `shared` failed to open a populated vault. Shown in Bar Hits empty copy.
    private(set) static var lastLoadError: String?

    static var shared: BarHitsCatalogStore? {
        lock.lock()
        defer { lock.unlock() }
        if _shared == nil {
            do {
                let store = try BarHitsCatalogStore()
                store.cachedBarCount = store.barCount()
                store.cachedArtistCount = store.distinctArtistCount()
                guard store.cachedBarCount > 1_000 else {
                    lastLoadError = "Catalog file opened but has no bars."
                    return nil
                }
                lastLoadError = nil
                _shared = store
            } catch {
                lastLoadError = error.localizedDescription
                _shared = nil
            }
        }
        return _shared
    }

    private let db: OpaquePointer
    /// Cached at open so Bar Hits can show "1.7M bars · 784 artists" without a GROUP BY.
    private(set) var cachedBarCount: Int = 0
    private(set) var cachedArtistCount: Int = 0
    private var punchBookCached: Bool?
    /// `cadence_punches_fts` on a rebuilt catalog, or `temp.cadence_setup_fts` filled once.
    private var punchSetupFtsTable: String?
    private let mentionLock = NSLock()

    init(databaseURL: URL) throws {
        self.db = try Self.openHandle(at: databaseURL)
        sqlite3_busy_timeout(db, 2_000)
        sqlite3_exec(db, "PRAGMA query_only=ON", nil, nil, nil)
    }

    convenience init() throws {
        try self.init(databaseURL: Self.materializeDatabase())
    }

    deinit {
        sqlite3_close(db)
    }

    struct Row: Equatable, Sendable {
        var id: String
        var line: String
        var artist: String?
        var song: String?
        var syllables: Int
        var endWord: String
        var phoneticClass: String

        func candidate() -> RemindsMeOfCandidate {
            RemindsMeOfCandidate(
                id: id,
                line: line,
                artist: artist,
                song: song,
                syllableCount: syllables,
                source: .csv,
                geniusID: nil,
                url: nil
            )
        }
    }

    enum CatalogError: Error, LocalizedError {
        case openFailed(String)
        case missingCatalog
        case gunzipFailed

        var errorDescription: String? {
            switch self {
            case .openFailed(let path): return "Couldn't open catalog at \(path)"
            case .missingCatalog: return "BarHitsCatalog.sqlite.gz is not in this app install"
            case .gunzipFailed: return "Couldn't unpack the catalog gzip"
            }
        }
    }

    /// n-3...n+3 so cadence punches still surface when the gutter is not exact.
    static func wrapWindow(around syllables: Int) -> ClosedRange<Int> {
        max(1, syllables - 3)...(syllables + 3)
    }

    /// Content words from a setup used to find a similar catalog bar.
    /// Drops short glue so "I'm a running back like Vic" → running, back, vic.
    static func setupSearchTokens(_ setup: String) -> [String] {
        let stops: Set<String> = [
            "the", "and", "for", "with", "that", "this", "from", "been", "then", "but",
            "not", "just", "like", "got", "get", "yea", "yeah", "you", "your", "was",
            "are", "its", "his", "her", "they", "them", "our", "she", "him"
        ]
        var seen = Set<String>()
        var out: [String] = []
        for raw in CadenceGhostCache.normalize(setup).split(separator: " ") {
            let tok = String(raw)
            guard tok.count >= 3, !stops.contains(tok), seen.insert(tok).inserted else { continue }
            out.append(tok)
        }
        return out
    }

    static func phoneticClass(for word: String) -> String {
        let key = word.lowercased()
        guard let phones = getGlobalCMUDICTStore()[key], !phones.isEmpty else { return "" }
        var idx = 0
        for (i, phone) in phones.enumerated() where phone.hasSuffix("1") {
            idx = i
        }
        return phones[idx...].joined(separator: " ")
    }

    /// Distinct catalog landings for a rhyme class, popular first. Used by Free Ghost.
    func popularEndWords(phoneticClass: String, limit: Int = 40) -> [String] {
        let klass = phoneticClass.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !klass.isEmpty else { return [] }
        let destressed = klass.filter { !$0.isNumber }
            .lowercased()
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
        let sql = """
        SELECT end_word, COUNT(*) AS n
        FROM bars
        WHERE end_word IS NOT NULL AND end_word != ''
          AND (
                phonetic_class = ?
             OR lower(replace(replace(replace(phonetic_class,'0',''),'1',''),'2','')) = ?
          )
        GROUP BY end_word
        ORDER BY n DESC
        LIMIT ?
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, klass, -1, Self.SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 2, destressed, -1, Self.SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 3, Int32(limit))
        var words: [String] = []
        var seen = Set<String>()
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let raw = Self.string(statement, 0) else { continue }
            let word = raw.lowercased()
            guard word.count >= 2, seen.insert(word).inserted else { continue }
            words.append(word)
        }
        return words
    }

    struct CatalogSong: Sendable, Equatable {
        var artist: String
        var title: String
        var barCount: Int
        /// Same key Catalog MIR persists under in UserDefaults `catalog_mir_batch_v1`.
        var id: String { CatalogMIRBatchService.songRecordKey(artist: artist, title: title) }
    }

    /// Unique catalog tracks for MIR batching.
    /// Sqlite is lyrics-only (no audio/BPM/key/scale columns). Numeric MIR is null
    /// unless CatalogMIRBatchService finds local audio. Style tags still enrich from lyrics.
    /// Bar hits reads those records via `CatalogMIRBatchService.mir(song:artist:)` using `id`.
    func catalogSongs(limit: Int = 4000) -> [CatalogSong] {
        let sql = """
        SELECT artist, song, COUNT(*) AS n
        FROM bars
        WHERE artist IS NOT NULL AND artist != ''
          AND song IS NOT NULL AND song != ''
        GROUP BY artist, song
        ORDER BY n DESC
        LIMIT ?
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_int(statement, 1, Int32(limit))
        var songs: [CatalogSong] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let artist = Self.string(statement, 0),
                  let title = Self.string(statement, 1) else { continue }
            songs.append(CatalogSong(artist: artist, title: title, barCount: Int(sqlite3_column_int(statement, 2))))
        }
        return songs
    }

    func lyrics(artist: String, song: String, limit: Int = 32) -> String {
        let sql = """
        SELECT line FROM bars
        WHERE artist = ? AND song = ?
        ORDER BY rowid
        LIMIT ?
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return ""
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, artist, -1, Self.SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 2, song, -1, Self.SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 3, Int32(limit))
        var lines: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            if let line = Self.string(statement, 0) { lines.append(line) }
        }
        return lines.joined(separator: "\n")
    }

    func distinctArtistCount() -> Int {
        let sql = "SELECT COUNT(DISTINCT artist) FROM bars WHERE artist IS NOT NULL AND artist != ''"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return 0
        }
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int(statement, 0))
    }

    var summaryLine: String {
        let bars = cachedBarCount > 0 ? cachedBarCount : barCount()
        let artists = cachedArtistCount > 0 ? cachedArtistCount : distinctArtistCount()
        return "\(bars.formatted()) bars · \(artists.formatted()) artists"
    }

    func barCount() -> Int {
        let sql = "SELECT COUNT(*) FROM bars"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return 0
        }
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int(statement, 0))
    }

    func artistNames() -> [String] {
        let sql = "SELECT artist, COUNT(*) AS n FROM bars WHERE artist IS NOT NULL AND artist != '' GROUP BY artist ORDER BY n DESC"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }
        var names: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            if let name = Self.string(statement, 0) { names.append(name) }
        }
        return names
    }

    func wrapCandidates(
        syllableMin: Int,
        syllableMax: Int,
        endWord: String,
        phoneticClass: String,
        nearWords: [String],
        artists: [String] = [],
        limit: Int = 160
    ) -> [Row] {
        let end = endWord.lowercased()
        let klass = phoneticClass.trimmingCharacters(in: .whitespaces)
        let near = Array(Set(nearWords.map { $0.lowercased() }.filter { !$0.isEmpty && $0 != end })).prefix(40)
        let picked = Array(Set(artists.filter { !$0.isEmpty })).prefix(80)
        var sql = """
        SELECT id, line, artist, song, syllables, end_word, phonetic_class
        FROM bars
        WHERE syllables BETWEEN ? AND ?
          AND (
                end_word = ?
        """
        if !klass.isEmpty {
            sql += " OR phonetic_class = ?"
        }
        if !near.isEmpty {
            sql += " OR end_word IN (" + Array(repeating: "?", count: near.count).joined(separator: ",") + ")"
        }
        sql += ")"
        if !picked.isEmpty {
            sql += " AND artist IN (" + Array(repeating: "?", count: picked.count).joined(separator: ",") + ")"
        }
        // Exact end-word first, then by artist so Gunna-first CSV rowid doesn't hide Wayne / Uzi / Drake.
        sql += " ORDER BY CASE WHEN end_word = ? THEN 0"
        if !klass.isEmpty {
            sql += " WHEN phonetic_class = ? THEN 1"
        }
        sql += " ELSE 2 END, artist COLLATE NOCASE LIMIT ?"

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }

        var bind = 1
        sqlite3_bind_int(statement, Int32(bind), Int32(syllableMin)); bind += 1
        sqlite3_bind_int(statement, Int32(bind), Int32(syllableMax)); bind += 1
        sqlite3_bind_text(statement, Int32(bind), end, -1, Self.SQLITE_TRANSIENT); bind += 1
        if !klass.isEmpty {
            sqlite3_bind_text(statement, Int32(bind), klass, -1, Self.SQLITE_TRANSIENT); bind += 1
        }
        for word in near {
            sqlite3_bind_text(statement, Int32(bind), word, -1, Self.SQLITE_TRANSIENT); bind += 1
        }
        for name in picked {
            sqlite3_bind_text(statement, Int32(bind), name, -1, Self.SQLITE_TRANSIENT); bind += 1
        }
        sqlite3_bind_text(statement, Int32(bind), end, -1, Self.SQLITE_TRANSIENT); bind += 1
        if !klass.isEmpty {
            sqlite3_bind_text(statement, Int32(bind), klass, -1, Self.SQLITE_TRANSIENT); bind += 1
        }
        sqlite3_bind_int(statement, Int32(bind), Int32(limit))
        return Self.readRows(statement)
    }

    /// Similar setups across the punch book and full bars. Prefers comma bars so
    /// the engine can hand back only the after-comma punch.
    func wholeSetupCadenceRows(
        setup: String,
        syllableMin: Int,
        syllableMax: Int,
        limit: Int = 48
    ) -> [Row] {
        let tokens = Self.setupSearchTokens(setup)
        let windowMin = max(1, syllableMin)
        let windowMax = max(windowMin, syllableMax)
        let setupNorm = CadenceGhostCache.normalize(setup)
        var rows: [Row] = []
        var seen = Set<String>()
        func take(_ extra: [Row], commaOnly: Bool) {
            for row in extra {
                if commaOnly, !row.line.contains(",") { continue }
                let key = row.line.lowercased()
                guard seen.insert(key).inserted else { continue }
                rows.append(row)
                if rows.count >= limit { return }
            }
        }
        let lastNoun = tokens.last ?? ""
        // Whole setup first. Last-noun dump used to fill the limit with every
        // "Vic" punch before "running back" could run.
        if hasPunchBook, tokens.count >= 2 {
            take(
                cadencePunchBookSetupTokenRows(
                    tokens: tokens,
                    syllableMin: 1,
                    syllableMax: 16,
                    limit: limit
                ),
                commaOnly: false
            )
        }
        if tokens.count >= 2, rows.count < limit {
            let andMatch = tokens.prefix(3).map { "\"\($0)\"" }.joined(separator: " AND ")
            let hits = ftsCadenceRows(match: andMatch, limit: limit * 2)
            let comma = hits.filter { $0.line.contains(",") }
            take(comma.isEmpty ? hits : comma, commaOnly: false)
        }
        if tokens.count >= 2, rows.count < 8 {
            let and2 = tokens.prefix(2).map { "\"\($0)\"" }.joined(separator: " AND ")
            take(ftsCadenceRows(match: and2, limit: limit).filter { $0.line.contains(",") }, commaOnly: false)
        }
        if hasPunchBook, !lastNoun.isEmpty, rows.count < 8 {
            take(
                cadencePunchBookRows(
                    lastNoun: lastNoun,
                    setupNorm: setupNorm,
                    syllableMin: windowMin,
                    syllableMax: windowMax,
                    limit: limit,
                    flipsOnly: false
                ),
                commaOnly: false
            )
        }
        return rows
    }

    /// Punch-book setups that contain each setup token (whole setup, not last noun only).
    func cadencePunchBookSetupTokenRows(
        tokens: [String],
        syllableMin: Int,
        syllableMax: Int,
        limit: Int
    ) -> [Row] {
        let terms = Array(tokens.prefix(4)).filter { $0.count >= 3 }
        guard hasPunchBook, terms.count >= 2 else { return [] }
        if let ftsRows = punchSetupFtsRows(terms: terms, limit: limit), !ftsRows.isEmpty {
            return ftsRows
        }
        var sql = """
        SELECT punch, punch_syllables, artist, song, punch, last_noun
        FROM cadence_punches
        WHERE punch_syllables BETWEEN ? AND ?
        """
        for _ in terms {
            sql += " AND setup_norm LIKE ?"
        }
        sql += " LIMIT ?"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }
        var i: Int32 = 1
        sqlite3_bind_int(statement, i, Int32(syllableMin)); i += 1
        sqlite3_bind_int(statement, i, Int32(syllableMax)); i += 1
        for term in terms {
            let pattern = "%\(term)%"
            sqlite3_bind_text(statement, i, pattern, -1, Self.SQLITE_TRANSIENT); i += 1
        }
        sqlite3_bind_int(statement, i, Int32(limit))
        return readPunchBook(statement)
    }

    private func punchSetupFtsRows(terms: [String], limit: Int) -> [Row]? {
        guard let table = ensurePunchSetupFts() else { return nil }
        let match = terms.prefix(3).map { "\"\($0)\"" }.joined(separator: " AND ")
        let sql: String
        if table == "cadence_punches_fts" {
            sql = """
            SELECT p.punch, p.punch_syllables, p.artist, p.song, p.punch, p.last_noun
            FROM cadence_punches p
            JOIN cadence_punches_fts f ON p.rowid = f.rowid
            WHERE f MATCH ?
            LIMIT ?
            """
        } else {
            sql = """
            SELECT punch, punch_syllables, artist, song, punch, ''
            FROM cadence_setup_fts
            WHERE cadence_setup_fts MATCH ?
            LIMIT ?
            """
        }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return nil
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, match, -1, Self.SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 2, Int32(limit))
        return readPunchBook(statement)
    }

    /// Shipped catalogs may not have setup FTS yet. Build a temp one once from the punch book.
    private func ensurePunchSetupFts() -> String? {
        if let cached = punchSetupFtsTable { return cached.isEmpty ? nil : cached }
        if tableExists("cadence_punches_fts") {
            punchSetupFtsTable = "cadence_punches_fts"
            return punchSetupFtsTable
        }
        guard hasPunchBook else {
            punchSetupFtsTable = ""
            return nil
        }
        let create = """
        CREATE VIRTUAL TABLE IF NOT EXISTS temp.cadence_setup_fts USING fts5(
            setup_norm, punch, artist, song, punch_syllables UNINDEXED
        );
        """
        guard sqlite3_exec(db, create, nil, nil, nil) == SQLITE_OK else {
            punchSetupFtsTable = ""
            return nil
        }
        var countStmt: OpaquePointer?
        var empty = true
        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM temp.cadence_setup_fts", -1, &countStmt, nil) == SQLITE_OK,
           let countStmt {
            defer { sqlite3_finalize(countStmt) }
            if sqlite3_step(countStmt) == SQLITE_ROW {
                empty = sqlite3_column_int(countStmt, 0) == 0
            }
        }
        if empty {
            let insert = """
            INSERT INTO temp.cadence_setup_fts(setup_norm, punch, artist, song, punch_syllables)
            SELECT setup_norm, punch, IFNULL(artist,''), IFNULL(song,''), punch_syllables
            FROM cadence_punches;
            """
            guard sqlite3_exec(db, insert, nil, nil, nil) == SQLITE_OK else {
                punchSetupFtsTable = ""
                return nil
            }
        }
        punchSetupFtsTable = "temp.cadence_setup_fts"
        return punchSetupFtsTable
    }

    private func tableExists(_ name: String) -> Bool {
        let sql = "SELECT 1 FROM sqlite_master WHERE type='table' AND name = ? LIMIT 1"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return false
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, name, -1, Self.SQLITE_TRANSIENT)
        return sqlite3_step(statement) == SQLITE_ROW
    }

    /// Bars that share setup tokens. Punch book first (pre-cut caesuras), FTS only if the book is thin.
    func cadencePunchRows(
        setupTokens: [String],
        syllableMin: Int,
        syllableMax: Int,
        limit: Int = 48,
        setupNorm: String = ""
    ) -> [Row] {
        let terms = setupTokens
            .map { $0.lowercased().filter { $0.isLetter || $0.isNumber } }
            .filter { $0.count >= 3 }
        let windowMin = max(1, syllableMin)
        let windowMax = max(windowMin, syllableMax)
        if terms.isEmpty {
            return []
        }
        let lastNoun = terms[0]
        var rows: [Row] = []
        var seen = Set<String>()
        func take(_ extra: [Row]) {
            for row in extra {
                let key = row.line.lowercased()
                guard seen.insert(key).inserted else { continue }
                rows.append(row)
                if rows.count >= limit { return }
            }
        }
        if hasPunchBook {
            take(cadencePunchBookRows(
                lastNoun: lastNoun,
                setupNorm: setupNorm,
                syllableMin: windowMin,
                syllableMax: windowMax,
                limit: limit,
                flipsOnly: false
            ))
            if rows.count < 8 {
                take(cadencePunchBookRows(
                    lastNoun: lastNoun,
                    setupNorm: setupNorm,
                    syllableMin: 1,
                    syllableMax: 16,
                    limit: limit,
                    flipsOnly: false
                ))
            }
        }
        if rows.count >= max(8, limit / 3) { return rows }
        let rest = Array(terms.dropFirst().prefix(5))
        var match = "\"\(lastNoun)\""
        if !rest.isEmpty {
            match += " AND (" + rest.map { "\"\($0)\"" }.joined(separator: " OR ") + ")"
        }
        take(ftsCadenceRows(match: match, limit: limit))
        if rows.count < max(8, limit / 4) {
            take(ftsCadenceRows(match: "\"\(lastNoun)\"", limit: limit))
        }
        return rows
    }

    private var hasPunchBook: Bool {
        if let cached = punchBookCached { return cached }
        var statement: OpaquePointer?
        let sql = "SELECT 1 FROM sqlite_master WHERE type='table' AND name='cadence_punches' LIMIT 1"
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            punchBookCached = false
            return false
        }
        defer { sqlite3_finalize(statement) }
        let ready = sqlite3_step(statement) == SQLITE_ROW
        punchBookCached = ready
        return ready
    }

    /// Pre-cut setup→punch rows. Exact setup first, then noun-in-punch flips, then same last noun.
    func cadencePunchBookRows(
        lastNoun: String,
        setupNorm: String,
        syllableMin: Int,
        syllableMax: Int,
        limit: Int,
        flipsOnly: Bool
    ) -> [Row] {
        let noun = lastNoun.lowercased().filter { $0.isLetter || $0.isNumber }
        guard !noun.isEmpty else { return [] }
        var out: [Row] = []
        var seen = Set<String>()
        func run(_ sql: String, bindSetup: Bool, bindFlip: Bool) {
            guard out.count < limit else { return }
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else { return }
            defer { sqlite3_finalize(statement) }
            var i: Int32 = 1
            sqlite3_bind_int(statement, i, Int32(syllableMin)); i += 1
            sqlite3_bind_int(statement, i, Int32(syllableMax)); i += 1
            sqlite3_bind_text(statement, i, noun, -1, Self.SQLITE_TRANSIENT); i += 1
            if bindSetup {
                sqlite3_bind_text(statement, i, setupNorm, -1, Self.SQLITE_TRANSIENT); i += 1
            }
            if bindFlip {
                sqlite3_bind_int(statement, i, 1); i += 1
            }
            sqlite3_bind_int(statement, i, Int32(limit))
            for row in readPunchBook(statement) {
                let key = row.line.lowercased()
                guard seen.insert(key).inserted else { continue }
                out.append(row)
                if out.count >= limit { return }
            }
        }
        let select = """
        SELECT punch, punch_syllables, artist, song, punch, last_noun
        FROM cadence_punches
        WHERE punch_syllables BETWEEN ? AND ?
          AND last_noun = ?
        """
        if !setupNorm.isEmpty {
            run(select + " AND setup_norm = ? ORDER BY punch_has_noun DESC LIMIT ?", bindSetup: true, bindFlip: false)
        }
        run(select + " AND punch_has_noun = ? ORDER BY punch_syllables LIMIT ?", bindSetup: false, bindFlip: true)
        if !flipsOnly {
            run(select + " ORDER BY punch_has_noun DESC, punch_syllables LIMIT ?", bindSetup: false, bindFlip: false)
        }
        return out
    }

    private func readPunchBook(_ statement: OpaquePointer) -> [Row] {
        var rows: [Row] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let punch = Self.string(statement, 0) ?? ""
            guard !punch.isEmpty else { continue }
            let end = punch.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
                .last ?? ""
            rows.append(
                Row(
                    id: "cp-\(punch.hashValue)",
                    line: punch,
                    artist: Self.string(statement, 2),
                    song: Self.string(statement, 3),
                    syllables: Int(sqlite3_column_int(statement, 1)),
                    endWord: end,
                    phoneticClass: ""
                )
            )
        }
        return rows
    }

    private func ftsCadenceRows(match: String, limit: Int) -> [Row] {
        let sql = """
        SELECT bars.id, bars.line, bars.artist, bars.song, bars.syllables, bars.end_word, bars.phonetic_class
        FROM bars
        JOIN bars_fts ON bars.rowid = bars_fts.rowid
        WHERE bars_fts MATCH ?
        ORDER BY bm25(bars_fts)
        LIMIT ?
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, match, -1, Self.SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 2, Int32(limit))
        return Self.readRows(statement)
    }

    /// FTS phrase query for a noun and its other names. `also` keeps a line only
    /// when it also says the partner half. `excluding` drops lines that share a
    /// word but name somebody else (`wayne` without `john wayne`).
    /// Nil when nothing is searchable.
    nonisolated static func mentionMatch(
        phrases: [String],
        excluding: [String] = [],
        also: [String] = []
    ) -> String? {
        guard let included = joinedPhraseQuery(phrases) else { return nil }
        let query: String
        if let partner = joinedPhraseQuery(also) {
            query = "(\(included)) AND (\(partner))"
        } else {
            query = included
        }
        guard let excluded = joinedPhraseQuery(excluding) else { return query }
        return "(\(query)) NOT (\(excluded))"
    }

    private nonisolated static func joinedPhraseQuery(_ phrases: [String]) -> String? {
        var seen = Set<String>()
        var parts: [String] = []
        let ranked = phrases.sorted { lhs, rhs in
            let left = lhs.split(separator: " ").count
            let right = rhs.split(separator: " ").count
            if left != right { return left > right }
            return lhs.count > rhs.count
        }
        for raw in ranked {
            let folded = raw
                .folding(options: .diacriticInsensitive, locale: Locale(identifier: "en_US"))
                .lowercased()
                .replacingOccurrences(of: "\"", with: " ")
            var token = ""
            var tokens: [String] = []
            for scalar in folded.unicodeScalars {
                if CharacterSet.alphanumerics.contains(scalar) || scalar == "'" || scalar == "’" {
                    token.unicodeScalars.append(scalar)
                } else if !token.isEmpty {
                    tokens.append(token)
                    token = ""
                }
            }
            if !token.isEmpty { tokens.append(token) }
            guard !tokens.isEmpty else { continue }
            var forms = [tokens.joined(separator: " ")]
            let squeezed = tokens.map { $0.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "’", with: "") }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            if !squeezed.isEmpty, squeezed != forms[0] { forms.append(squeezed) }
            for phrase in forms where phrase.count >= 2 && seen.insert(phrase).inserted {
                parts.append("\"\(phrase)\"")
                if parts.count >= 12 { return parts.joined(separator: " OR ") }
            }
        }
        guard !parts.isEmpty else { return nil }
        return parts.joined(separator: " OR ")
    }

    func mentionCount(phrases: [String], excluding: [String] = [], also: [String] = []) -> Int {
        mentionLock.lock()
        defer { mentionLock.unlock() }
        guard let match = Self.mentionMatch(phrases: phrases, excluding: excluding, also: also) else { return 0 }
        let sql = "SELECT count(*) FROM bars_fts WHERE bars_fts MATCH ?"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return 0
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, match, -1, Self.SQLITE_TRANSIENT)
        guard sqlite3_step(statement) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int(statement, 0))
    }

    struct MentionStats: Equatable, Sendable {
        var hits: Int
        var artists: Int
        var songs: Int
    }

    /// One unbounded pass: line count, distinct artists, distinct songs. Not the capped line list.
    func mentionStats(phrases: [String], excluding: [String] = [], also: [String] = []) -> MentionStats {
        mentionLock.lock()
        defer { mentionLock.unlock() }
        guard let match = Self.mentionMatch(phrases: phrases, excluding: excluding, also: also) else {
            return MentionStats(hits: 0, artists: 0, songs: 0)
        }
        let sql = """
        SELECT COUNT(*), COUNT(DISTINCT bars.artist), COUNT(DISTINCT bars.song)
        FROM bars
        JOIN bars_fts ON bars.rowid = bars_fts.rowid
        WHERE bars_fts MATCH ?
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return MentionStats(hits: 0, artists: 0, songs: 0)
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, match, -1, Self.SQLITE_TRANSIENT)
        guard sqlite3_step(statement) == SQLITE_ROW else {
            return MentionStats(hits: 0, artists: 0, songs: 0)
        }
        return MentionStats(
            hits: Int(sqlite3_column_int64(statement, 0)),
            artists: Int(sqlite3_column_int64(statement, 1)),
            songs: Int(sqlite3_column_int64(statement, 2))
        )
    }

    func mentionLines(phrases: [String], excluding: [String] = [], also: [String] = [], limit: Int = 60) -> [Row] {
        mentionLock.lock()
        defer { mentionLock.unlock() }
        guard let match = Self.mentionMatch(phrases: phrases, excluding: excluding, also: also) else { return [] }
        let sql = """
        SELECT bars.id, bars.line, bars.artist, bars.song, bars.syllables, bars.end_word, bars.phonetic_class
        FROM bars
        JOIN bars_fts ON bars.rowid = bars_fts.rowid
        WHERE bars_fts MATCH ?
        ORDER BY bars.artist COLLATE NOCASE, bars.song COLLATE NOCASE, bars.line COLLATE NOCASE
        LIMIT ?
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, match, -1, Self.SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 2, Int32(limit))
        return Self.readRows(statement)
    }

    func meaningCandidates(tokens: [String], artists: [String] = [], limit: Int = 40) -> [Row] {
        let terms = tokens
            .map { $0.lowercased().filter { $0.isLetter || $0.isNumber } }
            .filter { $0.count >= 3 }
        guard !terms.isEmpty else { return [] }
        let match = terms.prefix(8).map { "\"\($0)\"" }.joined(separator: " OR ")
        let picked = Array(Set(artists.filter { !$0.isEmpty })).prefix(80)
        var sql = """
        SELECT bars.id, bars.line, bars.artist, bars.song, bars.syllables, bars.end_word, bars.phonetic_class
        FROM bars
        JOIN bars_fts ON bars.rowid = bars_fts.rowid
        WHERE bars_fts MATCH ?
        """
        if !picked.isEmpty {
            sql += " AND bars.artist IN (" + Array(repeating: "?", count: picked.count).joined(separator: ",") + ")"
        }
        sql += " ORDER BY bars.artist COLLATE NOCASE LIMIT ?"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }
        var bind = 1
        sqlite3_bind_text(statement, Int32(bind), match, -1, Self.SQLITE_TRANSIENT); bind += 1
        for name in picked {
            sqlite3_bind_text(statement, Int32(bind), name, -1, Self.SQLITE_TRANSIENT); bind += 1
        }
        sqlite3_bind_int(statement, Int32(bind), Int32(limit))
        return Self.readRows(statement)
    }

    private static let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    private static func readRows(_ statement: OpaquePointer) -> [Row] {
        var rows: [Row] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            rows.append(
                Row(
                    id: string(statement, 0) ?? "",
                    line: string(statement, 1) ?? "",
                    artist: string(statement, 2),
                    song: string(statement, 3),
                    syllables: Int(sqlite3_column_int(statement, 4)),
                    endWord: string(statement, 5) ?? "",
                    phoneticClass: string(statement, 6) ?? ""
                )
            )
        }
        return rows.filter { !$0.id.isEmpty && !$0.line.isEmpty }
    }

    private static func string(_ statement: OpaquePointer, _ index: Int32) -> String? {
        guard let ptr = sqlite3_column_text(statement, index) else { return nil }
        let text = String(cString: ptr)
        return text.isEmpty ? nil : text
    }


    /// All bars for one song (ordered by trailing line number in id when present).
    func bars(forSong song: String, artist: String? = nil, limit: Int = 400) -> [Row] {
        let title = song.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return [] }
        var sql = """
        SELECT id, line, artist, song, syllables, end_word, phonetic_class
        FROM bars
        WHERE song = ?
        """
        if let artist, !artist.isEmpty {
            sql += " AND artist = ?"
        }
        sql += " ORDER BY rowid LIMIT ?"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }
        var bind = 1
        sqlite3_bind_text(statement, Int32(bind), title, -1, Self.SQLITE_TRANSIENT); bind += 1
        if let artist, !artist.isEmpty {
            sqlite3_bind_text(statement, Int32(bind), artist, -1, Self.SQLITE_TRANSIENT); bind += 1
        }
        sqlite3_bind_int(statement, Int32(bind), Int32(limit))
        let rows = Self.readRows(statement)
        let numbered = rows.compactMap { row -> (Int, BarHitsCatalogStore.Row)? in
            guard let n = SimilarMeaningPipeline.parseCatalogId(row.id)?.line else { return nil }
            return (n, row)
        }
        if numbered.count == rows.count, !numbered.isEmpty {
            return numbered.sorted { $0.0 < $1.0 }.map(\.1)
        }
        return rows
    }

    /// Sample end-word rows across artists for Free Ghost index rebuilds.
    func sampleEndWordRows(perArtist: Int = 80, artistLimit: Int = 80) -> [Row] {
        var out: [Row] = []
        var seen = Set<String>()
        for artist in Array(artistNames().prefix(artistLimit)) {
            let sql = """
            SELECT id, line, artist, song, syllables, end_word, phonetic_class
            FROM bars
            WHERE artist = ? AND end_word IS NOT NULL AND end_word != ''
            LIMIT ?
            """
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
                continue
            }
            defer { sqlite3_finalize(statement) }
            sqlite3_bind_text(statement, 1, artist, -1, Self.SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 2, Int32(perArtist))
            for row in Self.readRows(statement) {
                let key = "\(row.phoneticClass)|\(row.endWord.lowercased())|\(artist)"
                guard seen.insert(key).inserted else { continue }
                out.append(row)
            }
        }
        return out
    }

    static func materializeDatabase(
        fileManager: FileManager = .default,
        bundle: Bundle = .main
    ) throws -> URL {
        let destDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        try fileManager.createDirectory(at: destDir, withIntermediateDirectories: true)
        let dest = destDir.appendingPathComponent(installedName)
        if fileSize(at: dest, fileManager: fileManager) > 1_000_000,
           isPopulatedDatabase(at: dest) {
            return dest
        }

        if let gz = bundledGzipURL(bundle: bundle, fileManager: fileManager) {
            try unpackGzip(gz, to: dest, fileManager: fileManager)
            return dest
        }

        let catalogDirs = [
            URL(fileURLWithPath: "/Users/samuel/Documents/The Final Journal AI.nosync/tools/bar-hits-catalog"),
            URL(fileURLWithPath: "/Users/samuel/Documents/The Final Journal AI/tools/bar-hits-catalog"),
            URL(fileURLWithPath: "/Users/samuel/Desktop/pennworkstudios.nosync/tools/bar-hits-catalog"),
            URL(fileURLWithPath: "/Users/samuel/Desktop/pennworkstudios/tools/bar-hits-catalog"),
            URL(fileURLWithPath: "/Users/samuel/Documents/The Final Journal AI.nosync/XJournal AI/RemindsMeOf"),
            URL(fileURLWithPath: "/Users/samuel/Documents/The Final Journal AI/XJournal AI/RemindsMeOf")
        ]
        for project in catalogDirs {
            let localSQLite = project.appendingPathComponent(filename)
            if fileManager.fileExists(atPath: localSQLite.path),
               isPopulatedDatabase(at: localSQLite) {
                // Open in place — do not copy 400 MB into Application Support.
                return localSQLite
            }
            let localGZ = project.appendingPathComponent(gzipFilename)
            if fileManager.fileExists(atPath: localGZ.path) {
                try unpackGzip(localGZ, to: dest, fileManager: fileManager)
                return dest
            }
        }
        throw CatalogError.missingCatalog
    }

    /// WAL catalogs need a writable open so SQLite can recreate missing -shm files
    /// after a gzip unpack. query_only is applied by `init` after that.
    private static func openHandle(at url: URL) throws -> OpaquePointer {
        var handle: OpaquePointer?
        let readonly = SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX
        if sqlite3_open_v2(url.path, &handle, readonly, nil) == SQLITE_OK, let handle {
            return handle
        }
        if let handle { sqlite3_close(handle) }
        handle = nil
        let readwrite = SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(url.path, &handle, readwrite, nil) == SQLITE_OK, let handle else {
            if let handle { sqlite3_close(handle) }
            throw CatalogError.openFailed(url.path)
        }
        sqlite3_exec(handle, "PRAGMA journal_mode=DELETE", nil, nil, nil)
        sqlite3_exec(handle, "PRAGMA wal_checkpoint(TRUNCATE)", nil, nil, nil)
        return handle
    }

    private static func bundledGzipURL(bundle: Bundle, fileManager: FileManager) -> URL? {
        let candidates: [URL?] = [
            bundle.bundleURL.appendingPathComponent(gzipFilename),
            bundle.resourceURL?.appendingPathComponent(gzipFilename),
            bundle.url(forResource: "BarHitsCatalog.sqlite", withExtension: "gz"),
            bundle.url(forResource: "BarHitsCatalog", withExtension: "sqlite.gz"),
            bundle.url(forResource: "BarHitsCatalog.sqlite", withExtension: "gz", subdirectory: "RemindsMeOf"),
            bundle.url(forResource: "BarHitsCatalog", withExtension: "sqlite.gz", subdirectory: "RemindsMeOf")
        ]
        return candidates.compactMap { $0 }.first { fileManager.fileExists(atPath: $0.path) }
    }

    private static func unpackGzip(_ gz: URL, to dest: URL, fileManager: FileManager) throws {
        let tmp = dest.appendingPathExtension("part")
        if fileManager.fileExists(atPath: tmp.path) {
            try fileManager.removeItem(at: tmp)
        }
        try gunzip(from: gz, to: tmp)
        guard isPopulatedDatabase(at: tmp) else {
            try? fileManager.removeItem(at: tmp)
            throw CatalogError.gunzipFailed
        }
        if fileManager.fileExists(atPath: dest.path) {
            try fileManager.removeItem(at: dest)
        }
        try fileManager.moveItem(at: tmp, to: dest)
    }

    private static func fileSize(at url: URL, fileManager: FileManager) -> Int {
        let attrs = try? fileManager.attributesOfItem(atPath: url.path)
        return (attrs?[.size] as? NSNumber)?.intValue ?? 0
    }

    /// True when the file is a real vault, not a stub/corrupt Application Support copy.
    private static func isPopulatedDatabase(at url: URL) -> Bool {
        guard let handle = try? openHandle(at: url) else { return false }
        defer { sqlite3_close(handle) }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, "SELECT 1 FROM bars LIMIT 1", -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return false
        }
        defer { sqlite3_finalize(statement) }
        return sqlite3_step(statement) == SQLITE_ROW
    }

    /// File-to-file gzip so a 188 MB vault does not allocate a 1.5 GB decode buffer.
    static func gunzip(from src: URL, to dest: URL) throws {
        let data = try Data(contentsOf: src, options: [.mappedIfSafe])
        guard let range = gzipDeflateRange(data) else { throw CatalogError.gunzipFailed }
        FileManager.default.createFile(atPath: dest.path, contents: nil)
        let out = try FileHandle(forWritingTo: dest)
        defer { try? out.close() }

        let dstScratch = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        let srcScratch = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        defer {
            dstScratch.deallocate()
            srcScratch.deallocate()
        }
        var stream = compression_stream(
            dst_ptr: dstScratch,
            dst_size: 0,
            src_ptr: UnsafePointer(srcScratch),
            src_size: 0,
            state: nil
        )
        var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
        guard status != COMPRESSION_STATUS_ERROR else { throw CatalogError.gunzipFailed }
        defer { compression_stream_destroy(&stream) }

        try data.withUnsafeBytes { raw in
            guard let base = raw.bindMemory(to: UInt8.self).baseAddress else {
                throw CatalogError.gunzipFailed
            }
            stream.src_ptr = base + range.lowerBound
            stream.src_size = range.count
            var buf = [UInt8](repeating: 0, count: 64 * 1024)
            while true {
                let produced: Int = buf.withUnsafeMutableBufferPointer { destBuf in
                    guard let dst = destBuf.baseAddress else { return 0 }
                    stream.dst_ptr = dst
                    stream.dst_size = destBuf.count
                    status = compression_stream_process(&stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))
                    return destBuf.count - stream.dst_size
                }
                if produced > 0 {
                    out.write(Data(buf[0..<produced]))
                }
                if status == COMPRESSION_STATUS_END { break }
                if status == COMPRESSION_STATUS_ERROR { throw CatalogError.gunzipFailed }
            }
        }
    }

    /// Standard gzip (Python gzip.open) → raw DEFLATE via Compression.
    static func gunzip(_ data: Data) -> Data? {
        guard let range = gzipDeflateRange(data) else { return nil }
        let deflate = data.subdata(in: range)
        let cap = max(deflate.count * 8, 1_000_000)
        return deflate.withUnsafeBytes { src -> Data? in
            guard let base = src.bindMemory(to: UInt8.self).baseAddress else { return nil }
            let dst = UnsafeMutablePointer<UInt8>.allocate(capacity: cap)
            defer { dst.deallocate() }
            let written = compression_decode_buffer(dst, cap, base, deflate.count, nil, COMPRESSION_ZLIB)
            guard written > 0, written < cap else { return nil }
            return Data(bytes: dst, count: written)
        }
    }

    private static func gzipDeflateRange(_ data: Data) -> Range<Int>? {
        guard data.count > 18, data[0] == 0x1f, data[1] == 0x8b else { return nil }
        var offset = 10
        let flags = data[3]
        if flags & 0x04 != 0 {
            guard offset + 2 <= data.count else { return nil }
            let extra = Int(data[offset]) | (Int(data[offset + 1]) << 8)
            offset += 2 + extra
        }
        if flags & 0x08 != 0 {
            while offset < data.count, data[offset] != 0 { offset += 1 }
            offset += 1
        }
        if flags & 0x10 != 0 {
            while offset < data.count, data[offset] != 0 { offset += 1 }
            offset += 1
        }
        if flags & 0x02 != 0 { offset += 2 }
        guard offset + 8 < data.count else { return nil }
        return offset..<(data.count - 8)
    }
}
