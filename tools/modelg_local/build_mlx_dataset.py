#!/usr/bin/env python3
"""
build_mlx_dataset.py
────────────────────
Adapt The Final Journal AI's training data into the on-disk layout that Apple's
MLX-LM LoRA trainer (`mlx_lm.lora`) expects: a directory containing
`train.jsonl` and `valid.jsonl`.

This lets you fine-tune Model G locally on an Apple-Silicon Mac — fully offline,
no OpenAI/cloud round-trip.

TWO INPUT MODES
───────────────
  1) From the OpenAI exporter output (default) — chat format, preserves the
     Model G system prompt baked in by export_genius_to_jsonl.py:
        python3 export_genius_to_jsonl.py            # makes rap_finetune_*.jsonl
        python3 tools/modelg_local/build_mlx_dataset.py \
            --input rap_finetune_training.jsonl rap_finetune_validation.jsonl \
            --out-dir tools/modelg_local/data
     -> writes {"messages": [...]} lines (MLX 'chat' format).

  2) From a rap_bars CSV (e.g. the tools/rap_dataset output) — groups bars into
     N-bar blocks and emits raw text for style LoRA:
        python3 tools/modelg_local/build_mlx_dataset.py \
            --from-csv "XJournal AI/rap_bars_from_spotify.csv" \
            --out-dir tools/modelg_local/data
     -> writes {"text": "<4 bars>"} lines (MLX 'text' format).

Then fine-tune (see README.md):
        mlx_lm.lora --config tools/modelg_local/mlx_lora_config.yaml

Stdlib only. Python 3.8+.
"""

import argparse
import csv
import glob
import json
import random
import sys
from pathlib import Path


# ─────────────────────────────────────────────────────────────────
# Mode 1: existing JSONL (chat / prompt-completion) -> MLX chat lines
# ─────────────────────────────────────────────────────────────────
def normalize_to_chat(obj):
    """Return a {'messages': [...]} dict, or None if unusable."""
    if "messages" in obj and isinstance(obj["messages"], list) and obj["messages"]:
        msgs = []
        for m in obj["messages"]:
            role = m.get("role")
            content = (m.get("content") or "").strip()
            if role in ("system", "user", "assistant") and content:
                msgs.append({"role": role, "content": content})
        # must contain at least a user turn and an assistant target
        roles = {m["role"] for m in msgs}
        if "assistant" in roles and ("user" in roles or "system" in roles):
            return {"messages": msgs}
        return None
    if "prompt" in obj and "completion" in obj:
        p, c = str(obj["prompt"]).strip(), str(obj["completion"]).strip()
        if p and c:
            return {"messages": [
                {"role": "user", "content": p},
                {"role": "assistant", "content": c},
            ]}
    if "text" in obj and str(obj["text"]).strip():
        return {"text": str(obj["text"]).strip()}
    return None


def load_jsonl_inputs(patterns):
    paths = []
    for pat in patterns:
        hits = glob.glob(pat)
        paths.extend(hits if hits else ([pat] if Path(pat).exists() else []))
    if not paths:
        print(f"✗ No input files matched: {patterns}")
        print("  Run export_genius_to_jsonl.py first, or pass --from-csv.")
        sys.exit(2)
    records = []
    for p in paths:
        n = 0
        with open(p, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    rec = normalize_to_chat(json.loads(line))
                except json.JSONDecodeError:
                    continue
                if rec:
                    records.append(rec)
                    n += 1
        print(f"  ✓ {p}: {n} usable examples")
    return records


# ─────────────────────────────────────────────────────────────────
# Mode 2: rap_bars CSV -> N-bar text blocks
# ─────────────────────────────────────────────────────────────────
def load_csv_blocks(csv_path, block_bars):
    csv.field_size_limit(min(sys.maxsize, 2**31 - 1))
    groups = {}      # (artist, song) -> list of (bar_index, line)
    order = []
    with open(csv_path, newline="", encoding="utf-8", errors="replace") as fh:
        reader = csv.DictReader(fh)
        text_col = next((c for c in reader.fieldnames
                         if c.lower() in ("text_bar_line", "text", "lyrics")), None)
        if text_col is None:
            print(f"✗ No text column in {csv_path}: {reader.fieldnames}")
            sys.exit(2)
        for row in reader:
            line = (row.get(text_col) or "").strip()
            if not line:
                continue
            key = (row.get("artist", ""), row.get("song", ""))
            if key not in groups:
                groups[key] = []
                order.append(key)
            try:
                bi = int(float(row.get("bar_index") or 0))
            except ValueError:
                bi = len(groups[key]) + 1
            groups[key].append((bi, line))
    records = []
    for key in order:
        bars = [ln for _, ln in sorted(groups[key], key=lambda t: t[0])]
        for i in range(0, len(bars) - block_bars + 1, block_bars):
            block = "\n".join(bars[i:i + block_bars])
            if len(block) >= 20:
                records.append({"text": block})
    print(f"  ✓ {csv_path}: {len(records)} {block_bars}-bar blocks "
          f"from {len(order)} songs")
    return records


# ─────────────────────────────────────────────────────────────────
def write_split(records, out_dir, val_split, seed):
    if not records:
        print("✗ 0 usable examples — nothing written."); sys.exit(2)
    rng = random.Random(seed)
    rng.shuffle(records)
    n_val = max(1, int(len(records) * val_split)) if len(records) >= 2 else 0
    valid = records[:n_val]
    train = records[n_val:] or records          # never leave train empty
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)

    def dump(path, rows):
        with open(path, "w", encoding="utf-8") as fh:
            for r in rows:
                fh.write(json.dumps(r, ensure_ascii=False) + "\n")

    dump(out / "train.jsonl", train)
    dump(out / "valid.jsonl", valid)
    fmt = "chat" if "messages" in records[0] else "text"
    print(f"\n✅ Wrote MLX '{fmt}' data to {out}/")
    print(f"   train.jsonl: {len(train)}   valid.jsonl: {len(valid)}")
    print(f"   sample: {json.dumps(records[0], ensure_ascii=False)[:160]}…")
    if len(train) < 50:
        print("   ⚠ <50 training examples — fine for a smoke test, thin for real "
              "LoRA. Add more bars/blocks before a serious run.")


def main():
    ap = argparse.ArgumentParser(description="Build MLX-LM LoRA data dir (train/valid.jsonl).")
    ap.add_argument("--input", nargs="*",
                    default=["rap_finetune_training.jsonl", "rap_finetune_validation.jsonl"],
                    help="JSONL file(s)/globs from export_genius_to_jsonl.py (chat or prompt/completion).")
    ap.add_argument("--from-csv", help="Build text blocks from a rap_bars CSV instead of JSONL.")
    ap.add_argument("--block-bars", type=int, default=4, help="Bars per text block in --from-csv mode.")
    ap.add_argument("--out-dir", default="tools/modelg_local/data", help="Output data directory.")
    ap.add_argument("--val-split", type=float, default=0.1, help="Validation fraction.")
    ap.add_argument("--seed", type=int, default=42, help="Shuffle seed (reproducible).")
    args = ap.parse_args()

    if args.from_csv:
        records = load_csv_blocks(args.from_csv, args.block_bars)
    else:
        records = load_jsonl_inputs(args.input)
    write_split(records, args.out_dir, args.val_split, args.seed)


if __name__ == "__main__":
    main()
