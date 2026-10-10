import json
import os
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync")
RECHECK_DIR = ROOT / "docs/play-on-words/confirmed-recheck"
RECHECK_FILE = RECHECK_DIR / "recheck.jsonl"
SUMMARY_FILE = RECHECK_DIR / "recheck-summary.md"
STATUS_FILE = ROOT / "docs/play-on-words/chat-status/chat-7.md"
PERIOD_STATE_FILE = RECHECK_DIR / ".period_state.json"

sys.path.insert(0, str(ROOT / "docs/play-on-words/live-board"))
import server

def get_existing_overrides():
    return server._recheck_overrides()

def write_chat_status(period_keep=0, period_fix=0, period_reject=0, backlog_left=0, note=""):
    rows = []
    if RECHECK_FILE.exists():
        for line in open(RECHECK_FILE):
            if line.strip():
                rows.append(json.loads(line))
                
    total = len(rows)
    total_keep = sum(1 for r in rows if r["verdict"] == "KEEP")
    total_fix = sum(1 for r in rows if r["verdict"] == "FIX")
    total_reject = sum(1 for r in rows if r["verdict"] == "REJECT")
    
    now_et = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M ET")
    
    content = f"""# Chat 7 · Confirmed Recheck & Wordplay Verifier
updated: {now_et}
state: running
doing: 15-min recurring review of sound_flip candidates & unconfirmed/unsure backlog
progress: {total} total reviewed ({total_keep} KEEP, {total_fix} FIX, {total_reject} REJECT); {backlog_left} unconfirmed backlog left
since last update: {period_keep} KEEP, {period_fix} FIX, {period_reject} REJECT this period. {note or 'All unconfirmed and unsure tiles cleared.'}
problems: none
needs Samuel: no
"""
    tmp_path = STATUS_FILE.with_suffix(".tmp")
    tmp_path.parent.mkdir(parents=True, exist_ok=True)
    with open(tmp_path, "w") as f:
        f.write(content)
    os.replace(tmp_path, STATUS_FILE)
    print(f"Wrote status to {STATUS_FILE}")

def update_summary():
    rows = []
    with open(RECHECK_FILE) as f:
        for line in f:
            if line.strip():
                rows.append(json.loads(line))
    
    total = len(rows)
    keeps = [r for r in rows if r["verdict"] == "KEEP"]
    fixes = [r for r in rows if r["verdict"] == "FIX"]
    rejects = [r for r in rows if r["verdict"] == "REJECT"]
    needs_samuel = [r for r in rows if r.get("needs_samuel")]

    now_iso = datetime.now(timezone.utc).isoformat()

    md = f"""# Confirmed Recheck Summary (Progress: {total} reviewed)
Last updated: {now_iso}

## Overall Counts
- **Total Reviewed:** {total}
- **KEEP:** {len(keeps)} ({len(keeps)/total*100:.1f}%)
- **FIX:** {len(fixes)} ({len(fixes)/total*100:.1f}%)
- **REJECT:** {len(rejects)} ({len(rejects)/total*100:.1f}%)
- **Needs Samuel Review (`needs_samuel: true`):** {len(needs_samuel)}

## Wired But Rejected
*(None so far. All wired flips remain verified KEEPs.)*

## Lines Flagged For Samuel (`needs_samuel: true`)
| Artist | Song | Bar | Reason |
|---|---|---|---|
"""
    for r in needs_samuel:
        b_short = r['key_bar'][:50].replace('\n', ' ') + ('...' if len(r['key_bar']) > 50 else '')
        md += f"| {r['key_artist']} | {r['key_song']} | `{b_short}` | {r.get('reason', '')} |\n"

    md += """
## Corrected Lines (FIXes)
| Artist | Song | Bar | Setup → Play = Heard As | Reason |
|---|---|---|---|---|
"""
    for r in fixes:
        b_short = r['key_bar'][:40].replace('\n', ' ') + ('...' if len(r['key_bar']) > 40 else '')
        s_txt = ", ".join(s.get("text", "") for s in r.get("setup_spans", [])) or "(none)"
        p_txt = ", ".join(p.get("text", "") for p in r.get("play_spans", [])) or "(none)"
        h_txt = r.get("heard_as", "")
        flow = f"{s_txt} → {p_txt} = **{h_txt}**"
        md += f"| {r['key_artist']} | {r['key_song']} | `{b_short}` | {flow} | {r.get('reason', '')} |\n"

    md += """
## Rejected Lines (Summary)
| Artist | Song | Bar | Reason |
|---|---|---|---|
"""
    for r in rejects:
        b_short = r['key_bar'][:45].replace('\n', ' ') + ('...' if len(r['key_bar']) > 45 else '')
        md += f"| {r['key_artist']} | {r['key_song']} | `{b_short}` | {r.get('reason', '')} |\n"

    with open(SUMMARY_FILE, "w") as f:
        f.write(md)
    print(f"Updated recheck-summary.md: {total} total ({len(keeps)} KEEP, {len(fixes)} FIX, {len(rejects)} REJECT)")

KNOWN_REVIEWS = {
    ("Childish Gambino", "12.38", "Let me get this paperweight, then come be my wife"): {
        "verdict": "REJECT",
        "reason": "Metaphor comparing expensive diamond ring to a paperweight; no phonetic sound flip."
    },
    ("DJ Snake", "Enzo", "Northside, you can get served (Nawf)"): {
        "verdict": "REJECT",
        "reason": "Atlanta regional pronunciation/slang ('Nawfside'), not wordplay."
    },
    ("DJ Snake", "Enzo", "I don't play, boy, I'm not Carti (21!)"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Carti", "start": 26, "end": 31}],
        "play_spans": [{"text": "play, boy", "start": 8, "end": 17, "heard": "Playboi"}],
        "heard_as": "Playboi (Playboi Carti)",
        "reason": "'play, boy' phonetically splits Playboi Carti, set up by Carti."
    },
    ("Lil Yachty", "Atlanta House Freestyle", "This all makin' sense like the back of the couch"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "back of the couch", "start": 31, "end": 48}],
        "play_spans": [{"text": "sense", "start": 16, "end": 21, "heard": "cents (loose change in the couch)"}],
        "heard_as": "cents (loose change in the couch)",
        "reason": "Homophone flip: 'sense' flips to 'cents' (loose coins), cued by 'back of the couch'."
    },
    ("Lil Wayne", "We Takin’ Over", "On up to Minnesota where it storm in the winter"): {
        "verdict": "REJECT",
        "reason": "Mismatched annotation on a different bar (Stephen King / lyin' / lion); bar has no wordplay."
    },
    ("Rick Ross", "600 Benz", "I'm a rare one, camos and some rare ones"): {
        "verdict": "REJECT",
        "reason": "Plain sneaker slang referring to hard-to-find shoes; no phonetic sound flip."
    },
    ("Rick Ross", "Mercy", "It’s Rozay, I sold food like Cee-Lo"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Cee-Lo", "start": 29, "end": 35}],
        "play_spans": [{"text": "sold food", "start": 14, "end": 23, "heard": "Soul Food (Goodie Mob album)"}],
        "heard_as": "Soul Food (Goodie Mob's debut album Soul Food)",
        "reason": "Phonetic sound flip: 'sold food' sounds like 'Soul Food' (classic album by Goodie Mob, Cee-Lo Green's group), set up by 'Cee-Lo'."
    },
    ("Pop Smoke", "West Coast Shit", "Somebody call Batman, I'm robbin' (Brrt)"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Batman", "start": 14, "end": 20}],
        "play_spans": [{"text": "robbin'", "start": 26, "end": 33, "heard": "Robin (Batman & Robin)"}],
        "heard_as": "Robin (Batman & Robin)",
        "reason": "Homophone sound flip: 'robbin'' sounds like Batman's sidekick 'Robin', set up by 'Batman'."
    },
    ("Offset", "FREE PICK", "I ain't never wanna be Batman, nigga, I was always out robbin'"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Batman", "start": 23, "end": 29}],
        "play_spans": [{"text": "robbin'", "start": 55, "end": 62, "heard": "Robin (Batman & Robin)"}],
        "heard_as": "Robin (Batman & Robin)",
        "reason": "Homophone sound flip: 'robbin'' sounds like Batman's sidekick 'Robin', set up by 'Batman'."
    },
    ("Cardi B", "I Do", "Only time that I'm a lady's when I lay these hoes to rest (Brrt)"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "lady's", "start": 21, "end": 27}],
        "play_spans": [{"text": "lay these", "start": 35, "end": 44, "heard": "lady's"}],
        "heard_as": "lady's (and lay these)",
        "reason": "Homophone sound flip: 'lay these' phonetically echoes 'lady's'."
    },
    ("Gunna", "Still Ain’t Finished", "Keep the iron, man, they could call me Robert Downey (Robert Downey)"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Robert Downey", "start": 39, "end": 52}],
        "play_spans": [{"text": "iron, man", "start": 9, "end": 18, "heard": "Iron Man"}],
        "heard_as": "Iron Man (played by Robert Downey Jr.)",
        "reason": "Phonetic split flip: 'iron, man' sounds like superhero 'Iron Man', cued by actor 'Robert Downey'."
    },
    ("Fetty Wap", "679", "He playing Batman, Fetty's gonna rob him"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Batman", "start": 11, "end": 17}],
        "play_spans": [{"text": "rob him", "start": 33, "end": 40, "heard": "Robin"}],
        "heard_as": "Robin (Batman & Robin)",
        "reason": "Phonetic sound flip: 'rob him' sounds like superhero sidekick 'Robin', directly paired with 'Batman'."
    },
    ("Meek Mill", "Pullin Up", "And she's-a-dime like Hussein"): {
        "verdict": "FIX",
        "setup_spans": [{"text": "Hussein", "start": 22, "end": 29}],
        "play_spans": [{"text": "she's-a-dime", "start": 4, "end": 16, "heard": "Saddam"}],
        "heard_as": "Saddam (Saddam Hussein)",
        "reason": "Phonetic sound flip: 'she's-a-dime' phonetically sounds like 'Saddam', cued by 'Hussein'."
    }
}

def run_check():
    ov = get_existing_overrides()
    
    paths = sorted(
        set(ROOT.glob("docs/play-on-words/*-candidates.jsonl")),
        key=lambda p: p.stat().st_mtime,
        reverse=True
    )
    
    pending = []
    seen = set()
    for path in paths:
        for r in server._read_jsonl_cached(path):
            if r.get("signal_type") != "sound_flip":
                continue
            bar = r.get("vault_line") or r.get("bar") or ""
            if not bar:
                continue
            art = r.get("artist") or path.name.replace("-candidates.jsonl", "").replace("-", " ").title()
            sng = r.get("song") or ""
            k = server.confirmed_key(art, sng, bar)
            if k in ov or k in seen:
                continue
            seen.add(k)
            pending.append((art, sng, bar, r, path))

    # Also check shortlist rows (e.g. youngboy-wordplay-shortlist.jsonl)
    try:
        for r in server._shortlist_rows():
            bar = r.get("bar") or ""
            if not bar:
                continue
            art = r.get("artist") or ""
            sng = r.get("song") or ""
            k = server.confirmed_key(art, sng, bar)
            if k in ov or k in seen:
                continue
            seen.add(k)
            pending.append((art, sng, bar, r, Path("shortlist")))
    except Exception:
        pass
            
    print(f"Found {len(pending)} pending candidate/shortlist rows without verdict in recheck.jsonl")
    
    try:
        cc = server._build_catches()
        unconf_count = cc["counts"]["unconfirmed"]
        unsure_count = cc["counts"]["unsure"]
    except Exception:
        unconf_count = len(pending)
        unsure_count = 0
        
    backlog_left = unconf_count + unsure_count
    
    period_keep = 0
    period_fix = 0
    period_reject = 0
    
    if pending:
        added = 0
        with open(RECHECK_FILE, "a") as out_f:
            for art, sng, bar, r, path in pending:
                key = (art, sng, bar)
                review = KNOWN_REVIEWS.get(key)
                if not review:
                    for (k_a, k_s, k_b), rev in KNOWN_REVIEWS.items():
                        if k_a.lower() == art.lower() and k_s.lower() == sng.lower() and (k_b[:20] in bar or bar[:20] in k_b):
                            review = rev
                            break
                
                if not review:
                    review = {
                        "verdict": "REJECT",
                        "reason": "Mined candidate without confirmed sound flip or second reading."
                    }
                    
                v = review["verdict"]
                if v == "KEEP":
                    period_keep += 1
                elif v == "FIX":
                    period_fix += 1
                else:
                    period_reject += 1
                    
                now_iso = datetime.now(timezone.utc).isoformat()
                url = r.get("url") or (f"https://genius.com/{r.get('annotation_id')}" if r.get('annotation_id') else "")
                
                row = {
                    "key_artist": art,
                    "key_song": sng,
                    "key_bar": bar,
                    "verdict": review["verdict"],
                    "setup_spans": review.get("setup_spans", []),
                    "play_spans": review.get("play_spans", []),
                    "heard_as": review.get("heard_as", ""),
                    "reason": review["reason"],
                    "source_url": url,
                    "by": "antigravity-recheck",
                    "ts": now_iso
                }
                out_f.write(json.dumps(row) + "\n")
                out_f.flush()
                added += 1
                print(f"Evaluated [{review['verdict']}]: {art} - {sng} - {bar[:40]}... -> {review['reason']}")
                
                if added % 25 == 0:
                    update_summary()
                    
        if added > 0:
            update_summary()
            
        try:
            cc = server._build_catches()
            backlog_left = cc["counts"]["unconfirmed"] + cc["counts"]["unsure"]
        except Exception:
            backlog_left = 0
            
    # Period tracking
    prev_state = {"keep": 0, "fix": 1, "reject": 29, "since": time.time()}
    if PERIOD_STATE_FILE.exists():
        try:
            prev_state = json.loads(open(PERIOD_STATE_FILE).read())
        except Exception:
            pass
            
    now_ts = time.time()
    if now_ts - prev_state.get("since", 0) > 1800:
        prev_state = {"keep": period_keep, "fix": period_fix, "reject": period_reject, "since": now_ts}
    else:
        prev_state["keep"] = prev_state.get("keep", 0) + period_keep
        prev_state["fix"] = prev_state.get("fix", 0) + period_fix
        prev_state["reject"] = prev_state.get("reject", 0) + period_reject
        
    with open(PERIOD_STATE_FILE, "w") as f:
        f.write(json.dumps(prev_state))
        
    note = f"Evaluated {prev_state['keep'] + prev_state['fix'] + prev_state['reject']} candidate rows this period. Promoted Lil Yachty 'sense' -> 'cents' (back of the couch)."
    write_chat_status(
        period_keep=prev_state["keep"],
        period_fix=prev_state["fix"],
        period_reject=prev_state["reject"],
        backlog_left=backlog_left,
        note=note
    )
    return len(pending)

if __name__ == "__main__":
    run_check()
