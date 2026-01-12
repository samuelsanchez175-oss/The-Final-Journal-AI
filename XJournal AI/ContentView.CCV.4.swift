import Foundation
import AVFoundation
import Combine

// MARK: - Audio Player Manager
// File: ContentView.CCV.4.swift
// Dependencies: None (standalone)
// Used by: ContentView.swift, audio-related views

class AudioPlayerManager: ObservableObject {
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var lastUpdateTime: Date = Date()
    private var currentPath: String?
    private let updateThrottleInterval: TimeInterval = 0.2
    private let appGroupID = "group.com.finaljournal.app"
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isLoading = false
    @Published var error: String?
    @Published var foundAlternativePath: String? // Path found in alternative location
    
    func loadAudio(from path: String) {
        isLoading = true
        error = nil
        currentPath = path
        
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
        
        // Check if file exists
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            // Try to find file in alternative locations
            let alternativePath = findAudioFile(originalPath: path)
            guard let foundPath = alternativePath, fileManager.fileExists(atPath: foundPath) else {
                error = "Audio file not found. The file may have been moved or deleted."
                isLoading = false
                foundAlternativePath = nil
                return
            }
            // Use the found path and notify that we found it in an alternative location
            currentPath = foundPath
            foundAlternativePath = foundPath
            loadAudioFile(at: foundPath)
            return
        }
        
        foundAlternativePath = nil
        loadAudioFile(at: path)
    }
    
    private func loadAudioFile(at path: String) {
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] notification in
            if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                self?.error = error.localizedDescription
                self?.isLoading = false
            }
        }
        
        if #available(iOS 16.0, *) {
            Task {
                do {
                    let durationValue = try await playerItem.asset.load(.duration)
                    await MainActor.run {
                        self.duration = CMTimeGetSeconds(durationValue)
                        self.isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        self.error = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        } else {
            if playerItem.asset.statusOfValue(forKey: "duration", error: nil) == .loaded {
                duration = CMTimeGetSeconds(playerItem.asset.duration)
                isLoading = false
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
            self?.currentTime = 0
        }
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: updateThrottleInterval, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            let now = Date()
            if now.timeIntervalSince(self.lastUpdateTime) >= self.updateThrottleInterval {
                self.currentTime = CMTimeGetSeconds(time)
                self.lastUpdateTime = now
            }
        }
    }
    
    // MARK: - File Location Helper
    
    private func findAudioFile(originalPath: String) -> String? {
        let fileManager = FileManager.default
        let filename = (originalPath as NSString).lastPathComponent
        
        // Try App Group container (for files imported via Share Extension)
        if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let appGroupPath = containerURL.appendingPathComponent(filename).path
            if fileManager.fileExists(atPath: appGroupPath) {
                return appGroupPath
            }
        }
        
        // Try document directory
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let documentsPath = documentsURL.appendingPathComponent(filename).path
            if fileManager.fileExists(atPath: documentsPath) {
                return documentsPath
            }
        }
        
        // Try searching in document directory recursively
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            if let foundPath = searchForFile(filename: filename, in: documentsURL) {
                return foundPath
            }
        }
        
        return nil
    }
    
    private func searchForFile(filename: String, in directory: URL) -> String? {
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
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
        currentTime = time
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
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
}
