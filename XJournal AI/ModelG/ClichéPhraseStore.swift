//
//  ClichéPhraseStore.swift
//  XJournal AI
//
//  Model G Core v1.0 — Cliché phrases for hard rejection.
//

import Foundation

/// Cliché phrases that trigger hard rejection. Start with small curated list.
class ClichéPhraseStore {
    static let shared = ClichéPhraseStore()

    private let clichéPhrases: [String] = {
        [
            "living my best life",
            "it is what it is",
            "at the end of the day",
            "main character energy",
            "built different",
            "and that's on period",
            "vibes only"
        ].map { $0.lowercased() }
    }()

    private init() {}

    /// Returns true if text contains a cliché phrase.
    func containsCliché(_ text: String) -> Bool {
        let lower = text.lowercased()
        for phrase in clichéPhrases {
            if lower.contains(phrase) { return true }
        }
        return false
    }
}
