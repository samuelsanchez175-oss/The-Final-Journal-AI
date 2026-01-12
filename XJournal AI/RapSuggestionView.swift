import SwiftUI
import Combine

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
    
    init(
        suggestions: [RapSuggestion],
        isLoading: Bool,
        loadingStep: String?,
        error: String?,
        onSelect: @escaping (RapSuggestion) -> Void,
        onCopy: ((RapSuggestion) -> Void)? = nil,
        onDismiss: @escaping () -> Void,
        contextText: String? = nil,
        onRegenerate: (() -> Void)? = nil
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
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if let error = error {
                    errorView(error)
                } else if suggestions.isEmpty {
                    emptyView
                } else {
                    suggestionsList
                }
            }
            .navigationTitle("Rap Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        // Comparison toggle
                        if suggestions.count > 1 {
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
                    .foregroundStyle(.secondary)
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
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.bubble")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Suggestions")
                .font(.headline)
            
            Text("Try adjusting your verse or check your API key settings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Suggestions List
    
    private var suggestionsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(suggestions) { suggestion in
                    suggestionCard(suggestion)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
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
            suggestionTextSection(suggestion, lines: lines, hasAnyFeedback: hasAnyFeedback)
            suggestionThemeTags(suggestion)
            suggestionQualityIndicators(suggestion)
            suggestionSignalNote(suggestion)
        }
        .padding(16)
        .background(cardBackgroundView())
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
                SuggestionLineRow(
                    line: line,
                    isLiked: isLiked,
                    isDisliked: isDisliked,
                    isHighlighted: highlightedSuggestionId == suggestion.id,
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
        .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
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
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        } else if let reasoning = suggestion.reasoning {
            Text(reasoning)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
    }
    
    private func cardBackgroundView() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
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
                            expectedVsActual: "Liked lines: \(likedLineTexts.joined(separator: ", "))"
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
                                .fill(.ultraThinMaterial)
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
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
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
            context: contextText ?? ""
        )
        
        // Track interaction
        SuggestionInteractionTracker.shared.trackSuggestionAction(
            suggestionId: suggestion.id,
            action: feedback == .liked ? .liked : .disliked
        )
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
            expectedVsActual: feedbackText[suggestion.id]
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
                .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
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
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
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
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
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
    @Published var isLoading: Bool = false
    @Published var loadingStep: String?
    @Published var error: String?
    
    // Store previous suggestions for recall
    @Published var previousSuggestions: [RapSuggestion] = []
    
    private let analysisEngine = RapAnalysisEngine()
    private let api = RapSuggestionAPI.shared
    private lazy var filter: ConstraintFilter = {
        // Access FJCMUDICTStore via global accessor function
        return ConstraintFilter(phonemeStoreProvider: { getGlobalCMUDICTStore() })
    }()
    
    func generateSuggestions(text: String, highlights: [Highlight], model: SuggestionModel = .modelG) async {
        await MainActor.run {
            isLoading = true
            error = nil
            suggestions = []
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
            let metrics = analysisEngine.extractMetrics(text: text, highlights: highlights)
            
            // SIGNAL LAYER: Step 1 - Signal Ingest (analyze behavior)
            let signalProfile = SignalIngest.shared.analyzeBehavior(text: text)
            
            // SIGNAL LAYER: Step 2 - Signal Mode Resolution
            let signalMode = SignalMode.resolveMode(from: signalProfile)
            
            // SIGNAL LAYER: Step 3 - Signal Axes Calibration
            let signalAxes = SignalAxes.calibrateAxes(profile: signalProfile, mode: signalMode)
            
            // SIGNAL LAYER: Step 4 - Constraint Engine
            let constraints = SignalConstraintEngine.shared.generateConstraints(mode: signalMode, axes: signalAxes)
            
            // Step 2: Narrative analysis
            await MainActor.run {
                loadingStep = "Understanding themes and tone..."
            }
            let narrative = try await api.analyzeNarrative(
                text: text,
                lastNLines: metrics.lastNLines,
                model: model
            )
            
            // Step 3: Semantic search
            await MainActor.run {
                loadingStep = "Searching lyrics database..."
            }
            let candidates = try await api.searchLyrics(
                narrativeSummary: narrative.summary,
                themes: narrative.primaryThemes + narrative.secondaryThemes,
                limit: 200
            )
            
            // Step 4: Constraint filtering
            await MainActor.run {
                loadingStep = "Filtering by rhyme and flow..."
            }
            let filtered = filter.filterCandidates(
                candidates: candidates,
                metrics: metrics
            )
            
            // Step 5: Load model settings and user details
            let modelSettings = api.loadModelSettings(for: model)
            let userDetails = api.loadUserPersonalDetails()
            
            // Step 6: Generate suggestions (with SIGNAL LAYER constraints)
            await MainActor.run {
                loadingStep = "Generating suggestions..."
            }
            var finalSuggestions = try await api.generateSuggestions(
                candidates: filtered.map { $0.line },
                metrics: metrics,
                narrative: narrative,
                model: model,
                settings: modelSettings,
                userDetails: userDetails,
                constraints: constraints
            )
            
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
            
            await MainActor.run {
                suggestions = finalSuggestions
                // Save to previous suggestions (append to history, limit to last 50)
                previousSuggestions.append(contentsOf: finalSuggestions)
                if previousSuggestions.count > 50 {
                    previousSuggestions = Array(previousSuggestions.suffix(50))
                }
                loadingStep = nil
            }
            
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                loadingStep = nil
            }
        }
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
                        .foregroundStyle(.secondary)
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

