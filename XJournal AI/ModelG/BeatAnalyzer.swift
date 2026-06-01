//
//  BeatAnalyzer.swift
//  XJournal AI
//
//  Model G Core v1.0 — Beat fingerprint analysis from audio.
//

import Foundation

/// Analyzes audio and produces BeatFingerprint.
/// Uses AudioAnalysisService for BPM/key/scale; derives energy, density, intensity from BPM and waveform.
class BeatAnalyzer {
    /// Analyze audio URL and return fingerprint.
    func analyze(audioURL: URL) async throws -> BeatFingerprint {
        let result = try await AudioAnalysisService.shared.analyzeAudio(url: audioURL)
        let bpm = Double(result.bpm ?? 120)
        let key = result.key ?? "C"
        let scale = result.scale ?? "Minor"

        let (avgEnergy, drumDensity, bassIntensity) = deriveLevelsFromBPM(bpm)
        let (spectralBrightness, melodicAiriness) = deriveFromScale(scale: scale)
        let (dropBars, breakdownBars) = await detectStructure(audioURL: audioURL)
        let swingFeel = 0.5
        let pocketDensityScore = 0.4 + (bpm / 200.0) * 0.4

        return BeatFingerprint(
            bpm: bpm,
            timeSignature: "4/4",
            key: key,
            scale: scale,
            avgEnergyLevel: avgEnergy,
            drumDensity: drumDensity,
            bassIntensity: bassIntensity,
            spectralBrightness: spectralBrightness,
            swingFeel: swingFeel,
            dropBars: dropBars,
            breakdownBars: breakdownBars,
            pocketDensityScore: min(1, pocketDensityScore),
            melodicAirinessScore: melodicAiriness
        )
    }

    private func deriveLevelsFromBPM(_ bpm: Double) -> (EnergyLevel, DensityLevel, IntensityLevel) {
        let energy: EnergyLevel = bpm < 100 ? .low : (bpm > 140 ? .high : .medium)
        let density: DensityLevel = bpm < 90 ? .low : (bpm > 130 ? .high : .medium)
        let intensity: IntensityLevel = bpm < 95 ? .low : (bpm > 150 ? .high : .medium)
        return (energy, density, intensity)
    }

    private func deriveFromScale(scale: String) -> (Double, Double) {
        let brightness = scale.lowercased().contains("major") ? 0.65 : 0.45
        let airiness = scale.lowercased().contains("minor") ? 0.6 : 0.5
        return (brightness, airiness)
    }

    private func detectStructure(audioURL: URL) async -> ([Int], [Int]) {
        do {
            let samples = try await WaveformAnalyzer.shared.analyzeAudio(url: audioURL, sampleCount: 64)
            guard samples.count >= 16 else { return ([], []) }
            var dropBars: [Int] = []
            var breakdownBars: [Int] = []
            let threshold = (samples.max() ?? 0.5) * 0.7
            let lowThreshold = (samples.min() ?? 0.2) + 0.1
            for i in stride(from: 0, to: samples.count - 1, by: 4) {
                let barIdx = i / 4
                let chunk = Array(samples[i..<min(i + 4, samples.count)])
                let avg = chunk.reduce(0, +) / Float(chunk.count)
                if avg >= threshold { dropBars.append(barIdx) }
                if avg <= lowThreshold { breakdownBars.append(barIdx) }
            }
            return (dropBars, breakdownBars)
        } catch {
            return ([], [])
        }
    }
}
