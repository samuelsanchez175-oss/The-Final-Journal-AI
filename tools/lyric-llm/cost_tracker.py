#!/usr/bin/env python3
"""Per-generation cost ceiling for Frontier v4 (Appendix A T1).

Pricing is pinned in tools/lyric-llm/model_pricing.json under "rates".
Do not fetch provider price pages at runtime. Update the JSON by hand.
Thinking tokens are billed on their own. They use thinking_per_mtok when
that field is set, and the completion rate otherwise.

CostBudgetExceeded subclasses BaseException so retry loops that catch
Exception cannot hide a blown verse budget.
"""

from __future__ import annotations

import contextvars
import json
import os
import sys
from pathlib import Path
from typing import Any, Optional

HERE = Path(__file__).resolve().parent
PRICING_PATH = HERE / "model_pricing.json"

_CURRENT: contextvars.ContextVar[Optional["CostTracker"]] = contextvars.ContextVar(
    "v4_cost_tracker",
    default=None,
)


class CostBudgetExceeded(BaseException):
    """Raised when one verse's running cost passes its ceiling."""


def default_verse_budget() -> float:
    raw = os.environ.get("V4_PER_VERSE_BUDGET", "").strip()
    if not raw:
        return 0.50
    return float(raw)


def load_rates(path: Path = PRICING_PATH) -> dict[str, dict[str, float]]:
    """Return model id -> {prompt_per_mtok, completion_per_mtok, thinking_per_mtok?}."""
    with path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)
    rates = payload.get("rates") or {}
    cleaned: dict[str, dict[str, float]] = {}
    for model, row in rates.items():
        if not isinstance(row, dict):
            continue
        if "prompt_per_mtok" not in row or "completion_per_mtok" not in row:
            continue
        item = {
            "prompt_per_mtok": float(row["prompt_per_mtok"]),
            "completion_per_mtok": float(row["completion_per_mtok"]),
        }
        if row.get("thinking_per_mtok") is not None:
            item["thinking_per_mtok"] = float(row["thinking_per_mtok"])
        cleaned[str(model)] = item
    return cleaned


def _max_rate(table: dict[str, dict[str, float]]) -> dict[str, float]:
    prompt = max(row["prompt_per_mtok"] for row in table.values())
    completion = max(row["completion_per_mtok"] for row in table.values())
    return {"prompt_per_mtok": prompt, "completion_per_mtok": completion}


def rates_for(model: str, table: Optional[dict[str, dict[str, float]]] = None) -> dict[str, float]:
    table = table if table is not None else load_rates()
    if model in table:
        return table[model]
    low = (model or "").lower()
    for key, row in table.items():
        if key.lower() == low:
            return row
    print(
        f"[cost] unknown model {model}; using the highest pinned rate",
        file=sys.stderr,
    )
    return _max_rate(table)


def price_usd(
    prompt_tokens: int,
    completion_tokens: int,
    thinking_tokens: int,
    rates: dict[str, float],
) -> float:
    prompt_rate = float(rates["prompt_per_mtok"])
    completion_rate = float(rates["completion_per_mtok"])
    thinking_rate = float(rates.get("thinking_per_mtok", completion_rate))
    return (
        prompt_tokens * prompt_rate
        + completion_tokens * completion_rate
        + thinking_tokens * thinking_rate
    ) / 1_000_000.0


class CostTracker:
    def __init__(self, generation_id: str, budget: Optional[float] = None, pricing_path: Path = PRICING_PATH):
        self.generation_id = generation_id or "verse"
        self.budget = default_verse_budget() if budget is None else float(budget)
        self.pricing_path = pricing_path
        self._rates = load_rates(pricing_path)
        self._usd = 0.0
        self.events: list[dict[str, Any]] = []

    def total_usd(self) -> float:
        return self._usd

    def exceeds(self, budget: float) -> bool:
        return self._usd > float(budget)

    def record(
        self,
        model: str,
        prompt_tokens: int,
        completion_tokens: int,
        thinking_tokens: int = 0,
    ) -> float:
        rates = rates_for(model, self._rates)
        prompt_tokens = int(prompt_tokens or 0)
        completion_tokens = int(completion_tokens or 0)
        thinking_tokens = int(thinking_tokens or 0)
        self._usd += price_usd(prompt_tokens, completion_tokens, thinking_tokens, rates)
        self.events.append(
            {
                "model": model,
                "prompt_tokens": prompt_tokens,
                "completion_tokens": completion_tokens,
                "thinking_tokens": thinking_tokens,
                "running_usd": self._usd,
            }
        )
        # Four decimals so a sub-cent call does not log as $0.00.
        print(
            f"[cost] generation={self.generation_id} model={model} "
            f"prompt={prompt_tokens} completion={completion_tokens} "
            f"running=${self._usd:.4f} budget=${self.budget:.2f}",
            file=sys.stderr,
        )
        if self.exceeds(self.budget):
            raise CostBudgetExceeded(
                f"[cost] budget exceeded generation={self.generation_id} "
                f"running=${self._usd:.4f} budget=${self.budget:.2f}"
            )
        return self._usd


def bind_cost_tracker(tracker: CostTracker):
    return _CURRENT.set(tracker)


def unbind_cost_tracker(token) -> None:
    _CURRENT.reset(token)


def current() -> Optional[CostTracker]:
    return _CURRENT.get()


def _as_int(value: Any) -> Optional[int]:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return None
    return int(value)


def usage_from(response: Any, system: str, user: str, text: str) -> tuple[int, int, int]:
    """Read provider usage. Estimate from characters when the SDK omits it."""
    usage = getattr(response, "usage", None)
    prompt = completion = thinking = None
    if usage is not None:
        prompt = _as_int(getattr(usage, "input_tokens", None))
        if prompt is None:
            prompt = _as_int(getattr(usage, "prompt_tokens", None))
        completion = _as_int(getattr(usage, "output_tokens", None))
        if completion is None:
            completion = _as_int(getattr(usage, "completion_tokens", None))
        thinking = _as_int(getattr(usage, "thinking_tokens", None))
        if thinking is None:
            thinking = _as_int(getattr(usage, "reasoning_tokens", None))
        details = getattr(usage, "completion_tokens_details", None)
        if thinking is None and details is not None:
            thinking = _as_int(getattr(details, "reasoning_tokens", None))
    if prompt is None or completion is None:
        prompt = max(1, (len(system or "") + len(user or "")) // 4)
        completion = max(0, len(text or "") // 4)
        thinking = 0
    # OpenAI folds reasoning tokens into completion_tokens. Bill them once
    # at the completion rate unless the pin lists a separate thinking rate.
    thinking = thinking or 0
    return prompt, completion, thinking


def note_chat(model: str, system: str, user: str, text: str, response: Any) -> None:
    tracker = current()
    if tracker is None:
        return
    prompt, completion, thinking = usage_from(response, system, user, text)
    rates = rates_for(model, tracker._rates)
    thinking_rate = float(rates.get("thinking_per_mtok", rates["completion_per_mtok"]))
    completion_rate = float(rates["completion_per_mtok"])
    if thinking and thinking_rate == completion_rate:
        thinking = 0
    elif thinking and completion >= thinking and thinking_rate != completion_rate:
        completion -= thinking
    tracker.record(model, prompt, completion, thinking_tokens=thinking)
