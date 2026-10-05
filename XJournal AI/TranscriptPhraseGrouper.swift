import Foundation
import CoreText

/// One Notes-style transcript row: a sentence/utterance, or a silence mark.
nonisolated struct TranscriptPhrase: Equatable, Sendable {
    let text: String
    let timestamp: TimeInterval
    let duration: TimeInterval
    let wordTimings: [WordTiming]
    /// Silence: empty text = paragraph gap; "···" = longer instrumental/pause.
    let isPause: Bool
}

/// Groups word-level or phrase-level ASR segments into rows that fit one column line.
/// A row closes on a breath, on a setup/punch boundary when the bar does not fit,
/// or when the next word would not fit. A full bar stays one row when every word fits.
nonisolated enum TranscriptPhraseGrouper: Sendable {
    static let pauseSplit: TimeInterval = 0.6
    static let paragraphGap: TimeInterval = 2.0
    static let pauseMarkGap: TimeInterval = 6.0
    static let maxPhraseChars = 120
    /// A line already holds a half-bar once it reaches this many syllables.
    static let halfBarSyllables = 6
    static let lineFontSize: CGFloat = 17

    nonisolated static func phrases(
        from segments: [TranscriptionSegment],
        bpm: Double? = nil,
        columnWidth: CGFloat? = nil,
        fitsLine: (@Sendable (String) -> Bool)? = nil
    ) -> [TranscriptPhrase] {
        let words = flatten(segments)
        guard !words.isEmpty else { return [] }
        let fits = fitsLine ?? { text in
            if let columnWidth {
                return self.fits(text, columnWidth: columnWidth)
            }
            return text.count <= maxPhraseChars
        }
        let raw = groupWords(words, bpm: bpm, fits: fits)
        let merged = mergeSameDisplayTimestamp(raw, bpm: bpm, fits: fits)
        return insertSilence(merged)
    }

    /// 17 pt system line. A few points of slack keep the last word from clipping.
    nonisolated static func fits(_ text: String, columnWidth: CGFloat, fontSize: CGFloat = lineFontSize) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        guard columnWidth > 8 else { return trimmed.count <= maxPhraseChars }
        return measuredWidth(trimmed, fontSize: fontSize) <= columnWidth - 4
    }

    nonisolated static func measuredWidth(_ text: String, fontSize: CGFloat = lineFontSize) -> CGFloat {
        let font = CTFontCreateUIFontForLanguage(.system, fontSize, nil)
        let attributes = [kCTFontAttributeName: font] as CFDictionary
        guard let attributed = CFAttributedStringCreate(kCFAllocatorDefault, text as CFString, attributes) else {
            return .greatestFiniteMagnitude
        }
        let line = CTLineCreateWithAttributedString(attributed)
        return CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    }

    /// About five seconds of speech on one timeline row.
    /// A whole bar stays on that row, so a setup and its punch are not split
    /// when a new word arrives.
    static let timelineWindow: TimeInterval = 5

    nonisolated static func timelinePhrases(
        from segments: [TranscriptionSegment],
        bpm: Double? = nil
    ) -> [TranscriptPhrase] {
        let words = flatten(segments)
        guard !words.isEmpty else { return [] }
        return timelineGroups(words: words, bpm: bpm, window: timelineWindow)
    }

    /// How many whole bars land nearest a five-second row. One bar minimum,
    /// so a slow bar is never cut between its setup and its punch.
    nonisolated static func barsPerTimelineRow(barSeconds: TimeInterval, window: TimeInterval = timelineWindow) -> Int {
        guard barSeconds > 0, window > 0 else { return 1 }
        let lower = max(1, Int(floor(window / barSeconds)))
        let upper = lower + 1
        let lowerDelta = abs(Double(lower) * barSeconds - window)
        let upperDelta = abs(Double(upper) * barSeconds - window)
        return upperDelta < lowerDelta ? upper : lower
    }

    /// `m:ss` under an hour, `h:mm:ss` after — same label Notes-style rows share.
    nonisolated static func displayTimestamp(_ time: TimeInterval) -> String {
        let totalSeconds = max(0, Int(time))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    nonisolated static func beatInBar(time: TimeInterval, bpm: Double) -> Int {
        guard bpm > 0 else { return 1 }
        let beat = 60.0 / bpm
        let index = Int(floor(max(0, time) / beat)) % 4
        return index + 1
    }

    nonisolated static func barIndex(time: TimeInterval, bpm: Double) -> Int {
        guard bpm > 0 else { return 0 }
        return Int(floor(max(0, time) / (240.0 / bpm)))
    }

    // MARK: - Group

    nonisolated private static func groupWords(
        _ words: [WordTiming],
        bpm: Double?,
        fits: (String) -> Bool
    ) -> [TranscriptPhrase] {
        var lines: [[WordTiming]] = []
        var current: [WordTiming] = []

        func close() {
            if !current.isEmpty {
                lines.append(current)
            }
            current = []
        }

        for (index, word) in words.enumerated() {
            if current.isEmpty {
                current = [word]
                continue
            }
            let previous = current[current.count - 1]
            let gap = word.timestamp - (previous.timestamp + previous.duration)
            if gap >= pauseSplit {
                close()
                current = [word]
                continue
            }
            if let bpm, bpm > 0, barIndex(time: word.timestamp, bpm: bpm) != barIndex(time: current[0].timestamp, bpm: bpm) {
                close()
                current = [word]
                continue
            }
            if let bpm, bpm > 0,
               beatInBar(time: current[0].timestamp, bpm: bpm) <= 2,
               beatInBar(time: word.timestamp, bpm: bpm) >= 3,
               !fullBarFits(current: current, from: index, words: words, bpm: bpm, fits: fits) {
                close()
                current = [word]
                continue
            }
            let combined = phraseText(current + [word])
            let nextWouldFit = fits(combined)
            if endsSentence(previous.text), syllableCount(current) >= halfBarSyllables || !nextWouldFit {
                close()
                current = [word]
                continue
            }
            if !nextWouldFit {
                close()
                current = [word]
                continue
            }
            current.append(word)
        }
        if !current.isEmpty {
            lines.append(current)
        }
        return lines.compactMap { makePhrase(from: $0) }
    }

    /// Setup plus the rest of this bar, stopping at a breath or the next bar.
    nonisolated private static func fullBarFits(
        current: [WordTiming],
        from index: Int,
        words: [WordTiming],
        bpm: Double,
        fits: (String) -> Bool
    ) -> Bool {
        let bar = barIndex(time: current[0].timestamp, bpm: bpm)
        var gathered = current
        var cursor = index
        while cursor < words.count {
            let word = words[cursor]
            let previous = gathered[gathered.count - 1]
            let gap = word.timestamp - (previous.timestamp + previous.duration)
            if gap >= pauseSplit { break }
            if barIndex(time: word.timestamp, bpm: bpm) != bar { break }
            gathered.append(word)
            cursor += 1
        }
        return fits(phraseText(gathered))
    }

    nonisolated private static func phraseText(_ words: [WordTiming]) -> String {
        words.map(\.text).joined(separator: " ")
    }

    nonisolated private static func syllableCount(_ words: [WordTiming]) -> Int {
        words.reduce(0) { $0 + Syllabifier.syllableCount(word: $1.text) }
    }

    // MARK: - Flatten

    nonisolated private static func flatten(_ segments: [TranscriptionSegment]) -> [WordTiming] {
        var out: [WordTiming] = []
        let sorted = segments.sorted { $0.timestamp < $1.timestamp }
        for seg in sorted {
            if let timings = seg.wordTimings, !timings.isEmpty {
                for timing in timings {
                    let text = timing.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { continue }
                    out.append(contentsOf: explodeRun(text: text, start: timing.timestamp, duration: max(0.05, timing.duration)))
                }
                continue
            }
            let text = seg.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { continue }
            out.append(contentsOf: explodeRun(text: text, start: seg.timestamp, duration: max(0.05, seg.duration)))
        }
        return out
    }

    /// A Speech run may be one word or several; split on whitespace and spread the range.
    nonisolated private static func explodeRun(text: String, start: TimeInterval, duration: TimeInterval) -> [WordTiming] {
        let parts = text.split(whereSeparator: { $0.isWhitespace }).map(String.init).filter { !$0.isEmpty }
        guard !parts.isEmpty else { return [] }
        if parts.count == 1 {
            return [WordTiming(text: parts[0], timestamp: start, duration: duration)]
        }
        let each = duration / Double(parts.count)
        return parts.enumerated().map { index, part in
            WordTiming(text: part, timestamp: start + Double(index) * each, duration: max(0.05, each))
        }
    }

    /// Time buckets. A later word joins the open row or starts the next one.
    /// It does not move words that already belong to an earlier row.
    nonisolated private static func timelineGroups(
        words: [WordTiming],
        bpm: Double?,
        window: TimeInterval
    ) -> [TranscriptPhrase] {
        let tempo = bpm.flatMap { $0 > 0 ? $0 : nil }
        let barSeconds = tempo.map { 240.0 / $0 }
        let barsPerRow = barSeconds.map { barsPerTimelineRow(barSeconds: $0, window: window) } ?? 1
        var groups: [[WordTiming]] = []
        var current: [WordTiming] = []

        func close() {
            if !current.isEmpty {
                groups.append(current)
            }
            current = []
        }

        for word in words {
            if current.isEmpty {
                current = [word]
                continue
            }
            if belongsOnCurrentTimelineRow(
                word,
                current: current,
                bpm: tempo,
                barsPerRow: barsPerRow,
                window: window
            ) {
                current.append(word)
            } else {
                close()
                current = [word]
            }
        }
        close()
        return groups.compactMap { makePhrase(from: $0) }
    }

    nonisolated private static func belongsOnCurrentTimelineRow(
        _ word: WordTiming,
        current: [WordTiming],
        bpm: Double?,
        barsPerRow: Int,
        window: TimeInterval
    ) -> Bool {
        let start = current[0].timestamp
        if let bpm, bpm > 0 {
            let startGroup = barIndex(time: start, bpm: bpm) / max(1, barsPerRow)
            let wordGroup = barIndex(time: word.timestamp, bpm: bpm) / max(1, barsPerRow)
            return wordGroup == startGroup
        }
        let windowEnd = (floor(max(0, start) / window) * window) + window
        if word.timestamp < windowEnd { return true }
        let previous = current[current.count - 1]
        let gap = word.timestamp - (previous.timestamp + previous.duration)
        // The punch crossed the five-second line without a breath. Keep it
        // with the setup, and stop once another short bar's worth has passed.
        return gap < pauseSplit && word.timestamp < windowEnd + 4
    }

    nonisolated private static func makePhrase(from words: [WordTiming]) -> TranscriptPhrase? {
        guard !words.isEmpty else { return nil }
        let text = phraseText(words)
        let start = words[0].timestamp
        let end = words[words.count - 1].timestamp + words[words.count - 1].duration
        return TranscriptPhrase(
            text: text,
            timestamp: start,
            duration: max(0.15, end - start),
            wordTimings: words,
            isPause: false
        )
    }

    nonisolated static func endsSentence(_ text: String) -> Bool {
        let stripped = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"'”’))"))
        guard let last = stripped.last else { return false }
        return ".?!…".contains(last)
    }

    /// Glue leftover splits that would print the same `2:40` with no breath between them.
    /// A setup/punch split stays split when the joined line would not fit. A new bar never merges back.
    nonisolated private static func mergeSameDisplayTimestamp(
        _ phrases: [TranscriptPhrase],
        bpm: Double?,
        fits: (String) -> Bool
    ) -> [TranscriptPhrase] {
        var merged: [TranscriptPhrase] = []
        for phrase in phrases {
            guard !phrase.isPause, let last = merged.last, !last.isPause else {
                merged.append(phrase)
                continue
            }
            let gap = phrase.timestamp - (last.timestamp + last.duration)
            let sameLabel = displayTimestamp(last.timestamp) == displayTimestamp(phrase.timestamp)
            let combined = last.text + " " + phrase.text
            let crossesBar = bpm.map { barIndex(time: last.timestamp, bpm: $0) != barIndex(time: phrase.timestamp, bpm: $0) } ?? false
            let crossesPunch = bpm.map {
                beatInBar(time: last.timestamp, bpm: $0) <= 2 && beatInBar(time: phrase.timestamp, bpm: $0) >= 3
            } ?? false
            if sameLabel, !endsSentence(last.text), gap < pauseSplit, fits(combined), !crossesBar, !crossesPunch {
                let words = last.wordTimings + phrase.wordTimings
                let end = max(last.timestamp + last.duration, phrase.timestamp + phrase.duration)
                merged[merged.count - 1] = TranscriptPhrase(
                    text: combined,
                    timestamp: last.timestamp,
                    duration: max(0.15, end - last.timestamp),
                    wordTimings: words,
                    isPause: false
                )
            } else {
                merged.append(phrase)
            }
        }
        return merged
    }

    nonisolated private static func insertSilence(_ phrases: [TranscriptPhrase]) -> [TranscriptPhrase] {
        guard !phrases.isEmpty else { return phrases }
        var out: [TranscriptPhrase] = []
        for (index, phrase) in phrases.enumerated() {
            if index > 0 {
                let prev = phrases[index - 1]
                let gapStart = prev.timestamp + prev.duration
                let gap = phrase.timestamp - gapStart
                if gap >= pauseMarkGap {
                    out.append(TranscriptPhrase(
                        text: "···",
                        timestamp: gapStart,
                        duration: gap,
                        wordTimings: [],
                        isPause: true
                    ))
                } else if gap >= paragraphGap {
                    out.append(TranscriptPhrase(
                        text: "",
                        timestamp: gapStart,
                        duration: gap,
                        wordTimings: [],
                        isPause: true
                    ))
                }
            }
            out.append(phrase)
        }
        return out
    }
}
