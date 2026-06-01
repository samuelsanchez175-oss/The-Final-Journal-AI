import Foundation

// MARK: - A/B Testing Manager
// Framework for testing improvements systematically

class ABTestingManager {
    static let shared = ABTestingManager()
    
    private let cohortsKey = "ab_test_cohorts"
    private let experimentsKey = "ab_test_experiments"
    
    private init() {}
    
    // MARK: - Experiment Management
    
    func createExperiment(
        name: String,
        variants: [ExperimentVariant],
        targetMetric: ExperimentMetric,
        durationDays: Int = 7
    ) -> Experiment {
        let experiment = Experiment(
            id: UUID(),
            name: name,
            variants: variants,
            targetMetric: targetMetric,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: durationDays, to: Date()) ?? Date(),
            status: .active,
            results: nil
        )
        
        saveExperiment(experiment)
        return experiment
    }
    
    func assignUserToVariant(experimentId: UUID, userId: String? = nil) -> ExperimentVariant? {
        let actualUserId = userId ?? getUserId()
        let experiment = loadExperiment(id: experimentId)
        guard let experiment = experiment, experiment.status == .active else { return nil }
        
        // Check if user already assigned
        if let existingAssignment = getUserCohort(userId: actualUserId, experimentId: experimentId) {
            return experiment.variants.first { $0.id == existingAssignment.variantId }
        }
        
        // Assign user to variant (50/50 split for now, can be customized)
        let variant = assignVariant(variants: experiment.variants, userId: actualUserId)
        
        let cohort = UserCohort(
            userId: actualUserId,
            experimentId: experimentId,
            variantId: variant.id,
            assignedAt: Date()
        )
        
        saveUserCohort(cohort)
        return variant
    }
    
    func recordMetric(experimentId: UUID, variantId: UUID, metric: ExperimentMetric, value: Double) {
        guard var experiment = loadExperiment(id: experimentId) else { return }
        
        // Initialize results if needed
        if experiment.results == nil {
            experiment.results = ExperimentResults(
                variantResults: experiment.variants.reduce(into: [:]) { dict, variant in
                    dict[variant.id] = VariantResults(
                        variantId: variant.id,
                        metricValues: [],
                        sampleSize: 0
                    )
                }
            )
        }
        
        // Record metric value
        if var variantResults = experiment.results?.variantResults[variantId] {
            variantResults.metricValues.append(MetricValue(
                value: value,
                timestamp: Date()
            ))
            variantResults.sampleSize += 1
            experiment.results?.variantResults[variantId] = variantResults
        }
        
        saveExperiment(experiment)
    }
    
    func getExperimentResults(experimentId: UUID) -> ExperimentResults? {
        let experiment = loadExperiment(id: experimentId)
        return experiment?.results
    }
    
    func analyzeExperiment(experimentId: UUID) -> ExperimentAnalysis? {
        guard let experiment = loadExperiment(id: experimentId),
              let results = experiment.results else {
            return nil
        }
        
        // Calculate statistics for each variant
        var variantAnalyses: [UUID: VariantAnalysis] = [:]
        
        for (variantId, variantResult) in results.variantResults {
            let values = variantResult.metricValues.map { $0.value }
            guard !values.isEmpty else { continue }
            
            let mean = values.reduce(0, +) / Double(values.count)
            let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
            let stdDev = sqrt(variance)
            
            variantAnalyses[variantId] = VariantAnalysis(
                variantId: variantId,
                mean: mean,
                standardDeviation: stdDev,
                sampleSize: variantResult.sampleSize,
                confidenceInterval: calculateConfidenceInterval(mean: mean, stdDev: stdDev, sampleSize: variantResult.sampleSize)
            )
        }
        
        // Determine winner (if statistically significant)
        let winner = determineWinner(variantAnalyses: variantAnalyses, targetMetric: experiment.targetMetric)
        
        return ExperimentAnalysis(
            experimentId: experimentId,
            variantAnalyses: variantAnalyses,
            winner: winner,
            isStatisticallySignificant: checkStatisticalSignificance(variantAnalyses: variantAnalyses),
            recommendation: generateRecommendation(winner: winner, significance: checkStatisticalSignificance(variantAnalyses: variantAnalyses))
        )
    }
    
    // MARK: - Private Helpers
    
    private func assignVariant(variants: [ExperimentVariant], userId: String) -> ExperimentVariant {
        // Simple hash-based assignment for consistency
        let hash = abs(userId.hashValue)
        let index = hash % variants.count
        return variants[index]
    }
    
    private func getUserId() -> String {
        // Generate or retrieve user ID
        if let userId = UserDefaults.standard.string(forKey: "user_id") {
            return userId
        } else {
            let userId = UUID().uuidString
            UserDefaults.standard.set(userId, forKey: "user_id")
            return userId
        }
    }
    
    private func calculateConfidenceInterval(mean: Double, stdDev: Double, sampleSize: Int) -> (lower: Double, upper: Double) {
        // 95% confidence interval using t-distribution approximation
        let tValue = 1.96 // For large samples, approximates t-distribution
        let marginOfError = tValue * (stdDev / sqrt(Double(sampleSize)))
        
        return (
            lower: mean - marginOfError,
            upper: mean + marginOfError
        )
    }
    
    private func determineWinner(variantAnalyses: [UUID: VariantAnalysis], targetMetric: ExperimentMetric) -> UUID? {
        guard variantAnalyses.count >= 2 else { return nil }
        
        let analyses = Array(variantAnalyses.values)
        
        switch targetMetric {
        case .acceptanceRate, .satisfactionScore:
            // Higher is better
            return analyses.max(by: { $0.mean < $1.mean })?.variantId
        case .regenerateFrequency, .timeToAcceptance:
            // Lower is better
            return analyses.min(by: { $0.mean < $1.mean })?.variantId
        }
    }
    
    private func checkStatisticalSignificance(variantAnalyses: [UUID: VariantAnalysis]) -> Bool {
        guard variantAnalyses.count >= 2 else { return false }
        
        let analyses = Array(variantAnalyses.values)
        guard analyses.count >= 2 else { return false }
        
        // Simple t-test approximation
        let variant1 = analyses[0]
        let variant2 = analyses[1]
        
        guard variant1.sampleSize >= 30 && variant2.sampleSize >= 30 else { return false }
        
        // Calculate t-statistic
        let pooledStdDev = sqrt((pow(variant1.standardDeviation, 2) + pow(variant2.standardDeviation, 2)) / 2)
        let standardError = pooledStdDev * sqrt(1.0 / Double(variant1.sampleSize) + 1.0 / Double(variant2.sampleSize))
        let tStatistic = abs(variant1.mean - variant2.mean) / standardError
        
        // Critical value for 95% confidence (two-tailed)
        let criticalValue = 1.96
        
        return tStatistic > criticalValue
    }
    
    private func generateRecommendation(winner: UUID?, significance: Bool) -> String {
        guard let winner = winner else {
            return "No clear winner. Continue experiment or adjust variants."
        }
        
        if significance {
            return "Variant \(winner.uuidString.prefix(8)) is statistically significantly better. Recommend deploying this variant."
        } else {
            return "Variant \(winner.uuidString.prefix(8)) appears better but not statistically significant. Consider extending experiment."
        }
    }
    
    private func getUserCohort(userId: String, experimentId: UUID) -> UserCohort? {
        let cohorts = loadUserCohorts()
        return cohorts.first { $0.userId == userId && $0.experimentId == experimentId }
    }
    
    private func saveUserCohort(_ cohort: UserCohort) {
        var cohorts = loadUserCohorts()
        cohorts.append(cohort)
        saveUserCohorts(cohorts)
    }
    
    private func loadUserCohorts() -> [UserCohort] {
        guard let data = UserDefaults.standard.data(forKey: cohortsKey),
              let decoded = try? JSONDecoder().decode([UserCohort].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private func saveUserCohorts(_ cohorts: [UserCohort]) {
        if let encoded = try? JSONEncoder().encode(cohorts) {
            UserDefaults.standard.set(encoded, forKey: cohortsKey)
        }
    }
    
    private func loadExperiment(id: UUID) -> Experiment? {
        let experiments = loadExperiments()
        return experiments.first { $0.id == id }
    }
    
    private func loadExperiments() -> [Experiment] {
        guard let data = UserDefaults.standard.data(forKey: experimentsKey),
              let decoded = try? JSONDecoder().decode([Experiment].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private func saveExperiment(_ experiment: Experiment) {
        var experiments = loadExperiments()
        if let index = experiments.firstIndex(where: { $0.id == experiment.id }) {
            experiments[index] = experiment
        } else {
            experiments.append(experiment)
        }
        saveExperiments(experiments)
    }
    
    private func saveExperiments(_ experiments: [Experiment]) {
        if let encoded = try? JSONEncoder().encode(experiments) {
            UserDefaults.standard.set(encoded, forKey: experimentsKey)
        }
    }
}

// MARK: - Data Models

struct Experiment: Codable, Identifiable {
    let id: UUID
    let name: String
    let variants: [ExperimentVariant]
    let targetMetric: ExperimentMetric
    let startDate: Date
    let endDate: Date
    var status: ExperimentStatus
    var results: ExperimentResults?
}

struct ExperimentVariant: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let configuration: VariantConfiguration
}

struct VariantConfiguration: Codable {
    let promptModifications: [String]? // Changes to prompt
    let metricWeights: MetricWeights? // Adjusted metric weights
    let modelSettings: ModelSettings? // Different model settings
}

struct MetricWeights: Codable {
    let rhymeStrength: Double
    let flowMatch: Double
    let styleMatch: Double
}

enum ExperimentMetric: String, Codable {
    case acceptanceRate = "acceptance_rate" // Percentage of suggestions accepted
    case regenerateFrequency = "regenerate_frequency" // How often users regenerate
    case satisfactionScore = "satisfaction_score" // User satisfaction rating
    case timeToAcceptance = "time_to_acceptance" // Time until user accepts suggestion
}

enum ExperimentStatus: String, Codable {
    case active
    case completed
    case paused
}

struct ExperimentResults: Codable {
    var variantResults: [UUID: VariantResults]
}

struct VariantResults: Codable {
    var variantId: UUID
    var metricValues: [MetricValue]
    var sampleSize: Int
}

struct MetricValue: Codable {
    let value: Double
    let timestamp: Date
}

struct UserCohort: Codable {
    let userId: String
    let experimentId: UUID
    let variantId: UUID
    let assignedAt: Date
}

struct ExperimentAnalysis {
    let experimentId: UUID
    let variantAnalyses: [UUID: VariantAnalysis]
    let winner: UUID?
    let isStatisticallySignificant: Bool
    let recommendation: String
}

struct VariantAnalysis {
    let variantId: UUID
    let mean: Double
    let standardDeviation: Double
    let sampleSize: Int
    let confidenceInterval: (lower: Double, upper: Double)
}
