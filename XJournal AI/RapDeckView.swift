//
//  RapDeckView.swift
//  XJournal AI
//
//  The swipeable deck of generations (spec §3.6). Newest is index 0 (front); swipe right
//  for older. Page dots + the blue swipe hint. Standalone — the assembly phase binds this
//  to RapSuggestionEngine.generations / currentGenerationIndex.
//

import SwiftUI

struct RapDeckView: View {
    let generations: [Generation]
    @Binding var index: Int
    var stackOn: Bool = false
    var rhymeOn: Bool = false
    var onRetryCritic: () -> Void = {}
    var onTapLine: (RapSuggestion, Int) -> Void = { _, _ in }

    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $index) {
                ForEach(Array(generations.enumerated()), id: \.element.id) { i, gen in
                    GenerationCardView(
                        generation: gen,
                        stackOn: stackOn,
                        rhymeOn: rhymeOn,
                        onRetryCritic: onRetryCritic,
                        onTapLine: onTapLine
                    )
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if generations.count > 1 {
                pageIndicator
                Text("swipe → for previous generations")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(.bottom, 4)
            }
        }
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
