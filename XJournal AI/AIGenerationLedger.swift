//
//  AIGenerationLedger.swift
//  XJournal AI
//
//  Records every suggestion generation (outputs + context) for grading and taste learning.
//

import Foundation

struct AIGenerationRecord: Codable, Identifiable {
    let id: UUID
    let noteKey: String
    let noteTitle: String
    let savedAt: Date
    let contextText: String
    let modelRaw: String
    let suggestionTexts: [String]
    let suggestionIds: [UUID]
    let wasSilence: Bool
    var aggregateGrade: GenerationGrade?

    enum GenerationGrade: String, Codable {
        case helpful
        case mixed
        case notHelpful
        case inserted // at least one line inserted into the note
    }
}

enum AIGenerationLedger {
    private static let storageKey = "ai_generation_ledger"
    private static let limit = 500

    static func record(
        generationId: UUID,
        noteKey: String,
        noteTitle: String,
        contextText: String,
        model: SuggestionModel,
        suggestions: [RapSuggestion],
        silence: Bool
    ) {
        var records = load()
        let entry = AIGenerationRecord(
            id: generationId,
            noteKey: noteKey,
            noteTitle: noteTitle,
            savedAt: Date(),
            contextText: contextText,
            modelRaw: model.rawValue,
            suggestionTexts: suggestions.map(\.text),
            suggestionIds: suggestions.map(\.id),
            wasSilence: silence,
            aggregateGrade: nil
        )
        records.append(entry)
        if records.count > limit {
            records = Array(records.suffix(limit))
        }
        save(records)
    }

    static func markInserted(generationId: UUID, suggestionId: UUID) {
        var records = load()
        guard let index = records.firstIndex(where: { $0.id == generationId }) else { return }
        if records[index].aggregateGrade != .inserted {
            records[index].aggregateGrade = .inserted
        }
        save(records)
    }

    static func applyFeedbackGrade(generationId: UUID?, suggestionId: UUID, feedback: RapSuggestion.SuggestionFeedback) {
        guard let generationId else { return }
        var records = load()
        guard let index = records.firstIndex(where: { $0.id == generationId }) else { return }
        switch feedback {
        case .liked:
            if records[index].aggregateGrade == nil || records[index].aggregateGrade == .notHelpful {
                records[index].aggregateGrade = .helpful
            }
        case .disliked:
            if records[index].aggregateGrade == nil || records[index].aggregateGrade == .helpful {
                records[index].aggregateGrade = .mixed
            }
        }
        save(records)
    }

    static func recent(limit: Int = 50) -> [AIGenerationRecord] {
        Array(load().suffix(limit))
    }

    static func forNote(_ noteKey: String, limit: Int = 20) -> [AIGenerationRecord] {
        Array(load().filter { $0.noteKey == noteKey }.suffix(limit))
    }

    private static func load() -> [AIGenerationRecord] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([AIGenerationRecord].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func save(_ records: [AIGenerationRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

// MARK: - Taste prompt fragment

enum UserTasteInsights {

    /// Short block for system prompts — learned from grades + thumbs.
    static func promptFragment(noteKey: String? = nil) -> String? {
        let stats = SuggestionFeedbackManager.shared.getFeedbackStats()
        guard stats.totalFeedback >= 2 else { return nil }

        var lines: [String] = []
        lines.append("USER TASTE (from past ratings on this device — honor this):")

        if stats.acceptanceRate >= 0.6 {
            lines.append("- User often accepts suggestions; keep confidence and specificity high.")
        } else if stats.acceptanceRate <= 0.35 {
            lines.append("- User often rejects suggestions; be stricter on rhyme, voice match, and avoiding generic flex.")
        }

        let patterns = linePatterns()
        if !patterns.liked.isEmpty {
            lines.append("- Lines/phrases they liked: \(patterns.liked.prefix(8).joined(separator: "; "))")
        }
        if !patterns.disliked.isEmpty {
            lines.append("- Avoid patterns they disliked: \(patterns.disliked.prefix(8).joined(separator: "; "))")
        }

        if let noteKey, let noteFeedback = noteScopedFeedback(noteKey: noteKey), !noteFeedback.isEmpty {
            lines.append("- On this note recently: \(noteFeedback)")
        }

        let analysis = FeedbackAnalysisEngine.shared.analyzeFeedbackPatterns()
        if let top = analysis.commonIssues.first, top.percentage > 0.2 {
            lines.append("- Recurring issue to fix: \(top.category.displayName) (\(Int(top.percentage * 100))% of dislikes).")
        }

        return lines.joined(separator: "\n")
    }

    private static func linePatterns() -> (liked: [String], disliked: [String]) {
        let recent = SuggestionFeedbackManager.shared.getRecentFeedback(limit: 80)
        var liked: [String] = []
        var disliked: [String] = []
        for entry in recent {
            if let ev = entry.expectedVsActual, ev.contains("Liked lines:") {
                liked.append(contentsOf: ev.replacingOccurrences(of: "Liked lines: ", with: "").split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) })
            }
            for issue in entry.specificIssues where issue.contains("Line ") {
                disliked.append(issue)
            }
        }
        return (liked, disliked)
    }

    private static func noteScopedFeedback(noteKey: String) -> String? {
        let entries = SuggestionFeedbackManager.shared.feedback(forNoteKey: noteKey, limit: 10)
        guard !entries.isEmpty else { return nil }
        let likes = entries.filter { $0.feedback == .liked }.count
        let dislikes = entries.filter { $0.feedback == .disliked }.count
        return "\(likes) liked, \(dislikes) disliked in recent sessions on this note."
    }
}
