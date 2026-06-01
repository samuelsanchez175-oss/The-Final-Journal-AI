import Foundation

// MARK: - Axis Profile
// Editorial axes with continuous values (-1.0 to +1.0)
// These are computed from existing signals but not yet consumed in decisions

struct AxisProfile: Codable {
    // Continuous axis values from -1.0 to +1.0
    let exposure_guarding: Double        // -1.0 = low exposure, +1.0 = high exposure
    let dominance_vulnerability: Double  // -1.0 = dominant, +1.0 = vulnerable
    let authority_aspiration: Double     // -1.0 = established, +1.0 = emerging
    let literal_symbolic: Double         // -1.0 = literal, +1.0 = symbolic
    let cultural_specificity: Double     // -1.0 = generic, +1.0 = specific
    let social_function: Double          // -1.0 = withdraw, +1.0 = assert
    
    static func empty() -> AxisProfile {
        return AxisProfile(
            exposure_guarding: 0.0,
            dominance_vulnerability: 0.0,
            authority_aspiration: 0.0,
            literal_symbolic: 0.0,
            cultural_specificity: 0.0,
            social_function: 0.0
        )
    }
}

// MARK: - Axis Profile Calculator

class AxisProfileCalculator {
    static let shared = AxisProfileCalculator()
    
    private init() {}
    
    // MARK: - Calculate Axis Profile
    
    /// Calculate axis profile from signal metrics and signal axes
    /// Axes are computed but not consumed yet (read-only/observability)
    func calculateAxisProfile(metrics: SignalMetrics, axes: SignalAxes) -> AxisProfile {
        // Calculate exposure_guarding from exposure risk and specificity
        let exposure_guarding = calculateExposureGuarding(metrics: metrics, axes: axes)
        
        // Calculate dominance_vulnerability from authority and emotion
        let dominance_vulnerability = calculateDominanceVulnerability(metrics: metrics, axes: axes)
        
        // Calculate authority_aspiration from authority posture
        let authority_aspiration = calculateAuthorityAspiration(metrics: metrics, axes: axes)
        
        // Calculate literal_symbolic from specificity and explanation
        let literal_symbolic = calculateLiteralSymbolic(metrics: metrics, axes: axes)
        
        // Calculate cultural_specificity from specificity load
        let cultural_specificity = calculateCulturalSpecificity(metrics: metrics, axes: axes)
        
        // Calculate social_function from social action
        let social_function = calculateSocialFunction(metrics: metrics, axes: axes)
        
        return AxisProfile(
            exposure_guarding: exposure_guarding,
            dominance_vulnerability: dominance_vulnerability,
            authority_aspiration: authority_aspiration,
            literal_symbolic: literal_symbolic,
            cultural_specificity: cultural_specificity,
            social_function: social_function
        )
    }
    
    // MARK: - Individual Axis Calculations
    
    private func calculateExposureGuarding(metrics: SignalMetrics, axes: SignalAxes) -> Double {
        // High specificity + high explanation = high exposure (positive)
        // Low specificity + low explanation = low exposure (negative)
        var score = 0.0
        
        // Specificity contributes
        if metrics.hasHighSpecificity {
            score += 0.4
        } else {
            score -= 0.2
        }
        
        // Explanation density contributes
        score += (metrics.explanationDensity - 0.5) * 0.6
        
        // Exposure risk from axes
        switch axes.exposureRisk {
        case .high:
            score += 0.3
        case .medium:
            score += 0.0
        case .low:
            score -= 0.3
        }
        
        // Clamp to -1.0 to +1.0
        return max(-1.0, min(1.0, score))
    }
    
    private func calculateDominanceVulnerability(metrics: SignalMetrics, axes: SignalAxes) -> Double {
        // High authority + low emotion = dominant (negative)
        // Low authority + high emotion = vulnerable (positive)
        var score = 0.0
        
        // Authority posture
        score += (metrics.authorityPosture - 0.5) * -1.0 // Invert: high authority = negative (dominant)
        
        // Emotional leakage
        score += (metrics.emotionalLeakage - 0.5) * 0.8 // High emotion = positive (vulnerable)
        
        // Clamp to -1.0 to +1.0
        return max(-1.0, min(1.0, score))
    }
    
    private func calculateAuthorityAspiration(metrics: SignalMetrics, axes: SignalAxes) -> Double {
        // High authority = established (negative)
        // Low authority = emerging (positive)
        var score = 0.0
        
        // Authority posture
        score += (metrics.authorityPosture - 0.5) * -1.0
        
        // Authority posture from axes
        switch axes.authorityPosture {
        case .established:
            score -= 0.3
        case .emerging:
            score += 0.1
        case .unstable:
            score += 0.2
        }
        
        // Clamp to -1.0 to +1.0
        return max(-1.0, min(1.0, score))
    }
    
    private func calculateLiteralSymbolic(metrics: SignalMetrics, axes: SignalAxes) -> Double {
        // High specificity = literal (negative)
        // Low specificity = symbolic (positive)
        var score = 0.0
        
        // Specificity load
        score += (metrics.specificityLoad - 0.5) * -1.0
        
        // Explanation density (more explanation = more literal)
        score += (metrics.explanationDensity - 0.5) * -0.5
        
        // Clamp to -1.0 to +1.0
        return max(-1.0, min(1.0, score))
    }
    
    private func calculateCulturalSpecificity(metrics: SignalMetrics, axes: SignalAxes) -> Double {
        // High specificity = specific (positive)
        // Low specificity = generic (negative)
        var score = 0.0
        
        // Specificity load directly maps
        score += (metrics.specificityLoad - 0.5) * 1.0
        
        // Audience scope (public = more specific)
        switch axes.audienceScope {
        case .public:
            score += 0.2
        case .innerCircle:
            score += 0.0
        case .selfOnly:
            score -= 0.2
        }
        
        // Clamp to -1.0 to +1.0
        return max(-1.0, min(1.0, score))
    }
    
    private func calculateSocialFunction(metrics: SignalMetrics, axes: SignalAxes) -> Double {
        // Withdraw = negative, Assert = positive
        var score = 0.0
        
        switch axes.socialAction {
        case .withdraw:
            score = -0.8
        case .distance:
            score = -0.4
        case .warn:
            score = 0.2
        case .confess:
            score = 0.0
        case .assert:
            score = 0.8
        case .flex:
            score = 0.6
        }
        
        // Authority posture influences assertiveness
        if metrics.authorityPosture > 0.6 {
            score += 0.2 // Higher authority = more assertive
        } else if metrics.authorityPosture < 0.4 {
            score -= 0.2 // Lower authority = more withdrawn
        }
        
        // Clamp to -1.0 to +1.0
        return max(-1.0, min(1.0, score))
    }
}

// MARK: - Convenience Extension

extension AxisProfile {
    static func calculate(metrics: SignalMetrics, axes: SignalAxes) -> AxisProfile {
        return AxisProfileCalculator.shared.calculateAxisProfile(metrics: metrics, axes: axes)
    }
    
    // Convenience method that accepts SignalProfile and text to compute metrics
    static func calculate(profile: SignalProfile, axes: SignalAxes, text: String) -> AxisProfile {
        let metrics = SignalIngest.shared.analyzeBehavior(text: text)
        return AxisProfileCalculator.shared.calculateAxisProfile(metrics: metrics, axes: axes)
    }
    
    /// Log axis values for observability (not used in decisions yet)
    func log() {
        print("📊 Axis Profile:")
        print("  exposure_guarding: \(String(format: "%.2f", exposure_guarding))")
        print("  dominance_vulnerability: \(String(format: "%.2f", dominance_vulnerability))")
        print("  authority_aspiration: \(String(format: "%.2f", authority_aspiration))")
        print("  literal_symbolic: \(String(format: "%.2f", literal_symbolic))")
        print("  cultural_specificity: \(String(format: "%.2f", cultural_specificity))")
        print("  social_function: \(String(format: "%.2f", social_function))")
    }
}
