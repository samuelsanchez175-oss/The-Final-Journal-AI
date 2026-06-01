import Foundation
import Combine

// MARK: - Model Improvement Pipeline
// Uses feedback to improve AI models and prompts

class ModelImprovementPipeline {
    static let shared = ModelImprovementPipeline()
    
    private let improvementKey = "model_improvements"
    private let promptVersionKey = "prompt_version"
    
    private init() {}
    
    // MARK: - Generate Improvements
    
    func generateImprovements() -> ModelImprovements {
        let analysis = FeedbackAnalysisEngine.shared.analyzeFeedbackPatterns()
        
        // Generate prompt improvements based on common issues
        let promptImprovements = generatePromptImprovements(analysis: analysis)
        
        // Suggest quality metric tuning
        let metricTuning = generateMetricTuning(analysis: analysis)
        
        // Suggest model selection improvements
        let modelSelection = generateModelSelectionImprovements(analysis: analysis)
        
        return ModelImprovements(
            promptImprovements: promptImprovements,
            metricTuning: metricTuning,
            modelSelection: modelSelection,
            generatedAt: Date()
        )
    }
    
    // MARK: - Prompt Improvements
    
    func generatePromptImprovements(analysis: FeedbackPatternAnalysis) -> [PromptImprovement] {
        var improvements: [PromptImprovement] = []
        
        // Analyze common issues and suggest prompt changes
        for issue in analysis.commonIssues {
            switch issue.category {
            case .rhymeQuality:
                improvements.append(PromptImprovement(
                    area: "Rhyme Quality",
                    currentPrompt: "Match rhyme target and maintain rhyme scheme",
                    suggestedChange: "STRICTLY enforce perfect rhyme matching. Reject suggestions with weak rhymes. Prioritize rhyme quality over other factors.",
                    priority: issue.percentage > 0.3 ? .high : .medium,
                    rationale: "\(Int(issue.percentage * 100))% of negative feedback relates to rhyme quality"
                ))
                
            case .flowRhythm:
                improvements.append(PromptImprovement(
                    area: "Flow/Rhythm",
                    currentPrompt: "Maintain rhythm consistency",
                    suggestedChange: "CRITICALLY analyze syllable stress patterns. Match cadence EXACTLY. Test flow by reading aloud.",
                    priority: issue.percentage > 0.3 ? .high : .medium,
                    rationale: "\(Int(issue.percentage * 100))% of negative feedback relates to flow/rhythm"
                ))
                
            case .styleMismatch:
                improvements.append(PromptImprovement(
                    area: "Style Matching",
                    currentPrompt: "Match user's style characteristics",
                    suggestedChange: "ANALYZE user's vocabulary complexity, sentence structure, and energy level MORE CAREFULLY. Penalize style mismatches heavily in confidence scoring.",
                    priority: issue.percentage > 0.3 ? .high : .medium,
                    rationale: "\(Int(issue.percentage * 100))% of negative feedback relates to style mismatch"
                ))
                
            case .themeInconsistency:
                improvements.append(PromptImprovement(
                    area: "Theme Consistency",
                    currentPrompt: "Maintain primary themes throughout",
                    suggestedChange: "ENSURE all 4 lines maintain primary themes. Reject suggestions that introduce unrelated themes. Check theme consistency line-by-line.",
                    priority: issue.percentage > 0.3 ? .high : .medium,
                    rationale: "\(Int(issue.percentage * 100))% of negative feedback relates to theme inconsistency"
                ))
                
            case .voiceMismatch:
                improvements.append(PromptImprovement(
                    area: "Voice Consistency",
                    currentPrompt: "Match voice type (defensive/vulnerable)",
                    suggestedChange: "STRICTLY enforce voice type matching. Defensive voice MUST stay defensive. Vulnerable voice MUST stay vulnerable. This is CRITICAL.",
                    priority: issue.percentage > 0.3 ? .high : .medium,
                    rationale: "\(Int(issue.percentage * 100))% of negative feedback relates to voice mismatch"
                ))
                
            default:
                break
            }
        }
        
        return improvements
    }
    
    // MARK: - Metric Tuning
    
    func generateMetricTuning(analysis: FeedbackPatternAnalysis) -> MetricTuningSuggestions {
        // Analyze quality metric accuracy and suggest weight adjustments
        let categoryStats = SuggestionFeedbackManager.shared.getFeedbackStatsByCategory()
        
        // Calculate which metrics need more weight based on feedback
        var rhymeWeightAdjustment: Double = 0.0
        var flowWeightAdjustment: Double = 0.0
        var styleWeightAdjustment: Double = 0.0
        
        let rhymeIssues = categoryStats.categoryStats[.rhymeQuality]?.disliked ?? 0
        let flowIssues = categoryStats.categoryStats[.flowRhythm]?.disliked ?? 0
        let styleIssues = categoryStats.categoryStats[.styleMismatch]?.disliked ?? 0
        
        let totalIssues = rhymeIssues + flowIssues + styleIssues
        
        if totalIssues > 0 {
            rhymeWeightAdjustment = Double(rhymeIssues) / Double(totalIssues) - 0.33 // Current weight is ~0.33
            flowWeightAdjustment = Double(flowIssues) / Double(totalIssues) - 0.33
            styleWeightAdjustment = Double(styleIssues) / Double(totalIssues) - 0.33
        }
        
        return MetricTuningSuggestions(
            rhymeStrengthWeightAdjustment: rhymeWeightAdjustment,
            flowMatchWeightAdjustment: flowWeightAdjustment,
            styleMatchWeightAdjustment: styleWeightAdjustment,
            confidenceThresholdAdjustment: analysis.trends.acceptanceRateTrend == .declining ? -0.1 : 0.0
        )
    }
    
    // MARK: - Model Selection
    
    func generateModelSelectionImprovements(analysis: FeedbackPatternAnalysis) -> ModelSelectionSuggestions {
        // Suggest which model to use based on feedback patterns
        // For now, return placeholder - would need model tracking in feedback
        
        return ModelSelectionSuggestions(
            preferredModel: nil,
            modelSpecificIssues: [:]
        )
    }
    
    // MARK: - Apply Improvements
    
    func applyImprovements(_ improvements: ModelImprovements) {
        // Store improvements for A/B testing
        var allImprovements = loadImprovements()
        allImprovements.append(improvements)
        
        // Keep only recent improvements
        if allImprovements.count > 50 {
            allImprovements = Array(allImprovements.suffix(50))
        }
        
        saveImprovements(allImprovements)
        
        // Increment prompt version
        let currentVersion = UserDefaults.standard.integer(forKey: promptVersionKey)
        UserDefaults.standard.set(currentVersion + 1, forKey: promptVersionKey)
    }
    
    // MARK: - Get Current Prompt Version
    
    func getCurrentPromptVersion() -> Int {
        return UserDefaults.standard.integer(forKey: promptVersionKey)
    }
    
    // MARK: - Get Recent Improvements
    
    func getRecentImprovements() -> [PromptImprovement] {
        let allImprovements = loadImprovements()
        // Get the most recent improvements and extract all prompt improvements
        let recent = allImprovements.suffix(5) // Last 5 improvement sets
        return recent.flatMap { $0.promptImprovements }
            .sorted { $0.priority.rawValue > $1.priority.rawValue } // High priority first
    }
    
    // MARK: - Private Helpers
    
    private func loadImprovements() -> [ModelImprovements] {
        guard let data = UserDefaults.standard.data(forKey: improvementKey),
              let decoded = try? JSONDecoder().decode([ModelImprovements].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private func saveImprovements(_ improvements: [ModelImprovements]) {
        if let encoded = try? JSONEncoder().encode(improvements) {
            UserDefaults.standard.set(encoded, forKey: improvementKey)
        }
    }
}

// MARK: - Data Models

struct ModelImprovements: Codable {
    let promptImprovements: [PromptImprovement]
    let metricTuning: MetricTuningSuggestions
    let modelSelection: ModelSelectionSuggestions
    let generatedAt: Date
}

struct PromptImprovement: Codable {
    let area: String
    let currentPrompt: String
    let suggestedChange: String
    let priority: ImprovementPriority
    let rationale: String
}

enum ImprovementPriority: Int, Codable {
    case low = 1
    case medium = 2
    case high = 3
}

struct MetricTuningSuggestions: Codable {
    let rhymeStrengthWeightAdjustment: Double // Adjustment to current weight
    let flowMatchWeightAdjustment: Double
    let styleMatchWeightAdjustment: Double
    let confidenceThresholdAdjustment: Double // Adjustment to confidence threshold
}

struct ModelSelectionSuggestions: Codable {
    let preferredModel: String? // Model identifier
    let modelSpecificIssues: [String: [FeedbackCategory]] // Model -> common issues
}
