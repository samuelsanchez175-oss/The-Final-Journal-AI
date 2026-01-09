import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var title: String
    var body: String
    var audioPath: String?
    var transcription: String?
    
    // MARK: - Metadata Fields
    var bpm: Int? // 60-220
    var key: String? // Musical key (e.g., "C", "D", "A#")
    var scale: String? // Scale type (e.g., "Major", "Dorian", "Chromatic")
    var urlAttachment: String? // URL for YouTube beat, etc.
    var folder: String? // Folder name for filtering

    init(timestamp: Date, title: String = "", body: String = "") {
        self.timestamp = timestamp
        self.title = title
        self.body = body
        self.audioPath = nil
        self.transcription = nil
        self.bpm = nil
        self.key = nil
        self.scale = nil
        self.urlAttachment = nil
        self.folder = nil
    }
}