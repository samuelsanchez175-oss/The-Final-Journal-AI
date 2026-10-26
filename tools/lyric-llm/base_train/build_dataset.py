#!/usr/bin/env python3
"""Build OpenAI chat JSONL for the v5 base fine-tune.

  python3 base_train/build_dataset.py --mode 50k_sample --out out/train_50k.jsonl
  python3 base_train/build_dataset.py --mode full       --out out/train_full.jsonl
  python3 base_train/build_dataset.py --mode 50k_sample --fim 0.2 --out out/train_50k_fim.jsonl
  python3 base_train/build_dataset.py --mode full       --fim 0.2 --out out/train_full_fim.jsonl

The train file is the 95% song split. Sibling files are val_<stem>.jsonl (3%)
and test_<stem>.jsonl (2%). A song is one artist + title. The catalog song_id
column is blank on tens of thousands of rows, so it is not the split key.

50k_sample draws only from the train split. Val and test stay the full
held-out songs, so both modes share one eval set. SAMPLE_SEED breaks ties
inside a voice. The split seed stays 7, matching lyriclib.split_song_ids.

The live catalog has no is_junk column. Junk bars are dropped with
lyriclib.is_junk_line. A table that does have is_junk drops is_junk=1 too.

--fim 0.2 reshapes that share of bars that have a following line. The same
bar stays fill-in-the-middle in the 50k file and the full file. --variant
hands the run to voice_dataset.py. Plain D1 commands pass neither flag.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import sqlite3
import sys
from collections import Counter, defaultdict
from pathlib import Path
from urllib.parse import quote

HERE = Path(__file__).resolve().parent
LYRIC_LLM = HERE.parent
if str(LYRIC_LLM) not in sys.path:
    sys.path.insert(0, str(LYRIC_LLM))
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from lyriclib import is_junk_line, split_song_ids

DEFAULT_DB = LYRIC_LLM / "out" / "catalog_index.sqlite"
SPLIT_SEED = 7
SAMPLE_TARGET = 50_000
SYSTEM_PROMPT = (
    "Write bars like <voice>. Keep the artist's slang, syllable count, "
    "and rhyme pattern. Preserve the end word if given."
)
FIM_SYSTEM = "Write the missing bar. Context above and below is from the same song."

# chronological_arc is the only section-like column. The chat template
# asks for a section name such as "verse", not the arc label.
ARC_SECTION = {
    "intro": "intro",
    "verse_build": "verse",
    "verse_turn": "verse",
    "climax_punch": "verse",
}


def song_key(artist: str, title: str) -> str:
    """Same recipe as clean_split.song_id_for. One artist + title, one song."""
    payload = artist + "\0" + title
    return hashlib.sha1(payload.encode("utf-8", errors="surrogateescape")).hexdigest()


def one_line(text: str) -> str:
    return " ".join((text or "").split())


def sample_seed() -> str:
    return os.environ.get("SAMPLE_SEED", "7")


def sibling_paths(train_path: Path) -> tuple[Path, Path]:
    """val/test names next to a train_*.jsonl file. Does not use out/val.jsonl."""
    name = train_path.name
    if name.startswith("train_"):
        rest = name[len("train_") :]
        return train_path.with_name("val_" + rest), train_path.with_name("test_" + rest)
    return (
        train_path.with_name(train_path.stem + "_val.jsonl"),
        train_path.with_name(train_path.stem + "_test.jsonl"),
    )


def connect_readonly(db_path: Path) -> sqlite3.Connection:
    uri = "file:" + quote(str(db_path)) + "?mode=ro"
    conn = sqlite3.connect(uri, uri=True)
    conn.row_factory = sqlite3.Row
    return conn


def load_rows(db_path: Path) -> list[dict]:
    conn = connect_readonly(db_path)
    try:
        cols = {row[1] for row in conn.execute("PRAGMA table_info(catalog_bars)")}
        if "is_junk" in cols:
            junk_sql = "COALESCE(is_junk, 0) AS is_junk"
        else:
            junk_sql = "0 AS is_junk"
        if "song_id" in cols:
            song_sql = "song_id"
        else:
            song_sql = "''"
        sql = f"""
            SELECT id, artist, song, {song_sql} AS song_id, text, end_word, syllables,
                   popularity_score, is_generic, line_seq, total_lines,
                   chronological_arc, topic, is_iconic_anthem, {junk_sql}
            FROM catalog_bars
        """
        rows = []
        keys: dict[tuple[str, str], str] = {}
        for raw in conn.execute(sql):
            artist = raw["artist"] or ""
            song = raw["song"] or ""
            pair = (artist, song)
            key = keys.get(pair)
            if key is None:
                key = song_key(artist, song)
                keys[pair] = key
            rows.append(
                {
                    "id": int(raw["id"]),
                    "artist": artist,
                    "song": song,
                    "song_key": key,
                    "song_id": raw["song_id"] or "",
                    "text": raw["text"] or "",
                    "end_word": raw["end_word"] or "",
                    "syllables": int(raw["syllables"] or 0),
                    "popularity_score": float(raw["popularity_score"] or 0.0),
                    "is_generic": int(raw["is_generic"] or 0),
                    "is_junk": int(raw["is_junk"] or 0),
                    "line_seq": int(raw["line_seq"] or 0),
                    "total_lines": int(raw["total_lines"] or 0),
                    "chronological_arc": raw["chronological_arc"] or "",
                    "topic": raw["topic"] or "",
                    "is_iconic_anthem": int(raw["is_iconic_anthem"] or 0),
                }
            )
    finally:
        conn.close()
    return rows


def section_name(arc: str) -> str:
    return ARC_SECTION.get((arc or "").strip(), "verse")


def build_examples(rows: list[dict]) -> tuple[list[dict], Counter]:
    """Drop the first bar of each song, then generic and junk bars."""
    grouped: dict[str, list[dict]] = defaultdict(list)
    for row in rows:
        key = row.get("song_key")
        if not key:
            row = dict(row)
            key = song_key(row.get("artist") or "", row.get("song") or "")
            row["song_key"] = key
        grouped[key].append(row)

    song_pop: dict[str, float] = {}
    for key, group in grouped.items():
        group.sort(key=lambda row: (row["line_seq"], row["id"]))
        song_pop[key] = max(row["popularity_score"] for row in group)

    examples: list[dict] = []
    drops: Counter = Counter()
    drops["rows"] = len(rows)
    drops["songs"] = len(grouped)
    for key, group in grouped.items():
        width = len(group)
        for index, row in enumerate(group):
            if index == 0:
                drops["dropped_first"] += 1
                continue
            if row["is_generic"]:
                drops["dropped_generic"] += 1
                continue
            if row["is_junk"]:
                drops["dropped_junk_column"] += 1
                continue
            if is_junk_line(row["text"]):
                drops["dropped_junk_line"] += 1
                continue
            text = one_line(row["text"])
            prev = group[index - 1]
            prev_text = one_line(prev["text"])
            next_text = ""
            next_song_id = ""
            if index + 1 < width:
                nxt = group[index + 1]
                next_text = one_line(nxt["text"])
                next_song_id = nxt.get("song_id") or ""
            if not text or not prev_text:
                drops["dropped_blank"] += 1
                continue
            total = row["total_lines"]
            if total < row["line_seq"]:
                total = max(row["line_seq"], width)
            topic = row["topic"].strip() or "unknown"
            examples.append(
                {
                    "id": row["id"],
                    "artist": row["artist"],
                    "song": row["song"],
                    "song_key": key,
                    "song_id": row.get("song_id") or "",
                    "text": text,
                    "prev_text": prev_text,
                    "prev_song_id": prev.get("song_id") or "",
                    "next_text": next_text,
                    "next_song_id": next_song_id,
                    "end_word": row["end_word"],
                    "syllables": row["syllables"],
                    "line_seq": row["line_seq"],
                    "total_lines": total,
                    "section": section_name(row["chronological_arc"]),
                    "topic": topic,
                    "popularity_score": row["popularity_score"],
                    "song_popularity": song_pop[key],
                    "is_iconic_anthem": row["is_iconic_anthem"],
                }
            )
    drops["kept"] = len(examples)
    return examples, drops


def assign_splits(examples: list[dict], seed: int = SPLIT_SEED) -> dict[str, list[dict]]:
    """95/3/2 by song. Val is stored under the key lyriclib uses: valid."""
    parts = split_song_ids((ex["song_key"] for ex in examples), seed=seed)
    buckets = {name: set(keys) for name, keys in parts.items()}
    out = {"train": [], "valid": [], "test": []}
    for ex in examples:
        key = ex["song_key"]
        if key in buckets["train"]:
            out["train"].append(ex)
        elif key in buckets["valid"]:
            out["valid"].append(ex)
        else:
            out["test"].append(ex)
    for name in out:
        out[name].sort(key=lambda ex: (ex["artist"], ex["song_key"], ex["line_seq"], ex["id"]))
    return out


def allocate(share_counts: dict[str, int], train_counts: dict[str, int], target: int) -> dict[str, int]:
    """Largest-remainder quotas. Caps at the train bars that voice actually has."""
    voices = sorted(set(share_counts) | set(train_counts))
    total_share = sum(share_counts.values())
    train_total = sum(train_counts.get(voice, 0) for voice in voices)
    target = min(int(target), train_total)
    if target <= 0 or total_share <= 0:
        return {}
    raw = {voice: target * share_counts.get(voice, 0) / total_share for voice in voices}
    base = {voice: int(math.floor(raw[voice])) for voice in voices}
    left = target - sum(base.values())
    order = sorted(voices, key=lambda voice: (-(raw[voice] - base[voice]), voice))
    for voice in order:
        if left <= 0:
            break
        base[voice] += 1
        left -= 1
    overflow = 0
    for voice in voices:
        room = train_counts.get(voice, 0)
        if base[voice] > room:
            overflow += base[voice] - room
            base[voice] = room
    while overflow:
        roomy = [voice for voice in voices if base[voice] < train_counts.get(voice, 0)]
        if not roomy:
            break
        roomy.sort(key=lambda voice: (-(train_counts[voice] - base[voice]), voice))
        base[roomy[0]] += 1
        overflow -= 1
    return {voice: count for voice, count in base.items() if count}


def rank_key(seed: str, ex: dict) -> tuple:
    """Iconic anthem, then song popularity, then bar popularity. Seed breaks ties."""
    tie = hashlib.blake2s(
        f"{seed}|{ex['song_key']}|{ex['line_seq']}|{ex['id']}".encode("utf-8")
    ).digest()
    return (
        -int(ex["is_iconic_anthem"]),
        -float(ex["song_popularity"]),
        -float(ex["popularity_score"]),
        tie,
    )


def select_stratified(
    train: list[dict],
    share_from: list[dict],
    target: int,
    seed: str,
) -> tuple[list[dict], dict[str, int]]:
    """Same voice percentage as share_from, taken from train only."""
    share_counts = dict(Counter(ex["artist"] for ex in share_from))
    train_counts = dict(Counter(ex["artist"] for ex in train))
    targets = allocate(share_counts, train_counts, target)
    by_voice: dict[str, list[dict]] = defaultdict(list)
    for ex in train:
        by_voice[ex["artist"]].append(ex)
    chosen: list[dict] = []
    for artist in sorted(targets):
        group = by_voice.get(artist, [])
        group.sort(key=lambda ex: rank_key(seed, ex))
        chosen.extend(group[: targets[artist]])
    chosen.sort(key=lambda ex: (ex["artist"],) + rank_key(seed, ex))
    return chosen, targets


def user_content(ex: dict) -> str:
    return (
        f"<voice: {ex['artist']}> <section: {ex['section']}> "
        f"<bar {ex['line_seq']} of {ex['total_lines']}>\n"
        f"PREV_BAR: {ex['prev_text']}\n"
        f"TOPIC: {ex['topic']}\n"
        f"END_WORD: {ex['end_word']}\n"
        f"SYLLABLES: {ex['syllables']}"
    )


def fim_user_content(ex: dict) -> str:
    return (
        f"<voice: {ex['artist']}>\n"
        f"ABOVE: {ex['prev_text']}\n"
        f"BELOW: {ex['next_text']}\n"
        f"END_WORD: {ex['end_word']}\n"
        f"SYLLABLES: {ex['syllables']}"
    )


def fim_unit(seed: str, ex: dict) -> float:
    """Stable 0..1 draw. The same bar gets the same draw in every file."""
    digest = hashlib.blake2s(
        f"{seed}|fim|{ex['song_key']}|{ex['line_seq']}|{ex['id']}".encode("utf-8")
    ).digest()
    return int.from_bytes(digest[:8], "big") / float(2**64)


def apply_fim(examples: list[dict], rate: float, seed: str) -> None:
    """Mark bars that have a following line when their draw falls under rate."""
    if rate < 0 or rate > 1:
        raise ValueError(f"fim rate must be from 0 to 1, got {rate}")
    for ex in examples:
        ex["fim"] = bool(ex.get("next_text")) and rate > 0 and fim_unit(seed, ex) < rate


def render(ex: dict) -> str:
    if ex.get("fim"):
        system = FIM_SYSTEM
        user = fim_user_content(ex)
    else:
        system = SYSTEM_PROMPT
        user = user_content(ex)
    record = {
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
            {"role": "assistant", "content": ex["text"]},
        ]
    }
    return json.dumps(record, ensure_ascii=False)


def write_jsonl(path: Path, examples: list[dict]) -> int:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        for ex in examples:
            handle.write(render(ex))
            handle.write("\n")
    return path.stat().st_size


def voice_counts(examples: list[dict]) -> dict[str, int]:
    return dict(sorted(Counter(ex["artist"] for ex in examples).items()))


def song_keys_of(examples: list[dict]) -> set[str]:
    return {ex["song_key"] for ex in examples}


def fim_count(examples: list[dict]) -> int:
    return sum(1 for ex in examples if ex.get("fim"))


def build_dataset(
    mode: str,
    out_path: Path,
    db_path: Path = DEFAULT_DB,
    sample_target: int = SAMPLE_TARGET,
    split_seed: int = SPLIT_SEED,
    fim_rate: float = 0.0,
) -> dict:
    if mode not in ("50k_sample", "full"):
        raise ValueError(f"unknown mode: {mode}")
    db_path = Path(db_path)
    if not db_path.is_file():
        raise FileNotFoundError(f"catalog not found: {db_path}")
    out_path = Path(out_path)
    val_path, test_path = sibling_paths(out_path)
    seed = sample_seed()

    rows = load_rows(db_path)
    examples, drops = build_examples(rows)
    splits = assign_splits(examples, seed=split_seed)
    targets: dict[str, int] = {}
    if mode == "50k_sample":
        train_rows, targets = select_stratified(splits["train"], examples, sample_target, seed)
    else:
        train_rows = splits["train"]

    apply_fim(train_rows, fim_rate, seed)
    apply_fim(splits["valid"], fim_rate, seed)
    apply_fim(splits["test"], fim_rate, seed)

    train_bytes = write_jsonl(out_path, train_rows)
    val_bytes = write_jsonl(val_path, splits["valid"])
    test_bytes = write_jsonl(test_path, splits["test"])

    return {
        "mode": mode,
        "sample_seed": seed,
        "split_seed": split_seed,
        "sample_target": sample_target if mode == "50k_sample" else None,
        "fim_rate": fim_rate,
        "fim_counts": {
            "train": fim_count(train_rows),
            "val": fim_count(splits["valid"]),
            "test": fim_count(splits["test"]),
        },
        "targets": targets,
        "paths": {"train": out_path, "val": val_path, "test": test_path},
        "bytes": {"train": train_bytes, "val": val_bytes, "test": test_bytes},
        "counts": {
            "train": len(train_rows),
            "val": len(splits["valid"]),
            "test": len(splits["test"]),
        },
        "by_voice": {
            "train": voice_counts(train_rows),
            "val": voice_counts(splits["valid"]),
            "test": voice_counts(splits["test"]),
            "eligible": voice_counts(examples),
        },
        "songs": {
            "train": len(song_keys_of(train_rows)),
            "val": len(song_keys_of(splits["valid"])),
            "test": len(song_keys_of(splits["test"])),
        },
        "split_songs": {
            "train": len(song_keys_of(splits["train"])),
            "val": len(song_keys_of(splits["valid"])),
            "test": len(song_keys_of(splits["test"])),
        },
        "song_keys": {
            "train": song_keys_of(splits["train"]),
            "val": song_keys_of(splits["valid"]),
            "test": song_keys_of(splits["test"]),
        },
        "drops": dict(drops),
        "train_examples": train_rows,
        "val_examples": splits["valid"],
        "test_examples": splits["test"],
    }


def format_report(result: dict) -> str:
    lines = [
        f"mode: {result['mode']}",
        f"sample_seed: {result['sample_seed']}",
        f"split_seed: {result['split_seed']}",
        f"sample_target: {result['sample_target']}",
        f"fim_rate: {result.get('fim_rate', 0)}",
        (
            f"fim_train: {result.get('fim_counts', {}).get('train', 0)} "
            f"fim_val: {result.get('fim_counts', {}).get('val', 0)} "
            f"fim_test: {result.get('fim_counts', {}).get('test', 0)}"
        ),
    ]
    for split_name in ("train", "val", "test"):
        path = result["paths"][split_name]
        lines.append(
            f"{split_name}: {path} rows={result['counts'][split_name]} "
            f"bytes={result['bytes'][split_name]} songs_in_file={result['songs'][split_name]} "
            f"split_songs={result['split_songs'][split_name]}"
        )
    lines.append("voices:")
    artists = sorted(result["by_voice"]["eligible"])
    for split_name in ("train", "val", "test"):
        counts = result["by_voice"][split_name]
        for artist in artists:
            lines.append(f"  {split_name} {artist} {counts.get(artist, 0)}")
    if result["targets"]:
        lines.append("quota:")
        for artist, count in sorted(result["targets"].items()):
            lines.append(f"  {artist} {count}")
    lines.append("drops:")
    for key, count in sorted(result["drops"].items()):
        lines.append(f"  {key} {count}")
    lines.append("examples:")
    shown: set[str] = set()
    for ex in result["train_examples"]:
        if ex["artist"] in shown:
            continue
        shown.add(ex["artist"])
        user = fim_user_content(ex) if ex.get("fim") else user_content(ex)
        lines.append(f"  VOICE {ex['artist']}")
        lines.append("  USER " + user.replace("\n", " | "))
        lines.append("  ASSISTANT " + ex["text"])
    spots = [ex for ex in result["train_examples"] if ex.get("fim")][:3]
    if spots:
        lines.append("fim_spots:")
        for ex in spots:
            lines.append(
                f"  song_key={ex['song_key']} song_id={ex.get('song_id') or '(blank)'} "
                f"prev_song_id={ex.get('prev_song_id') or '(blank)'} "
                f"next_song_id={ex.get('next_song_id') or '(blank)'}"
            )
            lines.append(f"  artist={ex['artist']} song={ex['song']}")
            lines.append(f"  ABOVE {ex['prev_text']}")
            lines.append(f"  BELOW {ex['next_text']}")
            lines.append(f"  ASSISTANT {ex['text']}")
    return "\n".join(lines) + "\n"


def _run_voice_cli(args: argparse.Namespace) -> int:
    """Existing voice-conditioning command. D1 does not use this path."""
    try:
        import voice_dataset
    except ImportError:
        print("voice_dataset.py is not on this branch", file=sys.stderr)
        return 2

    catalog = Path(args.catalog or args.db or DEFAULT_DB)
    seed = voice_dataset.resolve_seed(args.seed)
    variant = args.variant or "one_hot"
    records = voice_dataset.build(
        catalog=catalog,
        mode=args.mode,
        variant=variant,
        fim_rate=args.fim,
        seed=seed,
    )
    voice_dataset.write_jsonl(records, Path(args.out))
    size = Path(args.out).stat().st_size
    briefs = voice_dataset.load_briefs() if variant == "systembrief" else None
    print(
        f"mode={args.mode} variant={variant} seed={seed} "
        f"bytes={size} {voice_dataset.summarize(records, briefs)}"
    )
    print(args.out)
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Build the v5 base fine-tune JSONL.")
    parser.add_argument("--mode", required=True, choices=["50k_sample", "full"])
    parser.add_argument("--out", required=True, help="Train JSONL path.")
    parser.add_argument("--db", default=None, help="Catalog sqlite.")
    parser.add_argument("--catalog", default=None, help="Catalog sqlite. Same as --db.")
    parser.add_argument("--fim", type=float, default=0.0)
    parser.add_argument("--variant", default="")
    parser.add_argument("--seed", type=int, default=None)
    args = parser.parse_args(argv)
    if args.variant:
        try:
            return _run_voice_cli(args)
        except (FileNotFoundError, ValueError) as exc:
            print(str(exc), file=sys.stderr)
            return 2
    if args.seed is not None:
        os.environ["SAMPLE_SEED"] = str(args.seed)
    db = args.db or args.catalog or str(DEFAULT_DB)
    try:
        result = build_dataset(args.mode, Path(args.out), Path(db), fim_rate=args.fim)
    except (FileNotFoundError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        return 2
    sys.stdout.write(format_report(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
