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

struct SignalAxes {
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
    
    func calibrateAxes(profile: SignalProfile, mode: SignalMode) -> SignalAxes {
        let exposureRisk = calculateExposureRisk(profile: profile, mode: mode)
        let authorityPosture = calculateAuthorityPosture(profile: profile, mode: mode)
        let socialAction = calculateSocialAction(profile: profile, mode: mode)
        let audienceScope = calculateAudienceScope(profile: profile, mode: mode)
        
        return SignalAxes(
            exposureRisk: exposureRisk,
            authorityPosture: authorityPosture,
            socialAction: socialAction,
            audienceScope: audienceScope
        )
    }
    
    // MARK: - Exposure Risk Calculation
    
    private func calculateExposureRisk(profile: SignalProfile, mode: SignalMode) -> ExposureRisk {
        // High specificity + high explanation = high exposure
        // High emotional leakage = medium exposure
        // Defensive framing = medium exposure
        
        var riskScore = 0.0
        
        // Specificity contributes heavily
        if profile.hasHighSpecificity {
            riskScore += 0.4
        }
        
        // Explanation density contributes
        if profile.hasHighExplanation {
            riskScore += 0.3
        }
        
        // Emotional leakage contributes
        if profile.emotionalLeakage > 0.5 {
            riskScore += 0.2
        }
        
        // Defensive framing contributes
        if profile.hasDefensiveTone {
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
    
    private func calculateAuthorityPosture(profile: SignalProfile, mode: SignalMode) -> AuthorityPosture {
        // Direct mapping from profile authority score
        let authorityScore = profile.authorityPosture
        
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
    
    private func calculateSocialAction(profile: SignalProfile, mode: SignalMode) -> SocialAction {
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
            // Determine from profile
            if profile.authorityPosture > 0.6 {
                return .flex
            } else if profile.hasDefensiveTone {
                return .warn
            } else if profile.hasHighEmotion {
                return .confess
            } else {
                return .assert
            }
        }
    }
    
    // MARK: - Audience Scope Calculation
    
    private func calculateAudienceScope(profile: SignalProfile, mode: SignalMode) -> AudienceScope {
        // High specificity suggests public audience
        // High emotional leakage suggests inner circle or self
        // Defensive framing suggests public (defending against audience)
        
        var scopeScore = 0.0
        
        if profile.hasHighSpecificity {
            scopeScore += 0.4  // Specificity suggests public
        }
        
        if profile.hasDefensiveTone {
            scopeScore += 0.3  // Defensive suggests public audience
        }
        
        if profile.hasHighEmotion && !profile.hasHighSpecificity {
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
    static func calibrateAxes(profile: SignalProfile, mode: SignalMode) -> SignalAxes {
        return SignalAxesCalibrator.shared.calibrateAxes(profile: profile, mode: mode)
    }
}
