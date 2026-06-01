import Foundation

// MARK: - Narrative Enums
// Aligned 1:1 with the JSON schema enums

enum EmotionalTone: String, Codable, CaseIterable {
    case neutral
    case confident
    case aggressive
    case melancholic
    case reflective
    case detached
    case hopeful
    case resentful
}

enum NarrativePhase: String, Codable {
    case setup
    case assertion
    case conflict
    case reflection
    case resolution
    case aftermath
}

enum Perspective: String, Codable {
    case first_person
    case second_person
    case third_person
    case collective
}

enum EntityType: String, Codable {
    case person
    case place
    case object
    case concept
    case brand
}

enum SignalExposure: String, Codable {
    case none      // No SignalProfile content
    case compact   // Minimal policy dump only
    case full      // Full SignalProfile + NarrativeAnalysis
}
