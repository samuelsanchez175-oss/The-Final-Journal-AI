#!/usr/bin/env python3
"""Train the taste judge; report Spearman correlation vs Samuel's real scores
and compare against the old char-suffix scorer."""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
LLM_ROOT = HERE.parent
sys.path.insert(0, str(LLM_ROOT))

from taste.dataset import iter_verse_rows, iter_bar_rewrite_pairs, build_pairs, build_bar_pairs  # noqa: E402
from taste.features import FEATURE_KEYS, vector  # noqa: E402
from taste.judge import TasteJudge, spearman  # noqa: E402

OUT_WEIGHTS = HERE / "weights.json"
OUT_REPORT = LLM_ROOT / "eval" / "taste_judge_report.md"


def _old_generic_score(bars: list[str]) -> float:
    """Mirror the old char-suffix generic scorer composite (pre-upgrade)."""
    import re, statistics
    _VOWELS = set("aeiou")
    def syls(w):
        w = re.sub(r"[^a-z]", "", w.lower())
        if not w: return 0
        c = 0; pv = False
        for ch in w:
            v = ch in _VOWELS
            if v and not pv: c += 1
            pv = v
        if w.endswith("e") and c > 1: c -= 1
        return max(c, 1)
    def line_syls(ln): return sum(syls(w) for w in re.findall(r"[A-Za-z']+", ln))
    def ew(ln):
        w = re.findall(r"[A-Za-z']+", ln)
        return w[-1].lower() if w else ""
    def rh(a, b): return bool(a) and bool(b) and (a[-2:] == b[-2:] or a[-3:] == b[-3:])
    if not bars: return 0.0
    sl = [line_syls(b) for b in bars]
    en = [ew(b) for b in bars]
    hits = sum(1 for i in range(1, len(en)) if rh(en[i-1], en[i]))
    rhyme = hits / max(len(en) - 1, 1)
    mean = statistics.mean(sl) if sl else 0.0
    cons = 1.0 - min(1.0, (statistics.pstdev(sl) / max(mean, 1.0)))
    return 0.5 * rhyme + 0.5 * cons


def main() -> int:
    rows = list(iter_verse_rows())
    print(f"loaded {len(rows)} rated verses")

    # 80/20 split by row (not pair) so held-out verses are disjoint
    rng = random.Random(20261029)
    rng.shuffle(rows)
    cut = int(len(rows) * 0.8)
    train_rows, test_rows = rows[:cut], rows[cut:]
    print(f"train={len(train_rows)}  test={len(test_rows)}")

    train_pairs = build_pairs(train_rows)
    print(f"within-batch verse pairs (train): {len(train_pairs)}")

    rewrite_pairs = build_bar_pairs(list(iter_bar_rewrite_pairs()))
    print(f"bar-rewrite pairs: {len(rewrite_pairs)}")

    all_pairs = train_pairs + rewrite_pairs
    judge = TasteJudge.train(all_pairs, epochs=400, lr=0.05, l2=1e-3)
    judge.save(OUT_WEIGHTS)
    print(f"saved {OUT_WEIGHTS}")

    # held-out: Spearman of judge-margin vs real verse_score
    xs = [judge.score_verse(r["bars"], voice=r["artist"]) for r in test_rows]
    ys = [r["score"] for r in test_rows]
    rho_judge = spearman(xs, ys)

    # baseline: old char-suffix composite
    xs_old = [_old_generic_score(r["bars"]) for r in test_rows]
    rho_old = spearman(xs_old, ys)

    # same, on training set, for sanity
    tr_xs = [judge.score_verse(r["bars"], voice=r["artist"]) for r in train_rows]
    tr_ys = [r["score"] for r in train_rows]
    rho_train = spearman(tr_xs, tr_ys)

    # pair accuracy (on held-out verse pairs)
    test_pairs = build_pairs(test_rows)
    pair_acc = judge.eval_accuracy(test_pairs)

    report = f"""# Taste judge — training report

**Branch:** `claude/taste-judge-wordplay`
**Rated verses:** {len(rows)} (train {len(train_rows)} / held-out {len(test_rows)})
**Within-batch training pairs:** {len(train_pairs)}
**Bar-rewrite pairs:** {len(rewrite_pairs)}

## Spearman correlation vs Samuel's real verse_score

| scorer | train rho | held-out rho |
| --- | ---:| ---:|
| new taste judge (pairwise logistic over 8 features) | {rho_train:.3f} | **{rho_judge:.3f}** |
| old char-suffix generic composite | — | {rho_old:.3f} |

**Held-out pair-accuracy:** {pair_acc:.3f}  ({len(test_pairs)} pairs)

## Learned weights (normalized)

| feature | weight |
| --- | ---:|
""" + "\n".join(f"| `{k}` | {w:+.3f} |" for k, w in zip(FEATURE_KEYS, judge.w)) + f"""
| bias | {judge.b:+.3f} |

Weights are over standardized features; sign shows direction, magnitude shows strength.

## Notes

- Training uses pairs where (a) same-batch verses with different scores (higher beats
  lower) and (b) bar-level `rewrite` beats bar `text` from Samuel's rewrites.
- Features: end-rhyme hit rate, multisyllable rhyme share, inner-rhyme mean,
  syllable mean/stdev, commas-per-bar, profanity rate, celebrity name leak count.
- No embeddings yet (keeps the model pure-python, no dependency wall);
  embeddings can bolt on later as additional feature columns.
- Weights: `{OUT_WEIGHTS.relative_to(LLM_ROOT.parent.parent)}`
"""
    OUT_REPORT.parent.mkdir(parents=True, exist_ok=True)
    OUT_REPORT.write_text(report)
    print(f"wrote {OUT_REPORT}")
    print()
    print(f"Spearman — judge (held-out): {rho_judge:+.3f}")
    print(f"Spearman — old scorer:       {rho_old:+.3f}")
    print(f"Held-out pair accuracy:      {pair_acc:.3f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
