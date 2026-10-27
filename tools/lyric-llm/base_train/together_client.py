#!/usr/bin/env python3
"""Minimal Together.ai fine-tune client. Mirrors the three OpenAI shim
subcommands used by the train scripts so the pipeline can keep its shape:

  files.create        -> POST /v1/files (multipart upload)
  fine_tunes.create   -> POST /v1/fine-tunes
  fine_tunes.retrieve -> GET /v1/fine-tunes/{id}
  files.delete        -> DELETE /v1/files/{id}

All responses print as JSON on stdout so train.sh's jq pipeline is reusable.
Reads TOGETHER_API_KEY from env. Never logs the key.

Default fine-tune base: meta-llama/Meta-Llama-3.1-8B-Instruct-Reference
  Cheap ($0.80/1M tokens train), instruction-tuned, OpenAI-compatible chat
  shape so our existing JSONLs load without conversion.

For the Grok #3 combined final, swap to:
  meta-llama/Meta-Llama-3.1-70B-Instruct-Reference (~$3/1M tokens)
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    print(json.dumps({"error": "requests not installed. uv pip install requests"}))
    sys.exit(2)

BASE_URL = os.environ.get("TOGETHER_BASE_URL", "https://api.together.xyz/v1")


def _key() -> str:
    key = os.environ.get("TOGETHER_API_KEY")
    if not key:
        print(json.dumps({"error": "TOGETHER_API_KEY is not set"}))
        sys.exit(2)
    return key


def _headers() -> dict:
    return {"Authorization": f"Bearer {_key()}"}


def _print(resp: "requests.Response") -> int:
    try:
        body = resp.json()
    except Exception:
        body = {"status_code": resp.status_code, "text": resp.text[:500]}
    print(json.dumps(body))
    return 0 if resp.ok else 1


def files_create(args: list[str]) -> int:
    """Upload a training file. Together.ai accepts JSONL with openai chat shape."""
    p = argparse.ArgumentParser(prog="together files.create")
    p.add_argument("-f", "--file", required=True, dest="path")
    p.add_argument("-p", "--purpose", default="fine-tune")
    ns = p.parse_args(args)
    path = Path(ns.path)
    if not path.is_file():
        print(json.dumps({"error": f"file not found: {ns.path}"}))
        return 2
    with path.open("rb") as fh:
        resp = requests.post(
            f"{BASE_URL}/files",
            headers=_headers(),
            files={"file": (path.name, fh, "application/jsonl")},
            data={"purpose": ns.purpose},
            timeout=600,
        )
    return _print(resp)


def fine_tunes_create(args: list[str]) -> int:
    """Create a fine-tune job. Together's /v1/fine-tunes shape:
        {
          "training_file": "file-...",
          "validation_file": "file-...",
          "model": "meta-llama/Meta-Llama-3.1-8B-Instruct-Reference",
          "n_epochs": 3,
          "suffix": "v5-base-mini-50k",
          "batch_size": "max",
          "learning_rate": 1e-5
        }
    """
    p = argparse.ArgumentParser(prog="together fine_tunes.create")
    p.add_argument("-t", "--training-file", required=True)
    p.add_argument("-v", "--validation-file", required=False, default=None)
    p.add_argument("-m", "--model", required=True)
    p.add_argument("--n-epochs", type=int, default=3)
    p.add_argument("--suffix", default=None)
    p.add_argument("--batch-size", default="max")
    p.add_argument("--learning-rate", type=float, default=1e-5)
    p.add_argument("--lora", action="store_true", help="LoRA adapter (cheaper, faster).")
    ns = p.parse_args(args)
    body = {
        "training_file": ns.training_file,
        "model": ns.model,
        "n_epochs": ns.n_epochs,
        "batch_size": ns.batch_size,
        "learning_rate": ns.learning_rate,
    }
    if ns.validation_file:
        body["validation_file"] = ns.validation_file
    if ns.suffix:
        body["suffix"] = ns.suffix
    if ns.lora:
        body["training_type"] = {"type": "Lora"}
    resp = requests.post(
        f"{BASE_URL}/fine-tunes",
        headers={**_headers(), "Content-Type": "application/json"},
        json=body,
        timeout=120,
    )
    return _print(resp)


def fine_tunes_retrieve(args: list[str]) -> int:
    if len(args) != 1:
        print(json.dumps({"error": "usage: fine_tunes.retrieve JOB_ID"}))
        return 2
    resp = requests.get(f"{BASE_URL}/fine-tunes/{args[0]}", headers=_headers(), timeout=60)
    return _print(resp)


def files_delete(args: list[str]) -> int:
    if len(args) != 1:
        print(json.dumps({"error": "usage: files.delete FILE_ID"}))
        return 2
    resp = requests.delete(f"{BASE_URL}/files/{args[0]}", headers=_headers(), timeout=60)
    return _print(resp)


COMMANDS = {
    "files.create": files_create,
    "files.delete": files_delete,
    "fine_tunes.create": fine_tunes_create,
    "fine_tunes.retrieve": fine_tunes_retrieve,
}


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if argv == ["--version"]:
        print("together-cli-shim 0.1")
        return 0
    if not argv or argv[0] not in {"api"}:
        print(json.dumps({"error": f"usage: together api <command> ... (got {argv!r})"}))
        return 2
    if len(argv) < 2:
        print(json.dumps({"error": "missing api subcommand"}))
        return 2
    cmd, *rest = argv[1:]
    handler = COMMANDS.get(cmd)
    if handler is None:
        print(json.dumps({"error": f"unsupported: {cmd}; supported: {sorted(COMMANDS)}"}))
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
