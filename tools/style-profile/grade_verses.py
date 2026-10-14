#!/usr/bin/env python3
"""Grade phase6.v2 verses the way Samuel rates them.

Few-shot from a sparkler.ratings.v1 export. Every verse being graded is
held out of the examples, including its saved rewrites. The script writes
a separate sparkler.ratings.v1 file with rater "sparkler-grader".

It does not import that file into feedback.db and it does not touch the
rater page. Do not pass the autograde file to import_ratings.py.

Usage:
  python3 tools/style-profile/grade_verses.py \\
    --examples tools/style-profile/rater/exports/sparkler_ratings_2026-10-14_0233.json \\
    --out tools/style-profile/rater/exports/sparkler_autograde_family_fame_street.json \\
    out/rater-batch/07_family.json out/rater-batch/08_fame.json out/rater-batch/09_street.json
"""

from __future__ import annotations

import argparse
import json
import re
import socket
import sqlite3
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import feedback_store

HERE = Path(__file__).resolve().parent
REASONS = feedback_store.REASONS
REASON_ORDER = ("no_sense", "bad_rhyme", "off_flow", "off_topic", "too_copied", "cringe")
OMNI_URL = "http://127.0.0.1:20128/v1/chat/completions"
DEFAULT_MODEL = "gemini/gemini-2.5-flash-lite"
FALLBACK_MODEL = "sambanova/Meta-Llama-3.3-70B-Instruct"
SCHEMA = "sparkler.ratings.v1"
RATER = "sparkler-grader"


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def verse_from_model(doc: dict, model: dict) -> dict | None:
    gid = model.get("generation_id")
    texts = []
    for bar in model.get("bars") or []:
        text = " ".join(str(bar.get("text") or "").split())
        if text:
            texts.append(text)
    if not gid or not texts:
        return None
    return {
        "generation_id": gid,
        "model": model.get("model") or "",
        "artist": doc.get("artist") or "",
        "topic": doc.get("topic") or "",
        "topic_brief": doc.get("topic_brief") or "",
        "scheme": doc.get("scheme") or "",
        "prompt_version": doc.get("prompt_version") or "",
        "passed_checks": bool(model.get("passed")),
        "bars": texts,
    }


def load_phase6(path: Path) -> list[dict]:
    doc = load_json(path)
    if doc.get("schema") != "phase6.v2":
        raise SystemExit(f"{path} is not phase6.v2")
    models = doc.get("models") or {}
    items = models.values() if isinstance(models, dict) else models
    verses = []
    for model in items:
        verse = verse_from_model(doc, model)
        if verse:
            verses.append(verse)
    return verses


def default_corpus() -> list[Path]:
    out = HERE / "out"
    files = []
    main = out / "model_comparison.json"
    if main.exists():
        files.append(main)
    batch = out / "rater-batch"
    if batch.is_dir():
        files.extend(sorted(p for p in batch.glob("*.json") if p.is_file()))
    return files


def index_corpus(paths: list[Path]) -> dict[str, dict]:
    index = {}
    for path in paths:
        try:
            doc = load_json(path)
        except (OSError, json.JSONDecodeError):
            continue
        if doc.get("schema") != "phase6.v2":
            continue
        models = doc.get("models") or {}
        items = models.values() if isinstance(models, dict) else models
        for model in items:
            verse = verse_from_model(doc, model)
            if verse:
                index[verse["generation_id"]] = verse
    return index


def human_score(row: dict) -> tuple[str, int | None]:
    score = row.get("verse_score")
    if isinstance(score, int) and 1 <= score <= 10:
        return "slider", score
    vote = row.get("verse_vote")
    if score is None and vote == -1:
        return "thumbs_down", None
    if score is None and vote == 1:
        return "thumbs_up", None
    return "unrated", None


def clean_reasons(values) -> list[str]:
    found = []
    for code in values or []:
        if code in REASONS and code not in found:
            found.append(code)
    return [code for code in REASON_ORDER if code in found]


def one_line(text: str) -> str:
    return " ".join(str(text or "").split())


def normalize_grade(raw: dict, n_bars: int) -> dict:
    """Clamp a model reply onto the sparkler contract.

    verse_score and verse_vote are the same integer. A score of 1 stays 1.
    Reasons clear at 7 and above. A bar vote is only 1, -1, or absent.
    The verse score is never copied onto a bar.
    """
    if not isinstance(raw, dict):
        raise ValueError("grade is not an object")
    score = raw.get("verse_score")
    if isinstance(score, str) and score.strip().isdigit():
        score = int(score.strip())
    if not isinstance(score, int) or isinstance(score, bool) or not 1 <= score <= 10:
        raise ValueError("verse_score must be an integer 1-10")
    reasons = [] if score >= 7 else clean_reasons(raw.get("verse_reasons"))
    by_index = {}
    for bar in raw.get("bars") or []:
        if not isinstance(bar, dict):
            continue
        index = bar.get("bar_index")
        if isinstance(index, str) and index.strip().isdigit():
            index = int(index.strip())
        if not isinstance(index, int) or isinstance(index, bool) or not 0 <= index < n_bars:
            continue
        vote = bar.get("vote")
        if vote in ("green", "up", "1", 1, True):
            vote = 1
        elif vote in ("red", "down", "-1", -1):
            vote = -1
        else:
            vote = None
        rewrite = "" if vote == 1 else one_line(bar.get("rewrite") or "")
        if vote not in (1, -1) and not rewrite:
            continue
        by_index[index] = {"vote": vote, "rewrite": rewrite}
    return {"verse_score": score, "verse_reasons": reasons, "bars": by_index}


def rating_row(verse: dict, grade: dict, elapsed_ms: int) -> dict:
    bars = []
    for index, text in enumerate(verse["bars"]):
        mark = grade["bars"].get(index) or {"vote": None, "rewrite": ""}
        vote = mark["vote"]
        rewrite = mark["rewrite"]
        if rewrite and rewrite.casefold() == text.casefold():
            rewrite = ""
        if vote not in (1, -1) and not rewrite:
            continue
        bars.append({
            "bar_index": index,
            "bar_id": f"{verse['generation_id']}:{index}",
            "text": text,
            "vote": vote if vote in (1, -1) else None,
            "keeper": False,
            "reasons": [],
            "rewrite": rewrite,
        })
    score = grade["verse_score"]
    return {
        "generation_id": verse["generation_id"],
        "model": verse["model"],
        "artist": verse["artist"],
        "topic": verse["topic"],
        "prompt_version": verse["prompt_version"],
        "passed_checks": verse["passed_checks"],
        "verse_score": score,
        "verse_vote": score,
        "verse_reasons": grade["verse_reasons"],
        "note": "",
        "bar_votes": bars,
        "rated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "time_to_rate_ms": elapsed_ms,
    }


def mark_word(vote) -> str:
    if vote == 1:
        return "green"
    if vote == -1:
        return "red"
    return "unmarked"


def example_block(verse: dict, row: dict) -> str:
    kind, score = human_score(row)
    if kind == "slider":
        score_line = f"verse_score: {score}"
    elif kind == "thumbs_down":
        score_line = "verse_score: thumbs_down"
    elif kind == "thumbs_up":
        score_line = "verse_score: thumbs_up"
    else:
        score_line = "verse_score: unrated"
    marks = {}
    for bar in row.get("bar_votes") or []:
        index = bar.get("bar_index")
        if isinstance(index, int):
            marks[index] = bar
    lines = [
        "EXAMPLE",
        f"topic: {verse['topic']}",
        f"brief: {verse['topic_brief']}",
        f"scheme: {verse['scheme']}",
        f"passed_checks: {str(verse['passed_checks']).lower()}",
        "bars:",
    ]
    for index, text in enumerate(verse["bars"]):
        lines.append(f"[{index}] {text}")
    lines.append("samuel:")
    lines.append(score_line)
    lines.append("verse_reasons: " + ", ".join(clean_reasons(row.get("verse_reasons"))))
    for index in range(len(verse["bars"])):
        mark = marks.get(index) or {}
        vote = mark.get("vote")
        if vote not in (1, -1):
            vote = None
        lines.append(f"[{index}] {mark_word(vote)}")
        rewrite = one_line(mark.get("rewrite") or "")
        if rewrite:
            lines.append(f"[{index}] rewrite: {rewrite}")
    return "\n".join(lines)


def contrast_block(examples: list[tuple[dict, dict]]) -> str:
    greens = []
    reds = []
    for verse, row in examples:
        marks = {}
        for bar in row.get("bar_votes") or []:
            if isinstance(bar.get("bar_index"), int):
                marks[bar["bar_index"]] = bar.get("vote")
        for index, text in enumerate(verse["bars"]):
            vote = marks.get(index)
            if vote == 1 and text not in greens:
                greens.append(text)
            elif vote == -1 and text not in reds:
                reds.append(text)
    lines = ["Lines Samuel marked green:"]
    lines.extend(f"- {text}" for text in greens[:8])
    if not greens:
        lines.append("- (none in the examples)")
    lines.append("Lines Samuel marked red:")
    lines.extend(f"- {text}" for text in reds[:8])
    if not reds:
        lines.append("- (none in the examples)")
    lines.append(
        "Green means the line is that plain: a person, a place, or an object, and one action. "
        "Red means the line is vague, decorative, or only there to rhyme. "
        "Leave a line unmarked when you are unsure. "
        "Do not mark a plain spoken line red just because the rest of the verse is weak."
    )
    lines.append(
        "Score the way the examples do. verse_score is 1 when every line is red. "
        "verse_score is 2 when at least one line is green, or when some lines are red and the rest are unmarked. "
        "A verse can be all green and still score 2. "
        "Do not score 1 if you marked any line green. "
        "A rewrite must be a different line. If you would keep the wording, mark the line green and leave rewrite empty."
    )
    return "\n".join(lines)


def score_spread(rows: list[dict]) -> str:
    sliders = []
    downs = 0
    ups = 0
    for row in rows:
        kind, score = human_score(row)
        if kind == "slider":
            sliders.append(score)
        elif kind == "thumbs_down":
            downs += 1
        elif kind == "thumbs_up":
            ups += 1
    slider_text = ", ".join(str(n) for n in sorted(sliders)) or "none"
    return (
        f"Slider scores in the examples: {slider_text}. "
        f"Older thumbs_down count: {downs}. Older thumbs_up count: {ups}."
    )


def build_prompt(examples: list[tuple[dict, dict]], verse: dict, contrast: str) -> str:
    rows = [row for _, row in examples]
    blocks = [example_block(sample, row) for sample, row in examples]
    target = [
        "GRADE THIS VERSE",
        f"topic: {verse['topic']}",
        f"brief: {verse['topic_brief']}",
        f"scheme: {verse['scheme']}",
        f"passed_checks: {str(verse['passed_checks']).lower()}",
        "bars:",
    ]
    for index, text in enumerate(verse["bars"]):
        target.append(f"[{index}] {text}")
    rules = f"""You are grading one AI rap verse the way Samuel grades in Sparkler Rater.
Reply with one JSON object and no markdown.

Samuel is harsh. {score_spread(rows)}
thumbs_down is the old reject button. It is not the number 1.
On the 1-10 scale, 1 is the worst verse and 10 is a verse he would keep.
Use 7-10 only when every line is a plain spoken sentence he would actually keep, and then verse_reasons must be [].

Reason codes, and no others: no_sense, bad_rhyme, off_flow, off_topic, too_copied, cringe.
no_sense is the usual reason. A passed_checks value of true does not mean he likes the verse.

Green (vote 1) means the line is a plain spoken sentence with a real place, a person, or an object, and one action.
Red (vote -1) means the line is vague, decorative, or only there to make the rhyme.
Leave a line unmarked (vote null) when you would not mark it.
When a line is red, rewrite it as one spoken line with a person, a place, and one action.
The rewrite stays in the same scene. Do not paste a line from the examples.
Leave rewrite empty on green lines and on unmarked lines.
Do not copy the verse score onto a bar. Bar reasons are always [].

bar_index is 0-based and must match the bars above.
JSON shape:
{{"verse_score": 2, "verse_reasons": ["no_sense"], "bars": [{{"bar_index": 0, "vote": -1, "rewrite": "one spoken line"}}, {{"bar_index": 1, "vote": 1, "rewrite": ""}}]}}
"""
    return rules + "\n\n" + contrast + "\n\n" + "\n\n".join(blocks) + "\n\n" + "\n".join(target)


def assert_blind(example_text: str, held_verses: list[dict], held_rows: list[dict]) -> None:
    for verse in held_verses:
        gid = verse["generation_id"]
        if gid and gid in example_text:
            raise SystemExit("blind check failed: held-out generation id is in the examples")
        for bar in verse["bars"]:
            if bar and bar in example_text:
                raise SystemExit("blind check failed: held-out bar is in the examples")
    for row in held_rows:
        for bar in row.get("bar_votes") or []:
            rewrite = one_line(bar.get("rewrite") or "")
            if rewrite and rewrite in example_text:
                raise SystemExit("blind check failed: held-out rewrite is in the examples")


def manage_key() -> str:
    db_path = Path.home() / ".omniroute" / "storage.sqlite"
    con = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    try:
        row = con.execute(
            "select key from api_keys where name = ? and revoked_at is null",
            ("one 1",),
        ).fetchone()
    finally:
        con.close()
    if not row or not row[0]:
        raise SystemExit("omniroute manage key is missing")
    return row[0]


def extract_json(text: str) -> dict:
    cleaned = re.sub(r"<think>.*?</think>", "", text, flags=re.S).strip()
    cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
    cleaned = re.sub(r"\s*```$", "", cleaned)
    start = cleaned.find("{")
    end = cleaned.rfind("}")
    if start < 0 or end <= start:
        raise ValueError("no JSON object in the model reply")
    parsed = json.loads(cleaned[start:end + 1])
    if not isinstance(parsed, dict):
        raise ValueError("model JSON is not an object")
    return parsed


def message_text(message: dict) -> str:
    content = message.get("content")
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for part in content:
            if isinstance(part, str):
                parts.append(part)
            elif isinstance(part, dict):
                parts.append(str(part.get("text") or part.get("content") or ""))
        return "".join(parts)
    return ""


def chat(key: str, model: str, prompt: str) -> tuple[str, str]:
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.2,
        "max_tokens": 2048,
        "tool_choice": "none",
    }
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        OMNI_URL,
        data=data,
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=40) as response:
            body = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")[:300]
        raise RuntimeError(f"HTTP {exc.code}: {detail}") from exc
    choice = (body.get("choices") or [{}])[0]
    message = choice.get("message") or {}
    return message_text(message).strip(), str(choice.get("finish_reason") or "")


def grade_one(key: str, model: str, prompt: str, n_bars: int) -> tuple[dict, str]:
    errors = []
    pause = False
    for attempt_model in (model, model, FALLBACK_MODEL):
        if pause:
            time.sleep(4)
            pause = False
        try:
            text, finish = chat(key, attempt_model, prompt)
        except (RuntimeError, urllib.error.URLError, TimeoutError, socket.timeout, OSError, json.JSONDecodeError) as exc:
            errors.append(f"{attempt_model}: {exc}")
            pause = "429" in str(exc)
            continue
        if not text:
            errors.append(f"{attempt_model}: empty content ({finish or 'no finish'})")
            continue
        try:
            grade = normalize_grade(extract_json(text), n_bars)
        except (ValueError, json.JSONDecodeError) as exc:
            errors.append(f"{attempt_model}: {exc}")
            continue
        return grade, attempt_model
    raise RuntimeError("; ".join(errors) or "no grade")


def human_marks(row: dict | None) -> dict[int, int]:
    marks = {}
    if not row:
        return marks
    for bar in row.get("bar_votes") or []:
        if bar.get("vote") in (1, -1) and isinstance(bar.get("bar_index"), int):
            marks[bar["bar_index"]] = bar["vote"]
    return marks


def compare_line(verse: dict, human: dict | None, auto: dict) -> str:
    if not human:
        return f"{verse['topic']}  {verse['model']}  no human rating  auto {auto['verse_score']}"
    kind, score = human_score(human)
    human_label = str(score) if kind == "slider" else kind
    delta = ""
    if kind == "slider":
        delta = f"  delta {auto['verse_score'] - score:+d}"
    wanted = human_marks(human)
    got = {index: mark["vote"] for index, mark in auto["bars"].items() if mark["vote"] in (1, -1)}
    matched = sum(1 for index, vote in wanted.items() if got.get(index) == vote)
    mark_text = f"{matched}/{len(wanted)} line marks" if wanted else "no line marks"
    human_reasons = ",".join(clean_reasons(human.get("verse_reasons"))) or "-"
    auto_reasons = ",".join(auto["verse_reasons"]) or "-"
    return (
        f"{verse['topic']}  {verse['model']}  samuel {human_label}  "
        f"grader {auto['verse_score']}{delta}  {mark_text}  "
        f"reasons {human_reasons} vs {auto_reasons}"
    )


def summary_lines(pairs: list[tuple[dict, dict | None, dict]]) -> list[str]:
    scored = []
    exact = 0
    within = 0
    matched = 0
    marked = 0
    for _verse, human, auto in pairs:
        if not human:
            continue
        kind, score = human_score(human)
        if kind == "slider":
            gap = abs(auto["verse_score"] - score)
            scored.append(gap)
            exact += gap == 0
            within += gap <= 1
        wanted = human_marks(human)
        got = {index: mark["vote"] for index, mark in auto["bars"].items() if mark["vote"] in (1, -1)}
        marked += len(wanted)
        matched += sum(1 for index, vote in wanted.items() if got.get(index) == vote)
    lines = [f"graded {len(pairs)}"]
    if scored:
        mean = sum(scored) / len(scored)
        lines.append(
            f"slider verses {len(scored)}  exact {exact}/{len(scored)}  "
            f"within 1 {within}/{len(scored)}  mean abs error {mean:.2f}"
        )
    if marked:
        lines.append(f"line marks matched {matched}/{marked}")
    return lines


def self_check() -> None:
    grade = normalize_grade(
        {
            "verse_score": "1",
            "verse_reasons": ["no_sense", "not_a_reason", "no_sense"],
            "bars": [
                {"bar_index": 0, "vote": -1, "rewrite": "mama  washing\npots"},
                {"bar_index": 1, "vote": 1, "rewrite": "should be dropped"},
                {"bar_index": 2, "vote": None, "rewrite": ""},
                {"bar_index": 9, "vote": 1, "rewrite": ""},
            ],
        },
        3,
    )
    assert grade["verse_score"] == 1, grade
    assert grade["verse_reasons"] == ["no_sense"], grade
    assert grade["bars"][0]["rewrite"] == "mama washing pots"
    assert grade["bars"][1]["rewrite"] == ""
    assert 2 not in grade["bars"]
    high = normalize_grade({"verse_score": 8, "verse_reasons": ["cringe"], "bars": []}, 2)
    assert high["verse_reasons"] == []
    row = rating_row(
        {
            "generation_id": "abc",
            "model": "m",
            "artist": "Gunna",
            "topic": "family_home",
            "prompt_version": "verse.v4",
            "passed_checks": False,
            "bars": ["one", "two", "three"],
        },
        grade,
        10,
    )
    assert row["verse_vote"] == 1 and row["verse_score"] == 1
    assert [bar["vote"] for bar in row["bar_votes"]] == [-1, 1]
    assert all(bar["reasons"] == [] and bar["keeper"] is False for bar in row["bar_votes"])
    try:
        normalize_grade({"verse_score": 0, "bars": []}, 1)
    except ValueError:
        pass
    else:
        raise SystemExit("score 0 should fail")
    print("self-check ok")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Grade verses into sparkler.ratings.v1")
    parser.add_argument("files", nargs="*", type=Path, help="phase6.v2 comparison files to grade")
    parser.add_argument("--examples", type=Path, help="sparkler.ratings.v1 export used as few-shot")
    parser.add_argument("--out", type=Path, help="autograde JSON path")
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--dry-run", action="store_true", help="print the first prompt and do not call a model")
    parser.add_argument("--self-check", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.self_check:
        self_check()
        if not args.files:
            return 0
    if not args.files or not args.examples:
        print("usage: grade_verses.py --examples <ratings.json> [--out <file>] <phase6.json>...", file=sys.stderr)
        return 2
    export = load_json(args.examples)
    if export.get("schema") != SCHEMA or not isinstance(export.get("ratings"), list):
        print("examples file must be sparkler.ratings.v1", file=sys.stderr)
        return 1
    ratings = {row.get("generation_id"): row for row in export["ratings"] if row.get("generation_id")}
    corpus = index_corpus(default_corpus())
    targets = []
    for path in args.files:
        targets.extend(load_phase6(path))
    if not targets:
        print("no verses to grade", file=sys.stderr)
        return 1
    held_ids = {verse["generation_id"] for verse in targets}
    examples = []
    for gid, row in ratings.items():
        if gid in held_ids or gid not in corpus:
            continue
        if human_score(row)[0] == "unrated":
            continue
        examples.append((corpus[gid], row))
    examples.sort(key=lambda pair: (pair[0]["topic"], pair[0]["model"], pair[0]["generation_id"]))
    if not examples:
        print("no held-out examples available", file=sys.stderr)
        return 1
    contrast = contrast_block(examples)
    example_text = contrast + "\n\n" + "\n\n".join(example_block(verse, row) for verse, row in examples)
    held_rows = [ratings[gid] for gid in held_ids if gid in ratings]
    assert_blind(example_text, targets, held_rows)
    print(f"examples {len(examples)}  held out {len(held_ids)}  blind check ok", flush=True)
    if args.dry_run:
        print(build_prompt(examples, targets[0], contrast))
        return 0

    key = manage_key()
    graded = []
    comparisons = []
    failures = []
    for number, verse in enumerate(targets, start=1):
        print(f"grading {number}/{len(targets)} {verse['topic']} {verse['model']}", flush=True)
        prompt = build_prompt(examples, verse, contrast)
        started = time.time()
        try:
            grade, used_model = grade_one(key, args.model, prompt, len(verse["bars"]))
        except RuntimeError as exc:
            failures.append(f"{verse['generation_id']} {exc}")
            print(f"  failed {exc}", flush=True)
            continue
        elapsed_ms = int((time.time() - started) * 1000)
        row = rating_row(verse, grade, elapsed_ms)
        graded.append(row)
        human = ratings.get(verse["generation_id"])
        comparisons.append((verse, human, {"verse_score": grade["verse_score"], "verse_reasons": grade["verse_reasons"], "bars": grade["bars"]}))
        print(f"  {used_model}  {compare_line(verse, human, comparisons[-1][2])}", flush=True)

    if not graded:
        print("no grades written", file=sys.stderr)
        for line in failures:
            print(line, file=sys.stderr)
        return 1
    out_path = args.out
    if out_path is None:
        stamp = datetime.now().strftime("%Y-%m-%d_%H%M")
        out_path = HERE / "rater" / "exports" / f"sparkler_autograde_{stamp}.json"
    body = {
        "schema": SCHEMA,
        "rater": RATER,
        "exported_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "ratings": graded,
    }
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(body, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    report = [f"judge {args.model}"]
    report.extend(compare_line(verse, human, auto) for verse, human, auto in comparisons)
    report.extend(summary_lines(comparisons))
    if failures:
        report.append(f"failed {len(failures)}")
        report.extend(failures)
    report_path = out_path.with_suffix(".report.txt")
    report_path.write_text("\n".join(report) + "\n", encoding="utf-8")
    print(f"wrote {out_path}")
    print(f"report {report_path}")
    for line in summary_lines(comparisons):
        print(line)
    return 0


if __name__ == "__main__":
    sys.exit(main())
