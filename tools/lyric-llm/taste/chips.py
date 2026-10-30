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

# Nouns you can point at. CHIP_BANK suggestions rank these ahead of slang.
CONCRETE_CHIP_CATEGORIES = frozenset({
    "brands", "cars", "jewelry", "jewelers", "places",
})

# Named generic slang, plus any chip whose last word is "shit".
_GENERIC_SLANG_EXACT = frozenset({"dog shit", "opp shit", "cash out"})


def _chip_key(chip: str) -> str:
    text = (chip or "").lower().replace("\u2019", "'").replace("'", "")
    return " ".join(text.split())


def is_generic_slang_chip(chip: str) -> bool:
    """True for generic slang such as dog shit, opp shit, and cash out."""
    key = _chip_key(chip)
    if not key or key in _GENERIC_SLANG_EXACT:
        return bool(key)
    return key.split()[-1] == "shit"


def slang_chip_names(rows: list[dict]) -> list[str]:
    """Chip strings the suggestion filter drops, in bank order."""
    names: list[str] = []
    seen: set[str] = set()
    for row in rows:
        chip = str(row.get("chip") or "").strip()
        key = _chip_key(chip)
        if chip and key not in seen and is_generic_slang_chip(chip):
            seen.add(key)
            names.append(chip)
    return names


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

        def score(row: dict) -> tuple[int, int, int, int, int]:
            # higher is better in each slot
            rime_hit = 1 if (target_rime and tuple(row.get("end_rime") or ()) == target_rime) else 0
            cat_hit = 1 if row.get("category", "").lower() in target_cats else 0
            concrete = 1 if row.get("category", "").lower() in CONCRETE_CHIP_CATEGORIES else 0
            freq = int(row.get("vault_count") or 0)
            short = -len((row.get("chip") or "").split())
            return (rime_hit, cat_hit, concrete, freq, short)

        pool = [row for row in self.rows if not is_generic_slang_chip(row.get("chip") or "")]
        return sorted(pool, key=score, reverse=True)[:max(0, int(k))]

    def retrieve_many_rimes(self, topic: Optional[str], end_rimes: Iterable[Iterable[str]],
                            per_rime: int = 2, k: int = 8) -> list[dict]:
        """Pull a few chips per supplied end-rime so the planner sees a chip for
        each paired couplet rime."""
        seen = set()
        out: list[dict] = []
        target_cats = set(self.categories_for_topic(topic or ""))

        def _usable(index: int) -> bool:
            return not is_generic_slang_chip(self.rows[index].get("chip") or "")

        def sort_key(i):
            row = self.rows[i]
            category = row.get("category", "").lower()
            return (
                1 if category in CONCRETE_CHIP_CATEGORIES else 0,
                1 if category in target_cats else 0,
                int(row.get("vault_count") or 0),
                -len((row.get("chip") or "").split()),
            )

        for rime in end_rimes:
            rime = tuple(rime or ())
            if not rime:
                continue
            indices = [i for i in self._by_rime.get(rime, []) if _usable(i)]
            for i in sorted(indices, key=sort_key, reverse=True)[:per_rime]:
                if i in seen:
                    continue
                seen.add(i)
                out.append(self.rows[i])
                if len(out) >= k:
                    return out
        # Pad with concrete nouns, then the topic's other categories.
        if len(out) < k:
            rest = [i for i in range(len(self.rows)) if i not in seen and _usable(i)]
            rest.sort(key=sort_key, reverse=True)
            for i in rest:
                row = self.rows[i]
                category = row.get("category", "").lower()
                if category not in CONCRETE_CHIP_CATEGORIES and category not in target_cats:
                    continue
                out.append(row)
                seen.add(i)
                if len(out) >= k:
                    break
        return out
