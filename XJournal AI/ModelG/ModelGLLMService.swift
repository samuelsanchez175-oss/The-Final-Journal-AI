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

    private init() {}

    /// Generate N bar candidates in one request. Returns raw line strings.
    func generateBarCandidates(count: Int, context: GenerationContext) async throws -> [String] {
        guard let key = apiKey else { throw ModelGLLMError.missingAPIKey }

        let prompt = buildBarCandidatesPrompt(count: count, context: context)
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are Model G. Output ONLY the requested number of bar options, one per line. No numbering, labels, or explanations."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 700
        ]

        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 429 {
            let headers = Dictionary(uniqueKeysWithValues: http.allHeaderFields.compactMap { k, v -> (String, String)? in
                guard let key = k as? String, let val = v as? String else { return nil }
                return (key.lowercased(), val)
            })
            let retryAfter = headers["retry-after"].flatMap { Int($0) }
            throw ModelGLLMError.rateLimitExceeded(retryAfterSeconds: retryAfter)
        }
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ModelGLLMError.requestFailed
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let content = choices?.first?["message"] as? [String: Any]
        let text = content?["content"] as? String ?? ""

        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .prefix(count)
        return Array(lines)
    }

    /// Generate a hook.
    func generateHook(context: GenerationContext) async throws -> String {
        guard let key = apiKey else { throw ModelGLLMError.missingAPIKey }

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

        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are Model G. Output only the hook lines."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 80
        ]

        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 429 {
            let headers = Dictionary(uniqueKeysWithValues: http.allHeaderFields.compactMap { k, v -> (String, String)? in
                guard let key = k as? String, let val = v as? String else { return nil }
                return (key.lowercased(), val)
            })
            let retryAfter = headers["retry-after"].flatMap { Int($0) }
            throw ModelGLLMError.rateLimitExceeded(retryAfterSeconds: retryAfter)
        }
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ModelGLLMError.requestFailed
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let content = choices?.first?["message"] as? [String: Any]
        return (content?["content"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
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
