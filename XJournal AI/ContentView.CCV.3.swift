import Foundation
import NaturalLanguage
import UIKit
import Combine

// MARK: - Rhyme Highlighter Engine
// File: ContentView.CCV.3.swift
// Dependencies: CCV.1 (FJCMUDICTStore), CCV.2 (RhymeColorPalette)
// Used by: CCV.6 (RhymeHighlightTextView), ContentView.swift
// Note: Highlight struct is defined here (depends on RhymeHighlighterEngine types)

nonisolated struct RhymeHighlighterEngine {
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
        /// Line that popped on Genius (Reminds me of). Painted green, not a rhyme family.
        case geniusEcho
        /// Hold-a-gutter-count pulse: whole line yellow.
        case holdPulseYellow
        /// Hold-a-word pulse: end-rhyme word green before Suggest Rhymes opens.
        case holdPulseGreen
    }

    /// Tiny function words must not paint a rhyme group. "a" is AH0, not a rime with silent.
    nonisolated static let rhymeStopwords: Set<String> = [
        "a", "an", "the", "of", "to", "in", "on", "and", "or", "but", "for", "with", "at", "by",
        "as", "is", "it", "be", "we", "my", "me", "you", "i", "im", "i'm", "so", "if", "do", "no"
    ]

    struct PhoneticSignature {
        let stressedVowel: String
        let coda: [String]

        /// Onset ignored. `AY|D` vs `IH|K` — silent/tick do not share this.
        nonisolated var rimeKey: String {
            let v = String(stressedVowel.filter { !$0.isNumber })
            if coda.isEmpty { return v }
            return v + "|" + coda.joined(separator: "-")
        }

        /// Stable phonetic rhyme-class id used for color locking across notes/relaunches.
        nonisolated var rhymeClassId: String { rimeKey }
    }

    /// Forced end-rhyme slant family. `blink` must NOT join `shit`.
    /// militant / idiot / immigrant / commits / script / shit share one end group.
    nonisolated static let lockedSlantEndFamily: Set<String> = [
        "militant", "idiot", "immigrant", "commits", "script", "shit"
    ]

    /// Words that share IH with shit's vowel but must stay out of the locked shit family.
    /// NG+K (blink/think) is a velar nasal cluster, not an alveolar stop.
    nonisolated static let lockedSlantEndFamilyExclusions: Set<String> = [
        "blink", "think", "pink", "link", "sink", "drink", "ink"
    ]

    /// Stable class for IH + alveolar stop (T/D) landings, including trailing S/Z (commits).
    nonisolated static let ihAlveolarStopClassId = "IH|ALVSTOP"

    /// Feminine -y near family (`dummy`/`money`, `pretty`/`chelly`). Vowel still matters —
    /// `crazy` (EY) must not glue to `abbe` (AE) just because both end in unstressed IY.
    nonisolated static let feminineYClassSuffix = "|Y"

    /// Labial/velar stop near family (`hip`/`dick`/`clips`). T/D stay on `ihAlveolarStopClassId`.
    nonisolated static let labialVelarStopClassSuffix = "|STOP-PBGK"

    private static let vowelPhones: Set<String> = [
        "AA", "AE", "AH", "AO", "AW", "AY", "EH", "ER", "EY", "IH", "IY", "OW", "OY", "UH", "UW"
    ]
    private static let labialVelarStops: Set<String> = ["P", "B", "K", "G"]
    /// Voiceless pairs that still lock in rap (`cheat`/`reach`, `teach`/`beach`).
    private static let similarCodaPairs: [Set<String>] = [
        ["T", "CH"], ["D", "JH"], ["S", "SH"], ["Z", "ZH"], ["T", "S"], ["D", "Z"]
    ]

    /// IY/IH + T or CH — `cheat`/`reach`/`teach` share a pocket.
    nonisolated static func tchFamilyKey(for signature: PhoneticSignature) -> String? {
        let v = String(signature.stressedVowel.filter { !$0.isNumber })
        guard v == "IY" || v == "IH" else { return nil }
        let last = lastConsonant(of: signature)
        guard last == "T" || last == "CH" else { return nil }
        return v + "|TCH"
    }

    /// Map a word into its end-group bucket key. Locked slant family collapses to one id.
    /// Line-end landings on T/D (militant / idiot / immigrant / commits / script / shit)
    /// share one paint family. `blink`/`think` land on K and stay out.
    /// Near rhymes that share a vowel family + feminine -y, or the same vowel + P/B/K/G,
    /// paint together even when the exact coda phones differ.
    nonisolated static func endGroupKey(
        for word: String,
        signature: PhoneticSignature,
        isLineEnd: Bool = false
    ) -> String {
        let w = word.lowercased()
        if lockedSlantEndFamilyExclusions.contains(w) {
            return signature.rhymeClassId
        }
        if lockedSlantEndFamily.contains(w) {
            return ihAlveolarStopClassId
        }
        // Feminine -y before alveolar-stop: `pretty` (IH T IY0) would otherwise join `shit`.
        if let yKey = feminineYFamilyKey(for: signature) {
            return yKey
        }
        // `cheat`/`reach`/`teach` (IY + T/CH) — not the locked militant/shit T-D bucket.
        if let tch = tchFamilyKey(for: signature) {
            return tch
        }
        // Locked T/D family is a line-end landing, not every mid-bar IY+T (`cheat` ≠ `mount`).
        if isLineEnd, isIHAlveolarStopFamily(signature) {
            return ihAlveolarStopClassId
        }
        if isLineEnd, isAlveolarStopLanding(signature) {
            return ihAlveolarStopClassId
        }
        if let stopKey = stopCodaFamilyKey(for: signature) {
            return stopKey
        }
        return signature.rhymeClassId
    }

    /// Strip stress digits and trailing plural/3sg S/Z so `clips` matches `clip`/`hip`.
    nonisolated static func strippedCoda(_ coda: [String]) -> [String] {
        var phones = coda.map { String($0.filter { !$0.isNumber }) }
        while let last = phones.last, last == "S" || last == "Z" {
            phones.removeLast()
        }
        return phones
    }

    /// `pretty`/`chelly` share IH-EH; `dummy`/`money` share AH. Trailing unstressed IY required.
    nonisolated static func feminineYFamilyKey(for signature: PhoneticSignature) -> String? {
        let coda = strippedCoda(signature.coda)
        guard coda.last == "IY" else { return nil }
        return feminineVowelFamily(signature.stressedVowel) + feminineYClassSuffix
    }

    nonisolated static func feminineVowelFamily(_ vowel: String) -> String {
        let v = String(vowel.filter { !$0.isNumber })
        if v == "IH" || v == "EH" { return "IH-EH" }
        return v
    }

    /// Same stressed vowel + a single P/B/K/G (after stripping S). NG+K (`blink`) stays out.
    nonisolated static func stopCodaFamilyKey(for signature: PhoneticSignature) -> String? {
        let coda = strippedCoda(signature.coda)
        guard !coda.contains("NG") else { return nil }
        let consonants = coda.filter { !vowelPhones.contains($0) }
        guard consonants.count == 1, let stop = consonants.first, labialVelarStops.contains(stop) else {
            return nil
        }
        let v = String(signature.stressedVowel.filter { !$0.isNumber })
        return v + labialVelarStopClassSuffix
    }

    nonisolated static func lastConsonant(of signature: PhoneticSignature) -> String? {
        let coda = signature.coda.map { String($0.filter { !$0.isNumber }) }
        let vowels: Set<String> = [
            "AA", "AE", "AH", "AO", "AW", "AY", "EH", "ER", "EY", "IH", "IY", "OW", "OY", "UH", "UW"
        ]
        for phone in coda.reversed() {
            if phone == "S" || phone == "Z" { continue }
            if vowels.contains(phone) { continue }
            if phone.isEmpty { continue }
            return phone
        }
        return nil
    }

    nonisolated static func isAlveolarStopLanding(_ signature: PhoneticSignature) -> Bool {
        let c = lastConsonant(of: signature)
        return c == "T" || c == "D"
    }

    /// IH nucleus + last consonant T/D (skip trailing S/Z). blink's last C is K — excluded.
    nonisolated static func isIHAlveolarStopFamily(_ signature: PhoneticSignature) -> Bool {
        let vowel = String(signature.stressedVowel.filter { !$0.isNumber })
        // idiot's last stress is IY2; still an IH-family slant into /t/.
        guard vowel == "IH" || vowel == "IY" else { return false }
        return isAlveolarStopLanding(signature)
    }

    /// A digit is said as its English name. "8" is eight, so it can rhyme with hate.
    nonisolated static func keepsRhymeToken(_ word: String) -> Bool {
        if rhymeStopwords.contains(word) { return false }
        if word.allSatisfy(\.isNumber) { return !word.isEmpty }
        return word.count >= 2
    }

    /// Spell a digit string into dictionary words. "8" → eight, "21" → twenty one.
    nonisolated static func spokenDigitWords(_ word: String) -> [String]? {
        guard !word.isEmpty, word.allSatisfy(\.isNumber) else { return nil }
        let ones = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
        if word.count == 1, let n = Int(word), (0...9).contains(n) {
            return [ones[n]]
        }
        guard let n = Int(word) else { return nil }
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .spellOut
        guard let spoken = formatter.string(from: NSNumber(value: n)) else { return nil }
        let parts = spoken.lowercased().split { !$0.isLetter }.map(String.init).filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts
    }

    nonisolated static func phonemes(for word: String) -> [String]? {
        let w = word.lowercased()
        if let spoken = spokenDigitWords(w) {
            var phones: [String] = []
            for part in spoken {
                guard let next = phonemes(for: part), !next.isEmpty else { return nil }
                phones.append(contentsOf: next)
            }
            return phones
        }
        if lockedSlantEndFamily.contains(w) {
            if let slang = RapSlangPhonemes.phonemes(for: w), !slang.isEmpty { return slang }
        }
        if let p = getGlobalCMUDICTStore()[w], !p.isEmpty { return p }
        if let p = FJCMUDICTStore.shared.phonemesByWord[w], !p.isEmpty { return p }
        if let p = RapSlangPhonemes.phonemes(for: w), !p.isEmpty { return p }
        if let p = RapSlangPhonemes.heuristicPhonemes(for: w), !p.isEmpty { return p }
        if lockedSlantEndFamily.contains(w) {
            return ["IH1", "T"]
        }
        return nil
    }

    /// Color key = phonetic rhyme class id (NOT first-appearance order).
    /// phone/tone/alone/microphone (`OW|N`) always emerald (palette index 2).
    nonisolated static func colorIndex(forRhymeClass key: String, paletteCount: Int = 6) -> Int {
        let count = max(paletteCount, 1)
        let parts = key.split(separator: "|", maxSplits: 1).map(String.init)
        let vowel = parts.first ?? key
        let coda = parts.count > 1 ? parts[1] : ""
        // Open-O + N family — phone / tone / alone / microphone
        if vowel == "OW" && (coda == "N" || coda.hasPrefix("N")) {
            return 2 % count
        }
        if key == ihAlveolarStopClassId || key.hasPrefix("LOCKED_SLANT") {
            return 1 % count
        }
        var hash = 5381
        for byte in key.utf8 {
            hash = ((hash << 5) &+ hash) &+ Int(byte)
        }
        return abs(hash) % count
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

    /// Content token with signature + line metadata. Shared by full and incremental grouping.
    struct AnnotatedToken {
        let word: String
        let range: Range<String.Index>
        let lineIndex: Int
        let positionInLine: Int
        let isLineEnd: Bool
        let signature: PhoneticSignature
    }

    /// Last *primary* stress (1 or 2), not a trailing schwa. "silent" is AY, not AH0 — so "a" does not join it.
    nonisolated static func extractSignature(from phonemes: [String]) -> PhoneticSignature? {
        guard let idx = phonemes.lastIndex(where: { $0.last == "1" || $0.last == "2" }) else {
            return nil
        }
        let vowel = phonemes[idx]
        let coda = Array(phonemes.dropFirst(idx + 1))
        return PhoneticSignature(stressedVowel: vowel, coda: coda)
    }
    
    nonisolated private static func baseVowelSound(_ vowel: String) -> String {
        return String(vowel.dropLast())
    }
    
    nonisolated private static func areVowelsSimilar(_ vowelA: String, _ vowelB: String) -> Bool {
        let baseA = baseVowelSound(vowelA)
        let baseB = baseVowelSound(vowelB)
        
        if baseA == baseB {
            return true
        }
        
        let similarVowelGroups: [Set<String>] = [
            ["AY", "EY"],
            ["OW", "AW", "AO"],
            ["IY", "IH"],
            ["IH", "EH"],
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
    
    nonisolated private static func areCodasSimilar(_ codaA: [String], _ codaB: [String]) -> Bool {
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
            if Double(matchingCount) / Double(codaA.count) >= 0.5 {
                return true
            }
        }

        let lastA = strippedCoda(codaA).last
        let lastB = strippedCoda(codaB).last
        if let lastA, let lastB {
            if lastA == lastB { return true }
            let pair: Set<String> = [lastA, lastB]
            if similarCodaPairs.contains(where: { $0 == pair }) { return true }
        }
        
        return false
    }

    /// Same vowel, and one coda is the other plus a consonant tail.
    /// `girl` (L) rhymes with `world` (L D). An extra vowel is a new syllable
    /// (`man` / `manage`) and stays dark. An empty coda is assonance (`go` / `goat`), not this rhyme.
    nonisolated static func consonantTailExtends(_ a: [String], _ b: [String]) -> Bool {
        let left = a.map { String($0.filter { !$0.isNumber }) }
        let right = b.map { String($0.filter { !$0.isNumber }) }
        let short = left.count <= right.count ? left : right
        let long = left.count <= right.count ? right : left
        guard short.count >= 1, long.count > short.count else { return false }
        guard Array(long.prefix(short.count)) == short else { return false }
        return long.dropFirst(short.count).allSatisfy { !vowelPhones.contains($0) }
    }

    nonisolated static func rhymeScore(_ a: PhoneticSignature, _ b: PhoneticSignature) -> RhymeStrength? {
        if a.stressedVowel == b.stressedVowel && a.coda == b.coda {
            return .perfect
        }
        if a.stressedVowel == b.stressedVowel && areCodasSimilar(a.coda, b.coda) {
            return .near
        }
        let vowelA = String(a.stressedVowel.filter { !$0.isNumber })
        let vowelB = String(b.stressedVowel.filter { !$0.isNumber })
        if vowelA == vowelB && consonantTailExtends(a.coda, b.coda) {
            return .near
        }
        if areVowelsSimilar(a.stressedVowel, b.stressedVowel) && a.coda == b.coda {
            return .slant
        }
        if areVowelsSimilar(a.stressedVowel, b.stressedVowel) && areCodasSimilar(a.coda, b.coda) {
            return .slant
        }
        return nil
    }

    /// Words for rhyme paint. NLTokenizer skips the in-progress last word until a
    /// space/newline; append that trailing token so the eye colors as you type.
    nonisolated static func tokenizeWords(in text: String) -> [(String, Range<String.Index>)] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var tokens: [(String, Range<String.Index>)] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokens.append((String(text[range]).lowercased(), range))
            return true
        }
        mergeDigitTokens(in: text, into: &tokens)
        appendTrailingInProgressWord(in: text, to: &tokens)
        return tokens
    }

    /// NLTokenizer sometimes skips a lone digit. "8" still has to be a rhyme token.
    nonisolated static func mergeDigitTokens(
        in text: String,
        into tokens: inout [(String, Range<String.Index>)]
    ) {
        var i = text.startIndex
        var extra: [(String, Range<String.Index>)] = []
        while i < text.endIndex {
            if text[i].isNumber {
                let start = i
                while i < text.endIndex, text[i].isNumber {
                    i = text.index(after: i)
                }
                let range = start..<i
                let covered = tokens.contains { token in
                    token.1.overlaps(range) || token.1 == range
                }
                if !covered {
                    extra.append((String(text[range]), range))
                }
            } else {
                i = text.index(after: i)
            }
        }
        guard !extra.isEmpty else { return }
        tokens.append(contentsOf: extra)
        tokens.sort { $0.1.lowerBound < $1.1.lowerBound }
    }

    /// Last run of letters/digits/' if the body does not already end on a word break.
    nonisolated static func trailingInProgressWord(
        in text: String
    ) -> (String, Range<String.Index>)? {
        guard let last = text.last, !last.isWhitespace, !last.isNewline else { return nil }
        var start = text.endIndex
        while start > text.startIndex {
            let prev = text.index(before: start)
            let ch = text[prev]
            if ch.isLetter || ch.isNumber || ch == "'" || ch == "\u{2019}" {
                start = prev
            } else {
                break
            }
        }
        guard start < text.endIndex else { return nil }
        let word = String(text[start..<text.endIndex]).lowercased()
        guard keepsRhymeToken(word) else { return nil }
        return (word, start..<text.endIndex)
    }

    nonisolated static func appendTrailingInProgressWord(
        in text: String,
        to tokens: inout [(String, Range<String.Index>)]
    ) {
        guard let trailing = trailingInProgressWord(in: text) else { return }
        if let last = tokens.last {
            if last.1 == trailing.1 { return }
            if last.1.lowerBound == trailing.1.lowerBound {
                tokens[tokens.count - 1] = trailing
                return
            }
            if last.1.upperBound > trailing.1.lowerBound { return }
        }
        tokens.append(trailing)
    }

    /// Color the word currently being typed if it already belongs to a rhyme family.
    nonisolated static func liveTrailingHighlight(
        in text: String,
        existing: [Highlight],
        groups: [RhymeGroup]
    ) -> Highlight? {
        guard !groups.isEmpty, let (word, range) = trailingInProgressWord(in: text) else { return nil }
        guard !rhymeStopwords.contains(word) else { return nil }
        let utf16 = NSRange(range, in: text)
        if existing.contains(where: { NSIntersectionRange($0.utf16, utf16).length == utf16.length && utf16.length > 0 }) {
            return nil
        }
        func paint(_ group: RhymeGroup) -> Highlight {
            Highlight(
                range: range,
                in: text,
                colorIndex: group.colorIndex,
                strength: group.strength,
                rhymeType: group.rhymeType
            )
        }
        // "mone" has no dictionary vowel yet, but it is already the start of "money".
        func prefixGroup() -> RhymeGroup? {
            guard word.count >= 3 else { return nil }
            let hits = groups.filter { group in
                group.words.contains { $0.word.count > word.count && $0.word.hasPrefix(word) }
            }
            guard hits.count == 1 else { return nil }
            return hits[0]
        }
        guard let phonemes = phonemes(for: word), let sig = extractSignature(from: phonemes) else {
            return prefixGroup().map(paint)
        }
        let endKey = endGroupKey(for: word, signature: sig, isLineEnd: true)
        let internalKey = endGroupKey(for: word, signature: sig, isLineEnd: false)
        func matchingGroup(for key: String) -> RhymeGroup? {
            let matches = groups.filter { $0.key == key }
            return matches.first(where: { $0.rhymeType == .endRhyme }) ?? matches.first
        }
        if let group = matchingGroup(for: endKey)
            ?? (internalKey != endKey ? matchingGroup(for: internalKey) : nil) {
            return paint(group)
        }
        return prefixGroup().map(paint)
    }

    /// Paint the in-progress token as soon as it matches (or prefixes) a ghost-dock word.
    nonisolated static func liveGhostDockHighlight(
        in text: String,
        dock: [String],
        groups: [RhymeGroup],
        existing: [Highlight]
    ) -> Highlight? {
        guard let (token, range) = trailingInProgressWord(in: text), token.count >= 2 else { return nil }
        let lower = token.lowercased()
        let hitsDock = dock.contains { $0.caseInsensitiveCompare(token) == .orderedSame }
            || dock.contains { $0.lowercased().hasPrefix(lower) }
        guard hitsDock else { return nil }
        let utf16 = NSRange(range, in: text)
        if existing.contains(where: { NSIntersectionRange($0.utf16, utf16).length == utf16.length && utf16.length > 0 }) {
            return nil
        }
        if let full = liveTrailingHighlight(in: text, existing: existing, groups: groups) {
            return full
        }
        guard let group = groups.last(where: { $0.rhymeType == .endRhyme }) ?? groups.last else { return nil }
        return Highlight(
            range: range,
            in: text,
            colorIndex: group.colorIndex,
            strength: .near,
            rhymeType: group.rhymeType
        )
    }

    /// Content words with signatures, real `lineIndex` / `positionInLine`, and line-end flags.
    nonisolated static func annotatedTokens(
        in text: String,
        signatureCache: [String: PhoneticSignature] = [:]
    ) -> [AnnotatedToken] {
        let tokens = tokenizeWords(in: text)
        let lineEndIndices = lineEndTokenIndices(in: tokens, text: text)

        struct Pending {
            let word: String
            let range: Range<String.Index>
            let lineIndex: Int
            let isLineEnd: Bool
            let signature: PhoneticSignature
        }
        var pending: [Pending] = []
        pending.reserveCapacity(tokens.count)
        for (i, (word, range)) in tokens.enumerated() {
            guard keepsRhymeToken(word) else { continue }
            let sig = signatureCache[word] ?? phonemes(for: word).flatMap { extractSignature(from: $0) }
            guard let sig else { continue }
            let lineIndex = text[text.startIndex..<range.lowerBound].reduce(0) { $1 == "\n" ? $0 + 1 : $0 }
            pending.append(
                Pending(
                    word: word,
                    range: range,
                    lineIndex: lineIndex,
                    isLineEnd: lineEndIndices.contains(i),
                    signature: sig
                )
            )
        }

        var positionOnLine: [Int: Int] = [:]
        var result: [AnnotatedToken] = []
        result.reserveCapacity(pending.count)
        for p in pending {
            let pos = positionOnLine[p.lineIndex, default: 0]
            positionOnLine[p.lineIndex] = pos + 1
            result.append(
                AnnotatedToken(
                    word: p.word,
                    range: p.range,
                    lineIndex: p.lineIndex,
                    positionInLine: pos,
                    isLineEnd: p.isLineEnd,
                    signature: p.signature
                )
            )
        }
        return result
    }

    nonisolated static func makeRhymeGroup(
        key: String,
        entries: [(RhymeGroupWord, PhoneticSignature)],
        rhymeType: RhymeType
    ) -> RhymeGroup {
        let signatures = entries.map { $0.1 }
        let base = signatures[0]
        let scores = entries.map { rhymeScore(base, $0.1) }
        let strength: RhymeStrength = scores.allSatisfy { $0 == .perfect } ? .perfect : .near
        return RhymeGroup(
            id: UUID(),
            key: key,
            strength: strength,
            colorIndex: 0,
            words: entries.map(\.0),
            rhymeType: rhymeType
        )
    }

    nonisolated static func groupWord(from token: AnnotatedToken) -> RhymeGroupWord {
        RhymeGroupWord(
            word: token.word,
            range: token.range,
            lineIndex: token.lineIndex,
            positionInLine: token.positionInLine,
            isLineEnd: token.isLineEnd
        )
    }

    /// End rhymes from line-end landings. Internals from same-bar pairs, from mid words
    /// that share an end-group key, and from the same family across lines (`cheat` / `reach`).
    nonisolated static func groupsFromAnnotatedTokens(_ tokens: [AnnotatedToken]) -> [RhymeGroup] {
        struct Coord: Hashable {
            let lineIndex: Int
            let positionInLine: Int
        }
        func coord(_ token: AnnotatedToken) -> Coord {
            Coord(lineIndex: token.lineIndex, positionInLine: token.positionInLine)
        }

        var endBuckets: [String: [(RhymeGroupWord, PhoneticSignature)]] = [:]
        for token in tokens where token.isLineEnd {
            let key = endGroupKey(for: token.word, signature: token.signature, isLineEnd: true)
            endBuckets[key, default: []].append((groupWord(from: token), token.signature))
        }

        var result: [RhymeGroup] = []
        var endGroupKeys: Set<String> = []
        var endMemberCoords: Set<Coord> = []
        for (key, entries) in endBuckets {
            let distinctWordCount = Set(entries.map(\.0.word)).count
            guard distinctWordCount >= 2 || entries.count >= 2 else { continue }
            endGroupKeys.insert(key)
            for entry in entries {
                endMemberCoords.insert(Coord(lineIndex: entry.0.lineIndex, positionInLine: entry.0.positionInLine))
            }
            result.append(makeRhymeGroup(key: key, entries: entries, rhymeType: .endRhyme))
        }

        var indicesByLine: [Int: [Int]] = [:]
        for (i, token) in tokens.enumerated() {
            indicesByLine[token.lineIndex, default: []].append(i)
        }

        var parent = Array(tokens.indices)
        func find(_ x: Int) -> Int {
            var x = x
            while parent[x] != x { x = parent[x] }
            return x
        }
        func union(_ a: Int, _ b: Int) {
            let ra = find(a), rb = find(b)
            if ra != rb { parent[rb] = ra }
        }

        var hasSameLinePartner = Array(repeating: false, count: tokens.count)
        for idxs in indicesByLine.values {
            for i in 0..<idxs.count {
                for j in (i + 1)..<idxs.count {
                    let a = idxs[i], b = idxs[j]
                    if rhymeScore(tokens[a].signature, tokens[b].signature) != nil {
                        union(a, b)
                        hasSameLinePartner[a] = true
                        hasSameLinePartner[b] = true
                    }
                }
            }
        }

        func groupingKeys(for token: AnnotatedToken) -> [String] {
            let offEnd = endGroupKey(for: token.word, signature: token.signature, isLineEnd: false)
            guard token.isLineEnd else { return [offEnd] }
            let onEnd = endGroupKey(for: token.word, signature: token.signature, isLineEnd: true)
            return offEnd == onEnd ? [offEnd] : [offEnd, onEnd]
        }

        var internalBuckets: [String: [(RhymeGroupWord, PhoneticSignature)]] = [:]
        var internalCoords: Set<Coord> = []

        func addInternal(_ token: AnnotatedToken, key: String) {
            let c = coord(token)
            if endMemberCoords.contains(c) || internalCoords.contains(c) { return }
            internalCoords.insert(c)
            internalBuckets[key, default: []].append((groupWord(from: token), token.signature))
        }

        var componentMembers: [Int: [Int]] = [:]
        for i in tokens.indices where hasSameLinePartner[i] {
            componentMembers[find(i), default: []].append(i)
        }
        for members in componentMembers.values {
            let component = members.map { tokens[$0] }
            let keys = component.flatMap { groupingKeys(for: $0) }
            let key = keys.first(where: { endGroupKeys.contains($0) })
                ?? groupingKeys(for: component[0])[0]
            for token in component {
                addInternal(token, key: key)
            }
        }

        func offEndKey(_ token: AnnotatedToken) -> String {
            endGroupKey(for: token.word, signature: token.signature, isLineEnd: false)
        }

        for token in tokens {
            let c = coord(token)
            if endMemberCoords.contains(c) || internalCoords.contains(c) { continue }
            let key = offEndKey(token)
            if endGroupKeys.contains(key) || internalBuckets[key] != nil {
                addInternal(token, key: key)
            }
        }

        // Same family on different lines is still an inner rhyme. `cheat` / `reach`
        // never land the bar, so the line-end bucket cannot see them.
        var sharedFamily: [String: [AnnotatedToken]] = [:]
        for token in tokens {
            let c = coord(token)
            if endMemberCoords.contains(c) || internalCoords.contains(c) { continue }
            sharedFamily[offEndKey(token), default: []].append(token)
        }
        for (key, family) in sharedFamily {
            let distinct = Set(family.map(\.word))
            guard distinct.count >= 2 || family.count >= 2 else { continue }
            for token in family {
                addInternal(token, key: key)
            }
        }

        for (key, entries) in internalBuckets {
            let sharesEnd = endGroupKeys.contains(key)
            let distinctWordCount = Set(entries.map(\.0.word)).count
            if sharesEnd {
                guard !entries.isEmpty else { continue }
            } else {
                guard distinctWordCount >= 2 || entries.count >= 2 else { continue }
            }
            result.append(makeRhymeGroup(key: key, entries: entries, rhymeType: .internalRhyme))
        }

        return result
    }

    nonisolated static func computeGroups(text: String) async -> [RhymeGroup] {
        lockColorIndices(groupsFromAnnotatedTokens(annotatedTokens(in: text)))
    }

    /// Color index from phonetic rhyme-class id — stable across notes and relaunches.
    /// Highlights use the same index so the page and the list stay locked.
    nonisolated static func lockColorIndices(_ groups: [RhymeGroup], paletteCount: Int = 6) -> [RhymeGroup] {
        return groups.map { group in
            RhymeGroup(
                id: group.id,
                key: group.key,
                strength: group.strength,
                colorIndex: colorIndex(forRhymeClass: group.key, paletteCount: paletteCount),
                words: group.words,
                rhymeType: group.rhymeType
            )
        }
    }

    nonisolated static func computeAll(text: String) async -> ([RhymeGroup], [Highlight]) {
        let groups = await computeGroups(text: text)
        var highlights: [Highlight] = []
        for group in groups {
            for wordInfo in group.words {
                highlights.append(
                    Highlight(
                        range: wordInfo.range,
                        in: text,
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
        // Cache colors count to avoid main actor access
        let colorsCount = 6 // RhymeColorPalette.colors.count (hardcoded to avoid main actor isolation)
        let result = lockColorIndices(
            groupsFromAnnotatedTokens(annotatedTokens(in: text, signatureCache: signatureCache)),
            paletteCount: colorsCount
        )

        var highlights: [Highlight] = []
        for group in result {
            for wordInfo in group.words {
                highlights.append(
                    Highlight(
                        range: wordInfo.range,
                        in: text,
                        colorIndex: group.colorIndex,
                        strength: group.strength,
                        rhymeType: group.rhymeType
                    )
                )
            }
        }

        return (result, highlights)
    }

    /// Token indices that are the last content word of their line.
    nonisolated static func lineEndTokenIndices(
        in tokens: [(String, Range<String.Index>)],
        text: String
    ) -> Set<Int> {
        var lineOfToken: [Int] = []
        lineOfToken.reserveCapacity(tokens.count)
        for (_, range) in tokens {
            let n = text[text.startIndex..<range.lowerBound].reduce(0) { $1 == "\n" ? $0 + 1 : $0 }
            lineOfToken.append(n)
        }
        var lastByLine: [Int: Int] = [:]
        for (i, (word, _)) in tokens.enumerated() {
            guard keepsRhymeToken(word) else { continue }
            lastByLine[lineOfToken[i]] = i
        }
        return Set(lastByLine.values)
    }

    /// Last content word of a line (for scheme letters).
    nonisolated static func lastContentWord(_ line: String) -> String {
        let parts = line.split { !$0.isLetter && !$0.isNumber && $0 != "'" }.map { String($0).lowercased() }
        return parts.reversed().first { keepsRhymeToken($0) } ?? ""
    }

    /// AABB CCDD from line-end rimes. Unknown ends are "?".
    nonisolated static func endRhymeScheme(lines: [String], dict: [String: [String]]) -> (label: String, ends: [String]) {
        var map: [String: Character] = [:]
        var next = Character("A")
        var letters: [Character] = []
        var ends: [String] = []
        for line in lines {
            let word = lastContentWord(line)
            ends.append(word)
            guard let phones = dict[word], let sig = extractSignature(from: phones) else {
                letters.append("?")
                continue
            }
            let key = sig.rimeKey
            if map[key] == nil {
                map[key] = next
                if let ascii = next.asciiValue, ascii < 90 {
                    next = Character(UnicodeScalar(ascii + 1))
                }
            }
            letters.append(map[key] ?? "?")
        }
        let chunks: [String] = stride(from: 0, to: letters.count, by: 4).map { i in
            String(letters[i..<min(i + 4, letters.count)])
        }
        return (chunks.joined(separator: "  "), ends)
    }
}

// MARK: - Highlight

nonisolated struct Highlight: Equatable {
    /// UTF-16 range into the body at compute time. Integers stay valid across String copies;
    /// `String.Index` from a previous body traps or silently skips when applied to a new copy.
    let utf16: NSRange
    let colorIndex: Int
    let strength: RhymeHighlighterEngine.RhymeStrength
    let rhymeType: RhymeHighlighterEngine.RhymeType
    /// 0...1 craft heat (blue→red). Nil uses the rhyme-family palette.
    let heat: CGFloat?

    init(range: Range<String.Index>, in text: String, colorIndex: Int, strength: RhymeHighlighterEngine.RhymeStrength, rhymeType: RhymeHighlighterEngine.RhymeType, heat: CGFloat? = nil) {
        self.utf16 = NSRange(range, in: text)
        self.colorIndex = colorIndex
        self.strength = strength
        self.rhymeType = rhymeType
        self.heat = heat
    }

    init(utf16: NSRange, colorIndex: Int, strength: RhymeHighlighterEngine.RhymeStrength, rhymeType: RhymeHighlighterEngine.RhymeType, heat: CGFloat? = nil) {
        self.utf16 = utf16
        self.colorIndex = colorIndex
        self.strength = strength
        self.rhymeType = rhymeType
        self.heat = heat
    }

    func stringRange(in text: String) -> Range<String.Index>? {
        Range(utf16, in: text)
    }
}

// MARK: - Rhyme Engine State

@MainActor
final class RhymeEngineState: ObservableObject {
    @Published var cachedGroups: [RhymeHighlighterEngine.RhymeGroup] = []
    @Published var cachedHighlights: [Highlight] = []
    private var lastTextHash: Int?
    private var lastText: String = ""
    /// Set as soon as analysis is requested so a late CMUDICT load can retry
    /// even if the first compute finished (or was still debouncing) with an empty dict.
    private var pendingText: String = ""
    
    private var wordSignatureCache: [String: RhymeHighlighterEngine.PhoneticSignature] = [:]
    
    private var debounceTask: Task<Void, Never>? = nil
    private let debounceDelay: TimeInterval = 0.05
    /// Bumped on every new request so an older `computeAll` cannot clobber last-good paint.
    private var computeGeneration: UInt64 = 0
    
    private var cmudictObserver: NSObjectProtocol?
    
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
        cmudictObserver = NotificationCenter.default.addObserver(
            forName: .cmudictDidFinishLoading,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.retryIfNeededAfterDictionaryLoad()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let obs = cmudictObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
    
    private func clearCaches() {
        wordSignatureCache.removeAll(keepingCapacity: false)
        print("⚠️ RhymeEngineState: Caches cleared due to memory warning")
    }
    
    /// Re-run rhyme analysis when CMUDICT finishes loading (handles race where user typed before dictionary was ready).
    private func retryIfNeededAfterDictionaryLoad() {
        let text = pendingText.isEmpty ? lastText : pendingText
        guard !text.isEmpty else { return }
        Task { @MainActor in
            await refreshImmediately(text: text)
        }
    }

    func updateIfNeeded(text: String) {
        pendingText = text
        let hash = text.hashValue
        guard hash != lastTextHash else { return }

        debounceTask?.cancel()
        computeGeneration += 1
        let gen = computeGeneration

        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            guard !Task.isCancelled, gen == self.computeGeneration else { return }
            let snapshot = self.pendingText
            let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: snapshot)
            guard gen == self.computeGeneration else { return }
            self.applyComputeResults(groups: groups, highlights: highlights, text: snapshot)
        }
    }

    /// Last-good paint, remapped across the in-flight edit. Never `[]` just because
    /// `text` drifted — every keystroke used to cancel the 400ms recompute and the
    /// eye overlay went blank until `refreshImmediately` (toggling the eye).
    func highlights(for text: String) -> [Highlight] {
        var result: [Highlight]
        if lastText == text {
            result = cachedHighlights
        } else {
            result = Self.remapHighlights(cachedHighlights, from: lastText, to: text)
        }
        if let live = RhymeHighlighterEngine.liveTrailingHighlight(
            in: text,
            existing: result,
            groups: cachedGroups
        ) {
            result.append(live)
        }
        return result
    }

    func groups(for text: String) -> [RhymeHighlighterEngine.RhymeGroup] {
        cachedGroups
    }

    /// Run rhyme analysis immediately (no debounce). Use when opening a note or Model G.
    func refreshImmediately(text: String) async {
        debounceTask?.cancel()
        pendingText = text
        computeGeneration += 1
        let gen = computeGeneration
        if getGlobalCMUDICTStore().isEmpty {
            return
        }
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)
        guard gen == computeGeneration else { return }
        applyComputeResults(groups: groups, highlights: highlights, text: text)
    }

    private func applyComputeResults(
        groups: [RhymeHighlighterEngine.RhymeGroup],
        highlights: [Highlight],
        text: String
    ) {
        cachedGroups = groups
        cachedHighlights = highlights
        lastTextHash = text.hashValue
        lastText = text
    }

    /// Shift utf16 spans across one contiguous edit (common prefix / suffix).
    /// Spans wholly before the edit stay; spans wholly after shift by delta;
    /// spans that overlap the edited region are dropped. Leftover spans that
    /// still fit the new UTF-16 length are kept; anything past the end is dropped.
    nonisolated static func remapHighlights(_ highlights: [Highlight], from old: String, to new: String) -> [Highlight] {
        if old == new { return highlights }
        let newLen = (new as NSString).length
        guard !highlights.isEmpty else { return [] }
        if old.isEmpty {
            return highlights.filter { $0.utf16.location >= 0 && NSMaxRange($0.utf16) <= newLen }
        }

        let oldNS = old as NSString
        let newNS = new as NSString
        let oldLen = oldNS.length
        var prefix = 0
        let maxPrefix = min(oldLen, newLen)
        while prefix < maxPrefix && oldNS.character(at: prefix) == newNS.character(at: prefix) {
            prefix += 1
        }
        var suffix = 0
        while suffix < oldLen - prefix,
              suffix < newLen - prefix,
              oldNS.character(at: oldLen - 1 - suffix) == newNS.character(at: newLen - 1 - suffix) {
            suffix += 1
        }

        let oldEditEnd = oldLen - suffix
        let delta = newLen - oldLen

        return highlights.compactMap { h in
            let r = h.utf16
            guard r.location >= 0, r.length > 0 else { return nil }
            let end = NSMaxRange(r)
            let shifted: NSRange
            if end <= prefix {
                shifted = r
            } else if r.location >= oldEditEnd {
                let loc = r.location + delta
                guard loc >= 0 else { return nil }
                shifted = NSRange(location: loc, length: r.length)
            } else {
                return nil
            }
            guard shifted.location >= 0, NSMaxRange(shifted) <= newLen else { return nil }
            if shifted == r { return h }
            return Highlight(
                utf16: shifted,
                colorIndex: h.colorIndex,
                strength: h.strength,
                rhymeType: h.rhymeType
            )
        }
    }
}
