#!/usr/bin/env python3
"""Trainer checks that do not import MLX and do not read the lyric catalog."""

from __future__ import annotations

import csv
import json
import os
import tempfile
import unittest
from contextlib import contextmanager
from contextlib import redirect_stderr
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path

import train
from lyriclib import estimate_syllables


def song(artist, n_lines, bpm, scale, song_id, line_text="alpha beta gamma"):
    lines = [("%s %d" % (line_text, i)) for i in range(n_lines)]
    return {
        "text": "\n".join(lines),
        "artist": artist,
        "bpm": bpm,
        "scale": scale,
        "song_id": song_id,
    }


class TrainSetupTests(unittest.TestCase):
    def test_window_emits_voice_prefix(self):
        record = song("Test Artist", 8, 142, "A minor", "s1", "alpha beta gamma")
        windows = train.windows_for_record(record)
        self.assertEqual(len(windows), 1)
        user = windows[0]["messages"][0]["content"]
        body = windows[0]["messages"][1]["content"]
        self.assertTrue(user.startswith("<voice:Test Artist>"))
        self.assertIn("<bpm:140>", user)
        self.assertIn("<scale:A minor>", user)
        expected = estimate_syllables("alpha beta gamma 0")
        self.assertIn("<syl:%d>" % expected, user)
        self.assertNotIn("alpha beta", user)
        self.assertIn("alpha beta gamma 0", body)

    def test_null_bpm_and_scale_are_omitted(self):
        record = song("Test Artist", 4, None, None, "s2")
        user = train.windows_for_record(record)[0]["messages"][0]["content"]
        self.assertTrue(user.startswith("<voice:Test Artist>"))
        self.assertNotIn("<bpm:", user)
        self.assertNotIn("<scale:", user)
        self.assertNotIn("unk", user)
        self.assertIn("<syl:", user)

    def test_marker_stays_in_the_window_and_out_of_the_syllable_median(self):
        lyric = "alpha beta gamma"
        record = {
            "text": "[Verse]\n" + "\n".join([lyric] * 7),
            "artist": "Test Artist",
            "bpm": 90,
            "scale": "C major",
            "song_id": "s3",
        }
        windows = train.windows_for_record(record)
        self.assertEqual(len(windows), 1)
        body = windows[0]["messages"][1]["content"]
        self.assertTrue(body.startswith("[Verse]"))
        user = windows[0]["messages"][0]["content"]
        self.assertIn("<syl:%d>" % estimate_syllables(lyric), user)

    def test_smoke_sample_is_20_and_line_capped(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "train.jsonl"
            records = []
            records.append(song("Too Short", 2, 100, "C major", "short"))
            for i in range(25):
                records.append(song("Other", 40, 100, "C major", "o%02d" % i))
            with path.open("w", encoding="utf-8") as handle:
                for record in records:
                    handle.write(json.dumps(record) + "\n")
            chosen = train.sample_songs(path, train.SMOKE_SONGS, seed=7, pin=False)
            self.assertEqual(len(chosen), 20)
            ids = [record["song_id"] for record in chosen]
            self.assertNotIn("short", ids)
            self.assertEqual(ids, [record["song_id"] for record in train.sample_songs(path, 20, 7, pin=False)])
            capped = train.windows_for_record(chosen[0], line_cap=train.SMOKE_LINE_CAP)
            self.assertEqual(len(capped), 2)
            uncapped = train.windows_for_record(chosen[0])
            self.assertGreater(len(uncapped), 2)
            self.assertLessEqual(20 * 2, train.SMOKE_STEP_CEILING)

    def test_smoke_pins_gunna_and_young_thug(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "train.jsonl"
            records = [song("Gunna", 8, 140, "A minor", "g1", "pin line")]
            records.extend(song("Other", 8, 90, "C major", "o%02d" % i, "other line") for i in range(30))
            records.append(song("Young Thug", 8, 150, "D minor", "yt1", "pin line"))
            with path.open("w", encoding="utf-8") as handle:
                for record in records:
                    handle.write(json.dumps(record) + "\n")
            chosen = train.sample_songs(path, 20, seed=7, pin=True)
            artists = {record["artist"] for record in chosen}
            self.assertEqual(len(chosen), 20)
            self.assertIn("Gunna", artists)
            self.assertIn("Young Thug", artists)

    def test_young_stoner_life_fills_in_when_young_thug_is_absent(self):
        chosen = [song("Other", 8, 90, "C major", "o%d" % i) for i in range(20)]
        pinned = {
            "Gunna": song("Gunna", 8, 140, "A minor", "g1"),
            "Young Stoner Life": song("Young Stoner Life", 8, 130, "F minor", "ysl1"),
        }
        train.apply_pins(chosen, pinned)
        artists = [record["artist"] for record in chosen]
        self.assertEqual(len(chosen), 20)
        self.assertIn("Gunna", artists)
        self.assertIn("Young Stoner Life", artists)
        self.assertNotIn("Young Thug", artists)

    def test_csv_header_and_row(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "training_log.csv"
            log = train.StepLog(path)
            log.on_val({"iteration": 0, "val_loss": 1.5, "val_time": 0.2})
            log.on_train(
                {
                    "iteration": 1,
                    "train_loss": 2.25,
                    "learning_rate": 2.0e-5,
                    "tokens_per_second": 12.5,
                    "peak_memory": 5.5,
                }
            )
            log.close()
            with path.open(encoding="utf-8", newline="") as handle:
                rows = list(csv.reader(handle))
            self.assertEqual(rows[0], train.LOG_FIELDS)
            self.assertEqual(rows[1][0], "1")
            self.assertEqual(rows[1][1], "2.25")
            self.assertEqual(rows[1][2], "1.5")
            self.assertEqual(rows[1][5], "5.5")

    def test_config_has_required_knobs(self):
        text = train.CONFIG.read_text(encoding="utf-8")
        for key in (
            "learning_rate:",
            "epochs:",
            "batch_size:",
            "grad_accumulation_steps:",
            "rank:",
            "scale:",
            "max_seq_length:",
            "warmup:",
            "save_every: 500",
            "steps_per_report: 1",
        ):
            self.assertIn(key, text)
        self.assertIn("2.0e-5", text)
        self.assertIn("160", text)
        self.assertIn("mask_prompt: true", text)
        self.assertIn("self_attn.q_proj", text)
        self.assertIn("self_attn.v_proj", text)
        self.assertNotIn("<bpm:unk>", text)
        self.assertIsNone(train.ALPHA_KEY.search(text))
        self.assertEqual(train.yaml_top_number(text, "learning_rate", 0), 2.0e-5)
        self.assertEqual(train.yaml_top_number(text, "epochs", 0), 1)
        self.assertEqual(train.yaml_top_number(text, "batch_size", 0), 1)
        self.assertEqual(train.yaml_top_number(text, "grad_accumulation_steps", 0), 8)
        self.assertEqual(train.yaml_schedule_warmup(text, 0), 100)
        self.assertEqual(train.smoke_warmup(40), 4)
        self.assertEqual(train.smoke_warmup(4), 0)
        self.assertEqual(train.smoke_warmup(100), 5)

    def test_run_config_keeps_peak_and_sets_iters(self):
        text = train.CONFIG.read_text(encoding="utf-8")
        rendered = train.render_run_config(
            text,
            iters=40,
            warmup=4,
            data="/tmp/lyric smoke",
            adapter_path="/tmp/adapters_smoke",
            val_batches=2,
        )
        self.assertIn("arguments: [2.0e-5, 40, 1.0e-7]", rendered)
        self.assertIn("warmup: 4", rendered)
        self.assertNotIn("warmup: 100", rendered)
        self.assertIn("iters: 40", rendered)
        self.assertIn("save_every: 500", rendered)
        self.assertIn('data: "/tmp/lyric smoke"', rendered)
        self.assertIn('adapter_path: "/tmp/adapters_smoke"', rendered)
        self.assertIn("val_batches: 2", rendered)
        self.assertIsNone(train.ALPHA_KEY.search(rendered))


def write_log(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=train.LOG_FIELDS)
        writer.writeheader()
        for step, loss in rows:
            writer.writerow(
                {
                    "step": step,
                    "train_loss": loss,
                    "val_loss": "",
                    "learning_rate": "2e-05",
                    "tokens_per_second": "1",
                    "peak_memory_gb": "1",
                }
            )


def log_steps(path):
    with path.open(encoding="utf-8", newline="") as handle:
        return [row["step"] for row in csv.DictReader(handle)]


@contextmanager
def isolated_layout(tmp):
    """Point train.py at a temp tree so a test cannot touch the real adapters."""
    root = Path(tmp)
    songs = root / "songs"
    out = root / "out"
    songs.mkdir()
    out.mkdir()
    names = {
        "SONG_DIR": out,
        "FULL_DATA": out / "mlx_songs",
        "SMOKE_DATA": out / "smoke",
        "RUN_CONFIG": out / "train_config.run.yaml",
        "FULL_LOG": out / "training_log.csv",
        "SMOKE_LOG": out / "training_log.csv",
        "PID_FILE": out / "train.pid",
        "RESUME_MARKER": out / "resume_check.json",
        "FULL_ADAPTER": root / "adapters",
        "SMOKE_ADAPTER": root / "adapters_smoke",
        "SONG_FILES": {
            "train": songs / "train.jsonl",
            "valid": songs / "val.jsonl",
            "test": songs / "test.jsonl",
        },
    }
    saved = {key: getattr(train, key) for key in names}
    for key, value in names.items():
        setattr(train, key, value)
    try:
        yield names
    finally:
        for key, value in saved.items():
            setattr(train, key, value)


def write_split(paths, n_train):
    files = paths["SONG_FILES"]

    def dump(path, records):
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", encoding="utf-8") as handle:
            for record in records:
                handle.write(json.dumps(record) + "\n")

    dump(
        files["train"],
        [song("Tester", 8, 100, "C major", "id%d" % i) for i in range(n_train)],
    )
    dump(files["valid"], [song("Tester", 8, 90, "C major", "v1")])
    dump(files["test"], [song("Tester", 8, 90, "C major", "t1")])


def matching_checkpoint(paths, step, loss, n_train=4):
    write_split(paths, n_train)
    plan = train.prepare_full(write=False)
    text = train.CONFIG.read_text(encoding="utf-8")
    batch = int(train.yaml_top_number(text, "batch_size", 1))
    accum = int(train.yaml_top_number(text, "grad_accumulation_steps", 8))
    max_seq = int(train.yaml_top_number(text, "max_seq_length", 384))
    state = {
        "step": step,
        "train_loss": loss,
        "adapter_weights": "%07d_adapters.safetensors" % step,
        "completed": False,
        "song_digest": train.song_id_digest(train.song_paths()),
        "train_windows": plan["windows"],
        "iters_total": train.iter_count(plan["windows"], batch, 1),
        "seed": 7,
        "mode": "full",
        "batch_size": batch,
        "max_seq_length": max_seq,
        "grad_accumulation_steps": accum,
    }
    train.resume_lib.atomic_write_json(
        train.resume_lib.state_path(paths["FULL_ADAPTER"]),
        state,
    )
    return state


def run_main(argv):
    buffer = StringIO()
    with redirect_stdout(buffer):
        code = train.main(argv)
    return code, buffer.getvalue()


class VoiceListTests(unittest.TestCase):
    def test_list_voices_exits_before_training(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                files = paths["SONG_FILES"]

                def dump(path, records):
                    with path.open("w", encoding="utf-8") as handle:
                        for record in records:
                            handle.write(json.dumps(record) + "\n")

                ada = {
                    "text": "[Verse]\n" + "\n".join("alpha beta gamma %d" % i for i in range(7)),
                    "artist": "Ada",
                    "bpm": None,
                    "scale": None,
                    "song_id": "ada1",
                }
                dump(files["train"], [ada, song("ada", 8, 90, "C major", "ada-lower")])
                dump(files["valid"], [song("Val Only", 8, 100, "D minor", "val-only")])
                dump(files["test"], [song("Ada", 4, None, None, "ada-test")])
                paths["PID_FILE"].write_text("%d\n" % os.getpid(), encoding="utf-8")
                original = train.prepare_full

                def boom(*args, **kwargs):
                    raise AssertionError("prepare_full ran")

                train.prepare_full = boom
                try:
                    code, text = run_main(["--list-voices", "--smoke", "--pilot"])
                finally:
                    train.prepare_full = original
                self.assertEqual(code, 0)
                self.assertIn("voice tokens: 3", text)
                self.assertNotIn("alpha beta", text)
                tokens = (paths["SONG_DIR"] / "voices.txt").read_text(encoding="utf-8").splitlines()
                self.assertEqual(tokens, ["<voice:Ada>", "<voice:Val Only>", "<voice:ada>"])
                counts = json.loads((paths["SONG_DIR"] / "voice_counts.json").read_text(encoding="utf-8"))
                self.assertEqual(counts["<voice:Ada>"]["train_lines"], 7)
                self.assertEqual(counts["<voice:Ada>"]["train_windows"], 1)
                self.assertFalse(counts["<voice:Ada>"]["reliable"])
                self.assertIn("too few train lines", counts["<voice:Ada>"]["flag"])
                self.assertEqual(counts["<voice:ada>"]["train_lines"], 8)
                self.assertEqual(counts["<voice:Val Only>"]["train_lines"], 0)
                self.assertIn("no training window", counts["<voice:Val Only>"]["flag"])
                self.assertFalse((paths["FULL_ADAPTER"] / "resume_state.json").exists())
                from lyriclib import voice_example_counts

                lyric, windows = voice_example_counts(ada)
                self.assertEqual(lyric, 7)
                self.assertEqual(windows, len(train.windows_for_record(ada)))


class ResumeTests(unittest.TestCase):
    def test_decide_refuses_a_checkpoint_without_resume(self):
        state = {
            "step": 10,
            "train_loss": 1.2,
            "adapter_weights": "0000010_adapters.safetensors",
            "completed": False,
        }
        action, message = train.resume_lib.decide(state, False, False, False)
        self.assertEqual(action, "refuse")
        self.assertIn("--resume", message)
        fresh, _ = train.resume_lib.decide(state, False, True, False)
        self.assertEqual(fresh, "start")
        again, _ = train.resume_lib.decide(state, True, False, False)
        self.assertEqual(again, "resume")

    def test_completed_and_step_zero_and_both_flags_refuse(self):
        done = {
            "step": 40,
            "train_loss": 1.0,
            "adapter_weights": "0000040_adapters.safetensors",
            "completed": True,
        }
        action, message = train.resume_lib.decide(done, False, False, False)
        self.assertEqual(action, "finished")
        self.assertIn("--fresh", message)
        fresh, _ = train.resume_lib.decide(done, False, True, False)
        self.assertEqual(fresh, "start")
        started = {"step": 0, "adapter_weights": None, "completed": False}
        action, message = train.resume_lib.decide(started, False, False, False)
        self.assertEqual(action, "refuse")
        self.assertIn("--fresh", message)
        both, message = train.resume_lib.decide(done, True, True, False)
        self.assertEqual(both, "refuse")
        self.assertIn("either", message)
        missing, message = train.resume_lib.decide(None, True, False, False)
        self.assertEqual(missing, "refuse")
        self.assertIn("will not start", message)

    def test_truncate_keeps_the_checkpoint_row_and_drops_the_tail(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "training_log.csv"
            write_log(path, [(1, "2.0"), (4, "1.25"), (5, "1.10")])
            dropped = train.resume_lib.truncate_csv_to_step(path, 4)
            self.assertEqual(dropped, 1)
            self.assertEqual(log_steps(path), ["1", "4"])
            text = path.read_text(encoding="utf-8")
            self.assertTrue(text.startswith("step,train_loss"))

    def test_append_keeps_the_header_and_the_saved_step(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "training_log.csv"
            first = train.StepLog(path)
            first.on_train(
                {
                    "iteration": 4,
                    "train_loss": 1.25,
                    "learning_rate": 2.0e-5,
                    "tokens_per_second": 3,
                    "peak_memory": 5.5,
                }
            )
            first.close()
            second = train.StepLog(path, append=True)
            second.on_train(
                {
                    "iteration": 5,
                    "train_loss": 1.2,
                    "learning_rate": 2.0e-5,
                    "tokens_per_second": 3,
                    "peak_memory": 5.5,
                }
            )
            second.close()
            text = path.read_text(encoding="utf-8")
            self.assertEqual(text.count("step,train_loss"), 1)
            self.assertEqual(log_steps(path), ["4", "5"])

    def test_check_resume_compares_step_and_loss(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "training_log.csv"
            write_log(path, [(4, "1.25"), (5, "1.20")])
            marker = {
                "resumed_from_step": 4,
                "resumed_from_loss": "1.25",
                "expect_next_step": 5,
            }
            code, text = train.resume_lib.check_resume(path, marker)
            self.assertEqual(code, 0)
            self.assertIn("step 4", text)
            self.assertIn("1.25", text)
            self.assertIn("step 5", text)
            self.assertIn("1.20", text)

            write_log(path, [(4, "1.25")])
            code, text = train.resume_lib.check_resume(path, marker)
            self.assertEqual(code, 2)
            self.assertIn("not in the log yet", text)

            write_log(path, [(1, "9.0")])
            code, text = train.resume_lib.check_resume(path, marker)
            self.assertEqual(code, 1)
            self.assertIn("missing", text)

            write_log(path, [(4, "9.0"), (5, "1.0")])
            code, text = train.resume_lib.check_resume(path, marker)
            self.assertEqual(code, 1)
            self.assertIn("changed", text)

    def test_ensure_refuses_a_mismatched_loss_without_rewriting(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "training_log.csv"
            write_log(path, [(4, "9.0")])
            before = path.read_text(encoding="utf-8")
            loss, err = train.resume_lib.ensure_checkpoint_row(
                path,
                {"step": 4, "train_loss": 1.25},
            )
            self.assertIsNone(loss)
            self.assertIn("Refusing", err)
            self.assertEqual(path.read_text(encoding="utf-8"), before)

    def test_step_zero_state_blocks_a_silent_restart(self):
        with tempfile.TemporaryDirectory() as tmp:
            adapter = Path(tmp) / "adapters"
            fingerprint = train.make_fingerprint("abc", 4, 4, 7, False, 1, 384, 8)
            train.write_initial_state(adapter, fingerprint)
            state = train.resume_lib.load_state(train.resume_lib.state_path(adapter))
            action, message = train.resume_lib.decide(state, False, False, False)
            self.assertEqual(state["step"], 0)
            self.assertIsNone(state["adapter_weights"])
            self.assertEqual(action, "refuse")
            self.assertIn("--fresh", message)

    def test_main_refuses_a_checkpoint_before_scanning_songs(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                train.resume_lib.atomic_write_json(
                    train.resume_lib.state_path(paths["FULL_ADAPTER"]),
                    {
                        "step": 10,
                        "train_loss": 1.2,
                        "adapter_weights": "0000010_adapters.safetensors",
                        "completed": False,
                    },
                )
                called = {"n": 0}
                real = train.prepare_full

                def wrapped(*args, **kwargs):
                    called["n"] += 1
                    return real(*args, **kwargs)

                train.prepare_full = wrapped
                try:
                    code, output = run_main(["--dry-run", "--epochs", "1"])
                finally:
                    train.prepare_full = real
                self.assertEqual(code, 1)
                self.assertEqual(called["n"], 0)
                self.assertIn("Refusing to start over", output)
                self.assertNotIn("Missing song files", output)
                self.assertFalse(paths["RUN_CONFIG"].exists())

    def test_main_dry_run_resume_does_not_truncate_or_write_the_marker(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                matching_checkpoint(paths, 2, 1.25)
                write_log(paths["FULL_LOG"], [(2, "1.25"), (3, "1.10")])
                code, output = run_main(["--resume", "--dry-run"])
                self.assertEqual(code, 0, output)
                self.assertEqual(log_steps(paths["FULL_LOG"]), ["2", "3"])
                self.assertFalse(paths["RESUME_MARKER"].exists())
                self.assertIn("would continue from step 2 loss 1.25", output)
                self.assertIn("Next logged step would be 3", output)

    def test_main_resume_truncates_and_records_the_next_step(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                matching_checkpoint(paths, 2, 1.25)
                write_log(paths["FULL_LOG"], [(2, "1.25"), (3, "1.10")])
                captured = {}

                def fake_train(run_config, log_path, control):
                    captured["control"] = control
                    captured["append"] = int(control["start_step"]) > 0
                    return 0

                real = train.train_in_process
                train.train_in_process = fake_train
                try:
                    code, output = run_main(["--resume"])
                finally:
                    train.train_in_process = real
                self.assertEqual(code, 0, output)
                self.assertEqual(log_steps(paths["FULL_LOG"]), ["2"])
                self.assertEqual(captured["control"]["start_step"], 2)
                self.assertTrue(captured["append"])
                marker = json.loads(paths["RESUME_MARKER"].read_text(encoding="utf-8"))
                self.assertEqual(marker["resumed_from_step"], 2)
                self.assertEqual(marker["resumed_from_loss"], "1.25")
                self.assertEqual(marker["expect_next_step"], 3)
                self.assertIn("before: step 2  loss 1.25", output)
                self.assertIn("dropped 1 log row", output)

    def test_seed_mismatch_does_not_truncate(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                matching_checkpoint(paths, 2, 1.25)
                write_log(paths["FULL_LOG"], [(2, "1.25"), (3, "1.10")])
                called = {"n": 0}
                real = train.prepare_full

                def wrapped(*args, **kwargs):
                    called["n"] += 1
                    return real(*args, **kwargs)

                train.prepare_full = wrapped
                try:
                    code, output = run_main(["--resume", "--seed", "99", "--dry-run"])
                finally:
                    train.prepare_full = real
                self.assertEqual(code, 1, output)
                self.assertEqual(called["n"], 0)
                self.assertEqual(log_steps(paths["FULL_LOG"]), ["2", "3"])
                self.assertIn("Windows were not counted", output)
                self.assertFalse(paths["RESUME_MARKER"].exists())

    def test_loss_mismatch_leaves_the_log_alone(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                matching_checkpoint(paths, 2, 1.25)
                write_log(paths["FULL_LOG"], [(2, "9.0"), (3, "1.10")])
                code, output = run_main(["--resume", "--dry-run"])
                self.assertEqual(code, 0, output)
                real = train.train_in_process
                train.train_in_process = lambda *args, **kwargs: 0
                try:
                    code, output = run_main(["--resume"])
                finally:
                    train.train_in_process = real
                self.assertEqual(code, 1, output)
                self.assertIn("Refusing to resume", output)
                self.assertEqual(log_steps(paths["FULL_LOG"]), ["2", "3"])
                self.assertFalse(paths["RESUME_MARKER"].exists())

    def test_check_resume_command_does_not_need_the_corpus(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                write_log(paths["FULL_LOG"], [(4, "1.25"), (5, "1.20")])
                train.resume_lib.atomic_write_json(
                    paths["RESUME_MARKER"],
                    {
                        "resumed_from_step": 4,
                        "resumed_from_loss": "1.25",
                        "expect_next_step": 5,
                    },
                )
                code, output = run_main(["--check-resume"])
                self.assertEqual(code, 0, output)
                self.assertIn("step 4", output)
                self.assertIn("step 5", output)
                write_log(paths["FULL_LOG"], [(4, "1.25")])
                code, output = run_main(["--check-resume"])
                self.assertEqual(code, 2, output)

    def test_fresh_dry_run_does_not_move_the_checkpoint(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                matching_checkpoint(paths, 2, 1.25)
                code, output = run_main(["--fresh", "--dry-run"])
                self.assertEqual(code, 0, output)
                self.assertIn("left in place", output)
                self.assertTrue(
                    train.resume_lib.state_path(paths["FULL_ADAPTER"]).exists()
                )
                self.assertFalse(any(Path(tmp).glob("adapters.replaced-*")))

    def test_weights_without_a_state_file_refuse(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                paths["FULL_ADAPTER"].mkdir()
                (paths["FULL_ADAPTER"] / "adapters.safetensors").write_text(
                    "not a real weight file",
                    encoding="utf-8",
                )
                code, output = run_main(["--dry-run"])
                self.assertEqual(code, 1, output)
                self.assertIn("without resume_state.json", output)
                self.assertFalse(paths["RUN_CONFIG"].exists())

    def test_other_mode_shares_the_log_and_blocks_a_start(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                train.resume_lib.atomic_write_json(
                    train.resume_lib.state_path(paths["SMOKE_ADAPTER"]),
                    {
                        "step": 6,
                        "train_loss": 1.4,
                        "adapter_weights": "0000006_adapters.safetensors",
                        "completed": False,
                    },
                )
                code, output = run_main(["--dry-run"])
                self.assertEqual(code, 1, output)
                self.assertIn("--resume --smoke", output)
                self.assertIn("training_log.csv", output)

    def test_missing_mlx_does_not_plant_a_checkpoint(self):
        try:
            import mlx_lm.lora  # noqa: F401
        except ImportError:
            pass
        else:
            self.skipTest("mlx is installed")
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                control = {
                    "start_step": 0,
                    "fingerprint": train.make_fingerprint("abc", 1, 1, 7, False, 1, 384, 8),
                    "adapter": paths["FULL_ADAPTER"],
                    "smoke": False,
                }
                errors = StringIO()
                with redirect_stderr(errors):
                    code = train.train_in_process(
                        paths["RUN_CONFIG"],
                        paths["FULL_LOG"],
                        control,
                    )
                self.assertEqual(code, 1)
                self.assertIn("mlx_lm is not installed", errors.getvalue())
                self.assertFalse(train.resume_lib.state_path(paths["FULL_ADAPTER"]).exists())
                self.assertFalse(paths["PID_FILE"].exists())
                self.assertFalse(paths["FULL_LOG"].exists())

    def test_a_clean_dry_run_does_not_plant_a_checkpoint(self):
        with tempfile.TemporaryDirectory() as tmp:
            with isolated_layout(tmp) as paths:
                write_split(paths, 1)
                code, output = run_main(["--dry-run"])
                self.assertEqual(code, 0, output)
                self.assertIn("training not started", output)
                self.assertFalse(
                    train.resume_lib.state_path(paths["FULL_ADAPTER"]).exists()
                )


if __name__ == "__main__":
    unittest.main()
