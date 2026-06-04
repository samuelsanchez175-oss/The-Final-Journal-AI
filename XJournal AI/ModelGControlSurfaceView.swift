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
    @State private var endRhymeLines: Int = 2
    @State private var selectedRhymeGroupIDs: Set<RhymeGroupID> = []
    @State private var highlightWordsText: String = ""
    @State private var mustUseWordsText: String = ""
    @State private var selectedTones: Set<EmotionalTone> = []
    @State private var selectedTopicsText: String = ""
    @State private var worldBuildingText: String = ""
    @State private var styleOverrideKey: String = "auto"
    @State private var isWorldBuildingExpanded = false

    // v3↔v4 engine A/B switch. Same key the directed-generation router reads
    // (RapSuggestionAPI.generateModelGCoreRecordWithRetry: useModelGv4 → CoordinatorV4, else v3),
    // so flipping this here changes which pipeline this sheet's Generate runs. Off by default.
    @AppStorage("model_g_v4_enabled") private var useModelGv4 = false

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
            minEndRhymeLines: endRhymeLines,
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
                let savedRhyme = UserDefaults.standard.object(forKey: "suggestion_default_end_rhyme_lines") as? Int ?? 2
                endRhymeLines = [2, 4, 6, 8].contains(savedRhyme) ? savedRhyme : 2
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
            onGenerate(params, rhymeGroupsByID)
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Text("Generate")
                if !selectedTones.isEmpty {
                    Text("\(selectedTones.count)")
                        .font(.footnote.weight(.bold))
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
            modelGEngineSection
            userPromptSection
            styleOverrideSection
            lineCountSection
            endRhymeSection
            wordsToEmphasizeSection
            topicsSection
            toneSection
            rhymeGroupsSection
        }
        .padding()
    }

    private var modelGEngineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Generation engine")
            Toggle(isOn: $useModelGv4) {
                Text("Use Model G v4 engine").font(.subheadline.weight(.semibold))
            }
            Text("Generates with the newer v4 pipeline, which grounds your bars in your reference-lyric corpus. Takes priority over v3 when on. Experimental — off by default.")
                .font(.caption).foregroundStyle(Momentum.contentSecondary)
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

    private var endRhymeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Lines per rhyme")
            Picker("", selection: Binding(
                get: { endRhymeLines },
                set: { newValue in
                    endRhymeLines = newValue
                    UserDefaults.standard.set(newValue, forKey: "suggestion_default_end_rhyme_lines")
                }
            )) {
                Text("2").tag(2)
                Text("4").tag(4)
                Text("6").tag(6)
                Text("8").tag(8)
            }
            .pickerStyle(.segmented)
            Text(endRhymeCaption)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var endRhymeCaption: String {
        switch endRhymeLines {
        case 2: return "The ending rhyme switches every 2 lines — couplets, the fastest switch."
        case 4: return "The same ending rhyme is held for 4 lines before it switches."
        case 6: return "The same ending rhyme is held for 6 lines before it switches."
        default: return "One ending rhyme carried across 8 lines — the slowest switch."
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
                    .font(.footnote.weight(.semibold))
                Text(tone.rawValue).font(.subheadline.weight(.medium))
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

