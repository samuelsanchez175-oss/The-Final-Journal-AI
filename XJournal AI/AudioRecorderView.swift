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
            
            recordButton
            
            timeDisplay
            
            if recorder.isRecording {
                waveformView
            }
            
            Spacer()
            
            infoText
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
                .foregroundStyle(.secondary)
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
            .foregroundStyle(.secondary)
    }
    
    private var backgroundView: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
            .ignoresSafeArea()
    }
    
    private func startRecording() {
        requestMicrophonePermission { granted in
            if granted {
                let audioFilename = getDocumentsDirectory().appendingPathComponent("recording_\(UUID().uuidString).m4a")
                recorder.startRecording(to: audioFilename.path)
                
                recordingTime = 0
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    recordingTime += 0.1
                }
            }
        }
    }
    
    private func stopRecording() {
        timer?.invalidate()
        if let audioPath = recorder.stopRecording() {
            item.audioPath = audioPath
            dismiss()
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
