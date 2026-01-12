import Foundation

struct TranscriptionSegment: Codable, Identifiable {
    let id: UUID
    let text: String
    let timestamp: TimeInterval
    let duration: TimeInterval
    
    init(text: String, timestamp: TimeInterval, duration: TimeInterval) {
        self.id = UUID()
        self.text = text
        self.timestamp = timestamp
        self.duration = duration
    }
}
