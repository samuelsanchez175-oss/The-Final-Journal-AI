//
// ContentView.CCV.13.swift
//
// This file contains NoteEditorView.
//
// Dependencies:
// - ContentView.CCV.2.swift (for GlassSettings, ScrollOffsetKey, lightHaptic)
// - ContentView.CCV.3.swift (for RhymeHighlighterEngine, Highlight, RhymeEngineState)
// - ContentView.CCV.4.swift (for AudioPlayerManager)
// - ContentView.CCV.5.swift (for KeyboardObserver)
// - ContentView.CCV.6.swift (for RhymeHighlightTextView)
// - ContentView.CCV.7.swift (for GlassView)
// - ContentView.CCV.8.swift (for PopoverViews)
// - ContentView.CCV.14.swift (for DynamicIslandToolbarView)
// - ContentView.CCV.15.swift (for RhymeGroupListView)
//
import SwiftUI
import SwiftData
import UIKit
import Combine
import Foundation

// #region agent log
extension String {
    func appendLineToFile(atPath path: String) throws {
        // Create directory if it doesn't exist
        let url = URL(fileURLWithPath: path)
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        
        // Now try to append to file
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            defer { fileHandle.closeFile() }
            fileHandle.seekToEndOfFile()
            if let data = (self + "\n").data(using: .utf8) {
                fileHandle.write(data)
            }
        } else {
            // File doesn't exist, create it
            try (self + "\n").write(toFile: path, atomically: true, encoding: .utf8)
        }
    }
}
// #endregion
import NaturalLanguage
import AVFoundation
import Speech
import PhotosUI
import UniformTypeIdentifiers

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage(EditorChromeSettings.hideToolbarGlassKey) private var hideToolbarGlass = true
    @Bindable var item: Item

    @State private var isRhymeOverlayVisible: Bool = false
    @State private var showRhymeDiagnostics: Bool = false
    @FocusState private var isEditorFocused: Bool
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State private var isToolbarExpanded: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var savedScrollPosition: CGFloat = 0 // SEGMENT 20: Save scroll position to prevent jump
    @State private var rhymeOverlayHeight: CGFloat = 40 // Dynamic height for rhyme overlay
    @StateObject private var rhymeEngineState = RhymeEngineState()

    @AppStorage("toolbar_ai_last_suggestion_model") private var lastToolbarSuggestionModelRaw: String = SuggestionModel.modelGv3.rawValue

    /// Control surface generation uses `.modelG` so DirectedGenerationParams + Model G Core v3 coordinator stay wired.
    private var modelGControlSurfaceAPIModel: SuggestionModel { .modelG }
    
    // Onboarding splash screen state
    @ObservedObject private var splashManager = SplashScreenManager.shared
    @State private var showToolbarOverview: Bool = false
    @State private var showToolbarButtonSplash: Bool = false
    @State private var currentButtonSplashID: SplashScreenID?
    @State private var toolbarFrame: CGRect?
    @State private var buttonFrames: [SplashScreenID: CGRect] = [:]
    
    // Helper function to count trailing newlines
    private func countTrailingNewlines(in text: String) -> Int {
        var count = 0
        var index = text.endIndex
        while index > text.startIndex {
            let previousIndex = text.index(before: index)
            if text[previousIndex] == "\n" {
                count += 1
                index = previousIndex
            } else {
                break
            }
        }
        return count
    }
    
    // No longer using trailing newlines - using padding instead to avoid text splitting issues
    // This function is kept for compatibility but is no longer used
    private func ensureTrailingNewlines() {
        // Padding is handled by TextEditor's bottom padding instead
    }

    private var rhymeGroups: [RhymeHighlighterEngine.RhymeGroup] {
        rhymeEngineState.cachedGroups
    }

    private var computedHighlights: [Highlight] {
        // Use actual text for highlight calculations (no trailing newlines)
        let displayText = item.body
        var highlights = rhymeEngineState.cachedHighlights
        
        // Add context highlights for last 4 lines when generating suggestions
        if showContextHighlight {
            let contextHighlights = calculateContextHighlights(text: displayText)
            highlights.append(contentsOf: contextHighlights)
        }
        
        // Add AI-generated text highlights (blue color)
        let aiHighlights = calculateAITextHighlights(text: displayText)
        highlights.append(contentsOf: aiHighlights)
        
        return highlights
    }
    
    // Computed properties for use in closures
    private var currentText: String {
        item.body
    }
    
    private var highlights: [Highlight] {
        computedHighlights
    }

    private var aiNoteKey: String {
        NoteSuggestionSessionStore.noteKey(for: item)
    }

    private var hasRecallableSuggestionsOnNote: Bool {
        NoteSuggestionSessionStore.hasSession(on: item) || rapSuggestionEngine.hasRecallableSuggestions
    }

    private func retryHumanCriticForCurrentNote() {
        let batch = rapSuggestionEngine.lastBatchSuggestions.isEmpty
            ? rapSuggestionEngine.suggestions
            : rapSuggestionEngine.lastBatchSuggestions
        let verse = rapSuggestionEngine.lastSessionContextText ?? currentText
        rapSuggestionEngine.refreshHumanCritic(
            userVerse: verse,
            primarySuggestion: batch.first,
            themes: Array(Set(batch.flatMap(\.themes))).prefix(6).map { $0 },
            persistTo: item,
            model: rapSuggestionEngine.lastStandardGenerationModel
        )
    }
    
    // Improve flow function
    private func improveFlow() async {
        isImprovingFlow = true
        improveFlowLoadingStep = "Analyzing flow..."
        defer {
            isImprovingFlow = false
            improveFlowLoadingStep = nil
        }
        
        await rapSuggestionEngine.generateSuggestions(
            text: currentText,
            highlights: highlights,
            bpm: item.bpm,
            key: item.key,
            scale: item.scale,
            audioURL: item.audioPath.flatMap { URL(fileURLWithPath: $0) },
            transcriptionRhythmMapData: item.transcriptionRhythmMapData,
            noteKey: aiNoteKey,
            noteTitle: item.title,
            persistTo: item
        )
        
        improveFlowSuggestions = rapSuggestionEngine.suggestions
        if !improveFlowSuggestions.isEmpty {
            showImproveFlow = true
        }
    }
    
    // MARK: - AI Text Highlights
    
    /// Pure: builds blue highlights for the currently-stored AI text ranges.
    /// MUST NOT mutate model state — this runs inside `computedHighlights` during view
    /// updates. Stale/out-of-bounds ranges are simply skipped here; they get pruned
    /// off the render path in `pruneInvalidAITextRanges()`.
    private func calculateAITextHighlights(text: String) -> [Highlight] {
        guard !text.isEmpty, !item.aiTextRanges.isEmpty else { return [] }

        var highlights: [Highlight] = []
        for rangeString in item.aiTextRanges {
            guard let range = aiTextRange(from: rangeString, in: text) else { continue }
            // Use blue color (index 3) for AI-generated text
            highlights.append(Highlight(
                range: range,
                colorIndex: 3, // Blue color
                strength: .perfect,
                rhymeType: .endRhyme
            ))
        }
        return highlights
    }

    /// Parses a "start:end" character-offset range string into a `String` range,
    /// bounds-checked against `text`. Returns nil when the range is malformed or no
    /// longer fits the text (e.g. after an edit shortened the body).
    private func aiTextRange(from rangeString: String, in text: String) -> Range<String.Index>? {
        let components = rangeString.split(separator: ":")
        guard components.count == 2,
              let start = Int(components[0]),
              let end = Int(components[1]),
              start >= 0,
              end <= text.count,
              start < end,
              let startIndex = text.index(text.startIndex, offsetBy: start, limitedBy: text.endIndex),
              let endIndex = text.index(text.startIndex, offsetBy: end, limitedBy: text.endIndex),
              startIndex < endIndex else {
            return nil
        }
        return startIndex..<endIndex
    }

    /// Drops AI text ranges that no longer fit the current body. Call this OFF the render
    /// path (e.g. from `.onChange(of: item.body)`) — it writes to the model, so it must
    /// never run during view-body evaluation.
    private func pruneInvalidAITextRanges() {
        guard !item.aiTextRanges.isEmpty else { return }
        let text = item.body
        let validRanges = item.aiTextRanges.filter { aiTextRange(from: $0, in: text) != nil }
        if validRanges.count != item.aiTextRanges.count {
            item.aiTextRanges = validRanges
        }
    }
    
    // MARK: - Context Highlights (Last 4 lines for AI suggestions)
    
    private func calculateContextHighlights(text: String) -> [Highlight] {
        guard !text.isEmpty else { return [] }
        
        let lines = text.components(separatedBy: "\n")
        guard lines.count >= 1 else { return [] }
        
        var highlights: [Highlight] = []
        
        // Calculate ranges for each line
        var currentIndex = text.startIndex
        
        // Find the starting index of the last 4 lines
        let linesSkipped = max(0, lines.count - 4)
        
        for (index, line) in lines.enumerated() {
            if index >= linesSkipped {
                // This is one of the last 4 lines
                let lineEndIndex = text.index(currentIndex, offsetBy: line.count, limitedBy: text.endIndex) ?? text.endIndex
                let lineRange = currentIndex..<lineEndIndex
                
                // Create highlight for entire line (including newline if not last line)
                let highlightRange: Range<String.Index>
                if index < lines.count - 1 {
                    // Include newline character
                    let newlineEnd = text.index(lineRange.upperBound, offsetBy: 1, limitedBy: text.endIndex) ?? text.endIndex
                    highlightRange = lineRange.lowerBound..<newlineEnd
                } else {
                    // Last line, no newline
                    highlightRange = lineRange
                }
                
                // Use blue background highlight (index 3 from RhymeColorPalette) and perfect strength
                // This is a background highlight, not foreground color
                highlights.append(Highlight(
                    range: highlightRange,
                    colorIndex: 3, // Blue color for background
                    strength: .perfect,
                    rhymeType: .endRhyme
                ))
            }
            
            // Move to next line
            if index < lines.count - 1 {
                // Skip to after the newline
                let nextLineStart = text.index(currentIndex, offsetBy: line.count + 1, limitedBy: text.endIndex) ?? text.endIndex
                currentIndex = nextLineStart
            }
        }
        
        return highlights
    }

    // MARK: - Metadata Popover States
    @State private var showBPMPopover: Bool = false
    @State private var showKeyPopover: Bool = false
    @State private var showScalePopover: Bool = false
    @State private var showURLPopover: Bool = false
    @State private var showFolderPopover: Bool = false
    @State private var showAudioRecorder: Bool = false
    @State private var showRapSuggestions: Bool = false
    @State private var showModelGControlSurface: Bool = false
    @State private var isShowingRecalled: Bool = false
    @State private var showContextHighlight: Bool = false
    @State private var showAudioImporter: Bool = false
    @State private var showImportNotesInstructions: Bool = false
    @State private var showAudioDetailSheet: Bool = false
    @State private var showRawTranscriptOnSurface: Bool = false
    @State private var shouldAutoTranscribe: Bool = false
    @State private var showFindInTranscript: Bool = false
    @StateObject private var transcriptionService = AudioTranscriptionService()
    @StateObject private var rapSuggestionEngine = RapSuggestionEngine()
    
    // New features state
    @State private var showRhymeSuggestions: Bool = false
    @State private var showImproveFlow: Bool = false
    @State private var showRewriteLine: Bool = false
    @State private var lastWordRhymes: [RhymeSuggestion] = []
    @State private var targetWordForRhymes: String = ""
    @State private var improveFlowSuggestions: [RapSuggestion] = []
    @State private var rewriteLineSuggestion: String = ""
    
    // Loading states for new features
    @State private var isRewritingLine: Bool = false
    @State private var isImprovingFlow: Bool = false
    @State private var rewriteLineLoadingStep: String?
    @State private var improveFlowLoadingStep: String?
    @State private var slamAnimationText: String? = nil
    @State private var slamAnimationOffset: CGFloat = 0
    @State private var slamAnimationScale: CGFloat = 1.0
    @State private var showProactiveFeedback: Bool = false
    @State private var lastInsertedSuggestion: RapSuggestion? = nil
    @State private var aiErrorMessage: String? = nil
    @State private var aiErrorFixDestination: AppErrorFixDestination = .none
    @State private var showAIErrorToast: Bool = false
    @State private var showPaywall: Bool = false
    @State private var paywallFeature: String = ""
    
    // Phase 4 & 5: A&R Critique, Theme Expansion, Export, Analytics
    @State private var showGenerateLyricsFromFlowSheet: Bool = false
    @State private var showARCritiqueSheet: Bool = false
    @State private var showThemeExpansionSheet: Bool = false
    @State private var showExportSheet: Bool = false
    @State private var themeExpansionSuggestions: [RapSuggestion] = []
    @State private var isGeneratingThemeExpansion: Bool = false
    @State private var selectedArtistForStyleTransfer: String = ""
    
    @Environment(\.colorScheme) private var colorScheme
    
    // Show AI error message
    private func showAIError(
        _ message: String,
        fixDestination: AppErrorFixDestination = .none,
        source: String = "AI Sparkle Button",
        context: String? = nil
    ) {
        ErrorStorageManager.shared.storeError(message, source: source, context: context)

        let resolvedDestination = fixDestination == .none
            ? AppErrorRecovery.destination(forMessage: message)
            : fixDestination

        aiErrorMessage = message
        aiErrorFixDestination = resolvedDestination
        showAIErrorToast = true
        HapticFeedbackManager.shared.error()

        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showAIErrorToast = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                aiErrorMessage = nil
                aiErrorFixDestination = .none
            }
        }
    }

    private func dismissAIErrorToast() {
        withAnimation(.easeOut(duration: 0.25)) {
            showAIErrorToast = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            aiErrorMessage = nil
            aiErrorFixDestination = .none
        }
    }

    private func handleAIErrorFix() {
        let destination = aiErrorFixDestination
        dismissAIErrorToast()
        AppNavigation.navigate(to: destination)
    }

    // Wrapper function for DynamicIslandToolbarView that expects (String) -> Void
    private func showAIErrorWrapper(_ message: String) {
        showAIError(message)
    }
    
    // MARK: - Undo/Redo State
    @State private var undoHistory: [String] = []
    @State private var redoHistory: [String] = []
    @State private var isUndoing: Bool = false
    @State private var isRedoing: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header (title + metadata pills)
            // The coral bloom now lives HERE in the top section and fades out toward
            // the divider, leaving the writing surface below fully opaque.
            VStack(spacing: 0) {
                TextField("Title", text: $item.title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 680)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .scaleEffect(scrollOffset < -20 ? 0.94 : 1.0)
                    .opacity(scrollOffset < -20 ? 0.6 : 1.0)
                    .animation(.easeOut(duration: 0.2), value: scrollOffset)

                // MARK: - Metadata Pills Section
                metadataPillsView
                    .padding(.vertical, 8)
            }
            .background(
                EditorHeaderCoralBackground(bpm: item.bpm)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
            )

            Divider()
                .frame(maxWidth: .infinity) // Extend divider to full width

            GeometryReader { viewport in
                ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                        // Disable automatic scrolling when text editor is focused
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self,
                                            value: geo.frame(in: CoordinateSpace.named("editorScroll")).minY)
                        }
                        .frame(height: 0)
                    VStack(alignment: .leading, spacing: 0) { // FIXED: Decouple spacing
                        // MARK: - Audio + transcript (scroll with content; not persistent)
                        if let audioPath = item.audioPath, !audioPath.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                InlineAudioCardView(
                                    item: item,
                                    onTap: {
                                        shouldAutoTranscribe = false
                                        showAudioDetailSheet = true
                                    },
                                    onTranscribe: {
                                        shouldAutoTranscribe = true
                                        showAudioDetailSheet = true
                                    },
                                    onAddTranscriptToNote: {
                                        guard let transcription = item.transcription, !transcription.isEmpty else { return }
                                        let prefix = item.body.isEmpty ? "" : "\n\n"
                                        item.body += prefix + transcription
                                        item.modifiedDate = Date()
                                    }
                                )
                                .padding(.horizontal, 20)
                                if let transcription = item.transcription, !transcription.isEmpty {
                                    transcriptSurfaceSection(transcription: transcription)
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        }
                        // SEGMENT 19: Unified Padding - Apply padding to ZStack for consistent writing room
                            WritingSurface(
                                text: $item.body,
                                highlights: computedHighlights,
                                isEditorFocused: $isEditorFocused,
                                isRhymeOverlayVisible: isRhymeOverlayVisible,
                                rhymeOverlayHeight: $rhymeOverlayHeight,
                                scrollOffset: scrollOffset,
                                savedScrollPosition: $savedScrollPosition,
                                slamAnimationText: slamAnimationText,
                                slamAnimationOffset: slamAnimationOffset,
                                slamAnimationScale: slamAnimationScale,
                                minHeight: viewport.size.height - 200
                            )
                        
                        // Timestamp bar moved out of the scroll stream — it is now a
                        // centered overlay pinned to the bottom of the editor (see
                        // `.overlay(alignment: .bottom)` below) so it always stays
                        // visible above the toolbar instead of scrolling away.
                    }
                    .frame(maxWidth: 680) // Constrain to max width, center within parent
                .coordinateSpace(name: "editorScroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                    }
                    // SEGMENT 20: Override Keyboard Centering - Prevent system re-centering
                    // Stops the system from trying to re-center the viewport upon focus
                    .scrollDismissesKeyboard(.never) // CRITICAL: Stops system re-centering
                    // SEGMENT 20: Disable automatic keyboard avoidance that causes jump
                    .defaultScrollAnchor(.top) // Anchor to top to prevent bottom jump
                    // SEGMENT 20: Prevent automatic scroll adjustments when keyboard appears
                    .ignoresSafeArea(.keyboard, edges: .all)
                    }
                }
            }
            // Fully opaque writing surface — the coral bloom now lives in the header
            // section above the divider, not on the writing area.
            .background(Momentum.surfaceElevated)
            .overlay(alignment: .bottom) {
                noteTimestampBar
                    .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // SEGMENT 20: Scroll Gravity Locking - Ignore keyboard safe area to prevent displacement
        // While the toolbar follows the keyboard, the text surface should ignore keyboard displacement
        // This prevents the entire view from shifting upward when focus is gained
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .safeAreaInset(edge: .bottom) {
            bottomToolbar
        }
        .onReceive(NotificationCenter.default.publisher(for: .inAppAPIError)) { notification in
            guard let msg = notification.userInfo?[InAppAPIErrorPayload.messageKey] as? String, !msg.isEmpty else { return }
            let destination = AppErrorRecovery.destination(from: notification)
            showAIError(msg, fixDestination: destination, source: "API", context: nil)
        }
        .onChange(of: showModelGControlSurface) { _, isShowing in
            if isShowing {
                Task { await rhymeEngineState.refreshImmediately(text: item.body) }
            }
        }
        .sheet(isPresented: $showModelGControlSurface) {
            ModelGControlSurfaceView(rhymeGroups: rhymeGroups) { params, rhymeGroupsByID in
                showModelGControlSurface = false
                showContextHighlight = true
                Task {
                    await rapSuggestionEngine.generateSuggestions(
                        text: currentText,
                        highlights: computedHighlights,
                        model: modelGControlSurfaceAPIModel,
                        bpm: item.bpm,
                        key: item.key,
                        scale: item.scale,
                        directedParams: params,
                        rhymeGroupsByID: rhymeGroupsByID,
                        audioURL: item.audioPath.flatMap { URL(fileURLWithPath: $0) },
                        transcriptionRhythmMapData: item.transcriptionRhythmMapData,
                        noteKey: aiNoteKey,
                        noteTitle: item.title,
                        persistTo: item
                    )
                    await MainActor.run {
                        showContextHighlight = false
                        if let error = rapSuggestionEngine.error {
                            HapticFeedbackManager.shared.error()
                            showAIErrorWrapper(error)
                        } else {
                            HapticFeedbackManager.shared.success()
                            showRapSuggestions = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showRapSuggestions) {
            RapSuggestionView(
                suggestions: isShowingRecalled ? rapSuggestionEngine.lastBatchSuggestions : rapSuggestionEngine.suggestions,
                isLoading: rapSuggestionEngine.isLoading && !isShowingRecalled,
                loadingStep: isShowingRecalled ? nil : rapSuggestionEngine.loadingStep,
                error: isShowingRecalled ? nil : rapSuggestionEngine.error,
                onSelect: { suggestion in
                    insertRapSuggestion(suggestion, isAIGenerated: true)
                },
                onCopy: { suggestion in
                    copyRapSuggestionWithSlam(suggestion)
                },
                onDismiss: {
                    showRapSuggestions = false
                    isShowingRecalled = false
                },
                contextText: isShowingRecalled
                    ? (rapSuggestionEngine.lastSessionContextText ?? currentText)
                    : currentText,
                onRegenerate: {
                    Task {
                        if rapSuggestionEngine.isParallelModelG,
                           let params = rapSuggestionEngine.lastParallelDirectedParams,
                           let rhymeGroupsByID = rapSuggestionEngine.lastParallelRhymeGroupsByID {
                            await rapSuggestionEngine.generateSuggestionsModelGParallel(
                                text: currentText,
                                highlights: computedHighlights,
                                bpm: item.bpm,
                                key: item.key,
                                scale: item.scale,
                                directedParams: params,
                                rhymeGroupsByID: rhymeGroupsByID,
                                audioURL: item.audioPath.flatMap { URL(fileURLWithPath: $0) },
                                transcriptionRhythmMapData: item.transcriptionRhythmMapData,
                                noteKey: aiNoteKey,
                                noteTitle: item.title,
                                persistTo: item
                            )
                        } else {
                            await rapSuggestionEngine.generateSuggestions(
                                text: currentText,
                                highlights: highlights,
                                model: rapSuggestionEngine.lastStandardGenerationModel,
                                bpm: item.bpm,
                                key: item.key,
                                scale: item.scale,
                                audioURL: item.audioPath.flatMap { URL(fileURLWithPath: $0) },
                                transcriptionRhythmMapData: item.transcriptionRhythmMapData,
                                noteKey: aiNoteKey,
                                noteTitle: item.title,
                                persistTo: item
                            )
                        }
                    }
                },
                currentSignalMode: isShowingRecalled ? nil : rapSuggestionEngine.currentSignalMode,
                currentSignalProfile: isShowingRecalled ? nil : rapSuggestionEngine.currentSignalProfile,
                silenceCommentary: rapSuggestionEngine.silenceCommentary,
                leftSuggestions: rapSuggestionEngine.isParallelModelG ? rapSuggestionEngine.suggestionsV1 : nil,
                rightSuggestions: rapSuggestionEngine.isParallelModelG ? rapSuggestionEngine.suggestionsV2 : nil,
                leftTitle: rapSuggestionEngine.isParallelModelG ? "Model G v1" : nil,
                rightTitle: rapSuggestionEngine.isParallelModelG ? "Model G v2" : nil,
                noteKey: aiNoteKey,
                generationId: rapSuggestionEngine.lastSessionGenerationId,
                humanCriticFeedback: $rapSuggestionEngine.humanCriticFeedback,
                humanCriticLoading: $rapSuggestionEngine.humanCriticLoading,
                humanCriticError: $rapSuggestionEngine.humanCriticError,
                onRetryHumanCritic: retryHumanCriticForCurrentNote
            )
        }
        .sheet(isPresented: $showRhymeSuggestions) {
            RhymeSuggestionView(
                rhymes: lastWordRhymes,
                targetWord: targetWordForRhymes,
                onSelect: { word in
                    insertRhymeWord(word)
                },
                onDismiss: {
                    showRhymeSuggestions = false
                }
            )
        }
        .sheet(isPresented: $showImproveFlow) {
            RapSuggestionView(
                suggestions: improveFlowSuggestions,
                isLoading: rapSuggestionEngine.isLoading,
                loadingStep: rapSuggestionEngine.loadingStep,
                error: rapSuggestionEngine.error,
                onSelect: { suggestion in
                    insertRapSuggestion(suggestion, isAIGenerated: true)
                },
                onCopy: { suggestion in
                    copyRapSuggestionWithSlam(suggestion)
                },
                onDismiss: {
                    showImproveFlow = false
                },
                contextText: item.body, // Pass context for feedback tracking
                onRegenerate: {
                    // Regenerate flow improvements (Phase 1)
                    Task {
                        await improveFlow()
                    }
                },
                currentSignalMode: rapSuggestionEngine.currentSignalMode,
                currentSignalProfile: rapSuggestionEngine.currentSignalProfile,
                humanCriticFeedback: .constant(nil),
                humanCriticLoading: .constant(false),
                humanCriticError: .constant(nil),
                onRetryHumanCritic: {}
            )
        }
        .toolbar {
            editorToolbarItems
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAudioRecorder) {
            AudioRecorderView(item: item)
        }
        .sheet(isPresented: $showAudioDetailSheet) {
            AudioDetailSheet(item: item, autoTranscribe: shouldAutoTranscribe)
        }
        .onChange(of: showAudioDetailSheet) { oldValue, newValue in
            // Reset auto-transcribe flag when sheet is dismissed
            if !newValue {
                shouldAutoTranscribe = false
            }
        }
        .fileImporter(
            isPresented: $showAudioImporter,
            allowedContentTypes: [.audio, .mpeg4Audio],
            allowsMultipleSelection: false
        ) { result in
            handleAudioImport(result: result)
        }
        .sheet(isPresented: $showImportNotesInstructions) {
            ImportNotesInstructionsView(
                modelContext: modelContext,
                onNoteCreated: { newItem in
                  showImportNotesInstructions = false
                  // When importing from NoteEditorView, append to current note instead of creating new one
                  let importedText = newItem.body
                  if !importedText.isEmpty {
                      if !item.body.isEmpty {
                          item.body += "\n\n"
                      }
                      item.body += importedText
                      item.modifiedDate = Date()
                  }
                }
            )
            .presentationDetents([PresentationDetent.large])
            .presentationDragIndicator(Visibility.visible)
        }
        .onAppear {
            if let session = NoteSuggestionSessionStore.load(from: item) {
                NoteSuggestionSessionStore.apply(session, to: rapSuggestionEngine)
            }
            // Ensure text has 4 trailing newlines for writing space
            ensureTrailingNewlines()
            // Initialize undo history with current state
            if undoHistory.isEmpty {
                undoHistory.append(item.body)
            }
            // Immediate analysis on appear (no debounce needed - user isn't typing yet)
            rhymeEngineState.updateIfNeeded(text: item.body)
            
            // Check if we should show toolbar overview splash
            if splashManager.hasCompletedOnboarding && splashManager.shouldShowSplash(.toolbarOverview) {
                // Small delay to ensure toolbar is rendered
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isToolbarExpanded = true // Expand toolbar for overview
                    showToolbarOverview = true
                }
            }
        }
        .overlay {
            toolbarSplashesOverlay
        }
        .onChange(of: item.body) { oldValue, newValue in
            handleBodyChange(old: oldValue, new: newValue)
        }
        .onChange(of: item.title) { oldValue, newValue in
            // Track modification date when title changes
            if oldValue != newValue {
                item.modifiedDate = Date()
                // Explicitly save the context to ensure changes persist
                do {
                    try item.modelContext?.save()
                } catch {
                    print("⚠️ Failed to save title change: \(error.localizedDescription)")
                }
            }
        }
        // MARK: - Metadata Popovers (Segment 2)
        .sheet(isPresented: $showBPMPopover) {
            BPMPopoverView(bpm: $item.bpm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .popover(isPresented: $showKeyPopover) {
            KeyPopoverView(key: $item.key)
        }
        .popover(isPresented: $showScalePopover) {
            ScalePopoverView(key: $item.key, scale: $item.scale)
        }
        .sheet(isPresented: $showURLPopover) {
            URLAttachmentPopoverView(url: $item.urlAttachment)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .popover(isPresented: $showFolderPopover) {
            FolderPopoverView(folder: $item.folder)
        }
        // Phase 4: Style Transfer & Theme Expansion Sheets
        .sheet(isPresented: $showProactiveFeedback) {
            if let suggestion = lastInsertedSuggestion {
                ProactiveFeedbackView(
                    suggestion: suggestion,
                    context: currentText,
                    onDismiss: {
                        showProactiveFeedback = false
                        lastInsertedSuggestion = nil
                    }
                )
            }
        }
        .sheet(isPresented: $showGenerateLyricsFromFlowSheet) {
            GenerateLyricsFromFlowSheet(
                item: item,
                onInsertLyrics: { lyrics in
                    let trimmed = lyrics.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        let newBody = item.body.isEmpty ? trimmed : (item.body + "\n\n" + trimmed)
                        item.body = newBody
                        item.modifiedDate = Date()
                    }
                },
                onDismiss: {
                    showGenerateLyricsFromFlowSheet = false
                },
                onOpenRecorder: {
                    showGenerateLyricsFromFlowSheet = false
                    showAudioRecorder = true
                },
                onOpenAudioImporter: {
                    showGenerateLyricsFromFlowSheet = false
                    showAudioImporter = true
                }
            )
        }
        .sheet(isPresented: $showThemeExpansionSheet) {
            ThemeExpansionSheet(
                currentText: currentText,
                item: item,
                onDismiss: {
                    showThemeExpansionSheet = false
                }
            )
        }
        // Phase 5: Export Sheet
        .sheet(isPresented: $showExportSheet) {
            ExportSheet(
                item: item,
                onDismiss: {
                    showExportSheet = false
                }
            )
        }
    }
    
    // MARK: - Writing Surface (isolated child view)
    /// The text-entry surface — `TextEditor` + rhyme-highlight overlay + slam animation.
    /// Extracted into its own `View` so that a keystroke (or a debounced rhyme-engine
    /// update) re-renders ONLY this subtree, not the entire NoteEditorView chrome
    /// (toolbar, sheets, metadata bar). Inputs are deliberately narrow and value-typed,
    /// so SwiftUI can skip re-rendering this subtree when unrelated parent state changes.
    /// Behavior, modifier order, and the SEGMENT-20 anti-jump tricks are preserved exactly.
    private struct WritingSurface: View {
        @Binding var text: String
        let highlights: [Highlight]
        @FocusState.Binding var isEditorFocused: Bool
        let isRhymeOverlayVisible: Bool
        @Binding var rhymeOverlayHeight: CGFloat
        let scrollOffset: CGFloat
        @Binding var savedScrollPosition: CGFloat
        let slamAnimationText: String?
        let slamAnimationOffset: CGFloat
        let slamAnimationScale: CGFloat
        let minHeight: CGFloat

        var body: some View {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .focused($isEditorFocused)
                    .font(.body)
                    .frame(maxWidth: 680)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    // SEGMENT 20: Static buffer reserves physical space for the Dynamic Island
                    .padding(.bottom, 150)
                    .scrollContentBackground(.hidden)
                    .textEditorStyle(.plain)
                    .foregroundStyle(isRhymeOverlayVisible ? .clear : .primary)
                    // SEGMENT 20: parent ScrollView handles scrolling (prevents "jumps")
                    .scrollDisabled(true)
                    // SEGMENT 20: vertical locking — forces expansion, prevents viewport shift
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(0)
                    .allowsHitTesting(!isRhymeOverlayVisible)
                    .scrollDismissesKeyboard(.never)
                    // SEGMENT 21: auto-focus empty notes so the keyboard shows immediately
                    .onAppear {
                        if text.isEmpty {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isEditorFocused = true
                            }
                        }
                    }
                    // SEGMENT 20: save scroll position the moment focus is gained
                    .onChange(of: isEditorFocused) { oldValue, newValue in
                        if newValue && !oldValue {
                            savedScrollPosition = scrollOffset
                        }
                    }
                    // SEGMENT 20: prevent automatic keyboard avoidance that causes jump
                    .ignoresSafeArea(.keyboard, edges: .all)

                // Rhyme-highlight overlay — kept in the hierarchy (opacity toggles visibility
                // instead of conditional rendering) so the UIKit view + cache aren't recreated.
                GeometryReader { geo in
                    RhymeHighlightTextView(
                        text: text,
                        highlights: highlights,
                        isVisible: isRhymeOverlayVisible,
                        showFullText: true,
                        horizontalPadding: 20,
                        isEditable: isRhymeOverlayVisible,
                        onTextChange: { newText in
                            text = newText
                        },
                        dynamicHeight: $rhymeOverlayHeight,
                        availableWidth: geo.size.width
                    )
                    .frame(height: rhymeOverlayHeight)
                    .animation(nil, value: isRhymeOverlayVisible)
                }
                .frame(maxWidth: 680, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .opacity(isRhymeOverlayVisible ? 1.0 : 0.0)
                .allowsHitTesting(isRhymeOverlayVisible)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(0)
                .onChange(of: isRhymeOverlayVisible) { _, _ in
                    // Intentionally empty: no forced layout, to prevent scroll jump on eye toggle.
                }

                // Slam animation overlay (iMessage-style)
                if let slamText = slamAnimationText {
                    Text(slamText)
                        .font(.body)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .frame(maxWidth: 680, alignment: .leading)
                        .offset(y: slamAnimationOffset)
                        .scaleEffect(slamAnimationScale)
                        .opacity(slamAnimationScale < 1.0 ? 0.6 : 1.0)
                        .allowsHitTesting(false)
                }
            }
            .layoutPriority(0)
            // SEGMENT 20: buffer matches TextEditor's bottom padding for synchronized height
            .padding(.bottom, 150)
            // Fill the viewport so the whole text area is tappable for writing
            .frame(minHeight: minHeight, alignment: .topLeading)
        }
    }

    // MARK: - Bottom Dynamic Island Toolbar (Page 3)
    private var bottomToolbar: some View {
        DynamicIslandToolbarView(
            isExpanded: $isToolbarExpanded,
            isRhymeOverlayVisible: $isRhymeOverlayVisible,
            showDiagnostics: $showRhymeDiagnostics,
            rhymeGroups: rhymeGroups,
            currentText: item.body,
            highlights: computedHighlights,
            isEditorFocused: $isEditorFocused,
            keyboardHeight: $keyboardObserver.height,
            showAudioRecorder: $showAudioRecorder,
            showRapSuggestions: $showRapSuggestions,
            showModelGControlSurface: $showModelGControlSurface,
            rapSuggestionEngine: rapSuggestionEngine,
            isShowingRecalled: $isShowingRecalled,
            showContextHighlight: $showContextHighlight,
            showAudioImporter: $showAudioImporter,
            showImportNotesInstructions: $showImportNotesInstructions,
            onRewriteLine: handleRewriteLine,
            onSuggestRhymes: handleSuggestRhymes,
            onImproveFlow: handleImproveFlow,
            onUndo: handleUndo,
            onRedo: handleRedo,
            onInsertRapSuggestion: { suggestion in insertRapSuggestion(suggestion, isAIGenerated: true) },
            canUndo: !undoHistory.isEmpty,
            canRedo: !redoHistory.isEmpty,
            isRewritingLine: $isRewritingLine,
            isImprovingFlow: $isImprovingFlow,
            rewriteLineLoadingStep: $rewriteLineLoadingStep,
            improveFlowLoadingStep: $improveFlowLoadingStep,
            showPaywall: $showPaywall,
            paywallFeature: $paywallFeature,
            showAIErrorToast: $showAIErrorToast,
            aiErrorMessage: $aiErrorMessage,
            aiErrorFixDestination: $aiErrorFixDestination,
            onAIErrorFix: handleAIErrorFix,
            onDismissAIError: dismissAIErrorToast,
            showGenerateLyricsFromFlowSheet: $showGenerateLyricsFromFlowSheet,
            showARCritiqueSheet: $showARCritiqueSheet,
            showThemeExpansionSheet: $showThemeExpansionSheet,
            showExportSheet: $showExportSheet,
            insertRapSuggestion: insertRapSuggestion,
            extractThemes: extractThemes,
            showAIError: showAIErrorWrapper,
            onRetryHumanCritic: retryHumanCriticForCurrentNote,
            item: item
        )
        .frame(maxWidth: 680)
    }

    // MARK: - Navigation Bar Toolbar Items (undo / redo / add menu)
    @ToolbarContentBuilder
    private var editorToolbarItems: some ToolbarContent {
        // Page 2 — the undo/redo/add pill drops its iOS 26 liquid-glass backdrop and sits
        // flat on the coral (the weak header coral made that platter read muddy gray).
        // The system back button is left intact so its swipe-back gesture keeps working.
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                HapticFeedbackManager.shared.lightTap()
                handleUndo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .disabled(undoHistory.isEmpty)
            .accessibilityLabel("Undo")
            .accessibilityHint("Double tap to undo last change")

            Button {
                HapticFeedbackManager.shared.lightTap()
                handleRedo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
            }
            .disabled(redoHistory.isEmpty)
            .accessibilityLabel("Redo")
            .accessibilityHint("Double tap to redo last undone change")

            Menu {
                Button {
                    prepareHapticForNewNote()
                    createAndNavigateToNewNote()
                } label: {
                    Label("New Note", systemImage: "square.and.pencil")
                }

                Button {
                    // TODO: Import from Apple Notes
                } label: {
                    Label("Import from Notes", systemImage: "note.text")
                }

                Button {
                    openAudioRecorder()
                } label: {
                    Label("Record Audio", systemImage: "waveform")
                }

                // Phase 5: Export functionality (Basic+)
                if FeatureGate.canAccess(.exportPDF) || FeatureGate.canAccess(.exportWord) {
                    Divider()

                    Button {
                        HapticFeedbackManager.shared.lightTap()
                        // Check feature access before showing sheet
                        if !FeatureGate.checkAccess(.exportPDF, showPaywall: { featureName in
                            paywallFeature = featureName
                            showPaywall = true
                        }) {
                            return
                        }
                        showExportSheet = true
                    } label: {
                        Label("Export Note", systemImage: "square.and.arrow.up")
                    }
                }
            } label: {
                Image(systemName: "plus")
            }
        }
        .sharedBackgroundVisibility(hideToolbarGlass ? .hidden : .automatic)
    }

    // MARK: - Toolbar Onboarding Splash Overlays
    @ViewBuilder
    private var toolbarSplashesOverlay: some View {
        // Toolbar Overview Splash
        if showToolbarOverview {
            ToolbarOverviewSplashView(
                toolbarFrame: toolbarFrame,
                onDismiss: {
                    showToolbarOverview = false
                },
                onNext: {
                    showToolbarOverview = false
                    showNextToolbarButtonSplash()
                }
            )
            .transition(.opacity)
            .zIndex(1000)
        }

        // Toolbar Button Splash
        if showToolbarButtonSplash, let splashID = currentButtonSplashID {
            let buttonInfo = getButtonInfo(for: splashID)
            let buttonFrame = buttonFrames[splashID] ?? (toolbarFrame != nil ? calculateApproximateButtonFrame(for: splashID, toolbarFrame: toolbarFrame!) : nil)
            ToolbarButtonSplashView(
                id: splashID,
                buttonFrame: buttonFrame,
                title: buttonInfo.title,
                description: buttonInfo.description,
                icon: buttonInfo.icon,
                onDismiss: {
                    showToolbarButtonSplash = false
                    currentButtonSplashID = nil
                },
                onNext: {
                    showToolbarButtonSplash = false
                    currentButtonSplashID = nil
                    showNextToolbarButtonSplash()
                }
            )
            .transition(.opacity)
            .zIndex(1000)
        }
    }

    // MARK: - Body Change Handling
    /// Per-keystroke side effects for the note body: modified-date, AI-range pruning,
    /// writing-activity tracking, undo history, and debounced rhyme analysis. Extracted
    /// from the `.onChange(of: item.body)` closure to keep the view body type-checkable.
    private func handleBodyChange(old oldValue: String, new newValue: String) {
        // Track modification date when body changes
        if oldValue != newValue {
            item.modifiedDate = Date()

            // Prune AI text ranges the edit pushed out of bounds. This used to run
            // inside computedHighlights and mutate item.aiTextRanges mid-render
            // ("Modifying state during view update"); doing it here is both safe and
            // more correct — ranges go stale exactly when the body changes.
            pruneInvalidAITextRanges()

            // Track writing activity
            let oldWords = oldValue.components(separatedBy: CharacterSet.whitespacesAndNewlines)
                .filter { !$0.isEmpty }.count
            let newWords = newValue.components(separatedBy: CharacterSet.whitespacesAndNewlines)
                .filter { !$0.isEmpty }.count
            let wordsAdded = newWords - oldWords
            if wordsAdded > 0 {
                UserBehaviorTracker.shared.trackWritingActivity(wordsWritten: wordsAdded)

                // Check achievements periodically (every 100 words)
                // Defer to background to avoid blocking UI
                if newWords % 100 == 0 {
                    Task.detached(priority: .utility) {
                        await MainActor.run {
                            // Get all items to check achievements accurately
                            let descriptor = FetchDescriptor<Item>()
                            if let allItems = try? modelContext.fetch(descriptor) {
                                UserBehaviorTracker.shared.checkAchievementsWithItems(items: allItems)
                            }
                        }
                    }
                }
            }
        }

        // Track undo/redo history (skip if we're currently undoing/redoing)
        if !isUndoing && !isRedoing && oldValue != newValue {
            // Add to undo history
            undoHistory.append(oldValue)
            // Clear redo history when new change is made
            redoHistory.removeAll()
            // Limit undo history to 50 entries
            if undoHistory.count > 50 {
                undoHistory.removeFirst()
            }
        }

        // Debounced analysis - waits 400ms after typing stops before analyzing
        // This reduces computation during active typing and improves performance
        rhymeEngineState.updateIfNeeded(text: newValue)
    }

    // Phase 4: Detect themes from lyrics for theme expansion auto-selection
    private func extractThemes(from text: String) -> [String] {
        ThemeIdentificationService.detectedThemeNames(in: text)
    }
    
    // MARK: - Note Timestamp Metadata Bar
    private var noteTimestampBar: some View {
        VStack(spacing: 6) {
            timestampLine(label: "Created", date: item.timestamp)
            if let modifiedDate = item.modifiedDate {
                timestampLine(label: "Modified", date: modifiedDate)
            }
        }
        .frame(maxWidth: .infinity) // Center horizontally
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func timestampLine(label: String, date: Date) -> some View {
        HStack(spacing: 5) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(formatTimestamp(date))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Timestamp Formatting Helper
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M - d - yyyy h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }

    /// Split transcription into phrases/lines by sentence boundaries and commas, similar to rap bars.
    private func splitTranscriptionIntoLines(_ text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        // Split by sentence boundaries (. ? !) and commas
        var normalized = trimmed
            .replacingOccurrences(of: ". ", with: ".\n")
            .replacingOccurrences(of: "? ", with: "?\n")
            .replacingOccurrences(of: "! ", with: "!\n")
            .replacingOccurrences(of: ", ", with: ",\n")
        
        // Ensure trailing punctuation doesn't create empty lines
        if normalized.hasSuffix(".") || normalized.hasSuffix("?") || normalized.hasSuffix("!") || normalized.hasSuffix(",") {
            // Keep as is
        } else if !normalized.isEmpty {
            normalized = normalized + "\n"
        }
        
        let phrases = normalized
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Split very long phrases at word boundaries (max ~120 chars per line)
        let maxLineLength = 120
        var result: [String] = []
        for phrase in phrases {
            if phrase.count > maxLineLength {
                var remaining = phrase
                while remaining.count > maxLineLength {
                    let chunk = String(remaining.prefix(maxLineLength))
                    if let lastSpace = chunk.lastIndex(of: " ") {
                        result.append(String(chunk[..<lastSpace]).trimmingCharacters(in: .whitespaces))
                        remaining = String(remaining[chunk.index(after: lastSpace)...]).trimmingCharacters(in: .whitespaces)
                    } else {
                        result.append(chunk)
                        remaining = String(remaining[chunk.endIndex...]).trimmingCharacters(in: .whitespaces)
                    }
                }
                if !remaining.isEmpty {
                    result.append(remaining)
                }
            } else {
                result.append(phrase)
            }
        }
        
        return result
    }
    
    /// Transcript block on the text surface: heading, "Open transcription" button (toggles raw text visibility), and inline text displayed line-by-line (hidden until button pressed).
    private func transcriptSurfaceSection(transcription: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Transcript")
                    .font(.headline)
                Spacer()
                Button {
                    showRawTranscriptOnSurface.toggle()
                } label: {
                    Text(showRawTranscriptOnSurface ? "Close transcription" : "Open transcription")
                        .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.bordered)
                .tint(.yellow)
            }
            .padding(.horizontal, 20)
            if showRawTranscriptOnSurface {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(splitTranscriptionIntoLines(transcription).enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Metadata Pills View
    private var metadataPillsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // BPM Pill Menu
                bpmPillMenu
                
                // Key Pill Menu
                keyPillMenu
                
                // Scale Pill Menu
                scalePillMenu
                
                // URL Pill Menu
                urlPillMenu
                
                // Folder Pill Menu
                folderPillMenu
            }
            .padding(.leading, 16) // Leading padding for first pill
            .padding(.trailing, 16) // Trailing padding for last pill
        }
        .frame(maxWidth: .infinity) // Extend to full width
    }
    
    // MARK: - BPM Pill Menu
    private var bpmPillMenu: some View {
        Menu {
            // Quick Select BPM Values
            ForEach([60, 90, 120, 140, 160, 180, 200], id: \.self) { bpmValue in
                Button {
                    item.bpm = bpmValue
                } label: {
                    HStack {
                        Text("\(bpmValue) BPM")
                        Spacer()
                        if item.bpm == bpmValue {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
            }
            
            Divider()
            
            // Custom BPM (opens popover)
            Button {
                showBPMPopover = true
            } label: {
                Label("Custom BPM", systemImage: "slider.horizontal.3")
            }
            
            if item.bpm != nil {
                Divider()
                
                Button(role: .destructive) {
                    item.bpm = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "metronome",
                label: item.bpm != nil ? "\(item.bpm!) BPM" : "BPM",
                isSet: item.bpm != nil
            )
        }
    }
    
    // MARK: - Key Pill Menu
    private var keyPillMenu: some View {
        Menu {
            // All Musical Keys
            ForEach(["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"], id: \.self) { keyValue in
                Button {
                    item.key = keyValue
                } label: {
                    HStack {
                        Text(keyValue)
                        Spacer()
                        if item.key == keyValue {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
            }
            
            if item.key != nil {
                Divider()
                
                Button(role: .destructive) {
                    item.key = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "music.note",
                label: item.key ?? "KEY",
                isSet: item.key != nil
            )
        }
    }
    
    // MARK: - Scale Pill Menu
    private var scalePillMenu: some View {
        Menu {
            // All Scales
            ForEach([
                "Chromatic",
                "Major",
                "Natural Minor",
                "Harmonic Minor",
                "Melodic Minor",
                "Ionian (Major)",
                "Dorian",
                "Phrygian",
                "Lydian",
                "Mixolydian",
                "Aeolian (Natural Minor)",
                "Locrian"
            ], id: \.self) { scaleValue in
                Button {
                    item.scale = scaleValue
                } label: {
                    HStack {
                        Text(scaleValue)
                        Spacer()
                        if item.scale == scaleValue {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
            }
            
            if item.scale != nil {
                Divider()
                
                Button(role: .destructive) {
                    item.scale = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "slider.horizontal.3",
                label: item.scale ?? "SCALE",
                isSet: item.scale != nil
            )
        }
    }
    
    // MARK: - URL Pill Menu
    private var urlPillMenu: some View {
        Menu {
            Button {
                showURLPopover = true
            } label: {
                Label("Set URL", systemImage: "link")
            }
            
            if item.urlAttachment != nil {
                Divider()
                
                if let url = item.urlAttachment, let urlObj = URL(string: url) {
                    ShareLink(item: urlObj) {
                        Label("Share URL", systemImage: "square.and.arrow.up")
                    }
                }
                
                Button(role: .destructive) {
                    item.urlAttachment = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "link",
                label: item.urlAttachment != nil ? "URL" : "URL",
                isSet: item.urlAttachment != nil
            )
        }
    }
    
    // MARK: - Folder Pill Menu
    private var folderPillMenu: some View {
        Menu {
            Button {
                showFolderPopover = true
            } label: {
                Label("Set Folder", systemImage: "folder")
            }
            
            if item.folder != nil {
                Divider()
                
                Button(role: .destructive) {
                    item.folder = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "folder",
                label: item.folder ?? "FOLDER",
                isSet: item.folder != nil
            )
        }
    }
    
    // MARK: - Metadata Pill Label Component
    @ViewBuilder
    private func metadataPillLabel(icon: String, label: String, isSet: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(label)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(
            SoftBlueGlassStyle
                .tint(for: colorScheme)
                .opacity(isSet ? 1.0 : 0.88)
        )
        .padding(.horizontal, 13)
        .padding(.vertical, 7)
        // Clean outline on the coral — restores the pill border without the muddy fill.
        // The old SoftBlueGlassBackground used .ultraThinMaterial (read gray over coral)
        // plus a gyro glint overlay that ate the horizontal scroll drag; a plain tinted
        // strokeBorder is non-interactive, so the row keeps scrolling. Keep a `.background`
        // here — fully dropping it tips NoteEditorView's body over the Swift type-checker
        // limit. A set value still shows inline (e.g. "120 BPM").
        .background(
            Capsule(style: .continuous)
                .strokeBorder(
                    SoftBlueGlassStyle.tint(for: colorScheme).opacity(isSet ? 0.55 : 0.35),
                    lineWidth: isSet ? 1.0 : 0.8
                )
        )
    }

    private func prepareHapticForNewNote() {
        HapticFeedbackManager.shared.lightTap()
    }

    private func createAndNavigateToNewNote() {
        let descriptor = FetchDescriptor<Item>()
        let count = (try? modelContext.fetch(descriptor).count) ?? 0
        let nextIndex = count + 1

        let newItem = Item(
            timestamp: Date(),
            title: "Note \(nextIndex)",
            body: ""
        )
        modelContext.insert(newItem)

        dismiss()
    }
    
    // MARK: - Voice Memos Integration / Audio Recording
    private func openAudioRecorder() {
        lightHaptic()
        // Note: Audio recording will be handled in NoteEditorView via binding
    }
    
    // MARK: - File Import Handlers
    private func handleAudioImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Copy file to app container
            let fileManager = FileManager.default
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            
            // Remove existing file if present
            try? fileManager.removeItem(at: destinationURL)
            
            do {
                try fileManager.copyItem(at: url, to: destinationURL)
                
                // Store audio path
                item.audioPath = destinationURL.path
                
                // Process audio: get duration, transcribe, generate summary
                Task {
                    await processImportedAudio(url: destinationURL)
                }
            } catch {
                print("Failed to copy audio file: \(error)")
            }
            
        case .failure(let error):
            print("File import failed: \(error)")
        }
    }
    
    @MainActor
    private func processImportedAudio(url: URL) async {
        // Get audio duration
        do {
            let duration = try await WaveformAnalyzer.shared.getDuration(url: url)
            item.audioDuration = duration
        } catch {
            print("Failed to get audio duration: \(error)")
        }
        
        // Analyze audio for BPM, key, and scale (await to ensure it completes and auto-fills)
        Task {
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
                }
            } catch {
                print("⚠️ Audio analysis failed: \(error.localizedDescription)")
                // Don't fail the whole process if analysis fails - user can analyze manually later
            }
        }
        
        // Transcribe audio (on-device)
        do {
            let result = try await transcriptionService.transcribe(audioURL: url)
            item.transcription = result.fullText
            item.transcriptionSegments = result.segments
            
            // Show completion notification with all detected metadata
            let hasTimestamps = !result.segments.isEmpty
            NotificationManager.shared.showAudioProcessingCompleteNotification(
                bpm: item.bpm,
                key: item.key,
                scale: item.scale,
                transcriptionComplete: true,
                timestampsComplete: hasTimestamps
            )
            
            // Generate summary (cloud API)
            Task {
                do {
                    let summary = try await AudioSummaryService.shared.generateSummary(from: result.fullText)
                    await MainActor.run {
                        item.audioSummary = summary
                    }
                } catch {
                    // Summary generation failed (e.g., no API key) - that's okay
                    print("Summary generation skipped: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Transcription failed: \(error.localizedDescription)")
            // Show error to user if needed
            
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
    
    // MARK: - Rap Suggestions
    private func insertRapSuggestion(_ suggestion: RapSuggestion, isAIGenerated: Bool = false) {
        // PR 7: Taste Memory - Record accepted suggestion
        if isAIGenerated {
            TasteMemory.shared.recordAccepted(
                suggestion: suggestion,
                signalMode: rapSuggestionEngine.currentSignalMode,
                signalProfile: rapSuggestionEngine.currentSignalProfile,
                registers: nil,
                axes: nil,
                axisProfile: nil,
                alignmentScore: nil
            )
            AIGenerationLedger.markInserted(
                generationId: rapSuggestionEngine.lastSessionGenerationId ?? UUID(),
                suggestionId: suggestion.id
            )
        }
        // Set up slam animation
        slamAnimationText = suggestion.text
        slamAnimationOffset = -200 // Start above
        slamAnimationScale = 0.8
        
        let originalLength = item.body.count
        let wasEmpty = item.body.isEmpty
        let prefix = wasEmpty ? "" : "\n"
        
        // Animate slam effect
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            slamAnimationOffset = 0
            slamAnimationScale = 1.0
        }
        
        // Insert suggestion at the end of the body, with a newline if body is not empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if wasEmpty {
                self.item.body = suggestion.text
            } else {
                self.item.body += prefix + suggestion.text
            }
            
            // Track AI-generated text range
            if isAIGenerated {
                let startIndex = originalLength + (wasEmpty ? 0 : prefix.count)
                let endIndex = self.item.body.count
                let rangeString = "\(startIndex):\(endIndex)"
                self.item.aiTextRanges.append(rangeString)
                
                // Track insertion for implicit feedback
                SuggestionInteractionTracker.shared.trackSuggestionInsertion(
                    suggestionId: suggestion.id,
                    suggestionText: suggestion.text,
                    context: self.currentText
                )
            }
            
            // Update modification date
            self.item.modifiedDate = Date()
            
            // Re-enable focus and ensure cursor is at the end
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isEditorFocused = true
            }
        }
        
        // Clear animation after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                self.slamAnimationText = nil
                self.slamAnimationOffset = 0
                self.slamAnimationScale = 1.0
            }
        }
        
        // Show proactive feedback prompt after a delay (if AI-generated)
        if isAIGenerated {
            lastInsertedSuggestion = suggestion
            // Show feedback prompt after 3 seconds to give user time to see/edit the suggestion
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // Only show if user hasn't dismissed it and suggestion is still in text
                if self.item.body.contains(suggestion.text) {
                    self.showProactiveFeedback = true
                }
            }
        }
    }
    
    private func copyRapSuggestionWithSlam(_ suggestion: RapSuggestion) {
        // Set up slam animation
        slamAnimationText = suggestion.text
        slamAnimationOffset = -200 // Start above
        slamAnimationScale = 0.8
        
        // Animate slam effect
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            slamAnimationOffset = 0
            slamAnimationScale = 1.0
        }
        
        // Insert the text after animation starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            insertRapSuggestion(suggestion, isAIGenerated: true)
        }
        
        // Clear animation after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                slamAnimationText = nil
                slamAnimationOffset = 0
                slamAnimationScale = 1.0
            }
        }
    }
    
    // MARK: - New Feature Handlers
    
    private func handleSuggestRhymes() {
        // Check usage limits (Phase 2: Monetization)
        if !UsageTracker.shared.canUseSuggestRhymes() {
            paywallFeature = "Suggest Rhymes"
            showPaywall = true
            return
        }
        
        // Track usage
        UsageTracker.shared.trackSuggestRhymes()
        UserBehaviorTracker.shared.trackFeatureUsage(feature: .suggestRhymes)
        
        lightHaptic()
        isEditorFocused = false
        
        // Extract last word from text
        let lines = item.body.split(separator: "\n", omittingEmptySubsequences: false)
        guard let lastLine = lines.last, !lastLine.isEmpty else {
            return
        }
        
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = String(lastLine)
        
        var lastWord: String?
        tokenizer.enumerateTokens(in: String(lastLine).startIndex..<String(lastLine).endIndex) { range, _ in
            lastWord = String(lastLine[range]).lowercased()
            return true
        }
        
        guard let word = lastWord else { return }
        
        // Find rhymes (this is instant, no loading needed)
        let rhymes = RhymeFinder.findRhymes(for: word, limit: 8)
        targetWordForRhymes = word
        lastWordRhymes = rhymes
        showRhymeSuggestions = true
    }
    
    private func insertRhymeWord(_ word: String) {
        // Replace the last word in the last line with the selected rhyme
        let lines = item.body.split(separator: "\n", omittingEmptySubsequences: false)
        guard let lastLineSubstring = lines.last, !lastLineSubstring.isEmpty else { return }
        
        let lastLine = String(lastLineSubstring)
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = lastLine
        
        var wordRanges: [(String, Range<String.Index>)] = []
        tokenizer.enumerateTokens(in: lastLine.startIndex..<lastLine.endIndex) { range, _ in
            wordRanges.append((String(lastLine[range]), range))
            return true
        }
        
        guard let lastWordRange = wordRanges.last else { return }
        
        // Replace the last word
        var newLastLine = lastLine
        newLastLine.replaceSubrange(lastWordRange.1, with: word)
        
        // Reconstruct text
        var newLines = Array(lines.dropLast())
        newLines.append(Substring(newLastLine))
        item.body = newLines.joined(separator: "\n")
        item.modifiedDate = Date()
        
        showRhymeSuggestions = false
    }
    
    private func handleImproveFlow() {
        // Check feature access (Phase 1: Feature Gating)
        if !FeatureGate.checkAccess(.improveFlow, showPaywall: { featureName in
            paywallFeature = featureName
            showPaywall = true
        }) {
            return
        }
        
        // Check usage limits (Phase 2: Monetization)
        if !UsageTracker.shared.canUseImproveFlow() {
            paywallFeature = "Improve Flow"
            showPaywall = true
            return
        }
        
        // Track usage
        UsageTracker.shared.trackImproveFlow()
        
        lightHaptic()
        isEditorFocused = false
        showContextHighlight = true
        
        Task {
            await MainActor.run {
                isImprovingFlow = true
                improveFlowLoadingStep = "Analyzing rhyme scheme..."
            }
            
            let metrics = RapAnalysisEngine().extractMetrics(text: item.body, highlights: computedHighlights)
            
            // Get rhyme scheme
            guard let rhymeScheme = metrics.rhymeScheme else {
                await MainActor.run {
                    isImprovingFlow = false
                    showContextHighlight = false
                }
                return
            }
            
            // Generate suggestions focused on maintaining rhyme scheme
            do {
                await MainActor.run {
                    improveFlowLoadingStep = "Understanding themes..."
                }
                
                let narrative = try await RapSuggestionAPI.shared.analyzeNarrative(
                    text: item.body,
                    lastNLines: metrics.lastNLines,
                    model: .modelG
                )
                
                await MainActor.run {
                    improveFlowLoadingStep = "Generating suggestions..."
                }
                
                // CSV search is deprecated - use constraint-driven generation instead
                let candidates: [RapLine] = []
                
                let filtered = ConstraintFilter(phonemeStoreProvider: { FJCMUDICTStore.shared.phonemesByWord }).filterCandidates(
                    candidates: candidates,
                    metrics: metrics
                )
                
                // Generate suggestions with rhyme scheme focus
                let suggestions = try await RapSuggestionAPI.shared.generateSuggestionsForFlow(
                    candidates: filtered.map { $0.line },
                    metrics: metrics,
                    narrative: narrative,
                    rhymeScheme: rhymeScheme,
                    model: .modelG
                )
                
                await MainActor.run {
                    improveFlowSuggestions = suggestions
                    isImprovingFlow = false
                    improveFlowLoadingStep = nil
                    showContextHighlight = false
                    showImproveFlow = true
                }
            } catch {
                await MainActor.run {
                    isImprovingFlow = false
                    improveFlowLoadingStep = nil
                    showContextHighlight = false
                }
            }
        }
    }
    
    private func handleRewriteLine() {
        // Check feature access (Phase 1: Feature Gating)
        if !FeatureGate.checkAccess(.rewriteLine, showPaywall: { featureName in
            paywallFeature = featureName
            showPaywall = true
        }) {
            return
        }
        
        // Check usage limits (Phase 2: Monetization)
        if !UsageTracker.shared.canUseRewriteLine() {
            paywallFeature = "Rewrite Line"
            showPaywall = true
            return
        }
        
        // Track usage
        UsageTracker.shared.trackRewriteLine()
        UserBehaviorTracker.shared.trackFeatureUsage(feature: .rewriteLine)
        
        lightHaptic()
        isEditorFocused = false
        
        // Get last 4 lines
        let lines = item.body.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count >= 1 else { return }
        
        let last4Lines = Array(lines.suffix(4))
        
        // Extract last word and syllable count
        let metrics = RapAnalysisEngine().extractMetrics(text: item.body, highlights: computedHighlights)
        guard let rhymeTarget = metrics.rhymeTarget,
              let syllableTarget = metrics.syllableTarget else {
            return
        }
        
        Task {
            await MainActor.run {
                isRewritingLine = true
                rewriteLineLoadingStep = "Analyzing your verse..."
            }
            
            do {
                await MainActor.run {
                    rewriteLineLoadingStep = "Understanding themes..."
                }
                
                // Use Model G to generate a single line suggestion
                let narrative = try await RapSuggestionAPI.shared.analyzeNarrative(
                    text: item.body,
                    lastNLines: Array(last4Lines.map { String($0) }),
                    model: .modelG
                )
                
                await MainActor.run {
                    rewriteLineLoadingStep = "Generating suggestions..."
                }
                
                // CSV search is deprecated - use constraint-driven generation instead
                let candidates: [RapLine] = []
                
                // Filter candidates that rhyme with the target
                let rhymingCandidates = candidates.filter { line in
                    let tokenizer = NLTokenizer(unit: .word)
                    tokenizer.string = line.text
                    var lastWord: String?
                    tokenizer.enumerateTokens(in: line.text.startIndex..<line.text.endIndex) { range, _ in
                        lastWord = String(line.text[range]).lowercased()
                        return true
                    }
                    
                    guard let word = lastWord else { return false }
                    
                    // Check if it rhymes with target
                    guard let wordPhonemes = FJCMUDICTStore.shared.phonemesByWord[word],
                          let targetPhonemes = FJCMUDICTStore.shared.phonemesByWord[rhymeTarget],
                          let wordSig = RhymeHighlighterEngine.extractSignature(from: wordPhonemes),
                          let targetSig = RhymeHighlighterEngine.extractSignature(from: targetPhonemes),
                          let strength = RhymeHighlighterEngine.rhymeScore(wordSig, targetSig) else {
                        return false
                    }
                    
                    return strength == .perfect || strength == .near
                }
                
                await MainActor.run {
                    rewriteLineLoadingStep = "Generating line..."
                }
                
                // Generate single line suggestion using Model G
                let filtered = ConstraintFilter(phonemeStoreProvider: { FJCMUDICTStore.shared.phonemesByWord }).filterCandidates(
                    candidates: rhymingCandidates,
                    metrics: metrics
                )
                
                // Generate single line suggestion
                let suggestion = try await RapSuggestionAPI.shared.generateSingleLineSuggestion(
                    candidates: filtered.map { $0.line },
                    metrics: metrics,
                    narrative: narrative,
                    rhymeTarget: rhymeTarget,
                    syllableTarget: syllableTarget,
                    model: .modelG
                )
                
                await MainActor.run {
                    rewriteLineSuggestion = suggestion
                    insertRewriteLine(suggestion)
                    isRewritingLine = false
                    rewriteLineLoadingStep = nil
                }
            } catch {
                await MainActor.run {
                    isRewritingLine = false
                    rewriteLineLoadingStep = nil
                }
            }
        }
    }
    
    // MARK: - Undo/Redo Handlers
    private func handleUndo() {
        guard !undoHistory.isEmpty else { return }
        lightHaptic()
        
        // Save current state to redo history
        redoHistory.append(item.body)
        
        // Restore previous state
        let previousState = undoHistory.removeLast()
        isUndoing = true
        item.body = previousState
        isUndoing = false
        
        // Update modification date
        item.modifiedDate = Date()
    }
    
    private func handleRedo() {
        guard !redoHistory.isEmpty else { return }
        lightHaptic()
        
        // Save current state to undo history
        undoHistory.append(item.body)
        
        // Restore next state
        let nextState = redoHistory.removeLast()
        isRedoing = true
        item.body = nextState
        isRedoing = false
        
        // Update modification date
        item.modifiedDate = Date()
    }
    
    private func insertRewriteLine(_ line: String) {
        // Insert a new line instead of replacing
        let prefix = item.body.isEmpty ? "" : "\n"
        item.body += prefix + line
        item.modifiedDate = Date()
    }
    
    // MARK: - Onboarding Splash Screen Helpers
    
    private func showNextToolbarButtonSplash() {
        guard let nextSplashID = splashManager.getNextToolbarButtonSplash() else {
            // All button splashes shown
            return
        }
        
        currentButtonSplashID = nextSplashID
        isToolbarExpanded = true // Ensure toolbar is expanded
        
        // Small delay to ensure toolbar is rendered
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showToolbarButtonSplash = true
        }
    }
    
    private func getButtonInfo(for id: SplashScreenID) -> (title: String, description: String, icon: String) {
        switch id {
        case .toolbarPaperclip:
            return (
                title: "Attach & Import",
                description: "Import audio files, notes, or record audio directly into your journal entry",
                icon: "paperclip"
            )
        case .toolbarAISparkle:
            return (
                title: "AI Writing Assistant",
                description: "Get AI-powered suggestions for your next lines, rewrite lines, suggest rhymes, and improve flow. Configure Model G, Model G Core, and Model Y in preferences.",
                icon: "sparkles"
            )
        case .toolbarUndoRedo:
            return (
                title: "Undo & Redo",
                description: "Easily undo or redo your changes while writing",
                icon: "arrow.uturn.backward"
            )
        case .toolbarEyeToggle:
            return (
                title: "Rhyme Overlay",
                description: "Toggle visual rhyme highlighting to see rhyming words color-coded in your text",
                icon: "eye"
            )
        case .toolbarMagnifyingGlass:
            return (
                title: "Rhyme Groups",
                description: "View all rhyme groups in your text and explore rhyming words",
                icon: "text.magnifyingglass"
            )
        case .toolbarDiagnostics:
            return (
                title: "Rhyme Diagnostics",
                description: "Analyze syllables, stress patterns, cadence, and flow metrics for your verse",
                icon: "chart.bar"
            )
        default:
            return (title: "", description: "", icon: "questionmark")
        }
    }
    
    private func calculateApproximateButtonFrame(for id: SplashScreenID, toolbarFrame: CGRect) -> CGRect {
        // Calculate approximate button positions based on toolbar layout
        // Buttons are in order: X, Paperclip, AI Sparkle, Undo, Redo, Eye, Magnifying Glass, Diagnostics, Keyboard
        // Each button is 44x44 with 14pt spacing
        let buttonSize: CGFloat = 44
        let spacing: CGFloat = 14
        let startX = toolbarFrame.minX + 16 + 44 + spacing // After X button
        
        let buttonIndex: Int
        switch id {
        case .toolbarPaperclip:
            buttonIndex = 0
        case .toolbarAISparkle:
            buttonIndex = 1
        case .toolbarUndoRedo:
            buttonIndex = 2 // Approximate for undo button
        case .toolbarEyeToggle:
            buttonIndex = 4
        case .toolbarMagnifyingGlass:
            buttonIndex = 5
        case .toolbarDiagnostics:
            buttonIndex = 6
        default:
            buttonIndex = 0
        }
        
        let buttonX = startX + CGFloat(buttonIndex) * (buttonSize + spacing)
        let buttonY = toolbarFrame.midY
        
        return CGRect(
            x: buttonX,
            y: buttonY - buttonSize / 2,
            width: buttonSize,
            height: buttonSize
        )
    }
    
    // Helper function to find UITextView in view hierarchy
    private func findTextView(in view: UIView) -> UITextView? {
        if let textView = view as? UITextView {
            return textView
        }
        for subview in view.subviews {
            if let textView = findTextView(in: subview) {
                return textView
            }
        }
        return nil
    }
    
    // SEGMENT 20: Helper to find TextEditor's underlying UITextView
    // This is used to disable automatic scroll-to-cursor behavior
    private func findTextEditorTextView() -> UITextView? {
        // This is a fallback - the actual TextEditor UITextView might be harder to access
        // The main fix is through the modifiers and delegate methods
        return nil
    }
    }
