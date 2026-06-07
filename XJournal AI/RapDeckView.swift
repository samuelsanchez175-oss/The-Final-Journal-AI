//
//  RapDeckView.swift
//  XJournal AI
//
//  The swipeable deck of generations (spec §3.6). Newest is index 0 (front); swipe right
//  for older. Page dots + the blue swipe hint. The live critic is shown on the visible
//  card; older cards show their own snapshot.
//

import SwiftUI

struct RapDeckView: View {
    let generations: [Generation]
    @Binding var index: Int
    var stackOn: Bool = false
    var rhymeOn: Bool = false
    var criticFeedback: HumanCriticFeedback? = nil
    var criticLoading: Bool = false
    var criticError: String? = nil
    var onRetryCritic: () -> Void = {}
    var onTapLine: (RapSuggestion, Int) -> Void = { _, _ in }
    /// Per-suggestion liked / disliked line indices (non-empty-line index space), so each
    /// bar can render its like/dislike state. Keyed by suggestion id.
    var likedLines: [UUID: Set<Int>] = [:]
    var dislikedLines: [UUID: Set<Int>] = [:]

    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $index) {
                ForEach(Array(generations.enumerated()), id: \.element.id) { pair in
                    card(for: pair.element, at: pair.offset)
                        .tag(pair.offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: index) { _, newIndex in
                // Swiping onto a generation with a standout "Model G moment" gets a distinct
                // sparkle; everything else gets the usual light page tick.
                let hasMoment = generations.indices.contains(newIndex)
                    && generations[newIndex].suggestions.contains { ($0.modelGMomentLineIndices?.isEmpty == false) }
                if hasMoment {
                    HapticFeedbackManager.shared.play(.sparkle)
                } else {
                    HapticFeedbackManager.shared.fire(.impact(.light))
                }
            }

            if generations.count > 1 {
                pageIndicator
                Text("swipe → for previous generations")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(.bottom, 4)
            }
        }
    }

    @ViewBuilder
    private func card(for gen: Generation, at i: Int) -> some View {
        let isCurrent = i == index
        GenerationCardView(
            generation: gen,
            stackOn: stackOn,
            rhymeOn: rhymeOn,
            criticFeedback: isCurrent ? criticFeedback : gen.critic,
            criticLoading: isCurrent ? criticLoading : false,
            criticError: isCurrent ? criticError : nil,
            onRetryCritic: onRetryCritic,
            onTapLine: onTapLine,
            likedLines: likedLines,
            dislikedLines: dislikedLines
        )
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(generations.indices, id: \.self) { i in
                Circle()
                    .fill(i == index ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
