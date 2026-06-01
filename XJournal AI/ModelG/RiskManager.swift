//
//  RiskManager.swift
//  XJournal AI
//
//  Model G Core v1.0 — Risk index escalation.
//

import Foundation

/// Manages risk index for regeneration escalation.
class RiskManager {
    private(set) var riskIndex: Double = 0.18

    func increaseRiskOnRegenerate(style: StyleProfile) {
        riskIndex = min(riskIndex + 0.07, style.riskCeiling)
    }

    func reset() {
        riskIndex = 0.18
    }
}
