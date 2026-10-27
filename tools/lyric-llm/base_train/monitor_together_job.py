#!/usr/bin/env python3
"""Poll a Together.ai fine-tune job every 60s. Log transitions + exit when done.

Usage:
  TOGETHER_API_KEY=... python3 base_train/monitor_together_job.py \
      --job-id ft-a2211706-c2ae \
      --alias v5-base-50k \
      --experiment dataset_size --variant 50k_sample \
      --log out/together_logs/50k.jsonl
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import requests

BASE_URL = os.environ.get("TOGETHER_BASE_URL", "https://api.together.ai/v1")
POLL = int(os.environ.get("POLL_SECONDS", "60"))
TERMINAL = {"completed", "succeeded", "failed", "cancelled", "error"}


def _headers() -> dict:
    k = os.environ.get("TOGETHER_API_KEY")
    if not k:
        print("TOGETHER_API_KEY unset", file=sys.stderr)
        sys.exit(2)
    return {"Authorization": f"Bearer {k}"}


def now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def log_row(path: Path, row: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(row) + "\n")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--job-id", required=True)
    p.add_argument("--alias", required=True)
    p.add_argument("--experiment", required=True)
    p.add_argument("--variant", required=True)
    p.add_argument("--log", required=True)
    ns = p.parse_args()
    log_path = Path(ns.log)
    last_status = None
    while True:
        try:
            r = requests.get(f"{BASE_URL}/fine-tunes/{ns.job_id}", headers=_headers(), timeout=60)
            if not r.ok:
                log_row(log_path, {"ts": now(), "event": "poll_error", "status_code": r.status_code, "text": r.text[:200]})
                time.sleep(POLL)
                continue
            data = r.json()
            status = data.get("status", "unknown")
            price = data.get("total_price")
            tokens = data.get("token_count")
            progress = data.get("progress")
            if status != last_status:
                log_row(log_path, {
                    "ts": now(), "event": "status", "job_id": ns.job_id,
                    "status": status, "progress": progress,
                    "total_price": price, "token_count": tokens,
                })
                print(f"[{now()}] {ns.job_id} {status} price=${price} tokens={tokens} progress={progress}", flush=True)
                last_status = status
            if status.lower() in TERMINAL:
                model_id = (
                    data.get("api_model_object_name")
                    or data.get("x_model_output_name")
                    or data.get("output_name")
                    or data.get("model_output_name")
                    or data.get("fine_tuned_model")
                )
                log_row(log_path, {
                    "ts": now(), "event": "done", "job_id": ns.job_id,
                    "model_id": model_id, "alias": ns.alias,
                    "experiment": ns.experiment, "variant": ns.variant,
                    "status": status, "total_price": price,
                    "token_count": tokens,
                })
                print(f"TERMINAL: {status} model_id={model_id}")
                return 0 if status.lower() in ("completed", "succeeded") else 1
        except requests.RequestException as exc:
            log_row(log_path, {"ts": now(), "event": "transport_error", "err": str(exc)[:200]})
        time.sleep(POLL)


if __name__ == "__main__":
    raise SystemExit(main())
