import Foundation
import Security
import NaturalLanguage

// MARK: - Model Types

enum SuggestionModel: String, CaseIterable {
    case modelG = "Model G"
    case modelY = "Model Y"
    
    var displayName: String {
        return rawValue
    }
    
    var modelIdentifier: String {
        switch self {
        case .modelG:
            return "gpt-4-turbo-preview"
        case .modelY:
            return "gpt-4-turbo-preview" // Can be changed to different model if needed
        }
    }
    
    var temperature: Double {
        switch self {
        case .modelG:
            return 0.6
        case .modelY:
            return 0.6 // Can be adjusted for Model Y
        }
    }
}

// MARK: - API Models

struct NarrativeAnalysis: Codable {
    let primaryThemes: [String]
    let secondaryThemes: [String]
    let underlyingThemes: [String]? // Themes beneath the surface (isolation, betrayal, etc.)
    let topicTreatmentModes: TopicTreatmentModes? // How different topics are treated
    let voiceType: String? // "defensive", "vulnerable", "mixed", "guarded", "introspective"
    let thematicContradictions: [String]? // Detected contradictions/ironies
    let narrativeMomentum: String? // "building-tension", "escapist-relief", "maintaining", "transitioning"
    let contextualPlacement: String? // "opening", "mid-album", "reflection", "climax", "outro"
    let emotionalTone: String
    let narrativePhase: String // "intro", "build", "climax", "outro", etc.
    let entities: [String] // People, places, objects mentioned
    let perspective: String // "first-person", "third-person", etc.
    let summary: String
    let styleCharacteristics: StyleCharacteristics? // Style traits extracted from text
    let keyPhrases: [String]? // Important phrases/concepts for continuity
    let storyElements: [String]? // Key narrative elements to continue/reference
    let continuationNeeds: String? // What the next lines should accomplish narratively
}

struct StyleCharacteristics: Codable {
    let vocabularyLevel: String? // "simple", "complex", "mixed"
    let sentenceStructure: String? // "short-punchy", "long-flowing", "varied"
    let figurativeLanguage: String? // "heavy", "moderate", "minimal"
    let energyLevel: String? // "high", "medium", "low", "varied"
    let formalityLevel: String? // "street-slang", "formal", "mixed"
    let repetitionPatterns: String? // Description of repetition style
    let punctuationStyle: String? // Description of punctuation usage
}

struct TopicTreatmentModes: Codable {
    let women: String? // "aesthetic", "relational", "mixed", "not-present"
    let wealth: String? // "flexing", "burden", "ironic", "straightforward"
    let success: String? // "celebration", "obligation", "isolation", "mixed"
    // Can add more topics as needed
}

struct RapSuggestion: Codable, Identifiable {
    let id: UUID
    let text: String
    let confidence: Double
    let source: String? // Original artist/song if adapted
    let reasoning: String? // Why this suggestion fits
    let themes: [String] // Themes extracted from the suggestion
    
    // Quality metrics (Phase 1: AI Quality Foundation)
    var rhymeStrength: Double? // 0.0-1.0, strength of rhymes in suggestion
    var flowMatch: Double? // 0.0-1.0, how well flow matches existing text
    var styleMatch: Double? // 0.0-1.0, how well style matches user's writing
    var userFeedback: SuggestionFeedback? // User's 👍/👎 feedback
    
    // SIGNAL LAYER metrics
    var signalStrength: Double? // 0.0-1.0, signal clarity score (replaces confidence for display)
    var signalNote: String? // Signal Layer feedback note
    
    enum SuggestionFeedback: String, Codable {
        case liked = "liked"
        case disliked = "disliked"
    }
}

// MARK: - API Client

class RapSuggestionAPI {
    static let shared = RapSuggestionAPI()
    
    private let baseURL = "https://api.openai.com/v1"
    private var apiKey: String? {
        // Retrieve from Keychain
        return KeychainHelper.shared.getAPIKey()
    }
    
    // Internal accessors for extensions
    internal var internalAPIKey: String? { apiKey }
    internal var internalBaseURL: String { baseURL }
    
    private init() {}
    
    // MARK: - Settings Loading
    
    func loadModelSettings(for model: SuggestionModel) -> ModelSettings {
        let key = model == .modelG ? "modelG_settings" : "modelY_settings"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(ModelSettings.self, from: data) {
            return decoded
        }
        return ModelSettings() // Return defaults if not found
    }
    
    func loadUserPersonalDetails() -> UserPersonalDetails {
        if let data = UserDefaults.standard.data(forKey: "user_personal_details"),
           let decoded = try? JSONDecoder().decode(UserPersonalDetails.self, from: data) {
            return decoded
        }
        return UserPersonalDetails() // Return empty if not found
    }
    
    // MARK: - Narrative Analysis
    
    func analyzeNarrative(text: String, lastNLines: [String], model: SuggestionModel = .modelG) async throws -> NarrativeAnalysis {
        guard apiKey != nil else {
            throw RapAPIError.missingAPIKey
        }
        
        let prompt = """
        Analyze this rap verse and extract structured information with deep narrative understanding:
        
        Full text:
        \(text)
        
        Last 3 lines (immediate context):
        \(lastNLines.joined(separator: "\n"))
        
        Extract and return JSON with:
        - primaryThemes: Array of 2-4 main themes (e.g., ["luxury", "hustle", "status"])
        - secondaryThemes: Array of 1-3 secondary themes
        - underlyingThemes: Array of 0-3 themes beneath the surface that contrast with or complicate primary themes (e.g., ["isolation", "betrayal", "burden"]). These are emotional/psychological themes that exist alongside or beneath surface themes. If no underlying themes are present, use empty array [].
        - topicTreatmentModes: Object describing how specific topics are treated in the verse:
          - women: "aesthetic" (treated as lifestyle/visual element), "relational" (deep emotional connection), "mixed", or "not-present"
          - wealth: "flexing" (celebration/showing off), "burden" (creating problems), "ironic" (contradictory treatment), or "straightforward"
          - success: "celebration" (positive), "obligation" (feels like duty), "isolation" (creates distance), or "mixed"
        - voiceType: One of "defensive" (guarded, justifying, protecting), "vulnerable" (introspective, open, emotional), "mixed", "guarded", or "introspective". Detect based on how the speaker presents themselves - defensive voice defends choices/actions, vulnerable voice explores emotions openly.
        - thematicContradictions: Array of 0-3 detected contradictions or ironies in the verse (e.g., ["success feels like obligation", "wealth creates isolation", "celebration masks betrayal"]). These are tensions between what is said and what is felt, or between themes. If no contradictions exist, use empty array [].
        - narrativeMomentum: One of "building-tension" (escalating energy/stakes), "escapist-relief" (providing escape from heavier themes), "maintaining" (keeping current energy level), or "transitioning" (shifting between states). Detect based on the verse's emotional and narrative trajectory.
        - contextualPlacement: One of "opening" (introducing themes/narrative), "mid-album" (developing narrative), "reflection" (introspective moment), "climax" (peak intensity), or "outro" (concluding/resolving). Infer based on verse position, content, and narrative function.
        - emotionalTone: Single tone (e.g., "confident", "gritty", "aspirational", "vulnerable", "defensive")
        - narrativePhase: One of "intro", "build", "climax", "outro", "bridge", "verse" - detect based on full text narrative progression and story arc position
        - entities: Array of people, places, objects mentioned throughout the verse
        - perspective: "first-person" or "third-person"
        - summary: 1-2 sentence summary of the verse's meaning and narrative arc
        - styleCharacteristics: Object with style traits extracted from the FULL text:
          - vocabularyLevel: "simple", "complex", or "mixed" (analyze word choice complexity)
          - sentenceStructure: "short-punchy", "long-flowing", or "varied" (analyze line length and structure patterns)
          - figurativeLanguage: "heavy", "moderate", or "minimal" (count metaphors, similes, imagery)
          - energyLevel: "high", "medium", "low", or "varied" (assess intensity and aggressiveness)
          - formalityLevel: "street-slang", "formal", or "mixed" (analyze language register)
          - repetitionPatterns: Brief description of repetition style (e.g., "repetitive hooks", "varied", "minimal", "anaphora", "epistrophe")
          - punctuationStyle: Description of punctuation usage (e.g., "sparse", "frequent", "dramatic", "minimal commas")
        - keyPhrases: Array of 3-7 important phrases, concepts, or words from the verse that should be referenced for continuity (prioritize phrases that appear multiple times or are central to the narrative)
        - storyElements: Array of key narrative elements (characters, settings, conflicts, objects, relationships) that should be continued/referenced in next lines
        - continuationNeeds: String describing what the next lines should accomplish narratively (e.g., "build tension", "resolve conflict", "develop character", "maintain momentum", "introduce new element", "escalate stakes")
        
        Analysis Guidelines (CRITICAL - analyze FULL text):
        - Analyze the FULL text for narrative progression, not just surface themes
        - Detect underlying themes: Identify emotional/psychological themes that exist beneath or contrast with primary themes (e.g., success masking isolation, wealth creating burden, celebration hiding betrayal). Look for contradictions, tensions, or layers in the narrative. If primary themes are "wealth" and "success", underlying themes might be "isolation", "burden", "obligation". If no underlying themes exist, use empty array [].
        - Detect topic treatment modes: Analyze how specific topics are treated:
          - Women: Are they referenced as aesthetic elements (appearance, lifestyle) or relational (emotional connection, relationships)? Or mixed?
          - Wealth: Is it celebrated/flexed, treated as burden/problem, or presented ironically?
          - Success: Is it celebrated, treated as obligation/duty, or creating isolation?
        - Detect voice type: Determine if the speaker's voice is defensive (guarded, justifying choices, protecting self), vulnerable (introspective, open about emotions, exploring feelings), or mixed. Look for language patterns: defensive uses justification/rationalization, vulnerable uses introspection/emotion.
        - Detect thematic contradictions/ironies: Identify contradictions or tensions in the verse (e.g., "success feels like obligation", "wealth creates isolation", "celebration masks betrayal"). Look for tensions between what is said and what is felt, or between different themes. If no contradictions exist, use empty array [].
        - Detect narrative momentum: Determine the verse's emotional and narrative trajectory: "building-tension" (escalating energy/stakes), "escapist-relief" (providing escape from heavier themes), "maintaining" (keeping current energy level), or "transitioning" (shifting between states). Consider whether the verse is building toward something, providing relief, maintaining status quo, or transitioning.
        - Infer contextual placement: Based on verse position, content, and narrative function, determine where this verse sits in a larger narrative: "opening" (introducing themes/narrative), "mid-album" (developing narrative), "reflection" (introspective moment), "climax" (peak intensity), or "outro" (concluding/resolving). Consider verse length, introduction of new elements, resolution of conflicts, and narrative phase.
        - Identify story elements: Extract characters, setting, conflict, resolution, objects, relationships from the entire verse
        - Extract style characteristics: Analyze vocabulary complexity, sentence structure patterns, figurative language usage, energy level, formality, repetition patterns, and punctuation style from the FULL text
        - Identify key phrases/concepts: Find phrases, words, or concepts that appear multiple times or are central to narrative continuity
        - Determine narrative function: Based on the full verse context and narrative phase, determine what the next lines should accomplish (build tension, resolve, develop, escalate, etc.)
        - Narrative phase detection: Consider the full verse length, story progression, and emotional arc to determine if this is intro, build, climax, outro, bridge, or verse
        - Style detection: Look for patterns across the entire verse, not just recent lines
        
        Return ONLY valid JSON, no markdown, no code blocks.
        """
        
        let requestBody: [String: Any] = [
            "model": model.modelIdentifier,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a rap lyric analyst specializing in deep narrative analysis. Extract themes (including underlying themes beneath surface themes), tone, narrative structure, style characteristics, topic treatment modes, voice type, thematic contradictions, narrative momentum, contextual placement, and story elements from rap verses. Analyze the FULL text for narrative progression, thematic layering (primary themes vs underlying emotional/psychological themes), stylistic patterns, and story elements. Detect underlying themes that contrast with or complicate primary themes (e.g., success masking isolation, wealth creating burden). Detect how topics are treated (women as aesthetic vs relational, wealth as flexing vs burden, success as celebration vs obligation). Detect voice type (defensive vs vulnerable). Detect thematic contradictions/ironies (tensions between what is said and what is felt). Detect narrative momentum (building tension vs escapist relief vs maintaining vs transitioning). Infer contextual placement (where verse sits in larger narrative: opening, mid-album, reflection, climax, outro). Identify key phrases for continuity, and determine what the next lines should accomplish narratively. Always return valid JSON."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.3,
            "response_format": ["type": "json_object"]
        ]
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RapAPIError.requestFailed
        }
        
        let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = jsonResponse.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw RapAPIError.invalidResponse
        }
        
        return try JSONDecoder().decode(NarrativeAnalysis.self, from: jsonData)
    }
    
    // MARK: - Semantic Search (using embeddings)
    
    func searchLyrics(
        narrativeSummary: String,
        themes: [String],
        limit: Int = 200
    ) async throws -> [RapLine] {
        // For now, use simple keyword matching
        // In production, this would use embeddings for semantic search
        let database = RapLyricsDatabase.shared
        
        // Search by themes
        var results = database.searchLyricsByTheme(themes)
        
        // If we have narrative summary, filter by keyword matching
        if !narrativeSummary.isEmpty {
            let keywords = extractKeywords(from: narrativeSummary)
            results = results.filter { line in
                keywords.contains { keyword in
                    line.text.localizedCaseInsensitiveContains(keyword) ||
                    (line.context?.localizedCaseInsensitiveContains(keyword) ?? false)
                }
            }
        }
        
        // Limit results
        return Array(results.prefix(limit))
    }
    
    private func extractKeywords(from text: String) -> [String] {
        // Simple keyword extraction (in production, use NLP)
        let words = text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }
            .filter { !stopWords.contains($0) }
        
        return Array(Set(words)).prefix(10).map { $0 }
    }
    
    private let stopWords = Set(["the", "and", "for", "are", "but", "not", "you", "all", "can", "her", "was", "one", "our", "out", "day", "get", "has", "him", "his", "how", "its", "may", "new", "now", "old", "see", "two", "way", "who", "boy", "did", "she", "use", "her", "many", "than", "them", "these", "this", "that", "with", "from", "have", "been", "will", "what", "when", "where", "which"])
    
    // MARK: - Controlled Rewriting
    
    func generateSuggestions(
        candidates: [RapLine],
        metrics: RapMetrics,
        narrative: NarrativeAnalysis,
        model: SuggestionModel = .modelG,
        settings: ModelSettings? = nil,
        userDetails: UserPersonalDetails? = nil,
        constraints: ConstraintRules? = nil
    ) async throws -> [RapSuggestion] {
        guard apiKey != nil else {
            throw RapAPIError.missingAPIKey
        }
        
        // Select top 20 candidates for rewriting
        let topCandidates = Array(candidates.prefix(20))
        
        let candidatesText = topCandidates.enumerated().map { index, line in
            "\(index + 1). \(line.text) [Artist: \(line.artist ?? "Unknown"), Song: \(line.song ?? "Unknown")]"
        }.joined(separator: "\n")
        
        // Extract last 8-12 lines for better context (Phase 1: Expanded Context Window)
        let lines = metrics.fullText.split(separator: "\n", omittingEmptySubsequences: false)
        let contextLines = Array(lines.suffix(12)).map { String($0) } // Increased from 6 to 12 lines
        let last4To6Lines = Array(contextLines.suffix(6)) // Still use last 6 for immediate context in prompt
        
        // Build style characteristics string
        var styleInfo = ""
        if let style = narrative.styleCharacteristics {
            var styleParts: [String] = []
            if let vocab = style.vocabularyLevel { styleParts.append("Vocabulary: \(vocab)") }
            if let structure = style.sentenceStructure { styleParts.append("Structure: \(structure)") }
            if let figurative = style.figurativeLanguage { styleParts.append("Figurative language: \(figurative)") }
            if let energy = style.energyLevel { styleParts.append("Energy: \(energy)") }
            if let formality = style.formalityLevel { styleParts.append("Formality: \(formality)") }
            if let repetition = style.repetitionPatterns { styleParts.append("Repetition: \(repetition)") }
            if let punctuation = style.punctuationStyle { styleParts.append("Punctuation: \(punctuation)") }
            styleInfo = styleParts.joined(separator: ", ")
        }
        
        // Build key phrases string
        let keyPhrasesStr = (narrative.keyPhrases ?? []).joined(separator: ", ")
        
        // Build story elements string
        let storyElementsStr = (narrative.storyElements ?? []).joined(separator: ", ")
        
        // Build continuation needs string
        let continuationNeedsStr = narrative.continuationNeeds ?? "continue narrative progression"
        
        // Build topic treatment modes string
        var topicModesInfo = ""
        if let modes = narrative.topicTreatmentModes {
            var modeParts: [String] = []
            if let women = modes.women, women != "not-present" { modeParts.append("Women: \(women)") }
            if let wealth = modes.wealth { modeParts.append("Wealth: \(wealth)") }
            if let success = modes.success { modeParts.append("Success: \(success)") }
            if !modeParts.isEmpty {
                topicModesInfo = modeParts.joined(separator: ", ")
            }
        }
        
        // Build voice type string
        let voiceTypeStr = narrative.voiceType ?? ""
        
        // Build thematic contradictions string
        let contradictionsStr = (narrative.thematicContradictions ?? []).joined(separator: "; ")
        
        // Build narrative momentum string
        let momentumStr = narrative.narrativeMomentum ?? ""
        
        // Build contextual placement string
        let contextualPlacementStr = narrative.contextualPlacement ?? ""
        
        // Load settings and user details if not provided
        let modelSettings = settings ?? loadModelSettings(for: model)
        let personalDetails = userDetails ?? loadUserPersonalDetails()
        
        // Get feedback-based improvements and apply them
        let feedbackImprovements = getFeedbackImprovements()
        
        // Generate model-specific prompt with feedback improvements
        let prompt = buildGenerationPrompt(
            model: model,
            metrics: metrics,
            narrative: narrative,
            last4To6Lines: last4To6Lines,
            candidatesText: candidatesText,
            styleInfo: styleInfo,
            keyPhrasesStr: keyPhrasesStr,
            storyElementsStr: storyElementsStr,
            continuationNeedsStr: continuationNeedsStr,
            topicModesInfo: topicModesInfo,
            voiceTypeStr: voiceTypeStr,
            contradictionsStr: contradictionsStr,
            momentumStr: momentumStr,
            contextualPlacementStr: contextualPlacementStr,
            settings: modelSettings,
            userDetails: personalDetails,
            feedbackImprovements: feedbackImprovements
        )
        
        // Generate model-specific system message with feedback improvements and constraints
        let systemMessage = buildSystemMessage(model: model, settings: modelSettings, feedbackImprovements: feedbackImprovements, constraints: constraints)
        
        let requestBody: [String: Any] = [
            "model": model.modelIdentifier,
            "messages": [
                [
                    "role": "system",
                    "content": systemMessage
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": model.temperature,
            "response_format": ["type": "json_object"]
        ]
        
        var suggestions = try await performAPIRequest(requestBody: requestBody, narrative: narrative, metrics: metrics)
        
        // Apply personalization based on user feedback history
        suggestions = PersonalizationEngine.shared.personalizeSuggestions(suggestions)
        
        // Learn from feedback periodically (if enough time has passed)
        PersonalizationEngine.shared.learnFromFeedbackIfNeeded()
        
        return suggestions
    }
    
    // MARK: - Feedback Integration
    
    /// Get feedback-based improvements and apply them automatically
    private func getFeedbackImprovements() -> ModelImprovements? {
        // Check if we have enough feedback to generate improvements (at least 10 feedback entries)
        let feedbackStats = SuggestionFeedbackManager.shared.getFeedbackStats()
        guard feedbackStats.totalFeedback >= 10 else {
            return nil
        }
        
        // Generate improvements from feedback
        let improvements = ModelImprovementPipeline.shared.generateImprovements()
        
        // Apply improvements automatically (store for tracking)
        ModelImprovementPipeline.shared.applyImprovements(improvements)
        
        return improvements
    }
    
    // MARK: - Model-Specific Prompt Builders
    
    private func buildSystemMessage(model: SuggestionModel, settings: ModelSettings, feedbackImprovements: ModelImprovements? = nil, constraints: ConstraintRules? = nil) -> String {
        var baseMessage = "You are an expert rap lyric suggestion engine specializing in narrative continuity, thematic consistency (including thematic layering), topic treatment mode matching, voice consistency, contradiction preservation, narrative momentum awareness, contextual placement awareness, multi-line coherence, and musical constraints. "
        
        // Add priority focus guidance
        switch settings.priorityFocus {
        case .balanced:
            baseMessage += "Maintain a balanced approach across all aspects. "
        case .musicalFlow:
            baseMessage += "PRIORITIZE musical flow and rhythm above all else. "
        case .thematicDepth:
            baseMessage += "PRIORITIZE thematic depth and narrative above all else. "
        case .voiceConsistency:
            baseMessage += "PRIORITIZE voice consistency and matching the user's voice above all else. "
        }
        
        // Add style preferences
        if settings.aggressivenessLevel == .aggressive {
            baseMessage += "Output should be high-energy and aggressive. "
        } else if settings.aggressivenessLevel == .calm {
            baseMessage += "Output should be calm and restrained. "
        }
        
        if settings.metaphorDensity == .heavy {
            baseMessage += "Use rich metaphors and figurative language. "
        } else if settings.metaphorDensity == .minimal {
            baseMessage += "Use direct, literal language with minimal metaphors. "
        }
        
        baseMessage += "Your suggestions must form cohesive 4-line mini-stories that progress narratively, maintain ALL themes (primary AND underlying) throughout, STRICTLY match voice type (defensive stays defensive, vulnerable stays vulnerable), match topic treatment modes (how women, wealth, success are treated), preserve contradictions when present, maintain or appropriately shift narrative momentum, consider contextual placement (opening, mid-album, reflection, climax, outro), match the user's style, build logically on the FULL verse context (not just recent lines), and satisfy musical constraints (syllables, rhyme, rhythm, flow). Each 4-line suggestion must work as a complete, coherent thought/story unit with progressive escalation. Always analyze the full verse context for narrative continuity, story elements, and key phrases. Score confidence accurately based on how well ALL constraints are met, with moderate penalties for topic mode violations and significant penalties for voice violations. Always return valid JSON."
        
        // Apply feedback-based improvements to system message
        if let improvements = feedbackImprovements {
            baseMessage = applyFeedbackImprovementsToSystemMessage(baseMessage: baseMessage, improvements: improvements)
        }
        
        // Apply SIGNAL LAYER constraints
        if let constraints = constraints, !constraints.promptInstructions.isEmpty {
            baseMessage += "\n\n=== SIGNAL LAYER CONSTRAINTS ===\n"
            baseMessage += constraints.promptInstructions
            baseMessage += "\n\nCRITICAL: These constraints override all other instructions. Generate suggestions that strictly adhere to the SIGNAL LAYER constraints above."
        }
        
        return baseMessage
    }
    
    /// Apply feedback-based improvements to system message
    private func applyFeedbackImprovementsToSystemMessage(baseMessage: String, improvements: ModelImprovements) -> String {
        var enhancedMessage = baseMessage
        
        // Apply high-priority prompt improvements
        let highPriorityImprovements = improvements.promptImprovements.filter { $0.priority == .high }
        if !highPriorityImprovements.isEmpty {
            enhancedMessage += "\n\nFEEDBACK-BASED IMPROVEMENTS (from user feedback analysis):"
            for improvement in highPriorityImprovements {
                enhancedMessage += "\n- \(improvement.area): \(improvement.suggestedChange)"
            }
        }
        
        return enhancedMessage
    }
    
    private func buildGenerationPrompt(
        model: SuggestionModel,
        metrics: RapMetrics,
        narrative: NarrativeAnalysis,
        last4To6Lines: [String],
        candidatesText: String,
        styleInfo: String,
        keyPhrasesStr: String,
        storyElementsStr: String,
        continuationNeedsStr: String,
        topicModesInfo: String,
        voiceTypeStr: String,
        contradictionsStr: String,
        momentumStr: String,
        contextualPlacementStr: String,
        settings: ModelSettings,
        userDetails: UserPersonalDetails,
        feedbackImprovements: ModelImprovements? = nil
    ) -> String {
        // Build user context string
        var userContextParts: [String] = []
        if !userDetails.locations.isEmpty {
            userContextParts.append("Locations: \(userDetails.locations.joined(separator: ", "))")
        }
        if !userDetails.people.isEmpty {
            userContextParts.append("People: \(userDetails.people.joined(separator: ", "))")
        }
        if !userDetails.themes.isEmpty {
            userContextParts.append("Themes: \(userDetails.themes.joined(separator: ", "))")
        }
        if !userDetails.interests.isEmpty {
            userContextParts.append("Interests: \(userDetails.interests.joined(separator: ", "))")
        }
        let userContextStr = userContextParts.isEmpty ? "" : userContextParts.joined(separator: ". ")
        let userBackgroundStr = userDetails.background.isEmpty ? "" : "Background: \(userDetails.background)"
        
        // Base prompt structure (shared between models)
        let basePrompt = """
        You are a rap lyric suggestion engine. Your job is to suggest the next 4 lines for a rap verse that form a cohesive, narratively progressive mini-story.
        
        FULL VERSE CONTEXT (for narrative continuity):
        \(metrics.fullText)
        
        IMMEDIATE CONTEXT (last 4-6 lines for flow):
        \(last4To6Lines.joined(separator: "\n"))
        
        \(userContextStr.isEmpty ? "" : "USER CONTEXT (personalize suggestions with these references): \(userContextStr)")
        \(userBackgroundStr.isEmpty ? "" : "\n\(userBackgroundStr)")
        
        NARRATIVE ANALYSIS:
        - Primary Themes: \(narrative.primaryThemes.joined(separator: ", "))
        - Secondary Themes: \(narrative.secondaryThemes.joined(separator: ", "))
        \(narrative.underlyingThemes?.isEmpty == false ? "- Underlying Themes (maintain these beneath surface): \(narrative.underlyingThemes!.joined(separator: ", "))" : "")
        - Emotional Tone: \(narrative.emotionalTone)
        - Narrative Phase: \(narrative.narrativePhase)
        - Perspective: \(narrative.perspective)
        \(voiceTypeStr.isEmpty ? "" : "- Voice Type (STRICTLY MATCH THIS): \(voiceTypeStr)")
        \(topicModesInfo.isEmpty ? "" : "- Topic Treatment Modes (MATCH THESE): \(topicModesInfo)")
        \(contradictionsStr.isEmpty ? "" : "- Thematic Contradictions/Ironies (preserve when appropriate): \(contradictionsStr)")
        \(momentumStr.isEmpty ? "" : "- Narrative Momentum (maintain or allow shifts if narratively strong): \(momentumStr)")
        \(contextualPlacementStr.isEmpty ? "" : "- Contextual Placement (consider this in suggestions): \(contextualPlacementStr)")
        - Continuation Needs: \(continuationNeedsStr)
        \(keyPhrasesStr.isEmpty ? "" : "- Key Phrases/Concepts (reference these): \(keyPhrasesStr)")
        \(storyElementsStr.isEmpty ? "" : "- Story Elements (continue/reference): \(storyElementsStr)")
        \(styleInfo.isEmpty ? "" : "- Style Characteristics (MATCH THIS): \(styleInfo)")
        
        MUSICAL CONSTRAINTS:
        - Target Syllables per line: \(metrics.syllableTarget ?? 0) (±1 allowed)
        - Rhyme Target: \(metrics.rhymeTarget ?? "none")
        - Rhyme Scheme: \(metrics.rhymeScheme ?? "unknown")
        - Average Syllables: \(String(format: "%.1f", metrics.averageSyllables))
        - Syllable Variance: \(String(format: "%.1f", metrics.syllableVariance))
        
        CANDIDATE LINES (use these as inspiration, prefer selection/adaptation over free generation):
        \(candidatesText)
        """
        
        // Model-specific rules section
        let rulesSection = buildRulesSection(
            model: model,
            metrics: metrics,
            topicModesInfo: topicModesInfo,
            voiceTypeStr: voiceTypeStr,
            contradictionsStr: contradictionsStr,
            momentumStr: momentumStr,
            contextualPlacementStr: contextualPlacementStr,
            styleInfo: styleInfo,
            settings: settings,
            feedbackImprovements: feedbackImprovements
        )
        
        // Confidence scoring section (can be customized per model and feedback)
        let confidenceSection = buildConfidenceScoringSection(model: model, feedbackImprovements: feedbackImprovements)
        
        // JSON format section
        let jsonFormatSection = """
        
        Return 3-5 suggestions as JSON object with "suggestions" array:
        {
          "suggestions": [
            {
              "text": "line 1\\nline 2\\nline 3\\nline 4",
              "confidence": 0.0-1.0,
              "source": "Artist - Song (if adapted)",
              "reasoning": "brief explanation of how it matches constraints",
              "themes": ["theme1", "theme2", "theme3"]
            }
          ]
        }
        
        IMPORTANT: 
        - Each "text" field must contain exactly 4 lines separated by newline characters (\\n).
        - Each suggestion must form a cohesive mini-story that progresses narratively.
        - Confidence must accurately reflect how well ALL constraints are met.
        
        Return ONLY valid JSON object, no markdown, no code blocks.
        """
        
        return basePrompt + "\n\n" + rulesSection + "\n\n" + confidenceSection + jsonFormatSection
    }
    
    private func buildRulesSection(
        model: SuggestionModel,
        metrics: RapMetrics,
        topicModesInfo: String,
        voiceTypeStr: String,
        contradictionsStr: String,
        momentumStr: String,
        contextualPlacementStr: String,
        styleInfo: String,
        settings: ModelSettings,
        feedbackImprovements: ModelImprovements? = nil
    ) -> String {
        switch model {
        case .modelG:
            return buildModelGRules(
                metrics: metrics,
                topicModesInfo: topicModesInfo,
                voiceTypeStr: voiceTypeStr,
                contradictionsStr: contradictionsStr,
                momentumStr: momentumStr,
                contextualPlacementStr: contextualPlacementStr,
                styleInfo: styleInfo,
                settings: settings,
                feedbackImprovements: feedbackImprovements
            )
            
        case .modelY:
            return buildModelYRules(
                metrics: metrics,
                topicModesInfo: topicModesInfo,
                voiceTypeStr: voiceTypeStr,
                contradictionsStr: contradictionsStr,
                momentumStr: momentumStr,
                contextualPlacementStr: contextualPlacementStr,
                styleInfo: styleInfo,
                settings: settings,
                feedbackImprovements: feedbackImprovements
            )
        }
    }
    
    private func buildModelGRules(
        metrics: RapMetrics,
        topicModesInfo: String,
        voiceTypeStr: String,
        contradictionsStr: String,
        momentumStr: String,
        contextualPlacementStr: String,
        styleInfo: String,
        settings: ModelSettings,
        feedbackImprovements: ModelImprovements? = nil
    ) -> String {
        return """
        CRITICAL RULES:
        
        A. STORY PROGRESSION (HIGH PRIORITY):
        1. Line-by-line narrative arc:
           - Line 1: Bridge/continue from user's last line seamlessly
           - Line 2: Develop/expand the idea introduced in line 1
           - Line 3: Build momentum/raise stakes/add intensity
           - Line 4: Provide strong ending/punchline/setup for next lines
        2. Progressive escalation: Each line must add something new (information, emotion, intensity, detail)
        3. Cohesive mini-story: All 4 lines must work together as a complete, coherent thought/story unit
        4. Reference continuity: Reference entities, objects, or concepts from the full verse when appropriate
        5. Narrative phase awareness:
           - "build" → escalate tension/energy across the 4 lines
           - "climax" → maintain intensity, add resolution elements
           - "outro" → provide resolution or conclusion
           - "verse" → continue narrative progression naturally
        
        B. THEMATIC CONSISTENCY (HIGH PRIORITY):
        1. Must maintain ALL primary themes throughout the 4-line suggestion
        2. Secondary themes should appear naturally where appropriate
        3. Underlying themes: If underlying themes are present, maintain BOTH primary themes AND underlying themes throughout the 4-line suggestion. Underlying themes should appear naturally, not forced. If underlying themes contrast with primary themes (e.g., success vs isolation), preserve that tension - don't resolve it unless narratively appropriate.
        4. Thematic layering: Maintain the thematic depth - if the verse has layers (surface themes + underlying emotional themes), preserve both layers in suggestions.
        5. Avoid introducing new themes unless they naturally extend existing ones
        6. Reject suggestions that contradict established themes
        7. Use key phrases/concepts from the full verse when appropriate
        
        C. NARRATIVE FLOW (HIGH PRIORITY):
        1. Build logically on the FULL verse context, not just last lines
        2. Reference entities/objects from the full text when relevant
        3. Maintain perspective consistency (first-person vs third-person)
        4. Maintain temporal/logical consistency with full verse
        5. Ensure suggestions don't contradict user's established story elements
        
        D. MULTI-LINE COHERENCE (HIGH PRIORITY):
        1. Inter-line coherence: Each line must flow naturally into the next
        2. Complete thought: The 4 lines must form a complete, coherent thought/story
        3. Avoid fragmentation: Don't create 4 disconnected lines
        4. Punctuation/flow: Use appropriate line breaks and phrasing
        5. Emotional progression: Build emotional momentum across the 4 lines
        
        E. MUSICAL CONSTRAINTS (\(settings.musicalStrictness == .veryStrict ? "HIGHEST" : settings.musicalStrictness == .moderate ? "HIGH" : "MEDIUM") PRIORITY):
        1. Syllable count: Each line within ±1 of target (\(metrics.syllableTarget ?? 0)) - \(settings.musicalStrictness == .veryStrict ? "ABSOLUTELY CRITICAL" : "CRITICAL") for flow
        2. Rhyme matching: Match the rhyme target if provided (\(metrics.rhymeTarget ?? "none")) - Use rhyme words that fit naturally. \(settings.rhymeComplexity == .complex ? "Use complex, multi-syllable rhymes when possible." : settings.rhymeComplexity == .simple ? "Keep rhymes simple and straightforward." : "")
        3. Rhyme scheme: Maintain the detected rhyme scheme (\(metrics.rhymeScheme ?? "unknown")) - Preserve pattern consistency
        4. Rhythm consistency: Lines should have similar rhythm/pace as user's lines - Match the cadence and flow feel
        5. Flow patterns: Maintain consistent syllable variance (current: \(String(format: "%.1f", metrics.syllableVariance))) - Match density/sparsity pattern. \(settings.flowDensity == .dense ? "Prefer dense, packed flow." : settings.flowDensity == .sparse ? "Prefer sparse flow with breathing room." : "")
        6. Beat alignment: Consider how lines would flow over a beat, maintain groove/feel consistency - Think about musicality. \(settings.beatSyncPreference == .tight ? "Maintain tight beat synchronization." : settings.beatSyncPreference == .loose ? "Allow flexible timing." : "")
        7. Avoid jarring rhythm shifts within the 4-line suggestion - Smooth transitions between lines
        8. Syllable stress patterns: Match stress patterns of user's lines when possible - Maintain rhythmic feel
        9. Flow style matching: Match flow style (dense vs sparse, fast vs slow) from user's verse
        10. Syllable variance tolerance: \(settings.syllableVarianceTolerance == .strict ? "STRICTLY maintain syllable consistency." : settings.syllableVarianceTolerance == .flexible ? "Allow creative freedom with syllable counts." : "Maintain moderate consistency.")
        
        F. TOPIC TREATMENT MODE MATCHING (HIGH PRIORITY):
        \(topicModesInfo.isEmpty ? "1. Match how topics are treated in the user's verse naturally" : "1. STRICTLY match the detected topic treatment modes: \(topicModesInfo)")
        2. If women are treated aesthetically (lifestyle/visual), maintain that - don't shift to relational unless narratively strong and appropriate
        3. If women are treated relationally (emotional connection), maintain that depth
        4. Match wealth treatment mode (flexing vs burden vs ironic)
        5. Match success treatment mode (celebration vs obligation vs isolation)
        6. Allow mode shifts ONLY if narratively appropriate and the shift strengthens the narrative
        7. Flag violations in confidence scoring
        
        G. VOICE TYPE MATCHING (HIGH PRIORITY - STRICT):
        \(voiceTypeStr.isEmpty ? "1. Match the user's voice type naturally" : "1. STRICTLY match voice type: \(voiceTypeStr)")
        2. If voice is defensive (guarded, justifying), maintain that - do NOT shift to vulnerable
        3. If voice is vulnerable (introspective, open), maintain that - do NOT shift to defensive
        4. Match the level of guard/openness consistently
        5. Do not shift from defensive to vulnerable (or vice versa) unless explicitly transitioning in a narratively strong way
        6. Voice consistency is critical - violations significantly reduce confidence
        
        H. CONTRADICTION/IRONY PRESERVATION (MEDIUM PRIORITY):
        \(contradictionsStr.isEmpty ? "1. Detect and preserve contradictions when they exist naturally" : "1. Preserve detected contradictions/ironies: \(contradictionsStr)")
        2. If contradictions exist (e.g., success feels like obligation), maintain that tension - don't resolve it unless narratively appropriate
        3. Allow smooth transitions when narratively appropriate - contradictions don't need to be forced
        4. Don't force contradictions if they don't exist in the verse
        5. Contradictions add depth - preserve them when present
        
        I. NARRATIVE MOMENTUM (MEDIUM PRIORITY):
        \(momentumStr.isEmpty ? "1. Detect current momentum and maintain or allow shifts when narratively strong" : "1. Current momentum: \(momentumStr)")
        2. If momentum is "building-tension", maintain or escalate tension across the 4 lines
        3. If momentum is "escapist-relief", maintain that lighter energy or provide relief from heavier themes
        4. If momentum is "maintaining", keep the current energy level consistent
        5. If momentum is "transitioning", allow the transition to complete naturally
        6. Allow momentum shifts ONLY if narratively strong and appropriate
        7. Consider contextual placement when determining momentum
        
        J. CONTEXTUAL PLACEMENT AWARENESS (MEDIUM PRIORITY):
        \(contextualPlacementStr.isEmpty ? "1. Consider where the verse sits in a larger narrative when suggesting next lines" : "1. Contextual placement: \(contextualPlacementStr)")
        2. If "opening": Suggestions should introduce/develop themes, set up narrative
        3. If "mid-album": Suggestions should develop narrative, maintain momentum, deepen themes
        4. If "reflection": Suggestions should be introspective, explore emotions, provide insight
        5. If "climax": Suggestions should maintain intensity, add resolution elements, peak energy
        6. If "outro": Suggestions should provide resolution, conclude themes, wrap up narrative
        7. Use contextual placement to inform narrative function and momentum
        
        K. STYLE/VOICE MATCHING (HIGH PRIORITY):
        \(styleInfo.isEmpty ? "1. Match the user's writing style and voice naturally" : "1. Match the user's style characteristics: \(styleInfo)")
        2. Maintain vocabulary complexity level
        3. Match sentence structure patterns (short punchy vs longer flowing)
        4. Match figurative language usage
        5. Match energy and formality level
        6. Match punctuation style
        
        L. CONTENT RULES:
        1. Prefer selecting/adapting from candidates (\(Int(settings.candidateSelectionRatio * 100))%) over free generation (\(Int((1 - settings.candidateSelectionRatio) * 100))%)
        2. Each suggestion must be EXACTLY 4 lines (separated by newlines)
        3. Never invent new content - only adapt existing lyrics from candidates
        4. Keep the flow natural and authentic
        5. \(settings.adaptationOriginalityBalance == .originality ? "Prioritize originality and fresh content." : settings.adaptationOriginalityBalance == .adaptation ? "Prioritize adapting from existing candidates." : "Balance adaptation and originality.")
        6. \(settings.referenceFrequency == .frequent ? "Include frequent references to cultural elements, people, places." : settings.referenceFrequency == .rare ? "Minimize references, focus on original content." : "Include moderate references when appropriate.")
        7. \(settings.experimentalLanguageTolerance == .experimental ? "Feel free to use experimental, innovative language." : settings.experimentalLanguageTolerance == .conservative ? "Use traditional, conservative language." : "Use moderate experimentation.")
        8. \(settings.genreBlendingPreference == .blended ? "Feel free to blend elements from other genres." : settings.genreBlendingPreference == .pure ? "Stay within rap genre conventions." : "Allow moderate genre blending.")
        9. \(!settings.topicRestrictions.isEmpty ? "AVOID these topics: \(settings.topicRestrictions)" : "")
        10. \(settings.languageRestrictions == .strict ? "Avoid explicit content and strong language." : settings.languageRestrictions == .none ? "No language restrictions." : "Use moderate language.")
        11. \(settings.referenceStyle == .personal ? "Use personal, concrete references when possible." : settings.referenceStyle == .abstract ? "Use abstract, metaphorical references." : "Balance personal and abstract references.")
        \(applyFeedbackImprovementsToRules(feedbackImprovements: feedbackImprovements))
        """
    }
    
    private func buildModelYRules(
        metrics: RapMetrics,
        topicModesInfo: String,
        voiceTypeStr: String,
        contradictionsStr: String,
        momentumStr: String,
        contextualPlacementStr: String,
        styleInfo: String,
        settings: ModelSettings,
        feedbackImprovements: ModelImprovements? = nil
    ) -> String {
        // Model Y rules - customize these to have different priorities/emphasis
        // For example, Model Y might prioritize musical flow over thematic complexity
        return """
        CRITICAL RULES (MODEL Y - PRIORITIZES FLOW AND MUSICALITY):
        
        A. MUSICAL CONSTRAINTS (HIGHEST PRIORITY):
        1. Syllable count: Each line within ±1 of target (\(metrics.syllableTarget ?? 0)) - ABSOLUTELY CRITICAL
        2. Rhyme matching: Match the rhyme target if provided (\(metrics.rhymeTarget ?? "none")) - Perfect rhyme matching is essential
        3. Rhyme scheme: Maintain the detected rhyme scheme (\(metrics.rhymeScheme ?? "unknown")) - Pattern consistency is key
        4. Rhythm consistency: Lines MUST have similar rhythm/pace as user's lines - Match cadence exactly
        5. Flow patterns: Maintain consistent syllable variance (current: \(String(format: "%.1f", metrics.syllableVariance))) - Flow is everything
        6. Beat alignment: Lines must flow perfectly over a beat - Musicality is paramount
        7. No jarring rhythm shifts - Smooth, consistent flow required
        8. Syllable stress patterns: Match stress patterns exactly - Maintain rhythmic feel
        9. Flow style matching: Match flow style precisely (dense vs sparse, fast vs slow)
        
        B. STORY PROGRESSION (HIGH PRIORITY):
        1. Line-by-line narrative arc:
           - Line 1: Bridge/continue from user's last line seamlessly
           - Line 2: Develop/expand the idea introduced in line 1
           - Line 3: Build momentum/raise stakes/add intensity
           - Line 4: Provide strong ending/punchline/setup for next lines
        2. Progressive escalation: Each line must add something new (information, emotion, intensity, detail)
        3. Cohesive mini-story: All 4 lines must work together as a complete, coherent thought/story unit
        4. Reference continuity: Reference entities, objects, or concepts from the full verse when appropriate
        
        C. THEMATIC CONSISTENCY (HIGH PRIORITY):
        1. Must maintain ALL primary themes throughout the 4-line suggestion
        2. Secondary themes should appear naturally where appropriate
        3. Underlying themes: If underlying themes are present, maintain BOTH primary themes AND underlying themes throughout the 4-line suggestion.
        4. Avoid introducing new themes unless they naturally extend existing ones
        5. Use key phrases/concepts from the full verse when appropriate
        
        D. MULTI-LINE COHERENCE (HIGH PRIORITY):
        1. Inter-line coherence: Each line must flow naturally into the next
        2. Complete thought: The 4 lines must form a complete, coherent thought/story
        3. Avoid fragmentation: Don't create 4 disconnected lines
        4. Punctuation/flow: Use appropriate line breaks and phrasing
        
        E. NARRATIVE FLOW (MEDIUM PRIORITY):
        1. Build logically on the FULL verse context, not just last lines
        2. Reference entities/objects from the full text when relevant
        3. Maintain perspective consistency (first-person vs third-person)
        
        F. TOPIC TREATMENT MODE MATCHING (MEDIUM PRIORITY):
        \(topicModesInfo.isEmpty ? "1. Match how topics are treated in the user's verse naturally" : "1. Match the detected topic treatment modes: \(topicModesInfo)")
        2. Allow more flexibility in mode shifts if it improves flow
        
        G. VOICE TYPE MATCHING (MEDIUM PRIORITY):
        \(voiceTypeStr.isEmpty ? "1. Match the user's voice type naturally" : "1. Match voice type: \(voiceTypeStr)")
        2. Maintain voice consistency but allow slight variations for flow
        
        H. STYLE/VOICE MATCHING (HIGH PRIORITY):
        \(styleInfo.isEmpty ? "1. Match the user's writing style and voice naturally" : "1. Match the user's style characteristics: \(styleInfo)")
        2. Maintain vocabulary complexity level
        3. Match sentence structure patterns
        4. Match energy and formality level
        
        I. CONTENT RULES:
        1. Prefer selecting/adapting from candidates (\(Int(settings.candidateSelectionRatio * 100))%) over free generation (\(Int((1 - settings.candidateSelectionRatio) * 100))%) - More creative freedom
        2. Each suggestion must be EXACTLY 4 lines (separated by newlines)
        3. Never invent new content - only adapt existing lyrics from candidates
        4. Prioritize flow and musicality above all else
        5. \(settings.adaptationOriginalityBalance == .originality ? "Prioritize originality and fresh content." : settings.adaptationOriginalityBalance == .adaptation ? "Prioritize adapting from existing candidates." : "Balance adaptation and originality.")
        6. \(settings.referenceFrequency == .frequent ? "Include frequent references to cultural elements, people, places." : settings.referenceFrequency == .rare ? "Minimize references, focus on original content." : "Include moderate references when appropriate.")
        7. \(settings.experimentalLanguageTolerance == .experimental ? "Feel free to use experimental, innovative language." : settings.experimentalLanguageTolerance == .conservative ? "Use traditional, conservative language." : "Use moderate experimentation.")
        8. \(settings.genreBlendingPreference == .blended ? "Feel free to blend elements from other genres." : settings.genreBlendingPreference == .pure ? "Stay within rap genre conventions." : "Allow moderate genre blending.")
        9. \(!settings.topicRestrictions.isEmpty ? "AVOID these topics: \(settings.topicRestrictions)" : "")
        10. \(settings.languageRestrictions == .strict ? "Avoid explicit content and strong language." : settings.languageRestrictions == .none ? "No language restrictions." : "Use moderate language.")
        \(applyFeedbackImprovementsToRules(feedbackImprovements: feedbackImprovements))
        """
    }
    
    /// Apply feedback-based improvements to rules section
    private func applyFeedbackImprovementsToRules(feedbackImprovements: ModelImprovements?) -> String {
        guard let improvements = feedbackImprovements else { return "" }
        
        var feedbackSection = "\n\nM. FEEDBACK-BASED IMPROVEMENTS (from user feedback analysis):"
        
        // Add high and medium priority improvements
        let priorityImprovements = improvements.promptImprovements.filter { $0.priority == .high || $0.priority == .medium }
        if !priorityImprovements.isEmpty {
            for improvement in priorityImprovements {
                feedbackSection += "\n\(improvement.area): \(improvement.suggestedChange) [Rationale: \(improvement.rationale)]"
            }
        } else {
            return "" // No improvements to apply
        }
        
        return feedbackSection
    }
    
    private func buildConfidenceScoringSection(model: SuggestionModel, feedbackImprovements: ModelImprovements? = nil) -> String {
        // Get metric tuning adjustments from feedback
        let metricTuning = feedbackImprovements?.metricTuning ?? MetricTuningSuggestions(
            rhymeStrengthWeightAdjustment: 0.0,
            flowMatchWeightAdjustment: 0.0,
            styleMatchWeightAdjustment: 0.0,
            confidenceThresholdAdjustment: 0.0
        )
        
        // Calculate adjusted weights based on feedback
        let baseThemeWeight = 0.11
        let baseLayeringWeight = 0.11
        let baseTopicModesWeight = 0.09
        let baseVoiceWeight = 0.09
        let baseContradictionsWeight = 0.05
        let baseMomentumWeight = 0.05
        let baseNarrativeWeight = 0.11
        let baseCoherenceWeight = 0.11
        let baseMusicalWeight = 0.17
        let baseStyleWeight = 0.07
        let baseProgressionWeight = 0.05
        
        // Adjust weights based on feedback (metric tuning)
        // If rhyme issues are high, increase musical weight (which includes rhyme)
        let adjustedMusicalWeight = baseMusicalWeight + metricTuning.rhymeStrengthWeightAdjustment * 0.1
        let adjustedStyleWeight = baseStyleWeight + metricTuning.styleMatchWeightAdjustment * 0.1
        // Flow is part of musical constraints, so adjust musical weight
        let finalMusicalWeight = adjustedMusicalWeight + metricTuning.flowMatchWeightAdjustment * 0.1
        
        // Normalize weights to sum to 1.0
        let totalWeight = baseThemeWeight + baseLayeringWeight + baseTopicModesWeight + baseVoiceWeight + 
                         baseContradictionsWeight + baseMomentumWeight + baseNarrativeWeight + baseCoherenceWeight + 
                         finalMusicalWeight + adjustedStyleWeight + baseProgressionWeight
        let normalizationFactor = 1.0 / totalWeight
        
        let themeWeight = baseThemeWeight * normalizationFactor
        let layeringWeight = baseLayeringWeight * normalizationFactor
        let topicModesWeight = baseTopicModesWeight * normalizationFactor
        let voiceWeight = baseVoiceWeight * normalizationFactor
        let contradictionsWeight = baseContradictionsWeight * normalizationFactor
        let momentumWeight = baseMomentumWeight * normalizationFactor
        let narrativeWeight = baseNarrativeWeight * normalizationFactor
        let coherenceWeight = baseCoherenceWeight * normalizationFactor
        let musicalWeight = finalMusicalWeight * normalizationFactor
        let styleWeight = adjustedStyleWeight * normalizationFactor
        let progressionWeight = baseProgressionWeight * normalizationFactor
        
        // Build confidence threshold note if adjusted
        let thresholdNote = metricTuning.confidenceThresholdAdjustment != 0.0 ? 
            "\n- Confidence threshold adjusted based on feedback: \(metricTuning.confidenceThresholdAdjustment > 0 ? "increased" : "decreased") by \(String(format: "%.2f", abs(metricTuning.confidenceThresholdAdjustment)))" : ""
        
        switch model {
        case .modelG:
            return """
        CONFIDENCE SCORING (REQUIRED - CRITICAL)\(thresholdNote):
        Score confidence 0.0-1.0 based on how well the suggestion matches ALL constraints above. Lower confidence if any constraint is weak.
        
        Evaluate and score based on these dimensions (each 0.0-1.0) with adjusted weights based on user feedback:
        1. Theme matching (weight: \(String(format: "%.3f", themeWeight))) - How well ALL primary themes are maintained throughout all 4 lines, secondary themes appear naturally, no contradictions
        2. Thematic layering (weight: \(String(format: "%.3f", layeringWeight))) - How well both primary themes AND underlying themes are maintained (if underlying themes exist). If underlying themes contrast with primary themes, how well that tension is preserved. If no underlying themes exist, score based on thematic depth consistency.
        3. Topic treatment mode matching (weight: \(String(format: "%.3f", topicModesWeight))) - How well treatment modes are matched (women as aesthetic vs relational, wealth as flexing vs burden, success as celebration vs obligation). Moderate penalty (0.1-0.2 reduction) for violations but allow if narratively strong.
        4. Voice consistency (weight: \(String(format: "%.3f", voiceWeight))) - How well voice type is maintained (defensive stays defensive, vulnerable stays vulnerable). STRICT matching required - significant penalty (0.2-0.3 reduction) for voice shifts unless narratively strong.
        5. Contradiction preservation (weight: \(String(format: "%.3f", contradictionsWeight))) - How well contradictions/ironies are preserved when present. Don't force contradictions if they don't exist. Moderate penalty if contradictions are lost when they should be preserved.
        6. Narrative momentum (weight: \(String(format: "%.3f", momentumWeight))) - How well momentum is maintained or appropriately shifted. Building tension should escalate, escapist relief should maintain lighter energy, maintaining should stay consistent. Allow shifts if narratively strong.
        7. Narrative flow/coherence (weight: \(String(format: "%.3f", narrativeWeight))) - How well it builds logically on FULL verse context (not just last lines), references entities appropriately, maintains perspective/temporal consistency
        8. Multi-line coherence (weight: \(String(format: "%.3f", coherenceWeight))) - How well 4 lines form a cohesive mini-story, flow naturally line-to-line, avoid fragmentation, complete thought
        9. Musical constraints (weight: \(String(format: "%.3f", musicalWeight))) - Syllable count accuracy, rhyme matching, rhyme scheme consistency, rhythm/pace matching, flow pattern consistency, beat alignment\(metricTuning.rhymeStrengthWeightAdjustment != 0.0 || metricTuning.flowMatchWeightAdjustment != 0.0 ? " [Weight adjusted based on feedback]" : "")
        10. Style matching (weight: \(String(format: "%.3f", styleWeight))) - How well vocabulary complexity, sentence structure, figurative language, energy level, formality, punctuation style are matched\(metricTuning.styleMatchWeightAdjustment != 0.0 ? " [Weight adjusted based on feedback]" : "")
        11. Story progression quality (weight: \(String(format: "%.3f", progressionWeight))) - How well the narrative arc works (line 1 bridges, line 2 develops, line 3 builds, line 4 concludes), progressive escalation, narrative phase awareness
        
        Confidence calculation:
        - Calculate weighted average: (theme × \(String(format: "%.3f", themeWeight))) + (layering × \(String(format: "%.3f", layeringWeight))) + (topicModes × \(String(format: "%.3f", topicModesWeight))) + (voice × \(String(format: "%.3f", voiceWeight))) + (contradictions × \(String(format: "%.3f", contradictionsWeight))) + (momentum × \(String(format: "%.3f", momentumWeight))) + (narrative × \(String(format: "%.3f", narrativeWeight))) + (coherence × \(String(format: "%.3f", coherenceWeight))) + (musical × \(String(format: "%.3f", musicalWeight))) + (style × \(String(format: "%.3f", styleWeight))) + (progression × \(String(format: "%.3f", progressionWeight)))
        - Apply moderate penalties: Topic mode violations reduce by 0.1-0.2, voice violations reduce by 0.2-0.3 (unless narratively strong), contradiction loss reduces by 0.1-0.15
        - OR use minimum approach: If ANY dimension scores <0.5, cap confidence at 0.5
        - If a suggestion violates any major constraint (contradicts themes, breaks narrative flow, fragments lines, misses musical constraints, fails to maintain thematic layering when present, shifts voice inappropriately, loses contradictions when they should be preserved), confidence should be low (<0.5)
        - Higher confidence (>0.7) = excellent match across ALL dimensions with no weak areas
        - Medium confidence (0.5-0.7) = good match but some areas could be stronger
        - Lower confidence (<0.5) = significant issues with one or more constraints
        """
            
        case .modelY:
            // Model Y has different base weights - prioritize musical flow
            let modelYBaseMusicalWeight = 0.30
            let modelYBaseCoherenceWeight = 0.15
            let modelYBaseProgressionWeight = 0.12
            let modelYBaseThemeWeight = 0.10
            let modelYBaseStyleWeight = 0.10
            let modelYBaseNarrativeWeight = 0.08
            let modelYBaseLayeringWeight = 0.05
            let modelYBaseVoiceWeight = 0.05
            let modelYBaseTopicModesWeight = 0.03
            let modelYBaseContradictionsWeight = 0.02
            
            // Adjust Model Y weights based on feedback
            let modelYAdjustedMusicalWeight = modelYBaseMusicalWeight + metricTuning.rhymeStrengthWeightAdjustment * 0.15 + metricTuning.flowMatchWeightAdjustment * 0.15
            let modelYAdjustedStyleWeight = modelYBaseStyleWeight + metricTuning.styleMatchWeightAdjustment * 0.1
            
            // Normalize Model Y weights
            let modelYTotalWeight = modelYBaseThemeWeight + modelYBaseLayeringWeight + modelYBaseTopicModesWeight + modelYBaseVoiceWeight +
                                   modelYBaseContradictionsWeight + modelYBaseProgressionWeight + modelYBaseNarrativeWeight + modelYBaseCoherenceWeight +
                                   modelYAdjustedMusicalWeight + modelYAdjustedStyleWeight
            let modelYNormalizationFactor = 1.0 / modelYTotalWeight
            
            return """
        CONFIDENCE SCORING (MODEL Y - MUSICAL FLOW WEIGHTED HIGHER)\(thresholdNote):
        Score confidence 0.0-1.0 based on how well the suggestion matches ALL constraints, with EXTRA weight on musical constraints.
        
        Evaluate and score based on these dimensions (each 0.0-1.0) with adjusted weights based on user feedback:
        1. Musical constraints (weight: \(String(format: "%.3f", modelYAdjustedMusicalWeight * modelYNormalizationFactor))) - Syllable count accuracy, rhyme matching, rhyme scheme consistency, rhythm/pace matching, flow pattern consistency, beat alignment - THIS IS MOST IMPORTANT\(metricTuning.rhymeStrengthWeightAdjustment != 0.0 || metricTuning.flowMatchWeightAdjustment != 0.0 ? " [Weight adjusted based on feedback]" : "")
        2. Multi-line coherence (weight: \(String(format: "%.3f", modelYBaseCoherenceWeight * modelYNormalizationFactor))) - How well 4 lines form a cohesive mini-story, flow naturally line-to-line
        3. Story progression quality (weight: \(String(format: "%.3f", modelYBaseProgressionWeight * modelYNormalizationFactor))) - How well the narrative arc works, progressive escalation
        4. Theme matching (weight: \(String(format: "%.3f", modelYBaseThemeWeight * modelYNormalizationFactor))) - How well ALL primary themes are maintained
        5. Style matching (weight: \(String(format: "%.3f", modelYAdjustedStyleWeight * modelYNormalizationFactor))) - How well vocabulary complexity, sentence structure, energy level are matched\(metricTuning.styleMatchWeightAdjustment != 0.0 ? " [Weight adjusted based on feedback]" : "")
        6. Narrative flow/coherence (weight: \(String(format: "%.3f", modelYBaseNarrativeWeight * modelYNormalizationFactor))) - How well it builds logically on FULL verse context
        7. Thematic layering (weight: \(String(format: "%.3f", modelYBaseLayeringWeight * modelYNormalizationFactor))) - How well underlying themes are maintained
        8. Voice consistency (weight: \(String(format: "%.3f", modelYBaseVoiceWeight * modelYNormalizationFactor))) - How well voice type is maintained
        9. Topic treatment mode matching (weight: \(String(format: "%.3f", modelYBaseTopicModesWeight * modelYNormalizationFactor))) - How well treatment modes are matched
        10. Contradiction preservation (weight: \(String(format: "%.3f", modelYBaseContradictionsWeight * modelYNormalizationFactor))) - How well contradictions are preserved
        
        Confidence calculation:
        - Calculate weighted average with musical constraints weighted highest
        - If musical constraints score <0.7, significantly reduce overall confidence
        - Higher confidence (>0.7) = excellent musical flow AND good narrative coherence
        - Medium confidence (0.5-0.7) = good musical flow but some narrative areas could be stronger
        - Lower confidence (<0.5) = significant issues with musical flow or major constraints
        """
        }
    }
    
    private func performAPIRequest(requestBody: [String: Any], narrative: NarrativeAnalysis, metrics: RapMetrics) async throws -> [RapSuggestion] {
        guard apiKey != nil else {
            throw RapAPIError.missingAPIKey
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RapAPIError.requestFailed
        }
        
        let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = jsonResponse.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw RapAPIError.invalidResponse
        }
        
        // Parse suggestions array
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        
        // Try to get suggestions array from the response
        var suggestionsArray: [[String: Any]] = []
        if let suggestions = jsonObject?["suggestions"] as? [[String: Any]] {
            suggestionsArray = suggestions
        } else if let suggestions = jsonObject?["suggestions"] as? [Any] {
            // Fallback: try to parse as array
            suggestionsArray = suggestions.compactMap { $0 as? [String: Any] }
        }
        
        var suggestions: [RapSuggestion] = []
        for suggestionDict in suggestionsArray {
            let text = suggestionDict["text"] as? String ?? ""
            let confidence = (suggestionDict["confidence"] as? Double) ?? 0.5
            let source = suggestionDict["source"] as? String
            let reasoning = suggestionDict["reasoning"] as? String
            let themesArray = suggestionDict["themes"] as? [String] ?? []
            
            // If themes are not provided in response, extract from narrative
            let themes = themesArray.isEmpty ? (narrative.primaryThemes + narrative.secondaryThemes) : themesArray
            
            // Calculate quality metrics (Phase 1: AI Quality Foundation)
            let rhymeStrength = calculateRhymeStrength(text: text)
            let flowMatch = calculateFlowMatch(suggestionText: text, originalText: metrics.fullText)
            let styleMatch = calculateStyleMatch(suggestionText: text, narrative: narrative)
            
            suggestions.append(RapSuggestion(
                id: UUID(),
                text: text,
                confidence: confidence,
                source: source,
                reasoning: reasoning,
                themes: Array(themes.prefix(5)), // Limit to 5 themes
                rhymeStrength: rhymeStrength,
                flowMatch: flowMatch,
                styleMatch: styleMatch,
                userFeedback: nil,
                signalStrength: nil,
                signalNote: nil
            ))
        }
        
        return suggestions
    }
    
    // MARK: - Quality Metrics Calculation (Phase 1: AI Quality Foundation)
    
    /// Calculate rhyme strength score (0.0-1.0) for suggestion text
    private func calculateRhymeStrength(text: String) -> Double {
        let lines = text.components(separatedBy: "\n").filter { !$0.isEmpty }
        guard lines.count >= 2 else { return 0.5 } // Default if not enough lines
        
        var rhymeScores: [Double] = []
        
        // Check end rhymes between consecutive lines
        for i in 0..<(lines.count - 1) {
            let line1 = lines[i]
            let line2 = lines[i + 1]
            
            if let score = calculateLineRhymeScore(line1: line1, line2: line2) {
                rhymeScores.append(score)
            }
        }
        
        // Average rhyme scores, default to 0.5 if no rhymes found
        return rhymeScores.isEmpty ? 0.5 : rhymeScores.reduce(0, +) / Double(rhymeScores.count)
    }
    
    /// Calculate rhyme score between two lines
    private func calculateLineRhymeScore(line1: String, line2: String) -> Double? {
        let tokenizer = NLTokenizer(unit: .word)
        
        // Get last word of each line
        var lastWord1: String?
        var lastWord2: String?
        
        tokenizer.string = line1
        tokenizer.enumerateTokens(in: line1.startIndex..<line1.endIndex) { range, _ in
            lastWord1 = String(line1[range]).lowercased()
            return true
        }
        
        tokenizer.string = line2
        tokenizer.enumerateTokens(in: line2.startIndex..<line2.endIndex) { range, _ in
            lastWord2 = String(line2[range]).lowercased()
            return true
        }
        
        guard let word1 = lastWord1,
              let word2 = lastWord2,
              let phonemes1 = getCMUDICTPhonemes(for: word1),
              let phonemes2 = getCMUDICTPhonemes(for: word2),
              let sig1 = extractPhoneticSignature(from: phonemes1),
              let sig2 = extractPhoneticSignature(from: phonemes2),
              let strength = calculateRhymeStrengthFromSignatures(sig1: sig1, sig2: sig2) else {
            return nil
        }
        
        // Convert RhymeStrength enum to Double
        // Use rawValue since RhymeStrength has Double rawValue
        return strength.rawValue
    }
    
    /// Calculate flow match score (0.0-1.0) by comparing cadence/rhythm
    private func calculateFlowMatch(suggestionText: String, originalText: String) -> Double {
        // Analyze cadence using local implementation
        let suggestionMetrics = analyzeCadence(text: suggestionText)
        let originalMetrics = analyzeCadence(text: originalText)
        
        // Compare average syllables per line
        let suggestionAvgSyllables: Double = suggestionMetrics.averageSyllables
        let originalAvgSyllables: Double = originalMetrics.averageSyllables
        
        guard originalAvgSyllables > 0 else { return 0.5 }
        
        let syllableMatch = 1.0 - min(abs(suggestionAvgSyllables - originalAvgSyllables) / originalAvgSyllables, 1.0)
        
        // Compare stress patterns (simplified)
        let stressMatch = 0.7 // Placeholder - could be improved with actual stress pattern comparison
        
        return (syllableMatch * 0.7 + stressMatch * 0.3)
    }
    
    /// Calculate style match score (0.0-1.0) by comparing vocabulary and structure
    private func calculateStyleMatch(suggestionText: String, narrative: NarrativeAnalysis) -> Double {
        var matchScore: Double = 0.5 // Default
        
        // Check vocabulary level match
        if let vocabLevel = narrative.styleCharacteristics?.vocabularyLevel {
            let suggestionVocab = estimateVocabularyLevel(text: suggestionText)
            if suggestionVocab == vocabLevel {
                matchScore += 0.2
            }
        }
        
        // Check sentence structure match
        if let structure = narrative.styleCharacteristics?.sentenceStructure {
            let suggestionStructure = estimateSentenceStructure(text: suggestionText)
            if suggestionStructure == structure {
                matchScore += 0.2
            }
        }
        
        // Check energy level match
        if let energy = narrative.styleCharacteristics?.energyLevel {
            let suggestionEnergy = estimateEnergyLevel(text: suggestionText)
            if suggestionEnergy == energy {
                matchScore += 0.1
            }
        }
        
        return min(matchScore, 1.0)
    }
    
    /// Estimate vocabulary level from text
    private func estimateVocabularyLevel(text: String) -> String {
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let avgLength = words.reduce(0) { $0 + $1.count } / max(words.count, 1)
        
        if avgLength > 6 {
            return "complex"
        } else if avgLength < 4 {
            return "simple"
        } else {
            return "mixed"
        }
    }
    
    /// Estimate sentence structure from text
    private func estimateSentenceStructure(text: String) -> String {
        let lines = text.components(separatedBy: "\n").filter { !$0.isEmpty }
        let avgLength = lines.reduce(0) { $0 + $1.count } / max(lines.count, 1)
        
        if avgLength < 30 {
            return "short-punchy"
        } else if avgLength > 60 {
            return "long-flowing"
        } else {
            return "varied"
        }
    }
    
    /// Estimate energy level from text
    private func estimateEnergyLevel(text: String) -> String {
        let uppercaseCount = text.filter { $0.isUppercase }.count
        let totalChars = text.filter { $0.isLetter }.count
        let uppercaseRatio = totalChars > 0 ? Double(uppercaseCount) / Double(totalChars) : 0
        
        // Check for exclamation marks, caps, etc.
        let exclamationCount = text.filter { $0 == "!" }.count
        let hasHighEnergy = uppercaseRatio > 0.1 || exclamationCount > 0
        
        return hasHighEnergy ? "high" : "medium"
    }
    
    // MARK: - Single Line Suggestion (for Rewrite Line)
    
    func generateSingleLineSuggestion(
        candidates: [RapLine],
        metrics: RapMetrics,
        narrative: NarrativeAnalysis,
        rhymeTarget: String,
        syllableTarget: Int,
        model: SuggestionModel = .modelG
    ) async throws -> String {
        guard apiKey != nil else {
            throw RapAPIError.missingAPIKey
        }
        
        // Filter candidates that rhyme with target and match syllable count
        let filteredCandidates = candidates.filter { line in
            // Check rhyme
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = line.text
            var lastWord: String?
            tokenizer.enumerateTokens(in: line.text.startIndex..<line.text.endIndex) { range, _ in
                lastWord = String(line.text[range]).lowercased()
                return true
            }
            
            guard let word = lastWord,
                  let wordPhonemes = getCMUDICTPhonemes(for: word),
                  let targetPhonemes = getCMUDICTPhonemes(for: rhymeTarget),
                  let wordSig = extractPhoneticSignature(from: wordPhonemes),
                  let targetSig = extractPhoneticSignature(from: targetPhonemes),
                  let strength = calculateRhymeStrengthFromSignatures(sig1: wordSig, sig2: targetSig) else {
                return false
            }
            
            // Check syllable count (within ±1)
            let words = line.text.split { !$0.isLetter }
            var syllables = 0
            for wordSub in words {
                let wordStr = String(wordSub).lowercased()
                let analysis = analyzeSyllables(word: wordStr)
                syllables += analysis.syllables
            }
            
            return (strength == .perfect || strength == .near) && abs(syllables - syllableTarget) <= 1
        }
        
        // Select top 10 candidates
        let topCandidates = Array(filteredCandidates.prefix(10))
        let candidatesText = topCandidates.enumerated().map { index, line in
            "\(index + 1). \(line.text)"
        }.joined(separator: "\n")
        
        let prompt = """
        Suggest a single line of rap lyrics that:
        1. Rhymes with the word "\(rhymeTarget)" (perfect or near rhyme)
        2. Has approximately \(syllableTarget) syllables (±1 allowed)
        3. Matches the themes: \(narrative.primaryThemes.joined(separator: ", "))
        4. Matches the tone: \(narrative.emotionalTone)
        5. Flows naturally from the context
        
        Context (last 4 lines):
        \(metrics.lastNLines.joined(separator: "\n"))
        
        Candidate lines (use as inspiration):
        \(candidatesText.isEmpty ? "None found" : candidatesText)
        
        Return ONLY the single line of lyrics, no explanation, no quotes, just the line.
        """
        
        let requestBody: [String: Any] = [
            "model": model.modelIdentifier,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a rap lyricist. Suggest a single line that rhymes perfectly, matches syllable count, and fits the context. Return only the line, nothing else."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": model.temperature,
            "max_tokens": 50
        ]
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RapAPIError.requestFailed
        }
        
        let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = jsonResponse.choices.first?.message.content else {
            throw RapAPIError.invalidResponse
        }
        
        // Clean up the response (remove quotes, extra whitespace)
        let cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "'", with: "")
        
        return cleaned
    }
    
    // MARK: - Improve Flow (Rhyme Scheme Focus)
    
    func generateSuggestionsForFlow(
        candidates: [RapLine],
        metrics: RapMetrics,
        narrative: NarrativeAnalysis,
        rhymeScheme: String,
        model: SuggestionModel = .modelG,
        settings: ModelSettings? = nil
    ) async throws -> [RapSuggestion] {
        guard apiKey != nil else {
            throw RapAPIError.missingAPIKey
        }
        
        // Select top 20 candidates for rewriting
        let topCandidates = Array(candidates.prefix(20))
        
        let candidatesText = topCandidates.enumerated().map { index, line in
            "\(index + 1). \(line.text) [Artist: \(line.artist ?? "Unknown"), Song: \(line.song ?? "Unknown")]"
        }.joined(separator: "\n")
        
        // Extract last 8-12 lines for better context (Phase 1: Expanded Context Window)
        let lines = metrics.fullText.split(separator: "\n", omittingEmptySubsequences: false)
        let contextLines = Array(lines.suffix(12)).map { String($0) } // Increased from 6 to 12 lines
        let last4To6Lines = Array(contextLines.suffix(6)) // Still use last 6 for immediate context in prompt
        
        // Build style characteristics string
        var styleInfo = ""
        if let style = narrative.styleCharacteristics {
            var styleParts: [String] = []
            if let vocab = style.vocabularyLevel { styleParts.append("Vocabulary: \(vocab)") }
            if let structure = style.sentenceStructure { styleParts.append("Structure: \(structure)") }
            if let figurative = style.figurativeLanguage { styleParts.append("Figurative language: \(figurative)") }
            if let energy = style.energyLevel { styleParts.append("Energy: \(energy)") }
            if let formality = style.formalityLevel { styleParts.append("Formality: \(formality)") }
            if let repetition = style.repetitionPatterns { styleParts.append("Repetition: \(repetition)") }
            if let punctuation = style.punctuationStyle { styleParts.append("Punctuation: \(punctuation)") }
            styleInfo = styleParts.joined(separator: ", ")
        }
        
        // Build key phrases string
        let keyPhrasesStr = (narrative.keyPhrases ?? []).joined(separator: ", ")
        
        // Build story elements string
        let storyElementsStr = (narrative.storyElements ?? []).joined(separator: ", ")
        
        // Build continuation needs string
        let continuationNeedsStr = narrative.continuationNeeds ?? "continue narrative progression"
        
        // Generate model-specific prompt with rhyme scheme emphasis
        let prompt = buildFlowImprovementPrompt(
            model: model,
            metrics: metrics,
            narrative: narrative,
            last4To6Lines: last4To6Lines,
            candidatesText: candidatesText,
            styleInfo: styleInfo,
            keyPhrasesStr: keyPhrasesStr,
            storyElementsStr: storyElementsStr,
            continuationNeedsStr: continuationNeedsStr,
            rhymeScheme: rhymeScheme
        )
        
        // Get feedback-based improvements and apply them
        let feedbackImprovements = getFeedbackImprovements()
        
        // Generate model-specific system message with feedback improvements
        let modelSettings = settings ?? ModelSettings()
        let systemMessage = buildSystemMessage(model: model, settings: modelSettings, feedbackImprovements: feedbackImprovements)
        
        let requestBody: [String: Any] = [
            "model": model.modelIdentifier,
            "messages": [
                [
                    "role": "system",
                    "content": systemMessage + " CRITICAL: Focus on maintaining the rhyme scheme \(rhymeScheme). Rhyme scheme consistency is the highest priority."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": model.temperature,
            "response_format": ["type": "json_object"]
        ]
        
        return try await performAPIRequest(requestBody: requestBody, narrative: narrative, metrics: metrics)
    }
    
    private func buildFlowImprovementPrompt(
        model: SuggestionModel,
        metrics: RapMetrics,
        narrative: NarrativeAnalysis,
        last4To6Lines: [String],
        candidatesText: String,
        styleInfo: String,
        keyPhrasesStr: String,
        storyElementsStr: String,
        continuationNeedsStr: String,
        rhymeScheme: String
    ) -> String {
        // Base prompt structure (shared between models)
        let basePrompt = """
        You are a rap lyric suggestion engine focused on IMPROVING FLOW by maintaining rhyme scheme consistency.
        
        FULL VERSE CONTEXT (for narrative continuity):
        \(metrics.fullText)
        
        IMMEDIATE CONTEXT (last 4-6 lines for flow):
        \(last4To6Lines.joined(separator: "\n"))
        
        CRITICAL: CURRENT RHYME SCHEME: \(rhymeScheme)
        You MUST maintain this exact rhyme scheme pattern in your 4-line suggestions.
        
        NARRATIVE ANALYSIS:
        - Primary Themes: \(narrative.primaryThemes.joined(separator: ", "))
        - Secondary Themes: \(narrative.secondaryThemes.joined(separator: ", "))
        - Emotional Tone: \(narrative.emotionalTone)
        - Narrative Phase: \(narrative.narrativePhase)
        - Perspective: \(narrative.perspective)
        - Continuation Needs: \(continuationNeedsStr)
        \(keyPhrasesStr.isEmpty ? "" : "- Key Phrases/Concepts (reference these): \(keyPhrasesStr)")
        \(storyElementsStr.isEmpty ? "" : "- Story Elements (continue/reference): \(storyElementsStr)")
        \(styleInfo.isEmpty ? "" : "- Style Characteristics (MATCH THIS): \(styleInfo)")
        
        MUSICAL CONSTRAINTS:
        - Target Syllables per line: \(metrics.syllableTarget ?? 0) (±1 allowed)
        - Rhyme Scheme: \(rhymeScheme) - THIS IS CRITICAL - MAINTAIN THIS PATTERN
        - Average Syllables: \(String(format: "%.1f", metrics.averageSyllables))
        - Syllable Variance: \(String(format: "%.1f", metrics.syllableVariance))
        
        CANDIDATE LINES (use these as inspiration, prefer selection/adaptation over free generation):
        \(candidatesText)
        """
        
        // Model-specific rules section with rhyme scheme emphasis
        let rulesSection = """
        
        CRITICAL RULES - RHYME SCHEME FOCUS:
        
        A. RHYME SCHEME CONSISTENCY (HIGHEST PRIORITY):
        1. The current rhyme scheme is: \(rhymeScheme)
        2. Your 4-line suggestion MUST follow this exact pattern
        3. If pattern is ABAB: lines 1 and 3 must rhyme, lines 2 and 4 must rhyme
        4. If pattern is AABB: lines 1-2 must rhyme, lines 3-4 must rhyme
        5. If pattern is ABBA: lines 1 and 4 must rhyme, lines 2 and 3 must rhyme
        6. If pattern is ABAC: lines 1 and 3 must rhyme, line 2 is unique, line 4 matches line 1 or 3
        7. Maintain the pattern EXACTLY - this is the primary goal
        
        B. MUSICAL CONSTRAINTS (HIGH PRIORITY):
        1. Syllable count: Each line within ±1 of target (\(metrics.syllableTarget ?? 0))
        2. Rhythm consistency: Lines should have similar rhythm/pace as user's lines
        3. Flow patterns: Maintain consistent syllable variance (current: \(String(format: "%.1f", metrics.syllableVariance)))
        4. Beat alignment: Consider how lines would flow over a beat
        
        C. THEMATIC CONSISTENCY (MEDIUM PRIORITY):
        1. Maintain primary themes: \(narrative.primaryThemes.joined(separator: ", "))
        2. Secondary themes should appear naturally where appropriate
        3. Use key phrases/concepts from the full verse when appropriate
        
        D. STORY PROGRESSION (MEDIUM PRIORITY):
        1. Line-by-line narrative arc:
           - Line 1: Bridge/continue from user's last line seamlessly
           - Line 2: Develop/expand the idea introduced in line 1
           - Line 3: Build momentum/raise stakes/add intensity
           - Line 4: Provide strong ending/punchline/setup for next lines
        2. Progressive escalation: Each line must add something new
        
        E. STYLE MATCHING (MEDIUM PRIORITY):
        \(styleInfo.isEmpty ? "1. Match the user's writing style naturally" : "1. Match the user's style characteristics: \(styleInfo)")
        2. Maintain vocabulary complexity level
        3. Match sentence structure patterns
        
        F. CONTENT RULES:
        1. Prefer selecting/adapting from candidates (70%) over free generation (30%)
        2. Each suggestion must be EXACTLY 4 lines (separated by newlines)
        3. Never invent new content - only adapt existing lyrics from candidates
        4. Keep the flow natural and authentic
        
        CONFIDENCE SCORING (REQUIRED):
        Score confidence 0.0-1.0 based on how well the suggestion matches ALL constraints, with EXTRA weight on rhyme scheme consistency.
        
        Evaluate and score based on these dimensions (each 0.0-1.0):
        1. Rhyme scheme consistency (weight: 0.40) - CRITICAL - How well the rhyme scheme \(rhymeScheme) is maintained
        2. Musical constraints (weight: 0.25) - Syllable count, rhythm, flow
        3. Thematic consistency (weight: 0.15) - How well themes are maintained
        4. Story progression (weight: 0.10) - How well narrative arc works
        5. Style matching (weight: 0.10) - How well style is matched
        
        Confidence calculation:
        - Calculate weighted average with rhyme scheme weighted highest
        - If rhyme scheme is NOT maintained correctly, confidence should be LOW (<0.4)
        - Higher confidence (>0.7) = perfect rhyme scheme match AND good other aspects
        - Medium confidence (0.5-0.7) = good rhyme scheme but some other areas could be stronger
        - Lower confidence (<0.5) = rhyme scheme issues or major constraint violations
        """
        
        // JSON format section
        let jsonFormatSection = """
        
        Return 3-5 suggestions as JSON object with "suggestions" array:
        {
          "suggestions": [
            {
              "text": "line 1\\nline 2\\nline 3\\nline 4",
              "confidence": 0.0-1.0,
              "source": "Artist - Song (if adapted)",
              "reasoning": "brief explanation focusing on rhyme scheme match",
              "themes": ["theme1", "theme2", "theme3"]
            }
          ]
        }
        
        IMPORTANT: 
        - Each "text" field must contain exactly 4 lines separated by newline characters (\\n).
        - Each suggestion MUST follow the rhyme scheme \(rhymeScheme) exactly.
        - Confidence must accurately reflect rhyme scheme consistency.
        
        Return ONLY valid JSON object, no markdown, no code blocks.
        """
        
        return basePrompt + "\n\n" + rulesSection + jsonFormatSection
    }
    
    // MARK: - Local Type Definitions (to avoid dependency on ContentView.swift types)
    
    private struct PhoneticSignature {
        let stressedVowel: String
        let coda: [String]
    }
    
    private enum RhymeStrength: Double {
        case perfect = 1.0
        case near = 0.75
        case slant = 0.55
    }
    
    private struct CadenceMetrics {
        struct LineMetrics {
            let lineIndex: Int
            let syllableCount: Int
            let stressCount: Int
            let rhymeCount: Int
        }
        let lines: [LineMetrics]
        
        var averageSyllables: Double {
            guard !lines.isEmpty else { return 0 }
            return Double(lines.map(\.syllableCount).reduce(0, +)) / Double(lines.count)
        }
        var syllableVariance: Double {
            let avg = averageSyllables
            return lines.map { pow(Double($0.syllableCount) - avg, 2) }.reduce(0, +) / Double(lines.count)
        }
    }
    
    private struct APISuggestionHighlight {
        let range: Range<String.Index>
        let colorIndex: Int
    }
    
    // MARK: - Helper Functions (Local Implementations)
    
    private func getCMUDICTPhonemes(for word: String) -> [String]? {
        // Try to access FJCMUDICTStore from ContentView.swift
        // If not available, return nil (will be handled gracefully)
        // Note: This requires FJCMUDICTStore to be accessible
        // For now, we'll use a workaround by accessing it through a type-erased approach
        return getPhonemesFromCMUDICT(word: word.lowercased())
    }
    
    private func getPhonemesFromCMUDICT(word: String) -> [String]? {
        // Access CMUDICT store - using reflection/dynamic lookup as fallback
        // This is a workaround for type resolution issues
        if let store = getCMUDICTStore() {
            return store[word]
        }
        return nil
    }
    
    private func getCMUDICTStore() -> [String: [String]]? {
        // Try to access FJCMUDICTStore.shared.phonemesByWord
        // Using a type-erased approach to avoid compilation errors
        return accessCMUDICTStore()
    }
    
    private func accessCMUDICTStore() -> [String: [String]]? {
        // Access FJCMUDICTStore.shared.phonemesByWord using a closure-based approach
        // This works around type resolution issues by using a provider pattern
        return getCMUDICTStoreProvider()()
    }
    
    private func getCMUDICTStoreProvider() -> () -> [String: [String]] {
        // Return a closure that accesses the store
        // This allows the store to be accessed even if the type isn't directly visible
        return {
            // Access FJCMUDICTStore through a global accessor function
            // This function should be defined in ContentView.swift or as a global function
            return getGlobalCMUDICTStore()
        }
    }
    
    // Global accessor function is defined in ContentView.swift
    // This allows access to FJCMUDICTStore without direct type reference
    
    private func extractPhoneticSignature(from phonemes: [String]) -> PhoneticSignature? {
        // Find the stressed vowel (phoneme ending in 0, 1, or 2)
        guard let stressedIndex = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
            return nil
        }
        
        let stressedVowel = phonemes[stressedIndex]
        let coda = Array(phonemes[(stressedIndex + 1)...])
        
        return PhoneticSignature(stressedVowel: stressedVowel, coda: coda)
    }
    
    private func calculateRhymeStrengthFromSignatures(sig1: PhoneticSignature, sig2: PhoneticSignature) -> RhymeStrength? {
        // Perfect rhyme: same stressed vowel + same coda
        if sig1.stressedVowel == sig2.stressedVowel && sig1.coda == sig2.coda {
            return .perfect
        }
        
        // Near rhyme: same stressed vowel, different coda
        if sig1.stressedVowel == sig2.stressedVowel {
            return .near
        }
        
        // Slant rhyme: similar vowels (check base vowel without stress number)
        let vowel1Base = String(sig1.stressedVowel.dropLast())
        let vowel2Base = String(sig2.stressedVowel.dropLast())
        if vowel1Base == vowel2Base {
            return .slant
        }
        
        return nil
    }
    
    private func analyzeCadence(text: String) -> CadenceMetrics {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var results: [CadenceMetrics.LineMetrics] = []
        
        for (index, line) in lines.enumerated() {
            let words = line.split { !$0.isLetter }
            var syllables = 0
            var stresses = 0
            
            for wordSub in words {
                let word = String(wordSub).lowercased()
                if let phonemes = getCMUDICTPhonemes(for: word) {
                    // Count syllables (phonemes ending in numbers)
                    let syllableCount = phonemes.filter { $0.last?.isNumber == true }.count
                    syllables += syllableCount
                    
                    // Count stresses (phonemes ending in "1")
                    let stressCount = phonemes.filter { $0.hasSuffix("1") }.count
                    stresses += stressCount
                } else {
                    // Fallback: estimate syllables from word length
                    syllables += max(1, word.count / 3)
                }
            }
            
            results.append(CadenceMetrics.LineMetrics(
                lineIndex: index,
                syllableCount: syllables,
                stressCount: stresses,
                rhymeCount: 0 // Not tracking rhymes here
            ))
        }
        
        return CadenceMetrics(lines: results)
    }
    
    private func analyzeSyllables(word: String) -> (syllables: Int, stresses: [Int]) {
        guard let phonemes = getCMUDICTPhonemes(for: word) else {
            // Fallback: estimate syllables from word length
            let estimated = max(1, word.count / 3)
            return (estimated, [])
        }
        
        var syllableIndex = 0
        var stresses: [Int] = []
        
        for phone in phonemes {
            if let last = phone.last, last.isNumber {
                if last == "1" {
                    stresses.append(syllableIndex)
                }
                syllableIndex += 1
            }
        }
        
        return (syllableIndex, stresses)
    }
}

// MARK: - OpenAI Response Models

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

// MARK: - Errors

enum RapAPIError: LocalizedError {
    case missingAPIKey
    case requestFailed
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key not found. Please add your API key in settings."
        case .requestFailed:
            return "API request failed. Please check your internet connection."
        case .invalidResponse:
            return "Invalid response from API."
        }
    }
}

