#!/usr/bin/env python3
"""Build notes-queue.jsonl + summary from Genius community notes in genius-clicks/*.jsonl.
Read-only on all inputs; writes only into this folder. No network calls."""
import json, glob, re, os, time, collections, unicodedata

T0 = time.time()
HERE = os.path.dirname(os.path.abspath(__file__))
POW = os.path.dirname(HERE)
OUT = os.path.join(HERE, "notes-queue.jsonl")
SUM = os.path.join(HERE, "notes-queue-summary.md")

def norm(s):
    s = unicodedata.normalize("NFKC", s or "").replace("\u200b", "").replace("\u200e", "")
    s = s.replace("\u2019", "'").replace("\u2018", "'").replace("\u201c", '"').replace("\u201d", '"')
    return re.sub(r"\s+", " ", s).strip().casefold()

def R(p): return re.compile(p, re.I | re.S)

# (label, regex, weight)  weight 3 = specific, 1 = generic
SIG = {
 "sound_flips": [
  ("sounds like", R(r"\bsounds? like\b"), 3), ("homophone", R(r"\bhomophon"), 3),
  ("soundalike", R(r"\bsound-?alike"), 3), ("pronounced", R(r"\bpronounc"), 3),
  ("heard as", R(r"\bheard as\b"), 3), ("rhymes with … and", R(r"\brhymes? with\b.{0,80}?\band\b"), 2),
  ("play on the sound", R(r"\bplay on the sound"), 3)],
 "double_meanings": [
  ("double meaning", R(r"\bdouble[- ]meaning"), 3), ("double entendre", R(r"\bdouble[- ]entendre"), 3),
  ("two meanings", R(r"\btwo meanings\b"), 3), ("both", R(r"\bboth\b"), 1),
  ("also means", R(r"\balso means?\b"), 2), ("also refers", R(r"\balso refer"), 2),
  ("refers to both", R(r"\brefers? to both\b"), 3), ("pun", R(r"\bpun(s|ny|ning)?\b"), 2),
  ("play on words", R(r"\bplay on words\b"), 2), ("wordplay", R(r"\bwordplay\b"), 2),
  ("word play", R(r"\bword play\b"), 2), ("play on", R(r"\bplay(s|ing)? on\b"), 1),
  ("idiom", R(r"\bidiom"), 2), ("expression", R(r"\bexpression\b"), 1),
  ("twist on", R(r"\btwist on\b"), 2), ("metaphor", R(r"\bmetaphor"), 1), ("extended", R(r"\bextended\b"), 1)],
 "split_names": [
  ("combining", R(r"\bcombin(ing|es|ed)\b"), 2), ("together make", R(r"\btogether,? (make|makes|form|spell)"), 3),
  ("put together", R(r"\bput together\b"), 2), ("full name", R(r"\bfull name\b"), 2),
  ("first name … last name", R(r"\bfirst name\b.{0,100}?\b(last|sur)name\b"), 3)],
 "hidden_references": [
  ("nod to", R(r"\bnods? to\b"), 1),
  ("reference to the title", R(r"\breference to the (film|movie|show|song|album|book|sitcom|series)\b"), 2),
  ("title of", R(r"\btitle of\b"), 2), ("spells", R(r"\bspell(s|ed|ing)?\b"), 2),
  ("stands for", R(r"\bstands? for\b"), 2), ("acronym", R(r"\bacronym"), 3), ("initials", R(r"\binitials?\b"), 2),
  ("abbreviation", R(r"\babbreviat"), 2), ("code", R(r"\bcode\b"), 1),
  ("digits stand for/refer to", R(r"\b\d+\b.{0,40}?\b(stands? for|refers? to)\b|\b(stands? for|refers? to)\b.{0,40}?\b\d+\b"), 2),
  ("911", R(r"\b911\b"), 2), ("upside down", R(r"\bupside[- ]down\b"), 2)],
}
PUNCH = [("punchline", R(r"\bpunch ?lines?\b")), ("sets up", R(r"\bsets up\b")),
         ("set up", R(r"\bset[- ]up\b")), ("the payoff", R(r"\bthe pay-?off\b"))]
HEDGE = R(r"\b(possibly|might|maybe|perhaps)\b|\?")
CREDIT = R(r"\b(sampl(e|es|ed|ing)|produced by|producer|production|interpolat)")
HEADER = re.compile(r"^\s*\[[^\]]*\]\s*$")
TAB_ORDER = ["split_names", "sound_flips", "hidden_references", "double_meanings"]
BRAND = R(r"\b(brand|company|label|logo|car|designer|clothing|line of|manufacturer)\b")

def classify(note):
    matched, score = [], collections.Counter()
    for tab, sigs in SIG.items():
        for lab, rx, w in sigs:
            if rx.search(note):
                matched.append(lab); score[tab] += w
    punch = [lab for lab, rx in PUNCH if rx.search(note)]
    matched += punch
    if not score:
        return (None, None, matched, bool(punch)) if punch else (None, None, [], False)
    best = max(TAB_ORDER, key=lambda t: (score[t], -TAB_ORDER.index(t)))
    m = set(matched)
    if best == "sound_flips":
        sub = "homophone" if "homophone" in m else "sound_flip"
    elif best == "double_meanings":
        if m & {"idiom", "expression", "twist on"} and not m & {"double meaning", "double entendre", "two meanings", "refers to both"}:
            sub = "idiom_twist"
        elif m & {"metaphor", "extended"} and not m & {"double meaning", "double entendre", "two meanings", "refers to both", "pun", "wordplay", "word play", "play on words"}:
            sub = "extended_metaphor"
        else:
            sub = "double_meaning"
    elif best == "split_names":
        sub = "split_brand" if BRAND.search(note) else "split_name"
    else:
        if m & {"911", "digits stand for/refer to"}:
            sub = "hidden_number"
        elif m & {"spells", "acronym", "initials", "abbreviation", "upside down", "stands for", "code"}:
            sub = "letter_play"
        else:
            sub = "hidden_title"
    return best, sub, matched, bool(punch)

# ---- artist order (baseline vault song counts)
base = {}
for l in open(os.path.join(POW, "all-artists-baseline.md"), encoding="utf-8"):
    m = re.match(r"\| (.+?) \| (\d+) \| (\d+) \|", l)
    if m: base[m.group(1)] = int(m.group(2))
main = sorted([a for a, n in base.items() if n >= 20], key=lambda a: (-base[a], a.casefold()))
rank = {a: i for i, a in enumerate(main)}

# ---- recheck (latest verdict per key)
rech = {}
for l in open(os.path.join(POW, "confirmed-recheck", "recheck.jsonl"), encoding="utf-8"):
    if not l.strip(): continue
    r = json.loads(l)
    rech[(norm(r.get("key_artist")), norm(r.get("key_song")), norm(r.get("key_bar")))] = r.get("verdict")

# ---- wired chips
wired = {}
for l in open(os.path.join(POW, "wordplay-wiring-log.jsonl"), encoding="utf-8"):
    if not l.strip(): continue
    r = json.loads(l)
    if r.get("bar") and r.get("noun"):
        wired[(norm(r.get("artist")), norm(r.get("song")), norm(r["bar"]))] = r["noun"]
for l in open(os.path.join(POW, "wordplay-highlights.jsonl"), encoding="utf-8"):
    if not l.strip(): continue
    r = json.loads(l)
    k = (norm(r.get("artist")), norm(r.get("song")), norm(r.get("bar")))
    if r.get("bar") and k not in wired and r.get("heard_as"):
        wired[k] = r["heard_as"]

def lookup(d, a, s, bars):
    for b in bars:
        k = (norm(a), norm(s), norm(b))
        if k in d: return d[k]
    return None

stats = collections.Counter()
rows = {}
for f in sorted(glob.glob(os.path.join(POW, "genius-clicks", "*.jsonl"))):
    for l in open(f, encoding="utf-8", errors="replace"):
        if not l.strip(): continue
        try: r = json.loads(l)
        except Exception: stats["bad_json"] += 1; continue
        if r.get("type") != "line": continue
        stats["line_rows"] += 1
        note = (r.get("meaning") or "").strip()
        if not note: stats["drop_empty_note"] += 1; continue
        stats["notes_scanned"] += 1
        gline = r.get("line") or ""
        if HEADER.match(gline): stats["drop_section_header"] += 1; continue
        tab, sub, matched, punch = classify(note)
        if not matched:
            stats["drop_credit_only" if CREDIT.search(note) else "drop_no_signal"] += 1; continue
        vl = [v for v in (r.get("vault_lines") or []) if v and v.strip()]
        bar = " ".join(vl) if vl else gline
        cands = [bar] + vl + [gline]
        a, s = r.get("artist") or "", r.get("song") or ""
        verdict = lookup(rech, a, s, cands)
        key = (norm(a), norm(s), norm(bar))
        row = {"artist": a, "song": s, "bar": bar, "note": note,
               "source_url": r.get("url") or None, "guess_tab": tab, "guess_subtype": sub,
               "matched_signals": matched, "hedged": bool(HEDGE.search(note)),
               "punchline_setup": punch,
               "already_reviewed": verdict is not None, "prior_verdict": verdict,
               "wired_chip": lookup(wired, a, s, cands),
               "genius_fragment": gline, "vault_lines": vl,
               "annotation_id": r.get("annotation_id"), "votes": r.get("votes", 0)}
        stats["flagged_raw"] += 1
        if key in rows:
            stats["dupes_merged"] += 1
            old = rows[key]
            better = (len(matched), row["votes"] or 0) > (len(old["matched_signals"]), old["votes"] or 0)
            keep, other = (row, old) if better else (old, row)
            keep["other_notes"] = old.get("other_notes", []) + row.get("other_notes", []) + \
                [{"note": other["note"], "source_url": other["source_url"], "matched_signals": other["matched_signals"]}]
            # carry review/wire info if either side had it
            for fld in ("prior_verdict", "wired_chip"):
                keep[fld] = keep[fld] or other[fld]
            keep["already_reviewed"] = keep["prior_verdict"] is not None
            keep.pop("other_notes_tmp", None)
            rows[key] = keep
        else:
            row["other_notes"] = []
            rows[key] = row

def sortkey(item):
    i, row = item
    a = row["artist"]
    return (0 if a in rank else 1, rank.get(a, 0), -base.get(a, 0), a.casefold(), norm(row["song"]), i)
ordered = [r for _, r in sorted(enumerate(rows.values()), key=sortkey)]
with open(OUT, "x", encoding="utf-8") as fh:
    for r in ordered:
        fh.write(json.dumps(r, ensure_ascii=False) + "\n")

# ---- summary
tabc = collections.Counter(r["guess_tab"] or "(punchline only)" for r in ordered)
subc = collections.Counter((r["guess_tab"] or "(punchline only)", r["guess_subtype"] or "-") for r in ordered)
rev = sum(r["already_reviewed"] for r in ordered)
artc = collections.Counter(r["artist"] for r in ordered)
hedged = sum(r["hedged"] for r in ordered); punch = sum(r["punchline_setup"] for r in ordered)
wiredn = sum(1 for r in ordered if r["wired_chip"])
verdc = collections.Counter(r["prior_verdict"] for r in ordered if r["prior_verdict"])
mainn = sum(1 for r in ordered if r["artist"] in rank)
runtime = time.time() - T0
L = ["# Notes queue summary (Genius community notes → Play on Words tabs)", "",
     f"Generated {time.strftime('%Y-%m-%d %H:%M %Z')} by build_notes_queue.py (runtime {runtime:.1f}s). guess_tab is a regex hint only.", "",
     "## Totals", "",
     f"- line rows read: {stats['line_rows']:,}",
     f"- empty notes dropped: {stats['drop_empty_note']:,}",
     f"- **notes scanned (non-empty): {stats['notes_scanned']:,}**",
     f"- dropped as section headers: {stats['drop_section_header']:,}",
     f"- dropped as sample/production credit only: {stats['drop_credit_only']:,}",
     f"- no tab signal (not flagged): {stats['drop_no_signal']:,}",
     f"- flagged before dedupe: {stats['flagged_raw']:,} (merged {stats['dupes_merged']:,} duplicate artist+song+bar rows into other_notes)",
     f"- **flagged (unique artist+song+bar): {len(ordered):,}**",
     f"- **new (not in recheck.jsonl): {len(ordered)-rev:,}** · already reviewed: {rev:,} ({', '.join(f'{k} {v}' for k, v in verdc.most_common())})",
     f"- hedged: {hedged:,} · punchline_setup flag: {punch:,} · already wired chip: {wiredn:,}",
     f"- rows from the 81 main artists (20+ vault songs): {mainn:,} · other artists: {len(ordered)-mainn:,}", "",
     "## Per guess_tab / subtype", "", "| tab | subtype | count |", "| :--- | :--- | ---: |"]
for t in ["sound_flips", "double_meanings", "split_names", "hidden_references", "(punchline only)"]:
    L.append(f"| **{t}** | (all) | **{tabc[t]:,}** |")
    for (tt, s), n in sorted(subc.items(), key=lambda x: -x[1]):
        if tt == t and t != "(punchline only)": L.append(f"| {t} | {s} | {n:,} |")
L += ["", "## Top 15 artists by flagged count", "", "| artist | flagged | new | vault songs |", "| :--- | ---: | ---: | ---: |"]
for a, n in artc.most_common(15):
    new = sum(1 for r in ordered if r["artist"] == a and not r["already_reviewed"])
    L.append(f"| {a} | {n:,} | {new:,} | {base.get(a, '?')} |")
L += ["", "## Samples (3 per tab, new + unhedged + strongest signals first)", ""]
def clip(s, n=260): s = s.replace("\n", " "); return s if len(s) <= n else s[:n] + "…"
for t in ["sound_flips", "double_meanings", "split_names", "hidden_references", "(punchline only)"]:
    pool = [r for r in ordered if (r["guess_tab"] or "(punchline only)") == t]
    pool.sort(key=lambda r: (r["already_reviewed"], r["hedged"], -len(r["matched_signals"]), -(r["votes"] or 0)))
    L.append(f"### {t}")
    for r in pool[:3]:
        L.append(f"- **{r['artist']} – {r['song']}** ({r['guess_subtype'] or 'flag'}; {', '.join(r['matched_signals'])})  ")
        L.append(f"  bar: “{clip(r['bar'], 200)}”  ")
        L.append(f"  note: {clip(r['note'])}")
    L.append("")
with open(SUM, "x", encoding="utf-8") as fh:
    fh.write("\n".join(L) + "\n")
print(json.dumps({"stats": stats, "flagged": len(ordered), "reviewed": rev, "tabs": tabc, "runtime_s": round(runtime, 1)}, default=dict))
