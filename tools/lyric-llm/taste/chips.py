"""ChipIndex: retrieval over the exported chips.jsonl.

Rank order for retrieve(topic, end_rime, k):
  1. end-rime match (phonetic equality)
  2. category belongs to the topic's category list
  3. higher vault_count (frequency / proven usage)
  4. shorter chip (prefer concrete nouns over phrases)
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Iterable, Optional

HERE = Path(__file__).resolve().parent
LLM_ROOT = HERE.parent
DEFAULT_PATH = LLM_ROOT / "eval" / "chips.jsonl"
TOPIC_MAP_PATH = LLM_ROOT / "eval" / "chips_topic_map.json"


class ChipIndex:
    def __init__(self, rows: list[dict], topic_map: dict[str, list[str]] | None = None):
        self.rows = rows
        self.topic_map = {k.lower(): [c.lower() for c in v]
                          for k, v in (topic_map or {}).items()}
        # index by end_rime tuple
        self._by_rime: dict[tuple, list[int]] = {}
        for i, r in enumerate(rows):
            rime = tuple(r.get("end_rime") or ())
            if rime:
                self._by_rime.setdefault(rime, []).append(i)

    @classmethod
    def load(cls, path: Path | str | None = None,
             topic_map_path: Path | str | None = None) -> "ChipIndex":
        p = Path(path or DEFAULT_PATH)
        tp = Path(topic_map_path or TOPIC_MAP_PATH)
        rows = [json.loads(l) for l in p.read_text().splitlines() if l.strip()] if p.exists() else []
        tm = json.loads(tp.read_text()) if tp.exists() else {}
        return cls(rows, tm)

    def __len__(self) -> int:
        return len(self.rows)

    def categories_for_topic(self, topic: str) -> list[str]:
        return self.topic_map.get((topic or "").lower(), [])

    def retrieve(self, topic: Optional[str] = None,
                 end_rime: Optional[Iterable[str]] = None,
                 k: int = 8) -> list[dict]:
        if not self.rows:
            return []
        target_rime = tuple(end_rime) if end_rime else ()
        target_cats = set(self.categories_for_topic(topic or ""))

        def score(row: dict) -> tuple[int, int, int, int]:
            # higher is better in each slot
            rime_hit = 1 if (target_rime and tuple(row.get("end_rime") or ()) == target_rime) else 0
            cat_hit = 1 if row.get("category", "").lower() in target_cats else 0
            freq = int(row.get("vault_count") or 0)
            short = -len((row.get("chip") or "").split())
            return (rime_hit, cat_hit, freq, short)

        return sorted(self.rows, key=score, reverse=True)[:max(0, int(k))]

    def retrieve_many_rimes(self, topic: Optional[str], end_rimes: Iterable[Iterable[str]],
                            per_rime: int = 2, k: int = 8) -> list[dict]:
        """Pull a few chips per supplied end-rime so the planner sees a chip for
        each paired couplet rime."""
        seen = set()
        out: list[dict] = []
        target_cats = set(self.categories_for_topic(topic or ""))
        for rime in end_rimes:
            rime = tuple(rime or ())
            if not rime:
                continue
            indices = self._by_rime.get(rime, [])
            # Prefer category-matching, then frequency
            def sort_key(i):
                r = self.rows[i]
                return (1 if r.get("category", "").lower() in target_cats else 0,
                        int(r.get("vault_count") or 0),
                        -len((r.get("chip") or "").split()))
            for i in sorted(indices, key=sort_key, reverse=True)[:per_rime]:
                if i in seen:
                    continue
                seen.add(i)
                out.append(self.rows[i])
                if len(out) >= k:
                    return out
        # pad with topic-only matches if under k
        if len(out) < k and target_cats:
            for i, r in enumerate(self.rows):
                if i in seen:
                    continue
                if r.get("category", "").lower() in target_cats:
                    out.append(r); seen.add(i)
                    if len(out) >= k:
                        break
        return out
