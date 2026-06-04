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

    // MARK: - Private helpers

    /// Returns words in the global CMUDICT that rhyme (perfect or near) with `word`.
    /// Replicates the same lookup used by `RhymeSuggestionView` (file-private helpers
    /// there; re-implemented here to keep engine self-contained):
    ///   1. `getGlobalCMUDICTStore()` → `[String: [String]]`  (FJCMUDICTStore.swift:15)
    ///   2. Extract last-stressed-vowel index + trailing coda from the phoneme array.
    ///   3. Match on stressedVowel equality (= perfect/near; coda may differ).
    private static func rhymeCandidates(for word: String) -> [String] {
        let dict = getGlobalCMUDICTStore()
        guard let targetPhonemes = dict[word.lowercased()],
              let targetSig = phoneticSignature(from: targetPhonemes) else { return [] }

        var results: [String] = []
        for (dictWord, wordPhonemes) in dict {
            guard dictWord.lowercased() != word.lowercased() else { continue }
            guard let sig = phoneticSignature(from: wordPhonemes) else { continue }
            // Match on stressed vowel (perfect = same vowel + coda; near = same vowel only).
            if sig.stressedVowel == targetSig.stressedVowel {
                results.append(dictWord)
            }
            if results.count >= 120 { break } // cap scan for performance
        }
        return results.sorted()
    }

    private struct PhoneticSig {
        let stressedVowel: String
        let coda: [String]
    }

    /// Mirrors the private `extractSignature` in `RhymeSuggestionView.swift:18`.
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
