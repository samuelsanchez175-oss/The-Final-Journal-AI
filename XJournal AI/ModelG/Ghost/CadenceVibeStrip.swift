import SwiftUI

/// Replaces `GhostBarPill` while Cadence Ghost is on — one platter, not two.
struct CadenceVibeStrip: View {
    let result: CadenceResult
    let borrow: Double
    let onAccept: (CadenceSuggestion) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Image("GhostIcon")
                    .renderingMode(.template)
                    .resizable().scaledToFit()
                    .frame(width: 16, height: 16)
                    .opacity(0.75)
                Text(CadenceGhostEngine.borrowCaption(borrow))
                    .font(.caption2.weight(.semibold))
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Button {
                    for suggestion in result.suggestions where suggestion.bucket == .signature {
                        SignatureMemory.recordSkipped(
                            personId: suggestion.personId,
                            aspectId: suggestion.aspectId
                        )
                    }
                    onDismiss()
                } label: {
                    Image(systemName: "xmark").font(.caption2).opacity(0.6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss cadence ghost")
            }
            .padding(.horizontal, 12)
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(result.suggestions) { suggestion in
                            Button {
                                if suggestion.bucket == .signature {
                                    SignatureMemory.recordKept(
                                        personId: suggestion.personId,
                                        aspectId: suggestion.aspectId
                                    )
                                }
                                onAccept(suggestion)
                            } label: {
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 4) {
                                        Text(suggestion.bucket.chipTitle)
                                            .font(.caption2.weight(.bold))
                                            .textCase(.uppercase)
                                            .tracking(0.4)
                                        if suggestion.isOriginal {
                                            Text("new")
                                                .font(.caption2.weight(.bold))
                                                .textCase(.uppercase)
                                                .tracking(0.4)
                                                .opacity(0.7)
                                        }
                                    }
                                    Text(suggestion.display)
                                        .font(.subheadline.weight(.medium))
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                    Text(caption(suggestion))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .frame(width: max(geo.size.width - 64, 180), alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.white.opacity(0.14)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 2)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .dockEdgeFade()
            }
            .frame(height: 108)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 12)
    }

    private func caption(_ suggestion: CadenceSuggestion) -> String {
        [suggestion.metaphor, suggestion.artist]
            .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}
