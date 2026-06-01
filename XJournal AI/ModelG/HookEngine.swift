//
//  HookEngine.swift
//  XJournal AI
//
//  Model G Core v1.0 — Hook generation.
//

import Foundation

/// Generates hooks with Cold Trap rules: 6–8 syllables, repetition structure, minimal phrasing.
class HookEngine {
    private let llmService = ModelGLLMService.shared

    /// Generate a hook for the given context.
    func generateHook(context: GenerationContext) async throws -> String {
        do {
            let hook = try await llmService.generateHook(context: context)
            return hook.isEmpty ? "Drip on me — flow" : hook
        } catch let err {
            if case ModelGLLMError.rateLimitExceeded = err {
                throw err
            }
            return "Drip on me — flow"
        }
    }
}
