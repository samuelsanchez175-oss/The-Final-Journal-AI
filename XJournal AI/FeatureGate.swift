import Foundation
import SwiftUI

// MARK: - Feature Gate
// Centralized feature gating system for subscription tiers

class FeatureGate {
    static let shared = FeatureGate()
    
    // MARK: - Development Mode
    // Set to true to disable all feature gates during development
    private static let isDevelopmentMode = true
    
    private init() {}
    
    // MARK: - Feature Access Checks
    
    /// Check if user can access a premium feature
    /// DEVELOPMENT MODE: Always returns true - all features enabled
    static func canAccess(_ feature: PremiumFeature) -> Bool {
        if isDevelopmentMode {
            return true // Always allow access in development
        }
        // Production code (disabled during development):
        // return SubscriptionManager.shared.hasTier(feature.requiredTier)
        return true
    }
    
    /// Require a specific tier, return false if not met (for showing paywall)
    /// DEVELOPMENT MODE: Always returns true - all features enabled
    static func requireTier(_ tier: SubscriptionTier, featureName: String) -> Bool {
        if isDevelopmentMode {
            return true // Always allow in development
        }
        // Production code (disabled during development):
        // if !SubscriptionManager.shared.hasTier(tier) {
        //     return false
        // }
        return true
    }
    
    /// Check if user can use a feature and optionally show paywall
    /// DEVELOPMENT MODE: Always returns true - all features enabled (paywall never shown)
    static func checkAccess(
        _ feature: PremiumFeature,
        showPaywall: @escaping (String) -> Void
    ) -> Bool {
        if isDevelopmentMode {
            return true // Always allow access in development (paywall never shown)
        }
        // Production code (disabled during development):
        // if canAccess(feature) {
        //     return true
        // } else {
        //     showPaywall(feature.displayName)
        //     return false
        // }
        return true
    }
    
    /// Get the required tier for a feature
    /// DEVELOPMENT MODE: Always returns .none - no tier required
    static func requiredTier(for feature: PremiumFeature) -> SubscriptionTier {
        if isDevelopmentMode {
            return .none // No tier required in development
        }
        // Production code (disabled during development):
        // return feature.requiredTier
        return .none
    }
}

// MARK: - Premium Feature Enum

enum PremiumFeature {
    case aiSuggestions
    case rewriteLine
    case improveFlow
    case generateLyricsFromFlow
    case styleTransfer
    case themeExpansion
    case exportPDF
    case exportWord
    case analytics
    case advancedDiagnostics
    case cloudSync
    case prioritySupport
    
    var requiredTier: SubscriptionTier {
        switch self {
        case .aiSuggestions, .rewriteLine, .improveFlow, .exportPDF, .exportWord, .cloudSync, .prioritySupport:
            return .basic
        case .generateLyricsFromFlow, .styleTransfer, .themeExpansion, .analytics, .advancedDiagnostics:
            return .pro
        }
    }
    
    var displayName: String {
        switch self {
        case .aiSuggestions:
            return "AI Suggestions"
        case .rewriteLine:
            return "Rewrite Line"
        case .improveFlow:
            return "Improve Flow"
        case .generateLyricsFromFlow:
            return "Generate Lyrics from Flow"
        case .styleTransfer:
            return "Critic"
        case .themeExpansion:
            return "Theme Expansion"
        case .exportPDF:
            return "PDF Export"
        case .exportWord:
            return "Word Export"
        case .analytics:
            return "Analytics Dashboard"
        case .advancedDiagnostics:
            return "Advanced Diagnostics"
        case .cloudSync:
            return "Cloud Sync"
        case .prioritySupport:
            return "Priority Support"
        }
    }
    
    var description: String {
        switch self {
        case .aiSuggestions:
            return "Get AI-powered suggestions for your next lines"
        case .rewriteLine:
            return "Rewrite lines with AI assistance"
        case .improveFlow:
            return "Improve the flow and cadence of your lyrics"
        case .generateLyricsFromFlow:
            return "Generate lyrics from your recorded flow or mumble"
        case .styleTransfer:
            return "Get A&R-style line-by-line critiques of your writing"
        case .themeExpansion:
            return "Expand on themes and explore related concepts"
        case .exportPDF:
            return "Export notes to PDF format"
        case .exportWord:
            return "Export notes to Word/RTF format"
        case .analytics:
            return "View detailed writing analytics and insights"
        case .advancedDiagnostics:
            return "Advanced rhyme diagnostics and analysis"
        case .cloudSync:
            return "Sync your notes across all devices"
        case .prioritySupport:
            return "Get priority support and faster response times"
        }
    }
}
