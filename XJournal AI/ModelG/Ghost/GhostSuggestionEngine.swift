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

    func freeHint(forLastLine line: String) -> GhostHint? {
        guard let end = Self.endWord(of: line) else { return nil }
        let phonetic = Self.rhymeCandidates(for: end)
        guard !phonetic.isEmpty else { return nil }

        // Promote on-brand words (corpus hit) to the front.
        let onBrand: [String] = retriever.map { r in
            phonetic.filter { w in
                !r.retrieve(theme: nil, draft: w, brands: [], k: 1).exemplars.isEmpty
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

    /// CMUDICT-backed rhyme lookup for the live engine. Perfect-first + deterministic via `rankedRhymes`.
    /// Caps at 12 so `freeHint`'s on-brand promotion runs a bounded number of corpus lookups.
    private static func rhymeCandidates(for word: String) -> [String] {
        let key = word.lowercased()
        let dict = getGlobalCMUDICTStore()
        guard let target = dict[key] else { return [] }
        return rankedRhymes(target: target, lexicon: dict, excluding: key, limit: 12)
    }

    private struct PhoneticSig {
        let stressedVowel: String
        let coda: [String]
    }

    /// Mirrors the canonical `extractSignature` (RapAnalysisEngine.swift:108): the last
    /// stress-marked vowel is the rhyme vowel; everything after it is the coda.
    private static func phoneticSignature(from phonemes: [String]) -> PhoneticSig? {
        guard let idx = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
            return nil
        }
        return PhoneticSig(
            stressedVowel: phonemes[idx],
            coda: Array(phonemes.dropFirst(idx + 1))
        )
    }
}
