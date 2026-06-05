//
//  GroundTruthCorpus.swift
//  XJournal AI
//
//  Model G v4 — the RAG retrieval layer.
//
//  Loads the real Gunna/Young-Thug ground-truth corpus (ground_truth_rap_bars_MODEL_G.csv)
//  with the CORRECT schema and retrieves the bars closest to a generation request so they can
//  anchor the LLM's cadence and rhyme.
//
//  Why this exists (and the old GroundTruthRetriever/EditorialGroundTruth parsers don't suffice):
//  the CSV has a 2-row preamble. The real *column names* are on line 0, the `text_id` is column 0,
//  and the lyric is in `text_bar_line` (col 6). The legacy loaders read the header from the wrong
//  line, so they either set `text` to the artist name or miss `syllable_count`/`stress`/`rhyme`
//  entirely. This loader reads line 0 as the schema and indexes the columns retrieval actually needs.
//

import Foundation

/// One real bar from the ground-truth corpus, with the metadata Model G retrieves on.
struct CorpusBar: Identifiable, Hashable {
    let id: String              // text_id, e.g. "gunna.200forlunch.1"
    let text: String            // the actual lyric (text_bar_line)
    let artist: String?
    let song: String?
    let syllableCount: Int
    let rhymeClass: String?     // e.g. "ood"
    let phoneticEnding: String? // e.g. "F EY1 S AH0 Z"
    let primaryTone: String?    // e.g. "luxurious" (lowercased)
    let secondaryTone: String?  // e.g. "aspirational" (lowercased)
    let authorityClass: String? // e.g. "LIFESTYLE_BACKGROUND"

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CorpusBar, rhs: CorpusBar) -> Bool { lhs.id == rhs.id }
}

/// Loads + retrieves the ground-truth corpus for Model G v4. Singleton; load once.
/// Mirrors the concurrency style of `GroundTruthRetriever` (plain class singleton; parse on a
/// detached task; read-only after load).
final class GroundTruthCorpus {
    static let shared = GroundTruthCorpus()
    private init() {}

    private(set) var bars: [CorpusBar] = []
    private(set) var isLoaded: Bool = false

    private static let resourceName = "ground_truth_rap_bars_MODEL_G"

    // MARK: - Load

    /// Load + parse the corpus from the app bundle. Safe to call repeatedly (idempotent).
    func loadIfNeeded() async {
        guard !isLoaded else { return }

        guard let url = Bundle.main.url(forResource: Self.resourceName, withExtension: "csv") else {
            // Hard, visible failure: if this fires, the corpus isn't in the app target's resources
            // and the RAG silently has nothing to retrieve. (It should bundle via the synchronized group.)
            print("❌ GroundTruthCorpus: \(Self.resourceName).csv NOT found in bundle — RAG corpus is EMPTY. " +
                  "Add it to the app target's Copy Bundle Resources.")
            isLoaded = true
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let parsed = await Task.detached(priority: .utility) { Self.parse(data) }.value
            bars = parsed
            isLoaded = true
            print("✅ GroundTruthCorpus: loaded \(parsed.count) real ground-truth bars for retrieval.")
        } catch {
            isLoaded = true
            print("❌ GroundTruthCorpus: failed to read corpus — \(error.localizedDescription)")
        }
    }

    // MARK: - Retrieve

    /// Retrieve up to `limit` real bars closest to the request, to anchor cadence & rhyme.
    ///
    /// Ranking blends three signals, all optional:
    ///  - tone match (primary +3, secondary +1) against `tones`
    ///  - rhyme-class overlap (+3) against `rhymeClasses`
    ///  - syllable proximity to `syllableTarget` (closer = higher, up to +3)
    ///
    /// Empty `tones`/`rhymeClasses` simply don't constrain on that axis. A top window is sampled
    /// (not strictly top-k) so two verses generated back-to-back get varied anchors.
    func retrieve(syllableTarget: Int,
                  tones: [String] = [],
                  rhymeClasses: [String] = [],
                  limit: Int = 4) -> [CorpusBar] {
        guard !bars.isEmpty, limit > 0 else { return [] }

        let toneSet = Set(tones.map { $0.lowercased() })
        let rhymeSet = Set(rhymeClasses.map { $0.lowercased() })
        // Phase 3: learned per-tone reward (from authenticity NET + accept/reject). Read once, not per bar.
        let toneRewards = CorpusFeedbackStore.shared.rewardsSnapshot()

        func score(_ b: CorpusBar) -> Double {
            var s = 0.0
            if let p = b.primaryTone, toneSet.contains(p) { s += 3 }
            if let sec = b.secondaryTone, toneSet.contains(sec) { s += 1 }
            if let rc = b.rhymeClass?.lowercased(), !rhymeSet.isEmpty, rhymeSet.contains(rc) { s += 3 }
            if syllableTarget > 0 {
                s += max(0.0, 3.0 - Double(abs(b.syllableCount - syllableTarget)))
            }
            if let p = b.primaryTone, let r = toneRewards[p] { s += r * CorpusFeedbackStore.biasScale }
            return s
        }

        // Usable bars: realistic length and multi-word (drop ad-lib fragments / corrupt rows).
        let usable = bars.filter {
            $0.syllableCount >= 4 && $0.syllableCount <= 18 &&
            $0.text.split(separator: " ").count >= 3
        }
        let pool = usable.isEmpty ? bars : usable

        let ranked = pool
            .map { (bar: $0, score: score($0)) }
            .sorted { $0.score > $1.score }
            .prefix(max(limit * 4, limit))
            .map { $0.bar }

        return Array(ranked.shuffled().prefix(limit))
    }

    // MARK: - Parsing (canonical schema: column names on line 0, text_id in col 0)

    private nonisolated static func parse(_ data: Data) -> [CorpusBar] {
        guard let csv = String(data: data, encoding: .utf8) else { return [] }
        let lines = csv.components(separatedBy: .newlines)
        guard lines.count > 3 else { return [] }

        let header = parseLine(lines[0]).map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
        func col(_ names: String...) -> Int? {
            for n in names { if let i = header.firstIndex(of: n) { return i } }
            return nil
        }

        let cText = col("text_bar_line", "text") ?? 6
        let cArtist = col("artist")
        let cSong = col("song")
        let cSyll = col("syllable_count", "syllable_count_recalc")
        let cRhymeClass = col("rhyme_class")
        let cPhonEnd = col("phonetic_ending")
        let cPrimaryTone = col("primary_tone")
        let cSecondaryTone = col("secondary_tone")
        let cAuthority = col("authorityclass")

        var out: [CorpusBar] = []
        out.reserveCapacity(lines.count)

        for i in 1..<lines.count {
            let raw = lines[i]
            if raw.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            let f = parseLine(raw)
            guard f.count > cText else { continue }

            let id = f[0].trimmingCharacters(in: .whitespaces)
            // A real data row's id looks like "artist.song.n"; this skips the 2 preamble/header rows.
            guard id.contains("."), !id.isEmpty else { continue }

            let text = f[cText].trimmingCharacters(in: .whitespaces)
            guard !text.isEmpty, text.lowercased() != "text" else { continue }

            func g(_ idx: Int?) -> String? {
                guard let idx = idx, idx < f.count else { return nil }
                let v = f[idx].trimmingCharacters(in: .whitespaces)
                return v.isEmpty ? nil : v
            }

            let syll = Int(g(cSyll) ?? "") ?? estimateSyllables(text)

            out.append(CorpusBar(
                id: id,
                text: text,
                artist: g(cArtist),
                song: g(cSong),
                syllableCount: syll,
                rhymeClass: g(cRhymeClass),
                phoneticEnding: g(cPhonEnd),
                primaryTone: g(cPrimaryTone)?.lowercased(),
                secondaryTone: g(cSecondaryTone)?.lowercased(),
                authorityClass: g(cAuthority)
            ))
        }
        return out
    }

    /// Quote-aware CSV line splitter (matches the parsers elsewhere in the app).
    private nonisolated static func parseLine(_ line: String) -> [String] {
        var components: [String] = []
        var current = ""
        var inQuotes = false
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                components.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        if !current.isEmpty || line.last == "," {
            components.append(current)
        }
        return components
    }

    /// Rough syllable estimate when the column is missing (~1.5 syllables/word).
    private nonisolated static func estimateSyllables(_ text: String) -> Int {
        let words = text.split(whereSeparator: { $0 == " " }).count
        return max(1, Int(Double(words) * 1.5))
    }
}
