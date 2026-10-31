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
import NaturalLanguage
import AVFoundation
import PhotosUI
import UniformTypeIdentifiers

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(EditorChromeSettings.hideToolbarGlassKey) private var hideToolbarGlass = false
    @Bindable var item: Item

    @AppStorage(EyeHighlightOption.rhymesStorageKey) private var isRhymeOverlayVisible: Bool = true
    @AppStorage(EyeHighlightOption.techniquesStorageKey) private var techniqueOverlayOn = false
    @AppStorage(EyeHighlightOption.setupAndPunchStorageKey) private var setupAndPunchOn = false
    @AppStorage("barClockStripVisible") private var barClockStripVisible: Bool = true
    /// When off, holding a syllable count does not open Bar Hits. The toolbar button still does.
    @AppStorage("barHits.opensFromHold") private var barHitsOpensFromHold = true
    @AppStorage("barClockPunchBeats") private var punchBeatsRaw: String = "3,4"
    @State private var showPunchHint = false
    @State private var showBreathCommaPrompt = false
    @State private var breathCommaPrompt: [BreathCommaEdit] = []
    @StateObject private var remindsMeOfService = RemindsMeOfService()
    @State private var selectedGeniusMatch: RemindsMeOfLineMatch?
    @State private var showGeniusLineHits: Bool = false
    @State private var showRemindsMeOfPopover: Bool = false
    @State private var pulseLineIndex: Int?
    @State private var pulseWordUTF16: NSRange?
    @State private var holdPulseLocked = false
    /// Cursor range when the hold lookup started. A later move while loading closes Bar Hits.
    @State private var barHitsSelectionAnchor: NSRange?
    @StateObject private var beatPreview = NoteBeatPreviewPlayer()
    @State private var tappedWordUTF16Range: NSRange?
    @State private var showRhymeDiagnostics: Bool = false
    @State private var showGhostPricing: Bool = false
    @State private var showNounBank: Bool = false
    @FocusState private var isEditorFocused: Bool
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State private var isToolbarExpanded: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var savedScrollPosition: CGFloat = 0 // SEGMENT 20: Save scroll position to prevent jump
    /// True after this note's file has been played. Stays until the note is left.
    @State private var audioDockArmed = false
    /// The recording card is still on screen. The dock circle replaces it once it scrolls away.
    @State private var audioCardVisible = true
    @State private var rhymeOverlayHeight: CGFloat = 40 // Dynamic height for rhyme overlay
    /// Overlay, gutter, and rhyme analysis stay off until the user writes, holds, or taps the eye.
    @State private var writingToolsArmed = false
    /// Gutter / dictionary drip in after the writing surface is up — keeps home and first paint lean.
    @State private var editorGutterReady = false
    @StateObject private var rhymeEngineState = RhymeEngineState()
    @State private var rhymePaintEpoch: Int = 0

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
        rhymeEngineState.groups(for: item.body)
    }

    private var computedHighlights: [Highlight] {
        // Last-good rhyme spans, remapped across the current keystroke. Do not
        // require lastText == body — that emptied the overlay until the eye
        // retriggered refreshImmediately.
        let displayText = item.body
        var highlights: [Highlight] = []
        if techniqueOverlayOn {
            highlights.append(contentsOf: TechniqueOverlayEngine.highlights(in: displayText))
        } else if isRhymeOverlayVisible {
            highlights.append(contentsOf: rhymeEngineState.highlights(for: displayText))
            if let dock = ghostHint?.candidates,
               let extra = RhymeHighlighterEngine.liveGhostDockHighlight(
                in: displayText,
                dock: dock,
                groups: rhymeEngineState.groups(for: displayText),
                existing: highlights
               ) {
                highlights.append(extra)
            }
            highlights.append(contentsOf: calculateAITextHighlights(text: displayText))
        }
        highlights.append(contentsOf: remindsMeOfService.highlights(in: displayText))
        highlights.append(contentsOf: holdPulseHighlights(in: displayText))
        return highlights
    }

    /// Eye on (or a hold pulse) plus armed tools. Stays true while typing so
    /// `.task(id:)` does not tear down the overlay on each keystroke.
    private var rhymeSurfaceActive: Bool {
        writingToolsArmed && (isRhymeOverlayVisible || setupAndPunchOn || techniqueOverlayOn || pulseLineIndex != nil || pulseWordUTF16 != nil)
    }

    /// Eye follows overlay. Landing a note turns overlay on and arms paint.
    private var rhymeEyeBinding: Binding<Bool> {
        Binding(
            get: { isRhymeOverlayVisible && !setupAndPunchOn && !techniqueOverlayOn },
            set: { on in
                if on {
                    ensureEyeHighlight(.rhymes)
                } else if isRhymeOverlayVisible && !setupAndPunchOn && !techniqueOverlayOn {
                    selectEyeHighlight(.rhymes)
                }
            }
        )
    }

    /// Dictionary and rhyme paint stay off for a blank note. Arm when the eye is on
    /// and this note already has text (open existing, or first keystroke).
    private func armWritingToolsIfNoteNeedsThem() {
        guard isRhymeOverlayVisible || setupAndPunchOn || techniqueOverlayOn else { return }
        guard !item.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        armWritingTools()
    }

    /// One highlight at a time. Tap the active row again to turn all washes off.
    private func selectEyeHighlight(_ option: EyeHighlightOption) {
        HapticFeedbackManager.shared.selection()
        let alreadyOn: Bool
        switch option {
        case .rhymes:
            alreadyOn = isRhymeOverlayVisible && !setupAndPunchOn && !techniqueOverlayOn
        case .setupAndPunch:
            alreadyOn = setupAndPunchOn && !techniqueOverlayOn
        case .techniques:
            alreadyOn = techniqueOverlayOn
        }
        if alreadyOn {
            isRhymeOverlayVisible = false
            setupAndPunchOn = false
            techniqueOverlayOn = false
        } else {
            isRhymeOverlayVisible = (option == .rhymes)
            setupAndPunchOn = (option == .setupAndPunch)
            techniqueOverlayOn = (option == .techniques)
            armWritingToolsIfNoteNeedsThem()
        }
        rhymePaintEpoch += 1
    }

    /// Highlight is already on. Offer breath commas only for lines the wrap can support.
    private func offerBreathCommas() {
        let edits = BreathCommaFormatter.edits(
            in: item.body,
            wrapSyllables: BreathCommaFormatter.wrapCount(min: item.syllableMin, max: item.syllableMax)
        )
        breathCommaPrompt = edits
        showBreathCommaPrompt = !edits.isEmpty
    }

    private func applyBreathCommas(_ edits: [BreathCommaEdit]) {
        let updated = BreathCommaFormatter.applying(edits, to: item.body)
        guard updated != item.body else { return }
        guard let textView = EditorWritingMetrics.activeTextView,
              let range = textView.textRange(from: textView.beginningOfDocument, to: textView.endOfDocument)
        else {
            item.body = updated
            return
        }
        textView.replace(range, withText: updated)
        if (textView.text ?? "") != updated || item.body != updated {
            item.body = updated
        }
    }

    /// Turn a highlight on without toggling it off if it is already the active mode.
    private func ensureEyeHighlight(_ option: EyeHighlightOption) {
        let alreadyOn: Bool
        switch option {
        case .rhymes:
            alreadyOn = isRhymeOverlayVisible && !setupAndPunchOn && !techniqueOverlayOn
        case .setupAndPunch:
            alreadyOn = setupAndPunchOn && !techniqueOverlayOn
        case .techniques:
            alreadyOn = techniqueOverlayOn
        }
        if alreadyOn { return }
        isRhymeOverlayVisible = (option == .rhymes)
        setupAndPunchOn = (option == .setupAndPunch)
        techniqueOverlayOn = (option == .techniques)
        armWritingToolsIfNoteNeedsThem()
        rhymePaintEpoch += 1
    }

    private func applyGhostMode(_ raw: String) {
        ghostModeRaw = raw
        if GhostMode(rawValue: raw) != .off {
            let text = item.body
            ghostTask?.cancel()
            ghostTask = Task { @MainActor in
                await refreshGhost(text: text, completed: false)
            }
        } else {
            ghostHint = nil
            ghostHeldSetup = nil
            ghostPunches = []
        }
    }

    private func armWritingTools() {
        guard !writingToolsArmed else { return }
        writingToolsArmed = true
        let font = CGFloat(
            UserDefaults.standard.object(forKey: EditorChromeSettings.writingFontSizeKey) as? Double
                ?? EditorChromeSettings.defaultWritingFontSize
        )
        let lineCount = max(1, item.body.split(separator: "\n", omittingEmptySubsequences: false).count)
        let estimated = CGFloat(lineCount) * font * 1.24 + 166
        if rhymeOverlayHeight < estimated {
            rhymeOverlayHeight = estimated
        }
        rhymePaintEpoch += 1
        Task { await rhymeEngineState.refreshImmediately(text: item.body) }
        Task.detached(priority: .userInitiated) {
            preloadGlobalCMUDICTStore()
            RhymeFinder.warmIndex()
        }
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
            model: rapSuggestionEngine.lastStandardGenerationModel,
            bpm: item.bpm,
            key: item.key,
            scale: item.scale,
            syllableMin: item.syllableMin,
            syllableMax: item.syllableMax,
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
                in: text,
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
                    in: text,
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
    @State private var showSyllablesPopover: Bool = false
    @State private var showFolderPopover: Bool = false
    /// The tempo / key / scale / bar-length row is hidden until Beat Info is tapped.
    @State private var beatInfoExpanded = false
    /// True while a pill menu is on screen, so the row does not hide underneath it.
    @State private var beatInfoMenuOpen = false
    /// Bumps whenever a tap or scroll in the row should restart the 4 second hide.
    @State private var beatInfoGeneration = 0
    @State private var beatInfoLastTouch: Date = .distantPast
    @State private var showAudioRecorder: Bool = false
    @State private var showRapSuggestions: Bool = false
    @State private var showModelGControlSurface: Bool = false
    @State private var isShowingRecalled: Bool = false
    @State private var showContextHighlight: Bool = false
    @State private var showAudioImporter: Bool = false
    @State private var audioDropTargeted: Bool = false
    @State private var audioAttachError: String?
    @State private var pendingAudioURL: URL?
    @State private var pendingAudioName: String = ""
    @State private var showReplaceAudioConfirm: Bool = false
    @State private var lastEditorDropAt: Date?
    @State private var showImportNotesInstructions: Bool = false
    @State private var showAudioDetailSheet: Bool = false
    @State private var recordAfterAudioDetail: Bool = false
    @State private var metadataGlow: Bool = false
    @State private var audioMetaSnapshot: String = ""
    @State private var showRawTranscriptOnSurface: Bool = false
    @State private var shouldAutoTranscribe: Bool = false
    @State private var showFindInTranscript: Bool = false
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

    // Ghost Bar
    @AppStorage(GhostMode.storageKey) private var ghostModeRaw: String = GhostMode.off.rawValue
    @State private var ghostHint: GhostHint?
    @State private var ghostTask: Task<Void, Never>?
    @State private var ghostPool: [String] = []        // current rhyme group (cached per family)
    @State private var ghostPunches: [GhostPunchChip] = []
    @State private var ghostTargetWrap: Int = 0
    @State private var ghostHeldSetup: String?
    @State private var ghostRhymeKey: String?          // family of ghostPool; re-scan when it changes
    @State private var ghostLandedWord: String?
    @State private var ghostLandedTask: Task<Void, Never>?
    @State private var isGhostSearching = false
    /// End rhymes + AI, keyed by end word and note title, so a pause on the same word does not bill twice.
    @State private var liveRhymeCache: [String: [String]] = [:]
    @State private var liveRhymeInflightKey: String?
    @State private var isGeneratingThemeExpansion: Bool = false
    @State private var selectedArtistForStyleTransfer: String = ""
    
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
        UINotificationFeedbackGenerator().notificationOccurred(.error)

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
        if destination == .retryGenerate {
            runModelGGenerate(
                directedParams: rapSuggestionEngine.lastParallelDirectedParams,
                rhymeGroupsByID: rapSuggestionEngine.lastParallelRhymeGroupsByID
            )
            return
        }
        AppNavigation.navigate(to: destination)
    }

    private func runModelGGenerate(
        directedParams: DirectedGenerationParams?,
        rhymeGroupsByID: [RhymeGroupID: RhymeGroupSummary]? = nil
    ) {
        showContextHighlight = true
        Task {
            await rapSuggestionEngine.generateSuggestions(
                text: currentText,
                highlights: computedHighlights,
                // V6 is this call: Model G Core v4, generateFullVerse, then the chat provider for the key.
                // frontier_v5.py is not on this route. V7 has no endpoint.
                model: .modelG,
                bpm: item.bpm,
                key: item.key,
                scale: item.scale,
                syllableMin: item.syllableMin,
                syllableMax: item.syllableMax,
                directedParams: directedParams,
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

    // Wrapper function for DynamicIslandToolbarView that expects (String) -> Void
    private func showAIErrorWrapper(_ message: String) {
        showAIError(message)
    }
    
    @State private var canUndoWriting = false
    @State private var canRedoWriting = false

    var body: some View {
        editorChrome(editorContent)
    }

    private var editorContent: some View {
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

                // Tempo, key, scale, and bar length stay hidden until Beat Info opens them.
                if beatInfoExpanded {
                    metadataPillsView
                        .padding(.vertical, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if barClockStripVisible, item.bpm != nil || beatPreview.isPlaying {
                    if showPunchHint || showsBarClockStatusCaption {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Momentum.accent)
                                .frame(width: 6, height: 6)
                            Text(barClockCaption)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Momentum.accent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 6)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    BarClockStrip(
                        activeBeat: beatPreview.beatInBar,
                        punchBeats: punchBeats,
                        onTogglePunch: togglePunchBeat
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                if beatPreview.missingAudio {
                    Menu {
                        Button {
                            showAudioRecorder = true
                        } label: {
                            Label("Record audio", systemImage: "waveform")
                        }
                        Button {
                            presentAudioImporter()
                        } label: {
                            Label("Attach audio", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Text("Record or attach a beat to play it.")
                            .font(.caption)
                            .foregroundStyle(Momentum.accent)
                            .frame(maxWidth: .infinity)
                    }
                    .accessibilityHint("Opens record, or attach an mp3, m4a, wav, or aiff to this note.")
                    .padding(.bottom, 8)
                }
                if showContextHighlight {
                    Text("Writing from the last 4 lines")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Momentum.contentSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                }
            }
            .background(
                EditorHeaderCoralBackground(bpm: item.bpm)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
            )

            Divider()
                .frame(maxWidth: .infinity) // Extend divider to full width

            GeometryReader { viewport in
            ScrollView(.vertical, showsIndicators: false) {
                        // Disable automatic scrolling when text editor is focused
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self,
                                            value: geo.frame(in: CoordinateSpace.named("editorScroll")).minY)
                        }
                        .frame(height: 0)
                    VStack(alignment: .leading, spacing: 0) { // FIXED: Decouple spacing
                        if let audioPath = item.audioPath, !audioPath.isEmpty {
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
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .accessibilityIdentifier("note-audio-bar")
                            .onScrollVisibilityChange(threshold: 0.15) { visible in
                                audioCardVisible = visible
                            }
                        }
                        // SEGMENT 19: Unified Padding - Apply padding to ZStack for consistent writing room
                            WritingSurface(
                                text: $item.body,
                                highlights: computedHighlights,
                                isEditorFocused: $isEditorFocused,
                                isRhymeOverlayVisible: isRhymeOverlayVisible || techniqueOverlayOn,
                                showBreathWash: !techniqueOverlayOn && setupAndPunchOn && writingToolsArmed,
                                showRhymeSurface: writingToolsArmed,
                                showGutter: editorGutterReady || writingToolsArmed,
                                showCraftHeat: techniqueOverlayOn,
                                rhymeOverlayHeight: $rhymeOverlayHeight,
                                scrollOffset: scrollOffset,
                                savedScrollPosition: $savedScrollPosition,
                                slamAnimationText: slamAnimationText,
                                slamAnimationOffset: slamAnimationOffset,
                                slamAnimationScale: slamAnimationScale,
                                // The audio card sits above this well. A short minimum kept the
                                // card on screen and shrank the writing area. A full well lets
                                // the card scroll away with the text.
                                minHeight: viewport.size.height - ((item.audioPath?.isEmpty == false) ? 16 : 200),
                                paintEpoch: rhymePaintEpoch,
                                onWordTap: handleTappedWord,
                                onHoldSyllableLine: handleHoldSyllableLine,
                                onSyllablePressing: handleSyllablePressing,
                                onWordHoldPreview: handleWordHoldPreview,
                                onWordHoldBegan: handleWordHoldBegan,
                                onWordHoldEnded: handleWordHoldEnded,
                                onWordHoldCancelled: {
                                    if !showRhymeSuggestions { clearHoldPulse() }
                                },
                                onSelectionChange: handleEditorSelectionChange,
                                onEditorDrop: receiveEditorDrop,
                                onSurfaceTap: { collapseBeatInfo() }
                            )
                        
                            // Timestamp lives at the END of the scroll content so it
                            // scrolls WITH the text (Apple Notes style). Pinning it as a
                            // bottom overlay made long notes scroll text *under* it — a
                            // visual clash. WritingSurface's minHeight keeps it near the
                            // bottom for short notes without needing to scroll.
                            noteTimestampBar
                                .padding(.top, 8)
                                // 64pt island + 16pt air — short notes were drawing Created/Modified
                                // under the collapsed writing island.
                                .padding(.bottom, 80)
                    }
                    .frame(maxWidth: 680)
                    .frame(maxWidth: .infinity) // Center the 680 column in the iPad detail pane
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
            // Fully opaque writing surface — the coral bloom now lives in the header
            // section above the divider, not on the writing area.
            .background(Momentum.surfaceElevated)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // SEGMENT 20: Scroll Gravity Locking - Ignore keyboard safe area to prevent displacement
        // While the toolbar follows the keyboard, the text surface should ignore keyboard displacement
        // This prevents the entire view from shifting upward when focus is gained
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onDrop(
            of: [
                .audio, .mp3, .mpeg4Audio, .wav, .aiff,
                .plainText, .utf8PlainText, .text, .fileURL
            ],
            isTargeted: $audioDropTargeted
        ) { providers in
            receiveEditorDrop(providers)
            return true
        }
        .overlay(alignment: .top) {
            if audioDropTargeted {
                Text("Drop audio or lyrics")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Momentum.surfaceElevated)
                            .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                    )
                    .padding(.top, 8)
                    .accessibilityLabel("Drop audio or lyrics")
            }
        }
        .safeAreaInset(edge: .bottom) {
            // One stable inset: a second inset that appears on Enter rebuilds the
            // responder chain (keyboard drop) and relayouts the gutter before glyphs exist.
            VStack(spacing: 0) {
                if let hint = ghostHint,
                   GhostMode(rawValue: ghostModeRaw) != .off,
                   !techniqueOverlayOn {
                    GhostBarPill(
                        candidates: hint.candidates,
                        punches: hint.punches,
                        targetWrap: hint.targetWrap,
                        typingPrefix: ghostTypingPrefix,
                        landedWord: ghostLandedWord,
                        onAccept: insertGhostWord,
                        onDismiss: {
                            ghostHint = nil
                            ghostHeldSetup = nil
                            ghostPunches = []
                            isGhostSearching = false
                        },
                        pocketCaption: GhostMode(rawValue: ghostModeRaw) == .cadence
                            ? "Similar setups · punch half"
                            : nil,
                        isSearching: isGhostSearching
                    )
                        .padding(.bottom, 2)
                }
                bottomToolbar
                    .overlay(alignment: .topLeading) {
                        Group {
                            if !isToolbarExpanded {
                                NoteClipboardDockButton()
                                    .padding(.top, 10)
                                    .padding(.leading, 8)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isToolbarExpanded)
                    }
                    .overlay(alignment: .topTrailing) {
                        if audioDockArmed, !audioCardVisible, !isToolbarExpanded,
                           let path = item.audioPath, !path.isEmpty {
                            NoteAudioDockButton(item: item)
                                .padding(.top, 10)
                                .padding(.trailing, 8)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: audioDockArmed && !audioCardVisible)
            }
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
            ModelGControlSurfaceView(
                rhymeGroups: rhymeGroups,
                noteBPM: item.bpm,
                noteKey: item.key,
                noteScale: item.scale,
                noteText: item.body,
                noteTranscript: item.transcription,
                syllableMin: $item.syllableMin,
                syllableMax: $item.syllableMax
            ) { params, rhymeGroupsByID in
                showModelGControlSurface = false
                runModelGGenerate(directedParams: params, rhymeGroupsByID: rhymeGroupsByID)
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
                        await rapSuggestionEngine.generateSuggestions(
                            text: currentText,
                            highlights: highlights,
                            model: rapSuggestionEngine.lastStandardGenerationModel,
                            bpm: item.bpm,
                            key: item.key,
                            scale: item.scale,
                            syllableMin: item.syllableMin,
                            syllableMax: item.syllableMax,
                            directedParams: rapSuggestionEngine.lastParallelDirectedParams,
                            rhymeGroupsByID: rapSuggestionEngine.lastParallelRhymeGroupsByID,
                            audioURL: item.audioPath.flatMap { URL(fileURLWithPath: $0) },
                            transcriptionRhythmMapData: item.transcriptionRhythmMapData,
                            noteKey: aiNoteKey,
                            noteTitle: item.title,
                            persistTo: item
                        )
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
                generations: isShowingRecalled ? [] : rapSuggestionEngine.generations,
                humanCriticFeedback: $rapSuggestionEngine.humanCriticFeedback,
                humanCriticLoading: $rapSuggestionEngine.humanCriticLoading,
                humanCriticError: $rapSuggestionEngine.humanCriticError,
                onRetryHumanCritic: retryHumanCriticForCurrentNote
            )
        }
        .sheet(isPresented: $showRhymeSuggestions, onDismiss: { clearHoldPulse() }) {
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
        .popover(isPresented: $showGeniusLineHits, arrowEdge: .bottom) {
            if let match = selectedGeniusMatch {
                RemindsMeOfLineHitsView(match: match)
                    .presentationCompactAdaptation(.popover)
            }
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
        .tint(Momentum.chromeIcon)
        .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAudioRecorder) {
            AudioRecorderView(item: item)
        }
                .sheet(isPresented: $showNounBank) {
            NounBankSheet { word in
                insertNounBankWord(word)
            }
        }
.fullScreenCover(isPresented: $showAudioDetailSheet, onDismiss: {
            if recordAfterAudioDetail {
                recordAfterAudioDetail = false
                showAudioRecorder = true
            }
        }) {
            AudioDetailSheet(item: item, autoTranscribe: shouldAutoTranscribe, onRecord: {
                recordAfterAudioDetail = true
                showAudioDetailSheet = false
            })
            .presentationBackground(.black)
        }
        .onChange(of: showAudioDetailSheet) { oldValue, newValue in
            if newValue {
                // Opening: snapshot audio metadata so we can detect what analysis adds.
                audioMetaSnapshot = "\(item.bpm ?? -1)|\(item.key ?? "")|\(item.scale ?? "")"
            } else {
                // Reset auto-transcribe flag when sheet is dismissed
                shouldAutoTranscribe = false
                // Toast: if fresh BPM/key/scale arrived from the audio, glow the pills.
                let now = "\(item.bpm ?? -1)|\(item.key ?? "")|\(item.scale ?? "")"
                if now != audioMetaSnapshot && (item.bpm != nil || item.key != nil || item.scale != nil) {
                    triggerMetadataGlow()
                }
            }
        }
        .fileImporter(
            isPresented: $showAudioImporter,
            allowedContentTypes: [.audio, .mpeg4Audio, .mp3, .wav, .aiff],
            allowsMultipleSelection: false
        ) { result in
            handleAudioImport(result: result)
        }
        .confirmationDialog(
            "Replace the audio on this note?",
            isPresented: $showReplaceAudioConfirm,
            titleVisibility: .visible
        ) {
            Button("Replace audio", role: .destructive) {
                if let url = pendingAudioURL {
                    commitAudio(from: url, suggestedName: pendingAudioName)
                }
                pendingAudioURL = nil
                pendingAudioName = ""
            }
            Button("Keep the current audio", role: .cancel) {
                if let url = pendingAudioURL {
                    try? FileManager.default.removeItem(at: url)
                }
                pendingAudioURL = nil
                pendingAudioName = ""
            }
        } message: {
            Text("This note already has a beat. The new file replaces it. The lyrics stay as they are.")
        }
        .alert(
            "Couldn't attach that file",
            isPresented: Binding(
                get: { audioAttachError != nil },
                set: { if !$0 { audioAttachError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { audioAttachError = nil }
        } message: {
            Text(audioAttachError ?? "")
        }
        .sheet(isPresented: $showBreathCommaPrompt) {
            BreathCommaPromptSheet(
                edits: breathCommaPrompt,
                onAdd: {
                    let edits = breathCommaPrompt
                    showBreathCommaPrompt = false
                    HapticFeedbackManager.shared.selection()
                    applyBreathCommas(edits)
                },
                onLeave: {
                    showBreathCommaPrompt = false
                }
            )
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
            if PendingNoteLaunch.openRecorder {
                PendingNoteLaunch.openRecorder = false
                showAudioRecorder = true
            }
        }
        .onChange(of: item.persistentModelID) { _, _ in
            beatPreview.stop()
            remindsMeOfService.clearScan()
            pulseLineIndex = nil
            pulseWordUTF16 = nil
            holdPulseLocked = false
            tappedWordUTF16Range = nil
            isToolbarExpanded = false
            audioDockArmed = false
            audioCardVisible = true
            selectedGeniusMatch = nil
            showGeniusLineHits = false
            showRemindsMeOfPopover = false
            rhymePaintEpoch += 1
            writingToolsArmed = false
            EditorWritingMetrics.activeTextView?.undoManager?.removeAllActions()
            canUndoWriting = false
            canRedoWriting = false
            collapseBeatInfo()
            if let url = pendingAudioURL {
                try? FileManager.default.removeItem(at: url)
            }
            pendingAudioURL = nil
            pendingAudioName = ""
            showReplaceAudioConfirm = false
            audioAttachError = nil
            showBreathCommaPrompt = false
            breathCommaPrompt = []
            armWritingToolsIfNoteNeedsThem()
        }
        .onReceive(AudioPlayerManager.shared.$playGeneration) { _ in
            guard let path = item.audioPath, AudioPlayerManager.shared.noteAudioMatches(path) else { return }
            audioDockArmed = true
        }
        .task(id: item.persistentModelID) {
            audioDockArmed = false
            audioCardVisible = true
            editorGutterReady = true
            if techniqueOverlayOn {
                isRhymeOverlayVisible = false
                setupAndPunchOn = false
            } else if setupAndPunchOn {
                isRhymeOverlayVisible = false
            }
            if !item.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                armWritingTools()
            }
            refreshUndoButtons()
        }
    }

    private func editorChrome<V: View>(_ content: V) -> some View {
        content
        .onChange(of: isRhymeOverlayVisible) { _, isOn in
            if isOn {
                setupAndPunchOn = false
                techniqueOverlayOn = false
                armWritingToolsIfNoteNeedsThem()
            }
        }
        .onChange(of: setupAndPunchOn) { _, isOn in
            rhymePaintEpoch += 1
            if isOn {
                armWritingToolsIfNoteNeedsThem()
                offerBreathCommas()
            } else {
                showBreathCommaPrompt = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .cmudictDidFinishLoading)) { _ in
            rhymePaintEpoch += 1
        }
        .onChange(of: techniqueOverlayOn) { _, isOn in
            rhymePaintEpoch += 1
            if isOn {
                armWritingToolsIfNoteNeedsThem()
                ghostHint = nil
            } else if GhostMode(rawValue: ghostModeRaw) != .off {
                let text = item.body
                ghostTask?.cancel()
                ghostTask = Task { @MainActor in
                    await refreshGhost(text: text, completed: false)
                }
            }
        }
        .task(id: rhymeSurfaceActive) {
            guard rhymeSurfaceActive else { return }
            await rhymeEngineState.refreshImmediately(text: item.body)
        }
        .task(id: barClockStripOn) {
            guard barClockStripOn, writingToolsArmed else { return }
            if BarClockPunchHint.shownThisLaunch {
                showPunchHint = false
                return
            }
            showPunchHint = true
            BarClockPunchHint.shownThisLaunch = true
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            withAnimation(.easeInOut(duration: 0.3)) {
                showPunchHint = false
            }
        }
        .onChange(of: showRemindsMeOfPopover) { _, isPresented in
            if isPresented { armWritingTools() }
            if !isPresented {
                remindsMeOfService.cancelHeldLookup()
                clearHoldPulse()
            }
        }
        .onDisappear {
            beatPreview.stop()
            beatInfoGeneration += 1
        }
        .onChange(of: beatInfoSuppressesHide) { _, holding in
            if holding {
                beatInfoGeneration += 1
            } else if beatInfoExpanded {
                beatInfoGeneration += 1
            }
        }
        .task(id: beatInfoHideToken) {
            guard beatInfoExpanded, !beatInfoSuppressesHide else { return }
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard !Task.isCancelled, beatInfoExpanded, !beatInfoSuppressesHide else { return }
            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                beatInfoExpanded = false
            }
        }
        .overlay {
            toolbarSplashesOverlay
        }
        .onChange(of: item.bpm) { _, newValue in
            if beatPreview.isPlaying {
                beatPreview.prepare(bpm: newValue)
            }
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
            URLAttachmentPopoverView(url: $item.urlAttachment, bpm: $item.bpm, key: $item.key, scale: $item.scale)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSyllablesPopover) {
            SyllablesPopoverView(syllableMin: $item.syllableMin, syllableMax: $item.syllableMax)
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
    /// The text-entry surface — one `UITextView` (rhyme colors are attributes, not a second field).
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
        var showBreathWash: Bool = false
        var showRhymeSurface: Bool = true
        var showGutter: Bool = false
        var showCraftHeat: Bool = false
        @Binding var rhymeOverlayHeight: CGFloat
        let scrollOffset: CGFloat
        @Binding var savedScrollPosition: CGFloat
        let slamAnimationText: String?
        let slamAnimationOffset: CGFloat
        let slamAnimationScale: CGFloat
        let minHeight: CGFloat
        var paintEpoch: Int = 0
        var onWordTap: ((String, NSRange) -> Void)? = nil
        var onHoldSyllableLine: ((Int) -> Void)? = nil
        var onSyllablePressing: ((Int?) -> Void)? = nil
        var onWordHoldPreview: ((String, NSRange) -> Void)? = nil
        var onWordHoldBegan: ((String, NSRange) -> Void)? = nil
        var onWordHoldEnded: ((String, NSRange) -> Void)? = nil
        var onWordHoldCancelled: (() -> Void)? = nil
        var onSelectionChange: (() -> Void)? = nil
        var onEditorDrop: (([NSItemProvider]) -> Void)? = nil
        var onSurfaceTap: (() -> Void)? = nil
        @AppStorage(EditorChromeSettings.writingFontSizeKey) private var writingFontSize: Double = EditorChromeSettings.defaultWritingFontSize
        @AppStorage(EditorChromeSettings.writingLineGuidesKey) private var showWritingLines: Bool = true
        @AppStorage(EditorChromeSettings.commaHintsKey) private var commaHintsOn: Bool = true
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        /// In-app stepper size × iOS text size. Buttons and lyrics share this.
        private var writingPointSize: CGFloat {
            let _ = dynamicTypeSize
            return EditorWritingMetrics.resolvedPointSize(CGFloat(writingFontSize))
        }
        @State private var gutterCounts: [Int] = []
        @State private var gutterTask: Task<Void, Never>?

        private func rebuildGutter(from text: String) {
            gutterCounts = LineSyllableCounter.counts(for: text)
        }

        private func refreshGutter(from text: String) {
            gutterTask?.cancel()
            gutterTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 90_000_000)
                guard !Task.isCancelled else { return }
                rebuildGutter(from: text)
            }
        }

        /// Solid chip in the technique color, so the key matches the wash on the page.
        private func techniqueKey(_ title: String, heat: CGFloat) -> some View {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.88))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(CraftHeatPalette.color(heat), in: Capsule())
                .accessibilityLabel(title)
        }

        var body: some View {
            ZStack(alignment: .topLeading) {
                if showCraftHeat {
                    VStack(alignment: .leading, spacing: 6) {
                        LinearGradient(
                            colors: [
                                CraftHeatPalette.color(0.40),
                                CraftHeatPalette.color(0.72),
                                CraftHeatPalette.color(0.92),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 3)
                        HStack(spacing: 8) {
                            techniqueKey("Inner", heat: 0.40)
                            techniqueKey("Mosaic", heat: 0.72)
                            techniqueKey("Chain", heat: 0.92)
                        }
                        .padding(.leading, SyllableCountButtonMetrics.width(
                            forRowHeight: EditorWritingMetrics.rowHeight(fontSize: writingPointSize)
                        ))
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .allowsHitTesting(false)
                }
                GeometryReader { geo in
                    RhymeHighlightTextView(
                        text: text,
                        highlights: highlights,
                        isVisible: isRhymeOverlayVisible && showRhymeSurface,
                        showBreathWash: showBreathWash,
                        showFullText: true,
                        horizontalPadding: 20,
                        isEditable: true,
                        onTextChange: { newText in
                            text = newText
                        },
                        dynamicHeight: $rhymeOverlayHeight,
                        availableWidth: geo.size.width,
                        fontSize: writingPointSize,
                        paintEpoch: paintEpoch,
                        isFocused: Binding(
                            get: { isEditorFocused },
                            set: { isEditorFocused = $0 }
                        ),
                        onWordTap: onWordTap,
                        onWordHoldPreview: onWordHoldPreview,
                        onWordHoldBegan: onWordHoldBegan,
                        onWordHoldEnded: onWordHoldEnded,
                        onWordHoldCancelled: onWordHoldCancelled,
                        onSelectionChange: onSelectionChange,
                        onEditorDrop: onEditorDrop
                    )
                    .frame(width: geo.size.width, height: max(rhymeOverlayHeight, geo.size.height), alignment: .topLeading)
                    .animation(nil, value: isRhymeOverlayVisible)
                    .animation(nil, value: showBreathWash)
                }
                .frame(maxWidth: 680, alignment: .leading)
                .frame(height: max(rhymeOverlayHeight, 44), alignment: .topLeading)
                .padding(.leading, SyllableCountButtonMetrics.width(
                    forRowHeight: EditorWritingMetrics.rowHeight(fontSize: writingPointSize)
                ))
                .padding(.trailing, 20)
                .padding(.top, showCraftHeat ? 56 : 8)
                .allowsHitTesting(true)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(0)
                .scrollDismissesKeyboard(.never)
                .ignoresSafeArea(.keyboard, edges: .all)

                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Tap to write")
                        .font(.system(size: writingPointSize))
                        .foregroundStyle(Momentum.contentSecondary)
                        .padding(.leading, SyllableCountButtonMetrics.width(
                            forRowHeight: EditorWritingMetrics.rowHeight(fontSize: writingPointSize)
                        ) + 5)
                        .padding(.top, 8)
                        .frame(maxWidth: 680, alignment: .leading)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                // Slam animation overlay (iMessage-style)
                if let slamText = slamAnimationText {
                    Text(slamText)
                        .font(.system(size: writingPointSize))
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
            // Empty well (between pills and island): entire rectangle focuses the keyboard.
            // "Tap to write" stays until the first character; contentShape covers the full well.
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded {
                onSurfaceTap?()
                if !isEditorFocused {
                    isEditorFocused = true
                }
            })
            .onAppear {
                HapticFeedbackManager.shared.prepareHold()
                Task { await CatalogEndWordIndex.shared.rebuildIfNeeded(force: false) }
                rebuildGutter(from: text)
                let rowH = EditorWritingMetrics.rowHeight(fontSize: writingPointSize)
                let lineCount = max(1, text.split(separator: "\n", omittingEmptySubsequences: false).count)
                let estimated = CGFloat(lineCount) * rowH + 166
                if rhymeOverlayHeight < estimated {
                    rhymeOverlayHeight = estimated
                }
                if text.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isEditorFocused = true
                    }
                }
            }
            .onChange(of: isEditorFocused) { oldValue, newValue in
                if newValue && !oldValue {
                    savedScrollPosition = scrollOffset
                }
                let editor = EditorWritingMetrics.activeTextView
                if newValue {
                    if editor?.isFirstResponder != true {
                        editor?.becomeFirstResponder()
                    }
                } else if editor?.isFirstResponder == true {
                    editor?.resignFirstResponder()
                }
            }
            .onChange(of: text) { _, newText in
                refreshGutter(from: newText)
            }
            .onChange(of: writingFontSize) { _, _ in
                rebuildGutter(from: text)
                let rowH = EditorWritingMetrics.rowHeight(fontSize: writingPointSize)
                let lineCount = max(1, text.split(separator: "\n", omittingEmptySubsequences: false).count)
                let estimated = CGFloat(lineCount) * rowH + 166
                if abs(rhymeOverlayHeight - estimated) > 0.5 {
                    rhymeOverlayHeight = max(rhymeOverlayHeight, estimated)
                }
            }
            .onChange(of: dynamicTypeSize) { _, _ in
                rebuildGutter(from: text)
            }
            .background {
                EditorKeyboardDismissProbe(
                    isKeyboardUp: isEditorFocused,
                    onDismiss: { isEditorFocused = false }
                )
            }
            .overlay(alignment: .topLeading) {
                if showGutter {
                    SyllableGutterOverlay(
                        counts: gutterCounts,
                        fontSize: writingPointSize,
                        textRevision: text,
                        preferOverlay: true,
                        showLineGuides: showWritingLines,
                        onHold: { onHoldSyllableLine?($0) },
                        onPressing: { onSyllablePressing?($0) }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .allowsHitTesting(true)
                    .accessibilityLabel("Syllable count buttons. Hold a count to highlight the bar, then let go to see similar bars.")
                }
            }
            .overlay(alignment: .topLeading) {
                CommaHintOverlay(text: text, enabled: commaHintsOn)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .allowsHitTesting(commaHintsOn)
                    .accessibilityElement(children: .contain)
            }
        }
    }

    // MARK: - Bottom Dynamic Island Toolbar (Page 3)
    private var bottomToolbar: some View {
        DynamicIslandToolbarView(
            isExpanded: $isToolbarExpanded,
            isRhymeOverlayVisible: rhymeEyeBinding,
            showDiagnostics: $showRhymeDiagnostics,
            rhymeGroups: rhymeGroups,
            currentText: item.body,
            highlights: computedHighlights,
            isEditorFocused: $isEditorFocused,
            keyboardHeight: $keyboardObserver.height,
            showRemindsMeOfPopover: $showRemindsMeOfPopover,
            remindsMeOfService: remindsMeOfService,
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
            canUndo: canUndoWriting,
            canRedo: canRedoWriting,
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
            item: item,
            onSamePocketNewNouns: handleSamePocketNewNouns,
            onShowNounBank: { showNounBank = true },
            techniqueOverlayOn: $techniqueOverlayOn,
            setupAndPunchOn: $setupAndPunchOn,
            onSelectEyeHighlight: selectEyeHighlight,
            onEnsureRhymes: { ensureEyeHighlight(.rhymes) },
            ghostModeRaw: $ghostModeRaw,
            showGhostPricing: $showGhostPricing,
            onGhostModeChange: applyGhostMode
        )
        .frame(maxWidth: 680)
    }

    // MARK: - Navigation Bar Toolbar Items (undo / redo / add menu)
    @ToolbarContentBuilder
    private var editorToolbarItems: some ToolbarContent {
        // Page 2 — the undo/redo/add pill drops its iOS 26 liquid-glass backdrop and sits
        // flat on the coral (the weak header coral made that platter read muddy gray).
        // The system back button is left intact so its swipe-back gesture keeps working.
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
            Button {
                HapticFeedbackManager.shared.lightTap()
                withAnimation(.easeInOut(duration: 0.2)) {
                    barClockStripVisible.toggle()
                }
            } label: {
                editorChromeIcon(barClockStripVisible ? "metronome.fill" : "metronome")
            }
            .buttonStyle(.plain)
            .accessibilityLabel(barClockStripVisible ? "Hide punch bar" : "Show punch bar")
            .accessibilityHint("Double tap to hide or show beats 1 through 4")

            Button {
                toggleBeatInfo()
            } label: {
                editorChromeIcon("waveform")
                    .overlay(alignment: .topTrailing) {
                        if beatInfoShowsDot {
                            Circle()
                                .fill(Momentum.accent)
                                .frame(width: 7, height: 7)
                                .offset(x: 1, y: 1)
                                .accessibilityIdentifier("beat-info-dot")
                        }
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Beat Info")
            .accessibilityHint(beatInfoExpanded
                ? "Hides tempo, key, scale, and bar length."
                : "Shows tempo, key, scale, and bar length under the title. They hide after a few seconds.")
            .accessibilityValue(beatInfoShowsDot ? "Tempo or key is set" : "")
            .accessibilityAddTraits(beatInfoExpanded ? .isSelected : AccessibilityTraits())

            Button {
                HapticFeedbackManager.shared.lightTap()
                handleUndo()
            } label: {
                editorChromeIcon("arrow.uturn.backward", faded: !canUndoWriting)
            }
            .buttonStyle(.plain)
            .disabled(!canUndoWriting)
            .accessibilityLabel("Undo")
            .accessibilityHint("Double tap to undo last change")

            Button {
                HapticFeedbackManager.shared.lightTap()
                handleRedo()
            } label: {
                editorChromeIcon("arrow.uturn.forward", faded: !canRedoWriting)
            }
            .buttonStyle(.plain)
            .disabled(!canRedoWriting)
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
                    showImportNotesInstructions = true
                } label: {
                    Label("Import from Notes", systemImage: "note.text")
                }

                Button {
                    presentAudioImporter()
                } label: {
                    Label("Attach audio", systemImage: "paperclip")
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
                editorChromeIcon("square.and.pencil")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Note menu")
            .accessibilityHint("Create a note, import from Notes, attach an mp3, m4a, wav, or aiff, record audio, or export")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .sharedBackgroundVisibility(hideToolbarGlass ? .hidden : .automatic)
    }

    private func editorChromeIcon(_ systemName: String, faded: Bool = false) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .semibold))
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Momentum.chromeIcon.opacity(faded ? 0.55 : 1))
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
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
        if oldValue != newValue, beatInfoExpanded {
            collapseBeatInfo()
        }
        if oldValue != newValue,
           remindsMeOfService.isScanning || remindsMeOfService.isFilling {
            dismissBarHits()
        }

        if isRhymeOverlayVisible,
           !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            armWritingTools()
        }

        // Track modification date when body changes
        if oldValue != newValue {
            item.modifiedDate = Date()
            item.refreshPreview()

            // Prune AI text ranges the edit pushed out of bounds. This used to run
            // inside computedHighlights and mutate item.aiTextRanges mid-render
            // ("Modifying state during view update"); doing it here is both safe and
            // more correct — ranges go stale exactly when the body changes.
            pruneInvalidAITextRanges()
        }

        refreshUndoButtons()

        if writingToolsArmed, isRhymeOverlayVisible {
            rhymeEngineState.updateIfNeeded(text: newValue)
        }

        if GhostMode(rawValue: ghostModeRaw) != .off,
           let landed = ghostDockWordJustUsed(old: oldValue, new: newValue) {
            flashGhostLanded(landed)
            if isRhymeOverlayVisible {
                Task { await rhymeEngineState.refreshImmediately(text: newValue) }
            }
        }

        // Ghost Bar: Free Ghost rhymes as you type. Cadence Ghost waits for a comma,
        // then fills punch halves from similar setups. Live Ghost hits the API on Enter.
        if GhostMode(rawValue: ghostModeRaw) != .off, !techniqueOverlayOn {
            let entered = GhostSuggestionEngine.didCompleteLineOrIndent(old: oldValue, new: newValue)
            let tookBreath = GhostSuggestionEngine.didTakeBreath(old: oldValue, new: newValue)
            let text = newValue
            let keepKeyboard = isEditorFocused
            let cadence = GhostMode(rawValue: ghostModeRaw) == .cadence
            // Comma: rhyme chips are wrong — swap to punch cards before the catalog returns.
            let hasBreath = GhostSuggestionEngine.breathSetup(
                in: GhostSuggestionEngine.lastNonEmptyLine(in: text) ?? ""
            ) != nil
            if cadence, tookBreath || (hasBreath && ghostPunches.isEmpty) {
                snapCadenceDock(from: text)
            }
            ghostTask?.cancel()
            ghostTask = Task { @MainActor in
                if !entered && !tookBreath {
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    if Task.isCancelled { return }
                }
                await refreshGhost(text: text, completed: entered)
                if keepKeyboard {
                    isEditorFocused = true
                    if EditorWritingMetrics.activeTextView?.isFirstResponder != true {
                        EditorWritingMetrics.activeTextView?.becomeFirstResponder()
                    }
                }
            }
        }
    }

    // Phase 4: Detect themes from lyrics for theme expansion auto-selection
    private func extractThemes(from text: String) -> [String] {
        ThemeIdentificationService.detectedThemeNames(in: text)
    }

    // MARK: - Ghost Bar

    @MainActor private func refreshGhost(text: String, completed: Bool) async {
        // Always the line being written. Comma is not Enter — justCompletedLine would
        // grab the previous bar in a verse and keep serving rhyme chips.
        let line = GhostSuggestionEngine.lastNonEmptyLine(in: text)
            ?? GhostSuggestionEngine.justCompletedLine(in: text)
        guard let line, !line.trimmingCharacters(in: .whitespaces).isEmpty else {
            // Enter on a blank next line must not wipe the chips or trap.
            if !completed { ghostHint = nil }
            isGhostSearching = false
            return
        }
        isGhostSearching = true
        var waitingOnAI = false
        let mode = GhostMode(rawValue: ghostModeRaw) ?? .off
        var liveWords: [String] = []
        let key = GhostSuggestionEngine.rhymeKey(forLastLine: line)
        let cadence = mode == .cadence
        var setup = cadence ? GhostSuggestionEngine.cadencePunchSetup(in: text, completed: completed) : nil
        if setup == nil, cadence, let held = ghostHeldSetup,
           GhostSuggestionEngine.stillPunching(in: text, heldSetup: held) {
            setup = held
        }
        if let setup {
            ghostHeldSetup = setup
        } else if cadence {
            ghostHeldSetup = nil
            ghostPunches = []
        }
        let pocket = setup.map { GhostSuggestionEngine.cadencePunchWrap(setup: $0, in: text) }
        let wrap = pocket?.punchWrap ?? 0
        let cacheKey = (key ?? "") + (cadence ? "|cadence|\(setup ?? "")|\(wrap)" : "|free")
        if cacheKey != ghostRhymeKey || ghostPool.isEmpty {
            let seed = line
            let fetched: (pool: [String], chips: [GhostPunchChip], solved: Bool) = await Task.detached(priority: .userInitiated) {
                if cadence, let setup {
                    if let cached = CadenceGhostCache.shared.chips(for: setup, wrap: wrap), cached.solved {
                        return (cached.chips.map(\.text), cached.chips, true)
                    }
                    let preferred = CadenceGhostCache.shared.punches(for: setup, wrap: wrap)?.preferred
                    let ranked = GhostSuggestionEngine.cadencePunchPool(setup: setup, limit: 24, preferred: preferred, wrap: wrap)
                    if !ranked.isEmpty {
                        CadenceGhostCache.shared.store(ranked, setup: setup, wrap: wrap, solved: false)
                        return (ranked.map(\.text), ranked, false)
                    }
                    if let cached = CadenceGhostCache.shared.chips(for: setup, wrap: wrap), !cached.chips.isEmpty {
                        return (cached.chips.map(\.text), cached.chips, false)
                    }
                    return ([], [], false)
                }
                if cadence {
                    return ([], [], false)
                }
                let words = GhostSuggestionEngine.freeRhymePool(forLastLine: seed, limit: 40, matchCadence: false)
                return (words, [], false)
            }.value
            if Task.isCancelled {
                isGhostSearching = false
                return
            }
            if fetched.chips.isEmpty, cadence, setup != nil, !ghostPunches.isEmpty {
                // Keep the instant comma snap; don't flash rhyme chips or an empty dock.
            } else {
                ghostPool = fetched.pool
                ghostPunches = fetched.chips
            }
            ghostTargetWrap = wrap
            ghostRhymeKey = cacheKey
            // Skip the network once this setup+wrap is already solved locally.
            if cadence, let setup, !fetched.solved, KeychainHelper.shared.getAPIKey() != nil {
                let catalog = fetched.pool
                let held = cacheKey
                waitingOnAI = true
                Task { @MainActor in
                    defer { if ghostRhymeKey == held { isGhostSearching = false } }
                    guard let ai = try? await ModelGLLMService.shared.cadencePunches(
                        setup: setup,
                        targetSyllables: max(wrap, 4),
                        catalogHints: catalog
                    ), !ai.isEmpty else { return }
                    let fitted = ai.filter {
                        abs(LineSyllableCounter.syllableCount(forLine: $0) - max(wrap, 4)) <= 3
                    }
                    let polished = fitted.isEmpty ? ai : fitted
                    let aiChips = GhostSuggestionEngine.chips(fromTexts: polished, wrap: wrap)
                    CadenceGhostCache.shared.store(aiChips + ghostPunches, setup: setup, wrap: wrap, solved: true)
                    guard ghostRhymeKey == held else { return }
                    var seen = Set<String>()
                    var mergedChips: [GhostPunchChip] = []
                    for chip in aiChips + ghostPunches {
                        let k = chip.text.lowercased()
                        guard seen.insert(k).inserted else { continue }
                        mergedChips.append(chip)
                    }
                    mergedChips = GhostSuggestionEngine.fittingPunches(
                        GhostSuggestionEngine.collapsePunchDupes(mergedChips),
                        wrap: wrap
                    )
                    ghostPunches = mergedChips
                    ghostPool = mergedChips.map(\.text)
                    let next = GhostHint(candidates: ghostPool, punches: mergedChips, tail: nil, targetWrap: wrap)
                    guard next != ghostHint else { return }
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        ghostHint = next
                    }
                }
            }
        }
        // End rhymes + AI keeps the on-phone list and adds a larger set the model has to
        // find on top of it. A pause on the same end word reuses the last answer.
        if mode == .live, KeychainHelper.shared.getAPIKey() != nil,
           let end = GhostSuggestionEngine.endWord(of: line), end.count >= 3 {
            let topic = item.title.isEmpty ? "rap verse" : item.title
            let liveKey = "\(end.lowercased())|\(topic.lowercased())"
            if let cached = liveRhymeCache[liveKey] {
                liveWords = cached
            } else if liveRhymeInflightKey != liveKey {
                liveRhymeInflightKey = liveKey
                let avoid = ghostPool
                let heldEnd = end
                waitingOnAI = true
                Task { @MainActor in
                    defer {
                        if liveRhymeInflightKey == liveKey { liveRhymeInflightKey = nil }
                        let stillHere = GhostSuggestionEngine.endWord(
                            of: GhostSuggestionEngine.lastNonEmptyLine(in: item.body) ?? ""
                        ) == heldEnd
                        if stillHere { isGhostSearching = false }
                    }
                    guard let words = try? await liveGhostWords(lastLine: line, avoid: avoid),
                          !words.isEmpty else { return }
                    liveRhymeCache[liveKey] = words
                    if liveRhymeCache.count > 24 {
                        liveRhymeCache = [liveKey: words]
                    }
                    let currentEnd = GhostSuggestionEngine.endWord(
                        of: GhostSuggestionEngine.lastNonEmptyLine(in: item.body) ?? ""
                    )
                    guard currentEnd == heldEnd else { return }
                    let merged = Self.liveWordsFirst(words, onto: ghostPool)
                    let next = GhostHint(
                        candidates: merged,
                        punches: ghostPunches,
                        tail: nil,
                        targetWrap: ghostTargetWrap == 0 ? nil : ghostTargetWrap
                    )
                    guard next != ghostHint else { return }
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) { ghostHint = next }
                }
            }
        }
        // Keep the long catalog list. Live words go in front, not instead of it.
        var chips = ghostPool
        if !liveWords.isEmpty {
            chips = Self.liveWordsFirst(liveWords, onto: ghostPool)
        }
        let next: GhostHint?
        if chips.isEmpty, cadence, setup != nil {
            next = ghostHint
        } else if chips.isEmpty {
            next = nil
        } else {
            next = GhostHint(candidates: chips, punches: ghostPunches, tail: nil, targetWrap: ghostTargetWrap == 0 ? nil : ghostTargetWrap)
        }
        if !waitingOnAI { isGhostSearching = false }
        // Re-assigning an identical hint rebuilds the inset and drops the keyboard.
        guard next != ghostHint else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            ghostHint = next
        }
    }

    private func liveGhostWords(lastLine: String, avoid: [String]) async throws -> [String] {
        guard let end = GhostSuggestionEngine.endWord(of: lastLine), end.count >= 3 else { return [] }
        let topic = item.title.isEmpty ? "rap verse" : item.title
        let words = try await ModelGLLMService.shared.ghostRhymes(
            rhymeWith: end,
            topic: topic,
            line: lastLine,
            avoid: avoid
        )
        var seen = Set<String>()
        var out: [String] = []
        for raw in words {
            let key = raw.lowercased()
            guard seen.insert(key).inserted else { continue }
            guard key != end else { continue }
            guard !GhostSuggestionEngine.isDictionarySpellingVariant(key, of: end) else { continue }
            guard RhymeFinder.isUsableRhymeHeadword(key) else { continue }
            out.append(raw)
            if out.count == 16 { break }
        }
        return out
    }

    private static func liveWordsFirst(_ live: [String], onto pool: [String]) -> [String] {
        var seen = Set(live.map { $0.lowercased() })
        return live + pool.filter { seen.insert($0.lowercased()).inserted }
    }

    private var ghostTypingPrefix: String? {
        guard GhostMode(rawValue: ghostModeRaw) != .off, ghostHint != nil else { return nil }
        guard let token = RhymeHighlighterEngine.trailingInProgressWord(in: item.body)?.0 else { return nil }
        return token
    }

    /// Swap rhyme chips for punch cards on the same runloop as the comma.
    private func snapCadenceDock(from text: String) {
        guard let setup = GhostSuggestionEngine.cadencePunchSetup(in: text, completed: false)
            ?? GhostSuggestionEngine.breathSetup(in: GhostSuggestionEngine.lastNonEmptyLine(in: text) ?? "")
        else { return }
        ghostHeldSetup = setup
        let wrap = GhostSuggestionEngine.cadencePunchWrap(setup: setup, in: text).punchWrap
        ghostTargetWrap = wrap
        let chips = GhostSuggestionEngine.instantCadenceChips(setup: setup, wrap: wrap)
        ghostPunches = chips
        ghostPool = chips.map(\.text)
        isGhostSearching = chips.isEmpty
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            ghostHint = GhostHint(
                candidates: ghostPool,
                punches: chips,
                tail: nil,
                targetWrap: wrap
            )
        }
    }

    private func insertGhostWord(_ word: String) {
        let cadence = GhostMode(rawValue: ghostModeRaw) == .cadence
        let setup = cadence
            ? (GhostSuggestionEngine.cadencePunchSetup(in: item.body, completed: false) ?? ghostHeldSetup)
            : nil
        item.body = GhostSuggestionEngine.insertingCandidate(word, into: item.body, asPunchBar: setup != nil)
        item.modifiedDate = Date()
        if cadence, let setup {
            ghostHeldSetup = setup
            let wrap = GhostSuggestionEngine.cadencePunchWrap(setup: setup, in: item.body).punchWrap
            CadenceGhostCache.shared.prefer(word, setup: setup, wrap: wrap)
            ghostPunches = ghostPunches.map { chip in
                var next = chip
                next.preferred = CadenceGhostCache.normalize(chip.text) == CadenceGhostCache.normalize(word)
                return next
            }
            if let idx = ghostPunches.firstIndex(where: { $0.preferred }) {
                let hit = ghostPunches.remove(at: idx)
                ghostPunches.insert(hit, at: 0)
            }
            ghostPool = ghostPunches.map(\.text)
            ghostHint = GhostHint(
                candidates: ghostPool,
                punches: ghostPunches,
                tail: nil,
                targetWrap: wrap
            )
        }
        flashGhostLanded(word)
        if isRhymeOverlayVisible {
            rhymeEngineState.updateIfNeeded(text: item.body)
            Task { await rhymeEngineState.refreshImmediately(text: item.body) }
        }
    }

    /// Dock word completed in the editor (last letter of `sum`, or a space after it).
    private func ghostDockWordJustUsed(old: String, new: String) -> String? {
        guard let candidates = ghostHint?.candidates, !candidates.isEmpty else { return nil }
        func match(_ token: String?) -> String? {
            guard let token, token.count >= 2 else { return nil }
            return candidates.first { $0.caseInsensitiveCompare(token) == .orderedSame }
        }
        let newToken = RhymeHighlighterEngine.trailingInProgressWord(in: new)?.0
        let oldToken = RhymeHighlighterEngine.trailingInProgressWord(in: old)?.0
        if let hit = match(newToken), hit.caseInsensitiveCompare(oldToken ?? "") != .orderedSame {
            return hit
        }
        if new.hasSuffix(" ") || new.hasSuffix("\n"),
           let hit = match(GhostSuggestionEngine.endWord(of: GhostSuggestionEngine.lastNonEmptyLine(in: new) ?? new)),
           hit.caseInsensitiveCompare(oldToken ?? "") != .orderedSame {
            return hit
        }
        return nil
    }

    private func flashGhostLanded(_ word: String) {
        HapticFeedbackManager.shared.lightTap()
        ghostLandedTask?.cancel()
        withAnimation(.spring(response: 0.34, dampingFraction: 0.68)) {
            ghostLandedWord = word
        }
        let captured = word
        ghostLandedTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_250_000_000)
            if Task.isCancelled { return }
            if ghostLandedWord?.caseInsensitiveCompare(captured) == .orderedSame {
                withAnimation(.easeOut(duration: 0.22)) {
                    ghostLandedWord = nil
                }
            }
        }
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
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    bpmPillMenu
                    keyPillMenu
                    scalePillMenu
                    syllablesPillMenu
                    urlPillMenu
                    folderPillMenu
                }
                .padding(.leading, 16)
                .padding(.trailing, 36) // peek of the last pill so the row reads as a carousel
                .frame(minHeight: 44)
                .contentShape(Rectangle())
                .buttonStyle(.plain)
            }
            .frame(width: geo.size.width)
            .scrollBounceBehavior(.always)
            .background(HorizontalPillScrollFix())
            .background(BeatInfoMenuProbe(menuOpen: $beatInfoMenuOpen))
            .simultaneousGesture(TapGesture().onEnded { noteBeatInfoRowTouched() })
            .simultaneousGesture(
                DragGesture(minimumDistance: 12).onChanged { _ in
                    noteBeatInfoRowTouched()
                }
            )
            .accessibilityIdentifier("beat-info-row")
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - BPM Pill Menu
    private var bpmPillMenu: some View {
        Menu {
            if item.audioPath != nil {
                Button {
                    beatPreview.toggle(path: item.audioPath, bpm: item.bpm)
                } label: {
                    Label(beatPreview.isPlaying ? "Pause beat" : "Play attached beat",
                          systemImage: beatPreview.isPlaying ? "pause.fill" : "play.fill")
                }
                Divider()
            }
            Section("Hip-hop") {
                bpmQuickPick(80)
                bpmQuickPick(90)
                bpmQuickPick(100)
            }
            Section("R&B / pop") {
                bpmQuickPick(110)
                bpmQuickPick(120)
                bpmQuickPick(128)
            }
            Section("Trap") {
                bpmQuickPick(140)
                bpmQuickPick(150)
                bpmQuickPick(160)
                bpmQuickPick(180)
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
                icon: beatPreview.isPlaying ? "pause.fill" : "metronome",
                label: bpmPillLabel,
                isSet: item.bpm != nil || beatPreview.isPlaying
            )
        }
        .accessibilityLabel(bpmPillLabel)
        .accessibilityHint(item.audioPath != nil
                           ? "Opens beat settings. Play the attached beat is the first item."
                           : "Opens beat settings, same as the other pills.")
    }

    @ViewBuilder
    private func bpmQuickPick(_ bpmValue: Int) -> some View {
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
                label: item.key ?? "Key",
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
                label: item.scale ?? "Scale",
                isSet: item.scale != nil
            )
        }
    }
    
    // MARK: - Syllables Pill Menu
    private var syllablesPillMenu: some View {
        Menu {
            ForEach(SyllableCountButtonMetrics.quickSelectCounts, id: \.self) { count in
                Button {
                    item.syllableMin = count
                    item.syllableMax = count
                } label: {
                    HStack {
                        Text("\(count) syllables")
                        Spacer()
                        if SyllableCountButtonMetrics.isExactCount(count, min: item.syllableMin, max: item.syllableMax) {
                            Image(systemName: "checkmark").font(.caption.weight(.semibold))
                        }
                    }
                }
            }
            Divider()
            Button { showSyllablesPopover = true } label: {
                Label("Custom range", systemImage: "slider.horizontal.3")
            }
            if item.syllableMin != nil || item.syllableMax != nil {
                Divider()
                Button(role: .destructive) {
                    item.syllableMin = nil; item.syllableMax = nil
                } label: { Label("Auto", systemImage: "xmark.circle") }
            }
        } label: {
            metadataPillLabel(
                icon: "textformat.size",
                label: syllablesPillLabel,
                isSet: item.syllableMin != nil || item.syllableMax != nil
            )
        }
        .accessibilityLabel(syllablesPillLabel)
        .accessibilityHint("Opens syllable count buttons. Tap a number to aim every bar at that length.")
    }

    private var syllablesPillLabel: String {
        SyllableCountButtonMetrics.pillLabel(min: item.syllableMin, max: item.syllableMax)
    }

    private var writeClock: BarClock {
        BarClock.resolve(userBPM: item.bpm)
    }

    private var bpmPillLabel: String {
        guard let raw = item.bpm else { return "BPM" }
        if writeClock.hatsFolded {
            return "\(raw) → \(Int(writeClock.bpm.rounded()))"
        }
        return "\(raw) BPM"
    }

    private var barClockStripOn: Bool {
        barClockStripVisible && (item.bpm != nil || beatPreview.isPlaying)
    }

    private var showsBarClockStatusCaption: Bool {
        beatPreview.isPlaying || writeClock.hatsFolded
    }

    private var punchBeats: Set<Int> {
        BarClock.punchBeats(from: punchBeatsRaw)
    }

    private func togglePunchBeat(_ beat: Int) {
        HapticFeedbackManager.shared.lightTap()
        punchBeatsRaw = BarClock.encodePunchBeats(BarClock.togglingPunch(punchBeats, beat: beat))
    }

    private var barClockCaption: String {
        if beatPreview.isPlaying {
            if writeClock.hatsFolded, let raw = item.bpm {
                return "Playing \(raw) — write at \(Int(writeClock.bpm.rounded()))"
            }
            return "Playing the attached beat"
        }
        if writeClock.hatsFolded, let raw = item.bpm {
            return "Write at \(Int(writeClock.bpm.rounded())) — hats are 2× (\(raw))"
        }
        return "Punch on 3 and 4"
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
                label: item.folder ?? "Folder",
                isSet: item.folder != nil
            )
        }
    }
    
    // MARK: - Metadata Pill Label Component
    @ViewBuilder
    private func metadataPillLabel(icon: String, label: String, isSet: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.callout.weight(.semibold))
                .symbolRenderingMode(.monochrome)
            Text(label)
                .font(.callout.weight(.semibold))
        }
        .chromeClamp()   // editor metadata pills live in a horizontal-scroll row — cap Dynamic Type
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .foregroundStyle(Momentum.chromeIcon)
        .momentumLiquidGlass(in: Capsule())
        .overlay(
            Capsule().strokeBorder(
                isSet ? Momentum.accent : Color.clear,
                lineWidth: Momentum.lineThin
            )
        )
        // Metadata-arrived toast: coral glow ring + halo for ~4s (see triggerMetadataGlow).
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Momentum.accent.opacity(metadataGlow ? 0.9 : 0), lineWidth: metadataGlow ? 1.6 : 0)
        )
        .shadow(color: metadataGlow ? Momentum.accent.opacity(0.7) : .clear, radius: metadataGlow ? 8 : 0)
        .animation(.easeInOut(duration: 0.45), value: metadataGlow)
    }

    /// A saved tempo or key, while the row is hidden, marks the Beat Info icon.
    private var beatInfoShowsDot: Bool {
        guard !beatInfoExpanded else { return false }
        if item.bpm != nil { return true }
        if let key = item.key?.trimmingCharacters(in: .whitespacesAndNewlines), !key.isEmpty {
            return true
        }
        return false
    }

    /// Sheets and the open pill menu keep the row up. The 4 second hide waits until they close.
    private var beatInfoSuppressesHide: Bool {
        beatInfoMenuOpen
            || showBPMPopover
            || showKeyPopover
            || showScalePopover
            || showURLPopover
            || showSyllablesPopover
            || showFolderPopover
    }

    private var beatInfoHideToken: String {
        "\(beatInfoGeneration)-\(beatInfoExpanded)-\(beatInfoSuppressesHide)"
    }

    private func toggleBeatInfo() {
        HapticFeedbackManager.shared.lightTap()
        if beatInfoExpanded {
            collapseBeatInfo()
        } else {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                beatInfoExpanded = true
            }
            beatInfoGeneration += 1
        }
    }

    private func collapseBeatInfo() {
        beatInfoGeneration += 1
        beatInfoMenuOpen = false
        guard beatInfoExpanded else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
            beatInfoExpanded = false
        }
    }

    /// A tap or scroll in the pill row starts the 4 second hide over.
    private func noteBeatInfoRowTouched() {
        guard beatInfoExpanded, !beatInfoSuppressesHide else { return }
        let now = Date()
        guard now.timeIntervalSince(beatInfoLastTouch) > 0.25 else { return }
        beatInfoLastTouch = now
        beatInfoGeneration += 1
    }

    /// Pulse the metadata pills with a coral glow for ~4s to toast that fresh
    /// BPM/key/scale just arrived from audio analysis.
    private func triggerMetadataGlow() {
        withAnimation(.easeInOut(duration: 0.45)) { metadataGlow = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.55)) { metadataGlow = false }
        }
    }

    private func prepareHapticForNewNote() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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
    /// The note menu has to finish dismissing before the file picker can present.
    private func presentAudioImporter() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            showAudioImporter = true
        }
    }

    private static let noteAudioExtensions: Set<String> = ["mp3", "m4a", "wav", "aiff", "aif"]
    private static let unsupportedAudioMessage = "That file isn't audio. Use an mp3, m4a, wav, or aiff, or drop text to insert lyrics."

    private func handleAudioImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let ext = url.pathExtension.lowercased()
            guard Self.noteAudioExtensions.contains(ext) else {
                audioAttachError = Self.unsupportedAudioMessage
                return
            }
            guard url.startAccessingSecurityScopedResource() else {
                audioAttachError = "Couldn't open that file."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            let temp = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)
            do {
                try FileManager.default.copyItem(at: url, to: temp)
                stageAudio(from: temp, suggestedName: url.lastPathComponent)
            } catch {
                audioAttachError = "Couldn't copy that audio file."
            }
        case .failure(let error):
            audioAttachError = error.localizedDescription
        }
    }

    /// Drag-and-drop and the text view's drop interaction both call this.
    /// The short gap keeps one drop from attaching the file twice.
    private func receiveEditorDrop(_ providers: [NSItemProvider]) {
        let now = Date()
        if let last = lastEditorDropAt, now.timeIntervalSince(last) < 0.4 { return }
        guard !providers.isEmpty else { return }
        lastEditorDropAt = now
        if let audio = providers.first(where: providerIsAudio) {
            loadDroppedAudio(audio)
            return
        }
        if let file = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) {
            loadDroppedFileURL(file)
            return
        }
        if let text = providers.first(where: providerIsText) {
            loadDroppedText(text)
            return
        }
        audioAttachError = Self.unsupportedAudioMessage
    }

    private func providerIsAudio(_ provider: NSItemProvider) -> Bool {
        let identifiers = [
            UTType.audio.identifier,
            UTType.mp3.identifier,
            UTType.mpeg4Audio.identifier,
            UTType.wav.identifier,
            UTType.aiff.identifier
        ]
        if identifiers.contains(where: { provider.hasItemConformingToTypeIdentifier($0) }) {
            return true
        }
        return provider.registeredTypeIdentifiers.contains { identifier in
            guard let type = UTType(identifier) else { return false }
            return type.conforms(to: .audio)
        }
    }

    private func providerIsText(_ provider: NSItemProvider) -> Bool {
        provider.hasItemConformingToTypeIdentifier(UTType.utf8PlainText.identifier)
            || provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier)
            || provider.hasItemConformingToTypeIdentifier(UTType.text.identifier)
    }

    private func audioTypeIdentifier(for provider: NSItemProvider) -> String {
        let preferred: [UTType] = [.mp3, .mpeg4Audio, .wav, .aiff, .audio]
        for type in preferred where provider.hasItemConformingToTypeIdentifier(type.identifier) {
            return type.identifier
        }
        return UTType.audio.identifier
    }

    private func loadDroppedAudio(_ provider: NSItemProvider) {
        let type = audioTypeIdentifier(for: provider)
        provider.loadFileRepresentation(forTypeIdentifier: type) { url, _ in
            guard let url else {
                Task { @MainActor in
                    self.audioAttachError = "Couldn't read that audio file."
                }
                return
            }
            let ext = url.pathExtension.isEmpty ? "m4a" : url.pathExtension
            let temp = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)
            let name = url.lastPathComponent
            do {
                try FileManager.default.copyItem(at: url, to: temp)
                Task { @MainActor in
                    self.stageAudio(from: temp, suggestedName: name)
                }
            } catch {
                Task { @MainActor in
                    self.audioAttachError = "Couldn't read that audio file."
                }
            }
        }
    }

    private func loadDroppedFileURL(_ provider: NSItemProvider) {
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            let url: URL?
            if let found = item as? URL {
                url = found
            } else if let data = item as? Data {
                url = URL(dataRepresentation: data, relativeTo: nil)
            } else {
                url = nil
            }
            guard let url else {
                Task { @MainActor in
                    self.audioAttachError = Self.unsupportedAudioMessage
                }
                return
            }
            let ext = url.pathExtension.lowercased()
            if Self.noteAudioExtensions.contains(ext) {
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                let temp = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(ext)
                do {
                    try FileManager.default.copyItem(at: url, to: temp)
                    let name = url.lastPathComponent
                    Task { @MainActor in
                        self.stageAudio(from: temp, suggestedName: name)
                    }
                } catch {
                    Task { @MainActor in
                        self.audioAttachError = "Couldn't read that audio file."
                    }
                }
            } else if ext == "txt" || ext == "text" {
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                let raw = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                let plain = LyricPlainText.normalizeLineBreaks(raw)
                Task { @MainActor in
                    if plain.isEmpty {
                        self.audioAttachError = Self.unsupportedAudioMessage
                    } else {
                        self.insertDroppedText(plain)
                    }
                }
            } else {
                Task { @MainActor in
                    self.audioAttachError = Self.unsupportedAudioMessage
                }
            }
        }
    }

    private func loadDroppedText(_ provider: NSItemProvider) {
        let type: String
        if provider.hasItemConformingToTypeIdentifier(UTType.utf8PlainText.identifier) {
            type = UTType.utf8PlainText.identifier
        } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            type = UTType.plainText.identifier
        } else {
            type = UTType.text.identifier
        }
        provider.loadItem(forTypeIdentifier: type, options: nil) { item, _ in
            let raw: String?
            if let string = item as? String {
                raw = string
            } else if let data = item as? Data {
                raw = String(data: data, encoding: .utf8)
            } else if let url = item as? URL {
                raw = try? String(contentsOf: url, encoding: .utf8)
            } else {
                raw = nil
            }
            let plain = LyricPlainText.normalizeLineBreaks(raw ?? "")
            Task { @MainActor in
                if plain.isEmpty {
                    self.audioAttachError = Self.unsupportedAudioMessage
                } else {
                    self.insertDroppedText(plain)
                }
            }
        }
    }

    private func insertDroppedText(_ plain: String) {
        let text = LyricPlainText.normalizeLineBreaks(plain)
        guard !text.isEmpty else { return }
        if let textView = EditorWritingMetrics.activeTextView {
            if !textView.isFirstResponder {
                _ = textView.becomeFirstResponder()
            }
            let target = textView.selectedTextRange
                ?? textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
            if let target {
                let undo = textView.undoManager
                undo?.beginUndoGrouping()
                textView.replace(target, withText: text)
                undo?.endUndoGrouping()
                return
            }
        }
        if item.body.isEmpty {
            item.body = text
        } else if item.body.hasSuffix("\n") {
            item.body += text
        } else {
            item.body += "\n" + text
        }
        item.modifiedDate = Date()
    }

    private func stageAudio(from source: URL, suggestedName: String) {
        let ext = source.pathExtension.lowercased()
        guard Self.noteAudioExtensions.contains(ext) else {
            try? FileManager.default.removeItem(at: source)
            audioAttachError = Self.unsupportedAudioMessage
            return
        }
        if let existing = item.audioPath, !existing.isEmpty {
            pendingAudioURL = source
            pendingAudioName = suggestedName
            showReplaceAudioConfirm = true
        } else {
            commitAudio(from: source, suggestedName: suggestedName)
        }
    }

    private func commitAudio(from source: URL, suggestedName: String) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            audioAttachError = "Couldn't save that audio on this note."
            try? fileManager.removeItem(at: source)
            return
        }
        let noteFolder = documentsURL
            .appendingPathComponent("NoteAudio", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        do {
            try fileManager.createDirectory(at: noteFolder, withIntermediateDirectories: true)
            let fileName = sanitizedAudioFileName(suggestedName, fallbackExtension: source.pathExtension)
            let destination = noteFolder.appendingPathComponent(fileName)
            try fileManager.copyItem(at: source, to: destination)
            removePreviousNoteAudioIfOwned()
            item.audioPath = destination.path
            item.audioDuration = nil
            item.bpm = nil
            item.key = nil
            item.scale = nil
            item.transcription = nil
            item.transcriptionSegments = nil
            item.audioSummary = nil
            item.modifiedDate = Date()
            try? fileManager.removeItem(at: source)
            try? item.modelContext?.save()
            Task { await processImportedAudio(url: destination) }
        } catch {
            audioAttachError = "Couldn't save that audio on this note."
            try? fileManager.removeItem(at: source)
        }
    }

    private func sanitizedAudioFileName(_ suggested: String, fallbackExtension: String) -> String {
        let base = URL(fileURLWithPath: suggested).lastPathComponent
            .replacingOccurrences(of: "/", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if base.isEmpty || base == "." || base == ".." {
            let ext = fallbackExtension.isEmpty ? "m4a" : fallbackExtension
            return "audio.\(ext)"
        }
        return base
    }

    /// Deletes a file this note copied into NoteAudio. Leaves older shared copies alone.
    private func removePreviousNoteAudioIfOwned() {
        guard let old = item.audioPath, old.contains("/NoteAudio/") else { return }
        let oldURL = URL(fileURLWithPath: old)
        let parent = oldURL.deletingLastPathComponent()
        if parent.lastPathComponent != "NoteAudio" {
            try? FileManager.default.removeItem(at: parent)
        } else {
            try? FileManager.default.removeItem(at: oldURL)
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
            let result = try await AudioTranscriptionService().transcribe(audioURL: url)
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
        presentRhymes(for: word, utf16Range: nil)
    }

    private func holdPulseHighlights(in text: String) -> [Highlight] {
        var out: [Highlight] = []
        if let index = pulseLineIndex,
           let ns = utf16RangeForLine(index, in: text),
           let range = Range(ns, in: text), !range.isEmpty {
            out.append(Highlight(range: range, in: text, colorIndex: 0, strength: .perfect, rhymeType: .holdPulseYellow))
        }
        if let ns = pulseWordUTF16, let range = Range(ns, in: text), !range.isEmpty {
            out.append(Highlight(range: range, in: text, colorIndex: 2, strength: .perfect, rhymeType: .holdPulseGreen))
        }
        return out
    }

    private func utf16RangeForLine(_ index: Int, in text: String) -> NSRange? {
        LineSyllableCounter.utf16RangeForLine(index, in: text)
    }

    private func clearHoldPulse() {
        if let index = pulseLineIndex,
           let textView = EditorWritingMetrics.activeTextView,
           let range = LineSyllableCounter.utf16RangeForLine(index, in: textView.text ?? ""),
           range.location + range.length <= textView.textStorage.length {
            textView.textStorage.removeAttribute(.backgroundColor, range: range)
        }
        rhymePaintEpoch += 1
        holdPulseLocked = false
        pulseLineIndex = nil
        pulseWordUTF16 = nil
    }

    private func dismissBarHits() {
        remindsMeOfService.cancelHeldLookup()
        clearHoldPulse()
        if showRemindsMeOfPopover {
            showRemindsMeOfPopover = false
        }
    }

    private func handleEditorSelectionChange() {
        guard isEditorFocused else { return }
        guard remindsMeOfService.isScanning || remindsMeOfService.isFilling else { return }
        let now = EditorWritingMetrics.activeTextView?.selectedRange
        if let anchor = barHitsSelectionAnchor, let now,
           now.location == anchor.location, now.length == anchor.length {
            return
        }
        dismissBarHits()
    }

    private func handleSyllablePressing(_ index: Int?) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            if let index {
                if pulseLineIndex != index {
                    pulseLineIndex = index
                }
            } else if !holdPulseLocked {
                pulseLineIndex = nil
            }
        }
    }

    private func handleHoldSyllableLine(_ index: Int) {
        let lines = item.body.split(separator: "\n", omittingEmptySubsequences: false)
        guard index >= 0, index < lines.count else { return }
        let line = String(lines[index])
        let syllables = LineSyllableCounter.syllableCount(forLine: line)
        guard syllables > 0 else { return }
        armWritingTools()
        holdPulseLocked = true
        pulseLineIndex = index
        guard barHitsOpensFromHold else {
            clearHoldPulse()
            return
        }
        barHitsSelectionAnchor = EditorWritingMetrics.activeTextView?.selectedRange
        showRemindsMeOfPopover = true
        let prior: [String] = {
            let spans = RemindsMeOfScorer.lineSpans(in: item.body).map(\.text)
            if let idx = spans.firstIndex(of: line) {
                return Array(spans[..<idx].suffix(8))
            }
            return Array(spans.suffix(8))
        }()
        remindsMeOfService.startHeldLookup(line: line, syllables: syllables, priorNoteLines: prior)
    }

    private func handleWordHoldPreview(_ word: String, range: NSRange) {
        let cleaned = word.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
        guard cleaned.count >= 2 else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            pulseWordUTF16 = range
        }
        tappedWordUTF16Range = range
        targetWordForRhymes = cleaned
    }

    private func handleWordHoldBegan(_ word: String, range: NSRange) {
        handleWordHoldPreview(word, range: range)
    }

    private func handleWordHoldEnded(_ word: String, range: NSRange) {
        let cleaned = word.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
        guard cleaned.count >= 2 else { return }
        holdPulseLocked = true
        if pulseWordUTF16 == nil {
            pulseWordUTF16 = range
        }
        presentRhymes(for: cleaned, utf16Range: range)
    }

    private func handleTappedWord(_ word: String, range: NSRange) {
        if let match = remindsMeOfService.match(containingUTF16: range.location) {
            lightHaptic()
            selectedGeniusMatch = match
            showGeniusLineHits = true
            isEditorFocused = false
        }
    }

    private func presentRhymes(for word: String, utf16Range: NSRange?) {
        let cleaned = word.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
        guard !cleaned.isEmpty else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isEditorFocused = false
        }
        tappedWordUTF16Range = utf16Range
        if targetWordForRhymes != cleaned || lastWordRhymes.isEmpty {
            lastWordRhymes = RhymeFinder.findRhymes(for: cleaned, limit: 160)
            targetWordForRhymes = cleaned
        }
        showRhymeSuggestions = true
    }

    private func insertNounBankWord(_ word: String) {
        if let tv = EditorWritingMetrics.activeTextView {
            let range = tv.selectedRange
            let ns = item.body as NSString
            let loc = min(max(0, range.location), ns.length)
            item.body = ns.replacingCharacters(in: NSRange(location: loc, length: 0), with: word + " ")
        } else {
            let prefix = item.body.isEmpty || item.body.hasSuffix(" ") || item.body.hasSuffix("\n") ? "" : " "
            item.body += prefix + word + " "
        }
        item.modifiedDate = Date()
        isEditorFocused = true
    }

    private func handleSamePocketNewNouns() {

        guard UsageTracker.shared.canUseAISuggestion() else {
            paywallFeature = "AI Suggestions"
            showPaywall = true
            return
        }
        UsageTracker.shared.trackAISuggestion()
        runModelGGenerate(directedParams: DirectedGenerationParams.samePocketNewNouns())
    }
    
    private func insertRhymeWord(_ word: String) {
        if let nsRange = tappedWordUTF16Range,
           let swiftRange = Range(nsRange, in: item.body) {
            item.body.replaceSubrange(swiftRange, with: word)
            item.modifiedDate = Date()
            tappedWordUTF16Range = nil
            showRhymeSuggestions = false
            return
        }
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
    private func refreshUndoButtons() {
        let manager = EditorWritingMetrics.activeTextView?.undoManager
        let undo = manager?.canUndo ?? false
        let redo = manager?.canRedo ?? false
        if canUndoWriting != undo { canUndoWriting = undo }
        if canRedoWriting != redo { canRedoWriting = redo }
    }

    private func handleUndo() {
        guard let manager = EditorWritingMetrics.activeTextView?.undoManager, manager.canUndo else { return }
        lightHaptic()
        manager.undo()
        item.modifiedDate = Date()
        refreshUndoButtons()
    }
    
    private func handleRedo() {
        guard let manager = EditorWritingMetrics.activeTextView?.undoManager, manager.canRedo else { return }
        lightHaptic()
        manager.redo()
        item.modifiedDate = Date()
        refreshUndoButtons()
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
                description: "Pull in audio, photos, or notes — or record straight into your entry.",
                icon: "paperclip"
            )
        case .toolbarAISparkle:
            return (
                title: "AI Writing Assistant",
                description: "Your AI co-writer — next lines, rewrites, rhyme ideas, and flow help, powered by your own key.",
                icon: "sparkles"
            )
        case .toolbarUndoRedo:
            return (
                title: "Undo & Redo",
                description: "Step back or forward through your edits anytime.",
                icon: "arrow.uturn.backward"
            )
        case .toolbarEyeToggle:
            return (
                title: "Highlighting",
                description: "Tap the eye for Rhymes, Setup and punch, and Techniques. Turn on more than one. Setup and punch paints green setup and red punch, and can offer breath commas on lines long enough for them. Techniques paints inner rhyme on a heat scale.",
                icon: "eye"
            )
        case .toolbarMagnifyingGlass:
            return (
                title: "Rhyme Groups",
                description: "See every rhyme family in your verse and explore related words.",
                icon: "text.magnifyingglass"
            )
        case .toolbarGhost:
            return (
                title: "Meet the Ghost",
                description: "End rhymes lists words that rhyme with the last word as you type, on this phone. End rhymes + AI keeps that list and adds a longer set from your key once you pause on a word. Line completions finishes the bar from the catalog after a comma.",
                icon: "sparkles"
            )
        case .toolbarDiagnostics:
            return (
                title: "Rhyme Diagnostics",
                description: "Break down syllables, stress, cadence, and flow for your verse.",
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
        case .toolbarGhost:
            buttonIndex = 6
        case .toolbarDiagnostics:
            buttonIndex = 7
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

/// Draws one syllable-count button per Enter-line in the left gutter.
/// Hold highlights the bar yellow; let go opens similar-bar hits.
private struct SyllableGutterOverlay: UIViewRepresentable {
    var counts: [Int]
    var fontSize: CGFloat
    var textRevision: String
    var preferOverlay: Bool
    var showLineGuides: Bool
    var onHold: (Int) -> Void
    var onPressing: (Int?) -> Void

    func makeUIView(context: Context) -> Host {
        let host = Host()
        host.backgroundColor = .clear
        host.isOpaque = false
        host.clipsToBounds = false
        host.fontSize = fontSize
        host.preferOverlay = preferOverlay
        host.showLineGuides = showLineGuides
        host.onHold = onHold
        host.onPressing = onPressing
        host.counts = counts
        host.textRevision = textRevision
        return host
    }

    func updateUIView(_ uiView: Host, context: Context) {
        uiView.fontSize = fontSize
        uiView.preferOverlay = preferOverlay
        uiView.showLineGuides = showLineGuides
        uiView.onHold = onHold
        uiView.onPressing = onPressing
        uiView.counts = counts
        uiView.textRevision = textRevision
        uiView.setNeedsLayout()
        uiView.setNeedsDisplay()
    }

    final class Host: UIView {
        var counts: [Int] = []
        var fontSize: CGFloat = 17
        var preferOverlay = false
        var showLineGuides = true
        var textRevision = ""
        var onHold: ((Int) -> Void)?
        var onPressing: ((Int?) -> Void)?

        private var hits: [SyllableGutterHitView] = []
        private var ruleYs: [CGFloat] = []
        private var gutterWidth: CGFloat {
            SyllableCountButtonMetrics.width(
                forRowHeight: EditorWritingMetrics.rowHeight(fontSize: fontSize)
            )
        }

        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            nearestHit(at: point) != nil
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            nearestHit(at: point)
        }

        private func nearestHit(at point: CGPoint) -> SyllableGutterHitView? {
            let live = hits.filter { !$0.isHidden && $0.isUserInteractionEnabled }
            guard let index = SyllableCountButtonMetrics.nearestIndex(to: point, visualFrames: live.map(\.frame)) else {
                return nil
            }
            return live[index]
        }

        override func draw(_ rect: CGRect) {
            guard showLineGuides, !ruleYs.isEmpty else { return }
            let color = UIColor.tertiaryLabel.withAlphaComponent(0.22)
            color.setStroke()
            let path = UIBezierPath()
            path.lineWidth = 1.5
            path.lineCapStyle = .round
            // Round caps + a near-zero dash reads as a soft dotted rule.
            path.setLineDash([0.01, 5], count: 2, phase: 0)
            let x0 = gutterWidth
            let x1 = max(x0 + 8, bounds.width - 16)
            for y in ruleYs where y.isFinite {
                let snapped = (y * contentScaleFactor).rounded() / max(contentScaleFactor, 1)
                path.move(to: CGPoint(x: x0, y: snapped))
                path.addLine(to: CGPoint(x: x1, y: snapped))
            }
            path.stroke()
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            setNeedsLayout()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            relayout()
        }

        private func relayout() {
            let textView = findWritingTextView()
            if let textView {
                textView.layoutManager.ensureLayout(for: textView.textContainer)
            }
            let liveCounts = LineSyllableCounter.counts(for: textView?.text ?? "")
            let counts = liveCounts.isEmpty ? self.counts : liveCounts
            let origins = textView.map { EditorWritingMetrics.newlineFragmentOrigins(in: $0) } ?? []
            let liveHeights = textView.map { EditorWritingMetrics.newlineFragmentHeights(in: $0) } ?? []
            let rowH = EditorWritingMetrics.rowHeight(fontSize: fontSize)
            let topPad: CGFloat = 8
            let lineCount = max(counts.count, origins.count)

            if let textView {
                ruleYs = EditorWritingMetrics.visualLineUnderlineYs(in: textView).compactMap { y in
                    let converted = convertY(y, from: textView)
                    return converted.isFinite ? converted : nil
                }
            } else {
                ruleYs = (0..<max(lineCount, 1)).map { topPad + CGFloat($0 + 1) * rowH - 1 }
            }
            setNeedsDisplay()

            while hits.count < lineCount {
                let hit = SyllableGutterHitView()
                addSubview(hit)
                hits.append(hit)
            }
            while hits.count > lineCount {
                hits.removeLast().removeFromSuperview()
            }

            for index in 0..<lineCount {
                let originY: CGFloat
                if let textView, index < origins.count {
                    let converted = textView.convert(CGPoint(x: 0, y: origins[index]), to: self).y
                    originY = converted.isFinite ? converted : topPad + CGFloat(index) * rowH
                } else {
                    originY = topPad + CGFloat(index) * rowH
                }
                let visualHeight: CGFloat = {
                    if index < liveHeights.count {
                        return max(rowH, liveHeights[index])
                    }
                    return rowH
                }()
                let count = index < counts.count ? counts[index] : 0
                let hit = hits[index]
                hit.frame = SyllableCountButtonMetrics.frame(
                    originY: originY,
                    visualHeight: visualHeight,
                    rowHeight: rowH
                )
                hit.apply(count: count, fontSize: fontSize)
                hit.onHold = { [weak self] in
                    self?.paintLinePulse(index, on: true)
                    self?.onPressing?(index)
                }
                hit.onHoldRelease = { [weak self] in
                    self?.onHold?(index)
                }
                hit.onUp = { [weak self] in
                    self?.paintLinePulse(index, on: false)
                    self?.onPressing?(nil)
                }
            }
        }

        private func paintLinePulse(_ index: Int, on: Bool) {
            guard let textView = findWritingTextView() else { return }
            let text = textView.text ?? ""
            guard let range = LineSyllableCounter.utf16RangeForLine(index, in: text),
                  range.location + range.length <= textView.textStorage.length else { return }
            if on {
                let dark = textView.traitCollection.userInterfaceStyle == .dark
                let yellow = UIColor.systemYellow.withAlphaComponent(dark ? 0.65 : 0.52)
                textView.textStorage.addAttribute(.backgroundColor, value: yellow, range: range)
            } else {
                textView.textStorage.removeAttribute(.backgroundColor, range: range)
            }
        }

        private func convertY(_ y: CGFloat, from textView: UITextView) -> CGFloat {
            if textView.window != nil, window != nil {
                let inWindow = textView.convert(CGPoint(x: 0, y: y), to: nil)
                let hostOrigin = convert(CGPoint.zero, to: nil)
                return inWindow.y - hostOrigin.y
            }
            return textView.convert(CGPoint(x: 0, y: y), to: self).y
        }

        private func findWritingTextView() -> UITextView? {
            var overlay: UITextView?
            var editor: UITextView?
            var node: UIView? = superview
            var depth = 0
            while let current = node, depth < 16 {
                collectTextViews(in: current, overlay: &overlay, editor: &editor)
                let pick = preferOverlay ? (overlay ?? editor) : (editor ?? overlay)
                if let pick { return pick }
                node = current.superview
                depth += 1
            }
            return nil
        }

        private func textMatches(_ textView: UITextView) -> Bool {
            if textRevision.isEmpty { return true }
            let body = textView.text ?? ""
            return body == textRevision || body.hasPrefix(String(textRevision.prefix(80))) || textRevision.hasPrefix(String(body.prefix(80)))
        }

        private func collectTextViews(in view: UIView, overlay: inout UITextView?, editor: inout UITextView?) {
            if view === self { return }
            if let textView = view as? UITextView, textMatches(textView) {
                if textView.tag == EditorWritingMetrics.lyricOverlayTag {
                    overlay = textView
                } else {
                    editor = textView
                }
            }
            for sub in view.subviews {
                collectTextViews(in: sub, overlay: &overlay, editor: &editor)
            }
        }
    }
}

/// Fast swipe toward the top of the note dismisses the keyboard without the
/// system scroll-to-caret jump that `.scrollDismissesKeyboard` causes here.
private struct EditorKeyboardDismissProbe: UIViewRepresentable {
    var isKeyboardUp: Bool
    var onDismiss: () -> Void

    func makeUIView(context: Context) -> Probe {
        let probe = Probe()
        probe.isKeyboardUp = { isKeyboardUp }
        probe.onDismiss = onDismiss
        return probe
    }

    func updateUIView(_ uiView: Probe, context: Context) {
        uiView.isKeyboardUp = { isKeyboardUp }
        uiView.onDismiss = onDismiss
        uiView.attachIfNeeded()
    }

    final class Probe: UIView {
        var isKeyboardUp: () -> Bool = { false }
        var onDismiss: () -> Void = {}
        private weak var scroll: UIScrollView?
        private var observing = false
        private let fastFlick: CGFloat = 850
        private let nearTopFlick: CGFloat = 420

        override func didMoveToWindow() {
            super.didMoveToWindow()
            attachIfNeeded()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            attachIfNeeded()
        }

        func attachIfNeeded() {
            var node: UIView? = superview
            while let current = node {
                if let found = current as? UIScrollView, !(current is UITextView) {
                    guard scroll !== found else { return }
                    detach()
                    scroll = found
                    found.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
                    observing = true
                    return
                }
                node = current.superview
            }
        }

        deinit {
            detach()
        }

        private func detach() {
            guard observing, let scroll else {
                observing = false
                return
            }
            scroll.panGestureRecognizer.removeTarget(self, action: #selector(handlePan(_:)))
            observing = false
            self.scroll = nil
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard isKeyboardUp(), let scroll else { return }
            let velocity = gesture.velocity(in: scroll)
            // Positive y = finger moving down = content returning toward the top.
            let nearTop = scroll.contentOffset.y <= 48
            let fastEnough = velocity.y >= (nearTop ? nearTopFlick : fastFlick)
            guard fastEnough else { return }
            switch gesture.state {
            case .ended, .cancelled:
                onDismiss()
            case .changed where nearTop:
                onDismiss()
            default:
                break
            }
        }
    }
}

/// Watches the pill row for an open menu so the 4 second hide waits until it closes.
private struct BeatInfoMenuProbe: UIViewRepresentable {
    @Binding var menuOpen: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> Probe {
        let view = Probe()
        view.coordinator = context.coordinator
        return view
    }

    func updateUIView(_ uiView: Probe, context: Context) {
        uiView.coordinator = context.coordinator
        context.coordinator.menuOpen = $menuOpen
    }

    final class Coordinator {
        var menuOpen: Binding<Bool> = .constant(false)
        var last = false

        func report(_ open: Bool) {
            guard open != last else { return }
            last = open
            guard menuOpen.wrappedValue != open else { return }
            menuOpen.wrappedValue = open
        }
    }

    final class Probe: UIView {
        weak var coordinator: Coordinator?
        private var timer: Timer?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            timer?.invalidate()
            timer = nil
            guard window != nil else { return }
            let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
                self?.poll()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        }

        deinit { timer?.invalidate() }

        func poll() {
            coordinator?.report(menuIsOpen())
        }

        func menuIsOpen() -> Bool {
            if let scroll = nearestPillScroll(), Self.buttonShowsMenu(scroll) {
                return true
            }
            return Self.menuChromeIsVisible()
        }

        func nearestPillScroll() -> UIScrollView? {
            var view: UIView? = self
            var hops = 0
            while let current = view, hops < 8 {
                if let found = Self.findPillScroll(in: current, depth: 0) {
                    return found
                }
                view = current.superview
                hops += 1
            }
            return nil
        }

        static func findPillScroll(in view: UIView, depth: Int) -> UIScrollView? {
            if depth > 6 { return nil }
            if let scroll = view as? UIScrollView,
               scroll.alwaysBounceHorizontal,
               scroll.bounds.height > 0,
               scroll.bounds.height < 90 {
                return scroll
            }
            for subview in view.subviews {
                if let found = findPillScroll(in: subview, depth: depth + 1) {
                    return found
                }
            }
            return nil
        }

        static func buttonShowsMenu(_ view: UIView) -> Bool {
            if let button = view as? UIButton, button.menu != nil,
               button.isHighlighted || button.isSelected {
                return true
            }
            for subview in view.subviews where buttonShowsMenu(subview) {
                return true
            }
            return false
        }

        static func menuChromeIsVisible() -> Bool {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            for scene in scenes {
                for window in scene.windows where !window.isHidden && !window.isKeyWindow {
                    let windowName = NSStringFromClass(type(of: window))
                    if windowName.contains("Keyboard") || windowName.contains("TextEffects") || windowName.contains("Remote") {
                        continue
                    }
                    if treeLooksLikeMenu(window, depth: 0) { return true }
                }
            }
            return false
        }

        static func treeLooksLikeMenu(_ view: UIView, depth: Int) -> Bool {
            if depth > 10 { return false }
            let name = NSStringFromClass(type(of: view))
            if (name.contains("ContextMenu") || name.contains("UIMenuList")),
               !view.isHidden,
               view.alpha > 0.01,
               view.bounds.width > 40,
               view.bounds.height > 20 {
                return true
            }
            for subview in view.subviews where treeLooksLikeMenu(subview, depth: depth + 1) {
                return true
            }
            return false
        }
    }
}

/// Lets a horizontal pill `ScrollView` take a drag even when the finger starts on a `Menu`.
private struct HorizontalPillScrollFix: UIViewRepresentable {
    func makeUIView(context: Context) -> Probe {
        Probe()
    }

    func updateUIView(_ uiView: Probe, context: Context) {
        uiView.fix()
    }

    final class Probe: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            fix()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            fix()
        }

        func fix() {
            var view: UIView? = self
            while let current = view {
                if let scroll = current as? UIScrollView {
                    scroll.delaysContentTouches = false
                    scroll.canCancelContentTouches = true
                    scroll.alwaysBounceHorizontal = true
                    scroll.isDirectionalLockEnabled = true
                    scroll.bounces = true
                    return
                }
                view = current.superview
            }
        }
    }
}

/// Instant gutter press: yellow on finger-down, no ScrollView delay, no editor jump.
private struct SyllableGutterPressView: UIViewRepresentable {
    var enabled: Bool
    var onDown: () -> Void
    var onUp: () -> Void
    var onHold: () -> Void

    func makeUIView(context: Context) -> SyllableGutterHitView {
        SyllableGutterHitView()
    }

    func updateUIView(_ uiView: SyllableGutterHitView, context: Context) {
        uiView.isUserInteractionEnabled = enabled
        uiView.onDown = onDown
        uiView.onUp = onUp
        uiView.onHold = onHold
    }
}

final class SyllableGutterHitView: UIControl {
    var onDown: (() -> Void)?
    var onUp: (() -> Void)?
    var onHold: (() -> Void)?
    var onHoldRelease: (() -> Void)?

    private let countLabel = UILabel()
    private var holdWork: DispatchWorkItem?
    private var didHold = false
    private var isPressing = false
    private var swipeCancelled = false
    private var startPoint: CGPoint = .zero
    private let swipeDownCancelDistance: CGFloat = 24
    private weak var parentScroll: UIScrollView?
    private var lockedPan = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isExclusiveTouch = true
        isMultipleTouchEnabled = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        countLabel.textAlignment = .center
        countLabel.adjustsFontForContentSizeCategory = false
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.75
        countLabel.isUserInteractionEnabled = false
        addSubview(countLabel)
        addTarget(self, action: #selector(handleDown), for: .touchDown)
        addTarget(self, action: #selector(handleUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: SyllableGutterHitView, _) in
            view.applyChrome()
        }
        applyChrome()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        unlockParentScroll()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        prepareParentScroll()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        countLabel.frame = bounds
        let shortest = min(bounds.width, bounds.height)
        layer.cornerRadius = min(12, max(8, shortest * 0.22))
        layer.borderWidth = 1.5
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        SyllableCountButtonMetrics.hitFrame(for: bounds).contains(point)
    }

    func apply(count: Int, fontSize: CGFloat = 17) {
        let body = UIFont.systemFont(ofSize: EditorWritingMetrics.gutterNumberSize(for: fontSize), weight: .bold)
        if let rounded = body.fontDescriptor.withDesign(.rounded) {
            countLabel.font = UIFont(descriptor: rounded, size: body.pointSize)
        } else {
            countLabel.font = body
        }
        countLabel.text = count == 0 ? nil : "\(count)"
        isHidden = count == 0
        isUserInteractionEnabled = count > 0
        accessibilityLabel = count == 0
            ? "Empty line"
            : "\(count) syllables. Hold to highlight this bar, then let go to see similar bars. Swipe down to cancel."
        applyChrome()
    }

    func applyChrome() {
        let dark = traitCollection.userInterfaceStyle == .dark
        if didHold {
            backgroundColor = UIColor.systemYellow.withAlphaComponent(dark ? 0.55 : 0.42)
            layer.borderColor = UIColor.systemYellow.withAlphaComponent(0.95).cgColor
            countLabel.textColor = .label
        } else if isPressing {
            backgroundColor = UIColor.tertiarySystemFill
            layer.borderColor = UIColor.label.withAlphaComponent(0.28).cgColor
            countLabel.textColor = .label
        } else {
            backgroundColor = dark
                ? UIColor.secondarySystemFill
                : UIColor.systemGray5
            layer.borderColor = UIColor.label.withAlphaComponent(dark ? 0.28 : 0.16).cgColor
            countLabel.textColor = .label
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swipeCancelled = false
        startPoint = touches.first?.location(in: self) ?? .zero
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard !swipeCancelled, let point = touches.first?.location(in: self) else { return }
        if point.y - startPoint.y >= swipeDownCancelDistance {
            cancelHoldBySwipe()
        }
    }

    @objc private func handleDown() {
        didHold = true
        isPressing = true
        swipeCancelled = false
        applyChrome()
        onDown?()
        prepareParentScroll()
        lockParentScroll()
        HapticFeedbackManager.shared.prepareHold()
        holdWork?.cancel()
        holdWork = nil
        HapticFeedbackManager.shared.mediumTap()
        onHold?()
    }

    @objc private func handleUp() {
        holdWork?.cancel()
        holdWork = nil
        unlockParentScroll()
        isPressing = false
        if swipeCancelled {
            swipeCancelled = false
            didHold = false
            applyChrome()
            return
        }
        didHold = false
        applyChrome()
        onHoldRelease?()
    }

    private func cancelHoldBySwipe() {
        swipeCancelled = true
        didHold = false
        isPressing = false
        holdWork?.cancel()
        holdWork = nil
        unlockParentScroll()
        applyChrome()
        onUp?()
    }

    private func prepareParentScroll() {
        var view: UIView? = superview
        while let current = view {
            if let scroll = current as? UIScrollView, !(current is UITextView) {
                parentScroll = scroll
                scroll.delaysContentTouches = false
                return
            }
            view = current.superview
        }
    }

    private func lockParentScroll() {
        guard let scroll = parentScroll, !lockedPan else { return }
        scroll.canCancelContentTouches = false
        scroll.panGestureRecognizer.isEnabled = false
        lockedPan = true
    }

    private func unlockParentScroll() {
        guard lockedPan, let scroll = parentScroll else {
            lockedPan = false
            return
        }
        scroll.canCancelContentTouches = true
        scroll.panGestureRecognizer.isEnabled = true
        lockedPan = false
    }
}
