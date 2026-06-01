//
//  FlowDNAEngine.swift
//  XJournal AI
//
//  Orchestrates Flow DNA pipeline: lyrics -> bars, features, cadence profile.
//

import Foundation

enum FlowDNAEngine {
    /// Single entry: analyze verse and return schema, features, and profile.
    static func analyze(verse: String, bpm: Int? = nil, verseId: String = "v001") -> (VerseSchema, FlowDNAFeatures, CadenceProfile) {
        let lines = verse.split(separator: "\n", omittingEmptySubsequences: false).map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let bars = BarGridMapper.mapVerse(lines: lines, bpm: bpm, barOffsetSlots: 0)
        let rhymeClusters = RhymeClusterEngine.detect(lines: lines)
        let (features, profile) = CadenceProfiler.profile(bars: bars, rhymeClusters: rhymeClusters)
        let schema = VerseSchema(
            verseId: verseId,
            artistStyleLabel: nil,
            bpm: bpm,
            timeSignature: "4/4",
            bars: bars,
            lines: lines,
            flowFeatures: features,
            flowEmbedding: nil
        )
        return (schema, features, profile)
    }
}
