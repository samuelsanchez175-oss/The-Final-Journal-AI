//
//  DebugLogger.swift
//  XJournal AI
//
//  Model G Core v1.0 — Debug JSON export.
//

import Foundation

// MARK: - Generation Session Log

struct GenerationSessionLog: Codable {
    let modelVersion: String
    let styleBranch: String
    let riskProfile: Double
    let beatSummary: String?
    let styleDetectionScores: [String: Double]
    let weightSnapshot: [String: Double]
    let perBarMetrics: [BarMetricEntry]
    let deviationMetadata: [String: String]
    let averageBarScore: Double
    let timestamp: Date
}

struct BarMetricEntry: Codable {
    let barIndex: Int
    let text: String
    let score: Double
    let deviationType: String?
}

// MARK: - Debug Logger

class DebugLogger {
    /// Export session log as JSON. Only if ModelGEnvironment.mode == .debug.
    func export(session: GenerationSessionLog) {
        guard ModelGEnvironment.mode == .debug else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateStr = formatter.string(from: session.timestamp)
        let filename = "ModelG_\(dateStr)_\(session.styleBranch)_\(String(format: "%.2f", session.riskProfile))_\(Int(session.averageBarScore)).json"

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(session)
            if let str = String(data: data, encoding: .utf8) {
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                try str.write(to: url, atomically: true, encoding: .utf8)
                print("Model G Debug: Exported to \(url.path)")
            }
        } catch {
            print("Model G Debug: Export failed: \(error)")
        }
    }
}
