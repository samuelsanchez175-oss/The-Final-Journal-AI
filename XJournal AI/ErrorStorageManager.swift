import Foundation
import SwiftData

// MARK: - Error Record

struct AIErrorRecord: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let message: String
    let source: String // e.g., "AI Sparkle Button", "Model G", "Model Y"
    let context: String? // Optional context about what was happening
    
    init(id: UUID = UUID(), timestamp: Date = Date(), message: String, source: String, context: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.message = message
        self.source = source
        self.context = context
    }
}

// MARK: - Error Storage Manager

class ErrorStorageManager {
    static let shared = ErrorStorageManager()
    
    private let maxErrors = 1000 // Limit stored errors
    private let errorStorageKey = "ai_errors"
    
    private init() {}
    
    // MARK: - Error Storage
    
    /// Store an error
    func storeError(_ message: String, source: String, context: String? = nil) {
        let error = AIErrorRecord(message: message, source: source, context: context)
        
        var errors = getAllErrors()
        errors.insert(error, at: 0) // Add to beginning
        
        // Limit to maxErrors
        if errors.count > maxErrors {
            errors = Array(errors.prefix(maxErrors))
        }
        
        saveErrors(errors)
    }
    
    /// Get all stored errors
    func getAllErrors() -> [AIErrorRecord] {
        guard let data = UserDefaults.standard.data(forKey: errorStorageKey),
              let errors = try? JSONDecoder().decode([AIErrorRecord].self, from: data) else {
            return []
        }
        return errors
    }
    
    /// Get errors filtered by source
    func getErrors(source: String) -> [AIErrorRecord] {
        return getAllErrors().filter { $0.source == source }
    }
    
    /// Get recent errors (last N)
    func getRecentErrors(limit: Int = 50) -> [AIErrorRecord] {
        return Array(getAllErrors().prefix(limit))
    }
    
    /// Clear all errors
    func clearAllErrors() {
        UserDefaults.standard.removeObject(forKey: errorStorageKey)
    }
    
    /// Clear errors older than specified days
    func clearOldErrors(olderThanDays days: Int) {
        let cutoffDate = Date().addingTimeInterval(-Double(days * 24 * 60 * 60))
        var errors = getAllErrors()
        errors = errors.filter { $0.timestamp > cutoffDate }
        saveErrors(errors)
    }
    
    // MARK: - Private Helpers
    
    private func saveErrors(_ errors: [AIErrorRecord]) {
        if let encoded = try? JSONEncoder().encode(errors) {
            UserDefaults.standard.set(encoded, forKey: errorStorageKey)
        }
    }
    
    // MARK: - Statistics
    
    struct ErrorStats {
        let totalErrors: Int
        let errorsBySource: [String: Int]
        let recentErrorCount: Int // Last 24 hours
        let mostCommonError: String?
    }
    
    func getErrorStats() -> ErrorStats {
        let allErrors = getAllErrors()
        let totalErrors = allErrors.count
        
        // Group by source
        var errorsBySource: [String: Int] = [:]
        for error in allErrors {
            errorsBySource[error.source, default: 0] += 1
        }
        
        // Count recent errors (last 24 hours)
        let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        let recentErrorCount = allErrors.filter { $0.timestamp > oneDayAgo }.count
        
        // Find most common error message
        var errorCounts: [String: Int] = [:]
        for error in allErrors {
            errorCounts[error.message, default: 0] += 1
        }
        let mostCommonError = errorCounts.max(by: { $0.value < $1.value })?.key
        
        return ErrorStats(
            totalErrors: totalErrors,
            errorsBySource: errorsBySource,
            recentErrorCount: recentErrorCount,
            mostCommonError: mostCommonError
        )
    }
}
