//
//  BYOKKeychain.swift
//  PennWork Studios
//
//  Task T14a: Secure on-device keychain storage for Bring-Your-Own-Key (BYOK) API keys.
//  Policy: kSecAttrAccessibleWhenUnlockedThisDeviceOnly (no iCloud sync).
//  Namespaced: com.pennworkstudios.byok.<provider>
//

import Foundation
import Security

public enum BYOKProvider: String, CaseIterable, Codable {
    case anthropic
    case openai
    case google

    public var displayName: String {
        switch self {
        case .anthropic:
            return "Anthropic"
        case .openai:
            return "OpenAI"
        case .google:
            return "Google"
        }
    }

    public var keychainKey: String {
        return "com.pennworkstudios.byok.\(rawValue)"
    }
}

public enum BYOKKeychainError: LocalizedError {
    case encodingError
    case saveError(String)
    case loadError(String)
    case deleteError(String)

    public var errorDescription: String? {
        switch self {
        case .encodingError:
            return "Failed to encode API key to UTF-8."
        case .saveError(let msg):
            return "Failed to save key in Keychain: \(msg)"
        case .loadError(let msg):
            return "Failed to load key from Keychain: \(msg)"
        case .deleteError(let msg):
            return "Failed to delete key from Keychain: \(msg)"
        }
    }
}

public enum BYOKKeychain {
    public static let serviceName = "com.pennworkstudios.byok"

    // In-memory fallback when unsigned test builds lack Keychain entitlements
    private static var inMemoryFallback: [String: String] = [:]
    private static let lock = NSLock()

    /// Saves an API key for the specified provider into the secure device-only keychain.
    public static func save(key: String, for provider: BYOKProvider) throws {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmedKey.data(using: .utf8) else {
            throw BYOKKeychainError.encodingError
        }

        let account = provider.keychainKey

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: serviceName,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
            if updateStatus == errSecMissingEntitlement {
                setFallback(key: trimmedKey, for: provider)
                return
            }
            guard updateStatus == noErr else {
                throw BYOKKeychainError.saveError("SecItemUpdate OSStatus: \(updateStatus)")
            }
            clearFallback(for: provider)
        } else if status == errSecMissingEntitlement {
            setFallback(key: trimmedKey, for: provider)
        } else {
            guard status == noErr else {
                throw BYOKKeychainError.saveError("SecItemAdd OSStatus: \(status)")
            }
            clearFallback(for: provider)
        }
    }

    /// Loads the stored API key for the specified provider, or returns nil if absent.
    public static func load(for provider: BYOKProvider) -> String? {
        let account = provider.keychainKey

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == noErr, let data = item as? Data, let keyString = String(data: data, encoding: .utf8), !keyString.isEmpty {
            return keyString
        }

        if let fallback = getFallback(for: provider), !fallback.isEmpty {
            return fallback
        }

        return nil
    }

    /// Deletes the stored API key for the specified provider.
    public static func delete(for provider: BYOKProvider) throws {
        let account = provider.keychainKey

        clearFallback(for: provider)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound || status == errSecMissingEntitlement else {
            throw BYOKKeychainError.deleteError("SecItemDelete OSStatus: \(status)")
        }
    }

    /// Returns the list of all providers that currently have a valid non-empty key stored.
    public static func providers() -> [BYOKProvider] {
        return BYOKProvider.allCases.filter { provider in
            guard let key = load(for: provider) else { return false }
            return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    // MARK: - In-Memory Fallback for Tests / Simulator Without Keychain Entitlement
    private static func setFallback(key: String, for provider: BYOKProvider) {
        lock.lock()
        defer { lock.unlock() }
        inMemoryFallback[provider.keychainKey] = key
    }

    private static func getFallback(for provider: BYOKProvider) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return inMemoryFallback[provider.keychainKey]
    }

    private static func clearFallback(for provider: BYOKProvider) {
        lock.lock()
        defer { lock.unlock() }
        inMemoryFallback.removeValue(forKey: provider.keychainKey)
    }

    public static func resetAllForTesting() {
        lock.lock()
        inMemoryFallback.removeAll()
        lock.unlock()
        for provider in BYOKProvider.allCases {
            try? delete(for: provider)
        }
    }
}
