import Foundation

/// Rough cost per Ghost/Model G suggestion (~750 input / 40 output tokens). Estimates — confirm vs live pricing.
struct ProviderPricing: Identifiable {
    let id = UUID()
    let provider: String
    let model: String
    let perSuggestion: String
    static let all: [ProviderPricing] = [
        .init(provider: "Google",    model: "Gemini Flash",  perSuggestion: "~$0.0001"),
        .init(provider: "OpenAI",    model: "gpt-4o-mini",   perSuggestion: "~$0.0002"),
        .init(provider: "Anthropic", model: "Claude Haiku",  perSuggestion: "~$0.0008"),
        .init(provider: "OpenAI",    model: "gpt-4o",        perSuggestion: "~$0.002"),
        .init(provider: "Anthropic", model: "Claude Sonnet", perSuggestion: "~$0.003"),
    ]
}
