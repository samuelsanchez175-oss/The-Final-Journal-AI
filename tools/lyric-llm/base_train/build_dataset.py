#!/usr/bin/env python3
"""Shared dataset CLI for the base-LLM fine-tune.

    python3 base_train/build_dataset.py --mode 50k_sample --fim 0.2 \\
        --variant one_hot --out out/train_voice_a.jsonl

Grok #1's builder was not on disk. Sampling lives in voice_dataset.py.
Voice text lives in voice_variant.py. This file is the command both
briefs name. It does not read or print an API key.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import voice_dataset  # noqa: E402


def default_catalog() -> Path:
    return Path(__file__).resolve().parents[1] / "out" / "catalog_index.sqlite"


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build an OpenAI chat JSONL from the lyric catalog.")
    parser.add_argument("--mode", required=True, choices=("50k_sample", "full"))
    parser.add_argument("--fim", type=float, default=0.0)
    parser.add_argument("--variant", default="one_hot", choices=("one_hot", "systembrief"))
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--catalog", type=Path, default=None)
    parser.add_argument("--seed", type=int, default=None)
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    catalog = args.catalog if args.catalog is not None else default_catalog()
    seed = voice_dataset.resolve_seed(args.seed)
    records = voice_dataset.build(
        catalog=catalog,
        mode=args.mode,
        variant=args.variant,
        fim_rate=args.fim,
        seed=seed,
    )
    voice_dataset.write_jsonl(records, args.out)
    size = args.out.stat().st_size
    briefs = voice_dataset.load_briefs() if args.variant == "systembrief" else None
    print(
        f"mode={args.mode} variant={args.variant} seed={seed} "
        f"bytes={size} {voice_dataset.summarize(records, briefs)}"
    )
    print(args.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
