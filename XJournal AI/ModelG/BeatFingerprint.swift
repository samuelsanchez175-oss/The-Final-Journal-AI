//
//  BeatFingerprint.swift
//  XJournal AI
//
//  Model G Core v1.0 — Beat fingerprint data structure.
//

import Foundation

// MARK: - Energy Level

enum EnergyLevel: String, Codable {
    case low
    case medium
    case high
}

// MARK: - Density Level

enum DensityLevel: String, Codable {
    case low
    case medium
    case high
}

// MARK: - Intensity Level

enum IntensityLevel: String, Codable {
    case low
    case medium
    case high
}

// MARK: - Beat Fingerprint

/// Immutable beat fingerprint from audio analysis.
/// Stored in note metadata; re-analysis only if audio file changes.
struct BeatFingerprint: Codable, Equatable {
    let bpm: Double
    let timeSignature: String
    let key: String
    let scale: String
    let avgEnergyLevel: EnergyLevel
    let drumDensity: DensityLevel
    let bassIntensity: IntensityLevel
    let spectralBrightness: Double
    let swingFeel: Double
    let dropBars: [Int]
    let breakdownBars: [Int]
    let pocketDensityScore: Double
    let melodicAirinessScore: Double
}
