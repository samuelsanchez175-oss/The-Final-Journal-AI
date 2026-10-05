import AVFoundation
import Combine
import Foundation

/// Plays the note's attached beat on a background-activated session. Never calls setActive on main.
/// The visual clock always uses heard tempo (no hat-fold) so 1–2–3–4 matches the file.
@MainActor
final class NoteBeatPreviewPlayer: ObservableObject {
    @Published private(set) var isPlaying = false
    @Published private(set) var beatInBar: Int = 1
    @Published private(set) var missingAudio = false

    private var player: AVAudioPlayer?
    private var tickTask: Task<Void, Never>?
    private var clock = BarClock.resolveHeard(userBPM: 92)
    private var lastBPM: Int?
    private var elapsed: TimeInterval = 0

    func prepare(bpm: Int?) {
        lastBPM = bpm
        clock = BarClock.resolveHeard(userBPM: bpm)
    }

    func toggle(path: String?, bpm: Int?) {
        if isPlaying {
            stop()
            return
        }
        play(path: path, bpm: bpm)
    }

    func play(path: String?, bpm: Int?) {
        stopAudio()
        lastBPM = bpm
        guard let path, !path.isEmpty, FileManager.default.fileExists(atPath: path) else {
            missingAudio = true
            prepare(bpm: bpm)
            return
        }
        missingAudio = false
        clock = BarClock.resolveHeard(userBPM: bpm)
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player?.numberOfLoops = -1
            player?.prepareToPlay()
        } catch {
            missingAudio = true
            prepare(bpm: bpm)
            return
        }
        Task {
            await PlaybackAudioSession.activate()
            await MainActor.run {
                self.player?.play()
                self.isPlaying = true
                self.elapsed = 0
                self.publishBeat()
                self.startTick()
            }
        }
    }

    func stop() {
        tickTask?.cancel()
        tickTask = nil
        player?.stop()
        player = nil
        isPlaying = false
        elapsed = 0
    }

    private func stopAudio() {
        stop()
    }

    private func startTick() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 120_000_000)
                await MainActor.run {
                    self?.handleTick()
                }
            }
        }
    }

    private func handleTick() {
        if let player {
            elapsed = player.currentTime
            if !player.isPlaying {
                stop()
                return
            }
        }
        publishBeat()
    }

    private func publishBeat() {
        let beat = clock.beatInBar(elapsed: elapsed)
        if beat != beatInBar {
            beatInBar = beat
        }
    }
}
