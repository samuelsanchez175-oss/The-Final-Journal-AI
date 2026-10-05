import Foundation

nonisolated enum SignatureKind: String, Equatable, Sendable {
    case mannerism, mark, performance, title
    case catchphrase, tag, adlib, album, crew, moment, outfit
}

nonisolated enum SignatureGroup: String, Equatable, Sendable {
    case artists, hoopers, athletes, celebs

    var title: String {
        switch self {
        case .artists: return "Artists"
        case .hoopers: return "Hoopers"
        case .athletes: return "Athletes"
        case .celebs: return "Celebs"
        }
    }
}

/// One public picture of a person. `privateNote` stays in the catalog.
nonisolated struct SignatureAspect: Equatable, Sendable, Identifiable {
    var id: String
    var kind: SignatureKind
    var label: String
    var phrases: [String]
    var privateNote: String
}

nonisolated struct PersonSignature: Equatable, Sendable, Identifiable {
    var id: String
    var spoken: String
    var aliases: [String]
    var group: SignatureGroup
    var aspects: [SignatureAspect]
}

nonisolated enum SignatureCatalog {
    static let all: [PersonSignature] = artists + hoopers + athletes + celebs

    /// Spoken name plus aliases for the person this noun chip pictures. Empty for objects.
    static func namePhrases(icon: String, spoken: String) -> [String] {
        let key = spoken.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let person = all.first(where: { candidate in
            if candidate.id == icon { return true }
            if candidate.spoken.compare(key, options: [.diacriticInsensitive, .caseInsensitive]) == .orderedSame {
                return true
            }
            return candidate.aliases.contains {
                $0.compare(key, options: [.diacriticInsensitive, .caseInsensitive]) == .orderedSame
            }
        }) else { return [] }
        return [person.spoken] + person.aliases
    }

    private static func aspect(
        _ id: String,
        _ kind: SignatureKind,
        _ label: String,
        _ phrases: [String],
        _ note: String
    ) -> SignatureAspect {
        SignatureAspect(id: id, kind: kind, label: label, phrases: phrases, privateNote: "PRIVATE " + note)
    }

    private static func person(
        _ id: String,
        _ spoken: String,
        _ aliases: [String],
        _ group: SignatureGroup,
        _ aspects: [SignatureAspect]
    ) -> PersonSignature {
        PersonSignature(id: id, spoken: spoken, aliases: aliases, group: group, aspects: aspects)
    }

    private static let artists: [PersonSignature] = [
        person("noun-artist-uzi", "Uzi", ["uzi", "lil uzi", "lil uzi vert"], .artists, [
            aspect("eye-roll", .mannerism, "eye roll", [
                "eye roll", "eyes roll", "rolled her eyes", "rolled his eyes", "rolled my eyes", "eye rolled", "eyes rolled",
            ], "Lil Uzi Vert rolls his eyes on stage."),
            aspect("shrug", .mannerism, "shrug", [
                "shrug", "shrugged", "shrugs", "shrugging",
            ], "Lil Uzi Vert shrugs his shoulders in performances."),
            aspect("forehead-diamond", .mark, "forehead diamond", [
                "forehead", "middle of my head", "middle of the head", "middle of my forehead", "on my forehead", "on the forehead",
            ], "Lil Uzi Vert wears a diamond on his forehead."),
        ]),
        person("noun-artist-wayne", "Wayne", ["wayne", "lil wayne", "weezy", "tunechi", "young tune"], .artists, [
            aspect("skateboard", .performance, "skateboard", [
                "skateboard", "skate board", "on a skateboard",
            ], "Lil Wayne rides a skateboard."),
            aspect("a-milli", .title, "a milli", [
                "a milli",
            ], "Lil Wayne song A Milli."),
            aspect("lollipop", .title, "lollipop", [
                "lollipop",
            ], "Lil Wayne song Lollipop."),
            aspect("six-foot", .title, "6 foot 7 foot", [
                "6 foot 7 foot", "six foot seven foot",
            ], "Lil Wayne song 6 Foot 7 Foot."),
            aspect("how-to-love", .title, "how to love", [
                "how to love",
            ], "Lil Wayne song How to Love."),
            aspect("mrs-officer", .title, "mrs officer", [
                "mrs officer", "mrs. officer",
            ], "Lil Wayne song Mrs. Officer."),
        ]),
        person("noun-artist-birdman", "Birdman", ["birdman", "stunna"], .artists, [
            aspect("hand-rub", .mannerism, "hand rub", [
                "hand rub", "rubbing his hands", "rubbed his hands", "rubbin his hands", "rubbin' his hands",
            ], "Birdman rubs his hands together."),
        ]),
        person("noun-artist-tupac", "Pac", ["tupac", "2pac", "pac", "makaveli"], .artists, [
            aspect("thug-life", .mark, "thug life", [
                "thug life", "thug life across",
            ], "Tupac had THUG LIFE tattooed across his stomach."),
            aspect("dear-mama", .title, "dear mama", [
                "dear mama",
            ], "Tupac song Dear Mama."),
            aspect("california-love", .title, "california love", [
                "california love",
            ], "Tupac song California Love."),
            aspect("keep-ya-head-up", .title, "keep ya head up", [
                "keep ya head up", "keep your head up",
            ], "Tupac song Keep Ya Head Up."),
            aspect("hail-mary", .title, "hail mary", [
                "hail mary",
            ], "Tupac song Hail Mary."),
            aspect("all-eyez", .title, "all eyez on me", [
                "all eyez on me", "all eyes on me",
            ], "Tupac song All Eyez on Me."),
            aspect("aint-mad", .title, "i ain't mad at cha", [
                "i ain't mad at cha", "i aint mad at cha", "i ain't mad at you",
            ], "Tupac song I Ain't Mad at Cha."),
        ]),
        person("noun-artist-biggie", "Biggie", ["biggie", "biggie smalls", "notorious b.i.g"], .artists, [
            aspect("coogi", .mark, "coogi", [
                "coogi", "coogi sweater",
            ], "The Notorious B.I.G. wore Coogi sweaters."),
            aspect("hypnotize", .title, "hypnotize", [
                "hypnotize",
            ], "Biggie song Hypnotize."),
            aspect("big-poppa", .title, "big poppa", [
                "big poppa",
            ], "Biggie song Big Poppa."),
            aspect("mo-money", .title, "mo money mo problems", [
                "mo money mo problems",
            ], "Biggie song Mo Money Mo Problems."),
            aspect("gimme-the-loot", .title, "gimme the loot", [
                "gimme the loot", "give me the loot",
            ], "Biggie song Gimme the Loot."),
            aspect("juicy", .title, "juicy", [
                "juicy",
            ], "Biggie song Juicy."),
        ]),
        person("noun-artist-50-cent", "50", ["50 cent", "fifty cent", "fifty"], .artists, [
            aspect("vest", .mark, "bulletproof vest", [
                "bulletproof vest", "bullet proof vest", "shot nine times",
            ], "50 Cent was shot nine times and wore the vest on the album cover."),
            aspect("in-da-club", .title, "in da club", [
                "in da club",
            ], "50 Cent song In Da Club."),
            aspect("21-questions", .title, "21 questions", [
                "21 questions", "twenty one questions",
            ], "50 Cent song 21 Questions."),
            aspect("many-men", .title, "many men", [
                "many men",
            ], "50 Cent song Many Men."),
            aspect("candy-shop", .title, "candy shop", [
                "candy shop",
            ], "50 Cent song Candy Shop."),
            aspect("hate-or-love", .title, "hate it or love it", [
                "hate it or love it",
            ], "50 Cent song Hate It or Love It."),
        ]),
        person("noun-artist-eminem", "Eminem", ["eminem", "slim shady", "shady", "marshall mathers"], .artists, [
            aspect("bleach-blonde", .mark, "bleach blonde", [
                "bleach blonde", "bleached blonde", "bleached his hair", "mom's spaghetti",
            ], "Eminem's bleach-blonde hair."),
            aspect("lose-yourself", .title, "lose yourself", [
                "lose yourself",
            ], "Eminem song Lose Yourself."),
            aspect("slim-shady", .title, "the real slim shady", [
                "the real slim shady", "real slim shady",
            ], "Eminem song The Real Slim Shady."),
            aspect("mockingbird", .title, "mockingbird", [
                "mockingbird",
            ], "Eminem song Mockingbird."),
            aspect("rap-god", .title, "rap god", [
                "rap god",
            ], "Eminem song Rap God."),
            aspect("love-the-way", .title, "love the way you lie", [
                "love the way you lie",
            ], "Eminem song Love the Way You Lie."),
            aspect("cleaning-closet", .title, "cleaning out my closet", [
                "cleaning out my closet",
            ], "Eminem song Cleaning Out My Closet."),
        ]),
        person("noun-celeb-dmx", "DMX", ["dmx", "dark man x"], .artists, [
            aspect("bark", .mannerism, "barking", [
                "started barking", "barking on the beat", "barked at the", "where the hood at",
            ], "DMX barks on records and prays on them."),
        ]),
        person("noun-artist-drake", "Drake", ["drake", "champagne papi", "drizzy"], .artists, [
            aspect("hotline", .title, "hotline bling", [
                "hotline bling", "hotline dance",
            ], "Drake song Hotline Bling."),
            aspect("gods-plan", .title, "god's plan", [
                "god's plan", "gods plan",
            ], "Drake song God's Plan."),
            aspect("in-my-feelings", .title, "in my feelings", [
                "in my feelings",
            ], "Drake song In My Feelings."),
            aspect("started-from-the-bottom", .title, "started from the bottom", [
                "started from the bottom",
            ], "Drake song Started from the Bottom."),
            aspect("hold-on", .title, "hold on we're going home", [
                "hold on we're going home", "hold on were going home",
            ], "Drake song Hold On, We're Going Home."),
            aspect("marvins-room", .title, "marvin's room", [
                "marvin's room", "marvins room",
            ], "Drake song Marvins Room."),
            aspect("one-dance", .title, "one dance", [
                "one dance",
            ], "Drake song One Dance."),
            aspect("nice-for-what", .title, "nice for what", [
                "nice for what",
            ], "Drake song Nice for What."),
            aspect("childs-play", .title, "child's play", [
                "child's play", "childs play",
            ], "Drake song Child's Play."),
            aspect("do-not-disturb", .title, "do not disturb", [
                "do not disturb",
            ], "Drake song Do Not Disturb."),
            aspect("take-care", .album, "take care", [
                "take care",
            ], "Drake album Take Care. take care of stays a normal sentence."),
            aspect("nothing-was-the-same", .album, "nothing was the same", [
                "nothing was the same",
            ], "Drake album Nothing Was the Same."),
            aspect("if-youre-reading", .album, "if you're reading this it's too late", [
                "if you're reading this it's too late", "if youre reading this its too late",
            ], "Drake album If You're Reading This It's Too Late."),
            aspect("certified-lover-boy", .album, "certified lover boy", [
                "certified lover boy",
            ], "Drake album Certified Lover Boy."),
        ]),
        person("noun-artist-kanye", "Ye", ["kanye", "kanye west", "ye", "yeezy", "yeezus"], .artists, [
            aspect("wired-jaw", .mark, "wired jaw", [
                "jaw wired", "wired jaw", "jaw shut", "sunday service",
            ], "Kanye West had his jaw wired after a car crash."),
            aspect("gold-digger", .title, "gold digger", [
                "gold digger",
            ], "Kanye West song Gold Digger."),
            aspect("jesus-walks", .title, "jesus walks", [
                "jesus walks",
            ], "Kanye West song Jesus Walks."),
            aspect("through-the-wire", .title, "through the wire", [
                "through the wire",
            ], "Kanye West song Through the Wire."),
            aspect("flashing-lights", .title, "flashing lights", [
                "flashing lights",
            ], "Kanye West song Flashing Lights."),
            aspect("runaway", .title, "runaway", [
                "runaway",
            ], "Kanye West song Runaway."),
            aspect("no-more-parties", .title, "no more parties in la", [
                "no more parties in la", "no more parties",
            ], "Kanye West song No More Parties in LA."),
            aspect("all-of-the-lights", .title, "all of the lights", [
                "all of the lights",
            ], "Kanye West song All of the Lights."),
            aspect("twisted-fantasy", .album, "dark twisted fantasy", [
                "dark twisted fantasy", "my beautiful dark twisted fantasy",
            ], "Kanye West album My Beautiful Dark Twisted Fantasy."),
            aspect("life-of-pablo", .album, "the life of pablo", [
                "the life of pablo", "life of pablo",
            ], "Kanye West album The Life of Pablo."),
            aspect("kilt", .outfit, "kilt", [
                "in a kilt", "wore a kilt",
            ], "Kanye West in a kilt."),
            aspect("let-you-finish", .moment, "imma let you finish", [
                "imma let you finish", "ima let you finish",
            ], "Kanye West at the VMAs, imma let you finish."),
        ]),
        person("noun-artist-gucci-mane", "Guwop", ["gucci mane", "guwop"], .artists, [
            aspect("ice-cream-tat", .mark, "ice cream tattoo", [
                "ice cream tattoo", "ice cream on his face", "ice cream cone on his face",
            ], "Gucci Mane has an ice cream cone tattooed on his face."),
            aspect("burr", .adlib, "burr", [
                "burr",
            ], "Gucci Mane's burr adlib."),
        ]),
        person("noun-artist-kodak", "Kodak", ["kodak", "kodak black"], .artists, [
            aspect("snaggletooth", .mark, "snaggletooth", [
                "snaggletooth", "snaggle tooth",
            ], "Kodak Black's snaggletooth."),
            aspect("tunnel-vision", .title, "tunnel vision", [
                "tunnel vision",
            ], "Kodak Black song Tunnel Vision."),
            aspect("super-gremlin", .title, "super gremlin", [
                "super gremlin",
            ], "Kodak Black song Super Gremlin."),
            aspect("roll-in-peace", .title, "roll in peace", [
                "roll in peace",
            ], "Kodak Black song Roll in Peace."),
        ]),
        person("noun-artist-juice-wrld", "Juice", ["juice wrld", "juice world", "juice"], .artists, [
            aspect("triple-nine", .mark, "999", [
                "999", "triple nines", "999 club",
            ], "Juice WRLD used 999."),
            aspect("lucid-dreams", .title, "lucid dreams", [
                "lucid dreams",
            ], "Juice WRLD song Lucid Dreams."),
            aspect("all-girls", .title, "all girls are the same", [
                "all girls are the same",
            ], "Juice WRLD song All Girls Are the Same."),
            aspect("wishing-well", .title, "wishing well", [
                "wishing well",
            ], "Juice WRLD song Wishing Well."),
        ]),
        person("noun-artist-nicki", "Nicki", ["nicki", "nicki minaj", "onika"], .artists, [
            aspect("pink-wig", .mark, "pink wig", [
                "pink wig", "the barbz",
            ], "Nicki Minaj's pink wig."),
            aspect("super-bass", .title, "super bass", [
                "super bass",
            ], "Nicki Minaj song Super Bass."),
            aspect("anaconda", .title, "anaconda", [
                "anaconda",
            ], "Nicki Minaj song Anaconda."),
            aspect("beez", .title, "beez in the trap", [
                "beez in the trap",
            ], "Nicki Minaj song Beez in the Trap."),
        ]),
        person("noun-artist-cardi-b", "Cardi", ["cardi", "cardi b", "bardi"], .artists, [
            aspect("okurr", .mannerism, "okurr", [
                "okurrr", "okurr",
            ], "Cardi B's okurrr."),
            aspect("bodak", .title, "bodak yellow", [
                "bodak yellow",
            ], "Cardi B song Bodak Yellow."),
            aspect("wap", .title, "wap", [
                "wap",
            ], "Cardi B song WAP."),
        ]),
        person("noun-celeb-andre-3000", "Andre", ["andre 3000", "andre", "3 stacks", "three stacks"], .artists, [
            aspect("flute", .performance, "the flute", [
                "playing the flute", "the flute", "outkast flute",
            ], "Andre 3000 plays the flute."),
            aspect("hey-ya", .title, "hey ya", [
                "hey ya",
            ], "Outkast song Hey Ya."),
            aspect("ms-jackson", .title, "ms jackson", [
                "ms jackson", "ms. jackson",
            ], "Outkast song Ms. Jackson."),
            aspect("so-fresh", .title, "so fresh so clean", [
                "so fresh so clean",
            ], "Outkast song So Fresh, So Clean."),
            aspect("the-way-you-move", .title, "the way you move", [
                "the way you move",
            ], "Outkast song The Way You Move."),
            aspect("wig", .outfit, "platinum wig", [
                "platinum wig", "outkast wig",
            ], "Andre 3000's wigs."),
        ]),
        person("noun-celeb-nelly", "Nelly", ["nelly"], .artists, [
            aspect("band-aid", .mark, "band-aid", [
                "band-aid", "bandaid", "band aid",
            ], "Nelly wore a band-aid on his cheek."),
            aspect("hot-in-herre", .title, "hot in herre", [
                "hot in herre", "hot in here",
            ], "Nelly song Hot in Herre."),
            aspect("dilemma", .title, "dilemma", [
                "dilemma",
            ], "Nelly song Dilemma."),
            aspect("ride-wit-me", .title, "ride wit me", [
                "ride wit me",
            ], "Nelly song Ride Wit Me."),
            aspect("country-grammar", .title, "country grammar", [
                "country grammar",
            ], "Nelly song Country Grammar."),
            aspect("grillz", .title, "grillz", [
                "grillz",
            ], "Nelly song Grillz."),
        ]),
        person("noun-celeb-soulja-boy", "Soulja", ["soulja", "soulja boy"], .artists, [
            aspect("crank", .performance, "crank that", [
                "crank that", "crank dat", "superman dance",
            ], "Soulja Boy's crank that dance."),
        ]),
        person("noun-artist-jayz", "Hov", ["jay z", "jay-z", "hov", "hova", "jigga", "young hov"], .artists, [
            aspect("shoulder-brush", .mannerism, "dirt off my shoulder", [
                "dirt off my shoulder", "dirt off your shoulder", "brushed the dirt off",
            ], "Jay-Z brushes dirt off his shoulder."),
            aspect("99-problems", .title, "99 problems", [
                "99 problems", "ninety nine problems", "ninety-nine problems",
            ], "Jay-Z song 99 Problems."),
            aspect("empire-state", .title, "empire state of mind", [
                "empire state of mind",
            ], "Jay-Z song Empire State of Mind."),
            aspect("hard-knock", .title, "hard knock life", [
                "hard knock life",
            ], "Jay-Z song Hard Knock Life."),
            aspect("big-pimpin", .title, "big pimpin", [
                "big pimpin", "big pimping",
            ], "Jay-Z song Big Pimpin."),
            aspect("niggas-in-paris", .title, "niggas in paris", [
                "niggas in paris",
            ], "Jay-Z song Niggas in Paris."),
            aspect("run-this-town", .title, "run this town", [
                "run this town",
            ], "Jay-Z song Run This Town."),
            aspect("song-cry", .title, "song cry", [
                "song cry",
            ], "Jay-Z song Song Cry."),
        ]),
        person("noun-celeb-suge", "Suge", ["suge", "suge knight"], .artists, [
            aspect("balcony", .performance, "off the balcony", [
                "hung him off the balcony", "dangled off the balcony", "hung him over the balcony",
            ], "Suge Knight is known for dangling a man off a balcony."),
        ]),
        person("noun-celeb-aaliyah", "Aaliyah", ["aaliyah"], .artists, [
            aspect("swoop", .mark, "side swoop", [
                "side swoop", "swoop bang", "hair over one eye",
            ], "Aaliyah's swoop bang over one eye."),
        ]),
        person("noun-celeb-beyonce", "Bey", ["beyonce", "beyoncé", "bey", "yonce"], .artists, [
            aspect("ring", .title, "put a ring on it", [
                "put a ring on it", "single ladies",
            ], "Beyoncé song Single Ladies."),
            aspect("crazy-in-love", .title, "crazy in love", [
                "crazy in love",
            ], "Beyoncé song Crazy in Love."),
            aspect("irreplaceable", .title, "irreplaceable", [
                "irreplaceable",
            ], "Beyoncé song Irreplaceable."),
            aspect("drunk-in-love", .title, "drunk in love", [
                "drunk in love",
            ], "Beyoncé song Drunk in Love."),
            aspect("love-on-top", .title, "love on top", [
                "love on top",
            ], "Beyoncé song Love on Top."),
            aspect("if-i-were-a-boy", .title, "if i were a boy", [
                "if i were a boy",
            ], "Beyoncé song If I Were a Boy."),
        ]),
        person("noun-celeb-rihanna", "Rihanna", ["rihanna", "riri"], .artists, [
            aspect("ella", .title, "ella ella", [
                "ella ella",
            ], "Rihanna song Umbrella."),
            aspect("bbhmm", .title, "bitch better have my money", [
                "bitch better have my money",
            ], "Rihanna song Bitch Better Have My Money."),
            aspect("needed-me", .title, "needed me", [
                "needed me",
            ], "Rihanna song Needed Me."),
            aspect("love-on-the-brain", .title, "love on the brain", [
                "love on the brain",
            ], "Rihanna song Love on the Brain."),
            aspect("kiss-it-better", .title, "kiss it better", [
                "kiss it better",
            ], "Rihanna song Kiss It Better."),
            aspect("we-found-love", .title, "we found love", [
                "we found love",
            ], "Rihanna song We Found Love."),
            aspect("pour-it-up", .title, "pour it up", [
                "pour it up",
            ], "Rihanna song Pour It Up."),
        ]),
        person("noun-prod-pharrell", "Pharrell", ["pharrell"], .artists, [
            aspect("big-hat", .outfit, "oversized hat", [
                "oversized hat", "oversized brown hat", "big hat at the grammys",
            ], "Pharrell's oversized hat."),
        ]),
        person("noun-celeb-akon", "Akon", ["akon", "konvict"], .artists, [
            aspect("konvict", .mark, "konvict", [
                "konvict",
            ], "Akon's Konvict brand."),
        ]),
        person("noun-celeb-big-boi", "Big Boi", ["big boi"], .artists, [
            aspect("speakers", .performance, "speakerboxxx", [
                "speakerboxxx", "speakerbox",
            ], "Big Boi's Speakerboxxx."),
            aspect("so-fresh", .title, "so fresh so clean", [
                "so fresh so clean",
            ], "Outkast song So Fresh, So Clean."),
        ]),
        person("noun-celeb-boosie", "Boosie", ["boosie", "lil boosie"], .artists, [
            aspect("bad-azz", .performance, "bad azz", [
                "bad azz", "wipe me down",
            ], "Boosie's bad azz."),
        ]),
        person("noun-artist-carti", "Carti", ["carti", "playboi carti", "vamp"], .artists, [
            aspect("baby-voice", .mannerism, "baby voice", [
                "baby voice", "vamp in the",
            ], "Playboi Carti's baby voice."),
            aspect("magnolia", .title, "magnolia", [
                "magnolia",
            ], "Playboi Carti song Magnolia."),
            aspect("miss-the-rage", .title, "miss the rage", [
                "miss the rage",
            ], "Playboi Carti song Miss the Rage."),
            aspect("whole-lotta-red", .album, "whole lotta red", [
                "whole lotta red",
            ], "Playboi Carti album Whole Lotta Red."),
            aspect("what-what", .adlib, "what what", [
                "what what",
            ], "Playboi Carti's what adlib. Bare what stays off."),
            aspect("slatt", .adlib, "slatt", [
                "slatt",
            ], "Playboi Carti's slatt adlib."),
        ]),
        person("noun-artist-sosa", "Keef", ["chief keef", "keef", "sosa"], .artists, [
            aspect("faneto", .title, "faneto", [
                "faneto", "finally rich",
            ], "Chief Keef song Faneto."),
            aspect("love-sosa", .title, "love sosa", [
                "love sosa",
            ], "Chief Keef song Love Sosa."),
        ]),
        person("noun-artist-durk", "Durk", ["durk", "lil durk"], .artists, [
            aspect("otf", .crew, "otf", [
                "otf", "only the family",
            ], "Lil Durk's OTF. The same crew picture also belongs to Von."),
            aspect("voice-of-the-heroes", .album, "voice of the heroes", [
                "voice of the heroes",
            ], "Lil Durk and King Von album The Voice of the Heroes."),
        ]),
        person("noun-artist-king-von", "Von", ["king von", "von"], .artists, [
            aspect("otf", .crew, "otf", [
                "otf", "only the family",
            ], "King Von's OTF. The same crew picture also belongs to Durk."),
            aspect("voice-of-the-heroes", .album, "voice of the heroes", [
                "voice of the heroes",
            ], "King Von and Lil Durk album The Voice of the Heroes."),
            aspect("crazy-story", .performance, "crazy story", [
                "crazy story",
            ], "King Von's Crazy Story series."),
        ]),
        person("noun-artist-future", "Future", ["future hendrix", "pluto"], .artists, [
            aspect("dirty-sprite", .title, "dirty sprite", [
                "dirty sprite",
            ], "Future song Dirty Sprite."),
            aspect("mask-off", .title, "mask off", [
                "mask off",
            ], "Future song Mask Off."),
            aspect("life-is-good", .title, "life is good", [
                "life is good",
            ], "Future song Life Is Good."),
            aspect("march-madness", .title, "march madness", [
                "march madness",
            ], "Future song March Madness."),
            aspect("ds2", .album, "dirty sprite 2", [
                "dirty sprite 2", "ds2",
            ], "Future album DS2."),
        ]),
        person("noun-artist-gunna", "Gunna", ["gunna", "wunna"], .artists, [
            aspect("pushin-p", .title, "pushin p", [
                "pushin p", "pushing p", "pushin' p",
            ], "Gunna song Pushin P."),
            aspect("drip-too-hard", .title, "drip too hard", [
                "drip too hard",
            ], "Gunna song Drip Too Hard."),
            aspect("banking-on-me", .title, "banking on me", [
                "banking on me",
            ], "Gunna song Banking on Me."),
            aspect("baby-birkin", .title, "baby birkin", [
                "baby birkin",
            ], "Gunna song Baby Birkin."),
        ]),
        person("noun-artist-lil-yachty", "Yachty", ["yachty", "lil yachty"], .artists, [
            aspect("bubblegum", .mark, "bubblegum hair", [
                "bubblegum hair", "bubblegum dreads",
            ], "Lil Yachty's bubblegum hair."),
        ]),
        person("noun-artist-megan", "Megan", ["megan", "megan thee stallion", "tina snow"], .artists, [
            aspect("hot-girl", .performance, "hot girl", [
                "real hot girl", "hot girl summer",
            ], "Megan Thee Stallion's hot girl."),
            aspect("big-ole-freak", .title, "big ole freak", [
                "big ole freak",
            ], "Megan Thee Stallion song Big Ole Freak."),
            aspect("captain-hook", .title, "captain hook", [
                "captain hook",
            ], "Megan Thee Stallion song Captain Hook."),
        ]),
        person("noun-celeb-method-man", "Meth", ["method man", "johnny blaze", "tical"], .artists, [
            aspect("ticallion", .performance, "ticallion", [
                "ticallion", "ticalion", "john blaz", "johnny blaze",
            ], "Method Man's ticallion stallion."),
        ]),
        person("noun-prod-metro", "Metro", ["metro", "metro boomin"], .artists, [
            aspect("tag", .tag, "if young metro don't trust you", [
                "if young metro don't trust you", "if young metro dont trust you",
            ], "Metro Boomin's producer tag."),
            aspect("boomin-tag", .tag, "boomin want some more", [
                "boomin want some more",
            ], "Metro Boomin's other producer tag."),
        ]),
        person("noun-artist-migos", "Migos", ["migos"], .artists, [
            aspect("dab", .performance, "the dab", [
                "dabbed", "hit the dab", "the dab",
            ], "Migos and the dab."),
            aspect("bad-and-boujee", .title, "bad and boujee", [
                "bad and boujee", "bad and bougie",
            ], "Migos song Bad and Boujee."),
            aspect("walk-it", .title, "walk it like i talk it", [
                "walk it like i talk it",
            ], "Migos song Walk It Like I Talk It."),
            aspect("stir-fry", .title, "stir fry", [
                "stir fry",
            ], "Migos song Stir Fry."),
        ]),
        person("noun-celeb-odb", "ODB", ["odb", "ol dirty", "ol' dirty", "dirt mcgirt"], .artists, [
            aspect("got-your-money", .performance, "got your money", [
                "got your money", "shimmy ya",
            ], "Ol' Dirty Bastard's got your money."),
        ]),
        person("noun-artist-offset", "Offset", ["offset"], .artists, [
            aspect("flair-drip", .mark, "ric flair drip", [
                "ric flair drip",
            ], "Offset's Ric Flair drip."),
        ]),
        person("noun-artist-pop-smoke", "Pop", ["pop smoke"], .artists, [
            aspect("woo-back", .mannerism, "woo back", [
                "woo back",
            ], "Pop Smoke's woo back."),
        ]),
        person("noun-artist-quavo", "Quavo", ["quavo", "huncho"], .artists, [
            aspect("huncho", .performance, "huncho", [
                "huncho",
            ], "Quavo's huncho."),
        ]),
        person("noun-celeb-rakim", "Rakim", ["rakim"], .artists, [
            aspect("paid-in-full", .performance, "paid in full", [
                "paid in full",
            ], "Rakim and Paid in Full."),
        ]),
        person("noun-celeb-slick-rick", "Rick", ["slick rick", "ricky d", "the ruler"], .artists, [
            aspect("eye-patch", .mark, "eye patch", [
                "eye patch", "children's story", "childrens story",
            ], "Slick Rick's eye patch."),
        ]),
        person("noun-artist-takeoff", "Takeoff", ["takeoff", "captain kirk"], .artists, [
            aspect("captain", .performance, "captain kirk", [
                "captain kirk",
            ], "Takeoff's Captain Kirk nickname."),
        ]),
        person("noun-artist-thugger", "Thug", ["thugger", "young thug", "jeffrey", "jeffery"], .artists, [
            aspect("jeffrey-dress", .outfit, "jeffrey dress", [
                "dress on the cover", "jeffrey cover", "wore a dress on the",
            ], "Young Thug wore a dress on the Jeffrey cover."),
            aspect("slime", .adlib, "slime", [
                "slime",
            ], "Young Thug's slime adlib."),
        ]),
        person("noun-celeb-doja", "Doja", ["doja", "doja cat"], .artists, [
            aspect("paint-town", .title, "paint the town red", [
                "paint the town red",
            ], "Doja Cat song Paint the Town Red."),
            aspect("kiss-me-more", .title, "kiss me more", [
                "kiss me more",
            ], "Doja Cat song Kiss Me More."),
            aspect("agora-hills", .title, "agora hills", [
                "agora hills",
            ], "Doja Cat song Agora Hills."),
        ]),
        person("noun-celeb-pimp-c", "Pimp C", ["pimp c", "sweet jones"], .artists, [
            aspect("sweet-jones", .performance, "sweet jones", [
                "sweet jones",
            ], "Pimp C, Sweet Jones."),
        ]),
        person("noun-artist-latto", "Latto", ["latto", "mulatto"], .artists, [
            aspect("big-energy", .title, "big energy", [
                "big energy",
            ], "Latto song Big Energy."),
            aspect("put-it-on-da-floor", .title, "put it on da floor", [
                "put it on da floor",
            ], "Latto song Put It on da Floor."),
        ]),
        person("noun-celeb-pnd", "PartyNextDoor", ["partynextdoor", "party next door", "pnd", "jahron"], .artists, [
            aspect("lose-my-mind", .title, "lose my mind", [
                "lose my mind", "losing her mind", "losing his mind", "losing my mind",
                "lost her mind", "lost his mind", "lost my mind", "lose her mind", "lose his mind",
            ], "PartyNextDoor song Lose My Mind."),
            aspect("break-from-toronto", .title, "break from toronto", [
                "break from toronto",
            ], "PartyNextDoor song Break from Toronto."),
            aspect("come-and-see-me", .title, "come and see me", [
                "come and see me",
            ], "PartyNextDoor song Come and See Me."),
            aspect("sex-on-the-beach", .title, "sex on the beach", [
                "sex on the beach",
            ], "PartyNextDoor song Sex on the Beach."),
        ]),
        person("noun-artist-kendrick", "Kendrick", ["kendrick", "kendrick lamar", "kdot", "kung fu kenny"], .artists, [
            aspect("not-like-us", .title, "not like us", [
                "not like us",
            ], "Kendrick Lamar song Not Like Us."),
            aspect("swimming-pools", .title, "swimming pools", [
                "swimming pools",
            ], "Kendrick Lamar song Swimming Pools."),
            aspect("money-trees", .title, "money trees", [
                "money trees",
            ], "Kendrick Lamar song Money Trees."),
            aspect("dont-kill-my-vibe", .title, "don't kill my vibe", [
                "don't kill my vibe", "dont kill my vibe", "bitch don't kill my vibe",
            ], "Kendrick Lamar song Bitch, Don't Kill My Vibe."),
            aspect("king-kunta", .title, "king kunta", [
                "king kunta",
            ], "Kendrick Lamar song King Kunta."),
            aspect("poetic-justice", .title, "poetic justice", [
                "poetic justice",
            ], "Kendrick Lamar song Poetic Justice."),
            aspect("count-me-out", .title, "count me out", [
                "count me out",
            ], "Kendrick Lamar song Count Me Out."),
            aspect("gkmc", .album, "good kid mad city", [
                "good kid mad city", "good kid maad city",
            ], "Kendrick Lamar album good kid, m.A.A.d city."),
            aspect("tpab", .album, "to pimp a butterfly", [
                "to pimp a butterfly",
            ], "Kendrick Lamar album To Pimp a Butterfly."),
            aspect("mr-morale", .album, "mr morale", [
                "mr morale",
            ], "Kendrick Lamar album Mr. Morale & the Big Steppers."),
        ]),
        person("noun-artist-j-cole", "Cole", ["j cole", "j. cole", "cole", "cole world"], .artists, [
            aspect("middle-child", .title, "middle child", [
                "middle child",
            ], "J. Cole song Middle Child."),
            aspect("no-role-modelz", .title, "no role modelz", [
                "no role modelz", "no role models",
            ], "J. Cole song No Role Modelz."),
            aspect("power-trip", .title, "power trip", [
                "power trip",
            ], "J. Cole song Power Trip."),
            aspect("crooked-smile", .title, "crooked smile", [
                "crooked smile",
            ], "J. Cole song Crooked Smile."),
            aspect("wet-dreamz", .title, "wet dreamz", [
                "wet dreamz", "wet dreams",
            ], "J. Cole song Wet Dreamz."),
            aspect("foldin-clothes", .title, "foldin clothes", [
                "foldin clothes", "folding clothes",
            ], "J. Cole song Foldin Clothes."),
            aspect("love-yourz", .title, "love yourz", [
                "love yourz", "love yours",
            ], "J. Cole song Love Yourz."),
            aspect("forest-hills", .album, "forest hills drive", [
                "forest hills drive", "2014 forest hills drive",
            ], "J. Cole album 2014 Forest Hills Drive."),
        ]),
        person("noun-artist-travis", "Travis", ["travis scott", "travis", "la flame"], .artists, [
            aspect("sicko-mode", .title, "sicko mode", [
                "sicko mode",
            ], "Travis Scott song Sicko Mode."),
            aspect("goosebumps", .title, "goosebumps", [
                "goosebumps",
            ], "Travis Scott song Goosebumps."),
            aspect("highest", .title, "highest in the room", [
                "highest in the room",
            ], "Travis Scott song Highest in the Room."),
            aspect("butterfly-effect", .title, "butterfly effect", [
                "butterfly effect",
            ], "Travis Scott song Butterfly Effect."),
            aspect("antidote", .title, "antidote", [
                "antidote",
            ], "Travis Scott song Antidote."),
            aspect("astroworld", .album, "astroworld", [
                "astroworld",
            ], "Travis Scott album Astroworld."),
        ]),
        person("noun-artist-21", "21", ["21 savage", "21"], .artists, [
            aspect("bank-account", .title, "bank account", [
                "bank account",
            ], "21 Savage song Bank Account."),
            aspect("red-opps", .title, "red opps", [
                "red opps",
            ], "21 Savage song Red Opps."),
            aspect("no-heart", .title, "no heart", [
                "no heart",
            ], "21 Savage song No Heart."),
        ]),
        person("noun-celeb-bryson-tiller", "Bryson", ["bryson", "bryson tiller"], .artists, [
            aspect("right-my-wrongs", .title, "right my wrongs", [
                "right my wrongs",
            ], "Bryson Tiller song Right My Wrongs."),
        ]),
        person("noun-artist-nas", "Nas", ["nas", "nasty nas", "nasir"], .artists, [
            aspect("world-is-yours", .title, "the world is yours", ["the world is yours"], "Nas song The World Is Yours."),
            aspect("if-i-ruled", .title, "if i ruled the world", ["if i ruled the world"], "Nas song If I Ruled the World."),
            aspect("ny-state", .title, "ny state of mind", ["ny state of mind", "new york state of mind"], "Nas song N.Y. State of Mind."),
            aspect("aint-hard", .title, "it ain't hard to tell", ["it ain't hard to tell", "it aint hard to tell"], "Nas song It Ain't Hard to Tell."),
            aspect("one-mic", .title, "one mic", ["one mic"], "Nas song One Mic."),
            aspect("made-you-look", .title, "made you look", ["made you look"], "Nas song Made You Look."),
            aspect("illmatic", .album, "illmatic", ["illmatic"], "Nas album Illmatic."),
        ]),
        person("noun-artist-nipsey", "Nipsey", ["nipsey", "nipsey hussle"], .artists, [
            aspect("grinding", .title, "grinding all my life", ["grinding all my life"], "Nipsey Hussle song Grinding All My Life."),
            aspect("last-time-checcd", .title, "last time that i checc'd", ["last time that i checc'd", "last time that i checced"], "Nipsey Hussle song Last Time That I Checc'd."),
        ]),
        person("noun-artist-lil-baby", "Lil Baby", ["lil baby"], .artists, [
            aspect("emotionally-scarred", .title, "emotionally scarred", ["emotionally scarred"], "Lil Baby song Emotionally Scarred."),
            aspect("bigger-picture", .title, "the bigger picture", ["the bigger picture"], "Lil Baby song The Bigger Picture."),
            aspect("sum-2-prove", .title, "sum 2 prove", ["sum 2 prove"], "Lil Baby song Sum 2 Prove."),
        ]),
        person("noun-artist-youngboy", "YoungBoy", ["youngboy", "nba youngboy", "yb"], .artists, [
            aspect("lonely-child", .title, "lonely child", ["lonely child"], "NBA YoungBoy song Lonely Child."),
            aspect("outside-today", .title, "outside today", ["outside today"], "NBA YoungBoy song Outside Today."),
            aspect("through-the-storm", .title, "through the storm", ["through the storm"], "NBA YoungBoy song Through the Storm."),
            aspect("who-they-say", .title, "i am who they say i am", ["i am who they say i am"], "NBA YoungBoy song I Am Who They Say I Am."),
        ]),
        person("noun-celeb-ludacris", "Luda", ["ludacris", "luda"], .artists, [
            aspect("fantasy", .title, "what's your fantasy", ["what's your fantasy", "whats your fantasy"], "Ludacris song What's Your Fantasy."),
            aspect("area-codes", .title, "area codes", ["area codes"], "Ludacris song Area Codes."),
            aspect("splash", .title, "splash waterfalls", ["splash waterfalls"], "Ludacris song Splash Waterfalls."),
            aspect("my-chick-bad", .title, "my chick bad", ["my chick bad"], "Ludacris song My Chick Bad."),
            aspect("move-bitch", .title, "move bitch", ["move bitch"], "Ludacris song Move Bitch."),
        ]),
        person("noun-celeb-lil-jon", "Lil Jon", ["lil jon"], .artists, [
            aspect("get-low", .title, "get low", ["get low"], "Lil Jon song Get Low."),
            aspect("turn-down", .title, "turn down for what", ["turn down for what"], "Lil Jon song Turn Down for What."),
            aspect("snap-yo-fingers", .title, "snap yo fingers", ["snap yo fingers"], "Lil Jon song Snap Yo Fingers."),
            aspect("lovers-and-friends", .title, "lovers and friends", ["lovers and friends"], "Lil Jon song Lovers and Friends."),
        ]),
        person("noun-celeb-busta", "Busta", ["busta", "busta rhymes"], .artists, [
            aspect("hands-where", .title, "put your hands where my eyes can see", ["put your hands where my eyes can see"], "Busta Rhymes song Put Your Hands Where My Eyes Could See."),
            aspect("break-ya-neck", .title, "break ya neck", ["break ya neck", "break your neck"], "Busta Rhymes song Break Ya Neck."),
            aspect("courvoisier", .title, "pass the courvoisier", ["pass the courvoisier"], "Busta Rhymes song Pass the Courvoisier."),
            aspect("woo-hah", .title, "woo hah", ["woo hah", "woo-hah"], "Busta Rhymes song Woo Hah!! Got You All in Check."),
        ]),
        person("noun-celeb-lil-kim", "Lil Kim", ["lil kim", "queen bee"], .artists, [
            aspect("crush-on-you", .title, "crush on you", ["crush on you"], "Lil Kim song Crush on You."),
            aspect("magic-stick", .title, "magic stick", ["magic stick"], "Lil Kim song Magic Stick."),
            aspect("how-many-licks", .title, "how many licks", ["how many licks"], "Lil Kim song How Many Licks."),
            aspect("not-tonight", .title, "not tonight", ["not tonight"], "Lil Kim song Not Tonight."),
            aspect("the-jump-off", .title, "the jump off", ["the jump off"], "Lil Kim song The Jump Off."),
        ]),
        person("noun-celeb-usher", "Usher", ["usher"], .artists, [
            aspect("u-got-it-bad", .title, "u got it bad", ["u got it bad", "you got it bad"], "Usher song U Got It Bad."),
            aspect("u-remind-me", .title, "u remind me", ["u remind me", "you remind me"], "Usher song U Remind Me."),
            aspect("love-in-this-club", .title, "love in this club", ["love in this club"], "Usher song Love in This Club."),
            aspect("there-goes-my-baby", .title, "there goes my baby", ["there goes my baby"], "Usher song There Goes My Baby."),
            aspect("my-boo", .title, "my boo", ["my boo"], "Usher song My Boo."),
        ]),
        person("noun-celeb-mary-j", "Mary", ["mary j", "mary j blige"], .artists, [
            aspect("no-more-drama", .title, "no more drama", ["no more drama"], "Mary J. Blige song No More Drama."),
            aspect("be-without-you", .title, "be without you", ["be without you"], "Mary J. Blige song Be Without You."),
            aspect("family-affair", .title, "family affair", ["family affair"], "Mary J. Blige song Family Affair."),
            aspect("not-gon-cry", .title, "not gon cry", ["not gon cry", "not gonna cry"], "Mary J. Blige song Not Gon' Cry."),
        ]),
        person("noun-celeb-mariah", "Mariah", ["mariah", "mariah carey", "mimi"], .artists, [
            aspect("always-be-my-baby", .title, "always be my baby", ["always be my baby"], "Mariah Carey song Always Be My Baby."),
            aspect("we-belong-together", .title, "we belong together", ["we belong together"], "Mariah Carey song We Belong Together."),
            aspect("touch-my-body", .title, "touch my body", ["touch my body"], "Mariah Carey song Touch My Body."),
            aspect("all-i-want", .title, "all i want for christmas", ["all i want for christmas"], "Mariah Carey song All I Want for Christmas Is You."),
            aspect("vision-of-love", .title, "vision of love", ["vision of love"], "Mariah Carey song Vision of Love."),
        ]),
        person("noun-celeb-whitney", "Whitney", ["whitney", "whitney houston", "nippy"], .artists, [
            aspect("always-love-you", .title, "i will always love you", ["i will always love you"], "Whitney Houston song I Will Always Love You."),
            aspect("dance-with-somebody", .title, "i wanna dance with somebody", ["i wanna dance with somebody", "i want to dance with somebody"], "Whitney Houston song I Wanna Dance with Somebody."),
            aspect("greatest-love", .title, "greatest love of all", ["greatest love of all"], "Whitney Houston song Greatest Love of All."),
            aspect("i-have-nothing", .title, "i have nothing", ["i have nothing"], "Whitney Houston song I Have Nothing."),
            aspect("how-will-i-know", .title, "how will i know", ["how will i know"], "Whitney Houston song How Will I Know."),
        ]),
        person("noun-celeb-bob-marley", "Marley", ["bob marley", "marley"], .artists, [
            aspect("no-woman", .title, "no woman no cry", ["no woman no cry"], "Bob Marley song No Woman, No Cry."),
            aspect("three-little-birds", .title, "three little birds", ["three little birds"], "Bob Marley song Three Little Birds."),
            aspect("redemption-song", .title, "redemption song", ["redemption song"], "Bob Marley song Redemption Song."),
            aspect("buffalo-soldier", .title, "buffalo soldier", ["buffalo soldier"], "Bob Marley song Buffalo Soldier."),
            aspect("get-up-stand-up", .title, "get up stand up", ["get up stand up"], "Bob Marley song Get Up, Stand Up."),
            aspect("is-this-love", .title, "is this love", ["is this love"], "Bob Marley song Is This Love."),
        ]),
        person("noun-celeb-lauryn", "Lauryn", ["lauryn", "lauryn hill", "l boogie"], .artists, [
            aspect("killing-me-softly", .title, "killing me softly", ["killing me softly"], "Fugees song Killing Me Softly."),
            aspect("ready-or-not", .title, "ready or not", ["ready or not"], "Fugees song Ready or Not."),
            aspect("doo-wop", .title, "doo wop", ["doo wop", "that thing"], "Lauryn Hill song Doo Wop (That Thing)."),
            aspect("ex-factor", .title, "ex-factor", ["ex-factor", "ex factor"], "Lauryn Hill song Ex-Factor."),
            aspect("lost-ones", .title, "lost ones", ["lost ones"], "Lauryn Hill song Lost Ones."),
        ]),
        person("noun-celeb-erykah", "Erykah", ["erykah", "erykah badu", "badu"], .artists, [
            aspect("bag-lady", .title, "bag lady", ["bag lady"], "Erykah Badu song Bag Lady."),
            aspect("tyrone", .title, "tyrone", ["tyrone"], "Erykah Badu song Tyrone."),
            aspect("next-lifetime", .title, "next lifetime", ["next lifetime"], "Erykah Badu song Next Lifetime."),
            aspect("appletree", .title, "appletree", ["appletree"], "Erykah Badu song Appletree."),
            aspect("window-seat", .title, "window seat", ["window seat"], "Erykah Badu song Window Seat."),
        ]),
        person("noun-celeb-sade", "Sade", ["sade"], .artists, [
            aspect("smooth-operator", .title, "smooth operator", ["smooth operator"], "Sade song Smooth Operator."),
            aspect("no-ordinary-love", .title, "no ordinary love", ["no ordinary love"], "Sade song No Ordinary Love."),
            aspect("sweetest-taboo", .title, "the sweetest taboo", ["the sweetest taboo", "sweetest taboo"], "Sade song The Sweetest Taboo."),
            aspect("kiss-of-life", .title, "kiss of life", ["kiss of life"], "Sade song Kiss of Life."),
            aspect("soldier-of-love", .title, "soldier of love", ["soldier of love"], "Sade song Soldier of Love."),
        ]),
        person("noun-celeb-alicia", "Alicia", ["alicia", "alicia keys"], .artists, [
            aspect("if-i-aint-got-you", .title, "if i ain't got you", ["if i ain't got you", "if i aint got you"], "Alicia Keys song If I Ain't Got You."),
            aspect("dont-know-my-name", .title, "you don't know my name", ["you don't know my name", "you dont know my name"], "Alicia Keys song You Don't Know My Name."),
            aspect("womans-worth", .title, "a woman's worth", ["a woman's worth", "a womans worth"], "Alicia Keys song A Woman's Worth."),
            aspect("girl-on-fire", .title, "girl on fire", ["girl on fire"], "Alicia Keys song Girl on Fire."),
            aspect("fallin", .title, "fallin", ["fallin", "fallin'"], "Alicia Keys song Fallin'."),
        ]),
        person("noun-celeb-john-legend", "Legend", ["john legend"], .artists, [
            aspect("all-of-me", .title, "all of me", ["all of me"], "John Legend song All of Me."),
            aspect("ordinary-people", .title, "ordinary people", ["ordinary people"], "John Legend song Ordinary People."),
            aspect("save-room", .title, "save room", ["save room"], "John Legend song Save Room."),
        ]),
        person("noun-celeb-jhene", "Jhene", ["jhene", "jhene aiko"], .artists, [
            aspect("bed-peace", .title, "bed peace", ["bed peace"], "Jhené Aiko song Bed Peace."),
            aspect("the-worst", .title, "the worst", ["the worst"], "Jhené Aiko song The Worst."),
            aspect("while-were-young", .title, "while we're young", ["while we're young", "while were young"], "Jhené Aiko song While We're Young."),
        ]),
        person("noun-celeb-kehlani", "Kehlani", ["kehlani"], .artists, [
            aspect("nights-like-this", .title, "nights like this", ["nights like this"], "Kehlani song Nights Like This."),
            aspect("distraction", .title, "distraction", ["distraction"], "Kehlani song Distraction."),
        ]),
        person("noun-celeb-trey-songz", "Trey", ["trey songz", "trey"], .artists, [
            aspect("neighbors-know", .title, "neighbors know my name", ["neighbors know my name"], "Trey Songz song Neighbors Know My Name."),
            aspect("bottoms-up", .title, "bottoms up", ["bottoms up"], "Trey Songz song Bottoms Up."),
            aspect("cant-help-but-wait", .title, "can't help but wait", ["can't help but wait", "cant help but wait"], "Trey Songz song Can't Help but Wait."),
            aspect("say-ahh", .title, "say ahh", ["say ahh", "say ah"], "Trey Songz song Say Aah."),
        ]),
        person("noun-celeb-jeremih", "Jeremih", ["jeremih"], .artists, [
            aspect("birthday-sex", .title, "birthday sex", ["birthday sex"], "Jeremih song Birthday Sex."),
            aspect("dont-tell-em", .title, "don't tell em", ["don't tell em", "dont tell em"], "Jeremih song Don't Tell 'Em."),
            aspect("down-on-me", .title, "down on me", ["down on me"], "Jeremih song Down on Me."),
        ]),
        person("noun-celeb-tyga", "Tyga", ["tyga"], .artists, [
            aspect("rack-city", .title, "rack city", ["rack city"], "Tyga song Rack City."),
        ]),
        person("noun-celeb-a-boogie", "A Boogie", ["a boogie", "a boogie wit da hoodie"], .artists, [
            aspect("look-back", .title, "look back at it", ["look back at it"], "A Boogie wit da Hoodie song Look Back at It."),
        ]),
        person("noun-celeb-roddy", "Roddy", ["roddy", "roddy ricch"], .artists, [
            aspect("the-box", .title, "the box", ["the box"], "Roddy Ricch song The Box."),
            aspect("die-young", .title, "die young", ["die young"], "Roddy Ricch song Die Young."),
            aspect("high-fashion", .title, "high fashion", ["high fashion"], "Roddy Ricch song High Fashion."),
            aspect("tip-toe", .title, "tip toe", ["tip toe", "tiptoe"], "Roddy Ricch song Tip Toe."),
        ]),
        person("noun-artist-young-dolph", "Dolph", ["young dolph", "dolph"], .artists, [
            aspect("100-shots", .title, "100 shots", ["100 shots", "a hundred shots"], "Young Dolph song 100 Shots."),
            aspect("by-mistake", .title, "by mistake", ["by mistake"], "Young Dolph song By Mistake."),
        ]),
        person("noun-artist-glorilla", "Glo", ["glorilla", "glo"], .artists, [
            aspect("fnf", .title, "fnf", ["fnf", "f.n.f", "f.n.f."], "GloRilla song F.N.F. (Let's Go)."),
            aspect("yeah-glo", .title, "yeah glo", ["yeah glo"], "GloRilla song Yeah Glo!."),
        ]),
        person("noun-artist-moneybagg-yo", "Moneybagg", ["moneybagg", "moneybagg yo"], .artists, [
            aspect("wockesha", .title, "wockesha", ["wockesha"], "Moneybagg Yo song Wockesha."),
            aspect("said-sum", .title, "said sum", ["said sum"], "Moneybagg Yo song Said Sum."),
        ]),
        person("noun-artist-pooh-shiesty", "Shiesty", ["pooh shiesty", "shiesty"], .artists, [
            aspect("back-in-blood", .title, "back in blood", ["back in blood"], "Pooh Shiesty song Back in Blood."),
        ]),
        person("noun-artist-yo-gotti", "Gotti", ["yo gotti", "gotti"], .artists, [
            aspect("down-in-the-dm", .title, "down in the dm", ["down in the dm"], "Yo Gotti song Down in the DM."),
            aspect("rake-it-up", .title, "rake it up", ["rake it up"], "Yo Gotti song Rake It Up."),
        ]),
        person("noun-artist-young-nudy", "Nudy", ["nudy", "young nudy"], .artists, [
            aspect("peaches-eggplant", .title, "peaches and eggplant", ["peaches and eggplant", "peaches & eggplant"], "Young Nudy song Peaches & Eggplant."),
            aspect("since-when", .title, "since when", ["since when"], "Young Nudy song Since When."),
        ]),
        person("noun-celeb-key-glock", "Glock", ["key glock"], .artists, [
            aspect("son-of-a-gun", .title, "son of a gun", ["son of a gun"], "Key Glock song Son of a Gun."),
            aspect("since-6ix", .title, "since 6ix", ["since 6ix", "since six"], "Key Glock song Since 6ix."),
        ]),
        person("noun-celeb-project-pat", "Pat", ["project pat"], .artists, [
            aspect("chickenhead", .title, "chickenhead", ["chickenhead", "chicken head"], "Project Pat song Chickenhead."),
            aspect("aint-from-my-hood", .title, "if you ain't from my hood", ["if you ain't from my hood", "if you aint from my hood"], "Project Pat song If You Ain't From My Hood."),
            aspect("we-can-get-gangsta", .title, "we can get gangsta", ["we can get gangsta"], "Project Pat song We Can Get Gangsta."),
        ]),
        person("noun-celeb-juicy-j", "Juicy", ["juicy j"], .artists, [
            aspect("bandz", .title, "bandz a make her dance", ["bandz a make her dance", "bands a make her dance"], "Juicy J song Bandz a Make Her Dance."),
            aspect("stay-trippy", .title, "stay trippy", ["stay trippy"], "Juicy J song Stay Trippy."),
        ]),
        person("noun-celeb-paul-wall", "Wall", ["paul wall"], .artists, [
            aspect("sittin-sidewayz", .title, "sittin sidewayz", ["sittin sidewayz", "sitting sideways"], "Paul Wall song Sittin' Sidewayz."),
        ]),
        person("noun-celeb-chamillionaire", "Cham", ["chamillionaire"], .artists, [
            aspect("ridin-dirty", .title, "ridin dirty", ["ridin dirty", "ridin' dirty", "riding dirty"], "Chamillionaire song Ridin'."),
        ]),
        person("noun-celeb-mike-jones", "Mike Jones", ["mike jones"], .artists, [
            aspect("still-tippin", .title, "still tippin", ["still tippin", "still tipping"], "Mike Jones song Still Tippin'."),
        ]),
        person("noun-celeb-chingy", "Chingy", ["chingy"], .artists, [
            aspect("right-thurr", .title, "right thurr", ["right thurr"], "Chingy song Right Thurr."),
            aspect("holidae-in", .title, "holidae in", ["holidae in", "holiday in"], "Chingy song Holidae In."),
        ]),
        person("noun-celeb-twista", "Twista", ["twista"], .artists, [
            aspect("overnight", .title, "overnight celebrity", ["overnight celebrity"], "Twista song Overnight Celebrity."),
            aspect("slow-jamz", .title, "slow jamz", ["slow jamz", "slow jams"], "Twista song Slow Jamz."),
        ]),
        person("noun-celeb-webbie", "Webbie", ["webbie"], .artists, [
            aspect("independent", .title, "independent", ["independent"], "Webbie song Independent."),
        ]),
        person("noun-celeb-mystikal", "Mystikal", ["mystikal"], .artists, [
            aspect("shake-ya-ass", .title, "shake ya ass", ["shake ya ass", "shake that ass"], "Mystikal song Shake Ya Ass."),
        ]),
        person("noun-celeb-fat-joe", "Fat Joe", ["fat joe"], .artists, [
            aspect("lean-back", .title, "lean back", ["lean back"], "Fat Joe song Lean Back."),
            aspect("all-the-way-up", .title, "all the way up", ["all the way up"], "Fat Joe song All the Way Up."),
            aspect("whats-luv", .title, "what's luv", ["what's luv", "whats luv"], "Fat Joe song What's Luv?"),
            aspect("make-it-rain", .title, "make it rain", ["make it rain"], "Fat Joe song Make It Rain."),
        ]),
        person("noun-celeb-big-pun", "Pun", ["big pun", "pun"], .artists, [
            aspect("still-not-a-player", .title, "still not a player", ["still not a player", "i'm not a player", "im not a player"], "Big Pun song Still Not a Player."),
            aspect("you-aint-a-killer", .title, "you ain't a killer", ["you ain't a killer", "you aint a killer"], "Big Pun song You Ain't a Killer."),
        ]),
        person("noun-celeb-ll-cool-j", "LL", ["ll cool j"], .artists, [
            aspect("knock-you-out", .title, "mama said knock you out", ["mama said knock you out"], "LL Cool J song Mama Said Knock You Out."),
            aspect("around-the-way", .title, "around the way girl", ["around the way girl"], "LL Cool J song Around the Way Girl."),
            aspect("i-need-love", .title, "i need love", ["i need love"], "LL Cool J song I Need Love."),
        ]),
        person("noun-celeb-eazy-e", "Eazy", ["eazy", "eazy e", "eazy-e"], .artists, [
            aspect("boyz-n-the-hood", .title, "boyz n the hood", ["boyz n the hood", "boyz in the hood", "boys in the hood"], "Eazy-E song Boyz-n-the-Hood."),
            aspect("eazy-duz-it", .title, "eazy duz it", ["eazy duz it", "eazy does it", "easy does it"], "Eazy-E song Eazy-Duz-It."),
        ]),
        person("noun-celeb-bun-b", "Bun", ["bun b"], .artists, [
            aspect("draped-up", .title, "draped up", ["draped up"], "Bun B song Draped Up."),
            aspect("get-throwed", .title, "get throwed", ["get throwed"], "Bun B song Get Throwed."),
        ]),
        person("noun-celeb-pusha", "Pusha", ["pusha", "pusha t"], .artists, [
            aspect("if-you-know", .title, "if you know you know", ["if you know you know"], "Pusha T song If You Know You Know."),
            aspect("nosetalgia", .title, "nosetalgia", ["nosetalgia"], "Pusha T song Nosetalgia."),
            aspect("grindin", .title, "grindin", ["grindin", "grindin'"], "Clipse song Grindin'."),
        ]),
        person("noun-celeb-fabolous", "Fab", ["fabolous"], .artists, [
            aspect("make-me-better", .title, "make me better", ["make me better"], "Fabolous song Make Me Better."),
            aspect("throw-it-in-the-bag", .title, "throw it in the bag", ["throw it in the bag"], "Fabolous song Throw It in the Bag."),
            aspect("cant-let-you-go", .title, "can't let you go", ["can't let you go", "cant let you go"], "Fabolous song Can't Let You Go."),
        ]),
        person("noun-celeb-ja-rule", "Ja Rule", ["ja rule"], .artists, [
            aspect("always-on-time", .title, "always on time", ["always on time"], "Ja Rule song Always on Time."),
            aspect("mesmerize", .title, "mesmerize", ["mesmerize"], "Ja Rule song Mesmerize."),
            aspect("livin-it-up", .title, "livin it up", ["livin it up", "living it up"], "Ja Rule song Livin' It Up."),
            aspect("between-me-and-you", .title, "between me and you", ["between me and you"], "Ja Rule song Between Me and You."),
        ]),
        person("noun-celeb-ashanti", "Ashanti", ["ashanti"], .artists, [
            aspect("foolish", .title, "foolish", ["foolish"], "Ashanti song Foolish."),
            aspect("rock-wit-u", .title, "rock wit u", ["rock wit u"], "Ashanti song Rock wit U."),
        ]),
        person("noun-celeb-sean-paul", "Sean Paul", ["sean paul"], .artists, [
            aspect("get-busy", .title, "get busy", ["get busy"], "Sean Paul song Get Busy."),
            aspect("like-glue", .title, "like glue", ["like glue"], "Sean Paul song Like Glue."),
            aspect("gimme-the-light", .title, "gimme the light", ["gimme the light"], "Sean Paul song Gimme the Light."),
        ]),
        person("noun-celeb-selena", "Selena", ["selena"], .artists, [
            aspect("como-la-flor", .title, "como la flor", ["como la flor"], "Selena song Como La Flor."),
            aspect("dreaming-of-you", .title, "dreaming of you", ["dreaming of you"], "Selena song Dreaming of You."),
            aspect("bidi-bidi", .title, "bidi bidi bom bom", ["bidi bidi bom bom"], "Selena song Bidi Bidi Bom Bom."),
        ]),
        person("noun-celeb-jlo", "JLo", ["jlo", "jennifer lopez"], .artists, [
            aspect("jenny-from-the-block", .title, "jenny from the block", ["jenny from the block"], "Jennifer Lopez song Jenny from the Block."),
            aspect("love-dont-cost", .title, "love don't cost a thing", ["love don't cost a thing", "love dont cost a thing"], "Jennifer Lopez song Love Don't Cost a Thing."),
            aspect("if-you-had-my-love", .title, "if you had my love", ["if you had my love"], "Jennifer Lopez song If You Had My Love."),
            aspect("waiting-for-tonight", .title, "waiting for tonight", ["waiting for tonight"], "Jennifer Lopez song Waiting for Tonight."),
        ]),
        person("noun-celeb-shakira", "Shakira", ["shakira"], .artists, [
            aspect("hips-dont-lie", .title, "hips don't lie", ["hips don't lie", "hips dont lie"], "Shakira song Hips Don't Lie."),
            aspect("whenever-wherever", .title, "whenever wherever", ["whenever wherever", "whenever, wherever"], "Shakira song Whenever, Wherever."),
            aspect("waka-waka", .title, "waka waka", ["waka waka"], "Shakira song Waka Waka."),
        ]),
        person("noun-celeb-adele", "Adele", ["adele"], .artists, [
            aspect("rolling-in-the-deep", .title, "rolling in the deep", ["rolling in the deep"], "Adele song Rolling in the Deep."),
            aspect("set-fire", .title, "set fire to the rain", ["set fire to the rain"], "Adele song Set Fire to the Rain."),
            aspect("someone-like-you", .title, "someone like you", ["someone like you"], "Adele song Someone Like You."),
            aspect("easy-on-me", .title, "easy on me", ["easy on me"], "Adele song Easy on Me."),
            aspect("rumour-has-it", .title, "rumour has it", ["rumour has it", "rumor has it"], "Adele song Rumour Has It."),
        ]),
        person("noun-celeb-taylor-swift", "Taylor", ["taylor swift"], .artists, [
            aspect("blank-space", .title, "blank space", ["blank space"], "Taylor Swift song Blank Space."),
            aspect("you-belong-with-me", .title, "you belong with me", ["you belong with me"], "Taylor Swift song You Belong with Me."),
            aspect("look-what-you-made", .title, "look what you made me do", ["look what you made me do"], "Taylor Swift song Look What You Made Me Do."),
            aspect("all-too-well", .title, "all too well", ["all too well"], "Taylor Swift song All Too Well."),
            aspect("shake-it-off", .title, "shake it off", ["shake it off"], "Taylor Swift song Shake It Off."),
            aspect("cruel-summer", .title, "cruel summer", ["cruel summer"], "Taylor Swift song Cruel Summer."),
            aspect("anti-hero", .title, "anti-hero", ["anti-hero", "anti hero"], "Taylor Swift song Anti-Hero."),
        ]),
        person("noun-celeb-bieber", "Bieber", ["bieber", "justin bieber"], .artists, [
            aspect("love-yourself", .title, "love yourself", ["love yourself"], "Justin Bieber song Love Yourself."),
            aspect("what-do-you-mean", .title, "what do you mean", ["what do you mean"], "Justin Bieber song What Do You Mean?."),
            aspect("where-are-u-now", .title, "where are you now", ["where are you now", "where are u now"], "Justin Bieber song Where Are Ü Now."),
        ]),
        person("noun-celeb-ariana", "Ariana", ["ariana", "ariana grande"], .artists, [
            aspect("thank-u-next", .title, "thank u next", ["thank u next", "thank you next"], "Ariana Grande song thank u, next."),
            aspect("7-rings", .title, "7 rings", ["7 rings", "seven rings"], "Ariana Grande song 7 rings."),
            aspect("no-tears", .title, "no tears left to cry", ["no tears left to cry"], "Ariana Grande song no tears left to cry."),
            aspect("god-is-a-woman", .title, "god is a woman", ["god is a woman"], "Ariana Grande song God is a woman."),
            aspect("side-to-side", .title, "side to side", ["side to side"], "Ariana Grande song Side to Side."),
        ]),
        person("noun-celeb-britney", "Britney", ["britney", "britney spears"], .artists, [
            aspect("baby-one-more-time", .title, "baby one more time", ["baby one more time"], "Britney Spears song ...Baby One More Time."),
            aspect("oops", .title, "oops i did it again", ["oops i did it again"], "Britney Spears song Oops!... I Did It Again."),
            aspect("gimme-more", .title, "gimme more", ["gimme more"], "Britney Spears song Gimme More."),
            aspect("womanizer", .title, "womanizer", ["womanizer"], "Britney Spears song Womanizer."),
        ]),
        person("noun-celeb-lady-gaga", "Gaga", ["lady gaga", "gaga"], .artists, [
            aspect("poker-face", .title, "poker face", ["poker face"], "Lady Gaga song Poker Face."),
            aspect("bad-romance", .title, "bad romance", ["bad romance"], "Lady Gaga song Bad Romance."),
            aspect("born-this-way", .title, "born this way", ["born this way"], "Lady Gaga song Born This Way."),
            aspect("just-dance", .title, "just dance", ["just dance"], "Lady Gaga song Just Dance."),
        ]),
        person("noun-celeb-aretha", "Aretha", ["aretha", "aretha franklin"], .artists, [
            aspect("chain-of-fools", .title, "chain of fools", ["chain of fools"], "Aretha Franklin song Chain of Fools."),
            aspect("natural-woman", .title, "natural woman", ["natural woman", "a natural woman"], "Aretha Franklin song (You Make Me Feel Like) A Natural Woman."),
            aspect("little-prayer", .title, "i say a little prayer", ["i say a little prayer"], "Aretha Franklin song I Say a Little Prayer."),
        ]),
        person("noun-celeb-tina-turner", "Tina", ["tina turner"], .artists, [
            aspect("whats-love", .title, "what's love got to do with it", ["what's love got to do with it", "whats love got to do with it"], "Tina Turner song What's Love Got to Do with It."),
            aspect("simply-the-best", .title, "simply the best", ["simply the best"], "Tina Turner song The Best."),
            aspect("proud-mary", .title, "proud mary", ["proud mary"], "Tina Turner song Proud Mary."),
            aspect("private-dancer", .title, "private dancer", ["private dancer"], "Tina Turner song Private Dancer."),
        ]),
        person("noun-celeb-diana-ross", "Diana", ["diana ross"], .artists, [
            aspect("im-coming-out", .title, "i'm coming out", ["i'm coming out", "im coming out"], "Diana Ross song I'm Coming Out."),
            aspect("aint-no-mountain", .title, "ain't no mountain high enough", ["ain't no mountain high enough", "aint no mountain high enough"], "Diana Ross song Ain't No Mountain High Enough."),
            aspect("upside-down", .title, "upside down", ["upside down"], "Diana Ross song Upside Down."),
        ]),
        person("noun-celeb-madonna", "Madonna", ["madonna"], .artists, [
            aspect("like-a-virgin", .title, "like a virgin", ["like a virgin"], "Madonna song Like a Virgin."),
            aspect("like-a-prayer", .title, "like a prayer", ["like a prayer"], "Madonna song Like a Prayer."),
            aspect("material-girl", .title, "material girl", ["material girl"], "Madonna song Material Girl."),
            aspect("vogue", .title, "vogue", ["vogue"], "Madonna song Vogue."),
            aspect("papa-dont-preach", .title, "papa don't preach", ["papa don't preach", "papa dont preach"], "Madonna song Papa Don't Preach."),
        ]),
        person("noun-celeb-ciara", "Ciara", ["ciara"], .artists, [
            aspect("one-two-step", .title, "1 2 step", ["1 2 step", "1, 2 step", "one two step"], "Ciara song 1, 2 Step."),
            aspect("body-party", .title, "body party", ["body party"], "Ciara song Body Party."),
            aspect("goodies", .title, "goodies", ["goodies"], "Ciara song Goodies."),
        ]),
        person("noun-celeb-keyshia", "Keyshia", ["keyshia", "keyshia cole"], .artists, [
            aspect("should-have-cheated", .title, "i should have cheated", ["i should have cheated"], "Keyshia Cole song I Should Have Cheated."),
            aspect("heaven-sent", .title, "heaven sent", ["heaven sent"], "Keyshia Cole song Heaven Sent."),
        ]),
        person("noun-celeb-omarion", "Omarion", ["omarion"], .artists, [
            aspect("ice-box", .title, "ice box", ["ice box"], "Omarion song Ice Box."),
            aspect("post-to-be", .title, "post to be", ["post to be"], "Omarion song Post to Be."),
        ]),
        person("noun-celeb-ginuwine", "Ginuwine", ["ginuwine"], .artists, [
            aspect("pony", .title, "pony", ["pony"], "Ginuwine song Pony."),
            aspect("so-anxious", .title, "so anxious", ["so anxious"], "Ginuwine song So Anxious."),
            aspect("in-those-jeans", .title, "in those jeans", ["in those jeans"], "Ginuwine song In Those Jeans."),
        ]),
        person("noun-celeb-sisqo", "Sisqo", ["sisqo"], .artists, [
            aspect("thong-song", .title, "thong song", ["thong song", "the thong song"], "Sisqó song Thong Song."),
        ]),
        person("noun-celeb-bobby-brown", "Bobby", ["bobby brown"], .artists, [
            aspect("prerogative", .title, "my prerogative", ["my prerogative"], "Bobby Brown song My Prerogative."),
            aspect("every-little-step", .title, "every little step", ["every little step"], "Bobby Brown song Every Little Step."),
        ]),
        person("noun-celeb-janet", "Janet", ["janet jackson"], .artists, [
            aspect("way-love-goes", .title, "that's the way love goes", ["that's the way love goes", "thats the way love goes"], "Janet Jackson song That's the Way Love Goes."),
            aspect("what-have-you-done", .title, "what have you done for me lately", ["what have you done for me lately"], "Janet Jackson song What Have You Done for Me Lately."),
            aspect("together-again", .title, "together again", ["together again"], "Janet Jackson song Together Again."),
            aspect("all-for-you", .title, "all for you", ["all for you"], "Janet Jackson song All for You."),
        ]),
        person("noun-celeb-timberlake", "Timberlake", ["timberlake", "justin timberlake"], .artists, [
            aspect("sexyback", .title, "sexyback", ["sexyback", "sexy back"], "Justin Timberlake song SexyBack."),
            aspect("cry-me-a-river", .title, "cry me a river", ["cry me a river"], "Justin Timberlake song Cry Me a River."),
            aspect("rock-your-body", .title, "rock your body", ["rock your body"], "Justin Timberlake song Rock Your Body."),
            aspect("what-goes-around", .title, "what goes around", ["what goes around"], "Justin Timberlake song What Goes Around... Comes Around."),
            aspect("cant-stop-the-feeling", .title, "can't stop the feeling", ["can't stop the feeling", "cant stop the feeling"], "Justin Timberlake song Can't Stop the Feeling!."),
            aspect("suit-and-tie", .title, "suit and tie", ["suit and tie"], "Justin Timberlake song Suit & Tie."),
        ]),
        person("noun-artist-sza", "SZA", ["sza", "solana"], .artists, [
            aspect("kill-bill", .title, "kill bill", ["kill bill"], "SZA song Kill Bill."),
            aspect("nobody-gets-me", .title, "nobody gets me", ["nobody gets me"], "SZA song Nobody Gets Me."),
            aspect("snooze", .title, "snooze", ["snooze"], "SZA song Snooze."),
            aspect("good-days", .title, "good days", ["good days"], "SZA song Good Days."),
            aspect("smoking-on-my-ex", .title, "smoking on my ex", ["smoking on my ex"], "SZA song Smoking on My Ex Pack."),
            aspect("love-galore", .title, "love galore", ["love galore"], "SZA song Love Galore."),
            aspect("broken-clocks", .title, "broken clocks", ["broken clocks"], "SZA song Broken Clocks."),
            aspect("the-weekend", .title, "the weekend", ["the weekend"], "SZA song The Weekend."),
            aspect("gone-girl", .title, "gone girl", ["gone girl"], "SZA song Gone Girl."),
        ]),
        person("noun-artist-frank-ocean", "Frank", ["frank ocean"], .artists, [
            aspect("thinkin-bout-you", .title, "thinkin bout you", [
                "thinkin bout you", "thinking about you", "thinkin' bout you",
            ], "Frank Ocean song Thinkin Bout You."),
            aspect("super-rich-kids", .title, "super rich kids", ["super rich kids"], "Frank Ocean song Super Rich Kids."),
            aspect("pyramids", .title, "pyramids", ["pyramids"], "Frank Ocean song Pyramids."),
            aspect("novacane", .title, "novacane", ["novacane"], "Frank Ocean song Novacane."),
            aspect("swim-good", .title, "swim good", ["swim good"], "Frank Ocean song Swim Good."),
            aspect("white-ferrari", .title, "white ferrari", ["white ferrari"], "Frank Ocean song White Ferrari."),
            aspect("self-control", .title, "self control", ["self control"], "Frank Ocean song Self Control."),
            aspect("bad-religion", .title, "bad religion", ["bad religion"], "Frank Ocean song Bad Religion."),
            aspect("sweet-life", .title, "sweet life", ["sweet life"], "Frank Ocean song Sweet Life."),
            aspect("godspeed", .title, "godspeed", ["godspeed"], "Frank Ocean song Godspeed."),
            aspect("forrest-gump", .title, "forrest gump", ["forrest gump"], "Frank Ocean song Forrest Gump."),
        ]),
        person("noun-artist-chris-brown", "Breezy", ["chris brown", "breezy"], .artists, [
            aspect("under-the-influence", .title, "under the influence", ["under the influence"], "Chris Brown song Under the Influence."),
            aspect("no-guidance", .title, "no guidance", ["no guidance"], "Chris Brown song No Guidance."),
            aspect("fine-china", .title, "fine china", ["fine china"], "Chris Brown song Fine China."),
            aspect("look-at-me-now", .title, "look at me now", ["look at me now"], "Chris Brown song Look at Me Now."),
            aspect("deuces", .title, "deuces", ["deuces"], "Chris Brown song Deuces."),
            aspect("back-to-sleep", .title, "back to sleep", ["back to sleep"], "Chris Brown song Back to Sleep."),
            aspect("residuals", .title, "residuals", ["residuals"], "Chris Brown song Residuals."),
            aspect("kiss-kiss", .title, "kiss kiss", ["kiss kiss"], "Chris Brown song Kiss Kiss."),
        ]),
        person("noun-artist-summer-walker", "Summer", ["summer walker"], .artists, [
            aspect("playing-games", .title, "playing games", ["playing games"], "Summer Walker song Playing Games."),
            aspect("girls-need-love", .title, "girls need love", ["girls need love"], "Summer Walker song Girls Need Love."),
            aspect("come-thru", .title, "come thru", ["come thru"], "Summer Walker song Come Thru."),
            aspect("stretch-you-out", .title, "stretch you out", ["stretch you out"], "Summer Walker song Stretch You Out."),
            aspect("switch-a-nigga", .title, "switch a nigga out", ["switch a nigga out"], "Summer Walker song Switch a Nigga Out."),
            aspect("throw-it-away", .title, "throw it away", ["throw it away"], "Summer Walker song Throw It Away."),
            aspect("still-over-it", .title, "still over it", ["still over it"], "Summer Walker song Still Over It."),
            aspect("session-32", .title, "session 32", ["session 32"], "Summer Walker song Session 32."),
        ]),
        person("noun-artist-yeat", "Yeat", ["yeat"], .artists, [
            aspect("sorry-bout-that", .title, "sorry bout that", ["sorry bout that"], "Yeat song Sorry Bout That."),
            aspect("money-so-big", .title, "money so big", ["money so big"], "Yeat song Monëy So Big."),
            aspect("if-we-being-real", .title, "if we being real", ["if we being real"], "Yeat song If We Being Rëal."),
            aspect("mad-bout-that", .title, "mad bout that", ["mad bout that"], "Yeat song Mad Bout That."),
        ]),
        person("noun-artist-ken-carson", "Ken", ["ken carson"], .artists, [
            aspect("fighting-my-demons", .title, "fighting my demons", ["fighting my demons"], "Ken Carson song Fighting My Demons."),
            aspect("jennifers-body", .title, "jennifer's body", ["jennifer's body", "jennifers body"], "Ken Carson song Jennifer's Body."),
            aspect("delusional", .title, "delusional", ["delusional"], "Ken Carson song Delusional."),
            aspect("me-n-my-kup", .title, "me n my kup", ["me n my kup", "me and my cup"], "Ken Carson song Me N My Kup."),
            aspect("yale", .title, "yale", ["yale"], "Ken Carson song Yale."),
        ]),
        person("noun-artist-ice-spice", "Ice", ["ice spice", "ice"], .artists, [
            aspect("in-ha-mood", .title, "in ha mood", ["in ha mood", "in her mood"], "Ice Spice song In Ha Mood."),
            aspect("princess-diana", .title, "princess diana", ["princess diana"], "Ice Spice song Princess Diana."),
            aspect("bikini-bottom", .title, "bikini bottom", ["bikini bottom"], "Ice Spice song Bikini Bottom."),
            aspect("boys-a-liar", .title, "boy's a liar", ["boy's a liar", "boys a liar"], "Ice Spice song Boy's a Liar."),
            aspect("munch", .title, "munch", ["munch"], "Ice Spice song Munch."),
        ]),
        person("noun-artist-sexyy-red", "Sexyy", ["sexyy red", "sexyy"], .artists, [
            aspect("pound-town", .title, "pound town", ["pound town"], "Sexyy Red song Pound Town."),
            aspect("skeeyee", .title, "skeeyee", ["skeeyee", "skee yee"], "Sexyy Red song SkeeYee."),
            aspect("rich-baby-daddy", .title, "rich baby daddy", ["rich baby daddy"], "Sexyy Red song Rich Baby Daddy."),
        ]),
        person("noun-artist-g-herbo", "Herbo", ["g herbo", "herbo"], .artists, [
            aspect("ptsd", .title, "ptsd", ["ptsd"], "G Herbo song PTSD."),
            aspect("lawyer-fees", .title, "lawyer fees", ["lawyer fees"], "G Herbo song Lawyer Fees."),
            aspect("went-legit", .title, "went legit", ["went legit"], "G Herbo song Went Legit."),
            aspect("four-minutes", .title, "4 minutes of hell", ["4 minutes of hell", "four minutes of hell"], "G Herbo song 4 Minutes of Hell."),
            aspect("bi-polar", .title, "bi polar", ["bi polar", "bipolar"], "G Herbo song Bi Polar."),
        ]),
        person("noun-celeb-nav", "Nav", ["nav"], .artists, [
            aspect("some-way", .title, "some way", ["some way"], "NAV song Some Way."),
            aspect("wanted-you", .title, "wanted you", ["wanted you"], "NAV song Wanted You."),
            aspect("know-me", .title, "know me", ["know me"], "NAV song Know Me."),
            aspect("turks", .title, "turks", ["turks"], "NAV song Turks."),
        ]),
        person("noun-celeb-tory", "Tory", ["tory lanez", "tory"], .artists, [
            aspect("color-violet", .title, "the color violet", ["the color violet"], "Tory Lanez song The Color Violet."),
            aspect("ferris-wheel", .title, "ferris wheel", ["ferris wheel"], "Tory Lanez song Ferris Wheel."),
        ]),
        person("noun-artist-fivio-foreign", "Fivio", ["fivio", "fivio foreign"], .artists, [
            aspect("big-drip", .title, "big drip", ["big drip"], "Fivio Foreign song Big Drip."),
        ]),
        person("noun-celeb-french-montana", "French", ["french montana", "french"], .artists, [
            aspect("unforgettable", .title, "unforgettable", ["unforgettable"], "French Montana song Unforgettable."),
            aspect("pop-that", .title, "pop that", ["pop that"], "French Montana song Pop That."),
        ]),
        person("noun-celeb-mac-miller", "Mac", ["mac miller"], .artists, [
            aspect("self-care", .title, "self care", ["self care"], "Mac Miller song Self Care."),
            aspect("good-news", .title, "good news", ["good news"], "Mac Miller song Good News."),
        ]),
        person("noun-celeb-lil-peep", "Peep", ["lil peep", "peep"], .artists, [
            aspect("star-shopping", .title, "star shopping", ["star shopping"], "Lil Peep song Star Shopping."),
            aspect("beamer-boy", .title, "beamer boy", ["beamer boy"], "Lil Peep song Beamer Boy."),
            aspect("awful-things", .title, "awful things", ["awful things"], "Lil Peep song Awful Things."),
        ]),
        person("noun-celeb-jid", "JID", ["jid"], .artists, [
            aspect("surround-sound", .title, "surround sound", ["surround sound"], "JID song Surround Sound."),
            aspect("151-rum", .title, "151 rum", ["151 rum"], "JID song 151 Rum."),
            aspect("off-deez", .title, "off deez", ["off deez"], "JID song Off Deez."),
            aspect("dance-now", .title, "dance now", ["dance now"], "JID song Dance Now."),
        ]),
        person("noun-celeb-saweetie", "Saweetie", ["saweetie"], .artists, [
            aspect("tap-in", .title, "tap in", ["tap in"], "Saweetie song Tap In."),
            aspect("icy-girl", .title, "icy girl", ["icy girl", "icy grl"], "Saweetie song Icy Grl."),
        ]),
        person("noun-celeb-coi-leray", "Coi", ["coi leray", "coi"], .artists, [
            aspect("twinnem", .title, "twinnem", ["twinnem"], "Coi Leray song Twinnem."),
            aspect("blick-blick", .title, "blick blick", ["blick blick"], "Coi Leray song Blick Blick."),
        ]),
        person("noun-celeb-wyclef", "Wyclef", ["wyclef"], .artists, [
            aspect("gone-till-november", .title, "gone till november", ["gone till november"], "Wyclef Jean song Gone Till November."),
        ]),
        person("noun-celeb-queen-latifah", "Latifah", ["queen latifah", "latifah"], .artists, [
            aspect("ladies-first", .title, "ladies first", ["ladies first"], "Queen Latifah song Ladies First."),
            aspect("unity", .title, "u.n.i.t.y.", ["u.n.i.t.y.", "unity"], "Queen Latifah song U.N.I.T.Y."),
        ]),
        person("noun-celeb-teyana", "Teyana", ["teyana", "teyana taylor"], .artists, [
            aspect("gonna-love-me", .title, "gonna love me", ["gonna love me"], "Teyana Taylor song Gonna Love Me."),
        ]),
        person("noun-celeb-solange", "Solange", ["solange"], .artists, [
            aspect("cranes", .title, "cranes in the sky", ["cranes in the sky"], "Solange song Cranes in the Sky."),
            aspect("dont-touch-my-hair", .title, "don't touch my hair", ["don't touch my hair", "dont touch my hair"], "Solange song Don't Touch My Hair."),
        ]),
        person("noun-celeb-bow-wow", "Bow Wow", ["bow wow", "lil bow wow"], .artists, [
            aspect("puppy-love", .title, "puppy love", ["puppy love"], "Bow Wow song Puppy Love."),
            aspect("let-me-hold-you", .title, "let me hold you", ["let me hold you"], "Bow Wow song Let Me Hold You."),
        ]),
        person("noun-celeb-ghostface", "Ghostface", ["ghostface", "ghostface killah", "tony starks"], .artists, [
            aspect("all-that-i-got", .title, "all that i got is you", ["all that i got is you"], "Ghostface Killah song All That I Got Is You."),
            aspect("back-like-that", .title, "back like that", ["back like that"], "Ghostface Killah song Back Like That."),
        ]),
        person("noun-celeb-raekwon", "Rae", ["raekwon", "rae"], .artists, [
            aspect("ice-cream", .title, "ice cream", ["ice cream"], "Raekwon song Ice Cream."),
            aspect("criminology", .title, "criminology", ["criminology"], "Raekwon song Criminology."),
        ]),
        person("noun-celeb-jim-jones", "Capo", ["jim jones", "capo"], .artists, [
            aspect("we-fly-high", .title, "we fly high", ["we fly high"], "Jim Jones song We Fly High."),
            aspect("dipset", .crew, "dipset", ["dipset"], "Jim Jones and Dipset. The same crew picture also belongs to Cam'ron and Juelz."),
        ]),
        person("noun-celeb-max-b", "Wavy", ["max b", "wavy"], .artists, [
            aspect("wave-gods", .title, "wave gods", ["wave gods"], "Max B tape Wave Gods."),
        ]),
        person("noun-celeb-popcaan", "Popcaan", ["popcaan"], .artists, [
            aspect("firm-and-strong", .title, "firm and strong", ["firm and strong"], "Popcaan song Firm and Strong."),
        ]),
        person("noun-celeb-kartel", "Vybz", ["vybz kartel", "vybz", "kartel"], .artists, [
            aspect("coloring-book", .title, "coloring book", ["coloring book"], "Vybz Kartel song Coloring Book."),
        ]),
        person("noun-celeb-slim-thug", "Slim Thug", ["slim thug"], .artists, [
            aspect("like-a-boss", .title, "like a boss", ["like a boss"], "Slim Thug song Like a Boss."),
        ]),
        person("noun-celeb-tee-grizzley", "Grizzley", ["tee grizzley", "grizzley"], .artists, [
            aspect("first-day-out", .title, "first day out", ["first day out"], "Tee Grizzley song First Day Out."),
        ]),
        person("noun-artist-veeze", "Veeze", ["veeze"], .artists, [
            aspect("not-a-drill", .title, "not a drill", ["not a drill"], "Veeze song Not a Drill."),
        ]),
        person("noun-artist-sahbabii", "SahBabii", ["sahbabii"], .artists, [
            aspect("pull-up-wit-ah-stick", .title, "pull up wit ah stick", ["pull up wit ah stick"], "SahBabii song Pull Up wit ah Stick."),
        ]),
        person("noun-celeb-dababy", "DaBaby", ["dababy"], .artists, [
            aspect("baby-sitter", .title, "baby sitter", ["baby sitter"], "DaBaby song Baby Sitter."),
            aspect("vibez", .title, "vibez", ["vibez"], "DaBaby song Vibez."),
        ]),
        person("noun-artist-the-game", "Game", ["the game"], .artists, [
            aspect("how-we-do", .title, "how we do", ["how we do"], "The Game song How We Do."),
        ]),
        person("noun-artist-diddy", "Diddy", ["diddy", "puff daddy", "puffy"], .artists, [
            aspect("bad-boy", .title, "bad boy for life", ["bad boy for life"], "Diddy song Bad Boy for Life."),
            aspect("i-need-a-girl", .title, "i need a girl", ["i need a girl"], "Diddy song I Need a Girl."),
        ]),
        person("noun-artist-nocap", "NoCap", ["nocap"], .artists, [
            aspect("wrong-idea", .title, "wrong idea", ["wrong idea"], "NoCap song Wrong Idea."),
        ]),
        person("noun-artist-lil-keed", "Keed", ["lil keed", "keed"], .artists, [
            aspect("nameless", .title, "nameless", ["nameless"], "Lil Keed song Nameless. Bare nameless stays off."),
            aspect("fox-5", .title, "fox 5", ["fox 5"], "Lil Keed song Fox 5."),
        ]),
        person("noun-celeb-dj-khaled", "Khaled", ["dj khaled", "khaled"], .artists, [
            aspect("all-i-do-is-win", .title, "all i do is win", ["all i do is win"], "DJ Khaled song All I Do Is Win."),
            aspect("im-the-one", .title, "i'm the one", ["i'm the one", "im the one"], "DJ Khaled song I'm the One."),
            aspect("we-the-best", .catchphrase, "we the best", ["we the best"], "DJ Khaled catchphrase We the Best."),
            aspect("another-one", .catchphrase, "another one", ["another one"], "DJ Khaled catchphrase Another One."),
        ]),
        person("noun-celeb-redman", "Redman", ["redman", "funk doctor spock"], .artists, [
            aspect("tonights-da-night", .title, "tonight's da night", ["tonight's da night", "tonights da night"], "Redman song Tonight's da Night."),
        ]),
        person("noun-celeb-yung-miami", "Yung Miami", ["yung miami"], .artists, [
            aspect("act-up", .title, "act up", ["act up"], "City Girls song Act Up."),
        ]),
        person("noun-celeb-papoose", "Papoose", ["papoose"], .artists, [
            aspect("alphabetical", .title, "alphabetical slaughter", ["alphabetical slaughter"], "Papoose's alphabetical slaughter."),
        ]),
        person("noun-celeb-rza", "RZA", ["rza", "bobby digital", "the abbot"], .artists, [
            aspect("gravel-pit", .title, "gravel pit", ["gravel pit"], "Wu-Tang song Gravel Pit."),
            aspect("protect-ya-neck", .title, "protect ya neck", ["protect ya neck", "protect your neck"], "Wu-Tang song Protect Ya Neck."),
        ]),
        person("noun-celeb-tyrese", "Tyrese", ["tyrese"], .artists, [
            aspect("sweet-lady", .title, "sweet lady", ["sweet lady"], "Tyrese song Sweet Lady."),
        ]),
        person("noun-celeb-kelly-rowland", "Kelly", ["kelly rowland"], .artists, [
            aspect("motivation", .title, "motivation", ["motivation"], "Kelly Rowland song Motivation."),
            aspect("kisses-down-low", .title, "kisses down low", ["kisses down low"], "Kelly Rowland song Kisses Down Low."),
        ]),
        person("noun-celeb-jill-scott", "Jill", ["jill scott"], .artists, [
            aspect("a-long-walk", .title, "a long walk", ["a long walk"], "Jill Scott song A Long Walk."),
        ]),
        person("noun-celeb-anita-baker", "Anita", ["anita baker"], .artists, [
            aspect("rapture", .title, "caught up in the rapture", ["caught up in the rapture"], "Anita Baker song Caught Up in the Rapture."),
            aspect("best-that-i-got", .title, "giving you the best that i got", ["giving you the best that i got"], "Anita Baker song Giving You the Best That I Got."),
        ]),
        person("noun-celeb-sinatra", "Sinatra", ["sinatra", "frank sinatra", "ol blue eyes", "ol' blue eyes"], .artists, [
            aspect("fly-me", .title, "fly me to the moon", ["fly me to the moon"], "Frank Sinatra song Fly Me to the Moon."),
            aspect("new-york", .title, "new york new york", ["new york new york", "new york, new york"], "Frank Sinatra song New York, New York."),
        ]),
        person("noun-celeb-katy-perry", "Katy", ["katy perry"], .artists, [
            aspect("firework", .title, "firework", ["firework"], "Katy Perry song Firework."),
            aspect("teenage-dream", .title, "teenage dream", ["teenage dream"], "Katy Perry song Teenage Dream."),
            aspect("california-gurls", .title, "california gurls", ["california gurls", "california girls"], "Katy Perry song California Gurls."),
            aspect("dark-horse", .title, "dark horse", ["dark horse"], "Katy Perry song Dark Horse."),
        ]),
        person("noun-celeb-demi", "Demi", ["demi lovato", "demi"], .artists, [
            aspect("cool-for-the-summer", .title, "cool for the summer", ["cool for the summer"], "Demi Lovato song Cool for the Summer."),
        ]),
        person("noun-celeb-iggy", "Iggy", ["iggy", "iggy azalea"], .artists, [
            aspect("fancy", .title, "fancy", ["fancy"], "Iggy Azalea song Fancy."),
            aspect("black-widow", .title, "black widow", ["black widow"], "Iggy Azalea song Black Widow."),
        ]),
        person("noun-celeb-camron", "Cam'ron", ["camron", "cam'ron", "killa cam"], .artists, [
            aspect("hey-ma", .title, "hey ma", ["hey ma"], "Cam'ron song Hey Ma."),
            aspect("dipset", .crew, "dipset", ["dipset"], "Cam'ron and Dipset. The same crew picture also belongs to Juelz and Capo."),
            aspect("pink-fur", .outfit, "pink fur", ["pink fur", "pink fur coat"], "Cam'ron's pink fur."),
        ]),
        person("noun-celeb-juelz", "Juelz", ["juelz", "juelz santana"], .artists, [
            aspect("dipset-anthem", .title, "dipset anthem", ["dipset anthem"], "Juelz Santana song Dipset Anthem."),
            aspect("dipset", .crew, "dipset", ["dipset"], "Juelz Santana and Dipset. The same crew picture also belongs to Cam'ron and Capo."),
        ]),
        person("noun-prod-mustard", "Mustard", ["dj mustard", "mustard"], .artists, [
            aspect("on-the-beat", .tag, "mustard on the beat", [
                "mustard on the beat",
            ], "Mustard's producer tag."),
        ]),
        person("noun-prod-mike-will", "Mike WiLL", ["mike will", "mike will made it"], .artists, [
            aspect("made-it", .tag, "mike will made it", [
                "mike will made it",
            ], "Mike WiLL Made-It's producer tag."),
        ]),
        person("noun-prod-southside", "Southside", ["southside on the track"], .artists, [
            aspect("on-the-track", .tag, "southside on the track", [
                "southside on the track",
            ], "Southside's producer tag. Bare southside stays the place."),
        ]),
        person("noun-prod-wheezy", "Wheezy", ["wheezy"], .artists, [
            aspect("outta-here", .tag, "wheezy outta here", [
                "wheezy outta here",
            ], "Wheezy's producer tag."),
        ]),
        person("noun-prod-tay-keith", "Tay Keith", ["tay keith"], .artists, [
            aspect("tag", .tag, "tay keith fuck these niggas up", [
                "tay keith fuck these niggas up",
            ], "Tay Keith's producer tag."),
        ]),
    ]

    private static let hoopers: [PersonSignature] = [
        person("noun-celeb-michael-jordan", "Mike", ["michael jordan", "jordan", "mj", "mike"], .hoopers, [
            aspect("tongue-out", .mannerism, "tongue out", [
                "tongue out", "tongues out", "stuck his tongue", "stuck my tongue", "stuck her tongue",
            ], "Michael Jordan plays with his tongue out."),
            aspect("shrug", .mannerism, "shrug", [
                "shrug", "shrugged", "shrugs", "shrugging",
            ], "Michael Jordan shrugs in the I-can't-hear-you celebration."),
            aspect("flu-game", .moment, "flu game", [
                "flu game", "played with the flu", "played sick in the finals",
            ], "Michael Jordan played the flu game in the finals."),
        ]),
        person("noun-celeb-kobe", "Kobe", ["kobe", "mamba", "black mamba"], .hoopers, [
            aspect("fadeaway", .performance, "fadeaway", [
                "fadeaway", "fade away",
            ], "Kobe Bryant's shot is the fadeaway."),
            aspect("eighty-one", .moment, "81 points", [
                "81 points", "eighty-one points", "eighty one points",
            ], "Kobe Bryant scored 81 points in a game."),
        ]),
        person("noun-celeb-iverson", "Iverson", ["iverson", "allen iverson", "the answer", "ai", "a.i."], .hoopers, [
            aspect("crossover", .performance, "crossover", [
                "crossover", "the crossover", "crossed him", "crossed her", "crossed you", "cross him",
            ], "Allen Iverson is known for the crossover."),
            aspect("practice", .moment, "talking about practice", [
                "talking about practice", "talkin about practice", "talkin' about practice", "we talkin practice",
            ], "Allen Iverson's press conference kept saying we talking about practice."),
        ]),
        person("noun-celeb-steph", "Steph", ["steph", "steph curry", "stephen curry", "curry", "chef"], .hoopers, [
            aspect("shimmy", .mannerism, "shimmy", ["shimmy", "shimmied"], "Steph Curry shimmies after a shot."),
            aspect("night-night", .performance, "night night", [
                "night night", "night-night",
            ], "Steph Curry's night-night celebration."),
        ]),
        person("noun-celeb-kyrie", "Kyrie", ["kyrie", "kyrie irving", "uncle drew"], .hoopers, [
            aspect("ankles", .performance, "broke his ankles", [
                "broke his ankles", "broke her ankles", "broke they ankles", "broke the ankles", "ankles broke",
            ], "Kyrie Irving breaks ankles with the handle."),
        ]),
        person("noun-celeb-harden", "Harden", ["harden", "james harden"], .hoopers, [
            aspect("stepback", .performance, "stepback", [
                "stepback", "step back", "step-back",
            ], "James Harden's stepback jumper."),
        ]),
        person("noun-celeb-shaq", "Shaq", ["shaq", "shaquille", "diesel"], .hoopers, [
            aspect("backboard", .performance, "backboard", [
                "backboard", "broke the rim", "shattered the rim",
            ], "Shaquille O'Neal broke backboards."),
        ]),
        person("noun-celeb-vince-carter", "Vince", ["vince", "vince carter", "vinsanity"], .hoopers, [
            aspect("poster", .performance, "poster", [
                "posterized", "poster dunk", "on a poster", "threw a poster",
            ], "Vince Carter put defenders on posters."),
        ]),
        person("noun-celeb-lebron", "Bron", ["lebron", "bron", "king james"], .hoopers, [
            aspect("chalk", .mannerism, "chalk toss", [
                "chalk toss", "the chalk", "threw chalk", "clapped chalk",
            ], "LeBron James tosses chalk before tip."),
            aspect("the-decision", .moment, "took his talents", [
                "took my talents", "took his talents", "took her talents",
            ], "LeBron James announced he was taking his talents to South Beach."),
        ]),
        person("noun-celeb-rodman", "Rodman", ["rodman", "dennis rodman"], .hoopers, [
            aspect("hair", .outfit, "dyed hair", [
                "dyed hair", "dyed his hair", "dyed her hair", "rainbow hair",
            ], "Dennis Rodman dyes his hair."),
            aspect("wedding-dress", .outfit, "wedding dress", [
                "wedding dress", "wore a wedding dress",
            ], "Dennis Rodman wore a wedding dress."),
        ]),
        person("noun-celeb-mutombo", "Mutombo", ["mutombo", "dikembe"], .hoopers, [
            aspect("finger-wag", .mannerism, "finger wag", [
                "finger wag", "wagged his finger", "wagging the finger",
            ], "Dikembe Mutombo wags his finger."),
        ]),
        person("noun-celeb-kareem", "Kareem", ["kareem", "kareem abdul-jabbar", "kareem abdul jabbar"], .hoopers, [
            aspect("skyhook", .performance, "skyhook", [
                "skyhook", "sky hook",
            ], "Kareem Abdul-Jabbar's skyhook."),
        ]),
        person("noun-celeb-hakeem", "Hakeem", ["hakeem", "the dream"], .hoopers, [
            aspect("dream-shake", .performance, "dream shake", [
                "dream shake", "the dream shake",
            ], "Hakeem Olajuwon's dream shake."),
        ]),
        person("noun-celeb-dr-j", "Dr J", ["dr j", "dr. j", "julius erving"], .hoopers, [
            aspect("foul-line", .performance, "free throw line dunk", [
                "free throw line dunk", "from the free-throw line", "from the foul line",
            ], "Julius Erving dunked from the free-throw line."),
        ]),
        person("noun-celeb-magic-johnson", "Magic", ["magic johnson", "magic", "earvin"], .hoopers, [
            aspect("no-look", .performance, "no look pass", [
                "no look pass", "no-look pass", "no look dish",
            ], "Magic Johnson's no-look pass."),
        ]),
        person("noun-celeb-dirk", "Dirk", ["dirk", "dirk nowitzki"], .hoopers, [
            aspect("one-leg", .performance, "one-legged fade", [
                "one-legged fade", "one legged fade", "one leg fade",
            ], "Dirk Nowitzki's one-legged fade."),
        ]),
        person("noun-celeb-giannis", "Giannis", ["giannis", "greek freak"], .hoopers, [
            aspect("euro", .performance, "euro step", [
                "euro step", "eurostep", "greek freak",
            ], "Giannis Antetokounmpo's euro step."),
        ]),
        person("noun-celeb-lillard", "Dame", ["lillard", "damian lillard", "damian", "dame"], .hoopers, [
            aspect("dame-time", .performance, "dame time", [
                "dame time",
            ], "Damian Lillard's dame time."),
        ]),
        person("noun-celeb-westbrook", "Westbrook", ["westbrook", "russ"], .hoopers, [
            aspect("triple-double", .performance, "triple double", [
                "triple double", "triple-double",
            ], "Russell Westbrook's triple-doubles."),
        ]),
        person("noun-celeb-blake-griffin", "Blake", ["blake griffin"], .hoopers, [
            aspect("over-car", .performance, "dunked over a car", [
                "dunked over a car", "jumped over the car", "dunk over the kia",
            ], "Blake Griffin dunked over a car."),
        ]),
        person("noun-celeb-barkley", "Chuck", ["barkley", "charles barkley", "round mound"], .hoopers, [
            aspect("round-mound", .mark, "round mound", [
                "round mound", "not a role model", "i am not a role model",
            ], "Charles Barkley, the round mound of rebound."),
        ]),
        person("noun-celeb-sprewell", "Sprewell", ["sprewell", "latrell"], .hoopers, [
            aspect("coach", .performance, "choked his coach", [
                "choked his coach", "choked the coach", "hands on his coach",
            ], "Latrell Sprewell choked his coach."),
        ]),
        person("noun-celeb-t-mac", "T-Mac", ["t mac", "t-mac", "tracy mcgrady"], .hoopers, [
            aspect("thirty-three", .performance, "13 in 33", [
                "13 points in 33", "13 in 33", "in 33 seconds",
            ], "Tracy McGrady scored 13 points in 33 seconds."),
        ]),
        person("noun-celeb-kg", "KG", ["kg", "kevin garnett", "garnett"], .hoopers, [
            aspect("anything", .performance, "anything is possible", [
                "anything is possible",
            ], "Kevin Garnett's anything is possible."),
        ]),
        person("noun-nba-draymond", "Draymond", ["draymond", "draymond green"], .hoopers, [
            aspect("groin-kick", .mannerism, "kick to the groin", [
                "kicked him in the groin", "kick to the groin", "nut kick",
            ], "Draymond Green kicked a man in the groin."),
        ]),
        person("noun-celeb-ja-morant", "Ja", ["ja morant", "morant"], .hoopers, [
            aspect("between-legs", .performance, "between the legs dunk", [
                "between the legs dunk", "dunked between his legs", "between his legs dunk",
            ], "Ja Morant dunks between his legs."),
        ]),
        person("noun-celeb-kawhi", "Kawhi", ["kawhi", "kawhi leonard", "the claw"], .hoopers, [
            aspect("fun-guy", .mannerism, "fun guy", [
                "fun guy", "i'm a fun guy", "im a fun guy",
            ], "Kawhi Leonard's fun guy line."),
        ]),
        person("noun-celeb-kd", "KD", ["kd", "durant", "kevin durant", "slim reaper"], .hoopers, [
            aspect("slim-reaper", .mark, "slim reaper", [
                "slim reaper",
            ], "Kevin Durant, the slim reaper."),
        ]),
        person("noun-celeb-wilt", "Wilt", ["wilt", "wilt chamberlain"], .hoopers, [
            aspect("hundred", .performance, "100 points", [
                "100 points", "hundred-point game", "100-point game",
            ], "Wilt Chamberlain's 100-point game."),
        ]),
        person("noun-celeb-larry-bird", "Larry", ["larry bird", "larry"], .hoopers, [
            aspect("french-lick", .mark, "french lick", [
                "french lick", "from french lick",
            ], "Larry Bird is from French Lick."),
        ]),
    ]

    private static let athletes: [PersonSignature] = [
        person("noun-celeb-vick", "Vick", ["vick", "michael vick"], .athletes, [
            aspect("scramble", .performance, "scramble", [
                "scramble", "juke", "juked", "juking",
            ], "Michael Vick scrambled out of the pocket."),
            aspect("dog-fight", .moment, "dog fight", [
                "dog fight", "dog fighting", "fought dogs", "fighting dogs", "dogs fighting",
                "put dogs to fight", "put the dogs to fight", "dogs in a fight",
            ], "Michael Vick served time after a dog-fighting conviction."),
        ]),
        person("noun-celeb-odell", "Odell", ["odell", "obj", "odell beckham"], .athletes, [
            aspect("one-hand", .performance, "one-hand catch", [
                "one-hand", "one hand catch", "one-handed", "with one hand",
            ], "Odell Beckham's one-handed catch."),
        ]),
        person("noun-celeb-deion", "Deion", ["deion", "deion sanders", "prime", "primetime"], .athletes, [
            aspect("high-step", .mannerism, "high step", [
                "high step", "high-step", "high stepping", "high-stepping",
            ], "Deion Sanders high-steps into the end zone."),
        ]),
        person("noun-celeb-mike-tyson", "Tyson", ["tyson", "mike tyson", "iron mike"], .athletes, [
            aspect("face-tat", .mark, "face tattoo", [
                "face tat", "face tats", "face tattoo", "tattoo on his face", "tattoo on my face",
            ], "Mike Tyson has a tattoo on his face."),
            aspect("ear-bite", .moment, "bit the ear", [
                "bit his ear", "bit the ear", "bitten ear", "ear bite", "bit holyfield",
            ], "Mike Tyson bit Evander Holyfield's ear in the ring."),
        ]),
        person("noun-celeb-muhammad-ali", "Ali", ["ali", "muhammad ali"], .athletes, [
            aspect("shuffle", .performance, "shuffle", [
                "ali shuffle", "the shuffle",
            ], "Muhammad Ali's shuffle."),
            aspect("float", .performance, "float like a butterfly", [
                "float like a butterfly", "rope a dope", "rope-a-dope",
            ], "Muhammad Ali's shuffle and rope-a-dope."),
        ]),
        person("noun-celeb-mayweather", "Floyd", ["floyd", "mayweather", "floyd mayweather", "money may", "pretty boy"], .athletes, [
            aspect("count-money", .mannerism, "counting the money", [
                "counting the money", "counted the money", "counting the cash", "flashed the cash", "flash the cash",
            ], "Floyd Mayweather counts money in the ring."),
        ]),
        person("noun-celeb-cam-newton", "Cam", ["cam newton"], .athletes, [
            aspect("dab", .performance, "the dab", [
                "dabbed", "hit the dab", "the dab",
            ], "Cam Newton dabbed in the end zone."),
        ]),
        person("noun-celeb-marshawn", "Marshawn", ["marshawn", "marshawn lynch", "lynch", "beast mode"], .athletes, [
            aspect("skittles", .mannerism, "skittles", [
                "eating skittles", "skittles on the sideline", "bag of skittles", "beast mode",
            ], "Marshawn Lynch ate Skittles on the sideline."),
        ]),
        person("noun-celeb-kaepernick", "Kap", ["kaepernick", "kap", "colin kaepernick"], .athletes, [
            aspect("knee", .performance, "took a knee", [
                "took a knee", "knelt for the anthem", "knee for the anthem",
            ], "Colin Kaepernick knelt during the anthem."),
        ]),
        person("noun-celeb-randy-moss", "Moss", ["randy moss", "moss"], .athletes, [
            aspect("fake-spike", .mannerism, "fake spike", [
                "fake spike", "faked the spike",
            ], "Randy Moss faked the spike."),
        ]),
        person("noun-celeb-ray-lewis", "Ray", ["ray lewis"], .athletes, [
            aspect("squirrel", .performance, "squirrel dance", [
                "squirrel dance", "dance in the tunnel",
            ], "Ray Lewis dances out of the tunnel."),
        ]),
        person("noun-celeb-brady", "Brady", ["brady", "tom brady"], .athletes, [
            aspect("tuck-rule", .performance, "tuck rule", [
                "tuck rule",
            ], "Tom Brady and the tuck rule."),
        ]),
        person("noun-celeb-mahomes", "Mahomes", ["mahomes", "patrick mahomes"], .athletes, [
            aspect("no-look-throw", .performance, "behind the back throw", [
                "behind the back throw", "no look throw", "no-look throw",
            ], "Patrick Mahomes throws behind his back."),
        ]),
        person("noun-celeb-ochocinco", "Ocho", ["ochocinco", "chad johnson"], .athletes, [
            aspect("proposal", .performance, "proposed to a cheerleader", [
                "proposed to a cheerleader", "proposed on the field",
            ], "Chad Johnson proposed to a cheerleader."),
        ]),
        person("noun-celeb-usain", "Bolt", ["usain", "usain bolt"], .athletes, [
            aspect("lightning-pose", .mannerism, "lightning bolt pose", [
                "lightning bolt pose", "the bolt pose",
            ], "Usain Bolt's lightning pose."),
        ]),
        person("noun-celeb-tiger-woods", "Tiger", ["tiger woods", "tiger"], .athletes, [
            aspect("fist-pump", .mannerism, "fist pump", [
                "fist pump", "fist pumped", "sunday red",
            ], "Tiger Woods fist-pumps in a red shirt."),
        ]),
        person("noun-celeb-serena", "Serena", ["serena", "serena williams"], .athletes, [
            aspect("grunt", .mannerism, "serve grunt", [
                "grunted on the serve", "serve grunt", "grunted through the serve",
            ], "Serena Williams grunts on the serve."),
        ]),
        person("noun-celeb-bruce-lee", "Bruce", ["bruce lee"], .athletes, [
            aspect("nunchucks", .performance, "nunchucks", [
                "nunchucks", "nunchaku", "one inch punch", "one-inch punch",
            ], "Bruce Lee and nunchucks."),
        ]),
        person("noun-celeb-ric-flair", "Flair", ["ric flair", "nature boy"], .athletes, [
            aspect("woooo", .mannerism, "wooooo", [
                "wooooo", "stylin and profilin", "stylin' and profilin",
            ], "Ric Flair's woo and the robe."),
        ]),
        person("noun-celeb-steve-austin", "Stone Cold", ["stone cold", "steve austin", "stone cold steve austin"], .athletes, [
            aspect("stunner", .performance, "stunner", [
                "stone cold stunner", "beer smash", "smashed a beer",
            ], "Stone Cold Steve Austin's stunner and the beer smash."),
        ]),
        person("noun-celeb-undertaker", "Taker", ["undertaker", "the deadman"], .athletes, [
            aspect("throat-gesture", .mannerism, "thumb across his throat", [
                "thumb across his throat", "deadman walk",
            ], "The Undertaker draws a thumb across his throat."),
        ]),
        person("noun-celeb-hogan", "Hogan", ["hogan", "hulk hogan", "hulkster"], .athletes, [
            aspect("hulkamania", .performance, "hulkamania", [
                "hulkamania", "cupped his ear",
            ], "Hulk Hogan cups his ear."),
        ]),
        person("noun-celeb-john-cena", "Cena", ["john cena", "cena"], .athletes, [
            aspect("cant-see-me", .mannerism, "you can't see me", [
                "you can't see me", "you cant see me",
            ], "John Cena's you can't see me."),
        ]),
        person("noun-celeb-mcgregor", "Conor", ["mcgregor", "conor", "conor mcgregor", "the notorious"], .athletes, [
            aspect("weigh-in", .performance, "weigh-in", [
                "shirtless weigh-in", "at the weigh-in", "proper twelve",
            ], "Conor McGregor at the weigh-in."),
        ]),
        person("noun-celeb-phelps", "Phelps", ["phelps", "michael phelps"], .athletes, [
            aspect("eight-golds", .mark, "eight golds", [
                "eight golds", "eight gold medals",
            ], "Michael Phelps and eight gold medals."),
        ]),
        person("noun-celeb-oj", "OJ", ["oj simpson", "o.j."], .athletes, [
            aspect("bronco", .performance, "white bronco", [
                "white bronco", "the white bronco", "if the glove doesn't fit", "you must acquit",
            ], "O.J. Simpson's white Bronco chase."),
        ]),
        person("noun-celeb-ray-allen", "Ray Allen", ["ray allen"], .athletes, [
            aspect("he-got-game", .title, "he got game", ["he got game"], "Ray Allen and the film He Got Game."),
        ]),
        person("noun-celeb-klay", "Klay", ["klay", "klay thompson"], .athletes, [
            aspect("fourteen-threes", .performance, "fourteen threes", ["fourteen threes", "14 threes"], "Klay Thompson's fourteen threes."),
        ]),
        person("noun-celeb-cp3", "CP3", ["cp3", "chris paul", "point god"], .athletes, [
            aspect("lob-city", .performance, "lob city", ["lob city"], "Chris Paul's lob city."),
        ]),
        person("noun-celeb-d-wade", "Wade", ["d wade", "dwyane wade", "dwyane"], .athletes, [
            aspect("this-is-my-house", .performance, "this is my house", ["this is my house"], "Dwyane Wade's this is my house."),
        ]),
        person("noun-celeb-tim-duncan", "Duncan", ["tim duncan", "duncan", "big fundamental"], .athletes, [
            aspect("big-fundamental", .mannerism, "big fundamental", ["big fundamental", "the big fundamental"], "Tim Duncan, the big fundamental."),
        ]),
        person("noun-celeb-jimmy-butler", "Jimmy", ["jimmy butler", "playoff jimmy"], .athletes, [
            aspect("playoff-jimmy", .mannerism, "playoff jimmy", ["playoff jimmy", "himmy"], "Jimmy Butler in the playoffs."),
        ]),
        person("noun-celeb-pacquiao", "Pacman", ["pacquiao", "manny pacquiao", "pacman"], .athletes, [
            aspect("pacman", .mannerism, "pacman", ["pacman"], "Manny Pacquiao, Pacman."),
        ]),
        person("noun-celeb-peyton", "Peyton", ["peyton", "peyton manning"], .athletes, [
            aspect("omaha", .mannerism, "omaha", ["omaha"], "Peyton Manning's Omaha cadence."),
        ]),
        person("noun-celeb-bo-jackson", "Bo", ["bo jackson"], .athletes, [
            aspect("bo-knows", .mannerism, "bo knows", ["bo knows"], "Bo Jackson, Bo knows."),
        ]),
        person("noun-celeb-walter-payton", "Payton", ["walter payton", "payton", "sweetness"], .athletes, [
            aspect("sweetness", .mannerism, "sweetness", ["sweetness"], "Walter Payton, Sweetness."),
        ]),
        person("noun-celeb-tebow", "Tebow", ["tebow", "tim tebow"], .athletes, [
            aspect("tebowing", .mannerism, "tebowing", ["tebowing", "tebowed"], "Tim Tebow kneeling in the end zone."),
        ]),
        person("noun-celeb-tyreek", "Cheetah", ["tyreek", "tyreek hill", "cheetah"], .athletes, [
            aspect("cheetah-speed", .mannerism, "cheetah speed", ["cheetah speed"], "Tyreek Hill, the cheetah."),
        ]),
        person("noun-celeb-lamar-jackson", "Lamar", ["lamar jackson"], .athletes, [
            aspect("running-back", .mannerism, "not bad for a running back", ["not bad for a running back"], "Lamar Jackson's not bad for a running back."),
        ]),
        person("noun-celeb-jerry-rice", "Rice", ["jerry rice"], .athletes, [
            aspect("stickum", .mark, "stickum", ["stickum"], "Jerry Rice and stickum."),
        ]),
        person("noun-celeb-luka", "Luka", ["luka doncic"], .athletes, [
            aspect("luka-magic", .mannerism, "luka magic", ["luka magic"], "Luka Doncic, Luka Magic."),
        ]),
        person("noun-celeb-jokic", "Jokic", ["jokic", "nikola jokic"], .athletes, [
            aspect("big-honey", .mannerism, "big honey", ["big honey"], "Nikola Jokic, Big Honey."),
        ]),
        person("noun-celeb-trae-young", "Trae", ["trae young"], .athletes, [
            aspect("ice-trae", .mannerism, "ice trae", ["ice trae"], "Trae Young, Ice Trae."),
        ]),
        person("noun-nba-zion", "Zion", ["zion", "zion williamson"], .athletes, [
            aspect("freight-train", .mannerism, "freight train", ["freight train"], "Zion Williamson, the freight train. Bare freight train stays off."),
            aspect("shoe-blowout", .moment, "shoe exploded", [
                "shoe exploded", "shoe blew out", "shoe blew up",
            ], "Zion Williamson's shoe blew out on the court."),
        ]),
        person("noun-celeb-rondo", "Rondo", ["rajon rondo"], .athletes, [
            aspect("playoff-rondo", .mannerism, "playoff rondo", ["playoff rondo"], "Rajon Rondo in the playoffs."),
        ]),
        person("noun-celeb-aaron-rodgers", "Rodgers", ["aaron rodgers", "rodgers"], .athletes, [
            aspect("double-check", .mannerism, "discount double check", ["discount double check"], "Aaron Rodgers' discount double check."),
            aspect("hail-mary", .performance, "hail mary", ["hail mary"], "Aaron Rodgers' hail mary, and Tupac's song of the same name."),
        ]),
        person("noun-celeb-kelce", "Kelce", ["travis kelce", "kelce"], .athletes, [
            aspect("new-heights", .title, "new heights", ["new heights"], "Travis Kelce, New Heights."),
        ]),
        person("noun-celeb-favre", "Favre", ["brett favre", "favre"], .athletes, [
            aspect("gunslinger", .mannerism, "gunslinger", ["gunslinger"], "Brett Favre, the gunslinger. Bare gunslinger stays off."),
            aspect("across-body", .moment, "across his body", [
                "threw it across his body",
            ], "Brett Favre threw across his body."),
        ]),
        person("noun-celeb-brees", "Brees", ["drew brees", "brees"], .athletes, [
            aspect("who-dat", .mannerism, "who dat", ["who dat"], "Drew Brees and the who dat chant."),
        ]),
        person("noun-boxing-wilder", "Wilder", ["deontay wilder", "wilder"], .athletes, [
            aspect("bronze-bomber", .mannerism, "bronze bomber", ["bronze bomber"], "Deontay Wilder, the bronze bomber."),
        ]),
        person("noun-celeb-foreman", "Foreman", ["george foreman"], .athletes, [
            aspect("foreman-grill", .mark, "foreman grill", ["foreman grill"], "George Foreman's grill."),
        ]),
        person("noun-celeb-holyfield", "Holyfield", ["evander holyfield", "holyfield"], .athletes, [
            aspect("real-deal", .mannerism, "the real deal", ["the real deal"], "Evander Holyfield, the real deal. Bare the real deal stays off."),
            aspect("ear-bite", .moment, "bit the ear", [
                "bit his ear", "bit the ear", "ear bite",
            ], "Evander Holyfield's ear, the same moment as Tyson."),
        ]),
        person("noun-celeb-de-la-hoya", "De La Hoya", ["de la hoya", "oscar de la hoya"], .athletes, [
            aspect("golden-boy", .mannerism, "golden boy", ["golden boy"], "Oscar De La Hoya, the golden boy."),
        ]),
    ]

    private static let celebs: [PersonSignature] = [
        person("noun-celeb-michael-jackson", "Jackson", ["michael jackson", "jackson", "king of pop"], .celebs, [
            aspect("moonwalk", .performance, "moonwalk", [
                "moonwalk", "moon walk", "moonwalked",
            ], "Michael Jackson moonwalks."),
            aspect("one-glove", .mark, "one glove", [
                "one glove", "white glove", "single glove",
            ], "Michael Jackson wears one glove."),
            aspect("billie-jean", .title, "billie jean", ["billie jean"], "Michael Jackson song Billie Jean."),
            aspect("beat-it", .title, "beat it", ["beat it"], "Michael Jackson song Beat It."),
            aspect("thriller", .title, "thriller", ["thriller"], "Michael Jackson song Thriller."),
            aspect("smooth-criminal", .title, "smooth criminal", ["smooth criminal"], "Michael Jackson song Smooth Criminal."),
            aspect("man-in-the-mirror", .title, "man in the mirror", ["man in the mirror"], "Michael Jackson song Man in the Mirror."),
            aspect("black-or-white", .title, "black or white", ["black or white"], "Michael Jackson song Black or White."),
            aspect("remember-the-time", .title, "remember the time", ["remember the time"], "Michael Jackson song Remember the Time."),
            aspect("rock-with-you", .title, "rock with you", ["rock with you"], "Michael Jackson song Rock with You."),
        ]),
        person("noun-celeb-marilyn", "Marilyn", ["marilyn", "marilyn monroe"], .celebs, [
            aspect("beauty-mark", .mark, "beauty mark", [
                "beauty mark", "beauty mole",
            ], "Marilyn Monroe's beauty mark."),
            aspect("grate", .performance, "subway grate", [
                "subway grate", "over the grate", "dress over the grate",
            ], "Marilyn Monroe's white dress over the subway grate."),
        ]),
        person("noun-celeb-the-rock", "The Rock", ["the rock", "dwayne johnson", "dwayne"], .celebs, [
            aspect("eyebrow", .mannerism, "eyebrow", [
                "eyebrow", "eyebrows",
            ], "Dwayne Johnson raises an eyebrow."),
        ]),
        person("noun-celeb-elvis", "Elvis", ["elvis", "elvis presley"], .celebs, [
            aspect("hip-shake", .performance, "hip shake", [
                "hip shake", "shook his hips", "shook her hips",
            ], "Elvis Presley shakes his hips."),
            aspect("lip-curl", .mannerism, "lip curl", [
                "lip curl", "curled his lip", "curled her lip",
            ], "Elvis Presley curls his lip."),
            aspect("jailhouse", .title, "jailhouse rock", ["jailhouse rock"], "Elvis Presley song Jailhouse Rock."),
            aspect("blue-suede", .title, "blue suede shoes", ["blue suede shoes"], "Elvis Presley song Blue Suede Shoes."),
            aspect("cant-help-falling", .title, "can't help falling in love", [
                "can't help falling in love", "cant help falling in love",
            ], "Elvis Presley song Can't Help Falling in Love."),
            aspect("suspicious-minds", .title, "suspicious minds", ["suspicious minds"], "Elvis Presley song Suspicious Minds."),
            aspect("hound-dog", .title, "hound dog", ["hound dog"], "Elvis Presley song Hound Dog."),
        ]),
        person("noun-celeb-oprah", "Oprah", ["oprah"], .celebs, [
            aspect("you-get-a-car", .performance, "you get a car", [
                "you get a car", "and you get a car",
            ], "Oprah giving away cars."),
        ]),
        person("noun-celeb-obama", "Obama", ["obama", "barack"], .celebs, [
            aspect("yes-we-can", .performance, "yes we can", [
                "yes we can", "the tan suit", "hope poster",
            ], "Barack Obama's yes we can and the tan suit."),
        ]),
        person("noun-celeb-trump", "Trump", ["trump", "donald trump"], .celebs, [
            aspect("combover", .mark, "combover", [
                "combover", "the combover", "long red tie",
            ], "Donald Trump's combover and the long red tie."),
        ]),
        person("noun-celeb-kim-k", "Kim", ["kim k", "kim kardashian"], .celebs, [
            aspect("sex-tape", .mark, "sex tape", [
                "sex tape", "the leaked tape",
            ], "Kim Kardashian's leaked tape."),
        ]),
        person("noun-celeb-kylie", "Kylie", ["kylie", "kylie jenner"], .celebs, [
            aspect("lip-kit", .mark, "lip kit", [
                "lip kit", "lip challenge",
            ], "Kylie Jenner's lip kit."),
        ]),
        person("noun-celeb-denzel", "Denzel", ["denzel", "denzel washington"], .celebs, [
            aspect("king-kong", .performance, "king kong ain't got", [
                "king kong ain't got", "king kong aint got",
            ], "Denzel Washington in Training Day."),
        ]),
        person("noun-celeb-de-niro", "De Niro", ["de niro", "robert de niro"], .celebs, [
            aspect("talkin-to-me", .performance, "you talkin to me", [
                "you talkin to me", "you talkin' to me",
            ], "Robert De Niro's you talkin to me."),
        ]),
        person("noun-celeb-tom-cruise", "Cruise", ["tom cruise"], .celebs, [
            aspect("couch", .mannerism, "couch jump", [
                "jumped on the couch", "couch jump", "jumped on oprah",
            ], "Tom Cruise jumped on Oprah's couch."),
        ]),
        person("noun-celeb-will-smith", "Will", ["will smith", "fresh prince"], .celebs, [
            aspect("oscars-slap", .mannerism, "oscars slap", [
                "oscars slap", "slapped him at the oscars",
            ], "Will Smith slapped Chris Rock at the Oscars."),
        ]),
        person("noun-celeb-maury", "Maury", ["maury", "maury povich"], .celebs, [
            aspect("not-the-father", .performance, "not the father", [
                "you are not the father", "not the father", "the lie detector",
            ], "Maury Povich and the paternity reveal."),
        ]),
        person("noun-celeb-springer", "Springer", ["jerry springer", "springer"], .celebs, [
            aspect("chair", .mannerism, "threw a chair", [
                "threw a chair", "threw the chair",
            ], "Jerry Springer guests throw chairs."),
        ]),
        person("noun-celeb-paris-hilton", "Paris", ["paris hilton"], .celebs, [
            aspect("thats-hot", .mannerism, "that's hot", [
                "that's hot", "thats hot",
            ], "Paris Hilton's that's hot."),
        ]),
        person("noun-celeb-escobar", "Escobar", ["escobar", "pablo"], .celebs, [
            aspect("plata", .performance, "plata o plomo", [
                "plata o plomo", "silver or lead", "the hippos", "hippos in the",
            ], "Pablo Escobar's plata o plomo and the hippos."),
        ]),
        person("noun-celeb-chapo", "Chapo", ["chapo", "el chapo"], .celebs, [
            aspect("tunnel", .performance, "escaped through a tunnel", [
                "escaped through a tunnel", "escaped in a tunnel", "tunnel under the shower",
            ], "El Chapo escaped through a tunnel."),
        ]),
    ]
}
