//
//  GenerationDeckTests.swift
//  The Final Journal AITests
//

import Testing
import Foundation
@testable import XJournal_AI

struct GenerationDeckTests {
    // Tag generations by createdAt so we avoid constructing RapSuggestion (whose
    // memberwise init has many non-defaulted optionals).
    private func gen(_ tag: Double) -> Generation {
        Generation(
            id: UUID(),
            suggestions: [],
            critic: nil,
            createdAt: Date(timeIntervalSince1970: tag),
            isFavorite: false,
            isFresh: true
        )
    }

    @Test func newest_is_inserted_at_the_front() {
        let deck = GenerationDeck.inserting(gen(2), into: [gen(1)])
        #expect(deck.first?.createdAt.timeIntervalSince1970 == 2)
        #expect(deck.last?.createdAt.timeIntervalSince1970 == 1)
    }

    @Test func deck_is_capped_and_drops_the_oldest() {
        var deck: [Generation] = []
        for i in 0..<12 { deck = GenerationDeck.inserting(gen(Double(i)), into: deck, cap: 10) }
        #expect(deck.count == 10)
        // Newest first; the two oldest (tags 0 and 1) were dropped.
        #expect(deck.first?.createdAt.timeIntervalSince1970 == 11)
        #expect(deck.contains { $0.createdAt.timeIntervalSince1970 == 0 } == false)
    }
}
