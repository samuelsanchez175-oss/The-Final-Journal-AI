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
        clusters.append(contentsOf: internalClusters(in: words))
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

    private struct RhymeUnit {
        let label: String
        let signature: RhymeHighlighterEngine.PhoneticSignature
        let sourceWord: String
        let isSlice: Bool
    }

    /// Internal clusters use the highlighter score and stressed slices.
    /// "mattress" joins on "mat" (AE1), not the final schwa. End rhyme stays on stressedVowelAndCoda.
    private static func internalClusters(in words: [String]) -> [RhymeCluster] {
        let content = words.filter { !RhymeHighlighterEngine.rhymeStopwords.contains($0) }
        var units: [RhymeUnit] = []
        for word in content {
            guard let phones = RhymeHighlighterEngine.dictionaryPhonemes(for: word),
                  let signature = RhymeHighlighterEngine.extractSignature(from: phones) else { continue }
            units.append(RhymeUnit(label: word, signature: signature, sourceWord: word, isSlice: false))
            for slice in RhymeHighlighterEngine.syllableSlices(of: word) where slice.stress >= 1 && !slice.coversWholeWord {
                units.append(RhymeUnit(
                    label: slice.spelling,
                    signature: slice.signature,
                    sourceWord: word,
                    isSlice: true
                ))
            }
        }
        guard units.count >= 2 else { return [] }

        var parent = Array(units.indices)
        func find(_ index: Int) -> Int {
            var index = index
            while parent[index] != index {
                parent[index] = parent[parent[index]]
                index = parent[index]
            }
            return index
        }
        func unite(_ left: Int, _ right: Int) {
            let leftRoot = find(left)
            let rightRoot = find(right)
            if leftRoot != rightRoot { parent[rightRoot] = leftRoot }
        }
        for left in units.indices {
            for right in (left + 1)..<units.count {
                if units[left].sourceWord == units[right].sourceWord { continue }
                if RhymeHighlighterEngine.rhymeScore(units[left].signature, units[right].signature) != nil {
                    unite(left, right)
                }
            }
        }

        var members: [Int: [Int]] = [:]
        for index in units.indices {
            members[find(index), default: []].append(index)
        }
        var wholeWordsInClusters: Set<String> = []
        for group in members.values {
            let labels = Set(group.filter { !units[$0].isSlice }.map { units[$0].label })
            if labels.count >= 2 {
                wholeWordsInClusters.formUnion(labels)
            }
        }

        var clusters: [RhymeCluster] = []
        for group in members.values {
            var seen: Set<String> = []
            var labels: [String] = []
            for index in group {
                let unit = units[index]
                if unit.isSlice && wholeWordsInClusters.contains(unit.sourceWord) { continue }
                if seen.contains(unit.label) { continue }
                seen.insert(unit.label)
                labels.append(unit.label)
            }
            labels.sort()
            guard labels.count >= 2, labels.count <= 8 else { continue }
            clusters.append(RhymeCluster(
                type: "internal",
                parts: labels,
                density: Double(labels.count) / Double(words.count)
            ))
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
