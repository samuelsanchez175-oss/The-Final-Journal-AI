#!/usr/bin/env python3
"""Pull 3-5 real example lines per rule for the rulebook."""
from __future__ import annotations
import json, random, re, sys
from collections import defaultdict
from pathlib import Path
REPO = Path(__file__).resolve().parents[3]
LLM = REPO / "tools" / "lyric-llm"
OUT = REPO / "docs" / "flow-rules"
sys.path.insert(0, str(LLM))
try:
    from lyriclib import load_cmudict, end_rime
    CMU = load_cmudict(REPO / "XJournal AI" / "cmudict.txt")
except Exception:
    CMU = {}
    end_rime = lambda w, d: None  # type: ignore

_W = re.compile(r"[A-Za-z']+")
rng = random.Random(20261030)


def toks(s): return _W.findall(s or "")
def syl(w):
    w = re.sub(r"[^A-Za-z']", "", w).lower()
    if not w: return 0
    p = CMU.get(w)
    if p:
        return sum(1 for ph in p if any(c.isdigit() for c in ph))
    v = "aeiouy"; c = 0; pv = False
    for ch in w:
        iv = ch in v
        if iv and not pv: c += 1
        pv = iv
    return max(c, 1)
def erime(w): return tuple(end_rime(w.lower(), CMU) or ())


def main():
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna"]
    by_song = defaultdict(list)
    for r in solo: by_song[(r["artist"], r["song"])].append(r)

    buckets = {
        "comma_0": [], "comma_1": [], "comma_2": [], "comma_3plus": [],
        "carry_pair": [],
        "end_rhyme_match": [],
        "multisyl_rhyme": [],
        "inner_rhyme": [],
        "repeated_end_word": [],
        "triplet_candidate": [],
        "pov_i": [],
    }

    for r in solo:
        line = r["line"]; song = r["song"]
        n = line.count(",")
        if n == 0 and len(buckets["comma_0"]) < 5 and len(toks(line)) >= 6:
            buckets["comma_0"].append({"song": song, "line": line})
        if n == 1 and len(buckets["comma_1"]) < 5:
            buckets["comma_1"].append({"song": song, "line": line})
        if n == 2 and len(buckets["comma_2"]) < 5:
            buckets["comma_2"].append({"song": song, "line": line})
        if n >= 3 and len(buckets["comma_3plus"]) < 5:
            buckets["comma_3plus"].append({"song": song, "line": line})
        t = toks(line)
        if t and len(buckets["pov_i"]) < 5 and t[0].lower() in {"i", "im", "i'm", "ima", "i'ma", "my"}:
            buckets["pov_i"].append({"song": song, "line": line})
        # inner rhyme (two words with same rime)
        rimes = [erime(x) for x in t]
        seen = {}
        for ri in rimes:
            if not ri: continue
            if ri in seen and len(buckets["inner_rhyme"]) < 5:
                buckets["inner_rhyme"].append({"song": song, "line": line})
                break
            seen[ri] = True
        # triplet candidate (3 mono-syl in a row, 2+ such runs)
        runs = 0
        for i in range(len(t) - 2):
            if all(syl(tt) == 1 for tt in t[i:i+3]):
                runs += 1
        if runs >= 2 and len(t) >= 6 and len(buckets["triplet_candidate"]) < 5:
            buckets["triplet_candidate"].append({"song": song, "line": line})

    # carry + end-rhyme + repeated end word (require sequential)
    for (artist, song), seq in by_song.items():
        for i in range(len(seq) - 1):
            cur = seq[i]["line"]; nxt = seq[i+1]["line"]
            ct = toks(cur); nt = toks(nxt)
            if not ct or not nt: continue
            cur_term = cur.rstrip() and cur.rstrip()[-1] in ".!?"
            nxt_start_lower = next((ch for ch in nxt if ch.isalpha()), "A").islower()
            if (not cur_term) and nxt_start_lower and len(buckets["carry_pair"]) < 5:
                buckets["carry_pair"].append({"song": song, "pair": [cur, nxt]})
            re_cur = erime(ct[-1]); re_nxt = erime(nt[-1])
            if re_cur and re_nxt and re_cur == re_nxt and ct[-1].lower() != nt[-1].lower() and len(buckets["end_rhyme_match"]) < 5:
                buckets["end_rhyme_match"].append({"song": song, "pair": [cur, nxt]})
            # multisyllable rhyme (end words >= 2 syl, same rime)
            if syl(ct[-1]) >= 2 and syl(nt[-1]) >= 2 and re_cur and re_cur == re_nxt and len(buckets["multisyl_rhyme"]) < 5:
                buckets["multisyl_rhyme"].append({"song": song, "pair": [cur, nxt]})
            if ct[-1].lower() == nt[-1].lower() and len(buckets["repeated_end_word"]) < 5:
                buckets["repeated_end_word"].append({"song": song, "pair": [cur, nxt]})

    (OUT / "gunna_rule_examples.json").write_text(json.dumps(buckets, indent=2, ensure_ascii=False))
    for k, v in buckets.items():
        print(f"{k:22s} {len(v)}")
    print(f"\nwrote {OUT / 'gunna_rule_examples.json'}")

if __name__ == "__main__":
    main()
