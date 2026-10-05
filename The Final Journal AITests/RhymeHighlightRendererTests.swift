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
        #expect(lines[0].runs.contains { $0.backgroundColor != nil })   // "fire" painted like the editor
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

    @Test func remap_keeps_spans_when_appending() {
        let old = "cat hat"
        let hat = (old as NSString).range(of: "hat")
        let highlight = Highlight(utf16: hat, colorIndex: 0, strength: .perfect, rhymeType: .endRhyme)
        let remapped = RhymeEngineState.remapHighlights([highlight], from: old, to: old + "s")
        #expect(remapped.count == 1)
        #expect(remapped[0].utf16 == hat)
    }

    @Test func remap_shifts_spans_after_a_prefix_insert() {
        let old = "cat hat"
        let hat = (old as NSString).range(of: "hat")
        let highlight = Highlight(utf16: hat, colorIndex: 0, strength: .perfect, rhymeType: .endRhyme)
        let remapped = RhymeEngineState.remapHighlights([highlight], from: old, to: "X" + old)
        #expect(remapped.count == 1)
        #expect(remapped[0].utf16.location == hat.location + 1)
        #expect(remapped[0].utf16.length == hat.length)
    }

    @Test func remap_drops_spans_that_overlap_the_edit() {
        let old = "cat hat"
        let hat = (old as NSString).range(of: "hat")
        let highlight = Highlight(utf16: hat, colorIndex: 0, strength: .perfect, rhymeType: .endRhyme)
        let remapped = RhymeEngineState.remapHighlights([highlight], from: old, to: "cat hXat")
        #expect(remapped.isEmpty)
    }

    @Test func remap_drops_spans_past_the_new_end() {
        let old = "cat hat extra"
        let extra = (old as NSString).range(of: "extra")
        let highlight = Highlight(utf16: extra, colorIndex: 0, strength: .perfect, rhymeType: .endRhyme)
        let remapped = RhymeEngineState.remapHighlights([highlight], from: old, to: "cat")
        #expect(remapped.isEmpty)
    }
}
