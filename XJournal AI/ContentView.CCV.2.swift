import SwiftUI
import UIKit
import Combine
import Security

// MARK: - Rhyme Color Palette

enum RhymeColorPalette {
    // Light re-tune (2026-05-31): the editor already applies these as low-opacity backgrounds
    // (CCV.6: ~0.16–0.30 alpha in light), but the rhyme-group list (CCV.15) uses them as
    // foreground TEXT on the white Momentum surface — where amber[0] + green[2] read too faint.
    // Deepened just those two so they're legible as text AND still soft as editor highlights.
    // Distinct 6-hue identity preserved.
    static let colors: [UIColor] = [
        UIColor(red: 0.82, green: 0.58, blue: 0.08, alpha: 1),  // amber (deepened for light)
        UIColor(red: 0.94, green: 0.45, blue: 0.35, alpha: 1),  // coral
        UIColor(red: 0.18, green: 0.62, blue: 0.45, alpha: 1),  // emerald (deepened for light)
        UIColor(red: 0.45, green: 0.64, blue: 0.90, alpha: 1),  // azure
        UIColor(red: 0.72, green: 0.56, blue: 0.90, alpha: 1),  // violet
        UIColor(red: 0.90, green: 0.62, blue: 0.78, alpha: 1)   // rose
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
    
    // Genius API Key Management
    func getGeniusAPIKey() -> String? {
        do {
            guard let data = try load(key: "genius_api_key") else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    func saveGeniusAPIKey(_ apiKey: String) throws {
        guard let data = apiKey.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(key: "genius_api_key", data: data)
    }
    
    func deleteGeniusAPIKey() throws {
        try delete(key: "genius_api_key")
    }

    // Suno API Key
    func getSunoAPIKey() -> String? {
        do {
            guard let data = try load(key: "suno_api_key") else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    func saveSunoAPIKey(_ apiKey: String) throws {
        guard let data = apiKey.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(key: "suno_api_key", data: data)
    }

    func deleteSunoAPIKey() throws {
        try delete(key: "suno_api_key")
    }

    // Uberduck API credentials
    func getUberduckAPIKey() -> String? {
        do {
            guard let data = try load(key: "uberduck_api_key") else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    func saveUberduckAPIKey(_ key: String) throws {
        guard let data = key.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(key: "uberduck_api_key", data: data)
    }

    func getUberduckAPISecret() -> String? {
        do {
            guard let data = try load(key: "uberduck_api_secret") else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    func saveUberduckAPISecret(_ secret: String) throws {
        guard let data = secret.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(key: "uberduck_api_secret", data: data)
    }

    func deleteUberduckCredentials() {
        try? delete(key: "uberduck_api_key")
        try? delete(key: "uberduck_api_secret")
    }
}

// MARK: - Helper Functions

func lightHaptic() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
}

// MARK: - Glass Settings

enum GlassSettings {
    static let darkening: Double = 0.05
    static let gloss: Double = 1.0
}

enum SoftBlueGlassStyle {
    static func tint(for colorScheme: ColorScheme) -> Color {
        Color(red: 0.45, green: 0.72, blue: 1.0)
            .opacity(colorScheme == .dark ? 0.96 : 0.88)
    }
}

struct SoftBlueGlassBackground<S: InsettableShape>: View {
    let shape: S
    let colorScheme: ColorScheme
    var darkeningMultiplier: Double = 1.0
    var outlineLineWidth: CGFloat = 0.8

    var body: some View {
        shape
            .fill(.ultraThinMaterial)
            .overlay(
                shape
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.14 : 0.24),
                                Color.white.opacity(colorScheme == .dark ? 0.10 : 0.18),
                                Color.white.opacity(colorScheme == .dark ? 0.14 : 0.24)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
                    .clipShape(shape)
            )
            .overlay(
                Color.black.opacity(
                    colorScheme == .dark ? GlassSettings.darkening * darkeningMultiplier : 0.04
                )
            )
            .overlay(
                shape
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.22 : 0.36),
                                SoftBlueGlassStyle.tint(for: colorScheme).opacity(colorScheme == .dark ? 0.28 : 0.22),
                                Color.white.opacity(colorScheme == .dark ? 0.18 : 0.30)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: outlineLineWidth
                    )
            )
            .clipShape(shape)
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.30 : 0.10),
                radius: 8,
                x: 0,
                y: 2
            )
    }
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