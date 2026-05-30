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
    let repetitionPenalty: Double
    let overExplainPenalty: Double
    let net: Double

    var summary: String {
        String(format: "NET %.0f · cad %.0f · rhyme %.0f · inner %.0f · jargon %.0f · smart %.0f · −rep %.0f −exp %.0f",
               net, cadence, endRhyme, innerRhyme, jargon, smart, repetitionPenalty, overExplainPenalty)
    }
}

enum VerseLedgerScorer {
    // Corpus-derived targets (measured from ground_truth_rap_bars_MODEL_G.csv).
    private static let syllMean = 9.7, syllTol = 4.0
    private static let internalTarget = 0.02, multiTarget = 0.003, stressTarget = 0.72, rhymeTarget = 0.5
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
        let jargonTerms = Set(NewRapDatabase.shared.themes.flatMap { $0.jargonTerms }
            .map { $0.lowercased().trimmingCharacters(in: .whitespaces) }.filter { $0.count > 2 })

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

        let endRhyme = endRhymeScore(lines, cmu: cmu)
        let (innerRhyme, _) = innerRhymeScore(lines, cmu: cmu)
        let jargon = jargonScore(lines, terms: jargonTerms)
        let smart = smartScore(lines)
        let flow = flowScore(lines, cmu: cmu)
        let originality = 100.0   // on-device: no corpus n-gram set loaded; assume original

        let positives: [String: Double] = ["Cadence": cadence, "EndRhyme": endRhyme,
            "InnerRhyme": innerRhyme, "Jargon": jargon, "Smart": smart, "Flow": flow,
            "Originality": originality]
        let posTotal = weights.reduce(0.0) { $0 + (positives[$1.0] ?? 0) * $1.1 }

        // ---- negatives ----
        let rep = repetitionPenalty(lines)
        let over = overExplainPenalty(lines, cmu: cmu)
        let net = max(0, min(100, posTotal - rep - over))

        return VerseLedger(cadence: cadence, endRhyme: endRhyme, innerRhyme: innerRhyme,
            jargon: jargon, smart: smart, flow: flow, originality: originality,
            repetitionPenalty: rep, overExplainPenalty: over, net: net)
    }

    // MARK: - helpers

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

    /// Rime = phonemes from the last stressed vowel to the end (stress stripped).
    private static func rime(_ word: String, cmu: [String: [String]]) -> [String]? {
        guard let ph = cmu[word] else { return nil }
        guard let idx = ph.lastIndex(where: { $0.last?.isNumber == true }) else { return nil }
        return ph[idx...].map { $0.filter { !$0.isNumber } }
    }

    private static func rimeSyllables(_ word: String, cmu: [String: [String]]) -> Int {
        guard let ph = cmu[word], let idx = ph.lastIndex(where: { $0.last?.isNumber == true }) else { return 0 }
        return ph[idx...].filter { $0.last?.isNumber == true }.count
    }

    private static func wordsRhyme(_ a: String, _ b: String, cmu: [String: [String]]) -> Bool {
        if a == b { return false }
        if let ra = rime(a, cmu: cmu), let rb = rime(b, cmu: cmu) { return ra == rb }
        return a.count > 1 && b.count > 1 && a.suffix(2) == b.suffix(2)
    }

    private static func lastWord(_ line: String) -> String? { wordsIn(line).last }

    private static func endRhymeScore(_ lines: [String], cmu: [String: [String]]) -> Double {
        let lws = lines.map { lastWord($0) }
        var eligible = 0, rhymed = 0
        for i in 1..<max(1, lws.count) {
            guard let cur = lws[i] else { continue }
            eligible += 1
            for j in max(0, i - 2)..<i {
                if let prev = lws[j], wordsRhyme(cur, prev, cmu: cmu) { rhymed += 1; break }
            }
        }
        let rate = eligible > 0 ? Double(rhymed) / Double(eligible) : 0
        return rate >= rhymeTarget ? 100 : rate / rhymeTarget * 100
    }

    private static func innerRhymeScore(_ lines: [String], cmu: [String: [String]]) -> (Double, Double) {
        var rimes: [([String], Int)] = []
        var wordList: [String] = []
        for line in lines {
            for w in wordsIn(line) {
                if let r = rime(w, cmu: cmu) { rimes.append((r, rimeSyllables(w, cmu: cmu))); wordList.append(w) }
            }
        }
        guard rimes.count >= 2 else { return (0, 0) }
        var internalHits = 0, multiHits = 0, total = 0
        for a in 0..<rimes.count {
            for b in (a + 1)..<min(rimes.count, a + 8) {
                if wordList[a] == wordList[b] { continue }
                total += 1
                if rimes[a].0 == rimes[b].0 {
                    internalHits += 1
                    if min(rimes[a].1, rimes[b].1) >= 2 { multiHits += 1 }
                }
            }
        }
        guard total > 0 else { return (0, 0) }
        let density = Double(internalHits) / Double(total)
        let multiDensity = Double(multiHits) / Double(total)
        let intScore = min(100, density / internalTarget * 100)
        let multiScore = min(100, multiDensity / multiTarget * 100)
        return (min(100, intScore * 0.35 + multiScore * 0.65), multiDensity)
    }

    private static func jargonScore(_ lines: [String], terms: Set<String>) -> Double {
        guard !terms.isEmpty else { return 0 }
        let text = lines.joined(separator: " ").lowercased()
        let distinct = terms.filter { text.contains($0) }.count
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

/// Appends each generation's ledger to Documents/verse_ledger.jsonl — an on-device trend the app
/// accumulates over generations (pull the file, or surface it in a debug view later).
final class VerseLedgerLog {
    static let shared = VerseLedgerLog()
    private init() {}

    private var fileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("verse_ledger.jsonl")
    }

    func record(_ ledger: VerseLedger, source: String) {
        guard let url = fileURL else { return }
        struct Entry: Codable {
            let timestamp: Double, source: String, net: Double, cadence: Double, endRhyme: Double
            let innerRhyme: Double, jargon: Double, smart: Double, flow: Double
            let repetitionPenalty: Double, overExplainPenalty: Double
        }
        let e = Entry(timestamp: Date().timeIntervalSince1970, source: source, net: ledger.net,
            cadence: ledger.cadence, endRhyme: ledger.endRhyme, innerRhyme: ledger.innerRhyme,
            jargon: ledger.jargon, smart: ledger.smart, flow: ledger.flow,
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
}
