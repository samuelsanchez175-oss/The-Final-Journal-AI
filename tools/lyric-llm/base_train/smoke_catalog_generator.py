#!/usr/bin/env python3
"""Smoke test: catalog retrieval + fine-tuned generator talking to each other.

The catalog + fine-tune marriage: pull 3 scaffolds from catalog_index.sqlite,
feed each with its context to the fine-tune via llm_client.chat, print the
output bar + checks. This does not run frontier_v5 — it isolates the two
subsystems and the handoff between them.

Usage:
  python3 base_train/smoke_catalog_generator.py \
      --model v5-base-mini-50k            # alias (resolves via registry)
      --artist Gunna \
      --n 3

  python3 base_train/smoke_catalog_generator.py \
      --model ft:gpt-4o-mini:pennworkstudios:v5-base-mini-50k:abc \
      --artist Gunna --n 3                 # or pass the raw OpenAI id

Exit code 0 = all N bars came back non-empty. 1 = any failure.
"""

from __future__ import annotations

import argparse
import json
import os
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

import llm_client  # noqa: E402
from catalog_retriever import retrieve_matching_catalog_lines  # noqa: E402
from inner_rhyme_check import count_bar_syllables  # noqa: E402
from lyriclib import estimate_syllables  # noqa: E402

SYSTEM = (
    "Write bars like <voice>. Keep the artist's slang, syllable count, and "
    "rhyme pattern. Preserve the end word if given."
)


def build_prompt(artist: str, scaffold: dict) -> str:
    bar_text = scaffold.get("text") or scaffold.get("bar_text") or scaffold.get("line_text") or ""
    end_word = scaffold.get("end_word") or (bar_text.strip().split()[-1] if bar_text else "")
    section = scaffold.get("section_mode") or scaffold.get("section") or "verse"
    syl = scaffold.get("syllables") or estimate_syllables(bar_text)
    return (
        f"<voice: {artist}> <section: {section}>\n"
        f"SCAFFOLD: {bar_text}\n"
        f"END_WORD: {end_word}\n"
        f"SYLLABLES: {syl}\n"
        "Rewrite this bar in the artist's voice. Keep the end word."
    )


def pick_scaffolds(artist: str, n: int, seed: int) -> list[dict]:
    rng = random.Random(seed)
    pattern = {"target_syllables": 12}
    rows = retrieve_matching_catalog_lines(
        artist,
        pattern,
        limit=max(n * 4, 20),
    )
    rows = list(rows or [])
    if not rows:
        print(f"catalog returned 0 rows for artist={artist!r}", file=sys.stderr)
        return []
    rng.shuffle(rows)
    return rows[:n]


def run(model: str, artist: str, n: int, seed: int, max_tokens: int) -> int:
    scaffolds = pick_scaffolds(artist, n, seed)
    if not scaffolds:
        return 1
    print(f"model={model}  artist={artist}  scaffolds={len(scaffolds)}")
    print("-" * 72)
    fails = 0
    for idx, scaffold in enumerate(scaffolds, 1):
        prompt = build_prompt(artist, scaffold)
        try:
            text = llm_client.chat(
                model=model,
                system=SYSTEM,
                user=prompt,
                max_tokens=max_tokens,
                temperature=0.9,
            )
        except Exception as exc:
            text = ""
            print(f"[{idx}] ERROR {type(exc).__name__}: {exc}", file=sys.stderr)
            fails += 1
            continue
        text = (text or "").strip()
        if not text:
            print(f"[{idx}] empty response", file=sys.stderr)
            fails += 1
            continue
        try:
            syl_out = count_bar_syllables(text)
        except Exception:
            syl_out = estimate_syllables(text)
        scaffold_text = scaffold.get("text") or scaffold.get("bar_text") or ""
        syl_in = scaffold.get("syllables") or estimate_syllables(scaffold_text)
        print(f"[{idx}] in : {scaffold_text[:80]}  (syl={syl_in})")
        print(f"     out: {text[:80]}  (syl={syl_out})")
        print()
    print("-" * 72)
    print(f"ok={len(scaffolds)-fails}/{len(scaffolds)}")
    return 0 if fails == 0 else 1


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Catalog + fine-tune smoke test.")
    p.add_argument("--model", required=True, help="Alias from registry or raw OpenAI model id (ft:...).")
    p.add_argument("--artist", default="Gunna")
    p.add_argument("--n", type=int, default=3)
    p.add_argument("--seed", type=int, default=7)
    p.add_argument("--max-tokens", type=int, default=80)
    args = p.parse_args(argv)
    return run(args.model, args.artist, args.n, args.seed, args.max_tokens)


if __name__ == "__main__":
    raise SystemExit(main())
