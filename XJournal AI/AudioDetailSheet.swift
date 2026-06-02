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

// MARK: - Full-Screen Transcription Detail View

struct AudioDetailSheet: View {
    @Bindable var item: Item
    var autoTranscribe: Bool = false // Flag to auto-trigger transcription on appear
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var audioManager = AudioPlayerManager()
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
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var isPlayerVisible: Bool = true
    /// Cached phrase rows so we don't recompute on every body evaluation (was causing slow transcript population).
    @State private var cachedPhraseRows: [PhraseRow]? = nil
    /// Cached decoded rhythm map to avoid decoding JSON in body every time.
    @State private var cachedRhythmMap: RhythmicTranscriptionResult? = nil
    
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
                
                // Audio analysis CTA when metadata isn't available yet
                if item.bpm == nil && item.key == nil && item.scale == nil && item.audioPath != nil {
                    if isAnalyzingAudio {
                        audioAnalysisProgressView
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                    } else {
                        analyzeAudioButton
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                    }
                }
                
                // TRANSCRIPTION SURFACE: Fill available space so ScrollView can scroll all content
                transcriptView
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                
                // PLAYBACK CONTROLS: Show/hide based on scroll position
                if isPlayerVisible {
                    playbackControlsContainer
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Transcription status/button area
                if item.audioPath != nil {
                    if isTranscribing {
                        transcriptionProgressWithRestart
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    } else if transcriptionError != nil {
                        transcriptionErrorView
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    } else {
                        transcriptionButtonsView
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    }
                }
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
                // Auto-transcribe when missing or when we have text but no segments
                Task {
                    await triggerTranscriptionIfNeeded(audioPath: audioPath)
                }
            }
        }
        .onDisappear {
            stopTimer()
            stopDisplayLink()
            audioManager.pause()
        }
        .onReceive(audioManager.$currentTime) { time in
            currentTime = time
            // Smoothly animate to new time
            withAnimation(.linear(duration: 0.1)) {
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
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                // Menu button
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    showMenu = true
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.microCompression)
                .confirmationDialog("Audio Options", isPresented: $showMenu, titleVisibility: .visible) {
                    Button("Share Audio") {
                        shareAudio()
                    }
                    
                    Button("Export Transcription") {
                        exportTranscription()
                    }
                    
                    if item.audioPath != nil {
                        Button("Delete Audio", role: .destructive) {
                            deleteAudio()
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {}
                }
                
                Spacer()
                
                // Title and metadata
                VStack(spacing: 4) {
                    Text(displayTitle)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    
                    Text(dateTimeString)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(Momentum.contentSecondary)
                }
                
                Spacer()
                
                // Yellow checkmark button (Segment 7) with circular glassProminent style
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    print("🟡 Done button tapped")
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.9),
                                    Color.yellow.opacity(0.8),
                                    Color.yellow.opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .blendMode(.overlay)
                        )
                        .shadow(color: Color.yellow.opacity(0.4), radius: 8, x: 0, y: 4)
                )
                .buttonStyle(.plain)
            }
            
            if item.bpm != nil || item.key != nil || item.scale != nil {
                audioMetadataView
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // MARK: - Audio Metadata View
    
    private var audioMetadataView: some View {
        HStack(spacing: 10) {
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
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func metadataPill(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
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
            transcriptPreviewSection(fullText: fullText)
        } else if useBeatLineView {
            ForEach(beatLines) { line in
                transcriptBeatLineView(beatLine: line, preferredTextWidth: contentWidth)
            }
        } else if !segments.isEmpty {
            ForEach(segments) { segment in
                transcriptSegmentView(segment: segment, rhythmMap: rhythmMap, preferredTextWidth: contentWidth)
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("No transcription available")
                    .font(.body)
                    .foregroundStyle(Momentum.contentSecondary)
            }
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
        if let fullText = item.transcription, !fullText.isEmpty {
            let segs = item.transcriptionSegments ?? []
            Task { @MainActor in
                cachedPhraseRows = buildPhraseRows(fullText: fullText, segments: segs)
            }
        }
    }
    
    private func transcriptOnTranscriptionChange() {
        cachedPhraseRows = nil
        cachedRhythmMap = nil
        if let data = item.transcriptionRhythmMapData {
            cachedRhythmMap = try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: data)
        }
        guard let fullText = item.transcription, !fullText.isEmpty else { return }
        let segs = item.transcriptionSegments ?? []
        Task { @MainActor in
            cachedPhraseRows = buildPhraseRows(fullText: fullText, segments: segs)
        }
    }
    
    private func transcriptOnSegmentsChange() {
        cachedPhraseRows = nil
        if let data = item.transcriptionRhythmMapData {
            cachedRhythmMap = try? JSONDecoder().decode(RhythmicTranscriptionResult.self, from: data)
        }
        guard let fullText = item.transcription, !fullText.isEmpty else { return }
        let segs = item.transcriptionSegments ?? []
        Task { @MainActor in
            cachedPhraseRows = buildPhraseRows(fullText: fullText, segments: segs)
        }
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
        ZStack(alignment: .top) {
            transcriptViewScrollView
        }
    }
    
    
    /// PreferenceKey for tracking scroll offset
    private struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    /// Transcription progress overlay blended into transcription surface (iOS 26 style)
    private var transcriptionProgressOverlay: some View {
        HStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(0.8)
            Text("Transcribing audio...")
                .font(.subheadline)
                .foregroundStyle(.secondary.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Momentum.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
    @State private var showTimestamps: Bool = false
    private let transcriptTimestampColumnWidth: CGFloat = 52
    private let transcriptRowSpacing: CGFloat = 10
    private let transcriptRowHorizontalPadding: CGFloat = 24 // Increased from 2px to 24px per side
    
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
        return VStack(alignment: .leading, spacing: 12) {
            if showTimestamps {
                Text("By line")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Momentum.contentSecondary)
            } else {
                Text("By line")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.tertiary)
            }
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
                        .foregroundStyle(.secondary.opacity(0.6))
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
    
    /// Subtle/material style container for playback controls (no border, subtle blur)
    private var playbackControlsContainer: some View {
        VStack(spacing: 12) {
            playbackControlsView
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.6))
        )
    }
    
    private var playbackControlsView: some View {
        VStack(spacing: 12) {
            // Reduced timer display size (less prominent)
            Text(formatTimer(animatedTime))
                .font(.system(.title, design: .monospaced).weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.1), value: animatedTime)
            
            // Playback buttons (reduced size)
            HStack(spacing: 28) {
                // Skip backward 15s
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    print("🟡 Skip backward button tapped")
                    audioManager.skipBackward(seconds: 15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.microCompression)
                .contentShape(Circle())
                
                // Play/Pause (smaller)
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    print("🟡 Play/Pause button tapped - isPlaying: \(audioManager.isPlaying)")
                    if audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.microCompression)
                .contentShape(Circle())
                
                // Skip forward 15s
                Button {
                    HapticFeedbackManager.shared.lightTap()
                    print("🟡 Skip forward button tapped")
                    audioManager.skipForward(seconds: 15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.microCompression)
                .contentShape(Circle())
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadAudio() {
        guard let audioPath = item.audioPath else { return }
        // Use item title or filename for lock screen display
        let title = item.title.isEmpty ? nil : item.title
        audioManager.loadAudio(from: audioPath, title: title)
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
        guard item.transcription == nil || item.transcription!.isEmpty || 
              item.transcriptionSegments == nil || item.transcriptionSegments!.isEmpty else {
            return
        }
        
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
        // Try to find the audio file (may be in different location)
        let actualPath = await findAudioFile(originalPath: audioPath) ?? audioPath
        let audioURL = URL(fileURLWithPath: actualPath)
        
        // Verify file exists (same file that playback uses — the one that got you to this detail view)
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
        
        // Update item's audio path if we found it in a different location
        if actualPath != audioPath {
            item.audioPath = actualPath
            print("✅ Updated audio path to: \(actualPath)")
        }
        
        await MainActor.run {
            isTranscribing = true
            transcriptionError = nil
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
            let result = try await transcriptionService.transcribe(audioURL: audioURL)
            
            await MainActor.run {
                item.transcription = result.fullText
                item.transcriptionSegments = result.segments
                item.modifiedDate = Date()
                
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
                if rawMessage.contains("No speech recognized") {
                    transcriptionError = rawMessage + "\n\nIf this is music or non‑speech, Speech won’t return text. Use “Analyze BPM only” below for BPM/Key, or try speech-only audio and match device language to the recording."
                } else {
                    transcriptionError = rawMessage
                }
                print("❌ Transcription failed: \(rawMessage)")
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
