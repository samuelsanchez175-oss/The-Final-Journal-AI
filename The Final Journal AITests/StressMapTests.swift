//
//  StressMapTests.swift
//  The Final Journal AITests
//
//  StressMap reuses the app's SyllableEngine + RapSlangPhonemes/CMU (global state), so
//  these tests assert structural invariants that hold regardless of which dictionary
//  resources are loaded, rather than hard-coding dictionary-specific stress.
//

import Testing
@testable import XJournal_AI

struct StressMapTests {
    @Test func spans_reassemble_to_the_original_line() {
        for line in [
            "bag of dead presidents",
            "In the club, got that fire, every time",
            "Birkin bag, no cap, I'm haulin'"
        ] {
            #expect(StressMap.spans(for: line).map(\.text).joined() == line)
        }
    }

    @Test func separators_are_never_stressed() {
        let spans = StressMap.spans(for: "money in, money out")
        // Any span with no letters is a separator (space/punctuation) → must be light.
        for s in spans where !s.text.contains(where: { $0.isLetter }) {
            #expect(s.isStressed == false)
        }
    }

    @Test func a_content_line_has_contrast() {
        let spans = StressMap.spans(for: "Birkin bag full of dead presidents")
        #expect(spans.contains { $0.isStressed })     // at least one emphasized syllable
        #expect(spans.contains { !$0.isStressed })    // and at least one not
    }

    @Test func empty_line_yields_no_spans() {
        #expect(StressMap.spans(for: "").isEmpty)
    }
}
