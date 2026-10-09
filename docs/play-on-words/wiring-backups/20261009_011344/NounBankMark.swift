import SwiftUI

/// Flat one-color tile identity for a noun: initials + a brand/category hue + a silhouette.
/// Brand families share a mark (Henny / Hennessy both `HN` in cognac) so the 4-up grid
/// reads as one system, while each house still has its own color.
enum NounBankMark {
    struct Identity: Equatable, Sendable {
        let initials: String
        let hex: UInt
        let onHex: UInt
        let glyph: Glyph
        let family: String
    }

    enum Glyph: String, Equatable, Sendable {
        case cognacBottle
        case champagneBottle
        case tequilaBottle
        case vodkaBottle
        case wineGlass
        case doubleCup
        case pill
        case leaf
        case diamond
        case tag
        case shirt
        case firearm
        case bolt
        case heart
        case money
        case car
        case pin
        case waveform
        case person
        case paw
        case bug
        case plate
        case comb
        case nail
        case needle
        case controller
    }

    /// Other names for this exact chip (`Henny` / `Hennessy`).
    /// A longer product name does not inherit a family just because one word matches,
    /// and a common word (`switch`, `stick`, `ace`) is not added onto a more specific chip.
    static func familyAliases(for word: String) -> [String] {
        let key = normalize(word)
        guard let family = aliasIndex[key] else { return [] }
        return family.aliases.filter { alias in
            let folded = normalize(alias)
            if folded == key { return true }
            return !broadMentionWords.contains(folded)
        }
    }

    /// Single words that show up constantly for a different reason than the noun.
    private static let broadMentionWords: Set<String> = [
        "ace", "switch", "stick", "dot", "drill", "wayne", "demon", "block",
        "dang", "deuce", "bean", "whip", "coupe"
    ]

    static func identity(for word: String, category: NounBankCategory) -> Identity {
        let normalized = normalize(word)
        if let family = matchFamily(normalized, category: category) {
            return Identity(
                initials: family.initials,
                hex: family.hex,
                onHex: family.onHex ?? contrastingOnHex(family.hex),
                glyph: family.glyph,
                family: family.id
            )
        }
        let hex = fallbackHex(for: normalized, category: category)
        return Identity(
            initials: computedInitials(word),
            hex: hex,
            onHex: contrastingOnHex(hex),
            glyph: category.markGlyph,
            family: normalized
        )
    }

    static func initials(for word: String, category: NounBankCategory = .liquors) -> String {
        identity(for: word, category: category).initials
    }

    static func normalize(_ word: String) -> String {
        word.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "\u{2019}", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "/", with: " ")
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    // MARK: - Initials

    static func computedInitials(_ word: String) -> String {
        let folded = word.folding(options: .diacriticInsensitive, locale: .current)
        let cleaned = folded
            .replacingOccurrences(of: "\u{2019}", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: ".", with: "")
        let stops: Set<String> = ["of", "the", "a", "an", "and", "de", "des", "la", "le", "da"]
        let parts = cleaned.split { $0.isWhitespace || $0 == "-" || $0 == "/" }
            .map(String.init)
            .filter { !stops.contains($0.lowercased()) && !$0.isEmpty }

        if parts.count >= 2 {
            return String([firstAlnum(parts[0]), firstAlnum(parts[1])]).uppercased()
        }

        let one = parts.first ?? cleaned
        let alnum = one.filter { $0.isLetter || $0.isNumber }
        if alnum.isEmpty { return String(word.prefix(2)).uppercased() }
        if alnum.allSatisfy(\.isNumber) {
            return alnum.count >= 3 ? String(alnum.suffix(2)) : alnum
        }
        if alnum.count <= 3 { return alnum.uppercased() }
        return String(alnum.prefix(2)).uppercased()
    }

    private static func firstAlnum(_ s: String) -> Character {
        s.first { $0.isLetter || $0.isNumber } ?? "?"
    }

    // MARK: - Color

    static func contrastingOnHex(_ hex: UInt) -> UInt {
        let r = Double((hex >> 16) & 0xFF)
        let g = Double((hex >> 8) & 0xFF)
        let b = Double(hex & 0xFF)
        let lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
        return lum > 0.62 ? 0x1C1C1E : 0xF7F4EC
    }

    private static func fallbackHex(for normalized: String, category: NounBankCategory) -> UInt {
        let palette = palettes[category] ?? palettes[.brands]!
        let index = stableIndex(normalized, mod: palette.count)
        return palette[index]
    }

    private static func stableIndex(_ s: String, mod: Int) -> Int {
        var hash: UInt64 = 5381
        for byte in s.utf8 { hash = hash &* 33 &+ UInt64(byte) }
        return Int(hash % UInt64(max(mod, 1)))
    }

    private static let palettes: [NounBankCategory: [UInt]] = [
        .liquors: [0xC4A35A, 0x8B5A2B, 0xD4AF37, 0x6E1F2C, 0x1F3D2B, 0xA9C7D8, 0x1E4B8C, 0xC45C9A],
        .syrups: [0x6B3FA0, 0xC62828, 0x2E9B4A, 0xC6B03A, 0xD46A8A, 0xE0A825, 0x5C2E91, 0xD4451D],
        .drugs: [0x3D8B5A, 0xC45C2C, 0x7A9B6A, 0xD4AF37, 0x6B3FA0, 0x4A7BA7],
        .jewelry: [0xD4AF37, 0xC8E0F0, 0xB01E23, 0xC0C0C0, 0x004F3B, 0x1A1A2E],
        .jewelers: [0xD4AF37, 0xC8E0F0, 0x1A1A2E, 0xB01E23, 0xC0C0C0, 0x004F3B],
        .brands: [0xC4A35A, 0x1A1A1A, 0xB01E23, 0x4A7BA7, 0x6B3FA0, 0xD4AF37, 0x2C2C2C, 0x8B5A2B],
        .clothing: [0x3D4A3A, 0x6B4F3A, 0x1A1A1A, 0x8B2942, 0x4A5A6A, 0xC4A35A],
        .guns: [0x4A4F55, 0x2C2C2C, 0x6B3030, 0x5A5E63, 0x3A3A3A],
        .kill: [0x8B2942, 0x6B1D2A, 0x4A1F1F, 0xB01E23, 0x3A1515],
        .opps: [0x8B2942, 0x6B1D2A, 0x1A1A1A, 0xB01E23, 0x4A1F1F],
        .woman: [0xC45C9A, 0xD4A0A8, 0xB01E23, 0xE8A0B0, 0x8B4A6A],
        .money: [0x2F6B3A, 0xD4AF37, 0x1F4D2B, 0xC4A35A, 0x3D8B5A],
        .cars: [0xB22222, 0x1A1A1A, 0xC0C0C0, 0xC4A000, 0x2C2C2C, 0x3D5C4A, 0xFF8700],
        .motorcycles: [0x1A1A1A, 0xC4A000, 0xB22222, 0xFF8700, 0x2C2C2C, 0x4A4F55],
        .boats: [0x1E4B8C, 0xA9C7D8, 0x0B3A5B, 0xC4A35A, 0x2C2C2C],
        .aviation: [0x5B7C99, 0xC0C0C0, 0x1A1A1A, 0x4A7BA7, 0xD4AF37],
        .military: [0x3D4A3A, 0x4A4F55, 0x1A1A1A, 0x6B5A2B, 0x2F4F4F],
        .places: [0x3D6B8A, 0x2F4F4F, 0x6B3FA0, 0x1F3D2B, 0x8B5A2B, 0x4A7BA7],
        .producers: [0x1A1A1A, 0xD4AF37, 0x4A7BA7, 0xB01E23, 0x2C2C2C, 0xC4A35A],
        .artists: [0x1A1A1A, 0xB01E23, 0x4A7BA7, 0xD4AF37, 0x2F6B3A, 0x6B3FA0],
        .celebs: [0xD4AF37, 0x1A1A1A, 0x4A7BA7, 0xB01E23, 0xC4A35A, 0x6B3FA0],
        .characters: [0x6B3FA0, 0x1A1A1A, 0xD4AF37, 0xB01E23, 0x4A7BA7],
        .nba: [0xC45C2C, 0x1E4B8C, 0xD4AF37, 0x1A1A1A, 0xB01E23],
        .nfl: [0x4A3A2A, 0x1E4B8C, 0xB01E23, 0xC4A35A, 0x1A1A1A],
        .boxing: [0xB01E23, 0x1A1A1A, 0xD4AF37, 0x4A1F1F, 0xC0C0C0],
        .sports: [0xD4AF37, 0x2F6B3A, 0x1E4B8C, 0xB01E23, 0x1A1A1A],
        .animals: [0x3D6B3A, 0xC4A35A, 0x8B5A2B, 0x1F3D2B, 0x4A7BA7, 0x6B3FA0],
        .insects: [0xC6B03A, 0x2C2C2C, 0xC45C2C, 0x3D6B3A, 0x6B3FA0],
        .food: [0xC45C2C, 0xE0A825, 0x8B2942, 0x2F6B3A, 0xC4A35A, 0x6B3FA0, 0xD4451D],
        .grills: [0xD4AF37, 0xC0C0C0, 0xC8E0F0, 0x1A1A2E, 0xB01E23, 0x004F3B],
        .hair: [0x1A1A1A, 0x6B4F3A, 0xC4A35A, 0x8B2942, 0x3D4A3A, 0x4A5A6A],
        .nails: [0xE8C4C8, 0xC45C9A, 0xF7F4EC, 0x8B2942, 0xD4A0A8, 0x1A1A1A],
        .tattoos: [0x1A1A1A, 0x6B1D2A, 0x243044, 0xC4A35A, 0x4A2C3A, 0x8B2942],
        .friends: [0x1E4B8C, 0x2F6B3A, 0xC4A35A, 0x6B3FA0, 0xB01E23, 0x1A1A1A],
        .games: [0x2F6B3A, 0x1E4B8C, 0xB01E23, 0xC4A35A, 0x6B3FA0, 0x1A1A1A],
        .flowers: [0xC45C9A, 0xE23B4A, 0xF2C14E, 0xF7F4EC, 0x2F6B3A, 0x6B3FA0],
        .lingerie: [0x1A1A1A, 0xC45C9A, 0xF7F4EC, 0x8B2942, 0xD4A0A8, 0x4A2C3A],
        .toys: [0xC45C9A, 0x1A1A1A, 0x6B3FA0, 0xE8C4C8, 0x8B2942],
        .twerk: [0xC45C9A, 0x1A1A1A, 0xE23B4A, 0x6B3FA0, 0xF7F4EC],
        .streets: [0x8B2942, 0x1A1A1A, 0xC45C9A, 0x4A1F1F, 0x6B3FA0],
        .kingpin: [0x1A1A1A, 0xD4AF37, 0x6B1D2A, 0xC4A35A, 0x2C2C2C],
        .trapLife: [0x1F3D2B, 0x3D4A3A, 0x1A1A1A, 0x6B5A2B, 0x2F6B3A],
        .paranoia: [0x1A1A2E, 0x243044, 0x4A1F1F, 0x6B3FA0, 0x1A1A1A],
        .wrestlers: [0x1A1A1A, 0xB01E23, 0xC4A35A, 0x2C2C2C, 0x4A1F1F],
        .actors: [0x1A1A1A, 0xC4A35A, 0x1E4B8C, 0xF7F4EC, 0x6B3FA0],
        .streamers: [0x6B3FA0, 0x1A1A1A, 0xE23B4A, 0xF7F4EC, 0x1E4B8C],
        .substances: [0x3D8B5A, 0x6B3FA0, 0xC45C2C, 0x4A7BA7, 0x2C2C2C, 0xD4AF37],
        .religion: [0x1E4B8C, 0xF7F4EC, 0xC4A35A, 0x1A1A1A, 0x6B3FA0, 0x2F6B3A],
        .feelings: [0xC45C9A, 0x4A7BA7, 0xE0A825, 0x6B3FA0, 0x8B2942, 0x2F6B3A],
        .events: [0x1A1A1A, 0x1E4B8C, 0xC4A35A, 0x4A3A2A, 0x6B3FA0],
        .phrases: [0x1A1A1A, 0xD4AF37, 0xF7F4EC, 0xB01E23, 0x4A7BA7, 0x2C2C2C],
        .wordplay: [0x1A1A1A, 0xD4AF37, 0xF7F4EC, 0xB01E23, 0x4A7BA7, 0x2C2C2C],
        .apps: [0x1A1A1A, 0x1E4B8C, 0xF7F4EC, 0x4A7BA7, 0x2C2C2C, 0x6B3FA0],
        .looks: [0xC4A35A, 0x8B5A2B, 0xD4A574, 0x6B3A2A, 0xE8C4A8, 0x3D2A22, 0xF7F4EC]
    ]

    // MARK: - Families

    private struct Family {
        let id: String
        let aliases: [String]
        let initials: String
        let hex: UInt
        let onHex: UInt?
        let glyph: Glyph
    }

    /// People, creatures, and jewelers only wear a house mark when the whole chip
    /// is that alias. A single word inside the name must not steal it:
    /// "Jet Li" is the actor, not the private jet; "Jason of Beverly Hills" is the jeweler.
    private static let wholeNameCategories: Set<NounBankCategory> = [
        .family, .friends, .producers, .artists, .celebs, .events, .characters,
        .actors, .streamers, .nba, .nfl, .boxing, .sports, .wrestlers,
        .animals, .insects, .jewelers, .wordplay, .apps, .looks
    ]

    private static func matchFamily(_ normalized: String, category: NounBankCategory) -> Family? {
        if let hit = aliasIndex[normalized] {
            // Guns "Uzi" is the firearm. The artist family of the same word is Lil Uzi Vert.
            if category == .guns && hit.id == "uzi" {
                return nil
            }
            return hit
        }
        if wholeNameCategories.contains(category) { return nil }
        let tokens = normalized.split(separator: " ").map(String.init)
        if tokens.count >= 2 {
            for i in 0..<(tokens.count - 1) {
                if let hit = aliasIndex[tokens[i] + " " + tokens[i + 1]] { return hit }
            }
        }
        for token in tokens {
            if let hit = aliasIndex[token] { return hit }
        }
        return nil
    }

    private static let aliasIndex: [String: Family] = {
        var map: [String: Family] = [:]
        for family in families {
            map[family.id] = family
            for alias in family.aliases {
                map[alias] = family
            }
        }
        return map
    }()

    private static let families: [Family] = [
        // Liquors — one color per house, shared initials across nicknames.
        Family(id: "hennessy", aliases: ["henny", "hennessy"], initials: "HN", hex: 0x6B4423, onHex: 0xF7F4EC, glyph: .cognacBottle),
        Family(id: "remy", aliases: ["remy", "remy martin"], initials: "RM", hex: 0xD4AF37, onHex: 0x1C1C1E, glyph: .cognacBottle),
        Family(id: "ace", aliases: ["ace of spades", "ace"], initials: "AS", hex: 0x141414, onHex: 0xD4AF37, glyph: .champagneBottle),
        Family(id: "dom", aliases: ["dom p", "dom perignon"], initials: "DP", hex: 0x1F3D2B, onHex: nil, glyph: .champagneBottle),
        Family(id: "cristal", aliases: ["cristal"], initials: "CR", hex: 0xE6C35C, onHex: 0x1C1C1E, glyph: .champagneBottle),
        Family(id: "moet", aliases: ["moet"], initials: "MT", hex: 0xC4A36A, onHex: 0x1C1C1E, glyph: .champagneBottle),
        Family(id: "dusse", aliases: ["dusse"], initials: "DU", hex: 0x6E1F2C, onHex: nil, glyph: .cognacBottle),
        Family(id: "don julio", aliases: ["don julio"], initials: "DJ", hex: 0xB9A16A, onHex: 0x1C1C1E, glyph: .tequilaBottle),
        Family(id: "clase azul", aliases: ["clase azul"], initials: "CA", hex: 0x1E4B8C, onHex: nil, glyph: .tequilaBottle),
        Family(id: "1942", aliases: ["1942"], initials: "42", hex: 0xC9A84C, onHex: 0x1C1C1E, glyph: .tequilaBottle),
        Family(id: "casamigos", aliases: ["casamigos"], initials: "CG", hex: 0xD2C4A8, onHex: 0x1C1C1E, glyph: .tequilaBottle),
        Family(id: "ciroc", aliases: ["ciroc"], initials: "CI", hex: 0xC5CCD3, onHex: 0x1C1C1E, glyph: .vodkaBottle),
        Family(id: "peach ciroc", aliases: ["peach ciroc"], initials: "PC", hex: 0xE8B896, onHex: 0x1C1C1E, glyph: .vodkaBottle),
        Family(id: "grey goose", aliases: ["grey goose"], initials: "GG", hex: 0xA9C7D8, onHex: 0x1C1C1E, glyph: .vodkaBottle),
        Family(id: "belvedere", aliases: ["belvedere"], initials: "BV", hex: 0xB8BCC4, onHex: 0x1C1C1E, glyph: .vodkaBottle),
        Family(id: "louis xiii", aliases: ["louis xiii"], initials: "L13", hex: 0x7A1F2B, onHex: nil, glyph: .cognacBottle),
        Family(id: "nuvo", aliases: ["nuvo"], initials: "NV", hex: 0xC45C9A, onHex: nil, glyph: .wineGlass),
        Family(id: "belaire", aliases: ["belaire"], initials: "BL", hex: 0xD4A0B8, onHex: 0x1C1C1E, glyph: .champagneBottle),
        Family(id: "yak", aliases: ["yak", "yak attack"], initials: "YK", hex: 0xC47A2C, onHex: 0x1C1C1E, glyph: .cognacBottle),
        Family(id: "patron", aliases: ["patron"], initials: "PT", hex: 0x7A9B6A, onHex: 0x1C1C1E, glyph: .tequilaBottle),
        Family(id: "tequila", aliases: ["tequila"], initials: "TQ", hex: 0x9CAF88, onHex: 0x1C1C1E, glyph: .tequilaBottle),
        Family(id: "vodka", aliases: ["vodka"], initials: "VK", hex: 0xB0C4CE, onHex: 0x1C1C1E, glyph: .vodkaBottle),
        Family(id: "whiskey", aliases: ["whiskey"], initials: "WK", hex: 0xB8873A, onHex: 0x1C1C1E, glyph: .cognacBottle),
        Family(id: "cognac", aliases: ["cognac"], initials: "CN", hex: 0xA67C3D, onHex: 0x1C1C1E, glyph: .cognacBottle),
        Family(id: "bourbon", aliases: ["bourbon"], initials: "BB", hex: 0xB5651D, onHex: nil, glyph: .cognacBottle),
        Family(id: "champagne", aliases: ["champagne", "champagne rose", "pink champagne"], initials: "CH", hex: 0xD4C07A, onHex: 0x1C1C1E, glyph: .champagneBottle),
        Family(id: "actavis", aliases: ["actavis", "actavis double"], initials: "AV", hex: 0x6B3FA0, onHex: nil, glyph: .doubleCup),
        Family(id: "1800", aliases: ["1800"], initials: "18", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .tequilaBottle),
        Family(id: "absolut", aliases: ["absolut"], initials: "AB", hex: 0x4A7BA7, onHex: nil, glyph: .vodkaBottle),
        Family(id: "vsop", aliases: ["vsop"], initials: "VS", hex: 0xA67B3D, onHex: 0x1C1C1E, glyph: .cognacBottle),
        Family(id: "xo", aliases: ["xo"], initials: "XO", hex: 0x8B5A2B, onHex: nil, glyph: .cognacBottle),
        Family(id: "henny lean", aliases: ["henny lean"], initials: "HL", hex: 0x7B4B9A, onHex: nil, glyph: .doubleCup),

        // Syrups — color of the liquid, not a single purple wash.
        // Purple: Actavis / classic lean. Red: Hi-Tech / Robitussin.
        // Yellow: Wockhardt. Gold: Qualitest. Green: Sprite / green lean.
        Family(id: "lean", aliases: ["lean", "purple drank", "sizzurp", "pint of lean", "lean shawty", "lean cuisine"], initials: "LN", hex: 0x6B3FA0, onHex: nil, glyph: .doubleCup),
        Family(id: "wockhardt", aliases: ["wockhardt", "wock", "better wock"], initials: "WK", hex: 0xC6B03A, onHex: 0x1C1C1E, glyph: .doubleCup),
        Family(id: "hi tech", aliases: ["hi tech", "tech pints"], initials: "HT", hex: 0xC62828, onHex: nil, glyph: .doubleCup),
        Family(id: "robitussin", aliases: ["robitussin"], initials: "RO", hex: 0xD4451D, onHex: nil, glyph: .doubleCup),
        Family(id: "qualitest", aliases: ["qualitest"], initials: "QU", hex: 0xE0A825, onHex: 0x1C1C1E, glyph: .doubleCup),
        Family(id: "dirty sprite", aliases: ["dirty sprite"], initials: "DS", hex: 0x2E9B4A, onHex: nil, glyph: .doubleCup),
        Family(id: "lean green", aliases: ["lean green"], initials: "LG", hex: 0x3D8B3A, onHex: nil, glyph: .doubleCup),
        Family(id: "lean weed", aliases: ["lean weed"], initials: "LW", hex: 0x4A9A3A, onHex: nil, glyph: .doubleCup),
        Family(id: "codeine daiquiri", aliases: ["codeine daiquiri"], initials: "DQ", hex: 0xD46A8A, onHex: nil, glyph: .doubleCup),
        Family(id: "lean molly", aliases: ["lean molly", "codeine ecstasy"], initials: "LM", hex: 0xC44A8A, onHex: nil, glyph: .doubleCup),
        Family(id: "codeine", aliases: ["codeine", "codeine syrup", "codeine cups", "codeine cowboy", "codeine dreams", "codeine withdrawals", "codeine kills"], initials: "CD", hex: 0x5C2E91, onHex: nil, glyph: .doubleCup),
        Family(id: "promethazine", aliases: ["promethazine", "prometh"], initials: "PM", hex: 0x4A1F6E, onHex: nil, glyph: .doubleCup),
        Family(id: "styrofoam", aliases: ["styrofoam", "styrofoam cup", "styrofoam pluto"], initials: "SF", hex: 0xA88BC8, onHex: 0x1C1C1E, glyph: .doubleCup),
        Family(id: "double cup", aliases: ["double cup", "deuce", "deuce deuces", "deuce bigalow"], initials: "DC", hex: 0x7B4B9A, onHex: nil, glyph: .doubleCup),
        Family(id: "cup muddy", aliases: ["cup muddy"], initials: "CM", hex: 0x6B4A3A, onHex: nil, glyph: .doubleCup),
        Family(id: "cup stuffed", aliases: ["cup stuffed"], initials: "CS", hex: 0x6B3FA0, onHex: nil, glyph: .doubleCup),

        // Jewelry
        Family(id: "rolex", aliases: ["rolex", "rollie"], initials: "RX", hex: 0x004F3B, onHex: 0xD4AF37, glyph: .diamond),
        Family(id: "ap", aliases: ["ap", "audemars"], initials: "AP", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .diamond),
        Family(id: "patek", aliases: ["patek", "patek philippe", "patek phillippe", "patek phillipe"], initials: "PP", hex: 0x1A1A2E, onHex: 0xD4AF37, glyph: .diamond),
        Family(id: "cartier", aliases: ["cartier"], initials: "CT", hex: 0xB01E23, onHex: nil, glyph: .diamond),
        Family(id: "cuban", aliases: ["cuban", "cuban link"], initials: "CB", hex: 0xD4AF37, onHex: 0x1C1C1E, glyph: .diamond),
        Family(id: "vvs", aliases: ["vvs"], initials: "VVS", hex: 0xC8E0F0, onHex: 0x1C1C1E, glyph: .diamond),
        Family(id: "jacob", aliases: ["jacob"], initials: "JC", hex: 0xC0C0C0, onHex: 0x1C1C1E, glyph: .diamond),
        Family(id: "hublot", aliases: ["hublot"], initials: "HB", hex: 0x1A1A1A, onHex: 0xD4AF37, glyph: .diamond),

        // Fashion houses
        Family(id: "louis", aliases: ["louis", "louis v", "louis vuitton", "vuitton", "lv", "damier", "man bag"], initials: "LV", hex: 0x5C4033, onHex: 0xC4A35A, glyph: .tag),
        Family(id: "gucci", aliases: ["gucci"], initials: "GC", hex: 0x1F3D2B, onHex: 0xD4AF37, glyph: .tag),
        Family(id: "chanel", aliases: ["chanel"], initials: "CH", hex: 0x1A1A1A, onHex: nil, glyph: .tag),
        Family(id: "dior", aliases: ["dior"], initials: "DR", hex: 0x2C2C2C, onHex: nil, glyph: .tag),
        Family(id: "prada", aliases: ["prada"], initials: "PR", hex: 0x3A3A3A, onHex: nil, glyph: .tag),
        Family(id: "versace", aliases: ["versace"], initials: "VS", hex: 0xD4AF37, onHex: 0x1C1C1E, glyph: .tag),
        Family(id: "balenciaga", aliases: ["balenciaga"], initials: "BL", hex: 0x1A1A1A, onHex: nil, glyph: .tag),
        Family(id: "chrome hearts", aliases: ["chrome hearts", "chrome heart"], initials: "CH", hex: 0xC0C0C0, onHex: 0x1C1C1E, glyph: .tag),
        Family(id: "off white", aliases: ["off white"], initials: "OW", hex: 0xF2E6C9, onHex: 0x1C1C1E, glyph: .tag),
        Family(id: "yeezy", aliases: ["yeezy"], initials: "YZ", hex: 0x6B5A4A, onHex: nil, glyph: .tag),
        Family(id: "goyard", aliases: ["goyard"], initials: "GY", hex: 0x8B5A2B, onHex: nil, glyph: .tag),
        Family(id: "hermes", aliases: ["hermes", "birkin"], initials: "HM", hex: 0xE36B2C, onHex: 0x1C1C1E, glyph: .tag),
        Family(id: "ysl", aliases: ["ysl", "saint laurent", "yves saint", "yves saint laurent"], initials: "YSL", hex: 0x1A1A1A, onHex: nil, glyph: .tag),
        Family(id: "amiri", aliases: ["amiri"], initials: "AM", hex: 0x4A3A2A, onHex: nil, glyph: .tag),
        Family(id: "fendi", aliases: ["fendi"], initials: "FN", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .tag),
        Family(id: "bape", aliases: ["bape", "bathing ape", "bapesta"], initials: "BP", hex: 0x2F6B3A, onHex: nil, glyph: .tag),
        Family(id: "comme des garcons", aliases: ["comme des garcons", "cdg"], initials: "CDG", hex: 0xE10600, onHex: nil, glyph: .tag),
        Family(id: "nike", aliases: ["nike", "jumpman", "air force", "force 1"], initials: "NK", hex: 0x1A1A1A, onHex: nil, glyph: .tag),
        Family(id: "louboutin", aliases: ["red bottoms", "louboutin", "loubs", "christian louboutin"], initials: "RB", hex: 0xC41E3A, onHex: nil, glyph: .tag),

        // Cars
        Family(id: "ferrari", aliases: ["rari", "ferrari"], initials: "FR", hex: 0xC41E3A, onHex: nil, glyph: .car),
        Family(id: "bugatti", aliases: ["bugatti"], initials: "BG", hex: 0x0B1C48, onHex: 0x78B4E0, glyph: .car),
        Family(id: "lambo", aliases: ["lambo", "lamborghini"], initials: "LB", hex: 0xC4A000, onHex: 0x1C1C1E, glyph: .car),
        Family(id: "urus", aliases: ["urus", "lambo truck"], initials: "UR", hex: 0xC4A000, onHex: 0x1C1C1E, glyph: .car),
        Family(id: "benz", aliases: ["benz", "mercedes"], initials: "BZ", hex: 0xC0C0C0, onHex: 0x1C1C1E, glyph: .car),
        Family(id: "g-wagon", aliases: ["g wagon", "g wagen"], initials: "GW", hex: 0x2C2C2C, onHex: 0xC0C0C0, glyph: .car),
        Family(id: "range rover", aliases: ["range rover", "rover"], initials: "RR", hex: 0x3D5C4A, onHex: nil, glyph: .car),
        Family(id: "rolls", aliases: ["wraith", "cullinan", "phantom", "rolls", "ghost ride", "new rolls"], initials: "RR", hex: 0xF0EBE0, onHex: 0x1C1C1E, glyph: .car),
        Family(id: "hellcat", aliases: ["hellcat", "trackhawk", "charger", "scat pack", "demon"], initials: "HC", hex: 0xB22222, onHex: nil, glyph: .car),
        Family(id: "porsche", aliases: ["porsche"], initials: "PC", hex: 0x1A1A1A, onHex: 0xD4AF37, glyph: .car),
        Family(id: "audi", aliases: ["audi"], initials: "AU", hex: 0xBB0A30, onHex: nil, glyph: .car),
        Family(id: "corvette", aliases: ["corvette", "vette"], initials: "CV", hex: 0xC41E3A, onHex: nil, glyph: .car),
        Family(id: "maybach", aliases: ["maybach"], initials: "MB", hex: 0x1C1C1C, onHex: 0xD4AF37, glyph: .car),
        Family(id: "bentley", aliases: ["bentley", "bentayga"], initials: "BT", hex: 0x2F4F2F, onHex: nil, glyph: .car),
        Family(id: "mclaren", aliases: ["mclaren"], initials: "MC", hex: 0xFF8700, onHex: 0x1C1C1E, glyph: .car),
        Family(id: "tesla", aliases: ["tesla"], initials: "TS", hex: 0xCC0000, onHex: nil, glyph: .car),
        Family(id: "cadillac", aliases: ["cadillac", "caddy", "deville"], initials: "CD", hex: 0xA7A8AA, onHex: 0x1C1C1E, glyph: .car),
        Family(id: "chevy", aliases: ["chevy", "box chevy", "donk", "caprice", "cutlass", "impala", "old school"], initials: "CH", hex: 0x2C2C2C, onHex: 0xC0C0C0, glyph: .car),
        Family(id: "sprinter", aliases: ["sprinter"], initials: "SP", hex: 0x4A4F55, onHex: nil, glyph: .car),
        Family(id: "jet", aliases: ["jet", "the jet", "lear", "lear jet", "private jet"], initials: "JT", hex: 0x5B7C99, onHex: nil, glyph: .car),
        Family(id: "g5", aliases: ["g5"], initials: "G5", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .car),
        Family(id: "g6", aliases: ["g6"], initials: "G6", hex: 0x2C2C2C, onHex: 0xC0C0C0, glyph: .car),
        Family(id: "plane", aliases: ["private plane", "the plane"], initials: "PL", hex: 0x7A8B99, onHex: nil, glyph: .car),
        Family(id: "helicopter", aliases: ["helicopter", "the helicopter"], initials: "HE", hex: 0x3A3A3A, onHex: nil, glyph: .car),
        Family(id: "yacht", aliases: ["yacht", "the yacht"], initials: "YA", hex: 0x1C3A5A, onHex: nil, glyph: .car),
        Family(id: "boat", aliases: ["boat", "the boat"], initials: "BO", hex: 0x4A7BA7, onHex: nil, glyph: .car),
        Family(id: "jet ski", aliases: ["jet ski", "jetski"], initials: "JS", hex: 0x7CB342, onHex: 0x1C1C1E, glyph: .car),
        Family(id: "speedboat", aliases: ["speedboat"], initials: "SB", hex: 0x8B1E1E, onHex: nil, glyph: .car),
        Family(id: "cruise ship", aliases: ["cruise ship"], initials: "CS", hex: 0x5B7C99, onHex: nil, glyph: .car),
        Family(id: "whip", aliases: ["whip", "foreign whip", "coupe", "drop top"], initials: "WH", hex: 0x4A4F55, onHex: nil, glyph: .car),
        Family(id: "lambo doors", aliases: ["lambo doors"], initials: "LD", hex: 0xC4A000, onHex: 0x1C1C1E, glyph: .car),

        // Money
        Family(id: "racks", aliases: ["racks", "guap"], initials: "RA", hex: 0x2F6B3A, onHex: nil, glyph: .money),
        Family(id: "bands", aliases: ["bands"], initials: "BA", hex: 0x1F4D2B, onHex: nil, glyph: .money),
        Family(id: "rubber bands", aliases: ["rubber bands"], initials: "RU", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .money),
        Family(id: "hundreds", aliases: ["hunnids", "blue face", "big face"], initials: "HU", hex: 0x3D8B5A, onHex: nil, glyph: .money),
        Family(id: "money bag", aliases: ["money bag"], initials: "MB", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .money),
        Family(id: "millie", aliases: ["millie"], initials: "MI", hex: 0xD4AF37, onHex: 0x1C1C1E, glyph: .money),
        Family(id: "zelle", aliases: ["zelle"], initials: "ZE", hex: 0x6B3FA0, onHex: nil, glyph: .money),
        Family(id: "cashapp", aliases: ["cashapp"], initials: "CA", hex: 0x00D632, onHex: 0x1C1C1E, glyph: .money),
        Family(id: "paycheck", aliases: ["paycheck", "cash out"], initials: "PA", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .money),
        Family(id: "richard millie", aliases: ["richard millie", "face patek"], initials: "RM", hex: 0x1A1A2E, onHex: 0xD4AF37, glyph: .money),

        // Places
        Family(id: "trap", aliases: ["trap", "trap house", "trap spot"], initials: "TR", hex: 0x2F4F4F, onHex: nil, glyph: .pin),
        Family(id: "studio", aliases: ["stu", "booth"], initials: "ST", hex: 0x3D6B8A, onHex: nil, glyph: .pin),
        Family(id: "block", aliases: ["block", "o block"], initials: "BL", hex: 0x4A3A2A, onHex: nil, glyph: .pin),
        Family(id: "hood", aliases: ["hood", "southside", "northside", "eastside", "westside", "downtown"], initials: "HD", hex: 0x8B5A2B, onHex: nil, glyph: .pin),
        Family(id: "atlanta", aliases: ["atlanta", "zone 6", "decatur", "gwinnett", "east atlanta"], initials: "ATL", hex: 0xB01E23, onHex: nil, glyph: .pin),
        Family(id: "miami", aliases: ["miami"], initials: "MI", hex: 0x4A7BA7, onHex: nil, glyph: .pin),
        Family(id: "memphis", aliases: ["memphis", "south memphis"], initials: "ME", hex: 0x6B3FA0, onHex: nil, glyph: .pin),
        Family(id: "chicago", aliases: ["chicago", "chi town"], initials: "CHI", hex: 0x1E4B8C, onHex: nil, glyph: .pin),
        Family(id: "houston", aliases: ["houston"], initials: "HOU", hex: 0xC41E3A, onHex: nil, glyph: .pin),
        Family(id: "magic city", aliases: ["magic city"], initials: "MC", hex: 0x6B1D2A, onHex: nil, glyph: .pin),
        Family(id: "calabasas", aliases: ["calabasas"], initials: "CA", hex: 0x2F6B3A, onHex: nil, glyph: .pin),
        Family(id: "hollywood", aliases: ["hollywood", "hollywood hills", "beverly hills", "los angeles"], initials: "HL", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .pin),
        Family(id: "new orleans", aliases: ["new orleans"], initials: "NO", hex: 0x5A2E8A, onHex: nil, glyph: .pin),
        Family(id: "philly", aliases: ["philly", "philadelphia", "north philly"], initials: "PH", hex: 0x1F3D2B, onHex: nil, glyph: .pin),
        Family(id: "penthouse", aliases: ["penthouse"], initials: "PH", hex: 0xD4AF37, onHex: 0x1C1C1E, glyph: .pin),
        Family(id: "mansion", aliases: ["mansion"], initials: "MN", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .pin),
        Family(id: "paris", aliases: ["paris"], initials: "PA", hex: 0x1A1A2E, onHex: 0xD4AF37, glyph: .pin),
        Family(id: "london", aliases: ["london"], initials: "LD", hex: 0x4A4F55, onHex: nil, glyph: .pin),
        Family(id: "dubai", aliases: ["dubai"], initials: "DU", hex: 0xC4A000, onHex: 0x1C1C1E, glyph: .pin),
        Family(id: "tokyo", aliases: ["tokyo"], initials: "TK", hex: 0xB01E23, onHex: nil, glyph: .pin),
        Family(id: "jamaica", aliases: ["jamaica"], initials: "JA", hex: 0x2F6B3A, onHex: nil, glyph: .pin),
        Family(id: "overseas", aliases: ["overseas"], initials: "OS", hex: 0x3D6B8A, onHex: nil, glyph: .pin),

        // Guns — grey board, red wash only for named red pieces.
        Family(id: "glock", aliases: ["glock", "glock 40", "glock 20", "glock 23", "blicky", "blick", "thirty shot glock"], initials: "GL", hex: 0x4A4F55, onHex: nil, glyph: .firearm),
        Family(id: "draco", aliases: ["draco", "choppa", "chopper", "drac", "choppas", "choppa bullet", "choppa bust", "chopper rings", "chopper shot", "chopper bullets"], initials: "DR", hex: 0x6B3030, onHex: nil, glyph: .firearm),
        Family(id: "mac-11", aliases: ["mac 11"], initials: "M1", hex: 0x3A3A3A, onHex: nil, glyph: .firearm),
        Family(id: "p80", aliases: ["p80"], initials: "P80", hex: 0x2C2C2C, onHex: nil, glyph: .firearm),
        Family(id: "drum", aliases: ["hundred round drum", "100 round drum"], initials: "DR", hex: 0x5A5E63, onHex: nil, glyph: .firearm),
        Family(id: "extendo", aliases: ["extended clip", "extendo", "full clip"], initials: "EX", hex: 0x4A4F55, onHex: nil, glyph: .firearm),
        Family(id: "switch", aliases: ["switchy", "switch", "glock switches"], initials: "SW", hex: 0x3A3A3A, onHex: nil, glyph: .firearm),
        Family(id: "beam", aliases: ["red beam", "laser", "beam", "green beam", "beam team"], initials: "BE", hex: 0x6B3030, onHex: nil, glyph: .firearm),
        Family(id: "fn", aliases: ["fn", "fn loaded"], initials: "FN", hex: 0x4A4F55, onHex: nil, glyph: .firearm),
        Family(id: "rifle", aliases: ["rifle"], initials: "RI", hex: 0x3A3A3A, onHex: nil, glyph: .firearm),
        Family(id: "shotgun", aliases: ["shotty", "gauge", "12 gauge"], initials: "SG", hex: 0x5A5E63, onHex: nil, glyph: .firearm),
        Family(id: "dot", aliases: ["dot"], initials: "DOT", hex: 0x2C2C2C, onHex: nil, glyph: .firearm),
        Family(id: "pistol", aliases: ["stick", "toolie", "burner", "pistol"], initials: "PI", hex: 0x4A4F55, onHex: nil, glyph: .firearm),

        // Drugs
        Family(id: "perc", aliases: ["perc", "percocet", "perc 30", "perky", "percs", "percy"], initials: "PE", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .pill),
        Family(id: "xanax", aliases: ["xanax", "xanny", "xans", "xanny bar", "m box"], initials: "XA", hex: 0x7A9B6A, onHex: 0x1C1C1E, glyph: .pill),
        Family(id: "molly", aliases: ["molly", "ecstasy", "bean"], initials: "MO", hex: 0xC45C9A, onHex: nil, glyph: .pill),
        Family(id: "cocaine", aliases: ["white girl", "yayo", "fishscale"], initials: "CO", hex: 0xC8E0F0, onHex: 0x1C1C1E, glyph: .pill),
        Family(id: "weed", aliases: ["kush", "og kush", "zaza", "za", "runtz", "gelato", "cookies", "exotic", "gas pack", "loud pack"], initials: "WE", hex: 0x3D8B5A, onHex: nil, glyph: .leaf),
        Family(id: "backwood", aliases: ["backwood"], initials: "BW", hex: 0x6B4F3A, onHex: nil, glyph: .leaf),
        Family(id: "addy", aliases: ["addy", "adderall"], initials: "AD", hex: 0x4A7BA7, onHex: nil, glyph: .pill),
        Family(id: "shroom", aliases: ["shroom", "shrooms"], initials: "SH", hex: 0x9B59B6, onHex: nil, glyph: .leaf),
        Family(id: "fetty", aliases: ["fetty", "fentanyl"], initials: "FE", hex: 0x8B2942, onHex: nil, glyph: .pill),
        Family(id: "oxy", aliases: ["oxy", "roxy", "roxies"], initials: "OX", hex: 0xC45C2C, onHex: nil, glyph: .pill),
        Family(id: "acid", aliases: ["acid"], initials: "AC", hex: 0x7B4B9A, onHex: nil, glyph: .pill),

        // Kill — abstract, no gore.
        Family(id: "opp", aliases: ["opp", "opps", "opp pack", "opp dead", "opp died", "opp outside", "opp dropped", "opp face", "hitstick", "let it eat", "slide on", "rip skrrt", "drop him", "drill"], initials: "OP", hex: 0x8B2942, onHex: nil, glyph: .bolt),

        // Leftover houses
        Family(id: "givenchy", aliases: ["givenchy"], initials: "GV", hex: 0x1A1A1A, onHex: nil, glyph: .tag),
        Family(id: "supreme", aliases: ["supreme"], initials: "SU", hex: 0xB01E23, onHex: nil, glyph: .tag),
        Family(id: "celine", aliases: ["celine"], initials: "CE", hex: 0x2C2C2C, onHex: nil, glyph: .tag),
        Family(id: "vlone", aliases: ["vlone"], initials: "VL", hex: 0xB01E23, onHex: nil, glyph: .tag),
        Family(id: "moncler", aliases: ["moncler"], initials: "MO", hex: 0x1E4B8C, onHex: nil, glyph: .tag),
        Family(id: "bottega", aliases: ["bottega"], initials: "BV", hex: 0x2F6B3A, onHex: nil, glyph: .tag),
        Family(id: "adidas", aliases: ["adidas"], initials: "AD", hex: 0x1A1A1A, onHex: nil, glyph: .tag),
        Family(id: "fear of god", aliases: ["fear of god", "essentials"], initials: "FG", hex: 0x6B5A4A, onHex: nil, glyph: .tag),
        Family(id: "telfar", aliases: ["telfar"], initials: "TF", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .tag),
        Family(id: "sp5der", aliases: ["sp5der"], initials: "SP", hex: 0xC45C9A, onHex: nil, glyph: .tag),
        Family(id: "palm angels", aliases: ["palm angels"], initials: "PA", hex: 0x1A1A1A, onHex: nil, glyph: .tag),
        Family(id: "rick owens", aliases: ["rick owens"], initials: "RO", hex: 0x2C2C2C, onHex: nil, glyph: .tag),
        Family(id: "true religion", aliases: ["true religion", "truey", "trueys"], initials: "TR", hex: 0x4A7BA7, onHex: nil, glyph: .tag),
        Family(id: "north face", aliases: ["north face"], initials: "NF", hex: 0x1F3D2B, onHex: nil, glyph: .tag),
        Family(id: "canada goose", aliases: ["canada goose"], initials: "CG", hex: 0x1A1A1A, onHex: 0xD4AF37, glyph: .tag),

        Family(id: "johnny dang", aliases: ["johnny dang", "dang"], initials: "JD", hex: 0xD4AF37, onHex: 0x1C1C1E, glyph: .diamond),
        Family(id: "eliantte", aliases: ["eliantte"], initials: "EL", hex: 0xC8E0F0, onHex: 0x1C1C1E, glyph: .diamond),
        Family(id: "icebox", aliases: ["icebox"], initials: "IB", hex: 0x1A1A2E, onHex: 0xD4AF37, glyph: .diamond),
        Family(id: "avianne", aliases: ["avianne"], initials: "AV", hex: 0xB01E23, onHex: nil, glyph: .diamond),
        Family(id: "ben baller", aliases: ["ben baller"], initials: "BB", hex: 0x1A1A1A, onHex: 0xD4AF37, glyph: .diamond),
        Family(id: "jacob jeweler", aliases: ["jacob the jeweler"], initials: "JJ", hex: 0xD4AF37, onHex: 0x1C1C1E, glyph: .diamond),
        Family(id: "metro boomin", aliases: ["metro boomin", "metro"], initials: "MB", hex: 0x1A1A1A, onHex: 0xD4AF37, glyph: .waveform),
        Family(id: "wheezy", aliases: ["wheezy"], initials: "WZ", hex: 0x4A7BA7, onHex: nil, glyph: .waveform),
        Family(id: "tay keith", aliases: ["tay keith"], initials: "TK", hex: 0xB01E23, onHex: nil, glyph: .waveform),
        Family(id: "london on da track", aliases: ["london on da track", "london on the track"], initials: "LT", hex: 0xD4AF37, onHex: 0x1C1C1E, glyph: .waveform),
        Family(id: "mustard", aliases: ["mustard", "dj mustard"], initials: "MU", hex: 0xC4A000, onHex: 0x1C1C1E, glyph: .waveform),
        Family(id: "hit boy", aliases: ["hit boy", "hit-boy"], initials: "HB", hex: 0x1A1A1A, onHex: nil, glyph: .waveform),
        Family(id: "zaytoven", aliases: ["zaytoven"], initials: "ZT", hex: 0x6B3FA0, onHex: nil, glyph: .waveform),
        Family(id: "808 mafia", aliases: ["808 mafia"], initials: "8M", hex: 0xB01E23, onHex: nil, glyph: .waveform),
        Family(id: "wayne", aliases: ["wayne", "lil wayne"], initials: "LW", hex: 0x1A1A1A, onHex: nil, glyph: .person),
        Family(id: "thugger", aliases: ["thugger", "young thug"], initials: "YT", hex: 0x2F6B3A, onHex: nil, glyph: .person),
        Family(id: "carti", aliases: ["carti", "playboi carti"], initials: "PC", hex: 0xB01E23, onHex: nil, glyph: .person),
        Family(id: "uzi", aliases: ["uzi", "lil uzi vert"], initials: "UZ", hex: 0x6B3FA0, onHex: nil, glyph: .person),
        Family(id: "durk", aliases: ["durk", "lil durk"], initials: "LD", hex: 0x1E4B8C, onHex: nil, glyph: .person),
        Family(id: "kodak", aliases: ["kodak", "kodak black"], initials: "KB", hex: 0xC4A35A, onHex: 0x1C1C1E, glyph: .person),
        Family(id: "youngboy", aliases: ["youngboy", "nba youngboy"], initials: "YB", hex: 0x1A1A1A, onHex: 0xD4AF37, glyph: .person),
        Family(id: "tekashi", aliases: ["tekashi", "6ix9ine"], initials: "69", hex: 0xB01E23, onHex: nil, glyph: .bolt)
    ]
}

extension NounBankCategory {
    var markGlyph: NounBankMark.Glyph {
        switch self {
        case .liquors: return .cognacBottle
        case .syrups: return .doubleCup
        case .drugs: return .pill
        case .jewelry: return .diamond
        case .jewelers: return .diamond
        case .brands: return .tag
        case .clothing: return .shirt
        case .guns: return .firearm
        case .kill: return .bolt
        case .opps: return .bolt
        case .woman: return .heart
        case .family, .friends: return .person
        case .money: return .money
        case .cars, .motorcycles, .boats, .aviation, .military: return .car
        case .places: return .pin
        case .producers: return .waveform
        case .artists, .celebs, .characters, .events, .nba, .nfl, .boxing, .sports, .wrestlers, .actors, .streamers: return .person
        case .animals: return .paw
        case .insects: return .bug
        case .food: return .plate
        case .grills: return .diamond
        case .hair: return .comb
        case .nails: return .nail
        case .tattoos: return .needle
        case .games: return .controller
        case .flowers: return .leaf
        case .lingerie: return .shirt
        case .toys: return .heart
        case .twerk, .streets, .kingpin, .paranoia: return .person
        case .trapLife: return .pin
        case .substances: return .pill
        case .religion: return .person
        case .feelings: return .heart
        case .phrases, .wordplay, .apps: return .tag
        case .looks: return .person
        }
    }
}

// MARK: - Tile

struct NounBankMarkView: View {
    let word: String
    let category: NounBankCategory
    var iconName: String? = nil

    var body: some View {
        let mark = NounBankMark.identity(for: word, category: category)
        let ink = Color(hex: mark.hex)
        let icon = NounMarkImage.uiImage(named: iconName ?? NounBankCatalog.iconName(for: word, family: mark.family, category: category))

        let chip = RoundedRectangle(cornerRadius: 12, style: .continuous)
        let inner = RoundedRectangle(cornerRadius: 10, style: .continuous)
        let border: CGFloat = 2.5
        // Family color fills the chip; the photo is inset so that color is a thin border.
        chip
            .fill(ink)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                GeometryReader { geo in
                    let side = geo.size.width - border * 2
                    ZStack {
                        if let icon {
                            Image(uiImage: icon)
                                .resizable()
                                .scaledToFill()
                                .frame(width: side, height: side)
                                .clipped()
                                .clipShape(inner)
                        } else {
                            inner.fill(Color.white.opacity(0.92))
                            Image(systemName: NounBankSymbols.symbol(for: word, category: category))
                                .font(.system(size: max(18, side * 0.38), weight: .semibold))
                                .foregroundStyle(Self.symbolInk(mark.hex))
                                .frame(width: side, height: side)
                        }
                    }
                    .frame(width: side, height: side)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            .clipShape(chip)
            .accessibilityHidden(true)
    }

    /// Symbol sits on the white inset. A near-white house color would leave the tile empty.
    private static func symbolInk(_ hex: UInt) -> Color {
        let r = Double((hex >> 16) & 0xFF)
        let g = Double((hex >> 8) & 0xFF)
        let b = Double(hex & 0xFF)
        let lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
        return Color(hex: lum > 0.88 ? 0x1C1C1E : hex)
    }
}

// MARK: - Silhouettes

struct NounGlyphShape: Shape {
    var kind: NounBankMark.Glyph

    func path(in rect: CGRect) -> Path {
        switch kind {
        case .cognacBottle: return bottle(rect, neck: 22, collar: 28, shoulder: 44, body: 34)
        case .champagneBottle: return bottle(rect, neck: 10, collar: 38, shoulder: 52, body: 24)
        case .tequilaBottle: return bottle(rect, neck: 16, collar: 32, shoulder: 42, body: 32)
        case .vodkaBottle: return bottle(rect, neck: 14, collar: 22, shoulder: 30, body: 30)
        case .wineGlass: return wineGlass(rect)
        case .doubleCup: return doubleCup(rect)
        case .pill: return pill(rect)
        case .leaf: return leaf(rect)
        case .diamond: return diamond(rect)
        case .tag: return tag(rect)
        case .shirt: return shirt(rect)
        case .firearm: return firearm(rect)
        case .bolt: return bolt(rect)
        case .heart: return heart(rect)
        case .money: return money(rect)
        case .car: return car(rect)
        case .pin: return pin(rect)
        case .waveform: return waveform(rect)
        case .person: return person(rect)
        case .paw: return paw(rect)
        case .bug: return bug(rect)
        case .plate: return plate(rect)
        case .comb: return comb(rect)
        case .nail: return nail(rect)
        case .needle: return needle(rect)
        case .controller: return controller(rect)
        }
    }

    /// Points are in a 0…100 box, then mapped into `rect`.
    private func mapped(_ rect: CGRect, _ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: rect.minX + x / 100 * rect.width, y: rect.minY + y / 100 * rect.height)
    }

    private func bottle(_ rect: CGRect, neck: CGFloat, collar: CGFloat, shoulder: CGFloat, body: CGFloat) -> Path {
        let cx: CGFloat = 50
        let neckW = neck
        let bodyW = body
        var path = Path()
        path.move(to: mapped(rect, cx - neckW / 2, 6))
        path.addLine(to: mapped(rect, cx + neckW / 2, 6))
        path.addLine(to: mapped(rect, cx + neckW / 2, collar))
        path.addLine(to: mapped(rect, cx + bodyW / 2, shoulder))
        path.addLine(to: mapped(rect, cx + bodyW / 2, 94))
        path.addLine(to: mapped(rect, cx - bodyW / 2, 94))
        path.addLine(to: mapped(rect, cx - bodyW / 2, shoulder))
        path.addLine(to: mapped(rect, cx - neckW / 2, collar))
        path.closeSubpath()
        return path
    }

    private func wineGlass(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 28, 8))
        path.addLine(to: mapped(rect, 72, 8))
        path.addQuadCurve(to: mapped(rect, 54, 48), control: mapped(rect, 78, 36))
        path.addLine(to: mapped(rect, 54, 78))
        path.addLine(to: mapped(rect, 70, 92))
        path.addLine(to: mapped(rect, 30, 92))
        path.addLine(to: mapped(rect, 46, 78))
        path.addLine(to: mapped(rect, 46, 48))
        path.addQuadCurve(to: mapped(rect, 28, 8), control: mapped(rect, 22, 36))
        path.closeSubpath()
        return path
    }

    private func doubleCup(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 22, 28))
        path.addLine(to: mapped(rect, 78, 28))
        path.addLine(to: mapped(rect, 70, 92))
        path.addLine(to: mapped(rect, 30, 92))
        path.closeSubpath()
        path.move(to: mapped(rect, 28, 8))
        path.addLine(to: mapped(rect, 72, 8))
        path.addLine(to: mapped(rect, 68, 30))
        path.addLine(to: mapped(rect, 32, 30))
        path.closeSubpath()
        return path
    }

    private func pill(_ rect: CGRect) -> Path {
        let inset = rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.34)
        return Path(roundedRect: inset, cornerRadius: inset.height / 2)
    }

    private func leaf(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 50, 8))
        path.addQuadCurve(to: mapped(rect, 50, 92), control: mapped(rect, 92, 40))
        path.addQuadCurve(to: mapped(rect, 50, 8), control: mapped(rect, 8, 40))
        path.closeSubpath()
        return path
    }

    private func diamond(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 50, 8))
        path.addLine(to: mapped(rect, 88, 42))
        path.addLine(to: mapped(rect, 50, 94))
        path.addLine(to: mapped(rect, 12, 42))
        path.closeSubpath()
        path.move(to: mapped(rect, 22, 42))
        path.addLine(to: mapped(rect, 50, 8))
        path.addLine(to: mapped(rect, 78, 42))
        return path
    }

    private func tag(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 58, 10))
        path.addLine(to: mapped(rect, 88, 40))
        path.addLine(to: mapped(rect, 52, 90))
        path.addLine(to: mapped(rect, 12, 52))
        path.closeSubpath()
        let hole = CGRect(
            x: mapped(rect, 58, 22).x - rect.width * 0.05,
            y: mapped(rect, 58, 22).y - rect.height * 0.05,
            width: rect.width * 0.10,
            height: rect.height * 0.10
        )
        path.addEllipse(in: hole)
        return path
    }

    private func shirt(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 38, 14))
        path.addLine(to: mapped(rect, 50, 24))
        path.addLine(to: mapped(rect, 62, 14))
        path.addLine(to: mapped(rect, 88, 28))
        path.addLine(to: mapped(rect, 76, 40))
        path.addLine(to: mapped(rect, 76, 90))
        path.addLine(to: mapped(rect, 24, 90))
        path.addLine(to: mapped(rect, 24, 40))
        path.addLine(to: mapped(rect, 12, 28))
        path.closeSubpath()
        return path
    }

    private func firearm(_ rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(
            in: CGRect(
                x: mapped(rect, 12, 30).x,
                y: mapped(rect, 12, 30).y,
                width: rect.width * 0.72,
                height: rect.height * 0.18
            ),
            cornerSize: CGSize(width: 4, height: 4)
        )
        path.addRect(CGRect(
            x: mapped(rect, 28, 48).x,
            y: mapped(rect, 28, 48).y,
            width: rect.width * 0.16,
            height: rect.height * 0.36
        ))
        return path
    }

    private func bolt(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 58, 8))
        path.addLine(to: mapped(rect, 28, 50))
        path.addLine(to: mapped(rect, 48, 50))
        path.addLine(to: mapped(rect, 38, 92))
        path.addLine(to: mapped(rect, 74, 44))
        path.addLine(to: mapped(rect, 52, 44))
        path.closeSubpath()
        return path
    }

    private func heart(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 50, 88))
        path.addCurve(
            to: mapped(rect, 12, 36),
            control1: mapped(rect, 20, 70),
            control2: mapped(rect, 8, 52)
        )
        path.addCurve(
            to: mapped(rect, 50, 28),
            control1: mapped(rect, 16, 16),
            control2: mapped(rect, 40, 14)
        )
        path.addCurve(
            to: mapped(rect, 88, 36),
            control1: mapped(rect, 60, 14),
            control2: mapped(rect, 84, 16)
        )
        path.addCurve(
            to: mapped(rect, 50, 88),
            control1: mapped(rect, 92, 52),
            control2: mapped(rect, 80, 70)
        )
        path.closeSubpath()
        return path
    }

    private func money(_ rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(
            in: CGRect(
                x: mapped(rect, 14, 28).x,
                y: mapped(rect, 14, 28).y,
                width: rect.width * 0.72,
                height: rect.height * 0.46
            ),
            cornerSize: CGSize(width: 5, height: 5)
        )
        path.addRoundedRect(
            in: CGRect(
                x: mapped(rect, 20, 38).x,
                y: mapped(rect, 20, 38).y,
                width: rect.width * 0.72,
                height: rect.height * 0.46
            ),
            cornerSize: CGSize(width: 5, height: 5)
        )
        return path
    }

    private func car(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 10, 62))
        path.addLine(to: mapped(rect, 18, 62))
        path.addLine(to: mapped(rect, 28, 42))
        path.addLine(to: mapped(rect, 62, 42))
        path.addLine(to: mapped(rect, 78, 58))
        path.addLine(to: mapped(rect, 90, 58))
        path.addLine(to: mapped(rect, 90, 72))
        path.addLine(to: mapped(rect, 10, 72))
        path.closeSubpath()
        path.addEllipse(in: CGRect(
            x: mapped(rect, 24, 68).x - rect.width * 0.08,
            y: mapped(rect, 24, 68).y - rect.height * 0.08,
            width: rect.width * 0.16,
            height: rect.height * 0.16
        ))
        path.addEllipse(in: CGRect(
            x: mapped(rect, 70, 68).x - rect.width * 0.08,
            y: mapped(rect, 70, 68).y - rect.height * 0.08,
            width: rect.width * 0.16,
            height: rect.height * 0.16
        ))
        return path
    }

    private func pin(_ rect: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(rect, 50, 92))
        path.addQuadCurve(to: mapped(rect, 18, 38), control: mapped(rect, 18, 68))
        path.addQuadCurve(to: mapped(rect, 82, 38), control: mapped(rect, 50, 4))
        path.addQuadCurve(to: mapped(rect, 50, 92), control: mapped(rect, 82, 68))
        path.closeSubpath()
        path.addEllipse(in: CGRect(
            x: mapped(rect, 50, 38).x - rect.width * 0.12,
            y: mapped(rect, 50, 38).y - rect.height * 0.12,
            width: rect.width * 0.24,
            height: rect.height * 0.24
        ))
        return path
    }

    private func waveform(_ rect: CGRect) -> Path {
        var path = Path()
        let bars: [(x: CGFloat, top: CGFloat, h: CGFloat)] = [
            (16, 38, 24),
            (30, 22, 56),
            (44, 10, 80),
            (58, 26, 48),
            (72, 34, 32)
        ]
        for bar in bars {
            path.move(to: mapped(rect, bar.x, bar.top))
            path.addLine(to: mapped(rect, bar.x + 10, bar.top))
            path.addLine(to: mapped(rect, bar.x + 10, bar.top + bar.h))
            path.addLine(to: mapped(rect, bar.x, bar.top + bar.h))
            path.closeSubpath()
        }
        return path
    }

    private func person(_ rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(
            x: mapped(rect, 50, 20).x - rect.width * 0.16,
            y: mapped(rect, 50, 20).y - rect.height * 0.16,
            width: rect.width * 0.32,
            height: rect.height * 0.32
        ))
        path.move(to: mapped(rect, 22, 52))
        path.addQuadCurve(to: mapped(rect, 78, 52), control: mapped(rect, 50, 44))
        path.addLine(to: mapped(rect, 86, 92))
        path.addLine(to: mapped(rect, 14, 92))
        path.closeSubpath()
        return path
    }

    private func paw(_ rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(
            x: mapped(rect, 30, 50).x,
            y: mapped(rect, 30, 50).y,
            width: rect.width * 0.40,
            height: rect.height * 0.32
        ))
        for spot in [CGPoint(x: 16, y: 30), CGPoint(x: 32, y: 16), CGPoint(x: 52, y: 16), CGPoint(x: 68, y: 30)] {
            path.addEllipse(in: CGRect(
                x: mapped(rect, spot.x, spot.y).x,
                y: mapped(rect, spot.x, spot.y).y,
                width: rect.width * 0.14,
                height: rect.height * 0.14
            ))
        }
        return path
    }

    private func bug(_ rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(
            x: mapped(rect, 30, 42).x,
            y: mapped(rect, 30, 42).y,
            width: rect.width * 0.40,
            height: rect.height * 0.36
        ))
        path.addEllipse(in: CGRect(
            x: mapped(rect, 38, 24).x,
            y: mapped(rect, 38, 24).y,
            width: rect.width * 0.24,
            height: rect.height * 0.20
        ))
        return path
    }

    private func plate(_ rect: CGRect) -> Path {
        var path = Path()
        let center = mapped(rect, 50, 52)
        path.addEllipse(in: CGRect(
            x: center.x - rect.width * 0.42,
            y: center.y - rect.height * 0.28,
            width: rect.width * 0.84,
            height: rect.height * 0.56
        ))
        return path
    }

    private func comb(_ rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(
            x: mapped(rect, 18, 28).x,
            y: mapped(rect, 18, 28).y,
            width: rect.width * 0.64,
            height: rect.height * 0.14
        ))
        for tooth in stride(from: 22, through: 70, by: 12) {
            let x = CGFloat(tooth)
            path.addRect(CGRect(
                x: mapped(rect, x, 40).x,
                y: mapped(rect, x, 40).y,
                width: rect.width * 0.08,
                height: rect.height * 0.36
            ))
        }
        return path
    }

    private func nail(_ rect: CGRect) -> Path {
        var path = Path()
        let center = mapped(rect, 50, 46)
        path.addEllipse(in: CGRect(
            x: center.x - rect.width * 0.22,
            y: center.y - rect.height * 0.32,
            width: rect.width * 0.44,
            height: rect.height * 0.64
        ))
        return path
    }

    private func needle(_ rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(
            x: mapped(rect, 46, 8).x,
            y: mapped(rect, 46, 8).y,
            width: rect.width * 0.08,
            height: rect.height * 0.58
        ))
        let drop = mapped(rect, 50, 80)
        path.addEllipse(in: CGRect(
            x: drop.x - rect.width * 0.13,
            y: drop.y - rect.height * 0.12,
            width: rect.width * 0.26,
            height: rect.height * 0.24
        ))
        return path
    }

    private func controller(_ rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(
            in: CGRect(
                x: mapped(rect, 14, 34).x,
                y: mapped(rect, 14, 34).y,
                width: rect.width * 0.72,
                height: rect.height * 0.36
            ),
            cornerSize: CGSize(width: rect.width * 0.14, height: rect.height * 0.14)
        )
        for x in [36.0, 64.0] {
            let center = mapped(rect, x, 52)
            path.addEllipse(in: CGRect(
                x: center.x - rect.width * 0.06,
                y: center.y - rect.height * 0.06,
                width: rect.width * 0.12,
                height: rect.height * 0.12
            ))
        }
        return path
    }
}
