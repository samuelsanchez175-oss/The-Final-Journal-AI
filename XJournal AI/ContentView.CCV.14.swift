//
// ContentView.CCV.14.swift
//
// This file contains DynamicIslandToolbarView and related PreferenceKeys.
//
// Dependencies:
// - ContentView.CCV.2.swift (for GlassSettings, lightHaptic)
// - ContentView.CCV.3.swift (for RhymeHighlighterEngine, Highlight)
// - ContentView.CCV.8.swift (for PopoverViews)
//
import SwiftUI
import UIKit
import Combine

// MARK: - Permanent Toolbar Constants (LOCKED FOREVER - NEVER CHANGE)
// These values are permanently locked and must never be modified:
// - Toolbar height: Exactly 64pt (44pt content + 10pt top padding + 10pt bottom padding)
// - Keyboard spacing: Exactly 8pt (space between toolbar and keyboard)
private enum ToolbarConstants {
    static let height: CGFloat = 64.0 // LOCKED: Toolbar height = 44 (content) + 10 (top) + 10 (bottom)
    static let contentHeight: CGFloat = 44.0 // LOCKED: Button/icon content height
    static let verticalPadding: CGFloat = 10.0 // LOCKED: Top and bottom padding
    static let keyboardSpacing: CGFloat = 8.0 // LOCKED: Space between toolbar and keyboard (bottom padding)
}

struct ToolbarFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: [SplashScreenID: CGRect] = [:]
    static func reduce(value: inout [SplashScreenID: CGRect], nextValue: () -> [SplashScreenID: CGRect]) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

struct DynamicIslandToolbarView: View {
    @Namespace private var islandNamespace // For fluid island transitions
    @Binding var isExpanded: Bool
    @Binding var isRhymeOverlayVisible: Bool
    @Binding var showDiagnostics: Bool
    let rhymeGroups: [RhymeHighlighterEngine.RhymeGroup]
    let currentText: String
    let highlights: [Highlight]
    @FocusState.Binding var isEditorFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Binding var keyboardHeight: CGFloat
    @State private var showRhymeGroupsPopover: Bool = false
    @Binding var showAudioRecorder: Bool
    @Binding var showRapSuggestions: Bool
    @ObservedObject var rapSuggestionEngine: RapSuggestionEngine
    @Binding var isShowingRecalled: Bool
    @Binding var showContextHighlight: Bool
    @Binding var showAudioImporter: Bool
    @Binding var showImportNotesInstructions: Bool
    @State private var rotationAngle: Double = 0
    
    // Handler closures
    let onRewriteLine: () -> Void
    let onSuggestRhymes: () -> Void
    let onImproveFlow: () -> Void
    let onUndo: () -> Void
    let onRedo: () -> Void
    let onInsertRapSuggestion: (RapSuggestion) -> Void
    
    // Undo/Redo state
    let canUndo: Bool
    let canRedo: Bool
    
    // Loading state bindings
    @Binding var isRewritingLine: Bool
    @Binding var isImprovingFlow: Bool
    @Binding var rewriteLineLoadingStep: String?
    @Binding var improveFlowLoadingStep: String?
    
    // Splash screen state
    @ObservedObject private var splashManager = SplashScreenManager.shared
    @State private var showAISparkleSplash: Bool = false
    
    // Paywall and error state
    @Binding var showPaywall: Bool
    @Binding var paywallFeature: String
    @Binding var showAIErrorToast: Bool
    @Binding var aiErrorMessage: String?
    
    // Sheet state bindings
    @Binding var showStyleTransferSheet: Bool
    @Binding var showThemeExpansionSheet: Bool
    @Binding var showExportSheet: Bool
    
    // Handler closures for actions
    let insertRapSuggestion: (RapSuggestion, Bool) -> Void
    let extractThemes: (String) -> [String]
    let showAIError: (String) -> Void
    let item: Item
    
    // MARK: - Enhancement State Variables
    @State private var autoCollapseTimer: Timer?
    @State private var buttonPressStates: [String: Bool] = [:]
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var buttonAppearanceDelay: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Computed properties for live activity indicators
    private var wordCount: Int {
        currentText.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    private var rhymeCount: Int {
        rhymeGroups.count
    }
    
    private var isAILoading: Bool {
        rapSuggestionEngine.isLoading || isRewritingLine || isImprovingFlow
    }
    
    // MARK: - Audio Recording
    private func openAudioRecorder() {
        HapticFeedbackManager.shared.lightTap()
        showAudioRecorder = true
    }
    
    // MARK: - Auto-Collapse Logic
    private func startAutoCollapseTimer() {
        // Auto-collapse timer disabled - toolbar will stay open until manually closed
        cancelAutoCollapseTimer()
        // Timer functionality removed - toolbar no longer auto-collapses
    }
    
    private func cancelAutoCollapseTimer() {
        autoCollapseTimer?.invalidate()
        autoCollapseTimer = nil
    }
    
    // Note: Structs cannot have deinitializers
    // Timer cleanup is handled in onDisappear instead
    
    // MARK: - Enhanced Button Helper
    @ViewBuilder
    private func enhancedButton(
        id: String,
        action: @escaping () -> Void,
        label: @escaping () -> some View,
        hapticStyle: HapticStyle = .light,
        showGlow: Bool = false
    ) -> some View {
        let isPressed = buttonPressStates[id] ?? false
        
        Button(action: {
            switch hapticStyle {
            case .light:
                HapticFeedbackManager.shared.lightTap()
            case .medium:
                HapticFeedbackManager.shared.mediumTap()
            case .heavy:
                HapticFeedbackManager.shared.heavyTap()
            case .success:
                HapticFeedbackManager.shared.success()
            case .error:
                HapticFeedbackManager.shared.error()
            case .selection:
                HapticFeedbackManager.shared.selection()
            }
            action()
        }) {
            label()
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .overlay(
                    Group {
                        if showGlow && isAILoading {
                            Circle()
                                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                                .scaleEffect(1.2)
                                .opacity(0.6)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.easeOut(duration: 0.1)) {
                            buttonPressStates[id] = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        buttonPressStates[id] = false
                    }
                }
        )
    }
    
    enum HapticStyle {
        case light, medium, heavy, success, error, selection
    }
    
    // MARK: - Body Components (broken down for compiler)
    private var collapsedStateView: some View {
        enhancedButton(
            id: "expand",
            action: {
                withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.4, dampingFraction: 0.75)) {
                    isExpanded = true
                    buttonAppearanceDelay = 0.1
                }
                HapticFeedbackManager.shared.mediumTap()
            },
            label: {
                collapsedButtonContent
            },
            hapticStyle: .medium
        )
        // glassEffectID fallback: Using matchedGeometryEffect for fluid island transitions
        .matchedGeometryEffect(id: "island_main", in: islandNamespace)
        // Segment 17: Vertical padding for collapsed state to match expanded state
        .padding(.vertical, ToolbarConstants.verticalPadding) // LOCKED: Consistent vertical padding
        // Segment 17: LOCKED FOREVER - Toolbar height must never change
        .frame(height: ToolbarConstants.height) // LOCKED: Exactly 64pt (44 + 10 + 10) - NEVER MODIFY
        .accessibilityLabel("Expand toolbar")
        .accessibilityHint("Double tap to expand toolbar with writing tools")
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
            .onEnded { _ in
                HapticFeedbackManager.shared.mediumTap()
            }
        )
    }
    
    private var collapsedButtonContent: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .frame(width: ToolbarConstants.contentHeight, height: ToolbarConstants.contentHeight) // LOCKED: Standardized 44pt height
            
            Image(systemName: "plus")
                .font(.title2)
            
            if wordCount > 0 {
                activityIndicatorsView
            }
            
            if isAILoading {
                aiLoadingIndicator
            }
        }
    }
    
    private var activityIndicatorsView: some View {
        VStack(spacing: 2) {
            Spacer()
            HStack(spacing: 4) {
                if rhymeCount > 0 {
                    Text("\(rhymeCount)")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                Text("\(wordCount)")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            }
            .padding(.bottom, 2)
        }
    }
    
    private var aiLoadingIndicator: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: 56, height: 56)
            .rotationEffect(.degrees(rotationAngle))
            .onAppear {
                if rotationAngle == 0 {
                    rotationAngle = 0
                    withAnimation(
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotationAngle = 360
                    }
                }
            }
    }

    // MARK: - Expanded State Helper Views
    
    @ViewBuilder
    private func expandedStateButtons(geometry: GeometryProxy) -> some View {
        // Segment 15: Centered Gravity Calibration - Edge Buffer with centered buttons
        // Segment 16: Edge Buffer Calibration - Horizontal padding creates edge buffer
        // Segment 17: Static Verticality Locking - Vertical alignment and size stability
        HStack(alignment: .center, spacing: 8) {
            // Bookend Spacer 1: Pushes buttons to center
            Spacer(minLength: 0)
            
            enhancedButton(
                            id: "close",
                            action: {
                                cancelAutoCollapseTimer()
                                withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.4, dampingFraction: 0.8)) {
                            isExpanded = false
                                }
                            },
                            label: {
                                Image(systemName: "xmark")
                                    .font(.headline)
                                    .frame(width: ToolbarConstants.contentHeight, height: ToolbarConstants.contentHeight) // LOCKED: Standardized button height
                            },
                            hapticStyle: .medium
                        )
                        .accessibilityLabel("Close toolbar")
                        .accessibilityHint("Double tap to collapse toolbar")
                        // Always visible - no opacity animation for close button
                        .opacity(1.0)

                        Menu {
                            Button {
                                HapticFeedbackManager.shared.selection()
                                isExpanded = false
                                showAudioImporter = true
                            } label: {
                                Label("Import Audio", systemImage: "waveform")
                            }
                            
                            Button {
                                HapticFeedbackManager.shared.selection()
                                isExpanded = false
                                showImportNotesInstructions = true
                            } label: {
                                Label("Import Note", systemImage: "note.text")
                            }
                            
                            Button {
                                HapticFeedbackManager.shared.selection()
                                isExpanded = false
                                showAudioRecorder = true
                            } label: {
                                Label("Record Audio", systemImage: "waveform")
                            }
                        } label: {
                            Image(systemName: "paperclip")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .scaleEffect((buttonPressStates["paperclip"] ?? false) ? 0.92 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonPressStates["paperclip"])
                        }
                        .accessibilityLabel("Attach menu")
                        .accessibilityHint("Double tap to open attachment options")
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if buttonPressStates["paperclip"] != true {
                                        buttonPressStates["paperclip"] = true
                                    }
                                }
                                .onEnded { _ in
                                    HapticFeedbackManager.shared.lightTap()
                                    buttonPressStates["paperclip"] = false
                                }
                        )

                        Menu {
                            Button {
                                HapticFeedbackManager.shared.lightTap()
                                isEditorFocused = false
                                
                                // Show splash screen on first press
                                if splashManager.shouldShowSplash(.aiSparkleButton) {
                                    // Check if API key exists
                                    let apiKey = KeychainHelper.shared.getAPIKey()
                                    
                                    // Only show splash if API key is missing
                                    if apiKey == nil || apiKey?.isEmpty == true {
                                        showAISparkleSplash = true
                                        return
                                    } else {
                                        // API key exists, mark splash as dismissed
                                        splashManager.dismissSplash(.aiSparkleButton)
                                    }
                                }
                                
                                // Check feature access (Phase 1: Feature Gating)
                                if !FeatureGate.checkAccess(.aiSuggestions, showPaywall: { featureName in
                                    paywallFeature = featureName
                                    showPaywall = true
                                }) {
                                    return
                                }
                                
                                // Check usage limits (Phase 2: Monetization)
                                if !UsageTracker.shared.canUseAISuggestion() {
                                    paywallFeature = "AI Suggestions"
                                    showPaywall = true
                                    return
                                }
                                
                                // Track usage
                                UsageTracker.shared.trackAISuggestion()
                                UserBehaviorTracker.shared.trackFeatureUsage(feature: .aiSuggestions)
                                
                                isShowingRecalled = false // Clear recall flag when generating new suggestions
                                // Show context highlight for last 4 lines
                                showContextHighlight = true
                                Task {
                                    await rapSuggestionEngine.generateSuggestions(
                                        text: currentText,
                                        highlights: highlights,
                                        model: .modelG
                                    )
                                    // Hide context highlight when generation completes
                                    await MainActor.run {
                                    showContextHighlight = false
                                        if let error = rapSuggestionEngine.error {
                                            HapticFeedbackManager.shared.error()
                                            showAIError(error)
                                        } else {
                                            HapticFeedbackManager.shared.success()
                                    showRapSuggestions = true
                                        }
                                    }
                                }
                            } label: {
                                Label("Suggest Next Lines with Model G", systemImage: "sparkles")
                            }
                            
                            Button {
                                HapticFeedbackManager.shared.lightTap()
                                isEditorFocused = false
                                
                                // Show splash screen on first press
                                if splashManager.shouldShowSplash(.aiSparkleButton) {
                                    // Check if API key exists
                                    let apiKey = KeychainHelper.shared.getAPIKey()
                                    
                                    // Only show splash if API key is missing
                                    if apiKey == nil || apiKey?.isEmpty == true {
                                        showAISparkleSplash = true
                                        return
                                    } else {
                                        // API key exists, mark splash as dismissed
                                        splashManager.dismissSplash(.aiSparkleButton)
                                    }
                                }
                                
                                // Check feature access (Phase 1: Feature Gating)
                                if !FeatureGate.checkAccess(.aiSuggestions, showPaywall: { featureName in
                                    paywallFeature = featureName
                                    showPaywall = true
                                }) {
                                    return
                                }
                                
                                // Check usage limits (Phase 2: Monetization)
                                if !UsageTracker.shared.canUseAISuggestion() {
                                    paywallFeature = "AI Suggestions"
                                    showPaywall = true
                                    return
                                }
                                
                                // Track usage
                                UsageTracker.shared.trackAISuggestion()
                                UserBehaviorTracker.shared.trackFeatureUsage(feature: .aiSuggestions)
                                
                                isShowingRecalled = false // Clear recall flag when generating new suggestions
                                // Show context highlight for last 4 lines
                                showContextHighlight = true
                                Task {
                                    await rapSuggestionEngine.generateSuggestions(
                                        text: currentText,
                                        highlights: highlights,
                                        model: .modelY
                                    )
                                    // Hide context highlight when generation completes
                                    await MainActor.run {
                                    showContextHighlight = false
                                        if let error = rapSuggestionEngine.error {
                                            HapticFeedbackManager.shared.error()
                                            showAIError(error)
                                        } else {
                                            HapticFeedbackManager.shared.success()
                                    showRapSuggestions = true
                                        }
                                    }
                                }
                            } label: {
                                Label("Suggest Next Lines with Model Y", systemImage: "sparkles")
                            }
                            
                            Button {
                                HapticFeedbackManager.shared.selection()
                                isEditorFocused = false
                                // Set flag to show previous suggestions (no AI call)
                                isShowingRecalled = true
                                showRapSuggestions = true
                            } label: {
                                Label("Recall Suggested Lines", systemImage: "clock.arrow.circlepath")
                            }
                            .disabled(rapSuggestionEngine.previousSuggestions.isEmpty)
                            
                            Button {
                                onRewriteLine()
                            } label: {
                                HStack {
                                    if isRewritingLine {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .frame(width: 16, height: 16)
                                    }
                                    Label("Rewrite Line", systemImage: "arrow.clockwise")
                                }
                            }
                            .disabled(isRewritingLine)
                            
                            Button {
                                onSuggestRhymes()
                            } label: {
                                Label("Suggest Rhymes", systemImage: "text.magnifyingglass")
                            }
                            
                            Button {
                                onImproveFlow()
                            } label: {
                                HStack {
                                    if isImprovingFlow {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .frame(width: 16, height: 16)
                                    }
                                    Label("Improve Flow", systemImage: "waveform")
                                }
                            }
                            .disabled(isImprovingFlow)
                            
                            // Phase 4: Advanced AI Features (Pro tier and above)
                            if FeatureGate.canAccess(.styleTransfer) || FeatureGate.canAccess(.themeExpansion) {
                                Divider()
                                
                                if FeatureGate.canAccess(.styleTransfer) {
                                    Button {
                                        showStyleTransferSheet = true
                                    } label: {
                                        Label("Style Transfer", systemImage: "paintbrush")
                                    }
                                }
                                
                                if FeatureGate.canAccess(.themeExpansion) {
                                    Button {
                                        showThemeExpansionSheet = true
                                    } label: {
                                        Label("Theme Expansion", systemImage: "arrow.triangle.branch")
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                // Circular progress indicator (outer ring)
                                if rapSuggestionEngine.isLoading || isRewritingLine || isImprovingFlow {
                                    Circle()
                                        .trim(from: 0, to: 0.75)
                                        .stroke(
                                            style: StrokeStyle(
                                                lineWidth: 3,
                                                lineCap: .round,
                                                lineJoin: .round
                                            )
                                        )
                                        .foregroundStyle(.blue)
                                        .frame(width: ToolbarConstants.contentHeight, height: ToolbarConstants.contentHeight) // LOCKED: Standardized button height
                                        .rotationEffect(.degrees(rotationAngle))
                                    
                                    // Glow effect for AI operations
                                    Circle()
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                        .frame(width: 50, height: 50)
                                        .blur(radius: 4)
                                }
                                
                                // Sparkles icon (centered)
                                Image(systemName: "sparkles")
                                    .font(.headline)
                                    .frame(width: ToolbarConstants.contentHeight, height: ToolbarConstants.contentHeight) // LOCKED: Standardized button height
                                    .foregroundStyle(.blue)
                            }
                            .scaleEffect((buttonPressStates["aiSparkle"] ?? false) ? 0.92 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonPressStates["aiSparkle"])
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if buttonPressStates["aiSparkle"] != true {
                                        buttonPressStates["aiSparkle"] = true
                                    }
                                }
                                .onEnded { _ in
                                    HapticFeedbackManager.shared.lightTap()
                                    buttonPressStates["aiSparkle"] = false
                                }
                        )
                        .disabled(rapSuggestionEngine.isLoading || isRewritingLine || isImprovingFlow)
                        .accessibilityLabel("AI suggestions")
                        .accessibilityHint("Double tap to open AI writing assistance menu")
                        .onChange(of: rapSuggestionEngine.isLoading) { oldValue, newValue in
                            if newValue {
                                // Start rotating animation
                                rotationAngle = 0
                                withAnimation(
                                    Animation.linear(duration: 1.0)
                                        .repeatForever(autoreverses: false)
                                ) {
                                    rotationAngle = 360
                                }
                            } else {
                                // Stop animation and reset
                                rotationAngle = 0
                            }
                        }
                        .onChange(of: isRewritingLine) { oldValue, newValue in
                            if newValue {
                                // Start rotating animation
                                rotationAngle = 0
                                withAnimation(
                                    Animation.linear(duration: 1.0)
                                        .repeatForever(autoreverses: false)
                                ) {
                                    rotationAngle = 360
                                }
                            } else if !rapSuggestionEngine.isLoading && !isImprovingFlow {
                                // Stop animation and reset only if nothing else is loading
                                rotationAngle = 0
                            }
                        }
                        .onChange(of: isImprovingFlow) { oldValue, newValue in
                            if newValue {
                                // Start rotating animation
                                rotationAngle = 0
                                withAnimation(
                                    Animation.linear(duration: 1.0)
                                        .repeatForever(autoreverses: false)
                                ) {
                                    rotationAngle = 360
                                }
                            } else if !rapSuggestionEngine.isLoading && !isRewritingLine {
                                // Stop animation and reset only if nothing else is loading
                                rotationAngle = 0
                            }
                        }
                        .onAppear {
                            // Start rotation animation if AI is already loading
                            if isAILoading && rotationAngle == 0 {
                                rotationAngle = 0
                                withAnimation(
                                    Animation.linear(duration: 1.0)
                                        .repeatForever(autoreverses: false)
                                ) {
                                    rotationAngle = 360
                                }
                            }
                        }

                        enhancedButton(
                            id: "eyeToggle",
                            action: {
                                withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.7)) {
                                isRhymeOverlayVisible.toggle()
                            }
                                startAutoCollapseTimer()
                            },
                            label: {
                                Image(systemName: isRhymeOverlayVisible ? "eye.fill" : "eye")
                                    .font(.headline)
                                    .frame(width: ToolbarConstants.contentHeight, height: ToolbarConstants.contentHeight) // LOCKED: Standardized button height
                                    .foregroundStyle(isRhymeOverlayVisible ? .blue : .primary)
                            },
                            hapticStyle: .light
                        )
                        .accessibilityLabel(isRhymeOverlayVisible ? "Hide rhyme overlay" : "Show rhyme overlay")
                        .accessibilityHint("Double tap to toggle visual rhyme highlighting")

                        enhancedButton(
                            id: "undo",
                            action: {
                            onUndo()
                                startAutoCollapseTimer()
                            },
                            label: {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.headline)
                                    .frame(width: ToolbarConstants.contentHeight, height: ToolbarConstants.contentHeight) // LOCKED: Standardized button height
                            },
                            hapticStyle: .light
                        )
                        .disabled(!canUndo)
                        .opacity(canUndo ? 1.0 : 0.4)
                        .accessibilityLabel("Undo")
                        .accessibilityHint("Double tap to undo last change")
                        
                        enhancedButton(
                            id: "redo",
                            action: {
                            onRedo()
                                startAutoCollapseTimer()
                            },
                            label: {
                                Image(systemName: "arrow.uturn.forward")
                                    .font(.headline)
                                    .frame(width: ToolbarConstants.contentHeight, height: ToolbarConstants.contentHeight) // LOCKED: Standardized button height
                            },
                            hapticStyle: .light
                        )
                        .disabled(!canRedo)
                        .opacity(canRedo ? 1.0 : 0.4)
                        .accessibilityLabel("Redo")
                        .accessibilityHint("Double tap to redo last undone change")
                        
                        enhancedButton(
                            id: "magnifyingGlass",
                            action: {
                            // Dismiss keyboard when opening popover
                            isEditorFocused = false
                            showRhymeGroupsPopover = true
                                startAutoCollapseTimer()
                            },
                            label: {
                                Image(systemName: "text.magnifyingglass")
                                    .font(.headline)
                                    .frame(width: ToolbarConstants.contentHeight, height: ToolbarConstants.contentHeight) // LOCKED: Standardized button height
                            },
                            hapticStyle: .light
                        )
                        .accessibilityLabel("Rhyme groups")
                        .accessibilityHint("Double tap to view all rhyme groups in your text")
                        .popover(isPresented: $showRhymeGroupsPopover, arrowEdge: .bottom) {
                            RhymeGroupListView(
                                groups: rhymeGroups,
                                currentText: currentText
                            )
                            .presentationCompactAdaptation(.popover)
                        }
                        .onChange(of: showRhymeGroupsPopover) { _, isPresented in
                            // Ensure keyboard is dismissed when popover opens
                            if isPresented {
                                isEditorFocused = false
                            }
                        }

                        enhancedButton(
                            id: "keyboard",
                            action: {
                            isEditorFocused.toggle()
                                startAutoCollapseTimer()
                            },
                            label: {
                                Image(systemName: isEditorFocused ? "keyboard.chevron.compact.down" : "keyboard")
                                    .font(.headline)
                                    .frame(width: ToolbarConstants.contentHeight, height: ToolbarConstants.contentHeight) // LOCKED: Standardized button height
                            },
                            hapticStyle: .light
                        )
            .accessibilityLabel(isEditorFocused ? "Dismiss keyboard" : "Show keyboard")
            .accessibilityHint("Double tap to toggle keyboard")
            
            // Bookend Spacer 2: Completes centered gravity calibration
            Spacer(minLength: 0)
        }
        // Segment 17: Move padding to inner HStack for static verticality
        .padding(.vertical, ToolbarConstants.verticalPadding) // LOCKED: Consistent vertical padding (10 top + 10 bottom)
        // Segment 16: Edge Buffer Calibration - Creates space between buttons and glass edge
        .padding(.horizontal, 24) // Increased edge buffer to prevent X from touching container edge
        .frame(maxWidth: .infinity) // Ensure HStack respects container boundaries
        .frame(height: ToolbarConstants.height) // LOCKED: Exactly 64pt (44 + 10 + 10) - NEVER MODIFY
    }
    
    private func expandedStateView(geometry: GeometryProxy) -> some View {
        expandedStateButtons(geometry: geometry)
            // Segment 17: Remove explicit height - let inner HStack determine height (44 + padding = 64)
            .frame(maxWidth: geometry.size.width - 24) // Slightly reduce width to account for edge padding
            // REMOVED: Secondary background - only outer container should have glass effect
            // This prevents "double island" effect - single unified glass container
            // glassEffectID fallback: Using matchedGeometryEffect for fluid island transitions
            .matchedGeometryEffect(id: "island_main", in: islandNamespace)
            // REMOVED: Drag gesture - swipe away toolbar functionality removed
            .scaleEffect(isExpanded ? 1.0 : 0.8)
            .opacity(isExpanded ? 1.0 : 0)
            .animation(
                reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.4, dampingFraction: 0.75),
                value: isExpanded
            )
    }
    
    private var toolbarContent: some View {
        // GlassEffectContainer (fallback implementation for iOS < 26)
        // spacing: 12 controls glass blending threshold - small value prevents expansion
        VStack(spacing: 0) {
            ZStack {
                if !isExpanded {
                    collapsedStateView
                } else {
                    GeometryReader { geometry in
                        expandedStateView(geometry: geometry)
                    }
                }
            }
            // Segment 17: LOCKED FOREVER - Toolbar height must never change
            .frame(maxWidth: .infinity)
            .frame(height: ToolbarConstants.height) // LOCKED: Exactly 64pt (44 + 10 + 10) - NEVER MODIFY
            .onChange(of: isExpanded) { oldValue, newValue in
                if newValue {
                    buttonAppearanceDelay = 0.1
                    startAutoCollapseTimer()
                } else {
                    cancelAutoCollapseTimer()
                    buttonAppearanceDelay = 0
                }
            }
            .onChange(of: keyboardHeight) { oldValue, newValue in
                if newValue > 0 && !isExpanded {
                    withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.4, dampingFraction: 0.75)) {
                        isExpanded = true
                    }
                    HapticFeedbackManager.shared.lightTap()
                }
            }
            .onChange(of: isAILoading) { oldValue, newValue in
                if newValue {
                    cancelAutoCollapseTimer()
                } else {
                    if isExpanded {
                        startAutoCollapseTimer()
                    }
                }
            }
            .background(
                GeometryReader { toolbarGeometry in
                    Color.clear
                        .preference(
                            key: ToolbarFramePreferenceKey.self,
                            value: toolbarGeometry.frame(in: .global)
                        )
                }
            )
        }
        .background(
            // GlassEffectContainer fallback: Using continuous corner style for hardware alignment
            // More rounded edges for pill-shaped appearance
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 16) // Outer margin from device screen edges
        .padding(.bottom, ToolbarConstants.keyboardSpacing) // LOCKED FOREVER: Space between toolbar and keyboard - NEVER MODIFY
        // Intrinsic Surface Calibration: Prevent keyboard from squashing the toolbar
        // Unified glass container - no secondary backgrounds inside
        .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    private var aiSparkleSplashOverlay: some View {
        Group {
            if showAISparkleSplash {
                ZStack {
                    // Backdrop
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            splashManager.dismissSplash(.aiSparkleButton)
                            showAISparkleSplash = false
                        }
                    
                    // Splash screen with navigation to profile
                    VStack(spacing: 0) {
                        // Header with X button
                        HStack {
                            Text("AI Sparkle Button")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button {
                                splashManager.dismissSplash(.aiSparkleButton)
                                showAISparkleSplash = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        
                        Divider()
                            .opacity(0.15)
                        
                        // Content
                        VStack(alignment: .leading, spacing: 16) {
                            Text("To use the AI suggestion features, you'll need to add your OpenAI API key. You can find this in your Profile page under API Settings.")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                splashManager.dismissSplash(.aiSparkleButton)
                                showAISparkleSplash = false
                                // Navigate to profile - this will be handled by parent view
                                // For now, dismiss and user can manually open profile
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    // Show profile after splash dismisses
                                    NotificationCenter.default.post(name: NSNotification.Name("ShowProfile"), object: nil)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "person.crop.circle")
                                    Text("Open Profile Settings")
                                        .font(.headline)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.accentColor)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        
                        Divider()
                            .opacity(0.15)
                        
                        // Footer buttons
                        HStack(spacing: 12) {
                            Button {
                                splashManager.neverShowSplash(.aiSparkleButton)
                                showAISparkleSplash = false
                            } label: {
                                Text("\"Never show again\"")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .frame(maxWidth: 400)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(
                                        Color.primary.opacity(0.1),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    var body: some View {
        toolbarContent
        .overlay(aiSparkleSplashOverlay)
        .onChange(of: showAISparkleSplash) { _, isShowing in
            if isShowing {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    // Animation handled by transition
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                featureName: paywallFeature,
                onDismiss: {
                    showPaywall = false
                },
                onSubscribe: {
                    // TODO: Implement StoreKit subscription
                    // For now, set premium status for testing
                    UsageTracker.shared.setPremiumStatus(true)
                    showPaywall = false
                }
            )
        }
        .overlay(alignment: .top) {
            // AI Error Toast
            if showAIErrorToast, let errorMessage = aiErrorMessage {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Error")
                            .font(.caption.weight(.semibold))
                        Text(errorMessage)
                            .font(.caption2)
                            .lineLimit(2)
                    }
                    Spacer()
                    Button {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showAIErrorToast = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            aiErrorMessage = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: 400)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        // Phase 4: Style Transfer & Theme Expansion Sheets
        .sheet(isPresented: $showStyleTransferSheet) {
            if FeatureGate.canAccess(.styleTransfer) {
                StyleTransferSheet(
                    currentText: currentText,
                    onSelect: { suggestion in
                        onInsertRapSuggestion(suggestion)
                    },
                    onDismiss: {
                        showStyleTransferSheet = false
                    }
                )
            } else {
                PaywallView(
                    featureName: FeatureGate.requiredTier(for: .styleTransfer).displayName + " Features",
                    onDismiss: {
                        showStyleTransferSheet = false
                    },
                    onSubscribe: {
                        Task {
                            await SubscriptionManager.shared.checkSubscriptionStatus()
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showThemeExpansionSheet) {
            if FeatureGate.canAccess(.themeExpansion) {
                ThemeExpansionSheet(
                    currentText: currentText,
                    currentThemes: extractThemes(currentText),
                    onSelect: { suggestion in
                        onInsertRapSuggestion(suggestion)
                    },
                    onDismiss: {
                        showThemeExpansionSheet = false
                    }
                )
            } else {
                PaywallView(
                    featureName: FeatureGate.requiredTier(for: .themeExpansion).displayName + " Features",
                    onDismiss: {
                        showThemeExpansionSheet = false
                    },
                    onSubscribe: {
                        Task {
                            await SubscriptionManager.shared.checkSubscriptionStatus()
                        }
                    }
                )
            }
        }
        // Phase 5: Export Sheet
        .sheet(isPresented: $showExportSheet) {
            if FeatureGate.canAccess(.exportPDF) || FeatureGate.canAccess(.exportWord) {
                ExportSheet(
                    item: item,
                    onDismiss: {
                        showExportSheet = false
                    }
                )
            } else {
                PaywallView(
                    featureName: FeatureGate.requiredTier(for: .exportPDF).displayName + " Features",
                    onDismiss: {
                        showExportSheet = false
                    },
                    onSubscribe: {
                        Task {
                            await SubscriptionManager.shared.checkSubscriptionStatus()
                        }
                    }
                )
            }
        }
        .onDisappear {
            // Clean up timer when view disappears (replaces deinit which structs can't have)
            cancelAutoCollapseTimer()
        }
    }
}
