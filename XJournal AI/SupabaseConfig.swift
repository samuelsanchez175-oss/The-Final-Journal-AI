import Foundation

// MARK: - Supabase Configuration
// Store your Supabase project credentials here
// Get these from: https://app.supabase.com -> Your Project -> Settings -> API

struct SupabaseConfig {
    // Supabase project URL
    static let supabaseURL = "https://fmzkmerqotgisspgjhyj.supabase.co"
    
    // Supabase anon/public key (safe to use in client apps with RLS enabled)
    static let supabaseAnonKey = "sb_publishable_mV8HGP3A-sPKR7oiaM8Deg_i0Xe0kxS"
    
    // Optional: Service role key (for admin operations - keep secure!)
    static let supabaseServiceKey: String? = nil // Only use server-side, never expose in client
    
    static var isConfigured: Bool {
        return !supabaseURL.isEmpty && !supabaseAnonKey.isEmpty
    }
}
