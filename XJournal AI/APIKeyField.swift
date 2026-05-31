//
//  APIKeyField.swift
//  XJournal AI
//
//  Self-contained API-key input that fixes the "no save button / did it save?" problem:
//  reveal toggle, explicit Save + persistent confirmation, optional free "Test" (provider
//  models endpoint — no token cost), and provider auto-detect from the key prefix.
//

import SwiftUI
import UIKit

struct APIKeyField: View {
    let label: String
    let placeholder: String
    var helperText: String? = nil
    var detectProvider: Bool = false        // OpenAI/Gemini auto-detect + Test + dynamic "Get key" link
    var fixedGetKeyURL: URL? = nil           // for non-AI keys (e.g. Genius)
    let load: () -> String
    let save: (String) -> Void

    @State private var draft = ""
    @State private var lastSaved = ""
    @State private var revealed = false
    @State private var phase: Phase = .idle

    private enum Phase: Equatable { case idle, saved, testing, valid, invalid }
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
    private var getKeyLabel: String { provider == .gemini ? "Get Gemini key" : "Get OpenAI key" }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.subheadline.weight(.semibold))

            HStack(spacing: 8) {
                Group {
                    if revealed { TextField(placeholder, text: $draft) }
                    else { SecureField(placeholder, text: $draft) }
                }
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.callout.monospaced())

                Button { revealed.toggle() } label: {
                    Image(systemName: revealed ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.18), lineWidth: 1)
                    )
            )
            .onChange(of: draft) { _, _ in if phase != .idle { phase = .idle } }

            HStack(spacing: 12) {
                if detectProvider && provider != .unknown {
                    Label("Detected: \(providerName)", systemImage: "checkmark.seal")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if detectProvider {
                    Button("Test") { Task { await runTest() } }
                        .font(.caption.weight(.semibold))
                        .disabled(draft.isEmpty || phase == .testing)
                }
                Button {
                    save(draft)
                    lastSaved = draft
                    phase = .saved
                } label: {
                    Text("Save").font(.caption.weight(.bold))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(draft == lastSaved)
            }

            statusLine

            if let helperText {
                Text(helperText).font(.caption).foregroundStyle(.secondary)
            }
            if let getKeyURL {
                Link(destination: getKeyURL) {
                    Label(getKeyLabel, systemImage: "link").font(.caption)
                }
                .padding(.top, 2)
            }
        }
        .onAppear { draft = load(); lastSaved = draft }
    }

    @ViewBuilder private var statusLine: some View {
        switch phase {
        case .idle: EmptyView()
        case .saved:
            Label("Saved ✓", systemImage: "checkmark.circle.fill")
                .font(.caption).foregroundStyle(.green)
        case .testing:
            Label("Testing…", systemImage: "hourglass").font(.caption).foregroundStyle(.secondary)
        case .valid:
            Label("Key is valid ✓", systemImage: "checkmark.seal.fill")
                .font(.caption).foregroundStyle(.green)
        case .invalid:
            Label("Couldn't validate this key — check it and try again", systemImage: "exclamationmark.triangle.fill")
                .font(.caption).foregroundStyle(.orange)
        }
    }

    private func runTest() async {
        save(draft); lastSaved = draft        // test exactly what's stored
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
