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
        XCTAssertEqual(NounBankGroup.containing(.motorcycles), .vehicles)
        XCTAssertEqual(NounBankGroup.vehicles.categories, [.cars, .motorcycles, .boats, .aviation, .military])
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

    func testShortNamesStayOnThePersonTheyName() throws {
        let bruce = try XCTUnwrap(NounBankCatalog.items(for: .sports).first { $0.insertWord == "Bruce Lee" })
        let brucePhrases = NounBankCatalog.mentionPhrases(for: bruce, category: .sports).map { $0.lowercased() }
        XCTAssertTrue(brucePhrases.contains("bruce lee"))
        XCTAssertFalse(brucePhrases.contains("bruce"))
        XCTAssertFalse(brucePhrases.contains("bruce wayne"))
        XCTAssertFalse(brucePhrases.contains("bruce banner"))
        let bruceMatch = BarHitsCatalogStore.mentionMatch(phrases: brucePhrases)
        XCTAssertFalse(bruceMatch?.contains("\"bruce\"") == true)

        let hulk = try XCTUnwrap(NounBankCatalog.items(for: .characters).first { $0.insertWord == "Hulk" })
        XCTAssertTrue(
            NounBankCatalog.mentionPhrases(for: hulk, category: .characters).map { $0.lowercased() }.contains("bruce banner")
        )
        let batman = try XCTUnwrap(NounBankCatalog.items(for: .characters).first { $0.insertWord == "Batman" })
        XCTAssertTrue(
            NounBankCatalog.mentionPhrases(for: batman, category: .characters).map { $0.lowercased() }.contains("bruce wayne")
        )

        let sam = try XCTUnwrap(NounBankCatalog.items(for: .actors).first { $0.insertWord == "Samuel L. Jackson" })
        let samPhrases = NounBankCatalog.mentionPhrases(for: sam, category: .actors).map { $0.lowercased() }
        XCTAssertTrue(samPhrases.contains("sam l"))
        XCTAssertTrue(samPhrases.contains("sam l jackson"))
        XCTAssertTrue(samPhrases.contains("samuel jackson"))

        let mj = try XCTUnwrap(NounBankCatalog.items(for: .artists).first { $0.insertWord == "Michael Jackson" })
        let mjPhrases = NounBankCatalog.mentionPhrases(for: mj, category: .artists).map { $0.lowercased() }
        XCTAssertTrue(mjPhrases.contains("michael jackson"))
        XCTAssertFalse(mjPhrases.contains("jackson"))
        XCTAssertFalse(mjPhrases.contains("sam l"))
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
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: gator).map { $0.lowercased() }, ["gator", "gators"])
        XCTAssertTrue(animals.contains("shark"))
        XCTAssertFalse(animals.contains("sharks"))
        XCTAssertTrue(animals.contains("tiger"))
        XCTAssertFalse(animals.contains("tigers"))
        XCTAssertTrue(animals.contains("hog"))
        XCTAssertFalse(animals.contains("hogs"))
        let tiger = try XCTUnwrap(NounBankCatalog.items(for: .animals).first { $0.insertWord == "tiger" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: tiger).map { $0.lowercased() }.contains("tigers"))
        let hog = try XCTUnwrap(NounBankCatalog.items(for: .animals).first { $0.insertWord == "hog" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: hog).map { $0.lowercased() }.contains("hogs"))
        let shark = try XCTUnwrap(NounBankCatalog.items(for: .animals).first { $0.insertWord == "shark" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: shark).map { $0.lowercased() }.contains("sharks"))
        let pitBull = try XCTUnwrap(NounBankCatalog.items(for: .animals).first { $0.insertWord == "pit bull" })
        XCTAssertEqual(pitBull.family, "pit bull")
        XCTAssertTrue(NounBankStore.words(for: .cars).contains("Hellcat"))
        XCTAssertTrue(NounBankStore.words(for: .woman).contains("stallion"))
        XCTAssertFalse(animals.contains("stallion"))
        XCTAssertTrue(NounBankStore.words(for: .characters).contains("Simba"))
        XCTAssertTrue(NounBankStore.words(for: .drugs).contains("fishscale"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("Duck"))
        XCTAssertTrue(NounBankStore.words(for: .opps).contains("the rats"))
        XCTAssertFalse(animals.contains("rats"))
        let rat = try XCTUnwrap(NounBankCatalog.items(for: .animals).first { $0.insertWord == "rat" })
        XCTAssertTrue(NounBankCatalog.mentionPhrases(for: rat).map { $0.lowercased() }.contains("rats"))
        XCTAssertTrue(NounBankCatalog.mentionExclusions(for: rat).map { $0.lowercased() }.contains("the rats"))
    }

    func testInsectsStayTheBugAndNotTheOtherSense() throws {
        let insects = NounBankStore.words(for: .insects)
        for word in ["bee", "bumble bee", "roach", "ant", "spider", "tick", "lice", "mosquito", "centipede"] {
            XCTAssertTrue(insects.contains(word), word)
        }
        for mixed in ["ants", "ticks", "fly", "roaches", "cockroaches", "roache", "spiders", "louse", "bumblebee", "beetle", "caterpillar"] {
            XCTAssertFalse(insects.contains(mixed), mixed)
        }
        let roach = try XCTUnwrap(NounBankCatalog.items(for: .insects).first { $0.insertWord == "roach" })
        XCTAssertEqual(roach.label, "roach")
        XCTAssertEqual(roach.family, "roach")
        XCTAssertEqual(roach.icon, "noun-roaches")
        let bee = try XCTUnwrap(NounBankCatalog.items(for: .insects).first { $0.insertWord == "bee" })
        XCTAssertEqual(bee.icon, "noun-bee")
        XCTAssertNotEqual(bee.icon, roach.icon)
        XCTAssertEqual(
            NounBankCatalog.mentionPhrases(for: roach).map { $0.lowercased() },
            ["roach", "roaches", "cockroach", "cockroaches"]
        )
        XCTAssertEqual(
            NounBankCatalog.mentionExclusions(for: roach).map { $0.lowercased() },
            ["in the roach", "roach clip"]
        )
        XCTAssertFalse(NounBankStore.words(for: .animals).contains("roaches"))
        XCTAssertFalse(NounBankStore.words(for: .animals).contains("roach"))
        let ant = try XCTUnwrap(NounBankCatalog.items(for: .insects).first { $0.insertWord == "ant" })
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: ant).map { $0.lowercased() }, ["ant", "ants"])
        let spider = try XCTUnwrap(NounBankCatalog.items(for: .insects).first { $0.insertWord == "spider" })
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: spider).map { $0.lowercased() }, ["spider", "spiders"])
        XCTAssertEqual(NounBankCatalog.mentionExclusions(for: spider).map { $0.lowercased() }, ["spider-man", "spiderman"])
        let tick = try XCTUnwrap(NounBankCatalog.items(for: .insects).first { $0.insertWord == "tick" })
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: tick).map { $0.lowercased() }, ["tick", "ticks"])
    }

    func testFoodStaysThePlateAndNotTheOtherSense() throws {
        let food = NounBankStore.words(for: .food)
        for word in [
            "fried chicken", "chicken wings", "shrimp", "lobster", "lobster tail", "swordfish",
            "filet", "filet mignon", "taco", "fries", "french fries", "pancakes",
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
            "donut", "donuts", "pancake", "tacos"
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
        let taco = try XCTUnwrap(NounBankCatalog.items(for: .food).first { $0.insertWord == "taco" })
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: taco).map { $0.lowercased() }, ["taco", "tacos"])
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
            "grill", "gold grill", "gold fronts", "gold teeth", "gold tooth",
            "golds", "fangs", "my fangs", "teeth gold", "ice grill", "veneers", "porcelain"
        ] {
            XCTAssertTrue(grills.contains(word), word)
        }
        for mixed in ["grillz", "grills", "fronts", "crowns", "vampire", "bustdown", "slugs", "dentist", "dental", "the grill"] {
            XCTAssertFalse(grills.contains(mixed), mixed)
        }
        let grill = try XCTUnwrap(NounBankCatalog.items(for: .grills).first { $0.insertWord == "grill" })
        XCTAssertEqual(grill.label, "grill")
        XCTAssertNil(grill.canonical)
        XCTAssertEqual(grill.family, "grill")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: grill).map { $0.lowercased() }, ["grill", "grills"])
        XCTAssertEqual(NounBankCatalog.mentionExclusions(for: grill).map { $0.lowercased() }, ["my grills"])
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
            "dreads", "dreadlocks", "dreadlock", "waves", "temp fade", "braid", "lace front",
            "weave", "wigs", "lineup", "bangs", "bald head", "blonde", "blonde hair", "nappy",
            "haircut", "braid", "braided", "barbershop", "the barber"
        ] {
            XCTAssertTrue(hair.contains(word), word)
        }
        for mixed in [
            "locs", "locks", "braids", "fade", "wig", "durag", "wave cap", "lemonade", "bundles",
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
        XCTAssertEqual(braid.family, "braid")
        XCTAssertEqual(NounBankCatalog.mentionPhrases(for: braid).map { $0.lowercased() }, ["braid", "braids"])
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
        XCTAssertEqual(substances.count, 44)
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
        XCTAssertEqual(feelings.count, 101)
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
        let cars = NounBankStore.words(for: .cars)
        let motorcycles = NounBankStore.words(for: .motorcycles)
        for word in ["Harley", "Harley-Davidson", "Ducati", "Yamaha", "Kawasaki", "Can-Am", "Suzuki", "Indian", "bike", "BMX bike", "dirt bike", "Ninja", "R1", "GSXR"] {
            XCTAssertFalse(brands.contains(word), word)
            XCTAssertFalse(cars.contains(word), word)
            XCTAssertTrue(motorcycles.contains(word), word)
        }
        XCTAssertTrue(cars.contains("BMW"))
        XCTAssertFalse(motorcycles.contains("BMW"))
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
                "BMW", "Mercedes", "Ford", "Honda", "Toyota", "Lexus", "Nissan"
            ]),
            (.motorcycles, [
                "Harley", "Harley-Davidson", "Ducati", "Yamaha", "Kawasaki", "Can-Am",
                "Suzuki", "Indian", "bike", "BMX bike", "dirt bike", "Ninja", "R1", "GSXR"
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
            "Kill Bill",
            "billboard",
            "Quagmire",
            "astronauts",
            "ranned off",
            "drop my shell",
            "O'Neal",
            "Maybach curtains",
            "earplugs",
            "we ball",
            "cards I'm dealt",
            "Tommy tucked",
            "darkest times",
            "bag out",
            "hit our target",
            "from the rear",
            "bitin' my style",
            "not a serial killer",
            "think 'bout death",
            "rollin' loud",
            "Glock-9",
            "like a battery",
            "came sooner",
            "one coat",
            "napless",
            "see Pearl",
            "talkin Pearl",
            "an addict",
            "don't pretend",
            "mob ties",
            "for that brick",
            "assassinate him",
            "let it pan out",
            "my diamonds",
            "chargin' my career",
            "your presence",
            "incomplete",
            "takin' medicine",
            "brought my lawyer",
            "lean go",
            "my umbrella",
            "Hot dig",
            "with the Migos",
            "like Offset",
            "without the sticks",
            "runnin' like Hillary",
            "switch the beats",
            "envy me",
            "music app",
            "like game",
            "raid us",
            "use a pencil",
            "back and forth to court",
            "get abused",
            "cash comin'",
            "holiday eve",
            "head was weak",
            "I'm tracin'",
            "see a ring",
            "no flowers",
            "drake kickback",
            "wearing a trojan",
            "a Spartan",
            "tote 30",
            "on his trail",
            "shot a buffalo",
            "we packers",
            "pourin' up dirty",
            "vacuum seals",
            "Jr. Smith",
            "fee on her",
            "beat the jury",
            "curve me",
            "like Kyler Murray",
            "no Polo",
            "killing beats",
            "black mamba",
            "like Brady",
            "knockout Roosevelt",
            "like J.J Watts",
            "like Michael Oher",
            "in my home like Patrick",
            "like I'm Rondo",
            "it's a vert",
            "like Andre",
            "like Naruto",
            "like Wi-Fi",
            "like Jill Scott",
            "cloned Michael Jordan",
            "like Forest",
            "freekin' on you",
            "like I'm Tyler",
            "like the Cardinals",
            "on Rhude",
            "like I'm Gilbert",
            "like Tekashi",
            "like I'm jaggered",
            "Snow in the Bluff",
            "like Kobe Bryant",
            "like O-Dog",
            "like Doc Dre",
            "buy him the rockets",
            "like Neo",
            "like I'm John Wall",
            "like I'm Lonzo Ball",
            "like Secret Service",
            "like Johnnie Cochran",
            "like Raymond",
            "like I was Hot Sauce",
            "drive her crazy",
            "Dream Chaser",
            "like Diddy",
            "like Randolph",
            "like Similac",
            "like Thomas",
            "like Nipsey",
            "no limit",
            "in the ghost",
            "droppin' dimes",
            "like Huskies",
            "fightin' cases",
            "drum like I'm Nick Cannon",
            "like Anderson Silva",
            "feeling like curry",
            "Fifty Dub",
            "eighty-one",
            "the O2",
            "6 a.m.",
            "two up",
            "the billis",
            "Chef Curry",
            "trigger fingers",
            "William Wesley",
            "Energizer",
            "water gun",
            "girl's tour",
            "Midas",
            "Eurostep",
            "ambidex",
            "use your name",
            "Fabo",
            "money trees",
            "pound cake",
            "stopwatch",
            "God bless you",
            "on Glee",
            "George Strait",
            "Kenny head",
            "overlooked him",
            "Allen Iverson",
            "actin' days",
            "bad then",
            "a Kim",
            "Advil",
            "the ink",
            "Makaveli",
            "balled",
            "McLovin",
            "find me, Nemo",
            "Bueller",
            "Space Jam",
            "savin' face",
            "Grateful like Jerry",
            "Cape Town",
            "iron is up",
            "switched place",
            "Paramore",
            "a buzz",
            "hood dreams",
            "can't even act",
            "king cobra",
            "runneth over",
            "roller coaster",
            "four shadows",
            "two percent",
            "06er",
            "like BTS",
            "poor me",
            "patience",
            "one accord",
            "pallbearers",
            "B-roll",
            "pack Bone",
            "lion is loose",
            "Onyx",
            "wire transfers",
            "Bulgari",
            "from the ends",
            "loadin' rebuttals",
            "give me fifty",
            "how it seems",
            "in a scope",
            "degenerates",
            "checks owed",
            "TTC metro",
            "tradin' places",
            "your noodle",
            "the bark",
            "size-seven",
            "Gucci Row",
            "Papi champú",
            "like wrappers",
            "bigger fish",
            "buddin' careers",
            "shit is complex",
            "you and Cole",
            "double click",
            "The Fall Off",
            "W's and M's",
            "Sureños",
            "off us",
            "away from the bars",
            "lime green",
            "Domina",
            "Pee M's",
            "holdin' you down",
            "you and I",
            "big three",
            "Detroit Lions",
            "like Yahtzee",
            "net a Bey",
            "Pink Floyd",
            "AMBER Alert",
            "head in the clouds",
            "eight karats",
            "cup holder",
            "Big Benjamins",
            "let her open 'em",
            "make change",
            "Sinatra lifestyle",
            "like Snoopy",
            "place in Jamaica",
            "patty cake",
            "Cinco de Mayo",
            "hammers come out",
            "farfetched",
            "staple in the game",
            "in her organs",
            "feelin' bulletproof",
            "like it's wagyu",
            "sawed-off",
            "throwin' up six",
            "more Chrome",
            "talkin' in Dutch",
            "spangled banner",
            "too much joggin'",
            "Rotterdam trip",
            "broken necklace",
            "forecastin' tornadoes",
            "American Expresser",
            "call the bluff",
            "rippin' markers",
            "Champagne popper",
            "dim some",
            "break your Kevin Hart",
            "the one tankin'",
            "like Shakira",
            "heart is on my sleeve",
            "loose with the lyin'",
            "Casper the Ghost",
            "reigning supreme",
            "not believers",
            "boot toes",
            "will me to defeat",
            "like Antetokounmpo",
            "like Copenhagen",
            "up in arrivals",
            "no stick in the ride",
            "eighteen karats",
            "like silos",
            "peas and rice",
            "need vaccine",
            "feel like Dido",
            "medium guys",
            "Toodaloo",
            "amazin' grace",
            "double play",
            "booster seat",
            "lie to even tie",
            "seize the day",
            "we engaged",
            "this ain't Minute Maid",
            "never fade",
            "money is young",
            "see no time",
            "soft white",
            "duckin' indictments",
            "no Canseco",
            "no misses",
            "catch up to the slaps",
            "on the lap'",
            "tryna campaign",
            "teach you the ropes",
            "poker face",
            "plot a return",
            "bit the hand",
            "talk keys",
            "caps lock",
            "the Drake show",
            "call up a Stark",
            "gettin' ate",
            "not a BNB",
            "every twenty-four",
            "21 my addy",
            "like we DMC",
            "than the plot",
            "last ones laughin'",
            "not the Messi",
            "my attorney",
            "like New Jersey",
            "than Biscayne",
            "like 6:30",
            "no glaucoma",
            "just C-4in'",
            "got a SIG",
            "like Tila Tequila",
            "K-Y",
            "cheesehead",
            "Chuck Inglish",
            "actin' like Book",
            "anyone home",
            "we droppin'",
            "we sockin'",
            "eatin' a goat",
            "standin' on bidiness",
            "we whoppin'",
            "like Jeopardy",
            "I'm a prodigy",
            "like NextSelection",
            "like van Nistelrooy",
            "Scary Hours",
            "nose bleedin'",
            "may see us",
            "Frito Lays",
            "freed the slaves",
            "heart hardens",
            "pop it for real",
            "the spill",
            "like some green tea",
            "when it's silk",
            "oui, oui",
            "heat seats",
            "BC baby",
            "mention the O",
            "life to the O",
            "Coach K",
            "the V's",
            "Birkin is croc",
            "got the cakes",
            "lean in soda",
            "on-site like W-W-W",
            "like dot-com",
            "drawin' conclusions",
            "summers did I run",
            "four gunshot",
            "lay down when you make bed",
            "gotta punt",
            "Ice time",
            "gettin' secondhand",
            "mall with a rat",
            "Chase Bank",
            "got the hookup",
            "Slauson or Watts",
            "cash cow",
            "Cindy, ya bad",
            "two cougars",
            "Kris Kross",
            "two cents",
            "find you face down",
            "cop pleas",
            "deep-seated",
            "posted receipts",
            "bone to pick",
            "than MIT",
            "thank-me-later",
            "act like sheeps",
            "guzzle a Guinness",
            "it was an exhibit",
            "ovens and kitchens",
            "barrel was smoking",
            "body double",
            "nothing was the same",
            "like I'm Miss Adele",
            "on the 33rd",
            "cursin' me",
            "Sandra's rose",
            "like Charlamagne",
            "opened up a can",
            "like I'm Amber Rose",
            "like I'm Nixon",
            "illuminated angel",
            "rider in my system",
            "with a V in the middle",
            "key to the city",
            "went halal",
            "aidin' Ross",
            "do buy everything",
            "rack up a tab",
            "like the seven seas",
            "like Little Caesars",
            "like a carabiner",
            "like the Village People",
            "like I'm Lebanese",
            "like little leaguers",
            "sixth sense",
            "like the Philly Eagles",
            "Penny Lane",
            "makin' light of my situation",
            "money tree",
            "all my children",
            "all my millions",
            "be my strudel",
            "two black cars",
            "like it's a Spalding",
            "bowl a strike",
            "lose to love",
            "write my endin'",
            "bad boys that wasn't pretendin'",
            "tea with the stars",
            "swim with the sharks",
            "cut the tie",
            "like I'm Kris Kringle",
            "round the facts",
            "off a Quay",
            "he might clock",
            "need supervision",
            "drop addiction",
            "Bahamas, MIA",
            "hit JFK",
            "motion sickness",
            "top two",
            "I'm not two",
            "it's not one",
            "take a knee",
            "high note",
            "hearin' clicks",
            "out of the picture",
            "necklace a Frank",
            "came with a bar",
            "shawty BDs",
            "she biased",
            "other men are practice",
            "more M's",
            "less L's",
            "do no verses",
            "I baited",
            "meet PARTY",
            "watch face",
            "like a villain",
            "Nemo in the ocean",
            "like I'm Hulk Hogan",
            "parachuting molly",
            "with a dictionary",
            "like NASA",
            "when I'm 70",
            "need addressin'",
            "shackin' together",
            "like a squid",
            "blue in the face",
            "blue in the safe",
            "like a hockey coach",
            "bag with a pipe",
            "rackin' my brain",
            "red button",
            "do right and kill everything",
            "like I'm gettin' graded",
            "drive is dedicated",
            "not a graduation",
            "pad the stats",
            "hard pill to swallow",
            "like a revelation",
            "like some vegetation",
            "like a vaccination",
            "like I'm Howard Hughes",
            "pgLang on mute",
            "deadbeats",
            "like presto",
            "only blessed",
            "like man had flu",
            "seein' a ghost",
            "six-six",
            "on that live",
            "nosebleeds",
            "trunk is in my hood",
            "right my wrongs",
            "eatin' Caesar",
            "no Kente",
            "came with a pole",
            "Canseco the mix",
            "cheaper to keep her",
            "your Finsta",
            "like he snotty",
            "lovin' the crew",
            "like Gretzky",
            "for the 'Gram",
            "like bless me",
            "Chat's behind",
            "like Waldo",
            "Terry Fox",
            "I'll cater to you",
            "like some premises",
            "like a brake light",
            "fishing for some answers",
            "used to do was front",
            "grey in our conversation",
            "LOLOL",
            "not a GOAT",
            "still the motto",
            "if I'm lyin'",
            "tennis ball",
            "pickin' a lock",
            "Adidas to 'em",
            "sell pies",
            "diamondbacks",
            "about the practice",
            "last resort",
            "like abbreviations",
            "be cremated",
            "Infrared",
            "in the can",
            "like a tire",
            "like a bagel",
            "three the kid",
            "clip us",
            "when the hook drop",
            "all I need is a whistle",
            "flip the F out",
            "pyramid schemes",
            "impress ya",
            "live in Singapore",
            "like the kitchen drawer",
            "who sewed the buttons",
            "like a coat",
            "like a Coke",
            "like a ghost",
            "richie like Lionel",
            "got flipped",
            "the six upside down",
            "for the Grahams",
            "Armor All",
            "Macaulay Culkin",
            "sweeter the berry",
            "reality checks",
            "rest of my commas",
            "time on your hands",
            "like I'm J. Cole",
            "get RICO'd",
            "like he Bart",
            "turned duppy",
            "real vamp",
            "pint of Tech",
            "run fades",
            "hold hands",
            "take sand",
            "cookin' that Cersei",
            "this is Gustavo",
            "nothin' is sweet",
            "dust a man",
            "I'm a gymnast",
            "without the T-Y",
            "show the waves",
            "spoiled rotten",
            "Mekhi Phif",
            "lotta class",
            "stay slitherin",
            "other hand",
            "like Vert",
            "Jung body",
            "Pretty Ricky",
            "more tracks",
            "in the crib",
            "like a priest",
            "is magnolia",
            "got demoitis",
            "like Russell",
            "burst a bubble",
            "to the cross",
            "like I'm Kobe",
            "X and O",
            "from Jupiter",
            "on my boardwalk",
            "like half days",
            "air miles",
            "devil in a tight dress",
            "I'm gunproof",
            "finally broke up",
            "hang me out to dry",
            "outta hand",
            "cut ties",
            "don't fade away",
            "Kappa Alpha",
            "future and a past",
            "no-long-talker",
            "we Chucky somethin'",
            "skull gets hot",
            "cover they head",
            "paid by the letter",
            "own hip-hop",
            "like Dell and Windows",
            "Chromazz",
            "saved by the bell",
            "doin' macarena",
            "hit your noodle",
            "like MacGyver",
            "from the snow",
            "cha-cha slide",
            "breakin' a Brink's",
            "he's a wasteman",
            "missin' was Aaliyah",
            "Addy in my system",
            "don't see a savage",
            "Loverboy",
            "clique about to blow",
            "triple-double-Russ",
            "caught the hands",
            "a Cheerio",
            "wishin' death on me",
            "crack game",
            "just swangin'",
            "not holdin' you down",
            "you're mine",
            "exams for the boy",
            "see the future",
            "dodge sentences",
            "play my part too",
            "like the one-two",
            "flippin' the script",
            "Cartier pen",
            "doin' backflips",
            "bought my dawg a Rollie",
            "not kiddin'",
            "CC's on that ho",
            "clipped the hurdle",
            "Prince of Persia",
            "flirting with the thirty",
            "red-shirted",
            "all about my brothers",
            "like a campus",
            "empty crib in my empty crib",
            "lookin' hot",
            "through a speaker",
            "Houston, we got a problem",
            "bended knee",
            "grease me",
            "bidin' my time",
            "gettin' bold",
            "dumb rich",
            "Tiffany on you",
            "Fela Kuti",
            "next to Kobe",
            "cloud nine",
            "little lamb",
            "eyes blood red",
            "woke shit",
            "movin' like dogs",
            "fit off the mannequin",
            "boys tell stories",
            "not a home",
            "show ID",
            "umbrellaed up",
            "take my crown",
            "turnin' papers",
            "I'm the greatest",
            "stunt double",
            "TLC shit",
            "two wrongs",
            "two-tones",
            "skirt on a whip",
            "body is tea",
            "twenty-V-one",
            "witch one",
            "empty clips",
            "key ingredient",
            "LIV after church",
            "not in Kansas",
            "hittin' swishes",
            "my vice",
            "whole lot of M's",
            "Haffa B",
            "executives calls",
            "like a BBL",
            "Franklin Saint",
            "ho-ho-hoes",
            "under the mat",
            "hit the jackpot",
            "so official",
            "go to Venus",
            "racks like Serena",
            "buy the tires",
            "what a time",
            "sleepin' pattern",
            "like the truck",
            "feathers they pluck",
            "thousand islands",
            "go ham",
            "Mo City trip",
            "season pass",
            "a flower would grow",
            "October's Own",
            "wings of an angel",
            "like no hair",
            "break down ya d's",
            "return of the mack",
            "sonnin' them",
            "Big Pimpin'",
            "ex-men",
            "thirty-piece",
            "never get dirty",
            "exes live in Texas",
            "eat each other",
            "like a lollipop",
            "get on E",
            "Ben Frank' getter",
            "got the YSL",
            "fuckin' with the mob ties",
            "pardon my reach",
            "burn a bridge",
            "go deaf",
            "dash to my Dame",
            "draped up",
            "water for the D's",
            "windows down",
            "everything is kosher",
            "Courtney Love",
            "made a nickel",
            "distant lovers",
            "Boise state",
            "the Shade Room",
            "Dick Tracy",
            "pen-pal",
            "one-hunnid",
            "not one fronted",
            "head office",
            "king in Jamaica",
            "gone 'til November",
            "FuelBand",
            "pizza man",
            "nickels for my thoughts",
            "the cashier",
            "Maya Angelou",
            "glue stick",
            "pulling strings",
            "not Nintendo",
            "take a shot for me",
            "all the care",
            "Polo isn't at my session",
            "the game needs change",
            "for all the dogs",
            "Pete's sakes",
            "bury me alive",
            "sign the contracts",
            "in my grave",
            "feel entitled",
            "play hurt",
            "saving for Caribana",
            "brainwashed",
            "my windshield",
            "old flex",
            "workin' on it",
            "off my keyboard",
            "in your ends",
            "no jersey",
            "Harlem shaking",
            "chap's stick",
            "Gray's Anatomy",
            "auto-tune",
            "Evil Angel",
            "got options",
            "I'm a rider",
            "gates, pearly",
            "into legends",
            "black wood",
            "solely fit",
            "the takeover",
            "Summer's mine",
            "take my credit card",
            "down on her knees",
            "all-star weekend",
            "envy the life",
            "spreadin' my wings",
            "studio trappin'",
            "Richard prior",
            "like Sha'Carri",
            "Bun Vegas",
            "lil' Sicko",
            "back that ass up",
            "Big Tymer",
            "too much cheese",
            "all the roaming",
            "screw the fuckin' world",
            "like Bajan",
            "signs of the times",
            "exfoliate",
            "Eric B For President",
            "your centric",
            "now I'm cheese",
            "Baruch Yitadel",
            "buy time",
            "pay the price",
            "short gate",
            "just foreplay",
            "lies still",
            "truth hurts",
            "the ATF",
            "your pros",
            "sittin' sideways",
            "Kiki, she love me",
            "Duval",
            "Go Uptown",
            "degrees and papers",
            "tip-drill",
            "turn to chrome",
            "on some street shit",
            "only YOLO",
            "a Drac'",
            "Mr. Rogers",
            "the top is gone",
            "cross your mind",
            "for life",
            "360 windmill",
            "like Firestone",
            "a Clydesdale",
            "love's locked down",
            "tuna in a bowl",
            "Madonna hoes",
            "let your hair down",
            "like Blanka",
            "Jack son",
            "the two-three",
            "mountain of truth",
            "fountain of youth",
            "trick-trick",
            "goin' vegan",
            "ink with a major",
            "stayed up",
            "airing laundry",
            "Father's day",
            "get down",
            "ask V-O",
            "MC hammered",
            "call me T-Pain",
            "real italics",
            "still fly",
            "switchin' majors",
            "so far gone",
            "write my wrongs",
            "hit the Harden",
            "in sync",
            "my true religion",
            "six lives",
            "forward to me",
            "the world is yours",
            "don't be ridiculous",
            "the replacement",
            "it's ecstasy",
            "orange full moon",
            "speed stick",
            "big tired",
            "she's a spice",
            "like Yokohama",
            "serve backhands",
            "southern eyes",
            "just nevermind",
            "G check",
            "a-la-la-lollipop",
            "less sense",
            "eyes closed",
            "such a bone",
            "doing donuts",
            "Yves slatt Laurent",
            "acting tonto",
            "couple of beavers",
            "Drew Lord",
            "Double O",
            "Jenny and Swayze",
            "Game of Thrones",
            "Home Alone",
            "you and the six",
            "take advice",
            "retired teacher",
            "checks bounced",
            "one button",
            "toss the keys",
            "just be friends",
            "gyal heart",
            "it's personal",
            "like Sopranos",
            "El Chico",
            "Grab Eliza",
            "speed up the visa",
            "bien loquita",
            "needs a bonita",
            "mis cueros",
            "listen to rats",
            "like DaBaby",
            "around Dracs",
            "sometimes we laugh",
            "a ghost town",
            "closeable gap",
            "Tae is the best",
            "moved out the Ritz",
            "Garden of Eden",
            "victory lap",
            "got a strap",
            "doughnut shops",
            "heat of the moment",
            "know the road",
            "miss the boat",
            "sit in coach",
            "dog days",
            "red weave",
            "came to my senses",
            "patty gang",
            "I'm with Red",
            "I'm a pitbull",
            "P-I-C",
            "what damage",
            "make love",
            "the Batphone",
            "six summers",
            "get off again",
            "see you flexing",
            "life's hurdles",
            "Jay and Bey",
            "hold on you're going home",
            "Triple Crown",
            "on the Goose",
            "callin' a truce",
            "after Doe",
            "kick and a twitch",
            "Pyramids",
            "your man",
            "get across",
            "free time",
            "end of a world",
            "bigger picture",
            "comin' in first",
            "pillow with a mint",
            "throw your ones",
            "shoot down my flight",
            "that cream",
            "can we kick it",
            "Barack Hussein",
            "Bel-Air",
            "back in the Six",
            "on the hotline",
            "backpack underground",
            "trays in both hands",
            "cover up",
            "not a stainless",
            "a lot of smoke",
            "overthink",
            "took an L",
            "alarm ya",
            "little liar",
            "a canopy",
            "guns with the ink",
            "a ponytail",
            "car with the strap",
            "straight to the face",
            "my cues",
            "we're going home",
            "standin' up",
            "we don't get impeached",
            "Miami Heat",
            "like Montana",
            "talk used to be cheap",
            "cheap seat",
            "summer just started",
            "AM to the PM",
            "the garden",
            "ain't single",
            "Olympic pools",
            "no bench time",
            "draw attention",
            "the gift",
            "copying some vows",
            "top three",
            "I peak",
            "kick a punt",
            "been down so long",
            "reach back",
            "more chune",
            "thrillin bars",
            "the last hope",
            "R&B Diva",
            "dun know",
            "cannon on my hip",
            "no off notes",
            "stick with her",
            "checks cut",
            "bad meaning bad",
            "seedy",
            "switch wifey",
            "have my heart",
            "Yamaha mama",
            "Matilda",
            "faceshot",
            "Deadboy",
            "Spirit",
            "Akorn",
            "Bronny James",
            "main cabin",
            "Alvin Kamara",
            "eczema",
            "Monica Lewinsky",
            "John Collins",
            "through the wire",
            "Kid Bop",
            "hell",
            "Vez",
            "MVP",
            "wings",
            "fighting demons",
            "tan lines",
            "Arnez",
            "heart surgery",
            "sale",
            "leg crampin",
            "Donda",
            "wire",
            "Android",
            "Paul Bunyan",
            "Set It Off",
            "Eggo",
            "close friends",
            "Kemba Walker",
            "meal",
            "Neighborhood chucking",
            "Norbit",
            "Pistol Pete",
            "pull",
            "Carlos Boozer",
            "St. Lunatic",
            "Boban",
            "Die Lit",
            "Brook and Robin",
            "Neverland",
            "say my name",
            "Taylor Gang",
            "hundreds",
            "twenty",
            "Thottie breaking",
            "Pootie Tang",
            "Kelly, Michelle",
            "DX",
            "Naismith",
            "Joe Burrow",
            "Cracker Barrel",
            "Chuckie",
            "child",
            "PrizePick",
            "Beanie Sigel",
            "Red Bull",
            "bull",
            "Uzi Made",
            "Curtis",
            "Poison",
            "Raptors",
            "Hut",
            "blue",
            "Earl Sweatshirt",
            "Clinton Capella",
            "second place",
            "rainbow",
            "Titty",
            "billy",
            "Linwood",
            "Jason brother",
            "die",
            "hundred",
            "Otto Potter",
            "throwin' salt",
            "Quasimodo",
            "Ricky",
            "edible arrangement",
            "no more drama",
            "moi",
            "red dirt",
            "blue strips",
            "all that",
            "high",
            "white horns",
            "doubled up",
            "pip",
            "chicken wing",
            "wild out",
            "Paul George",
            "MIA",
            "red beans and rice",
            "Shameless",
            "Maino",
            "beef",
            "Kyro",
            "thug life",
            "Ariel",
            "bae",
            "Rey Mysterio",
            "Optimus",
            "Shell",
            "Leo",
            "Tina",
            "Denise's",
            "Wee Man",
            "Kells",
            "GED",
            "Poseidon",
            "Finn",
            "cadera",
            "Tetris",
            "origami",
            "harp",
            "nerd",
            "level",
            "Christine",
            "Armstrong",
            "Crawford",
            "Ambush",
            "Zoro",
            "finessed",
            "Cash",
            "Moonwalk",
            "'Port",
            "World Peace",
            "feta",
            "roger",
            "Dove bars",
            "'Luminati",
            "die 'lone",
            "Forest",
            "sequin",
            "deep end",
            "Stefan",
            "vent",
            "wildin' out",
            "Phillip",
            "bird, man",
            "Clifford",
            "Ragu",
            "IMAX",
            "Casper",
            "Hostess",
            "Geico",
            "playin' hockey"
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
            "Jrue Holiday": "Jrue Holiday is the holidays, said beside the bucks. On the Sprite bar, Jrue is beside Sprite.",
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
            "Kill Bill": "Kill Bill is the movie used as the sword and the kill.",
            "billboard": "Billboard is the painted sign and the charts. Climbing sets both up.",
            "Quagmire": "Quagmire is the jaw. Mansion is said as man-chin.",
            "astronauts": "Astronauts is the knots of cash. Swole pockets set up the suit.",
            "ranned off": "Ranned off is Randolph. Fifty is Zach's jersey.",
            "drop my shell": "Drop my shell is the casing and drop Michelle.",
            "O'Neal": "O'Neal is said so Shaquille sounds like she kill.",
            "Maybach curtains": "Maybach curtains plus angle is Kurt Angle.",
            "earplugs": "Earplugs sit where here is said as hear.",
            "we ball": "We ball sounds like we bald, said beside the hair.",
            "cards I'm dealt": "Cards I'm dealt is solitaire. Solitary is the cell.",
            "Tommy tucked": "Tommy tucked is the gun and a tummy tuck.",
            "darkest times": "Darkest times is said as bright beside the Breitlings.",
            "bag out": "Bag out is said as back out. The whip is in reverse.",
            "hit our target": "Hit our target is the aim and the store.",
            "from the rear": "From the rear is the sex and a rear-end. Insurance is the claim.",
            "bitin' my style": "Bitin' my style is stealing the flow. New teeth is the mouth.",
            "not a serial killer": "Not a serial killer is Siri and cereal.",
            "think 'bout death": "Think 'bout death is deaf. Here is hear.",
            "rollin' loud": "Rollin' loud is the weed and the festival.",
            "Glock-9": "Glock-9 sounds like GlokkNine, said beside Kodak.",
            "like a battery": "Like a battery is the dead battery and the Dodge Charger.",
            "came sooner": "Came sooner is the Oklahoma Sooners and arriving sooner.",
            "one coat": "One coat is Colt. Indianapolis is where the Colts play.",
            "napless": "Napless is Indianapolis, said beside the coat.",
            "see Pearl": "See Pearl is the whale. Well is said as whale.",
            "talkin Pearl": "Talkin Pearl is the whale. Well is said as whale.",
            "an addict": "An addict is the attic, said beside the basement.",
            "don't pretend": "Don't pretend is pre-ten. Nine comes before ten.",
            "mob ties": "Mob ties is the family. Laces are what you tie.",
            "for that brick": "For that brick is the missed shot and the cocaine.",
            "assassinate him": "Assassinate him is the hit. Presidential is the watch.",
            "let it pan out": "Let it pan out is laying low and the frying pan.",
            "my diamonds": "My diamonds is said as die-monds, beside death.",
            "chargin' my career": "Chargin' my career is the rise and a charge.",
            "your presence": "Your presence is presents. Gifted is the setup.",
            "incomplete": "Incomplete is the football pass. Past is the pass.",
            "takin' medicine": "Takin' medicine is the lean, and the end sounds like sin.",
            "brought my lawyer": "Brought my lawyer is the court. Jewelry is said as jury.",
            "lean go": "Lean go is lingo, the way he talks.",
            "my umbrella": "My umbrella is the song, said beside the re-up.",
            "Hot dig": "Hot dig is said as Diggs. Thirty is the shots.",
            "with the Migos": "With the Migos sets up take off as Takeoff.",
            "like Offset": "Like Offset sets up take off as Takeoff.",
            "without the sticks": "Without the sticks is the band and the gun.",
            "runnin' like Hillary": "Runnin' like Hillary is the campaign. Presidential is the watch.",
            "switch the beats": "Switch the beats is said as Swizz. Alicia Keys is his wife.",
            "envy me": "Envy me is the song. Cal is the .50 and the name.",
            "music app": "Music app is Spinrilla. Spin is the ride-out.",
            "like game": "Like game is the detergent. Washed is the laundry and the falloff.",
            "raid us": "Raid us is the Raiders, said beside Derek.",
            "use a pencil": "Use a pencil is the pen inside independent.",
            "back and forth to court": "Back and forth to court is the law and the basketball court.",
            "get abused": "Get abused is the drugs and the harm, said beside the codeine.",
            "cash comin'": "Cash comin' is the money coming in, said beside semen.",
            "holiday eve": "Holiday eve is Eve. At him is said as Adam.",
            "head was weak": "Head was weak is said as week. Seven days is a week.",
            "I'm tracin'": "I'm tracin' is on top of the page. Tracy is McGrady on the next bar.",
            "see a ring": "See a ring is the jewelry. Hardy is who wears it.",
            "no flowers": "No flowers is the plant. Rose is who she looks like.",
            "drake kickback": "Drake kickback is the Draco recoil. Soccer is the kick.",
            "wearing a trojan": "Wearing a Trojan is the condom and the other side. Spartan is the 300.",
            "a Spartan": "A Spartan is the movie 300. Hundred is the number.",
            "tote 30": "Tote 30 is the gun. Portland is the team that number does not play for.",
            "on his trail": "On his trail is the chase and the Trail Blazers. Portland is the city.",
            "shot a buffalo": "Shot a buffalo is the animal and the Buffalo Bills. Bills is the money.",
            "we packers": "We packers is the team and the clip. Clips is the AR.",
            "pourin' up dirty": "Pourin' up dirty is the lean. Clean is the other cup.",
            "vacuum seals": "Vacuum seals is the packed work and the cleaner. Clean sits beside it.",
            "Jr. Smith": "Jr. Smith is the shot he held. The ball is in the hand.",
            "fee on her": "Fee on her is Fiona. Shrek is the movie.",
            "beat the jury": "Beat the jury is the trial. The jeweler is who he swings on.",
            "curve me": "Curve me is the rejection and the pitch. Baseball money is on the line.",
            "like Kyler Murray": "Like Kyler Murray is the quarterback. Cardinal is the team.",
            "no Polo": "No Polo is the logo with the horse. Horses is the engine.",
            "killing beats": "Killing beats is the music and the brand. Headphones is what he did not shoot.",
            "black mamba": "Black mamba is the snake and the nickname. Kobe is the name.",
            "like Brady": "Like Brady is the quarterback. Threw is the pass.",
            "knockout Roosevelt": "Knockout Roosevelt is the punch and the president. Dime is the coin.",
            "like J.J Watts": "Like J.J Watts is the lineman. Set is the play call.",
            "like Michael Oher": "Like Michael Oher is the tackle. Blind is the blind side.",
            "in my home like Patrick": "In my home like Patrick is Mahomes. Kansas is where they came from.",
            "like I'm Rondo": "Like I'm Rondo is the guard. Nine is the jersey and the gun.",
            "it's a vert": "It's a vert is the drop-top and Lil Uzi. Uzi is on the line.",
            "like Andre": "Like Andre is Andre 3000. Thousand is the money.",
            "like Naruto": "Like Naruto is the show. Bandana is what he wears.",
            "like Wi-Fi": "Like Wi-Fi is the signal. Bars is the reception and the block.",
            "like Jill Scott": "Like Jill Scott is the song A Long Walk. Walk is on the line.",
            "cloned Michael Jordan": "Cloned Michael Jordan is number 23. 223 is the round.",
            "like Forest": "Like Forest is Forrest Gump. Gump is the name.",
            "freekin' on you": "Freekin' on you is the Jodeci song. Jodeci is the group.",
            "like I'm Tyler": "Like I'm Tyler is Tyler Herro. Heat is the team and the gun.",
            "like the Cardinals": "Like the Cardinals is the defense. Zone is the coverage.",
            "on Rhude": "On Rhude is the brand, said like rude. Attitude is the mood.",
            "like I'm Gilbert": "Like I'm Gilbert is Gilbert Arenas. Arena is the club and the building.",
            "like Tekashi": "Like Tekashi is 6ix9ine. Six is the name.",
            "like I'm jaggered": "Like I'm jaggered is Jagged Edge. Edge is the group and the risk.",
            "Snow in the Bluff": "Snow in the Bluff is the film. Camera is what they steal.",
            "like Kobe Bryant": "Like Kobe Bryant is the fadeaway. Faded is the shot and the friends.",
            "like O-Dog": "Like O-Dog is the movie Menace. Menace is the label.",
            "like Doc Dre": "Like Doc Dre is Dr. Dre. Beat is the track and the charge.",
            "buy him the rockets": "Buy him the rockets is the Houston team. Westbrook is who got dunked on.",
            "like Neo": "Like Neo is the Matrix. Bullets is what he walks through.",
            "like I'm John Wall": "Like I'm John Wall is the guard. Pass is the assist.",
            "like I'm Lonzo Ball": "Like I'm Lonzo Ball is the guard. Balling is the game.",
            "like Secret Service": "Like Secret Service is the detail. Presidents is who they walk with.",
            "like Johnnie Cochran": "Like Johnnie Cochran is the lawyer. Case is the trial.",
            "like Raymond": "Like Raymond is the show. Love is what they show him.",
            "like I was Hot Sauce": "Like I was Hot Sauce is the crossover. Crossed is the move.",
            "drive her crazy": "Drive her crazy is the feeling and the car. Collision is the crash.",
            "Dream Chaser": "Dream Chaser is the tape. Meek is Meek Mill.",
            "like Diddy": "Like Diddy is the group Dirty Money. Dirty is on the line.",
            "like Randolph": "Like Randolph is Zach Randolph. 50 is the jersey and the gun.",
            "like Similac": "Like Similac is the formula. White is what it looks like.",
            "like Thomas": "Like Thomas is the engine. Train is on the line.",
            "like Nipsey": "Like Nipsey is the affiliation. Crip is the set.",
            "no limit": "No limit is the label. Master is Master P.",
            "in the ghost": "In the ghost is the Rolls-Royce. Cast is the spell.",
            "droppin' dimes": "Droppin' dimes is the snitch and the coin. Penny is the other coin.",
            "like Huskies": "Like Huskies is the dog. Huggies is the diaper.",
            "fightin' cases": "Fightin' cases is the trial and the boxer. Ali is Muhammad Ali.",
            "drum like I'm Nick Cannon": "Drum like I'm Nick Cannon is the film Drumline.",
            "like Anderson Silva": "Like Anderson Silva is the fighter. Elbows and kick are the strikes.",
            "feeling like curry": "Feeling like curry is Steph Curry. Myself is being the one out there.",
            "Fifty Dub": "Fifty Dub is Fifty World. Tatted is Fif on his skin.",
            "eighty-one": "Eighty-one is the letters H and A. Crashers are that same name at the party.",
            "the O2": "The O2 is the London arena. The O3 is that show once the tickets were given back.",
            "6 a.m.": "6 a.m. is The 6. Pull up is the visit he does not want that early.",
            "two up": "Two up is too up. Three up is one past that.",
            "the billis": "The billis is a billion and a billy goat. Bucks is the money and the male.",
            "Chef Curry": "Chef Curry is Steph in the kitchen. Pot is the cook.",
            "trigger fingers": "Trigger fingers is the gun hand. Twitter fingers is the same hand on the app.",
            "William Wesley": "William Wesley is Worldwide Wes. Check me is a basketball challenge.",
            "Energizer": "Energizer is the battery bunny. Drum is the magazine and the bunny's drum.",
            "water gun": "Water gun is the toy. Skeet is the shot it names.",
            "girl's tour": "Girl's tour is her trip. World is the shows on the same line.",
            "Midas": "Midas is the gold touch. Touch is the hand that turns it.",
            "Eurostep": "Eurostep is the basketball move. London is the city and the euro.",
            "ambidex": "Ambidex is both hands. Left is the side with no weak side.",
            "use your name": "Use your name is username. Who is he is the question it gets.",
            "Fabo": "Fabo is the snap rapper. Snappin' is the camera and the dance.",
            "money trees": "Money trees is the song and the cash. Plant is putting them in the hood.",
            "pound cake": "Pound cake is the money and the cake. Million is the count.",
            "stopwatch": "Stopwatch is the timer. Stop is what the Rollie does not do.",
            "God bless you": "God bless you is the sneeze. Givenchy is the name it sounds like.",
            "on Glee": "On Glee is the show. New girl is the girlfriend and the other show.",
            "George Strait": "George Strait is the country singer. Texas is where the exes live.",
            "Kenny head": "Kenny head is the miss and the height. Bars are the lines that go over it.",
            "overlooked him": "Overlooked is missed and looked over. Starin' straight is the look from up high.",
            "Allen Iverson": "Allen Iverson is the Questions shoe. Question is the doubt on the line.",
            "actin' days": "Actin' days is the show and the fake smile. Over is those days being done.",
            "bad then": "Bad then is the awkward photo and the good looks. Pics are the high school shots.",
            "a Kim": "A Kim is the skim. Skim through it is flipping the two albums.",
            "Advil": "Advil is the hangover. Wheel is Jesus taking it.",
            "the ink": "The ink is the pen and the Inc. Irv is Irv Gotti.",
            "Makaveli": "Makaveli is 2Pac. Eyes is All Eyez On Me.",
            "balled": "Balled is the money and the bald. Chemo is what takes the hair.",
            "McLovin": "McLovin is the Superbad name and the McDonald's love. Bad is the movie and the women.",
            "find me, Nemo": "Find me, Nemo is the fish and money said backwards. Money is the pool.",
            "Bueller": "Bueller is Ferris Bueller skipping school. Class is the class he skips.",
            "Space Jam": "Space Jam is the movie with the alien and Jordan. Martian is Wayne.",
            "savin' face": "Savin' face is avoiding the embarrassment. Lecter is the one who takes the face.",
            "Grateful like Jerry": "Grateful like Jerry is the Dead. Mickey is Mickey Hart.",
            "Cape Town": "Cape Town is the city. Saved is the hero in the cape.",
            "iron is up": "Iron is up is the blood count and the gun. Blood is the family. Eyein' is the look that gets it raised.",
            "switched place": "Switched place turns tried into tired. R is the letter that moves.",
            "Paramore": "Paramore is the band of three. Ting is the third one in the car.",
            "a buzz": "A buzz is the haircut, the noise, the high, and the shock. Overdosed is the last time he had one.",
            "hood dreams": "Hood dreams is hoop dreams. Chains are the fame he wanted.",
            "can't even act": "Can't even act is no movie roles and no normal behavior. Hollywood is the town.",
            "king cobra": "King cobra is the snake and the sequel. Jealous is Fat Joe's album.",
            "runneth over": "Runneth over is the psalm about more than enough. Cup is the cup that spills.",
            "roller coaster": "Roller coaster is the ups and downs. Drops is the fall.",
            "four shadows": "Four shadows is foreshadows. Light is where he sees them.",
            "two percent": "Two percent is the milk and the share who are rich. Milk it is taking more than they earned.",
            "06er": "06er is The 6 and an old player. Year is whatever year it is.",
            "like BTS": "Like BTS is the group and behind the scenes. Career is how long the discovery took.",
            "poor me": "Poor me is the pity and the broke. Much is the money that blocks both.",
            "patience": "Patience is the wait and the patients. Dre is the doctor who sends them home.",
            "one accord": "One accord is the agreement and the Honda. Broke couple is who shares the car.",
            "pallbearers": "Pallbearers carry the casket. Paul Bearer is the manager with the urn.",
            "B-roll": "B-roll is the extra film and the blood type. Shootin' is the camera and the gun.",
            "pack Bone": "Pack Bone is Bone Thugs. Thuggish ruggish is their song.",
            "lion is loose": "Lion is loose is Young Lion in the booth. Booth is where the verse is.",
            "Onyx": "Onyx is the group. Shut 'em down is their song.",
            "wire transfers": "Wire transfers are the money. Tangled is the wires and the morals.",
            "Bulgari": "Bulgari is the resort. Turkey is the country next to Bulgaria, said the same way.",
            "from the ends": "From the ends is the neighborhood. Girls is who he does not love from there.",
            "loadin' rebuttals": "Loadin' rebuttals is the answers ready to fire. Cut is the spot he loads them from.",
            "give me fifty": "Give me fifty is the push-ups and the half he owes Top. Push-ups is the exercise.",
            "how it seems": "How it seems is how it looks and the seam. Sewn is the stitch.",
            "in a scope": "In a scope is the gun sight and Interscope. Label is the company.",
            "degenerates": "Degenerates is the crew and Degeneres. Ellen is the host who still likes it.",
            "checks owed": "Checks owed is the money and the Czechs. Formal is the dress code from that trip.",
            "TTC metro": "TTC metro is the Toronto train and Metro Boomin. Boomin' is the producer and the place.",
            "tradin' places": "Tradin' places is the movie and the swap. Murphy is Eddie Murphy.",
            "your noodle": "Your noodle is the head and dinner. Movies is the date after.",
            "the bark": "The bark is the talk and the dog. Bite is the action.",
            "size-seven": "Size-seven is the small shoe. Steppin' is the big walk that does not fit.",
            "Gucci Row": "Gucci Row is the courtside seats. UNLV is the school that named them.",
            "Papi champú": "Papi champú is Champagne Papi and the shampoo. Seis is the 6 God.",
            "like wrappers": "Like wrappers is the foil and the rappers. Platinum is the color and the plaques.",
            "bigger fish": "Bigger fish is the seafood and the bigger problem. Fry is how you cook it.",
            "buddin' careers": "Buddin' careers is Joe Budden and a new career. Sit around is the show.",
            "shit is complex": "Shit is complex is the magazine and the situation. Short is the height on the show.",
            "you and Cole": "You and Cole is J. Cole and the coal. January is the start of the year a bad kid waits through.",
            "double click": "Double click is the mouse and opening up. Open is the beat.",
            "The Fall Off": "The Fall Off is Cole's album. Ironic is that there is no fall off.",
            "W's and M's": "W's and M's are the wins, the millions, and the bathroom doors. Bathroom is the restroom with both.",
            "Sureños": "Sureños is the set marked 13. Vegas is where the 13 Billboard wins were.",
            "off us": "Off us is the attack and the office. Cubicles is where the employees sit.",
            "away from the bars": "Away from the bars is the weak lyrics and the jailbreak. Prison is the escape.",
            "lime green": "Lime green is the Android text bubble. Android is her phone.",
            "Domina": "Domina is the wine and the lady. Home is where he takes both.",
            "Pee M's": "Pee M's is Pierre Thomas and the afternoon. Noon is when it is past.",
            "holdin' you down": "Holdin' you down is support and the grip. Back is the opposite.",
            "you and I": "You and I is the couple and the university. School is the job that skipped it.",
            "big three": "Big three is the rappers and the league. League is the one they started.",
            "Detroit Lions": "Detroit Lions is the team and the animal. Sanders is Barry Sanders.",
            "like Yahtzee": "Like Yahtzee is the dice cup and the drank. Numbers is what Wayne was doing.",
            "net a Bey": "Net a Bey is a billion and Beyoncé. Apiarist is the keeper who nets a bee.",
            "Pink Floyd": "Pink Floyd is the band and the rock. Rock is what they cannot do with him.",
            "AMBER Alert": "AMBER Alert is the notice and Tiffany Amber Thiessen. Tiffany is the store she finds.",
            "head in the clouds": "Head in the clouds is the daydream and the high cloud. Serious is the word that sounds like Cirrus.",
            "eight karats": "Eight karats is the stones and ate carrots. Vegetarians is the diet on that bar.",
            "cup holder": "Cup holder is the car slot and the dimes that stick. Dimes is who stays.",
            "Big Benjamins": "Big Benjamins is the cash and Big Ben. Steelers is the Pittsburgh team.",
            "let her open 'em": "Let her open 'em is the mail and a letter opener. Envelopes is what came in.",
            "make change": "Make change is the coins and the switch. Money is what does it.",
            "Sinatra lifestyle": "Sinatra lifestyle is Frank and bein' frank. Frank is the word on that bar.",
            "like Snoopy": "Like Snoopy is the dog on the roof. House is where the drinks are.",
            "place in Jamaica": "Place in Jamaica is the house and the destination. Destined is the word it flips.",
            "patty cake": "Patty cake is the game and the pat-down. Inspection is the search they skip.",
            "Cinco de Mayo": "Cinco de Mayo is the holiday and a fifth. Fifth is what Junior Boy may hold.",
            "hammers come out": "Hammers come out is the gavel and the gun. Judge is who brings them.",
            "farfetched": "Farfetched is the stretch and the throw. Meters is how far he threw it.",
            "staple in the game": "Staple in the game is the fixture and the office staple. Papers is what it holds.",
            "in her organs": "In her organs sounds like Oregon. Portland is the city on that bar.",
            "feelin' bulletproof": "Feelin' bulletproof is the vest and the shots. Shots is what he is taking.",
            "like it's wagyu": "Like it's wagyu is the steak and the beef. Beef is the word on that bar.",
            "sawed-off": "Sawed-off is the shotgun and goin' off. Goin' is the word it sits on.",
            "throwin' up six": "Throwin' up six sounds like sick with the flu. Flu is the word on that bar.",
            "more Chrome": "More Chrome is the metal and the suits. Stark is Tony Stark.",
            "talkin' in Dutch": "Talkin' in Dutch is the language and the Dutch Masters. Smoke is what got him there.",
            "spangled banner": "Spangled banner is the anthem. Star is what he calls himself.",
            "too much joggin'": "Too much joggin' is the workout and running the town. Run is the word on that bar.",
            "Rotterdam trip": "Rotterdam trip is the city and A-Rod. Page is the front page that trip made.",
            "broken necklace": "Broken necklace is the chain with no link. Link is the hangout he turns down.",
            "forecastin' tornadoes": "Forecastin' tornadoes is the weather report. Brainstormin' is the dinner talk on that bar.",
            "American Expresser": "American Expresser is the card and the collector. Debt is what he collects.",
            "call the bluff": "Call the bluff is the poker bet. Fold is what they do on that bar.",
            "rippin' markers": "Rippin' markers is the casino credit he tears up. Henny is the shot on that bar.",
            "Champagne popper": "Champagne popper is the bottle and Champagne Papi. Doctor is the love doctor on that bar.",
            "dim some": "Dim some is the lights and the dumpling. Lights is what he turns down.",
            "break your Kevin Hart": "Break your Kevin Hart is the comic and break your heart. Boy is the word at the end of the bar.",
            "the one tankin'": "The one tankin' is the losing streak and the tank. Militant is how they are moving.",
            "like Shakira": "Like Shakira is the singer and Whenever, Wherever. Whenever is the word on that bar.",
            "heart is on my sleeve": "Heart is on my sleeve sounds like the artisan must leave. Fame is the hall his body is in.",
            "loose with the lyin'": "Loose with the lyin' is the lies and the lion. Cages is what is open.",
            "Casper the Ghost": "Casper the Ghost is the cartoon and the ghostwriter. Rap is the one he took.",
            "reigning supreme": "Reigning supreme is the crown and the rain. Clouds is what is hanging over you.",
            "not believers": "Not believers is the faith and the people leaving. Leavin' is the word on that bar.",
            "boot toes": "Boot toes is the steel toe and the flows they steal. Steal is the word on that bar.",
            "will me to defeat": "Will me to defeat is the will, the wheel, and da feet. Rollerbladin' is the sport on that bar.",
            "like Antetokounmpo": "Like Antetokounmpo is Giannis and the Milwaukee Bucks. Buck is keep it a buck.",
            "like Copenhagen": "Like Copenhagen is the city and then mark. Mark is the word in front of it.",
            "up in arrivals": "Up in arrivals is the airport and having made it. Made is the word on that bar.",
            "no stick in the ride": "No stick in the ride is the gun and the stick shift. Morningside is the street.",
            "eighteen karats": "Eighteen karats is the gold on the AP. AP is the watch he is thinking.",
            "like silos": "Like silos is the grain tower and the gun. Grains is what is in the mash.",
            "peas and rice": "Peas and rice is the plate he names. Breasts is the line it sits under.",
            "need vaccine": "Need vaccine is the shot and the video. Viral is how the vid starts going.",
            "feel like Dido": "Feel like Dido is the singer and the morning rain. Rain is on the window.",
            "medium guys": "Medium guys is the men and the shoe size. Shoe is the right shoe on that bar.",
            "Toodaloo": "Toodaloo is goodbye and to the loo. Google is the news it pops up on.",
            "amazin' grace": "Amazin' grace is the hymn and the grace period. Delayed is how late it is.",
            "double play": "Double play is the baseball out. Home is out at home on that bar.",
            "booster seat": "Booster seat is the child seat. Lies is what they tell from it.",
            "lie to even tie": "Lie to even tie is the knot and the lie. Feels is the word the bar starts with.",
            "seize the day": "Seize the day is the proverb and the owl. Owl is who wakes up.",
            "we engaged": "We engaged is the wedding and the beef. Married is the rapper he could have fallen back like.",
            "this ain't Minute Maid": "This ain't Minute Maid is the juice and the minutes. Years is the sixteen he has in.",
            "never fade": "Never fade is the haircut and fading away. Cut is what he does to them.",
            "money is young": "Money is young is the cash and Young Money. Old is what the problems are.",
            "see no time": "See no time is the prison and the flooded Rollie. Rollie is the watch.",
            "soft white": "Soft white is the powder and the Off-White. Off is the brand on that bar.",
            "duckin' indictments": "Duckin' indictments is dodging the case and ducking down. Stand is the stand-up on that bar.",
            "no Canseco": "No Canseco is Jose Canseco and the steroids. Roids is what he plays like he is on.",
            "no misses": "No misses is the hits and the Mrs. Married is the folk that is for.",
            "catch up to the slaps": "Catch up to the slaps is the hits and the ketchup. Mustard is who heard about them.",
            "on the lap'": "On the lap' is the lap and the Laugh Factory. Fact is the word after it.",
            "tryna campaign": "Tryna campaign is the election and runnin' shit. Runnin' is the word on that bar.",
            "teach you the ropes": "Teach you the ropes is the lesson and the rope. Hang is the word on that bar.",
            "poker face": "Poker face is the face and the cards. Jokers is who showed them.",
            "plot a return": "Plot a return is the comeback and the keyboard key. Shift is the key that moves the game.",
            "bit the hand": "Bit the hand is the bite and the hand that feeds. Starve is what comes after.",
            "talk keys": "Talk keys is the piano and the cocaine. Cane is what he is not pitching.",
            "caps lock": "Caps lock is the key and the capital. Capital is the money on that bar.",
            "the Drake show": "The Drake show is his show and The Eminem Show. Game is what turned into it.",
            "call up a Stark": "Call up a Stark is Tony Stark and Richard Stark. Chrome is the Chrome Hearts on that bar.",
            "gettin' ate": "Gettin' ate is the meal and the eight. Cake is the ten he is on.",
            "not a BNB": "Not a BNB is the house and the bed and breakfast. CMG is who he used to roll with.",
            "every twenty-four": "Every twenty-four is the hours and the jersey. Kobe is who lived them.",
            "21 my addy": "21 my addy is the address and 21 Savage. Knife is what is on the gate.",
            "like we DMC": "Like we DMC is the car and Run-DMC. Revvin' is Rev Run.",
            "than the plot": "Than the plot is the story and the body. Thicker is the word in front of it.",
            "last ones laughin'": "Last ones laughin' is the laugh and LOL. LOL is the gang on that bar.",
            "not the Messi": "Not the Messi is Lionel Messi and a ten. Ten is what shorty is.",
            "my attorney": "My attorney is the lawyer and the judge. Judgin' is what the friends keep doing.",
            "like New Jersey": "Like New Jersey is the state next to the city. Later is see me later.",
            "than Biscayne": "Than Biscayne is the bay and the distance. Farther is how far he takes you.",
            "like 6:30": "Like 6:30 is the clock. Hands is what points down.",
            "no glaucoma": "No glaucoma is the eye and the smoke. Smoke is what he does.",
            "just C-4in'": "Just C-4in' is the explosive and Carter IV. Recordin' is what the red light is not.",
            "got a SIG": "Got a SIG is the pistol and the signature. Smoker is what he is not.",
            "like Tila Tequila": "Like Tila Tequila is the house full of women and a full house. House is the word on that bar.",
            "K-Y": "K-Y is the jelly and the engineer. Homo is the word next to it.",
            "cheesehead": "Cheesehead is the fan and the cheese. Lombardi is Vince Lombardi.",
            "Chuck Inglish": "Chuck Inglish is the Cool Kid and the English. Coolest is the kid on that bar.",
            "actin' like Book": "Actin' like Book is Devin Booker. Booked is what the doggy got.",
            "anyone home": "Anyone home is the door and the knockout. Knockin' is the word on that bar.",
            "we droppin'": "We droppin' is the clumsy hands. Clumsy is the word on that bar.",
            "we sockin'": "We sockin' is the socks and the punch. Shoe is where the socks are.",
            "eatin' a goat": "Eatin' a goat is the animal and the GOAT. Vegan is what she said she was.",
            "standin' on bidiness": "Standin' on bidiness is the business and standing up. Sittin' is what they are doing.",
            "we whoppin'": "We whoppin' is the Whopper and the whooping. Combo is number one.",
            "like Jeopardy": "Like Jeopardy is the game show. Buzzin' is still buzzing in.",
            "I'm a prodigy": "I'm a prodigy sounds like Prada. Gucci is the groupie on that bar.",
            "like NextSelection": "Like NextSelection is Ryan Leslie. Les is the word in front of the name.",
            "like van Nistelrooy": "Like van Nistelrooy is the striker and Manchester United. United is the word on that bar.",
            "Scary Hours": "Scary Hours is the project and the fear. Afraid is what they should be.",
            "nose bleedin'": "Nose bleedin' is the nose and the nosebleed seats. Seats is where you cannot see the stage.",
            "may see us": "May see us sounds like Macy's. Parade is the street parade.",
            "Frito Lays": "Frito Lays is the chips and the cash. Stash is the safe they go in.",
            "freed the slaves": "Freed the slaves sounds like Lincoln. Linkin' is the word in front of it.",
            "heart hardens": "Heart hardens is the heart and James Harden. Adidas is the sneakers.",
            "pop it for real": "Pop it for real is the pop and Pop at Pharrell. Know is the word on that bar.",
            "the spill": "The spill is the secret and the sauce. Sauce is the other half of the bar.",
            "like some green tea": "Like some green tea is the brew. Blow is the word in front of it.",
            "when it's silk": "When it's silk is the fabric and the soft. Soft is what they keep calling it.",
            "oui, oui": "Oui, oui is the French yes and we, we, we. Text is how she sent it.",
            "heat seats": "Heat seats is the heated seats and the heat. Came is the word on that bar.",
            "BC baby": "BC baby is British Columbia and the green. Vancouver is the city.",
            "mention the O": "Mention the O is OVO and Ontario. Diss is what the boys are getting ready to do.",
            "life to the O": "Life to the O is OVO and Ontario. Brother is who would give it.",
            "Coach K": "Coach K is Kevin Lee and the coach. P is Pierre Thomas.",
            "the V's": "The V's is the verses and the vinyl. Noel is who recorded them.",
            "Birkin is croc": "Birkin is croc is the bag and the rubber shoe. Rubber is the shoe.",
            "got the cakes": "Got the cakes is the body and the baking. Bakin' is what she should stick to.",
            "lean in soda": "Lean in soda is the drank and leaning in. Fanta is the soda.",
            "on-site like W-W-W": "On-site like W-W-W is the website and on sight. Find is what he will do.",
            "like dot-com": "Like dot-com is the website and on sight. Site is the word on that bar.",
            "drawin' conclusions": "Drawin' conclusions is the guess and the drawing. Parsons is the design school.",
            "summers did I run": "Summers did I run is the years and the 10 Summers album. Ten is the number.",
            "four gunshot": "Four gunshot is the shots and the four records. Dead is what he is not.",
            "lay down when you make bed": "Lay down when you make bed is the idiom. Gotta is the word in front of it.",
            "gotta punt": "Gotta punt is the football kick. Down is how down they are.",
            "Ice time": "Ice time is the Iceman and the agency. Feds is the fake ones it is not.",
            "gettin' secondhand": "Gettin' secondhand is the used goods and the embarrassment. Embarrassment is the only thing.",
            "mall with a rat": "Mall with a rat is the mallrat and the snitch. Small is how they are thinking.",
            "Chase Bank": "Chase Bank is the bank and the chase. Bury is the word in front of it.",
            "got the hookup": "Got the hookup is the plug and No Limit. Limit is the word on that bar.",
            "Slauson or Watts": "Slauson or Watts is the swap meet. Swap is the word on that bar.",
            "cash cow": "Cash cow is the money and the animal. Tree is the money tree on that bar.",
            "Cindy, ya bad": "Cindy, ya bad is the photographer and sending a bag. Ayy is the word on that bar.",
            "two cougars": "Two cougars is the cats and the cars. Jag is the Jaguar he does not need.",
            "Kris Kross": "Kris Kross is the group and the jump. Jump is the word on that bar.",
            "two cents": "Two cents is the opinion and the coins. Spent is what he never did.",
            "find you face down": "Find you face down is the bet on that bar. Bet is the word in front of it.",
            "cop pleas": "Cop pleas is the ticket plea and the deal. Ticket is the word in front of it.",
            "deep-seated": "Deep-seated is the feeling and the seats. Seats is the word on that bar.",
            "posted receipts": "Posted receipts is the purchase and the proof. Chanel is the bag on that bar.",
            "bone to pick": "Bone to pick is the fight and the bones. Skeletons is the word on that bar.",
            "than MIT": "Than MIT is the school and the chemistry. Chemistry is the word on that bar.",
            "thank-me-later": "Thank-me-later is the album and the thanks. Gone is the word on that bar.",
            "act like sheeps": "Act like sheeps is the flock and the GOATs. Goats is the word in front of it.",
            "guzzle a Guinness": "Guzzle a Guinness is the pint and the record book. Records is the word on that bar.",
            "it was an exhibit": "It was an exhibit is the scene and the evidence. Bomb is the word on that bar.",
            "ovens and kitchens": "Ovens and kitchens is how close they were. Close is the word in front of it.",
            "barrel was smoking": "Barrel was smoking is the gun. Kissed is the word on that bar.",
            "body double": "Body double is the stand-in. Switches is the word on that bar.",
            "nothing was the same": "Nothing was the same is the album and the change. Forgiven is the word on that bar.",
            "like I'm Miss Adele": "Like I'm Miss Adele is the singer and the sales. Title is the word on that bar.",
            "on the 33rd": "On the 33rd is a day that never comes. Link is the word on that bar.",
            "cursin' me": "Cursin' me is the swear and the hex. Dirty is the word on that bar.",
            "Sandra's rose": "Sandra's rose is the son and the flower. Flower is the shop, and pick is the other bar.",
            "like Charlamagne": "Like Charlamagne is the host and the patches. Patches is the word on that bar.",
            "opened up a can": "Opened up a can is the can of worms. Worms is the word in front of it.",
            "like I'm Amber Rose": "Like I'm Amber Rose is the walk. Walk is the word on that bar.",
            "like I'm Nixon": "Like I'm Nixon is the peace sign. Peace is the word in front of it.",
            "illuminated angel": "Illuminated angel is the Rolls ornament. Rolls is the car on that bar.",
            "rider in my system": "Rider in my system is the backstage list and the writer. Better is the word in front of it.",
            "with a V in the middle": "With a V in the middle is OVO. Exes is the word in front of it.",
            "key to the city": "Key to the city is the honor and the producer. Wayne is the name on that bar.",
            "went halal": "Went halal is the clean plate and the sidestep. Beef is the word in front of it.",
            "aidin' Ross": "Aidin' Ross is the help and Adin Ross. Adin is the name on that bar.",
            "do buy everything": "Do buy everything sounds like Dubai. Eastern is the word on that bar.",
            "rack up a tab": "Rack up a tab sounds like Iraq. Eastern is the word on that bar.",
            "like the seven seas": "Like the seven seas is the water and the sale. Sale is the word in front of it.",
            "like Little Caesars": "Like Little Caesars is the pizza and the dough. Dough is the word in front of it.",
            "like a carabiner": "Like a carabiner is the clip and the Loop. Loop is the word on that bar.",
            "like the Village People": "Like the Village People is YMCA. YM is the word on that bar.",
            "like I'm Lebanese": "Like I'm Lebanese is the neighbor. Jordan is the word on that bar.",
            "like little leaguers": "Like little leaguers is the outfield. Field is the word on that bar.",
            "sixth sense": "Sixth sense is the feeling and the movie. Dead is the word on that bar.",
            "like the Philly Eagles": "Like the Philly Eagles is the team and the paint. Hurts is the word on that bar.",
            "Penny Lane": "Penny Lane is the movie line. Happening is the word in front of it.",
            "makin' light of my situation": "Makin' light of my situation is the joke and the Clapper. Clap is the word on that bar.",
            "money tree": "Money tree is the saying and the stack. 23 is the age on that bar.",
            "all my children": "All my children is the soap and the copies. Soap is the word in front of it.",
            "all my millions": "All my millions is the saying and the money. Myself is the word on that bar.",
            "be my strudel": "Be my strudel is the pastry. Toaster is the word in front of it.",
            "two black cars": "Two black cars is the pair he named. Luther is the name on that bar.",
            "like it's a Spalding": "Like it's a Spalding is the ball. Flight is the word on that bar.",
            "bowl a strike": "Bowl a strike is the pins and the body. Frame is the word in front of it.",
            "lose to love": "Lose to love is the loss and the tennis score. Tennis is the word on that bar.",
            "write my endin'": "Write my endin' is the ghostwriter and the close. Philly is the word on that bar.",
            "bad boys that wasn't pretendin'": "Bad boys that wasn't pretendin' is the label and the show. Scuffles is the word on that bar.",
            "tea with the stars": "Tea with the stars is the cup and the fame. Sharks is the word on that bar.",
            "swim with the sharks": "Swim with the sharks is the water and the danger. Stars is the word on that bar.",
            "cut the tie": "Cut the tie is the split and the necktie. Severed is the word on that bar.",
            "like I'm Kris Kringle": "Like I'm Kris Kringle is Santa. Noel is the name on that bar.",
            "round the facts": "Round the facts is the dodge and the show. Superstitious is the word on that bar.",
            "off a Quay": "Off a Quay is the dock and the pill. Tingle is the word on that bar.",
            "he might clock": "He might clock is the time and the hit. Watches is the word on that bar.",
            "need supervision": "Need supervision is the eye and the watches. Watches is the word on that bar.",
            "drop addiction": "Drop addiction is the habit and the roof. Top is the word on that bar.",
            "Bahamas, MIA": "Bahamas, MIA is the trip and missing in action. Away is the word on that bar.",
            "hit JFK": "Hit JFK is the airport. MIA is the word on that bar.",
            "motion sickness": "Motion sickness is the travel. Takin' is the word on that bar.",
            "top two": "Top two is the rank under five. Five is the word on that bar.",
            "I'm not two": "I'm not two is the rank and the count. One is the word on that bar.",
            "it's not one": "It's not one is the classic and the person. Had is the word in front of it.",
            "take a knee": "Take a knee is the proposal. White is the word on that bar.",
            "high note": "High note is the pitch and the peak. Feds is the word in front of it.",
            "hearin' clicks": "Hearin' clicks is the tap on the line. iPhone is the phone on that bar.",
            "out of the picture": "Gone from the frame is the threat on that bar. Gone is the word in front of it.",
            "necklace a Frank": "Necklace a Frank is the Homer chain and the rainbow. Rainbow is the word in front of it.",
            "came with a bar": "Came with a bar is the minibar and the 21. 21 is the word on that bar.",
            "shawty BDs": "Shawty BDs is the set and the baby daddies. Respect is the word in front of it.",
            "she biased": "She biased is the favor and by us. Seem is the word in front of it.",
            "other men are practice": "Other men are practice is the song and the warmup. Those is the word in front of it.",
            "more M's": "More M's is the money and the letter. Less is the word in front of it.",
            "less L's": "Less L's is the losses and the letter. More is the word on that bar.",
            "do no verses": "Do no verses sounds like Verzuz. Hits is the word on that bar.",
            "I baited": "I baited is the hook. Popstar is the word in front of it.",
            "meet PARTY": "Meet PARTY is the artist next door. Door is the word on that bar.",
            "watch face": "Watch face is the dial and the expression. Nah is the word in front of it."
      ,
            "like a villain": "Like a villain is the villa and the villain. Villas is the word in front of it.",
            "Nemo in the ocean": "Nemo in the ocean is the fish and the small fry. Neo is the name on that bar.",
            "like I'm Hulk Hogan": "Like I'm Hulk Hogan is the shirt and the wrestler. Rip is the word on that bar.",
            "parachuting molly": "Parachuting molly is the flight. Military is the word on that bar.",
            "with a dictionary": "With a dictionary is the club joke. 29 is the number on that bar.",
            "like NASA": "Like NASA is the exit. Roy is the name on that bar.",
            "when I'm 70": "When I'm 70 is the billions and the grade. Have is the word in front of it.",
            "need addressin'": "Need addressin' is the talk and the location. GPS is the word on that bar.",
            "shackin' together": "Shackin' together is the room and Shaq. Probably is the word in front of it.",
            "like a squid": "Like a squid is the ink. Ink is the word in front of it.",
            "blue in the face": "Blue in the face is the complaint. Diss is the word in front of it.",
            "blue in the safe": "Blue in the safe is the bills. Faces is the word on that bar.",
            "like a hockey coach": "Like a hockey coach is the bench and the sticks. Sticks is the word on that bar.",
            "bag with a pipe": "Bag with a pipe is the bagpipe. Scottish is the word on that bar.",
            "rackin' my brain": "Rackin' my brain is the thought and the rack. Money is the word on that bar.",
            "red button": "Red button is the record light and the gate. Gated is the word on that bar.",
            "do right and kill everything": "Do right and kill everything is the name. Death is the word on that bar.",
            "like I'm gettin' graded": "Like I'm gettin' graded is the mark and the billion. Circle is the word on that bar.",
            "drive is dedicated": "Drive is dedicated is the effort and the driver. Designated is the word on that bar.",
            "not a graduation": "Not a graduation is the album and the cap. Cap is the word on that bar.",
            "pad the stats": "Pad the stats is the numbers and the pad. Period is the word on that bar.",
            "hard pill to swallow": "Hard pill to swallow is the saying and the dose. Medication is the word on that bar.",
            "like a revelation": "Like a revelation is the surprise. Pop is the word in front of it.",
            "like some vegetation": "Like some vegetation is the plants. Dirt is the word on that bar.",
            "like a vaccination": "Like a vaccination is the shots. Shots is the word on that bar.",
            "like I'm Howard Hughes": "Like I'm Howard Hughes is the flight and the fortune. Sky is the word on that bar.",
            "pgLang on mute": "PgLang on mute is the quiet weekend. Challenge is the word on that bar.",
            "deadbeats": "Deadbeats is the beats on that bar. Beats is the word beside it.",
            "like presto": "Like presto is the magic word. Copperfield is the name on that bar.",
            "only blessed": "Only blessed is the nickname. Max is the name on that bar.",
            "like man had flu": "Like man had flu is the sick and the six. Six is the word on that bar.",
            "seein' a ghost": "Seein' a ghost is the spirit and the album. Person is the word on that bar.",
            "six-six": "Six-six is the area code. Woes is the word on that bar."
      ,
            "on that live": "On that live is the stream and the life. Alive is the word on that bar.",
            "nosebleeds": "Nosebleeds is the cheap seat. Wood is the word on that bar.",
            "trunk is in my hood": "Trunk is in my hood is the car and the block. Ghetto is the word in front of it.",
            "right my wrongs": "Right my wrongs is the past and the pen. Write is the word on that bar.",
            "eatin' Caesar": "Eatin' Caesar is the salad and the palace. Supermodel is the word on that bar.",
            "no Kente": "No Kente is the cloth and the name. Chains is the word on that bar.",
            "came with a pole": "Came with a pole is the stand and the piece. Pateks is the word on that bar.",
            "Canseco the mix": "Canseco the mix is the player and the juice. Juice is the word on that bar.",
            "cheaper to keep her": "Cheaper to keep her is the old song and the choice. Said is the word on that bar.",
            "your Finsta": "Your Finsta is the side page and the real one. Real is the word on that bar.",
            "like he snotty": "Like he snotty is the nose and the removal. Wipe is the word in front of it.",
            "lovin' the crew": "Lovin' the crew is the song and the crew. Hope is the word in front of it.",
            "like Gretzky": "Like Gretzky is the ice and the player. Ice is the word in front of it.",
            "for the 'Gram": "For the 'Gram is the app and the last name. Pic is the word on that bar.",
            "like bless me": "Like bless me is the sneeze. At is the word in front of it.",
            "Chat's behind": "Chat's behind is the bot and the writer. Words is the word on that bar.",
            "like Waldo": "Like Waldo is the search. Find is the word on that bar.",
            "Terry Fox": "Terry Fox is the run and the leg. Leg is the word on that bar.",
            "I'll cater to you": "I'll cater to you is the care and the sound-alike. Terrorist is the word on that bar.",
            "like some premises": "Like some premises is the tape and the lines. Lines is the word on that bar.",
            "like a brake light": "Like a brake light is the red light and the read. Read is the word on that bar.",
            "fishing for some answers": "Fishing for some answers is the hunt and the shark. White is the word on that bar.",
            "used to do was front": "Used to do was front is the act. Back is the word on that bar.",
            "grey in our conversation": "Grey in our conversation is the bubble and the unclear. History is the word on that bar.",
            "LOLOL": "LOLOL is the laugh and the oh well. Amusin is the word on that bar.",
            "not a GOAT": "Not a GOAT is the animal and the title. Description is the word on that bar.",
            "still the motto": "Still the motto is the saying and the song. Yolo is the word on that bar.",
            "if I'm lyin'": "If I'm lyin' is the oath and the flight. Flyin is the word on that bar.",
            "tennis ball": "Tennis ball is the shot and the zero. Love is the word on that bar.",
            "pickin' a lock": "Pickin' a lock is the door and the work. Tools is the word on that bar.",
            "Adidas to 'em": "Adidas to 'em is the stripes and the lines. Lines is the word on that bar.",
            "sell pies": "Sell pies is the bakery and the name. Patti is the name on that bar.",
            "diamondbacks": "Diamondbacks is the snake and the chain. Snakes is the word on that bar.",
            "about the practice": "About the practice is the press line. Game is the word on that bar.",
            "last resort": "Last resort is the end and the hotel. Inclusive is the word on that bar.",
            "like abbreviations": "Like abbreviations is the short form and the let-her. Letter is the word on that bar.",
            "be cremated": "Be cremated is the ash. Ass is the word on that bar.",
            "Infrared": "Infrared is the beam and the info. Beam is the word on that bar.",
            "in the can": "In the can is the jail and the tin. Lid is the word on that bar.",
            "like a tire": "Like a tire is the circle and the O. Stay is the word on that bar.",
            "like a bagel": "Like a bagel is the circle and the O. Stay is the word on that bar.",
            "three the kid": "Three the kid is the plea and the count. Kid is the word on that bar.",
            "clip us": "Clip us is the grab and the foul. Trippin is the word on that bar.",
            "when the hook drop": "When the hook drop is the chorus and the basket. Buckin is the word on that bar.",
            "all I need is a whistle": "All I need is a whistle is the official. Official is the word on that bar.",
            "flip the F out": "Flip the F out is the blowup and the brand. Fendi is the word on that bar.",
            "pyramid schemes": "Pyramid schemes is the scam and the tomb. Egyptians is the word on that bar.",
            "impress ya": "Impress ya is the flex and the car. Car is the word on that bar.",
            "live in Singapore": "Live in Singapore is the city and the sing-a-poor. Broke is the word on that bar.",
            "like the kitchen drawer": "Like the kitchen drawer is the knife put away. Knife is the word on that bar.",
            "who sewed the buttons": "Who sewed the buttons is the denim and the genes. Jeans is the word on that bar.",
            "like a coat": "Like a coat is the closet and the season. Summer is the word on that bar.",
            "like a Coke": "Like a Coke is the soda. Pop is the word on that bar.",
            "like a ghost": "Like a ghost is the surprise in the denim. Jeans is the word on that bar.",
            "richie like Lionel": "Richie like Lionel is the money and the singer. Real is the word on that bar.",
            "got flipped": "Got flipped is the turn and the loose talk. Sloppy is the word on that bar.",
            "the six upside down": "The six upside down is the digit. Nine is the word on that bar.",
            "for the Grahams": "For the Grahams is the family and the app. Gram is the word on that bar.",
            "Armor All": "Armor All is the shine and the armor. Knight is the word on that bar.",
            "Macaulay Culkin": "Macaulay Culkin is the kid in the house. Mansion is the word on that bar."
      ,
            "sweeter the berry": "Sweeter the berry is the old line turned around. Juice is the word on that bar.",
            "reality checks": "Reality checks is the bill and the books. Balances is the word on that bar.",
            "rest of my commas": "Rest of my commas is the pause and the money. Only is the word in front of it.",
            "time on your hands": "Time on your hands is the free time and the side. Side is the word on that bar.",
            "like I'm J. Cole": "Like I'm J. Cole is the rapper and the hair. Dread is the word in front of it.",
            "get RICO'd": "Get RICO'd is the case and the song. Suave is the word on that bar.",
            "like he Bart": "Like he Bart is the cartoon smack. Head is the word on that bar.",
            "turned duppy": "Turned duppy is the ghost. Played is the word on that bar.",
            "real vamp": "Real vamp is the night and the name. Geekin is the word on that bar.",
            "pint of Tech": "Pint of Tech is the pour and the piece. Red is the word on that bar.",
            "run fades": "Run fades is the fight and the route. Stick is the word on that bar.",
            "hold hands": "Hold hands is the clasp and the iron. Ridin is the word in front of it.",
            "take sand": "Take sand is the beach habit. Turks is the word on that bar.",
            "cookin' that Cersei": "Cookin' that Cersei is the name. White is the word on that bar.",
            "this is Gustavo": "This is Gustavo is the wolf and the boss. Bad is the word on that bar.",
            "nothin' is sweet": "Nothin' is sweet is the easy life and the suite. Penthouse is the word on that bar.",
            "dust a man": "Dust a man is the pen and the series. Sweep is the word on that bar.",
            "I'm a gymnast": "I'm a gymnast is the flip and the money. Bread is the word on that bar.",
            "without the T-Y": "Without the T-Y is the thank-you and the unity. You is the word on that bar.",
            "show the waves": "Show the waves is the hair and the trend. Cap is the word on that bar.",
            "spoiled rotten": "Spoiled rotten is the attitude and the gifts. Smell is the word on that bar.",
            "Mekhi Phif": "Mekhi Phif is the movie and the money. Paid is the word on that bar.",
            "lotta class": "Lotta class is the manners and the cars. Class is the word on that bar.",
            "stay slitherin": "Stay slitherin is the snake and the house. Snakes is the word in front of it.",
            "other hand": "Other hand is the wrist and the song. Watch is the word on that bar.",
            "like Vert": "Like Vert is the push and the song. Edge is the word on that bar.",
            "Jung body": "Jung body is the shape and the doctor. She is the word in front of it.",
            "Pretty Ricky": "Pretty Ricky is the group and the mood. Freaky is the word on that bar.",
            "more tracks": "More tracks is the songs and the hair. Salon is the word on that bar.",
            "in the crib": "In the crib is the house and the bed. Baby is the word on that bar.",
            "like a priest": "Like a priest is the church. Turks is the word on that bar.",
            "is magnolia": "Is magnolia is the song and the account. Milly is the word on that bar.",
            "got demoitis": "Got demoitis is the old version. Body is the word on that bar.",
            "like Russell": "Like Russell is the average and the player. Triple is the word on that bar.",
            "burst a bubble": "Burst a bubble is the pop and the guard. Star is the word on that bar.",
            "to the cross": "To the cross is the line he says. Pluto is the name on that bar.",
            "like I'm Kobe": "Like I'm Kobe is the jewelry and the titles. Rings is the word on that bar.",
            "X and O": "X and O is the hugs and the name. Love is the word on that bar.",
            "from Jupiter": "From Jupiter is the planet and the rhyme. Mars is the word on that bar.",
            "on my boardwalk": "On my boardwalk is the game and the top spot. Monopoly is the word on that bar.",
            "like half days": "Like half days is the short school day. Class is the word on that bar.",
            "air miles": "Air miles is the points and the fly. Mall is the word on that bar.",
            "devil in a tight dress": "Devil in a tight dress is the movie and the woman. Killer is the word on that bar.",
            "I'm gunproof": "I'm gunproof is the glow and the movie. Glow is the word on that bar.",
            "finally broke up": "Finally broke up is the split and the money. Broke is the word on that bar.",
            "hang me out to dry": "Hang me out to dry is the clothesline and the snub. Line is the word on that bar.",
            "outta hand": "Outta hand is the too-much and the gifts. Handouts is the word on that bar.",
            "cut ties": "Cut ties is the end and the peace. Peace is the word on that bar.",
            "don't fade away": "Don't fade away is the stay and the name. Mj is the name on that bar.",
            "Kappa Alpha": "Kappa Alpha is the step show and the gang. Steppin is the word on that bar.",
            "future and a past": "Future and a past is the life and the shape. Woman is the word on that bar.",
            "no-long-talker": "No-long-talker is the patois and the name. Baka is the name on that bar.",
            "we Chucky somethin'": "We Chucky somethin' is the doll and the song. Child is the word on that bar.",
            "skull gets hot": "Skull gets hot is the slang and the name. Nice is the word on that bar.",
            "cover they head": "Cover they head is the mask and the quiet. Clout is the word on that bar.",
            "paid by the letter": "Paid by the letter is the rate and the alphabet. Like is the word on that bar.",
            "own hip-hop": "Own hip-hop is the claim and the rent. Evict is the word on that bar.",
            "like Dell and Windows": "Like Dell and Windows is the computer and the turn. Pc is the word on that bar.",
            "Chromazz": "Chromazz is the name and the chrome. Rolls is the word on that bar.",
            "saved by the bell": "Saved by the bell is the escape and the show. Bayside is the word on that bar.",
            "doin' macarena": "Doin' macarena is the dance and the reach. Hands is the word on that bar.",
            "hit your noodle": "Hit your noodle is the meal and the head. Movies is the word on that bar.",
            "like MacGyver": "Like MacGyver is the fixer and the mask. Myers is the name on that bar.",
            "from the snow": "From the snow is the weather and the crew. Woes is the word on that bar.",
            "cha-cha slide": "Cha-cha slide is the dance and the name. Drama is the word on that bar.",
            "breakin' a Brink's": "Breakin' a Brink's is the truck and the spend. Cleef is the word on that bar.",
            "he's a wasteman": "He's a wasteman is the insult. Ex is the word on that bar.",
            "missin' was Aaliyah": "Missin' was Aaliyah is the person and the lack. Doors is the word on that bar.",
            "Addy in my system": "Addy in my system is the name and the address. Opp is the word on that bar.",
            "don't see a savage": "Don't see a savage is the look and the name. Twenty is the word on that bar.",
            "Loverboy": "Loverboy is the album and the mood. Romance is the word on that bar.",
            "clique about to blow": "Clique about to blow is the crew and the shutter. Road is the word on that bar.",
            "triple-double-Russ": "Triple-double-Russ is the stat and the face. Face is the word on that bar.",
            "caught the hands": "Caught the hands is the fight and the court. Stand is the word on that bar.",
            "a Cheerio": "A Cheerio is the cereal and the number. Serial is the word on that bar.",
            "wishin' death on me": "Wishin' death on me is the line and the name. Cent is the name on that bar.",
            "crack game": "Crack game is the street and the booth. Different is the word on that bar.",
            "just swangin'": "Just swangin' is the swing and the drive. Eyes is the word on that bar.",
            "not holdin' you down": "Not holdin' you down is the support and the stall. Back is the word on that bar.",
            "you're mine": "You're mine is the claim and the song. Yours is the word on that bar.",
            "exams for the boy": "Exams for the boy is the test and the look. Body is the word on that bar.",
            "see the future": "See the future is the sight and the name. Wavy is the word on that bar.",
            "dodge sentences": "Dodge sentences is the case and the grammar. Discuss is the word on that bar.",
            "play my part too": "Play my part too is the role and the part two. Sequel is the word on that bar.",
            "like the one-two": "Like the one-two is the count and the police. Move is the word on that bar.",
            "flippin' the script": "Flippin' the script is the twist and the table read. Read is the word on that bar.",
            "Cartier pen": "Cartier pen is the tool and the flex. Sound is the word on that bar.",
            "doin' backflips": "Doin' backflips is the move and the watch. Patek is the word on that bar.",
            "bought my dawg a Rollie": "Bought my dawg a Rollie is the watch and the loyalty. Rolled is the word on that bar.",
            "not kiddin'": "Not kiddin' is the serious and the duo. Playin is the word on that bar.",
            "CC's on that ho": "CC's on that ho is the logo and the measure. Surgeon is the word on that bar.",
            "clipped the hurdle": "Clipped the hurdle is the race and the fall. Trippin is the word on that bar.",
            "Prince of Persia": "Prince of Persia is the game and the title. Arab is the word on that bar.",
            "flirting with the thirty": "Flirting with the thirty is the number and the jersey. Outside is the word on that bar.",
            "red-shirted": "Red-shirted is the bench and the color. Twins is the word on that bar.",
            "all about my brothers": "All about my brothers is the family and the sample. Samplin is the word on that bar.",
            "like a campus": "Like a campus is the school and the house. Mansions is the word on that bar.",
            "empty crib in my empty crib": "Empty crib in my empty crib is the bed and the house. Got is the word on that bar.",
            "lookin' hot": "Lookin' hot is the heat and the look. Fever is the word on that bar.",
            "through a speaker": "Through a speaker is the music and the patois. Beat is the word on that bar.",
            "Houston, we got a problem": "Houston, we got a problem is the call and the city. Problem is the word on that bar.",
            "bended knee": "Bended knee is the proposal and the floor. Left is the word on that bar.",
            "grease me": "Grease me is the word and the country. Mykonos is the word on that bar.",
            "bidin' my time": "Bidin' my time is the wait and the name. Political is the word on that bar.",
            "gettin' bold": "Gettin' bold is the nerve and the font. Text is the word on that bar.",
            "dumb rich": "Dumb rich is the insult and the money. School is the word on that bar.",
            "Tiffany on you": "Tiffany on you is the jewelry and the shine. Poppin is the word on that bar.",
            "Fela Kuti": "Fela Kuti is the musician and the return. Died is the word on that bar.",
            "next to Kobe": "Next to Kobe is the height and the player. Tall is the word on that bar.",
            "cloud nine": "Cloud nine is the high and the feeling. Cozy is the word on that bar.",
            "little lamb": "Little lamb is the car and the vow. Married is the word on that bar.",
            "eyes blood red": "Eyes blood red is the color and the mood. Somethin is the word on that bar.",
            "woke shit": "Woke shit is the look and the word. Matted is the word on that bar.",
            "movin' like dogs": "Movin' like dogs is the album and the behavior. Lie is the word on that bar.",
            "fit off the mannequin": "Fit off the mannequin is the outfit and the flight. Canada is the word on that bar.",
            "boys tell stories": "Boys tell stories is the tale and the growth. Man is the word on that bar.",
            "not a home": "Not a home is the house and the saying. House is the word on that bar.",
            "show ID": "Show ID is the card and the rapper. 21 is the word on that bar.",
            "umbrellaed up": "Umbrellaed up is the cover and the weather. Rain is the word on that bar.",
            "take my crown": "Take my crown is the title and the end. Grave is the word on that bar.",
            "turnin' papers": "Turnin' papers is the homework and the money. Paid is the word on that bar.",
            "I'm the greatest": "I'm the greatest is the claim and the boxer. Knew is the word on that bar.",
            "stunt double": "Stunt double is the stand-in and the count. Two is the word on that bar.",
            "TLC shit": "TLC shit is the group and the member. Eye is the word on that bar.",
            "two wrongs": "Two wrongs is the saying and the fix. Right is the word on that bar.",
            "two-tones": "Two-tones is the watch and the gift. Givin is the word on that bar.",
            "skirt on a whip": "Skirt on a whip is the car and the logo. Crown is the word on that bar.",
            "body is tea": "Body is tea is the look and the name. Pain is the word on that bar.",
            "twenty-V-one": "Twenty-V-one is the count and the series. Hotel is the word on that bar.",
            "witch one": "Witch one is the question and the spell. Fairy is the word on that bar.",
            "empty clips": "Empty clips is the name and the duo. Wick is the word on that bar.",
            "key ingredient": "Key ingredient is the piece and the recipe. Recipe is the word on that bar.",
            "LIV after church": "LIV after church is the club and the Sunday. Sunday is the word on that bar.",
            "not in Kansas": "Not in Kansas is the line and the city. Lord is the word on that bar.",
            "hittin' swishes": "Hittin' swishes is the basket and the cigar. Swisher is the word on that bar.",
            "my vice": "My vice is the habit and the office. Election is the word on that bar.",
            "whole lot of M's": "Whole lot of M's is the letter and the size. Called is the word on that bar.",
            "Haffa B": "Haffa B is the name and the half. CL is the word on that bar.",
            "executives calls": "Executives calls is the meeting and the check. Bill is the word on that bar.",
            "like a BBL": "Like a BBL is the surgery and the love. Feel is the word on that bar.",
            "Franklin Saint": "Franklin Saint is the name and the show. Saint is the word on that bar.",
            "ho-ho-hoes": "Ho-ho-hoes is the laugh and the holiday. Nick is the word on that bar.",
            "under the mat": "Under the mat is the hide and the door. Key is the word on that bar.",
            "hit the jackpot": "Hit the jackpot is the win and the machine. Slot is the word on that bar.",
            "so official": "So official is the look and the game. Referee is the word on that bar.",
            "go to Venus": "Go to Venus is the planet and the sister. Jupiter is the word on that bar.",
            "racks like Serena": "Racks like Serena is the money and the player. Rings is the word on that bar.",
            "buy the tires": "Buy the tires is the car and the loyalty. Ride is the word on that bar.",
            "what a time": "What a time is the moment and the song. Alive is the word on that bar.",
            "sleepin' pattern": "Sleepin' pattern is the rest and the hours. Still is the word on that bar.",
            "like the truck": "Like the truck is the swerve and the date. Funeral is the word on that bar.",
            "feathers they pluck": "Feathers they pluck is the bird and the door. Doors is the word on that bar.",
            "thousand islands": "Thousand islands is the place and the dressing. Dressin is the word on that bar.",
            "go ham": "Go ham is the energy and the animal. Hog is the word on that bar.",
            "Mo City trip": "Mo City trip is the town and the ride. Trip is the word on that bar.",
            "season pass": "Season pass is the ticket and the stretch. Summer is the word on that bar.",
            "a flower would grow": "A flower would grow is the plant and the song. Concrete is the word on that bar.",
            "October's Own": "October's Own is the title and the holiday. July is the word on that bar.",
            "wings of an angel": "Wings of an angel is the spirit and the car. Road is the word on that bar.",
            "like no hair": "Like no hair is the bald and the ball. Balled is the word on that bar.",
            "break down ya d's": "Break down ya d's is the defense and the drink. Shots is the word on that bar.",
            "return of the mack": "Return of the mack is the song and the comeback. Back is the word on that bar.",
            "sonnin' them": "Sonnin' them is the sun and the son. Shade is the word on that bar.",
            "Big Pimpin'": "Big Pimpin' is the song and the director. Hype is the word on that bar.",
            "ex-men": "Ex-men is the team and the past. Marvel is the word on that bar.",
            "thirty-piece": "Thirty-piece is the meal and the player. Shai is the word on that bar.",
            "never get dirty": "Never get dirty is the hands and the trail. Trace is the word on that bar.",
            "exes live in Texas": "Exes live in Texas is the state and the singer. Strait is the word on that bar.",
            "eat each other": "Eat each other is the argument and the meal. Dinner is the word on that bar.",
            "like a lollipop": "Like a lollipop is the song and the name. Dwayne is the word on that bar.",
            "get on E": "Get on E is the fuel and the end. Ride is the word on that bar.",
            "Ben Frank' getter": "Ben Frank' getter is the bill and the style. Trendsetter is the word on that bar.",
            "got the YSL": "Got the YSL is the label and the house. Thugger is the word on that bar.",
            "fuckin' with the mob ties": "Fuckin' with the mob ties is the show and the city. Houston is the word on that bar.",
            "pardon my reach": "Pardon my reach is the manners and the spot. Top is the word on that bar.",
            "burn a bridge": "Burn a bridge is the break and the lamp. Light is the word on that bar.",
            "go deaf": "Go deaf is the hearing and the contact. Touch is the word on that bar.",
            "dash to my Dame": "Dash to my Dame is the name and the label. Roc is the word on that bar.",
            "draped up": "Draped up is the windows and the shine. Dripped is the word on that bar.",
            "water for the D's": "Water for the D's is the bottle and the drivers. Dom is the word on that bar.",
            "windows down": "Windows down is the cold and the season. Winter is the word on that bar.",
            "everything is kosher": "Everything is kosher is the word and the kitchen. Complain is the word on that bar.",
            "Courtney Love": "Courtney Love is the name and the mood. Crazy is the word on that bar.",
            "made a nickel": "Made a nickel is the coin and the sense. Sense is the word on that bar.",
            "distant lovers": "Distant lovers is the space and the singer. Marvin is the word on that bar.",
            "Boise state": "Boise state is the field and the blue. Turf is the word on that bar.",
            "the Shade Room": "The Shade Room is the page and the window. Blinds is the word on that bar.",
            "Dick Tracy": "Dick Tracy is the detective and the name. Ibiza is the word on that bar.",
            "pen-pal": "Pen-pal is the writer and the miles. Distance is the word on that bar.",
            "one-hunnid": "One-hunnid is the truth and the heat. Summertime is the word on that bar.",
            "not one fronted": "Not one fronted is the grill and the honesty. Paul is the word on that bar.",
            "head office": "Head office is the desk and the chain. Walgreens is the word on that bar.",
            "king in Jamaica": "King in Jamaica is the title and the drink. Ting is the word on that bar.",
            "gone 'til November": "Gone 'til November is the song and the month. November is the word on that bar.",
            "FuelBand": "FuelBand is the band and the product. Run is the word on that bar.",
            "pizza man": "Pizza man is the driver and the buzz. Delivery is the word on that bar.",
            "nickels for my thoughts": "Nickels for my thoughts is the saying and the coin. Dimes is the word on that bar.",
            "the cashier": "The cashier is the counter and the coins. Change is the word on that bar.",
            "Maya Angelou": "Maya Angelou is the poet and the number. 42 is the word on that bar.",
            "glue stick": "Glue stick is the supply and the hold. Blicky is the word on that bar.",
            "pulling strings": "Pulling strings is the favor and the guitar. Acoustic is the word on that bar.",
            "not Nintendo": "Not Nintendo is the console and the word. Switch is the word on that bar.",
            "take a shot for me": "Take a shot for me is the drink and the dedication. Shot is the word on that bar.",
            "all the care": "All the care is the effort and the album. Take is the word on that bar.",
            "Polo isn't at my session": "Polo isn't at my session is the producer and the absence. Session is the word on that bar.",
            "the game needs change": "The game needs change is the industry and the coins. Cashier is the word on that bar.",
            "for all the dogs": "For all the dogs is the album and the bark. Dogs is the word on that bar.",
            "Pete's sakes": "Pete's sakes is the saying and the name. Rocking is the word on that bar.",
            "bury me alive": "Bury me alive is the threat and the song. Wanna is the word on that bar.",
            "sign the contracts": "Sign the contracts is the deal and the DJ. Future is the word on that bar.",
            "in my grave": "In my grave is the song and the end. Money is the word on that bar.",
            "feel entitled": "Feel entitled is the claim and the service. Apple is the word on that bar.",
            "play hurt": "Play hurt is the injury and the player. Carter is the word on that bar.",
            "saving for Caribana": "Saving for Caribana is the festival and the vow. Marriage is the word on that bar.",
            "brainwashed": "Brainwashed is the movie and the mind. Kill is the word on that bar.",
            "my windshield": "My windshield is the glass and the winter. Ice is the word on that bar.",
            "old flex": "Old flex is the girl and the show. Workin is the word on that bar.",
            "workin' on it": "Workin' on it is the fix and the song. Flex is the word on that bar.",
            "off my keyboard": "Off my keyboard is the piano and the nose. Nose is the word on that bar.",
            "in your ends": "In your ends is the block and the feet. Ten is the word on that bar.",
            "no jersey": "No jersey is the shirt and the club. Ballin is the word on that bar.",
            "Harlem shaking": "Harlem shaking is the dance and the stress. Pressure is the word on that bar.",
            "chap's stick": "Chap's stick is the movie and the balm. Napoleon is the word on that bar.",
            "Gray's Anatomy": "Gray's Anatomy is the book and the body. Body is the word on that bar.",
            "auto-tune": "Auto-tune is the effect and the name. Pain is the word on that bar.",
            "Evil Angel": "Evil Angel is the studio and the name. Vivid is the word on that bar.",
            "got options": "Got options is the choice and the song. Chosen is the word on that bar.",
            "I'm a rider": "I'm a rider is the loyalty and the pen. Left is the word on that bar.",
            "gates, pearly": "Gates, pearly is the heaven and the name. Name is the word on that bar.",
            "into legends": "Into legends is the name and the street. Streets is the word on that bar.",
            "black wood": "Black wood is the interior and the name. Range is the word on that bar.",
            "solely fit": "Solely fit is the only and the shoe. Shoe is the word on that bar.",
            "the takeover": "The takeover is the song and the turn. Break is the word on that bar.",
            "Summer's mine": "Summer's mine is the season and the name. Summer is the word on that bar.",
            "take my credit card": "Take my credit card is the card and the spend. Spend is the word on that bar.",
            "down on her knees": "Down on her knees is the prayer and the floor. Reason is the word on that bar.",
            "all-star weekend": "All-star weekend is the game and the party. Start is the word on that bar.",
            "envy the life": "Envy the life is the jealousy and the state. Leadin is the word on that bar.",
            "spreadin' my wings": "Spreadin' my wings is the flight and the change. Cocoon is the word on that bar.",
            "studio trappin'": "Studio trappin' is the session and the stay. Room is the word on that bar.",
            "Richard prior": "Richard prior is the watch and the comic. Joke is the word on that bar.",
            "like Sha'Carri": "Like Sha'Carri is the sprinter and the race. Track is the word on that bar.",
            "Bun Vegas": "Bun Vegas is the name and the burn. Reply is the word on that bar.",
            "lil' Sicko": "Lil' Sicko is the name and the brand. Sideways is the word on that bar.",
            "back that ass up": "Back that ass up is the song and the dance. Fine is the word on that bar.",
            "Big Tymer": "Big Tymer is the duo and the money. Flipper is the word on that bar.",
            "too much cheese": "Too much cheese is the money and the box. KD is the word on that bar.",
            "all the roaming": "All the roaming is the travel and the charge. Bill is the word on that bar.",
            "screw the fuckin' world": "Screw the fuckin' world is the title and the DJ. World is the word on that bar.",
            "like Bajan": "Like Bajan is the island and the drink. Trini is the word on that bar.",
            "signs of the times": "Signs of the times is the era and the clock. Time is the word on that bar.",
            "exfoliate": "Exfoliate is the wash and the guy. Scrub is the word on that bar.",
            "Eric B For President": "Eric B For President is the record and the line. Evident is the word on that bar.",
            "your centric": "Your centric is the word and the culture. Afro is the word on that bar.",
            "now I'm cheese": "Now I'm cheese is the mood and the money. Tl is the word on that bar.",
            "Baruch Yitadel": "Baruch Yitadel is the prayer and the name. Yisrael is the word on that bar.",
            "buy time": "Buy time is the clock and the cash. Cash is the word on that bar.",
            "pay the price": "Pay the price is the cost and the saying. Owing is the word on that bar.",
            "short gate": "Short gate is the door and the fame. Side is the word on that bar.",
            "just foreplay": "Just foreplay is the preview and the start. World is the word on that bar.",
            "lies still": "Lies still is the rest and the lie. Sleep is the word on that bar.",
            "truth hurts": "Truth hurts is the pain and the lie. Heal is the word on that bar.",
            "the ATF": "The ATF is the crew and the letters. Rep is the word on that bar.",
            "your pros": "Your pros is the good and the writing. Cons is the word on that bar.",
            "sittin' sideways": "Sittin' sideways is the car and the look. Cut is the word on that bar.",
            "Kiki, she love me": "Kiki, she love me is the question and the answer. Shout is the word on that bar.",
            "Duval": "Duval is the name and the comic. Funny is the word on that bar.",
            "Go Uptown": "Go Uptown is the neighborhood and the song. York is the word on that bar.",
            "degrees and papers": "Degrees and papers is the school and the money. Educated is the word on that bar.",
            "tip-drill": "Tip-drill is the video and the no. Smell is the word on that bar.",
            "turn to chrome": "Turn to chrome is the metal and the brand. Heart is the word on that bar.",
            "on some street shit": "On some street shit is the block and the dance. Dance is the word on that bar.",
            "only YOLO": "Only YOLO is the motto and the once. Solo is the word on that bar.",
            "a Drac'": "A Drac' is the name and the match. Studio is the word on that bar.",
            "Mr. Rogers": "Mr. Rogers is the DJ and the show. Screw is the word on that bar.",
            "the top is gone": "The top is gone is the roof and the car. Drop is the word on that bar.",
            "cross your mind": "Cross your mind is the thought and the path. Escape is the word on that bar.",
            "for life": "For life is the vow and the song. Forever is the word on that bar.",
            "360 windmill": "360 windmill is the dunk and the exit. Scene is the word on that bar.",
            "like Firestone": "Like Firestone is the tire and the fatigue. Tired is the word on that bar.",
            "a Clydesdale": "A Clydesdale is the horse and the ad. Ridin is the word on that bar.",
            "love's locked down": "Love's locked down is the song and the cuffs. Cuffing is the word on that bar.",
            "tuna in a bowl": "Tuna in a bowl is the fish and the cash. Hundreds is the word on that bar.",
            "Madonna hoes": "Madonna hoes is the school and the name. Niggas is the word on that bar.",
            "let your hair down": "Let your hair down is the ease and the height. Top is the word on that bar.",
            "like Blanka": "Like Blanka is the character and the shock. Fighter is the word on that bar.",
            "Jack son": "Jack son is the actor and the split. Sam is the word on that bar.",
            "the two-three": "The two-three is the number and the city. City is the word on that bar.",
            "mountain of truth": "Mountain of truth is the pile, and kush is the word on that bar.",
            "fountain of youth": "Fountain of youth is the bottle, and wine is the word on that bar.",
            "trick-trick": "Trick-Trick is the Detroit rapper, and Detroit is the city on that bar.",
            "goin' vegan": "Goin' vegan is the diet, and beefin is the fight on that bar.",
            "ink with a major": "Ink with a major is the deal and the print. Printer is the word on that bar.",
            "stayed up": "Stayed up is the lights and the rank. Christmas is the word on that bar.",
            "airing laundry": "Airing laundry is the gossip and the wash. Dryer is the word on that bar.",
            "Father's day": "Father's day is the holiday and the rank. Sonned is the word on that bar.",
            "get down": "Get down is the join-in and the fall. Lay is the word on that bar.",
            "ask V-O": "Ask V-O is the friend, and flow is the word on that bar.",
            "MC hammered": "MC hammered is the dancer and the drink. Club is the word on that bar.",
            "call me T-Pain": "Call me T-Pain is the name, and sleeve is the word on that bar.",
            "real italics": "Real italics is the slant, and bold is the word on that bar.",
            "still fly": "Still fly is the cool and the height. Float is the word on that bar.",
            "switchin' majors": "Switchin' majors is the college and the choice. Decide is the word on that bar.",
            "so far gone": "So far gone is the mixtape and the exit. Outta is the word on that bar.",
            "write my wrongs": "Write my wrongs is the fix and the pen. Right is the word on that bar.",
            "hit the Harden": "Hit the Harden is the step-back, and stepped is the word on that bar.",
            "in sync": "In sync is the group and the timing. Justin is the word on that bar.",
            "my true religion": "True Religion is the jeans, and seams is the word on that bar.",
            "six lives": "Six lives is the cat and the hometown. Cat is the word on that bar.",
            "forward to me": "Forward to me is the invite, and forward is the nerve on that bar.",
            "the world is yours": "The world is yours is the film and the record. City is the word on that bar.",
            "don't be ridiculous": "Don't be ridiculous is the candy name, and reese is the word on that bar.",
            "the replacement": "The replacement is the new duo, and songz is the word on that bar.",
            "it's ecstasy": "It's ecstasy is the Barry White song, and next is the word on that bar.",
            "orange full moon": "The orange full moon is the sky, and nap is the word on that bar.",
            "speed stick": "Speed Stick is the deodorant, and deodorant is the word on that bar.",
            "big tired": "Big tired is the fatigue and the tire. Tractor is the word on that bar.",
            "she's a spice": "She's a spice is the artist and the heat. Bike is the word on that bar.",
            "like Yokohama": "Like Yokohama is the tire, and bike is the word on that bar.",
            "serve backhands": "Serve backhands is the tennis shot, and backspin is the word on that bar.",
            "southern eyes": "Southern eyes is the welcome, and decent is the word on that bar.",
            "just nevermind": "Just nevermind is the album, and honestly is the word on that bar.",
            "G check": "G check is the test, and played is the word on that bar.",
            "a-la-la-lollipop": "A-la-la-lollipop is the song, and singin is the word on that bar.",
            "less sense": "Less sense is the scent, and perfume is the word on that bar.",
            "eyes closed": "Eyes closed is the rush, and blindfolded is the word on that bar.",
            "such a bone": "Such a bone is the reply, and dog is the word on that bar.",
            "doing donuts": "Doing donuts is the spin and the record. Dilla is the word on that bar.",
            "Yves slatt Laurent": "Yves slatt Laurent is the name and the label. Ysl is the word on that bar.",
            "acting tonto": "Acting tonto is the Spanish, and papi is the word on that bar.",
            "couple of beavers": "A couple of beavers is the animal and the dam. Damns is the word on that bar.",
            "Drew Lord": "Drew Lord is the coach, and pass is the word on that bar.",
            "Double O": "Double O is the agent, and suits is the word on that bar.",
            "Jenny and Swayze": "Jenny and Swayze is the film pair, and swayze is the word on that bar.",
            "Game of Thrones": "Game of Thrones is the show, and momma is the word on that bar.",
            "Home Alone": "Home Alone is the film, and momma is the word on that bar.",
            "you and the six": "You and the six is the city and the mother. Raised is the word on that bar.",
            "take advice": "Take advice is the warning and the tip. Great is the word on that bar.",
            "retired teacher": "Retired teacher is the job and the lesson. Words is the word on that bar.",
            "checks bounced": "Checks bounced is the bill and the comeback. Back is the word on that bar.",
            "one button": "One button is the temper, and push is the word on that bar.",
            "toss the keys": "Toss the keys is the loan, and car is the word on that bar.",
            "just be friends": "Just be friends is the breakup line, and anymore is the word on that bar.",
            "gyal heart": "Gyal heart is the soft man, and man is the word on that bar.",
            "it's personal": "It's personal is the stake, and business is the word on that bar.",
            "like Sopranos": "Like Sopranos is the show, and italianos is the word on that bar.",
            "El Chico": "El Chico is the name, and cincuenta is the word on that bar.",
            "Grab Eliza": "Grab Eliza is the name, and ibiza is the word on that bar.",
            "speed up the visa": "Speed up the visa is the paperwork, and trip is the word on that bar.",
            "bien loquita": "Bien loquita is very wild, and freak is the word on that bar.",
            "needs a bonita": "A bonita is the pretty one, and Benito is the word on that bar.",
            "mis cueros": "Cueros is the word on that bar, and yales is the other.",
            "listen to rats": "Rats is the informant, and boy is the word on that bar.",
            "like DaBaby": "Like DaBaby is the name, and stretched is the word on that bar.",
            "around Dracs": "Dracs is the name and the gun. Drake is the word on that bar.",
            "sometimes we laugh": "Sometimes we laugh is the smile, and cry is the word on that bar.",
            "a ghost town": "A ghost town is the record, and block is the word on that bar.",
            "closeable gap": "Closeable gap is the brand, and store is the word on that bar.",
            "Tae is the best": "Tae is the best is the stylist, and wig is the word on that bar.",
            "moved out the Ritz": "Moved out the Ritz is the hotel, and bent is the word on that bar.",
            "Garden of Eden": "Garden of Eden is the yard, and backyard is the word on that bar.",
            "victory lap": "Victory lap is the album and the lap. Ran is the word on that bar.",
            "got a strap": "A strap is the cover and the gun. Need is the word on that bar.",
            "doughnut shops": "Doughnut shops is the hangout, and cops is the word on that bar.",
            "heat of the moment": "Heat of the moment is the rush, and straight is the word on that bar.",
            "know the road": "Know the road is the route, and hit is the word on that bar.",
            "miss the boat": "Miss the boat is the chance, and coach is the word on that bar.",
            "sit in coach": "Sit in coach is the cheap seat, and boat is the word on that bar.",
            "dog days": "Dog days is the song and the summer. Over is the word on that bar.",
            "red weave": "Red weave is the hair and the name. Thong is the word on that bar.",
            "came to my senses": "Came to my senses is the clear head, and nut is the word on that bar.",
            "patty gang": "Patty gang is the watch, and rollie is the word on that bar.",
            "I'm with Red": "I'm with Red is the guest and the team. Cincinnati is the word on that bar.",
            "I'm a pitbull": "I'm a pitbull is the dog and the artist. Dale is the word on that bar.",
            "P-I-C": "P-I-C is the letters, and see is the word on that bar.",
            "what damage": "What damage is the spend, and mall is the word on that bar.",
            "make love": "Make love is the commitment, and fuck is the word on that bar.",
            "the Batphone": "The Batphone is the private line, and work is the word on that bar.",
            "six summers": "Six summers is the years and the city. Run is the word on that bar.",
            "get off again": "Get off again is the release, and case is the word on that bar.",
            "see you flexing": "See you flexing is the celebration, and Kaepernick is the word on that bar.",
            "life's hurdles": "Life's hurdles is the track and the trouble. Lolo is the word on that bar.",
            "Jay and Bey": "Jay and Bey is the couple, and poor is the word on that bar.",
            "hold on you're going home": "Hold on you're going home is the song and the off-season. Season is the word on that bar.",
            "Triple Crown": "Triple Crown is the race and the drink. Bartender is the word on that bar.",
            "on the Goose": "On the Goose is the vodka, and juice is the word on that bar.",
            "callin' a truce": "Callin' a truce is the peace, and mirror is the word on that bar.",
            "after Doe": "After Doe is the money and the pitch. Re is the word on that bar.",
            "kick and a twitch": "Kick and a twitch is the recoil and the stream. Glock is the word on that bar.",
            "Pyramids": "Pyramids is the song, and ocean is the word on that bar.",
            "your man": "Your man is the partner, and manager is the word on that bar.",
            "get across": "Get across is the message, and overseas is the word on that bar.",
            "free time": "Free time is the spare hours, and costing is the word on that bar.",
            "end of a world": "End of a world is the bubble, and girl is the word on that bar.",
            "bigger picture": "The wide view is the scale, and vision is the word on that bar.",
            "comin' in first": "Comin' in first is the win, and last is the word on that bar.",
            "pillow with a mint": "Pillow with a mint is the hotel, and fresher is the word on that bar.",
            "throw your ones": "Throw your ones is the bills, and air is the word on that bar.",
            "shoot down my flight": "Shoot down my flight is the trip and the envy. Lands is the word on that bar.",
            "that cream": "That cream is the cash, and Tang is the word on that bar.",
            "can we kick it": "Can we kick it is the song, and Phife is the word on that bar.",
            "Barack Hussein": "Barack Hussein is the name and the room. Suite is the word on that bar.",
            "Bel-Air": "Bel-Air is the show, and Will is the word on that bar.",
            "back in the Six": "Back in the Six is the city, and months is the word on that bar.",
            "on the hotline": "On the hotline is the phone, and text is the word on that bar.",
            "backpack underground": "Backpack underground is the crowd, and skippin is the word on that bar.",
            "trays in both hands": "Trays in both hands is the serving and the steel. Cater is the word on that bar.",
            "cover up": "Cover up is the ink, and soul is the word on that bar.",
            "not a stainless": "Not a stainless is the metal, and watch is the word on that bar.",
            "a lot of smoke": "A lot of smoke is the cloud, and crack is the word on that bar.",
            "overthink": "Overthink is the loop, and drink is the word on that bar.",
            "took an L": "Took an L is the loss, and damage is the word on that bar.",
            "alarm ya": "Alarm ya is the warning and the name. Breana is the word on that bar.",
            "little liar": "Little liar is the story, and money is the word on that bar.",
            "a canopy": "A canopy is the cover, and lies is the word on that bar.",
            "guns with the ink": "Guns with the ink is the tattoo, and skin is the word on that bar.",
            "a ponytail": "A ponytail is the hair, and past is the word on that bar.",
            "car with the strap": "Car with the strap is the pistol in the back, and past is the word on that bar.",
            "straight to the face": "Straight to the face is the shot, and liquor is the word on that bar.",
            "my cues": "My cues is the hint and the cash. Clutch is the word on that bar.",
            "we're going home": "We're going home is the return, and hold is the word on that bar.",
            "standin' up": "Standin' up is the posture, and knees is the word on that bar.",
            "we don't get impeached": "We don't get impeached is the office, and suites is the word on that bar.",
            "Miami Heat": "Miami Heat is the team, and beach is the word on that bar.",
            "like Montana": "Like Montana is the hat and the state. Peak is the word on that bar.",
            "talk used to be cheap": "Talk used to be cheap is the old price, and free is the word on that bar.",
            "cheap seat": "A cheap seat is the distance, and view is the word on that bar.",
            "summer just started": "Summer just started is the season, and done is the word on that bar.",
            "AM to the PM": "AM to the PM is the song and the hours. Day is the word on that bar.",
            "the garden": "The garden is the arena, and noodles is the word on that bar.",
            "ain't single": "Ain't single is the status and the record. Dropped is the word on that bar.",
            "Olympic pools": "Olympic pools is the water, and money is the word on that bar.",
            "no bench time": "No bench time is the rotation, and starter is the word on that bar.",
            "draw attention": "Draw attention is the crowd, and pen is the word on that bar.",
            "the gift": "The gift is the talent and the album half. Curse is the word on that bar.",
            "copying some vows": "Copying some vows is the wedding, and eyes is the word on that bar.",
            "top three": "Top three is the rank, and Trey is the word on that bar.",
            "I peak": "I peak is the height, and interests is the word on that bar.",
            "kick a punt": "Kick a punt is the kick, and goal is the word on that bar.",
            "been down so long": "Been down so long is the low, and up is the word on that bar.",
            "reach back": "Reach back is the catch, and three is the word on that bar.",
            "more chune": "More chune is the tune, and headtop is the word on that bar.",
            "thrillin bars": "Thrillin bars is the writing, and Ghrisam is the word on that bar.",
            "the last hope": "The last hope is the song and the rank. Soundscan is the word on that bar.",
            "R&B Diva": "R&B Diva is the singer, and rapper is the word on that bar.",
            "dun know": "Dun know is the yes, and already is the word on that bar.",
            "cannon on my hip": "Cannon on my hip is the gun and the husband. Mariah is the word on that bar.",
            "no off notes": "No off notes is the piano, and keys is the word on that bar.",
            "stick with her": "Stick with her is the stay, and honey is the word on that bar.",
            "checks cut": "Checks cut is the payment, and Benedict is the word on that bar.",
            "bad meaning bad": "Bad meaning bad is the warning, and good is the word on that bar.",
            "seedy": "Seedy is the block, and sesame is the word on that bar.",
            "switch wifey": "Switch wifey is the change, and season is the word on that bar.",
            "have my heart": "Have my heart is the love, and dead is the word on that bar.",
            "Yamaha mama": "Yamaha mama is the girl, and rider is the word on that bar.",
            "Matilda": "Matilda is the film, said beside cookin'.",
            "faceshot": "Faceshot is the stolen identity, said beside identity.",
            "Deadboy": "Deadboy is Lucki, said beside luck.",
            "Spirit": "Spirit is the airline, said beside flyin'.",
            "Akorn": "Akorn is the acorn, said beside the squirrel.",
            "Bronny James": "Bronny James wore the Trojans, said beside Trojan.",
            "main cabin": "Main cabin is the plane seat, said beside plain.",
            "Alvin Kamara": "Alvin Kamara plays for the Saints, said beside saint.",
            "eczema": "Eczema is the itch, said beside scratch.",
            "Monica Lewinsky": "Monica Lewinsky is the presidential name, said beside presidential.",
            "John Collins": "John Collins wears 20, said beside the 20.",
            "through the wire": "Through the Wire is the Kanye song, said beside Kanye.",
            "Kid Bop": "Kid Bop is the cover series, said beside hip-hop.",
            "hell": "Hell is the Michigan town, said beside zip.",
            "Vez": "Vez is Icewear Vezzo, said beside iced up.",
            "MVP": "MVP is the 30-a-game year, said beside 30.",
            "wings": "Wings is the Robin jeans logo, said beside Robin.",
            "fighting demons": "Fighting demons is the inner fight, said beside deceased.",
            "tan lines": "Tan lines is the sun, said beside shade.",
            "Arnez": "Arnez is the One on One character, said beside one-on-one.",
            "heart surgery": "Heart surgery is the cold heart, said beside freeze.",
            "sale": "Sale is the cell, said beside singin.",
            "leg crampin": "Leg crampin is the athlete's lock-up, said beside ran.",
            "Donda": "Donda is the album from the stadium, said beside Benz.",
            "wire": "Wire is the glasses frame, said beside Cartiers.",
            "Android": "Android is the green thread, said beside green.",
            "Paul Bunyan": "Paul Bunyan is the lumberjack, said beside wood.",
            "Set It Off": "Set It Off is the film, said beside bank.",
            "Eggo": "Eggo is the waffle ad, said beside let go.",
            "close friends": "Close friends is the green ring, said beside green.",
            "Kemba Walker": "Kemba Walker is the player, said beside cream.",
            "meal": "Meal is the million, said beside steak.",
            "Neighborhood chucking": "Neighborhood chucking is the blue set, said beside blue.",
            "Norbit": "Norbit is the movie hug, said beside fat.",
            "Pistol Pete": "Pistol Pete is the scorer, said beside pass.",
            "pull": "Pull is the three, said beside Curry.",
            "Carlos Boozer": "Carlos Boozer is the dark beard, said beside dark.",
            "St. Lunatic": "St. Lunatic is Nelly's group, said beside Nelly.",
            "Boban": "Boban is the tall center, said beside bigger.",
            "Die Lit": "Die lit is the Carti album, said beside Carti.",
            "Brook and Robin": "Brook and Robin are the Lopez brothers, said beside brothers.",
            "Neverland": "Neverland is the ranch, said beside pop.",
            "say my name": "Say my name is the Destiny's Child song, said beside Beyoncé.",
            "Taylor Gang": "Taylor Gang is the label, said beside smoke.",
            "hundreds": "Hundreds is the bill, said beside wipe.",
            "twenty": "Twenty is the pocket change, said beside change.",
            "Thottie breaking": "Thottie breaking is the Keef tape, said beside Glory Gang.",
            "Pootie Tang": "Pootie Tang is the quiet flop, said beside noise.",
            "Kelly, Michelle": "Kelly, Michelle are the Cater 2 U pair, said beside cater.",
            "DX": "DX is the wrestling pair, said beside suck it.",
            "Naismith": "Naismith is the basketball hall, said beside fame.",
            "Joe Burrow": "Joe Burrow is the striped cat, said beside stripes.",
            "Cracker Barrel": "Cracker Barrel is the breakfast syrup, said beside syrup.",
            "Chuckie": "Chuckie is the glasses, said beside frames.",
            "child": "Child is the backend name, said beside backends.",
            "PrizePick": "PrizePick is the nightly prop, said beside ball.",
            "Beanie Sigel": "Beanie Sigel is the song in the air, said beside air.",
            "Red Bull": "Red Bull is the wings, said beside fly.",
            "bull": "Bull is the Philly word, said beside Philly.",
            "Uzi Made": "Uzi Made is the Japan line, said beside Japan.",
            "Curtis": "Curtis is the role, said beside die tryin.",
            "Poison": "Poison is the song, said beside mind.",
            "Raptors": "Raptors is the team, said beside six.",
            "Hut": "Hut is the snap, said beside plays.",
            "blue": "Blue is the bill, said beside sad.",
            "Earl Sweatshirt": "Earl Sweatshirt is the long hair, said beside haircut.",
            "Clinton Capella": "Clinton Capella is the alley-oop, said beside oop.",
            "second place": "Second place is the medal, said beside white.",
            "rainbow": "Rainbow is the flag, said beside sus.",
            "Titty": "Titty is the Tity Boi hook, said beside ridin.",
            "billy": "Billy is the dad, said beside Hannah Montana.",
            "Linwood": "Linwood is the two-family house, said beside flat.",
            "Jason brother": "Jason brother is the name, said beside loyal.",
            "die": "Die is the dive, said beside lower.",
            "hundred": "Hundred is the score, said beside Wilt.",
            "Otto Potter": "Otto Potter is the Porter name, said beside Wilt.",
            "throwin' salt": "Throwin' salt is the shade, said beside icy.",
            "Quasimodo": "Quasimodo is the hunch, said beside back.",
            "Ricky": "Ricky is the Owens name, said beside outfit.",
            "edible arrangement": "Edible arrangement is the fruit, said beside money.",
            "no more drama": "No more drama is the album, said beside Blige.",
            "moi": "Moi is the kiss, said beside French.",
            "red dirt": "Red dirt is the clay, said beside Alabama.",
            "blue strips": "Blue strips is the bill, said beside paper.",
            "all that": "All that is the show, said beside Kel.",
            "high": "High is the drug, said beside hills.",
            "white horns": "White horns is the Cartier, said beside Satan.",
            "doubled up": "Doubled up is the triple-double, said beside Oscar Robertson.",
            "pip": "Pip is the pimp, said beside sixteen.",
            "chicken wing": "Chicken wing is the lemon pepper, said beside Lou Will.",
            "wild out": "Wild out is the show, said beside Nick Cannon.",
            "Paul George": "Paul George is the miss, said beside around.",
            "MIA": "MIA is the missing, said beside dizzy.",
            "red beans and rice": "Red beans and rice is the cash, said beside fifties.",
            "Shameless": "Shameless is the show, said beside white.",
            "Maino": "Maino is the record, said beside haters.",
            "beef": "Beef is the meat, said beside gyro.",
            "Kyro": "Kyro is the affiliate, said beside limit.",
            "thug life": "Thug life is the pose, said beside pac.",
            "Ariel": "Ariel is the mermaid, said beside sing.",
            "bae": "Bae is the bay, said beside bay.",
            "Rey Mysterio": "Rey Mysterio is the 619, said beside six.",
            "Optimus": "Optimus is the robot, said beside prime.",
            "Shell": "Shell is the station, said beside gas.",
            "Leo": "Leo is the sign, said beside lion.",
            "Tina": "Tina is the llama, said beside llama.",
            "Denise's": "Denise's is the bakery, said beside cake.",
            "Wee Man": "Wee Man is the stuntman, said beside money.",
            "Kells": "Kells is the singer, said beside remix.",
            "GED": "GED is the test, said beside testin'.",
            "Poseidon": "Poseidon is the sea god, said beside water.",
            "Finn": "Finn is the cartoon, said beside Jake.",
            "cadera": "Cadera is the hip, said beside Hugo.",
            "Tetris": "Tetris is the game, said beside blocks.",
            "origami": "Origami is the paper art, said beside paper.",
            "harp": "Harp is the instrument, said beside strings.",
            "nerd": "Nerd is the band, said beside Urkel.",
            "level": "Level is the swapped word, said beside brain.",
            "Christine": "Christine is the singer, said beside million.",
            "Armstrong": "Armstrong is the cyclist, said beside bike.",
            "Crawford": "Crawford is the name, said beside Cindy.",
            "Ambush": "Ambush is the label, said beside POW.",
            "Zoro": "Zoro is the swordsman, said beside cut.",
            "finessed": "Finessed is the name, said beside Brandon.",
            "Cash": "Cash is the name, said beside XO.",
            "Moonwalk": "Moonwalk is the dance, said beside twenties.",
            "'Port": "'Port is the brand, said beside New.",
            "World Peace": "World Peace is the name, said beside Metta.",
            "feta": "Feta is the cheese, said beside cheese.",
            "roger": "Roger is the call, said beside copy.",
            "Dove bars": "Dove bars is the soap, said beside soap.",
            "'Luminati": "'Luminati is the eye, said beside Fetty Wap.",
            "die 'lone": "die 'lone is the slogan, said beside VLONE.",
            "Forest": "Forest is the name, said beside run.",
            "sequin": "Sequin is the sparkle, said beside diamonds.",
            "deep end": "Deep end is the pool, said beside water.",
            "Stefan": "Stefan is the name, said beside Urkel.",
            "vent": "Vent is the air, said beside AC.",
            "wildin' out": "wildin' out is the show, said beside Nick Cannon.",
            "Phillip": "Phillip is the screwdriver, said beside loose screw.",
            "bird, man": "bird, man is the name, said beside Lugz.",
            "Clifford": "Clifford is the dog, said beside big dog.",
            "Ragu": "Ragu is the sauce, said beside sauce.",
            "IMAX": "IMAX is the theater, said beside 3D.",
            "Casper": "Casper is the cartoon, said beside ghost.",
            "Hostess": "Hostess is the snack cake, said beside cake.",
            "Geico": "Geico is the gecko, said beside lizard.",
            "playin' hockey": "Playin' hockey is the sport, said beside icy."
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
        XCTAssertTrue(cancer.contains("cancer that"))
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
        XCTAssertEqual(NounBankCatalog.mentionPartners(for: items.first { $0.insertWord == "Jrue Holiday" }!), ["holidays", "sprite"])
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
            "I just made a clean Sprite look like Jrue Holiday",
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
        XCTAssertTrue(NounMentionWorth.keeps(
            "Why she only good for head and cookin'? Why she Matilda?",
            phrases: halves("Matilda")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Spin a bend and faceshot a nigga, steal identity (Face his ass)",
            phrases: halves("faceshot")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I gotta keep that wood tucked, Deadboy my only good luck",
            phrases: halves("Deadboy")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm high off yellow pills like I'm flyin' on Spirit",
            phrases: halves("Spirit")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I cracked the seal on an Akorn bottle, ain't never seen no squirrel get near us",
            phrases: halves("Akorn")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "She want me to take the Trojan off and sign it, but I'm not Bronny James (James)",
            phrases: halves("Bronny James")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "It been a minute since I seen the main cabin, but half my watches plain",
            phrases: halves("main cabin")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm Alvin Kamara lit, I done dragged her quick, you textin' that ho like a saint",
            phrases: halves("Alvin Kamara")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Like it got eczema, I scratch off so many government names off pints of red",
            phrases: halves("eczema")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "She gave me head, my wrist on presidential, it's giving me Monica Lewinsky",
            phrases: halves("Monica Lewinsky")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Right now this Perc' 20 on my back like John Collins",
            phrases: halves("John Collins")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "This that Kanye check, they sent it through the wire",
            phrases: halves("through the wire")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "They turned hip-hop to Kid Bop (No kizzy)",
            phrases: halves("Kid Bop")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "They say that we live in hell, I just smoked a zip in hell",
            phrases: halves("hell")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Spin the bin, sign his ass to Vez', leave him iced up",
            phrases: halves("Vez")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "And I average 30 every show, MVP, yeah",
            phrases: halves("MVP")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "You ignorant, you plot on me, I'll give you wings like Robin jeans",
            phrases: halves("wings")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "He swear he fighting demons, but ain't never made a opp deceased",
            phrases: halves("fighting demons")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "All the shade they throwin', it ain't workin', I got tan lines, nigga",
            phrases: halves("tan lines")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Did a one-on-one with your ho, I'm lil' Arnez",
            phrases: halves("Arnez")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "If I had a heart surgery, the doctor'd freeze to death",
            phrases: halves("heart surgery")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Need an R&B deal, singin' to get out the sale",
            phrases: halves("sale")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ran them real M's up without leg crampin'",
            phrases: halves("leg crampin")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I made this, was in the Benz, like the Donda",
            phrases: halves("Donda")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I don't give a fuck if its Cartiers, nigga, I ain't't wearin no wire (Stupid ass nigga)",
            phrases: halves("wire")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "These niggas green as the texts on an Android",
            phrases: halves("Android")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Swing wood and metal, Veeze Paul Bunyan",
            phrases: halves("Paul Bunyan")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Hit the bank, get a bag like Set It Off",
            phrases: halves("Set It Off")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Let go of my swag like an Eggo waffle",
            phrases: halves("Eggo")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "The green all in my circle, this shit ain't no close friends",
            phrases: halves("close friends")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I poured the Wock in the cream soda, it look like Kemba Walker",
            phrases: halves("Kemba Walker")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "These niggas dumb, they'll steal the steak, we was tryna make a meal with 'em (Tryna make a meal with 'em)",
            phrases: halves("meal")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I spread so many blue hundreds, look like I'm Neighborhood chucking",
            phrases: halves("Neighborhood chucking")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "My pockets fat and I'm huggin' on it like I'm Norbit",
            phrases: halves("Norbit")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Cup dark like the hair dye on Carlos Boozer",
            phrases: halves("Carlos Boozer")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Bands just like Nelly face, I'm a St. Lunatic",
            phrases: halves("St. Lunatic")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Same size as Boban, bigger than I ever been",
            phrases: halves("Boban")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Playboy like Carti, no cap, man, I might die lit",
            phrases: halves("Die Lit")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ballin' with my brothers, I feel like Brook and Robin",
            phrases: halves("Brook and Robin")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm a dirty pop king, I'm buyin' Neverland",
            phrases: halves("Neverland")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I can’t back down from no nigga, I bring more smoke than Taylor Gang (Shh)",
            phrases: halves("Taylor Gang")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Crybaby Veeze, use the hundreds, wipe it away",
            phrases: halves("hundreds")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I don’t got change for twenty, nigga, twenty ain't nothin’ but change",
            phrases: halves("twenty")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Thottie breaking, Glory Gang, slimy, I should be ashamed (Gang)",
            phrases: halves("Thottie breaking")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "He done dropped a hundred tapes, made no noise like Pootie Tang (What?)",
            phrases: halves("Pootie Tang")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I had to tell that lil' bitch, \"Suck it, suck it\", I went DX on a hoe",
            phrases: halves("DX")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Skipped right to the Hall of Fame, they should write my name in the Naismith",
            phrases: halves("Naismith")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Havin' stripes like Joe Burrow, havin' syrup like Cracker Barrel",
            phrases: halves("Joe Burrow")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Havin' stripes like Joe Burrow, havin' syrup like Cracker Barrel",
            phrases: halves("Cracker Barrel")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Baby bottle with the Chrome frames, lil' Chuckie from the Rugrats",
            phrases: halves("Chuckie")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "See a nigga gettin' backends now she wanna child like NoCap",
            phrases: halves("child")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'ma ball like every night, better put my name on your PrizePick",
            phrases: halves("PrizePick")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm fly as hell, it's like Red Bull when I shop",
            phrases: halves("Red Bull")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ask my Philly niggas about Veeze, he a slimy bull",
            phrases: halves("bull")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm rich right now, you old as hell, you gon' die tryin' like Curtis (Hahah)",
            phrases: halves("Curtis")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "All these bad bitches drive me out my mind, it's like poison (It's like poison)",
            phrases: halves("Poison")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I got a twin, and ball for the six, but ain't the raptors (Nah)",
            phrases: halves("Raptors")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Way I run the plays, man, I should be screamin', \"Hut\" (Hut)",
            phrases: halves("Hut")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "All my money blue, think it's sad, need a hug (Bee)",
            phrases: halves("blue")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Earl Sweatshirt, bitch, I don't want no haircut (Want no haircut)",
            phrases: halves("Earl Sweatshirt")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "This oop came from James, boy, I'm Clinton Capella (Don't talk)",
            phrases: halves("Clinton Capella")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "All of my chains white gold like I'm second place",
            phrases: halves("second place")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "My money different color, rainbow, I think that it's sus",
            phrases: halves("rainbow")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm just ridin' 'round and gettin' it, just like my name was Titty",
            phrases: halves("Titty")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Ain't stoppin' 'til I get a billy out it like Hannah Montana dad",
            phrases: halves("billy")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Do the beef like Linwood, lay two families flat (Ooh)",
            phrases: halves("Linwood")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "The foreign I parked is lower since I loved it, you gotta die for bands",
            phrases: halves("die")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Drop a hundred, everybody think I'm Wilt like Otto Potter",
            phrases: halves("hundred")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Drop a hundred, everybody think I'm Wilt like Otto Potter",
            phrases: halves("Otto Potter")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Man that Wock, fuckin' wit my back like Quasimodo",
            phrases: halves("Quasimodo")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Who shot me in my back? Naw, my outfit just Ricky",
            phrases: halves("Ricky")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "My stash is colored, I edible arrangement the money",
            phrases: halves("edible arrangement")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "He want no more drama, Mary J. Blige",
            phrases: halves("no more drama")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I wanna take you to France and kiss you in French (Moi, moi)",
            phrases: halves("moi")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Havin' these cups of this red dirt, they think it's from Alabama",
            phrases: halves("red dirt")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I want blue strips on all the paper when I get it",
            phrases: halves("blue strips")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I swear yo' bitch think I'm all that, like I'm Keenan, Kel",
            phrases: halves("all that")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm high just like the hills in Hollywood, but I'm not that bougie",
            phrases: halves("high")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "White horns on top of my head, it look like Satan, huh?",
            phrases: halves("white horns")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm off them drugs, I doubled up, I feel like Oscar Robertson (Woo)",
            phrases: halves("doubled up")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm a lil' pip, man, shit, I'm damn near sixteen",
            phrases: halves("pip")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I ball just like Lou Will, make it rain, chicken wing",
            phrases: halves("chicken wing")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Just gamed like thirty hoes, this a Nick Cannon, it's a wild out",
            phrases: halves("wild out")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Why you never around every time I need you? Paul George-in'",
            phrases: halves("Paul George")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm gettin' dizzy, I nap on the plane, went from MIA to the A back to MIA (MIA to the A back—)",
            phrases: halves("MIA")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Old hundreds and fifties on me tonight look like red beans and rice",
            phrases: halves("red beans and rice")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Show you so much white, you gon' think you watchin' Shameless",
            phrases: halves("Shameless")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "When I see haters I just tell 'em \"Hi\", I feel like Maino",
            phrases: halves("Maino")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm wrappin' up the beef like I just made a gyro",
            phrases: halves("beef")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Niggas act like thug life, til' they gotta go meet pac' for real",
            phrases: halves("thug life")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "She from the six one nine, Rey Mysterio (Let's go)",
            phrases: halves("Rey Mysterio")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Like it's prime and treat you like it's Optimus (Woah)",
            phrases: halves("Optimus")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Plus, I got gas like a Shell (Plus, I got gas like a Shell, okay)",
            phrases: halves("Shell")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Violation, boy, your money like Wee Man",
            phrases: halves("Wee Man")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Like Kells with the R so I hit with the remix",
            phrases: halves("Kells")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Know my diamonds like water, I'm Poseidon (Uh)",
            phrases: halves("Poseidon")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I been gettin' money, buildin' all my blocks up like they Tetris",
            phrases: halves("Tetris")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Can't fold the paper up, no origami",
            phrases: halves("origami")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Had to pull some strings like I play the harp",
            phrases: halves("harp")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Stay with a nerd just like Urkel, Jaleel",
            phrases: halves("nerd")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Armstrong, marathon when I'm on a bike like my name Neil (Let's go, let's go, let's go)",
            phrases: halves("Armstrong")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "If you want money, better Crawford like Cindy",
            phrases: halves("Crawford")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Cut that bitch off, Zoro (Offset)",
            phrases: halves("Zoro")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Brandon finessed on the beat, but I just did a city (Yeah)",
            phrases: halves("finessed")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "And I stay with the cash like a XO chain",
            phrases: halves("Cash")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "When I moonwalk, I don't need no twenties",
            phrases: halves("Moonwalk")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Okay, 'Port, but I'm not talking New' (Let's go)",
            phrases: halves("'Port")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Wait, countin' cheese, that's that feta (Yeah)",
            phrases: halves("feta")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I change my shoe like Mister Rogers (Huh?), copy that boy, no roger (What?)",
            phrases: halves("roger")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Dove bars, yeah, they choppin' that soap a lot",
            phrases: halves("Dove bars")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "One eye open, 'Luminati like Fetty Wap",
            phrases: halves("'Luminati")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "This not VLONE, this die 'lone (Die 'lone), get my Gosha from Dover",
            phrases: halves("die 'lone")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Forest, Forest, Forest, don't run ass boy (Don't run!)",
            phrases: halves("Forest")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Diamonds lay on my clothes like sequin",
            phrases: halves("sequin")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Water my wrist, say, I lay in the deep end",
            phrases: halves("deep end")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I feel like I am Stefan, came a long way, just was Urkel (Oogie Mane, he killed it)",
            phrases: halves("Stefan")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I need somebody just to vent to like the AC (AC)",
            phrases: halves("vent")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I am not Nick Cannon but they know I be wildin' out every time I pull out that drum",
            phrases: halves("wildin' out")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I'm high like a bird, man, but don't got no Lugz",
            phrases: halves("bird, man")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Yeah, ever since Clifford, yeah, Uzi been the big dog",
            phrases: halves("Clifford")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Drippin' in this Ragu, you know I got the big sauce",
            phrases: halves("Ragu")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Water on my neck, 3D like it's IMAX (Water)",
            phrases: halves("IMAX")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Oh, you Casper the ghost-writer and you ain't signed yet?",
            phrases: halves("Casper")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Speaking of cake, yeah my money from Hostess (Yeah)",
            phrases: halves("Hostess")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "I was talkin' to my little slime, that's a lil' lizard, call her Geico",
            phrases: halves("Geico")
        ))
        XCTAssertTrue(NounMentionWorth.keeps(
            "Pull up extra icy, I'm not playin' hockey (Bling, blaow)",
            phrases: halves("playin' hockey")
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
        XCTAssertEqual(apps.count, 66)
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
