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
    var contextText: String? = nil                       // the user's written lyrics (shown first)
    var userFeedback: [UUID: RapSuggestion.SuggestionFeedback] = [:]
    var onRetryCritic: () -> Void = {}
    var onTapLine: (RapSuggestion, Int) -> Void = { _, _ in }
    var onLike: (RapSuggestion) -> Void = { _ in }
    var onDislike: (RapSuggestion) -> Void = { _ in }

    @State private var fresh: Bool
    @State private var rhymeBySuggestion: [UUID: [AttributedString]] = [:]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(generation: Generation,
         stackOn: Bool = false,
         rhymeOn: Bool = false,
         criticFeedback: HumanCriticFeedback? = nil,
         criticLoading: Bool = false,
         criticError: String? = nil,
         contextText: String? = nil,
         userFeedback: [UUID: RapSuggestion.SuggestionFeedback] = [:],
         onRetryCritic: @escaping () -> Void = {},
         onTapLine: @escaping (RapSuggestion, Int) -> Void = { _, _ in },
         onLike: @escaping (RapSuggestion) -> Void = { _ in },
         onDislike: @escaping (RapSuggestion) -> Void = { _ in }) {
        self.generation = generation
        self.stackOn = stackOn
        self.rhymeOn = rhymeOn
        self.criticFeedback = criticFeedback
        self.criticLoading = criticLoading
        self.criticError = criticError
        self.contextText = contextText
        self.userFeedback = userFeedback
        self.onRetryCritic = onRetryCritic
        self.onTapLine = onTapLine
        self.onLike = onLike
        self.onDislike = onDislike
        _fresh = State(initialValue: generation.isFresh)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // The user's written lyrics FIRST (the context that prompted these), then the suggestions.
                if let ctx = contextText?.trimmingCharacters(in: .whitespacesAndNewlines), !ctx.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your lines")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Momentum.contentSecondary)
                        ForEach(Array(ctx.components(separatedBy: "\n").enumerated()), id: \.offset) { _, line in
                            if !line.isEmpty {
                                Text(line).font(.body).foregroundStyle(Momentum.contentSecondary)
                            }
                        }
                    }
                    Divider()
                }

                ForEach(generation.suggestions) { suggestion in
                    VStack(alignment: .leading, spacing: 8) {
                        lyrics(for: suggestion)
                        feedbackRow(for: suggestion)
                    }
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
            .padding(.top, 8)
            .padding(.bottom, 80)   // clear the floating island pill so feedback/critic aren't hidden
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

    @ViewBuilder
    private func feedbackRow(for suggestion: RapSuggestion) -> some View {
        HStack(spacing: 20) {
            Button { onDislike(suggestion) } label: {
                Image(systemName: userFeedback[suggestion.id] == .disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .font(.subheadline)
                    .foregroundStyle(userFeedback[suggestion.id] == .disliked ? .red : Momentum.contentSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dislike suggestion")

            Button { onLike(suggestion) } label: {
                Image(systemName: userFeedback[suggestion.id] == .liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.subheadline)
                    .foregroundStyle(userFeedback[suggestion.id] == .liked ? .green : Momentum.contentSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Like suggestion")

            Spacer()
        }
    }
}
