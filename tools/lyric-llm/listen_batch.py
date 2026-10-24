#!/usr/bin/env python3
"""Write 20 batches of 16 bars and a blank grading sheet.

Voice, BPM, and temperature change across the batches. Scale, top-p, and
the topic stay put so a listen compares those three controls. The grade
columns are empty. This script does not score the bars.

  .venv/bin/python listen_batch.py
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

import generate
import infer
from lyriclib import estimate_syllables

HERE = Path(__file__).resolve().parent
OUT = HERE / "out" / "listen"
BARS = 16
SCALE = "A minor"
TOP_P = 0.95
TOPIC = "a night that ran long"
GRADE_COLUMNS = (
    "rhyme (1-5)",
    "flow (1-5)",
    "voice match (1-5)",
    "originality (1-5)",
    "keep (yes/no)",
    "notes",
)
COLUMNS = ("batch", "voice", "bpm", "temperature") + GRADE_COLUMNS

# Twenty single-voice settings. Each voice appears twice, at a different
# BPM and temperature. Young Stoner Life stays its own token.
SPECS = (
    {"batch": 1, "voice": "Gunna", "bpm": 70, "temperature": "0.6"},
    {"batch": 2, "voice": "Young Thug", "bpm": 140, "temperature": "1.2"},
    {"batch": 3, "voice": "Young Stoner Life", "bpm": 100, "temperature": "0.8"},
    {"batch": 4, "voice": "Lil Wayne", "bpm": 160, "temperature": "1.0"},
    {"batch": 5, "voice": "Lil Uzi Vert", "bpm": 85, "temperature": "1.15"},
    {"batch": 6, "voice": "Drake", "bpm": 120, "temperature": "0.7"},
    {"batch": 7, "voice": "Juice WRLD", "bpm": 150, "temperature": "0.9"},
    {"batch": 8, "voice": "J. Cole", "bpm": 75, "temperature": "1.25"},
    {"batch": 9, "voice": "Rick Ross", "bpm": 130, "temperature": "0.65"},
    {"batch": 10, "voice": "Chief Keef", "bpm": 110, "temperature": "1.05"},
    {"batch": 11, "voice": "Gunna", "bpm": 155, "temperature": "1.1"},
    {"batch": 12, "voice": "Young Thug", "bpm": 80, "temperature": "0.75"},
    {"batch": 13, "voice": "Young Stoner Life", "bpm": 170, "temperature": "0.6"},
    {"batch": 14, "voice": "Lil Wayne", "bpm": 95, "temperature": "1.3"},
    {"batch": 15, "voice": "Lil Uzi Vert", "bpm": 145, "temperature": "0.8"},
    {"batch": 16, "voice": "Drake", "bpm": 70, "temperature": "1.0"},
    {"batch": 17, "voice": "Juice WRLD", "bpm": 125, "temperature": "1.2"},
    {"batch": 18, "voice": "J. Cole", "bpm": 165, "temperature": "0.7"},
    {"batch": 19, "voice": "Rick Ross", "bpm": 90, "temperature": "0.95"},
    {"batch": 20, "voice": "Chief Keef", "bpm": 135, "temperature": "1.15"},
)


def batch_path(directory: Path, batch: int) -> Path:
    return directory / ("%02d.txt" % int(batch))


def render_batch(spec, lines, scale=SCALE, top_p=TOP_P, bars=BARS, topic=TOPIC) -> str:
    """Settings first, then a blank line, then one bar per line."""
    header = [
        "batch: %02d" % spec["batch"],
        "voice: %s" % spec["voice"],
        "bpm: %s" % spec["bpm"],
        "temperature: %s" % spec["temperature"],
        "scale: %s" % scale,
        "top-p: %s" % top_p,
        "bars: %d" % bars,
        "seed: %d" % spec["seed"],
        "topic: %s" % topic,
        "",
    ]
    return "\n".join(header) + "\n" + generate.format_bars(lines)


def bar_count(text: str) -> int:
    parts = text.split("\n\n", 1)
    if len(parts) != 2:
        return 0
    return sum(1 for line in parts[1].splitlines() if line.strip())


def grading_rows(specs=SPECS):
    rows = []
    for spec in specs:
        row = {
            "batch": "%02d" % spec["batch"],
            "voice": spec["voice"],
            "bpm": str(spec["bpm"]),
            "temperature": spec["temperature"],
        }
        for column in GRADE_COLUMNS:
            row[column] = ""
        rows.append(row)
    return rows


def write_grading_sheet(path: Path, specs=SPECS) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(COLUMNS))
        writer.writeheader()
        writer.writerows(grading_rows(specs))


def sheet_has_grades(path: Path) -> bool:
    if not path.exists():
        return False
    with path.open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            for column in GRADE_COLUMNS:
                if (row.get(column) or "").strip():
                    return True
    return False


def parse_batch_file(text: str) -> dict:
    head, _, body = text.partition("\n\n")
    meta = {}
    for line in head.splitlines():
        if ": " not in line:
            continue
        key, value = line.split(": ", 1)
        meta[key.strip()] = value.strip()
    bars = [line.strip() for line in body.splitlines() if line.strip()]
    return {"meta": meta, "bars": bars}


def load_listen_batches(directory: Path) -> list:
    found = []
    for path in sorted(directory.glob("[0-9][0-9].txt")):
        parsed = parse_batch_file(path.read_text(encoding="utf-8"))
        meta = parsed["meta"]
        found.append(
            {
                "batch": meta.get("batch", path.stem),
                "voice": meta.get("voice", ""),
                "bpm": meta.get("bpm", ""),
                "temperature": meta.get("temperature", ""),
                "scale": meta.get("scale", ""),
                "top_p": meta.get("top-p", ""),
                "seed": meta.get("seed", ""),
                "topic": meta.get("topic", ""),
                "bars": parsed["bars"],
            }
        )
    return found


def _end_word(line: str) -> str:
    words = str(line).split()
    if not words:
        return ""
    return words[-1].strip(".,;:!?\"'()[]")


def _display_bars(bars) -> list:
    shown = []
    for bar in bars:
        line = bar.get("line", "") if isinstance(bar, dict) else str(bar)
        shown.append(
            {
                "line": line,
                "syllables": estimate_syllables(line) if line.strip() else 0,
                "end": _end_word(line),
            }
        )
    return shown


def render_listen_page(batches) -> str:
    """One verse on a sheet. Next stays off until that batch is checked.

    Syllable counts and end words are shown so a listen can see length and
    rhyme position. Score fields start empty.
    """
    ready = []
    for batch in batches:
        item = dict(batch)
        item["bars"] = _display_bars(batch.get("bars") or [])
        ready.append(item)
    payload = json.dumps(ready, ensure_ascii=False).replace("<", "\\u003c")
    return """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Listen batches</title>
<style>
  :root {
    --paper: #e7f0ea;
    --ink: #17241e;
    --quiet: #3e5248;
    --line: #c5d5cb;
    --fill: #17241e;
    --fill-text: #f4faf6;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    background: var(--paper);
    color: var(--ink);
    font: 20px/1.45 Palatino, "Palatino Linotype", "Iowan Old Style", serif;
  }
  main { max-width: 46rem; margin: 0 auto; padding: 1.4rem 1.2rem 4rem; }
  h1 { font: 600 2rem/1.15 "Avenir Next", "Gill Sans", system-ui, sans-serif; margin: 0.15rem 0 0.8rem; }
  h2 { font: 600 1.15rem/1.3 "Avenir Next", "Gill Sans", system-ui, sans-serif; margin: 0 0 0.35rem; }
  .progress, .hint, .aside, .col, label, button, select, textarea {
    font: 16px/1.4 "Avenir Next", "Gill Sans", system-ui, sans-serif;
  }
  .progress, .hint, .aside, .col { color: var(--quiet); }
  .hint { margin: 0 0 0.8rem; }
  .facts { display: grid; grid-template-columns: 1.4fr 0.7fr 0.8fr; gap: 0.8rem; margin-bottom: 0.7rem; }
  .facts strong { display: block; font: 600 1.55rem/1.15 "Avenir Next", "Gill Sans", system-ui, sans-serif; color: var(--ink); }
  .steps { display: flex; flex-wrap: wrap; gap: 0.35rem; margin: 0.9rem 0 1rem; }
  .head, li { display: grid; grid-template-columns: 5.5rem 1fr 7.5rem; gap: 0.7rem; align-items: baseline; }
  .head { margin-bottom: 0.2rem; }
  ol { list-style: none; margin: 0; padding: 0; }
  li { padding: 0.42rem 0; border-top: 1px solid var(--line); }
  .end { font-weight: 700; }
  .scores { margin-top: 1.4rem; }
  .grid { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 0.55rem; }
  label { display: block; margin-bottom: 0.25rem; }
  select, textarea {
    width: 100%;
    color: var(--ink);
    background: #f7fbf8;
    border: 1px solid var(--line);
    border-radius: 6px;
    padding: 0.45rem 0.5rem;
  }
  textarea { min-height: 5.5rem; margin-top: 0.55rem; font-size: 16px; }
  .row { display: flex; flex-wrap: wrap; gap: 0.55rem; margin-top: 1rem; }
  button {
    min-height: 44px;
    padding: 0.55rem 0.9rem;
    border-radius: 8px;
    border: 1px solid var(--ink);
    background: var(--fill);
    color: var(--fill-text);
  }
  button.quiet { background: transparent; color: var(--ink); }
  button:disabled { opacity: 0.38; }
  button:focus-visible, select:focus-visible, textarea:focus-visible {
    outline: 3px solid var(--ink);
    outline-offset: 2px;
  }
  .steps button { min-width: 44px; padding: 0.4rem 0.45rem; background: transparent; color: var(--ink); }
  .steps button[aria-current="true"] { background: var(--fill); color: var(--fill-text); }
  @media (max-width: 640px) {
    .facts, .grid { grid-template-columns: 1fr 1fr; }
    .head span:last-child { display: none; }
    .head, li { grid-template-columns: 4.2rem 1fr; }
    .end { grid-column: 2; }
  }
  @media (prefers-reduced-motion: reduce) {
    * { scroll-behavior: auto; }
  }
</style>
</head>
<body>
<main>
  <p class="progress" id="progress"></p>
  <h1 id="title">Batch</h1>
  <div class="facts" id="facts"></div>
  <p class="aside" id="aside"></p>
  <p class="hint">Check the batch on screen, then open the next one. Checking only records that you looked. It does not score the bars.</p>
  <div class="steps" id="steps"></div>
  <div class="head">
    <span class="col">Syllables</span>
    <span class="col">Bar</span>
    <span class="col">End word</span>
  </div>
  <ol id="bars"></ol>
  <section class="scores">
    <h2>Your scores</h2>
    <p class="hint">Leave these blank until you decide. Nothing here is filled in for you.</p>
    <div class="grid">
      <div><label for="score-rhyme">Rhyme, 1 to 5</label><select id="score-rhyme"></select></div>
      <div><label for="score-flow">Flow, 1 to 5</label><select id="score-flow"></select></div>
      <div><label for="score-voice">Voice match, 1 to 5</label><select id="score-voice"></select></div>
      <div><label for="score-originality">Originality, 1 to 5</label><select id="score-originality"></select></div>
      <div><label for="score-keep">Keep</label><select id="score-keep"></select></div>
    </div>
    <label for="score-notes">Notes</label>
    <textarea id="score-notes" placeholder="What you heard"></textarea>
  </section>
  <div class="row">
    <button type="button" id="prev-batch" class="quiet">Previous batch</button>
    <button type="button" id="check-batch">I checked this batch</button>
    <button type="button" id="next-batch">Next batch</button>
    <button type="button" id="download-sheet" class="quiet">Download the sheet</button>
  </div>
  <p class="hint">Download saves the scores you typed. Empty scores stay empty.</p>
</main>
<script>
const batches = __PAYLOAD__;
const checkedKey = "penwork-listen-checked";
const scoreKey = "penwork-listen-scores";
let checked = {};
let scores = {};
try { checked = JSON.parse(localStorage.getItem(checkedKey) || "{}"); } catch (e) { checked = {}; }
try { scores = JSON.parse(localStorage.getItem(scoreKey) || "{}"); } catch (e) { scores = {}; }
let index = 0;
for (let i = 0; i < batches.length; i += 1) {
  if (!checked[batches[i].batch]) { index = i; break; }
}

function fillScale(select, values) {
  select.replaceChildren();
  values.forEach(function (pair) {
    const option = document.createElement("option");
    option.value = pair[0];
    option.textContent = pair[1];
    select.append(option);
  });
}
const numbers = [["", "Not scored"], ["1", "1"], ["2", "2"], ["3", "3"], ["4", "4"], ["5", "5"]];
["score-rhyme", "score-flow", "score-voice", "score-originality"].forEach(function (id) {
  fillScale(document.getElementById(id), numbers);
});
fillScale(document.getElementById("score-keep"), [["", "Not scored"], ["yes", "Yes"], ["no", "No"]]);

function earlierChecked(target) {
  for (let i = 0; i < target; i += 1) {
    if (!checked[batches[i].batch]) return false;
  }
  return true;
}

function currentScores() {
  return {
    rhyme: document.getElementById("score-rhyme").value,
    flow: document.getElementById("score-flow").value,
    voice: document.getElementById("score-voice").value,
    originality: document.getElementById("score-originality").value,
    keep: document.getElementById("score-keep").value,
    notes: document.getElementById("score-notes").value
  };
}

function applyScores(row) {
  row = row || {};
  document.getElementById("score-rhyme").value = row.rhyme || "";
  document.getElementById("score-flow").value = row.flow || "";
  document.getElementById("score-voice").value = row.voice || "";
  document.getElementById("score-originality").value = row.originality || "";
  document.getElementById("score-keep").value = row.keep || "";
  document.getElementById("score-notes").value = row.notes || "";
}

function storeScores() {
  scores[batches[index].batch] = currentScores();
  localStorage.setItem(scoreKey, JSON.stringify(scores));
}

function show(nextIndex) {
  if (nextIndex < 0 || nextIndex >= batches.length) return;
  if (!earlierChecked(nextIndex)) return;
  index = nextIndex;
  const batch = batches[index];
  const seen = Boolean(checked[batch.batch]);
  document.getElementById("title").textContent = "Batch " + batch.batch;
  document.getElementById("facts").replaceChildren();
  [["Voice", batch.voice], ["BPM", batch.bpm], ["Temperature", batch.temperature]].forEach(function (pair) {
    const block = document.createElement("div");
    const name = document.createElement("span");
    name.className = "col";
    name.textContent = pair[0];
    const value = document.createElement("strong");
    value.textContent = pair[1];
    block.append(name, value);
    document.getElementById("facts").append(block);
  });
  document.getElementById("aside").textContent = "Scale " + batch.scale + ". Top-p " + batch.top_p + ". Seed " + batch.seed + ". Topic: " + batch.topic;
  const list = document.getElementById("bars");
  list.replaceChildren();
  batch.bars.forEach(function (bar) {
    const item = document.createElement("li");
    const count = document.createElement("span");
    count.className = "col";
    count.textContent = String(bar.syllables);
    const words = document.createElement("span");
    words.textContent = bar.line;
    const end = document.createElement("span");
    end.className = "end";
    end.textContent = bar.end;
    item.append(count, words, end);
    list.append(item);
  });
  applyScores(scores[batch.batch]);
  const done = batches.filter(function (item) { return checked[item.batch]; }).length;
  document.getElementById("progress").textContent = "Checked " + done + " of " + batches.length;
  const check = document.getElementById("check-batch");
  check.disabled = seen;
  check.textContent = seen ? "Checked" : "I checked this batch";
  document.getElementById("prev-batch").disabled = index === 0;
  document.getElementById("next-batch").disabled = !seen || index === batches.length - 1;
  const steps = document.getElementById("steps");
  steps.replaceChildren();
  batches.forEach(function (item, itemIndex) {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = item.batch;
    button.setAttribute("aria-label", "Batch " + item.batch);
    button.disabled = !earlierChecked(itemIndex);
    if (itemIndex === index) button.setAttribute("aria-current", "true");
    button.addEventListener("click", function () { show(itemIndex); window.scrollTo(0, 0); });
    steps.append(button);
  });
}

["score-rhyme", "score-flow", "score-voice", "score-originality", "score-keep", "score-notes"].forEach(function (id) {
  document.getElementById(id).addEventListener("input", storeScores);
  document.getElementById(id).addEventListener("change", storeScores);
});
document.getElementById("check-batch").addEventListener("click", function () {
  checked[batches[index].batch] = true;
  localStorage.setItem(checkedKey, JSON.stringify(checked));
  show(index);
});
document.getElementById("next-batch").addEventListener("click", function () {
  if (!checked[batches[index].batch]) return;
  show(index + 1);
  window.scrollTo(0, 0);
});
document.getElementById("prev-batch").addEventListener("click", function () {
  show(index - 1);
  window.scrollTo(0, 0);
});
document.getElementById("download-sheet").addEventListener("click", function () {
  storeScores();
  const header = ["batch", "voice", "bpm", "temperature", "rhyme (1-5)", "flow (1-5)", "voice match (1-5)", "originality (1-5)", "keep (yes/no)", "notes"];
  function cell(value) {
    const text = value == null ? "" : String(value);
    return /[",\\n]/.test(text) ? '"' + text.replace(/"/g, '""') + '"' : text;
  }
  const lines = [header.join(",")];
  batches.forEach(function (batch) {
    const row = scores[batch.batch] || {};
    lines.push([
      batch.batch, batch.voice, batch.bpm, batch.temperature,
      row.rhyme || "", row.flow || "", row.voice || "", row.originality || "", row.keep || "", row.notes || ""
    ].map(cell).join(","));
  });
  const blob = new Blob([lines.join("\\n") + "\\n"], { type: "text/csv" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = "grading.csv";
  link.click();
  URL.revokeObjectURL(link.href);
});
show(index);
</script>
</body>
</html>
""".replace("__PAYLOAD__", payload)


def write_listen_page(directory: Path) -> Path:
    batches = load_listen_batches(directory)
    if len(batches) != 20:
        raise GenerateError("Expected 20 batch files, found %d." % len(batches))
    path = directory / "index.html"
    path.write_text(render_listen_page(batches), encoding="utf-8")
    return path


class GenerateError(ValueError):
    """The listen page cannot be written."""


def _spec_seed(spec) -> dict:
    ready = dict(spec)
    ready["seed"] = 100 + int(spec["batch"])
    return ready


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description="Write 20 listen batches and a blank grading sheet.")
    parser.add_argument("--out-dir", type=Path, default=OUT)
    parser.add_argument("--model", default="mlx-community/Qwen2.5-3B-Instruct-4bit")
    parser.add_argument("--adapter", type=Path, default=HERE / "adapters")
    args = parser.parse_args(argv)
    directory = args.out_dir
    directory.mkdir(parents=True, exist_ok=True)
    sheet = directory / "grading.csv"
    if sheet_has_grades(sheet):
        print("grading.csv already has scores. Leave it.", file=sys.stderr)
        return 1

    pending = []
    for spec in SPECS:
        spec = _spec_seed(spec)
        path = batch_path(directory, spec["batch"])
        if path.exists() and bar_count(path.read_text(encoding="utf-8")) >= BARS:
            print("keep %s" % path.name, file=sys.stderr)
            continue
        pending.append((spec, path))

    loaded = None
    if pending:
        hold = argparse.Namespace(model=args.model, adapter=args.adapter)
        loaded = generate._load(hold)
        if loaded is None:
            return 1
    model, tokenizer = loaded if loaded else (None, None)

    short = []
    for spec, path in pending:
        request = generate.generation_request(
            spec["voice"],
            bpm=spec["bpm"],
            scale=SCALE,
            topic=TOPIC,
            bars=BARS,
            temperature=spec["temperature"],
            top_p=TOP_P,
            seed=spec["seed"],
        )
        plan = request["plan"]
        print(
            "batch %02d  %s  BPM %s  temperature %s  seed %s"
            % (spec["batch"], spec["voice"], spec["bpm"], spec["temperature"], spec["seed"]),
            file=sys.stderr,
        )
        lines = infer.generate_mixed(model, tokenizer, plan, request["job"])
        path.write_text(render_batch(spec, lines), encoding="utf-8")
        print("wrote %s  bars %d" % (path.name, len(lines)), file=sys.stderr)
        if len(lines) < BARS:
            short.append(path.name)

    write_grading_sheet(sheet)
    print("wrote %s" % sheet, file=sys.stderr)
    if short:
        print("short batches: %s" % ", ".join(short), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
