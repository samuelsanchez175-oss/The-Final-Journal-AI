//
//  VerseLedger.swift
//  XJournal AI
//
//  On-device verse scoring ledger — the same positive/negative rubric as eval/grade_modelg.py,
//  so the app records objective insight for every generation (not just user "good/bad").
//  Positives (cadence, end rhyme, inner rhyme, jargon, smart, flow, originality) minus penalties
//  (word repetition, over-explaining) = NET. Computed from CMUDICT + the theme jargon already loaded.
//

import Foundation

struct VerseLedger: Codable {
    let cadence: Double
    let endRhyme: Double
    let innerRhyme: Double
    let jargon: Double
    let smart: Double
    let flow: Double
    let originality: Double
    let voice: Double
    let repetitionPenalty: Double
    let overExplainPenalty: Double
    let net: Double

    var summary: String {
        String(format: "NET %.0f · cad %.0f · rhyme %.0f · inner %.0f · jargon %.0f · smart %.0f · voice %.0f · −rep %.0f −exp %.0f",
               net, cadence, endRhyme, innerRhyme, jargon, smart, voice, repetitionPenalty, overExplainPenalty)
    }
}

enum VerseLedgerScorer {
    // Corpus-derived targets (measured from ground_truth_rap_bars_MODEL_G.csv).
    private static let syllMean = 9.7, syllTol = 4.0
    private static let stressTarget = 0.72
    private static let voiceWeight = 0.08   // bounded Voice (A8/A9/A10) bonus → at most +8 NET
    private static let weights: [(String, Double)] = [
        ("Cadence", 0.18), ("EndRhyme", 0.18), ("InnerRhyme", 0.15),
        ("Jargon", 0.15), ("Smart", 0.15), ("Flow", 0.10), ("Originality", 0.09)]
    private static let stopwords: Set<String> = ["the", "a", "an", "and", "or", "but", "to", "of", "in",
        "on", "at", "it", "is", "be", "we", "they", "that", "this", "i", "you", "my", "me", "your", "im",
        "its", "got", "get", "gon", "gonna", "gotta", "yeah", "with", "for", "from", "now", "know", "like",
        "all", "out", "up", "so"]
    private static let explainers: Set<String> = ["because", "so", "really", "just", "finally", "trying",
        "tryna", "means", "destined", "blessed", "manifesting", "manifestin", "always", "never",
        "everything", "everybody", "literally", "honestly"]

    static func score(hook: String, bars: [String]) -> VerseLedger {
        let lines = ([hook] + bars).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let cmu = getGlobalCMUDICTStore()
        // Full v8 lexicon (≈500 terms), not just a theme subset — more authentic vocab to credit.
        let jargonTerms = Set(LexiconStore.shared.allTermStrings().filter { $0.count > 2 })

        // ---- positives ----
        let counts = lines.map { syllables(in: $0, cmu: cmu) }
        var cadence = 0.0
        if !counts.isEmpty {
            let per = counts.map { c -> Double in
                let dev = abs(Double(c) - syllMean) / max(1.5, syllTol) * 50.0
                return max(0.0, 100.0 - dev)
            }
            cadence = per.reduce(0.0, +) / Double(counts.count)
        }

        let (endRhyme, innerRhyme) = engineRhyme(lines)
        let jargon = jargonScore(lines, terms: jargonTerms)
        let smart = smartScore(lines)
        let flow = flowScore(lines, cmu: cmu)
        let originality = originalityScore(lines, bias: ModelGEnvironment.originalityBias)
        let voice = voiceScore(lines)   // A8/A9/A10 — Voice & Signal Theory via SignalIngest

        let positives: [String: Double] = ["Cadence": cadence, "EndRhyme": endRhyme,
            "InnerRhyme": innerRhyme, "Jargon": jargon, "Smart": smart, "Flow": flow,
            "Originality": originality]
        let posTotal = weights.reduce(0.0) { $0 + (positives[$1.0] ?? 0) * $1.1 }

        // ---- negatives ----
        let rep = repetitionPenalty(lines)
        let over = overExplainPenalty(lines, cmu: cmu)
        // Voice folds in as a bounded bonus so it shifts NET without destabilizing the trusted axes.
        let net = max(0, min(100, posTotal + voice * voiceWeight - rep - over))

        return VerseLedger(cadence: cadence, endRhyme: endRhyme, innerRhyme: innerRhyme,
            jargon: jargon, smart: smart, flow: flow, originality: originality, voice: voice,
            repetitionPenalty: rep, overExplainPenalty: over, net: net)
    }

    // MARK: - helpers

    /// A8/A9/A10 — Voice & Signal Theory measured with the app's own SignalIngest engine:
    /// A9 exposure discipline (penalize the over-explaining "AI tell"), A10 register consistency
    /// (hold one authority posture / audience across the verse), A8 social-action movement (a verse
    /// should shift its move, not stay flat). Returns 0–100; folded into NET as a bounded bonus.
    private static func voiceScore(_ lines: [String]) -> Double {
        let verse = lines.joined(separator: ". ")
        guard !verse.trimmingCharacters(in: .whitespaces).isEmpty else { return 50 }
        // A9 — exposure discipline from explanation density (the "AI tell").
        let metrics = SignalIngest.shared.analyzeBehavior(text: verse)
        let a9 = max(0.0, min(100.0, 100.0 - metrics.explanationDensity * 150.0))
        // A10 + A8 — compare the verse's two DISTINCT halves (needs 2+ lines; a single line would
        // compare a half against itself and falsely score perfect consistency).
        var a10 = 50.0, a8 = 50.0
        if lines.count >= 2 {
            let mid = lines.count / 2
            let firstHalf = lines.prefix(mid).joined(separator: ". ")
            let secondHalf = lines.suffix(lines.count - mid).joined(separator: ". ")
            if let a = computeModelGSignalAxes(from: firstHalf),
               let b = computeModelGSignalAxes(from: secondHalf) {
                a10 = (a.authorityPosture == b.authorityPosture ? 60.0 : 0.0)
                    + (a.audienceScope == b.audienceScope ? 40.0 : 0.0)
                a8 = (a.socialAction != b.socialAction) ? 100.0 : 50.0
            }
        }
        return 0.55 * a9 + 0.35 * a10 + 0.10 * a8
    }

    private static func wordsIn(_ s: String) -> [String] {
        let stripped = s.replacingOccurrences(of: "\\(.*?\\)", with: " ", options: .regularExpression)
        return stripped.lowercased().split { !$0.isLetter && $0 != "'" }.map(String.init)
    }

    private static func syllables(in line: String, cmu: [String: [String]]) -> Int {
        var total = 0
        for w in wordsIn(line) {
            if let ph = cmu[w] {
                let s = ph.filter { $0.last?.isNumber == true }.count
                total += max(1, s)
            } else {
                let v = w.filter { "aeiouy".contains($0) }.count
                total += max(1, v == 0 ? 1 : v)
            }
        }
        return total
    }

    /// Slant/assonance-aware rhyme via the app's own RhymeClusterEngine (RapSlangPhonemes + CMUDICT),
    /// replacing exact-rime-only scoring that under-counted real slant/multisyllabic rhyme. Targets are
    /// heuristic coverage levels (not corpus-calibrated) — the slant-aware detection is the upgrade.
    private static let endCoverageTarget = 0.5, internalCovTarget = 0.12, vowelFamilyCovTarget = 0.30

    private static func engineRhyme(_ lines: [String]) -> (end: Double, inner: Double) {
        let total = max(1, lines.flatMap { wordsIn($0) }.count)
        let clusters = RhymeClusterEngine.detect(lines: lines)
        // End rhyme: share of line-ends landing in a shared-stressed-vowel group (slant-aware).
        let endParts = Set(clusters.filter { $0.type == "end" }.flatMap { $0.parts })
        let endCov = Double(endParts.count) / Double(max(2, lines.count))
        let end = min(100, endCov / endCoverageTarget * 100)
        // Inner rhyme: true internal rhyme (vowel+coda) drives it, vowel-family assonance is a bonus.
        let internalParts = Set(clusters.filter { $0.type == "internal" }.flatMap { $0.parts })
        let famParts = Set(clusters.filter { $0.type == "vowel_family" }.flatMap { $0.parts })
        let internalCov = Double(internalParts.count) / Double(total)
        let famCov = Double(famParts.count) / Double(total)
        let inner = min(100, (internalCov / internalCovTarget * 0.7 + famCov / vowelFamilyCovTarget * 0.3) * 100)
        return (end, inner)
    }

    private static func jargonScore(_ lines: [String], terms: Set<String>) -> Double {
        guard !terms.isEmpty else { return 0 }
        let text = lines.joined(separator: " ").lowercased()
        // Tokenize once and match by membership instead of compiling ~500 regexes per call.
        // Single-word terms match whole tokens (so 'bin' won't fire in 'cabin'); multi-word terms
        // match as substrings — equivalent to the old \bterm\b pass but far cheaper.
        let tokens = Set(text.split { !$0.isLetter && !$0.isNumber && $0 != "'" }.map(String.init))
        let distinct = terms.filter { term in
            (term.contains(" ") || term.contains("-")) ? text.contains(term) : tokens.contains(term)
        }.count
        return min(100, Double(distinct) * 25)
    }

    private static func smartScore(_ lines: [String]) -> Double {
        let allWords = lines.flatMap { wordsIn($0) }
        let content = allWords.filter { $0.count > 3 && !stopwords.contains($0) }
        guard !content.isEmpty else { return 0 }
        let variety = Double(Set(content).count) / Double(content.count)
        let specific = allWords.filter { $0.contains(where: \.isNumber) || $0.count > 7 }.count
        let specDensity = Double(specific) / Double(max(1, allWords.count))
        return min(100, variety * 95 + specDensity * 180)
    }

    private static func flowScore(_ lines: [String], cmu: [String: [String]]) -> Double {
        var densities: [Double] = []
        for line in lines {
            var stressed = 0, total = 0
            for w in wordsIn(line) {
                if let ph = cmu[w] {
                    for p in ph where p.last?.isNumber == true {
                        total += 1
                        if p.last == "1" || p.last == "2" { stressed += 1 }
                    }
                } else {
                    let v = w.filter { "aeiouy".contains($0) }.count
                    total += v; stressed += Int(Double(v) * 0.4)
                }
            }
            if total > 0 { densities.append(Double(stressed) / Double(total)) }
        }
        guard !densities.isEmpty else { return 0 }
        let mean = densities.reduce(0, +) / Double(densities.count)
        let match = max(0.0, 100.0 - abs(mean - stressTarget) * 200.0)
        let variance = densities.map { ($0 - mean) * ($0 - mean) }.reduce(0.0, +) / Double(densities.count)
        let cv = mean > 0 ? variance.squareRoot() / mean : 0.0
        let consistency = max(0.0, 100.0 - cv * 100.0)
        return 0.6 * match + 0.4 * consistency
    }

    // Corpus vocabulary + exact lines for the inspiration/originality axis (lazy, on-device).
    private static var corpusVocab: Set<String> = []
    private static var corpusLines: Set<String> = []
    private static var corpusLoaded = false

    private static func loadCorpusOnce() {
        guard !corpusLoaded else { return }
        corpusLoaded = true
        for bar in EditorialGroundTruth.shared.groundTruthBars {
            let ws = wordsIn(bar.text)
            guard !ws.isEmpty else { continue }
            corpusLines.insert(ws.joined(separator: " "))
            for w in ws where w.count > 3 && !stopwords.contains(w) { corpusVocab.insert(w) }
        }
    }

    /// Reward hitting the inspiration target (bias): grounded in the culture's idioms but not
    /// verbatim. Sterile-original AND plagiarized both score low; the sweet spot is `bias`.
    private static func originalityScore(_ lines: [String], bias: Double) -> Double {
        loadCorpusOnce()
        guard !corpusVocab.isEmpty else { return 100.0 }   // corpus not loaded yet → neutral
        let verbatim = lines.contains { corpusLines.contains(wordsIn($0).joined(separator: " ")) }
        let content = lines.flatMap { wordsIn($0) }.filter { $0.count > 3 && !stopwords.contains($0) }
        guard !content.isEmpty else { return 50.0 }
        let inCorpus = content.filter { corpusVocab.contains($0) }.count
        let originalityLevel = 1.0 - Double(inCorpus) / Double(content.count)
        var score = max(0.0, 100.0 - abs(originalityLevel - bias) * 150.0)
        if verbatim { score = min(score, 20.0) }           // verbatim corpus line = plagiarism floor
        return score
    }

    private static func repetitionPenalty(_ lines: [String]) -> Double {
        let words = lines.flatMap { wordsIn($0) }.filter { $0.count > 3 && !stopwords.contains($0) }
        var counts: [String: Int] = [:]
        for w in words { counts[w, default: 0] += 1 }
        let overuse = counts.values.filter { $0 >= 4 }.reduce(0) { $0 + ($1 - 3) }
        return min(25, Double(overuse) * 5)
    }

    private static func overExplainPenalty(_ lines: [String], cmu: [String: [String]]) -> Double {
        let words = lines.flatMap { wordsIn($0) }
        guard !words.isEmpty else { return 0 }
        let markers = words.filter { explainers.contains($0) }.count
        let longBars = lines.filter { syllables(in: $0, cmu: cmu) > 16 }.count
        return min(15, Double(markers) * 2 + Double(longBars) * 2.5)
    }
}

/// One recorded generation (one line of verse_ledger.jsonl).
struct VerseLedgerEntry: Codable, Identifiable {
    var id: Double { timestamp }
    let timestamp: Double
    let source: String
    let net: Double
    let cadence: Double
    let endRhyme: Double
    let innerRhyme: Double
    let jargon: Double
    let smart: Double
    let flow: Double
    let voice: Double?
    let repetitionPenalty: Double
    let overExplainPenalty: Double
}

/// Appends each generation's ledger to Documents/verse_ledger.jsonl and reads it back —
/// an on-device trend the app accumulates over generations (see VerseLedgerTrendView).
final class VerseLedgerLog {
    static let shared = VerseLedgerLog()
    private init() {}

    private var fileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("verse_ledger.jsonl")
    }

    func record(_ ledger: VerseLedger, source: String) {
        guard let url = fileURL else { return }
        let e = VerseLedgerEntry(timestamp: Date().timeIntervalSince1970, source: source, net: ledger.net,
            cadence: ledger.cadence, endRhyme: ledger.endRhyme, innerRhyme: ledger.innerRhyme,
            jargon: ledger.jargon, smart: ledger.smart, flow: ledger.flow, voice: ledger.voice,
            repetitionPenalty: ledger.repetitionPenalty, overExplainPenalty: ledger.overExplainPenalty)
        guard let data = try? JSONEncoder().encode(e),
              var line = String(data: data, encoding: .utf8) else { return }
        line += "\n"
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            if let d = line.data(using: .utf8) { handle.write(d) }
            try? handle.close()
        } else {
            try? line.data(using: .utf8)?.write(to: url)
        }
    }

    /// All recorded generations, oldest first. Empty if nothing logged yet.
    func loadAll() -> [VerseLedgerEntry] {
        guard let url = fileURL, let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        let decoder = JSONDecoder()
        return text.split(separator: "\n").compactMap { line in
            line.data(using: .utf8).flatMap { try? decoder.decode(VerseLedgerEntry.self, from: $0) }
        }
    }
}
