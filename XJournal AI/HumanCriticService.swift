//
//  HumanCriticService.swift
//  XJournal AI
//
//  LLM listener pass — calm editor voice (toggle in Model Preferences deferred).
//

import Foundation

enum HumanCriticVoice: String, CaseIterable {
    case calmEditor
    case friend
    case hype

    /// Label for the Model Preferences picker.
    var displayName: String {
        switch self {
        case .calmEditor: return "Calm editor"
        case .friend: return "Friend"
        case .hype: return "Hype"
        }
    }

    /// Persona line — the only thing that changes between voices. Shared rules + JSON schema follow.
    private var persona: String {
        switch self {
        case .calmEditor:
            return "You are a calm, trusted editor listening to a rapper's draft in the room. You react like a thoughtful human—not an A&R executive, therapist, or professor. Be specific and kind; if little works, say so honestly."
        case .friend:
            return "You are the writer's talented friend gassing up their draft in the studio—warm, casual, genuinely on their side. Lead with what's hitting and keep fixes light and encouraging; talk like a real one, not a coach."
        case .hype:
            return "You are a hype-man reacting to the writer's draft—loud, gassed, all energy. Big up the bangers and frame fixes as 'go even harder here'—but keep every reaction useful and specific."
        }
    }

    var systemPrompt: String {
        """
        \(persona)

        Rules:
        - Respond ONLY with valid JSON matching the schema below.
        - Quote short phrases (max 8 words) copied exactly from the user's verse or the AI suggestion.
        - Give 2–4 reactions total (mix of what worked and what could be stronger).
        - Use plain feelings words (e.g. hype, cold, funny, sad, tense, bored)—no jargon.
        - Never use: register position, signal profile, alignment, posture, axis, lexicon, information refusal.
        - Always end with one concrete next step. Do not moralize or lecture.

        JSON schema:
        {
          "headline": "one sentence overall take",
          "reactions": [
            { "polarity": "positive|negative|mixed", "quote": "short exact phrase", "note": "1-2 sentences" }
          ],
          "feelings": ["word1", "word2"],
          "hook_note": "optional — how this connects to their opening/hook, or empty string",
          "next_step": "one concrete thing to try next"
        }
        """
    }
}

final class HumanCriticService {
    static let shared = HumanCriticService()

    private init() {}

    func generate(
        userVerse: String,
        generatedSuggestion: String?,
        themes: [String] = [],
        voice: HumanCriticVoice = .calmEditor
    ) async throws -> HumanCriticFeedback {
        guard KeychainHelper.shared.getAPIKey() != nil else {
            throw RapAPIError.missingAPIKey
        }

        let hookLine = userVerse
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty } ?? ""

        let lastUserLine = userVerse
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0) }
            .last { !$0.trimmingCharacters(in: .whitespaces).isEmpty } ?? ""

        var userPrompt = """
        User's full verse:
        \(userVerse)

        User's last line before the suggestion:
        \(lastUserLine)
        """

        if let opening = hookLine.isEmpty ? nil : hookLine {
            userPrompt += "\n\nOpening line (treat as hook/theme anchor):\n\(opening)"
        }

        if let generated = generatedSuggestion?.trimmingCharacters(in: .whitespacesAndNewlines), !generated.isEmpty {
            userPrompt += "\n\nAI-suggested continuation:\n\(generated)"
        } else {
            userPrompt += "\n\nNo lines were generated this round. Explain why the draft might be hard to extend and what the writer could adjust—still in your voice."
        }

        if !themes.isEmpty {
            userPrompt += "\n\nThemes detected: \(themes.joined(separator: ", "))"
        }

        let rawJSON = try await ModelGLLMService.shared.fetchJSONCompletion(
            system: voice.systemPrompt,
            user: userPrompt,
            maxTokens: 520
        )

        let parsed = try parseFeedback(from: rawJSON)
        let corpus = userVerse + "\n" + (generatedSuggestion ?? "")
        return HumanCriticSanitizer.sanitize(parsed, sourceCorpus: corpus)
    }

    private func parseFeedback(from raw: String) throws -> HumanCriticFeedback {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let jsonString: String
        if let start = trimmed.firstIndex(of: "{"), let end = trimmed.lastIndex(of: "}") {
            jsonString = String(trimmed[start...end])
        } else {
            jsonString = trimmed
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw HumanCriticError.invalidJSON
        }

        do {
            return try JSONDecoder().decode(HumanCriticFeedback.self, from: data)
        } catch {
            throw HumanCriticError.invalidJSON
        }
    }
}

enum HumanCriticError: LocalizedError {
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "Couldn't read the critic response. Try again."
        }
    }
}
