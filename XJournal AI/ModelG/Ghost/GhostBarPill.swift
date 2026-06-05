import SwiftUI

struct GhostBarPill: View {
    let candidates: [String]
    let onAccept: (String) -> Void
    let onDismiss: () -> Void
    var body: some View {
        HStack(spacing: 8) {
            // Ghost mark on the left so it's clearly the Ghost's suggestions.
            Image("GhostIcon")
                .renderingMode(.template)
                .resizable().scaledToFit()
                .frame(width: 16, height: 16)
                .opacity(0.75)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(candidates.prefix(6), id: \.self) { w in
                        Button(w) { onAccept(w) }
                            .font(.subheadline.weight(.medium)).buttonStyle(.plain)
                            .padding(.horizontal, 9).padding(.vertical, 3)
                            .background(Capsule().fill(.white.opacity(0.12)))
                    }
                }
            }
            Button { onDismiss() } label: { Image(systemName: "xmark").font(.caption2).opacity(0.6) }.buttonStyle(.plain)
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(Capsule().fill(.ultraThinMaterial)).padding(.horizontal, 16)
    }
}
