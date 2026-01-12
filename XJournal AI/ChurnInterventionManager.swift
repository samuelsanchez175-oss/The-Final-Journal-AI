import Foundation
import SwiftUI
import Combine

// MARK: - Churn Intervention Manager
// Triggers proactive interventions based on churn risk

class ChurnInterventionManager: ObservableObject {
    static let shared = ChurnInterventionManager()
    
    @Published var pendingInterventions: [Intervention] = []
    
    private let interventionKey = "churn_interventions"
    private let lastInterventionKey = "last_intervention_date"
    
    private init() {
        loadPendingInterventions()
    }
    
    // MARK: - Check and Trigger Interventions
    
    func checkAndTriggerInterventions() {
        let assessment = ChurnRiskAnalyzer.shared.assessChurnRisk()
        let lastInterventionDate = UserDefaults.standard.object(forKey: lastInterventionKey) as? Date ?? Date.distantPast
        let daysSinceLastIntervention = Calendar.current.dateComponents([.day], from: lastInterventionDate, to: Date()).day ?? 0
        
        // Don't show interventions too frequently (max once per day)
        guard daysSinceLastIntervention >= 1 else { return }
        
        var newInterventions: [Intervention] = []
        
        switch assessment.riskLevel {
        case .high:
            // High risk: Multiple intervention types
            newInterventions.append(contentsOf: generateHighRiskInterventions(assessment: assessment))
        case .medium:
            // Medium risk: Helpful tips and feature highlights
            newInterventions.append(contentsOf: generateMediumRiskInterventions(assessment: assessment))
        case .low:
            // Low risk: Optional helpful tips
            if daysSinceLastIntervention >= 7 {
                newInterventions.append(contentsOf: generateLowRiskInterventions())
            }
        }
        
        // Filter out interventions that were shown recently
        let recentInterventionTypes = pendingInterventions
            .filter { Calendar.current.isDateInToday($0.createdAt) }
            .map { $0.type }
        
        newInterventions = newInterventions.filter { !recentInterventionTypes.contains($0.type) }
        
        pendingInterventions.append(contentsOf: newInterventions)
        savePendingInterventions()
        
        if !newInterventions.isEmpty {
            UserDefaults.standard.set(Date(), forKey: lastInterventionKey)
        }
    }
    
    // MARK: - Generate Interventions
    
    private func generateHighRiskInterventions(assessment: ChurnRiskAssessment) -> [Intervention] {
        var interventions: [Intervention] = []
        
        // Personalized feedback request
        if assessment.riskFactors.contains(.negativeFeedbackTrend) {
            interventions.append(Intervention(
                id: UUID(),
                type: .feedbackRequest,
                title: "Help Us Improve",
                message: "We noticed you've been having issues with suggestions. Your feedback helps us make them better.",
                actionTitle: "Share Feedback",
                priority: .high,
                createdAt: Date()
            ))
        }
        
        // Feature discovery
        if assessment.riskFactors.contains(.featureAbandonment) {
            interventions.append(Intervention(
                id: UUID(),
                type: .featureDiscovery,
                title: "Discover More Features",
                message: "There are powerful features you might not know about. Let us show you around!",
                actionTitle: "Explore Features",
                priority: .high,
                createdAt: Date()
            ))
        }
        
        // Premium upgrade (if hitting limits)
        let usageTracker = UsageTracker.shared
        if !usageTracker.isPremiumUser() && (usageTracker.getRemainingAISuggestions() < 3) {
            interventions.append(Intervention(
                id: UUID(),
                type: .premiumUpgrade,
                title: "Unlock Unlimited Suggestions",
                message: "You're running low on free suggestions. Upgrade to Premium for unlimited access!",
                actionTitle: "Upgrade Now",
                priority: .high,
                createdAt: Date()
            ))
        }
        
        return interventions
    }
    
    private func generateMediumRiskInterventions(assessment: ChurnRiskAssessment) -> [Intervention] {
        var interventions: [Intervention] = []
        
        // Helpful tips
        interventions.append(Intervention(
            id: UUID(),
            type: .helpfulTip,
            title: "Pro Tip",
            message: getRandomTip(),
            actionTitle: "Got it",
            priority: .medium,
            createdAt: Date()
        ))
        
        // Feature highlight
        if assessment.riskFactors.contains(.featureAbandonment) {
            interventions.append(Intervention(
                id: UUID(),
                type: .featureHighlight,
                title: "Try This Feature",
                message: "Did you know you can compare multiple suggestions side-by-side?",
                actionTitle: "Learn More",
                priority: .medium,
                createdAt: Date()
            ))
        }
        
        return interventions
    }
    
    private func generateLowRiskInterventions() -> [Intervention] {
        return [
            Intervention(
                id: UUID(),
                type: .helpfulTip,
                title: "Did You Know?",
                message: getRandomTip(),
                actionTitle: "Thanks",
                priority: .low,
                createdAt: Date()
            )
        ]
    }
    
    private func getRandomTip() -> String {
        let tips = [
            "You can favorite suggestions you like for quick access later.",
            "Use the comparison view to see multiple suggestions side-by-side.",
            "Try adjusting your model settings for different styles of suggestions.",
            "The rhyme highlighting feature helps visualize your verse structure.",
            "You can regenerate suggestions if they don't match what you're looking for."
        ]
        return tips.randomElement() ?? tips[0]
    }
    
    // MARK: - Manage Interventions
    
    func dismissIntervention(_ intervention: Intervention) {
        pendingInterventions.removeAll { $0.id == intervention.id }
        savePendingInterventions()
    }
    
    func markInterventionCompleted(_ intervention: Intervention) {
        dismissIntervention(intervention)
    }
    
    func getNextIntervention() -> Intervention? {
        // Return highest priority intervention
        return pendingInterventions
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
            .first
    }
    
    // MARK: - Private Helpers
    
    private func loadPendingInterventions() {
        guard let data = UserDefaults.standard.data(forKey: interventionKey),
              let decoded = try? JSONDecoder().decode([Intervention].self, from: data) else {
            pendingInterventions = []
            return
        }
        
        // Filter out old interventions (older than 7 days)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        pendingInterventions = decoded.filter { $0.createdAt > sevenDaysAgo }
        savePendingInterventions()
    }
    
    private func savePendingInterventions() {
        if let encoded = try? JSONEncoder().encode(pendingInterventions) {
            UserDefaults.standard.set(encoded, forKey: interventionKey)
        }
    }
}

// MARK: - Data Models

struct Intervention: Codable, Identifiable {
    let id: UUID
    let type: InterventionType
    let title: String
    let message: String
    let actionTitle: String
    let priority: InterventionPriority
    let createdAt: Date
}

enum InterventionType: String, Codable {
    case feedbackRequest = "feedback_request"
    case featureDiscovery = "feature_discovery"
    case featureHighlight = "feature_highlight"
    case helpfulTip = "helpful_tip"
    case premiumUpgrade = "premium_upgrade"
}

enum InterventionPriority: Int, Codable {
    case low = 1
    case medium = 2
    case high = 3
}
