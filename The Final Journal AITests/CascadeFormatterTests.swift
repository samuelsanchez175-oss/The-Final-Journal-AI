//
//  CascadeFormatterTests.swift
//  The Final Journal AITests
//

import Testing
@testable import XJournal_AI

struct CascadeFormatterTests {
    @Test func short_line_is_a_single_chunk_at_indent_zero() {
        let chunks = CascadeFormatter.chunks(for: "Circle small big moves", maxSyllablesPerChunk: 6)
        #expect(chunks == [CascadeChunk(text: "Circle small big moves", indentLevel: 0)])
    }

    @Test func long_line_breaks_into_stepped_chunks() {
        let chunks = CascadeFormatter.chunks(
            for: "Birkin bag full of dead presidents that's what I'm haulin",
            maxSyllablesPerChunk: 4
        )
        #expect(chunks.count >= 2)
        // Indents step 0,1,2,… and the words are preserved in order.
        for (i, c) in chunks.enumerated() { #expect(c.indentLevel == i) }
        #expect(chunks.map(\.text).joined(separator: " ")
                == "Birkin bag full of dead presidents that's what I'm haulin")
    }

    @Test func a_comma_forces_a_break() {
        let chunks = CascadeFormatter.chunks(for: "money in, money out", maxSyllablesPerChunk: 20)
        #expect(chunks.count == 2)
        #expect(chunks[0].text == "money in,")
        #expect(chunks[1].text == "money out")
    }
}
