import Foundation

// MARK: - Curated Theme Catalog
// Consolidates overlapping CSV rows into user-facing themes with clear selection hints,
// meaningful tags, and keyword triggers for auto-selection from lyrics.

extension Theme {
    /// Short line explaining what selecting this theme will steer expansion toward.
    var selectionHint: String {
        ThemeCatalog.hint(for: id) ?? contextDescription
    }

    /// User-facing tags (not generic status/survival placeholders).
    var categoryTags: [String] {
        ThemeCatalog.tags(for: id)
    }

    /// Keywords and jargon used to auto-detect this theme in lyrics.
    var matchKeywords: [String] {
        ThemeCatalog.keywords(for: id)
    }

    /// Simplified tone bucket for filter pills.
    var toneCategory: String {
        ThemeCatalog.toneCategory(for: emotionalTone)
    }
}

enum ThemeCatalog {
    static let all: [Theme] = entries

    static func theme(id: String) -> Theme? {
        all.first { $0.id == id }
    }

    static func hint(for id: String) -> String? {
        meta[id]?.hint
    }

    static func tags(for id: String) -> [String] {
        meta[id]?.tags ?? []
    }

    static func keywords(for id: String) -> [String] {
        meta[id]?.keywords ?? []
    }

    static func toneCategory(for emotionalTone: String) -> String {
        let lower = emotionalTone.lowercased()
        if lower.contains("luxur") || lower.contains("aspir") { return "Luxury" }
        if lower.contains("gritty") || lower.contains("defiant") { return "Street" }
        if lower.contains("calculat") || lower.contains("opportun") { return "Calculated" }
        if lower.contains("paranoid") { return "Paranoid" }
        if lower.contains("celebrat") { return "Celebratory" }
        return "Confident"
    }

    static var toneCategories: [String] {
        ["All", "Luxury", "Street", "Confident", "Calculated", "Celebratory", "Paranoid"]
    }

    // MARK: - Keyword matching

    struct MatchResult: Identifiable {
        let id: String
        let theme: Theme
        let score: Int
        let matchedTerms: [String]
    }

    /// Score themes against lyric text using keywords, jargon, name, and context.
    static func matchThemes(in text: String, minimumScore: Int = 2) -> [MatchResult] {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

        let normalized = normalize(text)
        let tokens = tokenize(normalized)

        var results: [MatchResult] = []

        for theme in all {
            var score = 0
            var matched: [String] = []

            let candidates = Set(
                [theme.name.lowercased()] +
                theme.matchKeywords.map { $0.lowercased() } +
                theme.jargonTerms.map { $0.lowercased() }
            )

            for term in candidates where term.count >= 3 {
                if termContains(normalized, tokens: tokens, term: term) {
                    let weight = term.count >= 8 ? 3 : (term.count >= 5 ? 2 : 1)
                    score += weight
                    matched.append(term)
                }
            }

            if score >= minimumScore {
                results.append(MatchResult(id: theme.id, theme: theme, score: score, matchedTerms: matched))
            }
        }

        return results.sorted { $0.score > $1.score }
    }

    static func matchedThemeIDs(in text: String, minimumScore: Int = 2, maxCount: Int = 12) -> Set<String> {
        Set(matchThemes(in: text, minimumScore: minimumScore).prefix(maxCount).map(\.id))
    }

    static func detectedThemeNames(in text: String) -> [String] {
        matchThemes(in: text).map(\.theme.name)
    }

    private static func normalize(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: "\u{201C}", with: "\"")
            .replacingOccurrences(of: "\u{201D}", with: "\"")
    }

    private static func tokenize(_ text: String) -> Set<String> {
        Set(
            text.components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { $0.count >= 3 }
        )
    }

    private static func termContains(_ normalized: String, tokens: Set<String>, term: String) -> Bool {
        if normalized.contains(term) { return true }
        let termTokens = term.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { $0.count >= 3 }
        guard !termTokens.isEmpty else { return false }
        return termTokens.allSatisfy { tokens.contains($0) }
    }

    // MARK: - Metadata

    private struct Meta {
        let hint: String
        let tags: [String]
        let keywords: [String]
        let related: [String]
    }

    private static let meta: [String: Meta] = [
        "THEME_LUXURY_HOROLOGY_001": Meta(
            hint: "Adds watch & jewelry flex — Rolex, AP, bust-down vs plain Jane.",
            tags: ["flex", "wealth", "jewelry"],
            keywords: ["rolex", "ap", "audemars", "patek", "richard mille", "cartier", "cartis", "bust down", "plain jane", "watch", "timepiece"],
            related: ["High Fashion", "Luxury Accessories", "Real Estate"]
        ),
        "THEME_THE_HUSTLE_002": Meta(
            hint: "Pulls trap/kitchen origin story — weight, water, survival money.",
            tags: ["origin", "trap", "grind"],
            keywords: ["trap", "kitchen", "water", "weight", "hustle", "grind", "block", "trenches", "pack", "trapping"],
            related: ["Digital Finance", "Real Estate", "The Glow Up"]
        ),
        "THEME_DIGITAL_FINANCE_003": Meta(
            hint: "Adds scam-rap & digital hustle — swipe, bins, crypto, dark web.",
            tags: ["scam", "crypto", "finesse"],
            keywords: ["swipe", "method", "bin", "cashapp", "bitcoin", "dark web", "vpn", "fullz", "clone card", "telegram", "finesse", "scam"],
            related: ["The Hustle", "Tricking & Providing", "Paranoia & Surveillance"]
        ),
        "THEME_HIGH_FASHION_004": Meta(
            hint: "Elevates designer drip — Rick Owens, Margiela, couture flex.",
            tags: ["fashion", "designer", "drip"],
            keywords: ["rick owens", "margiela", "maison", "chrome hearts", "celine", "saint laurent", "designer", "drip", "couture"],
            related: ["Luxury Horology", "Footwear", "High-End Retail"]
        ),
        "THEME_FOOTWEAR_005": Meta(
            hint: "Adds sneaker & footwear culture — Js, Yeezys, red bottoms.",
            tags: ["sneakers", "fashion", "flex"],
            keywords: ["jordan", "yeezy", "red bottom", "louboutin", "bape", "sneaker", "kicks", "js"],
            related: ["High Fashion", "Luxury Horology"]
        ),
        "THEME_THE_OPS_CONFLICT_006": Meta(
            hint: "Intensifies opp/conflict energy — drilling, spinning, smoke.",
            tags: ["conflict", "drill", "opps"],
            keywords: ["opp", "opps", "drill", "drilling", "spinning", "smoke", "spin the block", "war", "beef"],
            related: ["Weaponry", "Legal & Prison", "Geography"]
        ),
        "THEME_LEGAL_PRISON_007": Meta(
            hint: "Raises legal stakes — RICO, feds, indictment, lawyer fees.",
            tags: ["legal", "rico", "stakes"],
            keywords: ["indictment", "rico", "feds", "fed", "lawyer", "prison", "jail", "going up top", "paperwork", "snitch", "informant"],
            related: ["Paranoia & Surveillance", "The Ops & Conflict", "Loyalty & Betrayal"]
        ),
        "THEME_GEOGRAPHY_008": Meta(
            hint: "Anchors hometown pride — area codes, the town, territory.",
            tags: ["city", "pride", "territory"],
            keywords: ["area code", "313", "212", "404", "the 6", "toronto", "the town", "the a", "hub", "block", "hood"],
            related: ["The Ops & Conflict", "Real Estate"]
        ),
        "THEME_VICE_SUBSTANCES_009": Meta(
            hint: "Adds party/vice imagery — lean, perc, zaza, escapism.",
            tags: ["vice", "party", "escapism"],
            keywords: ["wock", "lean", "purple", "perc", "percocet", "addy", "zaza", "gas", "xan", "xanny", "drank"],
            related: ["Clubs & Nightlife", "Escapism"]
        ),
        "THEME_LOYALTY_BETRAYAL_010": Meta(
            hint: "Explores trust & betrayal — day ones, snitching, small circle.",
            tags: ["loyalty", "trust", "betrayal"],
            keywords: ["snitch", "rat", "ratting", "day one", "day ones", "circle small", "loyalty", "betrayal", "snake", "judas"],
            related: ["Legal & Prison", "Paranoia & Surveillance", "Street Code"]
        ),
        "THEME_SPORTS_REFERENCES_011": Meta(
            hint: "Uses athlete metaphors — Curry, Kobe, GM moves, draft day.",
            tags: ["sports", "metaphor", "winning"],
            keywords: ["curry", "kobe", "ballin", "draft", "gm", "touchdown", "shooter", "mvp"],
            related: ["The Glow Up", "Wealth & Legacy"]
        ),
        "THEME_DINING_LIFESTYLE_012": Meta(
            hint: "Adds fine-dining & PJ lifestyle — Nobu, private chefs, first class.",
            tags: ["lifestyle", "dining", "travel"],
            keywords: ["nobu", "carbone", "catch", "private chef", "pj", "private jet", "g5", "first class", "flying private"],
            related: ["Travel & Flex", "Clubs & Nightlife", "Real Estate"]
        ),
        "THEME_WEAPONRY_013": Meta(
            hint: "Adds protection/aggression imagery — Glock, Draco, stick, pole.",
            tags: ["drill", "protection", "street"],
            keywords: ["glock", "draco", "stick", "pole", "clip", "choppa", "blick", "strap", "firearm"],
            related: ["The Ops & Conflict", "Paranoia & Surveillance"]
        ),
        "THEME_REAL_ESTATE_014": Meta(
            hint: "Levels up to property & penthouse — hills, gated, buying the block.",
            tags: ["property", "success", "escape"],
            keywords: ["penthouse", "gated", "the hills", "buying the block", "real estate", "mansion", "crib", "estate"],
            related: ["Wealth & Legacy", "The Glow Up", "Luxury Horology"]
        ),
        "THEME_TRICKING_PROVIDING_015": Meta(
            hint: "Adds sponsor/trickin' angle — allowances, rent, Birkin gifts.",
            tags: ["relationships", "spending", "sponsor"],
            keywords: ["trickin", "tricking", "sponsor", "allowance", "birkin", "pay the rent", "bagging", "spoil", "spoiling", "finesse"],
            related: ["Relationships & Rotation", "Luxury Accessories", "Cosmetic Surgery"]
        ),
        "THEME_COSMETIC_SURGERY_016": Meta(
            hint: "References BBL/body upgrades — Turks, new body, doctor shopping.",
            tags: ["beauty", "upgrade", "status"],
            keywords: ["bbl", "turks", "caicos", "new body", "doctor", "surgery", "veneers", "body"],
            related: ["Tricking & Providing", "Social Media & Clout"]
        ),
        "THEME_LUXURY_ACCESSORIES_017": Meta(
            hint: "Adds bag & accessory currency — Birkin, Kelly, Chanel, chinchilla.",
            tags: ["bags", "gifts", "luxury"],
            keywords: ["birkin", "hermes", "kelly", "chanel", "chinchilla", "louboutin", "accessories"],
            related: ["Luxury Horology", "High Fashion", "Tricking & Providing"]
        ),
        "THEME_TRAVEL_FLEX_019": Meta(
            hint: "Adds jet-set motion — passport stamps, villas, exotic locations.",
            tags: ["travel", "jet", "motion"],
            keywords: ["g5", "gulfstream", "passport", "villa", "exotic", "dubai", "cabo", "stamps", "jet setter"],
            related: ["Dining & Lifestyle", "Social Media & Clout", "Clubs & Nightlife"]
        ),
        "THEME_CLUBS_NIGHTLIFE_021": Meta(
            hint: "Adds bottle-service & club dominance — section, rain, tab flex.",
            tags: ["nightlife", "clubs", "flex"],
            keywords: ["bottle service", "section", "rain", "making it rain", "club", "starlets", "tab", "vip", "ace of spades", "don julio"],
            related: ["Tricking & Providing", "Vice & Substances", "Social Media & Clout"]
        ),
        "THEME_THE_GLOW_UP_022": Meta(
            hint: "Pushes rags-to-riches arc — used to have nothing, now we on.",
            tags: ["growth", "transformation", "come-up"],
            keywords: ["glow up", "upgrade", "used to have nothing", "now we on", "transformation", "before the fame", "come up"],
            related: ["Real Estate", "Wealth & Legacy", "The Hustle"]
        ),
        "THEME_DISCRETION_023": Meta(
            hint: "Adds privacy/low-profile moves — NDA, no cameras, deleted footage.",
            tags: ["privacy", "low-key", "security"],
            keywords: ["nda", "no cameras", "keep it low", "deleted", "footage", "discretion", "private", "low profile"],
            related: ["Paranoia & Surveillance", "After Hours"]
        ),
        "THEME_RELATIONSHIPS_ROTATION_121": Meta(
            hint: "Explores roster/rotation dynamics — main chick, side piece, city boys.",
            tags: ["relationships", "rotation", "toxic"],
            keywords: ["rotation", "roster", "main chick", "side piece", "city boys", "city girls", "wifey", "baddie", "dm", "slide"],
            related: ["Tricking & Providing", "Social Media & Clout"]
        ),
        "THEME_INDUSTRY_LABELS_030": Meta(
            hint: "Questions industry authenticity — plants, masters, 360 deals, label.",
            tags: ["industry", "business", "authenticity"],
            keywords: ["industry plant", "masters", "360 deal", "label", "grammy", "a&r", "advance", "equity", "streaming"],
            related: ["Wealth & Legacy", "Business vs Street"]
        ),
        "THEME_WEALTH_LEGACY_063": Meta(
            hint: "Shifts to CEO/legacy mindset — trust funds, land, generational wealth.",
            tags: ["legacy", "investing", "ceo"],
            keywords: ["generational", "trust fund", "equity", "portfolio", "land", "owning the masters", "mogul", "family office"],
            related: ["Real Estate", "Industry & Labels", "The Glow Up"]
        ),
        "THEME_PARANOIA_SURVEILLANCE_085": Meta(
            hint: "Adds watched/hunted tension — wiretaps, vans, feds, encrypted chats.",
            tags: ["paranoia", "surveillance", "danger"],
            keywords: ["wiretap", "surveillance", "van", "stakeout", "encrypted", "telegram", "signal", "burner", "tail", "watching"],
            related: ["Legal & Prison", "Discretion", "Weaponry"]
        ),
        "THEME_STREET_CODE_040": Meta(
            hint: "Reinforces street realness — no paperwork, civilians, taxing, solid.",
            tags: ["code", "realness", "street"],
            keywords: ["realness", "civilian", "taxing", "smacked", "solid", "omerta", "no paperwork", "street code"],
            related: ["Loyalty & Betrayal", "The Ops & Conflict", "Business vs Street"]
        ),
        "THEME_SPIRITUAL_ESOTERIC_034": Meta(
            hint: "Adds spiritual/matrix layer — evil eye, vibrations, ego death.",
            tags: ["spiritual", "matrix", "energy"],
            keywords: ["matrix", "vibration", "frequency", "evil eye", "aura", "third eye", "ego death", "red pill", "juju"],
            related: ["Paranoia & Surveillance", "Conspiracy & System"]
        ),
        "THEME_SOCIAL_MEDIA_132": Meta(
            hint: "Adds IG/clout mechanics — motion, photo dumps, blue check, DMs.",
            tags: ["social", "clout", "content"],
            keywords: ["instagram", "the gram", "motion", "photo dump", "blue check", "verified", "story", "clout", "tag me", "receipts"],
            related: ["Relationships & Rotation", "Clubs & Nightlife", "The Glow Up"]
        ),
        "THEME_ESCAPISM_080": Meta(
            hint: "Leans into numb/escape — flights, zaza clouds, island hopping.",
            tags: ["escape", "pain", "vice"],
            keywords: ["escapism", "numbing", "island", "clouds", "zaza", "pain", "forget"],
            related: ["Vice & Substances", "Travel & Flex"]
        ),
        "THEME_MONARCHY_079": Meta(
            hint: "Positions you as king/throne — crown, kingdom, apex predator.",
            tags: ["power", "royalty", "dominance"],
            keywords: ["throne", "kingdom", "crown", "king", "prince", "monarch", "apex"],
            related: ["Wealth & Legacy", "Real Estate"]
        ),
        "THEME_AFTER_HOURS_175": Meta(
            hint: "Extends into 4AM world — sprinter, safe house, after-party, cleanup.",
            tags: ["nightlife", "after-hours", "paranoia"],
            keywords: ["after party", "after-party", "4am", "sprinter", "safe house", "airbnb", "headcount", "collect the phones", "waffle house"],
            related: ["Clubs & Nightlife", "Discretion", "Vice & Substances"]
        ),
        "THEME_BUSINESS_STREET_228": Meta(
            hint: "Highlights CEO vs street identity clash — accountant, taxman, switch codes.",
            tags: ["identity", "business", "dual-life"],
            keywords: ["accountant", "taxman", "irs", "business expense", "corporate", "switch", "identity crisis"],
            related: ["Wealth & Legacy", "Street Code", "Industry & Labels"]
        ),
        "THEME_CONSPIRACY_SYSTEM_035": Meta(
            hint: "Adds system/matrix critique — 1%, puppet masters, digital dollars.",
            tags: ["conspiracy", "system", "awakening"],
            keywords: ["1%", "puppet", "sheep", "new world", "illuminati", "big pharma", "digital dollar", "glitch"],
            related: ["Spiritual & Esoteric", "Industry & Labels"]
        ),
        "THEME_HIGH_END_RETAIL_020": Meta(
            hint: "Adds luxury shopping flex — Saks, Neiman Marcus, Rodeo tabs.",
            tags: ["shopping", "retail", "spending"],
            keywords: ["saks", "neiman", "barneys", "rodeo drive", "running up a tab", "retail"],
            related: ["High Fashion", "Tricking & Providing", "Luxury Accessories"]
        )
    ]

    // MARK: - Theme entries (consolidated from CSV)

    private static let entries: [Theme] = [
        Theme(
            id: "THEME_LUXURY_HOROLOGY_001",
            name: "Luxury Horology",
            jargonTerms: ["Rolex", "AP (Audemars Piguet)", "Patek Philippe", "Richard Mille", "Cartier"],
            contextDescription: "Watch & jewelry flex signaling street-rich to wealthy.",
            relatedThemes: meta["THEME_LUXURY_HOROLOGY_001"]!.related,
            emotionalTone: "luxurious|aspirational"
        ),
        Theme(
            id: "THEME_THE_HUSTLE_002",
            name: "The Hustle",
            jargonTerms: ["The Trap", "The Kitchen", "Water", "Weight"],
            contextDescription: "Drug-trade origin as survival or wealth foundation.",
            relatedThemes: meta["THEME_THE_HUSTLE_002"]!.related,
            emotionalTone: "gritty|defiant"
        ),
        Theme(
            id: "THEME_DIGITAL_FINANCE_003",
            name: "Digital Finance",
            jargonTerms: ["Swipe", "Method", "Bin", "CashApp", "Bitcoin"],
            contextDescription: "Scam rap & digital street hustle evolution.",
            relatedThemes: meta["THEME_DIGITAL_FINANCE_003"]!.related,
            emotionalTone: "calculated|opportunistic"
        ),
        Theme(
            id: "THEME_HIGH_FASHION_004",
            name: "High Fashion",
            jargonTerms: ["Rick Owens", "Maison Margiela", "Chrome Hearts", "Celine"],
            contextDescription: "Avant-garde designer drip beyond mall brands.",
            relatedThemes: meta["THEME_HIGH_FASHION_004"]!.related,
            emotionalTone: "luxurious|aspirational"
        ),
        Theme(
            id: "THEME_FOOTWEAR_005",
            name: "Footwear",
            jargonTerms: ["Jordan 1s", "Yeezys", "Red Bottoms", "Bape Stas"],
            contextDescription: "Sneaker culture & footwear flex.",
            relatedThemes: meta["THEME_FOOTWEAR_005"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_THE_OPS_CONFLICT_006",
            name: "The Ops & Conflict",
            jargonTerms: ["Opps", "Drilling", "Spinning the block", "Smoke"],
            contextDescription: "Neighborhood rivalries & fame-era danger.",
            relatedThemes: meta["THEME_THE_OPS_CONFLICT_006"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_LEGAL_PRISON_007",
            name: "Legal & Prison",
            jargonTerms: ["Indictment", "RICO act", "The Feds", "Going up top"],
            contextDescription: "Legal system stakes & consequences.",
            relatedThemes: meta["THEME_LEGAL_PRISON_007"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_GEOGRAPHY_008",
            name: "Geography",
            jargonTerms: ["Area codes", "The 6", "The Town", "The A"],
            contextDescription: "Hometown pride & territory.",
            relatedThemes: meta["THEME_GEOGRAPHY_008"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_VICE_SUBSTANCES_009",
            name: "Vice & Substances",
            jargonTerms: ["Wockhardt", "Lean", "Gas/Zaza", "Percocet", "Addy"],
            contextDescription: "Escapism, partying & addiction references.",
            relatedThemes: meta["THEME_VICE_SUBSTANCES_009"]!.related,
            emotionalTone: "confident|celebratory"
        ),
        Theme(
            id: "THEME_LOYALTY_BETRAYAL_010",
            name: "Loyalty & Betrayal",
            jargonTerms: ["Snitching", "Ratting", "Day ones", "Circle small"],
            contextDescription: "Street moral code & trust after success.",
            relatedThemes: meta["THEME_LOYALTY_BETRAYAL_010"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_SPORTS_REFERENCES_011",
            name: "Sports References",
            jargonTerms: ["Shooting like Curry", "Ballin' like Kobe", "Draft day"],
            contextDescription: "Athlete metaphors for success & prowess.",
            relatedThemes: meta["THEME_SPORTS_REFERENCES_011"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_DINING_LIFESTYLE_012",
            name: "Dining & Lifestyle",
            jargonTerms: ["Nobu", "Catch", "Carbone", "Private Chefs", "PJ"],
            contextDescription: "Fine dining & private-jet lifestyle phase.",
            relatedThemes: meta["THEME_DINING_LIFESTYLE_012"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_WEAPONRY_013",
            name: "Weaponry",
            jargonTerms: ["Glock", "Draco", "Stick", "Pole", "30-round clip"],
            contextDescription: "Protection & aggression in drill context.",
            relatedThemes: meta["THEME_WEAPONRY_013"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_REAL_ESTATE_014",
            name: "Real Estate",
            jargonTerms: ["Penthouse", "Gated Community", "The Hills", "Buying the block back"],
            contextDescription: "Property as final success stage.",
            relatedThemes: meta["THEME_REAL_ESTATE_014"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_TRICKING_PROVIDING_015",
            name: "Tricking & Providing",
            jargonTerms: ["Trickin' off", "Sponsorship", "Pay the rent", "Allowance", "Birkin"],
            contextDescription: "Spending on partners — trickin', spoiling, finesse.",
            relatedThemes: meta["THEME_TRICKING_PROVIDING_015"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_COSMETIC_SURGERY_016",
            name: "Cosmetic Surgery",
            jargonTerms: ["BBL", "Turks & Caicos", "New body", "Doctor Shopping"],
            contextDescription: "Body upgrades as status symbol.",
            relatedThemes: meta["THEME_COSMETIC_SURGERY_016"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_LUXURY_ACCESSORIES_017",
            name: "Luxury Accessories",
            jargonTerms: ["Birkin Bag", "Kelly Bag", "Chanel", "Chinchilla"],
            contextDescription: "Bags & accessories as gifting currency.",
            relatedThemes: meta["THEME_LUXURY_ACCESSORIES_017"]!.related,
            emotionalTone: "luxurious|aspirational"
        ),
        Theme(
            id: "THEME_TRAVEL_FLEX_019",
            name: "Travel & Flex",
            jargonTerms: ["G5", "First Class", "Passport stamps", "Villas", "Exotic locations"],
            contextDescription: "Jet-set travel & global motion.",
            relatedThemes: meta["THEME_TRAVEL_FLEX_019"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_HIGH_END_RETAIL_020",
            name: "High-End Retail",
            jargonTerms: ["Saks Fifth Avenue", "Neiman Marcus", "Rodeo Drive"],
            contextDescription: "Luxury shopping & running up tabs.",
            relatedThemes: meta["THEME_HIGH_END_RETAIL_020"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_CLUBS_NIGHTLIFE_021",
            name: "Clubs & Nightlife",
            jargonTerms: ["Bottle Service", "Section", "Making it rain", "Starlets"],
            contextDescription: "Club dominance & bottle-service flex.",
            relatedThemes: meta["THEME_CLUBS_NIGHTLIFE_021"]!.related,
            emotionalTone: "confident|celebratory"
        ),
        Theme(
            id: "THEME_THE_GLOW_UP_022",
            name: "The Glow Up",
            jargonTerms: ["Transformation", "Used to have nothing", "Now we on", "Upgrade"],
            contextDescription: "Before/after fame transformation arc.",
            relatedThemes: meta["THEME_THE_GLOW_UP_022"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_DISCRETION_023",
            name: "Discretion",
            jargonTerms: ["NDA", "No cameras", "Keep it low", "Deleted the footage"],
            contextDescription: "Privacy in a high-stakes lifestyle.",
            relatedThemes: meta["THEME_DISCRETION_023"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_INDUSTRY_LABELS_030",
            name: "Industry & Labels",
            jargonTerms: ["Industry Plants", "Owned my masters", "360 Deals", "The Label"],
            contextDescription: "Music industry authenticity & deal politics.",
            relatedThemes: meta["THEME_INDUSTRY_LABELS_030"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_WEALTH_LEGACY_063",
            name: "Wealth & Legacy",
            jargonTerms: ["Generational Wealth", "Trust funds", "Equity", "Family Office"],
            contextDescription: "CEO mindset — owning vs spending.",
            relatedThemes: meta["THEME_WEALTH_LEGACY_063"]!.related,
            emotionalTone: "calculated|opportunistic"
        ),
        Theme(
            id: "THEME_PARANOIA_SURVEILLANCE_085",
            name: "Paranoia & Surveillance",
            jargonTerms: ["Wiretap", "The Van", "RICO Shadow", "Encrypted chats"],
            contextDescription: "Being watched — feds, opps, or the industry eye.",
            relatedThemes: meta["THEME_PARANOIA_SURVEILLANCE_085"]!.related,
            emotionalTone: "confident|paranoid"
        ),
        Theme(
            id: "THEME_STREET_CODE_040",
            name: "Street Code",
            jargonTerms: ["Paperwork", "Civilians", "Smacked", "Taxing", "Solid"],
            contextDescription: "Maintaining realness & street rules.",
            relatedThemes: meta["THEME_STREET_CODE_040"]!.related,
            emotionalTone: "gritty|defiant"
        ),
        Theme(
            id: "THEME_SPIRITUAL_ESOTERIC_034",
            name: "Spiritual & Esoteric",
            jargonTerms: ["Third Eye", "Vibrations", "Evil Eye", "Matrix", "Aura"],
            contextDescription: "Spiritual warfare & matrix consciousness.",
            relatedThemes: meta["THEME_SPIRITUAL_ESOTERIC_034"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_SOCIAL_MEDIA_132",
            name: "Social Media & Clout",
            jargonTerms: ["Motion", "Photo Dumps", "Blue Check", "The DM", "Clout Chasing"],
            contextDescription: "Instagram-era proof-of-life & digital courtship.",
            relatedThemes: meta["THEME_SOCIAL_MEDIA_132"]!.related,
            emotionalTone: "opportunistic|confident"
        ),
        Theme(
            id: "THEME_ESCAPISM_080",
            name: "Escapism",
            jargonTerms: ["G5 flights", "Zaza clouds", "Island hopping", "Numbing the pain"],
            contextDescription: "Using vice or travel to flee reality.",
            relatedThemes: meta["THEME_ESCAPISM_080"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_MONARCHY_079",
            name: "Monarchy & Power",
            jargonTerms: ["The Throne", "Kingdom", "Crown", "Prince of the City"],
            contextDescription: "King/God positioning & dominance.",
            relatedThemes: meta["THEME_MONARCHY_079"]!.related,
            emotionalTone: "confident"
        ),
        Theme(
            id: "THEME_AFTER_HOURS_175",
            name: "After Hours",
            jargonTerms: ["The Sprinter", "Safe House", "Collect the Phones", "Waffle House"],
            contextDescription: "4AM transition — after-party to cleanup.",
            relatedThemes: meta["THEME_AFTER_HOURS_175"]!.related,
            emotionalTone: "confident|paranoid"
        ),
        Theme(
            id: "THEME_BUSINESS_STREET_228",
            name: "Business vs Street",
            jargonTerms: ["The Taxman", "Wire Transfer", "Quarterly Reports", "Tax Write-off"],
            contextDescription: "Switching between corporate & street codes.",
            relatedThemes: meta["THEME_BUSINESS_STREET_228"]!.related,
            emotionalTone: "gritty|defiant"
        ),
        Theme(
            id: "THEME_CONSPIRACY_SYSTEM_035",
            name: "Conspiracy & System",
            jargonTerms: ["Red pill", "The 1%", "Puppet Masters", "Digital Dollars"],
            contextDescription: "Hidden forces & system critique.",
            relatedThemes: meta["THEME_CONSPIRACY_SYSTEM_035"]!.related,
            emotionalTone: "confident|paranoid"
        ),
        Theme(
            id: "THEME_RELATIONSHIPS_ROTATION_121",
            name: "Relationships & Rotation",
            jargonTerms: ["Rotation", "Roster", "City Boys", "City Girls", "Main Chick"],
            contextDescription: "Roster dynamics & toxic relationship games.",
            relatedThemes: meta["THEME_RELATIONSHIPS_ROTATION_121"]!.related,
            emotionalTone: "confident|celebratory"
        )
    ]
}
