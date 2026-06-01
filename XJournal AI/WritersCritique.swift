import Foundation

// MARK: - Writers Critique

struct WritersCritique {
    let mode: SignalMode
    let modeExplanation: String  // "You're processing out loud, not positioning"
    let whatIsAllowed: String    // "Single emotional admission is fine"
    let whatIsUnsafe: String     // "Repeating the same grievance weakens authority"
    let whatIsPremature: String  // "Don't claim closure when you're still explaining"
    let fullCritique: String     // Combined 2-3 sentence explanation
}

// MARK: - Line Comparison (PR 5)

struct LineComparison {
    let userLine: String
    let generatedLine: String
    let commentary: String  // A&R-style commentary on differences
    let postureDifference: String?  // How posture differs
    let authorityDifference: String?  // How authority differs
    let effectDifference: String?  // How effect differs
    let whySuggested: String?  // Why these new lines were suggested
    let previousLineCritique: String?  // What revisions/critiques the previous lines need
    let contextInfo: String  // How much context was used (bars, lines, etc.)
}

// MARK: - Writers Critique Generator

class WritersCritiqueGenerator {
    static let shared = WritersCritiqueGenerator()
    
    private init() {}
    
    // MARK: - Generate Critique
    
    func generateCritique(for mode: SignalMode, profile: SignalProfile) -> WritersCritique {
        let modeExplanation = explainModeInWritersRoomLanguage(mode: mode, profile: profile)
        let whatIsAllowed = explainWhatIsAllowed(mode: mode)
        let whatIsUnsafe = explainWhatIsUnsafe(mode: mode)
        let whatIsPremature = explainWhatIsPremature(mode: mode)
        
        // Combine into 2-3 sentence full critique
        let fullCritique = buildFullCritique(
            modeExplanation: modeExplanation,
            whatIsAllowed: whatIsAllowed,
            whatIsUnsafe: whatIsUnsafe,
            whatIsPremature: whatIsPremature
        )
        
        return WritersCritique(
            mode: mode,
            modeExplanation: modeExplanation,
            whatIsAllowed: whatIsAllowed,
            whatIsUnsafe: whatIsUnsafe,
            whatIsPremature: whatIsPremature,
            fullCritique: fullCritique
        )
    }
    
    // MARK: - Mode Explanation (Writer's Room Language)
    
    private func explainModeInWritersRoomLanguage(mode: SignalMode, profile: SignalProfile) -> String {
        switch mode {
        case .uncontainedVulnerability:
            return "You're processing out loud, not positioning. The emotion is real but unfiltered."
            
        case .informationRefusal:
            return "You're holding back details on purpose. Mystery is the point."
            
        case .noRepair:
            return "This relationship is closed. Don't reopen it."
            
        case .voluntaryIsolation:
            return "You're creating distance without anger. Calm separation, not conflict."
            
        case .lossAcknowledgmentWithoutAttribution:
            return "You're acknowledging the loss without naming who caused it. The pain is real, but blame stays implied."
            
        case .declarativeClosureWithoutEvidence:
            return "You're making a final statement without backing it up. The declaration stands on its own."
            
        case .postChaosStabilization:
            return "You're stabilizing after chaos. Focus on structure, not drama."
            
        case .defaultExpressive:
            return "You're exploring freely. No heavy constraints."
        }
    }
    
    // MARK: - What Is Allowed
    
    private func explainWhatIsAllowed(mode: SignalMode) -> String {
        switch mode {
        case .uncontainedVulnerability:
            return "Single emotional admission is fine. Abstract pain language works."
            
        case .informationRefusal:
            return "Ambiguity is allowed. Implication over statement."
            
        case .noRepair:
            return "Closure language is allowed. Finality without negotiation."
            
        case .voluntaryIsolation:
            return "Distance language is allowed. Separation without conflict."
            
        case .lossAcknowledgmentWithoutAttribution:
            return "Loss acknowledgment is allowed. Pain without perpetrator."
            
        case .declarativeClosureWithoutEvidence:
            return "Declarative statements are allowed. Finality without proof."
            
        case .postChaosStabilization:
            return "Structure and logistics are allowed. Function over form."
            
        case .defaultExpressive:
            return "Everything is allowed. Write what feels right."
        }
    }
    
    // MARK: - What Is Unsafe
    
    private func explainWhatIsUnsafe(mode: SignalMode) -> String {
        switch mode {
        case .uncontainedVulnerability:
            return "Repeating the same grievance weakens authority. Emotional redundancy erodes your position."
            
        case .informationRefusal:
            return "Explaining why breaks the mystery. Justification kills the signal."
            
        case .noRepair:
            return "Reopening the relationship puts you on the back foot. Apologies and outreach are unsafe."
            
        case .voluntaryIsolation:
            return "Hostile language breaks the calm. Accusation turns distance into conflict."
            
        case .lossAcknowledgmentWithoutAttribution:
            return "Naming who caused it breaks the containment. Attribution language is unsafe."
            
        case .declarativeClosureWithoutEvidence:
            return "Backing up the statement weakens it. Evidence and justification are unsafe."
            
        case .postChaosStabilization:
            return "Drama and spectacle are unsafe. Emotional display breaks the structure."
            
        case .defaultExpressive:
            return "Nothing is unsafe. You're free to explore."
        }
    }
    
    // MARK: - What Is Premature
    
    private func explainWhatIsPremature(mode: SignalMode) -> String {
        switch mode {
        case .uncontainedVulnerability:
            return "Don't claim closure when you're still explaining. Authority comes from containment, not premature resolution."
            
        case .informationRefusal:
            return "Don't explain the mystery. Premature clarity kills the signal."
            
        case .noRepair:
            return "Don't try to repair what's closed. Premature outreach weakens the closure."
            
        case .voluntaryIsolation:
            return "Don't justify the exit. Premature explanation breaks the calm distance."
            
        case .lossAcknowledgmentWithoutAttribution:
            return "Don't name the cause. Premature attribution breaks the containment."
            
        case .declarativeClosureWithoutEvidence:
            return "Don't back up the statement. Premature evidence weakens the declaration."
            
        case .postChaosStabilization:
            return "Don't return to drama. Premature spectacle breaks the structure."
            
        case .defaultExpressive:
            return "Nothing is premature. You're free to explore."
        }
    }
    
    // MARK: - Build Full Critique
    
    private func buildFullCritique(
        modeExplanation: String,
        whatIsAllowed: String,
        whatIsUnsafe: String,
        whatIsPremature: String
    ) -> String {
        // Combine into 2-3 sentences, A&R tone
        // Focus on what's allowed/unsafe/premature, not what's "good"
        
        var sentences: [String] = []
        
        // Start with mode explanation
        sentences.append(modeExplanation)
        
        // Add what's unsafe or premature (most important for teaching)
        if !whatIsUnsafe.contains("Nothing is unsafe") {
            // Extract the key unsafe behavior
            if whatIsUnsafe.contains("Repeating") {
                sentences.append("Authority drops when you repeat the same feeling.")
            } else if whatIsUnsafe.contains("Explaining") {
                sentences.append("Don't explain why—let them infer.")
            } else if whatIsUnsafe.contains("Reopening") {
                sentences.append("The door is shut—keep it shut.")
            } else if whatIsUnsafe.contains("Hostile") {
                sentences.append("No need to justify the exit.")
            } else if whatIsUnsafe.contains("Naming") {
                sentences.append("Blame stays implied.")
            } else if whatIsUnsafe.contains("Backing up") {
                sentences.append("No justification needed.")
            } else if whatIsUnsafe.contains("Drama") {
                sentences.append("Logistics over emotion.")
            }
        }
        
        // If we only have one sentence, add a practical note
        if sentences.count == 1 {
            if modeExplanation.contains("processing out loud") {
                sentences.append("Containment teaches authority.")
            } else if modeExplanation.contains("holding back") {
                sentences.append("Mystery is the point.")
            } else if modeExplanation.contains("closed") {
                sentences.append("Don't reopen it with apologies or outreach.")
            } else if modeExplanation.contains("distance") {
                sentences.append("Calm separation, not conflict.")
            } else if modeExplanation.contains("loss") {
                sentences.append("The pain is real, but blame stays implied.")
            } else if modeExplanation.contains("final statement") {
                sentences.append("The declaration stands on its own—no justification needed.")
            } else if modeExplanation.contains("stabilizing") {
                sentences.append("Logistics over emotion.")
            }
        }
        
        return sentences.joined(separator: " ")
    }
    
    // MARK: - Line Comparison (PR 5)
    
    /// Compare user line vs generated line and provide A&R-style commentary
    /// Focuses on posture, authority, and effect differences
    /// MUST quote user line vs generated line beneath output
    func compareLines(
        userLine: String,
        generatedLine: String,
        mode: SignalMode,
        profile: SignalProfile,
        suggestionReasoning: String? = nil,
        previousLines: [String] = [],
        fullTextLineCount: Int = 0,
        contextLineCount: Int = 0,
        axes: SignalAxes? = nil,
        strengthMode: StrengthMode? = nil
    ) -> LineComparison {
        // Check Strength Mode
        let isStrengthMode = strengthMode?.isActive ?? false
        
        // Analyze lexicon fit/block for generated line
        let lexiconFeedback = analyzeLexiconFit(
            line: generatedLine,
            userLine: userLine,
            axes: axes,
            profile: profile,
            isStrengthMode: isStrengthMode
        )
        
        // Analyze differences in posture, authority, and effect
        let postureDiff = analyzePostureDifference(userLine: userLine, generatedLine: generatedLine, mode: mode)
        let authorityDiff = analyzeAuthorityDifference(userLine: userLine, generatedLine: generatedLine, profile: profile)
        let effectDiff = analyzeEffectDifference(userLine: userLine, generatedLine: generatedLine, mode: mode)
        
        // Critique previous lines (what revisions they need)
        let previousCritique = critiquePreviousLines(previousLines: previousLines, mode: mode, profile: profile)
        
        // Build why suggested explanation
        let whySuggested = buildWhySuggested(
            reasoning: suggestionReasoning,
            mode: mode,
            profile: profile
        )
        
        // Build context information
        let contextInfo = buildContextInfo(
            fullTextLineCount: fullTextLineCount,
            contextLineCount: contextLineCount
        )
        
        // Build A&R-style commentary (include lexicon feedback)
        let commentary = buildComparisonCommentary(
            userLine: userLine,
            generatedLine: generatedLine,
            postureDiff: postureDiff,
            authorityDiff: authorityDiff,
            effectDiff: effectDiff,
            whySuggested: whySuggested,
            previousCritique: previousCritique,
            lexiconFeedback: lexiconFeedback,
            isStrengthMode: isStrengthMode
        )
        
        return LineComparison(
            userLine: userLine,
            generatedLine: generatedLine,
            commentary: commentary,
            postureDifference: postureDiff,
            authorityDifference: authorityDiff,
            effectDifference: effectDiff,
            whySuggested: whySuggested,
            previousLineCritique: previousCritique,
            contextInfo: contextInfo
        )
    }
    
    private func analyzePostureDifference(userLine: String, generatedLine: String, mode: SignalMode) -> String? {
        // Analyze how posture differs between user and generated line
        // For now, provide mode-specific analysis
        
        switch mode {
        case .noRepair:
            if generatedLine.lowercased().contains("sorry") || generatedLine.lowercased().contains("apolog") {
                return "Generated line shifts toward repair language, but your line maintains closure."
            }
        case .voluntaryIsolation:
            if generatedLine.lowercased().contains("hate") || generatedLine.lowercased().contains("angry") {
                return "Generated line introduces hostility, but your line maintains calm distance."
            }
        case .uncontainedVulnerability:
            // Check for emotional repetition
            let userEmotionWords = countEmotionWords(userLine)
            let genEmotionWords = countEmotionWords(generatedLine)
            if genEmotionWords > userEmotionWords + 1 {
                return "Generated line increases emotional density, which may weaken authority."
            }
        default:
            break
        }
        
        return nil
    }
    
    private func analyzeAuthorityDifference(userLine: String, generatedLine: String, profile: SignalProfile) -> String? {
        // Analyze authority markers
        let userAuthority = countAuthorityMarkers(userLine)
        let genAuthority = countAuthorityMarkers(generatedLine)
        
        if userAuthority > genAuthority + 1 {
            return "Your line has stronger authority markers. Generated line is more tentative."
        } else if genAuthority > userAuthority + 1 {
            return "Generated line increases authority, which may not match your current posture."
        }
        
        return nil
    }
    
    private func analyzeEffectDifference(userLine: String, generatedLine: String, mode: SignalMode) -> String? {
        // Analyze overall effect/impact
        // For now, provide mode-specific observations
        
        switch mode {
        case .informationRefusal:
            if generatedLine.lowercased().contains("because") || generatedLine.lowercased().contains("explain") {
                return "Generated line adds explanation, which breaks the mystery you're maintaining."
            }
        case .declarativeClosureWithoutEvidence:
            if generatedLine.lowercased().contains("because") || generatedLine.lowercased().contains("proof") {
                return "Generated line adds justification, which weakens the declarative stance."
            }
        default:
            break
        }
        
        return nil
    }
    
    private func buildComparisonCommentary(
        userLine: String,
        generatedLine: String,
        postureDiff: String?,
        authorityDiff: String?,
        effectDiff: String?,
        whySuggested: String?,
        previousCritique: String?,
        lexiconFeedback: String? = nil,
        isStrengthMode: Bool = false
    ) -> String {
        var commentary: [String] = []
        
        // Quote both lines
        commentary.append("Your last line: \"\(userLine)\"")
        commentary.append("Generated: \"\(generatedLine)\"")
        commentary.append("")
        
        // Why these lines were suggested
        if let why = whySuggested {
            commentary.append("Why suggested: \(why)")
            commentary.append("")
        }
        
        // What revisions previous lines need
        if let previous = previousCritique {
            commentary.append("Previous lines need: \(previous)")
            commentary.append("")
        }
        
        // Add lexicon feedback (if available)
        if let lexicon = lexiconFeedback {
            commentary.append("Lexicon: \(lexicon)")
            commentary.append("")
        }
        
        // Add differences
        if let posture = postureDiff {
            commentary.append("Posture: \(posture)")
        }
        if let authority = authorityDiff {
            commentary.append("Authority: \(authority)")
        }
        if let effect = effectDiff {
            commentary.append("Effect: \(effect)")
        }
        
        // If no specific differences, provide general observation
        if commentary.count <= 3 {
            commentary.append("Both lines maintain similar posture and authority. Generated line continues your narrative stance.")
        }
        
        // In Strength Mode, cap to 1-2 sentences and use whitelisted vocabulary
        if isStrengthMode {
            return applyStrengthModeConstraints(commentary: commentary.joined(separator: "\n"))
        }
        
        return commentary.joined(separator: "\n")
    }
    
    // MARK: - Lexicon Analysis
    
    private func analyzeLexiconFit(
        line: String,
        userLine: String,
        axes: SignalAxes?,
        profile: SignalProfile,
        isStrengthMode: Bool
    ) -> String? {
        // TODO: Implement lexicon fit analysis
        // For now, return nil (no lexicon feedback)
        return nil
    }
    
    // MARK: - Strength Mode Constraints
    
    private func applyStrengthModeConstraints(commentary: String) -> String {
        // In Strength Mode, cap commentary to 1-2 sentences
        let sentences = commentary.components(separatedBy: ". ")
        if sentences.count > 2 {
            return sentences.prefix(2).joined(separator: ". ") + "."
        }
        return commentary
    }
    
    /// Critique what revisions the previous lines need
    private func critiquePreviousLines(previousLines: [String], mode: SignalMode, profile: SignalProfile) -> String? {
        guard !previousLines.isEmpty else { return nil }
        
        let lastLines = previousLines.suffix(4).joined(separator: " ")
        let critique = WritersCritiqueGenerator.shared.generateCritique(for: mode, profile: profile)
        
        // Build specific critique based on mode
        switch mode {
        case .noRepair:
            if lastLines.lowercased().contains("sorry") || lastLines.lowercased().contains("apolog") {
                return "Remove repair language. Your position is closure—no reconciliation needed."
            }
        case .voluntaryIsolation:
            if lastLines.lowercased().contains("hate") || lastLines.lowercased().contains("angry") {
                return "Remove hostility. Maintain calm distance without conflict."
            }
        case .uncontainedVulnerability:
            let emotionCount = countEmotionWords(lastLines)
            if emotionCount > 3 {
                return "Reduce emotional repetition. Single admission is stronger than multiple."
            }
        case .informationRefusal:
            if lastLines.lowercased().contains("because") || lastLines.lowercased().contains("explain") {
                return "Remove explanation. Mystery is the point—let them infer."
            }
        case .declarativeClosureWithoutEvidence:
            if lastLines.lowercased().contains("because") || lastLines.lowercased().contains("proof") {
                return "Remove justification. The declaration stands on its own."
            }
        default:
            break
        }
        
        // General critique from WritersCritique
        if !critique.whatIsUnsafe.contains("Nothing is unsafe") {
            return critique.whatIsUnsafe
        }
        
        return nil
    }
    
    /// Build explanation of why these lines were suggested
    private func buildWhySuggested(reasoning: String?, mode: SignalMode, profile: SignalProfile) -> String {
        if let reasoning = reasoning, !reasoning.isEmpty {
            return reasoning
        }
        
        // Build explanation based on mode and profile
        switch mode {
        case .noRepair:
            return "These lines maintain closure without repair language, matching your no-repair position."
        case .voluntaryIsolation:
            return "These lines create distance without hostility, matching your isolation stance."
        case .uncontainedVulnerability:
            return "These lines contain emotion without repetition, maintaining single admission."
        case .informationRefusal:
            return "These lines maintain ambiguity and mystery, avoiding explanation."
        case .declarativeClosureWithoutEvidence:
            return "These lines maintain declarative stance without justification."
        case .postChaosStabilization:
            return "These lines focus on structure and logistics, avoiding drama."
        default:
            return "These lines continue your narrative while maintaining your register position."
        }
    }
    
    /// Build context information string
    private func buildContextInfo(fullTextLineCount: Int, contextLineCount: Int) -> String {
        if fullTextLineCount > 0 && contextLineCount > 0 {
            return "Using full verse (\(fullTextLineCount) lines) for analysis, last \(contextLineCount) lines for immediate context."
        } else if fullTextLineCount > 0 {
            return "Using full verse (\(fullTextLineCount) lines) for analysis."
        } else if contextLineCount > 0 {
            return "Using last \(contextLineCount) lines for context."
        }
        return "Context information not available."
    }
    
    private func countEmotionWords(_ text: String) -> Int {
        let emotionWords = ["hurt", "pain", "angry", "sad", "upset", "love", "hate", "feel", "feeling", "emotional", "crying", "tears", "broken"]
        let lowercased = text.lowercased()
        return emotionWords.filter { lowercased.contains($0) }.count
    }
    
    private func countAuthorityMarkers(_ text: String) -> Int {
        let authorityMarkers = ["I am", "I'm", "I got", "I have", "I own", "I control", "I run", "I lead", "I make", "I decide", "I know", "I see", "I understand"]
        let lowercased = text.lowercased()
        return authorityMarkers.filter { lowercased.contains($0) }.count
    }
}

// MARK: - Convenience Extension

extension WritersCritiqueGenerator {
    static func generateCritique(for mode: SignalMode, profile: SignalProfile) -> WritersCritique {
        return shared.generateCritique(for: mode, profile: profile)
    }
    
    static func compareLines(
        userLine: String,
        generatedLine: String,
        mode: SignalMode,
        profile: SignalProfile,
        suggestionReasoning: String? = nil,
        previousLines: [String] = [],
        fullTextLineCount: Int = 0,
        contextLineCount: Int = 0,
        axes: SignalAxes? = nil,
        strengthMode: StrengthMode? = nil
    ) -> LineComparison {
        return shared.compareLines(
            userLine: userLine,
            generatedLine: generatedLine,
            mode: mode,
            profile: profile,
            suggestionReasoning: suggestionReasoning,
            previousLines: previousLines,
            fullTextLineCount: fullTextLineCount,
            contextLineCount: contextLineCount,
            axes: axes,
            strengthMode: strengthMode
        )
    }
}
