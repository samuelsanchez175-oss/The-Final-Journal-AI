import Foundation

// MARK: - Signal Adjusted Line

struct SignalAdjustedLine {
    let original: String
    let adjusted: String
    let explanation: String
}

// MARK: - Signal Comparison

class SignalComparison {
    static let shared = SignalComparison()
    
    private init() {}
    
    // MARK: - Generate Signal Adjusted Version
    
    func generateSignalAdjustedVersion(
        originalLine: String,
        mode: SignalMode,
        constraints: ConstraintRules
    ) async throws -> SignalAdjustedLine {
        // This would typically call an AI API to generate the adjusted version
        // For now, we'll provide a simplified version that removes blocked patterns
        
        var adjusted = originalLine
        
        // Remove blocked patterns (simplified - in production, use NLP)
        for blockedPattern in constraints.blockedLanguagePatterns {
            // Simple removal - in production, use more sophisticated text processing
            let patternLower = blockedPattern.lowercased()
            let _ = adjusted.lowercased()
            
            // Remove common explanation markers
            if patternLower.contains("explanation") {
                adjusted = removeExplanationMarkers(from: adjusted)
            }
            
            // Remove specific time markers if exposure risk is high
            if patternLower.contains("time markers") {
                adjusted = removeTimeMarkers(from: adjusted)
            }
        }
        
        // Generate explanation
        let explanation = generateExplanation(original: originalLine, adjusted: adjusted, mode: mode)
        
        return SignalAdjustedLine(
            original: originalLine,
            adjusted: adjusted,
            explanation: explanation
        )
    }
    
    // MARK: - Helper Functions
    
    private func removeExplanationMarkers(from text: String) -> String {
        let explanationMarkers = [
            " because ", " since ", " so that ", " in order to ",
            " that's why ", " the reason ", " I did it because "
        ]
        
        var result = text
        for marker in explanationMarkers {
            result = result.replacingOccurrences(of: marker, with: " ", options: .caseInsensitive)
        }
        
        // Clean up extra spaces
        result = result.replacingOccurrences(of: "  ", with: " ")
        return result.trimmingCharacters(in: .whitespaces)
    }
    
    private func removeTimeMarkers(from text: String) -> String {
        let timeMarkers = [
            " yesterday ", " today ", " tomorrow ", " last week ", " last month ",
            " at 3am ", " at midnight ", " in the morning ", " in the afternoon "
        ]
        
        var result = text
        for marker in timeMarkers {
            result = result.replacingOccurrences(of: marker, with: " ", options: .caseInsensitive)
        }
        
        // Clean up extra spaces
        result = result.replacingOccurrences(of: "  ", with: " ")
        return result.trimmingCharacters(in: .whitespaces)
    }
    
    private func generateExplanation(original: String, adjusted: String, mode: SignalMode) -> String {
        if original.count > adjusted.count {
            return "This version removes motive and keeps outcome, which increases authority."
        } else if original != adjusted {
            return "This version reduces explanation and prefers implication, strengthening the signal."
        } else {
            return "This line already operates within signal constraints."
        }
    }
}
