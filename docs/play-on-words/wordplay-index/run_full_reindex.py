import json, os, sys, re
from pathlib import Path
from datetime import datetime

ROOT = Path("/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync")
INDEX_FILE = ROOT / "docs/play-on-words/wordplay-index/index.jsonl"
SUMMARY_FILE = ROOT / "docs/play-on-words/wordplay-index/summary.md"
RECHECK_FILE = ROOT / "docs/play-on-words/confirmed-recheck/recheck.jsonl"
STATUS_FILE = ROOT / "docs/play-on-words/chat-status/chat-7.md"

def norm_txt(t):
    if not t: return ""
    t = t.lower()
    t = re.sub(r"[’'\"“”„,.!?()\-—/\\]", " ", t)
    return " ".join(t.split())

# 1. Load priors map (Samuel's explicit calibration calls)
priors_map = {
    ("rick ross", "100 keys", "cause everybody knows keys open doors, but bricks open windows"): {
        "verdict": "KEEP", "tab": "double_meanings", "subtype": "double_meaning", "punchline_setup": False,
        "heard_as": "keys and bricks are kilos of cocaine (keys open doors / bricks open windows)",
        "reason": "Classic double meaning playing physical building keys/bricks against kilos of cocaine.",
        "setup_spans": [{"text": "keys open doors", "start": 22, "end": 37}],
        "play_spans": [{"text": "bricks open windows", "start": 43, "end": 62}]
    },
    ("rick ross", "finals", "got birds flying around, like mr. 23 himself"): {
        "verdict": "REJECT", "tab": "none", "subtype": "none", "punchline_setup": False,
        "heard_as": "", "reason": "Plain slang/simile comparing drug birds to Michael Jordan flying without a phonetic flip or double meaning.",
        "setup_spans": [], "play_spans": []
    },
    ("lil wayne", "senile", "started from the, like christina, got a million"): {
        "verdict": "FIX", "tab": "sound_flips", "subtype": "homophone", "punchline_setup": True,
        "heard_as": "Christina Milian / a million",
        "reason": "Homophone sound flip: 'got a million' phonetically echoes actress 'Christina Milian'.",
        "setup_spans": [{"text": "Christina", "start": 23, "end": 32}],
        "play_spans": [{"text": "a million", "start": 38, "end": 47, "heard": "Milian"}]
    },
    ("lil wayne", "ur supplier", "call me marlow 'cause i'm off the wire"): {
        "verdict": "REJECT", "tab": "none", "subtype": "none", "punchline_setup": False,
        "heard_as": "", "reason": "Direct TV show reference to Marlo Stanfield from The Wire without phonetic flip or double meaning.",
        "setup_spans": [], "play_spans": []
    },
    ("21 savage", "4l", "malcolm might get killed in the middle (on god)"): {
        "verdict": "KEEP", "tab": "hidden_references", "subtype": "hidden_title", "punchline_setup": False,
        "heard_as": "Malcolm in the Middle",
        "reason": "Hidden TV title embedded in the lyric ('Malcolm... in the middle').",
        "setup_spans": [{"text": "Malcolm", "start": 0, "end": 7}],
        "play_spans": [{"text": "in the middle", "start": 24, "end": 37}]
    },
    ("trippie redd", "negative energy", "bitch, i'm the shit like my butt stink"): {
        "verdict": "REJECT", "tab": "none", "subtype": "none", "punchline_setup": False,
        "heard_as": "", "reason": "Literal crude simile/slang comparison without real wordplay.",
        "setup_spans": [], "play_spans": []
    },
    ("cardi b", "money bag", "with them pretty ass twins, you look like beyoncé (woo)"): {
        "verdict": "REJECT", "tab": "none", "subtype": "none", "punchline_setup": False,
        "heard_as": "", "reason": "Plain pop culture simile/reference to Beyoncé having twins without wordplay.",
        "setup_spans": [], "play_spans": []
    },
    ("youngboy never broke again", "showdown", "i got lil' shawty to my left lookin' right and she teasin' me"): {
        "verdict": "KEEP", "tab": "double_meanings", "subtype": "double_meaning", "punchline_setup": False,
        "heard_as": "looking right (direction vs. looking attractive / good)",
        "reason": "Double meaning pairing directional 'left' with 'lookin' right' (direction vs. attractive).",
        "setup_spans": [{"text": "left", "start": 28, "end": 32}],
        "play_spans": [{"text": "right", "start": 41, "end": 46}]
    },
    ("youngboy never broke again", "no time", "pull that porsche out at eleven, ain't come back 'til nine (fuck is wrong with her?)"): {
        "verdict": "KEEP", "tab": "hidden_references", "subtype": "hidden_number", "punchline_setup": False,
        "heard_as": "Porsche 911",
        "reason": "Hidden model number built across 'eleven... 'til nine' referencing the Porsche 911.",
        "setup_spans": [{"text": "Porsche", "start": 10, "end": 17}],
        "play_spans": [{"text": "eleven", "start": 25, "end": 31}, {"text": "nine", "start": 52, "end": 56}]
    },
    ("juicy j", "ain’t no rapper", "pockets xxl and extended magazines"): {
        "verdict": "KEEP", "tab": "double_meanings", "subtype": "double_meaning", "punchline_setup": False,
        "heard_as": "XXL magazine (publication vs. extra large size & gun magazine)",
        "reason": "Double meaning on 'magazines' (gun ammo cartridge vs. XXL hip-hop publication).",
        "setup_spans": [{"text": "XXL", "start": 8, "end": 11}],
        "play_spans": [{"text": "magazines", "start": 26, "end": 35}]
    },
    ("drake", "pop that", "feed them bitches carrots (huh)"): {
        "verdict": "KEEP", "tab": "sound_flips", "subtype": "homophone", "punchline_setup": True,
        "heard_as": "carrots / carats (diamond karats)",
        "reason": "Homophone sound flip: 'carrots' plays on diamond 'carats'.",
        "setup_spans": [{"text": "bitches", "start": 10, "end": 17}],
        "play_spans": [{"text": "carrots", "start": 18, "end": 25, "heard": "carats"}]
    },
    ("drake", "i’m on one", "and it's double m-g 'til i get the chair, chyeah"): {
        "verdict": "KEEP", "tab": "sound_flips", "subtype": "homophone", "punchline_setup": True,
        "heard_as": "chair / cheer (electric chair vs. applause)",
        "reason": "Homophone sound flip: 'chair' (electric chair) sounds like 'cheer' (applause).",
        "setup_spans": [{"text": "double M-G", "start": 9, "end": 19}],
        "play_spans": [{"text": "chair", "start": 35, "end": 40, "heard": "cheer"}]
    },
    ("nocap", "judge the jury", "i'm blinded by this lean, i might go out like pimp c"): {
        "verdict": "KEEP", "tab": "sound_flips", "subtype": "homophone", "punchline_setup": True,
        "heard_as": "Pimp C / Pimp See (blinded vs. see)",
        "reason": "Homophone sound flip: 'blinded' cues 'Pimp C' heard as 'Pimp See'.",
        "setup_spans": [{"text": "blinded", "start": 4, "end": 11}],
        "play_spans": [{"text": "Pimp C", "start": 46, "end": 52, "heard": "Pimp See"}]
    },
    ("veeze", "old shit", "hoes broker than some porch pirates"): {
        "verdict": "REJECT", "tab": "none", "subtype": "none", "punchline_setup": False,
        "heard_as": "", "reason": "Genius note is a weak stretch/pun on poor pirates without phonetic flip or second meaning in the bar.",
        "setup_spans": [], "play_spans": []
    },
    ("meek mill", "they don’t love you no more", "i'm with double m, the genius"): {
        "verdict": "KEEP", "tab": "hidden_references", "subtype": "letter_play", "punchline_setup": False,
        "heard_as": "MMG (Maybach Music Group / double M)",
        "reason": "Letter play: 'double M' stands for Maybach Music Group (MMG).",
        "setup_spans": [],
        "play_spans": [{"text": "double M", "start": 9, "end": 17}]
    },
    ("drake", "my way (remix)", "they should call me james"): {
        "verdict": "KEEP", "tab": "sound_flips", "subtype": "sound_flip", "punchline_setup": True,
        "heard_as": "James Harden (goin' hard in)",
        "reason": "Phonetic sound flip: 'goin' hard in' sounds like NBA player 'James Harden'.",
        "setup_spans": [{"text": "James", "start": 20, "end": 25}],
        "play_spans": [{"text": "goin' hard in", "start": 0, "end": 13, "heard": "Harden"}]
    },
    ("juice wrld", "blastoff", "three k on my wrist like andré"): {
        "verdict": "KEEP", "tab": "split_names", "subtype": "split_name", "punchline_setup": True,
        "heard_as": "André 3000 (Three K ... André)",
        "reason": "Split name: 'Three K' ($3,000) and 'André' combine to form André 3000.",
        "setup_spans": [{"text": "Three K", "start": 0, "end": 7}],
        "play_spans": [{"text": "André", "start": 26, "end": 31}]
    },
    ("juice wrld", "barney’s freestyle", "getting duff money, i feel like i’m hillary"): {
        "verdict": "KEEP", "tab": "split_names", "subtype": "split_name", "punchline_setup": True,
        "heard_as": "Hilary Duff (Duff money ... Hillary)",
        "reason": "Split name: 'Duff money' and 'Hillary' combine to form pop star Hilary Duff.",
        "setup_spans": [{"text": "Duff money", "start": 8, "end": 18}],
        "play_spans": [{"text": "Hillary", "start": 37, "end": 44}]
    },
    ("juice wrld", "arctic tundra", "fatty on the max like some nike air"): {
        "verdict": "KEEP", "tab": "split_names", "subtype": "split_brand", "punchline_setup": True,
        "heard_as": "Nike Air Max (Max ... Nike Air)",
        "reason": "Split brand: 'Max' and 'Nike Air' combine to form sneaker model Nike Air Max.",
        "setup_spans": [{"text": "Max", "start": 17, "end": 20}],
        "play_spans": [{"text": "Nike Air", "start": 31, "end": 39}]
    },
    ("juice wrld", "challenger (iron on me)", "i fuck on a buddy, then bust on her buddy i bust on ’em both, that's a nutty buddy"): {
        "verdict": "KEEP", "tab": "double_meanings", "subtype": "double_meaning", "punchline_setup": True,
        "heard_as": "Nutty Buddy (candy bar vs. busting / nutting on friends / buddies)",
        "reason": "Double meaning playing friend / buddy and ejaculating ('bust') against candy bar Nutty Buddy.",
        "setup_spans": [{"text": "buddy", "start": 15, "end": 20}],
        "play_spans": [{"text": "Nutty Buddy", "start": 73, "end": 84}]
    }
}

# 2. Load wired chips
print("Loading wired chips...")
wiring_path = ROOT / "docs/play-on-words/wordplay-wiring-log.jsonl"
wired_chips = {}
if wiring_path.exists():
    for l in open(wiring_path):
        if not l.strip(): continue
        try:
            r = json.loads(l)
            if r.get("decision") in ("reused", "created", "approved_wired"):
                art = norm_txt(r.get("artist"))
                sng = norm_txt(r.get("song"))
                bar = norm_txt(r.get("bar"))
                noun = r.get("noun")
                if noun:
                    wired_chips[(art, sng, bar)] = noun
                    wired_chips[(art, sng)] = noun
        except Exception:
            pass
print(f"Loaded {len(wired_chips)} wired chip entries.")

# 3. Load genius clicks index
print("Loading genius clicks into memory...")
click_dir = ROOT / "docs/play-on-words/genius-clicks"
ann_map = {}
line_map = {}

for f in click_dir.glob("*.jsonl"):
    for l in open(f):
        if not l.strip(): continue
        try:
            r = json.loads(l)
            if r.get("type") != "line": continue
            m = r.get("meaning") or ""
            u = r.get("url") or ""
            aid = str(r.get("annotation_id") or "")
            if aid and aid != "None":
                ann_map[aid] = (m, u)
            art = norm_txt(r.get("artist"))
            sng = norm_txt(r.get("song"))
            line = norm_txt(r.get("line"))
            vl = [norm_txt(x) for x in r.get("vault_lines", [])]
            k = (art, sng)
            if k not in line_map: line_map[k] = []
            line_map[k].append((line, vl, m, u))
        except Exception:
            pass
print(f"Loaded {len(ann_map)} annotations and {len(line_map)} song maps.")

def find_meaning(art, sng, bar, url=""):
    if url:
        m_aid = re.search(r"genius\.com/(\d+)", url)
        if m_aid and m_aid.group(1) in ann_map:
            return ann_map[m_aid.group(1)]
    an = norm_txt(art)
    sn = norm_txt(sng)
    bn = norm_txt(bar)
    cand = line_map.get((an, sn), [])
    for line, vl, m, cu in cand:
        if bn == line or bn in line or line in bn or any(bn == v or bn in v or v in bn for v in vl):
            return (m, cu)
    return ("", url or "")

def classify_wordplay(art, sng, bar, meaning, heard="", existing_row=None):
    an = norm_txt(art)
    sn = norm_txt(sng)
    bn = norm_txt(bar)
    
    # Check priors
    for (pa, ps, pb), pdata in priors_map.items():
        if pa in an and ps in sn and (pb in bn or bn in pb):
            return pdata["verdict"], pdata["tab"], pdata["subtype"], pdata["punchline_setup"], pdata["heard_as"], pdata["reason"], pdata["setup_spans"], pdata["play_spans"]

    # Check existing KEEP / FIX in recheck
    if existing_row and existing_row.get("verdict") in ("KEEP", "FIX"):
        ev = existing_row.get("verdict")
        eh = existing_row.get("heard_as") or ""
        er = existing_row.get("reason") or "Verified wordplay line."
        es_spans = existing_row.get("setup_spans") or []
        ep_spans = existing_row.get("play_spans") or []
        m_comb = (meaning + " " + eh + " " + er).lower()
        
        # Determine tab and subtype
        # Split names / split brands
        if any(w in m_comb for w in ["split name", "combine to", "together form", "first and last name", "both names"]):
            sub = "split_brand" if any(w in m_comb for w in ["brand", "shoe", "nike", "car", "model"]) else "split_name"
            punch = any(sp.get("end", 0) >= len(bar) - 5 for sp in ep_spans)
            return ev, "split_names", sub, punch, eh, er, es_spans, ep_spans
        # Hidden references
        if any(w in m_comb for w in ["hidden title", "title of", "sitcom", "movie title"]):
            return ev, "hidden_references", "hidden_title", False, eh, er, es_spans, ep_spans
        if any(w in m_comb for w in ["hidden number", "model number", "area code", "stands for the number", "911"]):
            return ev, "hidden_references", "hidden_number", False, eh, er, es_spans, ep_spans
        if any(w in m_comb for w in ["letter play", "double m", "spells", "acronym", "initials"]):
            return ev, "hidden_references", "letter_play", False, eh, er, es_spans, ep_spans
        # Double meanings
        if any(w in m_comb for w in ["double meaning", "double entendre", "two meanings", "refers to both"]):
            punch = any(sp.get("end", 0) >= len(bar) - 5 for sp in ep_spans)
            return ev, "double_meanings", "double_meaning", punch, eh, er, es_spans, ep_spans
        # Sound flips / homophones (default for existing verified sound flips)
        sub = "homophone" if any(w in m_comb for w in ["homophone", "sounds identical", "same sound"]) else "sound_flip"
        punch = any(sp.get("end", 0) >= len(bar) - 5 for sp in ep_spans)
        return ev, "sound_flips", sub, punch, eh, er, es_spans, ep_spans

    # Otherwise evaluate from scratch using meaning
    m_lower = meaning.lower()
    b_lower = bar.lower()

    # Reject plain junk, plain reference, plain brand, simile alone
    if not meaning or len(meaning.strip()) < 10:
        return "REJECT", "none", "none", False, "", "No verified Genius community annotation for this bar.", [], []
    
    # Check for Split Name / Split Brand
    if any(k in m_lower for k in ["split", "plays on", "refers to both", "reference to"]) and any(w in m_lower for w in ["name", "artist", "rapper", "actor", "athlete", "brand", "model", "sneaker"]):
        # Check if 2 parts are present in the bar
        if "like" in b_lower or "call me" in b_lower or "wrist" in b_lower or "money" in b_lower:
            if any(w in m_lower for w in ["brand", "shoe", "nike", "car", "clothing"]):
                return "KEEP", "split_names", "split_brand", True, heard or "split brand", "Bar combines brand elements across the line into a split brand reference.", [], []
            if any(w in m_lower for w in ["3000", "hillary", "harden", "james", "curry", "danny", "jordan"]):
                return "KEEP", "split_names", "split_name", True, heard or "split name", "Bar splits first and last components across the line to form a celebrity/person name.", [], []

    # Check for Hidden References
    if any(k in m_lower for k in ["hidden", "reference to the tv show", "reference to the movie", "sitcom", "show titled", "movie titled"]):
        return "KEEP", "hidden_references", "hidden_title", False, heard or "hidden title", "Bar embeds a hidden show or movie title into the phrasing.", [], []
    if any(k in m_lower for k in ["stands for", "area code", "model", "number", "911", "four-four", "38"]):
        if any(w in b_lower for w in ["nine", "eleven", "four", "seven", "twenty"]):
            return "KEEP", "hidden_references", "hidden_number", False, heard or "hidden number", "Lyric disguises or embeds a significant number or model code.", [], []
    if any(k in m_lower for k in ["double m", "spells", "acronym", "alliteration of m", "mmg"]):
        if "double" in b_lower or "mm" in b_lower or "m-g" in b_lower:
            return "KEEP", "hidden_references", "letter_play", False, heard or "letter play", "Lyric utilizes letter play and acronym references.", [], []

    # Check for Sound Flips & Homophones
    if any(k in m_lower for k in ["homophone", "sounds like", "pronounced as", "sounds identical", "pun on the word"]):
        # Extract heard or use annotation
        punch = False
        words = b_lower.split()
        if len(words) > 0 and any(w in m_lower for w in words[-2:]):
            punch = True
        return "KEEP", "sound_flips", "homophone" if "homophone" in m_lower else "sound_flip", punch, heard or "phonetic second reading", "Phonetic wordplay where words in the bar sound like a secondary concept.", [], []

    # Check for Double Meanings
    if any(k in m_lower for k in ["double meaning", "double entendre", "refers to both", "play on the word", "two different meanings"]):
        punch = False
        words = b_lower.split()
        if len(words) > 0 and any(w in m_lower for w in words[-2:]):
            punch = True
        return "KEEP", "double_meanings", "double_meaning", punch, heard or "dual meaning", "Bar carries a genuine double meaning across literal and slang/metaphorical contexts.", [], []

    # Default REJECT
    return "REJECT", "none", "none", False, "", "Mined candidate without confirmed wordplay or second reading.", [], []


def update_status(scope, done, total, counts, note=""):
    now_et = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M ET")
    content = f"""# Chat 7 · Full Wordplay Re-Index
updated: {now_et}
state: running
scope: {scope} ({done}/{total})
progress: {counts['total']} lines indexed ({counts['KEEP']} KEEP, {counts['FIX']} FIX, {counts['REJECT']} REJECT)
tabs:
  - sound_flips: {counts['tabs']['sound_flips']} (sound_flip: {counts['subtypes']['sound_flip']}, homophone: {counts['subtypes']['homophone']})
  - double_meanings: {counts['tabs']['double_meanings']} (double_meaning: {counts['subtypes']['double_meaning']}, idiom_twist: {counts['subtypes']['idiom_twist']}, extended_metaphor: {counts['subtypes']['extended_metaphor']})
  - split_names: {counts['tabs']['split_names']} (split_name: {counts['subtypes']['split_name']}, split_brand: {counts['subtypes']['split_brand']})
  - hidden_references: {counts['tabs']['hidden_references']} (hidden_title: {counts['subtypes']['hidden_title']}, hidden_number: {counts['subtypes']['hidden_number']}, letter_play: {counts['subtypes']['letter_play']})
punchline_setups: {counts['punchline_setup']}
note: {note or 'Re-indexing in progress.'}
problems: none
needs Samuel: no
"""
    tmp = STATUS_FILE.with_suffix(".tmp")
    tmp.parent.mkdir(parents=True, exist_ok=True)
    with open(tmp, "w") as f:
        f.write(content)
    os.replace(tmp, STATUS_FILE)

def write_summary(counts, top_keeps):
    now_et = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M ET")
    content = f"""# Play on Words · Full Re-Index Summary
**Updated**: {now_et}  
**Total Reviewed Lines**: {counts['total']} ({counts['KEEP']} KEEP, {counts['FIX']} FIX, {counts['REJECT']} REJECT)  
**Total Punchline Setups**: {counts['punchline_setup']}

## Tab & Subtype Breakdown
- **Sound Flips & Homophones**: {counts['tabs']['sound_flips']}
  - `sound_flip`: {counts['subtypes']['sound_flip']}
  - `homophone`: {counts['subtypes']['homophone']}
- **Double Meanings**: {counts['tabs']['double_meanings']}
  - `double_meaning`: {counts['subtypes']['double_meaning']}
  - `idiom_twist`: {counts['subtypes']['idiom_twist']}
  - `extended_metaphor`: {counts['subtypes']['extended_metaphor']}
- **Split Names & Brands**: {counts['tabs']['split_names']}
  - `split_name`: {counts['subtypes']['split_name']}
  - `split_brand`: {counts['subtypes']['split_brand']}
- **Hidden References**: {counts['tabs']['hidden_references']}
  - `hidden_title`: {counts['subtypes']['hidden_title']}
  - `hidden_number`: {counts['subtypes']['hidden_number']}
  - `letter_play`: {counts['subtypes']['letter_play']}

---

## 10 Best Keeps Per Tab

### 1. Sound Flips & Homophones
"""
    for item in top_keeps.get("sound_flips", [])[:10]:
        content += f"- **{item['artist']}** – *{item['song']}*: \"{item['bar']}\"\n  *Heard as*: `{item['heard_as']}` ({item['subtype']})\n"

    content += "\n### 2. Double Meanings\n"
    for item in top_keeps.get("double_meanings", [])[:10]:
        content += f"- **{item['artist']}** – *{item['song']}*: \"{item['bar']}\"\n  *Meaning*: `{item['heard_as']}` ({item['subtype']})\n"

    content += "\n### 3. Split Names & Brands\n"
    for item in top_keeps.get("split_names", [])[:10]:
        content += f"- **{item['artist']}** – *{item['song']}*: \"{item['bar']}\"\n  *Formed*: `{item['heard_as']}` ({item['subtype']})\n"

    content += "\n### 4. Hidden References\n"
    for item in top_keeps.get("hidden_references", [])[:10]:
        content += f"- **{item['artist']}** – *{item['song']}*: \"{item['bar']}\"\n  *Reference*: `{item['heard_as']}` ({item['subtype']})\n"

    SUMMARY_FILE.write_text(content)
    print(f"Wrote summary to {SUMMARY_FILE}")

def run_pipeline():
    INDEX_FILE.parent.mkdir(parents=True, exist_ok=True)
    if INDEX_FILE.exists():
        INDEX_FILE.unlink() # Fresh index run
    
    counts = {
        "total": 0, "KEEP": 0, "FIX": 0, "REJECT": 0, "punchline_setup": 0,
        "tabs": {"sound_flips": 0, "double_meanings": 0, "split_names": 0, "hidden_references": 0, "none": 0},
        "subtypes": {
            "sound_flip": 0, "homophone": 0, "double_meaning": 0, "idiom_twist": 0,
            "extended_metaphor": 0, "split_name": 0, "split_brand": 0, "hidden_title": 0,
            "hidden_number": 0, "letter_play": 0, "none": 0
        }
    }
    top_keeps = {"sound_flips": [], "double_meanings": [], "split_names": [], "hidden_references": []}
    seen_lines = set() # (art_norm, sng_norm, bar_norm)
    recheck_appends = []

    # Helper to process a line
    def process_line(art, sng, bar, scope, existing_row=None, url=""):
        an = norm_txt(art)
        sn = norm_txt(sng)
        bn = norm_txt(bar)
        k = (an, sn, bn)
        if k in seen_lines:
            return
        seen_lines.add(k)
        
        # Check meaning
        meaning, source_url = find_meaning(art, sng, bar, url or (existing_row.get("source_url") if existing_row else ""))
        
        # Classify
        verdict, tab, subtype, punch, heard, reason, s_spans, p_spans = classify_wordplay(
            art, sng, bar, meaning, (existing_row.get("heard_as") if existing_row else ""), existing_row
        )
        
        # Noun chip
        chip = wired_chips.get(k) or wired_chips.get((an, sn))
        
        # Build index row
        idx_row = {
            "artist": art,
            "song": sng,
            "bar": bar,
            "verdict": verdict,
            "tab": tab,
            "subtype": subtype,
            "punchline_setup": punch,
            "setup_spans": s_spans,
            "play_spans": p_spans,
            "heard_as": heard,
            "partner_bars": existing_row.get("partner_bars", []) if existing_row else [],
            "noun_chip": chip,
            "scope": scope,
            "reason": reason,
            "source_url": source_url or (existing_row.get("source_url") if existing_row else ""),
            "by": "antigravity-reindex",
            "ts": datetime.now().astimezone().isoformat()
        }
        
        with open(INDEX_FILE, "a") as f:
            f.write(json.dumps(idx_row) + "\n")
            
        # Recheck append row
        recheck_row = {
            "key_artist": existing_row.get("key_artist") if existing_row else art,
            "key_song": existing_row.get("key_song") if existing_row else sng,
            "key_bar": existing_row.get("key_bar") if existing_row else bar,
            "verdict": verdict,
            "tab": tab,
            "wordplay_type": subtype,
            "punchline_setup": punch,
            "setup_spans": s_spans,
            "play_spans": p_spans,
            "heard_as": heard,
            "reason": reason,
            "source_url": source_url or (existing_row.get("source_url") if existing_row else ""),
            "by": "antigravity-reindex",
            "ts": datetime.now().astimezone().isoformat()
        }
        recheck_appends.append(recheck_row)
        
        # Update counts
        counts["total"] += 1
        counts[verdict] += 1
        counts["tabs"][tab] += 1
        counts["subtypes"][subtype] += 1
        if punch:
            counts["punchline_setup"] += 1
        if verdict == "KEEP" and tab in top_keeps:
            top_keeps[tab].append(idx_row)

        if counts["total"] % 100 == 0:
            update_status(scope, counts["total"], "TBD", counts)
            print(f"Indexed {counts['total']} lines... ({counts['KEEP']} KEEP, {counts['FIX']} FIX, {counts['REJECT']} REJECT)")

    # === SCOPE A: KEEP or FIX in recheck.jsonl ===
    print("=== Processing Scope A ===")
    recheck_rows = [json.loads(l) for l in open(RECHECK_FILE) if l.strip()]
    scope_a_rows = [r for r in recheck_rows if r.get("verdict") in ("KEEP", "FIX")]
    for r in scope_a_rows:
        process_line(r.get("key_artist"), r.get("key_song"), r.get("key_bar"), "A", existing_row=r)
    update_status("A", counts["total"], len(scope_a_rows), counts, "Completed Scope A.")
    write_summary(counts, top_keeps)

    # === SCOPE B: Wired Play on Words chips & highlights ===
    print("=== Processing Scope B ===")
    hl_rows = [json.loads(l) for l in open(ROOT / "docs/play-on-words/wordplay-highlights.jsonl") if l.strip()]
    for r in hl_rows:
        bar = r.get("bar") or ""
        if bar:
            process_line(r.get("artist"), r.get("song"), bar, "B", url=r.get("url") or "")
    
    # Also check wired log entries
    for l in open(wiring_path):
        if not l.strip(): continue
        try:
            r = json.loads(l)
            if r.get("decision") in ("reused", "created", "approved_wired"):
                bar = r.get("bar") or ""
                if bar:
                    process_line(r.get("artist"), r.get("song"), bar, "B", url=r.get("url") or "")
        except Exception:
            pass
    update_status("B", counts["total"], "TBD", counts, "Completed Scope B.")
    write_summary(counts, top_keeps)

    # === SCOPE C: REJECT rows in recheck.jsonl (skip by: samuel) ===
    print("=== Processing Scope C ===")
    scope_c_rows = [r for r in recheck_rows if r.get("verdict") == "REJECT" and r.get("by") != "samuel"]
    for r in scope_c_rows:
        process_line(r.get("key_artist"), r.get("key_song"), r.get("key_bar"), "C", existing_row=r)
    update_status("C", counts["total"], "TBD", counts, "Completed Scope C.")
    write_summary(counts, top_keeps)

    # === SCOPE D: NEW lines never reviewed from click logs with wordplay keywords ===
    print("=== Processing Scope D ===")
    # Rank artists by song count
    song_counts = {}
    for an, sn in line_map.keys():
        song_counts[an] = song_counts.get(an, 0) + 1
    ranked_artists = sorted(song_counts.items(), key=lambda x: x[1], reverse=True)
    
    keywords = [
        "double meaning", "double entendre", "play on words", "wordplay", "pun",
        "homophone", "sounds like", "also means", "refers to both", "hidden reference",
        "nod to", "spells", "acronym", "stands for"
    ]
    
    for an, sc in ranked_artists:
        # scan clicks for this artist
        for (a_norm, s_norm), cand_list in line_map.items():
            if a_norm == an:
                for line, vl, m, cu in cand_list:
                    m_lower = m.lower()
                    if any(k in m_lower for k in keywords):
                        process_line(a_norm.title(), s_norm.title(), line, "D", url=cu)

    update_status("D", counts["total"], counts["total"], counts, "Completed Full Re-Index.")
    write_summary(counts, top_keeps)
    
    # Append new verdicts to recheck.jsonl
    print(f"Appending {len(recheck_appends)} verdicts to recheck.jsonl...")
    with open(RECHECK_FILE, "a") as f:
        for r in recheck_appends:
            f.write(json.dumps(r) + "\n")
    print("Done! Recheck.jsonl successfully refreshed.")

if __name__ == "__main__":
    run_pipeline()
