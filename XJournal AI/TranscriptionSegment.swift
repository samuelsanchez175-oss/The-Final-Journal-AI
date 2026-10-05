import Foundation

/// One spoken token inside a phrase, with its audio range.
nonisolated struct WordTiming: Codable, Equatable, Sendable, Hashable {
    let text: String
    let timestamp: TimeInterval
    let duration: TimeInterval
}

/// One speech result (utterance/phrase). Word timings are children, not sibling rows.
nonisolated struct TranscriptionSegment: Codable, Identifiable, Sendable {
    let id: UUID
    let text: String
    let timestamp: TimeInterval
    let duration: TimeInterval
    /// Character range in the full transcript (for phrase-to-segment mapping). Optional for backward compatibility.
    let startIndex: Int?
    let length: Int?
    /// Per-word times from SpeechTranscriber runs. Nil on older saved transcripts.
    let wordTimings: [WordTiming]?

    nonisolated init(
        text: String,
        timestamp: TimeInterval,
        duration: TimeInterval,
        startIndex: Int? = nil,
        length: Int? = nil,
        wordTimings: [WordTiming]? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.timestamp = timestamp
        self.duration = duration
        self.startIndex = startIndex
        self.length = length
        self.wordTimings = wordTimings
    }
}
