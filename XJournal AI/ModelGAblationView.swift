//
//  ModelGAblationView.swift
//  XJournal AI
//
//  Model Lab — the axis-ablation harness. Runs ONE request through several axis combinations
//  (voice/exposure guard, punchline directive, corpus grounding, slim prompt) and scores each
//  with the v5 grader, so we tune Model G from real numbers instead of vibes. Each run also shows
//  best-by-NET (typicality selector) vs best-by-craft (the selector axis).
//
//  Dev tool. Surfaced from Model Preferences (DEBUG builds). It does not touch the production path.
//

import SwiftUI
import UIKit

// MARK: - Run configuration

struct AblationRunConfig: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let name: String
    let voiceGuard: Bool   // the "imply / never name the act" exposure directive
    let punchline: Bool    // explicit setup→turn punchline directive
    let grounding: Bool    // include reference bars (RAG proxy)
    let slim: Bool         // drop house-style flavor — the "clean Gemini brief"

    var summary: String {
        var on: [String] = [voiceGuard ? "guard" : "no-guard"]
        if punchline { on.append("punch") }
        on.append(grounding ? "grounded" : "no-RAG")
        if slim { on.append("slim") }
        return on.joined(separator: " · ")
    }

    /// The five prompt variants that isolate each axis (selector axis is shown per-run as NET vs craft).
    static let runs: [AblationRunConfig] = [
        .init(code: "A", name: "Baseline (today's v4)",        voiceGuard: true,  punchline: false, grounding: true,  slim: false),
        .init(code: "B", name: "Voice axis OFF",               voiceGuard: false, punchline: false, grounding: true,  slim: false),
        .init(code: "C", name: "Voice OFF + Punchline",        voiceGuard: false, punchline: true,  grounding: true,  slim: false),
        .init(code: "D", name: "Clean brief (Gemini-style)",   voiceGuard: false, punchline: true,  grounding: false, slim: true),
        .init(code: "F", name: "Guard + Punchline (fight test)", voiceGuard: true, punchline: true,  grounding: true,  slim: false),
    ]
}

// MARK: - Results

struct AblationCandidate: Identifiable {
    let id = UUID()
    let hook: String
    let bars: [String]
    let score: VerseLedgerV5
    var text: String { ([hook] + bars).filter { !$0.isEmpty }.joined(separator: "\n") }
}

struct AblationRunResult: Identifiable {
    let id = UUID()
    let config: AblationRunConfig
    let candidates: [AblationCandidate]

    var bestByNet: AblationCandidate? { candidates.max { $0.score.net < $1.score.net } }
    var bestByCraft: AblationCandidate? { candidates.max { $0.score.craft < $1.score.craft } }
}

// MARK: - View

struct ModelGAblationView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var topic = "missing a prom send-off"
    @State private var tone = "confident, flexing, a little cold"
    @State private var referenceText = ""
    @State private var barCount = 8
    @State private var candidatesPerRun = 2
    @State private var results: [AblationRunResult] = []
    @State private var isRunning = false
    @State private var progress = ""

    private var referenceBars: [String] {
        referenceText.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private var apiCallCount: Int { AblationRunConfig.runs.count * max(1, candidatesPerRun) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    inputsSection
                    if isRunning {
                        ProgressView(progress.isEmpty ? "Running…" : progress)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    }
                    if !results.isEmpty {
                        summarySection
                        ForEach(results) { runCard($0) }
                    }
                }
                .padding()
            }
            .navigationTitle("Model Lab · Axis A/B")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    if !results.isEmpty {
                        Button {
                            UIPasteboard.general.string = markdownReport()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: { Image(systemName: "doc.on.doc") }
                    }
                }
            }
        }
    }

    // MARK: Inputs

    private var inputsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Request").font(.headline)
            TextField("Topic / direction", text: $topic, axis: .vertical)
                .textFieldStyle(.roundedBorder).lineLimit(1...3)
            TextField("Tone", text: $tone)
                .textFieldStyle(.roundedBorder)

            Text("Reference bars (optional — one per line; used by the 'grounded' runs)")
                .font(.caption).foregroundStyle(.secondary)
            TextField("Paste a few real bars to ground on…", text: $referenceText, axis: .vertical)
                .textFieldStyle(.roundedBorder).lineLimit(2...6)

            Stepper("Bars per verse: \(barCount)", value: $barCount, in: 4...16, step: 4)
            Stepper("Drafts per run: \(candidatesPerRun)", value: $candidatesPerRun, in: 1...3)

            Button {
                run()
            } label: {
                Text(isRunning ? "Running…" : "Run A–F  (~\(apiCallCount) API calls)")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.18)))
            }
            .buttonStyle(.plain)
            .disabled(isRunning || topic.trimmingCharacters(in: .whitespaces).isEmpty)

            Text("Each run uses the app's configured model key. Best-by-NET = today's typicality selector; best-by-craft = the proposed selector. Tap the copy button to send me the numbers.")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }

    // MARK: Summary

    private var summarySection: some View {
        let topCraft = results.compactMap { $0.bestByCraft?.score.craft }.max() ?? 0
        return VStack(alignment: .leading, spacing: 6) {
            Text("Summary (best-by-NET per run)").font(.headline)
            ForEach(results) { r in
                if let b = r.bestByNet {
                    HStack(spacing: 8) {
                        Text(r.config.code).font(.caption.bold())
                            .frame(width: 18, alignment: .leading)
                        Text(r.config.name).font(.caption).lineLimit(1)
                        Spacer(minLength: 6)
                        miniScore("NET", b.score.net)
                        miniScore("craft", b.score.craft,
                                  highlight: (r.bestByCraft?.score.craft ?? 0) >= topCraft && topCraft > 0)
                        miniScore("rhyme", b.score.rhyme)
                    }
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
    }

    private func miniScore(_ label: String, _ value: Double, highlight: Bool = false) -> some View {
        Text("\(label) \(Int(value.rounded()))")
            .font(.caption2.monospacedDigit())
            .foregroundStyle(highlight ? Color.green : .secondary)
            .fontWeight(highlight ? .bold : .regular)
    }

    // MARK: Run card

    @ViewBuilder
    private func runCard(_ r: AblationRunResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(r.config.code) · \(r.config.name)").font(.subheadline.weight(.semibold))
                Spacer()
                Text(r.config.summary).font(.caption2).foregroundStyle(.secondary)
            }
            if let best = r.bestByNet {
                scorePills(best.score)
                Text(best.text)
                    .font(.callout)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.06)))
                if let craftPick = r.bestByCraft, craftPick.id != best.id {
                    Text("↳ a different draft scored higher on craft (\(Int(craftPick.score.craft.rounded()))) — the selector axis matters here.")
                        .font(.caption2).foregroundStyle(.green)
                }
            } else {
                Text("No usable draft (model returned empty or filtered).")
                    .font(.caption).foregroundStyle(.orange)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
    }

    private func scorePills(_ s: VerseLedgerV5) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                pill("NET", s.net, .blue)
                pill("typ", s.typicality, .purple)
                pill("craft", s.craft, .green)
                pill("rhyme", s.rhyme, .orange)
                pill("spec", s.specificity, .pink)
                pill("meter", s.meter, .teal)
                pill("thru", s.throughline, .indigo)
            }
        }
    }

    private func pill(_ label: String, _ value: Double, _ color: Color) -> some View {
        Text("\(label) \(Int(value.rounded()))")
            .font(.caption2.monospacedDigit())
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.18)))
            .foregroundStyle(color)
    }

    // MARK: Run

    private func run() {
        isRunning = true
        results = []
        let refs = referenceBars
        let count = max(1, candidatesPerRun)
        Task {
            var collected: [AblationRunResult] = []
            for cfg in AblationRunConfig.runs {
                await MainActor.run { progress = "Run \(cfg.code): \(cfg.name)…" }
                var cands: [AblationCandidate] = []
                for _ in 0..<count {
                    if let v = try? await ModelGLLMService.shared.generateAblationVerse(
                        topic: topic, tone: tone, referenceBars: refs, barCount: barCount,
                        voiceGuard: cfg.voiceGuard, punchline: cfg.punchline,
                        grounding: cfg.grounding, slim: cfg.slim
                    ), !v.bars.isEmpty {
                        let score = VerseLedgerV5Scorer.score(hook: v.hook, bars: v.bars)
                        cands.append(AblationCandidate(hook: v.hook, bars: v.bars, score: score))
                    }
                }
                collected.append(AblationRunResult(config: cfg, candidates: cands))
                await MainActor.run { results = collected }
            }
            await MainActor.run { isRunning = false; progress = "" }
        }
    }

    // MARK: Markdown export

    private func markdownReport() -> String {
        var out = "## Model Lab — axis ablation\n\n"
        out += "**Topic:** \(topic)  ·  **Tone:** \(tone)  ·  **Bars:** \(barCount)  ·  **Drafts/run:** \(candidatesPerRun)\n\n"
        out += "| Run | Config | NET | typ | craft | rhyme | spec | meter | thru |\n"
        out += "|---|---|---|---|---|---|---|---|---|\n"
        for r in results {
            if let b = r.bestByNet?.score {
                out += "| \(r.config.code) | \(r.config.summary) | \(i(b.net)) | \(i(b.typicality)) | \(i(b.craft)) | \(i(b.rhyme)) | \(i(b.specificity)) | \(i(b.meter)) | \(i(b.throughline)) |\n"
            } else {
                out += "| \(r.config.code) | \(r.config.summary) | — | — | — | — | — | — | — |\n"
            }
        }
        out += "\n### Winning verse per run (best-by-NET)\n"
        for r in results {
            out += "\n**\(r.config.code) — \(r.config.name)**\n"
            if let b = r.bestByNet {
                out += "```\n\(b.text)\n```\n"
            } else {
                out += "_(no usable draft)_\n"
            }
        }
        return out
    }

    private func i(_ v: Double) -> String { String(Int(v.rounded())) }
}
