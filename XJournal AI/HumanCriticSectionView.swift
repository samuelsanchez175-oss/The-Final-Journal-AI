//
//  HumanCriticSectionView.swift
//  XJournal AI
//

import SwiftUI

struct HumanCriticSectionView: View {
    let feedback: HumanCriticFeedback?
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.bubble")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("Critic")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                Spacer()
            }

            if isLoading {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Momentum.hairline)
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Momentum.hairline)
                        .frame(height: 10)
                        .frame(maxWidth: 220)
                }
                .accessibilityLabel("Loading feedback")
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                Button("Try again", action: onRetry)
                    .font(.caption.weight(.semibold))
            } else if let feedback {
                CriticTextStyling.aiText(feedback.headline)
                    .font(.subheadline.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)

                if !feedback.positiveReactions.isEmpty {
                    reactionGroup(title: "What worked", reactions: feedback.positiveReactions, accent: .green)
                }

                if !feedback.constructiveReactions.isEmpty {
                    reactionGroup(title: "Could be stronger", reactions: feedback.constructiveReactions, accent: .orange)
                }

                if !feedback.feelings.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Felt like")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Momentum.contentSecondary)
                        FlowLayoutFeelings(words: feedback.feelings)
                    }
                }

                if let hook = feedback.hookNote, !hook.isEmpty {
                    labeledBlock(title: "Hook / theme", body: hook)
                }

                if let step = feedback.nextStep, !step.isEmpty {
                    labeledBlock(title: "Try this", body: step)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .strokeBorder(Color.orange.opacity(0.2), lineWidth: Momentum.lineThin)
                )
        )
    }

    @ViewBuilder
    private func reactionGroup(title: String, reactions: [CriticReaction], accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Momentum.contentSecondary)
            ForEach(reactions) { reaction in
                VStack(alignment: .leading, spacing: 2) {
                    if !reaction.quote.isEmpty {
                        CriticTextStyling.userQuote("“\(reaction.quote)”")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    CriticTextStyling.aiText(reaction.note)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ViewBuilder
    private func labeledBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Momentum.contentSecondary)
            CriticTextStyling.aiText(body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Simple horizontal wrap for feeling chips.
private struct FlowLayoutFeelings: View {
    let words: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(words, id: \.self) { word in
                Text(word)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Momentum.surfaceElevated))
                    .overlay(Capsule().stroke(Momentum.hairline, lineWidth: Momentum.lineThin))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
