#!/usr/bin/env python3
"""Append one voice fine-tune row to model_registry.json.

Grok #1 owns shared.sample_seed. This writer never sets that field.
It does not read or print an API key.
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

EXPECTED_SEED = 7


def registry_path(explicit: Path | None) -> Path:
    if explicit is not None:
        return explicit
    return Path(__file__).resolve().parent.parent / "model_registry.json"


def check_shared_seed(path: Path, expected: int = EXPECTED_SEED) -> str:
    """Print-ready seed line. Raises if the registry seed disagrees."""
    if not path.is_file():
        return f"sample_seed={expected} registry_sample_seed=absent"
    data = json.loads(path.read_text(encoding="utf-8"))
    shared = data.get("shared") if isinstance(data, dict) else None
    seed = shared.get("sample_seed") if isinstance(shared, dict) else None
    if seed is None:
        return f"sample_seed={expected} registry_sample_seed=absent"
    if int(seed) != expected:
        raise SystemExit(
            f"shared.sample_seed is {seed}; voice files were built with {expected}"
        )
    return f"sample_seed={expected} registry_sample_seed={int(seed)}"


def register(
    path: Path,
    alias: str,
    model_id: str,
    job_id: str,
    experiment: str,
    variant: str,
    training_file: str,
    validation_file: str,
    n_examples: int,
    n_epochs: int,
    sample_seed: int,
    fim_share: float,
) -> dict:
    if path.is_file():
        data = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            raise SystemExit(f"{path} is not a JSON object")
    else:
        data = {"models": {}, "shared": {}}
    models = data.get("models")
    if not isinstance(models, dict):
        data["models"] = {}
        models = data["models"]
    if not isinstance(data.get("shared"), dict):
        data["shared"] = {}
    existing = models.get(alias)
    if isinstance(existing, dict):
        if existing.get("openai_id") != model_id:
            raise SystemExit(
                f"alias {alias} already maps to {existing.get('openai_id')}"
            )
        return data
    trained_at = datetime.now(ZoneInfo("America/New_York")).isoformat(timespec="seconds")
    models[alias] = {
        "openai_id": model_id,
        "base_model": "gpt-4o-mini",
        "trained_by": "grok#2",
        "experiment": experiment,
        "variant": variant,
        "training_file": training_file,
        "validation_file": validation_file,
        "n_examples": n_examples,
        "n_epochs": n_epochs,
        "trained_at": trained_at,
        "sample_seed": sample_seed,
        "fim_share": fim_share,
        "job_id": job_id,
        "cost_usd": None,
        "eval_report": None,
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    return data


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Register a voice fine-tune alias.")
    parser.add_argument("--check-seed", type=int, default=None)
    parser.add_argument("--alias")
    parser.add_argument("--model-id")
    parser.add_argument("--job-id")
    parser.add_argument("--experiment")
    parser.add_argument("--variant")
    parser.add_argument("--training-file")
    parser.add_argument("--validation-file")
    parser.add_argument("--n-examples", type=int)
    parser.add_argument("--n-epochs", type=int, default=3)
    parser.add_argument("--sample-seed", type=int)
    parser.add_argument("--fim-share", type=float)
    parser.add_argument("--registry", type=Path, default=None)
    args = parser.parse_args(argv)
    path = registry_path(args.registry)
    if args.check_seed is not None:
        print(check_shared_seed(path, args.check_seed))
        return 0
    required = {
        "alias": args.alias,
        "model_id": args.model_id,
        "job_id": args.job_id,
        "experiment": args.experiment,
        "variant": args.variant,
        "training_file": args.training_file,
        "validation_file": args.validation_file,
        "n_examples": args.n_examples,
        "sample_seed": args.sample_seed,
        "fim_share": args.fim_share,
    }
    missing = [name for name, value in required.items() if value is None]
    if missing:
        print("missing " + ", ".join(missing), file=sys.stderr)
        return 2
    register(
        path,
        args.alias,
        args.model_id,
        args.job_id,
        args.experiment,
        args.variant,
        args.training_file,
        args.validation_file,
        args.n_examples,
        args.n_epochs,
        args.sample_seed,
        args.fim_share,
    )
    print(f"alias={args.alias} model={args.model_id}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
