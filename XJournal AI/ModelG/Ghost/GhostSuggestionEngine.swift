import Foundation

// MARK: - GhostHint

struct GhostHint {
    let candidates: [String]
    let tail: String?
    var display: String { "↳ rhymes: " + candidates.prefix(3).joined(separator: " · ") }
}

// MARK: - GhostSuggestionEngine

/// Free-tier rhyme-ending suggester.
/// Scans `getGlobalCMUDICTStore()` ([String:[String]] keyed by word) for words
/// whose stressed-vowel + coda match the target end-word, then ranks on-brand
/// candidates first via `ModelGCorpusRetriever`. Pure — no UI, no network.
struct GhostSuggestionEngine {
    let retriever: ModelGCorpusRetriever?

    // MARK: - Public API

    static func endWord(of line: String) -> String? {
        line.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .last
    }

    /// True when a body edit just finished a line (Enter) or added an indent (Tab) — the moment to
    /// recompute rhymes. Counts newlines/tabs rather than checking a trailing "\n": predictive text
    /// routinely batches the newline with the next word ("…star\nI talk"), so the old suffix check
    /// missed most line completions and the rhymes went stale.
    static func didCompleteLineOrIndent(old: String, new: String) -> Bool {
        func count(_ s: String, _ c: Character) -> Int { s.reduce(0) { $1 == c ? $0 + 1 : $0 } }
        return count(new, "\n") > count(old, "\n") || count(new, "\t") > count(old, "\t")
    }

    /// The line the user most recently finished — the segment terminated by the latest newline.
    /// Robust to predictive-text batching ("…star\nI talk" still yields "…star"). Falls back to the
    /// last non-empty line.
    static func justCompletedLine(in text: String) -> String? {
        let segments = text.components(separatedBy: "\n")
        if segments.count >= 2 {
            let candidate = segments[segments.count - 2]
            if !candidate.trimmingCharacters(in: .whitespaces).isEmpty { return candidate }
        }
        return segments.reversed().first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    /// The last non-empty line — the line the user is currently typing. Used for the live (debounced)
    /// refresh so rhymes appear as you type, before you hit Enter.
    static func lastNonEmptyLine(in text: String) -> String? {
        text.components(separatedBy: "\n").reversed().first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    func freeHint(forLastLine line: String) -> GhostHint? {
        guard let end = Self.endWord(of: line) else { return nil }
        let phonetic = Self.rhymeCandidates(for: end)
        guard !phonetic.isEmpty else { return nil }

        // Promote on-brand words (corpus hit) to the front.
        let onBrand: [String] = retriever.map { r in
            phonetic.filter { w in
                !r.retrieve(draft: w, k: 1).exemplars.isEmpty
            }
        } ?? []

        var ranked: [String] = []
        for w in (onBrand + phonetic) where !ranked.contains(w) {
            ranked.append(w)
        }
        return GhostHint(candidates: Array(ranked.prefix(3)), tail: nil)
    }

    // MARK: - Rhyme ranking (pure + testable; CMUDICT-independent)

    /// Rhyme strength between two phoneme arrays, matching the app's canonical `rhymeScore`
    /// (RapAnalysisEngine.swift:117): **2** = perfect (same stressed vowel *and* coda),
    /// **1** = slant (same stressed vowel, different coda), **0** = no rhyme.
    static func rhymeStrength(of candidate: [String], against target: [String]) -> Int {
        guard let t = phoneticSignature(from: target),
              let c = phoneticSignature(from: candidate),
              c.stressedVowel == t.stressedVowel else { return 0 }
        return c.coda == t.coda ? 2 : 1
    }

    /// Words from `lexicon` that rhyme with `target`, **perfect rhymes first**, then slant,
    /// alphabetical within each tier. Deterministic: the result does not depend on `lexicon`
    /// iteration order. (The previous version capped an *unordered* dictionary scan, so the
    /// same line could surface different "rhymes" each launch — and it never ranked perfect
    /// rhymes ahead of vowel-only assonance.) `excluding` drops the source word. Pure — unit-
    /// testable with a small synthetic lexicon, no CMUDICT needed.
    static func rankedRhymes(target: [String], lexicon: [String: [String]], excluding: String, limit: Int) -> [String] {
        guard phoneticSignature(from: target) != nil else { return [] }
        var perfect: [String] = [], slant: [String] = []
        for (word, phonemes) in lexicon where word != excluding {
            switch rhymeStrength(of: phonemes, against: target) {
            case 2: perfect.append(word)
            case 1: slant.append(word)
            default: break
            }
        }
        return Array((perfect.sorted() + slant.sorted()).prefix(limit))
    }

    // MARK: - Private helpers

    /// CMUDICT-backed rhyme lookup. Perfect-first + deterministic via `rankedRhymes`.
    private static func rhymeCandidates(for word: String, limit: Int = 12) -> [String] {
        let key = word.lowercased()
        let dict = getGlobalCMUDICTStore()
        guard let target = dict[key] else { return [] }
        return rankedRhymes(target: target, lexicon: dict, excluding: key, limit: limit)
    }

    // MARK: - Live ghost: pooled + rotating rhymes (responsive, fresh options each line)

    /// Ordered rhyme pool for a line's end word (perfect rhymes first, then slant, alphabetical) —
    /// larger than the displayed window so the live path can rotate through fresh options.
    static func freeRhymePool(forLastLine line: String, limit: Int = 30) -> [String] {
        guard let end = endWord(of: line) else { return [] }
        return rhymeCandidates(for: end, limit: limit)
    }

    /// Stable key for the rhyme FAMILY of a line's end word. The live path keeps the SAME pool while
    /// this key is unchanged (a run of rhyming lines) — no CMUDICT re-scan, so it stays responsive —
    /// and re-scans only when the rhyme group changes.
    static func rhymeKey(forLastLine line: String) -> String? {
        guard let end = endWord(of: line),
              let phonemes = getGlobalCMUDICTStore()[end],
              let sig = phoneticSignature(from: phonemes) else { return nil }
        return sig.stressedVowel + "|" + sig.coda.joined(separator: " ")
    }

    /// `count` options from `pool`, advanced by `rotation` (pages by `count`, wraps) — so each
    /// Enter/indent surfaces fresh words from the same rhyme group.
    static func window(_ pool: [String], rotation: Int, count: Int = 3) -> [String] {
        guard !pool.isEmpty else { return [] }
        let n = pool.count
        let start = ((rotation * count) % n + n) % n
        return (0..<min(count, n)).map { pool[(start + $0) % n] }
    }

    private struct PhoneticSig {
        let stressedVowel: String
        let coda: [String]
    }

    /// The rhyme is anchored on the last **stressed** vowel (CMUDICT stress marker `1` or `2`);
    /// everything after it is the coda. CMUDICT marks EVERY vowel with a stress digit (0/1/2), so
    /// matching the last *digit-bearing* phoneme would grab an unstressed final vowel — e.g.
    /// "crazy" `K R EY1 Z IY0` → `IY0` with an empty coda — collapsing the rhyme key to a bare
    /// "-y" that "rhymes" with thousands of words (abbe, abadi…). Fall back to the last vowel of
    /// any stress only when no stressed vowel exists (rare; all-unstressed function words).
    /// (The canonical `extractSignature`, RapAnalysisEngine.swift:108, has the same latent pattern;
    /// corrected here because the Ghost scans the whole dictionary, where it surfaces.)
    private static func phoneticSignature(from phonemes: [String]) -> PhoneticSig? {
        let stressed = phonemes.lastIndex { $0.last == "1" || $0.last == "2" }
        guard let idx = stressed ?? phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
            return nil
        }
        return PhoneticSig(
            stressedVowel: phonemes[idx],
            coda: Array(phonemes.dropFirst(idx + 1))
        )
    }
}
