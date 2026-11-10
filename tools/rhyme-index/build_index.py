#!/usr/bin/env python3
"""Build the bundled rhyme index from finished rhyme-pair files.

Reads the odd and even worktrees. Does not write to them.
core = Y only. Keys are RhymeHighlighterEngine.endGroupKey.
"""
from __future__ import annotations

import csv
import json
import random
import re
import sqlite3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from appkey import RHYME_STOPWORDS, end_group_key

csv.field_size_limit(10_000_000)

ROOT = Path("/Users/samuel/.grok/worktrees/pennwork-rhyme-index")
ODD = Path("/Users/samuel/.grok/worktrees/pennwork-rhymes-gunna/docs/rhymes")
EVEN = Path("/Users/samuel/.grok/worktrees/pennwork-rhymes-young-thug/docs/rhymes")
OUT_DIR = ROOT / "XJournal AI" / "Resources" / "RhymeIndex"
VAULT = (
    "file:/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/"
    "tools/bar-hits-catalog/BarHitsCatalog.sqlite?mode=ro&immutable=1"
)
EXPECTED_VAULT = 1708472
WORD_LIMIT = 30
CUT_LIMIT = 20
MIN_CORE = 500
MAX_BYTES = 25 * 1024 * 1024
ADLIBS = {
    "yeah", "yea", "yuh", "ya", "uh", "uhh", "um", "umm", "woo", "woah", "whoa",
    "huh", "mm", "mmm", "hmm", "ha", "haha", "hah", "ay", "ayy", "ayyy", "okay",
    "ok", "nah", "na", "ooh", "ohh", "ah", "ahh", "hey", "oh", "ooo", "skrrt",
    "skrt", "skrrrt", "yo", "uhhuh", "uhuh", "wooo", "ayeeee",
}
TOKEN_RE = re.compile(r"[A-Za-z0-9']+")


class Stat:
    __slots__ = ("word", "n", "e", "i", "bar", "song", "blen")

    def __init__(self, word):
        self.word = word
        self.n = 0
        self.e = 0
        self.i = 0
        self.bar = ""
        self.song = ""
        self.blen = 10 ** 9


def vault_count():
    con = sqlite3.connect(VAULT, uri=True)
    try:
        return con.execute("SELECT COUNT(*) FROM bars").fetchone()[0]
    finally:
        con.close()


def parse_table(path: Path, header_prefix: str):
    rows = []
    started = False
    for line in path.read_text().splitlines():
        if line.startswith(header_prefix):
            started = True
            continue
        if not started:
            continue
        if line.startswith("|---") or line.startswith("| ---"):
            continue
        if not line.startswith("|"):
            break
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        rows.append(cells)
    return rows


def odd_artists():
    rows = parse_table(ODD / "_queue_odd.md", "| rank |")
    artists = []
    for cells in rows:
        artists.append({
            "name": cells[1],
            "slug": cells[2],
            "side": "odd",
            "path": ODD / cells[2] / "rhyme_pairs.csv",
        })
    artists.append({
        "name": "Gunna",
        "slug": "gunna",
        "side": "odd",
        "path": ODD / "gunna" / "rhyme_pairs.csv",
    })
    return artists


def even_artists():
    progress = (EVEN / "_progress_even.md").read_text().splitlines()
    finished = []
    in_queue = False
    for line in progress:
        if line.startswith("| # |"):
            in_queue = True
            continue
        if not in_queue:
            continue
        if line.startswith("| ---"):
            continue
        if not line.startswith("|"):
            break
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) < 9 or not cells[8]:
            continue
        core = cells[7]
        if not core.isdigit():
            continue
        slug = cells[1]
        finished.append({
            "name": cells[2],
            "slug": slug,
            "side": "even",
            "path": EVEN / slug / "rhyme_pairs.csv",
            "core_reported": int(core),
        })
    thug = EVEN / "young-thug" / "rhyme_pairs.csv"
    if thug.exists() and not any(item["slug"] == "young-thug" for item in finished):
        finished.append({
            "name": "Young Thug",
            "slug": "young-thug",
            "side": "even",
            "path": thug,
            "core_reported": None,
        })
    return finished


def even_queue():
    rows = parse_table(EVEN / "_queue_even.md", "| Post-skip rank |")
    return [{"rank": cells[0], "name": cells[1], "slug": cells[4]} for cells in rows]


def clean_bar(bar: str) -> bool:
    text = bar.strip()
    if len(text) < 2:
        return False
    low = text.lower()
    if "<img" in low or "img src" in low or "[img" in low:
        return False
    if "you might also like" in low:
        return False
    if text[0] in "|«*":
        return False
    if text.startswith("(") and text.endswith(")"):
        return False
    if text.startswith("[") and text.endswith("]"):
        return False
    return True


def rhyme_token(raw: str):
    if not raw or "img" in raw.lower() and "<" in raw.lower():
        return None
    parts = TOKEN_RE.findall(raw)
    kept = []
    for part in parts:
        word = part.lower().replace("’", "'")
        if any(ch.isdigit() for ch in word):
            continue
        if word in ADLIBS or word in RHYME_STOPWORDS:
            continue
        letters = word.replace("'", "")
        if len(letters) < 2:
            continue
        kept.append(word)
    return kept[-1] if kept else None


def bump(bucket, key, word, kind, bar, song):
    words = bucket.get(key)
    if words is None:
        words = {}
        bucket[key] = words
    stat = words.get(word)
    if stat is None:
        stat = Stat(word)
        words[word] = stat
    stat.n += 1
    if kind == "END":
        stat.e += 1
    else:
        stat.i += 1
    if clean_bar(bar) and len(bar) < stat.blen:
        stat.bar = bar
        stat.song = song
        stat.blen = len(bar)


def consume(path: Path, local, global_bucket):
    core_rows = 0
    tried = 0
    keyed = 0
    with path.open(newline="") as handle:
        reader = csv.DictReader(handle)
        if not reader.fieldnames or "core" not in reader.fieldnames:
            raise RuntimeError("missing core column")
        for row in reader:
            if row.get("core") != "Y":
                continue
            core_rows += 1
            line_end = row.get("type") == "END"
            for word_field, bar in (
                (row.get("word_a") or "", row.get("bar_a") or ""),
                (row.get("word_b") or "", row.get("bar_b") or ""),
            ):
                token = rhyme_token(word_field)
                if token is None:
                    continue
                tried += 1
                key = end_group_key(token, line_end)
                if not key:
                    continue
                keyed += 1
                song = row.get("song") or ""
                bump(local, key, token, row.get("type") or "", bar, song)
                bump(global_bucket, key, token, row.get("type") or "", bar, song)
    return core_rows, tried, keyed


def trim(bucket, limit):
    out = {}
    for key, words in bucket.items():
        ranked = sorted(words.values(), key=lambda stat: (-stat.n, stat.word))[:limit]
        out[key] = [
            {
                "word": stat.word,
                "count": stat.n,
                "end": stat.e,
                "inner": stat.i,
                "bar": stat.bar,
                "song": stat.song,
            }
            for stat in ranked
        ]
    return out


def pack(artists_trimmed, all_trimmed):
    return {
        "version": 1,
        "core": "Y",
        "key": "endGroupKey",
        "words_per_key": WORD_LIMIT if artists_trimmed and next(iter(artists_trimmed.values())) else WORD_LIMIT,
        "artists": artists_trimmed,
        "All artists": all_trimmed,
    }


def dump_size(payload):
    text = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
    return text, len(text.encode("utf-8"))


def main():
    count = vault_count()
    print(f"VAULT {count}", flush=True)
    if count != EXPECTED_VAULT:
        raise SystemExit(f"vault {count}")
    odd = odd_artists()
    even = even_artists()
    queue = even_queue()
    print(f"ODD {len(odd)} EVEN_FINISHED {len(even)} EVEN_QUEUE {len(queue)}", flush=True)
    global_bucket = {}
    included = []
    tried = keyed = 0
    artist_maps = []
    for item in odd + even:
        if not item["path"].exists():
            print(f"MISSING_FILE {item['slug']}", flush=True)
            item["missing_file"] = True
            continue
        local = {}
        try:
            core_rows, one_tried, one_keyed = consume(item["path"], local, global_bucket)
        except Exception as exc:
            print(f"ARTIST_FAIL {item['name']} {exc}", flush=True)
            item["error"] = str(exc)
            continue
        tried += one_tried
        keyed += one_keyed
        trimmed = trim(local, WORD_LIMIT)
        artist_maps.append((item, core_rows, trimmed))
        print(f"OK {item['side']} {item['name']} core {core_rows} keys {len(trimmed)}", flush=True)
        del local
    all_full = trim(global_bucket, WORD_LIMIT)
    del global_bucket
    artists_obj = {item["name"]: trimmed for item, _, trimmed in artist_maps}
    payload = {
        "version": 1,
        "core": "Y",
        "key": "endGroupKey",
        "words_per_key": WORD_LIMIT,
        "artists": artists_obj,
        "All artists": all_full,
    }
    text, size = dump_size(payload)
    dropped = []
    cut = False
    if size > MAX_BYTES:
        cut = True
        kept_maps = []
        for item, core_rows, trimmed in artist_maps:
            if core_rows < MIN_CORE:
                dropped.append({"name": item["name"], "slug": item["slug"], "side": item["side"], "core_pairs": core_rows})
                continue
            slim = {key: words[:CUT_LIMIT] for key, words in trimmed.items()}
            kept_maps.append((item, core_rows, slim))
        all_slim = {key: words[:CUT_LIMIT] for key, words in all_full.items()}
        artists_obj = {item["name"]: trimmed for item, _, trimmed in kept_maps}
        payload = {
            "version": 1,
            "core": "Y",
            "key": "endGroupKey",
            "words_per_key": CUT_LIMIT,
            "dropped_under_core_pairs": MIN_CORE,
            "artists": artists_obj,
            "All artists": all_slim,
        }
        text, size = dump_size(payload)
        artist_maps = kept_maps
        all_full = all_slim
    extra_dropped = []
    extra_keys = 0
    extra_floor = None
    if size > MAX_BYTES:
        # The 20-word / under-500 cut is still over 25 MB.
        # Raise the per-artist use floor until the file fits. All artists stays whole.
        cut = True
        base_artists = artists_obj
        lo, hi = 2, 800
        best = None
        while lo <= hi:
            floor = (lo + hi) // 2
            shrunk = {}
            dropped_names = []
            dropped_keys = 0
            for name, keys in base_artists.items():
                kept = {}
                for key, words in keys.items():
                    if sum(word["count"] for word in words) >= floor:
                        kept[key] = words
                    else:
                        dropped_keys += 1
                if kept:
                    shrunk[name] = kept
                else:
                    dropped_names.append(name)
            payload["artists"] = shrunk
            payload["extra_cut"] = (
                f"per-artist keys under {floor} uses dropped to stay under 25 MB"
            )
            trial, trial_size = dump_size(payload)
            if trial_size <= MAX_BYTES:
                best = (floor, shrunk, dropped_names, dropped_keys, trial, trial_size)
                hi = floor - 1
            else:
                lo = floor + 1
        if best is None:
            raise SystemExit(f"still over 25 MB after use-floor 800: {size}")
        extra_floor, artists_obj, extra_dropped, extra_keys, text, size = best
        payload["artists"] = artists_obj
        payload["extra_cut"] = (
            f"per-artist keys under {extra_floor} uses dropped to stay under 25 MB"
        )
    if size > MAX_BYTES:
        raise SystemExit(f"refusing to write {size} bytes over 25 MB")
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "rhyme_index.json").write_text(text)
    finished_slugs = {item["slug"] for item, _, _ in artist_maps}
    # Finished even that were read, plus ones skipped for size, are not "missing".
    read_even = {item["slug"] for item, _, _ in artist_maps if item["side"] == "even"}
    read_even |= {item["slug"] for item in even if item["slug"] not in {d["slug"] for d in dropped} or True}
    present_even = {item["slug"] for item in even if not item.get("missing_file") and not item.get("error")}
    missing = []
    for item in queue:
        if item["slug"] not in present_even:
            missing.append(item)
    kept_names = set(artists_obj)
    by_name = {item["name"]: (item, core_rows) for item, core_rows, _ in artist_maps}
    extra_removed = []
    for name in extra_dropped:
        item, core_rows = by_name[name]
        extra_removed.append({
            "name": item["name"],
            "slug": item["slug"],
            "side": item["side"],
            "core_pairs": core_rows,
        })
    artist_rows = []
    for item, core_rows, _ in artist_maps:
        if item["name"] not in kept_names:
            continue
        artist_rows.append({
            "name": item["name"],
            "slug": item["slug"],
            "side": item["side"],
            "core_pairs": core_rows,
        })
    artists_doc = {
        "artists": artist_rows,
        "all": "All artists",
        "dropped_under_500_core_pairs": dropped,
        "extra_cut_removed": extra_removed,
        "missing_even": missing,
        "vault_bars": count,
    }
    (OUT_DIR / "artists.json").write_text(json.dumps(artists_doc, ensure_ascii=False, indent=2) + "\n")
    odd_n = sum(1 for row in artist_rows if row["side"] == "odd")
    even_n = sum(1 for row in artist_rows if row["side"] == "even")
    gunna = artists_obj.get("Gunna", {})
    gunna_top = sorted(
        ((key, sum(word["count"] for word in words)) for key, words in gunna.items()),
        key=lambda item: -item[1],
    )[:10]
    lookups = []
    pool = []
    for name, keys in artists_obj.items():
        for key, words in keys.items():
            if words:
                pool.append((name, key, words[0]))
    rng = random.Random(20261109)
    if len(pool) > 10:
        picks = rng.sample(pool, 10)
    else:
        picks = pool
    for name, key, word in picks:
        lookups.append({
            "artist": name,
            "key": key,
            "word": word["word"],
            "count": word["count"],
            "end": word["end"],
            "inner": word["inner"],
            "song": word["song"],
            "bar": word["bar"],
        })
    rate = (keyed / tried) if tried else 0
    index_path = OUT_DIR / "rhyme_index.json"
    artists_path = OUT_DIR / "artists.json"
    report = [
        "# Rhyme index",
        "",
        f"Vault bars {count}.",
        "Output folder: `XJournal AI/Resources/RhymeIndex/`. Main has no bundled JSON data folder, so this is the folder the job named.",
        "Keys are `RhymeHighlighterEngine.endGroupKey` from ContentView.CCV.3.swift. `rime()` is the phonetic rime key.",
        "Pairs are core = Y only. Ad-libs, rhyme stopwords, words under 2 letters, and tokens with digits or img tags are skipped.",
        "",
        "## Artists",
        "",
        f"Included {len(artist_rows)}. Odd {odd_n}. Even {even_n}.",
        f"Source rows read: odd {len(odd)} (387 odd-rank artists plus Gunna), even {len(even)} (finished progress rows plus Young Thug).",
        f"Key-match rate {keyed}/{tried} = {rate:.1%}. A token counts once it passes the skip list. A match is a token that received an end-group key.",
        f"rhyme_index.json {size} bytes ({size / 1024 / 1024:.2f} MB). artists.json {artists_path.stat().st_size} bytes.",
        f"Words per key {payload['words_per_key']}. Cut applied: {cut}.",
        (
            f"Extra cut: per-artist keys under {extra_floor} uses dropped "
            f"({extra_keys} keys). Artists removed by that cut: {len(extra_dropped)}. "
            "The All artists map was kept."
            if extra_floor is not None
            else "Extra cut: none."
        ),
        "",
        "## Gunna top 10 keys",
        "",
        "| key | uses |",
        "|---|---:|",
    ]
    for key, uses in gunna_top:
        report.append(f"| {key} | {uses} |")
    report += ["", "## 10 random lookups", "", "Seed 20261109.", ""]
    for item in lookups:
        report.append(
            f"- {item['artist']} · {item['key']} · {item['word']} · count {item['count']} · end {item['end']} · inner {item['inner']} · {item['song']}"
        )
        report.append(f"  \"{item['bar']}\"")
    if dropped:
        report += ["", "## Dropped under 500 core pairs", ""]
        for item in dropped:
            report.append(f"- {item['name']} ({item['side']}) core {item['core_pairs']}")
    if extra_removed:
        report += ["", "## Removed by the use-floor cut", ""]
        for item in extra_removed:
            report.append(f"- {item['name']} ({item['side']}) core {item['core_pairs']}")
    report += ["", "## Even-rank artists still missing", ""]
    if not missing:
        report.append("None.")
    for item in missing:
        report.append(f"- {item['name']} ({item['slug']}), post-skip rank {item['rank']}")
    report.append("")
    (ROOT / "tools" / "rhyme-index" / "report.md").write_text("\n".join(report))
    print(f"WROTE {index_path} {size} artists {len(artist_rows)} missing_even {len(missing)}", flush=True)
    print(f"RATE {keyed}/{tried}", flush=True)


if __name__ == "__main__":
    main()
