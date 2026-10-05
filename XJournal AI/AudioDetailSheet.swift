//
//  AudioDetailSheet.swift
//  The Final Journal AI
//
//  CCV.22 — Silk Transcription Detail View
//  Full-screen transcription view matching iOS 26 Notes "Silk Boys Track 3" design
//

import SwiftUI
import SwiftData
import AVFoundation
import Combine
import Foundation
import Speech
import QuartzCore
import UIKit

/// Live transcription updates hop back to the main actor without capturing the note in a sendable closure.
@MainActor
private enum TranscriptionLiveBoard {
    static var items: [PersistentIdentifier: Item] = [:]

    static func publish(id: PersistentIdentifier, text: String, segments: [TranscriptionSegment]) {
        guard let live = items[id] else { return }
        live.transcription = text
        live.transcriptionSegments = segments
    }
}

// MARK: - Full-Screen Transcription Detail View

struct AudioDetailSheet: View {
    @Bindable var item: Item
    var autoTranscribe: Bool = false // Flag to auto-trigger transcription on appear
    /// Opens the recorder. The dark circle on this screen is that control.
    var onRecord: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var audioManager = AudioPlayerManager.shared
    @StateObject private var transcriptionService = AudioTranscriptionService()
    @State private var currentTime: TimeInterval = 0
    @State private var animatedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var displayLink: CADisplayLink?
    @State private var isTranscribing = false
    @State private var transcriptionError: String?
    @State private var isAnalyzingAudio = false
    @State private var audioAnalysisError: String?
    @State private var showMenu = false
    @State private var showFindBar = false
    @State private var findQuery = ""
    @State private var findMatchIndex = 0
    @State private var transcriptBanner: String? = nil
    @FocusState private var findFieldFocused: Bool
    @State private var detailPane: DetailPane = .transcript
    /// Yellow quote button. On while the words are on screen.
    @State private var transcriptVisible = true
    @State private var isSummarizing = false
    @State private var summaryError: String? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var isPlayerVisible: Bool = true
    @State private var isDraggingProgress = false
    @State private var dragProgress: Double = 0
    /// Cached phrase rows so we don't recompute on every body evaluation (was causing slow transcript population).
    @State private var cachedPhraseRows: [PhraseRow]? = nil
    /// Cached decoded rhythm map to avoid decoding JSON in body every time.
    @State private var cachedRhythmMap: RhythmicTranscriptionResult? = nil
    /// Text column after the timestamp and the gap. Measured from this screen.
    @State private var transcriptColumnWidth: CGFloat = 280
    /// Latest word end while a listen is in progress. Drives the fill and the open row.
    @State private var lastHeardTime: TimeInterval = 0
    @State private var lastHeardAt: Date = .distantPast
    
    // Computed properties
    private var displayTitle: String {
        if let audioPath = item.audioPath {
            let filename = (audioPath as NSString).lastPathComponent
            return (filename as NSString).deletingPathExtension
        }
        return item.title.isEmpty ? "Audio Recording" : item.title
    }
    
    /// File creation date, same source as the card. Editing the note does not move it.
    private var recordingDate: Date {
        if let path = item.audioPath {
            let created = try? URL(fileURLWithPath: path).resourceValues(forKeys: [.creationDateKey]).creationDate
            if let created { return created }
        }
        return item.timestamp
    }

    private var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy, h:mm a"
        let dateStr = formatter.string(from: recordingDate)
        
        if let duration = item.audioDuration, duration > 0 {
            let total = Int(duration)
            let hours = total / 3600
            let minutes = (total % 3600) / 60
            let seconds = total % 60
            let length = hours > 0
                ? String(format: "%d:%02d:%02d", hours, minutes, seconds)
                : String(format: "%d:%02d", minutes, seconds)
            return "\(dateStr) \(length)"
        }
        return dateStr
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 16)
                    .padding(.top, 6)

                Text(displayTitle)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 28)
                    .padding(.top, 6)

                Text(dateTimeString)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)

                summaryRow
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                if showFindBar {
                    findInTranscriptBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }

                if let transcriptBanner {
                    Text(transcriptBanner)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.12))
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .accessibilityLabel(transcriptBanner)
                        .transition(.opacity)
                }

                Group {
                    if detailPane == .summary {
                        summaryPane
                    } else if transcriptVisible {
                        transcriptView
                    } else {
                        Color.clear
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.72),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                if isTranscribing {
                    Text("Listening")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.top, 4)
                        .accessibilityLabel("Listening")
                } else if let transcriptionError {
                    Text(transcriptionError)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                }

                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !audioManager.isPlaying)) { _ in
                    let shown = audioManager.playbackTime()
                    Text(formatTimer(shown))
                        .font(.system(size: 52, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Playback position \(formatTimer(shown))")
                }
                .padding(.top, 8)

                notesTransport
                    .padding(.top, 10)

                bottomTools
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                    .padding(.bottom, 6)
            }
        }
        .onAppear {
            loadAudio()
            startTimer()
            
            // Debug: Log transcription state
            let hasSegments = item.transcriptionSegments != nil && !item.transcriptionSegments!.isEmpty
            let hasTranscription = item.transcription != nil && !item.transcription!.isEmpty
            let segmentCount = item.transcriptionSegments?.count ?? 0
            let segmentTextSample = item.transcriptionSegments?.first?.text ?? "(none)"
            print("📝 AudioDetailSheet onAppear - hasSegments: \(hasSegments), segmentCount: \(segmentCount), hasTranscription: \(hasTranscription), autoTranscribe: \(autoTranscribe), firstSegmentTextPreview: \"\(segmentTextSample.prefix(40))\(segmentTextSample.count > 40 ? "…" : "")\"")
            
            if hasSegments && !hasTranscription {
                print("⚠️ AudioDetailSheet: Has segments but no transcription text — may be stale/empty segments from a previous run; re-transcribing will replace them.")
            }
            if hasTranscription && !hasSegments {
                print("⚠️ AudioDetailSheet: Has transcription but no segments - attempting to refresh")
            }
            
            // Auto-trigger transcription if flag is set
            if autoTranscribe && item.audioPath != nil {
                print("🔄 Auto-triggering transcription from Transcribe button")
                Task {
                    // Force transcription even if one exists (user explicitly requested it)
                    await triggerTranscription(audioPath: item.audioPath!, force: true)
                }
            } else if !autoTranscribe, let audioPath = item.audioPath {
                // Only auto-transcribe when this note has no Apple transcript yet.
                // Never re-run just because segments are missing — that produced
                // different lyrics than the note and could retarget another file.
                Task {
                    await triggerTranscriptionIfNeeded(audioPath: audioPath)
                }
            }
        }
        .onDisappear {
            stopTimer()
            stopDisplayLink()
        }
        .onReceive(audioManager.$currentTime) { time in
            if !isDraggingProgress {
                currentTime = time
                animatedTime = time
            }
        }
        .onReceive(audioManager.$isPlaying) { playing in
            if !playing {
                stopTimer()
                stopDisplayLink()
            } else {
                startTimer()
                startDisplayLink()
            }
        }
    }
    
    // MARK: - Menu Actions
    
    private func shareAudio() {
        guard let audioPath = item.audioPath else { return }
        let url = URL(fileURLWithPath: audioPath)
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func exportTranscription() {
        var items: [Any] = []
        
        if let transcription = item.transcription, !transcription.isEmpty {
            items.append(transcription)
        }
        
        if let segments = item.transcriptionSegments, !segments.isEmpty {
            let formattedSegments = segments.map { segment in
                let timestamp = formatTime(segment.timestamp)
                return "[\(timestamp)] \(segment.text)"
            }.joined(separator: "\n")
            items.append(formattedSegments)
        }
        
        // When rhythm map exists, add SRT-like, word-level, and syllable grid formats
        if let data = item.transcriptionRhythmMapData,
           let rhythm = try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: data) {
            let srtString = buildSRTFromRhythm(rhythm)
            if !srtString.isEmpty { items.append(srtString) }
            let wordLevelString = buildWordLevelFromRhythm(rhythm)
            if !wordLevelString.isEmpty { items.append(wordLevelString) }
            let gridString = buildSyllableGridFromRhythm(rhythm)
            if !gridString.isEmpty { items.append(gridString) }
        }
        
        guard !items.isEmpty else { return }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func formatSRTTime(ms: Int) -> String {
        let totalSeconds = ms / 1000
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let millis = ms % 1000
        return String(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, millis)
    }
    
    private func buildSRTFromRhythm(_ rhythm: RhythmicTranscriptionResult) -> String {
        rhythm.transcript.segments.map { seg in
            "\(formatSRTTime(ms: seg.startMs)) --> \(formatSRTTime(ms: seg.endMs))\n\(seg.text)"
        }.joined(separator: "\n\n")
    }
    
    private func buildWordLevelFromRhythm(_ rhythm: RhythmicTranscriptionResult) -> String {
        rhythm.transcript.segments.flatMap { seg in
            seg.words.map { "[\(Double($0.s) / 1000.0)] \($0.w)" }
        }.joined(separator: " ")
    }
    
    private func buildSyllableGridFromRhythm(_ rhythm: RhythmicTranscriptionResult) -> String {
        let lines = rhythm.syllables.perBar.map { bar in
            let perBeatStr = bar.perBeat.map { String($0) }.joined(separator: ", ")
            return "Bar \(bar.bar): \(bar.count) syl, perBeat [\(perBeatStr)]"
        }
        return lines.joined(separator: "\n")
    }
    
    private var hasTranscriptText: Bool {
        transcriptPlainText != nil
    }

    private var transcriptPlainText: String? {
        if let text = item.transcription?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            return text
        }
        let joined = notesRows.filter { !$0.isPlaceholder }.map(\.phrase).joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return joined.isEmpty ? nil : joined
    }

    private func copyTranscript() {
        guard let text = transcriptPlainText else { return }
        UIPasteboard.general.string = text
        HapticFeedbackManager.shared.lightTap()
        flashBanner("Transcript copied")
    }

    private func addTranscriptToNote() {
        guard let text = transcriptPlainText else { return }
        if item.body.hasSuffix(text) {
            flashBanner("Transcript is already in this note")
            HapticFeedbackManager.shared.lightTap()
            return
        }
        let prefix = item.body.isEmpty ? "" : "\n\n"
        item.body += prefix + text
        item.modifiedDate = Date()
        try? item.modelContext?.save()
        HapticFeedbackManager.shared.lightTap()
        flashBanner("Added transcript to note")
    }

    private func flashBanner(_ message: String) {
        transcriptBanner = message
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            if transcriptBanner == message {
                transcriptBanner = nil
            }
        }
    }

    private var findMatchIDs: [Int] {
        TranscriptFind.matchingIDs(
            query: findQuery,
            rows: notesRows.map { (id: $0.id, text: $0.phrase, isPause: $0.isPlaceholder) }
        )
    }

    private var currentFindRowID: Int? {
        let ids = findMatchIDs
        guard !ids.isEmpty else { return nil }
        let index = min(max(0, findMatchIndex), ids.count - 1)
        return ids[index]
    }

    private func deleteAudio() {
        // Delete audio file
        if let audioPath = item.audioPath {
            try? FileManager.default.removeItem(atPath: audioPath)
        }
        
        // Clear audio-related fields
        item.audioPath = nil
        item.audioDuration = nil
        item.transcription = nil
        item.transcriptionSegments = nil
        item.transcriptionRhythmMapData = nil
        item.audioSummary = nil
        item.bpm = nil
        item.key = nil
        item.scale = nil
        
        // Save changes
        try? item.modelContext?.save()
        
        // Dismiss view
        dismiss()
    }
                    
    // MARK: - Header View
    
    private var topBar: some View {
        HStack {
            Button {
                HapticFeedbackManager.shared.lightTap()
                showMenu = true
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color(white: 0.16)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More")
            .accessibilityHint("Find, copy, or add the transcript, share audio, or delete this recording.")
            .confirmationDialog("Audio options", isPresented: $showMenu, titleVisibility: .visible) {
                if hasTranscriptText {
                    Button("Find in Transcript") {
                        showFindBar = true
                        findFieldFocused = true
                    }
                    Button("Copy Transcript") { copyTranscript() }
                    Button("Add Transcript to Note") { addTranscriptToNote() }
                    if let summary = item.audioSummary, !summary.isEmpty {
                        Button("Copy Summary") { copySummary() }
                        Button("Share Summary") { shareSummary() }
                    }
                }
                Button("Share audio") { shareAudio() }
                if hasTranscriptText {
                    Button("Export transcript") { exportTranscription() }
                }
                if item.audioPath != nil {
                    Button("Transcribe again") {
                        guard let audioPath = item.audioPath else { return }
                        Task { await triggerTranscription(audioPath: audioPath, force: true) }
                    }
                    Button("Delete recording", role: .destructive) { deleteAudio() }
                }
                Button("Cancel", role: .cancel) {}
            }

            Spacer()

            Button {
                HapticFeedbackManager.shared.lightTap()
                dismiss()
            } label: {
                Image(systemName: "checkmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color(uiColor: .systemYellow)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Done")
            .accessibilityHint("Closes this recording.")
        }
    }

    private var summaryRow: some View {
        Button {
            HapticFeedbackManager.shared.lightTap()
            if detailPane == .summary {
                detailPane = .transcript
            } else {
                detailPane = .summary
                Task { await ensureSummary() }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: detailPane == .summary ? "chevron.left" : "arrow.uturn.backward")
                    .font(.body.weight(.medium))
                Text(detailPane == .summary ? "Transcript" : "Summary")
                    .font(.body)
                Spacer()
                if detailPane == .transcript {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(white: 0.15))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(detailPane == .summary ? "Transcript" : "Summary")
        .accessibilityHint(detailPane == .summary
            ? "Shows the words in this recording."
            : "Shows a short summary of this recording.")
    }

    private var notesTransport: some View {
        HStack(spacing: 44) {
            Button {
                HapticFeedbackManager.shared.lightTap()
                audioManager.skipBackward(seconds: 15)
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Skip back 15 seconds")

            Button {
                HapticFeedbackManager.shared.lightTap()
                if audioManager.isPlaying {
                    audioManager.pause()
                } else {
                    audioManager.play()
                }
            } label: {
                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 46, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(audioManager.isPlaying ? "Pause" : "Play")
            .accessibilityHint(audioManager.isPlaying ? "Pauses this recording." : "Plays this recording.")

            Button {
                HapticFeedbackManager.shared.lightTap()
                audioManager.skipForward(seconds: 15)
            } label: {
                Image(systemName: "goforward.15")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Skip forward 15 seconds")
        }
    }

    private var bottomTools: some View {
        ZStack {
            HStack {
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    transcriptVisible.toggle()
                    if transcriptVisible { detailPane = .transcript }
                } label: {
                    Image(systemName: "quote.bubble.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(
                            Circle().fill(transcriptVisible
                                           ? Color(uiColor: .systemYellow)
                                           : Color.white.opacity(0.16))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(transcriptVisible ? "Hide transcript" : "Show transcript")
                .accessibilityHint("Shows or hides the words in this recording.")
                Spacer()
            }

            Button {
                HapticFeedbackManager.shared.lightTap()
                onRecord?()
            } label: {
                Circle()
                    .fill(Color(red: 0.24, green: 0.11, blue: 0.10))
                    .frame(width: 64, height: 64)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Record")
            .accessibilityHint("Opens the recorder.")
        }
    }

    private var headerView: some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                HapticFeedbackManager.shared.lightTap()
                showMenu = true
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 36, height: 36)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More")
            .accessibilityHint("Find, copy, or add the transcript, share audio, or delete this recording.")

            VStack(alignment: .leading, spacing: 6) {
                Text(displayTitle)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(dateTimeString)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.5))

                if item.bpm != nil || item.key != nil || item.scale != nil {
                    audioMetadataView
                } else if item.audioPath != nil {
                    if isAnalyzingAudio {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.7)))
                                .scaleEffect(0.7)
                            Text("Reading BPM and key")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    } else {
                        Button {
                            guard let audioPath = item.audioPath else { return }
                            Task { await analyzeAudio(audioPath: audioPath) }
                        } label: {
                            Text("Read BPM and key")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Read BPM and key")
                        .accessibilityHint("Detects tempo and musical key from this recording.")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                HapticFeedbackManager.shared.lightTap()
                dismiss()
            } label: {
                Image(systemName: "checkmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.yellow))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Done")
            .accessibilityHint("Closes this recording.")
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(sheetCardBackground)
    }

    private var sheetCardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.ultraThinMaterial.opacity(0.55))
    }

    private enum DetailPane: String, CaseIterable {
        case transcript = "Transcript"
        case summary = "Summary"
    }

    private var panePicker: some View {
        HStack(spacing: 0) {
            ForEach(DetailPane.allCases, id: \.self) { pane in
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    detailPane = pane
                    if pane == .summary {
                        Task { await ensureSummary() }
                    }
                } label: {
                    Text(pane.rawValue)
                        .font(.subheadline.weight(detailPane == pane ? .semibold : .medium))
                        .foregroundStyle(.white.opacity(detailPane == pane ? 1 : 0.55))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(detailPane == pane ? Color.white.opacity(0.16) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(pane.rawValue)
                .accessibilityAddTraits(detailPane == pane ? .isSelected : [])
                .accessibilityHint(pane == .summary
                    ? "Shows a short summary of this recording."
                    : "Shows the timestamped transcript.")
            }
        }
        .padding(3)
        .background(sheetCardBackground)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Transcript or Summary")
    }

    private var summaryPane: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isSummarizing {
                HStack(spacing: 10) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.7)))
                        .scaleEffect(0.8)
                    Text("Summarizing this recording…")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .accessibilityLabel("Summarizing this recording")
                Spacer()
            } else if let summaryError {
                VStack(alignment: .leading, spacing: 10) {
                    Text(summaryError)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.75))
                    Button("Try again") {
                        Task { await ensureSummary(force: true) }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .accessibilityLabel("Try again")
                    .accessibilityHint("Generates a new summary of this recording.")
                }
                Spacer()
            } else if let summary = item.audioSummary?.trimmingCharacters(in: .whitespacesAndNewlines), !summary.isEmpty {
                ScrollView {
                    Text(summary)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.92))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .scrollIndicators(.hidden)
                HStack(spacing: 12) {
                    Button("Copy Summary") { copySummary() }
                        .accessibilityHint("Copies the summary to the clipboard.")
                    Button("Share Summary") { shareSummary() }
                        .accessibilityHint("Opens the share sheet for this summary.")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            } else if !hasTranscriptText {
                Text("Transcribe this recording first, then open Summary.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
            } else {
                Text("No summary yet.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                Button("Summarize") {
                    Task { await ensureSummary(force: true) }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.orange)
                .accessibilityLabel("Summarize")
                .accessibilityHint("Writes a short summary of this recording.")
                Spacer()
            }
        }
    }

    private func copySummary() {
        guard let summary = item.audioSummary?.trimmingCharacters(in: .whitespacesAndNewlines), !summary.isEmpty else { return }
        UIPasteboard.general.string = summary
        HapticFeedbackManager.shared.lightTap()
        flashBanner("Summary copied")
    }

    private func shareSummary() {
        guard let summary = item.audioSummary?.trimmingCharacters(in: .whitespacesAndNewlines), !summary.isEmpty else { return }
        HapticFeedbackManager.shared.lightTap()
        let activityVC = UIActivityViewController(activityItems: [summary], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }

    @MainActor
    private func ensureSummary(force: Bool = false) async {
        if !force, let existing = item.audioSummary?.trimmingCharacters(in: .whitespacesAndNewlines), !existing.isEmpty {
            summaryError = nil
            return
        }
        guard let text = transcriptPlainText else {
            summaryError = "Transcribe this recording first, then open Summary."
            return
        }
        isSummarizing = true
        summaryError = nil
        defer { isSummarizing = false }
        do {
            let summary = try await AudioSummaryService.shared.generateSummary(from: text)
            item.audioSummary = summary
            item.modifiedDate = Date()
            try? item.modelContext?.save()
        } catch {
            summaryError = error.localizedDescription
        }
    }
    
    // MARK: - Audio Metadata View
    
    private var audioMetadataView: some View {
        HStack(spacing: 6) {
            if let bpm = item.bpm {
                metadataPill(icon: "metronome", label: "\(bpm) BPM", color: .blue)
            }
            if let key = item.key {
                metadataPill(icon: "music.note", label: key, color: .orange)
            }
            if let scale = item.scale {
                metadataPill(icon: "waveform", label: scale, color: .purple)
            }
        }
    }

    private func metadataPill(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.16))
                .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
        )
        .accessibilityLabel(label)
    }
    
    // MARK: - Transcript View with Active Highlighting and Glass Effect Transition
    
    @ViewBuilder
    private func transcriptVStackContent(
        segments: [TranscriptionSegment],
        hasTranscription: Bool,
        rhythmMap: RhythmicTranscriptionResult?,
        beatLines: [BeatLine],
        useBeatLineView: Bool,
        contentWidth: CGFloat
    ) -> some View {
        if isTranscribing {
            transcriptionProgressOverlay.padding(.bottom, 8)
        }
        if hasTranscription, let fullText = item.transcription, !fullText.isEmpty {
            timedTranscriptSection(
                fullText: fullText,
                segments: segments,
                rhythmMap: rhythmMap,
                preferredTextWidth: contentWidth,
                cachedPhraseRows: cachedPhraseRows
            )
        } else if useBeatLineView {
            ForEach(beatLines) { line in
                transcriptBeatLineView(beatLine: line, preferredTextWidth: contentWidth)
            }
        } else if !segments.isEmpty {
            ForEach(segments) { segment in
                transcriptSegmentView(segment: segment, rhythmMap: rhythmMap, preferredTextWidth: contentWidth)
            }
        } else if !isTranscribing {
            Text("No transcription yet")
                .font(.body)
                .foregroundStyle(Momentum.contentSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var transcriptView: some View {
        Group {
            transcriptViewInner
        }
    }
    
    private var transcriptViewScrollVStack: some View {
        let segments = item.transcriptionSegments ?? []
        let hasSegments = !segments.isEmpty
        let hasTranscription = item.transcription != nil && !item.transcription!.isEmpty
        let rhythmMap = cachedRhythmMap
        let beatLines = rhythmMap?.buildBeatLines() ?? []
        let useBeatLineView = hasSegments && rhythmMap != nil && (rhythmMap?.bpm ?? 0) > 0 && !beatLines.isEmpty
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let sidePadding: CGFloat = isPad ? 60 : 40
        return GeometryReader { geo in
            let contentWidth = max(0, geo.size.width - sidePadding)
            VStack(alignment: .leading, spacing: 12) {
                transcriptVStackContent(
                    segments: segments,
                    hasTranscription: hasTranscription,
                    rhythmMap: rhythmMap,
                    beatLines: beatLines,
                    useBeatLineView: useBeatLineView,
                    contentWidth: contentWidth
                )
            }
        }
        .frame(minHeight: 0)
    }
    
    private var transcriptViewScrollView: some View {
        transcriptViewScrollViewWithBehavior
    }
    
    private var transcriptViewScrollViewWithLayout: some View {
        ScrollView {
            transcriptViewScrollVStack
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.bottom, 48)
        .opacity(1.0)
        .blur(radius: 0)
        .animation(.easeInOut(duration: 0.4), value: item.transcriptionSegments?.count ?? 0)
    }
    
    private var transcriptViewScrollViewWithBehavior: some View {
        transcriptViewScrollViewWithLayout
            .background(transcriptScrollBackground)
            .onAppear { transcriptOnAppear() }
            .onChange(of: item.transcription ?? "") { _, _ in transcriptOnTranscriptionChange() }
            .onChange(of: item.transcriptionSegments?.count ?? 0) { _, _ in transcriptOnSegmentsChange() }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in transcriptOnScrollChange(value: value) }
            .scrollIndicators(.visible)
            .padding(.horizontal, 0)
            .frame(maxHeight: isPlayerVisible ? nil : .infinity)
    }
    
    private var transcriptScrollBackground: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: ScrollOffsetPreferenceKey.self,
                value: geometry.frame(in: .named("scroll")).minY
            )
        }
    }
    
    private func transcriptOnAppear() {
        let segmentCount = item.transcriptionSegments?.count ?? 0
        print("📝 TranscriptView onAppear - segmentCount: \(segmentCount)")
        if cachedRhythmMap == nil, let data = item.transcriptionRhythmMapData {
            cachedRhythmMap = try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: data)
        }
        ensureRhythmMapWhenPossible()
        if let data = item.transcriptionRhythmMapData, cachedRhythmMap == nil {
            cachedRhythmMap = try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: data)
        }
        rebuildNotesRows()
    }
    
    private func transcriptOnTranscriptionChange() {
        cachedRhythmMap = nil
        if let data = item.transcriptionRhythmMapData {
            cachedRhythmMap = try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: data)
        }
        rebuildNotesRows()
    }
    
    private func transcriptOnSegmentsChange() {
        if let data = item.transcriptionRhythmMapData {
            cachedRhythmMap = try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: data)
        }
        rebuildNotesRows()
    }

    private func rebuildNotesRows() {
        cachedPhraseRows = makePhraseRows(from: groupedPhrases())
    }

    private func groupedPhrases() -> [TranscriptPhrase] {
        TranscriptPhraseGrouper.timelinePhrases(
            from: item.transcriptionSegments ?? [],
            bpm: item.bpm.map(Double.init)
        )
    }

    private func makePhraseRows(from phrases: [TranscriptPhrase]) -> [PhraseRow] {
        if phrases.isEmpty,
           let fullText = item.transcription?.trimmingCharacters(in: .whitespacesAndNewlines),
           !fullText.isEmpty {
            return [PhraseRow(id: 0, phrase: fullText, timestamp: 0, duration: max(1, item.audioDuration ?? 1))]
        }
        return phrases.enumerated().map { index, phrase in
            PhraseRow(
                id: index,
                phrase: phrase.text,
                timestamp: phrase.timestamp,
                duration: phrase.duration,
                wordTimings: phrase.wordTimings.isEmpty ? nil : phrase.wordTimings.map { ($0.text, $0.timestamp, $0.duration) },
                isPlaceholder: phrase.isPause,
                placeholderEndTime: phrase.isPause ? phrase.timestamp + phrase.duration : nil
            )
        }
    }

    /// Screen width already excludes the sheet padding. This removes the time column and the gap.
    private func adoptColumnWidth(_ container: CGFloat) {
        let column = max(120, container - (transcriptLinePaddingH * 2) - transcriptTimeColumnWidth - transcriptLineGap)
        guard abs(column - transcriptColumnWidth) > 1 else { return }
        transcriptColumnWidth = column
        rebuildNotesRows()
    }

    private func noteHeardProgress() {
        let heard = (item.transcriptionSegments ?? []).map { $0.timestamp + $0.duration }.max() ?? 0
        guard heard > lastHeardTime + 0.04 else { return }
        lastHeardTime = heard
        lastHeardAt = Date()
    }
    
    private func transcriptOnScrollChange(value: CGFloat) {
        let newOffset = value
        let delta = newOffset - lastScrollOffset
        let playerHideThreshold: CGFloat = -50
        if newOffset < playerHideThreshold && delta < 0 {
            withAnimation(.easeInOut(duration: 0.3)) { isPlayerVisible = false }
        } else if newOffset > playerHideThreshold || delta > 0 {
            withAnimation(.easeInOut(duration: 0.3)) { isPlayerVisible = true }
        }
        lastScrollOffset = newOffset
        scrollOffset = newOffset
    }
    
    private var transcriptViewInner: some View {
        notesStyleTranscript
    }

    private var notesRows: [PhraseRow] {
        if let cached = cachedPhraseRows { return cached }
        return makePhraseRows(from: groupedPhrases())
    }

    /// While a listen is running and playback is still at the start, mark the row being written.
    private var marksRowBeingWritten: Bool {
        isTranscribing && !audioManager.isPlaying && currentTime < 0.2
    }

    private var activeTranscriptRowID: Int? {
        let spoken = notesRows.filter { !$0.isPlaceholder }
        guard !spoken.isEmpty else { return nil }
        if marksRowBeingWritten {
            guard lastHeardTime > 0.05 else { return nil }
            return spoken.last?.id
        }
        var current: Int? = nil
        for row in spoken {
            if currentTime + 0.08 >= row.timestamp {
                current = row.id
            } else if current != nil {
                break
            }
        }
        return current
    }

    private var paragraphTranscript: AttributedString {
        let raw = (item.transcription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var text = AttributedString(raw)
        text.foregroundColor = .white.opacity(0.70)
        return applyFindHighlight(text, query: findQuery, emphasize: true)
    }

    private var notesStyleTranscript: some View {
        let rows = notesRows
        return VStack(spacing: 0) {
            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if rows.isEmpty && !isTranscribing {
                                Text("No words yet")
                                    .font(.title3)
                                    .foregroundStyle(.white.opacity(0.45))
                            } else {
                                ForEach(rows) { row in
                                    notesTranscriptLine(row)
                                        .id(row.id)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .padding(.bottom, 24)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: findQuery) { _, _ in
                        findMatchIndex = 0
                        scrollToFindMatch(proxy)
                    }
                    .onChange(of: findMatchIndex) { _, _ in
                        scrollToFindMatch(proxy)
                    }
                }
                .onAppear { adoptColumnWidth(geo.size.width) }
                .onChange(of: geo.size.width) { _, width in
                    adoptColumnWidth(width)
                }
            }
        }
        .onChange(of: item.transcription ?? "") { _, _ in
            rebuildNotesRows()
            noteHeardProgress()
        }
        .onChange(of: item.transcriptionSegments?.count ?? 0) { _, _ in
            rebuildNotesRows()
            noteHeardProgress()
        }
        .onChange(of: item.bpm) { _, _ in
            rebuildNotesRows()
        }
    }

    private var findInTranscriptBar: some View {
        let matches = findMatchIDs
        let total = matches.count
        let current = total == 0 ? 0 : min(max(0, findMatchIndex), total - 1) + 1
        return HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))
                .accessibilityHidden(true)
            TextField("Find in transcript", text: $findQuery)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.subheadline)
                .foregroundStyle(.white)
                .focused($findFieldFocused)
                .accessibilityLabel("Find in transcript")
                .accessibilityHint("Jumps to matching lines. Use next and previous to move between them.")
            if !findQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(total == 0 ? "No matches" : "\(current) of \(total)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                    .accessibilityLabel(total == 0 ? "No matches" : "Match \(current) of \(total)")
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    guard total > 0 else { return }
                    findMatchIndex = (findMatchIndex - 1 + total) % total
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(total > 0 ? 0.9 : 0.35))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(total == 0)
                .accessibilityLabel("Previous match")
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    guard total > 0 else { return }
                    findMatchIndex = (findMatchIndex + 1) % total
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(total > 0 ? 0.9 : 0.35))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(total == 0)
                .accessibilityLabel("Next match")
            }
            Button("Done") {
                HapticFeedbackManager.shared.lightTap()
                findFieldFocused = false
                showFindBar = false
                findQuery = ""
                findMatchIndex = 0
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .accessibilityLabel("Done")
            .accessibilityHint("Closes find in transcript.")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
    }

    private func scrollToFindMatch(_ proxy: ScrollViewProxy) {
        guard showFindBar, let id = currentFindRowID else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            proxy.scrollTo(id, anchor: .center)
        }
    }

    @ViewBuilder
    private func notesTranscriptLine(_ row: PhraseRow) -> some View {
        if row.isPlaceholder, row.phrase.isEmpty {
            Color.clear.frame(height: 12).accessibilityHidden(true)
        } else {
            let isActive = activeTranscriptRowID == row.id
            Button {
                HapticFeedbackManager.shared.lightTap()
                audioManager.seekAndPlay(to: row.timestamp)
                currentTime = row.timestamp
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: transcriptLineGap) {
                    Text(formatTime(row.timestamp))
                        .font(.system(size: 15, weight: .regular, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.40))
                        .frame(width: transcriptTimeColumnWidth, alignment: .trailing)
                    if row.isPlaceholder {
                        Text("···")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(.white.opacity(0.32))
                            .tracking(6)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(lineText(row))
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.70))
                            .lineSpacing(6)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, transcriptLinePaddingV)
                .padding(.horizontal, transcriptLinePaddingH)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(lineBackground(isActive: isActive, rowID: row.id))
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(row.isPlaceholder ? "Pause at \(formatTime(row.timestamp))" : "\(formatTime(row.timestamp)), \(row.phrase)")
            .accessibilityHint("Plays this recording from this line.")
        }
    }

    private func lineBackground(isActive: Bool, rowID: Int) -> Color {
        if currentFindRowID == rowID { return Color.orange.opacity(0.16) }
        if isActive { return Color.white.opacity(0.10) }
        return Color.clear
    }

    private func lineText(_ row: PhraseRow) -> AttributedString {
        var text = AttributedString(row.phrase)
        text.font = .system(size: 22)
        text.foregroundColor = .white.opacity(0.70)
        return applyFindHighlight(text, query: findQuery, emphasize: currentFindRowID == row.id)
    }

    private func applyFindHighlight(_ text: AttributedString, query: String, emphasize: Bool) -> AttributedString {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return text }
        var result = text
        let plain = String(result.characters)
        var cursor = plain.startIndex
        while cursor < plain.endIndex,
              let range = plain.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive], range: cursor..<plain.endIndex) {
            let nsRange = NSRange(range, in: plain)
            if let attributedRange = Range(nsRange, in: result) {
                result[attributedRange].backgroundColor = emphasize
                    ? Color.orange.opacity(0.45)
                    : Color.yellow.opacity(0.28)
            }
            cursor = range.upperBound
        }
        return result
    }

    /// PreferenceKey for tracking scroll offset
    private struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    /// Listening pill: a thin fill of the file, beside Restart.
    private var transcriptionProgressOverlay: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            listeningPill(at: timeline.date)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private func listeningPill(at now: Date) -> some View {
        let duration = item.audioDuration ?? 0
        let heard = duration > 0 ? min(lastHeardTime, duration) : lastHeardTime
        let stalled = lastHeardTime > 0.05 && now.timeIntervalSince(lastHeardAt) >= 4
        let label: String = {
            if stalled { return "Still listening" }
            if duration > 0 {
                return "Listening · \(formatTime(heard)) of \(formatTime(duration))"
            }
            return "Listening · \(formatTime(heard))"
        }()
        let fraction = duration > 0 ? CGFloat(min(1, max(0, heard / duration))) : 0
        return VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(1)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.14))
                    Capsule()
                        .fill(Color.orange)
                        .frame(width: max(0, geo.size.width * fraction))
                }
            }
            .frame(height: 3)
            .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Momentum.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
    }
    
    /// Build and save rhythm map when we have segments + BPM but no (valid) rhythm map, so beat-line view is used.
    private func ensureRhythmMapWhenPossible() {
        guard let segments = item.transcriptionSegments, !segments.isEmpty,
              let bpm = item.bpm, bpm > 0 else { return }
        let existing = item.transcriptionRhythmMapData.flatMap { try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: $0) }
        if existing != nil && (existing?.bpm ?? 0) > 0 { return }
        let rhythm = TranscriptionAssembler.assemble(
            segments: segments,
            bpm: item.bpm,
            timeSignature: .fourFour,
            barOffsetMs: 0,
            audioId: nil
        )
        if let data = try? JSONEncoder().encode(rhythm) {
            item.transcriptionRhythmMapData = data
            try? item.modelContext?.save()
            print("✅ Rhythm map built on appear (BPM \(bpm)) — beat-line view will be used")
        }
    }
    
    /// When true, raw transcript is expanded; otherwise it stays collapsed to a few lines.
    @State private var showFullTranscript = false
    @State private var showTimestamps: Bool = true
    private let transcriptTimestampColumnWidth: CGFloat = 52
    private let transcriptRowSpacing: CGFloat = 10
    private let transcriptRowHorizontalPadding: CGFloat = 24 // Increased from 2px to 24px per side
    private let transcriptTimeColumnWidth: CGFloat = 48
    private let transcriptLineGap: CGFloat = 12
    private let transcriptLinePaddingH: CGFloat = 6
    private let transcriptLinePaddingV: CGFloat = 3
    private let transcriptStackSpacing: CGFloat = 4
    
    /// Calculate responsive max text width: ~320px on iPhone, ~400-450px on iPad
    private var responsiveMaxTextWidth: CGFloat {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        return isPad ? 420 : 320
    }
    
    private func transcriptTextWidth(for preferredTextWidth: CGFloat) -> CGFloat? {
        guard preferredTextWidth > 0 else { return nil }
        let reservedWidth = (showTimestamps ? transcriptTimestampColumnWidth : 0) + transcriptRowSpacing + (transcriptRowHorizontalPadding * 2)
        let maxWidth = min(preferredTextWidth - reservedWidth, responsiveMaxTextWidth - reservedWidth)
        return max(140, maxWidth)
    }
    
    /// Phrase boundary threshold: pause in speech (seconds) that starts a new phrase.
    private let phraseGapThreshold: TimeInterval = 0.65
    
    /// Split transcript into words (any whitespace including newlines).
    private func wordsFromTranscript(_ text: String) -> [String] {
        text.split(whereSeparator: { $0.isWhitespace }).map(String.init).filter { !$0.isEmpty }
    }
    
    /// Align fullText words to segment timestamps. Uses fullText as sole source — every word is included.
    /// When segments have startIndex/length, uses fullText substring for exact match.
    private func alignFullTextToSegments(fullTextWords: [String], segments: [TranscriptionSegment], fullText: String) -> [(String, TimeInterval, TimeInterval)] {
        guard !fullTextWords.isEmpty else { return [] }
        
        // No segments: distribute words uniformly over 1 second
        guard !segments.isEmpty else {
            let dur = 1.0 / Double(max(1, fullTextWords.count))
            return fullTextWords.enumerated().map { i, w in (w, Double(i) * dur, dur) }
        }
        
        var result: [(String, TimeInterval, TimeInterval)] = []
        var fullTextIndex = 0
        
        for seg in segments {
            let segWords: [String]
            if let s = seg.startIndex, let len = seg.length, s >= 0, len > 0,
               let startIdx = fullText.index(fullText.startIndex, offsetBy: s, limitedBy: fullText.endIndex),
               let endIdx = fullText.index(startIdx, offsetBy: len, limitedBy: fullText.endIndex) {
                segWords = String(fullText[startIdx..<endIdx]).split(separator: " ").map(String.init).filter { !$0.isEmpty }
            } else {
                segWords = seg.text.split(separator: " ").map(String.init).filter { !$0.isEmpty }
            }
            let n = max(1, segWords.count)
            let wordDuration = seg.duration / Double(n)
            for i in 0..<n {
                guard fullTextIndex < fullTextWords.count else { break }
                let word = fullTextWords[fullTextIndex]
                let start = seg.timestamp + Double(i) * wordDuration
                result.append((word, start, wordDuration))
                fullTextIndex += 1
            }
        }
        
        // Every remaining fullText word gets a timestamp (no words dropped)
        if fullTextIndex < fullTextWords.count {
            let lastEnd = result.last.map { $0.1 + $0.2 } ?? 0
            let step: TimeInterval = 0.25
            for i in fullTextIndex..<fullTextWords.count {
                result.append((fullTextWords[i], lastEnd + Double(i - fullTextIndex) * step, step))
            }
        }
        
        // Safety: if we somehow missed words, rebuild from fullText only
        if result.count != fullTextWords.count {
            let totalDuration = segments.last.map { $0.timestamp + $0.duration } ?? 1.0
            let step = totalDuration / Double(max(1, fullTextWords.count))
            return fullTextWords.enumerated().map { i, w in (w, Double(i) * step, step) }
        }
        
        return result
    }
    
    /// Split a long string into chunks at word boundaries, each at most maxLength characters.
    private func splitLongPhrase(_ phrase: String, maxLength: Int) -> [String] {
        var result: [String] = []
        var remaining = phrase
        while remaining.count > maxLength {
            let chunk = String(remaining.prefix(maxLength))
            if let lastSpace = chunk.lastIndex(of: " ") {
                result.append(String(chunk[..<lastSpace]).trimmingCharacters(in: .whitespaces))
                remaining = String(remaining[chunk.index(after: lastSpace)...]).trimmingCharacters(in: .whitespaces)
            } else {
                result.append(chunk)
                remaining = String(remaining[chunk.endIndex...]).trimmingCharacters(in: .whitespaces)
            }
        }
        if !remaining.isEmpty { result.append(remaining) }
        return result
    }
    
    /// Raw transcript section defaults to collapsed with explicit expand/collapse while remaining selectable.
    private func transcriptPreviewSection(fullText: String) -> some View {
        let collapsedLineLimit = 4
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                Text("Raw transcript")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
                Button {
                    showFullTranscript.toggle()
                    HapticFeedbackManager.shared.lightTap()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: showFullTranscript ? "chevron.up.circle.fill" : "chevron.down.circle")
                            .font(.subheadline)
                        Text(showFullTranscript ? "Collapse raw" : "Expand raw")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(Momentum.contentSecondary)
                }
                .buttonStyle(.plain)
            }
            Text(fullText)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(8)
                .lineLimit(showFullTranscript ? nil : collapsedLineLimit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
    }
    
    /// One phrase with optional word-level timings for per-word highlighting.
    private struct PhraseRow: Identifiable {
        let id: Int
        let phrase: String
        let timestamp: TimeInterval
        let duration: TimeInterval
        /// Per-word (text, startTime, duration) for word-level highlight as audio plays.
        let wordTimings: [(text: String, start: TimeInterval, duration: TimeInterval)]?
        let isPlaceholder: Bool
        let placeholderEndTime: TimeInterval?
        
        init(id: Int, phrase: String, timestamp: TimeInterval, duration: TimeInterval, wordTimings: [(String, TimeInterval, TimeInterval)]? = nil, isPlaceholder: Bool = false, placeholderEndTime: TimeInterval? = nil) {
            self.id = id
            self.phrase = phrase
            self.timestamp = timestamp
            self.duration = duration
            self.wordTimings = wordTimings
            self.isPlaceholder = isPlaceholder
            self.placeholderEndTime = placeholderEndTime
        }
    }
    
    /// Build phrase-based rows. Uses fullText as source of truth so no words are dropped.
    /// Aligns segment timestamps to fullText words; phrase boundaries from pauses in speech.
    private func buildPhraseRows(fullText: String, segments: [TranscriptionSegment]) -> [PhraseRow] {
        var result: [PhraseRow] = []
        let fullTextWords = wordsFromTranscript(fullText)
        
        if fullTextWords.isEmpty {
            return result
        }
        
        if !segments.isEmpty {
            // Build word-level timings from fullText, aligned to segments (no words dropped)
            let wordTimings = alignFullTextToSegments(fullTextWords: fullTextWords, segments: segments, fullText: fullText)
            guard !wordTimings.isEmpty else {
                result.append(PhraseRow(id: 0, phrase: fullText, timestamp: 0, duration: 1, wordTimings: nil))
                return result
            }
            
            // Phrase boundaries = pauses between segments. Group consecutive word timings by segment gaps.
            var phraseWordTimings: [(String, TimeInterval, TimeInterval)] = []
            var phraseStart = wordTimings[0].1
            
            for (i, wt) in wordTimings.enumerated() {
                let (word, start, duration) = wt
                let prevEnd = i > 0 ? (wordTimings[i - 1].1 + wordTimings[i - 1].2) : start
                let gap = start - prevEnd
                
                if gap > phraseGapThreshold && !phraseWordTimings.isEmpty {
                    let phrase = phraseWordTimings.map(\.0).joined(separator: " ")
                    let phraseEnd = phraseWordTimings.last!.1 + phraseWordTimings.last!.2
                    result.append(PhraseRow(id: result.count, phrase: phrase, timestamp: phraseStart, duration: max(0.1, phraseEnd - phraseStart), wordTimings: phraseWordTimings))
                    phraseWordTimings = []
                    phraseStart = start
                }
                phraseWordTimings.append((word, start, duration))
            }
            
            if !phraseWordTimings.isEmpty {
                let phrase = phraseWordTimings.map(\.0).joined(separator: " ")
                let phraseEnd = phraseWordTimings.last!.1 + phraseWordTimings.last!.2
                result.append(PhraseRow(id: result.count, phrase: phrase, timestamp: phraseStart, duration: max(0.1, phraseEnd - phraseStart), wordTimings: phraseWordTimings))
            }
            
            // Split long phrases at word boundaries
            let maxPhraseLength = 120
            var expanded: [PhraseRow] = []
            for (idx, row) in result.enumerated() {
                if row.phrase.count > maxPhraseLength, let timings = row.wordTimings {
                    let chunks = splitLongPhrase(row.phrase, maxLength: maxPhraseLength)
                    var chunkWordCount = 0
                    for (j, chunk) in chunks.enumerated() {
                        let chunkWords = chunk.split(separator: " ").map(String.init).filter { !$0.isEmpty }
                        var chunkTimings: [(String, TimeInterval, TimeInterval)] = []
                        let endIdx = min(chunkWordCount + chunkWords.count, timings.count)
                        if chunkWordCount < endIdx {
                            chunkTimings = Array(timings[chunkWordCount..<endIdx])
                        }
                        // Ensure every chunk word has a timing (pad if segment alignment was short)
                        let lastEnd = chunkTimings.last.map { $0.1 + $0.2 } ?? row.timestamp
                        for i in chunkTimings.count..<chunkWords.count {
                            chunkTimings.append((chunkWords[i], lastEnd + Double(i - chunkTimings.count) * 0.25, 0.25))
                        }
                        chunkWordCount += chunkWords.count
                        let chunkStart = chunkTimings.first?.1 ?? (row.timestamp + Double(j) * row.duration / Double(chunks.count))
                        let chunkEnd = chunkTimings.last.map { $0.1 + $0.2 } ?? chunkStart + row.duration / Double(chunks.count)
                        expanded.append(PhraseRow(
                            id: idx * 1000 + j,
                            phrase: chunk,
                            timestamp: chunkStart,
                            duration: max(0.1, chunkEnd - chunkStart),
                            wordTimings: chunkTimings.isEmpty ? nil : chunkTimings
                        ))
                    }
                } else {
                    expanded.append(row)
                }
            }
            result = expanded
        } else {
            // No segments: entire transcript as one phrase with word-level timings so every word is shown
            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                let wordTimings = alignFullTextToSegments(fullTextWords: fullTextWords, segments: [], fullText: fullText)
                result.append(PhraseRow(id: 0, phrase: trimmed, timestamp: 0, duration: 1, wordTimings: wordTimings.isEmpty ? nil : wordTimings))
            }
        }
        
        // Detect gaps and insert placeholder rows
        var finalResult: [PhraseRow] = []
        for (index, row) in result.enumerated() {
            finalResult.append(row)
            
            // Check for gap before next row
            if index < result.count - 1 {
                let currentEndTime = row.timestamp + row.duration
                let nextStartTime = result[index + 1].timestamp
                let gap = nextStartTime - currentEndTime
                
                if gap > 3.0 { // Gap > 3 seconds
                    if gap > 30.0 {
                        // Large gap: single placeholder with timestamp range
                        finalResult.append(PhraseRow(
                            id: 20000 + index,
                            phrase: "",
                            timestamp: currentEndTime,
                            duration: gap,
                            isPlaceholder: true,
                            placeholderEndTime: nextStartTime
                        ))
                    } else {
                        // Small gap: single empty placeholder row
                        finalResult.append(PhraseRow(
                            id: 20000 + index,
                            phrase: "",
                            timestamp: currentEndTime,
                            duration: gap,
                            isPlaceholder: true,
                            placeholderEndTime: nil
                        ))
                    }
                }
            }
        }
        
        // PRIORITY: Guarantee every word and line from fullText appears in By line — append any missing words
        let displayedWords: [String] = finalResult.flatMap { row -> [String] in
            if row.isPlaceholder { return [] }
            if let timings = row.wordTimings, !timings.isEmpty { return timings.map { $0.text } }
            return wordsFromTranscript(row.phrase)
        }
        if displayedWords.count < fullTextWords.count {
            let missingWords = Array(fullTextWords[displayedWords.count...])
            let missingPhrase = missingWords.joined(separator: " ")
            let lastEnd = finalResult.last.flatMap { r in r.isPlaceholder ? nil : (r.timestamp + r.duration) } ?? 0
            let step: TimeInterval = 0.25
            let missingTimings: [(String, TimeInterval, TimeInterval)] = missingWords.enumerated().map { i, w in
                (w, lastEnd + Double(i) * step, step)
            }
            finalResult.append(PhraseRow(
                id: 30000,
                phrase: missingPhrase,
                timestamp: lastEnd,
                duration: max(0.1, Double(missingWords.count) * step),
                wordTimings: missingTimings
            ))
        }
        
        // Final guarantee: if any words are still missing, show entire transcript as one row so nothing is lost
        let allDisplayedNow: [String] = finalResult.flatMap { row -> [String] in
            if row.isPlaceholder { return [] }
            if let timings = row.wordTimings, !timings.isEmpty { return timings.map { $0.text } }
            return wordsFromTranscript(row.phrase)
        }
        if allDisplayedNow.count < fullTextWords.count {
            let fallbackTimings = fullTextWords.enumerated().map { i, w in
                (w, Double(i) * 0.25, 0.25 as TimeInterval)
            }
            return [PhraseRow(id: 0, phrase: fullText.trimmingCharacters(in: .whitespacesAndNewlines), timestamp: 0, duration: max(1, Double(fullTextWords.count) * 0.25), wordTimings: fallbackTimings)]
        }
        
        return finalResult
    }
    
    /// By-line view: phrase-based rows with tap-to-seek (main transcript content).
    /// Uses cached phrase rows when available so we don't run buildPhraseRows on every body evaluation.
    private func timedTranscriptSection(
        fullText: String,
        segments: [TranscriptionSegment],
        rhythmMap: RhythmicTranscriptionResult?,
        preferredTextWidth: CGFloat,
        cachedPhraseRows: [PhraseRow]?
    ) -> some View {
        let phraseRows = cachedPhraseRows ?? []
        return VStack(alignment: .leading, spacing: 14) {
            if !phraseRows.isEmpty {
                ForEach(phraseRows) { row in
                    transcriptPhraseRowView(phraseRow: row, rhythmMap: rhythmMap, preferredTextWidth: preferredTextWidth)
                }
            } else if !segments.isEmpty {
                ForEach(segments) { segment in
                    transcriptSegmentView(segment: segment, rhythmMap: rhythmMap, preferredTextWidth: preferredTextWidth)
                }
            } else {
                transcriptPhraseRowView(phraseRow: PhraseRow(id: 0, phrase: fullText, timestamp: 0, duration: 1), rhythmMap: rhythmMap, preferredTextWidth: preferredTextWidth, lineLimit: 4)
            }
        }
    }
    
    /// One row in the by-line view: timestamp, phrase text (tap to seek); syllable below when rhythm map exists.
    private func transcriptPhraseRowView(phraseRow: PhraseRow, rhythmMap: RhythmicTranscriptionResult?, preferredTextWidth: CGFloat, lineLimit: Int? = nil) -> some View {
        let timeTolerance: TimeInterval = 0.1
        let isPastOrActive = currentTime >= (phraseRow.timestamp - timeTolerance)
        // Calculate syllables per beat from phrase text and BPM (prioritize text-based calculation)
        let syllableDisplay: String
        if let calculated = calculateSyllablesPerBeat(phrase: phraseRow.phrase, duration: phraseRow.duration, bpm: item.bpm) {
            syllableDisplay = calculated
        } else if let rhythmDisplay = rhythmMap?.syllablePerBeatDisplay(forSegmentTimestamp: phraseRow.timestamp, duration: phraseRow.duration), !rhythmDisplay.isEmpty {
            syllableDisplay = rhythmDisplay
        } else {
            syllableDisplay = ""
        }
        let textWidth = transcriptTextWidth(for: preferredTextWidth)
        
        // Format timestamp for placeholder rows with range
        let timestampText: String
        if phraseRow.isPlaceholder, let endTime = phraseRow.placeholderEndTime {
            timestampText = "\(formatTime(phraseRow.timestamp)) - \(formatTime(endTime))"
        } else {
            timestampText = formatTime(phraseRow.timestamp)
        }
        
        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: transcriptRowSpacing) {
                if showTimestamps {
                    Text(timestampText)
                        .font(.system(.caption, design: .monospaced).weight(.medium))
                        .foregroundStyle(.white.opacity(0.45))
                        .frame(width: transcriptTimestampColumnWidth, alignment: .leading)
                        .fixedSize(horizontal: true, vertical: false)
                } else {
                    Color.clear.frame(width: 0, height: 0)
                }
                if phraseRow.isPlaceholder {
                    // Placeholder row: empty text, non-interactive
                    Text("")
                        .font(.body)
                        .foregroundStyle(.secondary.opacity(0.3))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 20) // Maintain row height
                } else if let timings = phraseRow.wordTimings, !timings.isEmpty {
                    WordLevelSelectableText(
                        wordTimings: timings,
                        currentTime: currentTime,
                        seekTimestamp: phraseRow.timestamp,
                        preferredMaxLayoutWidth: textWidth,
                        lineLimit: lineLimit,
                        onSeek: { t in HapticFeedbackManager.shared.lightTap(); audioManager.seek(to: t); currentTime = t }
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    SelectableTextWithSeek(
                        text: phraseRow.phrase,
                        timestamp: phraseRow.timestamp,
                        isPastOrActive: isPastOrActive,
                        preferredMaxLayoutWidth: textWidth,
                        lineLimit: lineLimit,
                        onSeek: { t in HapticFeedbackManager.shared.lightTap(); audioManager.seek(to: t); currentTime = t }
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, transcriptRowHorizontalPadding)
            if item.bpm != nil && item.bpm! > 0 {
                HStack(alignment: .top, spacing: transcriptRowSpacing) {
                    if showTimestamps {
                        Color.clear.frame(width: transcriptTimestampColumnWidth, height: 0)
                    } else {
                        Color.clear.frame(width: 0, height: 0)
                    }
                    Text(syllableDisplay.isEmpty ? "—" : syllableDisplay)
                        .font(.caption.weight(.medium).monospacedDigit())
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .padding(.horizontal, transcriptRowHorizontalPadding)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.15), value: currentTime)
    }
    
    // MARK: - Word-Level Transcript (each word lights up as it plays)
    
    private struct WordLevelSelectableText: UIViewRepresentable {
        let wordTimings: [(text: String, start: TimeInterval, duration: TimeInterval)]
        let currentTime: TimeInterval
        let seekTimestamp: TimeInterval
        var preferredMaxLayoutWidth: CGFloat?
        var lineLimit: Int? = nil
        let onSeek: (TimeInterval) -> Void
        
        private let timeTolerance: TimeInterval = 0.05
        
        func makeUIView(context: Context) -> UITextView {
            let textView = UITextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainer.widthTracksTextView = true
            textView.font = .systemFont(ofSize: 17, weight: .regular)
            textView.isUserInteractionEnabled = true
            textView.dataDetectorTypes = []
            textView.textContainer.maximumNumberOfLines = lineLimit ?? 0
            textView.textContainer.lineBreakMode = .byWordWrapping
            textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            let w = max(140, preferredMaxLayoutWidth ?? 280)
            let widthConstraint = textView.widthAnchor.constraint(equalToConstant: w)
            widthConstraint.priority = .required
            widthConstraint.isActive = true
            context.coordinator.widthConstraint = widthConstraint
            
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.delegate = context.coordinator
            tapGesture.cancelsTouchesInView = false
            textView.addGestureRecognizer(tapGesture)
            
            context.coordinator.textView = textView
            context.coordinator.onSeek = onSeek
            context.coordinator.seekTimestamp = seekTimestamp
            
            return textView
        }
        
        func updateUIView(_ textView: UITextView, context: Context) {
            let fullText = wordTimings.map(\.text).joined(separator: " ")
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byWordWrapping
            
            let attributed = NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                    .paragraphStyle: paragraph
                ]
            )
            
            let nsFull = fullText as NSString
            var offset = 0
            for (i, wt) in wordTimings.enumerated() {
                let isActive = currentTime >= (wt.start - timeTolerance)
                let len = (wt.text as NSString).length
                let range = NSRange(location: offset, length: len)
                let color = isActive ? UIColor.label : UIColor.secondaryLabel.withAlphaComponent(0.78)
                attributed.addAttribute(.foregroundColor, value: color, range: range)
                offset += len
                if i < wordTimings.count - 1 && offset < nsFull.length {
                    attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: offset, length: 1))
                    offset += 1
                }
            }
            
            textView.attributedText = attributed
            
            let w = max(140, preferredMaxLayoutWidth ?? 280)
            if context.coordinator.widthConstraint?.constant != w {
                context.coordinator.widthConstraint?.constant = w
                textView.setNeedsLayout()
                textView.layoutIfNeeded()
            }
            textView.textContainer.maximumNumberOfLines = lineLimit ?? 0
            
            context.coordinator.onSeek = onSeek
            context.coordinator.seekTimestamp = seekTimestamp
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator()
        }
        
        class Coordinator: NSObject, UIGestureRecognizerDelegate {
            weak var textView: UITextView?
            var widthConstraint: NSLayoutConstraint?
            var onSeek: ((TimeInterval) -> Void)?
            var seekTimestamp: TimeInterval = 0
            
            @objc func handleTap(_ gesture: UITapGestureRecognizer) {
                guard let tv = textView, tv.selectedRange.length == 0 else { return }
                onSeek?(seekTimestamp)
            }
            
            func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
                true
            }
        }
    }
    
    // MARK: - Transcript Segment View with Interactive Seeking and Dynamic Highlighting (iOS 26 Notes style)
    
    private func transcriptSegmentView(segment: TranscriptionSegment, rhythmMap: RhythmicTranscriptionResult?, preferredTextWidth: CGFloat) -> some View {
        let timeTolerance: TimeInterval = 0.1
        let isPastOrActive = currentTime >= (segment.timestamp - timeTolerance)
        // Calculate syllables per beat from segment text and BPM (prioritize text-based calculation)
        let syllableDisplay: String
        if let calculated = calculateSyllablesPerBeat(phrase: segment.text, duration: segment.duration, bpm: item.bpm) {
            syllableDisplay = calculated
        } else if let rhythmDisplay = rhythmMap?.syllablePerBeatDisplay(forSegmentTimestamp: segment.timestamp, duration: segment.duration), !rhythmDisplay.isEmpty {
            syllableDisplay = rhythmDisplay
        } else {
            syllableDisplay = ""
        }
        let textWidth = transcriptTextWidth(for: preferredTextWidth)
        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: transcriptRowSpacing) {
                if showTimestamps {
                    Text(formatTime(segment.timestamp))
                        .font(.system(.caption, design: .monospaced).weight(.medium))
                        .foregroundStyle(.secondary.opacity(0.6))
                        .frame(width: transcriptTimestampColumnWidth, alignment: .leading)
                        .fixedSize(horizontal: true, vertical: false)
                } else {
                    Color.clear.frame(width: 0, height: 0)
                }
                SelectableTextWithSeek(
                    text: segment.text,
                    timestamp: segment.timestamp,
                    isPastOrActive: isPastOrActive,
                    preferredMaxLayoutWidth: textWidth,
                    onSeek: { t in HapticFeedbackManager.shared.lightTap(); audioManager.seek(to: t); currentTime = t }
                )
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, transcriptRowHorizontalPadding)
            if item.bpm != nil && item.bpm! > 0 {
                HStack(alignment: .top, spacing: transcriptRowSpacing) {
                    if showTimestamps {
                        Color.clear.frame(width: transcriptTimestampColumnWidth, height: 0)
                    } else {
                        Color.clear.frame(width: 0, height: 0)
                    }
                    Text(syllableDisplay.isEmpty ? "—" : syllableDisplay)
                        .font(.caption.weight(.medium).monospacedDigit())
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .padding(.horizontal, transcriptRowHorizontalPadding)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.2), value: isPastOrActive)
        // iOS 26 Notes: .glassEffectTransition(.materialize) for etch-into-glass appearance when available
    }
    
    // MARK: - Transcript Beat Line View (2 beats per line, syllable below)
    
    private func transcriptBeatLineView(beatLine: BeatLine, preferredTextWidth: CGFloat) -> some View {
        let startTime = TimeInterval(beatLine.startMs) / 1000
        let timeTolerance: TimeInterval = 0.1
        let isPastOrActive = currentTime >= startTime - timeTolerance
        let textWidth = transcriptTextWidth(for: preferredTextWidth)
        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: transcriptRowSpacing) {
                if showTimestamps {
                    Text(formatTime(startTime))
                        .font(.system(.caption, design: .monospaced).weight(.medium))
                        .foregroundStyle(.secondary.opacity(0.6))
                        .frame(width: transcriptTimestampColumnWidth, alignment: .leading)
                        .fixedSize(horizontal: true, vertical: false)
                } else {
                    Color.clear.frame(width: 0, height: 0)
                }
                SelectableTextWithSeek(
                    text: beatLine.text.trimmingCharacters(in: .whitespacesAndNewlines),
                    timestamp: startTime,
                    isPastOrActive: isPastOrActive,
                    preferredMaxLayoutWidth: textWidth,
                    onSeek: { _ in HapticFeedbackManager.shared.lightTap(); audioManager.seek(to: startTime); currentTime = startTime }
                )
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, transcriptRowHorizontalPadding)
            HStack(alignment: .top, spacing: transcriptRowSpacing) {
                if showTimestamps {
                    Color.clear.frame(width: transcriptTimestampColumnWidth, height: 0)
                } else {
                    Color.clear.frame(width: 0, height: 0)
                }
                Text(beatLine.perBeatDisplay)
                    .font(.caption.weight(.medium).monospacedDigit())
                    .foregroundStyle(Momentum.contentSecondary)
            }
            .padding(.horizontal, transcriptRowHorizontalPadding)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.2), value: isPastOrActive)
        // iOS 26 Notes: .glassEffectTransition(.materialize) for etch-into-glass appearance when available
    }
    
    // MARK: - Selectable Text with Seek Functionality (iOS 26 Notes Style)
    
    private struct SelectableTextWithSeek: UIViewRepresentable {
        let text: String
        let timestamp: TimeInterval
        let isPastOrActive: Bool
        /// When set, the text view uses this width so text wraps instead of extending off-screen.
        var preferredMaxLayoutWidth: CGFloat?
        /// When set (e.g. 4), caps visible lines so raw transcript fallback stays collapsed.
        var lineLimit: Int? = nil
        let onSeek: (TimeInterval) -> Void
        
        func makeUIView(context: Context) -> UITextView {
            let textView = UITextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainer.widthTracksTextView = true
            textView.font = .systemFont(ofSize: 17, weight: .regular)
            textView.textColor = isPastOrActive ? .label : .secondaryLabel.withAlphaComponent(0.78)
            textView.text = text
            textView.isUserInteractionEnabled = true
            textView.dataDetectorTypes = []
            textView.textContainer.maximumNumberOfLines = lineLimit ?? 0
            textView.textContainer.lineBreakMode = .byWordWrapping
            textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            // Width constraint so the view wraps at preferredMaxLayoutWidth; avoid exceeding device bounds when nil
            let initialWidth = max(140, preferredMaxLayoutWidth ?? 280)
            let widthConstraint = textView.widthAnchor.constraint(equalToConstant: initialWidth)
            widthConstraint.priority = .required
            widthConstraint.isActive = true
            context.coordinator.widthConstraint = widthConstraint
            
            // Configure for iOS 26 Notes style - fully selectable and copyable
            textView.allowsEditingTextAttributes = false
            
            // Add tap gesture for seeking (works when no text is selected)
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.delegate = context.coordinator
            tapGesture.cancelsTouchesInView = false
            textView.addGestureRecognizer(tapGesture)
            
            context.coordinator.textView = textView
            context.coordinator.onSeek = onSeek
            context.coordinator.timestamp = timestamp
            
            return textView
        }
        
        func updateUIView(_ textView: UITextView, context: Context) {
            // Update text and color
            if textView.text != text {
                textView.text = text
            }
            
            // Improved contrast: active text full opacity, inactive text 0.75-0.8 opacity instead of 0.4
            let newColor = isPastOrActive ? UIColor.label : UIColor.secondaryLabel.withAlphaComponent(0.78)
            if textView.textColor != newColor {
                textView.textColor = newColor
            }
            
            // Apply width so text wraps; cap when nil to avoid exceeding device bounds
            let w = max(140, preferredMaxLayoutWidth ?? 280)
            if context.coordinator.widthConstraint?.constant != w {
                context.coordinator.widthConstraint?.constant = w
                textView.setNeedsLayout()
                textView.layoutIfNeeded()
            }
            textView.textContainer.maximumNumberOfLines = lineLimit ?? 0
            
            context.coordinator.onSeek = onSeek
            context.coordinator.timestamp = timestamp
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator()
        }
        
        class Coordinator: NSObject, UIGestureRecognizerDelegate {
            weak var textView: UITextView?
            var widthConstraint: NSLayoutConstraint?
            var onSeek: ((TimeInterval) -> Void)?
            var timestamp: TimeInterval = 0
            
            @objc func handleTap(_ gesture: UITapGestureRecognizer) {
                guard let textView = textView else { return }
                
                // Only seek if no text is currently selected
                // This allows text selection to work normally
                let selectedRange = textView.selectedRange
                if selectedRange.length == 0 {
                    // No selection - seek to timestamp
                    print("🟡 Text tapped - seeking to: \(timestamp)s")
                    onSeek?(timestamp)
                }
                // If text is selected, the system handles copy/selection menu
            }
            
            func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                // Allow simultaneous recognition with text selection gestures
                return true
            }
            
            func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                // Don't block text selection gestures
                if otherGestureRecognizer is UILongPressGestureRecognizer {
                    return true // Require failure of long press (text selection)
                }
                return false
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        // Format as HH:MM:SS for longer audio (> 1 hour), otherwise MM:SS
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    /// Calculate syllables per beat for a phrase based on its text and duration
    /// Returns a string like "3 4 2" representing syllables per beat, or nil if BPM is unavailable
    private func calculateSyllablesPerBeat(phrase: String, duration: TimeInterval, bpm: Int?) -> String? {
        guard let bpm = bpm, bpm > 0, duration > 0 else { return nil }
        
        // Count syllables in the phrase text
        let totalSyllables = countSyllablesInText(phrase)
        guard totalSyllables > 0 else { return nil }
        
        // Calculate how many beats this phrase spans
        // beats = (duration in seconds) * (bpm / 60)
        let beats = duration * Double(bpm) / 60.0
        let numberOfBeats = max(1, Int(beats.rounded()))
        
        // Distribute syllables across beats
        // Simple distribution: divide syllables evenly across beats
        let syllablesPerBeat = totalSyllables / numberOfBeats
        let remainder = totalSyllables % numberOfBeats
        
        // Create array: most beats get syllablesPerBeat, remainder beats get +1
        var distribution: [Int] = []
        for i in 0..<numberOfBeats {
            if i < remainder {
                distribution.append(syllablesPerBeat + 1)
            } else {
                distribution.append(syllablesPerBeat)
            }
        }
        
        // Format as space-separated string
        return distribution.map { String($0) }.joined(separator: " ")
    }
    
    /// Count syllables in text using CMUDICT
    private func countSyllablesInText(_ text: String) -> Int {
        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
        
        var totalSyllables = 0
        for word in words {
            guard let phonemes = FJCMUDICTStore.shared.phonemesByWord[word] else { continue }
            // Count syllables: each phoneme ending in a number (0, 1, 2) represents a syllable
            for phone in phonemes {
                if let last = phone.last, last.isNumber {
                    totalSyllables += 1
                }
            }
        }
        return totalSyllables
    }
    
    // MARK: - Playback Controls
    
    private var playbackDuration: TimeInterval {
        if audioManager.duration.isFinite, audioManager.duration > 0 { return audioManager.duration }
        return item.audioDuration ?? 0
    }

    private var playbackProgress: Double {
        guard playbackDuration > 0 else { return 0 }
        return isDraggingProgress ? dragProgress : min(1, max(0, currentTime / playbackDuration))
    }

    private var scrubDisplayTime: TimeInterval {
        if isDraggingProgress, playbackDuration > 0 { return dragProgress * playbackDuration }
        return currentTime
    }

    /// Wide, short transport bar with a scrubber — Apple Notes style.
    private var playbackControlsContainer: some View {
        playbackControlsView
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(sheetCardBackground)
    }

    private var playbackControlsView: some View {
        VStack(spacing: 6) {
            AudioScrubberTrack(
                progress: playbackProgress,
                isDragging: isDraggingProgress,
                onScrubChanged: { fraction in
                    isDraggingProgress = true
                    dragProgress = fraction
                    if playbackDuration > 0 {
                        currentTime = fraction * playbackDuration
                    }
                },
                onScrubEnded: { fraction in
                    let seekTime = playbackDuration > 0 ? fraction * playbackDuration : 0
                    audioManager.seek(to: seekTime)
                    currentTime = seekTime
                    isDraggingProgress = false
                    dragProgress = 0
                }
            )
            .disabled(playbackDuration <= 0 && !audioManager.isReady)
            .opacity(playbackDuration > 0 ? 1 : 0.45)
            .accessibilityLabel("Playback position")
            .accessibilityValue(playbackDuration > 0
                ? "\(formatTime(currentTime)) of \(formatTime(playbackDuration))"
                : "Duration not loaded yet")
            .accessibilityHint("Swipe up or down to move in 5 second steps.")
            .accessibilityAdjustableAction { direction in
                let step: TimeInterval = 5
                let newTime = direction == .increment
                    ? min(max(playbackDuration, currentTime), currentTime + step)
                    : max(0, currentTime - step)
                audioManager.seek(to: newTime)
            }

            HStack {
                Text(formatTime(scrubDisplayTime))
                Spacer()
                Text(playbackDuration > 0 ? formatTime(playbackDuration) : "--:--")
            }
            .font(.caption2.monospacedDigit())
            .foregroundStyle(.white.opacity(0.55))
            .accessibilityHidden(true)

            HStack(spacing: 36) {
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    audioManager.skipBackward(seconds: 15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 36, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Skip back 15 seconds")

                Button {
                    HapticFeedbackManager.shared.lightTap()
                    if audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(audioManager.isPlaying ? "Pause" : "Play")
                .accessibilityHint(audioManager.isPlaying ? "Pauses this recording." : "Plays this recording.")

                Button {
                    HapticFeedbackManager.shared.lightTap()
                    audioManager.skipForward(seconds: 15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 36, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Skip forward 15 seconds")
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadAudio() {
        guard let audioPath = item.audioPath else { return }
        let title = item.title.isEmpty ? nil : item.title
        audioManager.loadAudio(from: audioPath, title: title, seedDuration: item.audioDuration)
        currentTime = audioManager.currentTime
    }
    
    private func startTimer() {
        stopTimer()
        // Timer is not needed - currentTime is updated via .onReceive(audioManager.$currentTime)
        // This function is kept for API compatibility but does nothing
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startDisplayLink() {
        stopDisplayLink()
        // DisplayLink not needed - currentTime is updated via .onReceive(audioManager.$currentTime)
        // This function is kept for API compatibility but does nothing
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // Helper class for CADisplayLink target
    private class DisplayLinkTarget: NSObject {
        let callback: () -> Void
        
        init(callback: @escaping () -> Void) {
            self.callback = callback
        }
        
        @objc func update() {
            callback()
        }
    }
    
    // MARK: - Transcription
    
    @MainActor
    private func triggerTranscriptionIfNeeded(audioPath: String) async {
        // Check if transcription already exists
        let hasText = !(item.transcription?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        guard !hasText else { return }
        
        await triggerTranscription(audioPath: audioPath, force: false)
    }
    
    @MainActor
    private func triggerTranscription(audioPath: String, force: Bool = false) async {
        // Efficient caching: Check if transcription already exists and is valid
        if !force {
            let hasValidTranscription = item.transcription != nil && !item.transcription!.isEmpty
            let hasValidSegments = item.transcriptionSegments != nil && !item.transcriptionSegments!.isEmpty
            if hasValidTranscription && hasValidSegments {
                print("📝 AudioDetailSheet: Transcription already exists, skipping (use force: true to re-transcribe)")
                return
            }
        }
        // Prefer this note's stored path. Filename-only lookup can pick another recording.
        let actualPath: String
        if FileManager.default.fileExists(atPath: audioPath) {
            actualPath = audioPath
        } else {
            actualPath = await findAudioFile(originalPath: audioPath) ?? audioPath
        }
        let audioURL = URL(fileURLWithPath: actualPath)
        
        guard FileManager.default.fileExists(atPath: actualPath) else {
            print("❌ Audio file not found at path: \(actualPath)")
            await MainActor.run {
                transcriptionError = "Audio file not found. The file may have been moved or deleted."
            }
            return
        }
        
        let fileExt = (actualPath as NSString).pathExtension
        let durationStr = item.audioDuration.map { String(format: "%.1fs", $0) } ?? "unknown"
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: actualPath)[.size] as? Int64) ?? 0
        print("📝 AudioDetailSheet: Using this note’s audio file (same file as playback). Path: \(actualPath), duration: \(durationStr), size: \(fileSize) bytes, ext: \(fileExt)")
        
        if actualPath != audioPath, !FileManager.default.fileExists(atPath: audioPath) {
            item.audioPath = actualPath
            print("✅ Updated audio path to: \(actualPath)")
        }
        
        await MainActor.run {
            isTranscribing = true
            transcriptionError = nil
            lastHeardTime = 0
            lastHeardAt = Date()
        }
        print("🔄 Starting transcription (Speech framework) for: \(actualPath) (force: \(force))")
        
        // Avoid SessionCore / FigApplicationStateMonitor conflicts: use a neutral audio session
        // during recognition instead of .playback. Notes doesn’t have playback active when transcribing.
        audioManager.pause()
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default)
            try session.setActive(true, options: [.notifyOthersOnDeactivation])
            print("📝 AudioDetailSheet: Set audio session to .ambient for Speech recognition")
        } catch {
            print("⚠️ AudioDetailSheet: Could not set ambient session before transcription: \(error.localizedDescription)")
        }
        
        do {
            let itemID = item.persistentModelID
            TranscriptionLiveBoard.items[itemID] = item
            defer { TranscriptionLiveBoard.items[itemID] = nil }
            let result = try await transcriptionService.transcribe(audioURL: audioURL) { segments, text in
                let id = itemID
                Task { @MainActor in
                    TranscriptionLiveBoard.publish(id: id, text: text, segments: segments)
                }
            }
            TranscriptionLiveBoard.items[itemID] = nil
            
            await MainActor.run {
                item.transcription = result.fullText
                item.transcriptionSegments = result.segments
                item.modifiedDate = Date()
                rebuildNotesRows()
                
                // Debug: Verify segments before saving
                print("📝 Saving transcription - segments count: \(result.segments.count)")
                if let firstSegment = result.segments.first {
                    print("📝 First segment: '\(firstSegment.text)' at \(firstSegment.timestamp)s")
                }
                
                // Force save to SwiftData
                do {
                    try item.modelContext?.save()
                    print("✅ Transcription saved to SwiftData successfully")
                    
                    // Verify segments were saved by reading them back
                    if let savedSegments = item.transcriptionSegments {
                        print("✅ Verified segments after save: \(savedSegments.count) segments with timestamps")
                        // Log a few timestamps to verify they're populated
                        for (index, segment) in savedSegments.prefix(3).enumerated() {
                            print("   Segment \(index + 1): [\(formatTime(segment.timestamp))] \(segment.text.prefix(30))...")
                        }
                    } else {
                        print("⚠️ Warning: Segments are nil after save")
                    }
                } catch {
                    print("❌ Failed to save transcription to SwiftData: \(error.localizedDescription)")
                }
                
                isTranscribing = false
                print("✅ Transcription completed - \(result.fullText.count) characters, \(result.segments.count) segments with timestamps")
            }
            await ensureSummary(force: true)
            
            // Run BPM/key/scale analysis if not already present, then build rhythm map
            if item.bpm == nil {
                print("📝 AudioDetailSheet: BPM nil — running audio analysis (BPM, Key, Scale)")
                await analyzeAudio(audioPath: actualPath)
            }
            await MainActor.run {
                print("📝 AudioDetailSheet: Building rhythm map from \(result.segments.count) segments, BPM: \(item.bpm?.description ?? "nil")")
                let rhythm = TranscriptionAssembler.assemble(
                    segments: result.segments,
                    bpm: item.bpm,
                    timeSignature: .fourFour,
                    barOffsetMs: 0,
                    audioId: nil
                )
                if let data = try? JSONEncoder().encode(rhythm) {
                    item.transcriptionRhythmMapData = data
                    try? item.modelContext?.save()
                    print("✅ Rhythm map saved (\(rhythm.syllables.events.count) syllable events, \(rhythm.syllables.perBar.count) bars)")
                } else {
                    print("⚠️ AudioDetailSheet: Failed to encode rhythm map")
                }
            }
        } catch {
            await MainActor.run {
                isTranscribing = false
                let rawMessage = error.localizedDescription
                let kept = !(item.transcription?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
                if kept {
                    transcriptionError = nil
                    rebuildNotesRows()
                    flashBanner("Listen stopped. Restart to try the rest.")
                    print("❌ Transcription stopped with lines kept: \(rawMessage)")
                } else if rawMessage.contains("No speech recognized") {
                    transcriptionError = rawMessage + "\n\nIf this is music or non‑speech, Speech won’t return text. Use “Analyze BPM only” below for BPM/Key, or try speech-only audio and match device language to the recording."
                    print("❌ Transcription failed: \(rawMessage)")
                } else {
                    transcriptionError = rawMessage
                    print("❌ Transcription failed: \(rawMessage)")
                }
            }
        }
        
        // Restore playback session so Play works again
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.allowBluetoothHFP, .allowBluetoothA2DP])
            try session.setActive(true, options: [.notifyOthersOnDeactivation])
            print("📝 AudioDetailSheet: Restored audio session to .playback")
        } catch {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
                print("📝 AudioDetailSheet: Restored audio session to .playback (no Bluetooth options)")
            } catch {
                print("⚠️ AudioDetailSheet: Could not restore playback session: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Transcription UI Components
    
    /// Transcription area buttons: Transcribe (when empty) + Restart (always)
    private var transcriptionButtonsView: some View {
        HStack(spacing: 12) {
            if item.transcription == nil || item.transcription!.isEmpty {
                transcribeButton
            }
            restartTranscriptionButton
        }
    }
    
    /// Progress overlay with Restart button when transcription is in progress (or hanging)
    private var transcriptionProgressWithRestart: some View {
        HStack(spacing: 12) {
            transcriptionProgressOverlay
            restartTranscriptionButton
        }
    }
    
    private var restartTranscriptionButton: some View {
        Button {
            guard let audioPath = item.audioPath else { return }
            HapticFeedbackManager.shared.lightTap()
            Task {
                await triggerTranscription(audioPath: audioPath, force: true)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.clockwise")
                    .font(.subheadline)
                Text("Restart")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(.orange)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.orange.opacity(0.6), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var transcribeButton: some View {
        Button {
            guard let audioPath = item.audioPath else { return }
            HapticFeedbackManager.shared.lightTap()
            Task {
                await triggerTranscription(audioPath: audioPath, force: true)
            }
        } label: {
            HStack {
                Image(systemName: "waveform")
                    .font(.subheadline)
                Text("Transcribe Audio")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.orange)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var transcriptionProgressView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
            Text("Transcribing audio...")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
    }
    
    private var transcriptionErrorView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Transcription Error")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            if let error = transcriptionError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            HStack(spacing: 12) {
                Button("Try Again") {
                    guard let audioPath = item.audioPath else { return }
                    Task {
                        await triggerTranscription(audioPath: audioPath, force: true)
                    }
                }
                .font(.caption)
                .foregroundStyle(.orange)
                if transcriptionError?.contains("No speech recognized") == true {
                    Button("Analyze BPM only") {
                        guard let audioPath = item.audioPath else { return }
                        Task {
                            transcriptionError = nil
                            await analyzeAudio(audioPath: audioPath)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.purple)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
    }
    
    // MARK: - Audio Analysis UI
    
    private var audioAnalysisProgressView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
            Text("Analyzing audio (BPM, Key, Scale)...")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
    }
    
    private var analyzeAudioButton: some View {
        Button {
            guard let audioPath = item.audioPath else { return }
            Task {
                await analyzeAudio(audioPath: audioPath)
            }
        } label: {
            HStack {
                Image(systemName: "waveform.path")
                    .font(.subheadline)
                Text("Analyze Audio (BPM, Key)")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.purple)
            )
        }
        .buttonStyle(.plain)
        .disabled(isAnalyzingAudio)
    }
    
    // MARK: - Audio File Finder Helper
    
    private func findAudioFile(originalPath: String) async -> String? {
        let fileManager = FileManager.default
        let appGroupID = "group.com.finaljournal.app"
        let filename = (originalPath as NSString).lastPathComponent
        
        if fileManager.fileExists(atPath: originalPath) {
            return originalPath
        }

        // Try App Group container (for files imported via Share Extension)
        if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let appGroupPath = containerURL.appendingPathComponent(filename).path
            if fileManager.fileExists(atPath: appGroupPath) {
                return appGroupPath
            }
        }
        
        // Try document directory
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let documentsPath = documentsURL.appendingPathComponent(filename).path
            if fileManager.fileExists(atPath: documentsPath) {
                return documentsPath
            }
        }
        
        return nil
    }
    
    private func analyzeAudio(audioPath: String) async {
        // Try to find the audio file (may be in different location)
        let actualPath = await findAudioFile(originalPath: audioPath) ?? audioPath
        let url = URL(fileURLWithPath: actualPath)
        
        // Verify file exists
        guard FileManager.default.fileExists(atPath: actualPath) else {
            await MainActor.run {
                audioAnalysisError = "Audio file not found. The file may have been moved or deleted."
            }
            return
        }
        
        // Update item's audio path if we found it in a different location
        if actualPath != audioPath {
            await MainActor.run {
                item.audioPath = actualPath
            }
        }
        
        await MainActor.run {
            isAnalyzingAudio = true
            audioAnalysisError = nil
        }
        
        do {
            print("🎵 Starting audio analysis (BPM, Key, Scale)...")
            let analysis = try await AudioAnalysisService.shared.analyzeAudio(url: url)
            
            await MainActor.run {
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
                
                // Force save to SwiftData to ensure values persist and UI updates
                try? item.modelContext?.save()
                print("✅ Audio metadata saved: BPM=\(item.bpm?.description ?? "nil"), Key=\(item.key ?? "nil"), Scale=\(item.scale ?? "nil")")
                
                isAnalyzingAudio = false
            }
        } catch {
            await MainActor.run {
                isAnalyzingAudio = false
                audioAnalysisError = error.localizedDescription
                print("❌ Audio analysis failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func formatTimer(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let centiseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
}
