//
//  AudioRecorderView.swift
//  The Final Journal AI
//
//  Extracted from ContentView.swift
//

import SwiftUI
import SwiftData
import AVFoundation
import Combine

// NOTE: GlassSettings is defined in ContentView.swift

struct AudioRecorderView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var recorder = AudioRecorderManager()
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            recorderContentView
                .padding(24)
                .background(backgroundView)
                .navigationTitle("Record Audio")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            requestMicrophonePermission()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    private var recorderContentView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            if isProcessing {
                processingView
            } else {
                recordButton
                
                timeDisplay
                
                if recorder.isRecording {
                    waveformView
                }
            }
            
            Spacer()
            
            if !isProcessing {
                infoText
            }
            
            if let error = processingError {
                VStack(spacing: 8) {
                    Text("Processing Error")
                        .font(.headline)
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                    Button("Dismiss") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Processing audio...")
                .font(.headline)
            Text("Getting duration, analyzing (BPM/Key), and transcribing")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    private var recordButton: some View {
        Button {
            if recorder.isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(recorder.isRecording ? Color.red : Color.blue)
                    .frame(width: 100, height: 100)
                
                Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var timeDisplay: some View {
        if recorder.isRecording {
            Text(formatTime(recordingTime))
                .font(.title.monospacedDigit())
                .foregroundStyle(.primary)
        } else {
            Text("Tap to Record")
                .font(.title3)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }
    
    private var waveformView: some View {
        HStack(spacing: 3) {
            ForEach(0..<40, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(.blue.opacity(0.7))
                    .frame(width: 4, height: waveformHeight(for: index))
            }
        }
        .frame(height: 32)
        .animation(.linear(duration: 0.1).repeatForever(autoreverses: true), value: recordingTime)
    }
    
    private func waveformHeight(for index: Int) -> CGFloat {
        CGFloat(8 + (sin(Double(index) * 0.5 + recordingTime * 2) + 1) * 16)
    }
    
    private var infoText: some View {
        Text("Audio will be saved to this note")
            .font(.caption)
            .foregroundStyle(Momentum.contentSecondary)
    }
    
    private var backgroundView: some View {
        Rectangle()
            .fill(Momentum.surfaceElevated)
            .ignoresSafeArea()
    }
    
    private func startRecording() {
        requestMicrophonePermission { granted in
            if granted {
                let audioFilename = getDocumentsDirectory().appendingPathComponent("recording_\(UUID().uuidString).m4a")
                recorder.startRecording(to: audioFilename.path)
                HapticFeedbackManager.shared.play(.recordStart)

                recordingTime = 0
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    recordingTime += 0.1
                }
            }
        }
    }
    
    @State private var isProcessing = false
    @State private var processingError: String?
    
    private func stopRecording() {
        timer?.invalidate()
        if let audioPath = recorder.stopRecording() {
            HapticFeedbackManager.shared.play(.recordStop)
            item.audioPath = audioPath
            // Process recorded audio: get duration, transcribe, generate summary
            // Don't dismiss immediately - wait for processing to complete
            isProcessing = true
            Task {
                await processRecordedAudio(audioPath: audioPath)
                await MainActor.run {
                    isProcessing = false
                    if processingError == nil {
                        HapticFeedbackManager.shared.success()
                        dismiss()
                    } else {
                        HapticFeedbackManager.shared.error()
                    }
                }
            }
        }
    }
    
    @MainActor
    private func processRecordedAudio(audioPath: String) async {
        let url = URL(fileURLWithPath: audioPath)
        
        // Get audio duration
        do {
            let duration = try await WaveformAnalyzer.shared.getDuration(url: url)
            item.audioDuration = duration
            item.modifiedDate = Date()
            print("✅ Audio duration: \(duration) seconds")
        } catch {
            print("❌ Failed to get audio duration: \(error)")
            processingError = "Failed to get audio duration: \(error.localizedDescription)"
            return
        }
        
        // Analyze audio for BPM, key, and scale (await to ensure it completes)
        do {
            print("🎵 Starting audio analysis (BPM, Key, Scale)...")
            let analysis = try await AudioAnalysisService.shared.analyzeAudio(url: url)
            
            if let bpm = analysis.bpm {
                item.bpm = bpm
                print("✅ BPM auto-filled: \(bpm)")
            }
            if let key = analysis.key {
                item.key = key
                print("✅ Key auto-filled: \(key)")
            }
            if let scale = analysis.scale {
                item.scale = scale
                print("✅ Scale auto-filled: \(scale)")
            }
            item.modifiedDate = Date()
            
            // Force save to SwiftData to ensure values persist
            try? item.modelContext?.save()
            print("✅ Audio metadata saved: BPM=\(item.bpm?.description ?? "nil"), Key=\(item.key ?? "nil"), Scale=\(item.scale ?? "nil")")
        } catch {
            print("⚠️ Audio analysis failed: \(error.localizedDescription)")
            // Don't fail the whole process if analysis fails - user can analyze manually later
        }
        
        // Transcribe audio (on-device)
        do {
            print("🎤 Starting transcription...")
            let transcriptionService = AudioTranscriptionService()
            let result = try await transcriptionService.transcribe(audioURL: url)
            
            print("✅ Transcription complete: \(result.fullText.count) characters, \(result.segments.count) segments")
            
            // Debug: Log segments before saving
            print("📝 Saving transcription - segments count: \(result.segments.count)")
            if let firstSegment = result.segments.first {
                print("📝 First segment: text='\(firstSegment.text)', timestamp=\(firstSegment.timestamp)")
            }
            
            item.transcription = result.fullText
            item.transcriptionSegments = result.segments
            item.modifiedDate = Date()
            
            // Force save to SwiftData with error handling
            do {
                try item.modelContext?.save()
                print("✅ Transcription saved to SwiftData successfully")
                
                // Verify segments were saved
                if let savedSegments = item.transcriptionSegments {
                    print("✅ Verified segments after save: \(savedSegments.count) segments")
                } else {
                    print("⚠️ Warning: Segments are nil after save - SwiftData may not support arrays of Codable structs")
                }
            } catch {
                print("❌ Failed to save transcription to SwiftData: \(error.localizedDescription)")
            }
            
            // Show completion notification with all detected metadata
            let hasTimestamps = !result.segments.isEmpty
            NotificationManager.shared.showAudioProcessingCompleteNotification(
                bpm: item.bpm,
                key: item.key,
                scale: item.scale,
                transcriptionComplete: true,
                timestampsComplete: hasTimestamps
            )
            
            // Generate summary (cloud API) - don't wait for this
            Task {
                do {
                    let summary = try await AudioSummaryService.shared.generateSummary(from: result.fullText)
                    await MainActor.run {
                        item.audioSummary = summary
                        item.modifiedDate = Date()
                        try? item.modelContext?.save()
                    }
                } catch {
                    // Summary generation failed (e.g., no API key) - that's okay
                    print("⚠️ Summary generation skipped: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Transcription failed: \(error.localizedDescription)")
            processingError = "Transcription failed: \(error.localizedDescription)\n\nYou can transcribe this audio later from the audio detail view."
            
            // Show notification even if transcription failed (but with metadata if available)
            NotificationManager.shared.showAudioProcessingCompleteNotification(
                bpm: item.bpm,
                key: item.key,
                scale: item.scale,
                transcriptionComplete: false,
                timestampsComplete: false
            )
        }
    }
    
    private func cleanup() {
        timer?.invalidate()
        if recorder.isRecording {
            stopRecording()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, seconds, milliseconds)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func requestMicrophonePermission(completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion?(granted)
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion?(granted)
                }
            }
        }
    }
}

// MARK: - Audio Recorder Manager

class AudioRecorderManager: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    @Published var isRecording = false
    
    func startRecording(to path: String) {
        let url = URL(fileURLWithPath: path)
        recordingURL = url
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
            isRecording = false
        }
    }
    
    func stopRecording() -> String? {
        guard let recorder = audioRecorder, isRecording else { return nil }
        
        recorder.stop()
        isRecording = false
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        return recordingURL?.path
    }
}
