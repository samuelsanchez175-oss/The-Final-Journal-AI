import Foundation
import NaturalLanguage
import UIKit
import Combine

// MARK: - Rhyme Highlighter Engine
// File: ContentView.CCV.3.swift
// Dependencies: CCV.1 (FJCMUDICTStore), CCV.2 (RhymeColorPalette)
// Used by: CCV.6 (RhymeHighlightTextView), ContentView.swift
// Note: Highlight struct is defined here (depends on RhymeHighlighterEngine types)

struct RhymeHighlighterEngine {
    enum RhymeStrength: Double {
        case perfect = 1.0
        case near = 0.75
        case slant = 0.55
    }
    
    enum RhymeType {
        case endRhyme
        case internalRhyme
        case alliteration
        case assonance
    }

    struct PhoneticSignature {
        let stressedVowel: String
        let coda: [String]
    }

    struct RhymeGroup: Identifiable {
        let id: UUID
        let key: String
        let strength: RhymeStrength
        let colorIndex: Int
        let words: [RhymeGroupWord]
        let rhymeType: RhymeType
    }

    struct RhymeGroupWord: Identifiable {
        let id = UUID()
        let word: String
        let range: Range<String.Index>
        let lineIndex: Int
        let positionInLine: Int
        let isLineEnd: Bool
    }

    nonisolated static func extractSignature(from phonemes: [String]) -> PhoneticSignature? {
        guard let idx = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
            return nil
        }
        let vowel = phonemes[idx]
        let coda = Array(phonemes.dropFirst(idx + 1))
        return PhoneticSignature(stressedVowel: vowel, coda: coda)
    }
    
    private static func baseVowelSound(_ vowel: String) -> String {
        return String(vowel.dropLast())
    }
    
    private static func areVowelsSimilar(_ vowelA: String, _ vowelB: String) -> Bool {
        let baseA = baseVowelSound(vowelA)
        let baseB = baseVowelSound(vowelB)
        
        if baseA == baseB {
            return true
        }
        
        let similarVowelGroups: [Set<String>] = [
            ["AY", "EY"],
            ["OW", "AW", "AO"],
            ["IY", "IH"],
            ["UW", "UH"],
            ["AE", "EH"],
            ["ER", "AH"],
            ["OY", "OW"],
            ["AY", "IH"]
        ]
        
        for group in similarVowelGroups {
            if group.contains(baseA) && group.contains(baseB) {
                return true
            }
        }
        
        return false
    }
    
    private static func areCodasSimilar(_ codaA: [String], _ codaB: [String]) -> Bool {
        if codaA == codaB {
            return true
        }
        
        if codaA.isEmpty != codaB.isEmpty {
            return false
        }
        
        if codaA.isEmpty && codaB.isEmpty {
            return true
        }
        
        if codaA.count == codaB.count {
            let matchingCount = zip(codaA, codaB).filter { $0.0 == $0.1 }.count
            return Double(matchingCount) / Double(codaA.count) >= 0.5
        }
        
        if let lastA = codaA.last, let lastB = codaB.last {
            if lastA == lastB {
                return true
            }
        }
        
        return false
    }

    nonisolated static func rhymeScore(_ a: PhoneticSignature, _ b: PhoneticSignature) -> RhymeStrength? {
        if a.stressedVowel == b.stressedVowel && a.coda == b.coda {
            return .perfect
        }
        
        if a.stressedVowel == b.stressedVowel {
            return .near
        }
        
        if areVowelsSimilar(a.stressedVowel, b.stressedVowel) {
            if areCodasSimilar(a.coda, b.coda) {
                return .slant
            }
            return .slant
        }
        
        return nil
    }

    nonisolated static func computeGroups(text: String) async -> [RhymeGroup] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text

        var tokens: [(String, Range<String.Index>)] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokens.append((String(text[range]).lowercased(), range))
            return true
        }

        let dict = await MainActor.run { FJCMUDICTStore.shared.phonemesByWord }
        var buckets: [String: [(RhymeGroupWord, PhoneticSignature)]] = [:]

        for (word, range) in tokens {
            guard
                let phonemes = dict[word],
                let sig = extractSignature(from: phonemes)
            else { continue }

            buckets[sig.stressedVowel, default: []]
                .append((RhymeGroupWord(word: word, range: range, lineIndex: 0, positionInLine: 0, isLineEnd: false), sig))
        }

        var result: [RhymeGroup] = []

        for (key, entries) in buckets where entries.count > 1 {
            let signatures = entries.map { $0.1 }
            let base = signatures[0]

            let scores = await MainActor.run {
                entries.map { rhymeScore(base, $0.1) }
            }
            let strength: RhymeStrength = scores.allSatisfy { $0 == .perfect } ? .perfect : .near

            let colorIndex = await MainActor.run { abs(key.hashValue) % RhymeColorPalette.colors.count }

            let words = entries.map { $0.0 }
            result.append(
                RhymeGroup(
                    id: UUID(),
                    key: key,
                    strength: strength,
                    colorIndex: colorIndex,
                    words: words,
                    rhymeType: .endRhyme
                )
            )
        }

        return result
    }
    
    nonisolated static func computeAll(text: String) async -> ([RhymeGroup], [Highlight]) {
        let groups = await computeGroups(text: text)
        var highlights: [Highlight] = []
        for group in groups {
            for wordInfo in group.words {
                highlights.append(
                    Highlight(
                        range: wordInfo.range,
                        colorIndex: group.colorIndex,
                        strength: group.strength,
                        rhymeType: group.rhymeType
                    )
                )
            }
        }
        return (groups, highlights)
    }
    
    nonisolated static func computeGroupsIncremental(text: String, signatureCache: [String: PhoneticSignature]) -> ([RhymeGroup], [Highlight]) {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        
        var tokens: [(String, Range<String.Index>)] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokens.append((String(text[range]).lowercased(), range))
            return true
        }
        
        var buckets: [String: [(RhymeGroupWord, PhoneticSignature)]] = [:]
        
        for (word, range) in tokens {
            guard let sig = signatureCache[word] else { continue }
            buckets[sig.stressedVowel, default: []]
                .append((RhymeGroupWord(word: word, range: range, lineIndex: 0, positionInLine: 0, isLineEnd: false), sig))
        }
        
        // Cache colors count to avoid main actor access
        let colorsCount = 6 // RhymeColorPalette.colors.count (hardcoded to avoid main actor isolation)
        
        var result: [RhymeGroup] = []
        
        for (key, entries) in buckets where entries.count > 1 {
            let signatures = entries.map { $0.1 }
            let base = signatures[0]
            
            // Check if all entries are perfect rhymes
            var allPerfect = true
            for entry in entries {
                let score = rhymeScore(base, entry.1)
                if score != .perfect {
                    allPerfect = false
                    break
                }
            }
            let strength: RhymeStrength = allPerfect ? .perfect : .near

            let colorIndex = abs(key.hashValue) % colorsCount
            
            let words = entries.map { $0.0 }
            result.append(
                RhymeGroup(
                    id: UUID(),
                    key: key,
                    strength: strength,
                    colorIndex: colorIndex,
                    words: words,
                    rhymeType: .endRhyme
                )
            )
        }
        
        var highlights: [Highlight] = []
        for group in result {
            for wordInfo in group.words {
                highlights.append(
                    Highlight(
                        range: wordInfo.range,
                        colorIndex: group.colorIndex,
                        strength: group.strength,
                        rhymeType: group.rhymeType
                    )
                )
            }
        }
        
        return (result, highlights)
    }
}

// MARK: - Highlight

struct Highlight: Equatable {
    let range: Range<String.Index>
    let colorIndex: Int
    let strength: RhymeHighlighterEngine.RhymeStrength
    let rhymeType: RhymeHighlighterEngine.RhymeType
}

// MARK: - Rhyme Engine State

@MainActor
final class RhymeEngineState: ObservableObject {
    @Published var cachedGroups: [RhymeHighlighterEngine.RhymeGroup] = []
    @Published var cachedHighlights: [Highlight] = []
    private var lastTextHash: Int?
    private var lastText: String = ""
    
    private var wordSignatureCache: [String: RhymeHighlighterEngine.PhoneticSignature] = [:]
    
    private var debounceTask: Task<Void, Never>? = nil
    private let debounceDelay: TimeInterval = 0.4
    
    init() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                self?.clearCaches()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func clearCaches() {
        wordSignatureCache.removeAll(keepingCapacity: false)
        print("⚠️ RhymeEngineState: Caches cleared due to memory warning")
    }

    func updateIfNeeded(text: String) {
        let hash = text.hashValue
        
        guard hash != lastTextHash else { return }
        
        debounceTask?.cancel()
        
        let textToAnalyze = text
        let _ = lastText
        
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: textToAnalyze)
            
            self.cachedGroups = groups
            self.cachedHighlights = highlights
            self.lastTextHash = hash
            self.lastText = textToAnalyze
        }
    }
}
