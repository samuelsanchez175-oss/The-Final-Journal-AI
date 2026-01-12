import Foundation

// MARK: - Signal Pattern Summary

struct SignalPatternSummary {
    let noteType: SignalNoteType
    let frequency: Int
    let timeWindow: TimeInterval
    let lastOccurrence: Date?
    
    var displayText: String {
        let timeDescription: String
        if timeWindow < 86400 { // Less than a day
            timeDescription = "today"
        } else if timeWindow < 604800 { // Less than a week
            timeDescription = "this week"
        } else {
            timeDescription = "this month"
        }
        
        return "\(noteType.rawValue.capitalized) (\(frequency)× \(timeDescription))"
    }
}

// MARK: - Signal Memory

class SignalMemory {
    static let shared = SignalMemory()
    
    private let userDefaults = UserDefaults.standard
    private let patternKeyPrefix = "signal_pattern_"
    private let timestampKeyPrefix = "signal_timestamp_"
    
    private init() {}
    
    // MARK: - Record Signal Pattern
    
    func recordSignalPattern(noteType: SignalNoteType, timestamp: Date = Date()) {
        let key = patternKeyPrefix + noteType.rawValue
        let timestampKey = timestampKeyPrefix + noteType.rawValue
        
        // Get existing count
        let currentCount = userDefaults.integer(forKey: key)
        userDefaults.set(currentCount + 1, forKey: key)
        
        // Store timestamp
        userDefaults.set(timestamp.timeIntervalSince1970, forKey: timestampKey)
        
        // Also store in array for time-based queries
        let historyKey = "signal_history_\(noteType.rawValue)"
        var timestamps = userDefaults.array(forKey: historyKey) as? [TimeInterval] ?? []
        timestamps.append(timestamp.timeIntervalSince1970)
        
        // Keep only last 100 timestamps
        if timestamps.count > 100 {
            timestamps = Array(timestamps.suffix(100))
        }
        
        userDefaults.set(timestamps, forKey: historyKey)
    }
    
    // MARK: - Get Pattern Frequency
    
    func getPatternFrequency(noteType: SignalNoteType, timeWindow: TimeInterval) -> Int {
        let historyKey = "signal_history_\(noteType.rawValue)"
        guard let timestamps = userDefaults.array(forKey: historyKey) as? [TimeInterval] else {
            return 0
        }
        
        let cutoffTime = Date().timeIntervalSince1970 - timeWindow
        return timestamps.filter { $0 >= cutoffTime }.count
    }
    
    // MARK: - Get Pattern Summary
    
    func getPatternSummary(noteType: SignalNoteType, timeWindow: TimeInterval = 86400) -> SignalPatternSummary {
        let frequency = getPatternFrequency(noteType: noteType, timeWindow: timeWindow)
        
        let timestampKey = timestampKeyPrefix + noteType.rawValue
        let lastTimestamp = userDefaults.double(forKey: timestampKey)
        let lastOccurrence = lastTimestamp > 0 ? Date(timeIntervalSince1970: lastTimestamp) : nil
        
        return SignalPatternSummary(
            noteType: noteType,
            frequency: frequency,
            timeWindow: timeWindow,
            lastOccurrence: lastOccurrence
        )
    }
    
    // MARK: - Get All Pattern Summaries
    
    func getAllPatternSummaries(timeWindow: TimeInterval = 86400) -> [SignalPatternSummary] {
        let allTypes: [SignalNoteType] = [
            .overExplaining, .vagueImagery, .weakSpeakerPosition, .genericFlex,
            .tooMuchDetail, .defensiveTone, .noSocialAction, .emotionalSpill,
            .unclearAudience, .fillerLanguage, .authorityWithoutEarning,
            .overAbstracted, .repetitiveSignal, .moodCarryingLine, .closureTooEarly
        ]
        
        return allTypes.map { type in
            getPatternSummary(noteType: type, timeWindow: timeWindow)
        }.filter { $0.frequency > 0 }
        .sorted { $0.frequency > $1.frequency }
    }
    
    // MARK: - Record Patterns from Suggestions
    
    func recordPatterns(from suggestions: [RapSuggestion]) {
        for suggestion in suggestions {
            if let signalNote = suggestion.signalNote {
                // Determine note type from note text
                if let noteType = determineNoteType(from: signalNote) {
                    recordSignalPattern(noteType: noteType)
                }
            }
        }
    }
    
    // MARK: - Determine Note Type from Text
    
    private func determineNoteType(from noteText: String) -> SignalNoteType? {
        let lowercased = noteText.lowercased()
        
        // Match note text to type (using key phrases from templates)
        if lowercased.contains("explains intent") || lowercased.contains("explains instead") {
            return .overExplaining
        } else if lowercased.contains("imagery sets a mood") || lowercased.contains("nothing is at risk") {
            return .vagueImagery
        } else if lowercased.contains("observational, not lived") || lowercased.contains("unclear why you") {
            return .weakSpeakerPosition
        } else if lowercased.contains("names success without") || lowercased.contains("interchangeable") {
            return .genericFlex
        } else if lowercased.contains("specifics here reduce") || lowercased.contains("fewer details") {
            return .tooMuchDetail
        } else if lowercased.contains("answers a criticism") || lowercased.contains("back foot") {
            return .defensiveTone
        } else if lowercased.contains("isn't doing anything") || lowercased.contains("no flex, no warning") {
            return .noSocialAction
        } else if lowercased.contains("emotion is clear, but unfiltered") || lowercased.contains("restraint would") {
            return .emotionalSpill
        } else if lowercased.contains("not clear who this line is for") || lowercased.contains("narrowing the audience") {
            return .unclearAudience
        } else if lowercased.contains("carrying rhythm, not meaning") || lowercased.contains("cutting them would") {
            return .fillerLanguage
        } else if lowercased.contains("confidence jumps ahead") || lowercased.contains("needs proof") {
            return .authorityWithoutEarning
        } else if lowercased.contains("too abstract") || lowercased.contains("concrete anchor") {
            return .overAbstracted
        } else if lowercased.contains("repeats information") || lowercased.contains("escalation or silence") {
            return .repetitiveSignal
        } else if lowercased.contains("atmosphere is doing") || lowercased.contains("clearer position") {
            return .moodCarryingLine
        } else if lowercased.contains("resolves tension too fast") || lowercased.contains("leaving it open") {
            return .closureTooEarly
        }
        
        return nil
    }
    
    // MARK: - Clear Patterns
    
    func clearPatterns() {
        let allTypes: [SignalNoteType] = [
            .overExplaining, .vagueImagery, .weakSpeakerPosition, .genericFlex,
            .tooMuchDetail, .defensiveTone, .noSocialAction, .emotionalSpill,
            .unclearAudience, .fillerLanguage, .authorityWithoutEarning,
            .overAbstracted, .repetitiveSignal, .moodCarryingLine, .closureTooEarly
        ]
        
        for type in allTypes {
            let key = patternKeyPrefix + type.rawValue
            let timestampKey = timestampKeyPrefix + type.rawValue
            let historyKey = "signal_history_\(type.rawValue)"
            
            userDefaults.removeObject(forKey: key)
            userDefaults.removeObject(forKey: timestampKey)
            userDefaults.removeObject(forKey: historyKey)
        }
    }
}
