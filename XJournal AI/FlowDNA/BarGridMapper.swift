//
//  BarGridMapper.swift
//  XJournal AI
//
//  Places stressed syllables on the 16-slot bar grid (lyrics-only, no audio).
//

import Foundation

enum BarGridMapper {
    private static let defaultBPM = 90
    private static let slotsPerBar = BarGridSlotNames.slotCount

    /// Maps a sequence of stressed syllables to bars with 16 slots each. No audio timestamps; linear distribution.
    static func map(
        stressedSyllables: [StressedSyllable],
        bpm: Int? = nil,
        barOffsetSlots: Int = 0
    ) -> [FlowBar] {
        let _ = bpm ?? Self.defaultBPM
        var bars: [FlowBar] = []
        var cursor = 0
        var barIndex = 1
        while cursor < stressedSyllables.count {
            let bar = buildOneBar(
                syllables: stressedSyllables[cursor...],
                barIndex: barIndex,
                offsetSlots: barOffsetSlots
            )
            bars.append(bar)
            let used = bar.slots.filter { $0.syllable != nil }.count
            cursor += used
            barIndex += 1
            if used == 0 { break }
        }
        return bars
    }

    private static func buildOneBar(
        syllables: ArraySlice<StressedSyllable>,
        barIndex: Int,
        offsetSlots: Int
    ) -> FlowBar {
        let arr = Array(syllables)
        let n = min(arr.count, slotsPerBar)
        var slots: [BarSlot] = []
        for i in 0..<slotsPerBar {
            let slotName = BarGridSlotNames.slotNames[i]
            if i < n {
                let syl = arr[i]
                slots.append(BarSlot(
                    slot: slotName,
                    syllable: syl.text,
                    stress: syl.stress,
                    pause: 0
                ))
            } else {
                slots.append(BarSlot(
                    slot: slotName,
                    syllable: nil,
                    stress: 0,
                    pause: 1
                ))
            }
        }
        return FlowBar(barIndex: barIndex, slots: slots)
    }

    /// Build bars from full verse (multiple lines). Concatenates stress maps per line.
    static func mapVerse(
        lines: [String],
        bpm: Int? = nil,
        barOffsetSlots: Int = 0
    ) -> [FlowBar] {
        var allSyllables: [StressedSyllable] = []
        for line in lines {
            allSyllables.append(contentsOf: StressMapBuilder.build(line: line))
        }
        return map(stressedSyllables: allSyllables, bpm: bpm, barOffsetSlots: barOffsetSlots)
    }
}
