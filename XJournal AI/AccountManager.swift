import Foundation
import Combine
// TODO: Add Supabase Swift SDK package dependency in Xcode
// Then uncomment this line:
// import Supabase

// MARK: - Account Manager
// Handles user authentication and account management using Supabase

// MARK: - Data Models (moved before AccountManager for type availability)

struct UserAccount: Codable {
    let id: String
    let email: String
    let name: String
    let createdAt: Date
    let lastSyncAt: Date?
}

struct UserProfileData: Codable {
    let userId: String
    let name: String
    let email: String
    let phone: String?
    let avatarData: Data?
    let personalDetails: UserPersonalDetails?
    let modelSettings: ModelSettings?
    let preferences: UserPreferences?
}

enum AccountError: LocalizedError {
    case invalidCredentials
    case invalidToken
    case notSignedIn
    case networkError
    case emailAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidToken:
            return "Session expired. Please sign in again."
        case .notSignedIn:
            return "You must be signed in to perform this action"
        case .networkError:
            return "Network error. Please check your connection."
        case .emailAlreadyExists:
            return "An account with this email already exists"
        }
    }
}

class AccountManager: ObservableObject {
    static let shared = AccountManager()
    
    @Published var isSignedIn: Bool = false // DISABLED: Always false - authentication disabled
    @Published var currentUser: UserAccount?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let accountKey = "user_account"
    private let authTokenKey = "auth_token"
    
    // Supabase client (uncomment when SDK is added)
    // private var supabase: SupabaseClient?
    
    private init() {
        // DISABLED: AccountManager initialization disabled
        // No initialization needed - AccountManager disabled
        /*
        // Initialize Supabase client if configured
        initializeSupabase()
        
        // Check if user is already signed in
        checkExistingSession()
        */
    }
    
    private func initializeSupabase() {
        // DISABLED: Supabase not needed at this moment
        // Always skip Supabase initialization and use local storage only
        /*
        guard SupabaseConfig.isConfigured else {
            print("⚠️ Supabase not configured. Please add your credentials in SupabaseConfig.swift")
            return
        }
        
        guard let url = URL(string: SupabaseConfig.supabaseURL),
              !SupabaseConfig.supabaseAnonKey.isEmpty else {
            print("⚠️ Invalid Supabase configuration")
            return
        }
        
        // Initialize Supabase client with Keychain storage for session persistence
        supabase = SupabaseClient(
            supabaseURL: url,
            supabaseKey: SupabaseConfig.supabaseAnonKey,
            options: SupabaseClientOptions(
                auth: AuthOptions(
                    storage: KeychainLocalStorage(),
                    flowType: .pkce
                )
            )
        )
        */
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, name: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // DISABLED: AccountManager signup disabled
        // Mock signup disabled - AccountManager disabled
        /*
        try await mockSignUp(email: email, password: password, name: name)
        */
        
        /* DISABLED: Supabase code commented out
        guard SupabaseConfig.isConfigured else {
            // Fallback to mock if not configured
            try await mockSignUp(email: email, password: password, name: name)
            return
        }
        
        // Uncomment when Supabase SDK is added:
        /*
        guard let supabase = supabase else {
            throw AccountError.networkError
        }
        
        do {
            // Sign up with Supabase
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": name]
            )
            
            guard let session = authResponse.session,
                  let user = authResponse.user else {
                throw AccountError.networkError
            }
            
            // Create user account object
            let account = UserAccount(
                id: user.id.uuidString,
                email: user.email ?? email,
                name: name,
                createdAt: user.createdAt,
                lastSyncAt: nil
            )
            
            await MainActor.run {
                currentUser = account
                isSignedIn = true
            }
            
            // Store account and token
            saveAccount(account)
            if let accessToken = session.accessToken {
                try? KeychainHelper.shared.saveAuthToken(accessToken)
            }
            
            // Auto-sync user data after signup
            try? await syncUserData()
            
        } catch {
            // Handle Supabase errors - check error message for common cases
            let errorMessage = error.localizedDescription.lowercased()
            if errorMessage.contains("already registered") || errorMessage.contains("already exists") {
                throw AccountError.emailAlreadyExists
            } else if errorMessage.contains("invalid") || errorMessage.contains("credentials") {
                throw AccountError.invalidCredentials
            } else {
                throw AccountError.networkError
            }
        }
        */
        */
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func signIn(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // DISABLED: AccountManager signin disabled
        // Mock signin disabled - AccountManager disabled
        /*
        try await mockSignIn(email: email, password: password)
        */
        
        /* DISABLED: Supabase code commented out
        guard SupabaseConfig.isConfigured else {
            // Fallback to mock if not configured
            try await mockSignIn(email: email, password: password)
            return
        }
        
        // Uncomment when Supabase SDK is added:
        /*
        guard let supabase = supabase else {
            throw AccountError.networkError
        }
        
        do {
            // Sign in with Supabase
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            guard let user = session.user else {
                throw AccountError.invalidCredentials
            }
            
            // Get user metadata
            let name = user.userMetadata["full_name"] as? String ?? user.email ?? "User"
            
            // Create user account object
            let account = UserAccount(
                id: user.id.uuidString,
                email: user.email ?? email,
                name: name,
                createdAt: user.createdAt,
                lastSyncAt: nil
            )
            
            await MainActor.run {
                currentUser = account
                isSignedIn = true
            }
            
            // Store account and token
            saveAccount(account)
            if let accessToken = session.accessToken {
                try? KeychainHelper.shared.saveAuthToken(accessToken)
            }
            
            // Auto-load user data after signin
            try? await loadUserData()
            
        } catch {
            // Handle Supabase errors
            let errorMessage = error.localizedDescription.lowercased()
            if errorMessage.contains("invalid") || errorMessage.contains("credentials") {
                throw AccountError.invalidCredentials
            } else {
                throw AccountError.networkError
            }
        }
        */
        */
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func signOut() async throws {
        // Uncomment when Supabase SDK is added:
        /*
        if let supabase = supabase {
            try? await supabase.auth.signOut()
        }
        */
        
        await MainActor.run {
            currentUser = nil
            isSignedIn = false
        }
        
        // Clear stored credentials
        UserDefaults.standard.removeObject(forKey: accountKey)
        UserDefaults.standard.removeObject(forKey: authTokenKey)
        
        // Clear keychain
        try? KeychainHelper.shared.deleteAuthToken()
    }
    
    // MARK: - Account Data Sync
    
    func syncUserData() async throws {
        guard let user = currentUser, isSignedIn else {
            throw AccountError.notSignedIn
        }
        
        // DISABLED: Supabase not needed - always use local sync
        // Always sync locally - Supabase disabled
        try await syncProfileData(user: user)
        return
        
        /*
        guard SupabaseConfig.isConfigured else {
            // Fallback: Just sync locally
            try await syncProfileData(user: user)
            return
        }
        
        // Uncomment when Supabase SDK is added:
        /*
        guard let supabase = supabase else {
            throw AccountError.networkError
        }
        
        // Prepare user profile data
        let profileData = UserProfileData(
            userId: user.id,
            name: UserDefaults.standard.string(forKey: "profile_name") ?? "",
            email: UserDefaults.standard.string(forKey: "profile_email") ?? "",
            phone: UserDefaults.standard.string(forKey: "profile_phone"),
            avatarData: UserDefaults.standard.data(forKey: "profile_avatar_data"),
            personalDetails: loadPersonalDetails(),
            modelSettings: loadModelSettings(),
            preferences: loadPreferences()
        )
        
        // Upload to Supabase database (user_profiles table)
        // Encode the data as JSON string
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(profileData)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
        
        // Upsert to Supabase
        struct ProfileRow: Codable {
            let user_id: String
            let profile_data: String
        }
        
        let row = ProfileRow(user_id: user.id, profile_data: jsonString)
        try await supabase.database
            .from("user_profiles")
            .upsert(row)
            .execute()
        
        // Update last sync time
        var updatedUser = user
        updatedUser.lastSyncAt = Date()
        await MainActor.run {
            currentUser = updatedUser
        }
        saveAccount(updatedUser)
        */
        */
        
        /* DISABLED: Local sync disabled
        // Temporary: Sync locally
        try await syncProfileData(user: user)
        */
    }
    
    func loadUserData() async throws {
        guard currentUser != nil, isSignedIn else {
            throw AccountError.notSignedIn
        }
        
        guard SupabaseConfig.isConfigured else {
            // Fallback: Load from local storage
            return
        }
        
        // Uncomment when Supabase SDK is added:
        /*
        guard let supabase = supabase else {
            throw AccountError.networkError
        }
        
        // Fetch from Supabase database
        struct ProfileRow: Codable {
            let user_id: String
            let profile_data: String
            let updated_at: String?
        }
        
        do {
            let response: [ProfileRow] = try await supabase.database
                .from("user_profiles")
                .select()
                .eq("user_id", value: user.id)
                .execute()
                .value
            
            if let row = response.first,
               let jsonData = row.profile_data.data(using: .utf8) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let profileData = try? decoder.decode(UserProfileData.self, from: jsonData) {
                    // Apply loaded data to local storage
                    applyProfileData(profileData)
                    
                    // Update last sync time
                    var updatedUser = user
                    updatedUser.lastSyncAt = Date()
                    await MainActor.run {
                        currentUser = updatedUser
                    }
                    saveAccount(updatedUser)
                }
            }
        } catch {
            // If no profile exists yet, that's okay - user can sync later
            print("No profile data found in Supabase: \(error.localizedDescription)")
        }
        */
    }
    
    // MARK: - Private Helpers
    
    private func checkExistingSession() {
        // DISABLED: Supabase not needed - always use local storage
        // Always check local storage - Supabase disabled
        if let accountData = UserDefaults.standard.data(forKey: accountKey),
           let account = try? JSONDecoder().decode(UserAccount.self, from: accountData) {
            currentUser = account
            isSignedIn = true
        }
        return
        
        /*
        guard SupabaseConfig.isConfigured else {
            // Fallback: Check local storage
            if let accountData = UserDefaults.standard.data(forKey: accountKey),
               let account = try? JSONDecoder().decode(UserAccount.self, from: accountData) {
                currentUser = account
                isSignedIn = true
            }
            return
        }
        
        // Uncomment when Supabase SDK is added:
        /*
        Task {
            guard let supabase = supabase else { return }
            
            do {
                // Get current session from Supabase
                let session = try await supabase.auth.session
                
                if let session = session, let user = session.user {
                    // Session exists and is valid
                    let name = user.userMetadata["full_name"] as? String ?? user.email ?? "User"
                    
                    let account = UserAccount(
                        id: user.id.uuidString,
                        email: user.email ?? "",
                        name: name,
                        createdAt: user.createdAt,
                        lastSyncAt: nil
                    )
                    
                    await MainActor.run {
                        currentUser = account
                        isSignedIn = true
                    }
                    
                    saveAccount(account)
                } else {
                    // No valid session
                    try? await signOut()
                }
            } catch {
                // Session invalid or expired
                try? await signOut()
            }
        }
        */
        */
        
        /* DISABLED: Local storage check disabled
        // Temporary: Check local storage
        if let accountData = UserDefaults.standard.data(forKey: accountKey),
           let account = try? JSONDecoder().decode(UserAccount.self, from: accountData) {
            currentUser = account
            isSignedIn = true
        }
        */
    }
    
    private func mockSignUp(email: String, password: String, name: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock successful signup
        let user = UserAccount(
            id: UUID().uuidString,
            email: email,
            name: name,
            createdAt: Date(),
            lastSyncAt: nil
        )
        
        let token = UUID().uuidString
        
        await MainActor.run {
            currentUser = user
            isSignedIn = true
        }
        
        // Store account and token
        saveAccount(user)
        try? KeychainHelper.shared.saveAuthToken(token)
        
        // Auto-sync user data after signup
        try? await syncUserData()
    }
    
    private func mockSignIn(email: String, password: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Check if account exists locally (for demo)
        if let accountData = UserDefaults.standard.data(forKey: accountKey),
           let account = try? JSONDecoder().decode(UserAccount.self, from: accountData),
           account.email == email {
            // Found existing account
            let token = UUID().uuidString
            
            await MainActor.run {
                currentUser = account
                isSignedIn = true
            }
            
            try? KeychainHelper.shared.saveAuthToken(token)
            
            // Auto-load user data after signin
            try? await loadUserData()
        } else {
            throw AccountError.invalidCredentials
        }
    }
    
    private func validateToken(_ token: String) async throws {
        // DISABLED: Supabase not needed - always use local token check
        // Always check if token exists locally - Supabase disabled
        guard !token.isEmpty else {
            throw AccountError.invalidToken
        }
        return
        
        /*
        guard SupabaseConfig.isConfigured else {
            // Fallback: Just check if token exists
            guard !token.isEmpty else {
                throw AccountError.invalidToken
            }
            return
        }
        
        // Uncomment when Supabase SDK is added:
        /*
        guard let supabase = supabase else {
            throw AccountError.networkError
        }
        
        // Supabase automatically validates tokens, so we just check session
        let session = try? await supabase.auth.session
        guard session != nil else {
            throw AccountError.invalidToken
        }
        */
        */
    }
    
    private func syncProfileData(user: UserAccount) async throws {
        // TODO: Sync profile data to backend
        let _ = UserProfileData(
            userId: user.id,
            name: UserDefaults.standard.string(forKey: "profile_name") ?? "",
            email: UserDefaults.standard.string(forKey: "profile_email") ?? "",
            phone: UserDefaults.standard.string(forKey: "profile_phone") ?? "",
            avatarData: UserDefaults.standard.data(forKey: "profile_avatar_data"),
            personalDetails: loadPersonalDetails(),
            modelSettings: loadModelSettings(),
            preferences: loadPreferences()
        )
        
        // TODO: Upload to backend
        print("Syncing profile data for user: \(user.id)")
    }
    
    private func syncPreferences() async throws {
        // Sync model preferences, user settings, etc.
        // TODO: Implement backend sync
    }
    
    private func syncFeedbackData() async throws {
        // Sync feedback data if user opts in
        // TODO: Implement backend sync
    }
    
    private func fetchProfileData(userId: String) async throws -> UserProfileData {
        // TODO: Fetch from backend
        // For now, return empty data
        return UserProfileData(
            userId: userId,
            name: "",
            email: "",
            phone: nil,
            avatarData: nil,
            personalDetails: nil,
            modelSettings: nil,
            preferences: nil
        )
    }
    
    private func applyProfileData(_ data: UserProfileData) {
        if !data.name.isEmpty {
            UserDefaults.standard.set(data.name, forKey: "profile_name")
        }
        if !data.email.isEmpty {
            UserDefaults.standard.set(data.email, forKey: "profile_email")
        }
        if let phone = data.phone {
            UserDefaults.standard.set(phone, forKey: "profile_phone")
        }
        if let avatarData = data.avatarData {
            UserDefaults.standard.set(avatarData, forKey: "profile_avatar_data")
        }
        if let personalDetails = data.personalDetails {
            if let encoded = try? JSONEncoder().encode(personalDetails) {
                UserDefaults.standard.set(encoded, forKey: "user_personal_details")
            }
        }
        if let modelSettings = data.modelSettings {
            if let encoded = try? JSONEncoder().encode(modelSettings) {
                UserDefaults.standard.set(encoded, forKey: "modelG_settings")
            }
        }
    }
    
    private func saveAccount(_ account: UserAccount) {
        if let encoded = try? JSONEncoder().encode(account) {
            UserDefaults.standard.set(encoded, forKey: accountKey)
        }
    }
    
    private func loadPersonalDetails() -> UserPersonalDetails? {
        guard let data = UserDefaults.standard.data(forKey: "user_personal_details"),
              let details = try? JSONDecoder().decode(UserPersonalDetails.self, from: data) else {
            return nil
        }
        return details
    }
    
    private func loadModelSettings() -> ModelSettings? {
        guard let data = UserDefaults.standard.data(forKey: "modelG_settings"),
              let settings = try? JSONDecoder().decode(ModelSettings.self, from: data) else {
            return nil
        }
        return settings
    }
    
    private func loadPreferences() -> UserPreferences? {
        guard let data = UserDefaults.standard.data(forKey: "user_personalization"),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return nil
        }
        return preferences
    }
}
