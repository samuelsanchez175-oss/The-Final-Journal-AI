import SwiftUI

enum NounBankGroup: String, CaseIterable, Identifiable {
    case liquids = "Liquids"
    case food = "Food"
    case ice = "Ice"
    case wear = "Wear"
    case street = "Street"
    case vehicles = "Vehicles"
    case people = "People"
    case athletes = "Athletes"
    case animals = "Animals"
    case games = "Games"
    case apps = "Apps"
    case looks = "Looks"
    case flowers = "Flowers"
    case feelings = "Feelings"
    case phrases = "Phrases"
    case wordplay = "Play on Words"

    var id: String { rawValue }

    var categories: [NounBankCategory] {
        switch self {
        case .liquids: return [.liquors, .syrups, .drugs, .substances]
        case .food: return [.food]
        case .ice: return [.jewelry, .grills, .jewelers, .money]
        case .wear: return [.brands, .clothing, .hair, .nails, .tattoos, .lingerie, .toys]
        case .street: return [.guns, .kill, .opps, .places, .woman, .twerk, .streets, .kingpin, .trapLife, .paranoia]
        case .vehicles: return [.cars, .motorcycles, .boats, .aviation, .military]
        case .people: return [.family, .friends, .producers, .artists, .celebs, .events, .characters, .actors, .streamers, .religion]
        case .athletes: return [.nba, .nfl, .boxing, .sports, .wrestlers]
        case .animals: return [.animals, .insects]
        case .games: return [.games]
        case .apps: return [.apps]
        case .looks: return [.looks]
        case .flowers: return [.flowers]
        case .feelings: return [.feelings]
        case .phrases: return [.phrases]
        case .wordplay: return [.wordplay]
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
    @State private var group: NounBankGroup = .liquids
    @State private var category: NounBankCategory = .liquors
    @State private var showingRecents = false
    @State private var query = ""
    @State private var linesHit: NounBankSearch.Hit?
    @State private var mentionCounts: [String: Int] = [:]

    private var needle: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool { !needle.isEmpty }

    private var hits: [NounBankSearch.Hit] {
        NounBankSearch.hits(query: query, selected: category)
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabStrip
                if showsFeelingNote {
                    feelingNote
                }

                if gridHits.isEmpty {
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
                if let saved = NounBankCategory(rawValue: lastCategoryRaw) {
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
        !isSearching && !showingRecents && category == .feelings
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
                stepCategory(by: dx < 0 ? 1 : -1)
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

    private func selectRecents() {
        query = ""
        showingRecents = true
    }

    private func selectGroup(_ g: NounBankGroup) {
        query = ""
        showingRecents = false
        group = g
        if !g.categories.contains(category) {
            category = g.categories[0]
        }
        lastCategoryRaw = category.rawValue
    }

    private func selectCategory(_ cat: NounBankCategory) {
        showingRecents = false
        category = cat
        group = NounBankGroup.containing(cat)
        lastCategoryRaw = cat.rawValue
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
                Text(passageText)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Momentum.contentPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .listRowInsets(NounMentionLinesView.tightRow)
                    .listRowBackground(Momentum.surfaceElevated)
                if let tally, !missingCatalog {
                    Text(tally.label)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Momentum.contentSecondary)
                        .listRowInsets(NounMentionLinesView.tightRow)
                        .listRowBackground(Momentum.surfaceElevated)
                        .accessibilityLabel(tally.label)
                }
                Button {
                    showingArtists = true
                } label: {
                    Label(filterTitle, systemImage: "line.3.horizontal.decrease.circle")
                }
                .disabled(artists.isEmpty)
                .listRowInsets(NounMentionLinesView.tightRow)
                .listRowBackground(Momentum.surfaceElevated)
                .accessibilityHint("Opens a list of artists so the lines can be limited to one")
                if !extraNames.isEmpty {
                    Text("Also matches \(extraNames.joined(separator: ", "))")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(Momentum.contentSecondary)
                        .listRowInsets(NounMentionLinesView.tightRow)
                        .listRowBackground(Momentum.surfaceElevated)
                }
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
