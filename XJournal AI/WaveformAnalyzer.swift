import Foundation
import AVFoundation

class WaveformAnalyzer {
    static let shared = WaveformAnalyzer()
    
    private init() {}
    
    /// Analyze audio file and generate waveform data points
    /// - Parameters:
    ///   - audioURL: URL to the audio file
    ///   - sampleCount: Number of samples to generate (default: 100)
    /// - Returns: Array of normalized amplitude values (0.0 to 1.0)
    func analyzeAudio(url: URL, sampleCount: Int = 100) async throws -> [Float] {
        let asset = AVURLAsset(url: url)
        
        guard let track = try await asset.loadTracks(withMediaType: .audio).first else {
            throw WaveformError.noAudioTrack
        }
        
        let duration = try await asset.load(.duration)
        let durationSeconds = CMTimeGetSeconds(duration)
        
        guard durationSeconds > 0 else {
            throw WaveformError.invalidDuration
        }
        
        // Read audio samples
        let reader = try AVAssetReader(asset: asset)
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(output)
        
        guard reader.startReading() else {
            throw WaveformError.readerFailed
        }
        
        var samples: [Float] = []
        var totalSamples: Int64 = 0
        
        // Read all samples
        while let sampleBuffer = output.copyNextSampleBuffer() {
            guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
                continue
            }
            
            var totalLength: Int = 0
            var dataPointer: UnsafeMutablePointer<CChar>? = nil
            
            let status = CMBlockBufferGetDataPointer(
                blockBuffer,
                atOffset: 0,
                lengthAtOffsetOut: nil,
                totalLengthOut: &totalLength,
                dataPointerOut: &dataPointer
            )
            
            guard status == kCMBlockBufferNoErr, let bytes = dataPointer else {
                continue
            }
            
            let sampleCount = totalLength / MemoryLayout<Int16>.size
            let int16Pointer = UnsafeMutableRawPointer(bytes).bindMemory(to: Int16.self, capacity: sampleCount)
            
            // Calculate RMS (Root Mean Square) for this buffer
            var sum: Double = 0
            for i in 0..<sampleCount {
                let sample = Double(int16Pointer[i])
                sum += sample * sample
            }
            
            let rms = sqrt(sum / Double(sampleCount))
            let normalized = Float(rms / Double(Int16.max))
            
            samples.append(normalized)
            totalSamples += Int64(sampleCount)
        }
        
        // Downsample to desired sample count
        guard !samples.isEmpty else {
            throw WaveformError.noSamples
        }
        
        let downsampled = downsample(samples, to: sampleCount)
        
        return downsampled
    }
    
    /// Get audio duration
    func getDuration(url: URL) async throws -> TimeInterval {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        return CMTimeGetSeconds(duration)
    }
    
    // MARK: - Private Helpers
    
    private func downsample(_ samples: [Float], to targetCount: Int) -> [Float] {
        guard samples.count > targetCount else {
            return samples
        }
        
        let step = Float(samples.count) / Float(targetCount)
        var result: [Float] = []
        
        for i in 0..<targetCount {
            let startIndex = Int(Float(i) * step)
            let endIndex = min(Int(Float(i + 1) * step), samples.count)
            
            // Average samples in this range
            let range = samples[startIndex..<endIndex]
            let average = range.reduce(0, +) / Float(range.count)
            result.append(average)
        }
        
        return result
    }
}

enum WaveformError: LocalizedError {
    case noAudioTrack
    case invalidDuration
    case readerFailed
    case noSamples
    
    var errorDescription: String? {
        switch self {
        case .noAudioTrack:
            return "No audio track found in file"
        case .invalidDuration:
            return "Invalid audio duration"
        case .readerFailed:
            return "Failed to read audio file"
        case .noSamples:
            return "No audio samples found"
        }
    }
}
