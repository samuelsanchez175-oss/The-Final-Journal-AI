//
//  CorpusTone.swift
//  XJournal AI
//
//  The 13-tone vault list for Suggest next lines. EmotionalTone stays the
//  narrative enum. This screen maps into it only where older code asks for one.
//

import Foundation

/// Corpus tones from the vault pass. Do not add a fourteenth.
enum CorpusTone: String, Codable, CaseIterable, Identifiable {
    case confident
    case luxurious
    case aspirational
    case aggressive
    case dominant
    case gritty
    case defiant
    case celebratory
    case detached
    case paranoid
    case anxious
    case opportunistic
    case calculated

    var id: String { rawValue }

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    /// Closest EmotionalTone. confident, aggressive, and detached match directly.
    var emotionalTone: EmotionalTone {
        switch self {
        case .confident: return .confident
        case .aggressive: return .aggressive
        case .detached: return .detached
        case .luxurious: return .confident
        case .aspirational: return .hopeful
        case .dominant: return .confident
        case .gritty: return .aggressive
        case .defiant: return .resentful
        case .celebratory: return .hopeful
        case .paranoid: return .melancholic
        case .anxious: return .melancholic
        case .opportunistic: return .confident
        case .calculated: return .detached
        }
    }

    static func emotionalTones(from tones: [CorpusTone]) -> [EmotionalTone] {
        var seen = Set<EmotionalTone>()
        return tones.map(\.emotionalTone).filter { seen.insert($0).inserted }
    }
}

/// Suggest next lines model row. V7 is shown and not selectable.
/// The live row is named for Model G Core v4 until a real V6 or V7 endpoint exists.
enum SuggestNextLinesModel: String, Codable, CaseIterable, Identifiable {
    case v6 = "V6"
    case v7 = "V7"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .v6: return "Current (Model G v4)"
        case .v7: return "V7"
        }
    }

    /// V7 has no app endpoint. The row stays disabled.
    var isCallable: Bool { self == .v6 }
}

/// Syllable groups for the suggest sheet. Replaces the 6–16 count grid.
enum SyllableBand: String, CaseIterable, Identifiable {
    case tight
    case standard
    case dense

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tight: return "Tight"
        case .standard: return "Standard"
        case .dense: return "Dense"
        }
    }

    var low: Int {
        switch self {
        case .tight: return 8
        case .standard: return 11
        case .dense: return 14
        }
    }

    var high: Int {
        switch self {
        case .tight: return 10
        case .standard: return 13
        case .dense: return 16
        }
    }

    var caption: String {
        switch self {
        case .tight: return "8–10. Non-triplet Gunna bars sit at a median of 9."
        case .standard: return "11–13. Triplet bars sit at a median of 12. This is the default."
        case .dense: return "14–16. A 16-syllable bar with three commas is about 1.5% of his lines."
        }
    }

    static func matching(min: Int?, max: Int?) -> SyllableBand? {
        guard let min, let max else { return nil }
        return allCases.first { $0.low == min && $0.high == max }
    }
}
