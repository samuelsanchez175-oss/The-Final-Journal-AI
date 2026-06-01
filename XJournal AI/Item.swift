import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var modifiedDate: Date? // Track when item was last modified
    var title: String
    var body: String
    var audioPath: String?
    var transcription: String?
    var transcriptionSegments: [TranscriptionSegment]?
    var transcriptionRhythmMapData: Data? // JSON-encoded RhythmicTranscriptionResult
    var audioSummary: String?
    var audioDuration: TimeInterval?
    
    // MARK: - Metadata Fields
    var bpm: Int? // 60-220
    var key: String? // Musical key (e.g., "C", "D", "A#")
    var scale: String? // Scale type (e.g., "Major", "Dorian", "Chromatic")
    var urlAttachment: String? // URL for YouTube beat, etc.
    var folder: String? // Folder name for filtering

    // MARK: - Model G Beat Fingerprint
    var beatFingerprintData: Data? // JSON-encoded BeatFingerprint
    var beatFingerprintHash: String? // Hash to detect audio file changes; re-analyze only if changed

    // MARK: - AI Text Tracking
    var aiTextRanges: [String] = [] // Store AI text ranges as strings (startIndex:endIndex format)

    /// Encoded `NoteSuggestionSession` — last suggestion batch for this note (survives app restart).
    var lastSuggestionSessionData: Data?

    /// Theme Expansion picks that steer Model G generation for this note (empty → auto-detect).
    var selectedThemeIDs: [String] = []

    init(timestamp: Date, title: String = "", body: String = "") {
        self.timestamp = timestamp
        self.modifiedDate = nil // No modifications on creation
        self.title = title
        self.body = body
        self.audioPath = nil
        self.transcription = nil
        self.transcriptionSegments = nil
        self.audioSummary = nil
        self.audioDuration = nil
        self.bpm = nil
        self.key = nil
        self.scale = nil
        self.urlAttachment = nil
        self.folder = nil
        self.beatFingerprintData = nil
        self.beatFingerprintHash = nil
    }
}