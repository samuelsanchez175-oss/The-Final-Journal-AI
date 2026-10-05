import Foundation

/// On-device picture of who this artist is, derived from claimed-track bars.
/// Saved as a sketch; pending cards still need Keep before they write.
nonisolated struct ArtistIdentitySketch: Codable, Equatable {
    var audienceLine: String = ""
    var talkingTo: ArtistTalkingTo = .sameAsSongs
    var cityTokens: [String] = []
    var viceTokens: [String] = []
    var loveTokens: [String] = []
    var topicTokens: [String] = []
    var writerLine: String = ""
    var barCount: Int = 0
    var updatedAt: Date? = nil

    var isEmpty: Bool {
        cityTokens.isEmpty
            && viceTokens.isEmpty
            && loveTokens.isEmpty
            && topicTokens.isEmpty
            && audienceLine.isEmpty
            && writerLine.isEmpty
    }
}

/// Fills audience / city / vices / love / topics / writer pocket from their bars.
/// Does not scrape. Does not mint grief. Does not auto-Keep.
nonisolated enum ArtistIdentityIngest: Sendable {
    static let cityTitle = "The city"
    static let bottleTitle = "The bottle"
    static let loveTitle = "Love / women"
    static let topicsTitle = "What they talk about"
    static let writerTitle = "How they write"

    private static let places: Set<String> = [
        "city", "block", "trap", "hood", "street", "streets", "downtown", "hometown",
        "eastside", "westside", "southside", "northside", "atlanta", "houston",
        "chicago", "miami", "london", "toronto", "brooklyn", "detroit", "memphis",
        "texas", "georgia", "florida", "california", "york"
    ]
    private static let vices: Set<String> = [
        "henny", "hennessy", "lean", "drank", "perc", "percs", "molly", "xan",
        "xanax", "weed", "blunt", "whiskey", "tequila", "codeine", "actavis", "syrup"
    ]
    private static let love: Set<String> = [
        "girl", "shawty", "wifey", "girlfriend", "wife", "shorty"
    ]
    private static let grief: Set<String> = [
        "dead", "died", "dying", "rip", "grave", "funeral", "casket", "heaven"
    ]
    private static let stop: Set<String> = [
        "the", "and", "you", "that", "this", "with", "from", "have", "just", "like",
        "when", "your", "aint", "dont", "never", "still", "back", "down", "come",
        "make", "know", "want", "gotta", "they", "them", "she", "her", "his", "for"
    ]

    nonisolated static func sketch(from brain: ArtistBrain) -> ArtistIdentitySketch {
        let bars = brain.lyricBars.map(\.text)
        var sketch = ArtistIdentitySketch()
        sketch.barCount = bars.count
        guard !bars.isEmpty else { return sketch }

        var counts: [String: Int] = [:]
        for bar in bars {
            for token in RemindsMeOfScorer.contentTokens(bar) where token.count >= 3 {
                counts[token, default: 0] += 1
            }
        }
        func ranked(_ pool: Set<String>) -> [String] {
            pool.filter { (counts[$0] ?? 0) > 0 }
                .sorted { lhs, rhs in
                    let lc = counts[lhs] ?? 0
                    let rc = counts[rhs] ?? 0
                    if lc != rc { return lc > rc }
                    return lhs < rhs
                }
        }

        sketch.cityTokens = Array(ranked(places).prefix(6))
        sketch.viceTokens = Array(ranked(vices).prefix(6))
        sketch.loveTokens = Array(ranked(love).prefix(6))
        sketch.topicTokens = counts
            .filter { token, n in
                n >= 2
                    && token.count >= 4
                    && !stop.contains(token)
                    && !places.contains(token)
                    && !vices.contains(token)
                    && !love.contains(token)
                    && !grief.contains(token)
            }
            .sorted { lhs, rhs in
                if lhs.value != rhs.value { return lhs.value > rhs.value }
                return lhs.key < rhs.key
            }
            .prefix(6)
            .map(\.key)

        let talking = inferTalkingTo(counts: counts)
        sketch.talkingTo = talking
        sketch.audienceLine = talking.promptLine
        sketch.writerLine = writerLine(brain: brain, bars: bars)
        sketch.updatedAt = Date()
        return sketch
    }

    nonisolated static func pendingCards(from brain: ArtistBrain) -> [ArtistBrainCard] {
        let sketch = brain.identitySketch.isEmpty ? sketch(from: brain) : brain.identitySketch
        let blocked = Set(brain.tossedCardIDs)
        let confirmedTitles = Set(brain.confirmedCards.map(\.title))
        var cards: [ArtistBrainCard] = []

        func add(title: String, body: String, role: ArtistMentionRole) {
            guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            guard !confirmedTitles.contains(title) else { return }
            let stableID = "identity-\(title)"
            guard !blocked.contains(stableID) else { return }
            let card = ArtistBrainCard(
                id: stableID,
                title: title,
                body: body,
                source: "lyrics",
                mentionRole: role
            )
            guard !ArtistOnboardingContract.isTitlePersonaClaim(card) else { return }
            cards.append(card)
        }

        if !brain.artistName.isEmpty, !confirmedTitles.contains("Name") {
            add(
                title: "Name",
                body: "Write as \(brain.artistName). Not house wrap (Gunna / Thug / Baby).",
                role: .casual
            )
        }
        let audience = sketch.audienceLine.isEmpty ? brain.talkingTo.promptLine : sketch.audienceLine
        add(title: "Who you're talking to", body: audience, role: .casual)
        if !sketch.cityTokens.isEmpty {
            add(
                title: cityTitle,
                body: "Places that keep coming back: \(sketch.cityTokens.joined(separator: ", ")).",
                role: .motif
            )
        }
        if !sketch.viceTokens.isEmpty {
            add(
                title: bottleTitle,
                body: "Punch stays punch on the pour: \(sketch.viceTokens.joined(separator: ", ")).",
                role: .punch
            )
        }
        if !sketch.loveTokens.isEmpty {
            add(
                title: loveTitle,
                body: "Love interest language: \(sketch.loveTokens.joined(separator: ", ")).",
                role: .casual
            )
        }
        if !sketch.topicTokens.isEmpty {
            add(
                title: topicsTitle,
                body: "They keep talking about: \(sketch.topicTokens.joined(separator: ", ")).",
                role: .motif
            )
        }
        if !sketch.writerLine.isEmpty {
            add(title: writerTitle, body: sketch.writerLine, role: .casual)
        }
        let noLonger = brain.noLongerWriteLike.trimmingCharacters(in: .whitespacesAndNewlines)
        if !noLonger.isEmpty {
            add(title: "Don't write like this anymore", body: noLonger, role: .casual)
        }
        let leave = brain.leaveOut.trimmingCharacters(in: .whitespacesAndNewlines)
        if !leave.isEmpty {
            add(title: "Leave out", body: leave, role: .casual)
        }
        return cards.filter { !ArtistOnboardingContract.isTitlePersonaClaim($0) }
    }

    nonisolated static func containsGrief(_ text: String) -> Bool {
        !RemindsMeOfScorer.contentTokens(text).isDisjoint(with: grief)
    }

    nonisolated private static func inferTalkingTo(counts: [String: Int]) -> ArtistTalkingTo {
        let cityHits = places.reduce(0) { $0 + (counts[$1] ?? 0) }
        let loveHits = love.reduce(0) { $0 + (counts[$1] ?? 0) }
        if loveHits >= 2 && loveHits > cityHits { return .aGirl }
        if cityHits >= 2 { return .theCity }
        let selfHits = (counts["i"] ?? 0) + (counts["me"] ?? 0) + (counts["my"] ?? 0) + (counts["myself"] ?? 0)
        if selfHits >= 6 && cityHits == 0 && loveHits == 0 { return .myself }
        return .sameAsSongs
    }

    nonisolated private static func writerLine(brain: ArtistBrain, bars: [String]) -> String {
        let counts = bars.map { LineSyllableCounter.syllableCount(forLine: $0) }.filter { $0 > 0 }
        let graph = ArtistBrainGraph.rebuild(from: brain)
        var parts: [String] = []
        if let lo = counts.min(), let hi = counts.max() {
            if lo == hi {
                parts.append("Bars sit around \(lo) syllables.")
            } else {
                parts.append("Bars sit around \(lo)–\(hi) syllables.")
            }
        }
        let punches = graph.punchLabels.prefix(4)
        if !punches.isEmpty {
            parts.append("Punch lands on \(punches.joined(separator: ", ")).")
        }
        let motifs = graph.motifLabels.prefix(4)
        if !motifs.isEmpty {
            parts.append("Motifs: \(motifs.joined(separator: ", ")).")
        }
        if parts.isEmpty {
            return "Write in their pocket from the claimed bars — not house wrap."
        }
        return parts.joined(separator: " ")
    }
}
