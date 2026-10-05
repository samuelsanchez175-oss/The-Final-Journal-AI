import Foundation

/// Drops a catalog mention that is only the name plus a shoutout or a status word.
/// A line stays when another picture is still set up around the name.
nonisolated enum NounMentionWorth {
    static func keeps(_ line: String, phrases: [String]) -> Bool {
        var text = fold(line)
        let needles = phrases.map(fold).filter { !$0.isEmpty }.sorted { $0.count > $1.count }
        for needle in needles {
            text = removeBounded(needle, from: text)
        }
        for tag in tags {
            text = removeBounded(tag, from: text)
        }
        let content = text.split(whereSeparator: \.isWhitespace).map(String.init).filter { !fillers.contains($0) }
        if content.count >= 2 { return true }
        if content.count == 1, let only = content.first, only.count >= 6 { return true }
        return false
    }

    /// Lowercase, apostrophes removed, everything else split into spaces.
    private static func fold(_ raw: String) -> String {
        var scalars: [UnicodeScalar] = []
        scalars.reserveCapacity(raw.unicodeScalars.count)
        for scalar in raw.lowercased().unicodeScalars {
            if scalar == "'" || scalar == "\u{2019}" || scalar == "\u{2018}" { continue }
            if CharacterSet.alphanumerics.contains(scalar) {
                scalars.append(scalar)
            } else {
                scalars.append(" ")
            }
        }
        return String(String.UnicodeScalarView(scalars))
    }

    private static func removeBounded(_ needle: String, from text: String) -> String {
        let pattern = "(?<![A-Za-z0-9])" + NSRegularExpression.escapedPattern(for: needle) + "(?![A-Za-z0-9])"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: " ")
    }

    /// Shoutout formulas, longest first, already folded.
    private static let tags = [
        "you know what im saying",
        "you know what im sayin",
        "know what i mean",
        "rest in peace",
        "you feel me",
        "thats facts",
        "my niggas",
        "my homies",
        "long live",
        "shout out",
        "shoutout",
        "for real",
        "my nigga",
        "my homie",
        "no cap",
        "on god",
        "r i p",
        "my boy"
    ]

    private static let fillers: Set<String> = [
        "a", "an", "the", "and", "or", "but", "if", "of", "to", "in", "on", "at", "for", "from",
        "with", "by", "as", "into", "onto", "over", "under", "out", "up", "down", "off", "about",
        "after", "than", "then", "so", "just", "like", "feel",
        "i", "me", "my", "mine", "im", "ive", "id", "ill", "you", "your", "youre", "yours",
        "we", "our", "ours", "they", "them", "their", "he", "she", "it", "its", "his", "her", "him", "us",
        "is", "am", "are", "was", "were", "be", "been", "being", "do", "did", "does", "dont", "didnt",
        "aint", "got", "get",
        "this", "that", "these", "those", "there", "here",
        "what", "who", "when", "where", "why", "how",
        "cause", "cuz", "cos", "know", "sayin", "saying", "mean",
        "still", "straight", "good", "great", "real", "always", "forever", "true", "facts",
        "period", "fr", "deadass", "yeah", "yup", "ayy", "uh", "hah", "haha", "man", "bro",
        "shit", "bitch", "bitches", "nigga", "niggas", "fucking", "fuckin", "motherfucking",
        "motherfuckin", "motherfucker", "motherfuckers", "lil",
        "coolin", "cooling", "chillin", "chilling", "shoutout", "rip", "homie", "homies"
    ]
}
