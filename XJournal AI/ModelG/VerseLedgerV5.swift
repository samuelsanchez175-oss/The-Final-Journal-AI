//
//  VerseLedgerV5.swift
//  XJournal AI
//
//  Model G v5 — the recalibrated, section-aware grader, ported from eval/grade_modelg_v5.py.
//
//  ADDITIVE: this does NOT touch VerseLedgerScorer (the shipping grader) or selection. It is the
//  v5 reference made callable in-app so it can be A/B'd, then wired into selection behind a flag
//  once the Xcode Cloud build validates it.
//
//  v5 measures authenticity as TYPICALITY — proximity to the authentic per-section distribution
//  (bundled v5_fingerprint.json, learned from the real corpus) — which rejects BOTH word-salad and
//  over-polished AI (the real-vs-AI finding: AI imitation scores "too clean"). Axes:
//    Meter (broad band + consistency, or an intent target) · Rhyme (slant: vowel + vowel/coda,
//    scheme-aware) · Specificity (lexicon + rare vocabulary) · Throughline (thematic cohesion) ·
//    Craft (lexical diversity) − section-aware Repetition (refrain-exempt, softened for hooks).
//

import Foundation

struct VerseLedgerV5: Codable {
    let section: String          // "verse" | "hook"
    let meter: Double
    let rhyme: Double
    let specificity: Double
    let throughline: Double
    let craft: Double
    let repetitionPenalty: Double
    let net: Double              // weighted-axis authenticity (0–100)
    let typicality: Double       // the learned grader: proximity to the authentic band (0–100)

    var summary: String {
        String(format: "v5[%@] NET %.0f · typ %.0f · meter %.0f rhyme %.0f spec %.0f thru %.0f craft %.0f −rep %.0f",
               section, net, typicality, meter, rhyme, specificity, throughline, craft, repetitionPenalty)
    }
}

enum VerseLedgerV5Scorer {
    // Per-section axis weights (mirror grade_modelg_v5.WEIGHTS).
    private static let weights: [String: [String: Double]] = [
        "verse": ["Meter": 0.25, "Rhyme": 0.32, "Specificity": 0.25, "Throughline": 0.08, "Craft": 0.10],
        "hook":  ["Meter": 0.28, "Rhyme": 0.32, "Specificity": 0.20, "Throughline": 0.08, "Craft": 0.12],
    ]
    // Same stopword set the fingerprint was built with (grade_modelg.STOPWORDS).
    private static let stop: Set<String> = ["the","a","an","and","or","but","to","of","in","on","at","it",
        "is","be","we","they","that","this","i","you","my","me","your","im","its","got","get","gon","gonna",
        "gotta","yeah","uh","with","for","from","now","know","like","all","out","up","so"]
    private static let spellVowel: [Character: String] = ["a": "AE", "e": "EH", "i": "AY", "o": "OW", "u": "UW", "y": "AY"]
    private static let adlib = try! NSRegularExpression(pattern: "\\([^)]*\\)")

    // MARK: - Bundled learned parameters
    struct Fingerprint: Codable { let k: Double; let verse: [String: [Double]]; let hook: [String: [Double]] }

    private static let fingerprint: Fingerprint? = {
        guard let url = Bundle.main.url(forResource: "v5_fingerprint", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Fingerprint.self, from: data)
    }()
    private static let common: Set<String> = {
        guard let url = Bundle.main.url(forResource: "v5_common_words", withExtension: "txt"),
              let txt = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        return Set(txt.split(whereSeparator: \.isNewline)
                      .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
    }()
    private static let lexicon: Set<String> = Set(LexiconStore.shared.allTermStrings()
        .map { $0.lowercased() }.filter { $0.count > 2 })

    // MARK: - Public API
    static func score(hook: String, bars: [String], section forced: String? = nil,
                      intentSyllables: Int? = nil) -> VerseLedgerV5 {
        let lines = ([hook] + bars).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let cmu = getGlobalCMUDICTStore()
        let section = forced ?? detectSection(lines)
        let axes: [String: Double] = [
            "Meter": meter(lines, cmu, intentSyllables),
            "Rhyme": rhyme(lines, cmu),
            "Specificity": specificity(lines),
            "Throughline": throughline(lines),
            "Craft": craft(lines),
        ]
        let w = weights[section] ?? weights["verse"]!
        let pos = w.reduce(0.0) { $0 + (axes[$1.key] ?? 0) * $1.value }
        let rep = repetitionPenalty(lines, section: section)
        let net = max(0, min(100, pos - rep))
        return VerseLedgerV5(section: section, meter: axes["Meter"]!, rhyme: axes["Rhyme"]!,
                             specificity: axes["Specificity"]!, throughline: axes["Throughline"]!,
                             craft: axes["Craft"]!, repetitionPenalty: rep,
                             net: net, typicality: typicality(axes, section: section))
    }

    // MARK: - Tokenizing
    private static func words(_ text: String) -> [String] {
        let r = NSRange(text.startIndex..., in: text)
        let noAdlib = adlib.stringByReplacingMatches(in: text, range: r, withTemplate: " ")
        return noAdlib.lowercased().split { !($0.isLetter || $0 == "'") }.map(String.init)
    }
    private static func content(_ text: String) -> [String] {
        words(text).filter { $0.count > 2 && !stop.contains($0) }
    }
    private static func syllables(_ word: String, _ cmu: [String: [String]]) -> Int {
        let w = word.trimmingCharacters(in: CharacterSet(charactersIn: "'"))
        if let ph = cmu[w] { return max(1, ph.filter { $0.last?.isNumber == true }.count) }
        if w.isEmpty { return 0 }
        return max(1, w.filter { "aeiouy".contains($0) }.count)
    }
    private static func lineSyllables(_ line: String, _ cmu: [String: [String]]) -> Int {
        words(line).reduce(0) { $0 + syllables($1, cmu) }
    }

    // MARK: - Rhyme (two-tier: vowel + vowel/coda, slant + monorhyme + OOV, scheme-aware)
    private static func endKeys(_ line: String, _ cmu: [String: [String]]) -> (String, String)? {
        guard let w = words(line).last else { return nil }
        if let ph = cmu[w], let i = ph.lastIndex(where: { $0.last?.isNumber == true }) {
            let vowel = String(ph[i].prefix(2))
            let coda = ph[(i + 1)...].last.map { String($0.prefix { !$0.isNumber }) } ?? ""
            return (vowel, vowel + "|" + coda)
        }
        let vowels = Array(w).filter { "aeiouy".contains($0) }
        guard let last = vowels.last, let tail = w.last else { return nil }
        let vk = spellVowel[last] ?? String(last).uppercased()
        return (vk, vk + "|" + String(tail))
    }
    private static func rhyme(_ lines: [String], _ cmu: [String: [String]]) -> Double {
        var vk: [String] = [], sk: [String] = []
        for l in lines { if let (v, s) = endKeys(l, cmu) { vk.append(v); sk.append(s) } }
        guard vk.count >= 2 else { return 0 }
        let fv = counts(vk), fs = counts(sk)
        let covV = Double(vk.filter { (fv[$0] ?? 0) >= 2 }.count) / Double(vk.count)
        let covS = Double(sk.filter { (fs[$0] ?? 0) >= 2 }.count) / Double(sk.count)
        return round1(min(100, 100 * (0.35 * covV + 0.65 * covS)))
    }

    // MARK: - Meter (broad band + consistency, or an intent target)
    private static func meter(_ lines: [String], _ cmu: [String: [String]], _ intent: Int?) -> Double {
        let c = lines.map { lineSyllables($0, cmu) }.filter { $0 > 0 }
        guard !c.isEmpty else { return 0 }
        if let t = intent {
            return round1(100 * Double(c.filter { abs($0 - t) <= 2 }.count) / Double(c.count))
        }
        let inband = Double(c.filter { $0 >= 4 && $0 <= 18 }.count) / Double(c.count)
        let consistency = max(0, 1 - pstdev(c.map(Double.init)) / 8.0)
        return round1(min(100, 100 * (0.7 * inband + 0.3 * consistency)))
    }

    // MARK: - Specificity (lexicon + rare vocabulary; order-invariant)
    private static func specificity(_ lines: [String]) -> Double {
        let toks = words(lines.joined(separator: " "))
        guard !toks.isEmpty else { return 0 }
        let low = lines.joined(separator: " ").lowercased()
        let tokset = Set(toks)
        let lex = lexicon.filter { $0.contains(" ") ? low.contains($0) : tokset.contains($0) }.count
        var specific = Set<String>()
        for w in toks {
            if w.contains(where: \.isNumber) { specific.insert(w) }
            else if w.count > 2 && !stop.contains(w) && !common.contains(w) { specific.insert(w) }
        }
        return round1(min(100, Double(lex + specific.count) / Double(lines.count) * 22))
    }

    // MARK: - Through-line (thematic cohesion, reward-only)
    private static func throughline(_ lines: [String]) -> Double {
        let sets = lines.map { Set(content($0)) }.filter { !$0.isEmpty }
        guard sets.count >= 2 else { return 0 }
        var sims: [Double] = []
        for i in 0..<sets.count {
            for j in (i + 1)..<sets.count {
                let u = sets[i].union(sets[j])
                if !u.isEmpty { sims.append(Double(sets[i].intersection(sets[j]).count) / Double(u.count)) }
            }
        }
        let cohesion = sims.isEmpty ? 0 : sims.reduce(0, +) / Double(sims.count)
        return round1(min(100, cohesion * 300))
    }

    private static func craft(_ lines: [String]) -> Double {
        let cw = lines.flatMap { content($0) }
        guard !cw.isEmpty else { return 50 }
        return round1(min(100, 100 * Double(Set(cw).count) / Double(cw.count)))
    }

    // MARK: - Repetition (refrain-exempt + monotony, section-softened, hard floor)
    private static func repetitionPenalty(_ lines: [String], section: String) -> Double {
        let norm = lines.map { normLine($0) }
        let lineCounts = counts(norm)
        let refrains = Set(norm.filter { (lineCounts[$0] ?? 0) >= 2 })
        let body = zip(lines, norm).filter { !refrains.contains($0.1) }.map { $0.0 }
        let cw = body.flatMap { content($0) }
        var monotony = 0.0
        if !cw.isEmpty { monotony = max(0, 0.6 - Double(Set(cw).count) / Double(cw.count)) * 100 }
        var pen = monotony * (section == "hook" ? 0.35 : 1.0) * 0.4
        let allcw = lines.flatMap { content($0) }
        if !allcw.isEmpty && Double(Set(allcw).count) / Double(allcw.count) < 0.25 { pen += 12 }
        return round1(min(25, pen))
    }

    // MARK: - Router
    private static func detectSection(_ lines: [String]) -> String {
        let norm = lines.map { normLine($0) }
        if counts(norm).values.contains(where: { $0 >= 3 }) { return "hook" }
        var tails: [String: Int] = [:]
        for l in lines {
            let w = words(l)
            if w.count >= 2 { tails[w[w.count - 2] + " " + w[w.count - 1], default: 0] += 1 }
        }
        if let m = tails.values.max(), m >= max(4, Int(Double(lines.count) * 0.4)) { return "hook" }
        return "verse"
    }

    // MARK: - Typicality (the learned grader: proximity to the authentic band)
    private static func typicality(_ axes: [String: Double], section: String) -> Double {
        guard let fp = fingerprint else { return 50 }
        let band = section == "hook" ? fp.hook : fp.verse
        guard !band.isEmpty else { return 50 }
        var closeness: [Double] = []
        for (axis, ms) in band where ms.count == 2 {
            let mean = ms[0], std = ms[1] == 0 ? 1e-9 : ms[1]
            let z = ((axes[axis] ?? mean) - mean) / (fp.k * std)
            closeness.append(exp(-0.5 * z * z))
        }
        guard !closeness.isEmpty else { return 50 }
        return round1(100 * closeness.reduce(0, +) / Double(closeness.count))
    }

    // MARK: - Small helpers
    private static func counts(_ arr: [String]) -> [String: Int] {
        var d: [String: Int] = [:]
        for x in arr { d[x, default: 0] += 1 }
        return d
    }
    private static func pstdev(_ xs: [Double]) -> Double {
        guard xs.count > 1 else { return 0 }
        let m = xs.reduce(0, +) / Double(xs.count)
        return (xs.reduce(0) { $0 + ($1 - m) * ($1 - m) } / Double(xs.count)).squareRoot()
    }
    private static func normLine(_ s: String) -> String {
        String(s.lowercased().map { ($0.isLetter || $0.isNumber) ? $0 : " " })
            .split(separator: " ").joined(separator: " ")
    }
    private static func round1(_ x: Double) -> Double { (x * 10).rounded() / 10 }
}
