import Foundation

/// Per-verse retrieve filters on the You seat. Not a new model.
struct ModelYouVerseFilters: Equatable {
    var usePeople: Bool = true
    var useBottle: Bool = true
    var streetOnly: Bool = false

    var effectiveUsePeople: Bool { streetOnly ? false : usePeople }
    var effectiveUseBottle: Bool { streetOnly ? false : useBottle }

    /// Writer-facing constraints so retrieve filters are not silent.
    var promptConstraintLines: [String] {
        if streetOnly {
            return ["This verse is street only: places, objects, the block. Do not name people. Do not pour the bottle."]
        }
        var lines: [String] = []
        if !usePeople {
            lines.append("This verse: no people. Do not name family, friends, or a girl.")
        }
        if !useBottle {
            lines.append("This verse: no bottle or drink punch. Leave the pour out.")
        }
        return lines
    }
}

/// Dedicated per-brain settings: modelYou_settings_<brainID>
struct ModelYouSettings: Codable, Equatable {
    var usePeople: Bool
    var useBottle: Bool
    var streetOnly: Bool

    init(usePeople: Bool = true, useBottle: Bool = true, streetOnly: Bool = false) {
        self.usePeople = usePeople
        self.useBottle = useBottle
        self.streetOnly = streetOnly
    }

    init(filters: ModelYouVerseFilters) {
        self.usePeople = filters.usePeople
        self.useBottle = filters.useBottle
        self.streetOnly = filters.streetOnly
    }

    var filters: ModelYouVerseFilters {
        ModelYouVerseFilters(usePeople: usePeople, useBottle: useBottle, streetOnly: streetOnly)
    }

    static func key(for brainID: String) -> String {
        "modelYou_settings_\(brainID)"
    }

    static func load(for brainID: String, userDefaults: UserDefaults = .standard) -> ModelYouSettings {
        guard let data = userDefaults.data(forKey: key(for: brainID)),
              let decoded = try? JSONDecoder().decode(ModelYouSettings.self, from: data) else {
            return ModelYouSettings()
        }
        return decoded
    }

    func save(for brainID: String, userDefaults: UserDefaults = .standard) {
        if let data = try? JSONEncoder().encode(self) {
            userDefaults.set(data, forKey: Self.key(for: brainID))
        }
    }
}

/// Phase 4: Model You is a writer seat, not a prompt rename of G.
enum ModelYouWriterPolicy {
    static let settingsKey = "modelYou_settings"

    static func settingsKey(for brainID: String) -> String {
        ModelYouSettings.key(for: brainID)
    }

    static func settingsKey(for model: SuggestionModel, brainID: String? = nil) -> String {
        switch model {
        case .modelYou:
            if let brainID {
                return settingsKey(for: brainID)
            }
            return settingsKey
        case .modelY: return "modelY_settings"
        case .modelG, .modelGv3, .modelGv4_1, .geminiLight:
            return "modelGv3_settings"
        }
    }

    static func usesArtistSeat(artistBrainPrompt: String?) -> Bool {
        guard let prompt = artistBrainPrompt?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        return !prompt.isEmpty
    }

    static func shouldLoadHouseExemplars(artistBrainPrompt: String?) -> Bool {
        !usesArtistSeat(artistBrainPrompt: artistBrainPrompt)
    }

    static func usesHouseLuxury(artistBrainPrompt: String?) -> Bool {
        !usesArtistSeat(artistBrainPrompt: artistBrainPrompt)
    }

    static func usesHousePalette(artistBrainPrompt: String?) -> Bool {
        !usesArtistSeat(artistBrainPrompt: artistBrainPrompt)
    }

    static func referenceSeat(artistChunks: [String], limit: Int = 12) -> [String] {
        Array(artistChunks.prefix(limit).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
    }

    static func controlSurfaceCaption(brain: ArtistBrain) -> String {
        if brain.lyricBars.isEmpty {
            return "You (getting to know you). G craft, only what they told us. Model G stays house wrap."
        }
        return "Model You uses G craft with this artist's confirmed brain from Profile → You. Model G stays house wrap."
    }

    static func luxuryPromptLine(layer: LuxuryLayer, usingArtistBrain: Bool) -> String {
        guard !usingArtistBrain else { return "" }
        return "Luxury layers (weave naturally, never list, 1 brand per bar max): brands \(joinedOrDash(layer.brands)); specs \(joinedOrDash(layer.specs)); environments \(joinedOrDash(layer.environments))."
    }

    static func housePaletteLine(palette: [String], usingArtistBrain: Bool) -> String {
        guard !usingArtistBrain, !palette.isEmpty else { return "" }
        return "\nSpecific references you MAY draw on (pick 1-3 that genuinely fit the feeling; never force, never list them): \(palette.joined(separator: ", "))."
    }

    static func referenceBarsDirective(usingArtistBrain: Bool, inspiration: Double) -> String {
        if usingArtistBrain {
            return "REFERENCE BARS (this is you — wrap and landing from their catalog. Do NOT copy phrasing):"
        }
        if inspiration <= 0.33 {
            return "REFERENCE BARS (loose flavor only — diverge from these, do NOT echo them):"
        }
        return "REFERENCE BARS (study craft and vocabulary — DO NOT copy phrasing; fill new nouns):"
    }

    static func concreteRule(
        usingArtistBrain: Bool,
        filters: ModelYouVerseFilters = .init()
    ) -> String {
        if usingArtistBrain {
            if !filters.effectiveUsePeople && !filters.effectiveUseBottle {
                return "name something CONCRETE from this artist's confirmed street catalog (places, objects, the block) — skip family and the pour, not house-wrap brands unless they confirmed them"
            }
            if !filters.effectiveUsePeople {
                return "name something CONCRETE from this artist's confirmed brain (places, the pour, objects) — skip family this verse, not house-wrap brands unless they confirmed them"
            }
            if !filters.effectiveUseBottle {
                return "name something CONCRETE from this artist's confirmed brain (their places, family, objects) — skip the pour this verse, not house-wrap brands unless they confirmed them"
            }
            return "name something CONCRETE from this artist's confirmed brain (their places, people, bottles) — not house-wrap brands unless they confirmed them"
        }
        return "name something CONCRETE — a specific brand, place, or coded term, not a generic word (\"Roley\" not \"a watch\", \"the trap\" not \"the block\"), at most 1 brand per bar"
    }

    static let sparkleDefaultedKey = "model_you_sparkle_defaulted"

    static func shouldDefaultToYou(brain: ArtistBrain) -> Bool {
        !brain.lyricBars.isEmpty
            || brain.confirmedCards.contains { $0.status == .kept || $0.status == .edited }
    }

    /// One-shot: after You is filled, sparkle lands on Model You. Later G taps stick.
    static func adoptDefaultSparkleIfNeeded(brain: ArtistBrain, currentRaw: String) -> String {
        guard shouldDefaultToYou(brain: brain) else { return currentRaw }
        if UserDefaults.standard.bool(forKey: sparkleDefaultedKey) { return currentRaw }
        UserDefaults.standard.set(true, forKey: sparkleDefaultedKey)
        return SuggestionModel.modelYou.rawValue
    }

    static func containsHouseIdentityNouns(_ text: String) -> Bool {
        let lower = text.lowercased()
        let nouns = ["gunna", "wunna", "young thug", "thugger", "lil baby", "roley", "atlanta"]
        return nouns.contains { lower.contains($0) }
    }

    private static func joinedOrDash(_ items: [String]) -> String {
        let cleaned = items.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        return cleaned.isEmpty ? "—" : cleaned.joined(separator: ", ")
    }
}
