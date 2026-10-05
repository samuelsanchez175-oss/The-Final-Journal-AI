import Foundation

// MARK: - Model You artist brain (on-device)

nonisolated enum ArtistMentionRole: String, Codable, CaseIterable, Identifiable {
    case punch
    case casual
    case motif
    var id: String { rawValue }
    var label: String {
        switch self {
        case .punch: return "Punch"
        case .casual: return "Casual"
        case .motif: return "Motif"
        }
    }
}

nonisolated enum ArtistTalkingTo: String, Codable, CaseIterable, Identifiable {
    case sameAsSongs
    case myself
    case aGirl
    case theCity
    case somebodyWhoAintHere
    var id: String { rawValue }
    var label: String {
        switch self {
        case .sameAsSongs: return "The same as the songs"
        case .myself: return "Myself"
        case .aGirl: return "A girl"
        case .theCity: return "The city"
        case .somebodyWhoAintHere: return "Somebody who ain't here"
        }
    }
    var promptLine: String {
        switch self {
        case .sameAsSongs: return "Talk to the same audience the catalog already talks to."
        case .myself: return "Talk to yourself — private, first-person, no crowd."
        case .aGirl: return "Talk to a girl."
        case .theCity: return "Talk to the city."
        case .somebodyWhoAintHere: return "Talk to somebody who ain't here."
        }
    }
}

nonisolated enum ArtistBrainChunkKind: String, Codable {
    case lyricBar = "lyric_bar"
    case caption
    case answer
    case confirmedCard = "confirmed_card"
}

nonisolated enum ArtistBrainCardStatus: String, Codable {
    case pending
    case kept
    case tossed
    case edited
}

nonisolated struct ArtistHomeStance: Codable, Equatable {
    var socialAction: SocialAction
    var audienceScope: AudienceScope
    var registerProfile: RegisterProfile
    var authorityPosture: AuthorityPosture
    var exposureRisk: ExposureRisk

    static let catalogDefault = ArtistHomeStance(
        socialAction: .assert,
        audienceScope: .public,
        registerProfile: .empty(),
        authorityPosture: .established,
        exposureRisk: .medium
    )

    var promptLine: String {
        "Home stance: \(socialAction.rawValue) to \(audienceScope.rawValue), \(authorityPosture.rawValue) authority, exposure \(exposureRisk.rawValue)."
    }
}

nonisolated struct ArtistSong: Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var primaryArtist: String
    var isFeature: Bool
    var included: Bool
    var source: String
    /// Local audio when available — MIR stays null without it.
    var audioPath: String? = nil
    var bpm: Int? = nil
    var musicalKey: String? = nil
    var scale: String? = nil
    var styleTags: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, title, primaryArtist, isFeature, included, source
        case audioPath, bpm, musicalKey, scale, styleTags
    }

    init(id: String, title: String, primaryArtist: String, isFeature: Bool, included: Bool, source: String,
         audioPath: String? = nil, bpm: Int? = nil, musicalKey: String? = nil, scale: String? = nil, styleTags: [String] = []) {
        self.id = id
        self.title = title
        self.primaryArtist = primaryArtist
        self.isFeature = isFeature
        self.included = included
        self.source = source
        self.audioPath = audioPath
        self.bpm = bpm
        self.musicalKey = musicalKey
        self.scale = scale
        self.styleTags = styleTags
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        primaryArtist = try c.decode(String.self, forKey: .primaryArtist)
        isFeature = try c.decodeIfPresent(Bool.self, forKey: .isFeature) ?? false
        included = try c.decodeIfPresent(Bool.self, forKey: .included) ?? true
        source = try c.decodeIfPresent(String.self, forKey: .source) ?? ""
        audioPath = try c.decodeIfPresent(String.self, forKey: .audioPath)
        bpm = try c.decodeIfPresent(Int.self, forKey: .bpm)
        musicalKey = try c.decodeIfPresent(String.self, forKey: .musicalKey)
        scale = try c.decodeIfPresent(String.self, forKey: .scale)
        styleTags = try c.decodeIfPresent([String].self, forKey: .styleTags) ?? []
    }
}

/// Background ingest that survives leaving the You tab.
nonisolated struct ArtistIngestProgress: Codable, Equatable {
    var isRunning: Bool = false
    var currentIndex: Int = 0
    var total: Int = 0
    var currentTitle: String = ""
    var message: String = ""
    var startedAt: Date? = nil
    var finishedAt: Date? = nil

    var fraction: Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, Double(currentIndex) / Double(total)))
    }

    var returnWhenReadyCopy: String {
        if isRunning {
            if currentIndex == 0 || total == 0 {
                return "Reading your songs in the background. You can leave this tab — come back when the bar is full."
            }
            return "Reading \(currentIndex) of \(total)\(currentTitle.isEmpty ? "" : ": \(currentTitle)"). You can leave this tab — come back when the bar is full."
        }
        if total > 0, currentIndex >= total, finishedAt != nil {
            return "Reading finished. Songs still missing lyrics are listed below — paste them if you have them."
        }
        return ""
    }
}

nonisolated struct ArtistBrainChunk: Codable, Identifiable, Equatable {
    var id: String
    var kind: ArtistBrainChunkKind
    var text: String
    var wrapFamily: String?
    var endRhyme: String?
    var syllableCount: Int
    var songId: String?
    var songTitle: String?
    var sourceURL: String?
    var ingestSource: String?

    init(
        id: String = UUID().uuidString,
        kind: ArtistBrainChunkKind,
        text: String,
        wrapFamily: String? = nil,
        endRhyme: String? = nil,
        syllableCount: Int = 0,
        songId: String? = nil,
        songTitle: String? = nil,
        sourceURL: String? = nil,
        ingestSource: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.text = text
        self.wrapFamily = wrapFamily
        self.endRhyme = endRhyme
        self.syllableCount = syllableCount > 0 ? syllableCount : LineSyllableCounter.syllableCount(forLine: text)
        self.songId = songId
        self.songTitle = songTitle
        self.sourceURL = sourceURL
        self.ingestSource = ingestSource
        if self.endRhyme == nil {
            self.endRhyme = ArtistBrainRAG.endWord(of: text)
        }
        if self.wrapFamily == nil {
            self.wrapFamily = ArtistBrainRAG.wrapFamily(of: text)
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        kind = try c.decodeIfPresent(ArtistBrainChunkKind.self, forKey: .kind) ?? .answer
        text = try c.decodeIfPresent(String.self, forKey: .text) ?? ""
        wrapFamily = try c.decodeIfPresent(String.self, forKey: .wrapFamily)
        endRhyme = try c.decodeIfPresent(String.self, forKey: .endRhyme)
        syllableCount = try c.decodeIfPresent(Int.self, forKey: .syllableCount) ?? 0
        songId = try c.decodeIfPresent(String.self, forKey: .songId)
        songTitle = try c.decodeIfPresent(String.self, forKey: .songTitle)
        sourceURL = try c.decodeIfPresent(String.self, forKey: .sourceURL)
        ingestSource = try c.decodeIfPresent(String.self, forKey: .ingestSource)
        if syllableCount == 0 {
            syllableCount = LineSyllableCounter.syllableCount(forLine: text)
        }
        if endRhyme == nil {
            endRhyme = ArtistBrainRAG.endWord(of: text)
        }
        if wrapFamily == nil {
            wrapFamily = ArtistBrainRAG.wrapFamily(of: text)
        }
    }
}

nonisolated struct ArtistBrainCard: Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var body: String
    var source: String
    var status: ArtistBrainCardStatus
    var mentionRole: ArtistMentionRole

    init(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        source: String,
        status: ArtistBrainCardStatus = .pending,
        mentionRole: ArtistMentionRole = .punch
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.source = source
        self.status = status
        self.mentionRole = mentionRole
    }
}

nonisolated struct ArtistBrain: Codable, Equatable {
    var artistName: String = ""
    var spotifyURL: String = ""
    var appleMusicURL: String = ""
    var instagramHandle: String = ""
    var songs: [ArtistSong] = []
    var noLongerWriteLike: String = ""
    var talkingTo: ArtistTalkingTo = .sameAsSongs
    var leaveOut: String = ""
    /// Per-object role is confirmed on cards in Phase 3. This global default is unused in onboarding.
    var mentionRole: ArtistMentionRole = .casual
    var homeStance: ArtistHomeStance = .catalogDefault
    var pendingCards: [ArtistBrainCard] = []
    var confirmedCards: [ArtistBrainCard] = []
    var tossedCardIDs: [String] = []
    var chunks: [ArtistBrainChunk] = []
    var catalogResolvedAt: Date? = nil
    /// Claimed-track bars. Rebuild copies included-song rows into `chunks`; unchecked songs drop out.
    var ingestedBars: [ArtistBrainChunk] = []
    /// Picture filled from claimed bars. Pending until Keep.
    var identitySketch: ArtistIdentitySketch = ArtistIdentitySketch()
    var ingestProgress: ArtistIngestProgress = ArtistIngestProgress()

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        artistName = try c.decodeIfPresent(String.self, forKey: .artistName) ?? ""
        spotifyURL = try c.decodeIfPresent(String.self, forKey: .spotifyURL) ?? ""
        appleMusicURL = try c.decodeIfPresent(String.self, forKey: .appleMusicURL) ?? ""
        instagramHandle = try c.decodeIfPresent(String.self, forKey: .instagramHandle) ?? ""
        songs = try c.decodeIfPresent([ArtistSong].self, forKey: .songs) ?? []
        noLongerWriteLike = try c.decodeIfPresent(String.self, forKey: .noLongerWriteLike) ?? ""
        talkingTo = try c.decodeIfPresent(ArtistTalkingTo.self, forKey: .talkingTo) ?? .sameAsSongs
        leaveOut = try c.decodeIfPresent(String.self, forKey: .leaveOut) ?? ""
        mentionRole = try c.decodeIfPresent(ArtistMentionRole.self, forKey: .mentionRole) ?? .casual
        homeStance = try c.decodeIfPresent(ArtistHomeStance.self, forKey: .homeStance) ?? .catalogDefault
        pendingCards = try c.decodeIfPresent([ArtistBrainCard].self, forKey: .pendingCards) ?? []
        confirmedCards = try c.decodeIfPresent([ArtistBrainCard].self, forKey: .confirmedCards) ?? []
        tossedCardIDs = try c.decodeIfPresent([String].self, forKey: .tossedCardIDs) ?? []
        chunks = try c.decodeIfPresent([ArtistBrainChunk].self, forKey: .chunks) ?? []
        catalogResolvedAt = try c.decodeIfPresent(Date.self, forKey: .catalogResolvedAt)
        ingestedBars = try c.decodeIfPresent([ArtistBrainChunk].self, forKey: .ingestedBars) ?? []
        identitySketch = try c.decodeIfPresent(ArtistIdentitySketch.self, forKey: .identitySketch) ?? ArtistIdentitySketch()
        ingestProgress = try c.decodeIfPresent(ArtistIngestProgress.self, forKey: .ingestProgress) ?? ArtistIngestProgress()
    }

    func barCount(forSongId songId: String) -> Int {
        ingestedBars.filter { $0.kind == .lyricBar && $0.songId == songId }.count
    }

    var includedSongs: [ArtistSong] { songs.filter(\.included) }
    var includedSongIDs: Set<String> { Set(includedSongs.map(\.id)) }
    var lyricBars: [ArtistBrainChunk] {
        ingestedBars.filter { $0.kind == .lyricBar && includedSongIDs.contains($0.songId ?? "") }
    }
    var hasCatalog: Bool { !artistName.isEmpty || !songs.isEmpty }
    var hasConfirmedBrain: Bool {
        !confirmedCards.isEmpty
            || !lyricBars.isEmpty
            || !chunks.isEmpty
            || !noLongerWriteLike.isEmpty
            || !leaveOut.isEmpty
    }
    var neverUse: [String] { ArtistOnboardingContract.neverUseTerms(from: leaveOut) }

    var emptyBrainCopy: String {
        "Write like a pro using only what they told us. Do not invent hometown, people, themes, or a drug story. Do not imitate another artist's full lyrics."
    }
}
