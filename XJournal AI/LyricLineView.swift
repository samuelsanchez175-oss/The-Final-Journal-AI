//
//  LyricLineView.swift
//  XJournal AI
//
//  One rap bar, rendered for the Rap Suggestions deck (spec §3.2, §3.7). Single-line
//  shrink-to-fit by default; bold stressed syllables in "stack" mode; multi-line phrase
//  cascade at large Dynamic Type (or when forced). Standalone — not yet wired into
//  RapSuggestionView (that's the assembly phase).
//

import SwiftUI

enum LyricRenderMode {
    case plain      // single line, shrink-to-fit
    case stress     // single line, stressed syllables emphasized (the "Stack" view)
    case cascade    // multi-line breath chunks (large-text reading layout)
}

struct LyricLineView: View {
    let line: String
    var mode: LyricRenderMode = .plain
    /// Prebuilt rhyme-highlighted text (from RhymeHighlighterEngine), supplied by the
    /// card when the eye toggle is on. Wiring happens in the assembly phase.
    var rhymeAttributed: AttributedString? = nil
    var isFresh: Bool = false
    var isLiked: Bool = false
    var isDisliked: Bool = false
    var isModelGMoment: Bool = false
    var onTap: () -> Void = {}

    @Environment(\.dynamicTypeSize) private var typeSize

    private var useCascade: Bool { mode == .cascade || typeSize >= .accessibility1 }

    var body: some View {
        HStack(spacing: 8) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(feedbackBackground)
                .overlay(feedbackBorder)
                .contentShape(Rectangle())
                .onTapGesture { onTap() }
            trailingGlyphs
        }
    }

    @ViewBuilder
    private var content: some View {
        if isFresh {
            // Freshness flash: whole line blue, styling suppressed until it fades.
            Text(line).font(.body).foregroundStyle(.blue)
                .lineLimit(1).minimumScaleFactor(0.6)
        } else if useCascade {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(CascadeFormatter.chunks(for: line).enumerated()), id: \.offset) { _, chunk in
                    Text(chunk.text)
                        .font(.body)
                        .padding(.leading, CGFloat(min(chunk.indentLevel, 4)) * 16)
                }
            }
        } else if mode == .stress {
            Text(stressAttributed).lineLimit(1).minimumScaleFactor(0.6)
        } else if let rhyme = rhymeAttributed {
            Text(rhyme).font(.body).lineLimit(1).minimumScaleFactor(0.6)
        } else {
            Text(line).font(.body).foregroundStyle(plainColor)
                .lineLimit(1).minimumScaleFactor(0.6)
        }
    }

    private var stressAttributed: AttributedString {
        var result = AttributedString()
        for span in StressMap.spans(for: line) {
            var piece = AttributedString(span.text)
            if span.isStressed {
                piece.font = .body.bold()
                piece.foregroundColor = .primary
            } else {
                piece.foregroundColor = .secondary
            }
            result += piece
        }
        return result
    }

    private var plainColor: Color {
        if isLiked { return .green }
        if isDisliked { return .red }
        return .primary
    }

    @ViewBuilder
    private var trailingGlyphs: some View {
        if isModelGMoment {
            Text("✴").font(.caption).foregroundStyle(Momentum.contentSecondary)
        }
        if isLiked {
            Image(systemName: "hand.thumbsup.fill").font(.caption).foregroundStyle(.green)
        } else if isDisliked {
            Image(systemName: "hand.thumbsdown.fill").font(.caption).foregroundStyle(.red)
        }
    }

    private var feedbackBackground: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(isLiked ? Color.green.opacity(0.15) : (isDisliked ? Color.red.opacity(0.15) : Color.clear))
    }

    private var feedbackBorder: some View {
        RoundedRectangle(cornerRadius: 6)
            .stroke(isLiked ? Color.green.opacity(0.5) : (isDisliked ? Color.red.opacity(0.5) : Color.clear), lineWidth: 1)
    }
}

#Preview {
    VStack(spacing: 12) {
        LyricLineView(line: "In the club, got that fire, every time I'm performin'")
        LyricLineView(line: "Birkin bag full of dead presidents, that's what I'm haulin'", mode: .stress)
        LyricLineView(line: "Red Bottoms on the floor, Chinchilla, that's how I'm flossin'", mode: .cascade)
        LyricLineView(line: "Fresh bar just landed on the deck", isFresh: true)
    }
    .padding()
}
