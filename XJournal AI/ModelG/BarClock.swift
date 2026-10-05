//
//  BarClock.swift
//  XJournal AI
//
//  Wrap pocket math (Ohm): bars/min = BPM / 4. Default Gunna wrap = 92 BPM,
//  last stress on beats 3–4. Hats whose half sits in 70–100 fold once (140→70, 180→90).
//

import Foundation

enum WrapPocket: String, Codable, Equatable, CaseIterable {
    case behind
    case onTop
    case ahead

    var promptLabel: String {
        switch self {
        case .behind: return "behind the beat"
        case .onTop: return "on top of the beat"
        case .ahead: return "ahead of the beat"
        }
    }

    var pickerLabel: String {
        switch self {
        case .behind: return "Behind"
        case .onTop: return "On top"
        case .ahead: return "Ahead"
        }
    }
}

enum WrapBpmSource: String, Codable, Equatable, CaseIterable {
    case note
    case wrap92
    case custom

    var pickerLabel: String {
        switch self {
        case .note: return "Note’s beat"
        case .wrap92: return "92"
        case .custom: return "Custom"
        }
    }
}

enum PunchGrammar: String, Codable, Equatable, CaseIterable {
    case couplet
    case threePlusOne
    case closedLoop4

    var pickerLabel: String {
        switch self {
        case .couplet: return "Couplet"
        case .threePlusOne: return "3+1"
        case .closedLoop4: return "Closed-loop 4"
        }
    }
}

struct BarClock: Equatable {
    var bpm: Double
    var beatsPerBar: Int
    var punchWindowBeats: ClosedRange<Double>
    var pocket: WrapPocket
    var generateChunkBars: Int
    var hatsFolded: Bool

    var barsPerMinute: Double { bpm / Double(beatsPerBar) }
    var secondsPerBar: Double { 240.0 / bpm }
    var secondsPerBeat: Double { 60.0 / bpm }

    /// Beat in the current bar, 1...beatsPerBar (Gunna punch = 3 and 4).
    func beatInBar(elapsed: TimeInterval) -> Int {
        guard bpm > 0, beatsPerBar > 0 else { return 1 }
        let t = max(0, elapsed)
        let idx = Int(floor(t / secondsPerBeat)) % beatsPerBar
        return idx + 1
    }

    func isPunchBeat(_ beat: Int) -> Bool {
        punchWindowBeats.contains(Double(beat))
    }

    static func punchBeats(from raw: String) -> Set<Int> {
        Set(
            raw.split(separator: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                .filter { (1...4).contains($0) }
        )
    }

    static func encodePunchBeats(_ beats: Set<Int>) -> String {
        beats.filter { (1...4).contains($0) }.sorted().map(String.init).joined(separator: ",")
    }

    static func togglingPunch(_ beats: Set<Int>, beat: Int) -> Set<Int> {
        guard (1...4).contains(beat) else { return beats }
        var next = beats
        if next.contains(beat) { next.remove(beat) } else { next.insert(beat) }
        return next
    }

    static let wrapDefaultBPM: Double = 92
    /// Landmarks songs actually sit at (hip-hop 80–100, R&B/pop 110–128, trap hats ~140–180).
    static let quickSelectBPMs: [Int] = [80, 90, 100, 110, 120, 128, 140, 150, 160, 180]

    static func resolve(userBPM: Int?, pocket: WrapPocket = .behind, foldHatsEnabled: Bool = true) -> BarClock {
        let raw = Double(userBPM ?? Int(wrapDefaultBPM))
        let (bpm, folded) = foldHatsEnabled ? foldHats(raw) : (raw, false)
        return BarClock(
            bpm: bpm,
            beatsPerBar: 4,
            punchWindowBeats: 3.0...4.0,
            pocket: pocket,
            generateChunkBars: 4,
            hatsFolded: folded
        )
    }

    /// Visual clock for listening — matches the file / metronome, never half-time.
    static func resolveHeard(userBPM: Int?, pocket: WrapPocket = .behind) -> BarClock {
        resolve(userBPM: userBPM, pocket: pocket, foldHatsEnabled: false)
    }

    /// Hats at 2× wrap (half sits in 70–100) fold once so the vocal writes half-time.
    static func foldHats(_ bpm: Double) -> (Double, Bool) {
        if bpm >= 118 {
            let half = bpm / 2.0
            if half >= 70 && half <= 100 { return (half, true) }
        }
        return (bpm, false)
    }
}
