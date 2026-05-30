//
//  SocialActionArc.swift
//  XJournal AI
//
//  Turns one verse-level social posture into a deliberate per-bar ARC, so the voice SHIFTS
//  across the verse (establish → contrast/turn → escalate → land) instead of repeating one
//  move on every bar. This is the lightweight "strategy step" of the persona work: a planned
//  emotional/strategic shape, computed without an extra LLM call.
//

import Foundation

enum SocialActionArc {
    /// Build a `count`-long arc of social actions from the verse's dominant move.
    /// Shape: open/build = dominant, mid = a contrasting "turn" for tension, peak = escalate,
    /// close = finality (assert), final bar lands punchy (flex) unless the verse is somber.
    static func build(dominant: SocialAction?, count: Int) -> [SocialAction] {
        guard count > 0 else { return [] }
        let base = dominant ?? .assert
        let turn = contrast(of: base)
        let peak = escalate(from: base)

        var arc: [SocialAction] = []
        for i in 0..<count {
            let pos = count > 1 ? Double(i) / Double(count - 1) : 0.0   // 0…1 through the verse
            let action: SocialAction
            if pos < 0.45 {
                action = base                                   // open + build: establish the posture
            } else if pos < 0.65 {
                action = turn                                   // mid turn: contrast for tension
            } else if pos < 0.85 {
                action = peak                                   // peak: escalate
            } else if i == count - 1 {
                action = (base == .confess || base == .withdraw) ? .assert : .flex   // land
            } else {
                action = .assert                                // close: finality
            }
            arc.append(action)
        }
        return arc
    }

    /// The contrasting move that creates a mid-verse "turn".
    private static func contrast(of a: SocialAction) -> SocialAction {
        switch a {
        case .flex:     return .distance
        case .warn:     return .flex
        case .distance: return .assert
        case .assert:   return .flex
        case .withdraw: return .assert
        case .confess:  return .distance
        }
    }

    /// The escalated move at the verse's peak.
    private static func escalate(from a: SocialAction) -> SocialAction {
        switch a {
        case .flex, .assert: return .flex
        case .warn:          return .warn
        case .distance:      return .assert
        case .withdraw:      return .assert
        case .confess:       return .assert
        }
    }
}
