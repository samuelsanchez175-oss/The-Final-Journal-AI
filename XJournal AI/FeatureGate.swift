import Foundation
import SwiftUI

// MARK: - Feature Gate
// Centralized feature gating system for subscription tiers

class FeatureGate {
    static let shared = FeatureGate()
    
    private init() {}
    
    // MARK: - Feature Access Checks
    
    /// Check if user can access a premium feature
    /// DISABLED: Always returns true - subscriptions disabled
    static func canAccess(_ feature: PremiumFeature) -> Bool {
        return true // Always allow access - subscriptions disabled
        // return SubscriptionManager.shared.hasTier(feature.requiredTier)
    }
    
    /// Require a specific tier, return false if not met (for showing paywall)
    /// DISABLED: Always returns true - subscriptions disabled
    static func requireTier(_ tier: SubscriptionTier, featureName: String) -> Bool {
        return true // Always allow - subscriptions disabled
        // if !SubscriptionManager.shared.hasTier(tier) {
        //     return false
        // }
        // return true
    }
    
    /// Check if user can use a feature and optionally show paywall
    /// DISABLED: Always returns true - subscriptions disabled
    static func checkAccess(
        _ feature: PremiumFeature,
        showPaywall: @escaping (String) -> Void
    ) -> Bool {
        return true // Always allow access - subscriptions disabled
        // if canAccess(feature) {
        //     return true
        // } else {
        //     showPaywall(feature.displayName)
        //     return false
        // }
    }
    
    /// Get the required tier for a feature
    /// DISABLED: Always returns .none - subscriptions disabled
    static func requiredTier(for feature: PremiumFeature) -> SubscriptionTier {
        return .none // Always return none tier - subscriptions disabled
        // return feature.requiredTier
    }
}

// MARK: - Premium Feature Enum

enum PremiumFeature {
    case aiSuggestions
    case rewriteLine
    case improveFlow
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
        case .styleTransfer, .themeExpansion, .analytics, .advancedDiagnostics:
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
        case .styleTransfer:
            return "Style Transfer"
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
        case .styleTransfer:
            return "Rewrite lyrics in the style of any artist"
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
