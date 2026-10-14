#!/usr/bin/env python3
"""AI Sparkler style profile — Phase 1: deterministic per-song metrics.

Reads the ground-truth bar CSV and writes one JSONL row per song plus one
rollup row per artist. No network, no LLM. Rhyme/cadence come from CMUdict
(`XJournal AI/cmudict.txt`). Percentile grades, BPM/key, topic chains and
wordplay come in later phases (see docs/play-on-words/ai-sparkler-style-profile-phases.md).

Usage:
  python3 tools/style-profile/phase1_song_metrics.py --artists "Gunna,J. Cole"
  python3 tools/style-profile/phase1_song_metrics.py            # whole catalog
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import statistics
import sys
from collections import Counter, defaultdict
from pathlib import Path

SCHEMA_VERSION = "phase1.v1"
ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CSV = ROOT / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv"
DEFAULT_CMU = ROOT / "XJournal AI" / "cmudict.txt"
DEFAULT_OUT = ROOT / "tools" / "style-profile" / "out"

MIN_BARS_CONFIDENT = 16
END_LOOKBACK = 6  # bars back to look for an end-rhyme partner

WORD_RE = re.compile(r"[a-z0-9']+")
ADLIB_RE = re.compile(r"\([^)]*\)|\[[^\]]*\]")
PAUSE_RE = re.compile(r"[,;:.!?—–…]|--|\s-\s")

STOPWORDS = frozenset(
    """a an the and or but so if of to in on at by for with from as is are was were be been am
    i me my mine you your yours he him his she her hers we us our they them their it its that this
    these those there here what who whom which when where why how not no yes do does did done
    have has had will would can could should shall may might must just got get gon gonna wanna
    like then than too very all some any more most ya yeah uh huh aye ay oh ooh woah yo""".split()
)

# ---------------------------------------------------------------- CMUdict


def load_cmudict(path: Path) -> dict[str, list[str]]:
    table: dict[str, list[str]] = {}
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            if line.startswith(";;;") or not line.strip():
                continue
            parts = line.split()
            word = re.sub(r"\(\d+\)$", "", parts[0]).lower()
            if word not in table:
                table[word] = parts[1:]
    return table


class Lexicon:
    """word -> WordInfo with a cache; handles rap spellings (tryin', 'bout, y'all)."""

    def __init__(self, cmu: dict[str, list[str]]):
        self.cmu = cmu
        self.cache: dict[str, tuple | None] = {}

    def phones_for(self, word: str) -> list[str] | None:
        w = word.lower()
        for cand in self._candidates(w):
            if cand in self.cmu:
                return self.cmu[cand]
        return None

    @staticmethod
    def _candidates(w: str):
        yield w
        if w.endswith("in'"):
            yield w[:-3] + "ing"
        if w.endswith("'s"):
            yield w[:-2]
        stripped = w.strip("'")
        if stripped != w:
            yield stripped
            if stripped.endswith("in"):
                yield stripped + "g"
        if w.endswith("in") and len(w) > 4:
            yield w + "g"
        if w.endswith("s'"):
            yield w[:-1]

    def info(self, word: str):
        """(syllables, stressed_count, rime_key, v2_key, known) — cached."""
        if word in self.cache:
            return self.cache[word]
        phones = self.phones_for(word)
        if phones is None:
            syl = max(1, len(re.findall(r"[aeiouy]+", word))) if re.search(r"[a-z]", word) else 0
            res = (syl, 0, None, None, False)
        else:
            res = analyze_phones(phones)
        self.cache[word] = res
        return res


def analyze_phones(phones: list[str]):
    vowel_idx = [i for i, p in enumerate(phones) if p[-1].isdigit()]
    syl = len(vowel_idx)
    if syl == 0:
        return (0, 0, None, None, True)
    stresses = [phones[i][-1] for i in vowel_idx]
    stressed = sum(1 for s in stresses if s in "12")
    # stressed rime: from the last primary-stressed vowel (else last secondary, else last vowel)
    anchor = None
    for want in ("1", "2"):
        for i in reversed(vowel_idx):
            if phones[i][-1] == want:
                anchor = i
                break
        if anchor is not None:
            break
    if anchor is None:
        anchor = vowel_idx[-1]
    rime_key = " ".join(re.sub(r"\d", "", p) for p in phones[anchor:])
    v2_key = None
    if syl >= 2:
        v2_key = " ".join(re.sub(r"\d", "", phones[i]) for i in vowel_idx[-2:])
    return (syl, stressed, rime_key, v2_key, True)


def trailing_vowel_depth(a: list[str], b: list[str]) -> int:
    va = [re.sub(r"\d", "", p) for p in a if p[-1].isdigit()]
    vb = [re.sub(r"\d", "", p) for p in b if p[-1].isdigit()]
    d = 0
    while d < min(len(va), len(vb)) and va[-1 - d] == vb[-1 - d]:
        d += 1
    return min(d, 4)


# ---------------------------------------------------------------- per-bar parsing


class Bar:
    __slots__ = ("raw", "words", "syl", "stressed", "known_syl", "rime", "v2",
                 "end_word", "end_phones", "pauses", "adlib", "oov")

    def __init__(self, raw: str, lex: Lexicon):
        self.raw = raw
        self.adlib = bool(ADLIB_RE.search(raw))
        body = ADLIB_RE.sub(" ", raw).replace("’", "'").replace("‘", "'").lower()
        self.pauses = len(PAUSE_RE.findall(body))
        self.words = [w for w in (t.strip("'") or t for t in WORD_RE.findall(body)) if w and not w.isdigit()]
        self.syl = 0
        self.stressed = 0
        self.known_syl = 0
        self.rime: list[str | None] = []
        self.v2: list[str | None] = []
        self.oov = 0
        for w in self.words:
            s, st, rk, vk, known = lex.info(w)
            self.syl += s
            if known:
                self.known_syl += s
                self.stressed += st
            else:
                self.oov += 1
            self.rime.append(rk)
            self.v2.append(vk)
        self.end_word = self.words[-1] if self.words else None
        self.end_phones = lex.phones_for(self.end_word) if self.end_word else None


def norm_line(raw: str) -> str:
    return " ".join(WORD_RE.findall(ADLIB_RE.sub(" ", raw).replace("’", "'").lower()))


# ---------------------------------------------------------------- song metrics


def pct(n: float, d: float) -> float:
    return round(100.0 * n / d, 2) if d else 0.0


def song_metrics(bars: list[Bar], total_raw_bars: int) -> dict:
    n = len(bars)
    out: dict = {"bars": n, "dup_bar_pct": pct(total_raw_bars - n, total_raw_bars)}

    # ---- cadence
    syl = [b.syl for b in bars if b.syl > 0]
    if syl:
        qs = statistics.quantiles(syl, n=10) if len(syl) >= 2 else [syl[0]] * 9
        mean = statistics.fmean(syl)
        sd = statistics.pstdev(syl)
        known = sum(b.known_syl for b in bars)
        out["cadence"] = {
            "syl_per_bar_mean": round(mean, 2),
            "syl_per_bar_median": statistics.median(syl),
            "syl_per_bar_std": round(sd, 2),
            "syl_per_bar_cv": round(sd / mean, 3) if mean else 0.0,
            "syl_per_bar_p10": qs[0],
            "syl_per_bar_p90": qs[-1],
            "short_bar_pct": pct(sum(1 for s in syl if s <= 6), len(syl)),
            "long_bar_pct": pct(sum(1 for s in syl if s >= 16), len(syl)),
            "stress_density": round(sum(b.stressed for b in bars) / known, 3) if known else None,
            "pauses_per_bar": round(statistics.fmean(b.pauses for b in bars), 2),
            "adlib_bar_pct": pct(sum(1 for b in bars if b.adlib), n),
        }
    else:
        out["cadence"] = None

    # ---- vocabulary
    toks = [w for b in bars for w in b.words]
    out["vocab"] = {
        "tokens": len(toks),
        "unique": len(set(toks)),
        "unique_per_100": round(100 * len(set(toks)) / len(toks), 1) if toks else 0.0,
        "mattr_100": _mattr(toks, 100),
        "oov_pct": pct(sum(b.oov for b in bars), max(1, len(toks))),
    }

    out["end_rhyme"] = _end_rhyme(bars)
    out["internal_rhyme"] = _internal_rhyme(bars)
    return out


def _mattr(toks: list[str], window: int):
    if len(toks) < window:
        return None
    counts: Counter = Counter(toks[:window])
    total = len(counts)
    n = 1
    for i in range(window, len(toks)):
        old = toks[i - window]
        counts[old] -= 1
        if counts[old] == 0:
            del counts[old]
        counts[toks[i]] += 1
        total += len(counts)
        n += 1
    return round(total / (n * window), 3)


def _end_rhyme(bars: list[Bar]) -> dict:
    usable = [b for b in bars if b.end_phones and b.rime and b.rime[-1]]
    if len(usable) < 4:
        return {"scored_bars": len(usable), "end_rhyme_pct": None}
    matched = perfect_pairs = slant_pairs = multi_pairs = 0
    dist = Counter()
    depths = []
    pair_keys: Counter = Counter()
    for i, b in enumerate(usable):
        best = None  # (distance, kind, depth)
        for d in range(1, END_LOOKBACK + 1):
            if i - d < 0:
                break
            p = usable[i - d]
            if p.end_word == b.end_word:
                continue
            rk_b, rk_p = b.rime[-1], p.rime[-1]
            depth = trailing_vowel_depth(b.end_phones, p.end_phones)
            if rk_b == rk_p:
                kind = "perfect"
            elif depth >= 1 and _stressed_vowel(rk_b) == _stressed_vowel(rk_p):
                kind = "slant"
            else:
                continue
            best = (d, kind, depth, rk_b)
            break
        if best:
            matched += 1
            d, kind, depth, key = best
            dist["couplet" if d == 1 else "alternate" if d == 2 else "far"] += 1
            perfect_pairs += kind == "perfect"
            slant_pairs += kind == "slant"
            multi_pairs += depth >= 2
            depths.append(depth)
            pair_keys[key] += 1
    n = len(usable)
    rimes = [b.rime[-1] for b in usable]
    return {
        "scored_bars": n,
        "end_rhyme_pct": pct(matched, n),
        "perfect_pct": pct(perfect_pairs, n),
        "slant_pct": pct(slant_pairs, n),
        "multisyllabic_pct": pct(multi_pairs, n),
        "mean_depth": round(statistics.fmean(depths), 2) if depths else 0.0,
        "scheme_share": {k: pct(v, matched) for k, v in dist.items()} if matched else {},
        "rhyme_family_reuse": round(1 - len(set(rimes)) / n, 3),
        "pair_keys": dict(pair_keys.most_common(12)),
    }


def _stressed_vowel(rime_key: str) -> str:
    return rime_key.split(" ", 1)[0]


def _content_positions(b: Bar):
    return [i for i, w in enumerate(b.words) if w not in STOPWORDS and b.rime[i]]


def _internal_rhyme(bars: list[Bar]) -> dict:
    scored = 0
    with_internal = pairs_total = mid_end = max_group_total = 0
    max_group = 0
    cross = 0
    cross_denom = 0
    for idx, b in enumerate(bars):
        pos = _content_positions(b)
        if len(pos) < 2:
            continue
        scored += 1
        groups: dict[str, set[str]] = defaultdict(set)
        for i in pos:
            groups[b.rime[i]].add(b.words[i])
            if b.v2[i]:
                groups["v2:" + b.v2[i]].add(b.words[i])
        # count distinct-word groups of size >=2; skip a v2 group that only repeats a rime group
        multi = [sorted(ws) for ws in groups.values() if len(ws) >= 2]
        if multi:
            with_internal += 1
            pair_set = {(x, y) for ws in multi for i, x in enumerate(ws) for y in ws[i + 1:]}
            pairs_total += len(pair_set)
            biggest = max(len(ws) for ws in multi)
            max_group = max(max_group, biggest)
            max_group_total += biggest
        last = len(b.words) - 1
        if last in pos:
            end_keys = {b.rime[last]} | ({"v2:" + b.v2[last]} if b.v2[last] else set())
            for k in end_keys:
                if len(groups[k] - {b.words[last]}) >= 1:
                    mid_end += 1
                    break
        # cross-bar: a non-final word's key shows up in the next bar
        if idx + 1 < len(bars):
            nxt = bars[idx + 1]
            npos = _content_positions(nxt)
            if npos:
                cross_denom += 1
                keys_here = {b.rime[i] for i in pos if i != last} | {"v2:" + b.v2[i] for i in pos if i != last and b.v2[i]}
                words_here = {b.words[i] for i in pos}
                hit = False
                for j in npos:
                    if nxt.words[j] in words_here:
                        continue
                    if nxt.rime[j] in keys_here or (nxt.v2[j] and "v2:" + nxt.v2[j] in keys_here):
                        hit = True
                        break
                cross += hit
    if scored < 4:
        return {"scored_bars": scored, "internal_bar_pct": None}
    return {
        "scored_bars": scored,
        "internal_bar_pct": pct(with_internal, scored),
        "pairs_per_bar": round(pairs_total / scored, 3),
        "max_group_in_bar": max_group,
        "mean_group_when_present": round(max_group_total / with_internal, 2) if with_internal else 0.0,
        "mid_to_end_pct": pct(mid_end, scored),
        "cross_bar_pct": pct(cross, cross_denom),
    }


# ---------------------------------------------------------------- IO


def trailing_number(text_id: str) -> int:
    m = re.search(r"(\d+)$", text_id)
    return int(m.group(1)) if m else 0


def read_songs(csv_path: Path, artists: set[str] | None):
    csv.field_size_limit(sys.maxsize)
    songs: dict[tuple[str, str], dict] = {}
    with open(csv_path, newline="", encoding="utf-8", errors="replace") as fh:
        reader = csv.reader(fh)
        header = next(reader)
        col = {name: i for i, name in enumerate(header)}
        c_id, c_art, c_song, c_alb, c_text, c_year = 0, col["artist"], col["song"], col["album"], col["text_bar_line"], col["year"]
        for row in reader:
            if len(row) <= c_text:
                continue
            art, song, text = row[c_art].strip(), row[c_song].strip(), row[c_text].strip()
            if art in ("", "artist") or not song or not text:
                continue
            if artists and art.lower() not in artists:
                continue
            rec = songs.setdefault((art, song), {"album": row[c_alb], "year": row[c_year], "lines": []})
            rec["lines"].append((trailing_number(row[c_id]), text))
    return songs


NUMERIC_PATHS = [
    ("cadence", "syl_per_bar_mean"), ("cadence", "syl_per_bar_cv"), ("cadence", "stress_density"),
    ("cadence", "pauses_per_bar"), ("vocab", "unique_per_100"), ("vocab", "mattr_100"),
    ("end_rhyme", "end_rhyme_pct"), ("end_rhyme", "perfect_pct"), ("end_rhyme", "slant_pct"),
    ("end_rhyme", "multisyllabic_pct"), ("end_rhyme", "mean_depth"), ("end_rhyme", "rhyme_family_reuse"),
    ("internal_rhyme", "internal_bar_pct"), ("internal_rhyme", "pairs_per_bar"),
    ("internal_rhyme", "mid_to_end_pct"), ("internal_rhyme", "cross_bar_pct"),
]


def spread(vals: list[float]) -> dict:
    vals = sorted(vals)
    q = statistics.quantiles(vals, n=10) if len(vals) >= 2 else [vals[0]] * 9
    return {
        "n": len(vals), "mean": round(statistics.fmean(vals), 3), "median": round(statistics.median(vals), 3),
        "std": round(statistics.pstdev(vals), 3), "min": vals[0], "p10": round(q[0], 3),
        "p90": round(q[-1], 3), "max": vals[-1],
    }


def artist_rollup(artist: str, rows: list[dict]) -> dict:
    conf = [r for r in rows if r["confident"]]
    out = {"artist": artist, "schema": SCHEMA_VERSION, "songs": len(rows), "confident_songs": len(conf),
           "bars": sum(r["bars"] for r in rows), "metrics": {}}
    for sect, key in NUMERIC_PATHS:
        vals = [r[sect][key] for r in conf if r.get(sect) and r[sect].get(key) is not None]
        if vals:
            out["metrics"][f"{sect}.{key}"] = spread(vals)
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    ap.add_argument("--cmudict", type=Path, default=DEFAULT_CMU)
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--artists", help="comma-separated artist names (case-insensitive); default all")
    ap.add_argument("--tag", default="", help="suffix for output filenames, e.g. pilot")
    args = ap.parse_args()

    artists = {a.strip().lower() for a in args.artists.split(",")} if args.artists else None
    lex = Lexicon(load_cmudict(args.cmudict))
    songs = read_songs(args.csv, artists)
    args.out.mkdir(parents=True, exist_ok=True)
    suffix = f"_{args.tag}" if args.tag else ""
    song_path = args.out / f"song_metrics{suffix}.jsonl"
    artist_path = args.out / f"artist_rollup{suffix}.jsonl"

    by_artist: dict[str, list[dict]] = defaultdict(list)
    with open(song_path, "w", encoding="utf-8") as fh:
        for (art, song), rec in sorted(songs.items()):
            lines = [t for _, t in sorted(rec["lines"], key=lambda x: x[0])]
            seen, uniq = set(), []
            for t in lines:
                k = norm_line(t)
                if k and k not in seen:
                    seen.add(k)
                    uniq.append(t)
            bars = [Bar(t, lex) for t in uniq]
            row = {"schema": SCHEMA_VERSION, "artist": art, "song": song, "album": rec["album"], "year": rec["year"],
                   "confident": len(bars) >= MIN_BARS_CONFIDENT}
            row.update(song_metrics(bars, len(lines)))
            fh.write(json.dumps(row, ensure_ascii=False) + "\n")
            by_artist[art].append(row)

    with open(artist_path, "w", encoding="utf-8") as fh:
        for art, rows in sorted(by_artist.items()):
            fh.write(json.dumps(artist_rollup(art, rows), ensure_ascii=False) + "\n")

    print(f"{len(songs)} songs, {len(by_artist)} artists -> {song_path} , {artist_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
