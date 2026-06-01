import Foundation

// MARK: - JSON Validation Service

class JSONValidationService {
    static let shared = JSONValidationService()
    
    private init() {}
    
    // MARK: - Validation Result
    
    struct ValidationResult {
        let isValid: Bool
        let errors: [ValidationError]
        let warnings: [ValidationWarning]
        
        struct ValidationError {
            let field: String
            let expectedType: String
            let actualType: String?
            let position: Int?
            let message: String
        }
        
        struct ValidationWarning {
            let field: String
            let message: String
        }
    }
    
    // MARK: - Validation Records
    
    struct ValidationRecord: Codable, Identifiable {
        let id: UUID
        let timestamp: Date
        let endpoint: String
        let isValid: Bool
        let errors: [String]
        let errorCount: Int
        let responseSize: Int
        let validationDuration: TimeInterval
        
        init(
            id: UUID = UUID(),
            timestamp: Date = Date(),
            endpoint: String,
            isValid: Bool,
            errors: [String],
            responseSize: Int,
            validationDuration: TimeInterval
        ) {
            self.id = id
            self.timestamp = timestamp
            self.endpoint = endpoint
            self.isValid = isValid
            self.errors = errors
            self.errorCount = errors.count
            self.responseSize = responseSize
            self.validationDuration = validationDuration
        }
    }
    
    // MARK: - Storage
    
    private let maxRecords = 500
    private let recordsStorageKey = "json_validation_records"
    
    // MARK: - Helper Methods
    
    // MARK: - Validate Suggestions Response
    
    func validateSuggestionsResponse(_ data: Data) -> ValidationResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        var errors: [ValidationResult.ValidationError] = []
        var warnings: [ValidationResult.ValidationWarning] = []
        
        // Check if it's valid JSON
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            let error = ValidationResult.ValidationError(
                field: "root",
                expectedType: "JSON Object",
                actualType: nil,
                position: nil,
                message: "Response is not valid JSON"
            )
            return ValidationResult(isValid: false, errors: [error], warnings: [])
        }
        
        // Check for suggestions array - this is the ONLY required field
        // All other fields (themes, narrative analysis, etc.) are optional and will use fallbacks
        guard let suggestions = jsonObject["suggestions"] else {
            // Check if there's a narrative analysis object that might contain suggestions
            if jsonObject["narrativeAnalysis"] as? [String: Any] != nil {
                // If we have narrative analysis but no suggestions, that's a warning, not an error
                warnings.append(ValidationResult.ValidationWarning(
                    field: "suggestions",
                    message: "No 'suggestions' array found, but narrative analysis is present. Suggestions may be in a different format."
                ))
            } else {
                // Only error if we truly have no suggestions and no narrative analysis
                errors.append(ValidationResult.ValidationError(
                    field: "suggestions",
                    expectedType: "Array",
                    actualType: nil,
                    position: nil,
                    message: "Required field 'suggestions' is missing"
                ))
            }
            
            // If we have errors, return early
            if !errors.isEmpty {
                let duration = CFAbsoluteTimeGetCurrent() - startTime
                let result = ValidationResult(isValid: false, errors: errors, warnings: warnings)
                
                storeValidationRecord(
                    endpoint: "suggestions",
                    isValid: false,
                    errors: errors.map { $0.message },
                    responseSize: data.count,
                    validationDuration: duration
                )
                
                return result
            }
            
            // If only warnings, continue validation but mark as valid
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            let result = ValidationResult(isValid: true, errors: [], warnings: warnings)
            
            storeValidationRecord(
                endpoint: "suggestions",
                isValid: true,
                errors: [],
                responseSize: data.count,
                validationDuration: duration
            )
            
            return result
        }
        
        guard let suggestionsArray = suggestions as? [Any] else {
            errors.append(ValidationResult.ValidationError(
                field: "suggestions",
                expectedType: "Array",
                actualType: typeDescription(of: suggestions),
                position: nil,
                message: "Field 'suggestions' must be an Array"
            ))
            
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            let result = ValidationResult(isValid: false, errors: errors, warnings: warnings)
            
            storeValidationRecord(
                endpoint: "suggestions",
                isValid: false,
                errors: errors.map { $0.message },
                responseSize: data.count,
                validationDuration: duration
            )
            
            return result
        }
        
        // Validate each suggestion
        for (index, suggestion) in suggestionsArray.enumerated() {
            guard let suggestionDict = suggestion as? [String: Any] else {
                errors.append(ValidationResult.ValidationError(
                    field: "suggestions[\(index)]",
                    expectedType: "Object",
                    actualType: typeDescription(of: suggestion),
                    position: nil,
                    message: "suggestions[\(index)] must be an Object"
                ))
                continue
            }
            
            // Check required fields in suggestion
            if !suggestionDict.keys.contains("text") {
                errors.append(ValidationResult.ValidationError(
                    field: "suggestions[\(index)].text",
                    expectedType: "String",
                    actualType: nil,
                    position: nil,
                    message: "suggestions[\(index)].text is required"
                ))
            } else if let text = suggestionDict["text"], !(text is String) {
                errors.append(ValidationResult.ValidationError(
                    field: "suggestions[\(index)].text",
                    expectedType: "String",
                    actualType: typeDescription(of: text),
                    position: nil,
                    message: "suggestions[\(index)].text must be a String"
                ))
            }
            
            // Check optional fields
            if let confidence = suggestionDict["confidence"] {
                if !(confidence is Double) && !(confidence is Int) {
                    warnings.append(ValidationResult.ValidationWarning(
                        field: "suggestions[\(index)].confidence",
                        message: "confidence should be a Number (Double), got \(typeDescription(of: confidence))"
                    ))
                }
            }
            
            if let themes = suggestionDict["themes"] {
                if !(themes is [String]) && !(themes is [Any]) {
                    warnings.append(ValidationResult.ValidationWarning(
                        field: "suggestions[\(index)].themes",
                        message: "themes should be an Array<String>, got \(typeDescription(of: themes))"
                    ))
                }
            }
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let result = ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
        
        storeValidationRecord(
            endpoint: "suggestions",
            isValid: result.isValid,
            errors: result.errors.map { $0.message },
            responseSize: data.count,
            validationDuration: duration
        )
        
        return result
    }
    
    // MARK: - Helper Methods
    
    private func typeDescription(of value: Any) -> String {
        switch value {
        case is String: return "String"
        case is Int: return "Int"
        case is Double: return "Double"
        case is Bool: return "Bool"
        case is [Any]: return "Array"
        case is [String: Any]: return "Object"
        case is NSNull: return "Null"
        default: return "Unknown"
        }
    }
    
    private func isTypeMatch(expectedType: String, actualValue: Any) -> Bool {
        switch expectedType {
        case "String":
            return actualValue is String
        case "Array<String>":
            return actualValue is [String] || (actualValue is [Any] && (actualValue as? [Any])?.allSatisfy { $0 is String } == true)
        case "Array":
            return actualValue is [Any]
        case "Object":
            return actualValue is [String: Any]
        case "Int":
            return actualValue is Int
        case "Double":
            return actualValue is Double || actualValue is Int
        case "Bool":
            return actualValue is Bool
        default:
            return true // Unknown type, don't validate
        }
    }
    
    // MARK: - Storage Management
    
    private func storeValidationRecord(
        endpoint: String,
        isValid: Bool,
        errors: [String],
        responseSize: Int,
        validationDuration: TimeInterval
    ) {
        let record = ValidationRecord(
            endpoint: endpoint,
            isValid: isValid,
            errors: errors,
            responseSize: responseSize,
            validationDuration: validationDuration
        )
        
        var allRecords = getAllRecords()
        allRecords.insert(record, at: 0)
        
        if allRecords.count > maxRecords {
            allRecords = Array(allRecords.prefix(maxRecords))
        }
        
        if let encoded = try? JSONEncoder().encode(allRecords) {
            UserDefaults.standard.set(encoded, forKey: recordsStorageKey)
        }
    }
    
    func getAllRecords() -> [ValidationRecord] {
        guard let data = UserDefaults.standard.data(forKey: recordsStorageKey),
              let records = try? JSONDecoder().decode([ValidationRecord].self, from: data) else {
            return []
        }
        return records
    }
    
    func getRecentRecords(limit: Int = 100) -> [ValidationRecord] {
        return Array(getAllRecords().prefix(limit))
    }
    
    func clearAllRecords() {
        UserDefaults.standard.removeObject(forKey: recordsStorageKey)
    }
    
    // MARK: - Statistics
    
    struct ValidationStats {
        let totalValidations: Int
        let successRate: Double
        let averageValidationDuration: TimeInterval
        let errorsByField: [String: Int]
        let errorsByEndpoint: [String: Int]
        let recentErrors: [String]
    }
    
    func getStats(timeRange: TimeInterval? = nil) -> ValidationStats {
        var records = getAllRecords()
        
        if let timeRange = timeRange {
            let cutoffDate = Date().addingTimeInterval(-timeRange)
            records = records.filter { $0.timestamp > cutoffDate }
        }
        
        guard !records.isEmpty else {
            return ValidationStats(
                totalValidations: 0,
                successRate: 0,
                averageValidationDuration: 0,
                errorsByField: [:],
                errorsByEndpoint: [:],
                recentErrors: []
            )
        }
        
        let successful = records.filter { $0.isValid }
        let successRate = Double(successful.count) / Double(records.count)
        
        let averageDuration = records.map { $0.validationDuration }.reduce(0, +) / Double(records.count)
        
        var errorsByField: [String: Int] = [:]
        var errorsByEndpoint: [String: Int] = [:]
        
        for record in records where !record.isValid {
            errorsByEndpoint[record.endpoint, default: 0] += 1
            
            for error in record.errors {
                // Extract field name from error message
                if let fieldMatch = error.range(of: #"'([^']+)'"#, options: .regularExpression) {
                    let field = String(error[fieldMatch])
                    errorsByField[field, default: 0] += 1
                }
            }
        }
        
        // Filter to only show errors from the last 24 hours to avoid stale errors
        let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        let recentErrors = records
            .filter { !$0.isValid && $0.timestamp > oneDayAgo }
            .prefix(10)
            .flatMap { $0.errors }
        
        return ValidationStats(
            totalValidations: records.count,
            successRate: successRate,
            averageValidationDuration: averageDuration,
            errorsByField: errorsByField,
            errorsByEndpoint: errorsByEndpoint,
            recentErrors: Array(recentErrors)
        )
    }
}
