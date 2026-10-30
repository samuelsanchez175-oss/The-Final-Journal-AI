import XCTest
@testable import XJournal_AI

final class RhymeGroupStrictnessTests: XCTestCase {
    /// `phonemes(for:)` falls through to the letter heuristic before CMUDICT
    /// finishes loading, so a nil check does not wait for the real vowel.
    private func waitForDictionaryWord(_ word: String) {
        preloadGlobalCMUDICTStore()
        let start = Date()
        while getGlobalCMUDICTStore()[word] == nil, Date().timeIntervalSince(start) < 20 {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
    }

    func testSilentUsesPrimaryStressNotSchwa() {
        let sig = RhymeHighlighterEngine.extractSignature(from: ["S", "AY1", "L", "AH0", "N", "T"])
        XCTAssertEqual(sig?.stressedVowel, "AY1")
        XCTAssertTrue(sig?.rimeKey.hasPrefix("AY") ?? false)
    }

    func testSchwaOnlyWordHasNoSignature() {
        XCTAssertNil(RhymeHighlighterEngine.extractSignature(from: ["AH0"]))
    }

    func testSilentAndTickAreDifferentRimes() {
        let silent = RhymeHighlighterEngine.extractSignature(from: ["S", "AY1", "L", "AH0", "N", "T"])
        let tick = RhymeHighlighterEngine.extractSignature(from: ["T", "IH1", "K"])
        XCTAssertNotEqual(silent?.rimeKey, tick?.rimeKey)
        XCTAssertNil(RhymeHighlighterEngine.rhymeScore(silent!, tick!))
    }

    func testGlowAndFlowShareRime() {
        let glow = RhymeHighlighterEngine.extractSignature(from: ["G", "L", "OW1"])
        let flow = RhymeHighlighterEngine.extractSignature(from: ["F", "L", "OW1"])
        XCTAssertEqual(glow?.rimeKey, flow?.rimeKey)
        XCTAssertEqual(RhymeHighlighterEngine.rhymeScore(glow!, flow!), .perfect)
    }

    func testAIsAStopword() {
        XCTAssertTrue(RhymeHighlighterEngine.rhymeStopwords.contains("a"))
    }

    func testColorsLockToPhoneticClassNotFirstAppearance() async {
        let text = "The sound around begins to mount\nA beat, a breath, the right amount"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)
        XCTAssertGreaterThanOrEqual(groups.count, 1)
        for group in groups {
            XCTAssertEqual(
                group.colorIndex,
                RhymeHighlighterEngine.colorIndex(forRhymeClass: group.key)
            )
            let painted = highlights.filter { $0.colorIndex == group.colorIndex }
            XCTAssertFalse(painted.isEmpty)
        }
    }

    func testPhoneFamilyIsStableEmeraldAcrossNotes() {
        let phone = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "OW1", coda: ["N"])
        let tone = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "OW1", coda: ["N"])
        let alone = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "OW1", coda: ["N"])
        XCTAssertEqual(phone.rhymeClassId, "OW|N")
        let a = RhymeHighlighterEngine.colorIndex(forRhymeClass: phone.rhymeClassId)
        let b = RhymeHighlighterEngine.colorIndex(forRhymeClass: tone.rhymeClassId)
        let c = RhymeHighlighterEngine.colorIndex(forRhymeClass: alone.rhymeClassId)
        XCTAssertEqual(a, 2)
        XCTAssertEqual(a, b)
        XCTAssertEqual(b, c)
    }

    func testIHAlveolarStopFamilyGroupsMilitantSetAndExcludesBlink() {
        let shit = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["T"])
        let script = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["P", "T"])
        let commits = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["T", "S"])
        let militant = RhymeHighlighterEngine.PhoneticSignature(
            stressedVowel: "IH1",
            coda: ["L", "AH0", "T", "AH0", "N", "T"]
        )
        let blink = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["NG", "K"])
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "shit", signature: shit),
            RhymeHighlighterEngine.ihAlveolarStopClassId
        )
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "script", signature: script),
            RhymeHighlighterEngine.ihAlveolarStopClassId
        )
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "commits", signature: commits),
            RhymeHighlighterEngine.ihAlveolarStopClassId
        )
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "militant", signature: militant),
            RhymeHighlighterEngine.ihAlveolarStopClassId
        )
        XCTAssertNotEqual(
            RhymeHighlighterEngine.endGroupKey(for: "blink", signature: blink),
            RhymeHighlighterEngine.ihAlveolarStopClassId
        )
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "idiot", signature: blink, isLineEnd: false),
            RhymeHighlighterEngine.ihAlveolarStopClassId,
            "idiot is in the locked set even if the signature is wrong"
        )
    }

    func testDrakeRemixEndLandingsPaintAsOneFamily() async {
        let verse = """
        I got my brothers, they move militant
        I see the shots I ain't no idiot
        Eye over my shoulder like a immigrant
        Don't care what happens long as the plug commits
        No time for acting, can't pull up no script
        I pull they cards knew they was full of shit
        Just like a flush when I need some time to think
        Just like the watch baby it barely blink
        """
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: verse)
        let family = groups.first { group in
            let words = Set(group.words.map { $0.word.lowercased() })
            return words.contains("militant") && words.contains("shit")
        }
        XCTAssertNotNil(family, "militant…shit must share one paint group")
        let words = Set(family?.words.map { $0.word.lowercased() } ?? [])
        for w in ["militant", "idiot", "immigrant", "commits", "script", "shit"] {
            XCTAssertTrue(words.contains(w), "\(w) should lock into the family")
        }
        XCTAssertFalse(words.contains("blink"))
        XCTAssertFalse(words.contains("think"))
        XCTAssertGreaterThanOrEqual(highlights.count, 6)
    }

    // MARK: - Near rhymes the editor must paint (dummy/money, hip/dick, pretty/chelly)

    func testDummyAndMoneyShareFeminineYFamily() {
        let dummy = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "AH1", coda: ["M", "IY0"])
        let money = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "AH1", coda: ["N", "IY0"])
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "dummy", signature: dummy),
            RhymeHighlighterEngine.endGroupKey(for: "money", signature: money),
            "dummy/money are the same feminine -y near family"
        )
        XCTAssertNotEqual(
            RhymeHighlighterEngine.endGroupKey(for: "dummy", signature: dummy),
            dummy.rhymeClassId,
            "must not stay on the exact M-IY0 key or money will never join"
        )
    }

    func testHipAndDickShareStopFamily() {
        let hip = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["P"])
        let dick = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["K"])
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "hip", signature: hip),
            RhymeHighlighterEngine.endGroupKey(for: "dick", signature: dick),
            "hip/dick are the same short-I + stop near family"
        )
    }

    func testHipAndClipsShareStopFamilyAfterTrailingS() {
        let hip = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["P"])
        let clips = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["P", "S"])
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "hip", signature: hip),
            RhymeHighlighterEngine.endGroupKey(for: "clips", signature: clips),
            "clips is hip + plural S and must paint with hip"
        )
    }

    func testPrettyAndChellyShareFeminineYFamily() {
        let pretty = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["T", "IY0"])
        let chelly = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "EH1", coda: ["L", "IY0"])
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "pretty", signature: pretty),
            RhymeHighlighterEngine.endGroupKey(for: "chelly", signature: chelly),
            "pretty/chelly are a short-vowel feminine -y near rhyme"
        )
    }

    func testCrazyDoesNotJoinAbbeOnTrailingY() {
        let crazy = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "EY1", coda: ["Z", "IY0"])
        let abbe = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "AE1", coda: ["B", "IY0"])
        XCTAssertNotEqual(
            RhymeHighlighterEngine.endGroupKey(for: "crazy", signature: crazy),
            RhymeHighlighterEngine.endGroupKey(for: "abbe", signature: abbe),
            "unstressed -y alone must not glue every -y word together"
        )
    }

    func testCheatAndReachShareTchFamilyNotMount() {
        let cheat = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IY1", coda: ["T"])
        let reach = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IY1", coda: ["CH"])
        let teach = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IY1", coda: ["CH"])
        let mount = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "AW1", coda: ["N", "T"])
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "cheat", signature: cheat),
            RhymeHighlighterEngine.endGroupKey(for: "reach", signature: reach)
        )
        XCTAssertEqual(
            RhymeHighlighterEngine.endGroupKey(for: "teach", signature: teach),
            RhymeHighlighterEngine.endGroupKey(for: "reach", signature: reach)
        )
        XCTAssertNotEqual(
            RhymeHighlighterEngine.endGroupKey(for: "cheat", signature: cheat, isLineEnd: false),
            RhymeHighlighterEngine.endGroupKey(for: "mount", signature: mount, isLineEnd: true),
            "mid-bar cheat must not ride mount/amount's T landing"
        )
        XCTAssertNotNil(RhymeHighlighterEngine.rhymeScore(cheat, reach))
    }

    func testRepeatedLineEndSomePaintsAsEndRhyme() async {
        waitForDictionaryWord("cheat")
        XCTAssertNotNil(getGlobalCMUDICTStore()["cheat"])
        XCTAssertNotNil(getGlobalCMUDICTStore()["reach"])
        let text = "She wanted to cheat me some\nI hope you ain't reach in for some"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)
        let somes = groups.filter { group in
            group.words.filter { $0.word.lowercased() == "some" }.count >= 2
        }
        XCTAssertFalse(somes.isEmpty, "some / some on two line ends must paint")
        XCTAssertEqual(somes.first?.rhymeType, .endRhyme)
        let reachFamily = groups.first { g in
            Set(g.words.map { $0.word.lowercased() }).isSuperset(of: ["cheat", "reach"])
        }
        XCTAssertNotNil(reachFamily, "cheat and reach must highlight together")
        let reachHit = highlights.contains { h in
            Range(h.utf16, in: text).map { text[$0].lowercased().contains("reach") } ?? false
        }
        XCTAssertTrue(reachHit, "reach must receive a highlight span")
    }

    func testHipStopFamilyDoesNotSwallowShit() {
        let hip = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["P"])
        let shit = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "IH1", coda: ["T"])
        XCTAssertNotEqual(
            RhymeHighlighterEngine.endGroupKey(for: "hip", signature: hip),
            RhymeHighlighterEngine.endGroupKey(for: "shit", signature: shit),
            "P/K stops stay out of the locked T/D shit family"
        )
    }

    func testChellyHasPhonemesWhenMissingFromCMUDICT() {
        let phones = RhymeHighlighterEngine.phonemes(for: "chelly")
        XCTAssertNotNil(phones, "Chelly is OOV in CMUDICT and must still get a pronunciation")
        let sig = phones.flatMap { RhymeHighlighterEngine.extractSignature(from: $0) }
        XCTAssertEqual(String(sig?.stressedVowel.filter { !$0.isNumber } ?? ""), "EH")
        XCTAssertTrue(sig?.coda.contains(where: { $0.hasPrefix("IY") }) ?? false)
    }

    func testGirlAndWorldShareAConsonantTail() {
        let girl = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "ER1", coda: ["L"])
        let world = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "ER1", coda: ["L", "D"])
        XCTAssertEqual(RhymeHighlighterEngine.rhymeScore(girl, world), .near)
        let man = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "AE1", coda: ["N"])
        let manage = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "AE1", coda: ["N", "AH0", "JH"])
        XCTAssertNil(
            RhymeHighlighterEngine.rhymeScore(man, manage),
            "an extra vowel is another syllable, not a girl/world tail"
        )
        let go = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "OW1", coda: [])
        let goat = RhymeHighlighterEngine.PhoneticSignature(stressedVowel: "OW1", coda: ["T"])
        XCTAssertEqual(
            RhymeHighlighterEngine.rhymeScore(go, goat),
            .assonance,
            "an empty coda is assonance, not the consonant-tail rhyme"
        )
    }

    func testEightRhymesWithHateAndDate() async {
        waitForDictionaryWord("hate")
        XCTAssertNotNil(getGlobalCMUDICTStore()["hate"])
        XCTAssertNotNil(getGlobalCMUDICTStore()["date"])
        let eight = RhymeHighlighterEngine.phonemes(for: "8")
        XCTAssertEqual(eight, RhymeHighlighterEngine.phonemes(for: "eight"))
        let text = "I date woman born after 9 8\nI can't switch out love for no dam hate"
        let (groups, _) = await RhymeHighlighterEngine.computeAll(text: text)
        func color(_ word: String) -> Int? {
            groups.first { group in group.words.contains { $0.word == word } }?.colorIndex
        }
        XCTAssertNotNil(color("8"), "8 must paint, groups \(groups.map { $0.words.map(\.word) })")
        XCTAssertEqual(color("8"), color("hate"))
        XCTAssertEqual(
            color("date"),
            color("hate"),
            "groups \(groups.map { ($0.words.map(\.word), $0.key, $0.strength) })"
        )
        XCTAssertNotEqual(color("9"), color("hate"))
    }

    func testWorldAndGirlPaintAsAnInnerRhyme() async {
        waitForDictionaryWord("world")
        XCTAssertNotNil(getGlobalCMUDICTStore()["world"])
        let text = "Money run the world took my girl out to Bombay"
        let (groups, _) = await RhymeHighlighterEngine.computeAll(text: text)
        let family = groups.first { group in
            let words = Set(group.words.map(\.word))
            return words.contains("world") && words.contains("girl")
        }
        XCTAssertNotNil(family, "world/girl must share a group, got \(groups.map { $0.words.map(\.word) })")
    }

    func testBurningBridgesNearRhymesPaintTogether() async {
        let verse = """
        You looking dummy with the money got a gun on my hip
        Ain't nothing to tell me when drop down my
        clips
        Pretty girl Chelly, she stay on my dick
        She was a dancer birthday in cancer
        """
        let (groups, _) = await RhymeHighlighterEngine.computeAll(text: verse)
        func groupWords(containing word: String) -> Set<String> {
            let hit = groups.first { group in
                group.words.contains { $0.word.lowercased() == word }
            }
            return Set(hit?.words.map { $0.word.lowercased() } ?? [])
        }
        let dummyFamily = groupWords(containing: "dummy")
        XCTAssertTrue(dummyFamily.contains("money"), "dummy must paint with money")
        let hipFamily = groupWords(containing: "hip")
        XCTAssertTrue(hipFamily.contains("dick"), "hip must paint with dick")
        XCTAssertTrue(hipFamily.contains("clips"), "hip must paint with clips")
        let prettyFamily = groupWords(containing: "pretty")
        XCTAssertTrue(prettyFamily.contains("chelly"), "pretty must paint with Chelly")
        let dancerFamily = groupWords(containing: "dancer")
        XCTAssertTrue(dancerFamily.contains("cancer"), "dancer/cancer perfect rhyme still paints")
    }

    // MARK: - End vs internal rhyme highlighting

    func testCrossLineLineEndRhymesAreEndRhyme() async {
        let text = "dummy\nmoney"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)
        let family = rhymeGroup(in: groups, containing: ["dummy", "money"])
        XCTAssertNotNil(family, "dummy/money line-ends must form a group")
        XCTAssertEqual(rhymeTypeName(family?.rhymeType), "endRhyme")
        let dummy = family?.words.first { $0.word.lowercased() == "dummy" }
        let money = family?.words.first { $0.word.lowercased() == "money" }
        XCTAssertEqual(dummy?.isLineEnd, true)
        XCTAssertEqual(money?.isLineEnd, true)
        XCTAssertFalse(
            groups.contains { isInternalRhyme($0.rhymeType) && groupWords($0).contains("dummy") },
            "cross-line dummy must not also sit in an internal group"
        )
        XCTAssertFalse(
            groups.contains { isInternalRhyme($0.rhymeType) && groupWords($0).contains("money") },
            "cross-line money must not also sit in an internal group"
        )
        let dummyHighlight = highlight(in: highlights, covering: nsRange(of: "dummy", in: text, occurrence: 0))
        let moneyHighlight = highlight(in: highlights, covering: nsRange(of: "money", in: text, occurrence: 0))
        XCTAssertEqual(rhymeTypeName(dummyHighlight?.rhymeType), "endRhyme")
        XCTAssertEqual(rhymeTypeName(moneyHighlight?.rhymeType), "endRhyme")
    }

    func testSameLineNonEndRhymesAreInternalRhyme() async {
        let text = "I flip money dummy cash\n"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)
        let family = rhymeGroup(in: groups, containing: ["dummy", "money"])
        XCTAssertNotNil(family, "money/dummy on the same line must form a group")
        XCTAssertEqual(rhymeTypeName(family?.rhymeType), "internalRhyme")
        XCTAssertFalse(groupWords(family).contains("cash"), "line-end cash must not join dummy/money")
        let dummy = family?.words.first { $0.word.lowercased() == "dummy" }
        let money = family?.words.first { $0.word.lowercased() == "money" }
        XCTAssertEqual(dummy?.isLineEnd, false, "dummy is mid-line; cash is the line end")
        XCTAssertEqual(money?.isLineEnd, false, "money is mid-line; cash is the line end")
        let dummyHighlight = highlight(in: highlights, covering: nsRange(of: "dummy", in: text, occurrence: 0))
        let moneyHighlight = highlight(in: highlights, covering: nsRange(of: "money", in: text, occurrence: 0))
        XCTAssertEqual(rhymeTypeName(dummyHighlight?.rhymeType), "internalRhyme")
        XCTAssertEqual(rhymeTypeName(moneyHighlight?.rhymeType), "internalRhyme")
    }

    func testCashDummyMoneySameLineIsInternalForMidWord() async {
        let text = "cash dummy money"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)
        let family = rhymeGroup(in: groups, containing: ["dummy", "money"])
        XCTAssertNotNil(family, "dummy/money on one line must form a group")
        XCTAssertEqual(rhymeTypeName(family?.rhymeType), "internalRhyme")
        XCTAssertFalse(groupWords(family).contains("cash"), "cash does not rhyme with dummy/money")
        let dummy = family?.words.first { $0.word.lowercased() == "dummy" }
        let money = family?.words.first { $0.word.lowercased() == "money" }
        XCTAssertEqual(dummy?.isLineEnd, false, "dummy is mid-line")
        XCTAssertEqual(money?.isLineEnd, true, "money is the line-end word")
        XCTAssertEqual(dummy?.lineIndex, 0)
        XCTAssertEqual(money?.lineIndex, 0)
        let dummyHighlight = highlight(in: highlights, covering: nsRange(of: "dummy", in: text, occurrence: 0))
        XCTAssertEqual(
            rhymeTypeName(dummyHighlight?.rhymeType),
            "internalRhyme",
            "mid-line dummy must paint as internal vs the line-end"
        )
    }

    func testLineEndEndGroupSpanIsNotDuplicatedAsInternal() async {
        let text = "I flip dummy money\nLooking dummy"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: text)
        let endFamily = groups.first { group in
            isEndRhyme(group.rhymeType)
                && group.words.contains { $0.word.lowercased() == "money" && $0.isLineEnd }
                && group.words.contains { $0.word.lowercased() == "dummy" && $0.isLineEnd }
        }
        XCTAssertNotNil(endFamily, "line-end dummy/money across lines must form an end group")
        XCTAssertEqual(rhymeTypeName(endFamily?.rhymeType), "endRhyme")

        let endMembers = (endFamily?.words ?? []).filter(\.isLineEnd)
        XCTAssertFalse(endMembers.isEmpty)

        for group in groups where isInternalRhyme(group.rhymeType) {
            for word in group.words {
                let duplicated = endMembers.contains {
                    $0.word.lowercased() == word.word.lowercased()
                        && $0.lineIndex == word.lineIndex
                        && $0.isLineEnd
                }
                XCTAssertFalse(
                    duplicated,
                    "line-end end-group span \(word.word) on line \(word.lineIndex) must not also be internal"
                )
            }
        }

        let moneyRange = nsRange(of: "money", in: text, occurrence: 0)
        let lineEndDummyRange = nsRange(of: "dummy", in: text, occurrence: 1)
        let moneyHits = highlights.filter { $0.utf16 == moneyRange }
        let dummyHits = highlights.filter { $0.utf16 == lineEndDummyRange }
        XCTAssertEqual(moneyHits.count, 1, "line-end money must paint once")
        XCTAssertEqual(dummyHits.count, 1, "line-end dummy must paint once")
        XCTAssertEqual(rhymeTypeName(moneyHits.first?.rhymeType), "endRhyme")
        XCTAssertEqual(rhymeTypeName(dummyHits.first?.rhymeType), "endRhyme")
        XCTAssertFalse(moneyHits.contains { isInternalRhyme($0.rhymeType) })
        XCTAssertFalse(dummyHits.contains { isInternalRhyme($0.rhymeType) })
    }

    func testDummyMoneyLineIndicesFollowLineBreaks() async {
        let text = "dummy\nmoney"
        let (groups, _) = await RhymeHighlighterEngine.computeAll(text: text)
        let family = rhymeGroup(in: groups, containing: ["dummy", "money"])
        XCTAssertNotNil(family, "dummy/money must form a group")
        let dummy = family?.words.first { $0.word.lowercased() == "dummy" }
        let money = family?.words.first { $0.word.lowercased() == "money" }
        XCTAssertEqual(dummy?.lineIndex, 0, "first line is index 0")
        XCTAssertEqual(money?.lineIndex, 1, "word after the newline is index 1")
    }

    func testTokenizeIncludesInProgressWordBeforeSpace() {
        let mid = "dummy money"
        let tokensMid = RhymeHighlighterEngine.tokenizeWords(in: mid)
        XCTAssertTrue(tokensMid.map(\.0).contains("money"))

        let typing = "dummy mone"
        let tokensTyping = RhymeHighlighterEngine.tokenizeWords(in: typing)
        XCTAssertEqual(tokensTyping.last?.0, "mone")
        XCTAssertEqual(String(typing[tokensTyping.last!.1]), "mone")
    }

    func testTokenizeDoesNotDuplicateWordAfterSpace() {
        let spaced = "dummy money "
        let tokens = RhymeHighlighterEngine.tokenizeWords(in: spaced)
        XCTAssertEqual(tokens.filter { $0.0 == "money" }.count, 1)
        XCTAssertNil(RhymeHighlighterEngine.trailingInProgressWord(in: spaced))
    }

    func testLiveTrailingHighlightPaintsBeforeSpace() async {
        let done = "dummy money"
        let (groups, highlights) = await RhymeHighlighterEngine.computeAll(text: done)
        XCTAssertFalse(groups.isEmpty, "dummy/money must form a group")
        let typing = "dummy mone"
        let live = RhymeHighlighterEngine.liveTrailingHighlight(
            in: typing,
            existing: [],
            groups: groups
        )
        XCTAssertNotNil(live, "in-progress 'mone' should pick up dummy's color before space")
        XCTAssertEqual(live?.colorIndex, highlights.first?.colorIndex)
        let covered = RhymeHighlighterEngine.liveTrailingHighlight(
            in: done,
            existing: highlights,
            groups: groups
        )
        XCTAssertNil(covered, "already-painted last word should not double-highlight")
    }

    // MARK: - End/internal helpers

    private func rhymeGroup(
        in groups: [RhymeHighlighterEngine.RhymeGroup],
        containing words: Set<String>
    ) -> RhymeHighlighterEngine.RhymeGroup? {
        groups.first { words.isSubset(of: groupWords($0)) }
    }

    private func groupWords(_ group: RhymeHighlighterEngine.RhymeGroup?) -> Set<String> {
        Set(group?.words.map { $0.word.lowercased() } ?? [])
    }

    private func isEndRhyme(_ type: RhymeHighlighterEngine.RhymeType) -> Bool {
        switch type {
        case .endRhyme: return true
        default: return false
        }
    }

    private func isInternalRhyme(_ type: RhymeHighlighterEngine.RhymeType) -> Bool {
        switch type {
        case .internalRhyme: return true
        default: return false
        }
    }

    private func rhymeTypeName(_ type: RhymeHighlighterEngine.RhymeType?) -> String {
        guard let type else { return "nil" }
        switch type {
        case .endRhyme: return "endRhyme"
        case .internalRhyme: return "internalRhyme"
        case .alliteration: return "alliteration"
        case .assonance: return "assonance"
        case .geniusEcho: return "geniusEcho"
        case .holdPulseYellow: return "holdPulseYellow"
        case .holdPulseGreen: return "holdPulseGreen"
        }
    }

    private func nsRange(of needle: String, in text: String, occurrence: Int) -> NSRange {
        let ns = text as NSString
        var search = NSRange(location: 0, length: ns.length)
        var seen = 0
        while search.length > 0 {
            let found = ns.range(of: needle, options: .caseInsensitive, range: search)
            guard found.location != NSNotFound else { return found }
            if seen == occurrence { return found }
            seen += 1
            let loc = found.location + found.length
            search = NSRange(location: loc, length: ns.length - loc)
        }
        return NSRange(location: NSNotFound, length: 0)
    }

    private func highlight(in highlights: [Highlight], covering range: NSRange) -> Highlight? {
        highlights.first { $0.utf16 == range }
    }
}
