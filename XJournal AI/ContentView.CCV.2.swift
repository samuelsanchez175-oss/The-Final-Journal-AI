import SwiftUI
import UIKit
import Combine
import Security

// MARK: - Rhyme Color Palette

enum RhymeColorPalette {
    // Six distinct rhyme-group hues, used both as low-opacity editor highlight backgrounds
    // (CCV.6: ~0.16–0.30 alpha) and as foreground TEXT in the rhyme-group list (CCV.15).
    // Scheme-aware: deepened in Light so amber/emerald read as text on the white surface;
    // brightened in Dark so the same hues read on the Lagoon surface (#0C1417). Light values
    // are unchanged from the 2026-05-31 re-tune. Distinct 6-hue identity preserved.
    static let colors: [UIColor] = [
        dynamic(light: (0.82, 0.58, 0.08), dark: (0.96, 0.74, 0.28)),  // amber
        dynamic(light: (0.94, 0.45, 0.35), dark: (0.97, 0.54, 0.45)),  // coral
        dynamic(light: (0.18, 0.62, 0.45), dark: (0.33, 0.82, 0.60)),  // emerald
        dynamic(light: (0.45, 0.64, 0.90), dark: (0.56, 0.73, 0.96)),  // azure
        dynamic(light: (0.72, 0.56, 0.90), dark: (0.79, 0.66, 0.97)),  // violet
        dynamic(light: (0.90, 0.62, 0.78), dark: (0.94, 0.69, 0.85))   // rose
    ]

    /// Resolves Light vs Dark RGB at render time via a dynamic `UIColor` — keeps the static
    /// `[UIColor]` API so every caller (editor highlights, rhyme-group list) is unchanged.
    private static func dynamic(light l: (CGFloat, CGFloat, CGFloat),
                                dark d: (CGFloat, CGFloat, CGFloat)) -> UIColor {
        UIColor { traits in
            let c = traits.userInterfaceStyle == .dark ? d : l
            return UIColor(red: c.0, green: c.1, blue: c.2, alpha: 1)
        }
    }
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
        // Vivid, near-opaque blue so it pops against the coral page instead of
        // reading as a faint pastel.
        Color(red: 0.13, green: 0.52, blue: 1.0)
            .opacity(colorScheme == .dark ? 1.0 : 0.96)
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
            // iOS 26-style moving glint that rides the blue glass edge with device tilt.
            .overlay(
                GyroSpecularEdge(
                    shape: shape,
                    lineWidth: outlineLineWidth + 0.8,
                    tint: .white,
                    intensity: colorScheme == .dark ? 0.85 : 1.0
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