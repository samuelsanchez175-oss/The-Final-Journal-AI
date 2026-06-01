import Foundation

// MARK: - Error Correlation Analyzer

class ErrorCorrelationAnalyzer {
    static let shared = ErrorCorrelationAnalyzer()
    
    private init() {}
    
    // MARK: - Analysis Results
    
    struct CorrelationAnalysis {
        let errorSequences: [ErrorSequence]
        let commonErrorPaths: [ErrorPath]
        let errorFrequencyByTime: [Int: Int] // Hour of day -> count
        let errorFrequencyByFeature: [String: Int]
        let errorClusters: [ErrorCluster]
        let rootCauseSuggestions: [RootCauseSuggestion]
        
        struct ErrorSequence {
            let errors: [String] // Error messages in sequence
            let frequency: Int
            let timeBetweenErrors: TimeInterval? // Average time between errors
        }
        
        struct ErrorPath {
            let path: [String] // Sequence of actions/features leading to error
            let error: String
            let frequency: Int
        }
        
        struct ErrorCluster {
            let errors: [String] // Similar errors grouped together
            let commonPattern: String
            let frequency: Int
        }
        
        struct RootCauseSuggestion {
            let error: String
            let suggestedCause: String
            let confidence: Double // 0.0-1.0
            let evidence: [String]
        }
    }
    
    // MARK: - Analyze Errors
    
    func analyzeErrors() -> CorrelationAnalysis {
        let allErrors = ErrorStorageManager.shared.getAllErrors()
        
        // Analyze error sequences
        let errorSequences = findErrorSequences(errors: allErrors)
        
        // Find common error paths (action sequences leading to errors)
        let errorPaths = findErrorPaths(errors: allErrors)
        
        // Analyze error frequency by time of day
        let errorFrequencyByTime = analyzeErrorFrequencyByTime(errors: allErrors)
        
        // Analyze error frequency by feature/source
        let errorFrequencyByFeature = analyzeErrorFrequencyByFeature(errors: allErrors)
        
        // Cluster similar errors
        let errorClusters = clusterErrors(errors: allErrors)
        
        // Generate root cause suggestions
        let rootCauseSuggestions = generateRootCauseSuggestions(
            errors: allErrors,
            sequences: errorSequences,
            clusters: errorClusters
        )
        
        return CorrelationAnalysis(
            errorSequences: errorSequences,
            commonErrorPaths: errorPaths,
            errorFrequencyByTime: errorFrequencyByTime,
            errorFrequencyByFeature: errorFrequencyByFeature,
            errorClusters: errorClusters,
            rootCauseSuggestions: rootCauseSuggestions
        )
    }
    
    // MARK: - Private Analysis Methods
    
    private func findErrorSequences(errors: [AIErrorRecord]) -> [CorrelationAnalysis.ErrorSequence] {
        var sequences: [String: (errors: [String], timestamps: [Date])] = [:]
        
        // Group errors by source and find sequences
        let errorsBySource = Dictionary(grouping: errors) { $0.source }
        
        for (_, sourceErrors) in errorsBySource {
            let sortedErrors = sourceErrors.sorted { $0.timestamp < $1.timestamp }
            
            // Find sequences of 2-3 consecutive errors
            for i in 0..<(sortedErrors.count - 1) {
                let error1 = sortedErrors[i]
                let error2 = sortedErrors[i + 1]
                
                // If errors are within 5 minutes, consider them a sequence
                let timeDiff = error2.timestamp.timeIntervalSince(error1.timestamp)
                if timeDiff < 300 { // 5 minutes
                    let sequenceKey = "\(error1.message)|\(error2.message)"
                    if sequences[sequenceKey] == nil {
                        sequences[sequenceKey] = (errors: [error1.message, error2.message], timestamps: [error1.timestamp, error2.timestamp])
                    } else {
                        sequences[sequenceKey]?.errors.append(error2.message)
                        sequences[sequenceKey]?.timestamps.append(error2.timestamp)
                    }
                }
            }
        }
        
        return sequences.map { key, value in
            let timeDiffs = zip(value.timestamps, value.timestamps.dropFirst()).map { $1.timeIntervalSince($0) }
            let avgTimeDiff = timeDiffs.isEmpty ? nil : timeDiffs.reduce(0, +) / Double(timeDiffs.count)
            
            return CorrelationAnalysis.ErrorSequence(
                errors: Array(Set(value.errors)), // Remove duplicates
                frequency: value.errors.count,
                timeBetweenErrors: avgTimeDiff
            )
        }.sorted { $0.frequency > $1.frequency }
    }
    
    private func findErrorPaths(errors: [AIErrorRecord]) -> [CorrelationAnalysis.ErrorPath] {
        var paths: [String: (path: [String], error: String, count: Int)] = [:]
        
        for error in errors {
            // Extract path from context if available
            if let context = error.context {
                // Try to extract feature/action from context
                let pathComponents = extractPathFromContext(context)
                let pathKey = pathComponents.joined(separator: " -> ")
                
                if paths[pathKey] == nil {
                    paths[pathKey] = (path: pathComponents, error: error.message, count: 1)
                } else {
                    paths[pathKey]?.count += 1
                }
            } else {
                // Use source as path
                let pathKey = error.source
                if paths[pathKey] == nil {
                    paths[pathKey] = (path: [error.source], error: error.message, count: 1)
                } else {
                    paths[pathKey]?.count += 1
                }
            }
        }
        
        return paths.map { key, value in
            CorrelationAnalysis.ErrorPath(
                path: value.path,
                error: value.error,
                frequency: value.count
            )
        }.sorted { $0.frequency > $1.frequency }
    }
    
    private func extractPathFromContext(_ context: String) -> [String] {
        // Simple extraction - look for common patterns
        var components: [String] = []
        
        // Look for feature names
        if context.contains("narrative_analysis") {
            components.append("Narrative Analysis")
        }
        if context.contains("suggestions") {
            components.append("Suggestions")
        }
        if context.contains("API") {
            components.append("API Call")
        }
        if context.contains("parsing") {
            components.append("JSON Parsing")
        }
        if context.contains("validation") {
            components.append("Validation")
        }
        
        // If no specific features found, use source
        if components.isEmpty {
            components.append("Unknown")
        }
        
        return components
    }
    
    private func analyzeErrorFrequencyByTime(errors: [AIErrorRecord]) -> [Int: Int] {
        var frequency: [Int: Int] = [:]
        
        let calendar = Calendar.current
        for error in errors {
            let hour = calendar.component(.hour, from: error.timestamp)
            frequency[hour, default: 0] += 1
        }
        
        return frequency
    }
    
    private func analyzeErrorFrequencyByFeature(errors: [AIErrorRecord]) -> [String: Int] {
        var frequency: [String: Int] = [:]
        
        for error in errors {
            frequency[error.source, default: 0] += 1
        }
        
        return frequency
    }
    
    private func clusterErrors(errors: [AIErrorRecord]) -> [CorrelationAnalysis.ErrorCluster] {
        // Group errors by similar messages
        var clusters: [String: [String]] = [:]
        
        for error in errors {
            // Extract key words from error message
            let keyWords = extractKeyWords(error.message)
            let clusterKey = keyWords.sorted().joined(separator: " ")
            
            if clusters[clusterKey] == nil {
                clusters[clusterKey] = []
            }
            clusters[clusterKey]?.append(error.message)
        }
        
        return clusters.map { key, messages in
            let uniqueMessages = Array(Set(messages))
            return CorrelationAnalysis.ErrorCluster(
                errors: uniqueMessages,
                commonPattern: key,
                frequency: messages.count
            )
        }.sorted { $0.frequency > $1.frequency }
    }
    
    private func extractKeyWords(_ message: String) -> [String] {
        let lowercased = message.lowercased()
        let words = lowercased.components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }
            .filter { !stopWords.contains($0) }
        
        return Array(Set(words)).prefix(5).map { $0 }
    }
    
    private let stopWords = Set(["the", "and", "for", "are", "but", "not", "you", "all", "can", "her", "was", "one", "our", "out", "day", "get", "has", "him", "his", "how", "its", "may", "new", "now", "old", "see", "two", "way", "who", "boy", "did", "she", "use", "her", "many", "than", "them", "these", "this", "that", "with", "from", "have", "been", "will", "what", "when", "where", "which", "failed", "error", "invalid", "unable"])
    
    private func generateRootCauseSuggestions(
        errors: [AIErrorRecord],
        sequences: [CorrelationAnalysis.ErrorSequence],
        clusters: [CorrelationAnalysis.ErrorCluster]
    ) -> [CorrelationAnalysis.RootCauseSuggestion] {
        var suggestions: [CorrelationAnalysis.RootCauseSuggestion] = []
        
        // Analyze common error patterns
        for cluster in clusters.prefix(5) {
            if cluster.frequency > 3 {
                let commonPattern = cluster.commonPattern
                let suggestedCause = inferRootCause(from: commonPattern, errors: cluster.errors)
                let confidence = min(Double(cluster.frequency) / 10.0, 1.0)
                
                suggestions.append(CorrelationAnalysis.RootCauseSuggestion(
                    error: cluster.errors.first ?? "Unknown error",
                    suggestedCause: suggestedCause,
                    confidence: confidence,
                    evidence: [
                        "Occurs \(cluster.frequency) times",
                        "Pattern: \(commonPattern)"
                    ]
                ))
            }
        }
        
        // Analyze error sequences
        for sequence in sequences.prefix(3) {
            if sequence.frequency > 2 {
                let suggestedCause = inferRootCauseFromSequence(sequence)
                let confidence = min(Double(sequence.frequency) / 5.0, 1.0)
                
                suggestions.append(CorrelationAnalysis.RootCauseSuggestion(
                    error: sequence.errors.joined(separator: " -> "),
                    suggestedCause: suggestedCause,
                    confidence: confidence,
                    evidence: [
                        "Sequence occurs \(sequence.frequency) times",
                        "Errors: \(sequence.errors.joined(separator: ", "))"
                    ]
                ))
            }
        }
        
        return suggestions.sorted { $0.confidence > $1.confidence }
    }
    
    private func inferRootCause(from pattern: String, errors: [String]) -> String {
        let lowerPattern = pattern.lowercased()
        
        if lowerPattern.contains("json") || lowerPattern.contains("parsing") || lowerPattern.contains("decode") {
            return "JSON parsing/validation issue - API may be returning malformed responses or unexpected structure"
        }
        if lowerPattern.contains("network") || lowerPattern.contains("connection") || lowerPattern.contains("timeout") {
            return "Network connectivity issue - check internet connection and API endpoint availability"
        }
        if lowerPattern.contains("token") || lowerPattern.contains("limit") || lowerPattern.contains("quota") {
            return "API quota/rate limit exceeded - may need to wait or upgrade API plan"
        }
        if lowerPattern.contains("key") || lowerPattern.contains("auth") || lowerPattern.contains("unauthorized") {
            return "Authentication issue - API key may be invalid or expired"
        }
        if lowerPattern.contains("validation") || lowerPattern.contains("schema") {
            return "Data validation failure - response structure doesn't match expected schema"
        }
        
        return "Unknown root cause - requires further investigation"
    }
    
    private func inferRootCauseFromSequence(_ sequence: CorrelationAnalysis.ErrorSequence) -> String {
        let errors = sequence.errors.joined(separator: " ").lowercased()
        
        if errors.contains("json") && errors.contains("network") {
            return "Network issue causing JSON parsing failures - intermittent connectivity"
        }
        if errors.contains("timeout") && errors.contains("retry") {
            return "API timeout issues - may need to increase timeout or implement better retry logic"
        }
        
        return "Error sequence suggests cascading failure - first error may trigger subsequent errors"
    }
}
