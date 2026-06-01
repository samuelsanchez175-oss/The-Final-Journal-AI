import Foundation
import NaturalLanguage

enum SummaryError: LocalizedError {
    case summarizationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .summarizationFailed(let message):
            return "Summary generation failed: \(message)"
        }
    }
}

class AudioSummaryService {
    static let shared = AudioSummaryService()
    
    private init() {}
    
    /// Generate a concise summary from transcription text using Apple's on-device Natural Language framework
    /// Falls back to OpenAI API if available and on-device summarization is insufficient
    func generateSummary(from transcription: String) async throws -> String {
        // Try on-device summarization first (Apple Intelligence / Natural Language)
        if let onDeviceSummary = try? generateOnDeviceSummary(from: transcription) {
            return onDeviceSummary
        }
        
        // Fallback to OpenAI API if available
        if let apiKey = KeychainHelper.shared.getAPIKey(), !apiKey.isEmpty {
            return try await generateOpenAISummary(from: transcription, apiKey: apiKey)
        }
        
        // If both fail, generate a simple extractive summary
        return generateExtractiveSummary(from: transcription)
    }
    
    // MARK: - On-Device Summarization (Apple Intelligence / Natural Language)
    
    /// Generate summary using Apple's Natural Language framework (on-device)
    private func generateOnDeviceSummary(from text: String) throws -> String {
        // Use Natural Language framework for extractive summarization
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        var sentences: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            sentences.append(String(text[range]))
            return true
        }
        
        guard !sentences.isEmpty else {
            throw SummaryError.summarizationFailed("No sentences found")
        }
        
        // Extract key sentences (first 2-3 sentences or sentences with important keywords)
        let summarySentences = extractKeySentences(sentences, maxCount: 3)
        
        return summarySentences.joined(separator: " ")
    }
    
    /// Extract key sentences based on importance
    private func extractKeySentences(_ sentences: [String], maxCount: Int) -> [String] {
        guard sentences.count > maxCount else {
            return sentences
        }
        
        // Score sentences based on length and keyword presence
        let importantKeywords = ["important", "main", "key", "summary", "conclusion", "purpose", "about"]
        
        let scoredSentences = sentences.enumerated().map { index, sentence -> (String, Double) in
            let lowercased = sentence.lowercased()
            var score = Double(sentence.count) / 100.0 // Prefer longer sentences
            
            // Boost score for important keywords
            for keyword in importantKeywords {
                if lowercased.contains(keyword) {
                    score += 2.0
                }
            }
            
            // Prefer earlier sentences slightly
            score += Double(maxCount - index) * 0.1
            
            return (sentence, score)
        }
        
        // Sort by score and take top sentences
        let topSentences = scoredSentences
            .sorted { $0.1 > $1.1 }
            .prefix(maxCount)
            .map { $0.0 }
            .sorted { sentences.firstIndex(of: $0)! < sentences.firstIndex(of: $1)! } // Maintain order
        
        return topSentences
    }
    
    /// Generate a simple extractive summary (fallback)
    private func generateExtractiveSummary(from text: String) -> String {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        var sentences: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            sentences.append(String(text[range]))
            return true
        }
        
        // Take first 2-3 sentences as summary
        let summaryCount = min(3, sentences.count)
        return sentences.prefix(summaryCount).joined(separator: " ")
    }
    
    // MARK: - OpenAI API Fallback
    
    /// Generate summary using OpenAI API (fallback option)
    private func generateOpenAISummary(from transcription: String, apiKey: String) async throws -> String {
        let baseURL = "https://api.openai.com/v1"
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw SummaryError.summarizationFailed("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Provide a concise 2-3 sentence summary of this audio transcription. Focus on the main topics, key points, and overall purpose or theme.
        
        Transcription:
        \(transcription)
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-turbo-preview",
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 150
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw SummaryError.summarizationFailed("Failed to encode request: \(error.localizedDescription)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SummaryError.summarizationFailed("Invalid response")
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw SummaryError.summarizationFailed("HTTP \(httpResponse.statusCode): \(errorMessage)")
            }
            
            struct OpenAIResponse: Codable {
                let choices: [Choice]
                struct Choice: Codable {
                    let message: Message
                    struct Message: Codable {
                        let content: String
                    }
                }
            }
            
            let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let firstChoice = jsonResponse.choices.first else {
                throw SummaryError.summarizationFailed("No response from API")
            }
            
            return firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch let error as SummaryError {
            throw error
        } catch {
            throw SummaryError.summarizationFailed(error.localizedDescription)
        }
    }
}
