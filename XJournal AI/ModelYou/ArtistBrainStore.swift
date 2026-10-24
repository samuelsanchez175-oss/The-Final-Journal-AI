import Foundation
import Combine

/// Summary representation of a saved Artist Brain for selection in UI.
nonisolated struct ArtistBrainSummary: Identifiable, Equatable {
    let id: String
    let name: String
    let barCount: Int
    let confirmedCardCount: Int

    var displayName: String {
        name.isEmpty ? "Unnamed Voice" : name
    }
}

/// On-device ArtistBrain store supporting multiple brains persisted in `ModelYouBrains/<id>.json`.
/// Also writes `user_personal_details` and mirrors legacy UserDefaults for backward compatibility.
@MainActor
final class ArtistBrainStore: ObservableObject {
    static let shared = ArtistBrainStore()
    static let brainKey = "model_you_artist_brain"
    static let personalDetailsKey = "user_personal_details"
    static let activeBrainIDKey = "model_you_active_brain_id"

    var customBrainsDirectory: URL? = nil

    var brainsDirectory: URL {
        if let custom = customBrainsDirectory {
            return custom
        }
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("ModelYouBrains", isDirectory: true)
    }

    func fileURL(for id: String) -> URL {
        brainsDirectory.appendingPathComponent("\(id).json")
    }

    private func ensureBrainsDirectoryExists() {
        try? FileManager.default.createDirectory(at: brainsDirectory, withIntermediateDirectories: true)
    }

    @Published private(set) var activeBrainID: String
    @Published private(set) var brain: ArtistBrain
    private var ingestTask: Task<Void, Never>?

    var isIngesting: Bool { brain.ingestProgress.isRunning }

    private init() {
        let savedID = UserDefaults.standard.string(forKey: Self.activeBrainIDKey) ?? "default"
        self.activeBrainID = savedID
        if let initial = Self.loadDirect(id: savedID, customDir: nil) {
            self.brain = initial
        } else {
            self.brain = Self.loadLegacyFromUserDefaults() ?? ArtistBrain(id: savedID)
        }
        migrateLegacyBrainIfNeeded()
    }

    @discardableResult
    func migrateLegacyBrainIfNeeded() -> Bool {
        ensureBrainsDirectoryExists()
        let defaultURL = fileURL(for: "default")
        // Idempotent: do not overwrite if default.json already exists
        guard !FileManager.default.fileExists(atPath: defaultURL.path) else {
            return false
        }
        guard let legacyData = UserDefaults.standard.data(forKey: Self.brainKey) else {
            return false
        }
        do {
            var legacyBrain = try JSONDecoder().decode(ArtistBrain.self, from: legacyData)
            if legacyBrain.id.isEmpty {
                legacyBrain.id = "default"
            }
            let encoded = try JSONEncoder().encode(legacyBrain)
            try encoded.write(to: defaultURL, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    func load(id: String) -> ArtistBrain? {
        ensureBrainsDirectoryExists()
        let url = fileURL(for: id)
        if FileManager.default.fileExists(atPath: url.path) {
            if id == "default" && UserDefaults.standard.object(forKey: Self.brainKey) == nil && customBrainsDirectory == nil {
                return nil
            }
            if let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode(ArtistBrain.self, from: data) {
                return decoded
            }
        }
        if id == "default" {
            return Self.loadLegacyFromUserDefaults()
        }
        return nil
    }

    static func load(id: String) -> ArtistBrain? {
        ArtistBrainStore.shared.load(id: id)
    }

    private static func loadDirect(id: String, customDir: URL?) -> ArtistBrain? {
        let dir: URL = {
            if let customDir { return customDir }
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0].appendingPathComponent("ModelYouBrains", isDirectory: true)
        }()
        let url = dir.appendingPathComponent("\(id).json")
        if FileManager.default.fileExists(atPath: url.path),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(ArtistBrain.self, from: data) {
            return decoded
        }
        return nil
    }

    private static func loadLegacyFromUserDefaults() -> ArtistBrain? {
        guard let data = UserDefaults.standard.data(forKey: brainKey),
              var decoded = try? JSONDecoder().decode(ArtistBrain.self, from: data) else {
            return nil
        }
        if decoded.id.isEmpty {
            decoded.id = "default"
        }
        return decoded
    }

    static func load() -> ArtistBrain {
        if let active = ArtistBrainStore.shared.load(id: ArtistBrainStore.shared.activeBrainID) {
            return active
        }
        return loadLegacyFromUserDefaults() ?? ArtistBrain(id: ArtistBrainStore.shared.activeBrainID)
    }

    func reload() {
        if let loaded = load(id: activeBrainID) {
            brain = loaded
        } else if activeBrainID == "default", let legacy = Self.loadLegacyFromUserDefaults() {
            brain = legacy
        } else {
            brain = ArtistBrain(id: activeBrainID)
        }
    }

    func save(brain next: ArtistBrain) {
        var copy = next
        if copy.id.isEmpty {
            copy.id = activeBrainID.isEmpty ? "default" : activeBrainID
        }
        copy.identitySketch = ArtistIdentityIngest.sketch(from: copy)
        copy.homeStance = Self.inferHomeStance(from: copy)
        copy.chunks = Self.rebuildChunks(from: copy)

        ensureBrainsDirectoryExists()
        let url = fileURL(for: copy.id)
        if let data = try? JSONEncoder().encode(copy) {
            try? data.write(to: url, options: .atomic)
            if copy.id == activeBrainID || copy.id == "default" {
                UserDefaults.standard.set(data, forKey: Self.brainKey)
            }
        }
        if copy.id == activeBrainID {
            self.brain = copy
            writePersonalDetailsMirror(copy)
        }
    }

    func save(_ next: ArtistBrain) {
        save(brain: next)
    }

    func switchBrain(to id: String) {
        guard activeBrainID != id else { return }
        activeBrainID = id
        UserDefaults.standard.set(id, forKey: Self.activeBrainIDKey)
        reload()
        writePersonalDetailsMirror(self.brain)
    }

    func delete(id: String) {
        ensureBrainsDirectoryExists()
        let url = fileURL(for: id)
        try? FileManager.default.removeItem(at: url)
        if id == "default" || id == activeBrainID {
            UserDefaults.standard.removeObject(forKey: Self.brainKey)
        }
        UserDefaults.standard.removeObject(forKey: ModelYouSettings.key(for: id))

        if id == activeBrainID {
            let remaining = allBrainSummaries().filter { $0.id != id }
            if let first = remaining.first {
                switchBrain(to: first.id)
            } else {
                activeBrainID = "default"
                UserDefaults.standard.set("default", forKey: Self.activeBrainIDKey)
                brain = ArtistBrain(id: "default")
            }
        }
    }

    func allBrainSummaries() -> [ArtistBrainSummary] {
        ensureBrainsDirectoryExists()
        var summaries: [ArtistBrainSummary] = []
        var seenIDs: Set<String> = []

        if let urls = try? FileManager.default.contentsOfDirectory(at: brainsDirectory, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles) {
            let jsonURLs = urls.filter { $0.pathExtension == "json" }
            for url in jsonURLs {
                let id = url.deletingPathExtension().lastPathComponent
                if let b = load(id: id) {
                    seenIDs.insert(id)
                    let name = b.artistName.isEmpty ? (id == "default" ? "My Voice" : id) : b.artistName
                    let bars = max(b.lyricBars.count, b.ingestedBars.filter { $0.kind == .lyricBar }.count)
                    summaries.append(ArtistBrainSummary(
                        id: b.id.isEmpty ? id : b.id,
                        name: name,
                        barCount: bars,
                        confirmedCardCount: b.confirmedCards.count
                    ))
                }
            }
        }

        if !seenIDs.contains("default") {
            if let legacy = Self.loadLegacyFromUserDefaults() {
                let name = legacy.artistName.isEmpty ? "My Voice" : legacy.artistName
                let bars = max(legacy.lyricBars.count, legacy.ingestedBars.filter { $0.kind == .lyricBar }.count)
                summaries.append(ArtistBrainSummary(
                    id: "default",
                    name: name,
                    barCount: bars,
                    confirmedCardCount: legacy.confirmedCards.count
                ))
            }
        }

        if summaries.isEmpty {
            summaries.append(ArtistBrainSummary(
                id: activeBrainID.isEmpty ? "default" : activeBrainID,
                name: brain.artistName.isEmpty ? "My Voice" : brain.artistName,
                barCount: brain.lyricBars.count,
                confirmedCardCount: brain.confirmedCards.count
            ))
        }

        return summaries.sorted { s1, s2 in
            if s1.id == "default" { return true }
            if s2.id == "default" { return false }
            return s1.name.localizedCaseInsensitiveCompare(s2.name) == .orderedAscending
        }
    }

    func resetCatalog() {
        var next = brain
        next.spotifyURL = ""
        next.appleMusicURL = ""
        next.songs = []
        next.pendingCards = []
        next.ingestedBars = []
        next.identitySketch = ArtistIdentitySketch()
        next.catalogResolvedAt = nil
        save(next)
    }

    /// Removes the whole on-device artist brain. Model G is untouched.
    func wipeArtistBrain() {
        ingestTask?.cancel()
        ingestTask = nil
        UserDefaults.standard.removeObject(forKey: Self.brainKey)
        brain = ArtistBrain()
    }

    func cancelIngest() {
        ingestTask?.cancel()
        ingestTask = nil
        var next = brain
        next.ingestProgress.isRunning = false
        next.ingestProgress.message = "Stopped. Bars already saved stay on this iPhone. Songs still missing lyrics are listed below."
        save(next)
    }

    /// Continues after leaving the You tab, or after relaunch if a job was in flight.
    func resumeIngestIfNeeded() {
        guard brain.ingestProgress.isRunning, ingestTask == nil else { return }
        startBackgroundIngest()
    }

    func startBackgroundIngest() {
        let claimed = brain.includedSongs
        guard !claimed.isEmpty else { return }
        if ingestTask != nil { return }
        var next = brain
        next.ingestProgress = ArtistIngestProgress(
            isRunning: true,
            currentIndex: 0,
            total: claimed.count,
            currentTitle: "",
            message: "Reading your songs in the background. You can leave this tab — come back when the bar is full.",
            startedAt: Date()
        )
        save(next)
        let artist = next.artistName
        ingestTask = Task { [weak self] in
            await self?.runBackgroundIngest(claimed: claimed, artist: artist)
        }
    }

    private func runBackgroundIngest(claimed: [ArtistSong], artist: String) async {
        _ = await ArtistLyricIngest.ingestIncludedSongs(
            claimed,
            catalogArtist: artist,
            apiKey: KeychainHelper.shared.getGeniusAPIKey(),
            onSong: { song, bars, index, total in
                await MainActor.run {
                    ArtistBrainStore.shared.absorbSongIngest(song: song, bars: bars)
                    var next = ArtistBrainStore.shared.brain
                    next.ingestProgress.isRunning = true
                    next.ingestProgress.currentIndex = index
                    next.ingestProgress.total = total
                    next.ingestProgress.currentTitle = song.title
                    next.ingestProgress.message = next.ingestProgress.returnWhenReadyCopy
                    ArtistBrainStore.shared.save(next)
                }
            }
        )
        await MainActor.run {
            self.ingestTask = nil
            var next = self.brain
            let cancelled = Task.isCancelled
            next.ingestProgress.isRunning = false
            next.ingestProgress.finishedAt = Date()
            if !cancelled {
                next.ingestProgress.currentIndex = max(next.ingestProgress.currentIndex, next.ingestProgress.total)
            }
            next.pendingCards = Self.inferPendingCards(from: next)
            next.ingestProgress.message = cancelled
                ? "Stopped. Songs still missing lyrics are listed below — paste them if you have them."
                : next.ingestProgress.returnWhenReadyCopy
            self.save(next)
        }
    }

    func absorbSongIngest(song: ArtistSong, bars: [ArtistBrainChunk]) {
        var next = brain
        if !bars.isEmpty {
            next.ingestedBars = ArtistLyricIngest.merge(
                next.ingestedBars,
                with: bars,
                replacingSongId: song.id
            )
        }
        let pictured = ArtistIdentityIngest.sketch(from: next)
        if next.talkingTo == .sameAsSongs, pictured.talkingTo != .sameAsSongs {
            next.talkingTo = pictured.talkingTo
        }
        save(next)
    }

    private func writePersonalDetailsMirror(_ brain: ArtistBrain) {
        var details = UserPersonalDetails()
        if let existing = UserDefaults.standard.data(forKey: Self.personalDetailsKey),
           let decoded = try? JSONDecoder().decode(UserPersonalDetails.self, from: existing) {
            details = decoded
        }
        if !brain.artistName.isEmpty, !details.interests.contains(brain.artistName) {
            details.interests.insert(brain.artistName, at: 0)
        }
        let talking = brain.talkingTo.label
        if !details.themes.contains(talking) {
            details.themes.append(talking)
        }
        var backgroundBits: [String] = []
        if !brain.artistName.isEmpty { backgroundBits.append("Artist: \(brain.artistName)") }
        if !brain.noLongerWriteLike.isEmpty { backgroundBits.append("No longer: \(brain.noLongerWriteLike)") }
        if !brain.leaveOut.isEmpty { backgroundBits.append("Leave out: \(brain.leaveOut)") }
        if !brain.instagramHandle.isEmpty { backgroundBits.append("IG: @\(brain.instagramHandle)") }
        let kept = brain.confirmedCards.filter { $0.status == .kept || $0.status == .edited }.map { "\($0.title): \($0.body)" }
        if !kept.isEmpty { backgroundBits.append(kept.joined(separator: " | ")) }
        if !backgroundBits.isEmpty {
            details.background = backgroundBits.joined(separator: "\n")
        }
        if let data = try? JSONEncoder().encode(details) {
            UserDefaults.standard.set(data, forKey: Self.personalDetailsKey)
        }
    }

    nonisolated static func rebuildChunks(from brain: ArtistBrain) -> [ArtistBrainChunk] {
        var chunks: [ArtistBrainChunk] = []
        for card in brain.confirmedCards where card.status == .kept || card.status == .edited {
            chunks.append(ArtistBrainRAG.makeChunk(kind: .confirmedCard, text: "\(card.title): \(card.body)"))
        }
        let noLonger = brain.noLongerWriteLike.trimmingCharacters(in: .whitespacesAndNewlines)
        if !noLonger.isEmpty {
            chunks.append(ArtistBrainRAG.makeChunk(kind: .answer, text: "No longer write like: \(noLonger)"))
        }
        chunks.append(ArtistBrainRAG.makeChunk(kind: .answer, text: brain.talkingTo.promptLine))
        let leave = brain.leaveOut.trimmingCharacters(in: .whitespacesAndNewlines)
        if !leave.isEmpty {
            chunks.append(ArtistBrainRAG.makeChunk(kind: .answer, text: "Leave out: \(leave)"))
        }
        let included = brain.includedSongIDs
        for bar in brain.ingestedBars where bar.kind == .lyricBar {
            guard let songId = bar.songId, included.contains(songId) else { continue }
            guard RemindsMeOfScorer.isLyricBar(bar.text) else { continue }
            guard !RemindsMeOfScorer.isTitleLeak(bar.text, song: bar.songTitle ?? "") else { continue }
            chunks.append(bar)
        }
        return chunks
    }

    /// Identity + gap answers. Lyric-backed city/bottle/love/topics stay pending until Keep.
    nonisolated static func inferPendingCards(from brain: ArtistBrain) -> [ArtistBrainCard] {
        ArtistIdentityIngest.pendingCards(from: brain)
    }

    nonisolated static func inferHomeStance(from brain: ArtistBrain) -> ArtistHomeStance {
        var stance = ArtistHomeStance.catalogDefault
        let lyrics = brain.lyricBars.map(\.text).joined(separator: "\n")
        if let axes = computeModelGSignalAxes(from: lyrics) {
            stance.socialAction = axes.socialAction
            stance.audienceScope = axes.audienceScope
            stance.authorityPosture = axes.authorityPosture
            stance.exposureRisk = axes.exposureRisk
        } else {
            switch brain.talkingTo {
            case .myself:
                stance.socialAction = .withdraw
                stance.audienceScope = .selfOnly
                stance.exposureRisk = .low
                stance.authorityPosture = .emerging
            case .aGirl:
                stance.socialAction = .confess
                stance.audienceScope = .innerCircle
                stance.exposureRisk = .medium
            case .theCity:
                stance.socialAction = .assert
                stance.audienceScope = .public
                stance.exposureRisk = .medium
            case .somebodyWhoAintHere:
                stance.socialAction = .distance
                stance.audienceScope = .innerCircle
                stance.exposureRisk = .high
            case .sameAsSongs:
                stance.socialAction = .assert
                stance.audienceScope = .public
            }
        }
        switch brain.talkingTo {
        case .myself:
            stance.audienceScope = .selfOnly
        case .aGirl, .somebodyWhoAintHere:
            stance.audienceScope = .innerCircle
        case .theCity:
            stance.audienceScope = .public
        case .sameAsSongs:
            break
        }
        return stance
    }
}
