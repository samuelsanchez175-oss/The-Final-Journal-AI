import SwiftUI
import Combine
import SwiftData

// MARK: - Rap Suggestion View
// NOTE: Highlight is defined in ContentView.swift and is accessible here

struct RapSuggestionView: View {
    let suggestions: [RapSuggestion]
    let isLoading: Bool
    let loadingStep: String?
    let error: String?
    let onSelect: (RapSuggestion) -> Void
    let onCopy: ((RapSuggestion) -> Void)? // New: Copy callback with slam animation
    let onDismiss: () -> Void
    let contextText: String? // The text that prompted these suggestions (optional)
    let onRegenerate: (() -> Void)? // Regenerate callback (Phase 1)
    let currentSignalMode: SignalMode? // Current Signal Mode for Writers Critique
    let currentSignalProfile: SignalProfile? // Current Signal Profile for Writers Critique
    let silenceCommentary: CriticCommentary? // PR 6: Silence as valid output
    /// When non-nil with rightSuggestions/rightTitle, show side-by-side (v1 left, v2 right).
    let leftSuggestions: [RapSuggestion]?
    let rightSuggestions: [RapSuggestion]?
    let leftTitle: String?
    let rightTitle: String?
    let noteKey: String?
    let generationId: UUID?
    var generations: [Generation] = []   // deck of past generations (newest first); [] → fallback to flat suggestions
    @Binding var humanCriticFeedback: HumanCriticFeedback?
    @Binding var humanCriticLoading: Bool
    @Binding var humanCriticError: String?
    let onRetryHumanCritic: () -> Void

    private var isParallelMode: Bool {
        leftTitle != nil && rightTitle != nil
    }
    
    init(
        suggestions: [RapSuggestion],
        isLoading: Bool,
        loadingStep: String?,
        error: String?,
        onSelect: @escaping (RapSuggestion) -> Void,
        onCopy: ((RapSuggestion) -> Void)? = nil,
        onDismiss: @escaping () -> Void,
        contextText: String? = nil,
        onRegenerate: (() -> Void)? = nil,
        currentSignalMode: SignalMode? = nil,
        currentSignalProfile: SignalProfile? = nil,
        silenceCommentary: CriticCommentary? = nil,
        leftSuggestions: [RapSuggestion]? = nil,
        rightSuggestions: [RapSuggestion]? = nil,
        leftTitle: String? = nil,
        rightTitle: String? = nil,
        noteKey: String? = nil,
        generationId: UUID? = nil,
        generations: [Generation] = [],
        humanCriticFeedback: Binding<HumanCriticFeedback?>,
        humanCriticLoading: Binding<Bool>,
        humanCriticError: Binding<String?>,
        onRetryHumanCritic: @escaping () -> Void
    ) {
        self.suggestions = suggestions
        self.isLoading = isLoading
        self.loadingStep = loadingStep
        self.error = error
        self.onSelect = onSelect
        self.onCopy = onCopy
        self.onDismiss = onDismiss
        self.contextText = contextText
        self.onRegenerate = onRegenerate
        self.currentSignalMode = currentSignalMode
        self.currentSignalProfile = currentSignalProfile
        self.silenceCommentary = silenceCommentary
        self.leftSuggestions = leftSuggestions
        self.rightSuggestions = rightSuggestions
        self.leftTitle = leftTitle
        self.rightTitle = rightTitle
        self.noteKey = noteKey
        self.generationId = generationId
        self.generations = generations
        _humanCriticFeedback = humanCriticFeedback
        _humanCriticLoading = humanCriticLoading
        _humanCriticError = humanCriticError
        self.onRetryHumanCritic = onRetryHumanCritic
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var highlightedSuggestionId: UUID? = nil
    @State private var showComparison: Bool = false
    @State private var selectedSuggestionIds: Set<UUID> = []
    @State private var userFeedback: [UUID: RapSuggestion.SuggestionFeedback] = [:]
    @State private var showHistory: Bool = false
    @State private var showFavorites: Bool = false
    @State private var favoriteSuggestions: Set<UUID> = []
    @State private var showingFeedbackForm: UUID? = nil
    @State private var selectedCategories: [UUID: Set<FeedbackCategory>] = [:]
    @State private var feedbackText: [UUID: String] = [:]
    @State private var qualityMetricFeedback: [UUID: QualityMetricFeedback] = [:]
    @State private var highlightedLines: [UUID: Set<Int>] = [:] // Suggestion ID -> Set of line indices (liked)
    @State private var dislikedLines: [UUID: Set<Int>] = [:] // Suggestion ID -> Set of line indices (disliked)
    @State private var showingReasoning: String? = nil
    @State private var lastShownMode: SignalMode? = nil // Track last shown mode for auto-show logic
    @State private var showCritiqueSheet: Bool = false // For on-demand critique sheet
    @State private var tightenedSuggestions: [UUID: SignalAdjustedLine] = [:] // Store tightened versions
    @State private var showingTightened: Set<UUID> = [] // Track which suggestions show tightened version
    /// Parallel mode: 0 = V1 (default), 1 = V2. User swipes right to see V2.
    @State private var parallelPageIndex: Int = 0

    // Deck UI (Rap Suggestions redesign)
    @State private var deckIndex: Int = 0
    @State private var stackOn: Bool = false
    @State private var rhymeOn: Bool = false
    @State private var deckRhymeGroups: [RhymeHighlighterEngine.RhymeGroup] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AtmosphereGlow()
                
                if isLoading {
                    loadingView
                } else if let error = error {
                    errorView(error)
                } else if let silence = silenceCommentary {
                    silenceView(silence)
                } else if isParallelMode {
                    sideBySideView
                } else if suggestions.isEmpty {
                    emptyView
                } else {
                    deckView
                }
            }
            .navigationTitle("Rap Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        // Comparison toggle (hide in parallel mode)
                        if !isParallelMode && suggestions.count > 1 {
                            Button {
                                showComparison.toggle()
                            } label: {
                                Image(systemName: showComparison ? "list.bullet" : "square.split.2x2")
                            }
                            .accessibilityLabel(showComparison ? "List view" : "Comparison view")
                        }
                        
                        // History button (Phase 1)
                        Button {
                            showHistory = true
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                        .accessibilityLabel("Suggestion history")
                        
                        // Favorites button (Phase 1)
                        Button {
                            showFavorites = true
                        } label: {
                            Image(systemName: "star")
                        }
                        .accessibilityLabel("Favorite suggestions")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showComparison) {
                SuggestionComparisonView(
                    suggestions: suggestions,
                    selectedIds: $selectedSuggestionIds,
                    onSelect: onSelect,
                    onDismiss: { showComparison = false }
                )
            }
            .sheet(isPresented: $showHistory) {
                SuggestionHistoryView(
                    onDismiss: { showHistory = false },
                    onSelect: { suggestion in
                        onSelect(suggestion)
                        showHistory = false
                        dismiss()
                    }
                )
            }
                .sheet(isPresented: $showFavorites) {
                FavoriteSuggestionsView(
                    favorites: Array(favoriteSuggestions),
                    onDismiss: { showFavorites = false },
                    onSelect: { suggestion in
                        onSelect(suggestion)
                        showFavorites = false
                        dismiss()
                    }
                )
            }
            .sheet(isPresented: $showCritiqueSheet) {
                if let mode = currentSignalMode, let profile = currentSignalProfile {
                    WritersCritiqueSheet(mode: mode, profile: profile)
                }
            }
            .onAppear {
                // Track suggestion view
                for suggestion in suggestions {
                    SuggestionInteractionTracker.shared.trackSuggestionView(suggestionId: suggestion.id)
                }
            }
            .onDisappear {
                // Track view durations when view disappears
                for _ in suggestions {
                    // This would ideally track actual view time, but for now we'll use a placeholder
                    // In a real implementation, you'd track when each suggestion appeared/disappeared
                }
            }
        }
        .alert("Why this suggestion?", isPresented: Binding(
            get: { showingReasoning != nil },
            set: { if !$0 { showingReasoning = nil } }
        )) {
            Button("OK") {
                showingReasoning = nil
            }
        } message: {
            if let reasoning = showingReasoning {
                Text(reasoning)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            if let step = loadingStep {
                Text(step)
                    .font(.subheadline)
                    .foregroundStyle(Momentum.contentSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - Error View
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Silence View (PR 6)
    
    private func silenceView(_ commentary: CriticCommentary) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "text.bubble")
                    .font(.system(size: 48))
                    .foregroundStyle(Momentum.contentSecondary)

                Text("No Line Generated")
                    .font(.headline)

                HumanCriticSectionView(
                    feedback: humanCriticFeedback,
                    isLoading: humanCriticLoading,
                    errorMessage: humanCriticError,
                    onRetry: onRetryHumanCritic
                )
                .padding(.horizontal, 20)

                if humanCriticFeedback == nil && !humanCriticLoading {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(commentary.explanation)
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                            .multilineTextAlignment(.center)
                        Text(commentary.guidance)
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 24)
        }
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.bubble")
                .font(.system(size: 48))
                .foregroundStyle(Momentum.contentSecondary)
            
            Text("No Suggestions")
                .font(.headline)
            
            Text("Try adjusting your verse or check your API key settings.")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Suggestions List
    
    // MARK: - Deck (Rap Suggestions redesign)

    /// Generations to show in the deck. Falls back to wrapping the flat `suggestions`
    /// as a single generation when the engine deck wasn't passed (recall / improve-flow).
    private var deckGenerations: [Generation] {
        if !generations.isEmpty { return generations }
        return [Generation(
            id: generationId ?? suggestions.first?.id ?? UUID(),
            suggestions: suggestions,
            critic: humanCriticFeedback,
            createdAt: Date(),
            isFavorite: false,
            isFresh: false
        )]
    }

    /// Text of the currently-visible generation (for the island's rhyme-groups popover).
    private var currentDeckText: String {
        let gens = deckGenerations
        guard !gens.isEmpty else { return "" }
        let i = min(max(deckIndex, 0), gens.count - 1)
        return gens[i].suggestions.map(\.text).joined(separator: "\n")
    }

    private var deckView: some View {
        ZStack(alignment: .bottom) {
            RapDeckView(
                generations: deckGenerations,
                index: $deckIndex,
                stackOn: stackOn,
                rhymeOn: rhymeOn,
                criticFeedback: humanCriticFeedback,
                criticLoading: humanCriticLoading,
                criticError: humanCriticError,
                onRetryCritic: onRetryHumanCritic,
                onTapLine: { suggestion, lineIndex in
                    toggleLineFeedback(suggestionId: suggestion.id, lineIndex: lineIndex)
                }
            )
            RapIslandToolbar(
                rhymeOn: $rhymeOn,
                stackOn: $stackOn,
                rhymeGroups: deckRhymeGroups,
                currentText: currentDeckText
            )
            .padding(.bottom, 12)
        }
        .onChange(of: deckGenerations.first?.id) { _, _ in
            deckIndex = 0   // newest generation auto-lands at the front (spec §3.6)
        }
        .task(id: currentDeckText) {
            // Rhyme groups for the island's magnifying-glass popover (visible generation).
            guard !currentDeckText.isEmpty else { deckRhymeGroups = []; return }
            let (groups, _) = await RhymeHighlighterEngine.computeAll(text: currentDeckText)
            deckRhymeGroups = groups
        }
    }

    private var suggestionsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(suggestions) { suggestion in
                    suggestionCard(suggestion)
                }

                HumanCriticSectionView(
                    feedback: humanCriticFeedback,
                    isLoading: humanCriticLoading,
                    errorMessage: humanCriticError,
                    onRetry: onRetryHumanCritic
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Side-by-Side (Model G v1 default, swipe right for v2)
    
    private var sideBySideView: some View {
        VStack(spacing: 0) {
            // Page indicator: V1 (default) | V2 — swipe to switch
            HStack(spacing: 8) {
                Text(leftTitle ?? "Model G v1")
                    .font(.subheadline.weight(parallelPageIndex == 0 ? .semibold : .regular))
                    .foregroundStyle(parallelPageIndex == 0 ? .primary : .secondary)
                Text("•")
                    .foregroundStyle(.tertiary)
                Text(rightTitle ?? "Model G v2")
                    .font(.subheadline.weight(parallelPageIndex == 1 ? .semibold : .regular))
                    .foregroundStyle(parallelPageIndex == 1 ? .primary : .secondary)
                Spacer()
                Text("Swipe to switch")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial.opacity(0.5))
            
            TabView(selection: $parallelPageIndex) {
                parallelColumn(
                    title: leftTitle ?? "Model G v1",
                    suggestions: leftSuggestions ?? []
                )
                .tag(0)
                parallelColumn(
                    title: rightTitle ?? "Model G v2",
                    suggestions: rightSuggestions ?? []
                )
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .padding(.vertical, 8)
    }
    
    private func parallelColumn(title: String, suggestions: [RapSuggestion]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Momentum.contentSecondary)
            ScrollView {
                VStack(spacing: 16) {
                    if suggestions.isEmpty {
                        Text("No result")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    } else {
                        ForEach(suggestions) { suggestion in
                            suggestionCard(suggestion)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Suggestion Card
    
    private func suggestionCard(_ suggestion: RapSuggestion) -> some View {
        let lines: [String] = suggestion.text
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        
        let hasAnyFeedback = !(highlightedLines[suggestion.id]?.isEmpty ?? true) || !(dislikedLines[suggestion.id]?.isEmpty ?? true)

        return VStack(alignment: .leading, spacing: 0) {
            cardContent(suggestion: suggestion, lines: lines, hasAnyFeedback: hasAnyFeedback)
            feedbackButtons(suggestion)
        }
    }
    
    @ViewBuilder
    private func cardContent(suggestion: RapSuggestion, lines: [String], hasAnyFeedback: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if humanCriticFeedback == nil,
               let mode = currentSignalMode,
               let profile = currentSignalProfile,
               let context = contextText,
               !context.isEmpty {
                lineComparisonCritique(
                    userLine: context,
                    generatedLine: suggestion.text,
                    mode: mode,
                    profile: profile,
                    suggestion: suggestion
                )
            }

            suggestionTextSection(suggestion, lines: lines, hasAnyFeedback: hasAnyFeedback)
            
            // Legacy A&R block hidden when human critic is active (calm editor MVP).
            if humanCriticFeedback == nil,
               let critique = suggestion.arCritique, !critique.isEmpty {
                arCritiqueSection(critique: critique)
            }

            suggestionThemeTags(suggestion)
            suggestionQualityIndicators(suggestion)
            feedbackLearningIndicator() // Show when feedback is being used
            suggestionSignalNote(suggestion)
            
            // "Tighten for authority" toggle (Layer 8 - Comparative Learning)
            if let mode = currentSignalMode, let constraints = getConstraintsForMode(mode) {
                tightenForAuthoritySection(suggestion: suggestion, mode: mode, constraints: constraints)
            }
            
            // Advanced mode display (Layer 10 - Advanced Exposure)
            if SignalAdvancedExposure.shared.isAdvancedModeEnabled(),
               let mode = currentSignalMode,
               let profile = currentSignalProfile,
               let text = contextText,
               let axes = getAxesForMode(mode, profile: profile) {
                let metrics = SignalIngest.shared.analyzeBehavior(text: text)
                let advancedInfo = SignalAdvancedExposure.shared.generateAdvancedInfo(
                    metrics: metrics,
                    mode: mode,
                    axes: axes,
                    profile: profile
                )
                signalModeInfo(mode: mode, axes: axes, profile: profile, advancedInfo: advancedInfo)
            }
        }
        .padding(16)
        .background(cardBackgroundView())
    }
    
    // Helper to get constraints for current mode
    private func getConstraintsForMode(_ mode: SignalMode) -> ConstraintRules? {
        guard let profile = currentSignalProfile, let text = contextText else { return nil }
        let axes = SignalAxes.calibrateAxes(profile: profile, mode: mode, text: text)
        return SignalConstraintEngine.shared.generateConstraints(mode: mode, axes: axes)
    }
    
    // Helper to get axes for current mode
    private func getAxesForMode(_ mode: SignalMode, profile: SignalProfile) -> SignalAxes? {
        guard let text = contextText else { return nil }
        return SignalAxes.calibrateAxes(profile: profile, mode: mode, text: text)
    }
    
    // MARK: - Line Comparison Critique (PR 5)
    
    @ViewBuilder
    private func lineComparisonCritique(userLine: String, generatedLine: String, mode: SignalMode, profile: SignalProfile, suggestion: RapSuggestion) -> some View {
        // Get last line from context for comparison
        let lastUserLine = userLine.split(separator: "\n", omittingEmptySubsequences: false).last.map { String($0) } ?? userLine
        
        // Get context info from engine (we'll need to pass this through)
        // For now, extract from contextText
        let allLines = (contextText ?? "").split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
        let previousLines = Array(allLines.suffix(6))
        let fullTextLineCount = allLines.count
        let contextLineCount = min(6, fullTextLineCount)
        
        // Get axes and strength mode for lexicon feedback
        let axes = getAxesForMode(mode, profile: profile)
        let strengthMode = ThematicStateDetector.shared.checkStrengthMode(
            text: contextText ?? "",
            axes: axes ?? SignalAxes(
                exposureRisk: .low,
                authorityPosture: .unstable,
                socialAction: .assert,
                audienceScope: .selfOnly
            ),
            profile: profile
        )
        
        let comparison = WritersCritiqueGenerator.compareLines(
            userLine: lastUserLine,
            generatedLine: generatedLine,
            mode: mode,
            profile: profile,
            suggestionReasoning: suggestion.reasoning, // Why these lines were suggested
            previousLines: previousLines,
            fullTextLineCount: fullTextLineCount,
            contextLineCount: contextLineCount,
            axes: axes,
            strengthMode: strengthMode
        )
        
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .padding(.vertical, 4)
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "text.bubble")
                    .font(.caption)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Critic")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                    
                    // Context information
                    Text(comparison.contextInfo)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .italic()
                    
                    LineComparisonCommentaryView(commentary: comparison.commentary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func suggestionTextSection(_ suggestion: RapSuggestion, lines: [String], hasAnyFeedback: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if !hasAnyFeedback {
                hintTextView
            }
            
            ForEach(Array(lines.enumerated()), id: \.offset) { pair in
                let index = pair.offset
                let line = pair.element
                let isLiked = highlightedLines[suggestion.id]?.contains(index) ?? false
                let isDisliked = dislikedLines[suggestion.id]?.contains(index) ?? false
                let isModelGMoment = suggestion.modelGMomentLineIndices?.contains(index) ?? false
                SuggestionLineRow(
                    line: line,
                    isLiked: isLiked,
                    isDisliked: isDisliked,
                    isHighlighted: highlightedSuggestionId == suggestion.id,
                    isModelGMoment: isModelGMoment,
                    onTap: { toggleLineFeedback(suggestionId: suggestion.id, lineIndex: index) }
                )
            }
        }
        .padding(.vertical, 4)
        .background(textSectionBackground(suggestionId: suggestion.id))
    }
    
    private var hintTextView: some View {
        HStack(spacing: 4) {
            Image(systemName: "hand.point.up.left")
                .font(.caption2)
            Text("Tap lines: 1st tap = dislike, 2nd tap = like, 3rd tap = clear")
                .font(.caption2)
        }
        .foregroundStyle(Momentum.contentSecondary)
        .padding(.bottom, 4)
    }
    
    private func textSectionBackground(suggestionId: UUID) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(highlightedSuggestionId == suggestionId ? Color.blue.opacity(0.15) : Color.clear)
            .animation(.easeInOut(duration: 0.2), value: highlightedSuggestionId)
    }
    
    @ViewBuilder
    private func suggestionThemeTags(_ suggestion: RapSuggestion) -> some View {
        if !suggestion.themes.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(suggestion.themes, id: \.self) { theme in
                        themeTag(theme)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
    
    @ViewBuilder
    private func suggestionQualityIndicators(_ suggestion: RapSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                qualityIndicator(
                    icon: "star.fill",
                    label: "Signal Strength",
                    value: suggestion.signalStrength ?? suggestion.confidence,
                    color: .yellow
                )
                
                // On-demand Writers Critique button
                if currentSignalMode != nil && currentSignalProfile != nil {
                    Button {
                        showCritiqueSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    .accessibilityLabel("Show Writer's Critique")
                }
                
                if let rhymeStrength = suggestion.rhymeStrength {
                    qualityIndicator(
                        icon: "textformat.123",
                        label: "Rhymes",
                        value: rhymeStrength,
                        color: .blue
                    )
                }
                
                if let flowMatch = suggestion.flowMatch {
                    qualityIndicator(
                        icon: "waveform",
                        label: "Flow",
                        value: flowMatch,
                        color: .green
                    )
                }
                
                if let styleMatch = suggestion.styleMatch {
                    qualityIndicator(
                        icon: "pencil.and.outline",
                        label: "Style",
                        value: styleMatch,
                        color: .purple
                    )
                }
            }
            
            if let source = suggestion.source {
                HStack(spacing: 4) {
                    Image(systemName: "music.note")
                        .font(.caption2)
                    Text(source)
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                        .lineLimit(1)
                }
            }
        }
    }
    
    @ViewBuilder
    private func feedbackLearningIndicator() -> some View {
        let feedbackStats = SuggestionFeedbackManager.shared.getFeedbackStats()
        let hasFeedback = feedbackStats.totalFeedback >= 3
        
        if hasFeedback {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                Text("AI learning from your feedback")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                Spacer()
                Text("\(feedbackStats.totalFeedback) feedback entries")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.blue.opacity(0.1))
            )
        }
    }
    
    @ViewBuilder
    private func suggestionSignalNote(_ suggestion: RapSuggestion) -> some View {
        // Show Signal Note if available, otherwise fall back to reasoning
        if let signalNote = suggestion.signalNote {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    Text("Signal Read")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                Text(signalNote)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                    .multilineTextAlignment(.leading)
                
                // Signal Pattern counter (optional - shows frequency)
                if let noteType = SignalMemory.shared.determineNoteType(from: signalNote) {
                    let patternSummary = SignalMemory.shared.getPatternSummary(noteType: noteType, timeWindow: 86400)
                    if patternSummary.frequency > 1 {
                        Text(patternSummary.displayText)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 2)
                    }
                }
            }
        } else if let reasoning = suggestion.reasoning {
            Text(reasoning)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder
    private func writersCritiqueSection(mode: SignalMode, profile: SignalProfile) -> some View {
        let critique = WritersCritiqueGenerator.shared.generateCritique(for: mode, profile: profile)
        
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "book.closed")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text("Writer's Room")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
            }
            
            Text(critique.fullCritique)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.leading)
            
            // Expandable details (optional)
            DisclosureGroup("What this means") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Allowed: \(critique.whatIsAllowed)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text("Unsafe: \(critique.whatIsUnsafe)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text("Premature: \(critique.whatIsPremature)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .font(.caption2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func arCritiqueSection(critique: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "mic.fill")
                    .font(.caption2)
                    .foregroundStyle(.purple)
                Text("A&R Critique")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.purple)
            }
            
            Text(critique)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func tightenForAuthoritySection(suggestion: RapSuggestion, mode: SignalMode, constraints: ConstraintRules) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                if showingTightened.contains(suggestion.id) {
                    showingTightened.remove(suggestion.id)
                } else {
                    // Generate tightened version
                    Task {
                        do {
                            let adjusted = try await SignalComparison.shared.generateSignalAdjustedVersion(
                                originalLine: suggestion.text,
                                mode: mode,
                                constraints: constraints
                            )
                            await MainActor.run {
                                tightenedSuggestions[suggestion.id] = adjusted
                                showingTightened.insert(suggestion.id)
                            }
                        } catch {
                            // Handle error silently
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: showingTightened.contains(suggestion.id) ? "lock.fill" : "lock.open")
                        .font(.caption2)
                    Text("Tighten for authority")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.blue)
            }
            
            // Show comparison if available
            if showingTightened.contains(suggestion.id),
               let adjusted = tightenedSuggestions[suggestion.id] {
                VStack(alignment: .leading, spacing: 6) {
                    // Original (greyed)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Original")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text(adjusted.original)
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                            .strikethrough()
                    }
                    
                    // Adjusted (highlighted)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Adjusted")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                        Text(adjusted.adjusted)
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.1))
                    )
                    
                    // Explanation
                    Text(adjusted.explanation)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .italic()
                }
                .padding(.top, 4)
            }
        }
    }
    
    @ViewBuilder
    private func signalModeInfo(mode: SignalMode, axes: SignalAxes, profile: SignalProfile, advancedInfo: SignalAdvancedInfo) -> some View {
        
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "gearshape.fill")
                    .font(.caption2)
                    .foregroundStyle(.purple)
                Text("Signal Mode: \(mode.displayName)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.purple)
            }
            
            Text(advancedInfo.modeSelectionReason)
                .font(.caption2)
                .foregroundStyle(.tertiary)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Exposure: \(axes.exposureRisk.rawValue)")
                        .font(.caption2)
                    Text("Authority: \(axes.authorityPosture.rawValue)")
                        .font(.caption2)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Action: \(axes.socialAction.rawValue)")
                        .font(.caption2)
                    Text("Audience: \(axes.audienceScope.rawValue)")
                        .font(.caption2)
                }
            }
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.purple.opacity(0.1))
        )
    }
    
    private func cardBackgroundView() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Momentum.surfaceElevated)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.overlay)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    private func feedbackButtons(_ suggestion: RapSuggestion) -> some View {
        VStack(spacing: 0) {
            // User Feedback Buttons (Phase 1: AI Quality Foundation)
            HStack(spacing: 8) {
                // Favorite button
                Button {
                    if favoriteSuggestions.contains(suggestion.id) {
                        favoriteSuggestions.remove(suggestion.id)
                        SuggestionFavoriteManager.shared.removeFavorite(suggestion.id)
                    } else {
                        favoriteSuggestions.insert(suggestion.id)
                        SuggestionFavoriteManager.shared.addFavorite(suggestion)
                        // Track favorite
                        SuggestionInteractionTracker.shared.trackSuggestionAction(
                            suggestionId: suggestion.id,
                            action: .favorited
                        )
                        UserBehaviorTracker.shared.trackSuggestionInteraction(action: .favorited, suggestionId: suggestion.id)
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Image(systemName: favoriteSuggestions.contains(suggestion.id) ? "star.fill" : "star")
                        .font(.subheadline)
                        .foregroundStyle(favoriteSuggestions.contains(suggestion.id) ? .yellow : .secondary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(favoriteSuggestions.contains(suggestion.id) ? Color.yellow.opacity(0.2) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(favoriteSuggestions.contains(suggestion.id) ? "Remove from favorites" : "Add to favorites")

                // Thumbs Down
                Button {
                    let feedback: RapSuggestion.SuggestionFeedback = .disliked
                    userFeedback[suggestion.id] = feedback

                    // PR 7: Taste Memory - Record rejected suggestion
                    TasteMemory.shared.recordRejected(
                        suggestion: suggestion,
                        signalMode: currentSignalMode,
                        signalProfile: currentSignalProfile,
                        registers: nil, // Will be inferred if needed
                        axes: nil, // Will be inferred if needed
                        axisProfile: nil, // Will be inferred if needed
                        alignmentScore: nil // Will be available if scored
                    )

                    // Show contextual feedback form
                    showingFeedbackForm = suggestion.id

                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                } label: {
                    Image(systemName: userFeedback[suggestion.id] == .disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .font(.subheadline)
                        .foregroundStyle(userFeedback[suggestion.id] == .disliked ? .red : .secondary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(userFeedback[suggestion.id] == .disliked ? Color.red.opacity(0.2) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dislike suggestion")
                .sheet(isPresented: Binding(
                    get: { showingFeedbackForm != nil },
                    set: { if !$0 { showingFeedbackForm = nil } }
                )) {
                    if let suggestionId = showingFeedbackForm,
                       let suggestion = suggestions.first(where: { $0.id == suggestionId }) {
                        ContextualFeedbackView(
                            suggestion: suggestion,
                            contextText: contextText ?? "",
                            selectedCategories: Binding(
                                get: { selectedCategories[suggestion.id] ?? [] },
                                set: { selectedCategories[suggestion.id] = $0 }
                            ),
                            feedbackText: Binding(
                                get: { feedbackText[suggestion.id] ?? "" },
                                set: { feedbackText[suggestion.id] = $0 }
                            ),
                            qualityMetricFeedback: Binding(
                                get: { qualityMetricFeedback[suggestion.id] },
                                set: { qualityMetricFeedback[suggestion.id] = $0 }
                            ),
                            likedLineIndices: Binding(
                                get: { highlightedLines[suggestion.id] ?? [] },
                                set: { highlightedLines[suggestion.id] = $0 }
                            ),
                            dislikedLineIndices: Binding(
                                get: { dislikedLines[suggestion.id] ?? [] },
                                set: { dislikedLines[suggestion.id] = $0 }
                            ),
                            onSave: {
                                saveContextualFeedback(suggestion: suggestion)
                                showingFeedbackForm = nil
                            },
                            onDismiss: {
                                showingFeedbackForm = nil
                            }
                        )
                    }
                }

                // Thumbs Up
                Button {
                    let feedback: RapSuggestion.SuggestionFeedback = .liked
                    userFeedback[suggestion.id] = feedback

                    // If specific lines were highlighted as liked, include that in feedback
                    let likedLineIndices = highlightedLines[suggestion.id] ?? []
                    if !likedLineIndices.isEmpty {
                        let lines = suggestion.text.components(separatedBy: "\n").filter { !$0.isEmpty }
                        let likedLineTexts = likedLineIndices.compactMap { index in
                            index < lines.count ? "Line \(index + 1): \(lines[index])" : nil
                        }

                        SuggestionFeedbackManager.shared.recordEnhancedFeedback(
                            suggestionId: suggestion.id,
                            feedback: .liked,
                            suggestionText: suggestion.text,
                            context: contextText ?? "",
                            categories: [],
                            qualityMetricCorrections: nil,
                            specificIssues: [],
                            expectedVsActual: "Liked lines: \(likedLineTexts.joined(separator: ", "))",
                            noteKey: noteKey,
                            generationId: generationId
                        )
                        AIGenerationLedger.applyFeedbackGrade(
                            generationId: generationId,
                            suggestionId: suggestion.id,
                            feedback: .liked
                        )
                    } else {
                        recordFeedback(suggestion: suggestion, feedback: feedback)
                    }

                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Image(systemName: userFeedback[suggestion.id] == .liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.subheadline)
                        .foregroundStyle(userFeedback[suggestion.id] == .liked ? .green : .secondary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(userFeedback[suggestion.id] == .liked ? Color.green.opacity(0.2) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Like suggestion")

                Spacer()

                // Regenerate button (Phase 1)
                if let onRegenerate = onRegenerate {
                    Button {
                        // Track regenerate
                        SuggestionInteractionTracker.shared.trackRegenerate(
                            context: contextText ?? "",
                            previousSuggestionIds: suggestions.map { $0.id }
                        )
                        UserBehaviorTracker.shared.trackSuggestionInteraction(action: .regenerated, suggestionId: nil)

                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onRegenerate()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Regenerate suggestions")
                }

                // Explain AI Button
                if let _ = suggestion.reasoning {
                    Button {
                        // Show reasoning in alert or sheet
                        showReasoning(suggestion)
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Why this suggestion?")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .onAppear {
                // Load favorites
                favoriteSuggestions = SuggestionFavoriteManager.shared.getFavoriteIds()
            }

            // Action buttons
            HStack(spacing: 12) {
                // Copy button
                Button {
                    // Track interaction
                    SuggestionInteractionTracker.shared.trackSuggestionAction(
                        suggestionId: suggestion.id,
                        action: .copied
                    )
                    UserBehaviorTracker.shared.trackSuggestionInteraction(action: .copied, suggestionId: suggestion.id)

                    // Highlight the card
                    withAnimation(.easeInOut(duration: 0.2)) {
                        highlightedSuggestionId = suggestion.id
                    }

                    // Copy to clipboard
                    UIPasteboard.general.string = suggestion.text

                    // Trigger slam animation via callback
                    if let onCopy = onCopy {
                        onCopy(suggestion)
                    }

                    // Dismiss after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)

                // Insert button (original behavior)
                Button {
                    // Track interaction
                    SuggestionInteractionTracker.shared.trackSuggestionAction(
                        suggestionId: suggestion.id,
                        action: .inserted
                    )
                    UserBehaviorTracker.shared.trackSuggestionInteraction(action: .inserted, suggestionId: suggestion.id)

                    onSelect(suggestion)
                    dismiss()
                } label: {
                    Label("Insert", systemImage: "text.insert")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Momentum.surfaceElevated)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
    }
    
    @ViewBuilder
    private func themeTag(_ theme: String) -> some View {
        Text(theme)
            .font(.caption2.weight(.medium))
            .foregroundStyle(Momentum.contentSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(Color.black.opacity(colorScheme == .dark ? 0.1 : 0))
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
            )
    }
    
    // MARK: - Feedback Recording
    
    private func recordFeedback(suggestion: RapSuggestion, feedback: RapSuggestion.SuggestionFeedback) {
        SuggestionFeedbackManager.shared.recordFeedback(
            suggestionId: suggestion.id,
            feedback: feedback,
            suggestionText: suggestion.text,
            context: contextText ?? "",
            noteKey: noteKey,
            generationId: generationId
        )
        
        // Track interaction
        SuggestionInteractionTracker.shared.trackSuggestionAction(
            suggestionId: suggestion.id,
            action: feedback == .liked ? .liked : .disliked
        )

        if feedback == .liked {
            TasteMemory.shared.recordAccepted(
                suggestion: suggestion,
                signalMode: currentSignalMode,
                signalProfile: currentSignalProfile
            )
        } else {
            TasteMemory.shared.recordRejected(
                suggestion: suggestion,
                signalMode: currentSignalMode,
                signalProfile: currentSignalProfile
            )
        }
    }
    
    private func toggleLineFeedback(suggestionId: UUID, lineIndex: Int) {
        // Cycle through: neutral -> dislike -> like -> neutral
        var likedSet = highlightedLines[suggestionId] ?? []
        var dislikedSet = dislikedLines[suggestionId] ?? []
        
        if likedSet.contains(lineIndex) {
            // Currently liked, remove it (back to neutral)
            likedSet.remove(lineIndex)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else if dislikedSet.contains(lineIndex) {
            // Currently disliked, switch to liked
            dislikedSet.remove(lineIndex)
            likedSet.insert(lineIndex)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            // Neutral, add to disliked
            dislikedSet.insert(lineIndex)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        
        highlightedLines[suggestionId] = likedSet
        dislikedLines[suggestionId] = dislikedSet
    }
    
    private func saveContextualFeedback(suggestion: RapSuggestion) {
        let categories = selectedCategories[suggestion.id] ?? []
        let issues = feedbackText[suggestion.id]?.isEmpty == false ? [feedbackText[suggestion.id]!] : []
        let qualityMetrics = qualityMetricFeedback[suggestion.id]
        let expectedVsActual = feedbackText[suggestion.id]
        
        // Include line-specific feedback
        let likedLineIndices = highlightedLines[suggestion.id] ?? []
        let dislikedLineIndices = dislikedLines[suggestion.id] ?? []
        
        var specificIssues = issues
        if !dislikedLineIndices.isEmpty {
            let lines = suggestion.text.components(separatedBy: "\n").filter { !$0.isEmpty }
            let dislikedLineTexts = dislikedLineIndices.compactMap { index in
                index < lines.count ? "Line \(index + 1): \(lines[index])" : nil
            }
            specificIssues.append(contentsOf: dislikedLineTexts)
        }
        
        if !likedLineIndices.isEmpty {
            let lines = suggestion.text.components(separatedBy: "\n").filter { !$0.isEmpty }
            let likedLineTexts = likedLineIndices.compactMap { index in
                index < lines.count ? "Line \(index + 1): \(lines[index])" : nil
            }
            // Add liked lines to expectedVsActual or create a note
            if expectedVsActual == nil || expectedVsActual!.isEmpty {
                feedbackText[suggestion.id] = "Liked lines: \(likedLineTexts.joined(separator: ", "))"
            }
        }
        
        SuggestionFeedbackManager.shared.recordEnhancedFeedback(
            suggestionId: suggestion.id,
            feedback: .disliked,
            suggestionText: suggestion.text,
            context: contextText ?? "",
            categories: Array(categories),
            qualityMetricCorrections: qualityMetrics,
            specificIssues: specificIssues,
            expectedVsActual: feedbackText[suggestion.id],
            noteKey: noteKey,
            generationId: generationId
        )
        
        // Track interaction
        let metadata: [String: String] = [
            "categories": categories.map { $0.rawValue }.joined(separator: ","),
            "has_text_feedback": issues.isEmpty ? "false" : "true",
            "liked_lines": likedLineIndices.map { String($0) }.joined(separator: ","),
            "disliked_lines": dislikedLineIndices.map { String($0) }.joined(separator: ",")
        ]
        
        SuggestionInteractionTracker.shared.trackSuggestionAction(
            suggestionId: suggestion.id,
            action: .disliked,
            metadata: metadata
        )
    }
    
    // MARK: - Show Reasoning
    
    private func showReasoning(_ suggestion: RapSuggestion) {
        showingReasoning = suggestion.reasoning
    }
    
    // MARK: - Quality Indicator Component
    
    @ViewBuilder
    private func qualityIndicator(icon: String, label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(String(format: "%.0f%%", value * 100))
                .font(.caption2)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule(style: .continuous)
                .fill(color.opacity(0.15))
        )
    }
}

// MARK: - Suggestion Line Row (extracted to reduce type-checking complexity)
private struct SuggestionLineRow: View {
    let line: String
    let isLiked: Bool
    let isDisliked: Bool
    let isHighlighted: Bool
    let isModelGMoment: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(line)
                .font(.body)
                .foregroundStyle(isLiked ? .green : (isDisliked ? .red : (isHighlighted ? .blue : .primary)))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isLiked ? Color.green.opacity(0.15) : (isDisliked ? Color.red.opacity(0.15) : Color.clear))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isLiked ? Color.green.opacity(0.5) : (isDisliked ? Color.red.opacity(0.5) : Color.clear), lineWidth: 1)
                )
                .onTapGesture { onTap() }

            if isModelGMoment {
                Text("✴")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            if isLiked {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else if isDisliked {
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

// MARK: - Suggestion Comparison View (Phase 1: AI Quality Foundation)

struct SuggestionComparisonView: View {
    let suggestions: [RapSuggestion]
    @Binding var selectedIds: Set<UUID>
    let onSelect: (RapSuggestion) -> Void
    let onDismiss: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Compare Suggestions")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("Select up to 3 suggestions to compare side-by-side")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                        .padding(.horizontal)
                    
                    // Comparison grid
                    if selectedIds.count > 0 {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(selectedIds.count, 3)), spacing: 12) {
                            ForEach(suggestions.filter { selectedIds.contains($0.id) }) { suggestion in
                                comparisonCard(suggestion)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // All suggestions list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Suggestions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(suggestions) { suggestion in
                            comparisonRow(suggestion)
                        }
                    }
                }
            }
            .background(
                Rectangle()
                    .fill(Momentum.surfaceElevated)
                    .ignoresSafeArea()
            )
            .navigationTitle("Compare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func comparisonCard(_ suggestion: RapSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(suggestion.text)
                .font(.caption)
                .lineLimit(6)
            
            if let confidence = suggestion.confidence as Double? {
                Text("\(Int(confidence * 100))%")
                    .font(.caption2)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Momentum.surfaceElevated)
        )
    }
    
    @ViewBuilder
    private func comparisonRow(_ suggestion: RapSuggestion) -> some View {
        HStack {
            Button {
                if selectedIds.contains(suggestion.id) {
                    selectedIds.remove(suggestion.id)
                } else if selectedIds.count < 3 {
                    selectedIds.insert(suggestion.id)
                }
            } label: {
                Image(systemName: selectedIds.contains(suggestion.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedIds.contains(suggestion.id) ? .blue : .secondary)
            }
            
            Text(suggestion.text)
                .font(.caption)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(selectedIds.contains(suggestion.id) ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
}

// MARK: - Rap Suggestion Engine (Orchestrator)

class RapSuggestionEngine: ObservableObject {
    @Published var suggestions: [RapSuggestion] = []

    // Deck UI (Rap Suggestions redesign): each generation is a card, newest at index 0.
    // Populated in commitGeneration; consumed by RapDeckView once the body swap lands.
    @Published var generations: [Generation] = []
    @Published var currentGenerationIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var loadingStep: String?
    @Published var error: String?
    @Published var silenceCommentary: CriticCommentary? = nil  // PR 6: Silence as valid output
    
    // Store previous suggestions for recall (rolling history on this note)
    @Published var previousSuggestions: [RapSuggestion] = []
    /// Most recent generation batch — used for "Open Last Suggestions" and persistence.
    @Published var lastBatchSuggestions: [RapSuggestion] = []
    @Published var lastSessionGenerationId: UUID?
    @Published var lastSessionContextText: String?

    @Published var humanCriticFeedback: HumanCriticFeedback?
    @Published var humanCriticLoading: Bool = false
    @Published var humanCriticError: String?

    var hasRecallableSuggestions: Bool {
        silenceCommentary != nil
            || !lastBatchSuggestions.isEmpty
            || (isParallelModelG && (!suggestionsV1.isEmpty || !suggestionsV2.isEmpty))
    }
    
    // Parallel Model G v1 + v2: when true, UI shows suggestionsV1 (left) and suggestionsV2 (right) side-by-side
    @Published var suggestionsV1: [RapSuggestion] = []
    @Published var suggestionsV2: [RapSuggestion] = []
    @Published var isParallelModelG: Bool = false
    /// Model from the last `generateSuggestions` call; used for Regenerate when not in parallel Model G mode.
    private(set) var lastStandardGenerationModel: SuggestionModel = .modelG
    /// Stored for Regenerate when in parallel mode (ContentView passes these back into generateSuggestionsModelGParallel).
    var lastParallelDirectedParams: DirectedGenerationParams?
    var lastParallelRhymeGroupsByID: [RhymeGroupID: RhymeGroupSummary]?
    
    // Store current Signal Mode and Profile for Writers Critique
    @Published var currentSignalMode: SignalMode?
    @Published var currentSignalProfile: SignalProfile?
    
    // Store context information for critique
    @Published var contextLineCount: Int = 0
    @Published var fullTextLineCount: Int = 0
    @Published var previousLines: [String] = []
    
    private let analysisEngine = RapAnalysisEngine()
    private let api = RapSuggestionAPI.shared
    private lazy var filter: ConstraintFilter = {
        // Access FJCMUDICTStore via global accessor function
        return ConstraintFilter(phonemeStoreProvider: { getGlobalCMUDICTStore() })
    }()

    /// Call after a successful generation to update recall state, ledger, and optional note persistence.
    @MainActor
    func commitGeneration(
        batch: [RapSuggestion],
        contextText: String,
        model: SuggestionModel,
        noteKey: String?,
        noteTitle: String,
        persistTo item: Item?
    ) {
        let generationId = UUID()
        lastSessionGenerationId = generationId
        lastSessionContextText = contextText
        lastBatchSuggestions = batch

        // Deck UI: keep each generation as its own card, newest first (spec §3.6).
        let generation = Generation(
            id: generationId,
            suggestions: batch,
            critic: humanCriticFeedback,
            createdAt: Date(),
            isFavorite: false,
            isFresh: true
        )
        generations = GenerationDeck.inserting(generation, into: generations)
        currentGenerationIndex = 0

        previousSuggestions.append(contentsOf: batch)
        if previousSuggestions.count > NoteSuggestionSession.historyCap {
            previousSuggestions = Array(previousSuggestions.suffix(NoteSuggestionSession.historyCap))
        }

        AIGenerationLedger.record(
            generationId: generationId,
            noteKey: noteKey ?? "",
            noteTitle: noteTitle,
            contextText: contextText,
            model: model,
            suggestions: batch,
            silence: false
        )

        if let item {
            NoteSuggestionSessionStore.save(from: self, contextText: contextText, model: model, to: item)
        }
    }

    @MainActor
    func clearHumanCritic() {
        humanCriticFeedback = nil
        humanCriticLoading = false
        humanCriticError = nil
    }

    func refreshHumanCritic(userVerse: String, primarySuggestion: RapSuggestion?, themes: [String] = [], persistTo item: Item? = nil, model: SuggestionModel = .modelG) {
        Task { @MainActor in
            humanCriticLoading = true
            humanCriticError = nil
        }

        let generated = primarySuggestion?.text
        let voice = HumanCriticVoice(rawValue: UserDefaults.standard.string(forKey: "human_critic_voice") ?? "") ?? .calmEditor
        Task {
            do {
                let feedback = try await HumanCriticService.shared.generate(
                    userVerse: userVerse,
                    generatedSuggestion: generated,
                    themes: themes,
                    voice: voice
                )
                await MainActor.run {
                    self.humanCriticFeedback = feedback
                    self.humanCriticLoading = false
                    if let item {
                        NoteSuggestionSessionStore.save(from: self, contextText: userVerse, model: model, to: item)
                    }
                }
            } catch {
                await MainActor.run {
                    self.humanCriticLoading = false
                    if let api = error as? RapAPIError, case .missingAPIKey = api {
                        self.humanCriticError = "Add your API key in Profile → AI for personalized feedback."
                    } else {
                        self.humanCriticError = "Personal feedback unavailable. Try again."
                    }
                }
            }
        }
    }
    
    func generateSuggestions(text: String, highlights: [Highlight], model: SuggestionModel = .modelG, bpm: Int? = nil, key: String? = nil, scale: String? = nil, syllableMin: Int? = nil, syllableMax: Int? = nil, directedParams: DirectedGenerationParams? = nil, rhymeGroupsByID: [RhymeGroupID: RhymeGroupSummary]? = nil, audioURL: URL? = nil, transcriptionRhythmMapData: Data? = nil, noteKey: String? = nil, noteTitle: String = "", persistTo item: Item? = nil) async {
        await MainActor.run {
            isLoading = true
            error = nil
            clearHumanCritic()
            suggestions = []
            silenceCommentary = nil  // Clear any previous silence commentary
            isParallelModelG = false
            suggestionsV1 = []
            suggestionsV2 = []
            lastStandardGenerationModel = model
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        do {
            // Step 1: Extract metrics
            await MainActor.run {
                loadingStep = "Analyzing your verse..."
            }
            let metrics = analysisEngine.extractMetrics(text: text, highlights: highlights, bpm: bpm, key: key, scale: scale, syllableMin: syllableMin, syllableMax: syllableMax)
            
            // Store context information for critique
            let allLines = text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
            let previousLines = Array(allLines.suffix(6))
            let fullTextLineCount = allLines.count
            let contextLineCount = min(6, fullTextLineCount)
            
            await MainActor.run {
                self.previousLines = previousLines
                self.fullTextLineCount = fullTextLineCount
                self.contextLineCount = contextLineCount
            }
            
            // SIGNAL LAYER: Step 1 - Signal Ingest (analyze behavior)
            let signalMetrics = SignalIngest.shared.analyzeBehavior(text: text)
            let signalProfile = SignalIngest.shared.extractSignalProfile(text: text)
            
            // SIGNAL LAYER: Step 2 - Signal Mode Resolution
            let signalMode = SignalMode.resolveMode(from: signalMetrics)
            
            // Store for Writers Critique
            await MainActor.run {
                currentSignalMode = signalMode
                currentSignalProfile = signalProfile
            }
            
            // SIGNAL LAYER: Step 3 - Signal Axes Calibration
            let signalAxes = SignalAxes.calibrateAxes(metrics: signalMetrics, mode: signalMode)
            
            // PR 2: Axis Profile (read-only, computed but not consumed)
            let axisProfile = AxisProfile.calculate(metrics: signalMetrics, axes: signalAxes)
            axisProfile.log() // Observability only
            #if DEBUG
            let useModelGCore = ModelGEnvironment.useModelGCore && model == .modelG
            print("Model G: useModelGCore=\(useModelGCore), model=\(model.rawValue)")
            #endif
            
            // PR 3: Register Profile Inference (artist position, not constraints)
            let registerProfile = RegisterProfile.inferRegisters(from: signalMetrics)
            
            // SIGNAL LAYER: Step 4 - Constraint Engine
            let constraints = SignalConstraintEngine.shared.generateConstraints(mode: signalMode, axes: signalAxes)
            
            // THEMATIC STATE DETECTION: Check for Strength Mode
            let strengthMode = ThematicStateDetector.shared.checkStrengthMode(
                text: text,
                axes: signalAxes,
                profile: signalProfile
            )
            
            // LEXICON GATE: Filter terms before generation
            await MainActor.run {
                loadingStep = "Filtering lexicon terms..."
            }
            let lexiconGate = LexiconGate.shared
            let lexiconGateResult = lexiconGate.filterAllowedTerms(
                text: text,
                axes: signalAxes,
                profile: signalProfile,
                scene: nil,  // Default to Atlanta
                isKnownArtist: false  // User-generated content
            )
            
            // Handle lexicon gate silence result
            let allowedLexiconTerms: [LexiconTerm]
            if case .silence(let commentary) = lexiconGateResult {
                #if DEBUG
                print("Model G: Lexicon gate returned silence — \(commentary.reason)")
                #endif
                await MainActor.run {
                    self.silenceCommentary = commentary
                    self.suggestions = []
                    loadingStep = nil
                }
                return
            } else if case .allowed(let terms) = lexiconGateResult {
                allowedLexiconTerms = terms
            } else {
                allowedLexiconTerms = []
            }
            
            // STRENGTH MODE: If active, prefer silence (fewer outputs)
            if strengthMode.isActive && strengthMode.prefersSilence {
                // Bias toward fewer outputs - if we have multiple candidates, prefer silence
                // This is handled later in the flow when we filter suggestions
            }
            
            // Step 2: Narrative analysis (skip when Model G Core — it derives intent from text)
            let narrative: NarrativeAnalysis
            if ModelGEnvironment.useModelGCore && model == .modelG {
                #if DEBUG
                print("Model G: Skipping narrative analysis (Model G Core path)")
                #endif
                narrative = .modelGCorePlaceholder
            } else {
                await MainActor.run {
                    loadingStep = "Understanding themes and tone..."
                }
                narrative = try await api.analyzeNarrative(
                    text: text,
                    lastNLines: metrics.lastNLines,
                    model: model
                )
            }
            
            // SIGNAL LAYER-DRIVEN: Skip CSV search - generate directly from constraints
            // Step 3: Load model settings and user details
            let modelSettings = api.loadModelSettings(for: model)
            let userDetails = api.loadUserPersonalDetails()
            
            // Step 4: Generate suggestions
            await MainActor.run {
                loadingStep = ModelGEnvironment.useModelGCore && model == .modelG
                    ? "Model G Core"
                    : "Generating from signal constraints..."
            }
            #if DEBUG
            print("Model G: Calling generateSuggestions (useModelGCore=\(ModelGEnvironment.useModelGCore))...")
            #endif
            let resolvedThemeIDs = item?.selectedThemeIDs ?? []
            var finalSuggestions = try await api.generateSuggestions(
                candidates: [], // Empty - generate from scratch
                metrics: metrics,
                narrative: narrative,
                model: model,
                settings: modelSettings,
                userDetails: userDetails,
                constraints: constraints,
                registers: registerProfile,
                signalProfile: signalProfile,
                signalAxes: signalAxes,
                allowedLexiconTerms: allowedLexiconTerms,
                directedParams: directedParams,
                selectedThemeIDs: resolvedThemeIDs,
                rhymeGroupsByID: rhymeGroupsByID,
                audioURL: audioURL,
                transcriptionRhythmMapData: transcriptionRhythmMapData
            )
            #if DEBUG
            print("Model G: Generated \(finalSuggestions.count) suggestion(s)")
            #endif
            
            // PR 4: Internal Alignment Scoring (scores logged but not exposed to UI)
            let alignmentScores = finalSuggestions.map { suggestion in
                AlignmentScorer.shared.scoreSuggestion(
                    suggestion: suggestion,
                    userText: text,
                    userProfile: signalProfile,
                    axes: signalAxes,
                    axisProfile: axisProfile,
                    registers: registerProfile
                )
            }
            
            // PR 6: Check alignment threshold - allow silence if no candidate passes
            let alignmentThreshold = 0.4 // Minimum alignment score required
            let passingSuggestions = finalSuggestions.enumerated().filter { index, _ in
                alignmentScores[index].totalScore >= alignmentThreshold
            }.map { $0.element }
            
            // If no suggestions pass threshold, create silence commentary
            if passingSuggestions.isEmpty && !finalSuggestions.isEmpty {
                let silenceCommentary = Self.createSilenceCommentary(
                    mode: signalMode,
                    profile: signalProfile,
                    axes: signalAxes,
                    highestScore: alignmentScores.map { $0.totalScore }.max() ?? 0.0
                )
                
                await MainActor.run {
                    // Store silence commentary for display
                    self.silenceCommentary = silenceCommentary
                    self.suggestions = []
                    loadingStep = nil
                }
                return
            }
            
            // Use passing suggestions, or all if threshold not enforced yet
            var suggestionsToUse = passingSuggestions.isEmpty ? finalSuggestions : passingSuggestions
            
            // STRENGTH MODE: Prefer silence (fewer outputs) - one restrained line beats multiple decent ones
            if strengthMode.isActive && strengthMode.prefersSilence {
                // If we have multiple suggestions, prefer only the best one (or silence)
                if suggestionsToUse.count > 1 {
                    // Sort by signal strength and take only the top one
                    let sorted = suggestionsToUse.sorted { (s1, s2) -> Bool in
                        let strength1 = s1.signalStrength ?? s1.confidence
                        let strength2 = s2.signalStrength ?? s2.confidence
                        return strength1 > strength2
                    }
                    suggestionsToUse = Array(sorted.prefix(1))  // Only keep the best one
                }
            }
            
            // SIGNAL LAYER: Step 6 - Signal Evaluation
            let evaluations = finalSuggestions.map { suggestion in
                SignalEvaluator.shared.evaluateSuggestion(
                    suggestion: suggestion,
                    mode: signalMode,
                    axes: signalAxes
                )
            }
            
            // SIGNAL LAYER: Step 7 - Signal Notes
            let signalNotes = SignalNotes.shared.generateNotes(
                suggestions: finalSuggestions,
                evaluations: evaluations,
                mode: signalMode
            )
            
            // Apply Signal Strength and Notes to suggestions
            finalSuggestions = finalSuggestions.enumerated().map { index, suggestion in
                let evaluation = evaluations[index]
                var updated = suggestion
                updated.signalStrength = evaluation.signalStrength
                updated.signalNote = signalNotes[suggestion.id]
                return updated
            }
            
            // SIGNAL LAYER: Step 9 - Signal Memory (track patterns)
            SignalMemory.shared.recordPatterns(from: finalSuggestions)
            
            // LEXICON: Track thematic state for memory
            let thematicState = ThematicStateDetector.shared.detectState(
                text: text,
                axes: signalAxes,
                profile: signalProfile
            )
            SignalMemory.shared.recordThematicState(thematicState)
            
            await MainActor.run {
                suggestions = suggestionsToUse
                silenceCommentary = nil
                commitGeneration(
                    batch: finalSuggestions,
                    contextText: text,
                    model: model,
                    noteKey: noteKey,
                    noteTitle: noteTitle,
                    persistTo: item
                )
                loadingStep = nil
                let primary = suggestionsToUse.first ?? finalSuggestions.first
                let themeSet = Array(Set(finalSuggestions.flatMap(\.themes))).prefix(6).map { $0 }
                refreshHumanCritic(
                    userVerse: text,
                    primarySuggestion: primary,
                    themes: themeSet,
                    persistTo: item,
                    model: model
                )
            }
            
        } catch let apiError as RapAPIError {
            #if DEBUG
            print("Model G: RapAPIError — \(apiError.localizedDescription)")
            #endif
            await MainActor.run {
                switch apiError {
                case .silence(let commentary):
                    self.silenceCommentary = commentary
                    self.suggestions = []
                    self.lastBatchSuggestions = []
                    self.lastSessionGenerationId = UUID()
                    self.error = nil
                    loadingStep = nil
                    if let item {
                        NoteSuggestionSessionStore.save(from: self, contextText: text, model: model, to: item)
                    }
                    AIGenerationLedger.record(
                        generationId: self.lastSessionGenerationId!,
                        noteKey: noteKey ?? "",
                        noteTitle: noteTitle,
                        contextText: text,
                        model: model,
                        suggestions: [],
                        silence: true
                    )
                    refreshHumanCritic(
                        userVerse: text,
                        primarySuggestion: nil,
                        persistTo: item,
                        model: model
                    )
                    
                    // Store silence for analytics (not as error, but as valid output)
                    ErrorStorageManager.shared.storeError(
                        "API returned silence: \(commentary.reason)",
                        source: "AI Sparkle Button",
                        context: "Explanation: \(commentary.explanation). Guidance: \(commentary.guidance)"
                    )
                    
                default:
                    // Handle other API errors
                    let errorMessage = apiError.localizedDescription
                    self.error = errorMessage
                    self.silenceCommentary = nil
                    loadingStep = nil
                    
                    // Store error for analytics
                    ErrorStorageManager.shared.storeError(
                        errorMessage,
                        source: "AI Sparkle Button",
                        context: "Rap Suggestion Generation - \(loadingStep ?? "Unknown step")"
                    )
                    // In-app notification with short explanation
                    if !apiError.inAppNotificationMessage.isEmpty {
                        AppErrorRecovery.postInAppError(from: apiError)
                    }
                }
            }
        } catch {
            #if DEBUG
            print("Model G: Error — \(error)")
            #endif
            await MainActor.run {
                let errorMessage = error.localizedDescription
                self.error = errorMessage
                self.silenceCommentary = nil
                loadingStep = nil
                
                // Store error for analytics
                ErrorStorageManager.shared.storeError(
                    errorMessage,
                    source: "AI Sparkle Button",
                    context: "Rap Suggestion Generation - \(loadingStep ?? "Unknown step")"
                )
                // In-app notification with short explanation
                AppErrorRecovery.postInAppError(from: error)
            }
        }
    }
    
    /// Run Model G Core v1 and v2 in parallel; results go to suggestionsV1 (left) and suggestionsV2 (right) for side-by-side UI.
    func generateSuggestionsModelGParallel(text: String, highlights: [Highlight], bpm: Int? = nil, key: String? = nil, scale: String? = nil, syllableMin: Int? = nil, syllableMax: Int? = nil, directedParams: DirectedGenerationParams? = nil, rhymeGroupsByID: [RhymeGroupID: RhymeGroupSummary]? = nil, audioURL: URL? = nil, transcriptionRhythmMapData: Data? = nil, noteKey: String? = nil, noteTitle: String = "", persistTo item: Item? = nil) async {
        await MainActor.run {
            isLoading = true
            error = nil
            clearHumanCritic()
            suggestions = []
            suggestionsV1 = []
            suggestionsV2 = []
            silenceCommentary = nil
            isParallelModelG = false
            loadingStep = "Model G v1 & v2..."
            lastStandardGenerationModel = .modelG
        }
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        do {
            await MainActor.run { loadingStep = "Analyzing your verse..." }
            let metrics = analysisEngine.extractMetrics(text: text, highlights: highlights, bpm: bpm, key: key, scale: scale, syllableMin: syllableMin, syllableMax: syllableMax)
            let allLines = text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
            let previousLines = Array(allLines.suffix(6))
            let fullTextLineCount = allLines.count
            let contextLineCount = min(6, fullTextLineCount)
            await MainActor.run {
                self.previousLines = previousLines
                self.fullTextLineCount = fullTextLineCount
                self.contextLineCount = contextLineCount
            }
            let signalMetrics = SignalIngest.shared.analyzeBehavior(text: text)
            let signalProfile = SignalIngest.shared.extractSignalProfile(text: text)
            let signalMode = SignalMode.resolveMode(from: signalMetrics)
            let signalAxes = SignalAxes.calibrateAxes(metrics: signalMetrics, mode: signalMode)
            await MainActor.run {
                currentSignalMode = signalMode
                currentSignalProfile = signalProfile
            }
            let registerProfile = RegisterProfile.inferRegisters(from: signalMetrics)
            let constraints = SignalConstraintEngine.shared.generateConstraints(mode: signalMode, axes: signalAxes)
            await MainActor.run { loadingStep = "Filtering lexicon terms..." }
            let lexiconGate = LexiconGate.shared
            let lexiconGateResult = lexiconGate.filterAllowedTerms(
                text: text,
                axes: signalAxes,
                profile: signalProfile,
                scene: nil,
                isKnownArtist: false
            )
            if case .silence(let commentary) = lexiconGateResult {
                await MainActor.run {
                    self.silenceCommentary = commentary
                    self.suggestionsV1 = []
                    self.suggestionsV2 = []
                    loadingStep = nil
                }
                return
            }
            let allowedLexiconTerms: [LexiconTerm]
            if case .allowed(let terms) = lexiconGateResult {
                allowedLexiconTerms = terms
            } else {
                allowedLexiconTerms = []
            }
            let narrative: NarrativeAnalysis = .modelGCorePlaceholder
            let modelSettings = api.loadModelSettings(for: .modelG)
            let userDetails = api.loadUserPersonalDetails()
            await MainActor.run { loadingStep = "Model G v1 & v2..." }
            let resolvedThemeIDs = item?.selectedThemeIDs ?? []
            async let v1Task = api.generateSuggestions(
                candidates: [],
                metrics: metrics,
                narrative: narrative,
                model: .modelG,
                settings: modelSettings,
                userDetails: userDetails,
                constraints: constraints,
                registers: registerProfile,
                signalProfile: signalProfile,
                signalAxes: signalAxes,
                allowedLexiconTerms: allowedLexiconTerms,
                directedParams: directedParams,
                selectedThemeIDs: resolvedThemeIDs,
                rhymeGroupsByID: rhymeGroupsByID,
                audioURL: audioURL,
                transcriptionRhythmMapData: transcriptionRhythmMapData,
                modelGVariantOverride: false
            )
            async let v2Task = api.generateSuggestions(
                candidates: [],
                metrics: metrics,
                narrative: narrative,
                model: .modelG,
                settings: modelSettings,
                userDetails: userDetails,
                constraints: constraints,
                registers: registerProfile,
                signalProfile: signalProfile,
                signalAxes: signalAxes,
                allowedLexiconTerms: allowedLexiconTerms,
                directedParams: directedParams,
                selectedThemeIDs: resolvedThemeIDs,
                rhymeGroupsByID: rhymeGroupsByID,
                audioURL: audioURL,
                transcriptionRhythmMapData: transcriptionRhythmMapData,
                modelGVariantOverride: true
            )
            var resultsV1: [RapSuggestion] = []
            var resultsV2: [RapSuggestion] = []
            do { resultsV1 = try await v1Task } catch {
                #if DEBUG
                print("Model G parallel: v1 failed — \(error)")
                #endif
            }
            do { resultsV2 = try await v2Task } catch {
                #if DEBUG
                print("Model G parallel: v2 failed — \(error)")
                #endif
            }
            await MainActor.run {
                self.suggestionsV1 = resultsV1
                self.suggestionsV2 = resultsV2
                self.isParallelModelG = true
                self.lastParallelDirectedParams = directedParams
                self.lastParallelRhymeGroupsByID = rhymeGroupsByID
                self.error = nil
                self.silenceCommentary = nil
                self.loadingStep = nil
                let batch = resultsV1 + resultsV2
                self.commitGeneration(
                    batch: batch,
                    contextText: text,
                    model: .modelG,
                    noteKey: noteKey,
                    noteTitle: noteTitle,
                    persistTo: item
                )
                let primary = resultsV1.first ?? resultsV2.first
                let themes = Array(Set(batch.flatMap(\.themes))).prefix(6).map { $0 }
                self.refreshHumanCritic(
                    userVerse: text,
                    primarySuggestion: primary,
                    themes: themes,
                    persistTo: item,
                    model: .modelG
                )
            }
        } catch {
            #if DEBUG
            print("Model G parallel: Error — \(error)")
            #endif
            await MainActor.run {
                self.error = error.localizedDescription
                self.suggestionsV1 = []
                self.suggestionsV2 = []
                self.isParallelModelG = false
                self.loadingStep = nil
                AppErrorRecovery.postInAppError(from: error)
            }
        }
    }
    
    // MARK: - Silence Commentary
    
    /// Create silence commentary when no suggestions pass alignment threshold
    private static func createSilenceCommentary(
        mode: SignalMode,
        profile: SignalProfile,
        axes: SignalAxes,
        highestScore: Double
    ) -> CriticCommentary {
        let explanation: String
        let reason: String
        let guidance: String
        
        // Generate explanation based on signal mode and alignment score
        if highestScore < 0.2 {
            explanation = "No lines generated that align with your current signal profile."
            reason = "Alignment score too low (\(String(format: "%.1f", highestScore * 100))%). Generated lines don't match your register position or axis profile."
        } else {
            explanation = "Generated lines don't meet the minimum alignment threshold."
            reason = "Highest alignment score (\(String(format: "%.1f", highestScore * 100))%) is below the required threshold (40%)."
        }
        
        // Generate guidance based on signal mode
        switch mode {
        case .uncontainedVulnerability:
            guidance = "Consider processing your thoughts more directly. The current register may be too vulnerable or explanatory for strong line generation."
        case .informationRefusal:
            guidance = "Your holding back position is valid, but it may limit line generation. Consider if you want to maintain this distance or allow more expression."
        case .noRepair:
            guidance = "The closed position is strong, but it may be too final for generating new lines. Consider if you want to maintain closure or explore what led to it."
        case .voluntaryIsolation:
            guidance = "Distance without hostility is powerful, but it may limit generative options. Consider if you want to maintain this calm separation."
        case .lossAcknowledgmentWithoutAttribution:
            guidance = "Loss processing is important, but it may be too emotional for strong line generation. Consider balancing emotion with structure."
        case .postChaosStabilization:
            guidance = "Stabilizing mode focuses on logistics, which may limit creative line generation. Consider if you want to maintain this practical focus."
        case .declarativeClosureWithoutEvidence:
            guidance = "Declarative closure is strong, but it may be too final for generating new lines. Consider if you want to maintain this position or explore alternatives."
        case .defaultExpressive:
            guidance = "The current expressive mode may not align well with line generation. Consider adjusting your approach or signal profile."
        }
        
        return CriticCommentary(
            explanation: explanation,
            reason: reason,
            guidance: guidance
        )
    }
}

// MARK: - Contextual Feedback View

struct ContextualFeedbackView: View {
    let suggestion: RapSuggestion
    let contextText: String
    @Binding var selectedCategories: Set<FeedbackCategory>
    @Binding var feedbackText: String
    @Binding var qualityMetricFeedback: QualityMetricFeedback?
    @Binding var likedLineIndices: Set<Int>
    @Binding var dislikedLineIndices: Set<Int>
    let onSave: () -> Void
    let onDismiss: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var showQualityMetrics = false
    @State private var rhymeStrengthCorrection: Double? = nil
    @State private var flowMatchCorrection: Double? = nil
    @State private var styleMatchCorrection: Double? = nil
    
    var body: some View {
        NavigationView {
            Form {
                // Show highlighted lines summary
                if !likedLineIndices.isEmpty || !dislikedLineIndices.isEmpty {
                    Section {
                        Text("Highlighted Lines")
                            .font(.headline)
                        
                        let lines = suggestion.text.components(separatedBy: "\n").filter { !$0.isEmpty }
                        
                        if !likedLineIndices.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Liked:")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                                ForEach(Array(likedLineIndices.sorted()), id: \.self) { index in
                                    if index < lines.count {
                                        HStack {
                                            Image(systemName: "hand.thumbsup.fill")
                                                .foregroundStyle(.green)
                                            Text("Line \(index + 1): \(lines[index])")
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !dislikedLineIndices.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Disliked:")
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                ForEach(Array(dislikedLineIndices.sorted()), id: \.self) { index in
                                    if index < lines.count {
                                        HStack {
                                            Image(systemName: "hand.thumbsdown.fill")
                                                .foregroundStyle(.red)
                                            Text("Line \(index + 1): \(lines[index])")
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Text("What was wrong with this suggestion?")
                        .font(.headline)
                    
                    // Quick feedback buttons
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(FeedbackCategory.allCases.filter { $0 != .other }, id: \.self) { category in
                            Button {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: selectedCategories.contains(category) ? "checkmark.circle.fill" : "circle")
                                    Text(category.displayName)
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedCategories.contains(category) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Section {
                    Toggle("Validate Quality Metrics", isOn: $showQualityMetrics)
                    
                    if showQualityMetrics {
                        if let rhymeStrength = suggestion.rhymeStrength {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rhyme Strength: \(Int(rhymeStrength * 100))%")
                                    .font(.subheadline)
                                Slider(value: Binding(
                                    get: { rhymeStrengthCorrection ?? rhymeStrength },
                                    set: { rhymeStrengthCorrection = $0 }
                                ), in: 0...1)
                            }
                        }
                        
                        if let flowMatch = suggestion.flowMatch {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Flow Match: \(Int(flowMatch * 100))%")
                                    .font(.subheadline)
                                Slider(value: Binding(
                                    get: { flowMatchCorrection ?? flowMatch },
                                    set: { flowMatchCorrection = $0 }
                                ), in: 0...1)
                            }
                        }
                        
                        if let styleMatch = suggestion.styleMatch {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Style Match: \(Int(styleMatch * 100))%")
                                    .font(.subheadline)
                                Slider(value: Binding(
                                    get: { styleMatchCorrection ?? styleMatch },
                                    set: { styleMatchCorrection = $0 }
                                ), in: 0...1)
                            }
                        }
                    }
                }
                
                Section {
                    Text("Additional Details (Optional)")
                        .font(.headline)
                    
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text("What were you looking for? What did you expect?")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                }
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Update quality metric feedback if corrections were made
                        if showQualityMetrics && (rhymeStrengthCorrection != nil || flowMatchCorrection != nil || styleMatchCorrection != nil) {
                            qualityMetricFeedback = QualityMetricFeedback(
                                rhymeStrengthCorrection: rhymeStrengthCorrection,
                                flowMatchCorrection: flowMatchCorrection,
                                styleMatchCorrection: styleMatchCorrection,
                                confidenceCorrection: nil
                            )
                        }
                        
                        onSave()
                        dismiss()
                    }
                    .disabled(selectedCategories.isEmpty && feedbackText.isEmpty)
                }
            }
        }
    }
}

