//
//  CascadeFormatter.swift
//  XJournal AI
//
//  Breaks a bar into stepped breath-chunks for the multi-line (large Dynamic Type)
//  reading layout — the accessibility fallback for the Rap Suggestions redesign
//  (spec §3.7). Pure + deterministic.
//

import Foundation

/// One breath/phrase chunk of a bar, with its step indentation (0, 1, 2, …).
struct CascadeChunk: Equatable {
    let text: String
    let indentLevel: Int
}

enum CascadeFormatter {
    /// Greedy: accumulate words until adding the next would exceed `maxSyllablesPerChunk`,
    /// or a word ends in a comma (hard breath), then start a new, deeper-indented chunk.
    static func chunks(for line: String, maxSyllablesPerChunk: Int = 5) -> [CascadeChunk] {
        let words = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard !words.isEmpty else { return [] }

        var chunks: [CascadeChunk] = []
        var current: [String] = []
        var currentSyllables = 0

        func flush() {
            guard !current.isEmpty else { return }
            chunks.append(CascadeChunk(text: current.joined(separator: " "), indentLevel: chunks.count))
            current = []
            currentSyllables = 0
        }

        for word in words {
            let syl = max(1, Syllabifier.syllableCount(word: word))
            if !current.isEmpty && currentSyllables + syl > maxSyllablesPerChunk {
                flush()
            }
            current.append(word)
            currentSyllables += syl
            if word.hasSuffix(",") {          // hard breath boundary
                flush()
            }
        }
        flush()
        return chunks
    }
}
