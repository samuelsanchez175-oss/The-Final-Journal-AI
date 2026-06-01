//
//  BannedLexiconStore.swift
//  XJournal AI
//
//  Model G Core v1.0 — Banned terms for hard rejection.
//

import Foundation

/// Banned lexicon for Model G hard rejection. Extend LexiconStore or maintain explicit list.
class BannedLexiconStore {
    static let shared = BannedLexiconStore()

    private let bannedTerms: Set<String> = {
        // Curated banned terms — expand as needed
        let terms = [
            "slur", "offensive", "hate", "racist", "sexist",
            "plagiarism", "copy", "stolen"
        ]
        return Set(terms.map { $0.lowercased() })
    }()

    private init() {}

    /// Returns true if text contains any banned term.
    func containsBannedTerm(_ text: String) -> Bool {
        let lower = text.lowercased()
        let words = lower.components(separatedBy: .whitespacesAndNewlines)
            .flatMap { $0.components(separatedBy: CharacterSet.punctuationCharacters) }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.count > 2 }

        for word in words {
            if bannedTerms.contains(word) { return true }
        }
        return false
    }
}
