#!/usr/bin/env python3
"""Export the antigravity-authored KEEP entries so Samuel can Y/N them.

Writes eval/review_antigravity_keeps/<tab>_batch_NNN.jsonl at 50 entries
per file, grouped by tab. Each row carries:
  {entry_id, tab, artist, song, line, setup, play, heard_as, reason, by, source}
plus a `verdict` field (initially ""), ready for Samuel to fill with
"KEEP" or "REJECT" and merge back as `by: samuel`.

Rows whose `by` already starts with "samuel" are excluded (they're already
confirmed and loaded by WordplayIndex).

Reject-rerun-v2.jsonl is NEVER included.
"""
from __future__ import annotations

import json
import re
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent.parent
INDEX = REPO / "docs" / "play-on-words" / "wordplay-index" / "index.jsonl"
INDEX_V2 = REPO / "docs" / "play-on-words" / "wordplay-index" / "index-v2.jsonl"
OUT_DIR = REPO / "tools" / "lyric-llm" / "eval" / "review_antigravity_keeps"


_WORD_RE = re.compile(r"[A-Za-z']+")


def _norm_bar(entry: dict) -> str:
    for k in ("line", "bar", "key_bar"):
        v = entry.get(k)
        if v and str(v).strip():
            return str(v).strip()
    return ""


def iter_candidates():
    for path, label in ((INDEX, "index"), (INDEX_V2, "index-v2")):
        if not path.exists():
            continue
        for raw in path.read_text().splitlines():
            if not raw.strip():
                continue
            try:
                entry = json.loads(raw)
            except json.JSONDecodeError:
                continue
            verdict = (entry.get("verdict") or "").upper()
            if verdict != "KEEP":
                continue
            by = (entry.get("by") or "").lower()
            if by.startswith("samuel"):
                continue
            line = _norm_bar(entry)
            if not line:
                continue
            setup_text = entry.get("setup") or ""
            if not setup_text and entry.get("setup_spans"):
                setup_text = " ".join(s.get("text", "") for s in entry["setup_spans"]
                                      if isinstance(s, dict))
            play_text = entry.get("play") or ""
            if not play_text and entry.get("play_spans"):
                heard = " ".join(s.get("heard", "") for s in entry["play_spans"]
                                 if isinstance(s, dict))
                play_text = heard
            yield {
                "entry_id": entry.get("id") or f"{label}:{entry.get('artist','')}:{line[:40]}",
                "tab": entry.get("tab") or "",
                "artist": entry.get("artist") or entry.get("key_artist") or "",
                "song": entry.get("song") or entry.get("key_song") or "",
                "line": line,
                "setup": setup_text,
                "play": play_text,
                "heard_as": entry.get("heard_as") or "",
                "reason": entry.get("reason") or "",
                "by": entry.get("by") or "",
                "source": label,
                "verdict": "",  # Samuel fills in
            }


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    by_tab: dict[str, list[dict]] = defaultdict(list)
    for row in iter_candidates():
        by_tab[row["tab"] or "untagged"].append(row)
    total = 0
    for tab, rows in sorted(by_tab.items()):
        for i in range(0, len(rows), 50):
            batch = rows[i:i + 50]
            fname = OUT_DIR / f"{tab}_batch_{(i // 50) + 1:03d}.jsonl"
            with fname.open("w", encoding="utf-8") as f:
                for r in batch:
                    f.write(json.dumps(r, ensure_ascii=False) + "\n")
            total += len(batch)
        print(f"  {tab:24s} {len(rows):4d} entries across "
              f"{(len(rows) + 49) // 50} batch file(s)")
    print(f"\nwrote {total} entries to {OUT_DIR.relative_to(REPO)}")
    print("Samuel fills `verdict: KEEP` or `REJECT`, saves with "
          "`by: samuel`, and re-runs WordplayIndex.build() to pick them up.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
