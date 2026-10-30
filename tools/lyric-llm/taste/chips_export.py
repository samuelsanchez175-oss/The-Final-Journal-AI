#!/usr/bin/env python3
"""Export Samuel's noun/chip bank into eval/chips.jsonl.

Reads the Swift literal data via `git show` (branch holds no Swift files),
regex-parses NounChipSection literals, joins WordplayFlips.json by chip name,
computes CMU end_rime + syllables, and samples up to 2 real vault lines per
chip from BarHitsCatalog.sqlite (opened read-only).

Does NOT modify any Swift, Xcode project, or the catalog DB.

Output row:
  {chip, category, section, aliases, end_rime, syllables, tags,
   example_lines: [{artist, song, line}], vault_count, linked_flips}
"""
from __future__ import annotations

import json
import re
import sqlite3
import subprocess
import sys
from pathlib import Path
from typing import Iterable

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent.parent
LLM_ROOT = HERE.parent
OUT_PATH = LLM_ROOT / "eval" / "chips.jsonl"
CATALOG = REPO / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite"
SWIFT_BRANCH = "grok/base-llm-voice-conditioning"

sys.path.insert(0, str(LLM_ROOT))
from lyriclib import load_cmudict, end_rime  # type: ignore

_CMU_PATH = REPO / "XJournal AI" / "cmudict.txt"
_CMU: dict | None = None


def _cmu() -> dict:
    global _CMU
    if _CMU is None:
        _CMU = load_cmudict(_CMU_PATH) if _CMU_PATH.exists() else {}
    return _CMU


def _git_show(path: str) -> str:
    out = subprocess.run(
        ["git", "-C", str(REPO), "show", f"{SWIFT_BRANCH}:{path}"],
        capture_output=True, text=True, check=True,
    )
    return out.stdout


# ---------- Swift parsing ----------
_CASE_RE = re.compile(r"^\s*case \.(\w+):\s*$", re.MULTILINE)
_SECTION_RE = re.compile(
    r"NounChipSection\(\s*title:\s*\"([^\"]*)\"\s*,\s*words:\s*\[(.*?)\]\s*\)",
    re.DOTALL,
)
_STRING_RE = re.compile(r'"((?:\\.|[^"\\])*)"')


def _split_cases(src: str) -> list[tuple[str, str]]:
    matches = list(_CASE_RE.finditer(src))
    out = []
    for i, m in enumerate(matches):
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(src)
        out.append((m.group(1), src[start:end]))
    return out


def _parse_sections(block: str) -> list[tuple[str, list[str]]]:
    results = []
    for m in _SECTION_RE.finditer(block):
        title = m.group(1).strip()
        words_blob = m.group(2)
        words = [w.encode().decode("unicode_escape") for w in _STRING_RE.findall(words_blob)]
        results.append((title, words))
    return results


# ---------- CMU helpers ----------
def _syllables(word: str, cmu: dict) -> int:
    w = re.sub(r"[^A-Za-z']", "", word).lower()
    if not w:
        return 0
    phones = cmu.get(w)
    if phones:
        return sum(1 for ph in phones[0].split() if any(c.isdigit() for c in ph))
    # fallback: count vowel groups
    vowels = "aeiouy"
    count, prev = 0, False
    for c in w:
        is_v = c in vowels
        if is_v and not prev:
            count += 1
        prev = is_v
    return max(count, 1)


def _end_rime(phrase: str, cmu: dict) -> tuple[str, ...] | None:
    """Last word's CMU end_rime; fall back to big_phoney for OOV words."""
    words = re.findall(r"[A-Za-z']+", phrase)
    if not words:
        return None
    last = words[-1].lower()
    rime = end_rime(last, cmu)
    if rime:
        return tuple(rime)
    try:
        from catalog_build.annotate import big_phoney  # type: ignore
        tail = big_phoney(last)
        if tail and len(tail) >= 2 and tail[1]:
            # big_phoney returns (word_phones, rime_phones) usually
            r = tail[1] if isinstance(tail[1], (list, tuple)) else tail[1].split()
            return tuple(r)
    except Exception:
        pass
    return None


# ---------- Vault lookup ----------
_CATALOG_CONN: sqlite3.Connection | None = None


def _catalog() -> sqlite3.Connection | None:
    global _CATALOG_CONN
    if _CATALOG_CONN is None and CATALOG.exists():
        _CATALOG_CONN = sqlite3.connect(f"file:{CATALOG}?mode=ro", uri=True,
                                        check_same_thread=False)
    return _CATALOG_CONN


def _vault_examples(chip: str, limit: int = 2) -> tuple[list[dict], int]:
    """Return (sample_rows, total_count). Uses FTS phrase query, bounded."""
    conn = _catalog()
    if conn is None:
        return ([], 0)
    norm = " ".join(re.findall(r"[A-Za-z']+", chip.lower()))
    if not norm:
        return ([], 0)
    try:
        quoted = '"' + norm + '"'
        # count once, cheap bound
        cnt_row = conn.execute(
            "SELECT COUNT(*) FROM bars_fts WHERE bars_fts MATCH ?", (quoted,),
        ).fetchone()
        total = int(cnt_row[0]) if cnt_row else 0
        samples: list[dict] = []
        if total > 0:
            rows = conn.execute(
                "SELECT bars.line, bars.artist, bars.song FROM bars_fts "
                "JOIN bars ON bars.rowid = bars_fts.rowid "
                "WHERE bars_fts MATCH ? LIMIT ?", (quoted, limit),
            ).fetchall()
            for line, artist, song in rows:
                samples.append({"line": line, "artist": artist, "song": song})
        return (samples, total)
    except sqlite3.Error:
        return ([], 0)


# ---------- WordplayFlips join ----------
def _load_flips() -> dict[str, list[dict]]:
    try:
        raw = _git_show("XJournal AI/WordplayFlips.json")
        data = json.loads(raw)
    except Exception:
        return {}
    by_chip: dict[str, list[dict]] = {}
    for row in data:
        chip = (row.get("chip") or "").strip().lower()
        if not chip:
            continue
        by_chip.setdefault(chip, []).append({
            "artist": row.get("artist"),
            "song": row.get("song"),
            "bar": row.get("bar"),
            "heard_as": row.get("heardAs"),
            "image": row.get("image"),
        })
    return by_chip


# ---------- Topic → chip category map ----------
TOPIC_CATEGORIES: dict[str, list[str]] = {
    "money_flex":        ["money", "jewelry", "jewelers", "brands", "cars", "clothing"],
    "women_romance":     ["woman", "family"],
    "braggadocio_skill": ["money", "jewelry", "clothing", "artists", "producers"],
    "come_up_hustle":    ["money", "food", "places", "family"],
    "loyalty_friends":   ["opps", "family", "guns"],
    "luxury_brands":     ["brands", "cars", "jewelry", "jewelers", "clothing", "boats", "aviation"],
    "fame_industry":     ["artists", "producers", "celebs", "characters"],
    "pain_trauma":       ["drugs", "syrups", "opps", "kill"],
    "violence_street":   ["guns", "kill", "opps", "places"],
    "dreams_future":     ["money", "places", "cars", "aviation"],
    "party_lifestyle":   ["liquors", "drugs", "syrups", "clothing", "woman"],
    "family_home":       ["family", "places", "food"],
    "sex":               ["woman"],
    "betrayal_enemies":  ["opps", "guns", "kill"],
}


# ---------- Pipeline ----------
def iter_chip_rows(vault_samples: bool = True) -> Iterable[dict]:
    src = _git_show("XJournal AI/NounBankSections.swift")
    flips_by_chip = _load_flips()
    cmu = _cmu()
    for category, block in _split_cases(src):
        for section_title, words in _parse_sections(block):
            for chip in words:
                chip_clean = chip.strip()
                if not chip_clean:
                    continue
                rime = _end_rime(chip_clean, cmu)
                syl = _syllables(chip_clean, cmu)
                samples, total = (([], 0) if not vault_samples
                                  else _vault_examples(chip_clean, limit=2))
                linked = flips_by_chip.get(chip_clean.lower(), [])
                yield {
                    "chip": chip_clean,
                    "category": category,
                    "section": section_title,
                    "aliases": [],
                    "end_rime": list(rime) if rime else [],
                    "syllables": syl,
                    "tags": [category, section_title],
                    "example_lines": samples,
                    "vault_count": total,
                    "linked_flips": linked,
                }


def main() -> int:
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default=str(OUT_PATH),
                        help="Output JSONL path")
    parser.add_argument("--no-vault", action="store_true",
                        help="Skip vault sampling (faster)")
    args = parser.parse_args()

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    count = 0
    cats: dict[str, int] = {}
    with out_path.open("w", encoding="utf-8") as f:
        for row in iter_chip_rows(vault_samples=not args.no_vault):
            f.write(json.dumps(row) + "\n")
            count += 1
            cats[row["category"]] = cats.get(row["category"], 0) + 1
            if count % 200 == 0:
                print(f"  {count} chips...", file=sys.stderr)

    # topic map goes in a sibling file
    topic_map = out_path.parent / "chips_topic_map.json"
    topic_map.write_text(json.dumps(TOPIC_CATEGORIES, indent=2))

    print(f"wrote {count} chips to {out_path}")
    print(f"wrote topic map to {topic_map}")
    print("per-category counts:")
    for cat, n in sorted(cats.items(), key=lambda kv: -kv[1]):
        print(f"  {cat:20s} {n}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
