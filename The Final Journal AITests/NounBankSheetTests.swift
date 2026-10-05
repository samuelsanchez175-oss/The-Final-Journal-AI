import SwiftUI
import XCTest
@testable import XJournal_AI

final class NounBankSheetTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: NounBankRecents.defaultsKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: NounBankRecents.defaultsKey)
        super.tearDown()
    }

    func testGlobalSearchFindsPeopleFromAnyTab() {
        let tabs: [NounBankCategory] = [.liquors, .guns, .clothing]
        for selected in tabs {
            let johnny = NounBankSearch.hits(query: "Johnny Dang", selected: selected)
            XCTAssertTrue(
                johnny.contains {
                    $0.item.insertWord.localizedCaseInsensitiveCompare("Johnny Dang") == .orderedSame
                        && $0.category == .jewelers
                },
                "Johnny Dang should match from \(selected.rawValue)"
            )

            let wheezy = NounBankSearch.hits(query: "Wheezy", selected: selected)
            XCTAssertTrue(
                wheezy.contains {
                    $0.item.insertWord.localizedCaseInsensitiveCompare("Wheezy") == .orderedSame
                        && $0.category == .producers
                },
                "Wheezy should match from \(selected.rawValue)"
            )

            let unfoonk = NounBankSearch.hits(query: "Unfoonk", selected: selected)
            XCTAssertTrue(
                unfoonk.contains {
                    $0.item.insertWord.localizedCaseInsensitiveCompare("Unfoonk") == .orderedSame
                        && $0.category == .artists
                },
                "Unfoonk should match from \(selected.rawValue)"
            )
        }
    }

    func testEmptyQueryStaysInSelectedCategory() {
        let hits = NounBankSearch.hits(query: "", selected: .liquors)
        XCTAssertFalse(hits.contains {
            $0.item.insertWord.localizedCaseInsensitiveCompare("Johnny Dang") == .orderedSame
        })
        XCTAssertTrue(hits.allSatisfy { $0.category == .liquors })
    }

    func testGroupsCoverEveryCategoryOnce() {
        let grouped = NounBankGroup.allCases.flatMap(\.categories)
        XCTAssertEqual(Set(grouped), Set(NounBankCategory.allCases))
        XCTAssertEqual(grouped.count, NounBankCategory.allCases.count)
        XCTAssertEqual(NounBankGroup.containing(.liquors), .liquids)
        XCTAssertEqual(NounBankGroup.containing(.jewelers), .ice)
        XCTAssertEqual(NounBankGroup.containing(.brands), .wear)
        XCTAssertEqual(NounBankGroup.containing(.cars), .vehicles)
        XCTAssertEqual(NounBankGroup.containing(.boats), .vehicles)
        XCTAssertEqual(NounBankGroup.containing(.aviation), .vehicles)
        XCTAssertEqual(NounBankGroup.containing(.military), .vehicles)
        XCTAssertEqual(NounBankGroup.containing(.artists), .people)
        XCTAssertEqual(NounBankGroup.containing(.producers), .people)
        XCTAssertEqual(NounBankGroup.containing(.celebs), .people)
        XCTAssertEqual(NounBankGroup.containing(.characters), .people)
        XCTAssertEqual(NounBankGroup.containing(.nba), .athletes)
        XCTAssertEqual(NounBankGroup.containing(.nfl), .athletes)
        XCTAssertEqual(NounBankGroup.containing(.boxing), .athletes)
        XCTAssertEqual(NounBankGroup.containing(.sports), .athletes)
        XCTAssertEqual(NounBankGroup.containing(.animals), .animals)
        XCTAssertEqual(NounBankGroup.containing(.insects), .animals)
        XCTAssertEqual(NounBankGroup.containing(.food), .food)
        XCTAssertEqual(NounBankGroup.containing(.grills), .ice)
        XCTAssertEqual(NounBankGroup.containing(.hair), .wear)
        XCTAssertEqual(NounBankGroup.containing(.nails), .wear)
        XCTAssertEqual(NounBankGroup.containing(.tattoos), .wear)
        XCTAssertEqual(NounBankGroup.containing(.lingerie), .wear)
        XCTAssertEqual(NounBankGroup.containing(.toys), .wear)
        XCTAssertEqual(NounBankGroup.containing(.twerk), .street)
        XCTAssertEqual(NounBankGroup.containing(.streets), .street)
        XCTAssertEqual(NounBankGroup.containing(.kingpin), .street)
        XCTAssertEqual(NounBankGroup.containing(.trapLife), .street)
        XCTAssertEqual(NounBankGroup.containing(.paranoia), .street)
        XCTAssertEqual(NounBankGroup.containing(.flowers), .flowers)
        XCTAssertEqual(NounBankGroup.containing(.wrestlers), .athletes)
        XCTAssertEqual(NounBankGroup.containing(.actors), .people)
        XCTAssertEqual(NounBankGroup.containing(.streamers), .people)
        XCTAssertEqual(NounBankGroup.containing(.substances), .liquids)
        XCTAssertEqual(NounBankGroup.containing(.religion), .people)
        XCTAssertEqual(NounBankGroup.containing(.feelings), .feelings)
        XCTAssertEqual(NounBankGroup.containing(.friends), .people)
        XCTAssertEqual(NounBankGroup.containing(.events), .people)
        XCTAssertEqual(NounBankGroup.containing(.games), .games)
        XCTAssertEqual(NounBankGroup.containing(.apps), .apps)
        XCTAssertEqual(NounBankGroup.containing(.looks), .looks)
        XCTAssertEqual(NounBankGroup.food.categories, [.food])
        XCTAssertEqual(NounBankGroup.ice.categories, [.jewelry, .grills, .jewelers, .money])
        XCTAssertEqual(NounBankGroup.wear.categories, [.brands, .clothing, .hair, .nails, .tattoos, .lingerie, .toys])
        XCTAssertEqual(
            NounBankGroup.street.categories,
            [.guns, .kill, .opps, .places, .woman, .twerk, .streets, .kingpin, .trapLife, .paranoia]
        )
        XCTAssertEqual(NounBankGroup.games.categories, [.games])
        XCTAssertEqual(NounBankGroup.apps.categories, [.apps])
        XCTAssertEqual(NounBankGroup.looks.categories, [.looks])
        XCTAssertEqual(NounBankGroup.flowers.categories, [.flowers])
        XCTAssertEqual(NounBankGroup.feelings.categories, [.feelings])
        XCTAssertEqual(NounBankGroup.liquids.categories, [.liquors, .syrups, .drugs, .substances])
        XCTAssertEqual(
            NounBankGroup.people.categories,
            [.family, .friends, .producers, .artists, .celebs, .events, .characters, .actors, .streamers, .religion]
        )
        XCTAssertEqual(
            NounBankGroup.athletes.categories,
            [.nba, .nfl, .boxing, .sports, .wrestlers]
        )
        XCTAssertEqual(NounBankGroup.containing(.phrases), .phrases)
        XCTAssertEqual(NounBankGroup.containing(.wordplay), .wordplay)
        XCTAssertEqual(NounBankGroup.wordplay.categories, [.wordplay])
    }

    func testSwipeStepsInsideTheGroupAndStopsAtTheEnds() {
        XCTAssertEqual(NounBankGroup.liquids.category(steppedBy: 1, from: .liquors), .syrups)
        XCTAssertEqual(NounBankGroup.liquids.category(steppedBy: 1, from: .syrups), .drugs)
        XCTAssertEqual(NounBankGroup.liquids.category(steppedBy: 1, from: .drugs), .substances)
        XCTAssertNil(NounBankGroup.liquids.category(steppedBy: 1, from: .substances))
        XCTAssertEqual(NounBankGroup.liquids.category(steppedBy: -1, from: .syrups), .liquors)
        XCTAssertNil(NounBankGroup.liquids.category(steppedBy: -1, from: .liquors))
        XCTAssertEqual(NounBankGroup.people.category(steppedBy: 1, from: .family), .friends)
        XCTAssertEqual(NounBankGroup.people.category(steppedBy: 1, from: .streamers), .religion)
        XCTAssertNil(NounBankGroup.people.category(steppedBy: 1, from: .religion))
        XCTAssertNil(NounBankGroup.people.category(steppedBy: -1, from: .family))
        XCTAssertNil(NounBankGroup.food.category(steppedBy: 1, from: .food))
        XCTAssertNil(NounBankGroup.liquids.category(steppedBy: 1, from: .family))
    }

    func testRecentsCapAtEightAndStayUnique() {
        let words = NounBankCatalog.items(for: .liquors).prefix(9).map(\.insertWord)
        XCTAssertEqual(words.count, 9)

        for word in words {
            NounBankRecents.record(word: word, category: .liquors)
        }
        XCTAssertEqual(NounBankRecents.items.count, 8)
        XCTAssertEqual(NounBankRecents.items.first?.word, words.last)
        XCTAssertFalse(NounBankRecents.items.contains { $0.word == words.first })

        NounBankRecents.record(word: words[8], category: .liquors)
        XCTAssertEqual(NounBankRecents.items.count, 8)
        XCTAssertEqual(
            NounBankRecents.items.filter {
                $0.word.localizedCaseInsensitiveCompare(words[8]) == .orderedSame
            }.count,
            1
        )

        NounBankRecents.record(word: words[2], category: .liquors)
        XCTAssertEqual(NounBankRecents.items.first?.word, words[2])
        XCTAssertEqual(
            NounBankRecents.items.filter { $0.word == words[2] }.count,
            1
        )
        XCTAssertEqual(NounBankRecents.items.count, 8)
    }

    func testKobeMentionPhrasesIncludeOtherNames() throws {
        let kobe = try XCTUnwrap(NounBankCatalog.items(for: .nba).first {
            $0.insertWord.localizedCaseInsensitiveCompare("Kobe") == .orderedSame
        })
        let folded = NounBankCatalog.mentionPhrases(for: kobe).map {
            $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        }
        XCTAssertTrue(folded.contains("kobe"))
        XCTAssertTrue(folded.contains("mamba"))
        XCTAssertTrue(folded.contains("black mamba"))
    }

    func testRedBottomsStayAShoeAndNotAPlace() throws {
        let shoe = try XCTUnwrap(NounBankCatalog.items(for: .brands).first {
            $0.insertWord.localizedCaseInsensitiveCompare("red bottoms") == .orderedSame
        })
        let folded = NounBankCatalog.mentionPhrases(for: shoe).map {
            $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        }
        XCTAssertTrue(folded.contains("red bottoms"))
        XCTAssertTrue(folded.contains("louboutin"))
        XCTAssertTrue(folded.contains("loubs"))
        for place in ["hood", "southside", "northside", "eastside", "westside", "downtown", "bottoms"] {
            XCTAssertFalse(folded.contains(place), place)
        }

        let places = NounBankMark.familyAliases(for: "southside").map {
            $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        }
        XCTAssertTrue(places.contains("eastside"))
        XCTAssertTrue(places.contains("westside"))
        XCTAssertTrue(places.contains("northside"))
        XCTAssertFalse(places.contains("bottoms"))
        XCTAssertFalse(places.contains("red bottoms"))
        XCTAssertFalse(places.contains("louboutin"))
    }

    func testSpecificNounsDoNotInheritBroadWords() {
        let ace = NounBankMark.familyAliases(for: "Ace of Spades").map { $0.lowercased() }
        XCTAssertTrue(ace.contains("ace of spades"))
        XCTAssertFalse(ace.contains("ace"))

        let glock = NounBankMark.familyAliases(for: "Glock").map { $0.lowercased() }
        XCTAssertTrue(glock.contains("glock"))
        XCTAssertFalse(glock.contains("switch"))

        let wayne = NounBankMark.familyAliases(for: "Lil Wayne").map { $0.lowercased() }
        XCTAssertTrue(wayne.contains("lil wayne"))
        XCTAssertFalse(wayne.contains("wayne"))

        let oblock = NounBankMark.familyAliases(for: "O-Block").map { $0.lowercased() }
        XCTAssertTrue(oblock.contains("o block"))
        XCTAssertFalse(oblock.contains("block"))

        let nike = NounBankMark.familyAliases(for: "Nike").map { $0.lowercased() }
        XCTAssertTrue(nike.contains("nike"))
        XCTAssertFalse(nike.contains("jordan"))

        XCTAssertTrue(NounBankMark.familyAliases(for: "Louis pouch").isEmpty)

        let xanax = NounBankMark.familyAliases(for: "Xanax").map { $0.lowercased() }
        XCTAssertFalse(xanax.contains("xbox"))
    }

    func testReferenceLinesSortByArtistThenAlbum() {
        func row(_ id: String, _ artist: String, _ song: String, _ line: String) -> BarHitsCatalogStore.Row {
            BarHitsCatalogStore.Row(
                id: id,
                line: line,
                artist: artist,
                song: song,
                syllables: 8,
                endWord: "line",
                phoneticClass: ""
            )
        }
        let sections = NounMentionOrder.sections([
            row("herbo", "G Herbo", "Yerk 30", "later"),
            row("take", "Drake", "Take Care", "middle"),
            row("scorpion", "Drake", "Scorpion", "before take care"),
            row("ten", "03 Greedo", "10 Times", "after two"),
            row("two", "03 Greedo", "2 Sexy", "first song"),
            row("game", "The Game", "Documentary", "with the g names"),
        ])
        XCTAssertEqual(sections.map(\.name), ["03 Greedo", "Drake", "G Herbo", "The Game"])
        XCTAssertEqual(sections[0].songs.map(\.title), ["2 Sexy", "10 Times"])
        XCTAssertEqual(sections[1].songs.map(\.title), ["Scorpion", "Take Care"])
        XCTAssertEqual(sections[0].songs[0].rows.map(\.id), ["two"])
    }

    func testScrubberJumpsToTheArtistLetter() {
        func row(_ id: String, _ artist: String, _ song: String) -> BarHitsCatalogStore.Row {
            BarHitsCatalogStore.Row(
                id: id,
                line: "line",
                artist: artist,
                song: song,
                syllables: 8,
                endWord: "line",
                phoneticClass: ""
            )
        }
        let sections = NounMentionOrder.sections([
            row("herbo", "G Herbo", "Yerk 30"),
            row("take", "Drake", "Take Care"),
            row("ten", "03 Greedo", "10 Times"),
            row("game", "The Game", "Documentary"),
        ])
        XCTAssertEqual(NounMentionOrder.indexLetter(forArtistKey: sections[0].id), "#")
        XCTAssertEqual(NounMentionOrder.indexLetter(forArtistKey: sections[1].id), "D")
        XCTAssertEqual(NounMentionOrder.indexLetter(forArtistKey: sections[2].id), "G")
        XCTAssertEqual(NounMentionOrder.indexLetter(forArtistKey: sections[3].id), "G")
        XCTAssertEqual(NounMentionOrder.leadingIndexLetter(for: sections[0].id, in: sections), "#")
        XCTAssertEqual(NounMentionOrder.leadingIndexLetter(for: sections[1].id, in: sections), "D")
        XCTAssertEqual(NounMentionOrder.leadingIndexLetter(for: sections[2].id, in: sections), "G")
        XCTAssertNil(NounMentionOrder.leadingIndexLetter(for: sections[3].id, in: sections))
    }

    func testHighlightMarksTheNounAndLeavesNearbyWords() {
        let marked = NounMentionHighlight.mark(
            "Eatin' seafood out in Bel-Air, sippin' Belaire",
            phrases: ["Belaire", "Luc Belaire"]
        )
        var highlighted = ""
        for run in marked.runs where run.backgroundColor != nil {
            highlighted += String(marked[run.range].characters)
        }
        XCTAssertEqual(highlighted, "Belaire")
    }

    func testHennyMentionPhrasesIncludeHennessy() throws {
        let henny = try XCTUnwrap(NounBankCatalog.items(for: .liquors).first {
            $0.insertWord.localizedCaseInsensitiveCompare("Henny") == .orderedSame
        })
        let folded = NounBankCatalog.mentionPhrases(for: henny).map {
            $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        }
        XCTAssertTrue(folded.contains { $0.contains("hennessy") })
    }

    func testMentionMatchQuotesLongerNamesFirst() {
        XCTAssertEqual(
            BarHitsCatalogStore.mentionMatch(phrases: ["Kobe", "black mamba", "Kobe"]),
            "\"black mamba\" OR \"kobe\""
        )
        XCTAssertEqual(
            BarHitsCatalogStore.mentionMatch(phrases: ["Wayne"], excluding: ["John Wayne"]),
            "(\"wayne\") NOT (\"john wayne\")"
        )
        XCTAssertEqual(
            BarHitsCatalogStore.mentionMatch(phrases: ["QuikTrip"], also: ["quick trip"]),
            "(\"quiktrip\") AND (\"quick trip\")"
        )
        XCTAssertEqual(
            BarHitsCatalogStore.mentionMatch(phrases: ["dial tone"], excluding: ["dove"], also: ["soap"]),
            "((\"dial tone\") AND (\"soap\")) NOT (\"dove\")"
        )
    }

    func testJohnWayneStaysOffLilWayneAndOtherHighCountMixesSplit() throws {
        XCTAssertTrue(NounBankStore.words(for: .celebs).contains("John Wayne"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Wayne"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Odd Future"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("A$AP Rocky"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("A$AP Ferg"))
        XCTAssertTrue(NounBankStore.words(for: .sports).contains("Sammy Sosa"))
        XCTAssertTrue(NounBankStore.words(for: .guns).contains("Uzi"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("demon time"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("Jet Life"))

        let lilWayne = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "Wayne" })
        let john = try XCTUnwrap(NounBankCatalog.items(for: .celebs).first { $0.insertWord == "John Wayne" })
        XCTAssertEqual(lilWayne.family, "wayne")
        XCTAssertEqual(john.family, "john wayne")
        XCTAssertNotEqual(john.family, lilWayne.family)
        XCTAssertEqual(john.icon, "noun-celeb-john-wayne")
        let wayneOff = NounBankCatalog.mentionExclusions(for: lilWayne, category: .artists).map { $0.lowercased() }
        XCTAssertTrue(wayneOff.contains("john wayne"))
        XCTAssertTrue(wayneOff.contains("bruce wayne"))
        XCTAssertTrue(wayneOff.contains("wayne gretzky"))
        XCTAssertFalse(NounBankMark.familyAliases(for: "Lil Wayne").map { $0.lowercased() }.contains("wayne"))

        let batman = try XCTUnwrap(NounBankCatalog.items(for: .characters).first { $0.insertWord == "Batman" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: batman, category: .characters).map { $0.lowercased() }.contains("bruce wayne"))
        let gretzky = try XCTUnwrap(NounBankCatalog.items(for: .sports).first { $0.insertWord == "Gretzky" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: gretzky, category: .sports).map { $0.lowercased() }.contains("wayne gretzky"))
        let yachty = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "Lil Yachty" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: yachty, category: .artists).map { $0.lowercased() }.contains("lil boat"))

        let boat = try XCTUnwrap(NounBankCatalog.items(for: .boats).first { $0.insertWord == "boat" })
        let boatOff = NounBankCatalog.mentionExclusions(for: boat, category: .boats).map { $0.lowercased() }
        XCTAssertTrue(boatOff.contains("lil boat"))
        XCTAssertTrue(boatOff.contains("love boat"))

        let jet = try XCTUnwrap(NounBankCatalog.items(for: .aviation).first { $0.insertWord == "jet" })
        let jetOff = NounBankCatalog.mentionExclusions(for: jet, category: .aviation).map { $0.lowercased() }
        XCTAssertTrue(jetOff.contains("jet li"))
        XCTAssertTrue(jetOff.contains("jet ski"))
        XCTAssertTrue(jetOff.contains("jet life"))

        let artistUzi = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "Uzi" })
        let gunUzi = try XCTUnwrap(NounBankCatalog.items(for: .guns).first { $0.insertWord == "Uzi" })
        XCTAssertEqual(gunUzi.icon, "noun-gun-uzi")
        XCTAssertEqual(artistUzi.icon, "noun-artist-uzi")
        XCTAssertNotEqual(gunUzi.icon, artistUzi.icon)
        let gunPhrases = NounBankCatalog.mentionPhrases(for: gunUzi, category: .guns).map { $0.lowercased() }
        XCTAssertEqual(gunPhrases, ["the uzi", "a uzi", "an uzi", "my uzi"])
        XCTAssertFalse(gunPhrases.contains("lil uzi"))
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: artistUzi, category: .artists).map { $0.lowercased() }.contains("the uzi"))

        let future = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "Future" })
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: future, category: .artists).map { $0.lowercased() }.contains("odd future"))
        let sosa = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "Sosa" })
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: sosa, category: .artists).map { $0.lowercased() }.contains("sammy sosa"))
        let keys = try XCTUnwrap(NounBankCatalog.items(for: .cars).first { $0.insertWord == "keys" })
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: keys, category: .cars).map { $0.lowercased() }.contains("alicia keys"))

        let mud = try XCTUnwrap(NounBankCatalog.items(for: .substances).first { $0.insertWord == "mud" })
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: mud, category: .substances).map { $0.lowercased() }.contains("the mud"))
        let outTheMud = try XCTUnwrap(NounBankCatalog.items(for: .phrases).first { $0.insertWord == "out the mud" })
        let comeUp = NounBankCatalog.mentionPhrases(for: outTheMud, category: .phrases).map { $0.lowercased() }
        XCTAssertTrue(comeUp.contains("from the mud"))
        XCTAssertTrue(comeUp.contains("outta the mud"))
        let og = try XCTUnwrap(NounBankCatalog.items(for: .friends).first { $0.insertWord == "og" })
        let ogOff = NounBankCatalog.mentionExclusions(for: og, category: .friends).map { $0.lowercased() }
        XCTAssertTrue(ogOff.contains("og kush"))
        XCTAssertTrue(ogOff.contains("og gas"))
        let block = try XCTUnwrap(NounBankCatalog.items(for: .places).first { $0.insertWord == "block" })
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: block, category: .places).map { $0.lowercased() }.contains("cell block"))
        let hood = try XCTUnwrap(NounBankCatalog.items(for: .places).first { $0.insertWord == "hood" })
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: hood, category: .places).map { $0.lowercased() }.contains("under the hood"))
        let rocky = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "A$AP Rocky" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: rocky, category: .artists).map { $0.lowercased() }.contains("asap rocky"))
        let ferg = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "A$AP Ferg" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: ferg, category: .artists).map { $0.lowercased() }.contains("asap ferg"))

        let url = URL(fileURLWithPath: "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/bar-hits-catalog/BarHitsCatalog.sqlite")
        try XCTSkipIf(!FileManager.default.fileExists(atPath: url.path))
        let store = try BarHitsCatalogStore(databaseURL: url)
        let phrases = NounBankCatalog.mentionPhrases(for: lilWayne, category: .artists)
        let excluding = NounBankCatalog.mentionExclusions(for: lilWayne, category: .artists)
        XCTAssertLessThan(
            store.mentionCount(phrases: phrases, excluding: excluding),
            store.mentionCount(phrases: phrases)
        )
        let johnCount = store.mentionCount(phrases: ["john wayne"])
        XCTAssertGreaterThanOrEqual(johnCount, 12)
        XCTAssertEqual(
            store.mentionCount(phrases: ["wayne"]) - store.mentionCount(phrases: ["wayne"], excluding: ["john wayne"]),
            johnCount
        )
        XCTAssertLessThan(
            store.mentionCount(phrases: ["mud"], excluding: ["the mud"]),
            store.mentionCount(phrases: ["mud"])
        )
        XCTAssertGreaterThanOrEqual(store.mentionCount(phrases: ["from the mud"]), 12)
        XCTAssertLessThan(
            store.mentionCount(phrases: ["og"], excluding: ["og kush", "og gas"]),
            store.mentionCount(phrases: ["og"])
        )
    }

    func testMentionHeatWarmsAsTheCountGrows() {
        XCTAssertLessThan(NounMentionHeat.fraction(for: 1), NounMentionHeat.fraction(for: 100))
        XCTAssertLessThan(NounMentionHeat.fraction(for: 100), NounMentionHeat.fraction(for: 10_000))
        XCTAssertEqual(NounMentionHeat.fraction(for: 0), 0)
        XCTAssertEqual(NounMentionHeat.fraction(for: 10_000), 1)
        XCTAssertEqual(NounMentionHeat.label(for: 678), "678")
        XCTAssertEqual(NounMentionHeat.label(for: 1500), "1.5k")
        XCTAssertEqual(NounMentionHeat.label(for: 12_000), "12k")
    }

    func testKobeCatalogLinesComeFromTheVault() throws {
        let url = URL(fileURLWithPath: "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/bar-hits-catalog/BarHitsCatalog.sqlite")
        try XCTSkipIf(!FileManager.default.fileExists(atPath: url.path))
        let kobe = try XCTUnwrap(NounBankCatalog.items(for: .nba).first {
            $0.insertWord.localizedCaseInsensitiveCompare("Kobe") == .orderedSame
        })
        let store = try BarHitsCatalogStore(databaseURL: url)
        let phrases = NounBankCatalog.mentionPhrases(for: kobe)
        XCTAssertGreaterThan(store.mentionCount(phrases: phrases), 100)
        let lines = store.mentionLines(phrases: phrases, limit: 8)
        XCTAssertFalse(lines.isEmpty)
        XCTAssertTrue(lines.allSatisfy { row in
            let line = row.line.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            return line.contains("kobe") || line.contains("mamba")
        })
    }

    func testAccessoriesStayThemselvesAndNotABrand() throws {
        let cars = NounBankCatalog.items(for: .cars)
        let carWords = cars.map(\.insertWord)
        for part in [
            "keys", "car keys", "tires", "rims", "wheels", "tints",
            "engine", "trunk", "Forgiatos", "license plate", "paper plates", "digital dash"
        ] {
            XCTAssertTrue(carWords.contains(part), part)
        }
        XCTAssertFalse(carWords.contains("Coupe"))
        XCTAssertFalse(carWords.contains("Ferrari"))
        XCTAssertFalse(carWords.contains("chrome"))
        XCTAssertFalse(carWords.contains("dubs"))

        let tires = try XCTUnwrap(cars.first { $0.insertWord == "tires" })
        XCTAssertEqual(tires.label, "tires")
        XCTAssertEqual(tires.family, "tires")
        let tirePhrases = NounBankCatalog.mentionPhrases(for: tires).map { $0.lowercased() }
        XCTAssertEqual(tirePhrases, ["tires"])

        let doors = try XCTUnwrap(cars.first { $0.insertWord == "lambo doors" })
        XCTAssertEqual(doors.label, "lambo doors")
        XCTAssertEqual(doors.family, "lambo doors")
        XCTAssertNotEqual(doors.icon, "noun-car-lambo")

        let digitalDash = try XCTUnwrap(cars.first { $0.insertWord == "digital dash" })
        XCTAssertEqual(digitalDash.icon, "noun-digital-dash")
        let analogDash = try XCTUnwrap(cars.first { $0.insertWord == "dashboard" })
        XCTAssertEqual(analogDash.icon, "noun-dashboard")
        XCTAssertNotEqual(digitalDash.icon, analogDash.icon)

        let keys = try XCTUnwrap(cars.first { $0.insertWord == "keys" })
        XCTAssertTrue(NounBankMark.familyAliases(for: keys.insertWord).isEmpty)

        let jewelry = NounBankCatalog.items(for: .jewelry).map(\.insertWord)
        for part in ["pinky ring", "earrings", "charm", "necklace", "bracelet"] {
            XCTAssertTrue(jewelry.contains(part), part)
        }
        let earrings = try XCTUnwrap(NounBankCatalog.items(for: .jewelry).first { $0.insertWord == "earrings" })
        XCTAssertEqual(earrings.family, "earrings")

        let guns = NounBankCatalog.items(for: .guns).map(\.insertWord)
        for part in ["clip", "ammo", "bullets", "shells", "hollows", "silencer", "holster", "barrel", "trigger", "scope"] {
            XCTAssertTrue(guns.contains(part), part)
        }

        let clothing = NounBankCatalog.items(for: .clothing).map(\.insertWord)
        for part in ["shades", "hoodie", "gloves", "scarf", "heels", "sneakers", "shorts", "jeans", "boots",
                     "beanie", "tank top", "t-shirt", "socks", "belt", "jersey", "sandals", "air max", "a dress"] {
            XCTAssertTrue(clothing.contains(part), part)
        }
        XCTAssertFalse(clothing.contains("suit"))
        XCTAssertFalse(clothing.contains("dress"))
        XCTAssertFalse(clothing.contains("tie"))
        XCTAssertFalse(clothing.contains("vest"))
        let tank = try XCTUnwrap(NounBankCatalog.items(for: .clothing).first { $0.insertWord == "tank top" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: tank, category: .clothing).map { $0.lowercased() }.contains("wife beater"))
        let mask = try XCTUnwrap(NounBankCatalog.items(for: .clothing).first { $0.insertWord == "ski mask" })
        XCTAssertFalse(NounBankCatalog.mentionPhrases(for: mask, category: .clothing).map { $0.lowercased() }.contains("shiesty"))
        let sheisty = try XCTUnwrap(NounBankCatalog.items(for: .clothing).first { $0.insertWord == "sheisty" })
        let sheistyPhrases = NounBankCatalog.mentionPhrases(for: sheisty, category: .clothing).map { $0.lowercased() }
        XCTAssertTrue(sheistyPhrases.contains("shiesty mask"))
        XCTAssertFalse(sheistyPhrases.contains("pooh shiesty"))
        let sockChip = try XCTUnwrap(NounBankCatalog.items(for: .clothing).first { $0.insertWord == "socks" })
        let sockPhrases = NounBankCatalog.mentionPhrases(for: sockChip, category: .clothing).map { $0.lowercased() }
        XCTAssertTrue(sockPhrases.contains("tube socks"))
        XCTAssertFalse(sockPhrases.contains("sock"))
        let jersey = try XCTUnwrap(NounBankCatalog.items(for: .clothing).first { $0.insertWord == "jersey" })
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: jersey, category: .clothing).map { $0.lowercased() }.contains("new jersey"))
        XCTAssertTrue(NounBankStore.words(for: .brands).contains("Levi's"))
        XCTAssertTrue(NounBankStore.words(for: .brands).contains("Jordan"))
        XCTAssertTrue(NounBankStore.words(for: .brands).contains("Dickies"))
        XCTAssertFalse(clothing.contains("Jordan"))
        XCTAssertFalse(clothing.contains("Dickies"))

        let money = NounBankCatalog.items(for: .money)
        let rubber = try XCTUnwrap(money.first { $0.insertWord == "rubber bands" })
        XCTAssertEqual(rubber.family, "rubber bands")
        XCTAssertNotEqual(rubber.family, "bands")
        XCTAssertEqual(Set(NounBankCatalog.mentionPhrases(for: rubber).map { $0.lowercased() }), ["rubber bands"])

        let phrases = NounBankStore.words(for: .phrases)
        for moved in ["suicide doors", "candy paint", "two door", "paper plates", "valet", "black card", "first class"] {
            XCTAssertFalse(phrases.contains(moved), moved)
        }
    }

    func testFamilyWordsAreThePeopleAndNotTheOtherSense() {
        let family = NounBankStore.words(for: .family)
        for word in ["mom", "momma", "mama", "my brother", "loved ones", "dukes", "kinfolk", "cuzzo", "unc", "my bm"] {
            XCTAssertTrue(family.contains(word), word)
        }
        for mixed in ["grams", "papa", "bro", "jit", "youngin", "ma", "papi", "baby girl"] {
            XCTAssertFalse(family.contains(mixed), mixed)
        }
        let momma = NounBankCatalog.items(for: .family).first { $0.insertWord == "momma" }
        XCTAssertEqual(momma?.label, "momma")
        XCTAssertEqual(momma?.family, "momma")
        XCTAssertEqual(momma?.icon, "noun-family-mom")
        let dad = NounBankCatalog.items(for: .family).first { $0.insertWord == "dad" }
        XCTAssertEqual(dad?.icon, "noun-family-dad")
        XCTAssertNotEqual(momma?.icon, dad?.icon)
        let home = NounBankCatalog.items(for: .family).first { $0.insertWord == "family" }
        XCTAssertEqual(home?.icon, "noun-family-home")
        let loved = NounBankCatalog.items(for: .family).first { $0.insertWord == "loved ones" }
        XCTAssertEqual(loved?.icon, "noun-family-loved-ones")
        XCTAssertEqual(
            NounBankCatalog.mentionPhrases(for: momma!).map { $0.lowercased() },
            ["momma"]
        )
        XCTAssertTrue(NounBankStore.words(for: .woman).contains("baby mama"))
        XCTAssertFalse(family.contains("baby mama"))
        let phrases = NounBankStore.words(for: .phrases)
        XCTAssertFalse(phrases.contains("kinfolk"))
        XCTAssertFalse(phrases.contains("baby daddy"))
        XCTAssertTrue(phrases.contains("on my mama"))
    }

    func testAnimalsStayTheCreatureAndNotTheOtherSense() throws {
        let animals = NounBankStore.words(for: .animals)
        for word in ["lion", "snake", "gator", "pitbull", "pit bull", "k9", "rat", "nemo", "king of the jungle"] {
            XCTAssertTrue(animals.contains(word), word)
        }
        for mixed in ["hellcat", "mustang", "jaguar", "viper", "lamb", "goat", "dog", "dawg", "eagle", "skunk", "mamba", "crocs", "simba", "drake"] {
            XCTAssertFalse(animals.contains(mixed), mixed)
        }
        let gator = try XCTUnwrap(NounBankCatalog.items(for: .animals).first { $0.insertWord == "gator" })
        XCTAssertEqual(gator.label, "gator")
        XCTAssertEqual(gator.family, "gator")
        XCTAssertEqual(gator.icon, "noun-gator")
        let lion = try XCTUnwrap(NounBankCatalog.items(for: .animals).first { $0.insertWord == "lion" })
        XCTAssertEqual(lion.icon, "noun-lion")
        XCTAssertNotEqual(lion.icon, gator.icon)
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: gator).map { $0.lowercased() }, ["gator"])
        let pitBull = try XCTUnwrap(NounBankCatalog.items(for: .animals).first { $0.insertWord == "pit bull" })
        XCTAssertEqual(pitBull.family, "pit bull")
        XCTAssertTrue(NounBankStore.words(for: .cars).contains("Hellcat"))
        XCTAssertTrue(NounBankStore.words(for: .woman).contains("stallion"))
        XCTAssertFalse(animals.contains("stallion"))
        XCTAssertTrue(NounBankStore.words(for: .characters).contains("Simba"))
        XCTAssertTrue(NounBankStore.words(for: .drugs).contains("fishscale"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("Duck"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("the rats"))
        XCTAssertTrue(animals.contains("rats"))
    }

    func testInsectsStayTheBugAndNotTheOtherSense() throws {
        let insects = NounBankStore.words(for: .insects)
        for word in ["bee", "bumble bee", "roaches", "ants", "spiders", "mosquito", "centipede"] {
            XCTAssertTrue(insects.contains(word), word)
        }
        for mixed in ["ant", "tick", "fly", "roach", "spider", "bumblebee", "beetle", "caterpillar"] {
            XCTAssertFalse(insects.contains(mixed), mixed)
        }
        let roaches = try XCTUnwrap(NounBankCatalog.items(for: .insects).first { $0.insertWord == "roaches" })
        XCTAssertEqual(roaches.label, "roaches")
        XCTAssertEqual(roaches.family, "roaches")
        XCTAssertEqual(roaches.icon, "noun-roaches")
        let bee = try XCTUnwrap(NounBankCatalog.items(for: .insects).first { $0.insertWord == "bee" })
        XCTAssertEqual(bee.icon, "noun-bee")
        XCTAssertNotEqual(bee.icon, roaches.icon)
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: roaches).map { $0.lowercased() }, ["roaches"])
        XCTAssertFalse(NounBankStore.words(for: .animals).contains("roaches"))
    }

    func testFoodStaysThePlateAndNotTheOtherSense() throws {
        let food = NounBankStore.words(for: .food)
        for word in [
            "fried chicken", "chicken wings", "shrimp", "lobster", "lobster tail", "swordfish",
            "filet", "filet mignon", "taco", "tacos", "fries", "french fries", "pancakes",
            "honey buns", "kool-aid", "popeyes", "chick fil a", "reese's", "domino's",
            "mcdonald's", "wendy's", "raising cane's", "ruth's chris", "in-n-out", "lemonade",
            "subway", "seafood", "salmon", "eggs", "soul food", "gyro"
        ] {
            XCTAssertTrue(food.contains(word), word)
        }
        for mixed in [
            "chicken", "wings", "cuban", "curry", "yams", "grits", "bacon", "ice cream",
            "cake", "skittles", "cookies", "gelato", "honey bun", "sprite", "goldfish",
            "crab", "crabs", "catfish", "popeye's", "kool aid", "chick-fil-a", "in n out",
            "donut", "donuts", "pancake"
        ] {
            XCTAssertFalse(food.contains(mixed), mixed)
        }
        let plate = try XCTUnwrap(NounBankCatalog.items(for: .food).first { $0.insertWord == "fried chicken" })
        XCTAssertEqual(plate.label, "fried chicken")
        XCTAssertNil(plate.canonical)
        XCTAssertEqual(plate.family, "fried chicken")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: plate).map { $0.lowercased() }, ["fried chicken"])
        let filet = try XCTUnwrap(NounBankCatalog.items(for: .food).first { $0.insertWord == "filet" })
        let mignon = try XCTUnwrap(NounBankCatalog.items(for: .food).first { $0.insertWord == "filet mignon" })
        XCTAssertEqual(filet.family, "filet")
        XCTAssertEqual(mignon.family, "filet mignon")
        XCTAssertNotEqual(filet.family, mignon.family)
        let animals = NounBankStore.words(for: .animals)
        for moved in ["shrimp", "lobster", "lobster tail", "swordfish", "crab", "crabs", "catfish", "fangs"] {
            XCTAssertFalse(animals.contains(moved), moved)
        }
        XCTAssertTrue(animals.contains("goldfish"))
        XCTAssertTrue(animals.contains("fish"))
        XCTAssertTrue(animals.contains("turkey"))
        XCTAssertTrue(NounBankStore.words(for: .syrups).contains("sprite"))
        XCTAssertTrue(NounBankStore.words(for: .drugs).contains("fishscale"))
    }

    func testGrillsStayTheTeethAndNotTheMixtape() throws {
        let grills = NounBankStore.words(for: .grills)
        for word in [
            "grill", "grills", "gold grill", "gold fronts", "gold teeth", "gold tooth",
            "golds", "fangs", "my fangs", "teeth gold", "ice grill", "veneers", "porcelain"
        ] {
            XCTAssertTrue(grills.contains(word), word)
        }
        for mixed in ["grillz", "fronts", "crowns", "vampire", "bustdown", "slugs", "dentist", "dental", "the grill"] {
            XCTAssertFalse(grills.contains(mixed), mixed)
        }
        let grill = try XCTUnwrap(NounBankCatalog.items(for: .grills).first { $0.insertWord == "grill" })
        XCTAssertEqual(grill.label, "grill")
        XCTAssertNil(grill.canonical)
        XCTAssertEqual(grill.family, "grill")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: grill).map { $0.lowercased() }, ["grill"])
        let teeth = try XCTUnwrap(NounBankCatalog.items(for: .grills).first { $0.insertWord == "gold teeth" })
        let tooth = try XCTUnwrap(NounBankCatalog.items(for: .grills).first { $0.insertWord == "gold tooth" })
        XCTAssertNotEqual(teeth.family, tooth.family)
        XCTAssertFalse(NounBankStore.words(for: .animals).contains("fangs"))
        XCTAssertFalse(NounBankStore.words(for: .jewelry).contains { $0.caseInsensitiveCompare("grill") == .orderedSame })
        XCTAssertTrue(NounBankStore.words(for: .jewelry).contains("Grillz"))
        XCTAssertTrue(NounBankStore.words(for: .jewelry).contains("Gangsta Grillz"))
    }

    func testHairStaysTheCutAndNotTheOtherSense() throws {
        let hair = NounBankStore.words(for: .hair)
        for word in [
            "dreads", "dreadlocks", "dreadlock", "waves", "temp fade", "braids", "lace front",
            "weave", "wigs", "lineup", "bangs", "bald head", "blonde", "blonde hair", "nappy",
            "haircut", "braid", "braided", "barbershop", "the barber"
        ] {
            XCTAssertTrue(hair.contains(word), word)
        }
        for mixed in [
            "locs", "locks", "fade", "wig", "durag", "wave cap", "lemonade", "bundles",
            "extensions", "line up", "line-up", "caesar", "closure"
        ] {
            XCTAssertFalse(hair.contains(mixed), mixed)
        }
        let dreads = try XCTUnwrap(NounBankCatalog.items(for: .hair).first { $0.insertWord == "dreads" })
        XCTAssertEqual(dreads.label, "dreads")
        XCTAssertNil(dreads.canonical)
        XCTAssertEqual(dreads.family, "dreads")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: dreads).map { $0.lowercased() }, ["dreads"])
        let locks = try XCTUnwrap(NounBankCatalog.items(for: .hair).first { $0.insertWord == "dreadlocks" })
        let lock = try XCTUnwrap(NounBankCatalog.items(for: .hair).first { $0.insertWord == "dreadlock" })
        XCTAssertNotEqual(dreads.family, locks.family)
        XCTAssertNotEqual(locks.family, lock.family)
        let braid = try XCTUnwrap(NounBankCatalog.items(for: .hair).first { $0.insertWord == "braid" })
        let braids = try XCTUnwrap(NounBankCatalog.items(for: .hair).first { $0.insertWord == "braids" })
        XCTAssertEqual(braid.family, "braid")
        XCTAssertNotEqual(braid.family, braids.family)
        XCTAssertTrue(NounBankStore.words(for: .clothing).contains("durag"))
        XCTAssertTrue(NounBankStore.words(for: .clothing).contains("wave cap"))
        XCTAssertTrue(NounBankStore.words(for: .kill).contains("wig split"))
        XCTAssertTrue(NounBankStore.words(for: .food).contains("lemonade"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("on my mama"))
    }

    func testNailsStayTheManicureAndNotTheOtherSense() throws {
        let nails = NounBankStore.words(for: .nails)
        for word in [
            "nails", "french tip", "french tips", "my nails", "her nails",
            "nails done", "nails did", "manicure", "pedicure"
        ] {
            XCTAssertTrue(nails.contains(word), word)
        }
        for mixed in [
            "acrylic", "acrylics", "stiletto", "stilettos", "coffin", "almond",
            "gel", "claws", "claw", "tips", "ballerina"
        ] {
            XCTAssertFalse(nails.contains(mixed), mixed)
        }
        let tip = try XCTUnwrap(NounBankCatalog.items(for: .nails).first { $0.insertWord == "french tip" })
        let tips = try XCTUnwrap(NounBankCatalog.items(for: .nails).first { $0.insertWord == "french tips" })
        XCTAssertEqual(tip.label, "french tip")
        XCTAssertNil(tip.canonical)
        XCTAssertEqual(tip.family, "french tip")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: tip).map { $0.lowercased() }, ["french tip"])
        XCTAssertNotEqual(tip.family, tips.family)
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("coffin"))
        XCTAssertTrue(NounBankStore.words(for: .animals).contains("claws"))
    }

    func testTattoosStayInkOnSkinAndNotTheOtherSense() throws {
        let tattoos = NounBankStore.words(for: .tattoos)
        for word in [
            "tattoo", "tattoos", "tatted", "tattooed", "tats",
            "a tattoo", "the tattoo", "the tattoos", "my tattoos", "my tats", "the tats",
            "tatted up", "i'm tatted", "she tatted", "it's tatted",
            "tatted on my", "tatted on me", "tatted on my face", "tatted on my neck", "tatted on my chest",
            "tatted on my arm",
            "tats on my", "tats on my face", "tats on my neck",
            "tattoos on my", "tattoo on my", "tattoo on her", "tattoos on her",
            "got tats", "got tattoos", "got it tatted",
            "name tatted", "my name tatted", "got my name tatted",
            "face tats", "face tatted", "tramp stamp", "inked"
        ] {
            XCTAssertTrue(tattoos.contains(word), word)
        }
        for mixed in [
            "ink", "sleeve", "sleeves", "my sleeve", "long sleeve", "tat", "a tat",
            "face tat", "teardrop", "teardrops", "neck piece", "barcode", "in ink",
            "inked up", "on my sleeve", "both arms"
        ] {
            XCTAssertFalse(tattoos.contains(mixed), mixed)
        }
        let one = try XCTUnwrap(NounBankCatalog.items(for: .tattoos).first { $0.insertWord == "tattoo" })
        let many = try XCTUnwrap(NounBankCatalog.items(for: .tattoos).first { $0.insertWord == "tattoos" })
        let slang = try XCTUnwrap(NounBankCatalog.items(for: .tattoos).first { $0.insertWord == "tats" })
        XCTAssertEqual(one.label, "tattoo")
        XCTAssertNil(one.canonical)
        XCTAssertEqual(one.family, "tattoo")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: one).map { $0.lowercased() }, ["tattoo"])
        XCTAssertNotEqual(one.family, many.family)
        XCTAssertNotEqual(many.family, slang.family)
        let stamp = try XCTUnwrap(NounBankCatalog.items(for: .tattoos).first { $0.insertWord == "tramp stamp" })
        XCTAssertEqual(stamp.label, "tramp stamp")
        XCTAssertNil(stamp.canonical)
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: stamp).map { $0.lowercased() }, ["tramp stamp"])
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("heart on my sleeve"))
        XCTAssertFalse(NounBankStore.words(for: .phrases).contains("tattoo"))
    }

    func testFlowersStayThePlantAndNotTheOtherSense() throws {
        let flowers = NounBankStore.words(for: .flowers)
        for word in ["flowers", "roses", "petals", "rose petals", "daisies", "tulips"] {
            XCTAssertTrue(flowers.contains(word), word)
        }
        for mixed in ["rose", "bouquet", "flower", "daisy", "sunflower", "lotus", "amber rose", "d-rose"] {
            XCTAssertFalse(flowers.contains(mixed), mixed)
        }
        let roses = try XCTUnwrap(NounBankCatalog.items(for: .flowers).first { $0.insertWord == "roses" })
        let petals = try XCTUnwrap(NounBankCatalog.items(for: .flowers).first { $0.insertWord == "rose petals" })
        XCTAssertEqual(roses.label, "roses")
        XCTAssertNil(roses.canonical)
        XCTAssertEqual(roses.family, "roses")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: roses).map { $0.lowercased() }, ["roses"])
        XCTAssertNotEqual(roses.family, petals.family)
        XCTAssertTrue(NounBankStore.words(for: .celebs).contains("Amber Rose"))
        XCTAssertTrue(NounBankStore.words(for: .nba).contains("D-Rose"))
    }

    func testLingerieAndToysStayTheGarment() throws {
        let lingerie = NounBankStore.words(for: .lingerie)
        for word in ["lingerie", "panties", "thong", "thongs", "g-string", "fishnets", "stockings", "bra", "boxers", "drawers", "bikini"] {
            XCTAssertTrue(lingerie.contains(word), word)
        }
        for mixed in ["heels", "lace", "teddy", "latex", "red bottoms", "dildo", "whip", "chains"] {
            XCTAssertFalse(lingerie.contains(mixed), mixed)
        }
        XCTAssertEqual(NounBankStore.words(for: .toys), ["vibrator", "rose"])
        let rose = try XCTUnwrap(NounBankCatalog.items(for: .toys).first { $0.insertWord == "rose" })
        XCTAssertEqual(rose.family, "rose")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: rose, category: .toys).map { $0.lowercased() }, ["rose toy"])
        XCTAssertFalse(NounBankStore.words(for: .flowers).contains("rose"))
        let thong = try XCTUnwrap(NounBankCatalog.items(for: .lingerie).first { $0.insertWord == "thong" })
        let thongs = try XCTUnwrap(NounBankCatalog.items(for: .lingerie).first { $0.insertWord == "thongs" })
        XCTAssertEqual(thong.label, "thong")
        XCTAssertNil(thong.canonical)
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: thong).map { $0.lowercased() }, ["thong"])
        XCTAssertNotEqual(thong.family, thongs.family)
        let toy = try XCTUnwrap(NounBankCatalog.items(for: .toys).first { $0.insertWord == "vibrator" })
        XCTAssertNil(toy.canonical)
        XCTAssertEqual(toy.family, "vibrator")
    }

    func testBehaviorPocketsStayTheSpokenSense() throws {
        let twerk = NounBankStore.words(for: .twerk)
        XCTAssertTrue(twerk.contains("twerk"))
        XCTAssertTrue(twerk.contains("twerking"))
        XCTAssertTrue(twerk.contains("bounce that ass"))
        XCTAssertFalse(twerk.contains("shake it"))
        XCTAssertFalse(twerk.contains("make it clap"))
        let one = try XCTUnwrap(NounBankCatalog.items(for: .twerk).first { $0.insertWord == "twerk" })
        let ing = try XCTUnwrap(NounBankCatalog.items(for: .twerk).first { $0.insertWord == "twerking" })
        XCTAssertEqual(one.label, "twerk")
        XCTAssertNil(one.canonical)
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: one).map { $0.lowercased() }, ["twerk"])
        XCTAssertNotEqual(one.family, ing.family)
        XCTAssertTrue(NounBankStore.words(for: .streets).contains("she a thot"))
        XCTAssertTrue(NounBankStore.words(for: .streets).contains("she for the streets"))
        XCTAssertFalse(NounBankStore.words(for: .streets).contains("thot"))
        XCTAssertTrue(NounBankStore.words(for: .woman).contains("thot"))
        XCTAssertEqual(NounBankStore.words(for: .kingpin), ["kingpin", "my connect", "plug talk", "hit the plug", "call the plug"])
        XCTAssertFalse(NounBankStore.words(for: .kingpin).contains("kingpins"))
        XCTAssertFalse(NounBankStore.words(for: .kingpin).contains("the plug"))
        XCTAssertTrue(NounBankStore.words(for: .trapLife).contains("trap house"))
        XCTAssertTrue(NounBankStore.words(for: .trapLife).contains("the trap"))
        XCTAssertFalse(NounBankStore.words(for: .trapLife).contains("trap"))
        XCTAssertTrue(NounBankStore.words(for: .places).contains("trap"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("in the trap"))
        XCTAssertTrue(NounBankStore.words(for: .paranoia).contains("paranoid"))
        XCTAssertTrue(NounBankStore.words(for: .paranoia).contains("hearing voices"))
        XCTAssertFalse(NounBankStore.words(for: .paranoia).contains("they watching"))
    }

    func testPeoplePocketsStayThePersonAndNotTheOtherSense() throws {
        XCTAssertEqual(
            NounBankStore.words(for: .wrestlers),
            [
                "Kurt Angle", "Steve Austin", "Jeff Hardy",
                "John Cena", "Ric Flair", "Undertaker", "Hogan", "Macho Man",
                "Mysterio", "Triple H", "HBK", "Stone Cold", "The Rock"
            ]
        )
        let sports = NounBankStore.words(for: .sports)
        XCTAssertTrue(sports.contains("Messi"))
        XCTAssertTrue(sports.contains("McGregor"))
        XCTAssertTrue(sports.contains("Bruce Lee"))
        XCTAssertFalse(sports.contains("John Cena"))
        XCTAssertFalse(sports.contains("Stone Cold"))
        XCTAssertFalse(sports.contains("The Rock"))
        XCTAssertFalse(sports.contains("Hogan"))
        let rock = try XCTUnwrap(NounBankCatalog.items(for: .wrestlers).first { $0.insertWord == "The Rock" })
        XCTAssertEqual(rock.icon, "noun-celeb-the-rock")
        let angle = try XCTUnwrap(NounBankCatalog.items(for: .wrestlers).first { $0.insertWord == "Kurt Angle" })
        XCTAssertEqual(angle.label, "Kurt Angle")
        XCTAssertNil(angle.canonical)
        XCTAssertEqual(angle.family, "kurt angle")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: angle).map { $0.lowercased() }, ["kurt angle"])
        let actors = NounBankStore.words(for: .actors)
        let jetLi = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Jet Li" })
        XCTAssertEqual(jetLi.family, "jet li")
        XCTAssertEqual(jetLi.icon, "noun-jet-li")
        XCTAssertNotEqual(jetLi.icon, "noun-jet")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: jetLi).map { $0.lowercased() }, ["jet li"])
        XCTAssertTrue(actors.contains("Stallone"))
        XCTAssertTrue(actors.contains("Sylvester Stallone"))
        XCTAssertTrue(actors.contains("Richard Pryor"))
        XCTAssertFalse(actors.contains("Denzel"))
        XCTAssertFalse(actors.contains("Denzel Washington"))
        XCTAssertFalse(actors.contains("DiCaprio"))
        let addedActors = [
            "Whoopi Goldberg", "Ving Rhames", "Steve Buscemi", "Heath Ledger",
            "Quentin Tarantino", "Steven Spielberg", "Martin Scorsese", "Ice Cube",
            "Mel Gibson", "Mekhi Phifer", "Mike Epps",
            "Morgan Freeman", "Redd Foxx", "Angela Bassett", "Nicolas Cage",
            "Robin Williams", "Wesley Snipes", "Keke Palmer", "Steven Seagal",
            "George Clooney", "John Travolta", "Don Cheadle", "Wayans",
            "Chris Farley", "Michael B. Jordan", "Samuel L. Jackson",
            "Idris Elba", "Mo'Nique"
        ]
        for name in addedActors {
            XCTAssertTrue(actors.contains(name), name)
        }
        let buscemi = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Steve Buscemi" })
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: buscemi).map { $0.lowercased() }, ["steve buscemi", "buscemi"])
        XCTAssertEqual(buscemi.icon, "noun-steve-buscemi")
        let gibson = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Mel Gibson" })
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: gibson).map { $0.lowercased() }, ["mel gibson"])
        let wayans = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Wayans" })
        XCTAssertEqual(wayans.family, "wayans")
        XCTAssertEqual(
            NounBankCatalog.mentionExclusions(for: wayans, category: .actors).map { $0.lowercased() },
            ["damon wayans"]
        )
        let cube = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Ice Cube" })
        XCTAssertEqual(cube.family, "ice cube")
        XCTAssertEqual(cube.icon, "noun-ice-cube")
        let mbj = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Michael B. Jordan" })
        XCTAssertEqual(mbj.icon, "noun-michael-b-jordan")
        XCTAssertNotEqual(mbj.icon, "noun-jordan")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: mbj).map { $0.lowercased() }, ["michael b. jordan"])
        let idris = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Idris Elba" })
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: idris).map { $0.lowercased() }, ["idris elba"])
        let farley = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Chris Farley" })
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: farley).map { $0.lowercased() }, ["chris farley"])
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Ray J"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Brandy"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Ice-T"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Snoop Dogg"))
        let snoop = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "Snoop Dogg" })
        XCTAssertEqual(snoop.icon, "noun-artist-snoop-dogg")
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: snoop).map { $0.lowercased() }.contains("snoop"))
        let iceT = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "Ice-T" })
        XCTAssertEqual(iceT.icon, "noun-artist-ice-t")
        XCTAssertNotEqual(iceT.icon, "noun-ice-cube")
        let tommy = try XCTUnwrap(NounBankCatalog.items(for: .characters).first { $0.insertWord == "Tommy" })
        XCTAssertEqual(tommy.icon, "noun-char-tommy")
        XCTAssertEqual(
            NounBankCatalog.mentionExclusions(for: tommy, category: .characters).map { $0.lowercased() },
            ["tommy gun", "tommy hilfiger", "tommy lee"]
        )
        XCTAssertFalse(NounBankStore.words(for: .characters).contains("Cole"))
        let madea = try XCTUnwrap(NounBankCatalog.items(for: .characters).first { $0.insertWord == "Madea" })
        XCTAssertEqual(madea.icon, "noun-char-madea")
        let bruh = try XCTUnwrap(NounBankCatalog.items(for: .characters).first { $0.insertWord == "Bruh-Man" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: bruh).map { $0.lowercased() }.contains("bro man"))
        let leonardo = try XCTUnwrap(NounBankCatalog.items(for: .celebs).first { $0.insertWord == "Leonardo" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: leonardo).map { $0.lowercased() }.contains("dicaprio"))
        let deNiro = try XCTUnwrap(NounBankCatalog.items(for: .celebs).first { $0.insertWord == "De Niro" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: deNiro).map { $0.lowercased() }.contains("deniro"))
        let stallone = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Stallone" })
        let full = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Sylvester Stallone" })
        XCTAssertNil(stallone.canonical)
        XCTAssertNotEqual(stallone.family, full.family)
        XCTAssertEqual(NounBankStore.words(for: .streamers), ["Akademiks", "Kai Cenat", "Charlamagne"])
        XCTAssertFalse(NounBankStore.words(for: .streamers).contains("Speed"))
        XCTAssertFalse(NounBankStore.words(for: .celebs).contains("Akademiks"))
        let aka = try XCTUnwrap(NounBankCatalog.items(for: .streamers).first { $0.insertWord == "Akademiks" })
        XCTAssertEqual(aka.label, "Akademiks")
        XCTAssertNil(aka.canonical)
        XCTAssertEqual(aka.family, "akademiks")
    }

    func testNounPageBriefIsAStandingLinePlusALyricTake() {
        let tall = [
            "Nine figure money, tall like Yao Ming",
            "Tall racks like Yao Ming",
            "Money tall like Yao Ming",
            "I got the ball and Yao Ming"
        ]
        let ming = NounMentionBrief.passage(word: "Yao Ming", category: .nba, phrases: ["Yao Ming"], lines: tall)
        XCTAssertTrue(ming.localizedCaseInsensitiveContains("basketball"))
        XCTAssertTrue(ming.contains("Houston Rockets"))
        XCTAssertFalse(ming.contains("is an NBA name"))
        XCTAssertFalse(ming.contains("Nine figure"))
        XCTAssertFalse(ming.contains("No catalog lines"))
        XCTAssertFalse(ming.contains("No single detail"))

        let roses = [
            "guns and roses",
            "guns and roses",
            "red roses on the table"
        ]
        let flower = NounMentionBrief.passage(word: "roses", category: .flowers, phrases: ["roses"], lines: roses)
        XCTAssertTrue(flower.localizedCaseInsensitiveContains("flower"))
        XCTAssertFalse(flower.contains("guns"))
        XCTAssertFalse(flower.contains("means the flower"))

        let quiet = NounMentionBrief.passage(word: "Akademiks", category: .streamers, phrases: ["Akademiks"], lines: ["Akademiks know"])
        XCTAssertTrue(quiet.contains("DJ Akademiks"))
        XCTAssertFalse(quiet.contains("No single detail"))
        XCTAssertFalse(quiet.localizedCaseInsensitiveContains("picture"))

        let empty = NounMentionBrief.passage(word: "Yao Ming", category: .nba, phrases: ["Yao Ming"], lines: [])
        XCTAssertEqual(empty, ming)
    }

    func testFriendsStayThePeopleAndNotTheOtherSense() throws {
        let friends = NounBankStore.words(for: .friends)
        for word in [
            "slime", "slimes", "slatt", "slatts", "twin", "brodie", "brody", "bruh",
            "broski", "bro", "bros", "potna", "partna", "whoadie", "wodie", "woadie",
            "homie", "homies", "homeboy", "homegirl", "dawg", "dawgs", "gang", "gangs",
            "goon", "goons", "drillers", "shooter", "shooters", "the guys", "my guys",
            "my mans", "the mandem", "gangbanger", "gang member", "gang members"
        ] {
            XCTAssertTrue(friends.contains(word), word)
        }
        for mixed in [
            "ysl", "locs", "loc", "fade", "ace", "o block", "blood", "crip",
            "lil homie", "big homie", "the homies", "my homies", "my dawg", "my boys",
            "day one", "day ones", "my gang", "with the gang", "for the gang",
            "the clique", "the crew", "the squad", "my boy", "my bro", "my people",
            "cuz", "cuzzo", "brother", "fam"
        ] {
            XCTAssertFalse(friends.contains(mixed), mixed)
        }
        let slime = try XCTUnwrap(NounBankCatalog.items(for: .friends).first { $0.insertWord == "slime" })
        XCTAssertEqual(slime.label, "slime")
        XCTAssertNil(slime.canonical)
        XCTAssertEqual(slime.family, "slime")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: slime).map { $0.lowercased() }, ["slime"])
        let slatt = try XCTUnwrap(NounBankCatalog.items(for: .friends).first { $0.insertWord == "slatt" })
        XCTAssertNotEqual(slime.family, slatt.family)
        XCTAssertFalse(NounBankStore.words(for: .animals).contains("dawg"))
        XCTAssertTrue(NounBankStore.words(for: .brands).contains("YSL"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("big homie"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("my dawg"))
        XCTAssertTrue(NounBankStore.words(for: .family).contains("cuz"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("Bloods"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("Crips"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("OTF"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("4PF"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("Glo Gang"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("FBG"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("Only the Family"))
        XCTAssertFalse(NounBankStore.words(for: .opps).contains("o block"))
        XCTAssertFalse(NounBankStore.words(for: .opps).contains("YSL"))
    }

    func testGamesStayTheTitleAndNotTheOtherSense() throws {
        let games = NounBankStore.words(for: .games)
        for word in [
            "Call of Duty", "Black Ops", "Fortnite", "GTA", "Grand Theft Auto",
            "San Andreas", "Madden", "FIFA", "Zelda", "Pokemon", "Luigi",
            "Mortal Kombat", "Street Fighter", "Tekken", "Pac-Man",
            "PlayStation", "PS5", "PS4", "Nintendo", "Wii"
        ] {
            XCTAssertTrue(games.contains(word), word)
        }
        for mixed in [
            "cod", "warzone", "2k", "halo", "mario", "xbox", "pacman",
            "game boy", "just dance", "ranked", "big smoke", "creeper", "ufo", "pikachu"
        ] {
            XCTAssertFalse(games.contains(mixed), mixed)
        }
        let duty = try XCTUnwrap(NounBankCatalog.items(for: .games).first { $0.insertWord == "Call of Duty" })
        XCTAssertEqual(duty.label, "Call of Duty")
        XCTAssertNil(duty.canonical)
        XCTAssertEqual(duty.family, "call of duty")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: duty).map { $0.lowercased() }, ["call of duty"])
        let gta = try XCTUnwrap(NounBankCatalog.items(for: .games).first { $0.insertWord == "GTA" })
        let full = try XCTUnwrap(NounBankCatalog.items(for: .games).first { $0.insertWord == "Grand Theft Auto" })
        XCTAssertNotEqual(gta.family, full.family)
        let luigi = try XCTUnwrap(NounBankCatalog.items(for: .games).first { $0.insertWord == "Luigi" })
        XCTAssertEqual(luigi.family, "luigi")
        XCTAssertNil(luigi.canonical)
        XCTAssertTrue(NounBankStore.words(for: .drugs).contains("xbox"))
        XCTAssertTrue(NounBankStore.words(for: .characters).contains("Pikachu"))
        XCTAssertFalse(NounBankStore.words(for: .events).contains("Luigi"))
    }

    func testEventsStayThePersonAndNotTheOtherSense() throws {
        let events = NounBankStore.words(for: .events)
        for word in [
            "Lil Snupe", "Snupe", "Speaker Knockerz", "Doe B", "Big L",
            "Trayvon", "Mike Brown", "Columbine"
        ] {
            XCTAssertTrue(events.contains(word), word)
        }
        for mixed in [
            "charlie kirk", "luigi", "trouble", "proof", "dolly", "fredo",
            "ceo", "shawty lo", "xxxtentacion", "george floyd", "i can't breathe",
            "say her name", "when they see us", "young dolph", "nipsey", "kobe"
        ] {
            XCTAssertFalse(events.contains(mixed), mixed)
        }
        let snupe = try XCTUnwrap(NounBankCatalog.items(for: .events).first { $0.insertWord == "Snupe" })
        let lil = try XCTUnwrap(NounBankCatalog.items(for: .events).first { $0.insertWord == "Lil Snupe" })
        XCTAssertEqual(snupe.label, "Snupe")
        XCTAssertNil(snupe.canonical)
        XCTAssertEqual(snupe.family, "snupe")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: snupe).map { $0.lowercased() }, ["snupe"])
        XCTAssertNotEqual(snupe.family, lil.family)
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Nipsey"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Pop Smoke"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("King Von"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Young Dolph"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("Takeoff"))
        XCTAssertTrue(NounBankStore.words(for: .artists).contains("2Pac"))
        XCTAssertTrue(NounBankStore.words(for: .nba).contains("Kobe"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("long live"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("RIP"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("rest in peace"))
    }

    func testRecentsDropWordsMissingFromStore() {
        let json = #"[{"word":"NotARealNounXYZ","category":"Liquors"}]"#
        UserDefaults.standard.set(Data(json.utf8), forKey: NounBankRecents.defaultsKey)
        XCTAssertTrue(NounBankRecents.items.isEmpty)
    }

    func testMinedPocketsKeepTheSeededTerms() {
        let substances = NounBankStore.words(for: .substances)
        XCTAssertEqual(substances.count, 43)
        XCTAssertTrue(substances.contains("embalming fluid"))
        XCTAssertEqual(Set(substances).count, substances.count)

        let religion = NounBankStore.words(for: .religion)
        XCTAssertEqual(religion.count, 34)
        for word in ["Jewish", "Muslim", "Christian", "God", "Allah", "church", "mosque", "rosary", "Bible", "Quran"] {
            XCTAssertTrue(religion.contains(word), word)
        }
        let god = NounMentionBrief.standing(word: "God", category: .religion)
        XCTAssertTrue(god.localizedCaseInsensitiveContains("deity") || god.localizedCaseInsensitiveContains("supreme"))
        XCTAssertFalse(god.contains("for writing reference"))
        let fluid = NounMentionBrief.standing(word: "embalming fluid", category: .substances)
        XCTAssertFalse(fluid.localizedCaseInsensitiveContains("funeral"))
        XCTAssertFalse(fluid.localizedCaseInsensitiveContains("decomposition"))
        XCTAssertTrue(
            fluid == "No published definition turned up for embalming fluid."
                || fluid.localizedCaseInsensitiveContains("phencyclidine")
                || fluid.localizedCaseInsensitiveContains("PCP")
        )

        let feelings = NounBankStore.words(for: .feelings)
        XCTAssertEqual(feelings.count, 98)
        for word in ["scary", "paranoid", "numb", "lonely", "alone", "blessed", "grateful", "angry", "hurt", "content"] {
            XCTAssertTrue(feelings.contains(word), word)
        }
        XCTAssertEqual(
            NounBankFeelingsNote.text,
            "Each chip opens two lists: the feeling, and the word said literally."
        )
        XCTAssertEqual(
            NounBankFeelingsNote.page,
            "These lines are split into the feeling and the literal use of the word."
        )
        XCTAssertEqual(NounFeelingSplit.kind(word: "alone", line: "how you feel when you alone?"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "alone", line: "Lately I just been alone"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "alone", line: "They left me all alone"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "alone", line: "leave you alone to go get it out the pot"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "alone", line: "Private jet, we flyin' all alone"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "alone", line: "Hoes by the pair, I'm never alone"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "alone", line: "Demons leave me alone"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "alone", line: "We alone, still lock the door"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "content", line: "Gotta get more 'cause I'm never content"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "content", line: "Now I got bread, but I ain't content"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "content", line: "Filmin' and get us some content"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "content", line: "Gon' and put it up for content"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "content", line: "Shawty wanna shoot content"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "hurt", line: "I know it hurt, but you still told me that you lied"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "hurt", line: "can't hurt a king"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "hurt", line: "It hurt my Glock when I lean"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "mad", line: "These fuck niggas mad, I see it in they face"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "mad", line: "lost mad commas"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "sad", line: "I'm so sad"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "abandoned", line: "When you broke, you just feel abandoned"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "abandoned", line: "abandoned building"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "happy", line: "I'm so happy"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "happy", line: "trigger happy"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "fear", line: "Fear of God on me"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "spite", line: "in spite of the pain"), .literal)
        XCTAssertEqual(NounFeelingSplit.kind(word: "spite", line: "maybe you spite me"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "love", line: "I love her"), .feeling)
        XCTAssertEqual(NounFeelingSplit.kind(word: "love", line: "we make love"), .literal)
        XCTAssertTrue(NounBankStore.words(for: .paranoia).contains("paranoid"))

        let phrases = NounBankStore.words(for: .phrases)
        for word in [
            "people weren't around", "wasn't there", "when I was down", "nobody believed", "been through it"
        ] {
            XCTAssertTrue(phrases.contains(word), word)
        }
        for word in [
            "when I was broke", "they ain't believe", "they didn't believe",
            "been through a lot", "when I was down bad", "wasn't around"
        ] {
            XCTAssertTrue(phrases.contains(word), word)
        }

        let characters = NounBankStore.words(for: .characters)
        for word in ["Hello Kitty", "Bart Simpson", "Mickey", "Scooby", "Scooby Doo", "SpongeBob", "Goku"] {
            XCTAssertTrue(characters.contains(word), word)
        }
        XCTAssertFalse(characters.contains("Mario"))
        XCTAssertTrue(NounBankStore.words(for: .games).contains("Luigi"))

        let brands = NounBankStore.words(for: .brands)
        XCTAssertFalse(brands.contains("Harley"))
        XCTAssertFalse(brands.contains("Harley-Davidson"))
        let cars = NounBankStore.words(for: .cars)
        XCTAssertTrue(cars.contains("Harley"))
        XCTAssertTrue(cars.contains("Harley-Davidson"))
        XCTAssertTrue(cars.contains("BMW"))
        XCTAssertTrue(cars.contains("Can-Am"))
        XCTAssertTrue(brands.contains("John Deere"))
        XCTAssertTrue(brands.contains("Louis V"))
        XCTAssertFalse(brands.contains("Louis Vuitton"))
        XCTAssertFalse(brands.contains("Hellcat"))
    }

    func testNewPocketsUseADifferentSymbolOnEveryChip() {
        for category in [NounBankCategory.substances, .religion, .feelings, .apps, .looks] {
            let symbols = NounBankStore.words(for: category).map {
                NounBankSymbols.symbol(for: $0, category: category)
            }
            XCTAssertEqual(Set(symbols).count, symbols.count, category.rawValue)
            for name in symbols {
                XCTAssertNotNil(UIImage(systemName: name), "\(category.rawValue) \(name)")
            }
        }
        let added: [(NounBankCategory, [String])] = [
            (.phrases, [
                "people weren't around", "wasn't there", "when I was down", "nobody believed",
                "when I was broke", "they ain't believe", "they didn't believe",
                "been through a lot", "been through it", "when I was down bad", "wasn't around"
            ]),
            (.characters, [
                "Hello Kitty", "Bart Simpson", "Mickey", "Mickey Mouse", "Scooby", "Homer", "Cartman",
                "Donald Duck", "Minnie", "Gohan", "Frieza", "Tom and Jerry", "Family Guy",
                "South Park", "Rugrats", "Hey Arnold", "Crash Bandicoot", "Sasuke", "Sonic"
            ]),
            (.brands, [
                "Samsung", "Crocs", "Uggs",
                "Timberland", "John Deere", "MacBook", "iPad", "Sony", "Coogi",
                "Apple Bottom", "iPhone"
            ]),
            (.cars, [
                "Harley", "Harley-Davidson", "Ducati", "Yamaha", "Kawasaki", "Can-Am",
                "BMW", "Mercedes", "Ford", "Honda", "Toyota", "Lexus", "Nissan"
            ])
        ]
        for (category, words) in added {
            let symbols = words.map { NounBankSymbols.symbol(for: $0, category: category) }
            XCTAssertEqual(Set(symbols).count, symbols.count, category.rawValue)
            for name in symbols {
                XCTAssertNotNil(UIImage(systemName: name), "\(category.rawValue) \(name)")
            }
        }
        for category in NounBankCategory.allCases {
            let words = NounBankStore.words(for: category)
            var seen = Set<String>()
            for word in words {
                let name = NounBankSymbols.symbol(for: word, category: category)
                XCTAssertFalse(name.isEmpty, "\(category.rawValue) \(word)")
                seen.insert(name)
            }
            if words.count > 1 {
                XCTAssertGreaterThan(seen.count, 1, category.rawValue)
            }
        }
    }

    func testMentionStatsStayUnboundedAndZeroReadsAsEmpty() throws {
        XCTAssertEqual(NounMentionTally(hits: 0, artists: 0, songs: 0).label, "0 in catalog")
        XCTAssertEqual(
            NounMentionTally(hits: 11, artists: 8, songs: 11).label,
            "11 hits · 8 artists · 11 songs"
        )
        let url = URL(fileURLWithPath: "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/bar-hits-catalog/BarHitsCatalog.sqlite")
        try XCTSkipIf(!FileManager.default.fileExists(atPath: url.path))
        let store = try BarHitsCatalogStore(databaseURL: url)
        let fluid = store.mentionStats(phrases: ["embalming fluid"])
        XCTAssertGreaterThanOrEqual(fluid.hits, 10)
        XCTAssertGreaterThanOrEqual(fluid.artists, 3)
        XCTAssertGreaterThan(fluid.songs, 0)
        let missing = store.mentionStats(phrases: ["people weren't around"])
        XCTAssertEqual(missing.hits, 0)
        XCTAssertEqual(
            NounMentionTally(hits: missing.hits, artists: missing.artists, songs: missing.songs).label,
            "0 in catalog"
        )
        let believed = store.mentionStats(phrases: ["nobody believed"])
        XCTAssertGreaterThan(believed.hits, 0)
        XCTAssertFalse(
            NounMentionTally(hits: believed.hits, artists: believed.artists, songs: believed.songs).label
                .hasPrefix("0 in catalog")
        )
    }

    func testSimpleMentionsDropAndASetupStays() {
        let phrases = ["Young Dolph", "Dolph"]
        XCTAssertFalse(NounMentionWorth.keeps("Young Dolph still straight", phrases: phrases))
        XCTAssertFalse(NounMentionWorth.keeps(
            "And long live my boy Young Dolph, you know what I'm sayin'",
            phrases: phrases
        ))
        XCTAssertFalse(NounMentionWorth.keeps("Young Dolph, I'm just coolin'", phrases: phrases))
        XCTAssertFalse(NounMentionWorth.keeps("I'm the shit, Young Dolph", phrases: phrases))
        XCTAssertTrue(NounMentionWorth.keeps(
            "'Cause after Bankroll, Drakeo, Dolph, and Nip, feel like the next to die",
            phrases: phrases
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I wish Dolph would've Uber Eats them cookies instead",
            phrases: phrases
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "If Dolph show up in court, man these bitches",
            phrases: phrases
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "In my neighborhood, I run it (It's Dolph)",
            phrases: phrases
        ))
        XCTAssertTrue(NounMentionWorth.keeps("Dolph Gabbana", phrases: phrases))
    }

    func testPlayOnWordsStayOneSenseAndOffTheOtherTabs() {
        let words = NounBankStore.words(for: .wordplay)
        XCTAssertEqual(words, [
            "gotta cancer",
            "never dye",
            "sharin' ten",
            "jump the gates",
            "Kevin Gates",
            "Marriott her",
            "Marcus",
            "until my days end",
            "Dial soap",
            "QuikTrip",
            "Faith Evans",
            "own lane",
            "Tory",
            "sliders",
            "box him",
            "must die",
            "a sheet",
            "bring the real back",
            "relay",
            "Jake",
            "Fox News",
            "Jamie Fox",
            "Lohan",
            "call on",
            "Creed",
            "rock it",
            "heroine",
            "Celean",
            "by the night",
            "Suge Knight",
            "Smith and Will",
            "I kneel",
            "Shaquille",
            "Reid me",
            "Eric Reid",
            "a bride",
            "a knot",
            "leavin' a lot",
            "4 holes",
            "leave my heat",
            "my sons",
            "Pinky",
            "Nguyen",
            "Mer-Curry",
            "keyboard",
            "pillow talk",
            "Titans",
            "smoked the restaurants",
            "Radric Davis",
            "temp me",
            "the drop",
            "MAC lipstick",
            "texts",
            "tecs",
            "Tom Brady",
            "moving swift",
            "Taylor",
            "geeked",
            "Steve Urkel",
            "hangin' with glue",
            "over Yao",
            "dodge the block",
            "Patrick Beverly",
            "Houston rockets",
            "no type",
            "Swae Lee",
            "to the vet",
            "T. Hill",
            "chief it",
            "Jrue Holiday",
            "Greek",
            "bet to the bucks",
            "Pluto",
            "playing Trouble",
            "Aaron Donald",
            "Serge Ibaka",
            "block her",
            "OD",
            "Major Payne",
            "Gilbert Arenas",
            "Tony Hawk",
            "Training Day",
            "Kill Bill"
        ])
        let others = NounBankCategory.allCases.filter { $0 != .wordplay }.flatMap { NounBankStore.words(for: $0) }
        let folded = Set(others.map { $0.lowercased() })
        for word in words {
            XCTAssertFalse(folded.contains(word.lowercased()), word)
            let icon = NounBankCatalog.iconName(for: word, family: NounBankMark.normalize(word), category: .wordplay)
            XCTAssertTrue(icon.hasPrefix("noun-"), icon)
        }
        XCTAssertTrue(NounBankStore.words(for: .actors).contains("Damon Wayans"))
        XCTAssertNil(NounBankCatalog.canonical(for: "Major Payne", category: .wordplay))
        let plays = [
            "gotta cancer": "Cancer is cancel. The bald head sets it up.",
            "never dye": "Dye is die. The bald head sets it up.",
            "sharin' ten": "Sharin' ten is the Sheraton.",
            "jump the gates": "Jump the gates is the getaway, said beside Kevin Gates.",
            "Kevin Gates": "Kevin Gates is the Kevin in the line. Jump the gates is the getaway.",
            "Marriott her": "Marriott her is marry her.",
            "Marcus": "Marcus is Mariota. Marriott her is marry her.",
            "until my days end": "Days end is the Days Inn.",
            "Dial soap": "Dial tone is Dial soap.",
            "QuikTrip": "QuikTrip is the store and a quick trip.",
            "Faith Evans": "Faith in you is Faith Evans, Biggie's wife.",
            "own lane": "Own lane is Tory Lanez.",
            "Tory": "Tory is Tory Lanez, said beside my own lane.",
            "sliders": "Sliders is the slide, said beside the burgers.",
            "box him": "Box him is the corner trap, said beside McGregor.",
            "must die": "Must die is musty, said beside the armpits.",
            "a sheet": "A sheet is what the junkies want, said beside the blankets.",
            "bring the real back": "Bring the real back is the spine and the realness, said beside scoliosis.",
            "relay": "Relay is run that shit back like a race.",
            "Jake": "Jake is the Jake in the line. Relay is run that shit back.",
            "Fox News": "Fox News is Jamie Foxx, and air puts him on the channel.",
            "Jamie Fox": "Jamie Fox is the Jamie in the line. Air puts him on Fox News.",
            "Lohan": "Lohan is low on the designer lenses.",
            "call on": "Call on is who you reach, said beside Creed.",
            "Creed": "Creed is who you would call, said beside call on.",
            "rock it": "Rock it is rocket, said beside scientific.",
            "heroine": "Heroine is the heroin in the percs.",
            "Celean": "Celean is Celine and the lean. The bar says designer and promethazine.",
            "by the night": "By the night is Knight, said beside Suge.",
            "Suge Knight": "Suge Knight is the Suge in the line. By the night is Knight.",
            "Smith and Will": "Smith and Will is Will Smith, said beside the Smith & Wesson.",
            "I kneel": "I kneel is O'Neal. Shaquille.",
            "Shaquille": "Shaquille is O'Neal. I kneel is the bow.",
            "Reid me": "Reid me is read me. Eric Reid.",
            "Eric Reid": "Eric Reid is the Eric in the line. Reid me is read me.",
            "a bride": "A bride is the wedding and ringing the Glock.",
            "a knot": "A knot is the bump and the money.",
            "leavin' a lot": "Leavin' a lot is the dealership lot.",
            "4 holes": "Four holes is the Audi rings.",
            "leave my heat": "Leave my heat is the gun and the Miami Heat.",
            "my sons": "My sons is my suns. They leave him with tans.",
            "Pinky": "Pinky is the curved clip.",
            "Nguyen": "Nguyen is when.",
            "Mer-Curry": "Mer-Curry is mercury and Steph Curry.",
            "keyboard": "Keyboard is the type.",
            "pillow talk": "Pillow talk is the conversation, said beside the decorator.",
            "Titans": "Titans is the team, said beside a fifty.",
            "smoked the restaurants": "Smoked is the shooting. The restaurants are the food.",
            "Radric Davis": "Radric Davis is Gucci Mane, said beside the Gucci.",
            "temp me": "Temp me is tempt me, said beside the barber.",
            "the drop": "The drop is the jump on somebody, and the line says it is not the car.",
            "MAC lipstick": "MAC is the gun and the lipstick.",
            "texts": "Texts is the messages, said beside the tecs.",
            "tecs": "Tecs is the guns, said beside the texts.",
            "Tom Brady": "Tom Brady is the flat ball. Air puts it out.",
            "moving swift": "Moving swift is Taylor Swift.",
            "Taylor": "Taylor is Taylor Swift, said beside moving swift.",
            "geeked": "Geeked is high, said beside Urkel.",
            "Steve Urkel": "Steve Urkel is the geek, said beside geeked.",
            "hangin' with glue": "Hangin' with glue is the sticks that stick.",
            "over Yao": "Over Yao is Yao Ming, the tall shot. Dodge the block is the street and the defense.",
            "dodge the block": "Dodge the block is the street and the defense, said beside Yao Ming.",
            "Patrick Beverly": "Patrick Beverly is the Houston Rockets.",
            "Houston rockets": "Houston rockets is the team, said beside Patrick Beverly.",
            "no type": "No type is the Rae Sremmurd song, said beside Swae Lee.",
            "Swae Lee": "Swae Lee is the No Type song.",
            "to the vet": "To the vet is the Hellcat sounding like an animal.",
            "T. Hill": "T. Hill is Tyreek. Chief it is the smoke and the Chiefs.",
            "chief it": "Chief it is the smoke and the Chiefs, said beside T. Hill.",
            "Jrue Holiday": "Jrue Holiday is the holidays, said beside the bucks.",
            "Greek": "Greek is the Greek Freak, said beside the Bucks.",
            "bet to the bucks": "Bet to the bucks is the team, said beside Greek.",
            "Pluto": "Pluto is the planet that got separated.",
            "playing Trouble": "Playing Trouble is the dice game and the trouble.",
            "Aaron Donald": "Aaron Donald is the sack on the line.",
            "Serge Ibaka": "Serge Ibaka is the block, said beside block her.",
            "block her": "Block her is the phone and the defense, said beside Serge Ibaka.",
            "OD": "OD is the overdose, said beside Odell.",
            "Major Payne": "Major Payne is the Damon Wayans movie and major pain.",
            "Gilbert Arenas": "Gilbert Arenas is the gun in the locker.",
            "Tony Hawk": "Tony Hawk is the skate and the grind.",
            "Training Day": "Training Day is the Denzel movie used as the move.",
            "Kill Bill": "Kill Bill is the movie used as the sword and the kill."
        ]
        XCTAssertEqual(Set(plays.keys), Set(words))
        for (word, line) in plays {
            let standing = NounMentionBrief.standing(word: word, category: .wordplay)
            XCTAssertEqual(standing, line, word)
            XCTAssertFalse(standing.localizedCaseInsensitiveContains("picture"), word)
            let shown = NounMentionBrief.passage(
                word: word,
                category: .wordplay,
                phrases: [word],
                lines: ["Give my opp a bald head, we gotta cancer that"]
            )
            XCTAssertEqual(shown, standing, word)
        }

        let items = NounBankCatalog.items(for: .wordplay)
        func phrases(_ word: String) -> [String] {
            let item = items.first { $0.insertWord == word }
            return NounBankCatalog.mentionPhrases(for: item!, category: .wordplay)
        }
        let cancer = phrases("gotta cancer")
        XCTAssertTrue(cancer.contains("cancer her"))
        XCTAssertTrue(cancer.contains("cancer this bitch"))
        XCTAssertFalse(cancer.contains("cancer"))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Give my opp a bald head, we gotta cancer that",
            phrases: cancer
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "And I'm quick to cancer her like Newports",
            phrases: cancer
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Young Neno I'mma Have To Cancer This Bitch",
            phrases: cancer
        ))
        let dye = phrases("never dye")
        XCTAssertTrue(dye.contains("he dye"))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Like I got a bald head, I could never dye (Never die)",
            phrases: dye
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Like the opps got bald heads, I don’t really care if he dye (die)",
            phrases: dye
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talkin' hotel but I'm sharin' ten",
            phrases: phrases("sharin' ten")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Narcs hit the block I ain't talkin' Kevin but I'ma jump the gates",
            phrases: phrases("jump the gates")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I can't be takin' her home to mama, I ain't talkin' Marcus, I Marriott her",
            phrases: phrases("Marriott her")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talkin' bout a hotel, I stay real until my days end",
            phrases: phrases("until my days end")
        ))

        func halves(_ word: String) -> [String] {
            let item = items.first { $0.insertWord == word }
            return NounBankCatalog.mentionPhrases(for: item!, category: .wordplay)
                + NounBankCatalog.mentionPartners(for: item!)
        }
        XCTAssertEqual(phrases("Dial soap"), ["dial tone"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Dial soap" }!), ["soap"])
        XCTAssertFalse(phrases("Dial soap").contains("Dial soap"))
        XCTAssertEqual(
            BarHitsCatalogStore.mentionMatch(
                phrases: phrases("Dial soap"),
                also: NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Dial soap" }!)
            ),
            "(\"dial tone\") AND (\"soap\")"
        )
        XCTAssertEqual(phrases("Faith Evans"), ["faith in you"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Faith Evans" }!), ["biggie"])
        XCTAssertFalse(phrases("Faith Evans").contains("Faith Evans"))
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "QuikTrip" }!), ["quick trip"])
        XCTAssertEqual(phrases("Celean"), ["promethazine"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Celean" }!), ["designer"])
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talkin' soap but they gettin' the dial tone",
            phrases: halves("Dial soap")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I told QuikTrip, I need the stick to make a quick trip",
            phrases: halves("QuikTrip")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talkin' 'bout Biggie, I put my faith in you",
            phrases: halves("Faith Evans")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I ain't talking Tory, nigga, I been in my own lane",
            phrases: halves("own lane")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talking burgers, all my niggas sliders",
            phrases: halves("sliders")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "With the stick, box him right in the corner I ain't talkin' McGregor",
            phrases: halves("box him")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "These niggas must die and I ain't talkin' armpits",
            phrases: halves("must die")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "And all them junkies want is a sheet, ain't talkin' blankets",
            phrases: halves("a sheet")
        ))
        XCTAssertEqual(halves("bring the real back"), ["bring the real back", "scoliosis"])
        XCTAssertTrue(
            NounMentionWorth.keeps(
                "I ain't talkin' scoliosis, but let's bring the real back (Let's bring the real)",
                phrases: halves("bring the real back")
            ),
            halves("bring the real back").joined(separator: " | ")
        )
        XCTAssertTrue(NounMentionWorth.keeps(
            "I ain't talkin' 'bout Jake, run that shit back like relay",
            phrases: halves("relay")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talkin' Jamie, I'ma air 'em 'til he on Fox News",
            phrases: halves("Fox News")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talking Lohan, these designer lenses",
            phrases: halves("Lohan")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I don't have no one to call on, ain't talkin' Creed",
            phrases: halves("call on")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Book me for a show, I rock it, I ain't talkin' scientific",
            phrases: halves("rock it")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "They callin' me Pooh cause I think them percs got heroine in 'em",
            phrases: halves("heroine")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talkin' designer, I'm talkin' promethazine",
            phrases: halves("Celean")
        ))
        XCTAssertEqual(phrases("4 holes"), ["holes"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "4 holes" }!), ["audi"])
        XCTAssertEqual(phrases("pillow talk"), ["pillow talkin"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "pillow talk" }!), ["decorator"])
        XCTAssertEqual(phrases("Radric Davis"), ["radric"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Radric Davis" }!), ["gucci"])
        XCTAssertEqual(phrases("MAC lipstick"), ["mac"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "MAC lipstick" }!), ["lipstick"])
        XCTAssertEqual(phrases("leave my heat"), ["leave my heat", "leave the heat", "leave heat"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "leave my heat" }!), ["lebron"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "by the night" }!), ["suge"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "I kneel" }!), ["shaquille"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "a bride" }!), ["glock"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "a knot" }!), ["bumped"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "my sons" }!), ["tans"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Pinky" }!), ["curve"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "keyboard" }!), ["type"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Titans" }!), ["fifty"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "temp me" }!), ["barber"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "the drop" }!), ["no car"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Mer-Curry" }!), ["stephen"])
        XCTAssertTrue(NounMentionWorth.keeps(
            "They gon' be gone by the night like they Suge",
            phrases: halves("by the night")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "And I tote a Smith & Wesson, not a Smith and Will",
            phrases: halves("Smith and Will")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "And I'm like Shaquille, I bow my head and I kneel",
            phrases: halves("I kneel")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm like Eric, I don't do to much a talkin', it be hard for you to Reid me",
            phrases: halves("Reid me")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "We need a bride for this Glock 'cause we ringin' it out",
            phrases: halves("a bride")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I bumped my head 'cause that's how bad a nigga needed a knot",
            phrases: halves("a knot")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "The hood was like a dealership, I was leavin' a lot",
            phrases: halves("leavin' a lot")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Put 4 holes in that boy until I go and cop an Audi",
            phrases: halves("4 holes")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm not Lebron, I could never leave my heat",
            phrases: halves("leave my heat")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Rap niggas my sons, y’all be leavin' me with tans",
            phrases: halves("my sons")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Draco clip I call it Pinky, came with a curve",
            phrases: halves("Pinky")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "She shoot me middle fingers, I say nguyen like I'm Vietnamese",
            phrases: halves("Nguyen")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I’ll never kill Stephen, I’m higher than Mer-Curry",
            phrases: halves("Mer-Curry")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't the type to lose, ain't talkin' 'bout keyboard, I need to go back outer space",
            phrases: halves("keyboard")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Bae, I ain't no interior decorator, I don't do no pillow talkin'",
            phrases: halves("pillow talk")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "A fifty to see me, ain't talkin' 'bout Titans, you dig?",
            phrases: halves("Titans")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talking food, but I just smoked the restaurants",
            phrases: halves("smoked the restaurants")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "He got on so much Gucci, he must've signed to Radric Davis",
            phrases: halves("Radric Davis")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "If you play with me, it's empty, I barely let my barber temp me",
            phrases: halves("temp me")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Uh, I can't wait to get the drop, I ain't talkin' 'bout no car",
            phrases: halves("the drop")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I just bought a MAC, that shit reminded her of lipstick",
            phrases: halves("MAC lipstick")
        ))
        XCTAssertEqual(phrases("Jamie Fox"), ["jamie"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Jamie Fox" }!), ["fox news"])
        XCTAssertFalse(phrases("Jamie Fox").contains("Jamie Fox"))
        XCTAssertEqual(phrases("Kevin Gates"), ["kevin"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Kevin Gates" }!), ["jump the gates"])
        XCTAssertEqual(phrases("Suge Knight"), ["suge"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Suge Knight" }!), ["by the night"])
        XCTAssertEqual(phrases("Eric Reid"), ["eric"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Eric Reid" }!), ["reid me"])
        XCTAssertEqual(phrases("Jrue Holiday"), ["jrue"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Jrue Holiday" }!), ["holidays"])
        XCTAssertEqual(phrases("Houston rockets"), ["rockets"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Houston rockets" }!), ["patrick beverly"])
        XCTAssertEqual(phrases("Steve Urkel"), ["urkel"])
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Steve Urkel" }!), ["geeked"])
        XCTAssertTrue(NounMentionWorth.keeps(
            "Narcs hit the block I ain't talkin' Kevin but I'ma jump the gates",
            phrases: halves("Kevin Gates")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I can't be takin' her home to mama, I ain't talkin' Marcus, I Marriott her",
            phrases: halves("Marcus")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I ain't talking Tory, nigga, I been in my own lane",
            phrases: halves("Tory")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't talkin' Jamie, I'ma air 'em 'til he on Fox News",
            phrases: halves("Jamie Fox")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I ain't talkin' 'bout Jake, run that shit back like relay",
            phrases: halves("Jake")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I don't have no one to call on, ain't talkin' Creed",
            phrases: halves("Creed")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "They gon' be gone by the night like they Suge",
            phrases: halves("Suge Knight")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "And I'm like Shaquille, I bow my head and I kneel",
            phrases: halves("Shaquille")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm like Eric, I don't do to much a talkin', it be hard for you to Reid me",
            phrases: halves("Eric Reid")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain’t talkin’ texts, we pull up with tecs",
            phrases: halves("texts")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "We don't send texts, bring the TECs in",
            phrases: halves("tecs")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "If I air this bitch, it's goin' flat like I'm Tom Brady",
            phrases: halves("Tom Brady")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ayy, savage, but I been moving swift just like I'm Taylor",
            phrases: halves("moving swift")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ayy, savage, but I been moving swift just like I'm Taylor",
            phrases: halves("Taylor")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm geeked as hell, I get to feelin' like I'm Urkel",
            phrases: halves("geeked")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I always move around with sticks like I'm hangin' with glue",
            phrases: halves("hangin' with glue")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Like I'm tryna shoot over Yao Ming, I'm tryna dodge the block",
            phrases: halves("over Yao")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Like I'm tryna shoot over Yao Ming, I'm tryna dodge the block",
            phrases: halves("dodge the block")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Up in Houston with them rockets like I'm Patrick Beverly",
            phrases: halves("Patrick Beverly")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Up in Houston with them rockets like I'm Patrick Beverly",
            phrases: halves("Houston rockets")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I ain't got no type like I'm Rae Sremmurd or Swae Lee",
            phrases: halves("no type")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I ain't got no type like I'm Rae Sremmurd or Swae Lee",
            phrases: halves("Swae Lee")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Might take that Hellcat to the vet, sound like it's barkin'",
            phrases: halves("to the vet")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'ma smoke this opp pack and chief it just like I'm T. Hill",
            phrases: halves("T. Hill")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'ma smoke this opp pack and chief it just like I'm T. Hill",
            phrases: halves("chief it")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ayy, got them bucks up like I'm Jrue, only got fly for holidays",
            phrases: halves("Jrue Holiday")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I got love in Milwaukee, bet to the bucks like I'm Greek",
            phrases: halves("Greek")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I got love in Milwaukee, bet to the bucks like I'm Greek",
            phrases: halves("bet to the bucks")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Separate myself like I'm Pluto",
            phrases: halves("Pluto")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Not a game, we roll the dice, they think a nigga playing Trouble",
            phrases: halves("playing Trouble")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I feel just like I'm Aaron Donald, I'm tryna get a sack",
            phrases: halves("Aaron Donald")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "She keep on talkin' and bringin' me problems, now I gotta block her like Serge Ibaka",
            phrases: halves("Serge Ibaka")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "She keep on talkin' and bringin' me problems, now I gotta block her like Serge Ibaka",
            phrases: halves("block her")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm ballin' like I'm Odell, hope I don't OD",
            phrases: halves("OD")
        ))
        XCTAssertTrue(NounBankStore.words(for: .celebs).contains("Lindsay Lohan"))
        XCTAssertTrue(NounBankStore.words(for: .brands).contains("Celine"))
        XCTAssertTrue(NounBankStore.words(for: .substances).contains("heroin"))
        XCTAssertTrue(NounBankStore.words(for: .sports).contains("McGregor"))
    }

    func testAppsPocketKeepsOneChipPerService() {
        let apps = NounBankStore.words(for: .apps)
        for word in ["FaceTime", "Skype", "OoVoo", "Instagram", "Snapchat", "Uber", "Uber Eats"] {
            XCTAssertTrue(apps.contains(word), word)
        }
        let phrases = NounBankStore.words(for: .phrases)
        for word in [
            "FaceTime", "Skype", "OoVoo", "Instagram", "on Instagram", "Snapchat", "TikTok",
            "OnlyFans", "MySpace", "WorldStar", "TMZ", "Shade Room", "Airbnb", "Pro Tools"
        ] {
            XCTAssertFalse(phrases.contains(word), word)
        }
        XCTAssertTrue(NounBankStore.words(for: .money).contains("cashapp"))
        XCTAssertTrue(NounBankStore.words(for: .money).contains("zelle"))
        XCTAssertTrue(NounBankStore.words(for: .brands).contains("iPhone"))
        XCTAssertTrue(NounBankStore.words(for: .games).contains("PlayStation"))
        XCTAssertFalse(apps.contains("iPhone"))
        XCTAssertFalse(apps.contains("PlayStation"))
        XCTAssertFalse(apps.contains("cashapp"))
        XCTAssertFalse(apps.contains("zelle"))

        let ig = NounBankCatalog.items(for: .apps).first { $0.insertWord == "Instagram" }
        let mentions = NounBankCatalog.mentionPhrases(for: ig!, category: .apps).map { $0.lowercased() }
        XCTAssertTrue(mentions.contains("the gram"))
        XCTAssertTrue(mentions.contains("on ig"))
        let uber = NounBankCatalog.items(for: .apps).first { $0.insertWord == "Uber" }
        XCTAssertEqual(
            NounBankCatalog.mentionExclusions(for: uber!, category: .apps).map { $0.lowercased() },
            ["uber eats"]
        )
        XCTAssertEqual(NounBankCatalog.canonical(for: "BBM", category: .apps), "BlackBerry Messenger")
        XCTAssertEqual(NounBankCatalog.canonical(for: "Musically", category: .apps), "Musical.ly")
        let faceTime = NounMentionBrief.standing(word: "FaceTime", category: .apps)
        XCTAssertTrue(faceTime.contains("Apple"))
        XCTAssertFalse(faceTime.contains("is an app or a service"))
        XCTAssertEqual(apps.count, 62)
    }

    func testLooksPocketKeepsTraitsAndOneChipPerWayOfSayingIt() {
        let looks = NounBankStore.words(for: .looks)
        for word in ["Dimples", "Colgate smile", "Brown skin", "She tall", "Long legs", "in HD", "in 3D", "Lightskin", "Redbone"] {
            XCTAssertTrue(looks.contains(word), word)
        }
        let woman = NounBankStore.words(for: .woman)
        XCTAssertTrue(woman.contains("stallion"))
        XCTAssertFalse(woman.contains("lightskin"))
        XCTAssertFalse(woman.contains("darkskin"))
        XCTAssertFalse(woman.contains("redbone"))
        XCTAssertFalse(woman.contains("yellow bone"))
        XCTAssertFalse(looks.contains("stallion"))
        XCTAssertTrue(NounBankStore.words(for: .phrases).contains("six feet"))
        XCTAssertFalse(looks.contains("six feet"))
        XCTAssertFalse(looks.contains("tall"))
        XCTAssertFalse(looks.contains("smile"))

        let smile = NounBankCatalog.items(for: .looks).first { $0.insertWord == "Colgate smile" }
        let smilePhrases = NounBankCatalog.mentionPhrases(for: smile!, category: .looks).map { $0.lowercased() }
        XCTAssertTrue(smilePhrases.contains("colgate"))
        let tall = NounBankCatalog.items(for: .looks).first { $0.insertWord == "She tall" }
        let tallPhrases = NounBankCatalog.mentionPhrases(for: tall!, category: .looks).map { $0.lowercased() }
        XCTAssertTrue(tallPhrases.contains("tall woman"))
        XCTAssertFalse(tallPhrases.contains("tall"))
        let skin = NounBankCatalog.items(for: .looks).first { $0.insertWord == "Lightskin" }
        let skinPhrases = NounBankCatalog.mentionPhrases(for: skin!, category: .looks).map { $0.lowercased() }
        XCTAssertTrue(skinPhrases.contains("light skin"))
        let dimples = NounMentionBrief.standing(word: "Dimples", category: .looks)
        XCTAssertTrue(dimples.localizedCaseInsensitiveContains("cheek"))
        XCTAssertFalse(dimples.contains("way a person looks"))
        XCTAssertEqual(looks.count, 36)
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: NounBankCatalog.makeItem(word: "coke", category: .drugs, sortIndex: 0), category: .drugs).map { $0.lowercased() }.contains("coke bottle"))
    }

    func testNounTabsGroupEveryChipWithItsPeople() {
        for category in NounBankCategory.allCases {
            let words = NounBankStore.words(for: category)
            let sections = NounBankSections.sections(for: category)
            let flat = sections.flatMap(\.words)
            XCTAssertEqual(flat.count, words.count, category.rawValue)
            XCTAssertEqual(Set(flat), Set(words), category.rawValue)
            let titles = sections.map(\.title)
            XCTAssertEqual(Set(titles).count, titles.count, "\(category.rawValue) titles")
            XCTAssertTrue(sections.allSatisfy { !$0.title.isEmpty && !$0.words.isEmpty }, category.rawValue)
        }

        let shows = Dictionary(uniqueKeysWithValues: NounBankSections.sections(for: .characters).map { ($0.title, $0.words) })
        XCTAssertEqual(shows["Scarface"] ?? [], ["Scarface", "Tony Montana"])
        XCTAssertEqual(shows["Friday"] ?? [], ["Deebo", "Big Worm", "Craig"])
        XCTAssertEqual(shows["Martin"] ?? [], ["Sheneneh", "Bruh-Man", "Pam", "Gina", "Tommy", "Hustle Man", "Otis"])
        XCTAssertEqual(shows["Madea"] ?? [], ["Madea"])
        XCTAssertEqual(shows["The Godfather"] ?? [], ["Don Corleone", "Michael Corleone"])
        XCTAssertEqual(shows["Marvel"] ?? [], ["Black Panther", "Thor", "Thanos", "Wolverine", "Hulk", "Iron Man", "Spider-Man"])

        let teams = Dictionary(uniqueKeysWithValues: NounBankSections.sections(for: .nba).map { ($0.title, $0.words) })
        XCTAssertEqual(teams["Lakers"] ?? [], ["Kobe", "Shaq", "Magic Johnson", "Kareem", "Wilt", "Lamar Odom"])
        XCTAssertFalse((teams["Lakers"] ?? []).contains("LeBron"))
        XCTAssertEqual(teams["Cavaliers"] ?? [], ["LeBron", "Kyrie"])

        let attitude = NounBankSections.sections(for: .wrestlers).first { $0.title == "Attitude Era" }
        XCTAssertEqual(
            Set(attitude?.words ?? []),
            Set(["Steve Austin", "Stone Cold", "The Rock", "Undertaker", "Triple H", "HBK", "Kurt Angle", "Jeff Hardy"])
        )

        let play = NounBankSections.sections(for: .wordplay)
        XCTAssertEqual(play.count, 1)
        XCTAssertEqual(play[0].words, NounBankStore.words(for: .wordplay))
    }
}
