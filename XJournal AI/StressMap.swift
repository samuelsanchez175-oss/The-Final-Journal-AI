//
//  StressMap.swift
//  XJournal AI
//
//  Stress-emphasis spans for the "Stack" view (Rap Suggestions redesign, spec §3.7).
//  Reuses the app's rap-slang-aware engines — `SyllableEngine` for syllable splitting
//  and `RapSlangPhonemes ?? CMU` for stress (the same sources as `StressMapBuilder`) —
//  so emphasis matches how the rest of the app reads stress. The whole line is tiled
//  (words AND separators) so `spans(for:).map(\.text).joined() == line`.
//

import Foundation

/// One contiguous run of a lyric line, flagged stressed or not.
struct SyllableSpan: Equatable {
    let text: String
    let isStressed: Bool
}

enum StressMap {
    /// Whole-line spans for stress-emphasis rendering. Separators (spaces, punctuation)
    /// are emitted as unstressed spans so the line reassembles exactly.
    static func spans(for line: String) -> [SyllableSpan] {
        guard !line.isEmpty else { return [] }

        var result: [SyllableSpan] = []
        var token = ""
        var separator = ""

        func isWordChar(_ c: Character) -> Bool { c.isLetter || c == "'" }

        func flushSeparator() {
            guard !separator.isEmpty else { return }
            result.append(SyllableSpan(text: separator, isStressed: false))
            separator = ""
        }

        func flushWord() {
            guard !token.isEmpty else { return }
            defer { token = "" }

            // Canonical, rap-slang-aware syllable split. Guarantee exact reassembly:
            // if the engine ever drops/adds characters, fall back to the whole word.
            var sylls = SyllableEngine.syllables(word: token)
            if sylls.isEmpty || sylls.joined() != token {
                sylls = [token]
            }

            let stressed = primaryStressIndices(for: token)
            if sylls.count <= 1 {
                result.append(SyllableSpan(text: token, isStressed: !stressed.isEmpty))
                return
            }
            for (i, syl) in sylls.enumerated() {
                result.append(SyllableSpan(text: syl, isStressed: stressed.contains(i)))
            }
        }

        for c in line {
            if isWordChar(c) {
                flushSeparator()
                token.append(c)
            } else {
                flushWord()
                separator.append(c)
            }
        }
        flushWord()
        flushSeparator()
        return result
    }

    /// Primary-stress syllable indices (phoneme trailing digit "1"), via rap-slang then CMU
    /// — the same phoneme sources `StressMapBuilder` uses. Out-of-dictionary words emphasize
    /// their first syllable; in-dictionary words with no primary stress (e.g. "the") stay
    /// light, which keeps display contrast.
    private static func primaryStressIndices(for word: String) -> Set<Int> {
        let lower = word.lowercased()
        guard let phonemes = RapSlangPhonemes.phonemes(for: lower) ?? getGlobalCMUDICTStore()[lower] else {
            return [0] // out-of-dictionary → emphasize the first syllable
        }
        var indices = Set<Int>()
        var syllable = 0
        for p in phonemes {
            if let last = p.last, last.isNumber {
                if last == "1" { indices.insert(syllable) }
                syllable += 1
            }
        }
        return indices
    }
}
