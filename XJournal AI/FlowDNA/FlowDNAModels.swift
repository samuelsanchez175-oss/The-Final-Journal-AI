//
//  FlowDNAModels.swift
//  XJournal AI
//
//  Flow DNA schema: bar slots, verse, features, cadence profile.
//

import Foundation

// MARK: - Bar Grid

/// Single slot in the 16-slot bar grid (1 e & a 2 e & a 3 e & a 4 e & a).
struct BarSlot: Codable, Equatable {
    let slot: String
    let syllable: String?
    let stress: Int
    let pause: Int
}

/// One bar = 16 slots.
struct FlowBar: Codable {
    let barIndex: Int
    let slots: [BarSlot]
}

/// Full verse with bars and metadata.
struct VerseSchema: Codable {
    let verseId: String
    let artistStyleLabel: String?
    let bpm: Int?
    let timeSignature: String
    let bars: [FlowBar]
    let lines: [String]
    let flowFeatures: FlowDNAFeatures?
    let flowEmbedding: [Float]?

    enum CodingKeys: String, CodingKey {
        case verseId = "verse_id"
        case artistStyleLabel = "artist_style_label"
        case bpm
        case timeSignature = "time_signature"
        case bars
        case lines
        case flowFeatures = "flow_features"
        case flowEmbedding = "flow_embedding"
    }
}

// MARK: - Flow DNA Feature Vector

struct FlowDNAFeatures: Codable, Equatable {
    let avgSyllablesPerBar: Double
    let stressDensity: Double
    let offbeatEntryRatio: Double
    let pauseRatio: Double
    let internalRhymeDensity: Double
    let endRhymeStrength: Double
    let multisyllableRhymeRate: Double
    let burstiness: Double
    let barSpilloverRate: Double
    let frontloadScore: Double
    let midloadScore: Double
    let endloadScore: Double

    enum CodingKeys: String, CodingKey {
        case avgSyllablesPerBar = "avg_syllables_per_bar"
        case stressDensity = "stress_density"
        case offbeatEntryRatio = "offbeat_entry_ratio"
        case pauseRatio = "pause_ratio"
        case internalRhymeDensity = "internal_rhyme_density"
        case endRhymeStrength = "end_rhyme_strength"
        case multisyllableRhymeRate = "multisyllable_rhyme_rate"
        case burstiness = "burstiness"
        case barSpilloverRate = "bar_spillover_rate"
        case frontloadScore = "frontload_score"
        case midloadScore = "midload_score"
        case endloadScore = "endload_score"
    }
}

// MARK: - Intermediate Pipeline Types

struct StressedSyllable: Codable, Equatable {
    let text: String
    let stress: Int
}

struct RhymeCluster: Codable {
    let type: String
    let parts: [String]
    let density: Double?
}

struct CadenceProfile: Codable {
    let stressDensity: String
    let internalRhyme: String
    let gridTightness: String
    let pauseControl: String
    let energyShape: String
    let cadenceFamily: String
    let suggestions: [String]
}

// MARK: - Slot Names

enum BarGridSlotNames {
    static let slotNames = ["1", "e", "&", "a", "2", "e", "&", "a", "3", "e", "&", "a", "4", "e", "&", "a"]
    static let slotCount = 16
}
