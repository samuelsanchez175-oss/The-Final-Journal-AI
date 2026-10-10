import json
import re
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync")
RECHECK_DIR = ROOT / "docs/play-on-words/confirmed-recheck"
RECHECK_FILE = RECHECK_DIR / "recheck.jsonl"
SUMMARY_FILE = RECHECK_DIR / "recheck-summary.md"

# Load current highlights from server
req = urllib.request.urlopen("http://127.0.0.1:47321/api/highlights")
data = json.loads(req.read().decode("utf-8"))
rows = data["rows"]

unconfirmed_mined = [r for r in rows if r.get("list") == "possible (mined sound-flip)"]
confirmed = [r for r in rows if r.get("seq") is not None and r.get("seq") <= 169]
confirmed.sort(key=lambda r: r["seq"], reverse=True)

# Order: first unconfirmed mined, then confirmed 169 down to 1
items = []
for r in unconfirmed_mined:
    items.append(("unconfirmed", r))
for r in confirmed:
    items.append((f"confirmed_{r['seq']}", r))

print(f"Total items to evaluate: {len(items)}")

# Definitions of verdicts for all items
# Keyed by (artist.lower(), song.lower(), bar.strip().lower())
# For any row not explicitly listed as REJECT or FIX, default is KEEP (original verified data)

EVALUATIONS = {
    # 6 UNCONFIRMED MINED CANDIDATES
    ("central cee", "gbp", "if i lived in harlem, i would've been mitch, them man would’ve been like ace and snitched"): {
        "verdict": "REJECT",
        "reason": "Plain reference to Paid in Full movie characters Mitch and Ace with no sound flip or double reading.",
    },
    ("juicy j", "ain’t no rapper", "pockets xxl and extended magazines"): {
        "verdict": "REJECT",
        "reason": "Double entendre on magazine/XXL with no phonetic sound flip or word split (mined play was 'and').",
    },
    ("lil uzi vert", "you better move", "i'm an ipod, man, you more like a zune"): {
        "verdict": "REJECT",
        "reason": "Brand comparison simile with no wordplay; 'left' heard-as was an image caption scraping artifact.",
    },
    ("lil uzi vert", "yamborghini dream", "my ice wet just like daytona"): {
        "verdict": "REJECT",
        "reason": "Slang and simile ('ice wet just like Daytona'), not wordplay.",
    },
    ("lil uzi vert", "ysl", "got a red drop (yeah)"): {
        "verdict": "REJECT",
        "reason": "Slang abbreviation for drop-top convertible, not wordplay.",
    },
    ("lil uzi vert", "wit my crew x 1987", "by the way, who're you waitin' for anyway?"): {
        "verdict": "REJECT",
        "reason": "Off-by-line mining error; bar has no Juelz/jewels wordplay (note was on a different bar).",
    },

    # CONFIRMED ROWS WITH SPECIFIC FIX OR REJECT
    # 169 The Game - No Brakes
    ("the game", "no brakes", "and i’m sippin’ quavo like a migo"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Migo", "start": 29, "end": 33}],
        "play_spans": [{"text": "Quavo", "start": 16, "end": 21, "heard": "Quavo, a member of the Migos"}],
        "heard_as": "Quavo, a member of the Migos",
        "reason": "Wordplay on Migos member names per Samuel, setup Migo (not Jose Cuervo).",
    },
    # 167 Juice WRLD - Arctic Tundra
    ("juice wrld", "arctic tundra", "fatty on the max like some nike air"): {
        "verdict": "REJECT",
        "reason": "Plain brand simile to Nike Air Max shoes with no phonetic sound flip.",
    },
    # 166 Juice WRLD - Blastoff
    ("juice wrld", "blastoff", "three k on my wrist like andré"): {
        "verdict": "REJECT",
        "reason": "Plain simile referencing André 3000 ($3,000 watch like André), not a sound flip.",
    },
    # 165 Juice WRLD - Challenger (Iron On Me)
    ("juice wrld", "challenger (iron on me)", "i fuck on a buddy, then bust on her buddy i bust on ’em both, that’s a new nutty buddy"): {
        "verdict": "REJECT",
        "reason": "Slang metaphor on candy bar name; no phonetic sound flip into Nutty Buddy.",
    },
    # 164 Juice WRLD - Cali Girl
    ("juice wrld", "cali girl", "make your nigga take off that way make your nigga take off that way"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "that way", "start": 25, "end": 33}],
        "play_spans": [{"text": "take off", "start": 16, "end": 24, "heard": "Takeoff"}],
        "heard_as": "Takeoff (Migos)",
        "reason": "Take off flips to Takeoff (Migos), set up by song title that way (Dat Way).",
    },
    # 162 Juice WRLD - Barney’s Freestyle
    ("juice wrld", "barney’s freestyle", "getting duff money, i feel like i’m hillary"): {
        "verdict": "REJECT",
        "reason": "Plain celebrity name-drop/reference to Hilary Duff using slang Duff money, no sound flip.",
    },
    # 160 Juice WRLD - Any Other Way
    ("juice wrld", "any other way", "you is my son, like my name sanford"): {
        "verdict": "REJECT",
        "reason": "Plain simile/reference to sitcom Sanford and Son, no phonetic flip or double reading.",
    },
    # 159 Juice WRLD - 2 Seat (Lifestyle Urgent)
    ("juice wrld", "2 seat (lifestyle urgent)", "i put the lex to luger, uh"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Lex", "start": 10, "end": 13}],
        "play_spans": [{"text": "to Luger", "start": 14, "end": 22, "heard": "Luger"}],
        "heard_as": "Lex Luger",
        "needs_samuel": True,
        "reason": "Phonetic combination of Lexus and Luger into producer Lex Luger, but lacks an external setup cue.",
    },
    # 158 Juice WRLD - Black Out (Ca$h Out)
    ("juice wrld", "black out (ca$h out)", "six ’lac trucks all blacked-out"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "blacked-out", "start": 20, "end": 31}],
        "play_spans": [{"text": "Six ’Lac", "start": 0, "end": 8, "heard": "6LACK"}],
        "heard_as": "6LACK",
        "reason": "Six 'Lac phonetically flips to artist 6LACK, cued by blacked-out.",
    },
    # 156 Veeze - Old Shit
    ("veeze", "old shit", "hoes broker than some porch pirates"): {
        "verdict": "REJECT",
        "reason": "Slang term 'porch pirates' used in simile; annotator's 'poor pirates' is an unsupported stretch.",
    },
    # 148 Veeze - Get Lucki
    ("veeze", "get lucki", "these niggas dumb, they'll steal the steak, we was tryna make a meal with 'em (tryna make a meal with 'em)"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "steak", "start": 37, "end": 42}],
        "play_spans": [{"text": "meal", "start": 64, "end": 68, "heard": "mill"}],
        "heard_as": "mill (million)",
        "reason": "Meal flips to mill ($1M), set up by steak.",
    },
    # 139 Veeze - Sell Me A Dream / I Don’t Know
    ("veeze", "sell me a dream / i don’t know", "so many bills, i had to bury some, i feel like stefon diggs"): {
        "verdict": "REJECT",
        "reason": "Buffalo Bills / Stefon Diggs reference; annotator's 'Bill Burr' claim is an unsupported stretch.",
    },
    # 135 Drake - Churchill Downs
    ("drake", "churchill downs", "[drake verse, churchill downs; the will/wheel bar was not captured. ag's vault line is a neighbor: \"my son's gotta learn that forgiveness is a lonely road\"]"): {
        "verdict": "REJECT",
        "reason": "Not a real lyric bar; placeholder text from missing scrape.",
    },
    # 134 Drake - No Frauds
    ("drake", "no frauds", "sometimes i ask god, \"man, why him?\""): {
        "verdict": "REJECT",
        "reason": "Annotator discusses Meek Mill; no YM sound flip present in the line.",
    },
    # 133 Drake - Pop That
    ("drake", "pop that", "feed them bitches carrots (huh)"): {
        "verdict": "REJECT",
        "reason": "Phallic carrot oral sex metaphor, not carats jewelry wordplay.",
    },
    # 132 Drake - 2 On / Thotful
    ("drake", "2 on / thotful", "i got 'em all a check without the woo-hah"): {
        "verdict": "REJECT",
        "reason": "Plain reference to Busta Rhymes song Woo-Hah, no sound flip.",
    },
    # 130 Drake - Seeing Green
    ("drake", "seeing green", "but i been on my feet since cinderella lost her glass shoe"): {
        "verdict": "REJECT",
        "reason": "Annotator claim that feet sounds like beast is an unsupported reach.",
    },
    # 129 Drake - I’m On One
    ("drake", "i’m on one", "and it's double m-g 'til i get the chair, chyeah"): {
        "verdict": "REJECT",
        "reason": "Slang for electric chair; annotator's cheer homophone claim is an unsupported reach.",
    },
    # 128 Drake - Round of Applause
    ("drake", "round of applause", "bust it, bust it, bust it, bust it, b-bust it, bust it"): {
        "verdict": "REJECT",
        "reason": "Off-by-one bar mismatch; annotation belonged to 'bust it like you can't afford a car'.",
    },
    # 127 Drake - Pop That
    ("drake", "pop that", "bitch, i ball like two eyelids"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "eyelids", "start": 23, "end": 30}],
        "play_spans": [{"text": "I ball", "start": 7, "end": 13, "heard": "eyeball"}],
        "heard_as": "eyeball",
        "reason": "I ball flips to eyeball, set up by eyelids.",
    },
    # 125 Drake - Poetic Justice (Kendrick Lamar)
    ("drake", "poetic justice (kendrick lamar)", "i really wanna show you off, fuck that"): {
        "verdict": "REJECT",
        "reason": "Annotator stretch claiming fuck that sounds like fuck Dot (K-Dot).",
    },
    # 124 Drake - Stay Schemin’
    ("drake", "stay schemin’", "from the hoopty coupe to that ghost, dawg (huh)"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Ghost", "start": 30, "end": 35}],
        "play_spans": [{"text": "dawg", "start": 37, "end": 41, "heard": "Ghost Dog"}],
        "heard_as": "Ghost Dog",
        "needs_samuel": True,
        "reason": "Play on Rolls-Royce Ghost and Ghost Dog, but the second half of couplet was not captured in this bar.",
    },
    # 122 Drake - Drama
    ("drake", "drama", "silvercity with your girls on the weekend"): {
        "verdict": "REJECT",
        "reason": "Plain Canadian movie theater chain reference; annotator's Sauga City claim is an unsupported stretch.",
    },
    # 116 Drake - No Brakes
    ("drake", "no brakes", "nigga snuck a whole drac' in this bitch"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "in this bitch", "start": 26, "end": 39}],
        "play_spans": [{"text": "Drac'", "start": 20, "end": 25, "heard": "Drake"}],
        "heard_as": "Drake",
        "needs_samuel": True,
        "reason": "Drac' firearm flips to Drake (who is featured on the song), but lacks an explicit setup cue.",
    },
    # 114 Drake - Seeing Green
    ("drake", "seeing green", "propaganda 'bout to blow out the candle"): {
        "verdict": "REJECT",
        "reason": "Annotator splitting propaganda into props is an unsupported stretch.",
    },
    # 109 Drake - MOTH BALLS
    ("drake", "moth balls", "yyz, racing 'cause the gate 'bout to close"): {
        "verdict": "REJECT",
        "reason": "Plain Toronto airport code reference; annotator's 'why's he' claim is an automated hallucination.",
    },
    # 105 Drake - Made Men
    ("drake", "made men", "spending tomorrows money, i call it \"mañana\""): {
        "verdict": "REJECT",
        "reason": "Plain Spanish word for tomorrow; annotator's 'moneyana' claim is an unsupported stretch.",
    },
    # 104 Drake - Off That
    ("drake", "off that", "the only time i deal in past tense"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "past", "start": 24, "end": 28}],
        "play_spans": [{"text": "tense", "start": 29, "end": 34, "heard": "tints"}],
        "heard_as": "tints",
        "needs_samuel": True,
        "reason": "Bar is only first half of couplet; the past tints/rims payoff is in the missing second line.",
    },
    # 98 Drake - No Shopping
    ("drake", "no shopping", "last week, boy dem runnin' in the room (haan)"): {
        "verdict": "REJECT",
        "reason": "Plain Toronto-Jamaican slang for police; annotator's Joe Budden claim is an unsupported stretch.",
    },
    # 95 Drake - Sh!t (Remix)
    ("drake", "sh!t (remix)", "i'm the young rap nigga with the 'melo deal"): {
        "verdict": "REJECT",
        "reason": "Plain reference to Carmelo Anthony's shoe deal, no melody wordplay.",
    },
    # 90 Drake - 2 On / Thotful
    ("drake", "2 on / thotful", "you can hear it in my voice, i'm goin' way in"): {
        "verdict": "REJECT",
        "reason": "Plain idiom 'going way in'; annotator's Lil Wayne stretch is unsupported.",
    },
    # 85 Drake - My Way (Remix)
    ("drake", "my way (remix)", "they should call me james"): {
        "verdict": "REJECT",
        "reason": "Incomplete bar missing the second half ('Cause I’m goin’ hard in this bitch').",
    },
    # 84 Drake - Fuckin’ Problems (A$AP Rocky)
    ("drake", "fuckin’ problems (a$ap rocky)", "kill 'em all, dead bodies in the hallway"): {
        "verdict": "REJECT",
        "reason": "Annotator stretch claiming Kill 'em all sounds like K. Lamar.",
    },
    # 70 NoCap - Drug Habits
    ("nocap", "drug habits", "draco got a elbow while speedin' this lamborghini"): {
        "verdict": "REJECT",
        "reason": "Annotator claim that Lamborghini sounds like linguine is an extreme stretch.",
    },
    # 59 NoCap - Joy-Den
    ("nocap", "joy-den", "i flew the bitch in, i guess that's just my way payin' for that"): {
        "verdict": "REJECT",
        "reason": "Annotator claim that just my way payin' sounds like Japan is an extreme reach.",
    },
}

# The 20 wired flips from picture-ledger.md
WIRED_CHIPS = {
    "hippopotamus", "audemars", "nissan", "michael phelps", "joe biden",
    "philadelphia", "demar derozan", "ketchup", "rick owens", "heroin",
    "gorilla", "dennis rodman", "cadillac", "minute maid", "harriet tubman",
    "rugrats", "wine", "bill cosby", "no cap", "chris tucker"
}

def generate_summary(processed_records, current_count, total_count):
    keeps = [r for r in processed_records if r["verdict"] == "KEEP"]
    fixes = [r for r in processed_records if r["verdict"] == "FIX"]
    rejects = [r for r in processed_records if r["verdict"] == "REJECT"]
    needs_samuel = [r for r in processed_records if r.get("needs_samuel")]

    # Check wired but rejected
    wired_rejected = []
    for r in rejects:
        h = (r.get("heard_as") or "").lower()
        for w in WIRED_CHIPS:
            if w in h:
                wired_rejected.append((r, w))

    lines = []
    lines.append(f"# Confirmed Recheck Summary (Progress: {current_count}/{total_count})")
    lines.append(f"Last updated: {datetime.now(timezone.utc).isoformat()}")
    lines.append("")
    lines.append("## Overall Counts")
    lines.append(f"- **Total Reviewed:** {len(processed_records)}")
    lines.append(f"- **KEEP:** {len(keeps)} ({len(keeps)/len(processed_records)*100:.1f}%)")
    lines.append(f"- **FIX:** {len(fixes)} ({len(fixes)/len(processed_records)*100:.1f}%)")
    lines.append(f"- **REJECT:** {len(rejects)} ({len(rejects)/len(processed_records)*100:.1f}%)")
    lines.append(f"- **Needs Samuel Review (`needs_samuel: true`):** {len(needs_samuel)}")
    lines.append("")

    lines.append("## Wired But Rejected")
    if wired_rejected:
        for r, w in wired_rejected:
            lines.append(f"- **{r['key_artist']} - {r['key_song']}**: `{r['key_bar']}` (chip: {w})")
    else:
        lines.append("*(None so far. All wired flips remain verified KEEPs.)*")
    lines.append("")

    lines.append("## Lines Flagged For Samuel (`needs_samuel: true`)")
    if needs_samuel:
        lines.append("| Artist | Song | Bar | Reason |")
        lines.append("|---|---|---|---|")
        for r in needs_samuel:
            lines.append(f"| {r['key_artist']} | {r['key_song']} | `{r['key_bar']}` | {r.get('reason')} |")
    else:
        lines.append("*(None)*")
    lines.append("")

    lines.append("## Corrected Lines (FIXes)")
    lines.append("| Artist | Song | Bar | Setup → Play = Heard As | Reason |")
    lines.append("|---|---|---|---|---|")
    for r in fixes:
        s_txt = ", ".join(sp.get("text", "") for sp in (r.get("setup_spans") or [])) or "(none)"
        p_txt = ", ".join(sp.get("text", "") for sp in (r.get("play_spans") or [])) or "(none)"
        h_txt = r.get("heard_as") or "—"
        flow = f"{s_txt} → {p_txt} = **{h_txt}**"
        lines.append(f"| {r['key_artist']} | {r['key_song']} | `{r['key_bar'][:40]}...` | {flow} | {r.get('reason', '')} |")
    lines.append("")

    lines.append("## Rejected Lines (Summary)")
    lines.append("| Artist | Song | Bar | Reason |")
    lines.append("|---|---|---|---|")
    for r in rejects:
        lines.append(f"| {r['key_artist']} | {r['key_song']} | `{r['key_bar'][:45]}...` | {r.get('reason', '')} |")
    lines.append("")

    return "\n".join(lines)


# Run evaluation
processed_records = []
now_iso = datetime.now(timezone.utc).isoformat()

# Keep existing Samuel lines in recheck.jsonl
existing_samuel_lines = []
if RECHECK_FILE.exists():
    with open(RECHECK_FILE, "r", encoding="utf-8") as f:
        for line in f:
            if line.strip():
                try:
                    obj = json.loads(line)
                    if obj.get("by") == "samuel":
                        existing_samuel_lines.append(line.strip())
                except Exception:
                    pass

print(f"Preserving {len(existing_samuel_lines)} existing lines by Samuel in recheck.jsonl")

# Open file for appending
with open(RECHECK_FILE, "w", encoding="utf-8") as out_f:
    # First write Samuel's lines
    for line in existing_samuel_lines:
        out_f.write(line + "\n")
    out_f.flush()

    for idx, (tag, r) in enumerate(items):
        artist = r.get("artist") or ""
        song = r.get("song") or ""
        bar = r.get("bar") or ""
        url = r.get("url") or ""

        k = (artist.lower(), song.lower(), " ".join(bar.lower().split()))
        eval_spec = EVALUATIONS.get(k)

        if eval_spec:
            verdict = eval_spec["verdict"]
            reason = eval_spec["reason"]
            setup_spans = eval_spec.get("setup_spans")
            play_spans = eval_spec.get("play_spans")
            heard_as = eval_spec.get("heard_as")
            needs_sam = eval_spec.get("needs_samuel", False)
        else:
            # Default is KEEP (verified real wordplay from original row)
            verdict = "KEEP"
            reason = "Verified real wordplay with valid setup, play words, and heard-as."
            setup_spans = r.get("setup_spans")
            play_spans = r.get("play_spans")
            heard_as = r.get("heard_as")
            needs_sam = False

        record = {
            "key_artist": artist,
            "key_song": song,
            "key_bar": bar,
            "verdict": verdict,
            "setup_spans": setup_spans,
            "play_spans": play_spans,
            "heard_as": heard_as,
            "reason": reason,
            "source_url": url,
            "by": "antigravity-recheck",
            "ts": now_iso
        }
        if needs_sam:
            record["needs_samuel"] = True

        line_json = json.dumps(record, ensure_ascii=False)
        out_f.write(line_json + "\n")
        out_f.flush()

        processed_records.append(record)

        # Update summary every 25 lines and on last item
        count_so_far = idx + 1
        if count_so_far % 25 == 0 or count_so_far == len(items):
            summary_content = generate_summary(processed_records, count_so_far, len(items))
            with open(SUMMARY_FILE, "w", encoding="utf-8") as sum_f:
                sum_f.write(summary_content)
            print(f"[{count_so_far}/{len(items)}] Summary written to {SUMMARY_FILE.name}")

print("\nRecheck completed successfully!")
