//
//  InlineAudioCardView.swift
//  The Final Journal AI
//
//  In-note audio player: play/pause, scrubber, skip. Transcription still opens
//  AudioDetailSheet (Apple Speech). Timestamped Speech Intelligence UI is later.
//

import SwiftUI
import SwiftData
import Combine
import AVFoundation

struct InlineAudioCardView: View {
    @Bindable var item: Item
    let onTap: () -> Void
    let onTranscribe: (() -> Void)?
    let onAddTranscriptToNote: (() -> Void)?

    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var isDraggingProgress = false
    @State private var dragProgress: Double = 0
    @State private var showDeleteConfirm = false

    @Environment(\.colorScheme) private var colorScheme

    /// Saved length shows before the player finishes loading, including after relaunch.
    private var shownDuration: TimeInterval {
        if duration > 0 { return duration }
        if let stored = item.audioDuration, stored.isFinite, stored > 0 { return stored }
        return 0
    }

    private var progress: Double {
        let total = shownDuration
        guard total > 0 else { return 0 }
        return isDraggingProgress ? dragProgress : min(1, max(0, currentTime / total))
    }

    private var displayFilename: String {
        guard let audioPath = item.audioPath else { return "Audio" }
        return audioPath.components(separatedBy: "/").last ?? "Audio"
    }

    /// Name on the card, without the file extension.
    private var displayTitle: String {
        let base = (displayFilename as NSString).deletingPathExtension
        let trimmed = base.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Audio" : trimmed
    }

    private var recordingDate: Date {
        if let path = item.audioPath {
            let created = try? URL(fileURLWithPath: path).resourceValues(forKeys: [.creationDateKey]).creationDate
            if let created { return created }
        }
        return item.timestamp
    }

    private var recordingDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: recordingDate)
    }

    /// Idle length, whole minutes, the way Notes writes "Audio · 49m".
    private var idleLengthText: String {
        guard shownDuration > 0 else { return "Audio" }
        let minutes = Int(shownDuration) / 60
        return "Audio · \(max(minutes, 1))m"
    }

    private var transcriptPreview: String {
        guard let transcription = item.transcription else { return "" }
        return transcription
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var analysisCaption: String? {
        var parts: [String] = []
        if let bpm = item.bpm {
            parts.append("\(bpm) BPM")
        }
        let keyScale = [item.key, item.scale].compactMap { value -> String? in
            guard let value else { return nil }
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }.joined(separator: " ")
        if !keyScale.isEmpty {
            parts.append(keyScale)
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private var hasTranscript: Bool {
        guard let transcription = item.transcription else { return false }
        return !transcription.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            if let error = audioPlayer.error {
                errorView(error: error)
                    .padding(16)
            } else {
                playerContent
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorScheme == .dark
                      ? Color(white: 0.20)
                      : Color(uiColor: .secondarySystemBackground))
        )
        .contextMenu { audioContextMenuItems }
        .confirmationDialog("Delete this recording?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete recording", role: .destructive) { handleDeleteAudio() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Removes the attached audio from this note. The file is not copied to Files first.")
        }
        .onAppear {
            preparePlayer()
            isPlaying = audioPlayer.isPlaying
        }
        .onChange(of: item.audioPath) { _, _ in
            preparePlayer()
        }
        // `$isPlaying` emits before the property changes. Use that new value.
        // Reading `audioPlayer.isPlaying` here still sees the previous state,
        // which left the card on Play after a tap.
        .onReceive(audioPlayer.$isPlaying) { playing in
            isPlaying = playing
        }
        .onReceive(audioPlayer.$currentTime) { time in
            if !isDraggingProgress {
                currentTime = time
            }
        }
        .onReceive(audioPlayer.$duration) { dur in
            guard dur.isFinite, dur > 0 else { return }
            duration = dur
            if item.audioDuration == nil || abs((item.audioDuration ?? 0) - dur) > 0.5 {
                item.audioDuration = dur
            }
        }
        .onReceive(audioPlayer.$foundAlternativePath) { alternativePath in
            if let newPath = alternativePath, newPath != item.audioPath {
                item.audioPath = newPath
                item.modifiedDate = Date()
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: isPlaying)
    }

    // MARK: - Player

    private var playerContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(displayTitle)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(recordingDateText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text(isPlaying ? playingClockText : idleLengthText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture { onTap() }

                if isPlaying {
                    playingTransport
                        .fixedSize()
                } else {
                    playPill
                        .fixedSize()
                }
            }

            if hasTranscript {
                Rectangle()
                    .fill(Color.primary.opacity(0.12))
                    .frame(height: 1)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transcript")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(transcriptPreview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture { onTap() }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Transcript")
                .accessibilityValue(transcriptPreview)
                .accessibilityHint("Opens the recording.")
                .accessibilityAddTraits(.isButton)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }

    private var playingClockText: String {
        let elapsed = clock(displayTime)
        guard shownDuration > 0 else { return elapsed }
        return "\(elapsed) / \(clock(shownDuration))"
    }

    private func clock(_ time: TimeInterval) -> String {
        let safe = time.isFinite ? max(0, time) : 0
        let total = Int(safe)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var playPill: some View {
        Button(action: handlePlayPause) {
            HStack(spacing: 6) {
                if audioPlayer.isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image(systemName: "play.fill")
                        .font(.caption.weight(.bold))
                }
                Text("Play")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Play")
        .accessibilityHint("Plays this recording.")
    }

    private var playingTransport: some View {
        HStack(spacing: 14) {
            Button(action: handleSkipBackward) {
                Image(systemName: "gobackward.15")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Skip back 15 seconds")

            Button(action: handlePlayPause) {
                Image(systemName: "pause.fill")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .frame(width: 28, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Pause")
            .accessibilityHint("Pauses this recording.")

            Button(action: handleSkipForward) {
                Image(systemName: "goforward.15")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Skip forward 15 seconds")
        }
    }

    private var displayTime: TimeInterval {
        if isDraggingProgress, shownDuration > 0 {
            return dragProgress * shownDuration
        }
        return currentTime
    }

    private var scrubber: some View {
        VStack(spacing: 4) {
            AudioScrubberTrack(
                progress: progress,
                isDragging: isDraggingProgress,
                onScrubChanged: { fraction in
                    isDraggingProgress = true
                    dragProgress = fraction
                    if shownDuration > 0 {
                        currentTime = fraction * shownDuration
                    }
                },
                onScrubEnded: { fraction in
                    let seekTime = shownDuration > 0 ? fraction * shownDuration : 0
                    preparePlayer()
                    audioPlayer.seek(to: seekTime)
                    currentTime = seekTime
                    isDraggingProgress = false
                    dragProgress = 0
                }
            )
            .disabled(shownDuration <= 0 && !audioPlayer.isReady)
            .opacity(shownDuration > 0 ? 1 : 0.45)
            .accessibilityLabel("Playback position")
            .accessibilityValue(shownDuration > 0
                ? "\(formatTime(currentTime)) of \(formatTime(shownDuration))"
                : "Duration not loaded yet")
            .accessibilityHint("Swipe up or down to move in 5 second steps.")
            .accessibilityAdjustableAction { direction in
                let step: TimeInterval = 5
                let total = max(shownDuration, currentTime)
                let newTime = direction == .increment
                    ? min(total, currentTime + step)
                    : max(0, currentTime - step)
                preparePlayer()
                audioPlayer.seek(to: newTime)
            }

            HStack {
                Text(formatTime(displayTime))
                Spacer()
                Text(shownDuration > 0 ? formatTime(shownDuration) : "--:--")
                    .accessibilityLabel(shownDuration > 0 ? "Length \(formatTime(shownDuration))" : "Length unknown")
            }
            .font(.caption2.monospacedDigit())
            .foregroundStyle(Momentum.contentSecondary)
            .accessibilityHidden(true)
        }
    }

    private var transportRow: some View {
        HStack(spacing: 0) {
            Button(action: handleShareAudio) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Share audio")
            .accessibilityHint("Opens the share sheet for this recording.")

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Button(action: handleSkipBackward) {
                    Image(systemName: "gobackward.15")
                        .font(.body)
                        .foregroundStyle(.blue)
                        .frame(width: 36, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Skip back 15 seconds")

                Button(action: handlePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.blue)
                        .opacity(audioPlayer.isLoading && !isPlaying ? 0.55 : 1)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPlaying ? "Pause" : "Play")
                .accessibilityHint(isPlaying ? "Pauses this recording." : "Plays this recording.")

                Button(action: handleSkipForward) {
                    Image(systemName: "goforward.15")
                        .font(.body)
                        .foregroundStyle(.blue)
                        .frame(width: 36, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Skip forward 15 seconds")
            }

            Spacer(minLength: 0)

            Button(action: handleTranscribe) {
                Text("Aa")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Transcribe")
            .accessibilityHint("Writes down the words in this recording.")
        }
    }

    // MARK: - Error

    private func errorView(error: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("Couldn't load audio")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                    .lineLimit(3)
            }
            Spacer()
            Button {
                audioPlayer.retry()
                preparePlayer()
            } label: {
                Text("Try again")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Try again")
            .accessibilityHint("Retries loading the audio file.")
        }
    }

    // MARK: - Context menu

    @ViewBuilder
    private var audioContextMenuItems: some View {
        if hasTranscript {
            Button {
                handleAddTranscriptToNote()
            } label: {
                Label("Insert into note", systemImage: "doc.text")
            }

            Button {
                handleCopyTranscript()
            } label: {
                Label("Copy transcript", systemImage: "doc.on.doc")
            }
        }

        if item.audioPath != nil {
            Button {
                handleShareAudio()
            } label: {
                Label("Share audio", systemImage: "square.and.arrow.up")
            }
        }

        Divider()

        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label("Delete recording", systemImage: "trash")
        }
    }

    // MARK: - Actions

    private func preparePlayer() {
        guard let audioPath = item.audioPath else { return }
        if let stored = item.audioDuration, stored.isFinite, stored > 0, duration <= 0 {
            duration = stored
        }
        let title = item.title.isEmpty ? displayFilename : item.title
        audioPlayer.loadAudio(
            from: audioPath,
            title: title,
            seedDuration: duration > 0 ? duration : item.audioDuration
        )
    }

    private func handlePlayPause() {
        preparePlayer()
        if isPlaying {
            isPlaying = false
            audioPlayer.pause()
        } else {
            isPlaying = true
            audioPlayer.play()
        }
    }

    private func handleSkipBackward() {
        preparePlayer()
        audioPlayer.skipBackward(seconds: 15)
    }

    private func handleSkipForward() {
        preparePlayer()
        audioPlayer.skipForward(seconds: 15)
    }

    private func handleTranscribe() {
        // Existing Speech path (SpeechAnalyzer on iOS 26). Timestamped
        // Apple Notes-style transcript UI is a follow-up.
        if let onTranscribe {
            onTranscribe()
        } else {
            onTap()
        }
    }

    private func handleAddTranscriptToNote() {
        guard let transcription = item.transcription, !transcription.isEmpty else { return }
        if let onAdd = onAddTranscriptToNote {
            onAdd()
        } else {
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

    private func handleShareAudio() {
        guard let audioPath = item.audioPath else { return }
        let url = URL(fileURLWithPath: audioPath)
        guard FileManager.default.fileExists(atPath: audioPath) else { return }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true)
        }
        lightHaptic()
    }

    private func handleDeleteAudio() {
        audioPlayer.pause()
        item.audioPath = nil
        item.transcription = nil
        item.transcriptionSegments = nil
        item.audioSummary = nil
        item.audioDuration = nil
        item.modifiedDate = Date()
        lightHaptic()
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let safe = time.isFinite ? max(0, time) : 0
        let minutes = Int(safe) / 60
        let seconds = Int(safe) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Circle island to the right of the writing toolbar. Play and pause for this note's file.
struct NoteAudioDockButton: View {
    @Bindable var item: Item
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared

    private var playingThisNote: Bool {
        guard let path = item.audioPath else { return false }
        return audioPlayer.isPlaying && audioPlayer.noteAudioMatches(path)
    }

    var body: some View {
        Button(action: toggle) {
            Image(systemName: playingThisNote ? "pause.fill" : "play.fill")
                .font(.body.weight(.bold))
                .foregroundStyle(Momentum.chromeIcon)
                .offset(x: playingThisNote ? 0 : 1)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .momentumLiquidGlass(in: Circle())
        .accessibilityIdentifier("note-audio-dock")
        .accessibilityLabel(playingThisNote ? "Pause audio" : "Play audio")
        .accessibilityHint("Plays or pauses the recording on this note")
    }

    private func toggle() {
        guard let path = item.audioPath, !path.isEmpty else { return }
        let title = item.title.isEmpty ? (path as NSString).lastPathComponent : item.title
        audioPlayer.loadAudio(from: path, title: title, seedDuration: item.audioDuration)
        if playingThisNote {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
}

// MARK: - Scrubber

struct AudioScrubberTrack: View {
    let progress: Double
    let isDragging: Bool
    let onScrubChanged: (Double) -> Void
    let onScrubEnded: (Double) -> Void

    var body: some View {
        GeometryReader { geometry in
            let width = max(0, geometry.size.width)
            let clamped = min(1, max(0, progress))
            let thumbX = clamped * width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.22))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(Color.blue)
                    .frame(width: max(trackHeight, thumbX), height: trackHeight)

                Circle()
                    .fill(Color.white)
                    .overlay(Circle().strokeBorder(Color.blue.opacity(0.9), lineWidth: 2))
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .black.opacity(0.18), radius: isDragging ? 3 : 1, y: 1)
                    .offset(x: min(max(0, thumbX - thumbSize / 2), width - thumbSize))
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let fraction = width > 0 ? min(1, max(0, value.location.x / width)) : 0
                        onScrubChanged(fraction)
                    }
                    .onEnded { value in
                        let fraction = width > 0 ? min(1, max(0, value.location.x / width)) : 0
                        onScrubEnded(fraction)
                    }
            )
        }
        .frame(height: 28)
        .sensoryFeedback(.selection, trigger: isDragging)
    }

    private var trackHeight: CGFloat { isDragging ? 7 : 5 }
    private var thumbSize: CGFloat { isDragging ? 16 : 12 }
}
