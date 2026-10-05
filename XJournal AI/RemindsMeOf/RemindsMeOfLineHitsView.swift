import SwiftUI

/// Songs Genius returned for one tapped line.
struct RemindsMeOfLineHitsView: View {
    let match: RemindsMeOfLineMatch
    private var geniusYellow: Color { Color(RhymeColorPalette.colors[0]) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(RemindsMeOfCopy.title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(match.line)
                .font(.callout)
                .foregroundStyle(geniusYellow)
                .fixedSize(horizontal: false, vertical: true)
            Text("Genius")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Momentum.contentSecondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(match.hits) { hit in
                        Button {
                            if let url = hit.url { UIApplication.shared.open(url) }
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(hit.displayLine)
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(geniusYellow)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(
                                    [hit.artist, hit.lyricLine == nil ? "" : hit.title]
                                        .map { $0.trimmingCharacters(in: .whitespaces) }
                                        .filter { !$0.isEmpty }
                                        .joined(separator: " · ")
                                )
                                    .font(.caption)
                                    .foregroundStyle(Momentum.contentSecondary)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 320)
        .frame(maxHeight: 420)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
    }
}
