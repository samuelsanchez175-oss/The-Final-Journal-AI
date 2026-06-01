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
func getGlobalCMUDICTStore() -> [String: [String]] {
    FJCMUDICTStore.shared.phonemesByWord
}

/// Triggers async load of CMUDICT; posts .cmudictDidFinishLoading when done.
func preloadGlobalCMUDICTStore() {
    FJCMUDICTStore.shared.preload()
}

final class FJCMUDICTStore {
    static let shared = FJCMUDICTStore()
    
    private let lock = NSLock()
    private var _phonemesByWord: [String: [String]] = [:]
    private var _isLoaded = false
    
    var phonemesByWord: [String: [String]] {
        lock.lock()
        defer { lock.unlock() }
        return _phonemesByWord
    }
    
    private init() {}
    
    func preload() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.load()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .cmudictDidFinishLoading, object: nil)
            }
        }
    }
    
    private func load() {
        lock.lock()
        defer { lock.unlock() }
        guard !_isLoaded else { return }
        
        guard let url = Bundle.main.url(forResource: "cmudict", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("⚠️ FJCMUDICTStore: cmudict.txt not found in bundle")
            _isLoaded = true
            return
        }
        
        var dict: [String: [String]] = [:]
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty,
                  !trimmed.hasPrefix("#"),
                  !trimmed.hasPrefix(";") else { continue }
            let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count >= 2 else { continue }
            let word = String(parts[0]).lowercased()
            let rest = String(parts[1])
            let phonemes = rest.split(separator: " ").map(String.init).filter { !$0.isEmpty }
            guard !phonemes.isEmpty else { continue }
            if dict[word] == nil {
                dict[word] = phonemes
            }
        }
        _phonemesByWord = dict
        _isLoaded = true
        print("✅ FJCMUDICTStore: loaded \(dict.count) words")
    }
}
