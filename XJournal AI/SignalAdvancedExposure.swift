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
        metrics: SignalMetrics,
        mode: SignalMode,
        axes: SignalAxes,
        profile: SignalProfile
    ) -> SignalAdvancedInfo {
        let reason = generateModeSelectionReason(metrics: metrics, mode: mode)
        
        return SignalAdvancedInfo(
            mode: mode,
            axes: axes,
            profile: profile,
            modeSelectionReason: reason
        )
    }
    
    // MARK: - Generate Mode Selection Reason
    
    private func generateModeSelectionReason(metrics: SignalMetrics, mode: SignalMode) -> String {
        switch mode {
        case .uncontainedVulnerability:
            return "High emotion (\(String(format: "%.0f", metrics.emotionalLeakage * 100))%) and explanation (\(String(format: "%.0f", metrics.explanationDensity * 100))%) without closure detected. Authority unstable."
        case .lossAcknowledgmentWithoutAttribution:
            return "High emotion (\(String(format: "%.0f", metrics.emotionalLeakage * 100))%) with low specificity (\(String(format: "%.0f", metrics.specificityLoad * 100))%) suggests loss acknowledgment without attribution."
        case .voluntaryIsolation:
            return "Low emotion and defensive tone suggests voluntary isolation. Distance without hostility."
        case .noRepair:
            return "Defensive framing (\(String(format: "%.0f", metrics.defensiveFraming * 100))%) with explanation suggests relationship closure. No repair mode activated."
        case .informationRefusal:
            return "Low explanation (\(String(format: "%.0f", metrics.explanationDensity * 100))%) and specificity suggests information refusal. Ambiguity preferred."
        case .declarativeClosureWithoutEvidence:
            return "High authority (\(String(format: "%.0f", metrics.authorityPosture * 100))%) with low explanation suggests declarative closure without evidence."
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
