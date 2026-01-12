import Foundation

// MARK: - Signal Note Type

enum SignalNoteType: String, Codable {
    case overExplaining
    case vagueImagery
    case weakSpeakerPosition
    case genericFlex
    case tooMuchDetail
    case defensiveTone
    case noSocialAction
    case emotionalSpill
    case unclearAudience
    case fillerLanguage
    case authorityWithoutEarning
    case overAbstracted
    case repetitiveSignal
    case moodCarryingLine
    case closureTooEarly
    
    var template: String {
        switch self {
        case .overExplaining:
            return "This line explains intent instead of letting the listener infer it. Authority drops when motives are stated."
        case .vagueImagery:
            return "The imagery sets a mood, but nothing is at risk. The listener doesn't know why this matters now."
        case .weakSpeakerPosition:
            return "The line sounds observational, not lived. It's unclear why you are the one saying this."
        case .genericFlex:
            return "This flex names success without showing consequence. It sounds interchangeable with anyone's verse."
        case .tooMuchDetail:
            return "Specifics here reduce mystique. Fewer details would read more intentional and confident."
        case .defensiveTone:
            return "This line answers a criticism the song hasn't received yet. That puts you on the back foot."
        case .noSocialAction:
            return "The line sounds good, but it isn't doing anything—no flex, no warning, no distance, no claim."
        case .emotionalSpill:
            return "The emotion is clear, but unfiltered. Restraint would make it land heavier."
        case .unclearAudience:
            return "It's not clear who this line is for. Narrowing the audience would sharpen the impact."
        case .fillerLanguage:
            return "Some words are carrying rhythm, not meaning. Cutting them would strengthen the signal."
        case .authorityWithoutEarning:
            return "The confidence jumps ahead of the story. The line needs proof or implication before the claim."
        case .overAbstracted:
            return "The idea is strong, but too abstract. One concrete anchor would ground it."
        case .repetitiveSignal:
            return "This repeats information the listener already has. Consider escalation or silence instead."
        case .moodCarryingLine:
            return "Atmosphere is doing the work here. A clearer position would make it memorable."
        case .closureTooEarly:
            return "The line resolves tension too fast. Leaving it open would increase replay value."
        }
    }
}

// MARK: - Signal Notes Generator

class SignalNotes {
    static let shared = SignalNotes()
    
    private init() {}
    
    // MARK: - Generate Signal Note
    
    func generateSignalNote(
        suggestion: RapSuggestion,
        evaluation: SignalEvaluation,
        mode: SignalMode
    ) -> String {
        // Determine dominant weakness
        let noteType = determineDominantWeakness(evaluation: evaluation, suggestion: suggestion, mode: mode)
        return noteType.template
    }
    
    // MARK: - Generate Notes for Multiple Suggestions
    
    func generateNotes(
        suggestions: [RapSuggestion],
        evaluations: [SignalEvaluation],
        mode: SignalMode
    ) -> [UUID: String] {
        var notes: [UUID: String] = [:]
        
        for (index, suggestion) in suggestions.enumerated() {
            if index < evaluations.count {
                let evaluation = evaluations[index]
                notes[suggestion.id] = generateSignalNote(
                    suggestion: suggestion,
                    evaluation: evaluation,
                    mode: mode
                )
            }
        }
        
        return notes
    }
    
    // MARK: - Determine Dominant Weakness
    
    private func determineDominantWeakness(
        evaluation: SignalEvaluation,
        suggestion: RapSuggestion,
        mode: SignalMode
    ) -> SignalNoteType {
        let text = suggestion.text.lowercased()
        
        // Check for specific patterns first (most specific)
        
        // Over-explaining
        if evaluation.reductionVsEscalation < 0.4 {
            let explanationMarkers = ["because", "since", "so that", "in order to", "that's why", "the reason"]
            for marker in explanationMarkers {
                if text.contains(marker) {
                    return .overExplaining
                }
            }
        }
        
        // Defensive tone
        if evaluation.authorityConsistency < 0.5 {
            let defensiveMarkers = ["i'm not saying", "i'm not trying", "it's not like", "you don't understand"]
            for marker in defensiveMarkers {
                if text.contains(marker) {
                    return .defensiveTone
                }
            }
        }
        
        // Emotional spill
        if evaluation.emotionalContainment < 0.4 {
            return .emotionalSpill
        }
        
        // Too much detail
        let wordCount = text.split(separator: " ").count
        var detailCount = 0
        let words = suggestion.text.split(separator: " ")
        for word in words {
            if word.first?.isUppercase == true && word.count > 1 {
                detailCount += 1
            }
        }
        if detailCount > 3 && wordCount > 30 {
            return .tooMuchDetail
        }
        
        // Weak speaker position
        if evaluation.authorityConsistency < 0.5 && !text.contains("i ") && !text.contains("i'm") {
            return .weakSpeakerPosition
        }
        
        // Generic flex
        let flexMarkers = ["i got", "i have", "i own", "i'm rich", "i'm the best"]
        var flexCount = 0
        for marker in flexMarkers {
            if text.contains(marker) {
                flexCount += 1
            }
        }
        if flexCount > 0 && evaluation.authorityConsistency < 0.6 {
            return .genericFlex
        }
        
        // Vague imagery
        let imageryMarkers = ["like", "as if", "seems", "appears", "feels like"]
        var imageryCount = 0
        for marker in imageryMarkers {
            if text.contains(marker) {
                imageryCount += 1
            }
        }
        if imageryCount > 2 && evaluation.authorityConsistency < 0.6 {
            return .vagueImagery
        }
        
        // No social action
        let actionMarkers = ["i warn", "i flex", "i claim", "i distance", "i withdraw"]
        var hasAction = false
        for marker in actionMarkers {
            if text.contains(marker) {
                hasAction = true
                break
            }
        }
        if !hasAction && wordCount > 15 {
            return .noSocialAction
        }
        
        // Filler language
        let fillerWords = ["just", "really", "very", "quite", "pretty", "sort of", "kind of"]
        var fillerCount = 0
        for filler in fillerWords {
            if text.contains(filler) {
                fillerCount += 1
            }
        }
        if fillerCount > 2 {
            return .fillerLanguage
        }
        
        // Authority without earning
        let authorityMarkers = ["i am", "i'm the", "i'm a", "i control", "i run"]
        var hasAuthority = false
        for marker in authorityMarkers {
            if text.contains(marker) {
                hasAuthority = true
                break
            }
        }
        if hasAuthority && evaluation.authorityConsistency < 0.6 {
            return .authorityWithoutEarning
        }
        
        // Over-abstracted
        let abstractMarkers = ["everything", "nothing", "all", "always", "never", "forever"]
        var abstractCount = 0
        for marker in abstractMarkers {
            if text.contains(marker) {
                abstractCount += 1
            }
        }
        if abstractCount > 2 && detailCount == 0 {
            return .overAbstracted
        }
        
        // Repetitive signal
        let lines = suggestion.text.components(separatedBy: "\n")
        if lines.count > 1 {
            let firstLineWords = Set(lines[0].lowercased().split(separator: " "))
            for line in lines[1...] {
                let lineWords = Set(line.lowercased().split(separator: " "))
                let overlap = firstLineWords.intersection(lineWords).count
                if overlap > 3 {
                    return .repetitiveSignal
                }
            }
        }
        
        // Mood carrying line
        if imageryCount > 1 && evaluation.authorityConsistency < 0.5 {
            return .moodCarryingLine
        }
        
        // Closure too early
        let closureMarkers = ["the end", "it's over", "that's it", "done", "finished"]
        for marker in closureMarkers {
            if text.contains(marker) && wordCount < 20 {
                return .closureTooEarly
            }
        }
        
        // Unclear audience (fallback)
        if evaluation.modeAdherence < 0.6 {
            return .unclearAudience
        }
        
        // Default: over-explaining (most common issue)
        return .overExplaining
    }
}

// MARK: - Convenience Extension

extension SignalNotes {
    static func generateNote(
        suggestion: RapSuggestion,
        evaluation: SignalEvaluation,
        mode: SignalMode
    ) -> String {
        return shared.generateSignalNote(suggestion: suggestion, evaluation: evaluation, mode: mode)
    }
}
