#!/usr/bin/env python3
"""Resume bookkeeping for the lyric LoRA. No MLX and no lyric text.

A saved run is the resume_state.json sitting next to the adapter. Starting
again without --resume refuses. --fresh is the only request that discards a
checkpoint, and it moves the old directory aside instead of deleting it.
"""

from __future__ import annotations

import csv
import json
import os
from pathlib import Path

STATE_NAME = "resume_state.json"
MARKER_NAME = "resume_check.json"


def state_path(adapter_dir):
    return Path(adapter_dir) / STATE_NAME


def atomic_write_json(path, payload):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def load_state(path):
    path = Path(path)
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def resume_command(smoke):
    if smoke:
        return ".venv/bin/python train.py --resume --smoke"
    return ".venv/bin/python train.py --resume"


def _step(state):
    try:
        return int(state.get("step") or 0)
    except (TypeError, ValueError):
        return 0


def has_weights(state):
    return bool(state.get("adapter_weights")) and _step(state) > 0


def decide(state, resume, fresh, smoke):
    """Choose start, resume, refuse, or finished.

    A checkpoint without --resume or --fresh is a refusal. The run does not
    begin again.
    """
    if resume and fresh:
        return "refuse", "Pass either --resume or --fresh."
    command = resume_command(smoke)
    if state is None:
        if resume:
            return (
                "refuse",
                "No resume_state.json in the adapter directory. "
                "--resume will not start a new run.",
            )
        return "start", ""
    step = _step(state)
    loss = state.get("train_loss")
    if state.get("completed"):
        if fresh:
            return "start", "The finished run at step %s will be moved aside." % step
        return (
            "finished",
            "Training already finished at step %s loss %s. "
            "Pass --fresh to keep that run and start another."
            % (step, loss),
        )
    if not has_weights(state):
        if fresh:
            return "start", "The unfinished run has no saved weights. It will be moved aside."
        return (
            "refuse",
            "A run was started and no weights were saved (step %s). "
            "Unsaved steps cannot be continued. Pass --fresh to start over."
            % step,
        )
    if fresh:
        return (
            "start",
            "The checkpoint at step %s loss %s will be moved aside."
            % (step, loss),
        )
    if not resume:
        return (
            "refuse",
            "A checkpoint exists at step %s loss %s. "
            "Refusing to start over. Resume with: %s"
            % (step, loss, command),
        )
    return "resume", ""


def same_run(state, fingerprint):
    """True when the data, seed, and step budget match the saved run."""
    keys = (
        "song_digest",
        "train_windows",
        "iters_total",
        "seed",
        "mode",
        "batch_size",
        "max_seq_length",
        "grad_accumulation_steps",
    )
    for key in keys:
        if state.get(key) != fingerprint.get(key):
            return False
    return True


def mismatch_report(state, fingerprint):
    """List fields this command changed. Keys absent from fingerprint are skipped."""
    lines = ["This command does not match the saved run. Refusing to resume."]
    keys = (
        "mode",
        "seed",
        "train_windows",
        "iters_total",
        "song_digest",
        "batch_size",
        "max_seq_length",
        "grad_accumulation_steps",
    )
    for key in keys:
        if key not in fingerprint:
            continue
        saved = state.get(key)
        current = fingerprint.get(key)
        if saved != current:
            lines.append("  %s saved %s, this command %s" % (key, saved, current))
    return "\n".join(lines)


def read_csv(path):
    path = Path(path)
    if not path.exists() or path.stat().st_size == 0:
        return []
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def truncate_csv_to_step(path, step):
    """Keep the header and rows at or below the saved step. Return how many were dropped."""
    path = Path(path)
    rows = read_csv(path)
    if not rows and not path.exists():
        return 0
    kept = []
    dropped = 0
    for row in rows:
        try:
            row_step = int(row.get("step") or 0)
        except ValueError:
            dropped += 1
            continue
        if row_step <= int(step):
            kept.append(row)
        else:
            dropped += 1
    fields = list(rows[0].keys()) if rows else [
        "step",
        "train_loss",
        "val_loss",
        "learning_rate",
        "tokens_per_second",
        "peak_memory_gb",
    ]
    temporary = path.with_suffix(path.suffix + ".tmp")
    path.parent.mkdir(parents=True, exist_ok=True)
    with temporary.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for row in kept:
            writer.writerow(row)
    temporary.replace(path)
    return dropped


def row_for_step(rows, step):
    found = None
    for row in rows:
        try:
            if int(row.get("step") or 0) == int(step):
                found = row
        except ValueError:
            continue
    return found


def losses_match(left, right):
    if left is None or right is None or left == "" or right == "":
        return False
    if str(left) == str(right):
        return True
    try:
        return abs(float(left) - float(right)) <= 1e-6
    except (TypeError, ValueError):
        return False


def ensure_checkpoint_row(path, state):
    """Make sure the log still has the checkpoint step.

    Returns (loss_text, error). A mismatch refuses the resume. A missing row
    is rewritten from the checkpoint so the before-step can be compared later.
    """
    path = Path(path)
    step = _step(state)
    rows = read_csv(path)
    found = row_for_step(rows, step)
    if found is not None:
        if not losses_match(found.get("train_loss"), state.get("train_loss")):
            return None, (
                "Log loss at step %s is %s. Checkpoint loss is %s. "
                "Refusing to resume."
                % (step, found.get("train_loss"), state.get("train_loss"))
            )
        return found.get("train_loss"), ""
    fields = [
        "step",
        "train_loss",
        "val_loss",
        "learning_rate",
        "tokens_per_second",
        "peak_memory_gb",
    ]
    loss_text = "" if state.get("train_loss") is None else str(state.get("train_loss"))
    blank = {key: "" for key in fields}
    blank["step"] = step
    blank["train_loss"] = loss_text
    blank["val_loss"] = state.get("val_loss") or ""
    blank["learning_rate"] = (
        "" if state.get("learning_rate") is None else state.get("learning_rate")
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    new_file = not path.exists() or path.stat().st_size == 0
    with path.open("a", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        if new_file:
            writer.writeheader()
        writer.writerow(blank)
    return blank["train_loss"], ""


def marker_payload(state, csv_loss):
    step = _step(state)
    return {
        "resumed_from_step": step,
        "resumed_from_loss": csv_loss if csv_loss not in (None, "") else state.get("train_loss"),
        "expect_next_step": step + 1,
    }


def check_resume(csv_path, marker):
    """Compare the saved step with the next logged step.

    Returns (code, text). 0 means the step increased by one and the saved
    loss is still the row for that step. 2 means the next step is not logged
    yet. 1 means the run started over or the saved loss changed.
    """
    if not marker:
        return 1, "No resume_check.json. Resume has not been started."
    before_step = int(marker["resumed_from_step"])
    before_loss = marker["resumed_from_loss"]
    next_step = int(marker["expect_next_step"])
    rows = read_csv(csv_path)
    before = row_for_step(rows, before_step)
    if before is None:
        return 1, (
            "Step %s is missing from %s. The log no longer contains the saved step."
            % (before_step, csv_path)
        )
    if not losses_match(before.get("train_loss"), before_loss):
        return 1, (
            "before: step %s loss %s\n"
            "log now: step %s loss %s\n"
            "The saved loss changed. This is not the checkpoint that was resumed."
            % (before_step, before_loss, before_step, before.get("train_loss"))
        )
    after = row_for_step(rows, next_step)
    if after is None:
        return 2, (
            "before: step %s  loss %s\n"
            "after:  step %s is not in the log yet"
            % (before_step, before.get("train_loss"), next_step)
        )
    if int(after["step"]) != before_step + 1:
        return 1, (
            "before: step %s  loss %s\n"
            "after:  step %s  loss %s\n"
            "The next step is not one past the checkpoint."
            % (before_step, before.get("train_loss"), after["step"], after.get("train_loss"))
        )
    return 0, (
        "before: step %s  loss %s\n"
        "after:  step %s  loss %s\n"
        "Resume continued from the saved step. The step %s loss is unchanged."
        % (
            before_step,
            before.get("train_loss"),
            after["step"],
            after.get("train_loss"),
            before_step,
        )
    )


def status_text(state, smoke):
    if state is None:
        return "No checkpoint. A new run starts at step 1."
    step = _step(state)
    loss = state.get("train_loss")
    if not has_weights(state):
        return (
            "No weights have been saved (recorded step %s). "
            "A crash before the first save, or before Ctrl-C finished the step, "
            "has nothing to resume."
            % step
        )
    if state.get("completed"):
        return "Training finished at step %s loss %s." % (step, loss)
    return (
        "checkpoint step: %s\n"
        "checkpoint loss: %s\n"
        "learning rate: %s\n"
        "weights: %s\n"
        "next step after resume: %s\n"
        "command: %s"
        % (
            step,
            loss,
            state.get("learning_rate"),
            state.get("adapter_weights"),
            step + 1,
            resume_command(smoke),
        )
    )


def pid_is_running(pid):
    try:
        os.kill(int(pid), 0)
    except (OSError, ValueError):
        return False
    return True


def read_pid(path):
    path = Path(path)
    if not path.exists():
        return None
    text = path.read_text(encoding="utf-8").strip()
    if not text:
        return None
    try:
        return int(text)
    except ValueError:
        return None
