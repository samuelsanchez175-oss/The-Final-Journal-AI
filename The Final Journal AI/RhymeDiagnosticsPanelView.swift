import SwiftUI

// =======================================================
// MARK: - PAGE 9: Rhyme Diagnostics Panel (UI)
// =======================================================

struct RhymeDiagnosticsPanelView: View {
    let word: String
    
    // Use a mock service for preview and development
    private let phonetics = CMUDICTStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(word)
                    .font(.title
                        .weight(.semibold))
                Spacer()
                Text("PHONETIC BREAKDOWN")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            let phonemes = phonetics.phonemesByWord[word.lowercased()] ?? []
            if phonemes.isEmpty {
                Text("No phonetic data found for this word.")
                    .foregroundStyle(.secondary)
            } else {
                Text("Rhyme Tail: \(rhymeTail(for: phonemes))")
                    .font(.callout)
                
                FlowLayout(spacing: 8) {
                    ForEach(phonemes, id: \.self) { p in
                        Text(p)
                            .padding(6)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
    
    private func rhymeTail(for phonemes: [String]) -> String {
        guard let idx = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
            return "N/A"
        }
        return Array(phonemes[idx...]).joined(separator: "-")
    }
}

// Simple FlowLayout for the phoneme capsules
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Simplified size calculation
        return CGSize(width: proposal.width ?? 0, height: 100)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.width {
                x = bounds.minX
                y += lineHeight + spacing
            }
            view.place(at: .init(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#Preview {
    RhymeDiagnosticsPanelView(word: "diagnostics")
}