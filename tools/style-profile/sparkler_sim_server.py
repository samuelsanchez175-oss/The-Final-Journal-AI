#!/usr/bin/env python3
"""Local helper for the Penwork Studios Sparkler screen.

The iPhone app cannot run the Python generator itself. This process stays on
the Mac. The simulator uses 127.0.0.1. A phone on the same Wi-Fi uses the Mac name.

  python3 tools/style-profile/sparkler_sim_server.py

GET  /verses   saved inner-rhyme and double-meaning verses
POST /run      one new mimic verse. Body: {"level": "inner"|"double"}
GET  /health
"""

from __future__ import annotations

import json
import subprocess
import sys
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent
HOST = "0.0.0.0"
PORT = 8766
SAVED = {
    "inner": [ROOT / "out" / "rater-batch-levels" / "inner",
              ROOT / "out" / "rater-batch-levels" / "v3"],
    "double": [ROOT / "out" / "rater-batch-levels" / "double",
               ROOT / "out" / "rater-batch-levels" / "v4"],
    "story": [ROOT / "out" / "rater-batch-story2" / "story",
              ROOT / "out" / "rater-batch-story" / "story"],
}
TITLES = {
    "inner": "Inner rhyme",
    "double": "Double meanings",
    "story": "Story spine",
}
HINTS = {
    "inner": "A rhyme inside the line, on about one line in four.",
    "double": "The same rhyme plan, plus two lines that each mean two things.",
    "story": "One spine the whole verse serves: come-up arc, a recurring person, or circle vs opps.",
}
RUN_DIR = ROOT / "out" / "rater-batch-levels" / "app-run"
PHASE6 = ROOT / "phase6_generate.py"

_lock = threading.Lock()
_run = {"state": "idle", "level": None, "message": "", "seed": None}


def _lines(model: dict) -> list[str]:
    return [bar.get("text", "") for bar in model.get("bars") or [] if bar.get("text")]


def _verses_in(folder: Path, origin: str) -> list[dict]:
    if not folder.is_dir():
        return []
    verses = []
    for path in sorted(folder.glob("mimic_*.json")):
        if path.name == "mimic_manifest.json":
            continue
        doc = json.loads(path.read_text(encoding="utf-8"))
        level = doc.get("level") or "inner"
        models = doc.get("models") or {}
        if not models and doc.get("bars"):
            models = {"take": {"bars": doc.get("bars"), "notes": doc.get("notes")}}
        for index, key in enumerate(sorted(models)):
            model = models[key] or {}
            lines = _lines(model)
            if not lines:
                continue
            notes = [note for note in (model.get("notes") or doc.get("notes") or []) if isinstance(note, str)]
            label = "New verse" if origin == "new" else f"Seed {doc.get('seed')}"
            verses.append({
                "seed": doc.get("seed"),
                "take": index + 1,
                "title": f"{label} · take {index + 1}",
                "lines": lines,
                "note": notes[0] if notes else "",
                "origin": origin,
                "level": level,
            })
    return verses


def board() -> dict:
    with _lock:
        run = dict(_run)
    fresh = _verses_in(RUN_DIR, "new")
    levels = []
    for level in ("story", "inner", "double"):
        verses = []
        for folder in SAVED[level]:
            verses += [verse for verse in _verses_in(folder, "saved") if verse["level"] == level]
        verses += [verse for verse in fresh if verse["level"] == level]
        levels.append({
            "id": level,
            "title": TITLES[level],
            "hint": HINTS[level],
            "verses": verses,
        })
    return {"ok": True, "helper": "running", "levels": levels, "run": run}


def _finish_run(proc: subprocess.Popen, level: str, seed: int) -> None:
    stdout, stderr = proc.communicate()
    tail = (stderr or stdout or "").strip().splitlines()
    message = tail[-1] if tail else f"finished with code {proc.returncode}"
    state = "done" if proc.returncode == 0 else "failed"
    with _lock:
        _run.update(state=state, level=level, seed=seed, message=message[:400])


def start_run(level: str) -> dict:
    if level not in SAVED:
        return {"ok": False, "error": "Choose inner rhyme or double meanings."}
    with _lock:
        if _run["state"] == "running":
            return {"ok": False, "error": "A verse is already being written.", "run": dict(_run)}
        seed = {"inner": 81, "double": 82, "story": 91}.get(level, 81)
        _run.update(state="running", level=level, seed=seed, message="Writing one verse. This can take a few minutes.")
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    out = RUN_DIR / f"mimic_{seed}.json"
    command = [
        sys.executable, str(PHASE6),
        "--artist", "Gunna",
        "--mode", "mimic",
        "--level", level,
        "--bars", "8",
        "--candidates", "2",
        "--sets", "1",
        "--seed", str(seed),
        "--closeness", "0.7",
        "--model", "sonnet",
        "--out", str(out),
    ]
    proc = subprocess.Popen(
        command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
    )
    threading.Thread(target=_finish_run, args=(proc, level, seed), daemon=True).start()
    with _lock:
        run = dict(_run)
    return {"ok": True, "run": run}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt: str, *args) -> None:
        sys.stderr.write("%s\n" % (fmt % args))

    def _send(self, code: int, payload: dict) -> None:
        body = json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        if self.path.startswith("/health"):
            self._send(200, {"ok": True})
        elif self.path.startswith("/verses"):
            self._send(200, board())
        else:
            self._send(404, {"ok": False, "error": "Not found"})

    def do_POST(self) -> None:
        if not self.path.startswith("/run"):
            self._send(404, {"ok": False, "error": "Not found"})
            return
        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length) if length else b"{}"
        try:
            body = json.loads(raw.decode() or "{}")
        except json.JSONDecodeError:
            self._send(400, {"ok": False, "error": "The request was not valid JSON."})
            return
        result = start_run(str(body.get("level") or "inner"))
        self._send(200 if result.get("ok") else 409, result)


def main() -> int:
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"Sparkler helper on http://{HOST}:{PORT}", flush=True)
    print("Phone on this Wi-Fi: http://Samuels-MacBook-Pro-3.local:8766", flush=True)
    server.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
