import Foundation

/// User-facing name. Vault bars and web records both sit here — not a Genius feature.
enum RemindsMeOfCopy {
    static let title = "Bar hits"
    static let toolbar = "Hits"
    static let accessibility = "Bar hits"
    static let hint = "Same wrap and nearby wrap from the on-device catalog. Same-idea pictures sit under those hits. Genius is its own tab."

    static func searchFailureMessage(for error: Error) -> String {
        searchIssue(for: error).headline
    }

    static func searchIssue(for error: Error) -> RemindsMeOfSearchIssue {
        if let api = error as? RapAPIError {
            switch api {
            case .serverError(let code, _):
                if code == 403 || code == 401 {
                    return .tokenBlocked
                }
                if code == 429 {
                    return .rateLimit
                }
                return RemindsMeOfSearchIssue(
                    kind: .other,
                    headline: "Web song search failed",
                    detail: "Vault bars still show. Try again in a minute. If it keeps failing, refresh the Genius client access token."
                )
            case .rateLimitExceeded:
                return .rateLimit
            case .requestFailed:
                return .network
            case .missingAPIKey:
                return .tokenBlocked
            default:
                break
            }
        }
        let lower = error.localizedDescription.lowercased()
        if lower.contains("403") || lower.contains("401") || lower.contains("forbidden") || lower.contains("unauthorized") {
            return .tokenBlocked
        }
        if lower.contains("429") || lower.contains("rate limit") {
            return .rateLimit
        }
        if lower.contains("network") || lower.contains("offline") || lower.contains("connection") {
            return .network
        }
        return RemindsMeOfSearchIssue(
            kind: .other,
            headline: "Web song search failed",
            detail: "Vault bars still show. Try again, or refresh the Genius client access token."
        )
    }
}

struct RemindsMeOfSearchIssue: Equatable {
    enum Kind: Equatable {
        case token
        case rateLimit
        case network
        case other
    }

    var kind: Kind
    var headline: String
    var detail: String

    var showsTokenField: Bool { kind == .token }
    var tapPrompt: String {
        showsTokenField ? "Tap to refresh the Genius token." : "Tap for what to try next."
    }

    static let tokenBlocked = RemindsMeOfSearchIssue(
        kind: .token,
        headline: "Refresh the Genius client access token",
        detail: "Web song search was blocked. Vault bars still show. Get a new Client Access Token from the Genius developer page, paste it, then Save."
    )
    static let rateLimit = RemindsMeOfSearchIssue(
        kind: .rateLimit,
        headline: "Web song search hit a limit",
        detail: "Vault bars still show. Wait a minute, then try again."
    )
    static let network = RemindsMeOfSearchIssue(
        kind: .network,
        headline: "Couldn't reach song search",
        detail: "Check the connection, then try again. Vault bars still show."
    )
}

nonisolated enum RemindsMeOfSource: String, Codable, Equatable, Sendable {
    case csv
    case genius
    case both

    var label: String {
        switch self {
        case .csv: return "Catalog"
        case .genius: return "Genius"
        case .both: return "Catalog · Genius"
        }
    }
}

/// Unscored lyric / song row from CSV, corpus, or the growing vault.
nonisolated struct RemindsMeOfCandidate: Equatable, Sendable {
    var id: String
    var line: String
    var artist: String?
    var song: String?
    var syllableCount: Int
    var source: RemindsMeOfSource
    var geniusID: Int?
    var url: URL?
}

/// One scored reference shown in the popup.
struct RemindsMeOfHit: Identifiable, Equatable {
    let id: String
    let line: String
    let artist: String?
    let song: String?
    let source: RemindsMeOfSource
    let url: URL?
    let syllableCount: Int
    let score: Double
    var metaphor: String? = nil

    var subtitle: String {
        [artist, song].compactMap { $0?.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.joined(separator: " · ")
    }
}

/// Color-grouped pocket, same layout language as rhyme groups.
struct RemindsMeOfGroup: Identifiable, Equatable {
    let id: String
    let title: String
    let colorIndex: Int
    let hits: [RemindsMeOfHit]
    /// Genius records — song title + artist, not a lyric bar.
    var showsAsTracks: Bool = false
}

nonisolated struct GeniusSongHit: Equatable, Identifiable, Sendable {
    let id: Int
    let title: String
    let artist: String
    let url: URL?
    /// Highlighted lyric bar from `/api/search/lyric`. Nil for title-only song search.
    var lyricLine: String? = nil

    var displayLine: String {
        let bar = lyricLine?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return bar.isEmpty ? title : bar
    }
}

/// Raw Genius lyric-search row before a snippet line is picked.
struct GeniusLyricHit: Equatable, Identifiable {
    let id: Int
    let title: String
    let artist: String
    let url: URL?
    let snippet: String
}

/// One verse line that returned Genius hits. Green on the writing surface; tap for songs.
struct RemindsMeOfLineMatch: Identifiable, Equatable {
    var id: Int { index }
    let index: Int
    let line: String
    let location: Int
    let length: Int
    let hits: [GeniusSongHit]
}

/// Hold a gutter count → wrap + almost-rhymes, similar meaning, then records Genius named.
struct RemindsMeOfHeldLineResult: Equatable {
    let line: String
    let syllables: Int
    let wrap: [RemindsMeOfHit]
    let meaning: [RemindsMeOfHit]
    let tracks: [RemindsMeOfHit]
    var meaningCards: [SimilarMeaningPipeline.ScoredCard] = []
    /// Same-end-word bars now live in `wrap`. Kept so older call sites compile.
    var landing: [RemindsMeOfHit] { [] }

    var isEmpty: Bool {
        wrap.isEmpty && meaning.isEmpty && tracks.isEmpty
    }

    /// Same wrap + same start — swap for the held line. Shown behind a button, not in the default list.
    func replaceHits() -> [RemindsMeOfHit] {
        wrap.filter {
            $0.syllableCount == syllables && RemindsMeOfScorer.prefixOverlap(line, $0.line) >= 1
        }
    }

    /// Next-line suggestions first, then nearby wrap (rhyme + slant), then same-idea pictures.
    func groups() -> [RemindsMeOfGroup] {
        var groups: [RemindsMeOfGroup] = []
        var buckets: [Int: [RemindsMeOfHit]] = [:]
        for hit in wrap {
            buckets[hit.syllableCount, default: []].append(hit)
        }
        for count in wrapSectionOrder {
            guard let hits = buckets[count], !hits.isEmpty else { continue }
            if count == syllables {
                // Next line is the full wrap pocket. Do not hide "I …" bars —
                // most catalog lines start with I, and that emptied the list.
                groups.append(RemindsMeOfGroup(
                    id: "held-follow-\(count)",
                    title: "Next line · \(count)-count",
                    colorIndex: 0,
                    hits: hits
                ))
            } else {
                groups.append(RemindsMeOfGroup(
                    id: "held-wrap-\(count)",
                    title: Self.nearbyWrapTitle(count),
                    colorIndex: 0,
                    hits: hits
                ))
            }
        }
        if !meaningCards.isEmpty {
            var order: [String] = []
            var buckets: [String: [SimilarMeaningPipeline.ScoredCard]] = [:]
            for card in meaningCards {
                let key = card.neighborhood.metaphorLabel.isEmpty ? "same idea" : card.neighborhood.metaphorLabel
                if buckets[key] == nil { order.append(key) }
                buckets[key, default: []].append(card)
            }
            for label in order {
                let hits = (buckets[label] ?? []).map { card in
                    RemindsMeOfHit(
                        id: card.neighborhood.anchorId,
                        line: card.neighborhood.anchor,
                        artist: card.neighborhood.artist,
                        song: card.neighborhood.song,
                        source: .csv,
                        url: nil,
                        syllableCount: LineSyllableCounter.syllableCount(forLine: card.neighborhood.anchor),
                        score: card.score
                    )
                }
                groups.append(RemindsMeOfGroup(
                    id: "held-meaning-\(label)",
                    title: "Imagery · \(label)",
                    colorIndex: 2,
                    hits: hits
                ))
            }
        } else if !meaning.isEmpty {
            groups.append(RemindsMeOfGroup(
                id: "held-meaning",
                title: "Same idea, different pictures",
                colorIndex: 2,
                hits: meaning
            ))
        }
        if !tracks.isEmpty {
            groups.append(RemindsMeOfGroup(
                id: "held-tracks",
                title: "Genius",
                colorIndex: 0,
                hits: tracks,
                showsAsTracks: true
            ))
        }
        return groups
    }

    /// Intended count first, then n-1, n+1, n+2 (the rest of the wrap window).
    private var wrapSectionOrder: [Int] {
        let window = RemindsMeOfScorer.wrapSyllableWindow(around: syllables)
        var order = [syllables]
        for count in window where count != syllables {
            order.append(count)
        }
        return order
    }

    private static func sameWrapTitle(_ count: Int) -> String {
        count == 1 ? "Same wrap (1 syllable)" : "Same wrap (\(count) syllables)"
    }

    private static func nearbyWrapTitle(_ count: Int) -> String {
        count == 1
            ? "Nearby wrap · 1-count · rhyme & slant"
            : "Nearby wrap · \(count)-count · rhyme & slant"
    }
}
