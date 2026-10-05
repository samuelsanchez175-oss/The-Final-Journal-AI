import AVFoundation
import Foundation

/// Playback session that never activates on the main thread.
/// `setActive` on main is a known hang (AVAudioSession_iOS.mm).
enum PlaybackAudioSession {
    nonisolated static func configureInBackground() {
        Task.detached(priority: .utility) {
            await activate()
        }
    }

    nonisolated static func activate() async {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.allowBluetoothHFP, .allowBluetoothA2DP])
            try await setActiveOffMain(session, options: [.notifyOthersOnDeactivation])
        } catch {
            let nsErr = error as NSError
            print("⚠️ Audio session: \(error.localizedDescription) (code: \(nsErr.code))")
            do {
                try session.setCategory(.playback, mode: .default)
                try await setActiveOffMain(session, options: [.notifyOthersOnDeactivation])
            } catch {
                print("❌ Audio session fallback failed: \(error.localizedDescription)")
            }
        }
    }

    private static func setActiveOffMain(
        _ session: AVAudioSession,
        options: AVAudioSession.SetActiveOptions
    ) async throws {
        try await Task.detached(priority: .utility) {
            try session.setActive(true, options: options)
        }.value
    }
}
