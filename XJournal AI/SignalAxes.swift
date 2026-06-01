import Foundation

// MARK: - Exposure Risk

enum ExposureRisk: String, Codable {
    case low
    case medium
    case high
}

// MARK: - Authority Posture

enum AuthorityPosture: String, Codable {
    case unstable
    case emerging
    case established
}

// MARK: - Social Action

enum SocialAction: String, Codable {
    case confess
    case distance
    case assert
    case withdraw
    case warn
    case flex
}

// MARK: - Audience Scope

enum AudienceScope: String, Codable {
    case selfOnly
    case innerCircle
    case `public`
}

// MARK: - Signal Axes

struct SignalAxes: Codable {
    let exposureRisk: ExposureRisk
    let authorityPosture: AuthorityPosture
    let socialAction: SocialAction
    let audienceScope: AudienceScope
    
    var description: String {
        return "Exposure: \(exposureRisk.rawValue), Authority: \(authorityPosture.rawValue), Action: \(socialAction.rawValue), Audience: \(audienceScope.rawValue)"
    }
}

// MARK: - Signal Axes Calibrator

class SignalAxesCalibrator {
    static let shared = SignalAxesCalibrator()
    
    private init() {}
    
    // MARK: - Main Calibration Function
    
    func calibrateAxes(metrics: SignalMetrics, mode: SignalMode) -> SignalAxes {
        let exposureRisk = calculateExposureRisk(metrics: metrics, mode: mode)
        let authorityPosture = calculateAuthorityPosture(metrics: metrics, mode: mode)
        let socialAction = calculateSocialAction(metrics: metrics, mode: mode)
        let audienceScope = calculateAudienceScope(metrics: metrics, mode: mode)
        
        return SignalAxes(
            exposureRisk: exposureRisk,
            authorityPosture: authorityPosture,
            socialAction: socialAction,
            audienceScope: audienceScope
        )
    }
    
    // MARK: - Exposure Risk Calculation
    
    private func calculateExposureRisk(metrics: SignalMetrics, mode: SignalMode) -> ExposureRisk {
        // High specificity + high explanation = high exposure
        // High emotional leakage = medium exposure
        // Defensive framing = medium exposure
        
        var riskScore = 0.0
        
        // Specificity contributes heavily
        if metrics.hasHighSpecificity {
            riskScore += 0.4
        }
        
        // Explanation density contributes
        if metrics.hasHighExplanation {
            riskScore += 0.3
        }
        
        // Emotional leakage contributes
        if metrics.emotionalLeakage > 0.5 {
            riskScore += 0.2
        }
        
        // Defensive framing contributes
        if metrics.hasDefensiveTone {
            riskScore += 0.1
        }
        
        // Mode-specific adjustments
        switch mode {
        case .informationRefusal:
            riskScore -= 0.3  // Lower exposure in refusal mode
        case .uncontainedVulnerability:
            riskScore += 0.2  // Higher exposure in vulnerability
        case .noRepair:
            riskScore += 0.1  // Slightly higher in no-repair
        default:
            break
        }
        
        // Clamp and convert
        riskScore = max(0.0, min(1.0, riskScore))
        
        if riskScore >= 0.7 {
            return .high
        } else if riskScore >= 0.4 {
            return .medium
        } else {
            return .low
        }
    }
    
    // MARK: - Authority Posture Calculation
    
    private func calculateAuthorityPosture(metrics: SignalMetrics, mode: SignalMode) -> AuthorityPosture {
        // Direct mapping from metrics authority score
        let authorityScore = metrics.authorityPosture
        
        // Mode-specific adjustments
        var adjustedScore = authorityScore
        
        switch mode {
        case .uncontainedVulnerability:
            adjustedScore -= 0.2  // Vulnerability reduces authority
        case .informationRefusal:
            adjustedScore += 0.1  // Refusal can increase perceived authority
        case .declarativeClosureWithoutEvidence:
            adjustedScore += 0.2  // Declarative closure suggests authority
        case .voluntaryIsolation:
            adjustedScore += 0.1  // Isolation can suggest strength
        default:
            break
        }
        
        adjustedScore = max(0.0, min(1.0, adjustedScore))
        
        if adjustedScore >= 0.7 {
            return .established
        } else if adjustedScore >= 0.4 {
            return .emerging
        } else {
            return .unstable
        }
    }
    
    // MARK: - Social Action Calculation
    
    private func calculateSocialAction(metrics: SignalMetrics, mode: SignalMode) -> SocialAction {
        // Mode-specific primary actions
        switch mode {
        case .uncontainedVulnerability:
            return .confess
        case .noRepair:
            return .withdraw
        case .voluntaryIsolation:
            return .distance
        case .informationRefusal:
            return .withdraw
        case .declarativeClosureWithoutEvidence:
            return .assert
        case .lossAcknowledgmentWithoutAttribution:
            return .confess
        case .postChaosStabilization:
            return .assert
        case .defaultExpressive:
            // Determine from metrics
            if metrics.authorityPosture > 0.6 {
                return .flex
            } else if metrics.hasDefensiveTone {
                return .warn
            } else if metrics.hasHighEmotion {
                return .confess
            } else {
                return .assert
            }
        }
    }
    
    // MARK: - Audience Scope Calculation
    
    private func calculateAudienceScope(metrics: SignalMetrics, mode: SignalMode) -> AudienceScope {
        // High specificity suggests public audience
        // High emotional leakage suggests inner circle or self
        // Defensive framing suggests public (defending against audience)
        
        var scopeScore = 0.0
        
        if metrics.hasHighSpecificity {
            scopeScore += 0.4  // Specificity suggests public
        }
        
        if metrics.hasDefensiveTone {
            scopeScore += 0.3  // Defensive suggests public audience
        }
        
        if metrics.hasHighEmotion && !metrics.hasHighSpecificity {
            scopeScore -= 0.3  // High emotion without specificity suggests private
        }
        
        // Mode-specific adjustments
        switch mode {
        case .informationRefusal:
            scopeScore -= 0.2  // Refusal suggests private
        case .voluntaryIsolation:
            scopeScore -= 0.1  // Isolation suggests smaller audience
        case .uncontainedVulnerability:
            scopeScore -= 0.2  // Vulnerability suggests private
        case .declarativeClosureWithoutEvidence:
            scopeScore += 0.2  // Closure suggests public statement
        default:
            break
        }
        
        scopeScore = max(0.0, min(1.0, scopeScore))
        
        if scopeScore >= 0.6 {
            return .public
        } else if scopeScore >= 0.3 {
            return .innerCircle
        } else {
            return .selfOnly
        }
    }
}

// MARK: - Convenience Extension

extension SignalAxes {
    static func calibrateAxes(metrics: SignalMetrics, mode: SignalMode) -> SignalAxes {
        return SignalAxesCalibrator.shared.calibrateAxes(metrics: metrics, mode: mode)
    }
    
    // Convenience method that accepts SignalProfile and text to compute metrics
    static func calibrateAxes(profile: SignalProfile, mode: SignalMode, text: String) -> SignalAxes {
        let metrics = SignalIngest.shared.analyzeBehavior(text: text)
        return SignalAxesCalibrator.shared.calibrateAxes(metrics: metrics, mode: mode)
    }
}
