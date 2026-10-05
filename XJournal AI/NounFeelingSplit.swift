import Foundation

/// A feeling chip keeps every line. Plain uses of the word stay with the emotion.
/// A line moves to the literal list only when the word is doing some other job.
nonisolated enum NounFeelingSplit {
    enum Kind: Equatable, Sendable {
        case feeling
        case literal
    }

    static func kind(word: String, line: String) -> Kind {
        let key = fold(word)
        let text = fold(line)
        guard containsPhrase(key, in: text) else { return .feeling }
        return isLiteral(key: key, line: text) ? .literal : .feeling
    }

    private static func isLiteral(key: String, line: String) -> Bool {
        switch key {
        case "alone":
            return aloneIsLiteral(line)
        case "content":
            return contentIsLiteral(line)
        case "hurt":
            return hurtIsLiteral(line)
        case "mad":
            return madIsLiteral(line)
        case "love":
            return containsAny(line, ["make love", "made love", "making love", "makin love", "love boat"])
        case "fear":
            return line.contains("fear of god")
        case "happy":
            return containsAny(line, ["trigger happy", "chopper happy", "happy birthday", "happy new year", "happy holidays"])
        case "abandoned":
            return tokenAfter("abandoned", in: line).map { places.contains($0) } ?? false
        case "spite":
            return line.contains("in spite") || line.contains("despite")
        case "lonely":
            return containsAny(line, ["by my lonely", "lil lonely"])
        case "numb":
            return numbIsLiteral(line)
        case "scarred":
            return scarredIsLiteral(line)
        case "pain":
            return painIsLiteral(line)
        case "bitter":
            return containsAny(line, ["bitter beer", "bitter taste", "bitter lemon", "bitter coffee", "bitter pill"])
        case "salty":
            return containsAny(line, ["salty food", "salty chips", "salty fries", "tastes salty", "taste salty"])
        default:
            return false
        }
    }

    private static func aloneIsLiteral(_ line: String) -> Bool {
        if line.contains("never alone") { return true }
        if matches("(leave|leaves|leavin|leaving)( \\w+){0,3} alone", line) { return true }
        if line.contains("jet") && line.contains("alone") { return true }
        if matches("(fly|flyin|flying|flew|flight).{0,24}alone", line) { return true }
        if line.contains("we alone") && (line.contains("lock") || line.contains("door")) { return true }
        return false
    }

    private static func contentIsLiteral(_ line: String) -> Bool {
        if matches("(film|filmin|filming|shoot|shootin|shooting|post|posted|posting|tape|taping|record|recording).{0,24}content", line) {
            return true
        }
        return containsAny(line, [
            "some content", "the content", "my content", "your content", "our content",
            "this content", "that content", "for content", "up for content"
        ])
    }

    private static func hurtIsLiteral(_ line: String) -> Bool {
        if containsAny(line, ["hurt my feelings", "hurt my heart", "hurt inside", "feel hurt", "feeling hurt"]) {
            return false
        }
        if containsAny(line, ["cant hurt", "cannot hurt", "wont hurt", "dont hurt", "wouldnt hurt"]) {
            return true
        }
        if containsAny(line, ["hurt my glock", "hurt my gun", "hurt my chopper", "hurt my stick", "hurt my draco", "hurt my switch"]) {
            return true
        }
        return line.contains("crunch time")
    }

    private static func madIsLiteral(_ line: String) -> Bool {
        guard let next = tokenAfter("mad", in: line) else { return false }
        return intensifiers.contains(next)
    }

    private static func numbIsLiteral(_ line: String) -> Bool {
        if line.contains("emotion") || containsPhrase("heart", in: line) || line.contains("dead inside") { return false }
        return containsAny(line, ["perc", "percs", "xan", "xanax", "lean", "pill", "pills", "molly", "drank", "geeked"])
    }

    private static func scarredIsLiteral(_ line: String) -> Bool {
        if line.contains("emotion") || containsPhrase("heart", in: line) { return false }
        return containsAny(line, ["bullet", "gun", "stab", "shot", "knife", "wound", "scarred up"])
    }

    private static func painIsLiteral(_ line: String) -> Bool {
        if containsAny(line, ["pain in my heart", "heart pain", "feel the pain", "feel pain", "emotional pain"]) {
            return false
        }
        return containsAny(line, [
            "back pain", "pain in my back", "neck pain", "pain in my neck",
            "stomach pain", "tooth pain", "head pain", "knee pain"
        ])
    }

    private static let intensifiers: Set<String> = [
        "rich", "comma", "commas", "band", "bands", "rack", "racks", "money", "guap", "bread",
        "chicken", "pack", "packs", "long", "early", "late", "high", "drunk", "quiet", "loud",
        "deep", "thick", "crazy", "different", "hard", "fast", "slow", "big", "small", "work", "love"
    ]

    private static let places: Set<String> = [
        "building", "buildings", "house", "home", "warehouse", "facility", "facilities",
        "garage", "truck", "ship", "car", "lot", "block", "street", "school", "factory",
        "mall", "apartment", "crib", "spot", "place", "city"
    ]

    private static func containsAny(_ line: String, _ phrases: [String]) -> Bool {
        phrases.contains { containsPhrase($0, in: line) }
    }

    private static func containsPhrase(_ phrase: String, in line: String) -> Bool {
        matches("(?<![a-z0-9])" + NSRegularExpression.escapedPattern(for: phrase) + "(?![a-z0-9])", line)
    }

    private static func tokenAfter(_ phrase: String, in line: String) -> String? {
        let pattern = "(?<![a-z0-9])" + NSRegularExpression.escapedPattern(for: phrase) + "(?![a-z0-9])\\s+([a-z0-9]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: line) else { return nil }
        return String(line[range])
    }

    private static func matches(_ pattern: String, _ line: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(line.startIndex..., in: line)
        return regex.firstMatch(in: line, range: range) != nil
    }

    private static func fold(_ raw: String) -> String {
        var scalars: [UnicodeScalar] = []
        scalars.reserveCapacity(raw.unicodeScalars.count)
        for scalar in raw.lowercased().unicodeScalars {
            if scalar == "'" || scalar == "\u{2019}" || scalar == "\u{2018}" { continue }
            scalars.append(CharacterSet.alphanumerics.contains(scalar) ? scalar : " ")
        }
        return String(String.UnicodeScalarView(scalars))
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}
