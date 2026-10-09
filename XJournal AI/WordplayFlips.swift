import Foundation

struct WordplayEntry: Codable, Equatable, Sendable {
    struct Span: Codable, Equatable, Sendable {
        let text: String
        let start: Int
        let end: Int
        let heard: String?
    }
    let chip: String          // green heard-as noun = chip text
    let artist: String
    let song: String
    let bar: String
    let setupSpans: [Span]    // blue
    let playSpans: [Span]     // yellow
    let heardAs: String       // full green heard_as as written
    let geniusURL: String
    let image: String         // "noun-…" asset actually used
    let imageDecision: String // reused | created
    let sourceLine: Int       // 1-based line in the source jsonl
}

enum WordplayFlips {
    static let all: [WordplayEntry] = {
        guard let url = Bundle.main.url(forResource: "WordplayFlips", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rows = try? JSONDecoder().decode([WordplayEntry].self, from: data) else { return [] }
        return rows
    }()
    static func entry(for chip: String) -> WordplayEntry? {
        let k = NounBankMark.normalize(chip)
        return all.first { NounBankMark.normalize($0.chip) == k }
    }
}
