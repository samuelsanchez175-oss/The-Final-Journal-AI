//
//  IntentExtractor.swift
//  XJournal AI
//
//  Phase 0: Pre-Generation Intent Compression
//  Extracts the Emotional Spine from NarrativeAnalysis or topic-only input.
//  Everything generated must align with this spine.
//

import Foundation

// MARK: - Intent Tone

/// Intent-level tone for emotional spine alignment.
/// Maps from EmotionalTone but adds plan-specific values.
enum IntentTone: String, Codable {
    case confident
    case dark
    case reflective
    case toxic
    case victorious
    case numb
}

// MARK: - Intent Perspective

enum IntentPerspective: String, Codable {
    case flexing
    case reflecting
    case addressingSomeone
}

// MARK: - Intent Energy Level

enum IntentEnergyLevel: String, Codable {
    case high
    case medium
    case low
}

// MARK: - GenerationIntent

/// Structured intent object — the Emotional Spine.
/// Used to constrain generation and score intent consistency.
struct GenerationIntent {
    /// One-sentence core theme
    let theme: String
    /// Primary emotional tone
    let tone: IntentTone
    /// Narrative perspective
    let perspective: IntentPerspective
    /// Energy level
    let energyLevel: IntentEnergyLevel
    /// Concepts that must appear or be reinforced
    let mustInclude: [String]
    /// Tone/narrative shifts to avoid
    let mustAvoid: [String]
    
    /// Prompt fragment for injection into generation
    var promptFragment: String {
        var parts: [String] = []
        parts.append("EMOTIONAL SPINE (every bar must reinforce): \(theme)")
        parts.append("Tone: \(tone.rawValue). Perspective: \(perspective.rawValue).")
        if !mustInclude.isEmpty {
            parts.append("Must-include concepts: \(mustInclude.joined(separator: ", ")).")
        }
        if !mustAvoid.isEmpty {
            parts.append("Avoid: \(mustAvoid.joined(separator: "; ")).")
        }
        return parts.joined(separator: " ")
    }
}

// MARK: - Intent Extractor

enum IntentExtractor {
    
    /// Extract GenerationIntent from NarrativeAnalysis.
    /// Compresses narrative into emotional spine for alignment scoring.
    static func extract(from narrative: NarrativeAnalysis) -> GenerationIntent {
        let theme = compressTheme(narrative)
        let tone = mapTone(narrative.emotionalTone, detectedTones: narrative.detectedTones)
        let perspective = mapPerspective(narrative)
        let energyLevel = mapEnergyLevel(narrative)
        let mustInclude = buildMustInclude(narrative)
        let mustAvoid = buildMustAvoid(narrative)
        
        return GenerationIntent(
            theme: theme,
            tone: tone,
            perspective: perspective,
            energyLevel: energyLevel,
            mustInclude: mustInclude,
            mustAvoid: mustAvoid
        )
    }
    
    /// Extract intent from topic-only input (no prior text).
    /// Used when user provides only a topic.
    static func extractFromTopic(_ topic: String) -> GenerationIntent {
        let theme = topic.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ? "Continue in melodic trap style with luxury flex and smooth flow" : topic
        return GenerationIntent(
            theme: theme,
            tone: .confident,
            perspective: .flexing,
            energyLevel: .medium,
            mustInclude: extractKeywords(from: topic),
            mustAvoid: ["generic party flex disconnected from theme", "random luxury flex without context"]
        )
    }
    
    // MARK: - Theme Compression
    
    private static func compressTheme(_ narrative: NarrativeAnalysis) -> String {
        if narrative.summary.count > 10 {
            return narrative.summary
        }
        let themes = narrative.primaryThemes + narrative.secondaryThemes
        let themeStr = themes.prefix(3).joined(separator: ", ")
        return "A \(narrative.emotionalTone.rawValue) narrative focused on \(themeStr)."
    }
    
    // MARK: - Tone Mapping
    
    private static func mapTone(_ emotionalTone: EmotionalTone, detectedTones: [EmotionalTone]) -> IntentTone {
        let primary = emotionalTone
        switch primary {
        case .confident: return .confident
        case .aggressive: return .toxic
        case .melancholic: return .dark
        case .reflective: return .reflective
        case .detached: return .numb
        case .hopeful: return .victorious
        case .resentful: return .toxic
        case .neutral:
            if detectedTones.contains(.confident) { return .confident }
            if detectedTones.contains(.melancholic) { return .dark }
            if detectedTones.contains(.reflective) { return .reflective }
            return .confident
        }
    }
    
    // MARK: - Perspective Mapping
    
    private static func mapPerspective(_ narrative: NarrativeAnalysis) -> IntentPerspective {
        guard let voiceType = narrative.voiceType?.lowercased() else {
            return .flexing
        }
        if voiceType.contains("vulnerable") || voiceType.contains("introspective") {
            return .reflecting
        }
        if narrative.primaryThemes.contains(where: { $0.lowercased().contains("loyalty") || $0.lowercased().contains("betrayal") }) {
            return .addressingSomeone
        }
        return .flexing
    }
    
    // MARK: - Energy Level
    
    private static func mapEnergyLevel(_ narrative: NarrativeAnalysis) -> IntentEnergyLevel {
        guard let style = narrative.styleCharacteristics else { return .medium }
        switch style.energyLevel?.lowercased() {
        case "high": return .high
        case "low": return .low
        default: return .medium
        }
    }
    
    // MARK: - Must-Include
    
    private static func buildMustInclude(_ narrative: NarrativeAnalysis) -> [String] {
        var items: [String] = []
        items.append(contentsOf: narrative.primaryThemes.prefix(2))
        items.append(contentsOf: narrative.secondaryThemes.prefix(1))
        if let keyPhrases = narrative.keyPhrases {
            items.append(contentsOf: keyPhrases.prefix(3))
        }
        if let storyElements = narrative.storyElements {
            items.append(contentsOf: storyElements.prefix(2))
        }
        return Array(Set(items.map { $0.lowercased() })).prefix(5).map { $0 }
    }
    
    // MARK: - Must-Avoid
    
    private static func buildMustAvoid(_ narrative: NarrativeAnalysis) -> [String] {
        var items: [String] = ["generic party flex disconnected from theme"]
        if narrative.emotionalTone == .reflective || narrative.emotionalTone == .melancholic {
            items.append("random luxury flex unless metaphorically aligned with emotional arc")
        }
        if let contradictions = narrative.thematicContradictions {
            for c in contradictions.prefix(2) {
                items.append("contradicting: \(c)")
            }
        }
        return items
    }
    
    private static func extractKeywords(from topic: String) -> [String] {
        let words = topic.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 2 }
        return Array(words.prefix(5))
    }
}
