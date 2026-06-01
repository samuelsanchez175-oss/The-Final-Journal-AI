//
//  VerseLedgerTrendView.swift
//  XJournal AI
//
//  In-app trend of Model G verse scores — reads Documents/verse_ledger.jsonl (VerseLedgerLog),
//  so insight about generations accumulates and is viewable without leaving the app.
//

import SwiftUI

struct VerseLedgerTrendView: View {
    @State private var entries: [VerseLedgerEntry] = []

    private var recent: [VerseLedgerEntry] { Array(entries.suffix(40)) }
    private var meanNet: Double { entries.isEmpty ? 0 : entries.map(\.net).reduce(0, +) / Double(entries.count) }
    private var lastNet: Double { entries.last?.net ?? 0 }

    var body: some View {
        Group {
            if entries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle).foregroundStyle(Momentum.contentSecondary)
                    Text("No scores yet").font(.headline)
                    Text("Generate a verse with Model G and its score appears here.")
                        .font(.caption).foregroundStyle(Momentum.contentSecondary).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 24) {
                        stat("Latest", lastNet)
                        stat("Average", meanNet)
                        stat("Count", Double(entries.count), isCount: true)
                    }
                    sparkline
                    Text("Recent generations").font(.headline)
                    ForEach(recent.reversed()) { row($0) }
                }
                .padding()
            }
        }
        .onAppear { entries = VerseLedgerLog.shared.loadAll() }
    }

    private func stat(_ label: String, _ value: Double, isCount: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(Momentum.contentSecondary)
            Text(isCount ? "\(Int(value))" : String(format: "%.0f", value))
                .font(.title2.weight(.bold).monospacedDigit())
        }
    }

    private func color(for net: Double) -> Color {
        net >= 65 ? .green : (net >= 50 ? .yellow : .red)
    }

    private var sparkline: some View {
        let nets = recent.map(\.net)
        let maxN = max(nets.max() ?? 100, 1)
        return VStack(alignment: .leading, spacing: 4) {
            Text("NET over recent generations (green ≥ 65 goal)")
                .font(.caption).foregroundStyle(Momentum.contentSecondary)
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(nets.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(color(for: nets[i]).opacity(0.85))
                        .frame(height: max(2, CGFloat(nets[i] / maxN) * 80))
                }
            }
            .frame(height: 80)
        }
    }

    private func row(_ e: VerseLedgerEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(e.source).font(.subheadline.weight(.medium)).lineLimit(1)
                Text(String(format: "rhyme %.0f · inner %.0f · jargon %.0f · smart %.0f · −rep %.0f −exp %.0f",
                            e.endRhyme, e.innerRhyme, e.jargon, e.smart,
                            e.repetitionPenalty, e.overExplainPenalty))
                    .font(.caption2).foregroundStyle(Momentum.contentSecondary).lineLimit(1)
            }
            Spacer()
            Text(String(format: "%.0f", e.net))
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(color(for: e.net))
        }
        .padding(.vertical, 4)
    }
}
