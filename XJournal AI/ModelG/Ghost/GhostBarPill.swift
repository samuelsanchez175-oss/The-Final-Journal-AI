import SwiftUI

struct GhostBarPill: View {
    let candidates: [String]
    let onAccept: (String) -> Void
    let onDismiss: () -> Void
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wand.and.stars").font(.footnote).opacity(0.7)
            ForEach(candidates.prefix(3), id: \.self) { w in
                Button(w) { onAccept(w) }
                    .font(.subheadline.weight(.medium)).buttonStyle(.plain)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(.white.opacity(0.12)))
            }
            Spacer(minLength: 0)
            Button { onDismiss() } label: { Image(systemName: "xmark").font(.caption2).opacity(0.6) }.buttonStyle(.plain)
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(Capsule().fill(.ultraThinMaterial)).padding(.horizontal, 16)
    }
}
