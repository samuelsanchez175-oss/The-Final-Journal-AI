//
//  UserTasteVector.swift
//  XJournal AI
//
//  Model G Core v1.0 — User taste bias for scoring.
//  Bias influence capped at 15% in ScoringEngine.
//

import Foundation

/// User taste vector — tracks learned preferences with exponential decay.
struct UserTasteVector: Codable {
    var specificityBias: Double
    var glideBias: Double
    var edgeBias: Double
    var culturalBias: Double
    var darknessBias: Double

    mutating func applyDecay() {
        specificityBias *= 0.92
        glideBias *= 0.92
        edgeBias *= 0.92
        culturalBias *= 0.92
        darknessBias *= 0.92
    }

    /// Default neutral vector.
    static let neutral = UserTasteVector(
        specificityBias: 0,
        glideBias: 0,
        edgeBias: 0,
        culturalBias: 0,
        darknessBias: 0
    )
}

// MARK: - User Taste Store
//
// Persists a learned `UserTasteVector` and updates it from the user's
// accept / reject / edit actions (fed in by `TasteMemory`). The Model G
// coordinators read `currentVector()` instead of `.neutral`, so scoring
// (ScoringEngine.applyUserTasteModifiers, capped at 15%) actually reflects
// what the user keeps vs. throws away. Biases decay slowly so taste can drift.

/// Single source of truth for the persisted user taste vector.
final class UserTasteStore {
    static let shared = UserTasteStore()

    private let vectorKey = "model_g_user_taste_vector"
    private let dateKey = "model_g_user_taste_vector_updated"
    private let defaults = UserDefaults.standard

    /// Bias magnitude is clamped so `bias * 0.01` stays inside the scorer's 0.15 cap.
    private let clampLimit: Double = 15.0
    /// Per-day forgetting factor applied on read (taste drifts toward neutral over time).
    private let dailyDecay: Double = 0.97

    private init() {}

    /// The current taste vector with time decay applied. `.neutral` until the user has acted.
    func currentVector() -> UserTasteVector {
        guard let stored = load() else { return .neutral }
        return applyTimeDecay(stored, since: lastUpdated())
    }

    /// Learn from a single user action on a suggestion's text.
    /// Accept nudges biases toward the bar's features; reject nudges away; edit is a mild accept.
    func learn(from text: String, action: TasteAction) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var vector = applyTimeDecay(load() ?? .neutral, since: lastUpdated())
        let features = TasteFeatureExtractor.features(from: trimmed)

        let step: Double
        switch action {
        case .accepted: step = 2.0
        case .edited:   step = 1.0
        case .rejected: step = -1.5
        }

        vector.specificityBias = clamp(vector.specificityBias + features.specificity * step)
        vector.glideBias       = clamp(vector.glideBias + features.glide * step)
        vector.edgeBias        = clamp(vector.edgeBias + features.edge * step)
        vector.culturalBias    = clamp(vector.culturalBias + features.cultural * step)
        vector.darknessBias    = clamp(vector.darknessBias + features.darkness * step)

        save(vector)
    }

    /// Wipe learned taste (e.g. from a settings "reset personalization" control).
    func reset() {
        defaults.removeObject(forKey: vectorKey)
        defaults.removeObject(forKey: dateKey)
    }

    // MARK: Persistence

    private func load() -> UserTasteVector? {
        guard let data = defaults.data(forKey: vectorKey) else { return nil }
        return try? JSONDecoder().decode(UserTasteVector.self, from: data)
    }

    private func lastUpdated() -> Date {
        (defaults.object(forKey: dateKey) as? Date) ?? Date()
    }

    private func save(_ vector: UserTasteVector) {
        if let data = try? JSONEncoder().encode(vector) {
            defaults.set(data, forKey: vectorKey)
        }
        defaults.set(Date(), forKey: dateKey)
    }

    private func clamp(_ value: Double) -> Double {
        min(clampLimit, max(-clampLimit, value))
    }

    private func applyTimeDecay(_ vector: UserTasteVector, since: Date) -> UserTasteVector {
        let days = max(0, Calendar.current.dateComponents([.day], from: since, to: Date()).day ?? 0)
        guard days > 0 else { return vector }
        let factor = pow(dailyDecay, Double(min(days, 60)))
        var decayed = vector
        decayed.specificityBias *= factor
        decayed.glideBias *= factor
        decayed.edgeBias *= factor
        decayed.culturalBias *= factor
        decayed.darknessBias *= factor
        return decayed
    }
}

// MARK: - Taste Feature Extractor
//
// Lightweight, dependency-free heuristics that estimate how strongly a bar
// expresses each taste dimension (0...1). Intentionally cheap so it can run
// on every accept/reject without touching the LLM or the lexicon loaders.

enum TasteFeatureExtractor {

    /// Returns 0...1 intensities for each taste axis.
    static func features(from text: String) -> (specificity: Double, glide: Double, edge: Double, cultural: Double, darkness: Double) {
        let lower = text.lowercased()
        let words = lower.split { !$0.isLetter && !$0.isNumber }.map(String.init)
        let total = max(1, words.count)

        // Specificity: numbers, money/percent markers, concrete detail.
        let numericTokens = words.filter { $0.contains(where: { $0.isNumber }) }.count
        let moneyMarks = lower.filter { $0 == "$" || $0 == "%" }.count
        let specificity = clamp01(Double(numericTokens + moneyMarks) / Double(total) * 3.0)

        let cultural = keywordRatio(culturalTerms, words: words, total: total, scale: 4.0)
        let edge = keywordRatio(edgeTerms, words: words, total: total, scale: 4.0)
        let darkness = keywordRatio(darkTerms, words: words, total: total, scale: 4.0)

        // Glide: melodic ad-libs + elongated vowels (e.g. "yeahhh", "ooo").
        let adlibHits = words.filter { adlibTerms.contains($0) }.count
        let elongations = elongatedVowelRuns(in: lower)
        let glide = clamp01((Double(adlibHits) / Double(total) * 4.0) + (Double(elongations) / Double(total) * 3.0))

        return (specificity, glide, edge, cultural, darkness)
    }

    // MARK: Helpers

    private static func keywordRatio(_ set: Set<String>, words: [String], total: Int, scale: Double) -> Double {
        let hits = words.reduce(0) { $0 + (set.contains($1) ? 1 : 0) }
        return clamp01(Double(hits) / Double(total) * scale)
    }

    /// Counts runs of the same vowel repeated 3+ times (a cheap "melodic stretch" proxy).
    private static func elongatedVowelRuns(in text: String) -> Int {
        let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
        var runs = 0
        var previous: Character? = nil
        var runLength = 0
        for char in text {
            if char == previous {
                runLength += 1
                if runLength == 3 && vowels.contains(char) { runs += 1 }
            } else {
                previous = char
                runLength = 1
            }
        }
        return runs
    }

    private static func clamp01(_ value: Double) -> Double { min(1.0, max(0.0, value)) }

    // Compact, style-appropriate keyword sets (melodic trap idiom). Heuristic, not exhaustive.
    private static let culturalTerms: Set<String> = [
        "drip", "racks", "bands", "guap", "plug", "whip", "ice", "slime", "gang",
        "designer", "cap", "slatt", "twin", "dawg", "foreign", "sauce", "wraith",
        "pesos", "geeked", "spinners", "diamonds", "vvs"
    ]
    private static let edgeTerms: Set<String> = [
        "boss", "king", "win", "run", "own", "flex", "hard", "real", "beast",
        "savage", "top", "stunt", "shine", "grind", "hustle", "rich", "richer", "up"
    ]
    private static let darkTerms: Set<String> = [
        "pain", "dead", "die", "lonely", "cold", "dark", "lost", "hurt", "numb",
        "gone", "tears", "grave", "hell", "demons", "broke", "alone", "cry", "scars"
    ]
    private static let adlibTerms: Set<String> = [
        "ooh", "ohh", "ayy", "yeah", "yea", "woah", "oh", "mmm", "huh", "skrt", "brr", "na", "la"
    ]
}
