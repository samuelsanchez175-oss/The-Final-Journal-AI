#!/usr/bin/env python3
"""AI Sparkler style profile — Phase 5a: Blocks catalog + topic -> blocks map.

  export : parse the Blocks bank out of XJournal AI/NounBankStore.swift (+ NounBankSheet.swift groups,
           + WordplayFlips.json chips) into out/blocks_catalog.jsonl  {block, norm, category, group, source}
  map    : for every song labeled in Phase 4 (out/topic_chain_songs.jsonl), find which blocks appear in the
           bars of each topic run. Writes out/topic_blocks.json:
             prior    : curated category -> topic hints (what the generator should reach for before data exists)
             observed : topic -> block -> count, plus per-artist counts and lift (how over-used vs the catalog base rate)

Usage:
  python3 tools/style-profile/phase5_blocks_map.py export
  python3 tools/style-profile/phase5_blocks_map.py map
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import phase1_song_metrics as p1  # noqa: E402

ROOT = p1.ROOT
APP = ROOT / "XJournal AI"
OUT = Path(__file__).resolve().parent / "out"
STR_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')

# Curated prior: Blocks category -> likely topics (names match phase4 TAXONOMY). Data in `observed` refines this.
CATEGORY_TOPIC_PRIOR = {
    "liquors": ["party_lifestyle", "money_flex"], "syrups": ["drugs"], "drugs": ["drugs"], "substances": ["drugs"],
    "food": ["party_lifestyle", "money_flex"], "jewelry": ["money_flex", "luxury_brands"], "grills": ["money_flex", "luxury_brands"],
    "jewelers": ["luxury_brands"], "money": ["money_flex", "come_up_hustle"], "brands": ["luxury_brands", "money_flex"],
    "clothing": ["luxury_brands", "money_flex"], "hair": ["women_romance", "luxury_brands"], "nails": ["women_romance"],
    "tattoos": ["pain_trauma", "braggadocio_skill"], "lingerie": ["sex", "women_romance"], "toys": ["sex"],
    "guns": ["violence_street"], "kill": ["violence_street"], "opps": ["betrayal_enemies", "violence_street"],
    "places": ["family_home", "party_lifestyle"], "woman": ["women_romance", "sex"], "twerk": ["sex", "party_lifestyle"],
    "streets": ["violence_street", "come_up_hustle"], "kingpin": ["come_up_hustle", "drugs"], "trapLife": ["come_up_hustle", "drugs"],
    "paranoia": ["violence_street", "mental_health"], "cars": ["money_flex", "luxury_brands"], "motorcycles": ["money_flex"],
    "boats": ["money_flex", "luxury_brands"], "aviation": ["money_flex"], "military": ["violence_street"],
    "family": ["family_home", "loyalty_friends"], "friends": ["loyalty_friends"], "producers": ["fame_industry"],
    "artists": ["fame_industry", "braggadocio_skill"], "celebs": ["fame_industry", "braggadocio_skill"],
    "events": ["party_lifestyle", "fame_industry"], "characters": ["wordplay_punchline", "braggadocio_skill"],
    "actors": ["fame_industry", "wordplay_punchline"], "streamers": ["fame_industry"], "religion": ["faith_mortality"],
    "nba": ["braggadocio_skill", "wordplay_punchline"], "nfl": ["braggadocio_skill"], "boxing": ["braggadocio_skill", "violence_street"],
    "sports": ["braggadocio_skill"], "wrestlers": ["braggadocio_skill", "wordplay_punchline"],
    "animals": ["wordplay_punchline", "braggadocio_skill"], "insects": ["wordplay_punchline"], "games": ["wordplay_punchline", "party_lifestyle"],
    "apps": ["fame_industry", "social_commentary"], "looks": ["women_romance", "braggadocio_skill"], "flowers": ["women_romance", "nostalgia_reflection"],
    "feelings": ["mental_health", "pain_trauma"], "phrases": ["wordplay_punchline", "braggadocio_skill"], "wordplay": ["wordplay_punchline"],
}


def norm(text: str) -> str:
    return " ".join(re.findall(r"[a-z0-9]+", text.lower().replace("’", "'").replace("'", "")))


# ---------------------------------------------------------------- export


def parse_store(path: Path) -> list[tuple[str, str]]:
    """(category_case, word) pairs from NounBankStore.words(for:)."""
    lines = path.read_text(encoding="utf-8").splitlines()
    start = next(i for i, l in enumerate(lines) if "static func words(for category" in l)
    pairs, cat = [], None
    for l in lines[start + 1:]:
        if re.match(r"^    (private )?static func ", l) or re.match(r"^}", l):
            break
        m = re.match(r"^\s*case \.([A-Za-z0-9_]+(?:,\s*\.[A-Za-z0-9_]+)*):", l)
        if m:
            cat = m.group(1).split(",")[0].strip()
            continue
        if cat:
            code = l.split("//")[0]
            for s in STR_RE.findall(code):
                if s.strip():
                    pairs.append((cat, s))
    return pairs


def parse_groups(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    groups = {}
    for m in re.finditer(r"case \.([A-Za-z0-9_]+): return \[([^\]]+)\]", text):
        for cat in re.findall(r"\.([A-Za-z0-9_]+)", m.group(2)):
            groups[cat] = m.group(1)
    return groups


def cmd_export(_args) -> int:
    OUT.mkdir(exist_ok=True)
    pairs = parse_store(APP / "NounBankStore.swift")
    groups = parse_groups(APP / "NounBankSheet.swift")
    seen, rows = set(), []
    for cat, word in pairs:
        key = (cat, norm(word))
        if not key[1] or key in seen:
            continue
        seen.add(key)
        rows.append({"block": word, "norm": key[1], "category": cat, "group": groups.get(cat), "source": "noun_bank"})
    flips = json.loads((APP / "WordplayFlips.json").read_text(encoding="utf-8"))
    for f in flips if isinstance(flips, list) else []:
        chip = f.get("chip")
        if chip and ("wordplay", norm(chip)) not in seen:
            seen.add(("wordplay", norm(chip)))
            rows.append({"block": chip, "norm": norm(chip), "category": "wordplay", "group": "wordplay",
                         "source": "wordplay_flips", "heard_as": f.get("heardAs")})
    with open(OUT / "blocks_catalog.jsonl", "w", encoding="utf-8") as fh:
        for r in rows:
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")
    per = Counter(r["category"] for r in rows)
    print(f"{len(rows)} blocks in {len(per)} categories -> {OUT / 'blocks_catalog.jsonl'}")
    print("categories:", ", ".join(f"{k}={v}" for k, v in per.most_common(8)), "…")
    return 0


# ---------------------------------------------------------------- map


def load_catalog() -> dict[str, list[dict]]:
    by_norm = defaultdict(list)
    for line in open(OUT / "blocks_catalog.jsonl", encoding="utf-8"):
        r = json.loads(line)
        by_norm[r["norm"]].append(r)
    return by_norm


GENERIC_SINGLE_WORDS = p1.STOPWORDS | frozenset(
    "see pull when still back down up out off over take make give know think say said tell look come came "
    "going went run ran put keep let want need feel work play move hit hold turn".split())
MAX_BASE_RATE = 0.02  # a one-word block in >2% of all labeled bars is vocabulary, not a block signal


def find_blocks(bar_norm: str, catalog: dict[str, list[dict]], max_len: int = 4) -> list[str]:
    """n-gram scan (1..max_len words) of a normalised bar against block norms."""
    words = bar_norm.split()
    hits = []
    for n in range(1, max_len + 1):
        for i in range(len(words) - n + 1):
            g = " ".join(words[i:i + n])
            if g in catalog and not (n == 1 and g in GENERIC_SINGLE_WORDS):
                hits.append(g)
    return hits


def cmd_map(args) -> int:
    catalog = load_catalog()
    chain = [json.loads(l) for l in open(OUT / "topic_chain_songs.jsonl", encoding="utf-8")]
    songs = {(c["artist"], c["song"]): c for c in chain}
    csv_songs = p1.read_songs(p1.DEFAULT_CSV, {c["artist"].lower() for c in chain})
    topic_blocks: dict[str, Counter] = defaultdict(Counter)
    artist_blocks: dict[str, dict[str, Counter]] = defaultdict(lambda: defaultdict(Counter))
    topic_bars: Counter = Counter()
    base: Counter = Counter()
    total_bars = 0
    for (art, song), c in songs.items():
        rec = csv_songs.get((art, song))
        if not rec:
            continue
        lines = [t for _, t in sorted(rec["lines"], key=lambda x: x[0])]
        seen, uniq = set(), []
        for t in lines:
            k = p1.norm_line(t)
            if k and k not in seen:
                seen.add(k)
                uniq.append(t)
        bars = uniq[: c["bars_labeled"]]
        for run in c["runs"]:
            for b in bars[run["start"] - 1: run["end"]]:
                hits = set(find_blocks(norm(b), catalog))
                topic_bars[run["topic"]] += 1
                total_bars += 1
                for h in hits:
                    topic_blocks[run["topic"]][h] += 1
                    artist_blocks[art][run["topic"]][h] += 1
                    base[h] += 1
    observed = {}
    for topic, cnt in topic_blocks.items():
        rows = []
        for block, n in cnt.most_common(args.top * 3):
            if len(rows) >= args.top:
                break
            if " " not in block and base[block] / max(1, total_bars) > MAX_BASE_RATE:
                continue
            rate_topic = n / max(1, topic_bars[topic])
            rate_all = base[block] / max(1, total_bars)
            rows.append({"block": block, "count": n, "lift": round(rate_topic / rate_all, 2) if rate_all else None,
                         "categories": sorted({r["category"] for r in catalog[block]})})
        observed[topic] = {"bars": topic_bars[topic], "top_blocks": rows}
    result = {"schema": "phase5.v1", "songs_used": len(songs), "bars_used": total_bars,
              "prior_category_to_topics": CATEGORY_TOPIC_PRIOR, "observed": observed}
    (OUT / "topic_blocks.json").write_text(json.dumps(result, ensure_ascii=False, indent=1))
    per_artist = {a: {t: dict(c.most_common(15)) for t, c in d.items()} for a, d in artist_blocks.items()}
    (OUT / "artist_topic_blocks.json").write_text(json.dumps(per_artist, ensure_ascii=False))
    print(f"{len(songs)} labeled songs, {total_bars} bars, {len(observed)} topics -> {OUT / 'topic_blocks.json'}")
    for t in ("money_flex", "drugs", "violence_street"):
        if t in observed:
            print(t, [(r["block"], r["count"], r["lift"]) for r in observed[t]["top_blocks"][:6]])
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("export").set_defaults(fn=cmd_export)
    m = sub.add_parser("map")
    m.add_argument("--top", type=int, default=40)
    m.set_defaults(fn=cmd_map)
    args = ap.parse_args()
    return args.fn(args)


if __name__ == "__main__":
    raise SystemExit(main())
