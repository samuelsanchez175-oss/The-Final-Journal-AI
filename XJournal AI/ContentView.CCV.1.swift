import Foundation
import Combine

// MARK: - CMUDICT Dictionary Store
// File: ContentView.CCV.1.swift
// Dependencies: None (foundational)
// Used by: CCV.3 (RhymeHighlighterEngine)

final class FJCMUDICTStore {
    static let shared = FJCMUDICTStore()
    private(set) var phonemesByWord: [String: [String]] = [:]
    private let loadingQueue = DispatchQueue(label: "com.finaljournal.cmudict.loading", qos: .userInitiated)
    private var isLoading = false
    private var isLoaded = false
    private let loadingLock = NSLock()
    
    // Thread-safe loading state check
    private var isDictionaryLoaded: Bool {
        loadingLock.lock()
        defer { loadingLock.unlock() }
        return isLoaded
    }
    
    private init() {
        // Load fallback dictionary immediately for basic functionality
        loadFallbackDictionary()
        // Start async loading of full dictionary
        preloadAsync()
    }
    
    /// Pre-loads the full dictionary asynchronously on a background thread
    /// This is called on app launch to ensure dictionary is ready before first use
    func preloadAsync() {
        loadingLock.lock()
        let shouldLoad = !isLoaded && !isLoading
        if shouldLoad {
            isLoading = true
        }
        loadingLock.unlock()
        
        guard shouldLoad else { return }
        
        Task.detached(priority: .userInitiated) {
            await self.loadAsync()
        }
    }
    
    /// Asynchronously loads the full dictionary on a background thread
    private func loadAsync() async {
        // Load dictionary file and parse on background thread
        let dictionary: [String: [String]]? = await Task.detached(priority: .userInitiated) { () -> [String: [String]]? in
            guard let url = Bundle.main.url(forResource: "cmudict", withExtension: "txt") else {
                print("⚠️ CMUDICT: Dictionary file not found")
                return nil
            }
            
            guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
                print("⚠️ CMUDICT: Failed to read dictionary file")
                return nil
            }
            
            // Parse dictionary on background thread
            var parsedDict: [String: [String]] = [:]
            for line in contents.split(separator: "\n") {
                guard !line.hasPrefix(";;;") else { continue }
                let parts = line.split(separator: " ")
                guard parts.count > 1 else { continue }
                let word = String(parts[0]).lowercased()
                let phones = parts.dropFirst().map(String.init)
                parsedDict[word] = phones
            }
            
            return parsedDict
        }.value
        
        // Update dictionary on main thread (thread-safe)
        await MainActor.run {
            if let dict = dictionary {
                self.phonemesByWord = dict
                
                self.loadingLock.lock()
                self.isLoaded = true
                self.isLoading = false
                self.loadingLock.unlock()
                
                print("✅ CMUDICT: Full dictionary loaded successfully (\(dict.count) words)")
            } else {
                self.loadingLock.lock()
                self.isLoading = false
                self.loadingLock.unlock()
                print("⚠️ CMUDICT: Failed to load full dictionary, using fallback")
            }
        }
    }
    
    /// Synchronous load method (kept for backwards compatibility, but should use preloadAsync)
    private func load() {
        guard let url = Bundle.main.url(forResource: "cmudict", withExtension: "txt"),
            let contents = try? String(contentsOf: url, encoding: .utf8) else {
            loadFallbackDictionary()
            return
        }
        parseDict(contents)
    }
    
    /// Parse dictionary contents (used by both sync and async loading)
    private func parseDict(_ contents: String) {
        for line in contents.split(separator: "\n") {
            guard !line.hasPrefix(";;;") else { continue }
            let parts = line.split(separator: " ")
            guard parts.count > 1 else { continue }
            let word = String(parts[0]).lowercased()
            let phones = parts.dropFirst().map(String.init)
            phonemesByWord[word] = phones
        }
    }
    
    /// Get phonemes for a word (thread-safe access)
    /// Falls back to empty array if dictionary not yet loaded
    func getPhonemes(for word: String) -> [String]? {
        loadingLock.lock()
        defer { loadingLock.unlock() }
        return phonemesByWord[word.lowercased()]
    }
    
    private func loadFallbackDictionary() {
        // Minimal fallback dictionary with common words
        phonemesByWord = [
            "love": ["L", "AH1", "V"],
            "dove": ["D", "AH1", "V"],
            "above": ["AH0", "B", "AH1", "V"],
            "shove": ["SH", "AH1", "V"],
            "cat": ["K", "AE1", "T"],
            "hat": ["HH", "AE1", "T"],
            "bat": ["B", "AE1", "T"],
            "rat": ["R", "AE1", "T"],
            "mat": ["M", "AE1", "T"],
            "sat": ["S", "AE1", "T"],
            "day": ["D", "EY1"],
            "way": ["W", "EY1"],
            "say": ["S", "EY1"],
            "pay": ["P", "EY1"],
            "play": ["P", "L", "EY1"],
            "stay": ["S", "T", "EY1"],
            "night": ["N", "AY1", "T"],
            "light": ["L", "AY1", "T"],
            "fight": ["F", "AY1", "T"],
            "right": ["R", "AY1", "T"],
            "sight": ["S", "AY1", "T"],
            "bright": ["B", "R", "AY1", "T"],
            "time": ["T", "AY1", "M"],
            "rhyme": ["R", "AY1", "M"],
            "climb": ["K", "L", "AY1", "M"],
            "chime": ["CH", "AY1", "M"],
            "sublime": ["S", "AH0", "B", "L", "AY1", "M"]
        ]
    }
}

// MARK: - Global Accessor Functions for RapSuggestionAPI

/// Global accessor function to get CMUDICT store
/// This allows RapSuggestionAPI.swift and other files to access FJCMUDICTStore without direct type reference
func getGlobalCMUDICTStore() -> [String: [String]] {
    return FJCMUDICTStore.shared.phonemesByWord
}

/// Global accessor function to preload CMUDICT dictionary asynchronously
/// This allows The_Final_Journal_AIApp.swift to access FJCMUDICTStore without direct type reference
func preloadGlobalCMUDICTStore() {
    // #region agent log
    let logData: [String: Any] = [
        "location": "CMUDICTStore.swift:preloadGlobalCMUDICTStore",
        "message": "preloadGlobalCMUDICTStore wrapper called",
        "timestamp": Date().timeIntervalSince1970 * 1000,
        "sessionId": "debug-session",
        "runId": "run1",
        "hypothesisId": "A"
    ]
    if let jsonData = try? JSONSerialization.data(withJSONObject: logData),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        let logPath = "/Users/samuel/Documents/The Final Journal AI/.cursor/debug.log"
        if let fileHandle = FileHandle(forWritingAtPath: logPath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(jsonString.data(using: .utf8)!)
            fileHandle.write("\n".data(using: .utf8)!)
            fileHandle.closeFile()
        } else {
            try? jsonString.write(toFile: logPath, atomically: true, encoding: .utf8)
        }
    }
    // #endregion
    
    FJCMUDICTStore.shared.preloadAsync()
}
