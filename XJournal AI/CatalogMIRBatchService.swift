import Foundation
import Combine

/// Batch MIR for catalog tracks that have audio. Lyrics-only stays null — never invent BPM/key.
///
/// Persistent per-song records live in UserDefaults `userDefaultsStorageKey`
/// (`catalog_mir_batch_v1`). Vault songs are keyed `songRecordKey` → `"artist|title"`.
/// Bar hits reads that map via `mir(song:artist:)`. The Genius sqlite vault has no
/// audio/BPM/key/scale columns, so those fields stay null unless a claimed Model You
/// track has local audio.
@MainActor
final class CatalogMIRBatchService: ObservableObject {
    static let shared = CatalogMIRBatchService()

    /// UserDefaults key for `[songRecordKey: SongMIR]`. Bar hits can read this map.
    nonisolated static let userDefaultsStorageKey = "catalog_mir_batch_v1"

    /// Covers the 70-artist Genius vault (~40,940 unique artist|song rows; 42,560 in the full sqlite).
    nonisolated static let fullVaultSongLimit = 50_000

    /// Catalog / Bar hits lookup key. Must match `BarHitsCatalogStore.CatalogSong.id`.
    nonisolated static func songRecordKey(artist: String, title: String) -> String {
        "\(artist)|\(title)"
    }

    struct SongMIR: Codable, Equatable, Sendable {
        var bpm: Int?
        var key: String?
        var scale: String?
        var styleTags: [String]
        var styleTagConfidence: Double
        var analyzedAt: Date?
        var hadAudio: Bool

        enum CodingKeys: String, CodingKey {
            case bpm, key, scale, styleTags, styleTagConfidence, analyzedAt, hadAudio
        }

        init(bpm: Int?, key: String?, scale: String?, styleTags: [String], styleTagConfidence: Double, analyzedAt: Date?, hadAudio: Bool) {
            self.bpm = bpm
            self.key = key
            self.scale = scale
            self.styleTags = styleTags
            self.styleTagConfidence = styleTagConfidence
            self.analyzedAt = analyzedAt
            self.hadAudio = hadAudio
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            bpm = try c.decodeIfPresent(Int.self, forKey: .bpm)
            key = try c.decodeIfPresent(String.self, forKey: .key)
            scale = try c.decodeIfPresent(String.self, forKey: .scale)
            styleTags = try c.decodeIfPresent([String].self, forKey: .styleTags) ?? []
            styleTagConfidence = try c.decodeIfPresent(Double.self, forKey: .styleTagConfidence) ?? 0
            analyzedAt = try c.decodeIfPresent(Date.self, forKey: .analyzedAt)
            hadAudio = try c.decodeIfPresent(Bool.self, forKey: .hadAudio) ?? false
        }
    }

    @Published private(set) var progressFraction: Double = 0
    @Published private(set) var progressMessage: String = ""
    @Published private(set) var isRunning = false
    @Published private(set) var resultsBySongId: [String: SongMIR] = [:]

    private var task: Task<Void, Never>?

    private init() {
        load()
    }

    func mir(for songId: String) -> SongMIR? { resultsBySongId[songId] }

    func mir(song title: String, artist: String?) -> SongMIR? {
        if let artist, let hit = resultsBySongId[Self.songRecordKey(artist: artist, title: title)] {
            return hit
        }
        return resultsBySongId[title]
    }

    /// Every catalog track (Genius vault + claimed Model You songs). Writing stays unblocked.
    /// Audio → BPM/key/scale. Lyrics-only → those stay null; style tags still fill at low confidence.
    /// Re-run skips songs that already have a result unless `force`.
    func startFullCatalog(force: Bool = false) {
        guard !isRunning else { return }
        task?.cancel()
        isRunning = true
        progressFraction = 0
        progressMessage = "Listing catalog songs…"
        let brainSongs = ArtistBrainStore.shared.brain.songs
        let brainLyrics = ArtistBrainStore.shared.brain.lyricBars // ArtistBrainChunk
        task = Task { [weak self] in
            guard let self else { return }
            let snapshot = Self.collectSongs(brainSongs: brainSongs, brainLyrics: brainLyrics)
            let total = max(snapshot.count, 1)
            var written: [String: SongMIR] = [:]
            for (idx, song) in snapshot.enumerated() {
                if Task.isCancelled { break }
                await MainActor.run {
                    self.progressMessage = "\(idx + 1)/\(snapshot.count)  \(song.title)"
                    self.progressFraction = Double(idx) / Double(total)
                }
                if !force, let existing = await MainActor.run(body: { self.resultsBySongId[song.id] }),
                   existing.analyzedAt != nil {
                    continue
                }
                var mir = SongMIR(
                    bpm: nil, key: nil, scale: nil,
                    styleTags: [], styleTagConfidence: 0,
                    analyzedAt: Date(), hadAudio: false
                )
                if let url = song.audioURL, FileManager.default.fileExists(atPath: url.path) {
                    mir.hadAudio = true
                    do {
                        let result = try await AudioAnalysisService.shared.analyzeAudio(url: url)
                        mir.bpm = result.bpm
                        mir.key = result.key
                        mir.scale = result.scale
                    } catch {
                        // Leave BPM/key/scale null — do not invent.
                    }
                }
                let lyrics = song.lyrics ?? Self.vaultLyrics(artist: song.artist, title: song.title)
                let tags = Self.styleTags(lyrics: lyrics, bpm: mir.bpm, hadAudio: mir.hadAudio)
                mir.styleTags = tags
                mir.styleTagConfidence = tags.isEmpty ? 0 : (mir.hadAudio && mir.bpm != nil ? 0.72 : 0.32)
                written[song.id] = mir
                await MainActor.run {
                    self.resultsBySongId[song.id] = mir
                    // Persist vault rows as we go — sqlite is lyrics-only and read-only.
                    if idx % 50 == 49 { self.save() }
                }
                await Task.yield()
            }
            await MainActor.run {
                for (id, mir) in written { self.resultsBySongId[id] = mir }
                self.progressFraction = 1
                self.progressMessage = "Catalog MIR finished — \(self.resultsBySongId.count) songs"
                self.isRunning = false
                self.save()
                self.writeBackToBrain(written)
            }
        }
    }

    func start(songs: [(id: String, title: String, audioURL: URL?, lyrics: String?)], force: Bool = false) {
        guard !isRunning else { return }
        let mapped = songs.map {
            CatalogJob(id: $0.id, title: $0.title, artist: nil, audioURL: $0.audioURL, lyrics: $0.lyrics)
        }
        startJobs(mapped, force: force)
    }

    private func startJobs(_ snapshot: [CatalogJob], force: Bool) {
        task?.cancel()
        isRunning = true
        progressFraction = 0
        progressMessage = "Starting catalog MIR…"
        task = Task { [weak self] in
            guard let self else { return }
            let total = max(snapshot.count, 1)
            for (idx, song) in snapshot.enumerated() {
                if Task.isCancelled { break }
                await MainActor.run {
                    self.progressMessage = "\(idx + 1)/\(snapshot.count)  \(song.title)"
                    self.progressFraction = Double(idx) / Double(total)
                }
                if !force, self.resultsBySongId[song.id]?.analyzedAt != nil { continue }
                var mir = SongMIR(
                    bpm: nil, key: nil, scale: nil,
                    styleTags: [], styleTagConfidence: 0,
                    analyzedAt: Date(), hadAudio: false
                )
                if let url = song.audioURL, FileManager.default.fileExists(atPath: url.path) {
                    mir.hadAudio = true
                    do {
                        let result = try await AudioAnalysisService.shared.analyzeAudio(url: url)
                        mir.bpm = result.bpm
                        mir.key = result.key
                        mir.scale = result.scale
                    } catch {}
                }
                let tags = Self.styleTags(lyrics: song.lyrics, bpm: mir.bpm, hadAudio: mir.hadAudio)
                mir.styleTags = tags
                mir.styleTagConfidence = tags.isEmpty ? 0 : (mir.hadAudio && mir.bpm != nil ? 0.72 : 0.32)
                await MainActor.run {
                    self.resultsBySongId[song.id] = mir
                    if idx % 50 == 49 { self.save() }
                }
                await Task.yield()
            }
            await MainActor.run {
                self.progressFraction = 1
                self.progressMessage = "Catalog MIR finished — \(self.resultsBySongId.count) songs"
                self.isRunning = false
                self.save()
            }
        }
    }

    private struct CatalogJob: Sendable {
        var id: String
        var title: String
        var artist: String?
        var audioURL: URL?
        var lyrics: String?
    }

    /// Lyrics stay off the listing pass so a 40k-song vault scan does not stall.
    private static func vaultLyrics(artist: String?, title: String) -> String? {
        guard let artist, let store = BarHitsCatalogStore.shared else { return nil }
        let text = store.lyrics(artist: artist, song: title)
        return text.isEmpty ? nil : text
    }

    private static func collectSongs(
        brainSongs: [ArtistSong],
        brainLyrics: [ArtistBrainChunk]
    ) -> [CatalogJob] {
        var jobs: [CatalogJob] = []
        var seen = Set<String>()
        if let store = BarHitsCatalogStore.shared {
            for song in store.catalogSongs(limit: fullVaultSongLimit) {
                guard seen.insert(song.id).inserted else { continue }
                let audio = brainSongs.first { claimed in
                    claimed.title.compare(song.title, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                        && (song.artist.isEmpty
                            || claimed.primaryArtist.compare(song.artist, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame)
                }.flatMap { claimed -> URL? in
                    guard let path = claimed.audioPath, !path.isEmpty else { return nil }
                    return URL(fileURLWithPath: path)
                }
                jobs.append(CatalogJob(id: song.id, title: song.title, artist: song.artist, audioURL: audio, lyrics: nil))
            }
        }
        for song in brainSongs {
            guard seen.insert(song.id).inserted else { continue }
            let url: URL? = {
                guard let path = song.audioPath, !path.isEmpty else { return nil }
                return URL(fileURLWithPath: path)
            }()
            let lyrics = brainLyrics.filter { $0.songId == song.id }.map(\.text).joined(separator: "\n")
            jobs.append(CatalogJob(id: song.id, title: song.title, artist: song.primaryArtist, audioURL: url, lyrics: lyrics))
        }
        return jobs
    }

    private func writeBackToBrain(_ written: [String: SongMIR]) {
        var next = ArtistBrainStore.shared.brain
        var changed = false
        for i in next.songs.indices {
            let song = next.songs[i]
            let mir = written[song.id]
            ?? written[CatalogMIRBatchService.songRecordKey(artist: song.primaryArtist, title: song.title)]
            guard let mir else { continue }
            if next.songs[i].bpm != mir.bpm
                || next.songs[i].musicalKey != mir.key
                || next.songs[i].scale != mir.scale
                || next.songs[i].styleTags != mir.styleTags {
                next.songs[i].bpm = mir.bpm
                next.songs[i].musicalKey = mir.key
                next.songs[i].scale = mir.scale
                next.songs[i].styleTags = mir.styleTags
                changed = true
            }
        }
        if changed { ArtistBrainStore.shared.save(next) }
    }

    func cancel() {
        task?.cancel()
        isRunning = false
        progressMessage = "Stopped"
    }

    /// Heuristic style tags — trap, ballad, melody-rap, beat-driven, sparse, no-drums, live-band.
    nonisolated static func styleTags(lyrics: String?, bpm: Int?, hadAudio: Bool) -> [String] {
        var tags: [String] = []
        let text = (lyrics ?? "").lowercased()
        if let bpm {
            if bpm >= 130 && bpm <= 170 { tags.append("trap") }
            if bpm > 0 && bpm < 85 { tags.append("ballad") }
            if bpm >= 85 && bpm < 110 { tags.append("melody-rap") }
            if bpm >= 110 { tags.append("beat-driven") }
        }
        // Lyrics cues never invent BPM/key. They only label style.
        if text.contains("trap") || text.contains("skrrt") || text.contains("808") { tags.append("trap") }
        if text.contains("ballad") || text.contains("slow jam") || text.contains("piano") { tags.append("ballad") }
        if text.contains("melody") || text.contains("sing") || text.contains("croon") { tags.append("melody-rap") }
        if text.contains("beat") || text.contains("808") || text.contains("bass") { tags.append("beat-driven") }
        let lines = text.split(separator: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        if lines.count > 0 && lines.count <= 8 { tags.append("sparse") }
        if text.contains("acoustic") || text.contains("guitar") || text.contains("band") || text.contains("live") {
            tags.append("live-band")
        }
        if text.contains("a cappella") || text.contains("acapella") || text.contains("no drums")
            || text.contains("undrummed") || text.contains("no drum") {
            tags.append("no-drums")
        }
        // unique preserve order
        var seen = Set<String>()
        return tags.filter { seen.insert($0).inserted }
    }

    private func save() {
        if let data = Self.encodeRecords(resultsBySongId) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsStorageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.userDefaultsStorageKey),
              let decoded = Self.decodeRecords(data) else { return }
        resultsBySongId = decoded
    }

    nonisolated static func encodeRecords(_ records: [String: SongMIR]) -> Data? {
        try? JSONEncoder().encode(records)
    }

    nonisolated static func decodeRecords(_ data: Data) -> [String: SongMIR]? {
        try? JSONDecoder().decode([String: SongMIR].self, from: data)
    }
}
