import Foundation

// MARK: - Token Usage Tracker

class TokenUsageTracker {
    static let shared = TokenUsageTracker()
    
    private init() {}
    
    // MARK: - Token Usage Record
    
    struct TokenUsageRecord: Codable, Identifiable {
        let id: UUID
        let timestamp: Date
        let model: String
        let endpoint: String
        let inputTokens: Int
        let outputTokens: Int
        let totalTokens: Int
        let estimatedCost: Double
        let feature: String // "narrative_analysis", "suggestions", etc.
        
        init(
            id: UUID = UUID(),
            timestamp: Date = Date(),
            model: String,
            endpoint: String,
            inputTokens: Int,
            outputTokens: Int,
            feature: String
        ) {
            self.id = id
            self.timestamp = timestamp
            self.model = model
            self.endpoint = endpoint
            self.inputTokens = inputTokens
            self.outputTokens = outputTokens
            self.totalTokens = inputTokens + outputTokens
            self.estimatedCost = Self.calculateCost(model: model, inputTokens: inputTokens, outputTokens: outputTokens)
            self.feature = feature
        }
        
        // Model pricing per 1M tokens (as of 2024)
        // These should be updated based on current OpenAI pricing
        private static func calculateCost(model: String, inputTokens: Int, outputTokens: Int) -> Double {
            let inputCostPer1M: Double
            let outputCostPer1M: Double
            
            if model.contains("gpt-4-turbo") || model.contains("gpt-4-turbo-preview") {
                inputCostPer1M = 10.0 // $10 per 1M input tokens
                outputCostPer1M = 30.0 // $30 per 1M output tokens
            } else if model.contains("gpt-4") {
                inputCostPer1M = 30.0 // $30 per 1M input tokens
                outputCostPer1M = 60.0 // $60 per 1M output tokens
            } else if model.contains("gpt-3.5-turbo") {
                inputCostPer1M = 0.5 // $0.50 per 1M input tokens
                outputCostPer1M = 1.5 // $1.50 per 1M output tokens
            } else {
                // Default to gpt-4-turbo pricing
                inputCostPer1M = 10.0
                outputCostPer1M = 30.0
            }
            
            let inputCost = (Double(inputTokens) / 1_000_000.0) * inputCostPer1M
            let outputCost = (Double(outputTokens) / 1_000_000.0) * outputCostPer1M
            
            return inputCost + outputCost
        }
    }
    
    // MARK: - Storage
    
    private let maxRecords = 1000
    private let recordsStorageKey = "token_usage_records"
    
    // MARK: - Track Usage
    
    func trackUsage(
        model: String,
        endpoint: String,
        inputTokens: Int,
        outputTokens: Int,
        feature: String
    ) {
        let record = TokenUsageRecord(
            model: model,
            endpoint: endpoint,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            feature: feature
        )
        
        storeRecord(record)
        
        // Log to console
        print("💰 Token Usage: \(record.totalTokens) tokens (\(inputTokens) in, \(outputTokens) out)")
        print("   Cost: $\(String(format: "%.4f", record.estimatedCost))")
        print("   Model: \(model), Feature: \(feature)")
    }
    
    // MARK: - Storage Management
    
    private func storeRecord(_ record: TokenUsageRecord) {
        var allRecords = getAllRecords()
        allRecords.insert(record, at: 0)
        
        if allRecords.count > maxRecords {
            allRecords = Array(allRecords.prefix(maxRecords))
        }
        
        if let encoded = try? JSONEncoder().encode(allRecords) {
            UserDefaults.standard.set(encoded, forKey: recordsStorageKey)
        }
    }
    
    func getAllRecords() -> [TokenUsageRecord] {
        guard let data = UserDefaults.standard.data(forKey: recordsStorageKey),
              let records = try? JSONDecoder().decode([TokenUsageRecord].self, from: data) else {
            return []
        }
        return records
    }
    
    func getRecentRecords(limit: Int = 100) -> [TokenUsageRecord] {
        return Array(getAllRecords().prefix(limit))
    }
    
    func clearAllRecords() {
        UserDefaults.standard.removeObject(forKey: recordsStorageKey)
    }
    
    func clearOldRecords(olderThanDays days: Int) {
        let cutoffDate = Date().addingTimeInterval(-Double(days * 24 * 60 * 60))
        let records = getAllRecords().filter { $0.timestamp > cutoffDate }
        
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsStorageKey)
        }
    }
    
    // MARK: - Statistics
    
    struct TokenStats {
        let totalTokens: Int
        let totalInputTokens: Int
        let totalOutputTokens: Int
        let totalCost: Double
        let averageTokensPerRequest: Double
        let averageCostPerRequest: Double
        let tokensByModel: [String: Int]
        let tokensByFeature: [String: Int]
        let costByModel: [String: Double]
        let costByFeature: [String: Double]
        let requestCount: Int
    }
    
    func getStats(timeRange: TimeInterval? = nil) -> TokenStats {
        var records = getAllRecords()
        
        if let timeRange = timeRange {
            let cutoffDate = Date().addingTimeInterval(-timeRange)
            records = records.filter { $0.timestamp > cutoffDate }
        }
        
        guard !records.isEmpty else {
            return TokenStats(
                totalTokens: 0,
                totalInputTokens: 0,
                totalOutputTokens: 0,
                totalCost: 0,
                averageTokensPerRequest: 0,
                averageCostPerRequest: 0,
                tokensByModel: [:],
                tokensByFeature: [:],
                costByModel: [:],
                costByFeature: [:],
                requestCount: 0
            )
        }
        
        let totalTokens = records.reduce(0) { $0 + $1.totalTokens }
        let totalInputTokens = records.reduce(0) { $0 + $1.inputTokens }
        let totalOutputTokens = records.reduce(0) { $0 + $1.outputTokens }
        let totalCost = records.reduce(0.0) { $0 + $1.estimatedCost }
        
        let averageTokensPerRequest = Double(totalTokens) / Double(records.count)
        let averageCostPerRequest = totalCost / Double(records.count)
        
        var tokensByModel: [String: Int] = [:]
        var tokensByFeature: [String: Int] = [:]
        var costByModel: [String: Double] = [:]
        var costByFeature: [String: Double] = [:]
        
        for record in records {
            tokensByModel[record.model, default: 0] += record.totalTokens
            tokensByFeature[record.feature, default: 0] += record.totalTokens
            costByModel[record.model, default: 0.0] += record.estimatedCost
            costByFeature[record.feature, default: 0.0] += record.estimatedCost
        }
        
        return TokenStats(
            totalTokens: totalTokens,
            totalInputTokens: totalInputTokens,
            totalOutputTokens: totalOutputTokens,
            totalCost: totalCost,
            averageTokensPerRequest: averageTokensPerRequest,
            averageCostPerRequest: averageCostPerRequest,
            tokensByModel: tokensByModel,
            tokensByFeature: tokensByFeature,
            costByModel: costByModel,
            costByFeature: costByFeature,
            requestCount: records.count
        )
    }
    
    // MARK: - Daily/Weekly/Monthly Stats
    
    func getDailyStats() -> TokenStats {
        return getStats(timeRange: 24 * 60 * 60) // Last 24 hours
    }
    
    func getWeeklyStats() -> TokenStats {
        return getStats(timeRange: 7 * 24 * 60 * 60) // Last 7 days
    }
    
    func getMonthlyStats() -> TokenStats {
        return getStats(timeRange: 30 * 24 * 60 * 60) // Last 30 days
    }
}
