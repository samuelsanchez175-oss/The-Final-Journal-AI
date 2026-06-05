import Foundation

/// Loads the bundled vault corpus and answers offline retrieval queries.
/// 13k bars decoded once into memory; filters are linear scans (microseconds).
final class ModelGCorpusStore {
    enum CorpusError: Error { case notFound(String) }

    let corpus: ModelGCorpus
    private let conceptIndex: [String: CorpusConcept]

    /// Shared production instance backed by the app-bundled `ModelGCorpus.json`. nil if absent.
    static let shared = try? ModelGCorpusStore()

    init(bundle: Bundle = .main, resource: String = "ModelGCorpus") throws {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw CorpusError.notFound(resource)
        }
        self.corpus = try JSONDecoder().decode(ModelGCorpus.self, from: Data(contentsOf: url))
        self.conceptIndex = Dictionary(
            corpus.concepts.map { ($0.name.lowercased(), $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    var barCount: Int { corpus.bars.count }

    func bars(theme: String) -> [CorpusBar] {
        let t = theme.lowercased()
        return corpus.bars.filter { $0.themes.contains { $0.lowercased() == t } }
    }

    func bars(matching keyword: String) -> [CorpusBar] {
        let k = keyword.lowercased()
        return corpus.bars.filter { $0.norm.contains(k) }
    }

    /// Bars whose `tags` (master-concept taxonomy, e.g. "master-concept/wealth-cars") contain the
    /// topic term as a substring. Powers topic-based retrieval: the corpus `themes` are emotional
    /// tones (confident/luxurious/…), so topical matching must go through tags. Ignores fragments
    /// shorter than 3 chars to avoid noise.
    func bars(tag: String) -> [CorpusBar] {
        let t = tag.lowercased().trimmingCharacters(in: .whitespaces)
        guard t.count >= 3 else { return [] }
        return corpus.bars.filter { $0.tags.contains { $0.lowercased().contains(t) } }
    }

    func concept(named name: String) -> CorpusConcept? { conceptIndex[name.lowercased()] }

    func brandAttributes(brand: String) -> [String] {
        let b = brand.lowercased()
        return corpus.brandAttributes.filter { $0.brand.lowercased() == b }.map(\.attribute)
    }
}
