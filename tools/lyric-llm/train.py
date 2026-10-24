#!/usr/bin/env python3
"""QLoRA fine-tune for Qwen2.5-3B on the leak-checked Penwork songs.

The base is mlx-community/Qwen2.5-3B-Instruct-4bit. LoRA on that 4-bit
checkpoint is MLX's QLoRA path. Each song is cut into 8-line windows. The
user turn is the voice prefix and the assistant turn is the window. Loss is
masked on the prefix.

  uv venv --python 3.12 .venv
  uv pip install -r requirements.txt
  .venv/bin/python train.py --smoke          # 20 songs, under 15 minutes once cached
  .venv/bin/python train.py --dry-run --epochs 1
  .venv/bin/python train.py --epochs 1       # one full pass; many hours
  .venv/bin/python train.py --resume         # continue from the last checkpoint
  .venv/bin/python train.py --check-resume   # compare the saved step and the next one
  python3 train.py --list-voices         # write the voice tokens; does not train

MLX is imported only when a run actually trains, so --dry-run, --list-voices,
and the unit tests work on the system Python.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import os
import random
import re
import signal
import sys
import time
import types
from pathlib import Path

import resume_lib

from lyriclib import (
    CHUNK_LINES,
    MIN_CHUNK,
    RELIABLE_VOICE_LINES,
    SECTION_RE,
    chunks,
    estimate_syllables,
    messages_for_chunk,
    write_voice_inventory,
)

HERE = Path(__file__).resolve().parent
CONFIG = HERE / "train_config.yaml"
SONG_DIR = HERE / "out"
SONG_FILES = {
    "train": SONG_DIR / "train.jsonl",
    "valid": SONG_DIR / "val.jsonl",
    "test": SONG_DIR / "test.jsonl",
}
FULL_DATA = SONG_DIR / "mlx_songs"
SMOKE_DATA = SONG_DIR / "smoke"
RUN_CONFIG = SONG_DIR / "train_config.run.yaml"
FULL_LOG = SONG_DIR / "training_log.csv"
SMOKE_LOG = FULL_LOG
PID_FILE = SONG_DIR / "train.pid"
RESUME_MARKER = SONG_DIR / resume_lib.MARKER_NAME
FULL_ADAPTER = HERE / "adapters"
SMOKE_ADAPTER = HERE / "adapters_smoke"

SMOKE_SONGS = 20
SMOKE_LINE_CAP = 16
SMOKE_SIDE = 4
SMOKE_STEP_CEILING = SMOKE_SONGS * (SMOKE_LINE_CAP // CHUNK_LINES)
PEAK_LR = "2.0e-5"
PIN_ARTISTS = ("Gunna", "Young Thug")
PIN_FALLBACK = "Young Stoner Life"
LOG_FIELDS = [
    "step",
    "train_loss",
    "val_loss",
    "learning_rate",
    "tokens_per_second",
    "peak_memory_gb",
]
ALPHA_KEY = re.compile(r"(?m)^[ \t]*alpha\s*:")

INSTALL_HELP = (
    "mlx_lm is not installed. From tools/lyric-llm, use the venv Python "
    "(3.12), not Xcode's 3.9:\n"
    '  cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"\n'
    "  uv venv --python 3.12 .venv\n"
    "  uv pip install -r requirements.txt\n"
    "  .venv/bin/python train.py --smoke\n"
    "  .venv/bin/python train.py --epochs 1"
)


def yaml_quote(value):
    """Quote a path so a space or a colon stays inside one YAML string."""
    escaped = str(value).replace("\\", "\\\\").replace('"', '\\"')
    return '"%s"' % escaped


def yaml_top_number(text, key, default):
    prefix = key + ":"
    for line in text.splitlines():
        if line.startswith(prefix):
            return float(line.split(":", 1)[1].strip())
    return float(default)


def yaml_schedule_warmup(text, default):
    in_schedule = False
    for line in text.splitlines():
        if line.startswith("lr_schedule:"):
            in_schedule = True
            continue
        if in_schedule and line and not line[0].isspace() and not line.startswith("#"):
            break
        stripped = line.strip()
        if in_schedule and stripped.startswith("warmup:"):
            return float(stripped.split(":", 1)[1].strip())
    return float(default)


def content_lines(record, line_cap=None):
    """Non-empty song lines, in order. Syllables are estimated on lyric lines.

    Section markers stay in the window so the verse/chorus label is still
    there. They do not get a syllable count, so they do not move the median
    the prefix reports. BPM and scale are copied through; nothing is invented.
    """
    lines = []
    for raw in (record.get("text") or "").split("\n"):
        if not raw.strip():
            continue
        item = {"text": raw}
        if not SECTION_RE.match(raw.strip()):
            item["syl"] = estimate_syllables(raw)
        lines.append(item)
        if line_cap is not None and len(lines) >= line_cap:
            break
    return lines


def eligible(record):
    return len(content_lines(record, line_cap=MIN_CHUNK)) >= MIN_CHUNK


def windows_for_record(record, line_cap=None):
    artist = record.get("artist") or ""
    if not artist or not eligible(record):
        return []
    scale = record.get("scale")
    if scale is not None and not str(scale).strip():
        scale = None
    produced = []
    for block in chunks(content_lines(record, line_cap=line_cap)):
        produced.append(
            messages_for_chunk(artist, record.get("bpm"), scale, block)
        )
    return produced


def apply_pins(chosen, pinned):
    """Keep one Gunna song and one Young Thug song in the smoke draw.

    Young Stoner Life fills the Young Thug slot when that exact credit is
    not in the draw. Collab credits are left alone. The draw length stays put.
    """
    if len(chosen) < 2:
        return chosen
    have = {record.get("artist") or "" for record in chosen}
    wanted = []
    if "Gunna" not in have and "Gunna" in pinned:
        wanted.append(pinned["Gunna"])
    if "Young Thug" not in have:
        if "Young Thug" in pinned:
            wanted.append(pinned["Young Thug"])
        elif PIN_FALLBACK not in have and PIN_FALLBACK in pinned:
            wanted.append(pinned[PIN_FALLBACK])
    ids = {record.get("song_id") for record in chosen}
    slot = len(chosen) - 1
    protected = set(PIN_ARTISTS + (PIN_FALLBACK,))
    for record in wanted:
        if record.get("song_id") in ids:
            continue
        while slot >= 0 and (chosen[slot].get("artist") or "") in protected:
            slot -= 1
        if slot < 0:
            break
        ids.discard(chosen[slot].get("song_id"))
        chosen[slot] = record
        ids.add(record.get("song_id"))
        slot -= 1
    return chosen


def sample_songs(path, k, seed, pin=False):
    """Reservoir sample of songs that have at least four non-empty lines."""
    rng = random.Random(seed)
    chosen = []
    seen = 0
    pinned = {}
    watch = set(PIN_ARTISTS + (PIN_FALLBACK,))
    with path.open(encoding="utf-8") as handle:
        for line in handle:
            if not line.strip():
                continue
            record = json.loads(line)
            if not eligible(record):
                continue
            artist = record.get("artist") or ""
            if pin and artist in watch and artist not in pinned:
                pinned[artist] = record
            seen += 1
            if len(chosen) < k:
                chosen.append(record)
            else:
                j = rng.randrange(seen)
                if j < k:
                    chosen[j] = record
    if pin:
        apply_pins(chosen, pinned)
    return chosen


def write_windows(records, dest, line_cap):
    dest.parent.mkdir(parents=True, exist_ok=True)
    songs = 0
    windows = 0
    first_prefix = ""
    with dest.open("w", encoding="utf-8") as handle:
        for record in records:
            produced = windows_for_record(record, line_cap=line_cap)
            if not produced:
                continue
            songs += 1
            windows += len(produced)
            if not first_prefix:
                first_prefix = produced[0]["messages"][0]["content"].split("\n", 1)[0]
            for item in produced:
                handle.write(json.dumps(item, ensure_ascii=False) + "\n")
    return songs, windows, first_prefix


def stream_windows(src, dest, line_cap, write):
    """Count windows. The full dry-run counts without writing the chat set."""
    songs = 0
    windows = 0
    first_prefix = ""
    handle = None
    if write:
        dest.parent.mkdir(parents=True, exist_ok=True)
        handle = dest.open("w", encoding="utf-8")
    try:
        with src.open(encoding="utf-8") as incoming:
            for line in incoming:
                if not line.strip():
                    continue
                produced = windows_for_record(json.loads(line), line_cap=line_cap)
                if not produced:
                    continue
                songs += 1
                windows += len(produced)
                if not first_prefix:
                    first_prefix = produced[0]["messages"][0]["content"].split("\n", 1)[0]
                if handle is not None:
                    for item in produced:
                        handle.write(json.dumps(item, ensure_ascii=False) + "\n")
    finally:
        if handle is not None:
            handle.close()
    return songs, windows, first_prefix


def copy_one_window(src, dest):
    """Give MLX a non-empty valid/test file when a side split has no windows."""
    if not src.exists():
        return 0
    with src.open(encoding="utf-8") as incoming:
        first = incoming.readline()
    if not first.strip():
        return 0
    dest.parent.mkdir(parents=True, exist_ok=True)
    with dest.open("w", encoding="utf-8") as handle:
        handle.write(first if first.endswith("\n") else first + "\n")
    return 1


def render_run_config(text, iters, warmup, data, adapter_path, val_batches):
    """Patch the run copy. The cosine peak stays 2.0e-5."""
    if ALPHA_KEY.search(text):
        raise ValueError(
            "train_config.yaml has an alpha key. MLX reads scale, and alpha "
            "160 is already expressed as scale 20."
        )
    lines = []
    in_schedule = False
    replaced = set()
    for line in text.splitlines():
        if line.startswith("lr_schedule:"):
            in_schedule = True
            lines.append(line)
            continue
        if in_schedule and line and not line[0].isspace() and not line.startswith("#"):
            in_schedule = False
        if in_schedule and line.strip().startswith("warmup:"):
            lines.append("  warmup: %s" % int(warmup))
            replaced.add("warmup")
            continue
        if in_schedule and line.strip().startswith("arguments:"):
            lines.append(
                "  arguments: [%s, %s, 1.0e-7]" % (PEAK_LR, int(iters))
            )
            replaced.add("arguments")
            continue
        if line.startswith("iters:"):
            lines.append("iters: %s" % int(iters))
            replaced.add("iters")
            continue
        if line.startswith("data:"):
            lines.append("data: %s" % yaml_quote(data))
            replaced.add("data")
            continue
        if line.startswith("adapter_path:"):
            lines.append("adapter_path: %s" % yaml_quote(adapter_path))
            replaced.add("adapter_path")
            continue
        if line.startswith("val_batches:"):
            lines.append("val_batches: %s" % int(val_batches))
            replaced.add("val_batches")
            continue
        lines.append(line)
    missing = {"warmup", "arguments", "iters", "data", "adapter_path", "val_batches"} - replaced
    if missing:
        raise ValueError("train_config.yaml is missing: %s" % ", ".join(sorted(missing)))
    rendered = "\n".join(lines) + "\n"
    if PEAK_LR not in rendered:
        raise ValueError("run config lost the %s learning-rate peak" % PEAK_LR)
    return rendered


def smoke_warmup(iters):
    """Short runs still reach the peak. A long warmup would spend the whole smoke test climbing."""
    return max(0, min(5, int(iters) // 10))


def iter_count(windows, batch, epochs):
    return max(1, int(math.ceil(float(windows) / float(max(1, batch)) * float(epochs))))


class StepLog:
    """One CSV row per reported micro-step. Val iteration in MLX is it-1.

    A resumed run appends. Opening with write mode would erase the step and
    loss that prove the resume continued.
    """

    def __init__(self, path, append=False):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.pending = {}
        appending = append and self.path.exists() and self.path.stat().st_size > 0
        self.handle = self.path.open("a" if appending else "w", encoding="utf-8", newline="")
        self.writer = csv.DictWriter(self.handle, fieldnames=LOG_FIELDS)
        if not appending:
            self.writer.writeheader()
            self.handle.flush()

    def on_val(self, info):
        step = int(info.get("iteration", 0)) + 1
        self.pending[step] = info.get("val_loss", "")

    def on_train(self, info):
        step = int(info["iteration"])
        self.writer.writerow(
            {
                "step": step,
                "train_loss": info.get("train_loss", ""),
                "val_loss": self.pending.get(step, ""),
                "learning_rate": info.get("learning_rate", ""),
                "tokens_per_second": info.get("tokens_per_second", ""),
                "peak_memory_gb": info.get("peak_memory", ""),
            }
        )
        self.handle.flush()

    def close(self):
        if not self.handle.closed:
            self.handle.flush()
            self.handle.close()


def install_loss_log(lora_mod, log):
    """run() overwrites any callback with get_reporting_callbacks from lora.py.

    Patching tuner.callbacks does not affect that name. The wrapper still
    returns a logger when report_to is empty, which is when MLX would return
    None and the per-step loss would never be recorded.
    """
    original = lora_mod.get_reporting_callbacks

    def wrapped(*args, **kwargs):
        base = original(*args, **kwargs)

        class LossCallback:
            def on_train_loss_report(self, info):
                if base is not None:
                    base.on_train_loss_report(info)
                log.on_train(info)

            def on_val_loss_report(self, info):
                if base is not None:
                    base.on_val_loss_report(info)
                log.on_val(info)

        return LossCallback()

    lora_mod.get_reporting_callbacks = wrapped


def song_id_digest(paths):
    """Hash song ids only. Lyric text stays out of the resume record."""
    digest = hashlib.sha256()
    for path in paths:
        digest.update(Path(path).name.encode("utf-8"))
        digest.update(b"\0")
        with Path(path).open(encoding="utf-8") as handle:
            for line in handle:
                if not line.strip():
                    continue
                song_id = json.loads(line).get("song_id") or ""
                digest.update(str(song_id).encode("utf-8"))
                digest.update(b"\n")
    return digest.hexdigest()


def count_lines(path):
    path = Path(path)
    if not path.exists():
        return 0
    count = 0
    with path.open(encoding="utf-8") as handle:
        for line in handle:
            if line.strip():
                count += 1
    return count


def claim_pid():
    PID_FILE.parent.mkdir(parents=True, exist_ok=True)
    existing = resume_lib.read_pid(PID_FILE)
    if existing is not None and resume_lib.pid_is_running(existing):
        print(
            "Training is already running as pid %s. Stop it with: kill -INT %s"
            % (existing, existing),
            file=sys.stderr,
        )
        return False
    PID_FILE.write_text("%s\n" % os.getpid(), encoding="utf-8")
    return True


def release_pid():
    existing = resume_lib.read_pid(PID_FILE)
    if existing == os.getpid() and PID_FILE.exists():
        PID_FILE.unlink()


def archive_adapter(adapter_dir, log_path, step):
    stamp = time.strftime("%Y%m%d-%H%M%S")
    adapter_dir = Path(adapter_dir)
    dest = None
    if adapter_dir.exists():
        dest = adapter_dir.parent / (
            "%s.replaced-%s-%s" % (adapter_dir.name, step, stamp)
        )
        adapter_dir.rename(dest)
    log_path = Path(log_path)
    log_dest = None
    if log_path.exists():
        log_dest = log_path.with_name(
            "%s.replaced-%s-%s" % (log_path.name, step, stamp)
        )
        log_path.rename(log_dest)
    if RESUME_MARKER.exists():
        RESUME_MARKER.unlink()
    return dest, log_dest


def install_stop_flag(control):
    def handle(signum, frame):
        control["hits"] = int(control.get("hits") or 0) + 1
        control["stop"] = True
        print(
            "\nStop requested. This step will finish, then the checkpoint is saved.",
            flush=True,
        )
        if control["hits"] >= 2:
            raise KeyboardInterrupt

    signal.signal(signal.SIGINT, handle)
    signal.signal(signal.SIGTERM, handle)


def iterate_from_cursor(dataset, batch_size, max_seq_length, seed, skip, comm_group=None):
    """Same batch order as mlx-lm, starting after `skip` micro-steps.

    Skipped positions are not tokenized. A resume does not replay the run
    from the first song.
    """
    import numpy as np
    import mlx.core as mx
    from mlx_lm.cli_ui import rprint
    from mlx_lm.tuner.datasets import CacheDataset

    if isinstance(dataset, CacheDataset):
        len_fn = lambda idx: dataset.itemlen(idx)
    else:
        len_fn = lambda idx: len(dataset[idx][0])
    order = sorted(range(len(dataset)), key=len_fn)
    if len(dataset) < batch_size:
        raise ValueError(
            "Dataset must have at least batch_size=%s examples but only has %s."
            % (batch_size, len(dataset))
        )
    if comm_group is not None:
        offset = comm_group.rank()
        stride = comm_group.size()
    else:
        offset = 0
        stride = 1
    if batch_size % stride != 0:
        raise ValueError("The batch size must be divisible by the number of workers")
    batch_idx = [
        order[i + offset : i + offset + batch_size : stride]
        for i in range(0, len(order) - batch_size + 1, batch_size)
    ]
    rng = np.random.RandomState(int(seed))
    produced = 0
    while True:
        indices = rng.permutation(len(batch_idx))
        for index in indices:
            if produced < int(skip):
                produced += 1
                continue
            batch = [dataset[j] for j in batch_idx[index]]
            if len(batch[0]) == 2:
                batch, offsets = zip(*batch)
            else:
                offsets = [0] * len(batch)
            lengths = [len(item) for item in batch]
            if max(lengths) > max_seq_length:
                rprint(
                    "[WARNING] Some sequences are longer than %s tokens. "
                    "The longest sentence %s will be truncated to %s."
                    % (max_seq_length, max(lengths), max_seq_length)
                )
            pad_to = 32
            max_length_in_batch = 1 + pad_to * ((max(lengths) + pad_to - 1) // pad_to)
            max_length_in_batch = min(max_length_in_batch, max_seq_length)
            batch_arr = np.zeros((batch_size // stride, max_length_in_batch), np.int32)
            for column in range(batch_size // stride):
                truncated = min(lengths[column], max_seq_length)
                batch_arr[column, :truncated] = batch[column][:truncated]
                lengths[column] = truncated
            produced += 1
            yield mx.array(batch_arr), mx.array(list(zip(offsets, lengths)))


def json_number(value):
    if value is None or value == "":
        return None
    if hasattr(value, "item"):
        value = value.item()
    return float(value)


def atomic_safetensors(path, arrays):
    import mlx.core as mx

    path = Path(path)
    temporary = path.with_suffix(".tmp.safetensors")
    mx.save_safetensors(str(temporary), arrays)
    actual = temporary if temporary.exists() else Path(str(temporary) + ".safetensors")
    actual.replace(path)


def save_training_state(model, optimizer, adapter_dir, step, info, fingerprint, grad_accum=None):
    import mlx.core as mx
    from mlx.utils import tree_flatten

    adapter_dir = Path(adapter_dir)
    adapter_dir.mkdir(parents=True, exist_ok=True)
    weights_name = "%07d_adapters.safetensors" % step
    opt_name = "%07d_optimizer.safetensors" % step
    rng_name = "%07d_rng.safetensors" % step
    grad_name = "%07d_grad.safetensors" % step
    adapter_weights = dict(tree_flatten(model.trainable_parameters()))
    mx.eval(adapter_weights)
    atomic_safetensors(adapter_dir / weights_name, adapter_weights)
    atomic_safetensors(adapter_dir / "adapters.safetensors", adapter_weights)
    optimizer_step = None
    flat = {}
    for key, value in tree_flatten(optimizer.state):
        if key == "step":
            optimizer_step = int(value.item())
            continue
        flat[key] = value
    opt_saved = None
    if flat:
        mx.eval(flat)
        atomic_safetensors(adapter_dir / opt_name, flat)
        opt_saved = opt_name
    rng_state = (
        mx.random.state[0]
        if hasattr(mx.random.state, "__getitem__") and not isinstance(mx.random.state, mx.array)
        else mx.random.state
    )
    mx.eval(rng_state)
    atomic_safetensors(adapter_dir / rng_name, {"state": rng_state})
    grad_saved = None
    if grad_accum is not None:
        flat_grad = dict(tree_flatten(grad_accum))
        mx.eval(flat_grad)
        atomic_safetensors(adapter_dir / grad_name, flat_grad)
        grad_saved = grad_name
    payload = dict(fingerprint)
    payload.update(
        {
            "step": int(step),
            "train_loss": json_number(info.get("train_loss")),
            "val_loss": json_number(info.get("val_loss")),
            "learning_rate": json_number(info.get("learning_rate")),
            "adapter_weights": weights_name,
            "optimizer_state": opt_saved,
            "rng_state": rng_name,
            "grad_accum": grad_saved,
            "optimizer_step": optimizer_step,
            "batch_cursor": int(step),
            "completed": int(step) >= int(fingerprint["iters_total"]),
        }
    )
    # JSON is last. A crash while the safetensors are written keeps the previous state.
    resume_lib.atomic_write_json(adapter_dir / resume_lib.STATE_NAME, payload)
    return payload


def restore_training_state(model, optimizer, adapter_dir, state):
    """Load weights, AdamW moments, the random state, and any open grad buffer.

    Returns the grad buffer, or None when the saved step was an optimizer update.
    A missing file raises. The caller must not start the loop at step 1.
    """
    import mlx.core as mx
    from mlx.utils import tree_map_with_path

    adapter_dir = Path(adapter_dir)
    if state.get("optimizer_step") is None or not state.get("adapter_weights") or not state.get("rng_state"):
        raise RuntimeError(
            "Checkpoint %s has no optimizer step, weights, or RNG. Refusing to start from step 1."
            % (adapter_dir / resume_lib.STATE_NAME)
        )
    weights = adapter_dir / state["adapter_weights"]
    rng_file = adapter_dir / state["rng_state"]
    missing = [str(path) for path in (weights, rng_file) if not path.exists()]
    opt_file = None
    if state.get("optimizer_state"):
        opt_file = adapter_dir / state["optimizer_state"]
        if not opt_file.exists():
            missing.append(str(opt_file))
    grad_file = None
    if state.get("grad_accum"):
        grad_file = adapter_dir / state["grad_accum"]
        if not grad_file.exists():
            missing.append(str(grad_file))
    if missing:
        raise RuntimeError(
            "Checkpoint files are missing (%s). Refusing to start from step 1."
            % ", ".join(missing)
        )
    model.load_weights(str(weights), strict=False)
    trainable = model.trainable_parameters()
    mx.eval(trainable)
    if opt_file is not None:
        optimizer.init(trainable)
        flat_opt = mx.load(str(opt_file))
        optimizer.state = tree_map_with_path(
            lambda path, val: flat_opt.get(path, val),
            optimizer.state,
        )
        optimizer.state["step"] = mx.array(int(state["optimizer_step"]), mx.uint64)
        optimizer._initialized = True
    else:
        optimizer.state = {"step": mx.array(int(state["optimizer_step"]), mx.uint64)}
        optimizer._initialized = False
    rng = mx.load(str(rng_file))
    if hasattr(mx.random.state, "__getitem__") and not isinstance(mx.random.state, mx.array):
        mx.random.state[0][:] = rng["state"]
    else:
        mx.random.state = rng["state"]
    mx.eval(mx.random.state)
    if grad_file is None:
        return None
    flat_grad = mx.load(str(grad_file))
    return tree_map_with_path(
        lambda path, val: flat_grad.get(path, val),
        trainable,
    )


def write_initial_state(adapter_dir, fingerprint):
    payload = dict(fingerprint)
    payload.update(
        {
            "step": 0,
            "train_loss": None,
            "val_loss": None,
            "learning_rate": None,
            "adapter_weights": None,
            "optimizer_state": None,
            "rng_state": None,
            "optimizer_step": None,
            "batch_cursor": 0,
            "grad_accum": None,
            "completed": False,
        }
    )
    resume_lib.atomic_write_json(Path(adapter_dir) / resume_lib.STATE_NAME, payload)


def loop_train(
    model,
    optimizer,
    train_dataset,
    val_dataset=None,
    args=None,
    loss=None,
    iterate_batches=None,
    training_callback=None,
):
    """MLX's train loop, plus a step counter that survives a stop.

    Stock mlx-lm saves adapter weights and then starts the next launch at
    step 1. This loop saves the optimizer, the random state, and the step,
    and the next launch continues at step + 1.
    """
    import mlx.core as mx
    import mlx.nn as nn
    from functools import partial
    from mlx.nn.utils import average_gradients
    from mlx.utils import tree_map
    from mlx_lm.tuner.trainer import (
        TrainingArgs,
        _clear_cache,
        default_loss,
        evaluate,
        grad_checkpoint,
    )
    from mlx_lm.utils import maybe_set_recommended_wired_limit

    maybe_set_recommended_wired_limit()
    control = loop_train.control
    if args is None:
        args = TrainingArgs()
    if loss is None:
        loss = default_loss
    if args.grad_checkpoint:
        grad_checkpoint(model.layers[0])

    start = int(control["start_step"])
    fingerprint = control["fingerprint"]
    iters_total = int(fingerprint["iters_total"])
    adapter_dir = Path(control["adapter"])
    if start >= iters_total:
        print("Saved step %s already completed this run." % start)
        return
    grad_accum = None
    if start > 0:
        grad_accum = restore_training_state(model, optimizer, adapter_dir, control["state"])
        print(
            "Resuming from step %s loss %s. Next step is %s."
            % (start, control["state"].get("train_loss"), start + 1),
            flush=True,
        )
    elif control.get("stop"):
        print("Stopped before the first step. No weights were saved.")
        return
    else:
        write_initial_state(adapter_dir, fingerprint)

    loss_value_and_grad = nn.value_and_grad(model, loss)
    grad_accum_steps = args.grad_accumulation_steps
    state = [model.state, optimizer.state, mx.random.state]

    @partial(mx.compile, inputs=state, outputs=state)
    def step(batch, prev_grad, do_update):
        (lvalue, toks), grad = loss_value_and_grad(model, *batch)
        if prev_grad is not None:
            grad = tree_map(lambda x, y: x + y, grad, prev_grad)
        if do_update:
            grad = average_gradients(grad)
            if grad_accum_steps > 1:
                grad = tree_map(lambda x: x / grad_accum_steps, grad)
            optimizer.update(model, grad)
            grad = None
        return lvalue, toks, grad

    model.train()
    losses = 0
    n_tokens = 0
    steps = 0
    train_time = 0
    world = mx.distributed.init()
    world_size = world.size()
    batches = iterate_from_cursor(
        train_dataset,
        args.batch_size,
        args.max_seq_length,
        fingerprint["seed"],
        start,
        world,
    )

    class Bridge:
        def on_train_loss_report(self, info):
            if training_callback is not None:
                training_callback.on_train_loss_report(info)
            control["last"] = dict(info)

        def on_val_loss_report(self, info):
            if training_callback is not None:
                training_callback.on_val_loss_report(info)
            control["last_val"] = dict(info)

    bridge = Bridge()
    try:
        for it, batch in zip(range(start + 1, iters_total + 1), batches):
            tic = time.perf_counter()
            if val_dataset is not None and (
                it == 1 or it % args.steps_per_eval == 0 or it == iters_total
            ):
                val_tic = time.perf_counter()
                val_loss = evaluate(
                    model=model,
                    dataset=val_dataset,
                    loss=loss,
                    batch_size=args.batch_size,
                    num_batches=args.val_batches,
                    max_seq_length=args.max_seq_length,
                )
                val_time = time.perf_counter() - val_tic
                model.train()
                bridge.on_val_loss_report(
                    {"iteration": it - 1, "val_loss": val_loss, "val_time": val_time}
                )
                tic = time.perf_counter()
            lvalue, toks, grad_accum = step(
                batch,
                grad_accum,
                it % grad_accum_steps == 0,
            )
            losses += lvalue
            n_tokens += toks
            steps += 1
            mx.eval(state, losses, n_tokens, grad_accum)
            _clear_cache(args.clear_cache_threshold)
            train_time += time.perf_counter() - tic
            if it % args.steps_per_report == 0 or it == iters_total:
                train_loss = mx.distributed.all_sum(losses, stream=mx.cpu).item()
                train_loss /= steps * world_size
                n_tokens = mx.distributed.all_sum(n_tokens, stream=mx.cpu).item()
                learning_rate = optimizer.learning_rate.item()
                tokens_sec = float(n_tokens) / train_time if train_time else 0.0
                peak_mem = mx.get_peak_memory() / 1e9
                bridge.on_train_loss_report(
                    {
                        "iteration": it,
                        "train_loss": train_loss,
                        "learning_rate": learning_rate,
                        "iterations_per_second": (
                            args.steps_per_report / train_time if train_time else 0.0
                        ),
                        "tokens_per_second": tokens_sec,
                        "trained_tokens": 0,
                        "peak_memory": peak_mem,
                    }
                )
                print(
                    "step %s  loss %.6f  lr %s" % (it, train_loss, learning_rate),
                    flush=True,
                )
                losses = 0
                n_tokens = 0
                steps = 0
                train_time = 0
            need_save = (
                it % args.steps_per_save == 0
                or control.get("stop")
                or it == iters_total
            )
            if need_save and control.get("last"):
                info = dict(control["last"])
                val = control.get("last_val")
                if val is not None and int(val.get("iteration", -2)) + 1 == it:
                    info["val_loss"] = val.get("val_loss")
                save_training_state(
                    model, optimizer, adapter_dir, it, info, fingerprint, grad_accum
                )
                print("saved step %s" % it, flush=True)
            if control.get("stop"):
                print(
                    "Stopped at step %s. Resume with: %s"
                    % (it, resume_lib.resume_command(control["smoke"])),
                    flush=True,
                )
                return
    except KeyboardInterrupt:
        print(
            "Interrupted during a step. That step was not saved. "
            "Resume uses the last saved checkpoint.",
            flush=True,
        )


def train_in_process(run_config, log_path, control):
    if not claim_pid():
        return 1
    try:
        import mlx_lm.lora as lora_mod
    except ImportError:
        release_pid()
        print(INSTALL_HELP, file=sys.stderr)
        return 1
    import yaml

    # Step 0 lands before the log is opened. A crash while the weights load
    # then refuses the next launch instead of wiping the log and starting at step 1.
    if int(control["start_step"]) == 0:
        write_initial_state(control["adapter"], control["fingerprint"])
    log = StepLog(log_path, append=int(control["start_step"]) > 0)
    control["log"] = log
    control["hits"] = 0
    control["stop"] = False
    install_stop_flag(control)
    try:
        install_loss_log(lora_mod, log)
        loop_train.control = control
        lora_mod.train = loop_train
        with run_config.open(encoding="utf-8") as handle:
            loaded = yaml.safe_load(handle)
        args = dict(lora_mod.CONFIG_DEFAULTS)
        args.update(loaded)
        args["train"] = True
        args["resume_adapter_file"] = None
        os.environ["TOKENIZERS_PARALLELISM"] = "true"
        print("pid: %s" % os.getpid(), flush=True)
        print("pid file: %s" % PID_FILE, flush=True)
        print("stop safely: kill -INT %s" % os.getpid(), flush=True)
        print("one Ctrl-C also stops safely after the current step", flush=True)
        print('watch: tail -f "%s"' % log_path, flush=True)
        try:
            lora_mod.run(types.SimpleNamespace(**args))
        except RuntimeError as exc:
            print(str(exc), file=sys.stderr)
            return 1
    finally:
        log.close()
        release_pid()
    return 0


def require_songs():
    missing = [str(path) for path in SONG_FILES.values() if not path.exists()]
    if missing:
        print("Missing song files:", file=sys.stderr)
        for path in missing:
            print("  %s" % path, file=sys.stderr)
        return False
    return True


def tally_windows(records, line_cap):
    songs = 0
    windows = 0
    prefix = ""
    for record in records:
        produced = windows_for_record(record, line_cap=line_cap)
        if not produced:
            continue
        songs += 1
        windows += len(produced)
        if not prefix:
            prefix = produced[0]["messages"][0]["content"].split("\n", 1)[0]
    return songs, windows, prefix


def prepare_smoke(seed, write=True):
    train_records = sample_songs(SONG_FILES["train"], SMOKE_SONGS, seed, pin=True)
    if len(train_records) != SMOKE_SONGS:
        print(
            "Smoke wanted %d eligible train songs and found %d."
            % (SMOKE_SONGS, len(train_records)),
            file=sys.stderr,
        )
        return None
    valid_records = sample_songs(SONG_FILES["valid"], SMOKE_SIDE, seed, pin=False)
    test_records = sample_songs(SONG_FILES["test"], SMOKE_SIDE, seed, pin=False)
    if write:
        train_songs, train_windows, prefix = write_windows(
            train_records, SMOKE_DATA / "train.jsonl", SMOKE_LINE_CAP
        )
        _, valid_windows, _ = write_windows(
            valid_records, SMOKE_DATA / "valid.jsonl", SMOKE_LINE_CAP
        )
        _, test_windows, _ = write_windows(
            test_records, SMOKE_DATA / "test.jsonl", SMOKE_LINE_CAP
        )
    else:
        train_songs, train_windows, prefix = tally_windows(train_records, SMOKE_LINE_CAP)
        _, valid_windows, _ = tally_windows(valid_records, SMOKE_LINE_CAP)
        _, test_windows, _ = tally_windows(test_records, SMOKE_LINE_CAP)
    if write and valid_windows == 0:
        valid_windows = copy_one_window(
            SMOKE_DATA / "train.jsonl", SMOKE_DATA / "valid.jsonl"
        )
    if write and test_windows == 0:
        test_windows = copy_one_window(
            SMOKE_DATA / "train.jsonl", SMOKE_DATA / "test.jsonl"
        )
    artists = sorted({record.get("artist") or "" for record in train_records})
    return {
        "songs": train_songs,
        "windows": train_windows,
        "valid_windows": valid_windows,
        "test_windows": test_windows,
        "prefix": prefix,
        "artists": artists,
        "data": SMOKE_DATA,
        "adapter": SMOKE_ADAPTER,
        "log": SMOKE_LOG,
        "val_batches": 2,
    }


def prepare_full(write):
    summary = {}
    prefix = ""
    for name, src in SONG_FILES.items():
        songs, windows, one_prefix = stream_windows(
            src, FULL_DATA / ("%s.jsonl" % name), None, write
        )
        summary[name] = {"songs": songs, "windows": windows}
        if name == "train" and one_prefix:
            prefix = one_prefix
    if write:
        if summary["valid"]["windows"] == 0:
            summary["valid"]["windows"] = copy_one_window(
                FULL_DATA / "train.jsonl", FULL_DATA / "valid.jsonl"
            )
        if summary["test"]["windows"] == 0:
            summary["test"]["windows"] = copy_one_window(
                FULL_DATA / "train.jsonl", FULL_DATA / "test.jsonl"
            )
    return {
        "songs": summary["train"]["songs"],
        "windows": summary["train"]["windows"],
        "valid_windows": summary["valid"]["windows"],
        "test_windows": summary["test"]["windows"],
        "prefix": prefix,
        "artists": [],
        "data": FULL_DATA,
        "adapter": FULL_ADAPTER,
        "log": FULL_LOG,
        "val_batches": None,
    }


def song_paths():
    return [SONG_FILES["train"], SONG_FILES["valid"], SONG_FILES["test"]]


def mode_name(smoke):
    return "smoke" if smoke else "full"


def adapter_dir_for(smoke):
    return SMOKE_ADAPTER if smoke else FULL_ADAPTER


def data_dir_for(smoke):
    return SMOKE_DATA if smoke else FULL_DATA


def chats_ready(data_dir, windows):
    """True when the chat files already match the saved window count."""
    try:
        expected = int(windows)
    except (TypeError, ValueError):
        return False
    if expected <= 0:
        return False
    data_dir = Path(data_dir)
    return (
        count_lines(data_dir / "train.jsonl") == expected
        and count_lines(data_dir / "valid.jsonl") > 0
        and count_lines(data_dir / "test.jsonl") > 0
    )


def plan_from_checkpoint(state, smoke):
    data = data_dir_for(smoke)
    return {
        "songs": None,
        "windows": int(state["train_windows"]),
        "valid_windows": count_lines(data / "valid.jsonl"),
        "test_windows": count_lines(data / "test.jsonl"),
        "prefix": "",
        "artists": None,
        "data": data,
        "adapter": adapter_dir_for(smoke),
        "log": FULL_LOG,
        "val_batches": 2 if smoke else None,
        "reused": True,
    }


def make_fingerprint(digest, windows, iters, seed, smoke, batch, max_seq, accum):
    return {
        "song_digest": digest,
        "train_windows": int(windows),
        "iters_total": int(iters),
        "seed": int(seed),
        "mode": mode_name(smoke),
        "batch_size": int(batch),
        "max_seq_length": int(max_seq),
        "grad_accumulation_steps": int(accum),
    }


def stray_weights(adapter_dir):
    """Weights with no resume_state.json. The step cannot be guessed."""
    adapter_dir = Path(adapter_dir)
    if not adapter_dir.exists():
        return False
    if (adapter_dir / "adapters.safetensors").exists():
        return True
    return any(adapter_dir.glob("*_adapters.safetensors"))


def unsaved_note(state, log_path):
    if not state or resume_lib.has_weights(state):
        return ""
    rows = resume_lib.read_csv(log_path)
    if not rows:
        return ""
    return (
        "The log has %d row(s) that were not checkpointed. Those steps cannot be resumed."
        % len(rows)
    )


def other_mode_message(smoke):
    other_smoke = not smoke
    other = resume_lib.load_state(resume_lib.state_path(adapter_dir_for(other_smoke)))
    if other is None:
        return ""
    return (
        "The %s run has saved state at step %s. Both runs share out/training_log.csv.\n"
        "Resume that run with: %s\n"
        "Pass --fresh to move both checkpoints aside and start over."
        % (
            mode_name(other_smoke),
            resume_lib._step(other),
            resume_lib.resume_command(other_smoke),
        )
    )


def running_pid():
    existing = resume_lib.read_pid(PID_FILE)
    if existing is not None and resume_lib.pid_is_running(existing):
        return existing
    return None


def archive_fresh(smoke, state):
    step = resume_lib._step(state) if state else 0
    dest, log_dest = archive_adapter(adapter_dir_for(smoke), FULL_LOG, step)
    if dest is not None:
        print("moved checkpoint aside: %s" % dest)
    if log_dest is not None:
        print("moved log aside: %s" % log_dest)
    other_dir = adapter_dir_for(not smoke)
    if other_dir.exists():
        other_state = resume_lib.load_state(resume_lib.state_path(other_dir))
        other_step = resume_lib._step(other_state) if other_state else 0
        other_dest, _ = archive_adapter(other_dir, FULL_LOG, other_step)
        if other_dest is not None:
            print("moved the other checkpoint aside: %s" % other_dest)


def print_plan(plan, iters, warmup, batch, accum, epochs, dry_run, smoke, pilot, max_seq=384):
    print("model: mlx-community/Qwen2.5-3B-Instruct-4bit")
    print("mode: %s" % ("smoke" if smoke else "full"))
    if plan["songs"] is None:
        print("train songs: unchanged")
    else:
        print("train songs: %d" % plan["songs"])
    print("train windows: %d" % plan["windows"])
    print("valid windows: %d" % plan["valid_windows"])
    print("test windows: %d" % plan["test_windows"])
    print("epochs: %s" % epochs)
    print("batch_size: %s" % batch)
    print("grad_accumulation_steps: %s" % accum)
    print("effective_batch: %s" % (batch * accum))
    print("iters: %d (one iter is one micro-step)" % iters)
    print("learning_rate peak: %s" % PEAK_LR)
    print("warmup: %s" % warmup)
    print("lora rank: 8")
    print("lora alpha: 160 (MLX scale 20)")
    print("max_seq_length: %s" % max_seq)
    print("save_every: 500")
    print("data: %s" % plan["data"])
    print("adapter: %s" % plan["adapter"])
    print("log: %s" % plan["log"])
    if plan["prefix"]:
        print("voice prefix on the first window: %s" % plan["prefix"])
    if smoke and plan.get("artists") is not None:
        pinned = [name for name in PIN_ARTISTS if name in plan["artists"]]
        if PIN_FALLBACK in plan["artists"] and "Young Thug" not in plan["artists"]:
            pinned.append(PIN_FALLBACK)
        print("pinned voices in the draw: %s" % ", ".join(pinned))
    if smoke:
        print("smoke step ceiling: %d" % SMOKE_STEP_CEILING)
        print(
            "Step budget is %d. After the 4-bit weights are cached, that budget "
            "is what keeps the smoke run under 15 minutes. The first launch also "
            "downloads about 1.7GB, which sits outside that budget."
            % SMOKE_STEP_CEILING
        )
    if plan.get("reused"):
        print("chats: existing window files kept")
    if pilot:
        print("--pilot is 20 optimizer steps on the full window set.")
        print("--smoke is the 20-song pipeline test.")
    if dry_run:
        print("dry-run: config written, training not started")
    else:
        print("training in-process via mlx_lm.lora.run so every step hits the CSV")


def _warmup_for(smoke, configured_warmup, iters):
    if smoke:
        return smoke_warmup(iters)
    if configured_warmup >= iters:
        return max(0, iters // 10)
    return configured_warmup


def _prepare(smoke, seed, write):
    if smoke:
        return prepare_smoke(seed, write=write)
    return prepare_full(write=write)


def list_voices_main():
    """Write every voice token from the leak-checked songs. Does not train."""
    missing = [str(path) for path in SONG_FILES.values() if not path.exists()]
    if missing:
        print("Missing song files:", file=sys.stderr)
        for path in missing:
            print(path, file=sys.stderr)
        return 1
    rows = write_voice_inventory(SONG_FILES, SONG_DIR)
    reliable = sum(1 for row in rows if row["reliable"])
    print("voice tokens: %d" % len(rows))
    print(
        "reliable (at least %d train lines and one window): %d"
        % (RELIABLE_VOICE_LINES, reliable)
    )
    print("flagged: %d" % (len(rows) - reliable))
    print("tokens: %s" % (SONG_DIR / "voices.txt"))
    print("report: %s" % (SONG_DIR / "voice_tokens.md"))
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description="Train the Qwen2.5 lyric LoRA on this Mac.")
    parser.add_argument("--config", type=Path, default=CONFIG)
    parser.add_argument(
        "--list-voices",
        action="store_true",
        help="Write out/voices.txt from the leak-checked songs and flag artists under 200 train lines. Does not train.",
    )
    parser.add_argument(
        "--smoke",
        action="store_true",
        help="Train on 20 line-capped songs. Sized to finish in under 15 minutes once the weights are cached.",
    )
    parser.add_argument(
        "--pilot",
        action="store_true",
        help="Cap the full window set at 20 optimizer steps. This is not the 20-song smoke test.",
    )
    parser.add_argument("--epochs", type=float, default=None, help="Passes over the train windows.")
    parser.add_argument("--dry-run", action="store_true", help="Write the run config and do not train.")
    parser.add_argument("--seed", type=int, default=7)
    parser.add_argument(
        "--resume",
        action="store_true",
        help="Continue from resume_state.json. The next logged step is the saved step plus one.",
    )
    parser.add_argument(
        "--fresh",
        action="store_true",
        help="Move an existing checkpoint and log aside, then start at step 1.",
    )
    parser.add_argument(
        "--resume-status",
        action="store_true",
        help="Print the checkpoint step and loss. Does not train.",
    )
    parser.add_argument(
        "--check-resume",
        action="store_true",
        help="Compare the saved step and loss with the next logged row. Does not train.",
    )
    args = parser.parse_args(argv)
    if args.list_voices:
        return list_voices_main()
    if args.smoke and args.pilot:
        print("Use --smoke or --pilot.", file=sys.stderr)
        return 1
    if args.check_resume:
        code, text = resume_lib.check_resume(
            FULL_LOG,
            resume_lib.load_state(RESUME_MARKER),
        )
        print(text)
        return code
    if args.resume_status:
        state = resume_lib.load_state(resume_lib.state_path(adapter_dir_for(args.smoke)))
        print(resume_lib.status_text(state, args.smoke))
        return 0

    pid = running_pid()
    if pid is not None:
        print(
            "Training is already running as pid %s. Stop it with: kill -INT %s"
            % (pid, pid),
            file=sys.stderr,
        )
        return 1

    state = resume_lib.load_state(resume_lib.state_path(adapter_dir_for(args.smoke)))
    if state is None and not args.resume and not args.fresh and stray_weights(adapter_dir_for(args.smoke)):
        print(
            "Adapter weights exist without %s. Refusing to guess a step. "
            "Pass --fresh to move them aside."
            % resume_lib.STATE_NAME
        )
        return 1
    if not args.fresh:
        other = other_mode_message(args.smoke)
        if other:
            print(other)
            return 1
    action, message = resume_lib.decide(state, args.resume, args.fresh, args.smoke)
    if action in ("refuse", "finished"):
        if message:
            print(message)
        note = unsaved_note(state, FULL_LOG)
        if note:
            print(note)
        return 1

    if args.fresh:
        if message:
            print(message)
        if args.dry_run:
            print("dry-run: checkpoint left in place.")
        else:
            archive_fresh(args.smoke, state)
        state = None
        action = "start"

    if not args.config.exists():
        print("Missing %s" % args.config, file=sys.stderr)
        return 1
    if not require_songs():
        return 1
    config_text = args.config.read_text(encoding="utf-8")
    if ALPHA_KEY.search(config_text):
        print(
            "Remove the alpha key from the config. MLX reads scale.",
            file=sys.stderr,
        )
        return 1
    batch = int(yaml_top_number(config_text, "batch_size", 1))
    accum = int(yaml_top_number(config_text, "grad_accumulation_steps", 8))
    max_seq = int(yaml_top_number(config_text, "max_seq_length", 384))
    configured_warmup = int(yaml_schedule_warmup(config_text, 100))
    epochs = args.epochs if args.epochs is not None else yaml_top_number(config_text, "epochs", 1)
    val_batches = int(yaml_top_number(config_text, "val_batches", 10))

    if action == "resume":
        early = {
            "mode": mode_name(args.smoke),
            "seed": int(args.seed),
            "batch_size": batch,
            "max_seq_length": max_seq,
            "grad_accumulation_steps": accum,
        }
        if any(state.get(key) != early[key] for key in early):
            print(resume_lib.mismatch_report(state, early))
            print("Windows were not counted.")
            return 1

    digest = song_id_digest(song_paths())
    reused = (
        action == "resume"
        and digest == state.get("song_digest")
        and chats_ready(data_dir_for(args.smoke), state.get("train_windows"))
    )
    if reused:
        plan = plan_from_checkpoint(state, args.smoke)
    else:
        # A resume counts first. Chats are rewritten only after the fingerprint matches.
        # A full dry-run counts without writing. A smoke dry-run still writes its tiny set.
        write = action != "resume" and (args.smoke or not args.dry_run)
        plan = _prepare(args.smoke, args.seed, write)
        if plan is None:
            return 1

    if action != "resume":
        if args.smoke:
            epochs = 1 if args.epochs is None else epochs
            if plan["windows"] > SMOKE_STEP_CEILING or plan["windows"] < 1:
                print(
                    "Smoke windows %d are outside 1..%d."
                    % (plan["windows"], SMOKE_STEP_CEILING),
                    file=sys.stderr,
                )
                return 1
        elif plan["windows"] < 1:
            print("No trainable windows in out/train.jsonl.", file=sys.stderr)
            return 1
    elif args.smoke and args.epochs is None:
        epochs = 1

    iters = iter_count(plan["windows"], batch, epochs)
    if args.pilot:
        iters = min(iters, 20 * max(1, accum))
    if plan["val_batches"] is not None:
        val_batches = plan["val_batches"]
    warmup = max(1, (iters // max(1, accum)) // 10) if args.pilot else _warmup_for(args.smoke, configured_warmup, iters)
    fingerprint = make_fingerprint(
        digest, plan["windows"], iters, args.seed, args.smoke, batch, max_seq, accum
    )
    if action == "resume" and not resume_lib.same_run(state, fingerprint):
        print(resume_lib.mismatch_report(state, fingerprint))
        return 1

    if action == "resume" and not reused and not args.dry_run:
        plan = _prepare(args.smoke, args.seed, True)
        if plan is None or plan["windows"] < 1:
            print("No trainable windows to resume.", file=sys.stderr)
            return 1
        iters = iter_count(plan["windows"], batch, epochs)
        if args.pilot:
            iters = min(iters, 20 * max(1, accum))
        warmup = max(1, (iters // max(1, accum)) // 10) if args.pilot else _warmup_for(args.smoke, configured_warmup, iters)
        fingerprint = make_fingerprint(
            digest, plan["windows"], iters, args.seed, args.smoke, batch, max_seq, accum
        )
        if not resume_lib.same_run(state, fingerprint):
            print(resume_lib.mismatch_report(state, fingerprint))
            print("Rebuilt chats do not match the checkpoint. Refusing to train.")
            return 1

    rendered = render_run_config(
        config_text,
        iters=iters,
        warmup=warmup,
        data=plan["data"],
        adapter_path=plan["adapter"],
        val_batches=val_batches,
    )
    RUN_CONFIG.parent.mkdir(parents=True, exist_ok=True)
    RUN_CONFIG.write_text(rendered, encoding="utf-8")
    print_plan(
        plan, iters, warmup, batch, accum, epochs, args.dry_run, args.smoke, args.pilot, max_seq
    )
    print("run config: %s" % RUN_CONFIG)
    if args.dry_run:
        if action == "resume":
            step = resume_lib._step(state)
            print(
                "dry-run: would continue from step %s loss %s. Next logged step would be %s."
                % (step, state.get("train_loss"), step + 1)
            )
            print("dry-run: the log was not truncated and resume_check.json was not written.")
        return 0

    if action == "resume":
        loss_text, err = resume_lib.ensure_checkpoint_row(plan["log"], state)
        if err:
            print(err)
            return 1
        step = resume_lib._step(state)
        dropped = resume_lib.truncate_csv_to_step(plan["log"], step)
        resume_lib.atomic_write_json(
            RESUME_MARKER,
            resume_lib.marker_payload(state, loss_text),
        )
        print("before: step %s  loss %s" % (step, loss_text))
        print("dropped %d log row(s) past step %s" % (dropped, step))
        print("next logged step must be %s" % (step + 1))
        print("confirm with: .venv/bin/python train.py --check-resume")
        control = {
            "start_step": step,
            "state": state,
            "fingerprint": fingerprint,
            "adapter": plan["adapter"],
            "smoke": bool(args.smoke),
        }
    else:
        if RESUME_MARKER.exists():
            RESUME_MARKER.unlink()
        control = {
            "start_step": 0,
            "state": None,
            "fingerprint": fingerprint,
            "adapter": plan["adapter"],
            "smoke": bool(args.smoke),
        }
    return train_in_process(RUN_CONFIG, plan["log"], control)


if __name__ == "__main__":
    raise SystemExit(main())
