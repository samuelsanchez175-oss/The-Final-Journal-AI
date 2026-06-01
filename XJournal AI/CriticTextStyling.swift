//
//  CriticTextStyling.swift
//  XJournal AI
//
//  User verse references: bold + primary. AI commentary: secondary gray.
//

import SwiftUI

enum CriticTextStyling {
    static func userQuote(_ text: String) -> Text {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.primary)
    }

    static func aiText(_ text: String) -> Text {
        Text(text)
            .font(.caption)
            .foregroundStyle(Momentum.contentSecondary)
    }

    static func aiLabel(_ text: String) -> Text {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Momentum.contentSecondary)
    }
}

// MARK: - Line comparison (legacy WritersCritique commentary string)

struct LineComparisonCommentaryView: View {
    let commentary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(commentary.components(separatedBy: "\n").enumerated()), id: \.offset) { _, line in
                lineRow(line)
            }
        }
    }

    @ViewBuilder
    private func lineRow(_ raw: String) -> some View {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            EmptyView()
        } else if trimmed.hasPrefix("Your last line:") {
            labeledQuoteBlock(
                label: "Your last line:",
                payload: String(trimmed.dropFirst("Your last line:".count)),
                quoteIsUserInput: true
            )
        } else if trimmed.hasPrefix("Generated:") {
            labeledQuoteBlock(
                label: "Generated:",
                payload: String(trimmed.dropFirst("Generated:".count)),
                quoteIsUserInput: false
            )
        } else if trimmed.hasPrefix("Why suggested:") {
            VStack(alignment: .leading, spacing: 2) {
                CriticTextStyling.aiLabel("Why suggested:")
                CriticTextStyling.aiText(String(trimmed.dropFirst("Why suggested:".count)).trimmingCharacters(in: .whitespaces))
            }
        } else if trimmed.hasPrefix("Previous lines need:") {
            VStack(alignment: .leading, spacing: 2) {
                CriticTextStyling.aiLabel("Previous lines need:")
                CriticTextStyling.aiText(String(trimmed.dropFirst("Previous lines need:".count)).trimmingCharacters(in: .whitespaces))
            }
        } else {
            CriticTextStyling.aiText(trimmed)
        }
    }

    @ViewBuilder
    private func labeledQuoteBlock(label: String, payload: String, quoteIsUserInput: Bool) -> some View {
        if let quote = extractQuotedString(from: payload) {
            VStack(alignment: .leading, spacing: 2) {
                CriticTextStyling.aiLabel(label)
                if quoteIsUserInput {
                    CriticTextStyling.userQuote(quote)
                } else {
                    CriticTextStyling.aiText(quote)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 2) {
                CriticTextStyling.aiLabel(label)
                if quoteIsUserInput {
                    CriticTextStyling.userQuote(payload.trimmingCharacters(in: .whitespaces))
                } else {
                    CriticTextStyling.aiText(payload.trimmingCharacters(in: .whitespaces))
                }
            }
        }
    }

    private func extractQuotedString(from payload: String) -> String? {
        let trimmed = payload.trimmingCharacters(in: .whitespaces)
        guard let start = trimmed.firstIndex(of: "\""),
              let end = trimmed.lastIndex(of: "\""),
              start < end
        else { return nil }
        return String(trimmed[trimmed.index(after: start)..<end])
    }
}
