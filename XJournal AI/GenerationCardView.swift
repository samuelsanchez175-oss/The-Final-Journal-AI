//
//  GenerationCardView.swift
//  XJournal AI
//
//  One card in the Rap Suggestions deck: lyrics first, then this generation's Critic
//  below (spec §3.5), with the freshness flash (spec §3.6). Standalone structural view —
//  the rich per-suggestion affordances (theme tags, quality indicators, feedback form,
//  Tighten) are folded in during the assembly phase that edits RapSuggestionView.
//

import SwiftUI

struct GenerationCardView: View {
    let generation: Generation
    var stackOn: Bool = false
    var onRetryCritic: () -> Void = {}
    var onTapLine: (RapSuggestion, Int) -> Void = { _, _ in }

    @State private var fresh: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(generation: Generation,
         stackOn: Bool = false,
         onRetryCritic: @escaping () -> Void = {},
         onTapLine: @escaping (RapSuggestion, Int) -> Void = { _, _ in }) {
        self.generation = generation
        self.stackOn = stackOn
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
        .onTapGesture {
            if fresh {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) { fresh = false }
            }
        }
    }

    @ViewBuilder
    private func lyrics(for suggestion: RapSuggestion) -> some View {
        let lines = suggestion.text.components(separatedBy: "\n").filter { !$0.isEmpty }
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(lines.enumerated()), id: \.offset) { idx, line in
                LyricLineView(
                    line: line,
                    mode: stackOn ? .stress : .plain,
                    isFresh: fresh,
                    isModelGMoment: suggestion.modelGMomentLineIndices?.contains(idx) ?? false,
                    onTap: { onTapLine(suggestion, idx) }
                )
            }
        }
    }
}
