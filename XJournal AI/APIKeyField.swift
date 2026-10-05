//
//  APIKeyField.swift
//  XJournal AI
//
//  API-key input. The key value lives in a parent @Binding; the Profile page's single
//  top-right Save persists it to Keychain — this field no longer self-saves. Keeps a reveal
//  toggle, provider auto-detect, auto-validation as you paste, a free "Test" retry, and a
//  "Get key" link. Momentum-styled (flat surface + hairline).
//

import SwiftUI
import UIKit

struct APIKeyField: View {
    let label: String
    let placeholder: String
    var helperText: String? = nil
    var detectProvider: Bool = false        // OpenAI/Gemini auto-detect + Test + dynamic "Get key" link
    var fixedGetKeyURL: URL? = nil           // for non-AI keys (e.g. Genius)
    var kind: APIKeyKind? = nil
    @Binding var draft: String

    @State private var revealed = false
    @State private var phase: Phase = .idle

    private enum Phase: Equatable { case idle, testing, valid, invalid }

    private var resolvedKind: APIKeyKind? {
        if let kind { return kind }
        if detectProvider { return .openAIOrGemini }
        if fixedGetKeyURL?.host()?.contains("genius") == true { return .genius }
        return nil
    }

    private var provider: APIKeyProvider { APIKeyValidator.provider(for: draft) }

    private var getKeyURL: URL? {
        if let fixedGetKeyURL { return fixedGetKeyURL }
        switch provider {
        case .gemini: return URL(string: "https://aistudio.google.com/app/apikey")
        case .openAI, .unknown, .genius: return URL(string: "https://platform.openai.com/api-keys")
        }
    }

    private var getKeyLabel: String {
        if resolvedKind == .genius { return "Create a Genius API client" }
        if let host = fixedGetKeyURL?.host() {
            return host.contains("genius") ? "Create a Genius API client" : "Get key"
        }
        return provider == .gemini ? "Get a Gemini key" : "Get an OpenAI key"
    }

    private var getKeyLinks: [(label: String, url: URL)] {
        if resolvedKind == .genius {
            return [
                ("Genius API docs", GeniusReferenceClient.developersURL),
                ("Create a Genius API client", GeniusReferenceClient.newAPIClientURL)
            ]
        }
        if let getKeyURL {
            return [(getKeyLabel, getKeyURL)]
        }
        return []
    }

    private var fieldStroke: Color {
        switch phase {
        case .valid: return Color.green.opacity(0.55)
        case .invalid: return Color.orange.opacity(0.7)
        case .testing: return Momentum.accent.opacity(0.55)
        case .idle: return Momentum.hairline
        }
    }

    private var wrongFieldText: String? {
        guard let resolvedKind else { return nil }
        return APIKeyValidator.wrongFieldMessage(for: draft, kind: resolvedKind)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Momentum.contentPrimary)

            HStack(spacing: 8) {
                Group {
                    if revealed { TextField(placeholder, text: $draft) }
                    else { SecureField(placeholder, text: $draft) }
                }
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.callout.monospaced())
                .foregroundStyle(Momentum.contentPrimary)
                .onSubmit { Task { await runTest() } }

                Button { revealed.toggle() } label: {
                    Image(systemName: revealed ? "eye.slash" : "eye")
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(revealed ? "Hide key" : "Show key")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                            .strokeBorder(fieldStroke, lineWidth: phase == .idle ? Momentum.lineThin : 1.2)
                    )
            )
            .onChange(of: draft) { _, _ in
                if phase != .idle { phase = .idle }
            }
            .task(id: draft) {
                await autoValidateIfReady()
            }

            HStack(spacing: 12) {
                if detectProvider && provider != .unknown {
                    Label("Detected: \(provider.displayName)", systemImage: "checkmark.seal")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                } else if resolvedKind == .genius, APIKeyValidator.looksReady(draft, kind: .genius) {
                    Label("Looks like a Genius token", systemImage: "checkmark.seal")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                Spacer()
                if resolvedKind != nil {
                    Button("Test") { Task { await runTest() } }
                        .font(.caption.weight(.semibold))
                        .disabled(APIKeyValidator.trimmed(draft).isEmpty || phase == .testing)
                        .accessibilityHint("Checks that this key works")
                }
            }

            statusLine

            if let helperText {
                Text(helperText)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(Array(getKeyLinks.enumerated()), id: \.offset) { _, link in
                Link(destination: link.url) {
                    Label(link.label, systemImage: "link").font(.caption)
                }
                .padding(.top, 2)
            }
        }
    }

    @ViewBuilder private var statusLine: some View {
        if let wrongFieldText, phase != .valid {
            Label(wrongFieldText, systemImage: "arrow.up.left")
                .font(.caption)
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            switch phase {
            case .idle:
                EmptyView()
            case .testing:
                Label("Checking this key…", systemImage: "hourglass")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            case .valid:
                Label(validCopy, systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            case .invalid:
                Label("This key didn't work. Check it and tap Test.", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var validCopy: String {
        switch resolvedKind {
        case .genius:
            return "Genius key works"
        case .openAIOrGemini:
            if provider == .unknown { return "Key works" }
            return "\(provider.displayName) key works"
        case .none:
            return "Key works"
        }
    }

    private func autoValidateIfReady() async {
        guard let resolvedKind else { return }
        if APIKeyValidator.wrongFieldMessage(for: draft, kind: resolvedKind) != nil { return }
        guard APIKeyValidator.looksReady(draft, kind: resolvedKind) else { return }
        try? await Task.sleep(nanoseconds: 650_000_000)
        guard !Task.isCancelled else { return }
        await runTest()
    }

    private func runTest() async {
        guard let resolvedKind else { return }
        let key = APIKeyValidator.trimmed(draft)
        guard !key.isEmpty else { return }
        if APIKeyValidator.wrongFieldMessage(for: key, kind: resolvedKind) != nil {
            phase = .invalid
            return
        }
        phase = .testing
        let ok = await APIKeyValidator.validate(key, kind: resolvedKind)
        guard !Task.isCancelled else { return }
        phase = ok ? .valid : .invalid
    }
}
