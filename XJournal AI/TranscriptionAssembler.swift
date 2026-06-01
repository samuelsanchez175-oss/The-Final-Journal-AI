//
//  TranscriptionAssembler.swift
//  XJournal AI
//
//  Converts ASR segments + BPM → word timing → syllable events → bar grid →
//  RhythmicTranscriptionResult.
//

import Foundation

enum TranscriptionAssembler {
    private static let defaultWordConfidence = 0.85
    private static let lowConfidenceWhenNoBPM = 0.5
    
    /// Builds a full rhythmic transcription result from ASR segments and optional BPM.
    static func assemble(
        segments: [TranscriptionSegment],
        bpm: Int?,
        timeSignature: TimeSignature = .fourFour,
        barOffsetMs: Int = 0,
        audioId: String? = nil
    ) -> RhythmicTranscriptionResult {
        let transcript = buildTranscriptWithWords(segments: segments)
        let (events, perBar) = buildSyllableEventsAndPerBar(
            segments: segments,
            bpm: bpm,
            timeSignature: timeSignature,
            barOffsetMs: barOffsetMs
        )
        let hasBPM = bpm != nil && (bpm ?? 0) > 0
        let syllables = SyllablesResult(
            method: "heuristic_vowel_groups_v1",
            events: events,
            perBar: perBar.map { bar in
                PerBarCount(
                    bar: bar.bar,
                    count: bar.count,
                    conf: hasBPM ? bar.conf : (bar.conf.map { min($0, Self.lowConfidenceWhenNoBPM) } ?? Self.lowConfidenceWhenNoBPM),
                    perBeat: bar.perBeat
                )
            }
        )
        return RhythmicTranscriptionResult(
            audioId: audioId,
            bpm: bpm,
            timeSignature: timeSignature,
            barOffsetMs: barOffsetMs,
            transcript: transcript,
            syllables: syllables
        )
    }
    
    // MARK: - Transcript with word-level timings
    
    private static func buildTranscriptWithWords(segments: [TranscriptionSegment]) -> TranscriptWithWords {
        let segs = segments.map { seg -> TranscriptSegmentWithWords in
            let startMs = Int(seg.timestamp * 1000)
            let endMs = Int((seg.timestamp + seg.duration) * 1000)
            let words = wordTimingsForSegment(text: seg.text, startMs: startMs, endMs: endMs)
            return TranscriptSegmentWithWords(
                startMs: startMs,
                endMs: endMs,
                text: seg.text,
                words: words
            )
        }
        return TranscriptWithWords(language: nil, segments: segs)
    }
    
    private static func wordTimingsForSegment(text: String, startMs: Int, endMs: Int) -> [TranscriptWord] {
        let parts = text.split(separator: " ").map(String.init).filter { !$0.isEmpty }
        let n = parts.count
        guard n > 0 else {
            return []
        }
        let span = endMs - startMs
        var out: [TranscriptWord] = []
        for i in 0..<n {
            let s = startMs + (i * span) / n
            let e = startMs + ((i + 1) * span) / n
            out.append(TranscriptWord(w: parts[i], s: s, e: e, conf: Self.defaultWordConfidence))
        }
        return out
    }
    
    // MARK: - Syllable events and per-bar counts
    
    private static func buildSyllableEventsAndPerBar(
        segments: [TranscriptionSegment],
        bpm: Int?,
        timeSignature: TimeSignature,
        barOffsetMs: Int
    ) -> (events: [SyllableEvent], perBar: [PerBarCount]) {
        var events: [SyllableEvent] = []
        let beatsPerBar = timeSignature.beatsPerBar
        let beatMs: Double
        let barMs: Double
        if let b = bpm, b > 0 {
            beatMs = 60_000.0 / Double(b)
            barMs = beatMs * Double(beatsPerBar)
        } else {
            beatMs = 0
            barMs = 0
        }
        
        for seg in segments {
            let startMs = Int(seg.timestamp * 1000)
            let endMs = Int((seg.timestamp + seg.duration) * 1000)
            let parts = seg.text.split(separator: " ").map(String.init).filter { !$0.isEmpty }
            let n = parts.count
            guard n > 0 else { continue }
            let span = endMs - startMs
            
            for (i, word) in parts.enumerated() {
                let s = startMs + (i * span) / n
                let e = startMs + ((i + 1) * span) / n
                let k = Syllabifier.syllableCount(word: word)
                let conf = Self.defaultWordConfidence
                
                for j in 0..<k {
                    let t = s + Int((Double(j) + 0.5) * Double(e - s) / Double(k))
                    let (bar, beat, slot16) = barBeatSlot(t: t, barOffsetMs: barOffsetMs, beatMs: beatMs, barMs: barMs, beatsPerBar: beatsPerBar)
                    events.append(SyllableEvent(
                        t: t,
                        bar: bar,
                        beat: beat,
                        slot16: slot16,
                        srcWord: word,
                        conf: conf
                    ))
                }
            }
        }
        
        // Aggregate perBar from events
        var barToEvents: [Int: [SyllableEvent]] = [:]
        for e in events {
            barToEvents[e.bar, default: []].append(e)
        }
        var perBar: [PerBarCount] = []
        for bar in barToEvents.keys.sorted() {
            let evs = barToEvents[bar]!
            var perBeat = [Int](repeating: 0, count: beatsPerBar)
            for e in evs {
                if e.beat >= 1 && e.beat <= beatsPerBar {
                    perBeat[e.beat - 1] += 1
                }
            }
            let total = perBeat.reduce(0, +)
            let conf = bpm != nil && (bpm ?? 0) > 0 ? Self.defaultWordConfidence : Self.lowConfidenceWhenNoBPM
            perBar.append(PerBarCount(bar: bar, count: total, conf: conf, perBeat: perBeat))
        }
        perBar.sort { $0.bar < $1.bar }
        
        return (events, perBar)
    }
    
    private static func barBeatSlot(t: Int, barOffsetMs: Int, beatMs: Double, barMs: Double, beatsPerBar: Int) -> (bar: Int, beat: Int, slot16: Int) {
        guard beatMs > 0, barMs > 0 else {
            return (0, 0, 0)
        }
        let tAdj = t - barOffsetMs
        let barIndex = Int(floor(Double(tAdj) / barMs)) + 1
        let inBar = Double(tAdj).truncatingRemainder(dividingBy: barMs)
        let beatInBar = Int(floor(inBar / beatMs)) + 1
        let slot16 = Int(floor((inBar / barMs) * 16))
        return (barIndex, beatInBar, min(15, max(0, slot16)))
    }
}
