import SwiftUI

struct GhostBarPill: View {
    let candidates: [String]
    var punches: [GhostPunchChip] = []
    var targetWrap: Int? = nil
    /// Trailing token in the editor — chips that start with this warm up as you type.
    var typingPrefix: String? = nil
    /// Dock word that just landed in the verse — pulses and shows the lock toast.
    var landedWord: String? = nil
    let onAccept: (String) -> Void
    let onDismiss: () -> Void
    /// Cadence split when the last bar has a real breath (`7 + 6`). Nil hides it.
    var pocketCaption: String? = nil
    /// Catalog / cadence search in flight.
    var isSearching: Bool = false

    /// Stable unique ids — `ForEach(..., id: \.self)` traps on duplicate catalog landings.
    private var chips: [(id: String, word: String)] {
        var seen = Set<String>()
        var out: [(id: String, word: String)] = []
        for (i, raw) in candidates.prefix(64).enumerated() {
            let word = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !word.isEmpty, seen.insert(word.lowercased()).inserted else { continue }
            out.append(("\(i)-\(word)", word))
        }
        return out
    }

    private var phraseMode: Bool { !punches.isEmpty || chips.contains(where: { $0.word.contains(" ") }) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            dockHeader
            if let landed = landedWord, !landed.isEmpty {
                lockedToast(landed)
                    .padding(.horizontal, 12)
            }
            if isSearching {
                searchingBar
                    .padding(.horizontal, 12)
            }
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    dockStrip(viewport: geo.size.width)
                }
                .scrollTargetBehavior(.viewAligned)
                .dockEdgeFade()
            }
            .frame(height: dockScrollHeight)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 12)
        .animation(.spring(response: 0.34, dampingFraction: 0.68), value: landedWord)
        .animation(.easeOut(duration: 0.16), value: typingPrefix)
    }

    /// Ghost mark and close sit on the title line so the lyric row can use the full dock width.
    private var dockHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("GhostIcon")
                .renderingMode(.template)
                .resizable().scaledToFit()
                .frame(width: 16, height: 16)
                .opacity(0.75)
            if let pocketCaption, !pocketCaption.isEmpty {
                Text(pocketCaption)
                    .font(.caption2.weight(.semibold))
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .accessibilityLabel("Cadence pockets \(pocketCaption)")
            }
            Spacer(minLength: 4)
            Button { onDismiss() } label: {
                Image(systemName: "xmark").font(.caption2).opacity(0.6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss ghost")
        }
        .padding(.horizontal, 12)
    }

    @ViewBuilder
    private func dockStrip(viewport: CGFloat) -> some View {
        let items = chips
        if !punches.isEmpty {
            let card = max(viewport - 64, 180)
            let columns = visiblePunches
            HStack(alignment: .top, spacing: 10) {
                ForEach(Array(stride(from: 0, to: columns.count, by: 2)), id: \.self) { i in
                    VStack(alignment: .leading, spacing: 6) {
                        punchChip(columns[i])
                        if i + 1 < columns.count {
                            punchChip(columns[i + 1])
                        }
                    }
                    .frame(width: card, alignment: .leading)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 28)
            .padding(.vertical, 2)
        } else if phraseMode {
            HStack(alignment: .center, spacing: 6) {
                ForEach(items, id: \.id) { item in
                    chip(item, phrase: true)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 28)
            .padding(.vertical, 2)
        } else if items.isEmpty, isSearching {
            Text("Looking for punches…")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
        } else {
            HStack(alignment: .top, spacing: 6) {
                ForEach(Array(stride(from: 0, to: items.count, by: 2)), id: \.self) { i in
                    VStack(spacing: 6) {
                        chip(items[i])
                        if i + 1 < items.count {
                            chip(items[i + 1])
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 28)
            .padding(.vertical, 2)
        }
    }

    private func lockedToast(_ landed: String) -> some View {
        Text("\(landed) · locked")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.primary.opacity(0.12)))
            .transition(.asymmetric(
                insertion: .scale(scale: 0.86).combined(with: .opacity),
                removal: .opacity
            ))
            .accessibilityLabel("\(landed) locked with the rhyme pocket")
    }

    private var searchingBar: some View {
        ProgressView()
            .progressViewStyle(.linear)
            .tint(Color.primary.opacity(0.45))
            .accessibilityLabel("Searching cadence punches")
    }

    private var dockScrollHeight: CGFloat {
        if !punches.isEmpty { return 176 }
        return phraseMode ? 58 : 64
    }

    private var visiblePunches: [GhostPunchChip] {
        let tight = punches.filter { $0.wrapFit != .miss }
        return tight.isEmpty ? punches : tight
    }

    private func punchChip(_ item: GhostPunchChip) -> some View {
        let landed = isSame(item.text, landedWord) || item.preferred
        return Button {
            onAccept(item.text)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.text)
                    .font(.subheadline.weight(landed ? .semibold : .medium))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 6) {
                    if let badge = wrapBadge(item) {
                        Text(badge.label)
                            .font(.caption2.monospacedDigit().weight(.semibold))
                            .foregroundStyle(badge.color)
                    }
                    if item.chained {
                        Text("chain")
                            .font(.caption2.weight(.semibold))
                            .textCase(.uppercase)
                            .tracking(0.4)
                            .foregroundStyle(Color.purple.opacity(0.9))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(
                    landed ? Color.primary.opacity(0.28)
                    : Color.white.opacity(0.14)
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(
                    landed ? Color.primary.opacity(0.45) : Color.clear,
                    lineWidth: 1.4
                )
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .scaleEffect(landed ? 1.04 : 1)
        .contextMenu {
            if let src = item.sourceLabel {
                Text(src)
            }
            Button("Use line") { onAccept(item.text) }
        }
        .accessibilityLabel(accessibilityLabel(item))
        .accessibilityAddTraits(landed ? .isSelected : [])
    }

    private func wrapBadge(_ item: GhostPunchChip) -> (label: String, color: Color)? {
        switch item.wrapFit {
        case .exact: return ("\(item.syllables)", Color.green.opacity(0.95))
        case .near: return ("\(item.syllables)", Color.orange.opacity(0.95))
        case .miss: return nil
        }
    }

    private func accessibilityLabel(_ item: GhostPunchChip) -> String {
        var parts = [item.text]
        if item.wrapFit != .miss { parts.append("\(item.syllables) syllables") }
        if let src = item.sourceLabel { parts.append(src) }
        return parts.joined(separator: ", ")
    }

    private func chip(_ item: (id: String, word: String), phrase: Bool = false) -> some View {
        let landed = isSame(item.word, landedWord)
        let warming = !landed && isPrefixMatch(item.word, typingPrefix)
        return Button(item.word) { onAccept(item.word) }
            .font((phrase ? Font.caption : Font.subheadline).weight(landed ? .semibold : .medium))
            .lineLimit(phrase ? 2 : 1)
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(
                    landed ? Color.primary.opacity(0.28)
                    : warming ? Color.primary.opacity(0.18)
                    : Color.white.opacity(0.14)
                )
            )
            .overlay(
                Capsule().strokeBorder(
                    landed ? Color.primary.opacity(0.45) : Color.clear,
                    lineWidth: 1.4
                )
            )
            .scaleEffect(landed ? 1.12 : warming ? 1.05 : 1)
            .id(item.id)
            .accessibilityAddTraits(landed ? .isSelected : [])
    }

    private func isSame(_ word: String, _ other: String?) -> Bool {
        guard let other, !other.isEmpty else { return false }
        return word.caseInsensitiveCompare(other) == .orderedSame
    }

    private func isPrefixMatch(_ word: String, _ prefix: String?) -> Bool {
        guard let prefix, prefix.count >= 2 else { return false }
        return word.lowercased().hasPrefix(prefix.lowercased())
    }
}

/// Soft blur on both ends of a sideways dock so a lyric can run to the edge while you swipe.
struct DockEdgeFade: ViewModifier {
    var edge: CGFloat = 28

    func body(content: Content) -> some View {
        content
            .mask(
                HStack(spacing: 0) {
                    LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                        .frame(width: edge)
                    Color.black
                    LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: edge)
                }
            )
            .overlay {
                HStack(spacing: 0) {
                    edgeBlur
                    Spacer(minLength: 0)
                    edgeBlur.scaleEffect(x: -1)
                }
                .allowsHitTesting(false)
            }
    }

    private var edgeBlur: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .frame(width: edge)
            .mask(
                LinearGradient(
                    colors: [.black, .black.opacity(0.4), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

extension View {
    func dockEdgeFade(edge: CGFloat = 28) -> some View {
        modifier(DockEdgeFade(edge: edge))
    }
}
