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

    nonisolated enum LLMProvider: Equatable, Sendable { case openAI, gemini, anthropic }
    nonisolated static func provider(forKey key: String) -> LLMProvider {
        if key.hasPrefix("AIza") { return .gemini }
        if key.hasPrefix("sk-ant-") { return .anthropic }
        return .openAI
    }

    private init() {}

    /// Generate N bar candidates in one request. Returns raw line strings.
    func generateBarCandidates(count: Int, context: GenerationContext) async throws -> [String] {
        if ModelGEnvironment.useLocalMLXAdapter {
            if let localBars = try? await generateLocalMLXBars(
                sectionMode: context.isHook ? "hook" : "verse",
                bars: max(4, min(16, count)),
                context: context
            ), !localBars.isEmpty {
                return Array(localBars.prefix(count))
            }
        }
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
        if ModelGEnvironment.useLocalMLXAdapter {
            if let localBars = try? await generateLocalMLXBars(
                sectionMode: "hook",
                bars: 4,
                context: context
            ), !localBars.isEmpty {
                return localBars.prefix(4).joined(separator: "\n")
            }
        }
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

    /// Calls the local Apple Silicon MLX QLoRA bridge (`POST /api/penwork/generate` on `desk.py`).
    func generateLocalMLXBars(
        sectionMode: String,
        bars: Int,
        context: GenerationContext
    ) async throws -> [String] {
        let base = ModelGEnvironment.localMLXBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: "\(base)/api/penwork/generate") else {
            throw ModelGLLMError.requestFailed
        }
        let bpm: Int = {
            if let b = context.musicalBPM { return b }
            if let d = context.beatFingerprint?.bpm { return Int(d.rounded()) }
            return 140
        }()
        let scale: String = {
            if let k = context.musicalKey, !k.isEmpty {
                if let s = context.musicalScale, !s.isEmpty { return "\(k) \(s)" }
                return k
            }
            return "F minor"
        }()
        let seedLine = context.existingBars.last(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ?? ""
        let payload: [String: Any] = [
            "adapter": "full",
            "voice": ModelGEnvironment.localMLXVoice,
            "bpm": bpm,
            "scale": scale,
            "section_mode": sectionMode,
            "bars": bars,
            "seed_line": seedLine,
            "topic": context.intent.theme,
            "temperature": 0.85,
            "top_p": 0.95
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ModelGLLMError.requestFailed
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              (json["ok"] as? Bool) == true else {
            throw ModelGLLMError.requestFailed
        }
        if let lines = json["lines"] as? [String], !lines.isEmpty {
            return lines
        }
        if let raw = json["raw"] as? String {
            return raw.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        return []
    }

    // MARK: - Model G v3 — planned single-call verse

    /// JSON completion for Human Critic and other structured side calls.
    func fetchJSONCompletion(system: String, user: String, maxTokens: Int = 520) async throws -> String {
        try await postChat(system: system, user: user, maxTokens: maxTokens, temperature: 0.65, jsonMode: true)
    }

    // MARK: - Ghost Bar (Live tier)

    /// Cadence Ghost: punch halves after a comma-breath. Fit `targetSyllables` (±1). Catalog hints first.
    func cadencePunches(setup: String, targetSyllables: Int, catalogHints: [String]) async throws -> [String] {
        let hints = catalogHints.prefix(8).map { "- \($0)" }.joined(separator: "\n")
        let system = """
        You write rap punchlines after a setup that ends in a comma (a breath). \
        Output JSON only: {"punches":["...","..."]}. \
        Each punch is the SECOND HALF only — no setup, no leading comma, no quotes, no artist names. \
        Each punch must be \(max(4, targetSyllables - 1))-\(targetSyllables + 1) syllables. \
        Prefer INTERNAL-TO-END RHYME CHAINS (mosaic / inner rhyme): take the setup's last sound and hit it \
        INSIDE the punch early, then land on the same family at the end. \
        Example: setup "im standing ten toes" → punch "hoes know how i let it go" \
        (toes → hoes/know internally, go at the end). \
        Rank those ahead of end-rhyme-only fillers. Rap diction. 5 punches. Polish catalog hints when they already chain.
        """
        let user = """
        Setup: \(setup)
        Target punch syllables: \(targetSyllables)
        Catalog punches:
        \(hints.isEmpty ? "(none)" : hints)
        Write punches that chain the setup landing internally and at the end.
        """
        let raw = try await postChat(system: system, user: user, maxTokens: 220, temperature: 0.7, jsonMode: true)
        return Self.parsePunchJSON(raw)
    }

    private static func parsePunchJSON(_ raw: String) -> [String] {
        struct Box: Decodable { var punches: [String] }
        if let data = raw.data(using: .utf8), let box = try? JSONDecoder().decode(Box.self, from: data) {
            return box.punches.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        }
        return raw.split(whereSeparator: { $0 == "\n" || $0 == "," })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\"[]")) }
            .filter { $0.split(whereSeparator: \.isWhitespace).count >= 2 }
    }

    /// End rhymes + AI: a full extra set of end words, on top of the on-phone list in `avoid`.
    func ghostRhymes(rhymeWith: String, topic: String, line: String, avoid: [String]) async throws -> [String] {
        let already = avoid.prefix(12).map { "- \($0)" }.joined(separator: "\n")
        let system = """
        You are the ghost on a rapper's shoulder, finding the next end word. \
        Output JSON only: {"words":["..."]}. \
        Give 16 different single words that can end a bar rhyming with the seed. \
        A rhyme is perfect (same stressed vowel and the same ending consonants) or one of these near families: \
        feminine -y (pretty/chelly), same vowel plus P/B/K/G (hip/dick), IY or IH plus T or CH (cheat/reach), \
        line-end IH plus an alveolar stop (shit/militant). \
        A shared vowel with any other ending is not a rhyme. \
        Fit the topic and the line. Concrete words a rapper would say out loud. \
        Skip the seed, spelling twins of the seed, and every word already on the dock. No sentences.
        """
        let user = """
        Seed: \(rhymeWith)
        Topic: \(topic)
        Line: \(line)
        Already on the dock:
        \(already.isEmpty ? "(none)" : already)
        16 more end words the dock does not already have.
        """
        let raw = try await postChat(system: system, user: user, maxTokens: 220, temperature: 0.65, jsonMode: true)
        return Self.parseGhostRhymeWords(raw)
    }

    private static func parseGhostRhymeWords(_ raw: String) -> [String] {
        struct Box: Decodable { var words: [String] }
        let pieces: [String]
        if let data = raw.data(using: .utf8), let box = try? JSONDecoder().decode(Box.self, from: data) {
            pieces = box.words
        } else {
            pieces = raw.split(whereSeparator: { $0 == "," || $0 == "\n" }).map(String.init)
        }
        return pieces
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\"[]")) }
            .filter { !$0.isEmpty && !$0.contains(where: \.isWhitespace) }
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
        var generationConfig: [String: Any] = ["temperature": temperature, "maxOutputTokens": maxTokens]
        if jsonMode { generationConfig["responseMimeType"] = "application/json" }
        let body: [String: Any] = [
            "system_instruction": ["parts": [["text": system]]],
            "contents": [["role": "user", "parts": [["text": user]]]],
            "generationConfig": generationConfig,
            // Rap lyrics — including the user's OWN reference bars injected by v4 — routinely trip
            // Gemini's default filters, which blocks the response (empty candidates) and makes v4
            // fail where v3's cleaner prompt passed. The user supplies the content; don't let safety
            // filters gut a creative-writing tool. (OpenAI/Anthropic have no equivalent per-request knob.)
            "safetySettings": [
                ["category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"]
            ]
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
        let params = context.directedParams
        let recipeSeed = params?.resolvedRecipeSeed ?? ""
        let cageSound = params?.resolvedSemanticSound ?? ""
        let namedSenses = params?.semanticSenses ?? []
        let cookRecipe = !recipeSeed.isEmpty
        let cookCage = !cageSound.isEmpty
        var cookBlock = ""
        var returnJSON = "Return JSON exactly: {\"centralImage\": \"core image/motif\", \"angle\": \"strategic angle in a phrase\", \"anchorRhymes\": [\"sound1\", \"sound2\", \"sound3\"]}"
        if cookRecipe || cookCage {
            var extra: [String] = []
            if cookRecipe {
                extra.append("""
                WORD RECIPE SEED: \(recipeSeed)
                Cook Ohm's neighborhood-news recipe: (1) pick the word (2) parse it for meaning AND rhyme (3) find an outside cultural reference (4) combine into ONE image. Example shape: "working laser and scope / Herculaneum notes". Do not lecture the steps — only cook the image.
                """)
            }
            if cookCage {
                let sensesLine = namedSenses.isEmpty
                    ? "List 3–6 labeled meanings of that sound (e.g. switch = swap / walk / punishment / pistol / circuit)."
                    : "Senses already named (use and extend, do not write a dictionary): \(namedSenses.joined(separator: ", "))."
                extra.append("""
                SEMANTIC CAGE SOUND: \(cageSound)
                \(sensesLine)
                """)
            }
            cookBlock = "\n" + extra.joined(separator: "\n")
            returnJSON = """
            Return JSON exactly: {"centralImage":"core image/motif","angle":"strategic angle in a phrase","anchorRhymes":["sound1","sound2","sound3"]\
            \(cookRecipe ? ",\"wordRecipe\":{\"seed\":\"\(recipeSeed)\",\"meanings\":[\"...\"],\"rimeFamily\":[\"...\"],\"culturalRef\":\"...\",\"combinedImage\":\"one cooked bar-image\"}" : "")\
            \(cookCage ? ",\"semanticCage\":{\"sound\":\"\(cageSound)\",\"senses\":[\"...\",\"...\"]}" : "")}
            """
        }
        let barAsk = params?.targetBarCount == 4 ? 4 : 16
        let user = """
        Plan a \(barAsk)-bar melodic trap verse. JSON only.
        Theme: \(theme?.themeName ?? context.intent.theme) (tone: \(theme?.emotionalTone ?? context.intent.tone.rawValue))
        \(controlSurfaceBlock(params))
        \(axesLine)\(cookBlock)
        \(returnJSON)
        """
        let raw = try await postChat(
            system: "You are Model G's planning step. Respond ONLY with valid JSON. Cook punches; do not write the verse yet.",
            user: user, maxTokens: (cookRecipe || cookCage) ? 520 : 220, temperature: 0.6, jsonMode: true
        )
        guard let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return .empty
        }
        return VersePlan.fromJSONObject(obj)
    }

    /// v3 step 2 — generate the whole verse (hook + 16 bars) in one call, conditioned on the plan.
    func generateFullVerse(plan: VersePlan, arcShape: String, context: GenerationContext,
                           temperature: Double = 0.8,
                           corpusExemplars: [String] = [], corpusVocab: [String] = [],
                           inspiration: Double = 0.4,
                           punchlineMode: Bool = false,
                           flowExemplar: FlowExemplar? = nil) async throws -> (hook: String, bars: [String]) {
        let usingArtistBrain = ModelYouWriterPolicy.usesArtistSeat(artistBrainPrompt: context.artistBrainPrompt)
        let layer = usingArtistBrain ? LuxuryLayer.empty : (context.luxuryLayer ?? .empty)
        let themeBlock = context.themeContext.map { themeDirective($0) } ?? ""
        let voiceBlock = context.signalAxes.map { "\n" + signalDirective($0) } ?? ""
        let inspirationLine = ModelGEnvironment.originalityBias < 0.5
            ? "Inspiration: be grounded in the culture — reference music, brands, places, slang and play on familiar phrases; borrow the genre's idioms. Clever and referential beats sterile-original."
            : "Inspiration: lean fresh and novel, but stay grounded in the culture — references and wordplay over invented-from-nothing lines."
        let palette = LexiconStore.shared.referencePalette()
        let referencesBlock = ModelYouWriterPolicy.housePaletteLine(palette: palette, usingArtistBrain: usingArtistBrain)
        let beatBlock = beatDirective(context)
        let wrapBlock = wrapClockBlock(context)
        let syllRule: String
        if let lo = context.syllableMin, let hi = context.syllableMax {
            syllRule = "between \(lo) and \(hi) syllables per bar — sit in the pocket"
        } else if context.barClock != nil || context.musicalBPM != nil {
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
        // Lyric RAG is vocabulary flavor only. Pocket resemblance lives on COPY-FLOW, not phrasing.
        let corpusExemplarBlock: String = {
            guard !corpusExemplars.isEmpty else { return "" }
            let lines = corpusExemplars.map { "• \($0)" }.joined(separator: "\n")
            let directive = ModelYouWriterPolicy.referenceBarsDirective(
                usingArtistBrain: usingArtistBrain,
                inspiration: inspiration
            )
            return "\n\n\(directive)\n\(lines)"
        }()
        let copyFlow = copyFlowBlock(flowExemplar)
        let corpusVocabBlock: String = (usingArtistBrain || corpusVocab.isEmpty) ? "" :
            "\nVOCAB PALETTE (weave in naturally, only if it fits): \(corpusVocab.prefix(12).joined(separator: ", "))"
            
        let punchlineBlock = punchlineMode ? "\n\nPUNCHLINE MODE (STRICT STRUCTURE):\n- Structure the entire 16-bar verse into 4-bar chunks.\n- Bars 1 and 2 MUST establish a premise or narrative.\n- Bar 3 MUST be a setup or misdirection.\n- Bar 4 MUST deliver a hard punchline/payoff.\n- This means bars 4, 8, 12, and 16 should be the strongest punchlines, set up by the preceding 3 bars." : ""
        let directedBlock = controlSurfaceBlock(context.directedParams)
        let punchContentBlock = punchContentBlock(plan)
        let artistBrainBlock: String = {
            guard let prompt = context.artistBrainPrompt, !prompt.isEmpty else { return "" }
            return "\n\nMODEL YOU ARTIST BRAIN (this writer — not Gunna house wrap):\n\(prompt)"
        }()
        let barAsk = context.directedParams?.targetBarCount == 4 ? 4 : 16
        let cycleAsk = barAsk == 4
            ? "a 1-2 line HOOK and EXACTLY 4 bars (one wrap cycle)"
            : "a 1-2 line HOOK and EXACTLY 16 bars as FOUR 4-bar cycles"
        let rhymeRule = usingArtistBrain
            ? "rhyme HARD — multisyllabic and internal, not just line-ends"
            : "end on a perfect hit (same ending sound) or a painter-family near (pretty/chelly, hip/dick, cheat/reach, line-end shit/militant); a shared vowel outside those families is not a rhyme; internal rhyme is welcome when the line stays relaxed; skip stacked multisyllabic flexes"
        let emptyRule = usingArtistBrain
            ? ""
            : " If you cannot keep DIRECTION inside ±2 syllables with that ending, return {\"hook\":\"\",\"bars\":[]} and write no filler."
        let user = """
        Write a melodic trap verse: \(cycleAsk). JSON only.
        \(wrapBlock)
        \(copyFlow)
        \(directedBlock)
        \(punchContentBlock)
        Topic: \(context.intent.theme) (tone: \(context.intent.tone.rawValue))
        \(plan.promptText)
        \(arcShape)\(themeBlock)\(voiceBlock)\(beatBlock)
        \(ModelYouWriterPolicy.luxuryPromptLine(layer: layer, usingArtistBrain: usingArtistBrain))
        \(inspirationLine)\(referencesBlock)\(corpusExemplarBlock)\(corpusVocabBlock)\(punchlineBlock)\(artistBrainBlock)
        Rules (strict): each bar SHORT and punchy, \(syllRule) (no wordy/run-on lines); \(rhymeRule); \(ModelYouWriterPolicy.concreteRule(usingArtistBrain: usingArtistBrain, filters: context.directedParams?.youFilters ?? .init())); deliberate repetition/anaphora is allowed — don't pad; earn the reveal, don't over-explain; no numbering inside the bar strings.\(rhymeCadence)
        Return JSON exactly: {"hook": "the hook lines", "bars": ["bar 1", "bar 2", "… \(barAsk) bars total"]}\(emptyRule)\(exampleBlock)
        """
        #if DEBUG
        let clock = context.barClock
        let recipeNote = plan.wordRecipe.map { " recipe=\($0.seed)" } ?? ""
        let cageNote = plan.semanticCage.map { " cage=\($0.sound)/\($0.senses.count)" } ?? ""
        let flowNote = flowExemplar.map { " flow=\($0.source.rawValue) \($0.syllableMap.map(String.init).joined(separator: "/"))" } ?? ""
        print("📝 [ModelG] clock bpm=\(clock.map { String(Int($0.bpm.rounded())) } ?? "nil") folded=\(clock?.hatsFolded ?? false)\(recipeNote)\(cageNote)\(flowNote) partner:\(directedBlock.prefix(180))")
        #endif
        let youSystem = usingArtistBrain
            ? "You are Model You. G craft (score, reject, syllables, silence) still applies, but identity is this artist's confirmed brain — not Gunna / Young Thug / Lil Baby house wrap. If the brain is thin, write like a pro using only what they told us. Punch stays punch. Respond ONLY with valid JSON: a hook and exactly the requested bars."
            : """
            ROLE
            You are Model G, the Verse Writer for Penwork. Swift reads your JSON and drops an empty bars array. Write short, concrete, cadence-driven trap lines.

            INPUT
            The user message uses these headings: DIRECTION, MUST-USE, HIGHLIGHTS, TOPICS, RHYME GROUPS, COPY-FLOW, BAR CLOCK. This request asks for \(barAsk) bars. Obey that count.

            ORDER
            1. DIRECTION. Keep the user's specific subject and picture. Compress it into the pocket.
            2. BAR CLOCK and COPY-FLOW. Stay within ±2 syllables of each slot on the map. When the subject is long, shorten the line. Stay inside ±2.
            3. RHYME. A perfect hit is the same ending sound. A near hit is a painter family only:
               - feminine -y, as in pretty/chelly
               - same vowel plus one P, B, K, or G, as in hip/dick
               - IY or IH plus T or CH, as in cheat/reach
               - a line-end IH plus an alveolar stop, as in shit/militant
               A shared vowel outside those families is not a rhyme. When RHYME GROUPS lists families, end on those. When the user message says to hold one ending for N bars, hold it for N bars.
            4. MUST-USE and HIGHLIGHTS. Place them inside the clock.

            STYLE
            One image or action per line. One brand per line. No run-on lines. Internal rhyme is welcome when the line stays relaxed. Skip stacked multisyllabic flexes. Reference bars are tone only. Leave their words behind. Match the intensity the direction already asks for. Do not add profanity to sound authentic.

            OUTPUT
            JSON only. No markdown, no commentary.
            {"hook":"1-2 lines in one string","bars":["…"]}
            The bars array length equals \(barAsk).
            When you cannot keep the direction inside ±2 with a perfect or painter-family ending, return {"hook":"","bars":[]}. Leave the slot empty. Do not write a filler bar.
            """
        let raw = try await postChat(
            system: youSystem,
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

    /// Writing-partner fields for the live Core prompt. Empty sections are omitted (not "—") so the model does not treat blanks as constraints.
    private func controlSurfaceBlock(_ params: DirectedGenerationParams?) -> String {
        var lines: [String] = []
        lines.append("DIRECTION: \(controlSurfaceDirection(params))")
        let job = params?.targetBarCount == 4 ? 4 : 16
        if job == 4 {
            lines.append("JOB: one 4-bar cycle. Do not punch-in one caption at a time.")
        } else {
            lines.append("JOB: four 4-bar cycles (16 bars). Repeat the pocket, swap nouns. Do not punch-in one caption at a time.")
        }
        guard let params else {
            return "\n" + lines.joined(separator: "\n") + "\n"
        }
        let recipeSeed = params.resolvedRecipeSeed
        if !recipeSeed.isEmpty {
            lines.append("RECIPE SEED: \(recipeSeed) — cook meaning + rhyme + one outside cultural ref into a single image. Do not just name the word.")
        }
        let cageSound = params.resolvedSemanticSound
        if !cageSound.isEmpty {
            let senses = params.semanticSenses
            if senses.isEmpty {
                lines.append("SOUND CAGE: \"\(cageSound)\" — one sound, several meanings. Use at least two senses across the 16. Do not define the word.")
            } else {
                lines.append("SOUND CAGE: \"\(cageSound)\" may mean \(senses.joined(separator: " / ")). Each 4-bar cycle uses at least two senses. Do not define the word.")
            }
        }
        let keywordCage = params.resolvedKeywordCage
        if !keywordCage.isEmpty {
            lines.append("KEYWORD CAGE (every bar touches at least one): \(keywordCage.joined(separator: ", "))")
        }
        let mustUse = params.resolvedMustUseVerbatim
        if !mustUse.isEmpty {
            lines.append("MUST-USE (include each verbatim at least once): \(mustUse.joined(separator: ", "))")
        }
        if !params.highlightAnchors.isEmpty {
            let bits = params.highlightAnchors.map { anchor -> String in
                guard let strength = anchor.strength else { return anchor.word }
                return "\(anchor.word) (\(strength.rawValue))"
            }
            lines.append("HIGHLIGHTS (nudge rhyme and imagery): \(bits.joined(separator: ", "))")
        }
        if !params.selectedTopics.isEmpty {
            lines.append("TOPICS: \(params.selectedTopics.joined(separator: ", "))")
        }
        if !params.selectedTones.isEmpty {
            lines.append("TONES: \(params.selectedTones.map(\.rawValue).joined(separator: ", "))")
        }
        if !params.worldBuildingWords.isEmpty {
            lines.append("WORLD-BUILDING (weave as imagery, not a list): \(params.worldBuildingWords.joined(separator: ", "))")
        }
        if !params.selectedRhymeGroups.isEmpty {
            let groups = params.selectedRhymeGroups
                .map { "\($0.key): \($0.words.joined(separator: ", "))" }
                .joined(separator: "; ")
            lines.append("RHYME GROUPS (prefer these families at line end): \(groups)")
        }
        let chips = params.schemeChipBlock().trimmingCharacters(in: .whitespacesAndNewlines)
        if !chips.isEmpty {
            lines.append(contentsOf: chips.split(separator: "\n").map(String.init))
        }
        return "\n" + lines.joined(separator: "\n") + "\n"
    }

    /// Cooked punch content from the plan call. Empty when no recipe/cage was requested.
    private func punchContentBlock(_ plan: VersePlan) -> String {
        var lines: [String] = []
        if let recipe = plan.wordRecipe, recipe.isUsable {
            let meanings = recipe.meanings.isEmpty ? "" : " Meanings in play: \(recipe.meanings.joined(separator: ", "))."
            let rimes = recipe.rimeFamily.isEmpty ? "" : " Rime family: \(recipe.rimeFamily.joined(separator: ", "))."
            let culture = recipe.culturalRef.isEmpty ? "" : " Cultural ref: \(recipe.culturalRef)."
            lines.append("WORD RECIPE (use this cooked image, do not restate the steps): \(recipe.combinedImage).\(meanings)\(rimes)\(culture)")
        }
        if let cage = plan.semanticCage, cage.isUsable {
            lines.append("SEMANTIC CAGE: the sound \"\(cage.sound)\" may mean \(cage.senses.joined(separator: " / ")). Each 4-bar cycle uses at least two senses. Do not define the word. Do not say it has many meanings.")
        }
        guard !lines.isEmpty else { return "" }
        return "\n" + lines.joined(separator: "\n") + "\n"
    }

    /// Copy the CLOCK (syllable map + punch-window stress), never the nouns.
    private func copyFlowBlock(_ exemplar: FlowExemplar?) -> String {
        guard let exemplar, exemplar.isUsable else { return "" }
        let map = exemplar.syllableMap.map(String.init).joined(separator: " / ")
        var block = """

        COPY-FLOW (copy the CLOCK, not the nouns):
        Syllable map: \(map)
        Stress: \(exemplar.stressHint)
        Stay within ±2 syllables of each slot. Fill new nouns. Do not reuse the reference words.
        """
        if exemplar.includeBarText {
            let shape = exemplar.bars.joined(separator: "\n")
            block += "\nReference shape (do not reuse these words):\n\(shape)\n"
        }
        return block
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

    /// Ohm wrap clock: pocket + punch window. Omitted when Gunna wrap is off.
    private func wrapClockBlock(_ context: GenerationContext) -> String {
        if context.directedParams?.gunnaWrap == false { return "" }
        guard let clock = context.barClock else { return "" }
        let foldNote = clock.hatsFolded
            ? " Hats were 2×; write the vocal at this pocket, not double-time."
            : ""
        let job = context.directedParams?.targetBarCount == 4 ? 4 : 16
        let cycleLine: String
        if context.directedParams?.storyArc == true {
            cycleLine = "Write FOUR 4-bar cycles as ONE journey (not eight isolated couplets). Repeat this pocket; advance the story."
        } else if job == 4 {
            cycleLine = "Write ONE 4-bar cycle."
        } else {
            cycleLine = "Write FOUR 4-bar cycles. Repeat this pocket; swap nouns."
        }
        let grammar: String
        switch context.directedParams?.punchGrammar ?? .couplet {
        case .threePlusOne:
            grammar = "PUNCH GRAMMAR: bars 1–3 setup/misdirection, bar 4 payoff. Repeat that 4-bar shape."
        case .closedLoop4:
            grammar = "PUNCH GRAMMAR: closed-loop 4 — one concept across the four (same picture, illegal second readings). Example shape: first / second / nothing."
        case .couplet:
            grammar = "PUNCH GRAMMAR: couplet. Bars 1–2 setup/punch, bars 3–4 same pocket and same concept, new nouns. Setup on beats 1–2.5. Punch re-reads the setup (same picture, second meaning)."
        }
        let adlib = (context.directedParams?.adlibOnFour == true)
            ? "\nAd-lib \"yeah\" may mark beat 4 as a metronome click — not a bar."
            : ""
        return """

        BAR CLOCK: \(Int(clock.bpm.rounded())) BPM, 4/4, \(String(format: "%.1f", clock.barsPerMinute)) bars/min, \(String(format: "%.2f", clock.secondsPerBar))s per bar.
        Pocket: \(clock.pocket.promptLabel). Land the last stress on beats 3–4.\(foldNote)
        \(grammar)
        \(cycleLine) Do not punch-in one bar at a time.\(adlib)
        Syllable count follows THIS beat (~\(context.syllableTarget) per bar). Wrap is when the last stress lands, not four short words per bar.

        EXEMPLAR (timing only — last stress late. Copy WHEN it lands, not how many words these lines have):
        Came up off nothing like the first seconds
        When you come from nothing, you know firsts second
        You know no firsts like the first seconds
        I'm just getting started. This is nothing special
        """
    }

    /// Beat metadata → cadence feel + mood lean. Empty when the entry has no BPM/key.
    /// Maps the entry's BPM (tempo feel) and musical key/scale (major→bright, minor/modes→dark)
    /// onto the corpus's 8-tone mood palette so the verse matches the track.
    private func beatDirective(_ context: GenerationContext) -> String {
        var parts: [String] = []
        if let clock = context.barClock {
            let foldNote = clock.hatsFolded ? " (hats folded; write the vocal at this pocket, not double-time)" : ""
            parts.append("\(Int(clock.bpm.rounded())) BPM, \(String(format: "%.1f", clock.barsPerMinute)) bars/min, pocket \(clock.pocket.promptLabel), last stress on beats 3–4\(foldNote)")
        } else if let bpm = context.musicalBPM, bpm > 0 {
            let feel = bpm <= 85 ? "slow — more room per bar, stretch the melody"
                     : "mid-tempo — steady pocket"
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
        case .low:    exposure = "Earn the reveal on the punch bar; don't over-explain the setup. Naming the flip is allowed. Don't justify, don't list."
        case .medium: exposure = "Mostly imply on the setup; the punch may name the second meaning. Show more than you tell."
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
