import Foundation

// MARK: - Emotion Cue

struct EmotionCue: Codable {
    let emotion: String
    let intensity: Double? // 0.0-1.0, optional
}

// MARK: - Signal Profile
// Weak signals extracted from text (never required fields)
// All fields are optional - represents partial, incomplete signals

struct SignalProfile: Codable {
    let themeCandidates: [String]?
    let emotionalCues: [EmotionCue]?
    let perspectiveHint: Perspective?
    let entityHints: [Entity]?
    
    init(
        themeCandidates: [String]? = nil,
        emotionalCues: [EmotionCue]? = nil,
        perspectiveHint: Perspective? = nil,
        entityHints: [Entity]? = nil
    ) {
        self.themeCandidates = themeCandidates
        self.emotionalCues = emotionalCues
        self.perspectiveHint = perspectiveHint
        self.entityHints = entityHints
    }
}
