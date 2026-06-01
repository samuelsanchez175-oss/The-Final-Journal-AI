//
//  NoteSuggestionSession.swift
//  XJournal AI
//
//  Persists the last AI suggestion batch per note so "Open Last Suggestions"
//  works after leaving the note or restarting the app.
//

import Foundation
import SwiftData

// MARK: - Session payload

struct NoteSuggestionSession: Codable {
    var savedAt: Date
    var generationId: UUID
    var contextText: String
    /// The most recent generation batch (what "Open Last Suggestions" shows).
    var lastBatchSuggestions: [RapSuggestion]
    /// Rolling history across generations on this note (capped).
    var suggestionHistory: [RapSuggestion]
    var silenceCommentary: CriticCommentary?
    var isParallelModelG: Bool
    var suggestionsV1: [RapSuggestion]
    var suggestionsV2: [RapSuggestion]
    var modelRaw: String?
    var humanCritic: HumanCriticFeedback?

    static let historyCap = 50

    var hasRecallableBatch: Bool {
        silenceCommentary != nil
            || !lastBatchSuggestions.isEmpty
            || (isParallelModelG && (!suggestionsV1.isEmpty || !suggestionsV2.isEmpty))
    }
}

// MARK: - Persistence on Item

enum NoteSuggestionSessionStore {

    static func noteKey(for item: Item) -> String {
        String(describing: item.persistentModelID)
    }

    static func load(from item: Item) -> NoteSuggestionSession? {
        guard let data = item.lastSuggestionSessionData else { return nil }
        return try? JSONDecoder().decode(NoteSuggestionSession.self, from: data)
    }

    static func hasSession(on item: Item) -> Bool {
        load(from: item)?.hasRecallableBatch == true
    }

    @MainActor
    static func save(from engine: RapSuggestionEngine, contextText: String, model: SuggestionModel, to item: Item) {
        let batch = engine.lastBatchSuggestions
        let parallel = engine.isParallelModelG
        let hasSilence = engine.silenceCommentary != nil
        guard hasSilence
            || !batch.isEmpty
            || (parallel && (!engine.suggestionsV1.isEmpty || !engine.suggestionsV2.isEmpty)) else {
            return
        }

        var history = engine.previousSuggestions
        if history.count > NoteSuggestionSession.historyCap {
            history = Array(history.suffix(NoteSuggestionSession.historyCap))
        }

        let session = NoteSuggestionSession(
            savedAt: Date(),
            generationId: engine.lastSessionGenerationId ?? UUID(),
            contextText: contextText,
            lastBatchSuggestions: batch,
            suggestionHistory: history,
            silenceCommentary: engine.silenceCommentary,
            isParallelModelG: parallel,
            suggestionsV1: engine.suggestionsV1,
            suggestionsV2: engine.suggestionsV2,
            modelRaw: model.rawValue,
            humanCritic: engine.humanCriticFeedback
        )

        if let data = try? JSONEncoder().encode(session) {
            item.lastSuggestionSessionData = data
            item.modifiedDate = Date()
            try? item.modelContext?.save()
        }
    }

    @MainActor
    static func apply(_ session: NoteSuggestionSession, to engine: RapSuggestionEngine) {
        engine.lastSessionGenerationId = session.generationId
        engine.lastSessionContextText = session.contextText
        engine.lastBatchSuggestions = session.lastBatchSuggestions
        engine.previousSuggestions = session.suggestionHistory
        engine.silenceCommentary = session.silenceCommentary
        engine.isParallelModelG = session.isParallelModelG
        engine.suggestionsV1 = session.suggestionsV1
        engine.suggestionsV2 = session.suggestionsV2
        engine.suggestions = session.lastBatchSuggestions
        engine.humanCriticFeedback = session.humanCritic
        engine.humanCriticLoading = false
        engine.humanCriticError = nil
    }

    /// Suggestions to display when recalling the last session for this note.
    static func recallSuggestions(from session: NoteSuggestionSession) -> [RapSuggestion] {
        if session.isParallelModelG {
            return session.lastBatchSuggestions.isEmpty
                ? session.suggestionsV1 + session.suggestionsV2
                : session.lastBatchSuggestions
        }
        return session.lastBatchSuggestions
    }
}
