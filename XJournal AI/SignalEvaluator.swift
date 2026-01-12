import Foundation

// MARK: - Signal Evaluation

struct SignalEvaluation {
    let emotionalContainment: Double    // 0.0-1.0
    let authorityConsistency: Double    // 0.0-1.0
    let modeAdherence: Double          // 0.0-1.0
    let reductionVsEscalation: Double   // 0.0-1.0 (higher = more reduction, less escalation)
    
    var signalStrength: Double {
        // Weighted average
        return (emotionalContainment * 0.3) +
               (authorityConsistency * 0.3) +
               (modeAdherence * 0.25) +
               (reductionVsEscalation * 0.15)
    }
}

// MARK: - Signal Evaluator

class SignalEvaluator {
    static let shared = SignalEvaluator()
    
    private init() {}
    
    // MARK: - Main Evaluation Function
    
    func evaluateSuggestions(
        suggestions: [RapSuggestion],
        mode: SignalMode,
        axes: SignalAxes
    ) -> [RapSuggestion] {
        return suggestions.map { suggestion in
            let _ = evaluateSuggestion(suggestion: suggestion, mode: mode, axes: axes)
            
            // Create updated suggestion with Signal Strength instead of confidence
            let updated = suggestion
            // Note: We'll store signal strength in confidence field for now
            // In a full implementation, we'd add a signalStrength property to RapSuggestion
            return updated
        }
    }
    
    // MARK: - Individual Suggestion Evaluation
    
    func evaluateSuggestion(
        suggestion: RapSuggestion,
        mode: SignalMode,
        axes: SignalAxes
    ) -> SignalEvaluation {
        let emotionalContainment = evaluateEmotionalContainment(suggestion: suggestion, mode: mode)
        let authorityConsistency = evaluateAuthorityConsistency(suggestion: suggestion, axes: axes)
        let modeAdherence = evaluateModeAdherence(suggestion: suggestion, mode: mode)
        let reductionVsEscalation = evaluateReductionVsEscalation(suggestion: suggestion, mode: mode)
        
        return SignalEvaluation(
            emotionalContainment: emotionalContainment,
            authorityConsistency: authorityConsistency,
            modeAdherence: modeAdherence,
            reductionVsEscalation: reductionVsEscalation
        )
    }
    
    // MARK: - Calculate Signal Strength
    
    func calculateSignalStrength(
        suggestion: RapSuggestion,
        mode: SignalMode,
        axes: SignalAxes
    ) -> Double {
        let evaluation = evaluateSuggestion(suggestion: suggestion, mode: mode, axes: axes)
        return evaluation.signalStrength
    }
    
    // MARK: - Emotional Containment
    
    private func evaluateEmotionalContainment(suggestion: RapSuggestion, mode: SignalMode) -> Double {
        let text = suggestion.text.lowercased()
        
        // Count emotional words
        let emotionalWords = [
            "hurt", "pain", "angry", "mad", "sad", "upset", "frustrated",
            "betrayed", "lonely", "scared", "afraid", "worried", "anxious",
            "love", "hate", "care", "feel", "feeling", "crying", "tears"
        ]
        
        var emotionalCount = 0
        for word in emotionalWords {
            if text.contains(word) {
                emotionalCount += 1
            }
        }
        
        // Count total words
        let wordCount = text.split(separator: " ").count
        guard wordCount > 0 else { return 0.5 }
        
        let emotionalDensity = Double(emotionalCount) / Double(wordCount)
        
        // Mode-specific scoring
        switch mode {
        case .uncontainedVulnerability:
            // Allow some emotion but not excessive
            if emotionalDensity > 0.15 {
                return 0.3  // Too much emotion
            } else if emotionalDensity > 0.05 {
                return 0.7  // Appropriate level
            } else {
                return 0.9  // Well contained
            }
        case .lossAcknowledgmentWithoutAttribution:
            // Allow moderate emotion
            if emotionalDensity > 0.12 {
                return 0.4
            } else if emotionalDensity > 0.03 {
                return 0.8
            } else {
                return 0.6  // Too little emotion for this mode
            }
        case .informationRefusal, .voluntaryIsolation:
            // Low emotion preferred
            if emotionalDensity > 0.05 {
                return 0.2
            } else {
                return 0.9
            }
        default:
            // Default: moderate emotion is fine
            if emotionalDensity > 0.1 {
                return 0.6
            } else {
                return 0.8
            }
        }
    }
    
    // MARK: - Authority Consistency
    
    private func evaluateAuthorityConsistency(suggestion: RapSuggestion, axes: SignalAxes) -> Double {
        let text = suggestion.text.lowercased()
        
        let authorityMarkers = [
            "i am", "i'm", "i got", "i have", "i own", "i control",
            "i run", "i lead", "i make", "i decide", "i choose",
            "i know", "i see", "i understand", "i don't care"
        ]
        
        let weakMarkers = [
            "i think", "i guess", "i suppose", "maybe", "perhaps",
            "i'm not sure", "i don't know", "i hope", "i wish"
        ]
        
        var authorityCount = 0
        var weakCount = 0
        
        for marker in authorityMarkers {
            if text.contains(marker) {
                authorityCount += 1
            }
        }
        
        for marker in weakMarkers {
            if text.contains(marker) {
                weakCount += 1
            }
        }
        
        let wordCount = text.split(separator: " ").count
        guard wordCount > 0 else { return 0.5 }
        
        let authorityDensity = Double(authorityCount) / Double(wordCount)
        let weaknessDensity = Double(weakCount) / Double(wordCount)
        
        // Score based on expected authority posture
        switch axes.authorityPosture {
        case .established:
            // Should have high authority, low weakness
            if authorityDensity > 0.05 && weaknessDensity < 0.02 {
                return 0.9
            } else if authorityDensity > 0.03 {
                return 0.7
            } else {
                return 0.4
            }
        case .emerging:
            // Moderate authority, some weakness acceptable
            if authorityDensity > 0.03 && weaknessDensity < 0.05 {
                return 0.8
            } else if authorityDensity > 0.02 {
                return 0.6
            } else {
                return 0.4
            }
        case .unstable:
            // Low authority expected, some weakness acceptable
            if weaknessDensity < 0.1 {
                return 0.7
            } else {
                return 0.5
            }
        }
    }
    
    // MARK: - Mode Adherence
    
    private func evaluateModeAdherence(suggestion: RapSuggestion, mode: SignalMode) -> Double {
        let text = suggestion.text.lowercased()
        let constraints = mode.getConstraints()
        
        var violations = 0
        var totalChecks = 0
        
        // Check for blocked patterns
        for blockedPattern in constraints.blockedPatterns {
            totalChecks += 1
            // Simple check - in production, use more sophisticated NLP
            let patternLower = blockedPattern.lowercased()
            if text.contains(patternLower) {
                violations += 1
            }
        }
        
        // Check for required implications (harder to verify, but check for absence of explicit statements)
        // This is a simplified check
        for implication in constraints.requiredImplications {
            totalChecks += 1
            // If implication requires "without X", check that X is not present
            if implication.contains("without") {
                let parts = implication.components(separatedBy: "without")
                if parts.count == 2 {
                    let forbidden = parts[1].trimmingCharacters(in: .whitespaces)
                    if text.contains(forbidden.lowercased()) {
                        violations += 1
                    }
                }
            }
        }
        
        guard totalChecks > 0 else { return 0.8 }  // Default if no constraints
        
        let adherenceScore = 1.0 - (Double(violations) / Double(totalChecks))
        return max(0.0, min(1.0, adherenceScore))
    }
    
    // MARK: - Reduction vs Escalation
    
    private func evaluateReductionVsEscalation(suggestion: RapSuggestion, mode: SignalMode) -> Double {
        let text = suggestion.text
        
        // Count words
        let wordCount = text.split(separator: " ").count
        
        // Count explanation markers
        let explanationMarkers = [
            "because", "since", "so that", "in order to", "due to",
            "therefore", "thus", "that's why", "the reason"
        ]
        var explanationCount = 0
        let lowercased = text.lowercased()
        for marker in explanationMarkers {
            if lowercased.contains(marker) {
                explanationCount += 1
            }
        }
        
        // Count specific details (proper nouns, numbers, etc.)
        var detailCount = 0
        // Simple heuristic: count capitalized words (likely proper nouns)
        let words = text.split(separator: " ")
        for word in words {
            if word.first?.isUppercase == true && word.count > 1 {
                detailCount += 1
            }
        }
        
        // Score: prefer reduction (fewer words, less explanation, fewer details)
        var score = 0.5
        
        // Word count: fewer is better (up to a point)
        if wordCount < 20 {
            score += 0.2
        } else if wordCount > 40 {
            score -= 0.2
        }
        
        // Explanation: less is better
        if explanationCount == 0 {
            score += 0.2
        } else if explanationCount > 2 {
            score -= 0.3
        }
        
        // Details: fewer is better (mode-dependent)
        switch mode {
        case .informationRefusal, .voluntaryIsolation:
            if detailCount == 0 {
                score += 0.1
            } else if detailCount > 2 {
                score -= 0.2
            }
        default:
            // Some details are okay
            if detailCount > 5 {
                score -= 0.1
            }
        }
        
        return max(0.0, min(1.0, score))
    }
}
