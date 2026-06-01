import Foundation

// MARK: - Alignment Score Result

struct AlignmentScore {
    let totalScore: Double
    let axisProximity: Double
    let authorityContinuity: Double
    let exposurePayoffBalance: Double
    let culturalGroundTruth: Double
    
    var description: String {
        return String(format: "Total: %.2f (Axis: %.2f, Authority: %.2f, Exposure: %.2f, Cultural: %.2f)",
                     totalScore, axisProximity, authorityContinuity, exposurePayoffBalance, culturalGroundTruth)
    }
}

// MARK: - Alignment Scorer
// Internal scoring system - scores are logged but not exposed to UI yet

class AlignmentScorer {
    static let shared = AlignmentScorer()
    
    private init() {}
    
    // MARK: - Main Scoring Function
    
    /// Score a suggestion for alignment with user text, axes, and cultural ground truth
    /// Scores are internal only - not exposed to UI yet
    func scoreSuggestion(
        suggestion: RapSuggestion,
        userText: String,
        userProfile: SignalProfile,
        axes: SignalAxes,
        axisProfile: AxisProfile,
        registers: RegisterProfile
    ) -> AlignmentScore {
        // Calculate individual scores
        let axisProx = axisProximityScore(
            suggestion: suggestion,
            axisProfile: axisProfile
        )
        
        let authorityCont = authorityContinuityScore(
            suggestion: suggestion,
            userText: userText,
            userProfile: userProfile,
            axes: axes
        )
        
        let exposurePayoff = exposurePayoffBalanceScore(
            suggestion: suggestion,
            userProfile: userProfile,
            axes: axes
        )
        
        let culturalGT = culturalGroundTruthScore(
            suggestion: suggestion,
            registers: registers,
            axisProfile: axisProfile
        )
        
        // Weighted total score
        let totalScore = (axisProx * 0.3) +
                        (authorityCont * 0.3) +
                        (exposurePayoff * 0.2) +
                        (culturalGT * 0.2)
        
        let score = AlignmentScore(
            totalScore: totalScore,
            axisProximity: axisProx,
            authorityContinuity: authorityCont,
            exposurePayoffBalance: exposurePayoff,
            culturalGroundTruth: culturalGT
        )
        
        // Log score internally (not exposed to UI)
        logScore(suggestion: suggestion, score: score)
        
        return score
    }
    
    // MARK: - Individual Score Calculations
    
    /// How well suggestion matches axis profile
    private func axisProximityScore(
        suggestion: RapSuggestion,
        axisProfile: AxisProfile
    ) -> Double {
        // For now, return neutral score
        // In future, analyze suggestion text against axis profile
        // This would use NLP to detect exposure, dominance, authority, etc. in suggestion
        return 0.5
    }
    
    /// Authority consistency with user text
    private func authorityContinuityScore(
        suggestion: RapSuggestion,
        userText: String,
        userProfile: SignalProfile,
        axes: SignalAxes
    ) -> Double {
        // Score based on how well suggestion maintains authority posture
        // High authority user text should generate high authority suggestions
        // Compute SignalMetrics from user text to get numeric authority posture
        let userMetrics = SignalIngest.shared.analyzeBehavior(text: userText)
        let userAuthority = userMetrics.authorityPosture
        
        // For now, return score based on user authority
        // In future, analyze suggestion text for authority markers
        if userAuthority > 0.6 {
            // User has high authority - suggestions should maintain it
            return 0.7 // Assume suggestion maintains authority
        } else if userAuthority < 0.4 {
            // User has low authority - suggestions should match
            return 0.6 // Assume suggestion matches low authority
        } else {
            // Moderate authority
            return 0.65
        }
    }
    
    /// Exposure ↔ payoff balance
    private func exposurePayoffBalanceScore(
        suggestion: RapSuggestion,
        userProfile: SignalProfile,
        axes: SignalAxes
    ) -> Double {
        // Score based on whether suggestion balances exposure risk with payoff
        // High exposure should have high payoff, low exposure can have lower payoff
        
        let exposureRisk: Double
        switch axes.exposureRisk {
        case .high:
            exposureRisk = 0.8
        case .medium:
            exposureRisk = 0.5
        case .low:
            exposureRisk = 0.2
        }
        
        // For now, assume balanced (will be enhanced with actual analysis)
        // High exposure + high payoff = good balance
        // Low exposure + low payoff = acceptable balance
        if exposureRisk > 0.6 {
            // High exposure - should have high payoff
            return 0.7 // Assume balanced
        } else {
            // Lower exposure - acceptable with lower payoff
            return 0.65
        }
    }
    
    /// Compare against what has worked (cultural ground truth)
    private func culturalGroundTruthScore(
        suggestion: RapSuggestion,
        registers: RegisterProfile,
        axisProfile: AxisProfile
    ) -> Double {
        // Lazy load ground truth if not already loaded
        if !EditorialGroundTruth.shared.isLoaded && !EditorialGroundTruth.shared.isLoading {
            Task {
                try? await EditorialGroundTruth.shared.loadFromAppGroup()
            }
        }
        
        // Find similar ground truth bars
        let similarBars = EditorialGroundTruth.shared.findSimilarBars(
            registers: registers,
            axes: axisProfile,
            limit: 5
        )
        
        guard !similarBars.isEmpty else {
            // No ground truth available - return neutral
            return 0.5
        }
        
        // For now, return score based on having similar bars
        // In future, compare suggestion text against similar bars
        // Score higher if suggestion aligns with proven patterns
        
        // Simple heuristic: if we found similar bars, assume alignment
        // This will be enhanced with actual text comparison
        return 0.7
    }
    
    // MARK: - Logging (Internal Only)
    
    private func logScore(suggestion: RapSuggestion, score: AlignmentScore) {
        #if DEBUG
        print("📊 Alignment Score for suggestion '\(suggestion.text.prefix(50))...':")
        print("   \(score.description)")
        #endif
    }
}
