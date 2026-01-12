import SwiftUI
import UIKit
import Combine
import Security

// MARK: - Rhyme Color Palette

enum RhymeColorPalette {
    static let colors: [UIColor] = [
        UIColor(red: 0.94, green: 0.76, blue: 0.20, alpha: 1),
        UIColor(red: 0.94, green: 0.45, blue: 0.35, alpha: 1),
        UIColor(red: 0.48, green: 0.78, blue: 0.64, alpha: 1),
        UIColor(red: 0.45, green: 0.64, blue: 0.90, alpha: 1),
        UIColor(red: 0.72, green: 0.56, blue: 0.90, alpha: 1),
        UIColor(red: 0.90, green: 0.62, blue: 0.78, alpha: 1)
    ]
}

// MARK: - Keychain Helper

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    enum KeychainError: Error {
        case encodingError
        case decodingError
        case itemNotFound
        case saveError(String)
        case loadError(String)
    }
    
    private func save(key: String, data: Data) throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            let updateQuery = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ] as CFDictionary
            
            let attributesToUpdate = [kSecValueData as String: data] as CFDictionary
            
            let updateStatus = SecItemUpdate(updateQuery, attributesToUpdate)
            guard updateStatus == noErr else {
                throw KeychainError.saveError("Failed to update existing item")
            }
        } else {
            guard status == noErr else {
                throw KeychainError.saveError("OSStatus: \(status)")
            }
        }
    }
    
    private func load(key: String) throws -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        guard status == noErr, let data = result as? Data else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.loadError("OSStatus: \(status)")
        }
        
        return data
    }
    
    private func delete(key: String) throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.saveError("OSStatus: \(status)")
        }
    }
    
    // API Key Management
    func getAPIKey() -> String? {
        do {
            guard let data = try load(key: "openai_api_key") else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    func saveAPIKey(_ apiKey: String) throws {
        guard let data = apiKey.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(key: "openai_api_key", data: data)
    }
    
    func deleteAPIKey() throws {
        try delete(key: "openai_api_key")
    }
    
    // Auth Token Management
    func saveAuthToken(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(key: "auth_token", data: data)
    }
    
    func getAuthToken() -> String? {
        do {
            guard let data = try load(key: "auth_token") else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    func deleteAuthToken() throws {
        try delete(key: "auth_token")
    }
}

// MARK: - Helper Functions

func lightHaptic() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
}

// MARK: - Glass Settings

enum GlassSettings {
    static let darkening: Double = 0.12
    static let gloss: Double = 1.0
}

// MARK: - Scroll Offset Key

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Journal Detail Placeholder View

struct JournalDetailPlaceholderView: View {
    var body: some View {
        Color.clear
    }
}