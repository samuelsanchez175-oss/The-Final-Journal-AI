import Foundation

/// Chips that belong together inside one noun tab.
/// The sheet hides the title when a tab has only one group.
struct NounChipSection: Equatable, Identifiable, Sendable {
    let title: String
    let words: [String]
    var id: String { title }
}

/// Display order for a noun tab. Who is on the tab stays in `NounBankStore`.
enum NounBankSections {
    static func sections(for category: NounBankCategory) -> [NounChipSection] {
        switch category {
        case .liquors:
            return [
                NounChipSection(title: "Cognac", words: [
                    "Henny", "Rémy", "D'USSÉ", "Louis XIII",
                    "Yak", "Cognac", "VSOP", "Xo",
                    "Henny Lean",
                ]),
                NounChipSection(title: "Champagne", words: [
                    "Ace of Spades", "Dom P", "Cristal", "Moët",
                    "Nuvo", "Belaire", "Champagne", "Champagne Rose",
                ]),
                NounChipSection(title: "Tequila", words: [
                    "Don Julio", "Clase Azul", "1942", "Casamigos",
                    "Patron", "Tequila", "1800",
                ]),
                NounChipSection(title: "Vodka", words: [
                    "Cîroc", "Grey Goose", "Belvedere", "Vodka",
                    "Absolut", "Peach Cîroc",
                ]),
                NounChipSection(title: "Whiskey", words: [
                    "Whiskey", "Bourbon",
                ]),
            ]
        case .syrups:
            return [
                NounChipSection(title: "The drink", words: [
                    "lean", "purple drank", "dirty sprite", "codeine daiquiri",
                    "codeine", "promethazine", "sizzurp", "robitussin",
                    "prometh", "codeine ecstasy", "codeine kills", "lean green",
                    "lean shawty", "lean weed", "codeine cowboy", "codeine syrup",
                    "codeine withdrawals", "lean cuisine", "codeine dreams", "lean molly",
                    "pint of lean", "sprite",
                ]),
                NounChipSection(title: "The brands", words: [
                    "Wockhardt", "Better Wock", "Actavis", "Hi-Tech",
                    "wock", "qualitest", "tech pints",
                ]),
                NounChipSection(title: "The cup", words: [
                    "double cup", "styrofoam cup", "styrofoam", "deuce",
                    "codeine cups", "deuce deuces", "styrofoam pluto", "cup stuffed",
                    "cup muddy", "deuce bigalow",
                ]),
            ]
        case .drugs:
            return [
                NounChipSection(title: "Percs", words: [
                    "perc", "perc 30", "perky", "percs",
                    "percy", "perc 10's", "perky check", "molly percocets",
                    "percocet mollies", "M box", "roxy", "roxies",
                    "xbox",
                ]),
                NounChipSection(title: "Xanax", words: [
                    "xanny bar", "xanax", "xanny", "xans",
                ]),
                NounChipSection(title: "Addys", words: [
                    "addy", "adderall", "adderall thirty", "addy birkin",
                ]),
                NounChipSection(title: "Molly", words: [
                    "molly water", "molly", "ecstasy", "molly shawty",
                    "bean", "bean green", "bean money",
                ]),
                NounChipSection(title: "Weed", words: [
                    "gas pack", "loud pack", "OG kush", "zaza",
                    "runtz", "gelato", "backwood", "exotic",
                    "cookies", "za", "kush", "exotic packs",
                    "kush weed", "gelato biscotti", "kush sticky", "kush purple",
                    "kush lean", "blunt", "swisher",
                ]),
                NounChipSection(title: "Cocaine", words: [
                    "fishscale", "white girl", "yayo",
                ]),
                NounChipSection(title: "Pills and powder", words: [
                    "shroom", "shrooms", "fetty", "fentanyl",
                    "oxy", "acid", "oxy codeine",
                ]),
                NounChipSection(title: "The gear", words: [
                    "bong", "lighter", "scale",
                ]),
            ]
        case .jewelry:
            return [
                NounChipSection(title: "Chains", words: [
                    "Cuban link", "bust down Cuban", "tennis chain", "Bustdown",
                ]),
                NounChipSection(title: "Watches", words: [
                    "flooded Patek", "iced out AP", "plain Jane Rollie", "rose Sky-Dweller",
                    "Patek", "Rollie", "Presidential", "AP",
                    "Hublot", "Offshore", "Daytona",
                ]),
                NounChipSection(title: "Stones", words: [
                    "VVS pointers", "VVS", "Flooded", "Pointers",
                    "Baguette", "Vs1",
                ]),
                NounChipSection(title: "Pieces", words: [
                    "tennis bracelet", "flooded belt buckle", "Cartier frames", "Jesus piece",
                    "100k bezel", "Cartier", "Bezel", "Pendant",
                    "Cross", "pinky ring", "earrings", "charm",
                    "necklace", "bracelet",
                ]),
                NounChipSection(title: "Grills", words: [
                    "Grillz", "Honeycomb", "Gangsta Grillz",
                ]),
            ]
        case .jewelers:
            return [
                NounChipSection(title: "Jewelers", words: [
                    "Johnny Dang", "Eliantte", "Icebox", "Avianne",
                    "Ben Baller", "Jacob the Jeweler", "Lorraine Schwartz", "Alex Moss",
                    "Chopard", "David Yurman", "Harry Winston", "Jason of Beverly Hills",
                ]),
            ]
        case .brands:
            return [
                NounChipSection(title: "Louis Vuitton", words: [
                    "Damier buckle", "Damier print", "woodgrain Damier", "Louis pouch",
                    "Louis leather vest", "Louis V", "Louis bag", "Louis belt",
                    "Louis luggage", "Louis shoes", "Louis loafers", "Louis scarf",
                    "Louis coat",
                ]),
                NounChipSection(title: "Gucci", words: [
                    "Gucci bag", "Gucci belt", "Gucci socks", "Gucci slides",
                    "Gucci sweater", "Gucci", "Gucci Shirt", "Gucci Store",
                ]),
                NounChipSection(title: "Off-White", words: [
                    "Off-White fur", "Off-White", "Off-White coat", "Virgil",
                ]),
                NounChipSection(title: "Chrome Hearts", words: [
                    "Chrome Heart skinnies", "Chrome Hearts", "Chrome Heart glasses", "Chrome Hearts jeans",
                ]),
                NounChipSection(title: "YSL", words: [
                    "YSL", "YSL jeans",
                ]),
                NounChipSection(title: "Goyard", words: [
                    "Goyard", "Goyard backpack", "Goyard duffle", "Goyard bag",
                ]),
                NounChipSection(title: "Amiri", words: [
                    "Amiri jeans", "Amiri denim", "Amiri pants", "Amiri",
                ]),
                NounChipSection(title: "Palm Angels", words: [
                    "Palm Angels", "Palm Angels sweater",
                ]),
                NounChipSection(title: "Rick Owens", words: [
                    "Rick Owens", "Rick Owens denims",
                ]),
                NounChipSection(title: "Fear of God", words: [
                    "Fear of God", "Fear of God pants", "Essentials",
                ]),
                NounChipSection(title: "Chanel", words: [
                    "Chanel bag", "Chanel",
                ]),
                NounChipSection(title: "Prada", words: [
                    "Prada bag", "Prada",
                ]),
                NounChipSection(title: "Dior", words: [
                    "Dior",
                ]),
                NounChipSection(title: "Versace", words: [
                    "Versace shades", "Versace",
                ]),
                NounChipSection(title: "Fendi", words: [
                    "Fendi bag", "Fendi",
                ]),
                NounChipSection(title: "Balenciaga", words: [
                    "Balenciaga boots", "Balenciaga", "Triple S", "BB belt",
                ]),
                NounChipSection(title: "Hermes", words: [
                    "Birkin", "Hermes",
                ]),
                NounChipSection(title: "Givenchy", words: [
                    "Givenchy",
                ]),
                NounChipSection(title: "Margiela", words: [
                    "Margiela",
                ]),
                NounChipSection(title: "Balmain", words: [
                    "Balmain",
                ]),
                NounChipSection(title: "Celine", words: [
                    "Celine",
                ]),
                NounChipSection(title: "Bottega", words: [
                    "Bottega",
                ]),
                NounChipSection(title: "Shoes", words: [
                    "Loubs", "red bottoms", "Nike", "Adidas",
                    "Jordan", "New Balance", "Converse", "Vans",
                    "Reebok", "Puma", "Golden Goose", "Bapesta",
                    "Force 1", "Yeezy", "Crocs", "Uggs",
                    "Timberland",
                ]),
                NounChipSection(title: "Jewelry houses", words: [
                    "Tiffany", "Van Cleef", "Bvlgari",
                ]),
                NounChipSection(title: "Tech", words: [
                    "Samsung", "MacBook", "iPad", "Sony",
                    "iPhone",
                ]),
                NounChipSection(title: "Streetwear", words: [
                    "Heron Preston", "Telfar", "Sp5der", "Denim Tears",
                    "Ksubi", "Evisu", "Rhude", "Corteiz",
                    "CDG", "Raf Simons", "Helmut Lang", "Alyx",
                    "Ed Hardy", "Sean John", "Pelle Pelle", "FUBU",
                    "Dickies", "Levi's", "Carhartt", "Stussy",
                    "Kith", "Golf Wang", "Cactus Jack", "Human Made",
                    "Casablanca", "Kapital", "Robin jeans", "Yohji",
                    "Thom Browne", "Le Fleur", "Who Decides War", "Truey",
                    "Vlone", "Supreme", "Bape", "Vetements",
                    "Coogi", "Apple Bottom", "Ray-Bans",
                ]),
                NounChipSection(title: "Other houses", words: [
                    "Tom Ford", "Canada Goose", "Moschino", "Kenzo",
                    "Loewe", "Issey Miyake", "Michael Kors", "Fashion Nova",
                    "Skims", "Lululemon", "MCM", "North Face",
                    "Ferragamo", "man bag", "Moncler", "Marni",
                    "Alexander Mcqueen", "John Deere",
                ]),
            ]
        case .clothing:
            return [
                NounChipSection(title: "Head", words: [
                    "ski mask", "sheisty", "wave cap", "fitted cap", "bandana",
                    "durag", "shades", "beanie", "snapback",
                    "bucket hat", "kufi", "beret", "fedora",
                    "cowboy hat", "turban",
                ]),
                NounChipSection(title: "Tops", words: [
                    "hoodie", "t-shirt", "tank top", "sweater",
                    "sweatshirt", "flannel", "button up", "blouse",
                    "crop top", "tube top", "turtleneck", "cardigan",
                    "jersey", "dashiki",
                ]),
                NounChipSection(title: "Outerwear", words: [
                    "mink", "chinchilla", "white mink", "sable",
                    "trench", "Louis V trench", "burberry trench", "leatherman trench",
                    "bomber", "Gucci bomber", "puffer", "parka",
                    "leather jacket", "peacoat", "fur coat", "windbreaker",
                    "raincoat", "blazer",
                ]),
                NounChipSection(title: "Bottoms", words: [
                    "rockstar jeans", "joggers", "shorts", "jeans",
                    "skirt", "leggings", "sweats", "cargos",
                    "overalls", "khakis", "slacks",
                ]),
                NounChipSection(title: "Shoes", words: [
                    "Foamposites", "timbs", "dunks", "Amiri timbs",
                    "wheat timbs", "heels", "sneakers", "boots",
                    "slides", "sandals", "cleats", "loafers",
                    "flip flops", "stilettos", "slippers", "air max",
                ]),
                NounChipSection(title: "Sets", words: [
                    "leotard", "tracksuit", "scrubs", "uniform",
                    "apron", "pajamas", "camo", "fatigues",
                    "gown", "tuxedo", "suit and tie", "a dress",
                ]),
                NounChipSection(title: "Bags and extras", words: [
                    "duffel", "goyard duffel", "gats", "gloves",
                    "scarf", "socks", "mittens", "bow tie",
                    "suspenders", "belt", "fanny pack", "backpack",
                    "purse",
                ]),
            ]
        case .guns:
            return [
                NounChipSection(title: "Glocks", words: [
                    "blicky", "Glock 40", "Glock 20", "Glock 23",
                    "thirty shot Glock",
                ]),
                NounChipSection(title: "Other guns", words: [
                    "choppa", "stick", "toolie", "burner",
                    "Mac-11", "Uzi", "P80", "fn",
                    "switchy", "rifle", "shotty",
                ]),
                NounChipSection(title: "Parts and ammo", words: [
                    "extendo", "hundred round drum", "red beam", "green beam",
                    "dot", "clip", "ammo", "bullets",
                    "shells", "hollows", "silencer", "holster",
                    "barrel", "trigger", "scope",
                ]),
            ]
        case .opps:
            return [
                NounChipSection(title: "The word", words: [
                    "Opps", "Opp pack", "Opp block", "Opp slide",
                    "opp shit", "my opps", "no opps",
                ]),
                NounChipSection(title: "Gangs", words: [
                    "4KT", "NLMB", "Bloods", "Crips",
                    "GD", "GDK", "EBK", "Piru",
                    "Grape Street", "Nine Trey", "BDs", "Lamron",
                    "Sex Money Murder", "Blixky", "Damu", "Fazoland",
                    "soo woo", "OTF", "Only the Family", "4PF",
                    "Glo Gang", "FBG", "Rollin 60", "FrontStreet",
                    "Sniper Gang",
                ]),
                NounChipSection(title: "Police and informants", words: [
                    "Tekashi", "Duck", "STL", "the rats",
                    "ATF", "DEA", "CI", "informant",
                ]),
            ]
        case .kill:
            return [
                NounChipSection(title: "Shooting", words: [
                    "hitstick", "drill", "drop him", "smoke him",
                    "clap him", "let the stick", "murk him", "off him",
                    "lay him down", "take him out", "bust at", "wet him",
                    "send shots", "let the choppa", "let the glock", "dump the clip",
                    "wig split", "headshot", "head tap", "drive-by",
                    "let it bang", "let it spray", "on a drill", "gun him down",
                    "draw down", "shot in the face", "pull up and shoot",
                ]),
                NounChipSection(title: "The hunt", words: [
                    "catch a body", "spin the block", "slide on", "rest in piss",
                    "187", "body count", "up the score", "on his head",
                    "on a shirt", "walk down", "walk him down", "run down on",
                    "body for body", "crash out", "get active", "we on go",
                    "hit they block", "no witnesses", "put a hit out", "bag on his head",
                    "home invasion", "catch a opp", "catch a hat", "the get back",
                ]),
            ]
        case .woman:
            return [
                NounChipSection(title: "Women", words: [
                    "baddie", "bad bitch", "baby mama", "side chick",
                    "main chick", "shawty", "wifey", "hoes",
                    "stallion", "shorty", "thot", "groupie",
                    "thotiana", "jumpoff", "lil shawty",
                ]),
            ]
        case .family:
            return [
                NounChipSection(title: "Mothers", words: [
                    "mom", "moms", "mama", "momma",
                    "mommy", "mother",
                ]),
                NounChipSection(title: "Fathers", words: [
                    "dad", "daddy", "father", "pops",
                    "dukes", "father figure",
                ]),
                NounChipSection(title: "Brothers", words: [
                    "brother", "my brother", "big brother", "little brother",
                    "lil bro", "big bro",
                ]),
                NounChipSection(title: "Sisters", words: [
                    "sister", "sis", "little sister", "lil sister",
                    "big sister",
                ]),
                NounChipSection(title: "Grandparents", words: [
                    "grandma", "granny", "nana", "grandmama",
                    "big mama", "grandpa", "granddaddy",
                ]),
                NounChipSection(title: "Aunts and uncles", words: [
                    "auntie", "aunt", "aunty", "uncle",
                    "unc",
                ]),
                NounChipSection(title: "Cousins", words: [
                    "cousin", "cuzzo", "cuz",
                ]),
                NounChipSection(title: "Kids", words: [
                    "nephew", "niece", "son", "daughter",
                    "my kids", "my children",
                ]),
                NounChipSection(title: "Partner", words: [
                    "wife", "hubby", "baby daddy", "my bm",
                ]),
                NounChipSection(title: "The whole family", words: [
                    "loved ones", "family", "fam", "the fam",
                    "my folks", "kinfolk", "bloodline",
                ]),
            ]
        case .money:
            return [
                NounChipSection(title: "Cash", words: [
                    "racks", "bands", "guap", "blue face",
                    "money bag", "hunnids", "big face", "comma",
                    "bankroll", "knot", "rubber bands",
                ]),
                NounChipSection(title: "Apps and cards", words: [
                    "zelle", "cashapp", "paycheck", "black card",
                    "credit card",
                ]),
                NounChipSection(title: "Watches", words: [
                    "face Patek", "richard millie",
                ]),
                NounChipSection(title: "The stash", words: [
                    "cash out", "backend", "millie", "safe",
                ]),
            ]
        case .cars:
            return [
                NounChipSection(title: "Ferrari", words: [
                    "'Rari",
                ]),
                NounChipSection(title: "Lamborghini", words: [
                    "Lambo", "Urus",
                ]),
                NounChipSection(title: "Bugatti", words: [
                    "Bugatti",
                ]),
                NounChipSection(title: "Mercedes", words: [
                    "Mercedes", "Benz", "big body Benz", "G-Wagon", "Maybach",
                    "Black Maybach", "Sprinter",
                ]),
                NounChipSection(title: "BMW", words: [
                    "BMW",
                ]),
                NounChipSection(title: "Ford", words: [
                    "Ford",
                ]),
                NounChipSection(title: "Honda", words: [
                    "Honda",
                ]),
                NounChipSection(title: "Toyota", words: [
                    "Toyota",
                ]),
                NounChipSection(title: "Lexus", words: [
                    "Lexus",
                ]),
                NounChipSection(title: "Nissan", words: [
                    "Nissan",
                ]),
                NounChipSection(title: "Bikes", words: [
                    "Harley", "Harley-Davidson", "Ducati", "Yamaha",
                    "Kawasaki", "Can-Am",
                ]),
                NounChipSection(title: "Range Rover", words: [
                    "Range Rover", "white Range Rover",
                ]),
                NounChipSection(title: "Rolls-Royce", words: [
                    "Wraith", "Cullinan", "Phantom",
                ]),
                NounChipSection(title: "Bentley", words: [
                    "Bentley", "Bentayga", "Bentley Mulsanne",
                ]),
                NounChipSection(title: "Dodge", words: [
                    "Hellcat", "Demon", "Charger", "scat pack",
                    "Daytona Charger",
                ]),
                NounChipSection(title: "Jeep", words: [
                    "Trackhawk", "Jeep",
                ]),
                NounChipSection(title: "Porsche", words: [
                    "Porsche",
                ]),
                NounChipSection(title: "Tesla", words: [
                    "Tesla",
                ]),
                NounChipSection(title: "Audi", words: [
                    "Audi",
                ]),
                NounChipSection(title: "McLaren", words: [
                    "Mclaren",
                ]),
                NounChipSection(title: "Chevy", words: [
                    "box Chevy", "donk", "Caprice", "Corvette",
                ]),
                NounChipSection(title: "Cadillac", words: [
                    "Caddy",
                ]),
                NounChipSection(title: "Oldsmobile", words: [
                    "Cutlass", "old school",
                ]),
                NounChipSection(title: "The rest of the car", words: [
                    "drop top", "Whip", "Hummer", "keys",
                    "car keys", "tires", "rims", "wheels",
                    "tints", "engine", "trunk", "seats",
                    "Forgiatos", "suicide doors", "butterfly doors", "lambo doors",
                    "candy paint", "two door", "four door", "exhaust",
                    "interior", "speakers", "sunroof", "turbo",
                    "steering wheel", "headlights", "windshield", "brakes",
                    "bumper", "dashboard", "digital dash", "valet",
                    "license plate", "paper plates",
                ]),
            ]
        case .boats:
            return [
                NounChipSection(title: "Boats", words: [
                    "yacht", "boat", "jet ski", "speedboat",
                    "cruise ship", "yacht club", "ferry", "canoe",
                    "dock",
                ]),
            ]
        case .aviation:
            return [
                NounChipSection(title: "Planes", words: [
                    "jet", "Lear jet", "G5", "G6",
                    "private plane", "helicopter", "G4", "spaceship",
                    "rocket ship", "first class", "pilot",
                ]),
            ]
        case .military:
            return [
                NounChipSection(title: "Military", words: [
                    "Humvee", "bulletproof truck", "Brinks truck", "submarine",
                    "armored truck", "in a tank",
                ]),
            ]
        case .places:
            return [
                NounChipSection(title: "Atlanta", words: [
                    "Atlanta", "Zone 6", "Decatur", "Gwinnett",
                    "East Atlanta", "Magic City",
                ]),
                NounChipSection(title: "Chicago", words: [
                    "Chi-town", "O-Block",
                ]),
                NounChipSection(title: "Memphis", words: [
                    "Memphis", "South Memphis",
                ]),
                NounChipSection(title: "Houston", words: [
                    "Houston",
                ]),
                NounChipSection(title: "Miami", words: [
                    "Miami",
                ]),
                NounChipSection(title: "New Orleans", words: [
                    "New Orleans",
                ]),
                NounChipSection(title: "Philly", words: [
                    "Philly", "North Philly",
                ]),
                NounChipSection(title: "Los Angeles", words: [
                    "Los Angeles", "Hollywood", "Hollywood Hills", "Beverly Hills",
                    "Calabasas",
                ]),
                NounChipSection(title: "New York", words: [
                    "Brooklyn",
                ]),
                NounChipSection(title: "Sides", words: [
                    "hood", "southside", "Northside", "Eastside",
                    "Westside", "bottoms", "Downtown",
                ]),
                NounChipSection(title: "The room", words: [
                    "trap", "stu", "booth", "block",
                    "Penthouse", "Mansion",
                ]),
                NounChipSection(title: "The world", words: [
                    "overseas", "London", "Paris", "Dubai",
                    "Jamaica", "Haiti", "Africa", "Tokyo",
                ]),
                NounChipSection(title: "Other cities", words: [
                    "Detroit", "Dallas", "Cleveland", "Oakland",
                    "Baltimore", "Milwaukee", "Savannah",
                ]),
            ]
        case .producers:
            return [
                NounChipSection(title: "Atlanta", words: [
                    "Metro Boomin", "Wheezy", "ATL Jacob", "Zaytoven",
                    "Southside on the Track", "London on da Track", "Mike Will", "Lex Luger",
                    "Dun Deal", "Bangladesh", "TM88", "Drumma Boy",
                    "Outtatown", "Pi'erre Bourne", "Jermaine Dupri", "DJ Drama",
                    "DY Krazy", "808 Mafia",
                ]),
                NounChipSection(title: "Los Angeles", words: [
                    "Mustard", "Hit-Boy", "Dr Dre", "Alchemist",
                    "Madlib",
                ]),
                NounChipSection(title: "Virginia", words: [
                    "Pharrell", "Timbaland",
                ]),
                NounChipSection(title: "Memphis", words: [
                    "Tay Keith",
                ]),
                NounChipSection(title: "Philly", words: [
                    "BNYX", "F1lthy", "Scott Storch",
                ]),
                NounChipSection(title: "New York", words: [
                    "Just Blaze", "DJ Premier",
                ]),
                NounChipSection(title: "Miami", words: [
                    "Honorable C.N.O.T.E.", "Ronny J",
                ]),
                NounChipSection(title: "Toronto", words: [
                    "T-Minus", "Boi-1da", "Murda Beatz",
                ]),
                NounChipSection(title: "New Orleans", words: [
                    "Mannie Fresh",
                ]),
                NounChipSection(title: "Texas", words: [
                    "Cardo",
                ]),
            ]
        case .artists:
            return [
                NounChipSection(title: "Cash Money", words: [
                    "Birdman", "Wayne", "Drake", "Nicki",
                    "Tyga",
                ]),
                NounChipSection(title: "Young Stoner Life", words: [
                    "Thugger", "Gunna", "Lil Duke", "Unfoonk",
                    "Tadoe", "Lil Keed", "Lil Gotit", "Omelly",
                ]),
                NounChipSection(title: "Quality Control", words: [
                    "Migos", "Quavo", "Offset", "Takeoff",
                    "Lil Baby", "Lil Yachty", "Yung Miami",
                ]),
                NounChipSection(title: "Only the Family", words: [
                    "Durk", "King Von",
                ]),
                NounChipSection(title: "Glory Boyz", words: [
                    "Sosa", "Fredo Santana", "Lil Reese",
                ]),
                NounChipSection(title: "1017", words: [
                    "Gucci Mane", "Peewee Longway", "Young Scooter", "Bankroll Fresh",
                    "Skooly", "Pooh Shiesty", "Marlo",
                ]),
                NounChipSection(title: "A$AP", words: [
                    "A$AP Rocky", "A$AP Ferg",
                ]),
                NounChipSection(title: "Odd Future", words: [
                    "Odd Future",
                ]),
                NounChipSection(title: "Dreamville", words: [
                    "J Cole", "JID",
                ]),
                NounChipSection(title: "Top Dawg", words: [
                    "Kendrick",
                ]),
                NounChipSection(title: "Wu-Tang", words: [
                    "RZA", "Method Man", "Raekwon", "Ghostface",
                    "ODB",
                ]),
                NounChipSection(title: "The Diplomats", words: [
                    "Camron", "Jim Jones", "Juelz",
                ]),
                NounChipSection(title: "Outkast", words: [
                    "Andre 3000", "Big Boi",
                ]),
                NounChipSection(title: "UGK", words: [
                    "Bun B", "Pimp C",
                ]),
                NounChipSection(title: "Three 6 Mafia", words: [
                    "Juicy J", "Project Pat",
                ]),
                NounChipSection(title: "Paper Route Empire", words: [
                    "Young Dolph", "Key Glock",
                ]),
                NounChipSection(title: "CMG", words: [
                    "Yo Gotti", "Moneybagg Yo", "Blac Youngsta", "GloRilla",
                ]),
                NounChipSection(title: "Opium", words: [
                    "Carti", "Ken Carson", "Homixide Gang",
                ]),
                NounChipSection(title: "Death Row", words: [
                    "2Pac", "Suge", "Snoop Dogg",
                ]),
                NounChipSection(title: "Bad Boy", words: [
                    "Biggie", "Diddy",
                ]),
                NounChipSection(title: "Houston", words: [
                    "Travis Scott", "Megan", "Paul Wall", "Mike Jones",
                    "Slim Thug", "Chamillionaire", "Trae tha Truth",
                ]),
                NounChipSection(title: "Atlanta", words: [
                    "Future", "21 Savage", "Latto", "Ludacris",
                    "Lil Jon", "SahBabii", "Young Nudy", "Kap G",
                    "Soulja Boy",
                ]),
                NounChipSection(title: "Chicago", words: [
                    "G Herbo", "Twista", "Juice WRLD", "Kanye",
                ]),
                NounChipSection(title: "New York", words: [
                    "Nas", "Jay-Z", "50 Cent", "Cardi B",
                    "Ice Spice", "Fivio Foreign", "Pop Smoke", "Big Pun",
                    "LL Cool J", "Flavor Flav", "Slick Rick", "Busta Rhymes",
                    "Fat Joe", "French Montana", "Max B", "Rakim",
                    "DMX", "A Boogie", "Lil Kim", "Ja Rule",
                    "Papoose", "Fabolous", "Foxy Brown", "Jam Master Jay",
                    "Lil Peep", "Chinx",
                ]),
                NounChipSection(title: "New Jersey", words: [
                    "Uzi", "Coi Leray", "Redman",
                ]),
                NounChipSection(title: "Los Angeles", words: [
                    "Nipsey", "The Game", "Eazy-E", "Roddy Ricch",
                    "Ice-T",
                ]),
                NounChipSection(title: "Detroit", words: [
                    "Eminem", "Veeze", "Tee Grizzley",
                ]),
                NounChipSection(title: "Baton Rouge", words: [
                    "YoungBoy", "Boosie", "Webbie",
                ]),
                NounChipSection(title: "St. Louis", words: [
                    "Sexyy Red", "Nelly", "Chingy",
                ]),
                NounChipSection(title: "Florida", words: [
                    "Kodak", "DJ Khaled",
                ]),
                NounChipSection(title: "Toronto", words: [
                    "Tory Lanez", "NAV",
                ]),
                NounChipSection(title: "Dancehall", words: [
                    "Kartel", "Popcaan", "Sean Paul",
                ]),
                NounChipSection(title: "Rappers", words: [
                    "Yeat", "NoCap", "Bow Wow", "Pusha T",
                    "Mac Miller", "Mystikal", "Saweetie", "DaBaby",
                    "Petey Pablo",
                ]),
                NounChipSection(title: "Singers", words: [
                    "Doja", "Jeremih", "Iggy", "Beyonce",
                    "Rihanna", "Michael Jackson", "Elvis", "Selena",
                    "JLo", "Adele", "Taylor Swift", "Aaliyah",
                    "Mariah", "Whitney", "Usher", "Bieber",
                    "Madonna", "Britney", "Aretha", "Sinatra",
                    "Lady Gaga", "Queen Latifah", "Ciara", "Janet",
                    "Tina Turner", "Diana Ross", "Alicia", "John Legend",
                    "Lauryn", "Erykah", "Solange", "Shakira",
                    "Timberlake", "Trey Songz", "Kehlani", "Jhene",
                    "Teyana", "Tyrese", "Jill Scott", "Demi Lovato",
                    "Sisqo", "Ginuwine", "Kelly Rowland", "R Kelly",
                    "Bob Marley", "Bobby Brown", "Sade", "Mary J",
                    "Ashanti", "Katy Perry", "Omarion", "Anita Baker",
                    "Bryson Tiller", "Keyshia Cole", "Ariana", "Patti Labelle",
                    "SZA", "Frank Ocean", "Chris Brown", "Summer Walker",
                    "Akon", "PartyNextDoor", "Wyclef",
                    "Ray J", "Brandy",
                ]),
            ]
        case .nba:
            return [
                NounChipSection(title: "Lakers", words: [
                    "Kobe", "Shaq", "Magic Johnson", "Kareem",
                    "Wilt", "Lamar Odom",
                ]),
                NounChipSection(title: "Bulls", words: [
                    "Michael Jordan", "Pippen", "Rodman", "D-Rose",
                ]),
                NounChipSection(title: "Warriors", words: [
                    "Steph", "Klay", "KD", "Draymond",
                ]),
                NounChipSection(title: "Spurs", words: [
                    "Tim Duncan", "Tony Parker", "Ginobili", "Kawhi",
                ]),
                NounChipSection(title: "Celtics", words: [
                    "Larry Bird", "Tatum", "KG", "Paul Pierce",
                    "Ray Allen", "Rondo",
                ]),
                NounChipSection(title: "Cavaliers", words: [
                    "LeBron", "Kyrie",
                ]),
                NounChipSection(title: "Heat", words: [
                    "D-Wade", "Jimmy Butler",
                ]),
                NounChipSection(title: "Thunder", words: [
                    "Westbrook",
                ]),
                NounChipSection(title: "Rockets", words: [
                    "Harden", "Yao Ming", "Hakeem",
                ]),
                NounChipSection(title: "Mavericks", words: [
                    "Dirk", "Luka",
                ]),
                NounChipSection(title: "Suns", words: [
                    "Steve Nash", "Booker", "Barkley",
                ]),
                NounChipSection(title: "Knicks", words: [
                    "Melo", "Ewing", "Marbury", "Sprewell",
                ]),
                NounChipSection(title: "Magic", words: [
                    "Dwight Howard", "T-Mac", "Hardaway",
                ]),
                NounChipSection(title: "Jazz", words: [
                    "Stockton", "Karl Malone",
                ]),
                NounChipSection(title: "Clippers", words: [
                    "CP3", "Blake Griffin",
                ]),
                NounChipSection(title: "Sixers", words: [
                    "Iverson", "Dr J",
                ]),
                NounChipSection(title: "Bucks", words: [
                    "Giannis",
                ]),
                NounChipSection(title: "Blazers", words: [
                    "Lillard",
                ]),
                NounChipSection(title: "Grizzlies", words: [
                    "Ja Morant",
                ]),
                NounChipSection(title: "Hawks", words: [
                    "Trae Young",
                ]),
                NounChipSection(title: "Raptors", words: [
                    "DeRozan", "Vince Carter",
                ]),
                NounChipSection(title: "Nuggets", words: [
                    "Jokic", "Mutombo",
                ]),
                NounChipSection(title: "Pelicans", words: [
                    "Zion",
                ]),
                NounChipSection(title: "Hornets", words: [
                    "Lonzo", "Big Baller",
                ]),
            ]
        case .nfl:
            return [
                NounChipSection(title: "Chiefs", words: [
                    "Mahomes", "Kelce", "Tyreek",
                ]),
                NounChipSection(title: "Patriots", words: [
                    "Brady",
                ]),
                NounChipSection(title: "Cowboys", words: [
                    "Emmitt", "Deion", "Romo",
                ]),
                NounChipSection(title: "49ers", words: [
                    "Jerry Rice", "Kaepernick",
                ]),
                NounChipSection(title: "Packers", words: [
                    "Favre", "Aaron Rodgers",
                ]),
                NounChipSection(title: "Ravens", words: [
                    "Ray Lewis", "Lamar Jackson",
                ]),
                NounChipSection(title: "Falcons", words: [
                    "Vick",
                ]),
                NounChipSection(title: "Lions", words: [
                    "Megatron",
                ]),
                NounChipSection(title: "Giants", words: [
                    "Odell",
                ]),
                NounChipSection(title: "Panthers", words: [
                    "Cam Newton",
                ]),
                NounChipSection(title: "Colts", words: [
                    "Peyton",
                ]),
                NounChipSection(title: "Seahawks", words: [
                    "Marshawn",
                ]),
                NounChipSection(title: "Bengals", words: [
                    "Ochocinco",
                ]),
                NounChipSection(title: "Raiders", words: [
                    "Bo Jackson",
                ]),
                NounChipSection(title: "Dolphins", words: [
                    "Marino",
                ]),
                NounChipSection(title: "Saints", words: [
                    "Brees",
                ]),
                NounChipSection(title: "Broncos", words: [
                    "Tebow",
                ]),
                NounChipSection(title: "Bears", words: [
                    "Walter Payton",
                ]),
                NounChipSection(title: "Bills", words: [
                    "OJ",
                ]),
                NounChipSection(title: "Vikings", words: [
                    "Randy Moss",
                ]),
            ]
        case .boxing:
            return [
                NounChipSection(title: "Boxing", words: [
                    "Mayweather", "Mike Tyson", "Muhammad Ali", "Pacquiao",
                    "Holyfield", "Foreman", "De La Hoya", "Tank Davis",
                    "Wilder", "Joe Frazier", "Sonny Liston",
                ]),
            ]
        case .sports:
            return [
                NounChipSection(title: "Soccer", words: [
                    "Messi", "Beckham",
                ]),
                NounChipSection(title: "Tennis", words: [
                    "Serena",
                ]),
                NounChipSection(title: "Golf", words: [
                    "Tiger Woods",
                ]),
                NounChipSection(title: "Track", words: [
                    "Usain",
                ]),
                NounChipSection(title: "Swimming", words: [
                    "Phelps",
                ]),
                NounChipSection(title: "Martial arts", words: [
                    "Bruce Lee", "Jackie Chan",
                ]),
                NounChipSection(title: "Baseball", words: [
                    "Jeter", "Barry Bonds", "Sammy Sosa", "Babe Ruth",
                ]),
                NounChipSection(title: "Hockey", words: [
                    "Gretzky",
                ]),
                NounChipSection(title: "Fighting", words: [
                    "McGregor", "Ronda",
                ]),
            ]
        case .celebs:
            return [
                NounChipSection(title: "Film", words: [
                    "Denzel", "Will Smith", "Pacino", "De Niro",
                    "Leonardo", "Brad Pitt", "Jamie Foxx", "Tom Cruise",
                    "Vin Diesel", "Chris Tucker", "Jada", "Halle",
                    "Angelina", "Zendaya", "Marilyn", "Nia Long",
                    "Taraji", "Paul Walker", "Sanaa", "Forest Whitaker",
                    "Bruce Willis", "Keanu", "Larenz Tate", "Johnny Depp",
                    "John Wayne", "Meagan Good", "Lindsay Lohan", "Vivica",
                    "Joe Pesci", "Spike Lee",
                ]),
                NounChipSection(title: "Comedy", words: [
                    "Tyler Perry", "Eddie Murphy", "Chris Rock", "Kevin Hart",
                    "Dave Chappelle", "Martin Lawrence", "Bernie Mac", "Jim Carrey",
                    "Steve Harvey", "Kenan", "Will Ferrell", "Bill Bellamy",
                    "Cosby",
                ]),
                NounChipSection(title: "Television", words: [
                    "Oprah", "Maury", "Dr Phil", "Judge Judy",
                    "Wendy Williams", "Paris Hilton", "Tyra", "Arsenio",
                    "Jerry Springer", "Nick Cannon", "Martha Stewart",
                ]),
                NounChipSection(title: "The Kardashians", words: [
                    "Kim K", "Kylie", "Khloe", "Blac Chyna",
                    "Amber Rose",
                ]),
                NounChipSection(title: "Leaders", words: [
                    "Obama", "Trump", "Malcolm X", "Rosa Parks",
                    "MLK", "Farrakhan", "Harriet", "Hillary",
                    "Biden", "Sharpton", "Garvey", "Castro",
                    "Saddam", "Kim Jong", "Noriega",
                ]),
                NounChipSection(title: "Business", words: [
                    "Elon", "Bill Gates",
                ]),
                NounChipSection(title: "Crime figures", words: [
                    "Escobar", "Chapo",
                ]),
                NounChipSection(title: "Law", words: [
                    "Johnnie Cochran",
                ]),
            ]
        case .characters:
            return [
                NounChipSection(title: "Scarface", words: [
                    "Scarface", "Tony Montana",
                ]),
                NounChipSection(title: "Friday", words: [
                    "Deebo", "Big Worm", "Craig",
                ]),
                NounChipSection(title: "Martin", words: [
                    "Sheneneh", "Bruh-Man", "Pam", "Gina",
                    "Tommy", "Hustle Man", "Otis",
                ]),
                NounChipSection(title: "Madea", words: [
                    "Madea",
                ]),
                NounChipSection(title: "Fresh Prince", words: [
                    "Uncle Phil", "Carlton",
                ]),
                NounChipSection(title: "New Jack City", words: [
                    "Nino Brown", "Pookie",
                ]),
                NounChipSection(title: "Menace II Society", words: [
                    "O-Dog",
                ]),
                NounChipSection(title: "King of New York", words: [
                    "Frank White",
                ]),
                NounChipSection(title: "Carlito's Way", words: [
                    "Carlito",
                ]),
                NounChipSection(title: "The Godfather", words: [
                    "Don Corleone", "Michael Corleone",
                ]),
                NounChipSection(title: "Empire", words: [
                    "Lucious",
                ]),
                NounChipSection(title: "Family Matters", words: [
                    "Urkel",
                ]),
                NounChipSection(title: "Boyz n the Hood", words: [
                    "Doughboy",
                ]),
                NounChipSection(title: "The Sopranos", words: [
                    "Soprano",
                ]),
                NounChipSection(title: "DC", words: [
                    "Batman", "Joker", "Two-Face", "Superman",
                    "Wonder Woman",
                ]),
                NounChipSection(title: "Marvel", words: [
                    "Black Panther", "Thor", "Thanos", "Wolverine",
                    "Hulk", "Iron Man", "Spider-Man",
                ]),
                NounChipSection(title: "Star Wars", words: [
                    "Darth Vader", "Yoda", "Skywalker",
                ]),
                NounChipSection(title: "The Matrix", words: [
                    "Neo",
                ]),
                NounChipSection(title: "Terminator", words: [
                    "Terminator",
                ]),
                NounChipSection(title: "John Wick", words: [
                    "John Wick",
                ]),
                NounChipSection(title: "James Bond", words: [
                    "James Bond",
                ]),
                NounChipSection(title: "Austin Powers", words: [
                    "Austin Powers",
                ]),
                NounChipSection(title: "Rambo", words: [
                    "Rambo",
                ]),
                NounChipSection(title: "Rocky", words: [
                    "Rocky",
                ]),
                NounChipSection(title: "Transformers", words: [
                    "Optimus Prime",
                ]),
                NounChipSection(title: "He-Man", words: [
                    "He-Man",
                ]),
                NounChipSection(title: "Horror", words: [
                    "Freddy Krueger", "Michael Myers", "Hannibal", "Chucky",
                    "Candyman",
                ]),
                NounChipSection(title: "SpongeBob", words: [
                    "SpongeBob",
                ]),
                NounChipSection(title: "Shrek", words: [
                    "Shrek",
                ]),
                NounChipSection(title: "The Lion King", words: [
                    "Simba", "Mufasa",
                ]),
                NounChipSection(title: "Dragon Ball", words: [
                    "Goku", "Vegeta", "Gohan", "Frieza",
                ]),
                NounChipSection(title: "Naruto", words: [
                    "Naruto", "Sasuke",
                ]),
                NounChipSection(title: "Pokémon", words: [
                    "Pikachu",
                ]),
                NounChipSection(title: "Looney Tunes", words: [
                    "Bugs Bunny",
                ]),
                NounChipSection(title: "Scooby-Doo", words: [
                    "Scooby Doo", "Scooby",
                ]),
                NounChipSection(title: "Peanuts", words: [
                    "Snoopy",
                ]),
                NounChipSection(title: "Rick and Morty", words: [
                    "Morty",
                ]),
                NounChipSection(title: "Peter Pan", words: [
                    "Peter Pan",
                ]),
                NounChipSection(title: "Cinderella", words: [
                    "Cinderella",
                ]),
                NounChipSection(title: "Aladdin", words: [
                    "Aladdin", "Genie",
                ]),
                NounChipSection(title: "Harry Potter", words: [
                    "Harry Potter",
                ]),
                NounChipSection(title: "Forrest Gump", words: [
                    "Forrest Gump",
                ]),
                NounChipSection(title: "King Kong", words: [
                    "King Kong",
                ]),
                NounChipSection(title: "Godzilla", words: [
                    "Godzilla",
                ]),
                NounChipSection(title: "Django", words: [
                    "Django",
                ]),
                NounChipSection(title: "Tarzan", words: [
                    "Tarzan",
                ]),
                NounChipSection(title: "Willy Wonka", words: [
                    "Willy Wonka",
                ]),
                NounChipSection(title: "The Grinch", words: [
                    "The Grinch",
                ]),
                NounChipSection(title: "G.I. Joe", words: [
                    "G.I. Joe",
                ]),
                NounChipSection(title: "Winnie the Pooh", words: [
                    "Winnie the Pooh",
                ]),
                NounChipSection(title: "Hello Kitty", words: [
                    "Hello Kitty",
                ]),
                NounChipSection(title: "The Simpsons", words: [
                    "Bart Simpson", "Homer",
                ]),
                NounChipSection(title: "Mickey Mouse", words: [
                    "Mickey", "Mickey Mouse", "Minnie", "Donald Duck",
                ]),
                NounChipSection(title: "South Park", words: [
                    "Cartman", "South Park",
                ]),
                NounChipSection(title: "Family Guy", words: [
                    "Family Guy",
                ]),
                NounChipSection(title: "Rugrats", words: [
                    "Rugrats",
                ]),
                NounChipSection(title: "Hey Arnold", words: [
                    "Hey Arnold",
                ]),
                NounChipSection(title: "Crash Bandicoot", words: [
                    "Crash Bandicoot",
                ]),
                NounChipSection(title: "Tom and Jerry", words: [
                    "Tom and Jerry",
                ]),
                NounChipSection(title: "Sonic", words: [
                    "Sonic",
                ]),
            ]
        case .animals:
            return [
                NounChipSection(title: "Big cats", words: [
                    "lion", "lions", "tigers", "cheetah",
                    "leopard", "panther",
                ]),
                NounChipSection(title: "Apes and monkeys", words: [
                    "gorilla", "ape", "apes", "monkey",
                    "monkeys", "chimp", "baboon",
                ]),
                NounChipSection(title: "Safari", words: [
                    "zebra", "elephant", "hyena", "kangaroo",
                    "koala", "hippo", "giraffe",
                ]),
                NounChipSection(title: "Reptiles", words: [
                    "dinosaur", "pterodactyl", "komodo", "snake",
                    "snakes", "snakes in the grass", "cobra", "python",
                    "anaconda", "lizard", "iguana", "alligator",
                    "crocodile", "gator", "gators", "croc",
                    "frog", "frogs", "turtle", "tortoise",
                ]),
                NounChipSection(title: "Sea", words: [
                    "shark", "sharks", "great white", "whale",
                    "dolphin", "fish", "goldfish", "piranha",
                    "eel", "octopus", "starfish", "snail",
                    "nemo",
                ]),
                NounChipSection(title: "Farm", words: [
                    "pig", "pigs", "hogs", "cow",
                    "cows", "turkey", "sheep", "black sheep",
                    "donkey", "mule",
                ]),
                NounChipSection(title: "Dogs", words: [
                    "pitbull", "pitbulls", "pit bull", "pits",
                    "rottweiler", "doberman", "k9", "poodle",
                    "puppy", "puppies", "mutt",
                ]),
                NounChipSection(title: "Birds", words: [
                    "pigeon", "dove", "owl", "vulture",
                    "seagull", "rooster", "flamingo", "parrot",
                    "penguin", "raven", "hawk",
                ]),
                NounChipSection(title: "Other animals", words: [
                    "wolf", "wolves", "bear", "bears",
                    "polar bear", "grizzly", "deer", "rabbit",
                    "squirrel", "mouse", "rat", "rats",
                    "lab rat", "possum", "leech",
                ]),
                NounChipSection(title: "Myth", words: [
                    "unicorn", "dragon",
                ]),
                NounChipSection(title: "Parts", words: [
                    "king of the jungle", "claws", "whiskers", "feathers",
                    "venom",
                ]),
            ]
        case .insects:
            return [
                NounChipSection(title: "Stingers", words: [
                    "bee", "bees", "bumble bee", "beehive",
                    "hornet",
                ]),
                NounChipSection(title: "Biters", words: [
                    "mosquito", "mosquitoes", "flea", "fleas",
                    "ticks", "lice", "gnat", "gnats",
                ]),
                NounChipSection(title: "Crawlers", words: [
                    "ants", "roaches", "cockroaches", "spiders",
                    "centipede", "cricket", "crickets", "maggot",
                    "maggots",
                ]),
                NounChipSection(title: "Wings", words: [
                    "butterfly", "moth",
                ]),
            ]
        case .food:
            return [
                NounChipSection(title: "Chicken", words: [
                    "fried chicken", "chicken wings", "lemon pepper", "kfc",
                    "popeyes", "church's", "raising cane's", "wingstop",
                    "zaxby's", "chick fil a", "hooters",
                ]),
                NounChipSection(title: "Steak and seafood", words: [
                    "steak", "wagyu", "filet", "filet mignon",
                    "steak and lobster", "shrimp", "lobster", "lobster tail",
                    "swordfish", "sushi", "salmon", "seafood",
                    "calamari", "oysters", "fish fry", "red lobster",
                    "nobu", "benihana", "hibachi", "teriyaki",
                    "ruth's chris",
                ]),
                NounChipSection(title: "Pasta and noodles", words: [
                    "spaghetti", "ramen", "lo mein", "fried rice",
                    "lasagna", "alfredo", "wonton",
                ]),
                NounChipSection(title: "Southern", words: [
                    "collard greens", "gumbo", "soul food", "cornbread",
                    "peach cobbler", "chili",
                ]),
                NounChipSection(title: "Breakfast", words: [
                    "pancakes", "waffles", "french toast", "eggs",
                    "omelet", "ihop", "waffle house", "denny's",
                    "krispy kreme",
                ]),
                NounChipSection(title: "Fast food", words: [
                    "burger", "fries", "french fries", "pizza",
                    "pepperoni", "pizza hut", "domino's", "little caesars",
                    "mcdonald's", "burger king", "wendy's", "five guys",
                    "in-n-out", "cookout", "subway", "taco",
                    "tacos", "nachos", "taco bell", "cheesesteak",
                    "gyro", "hot sauce", "buffet",
                ]),
                NounChipSection(title: "Sweets", words: [
                    "milkshake", "sundae", "honey buns", "pop tart",
                    "cereal", "captain crunch", "cotton candy", "reese's",
                    "twix", "kit kat", "hershey", "cheesecake",
                    "now and later", "jolly rancher",
                ]),
                NounChipSection(title: "Drinks", words: [
                    "kool-aid", "capri sun", "lemonade", "sweet tea",
                    "iced tea", "smoothie", "minute maid",
                ]),
                NounChipSection(title: "Snacks", words: [
                    "cheetos", "doritos", "funyuns",
                ]),
            ]
        case .grills:
            return [
                NounChipSection(title: "Gold in the mouth", words: [
                    "gold grill", "gold fronts", "gold teeth", "gold tooth",
                    "golds", "mouth full of gold", "gold in my mouth", "diamonds in my teeth",
                    "diamonds in my mouth", "teeth gold", "diamond teeth", "ice grill",
                ]),
                NounChipSection(title: "The grill", words: [
                    "grill", "grills", "my grill", "my grills",
                ]),
                NounChipSection(title: "The teeth", words: [
                    "fangs", "my fangs", "my teeth", "veneers",
                    "braces", "porcelain",
                ]),
            ]
        case .hair:
            return [
                NounChipSection(title: "Locs and braids", words: [
                    "dreads", "dreadlocks", "dreadlock", "braids",
                    "cornrows", "twists", "braid", "braided",
                    "lace front", "weave", "wigs", "ponytail",
                ]),
                NounChipSection(title: "Cuts", words: [
                    "waves", "temp fade", "taper", "lineup",
                    "hairline", "bald head", "haircut", "nappy",
                    "afro", "fro", "bangs", "edges",
                    "bonnet",
                ]),
                NounChipSection(title: "Color", words: [
                    "blonde", "blonde hair", "jheri curl", "perm",
                    "curls", "curly hair",
                ]),
                NounChipSection(title: "Beard", words: [
                    "beard", "goatee", "mustache",
                ]),
                NounChipSection(title: "The shop", words: [
                    "barbershop", "the barber",
                ]),
            ]
        case .nails:
            return [
                NounChipSection(title: "Nails", words: [
                    "nails", "french tip", "french tips", "my nails",
                    "her nails", "nails done", "nails did", "manicure",
                    "pedicure",
                ]),
            ]
        case .tattoos:
            return [
                NounChipSection(title: "The word", words: [
                    "tattoo", "tattoos", "tatted", "tattooed",
                    "tats", "a tattoo", "the tattoo", "the tattoos",
                    "my tattoos", "my tats", "the tats", "tatted up",
                    "i'm tatted", "she tatted", "it's tatted", "inked",
                    "got tats", "got tattoos", "got it tatted",
                ]),
                NounChipSection(title: "Face", words: [
                    "tatted on my face", "tats on my face", "face tats", "face tatted",
                ]),
                NounChipSection(title: "The body", words: [
                    "tatted on my", "tatted on me", "tatted on my neck", "tatted on my chest",
                    "tatted on my arm",
                    "tats on my", "tats on my neck", "tattoos on my", "tattoo on my",
                    "tattoo on her", "tattoos on her", "name tatted", "my name tatted",
                    "got my name tatted",
                ]),
                NounChipSection(title: "Tramp stamp", words: [
                    "tramp stamp",
                ]),
            ]
        case .flowers:
            return [
                NounChipSection(title: "Flowers", words: [
                    "flowers", "roses", "petals", "rose petals",
                    "daisies", "tulips",
                ]),
            ]
        case .lingerie:
            return [
                NounChipSection(title: "Underwear", words: [
                    "panties", "thong", "thongs", "g-string",
                    "boxers", "drawers",
                ]),
                NounChipSection(title: "Bras and sets", words: [
                    "lingerie", "bra", "fishnets", "stockings",
                    "bikini",
                ]),
            ]
        case .toys:
            return [
                NounChipSection(title: "Toys", words: [
                    "vibrator", "rose",
                ]),
            ]
        case .twerk:
            return [
                NounChipSection(title: "Twerk", words: [
                    "twerk", "twerking", "she twerk", "make it twerk",
                    "twerk that", "twerk that ass", "shake that ass", "shake that ass for me",
                    "make that ass clap", "ass clap", "clap that ass", "throw that ass back",
                    "throw that ass", "throw it back on", "bounce it", "bounce that ass",
                ]),
            ]
        case .streets:
            return [
                NounChipSection(title: "Streets", words: [
                    "she for the streets", "she a thot", "like a thot",
                ]),
            ]
        case .kingpin:
            return [
                NounChipSection(title: "The plug", words: [
                    "kingpin", "my connect", "plug talk", "hit the plug",
                    "call the plug",
                ]),
            ]
        case .trapLife:
            return [
                NounChipSection(title: "The house", words: [
                    "trap house", "the trap house", "my trap house", "in the trap house",
                    "at the trap house", "the trap", "out the trap", "came from the trap",
                    "back to the trap", "back in the trap", "at the trap", "trap spot",
                    "trap houses", "still in the trap", "my trap", "his trap",
                ]),
                NounChipSection(title: "Trapping", words: [
                    "trapping", "i'm trapping", "still trapping", "been trapping",
                    "we trapping", "trapping out", "trap jumping",
                ]),
            ]
        case .paranoia:
            return [
                NounChipSection(title: "The feeling", words: [
                    "paranoid", "paranoia", "i'm paranoid", "so paranoid",
                    "too paranoid", "got me paranoid", "hearing voices",
                ]),
                NounChipSection(title: "The feds", words: [
                    "the feds watching", "feds watching", "the feds on me",
                ]),
                NounChipSection(title: "Can't trust", words: [
                    "can't trust nobody", "don't trust nobody", "i don't trust nobody", "can't trust no one",
                    "trust no one", "can't trust a soul", "don't trust a soul", "can't trust these niggas",
                    "i don't trust these niggas", "don't trust these niggas", "can't trust these hoes", "can't trust a bitch",
                    "can't trust 'em", "don't trust 'em", "no trust", "ain't no trust",
                ]),
            ]
        case .wrestlers:
            return [
                NounChipSection(title: "Attitude Era", words: [
                    "Steve Austin", "Stone Cold", "The Rock", "Undertaker",
                    "Triple H", "HBK", "Kurt Angle", "Jeff Hardy",
                ]),
                NounChipSection(title: "Legends", words: [
                    "Hogan", "Macho Man", "Ric Flair",
                ]),
                NounChipSection(title: "The new era", words: [
                    "John Cena", "Mysterio",
                ]),
            ]
        case .actors:
            return [
                NounChipSection(title: "Action", words: [
                    "Jet Li", "Van Damme", "Chuck Norris", "Stallone",
                    "Sylvester Stallone", "Arnold Schwarzenegger", "Wesley Snipes", "Steven Seagal",
                ]),
                NounChipSection(title: "Comedy", words: [
                    "Richard Pryor", "Damon Wayans", "Wayans", "Adam Sandler",
                    "Whoopi Goldberg", "Mike Epps", "Redd Foxx",
                    "Robin Williams", "Keke Palmer", "Chris Farley", "Mo'Nique",
                ]),
                NounChipSection(title: "Drama", words: [
                    "Danny Glover", "Ving Rhames", "Steve Buscemi", "Heath Ledger",
                    "Mekhi Phifer", "Morgan Freeman", "Angela Bassett", "Don Cheadle",
                    "Ice Cube", "Michael B. Jordan", "Samuel L. Jackson", "Idris Elba",
                ]),
                NounChipSection(title: "Directors", words: [
                    "Quentin Tarantino", "Steven Spielberg", "Martin Scorsese",
                ]),
                NounChipSection(title: "Stars", words: [
                    "Mel Gibson", "Nicolas Cage", "George Clooney", "John Travolta",
                ]),
            ]
        case .streamers:
            return [
                NounChipSection(title: "Streamers", words: [
                    "Akademiks", "Kai Cenat", "Charlamagne",
                ]),
            ]
        case .friends:
            return [
                NounChipSection(title: "Slime", words: [
                    "slime", "slimes", "my slime", "the slimes",
                    "slatt", "slatts",
                ]),
                NounChipSection(title: "Twin", words: [
                    "twin", "my twin",
                ]),
                NounChipSection(title: "Brodie", words: [
                    "brodie", "my brodie", "brody",
                ]),
                NounChipSection(title: "Bro", words: [
                    "bruh", "broski", "bro", "bros",
                ]),
                NounChipSection(title: "Partner", words: [
                    "potna", "partna", "my partna", "partner",
                    "partners",
                ]),
                NounChipSection(title: "Whoadie", words: [
                    "whoadie", "wodie", "woadie",
                ]),
                NounChipSection(title: "Homie", words: [
                    "homie", "homies", "my homie", "homeboy",
                    "homeboys", "my homeboy", "homegirl",
                ]),
                NounChipSection(title: "Dawg", words: [
                    "dawg", "dawgs", "cuh", "brudda",
                ]),
                NounChipSection(title: "The set", words: [
                    "eses", "vato", "vatos", "gang",
                    "gangs", "gang gang", "the set", "my set",
                    "clique", "mob", "the mob", "squad",
                    "crew", "the guys", "my guys", "my mans",
                    "the mandem",
                ]),
                NounChipSection(title: "Shooters", words: [
                    "gangbanger", "gangbangers", "gang member", "gang members",
                    "goon", "goons", "my goon", "drillers",
                    "shooter", "shooters", "my shooter", "hitter",
                    "hittas", "hitters",
                ]),
                NounChipSection(title: "Youngins", words: [
                    "youngin", "youngins",
                ]),
                NounChipSection(title: "Thugs and soldiers", words: [
                    "thugs", "gangsta", "gangster", "gangsters",
                    "savages", "trench baby", "soldiers", "my soldier",
                    "trapper", "trappers", "hitman", "og",
                    "young bull", "main man", "my celly", "my thug",
                    "codefendant", "my nigga", "my niggas",
                ]),
            ]
        case .games:
            return [
                NounChipSection(title: "Shooters", words: [
                    "Call of Duty", "Black Ops", "Fortnite",
                ]),
                NounChipSection(title: "Rockstar", words: [
                    "GTA", "Grand Theft Auto", "San Andreas",
                ]),
                NounChipSection(title: "Fighting", words: [
                    "Mortal Kombat", "Street Fighter", "Tekken",
                ]),
                NounChipSection(title: "Nintendo", words: [
                    "Zelda", "Pokemon", "Luigi", "Nintendo",
                    "Wii",
                ]),
                NounChipSection(title: "PlayStation", words: [
                    "PlayStation", "PS5", "PS4",
                ]),
                NounChipSection(title: "Sports games", words: [
                    "Madden", "FIFA",
                ]),
                NounChipSection(title: "Arcade", words: [
                    "Pac-Man",
                ]),
            ]
        case .events:
            return [
                NounChipSection(title: "Rappers we lost", words: [
                    "Lil Snupe", "Snupe", "Speaker Knockerz", "Doe B",
                    "Big L",
                ]),
                NounChipSection(title: "The news", words: [
                    "Trayvon", "Mike Brown", "Columbine",
                ]),
            ]
        case .substances:
            return [
                NounChipSection(title: "PCP", words: [
                    "embalming fluid", "sherm", "pcp", "angel dust",
                    "dipper", "illy", "love boat", "activis",
                ]),
                NounChipSection(title: "Powder", words: [
                    "crack", "coke", "cocaine", "dope",
                    "heroin", "meth", "crystal meth", "yola",
                    "kilo", "zip", "ounce", "eight ball",
                    "crack rock",
                ]),
                NounChipSection(title: "Weed", words: [
                    "mids", "reggie", "dro", "sour diesel",
                    "haze", "dutch", "grabba", "fronto",
                    "dab", "wax", "shatter", "purp",
                ]),
                NounChipSection(title: "Pills", words: [
                    "vicodin", "ketamine", "mushrooms", "edibles",
                    "dirty 30", "dirty thirty", "fent", "lucy",
                ]),
                NounChipSection(title: "Drank", words: [
                    "drank", "mud",
                ]),
            ]
        case .religion:
            return [
                NounChipSection(title: "Faiths", words: [
                    "Jewish", "Muslim", "Christian", "Catholic",
                    "Baptist", "Buddhist", "Hindu", "religion",
                ]),
                NounChipSection(title: "God and prophets", words: [
                    "God", "Allah", "Jesus", "Christ",
                    "Yahweh", "Jehovah", "Messiah", "virgin Mary",
                    "Buddha",
                ]),
                NounChipSection(title: "Books and prayer", words: [
                    "rosary", "Bible", "Quran", "gospel",
                    "prayer", "amen", "choir", "crucifix",
                ]),
                NounChipSection(title: "The building", words: [
                    "church", "mosque", "pastor", "preacher",
                    "priest", "Mecca", "Ramadan", "synagogue",
                    "Sunday service",
                ]),
            ]
        case .feelings:
            return [
                NounChipSection(title: "Hurt", words: [
                    "sad", "sadness", "sorrow", "cry",
                    "tears", "I miss", "lonely", "alone",
                    "lonesome", "homesick", "nostalgia", "longing",
                    "abandoned", "neglected", "rejected", "mourning",
                    "grief", "depressed", "depression", "hopeless",
                    "misery", "devastated", "dead inside", "betrayed",
                    "hurt", "pain", "heartbreak", "heartbroken",
                    "heart cold", "heartless", "scarred", "traumatized",
                    "trauma", "agony", "suffering", "regret",
                    "remorse", "helpless",
                ]),
                NounChipSection(title: "Scared", words: [
                    "scary", "scared", "afraid", "fear",
                    "paranoid", "anxious", "anxiety", "nervous",
                    "panic", "worried", "terrified", "insecure",
                    "vulnerable", "uneasy", "stressed", "stress",
                    "overwhelmed", "numb", "confused", "desperate",
                ]),
                NounChipSection(title: "Angry", words: [
                    "angry", "mad", "rage", "pissed",
                    "furious", "livid", "wrath", "hate",
                    "hatred", "bitter", "salty", "envy",
                    "jealous", "spite", "resentment", "disgusted",
                    "frustrated",
                ]),
                NounChipSection(title: "Glad", words: [
                    "love", "happy", "glad", "happiness",
                    "bliss", "proud", "pride", "grateful",
                    "thankful", "blessed", "calm", "content",
                    "confident", "excited",
                ]),
                NounChipSection(title: "Worn out", words: [
                    "tired", "fed up", "bored", "emotionless",
                    "restless",
                ]),
                NounChipSection(title: "Shame", words: [
                    "shame", "guilt", "ashamed", "embarrassed",
                ]),
            ]
        case .wordplay:
            return [
                NounChipSection(title: "Sound flips", words: [
                    "gotta cancer", "never dye", "sharin' ten", "jump the gates",
                    "Kevin Gates", "Marriott her", "Marcus", "until my days end",
                    "Dial soap", "QuikTrip", "Faith Evans", "own lane",
                    "Tory", "sliders", "box him", "must die",
                    "a sheet", "bring the real back", "relay", "Jake",
                    "Fox News", "Jamie Fox", "Lohan", "call on",
                    "Creed", "rock it", "heroine", "Celean",
                    "by the night", "Suge Knight", "Smith and Will", "I kneel",
                    "Shaquille", "Reid me", "Eric Reid", "a bride",
                    "a knot", "leavin' a lot", "4 holes", "leave my heat",
                    "my sons", "Pinky", "Nguyen", "Mer-Curry",
                    "keyboard", "pillow talk", "Titans", "smoked the restaurants",
                    "Radric Davis", "temp me", "the drop", "MAC lipstick",
                    "texts", "tecs", "Tom Brady", "moving swift",
                    "Taylor", "geeked", "Steve Urkel", "hangin' with glue",
                    "over Yao", "dodge the block", "Patrick Beverly", "Houston rockets",
                    "no type", "Swae Lee", "to the vet", "T. Hill",
                    "chief it", "Jrue Holiday", "Greek", "bet to the bucks",
                    "Pluto", "playing Trouble", "Aaron Donald", "Serge Ibaka",
                    "block her", "OD", "Major Payne", "Gilbert Arenas",
                    "Tony Hawk", "Training Day", "Kill Bill",
                ]),
            ]
        case .phrases:
            return [
                NounChipSection(title: "Death", words: [
                    "RIP", "long live", "if I die", "till I die",
                    "death before dishonor", "back from the dead", "death row", "I almost died",
                    "the reaper", "almost died", "rest in peace", "the grave",
                    "the casket", "closed casket", "the funeral", "dead homies",
                    "my dead homies", "fallen soldiers", "dead man walking", "body bag",
                    "yellow tape", "crime scene", "in heaven", "in the grave",
                    "graveyard", "the cemetery", "six feet", "six feet deep",
                    "coffin", "hearse", "tombstone", "headstone",
                    "obituary", "eulogy", "bury me", "to the grave",
                    "in the dirt", "in the ground", "up in heaven", "looking down",
                    "my angels", "the afterlife", "next life", "heaven or hell",
                    "grim reaper", "meet your maker", "on the other side", "rest up",
                    "dead and gone", "passed away", "last breath", "death wish",
                    "I lost my brother", "lost too many", "dead friends", "dead homie",
                    "dead opps", "die young", "the good die young", "scared to die",
                    "when I die", "my funeral", "at the funeral", "walking dead",
                ]),
                NounChipSection(title: "Guns", words: [
                    "the strap", "my strap", "I'm strapped", "keep a gun",
                    "under the seat", "on my waist", "cocked back", "shots fired",
                    "I got shot", "bulletproof vest", "the vest", "hop out",
                    "hopped out", "let it rip", "air it out", "bust back",
                    "keep it on me", "that strap", "we strapped", "keep a strap",
                    "on my hip", "strapped up", "stay strapped", "cock it back",
                    "off safety", "no safety", "fully auto", "fully automatic",
                    "empty the clip", "let off shots", "they shooting", "they shot",
                    "my vest", "no vest", "we sliding", "with the switch",
                    "with the beam", "beam on it", "red dot", "wet em",
                    "spray em",
                ]),
                NounChipSection(title: "Family", words: [
                    "on my mama", "I put that on my mama", "on my kids", "for my kids",
                    "family first", "that's my brother", "my brothers", "my wife",
                    "for my son", "for my daughter", "we family", "we brothers",
                    "my mama", "my momma", "my daddy", "my pops",
                    "my grandma", "my granny", "my auntie", "my uncle",
                    "my cousin", "my sister", "my son", "my daughter",
                    "no daddy", "child support", "mama house", "deadbeat",
                    "my family", "for my family", "my bros", "word to my mother",
                    "housewife", "my mother", "the family", "the bros",
                    "my dad", "mama told me", "my father", "mama said",
                    "raised me", "my fam", "whole family", "my big brother",
                    "my babies", "my nephew", "my cousins", "no father",
                    "for my mama", "bloodline", "for the fam", "for the kids",
                    "my niece", "family tree", "like my daddy", "my sisters",
                    "free my brother", "grandma house", "bought my mama", "like my mama",
                    "for the family", "momma house", "my little brother", "Uncle Sam",
                ]),
                NounChipSection(title: "Love", words: [
                    "fake love", "no love lost", "cross my heart", "heart broke",
                    "she the one", "catch feelings", "one love", "hood love",
                    "Bonnie and Clyde", "down ass bitch", "main bitch", "side bitch",
                    "side piece", "my bae", "my ex", "love of my life",
                    "soulmate", "broke my heart", "heart on my sleeve", "lonely nights",
                    "no strings attached", "one night stand", "no love", "she love me",
                    "I love her", "I miss you", "real love", "my queen",
                    "that's my baby", "she left me", "still in love", "don't leave me",
                    "first love", "dream girl", "just friends", "I miss her",
                    "she miss me", "feelings involved", "mistress", "main squeeze",
                    "boo thang", "my boo", "love at first sight", "heart broken",
                    "broken heart", "she don't love me", "you my baby", "put a ring on",
                ]),
                NounChipSection(title: "Money", words: [
                    "when I was broke", "get money", "secure the bag", "money over everything",
                    "new money", "get a bag", "old money", "get rich or die tryin",
                    "paper chasing", "money talks", "time is money", "rags to riches",
                    "money over bitches", "money on my mind", "big checks", "mind on my money",
                    "paid in full", "dirty money", "clean money", "fast money",
                    "trap money", "make it rain", "band for band", "self made",
                    "first of the month", "never broke", "I ain't broke", "die rich",
                    "EBT", "food stamps", "count it up", "blood money",
                    "drug money", "street money", "rap money", "never broke again",
                    "rich forever", "money in the bank", "stash house", "pockets fat",
                    "pockets on swole", "I was broke", "go broke", "big money",
                    "money long", "get this money", "paper route", "dead broke",
                    "stack it up", "six figures", "paid my dues", "bail money",
                    "mic check", "rich nigga", "broke nigga", "the stash",
                    "money counter", "real money", "big check", "look like money",
                    "stay rich", "the IRS", "I can't go broke", "blue check",
                    "getting money", "get paid", "count up", "hundred racks",
                    "hundred bands", "big racks", "I'm a millionaire", "multi millionaire",
                    "we was broke", "the rent", "pay the rent", "at the bank",
                    "throwing money", "I'm broke", "trust fund", "get rich",
                ]),
                NounChipSection(title: "Drugs", words: [
                    "cook it up", "high as hell", "I'm faded", "I'm geeked",
                    "I'm zooted", "off a perc", "off a molly", "off the lean",
                    "sippin lean", "poppin percs", "poppin pills", "never sober",
                    "poured up", "high as a kite", "geeked up", "I'm geekin",
                    "eyes low", "noddin off", "the munchies", "booted up",
                    "I'm leanin", "off the percs", "off the xans", "off a bean",
                    "off a pill", "sippin on lean", "sippin codeine", "sippin wock",
                    "pour up", "a whole pint", "cup of lean", "lean in my cup",
                    "baby bottle", "pop a perc", "pop a pill", "pop a xan",
                    "pop a molly", "two percs", "sell dope", "the fiends",
                    "the re-up", "middle man", "high as shit", "the plug",
                    "my plug", "a brick", "too high", "high as fuck",
                    "stay high", "the connect", "too faded", "too much lean",
                    "we sipping",
                ]),
                NounChipSection(title: "Ice", words: [
                    "ice on my neck", "ice on my wrist", "drip too hard", "diamonds dancing",
                    "water on my neck", "water on my wrist", "so icy", "wrist froze",
                    "too much ice", "iced out", "ice on me",
                ]),
                NounChipSection(title: "Cars and roads", words: [
                    "two seater", "foreign cars", "top down", "no roof",
                    "doors up", "wide body", "matte black", "off the lot",
                    "the dealership", "no ceiling", "the foreigns", "new truck",
                    "the highway", "the freeway", "in the foreign", "new car",
                    "tinted windows", "stolen car", "paper tags", "on the highway",
                    "on the freeway", "the interstate", "the driveway", "on the road",
                    "hit the road",
                ]),
                NounChipSection(title: "Faith", words: [
                    "on God", "God did", "that's on God", "I put that on God",
                    "God first", "young god", "swear to God", "God got me",
                    "the most high", "thank God", "pray for me", "on the Bible",
                    "only God can judge", "talk to God", "on my knees", "heaven sent",
                    "the holy ghost", "thank the Lord", "pray to God", "I pray to God",
                    "say a prayer", "Lord forgive me", "God forgive me", "I'm a sinner",
                    "my sins", "say my grace", "God bless", "bless up",
                    "God's plan", "believe in God", "only God can judge me", "only God knows",
                    "Lord knows", "in God we trust", "hand on the Bible", "go to church",
                    "the pastor", "the preacher", "the Reverend", "holy water",
                    "baptized", "the devil is a lie", "devil on my shoulder", "pearly gates",
                    "Lord have mercy", "Dear Lord", "my soul to keep", "amazing grace",
                    "the choir", "tithes", "the pulpit", "amen",
                    "hallelujah", "praise God", "thank you God",
                ]),
                NounChipSection(title: "The case", words: [
                    "fuck 12", "fuck the police", "no snitching", "no face no case",
                    "never snitch", "free him", "jump out boys", "the feds",
                    "RICO", "on probation", "house arrest", "the county",
                    "commissary", "kicked the door", "told on me", "on parole",
                    "upstate", "indictment", "behind bars", "locked up",
                    "life sentence", "catch a charge", "catch a case", "beat the case",
                    "not guilty", "plead the fifth", "make bail", "got knocked",
                    "in the pen", "penitentiary", "in the feds", "free my niggas",
                    "in a cell", "locked down", "the judge", "the DA",
                    "the jury", "a felony", "the 12", "free the guys",
                    "pulled me over", "jammed up", "on the yard", "the po-po",
                    "he a rat", "county jail", "fuck the system", "take the charge",
                    "took the stand", "the precinct", "high speed chase", "court date",
                    "Rikers", "convicted felon", "got indicted", "out on bond",
                    "the pen", "the yard", "the witness", "on lockdown",
                    "beat a case", "the system", "my lawyer", "in prison",
                    "snitching", "in court", "out of jail",
                ]),
                NounChipSection(title: "Phone and internet", words: [
                    "trap phone", "hit my line", "in my DMs", "the blogs",
                    "went viral", "two phones", "on read", "the comments",
                    "verified", "my story", "my timeline", "screenshot",
                    "trending", "hashtag", "viral", "go viral",
                    "three phones", "iPhone", "followers", "the internet",
                    "on the internet", "social media", "on live", "group chat",
                    "I don't post", "never post", "nudes", "double tap",
                    "on mute", "voicemail", "Do Not Disturb", "airplane mode",
                    "phone tapped", "new phone", "flip phone", "pager",
                    "beeper", "Google me", "my mentions", "the tea",
                    "for the clout",
                ]),
                NounChipSection(title: "Places", words: [
                    "on the block", "in the trap", "in the kitchen", "in the booth",
                    "word on the street", "from the hood", "for the hood", "the projects",
                    "the bricks", "the block hot", "trap nigga", "trap shit",
                    "section 8", "around the world", "coast to coast", "the hallway",
                    "the ave", "the boulevard", "trap star", "trap queen",
                    "worldwide", "every city", "on the corner", "the trenches",
                    "in the trenches", "from the trenches", "the gutter", "from the gutter",
                    "trap life", "in the studio", "the bando", "new crib",
                    "beach house", "marble floors", "house on the hill", "presidential suite",
                    "off the porch", "jumped off the porch", "the slums", "the corner store",
                    "in the alley", "bodega", "strip club", "the VIP",
                    "up in the club", "house party", "in the bando", "trap out the bando",
                    "alley-oop", "the club", "in the club", "at the club",
                    "the spot", "the studio", "new house", "dance floor",
                    "every hood", "every block", "back in the hood", "the rooftop",
                    "in VIP", "the stoop", "out of town", "outta town",
                    "in the city", "my city", "this city", "hotel room",
                    "the lobby", "my crib", "on the roof", "in the A",
                    "the Bay", "the corner", "the woods", "the beach",
                    "on the beach", "the A", "the Chi", "the hotel",
                    "in the lobby", "upstairs", "downstairs", "the basement",
                    "the attic", "the garage", "glass house", "the balcony",
                    "west coast", "east coast", "in Vegas", "South Beach",
                    "the hills", "Chiraq", "catch a flight", "on a plane",
                    "the airport", "passport", "on vacation", "Four Seasons",
                    "the Ritz", "the condo", "hotel lobby", "the pool",
                    "jacuzzi", "at the crib", "to the crib", "on the porch",
                    "living room", "your city", "city to city", "the whole city",
                    "for my city",
                ]),
                NounChipSection(title: "Time and weather", words: [
                    "no sleep", "365", "around the clock", "up all night",
                    "late nights", "early morning", "seven days a week", "Monday through Sunday",
                    "nine to five", "night shift", "24 hours", "get no sleep",
                    "all night", "all day", "late night", "can't sleep",
                    "day and night", "night and day", "I don't sleep", "in the morning",
                    "at night", "midnight", "Friday night", "the weekend",
                    "my birthday", "Christmas", "when it rain", "in the rain",
                    "sundown", "nighttime", "daytime", "sunset",
                    "sunrise", "sun up", "thunderstorm", "ice cold",
                    "cold outside", "in the summer", "in the winter", "on Christmas",
                    "Thanksgiving", "New Year", "on my birthday", "Halloween",
                    "payday", "all day long", "last night", "every night",
                    "this morning", "after dark", "middle of the night", "overnight",
                    "so cold", "this summer", "Mardi Gras", "Fourth of July",
                    "Christmas Eve", "Sunday morning", "on the weekend",
                ]),
                NounChipSection(title: "Sports", words: [
                    "game time", "hall of fame", "super bowl", "championship ring",
                    "pound for pound", "in the gym", "overtime", "free throw",
                    "tap out", "in the paint", "dream team", "home run",
                    "on the court", "above the rim", "all-star", "triple-double",
                    "crunch time", "slam dunk", "the nosebleeds", "end zone",
                    "gold medal", "hard in the paint", "toe to toe", "full court",
                    "finger roll", "three point", "field goal", "major league",
                    "hole in one", "got next", "rookie of the year", "throw in the towel",
                    "draft day", "no-look", "the huddle", "knuckle up",
                    "on the ropes", "three-peat", "hoop dreams", "royal rumble",
                    "catch a fade", "shot clock", "bob and weave", "the finals",
                    "the draft",
                ]),
                NounChipSection(title: "Loyalty", words: [
                    "real niggas", "keep it real", "real shit", "ride or die",
                    "do or die", "trust nobody", "keep it 100", "real talk",
                    "real recognize real", "keep it a buck", "no new friends", "never fold",
                    "I got you", "day one", "fake niggas", "fake friends",
                    "since day one", "trust issues", "real ones", "through thick and thin",
                    "keep it a hundred", "we all we got", "word is bond", "hold it down",
                    "ride for me", "hold me down", "ride with me", "die for me",
                    "kill for me", "stay solid", "stay true", "stay real",
                    "for the gang", "my circle", "who with me", "she loyal",
                    "down for me", "she a rider", "never switch", "don't switch",
                    "ten toes", "hoes ain't loyal", "she hold it down", "I'm solid",
                    "the real one", "day ones", "my day ones",
                ]),
                NounChipSection(title: "Everyday talk", words: [
                    "demon time", "Jet Life", "people weren't around", "wasn't there",
                    "when I was down", "nobody believed", "they ain't believe", "they didn't believe",
                    "been through a lot", "been through it", "when I was down bad", "wasn't around",
                    "pull up", "no cap", "turn up", "let's get it",
                    "run it up", "I want smoke", "I don't play", "in my bag",
                    "out the mud", "locked in", "what it do", "on my soul",
                    "on everything", "we outside", "it's a movie", "say less",
                    "that's facts", "that's cap", "started from the bottom", "look at me now",
                    "all eyes on me", "no days off", "I been him", "they not ready",
                    "for the culture", "I don't give a fuck", "for real", "straight up",
                    "turnt up", "it's up", "made it out", "we made it",
                    "no lie", "going crazy", "from nothing", "in my feelings",
                    "they don't want no smoke", "what's good", "by any means", "slide through",
                    "cold world", "pour it up", "I don't need nobody", "what's poppin",
                    "they watching", "from the dirt", "that's my dog", "never changed",
                    "they don't know me", "different breed", "you know the vibes", "haters gon hate",
                    "too blessed", "I want it all", "that's my nigga", "lock in",
                    "come get it", "still the same", "that's on me", "I ain't going nowhere",
                    "deadass", "American dream", "talk is cheap", "came from nothing",
                    "next up", "it's my time", "I'm next", "risk it all",
                    "from the streets", "new wave", "stay dangerous", "sky's the limit",
                    "I put that on everything", "now we here", "till the wheels fall off", "that's him",
                    "come see me", "who you know", "where you from", "live it up",
                    "make it happen", "mix it up", "24/7", "who want smoke",
                    "last laugh", "whatever it takes", "can't stop won't stop", "dollar and a dream",
                    "you only live once", "I don't chase", "case closed", "point blank",
                    "never forget", "old friends", "this is my life", "lost it all",
                    "in the lab", "off the grid", "young king", "front page",
                    "breaking news", "lights camera action", "at all costs", "old soul",
                    "time will tell", "what goes around", "showtime", "nothing to something",
                    "last man standing", "forever young", "who next", "our time",
                    "best of both worlds", "off the map", "play for keeps", "all the way up",
                    "top of the world", "king shit", "boss shit", "10 steps ahead",
                    "watch the throne", "born to win", "destined for greatness", "me against the world",
                    "underdog", "they counted me out", "bounce back", "stand on business",
                    "on my life", "go to war", "war ready", "war time",
                    "no peace", "for the people", "by any means necessary", "the revolution",
                    "come home", "I stand on that", "stand on it", "I ain't never scared",
                    "I ain't never ran", "welcome to my world", "us against the world", "never count me out",
                    "rise up", "on my name", "on my word", "for the team",
                    "on the throne", "wait on it", "to the moon", "leave it all",
                    "need it all", "in the mix", "high key", "who gon stop me",
                    "can't nobody", "can't tell me nothing", "let it ride", "keep your head up",
                    "keep it moving", "never give up", "never quit", "I ain't stopping",
                    "cold hearted", "heartless", "dead to me", "cut you off",
                    "best friends", "my squad", "my pack", "I came up",
                    "living legend", "living proof", "undercovers", "signed a deal",
                    "on tour", "sold out", "living good", "movie star",
                    "packed out", "world tour", "living lavish", "rockstar lifestyle",
                    "mixtape", "every state", "living large", "hell on earth",
                    "through the storm", "born again", "mind games", "I got the sauce",
                    "head to toe", "they hating", "hustle hard", "the grind",
                    "put in work", "move in silence", "after party", "popping bottles",
                    "drop it low", "on the radio", "the Grammys", "red carpet",
                    "paparazzi", "in my zone", "hit a lick", "undefeated",
                    "my homies", "my crew", "my clique", "talking shit",
                    "out of pocket", "it is what it is", "that's a bet", "you feel me",
                    "I ain't gon lie", "lowkey", "on the low", "keep it on the low",
                    "don't tell nobody", "been through hell", "hell and back", "I'm blessed",
                    "I'm chosen", "big facts", "I can't even lie", "on the grind",
                    "big homie", "lil homie", "all my niggas", "my gang",
                    "with the gang", "for my niggas", "my team", "same niggas",
                    "fly private", "private island", "fresh to death", "one of one",
                    "million dollar nigga", "the good life", "tour bus", "around the globe",
                    "on my grind", "two jobs", "blood sweat and tears", "I ain't got time",
                    "no time to waste", "time to get it", "in the cut", "stay down",
                    "project baby", "around the way", "welfare", "bailed out",
                    "my section", "the GOAT", "turn it up", "on stage",
                    "the remix", "the charts", "the DJ", "the clout",
                    "the come up", "make it clap", "on repeat", "in my prime",
                    "on the pole", "Fashion Week", "hit the stage", "went platinum",
                    "record deal", "first week", "Met Gala", "lap dance",
                    "ad-libs", "rockstar shit", "my masters", "no features",
                    "the groupies", "on the cover", "life of sin", "count my blessings",
                    "Sunday service", "pour a four", "Hail Mary", "the playoffs",
                    "boo'd up", "girl of my dreams", "the beat", "on the beat",
                    "rockstar", "superstar", "number one", "the work",
                    "you already know", "don't tell", "my people", "I'm good",
                    "I'm straight", "my dawgs", "another one", "believe that",
                    "it's over", "the safe", "the strip", "independent",
                    "the label", "know what I'm saying", "get low", "that's a fact",
                    "going up", "good girl", "bad girl", "never stop",
                    "I can't stop", "I won't stop", "I'm rolling", "hit me up",
                    "what you sayin", "what you on", "the homies", "here we go",
                    "I'm him", "out of line", "the clique", "between us",
                    "the album", "it's going down", "I'm different", "they talking",
                    "pretty girls", "how you want it", "playing games", "on the strip",
                    "paperwork", "no rest", "two faced", "pop bottles",
                    "life without", "don't waste my time", "I'm special", "on the same page",
                    "part two", "the sequel", "round two", "change the game",
                    "changed the game", "out of this world", "out of order", "top 5",
                    "top ten", "the trophy", "same team", "we over",
                    "I seen it all", "cloud 9", "new album", "no debate",
                    "putting in work", "we going up", "they switched", "it's poppin",
                    "where they do that at", "they biting", "I been through it all", "grind time",
                    "my rules", "in pocket", "the sauce", "the crew",
                    "out of bounds", "no rules", "my label", "in rotation",
                    "here we go again", "my boys", "the squad", "with my niggas",
                    "I blew up", "stay out my business", "in my business", "summertime",
                    "wintertime", "out of state", "the back door", "ate that",
                    "the audacity", "I said what I said", "on sight", "we don't play",
                    "I don't play about", "don't play with me", "try me", "don't try me",
                    "play with me", "what's the word", "word around town", "they hatin",
                    "the haters", "my haters", "wanna be me", "my lifestyle",
                    "they copy", "steal my style", "hate to see me", "they jealous",
                    "work hard", "stay on my grind", "my hustle", "the hustle",
                    "I been grindin", "early mornings", "pop star", "I'm a legend",
                    "they know my name", "I'm famous", "a feature", "the camera",
                    "washed up", "she trippin", "the hospital", "black hoodie",
                    "hoodie on", "mask on", "mask off", "no mask",
                    "clap back", "my dog", "my dawg", "my bro",
                    "my dogs", "my mom", "my boy", "me and my niggas",
                    "we ain't have", "all my dogs", "all my dawgs", "that's my dawg",
                    "mind your business", "when it rains", "rainy day", "on the come up",
                    "on the rise", "top five", "in town", "I'm in town",
                    "on the map", "in New York", "the front door", "take a trip",
                    "top floor", "light bill", "state to state", "out the country",
                ]),
            ]
        case .apps:
            return [
                NounChipSection(title: "Chat", words: [
                    "FaceTime", "Skype", "OoVoo", "WhatsApp",
                    "iMessage", "Telegram", "Kik", "BBM",
                ]),
                NounChipSection(title: "Social", words: [
                    "Snapchat", "Instagram", "Twitter", "TikTok",
                    "Facebook", "MySpace", "Triller", "Reddit",
                    "Tumblr", "Linktree", "Musically",
                ]),
                NounChipSection(title: "Video", words: [
                    "YouTube", "Twitch", "Periscope", "Netflix",
                    "Hulu", "HBO", "Tubi", "Pornhub",
                ]),
                NounChipSection(title: "Music", words: [
                    "Spotify", "SoundCloud", "Apple Music", "iTunes",
                    "Shazam", "DatPiff", "LiveMixtapes", "Spinrilla",
                    "Bandcamp", "Pro Tools",
                ]),
                NounChipSection(title: "Rides and food", words: [
                    "Uber", "Uber Eats", "Lyft", "DoorDash",
                    "Postmates", "Instacart",
                ]),
                NounChipSection(title: "Maps and stays", words: [
                    "Google Maps", "Waze", "Airbnb",
                ]),
                NounChipSection(title: "Money apps", words: [
                    "Venmo", "PayPal", "Coinbase", "Apple Pay",
                ]),
                NounChipSection(title: "Stores", words: [
                    "eBay", "Craigslist", "Backpage", "StockX",
                    "OfferUp",
                ]),
                NounChipSection(title: "Dating", words: [
                    "Tinder", "OnlyFans", "Grindr",
                ]),
                NounChipSection(title: "News", words: [
                    "TMZ", "WorldStar", "Shade Room",
                ]),
                NounChipSection(title: "Voice", words: [
                    "Alexa",
                ]),
            ]
        case .looks:
            return [
                NounChipSection(title: "Smile", words: [
                    "Dimples", "Colgate smile", "Pearly whites", "Million dollar smile",
                    "Freckles",
                ]),
                NounChipSection(title: "Face", words: [
                    "Pretty face", "Baby face", "Big lips",
                ]),
                NounChipSection(title: "Eyes", words: [
                    "Pretty eyes", "Brown eyes", "Green eyes", "Blue eyes",
                    "Hazel eyes",
                ]),
                NounChipSection(title: "Skin", words: [
                    "Lightskin", "Darkskin", "Redbone", "Yellow bone",
                    "Brown skin", "Melanin", "High yellow", "Caramel skin",
                    "Chocolate skin", "Albino", "Pale skin",
                ]),
                NounChipSection(title: "Body", words: [
                    "Long legs", "She tall", "Six foot", "Slim thick",
                    "Slim waist", "Hourglass", "Coke bottle", "Bad body",
                    "Petite",
                ]),
                NounChipSection(title: "On camera", words: [
                    "in HD", "in 3D", "in 4K",
                ]),
            ]
        }
    }
}
