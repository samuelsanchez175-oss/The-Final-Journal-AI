import Foundation
import NaturalLanguage

/// On-device semantic index over the corpus bars (Apple NLEmbedding).
/// Builds in the background on first use; degrades to nil (caller falls back to lexical) until ready / if unavailable.
final class ModelGEmbeddingIndex {
    static let shared = ModelGEmbeddingIndex()

    private let embedding = NLEmbedding.sentenceEmbedding(for: .english)
    private let lock = NSLock()
    private var vectors: [String: [Float]] = [:]
    private var _isReady = false
    private var building = false
    private let buildQueue = DispatchQueue(label: "modelg.embedding.build", qos: .utility)

    var isAvailable: Bool { embedding != nil }
    var isReady: Bool { lock.lock(); defer { lock.unlock() }; return _isReady }

    func embed(_ text: String) -> [Float]? {
        guard let v = embedding?.vector(for: text.lowercased()) else { return nil }
        return v.map { Float($0) }
    }

    func buildIfNeeded(bars: [CorpusBar]) {
        guard isAvailable else { return }
        lock.lock()
        if _isReady || building { lock.unlock(); return }
        building = true
        lock.unlock()
        buildQueue.async { [weak self] in
            guard let self else { return }
            var map: [String: [Float]] = [:]; map.reserveCapacity(bars.count)
            for b in bars where !b.text.isEmpty { if let v = self.embed(b.text) { map[b.id] = v } }
            self.lock.lock(); self.vectors = map; self._isReady = true; self.building = false; self.lock.unlock()
        }
    }

    func rank(bars: [CorpusBar], near query: String, k: Int) -> [CorpusBar]? {
        guard isReady, let q = embed(query) else { return nil }
        lock.lock(); let v = vectors; lock.unlock()
        return Self.rankByVectors(bars: bars, vectors: v, query: q, k: k)
    }

    static func rankByVectors(bars: [CorpusBar], vectors: [String: [Float]], query: [Float], k: Int) -> [CorpusBar] {
        bars.compactMap { bar in vectors[bar.id].map { (bar, VectorMath.cosine($0, query)) } }
            .sorted { $0.1 > $1.1 }
            .prefix(k).map { $0.0 }
    }
}
