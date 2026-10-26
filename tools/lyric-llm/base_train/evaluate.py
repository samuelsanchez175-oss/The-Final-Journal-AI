#!/usr/bin/env python3
"""D4 harness. Compare the 50k fine-tune with the full fine-tune.

Samuel runs this after the two jobs exist. Unit tests pass a fake client.
This file does not call OpenAI on import, and it does not print an API key.

From tools/lyric-llm:

    python3 base_train/evaluate.py \\
        --model-a ft:gpt-4o-mini:...:50k:... \\
        --model-b ft:gpt-4o-mini:...:full:... \\
        --fixture out/test_50k_fim.jsonl \\
        --out out/compare_50k_vs_full.md

out/test.jsonl is the MLX song split. This harness rejects it.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import random
import re
import sys
import time
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

LYRIC_ROOT = Path(__file__).resolve().parents[1]
BASE_TRAIN = Path(__file__).resolve().parent
for _path in (LYRIC_ROOT, BASE_TRAIN):
    if str(_path) not in sys.path:
        sys.path.insert(0, str(_path))

from catalog_retriever import detect_inner_rhymes  # noqa: E402
from inner_rhyme_check import count_bar_syllables  # noqa: E402

DEFAULT_SEED = 7
DEFAULT_LIMIT = 400
DEFAULT_VOICE_N = 100
MAX_TOKENS = 80
VOICE_ARTISTS = ("Gunna", "Lil Baby")

# Dollars per 1M tokens. Fine-tune rates are the gpt-4o-mini-2024-07-18 row.
PRICE_BASE = (0.15, 0.60)
PRICE_FT = (0.30, 1.20)

METRICS = (
    ("perplexity", "lower"),
    ("end_word_match", "higher"),
    ("syllable_precision", "higher"),
    ("voice_match", "higher"),
    ("inner_rhyme", "higher"),
    ("cost_per_1000", "lower"),
)

SYSTEM_PROMPT = (
    "Write bars like <voice>. Keep the artist's slang, syllable count, "
    "and rhyme pattern. Preserve the end word if given."
)

MLX_ERROR = (
    "out/test.jsonl is the MLX song split. "
    "The chat file is out/test_50k_fim.jsonl."
)

TOKEN_RE = re.compile(r"[a-z0-9]+")
VOICE_RE = re.compile(r"<voice:\s*([^>]+)>")
FIELD_RE = re.compile(r"^(PREV_BAR|TOPIC|END_WORD|SYLLABLES|ABOVE|BELOW):\s*(.*)$")


@dataclass
class Example:
    artist: str
    system: str
    user: str
    end_word: str
    syllables: int
    text: str
    prev_text: str
    topic: str


@dataclass
class GenResult:
    text: str
    prompt_tokens: int
    completion_tokens: int
    logprobs: list[float]


@dataclass
class Job:
    kind: str
    slot: str
    model: str
    index: int
    artist: str
    messages: list[dict]


def die(message: str, code: int) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(code)


def is_rate_limit(exc: BaseException) -> bool:
    if getattr(exc, "status_code", None) == 429:
        return True
    response = getattr(exc, "response", None)
    return getattr(response, "status_code", None) == 429


def with_backoff(call, sleep=time.sleep, attempts: int = 6):
    delay = 1.0
    last = None
    for attempt in range(attempts):
        try:
            return call()
        except Exception as exc:
            last = exc
            if not is_rate_limit(exc) or attempt + 1 == attempts:
                raise
            sleep(delay)
            delay = min(delay * 2, 60.0)
    raise last


def parse_chat_response(resp) -> GenResult:
    choices = getattr(resp, "choices", None) or []
    if not choices:
        die("openai response had no choices", 1)
    choice = choices[0]
    message = choice.message
    if isinstance(message, dict):
        text = message.get("content") or ""
    else:
        text = getattr(message, "content", None) or ""
    logprobs: list[float] = []
    raw = getattr(choice, "logprobs", None)
    content = None
    if isinstance(raw, dict):
        content = raw.get("content")
    elif raw is not None:
        content = getattr(raw, "content", None)
    if content:
        for tok in content:
            if isinstance(tok, dict):
                value = tok.get("logprob")
            else:
                value = getattr(tok, "logprob", None)
            if value is not None:
                logprobs.append(float(value))
    usage = getattr(resp, "usage", None)
    if isinstance(usage, dict):
        prompt_tokens = int(usage.get("prompt_tokens") or 0)
        completion_tokens = int(usage.get("completion_tokens") or 0)
    else:
        prompt_tokens = int(getattr(usage, "prompt_tokens", 0) or 0)
        completion_tokens = int(getattr(usage, "completion_tokens", 0) or 0)
    return GenResult(text.strip(), prompt_tokens, completion_tokens, logprobs)


def _field_map(user: str) -> dict[str, str]:
    found = {}
    for line in user.splitlines():
        match = FIELD_RE.match(line.strip())
        if match:
            found[match.group(1)] = match.group(2).strip()
    return found


def parse_example(record: dict) -> Example | None:
    messages = record.get("messages")
    if not isinstance(messages, list) or len(messages) < 3:
        return None
    system = messages[0].get("content") or ""
    user = messages[1].get("content") or ""
    fields = _field_map(user)
    if "END_WORD" not in fields or "SYLLABLES" not in fields:
        return None
    voice = VOICE_RE.search(user)
    if not voice:
        return None
    try:
        syllables = int(fields["SYLLABLES"])
    except ValueError:
        return None
    prev = fields.get("PREV_BAR")
    if prev is None:
        prev = fields.get("ABOVE") or ""
    topic = fields.get("TOPIC") or "unknown"
    return Example(
        artist=voice.group(1).strip(),
        system=system,
        user=user,
        end_word=fields["END_WORD"],
        syllables=syllables,
        text=messages[2].get("content") or "",
        prev_text=prev,
        topic=topic,
    )


def load_chat_file(path: Path) -> tuple[list[Example], int]:
    """Return parsed chat rows and the count of lines that were not examples."""
    if not path.is_file():
        die(f"missing {path}", 2)
    rows: list[Example] = []
    skipped = 0
    seen = False
    with path.open(encoding="utf-8") as handle:
        for number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                die(f"fixture line {number} is not json", 2)
            if not isinstance(record, dict):
                die(MLX_ERROR, 2)
            if not seen:
                seen = True
                messages = record.get("messages")
                if not isinstance(messages, list):
                    die(MLX_ERROR, 2)
            parsed = parse_example(record)
            if parsed is None:
                skipped += 1
                continue
            rows.append(parsed)
    if not seen:
        die(f"no chat rows in {path}", 2)
    if not rows:
        die(f"no chat rows in {path}", 2)
    return rows, skipped


def sample_rows(rows: list, k: int, seed: int) -> list:
    """Shuffle indexes with Random(seed), keep k, then restore fixture order."""
    if k <= 0 or not rows:
        return []
    if k >= len(rows):
        return list(rows)
    rng = random.Random(seed)
    indexes = list(range(len(rows)))
    rng.shuffle(indexes)
    chosen = sorted(indexes[:k])
    return [rows[index] for index in chosen]


def prompt_messages(example: Example) -> list[dict]:
    return [
        {"role": "system", "content": example.system},
        {"role": "user", "content": example.user},
    ]


def voice_messages(artist: str, prev: str, topic: str) -> list[dict]:
    """D1 system prompt. No END_WORD and no SYLLABLES, so the end word is the model's."""
    user = (
        f"<voice: {artist}> <section: verse>\n"
        f"PREV_BAR: {prev}\n"
        f"TOPIC: {topic or 'unknown'}"
    )
    return [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": user},
    ]


def last_word(text: str) -> str:
    tokens = TOKEN_RE.findall((text or "").casefold())
    return tokens[-1] if tokens else ""


def end_word_match(text: str, target: str) -> bool:
    return last_word(text) == last_word(target)


def syllable_hit(text: str, target: int, cmu: dict) -> bool:
    return abs(count_bar_syllables(text, cmu) - target) <= 1


def inner_rhyme_count(text: str, cmu: dict) -> int:
    return len(detect_inner_rhymes(text, cmu))


def _ranks(values: list[float]) -> list[float]:
    order = sorted(range(len(values)), key=lambda index: values[index])
    ranks = [0.0] * len(values)
    index = 0
    while index < len(values):
        end = index
        while end + 1 < len(values) and values[order[end + 1]] == values[order[index]]:
            end += 1
        average = (index + end) / 2 + 1
        for cursor in range(index, end + 1):
            ranks[order[cursor]] = average
        index = end + 1
    return ranks


def spearman(left: dict[str, float], right: dict[str, float]) -> float | None:
    keys = sorted(set(left).union(right))
    if len(keys) < 2:
        return None
    xs = [float(left.get(key, 0.0)) for key in keys]
    ys = [float(right.get(key, 0.0)) for key in keys]
    rx = _ranks(xs)
    ry = _ranks(ys)
    n = len(keys)
    mean_x = sum(rx) / n
    mean_y = sum(ry) / n
    num = sum((x - mean_x) * (y - mean_y) for x, y in zip(rx, ry))
    dx = math.sqrt(sum((x - mean_x) ** 2 for x in rx))
    dy = math.sqrt(sum((y - mean_y) ** 2 for y in ry))
    if dx == 0 or dy == 0:
        return None
    return num / (dx * dy)


def word_counts(words: list[str]) -> dict[str, float]:
    found: dict[str, float] = {}
    for word in words:
        if not word:
            continue
        found[word] = found.get(word, 0.0) + 1.0
    return found


def perplexity(logprob_rows: list[list[float]]) -> float | None:
    values = [value for row in logprob_rows for value in row]
    if not values:
        return None
    return math.exp(-sum(values) / len(values))


def rate(hits: int, total: int) -> float | None:
    if total <= 0:
        return None
    return hits / total


def mean(values: list[float]) -> float | None:
    if not values:
        return None
    return sum(values) / len(values)


def is_ft(model: str) -> bool:
    return model.startswith("ft:")


def cost_per_1000(prompt_tokens: int, completion_tokens: int, n_bars: int, ft: bool) -> float | None:
    if n_bars <= 0:
        return None
    price_in, price_out = PRICE_FT if ft else PRICE_BASE
    dollars = prompt_tokens / 1_000_000 * price_in + completion_tokens / 1_000_000 * price_out
    return dollars / n_bars * 1000


def better(value: float | None, other: float | None, direction: str) -> bool:
    if value is None or other is None or value == other:
        return False
    if direction == "higher":
        return value > other
    return value < other


def metric_winner(left, right, direction: str) -> str:
    """left is the 50k slot (model-a). right is the full slot (model-b)."""
    if better(left, right, direction):
        return "50k"
    if better(right, left, direction):
        return "full"
    return "tie"


def overall_winner(wins_a: int, wins_b: int) -> str:
    if wins_a >= 4 and wins_a > wins_b:
        return "50k wins"
    if wins_b >= 4 and wins_b > wins_a:
        return "full wins"
    return "tie"


def _fmt(value) -> str:
    if value is None:
        return "n/a"
    if isinstance(value, float):
        return f"{value:.4f}"
    return str(value)


def selection_summary(path: Path, seed: int = DEFAULT_SEED, limit: int = DEFAULT_LIMIT, voice_n: int = DEFAULT_VOICE_N) -> dict:
    """Counts only. No generation and no lyric text."""
    rows, skipped = load_chat_file(path)
    scored = sample_rows(rows, limit, seed)
    artists = Counter(row.artist for row in scored)
    voice = {}
    for artist in VOICE_ARTISTS:
        pool = [row for row in rows if row.artist == artist]
        picked = sample_rows(pool, voice_n, seed)
        voice[artist] = {"pool": len(pool), "picked": len(picked)}
    return {
        "rows": len(rows),
        "skipped": skipped,
        "scored": len(scored),
        "limit": limit,
        "artists": dict(artists),
        "voice": voice,
    }


def build_jobs(rows, scored, model_a: str, model_b: str, voice_n: int, seed: int) -> tuple[list[Job], dict]:
    jobs: list[Job] = []
    models = (("50k", model_a), ("full", model_b))
    for index, example in enumerate(scored):
        messages = prompt_messages(example)
        for slot, model in models:
            jobs.append(Job("held", slot, model, index, example.artist, messages))
    voice_plan = {}
    for artist in VOICE_ARTISTS:
        pool = [row for row in rows if row.artist == artist]
        picked = sample_rows(pool, voice_n, seed)
        voice_plan[artist] = {"pool": len(pool), "picked": len(picked)}
        for index, example in enumerate(picked):
            messages = voice_messages(artist, example.prev_text, example.topic)
            for slot, model in models:
                jobs.append(Job("voice", slot, model, index, artist, messages))
    return jobs, voice_plan


def run_jobs(client, jobs: list[Job]) -> list[GenResult]:
    results = []
    for job in jobs:
        try:
            result = client.generate(job.model, job.messages)
        except SystemExit:
            raise
        except Exception as exc:
            status = getattr(exc, "status_code", None)
            die(f"openai {type(exc).__name__} status={status}", 1)
        if not isinstance(result, GenResult):
            die("client.generate did not return a generation", 1)
        results.append(result)
    return results


def score_jobs(rows, scored, jobs, results, cmu: dict) -> dict:
    by_key = {}
    for job, result in zip(jobs, results):
        by_key[(job.kind, job.slot, job.artist, job.index)] = result
    slots = ("50k", "full")
    end_hits = {slot: 0 for slot in slots}
    syl_hits = {slot: 0 for slot in slots}
    inner = {slot: [] for slot in slots}
    logprobs = {slot: [] for slot in slots}
    usage = {slot: [0, 0, 0] for slot in slots}
    for slot in slots:
        for index, example in enumerate(scored):
            result = by_key.get(("held", slot, example.artist, index))
            if result is None:
                continue
            usage[slot][0] += result.prompt_tokens
            usage[slot][1] += result.completion_tokens
            usage[slot][2] += 1
            if end_word_match(result.text, example.end_word):
                end_hits[slot] += 1
            if syllable_hit(result.text, example.syllables, cmu):
                syl_hits[slot] += 1
            inner[slot].append(float(inner_rhyme_count(result.text, cmu)))
            if result.logprobs:
                logprobs[slot].append(result.logprobs)
        for job in jobs:
            if job.kind != "voice" or job.slot != slot:
                continue
            result = by_key[(job.kind, job.slot, job.artist, job.index)]
            usage[slot][0] += result.prompt_tokens
            usage[slot][1] += result.completion_tokens
            usage[slot][2] += 1

    catalog = {}
    for artist in VOICE_ARTISTS:
        catalog[artist] = word_counts([
            last_word(row.text) for row in rows if row.artist == artist
        ])
    voice_words = {slot: {artist: [] for artist in VOICE_ARTISTS} for slot in slots}
    for job in jobs:
        if job.kind != "voice":
            continue
        result = by_key[(job.kind, job.slot, job.artist, job.index)]
        voice_words[job.slot][job.artist].append(last_word(result.text))

    def voice_score(slot: str) -> float | None:
        parts = []
        for artist in VOICE_ARTISTS:
            generated = word_counts(voice_words[slot][artist])
            if not generated or not catalog[artist]:
                continue
            value = spearman(generated, catalog[artist])
            if value is not None:
                parts.append(value)
        return mean(parts)

    model_for = {}
    for job in jobs:
        model_for[job.slot] = job.model
    n = len(scored)
    scores = {
        "perplexity": {slot: perplexity(logprobs[slot]) for slot in slots},
        "end_word_match": {slot: rate(end_hits[slot], n) for slot in slots},
        "syllable_precision": {slot: rate(syl_hits[slot], n) for slot in slots},
        "voice_match": {slot: voice_score(slot) for slot in slots},
        "inner_rhyme": {slot: mean(inner[slot]) for slot in slots},
        "cost_per_1000": {
            slot: cost_per_1000(
                usage[slot][0],
                usage[slot][1],
                usage[slot][2],
                is_ft(model_for.get(slot, "")),
            )
            for slot in slots
        },
    }
    return scores


def render_report(
    scores: dict,
    model_a: str,
    model_b: str,
    fixture: str,
    row_count: int,
    scored: int,
    limit: int,
    seed: int,
    skipped: int,
    voice_plan: dict,
    voice_n: int,
    calls: int,
    seconds: float,
) -> str:
    winners = []
    for name, direction in METRICS:
        winners.append(metric_winner(scores[name]["50k"], scores[name]["full"], direction))
    wins_a = sum(1 for label in winners if label == "50k")
    wins_b = sum(1 for label in winners if label == "full")
    decision = overall_winner(wins_a, wins_b)
    lines = [
        "# 50k vs full",
        "",
        f"50k (`--model-a`): `{model_a}`",
        f"full (`--model-b`): `{model_b}`",
        "",
        f"Fixture: `{fixture}`",
        f"Scored {scored} of {row_count}.",
        f"Same {scored} bars for both models. Seed {seed}.",
    ]
    if row_count < limit:
        lines.append(
            f"The fixture has fewer than {limit} bars, so every bar was scored."
        )
    if skipped:
        lines.append(f"Skipped rows that were not chat examples: {skipped}.")
    lines.extend([
        "",
        "Perplexity is exp(mean negative logprob) of the completion tokens the API "
        "returns for the held-out prompts. It is not gold-bar next-token loss. "
        "It is n/a when logprobs are missing, and neither model wins that metric.",
        "",
        "Voice-match prompts drop END_WORD and SYLLABLES. The catalog is the last "
        "word of that artist's assistant bars in the full fixture. The score is the "
        "mean of the Gunna and Lil Baby Spearman correlations.",
        "",
        "Inner rhyme is the mean of detect_inner_rhymes on the held-out generations.",
        "",
        "Cost uses $0.30 per 1M input tokens and $1.20 per 1M output tokens for "
        "model ids that start with ft:. Other ids use $0.15 and $0.60. The count "
        "covers every generated bar for that model, the held-out set and the voice-match set.",
        "",
        "| Metric | Better | 50k | full | Winner |",
        "| --- | --- | ---: | ---: | --- |",
    ])
    for (name, direction), winner in zip(METRICS, winners):
        lines.append(
            "| {name} | {direction} | {left} | {right} | {winner} |".format(
                name=name,
                direction=direction,
                left=_fmt(scores[name]["50k"]),
                right=_fmt(scores[name]["full"]),
                winner=winner,
            )
        )
    lines.extend([
        "",
        f"50k metric wins: {wins_a}. full metric wins: {wins_b}.",
        f"Overall: {decision}",
        "",
        f"Calls: {calls}",
        f"Duration seconds: {seconds:.1f}",
    ])
    for artist in VOICE_ARTISTS:
        plan = voice_plan.get(artist) or {"pool": 0, "picked": 0}
        lines.append(
            f"{artist} voice bars: {plan['picked']} (pool {plan['pool']}, requested {voice_n})."
        )
    lines.append("")
    return "\n".join(lines)


def run_compare(rows, client, model_a, model_b, cmu, fixture, seed, limit, voice_n, skipped) -> str:
    started = time.perf_counter()
    scored = sample_rows(rows, limit, seed)
    jobs, voice_plan = build_jobs(rows, scored, model_a, model_b, voice_n, seed)
    results = run_jobs(client, jobs)
    scores = score_jobs(rows, scored, jobs, results, cmu)
    seconds = time.perf_counter() - started
    return render_report(
        scores,
        model_a,
        model_b,
        fixture,
        len(rows),
        len(scored),
        limit,
        seed,
        skipped,
        voice_plan,
        voice_n,
        len(jobs),
        seconds,
    )


class OpenAIChat:
    """Real client. Built only when Samuel runs the script without a fake."""

    def __init__(self, api_key: str):
        from openai import OpenAI
        self.client = OpenAI(api_key=api_key)

    def generate(self, model: str, messages: list[dict]) -> GenResult:
        def once():
            resp = self.client.chat.completions.create(
                model=model,
                messages=messages,
                temperature=0,
                max_tokens=MAX_TOKENS,
                logprobs=True,
            )
            return parse_chat_response(resp)

        try:
            return with_backoff(once)
        except SystemExit:
            raise
        except Exception as exc:
            status = getattr(exc, "status_code", None)
            die(f"openai {type(exc).__name__} status={status}", 1)


def load_api_key() -> str:
    key = (os.environ.get("OPENAI_API_KEY") or "").strip()
    if key:
        return key
    env_file = (os.environ.get("OPENAI_ENV_FILE") or "").strip()
    if env_file:
        path = Path(env_file)
        if path.is_file() and path.stat().st_size > 0:
            return "".join(path.read_text(encoding="utf-8").split())
        die("missing .env.openai", 1)
    here = Path(__file__).resolve()
    for path in (here.parents[1] / ".env.openai", here.parents[3] / ".env.openai"):
        if path.is_file() and path.stat().st_size > 0:
            return "".join(path.read_text(encoding="utf-8").split())
    die("missing .env.openai", 1)
    return ""


def load_cmu() -> dict:
    from lyriclib import load_cmudict
    from catalog_retriever import CMU_PATH
    if CMU_PATH.is_file():
        return load_cmudict(CMU_PATH)
    return {}


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Compare the 50k and full fine-tunes.")
    parser.add_argument("--model-a", required=True)
    parser.add_argument("--model-b", required=True)
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--seed", type=int, default=DEFAULT_SEED)
    parser.add_argument("--limit", type=int, default=DEFAULT_LIMIT)
    parser.add_argument("--voice-n", type=int, default=DEFAULT_VOICE_N)
    args = parser.parse_args(argv)
    if args.limit < 1:
        die("limit must be at least 1", 2)
    if args.voice_n < 0:
        die("voice-n must be at least 0", 2)
    return args


def main(argv: list[str] | None = None, client=None, cmu: dict | None = None) -> int:
    args = parse_args(argv)
    rows, skipped = load_chat_file(args.fixture)
    if client is None:
        try:
            client = OpenAIChat(load_api_key())
        except SystemExit:
            raise
        except Exception as exc:
            status = getattr(exc, "status_code", None)
            die(f"openai {type(exc).__name__} status={status}", 1)
    if cmu is None:
        cmu = load_cmu()
    report = run_compare(
        rows,
        client,
        args.model_a,
        args.model_b,
        cmu,
        str(args.fixture),
        args.seed,
        args.limit,
        args.voice_n,
        skipped,
    )
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(report, encoding="utf-8")
    decision = "tie"
    for line in report.splitlines():
        if line.startswith("Overall: "):
            decision = line.split(": ", 1)[1]
            break
    scored = sample_rows(rows, args.limit, args.seed)
    calls = len(scored) * 2
    for artist in VOICE_ARTISTS:
        pool = sum(1 for row in rows if row.artist == artist)
        calls += min(args.voice_n, pool) * 2
    print(f"overall={decision} scored={len(scored)} calls={calls} out={args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
