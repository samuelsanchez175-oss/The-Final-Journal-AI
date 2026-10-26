#!/usr/bin/env python3
"""Train-script tests. A fake openai binary stands in for the CLI. No network call."""

from __future__ import annotations

import json
import os
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCRIPT = HERE / "train.sh"
KEY = "test-key-do-not-print"

FAKE = r"""#!/bin/bash
set -u
printf '%s\n' "$*" >> "$FAKE_OPENAI_LOG"
if [[ "${OPENAI_API_KEY:-}" == "test-key-do-not-print" ]]; then
  printf '%s\n' saw_key=1 >> "$FAKE_OPENAI_LOG"
else
  printf '%s\n' saw_key=0 >> "$FAKE_OPENAI_LOG"
fi
if [[ "$1" == "api" && "$2" == "files.create" ]]; then
  file=""
  prev=""
  for arg in "$@"; do
    if [[ "$prev" == "-f" ]]; then file="$arg"; fi
    prev="$arg"
  done
  case "$file" in
    *train*) echo '{"id":"file-train"}' ;;
    *) echo '{"id":"file-val"}' ;;
  esac
  exit 0
fi
if [[ "$1" == "api" && "$2" == "fine_tuning.jobs.create" ]]; then
  echo '{"id":"ftjob-1"}'
  exit 0
fi
if [[ "$1" == "api" && "$2" == "fine_tuning.jobs.retrieve" ]]; then
  n=0
  if [[ -f "$FAKE_COUNT" ]]; then n="$(cat "$FAKE_COUNT")"; fi
  n=$((n + 1))
  printf '%s' "$n" > "$FAKE_COUNT"
  if [[ "$n" -lt 2 ]]; then
    echo '{"id":"ftjob-1","status":"queued","estimated_finish":1999999999,"fine_tuned_model":null}'
  else
    echo '{"id":"ftjob-1","status":"succeeded","estimated_finish":null,"fine_tuned_model":"ft:gpt-4o-mini:org:v5:abc"}'
  fi
  exit 0
fi
echo "unexpected openai args: $*" >&2
exit 1
"""


def _write_jsonl(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(
            {
                "messages": [
                    {"role": "system", "content": "Write bars."},
                    {"role": "user", "content": "PREV"},
                    {"role": "assistant", "content": text},
                ]
            }
        )
        + "\n",
        encoding="utf-8",
    )


class TrainScriptTests(unittest.TestCase):
    def setUp(self) -> None:
        self._tmpdir = tempfile.TemporaryDirectory()
        self.root = Path(self._tmpdir.name)
        self.lyric = self.root / "lyric"
        self.fake_dir = self.root / "bin"
        self.fake_dir.mkdir()
        fake = self.fake_dir / "openai"
        fake.write_text(FAKE, encoding="utf-8")
        fake.chmod(fake.stat().st_mode | stat.S_IEXEC)
        self.env_file = self.root / "key.env"
        self.env_file.write_text(KEY + "\n", encoding="utf-8")
        self.fake_log = self.root / "openai-args.txt"
        self.fake_count = self.root / "openai-count.txt"
        _write_jsonl(self.lyric / "out" / "train_50k_fim.jsonl", "bar a")
        _write_jsonl(self.lyric / "out" / "val_50k_fim.jsonl", "bar b")
        _write_jsonl(self.lyric / "out" / "train_full_fim.jsonl", "bar c")
        _write_jsonl(self.lyric / "out" / "val_full_fim.jsonl", "bar d")

    def tearDown(self) -> None:
        self._tmpdir.cleanup()

    def _env(self) -> dict[str, str]:
        env = os.environ.copy()
        env["PATH"] = str(self.fake_dir) + os.pathsep + env.get("PATH", "")
        env["LYRIC_LLM_ROOT"] = str(self.lyric)
        env["OPENAI_ENV_FILE"] = str(self.env_file)
        env["POLL_SECONDS"] = "0"
        env["FAKE_OPENAI_LOG"] = str(self.fake_log)
        env["FAKE_COUNT"] = str(self.fake_count)
        env.pop("OPENAI_API_KEY", None)
        return env

    def _run(self, *args: str, env: dict[str, str] | None = None) -> subprocess.CompletedProcess:
        return subprocess.run(
            ["bash", str(SCRIPT), *args],
            check=False,
            capture_output=True,
            text=True,
            env=env or self._env(),
        )

    def _assert_key_hidden(self, completed: subprocess.CompletedProcess, *paths: Path) -> None:
        self.assertNotIn(KEY, completed.stdout)
        self.assertNotIn(KEY, completed.stderr)
        for path in paths:
            if path.is_file():
                self.assertNotIn(KEY, path.read_text(encoding="utf-8"))

    def test_bash_syntax(self) -> None:
        completed = subprocess.run(
            ["bash", "-n", str(SCRIPT)],
            check=False,
            capture_output=True,
            text=True,
        )
        self.assertEqual(completed.returncode, 0, completed.stderr)
        source = SCRIPT.read_text(encoding="utf-8")
        self.assertNotIn("set -x", source)
        code = "\n".join(line for line in source.splitlines() if not line.strip().startswith("#"))
        self.assertNotIn("out/val.jsonl", code)
        self.assertIn('{"n_epochs": 3}', source)
        self.assertIn("gpt-4o-mini", source)

    def test_50k_logs_upload_and_model_without_the_key(self) -> None:
        completed = self._run("50k")
        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertIn("train=file-train", completed.stdout)
        self.assertIn("val=file-val", completed.stdout)
        self.assertIn("job=ftjob-1", completed.stdout)
        self.assertIn("model=ft:gpt-4o-mini:org:v5:abc", completed.stdout)
        log_path = self.lyric / "out" / "finetune_50k_log.jsonl"
        rows = [json.loads(line) for line in log_path.read_text(encoding="utf-8").splitlines()]
        self.assertEqual([row["event"] for row in rows], ["upload", "upload", "job", "status", "status", "done"])
        self.assertEqual(rows[0]["file"], "out/train_50k_fim.jsonl")
        self.assertEqual(rows[1]["file"], "out/val_50k_fim.jsonl")
        self.assertEqual(rows[2]["model"], "gpt-4o-mini")
        self.assertEqual(rows[2]["n_epochs"], 3)
        self.assertEqual(rows[2]["suffix"], "v5-base-mini-50k")
        self.assertEqual(rows[-1]["fine_tuned_model"], "ft:gpt-4o-mini:org:v5:abc")
        calls = self.fake_log.read_text(encoding="utf-8")
        self.assertIn("api files.create -f out/train_50k_fim.jsonl -p fine-tune", calls)
        self.assertIn("api files.create -f out/val_50k_fim.jsonl -p fine-tune", calls)
        self.assertIn("api fine_tuning.jobs.create -t file-train -v file-val -m gpt-4o-mini", calls)
        self.assertIn('--hyperparameters {"n_epochs": 3}', calls)
        self.assertIn("--suffix v5-base-mini-50k", calls)
        self.assertIn("saw_key=1", calls)
        self._assert_key_hidden(completed, log_path, self.fake_log)

    def test_full_uses_the_full_files_and_log(self) -> None:
        completed = self._run("full")
        self.assertEqual(completed.returncode, 0, completed.stderr)
        log_path = self.lyric / "out" / "finetune_full_log.jsonl"
        rows = [json.loads(line) for line in log_path.read_text(encoding="utf-8").splitlines()]
        self.assertEqual(rows[0]["file"], "out/train_full_fim.jsonl")
        self.assertEqual(rows[1]["file"], "out/val_full_fim.jsonl")
        self.assertEqual(rows[2]["suffix"], "v5-base-mini-full")
        self.assertFalse((self.lyric / "out" / "finetune_50k_log.jsonl").exists())
        self._assert_key_hidden(completed, log_path, self.fake_log)

    def test_bad_mode_and_missing_files_do_not_call_openai(self) -> None:
        bad = self._run("nope")
        self.assertEqual(bad.returncode, 2, bad.stderr)
        self.assertIn("usage:", bad.stderr)
        self.assertFalse(self.fake_log.exists())
        self._assert_key_hidden(bad)
        empty = self.root / "empty"
        empty.mkdir()
        env = self._env()
        env["LYRIC_LLM_ROOT"] = str(empty)
        missing = self._run("50k", env=env)
        self.assertEqual(missing.returncode, 1, missing.stderr)
        self.assertIn("missing out/train_50k_fim.jsonl", missing.stderr)
        self.assertFalse(self.fake_log.exists())
        self._assert_key_hidden(missing)

    def test_missing_key_file_exits_before_openai(self) -> None:
        env = self._env()
        env["OPENAI_ENV_FILE"] = str(self.root / "absent.env")
        completed = self._run("50k", env=env)
        self.assertEqual(completed.returncode, 1, completed.stderr)
        self.assertIn("missing .env.openai", completed.stderr)
        self.assertFalse(self.fake_log.exists())
        self._assert_key_hidden(completed)

    def test_failed_job_is_logged_and_exits(self) -> None:
        fake = self.fake_dir / "openai"
        text = fake.read_text(encoding="utf-8").replace(
            '"status":"succeeded"',
            '"status":"failed"',
        )
        fake.write_text(text, encoding="utf-8")
        completed = self._run("50k")
        self.assertEqual(completed.returncode, 1, completed.stderr)
        self.assertIn("ended failed", completed.stderr)
        log_path = self.lyric / "out" / "finetune_50k_log.jsonl"
        rows = [json.loads(line) for line in log_path.read_text(encoding="utf-8").splitlines()]
        self.assertEqual(rows[-1]["status"], "failed")
        self.assertNotIn("done", [row["event"] for row in rows])
        self._assert_key_hidden(completed, log_path, self.fake_log)


if __name__ == "__main__":
    unittest.main()
