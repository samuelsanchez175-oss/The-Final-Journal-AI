#!/usr/bin/env python3
"""Write clean bars to the screen and to a dated text file.

Defaults are temperature 0.8 and top-p 0.95. A seed line is the first bar.
A topic stays in the prompt and is not a bar. BPM sets the syllable budget
(8 at 70 BPM, 14 at 140). Scale is written in the prefix only.

From tools/lyric-llm:

  .venv/bin/python generate.py --voice "Gunna" --bpm 140 --scale "A minor" \\
      --bars 16 --seed-line "Count the room before I say the number"

  .venv/bin/python generate.py --voice "Gunna" --blend "Young Thug" --mix 70 \\
      --bpm 140 --scale "A minor" --bars 16 \\
      --seed-line "Count the room before I say the number"

  .venv/bin/python generate.py --voice "Young Thug" --bpm 90 --scale "D minor" \\
      --bars 8 --topic "rain on the windshield" --temperature 1.2 --top-p 0.99
"""

from __future__ import annotations

import argparse
import os
import random
import sys
from datetime import datetime
from pathlib import Path

import infer
from lyriclib import control_prefix, tag_safe, tempo_line_syllables

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
BARS_DIR = OUT / "bars"
DEFAULT_TEMPERATURE = 0.8
DEFAULT_TOP_P = 0.95
DEFAULT_BARS = 8


class GenerateError(ValueError):
    """The request cannot be sampled."""


def _slug(text: str) -> str:
    chars = []
    for ch in (text or "").lower():
        chars.append(ch if ch.isalnum() else "-")
    parts = [part for part in "".join(chars).split("-") if part]
    return "-".join(parts)[:40] or "voice"


def dated_bars_path(directory: Path, when: datetime, voice: str, blend: str = "") -> Path:
    """YYYY-MM-DD-HHMMSS-voice.txt. A second file in the same second gets -2."""
    stamp = when.strftime("%Y-%m-%d-%H%M%S")
    name = stamp + "-" + _slug(voice)
    if blend:
        name += "-" + _slug(blend)
    path = directory / (name + ".txt")
    extra = 2
    while path.exists():
        path = directory / ("%s-%d.txt" % (name, extra))
        extra += 1
    return path


def format_bars(lines) -> str:
    """One bar per line. No numbers, scores, or headers."""
    kept = []
    for line in lines:
        text = " ".join(str(line).split())
        if text:
            kept.append(text)
    if not kept:
        return ""
    return "\n".join(kept) + "\n"


def _with_topic(prefix: str, topic: str) -> str:
    topic = " ".join((topic or "").split())
    if not topic:
        return prefix
    return prefix + "\n" + topic


def generation_request(
    voice,
    blend="",
    mix="",
    bpm=None,
    scale="",
    seed_line="",
    topic="",
    bars=DEFAULT_BARS,
    temperature=DEFAULT_TEMPERATURE,
    top_p=DEFAULT_TOP_P,
    seed=0,
):
    """Build the sampler plan. The seed line is bar 1 and is not generated again."""
    voice = " ".join(str(voice or "").split())
    blend = " ".join(str(blend or "").split())
    scale = " ".join(str(scale or "").split())
    opening = " ".join(str(seed_line or "").split())
    topic = " ".join(str(topic or "").split())
    if not voice:
        raise GenerateError("Pass --voice.")
    if tag_safe(voice).lower() == "custom":
        raise GenerateError("A custom voice stays on infer.py --exemplar.")
    if bpm is None:
        raise GenerateError("Pass --bpm.")
    try:
        bpm = float(bpm)
    except (TypeError, ValueError) as exc:
        raise GenerateError("BPM must be a number.") from exc
    if bpm <= 0:
        raise GenerateError("BPM must be above 0.")
    if not scale:
        raise GenerateError("Pass --scale, for example 'A minor'.")
    try:
        bars = int(bars)
    except (TypeError, ValueError) as exc:
        raise GenerateError("Bars must be a whole number.") from exc
    if bars < 1:
        raise GenerateError("Ask for at least one bar.")
    try:
        temperature = float(temperature)
        top_p = float(top_p)
    except (TypeError, ValueError) as exc:
        raise GenerateError("Temperature and top-p must be numbers.") from exc
    if temperature <= 0:
        raise GenerateError("Temperature must be above 0.")
    if top_p <= 0 or top_p > 1:
        raise GenerateError("Top-p must be above 0 and at most 1.")
    if blend:
        try:
            primary, secondary = infer.parse_mix(mix)
        except infer.MixError as exc:
            raise GenerateError(str(exc)) from exc
        if tag_safe(voice).lower() == tag_safe(blend).lower():
            raise GenerateError("The blend needs two different voices.")
        share = primary / 100.0
        title = "%d%% %s / %d%% %s" % (primary, voice, secondary, blend)
    else:
        if str(mix or "").strip():
            raise GenerateError("A mix needs --blend.")
        share = 1.0
        title = voice
    syl = tempo_line_syllables(bpm)
    left = _with_topic(control_prefix(voice, bpm, scale, syl), topic)
    right_voice = blend or voice
    right = _with_topic(control_prefix(right_voice, bpm, scale, syl), topic)
    return {
        "plan": {
            "left_prefix": left,
            "right_prefix": right,
            "seed_line": opening,
            "bars": bars - (1 if opening else 0),
            "seed": int(seed),
            "bpm": bpm,
            "syl": syl,
            "temperature": temperature,
            "top_p": top_p,
            "fit_syllables": True,
        },
        "job": {"title": title, "share": share},
        "opening": opening,
        "voice": voice,
        "blend": blend,
        "topic": topic,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Write clean bars to the screen and to a dated text file.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "examples:\n"
            "  .venv/bin/python generate.py --voice \"Gunna\" --bpm 140 --scale \"A minor\" \\\n"
            "      --bars 16 --seed-line \"Count the room before I say the number\"\n"
            "  .venv/bin/python generate.py --voice \"Gunna\" --blend \"Young Thug\" --mix 70 \\\n"
            "      --bpm 140 --scale \"A minor\" --bars 16 \\\n"
            "      --seed-line \"Count the room before I say the number\"\n"
            "  .venv/bin/python generate.py --voice \"Young Thug\" --bpm 90 --scale \"D minor\" \\\n"
            "      --bars 8 --topic \"rain on the windshield\" --temperature 1.2 --top-p 0.99\n"
            "\n"
            "Young Stoner Life is its own voice token."
        ),
    )
    parser.add_argument("--voice", default="", help="Artist name.")
    parser.add_argument("--blend", default="", help="Second artist. Use with --mix.")
    parser.add_argument("--mix", default="", help="Share for --voice, as 70 or 70/30.")
    parser.add_argument("--bpm", type=float, default=None)
    parser.add_argument("--scale", default="", help="Musical scale, for example 'A minor'.")
    parser.add_argument("--seed-line", default="", help="First bar. The model writes the lines after it.")
    parser.add_argument("--topic", default="", help="Subject for the bars. Not printed as a bar.")
    parser.add_argument("--bars", type=int, default=DEFAULT_BARS)
    parser.add_argument("--temperature", type=float, default=DEFAULT_TEMPERATURE)
    parser.add_argument("--top-p", type=float, default=DEFAULT_TOP_P)
    parser.add_argument("--seed", type=int, default=None, help="Random seed. Printed on screen, not in the file.")
    parser.add_argument("--model", default="mlx-community/Qwen2.5-3B-Instruct-4bit")
    parser.add_argument("--adapter", type=Path, default=HERE / "adapters")
    parser.add_argument("--out-dir", type=Path, default=BARS_DIR)
    return parser


def _load(args):
    os.environ.setdefault("HF_HUB_DISABLE_XET", "1")
    try:
        from mlx_lm import load
    except ImportError:
        print(
            "mlx_lm is not installed. From tools/lyric-llm:\n"
            "  uv venv --python 3.12 .venv && uv pip install -r requirements.txt",
            file=sys.stderr,
        )
        return None
    adapter = args.adapter if (args.adapter / "adapters.safetensors").exists() else None
    if adapter is None:
        print("Adapter: none loaded. These bars are the base model.", file=sys.stderr)
    else:
        print("Adapter: %s" % adapter, file=sys.stderr)
    model, tokenizer = load(args.model, adapter_path=str(adapter) if adapter else None)
    from mlx_lm.utils import maybe_set_recommended_wired_limit

    maybe_set_recommended_wired_limit()
    return model, tokenizer


def main(argv=None) -> int:
    args = build_parser().parse_args(argv)
    seed = args.seed if args.seed is not None else random.SystemRandom().randrange(1, 2**31)
    try:
        request = generation_request(
            args.voice,
            args.blend,
            args.mix,
            args.bpm,
            args.scale,
            args.seed_line,
            args.topic,
            args.bars,
            args.temperature,
            args.top_p,
            seed,
        )
    except GenerateError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    counts = infer.load_voice_counts(OUT / "voice_counts.json")
    for name in (request["voice"], request["blend"]):
        if not name:
            continue
        note = infer.voice_note(name, counts, False)
        if note:
            print(note, file=sys.stderr)
    plan = request["plan"]
    print(
        "sampling %s  BPM %g  budget %d  temperature %s  top-p %s  seed %s"
        % (
            request["job"]["title"],
            plan["bpm"],
            plan["syl"],
            plan["temperature"],
            plan["top_p"],
            plan["seed"],
        ),
        file=sys.stderr,
    )
    lines = []
    if request["opening"]:
        lines.append(request["opening"])
    if plan["bars"] > 0:
        loaded = _load(args)
        if loaded is None:
            return 1
        model, tokenizer = loaded
        written = infer.generate_mixed(model, tokenizer, plan, request["job"])
        lines.extend(written)
    text = format_bars(lines)
    if not text:
        print("The model returned no bars.", file=sys.stderr)
        return 1
    when = datetime.now()
    path = dated_bars_path(args.out_dir, when, request["voice"], request["blend"])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    print(text, end="")
    print("saved %s" % path, file=sys.stderr)
    if len(lines) < args.bars:
        print("The sample is short of the requested bar count.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
