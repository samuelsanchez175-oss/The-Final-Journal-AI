#!/usr/bin/env python3
"""Local tuning desk for the lyric model. Step 1 is layout plus real metrics.

Generate is not connected. This page reads files on this Mac and does not
upload the catalog or the weights.

From tools/lyric-llm:

    /usr/bin/python3 desk.py

Then open http://127.0.0.1:8766/
The listen sheet stays on port 8765.
"""

from __future__ import annotations

import csv
import hashlib
import json
import re
import sys
import time
from datetime import datetime
from html import escape
from zoneinfo import ZoneInfo
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

HERE = Path(__file__).resolve().parent
HOST = "127.0.0.1"
PORT = 8766
EVAL_STALE_SECONDS = 6 * 3600
LOG_STALE_SECONDS = 120
PINNED_VOICES = ("Gunna", "Young Thug", "Young Stoner Life")
GRADE_FIELDS = (
    "rhyme (1-5)",
    "flow (1-5)",
    "voice match (1-5)",
    "originality (1-5)",
    "keep (yes/no)",
)


def _stamp(epoch: float) -> str:
    return datetime.fromtimestamp(epoch).strftime("%Y-%m-%d %H:%M")


def _stamp_et(epoch: float) -> str:
    dt = datetime.fromtimestamp(float(epoch), ZoneInfo("America/New_York"))
    return dt.strftime("%-I:%M %p ET")


def _number(text: str):
    try:
        return float(text)
    except (TypeError, ValueError):
        return None


def read_model_name(path: Path):
    if not path.is_file():
        return None
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if line.startswith("model:"):
            name = line.split(":", 1)[1].strip()
            return name or None
    return None


def read_voices(path: Path) -> list:
    if not path.is_file():
        return list(PINNED_VOICES)
    found = []
    seen = set()
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        raw = line.strip()
        if raw.startswith("<voice:") and raw.endswith(">"):
            name = raw[len("<voice:") : -1].strip()
        else:
            name = raw
        if name and name not in seen:
            seen.add(name)
            found.append(name)
    pinned = [name for name in PINNED_VOICES if name in seen]
    rest = sorted((name for name in found if name not in PINNED_VOICES), key=str.lower)
    return pinned + rest


def _search(text: str, pattern: str):
    match = re.search(pattern, text, re.M)
    if not match:
        return None
    return match.group(1).strip()


def _syllable_rows(text: str) -> list:
    rows = []
    in_table = False
    for line in text.splitlines():
        if line.startswith("## 4."):
            break
        if not in_table:
            if line.startswith("| Voice |") and "Mean syllables" in line:
                in_table = True
            continue
        if not line.startswith("|"):
            if rows:
                break
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 7 or cells[0] in ("Voice", "---") or set(cells[0]) <= {"-"}:
            continue
        if not re.match(r"^-+:?$", cells[1]) and _number(cells[3]) is None:
            continue
        if _number(cells[3]) is None:
            continue
        rows.append(
            {
                "voice": cells[0],
                "bpm": cells[1],
                "source": cells[2],
                "mean_syllables": cells[3],
                "median": cells[4],
                "flow": cells[5],
                "corpus_flow": cells[6],
            }
        )
    return rows


def read_eval(path: Path, now: float) -> dict:
    empty = {
        "status": "absent",
        "perplexity": None,
        "test_loss": None,
        "songs": None,
        "windows": None,
        "corpus_rhyme": None,
        "generated_rhyme": None,
        "corpus_flow": None,
        "generated_flow": None,
        "syllables": [],
        "adapter_line": None,
        "written_at": None,
        "stale": False,
        "note": "out/eval_report.md is not on disk.",
    }
    if not path.is_file():
        return empty
    text = path.read_text(encoding="utf-8", errors="replace")
    written = path.stat().st_mtime
    age = max(0.0, now - written)
    syllables = _syllable_rows(text)
    long_count = 0
    for row in syllables:
        mean = _number(row["mean_syllables"])
        median = _number(row["median"])
        if mean is not None and median is not None and mean > median + 1:
            long_count += 1
    return {
        "status": "snapshot",
        "perplexity": _search(text, r"^- Perplexity:\s*([0-9.]+)\s*$"),
        "test_loss": _search(text, r"^- Test loss:\s*([0-9.]+)\s*$"),
        "songs": _search(text, r"^- Test songs:\s*([0-9,]+)\s*$"),
        "windows": _search(text, r"^- Windows scored:\s*([0-9,]+)\s*$"),
        "corpus_rhyme": _search(text, r"^- Corpus mean end-rhyme rate:\s*([0-9.]+)\s*$"),
        "generated_rhyme": _search(text, r"^- Generated mean end-rhyme rate:\s*([0-9.]+)\s*$"),
        "corpus_flow": _search(text, r"^- Corpus mean flow consistency:\s*([0-9.]+)\s*$"),
        "generated_flow": _search(
            text,
            r"^- Generated mean flow consistency on the five fidelity samples:\s*([0-9.]+)\s*$",
        ),
        "syllables": syllables,
        "long_count": long_count,
        "adapter_line": _search(text, r"^(No LoRA adapter has been trained\..*)$"),
        "model_line": _search(text, r"`(mlx-community/[^`]+)`"),
        "written_at": _stamp(written),
        "stale": age >= EVAL_STALE_SECONDS,
        "note": "",
    }


def read_training_log(path: Path, now: float) -> dict:
    absent = {
        "status": "absent",
        "train_loss": None,
        "val_loss": None,
        "learning_rate": None,
        "points": [],
        "val_points": [],
        "rows": 0,
        "stale": False,
        "written_at": None,
        "note": "out/training_log.csv is not on disk. Training has not started.",
    }
    if not path.is_file():
        return absent
    written = path.stat().st_mtime
    with path.open(newline="", encoding="utf-8", errors="replace") as handle:
        rows = list(csv.DictReader(handle))
    if not rows:
        absent["note"] = "out/training_log.csv has a header and no rows. Training has not logged a step."
        absent["written_at"] = _stamp(written)
        return absent
    points = []
    val_points = []
    last_train = None
    last_val = None
    last_lr = None
    for row in rows:
        step = _number(row.get("step", ""))
        train = row.get("train_loss", "")
        val = row.get("val_loss", "")
        rate = row.get("learning_rate", "")
        train_n = _number(train)
        if step is not None and train_n is not None:
            points.append({"step": row.get("step", "").strip(), "loss": train.strip()})
            last_train = train.strip()
        if _number(val) is not None:
            val_points.append({"step": row.get("step", "").strip(), "loss": val.strip()})
            last_val = val.strip()
        if _number(rate) is not None:
            last_lr = rate.strip()
    age = max(0.0, now - written)
    return {
        "status": "log",
        "train_loss": last_train,
        "val_loss": last_val,
        "learning_rate": last_lr,
        "points": points,
        "val_points": val_points,
        "rows": len(rows),
        "stale": age >= LOG_STALE_SECONDS,
        "written_at": _stamp(written),
        "note": "",
    }


def _grade_value(row: dict, key: str) -> str:
    return (row.get(key) or "").strip()


def read_grades(path: Path) -> dict:
    if path is None or not path.is_file():
        return {
            "status": "absent",
            "rows": [],
            "blank_rows": 0,
            "note": "No grade sheet was found to read.",
        }
    with path.open(newline="", encoding="utf-8", errors="replace") as handle:
        rows = list(csv.DictReader(handle))
    marked = []
    blank = 0
    for row in rows:
        if not any(_grade_value(row, key) for key in GRADE_FIELDS):
            blank += 1
            continue
        marked.append(
            {
                "batch": _grade_value(row, "batch"),
                "voice": _grade_value(row, "voice"),
                "bpm": _grade_value(row, "bpm"),
                "temperature": _grade_value(row, "temperature"),
                "rhyme": _grade_value(row, "rhyme (1-5)"),
                "flow": _grade_value(row, "flow (1-5)"),
                "voice_match": _grade_value(row, "voice match (1-5)"),
                "originality": _grade_value(row, "originality (1-5)"),
                "keep": _grade_value(row, "keep (yes/no)"),
            }
        )
    return {
        "status": "sheet",
        "rows": marked,
        "blank_rows": blank,
        "name": path.name,
        "note": "",
    }


def listen_sheet_state(path: Path) -> str:
    if not path.is_file():
        return "missing"
    with path.open(newline="", encoding="utf-8", errors="replace") as handle:
        rows = list(csv.DictReader(handle))
    for row in rows:
        if any(_grade_value(row, key) for key in GRADE_FIELDS):
            return "graded"
    return "blank"


def adapter_state(root: Path) -> dict:
    weights = root / "adapters" / "adapters.safetensors"
    if weights.is_file():
        return {"present": True, "note": "An adapter file is on disk."}
    return {
        "present": False,
        "note": "No adapter file. adapters/adapters.safetensors is not on disk.",
    }


def collect_metrics(root: Path, grades_path: Path = None, now: float = None) -> dict:
    now = time.time() if now is None else now
    if grades_path is None:
        grades_path = Path.home() / "Downloads" / "grading.csv"
    payload = {
        "model": read_model_name(root / "train_config.yaml"),
        "adapter": adapter_state(root),
        "voices": read_voices(root / "out" / "voices.txt"),
        "eval": read_eval(root / "out" / "eval_report.md", now),
        "training": read_training_log(root / "out" / "training_log.csv", now),
        "grades": read_grades(grades_path),
        "listen_sheet": listen_sheet_state(root / "out" / "listen" / "grading.csv"),
        "read_at": _stamp(now),
    }
    canonical = json.dumps(
        {key: value for key, value in payload.items() if key != "read_at"},
        sort_keys=True,
        ensure_ascii=True,
    )
    payload["signature"] = hashlib.sha256(canonical.encode("utf-8")).hexdigest()[:16]
    return payload


def _shown(value) -> str:
    if value is None or value == "":
        return "no data yet"
    return str(value)


def _window(title: str, body: str, absent: bool) -> str:
    kind = "window absent" if absent else "window"
    return '<article class="%s"><h3>%s</h3>%s</article>' % (kind, escape(title), body)


def _figure(value, absent: bool) -> str:
    kind = "figure missing" if absent else "figure"
    return '<p class="%s">%s</p>' % (kind, escape(_shown(value)))


def _hint(text: str) -> str:
    return '<p class="hint">%s</p>' % escape(text)


def _stale(text: str) -> str:
    if not text:
        return ""
    return '<p class="stale">%s</p>' % escape(text)


def _eval_status(eval_report: dict) -> str:
    if eval_report.get("status") != "snapshot" or not eval_report.get("written_at"):
        return ""
    if eval_report.get("stale"):
        return "Snapshot written %s. This metric has stopped updating." % eval_report["written_at"]
    return "Snapshot written %s. It changes only when eval_report.md is rewritten." % eval_report["written_at"]


def _chart(points: list) -> str:
    if len(points) < 2:
        return ""
    width = 280
    height = 92
    xs = []
    ys = []
    for point in points:
        x = _number(point["step"])
        y = _number(point["loss"])
        if x is None or y is None:
            continue
        xs.append(x)
        ys.append(y)
    if len(xs) < 2:
        return ""
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)
    if max_x == min_x:
        max_x = min_x + 1
    if max_y == min_y:
        max_y = min_y + 1
    coords = []
    for x, y in zip(xs, ys):
        sx = 8 + (x - min_x) / (max_x - min_x) * (width - 16)
        sy = 8 + (max_y - y) / (max_y - min_y) * (height - 16)
        coords.append("%0.1f,%0.1f" % (sx, sy))
    return (
        '<svg class="chart" viewBox="0 0 %d %d" role="img" aria-label="Training loss from the log, %d steps">'
        '<polyline points="%s" fill="none" stroke="#0e6e6a" stroke-width="2"></polyline>'
        "</svg>"
    ) % (width, height, len(xs), " ".join(coords))


def _metrics_html(payload: dict) -> str:
    training = payload["training"]
    report = payload["eval"]
    parts = []
    train_absent = training.get("train_loss") is None
    train_body = _figure(training.get("train_loss"), train_absent)
    train_body += _chart(training.get("points") or [])
    if train_absent:
        train_body += _hint(training.get("note") or "no data yet")
    else:
        train_body += _hint("Latest training loss in out/training_log.csv. %d logged steps." % training.get("rows", 0))
        if training.get("stale"):
            train_body += _stale(
                "This log has stopped updating. Last change %s." % (training.get("written_at") or "")
            )
    parts.append(_window("Training loss", train_body, train_absent))

    val_absent = training.get("val_loss") is None
    val_body = _figure(training.get("val_loss"), val_absent)
    if val_absent:
        val_body += _hint("No validation loss has been logged. Training has not written one.")
    else:
        val_body += _hint("Latest validation loss in out/training_log.csv.")
        if training.get("stale"):
            val_body += _stale(
                "This log has stopped updating. Last change %s." % (training.get("written_at") or "")
            )
    parts.append(_window("Validation loss", val_body, val_absent))

    rate_absent = training.get("learning_rate") is None
    rate_body = _figure(training.get("learning_rate"), rate_absent)
    if rate_absent:
        rate_body += _hint("No learning rate has been logged. The schedule starts when training does.")
    else:
        rate_body += _hint("Latest learning rate in out/training_log.csv.")
    parts.append(_window("Learning rate", rate_body, rate_absent))

    ppl_absent = not report.get("perplexity")
    ppl_body = _figure(report.get("perplexity"), ppl_absent)
    if ppl_absent:
        ppl_body += _hint(report.get("note") or "no data yet")
    else:
        detail = "Base checkpoint"
        if payload.get("model"):
            detail += " " + payload["model"]
        detail += ". No adapter."
        if report.get("test_loss"):
            detail += " Test loss %s." % report["test_loss"]
        if report.get("songs") and report.get("windows"):
            detail += " %s songs, %s windows." % (report["songs"], report["windows"])
        ppl_body += _hint(detail)
        ppl_body += _stale(_eval_status(report))
    parts.append(_window("Perplexity", ppl_body, ppl_absent))

    rhyme_absent = not report.get("generated_rhyme") and not report.get("corpus_rhyme")
    if rhyme_absent:
        rhyme_body = _figure(None, True) + _hint(report.get("note") or "no data yet")
    else:
        rhyme_body = (
            '<div class="pair"><p class="figure">%s</p><p class="pair-label">Latest generated</p></div>'
            '<div class="pair"><p class="figure">%s</p><p class="pair-label">Catalog average</p></div>'
            % (escape(_shown(report.get("generated_rhyme"))), escape(_shown(report.get("corpus_rhyme"))))
        )
        rhyme_body += _hint(
            "Share of lines whose end word rhymes with one of the previous four. "
            "The generated figure is the base-model eval samples."
        )
        rhyme_body += _stale(_eval_status(report))
    parts.append(_window("Rhyme density", rhyme_body, rhyme_absent))

    rows = report.get("syllables") or []
    flow_absent = not report.get("generated_flow") and not rows
    if flow_absent:
        syl_body = _figure(None, True) + _hint(report.get("note") or "no data yet")
    else:
        syl_body = (
            '<div class="pair"><p class="figure">%s</p><p class="pair-label">Generated steadiness</p></div>'
            '<div class="pair"><p class="figure">%s</p><p class="pair-label">Catalog steadiness</p></div>'
            % (escape(_shown(report.get("generated_flow"))), escape(_shown(report.get("corpus_flow"))))
        )
        syl_body += _hint("Steadiness is 1 when every line in the sample has the same syllable count.")
        if rows:
            syl_body += _hint(
                "%d of %d samples average more than one syllable above the catalog median at that BPM."
                % (report.get("long_count") or 0, len(rows))
            )
            syl_body += '<ul class="samples">'
            for row in rows:
                syl_body += (
                    '<li><p class="who">%s · %s BPM</p>'
                    "<p>Generated syllables %s. Catalog median %s.</p>"
                    "<p>Steadiness %s. Catalog steadiness %s.</p></li>"
                    % (
                        escape(row["voice"]),
                        escape(row["bpm"]),
                        escape(row["mean_syllables"]),
                        escape(row["median"]),
                        escape(row["flow"]),
                        escape(row["corpus_flow"]),
                    )
                )
            syl_body += "</ul>"
            syl_body += _hint(
                "Each block is one base-model sample beside the catalog median at that BPM."
            )
        syl_body += _stale(_eval_status(report))
    parts.append(_window("Syllable consistency", syl_body, flow_absent))
    return "\n".join(parts)


def _control(label: str, control_id: str, control: str, hint: str) -> str:
    return (
        '<div class="control"><label for="%s">%s</label>%s%s</div>'
        % (escape(control_id), escape(label), control, _hint(hint))
    )


def _adjusters_html(payload: dict) -> str:
    voices = payload.get("voices") or list(PINNED_VOICES)
    options = ['<option value="">Choose a voice</option>']
    for name in voices:
        options.append('<option value="%s">%s</option>' % (escape(name), escape(name)))
    voice = (
        '<select id="voice" disabled>%s</select>' % "".join(options)
    )
    blocks = [
        _control(
            "Temperature",
            "temperature",
            '<input id="temperature" type="range" min="0.1" max="1.5" step="0.05" value="0.8" disabled>'
            '<span class="value">0.8</span>',
            "How wild the next bars are. 0.8 is the everyday default. Lower is steadier. Not connected yet.",
        ),
        _control(
            "Top-p",
            "top-p",
            '<input id="top-p" type="range" min="0.1" max="1" step="0.01" value="0.95" disabled>'
            '<span class="value">0.95</span>',
            "How many likely next words stay in the draw. 0.95 is the everyday default. Not connected yet.",
        ),
        _control(
            "Top-k",
            "top-k",
            '<input id="top-k" type="text" disabled>',
            "Would keep only the K most likely next words. The sampler does not use this yet, so the field stays off.",
        ),
        _control(
            "Repetition penalty",
            "repetition-penalty",
            '<input id="repetition-penalty" type="text" disabled>',
            "Would push the model away from repeating a phrase. The sampler does not use this yet, so the field stays off.",
        ),
        _control(
            "Voice",
            "voice",
            voice,
            "Whose writing the bars should lean toward. Gunna, Young Thug, and Young Stoner Life lead the list. Not connected yet.",
        ),
        _control(
            "Blend with a second voice",
            "blend-on",
            '<input id="blend-on" type="checkbox" disabled>',
            "Adds a second voice at generation time. Leave off until Generate is connected.",
        ),
        _control(
            "Second voice",
            "blend-voice",
            '<select id="blend-voice" disabled>%s</select>' % "".join(options),
            "The voice mixed into the first one. Not connected yet.",
        ),
        _control(
            "Mix",
            "mix",
            '<input id="mix" type="range" min="0" max="100" step="5" value="70" disabled>'
            '<span class="value">70</span>',
            "Share of the first voice. 70 means 70 percent first voice and 30 percent second voice. Not connected yet.",
        ),
        _control(
            "BPM",
            "bpm",
            '<input id="bpm" type="number" min="40" max="220" disabled>',
            "Sets how many syllables each bar aims for. 70 aims at 8. 140 aims at 14. Required once Generate is connected.",
        ),
        _control(
            "Scale",
            "scale",
            '<input id="scale" type="text" disabled>',
            "Written into the prompt only. It does not change the syllable count. Not connected yet.",
        ),
        _control(
            "Seed line",
            "seed-line",
            '<input id="seed-line" type="text" disabled>',
            "Becomes bar 1 and is not rewritten. Leave this blank if you use a topic instead. Not connected yet.",
        ),
        _control(
            "Topic",
            "topic",
            '<input id="topic" type="text" disabled>',
            "A subject for the bars. It stays in the prompt and is not a bar. Not connected yet.",
        ),
        _control(
            "Number of bars",
            "bars",
            '<input id="bars" type="number" min="1" max="32" value="8" disabled>',
            "How many lines to write. 8 is the everyday default. Not connected yet.",
        ),
        _control(
            "Preset name",
            "preset-name",
            '<input id="preset-name" type="text" disabled>',
            "A name you can reload later. Saving a preset is not connected yet.",
        ),
    ]
    actions = (
        '<div class="actions">'
        '<button id="generate" type="button" disabled>Generate</button>'
        '<button id="save-settings" type="button" disabled>Save settings</button>'
        "</div>"
        + _hint("Generate is not connected. The next step sends these settings to generate.py on this Mac.")
        + _hint("Save settings is not connected. Named presets save on the next step.")
    )
    return (
        '<p class="hint">These controls are here so the desk has its shape. '
        "Moving one does nothing in this step.</p>"
        + "".join(blocks)
        + actions
    )


def _score_bits(row: dict) -> str:
    labels = (
        ("rhyme", "Rhyme"),
        ("flow", "Flow"),
        ("voice_match", "Voice match"),
        ("originality", "Originality"),
        ("keep", "Keep"),
    )
    bits = []
    for key, label in labels:
        value = row.get(key) or ""
        bits.append("%s %s" % (label, value if value else "not scored"))
    return ". ".join(bits) + "."


def _editor_html(payload: dict) -> str:
    grades = payload["grades"]
    if grades.get("status") != "sheet" or not grades.get("rows"):
        history = _figure(None, True) + _hint(grades.get("note") or "No scored rows to show.")
    else:
        items = []
        for row in grades["rows"]:
            items.append(
                "<li><p class=\"who\">Batch %s · %s · %s BPM · temperature %s</p><p>%s</p></li>"
                % (
                    escape(row.get("batch") or ""),
                    escape(row.get("voice") or ""),
                    escape(row.get("bpm") or ""),
                    escape(row.get("temperature") or ""),
                    escape(_score_bits(row)),
                )
            )
        extra = ""
        if grades.get("blank_rows"):
            extra = _hint(
                "%d batches on that sheet have no scores." % grades["blank_rows"]
            )
        history = '<ol class="grades">%s</ol>%s' % ("".join(items), extra)
        history += _hint(
            "Read from %s. This page does not write that file." % (grades.get("name") or "the grade sheet")
        )
    listen = payload.get("listen_sheet")
    if listen == "blank":
        history += _hint("The sheet in out/listen/grading.csv is still blank. This page did not change it.")
    elif listen == "graded":
        history += _hint("The sheet in out/listen/grading.csv already has scores. This page did not change it.")
    else:
        history += _hint("No listen sheet was found at out/listen/grading.csv.")

    score = (
        '<label for="{0}">{1}</label>'
        '<select id="{0}" disabled><option selected>Not scored</option>'
        "<option>1</option><option>2</option><option>3</option><option>4</option><option>5</option>"
        "</select>"
    )
    scores = "".join(
        '<div class="control">%s%s</div>'
        % (
            score.format(field_id, label),
            _hint("1 is weak and 5 is strong. Not connected yet."),
        )
        for field_id, label in (
            ("score-rhyme", "Rhyme"),
            ("score-flow", "Flow"),
            ("score-voice", "Voice match"),
            ("score-originality", "Originality"),
        )
    )
    takes = (
        '<div class="takes">'
        '<article class="take"><h3>This take</h3>'
        '<p class="figure missing">No bars are loaded</p>'
        + _hint("Generate is not connected yet, so this pane stays empty.")
        + "</article>"
        '<article class="take"><h3>Earlier take</h3>'
        + _figure(None, True)
        + _hint("Side by side opens when a saved take can be reloaded.")
        + "</article></div>"
    )
    actions = (
        '<div class="actions">'
        '<button id="keep" type="button" disabled>Keep</button>'
        '<button id="discard" type="button" disabled>Discard</button>'
        "</div>"
        + _hint("Keep marks this take as one to hold. Saving to the grade sheet comes in a later step.")
        + _hint("Discard marks this take as one to drop. Saving comes in a later step.")
    )
    return (
        takes
        + actions
        + scores
        + _control(
            "Notes",
            "notes",
            '<textarea id="notes" rows="3" disabled></textarea>',
            "What you heard. Saving comes in a later step.",
        )
        + _control(
            "Correct a line",
            "line-edit",
            '<textarea id="line-edit" rows="2" disabled></textarea>',
            "Fix one line after you hear it. Saving comes in a later step.",
        )
        + "<h3>Scores you already wrote</h3>"
        + history
    )


def _header(payload: dict) -> str:
    model = payload.get("model") or "no data yet"
    adapter = payload["adapter"]["note"]
    report = payload["eval"]
    ppl = report.get("perplexity")
    if ppl:
        ppl_line = "Last eval perplexity is %s on the base checkpoint." % ppl
    else:
        ppl_line = "Perplexity has no data yet."
    return (
        "<header class=\"mast\">"
        "<p class=\"kicker\">Penwork lyric desk</p>"
        "<h1>Nothing has been trained.</h1>"
        "<p class=\"lede\">Tuning starts when the smoke test runs and the loss falls. "
        "Prompt 13 changes how a trained model samples. This checkpoint has never been trained, "
        "so those settings still write essays.</p>"
        "<p class=\"lede\">%s %s</p>" % (escape(ppl_line), escape(adapter))
        + "<p class=\"hint\">Model in the training config: %s. " % escape(model)
        + "An API key can write bars from a short prompt. It does not learn this catalog unless the lyrics leave this Mac. "
        "This page reads local files. It does not upload the catalog or the weights.</p>"
        "<p class=\"hint\" id=\"refresh-note\">Read from disk at %s. The page checks the files again every 15 seconds.</p>"
        % escape(payload.get("read_at") or "")
        + "</header>"
    )


PAGE_STYLE = """
:root {
  --booth: #d5dde6;
  --card: #f4f7fa;
  --ink: #1b2430;
  --mute: #3d4c5c;
  --live: #0e6e6a;
  --missing: #9a3e2f;
  --rule: #b7c3d0;
  --recess: #e7edf3;
  --display: "Didot", "Bodoni 72", "Bodoni 72 Oldstyle", "Hoefler Text", serif;
  --body: "Gill Sans", "Gill Sans MT", "Trebuchet MS", sans-serif;
  --mono: "SF Mono", ui-monospace, Menlo, monospace;
}
* { box-sizing: border-box; }
body {
  margin: 0;
  background: var(--booth);
  color: var(--ink);
  font-family: var(--body);
  font-size: 16px;
  line-height: 1.4;
}
.wrap { max-width: 1280px; margin: 0 auto; padding: 28px 22px 48px; }
.kicker { margin: 0 0 6px; font-size: 15px; color: var(--live); }
h1 {
  margin: 0 0 10px;
  font-family: var(--display);
  font-weight: 400;
  font-style: italic;
  font-size: 46px;
  line-height: 1.05;
  letter-spacing: -0.02em;
}
h2 { margin: 0 0 12px; font-size: 22px; font-weight: 600; }
h3 { margin: 0; font-size: 15px; font-weight: 600; }
.lede { margin: 0 0 8px; max-width: 68rem; }
.hint, .stale, .pair-label, caption {
  font-size: 13px;
  line-height: 1.35;
  letter-spacing: 0;
  text-transform: none;
}
.hint { color: var(--mute); margin: 4px 0 12px; }
.stale { color: var(--missing); margin: 4px 0 0; }
.desk {
  display: grid;
  grid-template-columns: minmax(220px, 0.9fr) minmax(250px, 1fr) minmax(360px, 1.6fr);
  gap: 16px;
  align-items: start;
  margin-top: 18px;
}
.panel {
  background: var(--card);
  border-radius: 18px;
  padding: 16px;
  min-width: 0;
}
.window {
  background: var(--recess);
  border-radius: 14px 14px 8px 8px;
  padding: 12px 12px 14px;
  margin: 0 0 12px;
  position: relative;
  overflow: hidden;
  box-shadow: inset 0 0 0 1px var(--rule);
}
.window::before, .take::before {
  content: "";
  display: block;
  height: 5px;
  margin: -12px -12px 10px;
  border-radius: 14px 14px 0 0;
  background: var(--live);
}
.window.absent::before, .take::before {
  background: repeating-linear-gradient(90deg, var(--missing) 0 12px, transparent 12px 18px);
}
.figure {
  font-family: var(--display);
  font-size: 40px;
  line-height: 1;
  margin: 8px 0;
}
.figure.missing {
  font-family: var(--body);
  font-size: 22px;
  font-weight: 600;
  color: var(--missing);
}
.pair { display: inline-block; margin: 6px 18px 0 0; vertical-align: top; }
.pair .figure { font-size: 34px; }
.pair-label { margin: 0; color: var(--mute); }
.chart { width: 100%; height: auto; display: block; margin-top: 6px; }
.samples { list-style: none; margin: 8px 0 0; padding: 0; }
.samples li { margin: 0 0 8px; padding-bottom: 8px; border-bottom: 1px solid var(--rule); }
.samples p { margin: 0; font-size: 14px; line-height: 1.35; }
label { display: block; font-weight: 600; margin-bottom: 4px; }
input, select, textarea {
  width: 100%;
  font: inherit;
  color: var(--ink);
  background: white;
  border: 1px solid var(--rule);
  border-radius: 8px;
  padding: 7px 8px;
}
input[type="range"] { padding: 0; }
input[type="checkbox"] { width: auto; }
.value {
  font-family: var(--mono);
  font-size: 13px;
  margin-left: 8px;
}
.actions { display: flex; gap: 8px; flex-wrap: wrap; margin: 4px 0; }
button {
  font: inherit;
  background: var(--ink);
  color: var(--card);
  border: 0;
  border-radius: 999px;
  padding: 8px 14px;
}
button:disabled { background: #d5dde6; color: #1b2430; }
textarea { resize: vertical; }
.takes { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.take {
  background: var(--recess);
  border-radius: 14px;
  padding: 12px;
  box-shadow: inset 0 0 0 1px var(--rule);
}
.who { margin: 0 0 2px; font-weight: 600; }
.grades { margin: 0; padding-left: 18px; }
.grades li { margin: 0 0 10px; }
:focus-visible { outline: 2px solid var(--live); outline-offset: 2px; }
@media (max-width: 980px) {
  .desk, .takes { grid-template-columns: 1fr; }
  h1 { font-size: 36px; }
}
@media (prefers-reduced-motion: reduce) {
  * { scroll-behavior: auto; }
}
"""

PAGE_SCRIPT = """
<script>
const stamp = document.body.getAttribute("data-signature");
async function watchDesk() {
  const note = document.getElementById("refresh-note");
  try {
    const response = await fetch("/metrics.json", { cache: "no-store" });
    if (!response.ok) throw new Error("status " + response.status);
    const data = await response.json();
    if (data.signature && data.signature !== stamp) {
      location.reload();
      return;
    }
    if (note) note.textContent = "Read from disk at " + (data.read_at || "") + ". The page checks the files again every 15 seconds.";
  } catch (error) {
    if (note) note.textContent = "The desk could not re-read the files. Leave this page open and start desk.py again if the address stopped answering.";
  }
}
setInterval(watchDesk, 15000);
</script>
"""


def render_page(payload: dict) -> str:
    return """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Lyric desk</title>
<style>
%s
</style>
</head>
<body data-signature="%s">
<div class="wrap">
%s
<main class="desk">
<section class="panel" id="metrics" aria-labelledby="metrics-title">
<h2 id="metrics-title">Metrics</h2>
%s
</section>
<section class="panel" id="adjusters" aria-labelledby="adjusters-title">
<h2 id="adjusters-title">Adjusters</h2>
%s
</section>
<section class="panel" id="editor" aria-labelledby="editor-title">
<h2 id="editor-title">Editor</h2>
%s
</section>
</main>
</div>
%s
</body>
</html>
""" % (
        PAGE_STYLE,
        escape(payload.get("signature") or ""),
        _header(payload),
        _metrics_html(payload),
        _adjusters_html(payload),
        _editor_html(payload),
        PAGE_SCRIPT,
    )


def metrics_json(payload: dict) -> bytes:
    return json.dumps(payload, ensure_ascii=True).encode("utf-8")


def _pid_alive(pid_path: Path) -> dict:
    if not pid_path.is_file():
        return {"running": False, "pid": None}
    try:
        pid = int(pid_path.read_text(encoding="utf-8").strip())
        import os
        os.kill(pid, 0)
        return {"running": True, "pid": pid}
    except Exception:
        return {"running": False, "pid": None}


def _read_json_safe(path: Path, default=None):
    if not path.is_file():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except Exception:
        return default


_CHECKPOINT_POINTS_CACHE = None
_CHECKPOINT_CACHE_MTIME = 0


def _get_checkpoint_points(adapters_dir: Path) -> list:
    global _CHECKPOINT_POINTS_CACHE, _CHECKPOINT_CACHE_MTIME
    if not adapters_dir.is_dir():
        return []
    try:
        st_mtime = adapters_dir.stat().st_mtime
    except Exception:
        return []
    if _CHECKPOINT_POINTS_CACHE is not None and st_mtime == _CHECKPOINT_CACHE_MTIME:
        return _CHECKPOINT_POINTS_CACHE
    pts = []
    try:
        for p in adapters_dir.glob("*_adapters.safetensors"):
            m = re.match(r"^(\d+)_adapters\.safetensors$", p.name)
            if m:
                step = int(m.group(1))
                pts.append((step, p.stat().st_mtime))
    except Exception:
        pass
    pts.sort()
    _CHECKPOINT_POINTS_CACHE = pts
    _CHECKPOINT_CACHE_MTIME = st_mtime
    return pts


def _step_to_time(step: int, pts: list) -> float:
    if not pts:
        return 0.0
    if step <= pts[0][0]:
        if len(pts) > 1 and pts[1][0] > pts[0][0]:
            slope = (pts[1][1] - pts[0][1]) / (pts[1][0] - pts[0][0])
            return pts[0][1] - (pts[0][0] - step) * slope
        return pts[0][1]
    if step >= pts[-1][0]:
        if len(pts) > 1 and pts[-1][0] > pts[-2][0]:
            slope = (pts[-1][1] - pts[-2][1]) / (pts[-1][0] - pts[-2][0])
            return pts[-1][1] + (step - pts[-1][0]) * slope
        return pts[-1][1]
    for i in range(len(pts) - 1):
        s0, t0 = pts[i]
        s1, t1 = pts[i + 1]
        if s0 <= step <= s1:
            frac = (step - s0) / (s1 - s0)
            return t0 + frac * (t1 - t0)
    return pts[-1][1]


def _detailed_training_log(path: Path) -> list:
    if not path.is_file():
        return []
    adapters_dir = path.parent.parent / "adapters"
    pts = _get_checkpoint_points(adapters_dir)
    out = []
    try:
        with path.open(newline="", encoding="utf-8", errors="replace") as handle:
            raw_rows = list(csv.DictReader(handle))
        total_len = len(raw_rows)
        stride = max(1, total_len // 600)
        for i, row in enumerate(raw_rows):
            is_val = bool(row.get("val_loss"))
            is_edge = (i == 0 or i == total_len - 1)
            if not (is_val or is_edge or (i % stride == 0)):
                continue
            step = int(float(row["step"])) if _number(row.get("step")) is not None else 0
            epoch_t = _step_to_time(step, pts)
            time_str = datetime.fromtimestamp(epoch_t, ZoneInfo("America/New_York")).strftime("%b %-d, %-I:%M %p") if epoch_t else ""
            out.append({
                "step": step,
                "train_loss": _number(row.get("train_loss")),
                "val_loss": _number(row.get("val_loss")),
                "learning_rate": _number(row.get("learning_rate")),
                "tokens_per_second": _number(row.get("tokens_per_second")),
                "peak_memory_gb": _number(row.get("peak_memory_gb")),
                "timestamp": round(epoch_t, 2) if epoch_t else None,
                "time_str": time_str,
                "bars_mastered": step * 4,
            })
    except Exception:
        pass
    return out


def _training_log_span(path: Path) -> dict:
    """Hourly clock labels and timeline ticks for the loss and progress graph."""
    empty = {"started_at": None, "updated_at": None, "timeline_ticks": []}
    if not path.is_file():
        return empty
    adapters_dir = path.parent.parent / "adapters"
    pts = _get_checkpoint_points(adapters_dir)
    st = path.stat()
    born = getattr(st, "st_birthtime", None) or st.st_ctime

    timeline_ticks = []
    if pts:
        max_step = pts[-1][0]
        target_steps = [1, 5000, 10000, 15000, 20000, 25000, max_step]
        for s in target_steps:
            if s > max_step:
                continue
            epoch_t = _step_to_time(s, pts)
            dt = datetime.fromtimestamp(epoch_t, ZoneInfo("America/New_York"))
            timeline_ticks.append({
                "step": s,
                "short": dt.strftime("%m/%d %-I%p"),
                "full": dt.strftime("%b %-d, %-I:%M %p"),
                "time": round(epoch_t, 2),
            })
        first_epoch = _step_to_time(1, pts)
        last_epoch = pts[-1][1]
        started_str = datetime.fromtimestamp(first_epoch, ZoneInfo("America/New_York")).strftime("%b %-d, %-I:%M %p ET")
        updated_str = datetime.fromtimestamp(last_epoch, ZoneInfo("America/New_York")).strftime("%b %-d, %-I:%M %p ET")
    else:
        started_str = _stamp_et(born)
        updated_str = _stamp_et(st.st_mtime)

    return {
        "started_at": started_str,
        "updated_at": updated_str,
        "timeline_ticks": timeline_ticks,
    }


def _adapter_details(root: Path) -> dict:
    result = {}
    for key, folder in (("smoke", "adapters_smoke"), ("full", "adapters")):
        d = root / folder
        w = d / "adapters.safetensors"
        state = _read_json_safe(d / "resume_state.json", {}) or {}
        result[key] = {
            "present": w.is_file(),
            "size_mb": round(w.stat().st_size / (1024 * 1024), 2) if w.is_file() else 0,
            "updated_at": _stamp(w.stat().st_mtime) if w.is_file() else None,
            "step": state.get("step", 0),
            "iters_total": state.get("iters_total", 0),
            "completed": bool(state.get("completed", False)),
            "train_loss": state.get("train_loss"),
            "val_loss": state.get("val_loss"),
            "mode": state.get("mode", key),
            "path": str(d),
        }
    return result


def _voice_inventory(root: Path) -> dict:
    raw = _read_json_safe(root / "out" / "voice_counts.json", {}) or {}
    items = []
    reliable_count = 0
    for token, info in raw.items():
        if not isinstance(info, dict):
            continue
        rel = bool(info.get("reliable", False))
        if rel:
            reliable_count += 1
        items.append({
            "token": token,
            "artist": info.get("artist") or token,
            "train_lines": int(info.get("train_lines") or 0),
            "train_windows": int(info.get("train_windows") or 0),
            "val_lines": int(info.get("val_lines") or 0),
            "test_lines": int(info.get("test_lines") or 0),
            "reliable": rel,
            "flag": info.get("flag") or "",
        })
    items.sort(key=lambda x: (-x["train_lines"], x["artist"].lower()))
    return {
        "total": len(items),
        "reliable": reliable_count,
        "thin": max(0, len(items) - reliable_count),
        "items": items,
    }


def _recent_takes(root: Path, limit: int = 12) -> list:
    bars_dir = root / "out" / "bars"
    if not bars_dir.is_dir():
        return []
    try:
        from lyriclib import estimate_syllables
    except Exception:
        estimate_syllables = lambda s: len(s.split())
    files = sorted(bars_dir.glob("*.txt"), key=lambda p: p.stat().st_mtime, reverse=True)[:limit]
    takes = []
    for f in files:
        text = f.read_text(encoding="utf-8", errors="replace").strip()
        lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
        syls = [estimate_syllables(ln) for ln in lines]
        takes.append({
            "filename": f.name,
            "created_at": _stamp(f.stat().st_mtime),
            "lines": [
                {"index": idx + 1, "text": ln, "syllables": syls[idx]}
                for idx, ln in enumerate(lines)
            ],
            "mean_syllables": round(sum(syls) / len(syls), 1) if syls else 0,
            "raw": text,
        })
    return takes


def _telemetry_summary(root: Path) -> dict:
    try:
        import telemetry
        return telemetry.get_telemetry_stats()
    except Exception:
        return {}


def collect_studio_state(root: Path, grades_path: Path = None) -> dict:
    base_metrics = collect_metrics(root, grades_path=grades_path)
    voice_inv = _voice_inventory(root)
    syllable_curve = _read_json_safe(root / "out" / "syllable_curve.json", {}) or {}
    decisions = _read_json_safe(root / "out" / "phase_decisions.json", {}) or {}
    clean_audit = _read_json_safe(root / "out" / "clean_audit.json", {}) or {}
    proc = _pid_alive(root / "out" / "train.pid")
    tr_audit = clean_audit.get("train.jsonl", {})
    va_audit = clean_audit.get("val.jsonl", {})
    te_audit = clean_audit.get("test.jsonl", {})
    train_songs = int(tr_audit.get("songs_out", 38633))
    val_songs = int(va_audit.get("songs_out", 1180))
    test_songs = int(te_audit.get("songs_out", 779))
    train_lines = int(tr_audit.get("lines_kept", 1611690))
    val_lines = int(va_audit.get("lines_kept", 48207))
    test_lines = int(te_audit.get("lines_kept", 31567))
    total_windows = sum(x["train_windows"] for x in voice_inv.get("items", [])) or 202382
    return {
        "metrics": base_metrics,
        "process": proc,
        "adapters": _adapter_details(root),
        "training_series": _detailed_training_log(root / "out" / "training_log.csv"),
        "training_log_span": _training_log_span(root / "out" / "training_log.csv"),
        "voice_inventory": voice_inv,
        "syllable_curve": syllable_curve,
        "recent_takes": _recent_takes(root),
        "v4_telemetry": _telemetry_summary(root),
        "decisions": decisions,
        "corpus_summary": {
            "source_rows": 1793548,
            "kept_lines": train_lines + val_lines + test_lines,
            "kept_songs": train_songs + val_songs + test_songs,
            "train_songs": train_songs,
            "train_lines": train_lines,
            "val_songs": val_songs,
            "val_lines": val_lines,
            "test_songs": test_songs,
            "test_lines": test_lines,
            "train_windows": total_windows,
            "bpm_coverage_pct": 48.4,
            "scale_coverage_pct": 43.7,
            "html_artifact_songs": 0 if clean_audit else 53,
            "scrape_lines_removed": int(tr_audit.get("scrape_lines_removed", 924)),
            "scrambled_songs_dropped": (
                int(tr_audit.get("scrambled_songs_dropped", 176))
                + int(va_audit.get("scrambled_songs_dropped", 1))
                + int(te_audit.get("scrambled_songs_dropped", 2))
            ),
        },
    }


_DESK_CMU = None
_DESK_DNA = None


def _get_desk_cmu(root: Path):
    global _DESK_CMU
    if _DESK_CMU is not None:
        return _DESK_CMU
    try:
        from lyriclib import load_cmudict
        cmu_path = root.parent.parent / "XJournal AI" / "cmudict.txt"
        if cmu_path.is_file():
            _DESK_CMU = load_cmudict(cmu_path)
        else:
            _DESK_CMU = {}
    except Exception:
        _DESK_CMU = {}
    return _DESK_CMU


def _get_desk_dna(root: Path) -> dict:
    global _DESK_DNA
    if _DESK_DNA is not None:
        return _DESK_DNA
    dna_path = root / "out" / "artist_voice_dna.json"
    if dna_path.is_file():
        try:
            _DESK_DNA = json.loads(dna_path.read_text(encoding="utf-8"))
        except Exception:
            _DESK_DNA = {}
    else:
        _DESK_DNA = {}
    return _DESK_DNA


def run_live_generation(root: Path, params: dict) -> dict:
    import subprocess
    from lyriclib import end_rime, estimate_syllables, normalize, tempo_line_syllables, tokenize

    py_bin = root / ".venv" / "bin" / "python"
    if not py_bin.is_file():
        py_bin = Path(sys.executable)

    voice = str(params.get("voice") or "Drake").strip()
    blend = str(params.get("blend") or "").strip()
    mix = str(params.get("mix") or "70").strip()
    section_mode = str(params.get("section_mode") or "auto").strip().lower()
    raw_bpm = float(params.get("bpm") or 140)
    if section_mode == "hook":
        # Hook mode steers cadence to catchy 8-10 syllable bars
        bpm = float(params.get("bpm") or 85)
        effective_bpm = min(raw_bpm, 90.0) if raw_bpm > 100 else raw_bpm
        temperature = float(params.get("temperature") or 0.72)
    elif section_mode == "verse":
        # Verse mode steers cadence to dense 12-14 syllable bars
        bpm = float(params.get("bpm") or 140)
        effective_bpm = raw_bpm
        temperature = float(params.get("temperature") or 0.78)
    else:
        bpm = raw_bpm
        effective_bpm = raw_bpm
        temperature = float(params.get("temperature") or 0.8)

    scale = str(params.get("scale") or "F minor").strip()
    if not scale or scale.lower() in ("auto", "none", "optional"):
        scale = "F minor"
    seed_line = str(params.get("seed_line") or "").strip()
    scratchpad_bars = str(params.get("scratchpad") or params.get("scratchpad_bars") or "").strip()
    chosen_albums_val = params.get("chosen_albums") or params.get("albums")
    if isinstance(chosen_albums_val, str) and chosen_albums_val:
        chosen_albums_val = [k.strip() for k in chosen_albums_val.split(",") if k.strip()]
    topic = str(params.get("topic") or "").strip()
    bars = int(params.get("bars") or 8)
    top_p = float(params.get("top_p") or 0.95)
    seed = params.get("seed")
    adapter_choice = str(params.get("adapter") or "frontier_v2").strip()
    target_syl = int(params.get("target_syl") or 15)

    # DEFAULT TO FRONTIER GHOSTWRITER V2/V3/V4 UNLESS LOCAL MLX EXPLICITLY REQUESTED
    if adapter_choice not in ("local", "local_mlx", "adapters_gold", "smoke"):
        taste_param = params.get("taste")
        taste_on_val = True if taste_param is None or str(taste_param).lower() in ("1", "true", "on") else False
        taste_k_val = int(params.get("taste_k") or 6)

        # FRONTIER V4 TWO-PASS RETRIEVE & REMIX (REASONING PLANNER + FAST DRAFT + FRONTIER POLISH)
        if adapter_choice in ("v4", "frontier_v4"):
            import frontier_v4
            candidates_val = int(params.get("candidates") or 1)
            res = frontier_v4.generate_v4(
                voice=voice,
                blend=blend,
                mix=int(mix),
                bpm=effective_bpm,
                scale=scale,
                target_syl=target_syl,
                section_mode=section_mode,
                rhyme_technique=str(params.get("rhyme_technique") or "balanced"),
                bars_count=bars,
                seed_line=seed_line,
                topic_hint=topic,
                scratchpad_bars=scratchpad_bars,
                chosen_albums=chosen_albums_val,
                remix_ratio=int(params.get("remix_ratio") or 25),
                taste_on=taste_on_val,
                taste_k=taste_k_val,
                candidates=candidates_val,
            )
            return res

        import polish
        adhd_chain_val = params.get("adhd_chain")
        if isinstance(adhd_chain_val, str) and adhd_chain_val:
            adhd_chain_val = [k.strip() for k in adhd_chain_val.split(",") if k.strip()]
        if ":" in voice:
            v_parts = voice.split(":", 1)
            voice = v_parts[0]
            if not adhd_chain_val or adhd_chain_val in ("auto", ["auto"], "adhd_trap", ["adhd_trap"]):
                adhd_chain_val = [v_parts[1]]
        remix_ratio_val = int(params.get("remix_ratio") or 25)
        res = polish.generate_frontier_bars_v2(
            voice=voice,
            blend=blend,
            mix=int(mix),
            bpm=effective_bpm,
            scale=scale,
            target_syl=target_syl,
            section_mode=section_mode,
            rhyme_technique=str(params.get("rhyme_technique") or "balanced"),
            adhd_chain=adhd_chain_val,
            bars_count=bars,
            seed_line=seed_line,
            topic_hint=topic,
            scratchpad_bars=scratchpad_bars,
            chosen_albums=chosen_albums_val,
            remix_ratio=remix_ratio_val,
            taste_on=taste_on_val,
            taste_k=taste_k_val,
        )
        return res

    if adapter_choice == "gold":
        adapter_dir = root / "adapters_gold"
    elif adapter_choice == "smoke":
        adapter_dir = root / "adapters_smoke"
    elif adapter_choice == "full":
        # If gold adapter exists with trained weights, prefer it for pristine quality
        if (root / "adapters_gold").exists() and any((root / "adapters_gold").glob("*.safetensors")):
            adapter_dir = root / "adapters_gold"
        else:
            adapter_dir = root / "adapters"
    else:
        adapter_dir = root / "adapters_none"

    cmd = [
        str(py_bin),
        str(root / "generate.py"),
        "--voice", voice,
        "--bpm", str(effective_bpm),
        "--scale", scale,
        "--bars", str(bars),
        "--temperature", str(temperature),
        "--top-p", str(top_p),
        "--adapter", str(adapter_dir),
    ]
    if blend:
        cmd.extend(["--blend", blend, "--mix", mix])
    if seed_line:
        cmd.extend(["--seed-line", seed_line])
    if topic:
        cmd.extend(["--topic", topic])
    if seed is not None and str(seed).strip() != "":
        cmd.extend(["--seed", str(int(seed))])

    t0 = time.time()
    proc = subprocess.run(
        cmd,
        cwd=str(root),
        capture_output=True,
        text=True,
        timeout=180,
    )
    elapsed = round(time.time() - t0, 2)
    stdout = (proc.stdout or "").strip()
    stderr = (proc.stderr or "").strip()
    if proc.returncode != 0 and not stdout:
        return {
            "ok": False,
            "error": stderr or "Generation failed",
            "stderr": stderr,
            "elapsed_sec": elapsed,
        }
    lines = [ln.strip() for ln in stdout.splitlines() if ln.strip()]
    target_syl = tempo_line_syllables(effective_bpm)
    cmu = _get_desk_cmu(root)
    dna_all = _get_desk_dna(root)
    artist_dna = (dna_all.get("artists") or {}).get(voice) or (dna_all.get("artists") or {}).get("Gunna") or {}
    double_lex = dna_all.get("double_meaning_lexicon") or {}
    artist_end_set = {e.get("word") for e in (artist_dna.get("top_end_words") or []) if e.get("word")}
    artist_phrases = [p.get("phrase") for p in (artist_dna.get("signature_phrases") or []) if p.get("phrase")]

    bar_rows = []
    for idx, ln in enumerate(lines):
        syl = estimate_syllables(ln)
        norm_ln = normalize(ln)
        toks = tokenize(norm_ln)
        end_w = toks[-1] if toks else ""
        rime = end_rime(end_w, cmu) if (end_w and cmu) else None
        rime_str = "-".join(rime) if rime else ""
        stress_words = []
        if cmu and toks:
            for t in toks:
                if len(t) > 2 and any(p.endswith("1") for p in cmu.get(t, ())):
                    if t not in stress_words:
                        stress_words.append(t)
        phrase_hits = [ph for ph in artist_phrases if ph in norm_ln]
        double_hits = []
        seen_dw = set()
        for t in toks:
            if t in double_lex and t not in seen_dw:
                seen_dw.add(t)
                double_hits.append({
                    "word": t,
                    "senses": double_lex[t].get("senses") or [],
                })
        bar_rows.append({
            "index": idx + 1,
            "text": ln,
            "syllables": syl,
            "target_syllables": target_syl,
            "delta": syl - target_syl,
            "end_word": end_w,
            "rhyme_family": rime_str,
            "artist_rhyme_hit": end_w in artist_end_set,
            "artist_phrases_hit": phrase_hits[:2],
            "double_meanings": double_hits[:3],
            "stress_words": stress_words[-3:],
        })
    return {
        "ok": True,
        "voice": voice,
        "blend": blend,
        "mix": mix if blend else None,
        "section_mode": section_mode,
        "bpm": bpm,
        "effective_bpm": effective_bpm,
        "scale": scale,
        "target_syllables": target_syl,
        "adapter_used": adapter_choice,
        "voice_dna_summary": {
            "top_end_rhymes": [e.get("word") for e in (artist_dna.get("top_end_words") or [])[:12]],
            "signature_phrases": artist_phrases[:8],
            "double_meaning_mix": (artist_dna.get("double_meaning_words") or [])[:10],
        },
        "elapsed_sec": elapsed,
        "bars": bar_rows,
        "raw": stdout,
        "stderr": stderr,
    }


def control_training(root: Path, params: dict) -> dict:
    import signal
    import subprocess

    action = str(params.get("action") or "").strip()
    proc_info = _pid_alive(root / "out" / "train.pid")
    py_bin = root / ".venv" / "bin" / "python"
    if not py_bin.is_file():
        py_bin = Path(sys.executable)

    if action == "stop":
        if not proc_info["running"] or not proc_info["pid"]:
            return {"ok": False, "message": "No active training process is running."}
        try:
            import os
            os.kill(proc_info["pid"], signal.SIGINT)
            return {"ok": True, "message": f"Sent safe stop (SIGINT) to PID {proc_info['pid']}. Finishing current step and saving checkpoint."}
        except Exception as exc:
            return {"ok": False, "message": str(exc)}

    if proc_info["running"]:
        return {"ok": False, "message": f"Training is already running (PID {proc_info['pid']}). Stop it first."}

    cmd = [str(py_bin), str(root / "train.py")]
    if action == "smoke":
        cmd.extend(["--smoke", "--epochs", "1", "--fresh"])
    elif action == "pilot":
        cmd.extend(["--pilot", "--epochs", "1", "--fresh"])
    elif action == "full":
        cmd.extend(["--epochs", "1", "--fresh"])
    elif action == "resume":
        cmd.extend(["--resume"])
        if params.get("mode") == "smoke":
            cmd.append("--smoke")
        elif params.get("mode") == "pilot":
            cmd.append("--pilot")
    else:
        return {"ok": False, "message": f"Unknown training action: {action}"}

    log_path = root / "train_live.log"
    with log_path.open("a", encoding="utf-8") as log_file:
        p = subprocess.Popen(
            cmd,
            cwd=str(root),
            stdout=log_file,
            stderr=subprocess.STDOUT,
            start_new_session=True,
        )
    return {
        "ok": True,
        "pid": p.pid,
        "command": " ".join(cmd),
        "message": f"Started {action} training run (PID {p.pid}). Live metrics will stream into the chart.",
    }


def make_handler(root: Path, grades_path: Path):
    dashboard_html_path = root.parent.parent / "dashboard" / "index.html"

    class DeskHandler(BaseHTTPRequestHandler):
        def do_OPTIONS(self):
            self.send_response(204)
            self._cors()
            self.end_headers()

        def do_GET(self):
            parsed = urlparse(self.path)
            path = parsed.path
            if path in ("/", "/index.html", "/studio"):
                if dashboard_html_path.is_file():
                    body = dashboard_html_path.read_bytes()
                    self._send(200, "text/html; charset=utf-8", body)
                    return
                payload = collect_metrics(root, grades_path=grades_path)
                body = render_page(payload).encode("utf-8")
                self._send(200, "text/html; charset=utf-8", body)
                return
            if path == "/health":
                body = json.dumps({"status": "ok", "service": "penwork-lyric-llm-bridge", "port": PORT}).encode("utf-8")
                self._send(200, "application/json; charset=utf-8", body)
                return
            if path == "/classic":
                payload = collect_metrics(root, grades_path=grades_path)
                body = render_page(payload).encode("utf-8")
                self._send(200, "text/html; charset=utf-8", body)
                return
            if path == "/metrics.json":
                payload = collect_metrics(root, grades_path=grades_path)
                self._send(200, "application/json; charset=utf-8", metrics_json(payload))
                return
            if path == "/api/state":
                state = collect_studio_state(root, grades_path=grades_path)
                body = json.dumps(state, ensure_ascii=True).encode("utf-8")
                self._send(200, "application/json; charset=utf-8", body)
                return
            if path == "/api/bag_metrics":
                from urllib.parse import parse_qs
                import polish
                qs = parse_qs(parsed.query)
                v = (qs.get("voice") or ["Gunna"])[0]
                s = (qs.get("scale") or ["F minor"])[0]
                b = float((qs.get("bpm") or ["130"])[0])
                metrics = polish.get_artist_bag_metrics(voice=v, scale=s, bpm=b)
                self._send(200, "application/json; charset=utf-8", json.dumps(metrics).encode("utf-8"))
                return
            if path == "/api/telemetry":
                import telemetry
                stats = telemetry.get_telemetry_stats()
                recent = telemetry.read_telemetry(limit=32)
                body = json.dumps({"ok": True, "stats": stats, "recent": recent}).encode("utf-8")
                self._send(200, "application/json; charset=utf-8", body)
                return
            if path == "/api/artist_albums":
                from urllib.parse import parse_qs
                import sqlite3
                from catalog_retriever import DB_PATH, DEFAULT_CHOSEN_ALBUMS
                qs = parse_qs(parsed.query)
                v = (qs.get("voice") or ["Gunna"])[0].strip()
                if ":" in v:
                    v = v.split(":", 1)[0]
                defaults = DEFAULT_CHOSEN_ALBUMS.get(v, [])
                albums = list(defaults)
                if DB_PATH.exists():
                    try:
                        conn = sqlite3.connect(str(DB_PATH))
                        cur = conn.cursor()
                        cur.execute("SELECT DISTINCT album FROM catalog_bars WHERE artist = ? AND album IS NOT NULL AND album != 'Catalog' ORDER BY popularity_score DESC LIMIT 15;", (v,))
                        db_albums = [r[0] for r in cur.fetchall() if r[0]]
                        for alb in db_albums:
                            if alb not in albums:
                                albums.append(alb)
                        conn.close()
                    except Exception:
                        pass
                resp = {
                    "ok": True,
                    "voice": v,
                    "default_chosen": defaults[:3],
                    "all_albums": albums[:12],
                }
                self._send(200, "application/json; charset=utf-8", json.dumps(resp).encode("utf-8"))
                return
            if path == "/skeleton":
                return self._handle_skeleton(parsed)
            self._send(404, "text/plain; charset=utf-8", b"not found\n")

        def _handle_skeleton(self, parsed, raw=b""):
            # Flow Skeleton endpoint for Penwork Studios iOS app (FlowSkeletonService.swift) & V3 Stem Alignment
            from urllib.parse import parse_qs
            import v3_audio_aligner
            qs = parse_qs(parsed.query)
            try:
                post_json = json.loads(raw.decode("utf-8")) if raw else {}
            except Exception:
                post_json = {}
            bpm_val = int(float(post_json.get("bpm") or (qs.get("bpm") or ["120"])[0]))
            num_bars = int(float(post_json.get("bars") or (qs.get("bars") or ["8"])[0]))
            target_syl = int(float(post_json.get("syl") or (qs.get("syl") or ["16"])[0])) if ("syl" in post_json or "syl" in qs) else 16
            b1 = target_syl // 4
            rem = target_syl - (b1 * 4)
            per_beat = [b1 + (1 if i < rem else 0) for i in range(4)]
            metrics = v3_audio_aligner.compute_tempo_metrics(bpm_val)
            per_bar = [
                {
                    "bar": i + 1,
                    "count": target_syl,
                    "conf": 0.95,
                    "perBeat": per_beat,
                    "startMs": round(i * metrics["bar_duration_ms"], 2),
                    "endMs": round((i + 1) * metrics["bar_duration_ms"], 2),
                }
                for i in range(num_bars)
            ]
            resp_payload = {
                "ok": True,
                "bpm": bpm_val,
                "barDurationMs": metrics["bar_duration_ms"],
                "beatDurationMs": metrics["beat_duration_ms"],
                "perBar": per_bar,
            }
            self._send(200, "application/json; charset=utf-8", json.dumps(resp_payload).encode("utf-8"))
            return

        def do_POST(self):
            parsed = urlparse(self.path)
            path = parsed.path
            length = int(self.headers.get("Content-Length") or 0)
            raw = self.rfile.read(length) if length > 0 else b"{}"

            if path == "/skeleton":
                return self._handle_skeleton(parsed, raw)

            try:
                params = json.loads(raw.decode("utf-8"))
            except Exception:
                params = {}

            if path in ("/api/generate", "/api/penwork/generate"):
                try:
                    result = run_live_generation(root, params)
                    status = 200 if result.get("ok") else 400
                except Exception as exc:
                    result = {"ok": False, "error": str(exc)}
                    status = 500
                self._send(status, "application/json; charset=utf-8", json.dumps(result).encode("utf-8"))
                return

            if path in ("/api/polish", "/api/penwork/polish"):
                import polish
                try:
                    raw_bars = params.get("bars") or []
                    if isinstance(raw_bars, str):
                        bars_list = [b.strip() for b in raw_bars.splitlines() if b.strip()]
                    elif isinstance(raw_bars, list):
                        bars_list = []
                        for b in raw_bars:
                            if isinstance(b, dict):
                                t = (b.get("text") or "").strip()
                                if t:
                                    bars_list.append(t)
                            elif isinstance(b, str) and b.strip():
                                bars_list.append(b.strip())
                    else:
                        bars_list = []

                    voice_arg = str(params.get("voice") or "Gunna").strip()
                    blend_arg = str(params.get("blend") or "").strip()
                    mix_arg = int(params.get("mix") or 70)
                    bpm_arg = float(params.get("bpm") or 130.0)
                    topic_arg = str(params.get("topic") or "").strip()
                    section_arg = str(params.get("section_mode") or "verse").strip()

                    res = polish.polish_lyrics(
                        bars_list,
                        voice=voice_arg,
                        blend=blend_arg,
                        mix=mix_arg,
                        bpm=bpm_arg,
                        topic=topic_arg,
                        section_mode=section_arg,
                    )
                    status = 200 if res.get("ok") else 400
                except Exception as exc:
                    res = {"ok": False, "error": str(exc)}
                    status = 500
                self._send(status, "application/json; charset=utf-8", json.dumps(res).encode("utf-8"))
                return

            if path in ("/api/inspect_seed", "/api/penwork/inspect_seed"):
                from catalog_retriever import extract_seed_pattern, retrieve_matching_catalog_lines, DEFAULT_CHOSEN_ALBUMS
                import polish
                try:
                    cmu = polish._get_cmu()
                    scratchpad = str(params.get("scratchpad") or "").strip()
                    voice_arg = str(params.get("voice") or "Gunna").strip()
                    bpm_arg = float(params.get("bpm") or 140.0)
                    chosen_albs = params.get("chosen_albums") or DEFAULT_CHOSEN_ALBUMS.get(voice_arg, [])
                    if scratchpad:
                        lines = [l.strip() for l in scratchpad.splitlines() if l.strip()]
                        patterns = extract_seed_pattern(lines, cmu, bpm=bpm_arg)
                        prev_match = None
                        for p_idx, p in enumerate(patterns):
                            matches = retrieve_matching_catalog_lines(
                                artist=voice_arg,
                                pattern=p,
                                chosen_albums=chosen_albs,
                                limit=2,
                                bar_number=p_idx + 1,
                                previous_retrieved_line=prev_match,
                            )
                            p["preview_matches"] = matches
                            if matches:
                                prev_match = matches[0]
                        res = {"ok": True, "patterns": patterns, "count": len(patterns)}
                    else:
                        res = {"ok": True, "patterns": [], "count": 0}
                    status = 200
                except Exception as exc:
                    res = {"ok": False, "error": str(exc)}
                    status = 500
                self._send(status, "application/json; charset=utf-8", json.dumps(res).encode("utf-8"))
                return

            if path == "/api/train":
                try:
                    result = control_training(root, params)
                    status = 200 if result.get("ok") else 400
                except Exception as exc:
                    result = {"ok": False, "message": str(exc)}
                    status = 500
                self._send(status, "application/json; charset=utf-8", json.dumps(result).encode("utf-8"))
                return

            if path == "/api/decision":
                decisions_path = root / "out" / "phase_decisions.json"
                current = _read_json_safe(decisions_path, {}) or {}
                phase_id = str(params.get("phase") or "phase_2")
                current[phase_id] = {
                    "choice": params.get("choice"),
                    "label": params.get("label"),
                    "notes": params.get("notes", ""),
                    "updated_at": _stamp(time.time()),
                }
                decisions_path.parent.mkdir(parents=True, exist_ok=True)
                decisions_path.write_text(json.dumps(current, indent=2), encoding="utf-8")
                self._send(200, "application/json; charset=utf-8", json.dumps({"ok": True, "decisions": current}).encode("utf-8"))
                return

            self._send(404, "application/json; charset=utf-8", b'{"error":"not found"}\n')

        def _cors(self):
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")

        def _send(self, status: int, content_type: str, body: bytes):
            self.send_response(status)
            self._cors()
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)

        def log_message(self, fmt, *args):
            sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    return DeskHandler


def serve(root: Path = None, grades_path: Path = None, host: str = HOST, port: int = PORT):
    root = HERE if root is None else root
    grades_path = Path.home() / "Downloads" / "grading.csv" if grades_path is None else grades_path
    server = ThreadingHTTPServer((host, port), make_handler(root, grades_path))
    print("Lyric desk & Interactive Studio at http://%s:%s/" % (host, port), flush=True)
    print("Classic read-only desk at http://%s:%s/classic" % (host, port), flush=True)
    print("Nothing is uploaded. Stop this with Ctrl-C.", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Stopped.", flush=True)
    finally:
        server.server_close()


def main(argv=None):
    try:
        serve()
    except OSError as exc:
        print("The lyric desk could not listen on http://%s:%s/ (%s)." % (HOST, PORT, exc), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
