import SwiftUI
import UIKit

struct RemindsMeOfListView: View {
    @ObservedObject var service: RemindsMeOfService
    @ObservedObject private var catalogMIR = CatalogMIRBatchService.shared
    let text: String
    let bpm: Int?
    let syllableMin: Int?
    let syllableMax: Int?
    var onGeniusKeySaved: (() -> Void)? = nil
    var onSearchGenius: (() -> Void)? = nil
    var onClose: (() -> Void)? = nil

    @State private var isSortReversed = false
    @State private var sourceFilter: RemindsMeOfSourceFilter = .wrap
    @State private var heldIconName: String?
    @State private var holdTipTask: Task<Void, Never>?
    @State private var hideGeniusSetup = false
    @State private var showReplaceBars = false
    @State private var showCatalogPicker = false
    @State private var catalogDraft: Set<String> = []
    @State private var catalogArtists: [String] = []

    private enum RemindsMeOfSourceFilter: String, CaseIterable {
        case wrap, nearby, catalog, genius
        var icon: String {
            switch self {
            case .wrap: return "square.grid.2x2"
            case .nearby: return "metronome"
            case .catalog: return "doc.text"
            case .genius: return "quote.bubble"
            }
        }
        var label: String {
            switch self {
            case .wrap: return "Wrap"
            case .nearby: return "Nearby"
            case .catalog: return "Catalog"
            case .genius: return "Genius"
            }
        }
        var tabLabel: String { label }
        var holdHint: String {
            switch self {
            case .wrap: return "Next-line suggestions first. Nearby wrap is similar count plus rhyme and slant. Same-idea pictures after that."
            case .nearby: return "Neighbor syllable counts only"
            case .catalog: return "Pick artist names, then search the on-device catalog"
            case .genius: return "Search this bar on Genius"
            }
        }
    }

    private var captionCopy: String {
        if let held = service.heldLineResult {
            return held.line
        }
        return sourceFilter.holdHint
    }

    private var orderedGroups: [RemindsMeOfGroup] {
        if let held = service.heldLineResult {
            let groups = filterHeldGroups(held.groups())
            return isSortReversed ? Array(groups.reversed()) : groups
        }
        if sourceFilter == .genius, !service.matches.isEmpty {
            let groups = geniusMatchGroups
            return isSortReversed ? Array(groups.reversed()) : groups
        }
        let filtered = service.groups.compactMap { group -> RemindsMeOfGroup? in
            let hits = group.hits.filter { hit in
                switch sourceFilter {
                case .wrap, .nearby, .catalog:
                    return hit.source == .csv || hit.source == .both
                case .genius:
                    return hit.source == .genius || hit.source == .both
                }
            }
            guard !hits.isEmpty else { return nil }
            return RemindsMeOfGroup(id: group.id, title: group.title, colorIndex: group.colorIndex, hits: hits)
        }
        return isSortReversed ? Array(filtered.reversed()) : filtered
    }

    private func filterHeldGroups(_ groups: [RemindsMeOfGroup]) -> [RemindsMeOfGroup] {
        groups.compactMap { group in
            switch sourceFilter {
            case .wrap:
                return group.showsAsTracks ? nil : group
            case .nearby:
                guard group.id.hasPrefix("held-wrap-") else { return nil }
                if let held = service.heldLineResult, group.id == "held-wrap-\(held.syllables)" {
                    return nil
                }
                return group
            case .catalog:
                return group.showsAsTracks ? nil : group
            case .genius:
                return group.showsAsTracks ? group : nil
            }
        }
    }

    private var geniusMatchGroups: [RemindsMeOfGroup] {
        service.matches.map { match in
            let hits = match.hits.map { song in
                RemindsMeOfHit(
                    id: "\(match.index)-\(song.id)",
                    line: song.title,
                    artist: song.artist,
                    song: song.title,
                    source: .genius,
                    url: song.url,
                    syllableCount: 0,
                    score: 0
                )
            }
            return RemindsMeOfGroup(
                id: "line-\(match.index)",
                title: "Genius",
                colorIndex: 0,
                hits: hits,
                showsAsTracks: true
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerBar
            if let held = service.heldLineResult {
                Text(held.line)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 2)
                    .accessibilityLabel("Bar you held")
                    .accessibilityValue(held.line)
                replaceBarButton(held: held)
                if !service.selectedCatalogArtists.isEmpty {
                    let names = service.selectedCatalogArtists.sorted()
                    Text(names.count == 1 ? "Catalog: \(names[0])" : "Catalog: \(names.count) artists")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Momentum.contentSecondary)
                        .padding(.horizontal, 20)
                        .accessibilityLabel("Catalog filter")
                        .accessibilityValue(names.joined(separator: ", "))
                }
                if let tip = heldIconName {
                    Text(tip)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(geniusYellow)
                        .padding(.horizontal, 20)
                }
            } else {
                Text(heldIconName ?? captionCopy)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(heldIconName == nil ? Momentum.contentSecondary : geniusYellow)
                    .padding(.horizontal, 20)
            }

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if orderedGroups.isEmpty && (service.isScanning || service.isFilling) {
                            HStack {
                                ProgressView()
                                Text(service.isFilling ? service.fillingCopy : "Finding the same wrap…")
                                    .font(.callout)
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                        } else if service.isLoading && service.groups.isEmpty && orderedGroups.isEmpty {
                            HStack {
                                ProgressView()
                                Text("Scoring similar pockets…")
                                    .font(.callout)
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                        } else if orderedGroups.isEmpty {
                            Text(emptyCopy)
                                .font(.callout)
                                .foregroundStyle(Momentum.contentSecondary)
                        } else {
                            VStack(alignment: .leading, spacing: 14) {
                                ForEach(Array(orderedGroups.enumerated()), id: \.element.id) { index, group in
                                    groupRow(index: index, group: group)
                                    if index < orderedGroups.count - 1 {
                                        Divider().opacity(0.25)
                                    }
                                }
                                if service.isFilling {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                        Text(service.fillingCopy)
                                            .font(.callout)
                                            .foregroundStyle(Momentum.contentSecondary)
                                    }
                                    .accessibilityLabel(service.fillingCopy)
                                }
                            }
                        }

                        if let issue = service.searchIssue {
                            RemindsMeOfErrorCard(
                                issue: issue,
                                onRetry: retryWebSearch,
                                onTokenSaved: {
                                    service.clearSearchIssue()
                                    retryWebSearch()
                                }
                            )
                            .id("genius-setup")
                        } else if service.missingGeniusKey, !hideGeniusSetup, orderedGroups.isEmpty {
                            RemindsMeOfErrorCard(
                                issue: .tokenBlocked,
                                onRetry: retryWebSearch,
                                onTokenSaved: {
                                    service.clearSearchIssue()
                                    retryWebSearch()
                                }
                            )
                            .id("genius-setup")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollBounceBehavior(.basedOnSize)
                .simultaneousGesture(loadingSwipeAway)
                .onChange(of: sourceFilter) { _, filter in
                    if filter == .genius, service.missingGeniusKey {
                        hideGeniusSetup = false
                        withAnimation {
                            proxy.scrollTo("genius-setup", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(Momentum.surfaceElevated)
        .onAppear {
            if service.preferGeniusTab {
                sourceFilter = .genius
            } else {
                sourceFilter = .wrap
            }
        }
        .onChange(of: service.preferGeniusTab) { _, on in
            if on { sourceFilter = .genius }
        }
        .onChange(of: service.heldLineResult?.line) { _, _ in
            showReplaceBars = false
        }
        .task(id: text) {
            if service.heldLineResult != nil { return }
            await service.refresh(text: text, bpm: bpm, syllableMin: syllableMin, syllableMax: syllableMax)
        }
        .sheet(isPresented: $showCatalogPicker) {
            CatalogArtistPicker(
                artists: CatalogArtistSort.displayOrdered(catalogArtists),
                draft: $catalogDraft,
                onCancel: { showCatalogPicker = false },
                onDone: applyCatalogSelection
            )
        }
    }

    /// Downward drag while the list is still empty closes Bar Hits immediately.
    private var loadingSwipeAway: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let loading = orderedGroups.isEmpty && (service.isScanning || service.isFilling)
                guard loading else { return }
                guard value.translation.height > 70,
                      abs(value.translation.height) > abs(value.translation.width) else { return }
                onClose?()
            }
    }

    private var headerBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Button {
                    isSortReversed.toggle()
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(RemindsMeOfCopy.title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(RemindsMeOfCopy.accessibility)
                .simultaneousGesture(longPressTip("Sort"))

                Spacer(minLength: 8)

                Button("Cancel") {
                    onClose?()
                }
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .accessibilityLabel("Cancel")
                .accessibilityHint("Closes Bar Hits. The highlight on your bar goes away, and a search still running is stopped.")
            }

            if let store = BarHitsCatalogStore.shared {
                Text(store.summaryLine)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Momentum.contentSecondary)
                    .accessibilityLabel("On-device catalog: \(store.summaryLine)")
            } else {
                Text("Catalog missing from this install — rebuild onto the phone")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 6) {
                ForEach(RemindsMeOfSourceFilter.allCases, id: \.self) { filter in
                    Button {
                        handleHeaderTap(filter)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: filter.icon)
                                .font(.system(size: 16, weight: .semibold))
                            Text(filter.label)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(headerTint(for: filter))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(filter.label)
                    .accessibilityHint(filter.holdHint)
                    .help(filter.holdHint)
                    .simultaneousGesture(longPressTip(filter.holdHint))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func replaceBarButton(held: RemindsMeOfHeldLineResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showReplaceBars.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Replace this bar")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Spacer(minLength: 8)
                    Image(systemName: showReplaceBars ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Momentum.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Replace this bar")
            .accessibilityHint("Shows catalog bars that can swap for this line. Collapsed until you tap. Next-line suggestions stay on screen.")
            .accessibilityAddTraits(showReplaceBars ? .isSelected : [])

            if showReplaceBars {
                let hits = held.replaceHits()
                if hits.isEmpty {
                    Text("No swap for this start yet. Next-line suggestions are still below.")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Momentum.contentSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    groupRow(
                        index: 0,
                        group: RemindsMeOfGroup(
                            id: "held-replace-\(held.syllables)",
                            title: "Replace this bar · \(held.syllables)-count",
                            colorIndex: 0,
                            hits: hits
                        )
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private func handleHeaderTap(_ filter: RemindsMeOfSourceFilter) {
        if filter == .catalog {
            catalogArtists = CatalogArtistSort.displayOrdered(
                BarHitsCatalogStore.shared?.artistNames() ?? []
            )
            catalogDraft = service.selectedCatalogArtists
            showCatalogPicker = true
            return
        }
        sourceFilter = filter
        if filter == .genius {
            Task { await runGeniusTab() }
        }
    }

    private func applyCatalogSelection() {
        service.selectedCatalogArtists = catalogDraft
        showCatalogPicker = false
        sourceFilter = .wrap
        guard let held = service.heldLineResult else { return }
        service.startHeldLookup(line: held.line, syllables: held.syllables)
    }

    private func longPressTip(_ name: String) -> some Gesture {
        LongPressGesture(minimumDuration: 0.35)
            .onEnded { _ in
                heldIconName = name
                holdTipTask?.cancel()
                holdTipTask = Task {
                    try? await Task.sleep(nanoseconds: 1_600_000_000)
                    if !Task.isCancelled {
                        await MainActor.run { heldIconName = nil }
                    }
                }
            }
    }

    /// Amber/yellow — same family as the hold-syllable pulse, used for the Genius tab.
    private var geniusYellow: Color { Color(RhymeColorPalette.colors[0]) }

    private func headerTint(for filter: RemindsMeOfSourceFilter) -> Color {
        let selected: Bool
        switch filter {
        case .catalog:
            selected = showCatalogPicker || !service.selectedCatalogArtists.isEmpty
        case .genius:
            selected = sourceFilter == .genius
        case .wrap, .nearby:
            selected = sourceFilter == filter
        }
        if filter == .genius {
            return selected ? geniusYellow : Color.secondary
        }
        return selected ? Color(RhymeColorPalette.colors[1]) : Color.secondary
    }

    private func runGeniusTab() async {
        if service.heldLineResult != nil {
            await service.searchGeniusForHeldLine()
            return
        }
        onSearchGenius?()
        await service.scanVerse(text: text, force: true)
    }

    private func retryWebSearch() {
        Task {
            if service.heldLineResult != nil {
                await service.searchGeniusForHeldLine()
                return
            }
            await service.refresh(
                text: text,
                bpm: bpm,
                syllableMin: syllableMin,
                syllableMax: syllableMax,
                force: true
            )
            await service.scanVerse(text: text, force: true)
        }
    }

    private var emptyCopy: String {
        if sourceFilter != .genius, BarHitsCatalogStore.shared == nil {
            let detail = BarHitsCatalogStore.lastLoadError.map { " (\($0))" } ?? ""
            return "The scraped catalog isn't in this install, so wrap hits can't load.\(detail) Rebuild the app so BarHitsCatalog.sqlite.gz is copied into the bundle."
        }
        if RemindsMeOfScorer.queryLines(from: text).isEmpty, service.heldLineResult == nil {
            return "Write a few bars, then this finds similar wraps."
        }
        switch sourceFilter {
        case .wrap:
            return "No wrap pockets yet. Keep writing."
        case .nearby:
            return "No nearby syllable counts for this bar yet."
        case .catalog:
            return "No catalog bars for those artists yet."
        case .genius:
            return "No Genius songs for this bar yet. Tap Genius to search."
        }
    }

    /// Section labels: darker burnt orange, smaller than the held-bar title.
    private var sectionTitleColor: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.90, green: 0.50, blue: 0.20, alpha: 1)
                : UIColor(red: 0.58, green: 0.26, blue: 0.07, alpha: 1)
        })
    }

    @ViewBuilder
    private func groupRow(index: Int, group: RemindsMeOfGroup) -> some View {
        let groupColor = sourceFilter == .genius
            ? geniusYellow
            : Color(RhymeColorPalette.colors[group.colorIndex % RhymeColorPalette.colors.count])
        VStack(alignment: .leading, spacing: 8) {
            Text(group.title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(sectionTitleColor)
                .padding(.top, index == 0 ? 2 : 6)

            if group.id.hasPrefix("held-meaning"), let held = service.heldLineResult, !held.meaningCards.isEmpty {
                let label = group.title.replacingOccurrences(of: "Imagery · ", with: "")
                let cards = held.meaningCards.filter {
                    let key = $0.neighborhood.metaphorLabel.isEmpty ? "same idea" : $0.neighborhood.metaphorLabel
                    return group.id == "held-meaning" || key == label
                }
                ForEach(cards.prefix(8)) { card in
                    SimilarMeaningCard(card: card)
                }
            }
            if !(group.id.hasPrefix("held-meaning") && (service.heldLineResult?.meaningCards.isEmpty == false)) {
            ForEach(group.hits.prefix(8)) { hit in
                VStack(alignment: .leading, spacing: 2) {
                    let showLyric = !group.showsAsTracks
                        || (hit.line != (hit.song ?? "") && RemindsMeOfScorer.isSearchableLine(hit.line))
                    Text(showLyric ? hit.line : (hit.song ?? hit.line))
                        .font(.callout)
                        .foregroundStyle(groupColor.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        Text(group.showsAsTracks ? "Genius" : hit.source.label)
                            .font(.caption2.weight(.semibold))
                        if let picture = hit.metaphor, !picture.isEmpty {
                            Text(picture)
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(groupColor.opacity(0.18)))
                        }
                        if group.showsAsTracks {
                            if let artist = hit.artist, !artist.isEmpty {
                                Text(artist)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            if showLyric, let song = hit.song, !song.isEmpty, song != hit.line {
                                Text(song)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                        } else if !hit.subtitle.isEmpty {
                            Text(hit.subtitle)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        if let song = hit.song,
                           let mir = catalogMIR.mir(song: song, artist: hit.artist) {
                            // Display-only. Wrap/meaning ranking does not use BPM/key/scale.
                            let bits = [mir.bpm.map { "\($0) BPM" }, mir.key, mir.scale].compactMap { $0 }
                                + mir.styleTags
                            if !bits.isEmpty {
                                Text(bits.joined(separator: " · "))
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        if !group.showsAsTracks {
                            Text("\(Int(hit.score * 100))")
                                .font(.caption2.monospacedDigit())
                        }
                    }
                    .foregroundStyle(groupColor.opacity(0.65))
                }
                .onTapGesture {
                    if let url = hit.url {
                        UIApplication.shared.open(url)
                    } else {
                        UIPasteboard.general.string = hit.line
                    }
                    onClose?()
                }
            }
            }
        }
    }
}

/// Display-only A–Z for catalog artist sheets. Store/ingest order stays popularity-based.
enum CatalogArtistSort {
    static func displayOrdered(_ names: [String]) -> [String] {
        names.sorted {
            sortKey($0).localizedStandardCompare(sortKey($1)) == .orderedAscending
        }
    }

    static func sortKey(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        for prefix in ["the ", "a ", "an "] {
            if lower.hasPrefix(prefix) {
                return String(lower.dropFirst(prefix.count))
            }
        }
        return lower
    }
}

/// Multi-select names from the on-device Genius catalog vault.
private struct CatalogArtistPicker: View {
    let artists: [String]
    @Binding var draft: Set<String>
    let onCancel: () -> Void
    let onDone: () -> Void
    @State private var query = ""

    /// Sort after filter/search. Leading The/A/An is ignored for the key only.
    private var filtered: [String] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let base: [String]
        if needle.isEmpty {
            base = artists
        } else {
            base = artists.filter { $0.localizedCaseInsensitiveContains(needle) }
        }
        return CatalogArtistSort.displayOrdered(base)
    }

    var body: some View {
        NavigationStack {
            List {
                if artists.isEmpty {
                    Text("The scraped catalog isn't in this install. Rebuild so BarHitsCatalog.sqlite.gz is copied into the app, then reopen Catalog.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Momentum.contentSecondary)
                } else {
                    Section {
                        Button {
                            draft.removeAll()
                        } label: {
                            Text(draft.isEmpty ? "All artists" : "Clear selection — All artists")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                    }
                    Section {
                        ForEach(filtered, id: \.self) { name in
                            Button {
                                if draft.contains(name) {
                                    draft.remove(name)
                                } else {
                                    draft.insert(name)
                                }
                            } label: {
                                HStack {
                                    Text(name)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if draft.contains(name) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color(RhymeColorPalette.colors[1]))
                                    }
                                }
                            }
                            .accessibilityLabel(name)
                            .accessibilityHint(draft.contains(name) ? "Selected. Tap to remove." : "Tap to include in the catalog search.")
                            .accessibilityAddTraits(draft.contains(name) ? .isSelected : [])
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "Artist name")
            .navigationTitle("Catalog artists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                        .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}


/// Similar-meaning card: anchor bold, priors dimmed, Signal axes on the face.
struct SimilarMeaningCard: View {
    let card: SimilarMeaningPipeline.ScoredCard

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !card.neighborhood.metaphorLabel.isEmpty {
                Text(card.neighborhood.metaphorLabel.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(Color(RhymeColorPalette.colors[2]))
                    .accessibilityLabel("Imagery: \(card.neighborhood.metaphorLabel)")
            }
            if let artist = card.neighborhood.artist, !artist.isEmpty {
                Text([artist, card.neighborhood.song].filter { !$0.isEmpty }.joined(separator: " · "))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Momentum.contentSecondary)
            }
            ForEach(Array(card.neighborhood.priorLines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Momentum.contentSecondary.opacity(0.85))
            }
            Text(card.neighborhood.anchor)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text(card.neighborhood.reason)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(RhymeColorPalette.colors[2]))
            Text(card.neighborhood.axesSummary)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Momentum.contentSecondary)
                .accessibilityLabel("Signal axes: \(card.neighborhood.axesSummary)")
        }
        .padding(.vertical, 4)
    }
}
