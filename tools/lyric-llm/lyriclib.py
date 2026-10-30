"""Shared prep, scoring, and prompt pieces for the Penwork lyric model.

No lyric text is logged from here. Callers print counts and scores.
"""

from __future__ import annotations

import hashlib
import json
import random
import re
import sqlite3
import statistics
from collections import Counter
from pathlib import Path
from typing import Iterable, Iterator, Optional, Sequence

WORD_RE = re.compile(r"[a-z0-9']+")
SECTION_RE = re.compile(r"^\s*[\[\(].*[\]\)]\s*$")
HEAVY_SHARE = 0.04
MIN_CROSS_TOKENS = 4
MAX_COPIES_IN_SONG = 4
MAX_SHORT_COPIES = 2
NEAR_HAMMING = 3
CHUNK_LINES = 8
MIN_CHUNK = 4
SPLIT_RATIOS = (0.95, 0.03, 0.02)
# Under 200 train lines is about 25 eight-line windows or fewer, split across
# songs. A shared rank-8 LoRA does not see that voice string often enough.
RELIABLE_VOICE_LINES = 200

ADLIB = frozenset(
    "yeah ya uh huh ay aye woah whoa ooh yo hmm nah ok okay uhm um oh ah ha".split()
)
SECTION_WORDS = frozenset(
    "verse chorus intro outro bridge hook refrain lyrics embed interlude prechorus".split()
)
JUNK = frozenset(
    {
        "you might also like",
        "embed",
        "lyrics",
        "see upcoming rap shows",
        "get tickets for your favorite artists",
    }
)

_BIT = tuple(1 << i for i in range(64))


_HOMOGLYPHS = str.maketrans({
    "а": "a", "е": "e", "о": "o", "р": "p", "с": "c", "у": "y", "х": "x", "і": "i", "ј": "j", "ѕ": "s",
    "А": "a", "Е": "e", "О": "o", "Р": "p", "С": "c", "У": "y", "Х": "x", "І": "i", "Ј": "j", "Ѕ": "s",
})

def normalize(text: str) -> str:
    import unicodedata
    # 1. Translate Cyrillic homoglyphs commonly found in scraped web lyrics
    text = text.translate(_HOMOGLYPHS)
    # 2. Decompose accented unicode characters to ascii base characters
    text = "".join(c for c in unicodedata.normalize("NFKD", text) if not unicodedata.combining(c))
    text = text.lower().replace("\u2019", "'").replace("\u2018", "'")
    text = text.replace("\u201c", " ").replace("\u201d", " ")
    text = re.sub(r"\[[^\]]*\]", " ", text)
    text = re.sub(r"\([^)]*\)", " ", text)
    text = re.sub(r"[^a-z0-9'\s]", " ", text)
    text = text.replace("'", "")
    return " ".join(text.split())


def tokenize(text: str) -> list[str]:
    return WORD_RE.findall(text)


def loose_key(tokens: Sequence[str]) -> Optional[str]:
    """Key for cross-song dedupe. Short ad-libs stay out of it."""
    if len(tokens) < MIN_CROSS_TOKENS:
        return None
    core = [t for t in tokens if t not in ADLIB]
    use = core if len(core) >= MIN_CROSS_TOKENS else list(tokens)
    return " ".join(use)


def tag_safe(value: str) -> str:
    cleaned = value.replace("<", " ").replace(">", " ")
    return " ".join(cleaned.split())


def bucket_bpm(bpm: Optional[float]) -> Optional[int]:
    if bpm is None:
        return None
    return int(round(float(bpm) / 5.0) * 5)


def estimate_syllables(text: str) -> int:
    total = 0
    for word in tokenize(normalize(text)):
        groups = re.findall(r"[aeiouy]+", word)
        if groups:
            total += len(groups)
        elif word:
            total += 1
    return max(1, total)


def simhash(tokens: Sequence[str]) -> int:
    if not tokens:
        return 0
    acc = [0] * 64
    bit = _BIT
    for tok in tokens:
        digest = hashlib.blake2s(tok.encode("utf-8"), digest_size=8).digest()
        h = int.from_bytes(digest, "little")
        for i in range(64):
            acc[i] += 1 if h & bit[i] else -1
    out = 0
    for i, value in enumerate(acc):
        if value > 0:
            out |= bit[i]
    return out


def hamming(a: int, b: int) -> int:
    return bin(a ^ b).count("1")


def sha_text(norm: str) -> str:
    return hashlib.sha1(norm.encode("utf-8")).hexdigest()


def stable_tie(song_id: str, key: str) -> int:
    digest = hashlib.sha1(f"{song_id}|{key}".encode("utf-8")).digest()
    return int.from_bytes(digest[:4], "big")


class NearDupIndex:
    """Banded simhash. A hit only counts when the earlier line is another song."""

    def __init__(self, ham: int = NEAR_HAMMING, band_bits: int = 16) -> None:
        self.ham = ham
        self.band_bits = band_bits
        self.nbands = 64 // band_bits
        self.mask = (1 << band_bits) - 1
        self.buckets: dict[tuple[int, int], list[tuple[int, str]]] = {}

    def bands(self, fp: int) -> Iterator[tuple[int, int]]:
        for band in range(self.nbands):
            yield band, (fp >> (band * self.band_bits)) & self.mask

    def seen_other(self, fp: int, song_id: str) -> bool:
        checked = 0
        for band, bits in self.bands(fp):
            bucket = self.buckets.get((band, bits), ())
            for other_fp, other_song in bucket[-48:]:
                checked += 1
                if other_song != song_id and hamming(other_fp, fp) <= self.ham:
                    return True
            if checked > 200:
                break
        return False

    def add(self, fp: int, song_id: str) -> None:
        for band, bits in self.bands(fp):
            self.buckets.setdefault((band, bits), []).append((fp, song_id))


SCRAPE_JUNK_RE = re.compile(
    r"^\s*\|"
    r"|aria-label\s*:"
    r"|cover art for\s+"
    r"|you might also like"
    r"|get tickets as low as\s+\$"
    r"|^see\s+.+\s+live$"
    r"|song bio\d*\s*contributors?"
    r"|\d+embed\s*$"
    r"|^embed\s*$"
    r"|post this song on facebook"
    r"|tweet this song"
    r"|use italics\s*\(<i>lyric</i>\)"
    r"|how to format lyrics:"
    r"|type out all lyrics, even"
    r"|use section headers above different song parts"
    r"|to learn more, check out our"
    r"|\.\.\.\s*read more\s*$"
    r"|https?://\S+"
    r"|^[\[\{][^\[\]\}]*$"
    r"|^[^\[\]\{]*[\]\}]$"
    r"|^\[\""
    r"|\"\]$"
    r"|^\"\"\s*"
    r"|(?:this is the (?:first|second|third|lead|title|final|only) (?:solo )?(?:song|single|track)|"
    r"collaborative album with|featured on (?:his|her|their) (?:album|mixtape|ep)|"
    r"produced by [A-Z]|released on [A-Z][a-z]+ \d+|peaked at number|"
    r"on the Billboard Hot 100|music video was directed by|"
    r"first previewed by|via (?:his|her|their) instagram|"
    r"serves as the \d+(?:st|nd|rd|th) track off)",
    re.I,
)


def is_junk_line(text: str) -> bool:
    raw = text.strip()
    if not raw or SECTION_RE.match(raw):
        return True
    if len(raw) > 160 or SCRAPE_JUNK_RE.search(raw):
        return True
    norm = normalize(raw)
    if not norm or norm in JUNK or norm in SECTION_WORDS:
        return True
    return False


def cap_in_song(lines: list[dict]) -> list[dict]:
    """Keep a few in-song repeats so a hook can still land twice."""
    counts: Counter[str] = Counter()
    kept: list[dict] = []
    for line in lines:
        key = line["key"] or line["norm"]
        counts[key] += 1
        limit = MAX_COPIES_IN_SONG if line["key"] else MAX_SHORT_COPIES
        if counts[key] > limit:
            continue
        kept.append(line)
    return kept


def dedupe_songs(songs: dict[str, dict]) -> dict[str, int]:
    """Drop cross-song copies. The song with BPM, then scale, keeps the line.

    In-song repeats stay, up to a small cap. Near-duplicates across songs
    follow the same ownership rule.
    """
    stats = Counter()
    for song in songs.values():
        prepared = []
        for line in song["lines"]:
            text = line["text"]
            if is_junk_line(text):
                stats["junk"] += 1
                continue
            norm = normalize(text)
            tokens = tokenize(norm)
            if not tokens:
                stats["junk"] += 1
                continue
            prepared.append(
                {
                    "text": " ".join(text.split()),
                    "syl": int(line["syl"]) if line.get("syl") else estimate_syllables(text),
                    "norm": norm,
                    "tokens": tokens,
                    "key": loose_key(tokens),
                }
            )
        song["lines"] = cap_in_song(prepared)
        stats["after_cap"] += len(song["lines"])

    best: dict[str, tuple[tuple[int, int, int], str]] = {}
    for song_id, song in songs.items():
        score_bpm = 1 if song.get("bpm") is not None else 0
        score_scale = 1 if song.get("scale") else 0
        seen: set[str] = set()
        for line in song["lines"]:
            key = line["key"]
            if not key or key in seen:
                continue
            seen.add(key)
            rank = (score_bpm, score_scale, stable_tie(song_id, key))
            current = best.get(key)
            if current is None or rank > current[0]:
                best[key] = (rank, song_id)

    dropped_exact = 0
    for song_id, song in songs.items():
        kept = []
        for line in song["lines"]:
            key = line["key"]
            if key and best[key][1] != song_id:
                dropped_exact += 1
                continue
            kept.append(line)
        song["lines"] = kept
    stats["dropped_exact"] = dropped_exact

    order = sorted(best.items(), key=lambda item: item[1][0], reverse=True)
    index = NearDupIndex()
    drop_near: set[str] = set()
    for key, (rank, song_id) in order:
        fp = simhash(tokenize(key))
        if index.seen_other(fp, song_id):
            drop_near.add(key)
            continue
        index.add(fp, song_id)

    dropped_near = 0
    for song in songs.values():
        kept = []
        for line in song["lines"]:
            if line["key"] and line["key"] in drop_near:
                dropped_near += 1
                continue
            kept.append(line)
        song["lines"] = kept
    stats["dropped_near"] = dropped_near
    stats["kept_lines"] = sum(len(song["lines"]) for song in songs.values())
    return dict(stats)


def split_song_ids(
    song_ids: Iterable[str], seed: int = 7
) -> dict[str, list[str]]:
    """95/3/2 by song id. A song lands in one split."""
    ids = sorted(set(song_ids))
    rng = random.Random(seed)
    rng.shuffle(ids)
    n = len(ids)
    if n == 0:
        return {"train": [], "valid": [], "test": []}
    n_train = int(n * SPLIT_RATIOS[0])
    n_valid = int(n * SPLIT_RATIOS[1])
    if n >= 50:
        n_train = max(1, n_train)
        n_valid = max(1, n_valid)
    if n_train + n_valid >= n:
        n_valid = max(0, n - n_train - (1 if n > n_train else 0))
    n_test = n - n_train - n_valid
    return {
        "train": ids[:n_train],
        "valid": ids[n_train : n_train + n_valid],
        "test": ids[n_train + n_valid : n_train + n_valid + n_test],
    }


def dominance_flags(counts: Counter) -> list[dict]:
    total = sum(counts.values()) or 1
    ranked = counts.most_common()
    flags = []
    seen = set()
    for name, n in ranked:
        share = n / total
        if share >= HEAVY_SHARE:
            flags.append(
                {
                    "artist": name,
                    "lines": n,
                    "share": round(share, 4),
                    "reason": "4% or more of kept lines",
                }
            )
            seen.add(name)
    if len(ranked) >= 3 and ranked[0][1] > ranked[1][1] + ranked[2][1]:
        name, n = ranked[0]
        if name not in seen:
            flags.append(
                {
                    "artist": name,
                    "lines": n,
                    "share": round(n / total, 4),
                    "reason": "more kept lines than the next two artists combined",
                }
            )
    return flags


def voice_token(artist: str) -> str:
    """The exact string the LoRA sees for this stored artist credit."""
    return "<voice:%s>" % tag_safe(artist)


def control_prefix(
    artist: str,
    bpm: Optional[float],
    scale: Optional[str],
    syl: Optional[float],
    blend: Optional[str] = None,
    custom: bool = False,
) -> str:
    """Voice token, then bpm and scale only when the song actually has them.

    A missing tempo or scale is left out. Nothing is filled in with unk.
    The syllable tag is the median of the lyric lines in this window.
    """
    parts = ["<voice:custom>"] if custom else [voice_token(artist)]
    if blend:
        parts.append("<blend:%s>" % tag_safe(blend))
    if bpm is not None:
        parts.append("<bpm:%s>" % bucket_bpm(bpm))
    if scale is not None and str(scale).strip():
        parts.append("<scale:%s>" % tag_safe(scale))
    if syl is not None:
        parts.append("<syl:%s>" % int(round(float(syl))))
    return " ".join(parts)


def voice_example_counts(record: dict) -> tuple:
    """Lyric lines and trainable windows for one song. Text is not returned."""
    artist = record.get("artist") or ""
    lyric = 0
    lines = []
    for raw in (record.get("text") or "").split("\n"):
        if not raw.strip():
            continue
        if SECTION_RE.match(raw.strip()):
            lines.append({"text": raw})
        else:
            lyric += 1
            lines.append({"text": raw, "syl": 1})
    windows = 0
    if artist:
        windows = sum(1 for _ in chunks(lines))
    return lyric, windows


def collect_voice_rows(split_paths: dict, min_lines: int = RELIABLE_VOICE_LINES) -> list:
    """One row per stored artist string. Case variants and collabs stay apart."""
    rows: dict = {}
    split_field = {"train": "train", "valid": "val", "test": "test"}
    for split, path in split_paths.items():
        field = split_field.get(split, split)
        with Path(path).open(encoding="utf-8") as handle:
            for line in handle:
                if not line.strip():
                    continue
                record = json.loads(line)
                artist = record.get("artist") or ""
                if not artist:
                    continue
                lyric, windows = voice_example_counts(record)
                row = rows.get(artist)
                if row is None:
                    row = {
                        "artist": artist,
                        "token": voice_token(artist),
                        "train_lines": 0,
                        "train_windows": 0,
                        "val_lines": 0,
                        "test_lines": 0,
                        "reliable": False,
                        "flag": "",
                    }
                    rows[artist] = row
                row["%s_lines" % field] += lyric
                if field == "train":
                    row["train_windows"] += windows
    ordered = []
    for row in rows.values():
        reasons = []
        if row["train_lines"] < int(min_lines):
            reasons.append(
                "too few train lines (%d < %d)" % (row["train_lines"], int(min_lines))
            )
        if row["train_windows"] < 1:
            reasons.append("no training window")
        row["flag"] = "; ".join(reasons)
        row["reliable"] = not reasons
        ordered.append(row)
    ordered.sort(key=lambda item: item["artist"])
    return ordered


def render_voice_report(rows: Sequence[dict], min_lines: int = RELIABLE_VOICE_LINES) -> str:
    reliable = sum(1 for row in rows if row["reliable"])
    flagged = len(rows) - reliable
    lines = [
        "# Voice tokens",
        "",
        "Each token is the exact `<voice:...>` string on that artist's training windows. "
        "Case differences and collab credits are separate tokens.",
        "",
        "A voice is reliable when the train split has at least %d lyric lines "
        "and at least one eight-line window. A thinner credit is flagged and still "
        "gets a token, so the name can be typed at generation time."
        % int(min_lines),
        "",
        "Tokens: %d. Reliable: %d. Flagged: %d." % (len(rows), reliable, flagged),
        "",
        "| voice token | train lines | train windows | val lines | test lines | flag |",
        "| --- | ---: | ---: | ---: | ---: | --- |",
    ]
    for row in rows:
        token = str(row["token"]).replace("|", "\\|")
        flag = str(row["flag"]).replace("|", "\\|")
        lines.append(
            "| %s | %d | %d | %d | %d | %s |"
            % (
                token,
                row["train_lines"],
                row["train_windows"],
                row["val_lines"],
                row["test_lines"],
                flag,
            )
        )
    lines.append("")
    return "\n".join(lines)


def write_voice_inventory(split_paths: dict, out_dir, min_lines: int = RELIABLE_VOICE_LINES) -> list:
    """Write the token list, the flag report, and the counts infer.py reads."""
    rows = collect_voice_rows(split_paths, min_lines=min_lines)
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    tokens = [row["token"] for row in rows]
    (out_dir / "voices.txt").write_text(
        ("\n".join(tokens) + "\n") if tokens else "",
        encoding="utf-8",
    )
    (out_dir / "voice_tokens.md").write_text(
        render_voice_report(rows, min_lines),
        encoding="utf-8",
    )
    payload = {}
    for row in rows:
        payload[row["token"]] = {
            "artist": row["artist"],
            "train_lines": row["train_lines"],
            "train_windows": row["train_windows"],
            "val_lines": row["val_lines"],
            "test_lines": row["test_lines"],
            "reliable": row["reliable"],
            "flag": row["flag"],
        }
    (out_dir / "voice_counts.json").write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    return rows


def chunks(lines: Sequence[dict], size: int = CHUNK_LINES) -> Iterator[list[dict]]:
    for start in range(0, len(lines), size):
        block = list(lines[start : start + size])
        if len(block) >= MIN_CHUNK:
            yield block


def median_syl(lines: Sequence[dict]) -> Optional[int]:
    vals = [int(line["syl"]) for line in lines if line.get("syl")]
    if not vals:
        return None
    return int(round(statistics.median(vals)))


def messages_for_chunk(
    artist: str,
    bpm: Optional[float],
    scale: Optional[str],
    block: Sequence[dict],
    blend: Optional[str] = None,
    custom: bool = False,
    exemplar: Optional[Sequence[str]] = None,
) -> dict:
    prefix = control_prefix(
        artist, bpm, scale, median_syl(block), blend=blend, custom=custom
    )
    user = prefix
    if exemplar:
        shown = "\n".join(exemplar)
        user = f"{prefix}\n<exemplar>\n{shown}\n</exemplar>"
    body = "\n".join(line["text"] for line in block)
    return {
        "messages": [
            {"role": "user", "content": user},
            {"role": "assistant", "content": body},
        ]
    }


def line_record(text: str, artist: str, bpm: Optional[int], scale: Optional[str]) -> dict:
    return {"text": text, "artist": artist, "bpm": bpm, "scale": scale}


RAP_SLANG_CMU = {
    "audamar": ["AA1", "D", "AH0", "M", "AA2", "R"],
    "audemars": ["AA1", "D", "AH0", "M", "AA2", "R"],
    "maybach": ["M", "EY1", "B", "AA2", "K"],
    "goyard": ["G", "OW1", "Y", "AA2", "R", "D"],
    "cullinan": ["K", "AH1", "L", "IH0", "N", "AH0", "N"],
    "eliantte": ["EH0", "L", "IY0", "AA1", "N", "T", "EY2"],
    "biscotti": ["B", "IH0", "S", "K", "AA1", "T", "IY0"],
    "celine": ["S", "EH0", "L", "IY1", "N"],
    "calabasas": ["K", "AE2", "L", "AH0", "B", "AE1", "S", "AH0", "Z"],
    "balenciaga": ["B", "AH0", "L", "EH2", "N", "S", "IY0", "AA1", "G", "AH0"],
    "bottega": ["B", "OW0", "T", "EY1", "G", "AH0"],
    "cartier": ["K", "AA0", "R", "T", "IY0", "EY1"],
}


def load_cmudict(path: Path) -> dict[str, list[str]]:
    table: dict[str, list[str]] = dict(RAP_SLANG_CMU)
    if not path.exists():
        return table
    with path.open(encoding="utf-8", errors="replace") as handle:
        for raw in handle:
            if not raw.strip() or raw.startswith(";;;"):
                continue
            parts = raw.split()
            word = re.sub(r"\(\d+\)$", "", parts[0]).lower()
            table.setdefault(word, parts[1:])
    return table


def end_rime(word: str, cmu: dict[str, list[str]]) -> Optional[tuple[str, ...]]:
    phones = cmu.get(word.lower())
    if not phones:
        return None
    for i in range(len(phones) - 1, -1, -1):
        if phones[i][-1] in "12":
            return tuple(phones[i:])
    return tuple(phones)


ADLIB_TRAILING_RE = re.compile(r"\s*[\(\[\{][^\)\]\}]*[\)\]\}]\s*$")

RAP_VOWEL_CLASSES = {
    "IH": "V_weak", "IH0": "V_weak", "IH1": "V_weak", "IH2": "V_weak",
    "AH": "V_weak", "AH0": "V_weak", "AH1": "V_weak", "AH2": "V_weak",
    "AX": "V_weak", "AX0": "V_weak", "IX": "V_weak", "IX0": "V_weak",
    "AA": "V_broad", "AA0": "V_broad", "AA1": "V_broad", "AA2": "V_broad",
    "AO": "V_broad", "AO0": "V_broad", "AO1": "V_broad", "AO2": "V_broad",
    "AW": "V_broad", "AW0": "V_broad", "AW1": "V_broad", "AW2": "V_broad",
    "EY": "V_front_mid", "EY0": "V_front_mid", "EY1": "V_front_mid", "EY2": "V_front_mid",
    "AY": "V_front_low", "AY0": "V_front_low", "AY1": "V_front_low", "AY2": "V_front_low",
    "IY": "V_front_high", "IY0": "V_front_high", "IY1": "V_front_high", "IY2": "V_front_high",
    "EH": "V_front_open", "EH0": "V_front_open", "EH1": "V_front_open", "EH2": "V_front_open",
    "AE": "V_front_open", "AE0": "V_front_open", "AE1": "V_front_open", "AE2": "V_front_open",
    "OW": "V_round_mid", "OW0": "V_round_mid", "OW1": "V_round_mid", "OW2": "V_round_mid",
    "UW": "V_round_high", "UW0": "V_round_high", "UW1": "V_round_high", "UW2": "V_round_high",
    "UH": "V_round_mid", "UH0": "V_round_mid", "UH1": "V_round_mid", "UH2": "V_round_mid",
    "OY": "V_round_dip", "OY0": "V_round_dip", "OY1": "V_round_dip", "OY2": "V_round_dip",
    "ER": "V_rhot", "ER0": "V_rhot", "ER1": "V_rhot", "ER2": "V_rhot",
}


def clean_line_end_word(line: str) -> str:
    cleaned = ADLIB_TRAILING_RE.sub("", line).strip()
    if not cleaned:
        cleaned = line.strip()
    tokens = tokenize(normalize(cleaned))
    return tokens[-1] if tokens else ""


def words_rhyme(w1: str, w2: str, cmu: dict[str, list[str]]) -> bool:
    """Return True if two words rhyme via exact rime or hip-hop slant assonance."""
    if not w1 or not w2:
        return False
    if w1 == w2:
        return True
    r1 = end_rime(w1, cmu)
    r2 = end_rime(w2, cmu)
    if r1 and r2 and r1 == r2:
        return True
    # Slant assonance check via primary stressed vowel
    p1 = cmu.get(w1.lower())
    p2 = cmu.get(w2.lower())
    if not p1 or not p2:
        return False
    v1 = [p for p in p1 if any(c.isdigit() for c in p)]
    v2 = [p for p in p2 if any(c.isdigit() for c in p)]
    if not v1 or not v2:
        return False
    last_v1 = v1[-1]
    last_v2 = v2[-1]
    b1 = last_v1.rstrip("012")
    b2 = last_v2.rstrip("012")
    c1 = RAP_VOWEL_CLASSES.get(last_v1, b1)
    c2 = RAP_VOWEL_CLASSES.get(last_v2, b2)
    return b1 == b2 or c1 == c2


def rhyme_rate(lines: Sequence[str], cmu: dict[str, list[str]]) -> Optional[float]:
    """Share of lines whose end word rhymes with a neighboring line in a 4-bar scheme window (AABB, ABAB, AAAA)."""
    if len(lines) < 2 or not cmu:
        return None
    ends = [clean_line_end_word(line) for line in lines]
    hits = 0
    scored = 0
    for i, word in enumerate(ends):
        if not word:
            continue
        scored += 1
        window = [
            ends[j]
            for j in range(max(0, i - 4), min(len(ends), i + 5))
            if j != i and ends[j]
        ]
        if any(words_rhyme(word, prev, cmu) for prev in window):
            hits += 1
    if scored == 0:
        return None
    return hits / scored


def flow_consistency(syls: Sequence[int]) -> Optional[float]:
    """1 means every line has the same syllable count."""
    if len(syls) < 2:
        return None
    mean = statistics.fmean(syls)
    if mean <= 0:
        return None
    var = statistics.pstdev(syls) / mean
    return max(0.0, 1.0 - var)


def tempo_line_syllables(bpm: float) -> int:
    """Syllables the sampler asks for at this tempo.

    Slow tempos get a roomier line. Fast tempos get a denser line.
    70 BPM is 8 syllables. 140 BPM is 14. The steps between are linear,
    and the result stays between 6 and 18.
    """
    raw = 8.0 + (float(bpm) - 70.0) * (6.0 / 70.0)
    return max(6, min(18, int(round(raw))))


def line_reached_budget(text: str, target: int) -> bool:
    """True when the line has as many syllables as the tempo budget."""
    body = text.split("\n", 1)[0].strip()
    if not body:
        return False
    return estimate_syllables(body) >= int(target)


def corpus_bpm_syllables(paths: Sequence[Path], bpms: Sequence[float]) -> dict:
    """Mean and median syllables for lyric lines in these BPM buckets.

    Returns counts only. Lyric text is not kept.
    """
    wanted = {}
    for bpm in bpms:
        bucket = bucket_bpm(bpm)
        if bucket is not None:
            wanted[bucket] = {"songs": 0, "lines": 0, "values": []}
    for path in paths:
        if not Path(path).exists():
            continue
        with Path(path).open(encoding="utf-8") as handle:
            for raw in handle:
                raw = raw.strip()
                if not raw:
                    continue
                record = json.loads(raw)
                bucket = bucket_bpm(record.get("bpm"))
                if bucket not in wanted:
                    continue
                values = wanted[bucket]["values"]
                songs = 0
                for line in (record.get("text") or "").split("\n"):
                    if not line.strip() or SECTION_RE.match(line.strip()):
                        continue
                    values.append(estimate_syllables(line))
                    songs = 1
                wanted[bucket]["songs"] += songs
    out = {}
    for bucket, row in wanted.items():
        values = row["values"]
        out[bucket] = {
            "songs": row["songs"],
            "lines": len(values),
            "mean": round(statistics.fmean(values), 2) if values else None,
            "median": int(round(statistics.median(values))) if values else None,
        }
    return out


def target_syllables(curve: dict, bpm: Optional[float]) -> Optional[int]:
    """Median syllables-per-bar for this tempo, walking to a neighbor if thin."""
    buckets = curve.get("buckets") or {}
    if bpm is None:
        global_median = curve.get("global_median_syl")
        return int(global_median) if global_median else None
    center = bucket_bpm(bpm)
    if center is None:
        return None
    for distance in range(0, 40, 5):
        for candidate in (center + distance, center - distance):
            row = buckets.get(str(candidate))
            if row and row.get("n", 0) >= 30 and row.get("median_syl"):
                return int(row["median_syl"])
    global_median = curve.get("global_median_syl")
    return int(global_median) if global_median else None


def open_originality(path: Path) -> sqlite3.Connection:
    path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(path)
    conn.execute("PRAGMA journal_mode=OFF")
    conn.execute("PRAGMA synchronous=OFF")
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS fp (
            sha TEXT PRIMARY KEY,
            sim TEXT NOT NULL,
            b0 INTEGER,
            b1 INTEGER,
            b2 INTEGER,
            b3 INTEGER
        )
        """
    )
    return conn


def fingerprint(norm: str) -> tuple[str, str, int, int, int, int]:
    fp = simhash(tokenize(norm))
    bands = []
    for band in range(4):
        bands.append((fp >> (band * 16)) & 0xFFFF)
    return (sha_text(norm), f"{fp:016x}", bands[0], bands[1], bands[2], bands[3])


def index_originality(conn: sqlite3.Connection, norms: Iterable[str]) -> int:
    rows = []
    n = 0
    for norm in norms:
        if not norm:
            continue
        rows.append(fingerprint(norm))
        n += 1
        if len(rows) >= 5000:
            conn.executemany("INSERT OR IGNORE INTO fp VALUES (?,?,?,?,?,?)", rows)
            rows.clear()
    if rows:
        conn.executemany("INSERT OR IGNORE INTO fp VALUES (?,?,?,?,?,?)", rows)
    conn.execute("CREATE INDEX IF NOT EXISTS ix0 ON fp(b0)")
    conn.execute("CREATE INDEX IF NOT EXISTS ix1 ON fp(b1)")
    conn.execute("CREATE INDEX IF NOT EXISTS ix2 ON fp(b2)")
    conn.execute("CREATE INDEX IF NOT EXISTS ix3 ON fp(b3)")
    conn.commit()
    return n


def originality_score(conn: sqlite3.Connection, text: str) -> Optional[dict]:
    """Exact or near hit, with a Hamming distance. Does not return a training line.

    Similarity is 1 minus the Hamming distance over 64 simhash bits.
    An exact hash is distance 0. A near hit is the closest indexed neighbor
    at distance 3 or less.
    """
    norm = normalize(text)
    if not norm:
        return None
    sha, sim, b0, b1, b2, b3 = fingerprint(norm)
    row = conn.execute("SELECT 1 FROM fp WHERE sha = ?", (sha,)).fetchone()
    if row:
        return {"kind": "exact", "hamming": 0, "similarity": 1.0}
    fp = int(sim, 16)
    best = None
    for column, bits in (("b0", b0), ("b1", b1), ("b2", b2), ("b3", b3)):
        found = conn.execute(
            f"SELECT sim FROM fp WHERE {column} = ? LIMIT 64", (bits,)
        )
        for (other,) in found:
            distance = hamming(fp, int(other, 16))
            if best is None or distance < best:
                best = distance
    if best is None or best > NEAR_HAMMING:
        return None
    return {
        "kind": "near",
        "hamming": int(best),
        "similarity": round((64 - int(best)) / 64.0, 4),
    }


def originality_hit(conn: sqlite3.Connection, text: str) -> Optional[str]:
    """'exact', 'near', or None. Does not return the training line."""
    scored = originality_score(conn, text)
    if scored is None:
        return None
    return scored["kind"]


def stylometric(lines: Sequence[str], cmu: dict[str, list[str]]) -> dict[str, float]:
    syls = [estimate_syllables(line) for line in lines if line.strip()]
    words = [tokenize(normalize(line)) for line in lines if line.strip()]
    flat = [w for line in words for w in line if w not in ADLIB]
    ttr = (len(set(flat)) / len(flat)) if flat else 0.0
    rhyme = rhyme_rate(lines, cmu)
    return {
        "mean_syl": statistics.fmean(syls) if syls else 0.0,
        "mean_words": statistics.fmean([len(w) for w in words]) if words else 0.0,
        "ttr": ttr,
        "rhyme_rate": 0.0 if rhyme is None else rhyme,
    }


def l2(a: dict[str, float], b: dict[str, float]) -> float:
    keys = sorted(set(a) | set(b))
    return sum((a.get(k, 0.0) - b.get(k, 0.0)) ** 2 for k in keys) ** 0.5


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))
