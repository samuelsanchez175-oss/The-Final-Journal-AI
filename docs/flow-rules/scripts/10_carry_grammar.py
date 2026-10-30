#!/usr/bin/env python3
"""Grammar-based enjambment on a 200-line sample.

New rule: a line carries into the next when it ends WITHOUT a terminal
clause-closing word AND the next line begins with a continuation marker.

Terminal cues:
  * line ends on a sentence-final punctuation .!? AFTER ad-lib strip
  * line ends on a content noun / verb and the next line starts with a capital
    I / proper noun (new sentence)
  * line ends with a complete clause heuristic: contains a verb AND is not
    followed by a conj/prep/relative on the next line.

Continuation cues on the next line:
  * starts with a conjunction/preposition/relative
  * starts with lowercase (BUT only after ad-lib strip, since Genius
    capitalization is unreliable)
  * starts with "I" when the previous line's end word is a preposition / verb
    particle like "with", "on", "for", "about" (prepositional object pattern)

For precision: 200-line random sample, auto-classify, then dump each
decision with the pair so a human can spot-check. Report the auto-rate.
"""
from __future__ import annotations

import json
import random
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
OUT = REPO / "docs" / "flow-rules"
sys.path.insert(0, str(sys.path[0] or "")); sys.path.insert(0, str(REPO / "tools" / "lyric-llm"))

_W = re.compile(r"[A-Za-z']+")

TERMINAL = ".!?"
CONJ = {"and", "but", "or", "so", "yet", "then", "when", "while", "though",
        "as", "because", "since", "unless", "if"}
PREP = {"to", "of", "in", "on", "with", "by", "for", "at", "from",
        "into", "about", "over", "under", "through", "across", "between",
        "around", "like", "upon", "within"}
RELATIVE = {"that", "which", "who", "whom", "whose"}
# verb particles / prepositions that end a line in mid-clause
HANG = PREP | {"'cause", "cause", "where"}


def strip_adlib_tail(line: str) -> str:
    s = re.sub(r"\([^)]*\)|\[[^\]]*\]", "", line or "")
    trail = {"yeah", "uh", "woo", "huh", "what", "skrrt", "skrr", "ayy",
             "ooh", "woah", "oh", "nah", "hey", "mm", "mmm", "yuh", "yah",
             "aye", "ay", "ye"}
    while True:
        s = s.rstrip(" ,.!?;:—-")
        toks = _W.findall(s)
        if not toks:
            break
        if toks[-1].lower().strip("'") not in trail:
            break
        m = re.search(r"[A-Za-z']+[\s,!?.;:—-]*$", s)
        if not m:
            break
        s = s[:m.start()].rstrip(" ,.!?;:—-")
    return s.strip()


def classify(cur: str, nxt: str) -> dict:
    cur_stripped = strip_adlib_tail(cur)
    nxt_stripped = strip_adlib_tail(nxt)
    reasons: list[str] = []
    terminal = (cur_stripped and cur_stripped.rstrip()[-1] in TERMINAL)
    if terminal:
        return {"carry": False, "reasons": ["cur terminal punctuation"]}
    cur_tokens = _W.findall(cur_stripped)
    nxt_tokens = _W.findall(nxt_stripped)
    if not cur_tokens or not nxt_tokens:
        return {"carry": False, "reasons": ["empty after strip"]}
    cur_end = cur_tokens[-1].lower().strip("'")
    nxt_start = nxt_tokens[0].lower().strip("'")
    if cur_end in HANG:
        reasons.append(f"cur ends on hanging word {cur_end!r}")
    if nxt_start in (CONJ | RELATIVE):
        reasons.append(f"next starts with conj/relative {nxt_start!r}")
    if nxt_start in PREP:
        reasons.append(f"next starts with preposition {nxt_start!r}")
    # verb-less or incomplete-clause heuristic: if cur has NO verb-looking
    # token (ends in -s, -ed, -ing, or common copulas) and starts a thought
    # that depends on the next line, flag it
    def has_verb(toks: list[str]) -> bool:
        copula = {"is", "am", "are", "was", "were", "be", "been", "being",
                  "'s", "'re", "'m", "do", "did", "does", "doin'", "doing",
                  "ain't", "aint", "got", "gotta", "gon'", "gonna", "wanna",
                  "finna", "'ma", "ima"}
        for t in toks:
            tl = t.lower()
            if tl in copula:
                return True
            if tl.endswith(("ing", "in'")) or tl.endswith("ed") or tl.endswith("s"):
                return True
        return False
    cur_has_verb = has_verb(cur_tokens)
    nxt_has_verb = has_verb(nxt_tokens)
    if not cur_has_verb and nxt_has_verb:
        reasons.append("cur has no verb, next does (dangling)")
    carry = bool(reasons)
    return {"carry": carry, "reasons": reasons}


def main() -> int:
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna"]
    by_song: dict[tuple, list[dict]] = {}
    for r in solo:
        by_song.setdefault((r["artist"], r["song"]), []).append(r)
    pairs: list[tuple[str, str, str]] = []
    for seq in by_song.values():
        for i in range(len(seq) - 1):
            pairs.append((seq[i]["song"], seq[i]["line"], seq[i + 1]["line"]))
    rng = random.Random(20261030)
    sample = rng.sample(pairs, 200)
    results = []
    carries = 0
    for song, cur, nxt in sample:
        r = classify(cur, nxt)
        results.append({"song": song, "cur": cur, "nxt": nxt, **r})
        if r["carry"]:
            carries += 1

    md = ["# Grammar-based carry — 200-pair precision check", "",
          f"Sample: 200 adjacent pairs drawn uniformly from Gunna's solo 30,553-line subset.",
          f"Auto-classified **carry: {carries}/200 = {carries/2:.1f}%**", "",
          "Each row below is one pair with the auto decision. Mark the one you disagree with "
          "and we'll tune. CMU/lexicon-based, not a parser.", "",
          "| # | carry? | cur | next | reasons |",
          "| ---:| :-:| --- | --- | --- |"]
    for i, r in enumerate(results, 1):
        yes_no = "YES" if r["carry"] else "no"
        reasons = "; ".join(r["reasons"]) or "—"
        cur = r["cur"].replace("|", "\\|")
        nxt = r["nxt"].replace("|", "\\|")
        md.append(f"| {i} | {yes_no} | {cur!r} | {nxt!r} | {reasons} |")
    (OUT / "carry_grammar_sample.md").write_text("\n".join(md) + "\n")

    # also full-dataset recompute for the overall rate
    total = 0
    carries_total = 0
    length_hist = {"2": 0, "3": 0, "4+": 0}
    for seq in by_song.values():
        i = 0
        while i < len(seq) - 1:
            cur = seq[i]["line"]
            nxt = seq[i + 1]["line"]
            r = classify(cur, nxt)
            total += 1
            if r["carry"]:
                carries_total += 1
                length = 2
                j = i + 1
                while j < len(seq) - 1:
                    jc = classify(seq[j]["line"], seq[j + 1]["line"])
                    if jc["carry"]:
                        length += 1
                        j += 1
                    else:
                        break
                key = str(length) if length < 4 else "4+"
                length_hist[key] = length_hist.get(key, 0) + 1
                i = j + 1
            else:
                i += 1
    full = {
        "pairs_total": total, "carries_total": carries_total,
        "carry_rate": round(carries_total / max(total, 1), 4),
        "length_hist": length_hist,
    }
    (OUT / "carry_grammar_stats.json").write_text(json.dumps(full, indent=2))
    print(f"sample carry: {carries}/200 = {carries/2:.1f}%")
    print(f"full-dataset carry rate (grammar): {full['carry_rate']}  "
          f"({carries_total}/{total})  lengths={length_hist}")
    print(f"wrote carry_grammar_sample.md + carry_grammar_stats.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
