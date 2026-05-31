//
//  RapTrackPlaybackView.swift
//  XJournal AI
//
//  Full-screen playback sheet for a generated rap track.
//  Handles:
//    - Downloading audio from remote URL (Suno beat or Uberduck vocal)
//    - AVAudioPlayer inline playback with scrubber
//    - Beat + vocal layer toggle (if both are generated)
//    - Share sheet export (saves to Files, AirDrop, etc.)
//    - Model Gv3 cross-test badge so you know which model produced the bars
//
//  USAGE:
//    .sheet(isPresented: $showPlayback) {
//        RapTrackPlaybackView(
//            beatResult: beatResult,          // optional SunoBeatResult
//            vocalResult: vocalResult,        // optional UberduckRapResult
//            lyrics: generatedLyrics,
//            modelLabel: "Model G v3"
//        )
//    }
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Download + Player State

enum PlaybackLoadState {
    case idle
    case downloading
    case ready
    case playing
    case paused
    case error(String)
}

@MainActor
final class RapTrackPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {

    @Published var loadState: PlaybackLoadState = .idle
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isPlaying: Bool = false

    private var player: AVAudioPlayer?
    private var displayLink: Timer?
    private var localURL: URL?

    // ── Load from remote URL ─────────────────────────────────────

    func load(from remoteURL: URL) async {
        loadState = .downloading
        do {
            let (localURL, _) = try await URLSession.shared.download(from: remoteURL)
            // Move to temp directory with stable name
            let dest = FileManager.default.temporaryDirectory
                .appendingPathComponent("rap_track_\(UUID().uuidString).mp3")
            try? FileManager.default.moveItem(at: localURL, to: dest)
            self.localURL = dest
            try setupPlayer(url: dest)
            loadState = .ready
        } catch {
            loadState = .error("Could not load audio: \(error.localizedDescription)")
        }
    }

    func load(from localURL: URL) {
        self.localURL = localURL
        do {
            try setupPlayer(url: localURL)
            loadState = .ready
        } catch {
            loadState = .error("Could not load audio: \(error.localizedDescription)")
        }
    }

    private func setupPlayer(url: URL) throws {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        player = try AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.prepareToPlay()
        duration = player?.duration ?? 0
    }

    // ── Playback Controls ────────────────────────────────────────

    func play() {
        player?.play()
        isPlaying = true
        loadState = .playing
        startTimer()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        loadState = .paused
        stopTimer()
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func seek(to time: Double) {
        player?.currentTime = time
        currentTime = time
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
        currentTime = 0
        isPlaying = false
        loadState = .ready
        stopTimer()
    }

    // ── Timer for scrubber ───────────────────────────────────────

    private func startTimer() {
        displayLink = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self, let p = self.player else { return }
            Task { @MainActor in
                self.currentTime = p.currentTime
            }
        }
    }

    private func stopTimer() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // ── AVAudioPlayerDelegate ────────────────────────────────────

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.loadState = .ready
            self.currentTime = 0
            self.stopTimer()
        }
    }

    // ── Export ───────────────────────────────────────────────────

    var exportURL: URL? { localURL }

    func cleanUp() {
        stop()
        if let url = localURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

// MARK: - Main View

struct RapTrackPlaybackView: View {

    // Pass in whichever results were generated (can be nil if not yet made)
    var beatResult: SunoBeatResult?
    var vocalResult: UberduckRapResult?
    var lyrics: String
    var modelLabel: String = "Model G"

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var beatPlayer  = RapTrackPlayer()
    @StateObject private var vocalPlayer = RapTrackPlayer()

    @State private var activeLayer: TrackLayer = .beat
    @State private var showShareSheet: Bool = false
    @State private var shareItems: [Any] = []
    @State private var hasLoaded: Bool = false

    enum TrackLayer: String, CaseIterable {
        case beat  = "Beat"
        case vocal = "Vocals"
        case both  = "Both"
    }

    // Active player based on selected layer
    private var activePlayer: RapTrackPlayer {
        activeLayer == .vocal ? vocalPlayer : beatPlayer
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {

                    // ── Header ───────────────────────────────────
                    headerSection

                    // ── Layer picker ─────────────────────────────
                    if beatResult != nil && vocalResult != nil {
                        layerPicker
                    }

                    // ── Player UI ────────────────────────────────
                    playerSection

                    // ── Lyrics ───────────────────────────────────
                    lyricsSection
                }
                .padding(.vertical, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    shareButton
                }
            }
        }
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true
            await loadAudio()
        }
        .onDisappear {
            beatPlayer.cleanUp()
            vocalPlayer.cleanUp()
        }
        .sheet(isPresented: $showShareSheet) {
            if !shareItems.isEmpty {
                ShareSheet(items: shareItems)
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text(beatResult?.title ?? "Generated Track")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                // Model badge
                Text(modelLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.15))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())

                if let style = beatResult?.style {
                    Text(style)
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal)
    }

    private var layerPicker: some View {
        Picker("Layer", selection: $activeLayer) {
            ForEach(TrackLayer.allCases, id: \.self) { layer in
                Text(layer.rawValue).tag(layer)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .onChange(of: activeLayer) { _, _ in
            beatPlayer.stop()
            vocalPlayer.stop()
        }
    }

    private var playerSection: some View {
        VStack(spacing: 20) {
            switch activePlayer.loadState {

            case .downloading:
                VStack(spacing: 10) {
                    ProgressView()
                    Text("Loading audio…")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .frame(height: 120)

            case .error(let msg):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 120)
                .padding(.horizontal)

            default:
                VStack(spacing: 16) {
                    // Scrubber
                    VStack(spacing: 4) {
                        Slider(
                            value: Binding(
                                get: { activePlayer.currentTime },
                                set: { activePlayer.seek(to: $0) }
                            ),
                            in: 0...max(activePlayer.duration, 1)
                        )
                        .tint(.blue)

                        HStack {
                            Text(formatTime(activePlayer.currentTime))
                            Spacer()
                            Text(formatTime(activePlayer.duration))
                        }
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(Momentum.contentSecondary)
                    }
                    .padding(.horizontal)

                    // Transport controls
                    HStack(spacing: 40) {
                        Button {
                            activePlayer.seek(to: max(0, activePlayer.currentTime - 10))
                        } label: {
                            Image(systemName: "gobackward.10")
                                .font(.title2)
                        }
                        .disabled(!isReady)

                        Button { activePlayer.togglePlayPause() } label: {
                            Image(systemName: activePlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(isReady ? .blue : .secondary)
                        }
                        .disabled(!isReady)

                        Button {
                            activePlayer.seek(to: min(activePlayer.duration, activePlayer.currentTime + 10))
                        } label: {
                            Image(systemName: "goforward.10")
                                .font(.title2)
                        }
                        .disabled(!isReady)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activePlayer.isPlaying)
    }

    private var lyricsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lyrics")
                .font(.headline)
                .padding(.horizontal)

            Text(lyrics)
                .font(.body)
                .lineSpacing(6)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
        }
    }

    private var shareButton: some View {
        Button {
            buildShareItems()
            showShareSheet = true
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(activePlayer.exportURL == nil)
    }

    // MARK: - Helpers

    private var isReady: Bool {
        switch activePlayer.loadState {
        case .ready, .playing, .paused: return true
        default: return false
        }
    }

    private func loadAudio() async {
        if let beat = beatResult {
            await beatPlayer.load(from: beat.audioURL)
        }
        if let vocal = vocalResult {
            await vocalPlayer.load(from: vocal.audioURL)
        }
    }

    private func buildShareItems() {
        var items: [Any] = []
        // Share the audio file
        if let url = activePlayer.exportURL {
            items.append(url)
        }
        // Also share lyrics as text
        items.append("Generated by Final AI Journal X (\(modelLabel))\n\n\(lyrics)")
        shareItems = items
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let total = Int(seconds)
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    RapTrackPlaybackView(
        beatResult: nil,
        vocalResult: nil,
        lyrics: "I been stackin' paper / waitin' for the vapor\nMy diamonds got a crater / born a money-maker\nPull up in the coupe with the curtains on\nSee me in the morning like the rise of dawn",
        modelLabel: "Model G v3"
    )
}
#endif
