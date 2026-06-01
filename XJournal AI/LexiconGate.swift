import Foundation

// MARK: - Lexicon Gate Result

enum LexiconGateResult {
    case allowed([LexiconTerm])  // Filtered allowed terms
    case silence(CriticCommentary)  // Silence preferred when generation would cheapen authority
}

// MARK: - Lexicon Gate

class LexiconGate {
    static let shared = LexiconGate()
    
    private let lexiconStore = LexiconStore.shared
    private var recentTermUsage: [String: [Date]] = [:]  // Track term usage over time
    private let recentBarsWindow = 20  // Track last 20 bars
    
    private init() {}
    
    // MARK: - Main Filtering Function
    
    /// Filters lexicon terms based on authority and exposure gates
    /// - Parameters:
    ///   - text: User's current text (for context)
    ///   - axes: Current signal axes
    ///   - profile: Signal profile (for authority calculation)
    ///   - scene: Scene to use (defaults to Atlanta)
    ///   - isKnownArtist: Whether this is a known artist (defaults to earned authority)
    /// - Returns: Filtered allowed terms or silence
    func filterAllowedTerms(
        text: String,
        axes: SignalAxes,
        profile: SignalProfile,
        scene: LexiconScene? = nil,
        isKnownArtist: Bool = false
    ) -> LexiconGateResult {
        guard let lexicon = lexiconStore.getLexicon(for: scene) else {
            // If no lexicon available, return empty (will fall back to normal generation)
            return .allowed([])
        }
        
        // Resolve speaker authority
        let speakerAuthority = resolveSpeakerAuthority(
            text: text,
            profile: profile,
            axes: axes,
            isKnownArtist: isKnownArtist
        )
        
        // Calculate exposure guarding threshold
        let exposureGuarding = calculateExposureGuarding(axes: axes)
        
        // Filter terms
        var allowedTerms: [LexiconTerm] = []
        var blockedCount = 0
        
        for term in lexicon.terms {
            // Apply memory-based adjustments
            let adjustedAuthorityRequirement = SignalMemory.shared.getAdjustedAuthorityThreshold(
                baseThreshold: term.authorityRequirement
            )
            let adjustedOverusePenalty = SignalMemory.shared.getAdjustedOverusePenalty(
                basePenalty: term.overusePenalty,
                category: term.category
            )
            
            // Check basic gates (with adjusted thresholds)
            guard adjustedAuthorityRequirement <= speakerAuthority else {
                blockedCount += 1
                continue
            }
            
            guard term.exposureCost <= exposureGuarding else {
                blockedCount += 1
                continue
            }
            
            // Check proof-or-implication for earned authority
            if isEarnedAuthority(speakerAuthority: speakerAuthority, axes: axes) {
                // Check if term requires proof/implication based on theme or category
                let requiresProof = term.themePrimary?.contains("wealth") == true || 
                                   term.category == .luxuryList ||
                                   term.category == .wealthAccess
                if requiresProof {
                    if !hasProofOrImplication(term: term, text: text) {
                        blockedCount += 1
                        continue
                    }
                }
            }
            
            // Check luxury list penalties (for contextual_signal with wealth theme)
            let isLuxuryTerm = term.category == .luxuryList || 
                             (term.category == .contextualSignal && term.themePrimary?.contains("wealth") == true)
            if isLuxuryTerm {
                if !passesLuxuryListCheck(term: term, text: text) {
                    blockedCount += 1
                    continue
                }
            }
            
            // Check overuse penalty (with adjusted penalty from memory)
            if hasOverusePenalty(term: term, adjustedPenalty: adjustedOverusePenalty) {
                blockedCount += 1
                continue
            }
            
            // Term passes all gates
            allowedTerms.append(term)
        }
        
        // If multiple blocks occur and generation would cheapen authority, prefer silence
        if blockedCount > allowedTerms.count && blockedCount >= 3 {
            let commentary = createSilenceCommentary(
                blockedCount: blockedCount,
                allowedCount: allowedTerms.count,
                axes: axes
            )
            return .silence(commentary)
        }
        
        return .allowed(allowedTerms)
    }
    
    // MARK: - Speaker Authority Resolution
    
    private func resolveSpeakerAuthority(
        text: String,
        profile: SignalProfile,
        axes: SignalAxes,
        isKnownArtist: Bool
    ) -> Double {
        // For known artists: default to earned authority
        if isKnownArtist {
            return 0.7  // Default earned authority for known artists
        }
        
        // For users: derive from consistency over bars, not single-line claims
        // Compute metrics from text to get numeric authority values
        let metrics = SignalIngest.shared.analyzeBehavior(text: text)
        return calculateUserAuthorityFromConsistency(text: text, metrics: metrics, axes: axes)
    }
    
    private func calculateUserAuthorityFromConsistency(
        text: String,
        metrics: SignalMetrics,
        axes: SignalAxes
    ) -> Double {
        // Split text into bars (lines)
        let bars = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Use last 10-15 bars for consistency check
        let recentBars = Array(bars.suffix(15))
        guard !recentBars.isEmpty else {
            // If no bars, use metrics authority as baseline
            return metrics.authorityPosture
        }
        
        // Calculate average authority from recent context
        var authorityMarkers = 0
        var totalWords = 0
        
        let authorityMarkersList = [
            "i am", "i'm", "i got", "i have", "i own", "i control",
            "i run", "i lead", "i make", "i decide", "i choose",
            "i know", "i see", "i understand", "i don't care",
            "cashing", "checks", "road", "movement", "timing",
            "paperwork", "logistics"
        ]
        
        let weakMarkersList = [
            "i think", "i guess", "i suppose", "maybe", "perhaps",
            "i'm not sure", "i don't know", "i hope", "i wish",
            "i'm rich", "i'm wealthy", "i have money"  // Hollow flex markers
        ]
        
        for bar in recentBars {
            let lowercased = bar.lowercased()
            let words = lowercased.components(separatedBy: .whitespaces)
            totalWords += words.count
            
            for marker in authorityMarkersList {
                if lowercased.contains(marker) {
                    authorityMarkers += 1
                }
            }
            
            for marker in weakMarkersList {
                if lowercased.contains(marker) {
                    authorityMarkers -= 1  // Penalize weak markers
                }
            }
        }
        
        guard totalWords > 0 else {
            return metrics.authorityPosture
        }
        
        // Calculate consistency score
        let consistencyScore = Double(authorityMarkers) / Double(totalWords) * 10.0
        let baseAuthority = metrics.authorityPosture
        
        // Combine: base authority weighted by consistency
        let finalAuthority = (baseAuthority * 0.6) + (min(consistencyScore, 1.0) * 0.4)
        
        return max(0.0, min(1.0, finalAuthority))
    }
    
    // MARK: - Exposure Guarding Calculation
    
    private func calculateExposureGuarding(axes: SignalAxes) -> Double {
        // Map exposure risk to guarding threshold
        switch axes.exposureRisk {
        case .low:
            return 1.0  // Allow high exposure cost terms
        case .medium:
            return 0.6  // Moderate threshold
        case .high:
            return 0.3  // Low threshold - block high exposure cost terms
        }
    }
    
    // MARK: - Earned Authority Check
    
    private func isEarnedAuthority(speakerAuthority: Double, axes: SignalAxes) -> Bool {
        // Authority is "earned" if speaker authority is high and axes show established posture
        return speakerAuthority >= 0.6 && axes.authorityPosture == .established
    }
    
    // MARK: - Proof-or-Implication Check
    
    private func hasProofOrImplication(term: LexiconTerm, text: String) -> Bool {
        let lowercased = text.lowercased()
        
        // Check for concrete logistics markers
        let logisticsMarkers = [
            "cashing", "checks", "road", "movement", "timing",
            "paperwork", "fifteen years", "years fed", "on the road",
            "bank", "robbing", "console", "stash"
        ]
        
        for marker in logisticsMarkers {
            if lowercased.contains(marker) {
                return true  // Has concrete logistics
            }
        }
        
        // Check for indirect implication (aftermath, maintenance, not acquisition)
        let implicationMarkers = [
            "still wearing", "same watch", "cost me", "smell",
            "aftermath", "maintenance", "inevitable"
        ]
        
        for marker in implicationMarkers {
            if lowercased.contains(marker) {
                return true  // Has indirect implication
            }
        }
        
        // Check if term itself suggests logistics/aftermath
        if term.category == .codedLogistics || term.category == .aftermath || term.category == .maintenance {
            return true
        }
        
        // Check if contextual signal has logistics/aftermath markers in notes
        if term.category == .contextualSignal {
            if let notes = term.notes?.lowercased() {
                if notes.contains("logistics") || notes.contains("aftermath") || notes.contains("maintenance") {
                    return true
                }
            }
        }
        
        // No proof or implication found - this is hollow flex
        return false
    }
    
    // MARK: - Luxury List Check
    
    private func passesLuxuryListCheck(term: LexiconTerm, text: String) -> Bool {
        let lowercased = text.lowercased()
        
        // Count luxury items in recent text
        let luxuryMarkers = [
            "watch", "chain", "designer", "gucci", "prada", "versace",
            "rolex", "diamond", "jewelry", "fashion", "brand"
        ]
        
        var luxuryCount = 0
        for marker in luxuryMarkers {
            if lowercased.contains(marker) {
                luxuryCount += 1
            }
        }
        
        // Exception: Allow single-item luxury if framed as aftermath/maintenance
        if luxuryCount == 1 {
            let aftermathMarkers = ["still", "same", "wearing", "maintenance", "aftermath"]
            for marker in aftermathMarkers {
                if lowercased.contains(marker) {
                    return true  // Single item with aftermath/maintenance framing passes
                }
            }
        }
        
        // Multiple luxury items or acquisition framing - apply steeper penalty
        if luxuryCount > 1 {
            // Check for acquisition markers
            let acquisitionMarkers = ["new", "bought", "got", "picked up", "copped"]
            for marker in acquisitionMarkers {
                if lowercased.contains(marker) {
                    return false  // Acquisition framing collapses
                }
            }
        }
        
        // Apply steeper penalty curve for luxury lists
        // If already used multiple times, block
        if let usageHistory = recentTermUsage[term.term.lowercased()] {
            let recentUsage = usageHistory.filter { Date().timeIntervalSince($0) < 300 } // Last 5 minutes
            if recentUsage.count > 2 {
                return false  // Too many luxury items recently
            }
        }
        
        return true
    }
    
    // MARK: - Overuse Penalty Check
    
    private func hasOverusePenalty(term: LexiconTerm, adjustedPenalty: Double) -> Bool {
        let termKey = term.term.lowercased()
        
        // Get recent usage
        guard let usageHistory = recentTermUsage[termKey] else {
            return false  // No usage history
        }
        
        // Filter to recent bars (last 20 bars worth of time, approximate 2-3 minutes)
        let recentUsage = usageHistory.filter { Date().timeIntervalSince($0) < 180 }
        
        // Apply penalty if used more than 3 times recently
        if recentUsage.count > 3 {
            return true  // Overuse penalty applies
        }
        
        // Check penalty threshold (use adjusted penalty from memory)
        let usageCount = Double(recentUsage.count)
        let penaltyThreshold = adjustedPenalty * 5.0  // Scale penalty
        
        return usageCount >= penaltyThreshold
    }
    
    // MARK: - Track Term Usage
    
    func trackTermUsage(_ term: String) {
        let termKey = term.lowercased()
        let now = Date()
        
        if recentTermUsage[termKey] == nil {
            recentTermUsage[termKey] = []
        }
        
        recentTermUsage[termKey]?.append(now)
        
        // Clean old entries (older than 5 minutes)
        recentTermUsage[termKey] = recentTermUsage[termKey]?.filter {
            Date().timeIntervalSince($0) < 300
        }
    }
    
    // MARK: - Silence Commentary
    
    private func createSilenceCommentary(
        blockedCount: Int,
        allowedCount: Int,
        axes: SignalAxes
    ) -> CriticCommentary {
        let explanation = "No lines generated. Multiple terms blocked by authority and exposure gates."
        let reason = "\(blockedCount) terms blocked, only \(allowedCount) allowed. Generation would cheapen authority."
        let guidance = "Consider using logistics/aftermath framing instead of direct wealth claims, or reduce exposure cost."
        
        return CriticCommentary(
            explanation: explanation,
            reason: reason,
            guidance: guidance
        )
    }
}
