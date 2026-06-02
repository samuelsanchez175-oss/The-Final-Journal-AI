import SwiftUI
import Combine

// MARK: - Theme Model
struct Theme: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let jargonTerms: [String]
    let contextDescription: String
    let relatedThemes: [String]
    let emotionalTone: String
}

// MARK: - Theme Expansion Sheet

struct ThemeExpansionSheet: View {
    let currentText: String
    let item: Item
    let onDismiss: () -> Void

    @State private var selectedThemeIDs: Set<String> = []
    @State private var detectedThemeNames: [String] = []
    @State private var isIdentifying: Bool = false
    @State private var identificationSource: String = ""
    @State private var searchText: String = ""
    @State private var selectedToneCategory: String? = nil
    @Environment(\.dismiss) private var dismiss

    private var catalogThemes: [Theme] { ThemeCatalog.all }

    private var filteredThemes: [Theme] {
        var themes = catalogThemes

        if !searchText.isEmpty {
            themes = themes.filter { theme in
                theme.name.localizedCaseInsensitiveContains(searchText) ||
                theme.selectionHint.localizedCaseInsensitiveContains(searchText) ||
                theme.jargonTerms.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                theme.categoryTags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                theme.matchKeywords.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        if let category = selectedToneCategory, category != "All" {
            themes = themes.filter { $0.toneCategory == category }
        }

        return themes
    }

    private var toneCategories: [String] {
        ThemeCatalog.toneCategories
    }

    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(Momentum.surfaceElevated)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            dismiss()
                            onDismiss()
                        }
                        .foregroundStyle(Momentum.accent)
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }

                    ScrollView {
                        VStack(spacing: 24) {
                            headerSection
                                .padding(.top, 20)

                            if !detectedThemeNames.isEmpty {
                                detectedThemesSection
                            }

                            themeSelectionSection

                            rescanButton
                                .padding(.horizontal, 20)
                                .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            let hasSaved = !item.selectedThemeIDs.isEmpty
            if hasSaved { selectedThemeIDs = Set(item.selectedThemeIDs) }
            await runThemeIdentification(useAI: true, preserveSelection: hasSaved)
        }
    }

    // MARK: - Identification

    private func runThemeIdentification(useAI: Bool, preserveSelection: Bool = false) async {
        guard !currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        await MainActor.run { isIdentifying = true }

        let result = await ThemeIdentificationService.identify(in: currentText, useAI: useAI)

        await MainActor.run {
            if !preserveSelection {
                selectedThemeIDs = result.themeIDs
            }
            detectedThemeNames = result.detectedNames
            identificationSource = result.source.rawValue
            isIdentifying = false
            item.selectedThemeIDs = Array(selectedThemeIDs)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
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

            Text("Theme Expansion")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Momentum.contentPrimary)

            Text("Themes auto-select from your lyrics. Choose any to steer where your narrative goes next.")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Detected Themes

    private var detectedThemesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Detected in your lyrics", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(Momentum.contentPrimary)

                Spacer()

                if isIdentifying {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.orange)
                } else if !identificationSource.isEmpty {
                    Text(identificationSource == "ai" ? "AI" : identificationSource == "combined" ? "Keywords + AI" : "Keywords")
                        .font(.caption2)
                        .foregroundStyle(Momentum.contentSecondary)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(detectedThemeNames, id: \.self) { name in
                        detectedThemePill(name: name)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 8)
    }

    private func detectedThemePill(name: String) -> some View {
        Text(name)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Momentum.surfaceElevated)
                    .overlay(
                        Capsule()
                            .stroke(Color.orange.opacity(0.45), lineWidth: 1)
                    )
            )
    }

    // MARK: - Theme Selection

    private var themeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Themes")
                    .font(.headline)
                    .foregroundStyle(Momentum.contentPrimary)

                Spacer()

                Text("\(selectedThemeIDs.count) selected")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Momentum.contentSecondary)

                    TextField("Search themes...", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Momentum.contentSecondary)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Momentum.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(toneCategories, id: \.self) { category in
                            toneFilterPill(category: category)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(filteredThemes) { theme in
                    ThemeSelectionCard(
                        theme: theme,
                        isSelected: selectedThemeIDs.contains(theme.id),
                        onToggle: { toggleSelection(theme.id) }
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

            if !recommendedThemes.isEmpty && !selectedThemeIDs.isEmpty {
                recommendationsSection
            }
        }
        .padding(.vertical, 20)
    }

    private func toneFilterPill(category: String) -> some View {
        let isSelected = (category == "All" && selectedToneCategory == nil) || selectedToneCategory == category

        return Button {
            selectedToneCategory = category == "All" ? nil : category
        } label: {
            Text(category)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.orange : Momentum.surfaceElevated)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.orange.opacity(0.8) : Color.primary.opacity(0.15),
                            lineWidth: 1
                        )
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    private func toggleSelection(_ id: String) {
        var updated = selectedThemeIDs
        if updated.contains(id) {
            updated.remove(id)
        } else {
            updated.insert(id)
        }
        selectedThemeIDs = updated
        item.selectedThemeIDs = Array(updated)
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.orange)
                Text("Pairs well with your selection")
                    .font(.headline)
                    .foregroundStyle(Momentum.contentPrimary)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recommendedThemes) { theme in
                        Button {
                            toggleSelection(theme.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(theme.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                Text(theme.toneCategory)
                                    .font(.caption2)
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                            .padding(10)
                            .frame(width: 140)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Momentum.surfaceElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(Color.orange.opacity(0.35), lineWidth: 1)
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

    private var recommendedThemes: [Theme] {
        guard !selectedThemeIDs.isEmpty else { return [] }

        let selectedThemes = catalogThemes.filter { selectedThemeIDs.contains($0.id) }
        var recommended = Set<Theme>()

        for selected in selectedThemes {
            let related = catalogThemes.filter { theme in
                !selectedThemeIDs.contains(theme.id) &&
                (selected.relatedThemes.contains(theme.name) ||
                 theme.relatedThemes.contains(selected.name))
            }
            recommended.formUnion(related)
        }

        return Array(recommended).prefix(6).map { $0 }
    }

    // MARK: - Re-scan (AI identification only — no lyric generation yet)

    private var rescanButton: some View {
        Button {
            Task { await runThemeIdentification(useAI: true) }
        } label: {
            HStack(spacing: 8) {
                if isIdentifying {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.white)
                }
                Text(isIdentifying ? "Scanning lyrics..." : "Re-scan from Lyrics")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(isIdentifying || currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
    }
}

// MARK: - Theme Selection Card

struct ThemeSelectionCard: View {
    let theme: Theme
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onToggle()
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(theme.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 4)

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .orange : .secondary.opacity(0.35))
                        .font(.body)
                }

                Text(theme.selectionHint)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                if !theme.jargonTerms.isEmpty {
                    Text(theme.jargonTerms.prefix(2).joined(separator: " · "))
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary.opacity(0.8))
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(emotionalToneColor(theme.emotionalTone))

                    Text(theme.toneCategory)
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }

                if !theme.categoryTags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(theme.categoryTags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? Color.white.opacity(0.2) : Color.orange.opacity(0.12))
                                )
                                .foregroundStyle(isSelected ? .white.opacity(0.95) : .orange)
                        }
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .background(cardBackground)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var cardBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.45), Color.orange.opacity(0.28)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.orange, lineWidth: 2)
                )
        } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Momentum.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
        }
    }

    private func emotionalToneColor(_ tone: String) -> Color {
        let lowercased = tone.lowercased()
        if lowercased.contains("gritty") || lowercased.contains("defiant") { return .red }
        if lowercased.contains("luxur") || lowercased.contains("aspir") { return .purple }
        if lowercased.contains("calculat") || lowercased.contains("opportun") { return .blue }
        if lowercased.contains("paranoid") { return .gray }
        if lowercased.contains("celebrat") { return .green }
        return .orange
    }
}
