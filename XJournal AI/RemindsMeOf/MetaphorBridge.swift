import Foundation
import NaturalLanguage

protocol LineEmbedding: Sendable {
    func embed(_ text: String) -> [Float]?
}

struct NLLineEmbedding: LineEmbedding {
    private let model: NLEmbedding?
    init(model: NLEmbedding? = NLEmbedding.sentenceEmbedding(for: .english)) {
        self.model = model
    }
    func embed(_ text: String) -> [Float]? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let v = model?.vector(for: trimmed.lowercased()) else { return nil }
        return v.map { Float($0) }
    }
}

/// Query-time metaphor labels + rerank. Prototypes are tiny; the 1.7M vault is never embedded.
final class MetaphorBridge: @unchecked Sendable {
    static let shared = MetaphorBridge()

    private let embedding: LineEmbedding
    private let lock = NSLock()
    private var prototypeVectors: [String: [Float]] = [:]

    init(embedding: LineEmbedding = NLLineEmbedding()) {
        self.embedding = embedding
        warmPrototypes()
    }

    var isEmbeddingAvailable: Bool {
        embedding.embed("empty glass") != nil
    }

    func label(_ text: String) -> MetaphorPrototype? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let vector = embedding.embed(trimmed),
           let best = bestPrototype(vector: vector),
           best.score >= 0.32 {
            return best.proto
        }
        return bestLexical(in: trimmed)
    }

    /// Keyword hits only — used to expand FTS even when NLEmbedding is missing.
    func lexicalMatches(in text: String) -> [MetaphorPrototype] {
        let scored = MetaphorPrototypeCatalog.all.compactMap { proto -> (MetaphorPrototype, Int)? in
            let n = termHits(proto, in: text)
            return n > 0 ? (proto, n) : nil
        }
        .sorted { $0.1 > $1.1 }
        return scored.map(\.0)
    }

    func extraSearchTerms(for line: String) -> [String] {
        var terms: [String] = []
        var seen = Set<String>()
        for proto in lexicalMatches(in: line) {
            for term in proto.ftsTerms.prefix(10) where seen.insert(term.lowercased()).inserted {
                terms.append(term)
            }
        }
        return terms
    }

    func decorate(
        _ cards: [SimilarMeaningPipeline.ScoredCard],
        query: String
    ) -> [SimilarMeaningPipeline.ScoredCard] {
        let queryLabel = label(query)
        let queryVec = embedding.embed(query)
        return cards.map { card in
            var hood = card.neighborhood
            if hood.metaphorLabel.isEmpty, let tagged = label(hood.anchor) {
                hood.metaphorId = tagged.id
                hood.metaphorLabel = tagged.label
            }
            var score = card.score
            if let queryLabel, hood.metaphorId == queryLabel.id {
                score = min(1, score + 0.2)
            }
            if let queryVec, let candVec = embedding.embed(hood.anchor) {
                let cosine = Double(VectorMath.cosine(queryVec, candVec))
                score = min(1, score * 0.68 + max(0, cosine) * 0.32)
            }
            return SimilarMeaningPipeline.ScoredCard(neighborhood: hood, score: score)
        }
        .sorted { $0.score > $1.score }
    }

    func rerank(query: String, lines: [String]) -> [String] {
        guard let q = embedding.embed(query) else { return lines }
        return lines
            .map { line -> (String, Float) in
                (line, embedding.embed(line).map { VectorMath.cosine(q, $0) } ?? 0)
            }
            .sorted { $0.1 > $1.1 }
            .map(\.0)
    }

    // MARK: - Private

    private func warmPrototypes() {
        var map: [String: [Float]] = [:]
        for proto in MetaphorPrototypeCatalog.all {
            if let v = embedding.embed(proto.picture) {
                map[proto.id] = v
            }
        }
        lock.lock()
        prototypeVectors = map
        lock.unlock()
    }

    private func bestPrototype(vector: [Float]) -> (proto: MetaphorPrototype, score: Float)? {
        lock.lock()
        let stored = prototypeVectors
        lock.unlock()
        var best: (MetaphorPrototype, Float)?
        for proto in MetaphorPrototypeCatalog.all {
            guard let pv = stored[proto.id] else { continue }
            let score = VectorMath.cosine(vector, pv)
            if best == nil || score > best!.1 {
                best = (proto, score)
            }
        }
        return best.map { ($0.0, $0.1) }
    }

    private func bestLexical(in text: String) -> MetaphorPrototype? {
        lexicalMatches(in: text).first
    }

    private func termHits(_ proto: MetaphorPrototype, in text: String) -> Int {
        let lower = text.lowercased()
        var hits = 0
        for term in proto.ftsTerms {
            let needle = term.lowercased()
            guard needle.count >= 3 else { continue }
            if hasWord(needle, in: lower) { hits += 1 }
        }
        if hasWord(proto.label.lowercased(), in: lower) { hits += 2 }
        return hits
    }

    private func hasWord(_ word: String, in lower: String) -> Bool {
        guard let regex = try? NSRegularExpression(
            pattern: "\\b\(NSRegularExpression.escapedPattern(for: word))\\b"
        ) else {
            return lower.contains(word)
        }
        let range = NSRange(lower.startIndex..., in: lower)
        return regex.firstMatch(in: lower, range: range) != nil
    }
}
