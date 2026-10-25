#!/usr/bin/env python3
"""measure_entropy.py
===================
Computes Shannon entropy (in bits) of end-word distribution across generated bars or catalog batches.
Formula: H(X) = - sum(p(x) * log2(p(x)))
"""

from __future__ import annotations

import collections
import math
import sys
from typing import Sequence


def compute_shannon_entropy(words: Sequence[str]) -> float:
    """Compute Shannon entropy in bits for a sequence of tokens/end-words."""
    clean_words = [w.strip().lower() for w in words if w and w.strip()]
    if not clean_words:
        return 0.0

    counts = collections.Counter(clean_words)
    total = len(clean_words)
    entropy = 0.0
    for count in counts.values():
        p = count / total
        if p > 0:
            entropy -= p * math.log2(p)
    return round(entropy, 3)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Pass words as command line arguments or lines from stdin
        tokens = sys.argv[1:]
    else:
        tokens = [line.strip() for line in sys.stdin if line.strip()]

    h = compute_shannon_entropy(tokens)
    print(f"End-word Shannon Entropy: {h} bits across {len(tokens)} items")
