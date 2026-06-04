import Foundation

struct ModelGCorpus: Codable {
    let version: Int
    let bars: [CorpusBar]
    let concepts: [CorpusConcept]
    let brandAttributes: [BrandAttribute]
    let slang: [CorpusSlang]
}

struct CorpusBar: Codable {
    let id: String
    let text: String
    let adlib: String?
    let norm: String
    let artist: String?
    let activeArtist: String?
    let song: String?
    let album: String?
    let section: String?
    let themes: [String]
    let tags: [String]
    let bpm: Int?
    let scale: String?
    let concepts: [String]
    let context: [String]
}

struct CorpusConcept: Codable {
    let name: String
    let category: String
    let parents: [String]
    let aliases: [String]
    let tags: [String]
}

struct BrandAttribute: Codable {
    let brand: String
    let attribute: String
}

struct CorpusSlang: Codable {
    let term: String
    let category: String?
    let themePrimary: String?
    let definition: String?
}
