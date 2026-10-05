import Foundation

nonisolated struct SignatureHit: Equatable, Sendable {
    var person: PersonSignature
    var aspect: SignatureAspect
    var phrase: String
}

nonisolated struct SignatureTail: Equatable, Sendable {
    var insert: String
    var spoken: String
    var aspectId: String
    var aspectLabel: String
    var personId: String
}

/// Matches a public picture already in the line and offers the short name.
nonisolated enum SignatureBridge {
    static func hits(in line: String) -> [SignatureHit] {
        let text = normalized(line)
        guard !text.isEmpty else { return [] }
        var found: [SignatureHit] = []
        for person in SignatureCatalog.all {
            if suppressed(person, in: text) { continue }
            guard let best = bestAspect(person, in: text) else { continue }
            found.append(SignatureHit(person: person, aspect: best.aspect, phrase: best.phrase))
        }
        return found
    }

    /// Tail only when the line has the picture and has not already said the name.
    /// A producer tag is allowed to contain the name, because the tag is the picture.
    static func tails(in line: String) -> [SignatureTail] {
        let text = normalized(line)
        return hits(in: line).compactMap { hit in
            let aside = hit.aspect.kind == .tag ? hit.phrase : nil
            guard !nameAlreadyPresent(hit.person, in: text, asideFrom: aside) else { return nil }
            return tail(for: hit, insert: "like \(hit.person.spoken)")
        }
    }

    /// The line already started a song, album, catchphrase, or tag. Offer the missing words and the name.
    static func completions(in line: String) -> [SignatureTail] {
        let text = normalized(line)
        let lineTokens = tokens(in: text)
        guard lineTokens.count >= 2 else { return [] }
        let open = Set(hits(in: line).map(\.person.id))
        var found: [SignatureTail] = []
        for person in SignatureCatalog.all {
            if open.contains(person.id) || suppressed(person, in: text) { continue }
            guard let best = bestCompletion(person, tokens: lineTokens, text: text) else { continue }
            let prefix = best.prefix.joined(separator: " ")
            let aside = best.aspect.kind == .tag ? prefix : nil
            if nameAlreadyPresent(person, in: text, asideFrom: aside) { continue }
            let insert = "\(best.rest) like \(person.spoken)"
            found.append(SignatureTail(
                insert: insert,
                spoken: person.spoken,
                aspectId: best.aspect.id,
                aspectLabel: best.aspect.label,
                personId: person.id
            ))
        }
        return found
    }

    /// The name is already in the line, so offer the picture instead of a second name.
    static func pictures(in line: String) -> [SignatureTail] {
        let text = normalized(line)
        let matched = hits(in: line)
        var field = text
        for hit in matched {
            field = removingFirstPhrase(hit.phrase, from: field)
        }
        let open = Set(matched.map(\.person.id))
        var found: [SignatureTail] = []
        for person in SignatureCatalog.all {
            if open.contains(person.id) || suppressed(person, in: text) { continue }
            guard nameAlreadyPresent(person, in: field) else { continue }
            for aspect in person.aspects {
                let insert = aspect.label
                guard !containsPhrase(insert, in: text) else { continue }
                found.append(SignatureTail(
                    insert: insert,
                    spoken: person.spoken,
                    aspectId: aspect.id,
                    aspectLabel: aspect.label,
                    personId: person.id
                ))
                if found.count == 3 { return found }
            }
        }
        return found
    }

    /// Tails first, then a title the line has started, then pictures for a name already said. Three total.
    static func offers(in line: String) -> [SignatureTail] {
        var out = tails(in: line)
        let tailed = Set(out.map(\.personId))
        if out.count < 3 {
            for tail in completions(in: line) where !tailed.contains(tail.personId) {
                out.append(tail)
                if out.count == 3 { return out }
            }
        }
        if out.count < 3 {
            let used = Set(out.map(\.personId))
            for tail in pictures(in: line) where !used.contains(tail.personId) {
                out.append(tail)
                if out.count == 3 { break }
            }
        }
        return Array(out.prefix(3))
    }

    /// People already named, so a later pass can offer their picture instead of another name.
    static func aspects(mentioningSpokenName line: String) -> [PersonSignature] {
        let text = normalized(line)
        guard !text.isEmpty else { return [] }
        return SignatureCatalog.all.filter { person in
            !suppressed(person, in: text) && nameAlreadyPresent(person, in: text)
        }
    }

    static func weaponSense(_ line: String) -> Bool {
        let text = normalized(line)
        return containsAny(["uzi", "lil uzi"], in: text)
            && containsAny(["clip", "spray", "extended", "drum", "tuck"], in: text)
    }

    static func promptFragment() -> String {
        let groups = SignatureCatalog.all.reduce(into: [SignatureGroup: [PersonSignature]]()) { partial, person in
            partial[person.group, default: []].append(person)
        }
        let order: [SignatureGroup] = [.artists, .hoopers, .athletes, .celebs]
        let body = order.compactMap { group -> String? in
            guard let people = groups[group], !people.isEmpty else { return nil }
            let lines = people.map { person in
                let pictures = person.aspects.map { aspect in
                    switch aspect.kind {
                    case .title: return "\(aspect.label) (song)"
                    case .album: return "\(aspect.label) (album)"
                    case .catchphrase: return "\(aspect.label) (catchphrase)"
                    case .tag: return "\(aspect.label) (tag)"
                    case .adlib: return "\(aspect.label) (adlib)"
                    case .crew: return "\(aspect.label) (crew)"
                    case .moment: return "\(aspect.label) (moment)"
                    case .outfit: return "\(aspect.label) (outfit)"
                    case .mannerism, .mark, .performance: return aspect.label
                    }
                }.joined(separator: ", ")
                return "- \(person.spoken): \(pictures)"
            }.joined(separator: "\n")
            return "\(group.title)\n\(lines)"
        }.joined(separator: "\n")
        return """
        One signature in the block. A picture can be a mannerism, a song, an album, a catchphrase, a producer tag, or an adlib. Use the picture as the sentence, then the short name. Say it and stop. If the name is already in the line, use the picture and do not add the name again. The listener already knows the link.
        \(body)
        """
    }

    /// Pictures the verse already earned. An empty scene gets no names.
    static func promptFragment(earnedBy text: String) -> String {
        let header = "One signature in the block. Use the picture as the sentence, then the short name. Say it and stop. Do not explain the link."
        var lines: [String] = []
        var seen = Set<String>()
        let source = text.split(separator: "\n").map(String.init)
        let rows = source.isEmpty ? [text] : source
        for row in rows where !row.trimmingCharacters(in: .whitespaces).isEmpty {
            let matched = hits(in: row)
            if matched.isEmpty {
                for picture in pictures(in: row) {
                    let key = picture.personId + "|" + picture.aspectId
                    if seen.insert(key).inserted {
                        lines.append("- \(picture.spoken): \(picture.aspectLabel)")
                    }
                }
            } else {
                for hit in matched {
                    let key = hit.person.id + "|" + hit.aspect.id
                    if seen.insert(key).inserted {
                        lines.append("- \(hit.person.spoken): \(hit.aspect.label)")
                    }
                }
            }
        }
        if lines.isEmpty {
            return header + "\nNo picture is in these lines. Do not add a name."
        }
        return header + "\n" + lines.joined(separator: "\n")
    }

    /// Drop a draft that explains the link, uses two pictures, or says a name with no picture.
    static func keepsDraft(_ text: String) -> Bool {
        let normalizedDraft = normalized(text)
        if normalizedDraft.contains("private") && text.contains("PRIVATE") { return false }
        let marks = [
            "referring to", "known for", "that's why", "that is why",
            "which means", "this means", "the reference", "this is about",
        ]
        if marks.contains(where: { normalizedDraft.contains($0) }) { return false }
        let rows = text.split(separator: "\n").map(String.init).filter {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }
        let pictureLines = rows.filter { !hits(in: $0).isEmpty }
        if pictureLines.count > 1 { return false }
        for row in rows where namedWithoutPicture(in: row) {
            return false
        }
        return true
    }

    /// Ordinary phrases. An empty lock list never matches. Any other list matches only when a lock is also in the line.
    private static let wideLocks: [String: [String]] = [
        "fancy": ["so fancy", "i'm so fancy", "im so fancy"],
        "motivation": ["your motivation"],
        "act up": ["said you gon"],
        "nameless": [],
        "i'm the one": ["yeah i'm the one", "yeah im the one"],
        "im the one": ["yeah i'm the one", "yeah im the one"],
        "freight train": [],
        "gunslinger": [],
        "the real deal": [],
        "another one": [],
        "who dat": [],
    ]

    /// A one-word picture matches only when it is pinned. Ordinary words stay off.
    private static let pinnedOneWord: Set<String> = [
        "shrug", "shrugged", "shrugs", "shrugging",
        "moonwalk", "moonwalked",
        "fadeaway", "shimmy", "shimmied", "scramble",
        "eyebrow", "eyebrows",
        "otf", "dipset", "burr", "slatt",
        "illmatic", "astroworld", "magnolia", "ds2", "wap", "faneto",
        "skeeyee", "okurr", "okurrr", "twinnem", "tebowing", "tebowed",
        "nunchucks", "nunchaku", "stickum", "snaggletooth",
        "hulkamania", "wooooo", "woooo", "coogi", "grillz", "skyhook",
        "ticallion", "ticalion", "vibez", "stepback",
    ]

    /// Phrase matches that die when a longer ordinary reading is in the line.
    private static let phraseExcludes: [String: [String]] = [
        "take care": ["take care of"],
    ]

    private static let completionStops: Set<String> = [
        "a", "an", "the", "of", "to", "in", "on", "my", "her", "his", "she", "he",
        "we", "they", "you", "your", "me", "it", "is", "was", "and", "for", "da",
        "tha", "i'm", "im", "i", "got", "get", "like", "this", "that",
    ]

    private static func bestAspect(_ person: PersonSignature, in text: String) -> (aspect: SignatureAspect, phrase: String)? {
        var best: (aspect: SignatureAspect, phrase: String)?
        for aspect in person.aspects {
            for phrase in aspect.phrases where phraseAllowed(phrase, in: text) {
                if let current = best {
                    if phrase.count > current.phrase.count { best = (aspect, phrase) }
                } else {
                    best = (aspect, phrase)
                }
            }
        }
        return best
    }

    private static func bestCompletion(
        _ person: PersonSignature,
        tokens lineTokens: [String],
        text: String
    ) -> (aspect: SignatureAspect, prefix: [String], rest: String)? {
        var best: (aspect: SignatureAspect, prefix: [String], rest: String, count: Int)?
        for aspect in person.aspects where canComplete(aspect.kind) {
            for phrase in aspect.phrases where completionAllowed(phrase, in: text) {
                guard let match = completing(phrase, lineTokens: lineTokens) else { continue }
                if let current = best, match.prefix.count <= current.count { continue }
                best = (aspect, match.prefix, match.rest, match.prefix.count)
            }
        }
        guard let best else { return nil }
        return (best.aspect, best.prefix, best.rest)
    }

    private static func canComplete(_ kind: SignatureKind) -> Bool {
        switch kind {
        case .title, .album, .catchphrase, .tag: return true
        case .mannerism, .mark, .performance, .adlib, .crew, .moment, .outfit: return false
        }
    }

    /// Longest real prefix of a 3+ word picture that the line already ends on.
    private static func completing(_ phrase: String, lineTokens: [String]) -> (prefix: [String], rest: String)? {
        let phraseTokens = tokens(in: normalized(phrase))
        guard phraseTokens.count >= 3 else { return nil }
        let maxPrefix = min(phraseTokens.count - 1, lineTokens.count)
        guard maxPrefix >= 2 else { return nil }
        for length in stride(from: maxPrefix, through: 2, by: -1) {
            let prefix = Array(phraseTokens.prefix(length))
            guard Array(lineTokens.suffix(length)) == prefix else { continue }
            let anchored = prefix.contains { word in
                word.count >= 3 && !completionStops.contains(word)
            }
            guard anchored else { continue }
            let rest = phraseTokens.dropFirst(length).joined(separator: " ")
            guard !rest.isEmpty else { continue }
            return (prefix, rest)
        }
        return nil
    }

    private static func phraseAllowed(_ phrase: String, in text: String) -> Bool {
        guard containsPhrase(phrase, in: text) else { return false }
        if let locks = wideLocks[phrase], !locks.contains(where: { containsPhrase($0, in: text) }) {
            return false
        }
        if let bans = phraseExcludes[phrase], containsAny(bans, in: text) {
            return false
        }
        if tokens(in: normalized(phrase)).count == 1,
           !pinnedOneWord.contains(normalized(phrase)),
           wideLocks[phrase] == nil {
            return false
        }
        return true
    }

    private static func namedWithoutPicture(in line: String) -> Bool {
        let text = normalized(line)
        let matched = hits(in: line)
        var field = text
        for hit in matched {
            field = removingFirstPhrase(hit.phrase, from: field)
        }
        for person in SignatureCatalog.all {
            if suppressed(person, in: text) { continue }
            if bestAspect(person, in: text) != nil { continue }
            if containsPhrase("like \(person.spoken)", in: field) { return true }
            let longAliases = person.aliases.filter { alias in
                tokens(in: alias).count > 1 || alias.count >= 4
            }
            if containsAny(longAliases, in: field) { return true }
        }
        return false
    }

    /// A wide picture does not get finished from a prefix unless its lock is already in the line.
    private static func completionAllowed(_ phrase: String, in text: String) -> Bool {
        if containsPhrase(phrase, in: text) { return false }
        if let locks = wideLocks[phrase], !locks.contains(where: { containsPhrase($0, in: text) }) {
            return false
        }
        if let bans = phraseExcludes[phrase], containsAny(bans, in: text) {
            return false
        }
        return true
    }

    private static func tail(for hit: SignatureHit, insert: String) -> SignatureTail {
        SignatureTail(
            insert: insert,
            spoken: hit.person.spoken,
            aspectId: hit.aspect.id,
            aspectLabel: hit.aspect.label,
            personId: hit.person.id
        )
    }

    private static func suppressed(_ person: PersonSignature, in text: String) -> Bool {
        switch person.id {
        case "noun-artist-uzi":
            return weaponSense(text)
        case "noun-celeb-michael-jordan":
            return containsAny(["bred", "cement", "aj1", "jordan 1", "jordans"], in: text)
                || (containsPhrase("jordan", in: text) && containsAny(["feet", "lace", "leather"], in: text))
        case "noun-celeb-steph":
            return containsPhrase("curry", in: text) && containsAny(["chicken", "goat", "stew", "plate"], in: text)
        case "noun-celeb-vick":
            return containsAny(["vick", "vicks"], in: text)
                && containsAny(["rub", "vapor", "vapour", "sick", "chest"], in: text)
        case "noun-celeb-the-rock":
            let object = containsPhrase("rock", in: text) && containsAny(["chain", "stone", "diamond", "ice"], in: text)
            let brow = containsAny(["eyebrow", "eyebrows"], in: text)
            return object && !brow
        case "noun-artist-juice-wrld":
            let food = containsAny(["orange", "cranberry", "apple", "bottle", "jug"], in: text)
            let mark = containsAny(["999", "triple nines", "999 club"], in: text)
            return food && !mark
        case "noun-celeb-magic-johnson":
            let city = containsAny(["magic city", "magic stick", "black magic"], in: text)
            let pass = containsAny(["no look pass", "no-look pass", "no look dish"], in: text)
            return city && !pass
        case "noun-celeb-tiger-woods":
            let proverb = containsPhrase("eye of the tiger", in: text)
            let pump = containsAny(["fist pump", "fist pumped", "sunday red"], in: text)
            return proverb && !pump
        case "noun-celeb-michael-jackson":
            let leanCollision = containsPhrase("lean", in: text) && containsAny(["cup", "pour", "sip", "oz", "foreign"], in: text)
            let stage = containsAny(["moonwalk", "moon walk", "one glove", "white glove", "single glove"], in: text)
            return leanCollision && !stage
        case "noun-artist-ice-spice":
            return containsPhrase("ice", in: text)
                && containsAny(["rock", "chain", "diamond", "wrist", "cuban"], in: text)
        default:
            return false
        }
    }

    private static func nameAlreadyPresent(
        _ person: PersonSignature,
        in text: String,
        asideFrom phrase: String? = nil
    ) -> Bool {
        if containsPhrase("like \(person.spoken)", in: text) { return true }
        let field = phrase.map { removingFirstPhrase($0, from: text) } ?? text
        return containsAny(person.aliases, in: field)
    }

    private static func containsAny(_ phrases: [String], in text: String) -> Bool {
        phrases.contains { containsPhrase($0, in: text) }
    }

    private static func containsPhrase(_ phrase: String, in text: String) -> Bool {
        let haystack = text
        let needle = normalized(phrase)
        guard !needle.isEmpty, haystack.count >= needle.count else { return false }
        var rest = haystack[...]
        while let range = rest.range(of: needle) {
            let beforeOK = range.lowerBound == haystack.startIndex
                || !haystack[haystack.index(before: range.lowerBound)].isLetter
            let afterOK = range.upperBound == haystack.endIndex
                || !haystack[range.upperBound].isLetter
            if beforeOK && afterOK { return true }
            rest = haystack[range.upperBound...]
        }
        return false
    }

    private static func removingFirstPhrase(_ phrase: String, from text: String) -> String {
        let needle = normalized(phrase)
        guard !needle.isEmpty else { return text }
        var rest = text[...]
        while let range = rest.range(of: needle) {
            let beforeOK = range.lowerBound == text.startIndex
                || !text[text.index(before: range.lowerBound)].isLetter
            let afterOK = range.upperBound == text.endIndex
                || !text[range.upperBound].isLetter
            if beforeOK && afterOK {
                var copy = text
                copy.removeSubrange(range)
                return copy
            }
            rest = text[range.upperBound...]
        }
        return text
    }

    private static func tokens(in text: String) -> [String] {
        text.split { character in
            !(character.isLetter || character.isNumber || character == "'")
        }.map(String.init)
    }

    private static func normalized(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "‘", with: "'")
    }
}
