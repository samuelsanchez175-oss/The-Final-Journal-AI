import Foundation

/// The noun page shows one published definition.
/// Play on Words keeps the pun sentence. Every other chip uses the looked-up
/// page, or says when no published definition turned up.
/// Catalog lines stay off this sentence.
enum NounMentionBrief {
    static func passage(word: String, category: NounBankCategory, phrases: [String], lines: [String]) -> String {
        _ = phrases
        _ = lines
        return standing(word: word, category: category)
    }

    static func standing(word: String, category: NounBankCategory) -> String {
        if category == .wordplay {
            return wordplay[NounBankMark.normalize(word)]
                ?? "\(word) says one word and means the one beside it."
        }
        if let published = NounDefinitions.text(category: category, word: word) {
            return published
        }
        return "No published definition turned up for \(word)."
    }

    private static func lyricTake(word: String, category: NounBankCategory, phrases: [String], lines: [String]) -> String {
        var counts: [String: Int] = [:]
        var stone = 0
        var cold = 0
        var undress = 0
        var matched = 0
        for line in lines {
            guard let neighbors = neighbors(in: line, phrases: phrases) else { continue }
            matched += 1
            var seen = Set<String>()
            for token in neighbors {
                if token == "stone" { stone += 1 }
                if token == "cold" { cold += 1 }
                if undressWords.contains(token) { undress += 1 }
                guard let gloss = gloss(for: token, category: category), seen.insert(gloss).inserted else { continue }
                counts[gloss, default: 0] += 1
            }
        }
        guard matched > 0 else {
            return "No catalog lines are loaded for a closer read."
        }
        let bar = threshold(for: matched)
        if stone >= bar, cold >= bar {
            counts["being stone cold"] = min(stone, cold)
        }
        if (category == .lingerie || category == .toys), undress >= bar {
            counts["putting it on or taking it off"] = undress
        }
        let ranked = counts
            .filter { $0.value >= bar }
            .sorted { lhs, rhs in
                if lhs.value != rhs.value { return lhs.value > rhs.value }
                return lhs.key < rhs.key
            }
            .prefix(3)
            .map(\.key)
        if ranked.isEmpty {
            return fallback(category: category)
        }
        return "In these lines, \(word) shows up for \(join(Array(ranked)))."
    }

    private static func fallback(category: NounBankCategory) -> String {
        switch category {
        case .toys: return "In these lines it stays the toy in a sex bar."
        case .streets: return "In these lines it stays the passed-around sense."
        case .paranoia: return "In these lines it is the feeling itself."
        case .tattoos: return "In these lines it stays ink on skin."
        case .flowers: return "In these lines it stays the flower."
        case .wrestlers, .actors, .streamers, .celebs, .nba, .nfl, .boxing, .sports, .artists, .producers, .characters:
            return "No single detail repeats often enough to sum the person up."
        default:
            return "No single detail repeats often enough to sum it up."
        }
    }

    /// The play itself. The chip page shows this sentence and stops.
    private static let wordplay: [String: String] = [
        "gotta cancer": "Cancer is cancel. The bald head sets it up.",
        "never dye": "Dye is die. The bald head sets it up.",
        "sharin ten": "Sharin' ten is the Sheraton.",
        "jump the gates": "Jump the gates is the getaway, said beside Kevin Gates.",
        "kevin gates": "Kevin Gates is the Kevin in the line. Jump the gates is the getaway.",
        "marriott her": "Marriott her is marry her.",
        "marcus": "Marcus is Mariota. Marriott her is marry her.",
        "until my days end": "Days end is the Days Inn.",
        "dial soap": "Dial tone is Dial soap.",
        "quiktrip": "QuikTrip is the store and a quick trip.",
        "faith evans": "Faith in you is Faith Evans, Biggie's wife.",
        "own lane": "Own lane is Tory Lanez.",
        "tory": "Tory is Tory Lanez, said beside my own lane.",
        "sliders": "Sliders is the slide, said beside the burgers.",
        "box him": "Box him is the corner trap, said beside McGregor.",
        "must die": "Must die is musty, said beside the armpits.",
        "a sheet": "A sheet is what the junkies want, said beside the blankets.",
        "bring the real back": "Bring the real back is the spine and the realness, said beside scoliosis.",
        "relay": "Relay is run that shit back like a race.",
        "jake": "Jake is the Jake in the line. Relay is run that shit back.",
        "fox news": "Fox News is Jamie Foxx, and air puts him on the channel.",
        "jamie fox": "Jamie Fox is the Jamie in the line. Air puts him on Fox News.",
        "lohan": "Lohan is low on the designer lenses.",
        "call on": "Call on is who you reach, said beside Creed.",
        "creed": "Creed is who you would call, said beside call on.",
        "rock it": "Rock it is rocket, said beside scientific.",
        "heroine": "Heroine is the heroin in the percs.",
        "celean": "Celean is Celine and the lean. The bar says designer and promethazine.",
        "by the night": "By the night is Knight, said beside Suge.",
        "suge knight": "Suge Knight is the Suge in the line. By the night is Knight.",
        "smith and will": "Smith and Will is Will Smith, said beside the Smith & Wesson.",
        "i kneel": "I kneel is O'Neal. Shaquille.",
        "shaquille": "Shaquille is O'Neal. I kneel is the bow.",
        "reid me": "Reid me is read me. Eric Reid.",
        "eric reid": "Eric Reid is the Eric in the line. Reid me is read me.",
        "a bride": "A bride is the wedding and ringing the Glock.",
        "a knot": "A knot is the bump and the money.",
        "leavin a lot": "Leavin' a lot is the dealership lot.",
        "4 holes": "Four holes is the Audi rings.",
        "leave my heat": "Leave my heat is the gun and the Miami Heat.",
        "my sons": "My sons is my suns. They leave him with tans.",
        "pinky": "Pinky is the curved clip.",
        "nguyen": "Nguyen is when.",
        "mer curry": "Mer-Curry is mercury and Steph Curry.",
        "keyboard": "Keyboard is the type.",
        "pillow talk": "Pillow talk is the conversation, said beside the decorator.",
        "titans": "Titans is the team, said beside a fifty.",
        "smoked the restaurants": "Smoked is the shooting. The restaurants are the food.",
        "radric davis": "Radric Davis is Gucci Mane, said beside the Gucci.",
        "temp me": "Temp me is tempt me, said beside the barber.",
        "the drop": "The drop is the jump on somebody, and the line says it is not the car.",
        "mac lipstick": "MAC is the gun and the lipstick.",
        "texts": "Texts is the messages, said beside the tecs.",
        "tecs": "Tecs is the guns, said beside the texts.",
        "tom brady": "Tom Brady is the flat ball. Air puts it out.",
        "moving swift": "Moving swift is Taylor Swift.",
        "taylor": "Taylor is Taylor Swift, said beside moving swift.",
        "geeked": "Geeked is high, said beside Urkel.",
        "steve urkel": "Steve Urkel is the geek, said beside geeked.",
        "hangin with glue": "Hangin' with glue is the sticks that stick.",
        "over yao": "Over Yao is Yao Ming, the tall shot. Dodge the block is the street and the defense.",
        "dodge the block": "Dodge the block is the street and the defense, said beside Yao Ming.",
        "patrick beverly": "Patrick Beverly is the Houston Rockets.",
        "houston rockets": "Houston rockets is the team, said beside Patrick Beverly.",
        "no type": "No type is the Rae Sremmurd song, said beside Swae Lee.",
        "swae lee": "Swae Lee is the No Type song.",
        "to the vet": "To the vet is the Hellcat sounding like an animal.",
        "t hill": "T. Hill is Tyreek. Chief it is the smoke and the Chiefs.",
        "chief it": "Chief it is the smoke and the Chiefs, said beside T. Hill.",
        "jrue holiday": "Jrue Holiday is the holidays, said beside the bucks.",
        "greek": "Greek is the Greek Freak, said beside the Bucks.",
        "bet to the bucks": "Bet to the bucks is the team, said beside Greek.",
        "pluto": "Pluto is the planet that got separated.",
        "playing trouble": "Playing Trouble is the dice game and the trouble.",
        "aaron donald": "Aaron Donald is the sack on the line.",
        "serge ibaka": "Serge Ibaka is the block, said beside block her.",
        "block her": "Block her is the phone and the defense, said beside Serge Ibaka.",
        "od": "OD is the overdose, said beside Odell.",
        "major payne": "Major Payne is the Damon Wayans movie and major pain.",
        "gilbert arenas": "Gilbert Arenas is the gun in the locker.",
        "tony hawk": "Tony Hawk is the skate and the grind.",
        "training day": "Training Day is the Denzel movie used as the move.",
        "kill bill": "Kill Bill is the movie used as the sword and the kill."
    ]

    private static func threshold(for matched: Int) -> Int {
        if matched < 24 { return 2 }
        return max(4, matched / 10)
    }

    private static func gloss(for token: String, category: NounBankCategory) -> String? {
        switch token {
        case "tall", "taller", "tallest", "height", "giant": return "height"
        case "money", "racks", "rack", "bands", "million", "millions", "dough", "bread": return "money"
        case "ice", "icy", "diamond", "diamonds", "chain", "chains", "wrist", "cuban": return "jewelry"
        case "guns", "gun", "glock", "chopper", "rifle", "chrome": return "guns"
        case "face", "neck", "chest", "tears", "teardrop", "sleeve": return "the body"
        case "name": return "a name"
        case "pour", "sip", "sipping", "sippin", "drinkin", "drinking", "drunk", "bottle", "glass": return "pouring and sipping"
        case "lock": return "a lock"
        case "stunner": return "the Stunner"
        case "medal", "medallion": return "a medal"
        case "rockets", "rocket", "houston": return "the Rockets"
        case "dead", "funeral", "grave": return "the dead"
        case "smell": return "the smell"
        case "red": return category == .flowers ? "red" : nil
        case "feds", "trust", "watching", "watchin", "voices": return "being watched"
        case "plug", "connect": return "the plug"
        case "mansion": return "a mansion"
        case "clap", "bounce": return category == .twerk ? "the dance" : nil
        case "give", "send", "sending": return category == .flowers ? "giving them" : nil
        default: return nil
        }
    }

    private static let undressWords: Set<String> = ["take", "pull", "drop", "wear", "off"]

    private static let stops: Set<String> = [
        "a", "an", "the", "i", "im", "my", "me", "you", "your", "we", "they", "he", "she", "it",
        "to", "of", "and", "or", "in", "on", "for", "with", "that", "this", "just", "like", "feel",
        "feels", "feeling", "got", "get", "aint", "from", "when", "what", "all", "out", "up", "down",
        "so", "as", "be", "is", "are", "was", "am", "but", "if", "at", "by", "do", "did", "than",
        "then", "not", "no", "ya", "its", "cause", "cos", "dont", "cant", "was", "were", "been",
        "have", "has", "had", "their", "them", "our", "his", "her", "too", "very", "really", "still",
        "back", "off", "into", "over", "about", "gonna", "wit", "tha", "da", "dey", "dem", "yeah",
        "uh", "yo", "nigga", "niggas", "bitch", "bitches", "hoe", "hoes", "fuck", "fucking", "shit"
    ]

    private static func neighbors(in line: String, phrases: [String]) -> [String]? {
        let tokens = tokenize(line)
        let phraseTokenLists = phrases
            .map { tokenize($0) }
            .filter { !$0.isEmpty }
            .sorted { $0.count > $1.count }
        guard !tokens.isEmpty, !phraseTokenLists.isEmpty else { return nil }
        for phraseTokens in phraseTokenLists {
            guard let index = firstIndex(of: phraseTokens, in: tokens) else { continue }
            let phraseSet = Set(phraseTokens)
            let left = tokens[max(0, index - 6)..<index]
            let right = tokens[(index + phraseTokens.count)..<min(tokens.count, index + phraseTokens.count + 4)]
            return (Array(left) + Array(right)).filter { token in
                token.count > 2 && !stops.contains(token) && !phraseSet.contains(token)
            }
        }
        return nil
    }

    private static func firstIndex(of phrase: [String], in tokens: [String]) -> Int? {
        guard phrase.count <= tokens.count else { return nil }
        let last = tokens.count - phrase.count
        for index in 0...last where Array(tokens[index..<(index + phrase.count)]) == phrase {
            return index
        }
        return nil
    }

    private static func tokenize(_ text: String) -> [String] {
        let folded = text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: "'", with: "")
        var words: [String] = []
        var current = ""
        for scalar in folded.unicodeScalars {
            if CharacterSet.alphanumerics.contains(scalar) {
                current.unicodeScalars.append(scalar)
            } else if !current.isEmpty {
                words.append(current)
                current = ""
            }
        }
        if !current.isEmpty { words.append(current) }
        return words
    }

    private static func join(_ items: [String]) -> String {
        switch items.count {
        case 0: return ""
        case 1: return items[0]
        case 2: return "\(items[0]) and \(items[1])"
        default:
            return items.dropLast().joined(separator: ", ") + ", and " + items[items.count - 1]
        }
    }
}
