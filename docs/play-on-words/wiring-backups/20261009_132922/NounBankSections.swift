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
                    "Nuvo", "Belaire", "Champagne", "Champagne Rose", "Don P", "Rosé Spade",
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
                NounChipSection(title: "Wine", words: [
                    "Pinot Grigio",
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
                    "percy", "percocets", "perc 10's", "perky check", "molly percocets",
                    "percocet mollies", "M box", "roxy", "roxies",
                    "xbox",
                ]),
                NounChipSection(title: "Xanax", words: [
                    "xanny bar", "xanax", "xanny", "xans",
                ]),
                NounChipSection(title: "Addys", words: [
                    "addy", "addys", "adderall", "adderall thirty", "addy birkin",
                ]),
                NounChipSection(title: "Molly", words: [
                    "molly water", "molly", "ecstasy", "molly shawty",
                    "bean", "bean green", "bean money",
                ]),
                NounChipSection(title: "Weed", words: [
                    "gas pack", "loud pack", "OG kush", "zaza",
                    "runtz", "gelato", "backwood", "Backwoods", "Keeks", "exotic",
                    "cookies", "za", "kush", "exotic packs",
                    "kush weed", "gelato biscotti", "kush sticky", "kush purple",
                    "kush lean", "blunt", "swisher",
                ]),
                NounChipSection(title: "Cocaine", words: [
                    "fishscale", "white girl", "yayo",
                ]),
                NounChipSection(title: "Pills and powder", words: [
                    "shroom", "shrooms", "fetty", "fentanyl",
                    "oxy", "pill blue", "Whippin' the pot", "acid", "oxy codeine",
                ]),
                NounChipSection(title: "The gear", words: [
                    "bong", "lighter", "scale",
                ]),
            ]
        case .jewelry:
            return [
                NounChipSection(title: "Chains", words: [
                    "Cuban link", "bust down Cuban", "tennis chain", "Bustdown", "Homer hanging",
                ]),
                NounChipSection(title: "Watches", words: [
                    "flooded Patek", "iced out AP", "plain Jane Rollie", "rose Sky-Dweller", "ruby rose", "Arabic dial", "Cartier Crash",
                    "Patek", "Rollie", "Presidential", "AP", "G-Shock", "factory time",
                    "Hublot", "TechnoMarine", "Offshore", "Daytona", "Oyster Perpetual", "Breitlings", "Rolex", "Aventi", "Franck Muller",
                ]),
                NounChipSection(title: "Stones", words: [
                    "VVS pointers", "VVS", "Flooded", "Pointers",
                    "Baguette", "Vs1", "G.I.", "emerald", "rhines", "rubies", "Cubic zirconias",
                ]),
                NounChipSection(title: "Pieces", words: [
                    "tennis bracelet", "flooded belt buckle", "Cartier frames", "Jesus piece",
                    "100k bezel", "Cartier", "Bezel", "Pendant", "Medallion",
                    "Cross", "pinky ring", "earrings", "charm",
                    "necklace", "choker", "bracelet",
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
                    "Chopard", "David Yurman", "Harry Winston", "Jason of Beverly Hills", "Elliot",
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
                    "Chrome Heart skinnies", "Chrome Hearts", "Chrome Heart glasses", "Chrome Hearts jeans", "Matty Boy",
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
                NounChipSection(title: "Banks", words: [
                    "Wells Fargo", "Bank of America",
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
                    "Birkin", "Kelly", "Hermes",
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
                    "Loubs", "red bottoms", "Nike", "Adidas", "Shell Toes",
                    "Jordan", "Visvim", "New Balance", "Converse", "Vans",
                    "Reebok", "Puma", "Golden Goose", "Bapesta",
                    "Force 1", "G-Fazos", "Yeezy", "Crocs", "Uggs",
                    "Timberland", "Smiths", "Hender Scheme", "Jeremy Scotts",
                ]),
                NounChipSection(title: "Jewelry houses", words: [
                    "Tiffany", "Van Cleef", "Bvlgari",
                ]),
                NounChipSection(title: "Tech", words: [
                    "Samsung", "MacBook", "iPad", "Kindle", "Sony", "Motorola",
                    "iPhone", "iPhone X", "Beats", "headphones",
                ]),
                NounChipSection(title: "Streetwear", words: [
                    "Heron Preston", "Telfar", "Sp5der", "Denim Tears",
                    "Ksubi", "Evisu", "Rhude", "Corteiz",
                    "CDG", "Sacai", "Dover Street Market", "RSVP", "Raf Simons", "Helmut Lang", "Alyx",
                    "Ed Hardy", "Sean John", "Pelle Pelle", "FUBU",
                    "Dickies", "Levi's", "G-Star", "Carhartt", "Stussy",
                    "Kith", "Golf Wang", "Cactus Jack", "Human Made",
                    "Casablanca", "Kapital", "Undercover", "Robin jeans", "Yohji",
                    "Thom Browne", "Le Fleur", "Who Decides War", "Truey",
                    "Vlone", "Don C", "Saudi sweats", "Supreme", "Thrasher", "Bape", "Vetements",
                    "Coogi", "Apple Bottom", "Ray-Bans", "Polo", "Girbaud", "ushanka", "Spitfire", "Snipes", "Bloody Osiris",
                ]),
                NounChipSection(title: "Other houses", words: [
                    "Tom Ford", "Vivienne Westwood", "Canada Goose", "Moschino", "Kenzo",
                    "Loewe", "Issey Miyake", "Michael Kors", "Fashion Nova",
                    "Skims", "Lululemon", "MCM", "Burberry", "Tisci", "Phillip Lim", "Joan Shepp", "Saks", "Neimans", "Ouija", "North Face",
                    "Ferragamo", "Faith Connexion", "man bag", "Moncler", "Marni",
                    "Alexander Mcqueen", "Alexander Wang", "A.P.C.", "Marc Jacobs", "John Deere", "Johnson & Johnson", "Walmart", "CVS", "Tums", "Plan B", "Barneys", "Avon", "Chevron", "Trojan",
                    "Similac", "Huggies", "Hugo", "Benny", "Bergdorf", "Turo",
                ]),
                NounChipSection(title: "McDonald's", words: [
                    "Happy Meal",
                ]),
                NounChipSection(title: "News", words: [
                    "Al Jazeera", "Rolling Stone", "Vogue", "FM", "23 and me",
                ]),
                NounChipSection(title: "Equinox", words: [
                    "Equinox",
                ]),
                NounChipSection(title: "Progressive", words: [
                    "Progressive",
                ]),
                NounChipSection(title: "Velcro", words: [
                    "Velcro",
                ]),
                NounChipSection(title: "Yoropiko", words: [
                    "Europeako",
                ]),
                NounChipSection(title: "Jergens", words: [
                    "Jergens",
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
                    "raincoat", "blazer", "poncho",
                ]),
                NounChipSection(title: "Bottoms", words: [
                    "rockstar jeans", "joggers", "shorts", "jeans",
                    "skirt", "leggings", "sweats", "cargos",
                    "overalls", "khakis", "slacks",
                ]),
                NounChipSection(title: "Shoes", words: [
                    "Foamposites", "timbs", "dunks", "Amiri timbs",
                    "wheat timbs", "heels", "sneakers", "boots", "fur boots",
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
                    "Mac-11", "Desert Eagles", "Smith & Wesson", "Uzi", "P80", "fn",
                    "switchy", "rifle", "shotty", "handheld",
                ]),
                NounChipSection(title: "Parts and ammo", words: [
                    "extendo", "hundred round drum", "red beam", "green beam",
                    "dot", "clip", "clips", "ammo", "bullets",
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
                    "soo woo", "Su-woop", "Su-woo", "OTF", "Only the Family", "4PF",
                    "Glo Gang", "FBG", "Rollin 60", "FrontStreet",
                    "Sniper Gang", "Lords",
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
                    "lil bro", "big bro", "Akhi",
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
                    "racks", "bands", "guap", "dough", "cabbage", "blue face", "blue cheese", "blue cheddar", "loose cheddar",
                    "money bag", "hunnids", "Hundred K", "big face", "comma",
                    "bankroll", "knot", "rubber bands", "Ben Franklin", "penny", "George Washingtons", "cash register", "custy", "dog shit",
                ]),
                NounChipSection(title: "Apps and cards", words: [
                    "zelle", "cashapp", "paycheck", "black card", "Amex",
                    "credit card", "insurance", "JPays",
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
                    "Lambo", "Urus", "Murciélago",
                ]),
                NounChipSection(title: "Bugatti", words: [
                    "Bugatti",
                ]),
                NounChipSection(title: "Volkswagen", words: [
                    "Beetle",
                ]),
                NounChipSection(title: "Mercedes", words: [
                    "Mercedes", "Benz", "big body Benz", "G-Wagon", "BRABUS", "Maybach",
                    "Black Maybach", "Sprinter", "CL 6", "AMG",
                ]),
                NounChipSection(title: "BMW", words: [
                    "BMW",
                ]),
                NounChipSection(title: "Ford", words: [
                    "Ford", "Saleen",
                ]),
                NounChipSection(title: "Chrysler", words: [
                    "Chrysler",
                ]),
                NounChipSection(title: "Honda", words: [
                    "Honda", "Honda Accord",
                ]),
                NounChipSection(title: "Mazda", words: [
                    "Mazda",
                ]),
                NounChipSection(title: "Toyota", words: [
                    "Toyota", "Corolla",
                ]),
                NounChipSection(title: "DeLorean", words: [
                    "DeLorean",
                ]),
                NounChipSection(title: "Lexus", words: [
                    "Lexus",
                ]),
                NounChipSection(title: "Nissan", words: [
                    "Nissan", "GTR",
                ]),
                NounChipSection(title: "Subaru", words: [
                    "Subaru",
                ]),
                NounChipSection(title: "Range Rover", words: [
                    "Range Rover", "white Range Rover", "Fuji white Rover", "Land Rover",
                ]),
                NounChipSection(title: "Rolls-Royce", words: [
                    "Wraith", "Cullinan", "Phantom", "Ghost", "Rolls", "Double R",
                ]),
                NounChipSection(title: "Bentley", words: [
                    "Bentley", "Bentayga", "Bentley Mulsanne", "frog-eye",
                ]),
                NounChipSection(title: "Jaguar", words: [
                    "Jag",
                ]),
                NounChipSection(title: "Aston Martin", words: [
                    "Aston",
                ]),
                NounChipSection(title: "Dodge", words: [
                    "Hellcat", "Demon", "Charger", "Challenger", "scat pack",
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
                    "Audi", "R8",
                ]),
                NounChipSection(title: "McLaren", words: [
                    "Mclaren", "650S",
                ]),
                NounChipSection(title: "Chevy", words: [
                    "box Chevy", "donk", "Caprice", "Cavalier", "Corvette",
                ]),
                NounChipSection(title: "Cadillac", words: [
                    "Caddy",
                ]),
                NounChipSection(title: "Buick", words: [
                    "Buick Regal",
                ]),
                NounChipSection(title: "Mercury", words: [
                    "Grand Marquis",
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
                    "license plate", "paper plates", "Yokohama",
                ]),
            ]
        case .motorcycles:
            return [
                NounChipSection(title: "Motorcycles", words: [
                    "Harley", "Harley-Davidson", "Ducati", "Yamaha",
                    "Kawasaki", "Can-Am", "KTM", "Suzuki", "Indian",
                ]),
                NounChipSection(title: "Bikes", words: [
                    "bike", "BMX bike", "dirt bike",
                ]),
                NounChipSection(title: "Sport bikes", words: [
                    "Ninja", "R1", "GSXR",
                ]),
            ]
        case .boats:
            return [
                NounChipSection(title: "Boats", words: [
                    "yacht", "boat", "jet ski", "speedboat",
                    "cruise ship", "yacht club", "ferry", "canoe",
                    "dock", "Cigarette Boat",
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
                    "Humvee", "SWAT", "bulletproof truck", "Brinks truck", "submarine",
                    "armored truck", "in a tank", "Secret Service", "AWOL",
                ]),
            ]
        case .places:
            return [
                NounChipSection(title: "Atlanta", words: [
                    "Atlanta", "Zone 6", "Decatur", "Gwinnett",
                    "East Atlanta", "Oakland City", "Magic City", "Follies", "Booby Trap", "Tootsies",
                ]),
                NounChipSection(title: "Chicago", words: [
                    "Chi-town", "O-Block", "Essex",
                ]),
                NounChipSection(title: "Enviyon", words: [
                    "Enviyon",
                ]),
                NounChipSection(title: "Hoover Dam", words: [
                    "Hoover damn",
                ]),
                NounChipSection(title: "Memphis", words: [
                    "Memphis", "South Memphis", "Orange Mound", "Whitehaven",
                ]),
                NounChipSection(title: "Tennessee", words: [
                    "Tennessee",
                ]),
                NounChipSection(title: "Houston", words: [
                    "Houston", "Area 29", "H-Town",
                ]),
                NounChipSection(title: "Miami", words: [
                    "Miami", "Bal Harbour", "the Grove",
                ]),
                NounChipSection(title: "New Orleans", words: [
                    "New Orleans", "Magnolia",
                ]),
                NounChipSection(title: "Philly", words: [
                    "Philly", "North Philly", "32nd and Cumberland", "1600", "the 16", "Francisville",
                ]),
                NounChipSection(title: "Los Angeles", words: [
                    "Los Angeles", "Hollywood", "Hollywood Hills", "Beverly Hills",
                    "Calabasas", "Slauson", "Watts", "Highlight Room", "Malibu",
                ]),
                NounChipSection(title: "New York", words: [
                    "Brooklyn", "Uptown", "Dyckman", "Highbridge", "MoMA", "Starlet's",
                ]),
                NounChipSection(title: "Sides", words: [
                    "hood", "southside", "Northside", "Eastside",
                    "Westside", "bottoms", "Downtown",
                ]),
                NounChipSection(title: "The room", words: [
                    "trap", "stu", "booth", "block",
                    "Penthouse", "Mansion", "Playboy mansion", "dungeon",
                ]),
                NounChipSection(title: "The world", words: [
                    "overseas", "London", "Paris", "Dubai",
                    "Jamaica", "Haiti", "Africa", "Tokyo", "Virgin Islands", "Oklahoma", "Monaco", "Monte Carlo", "Gstaad", "Zurich", "Albany Marina", "Mykonos", "Turks", "the Hamptons", "Rome", "Ibiza", "Giza", "Nile", "Maui", "Kailua", "Hawaii", "Mars", "Birmingham", "Montreal", "St. Lucia", "Russia", "Canada", "France", "Alabama",
                ]),
                NounChipSection(title: "Other cities", words: [
                    "Detroit", "Dallas", "Cleveland", "Oakland", "7 Mile", "734", "Ohio", "Bompton",
                    "Baltimore", "Milwaukee", "Savannah",
                    "Portland", "San Diego", "Washington", "Indianapolis", "Cincinnati", "DC", "Timmins", "Woodward", "Texas",
                ]),
                NounChipSection(title: "Toronto", words: [
                    "Weston Road", "Scarlett Road", "Fort York", "Money Mart",
                    "the 6", "Morningside", "6ix God", "Ceesay's", "from the Jane", "G Block",
                    "East Detention", "Pine Hill Funeral Center", "D-Block", "G-Way", "6ixside", "Kennedy Road", "Parma", "Forest Hill", "Richmond", "T-Dot",
                ]),
                NounChipSection(title: "Resorts", words: [
                    "Courchevel", "Grace Bay", "Lake Como",
                ]),
                NounChipSection(title: "Restaurants", words: [
                    "Giorgio Baldi", "Madeo", "Serafina", "Carbone", "TAO", "Buddakan", "at Cheesecake",
                ]),
                NounChipSection(title: "Hotels", words: [
                    "Best Western", "Royal Palace", "Dream Hotel", "Hazelton", "club at Edition", "Post Oak", "the Derek", "SoHo, Cosmo", "the Wynn", "Ritz-Carlton", "Radisson", "SLS",
                ]),
                NounChipSection(title: "Clubs", words: [
                    "Cinquante-Cinq", "6 Degrees", "Delilah", "Playhouse",
                ]),
                NounChipSection(title: "Schools", words: [
                    "Parsons", "Bayside", "Howard", "Cambridge", "St. Vincent-St. Mary's", "Loyola",
                ]),
            ]
        case .producers:
            return [
                NounChipSection(title: "Atlanta", words: [
                    "Metro Boomin", "Wheezy", "ATL Jacob", "Zaytoven",
                    "Southside on the Track", "London on da Track", "Mike Will", "Lex Luger",
                    "Dun Deal", "Bangladesh", "TM88", "Drumma Boy",
                    "Outtatown", "Pi'erre Bourne", "Jermaine Dupri", "DJ Drama",
                    "DY Krazy", "808 Mafia", "Gezin", "Purps",
                ]),
                NounChipSection(title: "Los Angeles", words: [
                    "Mustard", "Hit-Boy", "Dr Dre", "Alchemist",
                    "Madlib", "Babyface",
                ]),
                NounChipSection(title: "Virginia", words: [
                    "Pharrell", "I am OTHER", "Timbaland",
                ]),
                NounChipSection(title: "Memphis", words: [
                    "Tay Keith",
                ]),
                NounChipSection(title: "Philly", words: [
                    "BNYX", "F1lthy", "Working On Dying", "Oogie Mane", "Maaly Raw", "Loosie Man", "Scott Storch",
                ]),
                NounChipSection(title: "New York", words: [
                    "Just Blaze", "DJ Premier", "DJ Clue", "Daytrip",
                ]),
                NounChipSection(title: "Miami", words: [
                    "Honorable C.N.O.T.E.", "Ronny J",
                ]),
                NounChipSection(title: "Toronto", words: [
                    "T-Minus", "Boi-1da", "Murda Beatz", "40", "Oli", "Oliver",
                ]),
                NounChipSection(title: "New Orleans", words: [
                    "Mannie Fresh",
                ]),
                NounChipSection(title: "Texas", words: [
                    "Cardo",
                ]),
                NounChipSection(title: "Yung Exclusive", words: [
                    "Yung Exclusive",
                ]),
                NounChipSection(title: "G. Ry", words: [
                    "G. Ry",
                ]),
                NounChipSection(title: "ChopsquadDJ", words: [
                    "Chopsquad",
                ]),
                NounChipSection(title: "Marshmello", words: [
                    "Mello",
                ]),
                NounChipSection(title: "Mobile", words: [
                    "Al Geno",
                ]),
                NounChipSection(title: "Supah Mario", words: [
                    "Mario",
                ]),
                NounChipSection(title: "Bugz", words: [
                    "Bugz",
                ]),
                NounChipSection(title: "Kirk Kneezy", words: [
                    "Kirk Kneezy",
                ]),
            ]
        case .artists:
            return [
                NounChipSection(title: "Cash Money", words: [
                    "Birdman", "Wayne", "Drake", "Drizzy", "Nicki",
                    "Tyga", "Gudda Gudda", "Young Money", "YMCMB", "YMB", "Dwayne Michael Carter", "Hot boy",
                ]),
                NounChipSection(title: "October Firm", words: [
                    "October Firm",
                ]),
                NounChipSection(title: "OVO", words: [
                    "OVO",
                ]),
                NounChipSection(title: "Interscope", words: [
                    "Interscope",
                ]),
                NounChipSection(title: "Slaughter Gang", words: [
                    "Slaughter Gang",
                ]),
                NounChipSection(title: "GS9", words: [
                    "GS9",
                ]),
                NounChipSection(title: "New Edition", words: [
                    "New Edition",
                ]),
                NounChipSection(title: "Young Stoner Life", words: [
                    "Thugger", "Thug and 'nem", "Gunna", "Lil Duke", "Unfoonk",
                    "Tadoe", "Lil Keed", "Lil Gotit", "Omelly",
                ]),
                NounChipSection(title: "Quality Control", words: [
                    "Migos", "Quavo", "Offset", "Takeoff",
                    "Lil Baby", "Lil Dan", "Lil Yachty", "Yung Miami",
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
                    "Kendrick", "Ab-Soul",
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
                NounChipSection(title: "The Beatles", words: [
                    "The Beatles",
                ]),
                NounChipSection(title: "Black Sabbath", words: [
                    "Black Sabbath",
                ]),
                NounChipSection(title: "Makonnen", words: [
                    "Makonnen",
                ]),
                NounChipSection(title: "UGK", words: [
                    "Bun B", "Pimp C", "underground kings",
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
                    "Carti", "Bash Barti", "Ken Carson", "Homixide Gang",
                ]),
                NounChipSection(title: "Death Row", words: [
                    "2Pac", "Suge", "Snoop Dogg",
                ]),
                NounChipSection(title: "Bad Boy", words: [
                    "Biggie", "Diddy",
                ]),
                NounChipSection(title: "Houston", words: [
                    "Travis Scott", "Megan", "Paul Wall", "Mike Jones",
                    "Slim Thug", "Chamillionaire", "Trae tha Truth", "DJ Screw", "Screwed Up Click", "OG Ron C",
                ]),
                NounChipSection(title: "Atlanta", words: [
                    "Future", "21 Savage", "Latto", "Ludacris",
                    "Lil Jon", "SahBabii", "Young Nudy", "Kap G",
                    "Soulja Boy", "Yung Joc", "Trinidad James",
                ]),
                NounChipSection(title: "Chicago", words: [
                    "G Herbo", "Lupe", "Twista", "Juice WRLD", "Kanye",
                ]),
                NounChipSection(title: "New York", words: [
                    "Nas", "Jay-Z", "Dame", "Hova", "50 Cent", "Cardi B",
                    "Ice Spice", "Fivio Foreign", "Pop Smoke", "Big Pun",
                    "LL Cool J", "Flavor Flav", "Slick Rick", "Busta Rhymes",
                    "Fat Joe", "French Montana", "Max B", "Rakim",
                    "DMX", "A Boogie", "Lil Kim", "Ja Rule",
                    "Papoose", "Fabolous", "Foxy Brown", "Jam Master Jay",
                    "Kay Flock",
                    "Lil Peep", "Chinx", "Afu-Ra", "Shmurda",
                ]),
                NounChipSection(title: "New Jersey", words: [
                    "Uzi", "Coi Leray", "Redman",
                ]),
                NounChipSection(title: "Los Angeles", words: [
                    "Nipsey", "The Game", "Eazy-E", "Roddy Ricch",
                    "Ice-T", "Ice Cube", "Big U",
                ]),
                NounChipSection(title: "Detroit", words: [
                    "Eminem", "Big Sean", "DeJ Loaf", "Veeze", "Tee Grizzley", "J Dilla", "Stax", "Dae",
                ]),
                NounChipSection(title: "Baton Rouge", words: [
                    "YoungBoy", "Boosie", "Webbie",
                ]),
                NounChipSection(title: "St. Louis", words: [
                    "Sexyy Red", "Nelly", "Chingy",
                ]),
                NounChipSection(title: "Florida", words: [
                    "Kodak", "DJ Khaled", "Rod Wave",
                ]),
                NounChipSection(title: "Toronto", words: [
                    "Tory Lanez", "NAV", "Baka", "Roy Woods", "Smoke Dawg", "Puffy L'z", "Preme",
                ]),
                NounChipSection(title: "Dancehall", words: [
                    "Kartel", "Popcaan", "Sean Paul",
                ]),
                NounChipSection(title: "Soca", words: [
                    "soca", "Machel Montano",
                ]),
                NounChipSection(title: "Rappers", words: [
                    "Yeat", "NoCap", "Bow Wow", "Will Smith", "Pusha T",
                    "Mac Miller", "Mystikal", "Saweetie", "DaBaby",
                    "Petey Pablo", "Rubi Rose", "Master P", "Meek",
                    "Lil Mouse", "AR-AB", "Jermaine", "Stunna Sandy", "Nickel F", "Aristo", "Stizzy", "Tjay", "Hunxho", "JT", "Desto", "Chinese Kitty", "Gilly", "Jodye Flacko", "Wiz", "V.I.C.", "Hoodbaby", "Skeme", "Quan", "Doll", "Kodie",
                ]),
                NounChipSection(title: "Singers", words: [
                    "Doja", "Jeremih", "Iggy", "Beyonce",
                    "Rihanna", "Michael Jackson", "Jimi Hendrix", "Elvis", "Selena",
                    "JLo", "Adele", "Taylor Swift", "Aaliyah",
                    "Mariah", "Whitney", "Usher", "Bieber",
                    "Madonna", "Britney", "Aretha", "Sinatra",
                    "Lady Gaga", "Queen Latifah", "Ciara", "Janet",
                    "Tina Turner", "Diana Ross", "Alicia", "John Legend",
                    "Lauryn", "Erykah", "Solange", "Shakira",
                    "Timberlake", "Trey Songz", "Kehlani", "Jhene",
                    "Teyana", "Tyrese", "Jamie Foxx", "Jill Scott", "Demi Lovato",
                    "Sisqo", "Ginuwine", "Kelly Rowland", "R Kelly",
                    "Bob Marley", "Shaggy", "Bobby Brown", "Sade", "Mary J",
                    "Ashanti", "Katy Perry", "Omarion", "Anita Baker",
                    "Bryson Tiller", "Keyshia Cole", "Ariana", "Patti Labelle",
                    "SZA", "Frank Ocean", "Daniel Caesar", "John Lennon", "Chris Brown", "Summer Walker",
                    "Akon", "PartyNextDoor", "Wyclef",
                    "Ray J", "Brandy", "Ray Charles", "Stevie",
                    "Jodeci", "Jagged Edge", "Voyce", "Missy", "Ashley Simpson",
                    "J. Balvin", "Chico DeBarge", "Milli Vanilli", "TLC", "Chilli", "Kravitz", "T-Pain", "CeCe Winans", "Ozzy",
                ]),
                NounChipSection(title: "Reps Up", words: [
                    "Reps Up",
                ]),
                NounChipSection(title: "Tribe Called Quest", words: [
                    "Ali Shaheed", "Phife Dawg",
                ]),
                NounChipSection(title: "Drums", words: [
                    "Larnell Lewis",
                ]),
                NounChipSection(title: "Dolly", words: [
                    "Dolly", "Dora", "Max",
                ]),
                NounChipSection(title: "Marching band", words: [
                    "snare", "marching band",
                ]),
                NounChipSection(title: "Surf Club", words: [
                    "Surf Club",
                ]),
            ]
        case .nba:
            return [
                NounChipSection(title: "Lakers", words: [
                    "Kobe", "Shaq", "Magic Johnson", "Kareem",
                    "Wilt", "Lamar Odom",
                ]),
                NounChipSection(title: "Bulls", words: [
                    "Michael Jordan", "Jordan meme", "Pippen", "Rodman", "Craig Hodges", "D-Rose", "Luol Deng", "Tyler Ulis",
                ]),
                NounChipSection(title: "Warriors", words: [
                    "Steph", "Barbosa", "Klay", "KD", "Draymond", "Curry",
                ]),
                NounChipSection(title: "Spurs", words: [
                    "Tim Duncan", "Tony Parker", "Ginobili", "Kawhi",
                ]),
                NounChipSection(title: "Celtics", words: [
                    "Larry Bird", "Scalabrine", "Tatum", "KG", "Paul Pierce",
                    "Ray Allen", "Rondo",
                ]),
                NounChipSection(title: "Cavaliers", words: [
                    "LeBron", "Kyrie",
                ]),
                NounChipSection(title: "Heat", words: [
                    "D-Wade", "Jimmy Butler", "Tyler Herro", "Chalmers",
                ]),
                NounChipSection(title: "Pistons", words: [
                    "Cade Cunningham", "Pistons",
                ]),
                NounChipSection(title: "Thunder", words: [
                    "Westbrook", "Raymond Felton", "OKC Thunder",
                ]),
                NounChipSection(title: "Rockets", words: [
                    "Harden", "Yao Ming", "Hakeem", "McGrady",
                ]),
                NounChipSection(title: "Mavericks", words: [
                    "Dirk", "Maverick", "Luka",
                ]),
                NounChipSection(title: "Suns", words: [
                    "Steve Nash", "Booker", "Barkley", "Ricky Rubio",
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
                    "CP3", "Blake Griffin", "JJ Redick", "Lou Will",
                ]),
                NounChipSection(title: "Sixers", words: [
                    "Iverson", "Dr J", "Julius Erving",
                ]),
                NounChipSection(title: "Bucks", words: [
                    "Giannis", "Greek Freak", "Tony Snell",
                ]),
                NounChipSection(title: "Blazers", words: [
                    "Lillard",
                ]),
                NounChipSection(title: "Grizzlies", words: [
                    "Ja Morant",
                ]),
                NounChipSection(title: "Hawks", words: [
                    "Trae Young", "Trey Young",
                ]),
                NounChipSection(title: "Raptors", words: [
                    "DeRozan", "Vince Carter",
                ]),
                NounChipSection(title: "Nuggets", words: [
                    "Jokic", "Mutombo",
                ]),
                NounChipSection(title: "Pelicans", words: [
                    "Zion", "Anthony Davis", "Pelicans",
                ]),
                NounChipSection(title: "Hornets", words: [
                    "Lonzo", "Big Baller", "Lonzo Ball",
                ]),
                NounChipSection(title: "Timberwolves", words: [
                    "Andrew Wiggins",
                ]),
                NounChipSection(title: "Wizards", words: [
                    "John Wall",
                ]),
                NounChipSection(title: "Coaches", words: [
                    "Luke Walton",
                ]),
                NounChipSection(title: "Nets", words: [
                    "Jason Kidd",
                ]),
                NounChipSection(title: "Royals", words: [
                    "Oscar Robertson",
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
                    "Jerry Rice", "Kaepernick", "Michael Crabtree",
                ]),
                NounChipSection(title: "Packers", words: [
                    "Favre", "Aaron Rodgers",
                ]),
                NounChipSection(title: "Ravens", words: [
                    "Ray Lewis", "Lamar Jackson", "Michael Oher",
                ]),
                NounChipSection(title: "Falcons", words: [
                    "Vick", "Julio Jones", "TJ Duckett", "Matt Ryan",
                ]),
                NounChipSection(title: "Lions", words: [
                    "Megatron",
                ]),
                NounChipSection(title: "Giants", words: [
                    "Odell", "Eli Manning",
                ]),
                NounChipSection(title: "Panthers", words: [
                    "Cam Newton",
                ]),
                NounChipSection(title: "Colts", words: [
                    "Peyton", "Andrew Luck",
                ]),
                NounChipSection(title: "Seahawks", words: [
                    "Marshawn",
                ]),
                NounChipSection(title: "Bengals", words: [
                    "Ochocinco", "Wallace Gilberry",
                ]),
                NounChipSection(title: "Raiders", words: [
                    "Bo Jackson", "Derek Carr",
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
                    "OJ", "Josh Allen",
                ]),
                NounChipSection(title: "Vikings", words: [
                    "Randy Moss",
                ]),
                NounChipSection(title: "Steelers", words: [
                    "Roethlisberger", "Pittsburgh Steelers",
                ]),
                NounChipSection(title: "Browns", words: [
                    "Colt McCoy",
                ]),
                NounChipSection(title: "Texans", words: [
                    "Tank Dell", "J.J Watts",
                ]),
                NounChipSection(title: "Cardinals", words: [
                    "Kyler Murray", "Cardinals",
                ]),
                NounChipSection(title: "Buccaneers", words: [
                    "Shilo Sanders",
                ]),
            ]
        case .boxing:
            return [
                NounChipSection(title: "Boxing", words: [
                    "Mayweather", "Mike Tyson", "Muhammad Ali", "Cassius", "Pacquiao",
                    "Holyfield", "Foreman", "De La Hoya", "Tank Davis",
                    "Wilder", "Joe Frazier", "Sonny Liston", "Gervonta",
                ]),
            ]
        case .sports:
            return [
                NounChipSection(title: "Soccer", words: [
                    "Messi", "Beckham", "soccer", "off-sides", "PSG", "Luis Enrique",
                ]),
                NounChipSection(title: "Tennis", words: [
                    "Serena", "Rafael Nadal",
                ]),
                NounChipSection(title: "Golf", words: [
                    "Tiger Woods",
                ]),
                NounChipSection(title: "Track", words: [
                    "Usain", "Lolo Jones",
                ]),
                NounChipSection(title: "Swimming", words: [
                    "Phelps", "Michael Phelps",
                ]),
                NounChipSection(title: "Martial arts", words: [
                    "Bruce Lee", "Jackie Chan", "Judo",
                ]),
                NounChipSection(title: "Baseball", words: [
                    "Jeter", "Barry Bonds", "Sammy Sosa", "Babe Ruth", "Rickey Henderson",
                ]),
                NounChipSection(title: "Hockey", words: [
                    "Gretzky",
                ]),
                NounChipSection(title: "Fighting", words: [
                    "McGregor", "Ronda", "Anderson Silva",
                ]),
                NounChipSection(title: "Coaches", words: [
                    "Nick Saban", "Rick Pitino", "Calipari",
                ]),
                NounChipSection(title: "Bucks", words: [
                    "Antetokounmpo",
                ]),
                NounChipSection(title: "Nascar", words: [
                    "Danica",
                ]),
                NounChipSection(title: "Skating", words: [
                    "Terry Kennedy", "snowboard",
                ]),
                NounChipSection(title: "Wrestling", words: [
                    "WWF", "Trish Stratus",
                ]),
                NounChipSection(title: "Jesse White", words: [
                    "Jesse White",
                ]),
            ]
        case .celebs:
            return [
                NounChipSection(title: "Film", words: [
                    "Denzel", "Will Smith", "Pacino", "De Niro",
                    "Leonardo", "Brad Pitt", "Jamie Foxx", "Tom Cruise",
                    "Vin Diesel", "Chris Tucker", "Jada", "Halle",
                    "Angelina", "Zendaya", "Jennifer Lawrence", "Julia Roberts", "Marilyn", "Nia Long",
                    "Taraji", "Paul Walker", "Sanaa", "Forest Whitaker",
                    "Bruce Willis", "Keanu", "Larenz Tate", "Johnny Depp",
                    "John Wayne", "Meagan Good", "Lindsay Lohan", "Hilary Duff", "Vivica",
                    "Joe Pesci", "Cousin Vinny", "Spike Lee", "Hype Williams", "Lorraine", "Drew Barrymore",
                ]),
                NounChipSection(title: "Comedy", words: [
                    "Tyler Perry", "Eddie Murphy", "Chris Rock", "Kevin Hart",
                    "Dave Chappelle", "Martin Lawrence", "Bernie Mac", "Jim Carrey",
                    "Steve Harvey", "Kenan", "Kel", "Will Ferrell", "Bill Bellamy",
                    "Cosby", "Leslie Jones",
                ]),
                NounChipSection(title: "Television", words: [
                    "Oprah", "Maury", "Dr Phil", "Judge Judy",
                    "Wendy Williams", "Paris Hilton", "Tyra", "Arsenio",
                    "Jerry Springer", "Nick Cannon", "Martha Stewart", "Jimmy Fallon", "Elmo", "Gracie Bon", "Wheelchair Jimmy", "Tim Westwood", "SportsCenter", "Crime Stoppers", "ElimiDate", "Jaleel", "Tamera", "Tia", "Jassie", "Miss Cleo", "Malcolm in the Middle", "Mister Rogers",
                ]),
                NounChipSection(title: "The Kardashians", words: [
                    "Kim K", "Kylie", "Khloe", "Blac Chyna",
                    "Amber Rose",
                ]),
                NounChipSection(title: "Leaders", words: [
                    "Obama", "Trump", "Malcolm X", "Rosa Parks",
                    "MLK", "Coretta", "Farrakhan", "Harriet", "Hillary",
                    "Biden", "Sharpton", "Garvey", "Castro",
                    "Saddam", "Kim Jong", "Noriega", "Roosevelt", "Diana",
                ]),
                NounChipSection(title: "Business", words: [
                    "Elon", "Bill Gates", "G-Money", "Mohamed Hadid", "Maverick Carter", "Richie Akiva", "Ms. Rhone", "Wafi",
                ]),
                NounChipSection(title: "Daredevils", words: [
                    "Evel Knievel",
                ]),
                NounChipSection(title: "Crime figures", words: [
                    "Escobar", "Chapo", "Griselda Blanco", "Genovese", "Big Meech", "Rayful", "Boston George",
                ]),
                NounChipSection(title: "G-Weed", words: [
                    "G-Weed",
                ]),
                NounChipSection(title: "Chico", words: [
                    "Chico",
                ]),
                NounChipSection(title: "Playboy", words: [
                    "Hugh Hefner", "bunny",
                ]),
                NounChipSection(title: "Pearce", words: [
                    "Pearce",
                ]),
                NounChipSection(title: "YellowDol", words: [
                    "YellowDol",
                ]),
                NounChipSection(title: "Law", words: [
                    "Johnnie Cochran",
                ]),
                NounChipSection(title: "History", words: [
                    "Helen Keller", "Adolf", "Tut", "Jackie Onassis", "John Kennedy", "Martin Luther",
                ]),
                NounChipSection(title: "Doctors", words: [
                    "Dr. Miami",
                ]),
                NounChipSection(title: "Art", words: [
                    "Warhol", "KAWS", "Murakami",
                ]),
                NounChipSection(title: "Writers", words: [
                    "John Ghrisam",
                ]),
            ]
        case .characters:
            return [
                NounChipSection(title: "Scarface", words: [
                    "Scarface", "Tony Montana",
                ]),
                NounChipSection(title: "Friday", words: [
                    "Deebo", "Big Worm", "Craig", "Smokey", "Ms. Pearly",
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
                    "O-Dog", "Caine",
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
                    "Batman", "Catwoman", "Joker", "Two-Face", "Superman",
                    "Wonder Woman",
                ]),
                NounChipSection(title: "Marvel", words: [
                    "Marvel", "Black Panther", "Thor", "Thanos", "Wolverine",
                    "Hulk", "Iron Man", "Spider-Man",
                ]),
                NounChipSection(title: "Star Wars", words: [
                    "Darth Vader", "Yoda", "Skywalker", "Anakin",
                ]),
                NounChipSection(title: "The Matrix", words: [
                    "Neo", "red pill",
                ]),
                NounChipSection(title: "Lilo and Stitch", words: [
                    "Lilo and Stitch",
                ]),
                NounChipSection(title: "Betty Crocker", words: [
                    "Betty Crocker",
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
                    "SpongeBob", "Bikini Bottom",
                ]),
                NounChipSection(title: "Candace", words: [
                    "Candace",
                ]),
                NounChipSection(title: "Rocket Power", words: [
                    "Otto",
                ]),
                NounChipSection(title: "Stuart Little", words: [
                    "Stuart",
                ]),
                NounChipSection(title: "Lord of the Rings", words: [
                    "Smeagol",
                ]),
                NounChipSection(title: "Mortal Kombat", words: [
                    "Jax",
                ]),
                NounChipSection(title: "Mario Kart", words: [
                    "Mario Kart",
                ]),
                NounChipSection(title: "Ed, Edd n Eddy", words: [
                    "Ed, Edd n Eddy",
                ]),
                NounChipSection(title: "Dennis the Menace", words: [
                    "Dennis the Menace",
                    "Mr. Wilson",
                ]),
                NounChipSection(title: "Shrek", words: [
                    "Shrek",
                ]),
                NounChipSection(title: "The Lion King", words: [
                    "Simba", "Mufasa",
                ]),
                NounChipSection(title: "E.T.", words: [
                    "phone home",
                ]),
                NounChipSection(title: "Dragon Ball", words: [
                    "Dragon Ball", "Goku", "Krillin", "Super Saiyan", "Vegeta", "Gohan", "Frieza",
                ]),
                NounChipSection(title: "Naruto", words: [
                    "Naruto", "Sasuke",
                ]),
                NounChipSection(title: "Pokémon", words: [
                    "Pikachu", "Mewtwo",
                ]),
                NounChipSection(title: "Looney Tunes", words: [
                    "Bugs Bunny",
                ]),
                NounChipSection(title: "Scooby-Doo", words: [
                    "Scooby Doo", "Scooby",
                ]),
                NounChipSection(title: "Danny Phantom", words: [
                    "Danny Phantom",
                ]),
                NounChipSection(title: "Power Ranger", words: [
                    "Power Ranger",
                ]),
                NounChipSection(title: "The Flintstones", words: [
                    "Flintstone",
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
                NounChipSection(title: "Like Mike", words: [
                    "Calvin Cambridge",
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
                NounChipSection(title: "Sam-I-Am", words: [
                    "Sam-I-Am",
                ]),
                NounChipSection(title: "Mad Hatter", words: [
                    "Mad Hatter",
                ]),
                NounChipSection(title: "Hercules", words: [
                    "Perc-ules",
                ]),
                NounChipSection(title: "G.I. Joe", words: [
                    "G.I. Joe",
                ]),
                NounChipSection(title: "G.I. Jane", words: [
                    "G.I. Jane",
                ]),
                NounChipSection(title: "Winnie the Pooh", words: [
                    "Winnie the Pooh",
                ]),
                NounChipSection(title: "Hello Kitty", words: [
                    "Hello Kitty",
                ]),
                NounChipSection(title: "The Simpsons", words: [
                    "Bart Simpson", "Homer", "Simpsons",
                ]),
                NounChipSection(title: "Mickey Mouse", words: [
                    "Mickey", "Mickey Mouse", "Minnie", "Donald Duck",
                ]),
                NounChipSection(title: "South Park", words: [
                    "Cartman", "Kenny", "South Park",
                ]),
                NounChipSection(title: "Regular Show", words: [
                    "Rigby",
                ]),
                NounChipSection(title: "Baby Boy", words: [
                    "Baby Boy",
                ]),
                NounChipSection(title: "Safe House", words: [
                    "Safe House",
                ]),
                NounChipSection(title: "Do the Right Thing", words: [
                    "Do the Right Thing", "Sal's",
                ]),
                NounChipSection(title: "Pretty Woman", words: [
                    "Pretty Woman",
                ]),
                NounChipSection(title: "Bye Bye Birdie", words: [
                    "Bye Bye Birdie",
                ]),
                NounChipSection(title: "Hellraiser", words: [
                    "Hellraiser",
                ]),
                NounChipSection(title: "The Grudge", words: [
                    "The Grudge",
                ]),
                NounChipSection(title: "Devil May Cry", words: [
                    "Devil May Cry",
                ]),
                NounChipSection(title: "Ren and Stimpy", words: [
                    "Ren", "Stimpy",
                ]),
                NounChipSection(title: "Monopoly", words: [
                    "Monopoly",
                ]),
                NounChipSection(title: "Jack and Jill", words: [
                    "Jack", "Jill",
                ]),
                NounChipSection(title: "Jack and the Beanstalk", words: [
                    "fee-fi-fo",
                ]),
                NounChipSection(title: "Family Guy", words: [
                    "Family Guy",
                ]),
                NounChipSection(title: "Rugrats", words: [
                    "Rugrats", "Reptar",
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
                NounChipSection(title: "Ninja Turtles", words: [
                    "Ninja Turtles", "Master Splinter",
                ]),
                NounChipSection(title: "Thomas the Tank Engine", words: [
                    "Thomas",
                ]),
                NounChipSection(title: "Everybody Loves Raymond", words: [
                    "Raymond",
                ]),
                NounChipSection(title: "Degrassi", words: [
                    "Degrassi",
                ]),
                NounChipSection(title: "Breaking Bad", words: [
                    "Fring",
                ]),
                NounChipSection(title: "Hunger Games", words: [
                    "Hunger Games",
                ]),
                NounChipSection(title: "Ocean's Twelve", words: [
                    "Ocean's Twelve",
                ]),
                NounChipSection(title: "Sesame Street", words: [
                    "Ernie", "Bert",
                ]),
                NounChipSection(title: "Books", words: [
                    "48 Laws",
                ]),
                NounChipSection(title: "Paid in Full", words: [
                    "Kermit",
                ]),
                NounChipSection(title: "Soul Plane", words: [
                    "Soul Plane",
                ]),
                NounChipSection(title: "Mr. Postman", words: [
                    "Mr. Postman",
                ]),
                NounChipSection(title: "White Chicks", words: [
                    "White Chicks",
                ]),
                NounChipSection(title: "Hannah Montana", words: [
                    "Hannah Montana",
                ]),
                NounChipSection(title: "8 Mile", words: [
                    "8 Mile",
                ]),
                NounChipSection(title: "Jason's Lyric", words: [
                    "Jason's Lyric",
                ]),
                NounChipSection(title: "Cupid", words: [
                    "Cupid",
                ]),
            ]
        case .animals:
            return [
                NounChipSection(title: "Big cats", words: [
                    "lion", "tiger", "cheetah",
                    "leopard", "panther",
                ]),
                NounChipSection(title: "Apes and monkeys", words: [
                    "gorilla", "Harambe", "ape", "monkey",
                    "chimp", "baboon",
                ]),
                NounChipSection(title: "Safari", words: [
                    "zebra", "elephant", "hyena", "kangaroo",
                    "koala", "hippo", "giraffe",
                ]),
                NounChipSection(title: "Reptiles", words: [
                    "dinosaur", "pterodactyl", "komodo", "snake",
                    "snakes in the grass", "cobra", "python",
                    "anaconda", "lizard", "iguana", "alligator",
                    "crocodile", "gator", "croc",
                    "frog", "turtle", "tortoise",
                ]),
                NounChipSection(title: "Sea", words: [
                    "shark", "great white", "whale",
                    "dolphin", "fish", "goldfish", "piranha",
                    "eel", "octopus", "starfish", "snail",
                    "nemo",
                ]),
                NounChipSection(title: "Farm", words: [
                    "pig", "hog", "cow",
                    "turkey", "sheep", "black sheep",
                    "donkey", "mule", "llama",
                ]),
                NounChipSection(title: "Dogs", words: [
                    "pitbull", "pit bull", "pits",
                    "rottweiler", "doberman", "k9", "poodle",
                    "puppy", "mutt", "Great Dane", "Huskies",
                ]),
                NounChipSection(title: "Birds", words: [
                    "pigeon", "dove", "owl", "vulture",
                    "seagull", "rooster", "flamingo", "parrot",
                    "penguin", "raven", "hawk", "ostrich",
                ]),
                NounChipSection(title: "Other animals", words: [
                    "wolf", "bear",
                    "polar bear", "grizzly", "deer", "rabbit",
                    "squirrel", "mouse", "rat",
                    "lab rat", "possum", "leech",
                ]),
                NounChipSection(title: "Myth", words: [
                    "unicorn", "dragon",
                ]),
                NounChipSection(title: "Parts", words: [
                    "king of the jungle", "claws", "whiskers", "feathers",
                    "venom",
                ]),
                NounChipSection(title: "Cells", words: [
                    "amoeba",
                ]),
            ]
        case .insects:
            return [
                NounChipSection(title: "Stingers", words: [
                    "bee", "bumble bee", "beehive",
                    "hornet",
                ]),
                NounChipSection(title: "Biters", words: [
                    "mosquito", "flea",
                    "tick", "lice", "gnat",
                ]),
                NounChipSection(title: "Crawlers", words: [
                    "ant", "roach", "spider", "chafer",
                    "centipede", "cricket", "maggot",
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
                    "steak", "veal", "wagyu", "filet", "filet mignon",
                    "steak and lobster", "shrimp", "lobster", "lobster tail",
                    "swordfish", "sushi", "salmon", "trout", "seafood",
                    "calamari", "oysters", "fish fry", "red lobster",
                    "nobu", "benihana", "hibachi", "teriyaki",
                    "ruth's chris",
                ]),
                NounChipSection(title: "Pasta and noodles", words: [
                    "spaghetti", "ramen", "lo mein", "chopstick", "fried rice",
                    "lasagna", "alfredo", "wonton",
                ]),
                NounChipSection(title: "Vegetables", words: [
                    "pea pod", "romaine",
                ]),
                NounChipSection(title: "Southern", words: [
                    "collard greens", "gumbo", "soul food", "cornbread",
                    "peach cobbler", "chili", "potatoes",
                ]),
                NounChipSection(title: "Breakfast", words: [
                    "pancakes", "waffles", "crumpets", "french toast", "eggs",
                    "omelet", "ihop", "waffle house", "denny's",
                    "krispy kreme",
                ]),
                NounChipSection(title: "Fast food", words: [
                    "burger", "fries", "french fries", "pizza",
                    "pepperoni", "pizza hut", "domino's", "little caesars",
                    "mcdonald's", "burger king", "wendy's", "five guys",
                    "in-n-out", "cookout", "subway", "taco",
                    "nachos", "taco bell", "cheesesteak",
                    "gyro", "hot sauce", "buffet", "Circle K", "White Castle",
                ]),
                NounChipSection(title: "Sweets", words: [
                    "milkshake", "sundae", "sorbet", "honey buns", "pop tart",
                    "cereal", "captain crunch", "cotton candy", "reese's", "apple fritters",
                    "twix", "kit kat", "hershey", "cheesecake",
                    "now and later", "jolly rancher", "licorice",
                ]),
                NounChipSection(title: "Drinks", words: [
                    "kool-aid", "capri sun", "lemonade", "sweet tea",
                    "iced tea", "smoothie", "minute maid",
                ]),
                NounChipSection(title: "Snacks", words: [
                    "cheetos", "doritos", "funyuns", "Hubba Bubba", "Planters",
                ]),
                NounChipSection(title: "Campbell's", words: [
                    "Campbell's",
                ]),
                NounChipSection(title: "Spondivits", words: [
                    "Spondivits",
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
                    "grill", "my grill", "my grills",
                ]),
                NounChipSection(title: "The teeth", words: [
                    "fangs", "my fangs", "my teeth", "new teeth", "veneers",
                    "braces", "porcelain",
                ]),
            ]
        case .hair:
            return [
                NounChipSection(title: "Locs and braids", words: [
                    "dreads", "dreadlocks", "dreadlock",
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
                    "Hogan", "Macho Man", "Ric Flair", "Mr. T",
                ]),
                NounChipSection(title: "The new era", words: [
                    "John Cena", "Mysterio",
                ]),
                NounChipSection(title: "SmackDown", words: [
                    "SmackDown",
                ]),
            ]
        case .actors:
            return [
                NounChipSection(title: "Action", words: [
                    "Jet Li", "Van Damme", "Chuck Norris", "Stallone",
                    "Sylvester Stallone", "Arnold Schwarzenegger", "Wesley Snipes", "Steven Seagal",
                    "Ludacris", "Tyrese",
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
                    "Queen Latifah", "LL Cool J", "Ice-T", "Jamie Foxx",
                ]),
                NounChipSection(title: "Directors", words: [
                    "Quentin Tarantino", "Steven Spielberg", "Martin Scorsese",
                ]),
                NounChipSection(title: "Stars", words: [
                    "Mel Gibson", "Nicolas Cage", "George Clooney", "John Travolta",
                    "Will Smith", "Tom Hanks",
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
                    "whoadie", "wodie", "woadie", "woes",
                ]),
                NounChipSection(title: "Named friends", words: [
                    "Johnny Bling",
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
                    "Mortal Kombat", "Kano", "Liu Kang", "Sub-Zero", "Street Fighter", "Blanka", "Tekken",
                ]),
                NounChipSection(title: "Nintendo", words: [
                    "Zelda", "Pokemon", "Luigi", "Bowser", "Nintendo",
                    "Wii",
                ]),
                NounChipSection(title: "PlayStation", words: [
                    "PlayStation", "PS5", "PS4", "PS3", "analog",
                ]),
                NounChipSection(title: "Sports games", words: [
                    "Madden", "FIFA",
                ]),
                NounChipSection(title: "Arcade", words: [
                    "Pac-Man",
                ]),
                NounChipSection(title: "Baccarat", words: [
                    "baccarat",
                ]),
                NounChipSection(title: "Yu-Gi-Oh", words: [
                    "Yu-Gi-Oh", "upside down pyramid",
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
                    "Alton Sterling", "Twin Towers",
                ]),
                NounChipSection(title: "Festivals", words: [
                    "Coachella", "Caribana",
                ]),
                NounChipSection(title: "Awards", words: [
                    "Grammy", "ESPY",
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
                    "dirty 30", "dirty thirty", "fent", "lucy", "Ozempic",
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
                NounChipSection(title: "Showing off", words: [
                    "boasy", "wassy",
                ]),
                NounChipSection(title: "Waste", words: [
                    "wasteman",
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
                    "billboard", "Quagmire", "astronauts", "ranned off",
                    "drop my shell", "O'Neal", "Maybach curtains", "earplugs",
                    "we ball", "cards I'm dealt", "Tommy tucked", "darkest times",
                    "bag out", "hit our target", "from the rear", "bitin' my style",
                    "not a serial killer", "think 'bout death", "rollin' loud", "Glock-9",
                    "like a battery", "came sooner", "one coat", "napless",
                    "see Pearl", "talkin Pearl", "an addict", "don't pretend",
                    "mob ties", "for that brick", "assassinate him", "let it pan out",
                    "my diamonds", "chargin' my career", "your presence", "incomplete",
                    "takin' medicine", "brought my lawyer", "lean go", "my umbrella",
                    "Hot dig", "with the Migos", "like Offset", "without the sticks",
                    "runnin' like Hillary", "switch the beats", "envy me", "music app",
                    "like game", "raid us", "use a pencil", "back and forth to court",
                    "get abused", "cash comin'", "holiday eve", "head was weak",
                    "I'm tracin'", "see a ring", "no flowers",
                    "drake kickback", "wearing a trojan", "a Spartan", "tote 30",
                    "on his trail", "shot a buffalo", "we packers", "pourin' up dirty",
                    "vacuum seals", "Jr. Smith",
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
                    "playin' hockey",
                    "hippopotamus",
                    "Audemars",
                    "Nissan",
                    "Michael Phelps",
                    "Joe Biden",
                    "Philadelphia",
                    "DeMar DeRozan",
                    "ketchup",
                    "Rick Owens",
                    "heroin",
                    "gorilla",
                    "Dennis Rodman",
                    "Cadillac",
                    "Minute Maid",
                    "Harriet Tubman",
                    "Rugrats",
                    "wine",
                    "Bill Cosby",
                    "No Cap",
                    "Chris Tucker",
                    "Marcus Mariota",
                    "IHOP",
                    "Iraq",
                    "Maybach",
                    "Kai Cenat",
                    "tints",
                    "lion",
                    "Kraft Dinner",
                    "Drake",
                    "eye",
                    "Prada",
                    "acorn",
                    "Kurt Angle",
                    "plane",
                    "cell",
                    "Lex Luger",
                    "Takeoff",
                    "Coi Leray",
                    "Chevrolet",
                    "Altima",
                    "Dodge Durango",
                    "paralyzed",
                    "Hawaii",
                    "Xbox",
                    "respect the game",
                    "Ryan Tannehill",
                    "wrist taker",
                    "Toronto",
                    "Manhattan",
                    "moose sayin'",
                    "diarrhea",
                    "Cuba Gooding",
                    "Hemi",
                    "Russell Wilson",
                    "Nazi",
                    "nuclear bomb",
                    "mustard",
                    "Raptor"
                ]),
            ]
        case .phrases:
            return [
                NounChipSection(title: "P's & Q's", words: [
                    "P's & Q's",
                ]),
                NounChipSection(title: "Songs", words: [
                    "It G Ma", "Left Right", "Take You Down", "New Level", "Do What I Want", "Whole Lotta Red", "Mr. All-My-Friends-Are-Dead", "Milly Rock", "Walk It Out", "confetti",
                ]),
                NounChipSection(title: "Dances", words: [
                    "Diddy Bop",
                ]),
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
                    "for the clout", "vanish mode",
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
                    "Christmas Eve", "Sunday morning", "on the weekend", "blue moon",
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
                    "the draft", "calisthenics",
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
                NounChipSection(title: "Patois", words: [
                    "yiy",
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
                    "Hulu", "HBO", "Tubi", "BET", "Pornhub",
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
                    "OfferUp", "Global Tel Link",
                ]),
                NounChipSection(title: "Dating", words: [
                    "Tinder", "OnlyFans", "Grindr",
                ]),
                NounChipSection(title: "News", words: [
                    "TMZ", "WorldStar", "Shade Room", "Fader",
                ]),
                NounChipSection(title: "Voice", words: [
                    "Alexa",
                ]),
                NounChipSection(title: "Signal", words: [
                    "Wi-Fi",
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
