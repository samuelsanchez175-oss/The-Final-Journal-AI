//
//  GenerateLyricsFromFlowSheet.swift
//  XJournal AI
//
//  Generate Lyrics from Flow: Scenario A (clear speech) and Scenario B (mumble).
//

import SwiftUI
import SwiftData

struct GenerateLyricsFromFlowSheet: View {
    let item: Item
    let onInsertLyrics: (String) -> Void
    let onDismiss: () -> Void
    /// When no audio, offer opening recorder / import from the sheet.
    var onOpenRecorder: (() -> Void)? = nil
    var onOpenAudioImporter: (() -> Void)? = nil

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var transcriptionService = AudioTranscriptionService()

    @State private var theme: String = ""
    @State private var isLoading: Bool = false
    @State private var generatedLyrics: String?
    @State private var errorMessage: String?
    @State private var loadingStep: String = ""

    private var hasAudio: Bool {
        guard let path = item.audioPath, !path.isEmpty else { return false }
        return FileManager.default.fileExists(atPath: path)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generate Lyrics from Flow")
                            .font(.title2.weight(.bold))
                        Text("Turn your recorded flow or mumble into lyrics that match the same rhythm.")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    if !hasAudio {
                        noAudioView
                    } else {
                        // Optional theme
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Theme (optional)")
                                .font(.subheadline.weight(.medium))
                            TextField("e.g. money, hustle, love", text: $theme)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                        }
                        .padding(.horizontal)

                        // Scenario A - From Clear Speech
                        scenarioCard(
                            title: "From Clear Speech",
                            explanation: "You recorded or transcribed real words. We use your transcript and BPM to match syllables and flow, then generate lyrics that fit.",
                            icon: "waveform",
                            action: { runScenarioA() }
                        )

                        // Scenario B - From Mumble
                        scenarioCard(
                            title: "From Mumble",
                            explanation: "You mumbled or freestyled without words. We detect rhythm from your audio and generate lyrics to fit that flow.",
                            icon: "waveform.badge.plus",
                            action: { runScenarioB() }
                        )

                        if isLoading {
                            loadingView
                        }

                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }

                        if let lyrics = generatedLyrics {
                            resultView(lyrics: lyrics)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            errorMessage = nil
            generatedLyrics = nil
        }
    }

    private var noAudioView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Record or import audio first", systemImage: "waveform.slash")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Momentum.contentSecondary)
            Text("Add audio to this entry, then open Generate Lyrics from Flow again.")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            HStack(spacing: 12) {
                if let openRecorder = onOpenRecorder {
                    Button {
                        onDismiss()
                        dismiss()
                        openRecorder()
                    } label: {
                        Label("Record Audio", systemImage: "waveform")
                    }
                    .buttonStyle(.borderedProminent)
                }
                if let openImport = onOpenAudioImporter {
                    Button {
                        onDismiss()
                        dismiss()
                        openImport()
                    } label: {
                        Label("Import Audio", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func scenarioCard(
        title: String,
        explanation: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
            }
            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
            Button(action: action) {
                Text(title == "From Clear Speech" ? "Generate from Speech" : "Generate from Mumble")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private var loadingView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.9)
            Text(loadingStep.isEmpty ? "Generating..." : loadingStep)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private func resultView(lyrics: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Generated Lyrics")
                .font(.headline)
            Text(lyrics)
                .font(.body)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            HStack(spacing: 12) {
                Button("Insert into Entry") {
                    onInsertLyrics(lyrics)
                    onDismiss()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                Button("Copy") {
                    UIPasteboard.general.string = lyrics
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .padding(.horizontal)
    }

    // MARK: - Actions (wired in Scenario A/B implementation)

    private func runScenarioA() {
        errorMessage = nil
        generatedLyrics = nil
        isLoading = true
        loadingStep = "Preparing..."
        Task {
            await runScenarioALogic()
        }
    }

    private func runScenarioB() {
        errorMessage = nil
        generatedLyrics = nil
        isLoading = true
        loadingStep = "Preparing..."
        Task {
            await runScenarioBLogic()
        }
    }

    @MainActor
    private func runScenarioALogic() async {
        defer { isLoading = false; loadingStep = "" }
        guard let audioPath = item.audioPath, !audioPath.isEmpty else {
            errorMessage = "No audio."
            return
        }
        let audioURL = URL(fileURLWithPath: audioPath)
        do {
            // Ensure transcription exists
            if item.transcriptionSegments == nil || item.transcriptionSegments?.isEmpty == true {
                loadingStep = "Transcribing speech..."
                let result = try await transcriptionService.transcribe(audioURL: audioURL)
                item.transcription = result.fullText
                item.transcriptionSegments = result.segments
                try? modelContext.save()
            }
            // Ensure BPM exists
            if item.bpm == nil || item.bpm == 0 {
                loadingStep = "Analyzing tempo..."
                let analysis = try await AudioAnalysisService.shared.analyzeAudio(url: audioURL)
                item.bpm = analysis.bpm
                item.key = analysis.key
                item.scale = analysis.scale
                try? modelContext.save()
            }
            loadingStep = "Generating lyrics..."
            let result = try await GenerateLyricsFromFlowService.runScenarioA(
                item: item,
                theme: theme.isEmpty ? nil : theme
            )
            generatedLyrics = result
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            generatedLyrics = nil
        }
    }

    @MainActor
    private func runScenarioBLogic() async {
        defer { isLoading = false; loadingStep = "" }
        guard let audioPath = item.audioPath, !audioPath.isEmpty else {
            errorMessage = "No audio."
            return
        }
        let audioURL = URL(fileURLWithPath: audioPath)
        do {
            if item.bpm == nil || item.bpm == 0 {
                loadingStep = "Analyzing tempo..."
                let analysis = try await AudioAnalysisService.shared.analyzeAudio(url: audioURL)
                item.bpm = analysis.bpm
                item.key = analysis.key
                item.scale = analysis.scale
                try? modelContext.save()
            }
            loadingStep = "Detecting rhythm from audio..."
            let result = try await GenerateLyricsFromFlowService.runScenarioB(
                item: item,
                theme: theme.isEmpty ? nil : theme
            )
            generatedLyrics = result
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            generatedLyrics = nil
        }
    }
}
