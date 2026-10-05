import XCTest
@testable import XJournal_AI

/// Eval only: 4-bar cycles sampled from the desktop Gunna/Thug CSV.
/// Not ingested as BLUEPRINT. Overlay is advisory.
final class CsvWrapEvalTests: XCTestCase {
    private struct Sample {
        let id: String
        let year: String
        let kind: String
        let bars: [String]
    }

    func testOverlayOnCsvCycles() {
        let samples: [Sample] = [
            Sample(id: "Who You Foolin V1", year: "2019", kind: "verse-even", bars: [
                "We don't need no one vouchin' for us",
                "I've been grindin' and found me a buzz",
                "I've been searchin' for love and found lust",
                "It's so hard to stop holdin' a grudge"
            ]),
            Sample(id: "mop V2", year: "2022", kind: "verse-sparse", bars: [
                "Emeralds, green diamonds (Green)",
                "Gators, they slimy (Slime)",
                "Car clear coat and polished",
                "Please go fire your stylist (Fire)"
            ]),
            Sample(id: "flooded V2", year: "2022", kind: "verse-luxury", bars: [
                "I spent two-fifty on just one chain",
                "None of this shit came from Johnny Dang",
                "Eliantte got me goin' insane",
                "Diamonds updated, they 'head of the game"
            ]),
            Sample(id: "fukumean V", year: "2023", kind: "verse-short", bars: [
                "Fuck you mean?",
                "Young Gunna Wunna, they workin' my nerves",
                "I'm about to pour up some syrup",
                "Fucking this bitch like a perv'"
            ]),
            Sample(id: "on one tonight", year: "2024", kind: "verse-pocket", bars: [
                "I went to AP, spent 200K",
                "They sold me the frost, rainbow face",
                "They hope I fall off, ain't no way",
                "I might be 'ight, but it ain't okay"
            ]),
            Sample(id: "forever be mine V1", year: "2025", kind: "verse-late", bars: [
                "You wanna chill or T up?",
                "Uh, bring me them guns, get 'em beat up",
                "Slow it down, baby, we ain't gotta rush",
                "Unless you want me to speed up"
            ]),
            Sample(id: "WUNNA FLO V2", year: "2020", kind: "verse-wunna", bars: [
                "Spent two hunna racks for the bulletproof (Two hunna)",
                "That bitch is so nasty, she like Betty Boop (Nasty)",
                "I hit from the back, had the pussy loose (Ooh)",
                "Her fingernails holdin' her toes down"
            ]),
            Sample(id: "Business Is Business V1", year: "2018", kind: "verse-brand-couplet", bars: [
                "Uh, Bentleys on Bentleys, we mob through the A",
                "Benjis on Benjis, we stack every day",
                "Business is business, so you gotta pay",
                "New Lamborghinis make me wanna race"
            ]),
            Sample(id: "Off White VLONE chorus", year: "2018", kind: "chorus-caption", bars: [
                "Shoppin' spree for fun, she did Saint Laurent (Uh)",
                "Alexander, Laurent (Yah), private flight to Milan ('Lan)",
                "Ice VVs (Ice, ice), ice VS1s (Ice VS1s)",
                "Off-White, Vlone 1's, foreigns parked in my lawn"
            ]),
            Sample(id: "hakuna matata V1", year: "2024", kind: "verse-long", bars: [
                "A dirty thirty, I hit it like Curry, they hit me, I don't even holler (Yeah, don't even holler)",
                "These niggas songs floppin', niggas ain't gon' stop him (Songs floppin', gon' stop him)",
                "Switch out my cars and my addy, my family straight and that's all that matter (Yeah, all that)",
                "Stackin' them racks in the safe and prepare for whatever, whenever it happen (Whenever it happen)"
            ]),
            Sample(id: "Seals Pills V1", year: "2018", kind: "verse-broken-pocket", bars: [
                "Blew a ten",
                "On a Wednesday, stack these bands",
                "Heard you rent wasn't paid, need a lend",
                "Just like Frito-Lay, I'ma feed my friends"
            ]),
            Sample(id: "SKYBOX V1", year: "2020", kind: "verse-fragment", bars: [
                "Hey (Hey), hey (Hey), hey (Hey)",
                "Put some diamonds in Chrome Hearts lens",
                "Bought a new Benz, lost some more friends",
                "Stretchin' my hands, money all in"
            ])
        ]

        var lines: [String] = ["id\tyear\tkind\ttie\tpunch\tshare\trime\tident\tpocket\tconcept\tsummary"]
        var ties: [String: Double] = [:]
        for sample in samples {
            let overlay = WrapOverlayEngine.evaluate(bars: sample.bars, grammar: .couplet)
            ties[sample.id] = overlay.tieBreak
            XCTAssertGreaterThanOrEqual(overlay.tieBreak, 0)
            XCTAssertLessThanOrEqual(overlay.tieBreak, 1)
            lines.append("\(sample.id)\t\(sample.year)\t\(sample.kind)\t\(String(format: "%.3f", overlay.tieBreak))\t\(overlay.punchWindowHits)/\(overlay.punchWindowTotal)\t\(overlay.setupPunchShares)/\(overlay.setupPunchTotal)\t\(overlay.rimeAtLeastNear)/\(overlay.rimeTotal)\t\(overlay.identicalEchoes)\t\(overlay.pocketRepeatHits)/\(overlay.pocketRepeatTotal)\t\(overlay.conceptCarry)\t\(overlay.summary)")
        }

        let stripped = Sample(
            id: "mop V2 stripped",
            year: "2022",
            kind: "verse-sparse-stripped",
            bars: [
                "Emeralds, green diamonds",
                "Gators, they slimy",
                "Car clear coat and polished",
                "Please go fire your stylist"
            ]
        )
        let raw = WrapOverlayEngine.evaluate(bars: samples.first { $0.id == "mop V2" }!.bars, grammar: .couplet)
        let clean = WrapOverlayEngine.evaluate(bars: stripped.bars, grammar: .couplet)
        lines.append("\(stripped.id)\t\(stripped.year)\t\(stripped.kind)\t\(String(format: "%.3f", clean.tieBreak))\t\(clean.punchWindowHits)/\(clean.punchWindowTotal)\t\(clean.setupPunchShares)/\(clean.setupPunchTotal)\t\(clean.rimeAtLeastNear)/\(clean.rimeTotal)\t\(clean.identicalEchoes)\t\(clean.pocketRepeatHits)/\(clean.pocketRepeatTotal)\t\(clean.conceptCarry)\t\(clean.summary)")
        lines.append("NOTE\tmop raw=\(String(format: "%.3f", raw.tieBreak)) stripped=\(String(format: "%.3f", clean.tieBreak)) foolin=\(String(format: "%.3f", ties["Who You Foolin V1"] ?? -1)) chorus=\(String(format: "%.3f", ties["Off White VLONE chorus"] ?? -1))")
        let out = URL(fileURLWithPath: "/tmp/csv_wrap_eval.tsv")
        try? lines.joined(separator: "\n").write(to: out, atomically: true, encoding: .utf8)
    }
}
