#!/usr/bin/env python3
"""Learned style classifier for Model You / AI Sparkler (Task C).

Replaces heuristic gunna_score.py with a learned linear model over character n-grams (3-5),
word n-grams (1-2), and function-word density using pure stdlib Python (no numpy, no sklearn).

Gates:
  1. AUC >= 0.75 on held-out anchor verses vs peer artists (leave-one-song-out).
  2. AUC >= 0.75 on held-out anchor verses vs random artists.
  3. Spearman rank correlation > 0 against human verse_score across rater exports.

Usage:
  python3 tools/style-profile/style_scorer.py self-check
  python3 tools/style-profile/style_scorer.py train
  python3 tools/style-profile/style_scorer.py evaluate
  python3 tools/style-profile/style_scorer.py score path/to/verse.txt
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
import time
from collections import Counter, defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
sys.path.insert(0, str(HERE))

import phase1_song_metrics as p1

SCHEMA_VERSION = "style_scorer.v1"
REPORT_SCHEMA = "style_scorer_report.v1"

DEFAULT_MODEL = HERE / "out" / "style_scorer_gunna.json"
DEFAULT_REPORT = HERE / "out" / "style_scorer_report.json"
ANCHOR_DIR = HERE / "out" / "anchor-profile"
PEER_DIR = HERE / "out" / "peers"
RANDOM_DIR = HERE / "out" / "random"
RATINGS_DIR = HERE / "rater" / "exports"

STOPWORDS = frozenset(p1.STOPWORDS)

_MODEL_CACHE: dict[str, dict] = {}


# ---------------------------------------------------------------- feature extraction


def norm_line(text: str) -> str:
    """Normalize a line for stylistic analysis."""
    return p1.norm_line(text)


def extract_features(lines: list[str] | str) -> Counter:
    """Extract character n-grams (3-5), word n-grams (1-2), and function-word features.

    Returns a Counter of feature counts.
    """
    if isinstance(lines, str):
        lines = lines.splitlines()

    clean_lines = [norm_line(l) for l in lines if l and norm_line(l)]
    if not clean_lines:
        return Counter()

    feats = Counter()
    full_text = " $ ".join(clean_lines)

    # 1. Character n-grams (sizes 3, 4, 5)
    text_len = len(full_text)
    for n in (3, 4, 5):
        if text_len >= n:
            for i in range(text_len - n + 1):
                gram = full_text[i:i + n]
                feats[f"c{n}:{gram}"] += 1

    # 2. Word n-grams (1, 2) and function words
    total_words = 0
    total_stopwords = 0

    for l in clean_lines:
        words = l.split()
        total_words += len(words)
        for i, w in enumerate(words):
            feats[f"w1:{w}"] += 1
            if w in STOPWORDS:
                total_stopwords += 1
                feats[f"fw:{w}"] += 1
            if i + 1 < len(words):
                w2 = f"{w}_{words[i + 1]}"
                feats[f"w2:{w2}"] += 1

    # 3. Function word density bin
    if total_words > 0:
        ratio = total_stopwords / total_words
        bin_idx = min(9, int(ratio * 10))
        feats[f"fw_ratio:{bin_idx}"] += 1

    return feats


def extract_windows(lines: list[str], size: int = 4, stride: int = 2) -> list[list[str]]:
    """Slice a list of lines into overlapping windows."""
    clean = [l.strip() for l in lines if l and l.strip()]
    if not clean:
        return []
    if len(clean) <= size:
        return [clean]
    windows = []
    for i in range(0, len(clean) - size + 1, stride):
        windows.append(clean[i:i + size])
    return windows


def load_songs(source: Path | list[dict] | list[Path] | list[str]) -> list[dict]:
    """Load songs from a directory, list of files, or list of dicts."""
    if isinstance(source, Path):
        if source.is_dir():
            files = sorted(source.glob("*.json"))
            songs = []
            for f in files:
                try:
                    songs.append(json.loads(f.read_text(encoding="utf-8")))
                except Exception:
                    pass
            return songs
        elif source.is_file():
            return [json.loads(source.read_text(encoding="utf-8"))]
    elif isinstance(source, list):
        if source and isinstance(source[0], dict):
            return source
        elif source and isinstance(source[0], (str, Path)):
            songs = []
            for item in source:
                p = Path(item)
                if p.is_file():
                    try:
                        songs.append(json.loads(p.read_text(encoding="utf-8")))
                    except Exception:
                        pass
            return songs
    return []


# ---------------------------------------------------------------- metrics & math


def compute_auc(pos_scores: list[float], neg_scores: list[float]) -> float:
    """Mann-Whitney U statistic for Area Under the ROC Curve."""
    if not pos_scores or not neg_scores:
        return 0.5
    ranks = sorted([(s, 1) for s in pos_scores] + [(s, 0) for s in neg_scores], key=lambda x: x[0])
    n_pos = len(pos_scores)
    n_neg = len(neg_scores)
    rank_sum = 0.0
    i = 0
    n = len(ranks)
    while i < n:
        j = i
        while j < n and ranks[j][0] == ranks[i][0]:
            j += 1
        avg_rank = (i + 1 + j) / 2.0
        for k in range(i, j):
            if ranks[k][1] == 1:
                rank_sum += avg_rank
        i = j
    u_pos = rank_sum - (n_pos * (n_pos + 1)) / 2.0
    return u_pos / (n_pos * n_neg)


def spearman_correlation(x: list[float], y: list[float]) -> float:
    """Spearman rank correlation coefficient."""
    if len(x) < 2 or len(x) != len(y):
        return 0.0

    def get_ranks(vals: list[float]) -> list[float]:
        indexed = sorted(enumerate(vals), key=lambda item: item[1])
        ranks = [0.0] * len(vals)
        i = 0
        n = len(vals)
        while i < n:
            j = i
            while j < n and indexed[j][1] == indexed[i][1]:
                j += 1
            avg_rank = (i + 1 + j) / 2.0
            for k in range(i, j):
                ranks[indexed[k][0]] = avg_rank
            i = j
        return ranks

    rx = get_ranks(x)
    ry = get_ranks(y)
    n = len(x)
    mean_rx = sum(rx) / n
    mean_ry = sum(ry) / n
    cov = sum((rx[i] - mean_rx) * (ry[i] - mean_ry) for i in range(n))
    var_x = sum((rx[i] - mean_rx) ** 2 for i in range(n))
    var_y = sum((ry[i] - mean_ry) ** 2 for i in range(n))
    if var_x <= 0 or var_y <= 0:
        return 0.0
    return cov / math.sqrt(var_x * var_y)


def confusion_matrix(pos_scores: list[float], neg_scores: list[float], threshold: float = 0.5) -> dict:
    """Computes confusion matrix and classification metrics at a given threshold."""
    tp = sum(1 for s in pos_scores if s >= threshold)
    fn = len(pos_scores) - tp
    fp = sum(1 for s in neg_scores if s >= threshold)
    tn = len(neg_scores) - fp
    total = tp + fn + fp + tn
    accuracy = (tp + tn) / total if total > 0 else 0.0
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0.0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0.0
    return {
        "threshold": threshold,
        "tp": tp,
        "fn": fn,
        "fp": fp,
        "tn": tn,
        "accuracy": round(accuracy, 4),
        "precision": round(precision, 4),
        "recall": round(recall, 4),
    }


# ---------------------------------------------------------------- classifier model


class StyleClassifier:
    """Pure stdlib linear log-odds classifier with sublinear TF and L2 normalization."""

    def __init__(
        self,
        alpha: float = 1.0,
        min_df: int = 2,
        top_k: int = 4000,
        scale: float = 8.0,
        weights: dict[str, float] | None = None,
        bias: float = 0.0,
        artist: str = "Gunna",
    ):
        self.alpha = alpha
        self.min_df = min_df
        self.top_k = top_k
        self.scale = scale
        self.weights = weights or {}
        self.bias = bias
        self.artist = artist

    def fit(self, pos_docs: list[list[str]], neg_docs: list[list[str]]):
        pos_feats = [extract_features(doc) for doc in pos_docs]
        neg_feats = [extract_features(doc) for doc in neg_docs]

        pos_df = Counter()
        for f in pos_feats:
            for k in f:
                pos_df[k] += 1

        neg_df = Counter()
        for f in neg_feats:
            for k in f:
                neg_df[k] += 1

        n_pos = len(pos_docs)
        n_neg = len(neg_docs)
        if n_pos == 0 or n_neg == 0:
            return

        # Filter by minimum document frequency
        all_keys = set(pos_df.keys()) | set(neg_df.keys())
        candidates = [k for k in all_keys if (pos_df[k] + neg_df[k]) >= self.min_df]

        # Feature selection: difference in document occurrence proportion
        def feature_relevance(k: str) -> float:
            p_p = pos_df[k] / n_pos
            p_n = neg_df[k] / n_neg
            return abs(p_p - p_n)

        candidates.sort(key=feature_relevance, reverse=True)
        selected_vocab = set(candidates[:self.top_k])

        # Aggregate total term counts per class for selected vocabulary
        c_pos = Counter()
        for f in pos_feats:
            for k, count in f.items():
                if k in selected_vocab:
                    c_pos[k] += count

        c_neg = Counter()
        for f in neg_feats:
            for k, count in f.items():
                if k in selected_vocab:
                    c_neg[k] += count

        tot_pos = sum(c_pos.values())
        tot_neg = sum(c_neg.values())
        v_size = len(selected_vocab)

        self.weights = {}
        for k in selected_vocab:
            p_pos = (c_pos[k] + self.alpha) / (tot_pos + self.alpha * v_size)
            p_neg = (c_neg[k] + self.alpha) / (tot_neg + self.alpha * v_size)
            self.weights[k] = math.log(p_pos / p_neg)

        self.bias = 0.0

    def score(self, text: list[str] | str) -> float:
        """Returns the probability in [0.0, 1.0] that the text matches this artist's style."""
        if not self.weights:
            return 0.5
        feats = extract_features(text)
        if not feats:
            return 0.5

        norm_factor = 0.0
        vec = {}
        for k, count in feats.items():
            if k in self.weights:
                val = 1.0 + math.log(count)
                vec[k] = val
                norm_factor += val * val

        if norm_factor <= 0.0:
            return 0.5

        norm = math.sqrt(norm_factor)
        dot = sum(val * self.weights[k] for k, val in vec.items()) / norm
        z = dot * self.scale

        # Clamp to avoid numerical overflow in exp
        z = max(-20.0, min(20.0, z))
        return 1.0 / (1.0 + math.exp(-z))

    def to_dict(self) -> dict:
        return {
            "schema": SCHEMA_VERSION,
            "artist": self.artist,
            "trained_at": time.time(),
            "alpha": self.alpha,
            "min_df": self.min_df,
            "top_k": self.top_k,
            "scale": self.scale,
            "bias": self.bias,
            "weights_count": len(self.weights),
            "weights": self.weights,
        }

    @classmethod
    def from_dict(cls, data: dict) -> StyleClassifier:
        return cls(
            alpha=data.get("alpha", 1.0),
            min_df=data.get("min_df", 2),
            top_k=data.get("top_k", 4000),
            scale=data.get("scale", 8.0),
            weights=data.get("weights", {}),
            bias=data.get("bias", 0.0),
            artist=data.get("artist", "Gunna"),
        )


def load(model_path: Path | str | dict | None = None) -> StyleClassifier | None:
    """Load or retrieve cached StyleClassifier."""
    if model_path is None:
        model_path = DEFAULT_MODEL
    if isinstance(model_path, dict):
        return StyleClassifier.from_dict(model_path)

    p = Path(model_path)
    p_str = str(p.resolve())
    if p_str in _MODEL_CACHE:
        return _MODEL_CACHE[p_str]

    if not p.exists():
        return None

    try:
        data = json.loads(p.read_text(encoding="utf-8"))
        clf = StyleClassifier.from_dict(data)
        _MODEL_CACHE[p_str] = clf
        return clf
    except Exception:
        return None


# ---------------------------------------------------------------- train, score, evaluate


def train(
    anchor_songs: Path | list[dict] | list[Path] | list[str],
    peer_songs: Path | list[dict] | list[Path] | list[str],
    out_path: Path | str = DEFAULT_MODEL,
    random_songs: Path | list[dict] | list[Path] | list[str] | None = None,
    artist: str = "Gunna",
    window_size: int = 4,
    stride: int = 2,
    alpha: float = 1.0,
    top_k: int = 4000,
) -> StyleClassifier:
    """Train a style classifier on anchor songs vs peer songs (and random songs)."""
    anchors = load_songs(anchor_songs)
    peers = load_songs(peer_songs)
    randoms = load_songs(random_songs) if random_songs else []

    if not anchors or not peers:
        raise ValueError("Must provide at least one anchor song and one peer song.")

    pos_windows = []
    for s in anchors:
        pos_windows.extend(extract_windows(s.get("lines", []), size=window_size, stride=stride))

    neg_windows = []
    for s in peers:
        neg_windows.extend(extract_windows(s.get("lines", []), size=window_size, stride=stride * 2))
    for s in randoms:
        neg_windows.extend(extract_windows(s.get("lines", []), size=window_size, stride=stride * 2))

    clf = StyleClassifier(alpha=alpha, min_df=2, top_k=top_k, artist=artist)
    clf.fit(pos_windows, neg_windows)

    out = Path(out_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(clf.to_dict(), ensure_ascii=False, indent=1), encoding="utf-8")
    _MODEL_CACHE[str(out.resolve())] = clf
    return clf


def score(text: list[str] | str, model_path: Path | str | dict | None = None) -> float:
    """Score text against the trained style model. Returns float in [0.0, 1.0]."""
    clf = load(model_path)
    if clf is None:
        return 0.5
    return clf.score(text)


def evaluate(
    model_path: Path | str = DEFAULT_MODEL,
    held_out_songs: Path | list[dict] | None = None,
    peer_songs: Path | list[dict] | None = None,
    random_songs: Path | list[dict] | None = None,
    rater_exports: Path | str | None = RATINGS_DIR,
    report_path: Path | str | None = DEFAULT_REPORT,
) -> dict:
    """Evaluate model on held-out anchor songs, peers, random artists, and rater exports."""
    anchors = load_songs(held_out_songs or ANCHOR_DIR)
    peers = load_songs(peer_songs or PEER_DIR)
    randoms = load_songs(random_songs or RANDOM_DIR) if random_songs or RANDOM_DIR.exists() else []

    # 1. Leave-One-Song-Out (LOO) evaluation on anchor songs
    peer_windows = []
    for s in peers:
        peer_windows.extend(extract_windows(s.get("lines", []), size=4, stride=2))

    random_windows = []
    for s in randoms:
        random_windows.extend(extract_windows(s.get("lines", []), size=4, stride=2))

    neg_train = peer_windows[::2] + (random_windows[::2] if random_windows else [])

    loo_anchor_scores = []
    per_song_loo = []

    for i in range(len(anchors)):
        test_song = anchors[i]
        train_anchors = [s for j, s in enumerate(anchors) if j != i]

        train_pos = []
        for s in train_anchors:
            train_pos.extend(extract_windows(s.get("lines", []), size=4, stride=2))

        loo_clf = StyleClassifier(alpha=1.0, min_df=2, top_k=4000)
        loo_clf.fit(train_pos, neg_train)

        test_windows = extract_windows(test_song.get("lines", []), size=4, stride=2)
        song_scores = [loo_clf.score(w) for w in test_windows] if test_windows else [0.5]
        loo_anchor_scores.extend(song_scores)
        per_song_loo.append({
            "title": test_song.get("title", f"song_{i}"),
            "album": test_song.get("album", ""),
            "n_windows": len(song_scores),
            "mean_score": round(sum(song_scores) / len(song_scores), 4) if song_scores else 0.5,
        })

    # Full model for peer and random test sets
    clf = load(model_path)
    if clf is None:
        # Train full model if missing
        clf = train(anchors, peers, out_path=model_path, random_songs=randoms)

    peer_test_scores = [clf.score(w) for w in peer_windows]
    random_test_scores = [clf.score(w) for w in random_windows] if random_windows else []

    auc_heldout_vs_peers = round(compute_auc(loo_anchor_scores, peer_test_scores), 4)
    auc_heldout_vs_random = round(compute_auc(loo_anchor_scores, random_test_scores), 4) if random_test_scores else 0.0

    confusion_peers = confusion_matrix(loo_anchor_scores, peer_test_scores, threshold=0.5)

    # 2. Spearman correlation vs human verse_score on rater exports
    spearman_val = 0.0
    rated_count = 0
    if rater_exports:
        r_dir = Path(rater_exports)
        if r_dir.exists():
            # Build index of generation_id -> bars from rater-batch files
            gid_to_bars = {}
            for p in (HERE / "out").rglob("*.json"):
                if "rater" in str(p) or "mimic" in str(p):
                    try:
                        doc = json.loads(p.read_text(encoding="utf-8"))
                        for model_key, model_data in (doc.get("models") or {}).items():
                            gid = model_data.get("generation_id")
                            bars = [b.get("text", "") for b in model_data.get("bars", []) if b.get("text")]
                            if gid and bars:
                                gid_to_bars[gid] = bars
                    except Exception:
                        pass

            rated_tuples = []
            files = sorted(r_dir.glob("sparkler_ratings_*.json")) if r_dir.is_dir() else [r_dir]
            for p in files:
                try:
                    data = json.loads(p.read_text(encoding="utf-8"))
                except Exception:
                    continue
                if data.get("schema") == "sparkler.ratings.v1" and data.get("rater") != "sparkler-grader":
                    for r in data.get("ratings", []):
                        vs = r.get("verse_score")
                        if vs is not None:
                            gid = r.get("generation_id")
                            bars = gid_to_bars.get(gid)
                            if not bars and r.get("bar_votes"):
                                bars = [b.get("text", "") for b in r.get("bar_votes", []) if b.get("text")]
                            if bars:
                                rated_tuples.append((vs, bars))

            if rated_tuples:
                pred_scores = [clf.score(bars) for vs, bars in rated_tuples]
                human_scores = [vs for vs, bars in rated_tuples]
                spearman_val = round(spearman_correlation(pred_scores, human_scores), 4)
                rated_count = len(rated_tuples)

    gate_1 = auc_heldout_vs_peers >= 0.75
    gate_2 = auc_heldout_vs_random >= 0.75
    gate_3 = spearman_val > 0.0
    cleared = gate_1 and gate_2 and gate_3

    report = {
        "schema": REPORT_SCHEMA,
        "model_path": str(model_path),
        "evaluated_at": time.time(),
        "n_anchors": len(anchors),
        "n_peers": len(peers),
        "n_random": len(randoms),
        "n_heldout_windows": len(loo_anchor_scores),
        "n_peer_windows": len(peer_windows),
        "n_random_windows": len(random_windows),
        "n_rated_verses": rated_count,
        "gates": {
            "gate_1_heldout_vs_peers_auc_ge_0_75": {
                "threshold": 0.75,
                "achieved": auc_heldout_vs_peers,
                "passed": gate_1,
            },
            "gate_2_heldout_vs_random_auc_ge_0_75": {
                "threshold": 0.75,
                "achieved": auc_heldout_vs_random,
                "passed": gate_2,
            },
            "gate_3_spearman_vs_verse_score_gt_0": {
                "threshold": 0.0,
                "achieved": spearman_val,
                "passed": gate_3,
            },
            "all_gates_cleared": cleared,
        },
        "auc": {
            "heldout_vs_peers_loo": auc_heldout_vs_peers,
            "heldout_vs_random_loo": auc_heldout_vs_random,
        },
        "spearman_vs_verse_score": spearman_val,
        "confusion_heldout_vs_peers": confusion_peers,
        "per_song_loo": per_song_loo,
        "verdict": (
            "ALL GATES CLEARED: style_scorer replaces gunna_score"
            if cleared else
            "GATES NOT MET: fallback to generation order"
        ),
    }

    if report_path:
        out_rep = Path(report_path)
        out_rep.parent.mkdir(parents=True, exist_ok=True)
        out_rep.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    return report


def passes_gate(model_path_or_report: Path | str | dict | None = None) -> bool:
    """Returns True if the model clears all 3 gates."""
    if isinstance(model_path_or_report, dict):
        if "gates" in model_path_or_report:
            return bool(model_path_or_report["gates"].get("all_gates_cleared"))
        if "metrics" in model_path_or_report:
            return bool(model_path_or_report["metrics"].get("passes_gate"))

    # Check report file if exists
    rep_path = DEFAULT_REPORT
    if isinstance(model_path_or_report, (str, Path)):
        p = Path(model_path_or_report)
        if p.name.endswith("report.json"):
            rep_path = p
        elif p.with_name("style_scorer_report.json").exists():
            rep_path = p.with_name("style_scorer_report.json")

    if rep_path.exists():
        try:
            data = json.loads(rep_path.read_text(encoding="utf-8"))
            return bool(data.get("gates", {}).get("all_gates_cleared"))
        except Exception:
            pass
    return False


# ---------------------------------------------------------------- CLI & Self-Check


def self_check() -> int:
    """Fast deterministic self-check on synthetic separation."""
    pos_data = [
        ["I'm in the coupe with the drip on the seat", "Diamonds so clear you can see where we meet",
         "Hundred racks cash in the back of the whip", "Bought her new Bottega, we take a new trip"],
        ["Swervin' in traffic, the Hellcat is loud", "Stood on the block and I made momma proud",
         "Pockets on heavy, they think that it's fake", "Count up the blue notes, avoid every snake"],
    ]
    neg_data = [
        ["The quick brown fox jumps over the dog", "Walking at dawn through the heavy grey fog",
         "Reading a novel while sitting alone", "Waiting for someone to call on the phone"],
        ["Standard academic prose discusses theory", "Students of physics grow tired and weary",
         "Calculus lectures on integrals run", "Writing the homework before setting sun"],
    ]

    clf = StyleClassifier(alpha=1.0, min_df=1, top_k=500)
    clf.fit(pos_data, neg_data)

    test_pos = ["Coupe with the drip, diamonds so bright", "Hundred racks cash in the middle of night"]
    test_neg = ["The professor explained the equation today", "Students took notes and then went on their way"]

    score_pos = clf.score(test_pos)
    score_neg = clf.score(test_neg)

    assert score_pos > score_neg, f"Expected pos ({score_pos}) > neg ({score_neg})"
    assert 0.0 <= score_pos <= 1.0 and 0.0 <= score_neg <= 1.0

    # Test AUC calculation
    auc = compute_auc([score_pos], [score_neg])
    assert auc == 1.0, f"Expected AUC 1.0, got {auc}"

    # Test Spearman calculation
    spear = spearman_correlation([1, 2, 3, 4], [2, 4, 6, 8])
    assert spear == 1.0, f"Expected Spearman 1.0, got {spear}"

    print(f"style_scorer self-check ok (pos {score_pos:.3f}, neg {score_neg:.3f}, auc {auc})")
    return 0


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] == "self-check":
        return self_check()

    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="command")

    sub.add_parser("self-check")

    p_train = sub.add_parser("train", help="train style classifier")
    p_train.add_argument("--anchors", type=Path, default=ANCHOR_DIR)
    p_train.add_argument("--peers", type=Path, default=PEER_DIR)
    p_train.add_argument("--random", type=Path, default=RANDOM_DIR)
    p_train.add_argument("--out", type=Path, default=DEFAULT_MODEL)

    p_eval = sub.add_parser("evaluate", help="evaluate classifier against gates")
    p_eval.add_argument("--model", type=Path, default=DEFAULT_MODEL)
    p_eval.add_argument("--anchors", type=Path, default=ANCHOR_DIR)
    p_eval.add_argument("--peers", type=Path, default=PEER_DIR)
    p_eval.add_argument("--random", type=Path, default=RANDOM_DIR)
    p_eval.add_argument("--rater-exports", type=Path, default=RATINGS_DIR)
    p_eval.add_argument("--report", type=Path, default=DEFAULT_REPORT)

    p_score = sub.add_parser("score", help="score verse lines")
    p_score.add_argument("verse_path", type=Path, help="path to verse file or - for stdin")
    p_score.add_argument("--model", type=Path, default=DEFAULT_MODEL)

    args = ap.parse_args()

    if args.command == "train":
        print(f"Training style classifier on {args.anchors} vs {args.peers} + {args.random}...")
        clf = train(args.anchors, args.peers, out_path=args.out, random_songs=args.random)
        print(f"Saved model to {args.out} ({len(clf.weights)} weights)")
        return 0

    if args.command == "evaluate":
        print(f"Evaluating {args.model} against gates...")
        rep = evaluate(
            model_path=args.model,
            held_out_songs=args.anchors,
            peer_songs=args.peers,
            random_songs=args.random,
            rater_exports=args.rater_exports,
            report_path=args.report,
        )
        print(json.dumps(rep["gates"], indent=2))
        print(f"Verdict: {rep['verdict']}")
        print(f"Wrote full report to {args.report}")
        return 0 if rep["gates"]["all_gates_cleared"] else 1

    if args.command == "score":
        text = sys.stdin.read() if str(args.verse_path) == "-" else args.verse_path.read_text(encoding="utf-8")
        val = score(text, args.model)
        print(f"score: {val}")
        return 0

    ap.print_help()
    return 0


if __name__ == "__main__":
    sys.exit(main())
