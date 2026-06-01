import Foundation

// MARK: - Thematic State

enum ThematicState {
    case wealthDripAscension  // Money, fashion, lifestyle, struggle, success (Gunna-adjacent)
    case none
}

// MARK: - Strength Mode

struct StrengthMode {
    let isActive: Bool
    let state: ThematicState
    let consecutiveBars: Int  // Number of consecutive bars showing signals
    
    static let inactive = StrengthMode(isActive: false, state: .none, consecutiveBars: 0)
}

// MARK: - Thematic State Detector

class ThematicStateDetector {
    static let shared = ThematicStateDetector()
    
    private var recentBarStates: [ThematicState] = []  // Track last 5 bars
    private let triggerGuardrail = 2  // Require 2-3 consecutive bars
    
    private init() {}
    
    // MARK: - Detect State
    
    /// Detects thematic state from text and axes
    /// - Parameters:
    ///   - text: User's current text
    ///   - axes: Current signal axes
    ///   - profile: Signal profile
    /// - Returns: Detected thematic state
    func detectState(text: String, axes: SignalAxes, profile: SignalProfile) -> ThematicState {
        // Check for Wealth-Drip-Ascension signals
        if hasWealthDripAscensionSignals(text: text, axes: axes, profile: profile) {
            return .wealthDripAscension
        }
        
        return .none
    }
    
    // MARK: - Check Strength Mode Activation
    
    /// Checks if Strength Mode should be activated based on consecutive bars
    /// - Parameters:
    ///   - text: Current text
    ///   - axes: Current signal axes
    ///   - profile: Signal profile
    /// - Returns: Strength Mode status
    func checkStrengthMode(text: String, axes: SignalAxes, profile: SignalProfile) -> StrengthMode {
        let currentState = detectState(text: text, axes: axes, profile: profile)
        
        // Track recent bar states
        recentBarStates.append(currentState)
        
        // Keep only last 5 bars
        if recentBarStates.count > 5 {
            recentBarStates.removeFirst()
        }
        
        // Check for consecutive Wealth-Drip-Ascension signals
        var consecutiveCount = 0
        for state in recentBarStates.reversed() {
            if state == .wealthDripAscension {
                consecutiveCount += 1
            } else {
                break
            }
        }
        
        // Trigger guardrail: require 2-3 consecutive bars
        if consecutiveCount >= triggerGuardrail && currentState == .wealthDripAscension {
            return StrengthMode(isActive: true, state: .wealthDripAscension, consecutiveBars: consecutiveCount)
        }
        
        return StrengthMode.inactive
    }
    
    // MARK: - Wealth-Drip-Ascension Detection
    
    private func hasWealthDripAscensionSignals(text: String, axes: SignalAxes, profile: SignalProfile) -> Bool {
        let lowercased = text.lowercased()
        
        // Check for money terms
        let moneyTerms = [
            "money", "cash", "checks", "dollar", "rich", "wealth", "paid",
            "bank", "stack", "bread", "paper", "bands", "hundreds", "thousands"
        ]
        var moneyCount = 0
        for term in moneyTerms {
            if lowercased.contains(term) {
                moneyCount += 1
            }
        }
        
        // Check for fashion terms
        let fashionTerms = [
            "designer", "gucci", "prada", "versace", "fashion", "drip",
            "watch", "chain", "jewelry", "diamond", "ice", "brand"
        ]
        var fashionCount = 0
        for term in fashionTerms {
            if lowercased.contains(term) {
                fashionCount += 1
            }
        }
        
        // Check for independence terms
        let independenceTerms = [
            "independent", "own", "control", "run", "lead", "make", "decide",
            "freedom", "free", "no one", "nobody", "myself"
        ]
        var independenceCount = 0
        for term in independenceTerms {
            if lowercased.contains(term) {
                independenceCount += 1
            }
        }
        
        // Require co-occurrence: money + fashion + independence
        let hasMoney = moneyCount > 0
        let hasFashion = fashionCount > 0
        let hasIndependence = independenceCount > 0
        
        guard hasMoney && hasFashion && hasIndependence else {
            return false
        }
        
        // Compute metrics from text to access numeric properties
        let metrics = SignalIngest.shared.analyzeBehavior(text: text)
        
        // Check axes: trend toward earned authority, guarded exposure, low explanation
        let hasEarnedAuthority = axes.authorityPosture == .established || metrics.authorityPosture > 0.6
        let hasGuardedExposure = axes.exposureRisk == .low || axes.exposureRisk == .medium
        let hasLowExplanation = !metrics.hasHighExplanation || metrics.explanationDensity < 0.4
        
        // Check if lexicon terms would pass authority gates (no aspirational leakage)
        // This is approximated by checking if authority is high enough
        let noAspirationalLeakage = metrics.authorityPosture >= 0.5
        
        return hasEarnedAuthority && hasGuardedExposure && hasLowExplanation && noAspirationalLeakage
    }
    
    // MARK: - Reset
    
    func reset() {
        recentBarStates = []
    }
}

// MARK: - Strength Mode Configuration

extension StrengthMode {
    /// Returns generation bias instructions for Strength Mode
    var generationBias: String {
        guard isActive else { return "" }
        
        return """
        STRENGTH MODE ACTIVE (Wealth-Drip-Ascension):
        - Bias toward IMPLICATION over declaration
        - Prefer LOGISTICS over luxury lists
        - Prefer AFTERMATH over action
        - Compression + restraint (silence preferred over multiple decent lines)
        - One restrained line beats multiple decent ones
        - Mirror assumption of understanding (don't justify, don't explain)
        """
    }
    
    /// Returns whether silence should be preferred
    var prefersSilence: Bool {
        return isActive
    }
}
