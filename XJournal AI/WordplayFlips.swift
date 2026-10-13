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
    let tabs: [String]?       // assigned main category IDs (nil = unassigned → "Unsorted")
    let subTabs: [String]?    // assigned subcategory IDs (nil = no supported subtype → "Unsorted")
}

/// Main Blocks tabs. Each maps to a `tabs` value stored in WordplayEntry records.
///
/// Counter semantics (computed from the live catalog, never hardcoded):
///   - Main-tab count  = distinct entries whose `tabs` contains this ID.
///                     Unassigned entries are counted only in the global "All" view.
///   - An entry may carry several `tabs` values and is counted once per view.
enum WordplayTab: String, CaseIterable, Identifiable {

    var id: String { rawValue }

    case soundFlips = "sound_flips"
    case doubleMeanings = "double_meanings"
    case splitNames = "split_names"
    case hiddenReferences = "hidden_references"
    case punchlineSetups = "punchline_setups"

    var title: String {
        switch self {
        case .soundFlips: return "Sound flips & homophones"
        case .doubleMeanings: return "Double meanings"
        case .splitNames: return "Split names & brands"
        case .hiddenReferences: return "Hidden references"
        case .punchlineSetups: return "Punchline setups"
        }
    }

    /// Second-level navigation groups. Navigation only — no wordplay is inferred.
    /// Entries with `subTabs` matching one of these land in the corresponding group;
    /// everything else in the parent category falls into "Unsorted".
    var subTabs: [WordplaySubTab] {
        switch self {
        case .soundFlips:
            return [.all, .homophones, .nearSoundFlips, .pronunciationAndAccent,
                    .multiwordSoundFlips, .unsorted]
        case .doubleMeanings:
            return [.all, .literalAndFigurative, .slangAndEverydayMeaning,
                    .multipleDictionaryMeanings, .namesAndCommonWords,
                    .threeOrMoreMeanings, .unsorted]
        case .splitNames:
            return [.all, .peopleAndStageNames, .brandsAndProducts, .placesAndOrganizations,
                    .titlesAndNamedWorks, .peoplePlacesAndThings, .unsorted]
        case .hiddenReferences:
            return [.all, .musicAndLyrics, .filmAndTV, .sports, .peopleAndHistory,
                    .gamesAndInternetCulture, .unsorted]
        case .punchlineSetups:
            return [.all, .setupAndPayoff, .comparisonsAndSimiles, .boastsAndDisses,
                    .observationalJokes, .unsorted]
        }
    }
}

/// Subcategories within a main Blocks tab.
///
/// Each `rawValue` maps to a `subTabs` value in WordplayEntry records.
/// "Unsorted" holds entries that already belong to the parent category but have
/// no supported subcategory assignment, so they remain discoverable. "All" mirrors
/// the parent category's total.
enum WordplaySubTab: String, CaseIterable, Identifiable {
    case all = "all"
    case homophones = "homophones"
    case nearSoundFlips = "near_sound_flips"
    case pronunciationAndAccent = "pronunciation_and_accent"
    case multiwordSoundFlips = "multiword_sound_flips"
    case literalAndFigurative = "literal_and_figurative"
    case slangAndEverydayMeaning = "slang_and_everyday_meaning"
    case multipleDictionaryMeanings = "multiple_dictionary_meanings"
    case namesAndCommonWords = "names_and_common_words"
    case threeOrMoreMeanings = "three_or_more_meanings"
    case peopleAndStageNames = "people_and_stage_names"
    case brandsAndProducts = "brands_and_products"
    case placesAndOrganizations = "places_and_organizations"
    case titlesAndNamedWorks = "titles_and_named_works"
    case peoplePlacesAndThings = "people_places_and_things"
    case musicAndLyrics = "music_and_lyrics"
    case filmAndTV = "film_and_tv"
    case sports = "sports"
    case peopleAndHistory = "people_and_history"
    case gamesAndInternetCulture = "games_and_internet_culture"
    case setupAndPayoff = "setup_and_payoff"
    case comparisonsAndSimiles = "comparisons_and_similes"
    case boastsAndDisses = "boasts_and_disses"
    case observationalJokes = "observational_jokes"
    case unsorted = "unsorted"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .homophones: return "Homophones"
        case .nearSoundFlips: return "Near-sound flips"
        case .pronunciationAndAccent: return "Pronunciation & accent"
        case .multiwordSoundFlips: return "Multiword sound flips"
        case .literalAndFigurative: return "Literal & figurative"
        case .slangAndEverydayMeaning: return "Slang & everyday meaning"
        case .multipleDictionaryMeanings: return "Multiple dictionary meanings"
        case .namesAndCommonWords: return "Names & common words"
        case .threeOrMoreMeanings: return "Three or more meanings"
        case .peopleAndStageNames: return "People & stage names"
        case .brandsAndProducts: return "Brands & products"
        case .placesAndOrganizations: return "Places & organizations"
        case .titlesAndNamedWorks: return "Titles & named works"
        case .peoplePlacesAndThings: return "People, places & things"
        case .musicAndLyrics: return "Music & lyrics"
        case .filmAndTV: return "Film & TV"
        case .sports: return "Sports"
        case .peopleAndHistory: return "People & history"
        case .gamesAndInternetCulture: return "Games & internet culture"
        case .setupAndPayoff: return "Setup & payoff"
        case .comparisonsAndSimiles: return "Comparisons & similes"
        case .boastsAndDisses: return "Boasts & disses"
        case .observationalJokes: return "Observational jokes"
        case .unsorted: return "Unsorted"
        }
    }

    /// The parent category this sub-tab belongs to.
    var parent: WordplayTab? {
        switch self {
        case .homophones, .nearSoundFlips, .pronunciationAndAccent, .multiwordSoundFlips:
            return .soundFlips
        case .literalAndFigurative, .slangAndEverydayMeaning, .multipleDictionaryMeanings,
             .namesAndCommonWords, .threeOrMoreMeanings:
            return .doubleMeanings
        case .peopleAndStageNames, .brandsAndProducts, .placesAndOrganizations,
             .titlesAndNamedWorks, .peoplePlacesAndThings:
            return .splitNames
        case .musicAndLyrics, .filmAndTV, .sports, .peopleAndHistory, .gamesAndInternetCulture:
            return .hiddenReferences
        case .setupAndPayoff, .comparisonsAndSimiles, .boastsAndDisses, .observationalJokes:
            return .punchlineSetups
        case .all, .unsorted:
            return nil
        }
    }
}

/// Namespace for the Blocks wordplay catalog. The static helpers below operate on the
/// `WordplayEntry` data decoded from `WordplayFlips.json`.
enum WordplayFlips {
    /// All entries decoded from WordplayFlips.json (empty if the bundle file is missing).
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

    /// True only when the chip's entry has reviewed membership in `tab`.
    /// Unassigned entries belong to no tab, and punchline membership may overlap others.
    static func contains(_ chip: String, in tab: WordplayTab) -> Bool {
        let k = NounBankMark.normalize(chip)
        return all.contains {
            NounBankMark.normalize($0.chip) == k && ($0.tabs ?? []).contains(tab.rawValue)
        }
    }
}

extension WordplayFlips {

    /// Entry identity used for deduplication within a view: normalized chip text.
    /// Each JSON array element is a distinct record even when its chip text collides,
    /// so identity is the normalized chip plus the original record index.
    private static func identity(for entry: WordplayEntry, at index: Int) -> String {
        "\(index)\u{1e}\(NounBankMark.normalize(entry.chip))"
    }

    /// All entries decoded from WordplayFlips.json. Returns [] gracefully if the
    /// bundled data file is missing, rather than crashing.
    private static var allEntries: [WordplayEntry] { all }

    /// Total distinct entries in the catalog, including entries without any tab assignment.
    /// Counted over all records so the global "All" view keeps every entry discoverable.
    static var allEntryCount: Int {
        Set(allEntries.enumerated().map { identity(for: $0.element, at: $0.offset) }).count
    }

    /// Entries that carry at least one `tabs` assignment (for the completeness note).
    static var entriesWithTabAssignment: Int {
        allEntries.filter { $0.tabs != nil && !$0.tabs!.isEmpty }.count
    }

    /// Distinct entries that belong to a given main category.
    ///
    /// Only entries whose `tabs` explicitly contains the category ID count. Entries
    /// with no assignment are not members of any technique tab; they stay discoverable
    /// in the global "All" view. Each record is counted once.
    static func entryCount(for tab: WordplayTab) -> Int {
        let needle = tab.rawValue
        var seen = Set<String>()
        var count = 0
        for (index, entry) in allEntries.enumerated() {
            guard seen.insert(identity(for: entry, at: index)).inserted else { continue }
            if (entry.tabs ?? []).contains(needle) { count += 1 }
        }
        return count
    }

    /// Distinct entries within a sub-category, scoped to its parent category.
    ///
    /// - `subTab` == `all`: membership equals the parent category's total (`entryCount(for:)`).
    /// - `unsorted`: entries in the parent category with no subtype yet.
    /// - Concrete subtype: entries whose `tabs` matches the parent AND whose `subTabs`
    ///   matches this subtype.
    ///
    /// Returns 0 only when the scoped set truly is empty.
    static func entryCount(for subTab: WordplaySubTab, within parent: WordplayTab) -> Int {
        guard subTab.parent == parent else { return 0 }
        if subTab == .all { return entryCount(for: parent) }
        let parentNeedle = parent.rawValue
        let subtypeNeedle = subTab.rawValue
        var seen = Set<String>()
        var count = 0
        for (index, entry) in allEntries.enumerated() {
            guard seen.insert(identity(for: entry, at: index)).inserted else { continue }
            guard (entry.tabs ?? []).contains(parentNeedle) else { continue }
            if subTab == .unsorted {
                if (entry.subTabs ?? []).isEmpty { count += 1 }
            } else if (entry.subTabs ?? []).contains(subtypeNeedle) {
                count += 1
            }
        }
        return count
    }
}
