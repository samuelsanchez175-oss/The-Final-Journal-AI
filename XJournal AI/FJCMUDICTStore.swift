//
//  FJCMUDICTStore.swift
//  The Final Journal AI
//
//  CMUDICT phonetic dictionary store. Loads cmudict.txt for rhyme highlighting.
//

import Foundation

extension Notification.Name {
    static let cmudictDidFinishLoading = Notification.Name("cmudictDidFinishLoading")
}

/// Global accessor for the CMUDICT phoneme dictionary.
nonisolated func getGlobalCMUDICTStore() -> [String: [String]] {
    FJCMUDICTStore.shared.phonemesByWord
}

/// Triggers async load of CMUDICT; posts .cmudictDidFinishLoading when done.
nonisolated func preloadGlobalCMUDICTStore() {
    FJCMUDICTStore.shared.preload()
}

nonisolated final class FJCMUDICTStore: @unchecked Sendable {
    static let shared = FJCMUDICTStore()
    
    private let lock = NSLock()
    private var _phonemesByWord: [String: [String]] = [:]
    private var _isLoaded = false
    private var _started = false
    
    var phonemesByWord: [String: [String]] {
        lock.lock()
        let started = _started
        let snapshot = _phonemesByWord
        lock.unlock()
        if !started {
            preload()
        }
        return snapshot
    }
    
    private init() {}
    
    func preload() {
        lock.lock()
        if _started {
            lock.unlock()
            return
        }
        _started = true
        lock.unlock()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.load()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .cmudictDidFinishLoading, object: nil)
            }
        }
    }
    
    private func load() {
        lock.lock()
        let already = _isLoaded
        lock.unlock()
        guard !already else { return }
        
        guard let url = Bundle.main.url(forResource: "cmudict", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("⚠️ FJCMUDICTStore: cmudict.txt not found in bundle")
            lock.lock()
            _isLoaded = true
            lock.unlock()
            return
        }
        
        var dict: [String: [String]] = [:]
        dict.reserveCapacity(140_000)
        content.enumerateLines { line, _ in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty,
                  !trimmed.hasPrefix("#"),
                  !trimmed.hasPrefix(";") else { return }
            let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count >= 2 else { return }
            let word = String(parts[0]).lowercased()
            guard dict[word] == nil else { return }
            let phonemes = parts[1].split(separator: " ").map(String.init).filter { !$0.isEmpty }
            guard !phonemes.isEmpty else { return }
            dict[word] = phonemes
        }
        lock.lock()
        _phonemesByWord = dict
        _isLoaded = true
        lock.unlock()
        print("✅ FJCMUDICTStore: loaded \(dict.count) words")
    }
}
