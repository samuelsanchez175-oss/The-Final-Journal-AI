import SwiftUI
import Foundation
import NaturalLanguage

// MARK: - Local Type Definitions (to avoid type resolution issues)

nonisolated private enum RhymeStrength: Double, Sendable {
    case perfect = 1.0
    case near = 0.75
    case slant = 0.55
}

nonisolated private struct PhoneticSignature: Sendable {
    let stressedVowel: String
    let coda: [String]
}

nonisolated private func extractSignature(from phonemes: [String]) -> PhoneticSignature? {
    // Anchor on the last STRESSED vowel (CMUDICT stress marker 1 or 2), not the last vowel.
    // CMUDICT marks EVERY vowel with a stress digit (0/1/2), so the last digit-bearing phoneme is
    // often an unstressed final vowel — e.g. "crazy" K R EY1 Z IY0 → IY0 with an empty coda —
    // which over-loosens rhyme matching to bare assonance ("-y" endings). Fall back to the last
    // vowel of any stress only when none is stressed.
    // (Mirrors GhostSuggestionEngine.phoneticSignature, fixed in 558937e.)
    let stressed = phonemes.lastIndex { $0.last == "1" || $0.last == "2" }
    guard let idx = stressed ?? phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
        return nil
    }
    let vowel = phonemes[idx]
    let coda = Array(phonemes.dropFirst(idx + 1))
    return PhoneticSignature(stressedVowel: vowel, coda: coda)
}

nonisolated private func rhymeScore(_ a: PhoneticSignature, _ b: PhoneticSignature) -> RhymeStrength? {
    if a.stressedVowel == b.stressedVowel && a.coda == b.coda {
        return .perfect
    }
    if a.stressedVowel == b.stressedVowel {
        return .near
    }
    // Check for slant rhyme (similar vowels)
    let baseA = String(a.stressedVowel.dropLast())
    let baseB = String(b.stressedVowel.dropLast())
    if baseA == baseB {
        return .slant
    }
    return nil
}

nonisolated private func getCMUDICTPhonemes(for word: String) -> [String]? {
    return getGlobalCMUDICTStore()[word.lowercased()]
}

// MARK: - Rhyme Suggestion View (for last word)

struct RhymeSuggestionView: View {
    let rhymes: [RhymeSuggestion]
    let targetWord: String
    let onSelect: (String) -> Void
    let onDismiss: () -> Void

    private enum ZoneTab: String, CaseIterable, Identifiable {
        case rhymes = "Rhymes"
        case near = "Near rhymes"
        case slant = "Slant"
        case related = "Related words"
        case similar = "Similar sound"
        case consonants = "Same consonants"
        var id: String { rawValue }
    }

    @State private var tab: ZoneTab = .rhymes
    @State private var related: [DatamuseRhymeClient.Hit] = []
    @State private var similar: [DatamuseRhymeClient.Hit] = []
    @State private var consonants: [DatamuseRhymeClient.Hit] = []
    @State private var isLoadingExtras = false

    private var perfect: [RhymeSuggestion] { rhymes.filter { $0.strength == .perfect } }
    private var near: [RhymeSuggestion] { rhymes.filter { $0.strength == .near } }
    private var slant: [RhymeSuggestion] { rhymes.filter { $0.strength == .slant } }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                header
                tabBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        tabBody
                        advancedLinks
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
            .background(Momentum.surfaceElevated)
            .navigationTitle("Suggest Rhymes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: onDismiss)
                        .foregroundStyle(Momentum.accent)
                }
            }
            .task(id: targetWord) {
                await loadExtras()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Words and phrases that rhyme with")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
            Text(targetWord.lowercased())
                .font(.title2.weight(.semibold))
                .italic()
            Text(resultCountLine)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var resultCountLine: String {
        let n: Int
        switch tab {
        case .rhymes: n = perfect.count
        case .near: n = near.count
        case .slant: n = slant.count
        case .related: n = related.count
        case .similar: n = similar.count
        case .consonants: n = consonants.count
        }
        return n == 1 ? "1 result" : "\(n) results"
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ZoneTab.allCases) { item in
                    Button {
                        tab = item
                    } label: {
                        Text(item.rawValue)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(tab == item ? Color(RhymeColorPalette.colors[3]).opacity(0.22) : Color.clear)
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .strokeBorder(
                                        tab == item ? Color(RhymeColorPalette.colors[3]) : Momentum.hairline,
                                        lineWidth: Momentum.lineThin
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(tab == item ? Color(RhymeColorPalette.colors[3]) : Momentum.contentPrimary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var tabBody: some View {
        switch tab {
        case .rhymes:
            syllableSections(RhymeFinder.groupedBySyllable(perfect))
        case .near:
            syllableSections(RhymeFinder.groupedBySyllable(near))
        case .slant:
            syllableSections(RhymeFinder.groupedBySyllable(slant))
        case .related:
            remoteSections(related, empty: "No related words yet.")
        case .similar:
            remoteSections(similar, empty: "No similar-sounding words yet.")
        case .consonants:
            remoteSections(consonants, empty: "No same-consonant matches yet.")
        }
    }

    @ViewBuilder
    private func syllableSections(_ groups: [RhymeSyllableGroup]) -> some View {
        if groups.isEmpty {
            Text("No rhymes in this tab.")
                .font(.callout)
                .foregroundStyle(Momentum.contentSecondary)
        } else {
            ForEach(groups, id: \.syllables) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.syllables == 1 ? "1 syllable" : "\(group.syllables) syllables")
                        .font(.subheadline.weight(.semibold))
                    wordFlow(group.words)
                }
            }
        }
    }

    @ViewBuilder
    private func remoteSections(_ hits: [DatamuseRhymeClient.Hit], empty: String) -> some View {
        if isLoadingExtras && hits.isEmpty {
            ProgressView()
        } else if hits.isEmpty {
            Text(empty)
                .font(.callout)
                .foregroundStyle(Momentum.contentSecondary)
        } else {
            let grouped = RhymeFinder.groupedBySyllable(words: hits.map { ($0.word, $0.numSyllables ?? 1) })
            syllableSections(grouped)
        }
    }

    private func wordFlow(_ words: [String]) -> some View {
        FlowLayout(spacing: 8) {
            ForEach(words, id: \.self) { word in
                Button {
                    onSelect(word)
                } label: {
                    Text(word.lowercased())
                        .font(.callout)
                        .foregroundStyle(Color(RhymeColorPalette.colors[3]))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var advancedLinks: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider().opacity(0.3)
            Text("More on RhymeZone")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Momentum.contentSecondary)
            if let perfect = RhymeFinder.rhymeZonePerfectURL(for: targetWord) {
                Link(destination: perfect) {
                    Label("Open syllable view on RhymeZone", systemImage: "safari")
                        .font(.callout.weight(.semibold))
                }
            }
            if let advanced = RhymeFinder.rhymeZoneAdvancedURL(for: targetWord) {
                Link(destination: advanced) {
                    Label("Advanced view", systemImage: "slider.horizontal.3")
                        .font(.callout.weight(.semibold))
                }
            }
        }
        .tint(Color(RhymeColorPalette.colors[3]))
    }

    private func loadExtras() async {
        isLoadingExtras = true
        defer { isLoadingExtras = false }
        async let rel = DatamuseRhymeClient.related(to: targetWord)
        async let sim = DatamuseRhymeClient.soundsLike(targetWord)
        async let cns = DatamuseRhymeClient.sameConsonants(as: targetWord)
        related = await rel
        similar = await sim
        consonants = await cns
    }
}

// MARK: - Rhyme Suggestion

struct RhymeSuggestion: Identifiable {
    let id = UUID()
    let word: String
    fileprivate let strength: RhymeStrength
    let syllableCount: Int
}

struct RhymeSyllableGroup: Equatable {
    let syllables: Int
    let words: [String]
}

// MARK: - Rhyme Finder Helper

nonisolated final class RhymeFinder: @unchecked Sendable {
    /// Rhyme tier over raw CMUDICT phoneme arrays — the single rhyme classifier used by
    /// `findRhymes` and exercised directly (CMUDICT-independent) by tests.
    /// 3 = perfect (same stressed vowel + coda), 2 = near (same stressed vowel, different coda),
    /// 1 = slant (same base vowel), 0 = no rhyme.
    nonisolated static func rhymeTier(_ a: [String], _ b: [String]) -> Int {
        guard let sigA = extractSignature(from: a),
              let sigB = extractSignature(from: b),
              let strength = rhymeScore(sigA, sigB) else {
            return 0
        }
        switch strength {
        case .perfect: return 3
        case .near:    return 2
        case .slant:   return 1
        }
    }

    /// CMUDICT keys that are real words a rapper would tap — not `a.d.` / `ab(2)`.
    static func isUsableRhymeHeadword(_ key: String) -> Bool {
        let k = key.lowercased()
        guard !k.isEmpty else { return false }
        if k.contains(where: { !$0.isLetter && $0 != "'" && $0 != "’" }) { return false }
        let letters = k.filter(\.isLetter)
        return (3...12).contains(letters.count)
    }

    static func sortRapUseful(_ words: [String]) -> [String] {
        words.sorted { a, b in
            if a.count != b.count { return a.count < b.count }
            return a < b
        }
    }

    /// Shared list for tap-to-rhyme and Ghost. Perfect, then near, then slant; short words first.
    static func rankedRhymeWords(for word: String, limit: Int = 8) -> [String] {
        rankedRhymeEntries(for: word, limit: limit).map(\.word)
    }

    /// Precompute rhyme buckets so a word tap does not scan the whole CMUDICT on the main thread.
    nonisolated static func warmIndex() {
        _ = rhymeLookup()
    }

    private struct RhymeLookup {
        let dictCount: Int
        let perfect: [String: [String]]
        let near: [String: [String]]
        let slant: [String: [String]]
    }

    private static let lookupLock = NSLock()
    private static var cachedLookup: RhymeLookup?

    private static func rhymeLookup() -> RhymeLookup {
        let dict = getGlobalCMUDICTStore()
        lookupLock.lock()
        defer { lookupLock.unlock() }
        if let cachedLookup, cachedLookup.dictCount == dict.count {
            return cachedLookup
        }
        var perfect: [String: [String]] = [:]
        var near: [String: [String]] = [:]
        var slant: [String: [String]] = [:]
        for (word, phonemes) in dict {
            let key = word.lowercased()
            guard isUsableRhymeHeadword(key), let sig = extractSignature(from: phonemes) else { continue }
            let perfectKey = sig.stressedVowel + "|" + sig.coda.joined(separator: " ")
            perfect[perfectKey, default: []].append(key)
            near[sig.stressedVowel, default: []].append(key)
            slant[String(sig.stressedVowel.dropLast()), default: []].append(key)
        }
        let built = RhymeLookup(dictCount: dict.count, perfect: perfect, near: near, slant: slant)
        cachedLookup = built
        return built
    }

    fileprivate static func rankedRhymeEntries(for word: String, limit: Int) -> [(word: String, strength: RhymeStrength)] {
        let cleaned = word.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines)).lowercased()
        guard !cleaned.isEmpty,
              let phonemes = getCMUDICTPhonemes(for: cleaned),
              let sig = extractSignature(from: phonemes) else {
            return []
        }

        let buckets = rhymeLookup()
        let perfectKey = sig.stressedVowel + "|" + sig.coda.joined(separator: " ")
        let perfectSet = Set((buckets.perfect[perfectKey] ?? []).filter { $0 != cleaned })
        var ordered = sortRapUseful(Array(perfectSet))
        var nearSet: Set<String> = []
        if ordered.count < limit {
            nearSet = Set((buckets.near[sig.stressedVowel] ?? []).filter { $0 != cleaned && !perfectSet.contains($0) })
            ordered.append(contentsOf: sortRapUseful(Array(nearSet)))
        }
        if ordered.count < limit {
            let skip = perfectSet.union(nearSet)
            let slantWords = (buckets.slant[String(sig.stressedVowel.dropLast())] ?? []).filter {
                $0 != cleaned && !skip.contains($0)
            }
            ordered.append(contentsOf: sortRapUseful(slantWords))
        }
        return ordered.prefix(limit).map { headword in
            let strength: RhymeStrength
            if perfectSet.contains(headword) { strength = .perfect }
            else if nearSet.contains(headword) { strength = .near }
            else { strength = .slant }
            return (headword, strength)
        }
    }

    static func findRhymes(for word: String, limit: Int = 8) -> [RhymeSuggestion] {
        rankedRhymeEntries(for: word, limit: limit).map { entry in
            RhymeSuggestion(
                word: entry.word,
                strength: entry.strength,
                syllableCount: SyllableEngine.syllableCount(word: entry.word)
            )
        }
    }

    /// RhymeZone-style buckets: 1 syllable, 2 syllables, …
    static func groupedBySyllable(_ rhymes: [RhymeSuggestion]) -> [RhymeSyllableGroup] {
        groupedBySyllable(words: rhymes.map { ($0.word, $0.syllableCount) })
    }

    static func groupedBySyllable(words: [(String, Int)]) -> [RhymeSyllableGroup] {
        let buckets = Dictionary(grouping: words, by: { max(1, $0.1) })
        return buckets.keys.sorted().map { count in
            let names = (buckets[count] ?? []).map(\.0).sorted { $0.lowercased() < $1.lowercased() }
            return RhymeSyllableGroup(syllables: count, words: names)
        }
    }

    static func rhymeZonePerfectURL(for word: String) -> URL? {
        rhymeZoneURL(word: word, type: "perfect", extra: ["org1": "syl", "org2": "l", "org3": "y"])
    }

    static func rhymeZoneAdvancedURL(for word: String) -> URL? {
        rhymeZoneURL(word: word, type: "adv", extra: ["loc": "advlink3"])
    }

    private static func rhymeZoneURL(word: String, type: String, extra: [String: String]) -> URL? {
        var items = [URLQueryItem(name: "Word", value: word), URLQueryItem(name: "typeofrhyme", value: type)]
        items.append(contentsOf: extra.map { URLQueryItem(name: $0.key, value: $0.value) })
        var comps = URLComponents(string: "https://www.rhymezone.com/r/rhyme.cgi")
        comps?.queryItems = items
        return comps?.url
    }
}


