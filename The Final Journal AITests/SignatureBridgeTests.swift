import XCTest
@testable import XJournal_AI

final class SignatureBridgeTests: XCTestCase {

    func testEyeRollTailIsUzi() {
        let tails = SignatureBridge.tails(in: "she made my eye roll")
        XCTAssertEqual(tails.map(\.insert), ["like Uzi"])
        XCTAssertEqual(tails.first?.aspectId, "eye-roll")
    }

    func testShrugOffersUziAndMike() {
        let spoken = SignatureBridge.tails(in: "I just shrugged it off").map(\.spoken)
        XCTAssertTrue(spoken.contains("Uzi"))
        XCTAssertTrue(spoken.contains("Mike"))
    }

    func testForeheadDiamondIsUziMark() {
        let hits = SignatureBridge.hits(in: "diamond in the middle of my forehead")
        XCTAssertEqual(hits.map(\.aspect.id), ["forehead-diamond"])
        XCTAssertEqual(hits.map(\.person.spoken), ["Uzi"])
    }

    func testLooseWordsStayEmpty() {
        XCTAssertTrue(SignatureBridge.hits(in: "diamond on my chain").isEmpty)
        XCTAssertTrue(SignatureBridge.hits(in: "roll a wood").isEmpty)
        XCTAssertTrue(SignatureBridge.hits(in: "AI").isEmpty)
        XCTAssertTrue(SignatureBridge.hits(in: "curry chicken").isEmpty)
        XCTAssertTrue(SignatureBridge.hits(in: "lean in the cup").isEmpty)
        XCTAssertTrue(SignatureBridge.hits(in: "ice on the rock").isEmpty)
        XCTAssertTrue(SignatureBridge.hits(in: "rub on my chest").isEmpty)
        XCTAssertTrue(SignatureBridge.hits(in: "jordans on my feet, bred toe").isEmpty)
    }

    func testNameAlreadyInTheLineGetsNoSecondTail() {
        XCTAssertTrue(SignatureBridge.tails(in: "she made my eye roll like Uzi").isEmpty)
        XCTAssertEqual(
            SignatureBridge.aspects(mentioningSpokenName: "she made my eye roll like Uzi").map(\.spoken),
            ["Uzi"]
        )
    }

    func testSongTitlePlaysAsTheSentence() {
        let tails = SignatureBridge.tails(in: "got her losing her mind")
        XCTAssertEqual(tails.map(\.insert), ["like PartyNextDoor"])
        XCTAssertEqual(tails.map(\.aspectId), ["lose-my-mind"])
        XCTAssertEqual(SignatureBridge.tails(in: "this was god's plan").map(\.spoken), ["Drake"])
        XCTAssertEqual(SignatureBridge.tails(in: "mask off").map(\.spoken), ["Future"])
        XCTAssertEqual(SignatureBridge.tails(in: "they not like us").map(\.spoken), ["Kendrick"])
        XCTAssertEqual(SignatureBridge.tails(in: "the world is yours").map(\.spoken), ["Nas"])
        XCTAssertEqual(SignatureBridge.tails(in: "jenny from the block").map(\.spoken), ["JLo"])
        XCTAssertEqual(SignatureBridge.tails(in: "hips don't lie").map(\.spoken), ["Shakira"])
        XCTAssertEqual(SignatureBridge.tails(in: "kill bill").map(\.spoken), ["SZA"])
        XCTAssertEqual(SignatureBridge.tails(in: "sorry bout that").map(\.spoken), ["Yeat"])
        XCTAssertEqual(SignatureBridge.tails(in: "playing games").map(\.spoken), ["Summer"])
        XCTAssertEqual(SignatureBridge.tails(in: "how we do").map(\.spoken), ["Game"])
        XCTAssertEqual(SignatureBridge.tails(in: "all i do is win").map(\.spoken), ["Khaled"])
        XCTAssertEqual(SignatureBridge.tails(in: "fly me to the moon").map(\.spoken), ["Sinatra"])
        XCTAssertEqual(SignatureBridge.tails(in: "hey ma").map(\.spoken), ["Cam'ron"])
        XCTAssertEqual(Set(SignatureBridge.tails(in: "hail mary").map(\.spoken)), Set(["Pac", "Rodgers"]))
        XCTAssertEqual(SignatureBridge.tails(in: "we the best").map(\.spoken), ["Khaled"])
        XCTAssertTrue(SignatureBridge.tails(in: "love sosa").isEmpty)
        XCTAssertTrue(SignatureBridge.aspects(mentioningSpokenName: "love sosa").map(\.spoken).contains("Keef"))
        XCTAssertTrue(SignatureBridge.tails(in: "chris brown under the influence").isEmpty)
        XCTAssertTrue(SignatureBridge.aspects(mentioningSpokenName: "drizzy").map(\.spoken).contains("Drake"))
    }

    func testVickDogFightIsSeparateFromTheScramble() {
        XCTAssertEqual(SignatureBridge.tails(in: "put the dogs to fight").map(\.spoken), ["Vick"])
        XCTAssertEqual(SignatureBridge.hits(in: "put the dogs to fight").map(\.aspect.id), ["dog-fight"])
        XCTAssertEqual(SignatureBridge.tails(in: "scramble to the sideline").map(\.spoken), ["Vick"])
        XCTAssertEqual(SignatureBridge.hits(in: "scramble to the sideline").map(\.aspect.id), ["scramble"])
    }

    func testExtendedUziIsTheGun() {
        XCTAssertTrue(SignatureBridge.weaponSense("extended uzi in the tuck"))
        XCTAssertTrue(SignatureBridge.hits(in: "extended uzi in the tuck").isEmpty)
    }

    func testHooperAndCelebPictures() {
        XCTAssertEqual(SignatureBridge.tails(in: "tongue out on the free throw").map(\.spoken), ["Mike"])
        XCTAssertEqual(SignatureBridge.tails(in: "fadeaway from the elbow").map(\.spoken), ["Kobe"])
        XCTAssertEqual(SignatureBridge.tails(in: "crossed him at half court").map(\.spoken), ["Iverson"])
        XCTAssertEqual(SignatureBridge.tails(in: "shimmy before the logo three").map(\.spoken), ["Steph"])
        XCTAssertEqual(SignatureBridge.tails(in: "moonwalk across the stage").map(\.spoken), ["Jackson"])
        XCTAssertEqual(SignatureBridge.tails(in: "face tat on the left side").map(\.spoken), ["Tyson"])
        XCTAssertEqual(SignatureBridge.tails(in: "eyebrow up").map(\.spoken), ["The Rock"])
        XCTAssertEqual(SignatureBridge.tails(in: "scramble to the sideline").map(\.spoken), ["Vick"])
    }

    func testNewSignaturePaths() {
        XCTAssertTrue(SignatureBridge.tails(in: "another one").isEmpty)
        XCTAssertEqual(SignatureBridge.tails(in: "if young metro don't trust you").map(\.spoken), ["Metro"])
        XCTAssertEqual(SignatureBridge.tails(in: "mustard on the beat").map(\.spoken), ["Mustard"])
        XCTAssertEqual(SignatureBridge.tails(in: "what what").map(\.spoken), ["Carti"])
        XCTAssertTrue(SignatureBridge.tails(in: "what").isEmpty)
        XCTAssertTrue(SignatureBridge.tails(in: "slime").isEmpty)
        XCTAssertTrue(SignatureBridge.tails(in: "juicy").isEmpty)
        XCTAssertTrue(SignatureBridge.tails(in: "who dat").isEmpty)
        XCTAssertEqual(SignatureBridge.tails(in: "burr").map(\.spoken), ["Guwop"])
        XCTAssertEqual(SignatureBridge.tails(in: "good kid mad city").map(\.spoken), ["Kendrick"])
        XCTAssertEqual(SignatureBridge.tails(in: "take care").map(\.spoken), ["Drake"])
        XCTAssertTrue(SignatureBridge.tails(in: "take care of her").isEmpty)
        XCTAssertEqual(Set(SignatureBridge.tails(in: "otf").map(\.spoken)), Set(["Durk", "Von"]))
        XCTAssertEqual(Set(SignatureBridge.tails(in: "dipset").map(\.spoken)), Set(["Capo", "Cam'ron", "Juelz"]))
        XCTAssertEqual(Set(SignatureBridge.tails(in: "bit his ear").map(\.spoken)), Set(["Tyson", "Holyfield"]))
        XCTAssertTrue(SignatureBridge.tails(in: "fancy").isEmpty)
        XCTAssertEqual(SignatureBridge.tails(in: "i'm so fancy").map(\.spoken), ["Iggy"])
        XCTAssertTrue(SignatureBridge.tails(in: "motivation").isEmpty)
        XCTAssertEqual(SignatureBridge.tails(in: "your motivation").map(\.spoken), ["Kelly"])
        XCTAssertTrue(SignatureBridge.tails(in: "freight train").isEmpty)
        XCTAssertEqual(SignatureBridge.tails(in: "shoe exploded").map(\.spoken), ["Zion"])
        XCTAssertTrue(SignatureBridge.tails(in: "the real deal").isEmpty)
        XCTAssertTrue(SignatureBridge.tails(in: "gunslinger").isEmpty)
        XCTAssertTrue(SignatureBridge.tails(in: "nameless").isEmpty)
        XCTAssertTrue(SignatureBridge.tails(in: "act up").isEmpty)
        XCTAssertTrue(SignatureBridge.tails(in: "i'm the one").isEmpty)
        XCTAssertEqual(SignatureBridge.tails(in: "yeah i'm the one").map(\.spoken), ["Khaled"])
        XCTAssertEqual(SignatureBridge.pictures(in: "uzi").map(\.insert), ["eye roll", "shrug", "forehead diamond"])
        XCTAssertTrue(SignatureBridge.tails(in: "uzi").isEmpty)
        XCTAssertTrue(SignatureBridge.pictures(in: "21 questions").isEmpty)
        XCTAssertEqual(
            SignatureBridge.completions(in: "got her losing her").map(\.insert),
            ["mind like PartyNextDoor"]
        )
        XCTAssertEqual(
            SignatureBridge.completions(in: "fly me to the").map(\.insert),
            ["moon like Sinatra"]
        )
        XCTAssertEqual(SignatureBridge.offers(in: "she made my eye roll").map(\.insert), ["like Uzi"])
        XCTAssertEqual(SignatureBridge.tails(in: "southside").map(\.spoken), [])
        XCTAssertEqual(SignatureBridge.tails(in: "southside on the track").map(\.spoken), ["Southside"])
        XCTAssertEqual(SignatureBridge.tails(in: "platinum wig").map(\.spoken), ["Andre"])
        XCTAssertEqual(SignatureBridge.tails(in: "in a kilt").map(\.spoken), ["Ye"])
        XCTAssertEqual(SignatureBridge.tails(in: "imma let you finish").map(\.spoken), ["Ye"])
        let earned = SignatureBridge.promptFragment(earnedBy: "she made my eye roll")
        XCTAssertTrue(earned.contains("Uzi: eye roll"))
        XCTAssertFalse(earned.contains("Kobe"))
        XCTAssertTrue(SignatureBridge.promptFragment(earnedBy: "the sun is out").contains("Do not add a name."))
        XCTAssertTrue(SignatureBridge.keepsDraft("she made my eye roll like Uzi"))
        XCTAssertFalse(SignatureBridge.keepsDraft("like Uzi"))
        XCTAssertFalse(SignatureBridge.keepsDraft("drake walked in"))
        XCTAssertFalse(SignatureBridge.keepsDraft("she made my eye roll like Uzi, referring to the stage"))
        XCTAssertFalse(SignatureBridge.keepsDraft("she made my eye roll like Uzi\nmoonwalk across the stage like Jackson"))
    }

    func testPromptFragmentListsGroupsAndHidesPrivateNotes() {
        let fragment = SignatureBridge.promptFragment()
        XCTAssertTrue(fragment.contains("Artists"))
        XCTAssertTrue(fragment.contains("Hoopers"))
        XCTAssertTrue(fragment.contains("Athletes"))
        XCTAssertTrue(fragment.contains("Celebs"))
        XCTAssertTrue(fragment.contains("Uzi: eye roll, shrug, forehead diamond"))
        XCTAssertTrue(fragment.contains("Kobe: fadeaway"))
        XCTAssertTrue(fragment.contains("Jackson: moonwalk, one glove"))
        XCTAssertFalse(fragment.contains("PRIVATE"))
        XCTAssertEqual(SignatureCatalog.all.count, 286)
        XCTAssertTrue(fragment.contains("we the best (catchphrase)"))
        XCTAssertTrue(fragment.contains("mustard on the beat (tag)"))
        XCTAssertTrue(fragment.contains("good kid mad city (album)"))
        XCTAssertTrue(fragment.contains("what what (adlib)"))
        XCTAssertTrue(fragment.contains("otf (crew)"))
        XCTAssertTrue(fragment.contains("shoe exploded (moment)"))
        XCTAssertTrue(fragment.contains("platinum wig (outfit)"))
        XCTAssertTrue(fragment.contains("lose my mind (song)"))
        XCTAssertTrue(fragment.contains("Vick: scramble, dog fight"))
        for tail in SignatureBridge.tails(in: "she made my eye roll") {
            XCTAssertFalse(tail.insert.contains("PRIVATE"))
            XCTAssertTrue(tail.insert.hasPrefix("like "))
        }
    }
}
