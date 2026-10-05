//
//  BeatAndVocalSheet.swift
//  The Final Journal AI
//
//  Paperclip home for Suno beats and Uberduck vocals.
//  Keys live in Profile → AI. Generation is optional — empty keys just send you there.
//

import SwiftUI

struct BeatAndVocalSheet: View {
    let lyrics: String
    let noteTitle: String

    @Environment(\.dismiss) private var dismiss
    @State private var isWorking = false
    @State private var statusMessage = ""
    @State private var errorMessage: String?
    @State private var beatResult: SunoBeatResult?
    @State private var vocalResult: UberduckRapResult?
    @State private var showPlayback = false

    private var trimmedLyrics: String {
        lyrics.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasLyrics: Bool { !trimmedLyrics.isEmpty }

    private var hasSunoKey: Bool {
        let key = KeychainHelper.shared.getSunoAPIKey() ?? ""
        return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasUberduckKeys: Bool {
        let key = KeychainHelper.shared.getUberduckAPIKey() ?? ""
        let secret = KeychainHelper.shared.getUberduckAPISecret() ?? ""
        return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !secret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Turn this note into a beat or a rap vocal. Keys stay on this device under Profile → AI.")
                        .font(.callout)
                        .foregroundStyle(Momentum.contentSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if !hasSunoKey && !hasUberduckKeys {
                        missingKeysCard
                    }

                    if !hasLyrics {
                        Text("Write some lyrics on the note first, then come back.")
                            .font(.callout)
                            .foregroundStyle(Momentum.contentSecondary)
                    }

                    actionCard(
                        title: "Make a beat",
                        subtitle: hasSunoKey
                            ? "Sends this note’s lyrics to Suno and plays the result. Can take up to a minute."
                            : "Add a Suno key in Profile → AI first.",
                        symbol: "metronome.fill",
                        enabled: hasSunoKey && hasLyrics && !isWorking,
                        action: { Task { await makeBeat() } }
                    )

                    actionCard(
                        title: "Make a rap vocal",
                        subtitle: hasUberduckKeys
                            ? "Sends this note’s lyrics to Uberduck and plays the sung result."
                            : "Add Uberduck key and secret in Profile → AI first.",
                        symbol: "mic.fill",
                        enabled: hasUberduckKeys && hasLyrics && !isWorking,
                        action: { Task { await makeVocal() } }
                    )

                    if isWorking {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text(statusMessage)
                                .font(.callout)
                                .foregroundStyle(Momentum.contentSecondary)
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(24)
            }
            .background(AtmosphereGlow())
            .navigationTitle("Beat & vocal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPlayback) {
                RapTrackPlaybackView(
                    beatResult: beatResult,
                    vocalResult: vocalResult,
                    lyrics: trimmedLyrics,
                    modelLabel: "Model G"
                )
            }
        }
    }

    private var missingKeysCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("No music keys yet")
                .font(.headline)
            Text("Add a Suno key for beats, or Uberduck key + secret for vocals, then open this again.")
                .font(.callout)
                .foregroundStyle(Momentum.contentSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                dismiss()
                AppNavigation.navigate(to: .profileAI)
            } label: {
                Text("Open Profile → AI")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
            .accessibilityHint("Closes this sheet and opens Profile on the AI tab so you can paste keys.")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
        )
    }

    private func actionCard(
        title: String,
        subtitle: String,
        symbol: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Momentum.accent.opacity(0.12))
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Momentum.accent)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Momentum.contentPrimary)
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Momentum.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.55)
        .accessibilityHint(subtitle)
    }

    @MainActor
    private func makeBeat() async {
        errorMessage = nil
        isWorking = true
        statusMessage = "Suno is writing a beat. This can take up to a minute."
        do {
            let result = try await SunoService.shared.generateBeat(
                lyrics: trimmedLyrics,
                title: noteTitle.isEmpty ? "Penwork track" : noteTitle
            )
            beatResult = result
            showPlayback = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
        statusMessage = ""
    }

    @MainActor
    private func makeVocal() async {
        errorMessage = nil
        isWorking = true
        statusMessage = "Uberduck is singing the bars. Hang on."
        do {
            let result = try await UberduckService.shared.synthesizeRap(lyrics: trimmedLyrics)
            vocalResult = result
            showPlayback = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
        statusMessage = ""
    }
}
