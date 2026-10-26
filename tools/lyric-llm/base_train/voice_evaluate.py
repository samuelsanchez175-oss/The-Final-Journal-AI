#!/usr/bin/env python3
"""Voice-conditioning eval. Samuel runs it. Unit tests pass a fake client.

base_train/evaluate.py is Grok #1's D4 file and is not on this branch.
This harness is the V5 command. It does not print an API key.
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
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path

LYRIC_ROOT = Path(__file__).resolve().parents[1]
BASE_TRAIN = Path(__file__).resolve().parent
for _path in (LYRIC_ROOT, BASE_TRAIN):
    if str(_path) not in sys.path:
        sys.path.insert(0, str(_path))

from catalog_retriever import detect_inner_rhymes  # noqa: E402
from inner_rhyme_check import count_bar_syllables  # noqa: E402
from voice_variant import load_briefs, render_messages  # noqa: E402

DEFAULT_WORKERS = 4
DEFAULT_VOICE_N = 100
DEFAULT_FLIP_N = 20
DEFAULT_SEED = 7
MAX_TOKENS = 80

# House names only. Shared slang (racks, drip, pain, hope) is not leakage.
# Thugger and Wayne are the nouns named in the V5 brief.
HOUSE_NOUNS = {
    "Gunna": ("wunna", "ysl"),
    "Lil Baby": ("brodie", "4pf"),
    "Drake": ("drizzy", "ovo", "6ix"),
    "Lil Wayne": ("weezy", "tunechi", "hollygrove", "wayne", "tha carter"),
    "NoCap": ("nocap",),
    "Young Thug": ("thugger", "slime"),
}

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
    ("voice_flip", "higher"),
    ("cross_voice_leakage", "lower"),
)

TOKEN_RE = re.compile(r"[a-z0-9]+")
VOICE_RE = re.compile(r"<voice:\s*([^>]+)>")
SECTION_RE = re.compile(r"<section:\s*([^>]+)>")
BAR_RE = re.compile(r"<bar\s+(\d+)\s+of\s+(\d+)>")
FIELD_RE = re.compile(r"^(PREV_BAR|TOPIC|END_WORD|SYLLABLES|ABOVE|BELOW):\s*(.*)$")


@dataclass
class GenResult:
    text: str
    prompt_tokens: int
    completion_tokens: int
    logprobs: list[float]


@dataclass
class Job:
    key: str
    model: str
    messages: list[dict]


def plan_calls(n_fixture: int, flip_n: int, voice_n: int) -> dict[str, int]:
    """Four prompt pairs: base and the fine-tune, on one_hot and on the brief."""
    fixture = n_fixture * 4
    flip = flip_n * 2 * 4
    voice = voice_n * 2 * 4
    return {
        "fixture": fixture,
        "flip": flip,
        "voice": voice,
        "total": fixture + flip + voice,
    }


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
    choice = resp.choices[0]
    message = choice.message
    text = (getattr(message, "content", None) or "") if not isinstance(message, dict) else message.get("content") or ""
    logprobs: list[float] = []
    raw = getattr(choice, "logprobs", None)
    content = getattr(raw, "content", None) if raw is not None else None
    if content:
        for tok in content:
            value = getattr(tok, "logprob", None)
            if value is not None:
                logprobs.append(float(value))
    usage = getattr(resp, "usage", None)
    prompt_tokens = int(getattr(usage, "prompt_tokens", 0) or 0)
    completion_tokens = int(getattr(usage, "completion_tokens", 0) or 0)
    return GenResult(text.strip(), prompt_tokens, completion_tokens, logprobs)


def _artist_from_brief(system: str) -> str:
    cache = getattr(_artist_from_brief, "cache", None)
    if cache is None:
        cache = {
            entry.get("brief"): name
            for name, entry in load_briefs().items()
            if isinstance(entry, dict)
        }
        _artist_from_brief.cache = cache
    return cache.get(system, "")


def _field_map(user: str) -> dict[str, str]:
    found = {}
    for line in user.splitlines():
        match = FIELD_RE.match(line.strip())
        if match:
            found[match.group(1)] = match.group(2)
    return found


def parse_example(record: dict) -> dict | None:
    """Pull the bar fields back out of a voice JSONL row."""
    messages = record.get("messages") or []
    if len(messages) < 3:
        return None
    user = messages[1].get("content") or ""
    fields = _field_map(user)
    if "END_WORD" not in fields or "SYLLABLES" not in fields:
        return None
    voice = VOICE_RE.search(user)
    section = SECTION_RE.search(user)
    bar = BAR_RE.search(user)
    fim = user.startswith("ABOVE:") or "\nABOVE:" in user
    try:
        syllables = int(fields["SYLLABLES"])
    except ValueError:
        return None
    artist = voice.group(1).strip() if voice else ""
    if not artist:
        artist = _artist_from_brief(messages[0].get("content") or "")
    if not artist:
        return None
    return {
        "artist": artist,
        "section": section.group(1).strip() if section else "verse",
        "line_seq": int(bar.group(1)) if bar else 1,
        "total_lines": int(bar.group(2)) if bar else 1,
        "prev_text": fields.get("PREV_BAR") or fields.get("ABOVE") or "",
        "topic": fields.get("TOPIC") or "untagged",
        "end_word": fields["END_WORD"],
        "syllables": syllables,
        "text": messages[2].get("content") or "",
        "next_text": fields.get("BELOW"),
        "fim": fim,
    }


def prompt_messages(example: dict, variant: str, briefs: dict) -> list[dict]:
    record = render_messages(example, variant, briefs)
    return record["messages"][:2]


def voice_match_messages(artist: str, variant: str, briefs: dict, prev: str, topic: str) -> list[dict]:
    """Same situation, voice only. No END_WORD, so the end word is the model's."""
    example = {
        "artist": artist,
        "section": "verse",
        "line_seq": 1,
        "total_lines": 16,
        "prev_text": prev,
        "topic": topic or "untagged",
        "end_word": "",
        "syllables": 0,
        "text": "",
        "next_text": None,
        "fim": False,
    }
    user_lines = []
    for line in prompt_messages(example, variant, briefs)[1]["content"].splitlines():
        if line.startswith("END_WORD:") or line.startswith("SYLLABLES:"):
            continue
        user_lines.append(line)
    messages = prompt_messages(example, variant, briefs)
    messages[1] = {"role": "user", "content": "\n".join(user_lines)}
    return messages


def last_word(text: str) -> str:
    tokens = TOKEN_RE.findall(text.casefold())
    return tokens[-1] if tokens else ""


def end_word_match(text: str, target: str) -> bool:
    return last_word(text) == last_word(target)


def syllable_hit(text: str, target: int, cmu: dict) -> bool:
    return abs(count_bar_syllables(text, cmu) - target) <= 1


def inner_rhyme_count(text: str, cmu: dict) -> int:
    return len(detect_inner_rhymes(text, cmu))


def contains_noun(text: str, noun: str) -> bool:
    tokens = TOKEN_RE.findall(text.casefold())
    parts = TOKEN_RE.findall(noun.casefold())
    if not parts:
        return False
    if len(parts) == 1:
        return parts[0] in tokens
    width = len(parts)
    return any(tokens[index:index + width] == parts for index in range(len(tokens) - width + 1))


def leakage_count(bars: list[str], artist: str) -> int:
    banned = [
        noun
        for name, nouns in HOUSE_NOUNS.items()
        if name != artist
        for noun in nouns
    ]
    hits = 0
    for bar in bars:
        if any(contains_noun(bar, noun) for noun in banned):
            hits += 1
    return hits


def edit_distance(left: str, right: str) -> int:
    if left == right:
        return 0
    if not left:
        return len(right)
    if not right:
        return len(left)
    prev = list(range(len(right) + 1))
    for i, ca in enumerate(left, 1):
        cur = [i]
        for j, cb in enumerate(right, 1):
            cur.append(min(cur[j - 1] + 1, prev[j] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return prev[-1]


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
    keys = sorted(set(left) | set(right))
    if len(keys) < 2:
        return None
    xs = [float(left.get(key, 0.0)) for key in keys]
    ys = [float(right.get(key, 0.0)) for key in keys]
    rx = _ranks(xs)
    ry = _ranks(ys)
    n = len(keys)
    mx = sum(rx) / n
    my = sum(ry) / n
    num = sum((x - mx) * (y - my) for x, y in zip(rx, ry))
    dx = math.sqrt(sum((x - mx) ** 2 for x in rx))
    dy = math.sqrt(sum((y - my) ** 2 for y in ry))
    if dx == 0 or dy == 0:
        return None
    return num / (dx * dy)


def counts(words: list[str]) -> dict[str, float]:
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


def cost_per_1000(prompt_tokens: int, completion_tokens: int, n_bars: int, ft: bool) -> float | None:
    if n_bars <= 0:
        return None
    price_in, price_out = PRICE_FT if ft else PRICE_BASE
    dollars = prompt_tokens / 1_000_000 * price_in + completion_tokens / 1_000_000 * price_out
    return dollars / n_bars * 1000


def better(value: float | None, other: float | None, direction: str) -> bool:
    if value is None or other is None:
        return False
    if direction == "higher":
        return value > other
    return value < other


def metric_winner(direction: str, base_a, score_a, base_b, score_b) -> str:
    a_beats = better(score_a, base_a, direction)
    b_beats = better(score_b, base_b, direction)
    if not a_beats and not b_beats:
        return "NO LIFT"
    if a_beats and not b_beats:
        return "one_hot"
    if b_beats and not a_beats:
        return "systembrief"
    if better(score_a, score_b, direction):
        return "one_hot"
    if better(score_b, score_a, direction):
        return "systembrief"
    return "tie"


def verdict(scores: dict[str, dict]) -> str:
    """scores[metric] = {base, base_brief, one_hot, systembrief}."""
    lifts = {"one_hot": 0, "systembrief": 0}
    head = {"one_hot": 0, "systembrief": 0}
    for name, direction in METRICS:
        row = scores[name]
        if better(row["one_hot"], row["base"], direction):
            lifts["one_hot"] += 1
        if better(row["systembrief"], row["base_brief"], direction):
            lifts["systembrief"] += 1
        if better(row["one_hot"], row["systembrief"], direction):
            head["one_hot"] += 1
        elif better(row["systembrief"], row["one_hot"], direction):
            head["systembrief"] += 1
    a_lifts = lifts["one_hot"] >= 5
    b_lifts = lifts["systembrief"] >= 5
    if a_lifts and b_lifts:
        if head["one_hot"] >= 5:
            return "one_hot wins"
        if head["systembrief"] >= 5:
            return "systembrief wins"
        return "tie"
    if a_lifts:
        return "one_hot wins"
    if b_lifts:
        return "systembrief wins"
    return "DATASET OR BASE INSUFFICIENT — do not ship"


def _fmt(value) -> str:
    if value is None:
        return "n/a"
    if isinstance(value, float):
        return f"{value:.4f}"
    return str(value)


def render_report(
    scores: dict[str, dict],
    baseline: str,
    model_a: str,
    model_b: str,
    seconds: float,
    spend: float,
    calls: int,
    notes: list[str],
) -> str:
    lines = [
        "# Voice conditioning eval",
        "",
        f"Base `{baseline}`. one_hot `{model_a}`. systembrief `{model_b}`.",
        "",
        "The Base column is the base model on the one_hot prompts. "
        "systembrief is scored on the brief prompts. Its baseline is "
        "`base_brief`, the base model on those same brief prompts.",
        "",
        "| Metric | Better | Base (one_hot prompts) | one_hot | base_brief | systembrief | Winner |",
        "| --- | --- | ---: | ---: | ---: | ---: | --- |",
    ]
    for name, direction in METRICS:
        row = scores[name]
        winner = metric_winner(
            direction, row["base"], row["one_hot"], row["base_brief"], row["systembrief"]
        )
        lines.append(
            "| {name} | {direction} | {base} | {one_hot} | {brief} | {system} | {winner} |".format(
                name=name,
                direction=direction,
                base=_fmt(row["base"]),
                one_hot=_fmt(row["one_hot"]),
                brief=_fmt(row["base_brief"]),
                system=_fmt(row["systembrief"]),
                winner=winner,
            )
        )
    decision = verdict(scores)
    lines.extend([
        "",
        f"Verdict: {decision}",
        "",
        f"Duration seconds: {seconds:.1f}",
        f"OpenAI spend estimate from returned token counts: ${spend:.4f}",
        f"Calls: {calls}",
        "",
    ])
    lines.extend(notes)
    lines.append("")
    return "\n".join(lines)


def load_fixture(path: Path) -> list[dict]:
    examples = []
    with path.open(encoding="utf-8") as handle:
        for line in handle:
            if not line.strip():
                continue
            parsed = parse_example(json.loads(line))
            if parsed is not None:
                examples.append(parsed)
    return examples


def _sample(rows: list[dict], k: int, rng: random.Random) -> list[dict]:
    if k <= 0 or not rows:
        return []
    if k >= len(rows):
        return list(rows)
    return rng.sample(rows, k)


def build_jobs(examples, briefs, baseline, model_a, model_b, flip_n, voice_n, seed) -> list[Job]:
    rng = random.Random(seed)
    jobs: list[Job] = []
    pairs = (
        ("base", baseline, "one_hot"),
        ("one_hot", model_a, "one_hot"),
        ("base_brief", baseline, "systembrief"),
        ("systembrief", model_b, "systembrief"),
    )
    for index, example in enumerate(examples):
        for label, model, variant in pairs:
            jobs.append(Job(
                f"fix:{label}:{index}",
                model,
                prompt_messages(example, variant, briefs),
            ))
    contexts = _sample([row for row in examples if not row["fim"]], flip_n, rng)
    for index, example in enumerate(contexts):
        for artist in ("Gunna", "Lil Baby"):
            swapped = dict(example)
            swapped["artist"] = artist
            swapped["fim"] = False
            for label, model, variant in pairs:
                jobs.append(Job(
                    f"flip:{label}:{artist}:{index}",
                    model,
                    prompt_messages(swapped, variant, briefs),
                ))
    voice_contexts = _sample([row for row in examples if not row["fim"]], voice_n, rng)
    for index, example in enumerate(voice_contexts):
        for artist in ("Gunna", "Lil Baby"):
            for label, model, variant in pairs:
                jobs.append(Job(
                    f"voice:{label}:{artist}:{index}",
                    model,
                    voice_match_messages(
                        artist, variant, briefs, example["prev_text"], example["topic"]
                    ),
                ))
    return jobs


def run_jobs(client, jobs: list[Job], workers: int) -> list[GenResult]:
    def one(job: Job) -> GenResult:
        return client.generate(job.model, job.messages)

    if workers <= 1:
        return [one(job) for job in jobs]
    with ThreadPoolExecutor(max_workers=workers) as pool:
        return list(pool.map(one, jobs))


def _bucket(jobs: list[Job], results: list[GenResult]) -> dict[str, GenResult]:
    return {job.key: result for job, result in zip(jobs, results)}


def _leak_count(found: dict[str, GenResult], label: str) -> float | None:
    bars = [found[key].text for key in found if key.startswith(f"voice:{label}:Gunna:")]
    if not bars:
        return None
    return float(leakage_count(bars, "Gunna"))


def score_run(examples, jobs, results, cmu: dict) -> tuple[dict[str, dict], float, int]:
    found = _bucket(jobs, results)
    labels = ("base", "one_hot", "base_brief", "systembrief")
    end_hits = {label: 0 for label in labels}
    syl_hits = {label: 0 for label in labels}
    inner = {label: [] for label in labels}
    logprobs = {label: [] for label in labels}
    usage = {label: [0, 0, 0] for label in labels}  # prompt, completion, bars
    for index, example in enumerate(examples):
        for label in labels:
            result = found.get(f"fix:{label}:{index}")
            if result is None:
                continue
            usage[label][0] += result.prompt_tokens
            usage[label][1] += result.completion_tokens
            usage[label][2] += 1
            if end_word_match(result.text, example["end_word"]):
                end_hits[label] += 1
            if syllable_hit(result.text, example["syllables"], cmu):
                syl_hits[label] += 1
            inner[label].append(float(inner_rhyme_count(result.text, cmu)))
            if result.logprobs:
                logprobs[label].append(result.logprobs)

    flip_distance = {label: [] for label in labels}
    flip_groups: dict[str, dict[int, dict[str, str]]] = {label: {} for label in labels}
    for key, result in found.items():
        if not key.startswith("flip:"):
            continue
        _, label, artist, index_s = key.split(":")
        flip_groups[label].setdefault(int(index_s), {})[artist] = result.text
        usage[label][0] += result.prompt_tokens
        usage[label][1] += result.completion_tokens
        usage[label][2] += 1
    for label in labels:
        for pair in flip_groups[label].values():
            if "Gunna" in pair and "Lil Baby" in pair:
                flip_distance[label].append(float(edit_distance(pair["Gunna"], pair["Lil Baby"])))

    voice_words = {label: {"Gunna": [], "Lil Baby": []} for label in labels}
    for key, result in found.items():
        if not key.startswith("voice:"):
            continue
        _, label, artist, _index = key.split(":")
        voice_words[label][artist].append(last_word(result.text))
        usage[label][0] += result.prompt_tokens
        usage[label][1] += result.completion_tokens
        usage[label][2] += 1

    catalog = {
        "Gunna": counts([
            last_word(row["end_word"]) for row in examples if row["artist"] == "Gunna"
        ]),
        "Lil Baby": counts([
            last_word(row["end_word"]) for row in examples if row["artist"] == "Lil Baby"
        ]),
    }

    def voice_score(label: str) -> float | None:
        parts = []
        for artist in ("Gunna", "Lil Baby"):
            value = spearman(counts(voice_words[label][artist]), catalog[artist])
            if value is not None:
                parts.append(value)
        return mean(parts)

    n = len(examples)
    ft = {"base": False, "one_hot": True, "base_brief": False, "systembrief": True}
    scores = {
        "perplexity": {label: perplexity(logprobs[label]) for label in labels},
        "end_word_match": {label: rate(end_hits[label], n) for label in labels},
        "syllable_precision": {label: rate(syl_hits[label], n) for label in labels},
        "voice_match": {label: voice_score(label) for label in labels},
        "inner_rhyme": {label: mean(inner[label]) for label in labels},
        "cost_per_1000": {
            label: cost_per_1000(usage[label][0], usage[label][1], usage[label][2], ft[label])
            for label in labels
        },
        "voice_flip": {label: mean(flip_distance[label]) for label in labels},
        "cross_voice_leakage": {
            label: _leak_count(found, label) for label in labels
        },
    }
    # The table's column names.
    shaped = {}
    for name, _direction in METRICS:
        shaped[name] = {
            "base": scores[name]["base"],
            "base_brief": scores[name]["base_brief"],
            "one_hot": scores[name]["one_hot"],
            "systembrief": scores[name]["systembrief"],
        }
    spend = 0.0
    for label in labels:
        price_in, price_out = PRICE_FT if ft[label] else PRICE_BASE
        spend += usage[label][0] / 1_000_000 * price_in
        spend += usage[label][1] / 1_000_000 * price_out
    return shaped, spend, len(jobs)


def run_eval(
    examples,
    client,
    briefs,
    cmu,
    baseline: str,
    model_a: str,
    model_b: str,
    flip_n: int,
    voice_n: int,
    seed: int,
    workers: int,
) -> tuple[str, dict]:
    started = time.perf_counter()
    jobs = build_jobs(examples, briefs, baseline, model_a, model_b, flip_n, voice_n, seed)
    results = run_jobs(client, jobs, workers)
    scores, spend, calls = score_run(examples, jobs, results, cmu)
    seconds = time.perf_counter() - started
    non_fim = sum(1 for row in examples if not row["fim"])
    notes = [
        f"Fixture rows scored: {len(examples)}.",
        f"Non-FIM rows available for flip and voice-match: {non_fim}.",
        f"Flip contexts requested: {flip_n}. Voice bars requested per artist: {voice_n}.",
        "Voice-match drops END_WORD so the end word is the model's.",
        "Cross-voice leakage is the share of Gunna voice-match bars that contain another artist's house noun.",
        "House nouns: " + ", ".join(
            f"{artist} ({', '.join(nouns)})" for artist, nouns in HOUSE_NOUNS.items()
        ) + ".",
        "A fine-tune beats its baseline only when its number is strictly better.",
        "A variant lifts when it beats its baseline on at least 5 of 8 metrics.",
        "Perplexity is exp(mean negative logprob) of the tokens the API returns. It is n/a when logprobs are missing.",
    ]
    report = render_report(
        scores, baseline, model_a, model_b, seconds, spend, calls, notes
    )
    return report, scores


class OpenAIChat:
    """Real client. Built only when Samuel runs the script."""

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

        return with_backoff(once)


def load_api_key() -> str:
    key = os.environ.get("OPENAI_API_KEY") or ""
    if key.strip():
        return key.strip()
    path = Path(__file__).resolve().parents[3] / ".env.openai"
    if path.is_file():
        return path.read_text(encoding="utf-8").strip()
    raise SystemExit(f"missing {path}")


def load_cmu() -> dict:
    from lyriclib import load_cmudict
    from catalog_retriever import CMU_PATH
    if CMU_PATH.is_file():
        return load_cmudict(CMU_PATH)
    return {}


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Score voice-conditioning fine-tunes.")
    parser.add_argument("--baseline", required=True)
    parser.add_argument("--model-a", required=True)
    parser.add_argument("--model-b", required=True)
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--voice-eval", action="store_true")
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--seed", type=int, default=DEFAULT_SEED)
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--flip-n", type=int, default=DEFAULT_FLIP_N)
    parser.add_argument("--voice-n", type=int, default=DEFAULT_VOICE_N)
    parser.add_argument("--workers", type=int, default=DEFAULT_WORKERS)
    args = parser.parse_args(argv)
    if not args.voice_eval:
        raise SystemExit("pass --voice-eval")
    return args


def main(argv: list[str] | None = None, client=None) -> int:
    args = parse_args(argv)
    examples = load_fixture(args.fixture)
    if args.limit > 0:
        examples = examples[:args.limit]
    if not examples:
        raise SystemExit(f"no rows in {args.fixture}")
    briefs = load_briefs()
    plan = plan_calls(len(examples), min(args.flip_n, sum(1 for row in examples if not row["fim"])), min(args.voice_n, sum(1 for row in examples if not row["fim"])))
    print(
        f"fixture={len(examples)} flip_n={args.flip_n} voice_n={args.voice_n} "
        f"calls={plan['total']} workers={args.workers}"
    )
    if client is None:
        client = OpenAIChat(load_api_key())
    cmu = load_cmu()
    report, _scores = run_eval(
        examples,
        client,
        briefs,
        cmu,
        args.baseline,
        args.model_a,
        args.model_b,
        args.flip_n,
        args.voice_n,
        args.seed,
        args.workers,
    )
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(report, encoding="utf-8")
    print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
