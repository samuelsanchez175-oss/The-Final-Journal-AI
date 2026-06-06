//
//  RhymeHighlightRendererTests.swift
//  The Final Journal AITests
//

import Testing
import Foundation
import SwiftUI
@testable import XJournal_AI

struct RhymeHighlightRendererTests {
    @Test func one_line_reassembles_and_colours_the_span() {
        let full = "fire on the wire"
        let spans = [(range: full.range(of: "fire")!, colorIndex: 0)]
        let lines = RhymeHighlightRenderer.perLineAttributed(fullText: full, spans: spans)
        #expect(lines.count == 1)
        #expect(String(lines[0].characters) == full)
        #expect(lines[0].runs.contains { $0.backgroundColor != nil })   // "fire" highlighted
    }

    @Test func spans_map_to_the_correct_line() {
        let full = "higher in the sky\nbuyer wants the buy"
        let spans = [
            (range: full.range(of: "higher")!, colorIndex: 0),
            (range: full.range(of: "buyer")!, colorIndex: 1),
        ]
        let lines = RhymeHighlightRenderer.perLineAttributed(fullText: full, spans: spans)
        #expect(lines.count == 2)
        #expect(String(lines[0].characters) == "higher in the sky")
        #expect(String(lines[1].characters) == "buyer wants the buy")
        #expect(lines[0].runs.contains { $0.backgroundColor != nil })
        #expect(lines[1].runs.contains { $0.backgroundColor != nil })
    }

    @Test func no_spans_means_no_colouring() {
        let lines = RhymeHighlightRenderer.perLineAttributed(fullText: "plain line", spans: [])
        #expect(lines.count == 1)
        #expect(lines[0].runs.allSatisfy { $0.backgroundColor == nil })
    }

    @Test func empty_text_yields_one_empty_line() {
        let lines = RhymeHighlightRenderer.perLineAttributed(fullText: "", spans: [])
        #expect(lines.count == 1)
        #expect(String(lines[0].characters) == "")
    }
}
