import XCTest
@testable import XJournal_AI

final class RhymeAssonanceTests: XCTestCase {
    private func signature(_ vowel: String, _ coda: [String]) -> RhymeHighlighterEngine.PhoneticSignature {
        RhymeHighlighterEngine.PhoneticSignature(stressedVowel: vowel, coda: coda)
    }

    func testAssonanceMatchesTheNamedPairsAndRejectsDreamsLanes() {
        let dreams = signature("IY1", ["M", "Z"])
        let scene = signature("IY1", ["N"])
        let time = signature("AY1", ["M"])
        let signs = signature("AY1", ["N", "Z"])
        let veins = signature("EY1", ["N", "Z"])
        let lanes = signature("EY1", ["N", "Z"])
        let gains = signature("EY1", ["N", "Z"])
        let deal = signature("IY1", ["L"])
        let meal = signature("IY1", ["L"])
        let heal = signature("IY1", ["L"])

        XCTAssertEqual(RhymeHighlighterEngine.rhymeScore(dreams, scene), .assonance)
        XCTAssertEqual(RhymeHighlighterEngine.rhymeScore(time, signs), .assonance)
        XCTAssertEqual(RhymeHighlighterEngine.rhymeScore(veins, lanes), .perfect)
        XCTAssertEqual(RhymeHighlighterEngine.rhymeScore(lanes, gains), .perfect)
        XCTAssertEqual(RhymeHighlighterEngine.rhymeScore(deal, meal), .perfect)
        XCTAssertEqual(RhymeHighlighterEngine.rhymeScore(meal, heal), .perfect)
        XCTAssertNil(RhymeHighlighterEngine.rhymeScore(dreams, lanes))
        XCTAssertLessThan(
            RhymeHighlighterEngine.RhymeStrength.assonance.rawValue,
            RhymeHighlighterEngine.RhymeStrength.perfect.rawValue
        )
    }

    private func waitForDictionary() {
        preloadGlobalCMUDICTStore()
        let start = Date()
        while getGlobalCMUDICTStore()["dreams"] == nil, Date().timeIntervalSince(start) < 20 {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
    }

    func testHighlighterPaintsAssonanceLighterThanExact() async {
        waitForDictionary()
        XCTAssertNotNil(getGlobalCMUDICTStore()["dreams"])
        let text = """
        dreams
        scene
        time
        signs
        veins
        lanes
        gains
        deal
        meal
        heal
        """
        let (groups, _) = await RhymeHighlighterEngine.computeAll(text: text)

        func group(containing word: String) -> RhymeHighlighterEngine.RhymeGroup? {
            groups.first { $0.words.contains { $0.word == word } }
        }

        let dreamGroup = group(containing: "dreams")
        let sceneGroup = group(containing: "scene")
        XCTAssertNotNil(dreamGroup)
        XCTAssertEqual(dreamGroup?.id, sceneGroup?.id)
        XCTAssertEqual(dreamGroup?.strength, .assonance)
        XCTAssertEqual(dreamGroup?.colorIndex, sceneGroup?.colorIndex)

        let timeGroup = group(containing: "time")
        XCTAssertEqual(timeGroup?.id, group(containing: "signs")?.id)
        XCTAssertEqual(timeGroup?.strength, .assonance)

        let dealGroup = group(containing: "deal")
        XCTAssertEqual(dealGroup?.strength, .perfect)
        XCTAssertEqual(dealGroup?.id, group(containing: "meal")?.id)
        XCTAssertEqual(dealGroup?.id, group(containing: "heal")?.id)

        let veinGroup = group(containing: "veins")
        XCTAssertEqual(veinGroup?.strength, .perfect)
        XCTAssertEqual(veinGroup?.id, group(containing: "lanes")?.id)
        XCTAssertEqual(veinGroup?.id, group(containing: "gains")?.id)

        XCTAssertNotEqual(dreamGroup?.id, group(containing: "lanes")?.id)
    }

    func testDreamsAndLanesDoNotShareAHighlight() async {
        waitForDictionary()
        let text = "dreams\nlanes"
        let (groups, _) = await RhymeHighlighterEngine.computeAll(text: text)
        let shared = groups.contains { group in
            let words = Set(group.words.map(\.word))
            return words.contains("dreams") && words.contains("lanes")
        }
        XCTAssertFalse(shared)
    }

    func testFillerWordsStayDark() async {
        waitForDictionary()
        let text = "yeah it's got the yeah"
        let (groups, _) = await RhymeHighlighterEngine.computeAll(text: text)
        let painted = Set(groups.flatMap { $0.words.map(\.word) })
        for filler in ["yeah", "it's", "its", "got", "the"] {
            XCTAssertFalse(painted.contains(filler), filler)
        }
    }

    func testMaintainedHighlightsOnlyTainedWithLanesGains() async {
        waitForDictionary()
        XCTAssertNotNil(getGlobalCMUDICTStore()["maintained"])
        XCTAssertNotNil(getGlobalCMUDICTStore()["lanes"])
        let text = "lanes\ngains\nveins\nmaintained"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)

        func painted(_ highlight: Highlight) -> String? {
            Range(highlight.utf16, in: text).map { String(text[$0]).lowercased() }
        }
        let paintedTexts = highlights.compactMap(painted)
        XCTAssertTrue(paintedTexts.contains("tained"), "painted \(paintedTexts)")
        XCTAssertFalse(paintedTexts.contains("maintained"), "the whole word must stay dark, painted \(paintedTexts)")
        XCTAssertFalse(paintedTexts.contains("main"))

        let family = groups.first { group in
            let words = Set(group.words.map { $0.word.lowercased() })
            return words.isSuperset(of: ["lanes", "gains", "veins", "tained"])
        }
        XCTAssertNotNil(family, "groups \(groups.map { $0.words.map(\.word) })")
        XCTAssertEqual(family?.strength, .perfect)

        let ns = text as NSString
        let lanesRange = ns.range(of: "lanes")
        let gainsRange = ns.range(of: "gains")
        XCTAssertTrue(highlights.contains { $0.utf16 == lanesRange }, "lanes must highlight the whole word")
        XCTAssertTrue(highlights.contains { $0.utf16 == gainsRange }, "gains must highlight the whole word")
    }

    func testSurveillanceHighlightsOnlyVeil() async {
        waitForDictionary()
        XCTAssertNotNil(getGlobalCMUDICTStore()["surveillance"])
        XCTAssertNotNil(getGlobalCMUDICTStore()["veil"])
        let text = "veil\nsurveillance"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)
        func painted(_ highlight: Highlight) -> String? {
            Range(highlight.utf16, in: text).map { String(text[$0]).lowercased() }
        }
        let paintedTexts = highlights.compactMap(painted)
        XCTAssertFalse(paintedTexts.contains("surveillance"), "painted \(paintedTexts)")
        XCTAssertEqual(paintedTexts.filter { $0 == "veil" }.count, 2, "painted \(paintedTexts)")
        let ns = text as NSString
        let wholeVeil = ns.range(of: "veil")
        XCTAssertTrue(highlights.contains { $0.utf16 == wholeVeil })
        let shared = groups.contains { group in
            group.words.filter { $0.word.lowercased() == "veil" }.count >= 2
        }
        XCTAssertTrue(shared, "groups \(groups.map { $0.words.map(\.word) })")
    }

    func testUnknownWordSplitsOnVowelGroups() {
        let slices = RhymeHighlighterEngine.syllableSlices(of: "borptain")
        XCTAssertGreaterThanOrEqual(slices.count, 2)
        XCTAssertTrue(slices.contains { $0.spelling.hasSuffix("tain") }, "slices \(slices.map(\.spelling))")
    }

    func testDeclineTimeNinesSignsHighlightAsOneGroup() async {
        waitForDictionary()
        for word in ["decline", "time", "nines", "signs"] {
            XCTAssertNotNil(getGlobalCMUDICTStore()[word], word)
        }
        let text = "decline time nines signs"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)
        let family = groups.filter { group in
            let words = Set(group.words.map { $0.word.lowercased() })
            return words.isSuperset(of: ["decline", "time", "nines", "signs"])
        }
        XCTAssertEqual(family.count, 1, "groups \(groups.map { $0.words.map(\.word) })")
        let ns = text as NSString
        for word in ["decline", "time", "nines", "signs"] {
            let range = ns.range(of: word)
            XCTAssertTrue(highlights.contains { $0.utf16 == range }, "\(word) must highlight, groups \(groups.map { $0.words.map(\.word) })")
        }
    }

    func testMattressStressedSliceIsMatAndTress() {
        waitForDictionary()
        XCTAssertNotNil(getGlobalCMUDICTStore()["mattress"])
        let slices = RhymeHighlighterEngine.syllableSlices(of: "mattress")
        XCTAssertEqual(slices.map(\.spelling), ["mat", "tress"], "slices \(slices.map(\.spelling))")
        let firstCoda = slices.first?.signature.coda.map { String($0.filter { !$0.isNumber }) } ?? []
        XCTAssertTrue(firstCoda.contains("T"), "coda \(firstCoda)")
        XCTAssertEqual(slices.last?.stress, 0)
    }

    func testBadBitchThatsRichMattressPaintsTheStack() async {
        waitForDictionary()
        let text = "bad bitch, that's rich, mattress"
        let (groups, _) = await RhymeHighlighterEngine.computeAll(text: text)
        let described = groups.map { "\($0.strength) \($0.words.map(\.word))" }
        let ae = groups.first { group in
            let words = Set(group.words.map { $0.word.lowercased() })
            return words.isSuperset(of: ["bad", "that's", "mat"])
        }
        XCTAssertNotNil(ae, "groups \(described)")
        let aeWords = Set((ae?.words ?? []).map { $0.word.lowercased() })
        XCTAssertFalse(aeWords.contains("tress"), "groups \(described)")
        let ih = groups.first { group in
            let words = Set(group.words.map { $0.word.lowercased() })
            return words.isSuperset(of: ["bitch", "rich"])
        }
        XCTAssertEqual(ih?.strength, .perfect, "groups \(described)")
    }

    func testEngineInternalClusterUsesStressedSliceForMattress() {
        waitForDictionary()
        XCTAssertNotNil(getGlobalCMUDICTStore()["mattress"])
        XCTAssertNotNil(getGlobalCMUDICTStore()["darkness"])
        XCTAssertEqual(
            RhymeHighlighterEngine.rhymeScore(
                signature("IY1", ["M", "Z"]),
                signature("IY1", ["N"])
            ),
            .assonance
        )
        let clusters = RhymeClusterEngine.detect(lines: ["bad bitch, that's rich, mattress"])
        let described = clusters.map { "\($0.type):\($0.parts)" }
        let stack = clusters.first { cluster in
            cluster.type == "internal"
                && Set(cluster.parts).isSuperset(of: ["bad", "that's", "mat"])
        }
        XCTAssertNotNil(stack, "clusters \(described)")
        XCTAssertFalse(stack?.parts.contains("tress") ?? true, "clusters \(described)")
        let stressed = RhymeHighlighterEngine.syllableSlices(of: "mattress")
            .first { $0.stress >= 1 && !$0.coversWholeWord }
        XCTAssertEqual(stressed?.spelling, "mat")
        XCTAssertTrue(
            stressed?.signature.stressedVowel.hasPrefix("AE") == true,
            "vowel \(stressed?.signature.stressedVowel ?? "nil")"
        )
        let end = RhymeClusterEngine.detect(lines: ["on the mattress", "in the darkness"])
        let endParts = end.first { $0.type == "end" }?.parts ?? []
        XCTAssertTrue(
            Set(endParts).isSuperset(of: ["mattress", "darkness"]),
            "end \(end.map { "\($0.type):\($0.parts)" })"
        )
    }

    func testHighlighterInternalGroupsComeFromTheEngine() async {
        waitForDictionary()
        let lines = ["dreams", "scene"]
        let text = lines.joined(separator: "\n")
        let engineParts = Set(
            RhymeClusterEngine.detect(lines: lines)
                .filter { $0.type == "internal" }
                .flatMap(\.parts)
        )
        XCTAssertTrue(engineParts.isSuperset(of: ["dreams", "scene"]), "engine \(engineParts)")
        let (groups, _) = await RhymeHighlighterEngine.computeAll(text: text)
        let described = groups.map { "\($0.rhymeType) \($0.strength) \($0.words.map(\.word))" }
        let dream = groups.first { $0.words.contains { $0.word.lowercased() == "dreams" } }
        XCTAssertEqual(dream?.strength, .assonance, "groups \(described)")
        let paintedInternal = Set(groups.flatMap { group -> [String] in
            guard case .internalRhyme = group.rhymeType else { return [] }
            return group.words.map { $0.word.lowercased() }
        })
        XCTAssertEqual(paintedInternal, engineParts, "groups \(described)")
    }

    func testMultisyllableRateIsMeasuredNotHardcoded() {
        waitForDictionary()
        let mono = FlowDNAEngine.analyze(verse: "the cat\nthe hat")
        XCTAssertEqual(mono.1.multisyllableRhymeRate, 0, "mono \(mono.1.multisyllableRhymeRate)")
        let multi = FlowDNAEngine.analyze(verse: "walking\ntalking")
        XCTAssertEqual(multi.1.multisyllableRhymeRate, 1, "multi \(multi.1.multisyllableRhymeRate)")
    }
}
