#!/usr/bin/env python3
"""Analyze gunna_acousticbrainz.csv after the fetch finishes.

Reports:
  - AB BPM coverage (matched / 739)
  - Gunna tempo distribution (histogram + median)
  - Spearman correlation of per-track mean syllables-per-bar vs BPM
  - Spearman correlation of per-track mean commas-per-bar vs BPM

Uses the clean order-preserved subset for syl/comma means.
No external APIs. No Spotify.
"""
from __future__ import annotations

import collections
import csv
import json
import math
import re
import statistics
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
LLM = REPO / "tools" / "lyric-llm"
OUT = REPO / "docs" / "flow-rules"
sys.path.insert(0, str(LLM))

from lyriclib import load_cmudict  # type: ignore

CMU = load_cmudict(REPO / "XJournal AI" / "cmudict.txt")
_W = re.compile(r"[A-Za-z']+")


def _syl(w):
    w = re.sub(r"[^A-Za-z']", "", (w or "").lower())
    if not w:
        return 0
    p = CMU.get(w)
    if p:
        return sum(1 for ph in p if any(c.isdigit() for c in ph))
    v = "aeiouy"; c, pv = 0, False
    for ch in w:
        iv = ch in v
        if iv and not pv: c += 1
        pv = iv
    return max(c, 1)


def spearman(xs, ys):
    if len(xs) != len(ys) or len(xs) < 3:
        return 0.0, 0
    def rank(seq):
        s = sorted(range(len(seq)), key=lambda i: seq[i])
        r = [0.0] * len(seq)
        i = 0
        while i < len(s):
            j = i
            while j + 1 < len(s) and seq[s[j + 1]] == seq[s[i]]:
                j += 1
            avg = (i + j) / 2 + 1
            for k in range(i, j + 1):
                r[s[k]] = avg
            i = j + 1
        return r
    rx, ry = rank(xs), rank(ys)
    mx = sum(rx) / len(rx); my = sum(ry) / len(ry)
    num = sum((rx[i] - mx) * (ry[i] - my) for i in range(len(rx)))
    denx = math.sqrt(sum((r - mx) ** 2 for r in rx))
    deny = math.sqrt(sum((r - my) ** 2 for r in ry))
    if denx == 0 or deny == 0:
        return 0.0, len(xs)
    return num / (denx * deny), len(xs)


def bootstrap_spearman_ci(xs, ys, trials=500, seed=42):
    import random
    if len(xs) < 10:
        return None, None
    rng = random.Random(seed)
    rhos = []
    for _ in range(trials):
        idx = [rng.randrange(len(xs)) for _ in range(len(xs))]
        sx = [xs[i] for i in idx]
        sy = [ys[i] for i in idx]
        rho, _ = spearman(sx, sy)
        rhos.append(rho)
    rhos.sort()
    return rhos[int(0.025 * trials)], rhos[int(0.975 * trials)]


def main() -> int:
    csv_path = OUT / "gunna_acousticbrainz.csv"
    if not csv_path.exists():
        print("ERROR: gunna_acousticbrainz.csv not yet written. Wait for the fetch to finish.",
              file=sys.stderr)
        return 2
    rows: list[dict] = []
    with csv_path.open() as f:
        for r in csv.DictReader(f):
            rows.append(r)
    total = len(rows)
    matched = [r for r in rows if r.get("bpm_ab") and r["bpm_ab"].strip()]
    print(f"AB coverage: {len(matched)}/{total} songs ({len(matched) * 100 / max(total, 1):.1f}%)")

    bpms = []
    for r in matched:
        try:
            bpm = float(r["bpm_ab"])
            if 50 <= bpm <= 220:
                bpms.append(bpm)
        except Exception:
            continue
    if bpms:
        print(f"Gunna tempo: n={len(bpms)}  median={statistics.median(bpms):.1f}  "
              f"mean={statistics.mean(bpms):.1f}  "
              f"sd={statistics.stdev(bpms) if len(bpms) > 1 else 0:.1f}")
        hist = collections.Counter()
        for b in bpms:
            if b < 90: hist["<90"] += 1
            elif b < 120: hist["90-119"] += 1
            elif b < 140: hist["120-139"] += 1
            elif b < 160: hist["140-159"] += 1
            else: hist["160+"] += 1
        print(f"BPM histogram: {dict(hist)}")

    # Per-song mean syl/bar + mean commas/bar from the order_preserved subset
    flags = json.loads((OUT / "song_order_flags.json").read_text())
    keep = {s["song"] for s in flags["songs"] if s["flag"] == "order_preserved"}
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna" and r["song"] in keep]
    per_song: dict[str, dict] = {}
    for r in solo:
        s = r["song"]
        toks = _W.findall(r["line"])
        syl = sum(_syl(t) for t in toks)
        commas = r["line"].count(",")
        p = per_song.setdefault(s, {"syls": [], "commas": []})
        p["syls"].append(syl)
        p["commas"].append(commas)
    song_stats = {s: {"syl_mean": statistics.mean(v["syls"]),
                      "comma_mean": statistics.mean(v["commas"])}
                  for s, v in per_song.items() if v["syls"]}

    # join with AB
    xs_syl, xs_cmm, ys_bpm = [], [], []
    for r in matched:
        try:
            bpm = float(r["bpm_ab"])
            if not (50 <= bpm <= 220):
                continue
        except Exception:
            continue
        song = r["song"]
        st = song_stats.get(song)
        if not st:
            continue
        xs_syl.append(st["syl_mean"])
        xs_cmm.append(st["comma_mean"])
        ys_bpm.append(bpm)
    rho_syl, n = spearman(xs_syl, ys_bpm)
    rho_cmm, _ = spearman(xs_cmm, ys_bpm)
    ci_syl = bootstrap_spearman_ci(xs_syl, ys_bpm)
    ci_cmm = bootstrap_spearman_ci(xs_cmm, ys_bpm)
    print()
    print(f"Spearman syl/bar  vs BPM: rho={rho_syl:+.3f}  n={n}  "
          f"CI95%={ci_syl[0]:+.3f}..{ci_syl[1]:+.3f}" if ci_syl[0] is not None
          else f"Spearman syl/bar vs BPM: n too small")
    print(f"Spearman comma/bar vs BPM: rho={rho_cmm:+.3f}  n={n}  "
          f"CI95%={ci_cmm[0]:+.3f}..{ci_cmm[1]:+.3f}" if ci_cmm[0] is not None
          else f"Spearman comma/bar vs BPM: n too small")

    out = {
        "ab_total": total, "ab_matched": len(matched),
        "ab_coverage_rate": round(len(matched) / max(total, 1), 4),
        "bpm_median": statistics.median(bpms) if bpms else None,
        "bpm_mean": statistics.mean(bpms) if bpms else None,
        "bpm_sd": (statistics.stdev(bpms) if len(bpms) > 1 else 0) if bpms else None,
        "bpm_histogram": dict(hist) if bpms else {},
        "spearman_syl_bpm": {"rho": round(rho_syl, 4), "n": n,
                              "ci95_low": round(ci_syl[0], 4) if ci_syl[0] is not None else None,
                              "ci95_high": round(ci_syl[1], 4) if ci_syl[1] is not None else None},
        "spearman_comma_bpm": {"rho": round(rho_cmm, 4), "n": n,
                                "ci95_low": round(ci_cmm[0], 4) if ci_cmm[0] is not None else None,
                                "ci95_high": round(ci_cmm[1], 4) if ci_cmm[1] is not None else None},
    }
    (OUT / "ab_analysis.json").write_text(json.dumps(out, indent=2))
    print(f"\nwrote {OUT / 'ab_analysis.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
