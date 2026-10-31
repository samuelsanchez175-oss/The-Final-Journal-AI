#!/usr/bin/env python3
"""One retry ceiling shared by every Frontier v4 gate (Appendix A T3).

Gates that call consume() before a rewrite: grid, punch, entity, inner-rhyme.
Default max is 8 (env V4_MAX_RETRIES). When consume() returns False the bar
stays as it is and generation continues.
"""

from __future__ import annotations

import os
import sys


class RetryBudget:
    def __init__(self, max_retries: int | None = None):
        if max_retries is None:
            max_retries = int(os.environ.get("V4_MAX_RETRIES", "8"))
        self.max_retries = max(0, int(max_retries))
        self.used = 0
        self.exhausted_at: list[str] = []

    def consume(self, gate: str = "", bar: int | None = None) -> bool:
        if self.used >= self.max_retries:
            name = gate or "unknown"
            if name not in self.exhausted_at:
                self.exhausted_at.append(name)
            bar_label = "?" if bar is None else str(bar)
            print(
                f"[retry] exhausted gate={name} bar={bar_label}",
                file=sys.stderr,
            )
            return False
        self.used += 1
        return True
