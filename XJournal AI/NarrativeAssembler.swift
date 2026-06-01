import Foundation

// MARK: - Narrative Assembler
// The only place completeness is enforced
// Converts NarrativeDraft (incomplete) → NarrativeAnalysis (complete)

struct NarrativeAssembler {
    
    static func assemble(
        from draft: NarrativeDraft,
        signal: SignalProfile,
        model: SuggestionModel = .modelG  // PR 3: Model parameter for GeneratorPolicy
    ) -> NarrativeAnalysis {
        
        // Primary themes: use draft if non-empty, otherwise fallback
        let primaryThemes: [String]
        if model == .modelG {
            // SuperGunna: Ignore SignalProfile, use forced themes
            primaryThemes = draft.primaryThemes?.isEmpty == false
                ? draft.primaryThemes!
                : ["wealth", "fashion", "motion", "distrust"]
        } else {
            // Normal mode: use draft if non-empty, otherwise fallback to signal
            primaryThemes = draft.primaryThemes?.isEmpty == false
                ? draft.primaryThemes!
                : fallbackPrimaryThemes(from: signal)
        }
        
        // Secondary themes: use draft or empty array
        let secondaryThemes = draft.secondaryThemes ?? []
        
        // Detected tones: from draft.detectedTones, or [draft.emotionalTone], or [.neutral]. Never infer selected tones here.
        let detectedTones: [EmotionalTone] = draft.detectedTones ?? (draft.emotionalTone.map { [$0] } ?? [.neutral])
        
        // Narrative phase: use draft or default
        let narrativePhase: NarrativePhase
        if model == .modelG {
            // SuperGunna: Force forward motion phase (assertion = closest to "verse")
            narrativePhase = draft.narrativePhase ?? .assertion
        } else {
            // Normal mode: use draft or default to reflection
            narrativePhase = draft.narrativePhase ?? .reflection
        }
        
        // Perspective: use draft, signal hint, or default to first_person
        let perspective = draft.perspective ?? inferPerspective(from: signal)
        
        // Entities: use draft or empty array
        let entities = draft.entities ?? []
        
        // Summary: use draft if present, otherwise generate
        let summary = draft.summary?.isEmpty == false
            ? draft.summary!
            : generateSummary(
                themes: primaryThemes,
                tone: detectedTones.first ?? .neutral,
                phase: narrativePhase,
                perspective: perspective
            )
        
        // PR 3: Compute indifference pressure
        let tags = primaryThemes + secondaryThemes
        let indifferencePressure = computeIndifferencePressure(
            authorityVector: nil,  // Can be enhanced later with SignalAxes integration
            tags: tags,
            signalProfile: signal
        )
        
        // PR 3: Build GeneratorPolicy based on model
        let generatorPolicy: GeneratorPolicy
        if model == .modelG {
            // Theme-aware: relax "learn"/"understand" for reflective themes (betrayal, resilience, principle)
            let reflectiveThemeKeywords = ["betrayal", "resilience", "principle", "reflection", "lessons", "growth"]
            let hasReflectiveTheme = (primaryThemes + secondaryThemes).contains { theme in
                reflectiveThemeKeywords.contains { theme.lowercased().contains($0) }
            }
            let forbiddenVerbs = hasReflectiveTheme
                ? ["because", "so", "since", "picked up"]  // Allow "learn"/"understand" for reflective themes
                : ["learn", "understand", "because", "so", "since", "picked up"]
            
            // Model G: Full Gunna constraints with SuperGunna defaults
            generatorPolicy = GeneratorPolicy(
                artistBias: .gunna,
                allowedVerbClasses: [.transaction, .motion, .reflection],  // Allow reflection verbs for Gunna (authentic to his style)
                forbiddenVerbs: forbiddenVerbs,
                maxClauseSyllables: 14,  // Preferred 8-12, allow up to 14 for flow (was 12, caused rejections on reflective themes)
                brandPerBarMax: 1,
                priceAnchorEveryNBars: 3,
                templateBias: [.car, .spending, .brand, .loyalty, .priceOnObject],
                indifferencePressure: indifferencePressure,
                superGunnaEnabled: true,
                stylePriority: 1.0,
                userProfileWeight: 0.01,  // Minimal weight: generate as established artist, not regular user
                signalProfileExposure: .none,  // No signal profile exposure: ignore user's weak signals
                repeatMotifEveryNBars: 4,
                motifPool: ["depend on my mood", "backend huge", "based on the mood"]
            )
        } else {
            // Model Y: Neutral (no constraints)
            generatorPolicy = GeneratorPolicy.default
        }
        
        return NarrativeAnalysis(
            primaryThemes: primaryThemes,
            secondaryThemes: secondaryThemes,
            detectedTones: detectedTones,
            narrativePhase: narrativePhase,
            perspective: perspective,
            entities: entities,
            summary: summary,
            underlyingThemes: draft.underlyingThemes,
            topicTreatmentModes: draft.topicTreatmentModes,
            voiceType: draft.voiceType,
            thematicContradictions: draft.thematicContradictions,
            narrativeMomentum: draft.narrativeMomentum,
            contextualPlacement: draft.contextualPlacement,
            styleCharacteristics: draft.styleCharacteristics,
            keyPhrases: draft.keyPhrases,
            storyElements: draft.storyElements,
            continuationNeeds: draft.continuationNeeds,
            generatorPolicy: generatorPolicy  // PR 3: Policy built based on model
        )
    }
    
    // MARK: - Fallback Logic
    
    private static func fallbackPrimaryThemes(
        from signal: SignalProfile
    ) -> [String] {
        // Priority 1: Use signal profile theme candidates
        if let candidates = signal.themeCandidates, !candidates.isEmpty {
            return Array(candidates.prefix(3))
        }
        
        // Priority 2: Use CSV themes from NewRapDatabase
        let csvThemes = NewRapDatabase.shared.themes
        if !csvThemes.isEmpty {
            // Get primary themes from CSV (first 3 themes)
            return Array(csvThemes.prefix(3).map { $0.name })
        }
        
        // Priority 3: Default fallback
        return ["luxury", "hustle", "status"]
    }
    
    private static func inferPerspective(
        from signal: SignalProfile
    ) -> Perspective {
        signal.perspectiveHint ?? .first_person
    }
    
    private static func generateSummary(
        themes: [String],
        tone: EmotionalTone,
        phase: NarrativePhase,
        perspective: Perspective
    ) -> String {
        
        let themeText = themes.prefix(2).joined(separator: ", ")
        let perspectiveText = perspective.rawValue.replacingOccurrences(of: "_", with: " ")
        
        return "A \(tone.rawValue) \(perspectiveText) narrative focused on \(themeText) during the \(phase.rawValue) phase."
    }
    
    // MARK: - PR 2: Indifference Pressure Computation
    
    /// Computes indifference pressure (0.0-1.0) based on input signals
    /// Higher pressure = colder, more transactional, less explanatory output
    /// Lower pressure = warmer, more emotional, more explanatory output
    static func computeIndifferencePressure(
        authorityVector: String? = nil,  // Optional: AuthorityVector from SignalAxes (e.g., "control_hierarchy", "capital_flow")
        tags: [String] = [],  // Detected tags from narrative analysis
        signalProfile: SignalProfile
    ) -> Double {
        var pressure: Double = 0.0
        
        // Factor 1: Authority signals (higher authority = higher pressure)
        if let authority = authorityVector {
            if authority.contains("control_hierarchy") || authority.contains("capital_flow") {
                pressure += 0.3
            }
            if authority.contains("fashion_rank") || authority.contains("loyalty_infrastructure") {
                pressure += 0.2
            }
        }
        
        // Factor 2: Luxury/backend themes (higher = higher pressure)
        let luxuryKeywords = ["luxury", "wealth", "backend", "income", "capital", "spending", "investment"]
        let wealthKeywords = ["money", "cash", "rich", "expensive", "brand", "designer"]
        
        let allTags = tags + (signalProfile.themeCandidates ?? [])
        let lowercasedTags = allTags.map { $0.lowercased() }
        
        let luxuryCount = lowercasedTags.filter { tag in
            luxuryKeywords.contains { tag.contains($0) }
        }.count
        
        let wealthCount = lowercasedTags.filter { tag in
            wealthKeywords.contains { tag.contains($0) }
        }.count
        
        if luxuryCount > 0 {
            pressure += 0.25
        }
        if wealthCount > 0 {
            pressure += 0.15
        }
        if luxuryCount > 1 || wealthCount > 1 {
            pressure += 0.1  // Bonus for multiple luxury/wealth signals
        }
        
        // Factor 3: Low emotional cues (fewer emotions = higher pressure)
        let emotionalCues = signalProfile.emotionalCues ?? []
        if emotionalCues.isEmpty {
            pressure += 0.15  // No emotions = more indifferent
        } else if emotionalCues.count == 1 {
            pressure += 0.05  // Single emotion = slightly indifferent
        }
        // Multiple emotions = lower pressure (stays at current level)
        
        // Factor 4: Transactional language hints
        let transactionalKeywords = ["buy", "spend", "cop", "drop", "invest", "pay"]
        let hasTransactional = lowercasedTags.contains { tag in
            transactionalKeywords.contains { tag.contains($0) }
        }
        if hasTransactional {
            pressure += 0.1
        }
        
        // Clamp to 0.0-1.0
        return min(max(pressure, 0.0), 1.0)
    }
}
