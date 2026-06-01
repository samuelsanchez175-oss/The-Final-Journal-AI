//
//  IntentExtractorExtensions.swift
//  XJournal AI
//
//  Model G Core v1.0 — Extends app IntentExtractor with Model G–specific logic.
//

import Foundation

// MARK: - Line Classification

/// How to treat a user line during generation. Keep 2–4 original phrases when possible.
enum LineClassification {
    case preserve  // Use verbatim
    case remix    // Adapt/rework
    case replace  // Generate new
}

// MARK: - Model G Intent Extensions

extension IntentExtractor {

    /// Classify user lines as Preserve, Remix, or Replace.
    /// Keeps 2–4 original phrases when possible.
    static func classifyUserLines(_ lines: [String], intent: GenerationIntent) -> [(line: String, classification: LineClassification)] {
        guard !lines.isEmpty else { return [] }

        let mustIncludeLower = Set(intent.mustInclude.map { $0.lowercased() })
        let mustAvoidLower = Set(intent.mustAvoid.map { $0.lowercased() })
        let targetPreserveCount = min(4, max(2, lines.count / 2))

        var result: [(String, LineClassification)] = []
        var preserveCount = 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let words = Set(trimmed.lowercased().components(separatedBy: .whitespaces).filter { $0.count > 2 })
            let hasMustInclude = !words.isDisjoint(with: mustIncludeLower)
            let hasMustAvoid = !words.isDisjoint(with: mustAvoidLower)

            if hasMustAvoid {
                result.append((trimmed, .replace))
            } else if hasMustInclude && preserveCount < targetPreserveCount {
                result.append((trimmed, .preserve))
                preserveCount += 1
            } else if preserveCount < targetPreserveCount && trimmed.count < 60 {
                result.append((trimmed, .remix))
                preserveCount += 1
            } else {
                result.append((trimmed, .replace))
            }
        }

        return result
    }

    /// Phrases to preserve (2–4) for injection into generation.
    static func mustPreservePhrases(from classifications: [(line: String, classification: LineClassification)]) -> [String] {
        classifications
            .filter { $0.classification == .preserve || $0.classification == .remix }
            .prefix(4)
            .map { $0.line }
    }
}
