//
// ModelGControlSurfaceView.swift
// Suggest next lines. Direction comes from the open note. The live row is Model G Core v4.
//

import SwiftUI
import AVFoundation

struct ModelGControlSurfaceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let rhymeGroups: [RhymeHighlighterEngine.RhymeGroup]
    var noteBPM: Int? = nil
    var noteKey: String? = nil
    var noteScale: String? = nil
    /// Written lines on the open note. The sheet does not ask for a direction.
    var noteText: String = ""
    /// Attached audio transcript, when the note has one.
    var noteTranscript: String? = nil
    @Binding var syllableMin: Int?
    @Binding var syllableMax: Int?
    let onGenerate: (DirectedGenerationParams, [RhymeGroupID: RhymeGroupSummary]) -> Void

    @State private var lineModel: SuggestNextLinesModel = .v6
    @State private var targetBarCount = 16
    @State private var endRhymeLines: Int = 2
    @State private var corpusTones: [CorpusTone] = []
    @State private var wrapPocket: WrapPocket = .onTop
    @State private var punchGrammar: PunchGrammar = .couplet
    @State private var breakTheRun = false
    @State private var isAdvancedExpanded = false
    @State private var freestyleAudioPath: String?
    @State private var freestyleError: String?
    @StateObject private var freestyleRecorder = AudioRecorderManager()

    private var params: DirectedGenerationParams {
        let bars = targetBarCount == 4 ? 4 : 16
        return DirectedGenerationParams(
            userPrompt: DirectedGenerationParams.directionFromOpenNote(
                noteText: noteText,
                transcript: noteTranscript
            ),
            gunnaWrap: true,
            wrapPocket: wrapPocket,
            targetBarCount: bars,
            punchGrammar: punchGrammar,
            breakTheRun: breakTheRun,
            scatFirst: true,
            setupOnlyRefs: true,
            lineCount: bars,
            syllableTolerance: 2,
            minEndRhymeLines: endRhymeLines,
            corpusTones: corpusTones,
            freestyleMatchAudioPath: freestyleAudioPath,
            suggestModel: lineModel
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

    private var generateFooter: some View {
        Button {
            if syllableMin == nil || syllableMax == nil {
                syllableMin = SyllableBand.standard.low
                syllableMax = SyllableBand.standard.high
            }
            onGenerate(params, rhymeGroupsByID)
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Text("Generate")
                if !corpusTones.isEmpty {
                    Text("\(corpusTones.count)")
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
            modelSection
            lengthSection
            syllableCountSection
            endRhymeSection
            toneSection
            advancedSection
        }
        .padding()
    }

    private var modelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Model")
            HStack(spacing: 8) {
                modelChoice(.v6, enabled: SuggestNextLinesModel.v6.isCallable)
                modelChoice(.v7, enabled: SuggestNextLinesModel.v7.isCallable)
            }
            Text(lineModel == .v7
                 ? "V7 uses the in-app writer plus the V7 rhyme, syllable, and cliché rules."
                 : "Current (Model G v4) is the verse writer already in the app. V7 is selectable.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private func modelChoice(_ model: SuggestNextLinesModel, enabled: Bool) -> some View {
        let selected = lineModel == model
        return Button {
            if enabled { lineModel = model }
        } label: {
            Text(model.title)
                .multilineTextAlignment(.center)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(selected ? Momentum.accent : Momentum.contentSecondary)
                .background(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .fill(selected ? Momentum.accent.opacity(0.10) : Momentum.surfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .stroke(selected ? Momentum.accent : Momentum.hairline, lineWidth: Momentum.lineThin)
                )
                .opacity(enabled ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(enabled ? model.title : "\(model.title), coming soon")
    }

    private var lengthSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Length")
            Picker("Length", selection: $targetBarCount) {
                Text("4 bars").tag(4)
                Text("16 bars").tag(16)
            }
            .pickerStyle(.segmented)
        }
    }

    private var syllableCountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Syllables per bar")
            Picker("Syllables per bar", selection: syllableBandBinding) {
                ForEach(SyllableBand.allCases) { band in
                    Text(band.title).tag(band)
                }
            }
            .pickerStyle(.segmented)
            Text(syllableCaption)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var syllableBandBinding: Binding<SyllableBand> {
        Binding(
            get: { SyllableBand.matching(min: syllableMin, max: syllableMax) ?? .standard },
            set: { band in
                syllableMin = band.low
                syllableMax = band.high
            }
        )
    }

    private var syllableCaption: String {
        if let band = SyllableBand.matching(min: syllableMin, max: syllableMax) {
            return band.caption
        }
        if let lo = syllableMin, let hi = syllableMax {
            return "This note is set to \(lo)–\(hi). Pick a group to replace it."
        }
        return SyllableBand.standard.caption
    }

    private var endRhymeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Lines per rhyme")
            Picker("Lines per rhyme", selection: Binding(
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

    private var toneSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MomentumSectionHeader(title: "Tone")
            FlowLayout(spacing: 8) {
                ForEach(CorpusTone.allCases) { tone in
                    toneChip(tone: tone)
                }
            }
        }
    }

    private func toneChip(tone: CorpusTone) -> some View {
        let isSelected = corpusTones.contains(tone)
        return Button {
            if isSelected {
                corpusTones.removeAll { $0 == tone }
            } else {
                corpusTones.append(tone)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.footnote.weight(.semibold))
                Text(tone.displayName).font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .foregroundStyle(isSelected ? Momentum.accent : Momentum.contentSecondary)
            .background(Rectangle().fill(Momentum.surfaceElevated))
            .overlay(Rectangle().stroke(isSelected ? Momentum.accent : Momentum.hairline, lineWidth: Momentum.lineThin))
        }
        .buttonStyle(.plain)
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
                        Text("Pocket, punch, break the run")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Momentum.accent)
                            .multilineTextAlignment(.leading)
                        Text("Closed unless you want to change the pocket. Defaults: on top, late, break off.")
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
            .accessibilityLabel("Pocket, punch, break the run")

            if isAdvancedExpanded {
                VStack(alignment: .leading, spacing: 20) {
                    pocketSection
                    punchSection
                    breakTheRunSection
                    freestyleSection
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

    private var pocketSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pocket").font(.subheadline.weight(.semibold))
            Picker("Pocket", selection: $wrapPocket) {
                ForEach(WrapPocket.allCases, id: \.self) { pocket in
                    Text(pocket.pickerLabel).tag(pocket)
                }
            }
            .pickerStyle(.segmented)
            Text(pocketCaption)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var pocketCaption: String {
        var bits: [String] = []
        if let bpm = noteBPM { bits.append("\(bpm) BPM") }
        let key = noteKey?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let scale = noteScale?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !key.isEmpty {
            bits.append(scale.isEmpty ? key : "\(key) \(scale)")
        }
        let beat = bits.isEmpty ? "No beat on this note." : "This note: \(bits.joined(separator: " · "))."
        return "\(beat) Default pocket is on top."
    }

    private var punchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Punch").font(.subheadline.weight(.semibold))
            Picker("Punch", selection: $punchGrammar) {
                ForEach(PunchGrammar.allCases, id: \.self) { grammar in
                    Text(grammar.pickerLabel).tag(grammar)
                }
            }
            .pickerStyle(.segmented)
            Text("Late. The last stress stays on beats 3–4. Couplet is the grammar.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var breakTheRunSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $breakTheRun) {
                Text("Break the run").font(.subheadline.weight(.semibold))
            }
            Text("Around every 3–4 bars, switch the ending sound and the cadence. Off keeps the lines-per-rhyme hold. Default: off.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var freestyleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Freestyle match").font(.subheadline.weight(.semibold))
            Text("Rap your own lyrics over the beat and record a take. Matching syllables, pocket, and end sounds from that take is not hooked up yet.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            Button {
                toggleFreestyleRecording()
            } label: {
                Text(freestyleRecorder.isRecording ? "Stop" : "Record a take")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(MomentumSquareButtonStyle(fill: .outline))
            if freestyleAudioPath != nil {
                Text("Take saved. It rides with this suggestion. The flow match is still to do.")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            if let freestyleError {
                Text(freestyleError)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
    }

    private func toggleFreestyleRecording() {
        if freestyleRecorder.isRecording {
            freestyleAudioPath = freestyleRecorder.stopRecording()
            freestyleError = freestyleAudioPath == nil ? "The take did not save." : nil
            return
        }
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                guard granted else {
                    freestyleError = "The microphone is off for Penwork."
                    return
                }
                let url = FileManager.default.temporaryDirectory
                    .appendingPathComponent("freestyle-match-\(UUID().uuidString).m4a")
                freestyleError = nil
                freestyleRecorder.startRecording(to: url.path)
                if !freestyleRecorder.isRecording {
                    freestyleError = "Recording did not start."
                }
            }
        }
    }
}
