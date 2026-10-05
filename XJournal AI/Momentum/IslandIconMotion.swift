//
//  IslandIconMotion.swift
//  XJournal AI
//
//  Slight selected-state motion for the island icons. The artwork stays the
//  original symbol or GhostIcon; only a small transform plays while selected.
//

import SwiftUI

struct IslandGhostWave: ViewModifier {
    var active: Bool
    var size: CGFloat

    func body(content: Content) -> some View {
        if active {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                let time = context.date.timeIntervalSinceReferenceDate * 4.2
                content.distortionEffect(
                    ShaderLibrary.ghostHemWave(.float(Float(time)), .float(Float(size))),
                    maxSampleOffset: CGSize(width: 0, height: 2),
                    isEnabled: true
                )
            }
        } else {
            content
        }
    }
}

struct IslandEyeBlink: ViewModifier {
    var active: Bool

    func body(content: Content) -> some View {
        if active {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                content.scaleEffect(
                    x: 1,
                    y: Self.opening(at: context.date.timeIntervalSinceReferenceDate),
                    anchor: .center
                )
            }
        } else {
            content
        }
    }

    /// Holds open, then one short close. The symbol itself does not change.
    private static func opening(at time: TimeInterval) -> CGFloat {
        let cycle = time.truncatingRemainder(dividingBy: 3.2)
        guard cycle > 2.42, cycle < 2.72 else { return 1 }
        let u = (cycle - 2.42) / 0.30
        return 1 - 0.72 * CGFloat(sin(u * .pi))
    }
}

struct IslandKeyPress: ViewModifier {
    var active: Bool

    func body(content: Content) -> some View {
        if active {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                content.offset(y: Self.press(at: context.date.timeIntervalSinceReferenceDate))
            }
        } else {
            content
        }
    }

    /// One small downward tap, then a rest. About 1.5pt.
    private static func press(at time: TimeInterval) -> CGFloat {
        let cycle = time.truncatingRemainder(dividingBy: 1.5)
        guard cycle < 0.22 else { return 0 }
        return CGFloat(sin(cycle / 0.22 * .pi)) * 1.5
    }
}
