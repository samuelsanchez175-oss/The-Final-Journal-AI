//
//  HumanCriticFeedback.swift
//  XJournal AI
//
//  Structured listener feedback for Rap Suggestions (calm editor voice).
//

import Foundation

// MARK: - Models

enum CriticReactionPolarity: String, Codable {
    case positive
    case negative
    case mixed
}

struct CriticReaction: Codable, Equatable, Identifiable {
    var id: String { "\(polarity.rawValue)-\(quote)" }
    let polarity: CriticReactionPolarity
    let quote: String
    let note: String
}

struct HumanCriticFeedback: Codable, Equatable {
    let headline: String
    let reactions: [CriticReaction]
    let feelings: [String]
    let hookNote: String?
    let nextStep: String?

    enum CodingKeys: String, CodingKey {
        case headline
        case reactions
        case feelings
        case hookNote = "hook_note"
        case nextStep = "next_step"
    }

    var positiveReactions: [CriticReaction] {
        reactions.filter { $0.polarity == .positive }
    }

    var constructiveReactions: [CriticReaction] {
        reactions.filter { $0.polarity == .negative || $0.polarity == .mixed }
    }
}

// MARK: - Sanitization

enum HumanCriticSanitizer {
    private static let bannedTerms = [
        "register position",
        "signal profile",
        "alignment threshold",
        "signal mode",
        "axis profile",
        "posture difference",
        "authority difference",
        "lexicon gate",
        "information refusal",
        "uncontained vulnerability"
    ]

    static func sanitize(_ raw: HumanCriticFeedback, sourceCorpus: String) -> HumanCriticFeedback {
        let corpus = sourceCorpus.lowercased()
        let cleanedReactions = raw.reactions.compactMap { reaction -> CriticReaction? in
            let note = scrubJargon(reaction.note)
            guard !note.isEmpty else { return nil }
            var quote = reaction.quote.trimmingCharacters(in: .whitespacesAndNewlines)
            if !quote.isEmpty, !corpus.contains(quote.lowercased()) {
                quote = ""
            }
            return CriticReaction(polarity: reaction.polarity, quote: quote, note: note)
        }

        return HumanCriticFeedback(
            headline: scrubJargon(raw.headline),
            reactions: Array(cleanedReactions.prefix(4)),
            feelings: raw.feelings.map { scrubJargon($0) }.filter { !$0.isEmpty }.prefix(5).map { $0 },
            hookNote: raw.hookNote.map { scrubJargon($0) }.flatMap { $0.isEmpty ? nil : $0 },
            nextStep: raw.nextStep.map { scrubJargon($0) }.flatMap { $0.isEmpty ? nil : $0 }
        )
    }

    static func scrubJargon(_ text: String) -> String {
        var result = text
        for term in bannedTerms {
            result = result.replacingOccurrences(of: term, with: "", options: .caseInsensitive)
        }
        while result.contains("  ") {
            result = result.replacingOccurrences(of: "  ", with: " ")
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
