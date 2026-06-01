//
//  GenerationCardView.swift
//  XJournal AI
//
//  One card in the Rap Suggestions deck: lyrics first, then this generation's Critic
//  below (spec §3.5), with the freshness flash (spec §3.6) and the eye-toggle rhyme
//  overlay (spec §3.3). Standalone structural view — the rich per-suggestion affordances
//  (theme tags, quality indicators, feedback form, Tighten) and the real feedback-index
//  convention are folded in during the assembly phase that edits RapSuggestionView.
//

import SwiftUI

struct GenerationCardView: View {
    let generation: Generation
    var stackOn: Bool = false
    var rhymeOn: Bool = false
    var onRetryCritic: () -> Void = {}
    var onTapLine: (RapSuggestion, Int) -> Void = { _, _ in }

    @State private var fresh: Bool
    @State private var rhymeBySuggestion: [UUID: [AttributedString]] = [:]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(generation: Generation,
         stackOn: Bool = false,
         rhymeOn: Bool = false,
         onRetryCritic: @escaping () -> Void = {},
         onTapLine: @escaping (RapSuggestion, Int) -> Void = { _, _ in }) {
        self.generation = generation
        self.stackOn = stackOn
        self.rhymeOn = rhymeOn
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
                    feedback: generation.critic,
                    isLoading: false,
                    errorMessage: nil,
                    onRetry: onRetryCritic
                )
            }
            .padding(16)
            .background(Momentum.surfaceElevated, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .task(id: generation.id) {
            // Freshness flash: clear after ~4s on screen (or on tap, below).
            guard fresh else { return }
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            if !Task.isCancelled {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) { fresh = false }
            }
        }
        .task(id: "\(generation.id.uuidString)-\(rhymeOn)") {
            // Eye toggle: compute rhyme highlights per suggestion (whole verse together).
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
        // Unfiltered split so indices line up with the rhyme renderer's per-line output.
        // (The filtered feedback-index convention is reconciled during assembly.)
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
