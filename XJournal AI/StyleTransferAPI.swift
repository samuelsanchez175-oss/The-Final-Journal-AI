import Foundation

// MARK: - Style Transfer API (Phase 4: Advanced AI Features)

extension RapSuggestionAPI {
    
    // MARK: - Style Transfer
    
    func generateStyleTransfer(
        text: String,
        targetArtist: String,
        context: String? = nil,
        signalAxes: SignalAxes? = nil
    ) async throws -> [RapSuggestion] {
        guard let apiKey = internalAPIKey else {
            throw RapAPIError.missingAPIKey
        }
        
        let url = URL(string: "\(internalBaseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var systemPrompt = """
        You are an expert rap lyricist and style analyst. Your task is to rewrite rap lyrics in the style of a specific artist while maintaining the original meaning and themes.
        
        Analyze the target artist's style characteristics:
        - Vocabulary level and word choice
        - Sentence structure and flow patterns
        - Figurative language usage
        - Energy and delivery style
        - Rhyme schemes and patterns
        - Repetition techniques
        - Cultural references and themes
        
        Rewrite the provided lyrics to match the target artist's style while preserving the core message and themes.
        """
        
        // Add signal axes preservation instructions if provided
        if let axes = signalAxes {
            systemPrompt += """
            
            CRITICAL: You must preserve the following psychological and social dimensions of the original text:
            
            - Exposure Risk: \(axes.exposureRisk.rawValue) - Maintain the same level of vulnerability/revelation. If \(axes.exposureRisk.rawValue), keep the same degree of personal exposure or guardedness.
            - Authority Posture: \(axes.authorityPosture.rawValue) - Maintain the same confidence level and position strength. If \(axes.authorityPosture.rawValue), preserve the same authority dynamics.
            - Social Action: \(axes.socialAction.rawValue) - Maintain the same social intent (confessing, asserting, withdrawing, etc.). The rewritten version should have the same social function.
            - Audience Scope: \(axes.audienceScope.rawValue) - Maintain the same intended audience (self, inner circle, or public). The rewritten version should address the same audience level.
            
            These dimensions are essential to preserving the original text's deeper meaning and social/psychological context. Do not change these characteristics - only change the artist's style/voice.
            """
        }
        
        var userPrompt = "Rewrite the following rap lyrics in the style of \(targetArtist):\n\n\(text)"
        if let context = context {
            userPrompt += "\n\nContext: \(context)"
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-turbo-preview",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7,
            "max_tokens": 500,
            "n": 3 // Generate 3 variations
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RapAPIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let _ = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw RapAPIError.requestFailed
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]] else {
            throw RapAPIError.invalidResponse
        }
        
        var suggestions: [RapSuggestion] = []
        
        for (index, choice) in choices.enumerated() {
            guard let message = choice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                continue
            }
            
            let suggestion = RapSuggestion(
                id: UUID(),
                text: content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                confidence: 0.85 - (Double(index) * 0.05), // Slightly decreasing confidence
                source: targetArtist,
                reasoning: "Rewritten in the style of \(targetArtist)",
                themes: [],
                rhymeStrength: nil,
                flowMatch: nil,
                styleMatch: 0.9 - (Double(index) * 0.05), // High style match
                userFeedback: nil
            )
            
            suggestions.append(suggestion)
        }
        
        return suggestions
    }
    
    // MARK: - Theme Expansion
    
    func generateThemeExpansion(
        text: String,
        currentThemes: [String],
        context: String? = nil,
        selectedThemeDetails: [Theme]? = nil
    ) async throws -> [RapSuggestion] {
        guard let apiKey = internalAPIKey else {
            throw RapAPIError.missingAPIKey
        }
        
        let url = URL(string: "\(internalBaseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var systemPrompt = """
        You are an expert rap lyricist and thematic analyst. Your task is to expand on existing themes in rap lyrics by suggesting related themes, concepts, and narrative directions.
        
        Analyze the current themes and suggest:
        - Related themes that naturally flow from the current ones
        - Deeper explorations of existing themes
        - Contrasting themes that create tension
        - New angles or perspectives on the themes
        - Emotional progressions that build on the themes
        
        Generate rap lyrics that expand on these themes while maintaining consistency with the original style and voice.
        """
        
        // Add theme database context if available
        if let themeDetails = selectedThemeDetails, !themeDetails.isEmpty {
            var themeContext = "\n\nTheme Database Context:\n"
            for theme in themeDetails {
                themeContext += "- \(theme.name): \(theme.contextDescription)\n"
                if !theme.jargonTerms.isEmpty {
                    themeContext += "  Related terms: \(theme.jargonTerms.joined(separator: ", "))\n"
                }
                if !theme.relatedThemes.isEmpty {
                    themeContext += "  Related themes: \(theme.relatedThemes.joined(separator: ", "))\n"
                }
                themeContext += "  Emotional tone: \(theme.emotionalTone)\n"
            }
            systemPrompt += themeContext
        }
        
        let themesStr = currentThemes.joined(separator: ", ")
        var userPrompt = """
        Current themes: \(themesStr)
        
        Current text:
        \(text)
        
        Generate rap lyrics that expand on these themes. Explore related concepts, deeper meanings, or new angles while maintaining the style and voice. Use the theme database context to understand related themes, emotional tones, and thematic connections.
        """
        
        if let context = context {
            userPrompt += "\n\nContext: \(context)"
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-turbo-preview",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.75,
            "max_tokens": 500,
            "n": 3 // Generate 3 variations
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RapAPIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let _ = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw RapAPIError.requestFailed
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]] else {
            throw RapAPIError.invalidResponse
        }
        
        var suggestions: [RapSuggestion] = []
        
        for (index, choice) in choices.enumerated() {
            guard let message = choice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                continue
            }
            
            let suggestion = RapSuggestion(
                id: UUID(),
                text: content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                confidence: 0.8 - (Double(index) * 0.05),
                source: "Theme Expansion",
                reasoning: "Expands on themes: \(themesStr)",
                themes: currentThemes,
                rhymeStrength: nil,
                flowMatch: nil,
                styleMatch: nil,
                userFeedback: nil
            )
            
            suggestions.append(suggestion)
        }
        
        return suggestions
    }
}
