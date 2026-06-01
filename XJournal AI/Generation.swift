//
//  Generation.swift
//  XJournal AI
//
//  One "generation" (one tap of Generate) shown as one card in the Rap Suggestions
//  deck, plus the pure list logic behind the engine's session deck (spec §3.6).
//

import Foundation

/// One generation shown as one card in the deck.
struct Generation: Identifiable {
    let id: UUID
    let suggestions: [RapSuggestion]
    var critic: HumanCriticFeedback?      // per-card critic snapshot (spec §3.5)
    let createdAt: Date
    var isFavorite: Bool
    var isFresh: Bool                      // drives the freshness flash (spec §3.6)
}

/// Pure list logic for the session deck: newest at the front, capped.
enum GenerationDeck {
    static let defaultCap = 10

    static func inserting(_ new: Generation, into deck: [Generation], cap: Int = defaultCap) -> [Generation] {
        var d = deck
        d.insert(new, at: 0)               // index 0 = newest = front (spec §3.6)
        if d.count > cap { d = Array(d.prefix(cap)) }
        return d
    }
}
