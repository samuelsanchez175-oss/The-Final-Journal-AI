//
//  TranscriptionRhythmModels.swift
//  XJournal AI
//
//  Codable types for rhythmic transcription: transcript with word timings,
//  syllable events, and per-beat/per-bar counts (BPM, bar grid).
//

import Foundation

// MARK: - Time signature

struct TimeSignature: Codable, Equatable {
    let beatsPerBar: Int
    let beatUnit: Int
    
    static let fourFour = TimeSignature(beatsPerBar: 4, beatUnit: 4)
}

// MARK: - Transcript with word-level timings

struct TranscriptWord: Codable {
    let w: String   // word
    let s: Int      // start ms
    let e: Int      // end ms
    let conf: Double?
}

struct TranscriptSegmentWithWords: Codable {
    let startMs: Int
    let endMs: Int
    let text: String
    let words: [TranscriptWord]
}

struct TranscriptWithWords: Codable {
    let language: String?
    let segments: [TranscriptSegmentWithWords]
}

// MARK: - Syllable events and per-bar counts

struct SyllableEvent: Codable {
    let t: Int           // time ms
    let bar: Int
    let beat: Int
    let slot16: Int
    let srcWord: String
    let conf: Double?
}

struct PerBarCount: Codable {
    let bar: Int
    let count: Int
    let conf: Double?
    let perBeat: [Int]
}

struct SyllablesResult: Codable {
    let method: String?
    let events: [SyllableEvent]
    let perBar: [PerBarCount]
}

// MARK: - Top-level rhythmic transcription result

struct RhythmicTranscriptionResult: Codable {
    let audioId: String?
    let bpm: Int?
    let timeSignature: TimeSignature?
    let barOffsetMs: Int?
    let transcript: TranscriptWithWords
    let syllables: SyllablesResult
}

// MARK: - Beat line (display line for Notes-style view)

/// One display line spanning N beats (e.g. 2), with words and syllable-per-beat for that span.
struct BeatLine: Identifiable {
    var id: Int { startMs }
    let text: String
    let startMs: Int
    let endMs: Int
    let perBeat: [Int]
    
    /// Format perBeat as "1|1|1|1" for display.
    var perBeatDisplay: String {
        guard !perBeat.isEmpty else { return "—" }
        return perBeat.map { String($0) }.joined(separator: "|")
    }
}

// MARK: - Beat-line builder

extension RhythmicTranscriptionResult {
    /// Default number of beats per display line (Notes-style ~2 beats per line).
    static let defaultBeatsPerLine = 2
    
    /// Builds display lines from the rhythm map: each line spans `beatsPerLine` beats, with words and syllable-per-beat. Returns empty when BPM is missing.
    func buildBeatLines(beatsPerLine: Int = defaultBeatsPerLine) -> [BeatLine] {
        guard let bpm = bpm, bpm > 0 else { return [] }
        let offset = barOffsetMs ?? 0
        let beatMs = 60_000 / bpm
        let lineDurationMs = beatsPerLine * beatMs
        guard lineDurationMs > 0 else { return [] }
        
        // Collect all words with timing (from transcript segments)
        var allWords: [(word: String, s: Int, e: Int)] = []
        for seg in transcript.segments {
            for w in seg.words {
                allWords.append((w.w, w.s, w.e))
            }
        }
        let events = syllables.events
        guard !allWords.isEmpty || !events.isEmpty else { return [] }
        
        let minMs = min(
            allWords.map(\.s).min() ?? Int.max,
            events.map(\.t).min() ?? Int.max
        )
        let maxMs = max(
            allWords.map(\.e).max() ?? 0,
            events.map(\.t).max() ?? 0
        )
        
        // Align first line to a beat boundary from barOffsetMs
        let firstLineStart = ((minMs - offset) / lineDurationMs) * lineDurationMs + offset
        var lines: [BeatLine] = []
        var lineStart = firstLineStart
        
        while lineStart < maxMs {
            let lineEnd = lineStart + lineDurationMs
            
            // Words overlapping this window (any overlap)
            let wordsInLine = allWords
                .filter { w in w.s < lineEnd && w.e > lineStart }
                .sorted(by: { $0.s < $1.s })
            let text = wordsInLine.map(\.word).joined(separator: " ")
            
            // Syllable events in this window, grouped by beat within the line (0 ..< beatsPerLine)
            var perBeat = [Int](repeating: 0, count: beatsPerLine)
            for e in events where e.t >= lineStart && e.t < lineEnd {
                let beatInLine = min(beatsPerLine - 1, (e.t - lineStart) / beatMs)
                if beatInLine >= 0 {
                    perBeat[beatInLine] += 1
                }
            }
            
            // Include line if it has words or any syllables
            if !text.isEmpty || perBeat.contains(where: { $0 > 0 }) {
                lines.append(BeatLine(
                    text: text.isEmpty ? " " : text,
                    startMs: lineStart,
                    endMs: lineEnd,
                    perBeat: perBeat
                ))
            }
            lineStart = lineEnd
        }
        
        return lines
    }
}

// MARK: - Helper: syllable-per-beat display string for a segment

extension RhythmicTranscriptionResult {
    /// Returns a display string of syllable-per-beat for the given segment time span (e.g. "3 4 2 3" or "—" when no data).
    func syllablePerBeatDisplay(forSegmentTimestamp timestamp: TimeInterval, duration: TimeInterval) -> String {
        let startMs = Int(timestamp * 1000)
        let endMs = Int((timestamp + duration) * 1000)
        return syllablePerBeatDisplay(startMs: startMs, endMs: endMs)
    }
    
    /// Returns a display string of syllable-per-beat for the given ms range.
    func syllablePerBeatDisplay(startMs: Int, endMs: Int) -> String {
        guard let bpm = bpm, bpm > 0 else { return "—" }
        let events = syllables.events.filter { $0.t >= startMs && $0.t <= endMs }
        if events.isEmpty { return "—" }
        
        // Group events by (bar, beat) and count
        var countByBarBeat: [String: Int] = [:]
        for e in events {
            let key = "\(e.bar).\(e.beat)"
            countByBarBeat[key, default: 0] += 1
        }
        
        // Order by bar then beat and format as "3 4 2 3" or "2 | 3 | 4" for multiple bars
        _ = timeSignature?.beatsPerBar ?? 4
        let sortedKeys = countByBarBeat.keys.sorted { a, b in
            let partsA = a.split(separator: ".").compactMap { Int($0) }
            let partsB = b.split(separator: ".").compactMap { Int($0) }
            guard partsA.count == 2, partsB.count == 2 else { return a < b }
            if partsA[0] != partsB[0] { return partsA[0] < partsB[0] }
            return partsA[1] < partsB[1]
        }
        let values = sortedKeys.compactMap { countByBarBeat[$0] }
        if values.isEmpty { return "—" }
        return values.map { String($0) }.joined(separator: " ")
    }
}
