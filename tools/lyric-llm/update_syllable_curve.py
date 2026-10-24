"""Regenerate out/syllable_curve.json with authentic rap end-rhyme rates and natural production BPMs.

Key fixes:
1. Strip parenthetical adlibs from end words before rhyme matching.
2. Recognize hip-hop slant assonances via primary stressed vowels and CMUDict.
3. Bidirectional scheme-window matching (AABB couplets, ABAB quatrains, AAAA monorhymes).
4. Natural musical BPM bucketing (70, 72, 75, 80, 84, 88, 90, 92, 95, 98, 100, 105, 110, 120, 128, 130, 132, 135, 138, 140, 141, 142, 144, 148, 150, 155, 160, etc.).
5. Automatic doubling of halved-tempo audio detections (<65 BPM).
"""

from collections import defaultdict
import json
from pathlib import Path
import re
import statistics
import sys
import time

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

import lyriclib
from v3_rhyme_stack import analyze_multisyllabic_stack, VOWEL_CLASSES

CANONICAL_POCKETS = {
    70: "Halftime Trap / Ambient",
    72: "Slow Melodic Bounce",
    75: "Soul Trap / Downtempo",
    78: "Late Night Melodic",
    80: "Boom Bap / Traditional Hip-Hop",
    82: "East Coast Classic",
    84: "R&B Trap Hybrid",
    85: "Gritty 90s Groove",
    88: "Golden Era Boom Bap",
    90: "Midtempo Headnod",
    92: "Underground Bounce",
    95: "West Coast Funk",
    98: "G-Funk / Modern Groove",
    100: "Club Midtempo / Pop Rap",
    105: "Dancehall / Afro-Fusion",
    110: "Bay Area Hyphy / Bounce",
    115: "Modern Detroit Style",
    120: "Club / Uptempo Trap",
    125: "House / Fast Bounce",
    128: "Festival Trap / EDM Rap",
    130: "Southern Trap Standard (Gunna Pocket)",
    132: "Atlanta Trap Mid",
    134: "Rolling Hi-Hats Trap",
    135: "Melodic Trap Anthem",
    138: "Dark Street Trap",
    140: "Heavy Trap Double-Time Standard",
    141: "Aggressive Double-Time",
    142: "Fast Atlanta Flow",
    144: "High-Energy Double-Time",
    146: "Rapid Trap Delivery",
    148: "Drill Hybrid Tempo",
    150: "High Octane Trap / Drill",
    155: "Hyper-Trap / Plugg",
    160: "UK / NY Drill Standard",
    165: "Fast Drill Pace",
    170: "Max Velocity Drill",
}

CANONICAL_BPMS = sorted(CANONICAL_POCKETS.keys())

ADLIB_RE = re.compile(r"\s*[\(\[\{][^\)\]\}]*[\)\]\}]\s*$")


def map_natural_bpm(raw_bpm: float) -> int:
    b = float(raw_bpm)
    if b < 65:
        b = b * 2
    nearest = min(CANONICAL_BPMS, key=lambda c: abs(c - b))
    if abs(nearest - b) <= 1.5:
        return nearest
    return int(round(b))


def clean_end_word(line: str) -> str:
    cleaned = ADLIB_RE.sub("", line).strip()
    if not cleaned:
        cleaned = line.strip()
    tokens = lyriclib.tokenize(lyriclib.normalize(cleaned))
    return tokens[-1] if tokens else ""


def build_curve(train_path: Path, cmu_path: Path) -> dict:
    cmu = lyriclib.load_cmudict(cmu_path)
    print(f"Loaded CMUDict with {len(cmu):,} words.")

    rhyme_cache = {}

    def words_rhyme(w1: str, w2: str) -> bool:
        if not w1 or not w2:
            return False
        if w1 == w2:
            return True
        pair = (w1, w2) if w1 < w2 else (w2, w1)
        if pair in rhyme_cache:
            return rhyme_cache[pair]

        r1 = lyriclib.end_rime(w1, cmu)
        r2 = lyriclib.end_rime(w2, cmu)
        if r1 and r2 and r1 == r2:
            rhyme_cache[pair] = True
            return True

        res = analyze_multisyllabic_stack(w1, w2, cmu)
        matched = res["depth"] >= 1
        rhyme_cache[pair] = matched
        return matched

    def calc_song_rhyme(lines: list[str]) -> float:
        if len(lines) < 2:
            return None
        ends = [clean_end_word(l) for l in lines]
        hits = 0
        scored = 0
        for i, w in enumerate(ends):
            if not w:
                continue
            scored += 1
            window = [
                ends[j]
                for j in range(max(0, i - 4), min(len(ends), i + 5))
                if j != i and ends[j]
            ]
            if any(words_rhyme(w, prev) for prev in window):
                hits += 1
        return hits / scored if scored > 0 else None

    bucket_syls = defaultdict(list)
    bucket_rhymes = defaultdict(list)
    bucket_flows = defaultdict(list)
    all_syls = []

    print(f"Processing songs from {train_path}...")
    t0 = time.time()
    song_count = 0
    with open(train_path, "r", encoding="utf-8") as f:
        for line in f:
            obj = json.loads(line)
            raw_lines = [
                l.strip() for l in obj.get("text", "").split("\n") if l.strip()
            ]
            if len(raw_lines) < 4:
                continue
            song_count += 1
            syls = [lyriclib.estimate_syllables(l) for l in raw_lines]
            all_syls.extend(syls)

            rhyme = calc_song_rhyme(raw_lines)
            flow = lyriclib.flow_consistency(syls)

            raw_bpm = obj.get("bpm")
            if raw_bpm is not None:
                nat_bpm = map_natural_bpm(raw_bpm)
                bucket_syls[nat_bpm].extend(syls)
                if rhyme is not None:
                    bucket_rhymes[nat_bpm].append(rhyme)
                if flow is not None:
                    bucket_flows[nat_bpm].append(flow)

    t1 = time.time()
    print(f"Finished {song_count:,} songs in {t1 - t0:.1f}s.")

    buckets = {}
    for bpm in sorted(bucket_syls.keys()):
        s_list = bucket_syls[bpm]
        if len(s_list) < 50:
            continue
        r_list = bucket_rhymes[bpm]
        f_list = bucket_flows[bpm]
        description = CANONICAL_POCKETS.get(bpm, f"{bpm} BPM Pocket")
        buckets[str(bpm)] = {
            "bpm": bpm,
            "description": description,
            "n": len(s_list),
            "median_syl": int(round(statistics.median(s_list))) if s_list else 11,
            "mean_rhyme_rate": round(statistics.fmean(r_list), 4) if r_list else 0.81,
            "mean_flow": round(statistics.fmean(f_list), 4) if f_list else 0.68,
        }

    global_med = int(round(statistics.median(all_syls))) if all_syls else 11
    return {
        "buckets": buckets,
        "global_median_syl": global_med,
        "canonical_pockets": CANONICAL_POCKETS,
    }


def main():
    train_path = ROOT / "out" / "train.jsonl"
    cmu_path = ROOT.parent.parent / "XJournal AI" / "cmudict.txt"
    out_curve_path = ROOT / "out" / "syllable_curve.json"

    curve = build_curve(train_path, cmu_path)
    out_curve_path.write_text(json.dumps(curve, indent=2), encoding="utf-8")
    print(f"Successfully wrote natural curve to {out_curve_path}")

    # Also update baseline.json if present
    baseline_path = ROOT / "out" / "baseline.json"
    if baseline_path.exists():
        try:
            base_obj = json.loads(baseline_path.read_text(encoding="utf-8"))
            base_obj["curve"] = curve
            baseline_path.write_text(
                json.dumps(base_obj, indent=2), encoding="utf-8"
            )
            print(f"Updated baseline.json curve section.")
        except Exception as e:
            print(f"Warning: could not update baseline.json: {e}")


if __name__ == "__main__":
    main()
