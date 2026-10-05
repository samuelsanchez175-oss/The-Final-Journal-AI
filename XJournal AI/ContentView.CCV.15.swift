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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isSortReversed = false
    @State private var showSuggestions = false
    
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
                    showSuggestions.toggle()
                } label: {
                    Image(systemName: showSuggestions ? "lightbulb.fill" : "lightbulb")
                        .font(.headline)
                        .foregroundStyle(showSuggestions ? .blue : .secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 6)


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
        let suggestions = showSuggestions ? findRhymeSuggestions(for: group) : []
        
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
            
            // Suggestions section
            if showSuggestions && !suggestions.isEmpty {
                Text(suggestions.joined(separator: " · "))
                    .font(.callout)
                    .foregroundStyle(.blue)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func groupHeaderTitle(index: Int, group: RhymeHighlighterEngine.RhymeGroup) -> String {
        let isInternal = group.rhymeType == .internalRhyme
        let kind = isInternal ? "Internal" : "End"
        let ordinal = orderedGroups.prefix(index + 1).filter {
            ($0.rhymeType == .internalRhyme) == isInternal
        }.count
        return "\(kind) \(ordinal)"
    }

    // Find rhyming words that aren't in the current text
    private func findRhymeSuggestions(for group: RhymeHighlighterEngine.RhymeGroup) -> [String] {
        let wordsInText = Set(
            RhymeHighlighterEngine.tokenizeWords(in: currentText).map { $0.0.lowercased() }
        )
        
        // Get the phonetic signature from the first word in the group
        guard let firstWord = group.words.first,
              let phonemes = RhymeHighlighterEngine.phonemes(for: firstWord.word),
              let groupSignature = RhymeHighlighterEngine.extractSignature(from: phonemes) else {
            return []
        }
        
        // Find all words in CMUDICT that rhyme with this group
        let dict = FJCMUDICTStore.shared.phonemesByWord
        var perfectRhymes: [String] = []
        var nearRhymes: [String] = []
        
        for (word, wordPhonemes) in dict {
            // Skip if word is already in the text
            if wordsInText.contains(word.lowercased()) {
                continue
            }
            
            // Skip if word is already in this group
            if group.words.contains(where: { $0.word.lowercased() == word.lowercased() }) {
                continue
            }
            
            // Check if it rhymes with the group
            guard let wordSignature = RhymeHighlighterEngine.extractSignature(from: wordPhonemes),
                  let strength = RhymeHighlighterEngine.rhymeScore(groupSignature, wordSignature) else {
                continue
            }
            
            // Prioritize perfect rhymes, then near rhymes (skip slant)
            let capitalizedWord = word.capitalized
            switch strength {
            case .perfect:
                perfectRhymes.append(capitalizedWord)
            case .near:
                nearRhymes.append(capitalizedWord)
            case .slant:
                continue
            }
            
            // Stop if we have enough perfect rhymes (7 for better suggestions)
            if perfectRhymes.count >= 7 {
                break
            }
        }
        
        // Return perfect rhymes first, then fill with near rhymes up to 7 total
        let allSuggestions = perfectRhymes + nearRhymes
        return Array(allSuggestions.prefix(7)).sorted()
    }
}
