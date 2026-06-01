//
//  RhymeClusterEngine.swift
//  XJournal AI
//
//  Detects end rhyme, internal rhyme, multisyllabic rhyme, vowel-family repetition.
//

import Foundation

enum RhymeClusterEngine {
    /// Analyze lines and return rhyme clusters (internal, end, vowel_family).
    static func detect(lines: [String]) -> [RhymeCluster] {
        let words = lines.flatMap { line in
            line.split(separator: " ").map { String($0).trimmingCharacters(in: .punctuationCharacters).lowercased() }.filter { $0.count > 1 }
        }
        guard words.count >= 2 else { return [] }
        var clusters: [RhymeCluster] = []
        var keyToWords: [String: [String]] = [:]
        for w in words {
            guard let sig = stressedVowelAndCoda(for: w) else { continue }
            let key = "\(sig.vowel)-\(sig.coda.joined(separator: "-"))"
            keyToWords[key, default: []].append(w)
        }
        for (_, group) in keyToWords where group.count >= 2 {
            let parts = Array(Set(group)).sorted()
            let density = Double(parts.count) / Double(words.count)
            if parts.count >= 2 && parts.count <= 8 {
                clusters.append(RhymeCluster(type: "internal", parts: parts, density: density))
            }
        }
        let lastWords: [String] = lines.compactMap { line in
            guard let last = line.split(separator: " ").last else { return nil }
            let w = String(last).trimmingCharacters(in: .punctuationCharacters).lowercased()
            return w.count > 1 ? w : nil
        }
        if lastWords.count >= 2 {
            var endGroups: [String: [String]] = [:]
            for w in lastWords {
                guard let sig = stressedVowelAndCoda(for: w) else { continue }
                endGroups[sig.vowel, default: []].append(w)
            }
            for (_, group) in endGroups where group.count >= 2 {
                let parts = Array(Set(group)).sorted()
                clusters.append(RhymeCluster(type: "end", parts: parts, density: Double(parts.count) / Double(max(1, lastWords.count))))
            }
        }
        let vowelFamily = vowelFamilyCluster(words: words)
        if !vowelFamily.parts.isEmpty {
            clusters.append(vowelFamily)
        }
        return clusters
    }

    private static func stressedVowelAndCoda(for word: String) -> (vowel: String, coda: [String])? {
        let lower = word.lowercased()
        let phonemes: [String]? = RapSlangPhonemes.phonemes(for: lower) ?? getGlobalCMUDICTStore()[lower]
        guard let phonemes = phonemes,
              let idx = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else { return nil }
        let vowel = phonemes[idx]
        let coda = Array(phonemes.dropFirst(idx + 1))
        return (vowel, coda)
    }

    private static func vowelFamilyCluster(words: [String]) -> RhymeCluster {
        var byVowel: [String: [String]] = [:]
        for w in words {
            guard let sig = stressedVowelAndCoda(for: w) else { continue }
            let base = String(sig.vowel.dropLast())
            byVowel[base, default: []].append(w)
        }
        guard let best = byVowel.max(by: { $0.value.count < $1.value.count }),
              best.value.count >= 2 else {
            return RhymeCluster(type: "vowel_family", parts: [], density: nil)
        }
        let parts = Array(Set(best.value)).sorted()
        return RhymeCluster(type: "vowel_family", parts: parts, density: Double(parts.count) / Double(words.count))
    }
}
