#!/usr/bin/env python3
"""Together.ai fine-tune shim: raw requests, no SDK.

Verified endpoints:
  POST /v1/files           -> upload (SDK handles signed URL; we use SDK for this one)
  POST /v1/fine-tunes      -> create job
  GET  /v1/fine-tunes/{id} -> retrieve
  DELETE /v1/files/{id}    -> delete file

Subcommands kept identical to the earlier version so train_together.sh
stays untouched:

  files.create / files.delete / fine_tunes.create / fine_tunes.retrieve
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

try:
    from together import Together
except ImportError:
    Together = None

BASE_URL = os.environ.get("TOGETHER_BASE_URL", "https://api.together.ai/v1")


def _key() -> str:
    k = os.environ.get("TOGETHER_API_KEY")
    if not k:
        print(json.dumps({"error": "TOGETHER_API_KEY is not set"}))
        sys.exit(2)
    return k


def _headers() -> dict:
    return {"Authorization": f"Bearer {_key()}"}


def _print(resp: "requests.Response") -> int:
    try:
        body = resp.json()
    except Exception:
        body = {"status_code": resp.status_code, "text": resp.text[:500]}
    print(json.dumps(body, default=str))
    return 0 if resp.ok else 1


def files_create(args: list[str]) -> int:
    """Use official SDK for upload — Together has a signed-URL flow raw curl can't do."""
    p = argparse.ArgumentParser(prog="together files.create")
    p.add_argument("-f", "--file", required=True, dest="path")
    p.add_argument("-p", "--purpose", default="fine-tune")
    ns = p.parse_args(args)
    path = Path(ns.path)
    if not path.is_file():
        print(json.dumps({"error": f"file not found: {ns.path}"}))
        return 2
    if Together is None:
        print(json.dumps({"error": "together SDK required for file upload. uv pip install together"}))
        return 2
    c = Together()  # upload does not need project_id
    resp = c.files.upload(str(path), check=True)
    if hasattr(resp, "model_dump"):
        print(json.dumps(resp.model_dump(), default=str))
    else:
        print(json.dumps(resp, default=str))
    return 0


def fine_tunes_create(args: list[str]) -> int:
    p = argparse.ArgumentParser(prog="together fine_tunes.create")
    p.add_argument("-t", "--training-file", required=True)
    p.add_argument("-v", "--validation-file", required=False, default=None)
    p.add_argument("-m", "--model", required=True)
    p.add_argument("--n-epochs", type=int, default=3)
    p.add_argument("--suffix", default=None)
    p.add_argument("--learning-rate", type=float, default=1e-5)
    p.add_argument("--batch-size", type=int, default=8)
    p.add_argument("--lora", action="store_true")
    p.add_argument("--lora-r", type=int, default=16)
    p.add_argument("--lora-alpha", type=int, default=32)
    p.add_argument("--lora-dropout", type=float, default=0.05)
    p.add_argument("--lora-trainable", default="all-linear")
    ns = p.parse_args(args)
    body = {
        "training_file": ns.training_file,
        "model": ns.model,
        "n_epochs": ns.n_epochs,
        "learning_rate": ns.learning_rate,
        "batch_size": ns.batch_size,
        "n_checkpoints": 1,
        "n_evals": 1,
    }
    if ns.validation_file:
        body["validation_file"] = ns.validation_file
    if ns.suffix:
        body["suffix"] = ns.suffix
    if ns.lora:
        body["training_type"] = {
            "type": "Lora",
            "lora_r": ns.lora_r,
            "lora_alpha": ns.lora_alpha,
            "lora_dropout": ns.lora_dropout,
            "lora_trainable_modules": ns.lora_trainable,
        }
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
        print("together-shim 0.3")
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
