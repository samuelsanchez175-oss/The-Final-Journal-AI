import Foundation

/// Kept and skipped signature chips. Wrap search does not read this.
nonisolated enum SignatureMemory {
    private static let keptKey = "signature.memory.kept"
    private static let skippedKey = "signature.memory.skipped"

    static var store: UserDefaults = .standard

    static func recordKept(personId: String, aspectId: String) {
        bump(keptKey, personId: personId, aspectId: aspectId)
    }

    static func recordSkipped(personId: String, aspectId: String) {
        bump(skippedKey, personId: personId, aspectId: aspectId)
    }

    /// Negative when the chip has been kept. Positive when it has been skipped.
    static func adjustment(personId: String, aspectId: String) -> Int {
        let key = storageKey(personId: personId, aspectId: aspectId)
        let kept = count(keptKey, key: key)
        let skipped = count(skippedKey, key: key)
        return skipped * 2 - kept * 4
    }

    static func reset() {
        store.removeObject(forKey: keptKey)
        store.removeObject(forKey: skippedKey)
    }

    private static func bump(_ name: String, personId: String, aspectId: String) {
        guard !personId.isEmpty, !aspectId.isEmpty else { return }
        var bag = store.dictionary(forKey: name) as? [String: Int] ?? [:]
        let key = storageKey(personId: personId, aspectId: aspectId)
        bag[key, default: 0] += 1
        store.set(bag, forKey: name)
    }

    private static func count(_ name: String, key: String) -> Int {
        let bag = store.dictionary(forKey: name) as? [String: Int] ?? [:]
        return bag[key] ?? 0
    }

    private static func storageKey(personId: String, aspectId: String) -> String {
        personId + "|" + aspectId
    }
}
