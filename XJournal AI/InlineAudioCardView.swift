//
//  InlineAudioCardView.swift
//  The Final Journal AI
//
//  Extracted from ContentView.swift
//

import SwiftUI
import SwiftData
import Combine
import AVFoundation

// NOTE: GlassSettings, lightHaptic, and AudioPlayerManager are defined in ContentView.swift

// MARK: - Inline Audio Card View (iOS 26 Notes Style)

struct InlineAudioCardView: View {
    @Bindable var item: Item
    let onTap: () -> Void
    let onTranscribe: (() -> Void)?
    let onAddTranscriptToNote: (() -> Void)?
    
    @StateObject private var audioPlayer = AudioPlayerManager()
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var fileSize: Int64 = 0
    @State private var isDraggingProgress = false
    @State private var dragProgress: Double = 0
    @State private var showSeekTooltip = false
    @State private var seekTooltipTime: TimeInterval = 0
    @State private var lastTapTime: Date?
    @State private var isExpanded: Bool = false
    @State private var loadTask: Task<Void, Never>?
    @Namespace private var audioNamespace
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    private var progress: Double {
        guard duration > 0 else { return 0 }
        return isDraggingProgress ? dragProgress : (currentTime / duration)
    }
    
    private var isRecordedAudio: Bool {
        // Check if audio was recorded (has transcription) vs imported
        return item.transcription != nil && !item.transcription!.isEmpty
    }
    
    /// Display name without extension (e.g. .mp3). Full name shown; truncation handled by layout.
    private var displayFilename: String {
        guard let audioPath = item.audioPath else { return "Audio" }
        let filename = audioPath.components(separatedBy: "/").last ?? "Audio"
        // Remove common audio extensions
        let lower = filename.lowercased()
        for ext in [".mp3", ".m4a", ".wav", ".aac", ".caf", ".m4r"] {
            if lower.hasSuffix(ext) {
                return String(filename.dropLast(ext.count))
            }
        }
        return filename
    }
    
    private var transcriptionPreview: String {
        if let transcript = item.transcription, !transcript.isEmpty {
            // Show first 100 characters as preview
            return String(transcript.prefix(100)) + (transcript.count > 100 ? "..." : "")
        }
        return ""
    }
    
    private var formattedDuration: String {
        guard let duration = item.audioDuration else { return "" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Error state
            if let error = audioPlayer.error {
                errorView(error: error)
                    .padding(16)
            } else {
                // Always show content, even when loading (play button should be visible)
                expandableContentView
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .matchedGeometryEffect(id: "audio_card_\(item.id.hashValue)", in: audioNamespace)
        .onAppear {
            // Use stored duration immediately if available (no loading needed)
            if let duration = item.audioDuration {
                self.duration = duration
            } else if let audioPath = item.audioPath {
                // Pre-load duration metadata (lightweight, doesn't create full player)
                // This makes playback start instantly when user taps play
                Task {
                    await preloadDurationMetadata(audioPath: audioPath)
                }
            }
            
            // Don't load full audio player automatically - only load when user interacts (play button)
            // This significantly improves app load time when multiple audio items are present
        }
        .onDisappear {
            // Cancel loading if view disappears quickly
            loadTask?.cancel()
            loadTask = nil
        }
        .onReceive(audioPlayer.$isPlaying) { playing in
            withAnimation(.easeInOut(duration: 0.2)) {
                isPlaying = playing
            }
        }
        .onReceive(audioPlayer.$currentTime) { time in
            if !isDraggingProgress {
                currentTime = time
            }
        }
        .onReceive(audioPlayer.$duration) { dur in
            duration = dur
        }
        .onReceive(audioPlayer.$foundAlternativePath) { alternativePath in
            // Update stored path if file was found in alternative location
            if let newPath = alternativePath, newPath != item.audioPath {
                item.audioPath = newPath
                item.modifiedDate = Date()
            }
        }
    }
    
    // MARK: - Expandable Content View
    
    private var expandableContentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Compact header - always visible (more compact padding)
            compactHeaderView
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            
            // Expanded transcript section
            if isExpanded, let transcript = item.transcription, !transcript.isEmpty {
                transcriptView(transcript: transcript)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
    }
    
    // MARK: - Compact Header View (Wider, More Compact Design)
    
    private var compactHeaderView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top row: Audio name + Duration (left), Insert to Body (top right when transcription exists)
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayFilename)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    if !formattedDuration.isEmpty {
                        Text(formattedDuration)
                            .font(.caption2)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                }
                
                Spacer(minLength: 8)
                
                // Insert to Body at top right when transcription exists
                if let transcription = item.transcription, !transcription.isEmpty {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        handleAddTranscriptToNote()
                    }) {
                        Text("Insert to Body")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.yellow)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.yellow.opacity(0.15))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.yellow.opacity(0.4), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            // Progress bar with scrubbing
            if duration > 0 {
                progressBar
                    .padding(.top, 4)
            }
            
            // Seek tooltip (shown during scrubbing)
            if showSeekTooltip {
                Text(formatTime(seekTooltipTime))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(Momentum.contentSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    )
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Playback controls row: Share (left), Centered scrubbers, Transcribe (right)
            if duration > 0 {
                ZStack(alignment: .center) {
                    HStack {
                        // Share button (left)
                        if item.audioPath != nil {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                handleShareAudio()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                        // Transcribe button (right)
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            handleTranscribe()
                        }) {
                            Text("Transcribe")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.yellow)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.yellow.opacity(0.15))
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(Color.yellow.opacity(0.4), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    // Playback controls centered in the row
                    playbackControls
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Playback Controls (Centered, Icons Only)
    
    private var playbackControls: some View {
        HStack(spacing: 4) {
            // Skip backward 15s (icon only, no text)
            Button(action: {
                print("🔵 Skip backward tapped")
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                handleSkipBackward()
            }) {
                Image(systemName: "gobackward.15")
                    .font(.body)
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            
            // Play/Pause button
            Button(action: {
                print("🔵 Play/Pause tapped")
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                handlePlayPause()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .opacity(audioPlayer.isLoading ? 0.5 : 1.0)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            
            // Skip forward 15s (icon only, no text)
            Button(action: {
                print("🔵 Skip forward tapped")
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                handleSkipForward()
            }) {
                Image(systemName: "goforward.15")
                    .font(.body)
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Transcript View
    
    private func transcriptView(transcript: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            // Summary header (if available) - iOS 26 Notes style
            if let summary = item.audioSummary, !summary.isEmpty {
                Button(action: {
                    // Could navigate to full summary view
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                        Text("Summary")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(white: colorScheme == .dark ? 0.2 : 0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            
            // Transcript text - iOS 26 Notes style with materialized reveal
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(transcript)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.primary)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .opacity(isExpanded ? 1 : 0)
                        .blur(radius: isExpanded ? 0 : 2)
                        .animation(.easeInOut(duration: 0.4).delay(0.1), value: isExpanded)
                }
            }
            .frame(maxHeight: 500) // Limit height for very long transcripts
        }
        .padding(.bottom, 16)
    }
    
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                // Progress fill with highlight during scrubbing
                Capsule()
                    .fill(isDraggingProgress ? Color.blue.opacity(0.8) : Color.blue)
                    .frame(width: max(0, geometry.size.width * progress), height: 4)
                    .animation(.linear(duration: 0.1), value: progress)
                
                // Playhead indicator
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .offset(x: max(0, min(geometry.size.width * progress - 4, geometry.size.width - 4)))
                    .animation(.linear(duration: 0.1), value: progress)
                    .scaleEffect(isDraggingProgress ? 1.3 : 1.0)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDraggingProgress = true
                        let newProgress = max(0, min(1, value.location.x / geometry.size.width))
                        dragProgress = newProgress
                        seekTooltipTime = newProgress * duration
                        withAnimation(.easeOut(duration: 0.1)) {
                            showSeekTooltip = true
                        }
                    }
                    .onEnded { value in
                        let newProgress = max(0, min(1, value.location.x / geometry.size.width))
                        let seekTime = newProgress * duration
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        audioPlayer.seek(to: seekTime)
                        isDraggingProgress = false
                        dragProgress = 0
                        withAnimation(.easeOut(duration: 0.2)) {
                            showSeekTooltip = false
                        }
                    }
            )
            .onTapGesture { location in
                // Single tap: seek to position
                let tapX = location.x
                let seekTime = (tapX / geometry.size.width) * duration
                audioPlayer.seek(to: seekTime)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded { _ in
                        // Double tap: skip forward 30 seconds
                        audioPlayer.skipForward(seconds: 30)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
            )
        }
        .frame(height: 8)
        .accessibilityLabel("Audio progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
        .accessibilityAdjustableAction { direction in
            let step: TimeInterval = 5 // 5 second steps
            let newTime = direction == .increment ? 
                min(duration, currentTime + step) : 
                max(0, currentTime - step)
            audioPlayer.seek(to: newTime)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading audio...")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
            Spacer()
        }
    }
    
    // MARK: - Error View
    private func errorView(error: String) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Failed to load audio")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Button {
                    audioPlayer.retry()
                    if let audioPath = item.audioPath {
                        let title = item.title.isEmpty ? nil : item.title
                        audioPlayer.loadAudio(from: audioPath, title: title)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                        .foregroundStyle(.blue)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Retry")
                .accessibilityHint("Retries loading the audio file")
            }
        }
    }
    
    // MARK: - Quick Action Buttons
    private var hasQuickActions: Bool {
        item.audioPath != nil || (item.transcription != nil && !item.transcription!.isEmpty)
    }
    
    private var quickActionButtons: some View {
        HStack(spacing: 16) {
            // Share button
            if item.audioPath != nil {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    handleShareAudio()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                        Text("Share")
                            .font(.caption2)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Share audio")
                .accessibilityHint("Opens share sheet to share the audio file")
            }
            
            // Copy Transcript button
            if let transcription = item.transcription, !transcription.isEmpty {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    handleCopyTranscript()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                        Text("Copy")
                            .font(.caption2)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Copy transcript")
                .accessibilityHint("Copies the audio transcript to clipboard")
            }
            
            // Add to Note button
            if let transcription = item.transcription, !transcription.isEmpty {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    handleAddTranscriptToNote()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                        Text("Add")
                            .font(.caption2)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add transcript to note")
                .accessibilityHint("Adds the audio transcript to the note body")
            }
        }
    }
    
    // MARK: - Audio Context Menu Items (iOS 26 Notes Style)
    @ViewBuilder
    private var audioContextMenuItems: some View {
        if let transcription = item.transcription, !transcription.isEmpty {
            Button {
                handleAddTranscriptToNote()
            } label: {
                Label("Add Transcript to Note", systemImage: "doc.text")
            }
            
            Button {
                handleCopyTranscript()
            } label: {
                Label("Copy Transcript", systemImage: "doc.on.doc")
            }
        }
        
        if item.audioPath != nil {
            Button {
                handleSaveAudioToFiles()
            } label: {
                Label("Save Audio to Files", systemImage: "folder")
            }
            
            Button {
                handleShareAudio()
            } label: {
                Label("Share Audio", systemImage: "square.and.arrow.up")
            }
        }
        
        Divider()
        
        Button(role: .destructive) {
            handleDeleteAudio()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    // MARK: - Menu Action Handlers
    private func handleAddTranscriptToNote() {
        guard let transcription = item.transcription, !transcription.isEmpty else { return }
        if let onAdd = onAddTranscriptToNote {
            onAdd()
        } else {
            // Fallback: add directly to item body
            let prefix = item.body.isEmpty ? "" : "\n\n"
            item.body += prefix + transcription
            item.modifiedDate = Date()
        }
        lightHaptic()
    }
    
    private func handleCopyTranscript() {
        guard let transcription = item.transcription, !transcription.isEmpty else { return }
        UIPasteboard.general.string = transcription
        lightHaptic()
    }
    
    private func handleSaveAudioToFiles() {
        guard let audioPath = item.audioPath else { return }
        let url = URL(fileURLWithPath: audioPath)
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        lightHaptic()
    }
    
    private func handleShareAudio() {
        guard let audioPath = item.audioPath else { return }
        let url = URL(fileURLWithPath: audioPath)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: audioPath) else {
            print("⚠️ InlineAudioCardView: Audio file not found at path: \(audioPath)")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // For iPad, we need to set the popover presentation
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            
            // Configure for iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true) {
                print("✅ InlineAudioCardView: Share sheet presented")
            }
        } else {
            print("⚠️ InlineAudioCardView: Could not find root view controller for share sheet")
        }
        lightHaptic()
    }
    
    private func handleDeleteAudio() {
        item.audioPath = nil
        item.transcription = nil
        item.transcriptionSegments = nil
        item.audioSummary = nil
        item.audioDuration = nil
        item.modifiedDate = Date()
        lightHaptic()
    }
    
    // MARK: - Helper Functions
    
    // MARK: - Audio Loading Helper
    
    /// Loads audio only when needed (when user wants to play)
    /// This implements lazy loading pattern to avoid blocking app startup
    private func loadAudioIfNeeded() {
        guard let audioPath = item.audioPath else { return }
        // Load if player doesn't exist or duration is 0 (not loaded yet)
        if audioPlayer.duration == 0 || audioPlayer.isLoading {
            let title = item.title.isEmpty ? nil : item.title
            audioPlayer.loadAudio(from: audioPath, title: title)
            calculateFileSize(audioPath: audioPath)
        }
    }
    
    private func handlePlayPause() {
        if isPlaying {
            audioPlayer.pause()
        } else {
            // Load audio only when user wants to play (lazy loading)
            if let audioPath = item.audioPath {
                if audioPlayer.duration == 0 {
                    let title = item.title.isEmpty ? nil : item.title
                    audioPlayer.loadAudio(from: audioPath, title: title)
                    calculateFileSize(audioPath: audioPath)
                }
                // Wait a moment for player to be ready, then play
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.audioPlayer.play()
                }
            }
        }
    }
    
    private func handleSkipBackward() {
        // Ensure audio is loaded before skipping
        guard let audioPath = item.audioPath else { return }
        
        if audioPlayer.duration == 0 {
            // Load audio first, then skip after a short delay
            let title = item.title.isEmpty ? nil : item.title
            audioPlayer.loadAudio(from: audioPath, title: title)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.audioPlayer.skipBackward(seconds: 15)
            }
        } else {
            // Audio already loaded, skip immediately
            audioPlayer.skipBackward(seconds: 15)
        }
    }
    
    private func handleSkipForward() {
        // Ensure audio is loaded before skipping
        guard let audioPath = item.audioPath else { return }
        
        if audioPlayer.duration == 0 {
            // Load audio first, then skip after a short delay
            let title = item.title.isEmpty ? nil : item.title
            audioPlayer.loadAudio(from: audioPath, title: title)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.audioPlayer.skipForward(seconds: 15)
            }
        } else {
            // Audio already loaded, skip immediately
            audioPlayer.skipForward(seconds: 15)
        }
    }
    
    private func handleTranscribe() {
        // Opens the audio detail view and triggers transcription
        if let onTranscribe = onTranscribe {
            onTranscribe()
        } else {
            // Fallback to regular tap if onTranscribe not provided
            onTap()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        // Use shorter format for inline display
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func calculateFileSize(audioPath: String) {
        Task {
            let fileManager = FileManager.default
            if let attributes = try? fileManager.attributesOfItem(atPath: audioPath),
               let size = attributes[.size] as? Int64 {
                await MainActor.run {
                    fileSize = size
                }
            }
        }
    }
    
    /// Pre-load duration metadata without creating full audio player
    /// This makes playback start instantly when user taps play
    private func preloadDurationMetadata(audioPath: String) async {
        let url = URL(fileURLWithPath: audioPath)
        let asset = AVURLAsset(url: url)
        
        do {
            if #available(iOS 16.0, *) {
                let durationValue = try await asset.load(.duration)
                let durationSeconds = CMTimeGetSeconds(durationValue)
                await MainActor.run {
                    self.duration = durationSeconds
                    // Also update item if it doesn't have duration stored
                    if item.audioDuration == nil {
                        item.audioDuration = durationSeconds
                    }
                }
            } else {
                // For iOS < 16, try synchronous access
                let durationValue = asset.duration
                if CMTimeCompare(durationValue, CMTime.zero) != 0 {
                    let durationSeconds = CMTimeGetSeconds(durationValue)
                    await MainActor.run {
                        self.duration = durationSeconds
                        if item.audioDuration == nil {
                            item.audioDuration = durationSeconds
                        }
                    }
                }
            }
        } catch {
            // Silently fail - duration will be loaded when audio player is created
            print("⚠️ Failed to preload duration: \(error.localizedDescription)")
        }
    }
}
