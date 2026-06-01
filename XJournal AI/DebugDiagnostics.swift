import Foundation

// MARK: - PR 10: Debug Diagnostics for GeneratorPolicy

/// Feature flag to enable/disable GeneratorPolicy enforcement
struct GeneratorPolicyFeatureFlag {
    static var enableGeneratorPolicy: Bool = true
    static var enableGroundTruthInjection: Bool = true  // PR 15: GT injection feature flag
    
    static func isEnabled() -> Bool {
        return enableGeneratorPolicy
    }
    
    static func setEnabled(_ enabled: Bool) {
        enableGeneratorPolicy = enabled
    }
    
    static func isGroundTruthInjectionEnabled() -> Bool {
        return enableGroundTruthInjection
    }
    
    static func setGroundTruthInjectionEnabled(_ enabled: Bool) {
        enableGroundTruthInjection = enabled
    }
}

/// Injection mode for ground truth integration
enum InjectionMode: String, Codable {
    case direct  // Mode A: Direct retrieval
    case slotReplacement  // Mode B: Slot replacement
    case rhymeAnchoring  // Mode C: Rhyme anchoring
    case none  // No injection
}

/// Diagnostics for generation process
struct GenerationDiagnostics: Codable {
    let policy: GeneratorPolicy
    let rejectedLines: [RejectedLine]
    let indifferencePressure: Double
    let attempts: Int
    let finalSuggestions: Int
    let timestamp: Date
    // PR 15: Ground truth injection diagnostics
    let groundTruthBarId: String?
    let injectionMode: InjectionMode?
    let slotsReplaced: [String]?  // Simplified: just slot types replaced
    let rhymeAnchors: [RhymeAnchorInfo]?
    
    struct RejectedLine: Codable {
        let line: String
        let reason: RejectionReason
    }
    
    struct RhymeAnchorInfo: Codable {
        let ending: String
        let syllableCount: Int
    }
    
    enum RejectionReason: String, Codable {
        case forbiddenVerb
        case explanationToken
        case tooManyBrands
        case clauseTooLong
        case verbClassViolation
        case reflectiveTense
    }
    
    init(
        policy: GeneratorPolicy,
        rejectedLines: [(line: String, reason: RejectionReason)],
        indifferencePressure: Double,
        attempts: Int,
        finalSuggestions: Int,
        groundTruthBarId: String? = nil,
        injectionMode: InjectionMode? = nil,
        slotsReplaced: [String]? = nil,
        rhymeAnchors: [RhymeAnchorInfo]? = nil
    ) {
        self.policy = policy
        self.rejectedLines = rejectedLines.map { RejectedLine(line: $0.line, reason: $0.reason) }
        self.indifferencePressure = indifferencePressure
        self.attempts = attempts
        self.finalSuggestions = finalSuggestions
        self.timestamp = Date()
        self.groundTruthBarId = groundTruthBarId
        self.injectionMode = injectionMode
        self.slotsReplaced = slotsReplaced
        self.rhymeAnchors = rhymeAnchors
    }
    
    func log() {
        print("📊 ===== GENERATION DIAGNOSTICS =====")
        print("Policy: \(policy.artistBias.rawValue)")
        print("Indifference Pressure: \(String(format: "%.2f", indifferencePressure))")
        print("Attempts: \(attempts)")
        print("Final Suggestions: \(finalSuggestions)")
        
        // PR 15: Log ground truth injection info
        if let gtBarId = groundTruthBarId {
            print("Ground Truth Bar ID: \(gtBarId)")
        }
        if let mode = injectionMode {
            print("Injection Mode: \(mode.rawValue)")
        }
        if let slots = slotsReplaced, !slots.isEmpty {
            print("Slots Replaced: \(slots.joined(separator: ", "))")
        }
        if let anchors = rhymeAnchors, !anchors.isEmpty {
            print("Rhyme Anchors: \(anchors.count)")
            for anchor in anchors.prefix(3) {
                print("  - Ending: \(anchor.ending), Syllables: \(anchor.syllableCount)")
            }
        }
        
        if !rejectedLines.isEmpty {
            print("Rejected Lines: \(rejectedLines.count)")
            for rejectedLine in rejectedLines.prefix(5) {
                print("  - [\(rejectedLine.reason.rawValue)]: \(rejectedLine.line.prefix(50))...")
            }
        }
        print("=====================================")
    }
}

/// Logger for GeneratorPolicy operations
class GeneratorPolicyLogger {
    static let shared = GeneratorPolicyLogger()
    
    private var diagnosticsHistory: [GenerationDiagnostics] = []
    private let maxHistorySize = 50
    
    private init() {}
    
    func logDiagnostics(_ diagnostics: GenerationDiagnostics) {
        diagnostics.log()
        diagnosticsHistory.append(diagnostics)
        if diagnosticsHistory.count > maxHistorySize {
            diagnosticsHistory.removeFirst()
        }
    }
    
    func getRecentDiagnostics(limit: Int = 10) -> [GenerationDiagnostics] {
        return Array(diagnosticsHistory.suffix(limit))
    }
    
    func clearHistory() {
        diagnosticsHistory.removeAll()
    }
}

// MARK: - PR 10: SuperGunna Diagnostics

/// SuperGunna-specific diagnostics for detailed debugging
struct SuperGunnaDiagnostics: Codable {
    let selectedTemplate: String  // TemplateType.rawValue
    let rejectedReasons: [String]  // RejectionReason.rawValue array
    let indifferencePressure: Double
    let motifInjected: Bool
    let barsSinceLastPrice: Int
    let attemptNumber: Int
    let policy: GeneratorPolicy
    
    init(
        selectedTemplate: String,
        rejectedReasons: [String] = [],
        indifferencePressure: Double,
        motifInjected: Bool,
        barsSinceLastPrice: Int,
        attemptNumber: Int,
        policy: GeneratorPolicy
    ) {
        self.selectedTemplate = selectedTemplate
        self.rejectedReasons = rejectedReasons
        self.indifferencePressure = indifferencePressure
        self.motifInjected = motifInjected
        self.barsSinceLastPrice = barsSinceLastPrice
        self.attemptNumber = attemptNumber
        self.policy = policy
    }
    
    func log() {
        print("🎯 ===== SUPERGUNNA DIAGNOSTICS =====")
        print("Attempt: \(attemptNumber)")
        print("Selected Template: \(selectedTemplate)")
        print("Indifference Pressure: \(String(format: "%.2f", indifferencePressure))")
        print("Motif Injected: \(motifInjected ? "Yes" : "No")")
        print("Bars Since Last Price: \(barsSinceLastPrice)")
        if !rejectedReasons.isEmpty {
            print("Rejected Reasons: \(rejectedReasons.joined(separator: ", "))")
        }
        print("Policy - SuperGunna Enabled: \(policy.superGunnaEnabled)")
        print("Policy - Style Priority: \(String(format: "%.2f", policy.stylePriority))")
        print("Policy - Signal Exposure: \(policy.signalProfileExposure.rawValue)")
        print("Policy - Repeat Motif Every N Bars: \(policy.repeatMotifEveryNBars)")
        print("Policy - Motif Pool: \(policy.motifPool.joined(separator: ", "))")
        print("====================================")
    }
}
