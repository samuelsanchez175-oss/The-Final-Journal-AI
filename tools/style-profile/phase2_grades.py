#!/usr/bin/env python3
"""AI Sparkler style profile — Phase 2: catalog percentiles, letter grades, style cards.

Input : tools/style-profile/out/song_metrics.jsonl (Phase 1, full catalog)
Output: song_grades.jsonl, artist_grades.jsonl, catalog_stats.json (same folder)

Each graded metric stores raw, pct (rank vs every confident song in the catalog),
z (distance from catalog mean) and letter (from pct). A grade means "how much of
this trait vs the catalog", not good/bad. Artist grade = median of the artist's
song percentiles.

Usage:
  python3 tools/style-profile/phase2_grades.py
  python3 tools/style-profile/phase2_grades.py --in out/song_metrics_pilot.jsonl --tag pilot
"""

from __future__ import annotations

import argparse
import bisect
import json
import statistics
from collections import Counter, defaultdict
from pathlib import Path

SCHEMA_VERSION = "phase2.v1"
HERE = Path(__file__).resolve().parent
MIN_SONGS_ARTIST = 5
COMMON_KEY_TOP_N = 50  # rime keys this common count as cliché pairs for novelty

# name -> (section, key). Higher value = more of the trait.
METRICS = {
    "end_rhyme_rate": ("end_rhyme", "end_rhyme_pct"),
    "multisyllabic_rate": ("end_rhyme", "multisyllabic_pct"),
    "rhyme_depth": ("end_rhyme", "mean_depth"),
    "rhyme_reuse": ("end_rhyme", "rhyme_family_reuse"),
    "internal_rhyme_rate": ("internal_rhyme", "internal_bar_pct"),
    "internal_density": ("internal_rhyme", "pairs_per_bar"),
    "mid_to_end_rate": ("internal_rhyme", "mid_to_end_pct"),
    "cross_bar_rate": ("internal_rhyme", "cross_bar_pct"),
    "vocab_diversity": ("vocab", "mattr_100"),
    "syllables_per_bar": ("cadence", "syl_per_bar_mean"),
    "cadence_variety": ("cadence", "syl_per_bar_cv"),
    "pause_rate": ("cadence", "pauses_per_bar"),
    "stress_density": ("cadence", "stress_density"),
}
# derived in this phase
DERIVED = ["rhyme_novelty"]

COMPOSITES = {
    "end_rhyme_grade": ["end_rhyme_rate", "multisyllabic_rate", "rhyme_depth", "rhyme_novelty"],
    "internal_rhyme_grade": ["internal_rhyme_rate", "internal_density", "mid_to_end_rate", "cross_bar_rate"],
    "cadence_grade": ["cadence_variety", "pause_rate"],
    "vocab_grade": ["vocab_diversity"],
}

PLAIN = {
    "end_rhyme_rate": "bars that end-rhyme with a recent bar",
    "multisyllabic_rate": "multi-syllable end rhymes",
    "rhyme_depth": "depth of end-rhyme matches",
    "rhyme_novelty": "uncommon rhyme pairs",
    "rhyme_reuse": "reuse of the same rhyme sound",
    "internal_rhyme_rate": "bars with a rhyme inside the bar",
    "internal_density": "internal rhyme pairs per bar",
    "mid_to_end_rate": "bars where a mid-bar word rhymes with the bar's last word",
    "cross_bar_rate": "internal rhymes that carry into the next bar",
    "vocab_diversity": "vocabulary variety",
    "syllables_per_bar": "syllables per bar",
    "cadence_variety": "bar-length variation",
    "pause_rate": "pause marks per bar",
    "stress_density": "stressed share of syllables",
}


def letter(p: float) -> str:
    return "A" if p >= 90 else "B" if p >= 75 else "C" if p >= 50 else "D" if p >= 25 else "F"


def get(row: dict, section: str, key: str):
    sec = row.get(section)
    return sec.get(key) if isinstance(sec, dict) else None


class Dist:
    def __init__(self, values: list[float]):
        self.sorted = sorted(values)
        self.mean = statistics.fmean(values)
        self.std = statistics.pstdev(values) or 1.0

    def pct(self, x: float) -> float:
        lo = bisect.bisect_left(self.sorted, x)
        hi = bisect.bisect_right(self.sorted, x)
        return round(100.0 * (lo + hi) / 2 / len(self.sorted), 1)

    def z(self, x: float) -> float:
        return round((x - self.mean) / self.std, 2)

    def summary(self) -> dict:
        s = self.sorted
        q = statistics.quantiles(s, n=20)
        return {"n": len(s), "mean": round(self.mean, 3), "std": round(self.std, 3), "p5": q[0], "p25": q[4],
                "median": q[9], "p75": q[14], "p95": q[-1]}


def novelty(row: dict, common: set[str]) -> float | None:
    keys = (row.get("end_rhyme") or {}).get("pair_keys")
    if not keys:
        return None
    total = sum(keys.values())
    return round(100.0 * sum(v for k, v in keys.items() if k not in common) / total, 2) if total else None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--in", dest="inp", type=Path, default=HERE / "out" / "song_metrics.jsonl")
    ap.add_argument("--out", type=Path, default=HERE / "out")
    ap.add_argument("--tag", default="")
    ap.add_argument("--skip-cadence", action="store_true",
                    help="leave out cadence metrics/grade (syllables/bar is not meaningful until tempo is merged)")
    args = ap.parse_args()
    suffix = f"_{args.tag}" if args.tag else ""

    if args.skip_cadence:
        for name in ("syllables_per_bar", "cadence_variety", "pause_rate", "stress_density"):
            METRICS.pop(name, None)
        COMPOSITES.pop("cadence_grade", None)
    rows = [json.loads(line) for line in open(args.inp, encoding="utf-8")]
    confident = [r for r in rows if r.get("confident")]

    # rime-key frequency across the catalog -> "common" set for novelty
    key_counts: Counter = Counter()
    for r in confident:
        for k, v in ((r.get("end_rhyme") or {}).get("pair_keys") or {}).items():
            key_counts[k] += v
    common = {k for k, _ in key_counts.most_common(COMMON_KEY_TOP_N)}

    def raw_values(r: dict) -> dict[str, float | None]:
        vals = {name: get(r, s, k) for name, (s, k) in METRICS.items()}
        vals["rhyme_novelty"] = novelty(r, common)
        return vals

    raw_by_song = [(r, raw_values(r)) for r in confident]
    dists: dict[str, Dist] = {}
    for name in list(METRICS) + DERIVED:
        vs = [v[name] for _, v in raw_by_song if v[name] is not None]
        if len(vs) >= 20:
            dists[name] = Dist(vs)

    # ---- song grades
    by_artist: dict[str, list[dict]] = defaultdict(list)
    with open(args.out / f"song_grades{suffix}.jsonl", "w", encoding="utf-8") as fh:
        for r, vals in raw_by_song:
            g: dict = {}
            for name, d in dists.items():
                x = vals[name]
                if x is None:
                    continue
                p = d.pct(x)
                g[name] = {"raw": x, "pct": p, "z": d.z(x), "letter": letter(p)}
            for comp, parts in COMPOSITES.items():
                ps = [g[m]["pct"] for m in parts if m in g]
                if ps:
                    cp = round(statistics.fmean(ps), 1)
                    g[comp] = {"pct": cp, "letter": letter(cp)}
            row = {"schema": SCHEMA_VERSION, "artist": r["artist"], "song": r["song"], "year": r.get("year"),
                   "bars": r["bars"], "grades": g, "scheme_share": (r.get("end_rhyme") or {}).get("scheme_share")}
            fh.write(json.dumps(row, ensure_ascii=False) + "\n")
            by_artist[r["artist"]].append(row)

    # ---- artist grades + style card
    artists_out = []
    for art, srows in sorted(by_artist.items()):
        n = len(srows)
        grades: dict = {}
        for name in list(dists) + list(COMPOSITES):
            ps = [s["grades"][name]["pct"] for s in srows if name in s["grades"]]
            if not ps:
                continue
            med = round(statistics.median(ps), 1)
            entry = {"pct": med, "letter": letter(med), "spread_pct": [round(min(ps), 1), round(max(ps), 1)]}
            raws = [s["grades"][name]["raw"] for s in srows if name in s["grades"] and "raw" in s["grades"][name]]
            if raws:
                entry["raw_median"] = round(statistics.median(raws), 3)
            grades[name] = entry
        schemes = Counter()
        for s in srows:
            for k, v in (s.get("scheme_share") or {}).items():
                schemes[k] += v
        scheme_total = sum(schemes.values()) or 1
        scheme = {k: round(100 * v / scheme_total, 1) for k, v in schemes.items()}
        artists_out.append({
            "schema": SCHEMA_VERSION, "artist": art, "songs_graded": n,
            "low_sample": n < MIN_SONGS_ARTIST, "grades": grades, "end_rhyme_scheme_share": scheme,
            "style_card": style_card(grades, scheme),
        })
    # artist-vs-artist rank of each typical (median) value; song-percentile medians regress to the middle,
    # so the style card uses this to find what is actually distinctive about an artist.
    solid = [a for a in artists_out if not a["low_sample"]]
    for name in list(dists):
        vals = [a["grades"][name]["raw_median"] for a in solid if name in a["grades"] and "raw_median" in a["grades"][name]]
        if len(vals) < 20:
            continue
        ad = Dist(vals)
        for a in artists_out:
            g = a["grades"].get(name)
            if g and "raw_median" in g:
                g["artist_pct"] = ad.pct(g["raw_median"])
                g["artist_letter"] = letter(g["artist_pct"])
    for a in artists_out:
        a["style_card"] = style_card(a["grades"], a["end_rhyme_scheme_share"])
    with open(args.out / f"artist_grades{suffix}.jsonl", "w", encoding="utf-8") as fh:
        for a in artists_out:
            fh.write(json.dumps(a, ensure_ascii=False) + "\n")

    stats = {"schema": SCHEMA_VERSION, "songs_in_catalog": len(confident),
             "common_rime_keys_excluded_from_novelty": sorted(common),
             "distributions": {k: d.summary() for k, d in dists.items()}}
    (args.out / f"catalog_stats{suffix}.json").write_text(json.dumps(stats, indent=1))
    print(f"{len(confident)} songs graded, {len(artists_out)} artists, {len(dists)} metrics")
    return 0


def band(p: float) -> str | None:
    return "very high" if p >= 90 else "high" if p >= 75 else "low" if p <= 25 and p > 10 else "very low" if p <= 10 else None


def style_card(grades: dict, scheme: dict) -> list[str]:
    """Plain-language rules for the generator. Only distinctive traits (outside the middle band)."""
    rules = []
    ordered = sorted(
        ((n, g) for n, g in grades.items() if n in PLAIN and "raw_median" in g),
        key=lambda x: -abs(x[1].get("artist_pct", 50) - 50),
    )
    for name, g in ordered[:8]:
        b = band(g.get("artist_pct", 50))
        if not b:
            continue
        unit = "%" if name.endswith("_rate") or name == "rhyme_novelty" else ""
        rules.append(f"{b.capitalize()} {PLAIN[name]}: typical {g['raw_median']}{unit} (higher than {g['artist_pct']}% of artists).")
    if scheme:
        top = max(scheme, key=scheme.get)
        label = {"couplet": "back-to-back couplet rhymes", "alternate": "alternating rhymes (every other bar)",
                 "far": "long-distance rhyme callbacks"}.get(top, top)
        rules.append(f"Most end rhymes land as {label} ({scheme[top]}% of matches).")
    return rules


if __name__ == "__main__":
    raise SystemExit(main())
