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
        var seen = Set<String>(), deduped: [CorpusBar] = []
        for b in pool where !b.norm.isEmpty && seen.insert(b.norm).inserted {
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
}
