import Foundation

/// One picture a rapper might use — not a synonym list.
/// Bar Hits uses these to find “glass half empty” next to “jet fuel low”
/// when the writer is really talking about running out.
struct MetaphorPrototype: Equatable, Sendable, Identifiable {
    var id: String
    var label: String
    /// Short sentence the embedding compares against.
    var picture: String
    /// Extra FTS seeds so lexical search reaches the same idea.
    var ftsTerms: [String]
}

enum MetaphorPrototypeCatalog: Sendable {
    static let all: [MetaphorPrototype] = prototypes

    static func prototype(id: String) -> MetaphorPrototype? {
        byID[id]
    }

    private static let byID: [String: MetaphorPrototype] = {
        Dictionary(uniqueKeysWithValues: prototypes.map { ($0.id, $0) })
    }()

    private static let prototypes: [MetaphorPrototype] = [
        MetaphorPrototype(
            id: "scarcity",
            label: "scarcity",
            picture: "the glass is half empty, last drop in the tank, jet fuel running low, pockets on empty, last mill in the bowl",
            ftsTerms: [
                "broke", "empty", "bowl", "mill", "mills", "hungry", "starving", "fuel", "tank",
                "glass", "half", "low", "pockets", "owe", "debt", "ramen", "evict", "rent",
                "sputter", "dry", "last", "fumes", "nothing", "zero", "crumbs", "nickel",
            ]
        ),
        MetaphorPrototype(
            id: "luxury",
            label: "luxury",
            picture: "ice on the neck, foreign parked outside, penthouse glass, private jet, champagne rain",
            ftsTerms: [
                "ice", "chain", "diamonds", "foreign", "penthouse", "jet", "champagne", "vvs",
                "patek", "rolls", "yacht", "marble", "mink", "cuban", "flooded", "bezel",
            ]
        ),
        MetaphorPrototype(
            id: "persistence",
            label: "persistence",
            picture: "keep climbing with no rope, engine still running after the crash, one more round",
            ftsTerms: [
                "climb", "grind", "engine", "round", "again", "survive", "hustle", "never",
                "quit", "push", "uphill", "marathon", "last", "stand", "fight",
            ]
        ),
        MetaphorPrototype(
            id: "aviation",
            label: "aviation",
            picture: "jet fuel low, plane on fumes, altitude drop, runway lights, takeoff in the fog",
            ftsTerms: [
                "jet", "fuel", "plane", "runway", "altitude", "turbulence", "pilot", "wing",
                "fumes", "takeoff", "landing", "cabin", "cockpit", "airport", "flight", "clouds",
            ]
        ),
        MetaphorPrototype(
            id: "machinery",
            label: "machinery",
            picture: "machine sputtering, gears grinding, engine knocking, factory lights still on",
            ftsTerms: [
                "machine", "engine", "gear", "sputter", "knock", "factory", "motor", "piston",
                "wrench", "bolt", "rust", "oil", "spark", "wire", "circuit",
            ]
        ),
        MetaphorPrototype(
            id: "weather",
            label: "weather",
            picture: "storm in the chest, drought in the city, sun finally out after the flood",
            ftsTerms: [
                "storm", "rain", "flood", "drought", "thunder", "cloud", "sun", "snow",
                "wind", "lightning", "hurricane", "fog", "cold", "heat",
            ]
        ),
        MetaphorPrototype(
            id: "vehicles",
            label: "vehicles",
            picture: "gas light on, engine cut out on the highway, wheels still spinning in the mud",
            ftsTerms: [
                "gas", "highway", "wheels", "whip", "coupe", "truck", "benz", "rari",
                "hellcat", "engine", "brake", "crash", "lane", "dash",
            ]
        ),
        MetaphorPrototype(
            id: "jewelry",
            label: "jewelry",
            picture: "stones so loud they talk, flooded bezel, ice making you blink",
            ftsTerms: [
                "ice", "stones", "bezel", "vvs", "diamond", "chain", "pendant", "tennis",
                "flooded", "sparkle", "blink", "shine", "grill",
            ]
        ),
        MetaphorPrototype(
            id: "appetite",
            label: "appetite",
            picture: "empty plate, fridge light on nothing, last sip in the glass, starving at the table",
            ftsTerms: [
                "plate", "fridge", "hungry", "starving", "sip", "glass", "bowl", "crumb",
                "dinner", "food", "stomach", "appetite", "thirst",
            ]
        ),
        MetaphorPrototype(
            id: "time",
            label: "time",
            picture: "clock running out, hourglass empty, last seconds on the shot clock",
            ftsTerms: [
                "clock", "hourglass", "seconds", "time", "late", "early", "yesterday",
                "tomorrow", "aging", "young", "old", "minute", "hour",
            ]
        ),
        MetaphorPrototype(
            id: "family",
            label: "family",
            picture: "mama on the porch, little brother watching, last name on the back",
            ftsTerms: [
                "mama", "mom", "dad", "brother", "sister", "family", "son", "daughter",
                "blood", "kin", "home", "porch",
            ]
        ),
        MetaphorPrototype(
            id: "war",
            label: "war",
            picture: "trenches still wet, armor on in the kitchen, bullets in the mailbox",
            ftsTerms: [
                "war", "trench", "armor", "bullet", "soldier", "battle", "enemy", "opp",
                "slide", "gun", "drill", "vest", "ammo",
            ]
        ),
        MetaphorPrototype(
            id: "love",
            label: "love",
            picture: "heart in my hands, her name in the mist, empty passenger seat",
            ftsTerms: [
                "love", "heart", "baby", "girl", "miss", "kiss", "faithful", "her",
                "passenger", "lonely", "together",
            ]
        ),
        MetaphorPrototype(
            id: "distance",
            label: "distance",
            picture: "walking out the door, phone on silent, ghost in the hallway",
            ftsTerms: [
                "leave", "gone", "left", "ghost", "ignore", "door", "silent", "away",
                "move", "distance", "fade",
            ]
        ),
        MetaphorPrototype(
            id: "loyalty",
            label: "loyalty",
            picture: "same dogs from the block, inner circle closed, brother from another",
            ftsTerms: [
                "bro", "homie", "dawg", "gang", "family", "circle", "loyal", "ride",
                "block", "day one", "dayone",
            ]
        ),
        MetaphorPrototype(
            id: "religion",
            label: "religion",
            picture: "praying on the floor, heaven closed the gate, devil in the details",
            ftsTerms: [
                "pray", "heaven", "hell", "god", "devil", "angel", "church", "sin",
                "bless", "faith", "soul",
            ]
        ),
        MetaphorPrototype(
            id: "sports",
            label: "sports",
            picture: "fourth quarter down, shot clock at one, rings on every finger",
            ftsTerms: [
                "quarter", "clock", "ring", "championship", "court", "field", "game",
                "score", "coach", "team", "win", "loss",
            ]
        ),
        MetaphorPrototype(
            id: "flex",
            label: "flex",
            picture: "money raining, paid the check in cash, bands falling out the bag",
            ftsTerms: [
                "money", "cash", "bands", "racks", "paid", "rich", "check", "bag",
                "count", "safe", "million",
            ]
        ),
    ]
}
