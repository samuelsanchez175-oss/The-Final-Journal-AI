import SwiftUI
import Combine

// MARK: - Rap Suggestion View

struct RapSuggestionView: View {
    let suggestions: [RapSuggestion]
    let isLoading: Bool
    let loadingStep: String?
    let error: String?
    let onSelect: (RapSuggestion) -> Void
    let onCopy: ((RapSuggestion) -> Void)? // New: Copy callback with slam animation
    let onDismiss: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var highlightedSuggestionId: UUID? = nil
    
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
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
        VStack(alignment: .leading, spacing: 0) {
            // Card content
            VStack(alignment: .leading, spacing: 12) {
                // Text (4 lines) - Highlightable
                VStack(alignment: .leading, spacing: 4) {
                    let lines = suggestion.text.components(separatedBy: "\n").filter { !$0.isEmpty }
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        Text(line)
                            .font(.body)
                            .foregroundStyle(highlightedSuggestionId == suggestion.id ? .blue : .primary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled) // Enable text selection
                    }
                }
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(highlightedSuggestionId == suggestion.id ? Color.blue.opacity(0.15) : Color.clear)
                        .animation(.easeInOut(duration: 0.2), value: highlightedSuggestionId)
                )
                
                // Theme Tags
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
                
                // Metadata
                HStack {
                    // Confidence
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.0f%%", suggestion.confidence * 100))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Source (if available)
                    if let source = suggestion.source {
                        Text(source)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Reasoning (if available)
                if let reasoning = suggestion.reasoning {
                    Text(reasoning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(16)
            .background(
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
            )
            
            // Action buttons
            HStack(spacing: 12) {
                // Copy button
                Button {
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
    private let filter = ConstraintFilter()
    
    func generateSuggestions(text: String, highlights: [Highlight]) async {
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
            
            // Step 2: Narrative analysis
            await MainActor.run {
                loadingStep = "Understanding themes and tone..."
            }
            let narrative = try await api.analyzeNarrative(
                text: text,
                lastNLines: metrics.lastNLines
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
                metrics: metrics,
                rhymeEngine: RhymeHighlighterEngine.self
            )
            
            // Step 5: Generate suggestions
            await MainActor.run {
                loadingStep = "Generating suggestions..."
            }
            let finalSuggestions = try await api.generateSuggestions(
                candidates: filtered.map { $0.line },
                metrics: metrics,
                narrative: narrative
            )
            
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
