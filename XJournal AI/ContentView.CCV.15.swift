//
// ContentView.CCV.15.swift
//
// This file contains RhymeGroupListView.
//
// Dependencies:
// - ContentView.CCV.2.swift (for GlassSettings, lightHaptic)
// - ContentView.CCV.3.swift (for RhymeHighlighterEngine)
//
import SwiftUI
import UIKit
import Combine

struct RhymeGroupListView: View {
    let groups: [RhymeHighlighterEngine.RhymeGroup]
    let currentText: String
    /// Same insert-at-caret path NounBankSheet uses (`insertNounBankWord`).
    var onInsert: (String) -> Void = { _ in }
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("rhymeLightbulbSource") private var rhymeLightbulbSource = "Dictionary"
    @State private var isSortReversed = false
    @State private var showSuggestions = false
    @State private var showSourcePicker = false
    @State private var artistQuery = ""
    @State private var artistNames: [String] = []
    @State private var chipsByGroup: [UUID: [RhymeLightbulbSearch.Chip]] = [:]
    @State private var sourceLabel = "Dictionary"
    
    // Device-aware sizing - uses modern API to get screen bounds
    private var popoverWidth: CGFloat {
        let screenWidth = getScreenWidth()
        // iPhone sizing: use 85% of screen width, max 400pt
        // iPad sizing: use fixed width
        if horizontalSizeClass == .compact {
            // iPhone
            return min(screenWidth * 0.85, 400)
        } else {
            // iPad
            return 520
        }
    }
    
    private var popoverMaxHeight: CGFloat {
        let screenHeight = getScreenHeight()
        // Use 60% of screen height, max 500pt
        return min(screenHeight * 0.6, 500)
    }
    
    // Helper to get screen width using modern API
    private func getScreenWidth() -> CGFloat {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.bounds.width ?? (horizontalSizeClass == .compact ? 390 : 768)
    }
    
    // Helper to get screen height using modern API
    private func getScreenHeight() -> CGFloat {
        // Try modern API first (iOS 13+)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let height = window?.bounds.height ?? (horizontalSizeClass == .compact ? 844 : 1024)
        return height
    }

    // Computed property to avoid complex expression in body
    private var orderedGroups: [RhymeHighlighterEngine.RhymeGroup] {
        func firstWordStart(_ group: RhymeHighlighterEngine.RhymeGroup) -> String.Index? {
            group.words.map({ $0.range.lowerBound }).min()
        }
        func typeRank(_ type: RhymeHighlighterEngine.RhymeType) -> Int {
            type == .internalRhyme ? 1 : 0
        }
        let baseOrdered = groups.sorted { g1, g2 in
            let rank1 = typeRank(g1.rhymeType)
            let rank2 = typeRank(g2.rhymeType)
            if rank1 != rank2 { return rank1 < rank2 }
            guard
                let r1 = firstWordStart(g1),
                let r2 = firstWordStart(g2)
            else { return false }
            return r1 < r2
        }
        return isSortReversed ? Array(baseOrdered.reversed()) : baseOrdered
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button {
                    isSortReversed.toggle()
                } label: {
                    HStack {
                        Text("Rhyme Groups")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()

                Button {
                    showSourcePicker.toggle()
                } label: {
                    Text(sourceLabel)
                        .font(.caption2)
                        .foregroundStyle(Momentum.contentSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Rhyme source \(sourceLabel)")

                Button {
                    showSuggestions.toggle()
                } label: {
                    Image(systemName: showSuggestions ? "lightbulb.fill" : "lightbulb")
                        .font(.headline)
                        .foregroundStyle(showSuggestions ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showSuggestions ? "Hide rhyme suggestions" : "Show rhyme suggestions")
            }
            .padding(.bottom, 6)

            if showSourcePicker {
                sourcePicker
            }


            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if orderedGroups.isEmpty {
                            Text("No rhymes found.")
                                .font(.callout)
                                .foregroundStyle(Momentum.contentSecondary)
                                .id("top")
                        } else {
                            ForEach(Array(orderedGroups.enumerated()), id: \.element.id) { index, group in
                                groupRowView(index: index, group: group)
                                    .id(index == 0 ? "top" : group.id.uuidString)

                                if index < orderedGroups.count - 1 {
                                    Divider().opacity(0.25)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    withAnimation {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .task(id: suggestionTaskID) {
            await refreshSuggestions()
        }
        .task {
            artistNames = await RhymeIndexStore.shared.artistNames()
        }
        .padding(16)
        .frame(width: popoverWidth)
        .frame(maxHeight: popoverMaxHeight)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Momentum.surfaceElevated)        )
    }
    
    // Helper view builder to break up complex expression
    @ViewBuilder
    private func groupRowView(index: Int, group: RhymeHighlighterEngine.RhymeGroup) -> some View {
        let groupColor = Color(RhymeColorPalette.color(at: group.colorIndex))
        let uniqueWords = Array(Set(group.words.map { $0.word })).sorted()
        let suggestions = showSuggestions ? (chipsByGroup[group.id] ?? []) : []
        
        VStack(alignment: .leading, spacing: 8) {
            // Group header
            Text(groupHeaderTitle(index: index, group: group))
                .font(.caption.weight(.semibold))
                .foregroundStyle(groupColor)
            
            // Current words in group
            Text(uniqueWords.joined(separator: " · "))
                .font(.callout)
                .foregroundStyle(groupColor.opacity(0.8))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            if showSuggestions && !suggestions.isEmpty {
                RhymeChipFlow(spacing: 6) {
                    ForEach(suggestions) { chip in
                        suggestionChip(chip)
                    }
                }
            }
        }
    }

    private func suggestionChip(_ chip: RhymeLightbulbSearch.Chip) -> some View {
        Button {
            onInsert(chip.word)
        } label: {
            Text(chip.word)
                .font(.callout)
                .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(chip.word)
        .accessibilityHint("Inserts at the caret")
        .contextMenu {
            if chip.exampleBar.isEmpty {
                Text("Dictionary")
            } else {
                Text(chip.exampleBar)
                if !chip.song.isEmpty {
                    Text(chip.song)
                }
            }
        }
    }

    private var filteredArtists: [String] {
        let query = artistQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return artistNames }
        return artistNames.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    private var sourcePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            sourceChoice("Dictionary")
            sourceChoice("All artists")
            TextField("Artist", text: $artistQuery)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Search artists")
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    if artistNames.isEmpty {
                        Text("Loading artists")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    ForEach(filteredArtists, id: \.self) { name in
                        sourceChoice(name)
                    }
                }
            }
            .frame(maxHeight: 180)
        }
    }

    private func sourceChoice(_ name: String) -> some View {
        Button {
            rhymeLightbulbSource = name
            showSourcePicker = false
            artistQuery = ""
        } label: {
            HStack {
                Text(name)
                    .font(.callout)
                    .foregroundStyle(Momentum.contentPrimary)
                Spacer()
                if rhymeLightbulbSource == name {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var suggestionTaskID: String {
        guard showSuggestions else { return "off|\(rhymeLightbulbSource)" }
        let ids = orderedGroups.map(\.id.uuidString).joined(separator: ",")
        return "\(rhymeLightbulbSource)|\(currentText.hashValue)|\(ids)"
    }

    private func refreshSuggestions() async {
        guard showSuggestions else {
            chipsByGroup = [:]
            sourceLabel = rhymeLightbulbSource
            return
        }
        let source = rhymeLightbulbSource
        sourceLabel = source
        let requests = orderedGroups.map { group in
            RhymeLightbulbSearch.Request(
                id: group.id,
                key: group.key,
                words: group.words.map(\.word)
            )
        }
        let textWords = RhymeHighlighterEngine.tokenizeWords(in: currentText).map(\.0)
        let result = await Task.detached(priority: .userInitiated) {
            await RhymeLightbulbSearch.run(source: source, requests: requests, textWords: textWords)
        }.value
        if Task.isCancelled { return }
        chipsByGroup = result.chips
        sourceLabel = result.label
    }
    
    private func groupHeaderTitle(index: Int, group: RhymeHighlighterEngine.RhymeGroup) -> String {
        let isInternal = group.rhymeType == .internalRhyme
        let kind = isInternal ? "Internal" : "End"
        let ordinal = orderedGroups.prefix(index + 1).filter {
            ($0.rhymeType == .internalRhyme) == isInternal
        }.count
        return "\(kind) \(ordinal)"
    }
}

/// Wraps lightbulb words so each one is its own tap target.
private struct RhymeChipFlow: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        let rows = rows(in: width, subviews: subviews)
        let height = rows.reduce(CGFloat(0)) { $0 + $1.height } + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = rows(in: bounds.width, subviews: subviews)
        var y = bounds.minY
        var index = 0
        for row in rows {
            var x = bounds.minX
            for size in row.sizes {
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )
                x += size.width + spacing
                index += 1
            }
            y += row.height + spacing
        }
    }

    private func rows(in width: CGFloat, subviews: Subviews) -> [(height: CGFloat, sizes: [CGSize])] {
        var rows: [(height: CGFloat, sizes: [CGSize])] = []
        var current: [CGSize] = []
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let next = rowWidth == 0 ? size.width : rowWidth + spacing + size.width
            if next > width, !current.isEmpty {
                rows.append((rowHeight, current))
                current = [size]
                rowWidth = size.width
                rowHeight = size.height
            } else {
                current.append(size)
                rowWidth = next
                rowHeight = max(rowHeight, size.height)
            }
        }
        if !current.isEmpty {
            rows.append((rowHeight, current))
        }
        return rows
    }
}
