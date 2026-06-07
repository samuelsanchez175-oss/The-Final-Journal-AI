//
//  RhymeHighlightRenderer.swift
//  XJournal AI
//
//  Turns rhyme highlights (from RhymeHighlighterEngine) into per-line SwiftUI
//  AttributedStrings for the Rap Suggestions eye toggle (spec §3.3). Pure mapping —
//  takes (range, colorIndex) spans into the full text and a line split, colours each
//  line with the editor's RhymeColorPalette. Reusable + unit-testable without async.
//

import SwiftUI
import UIKit

enum RhymeHighlightRenderer {
    /// One coloured AttributedString per line of `fullText` (split on "\n", unfiltered so
    /// indices line up with a matching split at the call site). Spans are ranges into
    /// `fullText` paired with a palette colour index.
    static func perLineAttributed(
        fullText: String,
        spans: [(range: Range<String.Index>, colorIndex: Int)]
    ) -> [AttributedString] {
        // Character offsets of each span within the full text.
        let offsets: [(start: Int, end: Int, colorIndex: Int)] = spans.compactMap { s in
            let start = fullText.distance(from: fullText.startIndex, to: s.range.lowerBound)
            let end = fullText.distance(from: fullText.startIndex, to: s.range.upperBound)
            guard end > start else { return nil }
            return (start, end, s.colorIndex)
        }

        var results: [AttributedString] = []
        var lineStart = 0
        for line in fullText.components(separatedBy: "\n") {
            let lineLen = line.count
            let lineEnd = lineStart + lineLen
            var attr = AttributedString(line)

            for o in offsets where o.start < lineEnd && o.end > lineStart {
                let relStart = max(o.start, lineStart) - lineStart
                let relEnd = min(o.end, lineEnd) - lineStart
                guard relEnd > relStart, relStart >= 0, relEnd <= lineLen else { continue }
                let a0 = attr.index(attr.startIndex, offsetByCharacters: relStart)
                let a1 = attr.index(a0, offsetByCharacters: relEnd - relStart)
                // Highlight the rhyme as a translucent coloured background behind the text
                // (matching the editor) rather than recolouring the glyphs — keeps every bar
                // legible while still grouping rhymes by colour.
                attr[a0..<a1].backgroundColor = highlightColor(for: o.colorIndex)
            }

            results.append(attr)
            lineStart = lineEnd + 1 // +1 for the consumed "\n"
        }
        return results
    }

    /// Translucent background tint for a rhyme group, scheme-aware so it reads on both the
    /// light surface and the dark Lagoon surface. Foreground text is left untouched so the
    /// glyphs stay legible on top of the highlight.
    private static func highlightColor(for index: Int) -> Color {
        let palette = RhymeColorPalette.colors
        guard !palette.isEmpty else { return .clear }
        let i = ((index % palette.count) + palette.count) % palette.count
        let base = palette[i]
        let tint = UIColor { traits in
            base.resolvedColor(with: traits)
                .withAlphaComponent(traits.userInterfaceStyle == .dark ? 0.45 : 0.25)
        }
        return Color(uiColor: tint)
    }
}
