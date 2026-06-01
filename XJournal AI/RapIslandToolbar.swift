//
//  RapIslandToolbar.swift
//  XJournal AI
//
//  Screen-local floating "dynamic island" for the Rap Suggestions screen (spec §3.4).
//  Matches the editor's island look (capsule, blur, eye / magnifying-glass / stack),
//  but is self-contained and wired to this screen's three toggles. Standalone — the
//  assembly phase overlays it on RapSuggestionView.
//

import SwiftUI

struct RapIslandToolbar: View {
    @Binding var rhymeOn: Bool      // eye: rhyme highlighting
    @Binding var stackOn: Bool      // stack: syllable stress emphasis
    let rhymeGroups: [RhymeHighlighterEngine.RhymeGroup]
    let currentText: String

    @State private var showGroups = false

    var body: some View {
        HStack(spacing: 18) {
            toggleButton(
                icon: rhymeOn ? "eye.fill" : "eye",
                label: "Rhymes",
                isOn: rhymeOn,
                action: { rhymeOn.toggle() }
            )
            .accessibilityLabel(rhymeOn ? "Hide rhyme overlay" : "Show rhyme overlay")

            groupsButton

            toggleButton(
                icon: "text.aligncenter",
                label: "Stack",
                isOn: stackOn,
                action: { stackOn.toggle() }
            )
            .accessibilityLabel(stackOn ? "Hide syllable stacking" : "Stack syllables")
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 18)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.08)))
        .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
    }

    private func toggleButton(icon: String, label: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon).font(.headline)
                Text(label).font(.caption2)
            }
            .foregroundStyle(isOn ? Color.green : Color.primary)
            .frame(minWidth: 44)
        }
        .buttonStyle(.plain)
    }

    private var groupsButton: some View {
        Button { showGroups = true } label: {
            VStack(spacing: 2) {
                Image(systemName: "text.magnifyingglass").font(.headline)
                Text("Groups").font(.caption2)
            }
            .foregroundStyle(Color.primary)
            .frame(minWidth: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Rhyme groups")
        .popover(isPresented: $showGroups, arrowEdge: .bottom) {
            RhymeGroupListView(groups: rhymeGroups, currentText: currentText)
                .presentationCompactAdaptation(.popover)
        }
    }
}

#Preview {
    RapIslandToolbar(
        rhymeOn: .constant(true),
        stackOn: .constant(false),
        rhymeGroups: [],
        currentText: ""
    )
    .padding()
}
