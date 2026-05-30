import Foundation
import Security
import NaturalLanguage

// MARK: - Model Types

enum SuggestionModel: String, CaseIterable {
    case modelG = "Model G"
    case modelY = "Model Y"
    case modelGv3 = "Model G v3"

    var displayName: String {
        return rawValue
    }

    var modelIdentifier: String {
        switch self {
        case .modelG:
            return "gpt-4o"
        case .modelY:
            return "gpt-4o"
        case .modelGv3:
            // CROSS-TEST: runs on base gpt-4o with the upgraded v3 prompt until fine-tune is ready.
            // After training, replace with your fine-tuned model ID, e.g.:
            // return "ft:gpt-4o-mini:your-org:rap-agent-v3:XXXXXXXX"
            return "gpt-4o"
        }
    }

    var temperature: Double {
        switch self {
        case .modelG:
            return 0.6
        case .modelY:
            return 0.6
        case .modelGv3:
            // Slightly tighter temperature for sharper rhyme control and less hallucination
            return 0.55
        }
    }
}

// MARK: - API Models

// MARK: - Generation Result (PR 6)

enum GenerationResult: Codable {
    case suggestion(RapSuggestion)
    case silence(CriticCommentary)

    private enum CodingKeys: String, CodingKey {
        case type
        case suggestion
        case silence
    }

    private enum Kind: String, Codable {
        case suggestion
        case silence
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)

        switch kind {
        case .suggestion:
            let value = try container.decode(RapSuggestion.self, forKey: .suggestion)
            self = .suggestion(value)
        case .silence:
            let value = try container.decode(CriticCommentary.self, forKey: .silence)
            self = .silence(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .suggestion(let value):
            try container.encode(Kind.suggestion, forKey: .type)
            try container.encode(value, forKey: .suggestion)
        case .silence(let value):
            try container.encode(Kind.silence, forKey: .type)
            try container.encode(value, forKey: .silence)
        }
    }
}

// MARK: - Critic Commentary (PR 6)

struct CriticCommentary: Codable {
    let explanation: String  // Why no line was generated
    let reason: String  // Specific reason (alignment threshold, register violation, etc.)
    let guidance: String  // What the user should consider
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
    
    // A&R Critique
    var arCritique: String? // A&R-style critique teaching the user how to improve based on their submitted text

    // Model G Core v1.0 — CRDP moment indices for ✴ glyph display
    var modelGMomentLineIndices: [Int]?

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
    
    /// Get Genius API key from Keychain
    private func getGeniusAPIKeyFromKeychain() -> String? {
        return KeychainHelper.shared.getGeniusAPIKey()
    }
    
    private init() {}
    
    // MARK: - Settings Loading
    
    func loadModelSettings(for model: SuggestionModel) -> ModelSettings {
        let key: String
        switch model {
        case .modelG:   key = "modelG_settings"
        case .modelY:   key = "modelY_settings"
        case .modelGv3: key = "modelGv3_settings"
        }
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(ModelSettings.self, from: data) {
            return sanitizeModelSettings(decoded)
        }
        return sanitizeModelSettings(ModelSettings()) // Return defaults if not found
    }

    private func sanitizeModelSettings(_ settings: ModelSettings) -> ModelSettings {
        var sanitized = settings
        sanitized.silenceThreshold = min(max(sanitized.silenceThreshold, 0.0), 0.8)
        sanitized.registerWeight = min(max(sanitized.registerWeight, 0.0), 1.0)
        return sanitized
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
        - detectedTones: Array of 1–4 tones detected in the verse (e.g. ["confident", "detached"]). Use EmotionalTone enum values: neutral, confident, aggressive, melancholic, reflective, detached, hopeful, resentful.
        - emotionalTone: For backward compatibility, set to the first value in detectedTones (or single tone if you only output one).
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
        
        // Track network performance
        let requestStartTime = CFAbsoluteTimeGetCurrent()
        let requestSize = request.httpBody?.count ?? 0
        let requestHeaders = Dictionary(uniqueKeysWithValues: request.allHTTPHeaderFields?.map { ($0.key, $0.value) } ?? [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let requestDuration = CFAbsoluteTimeGetCurrent() - requestStartTime
        let responseSize = data.count
        
        guard let httpResponse = response as? HTTPURLResponse else {
            // Track failed request
            NetworkPerformanceMonitor.shared.trackRequest(
                url: url.absoluteString,
                method: "POST",
                requestSize: requestSize,
                responseSize: 0,
                statusCode: nil,
                duration: requestDuration,
                success: false,
                errorMessage: "Invalid HTTP response",
                requestHeaders: requestHeaders
            )
            throw RapAPIError.requestFailed
        }
        
        let responseHeaders = Dictionary<String, String>(uniqueKeysWithValues: httpResponse.allHeaderFields.compactMap { key, value -> (String, String)? in
            guard let keyString = key as? String, let valueString = value as? String else { return nil }
            return (keyString, valueString)
        })
        
        guard httpResponse.statusCode == 200 else {
            // Track failed request
            NetworkPerformanceMonitor.shared.trackRequest(
                url: url.absoluteString,
                method: "POST",
                requestSize: requestSize,
                responseSize: responseSize,
                statusCode: httpResponse.statusCode,
                duration: requestDuration,
                success: false,
                errorMessage: "HTTP \(httpResponse.statusCode)",
                requestHeaders: requestHeaders,
                responseHeaders: responseHeaders
            )
            throw RapAPIError.requestFailed
        }
        
        // Track successful request
        NetworkPerformanceMonitor.shared.trackRequest(
            url: url.absoluteString,
            method: "POST",
            requestSize: requestSize,
            responseSize: responseSize,
            statusCode: httpResponse.statusCode,
            duration: requestDuration,
            success: true,
            requestHeaders: requestHeaders,
            responseHeaders: responseHeaders
        )
        
        let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        // Extract token usage if available
        var inputTokens: Int? = nil
        var outputTokens: Int? = nil
        var totalTokens: Int? = nil
        
        if let usage = jsonResponse.usage {
            inputTokens = usage.promptTokens
            outputTokens = usage.completionTokens
            totalTokens = usage.totalTokens
            
            // Track token usage
            if let input = usage.promptTokens, let output = usage.completionTokens {
                TokenUsageTracker.shared.trackUsage(
                    model: model.modelIdentifier,
                    endpoint: "narrative_analysis",
                    inputTokens: input,
                    outputTokens: output,
                    feature: "narrative_analysis"
                )
            }
        }
        
        guard let content = jsonResponse.choices.first?.message.content else {
            // Log response even if content is missing
            APIDebugInspector.shared.logResponse(
                statusCode: httpResponse.statusCode,
                responseBody: data,
                responseHeaders: responseHeaders,
                duration: requestDuration,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                totalTokens: totalTokens,
                parsingSuccess: false,
                parsingErrors: ["No content in choices"],
                validationResult: nil
            )
            throw RapAPIError.invalidResponse
        }
        
        // Clean the content: remove markdown code blocks if present
        var cleanedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code block markers (```json ... ``` or ``` ... ```)
        if cleanedContent.hasPrefix("```") {
            // Find the first newline after ```
            if let firstNewline = cleanedContent.firstIndex(of: "\n") {
                cleanedContent = String(cleanedContent[cleanedContent.index(after: firstNewline)...])
            } else {
                // No newline, just remove ```
                cleanedContent = cleanedContent.replacingOccurrences(of: "```", with: "")
            }
            // Remove trailing ```
            if cleanedContent.hasSuffix("```") {
                cleanedContent = String(cleanedContent[..<cleanedContent.index(cleanedContent.endIndex, offsetBy: -3)])
            }
            cleanedContent = cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard let jsonData = cleanedContent.data(using: .utf8) else {
            print("⚠️ RapSuggestionAPI: Failed to convert cleaned content to data for narrative analysis")
            print("Content preview: \(content.prefix(200))")
            
            // Log response with parsing error
            APIDebugInspector.shared.logResponse(
                statusCode: httpResponse.statusCode,
                responseBody: data,
                responseHeaders: responseHeaders,
                duration: requestDuration,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                totalTokens: totalTokens,
                parsingSuccess: false,
                parsingErrors: ["Failed to convert cleaned content to data"],
                validationResult: nil
            )
            
            throw RapAPIError.invalidResponse
        }
        
        // Decode to NarrativeDraft (incomplete inference output)
        let draft = try JSONDecoder().decode(NarrativeDraft.self, from: jsonData)
        
        // Extract SignalProfile from signal layer
        let signalProfile = SignalIngest.shared.extractSignalProfile(text: text)
        
        // Assemble complete NarrativeAnalysis from draft (PR 3: Pass model parameter)
        let analysis = NarrativeAssembler.assemble(from: draft, signal: signalProfile, model: model)
        
        // Validate the assembled analysis
        do {
            try NarrativeValidator.validate(analysis)
        } catch {
            print("⚠️ Narrative Validation Failed:")
            print("   - \(error.localizedDescription)")
            // Continue anyway - validation errors are logged but don't block
        }
        
        // Log response
        APIDebugInspector.shared.logResponse(
            statusCode: httpResponse.statusCode,
            responseBody: data,
            responseHeaders: responseHeaders,
            duration: requestDuration,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            totalTokens: totalTokens,
            parsingSuccess: true,
            validationResult: nil
        )
        
        return analysis
    }
    
    // MARK: - Semantic Search (DEPRECATED - No longer used with SIGNAL LAYER)
    
    // CSV-based search removed - SIGNAL LAYER generates from constraints, not CSV candidates
    // This function is kept for backwards compatibility but should not be called
    @available(*, deprecated, message: "Use constraint-driven generation instead. CSV search is no longer part of the suggestion flow.")
    func searchLyrics(
        narrativeSummary: String,
        themes: [String],
        limit: Int = 200
    ) async throws -> [RapLine] {
        // Return empty array - CSV search is deprecated
        // ThemeExpansionSheet may still need CSV, but suggestion generation doesn't
        return []
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

    // MARK: - Model G Core

    /// Distinct full-verse generations per Core call (each appears as its own suggestion card).
    private let modelGCoreSuggestionSetCount = 2

    private func generateModelGCoreRecordWithRetry(
        useV2: Bool,
        metrics: RapMetrics,
        audioURL: URL?,
        directedParams: DirectedGenerationParams?,
        transcriptionRhythmMapData: Data?
    ) async throws -> GeneratedRecord {
        let styleOverride = directedParams?.styleOverride
        func run() async throws -> GeneratedRecord {
            if ModelGEnvironment.useModelGv3 {
                let coordinatorV3 = ModelGCoreCoordinatorV3()
                return try await coordinatorV3.generateRecord(
                    input: metrics.fullText,
                    audioURL: audioURL,
                    styleOverride: styleOverride,
                    directedParams: directedParams,
                    transcriptionRhythmMapData: transcriptionRhythmMapData
                )
            }
            if useV2 {
                let coordinatorV2 = ModelGCoreCoordinatorV2()
                return try await coordinatorV2.generateRecord(
                    input: metrics.fullText,
                    audioURL: audioURL,
                    styleOverride: styleOverride,
                    directedParams: directedParams,
                    transcriptionRhythmMapData: transcriptionRhythmMapData
                )
            } else {
                let coordinator = ModelGCoreCoordinator()
                return try await coordinator.generateRecord(
                    input: metrics.fullText,
                    audioURL: audioURL,
                    styleOverride: styleOverride,
                    directedParams: directedParams
                )
            }
        }
        do {
            return try await run()
        } catch ModelGLLMError.rateLimitExceeded(let retryAfter) {
            let waitSeconds = retryAfter ?? 60
            print("⏳ Model G Core: Rate limited (429). Waiting \(waitSeconds)s before retry...")
            try await Task.sleep(nanoseconds: UInt64(waitSeconds) * 1_000_000_000)
            return try await run()
        }
    }

    // MARK: - Controlled Rewriting

    func generateSuggestions(
        candidates: [RapLine] = [],
        metrics: RapMetrics,
        narrative: NarrativeAnalysis,
        model: SuggestionModel = .modelG,
        settings: ModelSettings? = nil,
        userDetails: UserPersonalDetails? = nil,
        constraints: ConstraintRules? = nil,
        registers: RegisterProfile? = nil,
        signalProfile: SignalProfile? = nil,
        signalAxes: SignalAxes? = nil,
        allowedLexiconTerms: [LexiconTerm] = [],
        directedParams: DirectedGenerationParams? = nil,
        rhymeGroupsByID: [RhymeGroupID: RhymeGroupSummary]? = nil,
        audioURL: URL? = nil,
        transcriptionRhythmMapData: Data? = nil,
        modelGVariantOverride: Bool? = nil
    ) async throws -> [RapSuggestion] {
        guard apiKey != nil else {
            throw RapAPIError.missingAPIKey
        }

        // Model G Core — Use v2 when enabled, else v1. Override from param when provided (for parallel v1+v2).
        // Emits `modelGCoreSuggestionSetCount` full verses per model (each as its own card).
        if ModelGEnvironment.useModelGCore && model == .modelG {
            let useV2 = modelGVariantOverride ?? ModelGEnvironment.useModelGv2
            #if DEBUG
            print("Model G Core: Starting \(modelGCoreSuggestionSetCount) set(s) (\(useV2 ? "v2" : "v1"))...")
            #endif
            let baseSource = ModelGEnvironment.useModelGv3 ? "Model G Core v3.0" : (useV2 ? "Model G Core v2.0" : "Model G Core v1.0")
            var coreSuggestions: [RapSuggestion] = []

            // Generate all sets concurrently so their network round-trips overlap.
            // Each set builds its own coordinator, so there is no shared mutable state.
            let generatedSets: [(Int, GeneratedRecord?)] = await withTaskGroup(
                of: (Int, GeneratedRecord?).self
            ) { group in
                for setIndex in 1...modelGCoreSuggestionSetCount {
                    group.addTask {
                        do {
                            let record = try await self.generateModelGCoreRecordWithRetry(
                                useV2: useV2,
                                metrics: metrics,
                                audioURL: audioURL,
                                directedParams: directedParams,
                                transcriptionRhythmMapData: transcriptionRhythmMapData
                            )
                            return (setIndex, record)
                        } catch {
                            #if DEBUG
                            print("Model G Core: set \(setIndex)/\(self.modelGCoreSuggestionSetCount) — \(error.localizedDescription)")
                            #endif
                            return (setIndex, nil)
                        }
                    }
                }
                var collected: [(Int, GeneratedRecord?)] = []
                for await result in group {
                    collected.append(result)
                }
                return collected.sorted { $0.0 < $1.0 }
            }

            for (setIndex, recordOpt) in generatedSets {
                guard let record = recordOpt else { continue }
                let lines = [record.hook] + record.bars
                let text = lines.filter { !$0.isEmpty }.joined(separator: "\n")
                let isFallbackOnly = record.bars.allSatisfy { bar in
                    bar == "Fallback bar — continue the flow."
                        || bar.hasPrefix("Continue the flow —")
                }
                guard !isFallbackOnly && !text.isEmpty else {
                    #if DEBUG
                    print("Model G Core: set \(setIndex) fallback-only or empty — skipping card")
                    #endif
                    continue
                }
                let momentLineIndices = record.modelGMomentBarIndices.isEmpty ? nil
                    : record.modelGMomentBarIndices.map { $0 + 1 }
                let sourceLabel = modelGCoreSuggestionSetCount > 1 ? "\(baseSource) · Set \(setIndex)" : baseSource
                coreSuggestions.append(
                    RapSuggestion(
                        id: UUID(),
                        text: text,
                        confidence: record.averageBarScore / 100.0,
                        source: sourceLabel,
                        reasoning: nil,
                        themes: narrative.primaryThemes,
                        rhymeStrength: nil,
                        flowMatch: nil,
                        styleMatch: nil,
                        userFeedback: nil,
                        signalStrength: nil,
                        signalNote: nil,
                        arCritique: nil,
                        modelGMomentLineIndices: momentLineIndices
                    )
                )
            }
            if !coreSuggestions.isEmpty {
                return coreSuggestions
            }
            #if DEBUG
            print("Model G Core: No valid sets. Falling back to legacy Model G generation.")
            #endif
        }

        // LEXICON GATE: Filter terms before generation
        // Note: Actual filtering and silence handling happens in RapSuggestionEngine
        // The lexicon gate filters terms based on authority/exposure, and we continue with generation
        // using the filtered vocabulary context
        
        // SIGNAL LAYER-DRIVEN: Candidates are optional
        // If constraints are provided, we generate from scratch (writers-room approach)
        // If candidates exist, we can optionally use them as inspiration, but constraints take priority
        let useCandidates = !candidates.isEmpty && constraints == nil
        
        let candidatesText: String
        if useCandidates {
            let topCandidates = Array(candidates.prefix(20))
            candidatesText = topCandidates.enumerated().map { index, line in
                "\(index + 1). \(line.text)"
            }.joined(separator: "\n")
        } else {
            candidatesText = ""
        }
        
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
        let modelSettings = sanitizeModelSettings(settings ?? loadModelSettings(for: model))
        let personalDetails = userDetails ?? loadUserPersonalDetails()
        
        // Get feedback-based improvements and apply them
        let feedbackImprovements = getFeedbackImprovements()
        
        // Phase 0: Intent Extraction (Emotional Spine)
        let intent = IntentExtractor.extract(from: narrative)
        
        // PR 15: Ground Truth Retrieval (if enabled and Model G) - MUST happen before prompt building
        var groundTruthBar: GroundTruthIndex? = nil
        var groundTruthBarId: String? = nil
        var injectionMode: InjectionMode? = nil
        var slotsReplaced: [String]? = nil
        var rhymeAnchors: [GenerationDiagnostics.RhymeAnchorInfo]? = nil
        
        if GeneratorPolicyFeatureFlag.isGroundTruthInjectionEnabled() && narrative.generatorPolicy.artistBias == .gunna {
            // Load and index ground truth if not already done
            if !GroundTruthRetriever.shared.isIndexed {
                try? await GroundTruthRetriever.shared.loadAndIndex()
            }
            
            // Retrieve candidates
            let candidates = GroundTruthRetriever.shared.retrieveCandidates(
                authorityVector: narrative.generatorPolicy.artistBias == .gunna ? "control_hierarchy" : nil,
                syllableRange: (metrics.syllableTarget ?? 12) - 2..<(metrics.syllableTarget ?? 12) + 3,
                rhymeEnding: nil,  // Could extract from context
                verbDensityRange: 0.1..<0.5,
                limit: 20
            )
            
            // Filter by policy
            let filteredCandidates = GroundTruthRetriever.shared.filterCandidates(candidates, policy: narrative.generatorPolicy)
            
            // Select injection mode (for now, use rhyme anchoring if we have good anchors)
            if !filteredCandidates.isEmpty {
                let selectedCandidate = filteredCandidates.first!
                groundTruthBar = selectedCandidate
                groundTruthBarId = selectedCandidate.id
                
                // Extract anchors for Mode C
                let anchors = RhymeAnchorEngine.extractAnchors(from: [selectedCandidate])
                if !anchors.isEmpty {
                    injectionMode = .rhymeAnchoring
                    rhymeAnchors = anchors.map { anchor in
                        GenerationDiagnostics.RhymeAnchorInfo(
                            ending: anchor.ending,
                            syllableCount: anchor.syllableCount
                        )
                    }
                    
                    // Add anchor constraints to prompt
                    _ = RhymeAnchorEngine.buildAnchorConstraints(anchors: anchors, metrics: metrics)
                    // Note: This would be integrated into prompt building in a full implementation
                } else {
                    // Try Mode B: Slot replacement
                    let (skeleton, slots) = SlotReplacementEngine.extractSkeleton(selectedCandidate.text)
                    if !slots.isEmpty {
                        injectionMode = .slotReplacement
                        slotsReplaced = slots.map { $0.type.rawValue }
                        
                        // Refill slots
                        _ = SlotReplacementEngine.refillSlots(
                            skeleton: skeleton,
                            slots: slots,
                            lexicon: allowedLexiconTerms,
                            context: narrative,
                            policy: narrative.generatorPolicy
                        )
                        // Note: This would be used as a candidate or injected into prompt
                    } else {
                        // Mode A: Direct retrieval
                        injectionMode = .direct
                    }
                }
            }
        }
        
        // Model G v2: when control-surface params provided, use DirectedGenerationPromptBuilder
        let prompt: String
        let systemMessage: String
        if model == .modelG, let params = directedParams {
            prompt = DirectedGenerationPromptBuilder.buildUserPrompt(params: params, metrics: metrics, rhymeGroupsByID: rhymeGroupsByID ?? [:], intent: intent)
            systemMessage = DirectedGenerationPromptBuilder.buildSystemPrompt(params: params)
        } else {
            // Generate model-specific prompt with feedback improvements
            prompt = await buildGenerationPrompt(
                model: model,
                metrics: metrics,
                narrative: narrative,
                intent: intent,
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
                feedbackImprovements: feedbackImprovements,
                constraints: constraints,
                registers: registers,
                allowedLexiconTerms: allowedLexiconTerms,
                groundTruthBar: groundTruthBar
            )
            // Generate model-specific system message with feedback improvements and constraints
            // PR 4: Pass narrative for template constraints (Model G)
            systemMessage = buildSystemMessage(model: model, settings: modelSettings, feedbackImprovements: feedbackImprovements, constraints: constraints, narrative: narrative)
        }
        
        var requestBody: [String: Any] = [
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
            "temperature": model.temperature
        ]
        // Directed Model G (plain-text lines): ensure enough completion budget for multi-line output.
        if model == .modelG, let dp = directedParams {
            let linesWanted = max(8, dp.lineCount)
            requestBody["max_tokens"] = min(2500, 120 + linesWanted * 140)
        }
        // Model G v2 (control surface) expects plain-text lines; omit JSON response_format
        if model != .modelG || directedParams == nil {
            requestBody["response_format"] = ["type": "json_object"]
        }
        
        // Log API request for debugging
        // Resolve signal mode if not already available
        let resolvedSignalMetrics = SignalIngest.shared.analyzeBehavior(text: metrics.fullText)
        let resolvedSignalProfile = signalProfile ?? SignalIngest.shared.extractSignalProfile(text: metrics.fullText)
        let resolvedSignalMode = SignalMode.resolveMode(from: resolvedSignalMetrics)
        let resolvedAxisProfile = signalAxes != nil ? AxisProfile.calculate(metrics: resolvedSignalMetrics, axes: signalAxes!) : nil
        
        APIDebugInspector.shared.logRequest(
            model: model.modelIdentifier,
            systemMessage: systemMessage,
            userPrompt: prompt,
            fullText: metrics.fullText,
            narrative: narrative,
            signalProfile: resolvedSignalProfile,
            signalMode: resolvedSignalMode,
            signalAxes: signalAxes,
            axisProfile: resolvedAxisProfile,
            constraints: constraints,
            registers: registers,
            lexiconTerms: allowedLexiconTerms,
            metrics: metrics,
            settings: modelSettings,
            requestBody: requestBody
        )
        
        // PR 10: Check feature flag
        guard GeneratorPolicyFeatureFlag.isEnabled() else {
            // Feature disabled - use original generation path
            var dummyRejectedLines: [(line: String, reason: GenerationDiagnostics.RejectionReason)] = []
            let usePlainTextResponse = (model == .modelG && directedParams != nil)
            var suggestions = try await performAPIRequest(requestBody: requestBody, narrative: narrative, metrics: metrics, rejectedLines: &dummyRejectedLines, expectPlainTextLines: usePlainTextResponse)
            // Skip personalization for Model G (generates as established artist)
            if narrative.generatorPolicy.artistBias != .gunna {
                suggestions = PersonalizationEngine.shared.personalizeSuggestions(suggestions)
            }
            // Generate A&R critiques even when feature flag is disabled
            suggestions = await self.generateARCritiques(for: suggestions, userText: metrics.fullText, narrative: narrative)
            PersonalizationEngine.shared.learnFromFeedbackIfNeeded()
            return suggestions
        }
        
        // Ground truth retrieval already happened above (before prompt building)
        
        // PR 9: Regenerate loop with rejection gate (max 6 attempts for Model G)
        var suggestions: [RapSuggestion] = []
        let maxAttempts = narrative.generatorPolicy.artistBias == .gunna ? 6 : 1
        var attempts = 0
        var rejectedLines: [(line: String, reason: GenerationDiagnostics.RejectionReason)] = []
        var usedLocalFallbackFromSilence = false
        
        while suggestions.isEmpty && attempts < maxAttempts {
            attempts += 1
            print("🔄 RapSuggestionAPI: Attempt \(attempts)/\(maxAttempts) for Model G generation")
            
            let usePlainTextResponse = (model == .modelG && directedParams != nil)
            var candidateSuggestions: [RapSuggestion]
            do {
                candidateSuggestions = try await performAPIRequest(
                    requestBody: requestBody,
                    narrative: narrative,
                    metrics: metrics,
                    rejectedLines: &rejectedLines,
                    expectPlainTextLines: usePlainTextResponse
                )
            } catch RapAPIError.rateLimitExceeded(let retryAfter) {
                let waitSeconds = retryAfter ?? 60
                print("⏳ RapSuggestionAPI: Rate limited (429). Waiting \(waitSeconds)s before retry...")
                try await Task.sleep(nanoseconds: UInt64(waitSeconds) * 1_000_000_000)
                candidateSuggestions = try await performAPIRequest(
                    requestBody: requestBody,
                    narrative: narrative,
                    metrics: metrics,
                    rejectedLines: &rejectedLines,
                    expectPlainTextLines: usePlainTextResponse
                )
            } catch RapAPIError.silence(let commentary) {
                // If settings are strict enough to force silence often, return a safe fallback line
                // instead of surfacing a no-output state after model preference changes.
                if modelSettings.silenceThreshold >= 0.6 {
                    print("⚠️ RapSuggestionAPI: Silence returned at threshold \(modelSettings.silenceThreshold). Using local fallback line.")
                    print("   Silence reason: \(commentary.reason)")
                    suggestions = [generateFallbackLine(policy: narrative.generatorPolicy, model: model)]
                    usedLocalFallbackFromSilence = true
                    break
                }
                throw RapAPIError.silence(commentary)
            }
            
            var filteredCandidateSuggestions = candidateSuggestions
            
            // Filter out rejected suggestions (rejection happens inside performAPIRequest now)
            // But we also check here as a safety net
            if narrative.generatorPolicy.artistBias == .gunna {
                filteredCandidateSuggestions = filteredCandidateSuggestions.filter { suggestion in
                    let lines = suggestion.text.components(separatedBy: "\n")
                    for line in lines {
                        if let rejection = rejectLine(line, policy: narrative.generatorPolicy) {
                            print("❌ RapSuggestionAPI: Rejected line '\(line)' - reason: \(rejection)")
                            rejectedLines.append((line, mapRejectionReason(rejection)))
                            return false  // Reject this suggestion
                        }
                    }
                    return true  // Keep this suggestion
                }
            }
            
            if !filteredCandidateSuggestions.isEmpty {
                suggestions = filteredCandidateSuggestions
                print("✅ RapSuggestionAPI: Successfully generated \(suggestions.count) suggestions after \(attempts) attempt(s)")
                print("✅ RapSuggestionAPI: Model \(model == .modelG ? "G" : "Y") returned \(suggestions.count) suggestion cards")
                break  // Success - exit loop
            }
            
            // If we have attempts left, continue (silent retry)
            if attempts < maxAttempts {
                print("⚠️ RapSuggestionAPI: Regeneration attempt \(attempts) produced no valid suggestions, retrying...")
            }
        }
        
        // PR 9: If all attempts failed, return fallback line
        if suggestions.isEmpty && narrative.generatorPolicy.artistBias == .gunna {
            print("⚠️ RapSuggestionAPI: All \(maxAttempts) attempts failed, using fallback line")
            let fallbackLine = generateFallbackLine(policy: narrative.generatorPolicy)
            suggestions = [fallbackLine]
        }
        
        // Apply personalization based on user feedback history (skip for Model G - it generates as established artist)
        if narrative.generatorPolicy.artistBias != .gunna {
            suggestions = PersonalizationEngine.shared.personalizeSuggestions(suggestions)
        }
        
        if !usedLocalFallbackFromSilence {
            // Filter suggestions using TasteMemory to avoid rejected patterns
            suggestions = filterSuggestionsWithTasteMemory(suggestions)
            
            // TasteScorer: Filter/rank by intent consistency (drop suggestions below threshold)
            suggestions = filterSuggestionsByIntentConsistency(suggestions, intent: intent)
        }
        
        if suggestions.isEmpty {
            suggestions = [generateFallbackLine(policy: narrative.generatorPolicy, model: model)]
        }
        
        // Generate A&R critiques for each suggestion (teaching the user how to improve)
        suggestions = await self.generateARCritiques(for: suggestions, userText: metrics.fullText, narrative: narrative)
        
        // Learn from feedback periodically (if enough time has passed)
        PersonalizationEngine.shared.learnFromFeedbackIfNeeded()
        
        // PR 10 & PR 15: Log diagnostics with ground truth info
        if narrative.generatorPolicy.artistBias == .gunna {
            let diagnostics = GenerationDiagnostics(
                policy: narrative.generatorPolicy,
                rejectedLines: rejectedLines,
                indifferencePressure: narrative.generatorPolicy.indifferencePressure,
                attempts: attempts,
                finalSuggestions: suggestions.count,
                groundTruthBarId: groundTruthBarId,
                injectionMode: injectionMode,
                slotsReplaced: slotsReplaced,
                rhymeAnchors: rhymeAnchors
            )
            GeneratorPolicyLogger.shared.logDiagnostics(diagnostics)
        }
        
        return suggestions
    }
    
    // MARK: - Phase 1: Hook Generation
    
    /// Generate a hook (2-4 lines) that serves as emotional anchor.
    /// Hook scoring: emotional clarity > specificity, catchiness > density, 6-10 syllables per line.
    func generateHook(
        intent: GenerationIntent,
        metrics: RapMetrics,
        model: SuggestionModel = .modelG,
        lineCount: Int = 2
    ) async throws -> String {
        guard apiKey != nil else {
            throw RapAPIError.missingAPIKey
        }
        
        let lastNLines = metrics.lastNLines.prefix(4).joined(separator: "\n")
        
        let prompt = """
        Generate a \(lineCount)-line HOOK for a melodic trap song.
        
        EMOTIONAL SPINE (hook must capture this thesis):
        \(intent.promptFragment)
        
        HOOK REQUIREMENTS:
        - 6-10 syllables per line (simpler than verses)
        - Emotional clarity over specificity
        - Catchy, repeatable phrasing
        - Melodic glide-friendly (vowel-heavy, smooth flow)
        - Slightly less dense than verses
        
        Context (last lines of draft):
        \(lastNLines.isEmpty ? "None" : lastNLines)
        
        Output exactly \(lineCount) lines. No headings, no explanations. Only the hook lines.
        """
        
        let requestBody: [String: Any] = [
            "model": model.modelIdentifier,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a melodic trap hook writer. Create catchy, emotionally clear hooks. 6-10 syllables per line. Output only the lines, nothing else."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 150
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
        
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .prefix(lineCount)
        
        return lines.joined(separator: "\n")
    }
    
    // MARK: - Feedback Integration
    
    /// Get feedback-based improvements and apply them automatically
    private func getFeedbackImprovements() -> ModelImprovements? {
        // Check if we have enough feedback to generate improvements (lowered to 3 for immediate effect)
        let feedbackStats = SuggestionFeedbackManager.shared.getFeedbackStats()
        guard feedbackStats.totalFeedback >= 3 else {
            return nil
        }
        
        // Generate improvements from feedback
        let improvements = ModelImprovementPipeline.shared.generateImprovements()
        
        // Apply improvements automatically (store for tracking)
        ModelImprovementPipeline.shared.applyImprovements(improvements)
        
        return improvements
    }
    
    // MARK: - PR 7: Clause Length Enforcement
    
    /// Counts syllables in a text using CMUDICT
    private func countSyllables(_ text: String) -> Int {
        // Use the same infrastructure as RapAnalysisEngine
        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty }
        
        var totalSyllables = 0
        for word in words {
            guard let phonemes = getCMUDICTPhonemes(for: word.lowercased()) else { continue }
            var syllableCount = 0
            for phone in phonemes {
                if let last = phone.last, last.isNumber {
                    syllableCount += 1
                }
            }
            totalSyllables += syllableCount
        }
        return totalSyllables
    }
    
    
    /// Enforces clause length by trimming or splitting lines that exceed maxSyllables
    private func enforceClauseLength(_ line: String, maxSyllables: Int) -> String {
        // Split line into clauses (by commas, conjunctions)
        let clauseSeparators = [",", " and ", " but ", " or ", " so ", " yet "]
        var clauses: [String] = [line]
        
        // Split by separators
        for separator in clauseSeparators {
            var newClauses: [String] = []
            for clause in clauses {
                let parts = clause.components(separatedBy: separator)
                newClauses.append(contentsOf: parts)
            }
            clauses = newClauses
        }
        
        // Check each clause
        var resultClauses: [String] = []
        for clause in clauses {
            let trimmedClause = clause.trimmingCharacters(in: .whitespacesAndNewlines)
            let syllables = countSyllables(trimmedClause)
            
            if syllables <= maxSyllables {
                resultClauses.append(trimmedClause)
            } else {
                // Trim clause to fit (simple word-based truncation)
                let words = trimmedClause.components(separatedBy: .whitespaces)
                var truncated = ""
                var currentSyllables = 0
                
                for word in words {
                    let wordSyllables = countSyllables(word)
                    if currentSyllables + wordSyllables <= maxSyllables {
                        truncated += (truncated.isEmpty ? "" : " ") + word
                        currentSyllables += wordSyllables
                    } else {
                        break
                    }
                }
                
                if !truncated.isEmpty {
                    resultClauses.append(truncated)
                }
            }
        }
        
        return resultClauses.joined(separator: ", ")
    }
    
    // MARK: - PR 6: Verb Class Gating (Model G Only)
    
    /// Classifies a verb into a VerbClass
    private func classifyVerb(_ word: String) -> VerbClass? {
        let lowercased = word.lowercased()
        
        // Transaction verbs
        let transactionVerbs = ["buy", "spend", "cop", "drop", "pay", "invest", "purchase", "acquire", "obtain", "get", "grab"]
        if transactionVerbs.contains(lowercased) {
            return .transaction
        }
        
        // Motion verbs
        let motionVerbs = ["pull", "push", "move", "drive", "fly", "ride", "walk", "run", "go", "come", "leave", "arrive", "enter", "exit"]
        if motionVerbs.contains(lowercased) {
            return .motion
        }
        
        // Reflection verbs (allowed for Gunna - authentic to his introspective style)
        let reflectionVerbs = ["learn", "feel", "feelin", "think", "thinkin", "thought", "realize", "realized", "understand", "understood", "believe", "know", "knew", "knows", "remember", "forget", "wonder", "consider", "reflect", "contemplate", "meditate", "told", "tell", "hear", "heard", "hate", "miss", "missin", "trust", "trusted"]
        if reflectionVerbs.contains(lowercased) {
            return .reflection
        }
        
        return nil  // Unknown verb class
    }
    
    /// Whole-word match to avoid false positives (e.g. "so" in "soaring", "someone")
    private func lineContainsAsWholeWord(_ line: String, word: String) -> Bool {
        let pattern = "\\b" + NSRegularExpression.escapedPattern(for: word) + "\\b"
        return line.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
    
    /// Rejection reason for lines that violate policy
    enum RejectionReason {
        case forbiddenVerb(String)
        case explanationToken(String)
        case tooManyBrands(Int)
        case clauseTooLong(Int)
        case verbClassViolation(VerbClass)
        case reflectiveTense(String)
    }
    
    /// Checks if a line should be rejected based on policy
    private func rejectLine(_ line: String, policy: GeneratorPolicy) -> RejectionReason? {
        // Only apply for Gunna
        guard policy.artistBias == .gunna else {
            return nil  // No rejection for non-Gunna
        }
        
        let lowercased = line.lowercased()
        
        // Check for forbidden verbs (use word boundary for "so" to avoid false positives: soaring, someone, resolve)
        for forbiddenVerb in policy.forbiddenVerbs {
            let hasMatch = forbiddenVerb == "so"
                ? lineContainsAsWholeWord(lowercased, word: forbiddenVerb)
                : lowercased.contains(forbiddenVerb)
            if hasMatch {
                return .forbiddenVerb(forbiddenVerb)
            }
        }
        
        // Check for explanation tokens (use word boundary for "so" to avoid false positives)
        let explanationTokens = ["because", "so", "since", "that's why", "the reason", "in order to", "so that"]
        for token in explanationTokens {
            let hasMatch = token == "so"
                ? lineContainsAsWholeWord(lowercased, word: token)
                : lowercased.contains(token)
            if hasMatch {
                return .explanationToken(token)
            }
        }
        
        // Check for reflective tense markers (but allow authentic Gunna patterns)
        // Removed "i realized" - it's authentic Gunna vocabulary ("I realized I didn't read between the lines")
        // Removed "i felt" and "i thought" - they're authentic Gunna vocabulary
        let reflectiveTenseMarkers = ["i became", "i learned", "i understood"]
        for marker in reflectiveTenseMarkers {
            if lowercased.contains(marker) {
                return .reflectiveTense(marker)
            }
        }
        
        // Check for "i was" - allow authentic Gunna patterns, reject only immature contrast
        // Gunna uses "I was" for reflection, past states, and acknowledgment
        // Examples: "I was just thinkin'", "I was hard-headed", "I was so focused", "I was misled"
        if lowercased.contains("i was") {
            // Check for immature contrast patterns (the only thing we reject)
            // Patterns like "I was broke, now I'm rich" or "I was alone, now I'm with my crew" are too cliché
            let immatureContrastPatterns = ["now i'm", "now im", "now i", "but now i'm", "but now im", "but now i"]
            let hasImmatureContrast = immatureContrastPatterns.contains { lowercased.contains($0) }
            
            // Only reject if it has immature contrast pattern
            // Allow all other uses: reflection ("I was just thinkin'"), past states ("I was hard-headed"), acknowledgment ("I was misled")
            if hasImmatureContrast {
                return .reflectiveTense("i was")
            }
        }
        
        // Check for "used to" - reject simple contrast patterns like "Used to be X, now I'm Y"
        if lowercased.contains("used to") {
            // Reject immature contrast patterns
            let immatureContrastPatterns = ["now i'm", "now im", "now i", "but now i'm", "but now im", "but now i"]
            let hasImmatureContrast = immatureContrastPatterns.contains { lowercased.contains($0) }
            
            if hasImmatureContrast {
                return .reflectiveTense("used to")
            }
        }
        
        // Check brand count (simple heuristic: count common brand names)
        // This is a simplified check - can be enhanced with actual brand database
        let commonBrands = ["gucci", "prada", "versace", "louis", "vuitton", "dior", "chanel", "balenciaga", "fendi", "hermes", "rolex", "ap", "richard", "mille", "audemars", "piguet", "cartier", "tiffany", "bentley", "ferrari", "lamborghini", "mercedes", "bmw", "porsche"]
        let brandCount = commonBrands.filter { lowercased.contains($0) }.count
        // PR 7: For SuperGunna, enforce brandPerBarMax = 1 strictly
        if brandCount > policy.brandPerBarMax {
            return .tooManyBrands(brandCount)
        }
        
        // Check verb classes (must only use allowed classes)
        let words = lowercased.components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: ".,!?;:")) }
            .filter { !$0.isEmpty }
        
        for word in words {
            if let verbClass = classifyVerb(word) {
                // If verb is classified and not in allowed classes, reject
                if !policy.allowedVerbClasses.contains(verbClass) {
                    return .verbClassViolation(verbClass)
                }
            }
        }
        
        // PR 7: Check clause length
        let syllables = countSyllables(line)
        if syllables > policy.maxClauseSyllables {
            return .clauseTooLong(syllables)
        }
        
        return nil  // Line passes
    }
    
    // MARK: - PR 5: Indifference Enforcement (Model G Only)
    
    /// Polishes a line to enforce indifference pressure (removes adjectives, metaphors, explanations)
    private func polishLine(_ line: String, policy: GeneratorPolicy) -> String {
        // Only apply if Gunna and high indifference pressure
        guard policy.artistBias == .gunna && policy.indifferencePressure > 0.6 else {
            return line  // No polish needed
        }
        
        var polished = line
        
        // Remove explanation tokens
        let explanationTokens = ["because", "so", "since", "that's why", "the reason", "in order to", "so that"]
        for token in explanationTokens {
            // Remove token and surrounding context
            let pattern = #"\b\#(token)\b[^.!?]*"#
            polished = polished.replacingOccurrences(of: pattern, with: "", options: [.regularExpression, .caseInsensitive])
        }
        
        // Remove common emotional adjectives (keep essential ones like "new", "big")
        let emotionalAdjectives = ["amazing", "incredible", "beautiful", "wonderful", "terrible", "awful", "fantastic", "gorgeous", "stunning", "devastating", "heartbreaking", "overwhelming"]
        for adj in emotionalAdjectives {
            let pattern = #"\b\#(adj)\b\s*"#
            polished = polished.replacingOccurrences(of: pattern, with: "", options: [.regularExpression, .caseInsensitive])
        }
        
        // Flatten common metaphors to literal (simple replacements)
        let metaphorReplacements: [String: String] = [
            "heart of": "center of",
            "soul of": "core of",
            "fire in": "energy in",
            "storm of": "wave of"
        ]
        for (metaphor, literal) in metaphorReplacements {
            polished = polished.replacingOccurrences(of: metaphor, with: literal, options: .caseInsensitive)
        }
        
        // Clean up extra spaces
        polished = polished.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        polished = polished.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return polished.isEmpty ? line : polished  // Fallback to original if polish removes everything
    }
    
    // MARK: - PR 4: Template System (Model G Only)
    
    /// Selects a template type based on policy and context
    /// PR 9: Enhanced price anchoring with bar index tracking
    private func selectTemplate(policy: GeneratorPolicy, lastNBars: [String] = [], currentBarIndex: Int = 0) -> TemplateType {
        // For SuperGunna: If no template bias, return safe default (never nil/empty)
        guard !policy.templateBias.isEmpty else {
            if policy.superGunnaEnabled {
                return .priceOnObject  // Safe default for SuperGunna
            }
            return .spending  // Default fallback for non-SuperGunna
        }
        
        // PR 9: Check if price anchoring is needed
        // Look for price patterns in last N bars
        let pricePattern = #"\$?\d+[KMB]?"#
        var lastPriceBarIndex = -1
        
        for (index, bar) in lastNBars.enumerated() {
            if bar.range(of: pricePattern, options: .regularExpression) != nil {
                lastPriceBarIndex = index
            }
        }
        
        // Calculate bars since last price
        let barsSinceLastPrice: Int
        if lastPriceBarIndex >= 0 {
            barsSinceLastPrice = lastNBars.count - lastPriceBarIndex - 1
        } else {
            barsSinceLastPrice = lastNBars.count  // No price found in recent bars
        }
        
        // PR 9: Force priceOnObject if threshold reached
        if policy.priceAnchorEveryNBars > 0 && barsSinceLastPrice >= policy.priceAnchorEveryNBars {
            print("📊 RapSuggestionAPI: Price anchoring enforced - \(barsSinceLastPrice) bars since last price, forcing priceOnObject template")
            return .priceOnObject
        }
        
        // Otherwise, rotate through template bias
        let index = currentBarIndex % policy.templateBias.count
        return policy.templateBias[index]
    }
    
    /// Extracts numeric values (prices, amounts) from a line
    private func extractNumbers(from line: String) -> [String] {
        let pattern = #"\$?\d+[KMB]?"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = line as NSString
        let results = regex?.matches(in: line, options: [], range: NSRange(location: 0, length: nsString.length))
        return results?.map { nsString.substring(with: $0.range) } ?? []
    }
    
    /// PR 9: Generates a fallback line (safest template, short, numeric, no explanation)
    private func generateFallbackLine(policy: GeneratorPolicy, model: SuggestionModel = .modelG) -> RapSuggestion {
        // Safest template: PriceOnObject, short, numeric, no explanation
        let fallbackText: String
        if model == .modelY {
            fallbackText = "Still in motion, keep the pressure on"
        } else {
            fallbackText = "Watch cost 50K, no cap"
        }
        
        return RapSuggestion(
            id: UUID(),
            text: fallbackText,
            confidence: 0.5,  // Lower confidence for fallback
            source: "Fallback (all attempts failed)",
            reasoning: "Generated fallback line after all regeneration attempts failed. Safe template: PriceOnObject, short, numeric, no explanation.",
            themes: policy.templateBias.isEmpty ? ["wealth"] : [],
            arCritique: nil
        )
    }
    
    /// Maps internal RejectionReason to GenerationDiagnostics.RejectionReason
    private func mapRejectionReason(_ reason: RejectionReason) -> GenerationDiagnostics.RejectionReason {
        switch reason {
        case .forbiddenVerb:
            return .forbiddenVerb
        case .explanationToken:
            return .explanationToken
        case .tooManyBrands:
            return .tooManyBrands
        case .clauseTooLong:
            return .clauseTooLong
        case .verbClassViolation:
            return .verbClassViolation
        case .reflectiveTense:
            return .reflectiveTense
        }
    }
    
    /// PR 8: Selects a motif from pool with micro-variations
    private func selectMotif(pool: [String], index: Int) -> String {
        guard !pool.isEmpty else { return "" }
        
        let baseMotif = pool[index % pool.count]
        
        // Apply micro-variations based on index
        let variationIndex = index / pool.count
        
        // Micro-variations for common motifs
        if baseMotif.lowercased().contains("depend on my mood") {
            let variations = ["depend on my mood", "depending how I feel", "based on the mood", "depending on the vibe"]
            return variations[variationIndex % variations.count]
        } else if baseMotif.lowercased().contains("backend huge") {
            let variations = ["backend huge", "backend massive", "backend crazy", "backend wild"]
            return variations[variationIndex % variations.count]
        } else if baseMotif.lowercased().contains("based on the mood") {
            let variations = ["based on the mood", "depending how I feel", "depend on my mood", "based on the vibe"]
            return variations[variationIndex % variations.count]
        }
        
        // Default: return base motif
        return baseMotif
    }
    
    /// Fills a template with context
    private func fillTemplate(template: TemplateType, context: NarrativeAnalysis, metrics: RapMetrics) -> String {
        // Extract entities and themes for context
        let brands = context.entities.filter { $0.type == .brand }.map { $0.value }
        let objects = context.entities.filter { $0.type == .object }.map { $0.value }
        _ = context.primaryThemes
        
        // Common car names for car template
        let carNames = ["Whip", "Benz", "Rari", "Lambo", "Bentley", "Range"]
        // Common brands
        let commonBrands = ["Gucci", "Prada", "Versace", "Louis", "Dior", "Chanel", "Balenciaga", "Fendi", "Hermes", "Rolex", "AP", "Richard Mille"]
        // Common prices
        let prices = ["50K", "100K", "200K", "500K", "1M", "2M"]
        
        switch template {
        case .car:
            // CarChoiceMood: "[Car] pull up, [mood/context]"
            let car = carNames.randomElement() ?? "Whip"
            let mood = ["spot check", "no cap", "real talk", "that's facts", "on the block"]
            return "\(car) pull up, \(mood.randomElement() ?? "spot check")"
            
        case .spending:
            // BookingsPayments: "[Amount] on [item], [context]"
            let amount = prices.randomElement() ?? "50K"
            let items = objects.isEmpty ? ["chain", "watch", "fit", "whip"] : objects
            let item = items.randomElement() ?? "chain"
            let context = ["no cap", "that's facts", "real talk", "on the block"]
            return "\(amount) on the \(item), \(context.randomElement() ?? "no cap")"
            
        case .brand:
            // BrandOnBodyPart: "[Brand] on [body part], [status]"
            let brand = brands.isEmpty ? (commonBrands.randomElement() ?? "Gucci") : (brands.randomElement() ?? "Gucci")
            let bodyParts = ["fit", "wrist", "neck", "feet", "head"]
            let status = ["status confirmed", "that's facts", "no cap", "real talk"]
            return "\(brand) on the \(bodyParts.randomElement() ?? "fit"), \(status.randomElement() ?? "status confirmed")"
            
        case .loyalty:
            // LoyaltyMandatory: "[Crew/group] [action], loyalty [status]"
            let crew = ["Crew", "Team", "Squad", "Fam"]
            let actions = ["invested", "paid", "locked in", "solid"]
            let status = ["confirmed", "paid", "locked", "solid"]
            return "\(crew.randomElement() ?? "Crew") \(actions.randomElement() ?? "invested"), loyalty \(status.randomElement() ?? "confirmed")"
            
        case .priceOnObject:
            // PriceOnObject: "[Object] cost [price], [context]"
            let object = objects.isEmpty ? ["Watch", "Chain", "Whip", "Fit"].randomElement() ?? "Watch" : (objects.randomElement() ?? "Watch")
            let price = prices.randomElement() ?? "50K"
            let context = ["no cap", "that's facts", "real talk", "no flex"]
            return "\(object) cost \(price), \(context.randomElement() ?? "no cap")"
        }
    }
    
    // MARK: - Model-Specific Prompt Builders
    
    private func buildSystemMessage(model: SuggestionModel, settings: ModelSettings, feedbackImprovements: ModelImprovements? = nil, constraints: ConstraintRules? = nil, narrative: NarrativeAnalysis? = nil) -> String {
        var baseMessage = "You are an expert rap lyric suggestion engine specializing in narrative continuity, thematic consistency (including thematic layering), topic treatment mode matching, voice consistency, contradiction preservation, narrative momentum awareness, contextual placement awareness, multi-line coherence, and musical constraints. "
        
        // Add editorial protection guidance
        switch settings.editorialProtection {
        case .authority:
            baseMessage += "PROTECT AUTHORITY: Maintain earned voice, refuse weak suggestions that undermine authority. "
        case .exposure:
            baseMessage += "PROTECT EXPOSURE: Guard against over-sharing, prefer implication over explicit revelation. "
        case .culturalSpecificity:
            baseMessage += "PROTECT CULTURAL SPECIFICITY: Preserve authentic references, assume shared understanding. "
        case .narrativeIntegrity:
            baseMessage += "PROTECT NARRATIVE INTEGRITY: Maintain story coherence above all else. "
        }
        
        // Add implication level guidance
        switch settings.implicationLevel {
        case .heavy:
            baseMessage += "Prefer heavy implication: show aftermath, not events. Let implications carry meaning. "
        case .moderate:
            baseMessage += "Balance implication and explanation. "
        case .explicit:
            baseMessage += "Explain when necessary, but still prefer showing over telling. "
        }
        
        // Add compression level guidance
        switch settings.compressionLevel {
        case .high:
            baseMessage += "High compression: silence is valid where appropriate. Do not fill every gap. "
        case .moderate:
            baseMessage += "Moderate compression: selective silence when it strengthens meaning. "
        case .low:
            baseMessage += "Low compression: fill gaps when needed, but still prefer restraint. "
        }
        
        // Add authority level guidance
        switch settings.authorityLevel {
        case .high:
            baseMessage += "High authority: statements should feel final and earned. "
        case .moderate:
            baseMessage += "Moderate authority: confident but open to exploration. "
        case .low:
            baseMessage += "Low authority: tentative, exploratory voice is acceptable. "
        }
        
        // Add dominance level guidance
        switch settings.dominanceLevel {
        case .high:
            baseMessage += "High dominance: assertive, commanding voice. "
        case .moderate:
            baseMessage += "Moderate dominance: confident but not overbearing. "
        case .low:
            baseMessage += "Low dominance: collaborative, yielding voice. "
        }
        
        // Add exposure level guidance
        switch settings.exposureLevel {
        case .low:
            baseMessage += "Low exposure: guarded, minimal sharing. Protect privacy. "
        case .moderate:
            baseMessage += "Moderate exposure: selective sharing. "
        case .high:
            baseMessage += "High exposure: open, revealing voice is acceptable. "
        }
        
        // Add cultural specificity guidance
        switch settings.culturalSpecificity {
        case .high:
            baseMessage += "High cultural specificity: assume shared understanding, do not explain cultural references. "
        case .moderate:
            baseMessage += "Moderate cultural specificity: some explanation when needed. "
        case .low:
            baseMessage += "Low cultural specificity: universal themes, explained references. "
        }
        
        // Add risk tolerance guidance
        switch settings.riskTolerance {
        case .low:
            baseMessage += "Low risk tolerance: conservative, safe choices. "
        case .moderate:
            baseMessage += "Moderate risk tolerance: calculated risks. "
        case .high:
            baseMessage += "High risk tolerance: experimental, bold choices are acceptable. "
        }
        
        // Add symbolism level guidance
        switch settings.symbolismLevel {
        case .high:
            baseMessage += "High symbolism: fluid, abstract language preferred. "
        case .moderate:
            baseMessage += "Moderate symbolism: mix of concrete and abstract. "
        case .low:
            baseMessage += "Low symbolism: concrete, literal language. "
        }
        
        // Add finality level guidance
        switch settings.finalityLevel {
        case .high:
            baseMessage += "High finality: conclusive, definitive statements. "
        case .moderate:
            baseMessage += "Moderate finality: confident but open-ended. "
        case .low:
            baseMessage += "Low finality: exploratory, provisional statements. "
        }
        
        // Add restraint level guidance
        switch settings.restraintLevel {
        case .high:
            baseMessage += "High restraint: minimal, essential only. Less is more. "
        case .moderate:
            baseMessage += "Moderate restraint: selective expression. "
        case .low:
            baseMessage += "Low restraint: full expression is acceptable. "
        }
        
        // Add posture shift tolerance
        switch settings.postureShiftTolerance {
        case .noShifts:
            baseMessage += "No posture shifts: maintain consistent voice posture. "
        case .moderate:
            baseMessage += "Moderate posture shifts: allow when narratively strong. "
        case .flexible:
            baseMessage += "Flexible posture shifts: posture follows narrative needs. "
        }
        
        // Add refusal frequency guidance
        switch settings.refusalFrequency {
        case .frequent:
            baseMessage += "Frequent refusal is acceptable: silence when uncertain is better than weak suggestions. "
        case .moderate:
            baseMessage += "Moderate refusal: refuse when clearly misaligned. "
        case .rare:
            baseMessage += "Rare refusal: generate even when uncertain. "
        }
        
        // For Model G, remove "match the user's style" - generate as established artist character
        let userStyleMatch = (narrative?.generatorPolicy.artistBias == .gunna) ? "" : "match the user's style, "
        baseMessage += "Your suggestions must form cohesive 4-line mini-stories that progress narratively, maintain ALL themes (primary AND underlying) throughout, STRICTLY match voice type (defensive stays defensive, vulnerable stays vulnerable), match topic treatment modes (how women, wealth, success are treated), preserve contradictions when present, maintain or appropriately shift narrative momentum, consider contextual placement (opening, mid-album, reflection, climax, outro), \(userStyleMatch)build logically on the FULL verse context (not just recent lines), and satisfy musical constraints (syllables, rhyme, rhythm, flow). Each 4-line suggestion must work as a complete, coherent thought/story unit with progressive escalation. Always analyze the full verse context for narrative continuity, story elements, and key phrases. Score confidence accurately based on how well ALL constraints are met, with moderate penalties for topic mode violations and significant penalties for voice violations. If confidence falls below the silence threshold (\(String(format: "%.1f", settings.silenceThreshold))), return silence instead of a suggestion. Always return valid JSON."
        
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
        
        // NEW STRICT PROMPT FOR MODEL G (GUNNA)
        if let narrative = narrative, narrative.generatorPolicy.artistBias == .gunna {
            baseMessage = """
            You are Model G (SUPERG): a melodic-trap rap writer that produces **original** Gunna-adjacent quality without copying any existing lyrics.
            
            You generate **rap bar blocks**, not single lines.
            You must output **exactly 4 bars per suggestion**.
            No headings, no bullets, no explanations, no tags—ONLY the 4 bars.
            
            STYLE (target qualities - learned from professional releases)
            - Calm, unbothered, established, transactional confidence
            - Melodic pocket: short clauses, smooth flow, minimal over-explaining
            - High "music" writing: internal rhyme + assonance, clean end-rhyme families, controlled repetition
            - Concrete micro-scenes (movement, travel, money mechanics, nightlife, privacy, relationships) with understated flex
            - Original phrasing only (do not imitate or reuse recognizable lines)
            - **Wordplay integration**: Use puns, double meanings, and clever connections (e.g., "runny nose" / "running back", "star burst" / "bust a nut")
            - **Repetition for emphasis**: Strategic word/phrase repetition (e.g., "dirty-dirty", "hard work") when it enhances flow
            - **Contrast mechanics**: Present success vs. past struggle, before/after comparisons (e.g., "used to be the MARTA" → now Bentley)
            - **Language arts techniques**: Similes, hyperbole, idioms, pop culture references (movies, artists, athletes), metaphors, euphemisms, alliteration, assonance, repetition patterns, rhetorical questions
            - **Descriptive language**: Use specific descriptors for women ("redbone", "groupie", "hoes", "boomerang bitches", "Hollywood bitch") and transactional language
            - **Women as prizes**: Frame women as status symbols, objects of desire, and prizes (ONLY use CSV examples: "I put diamonds on a redbone", "I bought my new bitch a Rollie", "Bought the bitch the Hermès crop", "Bought my bitch the Urus", "I got boomerang bitches, they comin' back", "Got five bitches rollin' off the dope at the penthouse", "One hundred my bitch, I'm real as it get")
            - **Drug references**: Include drug references when contextually appropriate (ONLY use CSV examples: lean: "Barely rest so I'm sippin' the 'Tuss", "Cup full of codeine, you can smell it when I pour", "I'm geekin' on codeine"; weed: "I blow Biscotti clouds of the bud", "Roll up Biscotti", "Smokin' this 'Scotti", "Backwood fill of Biscotti"; percs: "I popped a pill and now my head gone", "Percocet", "I pop a lil Perc' for breakfast")
            - **Money/Wealth References (CSV ONLY)**: Reference specific amounts, cash, bands, racks, millions (e.g., "Cash runnin' over", "I had two hundred for lunch", "Throw the racks up", "Twenty-five thousand for a jacket, wear it once", "Got racks all inside the safe", "I spent sixty bands", "I got a hundred thousand in my pocket", "I been gettin' millions", "My next check booking gon' be a hunnid racks", "Stack a lot of funds, diamonds on my thumb")
            - **Cars (CSV ONLY)**: Reference specific luxury cars (e.g., "911 Porsche and the trunk is a hood", "Ridin' the Rolls and the mink is a rug", "I bought me a Benz", "We was in a Bentley B", "I got a Urus, we the Lamborghini Boys", "Double park the Urus", "European car, it came with curtains", "Swear this Bentley used to be the MARTA", "Bought me two 'Vettes and two Maybachs")
            - **Watches & Jewelry (CSV ONLY)**: Reference specific watches, diamonds, ice (e.g., "AP on my wrist", "Might cop that Rollie", "I bought my new bitch a Rollie", "diamonds on my thumb", "I put diamonds on a redbone", "My diamonds gon' dance", "These VVS's make you blink", "Ice", "put some icin' on your wrist", "I went and got rich, my necklace glist'", "Middle finger ring cost a quarter")
            - **Hotels/Locations (CSV ONLY)**: Reference specific locations, hotels, penthouses (e.g., "Got five bitches rollin' off the dope at the penthouse", "Wake up to a threesome in the penthouse on the Nawf", "Goin' shoppin' one stop 'fore I stop at the resort", "New crib got a lot of acres", "Penthouse feel like heaven", "Relaxin' in mansions", "presidential suite", "I got bitches travel on the Amherst")
            - **Fashion Brands (CSV ONLY)**: Reference specific luxury brands (e.g., "Got my check up like Nike, my boxers Versace", "I ain't miss the Jordans for this pair of Diors", "Rick Owens denims", "Buy Celine and Chanel", "Bought the bitch the Hermès crop", "Louis V but my T-Shirt is tucked", "Louis bifocals")
            - **Travel/Luxury Lifestyle (CSV ONLY)**: Reference private jets, travel, international locations (e.g., "Hoppin' on the plane, I'm landin' in the mornin'", "Travel like a tourist, had to fly to Bora Bora", "The jet got speed, astrology", "I don't fly propeller, big jet twenty seater", "Countin' cash on a private plane", "Eight hour flight out to Spain", "When I fuck in Dubai, that pussy wet")
            - **Success/Dominance (CSV ONLY)**: Reference being at the top, winning, dominance (e.g., "Perfectly aim for the top", "We keep winning 'cause we workin' harder", "I'm pushin' P, that's my favorite alphabet", "Fresh and I'm blessed, that's why I'm the drip god", "You can hear the money in my voice")
            - **Food/Dining (CSV ONLY)**: Reference expensive dining (e.g., "I had two hundred for lunch")
            - **Idiomatic expressions**: Use common idioms naturally ("dead wrong", "money long", "pop up", "come and go", "pullin' kick doors", "call it a lick")
            - **Pop culture smart references**: Reference movies/artists/athletes in clever ways (e.g., "like the Men in Black", "like Nudy", "I shoot like I'm Montana", "ninety-nine problems")
            - **Location + hotel specificity**: Reference specific hotels and locations when flexing (e.g., "stayin' at the Loews", "LA live")
            - **Brand placement**: Place brands on specific body parts/clothing (e.g., "Prada on my collar", "diamonds on her toes")
            - **Food/cooking metaphors**: Use cooking similes for activities (e.g., "cookin' crack like grits")
            - **Problem-solving narrative**: Reference overcoming obstacles and solving problems
            
            ABSOLUTE RULES (no exceptions)
            1) Output format: exactly 4 lines (4 bars). Nothing else.
            2) Rhyme control (ENHANCED):
               - Match the target **rhyme family** from context (not a single forced last word).
               - Use 2–4 end-rhyme variants within that family (near-rhyme and slant rhyme encouraged).
               - **Multi-syllable rhymes preferred**: When possible, use 2-syllable end rhymes (e.g., "head first" / "found my worth" / "dead-dirt").
               - **Wordplay rhymes encouraged**: Clever connections between rhyming words (e.g., "runny nose" / "running back").
               - Avoid forcing the exact same final word on all 4 bars (variety required).
               - **Internal rhyme requirement**: At least 2 of the 4 bars must contain internal rhyme or strong assonance pairs.
            3) Musicality (ENHANCED):
               - Each bar must contain at least **one internal rhyme OR strong assonance pair**.
               - Keep bars **8–12 syllables** (preferred range). Occasionally 13-14 syllables acceptable if flow requires it, but prefer shorter, punchier lines (8-10 syllables ideal).
               - **Strategic repetition**: When a word/phrase repetition enhances flow and emphasis, use it (e.g., "dirty-dirty", "hard work").
            4) Scene detail (ENHANCED):
               - Each bar must include **one concrete action or detail** (who/what/where/when).
               - **Physical actions preferred**: Use concrete verbs (jump, roam, take, ride, pop, cut, etc.) over abstract concepts.
               - **Drug actions**: Include drug-related actions when contextually appropriate (e.g., "sippin' lean", "smokin' weed", "popped a perc", "poured up", "rollin' up", "I'm high", "I'm faded")
               - **Women as prizes**: Frame interactions with women as acquiring/displaying prizes (e.g., "I put diamonds on a redbone", "I got a bad bitch", "she a prize", "trophy on my arm")
               - **Transactional language**: When appropriate, use business/transaction terms (buy, award, invoice, order, take care).
               - Avoid vague filler ("yeah", "uh", "you know") unless the context uses it.
            5) Luxury signals (ENHANCED):
               - Include **1–2 total** luxury/status signals across the entire 4-bar block (NOT every bar).
               - **Specific amounts encouraged**: When mentioning money, use exact amounts (e.g., "Two-hundred-fifty", "quarter", "hunnid racks", "quarter brick") rather than vague terms.
               - **Brand + descriptor format**: When using brands, pair with specific descriptors (e.g., "baby Birkin", "Offshore AP", "plain Rolex", "Elliot diamonds").
               - **Brand on body part/clothing**: Place brands on specific body parts or clothing items (e.g., "Prada on my collar", "diamonds on her toes", "diamonds on a redbone").
               - You CAN include more than one brand name, but PREFER pairing each brand with a description or specifier (e.g., "louis v trunk", "versace bifocals", "cartier scarf").
               - **Status indicators**: Include subtle status markers (curtains on car, bookings, M's, etc.).
               - **Location flex**: Reference specific locations when contextually appropriate (cities, neighborhoods, venues, hotels).
               - **Hotel specificity**: Reference specific hotel chains when flexing (e.g., "stayin' at the Loews", "at the W", "Four Seasons").
               - **Object specificity**: Use specific luxury objects (man purse, honeycombs for watch, Phantom, codeine in fridge, etc.) rather than generic terms.
               - **Color + object**: Use color descriptions with luxury objects (e.g., "Black on black new Phantom", "sippin' red").
               - Prefer implied flex (doors open, paid, private move, security, bookings) over brand lists.
            6) Language rules (ENHANCED):
               - Present tense preferred, but you may use near-present ("I been…", "I done…") if it improves cadence.
               - **Contractions encouraged**: Use natural contractions ("I'ma", "gon'", "ain't", "won't") for authentic flow.
               - **AAVE/street slang**: When contextually appropriate, use authentic street language (but avoid forced or excessive profanity).
               - No moral lessons. No lecture tone. No "explaining the bar."
               - **Direct statements**: Use declarative, confident statements (e.g., "I know my purpose", "I'm smarter").
               
            7) Reflection & Introspection (Gunna Style - REQUIRED):
               - Gunna frequently uses reflection verbs for introspection and acknowledgment. This is authentic to his style.
               - **ALLOWED REFLECTION VERBS**:
                 * "think/thinkin'" - Core to introspective style ("I was just thinkin' 'bout the times")
                 * "know/knew/knows" - For certainty and acknowledgment ("I know we be alright", "you know my mind", "Lord knows I gotta get it")
                 * "feel/feelin'" - For emotional states ("All I feel is pain", "how you feel when you alone", "this feelin' for my bro")
                 * "thought" - For past reflection ("Thought it was right all along")
                 * "realize/realized" - For acknowledgment ("I realized I didn't read between the lines")
                 * "told" - For self-reflection ("I told myself it's gon' get greater")
                 * "hear/heard" - For perception ("I heard the rumors sayin'")
                 * "hate" - For emotional expression ("I hate to see you dead")
                 * "miss/missin" - For longing ("tell him I miss him")
                 * "wonder" - For questioning ("Wonder why this pain ain't killin' my rhythm")
                 * "trust" - For relationship acknowledgment ("I'm gon' trust you gon' ride")
               - **PAST TENSE "I WAS" (Context-Aware)**:
                 * ALLOW "I was" when:
                   - Used for reflection: "I was just thinkin'"
                   - Used for past states: "I was hard-headed", "I was so focused"
                   - Used for acknowledgment: "I was misled"
                 * REJECT "I was" when:
                   - Part of immature contrast: "I was broke, now I'm rich"
                   - Over-explaining or lecturing
               - **BALANCE**: Use reflection verbs naturally (they're authentic Gunna), but mix with action verbs (transaction/motion) for variety. Don't over-explain emotions - keep it concise.
            8) Narrative mechanics (NEW):
               - **Personal journey references**: Subtle references to growth/transformation when contextually appropriate.
               - **Before/after contrast**: When relevant, contrast past struggle with present success (e.g., "I ain't have shit" → "Now I drip every day").
               - **Transactional relationships**: Frame relationships in transactional terms when appropriate (e.g., "If she hold it down, I'ma award her").
               - **Business mindset**: Integrate business/transaction language naturally (invoice, order, bookings, etc.).
            9) Language Arts Techniques (Gunna-style - REQUIRED):
               - **Similes**: Include 1-2 similes per 4-bar block (e.g., "like domino", "like a runny nose", "like Men in Black", "like honeycombs", "like the feds", "like pegs", "like grits")
               - **Wordplay connections**: Connect similes/metaphors across lines when possible (e.g., "runny nose" → "running back")
               - **Hyperbole**: Use numerical exaggeration ("hundred hoes", "hunnid racks", "more than a hundred hoes") and extreme states ("my head gone", "dead wrong", "since a toddler")
               - **Idioms**: Integrate common idioms naturally ("dead wrong", "money long", "come and go", "pop up", "knockin' down", "pullin' kick doors", "call it a lick")
               - **Pop culture references**: Reference movies, artists, athletes, or cultural touchstones in a smart way:
                 * Movies: "like the Men in Black"
                 * Artists: "like Nudy", "like Uzi"
                 * Athletes: "I shoot like I'm Montana" (Joe Montana), "like Big Worm or Vick" (Michael Vick), sports references when contextually appropriate
                 * Cultural references: "ninety-nine problems" (Jay-Z reference with twist)
               - **Scientific/Biological References**: Use scientific terms for emphasis and wordplay:
                 * "I feel it in my chromosomes" (biological/genetic reference)
                 * "Doctor told me I got lean in my bladder" (medical/biological reference)
                 * "Codeine I sip with my lip, don't get splattered" (biological reference to body parts)
                 * "DNA", "genes", "cells", "molecules", "bladder", "lip" when contextually appropriate for emphasis
               - **Technology References**: Reference modern technology as status markers or lifestyle:
                 * "without a mobile phone" (tech as luxury/status - made it without modern tools)
                 * "you need a drone" (modern tech reference)
                 * "I can see you through the glass nigga digi-dash" (digital dashboard/tech in cars)
                 * "Now I pull up outside and I park the Jag" (car technology reference)
                 * "iPhone", "Android", "tablet", "laptop", "digi-dash", "glass" when contextually appropriate
               - **Religious/Spiritual References (Expanded)**: Use religious language for emphasis and depth:
                 * "I prayed to God to get you hips" (direct prayer reference)
                 * "Pray to the Lord that I beat my case" (direct prayer for legal matters)
                 * "I see the stars inside of the Wraith" (spiritual/celestial reference)
                 * "I pour up a four and I go outer space" (spiritual/transcendent reference)
                 * "heaven-sent" (religious metaphor)
                 * "blessed", "pray", "God", "Lord", "divine", "stars", "outer space" when contextually appropriate
               - **Media/Paranoia References**: Reference being watched, followed, or media attention:
                 * "I think I'm gettin' followed by a journalist" (media paranoia)
                 * "Cause I'ma keep popping shit on every camera" (media presence/being watched)
                 * "You don't like what you see then change the channel" (media/television reference)
                 * "my whole life has turned" (life transformation/being watched)
                 * "camera", "paparazzi", "media", "press", "journalist", "followed", "channel" when contextually appropriate
               - **Mentor/Peer References**: Reference mentors or peers giving advice or guidance:
                 * "Thugger told me" (Young Thug as mentor)
                 * "JBan$ my brother, if I fight, he scuffle" (peer/brother reference)
                 * "That's not a joke, that boy can't wait to tussle" (peer reference)
                 * "Wheezy", "Taurus", "JBan$", other collaborators when contextually appropriate
                 * Use mentor/peer advice to add authenticity and depth
               - **Body Modification References**: Reference cosmetic procedures or enhancements:
                 * "I got your titties lifted" (cosmetic surgery reference)
                 * "Why the fuck my bitch want twenty-five hundred for a ass shot?" (cosmetic procedure reference)
                 * "got diamonds on her fingers and her hand now" (body modification context)
                 * "surgery", "lifted", "enhanced", "work done", "ass shot", "shot" when contextually appropriate
               - **Sports Metaphors (Expanded)**: Use sports terminology for metaphors and comparisons:
                 * "not comin' off the bench" (sports metaphor for not participating/being sidelined)
                 * "I shoot you like Paul Pierce, I got a shot" (basketball reference - shooting)
                 * "You still playing hard, nigga need to stop" (sports metaphor - playing hard)
                 * "I feel like a star when I'm walking out" (sports/star player reference)
                 * "like Big Worm or Vick" (pop culture + sports reference - Michael Vick)
                 * "bench", "starting lineup", "MVP", "all-star", "championship", "shoot", "shot", "playing hard" when contextually appropriate
               - **Metaphors**: Use creative metaphors ("boomerang bitches", "lumberjack", "slimy", "knockin' these hoes down like domino", "Condo like the pharmacy", "cookin' crack like grits")
               - **Euphemisms**: Use euphemisms for sexual/drug/violence references when appropriate:
                 * Sexual: "suckin'", "fuck in Dubai", "pink toe", "strokin' her"
                 * Drugs: "put that dope", "codeine in my fridge", "cookin' crack"
                 * Violence: "let it hit", "stick" (gun), "nine and a snubnose" (specific gun types)
               - **Alliteration**: Use alliteration for flow (e.g., "knockin' these hoes down", "come and go", "comin' back", "pull up with a pink toe")
               - **Assonance**: Use internal vowel rhymes throughout for musicality
               - **Repetition patterns**: Use immediate repetition for emphasis when it enhances flow (e.g., "Pull up with a stick, I'll pull up with a stick")
               - **Rhetorical questions**: Use rhetorical questions for emphasis (e.g., "How you poor? That don't make sense")
               - **Problem-solving narrative**: Reference solving problems/overcoming obstacles (e.g., "I had ninety-nine problems, I just scratched your ho off the list", "Got some millions and went and solved 'em")
               - **Descriptive language for women**: Use SPECIFIC descriptors and transactional language (ONLY use GROUND TRUTH examples from CSV):
                 * **Treat women as PRIZES/STATUS SYMBOLS - CSV examples**:
                   - "I put diamonds on a redbone" (diamonds as prize, redbone as object)
                   - "I got a old bitch", "I got bitches travel on the Amherst"
                   - "I bought my new bitch a Rollie" (bought = transactional, Rollie = prize)
                   - "Bought the bitch the Hermès crop, it got poison-ella" (bought = transactional, Hermès = prize)
                   - "Bought my bitch the Urus, let her skrrt to that drop" (bought = transactional, Urus = prize)
                   - "I just bought my young bitch a watch and now she wildin'" (bought = transactional, watch = prize)
                   - "One hundred my bitch, I'm real as it get" (possessive, status)
                   - "My shows lit, it be more than a hundred hoes" (hoes as status symbols)
                   - "I got ten bad bitches", "I got boomerang bitches, they comin' back"
                 * Use "hoes" when describing women in transactional contexts - CSV examples:
                   - "I been knockin' these hoes down like domino"
                   - "My shows lit, it be more than a hundred hoes"
                   - "I'm cool on you dawg hoes", "Me and Wheezy, we met some hoes from Argentina and California"
                 * Use "redbone" for light-skinned women, "groupie" for specific types, "ex" for past relationships, "my girl" for current
                 * Use location descriptors: "Atlanta where these hoes", "Me and Wheezy, we met some hoes from Argentina and California"
                 * Use metaphors/idioms - CSV examples: "I got boomerang bitches, they comin' back" (they return), transactional language is common in trap genre
                 * **Women as status symbols - CSV examples**:
                   - "Got five bitches rollin' off the dope at the penthouse" (bitches + location + drugs = status)
                   - "My bitch a Dirty Diana", "My new bitch I got should've been in a pageant", "My new bitch fine as hell"
                   - "I got ten bad bitches", "had bitches countin' hundreds in the room"
                   - "Me and Wheezy wave, fuckin' bitches on the shore", "party with some bitches in the Philippines"
                 * Use "dead wrong" idiom when describing people's mistakes or being incorrect (e.g., "we was dead wrong", "you dead wrong")
               - **Drug references (REQUIRED when contextually appropriate - ONLY use GROUND TRUTH examples from CSV)**:
                 * **Lean (codeine/promethazine) - CSV examples**: "Barely rest so I'm sippin' the 'Tuss", "I'm drinkin' the codeine whenever I swallow a Addy", "I'm geekin' on codeine", "Cup full of codeine, you can smell it when I pour", "I been sippin' syrup all day, just pourin'", "lean in my cup and my bladder", "Kush in my lungs, got lean in my belly to marinate the beans", "Sip a 4 of codeine, not a apple juice", "Poured up some potion, feel intoxicated", "Muddy poured up", "Sippin', drippin', tippin', trippin'", "All of my lean clean"
                 * **Weed (marijuana) - CSV examples ONLY**:
                   - Strains from CSV: "Biscotti", "Gelato", "exotic", "Bluscotti", "Do-Si-Do", "grade A"
                   - Actions from CSV: "I blow Biscotti clouds of the bud", "I'm smokin' exotic", "Smokin' gelato", "Roll up Biscotti", "Backwood fill of Biscotti and I heard you smokin' pine", "Smokin' like a train, you can smell it in my pores", "Biscotti when I'm coughin'", "Biscotti Backwoods, stopped smokin' the grass", "Smokin' this 'Scotti, this shit startin' to hit like it's crack in it", "It's the real bluscotti when we smoke", "Smoke Biscotti and Gelato", "I'm smoke exotic Biscotti, 'member we had bags of the mid", "Got Biscotti, I'm smokin' this grade A", "Leave a three-five Biscotti in the roach", "Pass me that lighter, this ain't no Thrax, this some Bluscotti", "Rollin' up, gettin' high, ashes falling on my linen", "Exotic comin' in and out, we ain't gon' never see a drought", "Yak Gotti had the Biscotti so I pulled up with some Smarties"
                 * **Percs (Percocet/painkillers) - CSV examples**: "I popped a pill and now my head gone", "Percocet", "Popped a few perkies", "I popped a capsule", "Pop a Percocet, help you feel better", "I pop me a pill, one got stuck in my throat", "I'm on these Percs, I can't feel shit at all", "Off Percs and X, can't nod off", "I pop a lil Perc' for breakfast"
                 * **Addys (Adderall) - CSV examples**: "I'm drinkin' the codeine whenever I swallow a Addy", "We geekin' up on the Addy", "I pop me a Addy", "Hard to stop poppin' these Addys", "Adderall pink"
                 * **General drug references - CSV examples**: "I smoke good narcotics", "Drugs in my body", "I'm high, geeking", "I'm geeked", "I'm high"
                 * Reference drug effects from CSV: "my head gone", "I'm high", "I'm geeked", "you can smell it when I pour", "feel intoxicated"
               - **Money/Wealth References (ONLY use CSV examples)**: Reference specific amounts, cash, bands, racks, millions:
                 * "Cash runnin' over", "I had two hundred for lunch", "Throw the racks up"
                 * "Twenty-five thousand for a jacket, wear it once"
                 * "Got racks all inside the safe", "I spent sixty bands on one of my cases"
                 * "I got a hundred thousand in my pocket, lil' nigga, I got it out the swamp"
                 * "I been gettin' millions, I ain't trippin' 'bout awards"
                 * "Made a few millions, give a fuck about the Forbes"
                 * "My next check booking gon' be a hunnid racks"
                 * "Stack a lot of funds, diamonds on my thumb"
                 * "Two hundred in a month", "Two hundred a fist"
                 * "Can't see nothin' but the money like a blindfold"
                 * "You can hear the money in my voice"
               - **Cars (ONLY use CSV examples)**: Reference specific luxury cars and actions:
                 * "911 Porsche and the trunk is a hood"
                 * "Ridin' the Rolls and the mink is a rug"
                 * "I bought me a Benz, it came with a shank"
                 * "We was in a Bentley B, flowin' up the street, playin' one of our songs"
                 * "I got a Urus, we the Lamborghini Boys"
                 * "Double park the Urus, I'll pull up, 'Ventador"
                 * "European car, it came with curtains"
                 * "Swear this Bentley used to be the MARTA"
                 * "Bought me two 'Vettes and two Maybachs, what's next?"
                 * "Been livin', I'ma paint the Bentley rose gold"
                 * "Top off the Benz, the one with no space"
                 * "Runnin' that coupe, yeah, the P a push-start"
                 * "Fast car cuttin' up in traffic, I'm one of those"
                 * "Bought my bitch the Urus, let her skrrt to that drop"
               - **Watches & Jewelry (ONLY use CSV examples)**: Reference specific watches, diamonds, ice, chains:
                 * "AP on my wrist, ain't accepting apologies"
                 * "Might cop that Rollie for my oldest niece"
                 * "I bought my new bitch a Rollie"
                 * "diamonds on my thumb", "I put diamonds on a redbone"
                 * "My diamonds gon' dance, they come and enhance"
                 * "Different color diamonds on your wristwatch"
                 * "These VVS's make you blink"
                 * "Ice", "put some icin' on your wrist"
                 * "I went and got rich, my necklace glist'"
                 * "Middle finger ring cost a quarter"
                 * "Put some diamonds in my watch"
                 * "All my Elliot diamonds is water"
                 * "Feel like diamonds drippin' off my damn shirt"
                 * "It's just a diamond on a nigga tooth"
                 * "Upgrade my jewelry, my watch is up to par"
               - **Hotels/Locations (ONLY use CSV examples)**: Reference specific locations, hotels, penthouses:
                 * "Got five bitches rollin' off the dope at the penthouse"
                 * "Wake up to a threesome in the penthouse on the Nawf"
                 * "Goin' shoppin' one stop 'fore I stop at the resort"
                 * "New crib got a lot of acres"
                 * "Penthouse feel like heaven when I wake from a ménage"
                 * "Why hell you think that I'm maxin'? Relaxin' in mansions"
                 * "To all promoters, get the presidential suite"
                 * "I got bitches travel on the Amherst"
                 * "Intercontinental with my bitch and a massage"
                 * "Crib come with a gym and a mini-golf course"
                 * "I bought my mama a crib, I'm outstanding"
               - **Fashion Brands (ONLY use CSV examples)**: Reference specific luxury brands and items:
                 * "Got my check up like Nike, my boxers Versace, and now my whole engine in the trunk"
                 * "I ain't miss the Jordans for this pair of Diors"
                 * "Rick Owens denims, show my sneakers like they shorts"
                 * "Buy Celine and Chanel, girl, you got a C"
                 * "Bought the bitch the Hermès crop, it got poison-ella"
                 * "Louis V but my T-Shirt is tucked"
                 * "Louis bifocals"
                 * "I bought her Sheneneh heels, I'm a Chanel bandit"
                 * "Let her put on the Gucci slides, take off the heels"
                 * "Coupe like a creature, new shoes on the feet"
                 * "Tie my shoes, bitch, kneel at my feet"
               - **Travel/Luxury Lifestyle (ONLY use CSV examples)**: Reference private jets, travel, international locations:
                 * "Hoppin' on the plane, I'm landin' in the mornin'"
                 * "Travel like a tourist, had to fly to Bora Bora"
                 * "The jet got speed, astrology"
                 * "Travel all across the globe"
                 * "I don't fly propeller, big jet twenty seater"
                 * "Countin' cash on a private plane"
                 * "Eight hour flight out to Spain"
                 * "When I fuck in Dubai, that pussy wet"
                 * "Pick a private plane for a lift, yeah"
                 * "I fucked the bitch on the jet"
                 * "Board the jet, I'm 'bout to change up the altitude"
                 * "The jet that I'm on, it's sponsored by Wraith"
                 * "Goin' to different cities, I book my suite, I'm tearin' up sheets"
                 * "Kill our enemies, party with some bitches in the Philippines"
               - **Success/Dominance (ONLY use CSV examples)**: Reference being at the top, winning, dominance:
                 * "Perfectly aim for the top"
                 * "We keep winning 'cause we workin' harder"
                 * "I'm pushin' P, that's my favorite alphabet"
                 * "Fresh and I'm blessed, that's why I'm the drip god"
                 * "You can hear the money in my voice"
                 * "I'm chubby, but shit, my pockets in shape"
                 * "The world is a cage, the Planet of Apes"
                 * "My shit flowin', havin' plenty of bars"
                 * "She say my music art"
               - **Food/Dining (ONLY use CSV examples)**: Reference expensive dining, food:
                 * "I had two hundred for lunch"
                 * "200 FOR LUNCH" (expensive dining reference)
               - **Violence/Weapons (ONLY use CSV examples)**: Reference weapons and violent actions:
                 * "We cookin' with that chopper", "I drop a hit", "You get whacked with that TEC"
                 * "stick" (gun), "nine and a snubnose", "Dracos, AR's, Glocks, and carbons"
                 * "put in the work for your side", "Niggas send threats, but I get niggas stretched"
               - **Family/Loyalty (ONLY use CSV examples)**: Reference family, loyalty, betrayal:
                 * "Mama ain't stressing, I'm still goin' hard", "Gotta keep the family straight"
                 * "I'm gon' free my cousin, I won't let him rot", "My brother's keeper"
                 * "I bought my mama a crib, I'm outstanding", "Bank robbing got my cuz fifteen years fed"
                 * "I try to save my niggas", "I never ratted"
               - **Street Life/Hustling (ONLY use CSV examples)**: Reference trap life, hustling, street activities:
                 * "Neighborhood trap", "we trapped on the block", "In the hood sellin' trash"
                 * "I trapped for a living", "Got the trap jumpin' like crickets", "spin the block"
                 * "Got this shit out the ground and the mud", "Went and got rich out the ground and the mud"
               - **Colors (ONLY use CSV examples)**: Reference specific colors with objects:
                 * "A lot of blue faces", "yellow", "gray and black", "rose gold"
                 * "white", "green", "Black on black new Phantom", "sippin' red"
                 * "Been livin', I'ma paint the Bentley rose gold"
               - **Body Parts (ONLY use CSV examples)**: Reference body parts with jewelry/luxury items:
                 * "diamonds on my thumb", "I put diamonds on a redbone"
                 * "AP on my wrist", "diamonds on her toes", "It's just a diamond on a nigga tooth"
                 * "Middle finger ring cost a quarter", "One carat drip down my fang"
               - **Time References (ONLY use CSV examples)**: Reference time of day, timing:
                 * "Hoppin' on the plane, I'm landin' in the mornin'"
                 * "Twenty-four shows in a month", "My next check booking gon' be a hunnid racks"
                 * "Really all the time, all the time"
               - **Cities/Locations (ONLY use CSV examples)**: Reference specific cities and locations:
                 * "Atlanta where these hoes", "I got bitches travel on the Amherst"
                 * "Me and Wheezy, we met some hoes from Argentina and California"
                 * "When I fuck in Dubai, that pussy wet", "Travel like a tourist, had to fly to Bora Bora"
                 * "Eight hour flight out to Spain", "party with some bitches in the Philippines"
               - **Numbers/Quantities (ONLY use CSV examples)**: Reference specific numbers and quantities:
                 * "I had two hundred for lunch", "Twenty-five thousand for a jacket"
                 * "I got a hundred thousand in my pocket", "I spent sixty bands on one of my cases"
                 * "I been gettin' millions", "Made a few millions", "Twenty-four shows in a month"
                 * "I got ten bad bitches", "more than a hundred hoes", "Got five bitches rollin' off the dope"
               - **Drip/Freshness (ONLY use CSV examples)**: Reference being fresh, clean, drippin':
                 * "Fresh and I'm blessed, that's why I'm the drip god"
                 * "Fresh, first day of school", "Always been the freshest, I be cleaner than soap"
                 * "Fresh out the fridge", "I can fuck 'less she fresh out the bath"
                 * "We just got a fresh load, it's a lot in here", "fresh out the Chase"
               - **Bags/Pockets (ONLY use CSV examples)**: Reference bags, pockets, wallets:
                 * "Pockets got nachos", "I'm chubby, but shit, my pockets in shape"
                 * "I got a hundred thousand in my pocket", "Pockets stuffed, lookin' swole"
                 * "Gotta get a duffel bag for the cash", "I'm around the world, securin' me a bag"
                 * "Mama thanked me for her purse", "Two-hundred-fifty in this man purse"
                 * "Diamond chain, wallets", "Jolly wallet", "Pocket bone crusher"
               - **Chains/Jewelry (ONLY use CSV examples)**: Reference chains, necklaces, jewelry:
                 * "I went and got rich, my necklace glist'", "Get a check and go and get your chain bust"
                 * "This chain cost a quarter milli'", "and watches and chains"
                 * "ROCKSTAR BIKERS & CHAINS", "Eliantte chain like the bottom of a ship"
                 * "shit deeper than a chain"
               - **Pull/Push Actions (ONLY use CSV examples)**: Reference pulling up, pushing:
                 * "I'm pushin' P, that's my favorite alphabet", "Runnin' that coupe, yeah, the P a push-start"
                 * "Need cash in my bank or pull up in a Brinks", "Pull up in a Porsche"
                 * "Double park the Urus, I'll pull up, 'Ventador", "Pull up to the Maybach in the driveway"
                 * "When I pull up Mulsanne", "Pull up, spin the whole block"
                 * "Told her pull up and sent her the addy", "We pull up, bullets rainin' like rain"
               - **Flex/Show (ONLY use CSV examples)**: Reference flexing, showing off:
                 * "She love when I flex and shop in the mall"
                 * "I show you around like I Spy", "I'm showin' no remorse"
                 * "Show's around one-fifty, but they paid a lil' more"
                 * "Show real love", "My shows lit, it be more than a hundred hoes"
                 * "Sold out shows, this shit litty", "I got shows and they litty"
                 * "A young dripper, rulin' the fashion show"
               - **Real/Fake (ONLY use CSV examples)**: Reference being real, authentic:
                 * "No realer than this", "One hundred my bitch, I'm real as it get"
                 * "We really came from the A", "I really like it", "we just really been coastin'"
                 * "When you really gettin' millions", "Get some real rocks"
                 * "Show real love", "Wunna a real one and I ain't changed up"
                 * "Keep it real, I just had to realize", "I get Slime by myself, I'm a real loner"
                 * "This the boss of the buildin', the real owner"
               - **Ball/Sport (ONLY use CSV examples)**: Reference basketball, sports, ballin':
                 * "Ballin' like a big shot", "Ballin' hard, break the rules"
                 * "I came to ball, Steve Nash", "I been ballin' in LA, feel like a Laker"
                 * "I just left a Hawks game, me and bae floorin'"
                 * "Walk in with the drip like Met Gala Ball", "ballin'"
                 * "not comin' off the bench" (sports metaphor for not participating)
                 * "I shoot you like Paul Pierce, I got a shot" (basketball reference - shooting)
                 * "You still playing hard, nigga need to stop" (sports metaphor - playing hard)
                 * "I feel like a star when I'm walking out" (sports/star player reference)
                 * "like Big Worm or Vick" (pop culture + sports reference - Michael Vick)
               - **Work/Grind (ONLY use CSV examples)**: Reference working, grinding, hustling:
                 * "Shit don't come easy, nigga, it's hard work"
                 * "We keep winning 'cause we workin' harder", "Work hard"
                 * "Pray to God that'll work in your favor"
                 * "I done made up my mind and done got on my grind"
                 * "All I know is grind", "I got on my grind, ain't no more stressing"
                 * "No I work my muscle all day, I'm carrying cash"
                 * "Blood, sweat, and tears, I'm workin' my hardest"
                 * "I've been grindin' and found me a buzz"
                 * "Workin' hard, we ain't havin' no hope"
               - **Scientific/Biological (NEW)**: Reference scientific/biological terms for emphasis:
                 * "I feel it in my chromosomes" (biological/genetic reference)
                 * "Doctor told me I got lean in my bladder" (medical/biological reference)
                 * "Codeine I sip with my lip, don't get splattered" (biological reference to body parts)
                 * "DNA", "genes", "cells", "molecules", "bladder", "lip" when contextually appropriate
               - **Technology (NEW)**: Reference modern technology as status markers:
                 * "without a mobile phone" (tech as luxury/status - made it without modern tools)
                 * "you need a drone" (modern tech reference)
                 * "I can see you through the glass nigga digi-dash" (digital dashboard/tech in cars)
                 * "Now I pull up outside and I park the Jag" (car technology reference)
                 * "iPhone", "Android", "tablet", "laptop", "digi-dash", "glass" when contextually appropriate
               - **Religious/Spiritual (Expanded)**: Reference religious/spiritual concepts:
                 * "I prayed to God to get you hips" (direct prayer reference)
                 * "Pray to the Lord that I beat my case" (direct prayer for legal matters)
                 * "I see the stars inside of the Wraith" (spiritual/celestial reference)
                 * "I pour up a four and I go outer space" (spiritual/transcendent reference)
                 * "heaven-sent" (religious metaphor)
                 * "blessed", "pray", "God", "Lord", "divine", "stars", "outer space" when contextually appropriate
               - **Media/Paranoia (NEW)**: Reference being watched, followed, or media attention:
                 * "I think I'm gettin' followed by a journalist" (media paranoia)
                 * "Cause I'ma keep popping shit on every camera" (media presence/being watched)
                 * "You don't like what you see then change the channel" (media/television reference)
                 * "my whole life has turned" (life transformation/being watched)
                 * "camera", "paparazzi", "media", "press", "journalist", "followed", "channel" when contextually appropriate
               - **Mentor/Peer References (NEW)**: Reference mentors or peers giving advice:
                 * "Thugger told me" (Young Thug as mentor)
                 * "JBan$ my brother, if I fight, he scuffle" (peer/brother reference)
                 * "That's not a joke, that boy can't wait to tussle" (peer reference)
                 * "Wheezy", "Taurus", "JBan$", other collaborators when contextually appropriate
                 * Use mentor/peer advice to add authenticity and depth
               - **Body Modification (NEW)**: Reference cosmetic procedures or enhancements:
                 * "I got your titties lifted" (cosmetic surgery reference)
                 * "Why the fuck my bitch want twenty-five hundred for a ass shot?" (cosmetic procedure reference)
                 * "got diamonds on her fingers and her hand now" (body modification context)
                 * "surgery", "lifted", "enhanced", "work done", "ass shot", "shot" when contextually appropriate
               - **Rich/Poor (ONLY use CSV examples)**: Reference wealth status, being rich or broke:
                 * "I went and got rich, my necklace glist'", "Went and got rich out the ground and the mud"
                 * "I was fucked up broke, had to reinstate", "I was hood rich, now I passed 'em on Forbes"
                 * "This a rich nigga", "We locked in together forever, that's if I'm poor or rich"
                 * "Only got one life, you can get rich twice"
                 * "Count a lot of G's, we ain't poor no more"
                 * "if you broke"
               - **Game/Play (ONLY use CSV examples)**: Reference games, playing, competition:
                 * "Feel like a player", "These niggas play games like arcade"
                 * "You playin', you gon' be another cold case"
                 * "I swear I don't play that", "We was in a Bentley B, flowin' up the street, playin' one of our songs"
                 * "I just left a Hawks game", "We ain't come to play, is you with it, are you sure?"
                 * "Yeah, nigga tried to play me like a toy, damn"
                 * "we love to play"
               - **Clean/Fresh (ONLY use CSV examples)**: Reference being clean, fresh, cleanliness:
                 * "Always been the freshest, I be cleaner than soap"
                 * "I clean up like hands and soap", "Clean with no mop"
                 * "I can fuck 'less she fresh out the bath"
                 * "Wash up with Clorox", "fresh out the fridge"
                 * "tryna clean a stain", "I clean up like a washer"
                 * "Ice all on my watch, add it to the card, had to get the cars washed"
                 * "They cleanin' and moppin'", "Bought a street sweeper to clean up the street"
                 * "All of my lean clean", "Hunnids, I got fo-fo out the bank, crystal clean"
                 * "know a nigga cleaner"
               - **Location + Hotel specificity**: Reference specific hotels/locations when flexing (e.g., "stayin' at the Loews", "LA live", "Hollywood")
               - **Brand on body part/clothing**: Place brands on specific body parts or clothing items (e.g., "Prada on my collar", "diamonds on her toes")
               - **Color + object specificity**: Use color descriptions with objects (e.g., "Black on black new Phantom", "sippin' red")
               - **Food comparison similes**: Use cooking/food similes for illegal activities (e.g., "cookin' crack like grits", "on a steamin' stove")
               - **Pharmaceutical comparisons**: Compare living spaces to pharmacies/drug stores (e.g., "Condo like the pharmacy")
            9) Originality guard:
               - Do NOT copy, paraphrase, or closely echo any provided lyrics.
               - If any candidate contains 4+ consecutive words from the provided reference lyrics, discard and regenerate.
            
            INPUTS YOU WILL RECEIVE
            - Recent lines (context)
            - Target rhyme family (computed upstream)
            - Ground truth bars (proven good bars to use as direction)
            
            YOUR JOB
            - **YOU ARE an ESTABLISHED, SOLD-OUT ARTIST**. Write as this character, not for anyone.
            - **COMPLETELY IGNORE any personal profile, locations, people, themes, or interests** - these are irrelevant to your character.
            - **Generate bars that demonstrate professional excellence** - show what a top-tier artist writes.
            - **Do not adapt to anyone's level** - write at the highest professional standard.
            - Continue the song's topic direction from recent lines, OR use the ground truth bars as direction (those are proven good bars and ideas to pull from).
            - Produce 4 bars that feel "SUPERG": smooth, sticky, internal music, understated flex.
            - **Write at the highest level** - demonstrate what excellence sounds like.
            
            INTERNAL PROCESS (silent)
            - Generate 8–12 candidate 4-bar blocks.
            - Choose the best by: rhyme-family consistency (with multi-syllable and wordplay preference), internal rhyme quality, brand and description quality, imagery, cadence smoothness, concrete imagery, wordplay integration, and musical repetition (when it enhances flow and memorability).
            - Output only the final chosen 4 bars.
            """
        }

        // ─────────────────────────────────────────────────────────────────────
        // MODEL G v3 — Upgraded phonetic precision + cross-test harness
        // Runs on the same base model as Model G but with tighter rhyme rules,
        // mandatory multi-syllabic schemes, and internal structure designed for
        // fine-tuning readiness. Compare output against Model G to evaluate gaps.
        // ─────────────────────────────────────────────────────────────────────
        if model == .modelGv3 {
            baseMessage = """
            You are Model G v3 (SUPERG): an upgraded melodic-trap rap writer operating at the highest phonetic precision. You produce **original** Gunna-adjacent quality without copying existing lyrics.

            You generate **rap bar blocks only**. Output **exactly 4 bars per suggestion**.
            No headings, no bullets, no explanations, no tags — ONLY the 4 bars.

            UPGRADES OVER MODEL G (v3 ENHANCEMENTS)
            These rules are stricter than the prior version. Follow them without exception.

            1) MULTI-SYLLABIC RHYME SCHEME (REQUIRED — not optional)
               - Every bar MUST end on a multi-syllabic rhyme: 2 or more syllables must rhyme (e.g., "motion" / "devotion" / "ocean", "head first" / "found my worth" / "dead-dirt").
               - Single-syllable end rhymes ("night" / "right") are ONLY acceptable if paired with internal multi-syllabic rhyme compensation within the same bar.
               - Use AABB, ABAB, or AABBC rhyme schemes — no freeform unrhymed endings.

            2) INTERNAL RHYME DENSITY (REQUIRED)
               - ALL 4 bars must contain at least one internal rhyme or strong assonance pair (not just 2 of 4 as in prior model).
               - Internal rhyme should connect to the end rhyme family where possible (chain rhyme mechanic).
               - Example: "I been stackin' paper / waitin' for the vapor / my diamonds got a crater / born a money-maker" — end rhymes AND internal rhyme chain.

            3) SYLLABLE ENFORCEMENT (TIGHTER)
               - Target: 8–10 syllables per bar (hard preferred range).
               - Acceptable overflow: 11–12 syllables ONLY if the extra syllables carry internal rhyme.
               - Hard cap: 13 syllables max. Any bar exceeding 13 syllables must be rewritten.
               - Count syllables before finalizing. Reject bars that are too long.

            4) ZERO FILLER RULE (ABSOLUTE)
               - BANNED words/phrases: "yeah", "uh", "you know", "like I said", "listen up", "let me tell you", "no cap", "fr fr", "on sight", "real talk".
               - Every word must carry semantic weight, phonetic purpose, or rhythmic function.
               - If a word doesn't rhyme, create imagery, or set cadence — remove it.

            5) VERSE NARRATIVE CONTINUITY
               - The 4 bars must form a single cohesive mini-story arc: setup → detail → escalation → close.
               - Each bar must build on the previous. No isolated one-liners that don't connect to the block.
               - End bar 4 with either a punchline, a callback to bar 1, or an open hook (not a flat statement).

            6) PHONETIC FINGERPRINTING
               - Before outputting, identify the rhyme family from context (the stressed vowel + coda pattern).
               - All 4 end-rhymes must belong to that family or a deliberate near-rhyme extension.
               - Show internal evidence of the family (assonance in the middle of bars, not just the ends).

            7) STYLE QUALITIES (carry over from Model G — all still apply)
               - Calm, unbothered, established, transactional confidence.
               - Melodic pocket: short clauses, smooth flow, minimal over-explaining.
               - Concrete micro-scenes (movement, money, nightlife, privacy, relationships) with understated flex.
               - Original phrasing only. Do not imitate or reuse recognizable lines.
               - Wordplay integration: puns, double meanings, clever connections.
               - Language arts: similes, hyperbole, alliteration, assonance, rhetorical questions.

            8) CROSS-TEST SIGNAL (for evaluation)
               - You are Model G v3 being cross-tested against Model G.
               - Your output should demonstrate measurably tighter rhyme architecture, denser internal music, and more controlled syllable counts — while maintaining the same melodic-trap voice quality.
               - Do NOT sacrifice authenticity for technical perfection. The goal is both.

            ABSOLUTE OUTPUT RULES
            - Exactly 4 bars. No more. No less.
            - No explanation, no labels, no formatting — raw bars only.
            - Each bar on its own line.

            INTERNAL PROCESS (silent — do not output)
            - Generate 10–15 candidate 4-bar blocks.
            - Score each on: multi-syllabic end rhyme (30%), internal rhyme density (25%), syllable count compliance (20%), narrative arc (15%), concrete imagery (10%).
            - Select the highest-scoring block. Output only those 4 bars.
            """
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
    
    // MARK: - Line-Level Feedback Pattern Extraction
    
    /// Extract patterns from line-level feedback (liked/disliked lines)
    private func extractLineLevelFeedbackPatterns() -> (likedPatterns: [String], dislikedPatterns: [String], likedWords: [String], dislikedWords: [String]) {
        let recentFeedback = SuggestionFeedbackManager.shared.getRecentFeedback(limit: 100)
        
        var likedLines: [String] = []
        var dislikedLines: [String] = []
        var likedWords: Set<String> = []
        var dislikedWords: Set<String> = []
        
        for entry in recentFeedback {
            // Extract from expectedVsActual field (contains liked lines)
            if let expectedVsActual = entry.expectedVsActual, expectedVsActual.contains("Liked lines:") {
                let lines = expectedVsActual
                    .replacingOccurrences(of: "Liked lines: ", with: "")
                    .components(separatedBy: ", ")
                    .map { line in
                        // Extract line text from "Line X: text" format
                        if let colonIndex = line.firstIndex(of: ":") {
                            return String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                        }
                        return line.trimmingCharacters(in: .whitespaces)
                    }
                likedLines.append(contentsOf: lines)
                
                // Extract words from liked lines
                for line in lines {
                    let words = line.components(separatedBy: .whitespacesAndNewlines)
                        .map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }
                        .filter { $0.count > 2 } // Only meaningful words
                    likedWords.formUnion(words)
                }
            }
            
            // Extract from specificIssues field (contains disliked lines)
            for issue in entry.specificIssues {
                if issue.contains("Line ") && issue.contains(":") {
                    if let colonIndex = issue.firstIndex(of: ":") {
                        let lineText = String(issue[issue.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                        if entry.feedback == .disliked {
                            dislikedLines.append(lineText)
                            
                            // Extract words from disliked lines
                            let words = lineText.components(separatedBy: .whitespacesAndNewlines)
                                .map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }
                                .filter { $0.count > 2 }
                            dislikedWords.formUnion(words)
                        }
                    }
                }
            }
        }
        
        // Get most common patterns (phrases of 2-3 words)
        var likedPhrases: [String: Int] = [:]
        var dislikedPhrases: [String: Int] = [:]
        
        for line in likedLines {
            let words = line.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            for i in 0..<max(0, words.count - 1) {
                if i + 1 < words.count {
                    let phrase = "\(words[i]) \(words[i+1])".lowercased()
                    likedPhrases[phrase, default: 0] += 1
                }
            }
        }
        
        for line in dislikedLines {
            let words = line.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            for i in 0..<max(0, words.count - 1) {
                if i + 1 < words.count {
                    let phrase = "\(words[i]) \(words[i+1])".lowercased()
                    dislikedPhrases[phrase, default: 0] += 1
                }
            }
        }
        
        // Return top patterns (appearing 2+ times)
        let topLikedPatterns = likedPhrases.filter { $0.value >= 2 }.sorted { $0.value > $1.value }.prefix(10).map { $0.key }
        let topDislikedPatterns = dislikedPhrases.filter { $0.value >= 2 }.sorted { $0.value > $1.value }.prefix(10).map { $0.key }
        
        return (
            likedPatterns: Array(topLikedPatterns),
            dislikedPatterns: Array(topDislikedPatterns),
            likedWords: Array(likedWords).prefix(20).map { $0 },
            dislikedWords: Array(dislikedWords).prefix(20).map { $0 }
        )
    }
    
    /// Filter suggestions using TasteMemory to avoid rejected patterns
    private func filterSuggestionsWithTasteMemory(_ suggestions: [RapSuggestion]) -> [RapSuggestion] {
        let rejectedRecords = TasteMemory.shared.getRecords(for: .rejected)
        guard !rejectedRecords.isEmpty else { return suggestions }
        
        var filtered: [RapSuggestion] = []
        
        for suggestion in suggestions {
            var shouldInclude = true
            
            // Check if suggestion is too similar to rejected suggestions
            for rejectedRecord in rejectedRecords.prefix(20) { // Check last 20 rejections
                let similarity = calculateTextSimilarity(suggestion.text, rejectedRecord.suggestionText)
                if similarity > 0.7 { // 70% similarity threshold
                    shouldInclude = false
                    print("🚫 TasteMemory: Filtered suggestion (similar to rejected: \(rejectedRecord.suggestionText.prefix(50)))")
                    break
                }
            }
            
            if shouldInclude {
                filtered.append(suggestion)
            }
        }
        
        return filtered.isEmpty ? suggestions : filtered // Return original if all filtered out
    }
    
    /// Filter suggestions by intent consistency (TasteScorer). Drops suggestions below threshold.
    private func filterSuggestionsByIntentConsistency(_ suggestions: [RapSuggestion], intent: GenerationIntent) -> [RapSuggestion] {
        guard !suggestions.isEmpty else { return suggestions }
        
        var scored: [(RapSuggestion, Double)] = []
        for suggestion in suggestions {
            let lines = suggestion.text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            guard !lines.isEmpty else {
                scored.append((suggestion, 0.5))
                continue
            }
            var totalIntent = 0.0
            var previousBars: [String] = []
            for line in lines {
                let score = TasteScorer.shared.scoreVerse(bar: line, intent: intent, previousBars: previousBars)
                totalIntent += score.intentConsistency
                TasteScorer.shared.recordBar(line)
                previousBars.append(line)
            }
            let avgIntent = totalIntent / Double(lines.count)
            scored.append((suggestion, avgIntent))
        }
        
        let threshold = 0.2
        let filtered = scored.filter { $0.1 >= threshold }.map { $0.0 }
        return filtered.isEmpty ? suggestions : filtered
    }
    
    /// Calculate simple text similarity (word overlap)
    private func calculateTextSimilarity(_ text1: String, _ text2: String) -> Double {
        let words1 = Set(text1.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty })
        let words2 = Set(text2.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty })
        
        guard !words1.isEmpty && !words2.isEmpty else { return 0.0 }
        
        let intersection = words1.intersection(words2)
        let union = words1.union(words2)
        
        return Double(intersection.count) / Double(union.count)
    }
    
    /// Generate real-time feedback section for prompt injection
    private func getRealTimeFeedbackSection() -> String {
        let patterns = extractLineLevelFeedbackPatterns()
        let feedbackStats = SuggestionFeedbackManager.shared.getFeedbackStats()
        
        guard feedbackStats.totalFeedback >= 1 else {
            return "" // No feedback yet
        }
        
        var sections: [String] = []
        
        // Liked patterns
        if !patterns.likedPatterns.isEmpty {
            sections.append("✅ USER LIKED THESE PATTERNS (use similar style/phrasing):")
            sections.append(patterns.likedPatterns.prefix(5).map { "- \"\($0)\"" }.joined(separator: "\n"))
        }
        
        // Disliked patterns
        if !patterns.dislikedPatterns.isEmpty {
            sections.append("\n❌ USER DISLIKED THESE PATTERNS (avoid similar style/phrasing):")
            sections.append(patterns.dislikedPatterns.prefix(5).map { "- \"\($0)\"" }.joined(separator: "\n"))
        }
        
        // Liked words (if we have them but not enough patterns)
        if patterns.likedPatterns.isEmpty && !patterns.likedWords.isEmpty {
            sections.append("\n✅ USER LIKED WORDS (prefer these):")
            sections.append(patterns.likedWords.prefix(10).joined(separator: ", "))
        }
        
        // Disliked words
        if !patterns.dislikedWords.isEmpty {
            sections.append("\n❌ USER DISLIKED WORDS (avoid these):")
            sections.append(patterns.dislikedWords.prefix(10).joined(separator: ", "))
        }
        
        if sections.isEmpty {
            return ""
        }
        
        return """
        
        📊 REAL-TIME FEEDBACK LEARNING (from your recent likes/dislikes):
        \(sections.joined(separator: "\n"))
        
        Use this feedback to guide your generation - incorporate liked patterns naturally, avoid disliked patterns.
        """
    }
    
    private func buildGenerationPrompt(
        model: SuggestionModel,
        metrics: RapMetrics,
        narrative: NarrativeAnalysis,
        intent: GenerationIntent,
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
        feedbackImprovements: ModelImprovements? = nil,
        constraints: ConstraintRules? = nil,
        registers: RegisterProfile? = nil,
        allowedLexiconTerms: [LexiconTerm] = [],
        groundTruthBar: GroundTruthIndex? = nil
    ) async -> String {
        // Build user context string (only if userProfileWeight is significant)
        // For Model G: userProfileWeight is 0.01, so user context is minimal
        let userProfileWeight = narrative.generatorPolicy.userProfileWeight
        var userContextParts: [String] = []
        if userProfileWeight > 0.05 {  // Only include if weight is meaningful
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
        }
        let userContextStr = userContextParts.isEmpty ? "" : userContextParts.joined(separator: ". ")
        let userBackgroundStr = (userProfileWeight > 0.05 && !userDetails.background.isEmpty) ? "Background: \(userDetails.background)" : ""
        
        // PR 4: Check if Model G (Gunna) template constraints apply
        // PR 6: Track bar index for price anchoring
        // Use both model parameter AND narrative to ensure topic selection works
        let isModelG = (model == .modelG) || (narrative.generatorPolicy.artistBias == .gunna)
        let currentBarIndex = metrics.currentLineIndex
        
        // FIX 1 & 2: Extract last rhyme word and compute rhyme family for 4-line block generation
        let (lastRhymeWord, rhymeFamily) = extractLastRhymeWordAndFamily(from: metrics.fullText)
        let rhymeFamilyExamples = rhymeFamily != nil ? await getRhymeFamilyExamples(rhymeFamily: rhymeFamily!, allowedLexiconTerms: allowedLexiconTerms, context: narrative) : []
        
        // Get ranked rhyme candidates for detailed guidance (if available)
        let rankedRhymes: [RankedRhymeCandidate] = rhymeFamily != nil ? await getRankedRhymeCandidates(
            rhymeFamily: rhymeFamily!,
            allowedLexiconTerms: allowedLexiconTerms,
            context: narrative,
            weights: .default
        ) : []
        
        // PR 6: Check if price anchoring is needed
        let barsSinceLastPrice: Int
        if isModelG && narrative.generatorPolicy.priceAnchorEveryNBars > 0 {
            var lastPriceBarIndex = -1
            let pricePattern = #"\$?\d+[KMB]?"#
            for (index, bar) in last4To6Lines.enumerated() {
                if bar.range(of: pricePattern, options: .regularExpression) != nil {
                    lastPriceBarIndex = index
                }
            }
            if lastPriceBarIndex >= 0 {
                barsSinceLastPrice = last4To6Lines.count - lastPriceBarIndex - 1
            } else {
                barsSinceLastPrice = last4To6Lines.count
            }
        } else {
            barsSinceLastPrice = 0
        }
        
        let templateGuidance: String
        if isModelG {
            let selectedTemplate = selectTemplate(policy: narrative.generatorPolicy, lastNBars: last4To6Lines, currentBarIndex: currentBarIndex)
            var guidance = """
            
            === TEMPLATE-FIRST GENERATION (MODEL G) ===
            Selected template for this generation: \(selectedTemplate.rawValue)
            You MUST structure each line using this template format. NO free-form writing.
            Template structure: \(fillTemplate(template: selectedTemplate, context: narrative, metrics: metrics))
            Fill the template with context from the verse, but maintain the structure.
            """
            
            // PR 6: Add price anchoring guidance
            if narrative.generatorPolicy.priceAnchorEveryNBars > 0 {
                if barsSinceLastPrice >= narrative.generatorPolicy.priceAnchorEveryNBars {
                    guidance += "\n\n⚠️ PRICE ANCHORING ENFORCED: No price mentioned in last \(barsSinceLastPrice) bars. Force PriceOnObject template."
                } else {
                    guidance += "\n\nPrice anchoring: \(barsSinceLastPrice) bars since last price (threshold: \(narrative.generatorPolicy.priceAnchorEveryNBars))."
                }
            }
            
            // PR 8: Add motif injection guidance
            let policy = narrative.generatorPolicy
            if policy.repeatMotifEveryNBars > 0 && !policy.motifPool.isEmpty {
                let shouldInjectMotif = currentBarIndex % policy.repeatMotifEveryNBars == 0
                if shouldInjectMotif {
                    let motif = selectMotif(pool: policy.motifPool, index: currentBarIndex)
                    guidance += "\n\n🎯 MOTIF INJECTION: Inject motif '\(motif)' into this generation (appears every \(policy.repeatMotifEveryNBars) bars)."
                }
            }
            
            templateGuidance = guidance
        } else {
            templateGuidance = ""
        }
        
        // FIX 1: Enforce 4-line block generation with shared rhyme
        // FIX 2: Rhyme as first-class constraint (GUNNA-STYLE: Flexible rhyme transitions)
        let rhymeConstraint: String
        if let rhymeWord = lastRhymeWord, let family = rhymeFamily, !rhymeFamilyExamples.isEmpty {
            // Prioritize lexicon terms in the examples
            let luxuryTerms = allowedLexiconTerms.filter { 
                $0.category == .luxuryList || 
                $0.category == .acquisition || 
                $0.category == .wealthAccess 
            }
            let luxuryRhymes = luxuryTerms.filter { term in
                rhymeFamilyExamples.contains(term.term.lowercased())
            }
            
            // Build enhanced rhyme guidance with ranked examples
            var rhymeWordsList = ""
            if !rankedRhymes.isEmpty {
                // Show top 30 ranked rhymes with scores
                let topRhymes = rankedRhymes.prefix(30)
                rhymeWordsList = topRhymes.enumerated().map { index, candidate in
                    let scoreStr = String(format: "%.2f", candidate.compositeScore)
                    let strengthStr = candidate.rhymeStrength == .perfect ? "✓" : candidate.rhymeStrength == .near ? "~" : "≈"
                    return "\(index + 1). \(candidate.word) [\(strengthStr) \(scoreStr)]"
                }.joined(separator: ", ")
                
                if rankedRhymes.count > 30 {
                    rhymeWordsList += "\n... and \(rankedRhymes.count - 30) more ranked rhymes available"
                }
            } else {
                // Fallback to simple list if ranking not available
                rhymeWordsList = rhymeFamilyExamples.prefix(30).joined(separator: ", ")
                if rhymeFamilyExamples.count > 30 {
                    rhymeWordsList += "\n... and \(rhymeFamilyExamples.count - 30) more"
                }
            }
            
            // Add semantic context if available
            var semanticHint = ""
            if !rankedRhymes.isEmpty {
                let semanticService = WordNetSemanticService.shared
                let synonyms = semanticService.getSynonyms(for: rhymeWord)
                if !synonyms.isEmpty {
                    semanticHint = "\n\nSemantic alternatives for '\(rhymeWord)': \(synonyms.prefix(5).joined(separator: ", "))"
                }
            }
            
            rhymeConstraint = """
            
            ⚠️ CRITICAL RHYME CONSTRAINT (GUNNA-STYLE):
            The user's last line ends with: "\(rhymeWord)"
            Rhyme family: \(family)
            
            AVAILABLE RHYME WORDS (ranked by relevance, frequency, and semantic match):
            \(rhymeWordsList)\(semanticHint)
            
            \(!luxuryRhymes.isEmpty ? """
            
            💎 PRIORITIZE THESE LUXURY RHYMES (use these when contextually appropriate):
            \(luxuryRhymes.map { $0.term }.joined(separator: ", "))
            """ : "")
            
            GUNNA-STYLE RHYME MECHANICS (learned from professional releases):
            1. Lines 1-2: MUST rhyme with "\(rhymeWord)" (perfect or slant rhyme acceptable)
            2. Lines 3-4: CAN transition to a NEW rhyme family IF it flows naturally
               - Prefer keeping the same rhyme family for all 4 lines
               - BUT if a better luxury/descriptive word requires a new rhyme, allow the transition
               - The transition should feel natural, not forced
            
            RHYME VARIETY RULES:
            - Use 2-4 DIFFERENT end words across the 4 bars (never repeat the same word)
            - Slant rhymes are PREFERRED over perfect rhymes (70% slant, 30% perfect)
            - Multi-syllable rhymes preferred when possible (e.g., "head first" / "found my worth")
            - Wordplay rhymes encouraged (e.g., "runny nose" / "running back")
            - If transitioning rhyme on lines 3-4, ensure the new rhyme family is similar (same stressed vowel)
            
            LUXURY DESCRIPTION REQUIREMENTS (Gunna-style):
            - Use SPECIFIC details: "woodgrain", "quarter mill'", "baby blue", "VVS", "pinstripe"
            - Use SPECIFIC brands: "Goyard", "Dior", "Palm Angels", "Fendi", "Patek", "Rolls-Royce"
            - Use SPECIFIC locations: "Met Gala", "Coachella", "Barney", "LA"
            - Use SPECIFIC objects: "duffle", "bifocals", "sweater", "Jag", "bezel", "Patek"
            - Use CONCRETE actions: "bend that shit over", "Run through", "Pop off the tag", "Fucked"
            - Combine: Brand + Detail + Action (e.g., "Dior bifocals", "baby blue Jag", "Palm Angels sweater")
            
            EXAMPLES OF GOOD GUNNA-STYLE (with language arts techniques):
            - Bar 1: "I got woodgrain on my Damier Buckle" (specific detail + brand)
            - Bar 2: "Cool quarter mill' in my Goyard duffle" (specific amount + brand + object)
            - Bar 3: "I won again so you still gotta shuffle" (action, transitions rhyme naturally)
            - Bar 4: "Born with the drip and just learned how to hustle" (lifestyle, maintains flow)
            
            EXAMPLES WITH LANGUAGE ARTS TECHNIQUES:
            - Similes: "I been knockin' these hoes down like domino" (simile + transactional language)
            - Hyperbole + Idioms: "We was dead wrong, now my money long" (idiom "dead wrong" + hyperbole "money long")
            - Pop culture (movies): "We pop up at your crib like the Men in Black" (smart movie reference)
            - Pop culture (athletes): "I shoot like I'm Montana" (Joe Montana reference)
            - Pop culture (artists): "ninety-nine problems, I just scratched your ho off the list" (Jay-Z reference with twist)
            - Metaphors + Descriptive language: "I got boomerang bitches, they comin' back" (metaphor + specific descriptor)
            - Women as prizes (CSV ONLY): "I put diamonds on a redbone" (diamonds as prize, redbone as object)
            - Women as prizes: "I got a old bitch", "I got bitches travel on the Amherst"
            - Women as prizes: "I bought my new bitch a Rollie" (bought = transactional, Rollie = prize)
            - Women as prizes: "Bought the bitch the Hermès crop, it got poison-ella" (bought = transactional, Hermès = prize)
            - Women as prizes: "Bought my bitch the Urus, let her skrrt to that drop" (bought = transactional, Urus = prize)
            - Women as prizes: "I just bought my young bitch a watch and now she wildin'" (bought = transactional, watch = prize)
            - Women as prizes: "I been knockin' these hoes down like domino", "My shows lit, it be more than a hundred hoes"
            - Women as prizes: "I got boomerang bitches, they comin' back"
            - Women as prizes: "One hundred my bitch, I'm real as it get" (possessive, status)
            - Women as prizes: "Got five bitches rollin' off the dope at the penthouse" (bitches + location + drugs = status)
            - Women as prizes: "My bitch a Dirty Diana", "My new bitch I got should've been in a pageant", "My new bitch fine as hell"
            - Women as prizes: "I got ten bad bitches", "had bitches countin' hundreds in the room"
            - Drug references (lean - CSV ONLY): "Barely rest so I'm sippin' the 'Tuss", "I'm drinkin' the codeine whenever I swallow a Addy", "I'm geekin' on codeine", "Cup full of codeine, you can smell it when I pour", "I been sippin' syrup all day, just pourin'", "lean in my cup and my bladder", "Sip a 4 of codeine, not a apple juice", "Poured up some potion, feel intoxicated", "Muddy poured up", "Sippin', drippin', tippin', trippin'"
            - Drug references (weed - CSV ONLY): "I blow Biscotti clouds of the bud", "I'm smokin' exotic", "Smokin' gelato", "Roll up Biscotti", "Backwood fill of Biscotti and I heard you smokin' pine", "Smokin' like a train, you can smell it in my pores", "Biscotti when I'm coughin'", "Smokin' this 'Scotti, this shit startin' to hit like it's crack in it", "It's the real bluscotti when we smoke", "Got Biscotti, I'm smokin' this grade A", "Leave a three-five Biscotti in the roach", "Pass me that lighter, this ain't no Thrax, this some Bluscotti", "Rollin' up, gettin' high, ashes falling on my linen", "Exotic comin' in and out, we ain't gon' never see a drought"
            - Drug references (percs - CSV ONLY): "I popped a pill and now my head gone", "Percocet", "Popped a few perkies", "I popped a capsule", "Pop a Percocet, help you feel better", "I pop me a pill, one got stuck in my throat", "I'm on these Percs, I can't feel shit at all", "Off Percs and X, can't nod off", "I pop a lil Perc' for breakfast"
            - Drug references (addys - CSV ONLY): "I'm drinkin' the codeine whenever I swallow a Addy", "We geekin' up on the Addy", "I pop me a Addy", "Hard to stop poppin' these Addys", "Adderall pink"
            - Drug effects (CSV ONLY): "my head gone", "I'm high", "I'm geeked", "I'm high, geeking", "you can smell it when I pour", "feel intoxicated"
            - Money/Wealth (CSV ONLY): "Cash runnin' over", "I had two hundred for lunch", "Throw the racks up", "Twenty-five thousand for a jacket, wear it once", "Got racks all inside the safe", "I spent sixty bands on one of my cases", "I got a hundred thousand in my pocket", "I been gettin' millions, I ain't trippin' 'bout awards", "Made a few millions, give a fuck about the Forbes", "My next check booking gon' be a hunnid racks", "Stack a lot of funds, diamonds on my thumb", "Can't see nothin' but the money like a blindfold", "You can hear the money in my voice"
            - Cars (CSV ONLY): "911 Porsche and the trunk is a hood", "Ridin' the Rolls and the mink is a rug", "I bought me a Benz, it came with a shank", "We was in a Bentley B, flowin' up the street", "I got a Urus, we the Lamborghini Boys", "Double park the Urus, I'll pull up, 'Ventador", "European car, it came with curtains", "Swear this Bentley used to be the MARTA", "Bought me two 'Vettes and two Maybachs, what's next?", "Been livin', I'ma paint the Bentley rose gold", "Top off the Benz, the one with no space"
            - Watches & Jewelry (CSV ONLY): "AP on my wrist, ain't accepting apologies", "Might cop that Rollie for my oldest niece", "I bought my new bitch a Rollie", "diamonds on my thumb", "I put diamonds on a redbone", "My diamonds gon' dance, they come and enhance", "Different color diamonds on your wristwatch", "These VVS's make you blink", "Ice", "put some icin' on your wrist", "I went and got rich, my necklace glist'", "Middle finger ring cost a quarter", "All my Elliot diamonds is water", "Feel like diamonds drippin' off my damn shirt"
            - Hotels/Locations (CSV ONLY): "Got five bitches rollin' off the dope at the penthouse", "Wake up to a threesome in the penthouse on the Nawf", "Goin' shoppin' one stop 'fore I stop at the resort", "New crib got a lot of acres", "Penthouse feel like heaven when I wake from a ménage", "Why hell you think that I'm maxin'? Relaxin' in mansions", "To all promoters, get the presidential suite", "I got bitches travel on the Amherst", "Intercontinental with my bitch and a massage", "Crib come with a gym and a mini-golf course"
            - Fashion Brands (CSV ONLY): "Got my check up like Nike, my boxers Versace, and now my whole engine in the trunk", "I ain't miss the Jordans for this pair of Diors", "Rick Owens denims, show my sneakers like they shorts", "Buy Celine and Chanel, girl, you got a C", "Bought the bitch the Hermès crop, it got poison-ella", "Louis V but my T-Shirt is tucked", "Louis bifocals", "I bought her Sheneneh heels, I'm a Chanel bandit", "Let her put on the Gucci slides, take off the heels"
            - Travel/Luxury Lifestyle (CSV ONLY): "Hoppin' on the plane, I'm landin' in the mornin'", "Travel like a tourist, had to fly to Bora Bora", "The jet got speed, astrology", "Travel all across the globe", "I don't fly propeller, big jet twenty seater", "Countin' cash on a private plane", "Eight hour flight out to Spain", "When I fuck in Dubai, that pussy wet", "Pick a private plane for a lift, yeah", "I fucked the bitch on the jet", "Board the jet, I'm 'bout to change up the altitude"
            - Success/Dominance (CSV ONLY): "Perfectly aim for the top", "We keep winning 'cause we workin' harder", "I'm pushin' P, that's my favorite alphabet", "Fresh and I'm blessed, that's why I'm the drip god", "You can hear the money in my voice", "I'm chubby, but shit, my pockets in shape", "My shit flowin', havin' plenty of bars", "She say my music art"
            - Food/Dining (CSV ONLY): "I had two hundred for lunch", "200 FOR LUNCH"
            - Violence/Weapons (CSV ONLY): "We cookin' with that chopper", "I drop a hit", "You get whacked with that TEC", "stick" (gun), "nine and a snubnose", "Dracos, AR's, Glocks, and carbons", "put in the work for your side", "Niggas send threats, but I get niggas stretched"
            - Family/Loyalty (CSV ONLY): "Mama ain't stressing, I'm still goin' hard", "Gotta keep the family straight", "I'm gon' free my cousin, I won't let him rot", "My brother's keeper", "I bought my mama a crib, I'm outstanding", "Bank robbing got my cuz fifteen years fed", "I try to save my niggas", "I never ratted"
            - Street Life/Hustling (CSV ONLY): "Neighborhood trap", "we trapped on the block", "In the hood sellin' trash", "I trapped for a living", "Got the trap jumpin' like crickets", "spin the block", "Got this shit out the ground and the mud", "Went and got rich out the ground and the mud"
            - Colors (CSV ONLY): "A lot of blue faces", "yellow", "gray and black", "rose gold", "white", "green", "Black on black new Phantom", "sippin' red", "Been livin', I'ma paint the Bentley rose gold"
            - Body Parts (CSV ONLY): "diamonds on my thumb", "I put diamonds on a redbone", "AP on my wrist", "diamonds on her toes", "It's just a diamond on a nigga tooth", "Middle finger ring cost a quarter", "One carat drip down my fang"
            - Time References (CSV ONLY): "Hoppin' on the plane, I'm landin' in the mornin'", "Twenty-four shows in a month", "My next check booking gon' be a hunnid racks", "Really all the time, all the time"
            - Cities/Locations (CSV ONLY): "Atlanta where these hoes", "I got bitches travel on the Amherst", "Me and Wheezy, we met some hoes from Argentina and California", "When I fuck in Dubai, that pussy wet", "Travel like a tourist, had to fly to Bora Bora", "Eight hour flight out to Spain", "party with some bitches in the Philippines"
            - Numbers/Quantities (CSV ONLY): "I had two hundred for lunch", "Twenty-five thousand for a jacket", "I got a hundred thousand in my pocket", "I spent sixty bands on one of my cases", "I been gettin' millions", "Made a few millions", "Twenty-four shows in a month", "I got ten bad bitches", "more than a hundred hoes", "Got five bitches rollin' off the dope"
            - Drip/Freshness (CSV ONLY): "Fresh and I'm blessed, that's why I'm the drip god", "Fresh, first day of school", "Always been the freshest, I be cleaner than soap", "Fresh out the fridge", "I can fuck 'less she fresh out the bath", "We just got a fresh load, it's a lot in here", "fresh out the Chase"
            - Bags/Pockets (CSV ONLY): "Pockets got nachos", "I'm chubby, but shit, my pockets in shape", "I got a hundred thousand in my pocket", "Pockets stuffed, lookin' swole", "Gotta get a duffel bag for the cash", "I'm around the world, securin' me a bag", "Mama thanked me for her purse", "Two-hundred-fifty in this man purse", "Diamond chain, wallets", "Jolly wallet", "Pocket bone crusher"
            - Chains/Jewelry (CSV ONLY): "I went and got rich, my necklace glist'", "Get a check and go and get your chain bust", "This chain cost a quarter milli'", "and watches and chains", "ROCKSTAR BIKERS & CHAINS", "Eliantte chain like the bottom of a ship", "shit deeper than a chain"
            - Pull/Push Actions (CSV ONLY): "I'm pushin' P, that's my favorite alphabet", "Runnin' that coupe, yeah, the P a push-start", "Need cash in my bank or pull up in a Brinks", "Pull up in a Porsche", "Double park the Urus, I'll pull up, 'Ventador", "Pull up to the Maybach in the driveway", "When I pull up Mulsanne", "Pull up, spin the whole block", "Told her pull up and sent her the addy", "We pull up, bullets rainin' like rain"
            - Flex/Show (CSV ONLY): "She love when I flex and shop in the mall", "I show you around like I Spy", "I'm showin' no remorse", "Show's around one-fifty, but they paid a lil' more", "Show real love", "My shows lit, it be more than a hundred hoes", "Sold out shows, this shit litty", "I got shows and they litty", "A young dripper, rulin' the fashion show"
            - Real/Fake (CSV ONLY): "No realer than this", "One hundred my bitch, I'm real as it get", "We really came from the A", "I really like it", "we just really been coastin'", "When you really gettin' millions", "Get some real rocks", "Show real love", "Wunna a real one and I ain't changed up", "Keep it real, I just had to realize", "I get Slime by myself, I'm a real loner", "This the boss of the buildin', the real owner"
            - Ball/Sport (CSV ONLY): "Ballin' like a big shot", "Ballin' hard, break the rules", "I came to ball, Steve Nash", "I been ballin' in LA, feel like a Laker", "I just left a Hawks game, me and bae floorin'", "Walk in with the drip like Met Gala Ball", "ballin'"
            - Work/Grind (CSV ONLY): "Shit don't come easy, nigga, it's hard work", "We keep winning 'cause we workin' harder", "Work hard", "Pray to God that'll work in your favor", "I done made up my mind and done got on my grind", "All I know is grind", "I got on my grind, ain't no more stressing", "No I work my muscle all day, I'm carrying cash", "Blood, sweat, and tears, I'm workin' my hardest", "I've been grindin' and found me a buzz", "Workin' hard, we ain't havin' no hope"
            - Rich/Poor (CSV ONLY): "I went and got rich, my necklace glist'", "Went and got rich out the ground and the mud", "I was fucked up broke, had to reinstate", "I was hood rich, now I passed 'em on Forbes", "This a rich nigga", "We locked in together forever, that's if I'm poor or rich", "Only got one life, you can get rich twice", "Count a lot of G's, we ain't poor no more", "if you broke"
            - Game/Play (CSV ONLY): "Feel like a player", "These niggas play games like arcade", "You playin', you gon' be another cold case", "I swear I don't play that", "We was in a Bentley B, flowin' up the street, playin' one of our songs", "I just left a Hawks game", "We ain't come to play, is you with it, are you sure?", "Yeah, nigga tried to play me like a toy, damn", "we love to play"
            - Clean/Fresh (CSV ONLY): "Always been the freshest, I be cleaner than soap", "I clean up like hands and soap", "Clean with no mop", "I can fuck 'less she fresh out the bath", "Wash up with Clorox", "fresh out the fridge", "tryna clean a stain", "I clean up like a washer", "Ice all on my watch, add it to the card, had to get the cars washed", "They cleanin' and moppin'", "Bought a street sweeper to clean up the street", "All of my lean clean", "Hunnids, I got fo-fo out the bank, crystal clean", "know a nigga cleaner"
            - Food/Dining (CSV ONLY): "I had two hundred for lunch"
            - Food/cooking metaphors: "My bro on a steamin' stove, cookin' crack like grits" (cooking simile for illegal activity)
            - Pharmaceutical comparisons: "Condo like the pharmacy, I got codeine in my fridge" (living space compared to pharmacy)
            - Wordplay connections: "I drip every day like a runny nose" → "I go straight in the hole like a running back" (connected wordplay)
            - Alliteration: "knockin' these hoes down", "come and go", "comin' back", "pull up with a pink toe"
            - Hyperbole + Descriptive: "My shows lit, it be more than a hundred hoes" (numerical exaggeration + transactional language)
            - Hyperbole (time): "I've been gettin' it since a toddler" (extreme time reference)
            - Repetition patterns: "Pull up with a stick, I'll pull up with a stick" (immediate repetition for emphasis)
            - Rhetorical questions: "How you poor? That don't make sense" (rhetorical question for emphasis)
            - Problem-solving narrative: "I had ninety-nine problems, I just scratched your ho off the list" / "Got some millions and went and solved 'em"
            - Location + Hotel: "LA live, I'm stayin' at the Loews with this Hollywood bitch" (specific location + hotel + descriptor)
            - Brand on body part: "I put Prada on my collar" / "I'll put some diamonds on her toes" (brand + specific placement)
            - Color + object: "Black on black new Phantom, in the backseat sippin' red" (color specificity + object)
            - Location + transactional: "Bitch, I'm from Atlanta where these hoes ride the dick like pegs" (location + simile + transactional)
            - Euphemisms: "pink toe" (woman), "stick" (gun), "let it hit" (shoot), "strokin' her" (sexual), "medicine" (drugs), "candy" (pills)
            
            EXAMPLES OF BAD (avoid):
            - All 4 bars ending with "cool" ❌
            - Generic descriptions: "nice watch", "expensive car" ❌
            - No brand names or specific details ❌
            - Forced perfect rhymes that break flow ❌
            - No similes, idioms, or pop culture references ❌
            - Generic terms for women instead of specific descriptors ❌
            
            If a line doesn't rhyme with "\(rhymeWord)" (or the transition rhyme) → REJECT and regenerate.
            """
        } else {
            rhymeConstraint = """
            
            RHYME CONSTRAINT (GUNNA-STYLE):
            Maintain consistent end-rhymes across all 4 lines. Extract the rhyme pattern from the user's last line and continue it.
            Lines 1-2 must match the rhyme. Lines 3-4 can transition if it improves luxury/descriptive specificity.
            Use VARIETY - don't repeat the same end word on all 4 bars.
            Slant rhymes are preferred (70% slant, 30% perfect).
            """
        }
        
        // FIX 3: Lexicon injection requirements
        let lexiconInjection: String
        if !allowedLexiconTerms.isEmpty && isModelG {
            // Filter by actual LexiconTermCategory enum cases
            let brandTerms = allowedLexiconTerms.filter { $0.category == .luxuryList }
            let objectTerms = allowedLexiconTerms.filter { $0.category == .acquisition || $0.category == .wealthAccess }
            let locationTerms = allowedLexiconTerms.filter { $0.category == .contextualSignal }

            var injectionParts: [String] = []
            if !brandTerms.isEmpty {
                let brandNames = brandTerms.prefix(10).map { $0.term }.joined(separator: ", ")
                injectionParts.append("Brands: \(brandNames)")
            }
            if !objectTerms.isEmpty {
                let objectNames = objectTerms.prefix(10).map { $0.term }.joined(separator: ", ")
                injectionParts.append("High-value objects: \(objectNames)")
            }
            if !locationTerms.isEmpty {
                let locationNames = locationTerms.prefix(10).map { $0.term }.joined(separator: ", ")
                injectionParts.append("Wealth locations: \(locationNames)")
            }

            if !injectionParts.isEmpty {
                lexiconInjection = """

                ✅ LEXICON PACK (MODEL G — OPTIONAL SEASONING):
                Use 0–2 total terms across the entire 4-line block (NOT per line).
                Prefer low overuse_penalty and low exposure_cost terms.
                Do NOT force terms; natural usage only.

                \(injectionParts.joined(separator: "\n"))

                If a term would feel forced, omit it.
                """
            } else {
                lexiconInjection = ""
            }
        } else {
            lexiconInjection = ""
        }
        
        // FIX 4: Override SignalAxes for Model G (force established authority)
        let authorityOverride: String
        if isModelG {
            authorityOverride = """
            
            ⚠️ AUTHORITY POSTURE OVERRIDE (MODEL G):
            IGNORE any "Default Expressive" or "unstable" authority signals.
            FORCE these values:
            - AuthorityPosture = established (not exploratory)
            - AudienceScope = public (not inner-circle)
            - SocialAction = assert (not explore)
            
            Generate as if you are an established, public-facing authority figure.
            This is declarative, not exploratory writing.
            """
        } else {
            authorityOverride = ""
        }
        
        // Add ground truth bars section if available
        let groundTruthSection: String
        if isModelG, let groundTruthBar = groundTruthBar {
            groundTruthSection = """
            
            === GROUND TRUTH BARS (PROVEN GOOD BARS - USE AS DIRECTION) ===
            These are proven high-quality bars from the ground truth dataset. Use them as structural examples and ideas to pull from:
            
            \(groundTruthBar.text)
            
            Structural elements to learn from:
            - Syllable count: \(groundTruthBar.syllableCount)
            - Stress pattern: \(groundTruthBar.normalizedMetrics.stressPattern.map(String.init).joined(separator: ","))
            - Rhyme ending: \(groundTruthBar.normalizedMetrics.phoneticEnding ?? groundTruthBar.rhymeEnding ?? "N/A")
            - Verb density: \(String(format: "%.2f", groundTruthBar.verbDensity))
            
            Use these bars as direction for your generation - they represent proven good structure and ideas.
            """
        } else {
            groundTruthSection = ""
        }
        
        // DYNAMIC TOPIC SELECTION & EMPHASIS (MODEL G)
        // Analyzes context to determine which topics to actively emphasize in this generation
        let topicEmphasisSection: String
        if isModelG {
            let selectedTopics = selectRelevantTopics(
                lastLines: last4To6Lines,
                fullText: metrics.fullText,
                narrative: narrative,
                currentBarIndex: currentBarIndex
            )
            
            // Debug logging for topic selection
            print("🎯 RapSuggestionAPI: Model G topic selection - Selected \(selectedTopics.count) topics: \(selectedTopics.joined(separator: ", "))")
            
            if !selectedTopics.isEmpty {
                let topicDetails = selectedTopics.map { topic in
                    getTopicExamples(topic: topic)
                }.joined(separator: "\n\n")
                
                topicEmphasisSection = """
                
                🎯 ACTIVE TOPIC EMPHASIS (REQUIRED IN THIS GENERATION):
                Based on context analysis, you MUST actively incorporate these \(selectedTopics.count) topics into your 4-line generation:
                
                \(topicDetails)
                
                CRITICAL: At least 2-3 of these topics MUST appear naturally in your generated bars. Don't force them, but ensure they're present.
                """
                
                print("✅ RapSuggestionAPI: Topic emphasis section created with \(selectedTopics.count) topics")
            } else {
                topicEmphasisSection = ""
                print("⚠️ RapSuggestionAPI: No topics selected for emphasis")
            }
        } else {
            topicEmphasisSection = ""
            print("ℹ️ RapSuggestionAPI: Topic selection skipped (not Model G)")
        }
        
        // NEW STRICT PROMPT FOR MODEL G
        if isModelG {
            // Extract rhyme target
            let rhymeTargetStr = lastRhymeWord ?? rhymeFamily ?? (metrics.rhymeTarget ?? "none")
            
            // Extract allowed brands and luxury objects
            let brandTerms = allowedLexiconTerms.filter { $0.category == .luxuryList }
            let objectTerms = allowedLexiconTerms.filter { $0.category == .acquisition || $0.category == .wealthAccess }
            let allowedBrands = brandTerms.map { $0.term }.joined(separator: ", ")
            let allowedLuxuryObjects = objectTerms.map { $0.term }.joined(separator: ", ")
            
            let basePrompt = """
            Context Injection (from pipeline):
            
            rhymeTarget: \(rhymeTargetStr)
            authorityPosture: established
            audienceScope: public
            barsPerSuggestion: 4
            allowedBrands: \(allowedBrands.isEmpty ? "none provided" : allowedBrands)
            allowedLuxuryObjects: \(allowedLuxuryObjects.isEmpty ? "none provided" : allowedLuxuryObjects)
            generatorPolicy: constraints already resolved
            userProfileWeight: \(String(format: "%.2f", narrative.generatorPolicy.userProfileWeight)) (MINIMAL - ignore user's weak signals)
            \(groundTruthSection)
            \(topicEmphasisSection)
            
            ⚠️ CRITICAL: YOU ARE an ESTABLISHED, SOLD-OUT ARTIST CHARACTER.
            - COMPLETELY IGNORE any personal profile, locations, people, themes, or interests - these are irrelevant.
            - Generate bars that demonstrate professional excellence - show what a top-tier artist writes.
            - Do not adapt to anyone's level - write at the highest professional standard.
            - Write as the artist character, not for anyone.
            
            \(getRealTimeFeedbackSection())
            
            You must obey these constraints.
            
            Generation Instructions:
            1. Lock the rhyme using rhymeTarget: "\(rhymeTargetStr)"
               • rhyme (all 4 bars must end with words from the same rhyme family as "\(rhymeTargetStr)")
               • end-rhyme variants (use 2–4 different last words within the same rhyme family; do NOT repeat the same exact last word all 4 bars)
               • Lines 1-2: MUST rhyme with "\(rhymeTargetStr)" (perfect or slant rhyme)
               • Lines 3-4: CAN transition to new rhyme IF it improves luxury/descriptive specificity
            2. Generate 4 bars sharing:
               • cadence window (~120–140 BPM)
               • authority posture (established, public, assert)
            3. Luxury specificity (Gunna-style):
               • Across the full 4-bar block, include ONLY 1–2 total luxury/status signals
                 (brand OR high-value object OR specific location).
               • You CAN include more than one brand name, but PREFER pairing each brand with a description or specifier.
               • Examples: "louis v trunk", "versace bifocals", "cartier scarf", "patek bezel", "goyard duffle"
               • Use SPECIFIC amounts: "Two-hundred-fifty", "quarter", "hunnid racks" rather than vague terms
               • Use SPECIFIC details: "woodgrain", "baby blue", "VVS", "pinstripe", "high waters"
               • Use SPECIFIC locations: "Met Gala", "Coachella", "Barney", "LA", "Dubai"
               • Use SPECIFIC objects: "man purse", "honeycombs" (watch), "curtains" (car)
               • Prefer implied flex over brand lists.
            4. Gunna-Style Mechanics (learned from professional releases):
               • Multi-syllable rhymes: Prefer 2-syllable end rhymes when possible (e.g., "head first" / "found my worth")
               • Wordplay integration: Look for clever connections between rhyming words (e.g., "runny nose" / "running back")
               • Physical actions: Use concrete, physical verbs (jump, roam, take, ride, pop, cut) over abstract concepts
               • Drug references: Include drug references when contextually appropriate (ONLY use GROUND TRUTH examples from CSV):
                 - Lean (CSV examples): "Barely rest so I'm sippin' the 'Tuss", "I'm drinkin' the codeine whenever I swallow a Addy", "I'm geekin' on codeine", "Cup full of codeine, you can smell it when I pour", "I been sippin' syrup all day, just pourin'", "lean in my cup and my bladder", "Kush in my lungs, got lean in my belly to marinate the beans", "Sip a 4 of codeine, not a apple juice", "Poured up some potion, feel intoxicated", "Muddy poured up", "Sippin', drippin', tippin', trippin'", "All of my lean clean"
                 - Weed (CSV examples ONLY): "I blow Biscotti clouds of the bud", "I'm smokin' exotic", "Smokin' gelato", "Roll up Biscotti", "Backwood fill of Biscotti and I heard you smokin' pine", "Smokin' like a train, you can smell it in my pores", "Biscotti when I'm coughin'", "Biscotti Backwoods, stopped smokin' the grass", "Smokin' this 'Scotti, this shit startin' to hit like it's crack in it", "It's the real bluscotti when we smoke", "Smoke Biscotti and Gelato", "I'm smoke exotic Biscotti, 'member we had bags of the mid", "Got Biscotti, I'm smokin' this grade A", "Leave a three-five Biscotti in the roach", "Pass me that lighter, this ain't no Thrax, this some Bluscotti", "Rollin' up, gettin' high, ashes falling on my linen", "Exotic comin' in and out, we ain't gon' never see a drought", "Yak Gotti had the Biscotti so I pulled up with some Smarties"
                 - Percs (CSV examples): "I popped a pill and now my head gone", "Percocet", "Popped a few perkies", "I popped a capsule", "Pop a Percocet, help you feel better", "I pop me a pill, one got stuck in my throat", "I'm on these Percs, I can't feel shit at all", "Off Percs and X, can't nod off", "I pop a lil Perc' for breakfast"
                 - Addys (CSV examples): "I'm drinkin' the codeine whenever I swallow a Addy", "We geekin' up on the Addy", "I pop me a Addy", "Hard to stop poppin' these Addys", "Adderall pink"
                 - Effects (CSV examples): "my head gone", "I'm high", "I'm geeked", "I'm high, geeking", "you can smell it when I pour", "feel intoxicated"
               • Women as prizes: Frame women as status symbols and prizes (ONLY use GROUND TRUTH examples from CSV):
                 - "I put diamonds on a redbone" (diamonds as prize, redbone as object)
                 - "I got a old bitch", "I got bitches travel on the Amherst"
                 - "I bought my new bitch a Rollie" (bought = transactional, Rollie = prize)
                 - "Bought the bitch the Hermès crop, it got poison-ella" (bought = transactional, Hermès = prize)
                 - "Bought my bitch the Urus, let her skrrt to that drop" (bought = transactional, Urus = prize)
                 - "I just bought my young bitch a watch and now she wildin'" (bought = transactional, watch = prize)
                 - "I been knockin' these hoes down like domino", "My shows lit, it be more than a hundred hoes"
                 - "I got boomerang bitches, they comin' back"
                 - "One hundred my bitch, I'm real as it get" (possessive, status)
                 - "Got five bitches rollin' off the dope at the penthouse" (bitches + location + drugs = status)
                 - "My bitch a Dirty Diana", "My new bitch I got should've been in a pageant", "My new bitch fine as hell"
                 - "I got ten bad bitches", "had bitches countin' hundreds in the room"
                 - "Me and Wheezy wave, fuckin' bitches on the shore", "party with some bitches in the Philippines"
                 - Treat women as objects of desire and indicators of success/status
               • Strategic repetition: When repetition enhances flow, use it ("dirty-dirty", "hard work")
               • Before/after contrast: Subtle references to transformation/growth when contextually appropriate
               • Transactional language: Integrate business terms naturally (invoice, order, bookings, award)
               • Contractions: Use natural contractions ("I'ma", "gon'", "ain't") for authentic flow
               • Internal rhyme priority: At least 2 of 4 bars must have strong internal rhyme or assonance
            5. Language Arts Techniques (REQUIRED - Gunna-style):
               • Similes: Include 1-2 similes per 4-bar block (e.g., "like domino", "like a runny nose", "like Men in Black", "like honeycombs", "like the feds", "like pegs", "like grits")
               • Wordplay connections: Connect similes/metaphors across lines when possible (e.g., "runny nose" → "running back")
               • Hyperbole: Use numerical exaggeration ("hundred hoes", "hunnid racks", "more than a hundred hoes") and extreme states ("my head gone", "dead wrong", "since a toddler")
               • Idioms: Integrate common idioms naturally ("dead wrong", "money long", "come and go", "pop up", "knockin' down", "pullin' kick doors", "call it a lick")
               • Pop culture references: Reference movies, artists, athletes, or cultural touchstones in a smart way:
                 - Movies: "like the Men in Black"
                 - Artists: "like Nudy", "like Uzi"
                 - Athletes: "I shoot like I'm Montana" (Joe Montana), sports references when contextually appropriate
                 - Cultural: "ninety-nine problems" (Jay-Z reference with twist)
               • Metaphors: Use creative metaphors ("boomerang bitches", "lumberjack", "slimy", "knockin' these hoes down like domino", "Condo like the pharmacy", "cookin' crack like grits")
               • Euphemisms: Use euphemisms for sexual/drug/violence references when appropriate:
                 - Sexual: "suckin'", "fuck in Dubai", "pink toe", "strokin' her"
                 - Drugs: "put that dope", "codeine in my fridge", "cookin' crack", "sippin' lean", "poured up", "popped a perc", "rollin' up", "smokin'", "high", "faded", "geeked", "medicine", "prescription", "candy" (for pills)
                 - Violence: "let it hit", "stick" (gun), "nine and a snubnose" (specific gun types)
               • Alliteration: Use alliteration for flow (e.g., "knockin' these hoes down", "come and go", "comin' back", "pull up with a pink toe")
               • Assonance: Use internal vowel rhymes throughout for musicality
               • Repetition patterns: Use immediate repetition for emphasis when it enhances flow (e.g., "Pull up with a stick, I'll pull up with a stick")
               • Rhetorical questions: Use rhetorical questions for emphasis (e.g., "How you poor? That don't make sense")
               • Problem-solving narrative: Reference solving problems/overcoming obstacles (e.g., "I had ninety-nine problems, I just scratched your ho off the list", "Got some millions and went and solved 'em")
               • Descriptive language for women: Use SPECIFIC descriptors and transactional language (ONLY use GROUND TRUTH examples from CSV):
                 - **Treat women as PRIZES/STATUS SYMBOLS - CSV examples**:
                   - "I put diamonds on a redbone" (diamonds as prize, redbone as object)
                   - "I got a old bitch", "I got bitches travel on the Amherst"
                   - "I bought my new bitch a Rollie" (bought = transactional, Rollie = prize)
                   - "Bought the bitch the Hermès crop, it got poison-ella" (bought = transactional, Hermès = prize)
                   - "Bought my bitch the Urus, let her skrrt to that drop" (bought = transactional, Urus = prize)
                   - "I just bought my young bitch a watch and now she wildin'" (bought = transactional, watch = prize)
                   - "One hundred my bitch, I'm real as it get" (possessive, status)
                   - "My shows lit, it be more than a hundred hoes" (hoes as status symbols)
                   - "I got ten bad bitches", "I got boomerang bitches, they comin' back"
                 - Use "hoes" when describing women in transactional contexts - CSV examples:
                   - "I been knockin' these hoes down like domino"
                   - "My shows lit, it be more than a hundred hoes"
                   - "I'm cool on you dawg hoes", "Me and Wheezy, we met some hoes from Argentina and California"
                 - Use "redbone" for light-skinned women, "groupie" for specific types, "ex" for past relationships, "my girl" for current
                 - Use location descriptors: "Me and Wheezy, we met some hoes from Argentina and California"
                 - Use metaphors/idioms - CSV examples: "I got boomerang bitches, they comin' back" (they return), transactional language is common in trap genre
                 - **Women as status symbols - CSV examples**:
                   - "Got five bitches rollin' off the dope at the penthouse" (bitches + location + drugs = status)
                   - "My bitch a Dirty Diana", "My new bitch I got should've been in a pageant", "My new bitch fine as hell"
                   - "I got ten bad bitches", "had bitches countin' hundreds in the room"
                   - "Me and Wheezy wave, fuckin' bitches on the shore", "party with some bitches in the Philippines"
                 - Use "dead wrong" idiom when describing people's mistakes or being incorrect (e.g., "we was dead wrong", "you dead wrong")
               • Drug references (REQUIRED when contextually appropriate - ONLY use GROUND TRUTH examples from CSV):
                 - **Lean (codeine/promethazine) - CSV examples**: "Barely rest so I'm sippin' the 'Tuss", "I'm drinkin' the codeine whenever I swallow a Addy", "I'm geekin' on codeine", "Cup full of codeine, you can smell it when I pour", "I been sippin' syrup all day, just pourin'", "lean in my cup and my bladder", "Kush in my lungs, got lean in my belly to marinate the beans", "Sip a 4 of codeine, not a apple juice", "Poured up some potion, feel intoxicated", "Muddy poured up", "Sippin', drippin', tippin', trippin'", "All of my lean clean"
                 - **Weed (marijuana) - CSV examples ONLY**:
                   - Strains from CSV: "Biscotti", "Gelato", "exotic", "Bluscotti", "Do-Si-Do", "grade A"
                   - Actions from CSV: "I blow Biscotti clouds of the bud", "I'm smokin' exotic", "Smokin' gelato", "Roll up Biscotti", "Backwood fill of Biscotti and I heard you smokin' pine", "Smokin' like a train, you can smell it in my pores", "Biscotti when I'm coughin'", "Biscotti Backwoods, stopped smokin' the grass", "Smokin' this 'Scotti, this shit startin' to hit like it's crack in it", "It's the real bluscotti when we smoke", "Smoke Biscotti and Gelato", "I'm smoke exotic Biscotti, 'member we had bags of the mid", "Got Biscotti, I'm smokin' this grade A", "Leave a three-five Biscotti in the roach", "Pass me that lighter, this ain't no Thrax, this some Bluscotti", "Rollin' up, gettin' high, ashes falling on my linen", "Exotic comin' in and out, we ain't gon' never see a drought", "Yak Gotti had the Biscotti so I pulled up with some Smarties"
                 - **Percs (Percocet/painkillers) - CSV examples**: "I popped a pill and now my head gone", "Percocet", "Popped a few perkies", "I popped a capsule", "Pop a Percocet, help you feel better", "I pop me a pill, one got stuck in my throat", "I'm on these Percs, I can't feel shit at all", "Off Percs and X, can't nod off", "I pop a lil Perc' for breakfast"
                 - **Addys (Adderall) - CSV examples**: "I'm drinkin' the codeine whenever I swallow a Addy", "We geekin' up on the Addy", "I pop me a Addy", "Hard to stop poppin' these Addys", "Adderall pink"
                 - **General drug references - CSV examples**: "I smoke good narcotics", "Drugs in my body", "I'm high, geeking", "I'm geeked", "I'm high"
                 - Reference drug effects from CSV: "my head gone", "I'm high", "I'm geeked", "you can smell it when I pour", "feel intoxicated"
               • Money/Wealth References (ONLY use CSV examples): Reference specific amounts, cash, bands, racks, millions:
                 - "Cash runnin' over", "I had two hundred for lunch", "Throw the racks up"
                 - "Twenty-five thousand for a jacket, wear it once"
                 - "Got racks all inside the safe", "I spent sixty bands on one of my cases"
                 - "I got a hundred thousand in my pocket, lil' nigga, I got it out the swamp"
                 - "I been gettin' millions, I ain't trippin' 'bout awards"
                 - "Made a few millions, give a fuck about the Forbes"
                 - "My next check booking gon' be a hunnid racks"
                 - "Stack a lot of funds, diamonds on my thumb"
                 - "Two hundred in a month", "Two hundred a fist"
                 - "Can't see nothin' but the money like a blindfold"
                 - "You can hear the money in my voice"
               • Cars (ONLY use CSV examples): Reference specific luxury cars and actions:
                 - "911 Porsche and the trunk is a hood"
                 - "Ridin' the Rolls and the mink is a rug"
                 - "I bought me a Benz, it came with a shank"
                 - "We was in a Bentley B, flowin' up the street, playin' one of our songs"
                 - "I got a Urus, we the Lamborghini Boys"
                 - "Double park the Urus, I'll pull up, 'Ventador"
                 - "European car, it came with curtains"
                 - "Swear this Bentley used to be the MARTA"
                 - "Bought me two 'Vettes and two Maybachs, what's next?"
                 - "Been livin', I'ma paint the Bentley rose gold"
                 - "Top off the Benz, the one with no space"
                 - "Runnin' that coupe, yeah, the P a push-start"
                 - "Fast car cuttin' up in traffic, I'm one of those"
                 - "Bought my bitch the Urus, let her skrrt to that drop"
               • Watches & Jewelry (ONLY use CSV examples): Reference specific watches, diamonds, ice, chains:
                 - "AP on my wrist, ain't accepting apologies"
                 - "Might cop that Rollie for my oldest niece"
                 - "I bought my new bitch a Rollie"
                 - "diamonds on my thumb", "I put diamonds on a redbone"
                 - "My diamonds gon' dance, they come and enhance"
                 - "Different color diamonds on your wristwatch"
                 - "These VVS's make you blink"
                 - "Ice", "put some icin' on your wrist"
                 - "I went and got rich, my necklace glist'"
                 - "Middle finger ring cost a quarter"
                 - "Put some diamonds in my watch"
                 - "All my Elliot diamonds is water"
                 - "Feel like diamonds drippin' off my damn shirt"
                 - "It's just a diamond on a nigga tooth"
                 - "Upgrade my jewelry, my watch is up to par"
               • Hotels/Locations (ONLY use CSV examples): Reference specific locations, hotels, penthouses:
                 - "Got five bitches rollin' off the dope at the penthouse"
                 - "Wake up to a threesome in the penthouse on the Nawf"
                 - "Goin' shoppin' one stop 'fore I stop at the resort"
                 - "New crib got a lot of acres"
                 - "Penthouse feel like heaven when I wake from a ménage"
                 - "Why hell you think that I'm maxin'? Relaxin' in mansions"
                 - "To all promoters, get the presidential suite"
                 - "I got bitches travel on the Amherst"
                 - "Intercontinental with my bitch and a massage"
                 - "Crib come with a gym and a mini-golf course"
                 - "I bought my mama a crib, I'm outstanding"
               • Fashion Brands (ONLY use CSV examples): Reference specific luxury brands and items:
                 - "Got my check up like Nike, my boxers Versace, and now my whole engine in the trunk"
                 - "I ain't miss the Jordans for this pair of Diors"
                 - "Rick Owens denims, show my sneakers like they shorts"
                 - "Buy Celine and Chanel, girl, you got a C"
                 - "Bought the bitch the Hermès crop, it got poison-ella"
                 - "Louis V but my T-Shirt is tucked"
                 - "Louis bifocals"
                 - "I bought her Sheneneh heels, I'm a Chanel bandit"
                 - "Let her put on the Gucci slides, take off the heels"
                 - "Coupe like a creature, new shoes on the feet"
                 - "Tie my shoes, bitch, kneel at my feet"
               • Travel/Luxury Lifestyle (ONLY use CSV examples): Reference private jets, travel, international locations:
                 - "Hoppin' on the plane, I'm landin' in the mornin'"
                 - "Travel like a tourist, had to fly to Bora Bora"
                 - "The jet got speed, astrology"
                 - "Travel all across the globe"
                 - "I don't fly propeller, big jet twenty seater"
                 - "Countin' cash on a private plane"
                 - "Eight hour flight out to Spain"
                 - "When I fuck in Dubai, that pussy wet"
                 - "Pick a private plane for a lift, yeah"
                 - "I fucked the bitch on the jet"
                 - "Board the jet, I'm 'bout to change up the altitude"
                 - "The jet that I'm on, it's sponsored by Wraith"
                 - "Goin' to different cities, I book my suite, I'm tearin' up sheets"
                 - "Kill our enemies, party with some bitches in the Philippines"
               • Success/Dominance (ONLY use CSV examples): Reference being at the top, winning, dominance:
                 - "Perfectly aim for the top"
                 - "We keep winning 'cause we workin' harder"
                 - "I'm pushin' P, that's my favorite alphabet"
                 - "Fresh and I'm blessed, that's why I'm the drip god"
                 - "You can hear the money in my voice"
                 - "I'm chubby, but shit, my pockets in shape"
                 - "The world is a cage, the Planet of Apes"
                 - "My shit flowin', havin' plenty of bars"
                 - "She say my music art"
               • Food/Dining (ONLY use CSV examples): Reference expensive dining, food:
                 - "I had two hundred for lunch"
                 - "200 FOR LUNCH" (expensive dining reference)
               • Violence/Weapons (ONLY use CSV examples): Reference weapons and violent actions:
                 - "We cookin' with that chopper", "I drop a hit", "You get whacked with that TEC"
                 - "stick" (gun), "nine and a snubnose", "Dracos, AR's, Glocks, and carbons"
                 - "put in the work for your side", "Niggas send threats, but I get niggas stretched"
               • Family/Loyalty (ONLY use CSV examples): Reference family, loyalty, betrayal:
                 - "Mama ain't stressing, I'm still goin' hard", "Gotta keep the family straight"
                 - "I'm gon' free my cousin, I won't let him rot", "My brother's keeper"
                 - "I bought my mama a crib, I'm outstanding", "Bank robbing got my cuz fifteen years fed"
                 - "I try to save my niggas", "I never ratted"
               • Street Life/Hustling (ONLY use CSV examples): Reference trap life, hustling, street activities:
                 - "Neighborhood trap", "we trapped on the block", "In the hood sellin' trash"
                 - "I trapped for a living", "Got the trap jumpin' like crickets", "spin the block"
                 - "Got this shit out the ground and the mud", "Went and got rich out the ground and the mud"
               • Colors (ONLY use CSV examples): Reference specific colors with objects:
                 - "A lot of blue faces", "yellow", "gray and black", "rose gold"
                 - "white", "green", "Black on black new Phantom", "sippin' red"
                 - "Been livin', I'ma paint the Bentley rose gold"
               • Body Parts (ONLY use CSV examples): Reference body parts with jewelry/luxury items:
                 - "diamonds on my thumb", "I put diamonds on a redbone"
                 - "AP on my wrist", "diamonds on her toes", "It's just a diamond on a nigga tooth"
                 - "Middle finger ring cost a quarter", "One carat drip down my fang"
               • Time References (ONLY use CSV examples): Reference time of day, timing:
                 - "Hoppin' on the plane, I'm landin' in the mornin'"
                 - "Twenty-four shows in a month", "My next check booking gon' be a hunnid racks"
                 - "Really all the time, all the time"
               • Cities/Locations (ONLY use CSV examples): Reference specific cities and locations:
                 - "Atlanta where these hoes", "I got bitches travel on the Amherst"
                 - "Me and Wheezy, we met some hoes from Argentina and California"
                 - "When I fuck in Dubai, that pussy wet", "Travel like a tourist, had to fly to Bora Bora"
                 - "Eight hour flight out to Spain", "party with some bitches in the Philippines"
               • Numbers/Quantities (ONLY use CSV examples): Reference specific numbers and quantities:
                 - "I had two hundred for lunch", "Twenty-five thousand for a jacket"
                 - "I got a hundred thousand in my pocket", "I spent sixty bands on one of my cases"
                 - "I been gettin' millions", "Made a few millions", "Twenty-four shows in a month"
                 - "I got ten bad bitches", "more than a hundred hoes", "Got five bitches rollin' off the dope"
               • Drip/Freshness (ONLY use CSV examples): Reference being fresh, clean, drippin':
                 - "Fresh and I'm blessed, that's why I'm the drip god"
                 - "Fresh, first day of school", "Always been the freshest, I be cleaner than soap"
                 - "Fresh out the fridge", "I can fuck 'less she fresh out the bath"
                 - "We just got a fresh load, it's a lot in here", "fresh out the Chase"
               • Bags/Pockets (ONLY use CSV examples): Reference bags, pockets, wallets:
                 - "Pockets got nachos", "I'm chubby, but shit, my pockets in shape"
                 - "I got a hundred thousand in my pocket", "Pockets stuffed, lookin' swole"
                 - "Gotta get a duffel bag for the cash", "I'm around the world, securin' me a bag"
                 - "Mama thanked me for her purse", "Two-hundred-fifty in this man purse"
                 - "Diamond chain, wallets", "Jolly wallet", "Pocket bone crusher"
               • Chains/Jewelry (ONLY use CSV examples): Reference chains, necklaces, jewelry:
                 - "I went and got rich, my necklace glist'", "Get a check and go and get your chain bust"
                 - "This chain cost a quarter milli'", "and watches and chains"
                 - "ROCKSTAR BIKERS & CHAINS", "Eliantte chain like the bottom of a ship"
                 - "shit deeper than a chain"
               • Pull/Push Actions (ONLY use CSV examples): Reference pulling up, pushing:
                 - "I'm pushin' P, that's my favorite alphabet", "Runnin' that coupe, yeah, the P a push-start"
                 - "Need cash in my bank or pull up in a Brinks", "Pull up in a Porsche"
                 - "Double park the Urus, I'll pull up, 'Ventador", "Pull up to the Maybach in the driveway"
                 - "When I pull up Mulsanne", "Pull up, spin the whole block"
                 - "Told her pull up and sent her the addy", "We pull up, bullets rainin' like rain"
               • Flex/Show (ONLY use CSV examples): Reference flexing, showing off:
                 - "She love when I flex and shop in the mall"
                 - "I show you around like I Spy", "I'm showin' no remorse"
                 - "Show's around one-fifty, but they paid a lil' more"
                 - "Show real love", "My shows lit, it be more than a hundred hoes"
                 - "Sold out shows, this shit litty", "I got shows and they litty"
                 - "A young dripper, rulin' the fashion show"
               • Real/Fake (ONLY use CSV examples): Reference being real, authentic:
                 - "No realer than this", "One hundred my bitch, I'm real as it get"
                 - "We really came from the A", "I really like it", "we just really been coastin'"
                 - "When you really gettin' millions", "Get some real rocks"
                 - "Show real love", "Wunna a real one and I ain't changed up"
                 - "Keep it real, I just had to realize", "I get Slime by myself, I'm a real loner"
                 - "This the boss of the buildin', the real owner"
               • Ball/Sport (ONLY use CSV examples): Reference basketball, sports, ballin':
                 - "Ballin' like a big shot", "Ballin' hard, break the rules"
                 - "I came to ball, Steve Nash", "I been ballin' in LA, feel like a Laker"
                 - "I just left a Hawks game, me and bae floorin'"
                 - "Walk in with the drip like Met Gala Ball", "ballin'"
               • Work/Grind (ONLY use CSV examples): Reference working, grinding, hustling:
                 - "Shit don't come easy, nigga, it's hard work"
                 - "We keep winning 'cause we workin' harder", "Work hard"
                 - "Pray to God that'll work in your favor"
                 - "I done made up my mind and done got on my grind"
                 - "All I know is grind", "I got on my grind, ain't no more stressing"
                 - "No I work my muscle all day, I'm carrying cash"
                 - "Blood, sweat, and tears, I'm workin' my hardest"
                 - "I've been grindin' and found me a buzz"
                 - "Workin' hard, we ain't havin' no hope"
               • Rich/Poor (ONLY use CSV examples): Reference wealth status, being rich or broke:
                 - "I went and got rich, my necklace glist'", "Went and got rich out the ground and the mud"
                 - "I was fucked up broke, had to reinstate", "I was hood rich, now I passed 'em on Forbes"
                 - "This a rich nigga", "We locked in together forever, that's if I'm poor or rich"
                 - "Only got one life, you can get rich twice"
                 - "Count a lot of G's, we ain't poor no more"
                 - "if you broke"
               • Game/Play (ONLY use CSV examples): Reference games, playing, competition:
                 - "Feel like a player", "These niggas play games like arcade"
                 - "You playin', you gon' be another cold case"
                 - "I swear I don't play that", "We was in a Bentley B, flowin' up the street, playin' one of our songs"
                 - "I just left a Hawks game", "We ain't come to play, is you with it, are you sure?"
                 - "Yeah, nigga tried to play me like a toy, damn"
                 - "we love to play"
               • Clean/Fresh (ONLY use CSV examples): Reference being clean, fresh, cleanliness:
                 - "Always been the freshest, I be cleaner than soap"
                 - "I clean up like hands and soap", "Clean with no mop"
                 - "I can fuck 'less she fresh out the bath"
                 - "Wash up with Clorox", "fresh out the fridge"
                 - "tryna clean a stain", "I clean up like a washer"
                 - "Ice all on my watch, add it to the card, had to get the cars washed"
                 - "They cleanin' and moppin'", "Bought a street sweeper to clean up the street"
                 - "All of my lean clean", "Hunnids, I got fo-fo out the bank, crystal clean"
                 - "know a nigga cleaner"
               • Location + Hotel specificity: Reference specific hotels/locations when flexing (e.g., "stayin' at the Loews", "LA live", "Hollywood")
               • Brand on body part/clothing: Place brands on specific body parts or clothing items (e.g., "Prada on my collar", "diamonds on her toes")
               • Color + object specificity: Use color descriptions with objects (e.g., "Black on black new Phantom", "sippin' red")
               • Food comparison similes: Use cooking/food similes for illegal activities (e.g., "cookin' crack like grits", "on a steamin' stove")
               • Pharmaceutical comparisons: Compare living spaces to pharmacies/drug stores (e.g., "Condo like the pharmacy")
            6. If a bar fails any rule → regenerate internally
            6. Output only the bars and structured metadata (no explanations)
            
            Recent lines (for context):
            \(last4To6Lines.joined(separator: "\n"))
            """
            
            let jsonFormatSection = """

            REQUIRED OUTPUT SCHEMA (STRICT):

            {
              "suggestions": [
                {
                  "suggestionType": "rap_bar_block",
                  "artistBias": "gunna",
                  "rhymeTarget": "\(rhymeTargetStr)",
                  "bars": [
                    { "text": "<bar 1>", "luxurySignals": [], "rhymeWord": "<bar_last_word>" },
                    { "text": "<bar 2>", "luxurySignals": [], "rhymeWord": "<bar_last_word>" },
                    { "text": "<bar 3>", "luxurySignals": [], "rhymeWord": "<bar_last_word>" },
                    { "text": "<bar 4>", "luxurySignals": [], "rhymeWord": "<bar_last_word>" }
                  ],
                  "authorityCheck": {
                    "posture": "established",
                    "tone": "indifferent",
                    "explanationDetected": false
                  }
                }
              ]
            }

            HARD OUTPUT RULES:
            - You MUST return exactly 5 objects in the suggestions array.
            - Each suggestion must contain exactly 4 bars.
            - Do not include any extra keys.

            ❌ WHAT YOU ARE NOT ALLOWED TO DO:
            • Output fewer or more than 4 bars per suggestion
            • Output fewer or more than 5 suggestions
            • Produce generic luxury words without specificity
            • Explain status, confidence, or success
            • Output critique or commentary in the generation step

            Return ONLY valid JSON object, no markdown, no code blocks.
            """
            
            return basePrompt + "\n\n" + jsonFormatSection
        }
        
        // Base prompt structure (shared between models) - for Model Y
        // SIGNAL LAYER-DRIVEN: Constraints are primary, narrative is context
        let basePrompt = """
        You are a rap lyric suggestion engine operating under SIGNAL LAYER constraints. Your job is to generate the next 4 lines for a rap verse that form a cohesive, narratively progressive mini-story while STRICTLY adhering to SIGNAL LAYER constraints (provided in system message).
        
        CRITICAL: SIGNAL LAYER constraints override all other instructions. Generate lines that satisfy signal constraints FIRST, then ensure narrative coherence.
        \(templateGuidance)
        \(rhymeConstraint)
        \(lexiconInjection)
        \(authorityOverride)
        
        FULL VERSE CONTEXT (for narrative continuity):
        \(metrics.fullText)
        
        IMMEDIATE CONTEXT (last 4-6 lines for flow):
        \(last4To6Lines.joined(separator: "\n"))
        
        \(isModelG ? """
        ⚠️ USER PROFILE IGNORED (Model G):
        The user's personal profile (locations, people, themes, interests) represents weak signals from a beginner.
        Generate as an ESTABLISHED ARTIST CHARACTER, not based on the user's profile.
        Your job is to TEACH excellence by showing what professional-level bars sound like.
        """ : (userContextStr.isEmpty ? "" : "USER CONTEXT (personalize suggestions with these references): \(userContextStr)"))
        \(!isModelG && !userBackgroundStr.isEmpty ? "\n\(userBackgroundStr)" : "")
        
        \(buildStreetLedgerBlock(narrative: narrative))
        
        \(narrative.generatorPolicy.signalProfileExposure == .none ? "NARRATIVE ANALYSIS (structural context only - mood/theme drivers disabled for SuperGunna mode):" : "NARRATIVE ANALYSIS (use as context, not as search terms):")
        - Primary Themes: \(narrative.primaryThemes.joined(separator: ", "))
        - Secondary Themes: \(narrative.secondaryThemes.joined(separator: ", "))
        
        EMOTIONAL SPINE (every bar must reinforce - no message betrayal):
        \(intent.promptFragment)
        \(narrative.underlyingThemes?.isEmpty == false ? "- Underlying Themes (maintain these beneath surface): \(narrative.underlyingThemes!.joined(separator: ", "))" : "")
        - Detected Tones: \(narrative.detectedTones.map(\.rawValue).joined(separator: ", "))
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
        \(metrics.bpm != nil ? "- BPM (Tempo): \(metrics.bpm!) - Match the rhythm and pacing to this tempo" : "")
        \(metrics.key != nil ? "- Musical Key: \(metrics.key!) - Consider the tonal quality and mood of this key" : "")
        \(metrics.scale != nil ? "- Scale: \(metrics.scale!) - Align the lyrical flow with the scale's characteristics" : "")
        
        \(buildRegisterGuidance(registers: registers))
        
        \(buildLexiconGuidance(allowedLexiconTerms: allowedLexiconTerms))
        
        OPTIONAL CANDIDATE LINES (may use as inspiration, but SIGNAL LAYER constraints take priority):
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
            candidatesText: candidatesText,
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
        
        SILENCE THRESHOLD: \(String(format: "%.1f", settings.silenceThreshold))
        - If ALL suggestions would have confidence below \(String(format: "%.1f", settings.silenceThreshold)), return silence instead:
        {
          "silence": {
            "explanation": "Why no line was generated",
            "reason": "Specific reason (alignment threshold, register violation, etc.)",
            "guidance": "What the user should consider"
          }
        }
        - Silence is a valid and preferred outcome when confidence is low. Do not generate weak suggestions just to fill the response.
        - \(settings.refusalFrequency == .frequent ? "Frequent refusal is acceptable: prefer silence when uncertain." : settings.refusalFrequency == .moderate ? "Moderate refusal: refuse when clearly misaligned." : "Rare refusal: generate even when uncertain, but still respect silence threshold.")
        
        IMPORTANT: 
        - Each "text" field must contain exactly 4 lines separated by newline characters (\\n).
        - Each suggestion must form a cohesive mini-story that progresses narratively.
        - Confidence must accurately reflect how well ALL constraints are met.
        - If confidence falls below silence threshold, return silence instead of a suggestion.
        
        Return ONLY valid JSON object, no markdown, no code blocks.
        """
        
        return basePrompt + "\n\n" + rulesSection + "\n\n" + confidenceSection + jsonFormatSection
    }
    
    /// Builds StreetLedger policy block for SuperGunna mode
    private func buildStreetLedgerBlock(narrative: NarrativeAnalysis) -> String {
        let policy = narrative.generatorPolicy
        
        // Only show StreetLedger if signalProfileExposure is .none (SuperGunna mode)
        guard policy.signalProfileExposure == .none else {
            return ""
        }
        
        // Infer AuthorityVector from artist bias or use default
        let authorityVector: String
        if policy.artistBias == .gunna {
            authorityVector = "control_hierarchy/capital_flow"
        } else {
            authorityVector = "neutral"
        }
        
        let templateBiasStr = policy.templateBias.map { $0.rawValue }.joined(separator: ", ")
        let forbiddenVerbsStr = policy.forbiddenVerbs.joined(separator: ", ")
        let motifPoolStr = policy.motifPool.joined(separator: ", ")
        
        return """
        
        === STREETLEDGER POLICY (MODEL G) ===
        AuthorityVector: \(authorityVector)
        IndifferencePressure: \(String(format: "%.2f", policy.indifferencePressure))
        TemplateBias: \(templateBiasStr.isEmpty ? "none" : templateBiasStr)
        AllowedVerbClasses: Transaction, Motion, Reflection (all three allowed - reflection verbs are authentic Gunna)
        ForbiddenVerbs: \(forbiddenVerbsStr.isEmpty ? "none" : forbiddenVerbsStr) (Note: "feel", "think", "realize" are ALLOWED - they're authentic Gunna vocabulary)
        MaxClauseSyllables: \(policy.maxClauseSyllables) (preferred: 8-12, but 13-14 acceptable if flow requires)
        BrandPerBarMax: \(policy.brandPerBarMax)
        PriceAnchorEveryNBars: \(policy.priceAnchorEveryNBars)
        RepeatMotifEveryNBars: \(policy.repeatMotifEveryNBars)
        MotifPool: \(motifPoolStr.isEmpty ? "none" : motifPoolStr)
        
        CRITICAL: This policy overrides all journal-derived signals. Generate using templates, use reflection verbs naturally (they're authentic Gunna), enforce brand limits, anchor prices.
        """
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
        candidatesText: String,
        feedbackImprovements: ModelImprovements? = nil
    ) -> String {
        switch model {
        case .modelG, .modelGv3:
            return buildModelGRules(
                metrics: metrics,
                topicModesInfo: topicModesInfo,
                voiceTypeStr: voiceTypeStr,
                contradictionsStr: contradictionsStr,
                momentumStr: momentumStr,
                contextualPlacementStr: contextualPlacementStr,
                styleInfo: styleInfo,
                settings: settings,
                candidatesText: candidatesText,
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
                candidatesText: candidatesText,
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
        candidatesText: String,
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
        
        E. REGISTER CONSTRAINTS (\(settings.registerStrictness == .strict ? "HIGHEST" : settings.registerStrictness == .moderate ? "HIGH" : "MEDIUM") PRIORITY):
        1. Register consistency: \(settings.registerStrictness == .strict ? "STRICTLY maintain linguistic register consistently throughout." : settings.registerStrictness == .moderate ? "Maintain register but allow shifts when narratively strong." : "Register follows narrative needs.")
        2. Register enforcement weight: \(String(format: "%.0f", settings.registerWeight * 100))% - This controls how strongly register constraints are enforced
        
        F. MUSICAL CONSTRAINTS (HIGH PRIORITY):
        1. Syllable count: Each line within ±1 of target (\(metrics.syllableTarget ?? 0)) - CRITICAL for flow
        2. Rhyme matching: Match the rhyme target if provided (\(metrics.rhymeTarget ?? "none")) - Use rhyme words that fit naturally. \(settings.rhymeComplexity == .complex ? "Use complex, multi-syllable rhymes when possible." : settings.rhymeComplexity == .simple ? "Keep rhymes simple and straightforward." : "")
        3. Rhyme scheme: Maintain the detected rhyme scheme (\(metrics.rhymeScheme ?? "unknown")) - Preserve pattern consistency
        4. Rhythm consistency: Lines should have similar rhythm/pace as user's lines - Match the cadence and flow feel
        5. Flow patterns: Maintain consistent syllable variance (current: \(String(format: "%.1f", metrics.syllableVariance))) - Match density/sparsity pattern. \(settings.flowDensity == .dense ? "Prefer dense, packed flow." : settings.flowDensity == .sparse ? "Prefer sparse flow with breathing room." : "")
        6. Beat alignment: Consider how lines would flow over a beat, maintain groove/feel consistency - Think about musicality. \(settings.beatSyncPreference == .tight ? "Maintain tight beat synchronization." : settings.beatSyncPreference == .loose ? "Allow flexible timing." : "")
        7. Avoid jarring rhythm shifts within the 4-line suggestion - Smooth transitions between lines
        8. Syllable stress patterns: Match stress patterns of user's lines when possible - Maintain rhythmic feel
        9. Flow style matching: Match flow style (dense vs sparse, fast vs slow) from user's verse
        10. Syllable variance tolerance: \(settings.syllableVarianceTolerance == .strict ? "STRICTLY maintain syllable consistency." : settings.syllableVarianceTolerance == .flexible ? "Allow creative freedom with syllable counts." : "Maintain moderate consistency.")
        
        G. TOPIC TREATMENT MODE MATCHING (HIGH PRIORITY):
        \(topicModesInfo.isEmpty ? "1. Match how topics are treated in the user's verse naturally" : "1. STRICTLY match the detected topic treatment modes: \(topicModesInfo)")
        2. If women are treated aesthetically (lifestyle/visual), maintain that - don't shift to relational unless narratively strong and appropriate
        3. If women are treated relationally (emotional connection), maintain that depth
        4. Match wealth treatment mode (flexing vs burden vs ironic)
        5. Match success treatment mode (celebration vs obligation vs isolation)
        6. Allow mode shifts ONLY if narratively appropriate and the shift strengthens the narrative
        7. Flag violations in confidence scoring
        
        H. VOICE TYPE MATCHING (HIGH PRIORITY - STRICT):
        \(voiceTypeStr.isEmpty ? "1. Match the user's voice type naturally" : "1. STRICTLY match voice type: \(voiceTypeStr)")
        2. If voice is defensive (guarded, justifying), maintain that - do NOT shift to vulnerable
        3. If voice is vulnerable (introspective, open), maintain that - do NOT shift to defensive
        4. Match the level of guard/openness consistently
        5. Do not shift from defensive to vulnerable (or vice versa) unless explicitly transitioning in a narratively strong way
        6. Voice consistency is critical - violations significantly reduce confidence
        
        I. CONTRADICTION/IRONY PRESERVATION (MEDIUM PRIORITY):
        \(contradictionsStr.isEmpty ? "1. Detect and preserve contradictions when they exist naturally" : "1. Preserve detected contradictions/ironies: \(contradictionsStr)")
        2. If contradictions exist (e.g., success feels like obligation), maintain that tension - don't resolve it unless narratively appropriate
        3. Allow smooth transitions when narratively appropriate - contradictions don't need to be forced
        4. Don't force contradictions if they don't exist in the verse
        5. Contradictions add depth - preserve them when present
        
        J. NARRATIVE MOMENTUM (MEDIUM PRIORITY):
        \(momentumStr.isEmpty ? "1. Detect current momentum and maintain or allow shifts when narratively strong" : "1. Current momentum: \(momentumStr)")
        2. If momentum is "building-tension", maintain or escalate tension across the 4 lines
        3. If momentum is "escapist-relief", maintain that lighter energy or provide relief from heavier themes
        4. If momentum is "maintaining", keep the current energy level consistent
        5. If momentum is "transitioning", allow the transition to complete naturally
        6. Allow momentum shifts ONLY if narratively strong and appropriate
        7. Consider contextual placement when determining momentum
        
        K. CONTEXTUAL PLACEMENT AWARENESS (MEDIUM PRIORITY):
        \(contextualPlacementStr.isEmpty ? "1. Consider where the verse sits in a larger narrative when suggesting next lines" : "1. Contextual placement: \(contextualPlacementStr)")
        2. If "opening": Suggestions should introduce/develop themes, set up narrative
        3. If "mid-album": Suggestions should develop narrative, maintain momentum, deepen themes
        4. If "reflection": Suggestions should be introspective, explore emotions, provide insight
        5. If "climax": Suggestions should maintain intensity, add resolution elements, peak energy
        6. If "outro": Suggestions should provide resolution, conclude themes, wrap up narrative
        7. Use contextual placement to inform narrative function and momentum
        
        L. STYLE/VOICE MATCHING (HIGH PRIORITY):
        \(styleInfo.isEmpty ? "1. Match the user's writing style and voice naturally" : "1. Match the user's style characteristics: \(styleInfo)")
        2. Maintain vocabulary complexity level
        3. Match sentence structure patterns (short punchy vs longer flowing)
        4. Match figurative language usage
        5. Match energy and formality level
        6. Match punctuation style
        
        M. MODEL G SPECIFIC GUIDANCE:
        1. Assume shared understanding - do not explain cultural references. High cultural specificity means the audience knows.
        2. Prefer implication over explanation - show aftermath, not events. Heavy implication is preferred.
        3. High silence threshold (\(String(format: "%.1f", settings.silenceThreshold))) - refuse to generate when uncertain. Silence is better than weak suggestions.
        4. Maintain guarded exposure - minimal sharing. Protect privacy and authority.
        5. High authority - statements should feel final and earned. No tentative language.
        6. High compression - silence where appropriate. Do not fill every gap.
        7. No posture shifts - maintain consistent voice posture throughout.
        8. High restraint - minimal, essential only. Less is more.
        
        N. CONTENT RULES (CRITICAL - 4-LINE BLOCK GENERATION):
        1. \(candidatesText.isEmpty ? "Generate original lines from scratch based on SIGNAL LAYER constraints and narrative context. Do not adapt from existing lyrics." : "You may use candidates as inspiration, but SIGNAL LAYER constraints are PRIMARY. Generate lines that satisfy constraints first, then consider candidates if helpful.")
        2. ⚠️ MANDATORY: Each suggestion must be EXACTLY 4 lines (separated by newlines). NO single-line suggestions. NO exceptions.
        3. ⚠️ MANDATORY: All 4 lines must share the same rhyme target (end-word rhyme family). Extract the rhyme from the user's last line and continue it across all 4 lines.
        4. ⚠️ MANDATORY: Each of the 4 lines must include at least ONE lexicon term (brand, high-value object, or wealth location). Use lexicon terms naturally - don't force them, but ensure they appear.
        5. \(candidatesText.isEmpty ? "Generate fresh, original content that operates within SIGNAL constraints. Do not copy or closely adapt existing lyrics." : "Prefer constraint-satisfying original lines over adapting candidates. Only adapt if it strengthens the signal.")
        6. Keep the flow natural and authentic
        7. Lifestyle accumulation: Each line should build on the previous, accumulating wealth/luxury signals across the 4-line block
        8. Authority escalation: The 4-line block should demonstrate increasing authority/status from line 1 to line 4
        5. \(settings.riskTolerance == .high ? "Higher risk tolerance: experimental, bold choices are acceptable." : settings.riskTolerance == .low ? "Low risk tolerance: conservative, safe choices only." : "Moderate risk tolerance: calculated risks.")
        6. \(settings.symbolismLevel == .high ? "High symbolism: fluid, abstract language preferred." : settings.symbolismLevel == .low ? "Low symbolism: concrete, literal language." : "Moderate symbolism: mix of concrete and abstract.")
        7. \(!settings.topicRestrictions.isEmpty ? "AVOID these topics: \(settings.topicRestrictions)" : "")
        8. \(settings.languageRestrictions == .strict ? "Avoid explicit content and strong language." : settings.languageRestrictions == .none ? "No language restrictions." : "Use moderate language.")
        9. \(settings.referenceStyle == .personal ? "Use personal, concrete references when possible." : settings.referenceStyle == .abstract ? "Use abstract, metaphorical references." : "Balance personal and abstract references.")
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
        candidatesText: String,
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
        
        I. MODEL Y SPECIFIC GUIDANCE:
        1. Higher risk tolerance - allow experimental language and bold choices.
        2. Symbolic/fluid language preferred - high symbolism means abstract, flowing language.
        3. Allow posture shifts when narratively strong - flexible posture shift tolerance.
        4. Moderate silence threshold (\(String(format: "%.1f", settings.silenceThreshold))) - generate more frequently, but still refuse when clearly misaligned.
        5. Flexible register - register follows narrative needs, not strict consistency.
        6. High dominance - assertive, commanding voice preferred.
        
        J. CONTENT RULES:
        1. \(candidatesText.isEmpty ? "Generate original lines from scratch based on SIGNAL LAYER constraints. Prioritize signal clarity and musicality." : "You may use candidates as inspiration, but SIGNAL LAYER constraints are PRIMARY. Generate constraint-satisfying lines first.")
        2. Each suggestion must be EXACTLY 4 lines (separated by newlines)
        3. \(candidatesText.isEmpty ? "Generate fresh, original content that operates within SIGNAL constraints." : "Prefer constraint-satisfying original lines over adapting candidates.")
        4. Prioritize flow and musicality above all else, but SIGNAL constraints are non-negotiable
        5. \(settings.riskTolerance == .high ? "Higher risk tolerance: experimental, bold choices are acceptable." : settings.riskTolerance == .low ? "Low risk tolerance: conservative, safe choices only." : "Moderate risk tolerance: calculated risks.")
        6. \(settings.symbolismLevel == .high ? "High symbolism: fluid, abstract language preferred." : settings.symbolismLevel == .low ? "Low symbolism: concrete, literal language." : "Moderate symbolism: mix of concrete and abstract.")
        7. \(!settings.topicRestrictions.isEmpty ? "AVOID these topics: \(settings.topicRestrictions)" : "")
        8. \(settings.languageRestrictions == .strict ? "Avoid explicit content and strong language." : settings.languageRestrictions == .none ? "No language restrictions." : "Use moderate language.")
        9. \(settings.referenceStyle == .personal ? "Use personal, concrete references when possible." : settings.referenceStyle == .abstract ? "Use abstract, metaphorical references." : "Balance personal and abstract references.")
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
        case .modelG, .modelGv3:
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
    
    private func performAPIRequest(requestBody: [String: Any], narrative: NarrativeAnalysis, metrics: RapMetrics, rejectedLines: inout [(line: String, reason: GenerationDiagnostics.RejectionReason)], expectPlainTextLines: Bool = false) async throws -> [RapSuggestion] {
        guard apiKey != nil else {
            throw RapAPIError.missingAPIKey
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Set longer timeout for Model G requests (60 seconds)
        // Model G requests can be complex with multiple constraints and templates
        request.timeoutInterval = 60.0
        
        // Track network performance
        let requestStartTime = CFAbsoluteTimeGetCurrent()
        let requestSize = request.httpBody?.count ?? 0
        let requestHeaders = Dictionary(uniqueKeysWithValues: request.allHTTPHeaderFields?.map { ($0.key, $0.value) } ?? [])
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError {
            let requestDuration = CFAbsoluteTimeGetCurrent() - requestStartTime
            
            // Handle timeout specifically
            if urlError.code == .timedOut {
                let errorMessage = "API request timed out after \(String(format: "%.2f", requestDuration)) seconds"
                print("⚠️ RapSuggestionAPI: \(errorMessage)")
                print("   Request size: \(requestSize) bytes")
                print("   URL: \(url.absoluteString)")
                
                ErrorStorageManager.shared.storeError(
                    errorMessage,
                    source: "AI Sparkle Button",
                    context: "Request timed out. Duration: \(String(format: "%.2f", requestDuration))s, Size: \(requestSize) bytes"
                )
                
                // Track failed request
                NetworkPerformanceMonitor.shared.trackRequest(
                    url: url.absoluteString,
                    method: "POST",
                    requestSize: requestSize,
                    responseSize: 0,
                    statusCode: nil,
                    duration: requestDuration,
                    success: false,
                    errorMessage: errorMessage,
                    requestHeaders: requestHeaders
                )
                
                throw RapAPIError.requestFailed
            } else {
                // Handle other URL errors
                let errorMessage = "Network error: \(urlError.localizedDescription)"
                print("⚠️ RapSuggestionAPI: \(errorMessage)")
                print("   Error code: \(urlError.code.rawValue)")
                
                ErrorStorageManager.shared.storeError(
                    errorMessage,
                    source: "AI Sparkle Button",
                    context: "URLError code: \(urlError.code.rawValue), Description: \(urlError.localizedDescription)"
                )
                
                NetworkPerformanceMonitor.shared.trackRequest(
                    url: url.absoluteString,
                    method: "POST",
                    requestSize: requestSize,
                    responseSize: 0,
                    statusCode: nil,
                    duration: requestDuration,
                    success: false,
                    errorMessage: errorMessage,
                    requestHeaders: requestHeaders
                )
                
                throw RapAPIError.requestFailed
            }
        } catch {
            // Handle any other errors
            let requestDuration = CFAbsoluteTimeGetCurrent() - requestStartTime
            let errorMessage = "API request failed: \(error.localizedDescription)"
            print("⚠️ RapSuggestionAPI: \(errorMessage)")
            
            ErrorStorageManager.shared.storeError(
                errorMessage,
                source: "AI Sparkle Button",
                context: "Request failed. Error: \(error.localizedDescription)"
            )
            
            NetworkPerformanceMonitor.shared.trackRequest(
                url: url.absoluteString,
                method: "POST",
                requestSize: requestSize,
                responseSize: 0,
                statusCode: nil,
                duration: requestDuration,
                success: false,
                errorMessage: errorMessage,
                requestHeaders: requestHeaders
            )
            
            throw RapAPIError.requestFailed
        }
        
        let requestDuration = CFAbsoluteTimeGetCurrent() - requestStartTime
        let responseSize = data.count
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let errorMessage = "Invalid HTTP response"
            print("⚠️ RapSuggestionAPI: \(errorMessage)")
            ErrorStorageManager.shared.storeError(
                errorMessage,
                source: "AI Sparkle Button",
                context: "Invalid HTTP response"
            )
            
            // Track failed request
            NetworkPerformanceMonitor.shared.trackRequest(
                url: url.absoluteString,
                method: "POST",
                requestSize: requestSize,
                responseSize: 0,
                statusCode: nil,
                duration: requestDuration,
                success: false,
                errorMessage: errorMessage,
                requestHeaders: requestHeaders
            )
            
            throw RapAPIError.requestFailed
        }
        
        let responseHeaders = Dictionary<String, String>(uniqueKeysWithValues: httpResponse.allHeaderFields.compactMap { key, value -> (String, String)? in
            guard let keyString = key as? String, let valueString = value as? String else { return nil }
            return (keyString, valueString)
        })
        
        guard httpResponse.statusCode == 200 else {
            let statusCode = httpResponse.statusCode
            let errorMessage = "API request failed with status code: \(statusCode)"
            print("⚠️ RapSuggestionAPI: \(errorMessage)")
            ErrorStorageManager.shared.storeError(
                errorMessage,
                source: "AI Sparkle Button",
                context: "HTTP status code: \(statusCode)"
            )
            
            // Track failed request
            NetworkPerformanceMonitor.shared.trackRequest(
                url: url.absoluteString,
                method: "POST",
                requestSize: requestSize,
                responseSize: responseSize,
                statusCode: statusCode,
                duration: requestDuration,
                success: false,
                errorMessage: errorMessage,
                requestHeaders: requestHeaders,
                responseHeaders: responseHeaders
            )
            
            if statusCode == 429 {
                let retryAfter = responseHeaders["Retry-After"].flatMap { Int($0) }
                throw RapAPIError.rateLimitExceeded(retryAfterSeconds: retryAfter)
            }
            throw RapAPIError.requestFailed
        }
        
        // Track successful request
        NetworkPerformanceMonitor.shared.trackRequest(
            url: url.absoluteString,
            method: "POST",
            requestSize: requestSize,
            responseSize: responseSize,
            statusCode: httpResponse.statusCode,
            duration: requestDuration,
            success: true,
            requestHeaders: requestHeaders,
            responseHeaders: responseHeaders
        )
        
        // Validate JSON before parsing (non-blocking - just for logging)
        let validationResult = JSONValidationService.shared.validateSuggestionsResponse(data)
        if !validationResult.isValid {
            print("⚠️ JSON Validation Failed for Suggestions (non-blocking):")
            for error in validationResult.errors {
                print("   - \(error.message)")
            }
            // Log warnings but don't block - we'll use fallbacks
            for warning in validationResult.warnings {
                print("   ⚠️ \(warning.message)")
            }
        }
        // Continue parsing even if validation fails - we'll use fallback values
        
        let jsonResponse: OpenAIResponse
        var parsingErrors: [String] = []
        var inputTokens: Int? = nil
        var outputTokens: Int? = nil
        var totalTokens: Int? = nil
        
        do {
            jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            // Extract token usage if available
            if let usage = jsonResponse.usage {
                inputTokens = usage.promptTokens
                outputTokens = usage.completionTokens
                totalTokens = usage.totalTokens
                
                // Track token usage
                if let input = usage.promptTokens, let output = usage.completionTokens {
                    TokenUsageTracker.shared.trackUsage(
                        model: (requestBody["model"] as? String) ?? "unknown",
                        endpoint: "suggestions",
                        inputTokens: input,
                        outputTokens: output,
                        feature: "suggestions"
                    )
                }
            }
        } catch {
            // If we can't decode the response structure, log it and provide better error
            let errorMessage = "Failed to decode API response structure: \(error.localizedDescription)"
            parsingErrors.append(errorMessage)
            print("⚠️ RapSuggestionAPI: \(errorMessage)")
            print("Response data preview: \(String(data: data.prefix(500), encoding: .utf8) ?? "Unable to decode")")
            
            ErrorStorageManager.shared.storeError(
                errorMessage,
                source: "AI Sparkle Button",
                context: "API response structure was invalid. Response length: \(data.count) bytes"
            )
            
            // Log response with parsing error
            APIDebugInspector.shared.logResponse(
                statusCode: httpResponse.statusCode,
                responseBody: data,
                responseHeaders: responseHeaders,
                duration: requestDuration,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                totalTokens: totalTokens,
                parsingSuccess: false,
                parsingErrors: parsingErrors,
                validationResult: validationResult
            )
            
            throw RapAPIError.jsonParsingFailed("API response structure was invalid")
        }
        
        guard let content = jsonResponse.choices.first?.message.content else {
            let errorMessage = "API response had no content in choices"
            parsingErrors.append(errorMessage)
            print("⚠️ RapSuggestionAPI: \(errorMessage)")
            ErrorStorageManager.shared.storeError(
                errorMessage,
                source: "AI Sparkle Button",
                context: "Response had \(jsonResponse.choices.count) choices but no content"
            )
            
            // Log response with parsing error
            APIDebugInspector.shared.logResponse(
                statusCode: httpResponse.statusCode,
                responseBody: data,
                responseHeaders: responseHeaders,
                duration: requestDuration,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                totalTokens: totalTokens,
                parsingSuccess: false,
                parsingErrors: parsingErrors,
                validationResult: validationResult
            )
            
            throw RapAPIError.invalidResponse
        }
        
        // Model G v2 (control surface): response is plain-text lines, not JSON
        if expectPlainTextLines {
            let text = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { throw RapAPIError.invalidResponse }
            return [
                RapSuggestion(
                    id: UUID(),
                    text: text,
                    confidence: 0.85,
                    source: nil,
                    reasoning: nil,
                    themes: narrative.primaryThemes,
                    arCritique: nil
                )
            ]
        }
        
        // Clean the content: remove markdown code blocks and extract JSON
        let cleanedContent = cleanJSONContent(content)
        
        // Log the raw content for debugging (first 500 chars)
        print("📝 RapSuggestionAPI: Raw content preview: \(content.prefix(500))")
        print("📝 RapSuggestionAPI: Cleaned content preview: \(cleanedContent.prefix(500))")
        
        guard let jsonData = cleanedContent.data(using: .utf8) else {
            let errorMessage = "Failed to convert cleaned content to UTF-8 data"
            print("⚠️ RapSuggestionAPI: \(errorMessage)")
            print("Original content length: \(content.count), Cleaned length: \(cleanedContent.count)")
            print("Original content: \(content)")
            
            ErrorStorageManager.shared.storeError(
                errorMessage,
                source: "AI Sparkle Button",
                context: "Content conversion failed. Original: \(content.prefix(200))"
            )
            
            throw RapAPIError.jsonParsingFailed(errorMessage)
        }
        
        // Parse suggestions array with better error handling and fallback strategies
        let jsonObject: [String: Any]
        do {
            // Try parsing the cleaned content first
            let parsed = try JSONSerialization.jsonObject(with: jsonData)
            
            if let dict = parsed as? [String: Any] {
                // Successfully parsed as dictionary
                jsonObject = dict
                print("✅ RapSuggestionAPI: Successfully parsed JSON as dictionary with keys: \(dict.keys.joined(separator: ", "))")
            } else if let array = parsed as? [Any] {
                // If it's an array, wrap it in a dictionary with "suggestions" key
                print("⚠️ RapSuggestionAPI: Response is an array, wrapping in dictionary")
                jsonObject = ["suggestions": array]
            } else {
                // Try to extract JSON from the response if it's not a direct dictionary
                print("⚠️ RapSuggestionAPI: Response is not a dictionary or array, attempting extraction")
                if let extracted = extractJSONFromText(content) {
                    guard let extractedData = extracted.data(using: .utf8),
                          let extractedParsed = try? JSONSerialization.jsonObject(with: extractedData) as? [String: Any] else {
                        let errorMessage = "JSON is not a dictionary after extraction"
                        print("⚠️ RapSuggestionAPI: \(errorMessage)")
                        print("Extracted content preview: \(extracted.prefix(500))")
                        
                        ErrorStorageManager.shared.storeError(
                            errorMessage,
                            source: "AI Sparkle Button",
                            context: "Extraction failed. Original: \(content.prefix(200))"
                        )
                        
                        throw RapAPIError.jsonParsingFailed(errorMessage)
                    }
                    jsonObject = extractedParsed
                    print("✅ RapSuggestionAPI: Successfully extracted and parsed JSON")
                } else {
                    let errorMessage = "JSON is not a dictionary or array. Response structure unexpected."
                    print("⚠️ RapSuggestionAPI: \(errorMessage)")
                    print("Parsed type: \(type(of: parsed))")
                    print("Content preview: \(cleanedContent.prefix(500))")
                    
                    // Store error for analytics
                    ErrorStorageManager.shared.storeError(
                        errorMessage,
                        source: "AI Sparkle Button",
                        context: "Response was not a JSON dictionary. Content: \(cleanedContent.prefix(200))"
                    )
                    
                    throw RapAPIError.jsonParsingFailed("Response was not a JSON dictionary")
                }
            }
        } catch let jsonError as NSError {
            // Enhanced error logging
            print("⚠️ RapSuggestionAPI: JSON parsing error: \(jsonError.localizedDescription)")
            print("   Error domain: \(jsonError.domain), code: \(jsonError.code)")
            if !jsonError.userInfo.isEmpty {
                print("   User info: \(jsonError.userInfo)")
            }
            print("Original content (first 1000 chars): \(content.prefix(1000))")
            print("Cleaned content (first 1000 chars): \(cleanedContent.prefix(1000))")
            
            // Last resort: try to extract JSON from the original content
            if let extracted = extractJSONFromText(content),
               let extractedData = extracted.data(using: .utf8),
               let parsed = try? JSONSerialization.jsonObject(with: extractedData) as? [String: Any] {
                print("✅ RapSuggestionAPI: Successfully extracted JSON on retry")
                jsonObject = parsed
            } else {
                let errorMessage = "JSON parsing failed: \(jsonError.localizedDescription)"
                print("⚠️ RapSuggestionAPI: \(errorMessage)")
                print("   Failed to extract JSON from content")
                
                // Store error for analytics with full context
                ErrorStorageManager.shared.storeError(
                    errorMessage,
                    source: "AI Sparkle Button",
                    context: "JSON parsing failed. Error: \(jsonError.localizedDescription). Content length: \(content.count), Cleaned: \(cleanedContent.count). First 500 chars: \(content.prefix(500))"
                )
                
                throw RapAPIError.jsonParsingFailed("\(jsonError.localizedDescription). Content preview: \(content.prefix(200))")
            }
        }
        
        // Parse Model G strict schema (supports both single-block and multi-block responses)
        if narrative.generatorPolicy.artistBias == .gunna {
            let blocks: [[String: Any]]
            if let suggestionsArr = jsonObject["suggestions"] as? [[String: Any]] {
                blocks = suggestionsArr
            } else if let suggestionType = jsonObject["suggestionType"] as? String,
                      suggestionType == "rap_bar_block" {
                // Legacy single-block format
                blocks = [jsonObject]
            } else {
                blocks = []
            }
            
            var parsed: [RapSuggestion] = []
            for block in blocks {
                guard let barsArr = block["bars"] as? [[String: Any]], barsArr.count == 4 else { continue }
                let barTexts: [String] = barsArr.compactMap { $0["text"] as? String }
                guard barTexts.count == 4 else { continue }
                
                let suggestionText = barTexts.joined(separator: "\n")
                
                parsed.append(
                    RapSuggestion(
                        id: UUID(),
                        text: suggestionText,
                        confidence: 0.9,
                        source: nil,
                        reasoning: nil,
                        themes: narrative.primaryThemes,
                        arCritique: nil
                    )
                )
                
                if parsed.count >= 5 { break } // enforce 5 cards max
            }
            
            if !parsed.isEmpty {
                return parsed
            }
            // If parsing failed, fall through to legacy parsing
        }
        
        // Try direct "suggestions" key first (legacy format for Model Y)
        var suggestionsArray: [[String: Any]] = []
        if let suggestions = jsonObject["suggestions"] as? [[String: Any]] {
            suggestionsArray = suggestions
        } else if let suggestions = jsonObject["suggestions"] as? [Any] {
            // Fallback: try to parse as array
            suggestionsArray = suggestions.compactMap { $0 as? [String: Any] }
        } else if let lines = jsonObject["lines"] as? [[String: Any]] {
            // Alternative: check for "lines" key
            suggestionsArray = lines
        } else if let lines = jsonObject["lines"] as? [Any] {
            suggestionsArray = lines.compactMap { $0 as? [String: Any] }
        } else if let candidates = jsonObject["candidates"] as? [[String: Any]] {
            // Alternative: check for "candidates" key
            suggestionsArray = candidates
        } else if let candidates = jsonObject["candidates"] as? [Any] {
            suggestionsArray = candidates.compactMap { $0 as? [String: Any] }
        } else {
            // Check if this is a "silence" response (API cannot generate suggestions)
            if let silenceDict = jsonObject["silence"] as? [String: Any] {
                // Parse the silence commentary
                let explanation = silenceDict["explanation"] as? String ?? "Unable to generate suggestions that meet all constraints."
                let reason = silenceDict["reason"] as? String ?? "Constraints too strict for current narrative context."
                let guidance = silenceDict["guidance"] as? String ?? "Consider adjusting the narrative or thematic constraints for broader creative flexibility."
                
                let commentary = CriticCommentary(
                    explanation: explanation,
                    reason: reason,
                    guidance: guidance
                )
                
                print("⚠️ RapSuggestionAPI: Received silence response from API")
                print("   Explanation: \(explanation)")
                print("   Reason: \(reason)")
                print("   Guidance: \(guidance)")
                
                // Store error for analytics
                ErrorStorageManager.shared.storeError(
                    "API returned silence: \(reason)",
                    source: "AI Sparkle Button",
                    context: "Explanation: \(explanation). Guidance: \(guidance)"
                )
                
                // Throw silence error - caller should handle this gracefully
                throw RapAPIError.silence(commentary)
            }
            
            // No suggestions found in response - log the actual structure
            print("⚠️ RapSuggestionAPI: No 'suggestions' key found in response")
            print("Response keys: \(jsonObject.keys.joined(separator: ", "))")
            print("Full response preview: \(cleanedContent.prefix(1000))")
            
            // Try to extract any array of strings as fallback
            for (key, value) in jsonObject {
                if let stringArray = value as? [String], !stringArray.isEmpty {
                    // Convert string array to suggestion dictionaries
                    suggestionsArray = stringArray.map { ["text": $0] }
                    print("✅ RapSuggestionAPI: Found string array under '\(key)', converting to suggestions")
                    break
                }
            }
            
            // If still no suggestions, log detailed error and throw
            if suggestionsArray.isEmpty {
                let errorMessage = "No suggestions found in API response"
                print("⚠️ RapSuggestionAPI: \(errorMessage)")
                print("   Response keys: \(jsonObject.keys.joined(separator: ", "))")
                print("   Response structure: \(jsonObject)")
                print("   Full response preview: \(cleanedContent.prefix(1000))")
                
                ErrorStorageManager.shared.storeError(
                    "Required field 'suggestions' is missing",
                    source: "AI Sparkle Button",
                    context: "Response keys: \(jsonObject.keys.joined(separator: ", ")). Response preview: \(cleanedContent.prefix(500))"
                )
                
                throw RapAPIError.emptyResponse
            }
        }
        
        // Check if we have any suggestions
        guard !suggestionsArray.isEmpty else {
            let errorMessage = "Suggestions array is empty after parsing"
            print("⚠️ RapSuggestionAPI: \(errorMessage)")
            print("   Response keys: \(jsonObject.keys.joined(separator: ", "))")
            
            ErrorStorageManager.shared.storeError(
                "Required field 'suggestions' is missing",
                source: "AI Sparkle Button",
                context: "Suggestions array was empty after parsing. Response structure: \(jsonObject.keys.joined(separator: ", "))"
            )
            
            throw RapAPIError.emptyResponse
        }
        
        var suggestions: [RapSuggestion] = []
        for suggestionDict in suggestionsArray {
            let text = suggestionDict["text"] as? String ?? ""
            let confidence = (suggestionDict["confidence"] as? Double) ?? 0.5
            let source = suggestionDict["source"] as? String
            let reasoning = suggestionDict["reasoning"] as? String
            let themesArray = suggestionDict["themes"] as? [String] ?? []
            
            // If themes are not provided in response, extract from narrative
            // If narrative themes are also missing, fall back to CSV themes
            var themes: [String]
            if !themesArray.isEmpty {
                themes = themesArray
            } else if !narrative.primaryThemes.isEmpty || !narrative.secondaryThemes.isEmpty {
                themes = narrative.primaryThemes + narrative.secondaryThemes
            } else {
                // Fallback to CSV themes from NewRapDatabase
                let csvThemes = NewRapDatabase.shared.themes.prefix(3).map { $0.name }
                themes = Array(csvThemes)
                if themes.isEmpty {
                    // Last resort: use default themes
                    themes = ["luxury", "hustle", "status"]
                }
            }
            
            // Calculate quality metrics (Phase 1: AI Quality Foundation)
            let rhymeStrength = calculateRhymeStrength(text: text)
            let flowMatch = calculateFlowMatch(suggestionText: text, originalText: metrics.fullText)
            let styleMatch = calculateStyleMatch(suggestionText: text, narrative: narrative)
            
            // PR 6: Check for rejection (Model G only)
            let lines = text.components(separatedBy: "\n")
            var shouldReject = false
            var rejectionReason: RejectionReason? = nil
            
            for line in lines {
                if let reason = rejectLine(line, policy: narrative.generatorPolicy) {
                    shouldReject = true
                    rejectionReason = reason
                    break  // Reject entire suggestion if any line fails
                }
            }
            
            // Skip this suggestion if rejected
            if shouldReject {
                print("⚠️ RapSuggestionAPI: Rejected suggestion due to: \(rejectionReason!)")
                // PR 10: Track rejected lines for diagnostics
                if let reason = rejectionReason {
                    let diagnosticsReason: GenerationDiagnostics.RejectionReason
                    switch reason {
                    case .forbiddenVerb:
                        diagnosticsReason = .forbiddenVerb
                    case .explanationToken:
                        diagnosticsReason = .explanationToken
                    case .tooManyBrands:
                        diagnosticsReason = .tooManyBrands
                    case .clauseTooLong:
                        diagnosticsReason = .clauseTooLong
                    case .verbClassViolation:
                        diagnosticsReason = .verbClassViolation
                    case .reflectiveTense:
                        diagnosticsReason = .reflectiveTense
                    }
                    rejectedLines.append((line: text, reason: diagnosticsReason))
                }
                continue
            }
            
            // PR 5: Apply indifference polish to each line (Model G only)
            // PR 7: Enforce clause length
            let polishedText: String
            if narrative.generatorPolicy.artistBias == .gunna {
                // Split into lines, polish each, enforce clause length, rejoin
                let polishedAndEnforced = lines.map { line in
                    let polished = polishLine(line, policy: narrative.generatorPolicy)
                    return enforceClauseLength(polished, maxSyllables: narrative.generatorPolicy.maxClauseSyllables)
                }
                polishedText = polishedAndEnforced.joined(separator: "\n")
            } else {
                polishedText = text
            }
            
            suggestions.append(RapSuggestion(
                id: UUID(),
                text: polishedText,
                confidence: confidence,
                source: source,
                reasoning: reasoning,
                themes: Array(themes.prefix(5)), // Limit to 5 themes
                rhymeStrength: rhymeStrength,
                flowMatch: flowMatch,
                styleMatch: styleMatch,
                userFeedback: nil,
                signalStrength: nil,
                signalNote: nil,
                arCritique: nil
            ))
        }
        
        // Log successful response (if not already logged in error cases)
        // Note: Response logging is already handled in error cases above
        // This ensures we log even successful parsing
        if parsingErrors.isEmpty {
            APIDebugInspector.shared.logResponse(
                statusCode: httpResponse.statusCode,
                responseBody: data,
                responseHeaders: responseHeaders,
                duration: requestDuration,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                totalTokens: totalTokens,
                parsingSuccess: true,
                parsingErrors: [],
                validationResult: validationResult
            )
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
        4. Matches the tone: \(narrative.detectedTones.first ?? narrative.emotionalTone)
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
            "\(index + 1). \(line.text)"
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
        
        var dummyRejectedLines: [(line: String, reason: GenerationDiagnostics.RejectionReason)] = []
        return try await performAPIRequest(requestBody: requestBody, narrative: narrative, metrics: metrics, rejectedLines: &dummyRejectedLines)
    }
    
    // MARK: - Generate Lyrics from Flow (syllable-constrained generation)
    
    /// Parse OpenAI error response body for a user-facing message. Returns nil if body is not valid JSON or has no error.message.
    private static func parseOpenAIErrorMessage(from data: Data) -> String? {
        struct OpenAIError: Decodable {
            let error: Inner?
            struct Inner: Decodable {
                let message: String?
            }
        }
        guard let decoded = try? JSONDecoder().decode(OpenAIError.self, from: data),
              let message = decoded.error?.message?.trimmingCharacters(in: .whitespacesAndNewlines),
              !message.isEmpty else { return nil }
        return message
    }
    
    /// Generate rap lyrics that match a given rhythm skeleton (syllable-per-bar). Used by Generate Lyrics from Flow (Scenario A and B).
    func generateLyricsFromFlow(rhythmResult: RhythmicTranscriptionResult, theme: String?) async throws -> String {
        guard apiKey != nil else {
            throw RapAPIError.missingAPIKey
        }
        
        let perBar = rhythmResult.syllables.perBar
        guard !perBar.isEmpty else {
            throw RapAPIError.requestFailed
        }
        
        var skeletonLines: [String] = []
        for (index, bar) in perBar.enumerated() {
            let barNum = index + 1
            let perBeatStr = bar.perBeat.map { String($0) }.joined(separator: "|")
            skeletonLines.append("Bar \(barNum): \(bar.count) syllables (per beat: \(perBeatStr))")
        }
        let skeletonText = skeletonLines.joined(separator: "\n")
        let themeText = (theme?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { t in t.isEmpty ? nil : t } ?? "general"
        let bpmText = rhythmResult.bpm.map { "\($0) BPM" } ?? "unknown BPM"
        
        let systemContent = """
        You are a rap lyricist. Generate original rap lyrics that match an exact syllable structure. \
        Each line must fit the given syllable count per bar. Use end rhymes (e.g. lines 2 and 4 rhyme). \
        Output only the lyrics, one line per bar. No numbering, no explanations.
        """
        
        let userContent = """
        Generate rap lyrics with this exact structure:
        \(skeletonText)
        Tempo: \(bpmText)
        Theme or vibe: \(themeText)

        Output only the lyrics, one bar per line. Match the syllable counts so the lyrics can be rapped in the same flow.
        """
        
        let requestBody: [String: Any] = [
            "model": SuggestionModel.modelG.modelIdentifier,
            "messages": [
                ["role": "system", "content": systemContent],
                ["role": "user", "content": userContent]
            ],
            "temperature": 0.7,
            "max_tokens": 1024
        ]
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 45.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let message = Self.parseOpenAIErrorMessage(from: data)
            throw RapAPIError.serverError(statusCode: http.statusCode, message: message)
        }
        
        struct ChatChoice: Decodable {
            let message: ChatMessage?
        }
        struct ChatMessage: Decodable {
            let content: String?
        }
        struct ChatResponse: Decodable {
            let choices: [ChatChoice]?
        }
        
        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = decoded.choices?.first?.message?.content?.trimmingCharacters(in: .whitespacesAndNewlines),
              !content.isEmpty else {
            throw RapAPIError.requestFailed
        }
        return content
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
        - Detected Tones: \(narrative.detectedTones.map(\.rawValue).joined(separator: ", "))
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
        
        OPTIONAL CANDIDATE LINES (may use as inspiration, but SIGNAL LAYER constraints take priority):
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
    
    // MARK: - Advanced Rhyme Ranking Structures
    
    /// Represents a ranked rhyme candidate with multi-source scoring
    private struct RankedRhymeCandidate {
        let word: String
        let rhymeStrength: RhymeStrength
        let compositeScore: Double  // 0.0-1.0, combines all ranking factors
        
        // Individual component scores
        let phoneticScore: Double      // From CMUDICT phonetic matching
        let lyricsFrequencyScore: Double  // From song lyrics database
        let ngramFrequencyScore: Double   // From Google Books N-gram
        let userQueryScore: Double        // From user query logs
        let semanticRelevanceScore: Double // From WordNet semantic analysis
    }
    
    /// Configuration for ranking weights
    private struct RhymeRankingWeights: Sendable {
        var phoneticWeight: Double = 0.30
        var lyricsFrequencyWeight: Double = 0.25
        var ngramFrequencyWeight: Double = 0.20
        var userQueryWeight: Double = 0.15
        var semanticRelevanceWeight: Double = 0.10
        
        static let `default` = RhymeRankingWeights()
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
    
    // MARK: - Advanced Rhyme Ranking Services
    
    /// Service for querying song lyrics databases (e.g., Genius API, Musixmatch, or local database)
    private class LyricsFrequencyService {
        static let shared = LyricsFrequencyService()
        
        private var lyricsDatabase: [String: Int] = [:] // word -> frequency count
        private let cache = NSCache<NSString, NSNumber>()
        var isLoaded = false
        
        // Path to accumulated data file (crowdsourced data)
        private var accumulatedDataURL: URL? {
            guard let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.finaljournal.app"
            ) else { return nil }
            return containerURL.appendingPathComponent("accumulated_lyrics_frequency.json")
        }
        
        private init() {
            cache.countLimit = 1000
        }
        
        /// Load lyrics database from local file, accumulated data, or API
        func loadLyricsDatabase() async throws {
            guard !isLoaded else { return }
            
            // 1. Try to load from bundle (initial/pre-populated data)
            if let url = Bundle.main.url(forResource: "lyrics_frequency", withExtension: "json") {
                let data = try Data(contentsOf: url)
                let bundleData = try JSONDecoder().decode([String: Int].self, from: data)
                lyricsDatabase.merge(bundleData) { (current, new) in max(current, new) }
            }
            
            // 2. Load accumulated data (crowdsourced from API queries)
            await loadAccumulatedData()
            
            isLoaded = true
            let totalWords = lyricsDatabase.count
            if totalWords > 0 {
                print("✅ LyricsFrequencyService: Loaded \(totalWords) words (bundle + accumulated)")
            } else {
                print("⚠️ LyricsFrequencyService: No local database found, will use API if configured")
            }
        }
        
        /// Load and merge accumulated data from App Group container
        private func loadAccumulatedData() async {
            guard let url = accumulatedDataURL,
                  FileManager.default.fileExists(atPath: url.path),
                  let data = try? Data(contentsOf: url),
                  let accumulated = try? JSONDecoder().decode([String: Int].self, from: data) else {
                return
            }
            
            // Merge accumulated data with existing database (sum frequencies)
            for (word, count) in accumulated {
                lyricsDatabase[word, default: 0] += count
            }
        }
        
        /// Accumulate word frequency from API query (crowdsourcing)
        private func accumulateWordFrequency(word: String, count: Int) {
            let normalized = word.lowercased()
            lyricsDatabase[normalized, default: 0] += count
            
            // Save to accumulated file asynchronously (non-blocking)
            Task.detached(priority: .utility) {
                await self.saveAccumulatedData()
            }
        }
        
        /// Save accumulated data to file (for crowdsourcing)
        private func saveAccumulatedData() async {
            guard let url = accumulatedDataURL else { return }
            
            do {
                let data = try JSONEncoder().encode(lyricsDatabase)
                try data.write(to: url)
                print("✅ LyricsFrequencyService: Saved accumulated data (\(lyricsDatabase.count) words)")
            } catch {
                print("⚠️ LyricsFrequencyService: Failed to save accumulated data - \(error.localizedDescription)")
            }
        }
        
        /// Get frequency score for a word in song lyrics (0.0-1.0)
        /// If not found locally, queries API and accumulates data
        func getFrequencyScoreWithAccumulation(for word: String, apiKey: String?) async -> Double {
            let normalized = word.lowercased()
            
            // Check cache first
            if let cached = cache.object(forKey: normalized as NSString) {
                return cached.doubleValue
            }
            
            // Check local/accumulated database
            var frequency = lyricsDatabase[normalized] ?? 0
            
            // If not found locally and API key available, query API and accumulate
            if frequency == 0, let apiKey = apiKey, !apiKey.isEmpty {
                let hitCount = await queryGeniusAPIAndAccumulate(word: normalized, apiKey: apiKey)
                frequency = hitCount
            }
            
            // Calculate normalized score
            let maxFrequency = max(lyricsDatabase.values.max() ?? 1, 1000)
            let score = maxFrequency > 0 ? min(1.0, Double(frequency) / Double(maxFrequency)) : 0.0
            
            // Cache result
            cache.setObject(NSNumber(value: score), forKey: normalized as NSString)
            return score
        }
        
        /// Get frequency score for a word (synchronous, uses existing data only)
        func getFrequencyScore(for word: String) -> Double {
            let normalized = word.lowercased()
            
            // Check cache first
            if let cached = cache.object(forKey: normalized as NSString) {
                return cached.doubleValue
            }
            
            // Check local database
            let frequency = lyricsDatabase[normalized] ?? 0
            let maxFrequency = lyricsDatabase.values.max() ?? 1
            let score = maxFrequency > 0 ? min(1.0, Double(frequency) / Double(maxFrequency)) : 0.0
            
            cache.setObject(NSNumber(value: score), forKey: normalized as NSString)
            return score
        }
        
        /// Query Genius API and accumulate results (crowdsourcing)
        private func queryGeniusAPIAndAccumulate(word: String, apiKey: String) async -> Int {
            // Genius API search endpoint
            let searchURL = "https://api.genius.com/search?q=\(word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? word)"
            
            guard let url = URL(string: searchURL) else {
                return 0
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let hits = response["hits"] as? [[String: Any]] {
                    let hitCount = hits.count
                    
                    // Accumulate this data (crowdsourcing)
                    if hitCount > 0 {
                        accumulateWordFrequency(word: word, count: hitCount)
                    }
                    
                    return hitCount
                }
            } catch {
                print("⚠️ LyricsFrequencyService: Genius API error - \(error.localizedDescription)")
            }
            
            return 0
        }
        
        /// Query Genius API for word frequency (requires API key) - legacy method
        func queryGeniusAPI(word: String, apiKey: String?) async -> Double {
            guard let apiKey = apiKey, !apiKey.isEmpty else {
                return 0.0
            }
            
            let hitCount = await queryGeniusAPIAndAccumulate(word: word, apiKey: apiKey)
            // Normalize to 0.0-1.0 (assuming max ~1000 results)
            return min(1.0, Double(hitCount) / 1000.0)
        }
    }
    
    /// Service for Google Books N-gram frequency data
    private class NgramFrequencyService {
        static let shared = NgramFrequencyService()
        
        private var ngramDatabase: [String: Double] = [:] // word -> normalized frequency
        private let cache = NSCache<NSString, NSNumber>()
        var isLoaded = false
        
        private init() {
            cache.countLimit = 1000
        }
        
        /// Load N-gram data (can use Google Books Ngram Viewer data or local cache)
        func loadNgramDatabase() async throws {
            guard !isLoaded else { return }
            
            // Try to load from local file (pre-processed N-gram data)
            if let url = Bundle.main.url(forResource: "ngram_frequency", withExtension: "json") {
                let data = try Data(contentsOf: url)
                ngramDatabase = try JSONDecoder().decode([String: Double].self, from: data)
                isLoaded = true
                print("✅ NgramFrequencyService: Loaded \(ngramDatabase.count) words from local database")
                return
            }
            
            // Fallback: Try App Group container
            if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.finaljournal.app") {
                let fileURL = containerURL.appendingPathComponent("ngram_frequency.json")
                if FileManager.default.fileExists(atPath: fileURL.path),
                   let data = try? Data(contentsOf: fileURL) {
                    ngramDatabase = try JSONDecoder().decode([String: Double].self, from: data)
                    isLoaded = true
                    print("✅ NgramFrequencyService: Loaded from App Group container")
                    return
                }
            }
            
            // If no local file, initialize empty
            isLoaded = true
            print("⚠️ NgramFrequencyService: No local database found")
        }
        
        /// Get normalized frequency score from N-gram data (0.0-1.0)
        func getFrequencyScore(for word: String) -> Double {
            let normalized = word.lowercased()
            
            // Check cache first
            if let cached = cache.object(forKey: normalized as NSString) {
                return cached.doubleValue
            }
            
            // N-gram frequencies are already normalized (per million words)
            let frequency = ngramDatabase[normalized] ?? 0.0
            // Normalize to 0.0-1.0 scale (assuming max frequency ~1000 per million)
            let score = min(1.0, frequency / 1000.0)
            
            cache.setObject(NSNumber(value: score), forKey: normalized as NSString)
            return score
        }
    }
    
    /// Service for user query logs (tracks what users search for/select)
    private class UserQueryLogService {
        static let shared = UserQueryLogService()
        
        private var queryLogs: [String: Int] = [:] // word -> selection count
        private let userDefaultsKey = "rhyme_query_logs"
        
        private init() {
            loadQueryLogs()
        }
        
        /// Load query logs from UserDefaults or database
        func loadQueryLogs() {
            if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
               let logs = try? JSONDecoder().decode([String: Int].self, from: data) {
                queryLogs = logs
            }
        }
        
        /// Record a user selection for analytics
        func recordSelection(word: String) {
            let normalized = word.lowercased()
            queryLogs[normalized, default: 0] += 1
            saveQueryLogs()
        }
        
        /// Get popularity score based on user selections (0.0-1.0)
        func getPopularityScore(for word: String) -> Double {
            let normalized = word.lowercased()
            let count = queryLogs[normalized] ?? 0
            guard count > 0 else { return 0.0 }
            
            let maxCount = queryLogs.values.max() ?? 1
            return min(1.0, Double(count) / Double(maxCount))
        }
        
        private func saveQueryLogs() {
            if let data = try? JSONEncoder().encode(queryLogs) {
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
            }
        }
    }
    
    /// Service for WordNet-based semantic analysis
    private class WordNetSemanticService {
        static let shared = WordNetSemanticService()
        
        // Note: For iOS, we'll use a simplified WordNet implementation
        // In production, you might want to use a WordNet library or API
        private var wordNetData: [String: WordNetEntry] = [:]
        private let cache = NSCache<NSString, NSNumber>()
        var isLoaded = false
        
        struct WordNetEntry: Codable {
            let word: String
            let synonyms: [String]
            let hypernyms: [String]  // More general terms
            let hyponyms: [String]   // More specific terms
            let descriptiveWords: [String]  // Adjectives/descriptors
        }
        
        private init() {
            cache.countLimit = 1000
        }
        
        /// Load WordNet data (from local files or API)
        func loadWordNetData() async throws {
            guard !isLoaded else { return }
            
            // Try to load from local JSON file
            if let url = Bundle.main.url(forResource: "wordnet_data", withExtension: "json") {
                let data = try Data(contentsOf: url)
                let entries = try JSONDecoder().decode([WordNetEntry].self, from: data)
                wordNetData = Dictionary(uniqueKeysWithValues: entries.map { ($0.word.lowercased(), $0) })
                isLoaded = true
                print("✅ WordNetSemanticService: Loaded \(wordNetData.count) entries from local database")
                return
            }
            
            // Fallback: Try App Group container
            if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.finaljournal.app") {
                let fileURL = containerURL.appendingPathComponent("wordnet_data.json")
                if FileManager.default.fileExists(atPath: fileURL.path),
                   let data = try? Data(contentsOf: fileURL) {
                    let entries = try JSONDecoder().decode([WordNetEntry].self, from: data)
                    wordNetData = Dictionary(uniqueKeysWithValues: entries.map { ($0.word.lowercased(), $0) })
                    isLoaded = true
                    print("✅ WordNetSemanticService: Loaded from App Group container")
                    return
                }
            }
            
            // If no local file, initialize with basic semantic relationships
            // This is a fallback - in production, you'd want proper WordNet data
            isLoaded = true
            print("⚠️ WordNetSemanticService: No local database found, using basic semantic matching")
        }
        
        /// Get semantic relevance score for a word given narrative context
        func getSemanticRelevanceScore(word: String, context: NarrativeAnalysis) -> Double {
            let normalized = word.lowercased()
            
            // Check cache first
            let cacheKey = "\(normalized)_\(context.primaryThemes.joined(separator: "_"))" as NSString
            if let cached = cache.object(forKey: cacheKey) {
                return cached.doubleValue
            }
            
            var relevanceScore: Double = 0.0
            
            // 1. Check direct theme matches
            let allThemes = context.primaryThemes + context.secondaryThemes + (context.underlyingThemes ?? [])
            if let entry = wordNetData[normalized] {
                for theme in allThemes {
                    let themeLower = theme.lowercased()
                    if entry.synonyms.contains(themeLower) ||
                       entry.hypernyms.contains(themeLower) ||
                       entry.hyponyms.contains(themeLower) {
                        relevanceScore += 0.3
                    }
                }
            }
            
            // 2. Check key phrases
            if let keyPhrases = context.keyPhrases {
                for phrase in keyPhrases {
                    let phraseWords = phrase.lowercased().components(separatedBy: CharacterSet.whitespaces)
                    if phraseWords.contains(normalized) {
                        relevanceScore += 0.2
                    }
                }
            }
            
            // 3. Check story elements
            if let storyElements = context.storyElements {
                for element in storyElements {
                    if element.lowercased().contains(normalized) {
                        relevanceScore += 0.2
                    }
                }
            }
            
            // 4. Check emotional tone match (use first detected tone)
            let toneString = (context.detectedTones.first ?? context.emotionalTone).rawValue
            if isDescriptiveWord(word: normalized, matchingTone: toneString) {
                relevanceScore += 0.3
            }
            
            let finalScore = min(1.0, relevanceScore)
            cache.setObject(NSNumber(value: finalScore), forKey: cacheKey)
            return finalScore
        }
        
        /// Get synonyms for a word (for semantic expansion)
        func getSynonyms(for word: String) -> [String] {
            let normalized = word.lowercased()
            return wordNetData[normalized]?.synonyms ?? []
        }
        
        /// Get descriptive words (adjectives) related to a word
        func getDescriptiveWords(for word: String) -> [String] {
            let normalized = word.lowercased()
            return wordNetData[normalized]?.descriptiveWords ?? []
        }
        
        /// Filter words by semantic relevance to context
        func filterBySemanticRelevance(
            words: [String],
            context: NarrativeAnalysis,
            threshold: Double = 0.3
        ) -> [String] {
            return words.filter { word in
                getSemanticRelevanceScore(word: word, context: context) >= threshold
            }
        }
        
        private func isDescriptiveWord(word: String, matchingTone: String) -> Bool {
            // Check if word is a descriptive adjective matching the tone
            guard let entry = wordNetData[word.lowercased()] else { return false }
            return entry.descriptiveWords.contains { $0.lowercased() == matchingTone.lowercased() }
        }
    }
    
    // MARK: - FIX 1 & 2: Rhyme Extraction and Family Computation
    
    /// Extracts the last rhyme word from text and computes its rhyme family
    /// Returns: (lastRhymeWord: String?, rhymeFamily: String?)
    private func extractLastRhymeWordAndFamily(from text: String) -> (lastRhymeWord: String?, rhymeFamily: String?) {
        // Get the last non-empty line
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard let lastLine = lines.last else {
            return (nil, nil)
        }
        
        // Extract the last word from the line
        let words = lastLine.components(separatedBy: CharacterSet.whitespaces.union(.punctuationCharacters))
            .filter { !$0.isEmpty }
        
        guard let lastWord = words.last?.lowercased() else {
            return (nil, nil)
        }
        
        // Get phonemes for the last word
        guard let phonemes = getCMUDICTPhonemes(for: lastWord) else {
            return (lastWord, nil)
        }
        
        // Extract phonetic signature
        guard let signature = extractPhoneticSignature(from: phonemes) else {
            return (lastWord, nil)
        }
        
        // Compute rhyme family: stressed vowel + coda (e.g., "AY1-T" for "night", "light")
        let rhymeFamily = "\(signature.stressedVowel)-\(signature.coda.joined(separator: "-"))"
        
        return (lastWord, rhymeFamily)
    }
    
    // MARK: - Advanced Rhyme Ranking
    
    /// Get ranked rhyme candidates with multi-source scoring
    private func getRankedRhymeCandidates(
        rhymeFamily: String,
        allowedLexiconTerms: [LexiconTerm] = [],
        context: NarrativeAnalysis? = nil,
        weights: RhymeRankingWeights
    ) async -> [RankedRhymeCandidate] {
        var candidates: [RankedRhymeCandidate] = []
        
        // Initialize services (lazy load if needed)
        let lyricsService = LyricsFrequencyService.shared
        let ngramService = NgramFrequencyService.shared
        let queryService = UserQueryLogService.shared
        let semanticService = WordNetSemanticService.shared
        
        // Load services if not already loaded
        if !lyricsService.isLoaded {
            try? await lyricsService.loadLyricsDatabase()
        }
        if !ngramService.isLoaded {
            try? await ngramService.loadNgramDatabase()
        }
        if !semanticService.isLoaded {
            try? await semanticService.loadWordNetData()
        }
        
        // Parse rhyme family
        let parts = rhymeFamily.split(separator: "-").map { String($0) }
        guard parts.count >= 2 else {
            return candidates
        }
        
        let stressedVowel = parts[0]
        let coda = parts[1...].joined(separator: "-")
        
        // Collect all potential rhyme words from CMUDICT
        var potentialWords: Set<String> = []
        
        if let store = getCMUDICTStore() {
            for (word, phonemes) in store {
                if let signature = extractPhoneticSignature(from: phonemes) {
                    // Perfect rhymes
                    if signature.stressedVowel == stressedVowel && 
                       signature.coda.joined(separator: "-") == coda {
                        potentialWords.insert(word)
                    }
                    // Near rhymes (same vowel, different coda)
                    else if signature.stressedVowel == stressedVowel {
                        potentialWords.insert(word)
                    }
                }
            }
        }
        
        // Add hardcoded and luxury rhymes
        let hardcoded = getHardcodedRhymeExamples(for: rhymeFamily)
        potentialWords.formUnion(hardcoded)
        
        let luxuryRhymes = getLuxuryBrandRhymes(for: rhymeFamily)
        potentialWords.formUnion(luxuryRhymes)
        
        // Score each candidate
        for word in potentialWords {
            let normalized = word.lowercased()
            
            // 1. Phonetic score (based on rhyme strength)
            guard let phonemes = getCMUDICTPhonemes(for: normalized),
                  let signature = extractPhoneticSignature(from: phonemes) else { continue }
            
            // Create target signature from rhyme family
            // The rhyme family format is "VOWEL-CODA", so we need to construct phonemes
            // For comparison, we'll check if the signature matches the rhyme family directly
            let matchesPerfect = signature.stressedVowel == stressedVowel && 
                                signature.coda.joined(separator: "-") == coda
            let matchesNear = signature.stressedVowel == stressedVowel
            
            let rhymeStrength: RhymeStrength?
            if matchesPerfect {
                rhymeStrength = .perfect
            } else if matchesNear {
                rhymeStrength = .near
            } else {
                // Check for slant rhyme (similar vowels)
                let vowel1Base = String(signature.stressedVowel.dropLast())
                let vowel2Base = String(stressedVowel.dropLast())
                rhymeStrength = (vowel1Base == vowel2Base) ? .slant : nil
            }
            
            guard let strength = rhymeStrength else { continue }
            let phoneticScore = strength.rawValue
            
            // 2. Lyrics frequency score (with accumulation)
            // Get Genius API key from Keychain
            let geniusAPIKey = getGeniusAPIKeyFromKeychain()
            let lyricsScore = await lyricsService.getFrequencyScoreWithAccumulation(
                for: normalized,
                apiKey: geniusAPIKey
            )
            
            // 3. N-gram frequency score
            let ngramScore = ngramService.getFrequencyScore(for: normalized)
            
            // 4. User query popularity score
            let queryScore = queryService.getPopularityScore(for: normalized)
            
            // 5. Semantic relevance score (if context provided)
            let semanticScore = context != nil ? 
                semanticService.getSemanticRelevanceScore(word: normalized, context: context!) : 0.5
            
            // Calculate composite score
            let compositeScore = 
                (phoneticScore * weights.phoneticWeight) +
                (lyricsScore * weights.lyricsFrequencyWeight) +
                (ngramScore * weights.ngramFrequencyWeight) +
                (queryScore * weights.userQueryWeight) +
                (semanticScore * weights.semanticRelevanceWeight)
            
            // Boost luxury/lexicon terms
            let isLuxuryTerm = allowedLexiconTerms.contains { $0.term.lowercased() == normalized }
            let finalScore = isLuxuryTerm ? min(1.0, compositeScore * 1.2) : compositeScore
            
            candidates.append(RankedRhymeCandidate(
                word: normalized,
                rhymeStrength: strength,
                compositeScore: finalScore,
                phoneticScore: phoneticScore,
                lyricsFrequencyScore: lyricsScore,
                ngramFrequencyScore: ngramScore,
                userQueryScore: queryScore,
                semanticRelevanceScore: semanticScore
            ))
        }
        
        // Sort by composite score (descending)
        candidates.sort { $0.compositeScore > $1.compositeScore }
        
        return candidates
    }
    
    /// Gets example words that rhyme with the given rhyme family (updated to use advanced ranking)
    private func getRhymeFamilyExamples(rhymeFamily: String, allowedLexiconTerms: [LexiconTerm] = [], context: NarrativeAnalysis? = nil) async -> [String] {
        // Use advanced ranking system
        let ranked = await getRankedRhymeCandidates(
            rhymeFamily: rhymeFamily,
            allowedLexiconTerms: allowedLexiconTerms,
            context: context,
            weights: .default
        )
        
        // Apply semantic filtering if context provided
        if let context = context {
            let semanticService = WordNetSemanticService.shared
            let filtered = semanticService.filterBySemanticRelevance(
                words: ranked.map { $0.word },
                context: context,
                threshold: 0.2  // Adjustable threshold
            )
            
            // Return filtered and ranked words
            return filtered.prefix(100).map { $0 }
        }
        
        // Return top 100 ranked words
        return ranked.prefix(100).map { $0.word }
    }
    
    private func getHardcodedRhymeExamples(for rhymeFamily: String) -> [String] {
        let examples: [String: [String]] = [
            "AY1-T": ["night", "light", "tight", "fight", "right", "sight", "bright", "flight", "might", "slight", "kite", "white", "write", "bite", "cite"],
            "IH1-T": ["hit", "bit", "fit", "sit", "wit", "lit", "pit", "kit", "quit", "split", "admit", "permit"],
            "OW1-L": ["bowl", "soul", "goal", "roll", "toll", "coal", "hole", "pole", "whole", "control", "patrol"],
            "UW1-L": ["cool", "pool", "tool", "rule", "fool", "school", "stool", "jewel", "fuel", "cruel", "duel"],
            "IH1-NG": ["thing", "ring", "sing", "bring", "king", "wing", "spring", "string", "swing", "cling", "sting"],
            "AY1-N": ["pain", "rain", "main", "gain", "chain", "brain", "train", "plain", "stain", "vain"],
            "OW1-N": ["own", "known", "shown", "blown", "grown", "thrown", "bone", "tone", "phone", "zone"],
            "IH1-K": ["thick", "sick", "pick", "trick", "stick", "click", "quick", "brick", "chick"],
            "EY1-L": ["mail", "fail", "tail", "sail", "nail", "rail", "trail", "detail", "retail"],
            "UW1-N": ["tune", "moon", "soon", "noon", "spoon", "balloon", "cartoon"]
        ]
        return examples[rhymeFamily] ?? []
    }
    
    private func getLuxuryBrandRhymes(for rhymeFamily: String) -> [String] {
        // Manual luxury brand rhymes that might not be in CMUDICT
        // Format: rhymeFamily -> [luxury words that rhyme]
        let luxuryRhymes: [String: [String]] = [
            "UW1-L": ["patek", "cartier", "goyard", "birkin", "hermes"],
            "AY1-T": ["patek", "rolex", "cartier"],
            "OW1-L": ["rolls", "porsche", "bentley"],
            "IH1-NG": ["bling", "ring", "thing"],
            "AY1-N": ["chain", "train", "main"]
        ]
        return luxuryRhymes[rhymeFamily] ?? []
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
    
    // MARK: - Register Guidance Builder
    
    /// Build register guidance for generation prompt
    /// Registers represent artist position - filter candidates by register consistency
    private func buildLexiconGuidance(allowedLexiconTerms: [LexiconTerm]) -> String {
        guard !allowedLexiconTerms.isEmpty else {
            return ""
        }
        
        // Group terms by category for better organization
        var termsByCategory: [String: [LexiconTerm]] = [:]
        for term in allowedLexiconTerms {
            let category = term.category.rawValue
            if termsByCategory[category] == nil {
                termsByCategory[category] = []
            }
            termsByCategory[category]?.append(term)
        }
        
        var guidance = "\nRAP LEXICON TERMS (use these authentic terms/phrases when contextually appropriate):\n"
        
        // Limit to top 50 terms to avoid overwhelming the prompt
        let displayTerms = Array(allowedLexiconTerms.prefix(50))
        
        for (index, term) in displayTerms.enumerated() {
            var termInfo = "\(index + 1). \"\(term.term)\""
            if let definition = term.definition, !definition.isEmpty {
                termInfo += " - \(definition)"
            }
            if let notes = term.notes, !notes.isEmpty {
                termInfo += " (\(notes))"
            }
            guidance += termInfo + "\n"
        }
        
        if allowedLexiconTerms.count > 50 {
            guidance += "\n... and \(allowedLexiconTerms.count - 50) more terms available. Use these terms naturally when they fit the context, register, and authority level.\n"
        } else {
            guidance += "\nUse these terms naturally when they fit the context, register, and authority level. These are authentic rap idioms and jargon that will improve the authenticity of your suggestions.\n"
        }
        
        return guidance
    }
    
    private func buildRegisterGuidance(registers: RegisterProfile?) -> String {
        guard let registers = registers else {
            return ""
        }
        
        var guidance: [String] = []
        guidance.append("REGISTER POSITION (artist stance - MUST maintain consistency):")
        
        if registers.register_noRepairPosition {
            guidance.append("- NO REPAIR POSITION: Do not use reconciliation language, apologies, or outreach. Maintain closure without repair attempts.")
        }
        
        if registers.register_isolationPosition {
            guidance.append("- ISOLATION POSITION: Maintain distance without hostility. No accusation or confrontation language.")
        }
        
        if registers.register_vulnerabilityPosition {
            guidance.append("- VULNERABILITY POSITION: High emotion and explanation are present. Maintain single emotional admission, avoid repetition.")
        }
        
        if registers.register_refusalPosition {
            guidance.append("- REFUSAL POSITION: Block explanation and justification. Prefer ambiguity and implication over statement.")
        }
        
        if registers.register_closurePosition {
            guidance.append("- CLOSURE POSITION: Maintain finality without proof. No evidence or justification needed.")
        }
        
        if registers.register_stabilizationPosition {
            guidance.append("- STABILIZATION POSITION: Focus on structure, logistics, responsibility. Avoid drama and spectacle.")
        }
        
        if guidance.count == 1 {
            // No specific registers, return empty
            return ""
        }
        
        return guidance.joined(separator: "\n")
    }
    
    // MARK: - JSON Cleaning Helpers
    
    /// Clean JSON content by removing markdown code blocks and extra formatting
    private func cleanJSONContent(_ content: String) -> String {
        var cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code block markers (```json ... ``` or ``` ... ```)
        // Be more aggressive - handle multiple layers of markdown
        while cleaned.hasPrefix("```") {
            // Find the first newline after ```
            if let firstNewline = cleaned.firstIndex(of: "\n") {
                cleaned = String(cleaned[cleaned.index(after: firstNewline)...])
            } else if cleaned.hasPrefix("```json") {
                cleaned = String(cleaned[cleaned.index(cleaned.startIndex, offsetBy: 7)...])
            } else if cleaned.hasPrefix("```JSON") {
                cleaned = String(cleaned[cleaned.index(cleaned.startIndex, offsetBy: 7)...])
            } else {
                cleaned = String(cleaned[cleaned.index(cleaned.startIndex, offsetBy: 3)...])
            }
        }
        
        // Remove trailing backticks
        while cleaned.hasSuffix("```") {
            let endIndex = cleaned.index(cleaned.endIndex, offsetBy: -3)
            cleaned = String(cleaned[..<endIndex])
        }
        
        // Remove any remaining backticks
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        
        // Remove leading/trailing whitespace and newlines
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to find JSON object boundaries if content is wrapped in text
        // Look for the first { and last } to extract just the JSON
        if let jsonStart = cleaned.firstIndex(of: "{"),
           let jsonEnd = cleaned.lastIndex(of: "}"),
           jsonStart < jsonEnd {
            cleaned = String(cleaned[jsonStart...jsonEnd])
        }
        
        return cleaned
    }
    
    /// Extract JSON from text that might contain other content
    private func extractJSONFromText(_ text: String) -> String? {
        // Strategy 1: Try to find JSON object boundaries (handle nested braces correctly)
        if let startIndex = text.firstIndex(of: "{"),
           let endIndex = text.lastIndex(of: "}"),
           startIndex < endIndex {
            let jsonString = String(text[startIndex...endIndex])
            
            // Validate it's valid JSON by trying to parse it
            if let data = jsonString.data(using: .utf8),
               (try? JSONSerialization.jsonObject(with: data)) != nil {
                return jsonString
            }
            
            // Try cleaning it first
            let cleaned = cleanJSONContent(jsonString)
            if let data = cleaned.data(using: .utf8),
               (try? JSONSerialization.jsonObject(with: data)) != nil {
                return cleaned
            }
            
            // Strategy 1b: Try to find balanced braces (handle nested objects)
            var braceCount = 0
            var balancedStart: String.Index? = nil
            
            for (index, char) in text.enumerated() {
                let stringIndex = text.index(text.startIndex, offsetBy: index)
                if char == "{" {
                    if braceCount == 0 {
                        balancedStart = stringIndex
                    }
                    braceCount += 1
                } else if char == "}" {
                    braceCount -= 1
                    if braceCount == 0, let start = balancedStart {
                        let balancedJson = String(text[start...stringIndex])
                        if let data = balancedJson.data(using: .utf8),
                           (try? JSONSerialization.jsonObject(with: data)) != nil {
                            return balancedJson
                        }
                        break
                    }
                }
            }
        }
        
        // Strategy 2: Try to find JSON array boundaries (in case response is just an array)
        if let startIndex = text.firstIndex(of: "["),
           let endIndex = text.lastIndex(of: "]"),
           startIndex < endIndex {
            let jsonString = String(text[startIndex...endIndex])
            
            if let data = jsonString.data(using: .utf8),
               let array = try? JSONSerialization.jsonObject(with: data) as? [Any],
               !array.isEmpty {
                // Wrap array in object with "suggestions" key
                let wrapped = ["suggestions": array]
                if let wrappedData = try? JSONSerialization.data(withJSONObject: wrapped),
                   let wrappedString = String(data: wrappedData, encoding: .utf8) {
                    return wrappedString
                }
            }
        }
        
        // Strategy 3: Try to find JSON object that contains "suggestions" key
        // Look for the opening brace before "suggestions" and find matching closing brace
        if let suggestionsIndex = text.range(of: "\"suggestions\"") {
            // Find the opening brace before "suggestions"
            let beforeSuggestions = String(text[..<suggestionsIndex.lowerBound])
            if let lastBrace = beforeSuggestions.lastIndex(of: "{") {
                // Now find the matching closing brace
                var braceCount = 1
                var searchIndex = suggestionsIndex.upperBound
                
                while searchIndex < text.endIndex && braceCount > 0 {
                    let char = text[searchIndex]
                    if char == "{" {
                        braceCount += 1
                    } else if char == "}" {
                        braceCount -= 1
                        if braceCount == 0 {
                            let jsonString = String(text[lastBrace...searchIndex])
                            if let data = jsonString.data(using: .utf8),
                               (try? JSONSerialization.jsonObject(with: data)) != nil {
                                return jsonString
                            }
                            break
                        }
                    }
                    searchIndex = text.index(after: searchIndex)
                }
            }
        }
        
        return nil
    }
    
    // MARK: - A&R Critique Generation
    
    /// Generates A&R-style critiques for suggestions, teaching the user how to improve based on their submitted text
    private func generateARCritiques(for suggestions: [RapSuggestion], userText: String, narrative: NarrativeAnalysis) async -> [RapSuggestion] {
        guard !suggestions.isEmpty && !userText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return suggestions
        }
        
        // Only generate critiques for Model G (Gunna mode)
        guard narrative.generatorPolicy.artistBias == .gunna else {
            return suggestions
        }
        
        var updatedSuggestions: [RapSuggestion] = []
        
        // Generate critique for the first suggestion (most relevant)
        // We can expand this later to generate critiques for all suggestions if needed
        if let firstSuggestion = suggestions.first {
            let critique = await generateSingleARCritique(userText: userText, suggestion: firstSuggestion, narrative: narrative)
            
            // Apply critique to first suggestion
            var updatedFirst = firstSuggestion
            updatedFirst.arCritique = critique
            updatedSuggestions.append(updatedFirst)
            
            // Add remaining suggestions without critiques (or with shared critique)
            for suggestion in suggestions.dropFirst() {
                updatedSuggestions.append(suggestion)
            }
        } else {
            updatedSuggestions = suggestions
        }
        
        return updatedSuggestions
    }
    
    /// Generates a single A&R critique analyzing the user's text and teaching improvement
    private func generateSingleARCritique(userText: String, suggestion: RapSuggestion, narrative: NarrativeAnalysis) async -> String {
        guard let apiKey = self.apiKey else {
            return "A&R critique unavailable (API key missing)."
        }
        
        let systemMessage = """
        You are an A&R (Artist & Repertoire) executive providing constructive, educational feedback to help an aspiring rapper improve their craft.
        
        Your job is to:
        1. Analyze the user's submitted rap text
        2. Identify specific areas for improvement (rhyme, flow, imagery, wordplay, luxury specificity, etc.)
        3. Provide constructive, actionable feedback that teaches them how to improve
        4. Reference the AI-generated suggestion as an example of professional-level execution
        5. Be encouraging but direct - help them understand what separates amateur from professional
        
        Focus on:
        - Rhyme quality and variety (end rhymes, internal rhymes, slant rhymes)
        - Flow and cadence (syllable count, rhythm, musicality)
        - Imagery and specificity (concrete details vs. vague descriptions)
        - Wordplay and language arts techniques (similes, metaphors, idioms, pop culture references)
        - Luxury/status signals (specificity, brand placement, amounts)
        - Structure and coherence (how lines connect, narrative flow)
        
        Write in a professional, encouraging A&R tone. Be specific with examples from their text.
        Keep it concise (3-5 sentences max).
        """
        
        let userPrompt = """
        User's submitted text:
        \(userText)
        
        AI-generated professional suggestion (example of quality):
        \(suggestion.text)
        
        Provide an A&R critique that:
        1. Identifies 2-3 specific weaknesses in the user's text
        2. Explains how the AI suggestion demonstrates better technique
        3. Gives actionable advice on how to improve
        
        Be direct but encouraging. Help them understand what to work on.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7,
            "max_tokens": 300
        ]
        
        do {
            let url = URL(string: "\(self.baseURL)/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                return "A&R critique generation failed. Focus on improving rhyme variety, flow, and specificity."
            }
            
            return content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } catch {
            print("⚠️ RapSuggestionAPI: Failed to generate A&R critique: \(error.localizedDescription)")
            return "A&R critique unavailable. Focus on improving rhyme variety, flow, and specificity in your writing."
        }
    }
    
    // MARK: - Dynamic Topic Selection
    
    /// Analyzes context to select 3-5 relevant topics that should be emphasized in this generation
    private func selectRelevantTopics(
        lastLines: [String],
        fullText: String,
        narrative: NarrativeAnalysis,
        currentBarIndex: Int
    ) -> [String] {
        let allText = (lastLines + [fullText]).joined(separator: " ").lowercased()
        
        // Define all available topics with their keywords
        let topicKeywords: [String: [String]] = [
            "Money/Wealth": ["money", "cash", "bands", "racks", "hundred", "thousand", "million", "rich", "broke", "poor", "stack"],
            "Cars": ["car", "benz", "bentley", "porsche", "urus", "lambo", "rolls", "maybach", "vette", "whip", "coupe"],
            "Watches & Jewelry": ["watch", "rolex", "rollie", "ap", "patek", "diamond", "ice", "chain", "necklace", "ring", "vvs"],
            "Hotels/Locations": ["hotel", "penthouse", "mansion", "resort", "suite", "crib", "atlanta", "dubai", "miami", "la"],
            "Fashion Brands": ["gucci", "versace", "louis", "dior", "prada", "nike", "jordan", "yeezy", "chanel", "hermes"],
            "Travel/Luxury Lifestyle": ["jet", "plane", "flight", "travel", "bora bora", "spain", "philippines", "private"],
            "Success/Dominance": ["top", "win", "winning", "boss", "king", "god", "drip god", "pushin' p", "best"],
            "Food/Dining": ["lunch", "dinner", "restaurant", "steak", "sushi", "two hundred for lunch"],
            "Violence/Weapons": ["chopper", "stick", "glock", "gun", "hit", "whacked", "tec", "nine", "snub"],
            "Family/Loyalty": ["mama", "cousin", "brother", "family", "loyalty", "real", "never ratted"],
            "Street Life/Hustling": ["trap", "block", "hood", "hustle", "grind", "street", "neighborhood"],
            "Colors": ["blue", "red", "black", "white", "yellow", "green", "rose gold", "gray"],
            "Body Parts": ["wrist", "thumb", "toe", "tooth", "finger", "neck", "arm"],
            "Time References": ["morning", "month", "day", "time", "twenty-four", "hunnid racks"],
            "Cities/Locations": ["atlanta", "dubai", "miami", "la", "argentina", "california", "spain", "philippines"],
            "Numbers/Quantities": ["two hundred", "twenty-five thousand", "hundred thousand", "sixty bands", "millions", "ten", "five"],
            "Drip/Freshness": ["drip", "fresh", "clean", "cleaner", "drip god", "freshest", "cleanest"],
            "Bags/Pockets": ["bag", "pocket", "purse", "wallet", "duffel", "pockets", "nachos"],
            "Chains/Jewelry": ["chain", "chains", "necklace", "quarter milli", "eliantte", "rockstar"],
            "Pull/Push Actions": ["pull up", "pushin'", "push", "pull", "brinks", "porsche", "maybach"],
            "Flex/Show": ["flex", "show", "shows", "showin'", "litty", "sold out", "fashion show"],
            "Real/Fake": ["real", "realer", "real one", "really", "authentic", "genuine"],
            "Ball/Sport": ["ball", "ballin'", "basketball", "laker", "hawks", "steve nash", "game"],
            "Work/Grind": ["work", "workin'", "grind", "grindin'", "hard work", "harder", "muscle"],
            "Game/Play": ["play", "player", "games", "playin'", "arcade", "toy"],
            "Clean/Fresh": ["clean", "cleaner", "cleanest", "wash", "clorox", "mop", "fresh", "freshest"],
            "Drug References": ["lean", "codeine", "biscotti", "weed", "perc", "addy", "geekin'", "sippin'", "smokin'"],
            "Women as Prizes": ["bitch", "bitches", "hoes", "redbone", "bought", "trophy", "prize"]
        ]
        
        // Score each topic based on presence in text
        var topicScores: [String: Int] = [:]
        for (topic, keywords) in topicKeywords {
            var score = 0
            for keyword in keywords {
                if allText.contains(keyword) {
                    score += 1
                }
            }
            topicScores[topic] = score
        }
        
        // Also check narrative themes
        let narrativeText = (narrative.primaryThemes + narrative.secondaryThemes).joined(separator: " ").lowercased()
        for (topic, keywords) in topicKeywords {
            for keyword in keywords {
                if narrativeText.contains(keyword) {
                    topicScores[topic, default: 0] += 2 // Higher weight for narrative themes
                }
            }
        }
        
        // Select topics: prioritize those with scores, but also ensure diversity
        var selected: [String] = []
        
        // First, add topics that are already present (to continue the theme)
        let presentTopics = topicScores.filter { $0.value > 0 }.sorted { $0.value > $1.value }
        selected.append(contentsOf: presentTopics.prefix(2).map { $0.key })
        
        // Then, add topics that are NOT present (to add variety)
        let absentTopics = topicScores.filter { $0.value == 0 }.keys.shuffled()
        selected.append(contentsOf: absentTopics.prefix(3))
        
        // Ensure we have 3-5 topics total
        if selected.count < 3 {
            let allTopics = Array(topicKeywords.keys).shuffled()
            for topic in allTopics {
                if !selected.contains(topic) {
                    selected.append(topic)
                    if selected.count >= 5 { break }
                }
            }
        }
        
        return Array(selected.prefix(5))
    }
    
    /// Returns formatted examples and guidance for a specific topic
    private func getTopicExamples(topic: String) -> String {
        let examples: [String: String] = [
            "Money/Wealth": """
            💰 MONEY/WEALTH (REQUIRED):
            - Use specific amounts: "I had two hundred for lunch", "Twenty-five thousand for a jacket"
            - Reference cash/bands: "Cash runnin' over", "Throw the racks up", "Got racks all inside the safe"
            - Status indicators: "I got a hundred thousand in my pocket", "I been gettin' millions"
            """,
            "Cars": """
            🚗 CARS (REQUIRED):
            - Specific luxury cars: "911 Porsche", "Bentley B", "Urus", "Maybach", "Rolls"
            - Car actions: "Ridin' the Rolls", "Double park the Urus", "Top off the Benz"
            - Car details: "trunk is a hood", "push-start", "no space"
            """,
            "Watches & Jewelry": """
            ⌚ WATCHES & JEWELRY (REQUIRED):
            - Specific watches: "AP on my wrist", "Rollie", "Richard Mille"
            - Diamonds/ice: "diamonds on my thumb", "I put diamonds on a redbone", "VVS's", "ice"
            - Chains: "my necklace glist'", "chain cost a quarter milli'", "Eliantte chain"
            """,
            "Hotels/Locations": """
            🏨 HOTELS/LOCATIONS (REQUIRED):
            - Specific locations: "penthouse", "resort", "mansion", "presidential suite"
            - Cities: "Atlanta", "Dubai", "Miami", "LA", "Argentina", "California"
            - Travel: "Bora Bora", "Spain", "Philippines", "private plane"
            """,
            "Fashion Brands": """
            👔 FASHION BRANDS (REQUIRED):
            - Luxury brands: "Gucci", "Versace", "Louis V", "Dior", "Prada", "Chanel", "Hermès"
            - Streetwear: "Nike", "Jordan", "Yeezy"
            - Brand + detail: "louis v trunk", "versace bifocals", "prada on my collar"
            """,
            "Travel/Luxury Lifestyle": """
            ✈️ TRAVEL/LUXURY LIFESTYLE (REQUIRED):
            - Private jets: "big jet twenty seater", "private plane", "Countin' cash on a private plane"
            - International: "Eight hour flight out to Spain", "When I fuck in Dubai", "Bora Bora"
            - Luxury travel: "Travel like a tourist", "The jet got speed"
            """,
            "Success/Dominance": """
            👑 SUCCESS/DOMINANCE (REQUIRED):
            - Status: "I'm pushin' P, that's my favorite alphabet", "Fresh and I'm blessed, that's why I'm the drip god"
            - Winning: "We keep winning 'cause we workin' harder", "Perfectly aim for the top"
            - Authority: "You can hear the money in my voice", "My shit flowin', havin' plenty of bars"
            """,
            "Food/Dining": """
            🍽️ FOOD/DINING (REQUIRED):
            - Expensive dining: "I had two hundred for lunch", "200 FOR LUNCH"
            - Luxury food references when contextually appropriate
            """,
            "Violence/Weapons": """
            🔫 VIOLENCE/WEAPONS (REQUIRED when contextually appropriate):
            - Weapons: "chopper", "stick" (gun), "nine and a snubnose", "Dracos, AR's, Glocks"
            - Actions: "I drop a hit", "You get whacked with that TEC", "put in the work for your side"
            """,
            "Family/Loyalty": """
            👨‍👩‍👧‍👦 FAMILY/LOYALTY (REQUIRED when contextually appropriate):
            - Family: "Mama ain't stressing", "I bought my mama a crib", "I'm gon' free my cousin"
            - Loyalty: "I never ratted", "My brother's keeper", "I try to save my niggas"
            """,
            "Street Life/Hustling": """
            🏘️ STREET LIFE/HUSTLING (REQUIRED when contextually appropriate):
            - Trap life: "Neighborhood trap", "we trapped on the block", "Got the trap jumpin' like crickets"
            - Hustling: "I trapped for a living", "spin the block", "Got this shit out the ground and the mud"
            """,
            "Colors": """
            🎨 COLORS (REQUIRED):
            - Color + object: "A lot of blue faces", "rose gold", "gray and black", "Black on black new Phantom"
            - Specific colors: "yellow", "white", "green", "sippin' red"
            """,
            "Body Parts": """
            💎 BODY PARTS (REQUIRED):
            - Jewelry on body: "diamonds on my thumb", "AP on my wrist", "diamonds on her toes"
            - Specific placements: "It's just a diamond on a nigga tooth", "Middle finger ring"
            """,
            "Time References": """
            ⏰ TIME REFERENCES (REQUIRED):
            - Timing: "Hoppin' on the plane, I'm landin' in the mornin'", "Twenty-four shows in a month"
            - Time expressions: "My next check booking gon' be a hunnid racks", "Really all the time"
            """,
            "Cities/Locations": """
            🌍 CITIES/LOCATIONS (REQUIRED):
            - Specific cities: "Atlanta where these hoes", "When I fuck in Dubai", "Argentina and California"
            - International: "Eight hour flight out to Spain", "party with some bitches in the Philippines"
            """,
            "Numbers/Quantities": """
            🔢 NUMBERS/QUANTITIES (REQUIRED):
            - Specific amounts: "I had two hundred for lunch", "Twenty-five thousand for a jacket"
            - Large numbers: "I got a hundred thousand in my pocket", "I been gettin' millions"
            - Quantities: "I got ten bad bitches", "more than a hundred hoes", "Got five bitches"
            """,
            "Drip/Freshness": """
            💧 DRIP/FRESHNESS (REQUIRED):
            - Status: "Fresh and I'm blessed, that's why I'm the drip god", "Always been the freshest"
            - Clean: "I be cleaner than soap", "Fresh out the fridge", "fresh out the Chase"
            """,
            "Bags/Pockets": """
            👜 BAGS/POCKETS (REQUIRED):
            - Pockets: "Pockets got nachos", "I'm chubby, but shit, my pockets in shape", "I got a hundred thousand in my pocket"
            - Bags: "Gotta get a duffel bag for the cash", "I'm around the world, securin' me a bag"
            - Wallets: "Mama thanked me for her purse", "Two-hundred-fifty in this man purse"
            """,
            "Chains/Jewelry": """
            ⛓️ CHAINS/JEWELRY (REQUIRED):
            - Chains: "I went and got rich, my necklace glist'", "This chain cost a quarter milli'", "ROCKSTAR BIKERS & CHAINS"
            - Specific chains: "Eliantte chain like the bottom of a ship", "shit deeper than a chain"
            """,
            "Pull/Push Actions": """
            🚶 PULL/PUSH ACTIONS (REQUIRED):
            - Pull up: "I'm pushin' P", "Pull up in a Brinks", "Pull up in a Porsche", "Double park the Urus, I'll pull up"
            - Actions: "Pull up to the Maybach", "When I pull up Mulsanne", "Pull up, spin the whole block"
            """,
            "Flex/Show": """
            💪 FLEX/SHOW (REQUIRED):
            - Flexing: "She love when I flex and shop in the mall", "I show you around like I Spy"
            - Shows: "My shows lit, it be more than a hundred hoes", "Sold out shows, this shit litty"
            """,
            "Real/Fake": """
            ✅ REAL/FAKE (REQUIRED):
            - Authenticity: "No realer than this", "I'm real as it get", "We really came from the A"
            - Real status: "Wunna a real one and I ain't changed up", "Keep it real", "real loner"
            """,
            "Ball/Sport": """
            🏀 BALL/SPORT (REQUIRED):
            - Basketball: "Ballin' like a big shot", "I came to ball, Steve Nash", "I been ballin' in LA, feel like a Laker"
            - Sports: "I just left a Hawks game", "Walk in with the drip like Met Gala Ball"
            """,
            "Work/Grind": """
            💼 WORK/GRIND (REQUIRED):
            - Work ethic: "Shit don't come easy, nigga, it's hard work", "We keep winning 'cause we workin' harder"
            - Grinding: "I done made up my mind and done got on my grind", "All I know is grind", "I got on my grind"
            """,
            "Game/Play": """
            🎮 GAME/PLAY (REQUIRED):
            - Player status: "Feel like a player", "These niggas play games like arcade"
            - Playing: "You playin', you gon' be another cold case", "We was in a Bentley B, flowin' up the street, playin' one of our songs"
            """,
            "Clean/Fresh": """
            🧹 CLEAN/FRESH (REQUIRED):
            - Cleanliness: "Always been the freshest, I be cleaner than soap", "I clean up like hands and soap"
            - Fresh: "Fresh out the fridge", "I can fuck 'less she fresh out the bath", "Wash up with Clorox"
            """,
            "Drug References": """
            💊 DRUG REFERENCES (REQUIRED when contextually appropriate):
            - Lean: "Barely rest so I'm sippin' the 'Tuss", "Cup full of codeine", "I'm geekin' on codeine"
            - Weed: "I blow Biscotti clouds of the bud", "Roll up Biscotti", "Smokin' this 'Scotti"
            - Percs: "I popped a pill and now my head gone", "I pop a lil Perc' for breakfast"
            - Addys: "I'm drinkin' the codeine whenever I swallow a Addy", "We geekin' up on the Addy"
            """,
            "Women as Prizes": """
            👑 WOMEN AS PRIZES (REQUIRED):
            - Status symbols: "I put diamonds on a redbone", "I got a old bitch", "I bought my new bitch a Rollie"
            - Transactional: "Bought the bitch the Hermès crop", "One hundred my bitch", "My shows lit, it be more than a hundred hoes"
            - Prizes: "I got ten bad bitches", "Got five bitches rollin' off the dope at the penthouse"
            """
        ]
        
        return examples[topic] ?? "\(topic): Incorporate this topic naturally into your bars using CSV examples."
    }
}

// MARK: - OpenAI Response Models

struct OpenAIResponse: Codable {
    let choices: [Choice]
    let usage: Usage?
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
    
    struct Usage: Codable {
        let promptTokens: Int?
        let completionTokens: Int?
        let totalTokens: Int?
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

// MARK: - Errors

enum RapAPIError: LocalizedError {
    case missingAPIKey
    case requestFailed
    case rateLimitExceeded(retryAfterSeconds: Int?) // 429 Too Many Requests
    case serverError(statusCode: Int, message: String?) // Non-2xx with optional OpenAI error body message
    case invalidResponse
    case emptyResponse
    case jsonParsingFailed(String) // Include the actual error message
    case silence(CriticCommentary) // API returned silence response
    case modelGCoreFailed // Model G Core returned only fallback bars (LLM calls failed)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key not found. Please add your API key in settings."
        case .requestFailed:
            return "API request failed. Please check your internet connection and try again."
        case .rateLimitExceeded(let retryAfter):
            let wait = retryAfter ?? 60
            return "Too many requests. Please wait \(wait) seconds and try again, or check your OpenAI usage/limits."
        case .serverError(let code, let message):
            if let msg = message?.trimmingCharacters(in: .whitespacesAndNewlines), !msg.isEmpty {
                return "API error (\(code)): \(msg)"
            }
            return "API request failed (status \(code)). Please check your connection and API key, then try again."
        case .invalidResponse:
            return "The AI response couldn't be read because it isn't in the correct format. This is usually a temporary issue - please try again."
        case .emptyResponse:
            return "No suggestions were generated. The API returned an empty response. Try adjusting your verse or settings."
        case .jsonParsingFailed(_):
            return "The AI response format was unexpected. Please try again. If this persists, the issue has been logged for review."
        case .modelGCoreFailed:
            return "Model G Core could not generate. Check your API key in settings, or try turning off Model G Core in Model Preferences."
        case .silence(let commentary):
            return "\(commentary.explanation) \(commentary.guidance)"
        }
    }
    
    /// Short message for in-app notification (toast/banner).
    var inAppNotificationMessage: String {
        switch self {
        case .missingAPIKey:
            return "API key missing. Add your OpenAI key in Settings."
        case .requestFailed:
            return "Request failed. Check your connection and try again."
        case .rateLimitExceeded(let retryAfter):
            let wait = retryAfter ?? 60
            return "Too many requests. Wait \(wait)s and try again, or check your API usage."
        case .serverError(let code, _):
            return "Server error (\(code)). Try again in a moment."
        case .invalidResponse:
            return "Response was invalid. Try again."
        case .emptyResponse:
            return "No suggestions came back. Try again."
        case .jsonParsingFailed:
            return "Response format issue. Try again."
        case .modelGCoreFailed:
            return "Model G couldn’t generate. Check Settings or try again."
        case .silence:
            return "" // Not shown as error toast
        }
    }
}

// MARK: - In-app API error notification
// Post this when an API error occurs so the UI can show a short toast/banner.
extension Notification.Name {
    static let inAppAPIError = Notification.Name("InAppAPIError")
}
struct InAppAPIErrorPayload {
    static let messageKey = "message"
}
