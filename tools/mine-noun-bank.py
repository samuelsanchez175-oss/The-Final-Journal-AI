#!/usr/bin/env python3
"""Full-vault noun bank mine.

Walks every bar in BarHitsCatalog.sqlite (all artists). The old FTS
LIMIT 25000 path returned Gunna/YSL first, so the bank looked like a
single-artist parse and only kept high-count phrases.

This pass:
  - scans the whole table (no artist filter, no FTS LIMIT)
  - keeps rare collocations (count 1–30) as first-class chips
  - round-robins display so Gunna does not crowd the list
  - writes Swift arrays for NounBankStore
"""
from __future__ import annotations

import json
import re
import sqlite3
import unicodedata
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "tools/bar-hits-catalog/BarHitsCatalog.sqlite"
SWIFT_OUT = ROOT / "XJournal AI/NounBankStore.swift"
REPORT = Path("/tmp/noun_bank_full_vault.txt")
JSON_OUT = Path("/tmp/noun_bank_full_vault.json")
HTML_OUT = ROOT / "docs/noun-bank-full-vault.html"
CSV_OUT = Path("/tmp/noun_bank_full_vault.csv")

WORD = re.compile(r"[a-z0-9']+")

SEEDS = {
    "liquors": [
        "henny", "hennessy", "remy", "dusse", "cristal", "moet", "belaire",
        "bel-air", "don julio", "clase azul", "casamigos", "patron", "ciroc",
        "grey goose", "belvedere", "cognac", "champagne", "tequila", "vodka",
        "whiskey", "bourbon", "dom p", "perignon", "louis xiii", "nuvo",
        "vsop", "actavis", "ace of spades", "1942", "absolut", "don julio",
        "1800", "remy martin", "d'usse", "luc belaire", "armand de brignac",
        "ace", "yak", "yak", "xo", "hennessy",
    ],
    "syrups": [
        "lean", "wock", "wockhardt", "prometh", "promethazine", "codeine",
        "dirty sprite", "double cup", "styrofoam", "sizzurp", "purple drank",
        "actavis", "hi-tech", "hitech", "robitussin", "qualitest", "deuce",
        "purple pint", "lean belly", "better wock",
    ],
    "drugs": [
        "perc", "percs", "percocet", "perky", "oxy", "xanax", "xanny", "xans",
        "molly", "ecstasy", "yayo", "fishscale", "kush", "zaza", "shrooms",
        "fetty", "fentanyl", "adderall", "addy", "runtz", "gelato", "backwood",
        "loud pack", "gas pack", "white girl", "percy", "roxies", "roxy",
        "m box", "xbox", "bean", "za", "cookies", "og kush", "exotic",
        "thizz", "ecstasy", "acid", "shroom",
    ],
    "jewelry": [
        "cuban", "vvs", "patek", "rolex", "rollie", "audemars", "richard mille",
        "cartier", "bust down", "bustdown", "iced out", "flooded", "grillz",
        "tennis chain", "jesus piece", "sky-dweller", "skydweller", "daytona",
        "hublot", "baguette", "bezel", "pinky ring", "pointers", "presidential",
        "plain jane", "offshore", "ap", "audemars piguet", "icebox", "cuban link",
        "tennis bracelet", "honeycomb", "vs1", "grill", "pendant", "cross",
        "jacob", "bust down",
    ],
    "brands": [
        "louis", "vuitton", "damier", "gucci", "balenciaga", "amiri",
        "chrome heart", "chrome hearts", "hermes", "birkin", "prada", "dior",
        "chanel", "fendi", "off-white", "yeezy", "supreme", "bape", "vlone",
        "moncler", "louboutin", "ferragamo", "balmain", "givenchy", "versace",
        "ysl", "saint laurent", "fear of god", "essentials", "palm angels",
        "canada goose", "marni", "bottega", "celine", "mcqueen", "margiela",
        "rick owens", "virgil", "tom ford", "true religion", "vetements",
        "off white", "lv", "hermès", "loubs", "red bottoms",
        "louis v", "louis vuitton", "louis v's",
        "heron preston", "goyard", "nike", "adidas", "jordan", "jumpman",
        "air force", "telfar", "sp5der", "denim tears", "ksubi", "evisu",
        "moschino", "kenzo", "loewe", "rhude", "corteiz", "comme des garcons",
        "cdg", "issey miyake", "raf simons", "helmut lang", "alyx",
        "ed hardy", "sean john", "pelle pelle", "fubu", "dickies", "carhartt",
        "stussy", "kith", "golf wang", "cactus jack", "human made",
        "casablanca", "kapital", "new balance", "converse", "vans", "reebok",
        "puma", "ray bans", "tiffany", "van cleef", "bvlgari", "michael kors",
        "fashion nova", "skims", "lululemon", "robin jeans", "trueys", "mcm",
        "north face", "thom browne", "yohji", "golden goose", "le fleur",
        "who decides war", "triple s", "bapesta", "arcteryx", "maison mihara",
        "purple jeans", "new rock",
    ],
    "clothing": [
        "mink", "trench", "durag", "ski mask", "balaclava", "joggers",
        "foamposite", "timberland", "timbs", "puffer", "parka", "bomber",
        "chinchilla", "sable", "wave cap", "fitted cap", "red bottoms",
        "duffel", "leotard", "man-bag", "foamposites", "dunks", "yeezy slides",
        "rockstar jeans", "wife beater", "trench coat", "mink coat",
        "cargo pants", "tracksuit", "bandana", "durag", "gats",
    ],
    "guns": [
        "glock", "draco", "choppa", "chopper", "extendo", "switchy", "beam",
        "fn", "drac", "mac-11", "mac 11", "p80", "ghost gun", "burner",
        "round drum", "glock 40", "glock 19", "glock 17", "ar-15", "deagle",
        "desert eagle", "toolie", "blick", "blicky", "rattler", "tec-9",
        "mac11", "draco", "choppas", "switch", "laser", "thirty round",
        "fifty round", "hundred round", "full clip", "extended clip",
        "pistol", "rifle", "shotty", "gauge", "dot", "red beam",
    ],
    "kill": [
        "opps", "opp", "catch a body", "spin the block", "hitstick",
        "let it eat", "let it rip", "wet him", "drop him", "the opps",
        "a drill", "hit a lick", "on the opps", "opp pack", "opp block",
        "catch a fade", "slide on",
    ],
    "woman": [
        "shorty", "shawty", "wifey", "thot", "baddie", "baby mama",
        "side chick", "main chick", "bad bitch", "pretty bitch", "thotiana",
        "redbone", "red bone", "yellow bone", "darkskin", "lightskin",
        "stallion", "groupie", "jumpoff", "side bitch", "baby girl",
        "these hoes", "bad one", "thickum", "thickums",
    ],
    "money": [
        "racks", "bands", "guap", "hunnids", "big face", "blue face",
        "cash out", "paycheck", "zelle", "cashapp", "cash app", "comma",
        "backend", "money bag", "moneybag", "big racks", "them racks",
        "them bands", "a bag", "the bag", "millie", "lululemon bag",
    ],
    "cars": [
        "hellcat", "charger", "camaro", "corvette", "ferrari", "rari",
        "tesla", "escalade", "tahoe", "trackhawk", "urus", "wraith",
        "phantom", "maybach", "bentley", "lambo", "lamborghini", "benz",
        "mercedes", "porsche", "g-wagon", "g wagon", "range rover",
        "bentayga", "cullinan", "mclaren", "challenger", "mustang",
        "raptor", "cadillac", "caddy", "drop top", "droptop", "old school",
        "woodgrain", "tinted", "two-door",
        "lambo truck", "scat pack", "demon", "bmw", "audi", "coupe",
        "foreign", "whip", "skyliner", "box chevy", "impala", "caprice",
        "cutlass", "donk", "daytona", "rolls royce", "royce", "ghost",
        "dawn", "suv", "quad", "atv", "yamaha",
        "kawasaki", "ducati", "bus", "sprinter", "party bus",
        "jeep", "hummer",
    ],
    "boats": [
        "yacht", "boat", "jet ski", "jetski", "speedboat", "cruise ship",
        "the yacht", "the boat", "cigarette boat", "pontoon",
    ],
    "aviation": [
        "lear", "lear jet", "private jet", "private plane", "jet", "the jet",
        "g5", "g6", "g4", "gulfstream", "helicopter", "the helicopter",
        "plane", "pj",
    ],
    "places": [
        "atlanta", "houston", "chicago", "miami", "detroit", "memphis",
        "oakland", "brooklyn", "trap house", "the trap", "the hood",
        "the stu", "the booth", "southside", "northside", "eastside",
        "westside", "downtown", "overseas", "penthouse", "mansion",
        "the block", "new york", "new orleans", "dallas", "houston",
        "zone 6", "zone 1", "cleveland", "baltimore", "philly",
        "philadelphia", "milwaukee", "london", "paris", "dubai",
        "los angeles", "hollywood", "beverly hills", "calabasas",
        "savannah", "decatur", "gwinnett", "austell", "the a",
        "chi-town", "chitown", "magic city", "o-block", "oblock",
        "stw", "so icey", "the heights", "the bottoms", "the village",
        "jamaica", "haiti", "africa", "london", "tokyo",
    ],
    "jewelers": [
        "johnny dang", "eliantte", "icebox", "avianne", "ben baller",
        "jacob the jeweler", "lorraine schwartz", "alex moss", "chopard",
        "david yurman", "harry winston", "jason of beverly hills",
    ],
    "producers": [
        "metro boomin", "wheezy", "tay keith", "pharrell", "atl jacob",
        "mustard", "hit-boy", "london on da track", "zaytoven", "808 mafia",
        "dr dre", "southside on the track", "mike will", "lex luger",
        "timbaland", "bnyx", "f1lthy", "dun deal", "scott storch",
        "just blaze", "alchemist", "cardo", "tm88", "drumma boy",
        "murda beatz", "pi'erre bourne", "boi-1da",
    ],
    "artists": [
        "drake", "lil wayne", "future", "young thug", "gunna", "lil baby",
        "kodak black", "nba youngboy", "lil durk", "king von", "playboi carti",
        "lil uzi vert", "juice wrld", "travis scott", "kendrick", "j cole",
        "unfoonk", "sahbabii", "peewee longway", "tadoe", "marlo",
        "young scooter", "bankroll fresh", "skooly", "nocap", "homixide gang",
        "young nudy", "lil keed", "omelly", "veeze", "moneybagg yo",
        "pooh shiesty", "glo rilla", "fivio foreign",
    ],
    "opps": [
        "opps", "opp pack", "opp block", "the opps", "o-block",
        "tekashi", "duck", "stl", "opp slide",
    ],
}

# Homographs: only count if a disambiguator is on the line.
CONTEXT_REQUIRED = {
    "foreign": {
        "cars": {"whip", "benz", "lambo", "rari", "coupe", "truck", "rover", "hellcat", "porsche", "urus"},
        "woman": {"bitch", "shawty", "shorty", "girl", "hoe", "hoes", "thot", "baddie", "wifey"},
        "places": {"overseas", "city", "paris", "london", "dubai", "miami"},
    },
    "ace": {"liquors": {"spades", "bottle", "pop", "champagne", "armand"}},
    "ghost": {"cars": {"rolls", "royce", "cullinan", "bentley", "whip"}},
    "daytona": {
        "jewelry": {"rollie", "rolex", "watch", "bust"},
        "cars": {"charger", "whip", "hellcat", "scat"},
    },
    "cross": {"jewelry": {"diamond", "chain", "pendant", "gold", "iced", "jesus"}},
    "ap": {"jewelry": {"patek", "rollie", "iced", "bust", "offshore", "audemars", "watch"}},
    "lv": {"brands": {"louis", "vuitton", "bag", "trunk", "damier"}},
    "switch": {"guns": {"glock", "extendo", "draco", "choppa", "clip", "beam", "stick"}},
}

STOP = {
    "the", "a", "an", "and", "or", "to", "of", "in", "on", "my", "i", "you", "it",
    "we", "they", "that", "this", "with", "from", "for", "yeah", "yah", "uh", "ooh",
    "ayy", "ay", "oh", "yo", "so", "if", "but", "as", "is", "was", "be", "me", "im",
    "i'm", "it's", "its", "at", "up", "out", "off", "just", "like", "got", "get",
    "don't", "dont", "can't", "aint", "ain't", "no", "not", "yes", "huh", "skrrt",
    "skrr", "woo", "whoa", "woah", "hey", "man", "dude", "cause", "'cause", "because",
    "when", "then", "than", "all", "some", "them", "these", "those", "your", "our",
    "his", "her", "she", "he", "him", "us", "em", "'em", "ya", "y'all", "yall",
    "nigga", "niggas", "niggaz", "bitch", "bitches",  # woman seeds still match as seeds
}

LEADING_BAD = {
    "and", "or", "to", "of", "in", "on", "with", "from", "for", "if", "but", "so",
    "as", "is", "was", "be", "at", "up", "out", "off", "when", "then", "just", "like",
    "got", "get", "don't", "dont", "bout", "'bout", "cause", "'cause", "em", "'em",
    "til", "'til", "nem", "'nem", "round", "'round", "fit", "'fit", "gy", "'gy",
    "sace", "'sace", "gram", "'gram", "yonc", "'yonc",
}
TRAILING_BAD = LEADING_BAD | {
    "the", "a", "an", "my", "i", "you", "it", "me", "im", "i'm", "that", "this", "your",
    "we", "they", "he", "she", "got", "get", "had", "do", "did", "yeah", "huh",
    "still", "too", "now", "oh", "uh", "gon", "gon'", "baby", "uhhuh",
}
VERBISH = {
    "got", "get", "gets", "getting", "take", "took", "make", "made", "had", "i'm",
    "im", "we", "they", "you", "i", "don", "dont", "don't", "swear", "know",
    "think", "talkin", "talkin'", "sippin", "sippin'", "drinkin", "drinkin'",
    "pour", "poured", "wanna", "gonna", "finna", "let", "ain't", "aint", "was",
    "were", "been", "doing", "did", "does", "can't", "cant", "won't", "wont",
    "i'll", "you'll", "we'll", "it's", "that's", "there's", "they're",
}
LEADING_DET = {"the", "a", "an", "my", "that", "them", "these", "this", "some", "his", "her", "ya"}

DENY_SUBSTRING = {
    "nigga", "nigger", "retard", "rape", "pedo",
}

# Homographs / slang that are not a person. Exact chip match after name_deny_key.
# KEY! the rapper is kept (exact "key!"); bare "key" is denied.
# Bare johnny/baller/metro/london/southside are denied; full forms stay.
NAME_DENY = {
    "baby", "juice", "genius", "flip", "turbo", "bet", "plug", "diamond",
    "tec", "bullet", "peep", "nba", "common", "trim", "casino", "dave",
    "autumn", "ian", "trav", "kyle", "blood money", "made man", "choo choo",
    "550", "xxl", "ab", "41", "the plug", "key",
    "johnny", "baller", "metro", "london", "southside",
}
PEOPLE_CATS = {"jewelers", "producers", "artists", "opps"}


def name_deny_key(s: str) -> str:
    """Normalize a chip/artist string for NAME_DENY. Preserves KEY!."""
    s = (s or "").strip().lower().replace("’", "'")
    if s.endswith("!") and s[:-1].strip() == "key":
        return "key!"
    s = re.sub(r"[^a-z0-9\s]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def is_denied_name(s: str) -> bool:
    key = name_deny_key(s)
    return bool(key) and key in NAME_DENY


CLAUSE = {
    "would", "might", "because", "again", "please", "since", "lets", "let's",
    "tryna", "coming", "came", "come", "went", "gone", "give", "gave", "want",
    "wanted", "tell", "told", "talk", "talkin", "talkin'", "talking", "doin",
    "doin'", "doing", "goin", "goin'", "going", "lookin", "lookin'", "looking",
    "playin", "playin'", "playing", "what", "where", "when", "why", "how",
    "never", "always", "every", "only", "still", "just", "fuck", "fuckin",
    "fuckin'", "fucking", "i'ma", "ima", "imma", "we'll", "i'll", "you'll",
    "ain't", "aint", "while", "before", "after", "until", "hold", "pull",
    "look", "real", "even", "damn", "holla", "ask", "sent", "split", "worth",
    "today", "through", "behind", "leave", "left", "tried", "turned", "weak",
    "knock", "free", "move", "stand", "shout", "bring", "brought", "bitch",
    "bitches", "shit", "tho", "though", "yeah", "huh", "okay", "ok",
    "would", "could", "should", "can't", "cant", "won't", "wont", "didn't",
    "didnt", "don't", "dont",
}


def tokens(line: str) -> list[str]:
    return WORD.findall(line.lower().replace("'", "'"))


def seed_index(seeds: list[str]):
    uni: dict[str, None] = {}
    multi: list[tuple[tuple[str, ...], str]] = []
    for s in seeds:
        parts = tuple(WORD.findall(s.lower()))
        if not parts:
            continue
        if len(parts) == 1:
            uni[parts[0]] = None
        else:
            multi.append((parts, s))
    return uni, multi


def line_has_multi(toks: list[str], multi) -> set[str]:
    hit = set()
    n = len(toks)
    for parts, raw in multi:
        k = len(parts)
        for i in range(0, n - k + 1):
            if tuple(toks[i : i + k]) == parts:
                hit.add(raw)
    return hit


def quality_phrase(gram: str, neighbor_only: bool, cat: str | None = None) -> bool:
    if any(bad in gram for bad in DENY_SUBSTRING):
        return False
    if cat in PEOPLE_CATS and is_denied_name(gram):
        return False
    toks = gram.split()
    if not (1 <= len(toks) <= 4):
        return False
    if len(gram) > 36:
        return False
    if any(t.startswith("'") for t in toks):
        return False
    if toks[0] in LEADING_BAD:
        return False
    if toks[-1] in TRAILING_BAD:
        return False
    if len(set(toks)) == 1 and len(toks) >= 2:
        return False
    if len(toks) >= 3 and toks[0] == toks[-1]:
        return False
    if any(len(t) == 1 and t not in {"a", "v"} for t in toks):
        return False
    if any(t in CLAUSE or t in VERBISH for t in toks):
        return False
    content = [t for t in toks if t not in STOP and t not in LEADING_DET]
    if not content:
        return False
    if neighbor_only:
        if len(toks) < 2:
            return False
        if any(t in STOP or t in LEADING_DET for t in toks):
            return False
        if any(len(t) < 3 for t in toks):
            return False
    if len(content) < max(1, (len(toks) + 1) // 2):
        return False
    return True


def windows_around(toks: list[str], i: int, radius: int = 3):
    lo = max(0, i - radius)
    hi = min(len(toks), i + radius + 1)
    return lo, hi, toks[lo:hi]


def extract(toks: list[str], seed_idxs: list[int], cat: str | None = None) -> set[str]:
    """N-grams that contain a seed (1–4 tokens). No neighbor-only grams —
    those explode into millions of unique keys and stall the pass."""
    out: set[str] = set()
    n = len(toks)
    for i in seed_idxs:
        for start in range(max(0, i - 3), i + 1):
            max_end = min(n, start + 3)
            for end in range(i + 1, max_end + 1):
                gram = " ".join(toks[start:end])
                if quality_phrase(gram, neighbor_only=False, cat=cat):
                    out.add(gram)
    return out


def build_lookups():
    uni_to_cat: dict[str, set[str]] = defaultdict(set)
    multi_at: dict[str, list[tuple[tuple[str, ...], str]]] = defaultdict(list)
    for cat, seeds in SEEDS.items():
        if cat in PEOPLE_CATS:
            seeds = [s for s in seeds if not is_denied_name(s)]
        uni, multi = seed_index(seeds)
        for u in uni:
            uni_to_cat[u].add(cat)
        for parts, _ in multi:
            multi_at[parts[0]].append((parts, cat))
    return uni_to_cat, multi_at


def context_ok(toks: list[str], token: str, cat: str) -> bool:
    req = CONTEXT_REQUIRED.get(token)
    if not req:
        return True
    if cat not in req:
        return False
    need = req[cat]
    tset = set(toks)
    return bool(tset & need)


def display_case(phrase: str, cat: str) -> str:
    proper_cats = {"brands", "cars", "places", "jewelry", "jewelers", "liquors", "producers", "artists", "opps"}
    toks = phrase.split()
    out = []
    for i, t in enumerate(toks):
        if t in LEADING_DET or t in {"of", "on", "and"}:
            out.append(t)
            continue
        if cat in proper_cats or t in {
            "glock", "draco", "choppa", "henny", "patek", "rollie", "rolex",
            "gucci", "louis", "amiri", "dior", "chanel", "prada",
        }:
            if t in {"lv", "ap", "rm", "fn", "ak", "ar", "vsop", "og", "bm", "vvs"}:
                out.append(t.upper())
            elif t in {"the", "a", "my", "that", "them"}:
                out.append(t)
            else:
                out.append(t[:1].upper() + t[1:])
        else:
            out.append(t)
    s = " ".join(out)
    # known preferred spellings
    repl = {
        "Henny": "Henny",
        "Rari": "'Rari",
        "G Wagon": "G-Wagon",
        "G-wagon": "G-Wagon",
        "Chrome Heart": "Chrome Hearts",
        "Chrome Hearts": "Chrome Hearts",
        "Damier": "Damier",
        "Patek": "Patek",
        "Rollie": "Rollie",
        "Hellcat": "Hellcat",
        "Trackhawk": "Trackhawk",
        "Bentayga": "Bentayga",
        "Urus": "Urus",
        "Wraith": "Wraith",
        "Maybach": "Maybach",
        "Lambo": "Lambo",
        "Baddie": "baddie",
        "Lean": "lean",
        "Opps": "opps",
        "The Opps": "the opps",
    }
    return repl.get(s, s)


def seed_tokens_for(cat: str) -> set[str]:
    out = set()
    for s in SEEDS[cat]:
        out.update(WORD.findall(s.lower()))
    return out - STOP


def noun_score(phrase: str, n: int, na: int, seeds: set[str]) -> int:
    toks = phrase.split()
    if not toks:
        return -999
    if any(t.startswith("'") for t in toks):
        return -999
    if len(toks) > 3:
        return -8
    score = {1: 2, 2: 10, 3: 6}.get(len(toks), 0)
    seed_at = [i for i, t in enumerate(toks) if t in seeds]
    if not seed_at:
        score -= 12
    else:
        score += 4
        if seed_at[0] == 0 and len(toks) >= 2:
            score += 7  # Glock 40, Damier buckle
        if toks[0] in LEADING_DET and len(seed_at) and seed_at[0] == 1:
            score += 5  # the stick, them racks
        if seed_at[-1] == len(toks) - 1 and len(toks) >= 2:
            score += 6  # flooded Patek, woodgrain Damier
    if 3 <= n <= 18:
        score += 6
    elif n == 2:
        score += 3
    elif n == 1:
        score += 2
    elif 19 <= n <= 80:
        score += 2
    if na >= 3:
        score += 4
    elif na == 2:
        score += 2
    if any(t in VERBISH for t in toks):
        score -= 14
    if toks[0].isdigit() and not (len(toks) >= 2 and toks[1] in seeds):
        if toks[0] not in seeds:
            score -= 10
    if toks[-1] in {"yeah", "uh", "woah", "okay", "ok", "huh", "man", "though", "still"}:
        score -= 12
    modifiers = {
        "flooded", "iced", "bust", "bustdown", "plain", "drop", "droptop", "old",
        "tinted", "foreign", "big", "white", "black", "red", "yellow", "dirty",
        "loud", "purple", "double", "styrofoam", "hundred", "extended", "full",
        "baby", "chrome", "woodgrain", "box", "scat", "private", "rose", "gold",
        "new", "brand", "that", "them", "these", "my", "some", "this", "plain",
        "sky", "offshore", "presidential", "cuban", "vvs",
    }
    others = [t for t in toks if t not in seeds and t not in LEADING_DET]
    n_seed_toks = sum(1 for t in toks if t in seeds)
    if len(toks) >= 2:
        if n_seed_toks >= 2 and not others:
            if not any(t in modifiers for t in toks):
                score -= 18  # Chanel Gucci, Houston Atlanta
            else:
                score += 4  # tinted Maybach, flooded Patek
        elif others:
            score += 10
            if any(len(t) >= 4 or t.isdigit() or t.endswith("k") for t in others):
                score += 8  # Damier buckle, 100k bezel, codeine daiquiri
    return score


# Same drink, different word → keep both (Henny and Hennessy).
# Same word with the/that/a/my or drink/bottle fluff → drop.
# Spelling twins of one word → one form (Cîroc not Ciroc).
SPELLING = {
    "ciroc": "Cîroc",
    "cîroc": "Cîroc",
    "peach ciroc": "Peach Cîroc",
    "peach cîroc": "Peach Cîroc",
    "moet": "Moët",
    "moët": "Moët",
    "dusse": "D'USSÉ",
    "d'usse": "D'USSÉ",
    "d'ussé": "D'USSÉ",
    "bel-air": "Belaire",
    "bel air": "Belaire",
    "belaire": "Belaire",
    "luc belaire": "Belaire",
    "perignon": "Dom Pérignon",
    "off white": "Off-White",
    "off-white": "Off-White",
    "chrome heart": "Chrome Hearts",
    "chrome hearts": "Chrome Hearts",
    "ray bans": "Ray-Bans",
    "ray-ban": "Ray-Bans",
    "rayban": "Ray-Bans",
    "louis v": "Louis V",
    "louis v's": "Louis V's",
    "louis vuitton": "Louis Vuitton",
    "lv": "LV",
    "loubs": "Loubs",
    "truey": "Truey",
    "trueys": "Trueys",
    "ysl": "YSL",
}
DET_PREFIX = {
    "the", "that", "a", "an", "my", "some", "this", "them", "these", "his", "her",
}
FLUFF_PREFIX = {
    "drink", "drinking", "sip", "sipping", "sippin'", "pourin'", "pouring",
    "pop", "poppin'", "popping", "poppin", "little", "lil'", "more", "much",
    "have", "into", "called", "bottles", "bottle", "hoes", "pill", "habits",
    "sprayin'", "spraying", "distilled", "tila", "papi", "henn'", "your",
    "me", "no", "keep", "see", "do", "put", "got", "gotta", "gon'", "everybody",
    "flip", "bought", "brand", "new", "big", "it", "mr", "now", "love", "need",
    "trust", "hit", "go", "around", "down", "beat", "spin",
}
FLUFF_SUFFIX = {
    "bottle", "bottles", "shots", "glass", "glasses", "toast", "shower",
    "showers", "rain", "diet", "cork", "pours", "over", "spill", "spillin'",
    "papi", "girl", "down", "straight", "sipping", "bubble", "flutes",
    "fountains", "piece", "act'", "skeet", "skrrt", "gunna", "poppin'",
    "bel", "towards", "than", "whenever", "need", "keep", "have", "had",
    "said", "gotta", "feel", "feelin'", "feeling", "back", "right", "more",
    "inside", "call", "turn", "watch", "go", "hit", "there", "really",
    "instead", "mixed", "hell", "named", "sounding", "stay", "style", "view",
    "zone", "blow", "kick", "shoot", "sittin'", "beep", "everywhere",
    "holdin'", "strike", "wit'", "walk", "sing", "comin'", "home", "hopped",
    "faster", "roll", "game", "ride", "time", "no", "called", "bought",
    "maybe", "spent", "stop", "throw", "long", "home", "will", "already",
    "better", "stupid", "somebody", "start", "stuck", "help", "tonight",
    "alright", "quick", "heavy", "drop", "grow", "last", "under",
}
JUNK = VERBISH | CLAUSE | FLUFF_PREFIX | FLUFF_SUFFIX | {
    "towards", "than", "whenever", "actin'", "hidin'", "dyin'", "sayin'",
    "gettin'", "bustin'", "burnin'", "ridin'", "screamin'", "tellin'",
    "runnin'", "rockin'", "rollin'", "smokin'", "sittin'", "pullin'",
    "throwin'", "callin'", "choosin'", "starin'", "thinkin'", "strippin'",
    "trippin'", "hangin'", "walkin'", "fallin'", "bussin'", "comin'",
    "chasin'", "shootin'", "thuggin'", "trappin'", "chillin'", "eatin'",
    "eating", "dreamin'", "dreaming", "kickin'", "moving", "pouring",
    "sell", "switch", "fill", "filled", "help", "kool", "fiend", "addict",
    "habit", "head", "stain", "wash", "taste", "till", "time", "crazy",
    "plug", "soda", "pills", "drink", "hard", "more", "keep", "sipper",
    "smoke", "smoking", "inside", "by", "no", "me", "everybody", "flip",
    "nothin'", "start", "trees", "bows", "crushed", "color", "everybody",
    "haaan", "holy", "hong", "kick", "love", "miley", "mixed", "she'll",
    "freak", "kill", "party", "tits", "dose", "family", "school", "control",
    "reflux", "boys", "rolled", "pies", "clothes", "dancer", "dancers",
    "wasted", "blunt", "good", "world", "geekin'", "geeked", "pets",
    "reefer", "projects", "smash", "thot", "half", "cookin'", "planet",
    "reynolds", "cost", "call", "feelin'", "thot", "vision", "wires",
    "bling", "right", "suck", "watches", "hideout", "both", "around",
    "full", "aquia", "line", "quarter", "hangin'", "hittin'", "checks",
    "embedded", "shopping", "studded", "wearing", "bustin'", "butters",
    "makin'", "matching", "polli", "thousand", "whoo", "water", "carti",
    "cigars", "suite", "your", "brand", "new", "atl", "steppin'", "five",
    "everything", "pharrell", "toes", "drip", "feet", "couch", "fits",
    "prints", "button", "mama", "stars", "clones", "collar", "crop",
    "fiend", "flames", "flips", "home", "maybe", "snake", "stans",
    "accessory", "pillows", "tees", "spelt", "spilling", "mask", "whole",
    "gotta", "hang", "minks", "pussy", "slatty", "babies", "under",
    "floor", "draggin'", "fast", "limp", "shoulder", "sparkin'", "stuff",
    "we're", "snow", "loser", "bleed", "bleeding", "scenes", "shorty",
    "flawless", "woo", "hop", "21", "lebrons", "boyz", "cardinals",
    "gang", "santana", "glitter", "dweller", "baow", "blaow", "brrd",
    "brrah", "dewt", "dissect", "music", "scream", "speaking", "started",
    "taller", "uppercut", "fresh", "mini", "stutter", "grrah", "cock",
    "taggin'", "popper", "pete", "whippin'", "com", "disappear", "survive",
    "hope", "rest", "scared", "steady", "lackin'", "about", "done", "hate",
    "send", "party", "list", "blocks", "favorite", "first", "brother",
    "whole", "same", "last", "rip", "it", "see", "do", "flyin'", "high",
    "something", "wouldn't", "cryin'", "ready", "mangos", "slim", "close",
    "cold", "couldn't", "dance", "fall", "graduated", "kept", "light",
    "mean", "mine", "must've", "sweet", "text", "wipe", "different",
    "seen", "shake", "gimme", "sleep", "apart", "away", "thirsty",
    "acting", "bendin'", "break", "lo", "dirt", "grandma", "naps",
    "skinny", "stack", "somebody", "rollies", "zero", "rubber", "fifties",
    "swag", "hol'", "involved", "stashed", "tall", "count", "hella",
    "lotta", "many", "spend", "blew", "too", "adopted", "hawk", "brrt",
    "bumpin'", "quiet", "rolling", "serving", "sold", "strapped",
    "warrior", "working", "y'all", "young", "studio", "turnin'",
    "polices", "mondays", "cavalier", "actress", "knew", "pass", "proud",
    "rats", "showed", "used", "boomin", "crack", "what's", "harrow",
    "space", "raised", "dolphins", "hunnid", "show", "coppin'", "near",
    "nice", "reppin'", "where'd", "bando", "code", "jumping", "moves",
    "play", "selena", "all", "hot", "is", "da", "lil'", "peanut", "manti",
    "frog", "jeff", "lik", "redder", "transform", "wrapped", "parked",
    "seashell", "slatt", "hmph", "arms", "mikes", "matte", "bald",
    "dawg", "filled", "into", "sick", "spurs", "spoke", "motor",
    "ghost", "danny", "pistol", "water", "tour", "windows", "body",
    "cost", "with", "two", "four", "door", "hard", "head", "sport",
    "mode", "flight", "cross", "kawasaki", "maserati", "creepin'",
    "revolv", "flow", "gilbert", "loser", "christian", "tucked",
    "fully", "they'll", "wet", "broke", "plain", "rock", "comin'",
    "boom", "smokin", "slatt", "accessory", "button", "king", "mike",
    "steppin", "triple", "both", "fatburger", "bling", "upside",
    "40'll", "40's", "bel",
}
WEAK_HEADS = {
    "plain", "red", "white", "full", "new", "ski", "jesus", "richard",
    "down", "heart", "laurent", "bad", "pretty", "gold", "it", "me",
    "your", "flood", "yves", "saint", "put", "st", "some", "double",
    "foreign", "bus", "demon", "dawn", "tinted", "royce", "body",
    "windows", "tour", "ghost", "danny", "door", "with", "hard",
    "sport", "mode", "flight", "cost", "yves", "saint",
}


def norm_key(s: str) -> str:
    s = unicodedata.normalize("NFKD", s.lower())
    s = "".join(c for c in s if not unicodedata.combining(c))
    return re.sub(r"[^a-z0-9]+", "", s)


def strip_det(s: str) -> str:
    toks = s.split()
    while toks and toks[0].lower() in DET_PREFIX:
        toks = toks[1:]
    return " ".join(toks)


def spelling_form(s: str) -> str:
    return SPELLING.get(s.lower(), s)


def is_fluff_variant(s: str, heads: set[str]) -> bool:
    """True if this is 'the Henny' / 'Drink Henny' / 'Henny Bottle' / 'lean towards'."""
    toks = [t.lower() for t in s.split()]
    if not toks:
        return True
    if len(toks) == 1:
        return False
    model_ok = {"glock", "perc", "bands", "racks", "gauge", "round", "bezel", "patek"}
    if toks[0].isdigit() and not any(norm_key(t) in model_ok or norm_key(t) in heads for t in toks[1:]):
        return True
    if toks[0] in {"henn'", "henn"}:
        return True
    if toks[0] in DET_PREFIX and norm_key(" ".join(toks[1:])) in heads:
        return True
    if toks[0] in FLUFF_PREFIX and norm_key(" ".join(toks[1:])) in heads:
        return True
    if toks[-1] in FLUFF_SUFFIX and norm_key(" ".join(toks[:-1])) in heads:
        return True
    # head + junk verb/clause
    keys = [norm_key(t) for t in toks]
    has_head = any(k in heads for k in keys)
    has_junk = any(t in JUNK for t in toks)
    if has_head and has_junk:
        return True
    # both tokens already unique heads ("kush weed", "Glock choppa")
    if len(toks) == 2 and keys[0] in heads and keys[1] in heads:
        return True
    return False


def unique_chips(
    words: list[str], protect: list[str] | None = None, cat: str | None = None
) -> list[str]:
    """Keep distinct words. Drop determiner/fluff copies and spelling twins."""
    protect = protect or []
    out: list[str] = []
    seen: set[str] = set()
    heads: set[str] = set()

    def add(form: str, force: bool) -> None:
        form = spelling_form(strip_det(form).strip())
        if not form:
            return
        if cat in PEOPLE_CATS and is_denied_name(form):
            return
        key = norm_key(form)
        if not key or key in seen:
            return
        if key in {"stlouis", "fordbutton", "majidjordan", "whiteshoesrock", "guccimane"}:
            return
        toks = form.split()
        if not force:
            if len(toks) == 1 and toks[0].lower() in WEAK_HEADS:
                return
            if is_fluff_variant(form, heads):
                return
        seen.add(key)
        heads.add(key)
        last = norm_key(toks[-1])
        if last:
            heads.add(last)
        first = norm_key(toks[0])
        if first:
            heads.add(first)
        out.append(form)

    for p in protect:
        add(p, force=True)
    one = [w for w in words if len(strip_det(w).split()) == 1]
    multi = [w for w in words if len(strip_det(w).split()) >= 2]
    for w in one:
        add(w, force=False)
    for w in multi:
        add(w, force=False)
    return out


KEEPERS = {
    "liquors": [
        "Henny", "Hennessy", "Rémy", "Rémy Martin",
        "Ace of Spades", "Dom P", "Dom Pérignon", "Cristal", "Moët",
        "D'USSÉ", "Don Julio", "Clase Azul", "1942", "Casamigos", "Cîroc",
        "Grey Goose", "Belvedere", "Louis XIII", "Nuvo", "Belaire",
        "Yak", "Patron", "Tequila", "Vodka", "Whiskey", "Cognac",
        "Bourbon", "Champagne", "Actavis", "1800", "Absolut", "VSOP", "Xo",
        "Peach Cîroc",
    ],
    "syrups": [
        "lean", "purple drank",
        "double cup", "styrofoam cup", "dirty sprite", "Wockhardt", "Better Wock",
        "Actavis", "Hi-Tech", "codeine daiquiri",
    ],
    "drugs": [
        "perc", "Percocet", "perc 30", "xanny bar", "molly water", "fishscale",
        "gas pack", "loud pack", "OG kush", "zaza", "runtz", "gelato",
        "backwood", "white girl", "M box",
    ],
    "jewelry": [
        "Cuban link", "bust down Cuban", "tennis chain", "tennis bracelet",
        "flooded Patek", "flooded belt buckle", "iced out AP", "plain Jane Rollie",
        "rose Sky-Dweller", "Cartier frames", "VVS pointers", "Jesus piece",
        "100k bezel", "bustdown Cuban", "icebox",
    ],
    "brands": [
        "Damier buckle", "Damier print", "woodgrain Damier", "Chrome Heart frames",
        "Amiri jeans", "Saint Laurent", "Baby Birkin", "Louis pouch",
        "Louis leather vest", "red bottoms", "BB belt", "gats",
        "Chrome Heart skinnies", "Off-White fur",
        "Heron Preston", "Goyard", "Goyard backpack", "Goyard duffle",
        "Off-White", "Fear of God", "Palm Angels", "Rick Owens", "Tom Ford",
        "True Religion", "Canada Goose", "Chrome Hearts", "Nike", "Adidas",
        "Jordan", "Jumpman", "Air Force", "Telfar", "Sp5der", "Denim Tears",
        "Ksubi", "Evisu", "Moschino", "Kenzo", "Loewe", "Rhude", "Corteiz",
        "Comme des Garçons", "CDG", "Issey Miyake", "Raf Simons", "Helmut Lang",
        "Alyx", "Ed Hardy", "Sean John", "Pelle Pelle", "FUBU", "Dickies",
        "Carhartt", "Stussy", "Kith", "Golf Wang", "Cactus Jack", "Human Made",
        "Casablanca", "Kapital", "New Balance", "Converse", "Vans", "Reebok",
        "Puma", "Ray-Bans", "Tiffany", "Van Cleef", "Bvlgari", "Michael Kors",
        "Fashion Nova", "Skims", "Lululemon", "Robin jeans", "Trueys", "MCM",
        "North Face", "Ferragamo", "Essentials", "Yohji", "Thom Browne",
        "Golden Goose", "Le Fleur", "Triple S", "Bapesta", "Who Decides War",
        "Palm Angels sweater", "Rick Owens denims", "Fear of God pants",
        "Telfar bag", "Off-White coat",
        # how the brands actually get said
        "Louis V", "Louis Vuitton", "Vuitton", "LV", "Louis V's",
        "Louis bag", "Louis V bag", "Louis belt", "Louis luggage",
        "Louis shoes", "Louis loafers", "Louis scarf", "Louis coat",
        "man bag", "Loubs", "YSL", "Birkin bag", "Goyard bag",
        "Gucci bag", "Gucci belt", "Gucci socks", "Gucci slides",
        "Gucci sweater", "Chanel bag", "Prada bag", "Fendi bag",
        "Amiri denim", "Amiri pants", "Versace shades", "Balenciaga boots",
        "Chrome Heart glasses", "Chrome Hearts jeans", "YSL jeans",
        "A Bathing Ape", "Truey", "Force 1", "Air Force 1",
    ],
    "clothing": [
        "ski mask", "black ski mask", "mink coat", "chinchilla", "wave cap",
        "fitted cap", "duffel bag", "trench coat", "Louis V trench",
        "rockstar jeans", "Foamposites", "red bottoms",
    ],
    "guns": [
        "blicky", "Glock 40", "Glock 20", "Glock 23", "thirty shot Glock",
        "choppa", "stick", "toolie", "burner",
        "Mac-11", "P80", "fn", "switchy", "extendo", "hundred round drum",
        "red beam", "green beam", "dot", "rifle", "shotty",
    ],
    "kill": [
        "opps", "catch a body", "spin the block", "opp pack", "hitstick",
        "let it eat", "slide on", "drill",
    ],
    "woman": [
        "baddie", "bad bitch", "baby mama", "side chick", "main chick",
        "shawty", "wifey", "redbone", "yellow bone", "these hoes", "stallion",
    ],
    "money": [
        "racks", "big racks", "bands", "guap", "blue face",
        "money bag", "cash out", "hunnids", "big face",
    ],
    "cars": [
        "'Rari", "Lambo", "Urus", "Bugatti", "Benz", "big body Benz", "G-Wagon",
        "Range Rover", "white Range Rover", "Wraith", "Cullinan", "Phantom",
        "Bentley", "Bentayga", "Bentley Mulsanne", "Hellcat", "Demon", "Trackhawk",
        "Charger", "scat pack", "Daytona Charger", "Maybach", "Black Maybach",
        "Porsche", "Tesla", "Audi", "Mclaren", "Caddy", "box Chevy", "donk",
        "Caprice", "Cutlass", "old school", "Corvette", "drop top", "Whip", "Sprinter",
        "Jeep", "Hummer",
    ],
    "boats": [
        "yacht", "boat", "jet ski", "speedboat", "cruise ship",
    ],
    "aviation": [
        "jet", "Lear jet", "G5", "G6", "private plane", "helicopter",
    ],
    "jewelers": [
        "Johnny Dang", "Eliantte", "Icebox", "Avianne", "Ben Baller",
        "Jacob the Jeweler", "Lorraine Schwartz", "Alex Moss", "Chopard",
        "David Yurman", "Harry Winston", "Jason of Beverly Hills",
    ],
    "producers": [
        "Metro Boomin", "Wheezy", "Tay Keith", "Pharrell", "ATL Jacob",
        "Mustard", "Hit-Boy", "London on da Track", "Zaytoven", "808 Mafia",
        "Dr Dre", "Southside on the Track", "Mike Will", "Lex Luger",
        "Timbaland", "BNYX", "F1lthy", "Pi'erre Bourne", "Boi-1da",
    ],
    "artists": [
        "Drake", "Wayne", "Future", "Thugger", "Gunna", "Lil Baby", "Kodak",
        "YoungBoy", "Durk", "King Von", "Carti", "Uzi", "Juice WRLD",
        "Unfoonk", "SahBabii", "Peewee Longway", "Tadoe", "Marlo",
        "Young Scooter", "NoCap", "Homixide Gang", "Young Nudy",
    ],
    "opps": [
        "Opps", "Opp pack", "Opp block", "The opps", "O-Block",
        "Tekashi", "Duck", "STL", "Opp slide",
    ],
    "places": [
        "trap", "stu", "booth", "block",
        "Atlanta", "Miami", "Memphis", "Chi-town", "Houston", "O-Block",
        "Magic City", "hood", "southside", "overseas", "Calabasas",
        "Zone 6", "Decatur", "Gwinnett", "Hollywood Hills",
        "Beverly Hills", "New Orleans", "bottoms", "Philly",
        "North Philly", "East Atlanta", "South Memphis", "Los Angeles",
    ],
}


def pick(cat: str, stats: dict) -> list[str]:
    seeds = seed_tokens_for(cat)
    uni_heads = {WORD.findall(s.lower())[0] for s in SEEDS[cat] if len(WORD.findall(s.lower())) == 1}
    scored = []
    for phrase, st in stats.items():
        n, na = st["n"], len(st["artists"])
        sc = noun_score(phrase, n, na, seeds)
        scored.append((sc, n, na, phrase))

    obscure = [(sc, n, na, p) for sc, n, na, p in scored if n <= 30 and " " in p and sc >= 14]
    mid = [(sc, n, na, p) for sc, n, na, p in scored if 31 <= n <= 200 and " " in p and sc >= 10]
    heads = [
        (sc, n, na, p)
        for sc, n, na, p in scored
        if " " not in p and p in uni_heads and n >= 3
    ]
    obscure.sort(key=lambda it: (-it[0], it[1], it[3]))
    mid.sort(key=lambda it: (-it[0], -it[2], it[3]))
    heads.sort(key=lambda it: (-it[1], it[3]))

    picked: list[str] = []
    seen: set[str] = set()

    def add_phrase(raw: str) -> None:
        key = re.sub(r"[^a-z0-9]+", "", raw.lower())
        if not key or key in seen:
            return
        low = raw.lower()
        for prev in picked[-25:]:
            pl = prev.lower()
            if pl in low and len(low) - len(pl) > 8:
                return
        seen.add(key)
        picked.append(raw if raw[:1].isupper() or raw[:1] in "'\"" else display_case(raw, cat))

    for k in KEEPERS.get(cat, []):
        add_phrase(k)
    for sc, n, na, p in obscure:
        if len(picked) >= 110:
            break
        add_phrase(display_case(p, cat))
    for sc, n, na, p in mid:
        if len(picked) >= 150:
            break
        add_phrase(display_case(p, cat))
    for sc, n, na, p in heads:
        if len(picked) >= 175:
            break
        add_phrase(display_case(p, cat))
    return unique_chips(picked, protect=KEEPERS.get(cat, []), cat=cat)[:180]


SWIFT_HEADER = '''import Foundation

/// Offline noun pockets. Heads plus short descriptors mined from the full
/// 1.7M-bar catalog (all 784 artists), not a Gunna/YSL FTS slice.
/// Rare collocations (count 1–30) are kept — obscure is the point.
/// No full bars. Regenerated by tools/mine-noun-bank.py.
enum NounBankCategory: String, CaseIterable, Identifiable {
    case liquors = "Liquors"
    case syrups = "Syrups"
    case drugs = "Drugs"
    case jewelry = "Jewelry"
    case jewelers = "Jewelers"
    case brands = "Brands"
    case clothing = "Clothing"
    case guns = "Guns"
    case kill = "Kill"
    case opps = "Opps"
    case woman = "Woman"
    case money = "Money"
    case cars = "Cars"
    case places = "Places"
    case producers = "Producers"
    case artists = "Artists"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .liquors: return "wineglass"
        case .syrups: return "drop.fill"
        case .drugs: return "pills"
        case .jewelry: return "sparkles"
        case .jewelers: return "diamond.fill"
        case .brands: return "tag"
        case .clothing: return "tshirt"
        case .guns: return "scope"
        case .kill: return "bolt.fill"
        case .opps: return "shield.slash"
        case .woman: return "heart"
        case .money: return "banknote"
        case .cars: return "car"
        case .places: return "mappin"
        case .producers: return "waveform"
        case .artists: return "person.fill"
        }
    }
}

enum NounBankStore {
    static func words(for category: NounBankCategory) -> [String] {
        switch category {
'''

SWIFT_FOOTER = '''        }
    }

    private static func unique(_ words: [String]) -> [String] {
        var seen = Set<String>()
        return words.filter { seen.insert($0.lowercased()).inserted }
    }
}
'''


def swift_array(name: str, words: list[str]) -> str:
    lines = [f"        case .{name}:", "            return unique(["]
    row = []
    for w in words:
        esc = w.replace("\\", "\\\\").replace('"', '\\"')
        row.append(f'"{esc}"')
        if len(", ".join(row)) > 88:
            lines.append("                " + ", ".join(row) + ",")
            row = []
    if row:
        lines.append("                " + ", ".join(row))
    lines.append("            ])")
    return "\n".join(lines)


def write_html(jsonable: dict, n_lines: int, n_used: int, n_artists: int) -> None:
    total = sum(len(v["picked"]) for v in jsonable.values())
    tabs = []
    panels = []
    overview_rows = []
    for i, (cat, data) in enumerate(jsonable.items()):
        n = len(data["picked"])
        rare_n = sum(1 for r in data["rows"] if r["band"] == "rare")
        artists = ", ".join(f"{a} ({c})" for a, c in data["top_artists"][:5])
        overview_rows.append(
            f"<tr><td>{cat.title()}</td><td>{n}</td><td>{rare_n}</td>"
            f"<td>{data['n_rare']}</td><td>{artists}</td></tr>"
        )
        active = " is-active" if i == 0 else ""
        tabs.append(
            f'<button class="tab{active}" data-tab="{cat}">{cat.title()} ({n})</button>'
        )
        body = []
        for j, r in enumerate(data["rows"], 1):
            hits = r["n"] if r["n"] is not None else "—"
            arts = r["artists"] if r["artists"] is not None else "—"
            body.append(
                f"<tr><td>{j}</td><td>{_html(r['chip'])}</td>"
                f"<td>{hits}</td><td>{arts}</td><td>{r['band']}</td></tr>"
            )
        panels.append(
            f'<section class="panel{active}" id="panel-{cat}">'
            f"<h2>{cat.title()}</h2>"
            f'<table><thead><tr><th>#</th><th>Chip</th><th>Vault hits</th>'
            f"<th>Artists (cap 12)</th><th>Band</th></tr></thead>"
            f"<tbody>{''.join(body)}</tbody></table></section>"
        )
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<title>Noun bank — full 1.7M vault</title>
<style>
:root {{ font-family: ui-sans-serif, system-ui, sans-serif; color: #111; background: #f6f4ef; }}
body {{ max-width: 1100px; margin: 32px auto; padding: 0 20px 80px; }}
h1 {{ font-size: 28px; margin: 0 0 8px; }}
.meta {{ color: #555; margin-bottom: 24px; }}
.tabs {{ display: flex; flex-wrap: wrap; gap: 6px; margin: 18px 0; }}
.tab {{ border: 1px solid #ccc; background: #fff; padding: 8px 12px; border-radius: 999px; cursor: pointer; }}
.tab.is-active {{ background: #111; color: #fff; border-color: #111; }}
.panel {{ display: none; }}
.panel.is-active {{ display: block; }}
table {{ width: 100%; border-collapse: collapse; background: #fff; }}
th, td {{ text-align: left; padding: 8px 10px; border-bottom: 1px solid #eee; font-size: 14px; }}
th {{ font-size: 12px; text-transform: uppercase; letter-spacing: .04em; color: #666; }}
td:nth-child(1), td:nth-child(3), td:nth-child(4) {{ font-variant-numeric: tabular-nums; }}
.banner {{ background: #111; color: #fff; padding: 10px 14px; border-radius: 8px; margin-bottom: 20px; }}
</style>
</head>
<body>
<div class="banner">FULL VAULT · {n_lines:,} bars · {n_artists} artists · {total} chips in the Nouns sheet</div>
<h1>Noun bank mine</h1>
<p class="meta">Walked every bar (no Gunna/YSL FTS cap). Rare = 1–30 vault hits. Artists column is capped at 12 during the scan. Keepers with no live match show as —.</p>
<table>
<thead><tr><th>Pocket</th><th>In sheet</th><th>Rare in sheet</th><th>Rare pool</th><th>Lead artists on this pocket</th></tr></thead>
<tbody>
{''.join(overview_rows)}
</tbody>
</table>
<div class="tabs">{''.join(tabs)}</div>
{''.join(panels)}
<script>
document.querySelectorAll('.tab').forEach(btn => {{
  btn.addEventListener('click', () => {{
    document.querySelectorAll('.tab,.panel').forEach(el => el.classList.remove('is-active'));
    btn.classList.add('is-active');
    document.getElementById('panel-' + btn.dataset.tab).classList.add('is-active');
  }});
}});
</script>
</body>
</html>
"""
    HTML_OUT.parent.mkdir(parents=True, exist_ok=True)
    HTML_OUT.write_text(html)
    vault = Path("/Users/samuel/Pictures/OB CLAUDE vault/📱 Penwork Studios - App/Noun bank — full vault 2026-09.html")
    try:
        vault.write_text(html)
    except OSError:
        pass


def _html(s: str) -> str:
    return (
        s.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


def mine():
    uni_to_cat, multi_at = build_lookups()
    # stats[cat][phrase] = {n, artists:set, neighbor:bool}
    stats = {cat: {} for cat in SEEDS}
    artist_hits = {cat: defaultdict(int) for cat in SEEDS}
    n_lines = 0
    n_used = 0

    print("mining", DB, flush=True)
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    cur = con.execute("SELECT line, artist FROM bars")
    while True:
        batch = cur.fetchmany(20000)
        if not batch:
            break
        for line, artist in batch:
            n_lines += 1
            toks = tokens(line or "")
            if not toks:
                continue
            # which cats fire
            fired: dict[str, list[int]] = defaultdict(list)
            ntok = len(toks)
            for i, t in enumerate(toks):
                for cat in uni_to_cat.get(t, ()):
                    if context_ok(toks, t, cat):
                        fired[cat].append(i)
                for parts, cat in multi_at.get(t, ()):
                    k = len(parts)
                    if i + k <= ntok and tuple(toks[i : i + k]) == parts:
                        fired[cat].extend(range(i, i + k))
            if not fired:
                continue
            used = False
            who = artist or "?"
            for cat, idxs in fired.items():
                grams = extract(toks, idxs, cat)
                if not grams:
                    continue
                used = True
                artist_hits[cat][who] += 1
                bucket = stats[cat]
                arts = who
                for gram in grams:
                    st = bucket.get(gram)
                    if st is None:
                        st = {"n": 0, "artists": set()}
                        bucket[gram] = st
                    st["n"] += 1
                    if len(st["artists"]) < 12:
                        st["artists"].add(arts)
            if used:
                n_used += 1
        if n_lines % 200000 == 0:
            print(f"... {n_lines} bars, hits={n_used}", flush=True)

    n_artists = con.execute("select count(distinct artist) from bars").fetchone()[0]
    report = [
        f"scanned {n_lines} bars, category-hit {n_used}",
        f"artists in vault: {n_artists}",
        "",
    ]
    picked = {}
    jsonable = {}
    csv_rows = ["pocket,chip,vault_hits,artists,band"]

    def stat_for(cat: str, word: str):
        bucket = stats[cat]
        keys = [
            word.lower(),
            word.lower().replace("'", ""),
            word.lower().replace("é", "e").replace("ö", "o").replace("î", "i").replace("ü", "u"),
            word.lower().replace("'rari", "rari"),
        ]
        for k in keys:
            if k in bucket:
                return bucket[k]
        return None

    def band_of(word: str, n) -> str:
        if n is None:
            return "keeper"
        if " " in word and n <= 30:
            return "rare"
        if n <= 200:
            return "mid"
        return "common"

    for cat in SEEDS:
        words = pick(cat, stats[cat])
        picked[cat] = words
        top_artists = sorted(artist_hits[cat].items(), key=lambda kv: -kv[1])[:8]
        n_phrases = len(stats[cat])
        n_rare = sum(1 for st in stats[cat].values() if st["n"] <= 30)
        rows = []
        report.append(f"=== {cat}  phrases={n_phrases} rare<=30={n_rare} picked={len(words)} ===")
        report.append("  artists: " + ", ".join(f"{a}({c})" for a, c in top_artists))
        report.append("  #    hits  arts  band     chip")
        for i, w in enumerate(words, 1):
            st = stat_for(cat, w)
            n = st["n"] if st else None
            na = len(st["artists"]) if st else None
            band = band_of(w, n)
            rows.append({"chip": w, "n": n, "artists": na, "band": band})
            n_s = str(n) if n is not None else "—"
            na_s = str(na) if na is not None else "—"
            report.append(f"  {i:3d}  {n_s:>5}  {na_s:>4}  {band:<8} {w}")
            csv_rows.append(
                f"{cat},{w.replace(',', ' ')},{n_s},{na_s},{band}"
            )
        report.append("")
        jsonable[cat] = {
            "picked": words,
            "rows": rows,
            "n_phrases": n_phrases,
            "n_rare": n_rare,
            "top_artists": top_artists,
        }

    REPORT.write_text("\n".join(report))
    JSON_OUT.write_text(json.dumps(jsonable, indent=2, default=list))
    CSV_OUT.write_text("\n".join(csv_rows) + "\n")
    write_html(jsonable, n_lines, n_used, n_artists)

    body = [SWIFT_HEADER.rstrip("\n")]
    for cat in SEEDS:
        body.append(swift_array(cat, picked[cat]))
    body.append(SWIFT_FOOTER.rstrip("\n"))
    SWIFT_OUT.write_text("\n".join(body) + "\n")
    print("wrote", SWIFT_OUT)
    print("wrote", REPORT)
    print("wrote", JSON_OUT)
    print("wrote", CSV_OUT)
    print("wrote", HTML_OUT)
    for cat, words in picked.items():
        print(f"  {cat:10} {len(words):4}  rare_pool={jsonable[cat]['n_rare']}")


if __name__ == "__main__":
    mine()
