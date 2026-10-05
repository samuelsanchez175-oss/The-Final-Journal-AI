import Foundation

nonisolated enum ArtistBrainEdgeKind: String, Codable, Equatable {
    case person
    case place
    case vice
    case motif
    case wrapFamily
    case endRhyme
}

/// Small on-device graph over confirmed You chunks. Pending cards never become nodes.
nonisolated struct ArtistBrainGraph: Equatable {
    nonisolated struct Node: Equatable, Identifiable {
        var id: String
        var kind: ArtistBrainChunkKind
        var text: String
        var mentionRole: ArtistMentionRole
        var mentionOK: Bool
        var confidence: Double
        var songId: String?
        var songTitle: String?
        var chunkId: String
    }

    nonisolated struct Edge: Equatable {
        var from: String
        var to: String
        var kind: ArtistBrainEdgeKind
        var count: Int
    }

    nonisolated struct ObjectStat: Equatable {
        var token: String
        var punch: Int
        var casual: Int
        var bars: Int
        var role: ArtistMentionRole
    }

    var nodes: [Node]
    var edges: [Edge]
    var objects: [ObjectStat]
    /// Lyric bars + confirmed cards only. Never pending, never titles, never neverUse.
    var retrieveChunks: [ArtistBrainChunk]

    var punchLabels: [String] { objects.filter { $0.role == .punch }.map(\.token) }
    var casualLabels: [String] { objects.filter { $0.role == .casual }.map(\.token) }
    var motifLabels: [String] { objects.filter { $0.role == .motif }.map(\.token) }

    static func rebuild(from brain: ArtistBrain) -> ArtistBrainGraph {
        let blocked = neverUseKeys(brain.neverUse)
        var nodes: [Node] = []
        var retrieve: [ArtistBrainChunk] = []

        for card in brain.confirmedCards where card.status == .kept || card.status == .edited {
            let text = "\(card.title): \(card.body)"
            guard !containsNeverUse(text, blocked: blocked) else { continue }
            let chunk = ArtistBrainRAG.makeChunk(kind: .confirmedCard, text: text)
            retrieve.append(chunk)
            nodes.append(Node(
                id: "card-\(card.id)",
                kind: .confirmedCard,
                text: text,
                mentionRole: card.mentionRole,
                mentionOK: true,
                confidence: 1,
                songId: nil,
                songTitle: nil,
                chunkId: chunk.id
            ))
        }

        let included = brain.includedSongIDs
        for bar in brain.ingestedBars where bar.kind == .lyricBar {
            guard let songId = bar.songId, included.contains(songId) else { continue }
            guard RemindsMeOfScorer.isLyricBar(bar.text) else { continue }
            guard !RemindsMeOfScorer.isTitleLeak(bar.text, song: bar.songTitle ?? "") else { continue }
            guard !containsNeverUse(bar.text, blocked: blocked) else { continue }
            retrieve.append(bar)
            nodes.append(Node(
                id: "bar-\(bar.id)",
                kind: .lyricBar,
                text: bar.text,
                mentionRole: .casual,
                mentionOK: true,
                confidence: 1,
                songId: bar.songId,
                songTitle: bar.songTitle,
                chunkId: bar.id
            ))
        }

        let objects = objectStats(from: retrieve.filter { $0.kind == .lyricBar })
        var edges: [Edge] = []
        var objectNodes: [Node] = []
        for obj in objects {
            let nodeID = "obj-\(obj.token)"
            objectNodes.append(Node(
                id: nodeID,
                kind: .caption,
                text: obj.token,
                mentionRole: obj.role,
                mentionOK: true,
                confidence: min(1, Double(obj.bars) / 4.0),
                songId: nil,
                songTitle: nil,
                chunkId: nodeID
            ))
            let kind: ArtistBrainEdgeKind = obj.role == .motif ? .motif : (obj.role == .punch ? .endRhyme : .wrapFamily)
            for bar in retrieve where bar.kind == .lyricBar {
                let tokens = RemindsMeOfScorer.contentTokens(bar.text)
                guard tokens.contains(obj.token) else { continue }
                edges.append(Edge(from: "bar-\(bar.id)", to: nodeID, kind: kind, count: 1))
            }
        }

        for bar in retrieve where bar.kind == .lyricBar {
            if let family = bar.wrapFamily {
                edges.append(Edge(from: "bar-\(bar.id)", to: "wrap-\(family)", kind: .wrapFamily, count: 1))
            }
            if let end = bar.endRhyme {
                edges.append(Edge(from: "bar-\(bar.id)", to: "rhyme-\(end)", kind: .endRhyme, count: 1))
            }
        }

        return ArtistBrainGraph(
            nodes: nodes + objectNodes,
            edges: edges,
            objects: objects,
            retrieveChunks: retrieve
        )
    }

    static func neverUseKeys(_ terms: [String]) -> [String] {
        terms
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { $0.count >= 2 }
    }

    static func containsNeverUse(_ text: String, blocked: [String]) -> Bool {
        guard !blocked.isEmpty else { return false }
        let lower = text.lowercased()
        let tokens = RemindsMeOfScorer.contentTokens(text)
        return blocked.contains { term in
            tokens.contains(term) || lower.contains(term)
        }
    }

    static func objectStats(from bars: [ArtistBrainChunk]) -> [ObjectStat] {
        var punch: [String: Int] = [:]
        var casual: [String: Int] = [:]
        var barHits: [String: Set<String>] = [:]
        for bar in bars {
            let tokens = RemindsMeOfScorer.contentTokens(bar.text)
            let end = ArtistBrainRAG.endWord(of: bar.text)
            for token in tokens where token.count >= 4 {
                if token == end {
                    punch[token, default: 0] += 1
                } else {
                    casual[token, default: 0] += 1
                }
                barHits[token, default: []].insert(bar.id)
            }
        }
        let keys = Set(punch.keys).union(casual.keys)
        return keys.compactMap { token -> ObjectStat? in
            let p = punch[token] ?? 0
            let c = casual[token] ?? 0
            let barsHit = barHits[token]?.count ?? 0
            guard p + c >= 1 else { return nil }
            let role: ArtistMentionRole
            if barsHit >= 3 {
                role = .motif
            } else if p >= c && p > 0 {
                role = .punch
            } else {
                role = .casual
            }
            return ObjectStat(token: token, punch: p, casual: c, bars: barsHit, role: role)
        }
        .sorted { lhs, rhs in
            if lhs.bars != rhs.bars { return lhs.bars > rhs.bars }
            return lhs.token < rhs.token
        }
    }
}
