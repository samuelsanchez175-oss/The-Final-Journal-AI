#!/usr/bin/env python3
"""Flag every Gunna song as order-preserved vs alphabetical.

Order-preserved: alphabetical-pair-rate < 0.6 across rowid-ordered lines.
Alphabetical:    alphabetical-pair-rate >= 0.9 (strong signal that rows
                 were sorted at ingest).
Unclear:         between 0.6 and 0.9 — mix.

Writes docs/flow-rules/song_order_flags.json with per-song flag + alpha_rate
and docs/flow-rules/song_order_summary.md with counts.
"""
from __future__ import annotations

import json
import sqlite3
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
OUT = REPO / "docs" / "flow-rules"
DB = REPO / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite"


def main() -> int:
    conn = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    songs = conn.execute(
        "SELECT song, COUNT(*) FROM bars WHERE lower(artist)='gunna' "
        "GROUP BY song ORDER BY song"
    ).fetchall()
    out: list[dict] = []
    buckets = {"order_preserved": 0, "alphabetical": 0, "unclear": 0, "too_short": 0}
    bucket_lines = {"order_preserved": 0, "alphabetical": 0, "unclear": 0, "too_short": 0}
    for song, n in songs:
        if n < 5:
            flag = "too_short"
            rate = None
        else:
            lines = [r[0] for r in conn.execute(
                "SELECT line FROM bars WHERE lower(artist)='gunna' AND song=? "
                "ORDER BY rowid", (song,)).fetchall()]
            pairs = sum(1 for i in range(1, len(lines))
                        if (lines[i - 1] or "").lower() <= (lines[i] or "").lower())
            rate = pairs / max(len(lines) - 1, 1)
            if rate < 0.6:
                flag = "order_preserved"
            elif rate >= 0.9:
                flag = "alphabetical"
            else:
                flag = "unclear"
        buckets[flag] += 1
        bucket_lines[flag] += n
        out.append({"song": song, "lines": n, "alpha_rate": rate, "flag": flag})
    conn.close()

    (OUT / "song_order_flags.json").write_text(
        json.dumps({"buckets": buckets, "bucket_lines": bucket_lines,
                    "songs": out}, indent=2, ensure_ascii=False))

    md = ["# Song order flags — Gunna 739 songs", "",
          "| flag | definition | songs | lines |",
          "| --- | --- | ---:| ---:|",
          f"| order_preserved | alpha-pair-rate < 0.6 | {buckets['order_preserved']} | {bucket_lines['order_preserved']} |",
          f"| alphabetical | alpha-pair-rate ≥ 0.9 | {buckets['alphabetical']} | {bucket_lines['alphabetical']} |",
          f"| unclear | 0.6 ≤ rate < 0.9 | {buckets['unclear']} | {bucket_lines['unclear']} |",
          f"| too_short | <5 lines | {buckets['too_short']} | {bucket_lines['too_short']} |",
          "",
          "## Order-preserved songs",
          "",
          "| song | lines | alpha_rate |",
          "| --- | ---:| ---:|"]
    for r in sorted((x for x in out if x["flag"] == "order_preserved"),
                    key=lambda x: -x["lines"]):
        md.append(f"| {r['song']} | {r['lines']} | {r['alpha_rate']:.2f} |")
    md.append("")
    md.append("## Unclear songs (sample)")
    md.append("")
    md.append("| song | lines | alpha_rate |")
    md.append("| --- | ---:| ---:|")
    for r in sorted((x for x in out if x["flag"] == "unclear"),
                    key=lambda x: -x["lines"])[:30]:
        md.append(f"| {r['song']} | {r['lines']} | {r['alpha_rate']:.2f} |")
    (OUT / "song_order_summary.md").write_text("\n".join(md) + "\n")
    print(f"order_preserved: {buckets['order_preserved']} songs / {bucket_lines['order_preserved']} lines")
    print(f"alphabetical:    {buckets['alphabetical']} songs / {bucket_lines['alphabetical']} lines")
    print(f"unclear:         {buckets['unclear']} songs / {bucket_lines['unclear']} lines")
    print(f"too_short:       {buckets['too_short']} songs / {bucket_lines['too_short']} lines")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
