//
//  CadenceProfiler.swift
//  XJournal AI
//
//  Computes FlowDNAFeatures and CadenceProfile from bars and rhyme clusters.
//

import Foundation

enum CadenceProfiler {
    static func profile(bars: [FlowBar], rhymeClusters: [RhymeCluster]) -> (FlowDNAFeatures, CadenceProfile) {
        let features = computeFeatures(bars: bars, rhymeClusters: rhymeClusters)
        let profile = mapToProfile(features: features, rhymeClusters: rhymeClusters)
        return (features, profile)
    }

    private static func computeFeatures(bars: [FlowBar], rhymeClusters: [RhymeCluster]) -> FlowDNAFeatures {
        guard !bars.isEmpty else {
            return FlowDNAFeatures(
                avgSyllablesPerBar: 0, stressDensity: 0, offbeatEntryRatio: 0, pauseRatio: 0,
                internalRhymeDensity: 0, endRhymeStrength: 0, multisyllableRhymeRate: 0,
                burstiness: 0, barSpilloverRate: 0, frontloadScore: 0, midloadScore: 0, endloadScore: 0
            )
        }
        var totalSyllables = 0
        var totalStressed = 0
        var totalSlots = 0
        var pauseCount = 0
        var offbeatCount = 0
        var beatCount = 0
        var syllablesPerBar: [Int] = []
        var frontloadSum = 0.0
        var midloadSum = 0.0
        var endloadSum = 0.0
        let beatSlotIndices = Set([0, 4, 8, 12])
        for bar in bars {
            var barSyllables = 0
            var barStressed = 0
            for (i, slot) in bar.slots.enumerated() {
                totalSlots += 1
                if slot.pause == 1 {
                    pauseCount += 1
                } else if let _ = slot.syllable {
                    barSyllables += 1
                    totalSyllables += 1
                    if slot.stress == 1 { totalStressed += 1; barStressed += 1 }
                    if beatSlotIndices.contains(i) { beatCount += 1 } else { offbeatCount += 1 }
                }
                if slot.syllable != nil {
                    if i < 4 { frontloadSum += 1 }
                    else if i < 12 { midloadSum += 1 }
                    else { endloadSum += 1 }
                }
            }
            syllablesPerBar.append(barSyllables)
        }
        let avgSyllables = totalSlots > 0 ? Double(totalSyllables) / Double(bars.count) : 0
        let stressDensity = totalSyllables > 0 ? Double(totalStressed) / Double(totalSyllables) : 0
        let totalSyllableSlots = offbeatCount + beatCount
        let offbeatRatio = totalSyllableSlots > 0 ? Double(offbeatCount) / Double(totalSyllableSlots) : 0
        let pauseRatio = totalSlots > 0 ? Double(pauseCount) / Double(totalSlots) : 0
        let meanSyl = syllablesPerBar.isEmpty ? 0.0 : Double(syllablesPerBar.reduce(0, +)) / Double(syllablesPerBar.count)
        let variance = syllablesPerBar.isEmpty ? 0 : syllablesPerBar.map { pow(Double($0) - meanSyl, 2) }.reduce(0, +) / Double(syllablesPerBar.count)
        let burstiness = meanSyl > 0 ? min(1, variance / meanSyl) : 0
        let totalLoad = frontloadSum + midloadSum + endloadSum
        let frontloadScore = totalLoad > 0 ? frontloadSum / totalLoad : 0.25
        let midloadScore = totalLoad > 0 ? midloadSum / totalLoad : 0.5
        let endloadScore = totalLoad > 0 ? endloadSum / totalLoad : 0.25
        let internalRhyme = rhymeClusters.filter { $0.type == "internal" }
        let internalDensity = internalRhyme.isEmpty ? 0 : (internalRhyme.compactMap(\.density).reduce(0, +) / Double(internalRhyme.count))
        let endRhyme = rhymeClusters.filter { $0.type == "end" }
        let endStrength = endRhyme.isEmpty ? 0 : (endRhyme.compactMap(\.density).reduce(0, +) / Double(max(1, endRhyme.count)))
        return FlowDNAFeatures(
            avgSyllablesPerBar: avgSyllables,
            stressDensity: stressDensity,
            offbeatEntryRatio: offbeatRatio,
            pauseRatio: pauseRatio,
            internalRhymeDensity: internalDensity,
            endRhymeStrength: endStrength,
            multisyllableRhymeRate: 0.29,
            burstiness: burstiness,
            barSpilloverRate: 0,
            frontloadScore: frontloadScore,
            midloadScore: midloadScore,
            endloadScore: endloadScore
        )
    }

    private static func mapToProfile(features: FlowDNAFeatures, rhymeClusters: [RhymeCluster]) -> CadenceProfile {
        let stressLabel = features.stressDensity > 0.6 ? "High" : (features.stressDensity > 0.35 ? "Medium" : "Low")
        let internalLabel = features.internalRhymeDensity > 0.5 ? "High" : (features.internalRhymeDensity > 0.25 ? "Medium" : "Low")
        let gridLabel = features.offbeatEntryRatio > 0.4 ? "Conversational" : (features.offbeatEntryRatio > 0.25 ? "Loose" : "Tight")
        let pauseLabel = features.pauseRatio > 0.15 ? "High" : (features.pauseRatio > 0.05 ? "Medium" : "Low")
        let energyLabel: String
        if features.endloadScore > max(features.frontloadScore, features.midloadScore) {
            energyLabel = "End-loaded"
        } else if features.frontloadScore > max(features.midloadScore, features.endloadScore) {
            energyLabel = "Front-loaded"
        } else {
            energyLabel = "Mid-loaded"
        }
        let family = cadenceFamily(features: features)
        var suggestions: [String] = []
        if features.internalRhymeDensity < 0.3 && !rhymeClusters.isEmpty {
            suggestions.append("Add internal rhyme in the middle of a bar.")
        }
        if features.stressDensity < 0.4 {
            suggestions.append("Add a stressed syllable before beat 3.")
        }
        if features.pauseRatio < 0.05 && features.avgSyllablesPerBar > 10 {
            suggestions.append("Leave a pause before the final stress cluster.")
        }
        return CadenceProfile(
            stressDensity: stressLabel,
            internalRhyme: internalLabel,
            gridTightness: gridLabel,
            pauseControl: pauseLabel,
            energyShape: energyLabel,
            cadenceFamily: family,
            suggestions: suggestions
        )
    }

    private static func cadenceFamily(features: FlowDNAFeatures) -> String {
        if features.stressDensity > 0.6 && features.offbeatEntryRatio > 0.35 {
            return "punch_heavy_street"
        }
        if features.burstiness > 0.6 && features.offbeatEntryRatio > 0.4 {
            return "conversational_spillover"
        }
        if features.avgSyllablesPerBar < 10 && features.stressDensity > 0.55 {
            return "clipped_drill"
        }
        if features.internalRhymeDensity > 0.5 && features.stressDensity < 0.5 {
            return "melodic_trap"
        }
        if features.pauseRatio > 0.1 && features.offbeatEntryRatio > 0.35 {
            return "slurred_elastic"
        }
        return "punch_heavy_street"
    }
}
