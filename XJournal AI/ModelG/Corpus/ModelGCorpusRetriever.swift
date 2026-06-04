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

    func retrieve(theme: String?, draft: String, brands: [String], k: Int) -> Result {
        var pool = theme.map { store.bars(theme: $0) } ?? []
        if pool.count < k {
            let kw = Self.keywords(from: draft)
            let extra = kw.flatMap { store.bars(matching: $0) }
            pool.append(contentsOf: extra)
        }
        let semantic = embeddingIndex?.isReady == true
        if pool.count < k, semantic { pool = store.corpus.bars }
        if semantic, let ranked = embeddingIndex?.rank(bars: pool, near: draft, k: k * 3) {
            pool = ranked
        }
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
