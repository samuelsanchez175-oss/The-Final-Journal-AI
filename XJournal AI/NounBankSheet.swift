import SwiftUI

enum NounBankGroup: String, CaseIterable, Identifiable {
    case people = "People"
    case athletes = "Athletes"
    case places = "Places"
    case food = "Food"
    case liquids = "Liquids"
    case ice = "Ice"
    case wear = "Wear"
    case street = "Street"
    case vehicles = "Vehicles"
    case animals = "Animals"
    case apps = "Apps"
    case games = "Games"
    case looks = "Looks"
    case flowers = "Flowers"
    case feelings = "Feelings"
    case phrases = "Phrases"
    case wordplay = "Play on Words"
    case fos = "FOS"

    var id: String { rawValue }

    var categories: [NounBankCategory] {
        switch self {
        case .people: return [.family, .friends, .producers, .artists, .celebs, .events, .characters, .actors, .streamers, .religion]
        case .athletes: return [.nba, .nfl, .boxing, .sports, .wrestlers]
        case .places: return [.places]
        case .food: return [.food]
        case .liquids: return [.liquors, .syrups, .drugs, .substances]
        case .ice: return [.jewelry, .grills, .jewelers, .money]
        case .wear: return [.brands, .clothing, .hair, .nails, .tattoos, .lingerie, .toys]
        case .street: return [.guns, .kill, .opps, .woman, .twerk, .streets, .kingpin, .trapLife, .paranoia]
        case .vehicles: return [.cars, .motorcycles, .boats, .aviation, .military]
        case .animals: return [.animals, .insects]
        case .apps: return [.apps]
        case .games: return [.games]
        case .looks: return [.looks]
        case .flowers: return [.flowers]
        case .feelings: return [.feelings]
        case .phrases: return [.phrases]
        case .wordplay: return [.wordplay]
        case .fos: return []
        }
    }

    static func containing(_ category: NounBankCategory) -> NounBankGroup {
        allCases.first { $0.categories.contains(category) } ?? .liquids
    }

    /// Neighbor pill inside this group.
    /// `step` +1 is the next pill (finger moving left). −1 is the previous (finger moving right).
    /// Nil at either end, and when `current` is not in this group. No wrap.
    func category(steppedBy step: Int, from current: NounBankCategory) -> NounBankCategory? {
        guard step != 0, let index = categories.firstIndex(of: current) else { return nil }
        let next = index + step
        guard categories.indices.contains(next) else { return nil }
        return categories[next]
    }
}

enum NounBankSearch {
    struct Hit: Identifiable, Equatable {
        let item: NounBankItem
        let category: NounBankCategory
        var id: String { "\(category.rawValue)\u{1e}\(item.insertWord)" }
    }

    /// Empty query → selected pocket. Non-empty → every `NounBankCategory`.
    static func hits(query: String, selected: NounBankCategory) -> [Hit] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if needle.isEmpty {
            return NounBankCatalog.items(for: selected).map { Hit(item: $0, category: selected) }
        }
        var hits: [Hit] = []
        for cat in NounBankCategory.allCases {
            for item in NounBankCatalog.items(for: cat) where matches(item, needle: needle) {
                hits.append(Hit(item: item, category: cat))
            }
        }
        return hits
    }

    static func matches(_ item: NounBankItem, needle: String) -> Bool {
        item.insertWord.localizedCaseInsensitiveContains(needle)
            || item.label.localizedCaseInsensitiveContains(needle)
            || (item.canonical?.localizedCaseInsensitiveContains(needle) ?? false)
    }
}

/// Offline noun picker. A tile opens catalog lines that mention that noun.
/// The noun page leads with a short take, then a button that filters those lines by artist.
enum NounBankFeelingsNote {
    static let text = "Each chip opens two lists: the feeling, and the word said literally."
    static let page = "These lines are split into the feeling and the literal use of the word."
}

struct NounBankSheet: View {
    let onInsert: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @AppStorage("nounBank.lastCategory") private var lastCategoryRaw = NounBankCategory.liquors.rawValue
    @AppStorage("nounBank.lastGroup") private var lastGroupRaw = ""
    @State private var group: NounBankGroup = .liquids
    @State private var category: NounBankCategory = .liquors
    @State private var fosArtist = FigurativeSpeech.artists[0]
    @State private var fosFigure: String? = nil
    @State private var showingRecents = false
    @State private var query = ""
    @State private var linesHit: NounBankSearch.Hit?
    @State private var mentionCounts: [String: Int] = [:]
    @State private var wordplayTab: WordplayTab? = nil
    @State private var wordplaySubTab: WordplaySubTab? = nil
    @State private var wordplaySubTabScrollID: WordplaySubTab? = nil


    /// Formats integer counts with locale-aware number formatting
    private var formattedCount: (Int) -> String { { count in
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }}

    /// The main tab row showing All and the 5 Blocks categories with live counters
    private var wordplayTabRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                wordplayTabPill(title: "All", count: WordplayFlips.allEntryCount, selected: wordplayTab == nil) {
                    selectWordplayTab(nil)
                }
                ForEach(WordplayTab.allCases) { tab in
                    wordplayTabPill(
                        title: tab.title,
                        count: WordplayFlips.entryCount(for: tab),
                        selected: wordplayTab == tab
                    ) {
                        selectWordplayTab(tab)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
    }

    /// The sub-tab row showing subcategories for the selected Blocks tab
    private var wordplaySubTabRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let tab = wordplayTab {
                    ForEach(tab.subTabs) { subTab in
                        wordplaySubTabPill(
                            title: subTab.title,
                            count: WordplayFlips.entryCount(for: subTab, within: tab),
                            selected: wordplaySubTab == subTab
                        ) {
                            selectWordplaySubTab(subTab)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    /// Reusable pill view for Blocks tabs and sub-tabs with count and selection state
    private func wordplayTabPill(title: String, count: Int, selected: Bool,
                               action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(selected ? Momentum.contentPrimary : Momentum.contentSecondary)
                    .lineLimit(1)
                Text(formattedCount(count))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(selected ? Momentum.contentPrimary : Momentum.contentSecondary)
                    .monospacedDigit()
            }
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Capsule()
                    .fill(selected ? Color(RhymeColorPalette.colors[1]).opacity(0.22) : Color.primary.opacity(0.04))
                    .overlay(
                        Capsule()
                            .strokeBorder(selected ? Color(RhymeColorPalette.colors[1]) : Color.primary.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(formattedCount(count)) entries, selected")
    }

    /// Reusable pill view for Blocks sub-tabs (same as tab pill but for consistency)
    private func wordplaySubTabPill(title: String, count: Int, selected: Bool,
                                  action: @escaping () -> Void) -> some View {
        wordplayTabPill(title: title, count: count, selected: selected, action: action)
    }

    private var needle: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool { !needle.isEmpty }

    /// Play on Words shows the Blocks rows. Search and Recents stay on the noun grid.
    private var showsWordplayRows: Bool {
        !isSearching && !showingRecents && group == .wordplay
    }

    /// FOS shows the artist row and the figure row.
    private var showsFOSRows: Bool {
        !isSearching && !showingRecents && group == .fos
    }

    private var hits: [NounBankSearch.Hit] {
        let hits = NounBankSearch.hits(query: query, selected: category)
        guard showsWordplayRows else { return hits }
        return hits.filter(matchesWordplayTab)
    }

    private func matchesWordplayTab(_ hit: NounBankSearch.Hit) -> Bool {
        guard let tab = wordplayTab else { return true }
        let chip = hit.item.insertWord
        if let subTab = wordplaySubTab, subTab != .all {
            return WordplayFlips.contains(chip, in: tab, subTab: subTab)
        }
        return WordplayFlips.contains(chip, in: tab)
    }

    private var recentHits: [NounBankSearch.Hit] {
        guard !isSearching else { return [] }
        return NounBankRecents.items.compactMap { entry in
            NounBankCatalog.items(for: entry.category).first {
                $0.insertWord.localizedCaseInsensitiveCompare(entry.word) == .orderedSame
            }.map { NounBankSearch.Hit(item: $0, category: entry.category) }
        }
    }

    private var gridHits: [NounBankSearch.Hit] {
        if isSearching { return hits }
        if showingRecents { return recentHits }
        return hits
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 64), spacing: 8), count: 4)
    }

    /// Data completeness note — explains partial catalog data
    private var dataCompletenessNote: Text? {
        guard showsWordplayRows else { return nil }
        let assignedCount = WordplayFlips.entriesWithTabAssignment
        let totalCount = WordplayFlips.allEntryCount
        let unassignedCount = totalCount - assignedCount
        if unassignedCount == 0 { return nil }
        return Text("\(formattedCount(unassignedCount)) entries need review and appear only under All. \(formattedCount(assignedCount)) of \(formattedCount(totalCount)) entries have explicit tab membership.")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabStrip
                if let note = dataCompletenessNote {
                    note
                }
                if showsFeelingNote {
                    feelingNote
                }

                if showsFOSRows {
                    fosList
                } else if gridHits.isEmpty {
                    emptyState
                } else {
                    chipGrid
                }
            }
            .background(Momentum.surface)
            .toolbarBackground(Momentum.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(text: $query, prompt: "Search all nouns")
            .navigationTitle("Nouns")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: Binding(
                get: { linesHit != nil },
                set: { if !$0 { linesHit = nil } }
            )) {
                if let linesHit {
                    NounMentionLinesView(
                        hit: linesHit,
                        count: mentionCounts[linesHit.id]
                    ) {
                        insert(linesHit)
                        dismiss()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                if NounBankGroup(rawValue: lastGroupRaw) == .fos {
                    group = .fos
                    showingRecents = false
                } else if let saved = NounBankCategory(rawValue: lastCategoryRaw) {
                    category = saved
                    group = NounBankGroup.containing(saved)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Momentum.surface)
    }

    private var tabStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    NounBankPill(
                        title: "Recents",
                        systemImage: "clock",
                        selected: showingRecents && !isSearching
                    ) {
                        selectRecents()
                    }
                    ForEach(NounBankGroup.allCases) { g in
                        NounBankPill(
                            title: g.rawValue,
                            selected: !showingRecents && !isSearching && g == group
                        ) {
                            selectGroup(g)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
            }

            if showsWordplayRows {
                wordplayTabRow
                if wordplayTab != nil {
                    wordplaySubTabRow
                }
            }
            if showsFOSRows {
                fosArtistRow
                fosFigureRow
            }
            if !showingRecents && !isSearching && group.categories.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack(spacing: 8) {
                            ForEach(group.categories) { cat in
                                NounBankPill(
                                    title: cat.rawValue,
                                    systemImage: cat.systemImage,
                                    selected: cat == category
                                ) {
                                    selectCategory(cat)
                                }
                                .id(cat)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        .onAppear {
                            proxy.scrollTo(category, anchor: .center)
                        }
                        .onChange(of: category) { _, new in
                            lastCategoryRaw = new.rawValue
                            withAnimation(.easeInOut(duration: 0.2)) {
                                proxy.scrollTo(new, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .chromeClamp()
    }

    private var showsFeelingNote: Bool {
        !isSearching && !showingRecents && group == .feelings && category == .feelings
    }

    private var feelingNote: some View {
        Text(NounBankFeelingsNote.text)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(Momentum.contentSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .accessibilityLabel(NounBankFeelingsNote.text)
    }

    private struct NounTabSection: Identifiable {
        let title: String
        let hits: [NounBankSearch.Hit]
        var id: String { title }
    }

    /// One tab, grouped so related chips share a row. Search and recents stay a flat list.
    private var tabSections: [NounTabSection] {
        let pairs = hits.map { (NounBankMark.normalize($0.item.insertWord), $0) }
        let lookup = Dictionary(pairs, uniquingKeysWith: { first, _ in first })
        return NounBankSections.sections(for: category).compactMap { section in
            let found = section.words.compactMap { lookup[NounBankMark.normalize($0)] }
            guard !found.isEmpty else { return nil }
            return NounTabSection(title: section.title, hits: found)
        }
    }

    private var chipGrid: some View {
        ScrollView {
            Group {
                if isSearching || showingRecents {
                    tileGrid(gridHits)
                } else {
                    sectionedGrid(tabSections)
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.horizontal, 12)
            .padding(.top, 2)
            .padding(.bottom, 20)
            .id(gridIdentity)
        }
        .scrollDismissesKeyboard(.interactively)
        .chromeClamp()
        .simultaneousGesture(categorySwipe)
        .task(id: gridIdentity) {
            await loadMentionCounts(for: gridHits)
        }
    }

    private func tileGrid(_ hits: [NounBankSearch.Hit]) -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(hits) { hit in
                nounTile(hit)
            }
        }
    }

    private func sectionedGrid(_ sections: [NounTabSection]) -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(sections) { section in
                if sections.count > 1 {
                    MomentumSectionHeader(title: section.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        .gridCellColumns(columns.count)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(section.title)
                        .accessibilityAddTraits(.isHeader)
                }
                ForEach(section.hits) { hit in
                    nounTile(hit)
                }
            }
        }
    }

    private func nounTile(_ hit: NounBankSearch.Hit) -> some View {
        NounBankTile(
            item: hit.item,
            category: hit.category,
            showCategoryCaption: (isSearching || showingRecents) && hit.category != category,
            mentionCount: mentionCounts[hit.id]
        ) {
            openLines(hit)
        }
    }

    private var gridIdentity: String {
        if isSearching { return "search:\(needle)" }
        if showingRecents { return "recents" }
        return category.rawValue
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Momentum.contentSecondary)
                .accessibilityHidden(true)
            Text(showingRecents && !isSearching ? "No recent nouns" : "No matching nouns")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(categorySwipe)
    }

    /// Horizontal drag on the grid. A clear sideways move steps the pill; a tap or a vertical scroll does not.
    private var categorySwipe: some Gesture {
        DragGesture(minimumDistance: 44, coordinateSpace: .local)
            .onEnded { value in
                let dx = value.translation.width
                let dy = value.translation.height
                guard abs(dx) > 64, abs(dx) > abs(dy) * 1.75 else { return }
                if group == .fos {
                    stepFOSArtist(by: dx < 0 ? 1 : -1)
                } else {
                    stepCategory(by: dx < 0 ? 1 : -1)
                }
            }
    }

    private func stepCategory(by step: Int) {
        guard !isSearching, !showingRecents else { return }
        guard let next = group.category(steppedBy: step, from: category) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            category = next
        }
        lastCategoryRaw = next.rawValue
    }

    private func stepFOSArtist(by step: Int) {
        guard step != 0, let index = FigurativeSpeech.artists.firstIndex(of: fosArtist) else { return }
        let next = index + step
        guard FigurativeSpeech.artists.indices.contains(next) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            fosArtist = FigurativeSpeech.artists[next]
        }
    }

    private func selectRecents() {
        query = ""
        showingRecents = true
        lastGroupRaw = ""
    }

    private func selectGroup(_ g: NounBankGroup) {
        query = ""
        showingRecents = false
        group = g
        lastGroupRaw = g.rawValue
        wordplayTab = nil
        wordplaySubTab = nil
        guard let first = g.categories.first else { return }
        if !g.categories.contains(category) {
            category = first
        }
        lastCategoryRaw = category.rawValue
    }

    private func selectCategory(_ cat: NounBankCategory) {
        showingRecents = false
        category = cat
        group = NounBankGroup.containing(cat)
        lastGroupRaw = group.rawValue
        lastCategoryRaw = cat.rawValue
    }

    private func selectWordplayTab(_ tab: WordplayTab?) {
        withAnimation(.easeInOut(duration: 0.18)) {
            wordplayTab = tab
            wordplaySubTab = nil
        }
    }

    private func selectWordplaySubTab(_ subTab: WordplaySubTab) {
        withAnimation(.easeInOut(duration: 0.18)) {
            wordplaySubTab = subTab
            wordplaySubTabScrollID = subTab
        }
    }

    private var fosArtistRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FigurativeSpeech.artists, id: \.self) { artist in
                    NounBankPill(title: artist, selected: artist == fosArtist) {
                        fosArtist = artist
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private var fosFigureRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FigurativeSpeech.typeOrder, id: \.self) { figure in
                    NounBankPill(title: figure, selected: fosFigure == figure) {
                        fosFigure = figure
                    }
                }
                NounBankPill(title: "All", selected: fosFigure == nil) {
                    fosFigure = nil
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private var fosList: some View {
        let rows = FigurativeSpeech.bars(artist: fosArtist, figure: fosFigure)
        return ScrollView {
            if rows.isEmpty {
                Text("No bars for this figure yet")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Momentum.contentSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .accessibilityLabel("No bars for this figure yet")
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(row.figure)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Momentum.contentSecondary)
                            Text(row.bar)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(Momentum.contentPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(row.song)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(Momentum.contentSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(row.figure). \(row.bar). \(row.artist). \(row.song)")
                    }
                }
            }
        }
        .simultaneousGesture(categorySwipe)
    }





    private func openLines(_ hit: NounBankSearch.Hit) {
        NounBankRecents.record(word: hit.item.insertWord, category: hit.category)
        linesHit = hit
    }

    private func insert(_ hit: NounBankSearch.Hit) {
        NounBankRecents.record(word: hit.item.insertWord, category: hit.category)
        onInsert(hit.item.insertWord)
    }

    private func loadMentionCounts(for hits: [NounBankSearch.Hit]) async {
        let jobs = hits.map { hit in
            (
                hit.id,
                NounBankCatalog.mentionPhrases(for: hit.item, category: hit.category),
                NounBankCatalog.mentionExclusions(for: hit.item, category: hit.category),
                NounBankCatalog.mentionPartners(for: hit.item)
            )
        }
        var loaded: [String: Int] = [:]
        for (id, phrases, excluding, also) in jobs {
            if Task.isCancelled { return }
            let count = await Task.detached(priority: .userInitiated) {
                NounMentionCounts.count(id: id, phrases: phrases, excluding: excluding, also: also)
            }.value
            loaded[id] = count
            if loaded.count % 6 == 0 {
                mentionCounts.merge(loaded) { _, new in new }
            }
        }
        if !Task.isCancelled {
            mentionCounts.merge(loaded) { _, new in new }
        }
    }
}

private struct NounBankPill: View {
    let title: String
    var systemImage: String? = nil
    let selected: Bool
    var flexible: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .padding(.horizontal, flexible ? 4 : 12)
            .padding(.vertical, 8)
            .frame(maxWidth: flexible ? .infinity : nil)
            .background(
                Capsule().fill(selected
                    ? Color(RhymeColorPalette.colors[1]).opacity(0.22)
                    : Color.primary.opacity(0.06))
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct NounBankTile: View {
    let item: NounBankItem
    let category: NounBankCategory
    var showCategoryCaption: Bool = false
    var mentionCount: Int? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                NounBankMarkView(word: item.insertWord, category: category, iconName: item.icon)
                    .overlay(alignment: .bottomTrailing) {
                        if let mentionCount {
                            let heat = NounMentionHeat.badgeColor(for: mentionCount)
                            Text(NounMentionHeat.label(for: mentionCount))
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(heat)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.black.opacity(0.94)))
                                .overlay(Capsule().strokeBorder(heat, lineWidth: 1))
                                .padding(3)
                        }
                    }
                Text(item.label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Momentum.contentPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, minHeight: 28, alignment: .top)
                if showCategoryCaption {
                    Text(category.rawValue)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Momentum.contentSecondary)
                        .lineLimit(1)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(NounTilePressStyle())
        .accessibilityLabel(accessibilityName)
        .accessibilityHint("Shows catalog lines that mention this")
    }

    private var accessibilityName: String {
        var name = item.insertWord
        if showCategoryCaption { name += ", \(category.rawValue)" }
        if let mentionCount {
            name += ", referenced \(mentionCount) times"
        }
        return name
    }
}

/// Techniques heat: a single mention stays cold blue, and larger catalog counts run toward red.
nonisolated enum NounMentionHeat {
    static func fraction(for count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        let t = log10(Double(count)) / 4
        return CGFloat(min(1, max(0, t)))
    }

    static func label(for count: Int) -> String {
        if count < 1_000 { return "\(count)" }
        if count >= 10_000 || count % 1_000 == 0 {
            return "\(count / 1_000)k"
        }
        return String(format: "%.1fk", Double(count) / 1_000)
    }

    /// Same blue → magenta → red hue as techniques, lifted so the digit reads on a black pill.
    static func badgeColor(for count: Int) -> Color {
        let hue = (0.667 + fraction(for: count) * 0.333).truncatingRemainder(dividingBy: 1)
        return Color(hue: hue, saturation: 0.78, brightness: 1)
    }
}

nonisolated enum NounMentionCounts {
    private static let lock = NSLock()
    private static var cache: [String: Int] = [:]

    static func count(id: String, phrases: [String], excluding: [String] = [], also: [String] = []) -> Int {
        lock.lock()
        if let cached = cache[id] {
            lock.unlock()
            return cached
        }
        lock.unlock()
        guard let store = BarHitsCatalogStore.shared else { return 0 }
        let tally = store.mentionCount(phrases: phrases, excluding: excluding, also: also)
        lock.lock()
        cache[id] = tally
        lock.unlock()
        return tally
    }
}

private struct NounMentionLinesView: View {
    private static let tightRow = EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16)
    private static let lyricRow = EdgeInsets(top: 1, leading: 16, bottom: 1, trailing: 16)

    let hit: NounBankSearch.Hit
    let count: Int?
    let onInsert: () -> Void
    @State private var rows: [BarHitsCatalogStore.Row] = []
    @State private var artists: [NounMentionOrder.Artist] = []
    @State private var missingCatalog = false
    @State private var loading = true
    @State private var passage = ""
    @State private var tally: NounMentionTally?
    @State private var artistID: String?
    @State private var showingArtists = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var phrases: [String] {
        NounBankCatalog.mentionPhrases(for: hit.item, category: hit.category)
    }

    private var extraNames: [String] {
        let chip = hit.item.insertWord.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        var seen = Set<String>()
        return phrases.filter { phrase in
            let folded = phrase.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            guard folded != chip else { return false }
            return seen.insert(folded).inserted
        }
    }

    var body: some View {
        List {
            Section {
                if !extraNames.isEmpty {
                    Text("Also matches \(extraNames.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .accessibilityLabel("Also matches \(extraNames.joined(separator: ", "))")
                }
                nounHeaderCard
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                Button {
                    showingArtists = true
                } label: {
                    Label(filterTitle, systemImage: "line.3.horizontal.decrease.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .disabled(artists.isEmpty)
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                .listRowBackground(Momentum.surfaceElevated)
                .accessibilityHint("Opens a list of artists so the lines can be limited to one")
                if hit.category == .feelings {
                    Text(NounBankFeelingsNote.page)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Momentum.contentSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .listRowBackground(Momentum.surfaceElevated)
                        .accessibilityLabel(NounBankFeelingsNote.page)
                }
            }
            if hit.category == .feelings {
                if loading || missingCatalog || rows.isEmpty {
                    statusSection
                } else {
                    feelingSplit(
                        title: "The feeling",
                        hint: feelingHint,
                        empty: "None of these lines use \(hit.item.insertWord) as the emotion.",
                        artists: splitArtists(.feeling)
                    )
                    feelingSplit(
                        title: "Literal",
                        hint: literalHint,
                        empty: "None of these lines use \(hit.item.insertWord) for something else.",
                        artists: splitArtists(.literal)
                    )
                }
            } else {
                statusSection
                if !loading && !missingCatalog {
                    artistSections(visibleArtists, indexed: true)
                }
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(4)
        .listRowSpacing(0)
        .environment(\.defaultMinListRowHeight, 1)
        .listSectionIndexVisibility(showsIndex ? .visible : .hidden)
        .navigationTitle(hit.item.insertWord)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Momentum.surface)
        .toolbarBackground(Momentum.surface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onInsert) {
                    Label("Insert", systemImage: "text.insert")
                }
                .accessibilityLabel("Insert \(hit.item.insertWord)")
            }
        }
        .sheet(isPresented: $showingArtists) {
            NounArtistFilterSheet(artists: artists, selection: $artistID)
        }
        .task(id: hit.id) {
            artistID = nil
            passage = ""
            tally = nil
            loading = true
            missingCatalog = false
            let phrases = NounBankCatalog.mentionPhrases(for: hit.item, category: hit.category)
            let excluding = NounBankCatalog.mentionExclusions(for: hit.item, category: hit.category)
            let also = NounBankCatalog.mentionPartners(for: hit.item)
            let word = hit.item.insertWord
            let category = hit.category
            let loaded = await Task.detached(priority: .userInitiated) {
                MentionLoad.fetch(
                    phrases: phrases,
                    excluding: excluding,
                    also: also,
                    keepingBareLines: category == .feelings
                )
            }.value
            switch loaded {
            case .missing:
                missingCatalog = true
                rows = []
                artists = []
                tally = nil
                passage = NounMentionBrief.standing(word: word, category: category)
                    + " The catalog isn’t in this install, so the lyric take can’t load."
            case .lines(let found, let stats):
                rows = found
                artists = NounMentionOrder.sections(found)
                tally = stats
                passage = NounMentionBrief.passage(
                    word: word,
                    category: category,
                    phrases: phrases,
                    lines: found.map(\.line)
                )
            }
            loading = false
        }
    }

    private var showsHeaderStats: Bool {
        tally != nil && !missingCatalog
    }

    private var headerStatsBesideLead: Bool {
        showsHeaderStats && !dynamicTypeSize.isAccessibilitySize
    }

    private var nounHeaderCard: some View {
        Group {
            if headerStatsBesideLead {
                HStack(alignment: .top, spacing: 12) {
                    nounHeaderLead
                        .frame(maxWidth: .infinity, alignment: .leading)
                    nounHeaderStats(trailing: true)
                        .frame(width: 90, alignment: .trailing)
                }
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(Momentum.hairline)
                        .frame(width: 1)
                        .padding(.vertical, 2)
                        .padding(.trailing, 96)
                        .accessibilityHidden(true)
                        .allowsHitTesting(false)
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    nounHeaderLead
                    if showsHeaderStats {
                        nounHeaderStats(trailing: false)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                .fill(Momentum.surfaceElevated)
        }
    }

    private var nounHeaderLead: some View {
        Group {
            if leadBullets.isEmpty && leadSignature == nil && athleteCard?.surname == nil {
                Text(passageText)
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(Momentum.contentPrimary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 7) {
                    if let surname = athleteCard?.surname {
                        Text(surname)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundStyle(Momentum.contentPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if let signature = leadSignature {
                        Text("\"\(signature.line)\" — \(signature.artist) | \(signature.song)")
                            .font(.system(.callout, design: .rounded))
                            .foregroundStyle(Momentum.contentPrimary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ForEach(Array(leadBullets.enumerated()), id: \.offset) { _, bullet in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("•")
                                .font(.system(.callout, design: .rounded))
                                .foregroundStyle(Momentum.contentPrimary)
                                .accessibilityHidden(true)
                            Text(bullet)
                                .font(.system(.callout, design: .rounded))
                                .foregroundStyle(Momentum.contentPrimary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(leadSpoken)
            }
        }
    }

    private func nounHeaderStats(trailing: Bool) -> some View {
        let alignment: HorizontalAlignment = trailing ? .trailing : .leading
        return VStack(alignment: alignment, spacing: 8) {
            nounHeaderStat(tally?.hits ?? 0, "hits", trailing: trailing)
            nounHeaderStat(tally?.artists ?? 0, "artists", trailing: trailing)
            nounHeaderStat(tally?.songs ?? 0, "songs", trailing: trailing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(headerStatsLabel)
    }

    private func nounHeaderStat(_ value: Int, _ name: String, trailing: Bool) -> some View {
        VStack(alignment: trailing ? .trailing : .leading, spacing: 2) {
            Text(value.formatted())
                .font(.headline.bold())
                .monospacedDigit()
                .foregroundStyle(Momentum.contentPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Text(name)
                .font(.caption2)
                .foregroundStyle(Momentum.contentSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: trailing ? .trailing : .leading)
    }

    private var headerStatsLabel: String {
        guard let tally else { return "" }
        return "\(tally.hits.formatted()) hits, \(tally.artists.formatted()) artists, \(tally.songs.formatted()) songs"
    }

    private var feelingHint: String {
        let count = splitArtists(.feeling).reduce(0) { sum, artist in
            sum + artist.songs.reduce(0) { $0 + $1.rows.count }
        }
        if count == 1 { return "1 line where \(hit.item.insertWord) is the emotion." }
        return "\(count.formatted()) lines where \(hit.item.insertWord) is the emotion."
    }

    private var literalHint: String {
        let count = splitArtists(.literal).reduce(0) { sum, artist in
            sum + artist.songs.reduce(0) { $0 + $1.rows.count }
        }
        if count == 1 { return "1 line where \(hit.item.insertWord) means something else." }
        return "\(count.formatted()) lines where \(hit.item.insertWord) means something else."
    }

    private func splitArtists(_ kind: NounFeelingSplit.Kind) -> [NounMentionOrder.Artist] {
        let pool = visibleArtists.flatMap { $0.songs.flatMap(\.rows) }
        let picked = pool.filter { NounFeelingSplit.kind(word: hit.item.insertWord, line: $0.line) == kind }
        let tag = kind == .feeling ? "feeling" : "literal"
        return NounMentionOrder.sections(picked).map { artist in
            NounMentionOrder.Artist(
                id: "\(tag)\u{1e}\(artist.id)",
                name: artist.name,
                songs: artist.songs.map { song in
                    NounMentionOrder.Song(
                        id: "\(tag)\u{1e}\(song.id)",
                        title: song.title,
                        rows: song.rows
                    )
                }
            )
        }
    }

    private var statusSection: some View {
        Section {
            Text(header)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Momentum.contentSecondary)
                .listRowBackground(Momentum.surfaceElevated)
            if loading {
                ProgressView("Looking through the catalog")
                    .listRowBackground(Momentum.surfaceElevated)
            } else if missingCatalog {
                Text("The catalog isn’t in this install, so these lines can’t load.")
                    .foregroundStyle(Momentum.contentSecondary)
                    .listRowBackground(Momentum.surfaceElevated)
            } else if rows.isEmpty {
                Text(emptyCopy)
                    .foregroundStyle(Momentum.contentSecondary)
                    .listRowBackground(Momentum.surfaceElevated)
            }
        }
    }

    private func feelingSplit(
        title: String,
        hint: String,
        empty: String,
        artists: [NounMentionOrder.Artist]
    ) -> some View {
        Group {
            Section {
                Text(hint)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Momentum.contentSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .listRowBackground(Momentum.surfaceElevated)
                    .accessibilityLabel("\(title). \(hint)")
                if artists.isEmpty {
                    Text(empty)
                        .foregroundStyle(Momentum.contentSecondary)
                        .listRowBackground(Momentum.surfaceElevated)
                }
            } header: {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Momentum.contentPrimary)
                    .textCase(nil)
            }
            artistSections(artists, indexed: false)
        }
    }

    private func artistSections(_ artists: [NounMentionOrder.Artist], indexed: Bool) -> some View {
        ForEach(artists) { artist in
            Section {
                ForEach(artist.songs) { song in
                    ForEach(Array(song.rows.enumerated()), id: \.element.id) { index, row in
                        VStack(alignment: .leading, spacing: 4) {
                            if index == 0, !song.title.isEmpty {
                                Text(song.title)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                            Text(NounMentionHighlight.mark(row.line, phrases: phrases))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .listRowInsets(NounMentionLinesView.lyricRow)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Momentum.surfaceElevated)
                    }
                }
            } header: {
                Text(artist.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Momentum.contentPrimary)
                    .textCase(nil)
                    .padding(.top, 6)
                    .padding(.bottom, 0)
            }
            .sectionIndexLabel(indexed ? indexLabel(for: artist) : nil)
        }
    }

    private var visibleArtists: [NounMentionOrder.Artist] {
        guard let artistID else { return artists }
        return artists.filter { $0.id == artistID }
    }

    private var filterTitle: String {
        if let artistID, let name = artists.first(where: { $0.id == artistID })?.name {
            return "Showing \(name)"
        }
        return "Filter by artist"
    }

    private var athleteCard: AthleteSheet.Card? {
        AthleteSheet.card(category: hit.category, word: hit.item.insertWord)
    }

    private var leadSignature: NounCharacteristics.Signature? {
        NounCharacteristics.signature(category: hit.category, word: hit.item.insertWord)
    }

    private var leadBullets: [String] {
        let stored = NounCharacteristics.bullets(category: hit.category, word: hit.item.insertWord)
        guard let card = athleteCard else { return stored }
        if card.surname == nil {
            if let line = card.line { return [line] }
            return stored
        }
        guard let line = card.line else { return stored }
        var bullets = stored.filter { !$0.lowercased().hasPrefix("tied to the ") }
        bullets.insert(line, at: 0)
        return bullets
    }

    private var leadSpoken: String {
        var parts: [String] = []
        if let surname = athleteCard?.surname {
            parts.append(surname)
        }
        if let signature = leadSignature {
            parts.append("\(signature.line). \(signature.artist), \(signature.song)")
        }
        parts.append(contentsOf: leadBullets)
        return parts.joined(separator: ", ")
    }

    private var passageText: String {
        if loading {
            return "Reading the catalog for a short take on \(hit.item.insertWord)."
        }
        return passage
    }

    private var showsIndex: Bool {
        guard hit.category != .feelings else { return false }
        var seen = Set<String>()
        for artist in visibleArtists {
            seen.insert(NounMentionOrder.indexLetter(forArtistKey: artist.id))
            if seen.count >= 2 { return true }
        }
        return false
    }

    private func indexLabel(for artist: NounMentionOrder.Artist) -> Text? {
        guard showsIndex, let letter = NounMentionOrder.leadingIndexLetter(for: artist.id, in: visibleArtists) else {
            return nil
        }
        return Text(letter)
    }

    private var header: String {
        if let artistID, let name = artists.first(where: { $0.id == artistID })?.name {
            let shown = visibleArtists.reduce(0) { sum, artist in
                sum + artist.songs.reduce(0) { $0 + $1.rows.count }
            }
            if shown == 1 { return "1 line from \(name)" }
            return "\(shown.formatted()) lines from \(name)"
        }
        guard let count else { return "Catalog lines, A to Z" }
        if !loading, count > 0, count <= NounMentionOrder.lineLimit, rows.count < count {
            if rows.isEmpty { return "0 lines with a setup" }
            if rows.count == 1 { return "1 line with a setup, A to Z" }
            return "\(rows.count.formatted()) lines with a setup, A to Z"
        }
        if count == 1 { return "1 catalog line" }
        if !rows.isEmpty, rows.count < count {
            return "\(rows.count.formatted()) of \(count.formatted()) lines, A to Z"
        }
        return "\(count.formatted()) catalog lines, A to Z"
    }

    private var emptyCopy: String {
        if let tally, tally.hits > 0 {
            return "Every loaded line was a name with no setup."
        }
        return "No catalog lines mention this yet."
    }
}

/// Popup list of the artists already on this noun, so the lines can be limited to one.
private struct NounArtistFilterSheet: View {
    let artists: [NounMentionOrder.Artist]
    @Binding var selection: String?
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var shown: [NounMentionOrder.Artist] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return artists }
        return artists.filter { $0.name.localizedStandardContains(needle) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        selection = nil
                        dismiss()
                    } label: {
                        HStack {
                            Text("All artists")
                            Spacer()
                            if selection == nil {
                                Image(systemName: "checkmark")
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .listRowBackground(Momentum.surfaceElevated)
                }
                Section {
                    if shown.isEmpty {
                        Text("No artist matches that.")
                            .foregroundStyle(Momentum.contentSecondary)
                            .listRowBackground(Momentum.surfaceElevated)
                    }
                    ForEach(shown) { artist in
                        Button {
                            selection = artist.id
                            dismiss()
                        } label: {
                            HStack {
                                Text(artist.name)
                                Spacer()
                                Text(lineCount(artist).formatted())
                                    .foregroundStyle(Momentum.contentSecondary)
                                    .monospacedDigit()
                                if selection == artist.id {
                                    Image(systemName: "checkmark")
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                        .listRowBackground(Momentum.surfaceElevated)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Momentum.surface)
            .navigationTitle("Artists")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search artists")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .toolbarBackground(Momentum.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Momentum.surface)
    }

    private func lineCount(_ artist: NounMentionOrder.Artist) -> Int {
        artist.songs.reduce(0) { $0 + $1.rows.count }
    }
}

/// Marks each catalog name inside a line so the noun is visible where it is used.
nonisolated enum NounMentionHighlight {
    static func mark(_ line: String, phrases: [String]) -> AttributedString {
        let source = line as NSString
        var hits: [NSRange] = []
        let ordered = phrases
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= 2 }
            .sorted { $0.count > $1.count }
        for phrase in ordered {
            var search = NSRange(location: 0, length: source.length)
            while search.length > 0 {
                let found = source.range(of: phrase, options: [.caseInsensitive, .diacriticInsensitive], range: search)
                if found.location == NSNotFound { break }
                if isBounded(source, found), hits.allSatisfy({ NSIntersectionRange($0, found).length == 0 }) {
                    hits.append(found)
                }
                let next = found.location + max(found.length, 1)
                if next >= source.length { break }
                search = NSRange(location: next, length: source.length - next)
            }
        }

        var marked = AttributedString(line)
        let wash = Color(uiColor: RhymeColorPalette.color(at: 3))
        for hit in hits {
            guard let stringRange = Range(hit, in: line),
                  let start = AttributedString.Index(stringRange.lowerBound, within: marked),
                  let end = AttributedString.Index(stringRange.upperBound, within: marked) else { continue }
            marked[start..<end].backgroundColor = wash.opacity(0.55)
            marked[start..<end].foregroundColor = .primary
            marked[start..<end].font = .system(size: 15, weight: .semibold, design: .rounded)
        }
        return marked
    }

    private static func isBounded(_ line: NSString, _ range: NSRange) -> Bool {
        if range.location > 0, isWordChar(line.character(at: range.location - 1)) { return false }
        let end = range.location + range.length
        if end < line.length, isWordChar(line.character(at: end)) { return false }
        return true
    }

    private static func isWordChar(_ value: unichar) -> Bool {
        guard let scalar = UnicodeScalar(value) else { return false }
        return CharacterSet.alphanumerics.contains(scalar)
    }
}

/// Artist A to Z, then the album or song A to Z, then the line.
nonisolated enum NounMentionOrder {
    static let lineLimit = 1_500

    struct Song: Identifiable {
        let id: String
        let title: String
        let rows: [BarHitsCatalogStore.Row]
    }

    struct Artist: Identifiable {
        let id: String
        let name: String
        let songs: [Song]
    }

    static func sections(_ rows: [BarHitsCatalogStore.Row]) -> [Artist] {
        var artists: [Artist] = []
        var songs: [Song] = []
        var songRows: [BarHitsCatalogStore.Row] = []
        var artistKey = ""
        var artistName = ""
        var songKey = ""
        var songTitle = ""
        var open = false

        func flushSong() {
            guard !songRows.isEmpty else { return }
            songs.append(Song(id: "\(artistKey)\u{1e}\(songKey)", title: songTitle, rows: songRows))
            songRows = []
        }
        func flushArtist() {
            flushSong()
            guard !songs.isEmpty else { return }
            artists.append(Artist(id: artistKey, name: artistName, songs: songs))
            songs = []
        }

        for row in sorted(rows) {
            let nextArtist = key(row.artist)
            let nextSong = key(row.song)
            if !open {
                open = true
                artistKey = nextArtist
                artistName = display(row.artist, empty: "Unknown artist")
                songKey = nextSong
                songTitle = display(row.song, empty: "")
            } else if nextArtist != artistKey {
                flushArtist()
                artistKey = nextArtist
                artistName = display(row.artist, empty: "Unknown artist")
                songKey = nextSong
                songTitle = display(row.song, empty: "")
            } else if nextSong != songKey {
                flushSong()
                songKey = nextSong
                songTitle = display(row.song, empty: "")
            }
            songRows.append(row)
        }
        if open { flushArtist() }
        return artists
    }

    static func sorted(_ rows: [BarHitsCatalogStore.Row]) -> [BarHitsCatalogStore.Row] {
        rows.sorted { a, b in
            let artist = key(a.artist).localizedStandardCompare(key(b.artist))
            if artist != .orderedSame { return artist == .orderedAscending }
            let song = key(a.song).localizedStandardCompare(key(b.song))
            if song != .orderedSame { return song == .orderedAscending }
            return a.line.localizedStandardCompare(b.line) == .orderedAscending
        }
    }

    private static func display(_ raw: String?, empty: String) -> String {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? empty : trimmed
    }

    /// Letters and digits only, so "The Game" sits with G and "A$AP" sits with ASAP.
    private static func key(_ raw: String?) -> String {
        let trimmed = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "\u{10FFFF}" }
        var text = trimmed.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US"))
        if text.hasPrefix("the ") { text.removeFirst(4) }
        let kept = text.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) || $0 == " " }
        let collapsed = String(String.UnicodeScalarView(kept)).trimmingCharacters(in: .whitespaces)
        return collapsed.isEmpty ? "\u{10FFFF}" : collapsed
    }

    /// "#" covers artists filed under a number. Everyone else uses their first letter.
    static func indexLetter(forArtistKey key: String) -> String {
        guard let scalar = key.unicodeScalars.first, scalar.value < 0x10FFFF else { return "#" }
        if CharacterSet.decimalDigits.contains(scalar) { return "#" }
        let letter = String(scalar).uppercased()
        guard letter.count == 1, let character = letter.first, character.isLetter else { return "#" }
        return letter
    }

    /// The rail shows one mark per letter, on the first artist filed under it.
    static func leadingIndexLetter(for artistID: String, in artists: [Artist]) -> String? {
        guard let index = artists.firstIndex(where: { $0.id == artistID }) else { return nil }
        let letter = indexLetter(forArtistKey: artistID)
        if index == 0 { return letter }
        let previous = indexLetter(forArtistKey: artists[index - 1].id)
        return letter == previous ? nil : letter
    }
}

nonisolated struct NounMentionTally: Equatable, Sendable {
    var hits: Int
    var artists: Int
    var songs: Int

    var label: String {
        if hits == 0 {
            return "0 in catalog"
        }
        return "\(hits) hits · \(artists) artists · \(songs) songs"
    }
}

nonisolated private enum MentionLoad {
    case missing
    case lines([BarHitsCatalogStore.Row], NounMentionTally)

    static func fetch(
        phrases: [String],
        excluding: [String] = [],
        also: [String] = [],
        keepingBareLines: Bool = false
    ) -> MentionLoad {
        guard let store = BarHitsCatalogStore.shared else { return .missing }
        let stats = store.mentionStats(phrases: phrases, excluding: excluding, also: also)
        let tally = NounMentionTally(hits: stats.hits, artists: stats.artists, songs: stats.songs)
        let found = store.mentionLines(phrases: phrases, excluding: excluding, also: also, limit: NounMentionOrder.lineLimit)
        let kept = keepingBareLines ? found : found.filter { NounMentionWorth.keeps($0.line, phrases: phrases + also) }
        return .lines(kept, tally)
    }
}

private struct NounTilePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    NounBankSheet { _ in }
}
