#!/usr/bin/env python3
"""Hook detector — fuzzy: SequenceMatcher ratio >= 0.8 clustered within a
song, cluster size >= 3 marks all cluster members as hook lines.

Writes docs/flow-rules/hook_fuzzy_stats.json. Reports strict vs fuzzy counts.
"""
from __future__ import annotations

import collections
import difflib
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
OUT = REPO / "docs" / "flow-rules"

_W = re.compile(r"[A-Za-z']+")
ADLIBS = {"yeah", "uh", "woo", "huh", "what", "skrrt", "skrr", "ayy",
          "ooh", "woah", "oh", "nah", "hey", "mm", "mmm", "yuh", "yah",
          "aye", "ay", "ye"}


def strip_adlibs(line: str) -> str:
    s = re.sub(r"\([^)]*\)|\[[^\]]*\]", "", line or "")
    while True:
        s = s.rstrip(" ,.!?;:—-")
        toks = _W.findall(s)
        if not toks or toks[-1].lower().strip("'") not in ADLIBS:
            break
        m = re.search(r"[A-Za-z']+[\s,!?.;:—-]*$", s)
        if not m:
            break
        s = s[:m.start()].rstrip(" ,.!?;:—-")
    return s.strip()


def norm(line: str) -> str:
    s = strip_adlibs(line).lower()
    s = re.sub(r"[^\w\s]", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def cluster_fuzzy(lines: list[str], threshold: float = 0.8) -> list[list[int]]:
    """Simple single-link clustering by SequenceMatcher.ratio.

    Returns list of clusters, each a list of line indexes. Only clusters of
    size >= 3 after merging will be marked as hooks downstream.
    """
    assigned = [-1] * len(lines)
    clusters: list[list[int]] = []
    for i, a in enumerate(lines):
        if not a:
            continue
        placed = False
        for cid, cl in enumerate(clusters):
            # compare against the cluster centroid (first member)
            b = lines[cl[0]]
            if not b:
                continue
            ratio = difflib.SequenceMatcher(None, a, b).ratio()
            if ratio >= threshold:
                cl.append(i)
                assigned[i] = cid
                placed = True
                break
        if not placed:
            clusters.append([i])
            assigned[i] = len(clusters) - 1
    return clusters


def main() -> int:
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna"]
    by_song: dict[tuple, list[dict]] = {}
    for r in solo:
        by_song.setdefault((r["artist"], r["song"]), []).append(r)

    strict_hook = 0
    fuzzy_hook = 0
    hook_samples: list[dict] = []
    cluster_sizes: list[int] = []
    songs_with_hook_strict = 0
    songs_with_hook_fuzzy = 0

    for (artist, song), seq in by_song.items():
        norms = [norm(r["line"]) for r in seq]
        # strict: count exact-norm repeats
        c = collections.Counter(n for n in norms if n)
        strict_cluster_sizes = [v for v in c.values() if v >= 3]
        if strict_cluster_sizes:
            songs_with_hook_strict += 1
        strict_this = sum(c[k] for k in c if c[k] >= 3)
        strict_hook += strict_this
        # fuzzy: cluster at 0.8 similarity
        clusters = cluster_fuzzy(norms, threshold=0.8)
        song_has_hook = False
        for cl in clusters:
            if len(cl) >= 3 and any(norms[i] for i in cl):
                cluster_sizes.append(len(cl))
                fuzzy_hook += len(cl)
                song_has_hook = True
                if len(hook_samples) < 20:
                    centroid = norms[cl[0]]
                    variants = [seq[i]["line"] for i in cl[:4]]
                    hook_samples.append({
                        "song": song, "cluster_size": len(cl),
                        "centroid_norm": centroid,
                        "variant_lines": variants,
                    })
        if song_has_hook:
            songs_with_hook_fuzzy += 1

    size_hist = collections.Counter(cluster_sizes)
    out = {
        "n_solo_lines": len(solo),
        "n_songs": len(by_song),
        "strict_hook_lines": strict_hook,
        "strict_hook_rate": round(strict_hook / max(len(solo), 1), 4),
        "fuzzy_hook_lines": fuzzy_hook,
        "fuzzy_hook_rate": round(fuzzy_hook / max(len(solo), 1), 4),
        "fuzzy_cluster_size_hist": dict(sorted(size_hist.items())),
        "songs_with_hook_strict": songs_with_hook_strict,
        "songs_with_hook_fuzzy": songs_with_hook_fuzzy,
        "fuzzy_threshold": 0.8,
        "sample_hook_clusters": hook_samples[:15],
    }
    (OUT / "hook_fuzzy_stats.json").write_text(json.dumps(out, indent=2, ensure_ascii=False))
    print(f"solo lines={len(solo)}")
    print(f"strict  hook_lines={strict_hook}  rate={out['strict_hook_rate']}  "
          f"songs_with_hook={songs_with_hook_strict}")
    print(f"fuzzy   hook_lines={fuzzy_hook}  rate={out['fuzzy_hook_rate']}  "
          f"songs_with_hook={songs_with_hook_fuzzy}")
    print(f"cluster-size histogram: {dict(sorted(size_hist.items())[:10])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
