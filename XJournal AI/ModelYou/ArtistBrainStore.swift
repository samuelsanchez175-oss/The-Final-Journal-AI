import Foundation
import Combine

/// On-device ArtistBrain. UserDefaults only — no off-device brain sync.
/// Also writes `user_personal_details` so older Model G / Y paths keep compiling.
@MainActor
final class ArtistBrainStore: ObservableObject {
    static let shared = ArtistBrainStore()
    static let brainKey = "model_you_artist_brain"
    static let personalDetailsKey = "user_personal_details"

    @Published private(set) var brain: ArtistBrain
    private var ingestTask: Task<Void, Never>?

    var isIngesting: Bool { brain.ingestProgress.isRunning }

    private init() {
        brain = Self.load()
    }

    static func load() -> ArtistBrain {
        guard let data = UserDefaults.standard.data(forKey: brainKey),
              let decoded = try? JSONDecoder().decode(ArtistBrain.self, from: data) else {
            return ArtistBrain()
        }
        return decoded
    }

    func reload() {
        brain = Self.load()
    }

    func save(_ next: ArtistBrain) {
        var copy = next
        copy.identitySketch = ArtistIdentityIngest.sketch(from: copy)
        copy.homeStance = Self.inferHomeStance(from: copy)
        copy.chunks = Self.rebuildChunks(from: copy)
        brain = copy
        if let data = try? JSONEncoder().encode(copy) {
            UserDefaults.standard.set(data, forKey: Self.brainKey)
        }
        writePersonalDetailsMirror(copy)
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
