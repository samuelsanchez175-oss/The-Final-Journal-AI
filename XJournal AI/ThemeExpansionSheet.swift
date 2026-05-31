import SwiftUI
import Combine

// MARK: - Theme Model (moved from RapLyricsDatabase)
struct Theme: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let jargonTerms: [String]
    let contextDescription: String
    let relatedThemes: [String]
    let emotionalTone: String
}

// MARK: - Theme Database (uses NewRapDatabase)
class ThemeDatabase: ObservableObject {
    @Published var themes: [Theme] = []
    @Published var isLoading: Bool = false
    @Published var isLoaded: Bool = false
    
    func loadFromAppGroup() async throws {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            try await NewRapDatabase.shared.loadAllCSVs()
            await MainActor.run {
                self.themes = NewRapDatabase.shared.themes
                self.isLoaded = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            throw error
        }
    }
}

// MARK: - Theme Expansion Sheet (Phase 4: Advanced AI Features)

struct ThemeExpansionSheet: View {
    let currentText: String
    let currentThemes: [String]
    let onSelect: (RapSuggestion) -> Void
    let onDismiss: () -> Void
    
    @State private var suggestions: [RapSuggestion] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var selectedThemeIDs: Set<String> = []
    @State private var loadingError: String?
    @State private var retryCount: Int = 0
    @State private var searchText: String = ""
    @State private var selectedEmotionalTone: String? = nil
    @StateObject private var themeDatabase = ThemeDatabase()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    // Computed property for filtered themes
    private var filteredThemes: [Theme] {
        var themes = themeDatabase.themes
        
        // Filter by search text
        if !searchText.isEmpty {
            themes = themes.filter { theme in
                theme.name.localizedCaseInsensitiveContains(searchText) ||
                theme.jargonTerms.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                theme.relatedThemes.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by emotional tone
        if let tone = selectedEmotionalTone {
            themes = themes.filter { $0.emotionalTone == tone }
        }
        
        return themes
    }
    
    // Available emotional tones
    private var availableEmotionalTones: [String] {
        Array(Set(themeDatabase.themes.map { $0.emotionalTone })).sorted()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Bar with Done button
                    HStack {
                        Spacer()
                        Button("Done") {
                            dismiss()
                            onDismiss()
                        }
                        .foregroundStyle(.white)
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header Section
                            headerSection
                            .padding(.top, 20)
                            
                            // Theme Selection Area
                            if !themeDatabase.themes.isEmpty {
                                themeSelectionSection
                            } else if themeDatabase.isLoading {
                                loadingThemesView
                            } else if let error = loadingError {
                                // Error state with retry
                                VStack(spacing: 16) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.orange)
                                    
                                    Text("Failed to Load Themes")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    Text(error)
                                        .font(.caption)
                                        .foregroundStyle(Momentum.contentSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                    
                                    Button {
                                        Task {
                                            retryCount = 0
                                            await loadThemesWithRetry()
                                        }
                                    } label: {
                                        Label("Retry", systemImage: "arrow.clockwise")
                                            .font(.subheadline)
                                            .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(Color.orange)
                                            )
                                    }
                                }
                                .padding(.vertical, 40)
                            } else {
                                // Empty state - no themes available
                                emptyThemesState
                            }
                            
                            // Current Themes Display (if any from text)
                            if !currentThemes.isEmpty {
                                detectedThemesSection
                            }
                            
                            // Expand Themes Button
                            expandThemesButton
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                            
                            // Error Message
                            if let error = errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                            }
                            
                            // Suggestions
                            if !suggestions.isEmpty {
                                suggestionsSection
                                .padding(.bottom, 40)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await loadThemesWithRetry()
            
            // Pre-select themes that match current themes
            if !currentThemes.isEmpty && !themeDatabase.themes.isEmpty {
                selectedThemeIDs = Set(themeDatabase.themes.filter { theme in
                    currentThemes.contains { currentTheme in
                        theme.name.localizedCaseInsensitiveContains(currentTheme) ||
                        theme.jargonTerms.contains { $0.localizedCaseInsensitiveContains(currentTheme) }
                    }
                }.map { $0.id })
            }
        }
    }
    
    // MARK: - Theme Loading
    
    // NOTE: CSV loading is now optional - ThemeExpansionSheet loads themes lazily
    // If CSV files are not available, the sheet will show an empty state
    private func loadThemesWithRetry() async {
        guard !themeDatabase.isLoaded && !themeDatabase.isLoading else { return }
        
        loadingError = nil
        
        do {
            try await themeDatabase.loadFromAppGroup()
            retryCount = 0
        } catch {
            // CSV files may not be available - this is okay if using SIGNAL LAYER-only generation
            loadingError = "Theme database not available. CSV files may need to be added if you want to use Theme Expansion feature."
            
            // Retry logic - up to 2 retries
            if retryCount < 2 {
                retryCount += 1
                try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
                await loadThemesWithRetry()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon with subtle animation
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse, options: .repeating)
            
            // Title with gradient
            Text("Theme Expansion")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Description
            Text("Explore related themes and expand your narrative")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Detected Themes Section
    
    private var detectedThemesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Detected Themes")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button {
                    // Convert detected themes to selected themes
                    let matchingThemes = themeDatabase.themes.filter { theme in
                        currentThemes.contains { currentTheme in
                            theme.name.localizedCaseInsensitiveContains(currentTheme) ||
                            theme.jargonTerms.contains { $0.localizedCaseInsensitiveContains(currentTheme) }
                        }
                    }
                    selectedThemeIDs.formUnion(Set(matchingThemes.map { $0.id }))
                } label: {
                    Label("Select All", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(currentThemes, id: \.self) { theme in
                        detectedThemePill(theme: theme)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func detectedThemePill(theme: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.caption2)
                .foregroundStyle(.orange)
            
            Text(theme.capitalized)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.5), .orange.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Theme Selection Section
    
    private var themeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Select Themes to Expand")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("\(selectedThemeIDs.count) selected")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            .padding(.horizontal, 20)
            
            // Search and Filter
            VStack(spacing: 12) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Momentum.contentSecondary)
                    
                    TextField("Search themes...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Momentum.contentSecondary)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                )
                
                // Emotional tone filter
                if !availableEmotionalTones.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button {
                                selectedEmotionalTone = nil
                            } label: {
                                Text("All")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(selectedEmotionalTone == nil ? Color.orange : Color.clear)
                                    )
                                    .foregroundStyle(selectedEmotionalTone == nil ? .white : .secondary)
                            }
                            
                            ForEach(availableEmotionalTones, id: \.self) { tone in
                                Button {
                                    selectedEmotionalTone = selectedEmotionalTone == tone ? nil : tone
                                } label: {
                                    Text(tone.capitalized)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(selectedEmotionalTone == tone ? Color.orange : Color.clear)
                                        )
                                        .foregroundStyle(selectedEmotionalTone == tone ? .white : .secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Theme Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(filteredThemes) { theme in
                    ThemeSelectionCard(
                        theme: theme,
                        isSelected: selectedThemeIDs.contains(theme.id),
                        onToggle: {
                            if selectedThemeIDs.contains(theme.id) {
                                selectedThemeIDs.remove(theme.id)
                            } else {
                                selectedThemeIDs.insert(theme.id)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            
            if filteredThemes.isEmpty && !searchText.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(Momentum.contentSecondary)
                    Text("No themes found")
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .padding(.vertical, 20)
            }
            
            // Theme Recommendations
            if !recommendedThemes.isEmpty && selectedThemeIDs.count > 0 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.orange)
                        Text("You might also like")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(recommendedThemes) { theme in
                                Button {
                                    selectedThemeIDs.insert(theme.id)
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(theme.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        
                                        Text(theme.emotionalTone.capitalized)
                                            .font(.caption2)
                                            .foregroundStyle(Momentum.contentSecondary)
                                    }
                                    .padding(10)
                                    .frame(width: 140)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Suggestions Section
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggestions")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                ForEach(suggestions) { suggestion in
                    suggestionCard(suggestion: suggestion, index: suggestions.firstIndex(where: { $0.id == suggestion.id }) ?? 0)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func suggestionCard(suggestion: RapSuggestion, index: Int) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onSelect(suggestion)
            dismiss()
            onDismiss()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Confidence indicator
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(Int(suggestion.confidence * 100))%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.orange)
                    }
                    
                    Spacer()
                    
                    Label("Insert", systemImage: "arrow.right.circle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.orange)
                }
                
                // Suggestion text
                Text(suggestion.text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                
                // Theme tags
                if !suggestion.themes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(suggestion.themes, id: \.self) { theme in
                                Text(theme)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.orange.opacity(0.15))
                                    )
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Loading States
    
    private var loadingThemesView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(1.2)
            
            Text("Loading themes...")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
            
            // Skeleton loading cards
            VStack(spacing: 12) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 80)
                        .opacity(0.6)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .padding(.vertical, 40)
    }
    
    private var expandThemesButton: some View {
        Button {
            Task {
                await generateThemeExpansion()
            }
        } label: {
            VStack(spacing: 8) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.white)
                    }
                    Text(isLoading ? "Generating..." : "Expand Themes")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                if isLoading {
                    Text("Analyzing themes and generating suggestions...")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isLoading || selectedThemeIDs.isEmpty {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.gray)
                    } else {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            )
        }
        .disabled(isLoading || selectedThemeIDs.isEmpty)
    }
    
    // MARK: - Theme Recommendations
    
    private var recommendedThemes: [Theme] {
        guard !selectedThemeIDs.isEmpty else { return [] }
        
        let selectedThemes = themeDatabase.themes.filter { selectedThemeIDs.contains($0.id) }
        var recommended = Set<Theme>()
        
        for selectedTheme in selectedThemes {
            // Find themes that are related to selected themes
            let related = themeDatabase.themes.filter { theme in
                !selectedThemeIDs.contains(theme.id) &&
                (theme.relatedThemes.contains(selectedTheme.name) ||
                 selectedTheme.relatedThemes.contains(theme.name) ||
                 theme.emotionalTone == selectedTheme.emotionalTone)
            }
            recommended.formUnion(related)
        }
        
        return Array(recommended).prefix(6).map { $0 }
    }
    
    // MARK: - Empty State
    
    private var emptyThemesState: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange.opacity(0.6))
            
            Text("No Themes Available")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Themes will be loaded from the database. If this persists, the theme database may need to be initialized.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                Task {
                    retryCount = 0
                    await loadThemesWithRetry()
                }
            } label: {
                Label("Try Loading Again", systemImage: "arrow.clockwise")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.orange)
                    )
            }
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Theme Expansion Generation
    
    private func generateThemeExpansion() async {
        isLoading = true
        errorMessage = nil
        
        // Get selected theme names and details
        let selectedThemes = themeDatabase.themes.filter { selectedThemeIDs.contains($0.id) }
        let themeNames = selectedThemes.map { $0.name }
        
        // If no themes selected, use current themes or default
        let themesToUse = themeNames.isEmpty 
            ? (currentThemes.isEmpty ? ["general"] : currentThemes)
            : themeNames
        
        do {
            // Note: generateThemeExpansion is an extension method on RapSuggestionAPI
            let api = RapSuggestionAPI.shared
            let themeDetails: [Theme]? = selectedThemes.isEmpty ? nil : selectedThemes
            let results = try await api.generateThemeExpansion(
                text: currentText,
                currentThemes: themesToUse,
                context: nil,
                selectedThemeDetails: themeDetails
            )
            
            await MainActor.run {
                suggestions = results
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - Theme Selection Card

struct ThemeSelectionCard: View {
    let theme: Theme
    let isSelected: Bool
    let onToggle: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onToggle()
            }
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(theme.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.orange)
                            .symbolEffect(.scale.up, options: .speed(0.5))
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.secondary.opacity(0.3))
                    }
                }
                
                if !theme.jargonTerms.isEmpty {
                    Text(theme.jargonTerms.prefix(2).joined(separator: ", "))
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                        .lineLimit(2)
                }
                
                // Emotional tone indicator
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(emotionalToneColor(theme.emotionalTone))
                    
                    Text(theme.emotionalTone.capitalized)
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                // Related themes preview
                if !theme.relatedThemes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(theme.relatedThemes.prefix(2), id: \.self) { relatedTheme in
                                Text(relatedTheme)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(isSelected ? Color.white.opacity(0.2) : Color.orange.opacity(0.1))
                                    )
                                    .foregroundStyle(isSelected ? .white.opacity(0.9) : .orange)
                            }
                        }
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.4), Color.orange.opacity(0.25)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.orange, Color.orange.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)
                    .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.clear, lineWidth: 1)
                    )
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
    
    private func emotionalToneColor(_ tone: String) -> Color {
        let lowercased = tone.lowercased()
        if lowercased.contains("aggressive") || lowercased.contains("angry") {
            return .red
        } else if lowercased.contains("sad") || lowercased.contains("melancholy") {
            return .blue
        } else if lowercased.contains("happy") || lowercased.contains("joyful") {
            return .green
        } else if lowercased.contains("confident") || lowercased.contains("powerful") {
            return .orange
        } else {
            return .purple
        }
    }
}
