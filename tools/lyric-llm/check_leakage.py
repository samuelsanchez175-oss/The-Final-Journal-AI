#!/usr/bin/env python3
"""Leak check for song-level train/val/test JSONL.

A leak is a song_id in two files, or an identical 8-word sequence that sits
in two splits and occurs in more than 5 songs across those splits. Chorus
repeats at or under that cap are allowed. A fix moves the whole song record.
Lines inside a song are never deleted.

  python3 check_leakage.py
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import resource
import sys
from collections import Counter, defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
SPLITS = ("train", "val", "test")
CAP = 5
WORD_RE = re.compile(r"[a-z0-9']+")
MARKER_RE = re.compile(r"^\[(verse|chorus|intro|outro|bridge|hook)\]$", re.I)
PREFER = {"train": 3, "val": 2, "test": 1}


def song_words(text: str) -> list[str]:
    words: list[str] = []
    for line in text.split("\n"):
        if MARKER_RE.match(line.strip()):
            continue
        lowered = line.lower().replace("\u2019", "'").replace("\u2018", "'")
        words.extend(WORD_RE.findall(lowered))
    return words


def gram_phrases(words: list[str]) -> set[str]:
    """Each distinct 8-word sequence in this song, once."""
    found: set[str] = set()
    for index in range(0, len(words) - 7):
        found.add(" ".join(words[index : index + 8]))
    return found


def gram_hash(phrase: str) -> bytes:
    return hashlib.sha1(phrase.encode("utf-8")).digest()


def bump(packed: int, split_index: int) -> int:
    shift = split_index * 16
    field = (packed >> shift) & 0xFFFF
    if field < 0xFFFF:
        field += 1
    mask = 0xFFFF << shift
    return (packed & ~mask) | (field << shift)


def unpack(packed: int) -> tuple[int, int, int]:
    return packed & 0xFFFF, (packed >> 16) & 0xFFFF, (packed >> 32) & 0xFFFF


def crossing_pairs(counts: tuple[int, int, int]) -> list[tuple[str, str, int]]:
    """Split pairs where the sequence is on both sides and the sum is over the cap."""
    names = SPLITS
    hits = []
    for left in range(3):
        for right in range(left + 1, 3):
            if counts[left] and counts[right] and counts[left] + counts[right] > CAP:
                hits.append((names[left], names[right], counts[left] + counts[right]))
    return hits


def lyric_lines(text: str) -> int:
    count = 0
    for line in text.split("\n"):
        stripped = line.strip()
        if stripped and not MARKER_RE.match(stripped):
            count += 1
    return count


def marker_lines(text: str) -> int:
    count = 0
    for line in text.split("\n"):
        if MARKER_RE.match(line.strip()):
            count += 1
    return count


class UnionFind:
    def __init__(self) -> None:
        self.parent: dict[str, str] = {}

    def find(self, item: str) -> str:
        self.parent.setdefault(item, item)
        root = item
        while self.parent[root] != root:
            root = self.parent[root]
        while self.parent[item] != root:
            nxt = self.parent[item]
            self.parent[item] = root
            item = nxt
        return root

    def union(self, left: str, right: str) -> None:
        ra = self.find(left)
        rb = self.find(right)
        if ra != rb:
            self.parent[rb] = ra


def assign_destinations(
    members: dict[bytes, list[tuple[str, str]]],
    split_of: dict[str, str],
) -> dict[str, str]:
    """Map song_id to the split it should move to. Songs already there are omitted.

    Songs that share a leaking sequence stay together. The group goes to the
    split that already holds the most of those songs. A tie goes to train.
    """
    groups = UnionFind()
    for rows in members.values():
        ids = [song_id for _split, song_id in rows]
        if not ids:
            continue
        first = ids[0]
        for song_id in ids[1:]:
            groups.union(first, song_id)
    buckets: dict[str, list[str]] = defaultdict(list)
    for song_id in split_of:
        buckets[groups.find(song_id)].append(song_id)
    largest = max((len(group) for group in buckets.values()), default=0)
    print(f"components {len(buckets):,} largest {largest:,}", flush=True)
    moves: dict[str, str] = {}
    for group in buckets.values():
        votes: Counter[str] = Counter(split_of[song_id] for song_id in group)
        dest = max(votes, key=lambda name: (votes[name], PREFER[name]))
        for song_id in group:
            if split_of[song_id] != dest:
                moves[song_id] = dest
    return moves


def rss_mb() -> int:
    usage = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    if sys.platform == "darwin":
        return int(usage / (1024 * 1024))
    return int(usage / 1024)


def scan(paths: dict[str, Path]) -> dict:
    counts: dict[bytes, int] = {}
    ids: dict[str, set[str]] = {name: set() for name in SPLITS}
    dup_inside: Counter[str] = Counter()
    songs_n = Counter()
    line_n: dict[str, Counter[str]] = {name: Counter() for name in SPLITS}
    song_n: dict[str, Counter[str]] = {name: Counter() for name in SPLITS}
    markers = Counter()
    missing_bpm = Counter()
    missing_scale = Counter()
    for split_index, split in enumerate(SPLITS):
        with paths[split].open(encoding="utf-8") as handle:
            for line in handle:
                record = json.loads(line)
                song_id = record["song_id"]
                if song_id in ids[split]:
                    dup_inside[split] += 1
                ids[split].add(song_id)
                songs_n[split] += 1
                artist = record.get("artist") or ""
                text = record.get("text") or ""
                line_n[split][artist] += lyric_lines(text)
                song_n[split][artist] += 1
                markers[split] += marker_lines(text)
                if record.get("bpm") is None:
                    missing_bpm[split] += 1
                if record.get("scale") is None:
                    missing_scale[split] += 1
                for phrase in gram_phrases(song_words(text)):
                    digest = gram_hash(phrase)
                    counts[digest] = bump(counts.get(digest, 0), split_index)
                if songs_n[split] % 5000 == 0:
                    print(
                        f"  {split} {songs_n[split]:,} grams {len(counts):,} rss {rss_mb()}MB",
                        flush=True,
                    )
        print(f"scanned {split} {songs_n[split]:,} grams {len(counts):,}", flush=True)
    shared = {
        "train-val": ids["train"] & ids["val"],
        "train-test": ids["train"] & ids["test"],
        "val-test": ids["val"] & ids["test"],
    }
    pair_over = Counter()
    pair_allowed = Counter()
    leak_hashes: set[bytes] = set()
    for digest, packed in counts.items():
        triple = unpack(packed)
        pairs = crossing_pairs(triple)
        if pairs:
            leak_hashes.add(digest)
            for left, right, _total in pairs:
                pair_over[f"{left}-{right}"] += 1
        else:
            train, val, test = triple
            if train and test and train + test <= CAP:
                pair_allowed["train-test"] += 1
            if train and val and train + val <= CAP:
                pair_allowed["train-val"] += 1
            if val and test and val + test <= CAP:
                pair_allowed["val-test"] += 1
    return {
        "counts": counts,
        "ids": ids,
        "dup_inside": dup_inside,
        "shared_ids": shared,
        "songs_n": songs_n,
        "line_n": line_n,
        "song_n": song_n,
        "markers": markers,
        "missing_bpm": missing_bpm,
        "missing_scale": missing_scale,
        "pair_over": pair_over,
        "pair_allowed": pair_allowed,
        "leak_hashes": leak_hashes,
    }


def collect_leaks(paths: dict[str, Path], leak_hashes: set[bytes]) -> tuple[dict, dict, dict]:
    """Second pass. Records song ids and a few examples for leaking sequences."""
    members: dict[bytes, list[tuple[str, str]]] = defaultdict(list)
    examples: dict[bytes, list[tuple[str, str, str]]] = defaultdict(list)
    phrases: dict[bytes, str] = {}
    split_of: dict[str, str] = {}
    if not leak_hashes:
        return members, examples, split_of
    for split in SPLITS:
        with paths[split].open(encoding="utf-8") as handle:
            for line in handle:
                record = json.loads(line)
                song_id = record["song_id"]
                words = song_words(record.get("text") or "")
                seen: set[bytes] = set()
                artist = record.get("artist") or ""
                for index in range(0, len(words) - 7):
                    phrase = " ".join(words[index : index + 8])
                    digest = gram_hash(phrase)
                    if digest not in leak_hashes or digest in seen:
                        continue
                    seen.add(digest)
                    phrases.setdefault(digest, phrase)
                    members[digest].append((split, song_id))
                    if len(examples[digest]) < 3:
                        examples[digest].append((artist, song_id, split))
                    split_of.setdefault(song_id, split)
    examples["__phrases__"] = phrases  # type: ignore[assignment]
    return members, examples, split_of


def apply_moves(paths: dict[str, Path], moves: dict[str, str], keep_split: dict[str, str]) -> Counter:
    """Rewrite the three files. Whole records move. Nothing inside a song is edited."""
    temps = {split: paths[split].with_suffix(".jsonl.leak-tmp") for split in SPLITS}
    written = Counter()
    handles = {split: temps[split].open("w", encoding="utf-8") for split in SPLITS}
    try:
        for split in SPLITS:
            with paths[split].open(encoding="utf-8") as handle:
                for line in handle:
                    song_id = json.loads(line)["song_id"]
                    if song_id in keep_split and split != keep_split[song_id]:
                        continue
                    dest = moves.get(song_id, split)
                    handles[dest].write(line if line.endswith("\n") else line + "\n")
                    written[dest] += 1
    finally:
        for handle in handles.values():
            handle.close()
    for split in SPLITS:
        os.replace(temps[split], paths[split])
    return written


def distribution(scan_result: dict) -> dict:
    line_n = scan_result["line_n"]
    song_n = scan_result["song_n"]
    totals = {split: sum(line_n[split].values()) for split in SPLITS}
    song_totals = {split: sum(song_n[split].values()) for split in SPLITS}
    artists = set()
    for split in SPLITS:
        artists.update(line_n[split])
    global_lines = Counter()
    global_songs = Counter()
    for split in SPLITS:
        global_lines.update(line_n[split])
        global_songs.update(song_n[split])
    grand = sum(global_lines.values()) or 1
    weighted = 0.0
    weight = 0
    outliers = []
    for artist, count in global_lines.items():
        global_share = count / grand
        deviations = []
        for split in SPLITS:
            split_total = totals[split] or 1
            share = line_n[split][artist] / split_total
            deviations.append(abs(share - global_share))
        weighted += count * sum(deviations)
        weight += count
        train_share = line_n["train"][artist] / (totals["train"] or 1)
        test_share = line_n["test"][artist] / (totals["test"] or 1)
        val_share = line_n["val"][artist] / (totals["val"] or 1)
        gap = max(abs(test_share - train_share), abs(val_share - train_share))
        if count >= 1000 and gap > 0.015:
            outliers.append(
                (
                    gap,
                    artist,
                    count,
                    train_share,
                    val_share,
                    test_share,
                    global_songs[artist],
                )
            )
    outliers.sort(reverse=True)
    wad = (weighted / weight / 3) if weight else 0.0
    big = []
    for artist, count in global_lines.most_common(15):
        big.append(
            {
                "artist": artist,
                "lines": count,
                "songs": global_songs[artist],
                "shares": {
                    split: line_n[split][artist] / (totals[split] or 1) for split in SPLITS
                },
                "song_counts": {split: song_n[split][artist] for split in SPLITS},
                "line_counts": {split: line_n[split][artist] for split in SPLITS},
            }
        )
    return {
        "totals": totals,
        "song_totals": song_totals,
        "wad": wad,
        "outliers": outliers,
        "big": big,
        "artists": len(artists),
    }


def write_report(path: Path, payload: dict) -> None:
    lines = [
        "# Leak check",
        "",
        "8-word sequences are lowercase letter, number, and apostrophe tokens in song order.",
        "Section-marker lines such as `[Chorus]` are not words. Each song counts a sequence once.",
        f"A sequence may sit in train and test when it occurs in {CAP} or fewer songs across those two files.",
        "Above that cap, every song that contains the sequence is moved as a whole record into one split.",
        "",
        "## Song ids",
        "",
    ]
    shared = payload["shared_ids"]
    for name in ("train-val", "train-test", "val-test"):
        lines.append(f"- `{name}` shared song ids: {len(shared[name]):,}")
    dup = payload["dup_inside"]
    for split in SPLITS:
        lines.append(f"- Duplicate song ids inside `{split}`: {dup[split]:,}")
    lines.extend(["", "## 8-word sequences", ""])
    allowed = payload["pair_allowed"]
    over = payload["pair_over"]
    for name in ("train-val", "train-test", "val-test"):
        lines.append(
            f"- `{name}` at or under {CAP} songs: {allowed[name]:,}. Over {CAP}: {over[name]:,}."
        )
    lines.append(f"- Songs moved: {payload['moved']:,}")
    if payload["moved_detail"]:
        for dest, count in payload["moved_detail"].most_common():
            lines.append(f"  - To `{dest}`: {count:,}")
    lines.append(f"- After the move, sequences still over the cap: {payload['remaining_over']:,}")
    lines.extend(["", "## Leak examples", ""])
    if not payload["examples"]:
        lines.append("No sequence over the cap crossed two files.")
    else:
        lines.append("Counts are songs in each file before any move.")
        lines.append("")
        for item in payload["examples"]:
            phrase = item["phrase"].replace("|", "\\|")
            lines.append(
                f"- `{phrase}` — train {item['train']}, val {item['val']}, test {item['test']}"
            )
            for artist, song_id, split in item["samples"]:
                safe = artist.replace("|", "\\|")
                lines.append(f"  - {split}: {safe} `{song_id}`")
    dist = payload["distribution"]
    lines.extend(
        [
            "",
            "## Artist distribution",
            "",
            "Share is that artist's lyric lines divided by the lyric lines in the split.",
            f"Weighted mean absolute deviation from the artist's overall share: {dist['wad'] * 100:.3f} percentage points.",
            "",
            "| Artist | Train share | Val share | Test share | Train lines | Val lines | Test lines |",
            "| --- | ---: | ---: | ---: | ---: | ---: | ---: |",
        ]
    )
    for row in dist["big"]:
        artist = row["artist"].replace("|", "\\|")
        shares = row["shares"]
        got = row["line_counts"]
        lines.append(
            f"| {artist} | {shares['train'] * 100:.2f}% | {shares['val'] * 100:.2f}% | "
            f"{shares['test'] * 100:.2f}% | {got['train']:,} | {got['val']:,} | {got['test']:,} |"
        )
    lines.extend(["", "Artists with at least 1,000 lines whose train share and another split differ by more than 1.5 percentage points:", ""])
    if not dist["outliers"]:
        lines.append("None.")
    else:
        for gap, artist, count, train_share, val_share, test_share, songs in dist["outliers"][:30]:
            safe = artist.replace("|", "\\|")
            lines.append(
                f"- {safe}: {count:,} lines, {songs:,} songs, "
                f"train {train_share * 100:.2f}%, val {val_share * 100:.2f}%, test {test_share * 100:.2f}%"
            )
    lines.append("")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def refresh_split_counts(scan_result: dict) -> None:
    """Replace the split tables so they match the files after a move."""
    path = OUT / "split_counts.md"
    existing = path.read_text(encoding="utf-8") if path.exists() else "# Clean split counts\n"
    marker = "\n## Splits\n"
    head = existing.split(marker)[0].rstrip()
    line_n = scan_result["line_n"]
    song_n = scan_result["song_n"]
    artists = set()
    for split in SPLITS:
        artists.update(song_n[split])
    ranked = sorted(
        artists,
        key=lambda artist: (
            -sum(line_n[split][artist] for split in SPLITS),
            artist.lower(),
        ),
    )
    markers = scan_result["markers"]
    missing_bpm = scan_result["missing_bpm"]
    missing_scale = scan_result["missing_scale"]
    rows = [
        head,
        "",
        "Songs were moved whole after the leak check. Line text was not edited.",
        "",
        "## Splits",
        "",
        "| Split | Songs | Lyric lines | Section markers | Artists | Songs missing BPM | Songs missing scale |",
        "| --- | ---: | ---: | ---: | ---: | ---: | ---: |",
    ]
    total_songs = 0
    total_lines = 0
    total_markers = 0
    total_bpm = 0
    total_scale = 0
    for split in SPLITS:
        songs = sum(song_n[split].values())
        lines = sum(line_n[split].values())
        total_songs += songs
        total_lines += lines
        total_markers += markers[split]
        total_bpm += missing_bpm[split]
        total_scale += missing_scale[split]
        rows.append(
            f"| {split} | {songs:,} | {lines:,} | {markers[split]:,} | "
            f"{len(song_n[split]):,} | {missing_bpm[split]:,} | {missing_scale[split]:,} |"
        )
    rows.append(
        f"| total | {total_songs:,} | {total_lines:,} | {total_markers:,} | "
        f"{len(artists):,} | {total_bpm:,} | {total_scale:,} |"
    )
    rows.extend(
        [
            "",
            "## Lines and songs per artist",
            "",
            "| Artist | Train songs | Train lines | Val songs | Val lines | Test songs | Test lines | Total songs | Total lines |",
            "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
        ]
    )
    for artist in ranked:
        cells = [artist.replace("|", "\\|")]
        total_s = 0
        total_l = 0
        for split in SPLITS:
            songs = song_n[split][artist]
            lines = line_n[split][artist]
            total_s += songs
            total_l += lines
            cells.append(f"{songs:,}")
            cells.append(f"{lines:,}")
        cells.append(f"{total_s:,}")
        cells.append(f"{total_l:,}")
        rows.append("| " + " | ".join(cells) + " |")
    rows.append("")
    path.write_text("\n".join(rows) + "\n", encoding="utf-8")


def main() -> int:
    paths = {split: OUT / f"{split}.jsonl" for split in SPLITS}
    for path in paths.values():
        if not path.exists():
            print("missing", path)
            return 1
    print("scan", flush=True)
    first = scan(paths)
    for name, ids in first["shared_ids"].items():
        print(f"shared_ids {name} {len(ids)}", flush=True)
    for name in ("train-test", "train-val", "val-test"):
        print(
            f"grams {name} allowed {first['pair_allowed'][name]} over {first['pair_over'][name]}",
            flush=True,
        )
    moves: dict[str, str] = {}
    examples_out = []
    shared_all: set[str] = set()
    for ids in first["shared_ids"].values():
        shared_all.update(ids)
    keep_split: dict[str, str] = {}
    for split in SPLITS:
        for song_id in first["ids"][split]:
            if song_id not in shared_all:
                continue
            current = keep_split.get(song_id)
            if current is None or PREFER[split] > PREFER[current]:
                keep_split[song_id] = split
    heavy = {
        digest
        for digest, packed in first["counts"].items()
        if sum(unpack(packed)) > CAP
    }
    if first["leak_hashes"] or keep_split:
        print(
            f"collect leaks {len(first['leak_hashes']):,} heavy {len(heavy):,}",
            flush=True,
        )
        members, examples, split_of = collect_leaks(paths, heavy)
        phrases = examples.pop("__phrases__", {})
        ranked = sorted(
            first["leak_hashes"],
            key=lambda digest: sum(unpack(first["counts"][digest])),
            reverse=True,
        )
        for digest in ranked[:20]:
            train, val, test = unpack(first["counts"][digest])
            samples = examples.get(digest, [])
            examples_out.append(
                {
                    "phrase": phrases.get(digest, ""),
                    "train": train,
                    "val": val,
                    "test": test,
                    "samples": samples,
                }
            )
            print(
                f"LEAK {train}/{val}/{test} {phrases.get(digest, '')[:80]}",
                flush=True,
            )
        if members:
            moves = assign_destinations(members, split_of)
        print(f"moves {len(moves):,} duplicate_song_ids {len(keep_split):,}", flush=True)
        if moves or keep_split:
            written = apply_moves(paths, moves, keep_split)
            print(
                "rewrote",
                " ".join(f"{split} {written[split]}" for split in SPLITS),
                flush=True,
            )
    else:
        print("no song-id overlap and no sequence over the cap", flush=True)
    print("rescan", flush=True)
    second = scan(paths)
    remaining = sum(second["pair_over"].values())
    shared_left = sum(len(ids) for ids in second["shared_ids"].values())
    print(f"remaining_over_pairs {remaining} shared_ids {shared_left}", flush=True)
    dist = distribution(second)
    print(
        f"artist_wad_pp {dist['wad'] * 100:.3f} outliers {len(dist['outliers'])} artists {dist['artists']}",
        flush=True,
    )
    for row in dist["big"][:8]:
        shares = row["shares"]
        print(
            f"ART {row['artist']} train {shares['train'] * 100:.2f} val {shares['val'] * 100:.2f} test {shares['test'] * 100:.2f}",
            flush=True,
        )
    moved_detail: Counter[str] = Counter(moves.values())
    report = {
        "shared_ids": first["shared_ids"],
        "dup_inside": first["dup_inside"],
        "pair_allowed": first["pair_allowed"],
        "pair_over": first["pair_over"],
        "moved": len(moves),
        "moved_detail": moved_detail,
        "remaining_over": remaining,
        "examples": examples_out,
        "distribution": dist,
    }
    report_path = OUT / "leak_report.md"
    write_report(report_path, report)
    print("WROTE", report_path)
    if moves or keep_split:
        refresh_split_counts(second)
        print("WROTE", OUT / "split_counts.md")
    if remaining or shared_left or sum(second["dup_inside"].values()):
        print("STILL_LEAKING")
        return 1
    print("CLEAN")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
