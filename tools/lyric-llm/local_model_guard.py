#!/usr/bin/env python3
"""Fail new local-model imports (Appendix A T9).

Local QLoRA stays shelved. A new file in the diff may not import mlx,
transformers, or torch, and may not name AutoModelForCausalLM or AutoTokenizer.
Historical files stay on the whitelist. torch is checked only under tools/lyric-llm/.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Optional

WHITELIST = {
    "train.py",
    "prep.py",
    "infer.py",
    "generate.py",
    "test_pipeline.py",
    "test_train_setup.py",
    "evaluate.py",
}

_MLX = re.compile(r"(?m)^\s*(?:import\s+mlx\b|from\s+mlx\b)")
_TRANSFORMERS = re.compile(r"(?m)^\s*(?:import\s+transformers\b|from\s+transformers\b)")
_TORCH = re.compile(r"(?m)^\s*(?:import\s+torch\b|from\s+torch\b)")
_AUTO = re.compile(r"\bAutoModelForCausalLM\b|\bAutoTokenizer\b")


def _skip_path(path: str) -> bool:
    parts = Path(path).parts
    if ".venv" in parts or "site-packages" in parts:
        return True
    norm = path.replace("\\", "/")
    if "/out/" in f"/{norm}" or norm.startswith("out/"):
        return True
    if "adapters" in parts:
        return True
    return False


def find_forbidden(path: str, text: str) -> list[str]:
    """Return the forbidden import names in text. Empty when the file is allowed."""
    if _skip_path(path):
        return []
    if Path(path).name in WHITELIST:
        return []
    found: list[str] = []
    if _MLX.search(text):
        found.append("mlx")
    if _TRANSFORMERS.search(text):
        found.append("transformers")
    norm = path.replace("\\", "/")
    under_lyric = "tools/lyric-llm/" in f"/{norm}" or norm.startswith("tools/lyric-llm/")
    if under_lyric and _TORCH.search(text):
        found.append("torch")
    if _AUTO.search(text):
        found.append("AutoModelForCausalLM/AutoTokenizer")
    return found


def _diff_text(base: str) -> str:
    commands = [
        ["git", "diff", "-U0", "--no-color", f"{base}...HEAD"],
        ["git", "diff", "-U0", "--no-color", base, "HEAD"],
    ]
    last_err = ""
    for cmd in commands:
        proc = subprocess.run(cmd, capture_output=True, text=True)
        if proc.returncode == 0:
            return proc.stdout
        last_err = (proc.stderr or proc.stdout or "git diff failed").strip()
    raise RuntimeError(last_err or "git diff failed")


def added_text_by_path(diff: str) -> dict[str, str]:
    """Map each file in a unified diff to the lines that were added."""
    current = ""
    buckets: dict[str, list[str]] = {}
    for line in diff.splitlines():
        if line.startswith("+++ b/"):
            current = line[6:]
            buckets.setdefault(current, [])
            continue
        if line.startswith("+++ /dev/null"):
            current = ""
            continue
        if current and line.startswith("+") and not line.startswith("+++"):
            buckets[current].append(line[1:])
    return {path: "\n".join(lines) for path, lines in buckets.items() if path}


def scan_added(added: dict[str, str]) -> list[tuple[str, list[str]]]:
    bad: list[tuple[str, list[str]]] = []
    for path, text in added.items():
        found = find_forbidden(path, text)
        if found:
            bad.append((path, found))
    return bad


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Reject new mlx, transformers, and torch imports.")
    parser.add_argument("--files", nargs="*", default=None, help="Treat these paths as new files and scan them whole.")
    parser.add_argument("--base", default=os.environ.get("V4_GUARD_BASE", "origin/main"))
    args = parser.parse_args(argv)

    if args.files is not None:
        bad: list[tuple[str, list[str]]] = []
        for raw in args.files:
            path = Path(raw)
            text = path.read_text(encoding="utf-8", errors="replace") if path.is_file() else ""
            found = find_forbidden(str(path), text)
            if found:
                bad.append((str(path), found))
    else:
        try:
            added = added_text_by_path(_diff_text(args.base))
        except RuntimeError as exc:
            print(f"local model guard: {exc}", file=sys.stderr)
            return 1
        bad = scan_added(added)

    if not bad:
        print("local model guard: clean")
        return 0
    print("local model guard: new local-model import:", file=sys.stderr)
    for path, found in bad:
        print(f"{path}: {', '.join(found)}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
