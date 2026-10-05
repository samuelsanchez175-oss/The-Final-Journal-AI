import Foundation

/// Shapes the bundled corpus into prompt-ready exemplars + vocab for v4 generation.
/// Lexical (theme filter + keyword overlap, deduped by normalized text). The same
/// `retrieve(...)` signature is the seam where Phase 2b semantic embeddings drop in.
struct ModelGCorpusRetriever {
    let store: ModelGCorpusStore
    var embeddingIndex: ModelGEmbeddingIndex? = nil

    struct Result {
        let exemplars: [CorpusBar]
        let vocab: [String]
    }

    /// Multi-signal lexical retrieval (+ optional semantic rerank), ordered most-specific first:
    /// draft keywords → topic tags → tonal floor. The corpus `themes` ARE the tone vocab
    /// (confident/luxurious/…), so `tones` reliably hit; `topics` match the master-concept `tags`.
    /// Never returns empty when a tone is known (tonal floor), so v4 always has bars to ground on.
    func retrieve(tones: [String] = [], topics: [String] = [], draft: String,
                  brands: [String] = [], k: Int) -> Result {
        var pool: [CorpusBar] = []
        // 1. Note-specific: draft keywords → substring on the lyric norm.
        pool += Self.keywords(from: draft).flatMap { store.bars(matching: $0) }
        // 2. Topical: theme tokens / jargon / user topics → master-concept tags.
        pool += topics.flatMap { store.bars(tag: $0) }
        // 3. Tonal floor: emotional tone → corpus themes (broad, reliable).
        pool += tones.flatMap { store.bars(theme: $0) }
        // 4. Semantic rerank when the on-device index is warm: rank by cosine to the draft over the
        //    lexical pool (or the whole corpus if it's thin) so relevance wins over scan order.
        if embeddingIndex?.isReady == true {
            let base = pool.count >= k ? pool : store.corpus.bars
            if let ranked = embeddingIndex?.rank(bars: base, near: draft, k: max(k * 3, k)) {
                pool = ranked
            }
        }
        // 5. Grounding floor: if a tone was requested but nothing matched, ground in the corpus so
        //    v4 always has reference bars. Gated on `!tones.isEmpty` so Ghost (which passes no tones
        //    and reads `exemplars.isEmpty` to test if a word is on-brand) keeps its semantics.
        if pool.isEmpty, !tones.isEmpty { pool = store.corpus.bars }
        // Dedup by normalized text; cap at k (most-specific signals survive the cap).
        // Drop ad-libs / fragments ("Yeah", "Ah") — they are metronome clicks, not bars.
        var seen = Set<String>(), deduped: [CorpusBar] = []
        for b in pool where !b.norm.isEmpty && seen.insert(b.norm).inserted {
            guard Self.isRealBar(b.text) else { continue }
            deduped.append(b)
            if deduped.count >= k { break }
        }
        let vocab = brands.flatMap { store.brandAttributes(brand: $0) }
        return Result(exemplars: deduped, vocab: Array(Set(vocab)).sorted())
    }

    private static func keywords(from draft: String) -> [String] {
        let words = draft.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 4 }
        return Array(words.prefix(6))
    }

    /// Ad-lib / fragment filter. Needs ≥4 tokens and ≥3 content words.
    nonisolated static func isRealBar(_ text: String) -> Bool {
        let words = text.split(whereSeparator: { $0.isWhitespace || $0.isNewline })
        guard words.count >= 4 else { return false }
        let fragments: Set<String> = ["yeah", "yah", "ah", "ooh", "uh", "skrrt", "skrr", "ayy", "ay", "woah", "whoa"]
        let content = words.filter { raw in
            let t = raw.lowercased().trimmingCharacters(in: .punctuationCharacters)
            return t.count >= 2 && !fragments.contains(t)
        }
        return content.count >= 3
    }

    /// 4-bar windows whose syllable map sits near `targetSyllables`. Used as a CLOCK only —
    /// callers must not inject these bar texts as lyric BLUEPRINT.
    func retrieveFlow(targetSyllables: Int, k: Int = 1) -> [FlowExemplar] {
        let real = store.corpus.bars.filter { Self.isRealBar($0.text) }
        let grouped = Dictionary(grouping: real) { bar -> String in
            let song = (bar.song ?? "").trimmingCharacters(in: .whitespaces)
            return song.isEmpty ? bar.id : song
        }
        var scored: [(distance: Int, exemplar: FlowExemplar)] = []
        for (_, bars) in grouped where bars.count >= 4 {
            for i in 0...(bars.count - 4) {
                let chunk = Array(bars[i..<(i + 4)])
                let map = chunk.map { SyllableEngine.lineSyllableCount($0.text) }
                guard map.allSatisfy({ $0 > 0 }) else { continue }
                let avg = map.reduce(0, +) / 4
                let distance = abs(avg - targetSyllables) + map.map { abs($0 - targetSyllables) }.reduce(0, +) / 4
                let exemplar = FlowExemplar(
                    bars: chunk.map(\.text),
                    syllableMap: map,
                    stressHint: "end-loaded, last stress of each bar in the punch window (beats 3–4)",
                    source: .corpusMap
                )
                scored.append((distance, exemplar))
            }
        }
        scored.sort { $0.distance < $1.distance }
        var seen = Set<String>()
        var out: [FlowExemplar] = []
        for item in scored {
            let key = item.exemplar.syllableMap.map(String.init).joined(separator: "-")
            guard seen.insert(key).inserted else { continue }
            out.append(item.exemplar)
            if out.count >= k { break }
        }
        return out
    }
}
