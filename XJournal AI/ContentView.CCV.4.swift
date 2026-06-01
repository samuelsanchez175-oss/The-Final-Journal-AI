import Foundation
import AVFoundation
import Combine
import MediaPlayer

// MARK: - Audio Player Manager
// File: ContentView.CCV.4.swift
// Dependencies: None (standalone)
// Used by: ContentView.swift, audio-related views

class AudioPlayerManager: ObservableObject {
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var lastUpdateTime: Date = Date()
    private var currentPath: String?
    private let updateThrottleInterval: TimeInterval = 0.2
    private let appGroupID = "group.com.finaljournal.app"
    
    // Track info for lock screen display
    private var trackTitle: String?
    private var trackArtist: String?
    
    // Track observers for proper cleanup
    private var statusObserver: NSKeyValueObservation?
    private var failedToPlayObserver: NSObjectProtocol?
    private var didPlayToEndObserver: NSObjectProtocol?
    
    // Remote command handlers
    private var playCommandTarget: Any?
    private var pauseCommandTarget: Any?
    private var togglePlayPauseCommandTarget: Any?
    private var skipForwardCommandTarget: Any?
    private var skipBackwardCommandTarget: Any?
    private var changePlaybackPositionCommandTarget: Any?
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isLoading = false
    @Published var error: String?
    @Published var foundAlternativePath: String? // Path found in alternative location
    
    func loadAudio(from path: String, title: String? = nil, artist: String? = nil) {
        // Clean up previous player and observers
        cleanup()
        
        isLoading = true
        error = nil
        currentPath = path
        trackTitle = title
        trackArtist = artist
        
        // Extract filename if no title provided
        if trackTitle == nil {
            let filename = (path as NSString).lastPathComponent
            trackTitle = (filename as NSString).deletingPathExtension
        }
        
        // Check if file exists (fast check)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            foundAlternativePath = nil
            loadAudioFile(at: path)
            return
        }
        
        // File not found at original path - try alternative locations
        // This is async to avoid blocking playback
        Task {
            let alternativePath = await findAudioFileAsync(originalPath: path)
            await MainActor.run {
                guard let foundPath = alternativePath, fileManager.fileExists(atPath: foundPath) else {
                    self.error = "Audio file not found. The file may have been moved or deleted."
                    self.isLoading = false
                    self.foundAlternativePath = nil
                    return
                }
                // Use the found path and notify that we found it in an alternative location
                self.currentPath = foundPath
                self.foundAlternativePath = foundPath
                self.loadAudioFile(at: foundPath)
            }
        }
    }
    
    private func loadAudioFile(at path: String) {
        // Configure audio session to bypass silent mode
        configureAudioSession()
        
        let url = URL(fileURLWithPath: path)
        let newPlayerItem = AVPlayerItem(url: url)
        self.playerItem = newPlayerItem
        player = AVPlayer(playerItem: newPlayerItem)
        
        // Configure player for background playback
        player?.automaticallyWaitsToMinimizeStalling = false
        // Ensure player continues in background
        if #available(iOS 13.0, *) {
            player?.preventsDisplaySleepDuringVideoPlayback = false
        }
        
        // Observe player item status for error handling
        statusObserver = newPlayerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                self?.handlePlayerItemStatus(item.status)
            }
        }
        
        // Set up notification observers
        failedToPlayObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: newPlayerItem,
            queue: .main
        ) { [weak self] notification in
            if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                self?.handleError(error.localizedDescription)
            }
        }
        
        didPlayToEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayerItem,
            queue: .main
        ) { [weak self] _ in
            self?.handlePlaybackEnded()
        }
        
        // Set up time observer immediately for responsive playback
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: updateThrottleInterval, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            let now = Date()
            if now.timeIntervalSince(self.lastUpdateTime) >= self.updateThrottleInterval {
                self.currentTime = CMTimeGetSeconds(time)
                self.lastUpdateTime = now
                // Update lock screen info periodically
                self.updateNowPlayingInfo()
            }
        }
        
        // Load duration asynchronously (doesn't block playback)
        // If we already have duration from item.audioDuration, use it immediately
        guard let playerItem = playerItem else {
            isLoading = false
            return
        }
        
        if #available(iOS 16.0, *) {
            Task {
                do {
                    let durationValue = try await playerItem.asset.load(.duration)
                    await MainActor.run {
                        self.duration = CMTimeGetSeconds(durationValue)
                        self.isLoading = false
                        // Update lock screen info when duration is loaded
                        self.updateNowPlayingInfo()
                    }
                } catch {
                    await MainActor.run {
                        self.error = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        } else {
            // For iOS < 16, try to get duration synchronously if available
            if playerItem.asset.statusOfValue(forKey: "duration", error: nil) == .loaded {
                duration = CMTimeGetSeconds(playerItem.asset.duration)
                isLoading = false
            } else {
                // Duration not loaded yet, but player can still play
                // Will be updated when duration becomes available
                isLoading = false
            }
        }
    }
    
    // MARK: - File Location Helper
    
    /// Async version of findAudioFile to avoid blocking main thread
    private func findAudioFileAsync(originalPath: String) async -> String? {
        let appGroupID = self.appGroupID // Capture for use in detached task
        return await Task.detached(priority: .userInitiated) {
            let fileManager = FileManager.default
            let filename = (originalPath as NSString).lastPathComponent
            
            // Try App Group container (for files imported via Share Extension) - fast check
            if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
                let appGroupPath = containerURL.appendingPathComponent(filename).path
                if fileManager.fileExists(atPath: appGroupPath) {
                    return appGroupPath
                }
            }
            
            // Try document directory - fast check
            if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let documentsPath = documentsURL.appendingPathComponent(filename).path
                if fileManager.fileExists(atPath: documentsPath) {
                    return documentsPath
                }
            }
            
            // Last resort: recursive search (slow, but only if needed)
            if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                if let foundPath = Self.searchForFile(filename: filename, in: documentsURL) {
                    return foundPath
                }
            }
            
            return nil
        }.value
    }
    
    nonisolated private static func searchForFile(filename: String, in directory: URL) -> String? {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else {
            return nil
        }
        
        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == filename {
                return fileURL.path
            }
        }
        
        return nil
    }
    
    func play() {
        guard let player = player else {
            print("⚠️ AudioPlayerManager: Cannot play - player is nil")
            return
        }
        
        guard player.status != .failed else {
            handleError("Player is in failed state. Please reload the audio.")
            return
        }
        
        // Configure audio session to bypass silent mode and support background playback
        configureAudioSession()
        
        // Ensure audio session stays active for background playback
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            print("⚠️ AudioPlayerManager: Failed to activate audio session: \(error.localizedDescription)")
        }
        
        player.play()
        isPlaying = true
        
        // Set up lock screen controls
        setupRemoteCommandCenter()
        updateNowPlayingInfo()
        
        print("✅ AudioPlayerManager: Playback started (background enabled)")
    }
    
    // MARK: - Audio Session Configuration
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        // Use .playback category to allow audio even when silent mode is on
        // Try with Bluetooth options first; fall back to no options if -50 (paramErr) on some devices
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetoothHFP, .allowBluetoothA2DP])
            try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
            print("✅ AudioPlayerManager: Audio session configured for background playback")
        } catch {
            let nsErr = error as NSError
            print("⚠️ AudioPlayerManager: Failed to configure audio session: \(error.localizedDescription) (code: \(nsErr.code), domain: \(nsErr.domain))")
            if nsErr.code == -50 {
                print("📝 AudioPlayerManager: Retrying with playback category only (no Bluetooth options)")
            }
            do {
                try audioSession.setCategory(.playback, mode: .default)
                try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
                print("✅ AudioPlayerManager: Audio session configured (playback only, no Bluetooth options)")
            } catch let fallbackError {
                let fallbackNs = fallbackError as NSError
                print("❌ AudioPlayerManager: Fallback config also failed: \(fallbackError.localizedDescription) (code: \(fallbackNs.code))")
            }
        }
    }
    
    func pause() {
        guard let player = player else {
            print("⚠️ AudioPlayerManager: Cannot pause - player is nil")
            return
        }
        
        player.pause()
        isPlaying = false
        
        // Update lock screen info
        updateNowPlayingInfo()
        
        print("✅ AudioPlayerManager: Playback paused")
    }
    
    func seek(to time: TimeInterval) {
        guard let player = player, let playerItem = playerItem else {
            print("⚠️ AudioPlayerManager: Cannot seek - player or playerItem is nil")
            return
        }
        
        guard playerItem.status == .readyToPlay else {
            print("⚠️ AudioPlayerManager: Cannot seek - player item not ready")
            return
        }
        
        let clampedTime = max(0, min(time, duration > 0 ? duration : time))
        let cmTime = CMTime(seconds: clampedTime, preferredTimescale: 600)
        
        player.seek(to: cmTime) { [weak self] completed in
            if completed {
                DispatchQueue.main.async {
                    self?.currentTime = clampedTime
                    print("✅ AudioPlayerManager: Seeked to \(clampedTime)s")
                }
            } else {
                print("⚠️ AudioPlayerManager: Seek failed")
            }
        }
    }
    
    func skipForward(seconds: TimeInterval = 15) {
        seek(to: currentTime + seconds)
    }
    
    func skipBackward(seconds: TimeInterval = 15) {
        seek(to: currentTime - seconds)
    }
    
    func retry() {
        error = nil
        if let path = currentPath {
            loadAudio(from: path)
        }
    }
    
    // MARK: - Helper Methods
    
    private func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            isLoading = false
            error = nil
            print("✅ AudioPlayerManager: Player item ready to play")
        case .failed:
            if let error = playerItem?.error {
                handleError(error.localizedDescription)
            } else {
                handleError("Unknown player item error")
            }
        case .unknown:
            // Still loading
            break
        @unknown default:
            break
        }
    }
    
    private func handleError(_ errorMessage: String) {
        error = errorMessage
        isLoading = false
        isPlaying = false
        print("❌ AudioPlayerManager Error: \(errorMessage)")
    }
    
    private func handlePlaybackEnded() {
        isPlaying = false
        currentTime = 0
        print("✅ AudioPlayerManager: Playback ended")
    }
    
    private func cleanup() {
        // Remove time observer
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        // Remove status observer
        statusObserver?.invalidate()
        statusObserver = nil
        
        // Remove notification observers
        if let failedObserver = failedToPlayObserver {
            NotificationCenter.default.removeObserver(failedObserver)
            failedToPlayObserver = nil
        }
        
        if let endObserver = didPlayToEndObserver {
            NotificationCenter.default.removeObserver(endObserver)
            didPlayToEndObserver = nil
        }
        
        // Pause and reset player
        player?.pause()
        player = nil
        playerItem = nil
        isPlaying = false
        currentTime = 0
        currentPath = nil
        
        // Clean up remote command handlers
        removeRemoteCommandHandlers()
        
        // Clear now playing info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        print("✅ AudioPlayerManager: Cleaned up")
    }
    
    // MARK: - Lock Screen Controls (iOS 26 Notes Style)
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Remove existing handlers first
        removeRemoteCommandHandlers()
        
        // Play command
        playCommandTarget = commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.play()
            return .success
        }
        commandCenter.playCommand.isEnabled = true
        
        // Pause command
        pauseCommandTarget = commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.pause()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        
        // Toggle play/pause command
        togglePlayPauseCommandTarget = commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.isPlaying {
                self.pause()
            } else {
                self.play()
            }
            return .success
        }
        commandCenter.togglePlayPauseCommand.isEnabled = true
        
        // Skip forward 15 seconds
        skipForwardCommandTarget = commandCenter.skipForwardCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if let skipEvent = event as? MPSkipIntervalCommandEvent {
                self.skipForward(seconds: skipEvent.interval)
            } else {
                self.skipForward(seconds: 15)
            }
            return .success
        }
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.isEnabled = true
        
        // Skip backward 15 seconds
        skipBackwardCommandTarget = commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if let skipEvent = event as? MPSkipIntervalCommandEvent {
                self.skipBackward(seconds: skipEvent.interval)
            } else {
                self.skipBackward(seconds: 15)
            }
            return .success
        }
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.isEnabled = true
        
        // Change playback position (scrubbing)
        changePlaybackPositionCommandTarget = commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self, let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.seek(to: positionEvent.positionTime)
            return .success
        }
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        
        print("✅ AudioPlayerManager: Lock screen controls enabled")
    }
    
    private func removeRemoteCommandHandlers() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.removeTarget(playCommandTarget)
        commandCenter.pauseCommand.removeTarget(pauseCommandTarget)
        commandCenter.togglePlayPauseCommand.removeTarget(togglePlayPauseCommandTarget)
        commandCenter.skipForwardCommand.removeTarget(skipForwardCommandTarget)
        commandCenter.skipBackwardCommand.removeTarget(skipBackwardCommandTarget)
        commandCenter.changePlaybackPositionCommand.removeTarget(changePlaybackPositionCommandTarget)
        
        playCommandTarget = nil
        pauseCommandTarget = nil
        togglePlayPauseCommandTarget = nil
        skipForwardCommandTarget = nil
        skipBackwardCommandTarget = nil
        changePlaybackPositionCommandTarget = nil
    }
    
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        
        // Title
        if let title = trackTitle {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        
        // Artist (or app name if not provided)
        nowPlayingInfo[MPMediaItemPropertyArtist] = trackArtist ?? "The Final Journal AI"
        
        // Playback duration
        if duration > 0 {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        }
        
        // Current playback time
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        
        // Playback rate (0 = paused, 1 = playing)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Update the now playing info center
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    deinit {
        cleanup()
    }
}
