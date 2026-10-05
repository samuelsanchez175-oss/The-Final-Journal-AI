import Foundation

/// Collapses a recognizer revision into the phrase it restates.
/// The kept row uses the later wording and the earlier timestamp.
nonisolated enum TranscriptRevision: Sendable {
    nonisolated static func absorb(
        _ segments: [TranscriptionSegment],
        _ phrase: TranscriptionSegment
    ) -> [TranscriptionSegment] {
        let trimmed = phrase.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return segments }
        let incoming = TranscriptionSegment(
            text: trimmed,
            timestamp: phrase.timestamp,
            duration: phrase.duration,
            startIndex: phrase.startIndex,
            length: phrase.length,
            wordTimings: phrase.wordTimings
        )
        let matches = segments.indices.filter { isRevision(segments[$0], incoming) }
        guard let keep = matches.first else {
            return (segments + [incoming]).sorted { $0.timestamp < $1.timestamp }
        }
        var result = segments
        let old = result[keep]
        let start = min(old.timestamp, incoming.timestamp)
        let end = max(old.timestamp + old.duration, incoming.timestamp + incoming.duration)
        result[keep] = TranscriptionSegment(
            text: incoming.text,
            timestamp: start,
            duration: max(0.15, end - start),
            startIndex: incoming.startIndex,
            length: incoming.length,
            wordTimings: anchored(incoming.wordTimings ?? old.wordTimings, to: start)
        )
        for index in matches.dropFirst().reversed() {
            result.remove(at: index)
        }
        return result.sorted { $0.timestamp < $1.timestamp }
    }

    /// True when `incoming` restates `existing` rather than starting a new line.
    nonisolated static func isRevision(
        _ existing: TranscriptionSegment,
        _ incoming: TranscriptionSegment
    ) -> Bool {
        let existingWords = words(in: existing.text)
        let incomingWords = words(in: incoming.text)
        guard !existingWords.isEmpty, !incomingWords.isEmpty else { return false }
        let shorter = existingWords.count <= incomingWords.count ? existingWords : incomingWords
        let longer = existingWords.count <= incomingWords.count ? incomingWords : existingWords
        let ordered = isOrderedSubset(shorter, longer)
        guard ordered else { return false }
        if overlap(existing, incoming) >= 0.2, shorter.count >= 2 {
            return true
        }
        let close = abs(existing.timestamp - incoming.timestamp) <= 1.5
        return close && shorter.count >= 3 && shorter.last == longer.last
    }

    /// The row clock is the first word. Pull that word back to the earlier timestamp.
    nonisolated private static func anchored(_ timings: [WordTiming]?, to start: TimeInterval) -> [WordTiming]? {
        guard var timings, let first = timings.first, first.timestamp > start + 0.01 else { return timings }
        timings[0] = WordTiming(
            text: first.text,
            timestamp: start,
            duration: first.duration + (first.timestamp - start)
        )
        return timings
    }

    nonisolated static func words(in text: String) -> [String] {
        text.lowercased()
            .split { !($0.isLetter || $0.isNumber || $0 == "'") }
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    nonisolated private static func isOrderedSubset(_ shorter: [String], _ longer: [String]) -> Bool {
        var index = 0
        for word in longer where index < shorter.count && word == shorter[index] {
            index += 1
        }
        return index == shorter.count
    }

    nonisolated private static func overlap(_ a: TranscriptionSegment, _ b: TranscriptionSegment) -> TimeInterval {
        let start = max(a.timestamp, b.timestamp)
        let end = min(a.timestamp + a.duration, b.timestamp + b.duration)
        return max(0, end - start)
    }
}
