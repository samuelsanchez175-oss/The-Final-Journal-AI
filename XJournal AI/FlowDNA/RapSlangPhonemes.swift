//
//  RapSlangPhonemes.swift
//  XJournal AI
//
//  Slang/OOV phoneme fallback for rap terms not in CMUDICT.
//

import Foundation

nonisolated enum RapSlangPhonemes: Sendable {
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
        "militant": ["M", "IH1", "L", "AH0", "T", "AH0", "N", "T"],
        "idiot": ["IH1", "D", "IY0", "AH0", "T"],
        "immigrant": ["IH1", "M", "AH0", "G", "R", "AH0", "N", "T"],
        "commits": ["K", "AH0", "M", "IH1", "T", "S"],
        "script": ["S", "K", "R", "IH1", "P", "T"],
        "shit": ["SH", "IH1", "T"],
        "flex": ["F", "L", "EH1", "K", "S"],
        "flexin": ["F", "L", "EH1", "K", "S", "IH0", "N"],
        "vibes": ["V", "AY1", "B", "Z"],
        "vibe": ["V", "AY1", "B"],
        "chelly": ["CH", "EH1", "L", "IY0"],
        "dummy": ["D", "AH1", "M", "IY0"],
        "money": ["M", "AH1", "N", "IY0"],
        "hip": ["HH", "IH1", "P"],
        "dick": ["D", "IH1", "K"],
        "pretty": ["P", "R", "IH1", "T", "IY0"],
        "clips": ["K", "L", "IH1", "P", "S"],
        "dancer": ["D", "AE1", "N", "S", "ER0"],
        "cancer": ["K", "AE1", "N", "S", "ER0"],
    ]

    static func phonemes(for word: String) -> [String]? {
        phonemesByWord[word.lowercased()]
    }

    /// Last-resort letter-to-sound for OOV names (`Chelly`) so they can still join a rhyme family.
    /// Only used by the highlighter when CMUDICT and the slang table miss.
    static func heuristicPhonemes(for raw: String) -> [String]? {
        let word = raw.lowercased()
        guard word.count >= 3, word.allSatisfy({ $0.isLetter }) else { return nil }
        let chars = Array(word)
        var phones: [String] = []
        var i = 0
        var vowelCount = 0
        while i < chars.count {
            let c = chars[i]
            let next = i + 1 < chars.count ? chars[i + 1] : nil
            if c == "c", next == "h" { phones.append("CH"); i += 2; continue }
            if c == "s", next == "h" { phones.append("SH"); i += 2; continue }
            if c == "t", next == "h" { phones.append("TH"); i += 2; continue }
            if c == "p", next == "h" { phones.append("F"); i += 2; continue }
            if c == "n", next == "g" { phones.append("NG"); i += 2; continue }
            if c == "c", next == "k" { phones.append("K"); i += 2; continue }
            if let n = next, n == c, !"aeiouy".contains(c) {
                phones.append(consonantPhone(c))
                i += 2
                continue
            }
            if c == "y", i == chars.count - 1 {
                phones.append("IY0")
                i += 1
                continue
            }
            if "aeiou".contains(c) {
                vowelCount += 1
                phones.append(vowelPhone(c, stressed: vowelCount == 1))
                i += 1
                continue
            }
            phones.append(consonantPhone(c))
            i += 1
        }
        guard phones.contains(where: { $0.last?.isNumber == true }) else { return nil }
        return phones
    }

    private static func vowelPhone(_ c: Character, stressed: Bool) -> String {
        let mark = stressed ? "1" : "0"
        switch c {
        case "a": return "AE" + mark
        case "e": return "EH" + mark
        case "i": return "IH" + mark
        case "o": return "AA" + mark
        case "u": return "AH" + mark
        default: return "AH" + mark
        }
    }

    private static func consonantPhone(_ c: Character) -> String {
        switch c {
        case "b": return "B"
        case "c": return "K"
        case "d": return "D"
        case "f": return "F"
        case "g": return "G"
        case "h": return "HH"
        case "j": return "JH"
        case "k": return "K"
        case "l": return "L"
        case "m": return "M"
        case "n": return "N"
        case "p": return "P"
        case "q": return "K"
        case "r": return "R"
        case "s": return "S"
        case "t": return "T"
        case "v": return "V"
        case "w": return "W"
        case "x": return "K"
        case "z": return "Z"
        default: return "T"
        }
    }
}
