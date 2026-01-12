//
//  AudioDetailSheet.swift
//  The Final Journal AI
//
//  CCV.22 — Silk Transcription Detail View
//  Full-screen transcription view matching iOS 26 Notes "Silk Boys Track 3" design
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Full-Screen Transcription Detail View

struct AudioDetailSheet: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    
    // Computed properties
    private var displayTitle: String {
        if let audioPath = item.audioPath {
            let filename = (audioPath as NSString).lastPathComponent
            return (filename as NSString).deletingPathExtension
        }
        return item.title.isEmpty ? "Audio Recording" : item.title
    }
    
    private var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy, h:mm a"
        let date = item.modifiedDate ?? item.timestamp
        let dateStr = formatter.string(from: date)
        
        if let duration = item.audioDuration {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return "\(dateStr) \(String(format: "%02d:%02d", minutes, seconds))"
        }
        return dateStr
    }
    
    var body: some View {
        ZStack {
            // Dark background with extension effect
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // HEADER: Segment 7 Linked Transition
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // SUMMARY BUTTON: Segment 22 Morphing Row with GlassEffectContainer
                if let summary = item.audioSummary, !summary.isEmpty {
                    summaryButton(summary: summary)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                }
                
                // TRANSCRIPT BODY: Segment 19 Active Highlighting with background extension
                transcriptView
                    .padding(.top, 24)
                    .modifier(BackgroundExtensionEffect())
                            
                Spacer()
                            
                // CONTROLS: Segment 4 Touch Responsiveness
                playbackControlsView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            loadAudio()
            startTimer()
        }
        .onDisappear {
            stopTimer()
            audioManager.pause()
        }
        .onReceive(audioManager.$currentTime) { time in
            currentTime = time
        }
        .onReceive(audioManager.$isPlaying) { playing in
            if !playing {
                stopTimer()
            } else {
                startTimer()
            }
                        }
                    }
                    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            // Menu button
                        Button {
                lightHaptic()
                // Could show menu actions
                        } label: {
                Image(systemName: "ellipsis.circle")
                                .font(.title2)
                    .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                        
            Spacer()
            
            // Title and metadata
            VStack(spacing: 4) {
                Text(displayTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(dateTimeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Yellow checkmark button (Segment 7) with glassProminent style
            Button {
                lightHaptic()
                dismiss()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.glassProminent(tint: .yellow))
                    }
                }
    
    // MARK: - Summary Button with GlassEffectContainer
    
    private func summaryButton(summary: String) -> some View {
        Button {
            lightHaptic()
            // Could navigate to full summary view
        } label: {
            GlassEffectContainer(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Summary")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Transcript View with Active Highlighting
    
    private var transcriptView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let segments = item.transcriptionSegments, !segments.isEmpty {
                    // Use segments for active highlighting with ForEach
                    ForEach(segments) { segment in
                        transcriptSegmentView(segment: segment)
                    }
                } else if let transcript = item.transcription, !transcript.isEmpty {
                    // Fallback to full transcript if no segments
                    Text(transcript)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.primary)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("No transcription available")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Transcript Segment View with Dynamic Highlighting
    
    private func transcriptSegmentView(segment: TranscriptionSegment) -> some View {
        let segmentEnd = segment.timestamp + segment.duration
        // Active when currentTime is within segment's time range
        let isActive = currentTime >= segment.timestamp && currentTime < segmentEnd
        
        return Text(segment.text)
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(isActive ? Color.primary : Color.secondary.opacity(0.4))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineSpacing(8)
            .animation(.easeInOut(duration: 0.2), value: isActive)
    }
    
    // MARK: - Playback Controls
    
    private var playbackControlsView: some View {
        VStack(spacing: 24) {
            // Large timer display
            Text(formatTimer(currentTime))
                .font(.system(size: 54, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
            
            // Playback buttons
            HStack(spacing: 40) {
                // Skip backward 15s
                Button {
                    lightHaptic()
                    audioManager.skipBackward(seconds: 15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                
                // Play/Pause
                Button {
                    lightHaptic()
                    if audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                }
                .buttonStyle(.plain)
                
                // Skip forward 15s
                Button {
                    lightHaptic()
                    audioManager.skipForward(seconds: 15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
        }
    }
    }
    
    // MARK: - Helper Functions
    
    private func loadAudio() {
        guard let audioPath = item.audioPath else { return }
        audioManager.loadAudio(from: audioPath)
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            currentTime = audioManager.currentTime
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTimer(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let centiseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
}
