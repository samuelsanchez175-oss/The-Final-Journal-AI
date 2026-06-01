import Foundation

struct TranscriptionSegment: Codable, Identifiable {
    let id: UUID
    let text: String
    let timestamp: TimeInterval
    let duration: TimeInterval
    /// Character range in the full transcript (for phrase-to-segment mapping). Optional for backward compatibility.
    let startIndex: Int?
    let length: Int?
    
    nonisolated init(text: String, timestamp: TimeInterval, duration: TimeInterval, startIndex: Int? = nil, length: Int? = nil) {
        self.id = UUID()
        self.text = text
        self.timestamp = timestamp
        self.duration = duration
        self.startIndex = startIndex
        self.length = length
    }
}
