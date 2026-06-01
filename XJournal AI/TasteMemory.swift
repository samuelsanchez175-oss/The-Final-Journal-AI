import Foundation

// MARK: - Taste Action

enum TasteAction: String, Codable {
    case accepted
    case rejected
    case edited
}

// MARK: - Taste Record

struct TasteRecord: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let action: TasteAction
    let suggestionId: UUID
    let suggestionText: String
    
    // Signal/register/axis data at time of action
    let signalMode: SignalMode?
    let signalProfile: SignalProfile?
    let registers: RegisterProfile?
    let axes: SignalAxes?
    let axisProfile: AxisProfile?
    
    // Alignment score at time of action
    let alignmentScore: Double?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        action: TasteAction,
        suggestionId: UUID,
        suggestionText: String,
        signalMode: SignalMode? = nil,
        signalProfile: SignalProfile? = nil,
        registers: RegisterProfile? = nil,
        axes: SignalAxes? = nil,
        axisProfile: AxisProfile? = nil,
        alignmentScore: Double? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.action = action
        self.suggestionId = suggestionId
        self.suggestionText = suggestionText
        self.signalMode = signalMode
        self.signalProfile = signalProfile
        self.registers = registers
        self.axes = axes
        self.axisProfile = axisProfile
        self.alignmentScore = alignmentScore
    }
}

// MARK: - Taste Memory
// Passive logging system - tracks user actions for future learning

class TasteMemory {
    static let shared = TasteMemory()
    
    private var records: [TasteRecord] = []
    private let maxRecords = 1000 // Limit memory size
    
    private init() {}
    
    // MARK: - Record Actions
    
    /// Record when user accepts a suggestion
    func recordAccepted(
        suggestion: RapSuggestion,
        signalMode: SignalMode? = nil,
        signalProfile: SignalProfile? = nil,
        registers: RegisterProfile? = nil,
        axes: SignalAxes? = nil,
        axisProfile: AxisProfile? = nil,
        alignmentScore: Double? = nil
    ) {
        let record = TasteRecord(
            action: .accepted,
            suggestionId: suggestion.id,
            suggestionText: suggestion.text,
            signalMode: signalMode,
            signalProfile: signalProfile,
            registers: registers,
            axes: axes,
            axisProfile: axisProfile,
            alignmentScore: alignmentScore
        )
        addRecord(record)
        
        // Integrate with ground truth CSV
        integrateWithGroundTruth(record: record, action: .accepted)
    }
    
    /// Record when user rejects a suggestion
    func recordRejected(
        suggestion: RapSuggestion,
        signalMode: SignalMode? = nil,
        signalProfile: SignalProfile? = nil,
        registers: RegisterProfile? = nil,
        axes: SignalAxes? = nil,
        axisProfile: AxisProfile? = nil,
        alignmentScore: Double? = nil
    ) {
        let record = TasteRecord(
            action: .rejected,
            suggestionId: suggestion.id,
            suggestionText: suggestion.text,
            signalMode: signalMode,
            signalProfile: signalProfile,
            registers: registers,
            axes: axes,
            axisProfile: axisProfile,
            alignmentScore: alignmentScore
        )
        addRecord(record)
        
        // Integrate with ground truth CSV
        integrateWithGroundTruth(record: record, action: .rejected)
    }
    
    /// Record when user edits a suggestion
    func recordEdited(
        originalSuggestion: RapSuggestion,
        editedText: String,
        signalMode: SignalMode? = nil,
        signalProfile: SignalProfile? = nil,
        registers: RegisterProfile? = nil,
        axes: SignalAxes? = nil,
        axisProfile: AxisProfile? = nil,
        alignmentScore: Double? = nil
    ) {
        let record = TasteRecord(
            action: .edited,
            suggestionId: originalSuggestion.id,
            suggestionText: editedText,
            signalMode: signalMode,
            signalProfile: signalProfile,
            registers: registers,
            axes: axes,
            axisProfile: axisProfile,
            alignmentScore: alignmentScore
        )
        addRecord(record)
        
        // Integrate with ground truth CSV
        integrateWithGroundTruth(record: record, action: .edited)
    }
    
    // MARK: - Record Management
    
    private func addRecord(_ record: TasteRecord) {
        records.append(record)
        
        // Limit memory size
        if records.count > maxRecords {
            records = Array(records.suffix(maxRecords))
        }
        
        // Log for observability (passive - no behavior changes)
        logRecord(record)
    }
    
    private func logRecord(_ record: TasteRecord) {
        #if DEBUG
        print("📝 Taste Memory: \(record.action.rawValue) - '\(record.suggestionText.prefix(50))...'")
        if let score = record.alignmentScore {
            print("   Alignment Score: \(String(format: "%.2f", score))")
        }
        #endif
    }
    
    // MARK: - Ground Truth Integration
    
    /// Integrate with ground truth CSV to learn patterns
    /// Compares user actions against what has worked in the world
    private func integrateWithGroundTruth(record: TasteRecord, action: TasteAction) {
        guard let registers = record.registers,
              let axisProfile = record.axisProfile else {
            return
        }
        
        // Find similar ground truth bars
        let similarBars = EditorialGroundTruth.shared.findSimilarBars(
            registers: registers,
            axes: axisProfile,
            limit: 5
        )
        
        guard !similarBars.isEmpty else {
            return
        }
        
        // Learn patterns that bridge user preference with cultural ground truth
        // For now, just log the comparison (passive learning)
        #if DEBUG
        print("🔗 Taste Memory: Comparing \(action.rawValue) action with \(similarBars.count) similar ground truth bars")
        print("   User preference: \(action.rawValue)")
        print("   Cultural patterns: \(similarBars.count) similar bars found")
        #endif
        
        // Store pattern for future learning (not used in this PR)
        // In future, this data will inform generation preferences
    }
    
    // MARK: - Query Methods (for future use)
    
    /// Get all records for a specific action
    func getRecords(for action: TasteAction) -> [TasteRecord] {
        return records.filter { $0.action == action }
    }
    
    /// Get recent records
    func getRecentRecords(limit: Int = 50) -> [TasteRecord] {
        return Array(records.suffix(limit))
    }
    
    /// Get records matching specific registers
    func getRecords(matching registers: RegisterProfile) -> [TasteRecord] {
        return records.filter { record in
            guard let recordRegisters = record.registers else { return false }
            return recordRegisters.register_noRepairPosition == registers.register_noRepairPosition &&
                   recordRegisters.register_isolationPosition == registers.register_isolationPosition
        }
    }
}
