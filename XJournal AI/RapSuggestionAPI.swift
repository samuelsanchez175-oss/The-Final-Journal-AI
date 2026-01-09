import Foundation
import Security

// MARK: - API Models

struct NarrativeAnalysis: Codable {
    let primaryThemes: [String]
    let secondaryThemes: [String]
    let emotionalTone: String
    let narrativePhase: String // "intro", "build", "climax", "outro", etc.
    let entities: [String] // People, places, objects mentioned
    let perspective: String // "first-person", "third-person", etc.
    let summary: String
}

struct RapSuggestion: Codable, Identifiable {
    let id: UUID
    let text: String
    let confidence: Double
    let source: String? // Original artist/song if adapted
    let reasoning: String? // Why this suggestion fits
    let themes: [String] // Themes extracted from the suggestion
}

// MARK: - API Client

class RapSuggestionAPI {
    static let shared = RapSuggestionAPI()
    
    private let baseURL = "https://api.openai.com/v1"
    private var apiKey: String? {
        // Retrieve from Keychain
        return KeychainHelper.shared.getAPIKey()
    }
    
    private init() {}
    
    // MARK: - Narrative Analysis
    
    func analyzeNarrative(text: String, lastNLines: [String]) async throws -> NarrativeAnalysis {
        guard let apiKey = apiKey else {
            throw RapAPIError.missingAPIKey
        }
        
        let prompt = """
        Analyze this rap verse and extract structured information:
        
        Full text:
        \(text)
        
        Last 3 lines (context):
        \(lastNLines.joined(separator: "\n"))
        
        Extract and return JSON with:
        - primaryThemes: Array of 2-4 main themes (e.g., ["luxury", "hustle", "status"])
        - secondaryThemes: Array of 1-3 secondary themes
        - emotionalTone: Single tone (e.g., "confident", "gritty", "aspirational")
        - narrativePhase: One of "intro", "build", "climax", "outro", "bridge", "verse"
        - entities: Array of people, places, objects mentioned
        - perspective: "first-person" or "third-person"
        - summary: 1-2 sentence summary of the verse's meaning
        
        Return ONLY valid JSON, no markdown, no code blocks.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-turbo-preview",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a rap lyric analyst. Extract themes, tone, and narrative structure from rap verses. Always return valid JSON."
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
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
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
        narrative: NarrativeAnalysis
    ) async throws -> [RapSuggestion] {
        guard let apiKey = apiKey else {
            throw RapAPIError.missingAPIKey
        }
        
        // Select top 20 candidates for rewriting
        let topCandidates = Array(candidates.prefix(20))
        
        let candidatesText = topCandidates.enumerated().map { index, line in
            "\(index + 1). \(line.text) [Artist: \(line.artist ?? "Unknown"), Song: \(line.song ?? "Unknown")]"
        }.joined(separator: "\n")
        
        let prompt = """
        You are a rap lyric suggestion engine. Your job is to suggest the next line(s) for a rap verse.
        
        User's current verse:
        \(metrics.lastNLines.joined(separator: "\n"))
        
        Context:
        - Themes: \(narrative.primaryThemes.joined(separator: ", "))
        - Tone: \(narrative.emotionalTone)
        - Narrative Phase: \(narrative.narrativePhase)
        - Target Syllables: \(metrics.syllableTarget ?? 0)
        - Rhyme Target: \(metrics.rhymeTarget ?? "none")
        - Rhyme Scheme: \(metrics.rhymeScheme ?? "unknown")
        
        Candidate lines from real rap songs (use these as inspiration, prefer selection over rewriting):
        \(candidatesText)
        
        Rules:
        1. Prefer selecting/adapting from candidates (70%) over free generation (30%)
        2. Each suggestion must be EXACTLY 4 lines (separated by newlines)
        3. Maintain syllable count within ±1 of target for each line
        4. Match the rhyme target if provided
        5. Maintain the detected rhyme scheme
        6. Match the emotional tone and themes
        7. Never invent new content - only adapt existing lyrics
        8. Keep the flow natural and authentic
        
        Return 3-5 suggestions as JSON object with "suggestions" array:
        {
          "suggestions": [
            {
              "text": "line 1\nline 2\nline 3\nline 4",
              "confidence": 0.0-1.0,
              "source": "Artist - Song (if adapted)",
              "reasoning": "brief explanation",
              "themes": ["theme1", "theme2", "theme3"]
            }
          ]
        }
        
        IMPORTANT: Each "text" field must contain exactly 4 lines separated by newline characters (\\n).
        
        Return ONLY valid JSON object, no markdown, no code blocks.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-turbo-preview",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a rap lyric suggestion engine. Suggest next lines by adapting real rap lyrics. Always return valid JSON arrays."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7,
            "response_format": ["type": "json_object"]
        ]
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
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
            
            suggestions.append(RapSuggestion(
                id: UUID(),
                text: text,
                confidence: confidence,
                source: source,
                reasoning: reasoning,
                themes: Array(themes.prefix(5)) // Limit to 5 themes
            ))
        }
        
        return suggestions
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

// MARK: - Keychain Helper

class KeychainHelper {
    static let shared = KeychainHelper()
    private let service = "com.finaljournal.app"
    private let key = "openai_api_key"
    
    private init() {}
    
    func saveAPIKey(_ key: String) throws {
        let data = key.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: self.key,
            kSecValueData as String: data
        ]
        
        // Delete existing
        SecItemDelete(query as CFDictionary)
        
        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    func getAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    func deleteAPIKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
}

enum KeychainError: LocalizedError {
    case saveFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save API key to Keychain"
        case .deleteFailed:
            return "Failed to delete API key from Keychain"
        }
    }
}
