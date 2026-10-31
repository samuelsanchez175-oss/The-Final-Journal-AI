#!/usr/bin/env python3
"""Grammar-based carry v2 — spaCy POS, order-preserved songs only.

Carry decision tree per adjacent pair:
  0. strip parentheticals + trailing ad-libs on both lines
  1. if cur ends in `.!?` → no carry
  2. if cur ends on a HANG word (prep / particle / 'cause / where) → CARRY
  3. if cur has NO VERB/AUX token AND nxt has a VERB/AUX → CARRY (dangling)
  4. nxt starting with and/that/which is NOT by itself a carry

200-pair sample drawn from the order_preserved subset only.
Writes docs/flow-rules/carry_v2_sample.md and carry_v2_stats.json.
"""
from __future__ import annotations

import json
import random
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
LLM = REPO / "tools" / "lyric-llm"
OUT = REPO / "docs" / "flow-rules"
sys.path.insert(0, str(LLM))

import spacy  # type: ignore

NLP = spacy.load("en_core_web_sm")

_W = re.compile(r"[A-Za-z']+")
TERMINAL = ".!?"
ADLIBS = {"yeah", "uh", "woo", "huh", "what", "skrrt", "skrr", "ayy",
          "ooh", "woah", "oh", "nah", "hey", "mm", "mmm", "yuh", "yah",
          "aye", "ay", "ye"}
HANG = {"to", "of", "in", "on", "with", "by", "for", "at", "from",
        "into", "about", "over", "under", "through", "across", "between",
        "around", "like", "upon", "within", "'cause", "cause", "where"}


def strip_adlibs(line: str) -> str:
    s = re.sub(r"\([^)]*\)|\[[^\]]*\]", "", line or "")
    while True:
        s = s.rstrip(" ,.!?;:—-")
        toks = _W.findall(s)
        if not toks or toks[-1].lower().strip("'") not in ADLIBS:
            break
        m = re.search(r"[A-Za-z']+[\s,!?.;:—-]*$", s)
        if not m:
            break
        s = s[:m.start()].rstrip(" ,.!?;:—-")
    return s.strip()


def has_verb(text: str) -> bool:
    doc = NLP(text)
    return any(t.pos_ in ("VERB", "AUX") for t in doc)


def classify(cur: str, nxt: str) -> dict:
    cs = strip_adlibs(cur); ns = strip_adlibs(nxt)
    if not cs:
        return {"carry": False, "reasons": ["cur empty"]}
    if cs.rstrip()[-1] in TERMINAL:
        return {"carry": False, "reasons": ["cur terminal punctuation"]}
    ct = _W.findall(cs); nt = _W.findall(ns)
    if not ct or not nt:
        return {"carry": False, "reasons": ["empty after strip"]}
    cur_end = ct[-1].lower().strip("'")
    reasons: list[str] = []
    if cur_end in HANG:
        reasons.append(f"cur ends on hanging word {cur_end!r}")
    cur_has = has_verb(cs); nxt_has = has_verb(ns)
    if not cur_has and nxt_has:
        reasons.append("cur has no VERB/AUX, next does (dangling)")
    return {"carry": bool(reasons), "reasons": reasons,
            "cur_has_verb": cur_has, "nxt_has_verb": nxt_has}


def main() -> int:
    flags = json.loads((OUT / "song_order_flags.json").read_text())
    keep = {s["song"] for s in flags["songs"] if s["flag"] == "order_preserved"}
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna" and r["song"] in keep]
    by_song: dict[str, list[dict]] = {}
    for r in solo:
        by_song.setdefault(r["song"], []).append(r)
    pairs = [(seq[i]["song"], seq[i]["line"], seq[i + 1]["line"])
             for seq in by_song.values() for i in range(len(seq) - 1)]

    rng = random.Random(20261030)
    sample = rng.sample(pairs, 200)
    results = []; carries_sample = 0
    for song, cur, nxt in sample:
        r = classify(cur, nxt)
        results.append({"song": song, "cur": cur, "nxt": nxt, **r})
        if r["carry"]:
            carries_sample += 1

    md = ["# Grammar-based carry v2 — spaCy POS, order-preserved subset", "",
          f"**Subset:** 593 order-preserved Gunna songs ({len(solo)} lines, "
          f"{len(pairs)} adjacent pairs). spaCy `en_core_web_sm`. "
          f"Decision tree in header comment of `scripts/17_carry_v2.py`.",
          "",
          f"**Sample 200 pairs — auto-carry: {carries_sample}/200 = {carries_sample/2:.1f}%**",
          "",
          "| # | carry? | cur | next | cur_verb | nxt_verb | reasons |",
          "| ---:| :-:| --- | --- | :-:| :-:| --- |"]
    for i, r in enumerate(results, 1):
        yn = "YES" if r["carry"] else "no"
        cur = (r["cur"] or "").replace("|", "\\|")
        nxt = (r["nxt"] or "").replace("|", "\\|")
        rs = "; ".join(r["reasons"]) or "—"
        cv = "✓" if r.get("cur_has_verb") else "✗"
        nv = "✓" if r.get("nxt_has_verb") else "✗"
        md.append(f"| {i} | {yn} | {cur!r} | {nxt!r} | {cv} | {nv} | {rs} |")
    (OUT / "carry_v2_sample.md").write_text("\n".join(md) + "\n")

    # Full-subset rate
    print(f"sample 200: carry={carries_sample}/200 = {carries_sample/2:.1f}%")
    print("full-subset recompute running...", file=sys.stderr)
    carries_total = pair_total = 0
    length_hist = {"2": 0, "3": 0, "4+": 0}
    for seq in by_song.values():
        i = 0
        while i < len(seq) - 1:
            r = classify(seq[i]["line"], seq[i + 1]["line"])
            pair_total += 1
            if r["carry"]:
                carries_total += 1
                length = 2
                j = i + 1
                while j < len(seq) - 1 and classify(seq[j]["line"], seq[j + 1]["line"])["carry"]:
                    length += 1; j += 1
                key = str(length) if length < 4 else "4+"
                length_hist[key] = length_hist.get(key, 0) + 1
                i = j + 1
            else:
                i += 1
    rate = round(carries_total / max(pair_total, 1), 4)
    stats = {
        "sample_carries": carries_sample, "sample_rate": carries_sample / 200,
        "subset_pairs": pair_total, "subset_carries": carries_total,
        "subset_carry_rate": rate, "subset_lengths": length_hist,
    }
    (OUT / "carry_v2_stats.json").write_text(json.dumps(stats, indent=2))
    print(f"full-subset: {carries_total}/{pair_total} = {rate}  lengths={length_hist}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
