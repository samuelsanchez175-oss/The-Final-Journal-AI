#!/usr/bin/env python3
"""Grade more than 1000 fresh verses, plus every verse Samuel already scored.

The 1000 verses are new. They are not imported into feedback.db and they
are not loaded into the rater. Samuel's 19 ratings stay the examples.
Each of those 19 is also graded once with that verse held out, so the
match number uses every score he gave.

Usage:
  python3 tools/style-profile/grade_thousand.py
  python3 tools/style-profile/grade_thousand.py --target 1000 --workers 3
"""

from __future__ import annotations

import argparse
import json
import sys
import threading
import time
import urllib.error
import urllib.request
from collections import Counter
from concurrent.futures import FIRST_COMPLETED, ThreadPoolExecutor, wait
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import grade_verses as gv

HERE = Path(__file__).resolve().parent
EXAMPLES = HERE / "rater" / "exports" / "sparkler_ratings_2026-10-14_0233.json"
BATCH_PATH = HERE / "rater" / "exports" / "autograde_1000.jsonl"
LOO_PATH = HERE / "rater" / "exports" / "autograde_loo19.jsonl"
SUMMARY_PATH = HERE / "rater" / "exports" / "autograde_1000_summary.txt"
MODELS = (
    "cohere/command-a-03-2025",
    "cloudflare-ai/@cf/meta/llama-3.3-70b-instruct-fp8-fast",
)
TOPICS = {
    "money_flex": "money: counting it, spending it, showing it off",
    "luxury_brands": "designer clothes, jewelry, watches, cars",
    "braggadocio_skill": "being above everyone else, shown through specifics, never by saying 'I'm the best'",
    "come_up_hustle": "coming up from nothing, the grind, then and now",
    "sex": "women and sex",
    "women_romance": "a woman he's involved with",
    "drugs": "drugs and getting high",
    "violence_street": "the street, guns, opps",
    "betrayal_enemies": "fake friends, snakes, enemies",
    "loyalty_friends": "his gang and loyalty",
    "party_lifestyle": "partying, clubs, nightlife",
    "fame_industry": "fame and the music industry",
    "family_home": "family and where he's from",
    "social_commentary": "the world around him",
    "wordplay_punchline": "punchlines and double meanings",
    "faith_mortality": "God, death, survival",
}
SCHEMES = ("aabb", "abab")
HTTP_SLOTS = threading.Semaphore(3)
WRITE_LOCK = threading.Lock()


def call_model(key: str, model: str, prompt: str, max_tokens: int, temperature: float) -> tuple[str, str]:
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": temperature,
        "max_tokens": max_tokens,
        "tool_choice": "none",
    }
    request = urllib.request.Request(
        gv.OMNI_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        method="POST",
    )
    with HTTP_SLOTS:
        try:
            with urllib.request.urlopen(request, timeout=35) as response:
                body = json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode("utf-8", errors="replace")[:240]
            raise RuntimeError(f"HTTP {exc.code}: {detail}") from exc
    choice = (body.get("choices") or [{}])[0]
    return gv.message_text(choice.get("message") or {}).strip(), str(choice.get("finish_reason") or "")


def unwrap(text: str) -> dict:
    data = gv.extract_json(text)
    if "verse_score" in data or "bars" in data:
        return data
    params = data.get("parameters") if isinstance(data.get("parameters"), dict) else {}
    inner = params.get("content")
    if isinstance(inner, str) and "{" in inner:
        return gv.extract_json(inner)
    if isinstance(inner, dict):
        return inner
    return data


def ask(key: str, prompt: str, max_tokens: int, temperature: float) -> tuple[dict, str]:
    errors = []
    for model in MODELS:
        try:
            text, finish = call_model(key, model, prompt, max_tokens, temperature)
        except (RuntimeError, urllib.error.URLError, TimeoutError, OSError, json.JSONDecodeError) as exc:
            errors.append(f"{model}: {exc}")
            if "429" in str(exc):
                time.sleep(4)
            continue
        if not text:
            errors.append(f"{model}: empty ({finish or 'no finish'})")
            continue
        try:
            return unwrap(text), model
        except (ValueError, json.JSONDecodeError) as exc:
            errors.append(f"{model}: {exc}")
    raise RuntimeError("; ".join(errors) or "no reply")


def generate_bars(key: str, topic: str, brief: str, scheme: str, seed: int) -> tuple[list[str], str]:
    prompt = (
        "Write 4 rap bars for Gunna. One scene. One action in each bar. "
        f"Rhyme scheme {scheme}. Topic: {brief}. Variation {seed}. "
        "Do not copy a famous hook. Reply with JSON only, no markdown: "
        '{"bars":["line one","line two","line three","line four"]}'
    )
    data, model = ask(key, prompt, 500, 0.9)
    raw = data.get("bars")
    if not isinstance(raw, list):
        raise RuntimeError("generation had no bars list")
    bars = []
    for item in raw:
        line = gv.one_line(item if isinstance(item, str) else "")
        if line:
            bars.append(line)
    if len(bars) < 4:
        raise RuntimeError(f"generation returned {len(bars)} bars")
    return bars[:4], model


def grade_verse(key: str, examples, contrast: str, verse: dict) -> tuple[dict, str]:
    prompt = gv.build_prompt(examples, verse, contrast)
    data, model = ask(key, prompt, 700, 0.2)
    try:
        grade = gv.normalize_grade(data, len(verse["bars"]))
    except ValueError as exc:
        score = data.get("verse_score") if isinstance(data, dict) else None
        raise RuntimeError(f"{exc}; score={score!r}") from exc
    return grade, model


def load_examples():
    export = gv.load_json(EXAMPLES)
    if export.get("schema") != gv.SCHEMA:
        raise SystemExit("examples file is not sparkler.ratings.v1")
    ratings = {row["generation_id"]: row for row in export["ratings"] if row.get("generation_id")}
    corpus = gv.index_corpus(gv.default_corpus())
    pairs = []
    for gid, row in ratings.items():
        if gid in corpus and gv.human_score(row)[0] != "unrated":
            pairs.append((corpus[gid], row))
    pairs.sort(key=lambda pair: (pair[0]["topic"], pair[0]["model"], pair[0]["generation_id"]))
    return pairs


def examples_except(pairs, held_id: str):
    kept = [(verse, row) for verse, row in pairs if verse["generation_id"] != held_id]
    return kept, gv.contrast_block(kept)


def append_jsonl(path: Path, row: dict) -> None:
    line = json.dumps(row, ensure_ascii=False) + "\n"
    with WRITE_LOCK:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as handle:
            handle.write(line)


def read_jsonl(path: Path) -> list[dict]:
    if not path.exists():
        return []
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            rows.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    return rows


def run_loo(key: str, pairs) -> None:
    done = {row.get("generation_id") for row in read_jsonl(LOO_PATH) if row.get("status") == "ok"}
    print(f"loo already {len(done)}", flush=True)
    for verse, human in pairs:
        gid = verse["generation_id"]
        if gid in done:
            continue
        kept, contrast = examples_except(pairs, gid)
        example_text = contrast + "\n" + "\n".join(gv.example_block(v, r) for v, r in kept)
        gv.assert_blind(example_text, [verse], [human])
        started = time.time()
        try:
            grade, model = grade_verse(key, kept, contrast, verse)
        except RuntimeError as exc:
            append_jsonl(LOO_PATH, {"generation_id": gid, "status": "fail", "error": str(exc)[:300]})
            print(f"loo fail {verse['topic']} {exc}"[:220], flush=True)
            continue
        kind, score = gv.human_score(human)
        wanted = gv.human_marks(human)
        got = {index: mark["vote"] for index, mark in grade["bars"].items() if mark["vote"] in (1, -1)}
        matched = sum(1 for index, vote in wanted.items() if got.get(index) == vote)
        row = {
            "generation_id": gid,
            "status": "ok",
            "topic": verse["topic"],
            "model": verse["model"],
            "judge": model,
            "samuel_score": score if kind == "slider" else kind,
            "grader_score": grade["verse_score"],
            "samuel_reasons": gv.clean_reasons(human.get("verse_reasons")),
            "grader_reasons": grade["verse_reasons"],
            "marks_matched": matched,
            "marks_total": len(wanted),
            "seconds": round(time.time() - started, 2),
        }
        append_jsonl(LOO_PATH, row)
        print(
            f"loo {verse['topic']} samuel {row['samuel_score']} grader {row['grader_score']} "
            f"lines {matched}/{len(wanted)}",
            flush=True,
        )


def jobs(limit_seeds: int):
    topics = list(TOPICS)
    for seed in range(1, limit_seeds + 1):
        for topic in topics:
            for scheme in SCHEMES:
                yield {
                    "set_id": f"{topic}-{scheme}-{seed}",
                    "topic": topic,
                    "brief": TOPICS[topic],
                    "scheme": scheme,
                    "seed": seed,
                }


def one_set(key: str, examples, contrast: str, job: dict, seen: set[str], seen_lock: threading.Lock) -> dict:
    started = time.time()
    base = {
        "set_id": job["set_id"],
        "topic": job["topic"],
        "scheme": job["scheme"],
        "seed": job["seed"],
        "status": "fail",
    }
    try:
        bars, writer = generate_bars(key, job["topic"], job["brief"], job["scheme"], job["seed"])
        fingerprint = " | ".join(bar.casefold() for bar in bars)
        with seen_lock:
            if fingerprint in seen:
                base["error"] = "duplicate verse"
                return base
            seen.add(fingerprint)
        verse = {
            "generation_id": job["set_id"],
            "model": writer,
            "artist": "Gunna",
            "topic": job["topic"],
            "topic_brief": job["brief"],
            "scheme": job["scheme"],
            "prompt_version": "verse.v4",
            "passed_checks": False,
            "bars": bars,
        }
        grade, judge = grade_verse(key, examples, contrast, verse)
    except (RuntimeError, ValueError, KeyError, TypeError) as exc:
        base["error"] = str(exc)[:300]
        base["seconds"] = round(time.time() - started, 2)
        return base
    greens = sum(1 for mark in grade["bars"].values() if mark["vote"] == 1)
    reds = sum(1 for mark in grade["bars"].values() if mark["vote"] == -1)
    rewrites = sum(1 for mark in grade["bars"].values() if mark["rewrite"])
    return {
        **base,
        "status": "ok",
        "writer": writer,
        "judge": judge,
        "bars": bars,
        "verse_score": grade["verse_score"],
        "verse_reasons": grade["verse_reasons"],
        "green": greens,
        "red": reds,
        "rewrites": rewrites,
        "seconds": round(time.time() - started, 2),
    }


def run_batch(key: str, examples, target: int, workers: int, seed_cap: int) -> int:
    contrast = gv.contrast_block(examples)
    prior = [row for row in read_jsonl(BATCH_PATH) if row.get("status") == "ok"]
    done_ids = {row["set_id"] for row in prior}
    seen = {" | ".join(bar.casefold() for bar in row.get("bars") or []) for row in prior}
    seen_lock = threading.Lock()
    ok_count = len(prior)
    print(f"batch resume {ok_count} target {target}", flush=True)
    if ok_count >= target:
        return ok_count
    fail_streak = 0
    inflight = {}
    job_iter = (job for job in jobs(seed_cap) if job["set_id"] not in done_ids)
    with ThreadPoolExecutor(max_workers=workers) as pool:
        def fill() -> None:
            while len(inflight) < workers and ok_count < target:
                job = next(job_iter, None)
                if job is None:
                    return
                future = pool.submit(one_set, key, examples, contrast, job, seen, seen_lock)
                inflight[future] = job

        fill()
        while inflight and ok_count < target:
            finished, _ = wait(inflight, timeout=90, return_when=FIRST_COMPLETED)
            if not finished:
                print(f"PROGRESS graded={ok_count} waiting", flush=True)
                continue
            for future in finished:
                inflight.pop(future, None)
                row = future.result()
                append_jsonl(BATCH_PATH, row)
                if row.get("status") == "ok":
                    ok_count += 1
                    fail_streak = 0
                    if ok_count % 25 == 0 or ok_count == target:
                        print(f"PROGRESS graded={ok_count} fails_in_a_row={fail_streak}", flush=True)
                else:
                    fail_streak += 1
                    print(f"fail {row.get('set_id')} {row.get('error', '')[:160]}", flush=True)
                    if fail_streak >= 40:
                        print("STALL 40 failures in a row", flush=True)
                        return ok_count
            fill()
    return ok_count


def summarize(target: int) -> str:
    batch = [row for row in read_jsonl(BATCH_PATH) if row.get("status") == "ok"]
    fails = [row for row in read_jsonl(BATCH_PATH) if row.get("status") != "ok"]
    loo = [row for row in read_jsonl(LOO_PATH) if row.get("status") == "ok"]
    lines = [f"fresh verses graded {len(batch)}", f"fresh failures logged {len(fails)}", f"target {target}"]
    if batch:
        scores = [row["verse_score"] for row in batch]
        hist = Counter(scores)
        lines.append("score counts " + " ".join(f"{score}:{hist[score]}" for score in range(1, 11) if hist[score]))
        lines.append(
            f"mean {sum(scores) / len(scores):.2f}  "
            f"score 1 {(hist[1] / len(scores)):.0%}  "
            f"score 7-10 {sum(hist[s] for s in range(7, 11)) / len(scores):.0%}"
        )
        greens = sum(row.get("green") or 0 for row in batch)
        reds = sum(row.get("red") or 0 for row in batch)
        marked = greens + reds
        lines.append(
            f"line marks green {greens} red {reds} "
            f"green share {(greens / marked):.0%}" if marked else "line marks none"
        )
        reasons = Counter(code for row in batch for code in row.get("verse_reasons") or [])
        if reasons:
            lines.append("reasons " + ", ".join(f"{code} {n}" for code, n in reasons.most_common()))
        by_topic = {}
        for row in batch:
            by_topic.setdefault(row["topic"], []).append(row["verse_score"])
        topic_bits = []
        for topic, values in sorted(by_topic.items(), key=lambda item: sum(item[1]) / len(item[1])):
            topic_bits.append(f"{topic} {sum(values) / len(values):.1f} (n={len(values)})")
        lines.append("mean by topic low to high: " + "; ".join(topic_bits))
    slider = [row for row in loo if isinstance(row.get("samuel_score"), int)]
    if slider:
        gaps = [abs(row["grader_score"] - row["samuel_score"]) for row in slider]
        exact = sum(gap == 0 for gap in gaps)
        within = sum(gap <= 1 for gap in gaps)
        matched = sum(row.get("marks_matched") or 0 for row in slider)
        total = sum(row.get("marks_total") or 0 for row in slider)
        lines.append(
            f"held-out human verses {len(slider)}  exact {exact}/{len(slider)}  "
            f"within 1 {within}/{len(slider)}  mean abs error {sum(gaps) / len(gaps):.2f}"
        )
        if total:
            lines.append(f"held-out line marks {matched}/{total}")
    text = "\n".join(lines) + "\n"
    SUMMARY_PATH.write_text(text, encoding="utf-8")
    return text


def self_check() -> None:
    wrapped = json.dumps({
        "name": "memory_save",
        "parameters": {"content": json.dumps({"verse_score": 2, "verse_reasons": ["no_sense"], "bars": []})},
    })
    data = unwrap(wrapped)
    grade = gv.normalize_grade(data, 1)
    assert grade["verse_score"] == 2
    direct = unwrap('{"bars":["a","b","c","d"]}')
    assert direct["bars"][0] == "a"
    print("self-check ok")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", type=int, default=1000)
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--seed-cap", type=int, default=80)
    parser.add_argument("--self-check", action="store_true")
    parser.add_argument("--skip-loo", action="store_true")
    parser.add_argument("--summary-only", action="store_true")
    args = parser.parse_args()
    if args.self_check:
        self_check()
        return 0
    if args.summary_only:
        print(summarize(args.target), end="")
        return 0
    pairs = load_examples()
    if len(pairs) < 10:
        print(f"only {len(pairs)} example verses", file=sys.stderr)
        return 1
    key = gv.manage_key()
    print(f"examples {len(pairs)}", flush=True)
    if not args.skip_loo:
        run_loo(key, pairs)
    count = run_batch(key, pairs, args.target, args.workers, args.seed_cap)
    print(summarize(args.target), end="")
    if count < args.target:
        print(f"stopped at {count}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
