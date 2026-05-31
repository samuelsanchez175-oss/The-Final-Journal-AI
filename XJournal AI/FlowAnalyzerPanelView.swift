//
//  FlowAnalyzerPanelView.swift
//  XJournal AI
//
//  Flow DNA panel: Stress %, Punch, Rhyme Density, Grid Tightness + 16-slot bar strip.
//

import SwiftUI

struct FlowAnalyzerPanelView: View {
    let features: FlowDNAFeatures?
    let profile: CadenceProfile?
    let bars: [FlowBar]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let profile = profile {
                flowMeters(profile: profile)
            }
            if !bars.isEmpty {
                barStripView
            }
        }
        .padding()
    }

    private func flowMeters(profile: CadenceProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Flow")
                .font(.headline)
            HStack(spacing: 16) {
                meter(label: "Stress", value: profile.stressDensity)
                meter(label: "Punch", value: profile.energyShape)
                meter(label: "Rhyme Density", value: profile.internalRhyme)
                meter(label: "Grid", value: profile.gridTightness)
            }
        }
    }

    private func meter(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }

    private var barStripView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bar grid")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            ForEach(bars.prefix(4), id: \.barIndex) { bar in
                HStack(spacing: 2) {
                    ForEach(Array(bar.slots.enumerated()), id: \.offset) { _, slot in
                        Text(slot.syllable != nil ? (slot.stress == 1 ? "X" : ".") : ".")
                            .font(.system(.caption, design: .monospaced))
                            .frame(width: 14, alignment: .center)
                    }
                }
            }
        }
    }
}
