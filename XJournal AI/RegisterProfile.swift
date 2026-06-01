import Foundation

// MARK: - Register Profile
// Represents artist position/stance (registers), separate from system constraints

struct RegisterProfile: Codable {
    // Register positions - these describe the artist's stance, not system constraints
    let register_noRepairPosition: Bool      // No reconciliation language allowed
    let register_isolationPosition: Bool     // Distance without hostility
    let register_vulnerabilityPosition: Bool // High emotion, high explanation
    let register_refusalPosition: Bool       // Explanation blocked, ambiguity preferred
    let register_closurePosition: Bool       // Finality without proof
    let register_stabilizationPosition: Bool // Structure, logistics, responsibility
    
    static func empty() -> RegisterProfile {
        return RegisterProfile(
            register_noRepairPosition: false,
            register_isolationPosition: false,
            register_vulnerabilityPosition: false,
            register_refusalPosition: false,
            register_closurePosition: false,
            register_stabilizationPosition: false
        )
    }
}

// MARK: - Register Profile Resolver

class RegisterProfileResolver {
    static let shared = RegisterProfileResolver()
    
    private init() {}
    
    // MARK: - Register Inference
    
    /// Infer register profile from signal mode
    /// Registers represent artist position, not system constraints
    func inferRegisters(from mode: SignalMode) -> RegisterProfile {
        switch mode {
        case .noRepair:
            return RegisterProfile(
                register_noRepairPosition: true,
                register_isolationPosition: false,
                register_vulnerabilityPosition: false,
                register_refusalPosition: false,
                register_closurePosition: false,
                register_stabilizationPosition: false
            )
            
        case .voluntaryIsolation:
            return RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: true,
                register_vulnerabilityPosition: false,
                register_refusalPosition: false,
                register_closurePosition: false,
                register_stabilizationPosition: false
            )
            
        case .uncontainedVulnerability:
            return RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: false,
                register_vulnerabilityPosition: true,
                register_refusalPosition: false,
                register_closurePosition: false,
                register_stabilizationPosition: false
            )
            
        case .informationRefusal:
            return RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: false,
                register_vulnerabilityPosition: false,
                register_refusalPosition: true,
                register_closurePosition: false,
                register_stabilizationPosition: false
            )
            
        case .declarativeClosureWithoutEvidence:
            return RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: false,
                register_vulnerabilityPosition: false,
                register_refusalPosition: false,
                register_closurePosition: true,
                register_stabilizationPosition: false
            )
            
        case .postChaosStabilization:
            return RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: false,
                register_vulnerabilityPosition: false,
                register_refusalPosition: false,
                register_closurePosition: false,
                register_stabilizationPosition: true
            )
            
        case .lossAcknowledgmentWithoutAttribution, .defaultExpressive:
            return RegisterProfile.empty()
        }
    }
    
    /// Infer register profile directly from signal metrics
    /// This allows register inference without going through mode resolution
    func inferRegisters(from metrics: SignalMetrics) -> RegisterProfile {
        // Infer registers based on signal metrics characteristics
        // This mirrors the mode resolution logic but outputs registers instead
        
        var registers = RegisterProfile.empty()
        
        // No Repair: Defensive tone + relationship closure language
        if metrics.hasDefensiveTone && metrics.explanationDensity > 0.4 {
            registers = RegisterProfile(
                register_noRepairPosition: true,
                register_isolationPosition: false,
                register_vulnerabilityPosition: false,
                register_refusalPosition: false,
                register_closurePosition: false,
                register_stabilizationPosition: false
            )
        }
        // Voluntary Isolation: Distance without hostility
        else if !metrics.hasHighEmotion && !metrics.hasDefensiveTone && metrics.authorityPosture > 0.4 {
            registers = RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: true,
                register_vulnerabilityPosition: false,
                register_refusalPosition: false,
                register_closurePosition: false,
                register_stabilizationPosition: false
            )
        }
        // Uncontained Vulnerability: High emotion + high explanation
        else if metrics.hasHighEmotion && metrics.hasHighExplanation && metrics.hasWeakAuthority {
            registers = RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: false,
                register_vulnerabilityPosition: true,
                register_refusalPosition: false,
                register_closurePosition: false,
                register_stabilizationPosition: false
            )
        }
        // Information Refusal: Low explanation + high ambiguity
        else if !metrics.hasHighExplanation && !metrics.hasHighSpecificity && metrics.authorityPosture > 0.5 {
            registers = RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: false,
                register_vulnerabilityPosition: false,
                register_refusalPosition: true,
                register_closurePosition: false,
                register_stabilizationPosition: false
            )
        }
        // Declarative Closure: High authority but low explanation
        else if metrics.authorityPosture > 0.6 && !metrics.hasHighExplanation {
            registers = RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: false,
                register_vulnerabilityPosition: false,
                register_refusalPosition: false,
                register_closurePosition: true,
                register_stabilizationPosition: false
            )
        }
        // Post-Chaos Stabilization: Low emotion, moderate authority, low specificity
        else if !metrics.hasHighEmotion && metrics.authorityPosture > 0.4 && !metrics.hasHighSpecificity {
            registers = RegisterProfile(
                register_noRepairPosition: false,
                register_isolationPosition: false,
                register_vulnerabilityPosition: false,
                register_refusalPosition: false,
                register_closurePosition: false,
                register_stabilizationPosition: true
            )
        }
        
        return registers
    }
}

// MARK: - Convenience Extension

extension RegisterProfile {
    static func inferRegisters(from mode: SignalMode) -> RegisterProfile {
        return RegisterProfileResolver.shared.inferRegisters(from: mode)
    }
    
    static func inferRegisters(from metrics: SignalMetrics) -> RegisterProfile {
        return RegisterProfileResolver.shared.inferRegisters(from: metrics)
    }
    
    static func inferRegisters(from profile: SignalProfile) -> RegisterProfile {
        // SignalProfile doesn't have the metrics needed, so return empty
        // Callers should use inferRegisters(from: SignalMetrics) instead
        return RegisterProfile.empty()
    }
}
