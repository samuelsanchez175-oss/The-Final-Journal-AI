import Foundation
import AVFoundation
import Accelerate

// MARK: - Audio Analysis Service
// Detects BPM, musical key, and scale from audio files

struct AudioAnalysisResult {
    let bpm: Int?
    let key: String?
    let scale: String? // Major, Minor, etc.
}

class AudioAnalysisService {
    static let shared = AudioAnalysisService()
    
    private init() {}
    
    /// Analyze audio file to detect BPM, key, and scale
    func analyzeAudio(url: URL) async throws -> AudioAnalysisResult {
        // Load audio file
        let asset = AVURLAsset(url: url)
        guard let track = try await asset.loadTracks(withMediaType: .audio).first else {
            throw AudioAnalysisError.noAudioTrack
        }
        
        // Read audio samples
        let reader = try AVAssetReader(asset: asset)
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsNonInterleaved: false,
            AVSampleRateKey: 44100.0
        ]
        
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(output)
        
        guard reader.startReading() else {
            throw AudioAnalysisError.readerFailed
        }
        
        var audioData: [Float] = []
        
        // Read all audio samples
        while let sampleBuffer = output.copyNextSampleBuffer() {
            guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
                continue
            }
            
            var length: Int = 0
            var dataPointer: UnsafeMutablePointer<Int8>? = nil
            
            let status = CMBlockBufferGetDataPointer(
                blockBuffer,
                atOffset: 0,
                lengthAtOffsetOut: nil,
                totalLengthOut: &length,
                dataPointerOut: &dataPointer
            )
            
            guard status == kCMBlockBufferNoErr, let bytes = dataPointer else {
                continue
            }
            
            let sampleCount = length / MemoryLayout<Float>.size
            let floatPointer = UnsafeRawPointer(bytes).bindMemory(to: Float.self, capacity: sampleCount)
            audioData.append(contentsOf: Array(UnsafeBufferPointer(start: floatPointer, count: sampleCount)))
        }
        
        guard !audioData.isEmpty else {
            throw AudioAnalysisError.noSamples
        }
        
        // Analyze audio
        let bpm = detectBPM(audioData: audioData, sampleRate: 44100.0)
        let (key, scale) = detectKeyAndScale(audioData: audioData, sampleRate: 44100.0)
        
        return AudioAnalysisResult(bpm: bpm, key: key, scale: scale)
    }
    
    // MARK: - BPM Detection
    
    private func detectBPM(audioData: [Float], sampleRate: Double) -> Int? {
        // Simple tempo detection using autocorrelation
        // This is a simplified version - for production, consider using more sophisticated algorithms
        
        let windowSize = Int(sampleRate * 0.5) // 0.5 second windows
        guard audioData.count >= windowSize * 2 else { return nil }
        
        // Calculate energy in windows
        var energies: [Float] = []
        for i in stride(from: 0, to: audioData.count - windowSize, by: windowSize / 2) {
            let window = Array(audioData[i..<min(i + windowSize, audioData.count)])
            let energy = window.map { $0 * $0 }.reduce(0, +) / Float(window.count)
            energies.append(energy)
        }
        
        guard energies.count > 10 else { return nil }
        
        // Find peaks in energy (potential beats)
        var peaks: [Int] = []
        for i in 1..<energies.count - 1 {
            if energies[i] > energies[i-1] && energies[i] > energies[i+1] && energies[i] > 0.01 {
                peaks.append(i)
            }
        }
        
        guard peaks.count >= 2 else { return nil }
        
        // Calculate average time between peaks
        var intervals: [Double] = []
        for i in 1..<peaks.count {
            let interval = Double(peaks[i] - peaks[i-1]) * (Double(windowSize) / 2.0) / sampleRate
            if interval > 0.3 && interval < 2.0 { // Valid BPM range: 30-200 BPM
                intervals.append(interval)
            }
        }
        
        guard !intervals.isEmpty else { return nil }
        
        // Calculate average interval and convert to BPM
        let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
        let bpm = Int(60.0 / avgInterval)
        
        // Clamp to valid range
        return max(60, min(220, bpm))
    }
    
    // MARK: - Key and Scale Detection
    
    private func detectKeyAndScale(audioData: [Float], sampleRate: Double) -> (key: String?, scale: String?) {
        // Use FFT to analyze frequency content
        let fftSize = 4096
        let hopSize = fftSize / 4
        
        guard audioData.count >= fftSize else { return (nil, nil) }
        
        // Calculate chroma features (pitch class profile)
        var chromaProfile = [Float](repeating: 0, count: 12)
        var totalEnergy: Float = 0
        
        for i in stride(from: 0, to: audioData.count - fftSize, by: hopSize) {
            let window = Array(audioData[i..<min(i + fftSize, audioData.count)])
            
            // Apply window function (Hann window)
            let windowed = applyHannWindow(window)
            
            // Perform FFT
            if let fftResult = performFFT(windowed) {
                // Extract chroma features
                let chroma = extractChroma(fftResult: fftResult, sampleRate: sampleRate)
                
                for j in 0..<12 {
                    chromaProfile[j] += chroma[j]
                }
                totalEnergy += chroma.reduce(0, +)
            }
        }
        
        guard totalEnergy > 0 else { return (nil, nil) }
        
        // Normalize chroma profile
        for i in 0..<12 {
            chromaProfile[i] /= totalEnergy
        }
        
        // Find key using template matching
        let key = findKey(chromaProfile: chromaProfile)
        let scale = determineScale(chromaProfile: chromaProfile)
        
        return (key, scale)
    }
    
    private func applyHannWindow(_ data: [Float]) -> [Float] {
        return data.enumerated().map { index, value in
            let n = Float(data.count)
            let window = 0.5 * (1 - cos(2 * Float.pi * Float(index) / (n - 1)))
            return value * window
        }
    }
    
    private func performFFT(_ data: [Float]) -> [Float]? {
        // Use a fixed FFT size that's a power of 2
        let fftSize = 2048
        guard data.count >= fftSize else { return nil }
        
        let log2n = vDSP_Length(log2(Double(fftSize)))
        
        let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
        guard let fftSetup = fftSetup else { return nil }
        defer { vDSP_destroy_fftsetup(fftSetup) }
        
        // Take first fftSize samples
        let inputData = Array(data.prefix(fftSize))
        
        // Create split complex format (real part is input, imaginary part is zero)
        var realp = inputData
        var imagp = [Float](repeating: 0, count: fftSize)
        
        // Perform FFT and calculate magnitudes using withUnsafeMutableBufferPointer to create stable pointers
        var magnitudes = [Float](repeating: 0, count: fftSize / 2)
        realp.withUnsafeMutableBufferPointer { realpBuffer in
            imagp.withUnsafeMutableBufferPointer { imagpBuffer in
                var splitComplex = DSPSplitComplex(realp: realpBuffer.baseAddress!, imagp: imagpBuffer.baseAddress!)
                vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                
                // Calculate magnitude spectrum (only need first half due to symmetry)
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(fftSize / 2))
            }
        }
        
        return magnitudes
    }
    
    private func extractChroma(fftResult: [Float], sampleRate: Double) -> [Float] {
        var chroma = [Float](repeating: 0, count: 12)
        let fftSize = fftResult.count * 2
        let binFreq = sampleRate / Double(fftSize)
        
        // Map FFT bins to chroma bins (C, C#, D, D#, E, F, F#, G, G#, A, A#, B)
        for (bin, magnitude) in fftResult.enumerated() {
            let freq = Double(bin) * binFreq
            
            // Only consider frequencies in musical range (80 Hz to 5000 Hz)
            guard freq >= 80 && freq <= 5000 else { continue }
            
            // Convert frequency to MIDI note number
            let midiNote = 12 * log2(freq / 440.0) + 69
            let chromaIndex = Int(midiNote) % 12
            
            // Add magnitude to corresponding chroma bin
            chroma[chromaIndex] += magnitude
        }
        
        return chroma
    }
    
    private func findKey(chromaProfile: [Float]) -> String? {
        // Key templates for major and minor keys (explicitly Float)
        let majorTemplate: [Float] = [6.35 as Float, 2.23 as Float, 3.48 as Float, 2.33 as Float, 4.38 as Float, 4.09 as Float, 2.52 as Float, 5.19 as Float, 2.39 as Float, 3.66 as Float, 2.29 as Float, 2.88 as Float]
        let minorTemplate: [Float] = [6.33 as Float, 2.68 as Float, 3.52 as Float, 5.38 as Float, 2.60 as Float, 3.53 as Float, 2.54 as Float, 4.75 as Float, 3.98 as Float, 2.69 as Float, 3.34 as Float, 3.17 as Float]
        
        let keyNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        var bestMatch = (key: "", score: Float(0))
        
        // Test all 12 keys in both major and minor
        for shift in 0..<12 {
            // Major
            var majorScore: Float = 0
            for i in 0..<12 {
                let index = (i + shift) % 12
                majorScore += chromaProfile[i] * majorTemplate[index]
            }
            
            if majorScore > bestMatch.score {
                bestMatch = (keyNames[shift], majorScore)
            }
            
            // Minor
            var minorScore: Float = 0
            for i in 0..<12 {
                let index = (i + shift) % 12
                minorScore += chromaProfile[i] * minorTemplate[index]
            }
            
            if minorScore > bestMatch.score {
                bestMatch = (keyNames[shift], minorScore)
            }
        }
        
        return bestMatch.score > 0.1 ? bestMatch.key : nil
    }
    
    private func determineScale(chromaProfile: [Float]) -> String? {
        // Simplified scale detection based on chroma profile
        // Compare major vs minor characteristics
        
        // Major scale intervals: 0, 2, 4, 5, 7, 9, 11
        // Minor scale intervals: 0, 2, 3, 5, 7, 8, 10
        
        let majorIndices = [0, 2, 4, 5, 7, 9, 11]
        let minorIndices = [0, 2, 3, 5, 7, 8, 10]
        
        var majorScore: Float = 0
        var minorScore: Float = 0
        
        for i in majorIndices {
            majorScore += chromaProfile[i]
        }
        
        for i in minorIndices {
            minorScore += chromaProfile[i]
        }
        
        if majorScore > minorScore * 1.1 {
            return "Major"
        } else if minorScore > majorScore * 1.1 {
            return "Minor"
        } else {
            return nil // Ambiguous or not clearly major/minor
        }
    }
}

enum AudioAnalysisError: LocalizedError {
    case noAudioTrack
    case readerFailed
    case noSamples
    
    var errorDescription: String? {
        switch self {
        case .noAudioTrack:
            return "No audio track found in file"
        case .readerFailed:
            return "Failed to read audio file"
        case .noSamples:
            return "No audio samples found"
        }
    }
}
