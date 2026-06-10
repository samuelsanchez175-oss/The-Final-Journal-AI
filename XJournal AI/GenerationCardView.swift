//
//  GenerationCardView.swift
//  XJournal AI
//
//  One card in the Rap Suggestions deck: lyrics first, then the Critic below (spec §3.5),
//  with the freshness flash (spec §3.6) and the eye-toggle rhyme overlay (spec §3.3).
//  The critic is passed in (live for the visible card, snapshot for others) by RapDeckView.
//  NOTE: this is the new-design card — it does not (yet) carry the legacy suggestionCard
//  affordances (theme tags, quality indicators, feedback form, Tighten). Those are a
//  follow-up if we want them back in the deck.
//

import SwiftUI

struct GenerationCardView: View {
    let generation: Generation
    var stackOn: Bool = false
    var rhymeOn: Bool = false
    var criticFeedback: HumanCriticFeedback?
    var criticLoading: Bool = false
    var criticError: String? = nil
    var onRetryCritic: () -> Void = {}
    var onTapLine: (RapSuggestion, Int) -> Void = { _, _ in }
    /// Per-suggestion liked / disliked line indices (non-empty-line index space),
    /// so taps show up green/red on the deck card.
    var likedLines: [UUID: Set<Int>] = [:]
    var dislikedLines: [UUID: Set<Int>] = [:]

    @State private var fresh: Bool
    @State private var rhymeBySuggestion: [UUID: [AttributedString]] = [:]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(generation: Generation,
         stackOn: Bool = false,
         rhymeOn: Bool = false,
         criticFeedback: HumanCriticFeedback? = nil,
         criticLoading: Bool = false,
         criticError: String? = nil,
         onRetryCritic: @escaping () -> Void = {},
         onTapLine: @escaping (RapSuggestion, Int) -> Void = { _, _ in },
         likedLines: [UUID: Set<Int>] = [:],
         dislikedLines: [UUID: Set<Int>] = [:]) {
        self.generation = generation
        self.stackOn = stackOn
        self.rhymeOn = rhymeOn
        self.criticFeedback = criticFeedback
        self.criticLoading = criticLoading
        self.criticError = criticError
        self.onRetryCritic = onRetryCritic
        self.onTapLine = onTapLine
        self.likedLines = likedLines
        self.dislikedLines = dislikedLines
        _fresh = State(initialValue: generation.isFresh)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Tap a line: once = dislike, again = like, again = clear")
                    .font(.caption2)
                    .foregroundStyle(Momentum.contentSecondary)

                ForEach(generation.suggestions) { suggestion in
                    lyrics(for: suggestion)
                }

                Divider()

                HumanCriticSectionView(
                    feedback: criticFeedback,
                    isLoading: criticLoading,
                    errorMessage: criticError,
                    onRetry: onRetryCritic
                )
            }
            .padding(16)
            .background(Momentum.surfaceElevated, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .task(id: generation.id) {
            guard fresh else { return }
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            if !Task.isCancelled {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) { fresh = false }
            }
        }
        .task(id: "\(generation.id.uuidString)-\(rhymeOn)") {
            guard rhymeOn else { rhymeBySuggestion = [:]; return }
            var map: [UUID: [AttributedString]] = [:]
            for suggestion in generation.suggestions {
                let (groups, _) = await RhymeHighlighterEngine.computeAll(text: suggestion.text)
                let spans = Self.sequentialRhymeSpans(for: groups, in: suggestion.text)
                map[suggestion.id] = RhymeHighlightRenderer.perLineAttributed(fullText: suggestion.text, spans: spans)
            }
            rhymeBySuggestion = map
        }
        .onTapGesture {
            if fresh {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) { fresh = false }
            }
        }
    }

    @ViewBuilder
    private func lyrics(for suggestion: RapSuggestion) -> some View {
        let rawLines = suggestion.text.components(separatedBy: "\n")
        let rhyme = rhymeOn ? (rhymeBySuggestion[suggestion.id] ?? []) : []
        let liked = likedLines[suggestion.id] ?? []
        let disliked = dislikedLines[suggestion.id] ?? []
        // Like/dislike is keyed by non-empty-line index (matching the rest of RapSuggestionView),
        // while the rhyme overlay is keyed by raw line index, so map between the two here.
        let feedbackIndexByRaw = Self.feedbackIndexMap(for: rawLines)
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(rawLines.enumerated()), id: \.offset) { idx, line in
                if !line.isEmpty {
                    let feedbackIndex = feedbackIndexByRaw[idx] ?? idx
                    LyricLineView(
                        line: line,
                        mode: stackOn ? .stress : .plain,
                        rhymeAttributed: idx < rhyme.count ? rhyme[idx] : nil,
                        isFresh: fresh,
                        isLiked: liked.contains(feedbackIndex),
                        isDisliked: disliked.contains(feedbackIndex),
                        isModelGMoment: suggestion.modelGMomentLineIndices?.contains(idx) ?? false,
                        onTap: { onTapLine(suggestion, feedbackIndex) }
                    )
                }
            }
        }
    }

    /// Maps each raw line index (split on "\n", blanks included) to its index among the
    /// non-empty lines — the index space the like/dislike store uses.
    private static func feedbackIndexMap(for rawLines: [String]) -> [Int: Int] {
        var map: [Int: Int] = [:]
        var nonEmpty = 0
        for (rawIndex, line) in rawLines.enumerated() where !line.isEmpty {
            map[rawIndex] = nonEmpty
            nonEmpty += 1
        }
        return map
    }

    /// Re-colours rhyme groups by first appearance so distinct rhymes get distinct, stable
    /// colours in the deck. `computeAll` assigns colours by hashing the rhyme key (which makes
    /// unrelated rhymes collide onto one hue, and which the editor relies on for its index-3
    /// sentinel), so the remap lives here, on the deck side, rather than in the shared engine.
    private static func sequentialRhymeSpans(
        for groups: [RhymeHighlighterEngine.RhymeGroup],
        in text: String
    ) -> [(range: Range<String.Index>, colorIndex: Int)] {
        let paletteCount = RhymeColorPalette.colors.count
        guard paletteCount > 0 else { return [] }
        let ordered = groups
            .map { group -> (earliest: String.Index, group: RhymeHighlighterEngine.RhymeGroup) in
                (group.words.map { $0.range.lowerBound }.min() ?? text.startIndex, group)
            }
            .sorted { $0.earliest < $1.earliest }
        var spans: [(range: Range<String.Index>, colorIndex: Int)] = []
        for (offset, item) in ordered.enumerated() {
            let colorIndex = offset % paletteCount
            for word in item.group.words {
                spans.append((range: word.range, colorIndex: colorIndex))
            }
        }
        return spans
    }
}
