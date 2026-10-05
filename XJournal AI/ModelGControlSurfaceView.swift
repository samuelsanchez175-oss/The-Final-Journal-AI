//
// ModelGControlSurfaceView.swift
// Pre-generation sheet: direction, style, optional word/topic/tone/rhyme constraints.
// Generate runs with DirectedGenerationParams into the single Model G pipeline.
//

import SwiftUI

struct ModelGControlSurfaceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let rhymeGroups: [RhymeHighlighterEngine.RhymeGroup]
    /// Note BPM / key / scale so wrap can show the attached beat.
    var noteBPM: Int? = nil
    var noteKey: String? = nil
    var noteScale: String? = nil
    @Binding var syllableMin: Int?
    @Binding var syllableMax: Int?
    /// Called with params and a lookup so the prompt builder can resolve selectedRhymeGroupIDs.
    let onGenerate: (DirectedGenerationParams, [RhymeGroupID: RhymeGroupSummary]) -> Void

    @State private var userPrompt: String = ""
    @State private var lineCount: Int = 4
    @State private var endRhymeLines: Int = 2
    @State private var selectedRhymeGroupIDs: Set<RhymeGroupID> = []
    @State private var highlightWordsText: String = ""
    @State private var mustUseWordsText: String = ""
    @State private var recipeSeedText: String = ""
    @State private var semanticSoundText: String = ""
    @State private var semanticSensesText: String = ""
    @State private var selectedTones: Set<EmotionalTone> = []
    @State private var selectedTopicsText: String = ""
    @State private var worldBuildingText: String = ""
    @State private var styleOverrideKey: String = "auto"
    @State private var isWorldBuildingExpanded = false
    @State private var copyLastFourRhythm = true
    @State private var pastedFlowText = ""
    @State private var isPasteFlowExpanded = false
    @State private var youUsePeople = true
    @State private var youUseBottle = true
    @State private var youStreetOnly = false
    @State private var gunnaWrap = true
    @State private var wrapPocket: WrapPocket = .behind
    @State private var wrapBpmSource: WrapBpmSource = .note
    @State private var wrapBpmCustomText = ""
    @State private var targetBarCount = 16
    @State private var punchGrammar: PunchGrammar = .couplet
    @State private var adlibOnFour = false
    @State private var acrosticWordText = ""
    @State private var storyArc = false
    @State private var lyricalPainting = false
    @State private var breakTheRun = false
    @State private var scatFirst = false
    @State private var setupOnlyRefs = true
    @State private var isSchemesExpanded = false
    @State private var isAdvancedExpanded = false
    @AppStorage("toolbar_ai_last_suggestion_model") private var selectedModelRaw: String = SuggestionModel.modelG.rawValue

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
        let recipeSeed = recipeSeedText.trimmingCharacters(in: .whitespacesAndNewlines)
        let semanticSound = semanticSoundText.trimmingCharacters(in: .whitespacesAndNewlines)
        let semanticSenses = semanticSensesText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.map { String($0) }
        let topics = selectedTopicsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.map { String($0) }
        let worldBuilding = worldBuildingText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.map { String($0) }
        let resolvedGroups = rhymeGroups
            .filter { selectedRhymeGroupIDs.contains($0.id) }
            .map { RhymeGroupSummary(key: $0.key, words: $0.words.map(\.word)) }
        return DirectedGenerationParams(
            userPrompt: userPrompt,
            selectedRhymeGroupIDs: Array(selectedRhymeGroupIDs),
            selectedRhymeGroups: resolvedGroups,
            highlightAnchors: highlightAnchors,
            mustUseTokens: mustUseTokens,
            recipeSeed: recipeSeed,
            semanticSound: semanticSound,
            semanticSenses: semanticSenses,
            copyLastFourRhythm: copyLastFourRhythm,
            pastedFlowText: pastedFlowText,
            gunnaWrap: gunnaWrap,
            wrapPocket: wrapPocket,
            wrapBpmSource: wrapBpmSource,
            wrapBpmCustom: Int(wrapBpmCustomText.trimmingCharacters(in: .whitespaces)),
            targetBarCount: targetBarCount,
            punchGrammar: punchGrammar,
            adlibOnFour: adlibOnFour,
            acrosticWord: acrosticWordText,
            storyArc: storyArc,
            lyricalPainting: lyricalPainting,
            breakTheRun: breakTheRun,
            scatFirst: scatFirst,
            setupOnlyRefs: setupOnlyRefs,
            selectedTopics: topics,
            selectedTones: Array(selectedTones),
            worldBuildingWords: worldBuilding,
            lineCount: lineCount,
            syllableTolerance: 2,
            minEndRhymeLines: endRhymeLines,
            styleOverride: Self.styleOptions.first(where: { $0.key == styleOverrideKey })?.key == "auto" ? nil : Self.styleOptions.first(where: { $0.key == styleOverrideKey })?.profile,
            youFilters: ModelYouVerseFilters(
                usePeople: youUsePeople,
                useBottle: youUseBottle,
                streetOnly: youStreetOnly
            )
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
                lineCount = 4
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

    private var selectedModel: SuggestionModel {
        get { SuggestionModel(rawValue: selectedModelRaw) ?? .modelG }
        nonmutating set { selectedModelRaw = newValue.rawValue }
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            modelPickerSection
            if selectedModel == .modelYou { youFilterSection }
            wrapSection
            syllableCountSection
            schemeChipsSection
            userPromptSection
            styleOverrideSection
            endRhymeSection
            topicsSection
            toneSection
            advancedSection
        }
        .padding()
    }

    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "Advanced")
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isAdvancedExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tweak BPM, cages, and rhyme groups")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Momentum.accent)
                            .multilineTextAlignment(.leading)
                        Text("BPM, punch recipe, keyword cage, copy-flow, and rhyme groups. Leave closed unless you want to tweak.")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: isAdvancedExpanded ? "chevron.down" : "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Momentum.accent)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .fill(Momentum.accent.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .stroke(Momentum.accent.opacity(0.55), lineWidth: Momentum.lineThin)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Tweak BPM, cages, and rhyme groups")
            .accessibilityHint("Opens extra wrap controls. Leave closed unless you want to tweak.")
            .accessibilityAddTraits(.isButton)

            if isAdvancedExpanded {
                VStack(alignment: .leading, spacing: 20) {
                    wrapBpmSection
                    punchContentSection
                    wordsToEmphasizeSection
                    copyFlowSection
                    rhymeGroupsSection
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
                )
            }
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

    private var modelPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Model")
            Picker("Model", selection: $selectedModelRaw) {
                ForEach(SuggestionModel.sparklePickerModels, id: \.self) { model in
                    Text(model.displayName).tag(model.rawValue)
                }
            }
            .pickerStyle(.segmented)
            if selectedModel == .modelYou {
                Text(ModelYouWriterPolicy.controlSurfaceCaption(brain: ArtistBrainStore.shared.brain))
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var youFilterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            MomentumSectionHeader(title: "This verse")
            Toggle("Use people", isOn: $youUsePeople)
                .disabled(youStreetOnly)
            Toggle("Use the bottle", isOn: $youUseBottle)
                .disabled(youStreetOnly)
            Toggle("Street only", isOn: $youStreetOnly)
            Text("Filters retrieve. They are not a new model.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var wrapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "Wrap")
            Toggle(isOn: Binding(
                get: { gunnaWrap },
                set: { on in
                    gunnaWrap = on
                    if on {
                        wrapPocket = .behind
                        punchGrammar = .couplet
                    }
                }
            )) {
                Text("Gunna wrap").font(.subheadline.weight(.semibold))
            }
            Text(gunnaWrap
                 ? "Punch lands late (beats 3–4), pocket repeats, hats at 140 write half-time — not double-time."
                 : "Clock off. Direction, recipe, and cages still apply.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            Text(noteBeatCaption)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)

            Picker("", selection: Binding(
                get: { targetBarCount },
                set: { newValue in
                    targetBarCount = newValue
                    if newValue == 4 { storyArc = false }
                }
            )) {
                Text("4-bar cycle").tag(4)
                Text("Repeat to 16").tag(16)
            }
            .pickerStyle(.segmented)
            if storyArc {
                Text("Story arc writes 16 — a 4-bar cycle turns the journey off.")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }

            if gunnaWrap {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pocket").font(.caption).foregroundStyle(Momentum.contentSecondary)
                    Picker("", selection: $wrapPocket) {
                        ForEach(WrapPocket.allCases, id: \.self) { pocket in
                            Text(pocket.pickerLabel).tag(pocket)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Punch").font(.caption).foregroundStyle(Momentum.contentSecondary)
                    Picker("", selection: $punchGrammar) {
                        ForEach(PunchGrammar.allCases, id: \.self) { grammar in
                            Text(grammar.pickerLabel).tag(grammar)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle(isOn: $adlibOnFour) {
                        Text("yeah on the 4").font(.subheadline.weight(.semibold))
                    }
                    Text("Marks beat 4 like a metronome click. Not a bar.")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                }
            }
        }
    }

    private var schemeChipsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Optional schemes")
            Text("Leave these off unless you want a specific Ohm drill. Gunna wrap stays sparse without them.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            DisclosureGroup(isExpanded: $isSchemesExpanded) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $setupOnlyRefs) {
                        Text("Names can stay in the setup").font(.subheadline.weight(.semibold))
                    }
                    Text("The punch does not have to cash every brand or name. On by default.")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)

                    Toggle(isOn: Binding(
                        get: { storyArc },
                        set: { on in
                            storyArc = on
                            if on { targetBarCount = 16 }
                        }
                    )) {
                        Text("Story arc").font(.subheadline.weight(.semibold))
                    }
                    Text("The 16 is a journey (home → call → climax → return changed), not eight punch couplets. Needs Repeat to 16. Default: off.")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)

                    Toggle(isOn: $lyricalPainting) {
                        Text("Describe the flow").font(.subheadline.weight(.semibold))
                    }
                    Text("Some bars talk about the cadence itself, or teach while they rap. Default: off.")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)

                    Toggle(isOn: $scatFirst) {
                        Text("Rhythm first").font(.subheadline.weight(.semibold))
                    }
                    Text("Place yeah/uh stresses, then drop nouns into those slots. Uses copy-flow if it's on. Default: off.")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)

                    Text("Acrostic").font(.subheadline.weight(.semibold))
                    TextField("Word the first letters spell, e.g. GUNNA", text: $acrosticWordText)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                    Text("Each bar starts with the next letter of this word. Leave blank to skip. Default: off.")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .padding(.top, 8)
            } label: {
                Text("Story, rhythm, acrostic, setup-only names")
                    .font(.subheadline)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
    }

    private var wrapBpmSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "BPM")
            Text("Defaults to this note’s beat, or the attached audio. Change only if you want a different clock.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            Picker("", selection: $wrapBpmSource) {
                ForEach(WrapBpmSource.allCases, id: \.self) { source in
                    Text(source.pickerLabel).tag(source)
                }
            }
            .pickerStyle(.segmented)
            if wrapBpmSource == .custom {
                TextField("BPM", text: $wrapBpmCustomText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }
            Text(foldedBpmCaption)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var noteBeatCaption: String {
        var bits: [String] = []
        if let bpm = noteBPM { bits.append("\(bpm) BPM") }
        let key = noteKey?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let scale = noteScale?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !key.isEmpty {
            bits.append(scale.isEmpty ? key : "\(key) \(scale)")
        }
        if bits.isEmpty {
            return "No beat on this note yet. If audio is attached, generate still reads it. Default pocket is 92."
        }
        return "This note’s beat: \(bits.joined(separator: " · ")). Wrap uses it unless you change BPM in Advanced."
    }

    private var foldedBpmCaption: String {
        let raw: Int?
        switch wrapBpmSource {
        case .wrap92: raw = 92
        case .custom: raw = Int(wrapBpmCustomText.trimmingCharacters(in: .whitespaces)) ?? noteBPM
        case .note: raw = noteBPM
        }
        let clock = BarClock.resolve(userBPM: raw, pocket: wrapPocket, foldHatsEnabled: true)
        if let raw, clock.hatsFolded {
            return "Note \(raw) → write at \(Int(clock.bpm.rounded())) BPM (hats folded)."
        }
        if raw == nil, wrapBpmSource == .note {
            return "No note BPM — writes at 92."
        }
        return "Writes at \(Int(clock.bpm.rounded())) BPM, \(clock.pocket.promptLabel)."
    }

    private var syllableCountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Syllables per bar")
            SyllableCountButtonGrid(syllableMin: $syllableMin, syllableMax: $syllableMax)
            HStack {
                Button {
                    syllableMin = nil
                    syllableMax = nil
                } label: {
                    Text("Auto")
                        .font(.callout)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Clears the count so Model G follows the beat.")
                Spacer()
            }
            Text(syllableCountCaption)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var syllableCountCaption: String {
        if let lo = syllableMin, let hi = syllableMax, lo == hi {
            return "Every bar aims at \(lo) syllables."
        }
        if let lo = syllableMin, let hi = syllableMax {
            return "Every bar aims between \(lo) and \(hi) syllables."
        }
        return "Tap a count to aim every bar at that length. Auto follows the beat."
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
            Toggle(isOn: $breakTheRun) {
                Text("Break the run").font(.subheadline.weight(.semibold))
            }
            Text("After the rhyme hold above, switch the ending sound and the cadence on purpose. Leave off to keep the pocket. Default: off.")
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
            MomentumSectionHeader(title: "Keyword cage")
            Text("Optional. Four to six words: every bar touches one. One word becomes the recipe seed if Recipe word is blank. Two or three stay verbatim must-use.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            TextField("Near-rhyme or mood, e.g. drip, flow, ice", text: $highlightWordsText)
                .textFieldStyle(.roundedBorder)
            TextField("Cage or must-use words, comma-separated", text: $mustUseWordsText)
                .textFieldStyle(.roundedBorder)
            Text("Gunna wrap stays sparse — leave this empty unless you want an Ohm drill.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var punchContentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Punch content")
            Text("Optional. Cooks the punch before the verse is written — one seed, or one sound with several meanings.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            TextField("Recipe word, e.g. laser", text: $recipeSeedText)
                .textFieldStyle(.roundedBorder)
            TextField("Sound cage, e.g. switch", text: $semanticSoundText)
                .textFieldStyle(.roundedBorder)
            TextField("Meanings for that sound, comma-separated (optional)", text: $semanticSensesText)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var copyFlowSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Copy-flow")
            Toggle(isOn: $copyLastFourRhythm) {
                Text("Copy last 4 bars' rhythm").font(.subheadline.weight(.semibold))
            }
            Text("Keeps the syllable map and late punch of your last four lines, then swaps in new nouns. Off = don't use the draft as a pocket.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            DisclosureGroup(isExpanded: $isPasteFlowExpanded) {
                TextField("Paste 4 bars to steal the pocket (not the words)", text: $pastedFlowText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(4...8)
                    .padding(.top, 4)
            } label: {
                Text("Paste a 4-bar pocket")
                    .font(.subheadline)
                    .foregroundStyle(Momentum.contentSecondary)
            }
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

