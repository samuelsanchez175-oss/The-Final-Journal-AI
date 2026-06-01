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
         onTapLine: @escaping (RapSuggestion, Int) -> Void = { _, _ in }) {
        self.generation = generation
        self.stackOn = stackOn
        self.rhymeOn = rhymeOn
        self.criticFeedback = criticFeedback
        self.criticLoading = criticLoading
        self.criticError = criticError
        self.onRetryCritic = onRetryCritic
        self.onTapLine = onTapLine
        _fresh = State(initialValue: generation.isFresh)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
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
                let (_, highlights) = await RhymeHighlighterEngine.computeAll(text: suggestion.text)
                let spans = highlights.map { (range: $0.range, colorIndex: $0.colorIndex) }
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
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(rawLines.enumerated()), id: \.offset) { idx, line in
                if !line.isEmpty {
                    LyricLineView(
                        line: line,
                        mode: stackOn ? .stress : .plain,
                        rhymeAttributed: idx < rhyme.count ? rhyme[idx] : nil,
                        isFresh: fresh,
                        isModelGMoment: suggestion.modelGMomentLineIndices?.contains(idx) ?? false,
                        onTap: { onTapLine(suggestion, idx) }
                    )
                }
            }
        }
    }
}
