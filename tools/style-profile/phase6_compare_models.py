#!/usr/bin/env python3
"""Send one identical verse prompt to several models and render the side-by-side page.

Every model gets the same real-lyric exemplars, topic and rhyme scheme, so differences come
from the model alone. Writes out/model_comparison.json and embeds it into model_comparison.html.

Usage:
  python3 tools/style-profile/phase6_compare_models.py --artist "Gunna" --bars 4
  python3 tools/style-profile/phase6_compare_models.py --artist "Gunna" --topic money_flex --scheme abab --seed 3
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

HERE = Path(__file__).resolve().parent
PAGE = HERE / "model_comparison.html"
DATA_START, DATA_END = "/*DATA_START*/", "/*DATA_END*/"


def embed(page: Path, data: dict) -> None:
    html = page.read_text(encoding="utf-8")
    a, b = html.index(DATA_START) + len(DATA_START), html.index(DATA_END)
    blob = json.dumps(data, ensure_ascii=False).replace("</", "<\\/")
    page.write_text(html[:a] + blob + html[b:], encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--artist", required=True)
    ap.add_argument("--bars", type=int, default=4)
    ap.add_argument("--models", default=",".join(gen.MODELS))
    ap.add_argument("--topic")
    ap.add_argument("--scheme", default="aabb", choices=gen.SCHEMES)
    ap.add_argument("--mode", default="rewrite", choices=gen.MODES)
    ap.add_argument("--seed", type=int)
    ap.add_argument("--out", type=Path, default=gen.OUT / "model_comparison.json")
    args = ap.parse_args()
    models = [m.strip() for m in args.models.split(",") if m.strip()]

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
