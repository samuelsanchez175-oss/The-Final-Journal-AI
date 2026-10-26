"""Build the voice-conditioning JSONL from catalog_index.sqlite.

Grok #1 had not published build_dataset.py or a SAMPLE_SEED when V2
started. This module is the sampler the shared CLI calls. Song split,
generic-bar drop, and the first-bar drop follow the shared brief.
The 50k draw is stratified by artist and prefers iconic, high-popularity
bars. SAMPLE_SEED defaults to 7, the seed clean_split.py already uses.
"""

from __future__ import annotations

import json
import os
import random
import sqlite3
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import quote

from voice_variant import render_messages, section_name, topic_name

DEFAULT_SEED = 7
SAMPLE_SIZE = 50_000
TRAIN_FRACTION = 0.95
VAL_FRACTION = 0.03
TEST_FRACTION = 0.02


@dataclass
class Bar:
    artist: str
    song_key: str
    line_seq: int
    total_lines: int
    section: str
    topic: str
    end_word: str
    syllables: int
    text: str
    iconic: int
    popularity: float
    is_generic: int
    bar_id: int


@dataclass
class Example:
    artist: str
    song_key: str
    line_seq: int
    total_lines: int
    section: str
    topic: str
    end_word: str
    syllables: int
    text: str
    prev_text: str
    next_text: str | None
    iconic: int
    popularity: float
    fim: bool = False

    def as_dict(self) -> dict:
        return {
            "artist": self.artist,
            "song_key": self.song_key,
            "line_seq": self.line_seq,
            "total_lines": self.total_lines,
            "section": self.section,
            "topic": self.topic,
            "end_word": self.end_word,
            "syllables": self.syllables,
            "text": self.text,
            "prev_text": self.prev_text,
            "next_text": self.next_text,
            "iconic": self.iconic,
            "popularity": self.popularity,
            "fim": self.fim,
        }


def song_key(artist: str, song_id: str | None, song: str, album: str | None) -> str:
    if song_id:
        return f"{artist}\0{song_id}"
    return f"{artist}\0{song}\0{album or ''}"


def split_songs(keys: list[str], seed: int) -> dict[str, str]:
    """95/3/2 assignment. Same seed and same key list always match."""
    ordered = sorted(keys)
    rng = random.Random(seed)
    rng.shuffle(ordered)
    n = len(ordered)
    n_test = int(round(n * TEST_FRACTION))
    n_val = int(round(n * VAL_FRACTION))
    while n_test + n_val > n:
        if n_val > 0:
            n_val -= 1
        elif n_test > 0:
            n_test -= 1
        else:
            break
    n_train = n - n_val - n_test
    roles = (
        ["train"] * n_train
        + ["val"] * n_val
        + ["test"] * n_test
    )
    return {key: role for key, role in zip(ordered, roles)}


def load_bars(catalog: Path) -> list[Bar]:
    if not catalog.is_file():
        raise FileNotFoundError(f"catalog not found: {catalog}")
    # Spaces in the repo path have to be escaped or SQLite rejects the URI.
    uri = "file:" + quote(catalog.resolve().as_posix(), safe="/") + "?mode=ro"
    con = sqlite3.connect(uri, uri=True)
    try:
        rows = con.execute(
            """
            SELECT id, artist, song, song_id, album, text, end_word, syllables,
                   is_generic, line_seq, total_lines, chronological_arc, topic,
                   is_iconic_anthem, popularity_score
            FROM catalog_bars
            """
        )
        bars: list[Bar] = []
        for row in rows:
            text = (row[5] or "").strip()
            artist = row[1] or ""
            if not artist or not text:
                continue
            bars.append(
                Bar(
                    artist=artist,
                    song_key=song_key(artist, (row[3] or "").strip() or None, row[2] or "", row[4]),
                    line_seq=int(row[9] or 0),
                    total_lines=int(row[10] or 0),
                    section=section_name(row[11]),
                    topic=topic_name(row[12]),
                    end_word=(row[6] or "").strip(),
                    syllables=int(row[7] or 0),
                    text=text,
                    iconic=1 if row[13] else 0,
                    popularity=float(row[14] or 0.0),
                    is_generic=1 if row[8] else 0,
                    bar_id=int(row[0]),
                )
            )
        return bars
    finally:
        con.close()


def eligible_examples(bars: list[Bar], train_keys: set[str]) -> list[Example]:
    """Train-song bars with a previous line. Generic targets and the first bar drop."""
    by_song: dict[str, list[Bar]] = {}
    for bar in bars:
        if bar.song_key not in train_keys:
            continue
        by_song.setdefault(bar.song_key, []).append(bar)
    examples: list[Example] = []
    for key in sorted(by_song):
        song_bars = sorted(by_song[key], key=lambda bar: (bar.line_seq, bar.bar_id))
        for index, bar in enumerate(song_bars):
            if index == 0 or bar.is_generic:
                continue
            prev = song_bars[index - 1]
            nxt = song_bars[index + 1] if index + 1 < len(song_bars) else None
            total = bar.total_lines if bar.total_lines >= bar.line_seq else bar.line_seq
            examples.append(
                Example(
                    artist=bar.artist,
                    song_key=bar.song_key,
                    line_seq=bar.line_seq,
                    total_lines=total,
                    section=bar.section,
                    topic=bar.topic,
                    end_word=bar.end_word,
                    syllables=bar.syllables,
                    text=bar.text,
                    prev_text=prev.text,
                    next_text=nxt.text if nxt is not None else None,
                    iconic=bar.iconic,
                    popularity=bar.popularity,
                )
            )
    return examples


def quotas(counts: dict[str, int], total: int) -> dict[str, int]:
    available = sum(counts.values())
    if available <= total:
        return dict(counts)
    exact = {artist: total * count / available for artist, count in counts.items()}
    floors = {artist: min(counts[artist], int(exact[artist])) for artist in counts}
    short = total - sum(floors.values())
    order = sorted(counts, key=lambda artist: (-(exact[artist] - int(exact[artist])), artist))
    while short > 0:
        moved = False
        for artist in order:
            if floors[artist] < counts[artist] and short > 0:
                floors[artist] += 1
                short -= 1
                moved = True
        if not moved:
            break
    return floors


def _weight(example: Example) -> float:
    iconic_bonus = 25.0 if example.iconic else 0.0
    return 1.0 + max(example.popularity, 0.0) + iconic_bonus


def weighted_sample(rows: list[Example], k: int, rng: random.Random) -> list[Example]:
    """Efraimidis-Spirakis sample. `rows` must already be in a stable order."""
    if k >= len(rows):
        return list(rows)
    keyed: list[tuple[float, int, Example]] = []
    for index, row in enumerate(rows):
        unit = max(rng.random(), 1e-12)
        key = unit ** (1.0 / _weight(row))
        keyed.append((key, index, row))
    keyed.sort(key=lambda item: (-item[0], item[1]))
    return [row for _, _, row in keyed[:k]]


def sample_examples(
    examples: list[Example],
    mode: str,
    seed: int,
    sample_size: int,
) -> list[Example]:
    if mode not in {"50k_sample", "full"}:
        raise ValueError(f"unknown mode {mode!r}")
    if mode == "full" or len(examples) <= sample_size:
        return list(examples)
    by_artist: dict[str, list[Example]] = {}
    for example in examples:
        by_artist.setdefault(example.artist, []).append(example)
    shares = quotas({artist: len(rows) for artist, rows in by_artist.items()}, sample_size)
    rng = random.Random(seed)
    # Song split consumes Random(seed) on its own. Sampling gets a child
    # stream so a change in split size does not reshuffle the draw when
    # the eligible train rows stay the same.
    rng = random.Random(rng.random())
    picked: list[Example] = []
    for artist in sorted(by_artist):
        rows = sorted(by_artist[artist], key=lambda row: (row.song_key, row.line_seq))
        picked.extend(weighted_sample(rows, shares[artist], rng))
    return picked


def assign_fim(examples: list[Example], fim_rate: float, seed: int) -> list[Example]:
    if fim_rate < 0 or fim_rate > 1:
        raise ValueError("fim must be between 0 and 1")
    ordered = sorted(examples, key=lambda row: (row.artist, row.song_key, row.line_seq))
    if fim_rate == 0 or not ordered:
        return ordered
    eligible = [index for index, row in enumerate(ordered) if row.next_text]
    k = min(len(eligible), int(round(fim_rate * len(ordered))))
    rng = random.Random(seed + 1)
    chosen = set(rng.sample(eligible, k)) if k else set()
    marked: list[Example] = []
    for index, row in enumerate(ordered):
        if index in chosen:
            marked.append(
                Example(
                    artist=row.artist,
                    song_key=row.song_key,
                    line_seq=row.line_seq,
                    total_lines=row.total_lines,
                    section=row.section,
                    topic=row.topic,
                    end_word=row.end_word,
                    syllables=row.syllables,
                    text=row.text,
                    prev_text=row.prev_text,
                    next_text=row.next_text,
                    iconic=row.iconic,
                    popularity=row.popularity,
                    fim=True,
                )
            )
        else:
            marked.append(row)
    return marked


def build(
    catalog: Path,
    mode: str,
    variant: str,
    fim_rate: float,
    seed: int,
    sample_size: int = SAMPLE_SIZE,
) -> list[dict]:
    bars = load_bars(catalog)
    keys = sorted({bar.song_key for bar in bars})
    roles = split_songs(keys, seed)
    train_keys = {key for key, role in roles.items() if role == "train"}
    examples = eligible_examples(bars, train_keys)
    picked = sample_examples(examples, mode, seed, sample_size)
    marked = assign_fim(picked, fim_rate, seed)
    return [render_messages(row.as_dict(), variant) for row in marked]


def identity_pairs(catalog: Path, mode: str, seed: int, sample_size: int) -> set[tuple[str, int]]:
    """Song key and line number for each kept assistant bar, before rendering."""
    bars = load_bars(catalog)
    roles = split_songs(sorted({bar.song_key for bar in bars}), seed)
    train_keys = {key for key, role in roles.items() if role == "train"}
    examples = eligible_examples(bars, train_keys)
    picked = sample_examples(examples, mode, seed, sample_size)
    return {(row.song_key, row.line_seq) for row in picked}


def write_jsonl(records: list[dict], out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8") as handle:
        for record in records:
            handle.write(json.dumps(record, ensure_ascii=False) + "\n")


def resolve_seed(cli_seed: int | None) -> int:
    if cli_seed is not None:
        return cli_seed
    raw = os.environ.get("SAMPLE_SEED")
    if raw is None or raw == "":
        return DEFAULT_SEED
    return int(raw)


def summarize(records: list[dict]) -> str:
    voices: dict[str, int] = {}
    fim = 0
    for record in records:
        system = record["messages"][0]["content"]
        user = record["messages"][1]["content"]
        if system == "Write the missing bar. Context above and below is from the same song.":
            fim += 1
            artist = user.split(">", 1)[0].replace("<voice: ", "")
        else:
            artist = system.split(".", 1)[0].replace("Write bars like ", "")
        voices[artist] = voices.get(artist, 0) + 1
    parts = [f"{artist}={voices[artist]}" for artist in sorted(voices)]
    return f"examples={len(records)} fim={fim} " + " ".join(parts)
