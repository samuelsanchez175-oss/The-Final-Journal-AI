#!/usr/bin/env python3
"""Score how close a verse is to the Gunna anchor profile, and prove whether that score separates.

The score is 0-100. It is deterministic and uses no model. Weights are fixed below; they are not
fit to maximize separation. `prove` prints group averages and AUC. If real anchor verses do not
score above other artists, the report says so.

Usage (from the repo root):
  python3 tools/style-profile/gunna_score.py self-check
  python3 tools/style-profile/gunna_score.py prove
  python3 tools/style-profile/gunna_score.py score path/to/verse.txt

`prove` expects out/anchor_profile_gunna.json from build_anchor_profile.py.
It re-reads the CSV (leave-one-song-out needs per-song counts) and writes
out/gunna_score_report.json. Verse text is not written into that report.

Expect from prove:
  a table of mean scores for held-out anchor verses, peer artists, random artists,
  and verses already in the generator database
  an AUC for each comparison
  a plain sentence saying whether the score separates real Gunna or not
"""

from __future__ import annotations

import argparse
import json
import math
import random
import sqlite3
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import phase1_song_metrics as p1
import anchor_lib

HERE = Path(__file__).resolve().parent
DEFAULT_PROFILE = HERE / "out" / "anchor_profile_gunna.json"
DEFAULT_REPORT = HERE / "out" / "gunna_score_report.json"
DEFAULT_DB = HERE / "out" / "feedback.db"
DEFAULT_COMPARISON = HERE / "out" / "model_comparison.json"
DEFAULT_METRICS = HERE / "out" / "song_metrics.jsonl"

# A priori weights. Not fit to the prove-run AUC.
# The 2026-10-14 prove run did not separate held-out anchor verses from peers
# (AUC about 0.47) or from random artists (AUC about 0.40). Do not retune these
# to chase that number. Ad-lib rate is the only component that clearly marks the
# old generator, because that generator was told to write no ad-libs.
WEIGHTS = {
    "syllables": 18,
    "rhyme": 16,
    "signature": 16,
    "bar_start": 12,
    "repetition": 12,
    "adlib": 10,
    "function": 16,
}
SCALES = {
    "syl_w1": 4.0,
    "half_w1": 3.0,
    "comma_width": 0.45,
    "link_width": 0.40,
    "alt_width": 0.35,
    "run_width": 0.30,
    "ident_width": 0.25,
    "opener_width": 0.40,
    "same_start_width": 0.25,
    "same_start2_width": 0.20,
    "repeat_floor": 0.20,
    "adlib_floor": 0.25,
    "js_width": 0.15,
    "function_width": 0.15,
    "sig_floor": 0.10,
}
PEERS = (
    "young thug", "lil baby", "future", "travis scott", "drake", "playboi carti",
    "lil durk", "nav", "moneybagg yo", "est gee", "21 savage", "lil uzi vert",
    "meek mill", "pop smoke",
)


def clip01(value: float) -> float:
    return max(0.0, min(1.0, value))


def tent(value: float, target: float, width: float) -> float:
    if width <= 0:
        return 1.0 if value == target else 0.0
    return clip01(1.0 - abs(value - target) / width)


def _hist_mass(hist, lo: int = 1, hi: int = 28):
    total = 0
    bins = [0.0] * (hi - lo + 1)
    for key, value in hist.items():
        count = int(value)
        if count <= 0:
            continue
        index = int(key)
        total += count
        if index < lo:
            bins[0] += count
        elif index > hi:
            bins[-1] += count
        else:
            bins[index - lo] += count
    if total <= 0:
        return None
    return [count / total for count in bins]


def wasserstein(left, right, lo: int = 1, hi: int = 28):
    mass_left, mass_right = _hist_mass(left, lo, hi), _hist_mass(right, lo, hi)
    if mass_left is None or mass_right is None:
        return None
    cum_left = cum_right = acc = 0.0
    for a, b in zip(mass_left, mass_right):
        cum_left += a
        cum_right += b
        acc += abs(cum_left - cum_right)
    return acc


def cosine(left: dict, right: dict) -> float:
    keys = set(left) | set(right)
    dot = left_norm = right_norm = 0.0
    for key in keys:
        x, y = float(left.get(key, 0.0)), float(right.get(key, 0.0))
        dot += x * y
        left_norm += x * x
        right_norm += y * y
    if left_norm <= 0 or right_norm <= 0:
        return 0.0
    return dot / math.sqrt(left_norm * right_norm)


def js_divergence(left: dict, right: dict) -> float:
    keys = set(left) | set(right)
    if not keys:
        return 0.0

    def probs(counts):
        total = sum(float(counts.get(key, 0.0)) + 0.5 for key in keys)
        return {key: (float(counts.get(key, 0.0)) + 0.5) / total for key in keys}

    left_p, right_p = probs(left), probs(right)
    mix = {key: 0.5 * (left_p[key] + right_p[key]) for key in keys}

    def kl(source, target):
        total = 0.0
        for key in keys:
            total += source[key] * math.log(source[key] / target[key])
        return total

    return 0.5 * kl(left_p, mix) + 0.5 * kl(right_p, mix)


def _rate(num: float, den: float) -> float:
    return num / den if den else 0.0


def _unit(distance: float, scale: float) -> float:
    if scale <= 0:
        return 0.0
    return 100.0 * clip01(1.0 - distance / scale)


def score_features(feat: dict, targets: dict) -> dict:
    """Score one verse-window feature dict (the shape features_from_lines returns)."""
    raw = {}
    parts = {}

    syl_w1 = wasserstein(feat["syl"], targets.get("syl_hist") or {})
    raw["syl_w1"] = None if syl_w1 is None else round(syl_w1, 3)
    if syl_w1 is None:
        parts["syllables"] = None
    else:
        syllable_score = _unit(syl_w1, SCALES["syl_w1"])
        comma_rate = _rate(feat["comma_bars"], feat["measured"])
        raw["comma_rate"] = round(comma_rate, 3)
        blended = 0.8 * syllable_score + 20.0 * tent(comma_rate, targets.get("comma_rate") or 0.0, SCALES["comma_width"])
        if feat["comma_bars"] >= 2 and targets.get("half_before_hist"):
            before = wasserstein(feat["half_before"], targets["half_before_hist"])
            after = wasserstein(feat["half_after"], targets["half_after_hist"])
            if before is not None and after is not None:
                half = 0.5 * (_unit(before, SCALES["half_w1"]) + _unit(after, SCALES["half_w1"]))
                blended = 0.7 * blended + 0.3 * half
                raw["half_w1"] = round(0.5 * (before + after), 3)
        parts["syllables"] = round(blended, 1)

    vowel_n = sum(feat["vowels"].values())
    verse_vowels = {key: value / vowel_n for key, value in feat["vowels"].items()} if vowel_n else {}
    vowel_cos = cosine(verse_vowels, targets.get("vowel_share") or {})
    dist1 = _rate(feat["dist1_hits"], feat["dist1_possible"])
    alt = _rate(feat["alt_hits"], feat["alt_possible"])
    run3 = _rate(feat["run3_bars"], feat["lines"])
    link_n = feat["dist1_hits"] + feat["alt_hits"]
    identical = _rate(feat["identical_links"], link_n)
    raw.update(vowel_cos=round(vowel_cos, 3), dist1=round(dist1, 3), alt=round(alt, 3),
               run3=round(run3, 3), identical=round(identical, 3))
    parts["rhyme"] = round(100.0 * (
        0.45 * vowel_cos
        + 0.20 * tent(dist1, targets.get("dist1_rate") or 0.0, SCALES["link_width"])
        + 0.15 * tent(alt, targets.get("alt_rate") or 0.0, SCALES["alt_width"])
        + 0.10 * tent(run3, targets.get("run3_share") or 0.0, SCALES["run_width"])
        + 0.10 * tent(identical, targets.get("identical_share") or 0.0, SCALES["ident_width"])
    ), 1)

    signature = set(targets.get("signature_set") or [])
    if not signature or not feat["content_n"]:
        parts["signature"] = None
        raw["sig_rate"] = None
    else:
        sig_rate = _rate(sum(count for word, count in feat["content"].items() if word in signature), feat["content_n"])
        width = max(SCALES["sig_floor"], 0.75 * (targets.get("signature_hit_rate") or 0.0))
        parts["signature"] = round(100.0 * tent(sig_rate, targets.get("signature_hit_rate") or 0.0, width), 1)
        raw["sig_rate"] = round(sig_rate, 3)

    opener_n = sum(feat["openers"].values())
    top = set(targets.get("opener_top") or [])
    hit = _rate(sum(count for word, count in feat["openers"].items() if word in top), opener_n)
    same1 = _rate(feat["same_first"], feat["consec"])
    same2 = _rate(feat["same_first2"], feat["consec"])
    parts["bar_start"] = round(100.0 * (
        tent(hit, targets.get("opener_hit_rate") or 0.0, SCALES["opener_width"])
        + tent(same1, targets.get("same_first_rate") or 0.0, SCALES["same_start_width"])
        + tent(same2, targets.get("same_first2_rate") or 0.0, SCALES["same_start2_width"])
    ) / 3.0, 1)
    raw.update(opener_hit=round(hit, 3), same_first=round(same1, 3))

    line_rate = _rate(feat["line_repeat_num"], feat["line_repeat_den"])
    tri_rate = _rate(feat["tri_repeat_num"], feat["tri_repeat_den"])
    parts["repetition"] = round(100.0 * 0.5 * (
        tent(line_rate, targets.get("line_repeat_rate") or 0.0, max(SCALES["repeat_floor"], targets.get("line_repeat_rate") or 0.0))
        + tent(tri_rate, targets.get("trigram_repeat_rate") or 0.0, max(SCALES["repeat_floor"], targets.get("trigram_repeat_rate") or 0.0))
    ), 1)

    adlib_rate = _rate(feat["adlib_bars"], feat["lines"])
    rate_score = tent(adlib_rate, targets.get("adlib_rate") or 0.0, max(SCALES["adlib_floor"], targets.get("adlib_rate") or 0.0))
    if feat["adlib_bars"] <= 0:
        pos_score = 1.0 if (targets.get("adlib_rate") or 0.0) < 0.05 else 0.0
    else:
        pos_n = sum(feat["adlib_pos"].values()) or 1
        verse_pos = {key: feat["adlib_pos"].get(key, 0) / pos_n for key in ("start", "middle", "end")}
        pos_score = cosine(verse_pos, targets.get("adlib_pos_share") or {})
    parts["adlib"] = round(100.0 * (0.7 * rate_score + 0.3 * pos_score), 1)
    raw["adlib_rate"] = round(adlib_rate, 3)

    js = js_divergence(feat["function"], targets.get("function_counts") or {})
    func_rate = _rate(sum(feat["function"].values()), feat["tokens"])
    raw["js"] = round(js, 4)
    raw["function_rate"] = round(func_rate, 3)
    parts["function"] = round(100.0 * (
        0.65 * clip01(1.0 - js / SCALES["js_width"])
        + 0.35 * tent(func_rate, targets.get("function_rate") or 0.0, SCALES["function_width"])
    ), 1)

    used = 0.0
    total = 0.0
    for name, weight in WEIGHTS.items():
        part = parts[name]
        if part is None:
            continue
        total += part * weight
        used += weight
    score = round(total / used, 1) if used else 0.0
    return {"score": score, "parts": {key: parts[key] for key in WEIGHTS}, "raw": raw}


def score_lines(lines: list[str], profile: dict, lex: p1.Lexicon) -> dict:
    return score_features(anchor_lib.features_from_lines(lines, lex), profile["targets"])


def load_profile(path: Path) -> dict:
    path = Path(path)
    if not path.exists():
        raise SystemExit(
            f"missing {path}\nrun: python3 tools/style-profile/build_anchor_profile.py"
        )
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("schema") != anchor_lib.SCHEMA:
        raise SystemExit(f"{path} schema is {data.get('schema')!r}, expected {anchor_lib.SCHEMA}")
    if "targets" not in data:
        raise SystemExit(f"{path} has no targets. Rebuild it with build_anchor_profile.py")
    return data


def auc(positive: list[float], negative: list[float]):
    if not positive or not negative:
        return None
    wins = ties = 0
    for left in positive:
        for right in negative:
            if left > right:
                wins += 1
            elif left == right:
                ties += 1
    return (wins + 0.5 * ties) / (len(positive) * len(negative))


def _median(values: list[float]):
    if not values:
        return None
    ordered = sorted(values)
    mid = len(ordered) // 2
    if len(ordered) % 2:
        return ordered[mid]
    return (ordered[mid - 1] + ordered[mid]) / 2


def _mean(values: list[float]):
    return round(sum(values) / len(values), 2) if values else None


def _summary(values: list[float]) -> dict:
    if not values:
        return {"n": 0, "mean": None, "median": None, "p10": None, "p90": None}
    ordered = sorted(values)
    def pick(q):
        index = min(len(ordered) - 1, max(0, int(round(q * (len(ordered) - 1)))))
        return ordered[index]
    return {
        "n": len(ordered),
        "mean": _mean(ordered),
        "median": round(_median(ordered), 2),
        "p10": round(pick(0.10), 2),
        "p90": round(pick(0.90), 2),
    }


def choose_other_songs(metrics_path: Path, seed: int) -> tuple[list[dict], list[dict], list[str]]:
    by_artist = defaultdict(list)
    with open(metrics_path, encoding="utf-8") as handle:
        for line in handle:
            row = json.loads(line)
            if row.get("artist", "").lower() == "gunna":
                continue
            if (row.get("bars") or 0) < 24:
                continue
            by_artist[row["artist"]].append(row)
    peers, peer_keys = [], set()
    missing = []
    found_lower = {name.lower(): name for name in by_artist}
    for name in PEERS:
        actual = found_lower.get(name)
        if not actual:
            missing.append(name)
            continue
        songs = sorted(by_artist[actual], key=lambda row: -row["bars"])
        peers.extend(songs[:2])
        peer_keys.add(actual.lower())
    pool = [artist for artist in by_artist if artist.lower() not in peer_keys]
    random.Random(seed).shuffle(pool)
    random_songs = []
    for artist in pool[:24]:
        songs = sorted(by_artist[artist], key=lambda row: -row["bars"])
        random_songs.append(songs[0])
    return peers, random_songs, missing


def load_selected_songs(csv_path: Path, wanted: set[tuple[str, str]]) -> dict[tuple[str, str], list[str]]:
    import csv
    csv.field_size_limit(sys.maxsize)
    buckets = defaultdict(list)
    print(f"reading {len(wanted)} comparison songs from {csv_path} ...", file=sys.stderr)
    with open(csv_path, newline="", encoding="utf-8", errors="replace") as handle:
        reader = csv.reader(handle)
        header = next(reader)
        col = {name: index for index, name in enumerate(header)}
        art_i, song_i, text_i = col["artist"], col["song"], col["text_bar_line"]
        for row in reader:
            if len(row) <= text_i:
                continue
            artist, song, text = row[art_i].strip(), row[song_i].strip(), row[text_i].strip()
            key = (artist.lower(), song)
            if key not in wanted or not text:
                continue
            buckets[key].append((p1.trailing_number(row[0]), text))
    return {key: [text for _, text in sorted(pairs)] for key, pairs in buckets.items()}


def load_generated(db_path: Path, comparison_path: Path) -> list[list[str]]:
    groups = defaultdict(list)
    if db_path.exists():
        uri = f"file:{db_path}?mode=ro"
        try:
            connection = sqlite3.connect(uri, uri=True)
        except sqlite3.Error:
            connection = sqlite3.connect(str(db_path))
        try:
            for gid, _index, text in connection.execute(
                "SELECT generation_id, bar_index, text FROM generation_bars ORDER BY generation_id, bar_index"
            ):
                if text and str(text).strip():
                    groups[gid].append(str(text).strip())
        except sqlite3.Error as exc:
            print(f"could not read {db_path}: {exc}", file=sys.stderr)
        finally:
            connection.close()
    if comparison_path.exists():
        try:
            document = json.loads(comparison_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            document = {}
        models = document.get("models") or {}
        items = models.values() if isinstance(models, dict) else models
        for index, model in enumerate(items):
            bars = [bar.get("text", "").strip() for bar in model.get("bars") or [] if bar.get("text")]
            if bars:
                groups[f"comparison:{index}"] = bars
    verses = []
    seen = set()
    for lines in groups.values():
        if len(lines) < 4:
            continue
        chunk = lines[:4]
        key = tuple(p1.norm_line(text) for text in chunk)
        if key in seen or not any(key):
            continue
        seen.add(key)
        verses.append(lines)
    return verses


def _score_windows(verses: list[list[str]], targets: dict, lex: p1.Lexicon, size: int, cap: int = 3) -> list[dict]:
    scored = []
    for lines in verses:
        windows = anchor_lib.windows_from_lines(lines, size, cap=cap) if size else [lines]
        if size and not windows and len(lines) >= size:
            windows = [lines[:size]]
        for window in windows:
            if len(window) < size:
                continue
            result = score_features(anchor_lib.features_from_lines(window, lex), targets)
            scored.append(result)
    return scored


def _component_means(scored: list[dict]) -> dict:
    means = {}
    for name in WEIGHTS:
        values = [row["parts"][name] for row in scored if row["parts"].get(name) is not None]
        means[name] = _mean(values)
    return means


def _judge(name: str, value) -> str:
    if value is None:
        return f"{name}: not enough verses to score."
    if value < 0.60:
        return f"{name}: AUC {value:.2f}. The score does not separate real Gunna from this group."
    if value < 0.75:
        return f"{name}: AUC {value:.2f}. Weak separation. Do not trust a close call."
    return f"{name}: AUC {value:.2f}. The score ranks real Gunna above this group more often than not."


def prove(args) -> int:
    saved = load_profile(args.profile)
    built = anchor_lib.compute(args.csv, args.cmudict)
    fresh = built["profile"]
    if saved.get("totals", {}).get("raw_lines") != fresh["totals"]["raw_lines"]:
        print(
            "WARNING: the saved profile raw-line count does not match a fresh read. "
            "This report uses the fresh read. Re-run build_anchor_profile.py.",
            file=sys.stderr,
        )
    targets = fresh["targets"]
    lex = built["lex"]
    loo_rows = []
    insample_rows = []
    per_song = []
    for packet in built["packets"]:
        song = packet["song"]
        song_targets = anchor_lib.loo_targets(packet, built["packets"], built["catalog"])
        lines = built["lines"][(song["title"], song["album"])]
        windows4 = anchor_lib.windows_from_lines(lines, 4, cap=3)
        windows8 = anchor_lib.windows_from_lines(lines, 8, cap=2)
        song_loo = [score_features(anchor_lib.features_from_lines(window, lex), song_targets) for window in windows4]
        song_in = [score_features(anchor_lib.features_from_lines(window, lex), targets) for window in windows4]
        loo_rows.extend(song_loo)
        insample_rows.extend(song_in)
        per_song.append({
            "title": song["title"],
            "album": song["album"],
            "loo_n": len(song_loo),
            "loo_mean": _mean([row["score"] for row in song_loo]),
            "insample_mean": _mean([row["score"] for row in song_in]),
            "windows8": len(windows8),
        })

    peers, random_songs, missing_peers = choose_other_songs(args.metrics, args.seed)
    wanted = {(row["artist"].lower(), row["song"]) for row in peers + random_songs}
    loaded = load_selected_songs(args.csv, wanted)
    peer_lines, random_lines = [], []
    for row in peers:
        text = loaded.get((row["artist"].lower(), row["song"]))
        if text:
            peer_lines.append(text)
    for row in random_songs:
        text = loaded.get((row["artist"].lower(), row["song"]))
        if text:
            random_lines.append(text)
    peer_scored = _score_windows(peer_lines, targets, lex, 4, cap=3)
    random_scored = _score_windows(random_lines, targets, lex, 4, cap=3)
    generated_lines = load_generated(args.db, args.comparison)
    generated_scored = []
    for lines in generated_lines:
        generated_scored.append(score_features(anchor_lib.features_from_lines(lines[:4], lex), targets))

    loo8, peer8, random8 = [], [], []
    for packet in built["packets"]:
        song = packet["song"]
        song_targets = anchor_lib.loo_targets(packet, built["packets"], built["catalog"])
        lines = built["lines"][(song["title"], song["album"])]
        for window in anchor_lib.windows_from_lines(lines, 8, cap=2):
            loo8.append(score_features(anchor_lib.features_from_lines(window, lex), song_targets))
    peer8 = _score_windows(peer_lines, targets, lex, 8, cap=2)
    random8 = _score_windows(random_lines, targets, lex, 8, cap=2)

    groups = {
        "heldout_anchor_4": loo_rows,
        "insample_anchor_4": insample_rows,
        "peers_4": peer_scored,
        "random_artists_4": random_scored,
        "generator_4": generated_scored,
        "heldout_anchor_8": loo8,
        "peers_8": peer8,
        "random_artists_8": random8,
    }
    scores = {name: [row["score"] for row in rows] for name, rows in groups.items()}
    aucs = {
        "heldout_vs_peers_4": auc(scores["heldout_anchor_4"], scores["peers_4"]),
        "heldout_vs_random_4": auc(scores["heldout_anchor_4"], scores["random_artists_4"]),
        "heldout_vs_generator_4": auc(scores["heldout_anchor_4"], scores["generator_4"]),
        "insample_vs_peers_4": auc(scores["insample_anchor_4"], scores["peers_4"]),
        "heldout_vs_peers_8": auc(scores["heldout_anchor_8"], scores["peers_8"]),
        "heldout_vs_random_8": auc(scores["heldout_anchor_8"], scores["random_artists_8"]),
    }
    weak = []
    loo_parts = _component_means(loo_rows)
    peer_parts = _component_means(peer_scored)
    for name in WEIGHTS:
        left, right = loo_parts.get(name), peer_parts.get(name)
        if left is None or right is None:
            continue
        if left - right < 5:
            weak.append(f"{name} (held-out {left}, peers {right})")

    def confusion(pos, neg):
        if not pos or not neg:
            return None
        threshold = ( _median(pos) + _median(neg) ) / 2
        tp = sum(value >= threshold for value in pos)
        fp = sum(value >= threshold for value in neg)
        return {
            "threshold": round(threshold, 2),
            "threshold_note": "midpoint of the two medians on this same sample, not a cutoff trained in advance",
            "real_above": tp,
            "real_below": len(pos) - tp,
            "other_above": fp,
            "other_below": len(neg) - fp,
        }

    report = {
        "schema": "gunna_score_report.v1",
        "weights": WEIGHTS,
        "scales": SCALES,
        "saved_profile_raw_lines": saved.get("totals", {}).get("raw_lines"),
        "fresh_raw_lines": fresh["totals"]["raw_lines"],
        "missing_peers": missing_peers,
        "peers_found_songs": len(peer_lines),
        "random_songs": len(random_lines),
        "generator_verses": len(generated_scored),
        "groups": {name: _summary(values) for name, values in scores.items()},
        "components_4": {
            "heldout_anchor": loo_parts,
            "insample_anchor": _component_means(insample_rows),
            "peers": peer_parts,
            "random_artists": _component_means(random_scored),
            "generator": _component_means(generated_scored),
        },
        "auc": {key: None if value is None else round(value, 3) for key, value in aucs.items()},
        "weak_components_vs_peers": weak,
        "confusion_heldout_vs_peers_4": confusion(scores["heldout_anchor_4"], scores["peers_4"]),
        "confusion_heldout_vs_generator_4": confusion(scores["heldout_anchor_4"], scores["generator_4"]),
        "per_song_4": per_song,
        "verdict": [
            _judge("Held-out anchor vs peers (4 bars)", aucs["heldout_vs_peers_4"]),
            _judge("Held-out anchor vs random artists (4 bars)", aucs["heldout_vs_random_4"]),
            _judge("Held-out anchor vs current generator (4 bars)", aucs["heldout_vs_generator_4"]),
            _judge("Held-out anchor vs peers (8 bars)", aucs["heldout_vs_peers_8"]),
        ],
    }
    if weak:
        report["verdict"].append(
            "These components do not separate held-out Gunna from the peers by 5 points: " + ", ".join(weak) + "."
        )
    else:
        report["verdict"].append("Every component is at least 5 points higher on held-out Gunna than on the peers.")

    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    _print_report(report)
    print(f"\nwrote {args.report}")
    return 0


def _print_report(report: dict) -> None:
    print("Gunna-ness score proof. Higher means closer to the anchor profile.")
    print("4-bar windows are the fair comparison with the current generator. 8-bar windows are a second check.")
    print("Held-out scores use a profile that did not see that song. In-sample scores did, so they are optimistic.")
    print()
    print(f"{'group':<24} {'n':>5} {'mean':>8} {'median':>8} {'p10':>8} {'p90':>8}")
    for name, summary in report["groups"].items():
        def cell(key):
            value = summary[key]
            return "n/a" if value is None else f"{value:.1f}" if key != "n" else str(value)
        print(f"{name:<24} {summary['n']:>5} {cell('mean'):>8} {cell('median'):>8} {cell('p10'):>8} {cell('p90'):>8}")
    print()
    print("AUC (1.00 = held-out Gunna always scores higher, 0.50 = coin flip):")
    for name, value in report["auc"].items():
        shown = "n/a" if value is None else f"{value:.3f}"
        print(f"  {name:<28} {shown}")
    print()
    print("Component means on 4-bar windows (0-100):")
    header = f"{'component':<14}" + "".join(f"{name:>16}" for name in (
        "heldout", "insample", "peers", "random", "generator"))
    print(header)
    components = report["components_4"]
    keys = ("heldout_anchor", "insample_anchor", "peers", "random_artists", "generator")
    for name in WEIGHTS:
        cells = []
        for key in keys:
            value = components[key].get(name)
            cells.append(f"{value:.1f}" if value is not None else "n/a")
        print(f"{name:<14}" + "".join(f"{cell:>16}" for cell in cells))
    print()
    for line in report["verdict"]:
        print(line)
    print()
    peers = report["confusion_heldout_vs_peers_4"]
    if peers:
        print(
            f"Confusion vs peers at {peers['threshold']} ({peers['threshold_note']}): "
            f"real above {peers['real_above']}, real below {peers['real_below']}, "
            f"peers above {peers['other_above']}, peers below {peers['other_below']}."
        )
    gen = report["confusion_heldout_vs_generator_4"]
    if gen:
        print(
            f"Confusion vs generator at {gen['threshold']}: "
            f"real above {gen['real_above']}, real below {gen['real_below']}, "
            f"generator above {gen['other_above']}, generator below {gen['other_below']}."
        )
    if report["missing_peers"]:
        print("Peer names not in song_metrics: " + ", ".join(report["missing_peers"]))
    print()
    print("Per anchor song, mean 4-bar score:")
    for song in report["per_song_4"]:
        loo = "n/a" if song["loo_mean"] is None else f"{song['loo_mean']:.1f}"
        ins = "n/a" if song["insample_mean"] is None else f"{song['insample_mean']:.1f}"
        print(f"  {song['title']:<24} loo {loo:>6}  insample {ins:>6}  n={song['loo_n']}")


def cmd_score(args) -> int:
    profile = load_profile(args.profile)
    lines = [line.strip() for line in args.path.read_text(encoding="utf-8").splitlines() if line.strip()]
    if not lines:
        raise SystemExit(f"{args.path} has no lines")
    lex = p1.Lexicon(p1.load_cmudict(args.cmudict))
    result = score_lines(lines, profile, lex)
    print(json.dumps({"lines": len(lines), **result}, ensure_ascii=False, indent=1))
    return 0


def self_check() -> int:
    assert wasserstein({"10": 5}, {"10": 9}) == 0
    assert wasserstein({"10": 5}, {"14": 5}) == 4
    assert auc([3, 4, 5], [0, 1, 2]) == 1
    assert auc([1, 1], [1, 1]) == 0.5
    assert tent(1, 1, 0.5) == 1
    assert abs(js_divergence({"i": 10, "the": 10}, {"i": 10, "the": 10})) < 1e-9
    near = anchor_lib.blank_counts()
    far = anchor_lib.blank_counts()
    near["lines"] = near["measured"] = near["line_repeat_den"] = 8
    far["lines"] = far["measured"] = far["line_repeat_den"] = 8
    near["syl"][10] = 8
    far["syl"][3] = 8
    near["vowels"]["AY"] = 4
    near["vowels"]["OW"] = 4
    far["vowels"]["IY"] = 8
    near["dist1_hits"] = 4
    near["dist1_possible"] = 7
    far["dist1_possible"] = 7
    near["alt_possible"] = far["alt_possible"] = 6
    near["openers"]["i"] = 4
    near["openers"]["got"] = 4
    far["openers"]["the"] = 8
    near["consec"] = far["consec"] = 7
    near["content"]["wunna"] = 2
    near["content"]["coat"] = 18
    far["content"]["table"] = 20
    near["content_n"] = far["content_n"] = 20
    near["function"]["i"] = 10
    near["function"]["the"] = 8
    near["function"]["and"] = 2
    far["function"]["because"] = 20
    near["tokens"] = far["tokens"] = 40
    near["adlib_bars"] = 2
    near["adlib_pos"]["end"] = 2
    near["tri_repeat_den"] = far["tri_repeat_den"] = 10
    targets = {
        "syl_hist": {"10": 100}, "half_before_hist": {}, "half_after_hist": {},
        "comma_rate": 0.0, "vowel_share": {"AY": 0.5, "OW": 0.5},
        "dist1_rate": 0.5, "alt_rate": 0.0, "run3_share": 0.0, "identical_share": 0.0,
        "opener_top": ["i", "got"], "opener_hit_rate": 1.0,
        "same_first_rate": 0.0, "same_first2_rate": 0.0,
        "line_repeat_rate": 0.0, "trigram_repeat_rate": 0.0,
        "adlib_rate": 0.25, "adlib_pos_share": {"start": 0.0, "middle": 0.0, "end": 1.0},
        "function_counts": {"i": 50, "the": 40, "and": 10}, "function_rate": 0.5,
        "signature_set": ["wunna"], "signature_hit_rate": 0.1,
    }
    near_score = score_features(near, targets)["score"]
    far_score = score_features(far, targets)["score"]
    assert near_score > far_score + 15, (near_score, far_score)
    print(f"gunna_score self-check ok (near {near_score}, far {far_score})")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)
    check = sub.add_parser("self-check")
    check.set_defaults(fn=lambda args: self_check())
    proof = sub.add_parser("prove")
    proof.add_argument("--profile", type=Path, default=DEFAULT_PROFILE)
    proof.add_argument("--csv", type=Path, default=p1.DEFAULT_CSV)
    proof.add_argument("--cmudict", type=Path, default=p1.DEFAULT_CMU)
    proof.add_argument("--metrics", type=Path, default=DEFAULT_METRICS)
    proof.add_argument("--db", type=Path, default=DEFAULT_DB)
    proof.add_argument("--comparison", type=Path, default=DEFAULT_COMPARISON)
    proof.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    proof.add_argument("--seed", type=int, default=7)
    proof.set_defaults(fn=prove)
    score = sub.add_parser("score")
    score.add_argument("path", type=Path)
    score.add_argument("--profile", type=Path, default=DEFAULT_PROFILE)
    score.add_argument("--cmudict", type=Path, default=p1.DEFAULT_CMU)
    score.set_defaults(fn=cmd_score)
    args = parser.parse_args()
    return args.fn(args)


if __name__ == "__main__":
    raise SystemExit(main())
