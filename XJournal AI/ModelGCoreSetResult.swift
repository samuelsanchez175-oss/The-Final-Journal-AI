import Foundation

/// One Model G suggestion-set attempt. Collecting these keeps a 429 from
/// being rewritten as "turn Model G off."
enum ModelGCoreSetResult {
    case success(GeneratedRecord)
    case failure(Error)

    /// Prefer any verse that landed. If nothing landed, surface rate-limit
    /// ahead of a generic core-failed error.
    static func recordsOrThrow(_ results: [ModelGCoreSetResult]) throws -> [GeneratedRecord] {
        let records = results.compactMap { result -> GeneratedRecord? in
            if case .success(let record) = result { return record }
            return nil
        }
        if !records.isEmpty { return records }

        for result in results {
            guard case .failure(let error) = result else { continue }
            if let api = error as? RapAPIError, case .rateLimitExceeded = api {
                throw api
            }
            if let llm = error as? ModelGLLMError, case .rateLimitExceeded(let seconds) = llm {
                throw RapAPIError.rateLimitExceeded(retryAfterSeconds: seconds)
            }
        }
        throw RapAPIError.modelGCoreFailed
    }
}
