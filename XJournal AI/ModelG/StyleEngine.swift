//
//  StyleEngine.swift
//  XJournal AI
//
//  Model G Core v1.0 — Style branch detection and profiles.
//

import Foundation

// MARK: - Style Profile

struct StyleProfile: Equatable {
    let name: String
    var specificityModifier: Double
    var glideModifier: Double
    var edgeModifier: Double
    var densityMultiplier: Double
    var riskCeiling: Double
    var signalVolume: SignalVolume

    static let coldTrap = StyleProfile(
        name: "ColdTrap",
        specificityModifier: 1.0,
        glideModifier: 1.0,
        edgeModifier: 1.0,
        densityMultiplier: 1.12,
        riskCeiling: 0.5,
        signalVolume: .mixed
    )

    static let floatyTrap = StyleProfile(
        name: "FloatyTrap",
        specificityModifier: 0.95,
        glideModifier: 1.15,
        edgeModifier: 0.9,
        densityMultiplier: 0.95,
        riskCeiling: 0.45,
        signalVolume: .mixed
    )

    static let toxicTrap = StyleProfile(
        name: "ToxicTrap",
        specificityModifier: 1.05,
        glideModifier: 0.9,
        edgeModifier: 1.2,
        densityMultiplier: 1.08,
        riskCeiling: 0.55,
        signalVolume: .mixed
    )

    static let darkAggressiveTrap = StyleProfile(
        name: "DarkAggressiveTrap",
        specificityModifier: 1.1,
        glideModifier: 0.85,
        edgeModifier: 1.25,
        densityMultiplier: 1.15,
        riskCeiling: 0.6,
        signalVolume: .loud
    )

    static let luxuryCinematicTrap = StyleProfile(
        name: "LuxuryCinematicTrap",
        specificityModifier: 1.08,
        glideModifier: 1.05,
        edgeModifier: 1.0,
        densityMultiplier: 1.05,
        riskCeiling: 0.48,
        signalVolume: .subtle
    )
}

// MARK: - Style Engine

class StyleEngine {
    /// Detect style from beat + intent. Supports override.
    func detectStyle(context: GenerationContext, override: StyleProfile? = nil) -> StyleProfile {
        if let override = override {
            return override
        }
        // Auto-detect from beat + intent
        if let beat = context.beatFingerprint {
            switch beat.avgEnergyLevel {
            case .low: return .floatyTrap
            case .medium: return .coldTrap
            case .high:
                if beat.bassIntensity == .high { return .darkAggressiveTrap }
                return .toxicTrap
            }
        }
        // Default from intent tone
        switch context.intent.tone {
        case .confident, .victorious: return .coldTrap
        case .dark, .numb: return .darkAggressiveTrap
        case .toxic: return .toxicTrap
        case .reflective: return .floatyTrap
        }
    }
}
