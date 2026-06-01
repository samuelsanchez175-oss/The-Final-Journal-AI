//
//  BarGenerator.swift
//  XJournal AI
//
//  Model G Core v1.0 — Competitive bar candidate generation.
//

import Foundation

/// Generates bar candidates. No selection logic — returns raw candidates.
class BarGenerator {
    private let llmService = ModelGLLMService.shared

    /// Generate N candidates for a single bar.
    func generateCandidates(count: Int, context: GenerationContext) async throws -> [String] {
        do {
            let candidates = try await llmService.generateBarCandidates(count: count, context: context)
            return candidates.isEmpty ? fallbackCandidates(count: count, context: context) : candidates
        } catch let err {
            if case ModelGLLMError.rateLimitExceeded = err {
                throw err
            }
            return fallbackCandidates(count: count, context: context)
        }
    }

    private func fallbackCandidates(count: Int, context: GenerationContext) -> [String] {
        (0..<count).map { _ in
            "Continue the flow — \(context.intent.theme.prefix(40))..."
        }
    }
}
