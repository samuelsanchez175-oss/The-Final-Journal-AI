//
//  APIKeyField.swift
//  XJournal AI
//
//  API-key input. The key value lives in a parent @Binding; the Profile page's single
//  top-right Save persists it to Keychain — this field no longer self-saves. Keeps a reveal
//  toggle, provider auto-detect, a free "Test" (provider models endpoint — no token cost),
//  and a "Get key" link. Momentum-styled (flat surface + hairline).
//

import SwiftUI
import UIKit

struct APIKeyField: View {
    let label: String
    let placeholder: String
    var helperText: String? = nil
    var detectProvider: Bool = false        // OpenAI/Gemini auto-detect + Test + dynamic "Get key" link
    var fixedGetKeyURL: URL? = nil           // for non-AI keys (e.g. Genius)
    @Binding var draft: String

    @State private var revealed = false
    @State private var phase: Phase = .idle

    private enum Phase: Equatable { case idle, testing, valid, invalid }
    private enum Provider { case gemini, openAI, unknown }

    private var provider: Provider {
        if draft.hasPrefix("AIza") { return .gemini }
        if draft.hasPrefix("sk-") { return .openAI }
        return .unknown
    }
    private var providerName: String {
        switch provider {
        case .gemini: return "Gemini (Google AI)"
        case .openAI: return "OpenAI"
        case .unknown: return ""
        }
    }
    private var getKeyURL: URL? {
        if let fixedGetKeyURL { return fixedGetKeyURL }
        switch provider {
        case .gemini: return URL(string: "https://aistudio.google.com/app/apikey")
        case .openAI, .unknown: return URL(string: "https://platform.openai.com/api-keys")
        }
    }
    private var getKeyLabel: String {
        if let host = fixedGetKeyURL?.host() {            // non-AI field (e.g. Genius) — don't assume OpenAI
            return host.contains("genius") ? "Get Genius key" : "Get key"
        }
        return provider == .gemini ? "Get Gemini key" : "Get OpenAI key"
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

                Button { revealed.toggle() } label: {
                    Image(systemName: revealed ? "eye.slash" : "eye")
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                            .strokeBorder(Momentum.hairline, lineWidth: Momentum.lineThin)
                    )
            )
            .onChange(of: draft) { _, _ in if phase != .idle { phase = .idle } }

            HStack(spacing: 12) {
                if detectProvider && provider != .unknown {
                    Label("Detected: \(providerName)", systemImage: "checkmark.seal")
                        .font(.caption).foregroundStyle(Momentum.contentSecondary)
                }
                Spacer()
                if detectProvider {
                    Button("Test") { Task { await runTest() } }
                        .font(.caption.weight(.semibold))
                        .disabled(draft.isEmpty || phase == .testing)
                }
            }

            statusLine

            if let helperText {
                Text(helperText).font(.caption).foregroundStyle(Momentum.contentSecondary)
            }
            if let getKeyURL {
                Link(destination: getKeyURL) {
                    Label(getKeyLabel, systemImage: "link").font(.caption)
                }
                .padding(.top, 2)
            }
        }
    }

    @ViewBuilder private var statusLine: some View {
        switch phase {
        case .idle: EmptyView()
        case .testing:
            Label("Testing…", systemImage: "hourglass").font(.caption).foregroundStyle(Momentum.contentSecondary)
        case .valid:
            Label("Key is valid ✓", systemImage: "checkmark.seal.fill")
                .font(.caption).foregroundStyle(.green)
        case .invalid:
            Label("Couldn't validate this key — check it and try again", systemImage: "exclamationmark.triangle.fill")
                .font(.caption).foregroundStyle(.orange)
        }
    }

    private func runTest() async {
        phase = .testing
        let ok = await Self.validate(draft)
        phase = ok ? .valid : .invalid
    }

    /// Free validation: hit the provider's models endpoint (no token cost). HTTP 200 = the key works.
    static func validate(_ key: String) async -> Bool {
        guard !key.isEmpty else { return false }
        var req: URLRequest
        if key.hasPrefix("AIza") {
            guard let u = URL(string: "https://generativelanguage.googleapis.com/v1beta/models?key=\(key)") else { return false }
            req = URLRequest(url: u)
        } else {
            guard let u = URL(string: "https://api.openai.com/v1/models") else { return false }
            req = URLRequest(url: u)
            req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        req.timeoutInterval = 15
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            return (resp as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
