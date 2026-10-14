#!/usr/bin/env python3
"""Send one identical verse prompt to several models and render the side-by-side page.

Every model gets the same real-lyric exemplars, topic and rhyme scheme, so differences come
from the model alone. Writes out/model_comparison.json and embeds it into model_comparison.html.

Usage:
  python3 tools/style-profile/phase6_compare_models.py --artist "Gunna" --bars 4
  python3 tools/style-profile/phase6_compare_models.py --artist "Gunna" --topic money_flex --scheme abab --seed 3
  python3 tools/style-profile/phase6_compare_models.py --artist "Gunna" --mode mimic --bars 8 --candidates 8
"""

from __future__ import annotations

import argparse
import json
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import phase1_song_metrics as p1
import phase6_generate as gen
import feedback_store
import anchor_lib
import gunna_score

HERE = Path(__file__).resolve().parent
PAGE = HERE / "model_comparison.html"
DATA_START, DATA_END = "/*DATA_START*/", "/*DATA_END*/"


def embed(page: Path, data: dict) -> None:
    html = page.read_text(encoding="utf-8")
    a, b = html.index(DATA_START) + len(DATA_START), html.index(DATA_END)
    blob = json.dumps(data, ensure_ascii=False).replace("</", "<\\/")
    page.write_text(html[:a] + blob + html[b:], encoding="utf-8")


def _compare_mimic(args, models: list[str]) -> int:
    """Each model generates its own best-of-N. Candidate i sees the same examples on every model."""
    if args.artist.lower() != "gunna":
        raise SystemExit("mimic mode is built for Gunna and the anchor set")
    if args.bars not in gen.MIMIC_BARS:
        raise SystemExit("--bars for mimic must be 4, 8, or 16")
    if not 0.0 <= args.closeness <= 1.0:
        raise SystemExit("--closeness must be between 0 and 1")
    profile = gunna_score.load_profile(args.profile)
    calls = len(models) * args.candidates * gen.MIMIC_ATTEMPTS
    print(
        f"mimic compare: {len(models)} models x {args.candidates} candidates, up to {calls} claude calls. "
        "This does not overwrite model_comparison.json and does not embed into the HTML.",
        file=sys.stderr,
    )
    gunna = anchor_lib.load_gunna(p1.DEFAULT_CSV)
    matched, missing = anchor_lib.match_anchors(gunna)
    if missing:
        raise SystemExit("anchor titles not in the CSV: " + ", ".join(missing))
    lex = p1.Lexicon(p1.load_cmudict(p1.DEFAULT_CMU))
    corpus = gen.Corpus(args.artist, lex, songs=anchor_lib.copy_songs(gunna))
    skip = anchor_lib.shared_long_line_keys(gunna)
    ctx = gen.build_mimic_context(
        args.artist, args.bars, args.seed, args.closeness, profile, matched, skip_keys=skip)
    store = feedback_store.FeedbackStore(str(gen.OUT / "feedback.db"))
    models_out = {}
    all_candidates = {}
    for model in models:
        print(f"{model}:", file=sys.stderr)
        packed = gen.run_mimic(ctx, model, corpus, profile, args.candidates)
        ids = {
            "winner": gen.log_mimic_result(store, ctx, packed["winner"]),
            "runner": gen.log_mimic_result(store, ctx, packed["runner_up"]) if packed["runner_up"] else None,
        }
        document = gen.mimic_document(ctx, model, packed, ids)
        for key, row in document["models"].items():
            models_out[key] = row
        all_candidates[model] = document["candidates"]
        if packed["all_identical"]:
            print(f"  {model}: every candidate was the same verse", file=sys.stderr)
    cadence = profile.get("cadence") or {}
    data = {
        "schema": gen.SCHEMA_VERSION,
        "prompt_version": gen.MIMIC_PROMPT_VERSION,
        "artist": args.artist,
        "bars_requested": args.bars,
        "topic": "mimic",
        "topic_brief": "unreleased outtake from the anchor songs",
        "scheme": "anchor",
        "syl_range": [cadence.get("syl_p10"), cadence.get("syl_p90")],
        "seed": args.seed,
        "mode": "mimic",
        "closeness": args.closeness,
        "exemplars": ctx["exemplars"],
        "couplets": [],
        "models": models_out,
        "candidates": all_candidates,
    }
    args.out.write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"wrote {args.out}", file=sys.stderr)
    print("Drop that file on the rating page. The two cards per model are the top scores.", file=sys.stderr)
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--artist", required=True)
    ap.add_argument("--bars", type=int, default=4)
    ap.add_argument("--models", default=",".join(gen.MODELS))
    ap.add_argument("--topic")
    ap.add_argument("--scheme", default="aabb", choices=gen.SCHEMES)
    ap.add_argument("--mode", default="rewrite", choices=gen.MODES)
    ap.add_argument("--closeness", type=float, default=0.7, help="mimic only")
    ap.add_argument("--candidates", type=int, default=8, help="mimic only")
    ap.add_argument("--profile", type=Path, default=gen.OUT / "anchor_profile_gunna.json")
    ap.add_argument("--seed", type=int)
    default_out = gen.OUT / "model_comparison.json"
    ap.add_argument("--out", type=Path, default=default_out)
    args = ap.parse_args()
    models = [m.strip() for m in args.models.split(",") if m.strip()]
    if args.mode == "mimic":
        if args.out == default_out:
            args.out = gen.OUT / "mimic_comparison.json"
        return _compare_mimic(args, models)

    lex = p1.Lexicon(p1.load_cmudict(p1.DEFAULT_CMU))
    corpus = gen.Corpus(args.artist, lex)
    ctx = gen.build_context(args.artist, args.bars, args.topic, args.scheme, args.seed, corpus, args.mode)
    print(f"{args.artist}: {args.bars} bars, topic={ctx['topic']}, scheme={ctx['scheme'].upper()}, "
          f"mode={ctx['mode']}, {len(ctx['exemplars'])} real passages, {len(ctx['couplets'])} source couplets, "
          f"{len(ctx['taste']['liked'])} liked / {len(ctx['taste']['disliked'])} rejected bars in prompt", file=sys.stderr)

    with ThreadPoolExecutor(len(models)) as pool:
        results = dict(zip(models, pool.map(lambda m: gen.run_model(ctx, m, corpus), models)))

    store = feedback_store.FeedbackStore(str(gen.OUT / "feedback.db"))
    catalog = gen.load_blocks_catalog()
    for m, r in results.items():
        r["generation_id"] = gen.log_result(store, ctx, r, catalog)
        status = "pass" if r["passed"] else f"{len(r['problems'])} problems"
        print(f"  {m}: {status}, {len(r['attempts'])} attempt(s), {r['elapsed_s']}s", file=sys.stderr)

    data = {
        "schema": gen.SCHEMA_VERSION, "prompt_version": gen.PROMPT_VERSION,
        "artist": args.artist, "bars_requested": args.bars, "topic": ctx["topic"],
        "topic_brief": gen.TOPIC_BRIEF.get(ctx["topic"], ctx["topic"]), "scheme": ctx["scheme"],
        "syl_range": [gen.SYL_MIN, gen.SYL_MAX], "seed": args.seed, "mode": ctx["mode"],
        "exemplars": [{**c, "topic": "source couplet"} for c in ctx["couplets"]] + ctx["exemplars"],
        "couplets": ctx["couplets"], "models": results,
    }
    args.out.write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding="utf-8")
    embed(PAGE, data)
    print(f"wrote {args.out} and embedded into {PAGE}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
