//
// ModelGControlSurfaceView.swift
// Pre-generation sheet: direction, style, optional word/topic/tone/rhyme constraints.
// Generate runs with DirectedGenerationParams into Model G v3.
//

import SwiftUI

struct ModelGControlSurfaceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let rhymeGroups: [RhymeHighlighterEngine.RhymeGroup]
    /// Called with params and a lookup so the prompt builder can resolve selectedRhymeGroupIDs.
    let onGenerate: (DirectedGenerationParams, [RhymeGroupID: RhymeGroupSummary]) -> Void

    @State private var userPrompt: String = ""
    @State private var lineCount: Int = 4
    @State private var selectedRhymeGroupIDs: Set<RhymeGroupID> = []
    @State private var highlightWordsText: String = ""
    @State private var mustUseWordsText: String = ""
    @State private var selectedTones: Set<EmotionalTone> = []
    @State private var selectedTopicsText: String = ""
    @State private var worldBuildingText: String = ""
    @State private var styleOverrideKey: String = "auto"
    @State private var modelChoice: ModelGGraderChoice = .v5
    @State private var isWorldBuildingExpanded = false

    private static let styleOptions: [(key: String, label: String, profile: StyleProfile)] = [
        ("auto", "Auto", StyleProfile.coldTrap),
        ("coldTrap", "Cold Trap", StyleProfile.coldTrap),
        ("floatyTrap", "Floaty Trap", StyleProfile.floatyTrap),
        ("toxicTrap", "Toxic Trap", StyleProfile.toxicTrap),
        ("darkAggressive", "Dark Aggressive", StyleProfile.darkAggressiveTrap),
        ("luxuryCinematic", "Luxury Cinematic", StyleProfile.luxuryCinematicTrap)
    ]

    private var params: DirectedGenerationParams {
        let highlightAnchors = highlightWordsText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { TokenSpan(word: String($0), strength: .near) }
        let mustUseTokens = mustUseWordsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.map { String($0) }
        let topics = selectedTopicsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.map { String($0) }
        let worldBuilding = worldBuildingText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.map { String($0) }
        return DirectedGenerationParams(
            userPrompt: userPrompt,
            selectedRhymeGroupIDs: Array(selectedRhymeGroupIDs),
            highlightAnchors: highlightAnchors,
            mustUseTokens: mustUseTokens,
            selectedTopics: topics,
            selectedTones: Array(selectedTones),
            worldBuildingWords: worldBuilding,
            lineCount: lineCount,
            syllableTolerance: 2,
            minEndRhymeLines: nil,
            styleOverride: Self.styleOptions.first(where: { $0.key == styleOverrideKey })?.key == "auto" ? nil : Self.styleOptions.first(where: { $0.key == styleOverrideKey })?.profile
        )
    }

    private var rhymeGroupsByID: [RhymeGroupID: RhymeGroupSummary] {
        Dictionary(uniqueKeysWithValues: rhymeGroups.map { ($0.id, RhymeGroupSummary(key: $0.key, words: $0.words.map(\.word))) })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    formContent
                }
                generateFooter
            }
            .navigationTitle("Suggest next lines")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let defaultFromProfile = UserDefaults.standard.object(forKey: "suggestion_default_line_count") as? Int ?? 4
                lineCount = (defaultFromProfile == 2 || defaultFromProfile == 4) ? defaultFromProfile : 4
                modelChoice = ModelGGraderChoice.current()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // Fixed footer — square PrimaryActionButton with a coral CounterPill (# tones selected).
    private var generateFooter: some View {
        Button {
            modelChoice.apply()
            onGenerate(params, rhymeGroupsByID)
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Text("Generate")
                if !selectedTones.isEmpty {
                    Text("\(selectedTones.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Momentum.onInverse)
                        .padding(.horizontal, 7).padding(.vertical, 2)
                        .background(Rectangle().fill(Momentum.accent))
                }
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
        .padding(Momentum.edge)
        .background(
            Momentum.surface
                .overlay(alignment: .top) { Rectangle().fill(Momentum.hairline).frame(height: Momentum.lineThin) }
        )
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            modelSection
            userPromptSection
            styleOverrideSection
            lineCountSection
            wordsToEmphasizeSection
            topicsSection
            toneSection
            rhymeGroupsSection
        }
        .padding()
    }

    private var modelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Model")
            Picker("", selection: $modelChoice) {
                ForEach(ModelGGraderChoice.allCases) { choice in
                    Text(choice.displayName).tag(choice)
                }
            }
            .pickerStyle(.menu)
            Text(modelChoice.blurb)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var styleOverrideSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Style")
            Picker("", selection: $styleOverrideKey) {
                ForEach(Self.styleOptions, id: \.key) { option in
                    Text(option.label).tag(option.key)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var userPromptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Direction")
            TextField("What should the next lines be about? Leave blank to continue the draft.", text: $userPrompt, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
    }

    private var lineCountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Lines to generate")
            Picker("", selection: $lineCount) {
                Text("2 (fast)").tag(2)
                Text("4 (standard)").tag(4)
            }
            .pickerStyle(.segmented)
        }
    }

    private var rhymeGroupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "Rhyme groups")
            if rhymeGroups.isEmpty {
                Text("Add lyrics to your draft to pick rhyme groups here (via Magnifier).")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                    )
            } else {
                ForEach(rhymeGroups) { group in
                    rhymeGroupCard(group: group)
                }
            }
        }
    }

    private func rhymeGroupCard(group: RhymeHighlighterEngine.RhymeGroup) -> some View {
        let isSelected = selectedRhymeGroupIDs.contains(group.id)
        return Button {
            if isSelected {
                selectedRhymeGroupIDs.remove(group.id)
            } else {
                selectedRhymeGroupIDs.insert(group.id)
            }
        } label: {
            rhymeGroupCardLabel(isSelected: isSelected, group: group)
        }
        .buttonStyle(.plain)
    }

    private func rhymeGroupCardLabel(isSelected: Bool, group: RhymeHighlighterEngine.RhymeGroup) -> some View {
        let bgColor = colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04)
        return VStack(alignment: .leading, spacing: 8) {
            Text(group.key)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Text(group.words.map(\.word).joined(separator: " · "))
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(bgColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .overlay(alignment: .topTrailing) {
            checkmarkOverlay(show: isSelected)
        }
    }

    @ViewBuilder
    private func checkmarkOverlay(show: Bool) -> some View {
        if show {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundStyle(Color.accentColor)
                .padding(8)
        }
    }

    private var wordsToEmphasizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Words to emphasize")
            Text("Optional — nudge rhyme and imagery without rewriting the draft.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            TextField("Near-rhyme or mood, e.g. drip, flow, ice", text: $highlightWordsText)
                .textFieldStyle(.roundedBorder)
            TextField("Must appear verbatim, comma-separated", text: $mustUseWordsText)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var toneSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Tone")
            FlowLayout(spacing: 8) {
                ForEach(EmotionalTone.allCases, id: \.self) { tone in
                    toneChip(tone: tone)
                }
            }
        }
    }

    private func toneChip(tone: EmotionalTone) -> some View {
        let isSelected = selectedTones.contains(tone)
        return Button {
            if isSelected {
                selectedTones.remove(tone)
            } else {
                selectedTones.insert(tone)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 13, weight: .semibold))
                Text(tone.rawValue).font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .foregroundStyle(isSelected ? Momentum.accent : Momentum.contentSecondary)
            .background(Rectangle().fill(Momentum.surfaceElevated))
            .overlay(Rectangle().stroke(isSelected ? Momentum.accent : Momentum.hairline, lineWidth: Momentum.lineThin))
        }
        .buttonStyle(.plain)
    }

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Topics")
            TextField("Themes to hit, comma-separated", text: $selectedTopicsText)
                .textFieldStyle(.roundedBorder)

            DisclosureGroup(isExpanded: $isWorldBuildingExpanded) {
                TextField("Places, textures, props — comma-separated", text: $worldBuildingText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 4)
            } label: {
                Text("World-building detail")
                    .font(.subheadline)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
    }
}

// MARK: - Selectable Model G variant (suggest-next-lines flow)

/// User-facing Model G choice on the "Suggest next lines" sheet.
///
/// Both options run the same RAG-grounded Model G Core (v4) verse generation; the choice swaps
/// the best-of-N grader that picks which candidate verse you get. "Model G v5" uses the
/// recalibrated, typicality-calibrated `VerseLedgerV5Scorer`; "Model G v4" uses the original
/// `VerseLedgerScorer`. Selecting an option writes the existing `ModelGEnvironment` flags, so the
/// pick sticks and drives the next generation (and shows up on each suggestion card's source line).
enum ModelGGraderChoice: String, CaseIterable, Identifiable {
    case v5
    case v4

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .v5: return "Model G v5"
        case .v4: return "Model G v4"
        }
    }

    var blurb: String {
        switch self {
        case .v5: return "RAG-grounded verse, picked by the v5 grader — typicality-calibrated and slant-rhyme aware. Recommended."
        case .v4: return "RAG-grounded verse, picked by the original v4 authenticity grader."
        }
    }

    /// Persist this choice into the Model G environment flags that drive generation.
    func apply() {
        ModelGEnvironment.useModelGv4 = true
        ModelGEnvironment.useV5Grader = (self == .v5)
    }

    /// The choice reflecting the current environment flags (so the picker opens on what's active).
    static func current() -> ModelGGraderChoice {
        ModelGEnvironment.useV5Grader ? .v5 : .v4
    }
}

