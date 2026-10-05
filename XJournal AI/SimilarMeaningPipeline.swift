import Foundation

/// Same-song similar-meaning pipeline.
/// Meaning window = PRIOR bars already said before the anchor + the anchor itself.
/// Following bars and other songs are out of scope. Wrap is NOT the meaning gate.
enum SimilarMeaningPipeline {

    struct Neighborhood: Equatable, Sendable {
        var song: String
        var artist: String?
        var priorLines: [String]
        var anchor: String
        var anchorId: String
        var themeTone: String
        var authorityPosture: AuthorityPosture
        var audienceScope: AudienceScope
        var talkingTo: String
        var socialAction: SocialAction
        var rubricIds: [String]
        var reason: String
        var metaphorId: String = ""
        var metaphorLabel: String = ""

        var displayPriors: [String] { priorLines }
        var axesSummary: String {
            let picture = metaphorLabel.isEmpty ? themeTone : metaphorLabel
            return "\(picture) · \(socialAction.rawValue) · \(authorityPosture.rawValue) · talking to \(talkingTo)"
        }
    }

    struct ScoredCard: Identifiable, Equatable {
        var id: String { neighborhood.anchorId }
        var neighborhood: Neighborhood
        var score: Double
    }

    /// Offline meaning buckets. Used on both the input window and the catalog window.
    static let rubric: [(id: String, label: String, social: SocialAction, posture: AuthorityPosture, talking: String, terms: [String])] = [
        ("poverty", "struggle / lack", .confess, .emerging, "himself",
         ["broke", "bowl", "hungry", "starving", "poor", "empty", "pockets", "mills", "mill", "hood",
          "struggle", "afford", "owe", "debt", "evict", "rent", "ramen", "foodstamp", "broke"]),
        ("flex", "flex / money", .flex, .established, "the city",
         ["money", "cash", "ice", "chain", "rich", "paid", "bands", "racks", "foreign", "diamonds"]),
        ("love", "love / want", .confess, .emerging, "a girl",
         ["love", "baby", "girl", "heart", "miss", "her", "kiss", "faithful"]),
        ("threat", "warning / street", .warn, .established, "you",
         ["watch", "opp", "opps", "slide", "body", "gun", "drill", "warn"]),
        ("distance", "walk away", .withdraw, .emerging, "you",
         ["leave", "gone", "left", "move", "ghost", "ignore"]),
        ("loyalty", "inner circle", .assert, .established, "homie",
         ["bro", "homie", "dawg", "gang", "family"])
    ]

    /// Parse `artist.song.linenum` catalog ids into song key + line number.
    nonisolated static func parseCatalogId(_ id: String) -> (songKey: String, line: Int)? {
        let parts = id.split(separator: ".")
        guard parts.count >= 3, let n = Int(parts.last!) else { return nil }
        let songKey = parts.dropLast().joined(separator: ".")
        return (songKey, n)
    }

    /// Build a meaning window from catalog rows that share a song: priors before anchor + anchor.
    /// Following bars stay out. Wrap is not used.
    static func neighborhood(from rows: [BarHitsCatalogStore.Row], anchor: BarHitsCatalogStore.Row) -> Neighborhood? {
        let ordered: [BarHitsCatalogStore.Row]
        if let parsed = parseCatalogId(anchor.id) {
            let numbered = rows.compactMap { row -> (Int, BarHitsCatalogStore.Row)? in
                guard let p = parseCatalogId(row.id), p.songKey == parsed.songKey else { return nil }
                return (p.line, row)
            }
            .sorted { $0.0 < $1.0 }
            ordered = numbered.isEmpty ? rows : numbered.map(\.1)
        } else {
            ordered = rows
        }
        let idx = ordered.firstIndex(where: { $0.id == anchor.id }) ?? ordered.firstIndex(where: {
            $0.line == anchor.line
        })
        let priors: [String]
        if let idx {
            priors = Array(ordered.prefix(idx).suffix(6).map(\.line))
        } else {
            priors = []
        }
        return makeNeighborhood(
            song: anchor.song ?? "",
            artist: anchor.artist,
            priorLines: priors,
            anchor: anchor.line,
            anchorId: anchor.id
        )
    }

    static func makeNeighborhood(
        song: String,
        artist: String?,
        priorLines: [String],
        anchor: String,
        anchorId: String
    ) -> Neighborhood {
        let window = (priorLines + [anchor]).joined(separator: "\n")
        let buckets = matchedRubric(in: window)
        let labels = buckets.map(\.label)
        let pictures = MetaphorBridge.shared.lexicalMatches(in: anchor)
        let picture = pictures.first
        let prefix = priorLines.isEmpty ? "picture: " : "setup + picture: "
        let reason = prefix + (picture?.label ?? labels.first ?? themeTone(for: window))
        let social = buckets.first?.social ?? social(for: window)
        let posture = buckets.first?.posture ?? posture(for: window)
        let talking = buckets.first?.talking ?? talkingTo(for: window)
        return Neighborhood(
            song: song,
            artist: artist,
            priorLines: priorLines,
            anchor: anchor,
            anchorId: anchorId,
            themeTone: picture?.label ?? labels.first ?? themeTone(for: window),
            authorityPosture: posture,
            audienceScope: audience(for: window),
            talkingTo: talking,
            socialAction: social,
            rubricIds: buckets.map(\.id),
            reason: reason,
            metaphorId: picture?.id ?? "",
            metaphorLabel: picture?.label ?? ""
        )
    }

    /// Extra FTS seeds so "broke / bowl" also pulls mill/hood/struggle bars.
    static func seedTokens(for line: String) -> [String] {
        var tokens = Array(RemindsMeOfScorer.contentTokens(line))
        let hits = matchedRubric(in: line)
        for bucket in hits {
            tokens.append(contentsOf: bucket.terms.prefix(8))
        }
        tokens.append(contentsOf: MetaphorBridge.shared.extraSearchTerms(for: line))
        var seen = Set<String>()
        return tokens.filter { seen.insert($0.lowercased()).inserted }
    }

    static func matchedRubric(in text: String) -> [(id: String, label: String, social: SocialAction, posture: AuthorityPosture, talking: String, terms: [String])] {
        let lower = text.lowercased()
        return rubric.filter { bucket in
            bucket.terms.contains { term in
                lower.range(of: "\\b\(NSRegularExpression.escapedPattern(for: term))\\b", options: .regularExpression) != nil
                    || lower.contains(term)
            }
        }
    }

    /// Score catalog neighborhoods against the user's selected line + prior note lines.
    /// Wrap / syllable count is intentionally ignored as a gate.
    static func score(
        inputPriorLines: [String],
        inputAnchor: String,
        candidates: [Neighborhood],
        limit: Int = 12
    ) -> [ScoredCard] {
        let inputWindow = (inputPriorLines + [inputAnchor])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !inputWindow.isEmpty else { return [] }
        let inputText = inputWindow.joined(separator: "\n")
        let inputTokens = Set(inputWindow.flatMap { RemindsMeOfScorer.contentTokens($0) })
        let inputRubric = Set(matchedRubric(in: inputText).map(\.id))
        let inputThemes = ThemeCatalog.matchedThemeIDs(in: inputText, minimumScore: 1)
        let inputAxes = (
            social: social(for: inputText),
            posture: posture(for: inputText),
            audience: audience(for: inputText)
        )
        var scored: [ScoredCard] = []
        var seen = Set<String>()
        for hood in candidates {
            let key = hood.anchorId
            guard seen.insert(key).inserted else { continue }
            let candWindow = hood.priorLines + [hood.anchor]
            let candText = candWindow.joined(separator: "\n")
            let candTokens = Set(candWindow.flatMap { RemindsMeOfScorer.contentTokens($0) })
            guard !candTokens.isEmpty, !inputTokens.isEmpty else { continue }
            let overlap = Double(inputTokens.intersection(candTokens).count)
                / Double(max(inputTokens.union(candTokens).count, 1))
            let themeOverlap: Double = {
                let candThemes = ThemeCatalog.matchedThemeIDs(in: candText, minimumScore: 1)
                guard !inputThemes.isEmpty, !candThemes.isEmpty else { return 0 }
                return Double(inputThemes.intersection(candThemes).count)
                    / Double(inputThemes.union(candThemes).count)
            }()
            let rubricOverlap: Double = {
                let candRubric = Set(hood.rubricIds)
                guard !inputRubric.isEmpty, !candRubric.isEmpty else { return 0 }
                return Double(inputRubric.intersection(candRubric).count)
                    / Double(inputRubric.union(candRubric).count)
            }()
            var axis = 0.0
            if hood.socialAction == inputAxes.social { axis += 0.4 }
            if hood.authorityPosture == inputAxes.posture { axis += 0.3 }
            if hood.audienceScope == inputAxes.audience { axis += 0.3 }
            let inputPictures = Set(MetaphorBridge.shared.lexicalMatches(in: inputAnchor).map(\.id))
            let pictureBoost: Double = {
                guard !inputPictures.isEmpty, inputPictures.contains(hood.metaphorId) else { return 0 }
                return 0.22
            }()
            // Meaning only — wrap does not gate. Picture match beats shared words.
            let value = min(1, overlap * 0.28 + themeOverlap * 0.16 + rubricOverlap * 0.24 + axis * 0.12 + pictureBoost)
            guard value >= 0.12 else { continue }
            var cardHood = hood
            if cardHood.reason.isEmpty {
                cardHood.reason = cardHood.themeTone
            }
            scored.append(ScoredCard(neighborhood: cardHood, score: value))
        }
        return scored.sorted { $0.score > $1.score }.prefix(limit).map { $0 }
    }

    // MARK: - Lightweight Signal axis heuristics (offline)

    static func themeTone(for text: String) -> String {
        let ids = ThemeCatalog.matchedThemeIDs(in: text, minimumScore: 1)
        if ids.isEmpty { return "neutral" }
        return ids.sorted().prefix(2).joined(separator: "/")
    }

    static func posture(for text: String) -> AuthorityPosture {
        let lower = text.lowercased()
        if lower.contains("king") || lower.contains("boss") || lower.contains("established") { return .established }
        if lower.contains("coming up") || lower.contains("almost") { return .emerging }
        return .emerging
    }

    static func audience(for text: String) -> AudienceScope {
        let lower = text.lowercased()
        if lower.contains("y'all") || lower.contains("everybody") || lower.contains("world") { return .public }
        if lower.contains("bro") || lower.contains("homie") || lower.contains("we ") { return .innerCircle }
        return .selfOnly
    }

    static func talkingTo(for text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("baby") || lower.contains("girl") || lower.contains("she ") { return "a girl" }
        if lower.contains("city") || lower.contains("streets") { return "the city" }
        if lower.contains("you ") || lower.contains("ya ") { return "you" }
        return "himself"
    }

    static func social(for text: String) -> SocialAction {
        let lower = text.lowercased()
        if lower.contains("warn") || lower.contains("watch") { return .warn }
        if lower.contains("flex") || lower.contains("ice") || lower.contains("money") { return .flex }
        if lower.contains("miss") || lower.contains("hurt") || lower.contains("cry") { return .confess }
        if lower.contains("leave") || lower.contains("gone") { return .withdraw }
        if lower.contains("not me") || lower.contains("different") { return .distance }
        return .assert
    }
}
