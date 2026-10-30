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
        /// Same last stressed vowel, different final consonants. Lighter than an exact rhyme.
        case assonance = 0.35
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
        "as", "is", "it", "be", "we", "my", "me", "you", "i", "im", "i'm", "so", "if", "do", "no",
        "it's", "its", "yeah", "yea", "got"
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
        // Assonance: the last stressed vowel matches and the codas are only consonants.
        // dreams/scene, time/signs. An extra vowel is another syllable (man/manage) and stays dark.
        // dreams/lanes do not match — IY is not EY.
        if vowelA == vowelB, codaIsConsonantsOnly(a.coda), codaIsConsonantsOnly(b.coda) {
            return .assonance
        }
        return nil
    }

    /// No vowel phone after the stressed nucleus. Empty is fine (`go`). `manage` is not.
    nonisolated static func codaIsConsonantsOnly(_ coda: [String]) -> Bool {
        coda.allSatisfy { phone in
            let bare = String(phone.filter { !$0.isNumber })
            return !vowelPhones.contains(bare)
        }
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
        let others = scores.dropFirst()
        let strength: RhymeStrength
        if scores.allSatisfy({ $0 == .perfect }) {
            strength = .perfect
        } else if !others.isEmpty, others.allSatisfy({ $0 == .assonance }) {
            strength = .assonance
        } else {
            strength = .near
        }
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

    /// One stressed syllable inside a longer word. `maintained` → `tained`.
    struct SyllableSlice {
        let spelling: String
        let startOffset: Int
        let endOffset: Int
        let signature: PhoneticSignature
        let stress: Int
        let wordLength: Int
        var coversWholeWord: Bool { startOffset == 0 && endOffset == wordLength && wordLength > 0 }
    }

    /// CMUDICT or the slang table. The letter heuristic is not syllable data.
    nonisolated static func dictionaryPhonemes(for word: String) -> [String]? {
        let w = word.lowercased()
        if let spoken = spokenDigitWords(w) {
            var phones: [String] = []
            for part in spoken {
                guard part != w, let next = dictionaryPhonemes(for: part), !next.isEmpty else { return nil }
                phones.append(contentsOf: next)
            }
            return phones.isEmpty ? nil : phones
        }
        if let p = getGlobalCMUDICTStore()[w], !p.isEmpty { return p }
        if let p = FJCMUDICTStore.shared.phonemesByWord[w], !p.isEmpty { return p }
        if let p = RapSlangPhonemes.phonemes(for: w), !p.isEmpty { return p }
        return nil
    }

    /// Stressed syllables from CMU stress marks. Unknown words split on vowel groups.
    nonisolated static func syllableSlices(of word: String) -> [SyllableSlice] {
        let cleaned = word.lowercased()
        guard !cleaned.isEmpty else { return [] }
        if let phones = dictionaryPhonemes(for: cleaned), !phones.isEmpty {
            let slices = slicesFromPhonemes(word: cleaned, phones: phones)
            if !slices.isEmpty { return slices }
        }
        return slicesFromVowelGroups(word: cleaned)
    }

    nonisolated private static let syllableGraphemes: [String: [String]] = [
        "AA": ["au", "aw", "oa", "a", "o"],
        "AE": ["au", "a"],
        "AH": ["ou", "oo", "a", "e", "i", "o", "u"],
        "AO": ["augh", "ough", "au", "aw", "oa", "a", "o"],
        "AW": ["ough", "ou", "ow", "au"],
        "AY": ["igh", "aye", "ai", "ay", "ei", "ey", "ie", "i", "y"],
        "EH": ["ea", "ai", "ie", "e", "a"],
        "ER": ["ear", "ure", "er", "ir", "ur", "or", "ar"],
        "EY": ["eigh", "ai", "ay", "ei", "ey", "ea", "a", "e"],
        "IH": ["ui", "i", "y", "e", "u"],
        "IY": ["ee", "ea", "ie", "ei", "ey", "i", "e", "y"],
        "OW": ["ough", "ow", "ou", "oa", "oe", "o"],
        "OY": ["oi", "oy"],
        "UH": ["oo", "ou", "u", "o"],
        "UW": ["ew", "ue", "oo", "ou", "u", "o"],
        "B": ["bb", "b"],
        "CH": ["tch", "ch", "t"],
        "D": ["dd", "ed", "d"],
        "DH": ["th"],
        "F": ["ph", "ff", "gh", "f"],
        "G": ["gg", "gu", "g"],
        "HH": ["wh", "h"],
        "JH": ["dge", "dg", "j", "g"],
        "K": ["ck", "cc", "ch", "q", "k", "c"],
        "L": ["ll", "l"],
        "M": ["mm", "mb", "m"],
        "N": ["nn", "kn", "gn", "n"],
        "NG": ["ng", "n"],
        "P": ["pp", "p"],
        "R": ["rr", "wr", "r"],
        "S": ["ss", "sc", "ce", "se", "s", "c"],
        "SH": ["ti", "ci", "sh", "s", "ch"],
        "T": ["tt", "ght", "ed", "t"],
        "TH": ["th"],
        "V": ["ve", "v"],
        "W": ["wh", "w", "u"],
        "Y": ["y", "i"],
        "Z": ["zz", "se", "es", "s", "z"],
        "ZH": ["si", "ge", "s", "z"]
    ]

    nonisolated private static let legalOnsets: Set<String> = [
        "B", "BL", "BR", "CH", "D", "DR", "F", "FL", "FR", "G", "GL", "GR",
        "HH", "JH", "K", "KL", "KR", "L", "M", "N", "P", "PL", "PR", "R",
        "S", "SH", "SK", "SL", "SM", "SN", "SP", "ST", "STR", "SW",
        "T", "TH", "TR", "TW", "V", "W", "Y", "Z"
    ]

    nonisolated private static func barePhone(_ phone: String) -> String {
        String(phone.filter { !$0.isNumber })
    }

    nonisolated private static func phoneStress(_ phone: String) -> Int? {
        guard let digit = phone.last, digit.isNumber else { return nil }
        return Int(String(digit))
    }

    /// Letter spans for each phoneme. Offsets are into `word`.
    nonisolated private static func alignPhonemes(_ word: String, phones: [String]) -> [(Int, Int)] {
        let chars = Array(word)
        var index = 0
        var spans: [(Int, Int)] = []
        for phone in phones {
            let options = syllableGraphemes[barePhone(phone)] ?? []
            var matched: (Int, Int)?
            for skip in [0, 1] {
                let start = index + skip
                if start > chars.count { break }
                for option in options where start + option.count <= chars.count {
                    if String(chars[start..<(start + option.count)]) == option {
                        matched = (start, start + option.count)
                        break
                    }
                }
                if matched != nil { break }
            }
            if matched == nil {
                let end = min(index + 1, chars.count)
                matched = (index, end)
            }
            spans.append(matched!)
            index = matched!.1
        }
        if !spans.isEmpty, index < chars.count {
            spans[spans.count - 1].1 = chars.count
        }
        return spans
    }

    nonisolated private static func slicesFromPhonemes(word: String, phones: [String]) -> [SyllableSlice] {
        let vowelIndexes = phones.indices.filter { phoneStress(phones[$0]) != nil }
        guard !vowelIndexes.isEmpty else { return [] }
        let spans = alignPhonemes(word, phones: phones)
        guard spans.count == phones.count else { return [] }

        var pieces: [(start: Int, vowel: Int, end: Int)] = []
        for (ordinal, vowel) in vowelIndexes.enumerated() {
            let next = ordinal + 1 < vowelIndexes.count ? vowelIndexes[ordinal + 1] : phones.count
            let start = ordinal == 0 ? 0 : vowelIndexes[ordinal - 1] + 1
            pieces.append((start, vowel, next))
        }
        if pieces.count > 1 {
            for index in 1..<pieces.count {
                let consLo = pieces[index - 1].vowel + 1
                let consHi = pieces[index - 1].end
                var best = consHi
                if consLo < consHi {
                    for split in consLo..<consHi {
                        let cluster = phones[split..<consHi].map { barePhone($0) }.joined()
                        if legalOnsets.contains(cluster) {
                            best = split
                            break
                        }
                    }
                }
                pieces[index - 1].end = best
                pieces[index].start = best
            }
        }
        // A stressed vowel keeps one following consonant. "veil" stays veil, not vei-l.
        if pieces.count > 1 {
            for index in 0..<(pieces.count - 1) {
                guard phoneStress(phones[pieces[index].vowel]) == 1
                        || phoneStress(phones[pieces[index].vowel]) == 2 else { continue }
                guard pieces[index].vowel + 1 == pieces[index].end else { continue }
                let onsetCount = pieces[index + 1].vowel - pieces[index + 1].start
                guard onsetCount == 1 else { continue }
                pieces[index].end = pieces[index + 1].start + 1
                pieces[index + 1].start += 1
            }
        }

        struct Row {
            var spelling: String
            var stress: Int
            var start: Int
            var end: Int
            var vowel: Int
            var phoneEnd: Int
        }
        var raw: [Row] = []
        for piece in pieces where piece.start < piece.end {
            let letterStart = spans[piece.start].0
            let letterEnd = spans[piece.end - 1].1
            guard letterEnd > letterStart else { continue }
            let spelling = String(word[word.index(word.startIndex, offsetBy: letterStart)..<word.index(word.startIndex, offsetBy: letterEnd)])
            raw.append(Row(
                spelling: spelling,
                stress: phoneStress(phones[piece.vowel]) ?? 0,
                start: letterStart,
                end: letterEnd,
                vowel: piece.vowel,
                phoneEnd: piece.end
            ))
        }
        if raw.count > 1 {
            for index in 0..<(raw.count - 1) {
                guard raw[index].end == raw[index + 1].start else { continue }
                let spelling = raw[index].spelling
                guard spelling.count >= 2 else { continue }
                let lastIndex = spelling.index(before: spelling.endIndex)
                let beforeIndex = spelling.index(before: lastIndex)
                guard spelling[lastIndex] == spelling[beforeIndex] else { continue }
                let trimmed = String(spelling.dropLast())
                guard !trimmed.isEmpty else { continue }
                raw[index].spelling = trimmed
                raw[index].end -= 1
                raw[index + 1].spelling = String(spelling[lastIndex]) + raw[index + 1].spelling
                raw[index + 1].start -= 1
            }
        }

        return raw.compactMap { item in
            guard !item.spelling.isEmpty, item.end > item.start else { return nil }
            let coda = Array(phones[(item.vowel + 1)..<item.phoneEnd])
            return SyllableSlice(
                spelling: item.spelling,
                startOffset: item.start,
                endOffset: item.end,
                signature: PhoneticSignature(stressedVowel: phones[item.vowel], coda: coda),
                stress: item.stress,
                wordLength: word.count
            )
        }
    }

    /// Unknown words: one slice per vowel group. Every slice counts as stressed.
    nonisolated private static func slicesFromVowelGroups(word: String) -> [SyllableSlice] {
        let chars = Array(word)
        guard !chars.isEmpty else { return [] }
        func isVowel(_ index: Int) -> Bool {
            let c = chars[index]
            if c == "y" { return index > 0 }
            return "aeiou".contains(c)
        }
        var groups: [(Int, Int)] = []
        var index = 0
        while index < chars.count {
            if isVowel(index) {
                let start = index
                index += 1
                while index < chars.count, isVowel(index) { index += 1 }
                groups.append((start, index))
            } else {
                index += 1
            }
        }
        if groups.count > 1,
           let last = groups.last,
           last.1 - last.0 == 1,
           chars[last.0] == "e",
           last.0 > 0,
           !isVowel(last.0 - 1) {
            groups.removeLast()
        }
        guard !groups.isEmpty else { return [] }
        var bounds: [(Int, Int)] = []
        for (ordinal, group) in groups.enumerated() {
            let start: Int
            if ordinal == 0 {
                start = 0
            } else {
                let gapLo = groups[ordinal - 1].1
                let gapHi = group.0
                let gap = gapHi - gapLo
                start = gap <= 1 ? gapLo : gapLo + 1
            }
            let end = ordinal + 1 < groups.count ? groups[ordinal + 1].0 : chars.count
            // end is refined below once the next start is known
            bounds.append((start, end))
        }
        if bounds.count > 1 {
            for ordinal in 0..<(bounds.count - 1) {
                bounds[ordinal].1 = bounds[ordinal + 1].0
            }
            bounds[bounds.count - 1].1 = chars.count
        }
        let vowelPhone: [Character: String] = [
            "a": "AE", "e": "EH", "i": "IH", "o": "AA", "u": "AH", "y": "IY"
        ]
        let digraph: [String: String] = [
            "ai": "EY", "ay": "EY", "ei": "EY", "ey": "EY",
            "ee": "IY", "ea": "IY", "oo": "UW", "ou": "AW", "ow": "AW",
            "oi": "OY", "oy": "OY"
        ]
        var slices: [SyllableSlice] = []
        for (start, end) in bounds where end > start {
            let spelling = String(chars[start..<end])
            let local = Array(spelling)
            guard let vowelAt = local.indices.first(where: { isVowelLetter(local[$0], atStart: $0 == 0 && start == 0) }) else { continue }
            let pair = vowelAt + 1 < local.count ? String(local[vowelAt...vowelAt + 1]) : ""
            let nucleus = digraph[pair] ?? vowelPhone[local[vowelAt]] ?? "AH"
            var coda: [String] = []
            var cursor = pair.count == 2 && digraph[pair] != nil ? vowelAt + 2 : vowelAt + 1
            while cursor < local.count {
                coda.append(String(local[cursor]).uppercased())
                cursor += 1
            }
            slices.append(SyllableSlice(
                spelling: spelling,
                startOffset: start,
                endOffset: end,
                signature: PhoneticSignature(stressedVowel: nucleus + "1", coda: coda),
                stress: 1,
                wordLength: chars.count
            ))
        }
        return slices
    }

    nonisolated private static func isVowelLetter(_ c: Character, atStart: Bool) -> Bool {
        if c == "y" { return !atStart }
        return "aeiou".contains(c)
    }

    /// Paint a stressed syllable that rhymes with a group, and leave the rest of the word dark.
    /// A one-syllable exact rhyme is already the whole word, so its span stays.
    nonisolated static func attachSyllableSlices(
        tokens: [AnnotatedToken],
        in text: String,
        to groups: inout [RhymeGroup]
    ) {
        var covered = groups.flatMap { $0.words.map(\.range) }
        for token in tokens {
            for slice in syllableSlices(of: token.word) where slice.stress >= 1 && !slice.coversWholeWord {
                guard let range = rangeInText(text, token: token, slice: slice) else { continue }
                if covered.contains(where: { $0.lowerBound <= range.lowerBound && $0.upperBound >= range.upperBound }) {
                    continue
                }
                let piece = RhymeGroupWord(
                    word: slice.spelling,
                    range: range,
                    lineIndex: token.lineIndex,
                    positionInLine: token.positionInLine,
                    isLineEnd: token.isLineEnd && range.upperBound == token.range.upperBound
                )
                if let groupIndex = bestGroupIndex(for: slice.signature, in: groups) {
                    let group = groups[groupIndex]
                    groups[groupIndex] = RhymeGroup(
                        id: group.id,
                        key: group.key,
                        strength: group.strength,
                        colorIndex: group.colorIndex,
                        words: group.words + [piece],
                        rhymeType: group.rhymeType
                    )
                    covered.append(range)
                    continue
                }
                // "veil" / "surveillance" has no whole-word group yet. A perfect
                // syllable match seeds one. Near and assonance stay with groups
                // that already exist, so a loose slice cannot open a new family.
                guard let partner = tokens.first(where: { other in
                    other.range != token.range
                        && !covered.contains(where: { $0.lowerBound <= other.range.lowerBound && $0.upperBound >= other.range.upperBound })
                        && rhymeScore(slice.signature, other.signature) == .perfect
                }) else { continue }
                let key = endGroupKey(for: partner.word, signature: partner.signature, isLineEnd: partner.isLineEnd)
                groups.append(RhymeGroup(
                    id: UUID(),
                    key: key,
                    strength: .perfect,
                    colorIndex: 0,
                    words: [groupWord(from: partner), piece],
                    rhymeType: .internalRhyme
                ))
                covered.append(partner.range)
                covered.append(range)
            }
        }
    }

    nonisolated private static func rangeInText(
        _ text: String,
        token: AnnotatedToken,
        slice: SyllableSlice
    ) -> Range<String.Index>? {
        guard slice.endOffset > slice.startOffset else { return nil }
        guard let start = text.index(token.range.lowerBound, offsetBy: slice.startOffset, limitedBy: token.range.upperBound),
              let end = text.index(token.range.lowerBound, offsetBy: slice.endOffset, limitedBy: token.range.upperBound),
              start < end else { return nil }
        return start..<end
    }

    nonisolated private static func bestGroupIndex(
        for signature: PhoneticSignature,
        in groups: [RhymeGroup]
    ) -> Int? {
        var best: (index: Int, raw: Double)?
        for (index, group) in groups.enumerated() {
            for member in group.words {
                guard let phones = dictionaryPhonemes(for: member.word),
                      let memberSignature = extractSignature(from: phones),
                      let score = rhymeScore(signature, memberSignature) else { continue }
                if best == nil || score.rawValue > best!.raw {
                    best = (index, score.rawValue)
                }
            }
        }
        return best?.index
    }

    /// End rhymes from line-end landings. Internals from same-bar pairs, from mid words
    /// that share an end-group key, and from the same family across lines (`cheat` / `reach`).
    nonisolated static func groupsFromAnnotatedTokens(_ tokens: [AnnotatedToken], in text: String) -> [RhymeGroup] {
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
                    let score = rhymeScore(tokens[a].signature, tokens[b].signature)
                    // Every rhyme in the bar joins, including assonance (time/nines).
                    // The key chosen below stays on the specific family, so "she"
                    // does not rename "cheat" off IY|TCH before reach can join it.
                    if score != nil {
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
            // A first match must not keep the key. "decline" is AY|N and
            // "nines" is AY|N-Z; the bar still shares one bucket. An end-family
            // key outranks a bare vowel so "she" cannot claim "cheat".
            let key = keys.max(by: { keyRank($0, endGroupKeys: endGroupKeys) < keyRank($1, endGroupKeys: endGroupKeys) })
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

        var groupedTokenIndexes: Set<Int> = []
        for (index, token) in tokens.enumerated() {
            if endMemberCoords.contains(coord(token)) || internalCoords.contains(coord(token)) {
                groupedTokenIndexes.insert(index)
            }
        }
        appendAssonanceGroups(tokens: tokens, alreadyGrouped: groupedTokenIndexes, into: &result)
        mergeSharedFinalConsonant(groups: &result)
        attachSyllableSlices(tokens: tokens, in: text, to: &result)

        return result
    }

    /// Higher rank wins the one key for a bar. End buckets and locked families
    /// beat a bare vowel, so the first word in the bar does not name the group.
    nonisolated private static func keyRank(_ key: String, endGroupKeys: Set<String>) -> Int {
        var rank = endGroupKeys.contains(key) ? 50 : 0
        if key.contains("ALVSTOP") || key.hasPrefix("LOCKED") { rank += 5 }
        else if key.contains("|TCH") || key.contains("STOP-PBGK") || key.hasSuffix("|Y") { rank += 4 }
        else if key.contains("|") { rank += 3 }
        else { rank += 1 }
        return rank
    }

    /// `nines`/`signs` are claimed under AY|N-Z before `decline` (AY|N) is seen.
    /// The trailing Z is the same final N. Fold those groups together so the
    /// first bucket cannot leave the other word dark.
    nonisolated static func mergeSharedFinalConsonant(groups: inout [RhymeGroup]) {
        guard groups.count > 1 else { return }
        func profile(_ word: String) -> (vowel: String, last: String, signature: PhoneticSignature)? {
            guard let phones = dictionaryPhonemes(for: word),
                  let signature = extractSignature(from: phones),
                  let last = strippedCoda(signature.coda).last else { return nil }
            let vowel = String(signature.stressedVowel.filter { !$0.isNumber })
            return (vowel, last, signature)
        }
        func locked(_ key: String) -> Bool {
            key.contains("ALVSTOP") || key.contains("|TCH") || key.contains("STOP-PBGK")
                || key.hasSuffix("|Y") || key.hasPrefix("LOCKED")
        }
        let profiles = groups.map { group in group.words.compactMap { profile($0.word) } }
        var parent = Array(groups.indices)
        func find(_ index: Int) -> Int {
            var index = index
            while parent[index] != index { index = parent[index] }
            return index
        }
        func unite(_ a: Int, _ b: Int) {
            let ra = find(a), rb = find(b)
            if ra != rb { parent[rb] = ra }
        }
        for i in groups.indices {
            for j in (i + 1)..<groups.count {
                if groups[i].key != groups[j].key, locked(groups[i].key) || locked(groups[j].key) {
                    continue
                }
                var linked = false
                for left in profiles[i] {
                    for right in profiles[j] where left.vowel == right.vowel && left.last == right.last {
                        if rhymeScore(left.signature, right.signature) != nil {
                            linked = true
                            break
                        }
                    }
                    if linked { break }
                }
                if linked { unite(i, j) }
            }
        }
        var buckets: [Int: [Int]] = [:]
        for index in groups.indices {
            buckets[find(index), default: []].append(index)
        }
        var merged: [RhymeGroup] = []
        var seenRoots: Set<Int> = []
        for index in groups.indices {
            let root = find(index)
            if seenRoots.contains(root) { continue }
            seenRoots.insert(root)
            let memberIndexes = buckets[root] ?? [index]
            if memberIndexes.count == 1 {
                merged.append(groups[memberIndexes[0]])
                continue
            }
            let memberGroups = memberIndexes.map { groups[$0] }
            let keeper = memberGroups.max(by: { $0.strength.rawValue < $1.strength.rawValue }) ?? memberGroups[0]
            var seen: Set<String> = []
            var words: [RhymeGroupWord] = []
            for group in memberGroups {
                for word in group.words {
                    let marker = "\(word.lineIndex)|\(word.positionInLine)|\(word.word)"
                    if seen.contains(marker) { continue }
                    seen.insert(marker)
                    words.append(word)
                }
            }
            let keepsEnd = memberGroups.contains { group in
                if case .endRhyme = group.rhymeType { return true }
                return false
            }
            merged.append(RhymeGroup(
                id: keeper.id,
                key: keeper.key,
                strength: keeper.strength,
                colorIndex: keeper.colorIndex,
                words: words,
                rhymeType: keepsEnd ? .endRhyme : keeper.rhymeType
            ))
        }
        groups = merged
    }

    /// Words the stricter buckets missed, grouped by the last stressed vowel.
    /// Exact groups stay as they are. These paint in that vowel's color, lighter.
    nonisolated static func appendAssonanceGroups(
        tokens: [AnnotatedToken],
        alreadyGrouped: Set<Int>,
        into result: inout [RhymeGroup]
    ) {
        func vowel(of token: AnnotatedToken) -> String {
            String(token.signature.stressedVowel.filter { !$0.isNumber })
        }

        let free = tokens.indices.filter { !alreadyGrouped.contains($0) }
        var byVowel: [String: [Int]] = [:]
        for index in free {
            byVowel[vowel(of: tokens[index]), default: []].append(index)
        }

        for (vowelSound, indexes) in byVowel {
            var parent = [Int: Int]()
            for index in indexes { parent[index] = index }
            func find(_ x: Int) -> Int {
                var x = x
                while parent[x] != x {
                    parent[x] = parent[parent[x]!]
                    x = parent[x]!
                }
                return x
            }
            func union(_ a: Int, _ b: Int) {
                let ra = find(a), rb = find(b)
                if ra != rb { parent[rb] = ra }
            }
            for i in indexes.indices {
                for j in (i + 1)..<indexes.count {
                    let left = indexes[i], right = indexes[j]
                    if rhymeScore(tokens[left].signature, tokens[right].signature) == .assonance {
                        union(left, right)
                    }
                }
            }
            var members: [Int: [Int]] = [:]
            for index in indexes {
                let root = find(index)
                let hasPartner = indexes.contains { other in
                    other != index && find(other) == root
                        && rhymeScore(tokens[index].signature, tokens[other].signature) == .assonance
                }
                if hasPartner { members[root, default: []].append(index) }
            }
            for groupIndexes in members.values {
                let words = Set(groupIndexes.map { tokens[$0].word })
                guard words.count >= 2 else { continue }
                let colorKey = result.first { group in
                    let head = group.key.split(separator: "|", maxSplits: 1).first.map(String.init) ?? group.key
                    return head == vowelSound && group.strength != .assonance
                }?.key ?? vowelSound
                let entries = groupIndexes.map { index in
                    (groupWord(from: tokens[index]), tokens[index].signature)
                }
                result.append(
                    RhymeGroup(
                        id: UUID(),
                        key: colorKey,
                        strength: .assonance,
                        colorIndex: 0,
                        words: entries.map(\.0),
                        rhymeType: .endRhyme
                    )
                )
            }
        }
    }

    nonisolated static func computeGroups(text: String) async -> [RhymeGroup] {
        lockColorIndices(groupsFromAnnotatedTokens(annotatedTokens(in: text), in: text))
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
            groupsFromAnnotatedTokens(annotatedTokens(in: text, signatureCache: signatureCache), in: text),
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
