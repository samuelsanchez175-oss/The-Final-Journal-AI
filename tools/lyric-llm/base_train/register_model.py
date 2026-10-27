#!/usr/bin/env python3
"""Generic fine-tune registration + winner marking for model_registry.json.

Handles all three Grok experiments uniformly:
  - dataset_size (Grok #1): aliases v5-base-mini-50k, v5-base-mini-full
  - voice_conditioning (Grok #2): aliases v5-base-mini-one-hot, v5-base-mini-systembrief
  - combined_production (Grok #3): any alias

Writes to tools/lyric-llm/model_registry.json. Appends models.<alias>.
Marks winner by setting status="winner" and clearing status on prior winners
in the same experiment (one winner per experiment).

Usage:
  python3 base_train/register_model.py add \
      --trained-by grok#1 --alias v5-base-mini-50k \
      --experiment dataset_size --variant 50k_sample \
      --openai-id "ft:gpt-4o-mini:pennworkstudios:v5-base-mini-50k:abc" \
      --job-id ftjob-abc --training-file out/train_50k_fim.jsonl \
      --validation-file out/val_50k_fim.jsonl --n-examples 50000 \
      --fim-share 0.2

  python3 base_train/register_model.py mark-winner \
      --experiment dataset_size --alias v5-base-mini-50k

  python3 base_train/register_model.py list
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

REGISTRY = Path(__file__).resolve().parent.parent / "model_registry.json"
EXPECTED_SEED = 7
VALID_EXPERIMENTS = {"dataset_size", "voice_conditioning", "combined_production"}
VALID_STATUSES = {"winner", "candidate", "regressed", "no_lift"}


def load(path: Path) -> dict:
    if not path.is_file():
        return {"schema_version": 1, "shared": {}, "models": {}}
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise SystemExit(f"{path} is not a JSON object")
    data.setdefault("models", {})
    data.setdefault("shared", {})
    if not isinstance(data["models"], dict) or not isinstance(data["shared"], dict):
        raise SystemExit(f"{path} has malformed models or shared block")
    return data


def save(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def _now() -> str:
    return datetime.now(ZoneInfo("America/New_York")).isoformat(timespec="seconds")


def add(args) -> int:
    if args.experiment not in VALID_EXPERIMENTS:
        raise SystemExit(f"experiment must be one of {sorted(VALID_EXPERIMENTS)}")
    if not args.model_id:
        raise SystemExit("--model-id (or --openai-id for backward compat) is required")
    if args.provider not in {"openai", "together", "anthropic", "xai"}:
        raise SystemExit("--provider must be one of openai|together|anthropic|xai")
    data = load(args.registry)
    models = data["models"]
    if args.alias in models:
        existing = models[args.alias]
        prior = existing.get("model_id") or existing.get("openai_id") or existing.get("together_id")
        if prior != args.model_id:
            raise SystemExit(f"alias {args.alias} already maps to {prior!r}")
        print(f"alias={args.alias} already present")
        return 0
    row = {
        "model_id": args.model_id,
        "provider": args.provider,
        "base_model": args.base_model,
        "trained_by": args.trained_by,
        "experiment": args.experiment,
        "variant": args.variant,
        "status": "candidate",
        "training_file": args.training_file,
        "validation_file": args.validation_file,
        "n_examples": args.n_examples,
        "n_epochs": args.n_epochs,
        "sample_seed": args.sample_seed,
        "fim_share": args.fim_share,
        "job_id": args.job_id,
        "trained_at": _now(),
        "cost_usd": None,
        "eval_report": None,
    }
    # Legacy field aliases kept for the earlier scripts
    if args.provider == "openai":
        row["openai_id"] = args.model_id
    elif args.provider == "together":
        row["together_id"] = args.model_id
    models[args.alias] = row
    save(args.registry, data)
    print(f"added alias={args.alias} provider={args.provider} status=candidate")
    return 0


def mark_winner(args) -> int:
    data = load(args.registry)
    models = data["models"]
    if args.alias not in models:
        raise SystemExit(f"alias {args.alias} not in registry")
    row = models[args.alias]
    if row.get("experiment") != args.experiment:
        raise SystemExit(
            f"alias {args.alias} experiment {row.get('experiment')!r} != {args.experiment!r}"
        )
    cleared = 0
    for other_alias, other in models.items():
        if other_alias == args.alias:
            continue
        if other.get("experiment") == args.experiment and other.get("status") == "winner":
            other["status"] = args.loser_status
            cleared += 1
    row["status"] = "winner"
    row["winner_at"] = _now()
    if args.eval_report:
        row["eval_report"] = args.eval_report
    save(args.registry, data)
    print(f"winner={args.alias} experiment={args.experiment} demoted={cleared}")
    return 0


def set_status(args) -> int:
    if args.status not in VALID_STATUSES:
        raise SystemExit(f"status must be one of {sorted(VALID_STATUSES)}")
    data = load(args.registry)
    models = data["models"]
    if args.alias not in models:
        raise SystemExit(f"alias {args.alias} not in registry")
    models[args.alias]["status"] = args.status
    save(args.registry, data)
    print(f"alias={args.alias} status={args.status}")
    return 0


def list_models(args) -> int:
    data = load(args.registry)
    models = data["models"]
    if not models:
        print("(registry has no models)")
        return 0
    rows = sorted(
        models.items(),
        key=lambda item: (item[1].get("experiment", ""), item[0]),
    )
    name_w = max(len(k) for k, _ in rows)
    for alias, meta in rows:
        print(
            f"{alias:<{name_w}}  "
            f"{meta.get('experiment','?'):<22}  "
            f"{meta.get('status','?'):<10}  "
            f"{meta.get('openai_id','?')}"
        )
    return 0


def winners(args) -> int:
    """Print one line per experiment: experiment=... alias=... openai_id=...

    Exits 1 if any experiment has no winner (useful for CI gates like Grok #3's C1).
    """
    data = load(args.registry)
    models = data["models"]
    found = {}
    for alias, meta in models.items():
        if meta.get("status") == "winner":
            exp = meta.get("experiment")
            if exp in found:
                print(f"duplicate winner for {exp}: {found[exp]!r} and {alias!r}", file=sys.stderr)
                return 2
            found[exp] = alias
    required = args.require.split(",") if args.require else []
    missing = [exp for exp in required if exp not in found]
    for exp in sorted(set(found) | set(required)):
        alias = found.get(exp)
        if alias is None:
            print(f"experiment={exp} alias=(none) openai_id=(none)")
        else:
            meta = models[alias]
            print(f"experiment={exp} alias={alias} openai_id={meta.get('openai_id')}")
    if missing:
        print(f"missing winners: {missing}", file=sys.stderr)
        return 1
    return 0


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Model registry writer.")
    p.add_argument("--registry", type=Path, default=REGISTRY)
    sub = p.add_subparsers(dest="cmd", required=True)

    pa = sub.add_parser("add", help="Append a new fine-tune row.")
    pa.add_argument("--trained-by", required=True)
    pa.add_argument("--alias", required=True)
    pa.add_argument("--experiment", required=True)
    pa.add_argument("--variant", required=True)
    pa.add_argument("--model-id", "--openai-id", "--together-id", "--xai-id", dest="model_id",
                    help="Provider-returned model identifier.")
    pa.add_argument("--provider", default="together", choices=["openai", "together", "anthropic", "xai"])
    pa.add_argument("--job-id", required=True)
    pa.add_argument("--training-file", required=True)
    pa.add_argument("--validation-file", required=True)
    pa.add_argument("--n-examples", type=int, required=True)
    pa.add_argument("--n-epochs", type=int, default=3)
    pa.add_argument("--sample-seed", type=int, default=EXPECTED_SEED)
    pa.add_argument("--fim-share", type=float, required=True)
    pa.add_argument("--base-model", default="meta-llama/Meta-Llama-3.1-8B-Instruct-Reference")
    pa.set_defaults(func=add)

    pw = sub.add_parser("mark-winner", help="Promote one alias to winner.")
    pw.add_argument("--alias", required=True)
    pw.add_argument("--experiment", required=True)
    pw.add_argument("--eval-report")
    pw.add_argument("--loser-status", default="regressed", choices=sorted(VALID_STATUSES))
    pw.set_defaults(func=mark_winner)

    ps = sub.add_parser("set-status")
    ps.add_argument("--alias", required=True)
    ps.add_argument("--status", required=True)
    ps.set_defaults(func=set_status)

    pl = sub.add_parser("list")
    pl.set_defaults(func=list_models)

    pwin = sub.add_parser("winners", help="Report winners; exit 1 if any required experiment lacks one.")
    pwin.add_argument("--require", help="Comma-separated experiments that must have a winner.")
    pwin.set_defaults(func=winners)

    args = p.parse_args(argv)
    return int(args.func(args) or 0)


if __name__ == "__main__":
    raise SystemExit(main())
