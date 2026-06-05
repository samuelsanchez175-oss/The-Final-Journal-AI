//
//  CorpusFeedbackStore.swift
//  XJournal AI
//
//  Model G v4 — Phase 3: the feedback loop that makes RAG retrieval ADAPT.
//
//  Two outcome signals are folded into a per-tone reward (exponential moving average):
//    1. AUTHENTICITY — the VerseLedger NET of each generated verse (automatic; recorded by v4).
//    2. ACCEPT/REJECT — whether the user kept or discarded a suggestion (recorded by TasteMemory).
//
//  GroundTruthCorpus.retrieve adds `reward * biasScale` for a bar's tone, so tones that
//  historically produce higher-authenticity / kept verses get pulled more often. Bounded so it
//  nudges ranking without overriding the tone/cadence/rhyme match. Persisted in UserDefaults.
//

import Foundation

final class CorpusFeedbackStore {
    static let shared = CorpusFeedbackStore()
    private init() {}

    /// How strongly a learned reward moves a bar's retrieval score (tone match is +3, so ±1.5 nudges).
    static let biasScale: Double = 1.5

    private let key = "model_g_corpus_tone_reward"
    private let defaults = UserDefaults.standard
    private let alpha: Double = 0.15        // EMA learning rate
    private let maxAbsReward: Double = 1.0  // reward clamp

    // MARK: - Record outcomes

    /// Automatic signal: the authenticity NET (0–100) of a verse generated for these retrieval tones.
    /// Maps to a reward in [-1, 1] centered on 50 (the "average" authenticity).
    func recordGeneration(tones: [String], net: Double) {
        let reward = clampReward((net - 50.0) / 50.0)
        update(tones: tones, reward: reward)
    }

    /// Explicit signal: the user kept (accepted) or discarded (rejected) a verse. Tones are inferred
    /// from the verse text. Acceptance is a strong positive; rejection a milder negative (noisier).
    func recordAcceptance(text: String, accepted: Bool) {
        let tones = Self.tones(in: text)
        guard !tones.isEmpty else { return }
        update(tones: tones, reward: accepted ? 1.0 : -0.5)
    }

    // MARK: - Read

    /// One snapshot of the learned per-tone rewards (lowercased keys). Read once per retrieval so
    /// scoring 9k bars doesn't hit UserDefaults 9k times.
    func rewardsSnapshot() -> [String: Double] {
        guard let data = defaults.data(forKey: key),
              let dict = try? JSONDecoder().decode([String: Double].self, from: data) else { return [:] }
        return dict
    }

    /// Convenience single-tone nudge (already scaled). Use `rewardsSnapshot()` in hot loops.
    func toneBias(_ tone: String?) -> Double {
        guard let tone = tone?.lowercased() else { return 0 }
        return (rewardsSnapshot()[tone] ?? 0) * Self.biasScale
    }

    /// Wipe learned corpus feedback (pairs with a "reset personalization" control).
    func reset() { defaults.removeObject(forKey: key) }

    // MARK: - Internals

    private func update(tones: [String], reward: Double) {
        var r = rewardsSnapshot()
        for t in Set(tones.map { $0.lowercased() }) {
            let prev = r[t] ?? 0
            r[t] = clampReward(prev + alpha * (reward - prev))   // EMA toward the new reward
        }
        if let data = try? JSONEncoder().encode(r) { defaults.set(data, forKey: key) }
    }

    private func clampReward(_ v: Double) -> Double { min(maxAbsReward, max(-maxAbsReward, v)) }

    /// Detect which corpus tone labels a verse expresses (mirrors the corpus's tone vocabulary and
    /// VerseLedger / grade_modelg.py's tone word sets).
    static func tones(in text: String) -> [String] {
        let w = Set(text.lowercased().split { !$0.isLetter }.map(String.init))
        var out: [String] = []
        if !w.isDisjoint(with: luxuriousWords)  { out.append("luxurious") }
        if !w.isDisjoint(with: confidentWords)  { out.append("confident") }
        if !w.isDisjoint(with: aggressiveWords) { out.append("aggressive") }
        if !w.isDisjoint(with: grittyWords)     { out.append("gritty") }
        return out
    }

    private static let luxuriousWords: Set<String> = ["diamonds", "diamond", "designer", "rich", "foreign",
        "drip", "ice", "racks", "bands", "chain", "rolex", "porsche", "patek", "gold", "mansion", "wraith", "vvs"]
    private static let confidentWords: Set<String> = ["boss", "king", "won", "top", "best", "run", "own",
        "real", "gang", "winning", "champion", "solid"]
    private static let aggressiveWords: Set<String> = ["smoke", "opp", "opps", "clip", "war", "stick",
        "slide", "beam", "drum", "shooter"]
    private static let grittyWords: Set<String> = ["trap", "kitchen", "corner", "block", "struggle", "cold",
        "streets", "pain", "grind", "hood"]
}
