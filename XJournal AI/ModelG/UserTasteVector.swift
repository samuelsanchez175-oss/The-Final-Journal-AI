//
//  UserTasteVector.swift
//  XJournal AI
//
//  Model G Core v1.0 — User taste bias for scoring.
//  Bias influence capped at 15% in ScoringEngine.
//

import Foundation

/// User taste vector — tracks learned preferences with exponential decay.
struct UserTasteVector: Codable {
    var specificityBias: Double
    var glideBias: Double
    var edgeBias: Double
    var culturalBias: Double
    var darknessBias: Double

    mutating func applyDecay() {
        specificityBias *= 0.92
        glideBias *= 0.92
        edgeBias *= 0.92
        culturalBias *= 0.92
        darknessBias *= 0.92
    }

    /// Default neutral vector.
    static let neutral = UserTasteVector(
        specificityBias: 0,
        glideBias: 0,
        edgeBias: 0,
        culturalBias: 0,
        darknessBias: 0
    )
}
