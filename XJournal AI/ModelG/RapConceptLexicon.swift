//
//  RapConceptLexicon.swift
//  XJournal AI
//
//  Model G v4 — Phase 5: concept (theme/meaning) taxonomy for RAG retrieval.
//
//  Distilled from the "LLM builder" vault wiki (its 52 descriptor/jargon nodes, grouped into the
//  vault's semantic categories). Used to tag corpus bars AND the journal entry so retrieval can
//  match by MEANING — cars, watches, jewelry, money, substances… — not just tone + rhyme + syllables.
//
//  Single-word keywords match whole tokens (so "ap" won't fire inside "trap"); multi-word / hyphenated
//  keywords match as substrings.
//

import Foundation

enum RapConceptLexicon {
    /// concept -> representative terms (faithful to the vault's category nodes).
    static let conceptKeywords: [String: [String]] = [
        "cars": ["car", "cars", "lambo", "lamborghini", "huracan", "huracán", "urus", "bentley",
                 "bentayga", "maybach", "porsche", "rolls", "royce", "rolls-royce", "phantom",
                 "wraith", "cullinan", "ghost", "coupe", "foreign", "whip", "trackhawk", "suicide doors"],
        "watches": ["watch", "ap", "audemars", "piguet", "cartier", "patek", "philippe",
                    "richard mille", "rolex", "roley", "plain jane", "hurricane ap"],
        "fashion": ["gucci", "ysl", "saint laurent", "prada", "birkin", "hermes", "hermès",
                    "balenciaga", "amiri", "designer", "off-white", "vlone", "fendi", "dior", "louis"],
        "jewelry": ["rocks", "stones", "frozen", "glistening", "cubans", "choker", "pendant", "vvs",
                    "diamonds", "diamond", "ice", "iced", "bust down", "bustdown", "bussdown", "chain"],
        "substances": ["codeine", "lean", "xanax", "xans", "xanny", "percocet", "percs", "perc",
                       "molly", "wock", "wockhardt", "pints", "drank", "actavis"],
        "weapons": ["glock", "glizzy", "blicky", "draco", "chop", "drum", "stick", "tec", "beam",
                    "extendo", "switch"],
        "luxury_travel": ["jet", "jets", "private jet", "netjets", "yacht", "mansion", "estate", "penthouse"],
        "money": ["racks", "bands", "hunnids", "commas", "gwap", "guap", "bread", "bag", "bags",
                  "blue faces", "profit", "mil", "mills"],
        "drip_identity": ["drip", "drippy", "wunna", "flex", "flexin", "flexing", "slime", "slatt", "gang"]
    ]

    /// Concepts expressed in a piece of text (a corpus bar or a journal entry).
    static func concepts(in text: String) -> Set<String> {
        let lower = text.lowercased()
        let tokens = Set(lower.split { !$0.isLetter && !$0.isNumber && $0 != "-" }.map(String.init))
        var out: Set<String> = []
        for (concept, keywords) in conceptKeywords {
            for kw in keywords {
                let multi = kw.contains(" ") || kw.contains("-")
                if multi ? lower.contains(kw) : tokens.contains(kw) {
                    out.insert(concept)
                    break
                }
            }
        }
        return out
    }
}
