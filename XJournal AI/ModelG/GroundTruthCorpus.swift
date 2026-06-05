//
//  GroundTruthCorpus.swift
//  XJournal AI
//
//  Model G v4 — the RAG retrieval layer.
//
//  Prefers the CHRONOLOGICAL corpus (chronological_rap_bars_MODEL_G.csv): the real bars in true
//  song order, with section + active-artist attribution and tone/rhyme metadata, built from the
//  vault's Excel source of truth (see build_chronological_corpus.py). Because order is preserved,
//  retrieval can hand the LLM real consecutive couplets — not isolated, alphabetized lines.
//
//  Falls back to the alphabetized ground_truth_rap_bars_MODEL_G.csv if the chronological file isn't
//  bundled. Either way it indexes the columns retrieval needs: tone, rhyme_class, syllable_count.
//

import Foundation

/// One real bar from the ground-truth corpus, with the metadata Model G retrieves on.
struct CorpusBar: Identifiable, Hashable {
    let id: String
    let text: String            // the actual lyric
    let artist: String?         // the track's billed artist
    let song: String?
    let songId: String          // stable per-song key (for chronological grouping / couplets)
    let lineNo: Int             // chronological position within the song (0 = unknown)
    let section: String?        // e.g. "Chorus", "Verse 1"
    let activeArtist: String?   // who performs this line (from [Section: Artist] headers)
    let syllableCount: Int
    let rhymeClass: String?     // e.g. "ood"
    let phoneticEnding: String? // e.g. "F EY1 S AH0 Z"
    let primaryTone: String?    // e.g. "luxurious" (lowercased)
    let secondaryTone: String?  // (lowercased)
    let authorityClass: String?
    let concepts: Set<String>   // theme/meaning tags (RapConceptLexicon): cars, watches, money…

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CorpusBar, rhs: CorpusBar) -> Bool { lhs.id == rhs.id }
}

/// Loads + retrieves the ground-truth corpus for Model G v4. Singleton; load once.
final class GroundTruthCorpus {
    static let shared = GroundTruthCorpus()
    private init() {}

    private(set) var bars: [CorpusBar] = []
    private(set) var isLoaded: Bool = false
    /// songId → that song's bars in chronological order (for couplets / context windows).
    private var bySong: [String: [CorpusBar]] = [:]

    private static let chronologicalResource = "chronological_rap_bars_MODEL_G"
    private static let alphabetizedResource = "ground_truth_rap_bars_MODEL_G"

    // MARK: - Load

    /// Load + parse the corpus from the app bundle. Safe to call repeatedly (idempotent).
    func loadIfNeeded() async {
        guard !isLoaded else { return }

        if let url = Bundle.main.url(forResource: Self.chronologicalResource, withExtension: "csv"),
           let data = try? Data(contentsOf: url) {
            let parsed = await Task.detached(priority: .utility) { Self.parseChronological(data) }.value
            finishLoad(parsed, label: "chronological")
            return
        }
        if let url = Bundle.main.url(forResource: Self.alphabetizedResource, withExtension: "csv"),
           let data = try? Data(contentsOf: url) {
            let parsed = await Task.detached(priority: .utility) { Self.parseAlphabetized(data) }.value
            finishLoad(parsed, label: "alphabetized (fallback)")
            return
        }

        print("❌ GroundTruthCorpus: no corpus CSV found in bundle — RAG corpus is EMPTY. " +
              "Add chronological_rap_bars_MODEL_G.csv (or the alphabetized fallback) to the app target.")
        isLoaded = true
    }

    private func finishLoad(_ parsed: [CorpusBar], label: String) {
        bars = parsed
        var grouped: [String: [CorpusBar]] = [:]
        for b in parsed { grouped[b.songId, default: []].append(b) }
        for k in grouped.keys { grouped[k]?.sort { $0.lineNo < $1.lineNo } }
        bySong = grouped
        isLoaded = true
        print("✅ GroundTruthCorpus: loaded \(parsed.count) real bars across \(grouped.count) songs (\(label)).")
    }

    // MARK: - Retrieve

    /// Retrieve up to `limit` real bars closest to the request, to anchor cadence & rhyme.
    /// Ranking: tone match (primary +3, secondary +1) + rhyme-class overlap (+3) + syllable
    /// proximity (≤ +3) + learned per-tone feedback (Phase 3). Empty `tones`/`rhymeClasses` don't
    /// constrain that axis. A top window is sampled (not strictly top-k) so back-to-back verses vary.
    func retrieve(syllableTarget: Int,
                  tones: [String] = [],
                  rhymeClasses: [String] = [],
                  concepts: [String] = [],
                  limit: Int = 4) -> [CorpusBar] {
        guard !bars.isEmpty, limit > 0 else { return [] }

        let toneSet = Set(tones.map { $0.lowercased() })
        let rhymeSet = Set(rhymeClasses.map { $0.lowercased() })
        let conceptSet = Set(concepts)
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
            // Phase 5: reward bars that share the entry's concepts (theme/meaning match).
            if !conceptSet.isEmpty { s += Double(b.concepts.intersection(conceptSet).count) * 2.5 }
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

    /// The retrieved line plus the next line in the same song — a real consecutive couplet — when
    /// available, so exemplars show true cadence/rhyme ACROSS bars, not an isolated line. Falls back
    /// to the single line (e.g. when loaded from the alphabetized corpus, which has no true order).
    func couplet(for bar: CorpusBar) -> String {
        guard bar.lineNo > 0, let seq = bySong[bar.songId],
              let i = seq.firstIndex(where: { $0.id == bar.id }), i + 1 < seq.count else {
            return bar.text
        }
        return bar.text + " / " + seq[i + 1].text
    }

    // MARK: - Parsing

    /// Chronological corpus: header on line 0 with named columns (order, song_id, song, artist,
    /// active_artist, album, section, line_no, text, primary_tone, secondary_tone, rhyme_class,
    /// phonetic_ending, syllable_count, authority).
    private nonisolated static func parseChronological(_ data: Data) -> [CorpusBar] {
        guard let csv = String(data: data, encoding: .utf8) else { return [] }
        let lines = csv.components(separatedBy: .newlines)
        guard lines.count > 1 else { return [] }

        let header = parseLine(lines[0]).map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
        func col(_ name: String) -> Int? { header.firstIndex(of: name) }
        let cOrder = col("order"), cSongId = col("song_id"), cSong = col("song"), cArtist = col("artist")
        let cActive = col("active_artist"), cSection = col("section"), cLineNo = col("line_no")
        let cText = col("text") ?? 8
        let cPrim = col("primary_tone"), cSec = col("secondary_tone"), cRC = col("rhyme_class")
        let cPhon = col("phonetic_ending"), cSyl = col("syllable_count"), cAuth = col("authority")

        var out: [CorpusBar] = []
        out.reserveCapacity(lines.count)
        for i in 1..<lines.count {
            let raw = lines[i]
            if raw.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            let f = parseLine(raw)
            guard f.count > cText else { continue }
            func g(_ idx: Int?) -> String? {
                guard let idx = idx, idx < f.count else { return nil }
                let v = f[idx].trimmingCharacters(in: .whitespaces)
                return v.isEmpty ? nil : v
            }
            guard let text = g(cText) else { continue }
            let songId = g(cSongId) ?? (g(cSong)?.lowercased().filter { $0.isLetter || $0.isNumber } ?? "unknown")
            let lineNo = Int(g(cLineNo) ?? "") ?? 0
            let syll = Int(g(cSyl) ?? "") ?? estimateSyllables(text)
            out.append(CorpusBar(
                id: "\(songId).\(g(cOrder) ?? String(lineNo))",
                text: text, artist: g(cArtist), song: g(cSong),
                songId: songId, lineNo: lineNo, section: g(cSection), activeArtist: g(cActive),
                syllableCount: syll, rhymeClass: g(cRC), phoneticEnding: g(cPhon),
                primaryTone: g(cPrim)?.lowercased(), secondaryTone: g(cSec)?.lowercased(),
                authorityClass: g(cAuth), concepts: RapConceptLexicon.concepts(in: text)
            ))
        }
        return out
    }

    /// Alphabetized fallback: canonical schema (names on line 0, text_id in col 0, lyric in
    /// text_bar_line). text_id is "song.N" — N is the *alphabetical* index here, so couplets are
    /// not truly chronological in this mode, but tone/rhyme/syllable retrieval still works.
    private nonisolated static func parseAlphabetized(_ data: Data) -> [CorpusBar] {
        guard let csv = String(data: data, encoding: .utf8) else { return [] }
        let lines = csv.components(separatedBy: .newlines)
        guard lines.count > 3 else { return [] }

        let header = parseLine(lines[0]).map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
        func col(_ names: String...) -> Int? {
            for n in names { if let i = header.firstIndex(of: n) { return i } }
            return nil
        }
        let cText = col("text_bar_line", "text") ?? 6
        let cArtist = col("artist"), cSong = col("song")
        let cSyl = col("syllable_count", "syllable_count_recalc"), cRC = col("rhyme_class")
        let cPhon = col("phonetic_ending"), cPrim = col("primary_tone"), cSec = col("secondary_tone")
        let cAuth = col("authorityclass")

        var out: [CorpusBar] = []
        out.reserveCapacity(lines.count)
        for i in 1..<lines.count {
            let raw = lines[i]
            if raw.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            let f = parseLine(raw)
            guard f.count > cText else { continue }
            let id = f[0].trimmingCharacters(in: .whitespaces)
            guard id.contains("."), !id.isEmpty else { continue }
            let text = f[cText].trimmingCharacters(in: .whitespaces)
            guard !text.isEmpty, text.lowercased() != "text" else { continue }
            func g(_ idx: Int?) -> String? {
                guard let idx = idx, idx < f.count else { return nil }
                let v = f[idx].trimmingCharacters(in: .whitespaces)
                return v.isEmpty ? nil : v
            }
            let parts = id.split(separator: ".")
            let lineNo = Int(parts.last.map(String.init) ?? "") ?? 0
            let songId = parts.count > 1 ? parts.dropLast().joined(separator: ".") : id
            let syll = Int(g(cSyl) ?? "") ?? estimateSyllables(text)
            out.append(CorpusBar(
                id: id, text: text, artist: g(cArtist), song: g(cSong),
                songId: songId, lineNo: lineNo, section: nil, activeArtist: g(cArtist),
                syllableCount: syll, rhymeClass: g(cRC), phoneticEnding: g(cPhon),
                primaryTone: g(cPrim)?.lowercased(), secondaryTone: g(cSec)?.lowercased(),
                authorityClass: g(cAuth), concepts: RapConceptLexicon.concepts(in: text)
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
