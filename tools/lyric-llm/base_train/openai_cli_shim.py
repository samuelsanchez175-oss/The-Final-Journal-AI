#!/usr/bin/env python3
"""Minimal shim replacing the legacy `openai` CLI for the base-llm train scripts.

OpenAI killed the CLI in openai>=2.x. The train scripts Grok wrote use three
commands; this shim recreates only those. All output is JSON on stdout so the
jq pipeline in train.sh stays verbatim.

Supported:
  openai api files.create -f PATH -p fine-tune
  openai api fine_tuning.jobs.create -t TRAIN_ID -v VAL_ID -m MODEL \
      --hyperparameters JSON --suffix NAME
  openai api fine_tuning.jobs.retrieve JOB_ID

API key comes from OPENAI_API_KEY. The shim never logs the key, never echoes
headers, and only ever prints the server JSON to stdout.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

try:
    from openai import OpenAI
except ImportError:
    print(json.dumps({"error": "openai>=1.0 python package not installed"}))
    sys.exit(2)


def _client() -> "OpenAI":
    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        print(json.dumps({"error": "OPENAI_API_KEY is not set"}))
        sys.exit(2)
    return OpenAI(api_key=key)


def _dump(obj) -> str:
    """SDK objects can be .model_dump()'d; fall back to .__dict__."""
    for name in ("model_dump", "to_dict"):
        fn = getattr(obj, name, None)
        if callable(fn):
            return json.dumps(fn(), default=str)
    try:
        return json.dumps(obj, default=lambda o: getattr(o, "__dict__", str(o)))
    except TypeError:
        return json.dumps(str(obj))


def files_create(args: list[str]) -> int:
    """openai api files.create -f PATH -p fine-tune"""
    p = argparse.ArgumentParser(prog="openai api files.create")
    p.add_argument("-f", "--file", required=True, dest="path")
    p.add_argument("-p", "--purpose", default="fine-tune")
    ns = p.parse_args(args)
    client = _client()
    path = Path(ns.path)
    if not path.is_file():
        print(json.dumps({"error": f"file not found: {ns.path}"}))
        return 2
    with path.open("rb") as fh:
        resp = client.files.create(file=fh, purpose=ns.purpose)
    print(_dump(resp))
    return 0


def fine_tuning_jobs_create(args: list[str]) -> int:
    """openai api fine_tuning.jobs.create -t ID -v ID -m MODEL
                                          --hyperparameters JSON --suffix NAME"""
    p = argparse.ArgumentParser(prog="openai api fine_tuning.jobs.create")
    p.add_argument("-t", "--training-file", required=True)
    p.add_argument("-v", "--validation-file", required=False, default=None)
    p.add_argument("-m", "--model", required=True)
    p.add_argument("--hyperparameters", default=None)
    p.add_argument("--suffix", default=None)
    ns = p.parse_args(args)
    client = _client()
    kwargs: dict = {
        "training_file": ns.training_file,
        "model": ns.model,
    }
    if ns.validation_file:
        kwargs["validation_file"] = ns.validation_file
    if ns.suffix:
        kwargs["suffix"] = ns.suffix
    if ns.hyperparameters:
        kwargs["hyperparameters"] = json.loads(ns.hyperparameters)
    resp = client.fine_tuning.jobs.create(**kwargs)
    print(_dump(resp))
    return 0


def fine_tuning_jobs_retrieve(args: list[str]) -> int:
    """openai api fine_tuning.jobs.retrieve JOB_ID"""
    if len(args) != 1:
        print(json.dumps({"error": "usage: fine_tuning.jobs.retrieve JOB_ID"}))
        return 2
    client = _client()
    resp = client.fine_tuning.jobs.retrieve(args[0])
    print(_dump(resp))
    return 0


COMMANDS = {
    "files.create": files_create,
    "fine_tuning.jobs.create": fine_tuning_jobs_create,
    "fine_tuning.jobs.retrieve": fine_tuning_jobs_retrieve,
}


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if not argv or argv[0] != "api":
        if argv == ["--version"]:
            print("openai-cli-shim 0.1")
            return 0
        print(json.dumps({"error": f"usage: openai api <command> ... (got {argv!r})"}))
        return 2
    if len(argv) < 2:
        print(json.dumps({"error": "missing api subcommand"}))
        return 2
    cmd, *rest = argv[1:]
    handler = COMMANDS.get(cmd)
    if handler is None:
        print(json.dumps({"error": f"unsupported command: {cmd}; supported: {sorted(COMMANDS)}"}))
        return 2
    try:
        return int(handler(rest) or 0)
    except SystemExit as exc:
        return int(exc.code or 0)
    except Exception as exc:
        print(json.dumps({"error": f"{type(exc).__name__}: {exc}"}))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
