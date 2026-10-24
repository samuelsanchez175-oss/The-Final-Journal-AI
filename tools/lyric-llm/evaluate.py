#!/usr/bin/env python3
"""Score the lyric model against held-out songs.

Perplexity is the prompt-masked loss on eight-line windows from out/test.jsonl.
Rhyme rate and flow are compared with the train-set BPM curve. Voice fidelity
is a stylometric distance to the named artist's held-out lines versus a random
artist's. Originality reports Hamming distance and does not print the training line.

  .venv/bin/python evaluate.py
  .venv/bin/python evaluate.py --corpus-only
"""

from __future__ import annotations

import argparse
import json
import math
import random
import sqlite3
import statistics
import sys
from collections import Counter
from pathlib import Path

from lyriclib import (
    SECTION_RE,
    bucket_bpm,
    control_prefix,
    estimate_syllables,
    flow_consistency,
    l2,
    load_cmudict,
    originality_score,
    read_json,
    rhyme_rate,
    stylometric,
    target_syllables,
    write_json,
)
from report import write_eval_report
from train import windows_for_record

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = HERE / "out"
CMU = ROOT / "XJournal AI" / "cmudict.txt"
MAX_SEQ = 384
PINS = ("Gunna", "Young Thug", "Young Stoner Life")
HELD_LINES = 80


def _as_ids(value) -> list[int]:
    if hasattr(value, "input_ids"):
        value = value.input_ids
    if hasattr(value, "ids"):
        value = value.ids
    return [int(item) for item in list(value)]


def _chat_tokens(tokenizer, messages: list[dict]) -> tuple[list[int], int]:
    """Token ids and the first completion index. Same mask as MLX chat training."""
    tokens = _as_ids(tokenizer.apply_chat_template(messages, return_dict=False))
    add_generation_prompt = messages[-1].get("role") == "assistant"
    offset = len(
        _as_ids(
            tokenizer.apply_chat_template(
                messages[:-1],
                add_generation_prompt=add_generation_prompt,
                return_dict=False,
            )
        )
    )
    return tokens, offset


def median_bpm_for(path: Path, artist: str):
    values = []
    if not path.exists():
        return None
    with path.open(encoding="utf-8") as handle:
        for raw in handle:
            raw = raw.strip()
            if not raw:
                continue
            record = json.loads(raw)
            if record.get("artist") != artist or record.get("bpm") is None:
                continue
            values.append(float(record["bpm"]))
    if not values:
        return None
    return float(statistics.median(values))


def load_heldout(path: Path) -> dict[str, dict]:
    """Held-out lyric lines and tempos per artist. Text stays in memory for scores only."""
    grouped: dict[str, dict] = {}
    with path.open(encoding="utf-8") as handle:
        for raw in handle:
            raw = raw.strip()
            if not raw:
                continue
            record = json.loads(raw)
            artist = record.get("artist") or ""
            if not artist:
                continue
            bucket = grouped.setdefault(
                artist, {"lines": [], "bpms": [], "scales": [], "songs": 0, "lyric_lines": 0}
            )
            bucket["songs"] += 1
            if record.get("bpm") is not None:
                bucket["bpms"].append(float(record["bpm"]))
            scale = record.get("scale")
            if scale is not None and str(scale).strip():
                bucket["scales"].append(str(scale).strip())
            for line in (record.get("text") or "").split("\n"):
                if not line.strip() or SECTION_RE.match(line.strip()):
                    continue
                bucket["lyric_lines"] += 1
                if len(bucket["lines"]) < HELD_LINES:
                    bucket["lines"].append(line)
    return grouped


def choose_voices(artists: dict, trials: int) -> list[str]:
    chosen = []
    for name in PINS:
        row = artists.get(name)
        if row and len(row["lines"]) >= 8:
            chosen.append(name)
    rest = [
        name
        for name, row in artists.items()
        if name not in chosen and len(row["lines"]) >= 40 and row["bpms"]
    ]
    rest.sort(key=lambda name: (-artists[name]["lyric_lines"], name))
    for name in rest:
        if len(chosen) >= trials:
            break
        chosen.append(name)
    return chosen[:trials]


def _pad_width(length: int) -> int:
    width = 64 * ((length + 63) // 64)
    return min(MAX_SEQ, max(64, width))


def batch_nll(model, rows: list[tuple]) -> tuple[float, float]:
    """Prompt-masked loss for windows padded to one shared width."""
    import mlx.core as mx
    import mlx.nn as nn

    width = len(rows[0][0])
    batch = mx.array([row[0] for row in rows])
    logits = model(batch[:, :-1])
    targets = batch[:, 1:]
    steps = mx.arange(1, targets.shape[1] + 1)
    masks = []
    for _padded, offset, length in rows:
        masks.append(mx.logical_and(steps >= offset, steps <= (length - 1)))
    mask = mx.stack(masks)
    losses = nn.losses.cross_entropy(logits, targets, reduction="none") * mask
    total = losses.astype(mx.float32).sum()
    count = mask.astype(mx.float32).sum()
    mx.eval(total, count)
    return float(total.item()), float(count.item())


def score_perplexity(model, tokenizer, path: Path) -> dict:
    songs = 0
    windows = 0
    skipped = 0
    buckets: dict[int, list] = {}
    with path.open(encoding="utf-8") as handle:
        for raw in handle:
            raw = raw.strip()
            if not raw:
                continue
            record = json.loads(raw)
            songs += 1
            for message in windows_for_record(record):
                ids, offset = _chat_tokens(tokenizer, message["messages"])
                trimmed = ids[:MAX_SEQ]
                length = len(trimmed)
                windows += 1
                if length < offset + 2:
                    skipped += 1
                    continue
                width = _pad_width(length)
                padded = trimmed + [0] * (width - length)
                buckets.setdefault(width, []).append((padded, offset, length))
    loss_sum = 0.0
    tokens = 0.0
    seen = 0
    for width in sorted(buckets):
        rows = buckets[width]
        for start in range(0, len(rows), 4):
            chunk = rows[start : start + 4]
            nll, count = batch_nll(model, chunk)
            if count <= 0:
                skipped += len(chunk)
                continue
            loss_sum += nll
            tokens += count
            seen += len(chunk)
            if seen // 200 != (seen - len(chunk)) // 200:
                mean = loss_sum / tokens if tokens else 0.0
                print(
                    "perplexity windows %d  tokens %d  loss %.4f"
                    % (seen, int(tokens), mean),
                    file=sys.stderr,
                    flush=True,
                )
    mean_loss = (loss_sum / tokens) if tokens else None
    ppl = math.exp(mean_loss) if mean_loss is not None else None
    return {
        "test_songs": songs,
        "test_windows": windows,
        "skipped_windows": skipped,
        "scored_tokens": int(tokens),
        "test_loss": None if mean_loss is None else round(mean_loss, 4),
        "perplexity": None if ppl is None else round(ppl, 2),
    }


def _mode(values: list[str]):
    if not values:
        return None
    return Counter(values).most_common(1)[0][0]


def voice_bpm(name: str, row: dict):
    """Held-out median BPM. A missing held-out tempo falls back to the train median."""
    if row["bpms"]:
        return float(statistics.median(row["bpms"])), "held-out songs"
    trained = median_bpm_for(OUT / "train.jsonl", name)
    if trained is not None:
        return trained, "train songs, because the held-out songs have no BPM"
    return None, "none"


def sample_voice(model, tokenizer, plan) -> list[str]:
    from infer import generate_mixed

    return generate_mixed(model, tokenizer, plan, {"title": plan["voice"], "share": 1.0})


def score_generation(name, bpm, bpm_source, scale, syl, bars_out, cmu, curve, artists, rng, conn, seed):
    hits = []
    for index, line in enumerate(bars_out, start=1):
        scored = originality_score(conn, line) if conn else None
        if scored:
            hits.append(
                {
                    "line": index,
                    "kind": scored["kind"],
                    "hamming": scored["hamming"],
                    "similarity": scored["similarity"],
                    "text": line,
                }
            )
    gen_stats = stylometric(bars_out, cmu) if bars_out else None
    target_stats = stylometric(artists[name]["lines"], cmu)
    pool = [
        other
        for other, row in artists.items()
        if other != name and len(row["lines"]) >= 40
    ]
    other_name = rng.choice(pool) if pool else None
    other_stats = stylometric(artists[other_name]["lines"], cmu) if other_name else None
    distance_voice = None
    distance_other = None
    closer = False
    if gen_stats and other_stats:
        distance_voice = l2(gen_stats, target_stats)
        distance_other = l2(gen_stats, other_stats)
        closer = distance_voice < distance_other
    bucket_key = None if bpm is None else bucket_bpm(bpm)
    bucket = {}
    if bucket_key is not None:
        bucket = curve.get("buckets", {}).get(str(bucket_key)) or {}
    rhyme = rhyme_rate(bars_out, cmu) if bars_out else None
    syls = [estimate_syllables(line) for line in bars_out]
    flow = flow_consistency(syls)
    mean_syl = statistics.fmean(syls) if syls else None
    return {
        "voice": name,
        "bpm": None if bpm is None else round(bpm, 1),
        "bpm_bucket": bucket_key,
        "bpm_source": bpm_source,
        "scale": scale,
        "seed": seed,
        "syl_target": syl,
        "lines": bars_out,
        "rhyme": None if rhyme is None else round(rhyme, 4),
        "corpus_rhyme": bucket.get("mean_rhyme_rate"),
        "mean_syl": None if mean_syl is None else round(mean_syl, 2),
        "flow": None if flow is None else round(flow, 4),
        "corpus_flow": bucket.get("mean_flow"),
        "corpus_median_syl": bucket.get("median_syl"),
        "closer": closer,
        "other_voice": other_name,
        "distance_voice": None if distance_voice is None else round(distance_voice, 4),
        "distance_other": None if distance_other is None else round(distance_other, 4),
        "flagged": len(hits),
        "hits": hits,
        "rhyme_note": "n/a"
        if rhyme is None or bucket.get("mean_rhyme_rate") is None
        else "%.2f vs %.2f" % (rhyme, bucket["mean_rhyme_rate"]),
        "flow_note": "n/a"
        if mean_syl is None
        else "mean syl %.1f vs bucket median %s, consistency %s vs bucket %.3f"
        % (
            mean_syl,
            bucket.get("median_syl", "n/a"),
            "n/a" if flow is None else "%.2f" % flow,
            bucket.get("mean_flow") or 0.0,
        ),
    }


def run_model(args, curve, cmu) -> dict:
    try:
        from mlx_lm import load
        from mlx_lm.utils import maybe_set_recommended_wired_limit
    except ImportError:
        return {"error": "mlx_lm is not installed."}
    adapter_file = args.adapter / "adapters.safetensors"
    adapter = args.adapter if adapter_file.exists() else None
    model, tokenizer = load(args.model, adapter_path=str(adapter) if adapter else None)
    maybe_set_recommended_wired_limit()
    print("scoring perplexity on held-out songs", file=sys.stderr, flush=True)
    perplexity = score_perplexity(model, tokenizer, OUT / "test.jsonl")
    artists = load_heldout(OUT / "test.jsonl")
    voices = choose_voices(artists, args.trials)
    if len(voices) < 2:
        perplexity["error"] = "Need at least two held-out artists with 8 lyric lines."
        return perplexity
    rng = random.Random(args.seed)
    conn = sqlite3.connect(OUT / "originality.sqlite") if (OUT / "originality.sqlite").exists() else None
    examples = []
    fidelity = []
    try:
        for name in voices:
            row = artists[name]
            bpm, bpm_source = voice_bpm(name, row)
            scale = _mode(row["scales"])
            syl = target_syllables(curve, bpm)
            prefix = control_prefix(name, bpm, scale, syl)
            for offset, counted in ((0, True), (1, False)):
                seed = args.seed + offset
                plan = {
                    "voice": name,
                    "left_prefix": prefix,
                    "right_prefix": prefix,
                    "seed_line": "",
                    "bars": args.bars,
                    "seed": seed,
                    "bpm": bpm,
                    "syl": syl,
                    "temperature": 0.9,
                    "top_p": 0.9,
                    "fit_syllables": False,
                }
                print("generating %s seed %d" % (name, seed), file=sys.stderr, flush=True)
                bars_out = sample_voice(model, tokenizer, plan)
                scored = score_generation(
                    name, bpm, bpm_source, scale, syl, bars_out, cmu, curve, artists, rng, conn, seed
                )
                scored["prefix"] = prefix
                scored["counted_for_fidelity"] = counted
                examples.append(scored)
                if counted:
                    fidelity.append(scored)
    finally:
        if conn:
            conn.close()
    rhymes = [row["rhyme"] for row in examples if row["rhyme"] is not None]
    flows = [row["flow"] for row in fidelity if row["flow"] is not None]
    hits = []
    for sample in examples:
        for hit in sample["hits"]:
            hits.append(
                {
                    "voice": sample["voice"],
                    "seed": sample["seed"],
                    "line": hit["line"],
                    "kind": hit["kind"],
                    "hamming": hit["hamming"],
                    "similarity": hit["similarity"],
                    "text": hit["text"],
                }
            )
    generated_lines = sum(len(sample["lines"]) for sample in examples)
    craft = (read_json(OUT / "baseline.json").get("global_craft") or {}) if (OUT / "baseline.json").exists() else {}
    return {
        "adapter": str(adapter) if adapter else "none",
        "model_id": args.model,
        "temperature": 0.9,
        "top_p": 0.9,
        "bars": args.bars,
        "corpus_rhyme": craft.get("mean_rhyme_rate"),
        "corpus_flow": craft.get("mean_flow"),
        "generated_rhyme": round(statistics.fmean(rhymes), 4) if rhymes else None,
        "generated_flow": round(statistics.fmean(flows), 4) if flows else None,
        "voice_passes": sum(1 for row in fidelity if row["closer"]),
        "voice_trials": len(fidelity),
        "flagged_lines": len(hits),
        "generated_lines": generated_lines,
        "trials": fidelity,
        "hits": hits,
        "examples": examples,
        **perplexity,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Evaluate the lyric model on held-out songs.")
    parser.add_argument("--corpus-only", action="store_true")
    parser.add_argument("--model", default="mlx-community/Qwen2.5-3B-Instruct-4bit")
    parser.add_argument("--adapter", type=Path, default=HERE / "adapters")
    parser.add_argument("--trials", type=int, default=5)
    parser.add_argument("--bars", type=int, default=8)
    parser.add_argument("--seed", type=int, default=7)
    args = parser.parse_args()
    baseline_path = OUT / "baseline.json"
    if not baseline_path.exists():
        print("Missing %s. Run prep.py first." % baseline_path, file=sys.stderr)
        return 1
    baseline = read_json(baseline_path)
    curve = read_json(OUT / "syllable_curve.json") if (OUT / "syllable_curve.json").exists() else baseline.get("curve") or {}
    model_section = None
    if not args.corpus_only:
        cmu = load_cmudict(CMU)
        model_section = run_model(args, curve, cmu)
        write_json(OUT / "model_scores.json", _public_scores(model_section))
    report_path = OUT / "eval_report.md"
    write_eval_report(report_path, baseline, model_section)
    print("wrote %s" % report_path)
    if model_section and model_section.get("error"):
        print(model_section["error"], file=sys.stderr)
        return 1
    return 0


def _public_scores(model: dict) -> dict:
    """Drop generated text from the JSON sidecar. The markdown report keeps the examples."""
    public = dict(model)
    public.pop("examples", None)
    public["hits"] = [
        {key: hit[key] for key in ("voice", "seed", "line", "kind", "hamming", "similarity")}
        for hit in model.get("hits") or []
    ]
    public["trials"] = [
        {key: row[key] for key in row if key != "lines" and key != "hits"}
        for row in model.get("trials") or []
    ]
    return public


if __name__ == "__main__":
    raise SystemExit(main())
