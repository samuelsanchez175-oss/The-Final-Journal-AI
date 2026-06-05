//
//  ModelGLLMService.swift
//  XJournal AI
//
//  Model G Core v1.0 — LLM calls for bar/hook generation.
//

import Foundation

/// Service for Model G Core LLM requests.
class ModelGLLMService {
    static let shared = ModelGLLMService()

    private var apiKey: String? { KeychainHelper.shared.getAPIKey() }
    private let baseURL = "https://api.openai.com/v1"
    /// Gemini text model, used automatically when an "AIza" (Google AI Studio) key is supplied.
    private let geminiModel = "gemini-2.5-flash"
    private let anthropicModel = "claude-3-5-sonnet-latest"  // configurable; current Claude model

    enum LLMProvider { case openAI, gemini, anthropic }
    static func provider(forKey key: String) -> LLMProvider {
        if key.hasPrefix("AIza") { return .gemini }
        if key.hasPrefix("sk-ant-") { return .anthropic }
        return .openAI
    }

    private init() {}

    /// Generate N bar candidates in one request. Returns raw line strings.
    func generateBarCandidates(count: Int, context: GenerationContext) async throws -> [String] {
        let prompt = buildBarCandidatesPrompt(count: count, context: context)
        let text = try await postChat(
            system: "You are Model G. Output ONLY the requested number of bar options, one per line. No numbering, labels, or explanations.",
            user: prompt, maxTokens: 700, temperature: 0.7, jsonMode: false
        )
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .prefix(count)
        return Array(lines)
    }

    /// Generate a hook.
    func generateHook(context: GenerationContext) async throws -> String {
        let params = context.directedParams
        let layer = context.luxuryLayer ?? .empty
        let signalBlock = context.signalAxes.map { "\n" + signalDirective($0) } ?? ""
        let themeBlock = context.themeContext.map { themeDirective($0) } ?? ""
        let prompt = """
        Generate a 1-2 line HOOK for a melodic trap song.
        Theme: \(context.intent.theme)
        Tone: \(context.intent.tone.rawValue)
        Direction: \(controlSurfaceDirection(params))
        Signal volume: \(context.styleProfile.signalVolume.rawValue) (\(volumeInstruction(context.styleProfile.signalVolume)))
        Luxury layers:
        - Brand: \(joinedOrDash(layer.brands))
        - Spec: \(joinedOrDash(layer.specs))
        - Environment: \(joinedOrDash(layer.environments))
        - Provenance/Acquisition: \(joinedOrDash(layer.provenance))
        - Archive reference: \(joinedOrDash(layer.archives))
        Requirements: 6-8 syllables per line, minimal chant, repetition structure.
        Weave layers naturally; do not list them mechanically.\(themeBlock)\(signalBlock)
        Output ONLY the hook lines, nothing else.
        """

        return (try await postChat(
            system: "You are Model G. Output only the hook lines.",
            user: prompt, maxTokens: 80, temperature: 0.7, jsonMode: false
        )).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Model G v3 — planned single-call verse

    /// JSON completion for Human Critic and other structured side calls.
    func fetchJSONCompletion(system: String, user: String, maxTokens: Int = 520) async throws -> String {
        try await postChat(system: system, user: user, maxTokens: maxTokens, temperature: 0.65, jsonMode: true)
    }

    // MARK: - Ghost Bar (Live tier)

    /// Ghost (Live tier): up to 3 single end-rhyme words for the next line that rhyme with `rhymeWith` and fit `topic`.
    func ghostRhymes(rhymeWith: String, topic: String) async throws -> [String] {
        let system = "You are Model G's rhyme helper. Output ONLY 3 single words, comma-separated, that rhyme with the given word and fit the topic. No sentences, no punctuation other than commas."
        let user = "Rhyme with: \(rhymeWith). Topic: \(topic). 3 words:"
        let text = try await postChat(system: system, user: user, maxTokens: 24, temperature: 0.8, jsonMode: false)
        return text.split(whereSeparator: { $0 == "," || $0 == "\n" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    /// Shared chat-completion call. Returns the assistant message content (JSON string when jsonMode).
    private func postChat(system: String, user: String, maxTokens: Int, temperature: Double, jsonMode: Bool) async throws -> String {
        guard let key = apiKey else { throw ModelGLLMError.missingAPIKey }
        switch Self.provider(forKey: key) {
        case .gemini:
            return try await postGemini(key: key, system: system, user: user, maxTokens: maxTokens, temperature: temperature, jsonMode: jsonMode)
        case .anthropic:
            return try await postAnthropic(key: key, system: system, user: user, maxTokens: maxTokens, temperature: temperature, jsonMode: jsonMode)
        case .openAI:
            break  // OpenAI body below (unchanged)
        }
        var body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user]
            ],
            "temperature": temperature,
            "max_tokens": maxTokens
        ]
        if jsonMode { body["response_format"] = ["type": "json_object"] }

        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 429 {
            let headers = Dictionary(uniqueKeysWithValues: http.allHeaderFields.compactMap { k, v -> (String, String)? in
                guard let key = k as? String, let val = v as? String else { return nil }
                return (key.lowercased(), val)
            })
            throw ModelGLLMError.rateLimitExceeded(retryAfterSeconds: headers["retry-after"].flatMap { Int($0) })
        }
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            #if DEBUG
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ [ModelG OpenAI] HTTP \(status): \(String(data: data, encoding: .utf8)?.prefix(700) ?? "<no body>")")
            #endif
            throw ModelGLLMError.requestFailed
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let content = choices?.first?["message"] as? [String: Any]
        return (content?["content"] as? String) ?? ""
    }

    /// Gemini (Google AI Studio) backend — used automatically when the key starts with "AIza".
    /// Lets Model G run on a Gemini key (e.g. reused from another project) with no OpenAI key.
    private func postGemini(key: String, system: String, user: String,
                            maxTokens: Int, temperature: Double, jsonMode: Bool) async throws -> String {
        // Disable 2.5 "thinking" — it otherwise consumes the output budget and truncates the verse.
        var generationConfig: [String: Any] = ["temperature": temperature, "maxOutputTokens": maxTokens,
                                                "thinkingConfig": ["thinkingBudget": 0]]
        if jsonMode { generationConfig["responseMimeType"] = "application/json" }
        let body: [String: Any] = [
            "system_instruction": ["parts": [["text": system]]],
            "contents": [["role": "user", "parts": [["text": user]]]],
            "generationConfig": generationConfig
        ]
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(geminiModel):generateContent?key=\(key)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 429 {
            throw ModelGLLMError.rateLimitExceeded(retryAfterSeconds: nil)
        }
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            #if DEBUG
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ [ModelG Gemini] HTTP \(status): \(String(data: data, encoding: .utf8)?.prefix(700) ?? "<no body>")")
            #endif
            throw ModelGLLMError.requestFailed
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let candidates = json?["candidates"] as? [[String: Any]]
        let content = candidates?.first?["content"] as? [String: Any]
        let parts = content?["parts"] as? [[String: Any]]
        return (parts?.first?["text"] as? String) ?? ""
    }

    /// Anthropic (Claude) backend — used automatically when the key starts with "sk-ant-".
    private func postAnthropic(key: String, system: String, user: String,
                               maxTokens: Int, temperature: Double, jsonMode: Bool) async throws -> String {
        let userContent = jsonMode ? user + "\n\nRespond with valid JSON only — no prose." : user
        let body: [String: Any] = [
            "model": anthropicModel,
            "max_tokens": maxTokens,
            "system": system,
            "temperature": temperature,
            "messages": [["role": "user", "content": userContent]]
        ]
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 429 {
            throw ModelGLLMError.rateLimitExceeded(retryAfterSeconds: nil)
        }
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            #if DEBUG
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ [ModelG Anthropic] HTTP \(status): \(String(data: data, encoding: .utf8)?.prefix(700) ?? "<no body>")")
            #endif
            throw ModelGLLMError.requestFailed
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let content = json?["content"] as? [[String: Any]]
        return content?.compactMap { $0["text"] as? String }.joined() ?? ""
    }

    /// v3 step 1 — plan the verse (central image, angle, anchor rhymes).
    func generateVersePlan(context: GenerationContext) async throws -> VersePlan {
        let theme = context.themeContext
        let axesLine = context.signalAxes.map {
            "Voice: \($0.authorityPosture.rawValue) authority to \($0.audienceScope.rawValue), exposure \($0.exposureRisk.rawValue)."
        } ?? ""
        let user = """
        Plan a 16-bar melodic trap verse. JSON only.
        Theme: \(theme?.themeName ?? context.intent.theme) (tone: \(theme?.emotionalTone ?? context.intent.tone.rawValue))
        Direction: \(context.intent.theme)
        \(axesLine)
        Return JSON exactly: {"centralImage": "core image/motif", "angle": "strategic angle in a phrase", "anchorRhymes": ["sound1", "sound2", "sound3"]}
        """
        let raw = try await postChat(
            system: "You are Model G's planning step. Respond ONLY with valid JSON.",
            user: user, maxTokens: 220, temperature: 0.6, jsonMode: true
        )
        guard let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return .empty
        }
        return VersePlan(
            centralImage: obj["centralImage"] as? String ?? "",
            angle: obj["angle"] as? String ?? "",
            anchorRhymes: (obj["anchorRhymes"] as? [String]) ?? []
        )
    }

    /// v3 step 2 — generate the whole verse (hook + 16 bars) in one call, conditioned on the plan.
    func generateFullVerse(plan: VersePlan, arcShape: String, context: GenerationContext,
                           temperature: Double = 0.8,
                           corpusExemplars: [String] = [], corpusVocab: [String] = [],
                           inspiration: Double = 0.4) async throws -> (hook: String, bars: [String]) {
        let layer = context.luxuryLayer ?? .empty
        let themeBlock = context.themeContext.map { themeDirective($0) } ?? ""
        let voiceBlock = context.signalAxes.map { "\n" + signalDirective($0) } ?? ""
        let inspirationLine = ModelGEnvironment.originalityBias < 0.5
            ? "Inspiration: be grounded in the culture — reference music, brands, places, slang and play on familiar phrases; borrow the genre's idioms. Clever and referential beats sterile-original."
            : "Inspiration: lean fresh and novel, but stay grounded in the culture — references and wordplay over invented-from-nothing lines."
        let palette = LexiconStore.shared.referencePalette()
        let referencesBlock = palette.isEmpty ? "" :
            "\nSpecific references you MAY draw on (pick 1-3 that genuinely fit the feeling; never force, never list them): \(palette.joined(separator: ", "))."
        let beatBlock = beatDirective(context)
        let syllRule: String
        if let lo = context.syllableMin, let hi = context.syllableMax {
            syllRule = "between \(lo) and \(hi) syllables per bar — sit in the pocket"
        } else if context.musicalBPM != nil {
            syllRule = "around \(context.syllableTarget) syllables per bar — sit in the pocket at this tempo"
        } else {
            syllRule = "8-10 syllables MAX"
        }
        // Example-based targeting (roadmap §2): models match length by example better than by count.
        let exampleLine = context.existingBars.min {
            abs(SyllableEngine.lineSyllableCount($0) - context.syllableTarget) <
            abs(SyllableEngine.lineSyllableCount($1) - context.syllableTarget)
        }
        let exampleBlock = exampleLine.map { "\nMatch the rhythm/length of a line like: \"\($0)\"" } ?? ""
        // End-rhyme cadence ("Lines per rhyme" control): hold the same ending rhyme for N bars before switching.
        // Soft hints don't hold — gpt-4o defaults to 2-bar couplets — so phrase it as a strict scheme with a concrete
        // example and an explicit "do not fall back to couplets", plus the target count of distinct end-rhyme sounds.
        let rhymeCadence: String = {
            guard let n = context.directedParams?.minEndRhymeLines, n >= 2 else { return "" }
            if n == 2 {
                return "\nEND-RHYME SCHEME (strict): rhyme in couplets — bars 1&2 share an ending rhyme, bars 3&4 a new one, and so on (AABB CCDD …)."
            }
            let example: String
            switch n {
            case 4: example = "bars 1-4 all end on ONE rhyme (e.g. -ight: night / sight / ignite / tonight), bars 5-8 a DIFFERENT rhyme, and so on"
            case 6: example = "bars 1-6 all end on ONE rhyme, bars 7-12 a DIFFERENT rhyme, and so on"
            default: example = "bars 1-8 all end on ONE rhyme, bars 9-16 a DIFFERENT rhyme"
            }
            return "\nEND-RHYME SCHEME (strict — this OVERRIDES your default): hold the SAME ending-rhyme sound for \(n) bars in a row, THEN switch to a brand-new rhyme sound for the next \(n) bars. Do NOT fall back to 2-bar couplets. Concretely: \(example). Use only about \(max(2, 16 / n)) distinct end-rhyme sounds across the 16 bars."
        }()
        // Grounding strength scales with the Inspiration slider (1 - originality). High = lean hard
        // on the vault; low = loose flavor only. Show all retrieved exemplars (retriever capped k).
        let corpusExemplarBlock: String = {
            guard !corpusExemplars.isEmpty else { return "" }
            let lines = corpusExemplars.map { "• \($0)" }.joined(separator: "\n")
            let directive: String
            if inspiration >= 0.66 {
                directive = "REFERENCE BARS — your BLUEPRINT. Echo their cadence, slang, imagery and phrasing closely and lean HARD on this exact style; a strong family resemblance is intended (reword, never copy verbatim):"
            } else if inspiration <= 0.33 {
                directive = "REFERENCE BARS (loose flavor only — diverge from these, do NOT echo them):"
            } else {
                directive = "REFERENCE BARS (study the craft, cadence and vocabulary — DO NOT copy; paraphrase/blend):"
            }
            return "\n\n\(directive)\n\(lines)"
        }()
        let corpusVocabBlock: String = corpusVocab.isEmpty ? "" :
            "\nVOCAB PALETTE (weave in naturally, only if it fits): \(corpusVocab.prefix(12).joined(separator: ", "))"
        let user = """
        Write a melodic trap verse: a 1-2 line HOOK and EXACTLY 16 bars. JSON only.
        Topic: \(context.intent.theme) (tone: \(context.intent.tone.rawValue))
        \(plan.promptText)
        Luxury layers (weave naturally, never list): brands \(joinedOrDash(layer.brands)); specs \(joinedOrDash(layer.specs)); environments \(joinedOrDash(layer.environments)).
        \(arcShape)\(themeBlock)\(voiceBlock)\(beatBlock)
        \(inspirationLine)\(referencesBlock)\(corpusExemplarBlock)\(corpusVocabBlock)
        Rules (strict): each bar SHORT and punchy, \(syllRule) (no wordy/run-on lines); rhyme HARD — multisyllabic and internal, not just line-ends; name something CONCRETE — a specific brand, place, or coded term, not a generic word ("Roley" not "a watch", "the trap" not "the block"), at least 1-2 per verse; do not repeat the same word; imply more than you state; no numbering inside the bar strings.\(rhymeCadence)
        Return JSON exactly: {"hook": "the hook lines", "bars": ["bar 1", "bar 2", "… 16 bars total"]}\(exampleBlock)
        """
        let raw = try await postChat(
            system: "You are Model G. Respond ONLY with valid JSON: a hook and exactly 16 bars. House style and the reference bars take priority over the requested topic when they conflict.",
            user: user, maxTokens: 1400, temperature: temperature, jsonMode: true
        )
        guard let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ("", [])
        }
        let hook = (obj["hook"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let bars = ((obj["bars"] as? [String]) ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return (hook, bars)
    }

    /// Extract beat metadata (BPM/key/scale) from a beat link's title/description text.
    /// Text-only: beat uploads list e.g. "140 BPM C# Minor" in the title. Returns nils when absent.
    func extractBeatMetadata(fromText text: String) async throws -> (bpm: Int?, key: String?, scale: String?) {
        let system = "Extract music beat metadata from a title/description. Respond ONLY with JSON: {\"bpm\": number or null, \"key\": one of C C# D D# E F F# G G# A A# B or null, \"scale\": \"Major\"/\"Minor\"/a mode or null}. Use null when not stated. Normalize: 'Cmin'→key C scale Minor; 'Am'→key A scale Minor; 'F#maj'→key F# scale Major."
        let user = "Title/description:\n\(text)\n\nReturn the JSON."
        let raw = try await postChat(system: system, user: user, maxTokens: 80, temperature: 0.0, jsonMode: true)
        guard let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return (nil, nil, nil)
        }
        let bpm = (obj["bpm"] as? Int)
            ?? (obj["bpm"] as? Double).map { Int($0) }
            ?? (obj["bpm"] as? String).flatMap { Int($0) }
        let key = (obj["key"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let scale = (obj["scale"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (bpm.flatMap { (60...220).contains($0) ? $0 : nil },
                (key?.isEmpty == false) ? key : nil,
                (scale?.isEmpty == false) ? scale : nil)
    }

    private func buildBarCandidatesPrompt(count: Int, context: GenerationContext) -> String {
        let params = context.directedParams
        let layer = context.luxuryLayer ?? .empty
        let selectedTopics = params?.selectedTopics ?? []
        let selectedTones = params?.selectedTones.map(\.rawValue) ?? []
        let worldWords = params?.worldBuildingWords ?? []
        let mustUse = params?.mustUseTokens ?? []
        var cadenceBlock = ""
        if let features = context.flowDNAFeatures {
            let stressLabel = features.stressDensity > 0.5 ? "high" : (features.stressDensity > 0.3 ? "medium" : "low")
            let internalLabel = features.internalRhymeDensity > 0.4 ? "medium-high" : (features.internalRhymeDensity > 0.2 ? "medium" : "low")
            cadenceBlock = """
            Cadence (match this profile): Stress density: \(stressLabel). Internal rhyme: \(internalLabel). Grid: \(features.offbeatEntryRatio > 0.35 ? "conversational" : "tight").
            """
        }
        if context.perBarSyllableTargets != nil {
            cadenceBlock += " This bar target: \(context.syllableTarget) syllables."
        }
        let signalBlock = context.signalAxes.map { "\n" + signalDirective($0) } ?? ""
        let themeBlock = context.themeContext.map { themeDirective($0) } ?? ""
        return """
        Generate exactly \(count) different one-line rap bar options.
        Theme: \(context.intent.theme)
        Tone: \(context.intent.tone.rawValue)
        Direction: \(controlSurfaceDirection(params))
        Selected topics: \(joinedOrDash(selectedTopics))
        Selected tones: \(joinedOrDash(selectedTones))
        World-building words: \(joinedOrDash(worldWords))
        Must-use words: \(joinedOrDash(mustUse))
        Signal volume: \(context.styleProfile.signalVolume.rawValue) (\(volumeInstruction(context.styleProfile.signalVolume)))
        Luxury layers to treat as composition layers (not a list):
        - Brand layer: \(joinedOrDash(layer.brands))
        - Spec layer: \(joinedOrDash(layer.specs))
        - Environment layer: \(joinedOrDash(layer.environments))
        - Provenance/acquisition layer: \(joinedOrDash(layer.provenance))
        - Archive layer (occasional): \(joinedOrDash(layer.archives))
        Target syllables: \(context.syllableTarget) ±2\(cadenceBlock.isEmpty ? "" : "\n\(cadenceBlock)")
        Existing bars for context: \(context.existingBars.suffix(4).joined(separator: " | "))\(themeBlock)\(signalBlock)
        Rules:
        - Every option should consider brand/spec/environment as layered signals.
        - Keep provenance/acquisition language occasional and natural.
        - Archive references should be occasional, not every line.
        Output \(count) lines, one bar per line. No numbering or labels.
        """
    }

    private func controlSurfaceDirection(_ params: DirectedGenerationParams?) -> String {
        guard let params else { return DirectedGenerationParams.defaultUserPromptWhenEmpty }
        let trimmed = params.userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? DirectedGenerationParams.defaultUserPromptWhenEmpty : trimmed
    }

    private func volumeInstruction(_ volume: SignalVolume) -> String {
        switch volume {
        case .loud:
            return "explicit brand signaling is allowed"
        case .subtle:
            return "favor premium specs and environment over explicit brand drops"
        case .mixed:
            return "balance explicit and subtle signaling"
        }
    }

    /// Beat metadata → cadence feel + mood lean. Empty when the entry has no BPM/key.
    /// Maps the entry's BPM (tempo feel) and musical key/scale (major→bright, minor/modes→dark)
    /// onto the corpus's 8-tone mood palette so the verse matches the track.
    private func beatDirective(_ context: GenerationContext) -> String {
        var parts: [String] = []
        if let bpm = context.musicalBPM, bpm > 0 {
            let feel = bpm >= 140 ? "fast — short, clipped bars, double-time pockets"
                     : (bpm <= 85 ? "slow — more room per bar, stretch the melody"
                                  : "mid-tempo — steady pocket")
            parts.append("\(bpm) BPM (\(feel))")
        }
        if let key = context.musicalKey, !key.isEmpty {
            let scale = context.musicalScale ?? ""
            if scale.isEmpty {
                parts.append("key \(key)")
            } else {
                let bright = ["major", "lydian", "ionian", "mixolydian"]
                    .contains { scale.lowercased().contains($0) }
                let mood = bright
                    ? "brighter, assured moods (confident, luxurious, celebratory)"
                    : "darker, tense moods (gritty, paranoid, aggressive, detached)"
                parts.append("key \(key) \(scale) → lean \(mood)")
            }
        }
        return parts.isEmpty ? "" : "\nBeat: " + parts.joined(separator: "; ") + "."
    }

    /// Inject the detected theme: name, emotional tone, jargon palette, and a few-shot anchor.
    private func themeDirective(_ t: ThemeContext) -> String {
        var lines = ["Theme: \(t.themeName) — emotional tone: \(t.emotionalTone)."]
        if !t.jargonPalette.isEmpty {
            lines.append("Draw on this theme's vocabulary where it fits (don't force all): \(t.jargonPalette.joined(separator: ", ")).")
        }
        if let ex = t.example, !ex.isEmpty {
            lines.append("Match the feel of this in-theme line (do NOT copy it): \"\(ex)\"")
        }
        return "\n" + lines.joined(separator: "\n")
    }

    /// Build a compact "voice" directive from the Signal Layer axes so generation
    /// conditions on exposure / social action / register — not just theme and rhyme.
    private func signalDirective(_ axes: SignalAxes) -> String {
        let move: String
        switch axes.socialAction {
        case .flex:     move = "flex — show status or skill through one specific detail, not a list"
        case .warn:     move = "warn — signal a consequence without naming the act"
        case .distance: move = "distance — cool detachment, create separation"
        case .assert:   move = "assert — state it with finality, no need to prove it"
        case .withdraw: move = "withdraw — say less, hold power in restraint"
        case .confess:  move = "confess — admit one real thing, do not over-narrate"
        }
        let exposure: String
        switch axes.exposureRisk {
        case .low:    exposure = "Imply, don't explain. Signal wealth/risk through detail; never justify, never name the act. Over-explaining kills the line."
        case .medium: exposure = "Mostly imply; at most one plain statement. Show more than you tell."
        case .high:   exposure = "Direct is allowed, but still show more than you tell."
        }
        return """
        Voice (stay in character):
        - Posture: \(axes.authorityPosture.rawValue) authority, speaking to \(axes.audienceScope.rawValue).
        - Social move: \(move).
        - Exposure: \(exposure)
        """
    }

    private func joinedOrDash(_ values: [String]) -> String {
        values.isEmpty ? "—" : values.joined(separator: ", ")
    }
}

enum ModelGLLMError: Error {
    case missingAPIKey
    case rateLimitExceeded(retryAfterSeconds: Int?)
    case requestFailed
}
