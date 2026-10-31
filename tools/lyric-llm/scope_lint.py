#!/usr/bin/env python3
"""Fail v4 pull requests that touch the Swift app (Appendix A T8).

In scope when the branch matches antigravity/v4-* or the PR title contains v4.
A diff is then rejected if it touches:
  XJournal AI/            (includes ModelG/ and ModelYou/)
  The Final Journal AITests/
  any .xcodeproj/ path
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from typing import Optional

FORBIDDEN_PREFIXES = (
    "XJournal AI/",
    "The Final Journal AITests/",
)


def in_scope(branch: str, title: str) -> bool:
    branch = (branch or "").strip()
    if branch.startswith("refs/heads/"):
        branch = branch[len("refs/heads/") :]
    if branch.startswith("antigravity/v4-"):
        return True
    return "v4" in (title or "")


def is_forbidden(path: str) -> bool:
    norm = path.replace("\\", "/").lstrip("./")
    if any(norm.startswith(prefix) or f"/{prefix}" in f"/{norm}" for prefix in FORBIDDEN_PREFIXES):
        return True
    if ".xcodeproj/" in f"{norm}/" or norm.endswith(".xcodeproj"):
        return True
    return False


def lint_paths(paths: list[str], branch: str, title: str) -> tuple[int, list[str]]:
    if not in_scope(branch, title):
        return 0, []
    bad = [path for path in paths if path and is_forbidden(path)]
    return (1 if bad else 0), bad


def _branch_from_env(explicit: Optional[str]) -> str:
    if explicit:
        return explicit
    for key in ("GITHUB_HEAD_REF", "GITHUB_REF_NAME"):
        value = os.environ.get(key, "").strip()
        if value:
            return value
    proc = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"],
        capture_output=True,
        text=True,
    )
    if proc.returncode == 0:
        return proc.stdout.strip()
    return ""


def _title_from_env(explicit: Optional[str]) -> str:
    if explicit:
        return explicit
    return os.environ.get("V4_PR_TITLE", "") or os.environ.get("PR_TITLE", "")


def diff_names(base: str) -> list[str]:
    commands = [
        ["git", "diff", "--name-only", f"{base}...HEAD"],
        ["git", "diff", "--name-only", base, "HEAD"],
    ]
    last_err = ""
    for cmd in commands:
        proc = subprocess.run(cmd, capture_output=True, text=True)
        if proc.returncode == 0:
            return [line.strip() for line in proc.stdout.splitlines() if line.strip()]
        last_err = (proc.stderr or proc.stdout or "git diff failed").strip()
    raise RuntimeError(last_err or "git diff failed")


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Reject Swift edits on antigravity/v4 branches.")
    parser.add_argument("--files", nargs="*", default=None, help="Paths to judge. Default: git diff against base.")
    parser.add_argument("--branch", default=None)
    parser.add_argument("--title", default=None)
    parser.add_argument("--base", default="origin/main")
    args = parser.parse_args(argv)

    branch = _branch_from_env(args.branch)
    title = _title_from_env(args.title)
    if args.files is not None:
        paths = list(args.files)
    else:
        if not in_scope(branch, title):
            print(f"scope lint: clean (branch {branch or '(none)'} is outside v4)")
            return 0
        try:
            paths = diff_names(args.base)
        except RuntimeError as exc:
            print(f"scope lint: {exc}", file=sys.stderr)
            return 1

    code, bad = lint_paths(paths, branch, title)
    if code == 0:
        shown = ", ".join(paths) if paths else "(empty diff)"
        print(f"scope lint: clean {shown}")
        return 0
    print("scope lint: v4 branch touched Swift paths:", file=sys.stderr)
    for path in bad:
        print(path, file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
