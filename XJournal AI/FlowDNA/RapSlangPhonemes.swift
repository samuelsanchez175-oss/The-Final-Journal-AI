//
//  RapSlangPhonemes.swift
//  XJournal AI
//
//  Slang/OOV phoneme fallback for rap terms not in CMUDICT.
//

import Foundation

enum RapSlangPhonemes {
    /// word (lowercased) -> CMU-style phonemes. Check before FJCMUDICTStore.
    static let phonemesByWord: [String: [String]] = [
        "opp": ["AA1", "P"],
        "opps": ["AA1", "P", "S"],
        "blick": ["B", "L", "IH1", "K"],
        "switchy": ["S", "W", "IH1", "CH", "IY0"],
        "gangnem": ["G", "AE1", "NG", "N", "EH0", "M"],
        "perc": ["P", "ER1", "K"],
        "percs": ["P", "ER1", "K", "S"],
        "skrrt": ["S", "K", "R", "ER1", "T"],
        "skrt": ["S", "K", "R", "ER1", "T"],
        "drip": ["D", "R", "IH1", "P"],
        "glizzy": ["G", "L", "IH1", "Z", "IY0"],
        "bando": ["B", "AE1", "N", "D", "OW0"],
        "choppa": ["CH", "AA1", "P", "AH0"],
        "chopper": ["CH", "AA1", "P", "ER0"],
        "trap": ["T", "R", "AE1", "P"],
        "slatt": ["S", "L", "AE1", "T"],
        "slat": ["S", "L", "AE1", "T"],
        "cap": ["K", "AE1", "P"],
        "capping": ["K", "AE1", "P", "IH0", "NG"],
        "no cap": ["N", "OW1", "K", "AE1", "P"],
        "bussin": ["B", "AH1", "S", "IH0", "N"],
        "bussing": ["B", "AH1", "S", "IH0", "NG"],
        "lit": ["L", "IH1", "T"],
        "flex": ["F", "L", "EH1", "K", "S"],
        "flexin": ["F", "L", "EH1", "K", "S", "IH0", "N"],
        "vibes": ["V", "AY1", "B", "Z"],
        "vibe": ["V", "AY1", "B"],
    ]

    static func phonemes(for word: String) -> [String]? {
        phonemesByWord[word.lowercased()]
    }
}
