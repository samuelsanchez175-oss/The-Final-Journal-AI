import Foundation

// MARK: - Signal Advanced Info

struct SignalAdvancedInfo {
    let mode: SignalMode
    let axes: SignalAxes
    let profile: SignalProfile
    let modeSelectionReason: String
}

// MARK: - Signal Advanced Exposure

class SignalAdvancedExposure {
    static let shared = SignalAdvancedExposure()
    
    private init() {}
    
    // MARK: - Generate Advanced Info
    
    func generateAdvancedInfo(
        profile: SignalProfile,
        mode: SignalMode,
        axes: SignalAxes
    ) -> SignalAdvancedInfo {
        let reason = generateModeSelectionReason(profile: profile, mode: mode)
        
        return SignalAdvancedInfo(
            mode: mode,
            axes: axes,
            profile: profile,
            modeSelectionReason: reason
        )
    }
    
    // MARK: - Generate Mode Selection Reason
    
    private func generateModeSelectionReason(profile: SignalProfile, mode: SignalMode) -> String {
        switch mode {
        case .uncontainedVulnerability:
            return "High emotion (\(String(format: "%.0f", profile.emotionalLeakage * 100))%) and explanation (\(String(format: "%.0f", profile.explanationDensity * 100))%) without closure detected. Authority unstable."
        case .lossAcknowledgmentWithoutAttribution:
            return "High emotion (\(String(format: "%.0f", profile.emotionalLeakage * 100))%) with low specificity (\(String(format: "%.0f", profile.specificityLoad * 100))%) suggests loss acknowledgment without attribution."
        case .voluntaryIsolation:
            return "Low emotion and defensive tone suggests voluntary isolation. Distance without hostility."
        case .noRepair:
            return "Defensive framing (\(String(format: "%.0f", profile.defensiveFraming * 100))%) with explanation suggests relationship closure. No repair mode activated."
        case .informationRefusal:
            return "Low explanation (\(String(format: "%.0f", profile.explanationDensity * 100))%) and specificity suggests information refusal. Ambiguity preferred."
        case .declarativeClosureWithoutEvidence:
            return "High authority (\(String(format: "%.0f", profile.authorityPosture * 100))%) with low explanation suggests declarative closure without evidence."
        case .postChaosStabilization:
            return "Low emotion, moderate authority suggests post-chaos stabilization. Structure over spectacle."
        case .defaultExpressive:
            return "Low risk profile detected. Default expressive mode for exploratory writing."
        }
    }
    
    // MARK: - Check if Advanced Mode is Enabled
    
    func isAdvancedModeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "signal_advanced_mode_enabled")
    }
    
    // MARK: - Set Advanced Mode
    
    func setAdvancedModeEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "signal_advanced_mode_enabled")
    }
}
