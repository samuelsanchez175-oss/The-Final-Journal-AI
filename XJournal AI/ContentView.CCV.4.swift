import Foundation
import AVFoundation
import Combine
import MediaPlayer

// MARK: - Audio Player Manager
// File: ContentView.CCV.4.swift
// Dependencies: None (standalone)
// Used by: ContentView.swift, audio-related views

class AudioPlayerManager: ObservableObject {
    /// One player for the note card and the transcript sheet so they stay on the same file.
    static let shared = AudioPlayerManager()

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
    /// Bumps when this note's file is asked to play, before the buffer starts.
    @Published private(set) var playGeneration: Int = 0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isLoading = false
    @Published var isReady = false
    @Published var error: String?
    @Published var foundAlternativePath: String? // Path found in alternative location

    private var playWhenReady = false
    private var pendingSeek: TimeInterval?

    func loadAudio(from path: String, title: String? = nil, artist: String? = nil, seedDuration: TimeInterval? = nil) {
        if isSameLoadedFile(path), player != nil, error == nil, isReady {
            if let seed = Self.finiteDuration(seedDuration), duration <= 0 {
                duration = seed
            }
            isLoading = false
            return
        }

        let queuedPlay = playWhenReady
        let queuedSeek = pendingSeek
        cleanup()
        playWhenReady = queuedPlay
        pendingSeek = queuedSeek

        isLoading = true
        isReady = false
        error = nil
        currentPath = path
        trackTitle = title
        trackArtist = artist
        if let seed = Self.finiteDuration(seedDuration) {
            duration = seed
        } else {
            duration = 0
        }

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
        PlaybackAudioSession.configureInBackground()

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
                        if let seconds = Self.finiteDuration(CMTimeGetSeconds(durationValue)) {
                            self.duration = seconds
                        }
                        self.isLoading = false
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
            if let seconds = Self.finiteDuration(CMTimeGetSeconds(playerItem.asset.duration)) {
                duration = seconds
            }
            isLoading = false
        }
    }

    private static func finiteDuration(_ value: TimeInterval?) -> TimeInterval? {
        guard let value, value.isFinite, value > 0 else { return nil }
        return value
    }
    
    // MARK: - File Location Helper
    
    /// Async version of findAudioFile to avoid blocking main thread
    private func findAudioFileAsync(originalPath: String) async -> String? {
        let appGroupID = self.appGroupID // Capture for use in detached task
        return await Task.detached(priority: .userInitiated) {
            let fileManager = FileManager.default
            let filename = (originalPath as NSString).lastPathComponent
            
            if fileManager.fileExists(atPath: originalPath) {
                return originalPath
            }

            // Try App Group container (for files imported via Share Extension) - fast check
            if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
                let appGroupPath = containerURL.appendingPathComponent(filename).path
                if fileManager.fileExists(atPath: appGroupPath) {
                    return appGroupPath
                }
            }
            
            if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let documentsPath = documentsURL.appendingPathComponent(filename).path
                if fileManager.fileExists(atPath: documentsPath) {
                    return documentsPath
                }
            }

            return nil
        }.value
    }
    
    /// Path currently loaded, so the note dock can tell this file from another note.
    var loadedFilePath: String? { currentPath }

    func noteAudioMatches(_ path: String) -> Bool {
        guard let loaded = currentPath, !loaded.isEmpty, !path.isEmpty else { return false }
        if loaded == path { return true }
        return (loaded as NSString).lastPathComponent == (path as NSString).lastPathComponent
    }

    func play() {
        playWhenReady = true
        playGeneration += 1

        guard player != nil else {
            if let path = currentPath {
                loadAudio(from: path, title: trackTitle, artist: trackArtist, seedDuration: duration)
            }
            return
        }

        guard player?.status != .failed else {
            playWhenReady = false
            handleError("Player is in failed state. Please reload the audio.")
            return
        }

        guard playerItem?.status == .readyToPlay else { return }

        playWhenReady = false
        Task {
            await PlaybackAudioSession.activate()
            await MainActor.run {
                guard let player = self.player, player.status != .failed else { return }
                player.play()
                self.isPlaying = true
                self.setupRemoteCommandCenter()
                self.updateNowPlayingInfo()
            }
        }
    }

    func pause() {
        playWhenReady = false
        player?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        if isPlaying || playWhenReady {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: TimeInterval) {
        let clampedTime = duration > 0 ? max(0, min(time, duration)) : max(0, time)
        currentTime = clampedTime
        pendingSeek = clampedTime

        guard let player, let playerItem, playerItem.status == .readyToPlay else { return }

        pendingSeek = nil
        let cmTime = CMTime(seconds: clampedTime, preferredTimescale: 600)
        player.seek(to: cmTime) { [weak self] completed in
            guard completed else { return }
            DispatchQueue.main.async {
                self?.currentTime = clampedTime
                self?.updateNowPlayingInfo()
            }
        }
    }

    func seekAndPlay(to time: TimeInterval) {
        seek(to: time)
        play()
    }

    private func isSameLoadedFile(_ path: String) -> Bool {
        guard let currentPath else { return false }
        if currentPath == path { return true }
        return (currentPath as NSString).standardizingPath == (path as NSString).standardizingPath
    }

    /// Unthrottled playhead, so the full-screen clock can show hundredths of a second.
    func playbackTime() -> TimeInterval {
        if let player {
            let seconds = CMTimeGetSeconds(player.currentTime())
            if seconds.isFinite, seconds >= 0 { return seconds }
        }
        return currentTime
    }
    
    func skipForward(seconds: TimeInterval = 15) {
        seek(to: playbackTime() + seconds)
    }
    
    func skipBackward(seconds: TimeInterval = 15) {
        seek(to: playbackTime() - seconds)
    }
    
    func retry() {
        let path = currentPath
        let title = trackTitle
        let artist = trackArtist
        let seed = duration
        error = nil
        cleanup()
        if let path {
            loadAudio(from: path, title: title, artist: artist, seedDuration: seed)
        }
    }
    
    // MARK: - Helper Methods
    
    private func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            isLoading = false
            isReady = true
            error = nil
            if duration <= 0, let item = playerItem,
               let seconds = Self.finiteDuration(CMTimeGetSeconds(item.duration)) {
                duration = seconds
            }
            if let pending = pendingSeek {
                pendingSeek = nil
                seek(to: pending)
            }
            if playWhenReady {
                play()
            }
        case .failed:
            isReady = false
            playWhenReady = false
            if let error = playerItem?.error {
                handleError(error.localizedDescription)
            } else {
                handleError("Unknown player item error")
            }
        case .unknown:
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
        isReady = false
        playWhenReady = false
        pendingSeek = nil
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
        nowPlayingInfo[MPMediaItemPropertyArtist] = trackArtist ?? Momentum.appName
        
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
