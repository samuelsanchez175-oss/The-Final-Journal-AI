#!/usr/bin/env python3
"""Step 6 reference: run the triplet detector on Migos / Quavo / Takeoff / Offset
so Gunna's rate can be read against a known triplet-rap baseline."""
from __future__ import annotations

import collections
import json
import re
import sqlite3
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
DB = REPO / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite"
LLM = REPO / "tools" / "lyric-llm"
OUT = REPO / "docs" / "flow-rules"
sys.path.insert(0, str(LLM))

try:
    from lyriclib import load_cmudict
    CMU = load_cmudict(REPO / "XJournal AI" / "cmudict.txt")
except Exception:
    CMU = {}

_WORD = re.compile(r"[A-Za-z']+")
VOICES = ["Migos", "Quavo", "Takeoff", "Offset"]


def _tokens(line: str) -> list[str]:
    return _WORD.findall(line or "")


def _syllables(word: str) -> int:
    w = re.sub(r"[^A-Za-z']", "", word).lower()
    if not w:
        return 0
    phones = CMU.get(w)
    if phones:
        return sum(1 for ph in phones if any(c.isdigit() for c in ph))
    vowels = "aeiouy"
    count, prev = 0, False
    for c in w:
        is_v = c in vowels
        if is_v and not prev:
            count += 1
        prev = is_v
    return max(count, 1)


def rates(rows: list[tuple[str, str]]) -> dict:
    triplet = stack = density = 0
    examples = []
    for artist, line in rows:
        toks = _tokens(line)
        syl = sum(_syllables(t) for t in toks)
        is_triplet = False
        for i in range(len(toks) - 2):
            if toks[i].lower() == toks[i + 1].lower() == toks[i + 2].lower():
                stack += 1
                is_triplet = True
                break
        if not is_triplet:
            runs = 0
            for i in range(len(toks) - 2):
                if all(_syllables(t) == 1 for t in toks[i:i + 3]):
                    runs += 1
            if runs >= 3 and len(toks) >= 8:
                triplet += 1
                is_triplet = True
        if syl >= 16 and line.count(",") >= 3:
            density += 1
        if is_triplet and len(examples) < 5:
            examples.append({"artist": artist, "line": line})
    n = len(rows)
    return {
        "n": n,
        "triplet_rate": round(triplet / max(n, 1), 4),
        "repeated_stack_rate": round(stack / max(n, 1), 4),
        "density_rate": round(density / max(n, 1), 4),
        "examples": examples,
    }


def main() -> int:
    conn = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    per_voice = {}
    for v in VOICES:
        rows = conn.execute(
            "SELECT artist, line FROM bars WHERE lower(artist) LIKE ?",
            (f"%{v.lower()}%",),
        ).fetchall()
        per_voice[v] = rates([(a, l) for a, l in rows if l])
    conn.close()
    out_path = OUT / "migos_triplet_reference.md"
    lines = [
        "# Triplet detector — Migos reference", "",
        "Same detector used on Gunna, run against Migos, Quavo, Takeoff, Offset. "
        "This gives Gunna's triplet rate a known baseline. ESTIMATE: all three "
        "rates come from CMU syllable counts and simple word-repetition patterns, "
        "not from any beat alignment.", "",
        "## Rates", "",
        "| voice | n lines | triplet (3-mono run) | repeated-stack | density (≥16 syl AND ≥3 commas) |",
        "| --- | ---:| ---:| ---:| ---:|",
    ]
    for v, s in per_voice.items():
        lines.append(f"| {v} | {s['n']} | {s['triplet_rate']} | {s['repeated_stack_rate']} | {s['density_rate']} |")
    gs = json.load(open(OUT / "gunna_stats.json"))["triplets"]
    lines.append(f"| **Gunna** (for comparison) | {gs['lines']} | {gs['triplet_flag_rate']} | {gs['repeated_stack_rate']} | {gs['density_rate']} |")
    lines += ["", "## Example triplet-flagged lines", ""]
    for v, s in per_voice.items():
        if s["examples"]:
            lines.append(f"**{v}**")
            for ex in s["examples"][:3]:
                lines.append(f"- `{ex['artist']}` — {ex['line']!r}")
            lines.append("")
    out_path.write_text("\n".join(lines) + "\n")
    print(f"wrote {out_path}")
    for v, s in per_voice.items():
        print(f"  {v:10s}  n={s['n']:6d}  triplet={s['triplet_rate']}  stack={s['repeated_stack_rate']}  density={s['density_rate']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
