//
//  FlowExemplar.swift
//  XJournal AI
//
//  Copy-flow: a 4-bar syllable/stress map to fill with new nouns.
//  Copy the CLOCK, not the lyrics.
//

import Foundation

struct FlowExemplar: Equatable {
    enum Source: String, Equatable {
        case draftLastFour
        case pasted
        case corpusMap
    }

    var bars: [String]
    var syllableMap: [Int]
    var stressHint: String
    var source: Source

    /// Include the bar text as a length/shape hint. False for corpus maps so we never paste Gunna nouns.
    var includeBarText: Bool {
        source != .corpusMap
    }

    var isUsable: Bool {
        syllableMap.count == 4 && syllableMap.allSatisfy { $0 > 0 }
    }

    static func fromLines(_ lines: [String], source: Source, bpm: Int? = nil) -> FlowExemplar? {
        let bars = lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard bars.count >= 4 else { return nil }
        let four = Array(bars.suffix(4))
        let map = four.map { SyllableEngine.lineSyllableCount($0) }
        guard map.allSatisfy({ $0 > 0 }) else { return nil }
        let verse = four.joined(separator: "\n")
        let features = FlowDNAEngine.analyze(verse: verse, bpm: bpm).1
        return FlowExemplar(
            bars: four,
            syllableMap: map,
            stressHint: stressHint(from: features),
            source: source
        )
    }

    static func fromDraft(_ draft: String, bpm: Int? = nil) -> FlowExemplar? {
        let lines = draft.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        return fromLines(lines, source: .draftLastFour, bpm: bpm)
    }

    static func stressHint(from features: FlowDNAFeatures) -> String {
        if features.endloadScore >= features.frontloadScore && features.endloadScore >= features.midloadScore {
            return "end-loaded, last stress of each bar in the punch window (beats 3–4)"
        }
        if features.frontloadScore > features.endloadScore {
            return "front-loaded entry; still land the last stress on beats 3–4"
        }
        return "last stress of each bar in the punch window (beats 3–4)"
    }
}
