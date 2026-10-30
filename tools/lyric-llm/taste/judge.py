"""Pairwise-logistic taste judge.

Trained to predict P(verse_a > verse_b) from feature vector differences.
Hand-rolled gradient descent (no sklearn dep). Serializes to JSON.
"""
from __future__ import annotations

import json
import math
import random
from pathlib import Path
from typing import Iterable, Sequence

HERE = Path(__file__).resolve().parent

from taste.features import FEATURE_KEYS, extract, vector  # noqa: E402


def _sigmoid(x: float) -> float:
    if x >= 0:
        z = math.exp(-x)
        return 1.0 / (1.0 + z)
    z = math.exp(x)
    return z / (1.0 + z)


class TasteJudge:
    def __init__(self, weights: Sequence[float] | None = None, bias: float = 0.0,
                 feature_mean: Sequence[float] | None = None,
                 feature_std: Sequence[float] | None = None):
        self.w = list(weights) if weights is not None else [0.0] * len(FEATURE_KEYS)
        self.b = float(bias)
        self.mean = list(feature_mean) if feature_mean is not None else [0.0] * len(FEATURE_KEYS)
        self.std = list(feature_std) if feature_std is not None else [1.0] * len(FEATURE_KEYS)

    def _norm(self, v: Sequence[float]) -> list[float]:
        return [(float(v[i]) - self.mean[i]) / (self.std[i] or 1.0) for i in range(len(v))]

    def margin(self, features: dict | Sequence[float]) -> float:
        v = vector(features) if isinstance(features, dict) else list(features)
        vn = self._norm(v)
        return self.b + sum(self.w[i] * vn[i] for i in range(len(vn)))

    def score_verse(self, bars: Iterable[str], voice: str | None = None) -> float:
        return self.margin(extract(bars, voice=voice))

    @classmethod
    def train(cls, pairs: list[tuple[list[float], list[float], int, dict]],
              epochs: int = 400, lr: float = 0.05, l2: float = 1e-3, seed: int = 20261029) -> "TasteJudge":
        if not pairs:
            raise ValueError("no training pairs")
        n_feat = len(FEATURE_KEYS)
        # compute normalization stats over all seen vectors
        all_vecs = [p[0] for p in pairs] + [p[1] for p in pairs]
        mean = [sum(v[i] for v in all_vecs) / len(all_vecs) for i in range(n_feat)]
        var = [sum((v[i] - mean[i]) ** 2 for v in all_vecs) / len(all_vecs) for i in range(n_feat)]
        std = [max(math.sqrt(v), 1e-6) for v in var]
        norm = lambda vec: [(vec[i] - mean[i]) / std[i] for i in range(n_feat)]
        w = [0.0] * n_feat
        b = 0.0
        rng = random.Random(seed)
        idx = list(range(len(pairs)))
        for epoch in range(epochs):
            rng.shuffle(idx)
            for k in idx:
                va, vb, label, _ = pairs[k]
                diff = [norm(va)[i] - norm(vb)[i] for i in range(n_feat)]
                z = b + sum(w[i] * diff[i] for i in range(n_feat))
                p = _sigmoid(z)
                err = p - label
                for i in range(n_feat):
                    w[i] -= lr * (err * diff[i] + l2 * w[i])
                b -= lr * err
        return cls(w, b, mean, std)

    def eval_accuracy(self, pairs: list[tuple[list[float], list[float], int, dict]]) -> float:
        if not pairs:
            return 0.0
        correct = 0
        for va, vb, label, _ in pairs:
            z = self.margin(va) - self.margin(vb)
            pred = 1 if z > 0 else 0
            if pred == label:
                correct += 1
        return correct / len(pairs)

    def to_dict(self) -> dict:
        return {
            "feature_keys": list(FEATURE_KEYS),
            "weights": self.w, "bias": self.b,
            "feature_mean": self.mean, "feature_std": self.std,
        }

    @classmethod
    def from_dict(cls, d: dict) -> "TasteJudge":
        return cls(d["weights"], d["bias"], d["feature_mean"], d["feature_std"])

    def save(self, path: Path | str) -> None:
        Path(path).write_text(json.dumps(self.to_dict(), indent=2))

    @classmethod
    def load(cls, path: Path | str) -> "TasteJudge":
        return cls.from_dict(json.loads(Path(path).read_text()))


# ---------- Spearman correlation (rank Pearson) ----------
def spearman(xs: Sequence[float], ys: Sequence[float]) -> float:
    if len(xs) != len(ys) or len(xs) < 2:
        return 0.0
    def rank(seq: Sequence[float]) -> list[float]:
        sorted_idx = sorted(range(len(seq)), key=lambda i: seq[i])
        ranks = [0.0] * len(seq)
        i = 0
        while i < len(sorted_idx):
            j = i
            while j + 1 < len(sorted_idx) and seq[sorted_idx[j + 1]] == seq[sorted_idx[i]]:
                j += 1
            avg = (i + j) / 2 + 1
            for k in range(i, j + 1):
                ranks[sorted_idx[k]] = avg
            i = j + 1
        return ranks
    rx, ry = rank(xs), rank(ys)
    mx = sum(rx) / len(rx)
    my = sum(ry) / len(ry)
    num = sum((rx[i] - mx) * (ry[i] - my) for i in range(len(rx)))
    denx = math.sqrt(sum((r - mx) ** 2 for r in rx))
    deny = math.sqrt(sum((r - my) ** 2 for r in ry))
    if denx == 0 or deny == 0:
        return 0.0
    return num / (denx * deny)
