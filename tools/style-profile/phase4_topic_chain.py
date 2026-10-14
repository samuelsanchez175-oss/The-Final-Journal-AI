#!/usr/bin/env python3
"""AI Sparkler style profile — Phase 4: topic chains, delivery shifts, Genius device stats.

Subcommands
  chain   LLM topic-run segmentation per song (headless `claude -p`, cached/resumable), plus a
          deterministic delivery-shift rate from bar-group vectors. Writes
          out/topic_chain_songs.jsonl and out/topic_chain_artists.jsonl (distribution + transition matrix).
  genius  Deterministic per-artist figurative-language stats from docs/play-on-words/genius-clicks
          (accepted/verified annotations only) per 100 bars. Writes out/genius_devices.jsonl.

Cost control: one LLM call per song, first MAX_BARS deduped bars only, haiku model. Start with
  python3 tools/style-profile/phase4_topic_chain.py chain --artists "Gunna" --limit 5
and look at the output before widening.
"""

from __future__ import annotations

import argparse
import json
import re
import statistics
import subprocess
import sys
import time
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import phase1_song_metrics as p1  # noqa: E402

SCHEMA_VERSION = "phase4.v1"
PROMPT_VERSION = "topics.v1"
HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
GENIUS_DIR = p1.ROOT / "docs" / "play-on-words" / "genius-clicks"
MAX_BARS = 64
MIN_BARS = 16
GROUP = 4

TAXONOMY = [
    "money_flex", "luxury_brands", "drugs", "violence_street", "women_romance", "sex", "loyalty_friends",
    "betrayal_enemies", "pain_trauma", "come_up_hustle", "fame_industry", "faith_mortality", "party_lifestyle",
    "braggadocio_skill", "social_commentary", "family_home", "mental_health", "nostalgia_reflection",
    "wordplay_punchline", "filler_adlib", "other",
]

PROMPT = """You label rap lyrics by subject matter.
Allowed topics: {topics}
If none fit a stretch, use "other" and add a short snake_case suggestion to "proposed_topics".

Below are {n} numbered bars from "{song}" by {artist}. Split them into consecutive RUNS where one subject
dominates. Runs must cover bars 1..{n} in order with no gaps or overlaps. Keep runs at least 2 bars unless a
single bar is a clear punchline switch. "secondary" is an optional second topic inside the run.

Reply with ONLY JSON, no prose:
{{"runs":[{{"start":1,"end":4,"topic":"money_flex","secondary":null}}],"proposed_topics":[]}}

BARS:
{bars}
"""


# ---------------------------------------------------------------- shared helpers


def song_bars(csv_path: Path, artists: set[str] | None):
    songs = p1.read_songs(csv_path, artists)
    for (art, song), rec in sorted(songs.items()):
        lines = [t for _, t in sorted(rec["lines"], key=lambda x: x[0])]
        seen, uniq = set(), []
        for t in lines:
            k = p1.norm_line(t)
            if k and k not in seen:
                seen.add(k)
                uniq.append(t)
        yield art, song, uniq


def delivery_shifts(bars: list[p1.Bar]) -> dict:
    """Deterministic style-change: compare adjacent 4-bar groups on syllables, pauses, ad-libs."""
    groups = [bars[i:i + GROUP] for i in range(0, len(bars) - GROUP + 1, GROUP)]
    vec = [(statistics.fmean(b.syl for b in g), statistics.fmean(b.pauses for b in g),
            sum(1 for b in g if b.adlib) / GROUP) for g in groups]
    shifts, dims = 0, Counter()
    for a, b in zip(vec, vec[1:]):
        hit = False
        if abs(a[0] - b[0]) >= 3:
            dims["syllables"] += 1
            hit = True
        if abs(a[1] - b[1]) >= 1.0:
            dims["pauses"] += 1
            hit = True
        if abs(a[2] - b[2]) >= 0.5:
            dims["adlibs"] += 1
            hit = True
        shifts += hit
    n = max(1, len(vec) - 1)
    return {"groups": len(vec), "shift_pct": round(100 * shifts / n, 1), "dims": dict(dims)} if len(vec) > 1 else {"groups": len(vec)}


# ---------------------------------------------------------------- LLM call


def call_llm(prompt: str, model: str, timeout: int = 180, attempts: int = 3) -> str | None:
    cmd = ["claude", "-p", "--model", model, "--output-format", "json", "--no-session-persistence",
           "--disable-slash-commands", "--strict-mcp-config", "--tools", ""]
    for attempt in range(attempts):
        if attempt:
            time.sleep(10 * attempt)  # back off: failures cluster when calls are throttled
        try:
            r = subprocess.run(cmd, input=prompt, capture_output=True, text=True, timeout=timeout)
        except subprocess.TimeoutExpired:
            continue
        if r.returncode != 0:
            continue
        try:
            data = json.loads(r.stdout)
        except json.JSONDecodeError:
            continue
        if data.get("is_error"):
            msg = str(data.get("result"))
            if "authenticate" in msg or "login" in msg.lower():
                sys.exit(f"claude CLI error: {msg} — run `claude auth login` in a terminal, then re-run.")
            continue
        return data.get("result")
    return None


def parse_runs(text: str | None, n: int):
    if not text:
        return None, []
    m = re.search(r"\{.*\}", text, re.S)
    if not m:
        return None, []
    try:
        data = json.loads(m.group(0))
    except json.JSONDecodeError:
        return None, []
    runs = []
    for r in data.get("runs", []):
        try:
            s, e = int(r["start"]), int(r["end"])
        except (KeyError, TypeError, ValueError):
            return None, []
        topic = r.get("topic") if r.get("topic") in TAXONOMY else "other"
        runs.append({"start": s, "end": e, "topic": topic,
                     "secondary": r.get("secondary") if r.get("secondary") in TAXONOMY else None})
    runs.sort(key=lambda r: r["start"])
    # repair: clamp to 1..n, close gaps/overlaps by extending the previous run
    fixed, cursor = [], 1
    for r in runs:
        if r["end"] < cursor:
            continue
        r["start"] = cursor
        r["end"] = min(max(r["end"], r["start"]), n)
        fixed.append(r)
        cursor = r["end"] + 1
        if cursor > n:
            break
    if not fixed:
        return None, []
    if fixed[-1]["end"] < n:
        fixed[-1]["end"] = n
    merged = [fixed[0]]
    for r in fixed[1:]:  # adjacent runs with the same topic are one run
        if r["topic"] == merged[-1]["topic"]:
            merged[-1]["end"] = r["end"]
        else:
            merged.append(r)
    fixed = merged
    return fixed, [t for t in data.get("proposed_topics", []) if isinstance(t, str)][:5]


def chain_metrics(runs: list[dict], n: int) -> dict:
    lens = [r["end"] - r["start"] + 1 for r in runs]
    topics = [r["topic"] for r in runs]
    switches = sum(1 for a, b in zip(topics, topics[1:]) if a != b)
    return {
        "chain": topics, "run_lengths": lens, "switches": switches,
        "switch_rate_per_16": round(switches * 16 / n, 2), "topic_change_pct": round(100 * switches / max(1, n - 1), 1),
        "avg_run": round(statistics.fmean(lens), 2), "longest_run": max(lens), "distinct_topics": len(set(topics)),
    }


# ---------------------------------------------------------------- chain command


def cmd_chain(args) -> int:
    OUT.mkdir(exist_ok=True)
    cache_path = OUT / "topic_cache.jsonl"
    done = {}
    if cache_path.exists():
        for line in cache_path.read_text(encoding="utf-8").splitlines():
            r = json.loads(line)
            if r.get("prompt_version") == PROMPT_VERSION and r.get("model") == args.model and r.get("status") == "ok":
                done[f'{r["artist"]}|{r["song"]}'] = r
    artists = {a.strip().lower() for a in args.artists.split(",")} if args.artists else None
    work = []
    for art, song, uniq in song_bars(args.csv, artists):
        if len(uniq) < MIN_BARS:
            continue
        work.append((art, song, uniq))
    if args.per_artist:
        seen: Counter = Counter()
        kept = []
        for w in work:
            if seen[w[0]] < args.per_artist:
                seen[w[0]] += 1
                kept.append(w)
        work = kept
    if args.limit:
        work = work[: args.limit]
    todo = [w for w in work if f"{w[0]}|{w[1]}" not in done]
    print(f"chain: {len(work)} songs, {len(todo)} to label ({len(work) - len(todo)} cached), model={args.model}")

    lex = p1.Lexicon(p1.load_cmudict(p1.DEFAULT_CMU))

    def job(w):
        art, song, uniq = w
        bars = uniq[:MAX_BARS]
        text = "\n".join(f"{i}. {b[:140]}" for i, b in enumerate(bars, 1))
        prompt = PROMPT.format(topics=", ".join(TAXONOMY), n=len(bars), song=song, artist=art, bars=text)
        runs, proposed = parse_runs(call_llm(prompt, args.model), len(bars))
        row = {"schema": SCHEMA_VERSION, "prompt_version": PROMPT_VERSION, "model": args.model, "artist": art, "song": song,
               "bars_labeled": len(bars), "bars_total": len(uniq)}
        if runs:
            row.update(status="ok", runs=runs, proposed_topics=proposed, **chain_metrics(runs, len(bars)))
        else:
            row["status"] = "failed"
        return row

    with ThreadPoolExecutor(max_workers=args.workers) as ex, open(cache_path, "a", encoding="utf-8") as fh:
        futs = [ex.submit(job, w) for w in todo]
        for i, f in enumerate(as_completed(futs), 1):
            row = f.result()
            fh.write(json.dumps(row, ensure_ascii=False) + "\n")
            fh.flush()
            done[f'{row["artist"]}|{row["song"]}'] = row
            if i % 10 == 0:
                print(f"  {i}/{len(todo)}")

    # delivery shifts + final song rows
    by_artist: dict[str, list[dict]] = defaultdict(list)
    lex_bars = {}
    for art, song, uniq in work:
        lex_bars[(art, song)] = [p1.Bar(t, lex) for t in uniq]
    with open(OUT / "topic_chain_songs.jsonl", "w", encoding="utf-8") as fh:
        for art, song, _ in work:
            row = done.get(f"{art}|{song}")
            if not row or row.get("status") != "ok":
                continue
            row = {**row, "delivery": delivery_shifts(lex_bars[(art, song)])}
            row.pop("runs_raw", None)
            fh.write(json.dumps(row, ensure_ascii=False) + "\n")
            by_artist[art].append(row)
    with open(OUT / "topic_chain_artists.jsonl", "w", encoding="utf-8") as fh:
        for art, rows in sorted(by_artist.items()):
            fh.write(json.dumps(artist_chain(art, rows), ensure_ascii=False) + "\n")
    failed = sum(1 for w in work if done.get(f"{w[0]}|{w[1]}", {}).get("status") == "failed")
    print(f"done: {sum(len(v) for v in by_artist.values())} songs labeled, {failed} failed -> {OUT}")
    return 0


def artist_chain(art: str, rows: list[dict]) -> dict:
    dist: Counter = Counter()
    trans: dict[str, Counter] = defaultdict(Counter)
    for r in rows:
        for run in r["runs"]:
            dist[run["topic"]] += run["end"] - run["start"] + 1
        t = r["chain"]
        for a, b in zip(t, t[1:]):
            if a != b:
                trans[a][b] += 1
    total = sum(dist.values()) or 1
    spread = lambda k: {"median": round(statistics.median(r[k] for r in rows), 2),
                        "min": min(r[k] for r in rows), "max": max(r[k] for r in rows)}
    return {
        "schema": SCHEMA_VERSION, "artist": art, "songs": len(rows),
        "topic_change_pct": spread("topic_change_pct"), "switch_rate_per_16": spread("switch_rate_per_16"),
        "avg_run": spread("avg_run"), "distinct_topics": spread("distinct_topics"),
        "delivery_shift_pct_median": round(statistics.median(
            r["delivery"].get("shift_pct", 0) for r in rows), 1),
        "topic_share_pct": {k: round(100 * v / total, 1) for k, v in dist.most_common()},
        "transition_prob": {a: {b: round(c / sum(cs.values()), 2) for b, c in cs.most_common(5)} for a, cs in trans.items()},
        "proposed_topics": Counter(t for r in rows for t in r.get("proposed_topics", [])).most_common(10),
    }


# ---------------------------------------------------------------- genius command


def cmd_genius(args) -> int:
    OUT.mkdir(exist_ok=True)
    bars_by_artist: Counter = Counter()
    metrics_path = OUT / "song_metrics.jsonl"
    for line in open(metrics_path, encoding="utf-8"):
        r = json.loads(line)
        bars_by_artist[r["artist"].lower()] += r["bars"]
    rows = []
    for f in sorted(GENIUS_DIR.glob("*.jsonl")):
        states, lines, second = Counter(), set(), 0
        for line in open(f, encoding="utf-8"):
            try:
                d = json.loads(line)
            except json.JSONDecodeError:
                continue
            if d.get("type") != "line":
                continue
            states[d.get("state")] += 1
            if d.get("state") in ("accepted", "verified") or d.get("strength") == "accepted":
                lines.add(d.get("line"))
                second += bool(d.get("second_sense"))
        art = f.stem.lower()
        bars = bars_by_artist.get(art, 0)
        good = states["accepted"] + states["verified"]
        rows.append({"schema": SCHEMA_VERSION, "artist": f.stem, "annotations": sum(states.values()), "accepted_or_verified": good,
                     "distinct_lines": len(lines), "with_second_sense": second, "bars_in_catalog": bars,
                     "devices_per_100_bars": round(100 * good / bars, 2) if bars else None})
    # signal-type mix from candidates that were not rejected
    mix: dict[str, Counter] = defaultdict(Counter)
    for f in GENIUS_DIR.parent.glob("*-candidates.jsonl"):
        slug = f.stem[: -len("-candidates")]
        for line in open(f, encoding="utf-8"):
            try:
                d = json.loads(line)
            except json.JSONDecodeError:
                continue
            if not d.get("reject_reason"):
                mix[slug][d.get("signal_type")] += 1
    with open(OUT / "genius_devices.jsonl", "w", encoding="utf-8") as fh:
        for r in rows:
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")
    with open(OUT / "genius_signal_mix.json", "w", encoding="utf-8") as fh:
        json.dump({k: dict(v) for k, v in mix.items()}, fh, ensure_ascii=False)
    top = sorted((r for r in rows if r["devices_per_100_bars"]), key=lambda r: -r["devices_per_100_bars"])[:5]
    print(f"{len(rows)} artists; top devices/100 bars: " + ", ".join(f'{r["artist"]} {r["devices_per_100_bars"]}' for r in top))
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("chain")
    c.add_argument("--csv", type=Path, default=p1.DEFAULT_CSV)
    c.add_argument("--artists")
    c.add_argument("--limit", type=int)
    c.add_argument("--per-artist", type=int, help="first N confident songs per artist")
    c.add_argument("--model", default="haiku")
    c.add_argument("--workers", type=int, default=3)
    c.set_defaults(fn=cmd_chain)
    g = sub.add_parser("genius")
    g.set_defaults(fn=cmd_genius)
    args = ap.parse_args()
    return args.fn(args)


if __name__ == "__main__":
    raise SystemExit(main())
