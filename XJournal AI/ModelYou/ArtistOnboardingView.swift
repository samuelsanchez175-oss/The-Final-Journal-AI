import SwiftUI

/// Profile → You: artist onboarding for Model You. Marketing lives on the App tab.
struct ArtistOnboardingView: View {
    @ObservedObject private var store = ArtistBrainStore.shared
    @State private var spotifyURL: String = ""
    @State private var appleMusicURL: String = ""
    @State private var showAppleMusic = false
    @State private var noLongerWriteLike: String = ""
    @State private var talkingTo: ArtistTalkingTo = .sameAsSongs
    @State private var instagramHandle: String = ""
    @State private var leaveOut: String = ""
    @State private var songs: [ArtistSong] = []
    @State private var pendingCards: [ArtistBrainCard] = []
    @State private var editingCardID: String?
    @State private var editingBody: String = ""
    @State private var isResolving = false
    @State private var errorMessage: String?
    @State private var statusMessage: String?
    @State private var artistName: String = ""
    @ObservedObject private var mirBatch = CatalogMIRBatchService.shared
    @State private var pasteSongID: String = ""
    @State private var pasteLyrics: String = ""
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            intro
            catalogSection
            if store.brain.ingestProgress.isRunning || store.brain.ingestProgress.total > 0 {
                ingestProgressSection
            }
            if !songs.isEmpty { songsSection }
            if !store.brain.identitySketch.isEmpty { identitySection }
            if !songs.isEmpty || store.brain.hasCatalog { gapQuestions }
            if !pendingCards.isEmpty { reviewSection }
            if store.brain.hasConfirmedBrain { confirmedSection }
            if store.brain.hasCatalog || store.brain.hasConfirmedBrain { deleteSection }
            mirBatchSection
        }
        .onAppear {
            hydrate()
            store.resumeIngestIfNeeded()
        }
        .onChange(of: store.brain.pendingCards) { _, newValue in
            pendingCards = newValue
        }
        .onChange(of: store.brain.talkingTo) { _, newValue in
            talkingTo = newValue
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Paste a Spotify or Apple Music artist link. We load the songs, then read lyric snippets in the background. You can leave this tab while it works. Songs still missing lyrics stay listed so you can paste them. Nothing writes into Model You until you tap Keep. Stays on this iPhone.")
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var catalogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "Your catalog")
            TextField("https://open.spotify.com/artist/…", text: $spotifyURL)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .padding(12)
                .background(fieldBackground)
            if !showAppleMusic {
                Button("Not on Spotify") {
                    withAnimation(.easeOut(duration: 0.18)) { showAppleMusic = true }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Momentum.accent)
            }
            if showAppleMusic {
                Text("Apple Music artist link")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                TextField("https://music.apple.com/…/artist/…", text: $appleMusicURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(fieldBackground)
            }
            Button(action: resolveCatalog) {
                HStack {
                    if isResolving { ProgressView().tint(Momentum.onInverse) }
                    Text(isResolving ? "Looking up…" : "Load songs")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
            .disabled(isResolving)
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if !artistName.isEmpty {
                Text(artistName)
                    .font(.momentumBody)
                    .foregroundStyle(Momentum.contentPrimary)
            }
        }
    }

    private var ingestProgressSection: some View {
        let progress = store.brain.ingestProgress
        return VStack(alignment: .leading, spacing: 10) {
            MomentumSectionHeader(title: progress.isRunning ? "Reading your songs" : "Song reading")
            ProgressView(value: progress.fraction)
                .tint(Momentum.accent)
                .accessibilityLabel("Song reading progress")
                .accessibilityValue("\(progress.currentIndex) of \(max(progress.total, 1)) songs")
            Text(progress.returnWhenReadyCopy.isEmpty ? progress.message : progress.returnWhenReadyCopy)
                .font(.subheadline)
                .foregroundStyle(Momentum.contentPrimary)
                .fixedSize(horizontal: false, vertical: true)
            if progress.isRunning {
                Button("Stop reading") { store.cancelIngest() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Momentum.accent)
                    .accessibilityHint("Stops after the song in progress. Already saved bars stay on this iPhone.")
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var songsSection: some View {
        let missing = songs.filter { $0.included && store.brain.barCount(forSongId: $0.id) == 0 }.count
        return VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "Your songs")
            Text("Uncheck features. Lyrics missing means Genius did not have bars — paste yours if you have them. Reading keeps going if you leave this tab.")
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if missing > 0 {
                Text("\(missing) claimed song\(missing == 1 ? "" : "s") still missing lyrics.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Momentum.contentPrimary)
            }
            VStack(spacing: 0) {
                ForEach($songs) { $song in
                    songRow($song)
                    if song.id != songs.last?.id {
                        Divider().overlay(Momentum.hairline)
                    }
                }
            }
            .padding(12)
            .background(cardBackground)
            .onChange(of: songs) { _, newValue in
                var next = store.brain
                next.songs = newValue
                store.save(next)
            }
            if !store.isIngesting {
                Button("Read bars from claimed songs") {
                    store.save(draftBrain())
                    store.startBackgroundIngest()
                }
                .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
                .disabled(songs.filter(\.included).isEmpty)
                .accessibilityHint("Reads lyric snippets in the background. You can leave this tab.")
            }
            if let statusMessage, pendingCards.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
    }

    @ViewBuilder
    private func songRow(_ song: Binding<ArtistSong>) -> some View {
        let bars = store.brain.barCount(forSongId: song.wrappedValue.id)
        let missing = song.wrappedValue.included && bars == 0
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: song.included) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.wrappedValue.title)
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentPrimary)
                    if song.wrappedValue.isFeature || song.wrappedValue.primaryArtist != artistName {
                        Text(song.wrappedValue.isFeature ? "Looks like a feature" : song.wrappedValue.primaryArtist)
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    Text(missing ? "Lyrics missing — paste them if you have them." : "\(bars) bar\(bars == 1 ? "" : "s") saved.")
                        .font(.caption)
                        .foregroundStyle(missing ? Momentum.accent : Momentum.contentSecondary)
                    if let mir = mirBatch.mir(for: song.wrappedValue.id) {
                        Text(mirSummary(mir))
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                }
            }
            .tint(Momentum.accent)
            .padding(.vertical, 6)
            if song.wrappedValue.included {
                Button(pasteSongID == song.wrappedValue.id ? "Hide paste" : "Paste lyrics for this song") {
                    withAnimation(.easeOut(duration: 0.18)) {
                        if pasteSongID == song.wrappedValue.id {
                            pasteSongID = ""
                            pasteLyrics = ""
                        } else {
                            pasteSongID = song.wrappedValue.id
                            pasteLyrics = ""
                        }
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Momentum.accent)
                .accessibilityHint("Opens a box to paste this song’s lyrics, one bar per line")
            }
            if pasteSongID == song.wrappedValue.id, song.wrappedValue.included {
                TextField("Paste lyrics, one bar per line", text: $pasteLyrics, axis: .vertical)
                    .lineLimit(5...12)
                    .padding(12)
                    .background(fieldBackground)
                Button("Save pasted bars") { savePastedBars() }
                    .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
                    .disabled(pasteLyrics.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private var gapQuestions: some View {
        VStack(alignment: .leading, spacing: 16) {
            MomentumSectionHeader(title: "Gap questions")
            Text("The songs fill audience, city, vices, love, and how they write when the bars say it. These are the holes they can’t.")
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 8) {
                Text("Anything you don't write like anymore?")
                    .font(.subheadline.weight(.semibold))
                TextField("Old pockets, slang, topics you'd skip now", text: $noLongerWriteLike, axis: .vertical)
                    .lineLimit(2...4)
                    .padding(12)
                    .background(fieldBackground)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Who you talking to on the next one?")
                    .font(.subheadline.weight(.semibold))
                Picker("Talking to", selection: $talkingTo) {
                    ForEach(ArtistTalkingTo.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(fieldBackground)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Musician Instagram (optional)")
                    .font(.subheadline.weight(.semibold))
                TextField("@handle", text: $instagramHandle)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(fieldBackground)
            }
            Button("Build review cards") { buildCards() }
                .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
        }
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "Review cards")
            Text("Keep / edit / toss. Nothing inferred writes until Keep.")
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
            ForEach(pendingCards) { card in
                reviewCard(card)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Anything we should leave out?")
                    .font(.subheadline.weight(.semibold))
                TextField("Topics, people, pockets to skip", text: $leaveOut, axis: .vertical)
                    .lineLimit(2...4)
                    .padding(12)
                    .background(fieldBackground)
            }
            Button("Save kept cards") { commitKeeps() }
                .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
    }

    private func reviewCard(_ card: ArtistBrainCard) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(card.title)
                .font(.subheadline.weight(.semibold))
            if editingCardID == card.id {
                TextField("Edit", text: $editingBody, axis: .vertical)
                    .lineLimit(2...5)
                    .padding(8)
                    .background(fieldBackground)
            } else {
                Text(card.body)
                    .font(.momentumMetadata)
                    .foregroundStyle(Momentum.contentSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 8) {
                Button("Keep") { setCard(card.id, .kept) }
                    .font(.caption.weight(.semibold))
                Button("Edit") {
                    editingCardID = card.id
                    editingBody = card.body
                }
                .font(.caption.weight(.semibold))
                if editingCardID == card.id {
                    Button("Done") {
                        applyEdit(card.id)
                    }
                    .font(.caption.weight(.semibold))
                }
                Button("Toss") { setCard(card.id, .tossed) }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
                Spacer()
                Text(card.status == .pending ? "Pending" : card.status.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var identitySection: some View {
        let sketch = store.brain.identitySketch
        return VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "What the songs say")
            Text("Saved from claimed bars. Keep a card before Model You writes it.")
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
                .fixedSize(horizontal: false, vertical: true)
            identityRow("Audience", sketch.audienceLine)
            identityRow("City", sketch.cityTokens.joined(separator: ", "))
            identityRow("Vices", sketch.viceTokens.joined(separator: ", "))
            identityRow("Love / women", sketch.loveTokens.joined(separator: ", "))
            identityRow("Topics", sketch.topicTokens.joined(separator: ", "))
            identityRow("How they write", sketch.writerLine)
        }
    }

    @ViewBuilder
    private func identityRow(_ title: String, _ value: String) -> some View {
        Group {
            if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text(value)
                        .font(.momentumMetadata)
                        .foregroundStyle(Momentum.contentSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var confirmedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "On this device")
            let bars = store.brain.lyricBars.count
            Text("\(store.brain.confirmedCards.count) kept card\(store.brain.confirmedCards.count == 1 ? "" : "s") · \(bars) bar\(bars == 1 ? "" : "s"). Model You uses this brain; Model G still ignores it.")
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var deleteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            MomentumSectionHeader(title: "Leave")
            Text("Deletes songs, bars, and cards from this iPhone. Model G is unchanged.")
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Delete this artist brain") {
                showDeleteConfirm = true
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.red)
            .accessibilityHint("Removes the on-device artist brain. Model G is unchanged.")
        }
        .confirmationDialog(
            "Delete this artist brain?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete this artist brain", role: .destructive) {
                wipeBrain()
            }
            Button("Keep it", role: .cancel) {}
        } message: {
            Text("Removes songs, bars, and cards from this iPhone. This cannot be undone. Model G is unchanged.")
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
            .fill(Momentum.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
            )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
            .fill(Momentum.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
            )
    }

    private func hydrate() {
        let brain = store.brain
        spotifyURL = brain.spotifyURL
        appleMusicURL = brain.appleMusicURL
        showAppleMusic = !brain.appleMusicURL.isEmpty
        noLongerWriteLike = brain.noLongerWriteLike
        talkingTo = brain.talkingTo
        instagramHandle = brain.instagramHandle
        leaveOut = brain.leaveOut
        songs = brain.songs
        artistName = brain.artistName
        pendingCards = brain.pendingCards
        if pasteSongID.isEmpty, let first = brain.includedSongs.first {
            pasteSongID = first.id
        }
    }



    private var mirBatchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Catalog MIR")
                .font(.headline)
            Text("Runs every catalog song in the background. BPM / key / scale only from audio — lyrics-only stays blank on those. Style (trap, ballad, beat-driven, no-drums) still fills from lyrics at lower confidence. Writing stays open.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if mirBatch.isRunning {
                ProgressView(value: mirBatch.progressFraction)
                Text(mirBatch.progressMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Stop MIR") { mirBatch.cancel() }
            } else {
                Button("Analyze every catalog song") {
                    mirBatch.startFullCatalog(force: false)
                }
                .buttonStyle(.borderedProminent)
                Button("Re-run all") {
                    mirBatch.startFullCatalog(force: true)
                }
                .font(.footnote)
            }
            ForEach(store.brain.songs) { song in
                if let mir = mirBatch.mir(for: song.id) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title).font(.subheadline.weight(.semibold))
                        Text(mirSummary(mir))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func mirSummary(_ mir: CatalogMIRBatchService.SongMIR) -> String {
        var parts: [String] = []
        if let bpm = mir.bpm { parts.append("\(bpm) BPM") }
        if let key = mir.key { parts.append(key) }
        if let scale = mir.scale { parts.append(scale) }
        if parts.isEmpty && !mir.hadAudio { parts.append("lyrics only — no BPM/key") }
        if !mir.styleTags.isEmpty {
            let conf = mir.styleTagConfidence > 0 ? " (\(Int(mir.styleTagConfidence * 100))%)" : ""
            parts.append(mir.styleTags.joined(separator: " · ") + conf)
        }
        return parts.joined(separator: " · ")
    }

    private func resolveCatalog() {
        errorMessage = nil
        isResolving = true
        Task {
            do {
                let result = try await ArtistCatalogClient.resolve(
                    spotifyURL: spotifyURL,
                    appleMusicURL: appleMusicURL
                )
                await MainActor.run {
                    artistName = result.artistName
                    songs = result.songs
                    pasteSongID = result.songs.first(where: \.included)?.id ?? result.songs.first?.id ?? ""
                    isResolving = false
                    var next = draftBrain()
                    next.artistName = result.artistName
                    next.songs = result.songs
                    next.spotifyURL = result.spotifyURL
                    next.appleMusicURL = result.appleMusicURL
                    next.catalogResolvedAt = Date()
                    store.save(next)
                    statusMessage = result.songs.isEmpty
                        ? "Found \(result.artistName), but no songs yet. Try the other store or paste bars after you add a track."
                        : "Saved \(result.songs.count) song\(result.songs.count == 1 ? "" : "s") for \(result.artistName). Reading bars in the background — you can leave."
                    if !result.songs.filter(\.included).isEmpty {
                        store.startBackgroundIngest()
                    }
                }
            } catch {
                await MainActor.run {
                    isResolving = false
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
    }

    private func draftBrain() -> ArtistBrain {
        var next = store.brain
        next.artistName = artistName
        next.spotifyURL = spotifyURL
        next.appleMusicURL = appleMusicURL
        next.instagramHandle = instagramHandle.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "@"))
        next.songs = songs
        next.noLongerWriteLike = noLongerWriteLike
        next.talkingTo = talkingTo
        next.leaveOut = leaveOut
        next.homeStance = ArtistBrainStore.inferHomeStance(from: next)
        next.catalogResolvedAt = Date()
        return next
    }

    private func buildCards() {
        var next = draftBrain()
        next.pendingCards = ArtistBrainStore.inferPendingCards(from: next)
        pendingCards = next.pendingCards
        store.save(next)
        statusMessage = "Review cards ready. Keep writes. Toss discards."
    }

    private func setCard(_ id: String, _ status: ArtistBrainCardStatus) {
        pendingCards = pendingCards.map { card in
            var copy = card
            if copy.id == id { copy.status = status }
            return copy
        }
    }

    private func applyEdit(_ id: String) {
        pendingCards = pendingCards.map { card in
            var copy = card
            if copy.id == id {
                copy.body = editingBody
                copy.status = .edited
            }
            return copy
        }
        editingCardID = nil
    }

    private func commitKeeps() {
        var next = draftBrain()
        next.pendingCards = pendingCards
        let kept = pendingCards.filter { $0.status == .kept || $0.status == .edited }
        let tossed = pendingCards.filter { $0.status == .tossed }.map(\.id)
        var confirmed = next.confirmedCards
        for card in kept {
            if let idx = confirmed.firstIndex(where: { $0.id == card.id }) {
                confirmed[idx] = card
            } else {
                confirmed.append(card)
            }
        }
        next.confirmedCards = confirmed
        next.tossedCardIDs = Array(Set(next.tossedCardIDs + tossed))
        next.homeStance = ArtistBrainStore.inferHomeStance(from: next)
        store.save(next)
        statusMessage = kept.isEmpty
            ? "Nothing written. Keep at least one card."
            : "Saved \(kept.count) card\(kept.count == 1 ? "" : "s") on this device."
    }

    private func savePastedBars() {
        guard let song = songs.first(where: { $0.id == pasteSongID && $0.included }) else {
            errorMessage = "Pick a claimed song, then paste."
            return
        }
        let incoming = ArtistLyricIngest.chunks(fromPaste: pasteLyrics, song: song)
        var next = draftBrain()
        next.ingestedBars = ArtistLyricIngest.merge(
            next.ingestedBars,
            with: incoming,
            replacingSongId: song.id
        )
        let pictured = ArtistIdentityIngest.sketch(from: next)
        if next.talkingTo == .sameAsSongs, pictured.talkingTo != .sameAsSongs {
            next.talkingTo = pictured.talkingTo
            talkingTo = pictured.talkingTo
        }
        next.pendingCards = ArtistBrainStore.inferPendingCards(from: next)
        pendingCards = next.pendingCards
        store.save(next)
        statusMessage = incoming.isEmpty
            ? "That paste had no usable bars. One bar per line, not the song title."
            : "Saved \(incoming.count) pasted bar\(incoming.count == 1 ? "" : "s") for \(song.title)."
        pasteLyrics = ""
    }

    private func wipeBrain() {
        store.wipeArtistBrain()
        spotifyURL = ""
        appleMusicURL = ""
        showAppleMusic = false
        noLongerWriteLike = ""
        talkingTo = .sameAsSongs
        instagramHandle = ""
        leaveOut = ""
        songs = []
        pendingCards = []
        artistName = ""
        pasteSongID = ""
        pasteLyrics = ""
        errorMessage = nil
        statusMessage = "Artist brain deleted from this iPhone. Model G is unchanged."
    }
}
