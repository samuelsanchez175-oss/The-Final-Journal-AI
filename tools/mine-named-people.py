#!/usr/bin/env python3
"""Mine jeweler / producer / artist / opp names from the full bar catalog.

Walks every bar in BarHitsCatalog.sqlite (all artists). Not a Gunna slice.
Writes JSON + a review table. Does not overwrite NounBankStore; curate after.
"""
from __future__ import annotations

import json
import re
import sqlite3
import sys
import time
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "tools/bar-hits-catalog/BarHitsCatalog.sqlite"
JSON_OUT = ROOT / "docs/noun-bank-named-people.json"
OPP_JSON_OUT = ROOT / "docs/noun-bank-opp-names.json"
MD_OUT = ROOT / "docs/noun-bank-named-people.md"
LOG = Path("/tmp/mine-named-people.log")

WORD = re.compile(r"[a-z0-9$']+")
# Keep hyphenated names (O-Block) as one token for opp-neighbor harvest.
OPP_WORD = re.compile(r"[A-Za-z0-9$']+(?:-[A-Za-z0-9$']+)*")

# Homographs only count with a disambiguator on the line.
CONTEXT = {
    "dang": {"jewelers": {"johnny", "jeweler", "grill", "grillz", "diamond", "iced", "chain", "icebox"}},
    "jacob": {"jewelers": {"jeweler", "watch", "iced", "diamond", "bust", "patek", "rollie"}},
    "metro": {"producers": {"boomin", "boom", "beat", "produced", "tag", "808", "trust", "young"}},
    "southside": {"producers": {"beat", "produced", "tag", "808", "mafia", "metro", "wheezy", "track"}},
    "london": {"producers": {"track", "datrack", "beat", "produced", "tag"}},
    "mustard": {"producers": {"dj", "beat", "produced", "tag", "track"}},
    "40": {"producers": {"noah", "shebib", "drake", "ovo", "produced", "beat"}},
    "pierre": {"producers": {"bourne", "beat", "produced", "tag"}},
    "dre": {"producers": {"dr", "beat", "produced", "aftermath", "compton"}},
    "kanye": {"producers": {"beat", "produced", "west", "ye"}, "artists": {"west", "ye", "yeezy"}},
    "ye": {"artists": {"kanye", "west", "yeezus"}},
    "von": {"artists": {"king", "durk", "chicago"}, "opps": {"opps", "opp", "killed", "slide"}},
    "duck": {"opps": {"opp", "opps", "chicago", "oblock", "king", "von"}},
}

JEWELERS = [
    "johnny dang", "johnny", "dang", "icebox", "avianne", "eliantte",
    "ben baller", "baller", "jacob the jeweler", "jacob", "lorraine schwartz",
    "lorraine", "jason of beverly hills", "ifandco", "if and co", "greg yuna",
    "alex woo", "graff", "harry winston", "chopard", "david yurman",
    "jason of bh", "custom jeweler", "beverly hills jeweler", "miami jeweler",
    "hatton garden", "shayne smith", "alex moss", "tomorrows antiques",
    "icebox diamonds", "avianne and co", "eliantte and co", "johnny dang chain",
    "ben baller chain", "jacob watch", "lorraine necklace",
]

PRODUCERS = [
    "metro boomin", "metro", "southside", "wheezy", "london on da track",
    "london on the track", "tay keith", "mike will", "mike will made it",
    "mike will made-it", "zaytoven", "tm88", "dj mustard", "mustard",
    "hit-boy", "hit boy", "hitboy", "pierre bourne", "pi'erre bourne",
    "pierre", "cardo", "cardo got wings", "dun deal", "808 mafia",
    "lex luger", "sonny digital", "wondagurl", "boi-1da", "boi 1da", "boi1da",
    "noah 40", "vinylz", "murda beatz", "nick mira", "t-minus", "t minus",
    "pharrell", "timbaland", "dr dre", "alchemist", "madlib", "dj premier",
    "just blaze", "scott storch", "bangladesh", "drumma boy",
    "honorable c note", "honorable c.n.o.t.e", "superstar george",
    "cassius jay", "turbo", "outtatown", "dy krazy", "keanu beats",
    "fki", "charlie heat", "atl jacob", "cubeatz", "cu beatz", "ronny j",
    "bnyx", "f1lthy", "star boy", "skipondabeat", "oz on the beat",
    "frank dukes", "allen ritter", "southside on the track",
    "if young metro", "wheezy beats", "zaytoven beat", "tay keith beat",
    "london beat", "mustard beat", "hitboy beat",
]

ARTISTS_EXTRA = [
    "drake", "lil wayne", "wayne", "future", "young thug", "thugger", "gunna",
    "lil baby", "baby", "kodak black", "kodak", "nba youngboy", "youngboy",
    "lil durk", "durk", "king von", "von", "pooh shiesty", "moneybagg yo",
    "g herbo", "21 savage", "offset", "quavo", "takeoff", "migos",
    "playboi carti", "carti", "lil uzi vert", "uzi", "juice wrld", "juice",
    "travis scott", "travis", "kendrick", "j cole", "cole", "nas", "jay-z",
    "jay z", "eminem", "50 cent", "kanye", "ye", "tyler", "frank ocean",
    "the weeknd", "sza", "rihanna", "nicki", "cardi", "megan", "latto",
    "ice spice", "sexyy red", "gucci mane", "jeezy", "t.i.", "ludacris",
    "outkast", "andre 3000", "2pac", "pac", "biggie", "nipsey", "pop smoke",
    "xxx", "peep", "yeat", "ken carson", "destroy lonely", "trippie redd",
    "ski mask", "lil tjay", "fivio", "asap rocky", "rocky", "asap ferg",
    "don toliver", "soFaygo", "summrs", "kankan", "autumn", "lone",
    "chief keef", "sosa", "gherbo", "polo g", "lil tecca", "rod wave",
    "toosii", "nle choppa", "lil tjay", "quando rondo", "ynw melly",
    "dababy", "meg thee stallion", "doja", "the kid laroi", "jack harlow",
    "central cee", "dave", "stormzy", "skepta", "j hus", "headie one",
    "popcaan", "vybz kartel", "shabba", "buju", "burna boy", "wizkid",
    "davido", "rema", "tems", "asake", "shallipopi",
    "youngboy never broke again", "nba", "yt", "wheniwas13",
]

OPPS = [
    "opps", "opp", "opp pack", "opp block", "opp slide", "the opps",
    "duck", "o-block", "oblock", "stl", "jaro", "tyquan world",
    "600", "051", "300", "bd", "gd", "6ix9ine", "tekashi",
    "snitch", "rat", "opp boy", "opp nigga", "them opps",
    "slide on the opps", "opp truck", "opp van", "opp house",
]

STOP = {
    "the", "a", "an", "and", "or", "to", "of", "in", "on", "my", "i", "you", "it",
    "we", "they", "that", "this", "with", "from", "for", "yeah", "yah", "uh",
    "ayy", "oh", "yo", "so", "if", "but", "as", "is", "was", "be", "me", "im",
    "i'm", "it's", "at", "up", "out", "off", "just", "like", "got", "get",
    "no", "not", "man", "when", "then", "all", "some", "them", "these", "your",
    "our", "his", "her", "she", "he", "him", "us", "em", "ya", "yall", "nigga",
    "niggas", "bitch", "bitches", "shit", "fuck", "ain't", "aint", "don't",
    "dont", "can't", "gon", "gonna", "finna", "still", "now", "too", "huh",
}

DENY = {"nigga", "nigger", "rape", "pedo", "retard"}

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

VERBISH = {
    "got", "get", "gets", "getting", "take", "took", "make", "made", "had", "i'm",
    "im", "we", "they", "you", "i", "don", "dont", "don't", "swear", "know",
    "think", "talkin", "talkin'", "sippin", "sippin'", "drinkin", "drinkin'",
    "pour", "poured", "wanna", "gonna", "finna", "let", "ain't", "aint", "was",
    "were", "been", "doing", "did", "does", "can't", "cant", "won't", "wont",
    "i'll", "you'll", "we'll", "it's", "that's", "there's", "they're",
    "dead", "die", "died", "dying", "kill", "killed", "killing", "smoke",
    "smokin", "smokin'", "smoking", "drop", "dropped", "hit", "see", "say",
    "said", "want", "wanted", "put", "make", "stay", "run", "keep", "send",
    "slide", "shoot", "shot", "pull", "need", "go", "come", "walk", "talk",
    "leave", "watch", "pop", "are", "been", "tryin", "tryna", "tryin'",
}

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
    "didnt", "don't", "dont", "outside", "another", "biggest", "couple",
    "pack", "block", "blocks", "ass", "thot", "time", "nine", "face",
    "inside", "same", "many", "more", "one", "two", "any", "who", "about",
}

# 1-token (or hyphenated) opp names allowed without Genius capital letters.
KNOWN_OPP_NAMES = {
    "o-block", "oblock", "o block", "jaro", "stl", "051", "600", "300",
    "tyquan", "tyquan world", "duck", "tekashi", "6ix9ine", "bd", "gd",
}
KNOWN_OPP_CANON = {
    "o-block": "o-block",
    "oblock": "o-block",
    "o block": "o-block",
    "jaro": "jaro",
    "stl": "stl",
    "051": "051",
    "600": "600",
    "300": "300",
    "tyquan": "tyquan",
    "tyquan world": "tyquan world",
    "duck": "duck",
    "tekashi": "tekashi",
    "6ix9ine": "6ix9ine",
    "bd": "bd",
    "gd": "gd",
}
KNOWN_OPP_DISPLAY = {
    "o-block": "O-Block",
    "jaro": "Jaro",
    "stl": "STL",
    "051": "051",
    "600": "600",
    "300": "300",
    "tyquan": "Tyquan",
    "tyquan world": "Tyquan World",
    "duck": "Duck",
    "tekashi": "Tekashi",
    "6ix9ine": "6ix9ine",
    "bd": "BD",
    "gd": "GD",
}

OPP_TRIGGERS = {
    "opp", "opps",
}


def log(msg: str) -> None:
    LOG.parent.mkdir(parents=True, exist_ok=True)
    with LOG.open("a") as f:
        f.write(msg + "\n")
    print(msg, flush=True)


def tokens(line: str) -> list[str]:
    return WORD.findall(line.lower().replace("’", "'"))


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


def opp_token_spans(line: str) -> list[tuple[str, str]]:
    """(lower, original) tokens, keeping hyphenated names together."""
    line = (line or "").replace("’", "'")
    return [(m.group(0).lower(), m.group(0)) for m in OPP_WORD.finditer(line)]


def line_is_shouting(origs: list[str]) -> bool:
    letters = [c for t in origs for c in t if c.isalpha()]
    if len(letters) < 8:
        return False
    return all(c.isupper() for c in letters)


def known_opp_key(parts_l: list[str]) -> str | None:
    span = " ".join(parts_l)
    joined = "".join(parts_l)
    hyphen = "-".join(parts_l)
    for cand in (span, joined, hyphen):
        if cand in KNOWN_OPP_NAMES:
            return KNOWN_OPP_CANON.get(cand, cand)
    return None


def is_opp_name_span(parts_l: list[str], parts_o: list[str], shouting: bool) -> bool:
    """2–3 tokens with a capital, or a known-set name (may be 1 token)."""
    if not parts_l:
        return False
    if any(len(t) < 2 for t in parts_l):
        return False
    if any(t in STOP or t in VERBISH or t in CLAUSE for t in parts_l):
        return False
    if any(t in {"opp", "opps"} for t in parts_l):
        return False
    if is_denied_name(" ".join(parts_l)):
        return False
    known = known_opp_key(parts_l)
    n = len(parts_l)
    if known:
        return True
    if n not in (2, 3):
        return False
    if shouting:
        return False
    has_cap = any(any(c.isupper() for c in p) for p in parts_o)
    return has_cap


def pick_opp_display(key: str, forms: dict[str, int]) -> str:
    if key in KNOWN_OPP_DISPLAY:
        return KNOWN_OPP_DISPLAY[key]
    if forms:
        return max(forms.items(), key=lambda kv: (kv[1], kv[0]))[0]
    return " ".join(t[:1].upper() + t[1:] for t in key.split())


def seed_parts(seeds: list[str]) -> list[tuple[tuple[str, ...], str]]:
    out = []
    for s in seeds:
        if is_denied_name(s):
            continue
        parts = tuple(WORD.findall(s.lower()))
        if parts:
            out.append((parts, s))
    out.sort(key=lambda it: -len(it[0]))
    return out


def context_ok(toks: set[str], head: str, cat: str) -> bool:
    req = CONTEXT.get(head)
    if not req or cat not in req:
        return True
    return bool(toks & req[cat])


def quality_name(gram: str) -> bool:
    low = gram.lower()
    if any(bad in low for bad in DENY):
        return False
    if is_denied_name(gram):
        return False
    toks = gram.split()
    if not (1 <= len(toks) <= 4):
        return False
    if toks[0] in STOP or toks[-1] in STOP:
        return False
    if any(t in VERBISH or t in CLAUSE for t in toks):
        return False
    if any(len(t) == 1 and t not in {"j", "t", "g"} for t in toks):
        return False
    return True


def load_catalog_artists(con: sqlite3.Connection) -> list[str]:
    rows = con.execute(
        "SELECT artist, COUNT(*) n FROM bars WHERE artist IS NOT NULL AND artist != '' "
        "GROUP BY artist ORDER BY n DESC"
    ).fetchall()
    names = []
    for artist, _n in rows:
        a = artist.strip()
        if not a or len(a) < 2:
            continue
        # skip credits that look like three people joined
        if a.count(",") >= 2:
            continue
        if is_denied_name(a):
            continue
        names.append(a)
    return names


def scan() -> dict:
    if not DB.exists():
        raise SystemExit(f"missing catalog {DB}")
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    con.execute("PRAGMA query_only=ON")
    catalog_artists = load_catalog_artists(con)
    log(f"catalog artists: {len(catalog_artists)}")

    artist_seeds = list(ARTISTS_EXTRA)
    for name in catalog_artists:
        artist_seeds.append(name)
        # also last token if multi-word (Young Thug -> thug is too noisy; skip)

    packed = {
        "jewelers": seed_parts(JEWELERS),
        "producers": seed_parts(PRODUCERS),
        "artists": seed_parts(artist_seeds),
        "opps": seed_parts(OPPS),
    }
    # longest-first already; build first-token index
    index: dict[str, list[tuple[str, tuple[str, ...], str]]] = defaultdict(list)
    for cat, items in packed.items():
        for parts, raw in items:
            index[parts[0]].append((cat, parts, raw))

    stats: dict[str, dict[str, dict]] = {c: {} for c in packed}
    opp_neighbors: dict[str, dict] = {}

    def bump(cat: str, raw: str, artist: str) -> None:
        if is_denied_name(raw):
            return
        slot = stats[cat].setdefault(raw, {"n": 0, "artists": set()})
        slot["n"] += 1
        if artist:
            slot["artists"].add(artist)

    n_lines = 0
    cur = con.execute("SELECT artist, line FROM bars")
    while True:
        batch = cur.fetchmany(20_000)
        if not batch:
            break
        for artist, line in batch:
            n_lines += 1
            if not line:
                continue
            toks = tokens(line)
            if len(toks) < 2:
                continue
            tset = set(toks)
            used = set()
            i = 0
            while i < len(toks):
                hits = index.get(toks[i])
                matched = False
                if hits:
                    for cat, parts, raw in hits:
                        k = len(parts)
                        if i + k <= len(toks) and tuple(toks[i : i + k]) == parts:
                            if context_ok(tset, parts[0], cat):
                                bump(cat, raw, artist or "")
                                used.add((cat, raw))
                                i += k
                                matched = True
                                break
                if not matched:
                    i += 1

            # Opp neighbor harvest uses Genius mixed-case `line`, not
            # lowercased tokens. Names are 2–3 tokens with a capital, or
            # a small known-set (Duck, O-Block, STL, …).
            if "opp" not in line.lower():
                continue
            spans = opp_token_spans(line)
            if any(low in OPP_TRIGGERS for low, _orig in spans):
                lowers = [s[0] for s in spans]
                origs = [s[1] for s in spans]
                shouting = line_is_shouting(origs)
                for i, tok in enumerate(lowers):
                    if tok not in OPP_TRIGGERS:
                        continue
                    windows: list[tuple[int, int]] = []
                    for k in (1, 2, 3):
                        if i >= k:
                            windows.append((i - k, i))
                        if i + 1 + k <= len(lowers):
                            windows.append((i + 1, i + 1 + k))
                    for lo, hi in windows:
                        parts_l = lowers[lo:hi]
                        parts_o = origs[lo:hi]
                        if not is_opp_name_span(parts_l, parts_o, shouting):
                            continue
                        known = known_opp_key(parts_l)
                        key = known or " ".join(parts_l)
                        orig_span = " ".join(parts_o)
                        slot = opp_neighbors.setdefault(
                            key, {"n": 0, "artists": set(), "forms": defaultdict(int)}
                        )
                        slot["n"] += 1
                        slot["forms"][orig_span] += 1
                        if artist:
                            slot["artists"].add(artist)

        if n_lines % 200_000 == 0:
            log(f"scanned {n_lines:,} bars")

    log(f"done {n_lines:,} bars")

    def freeze(cat_stats: dict) -> list[dict]:
        rows = []
        for raw, st in cat_stats.items():
            rows.append(
                {
                    "name": raw,
                    "bars": st["n"],
                    "artists": len(st["artists"]),
                    "sample_artists": sorted(st["artists"])[:8],
                }
            )
        rows.sort(key=lambda r: (-r["artists"], -r["bars"], r["name"]))
        return rows

    def freeze_opp_neighbors(neighbors: dict) -> list[dict]:
        rows = []
        for key, st in neighbors.items():
            name = pick_opp_display(key, st.get("forms") or {})
            n_art = len(st["artists"])
            n_bars = st["n"]
            if n_bars < 5 or n_art < 3:
                continue
            rows.append({"name": name, "bars": n_bars, "artists": n_art})
        rows.sort(key=lambda r: (-r["artists"], -r["bars"], r["name"].lower()))
        return rows

    payload = {
        "bars_scanned": n_lines,
        "catalog_artists": len(catalog_artists),
        "jewelers": freeze(stats["jewelers"]),
        "producers": freeze(stats["producers"]),
        "artists": freeze(stats["artists"]),
        "opps": freeze(stats["opps"]),
        "opp_neighbors": freeze_opp_neighbors(opp_neighbors),
    }
    return payload


def write_md(payload: dict) -> None:
    lines = [
        "# Named people in the full vault",
        "",
        f"Scanned **{payload['bars_scanned']:,}** bars across **{payload['catalog_artists']}** catalog artists.",
        "",
        "Short-form kept over spelled-out duplicates (Johnny / Johnny Dang stay as one house when both hit).",
        "",
    ]
    for cat, title in [
        ("jewelers", "Jewelers"),
        ("producers", "Producers"),
        ("artists", "Artists"),
        ("opps", "Opp seeds"),
        ("opp_neighbors", "Opp neighbors (mined next to opp/opps)"),
    ]:
        rows = payload[cat]
        lines.append(f"## {title}")
        lines.append("")
        lines.append("| Name | Bars | Artists |")
        lines.append("| --- | ---: | ---: |")
        for row in rows:
            if row["bars"] < 2 and cat != "jewelers":
                continue
            if cat == "opp_neighbors" and (row["bars"] < 5 or row["artists"] < 3):
                continue
            if cat == "artists" and row["bars"] < 15:
                continue
            lines.append(f"| {row['name']} | {row['bars']:,} | {row['artists']} |")
        lines.append("")
    MD_OUT.write_text("\n".join(lines), encoding="utf-8")


def write_opp_json(payload: dict) -> None:
    chips = [
        {"name": r["name"], "bars": r["bars"], "artists": r["artists"]}
        for r in payload.get("opp_neighbors", [])
    ]
    OPP_JSON_OUT.parent.mkdir(parents=True, exist_ok=True)
    OPP_JSON_OUT.write_text(
        json.dumps({"chips": chips}, indent=2) + "\n", encoding="utf-8"
    )


def main() -> None:
    LOG.write_text("", encoding="utf-8")
    t0 = time.time()
    payload = scan()
    elapsed = time.time() - t0
    write_opp_json(payload)
    log(f"wrote {OPP_JSON_OUT}")
    log(f"runtime {elapsed:.1f}s")
    log(f"opp name chips: {len(payload['opp_neighbors'])}")
    for row in payload["opp_neighbors"][:40]:
        log(f"  {row['name']}: bars={row['bars']} artists={row['artists']}")
    for cat in ("jewelers", "producers", "artists", "opps"):
        n = len(payload[cat])
        hits = sum(1 for r in payload[cat] if r["bars"] > 0)
        log(f"{cat}: {hits}/{n} seeds hit")
    # Full named-people JSON/MD is a later merge; this pass writes opp names.


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        log(f"FAILED: {exc}")
        raise
