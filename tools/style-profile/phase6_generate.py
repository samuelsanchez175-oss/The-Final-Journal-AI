#!/usr/bin/env python3
"""AI Sparkler Phase 6: bar generation, block sourcing, and feedback loop.

Generates N bars for a specified artist using style profile (Phase 2), topic chains (Phase 4),
and block maps (Phase 5). Logs generations + sources to feedback store. Grades output.

Usage:
  python3 tools/style-profile/phase6_generate.py --artist "Gunna" --bars 4

Output: generation_id with bars, sources (blocks + catalog refs), and footer data for voting.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import uuid
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import phase1_song_metrics as p1
import feedback_store

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
ROOT = p1.ROOT

SCHEMA_VERSION = "phase6.v1"
MODEL_DEFAULT = "haiku"
PROMPT_VERSION = "bars.v2"

# ---------------------------------------------------------------- load data


def load_style_card(artist: str) -> dict | None:
    """Load artist profile from Phase 2."""
    for line in open(OUT / "artist_grades.jsonl", encoding="utf-8"):
        r = json.loads(line)
        if r["artist"] == artist:
            return r
    return None


def load_topic_blocks(path: Path = OUT / "topic_blocks.json") -> dict:
    """Load topic→blocks map from Phase 5b."""
    return json.loads(path.read_text(encoding="utf-8"))


def load_blocks_catalog(path: Path = OUT / "blocks_catalog.jsonl") -> dict[str, list[dict]]:
    """Load all blocks by normalized name."""
    by_norm = defaultdict(list)
    for line in open(path, encoding="utf-8"):
        r = json.loads(line)
        by_norm[r["norm"]].append(r)
    return by_norm


def load_artist_chains(artist: str) -> dict | None:
    """Load topic transition probs + distribution for artist from Phase 4."""
    for line in open(OUT / "topic_chain_artists.jsonl", encoding="utf-8"):
        r = json.loads(line)
        if r["artist"] == artist:
            return r
    return None


# ---------------------------------------------------------------- generation


def generate_bar(artist: str, topic: str, style_card: dict, topic_blocks: dict,
                 context_bars: list[str] = None, model: str = MODEL_DEFAULT) -> str | None:
    """Generate one bar in the given topic, following artist's style."""

    rules = style_card.get("rules", [])[:5]

    prompt = f"""Write a single bar as {artist} about {topic}.

Style:
{chr(10).join(f"  - {r}" for r in rules)}

Bar format: 1 line, 1 comma, ~12-15 syllables. No filler words. Natural flow."""

    if context_bars:
        prior_texts = [b["text"] if isinstance(b, dict) else b for b in context_bars[-2:]]
        prompt += f"\n\nPrevious bars (for flow, not to copy):\n" + "\n".join(prior_texts)

    prompt += f"\n\n{artist} bar:"

    cmd = ["claude", "-p", "--model", model, "--no-session-persistence"]
    try:
        r = subprocess.run(cmd, input=prompt, capture_output=True, text=True, timeout=60)
        if r.returncode == 0 and r.stdout.strip():
            return r.stdout.strip()
        elif r.stderr:
            print(f"DEBUG: {r.stderr[:200]}", file=sys.stderr)
    except Exception as e:
        print(f"DEBUG: {e}", file=sys.stderr)
    return None


def find_blocks_in_bar(bar_text: str, blocks_catalog: dict, max_len: int = 4) -> list[dict]:
    """N-gram scan of bar against block norms; return block dicts."""
    hits = []
    norm_bar = " ".join(re.findall(r"[a-z0-9]+", bar_text.lower()))
    words = norm_bar.split()

    for n in range(min(max_len, len(words)), 0, -1):
        for i in range(len(words) - n + 1):
            g = " ".join(words[i:i + n])
            if g in blocks_catalog:
                for block_dict in blocks_catalog[g]:
                    hits.append({"norm": g, **block_dict})

    return hits


# ---------------------------------------------------------------- grading


def grade_bar(bar_text: str, topic: str, artist: str, lex: p1.Lexicon,
              grades: dict) -> dict:
    """Score bar on rhyme, cadence, vocab using Phase 2 benchmarks."""
    bar_obj = p1.Bar(bar_text, lex)

    return {
        "topic": topic,
        "syllables": bar_obj.syl,
        "stressed_syllables": bar_obj.stressed,
        "known_syllables": bar_obj.known_syl,
        "pauses": bar_obj.pauses,
        "adlib": bar_obj.adlib,
        "words": len(bar_obj.words),
        "out_of_vocab": bar_obj.oov,
    }


# ---------------------------------------------------------------- main


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--artist", required=True, help="artist name")
    ap.add_argument("--bars", type=int, default=4, help="number of bars to generate")
    ap.add_argument("--model", default=MODEL_DEFAULT, choices=["haiku", "sonnet"], help="model to use (haiku=faster, sonnet=better quality)")
    ap.add_argument("--db", type=Path, default=OUT / "feedback.db", help="feedback store DB path")
    args = ap.parse_args()

    # Load all data
    style_card = load_style_card(args.artist)
    if not style_card:
        print(f"artist '{args.artist}' not in artist_grades.jsonl")
        return 1

    topic_blocks = load_topic_blocks()
    blocks_catalog = load_blocks_catalog()
    artist_chains = load_artist_chains(args.artist)
    song_grades = {(r["artist"], r["song"]): r for r in (json.loads(l) for l in open(OUT / "song_grades.jsonl", encoding="utf-8")) if "artist" in r and "song" in r}
    lex = p1.Lexicon(p1.load_cmudict(p1.DEFAULT_CMU))

    # Init feedback store
    store = feedback_store.FeedbackStore(str(args.db))

    # Generate bars
    generation_bars = []
    topic_chain = []

    # Use artist's topic distribution to seed topic sequence
    topic_dist = style_card.get("topic_share_pct", {})
    topics = sorted(topic_dist.keys(), key=lambda t: -topic_dist[t])[:10]

    for i in range(args.bars):
        # Pick topic (simple: cycle through top topics)
        topic = topics[i % len(topics)] if topics else "braggadocio_skill"
        topic_chain.append(topic)

        # Generate bar
        context = generation_bars[-3:] if generation_bars else []
        bar_text = generate_bar(args.artist, topic, style_card, topic_blocks, context, model=args.model)
        if not bar_text:
            print(f"generation failed for bar {i+1}", file=sys.stderr)
            continue

        # Find blocks in bar
        blocks_in_bar = find_blocks_in_bar(bar_text, blocks_catalog)
        sources = [{"kind": "block", "ref": b["norm"], "category": b["category"]} for b in blocks_in_bar]

        # Grade bar
        grade = grade_bar(bar_text, topic, args.artist, lex, {})

        generation_bars.append({
            "index": i,
            "text": bar_text,
            "topic": topic,
            "sources": sources,
            "grade": grade
        })

    # Log to feedback store
    gid = store.log_generation(
        artist=args.artist,
        bars=generation_bars,
        request={"bars_requested": args.bars, "prompt_version": PROMPT_VERSION, "model": args.model},
        model=args.model,
        prompt_version=PROMPT_VERSION
    )

    # Output
    result = {
        "schema": SCHEMA_VERSION,
        "generation_id": gid,
        "artist": args.artist,
        "bars": generation_bars,
        "topic_chain": topic_chain,
        "db": str(args.db)
    }
    print(json.dumps(result, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
