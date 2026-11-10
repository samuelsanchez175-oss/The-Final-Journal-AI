import SwiftUI

/// One vault bar filed under a figure of speech. The bar text is the vault line.
struct FigurativeBar: Decodable, Equatable, Sendable, Identifiable {
    let figure: String
    let bar: String
    let artist: String
    let song: String
    let keys: String
    let reason: String
    let confidence: String

    var id: String { bar }
}

/// Figure-of-speech bars bundled in FigurativeSpeech.json.
enum FigurativeSpeech {
    static let artists = [
        "Gunna", "Young Thug",
        "Lil Wayne", "Lil Uzi Vert", "Juice WRLD", "Quality Control",
        "YoungBoy Never Broke Again", "Lil Yachty", "Ty Dolla $ign", "Rick Ross", "Yeat", "Drake",
        "Trippie Redd", "Tory Lanez", "Chief Keef", "JAY-Z", "Meek Mill", "Destroy Lonely", "Future",
        "Yo Gotti", "Don Toliver", "J. Cole", "Justin Bieber",
        "Young Dolph", "Big Sean", "Playboi Carti", "Travis Scott", "Tyler, the Creator", "Fetty Wap",
        "Kodak Black", "Young Stoner Life", "Moneybagg Yo", "Lil Keed",
        "Chance the Rapper", "Money Man", "03 Greedo", "G Herbo", "Ken Carson", "Key Glock", "Migos",
        "Cash Cobain", "Vic Mensa", "NAV", "Earl Sweatshirt", "Frank Ocean", "Young Nudy", "PARTYNEXTDOOR",
        "Fivio Foreign", "EST Gee", "NoCap", "Lil Baby", "Blac Youngsta", "Roddy Ricch",
        "Latto", "Homixide Gang", "21 Savage", "SahBabii", "Cardi B", "Veeze", "YFN Lucci",
        "Sleepy Hallow", "Quavo", "Offset",
        "BIA", "Pop Smoke", "BossMan Dlow", "GloRilla", "diamond*", "DaBaby", "BSlime", "Fridayy",
        "BashfortheWorld", "Montana 700", "Fatt Smaxk", "Unfoonk", "Takeoff", "Sniper Gang",
        "Ballout", "Gucci Mane", "YUME", "Lil Unky",
    ]

    static let typeOrder = [
        "Antithesis",
        "Metaphor",
        "Simile",
        "Hyperbole",
        "Personification",
        "Metonymy",
        "Double meaning",
        "Irony",
        "Unsure",
    ]

    static let all: [FigurativeBar] = {
        guard let url = Bundle.main.url(forResource: "FigurativeSpeech", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rows = try? JSONDecoder().decode([FigurativeBar].self, from: data) else {
            return []
        }
        return rows
    }()

    static func bars(artist: String, figure: String?) -> [FigurativeBar] {
        all.filter { row in
            row.artist == artist && (figure == nil || row.figure == figure)
        }
    }

    static func count(artist: String, figure: String?) -> Int {
        bars(artist: artist, figure: figure).count
    }
}

/// Figure list kept for the same type order the FOS tab uses.
struct FigurativeSpeechIndex: View {
    let artist: String

    var body: some View {
        Section {
            ForEach(FigurativeSpeech.typeOrder, id: \.self) { figure in
                NavigationLink {
                    FigurativeSpeechBars(artist: artist, figure: figure)
                } label: {
                    indexRow(figure: figure, count: FigurativeSpeech.count(artist: artist, figure: figure))
                }
                .listRowBackground(Momentum.surfaceElevated)
            }
            NavigationLink {
                FigurativeSpeechBars(artist: artist, figure: nil)
            } label: {
                indexRow(figure: "All", count: FigurativeSpeech.count(artist: artist, figure: nil))
            }
            .listRowBackground(Momentum.surfaceElevated)
        } header: {
            Text("Figure of speech")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Momentum.contentPrimary)
                .textCase(nil)
        }
    }

    private func indexRow(figure: String, count: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(figure)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Momentum.contentPrimary)
                Text(artist)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Momentum.contentSecondary)
            }
            Spacer(minLength: 8)
            Text(count.formatted())
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Momentum.contentSecondary)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Figure of speech, \(figure), \(artist), \(count.formatted()) bars")
    }
}

/// One figure for one artist. The bar is the figurative. The title carries the artist name.
struct FigurativeSpeechBars: View {
    let artist: String
    let figure: String?

    private var rows: [FigurativeBar] {
        FigurativeSpeech.bars(artist: artist, figure: figure)
    }

    private var title: String {
        "\(figure ?? "All") - \(artist)"
    }

    var body: some View {
        List {
            Section {
                ForEach(rows) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.figure)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Momentum.contentSecondary)
                        Text(row.bar)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Momentum.contentPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(row.song)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(row.figure). \(row.bar). \(row.artist). \(row.song)")
                    .listRowBackground(Momentum.surfaceElevated)
                }
            } header: {
                Text("\(rows.count.formatted()) bars")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Momentum.contentSecondary)
                    .textCase(nil)
            }
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Momentum.surface)
    }
}
