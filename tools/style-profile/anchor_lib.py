#!/usr/bin/env python3
"""Shared measurements for the Gunna anchor set.

The anchor list is the only style source for mimic mode. Edit ANCHOR_SONGS to change it.
Titles match case-insensitively after curly apostrophes are folded to straight ones.
When a title hits two albums, the album hint breaks the tie.

Nothing in this file stores lyric lines. Run the self-check with:

  python3 tools/style-profile/anchor_lib.py
"""

from __future__ import annotations

import math
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import phase1_song_metrics as p1

SCHEMA = "anchor_profile.v1"

# Exact titles Samuel named. Album hints are the CSV album when he knew it;
# "Unknown" means the CSV album field is Unknown. Several Gift & a Curse titles
# are filed under a setlist name in the CSV; matching treats that as the same hint.
ANCHOR_SONGS = (
    ("Phase", "Unknown"),
    ("Don't Give Up", "Unknown"),
    ("Invest", "Unknown"),
    ("Spending Addiction", "Drip Season 3"),
    ("Mistress", "Drip Season 3"),
    ("back to the moon", "Unknown"),
    ("idk nomore", "A Gift & A Curse"),
    ("paybach", "A Gift & A Curse"),
    ("born rich", "A Gift & A Curse"),
    ("turned your back", "A Gift & A Curse"),
    ("pushin P", "Unknown"),
    ("thought i was playing", "DS4EVER"),
    ("poochie gown", "A Gift & A Curse"),
    ("mop", "DRIP SEASON 4EVER"),
    ("how you did that", "DRIP SEASON 4EVER"),
    ("south to west", "A Gift & A Curse"),
    ("25k jacket", "DRIP SEASON 4EVER"),
    ("too easy", "Unknown"),
    ("idk that bitch", "DRIP SEASON 4EVER"),
    ("Diamonds Dancing", "Unknown"),
)

# Detector lists for the profile only. They do not drive line writing.
# A brand spelled another way still shows up in the signature-phrase table.
BRANDS = frozenset("""
dior amiri balenciaga gucci prada chanel rolex patek cartier hermes birkin
vlone bape yeezy ferrari lamborghini lambo bentley porsche bugatti maybach
mercedes cullinan aventador huracan mclaren givenchy fendi versace celine
bottega margiela balmain moncler ysl louboutin goyard rimowa audemars
""".split())
MULTI_BRANDS = (
    "louis vuitton", "chrome hearts", "rolls royce", "off white", "stone island",
    "saint laurent", "audemars piguet", "richard mille", "patek philippe",
)
PLACES = frozenset("""
atlanta georgia fulton miami houston paris london italy california decatur
buckhead europe france japan brooklyn manhattan
""".split())
MULTI_PLACES = ("zone 4", "zone 6", "new york", "los angeles", "las vegas", "zone four")

COUNTER_KEYS = (
    "syl", "half_before", "half_after", "openers", "openers2", "vowels",
    "adlib_pos", "adlib_texts", "function", "content", "bigrams", "trigrams",
    "brands", "places", "caps",
)
INT_KEYS = (
    "lines", "measured", "comma_bars", "setup_shorter",
    "same_first", "same_first2", "consec",
    "dist1_hits", "dist1_possible", "alt_hits", "alt_possible",
    "run3_bars", "identical_links", "internal_bars", "end_scored",
    "line_repeat_num", "line_repeat_den", "tri_repeat_num", "tri_repeat_den",
    "adlib_bars", "tokens", "content_n", "bigram_n", "trigram_n",
    "call_response_verses", "verses",
)


def norm_title(text: str) -> str:
    text = text.replace("\u2019", "'").replace("\u2018", "'").replace("\u02bc", "'").replace("`", "'")
    return re.sub(r"\s+", " ", text).strip().lower()


def album_compatible(hint: str, actual: str) -> bool:
    hint_n, actual_n = norm_title(hint), norm_title(actual)
    if hint_n == actual_n:
        return True
    if hint_n == "unknown":
        return actual_n in ("", "unknown")
    return hint_n in actual_n or actual_n in hint_n


def match_anchors(songs: list[dict]) -> tuple[list[dict], list[str]]:
    """Pick one CSV song per ANCHOR_SONGS row. `songs` items need title, album, lines."""
    by_norm = defaultdict(list)
    for song in songs:
        by_norm[norm_title(song["title"])].append(song)
    matched, missing = [], []
    for title, album in ANCHOR_SONGS:
        hits = by_norm.get(norm_title(title), [])
        if not hits:
            missing.append(title)
            continue
        note = None
        if len(hits) == 1:
            chosen = hits[0]
            if not album_compatible(album, chosen.get("album", "")):
                note = f"album hint {album!r} but the CSV has {chosen.get('album', '')!r}"
        else:
            compatible = [hit for hit in hits if album_compatible(album, hit.get("album", ""))]
            if len(compatible) == 1:
                chosen = compatible[0]
            elif len(compatible) > 1:
                chosen = max(compatible, key=lambda hit: len(hit["lines"]))
                note = "several albums matched the hint; kept the one with more lines"
            else:
                chosen = max(hits, key=lambda hit: len(hit["lines"]))
                note = f"no album matched hint {album!r}; kept {chosen.get('album', '')!r}"
        matched.append({
            **chosen,
            "hint_title": title,
            "hint_album": album,
            "album_note": note,
        })
    return matched, missing


_CHROME_RE = re.compile(r"aria-label", re.I)


def is_chrome_line(text: str) -> bool:
    """Genius page chrome that was stored in the lyric column (cover-art aria labels)."""
    stripped = text.strip()
    if _CHROME_RE.search(stripped):
        return True
    return len(stripped) >= 2 and stripped[0] == "|" and stripped[-1] == "|" and stripped.count("|") == 2


def load_gunna(csv_path: Path, progress: bool = True) -> list[dict]:
    """One row per (title, album). read_songs() folds albums together, which merges the two
    copies of a title. Chrome lines are dropped here so they never enter the profile."""
    if progress:
        print(f"reading Gunna rows from {csv_path} ...", file=sys.stderr)
    import csv as _csv
    _csv.field_size_limit(sys.maxsize)
    songs: dict[tuple[str, str, str], dict] = {}
    with open(csv_path, newline="", encoding="utf-8", errors="replace") as fh:
        reader = _csv.reader(fh)
        header = next(reader)
        col = {name: i for i, name in enumerate(header)}
        c_id = 0
        c_art, c_song, c_alb = col["artist"], col["song"], col["album"]
        c_text, c_year = col["text_bar_line"], col["year"]
        for row in reader:
            if len(row) <= c_text:
                continue
            artist, title, text = row[c_art].strip(), row[c_song].strip(), row[c_text].strip()
            if artist.lower() != "gunna" or not title or not text:
                continue
            album = row[c_alb].strip()
            rec = songs.setdefault((artist, title, album), {"year": row[c_year], "lines": []})
            rec["lines"].append((p1.trailing_number(row[c_id]), text))
    out = []
    dropped = 0
    for (artist, title, album), rec in sorted(songs.items(), key=lambda item: (norm_title(item[0][1]), item[0][2])):
        lines = []
        song_dropped = 0
        for _, text in sorted(rec["lines"], key=lambda pair: pair[0]):
            text = text.strip()
            if not text:
                continue
            if is_chrome_line(text):
                song_dropped += 1
                continue
            lines.append(text)
        dropped += song_dropped
        out.append({
            "artist": artist,
            "title": title,
            "album": album,
            "year": rec.get("year") or "",
            "lines": lines,
            "chrome_dropped": song_dropped,
        })
    if progress:
        print(f"  {len(out)} Gunna song/album rows, {dropped} chrome lines dropped", file=sys.stderr)
    return out


def first_occurrence(lines: list[str]) -> list[str]:
    seen, out = set(), []
    for text in lines:
        key = p1.norm_line(text)
        if not key or key in seen:
            continue
        seen.add(key)
        out.append(text)
    return out


def copy_songs(songs: list[dict]) -> list[tuple[str, list[str]]]:
    """(title, first copy of each line) for Corpus copy-checks. Repeats are not extra lines."""
    return [(song["title"], first_occurrence(song["lines"])) for song in songs]


def compress_pattern(pattern: str) -> str:
    out = []
    for char in pattern:
        if not out or out[-1] != char:
            out.append(char)
    return "".join(out)


def segment_sections(lines: list[str]) -> list[dict]:
    """Split a song into hook / verse / other using repeated line-pairs.

    A hook is a run of lines whose neighboring pair also occurs somewhere else
    in the song. A verse is any other run of at least 4 lines. Shorter leftovers
    are 'other' (intros, one-line tags) and are not treated as verses.
    """
    norms = [p1.norm_line(text) for text in lines]
    pos = defaultdict(list)
    for index, norm in enumerate(norms):
        if norm:
            pos[norm].append(index)
    hook = [False] * len(norms)
    for index in range(len(norms) - 1):
        left, right = norms[index], norms[index + 1]
        if not left or not right:
            continue
        for other in pos[left]:
            if other != index and other + 1 < len(norms) and norms[other + 1] == right:
                hook[index] = True
                hook[index + 1] = True
                break
    for index in range(1, len(norms) - 1):
        if hook[index] or not hook[index - 1] or not hook[index + 1]:
            continue
        if norms[index] and len(pos[norms[index]]) >= 2:
            hook[index] = True
    sections = []
    index = 0
    while index < len(lines):
        flag = hook[index]
        end = index + 1
        while end < len(lines) and hook[end] == flag:
            end += 1
        if flag:
            kind = "hook"
        elif end - index >= 4:
            kind = "verse"
        else:
            kind = "other"
        sections.append({"kind": kind, "lines": lines[index:end]})
        index = end
    return sections


def style_lines_for(lines: list[str]) -> dict:
    sections = segment_sections(lines) if lines else []
    verses = [section["lines"] for section in sections if section["kind"] == "verse"]
    verse_n = sum(len(verse) for verse in verses)
    hook_lengths = [len(section["lines"]) for section in sections if section["kind"] == "hook"]
    pattern = "".join(section["kind"][0].upper() for section in sections)
    first_hook = None
    seen = 0
    for section in sections:
        if section["kind"] == "hook":
            first_hook = seen / len(lines) if lines else None
            break
        seen += len(section["lines"])
    fallback = verse_n < 8
    if fallback:
        uniq = first_occurrence(lines)
        style = [uniq] if len(uniq) >= 4 else []
        real_verses = []
    else:
        style = verses
        real_verses = verses
    return {
        "pattern": compress_pattern(pattern),
        "pattern_raw": pattern if len(pattern) <= 48 else compress_pattern(pattern),
        "first_hook_frac": None if first_hook is None else round(first_hook, 3),
        "hook_bars": sum(hook_lengths),
        "hook_lengths": hook_lengths,
        "other_bars": sum(len(section["lines"]) for section in sections if section["kind"] == "other"),
        "detected_verse_bars": verse_n,
        "fallback": fallback,
        "style_verses": style,
        "real_verses": real_verses,
    }


def end_rhyme_kind(left: p1.Bar, right: p1.Bar):
    """Same rule as phase6_generate.end_rhyme_kind. Kept here so the score and the generator agree."""
    if not (left.end_phones and right.end_phones and left.rime and right.rime and left.rime[-1] and right.rime[-1]):
        return None
    if left.end_word == right.end_word:
        return "identical"
    left_r, right_r = left.rime[-1], right.rime[-1]
    if left_r == right_r:
        return "perfect"
    if left_r.split()[0] == right_r.split()[0] and p1.trailing_vowel_depth(left.end_phones, right.end_phones) >= 1:
        return "slant"
    return None


def vowel_of(bar: p1.Bar):
    if not bar.rime or not bar.rime[-1]:
        return None
    return bar.rime[-1].split()[0]


def internal_hit(bar: p1.Bar) -> bool:
    indexes = [
        index for index, word in enumerate(bar.words)
        if word not in p1.STOPWORDS and "'" not in word and len(word) > 2 and bar.rime[index]
    ]
    for left in range(len(indexes)):
        for right in range(left + 1, len(indexes)):
            i, j = indexes[left], indexes[right]
            if bar.words[i] != bar.words[j] and bar.rime[i] == bar.rime[j]:
                return True
    return False


def adlib_key(token: str) -> str:
    text = token.strip("()[]").lower().replace("\u2019", "'")
    text = re.sub(r"\s+", " ", text).strip()
    if not text or len(text.split()) > 4:
        return ""
    return text


def adlib_marks(raw: str) -> list[tuple[str, str]]:
    marks = []
    stripped_len = len(raw.strip()) or 1
    for match in p1.ADLIB_RE.finditer(raw):
        key = adlib_key(match.group(0))
        if not key:
            continue
        if match.start() <= 1:
            pos = "start"
        elif match.end() >= len(raw.strip()) or (match.start() + match.end()) / 2 >= 0.75 * stripped_len:
            pos = "end"
        else:
            pos = "middle"
        marks.append((pos, key))
    return marks


def mid_caps(raw: str) -> list[str]:
    body = p1.ADLIB_RE.sub(" ", raw)
    tokens = re.findall(r"[A-Za-z][A-Za-z0-9']*", body)
    found = []
    for index, token in enumerate(tokens):
        if index == 0 or len(token) < 3:
            continue
        if token[0].isupper():
            found.append(token.lower())
    return found


def blank_counts() -> dict:
    counts = {key: Counter() for key in COUNTER_KEYS}
    for key in INT_KEYS:
        counts[key] = 0
    counts["verse_lengths"] = []
    return counts


def merge_counts(dst: dict, src: dict) -> None:
    for key in COUNTER_KEYS:
        dst[key].update(src[key])
    for key in INT_KEYS:
        dst[key] += src[key]
    dst["verse_lengths"].extend(src.get("verse_lengths") or [])


def sub_counter(total: Counter, part: Counter) -> Counter:
    out = total.copy()
    out.subtract(part)
    for key in list(out):
        if out[key] <= 0:
            del out[key]
    return out


def subtract_counts(total: dict, part: dict) -> dict:
    out = blank_counts()
    for key in COUNTER_KEYS:
        out[key] = sub_counter(total[key], part[key])
    for key in INT_KEYS:
        out[key] = max(0, total[key] - part[key])
    lengths = list(total.get("verse_lengths") or [])
    for value in part.get("verse_lengths") or []:
        if value in lengths:
            lengths.remove(value)
    out["verse_lengths"] = lengths
    return out


def sum_counts(packets: list[dict]) -> dict:
    total = blank_counts()
    for packet in packets:
        merge_counts(total, packet["counts"])
    return total


def features_from_lines(lines: list[str], lex: p1.Lexicon, light: bool = False) -> dict:
    """One verse or one window. light=True keeps tokens and phrases only (catalog pass)."""
    counts = blank_counts()
    if not lines:
        return counts
    parsed = [p1.Bar(text, lex) for text in lines]
    counts["lines"] = len(lines)
    for raw, bar in zip(lines, parsed):
        marks = adlib_marks(raw)
        if marks:
            counts["adlib_bars"] += 1
            for pos, key in marks:
                counts["adlib_pos"][pos] += 1
                counts["adlib_texts"][key] += 1
        for word in bar.words:
            counts["tokens"] += 1
            if word in p1.STOPWORDS:
                counts["function"][word] += 1
            elif len(word) > 2 and "'" not in word:
                counts["content"][word] += 1
                counts["content_n"] += 1
            if word in BRANDS:
                counts["brands"][word] += 1
            if word in PLACES:
                counts["places"][word] += 1
        folded = p1.norm_line(raw)
        for phrase in MULTI_BRANDS:
            if phrase in folded:
                counts["brands"][phrase] += folded.count(phrase)
        for phrase in MULTI_PLACES:
            if phrase in folded:
                counts["places"][phrase] += folded.count(phrase)
        for token in mid_caps(raw):
            counts["caps"][token] += 1
        words = bar.words
        if len(words) >= 2:
            counts["bigram_n"] += len(words) - 1
            for index in range(len(words) - 1):
                counts["bigrams"][" ".join(words[index:index + 2])] += 1
        if len(words) >= 3:
            counts["trigram_n"] += len(words) - 2
            for index in range(len(words) - 2):
                counts["trigrams"][" ".join(words[index:index + 3])] += 1
        if light:
            continue
        if len(bar.words) >= 2 and bar.syl > 0:
            counts["measured"] += 1
            counts["syl"][bar.syl] += 1
            if internal_hit(bar):
                counts["internal_bars"] += 1
            vowel = vowel_of(bar)
            if vowel:
                counts["vowels"][vowel] += 1
                counts["end_scored"] += 1
            body = p1.ADLIB_RE.sub(" ", raw)
            if "," in body:
                left, right = body.split(",", 1)
                counts["comma_bars"] += 1
                left_syl, right_syl = p1.Bar(left, lex).syl, p1.Bar(right, lex).syl
                if left_syl:
                    counts["half_before"][left_syl] += 1
                if right_syl:
                    counts["half_after"][right_syl] += 1
                if left_syl and right_syl and left_syl < right_syl:
                    counts["setup_shorter"] += 1
        if bar.words:
            counts["openers"][bar.words[0]] += 1
        if len(bar.words) >= 2:
            counts["openers2"][" ".join(bar.words[:2])] += 1
    if light:
        return counts

    for index in range(1, len(parsed)):
        previous, current = parsed[index - 1], parsed[index]
        if not previous.words or not current.words:
            continue
        counts["consec"] += 1
        if previous.words[0] == current.words[0]:
            counts["same_first"] += 1
        if (
            len(previous.words) >= 2
            and len(current.words) >= 2
            and previous.words[:2] == current.words[:2]
        ):
            counts["same_first2"] += 1

    counts["dist1_possible"] = max(0, len(parsed) - 1)
    counts["alt_possible"] = max(0, len(parsed) - 2)
    rhymes_previous = [False] * len(parsed)
    for index in range(1, len(parsed)):
        kind = end_rhyme_kind(parsed[index - 1], parsed[index])
        if not kind:
            continue
        rhymes_previous[index] = True
        counts["dist1_hits"] += 1
        if kind == "identical":
            counts["identical_links"] += 1
    for index in range(2, len(parsed)):
        if rhymes_previous[index]:
            continue
        kind = end_rhyme_kind(parsed[index - 2], parsed[index])
        if not kind:
            continue
        counts["alt_hits"] += 1
        if kind == "identical":
            counts["identical_links"] += 1
    index = 0
    while index < len(parsed):
        if index + 1 < len(parsed) and rhymes_previous[index + 1]:
            end = index + 1
            while end + 1 < len(parsed) and rhymes_previous[end + 1]:
                end += 1
            if end - index + 1 >= 3:
                counts["run3_bars"] += end - index + 1
            index = end + 1
        else:
            index += 1

    seen = set()
    for text in lines:
        norm = p1.norm_line(text)
        if not norm:
            continue
        counts["line_repeat_den"] += 1
        if norm in seen:
            counts["line_repeat_num"] += 1
        else:
            seen.add(norm)
    trigrams = []
    for bar in parsed:
        for index in range(len(bar.words) - 2):
            trigrams.append(" ".join(bar.words[index:index + 3]))
    if trigrams:
        trigram_counts = Counter(trigrams)
        counts["tri_repeat_den"] = len(trigrams)
        counts["tri_repeat_num"] = sum(value for value in trigram_counts.values() if value > 1)
    return counts


def is_call_response(lines: list[str]) -> bool:
    norms = [p1.norm_line(text) for text in lines]
    freq = Counter(norm for norm in norms if norm)
    for norm, count in freq.items():
        if count < 2:
            continue
        indexes = [index for index, value in enumerate(norms) if value == norm]
        if any(b - a >= 2 for a, b in zip(indexes, indexes[1:])):
            return True
    # A couple of short lines inside a long song is not a call-and-response.
    # Ad-lib rate is measured on its own, so a repeated "(yeah)" does not count here.
    shorts = [0 < len(norm.split()) <= 4 for norm in norms]
    gaps = max(1, len(shorts) - 1)
    handoffs = sum(1 for index in range(len(shorts) - 1) if not shorts[index] and shorts[index + 1])
    return handoffs >= 3 and handoffs / gaps >= 0.15


def song_counts(song: dict, lex: p1.Lexicon, light: bool = False) -> tuple[dict, dict]:
    info = style_lines_for(song["lines"])
    counts = blank_counts()
    for verse in info["style_verses"]:
        merge_counts(counts, features_from_lines(verse, lex, light=light))
    if not light:
        for verse in info["real_verses"]:
            counts["verse_lengths"].append(len(verse))
            counts["verses"] += 1
            if is_call_response(verse):
                counts["call_response_verses"] += 1
    return info, counts


def _div(num: float, den: float) -> float:
    return num / den if den else 0.0


def _round(value: float, places: int = 4) -> float:
    return round(value, places)


def expand_hist(hist: Counter) -> list[int]:
    values = []
    for key, count in hist.items():
        values.extend([int(key)] * int(count))
    return values


def dist_numbers(values: list[int]) -> dict:
    if not values:
        return {"n": 0, "mean": None, "median": None, "p10": None, "p90": None, "std": None, "min": None, "max": None}
    import statistics
    ordered = sorted(values)
    if len(ordered) >= 2:
        quantiles = statistics.quantiles(ordered, n=10)
        p10, p90 = quantiles[0], quantiles[-1]
        std = statistics.pstdev(ordered)
    else:
        p10 = p90 = ordered[0]
        std = 0.0
    return {
        "n": len(ordered),
        "mean": round(statistics.fmean(ordered), 2),
        "median": round(statistics.median(ordered), 2),
        "p10": round(p10, 2),
        "p90": round(p90, 2),
        "std": round(std, 2),
        "min": ordered[0],
        "max": ordered[-1],
    }


def _hist_dict(hist: Counter) -> dict:
    return {str(key): int(value) for key, value in sorted(hist.items(), key=lambda item: int(item[0]))}


def _top(counter: Counter, limit: int, floor: int = 1) -> list[dict]:
    return [{"text": text, "count": int(count)} for text, count in counter.most_common(limit) if count >= floor]


def document_freq(packets: list[dict], key: str) -> Counter:
    freq = Counter()
    for packet in packets:
        for gram in packet["counts"][key]:
            freq[gram] += 1
    return freq


def pick_signature(anchor_counts: Counter, catalog_counts: Counter, anchor_df: Counter,
                   anchor_total: int, catalog_total: int, min_count: int, min_df: int,
                   min_lift: float, limit: int, phrases: bool = False) -> list[dict]:
    if anchor_total <= 0 or catalog_total <= 0:
        return []
    rows = []
    for text, count in anchor_counts.items():
        if count < min_count or anchor_df[text] < min_df:
            continue
        if phrases:
            parts = text.split()
            if not parts or all(part in p1.STOPWORDS for part in parts):
                continue
            if not any(len(part) > 2 and part not in p1.STOPWORDS for part in parts):
                continue
        catalog_count = catalog_counts.get(text, 0)
        if catalog_count <= 0:
            continue
        lift = (count / anchor_total) / (catalog_count / catalog_total)
        if lift < min_lift:
            continue
        rows.append({
            "text": text,
            "anchor": int(count),
            "catalog": int(catalog_count),
            "lift": round(lift, 2),
            "songs": int(anchor_df[text]),
            "rank": round(lift * math.log1p(count), 3),
        })
    rows.sort(key=lambda row: (-row["rank"], -row["anchor"], row["text"]))
    # Prefer a longer phrase over a shorter one it contains when both rank.
    if phrases:
        kept = []
        for row in rows:
            if any(row["text"] in chosen["text"] and row["text"] != chosen["text"] for chosen in kept):
                continue
            kept.append(row)
            if len(kept) >= limit:
                break
        return kept
    return rows[:limit]


def make_targets(counts: dict, signature_set: list[str], signature_hit_rate: float) -> dict:
    syl_nums = dist_numbers(expand_hist(counts["syl"]))
    opener_top = [word for word, _ in counts["openers"].most_common(25)]
    opener_n = sum(counts["openers"].values())
    opener_hits = sum(count for word, count in counts["openers"].items() if word in set(opener_top))
    vowel_n = sum(counts["vowels"].values())
    adlib_n = sum(counts["adlib_pos"].values())
    rhyme_links = counts["dist1_hits"] + counts["alt_hits"]
    return {
        "syl_hist": _hist_dict(counts["syl"]),
        "half_before_hist": _hist_dict(counts["half_before"]),
        "half_after_hist": _hist_dict(counts["half_after"]),
        "syl_p10": syl_nums["p10"],
        "syl_p90": syl_nums["p90"],
        "syl_median": syl_nums["median"],
        "comma_rate": _round(_div(counts["comma_bars"], counts["measured"])),
        "vowel_share": {key: _round(value / vowel_n) for key, value in counts["vowels"].items()} if vowel_n else {},
        "dist1_rate": _round(_div(counts["dist1_hits"], counts["dist1_possible"])),
        "alt_rate": _round(_div(counts["alt_hits"], counts["alt_possible"])),
        "run3_share": _round(_div(counts["run3_bars"], counts["lines"])),
        "identical_share": _round(_div(counts["identical_links"], rhyme_links)),
        "internal_rate": _round(_div(counts["internal_bars"], counts["measured"])),
        "opener_top": opener_top,
        "opener_hit_rate": _round(_div(opener_hits, opener_n)),
        "same_first_rate": _round(_div(counts["same_first"], counts["consec"])),
        "same_first2_rate": _round(_div(counts["same_first2"], counts["consec"])),
        "line_repeat_rate": _round(_div(counts["line_repeat_num"], counts["line_repeat_den"])),
        "trigram_repeat_rate": _round(_div(counts["tri_repeat_num"], counts["tri_repeat_den"])),
        "adlib_rate": _round(_div(counts["adlib_bars"], counts["lines"])),
        "adlib_pos_share": {
            key: _round(_div(counts["adlib_pos"].get(key, 0), adlib_n)) for key in ("start", "middle", "end")
        },
        "function_counts": {word: int(count) for word, count in counts["function"].items()},
        "function_rate": _round(_div(sum(counts["function"].values()), counts["tokens"])),
        "signature_set": list(signature_set),
        "signature_hit_rate": _round(signature_hit_rate),
        "measured": int(counts["measured"]),
        "lines": int(counts["lines"]),
    }


def signature_hit_rate(counts: dict, signature_set: set[str]) -> float:
    if not counts["content_n"]:
        return 0.0
    hits = sum(count for word, count in counts["content"].items() if word in signature_set)
    return hits / counts["content_n"]


def build_signature(counts: dict, packets: list[dict], catalog: dict) -> dict:
    unigram_df = document_freq(packets, "content")
    phrase_counts = Counter()
    phrase_counts.update(counts["bigrams"])
    phrase_counts.update(counts["trigrams"])
    phrase_df = document_freq(packets, "bigrams")
    for packet in packets:
        for gram in packet["counts"]["trigrams"]:
            phrase_df[gram] += 1
    catalog_phrases = Counter()
    catalog_phrases.update(catalog["bigrams"])
    catalog_phrases.update(catalog["trigrams"])
    lift_floor = 1.75
    unigrams = pick_signature(
        counts["content"], catalog["content"], unigram_df,
        counts["content_n"], catalog["content_n"],
        min_count=4, min_df=2, min_lift=lift_floor, limit=80,
    )
    if len(unigrams) < 15:
        lift_floor = 1.4
        unigrams = pick_signature(
            counts["content"], catalog["content"], unigram_df,
            counts["content_n"], catalog["content_n"],
            min_count=4, min_df=2, min_lift=lift_floor, limit=80,
        )
    phrases = pick_signature(
        phrase_counts, catalog_phrases, phrase_df,
        counts["bigram_n"] + counts["trigram_n"],
        catalog["bigram_n"] + catalog["trigram_n"],
        min_count=3, min_df=2, min_lift=2.0, limit=40, phrases=True,
    )
    signature_set = [row["text"] for row in unigrams[:60]]
    return {
        "lift_floor": lift_floor,
        "unigrams": unigrams,
        "phrases": phrases,
        "set": signature_set,
        "hit_rate": signature_hit_rate(counts, set(signature_set)),
    }


def line_overlap(all_songs: list[dict], anchors: list[dict]) -> dict[tuple[str, str], dict]:
    owners = defaultdict(set)
    for song in all_songs:
        seen = set()
        for text in song["lines"]:
            key = p1.norm_line(text)
            if not key or key in seen:
                continue
            seen.add(key)
            owners[key].add((song["title"], song["album"]))
    report = {}
    for song in anchors:
        identity = (song["title"], song["album"])
        unique = {p1.norm_line(text) for text in song["lines"] if p1.norm_line(text)}
        partners = Counter()
        shared = 0
        for key in unique:
            others = owners[key] - {identity}
            if not others:
                continue
            shared += 1
            for other in others:
                partners[other] += 1
        top = partners.most_common(1)
        report[identity] = {
            "overlap": round(shared / len(unique), 4) if unique else 0.0,
            "overlap_with": f"{top[0][0][0]} [{top[0][0][1]}]" if top else None,
            "overlap_lines": int(top[0][1]) if top else 0,
        }
    return report


def shared_long_line_keys(songs: list[dict], min_words: int = 4) -> set[str]:
    """Normalized lines of min_words or more that show up in two different song/album rows.

    Short lines stay out of this set. Producer tags are usually under four words.
    The caller uses the set to keep borrowed bars out of mimic examples. The songs stay.
    """
    owners: dict[str, set[tuple[str, str]]] = defaultdict(set)
    for song in songs:
        identity = (song["title"], song.get("album") or "")
        seen: set[str] = set()
        for text in song["lines"]:
            key = p1.norm_line(text)
            if not key or key in seen:
                continue
            seen.add(key)
            if len(key.split()) >= min_words:
                owners[key].add(identity)
    return {key for key, identities in owners.items() if len(identities) > 1}


def _pct(value) -> str:
    if value is None:
        return "n/a"
    return f"{100 * value:.0f}%"


def _num(value) -> str:
    if value is None:
        return "n/a"
    if isinstance(value, float) and value.is_integer():
        return str(int(value))
    return str(value)


def render_summary(profile: dict) -> str:
    totals = profile["totals"]
    cadence = profile["cadence"]
    starts = profile["starts"]
    rhyme = profile["rhyme"]
    repetition = profile["repetition"]
    adlibs = profile["adlibs"]
    vocab = profile["vocabulary"]
    shape = profile["shape"]
    lines = [
        f"Gunna anchor profile  ({totals['songs']} songs)",
        f"Raw lines {totals['raw_lines']}   unique lines {totals['unique_lines']}   "
        f"style lines measured {totals['style_lines']}   bars with 2+ words {totals['measured_bars']}",
        f"Detected verse lines {totals['detected_verse_bars']}   hook lines {totals['hook_bars']}   "
        f"songs measured from the first copy because the section repeats: {totals['fallback_songs']}",
        f"Genius cover-art lines dropped before measuring: {totals.get('chrome_lines_dropped', 0)}",
        "",
        "Syllables per measured line (hooks left out; repeated setlist copies counted once):",
        f"  median {_num(cadence['syl_median'])}   mean {_num(cadence['syl_mean'])}   "
        f"middle 80% {_num(cadence['syl_p10'])} to {_num(cadence['syl_p90'])}   "
        f"std {_num(cadence['syl_std'])}",
        f"  comma in {_pct(cadence['comma_rate'])} of measured lines. "
        f"When there is a comma, first half median {_num(cadence['half_before_median'])} syl, "
        f"second half median {_num(cadence['half_after_median'])}. "
        f"First half shorter: {_pct(cadence['setup_shorter_rate'])} of comma lines.",
        "",
        "How lines start:",
        "  first word: " + ", ".join(f"{row['text']} {row['count']}" for row in starts["first_word"][:8]),
        "  first two words: " + ", ".join(f"{row['text']} {row['count']}" for row in starts["first_two"][:6]),
        f"  next line starts with the same word {_pct(starts['same_first_rate'])} of the time, "
        f"the same two words {_pct(starts['same_first2_rate'])}.",
        "",
        "End rhyme on the measured lines (not a fixed AABB):",
        f"  rhymes the line before: {_pct(rhyme['dist1_rate'])}",
        f"  rhymes the line two back instead: {_pct(rhyme['alt_rate'])}",
        f"  lines sitting in a run of 3+ on one sound: {_pct(rhyme['run3_share'])}",
        f"  of the rhyme links, the same end word repeated: {_pct(rhyme['identical_share'])}",
        f"  internal rhyme (two content words, same rime): {_pct(rhyme['internal_rate'])} of measured lines",
        f"  end word had a CMU rime: {_pct(rhyme['end_scored_rate'])}",
        "  vowel families: " + ", ".join(f"{row['text']} {_pct(row['share'])}" for row in rhyme["vowels"][:8]),
        "",
        "Repetition inside the measured verses:",
        f"  lines that repeat an earlier line in the same verse: {_pct(repetition['line_repeat_rate'])}",
        f"  three-word phrases that occur more than once in the verse: {_pct(repetition['trigram_repeat_rate'])}",
        f"  verses with a call-and-response shape: {_pct(repetition['call_response_rate'])} "
        f"({repetition['call_response_verses']} of {repetition['verses']})",
        "",
        "Ad-libs in parentheses (4 words or shorter):",
        f"  lines with one: {_pct(adlibs['rate'])}   "
        f"placement start {_pct(adlibs['position'].get('start'))}, "
        f"middle {_pct(adlibs['position'].get('middle'))}, end {_pct(adlibs['position'].get('end'))}",
        "  most common: " + ", ".join(f"{row['text']} {row['count']}" for row in adlibs["common"][:10]),
    ]
    rates = sorted((song.get("adlib_rate") or 0.0, song["title"]) for song in profile["songs"])
    if rates:
        mid = rates[len(rates) // 2]
        lines.append(
            f"  per song: min {_pct(rates[0][0])} ({rates[0][1]}), "
            f"median {_pct(mid[0])} ({mid[1]}), "
            f"max {_pct(rates[-1][0])} ({rates[-1][1]})"
        )
    lines += [
        "",
        f"Signature words (more often in this set than in all of his verses; lift floor {vocab['lift_floor']}):",
        "  " + ", ".join(f"{row['text']} x{row['lift']}" for row in vocab["signature_unigrams"][:15]),
        "Signature phrases:",
        "  " + ", ".join(f"{row['text']} x{row['lift']}" for row in vocab["signature_phrases"][:10]),
        "Brands the detector found (count >= 2): "
        + (", ".join(f"{row['text']} {row['count']}" for row in vocab["brands"]) or "none"),
        "Places the detector found (count >= 2): "
        + (", ".join(f"{row['text']} {row['count']}" for row in vocab["places"]) or "none"),
        "Mid-line capitals (count >= 2): "
        + (", ".join(f"{row['text']} {row['count']}" for row in vocab["capitalized"][:12]) or "none"),
        "",
        "Verse shape (songs whose sections repeat are not given a fake verse length):",
        f"  verse length median {_num(shape['verse_median'])} lines "
        f"(p10 {_num(shape['verse_p10'])}, p90 {_num(shape['verse_p90'])}, n={shape['verse_n']})",
        f"  hook length median {_num(shape['hook_median'])} lines (n={shape['hook_n']})",
        f"  first hook starts about {_pct(shape['first_hook_median'])} of the way into the song",
        "  section patterns: " + ", ".join(f"{row['text']} {row['count']}" for row in shape["patterns"][:6]),
        "",
        "Songs (CSV title, CSV album, raw, unique, detected verse, hook, fallback, line-overlap with another song):",
    ]
    for song in profile["songs"]:
        flag = "FALLBACK" if song["fallback"] else "verse"
        overlap = f"{100 * song['overlap']:.0f}%"
        partner = f" ~ {song['overlap_with']}" if song.get("overlap_with") else ""
        review = "  REVIEW" if song["overlap"] >= 0.5 else ""
        lines.append(
            f"  {song['title']}  |  {song['album']}  |  raw {song['raw_lines']}  unique {song['unique_lines']}  "
            f"verse {song['detected_verse_bars']}  hook {song['hook_bars']}  {flag}  "
            f"adlib {_pct(song.get('adlib_rate'))}  overlap {overlap}{partner}{review}"
        )
        if song.get("album_note"):
            lines.append(f"      album note: {song['album_note']}")
    lines.append("")
    lines.append("Brands are a fixed detector plus signature phrases. A different spelling lands in the signature list.")
    lines.append("Syllables, rhymes, and openers use lines with at least two words after parentheticals are removed.")
    return "\n".join(lines)


def render_facts(profile: dict) -> list[str]:
    cadence = profile["cadence"]
    starts = profile["starts"]
    rhyme = profile["rhyme"]
    repetition = profile["repetition"]
    adlibs = profile["adlibs"]
    vocab = profile["vocabulary"]
    shape = profile["shape"]
    openers = ", ".join(row["text"] for row in starts["first_word"][:6]) or "n/a"
    vowels = ", ".join(row["text"] for row in rhyme["vowels"][:6]) or "n/a"
    words = ", ".join(row["text"] for row in vocab["signature_unigrams"][:12]) or "none measured"
    phrases = ", ".join(row["text"] for row in vocab["signature_phrases"][:6]) or "none measured"
    brands = ", ".join(row["text"] for row in vocab["brands"][:8]) or "none from the detector"
    places = ", ".join(row["text"] for row in vocab["places"][:6]) or "none from the detector"
    adlib_words = ", ".join(row["text"] for row in adlibs["common"][:6]) or "none"
    position = max(adlibs["position"], key=adlibs["position"].get) if adlibs["position"] else "end"
    return [
        f"Measured line length in this era: median {_num(cadence['syl_median'])} syllables, "
        f"middle 80% from {_num(cadence['syl_p10'])} to {_num(cadence['syl_p90'])}.",
        f"{_pct(cadence['comma_rate'])} of measured lines contain a comma. "
        f"When they do, the first half is about {_num(cadence['half_before_median'])} syllables "
        f"and the second about {_num(cadence['half_after_median'])}. Do not put a comma in every line.",
        f"Lines often start with: {openers}. "
        f"The next line starts with the same word {_pct(starts['same_first_rate'])} of the time.",
        f"End rhyme is mixed, not a fixed scheme. {_pct(rhyme['dist1_rate'])} of lines rhyme the line before, "
        f"{_pct(rhyme['alt_rate'])} rhyme the line two back instead, "
        f"and {_pct(rhyme['run3_share'])} of lines sit in a run of 3 or more on one sound. "
        f"He repeats the same end word on {_pct(rhyme['identical_share'])} of rhyme links. Do not force AABB or ABAB.",
        f"Most used end-sound families: {vowels}.",
        f"Internal rhymes show up on {_pct(rhyme['internal_rate'])} of lines. Do not force a rhyme inside the line.",
        f"{_pct(adlibs['rate'])} of lines have a short ad-lib in parentheses, usually at the {position}. "
        f"Common ones: {adlib_words}. Use about that rate, not one on every line.",
        f"Inside a verse, {_pct(repetition['line_repeat_rate'])} of lines repeat an earlier line and "
        f"{_pct(repetition['trigram_repeat_rate'])} of three-word phrases repeat. "
        f"Call-and-response shows up in {_pct(repetition['call_response_rate'])} of verses.",
        f"Words he uses more in these songs than in the rest of his catalog: {words}. "
        "Use one or two if they belong. Do not stuff them in.",
        f"Phrases with the same kind of lift: {phrases}.",
        f"Brands he names here: {brands}. Places: {places}.",
        f"These files rarely repeat a hook, so the measured stretch (median {_num(shape['verse_median'])} lines) "
        "is usually the whole song, not a target length. Write only the number of bars you were asked for. "
        f"Repeated hooks that did show up run about {_num(shape['hook_median'])} lines "
        f"(n={shape['hook_n']}).",
        "Phase in this file is Drip Season 2, released 2017-05-11, track 1. "
        "The CSV stores that song under album Unknown.",
        "Songs filed under Gunna: A Gift & a Curse Setlist are his 2023 live tour set. "
        "They stay in this era on purpose.",
        "Example verses leave out any line of four or more words that also appears in another Gunna song.",
    ]


def _catalog_bucket() -> dict:
    return {
        "content": Counter(), "content_n": 0, "tokens": 0,
        "bigrams": Counter(), "bigram_n": 0, "trigrams": Counter(), "trigram_n": 0,
    }


def _add_catalog(bucket: dict, counts: dict) -> None:
    bucket["content"].update(counts["content"])
    bucket["content_n"] += counts["content_n"]
    bucket["tokens"] += counts["tokens"]
    bucket["bigrams"].update(counts["bigrams"])
    bucket["bigram_n"] += counts["bigram_n"]
    bucket["trigrams"].update(counts["trigrams"])
    bucket["trigram_n"] += counts["trigram_n"]


def _sub_catalog(bucket: dict, counts: dict) -> dict:
    out = _catalog_bucket()
    out["content"] = sub_counter(bucket["content"], counts["content"])
    out["bigrams"] = sub_counter(bucket["bigrams"], counts["bigrams"])
    out["trigrams"] = sub_counter(bucket["trigrams"], counts["trigrams"])
    out["content_n"] = max(0, bucket["content_n"] - counts["content_n"])
    out["tokens"] = max(0, bucket["tokens"] - counts["tokens"])
    out["bigram_n"] = max(0, bucket["bigram_n"] - counts["bigram_n"])
    out["trigram_n"] = max(0, bucket["trigram_n"] - counts["trigram_n"])
    return out


def compute(csv_path: Path, cmu_path: Path, progress: bool = True) -> dict:
    """Measure the anchor set. Returns profile (JSON-ready) plus in-memory packets for leave-one-out.

    Packets and the returned line map are not written to disk.
    """
    gunna = load_gunna(csv_path, progress=progress)
    matched, missing = match_anchors(gunna)
    if missing:
        raise SystemExit("anchor titles not in the CSV: " + ", ".join(missing))
    if progress:
        print(f"matched {len(matched)} anchor songs, loading CMUdict ...", file=sys.stderr)
    lex = p1.Lexicon(p1.load_cmudict(cmu_path))
    overlap = line_overlap(gunna, matched)
    anchor_keys = {(song["title"], song["album"]) for song in matched}
    packets = []
    catalog = _catalog_bucket()
    lines_by_id = {}
    for index, song in enumerate(gunna, 1):
        identity = (song["title"], song["album"])
        is_anchor = identity in anchor_keys
        info, counts = song_counts(song, lex, light=not is_anchor)
        _add_catalog(catalog, counts)
        if is_anchor:
            packets.append({"song": song, "info": info, "counts": counts})
            lines_by_id[identity] = song["lines"]
        if progress and index % 100 == 0:
            print(f"  measured {index}/{len(gunna)} Gunna songs", file=sys.stderr)
    by_id = {(packet["song"]["title"], packet["song"]["album"]): packet for packet in packets}
    ordered = [by_id[(song["title"], song["album"])] for song in matched]
    total_counts = sum_counts(ordered)
    signature = build_signature(total_counts, ordered, catalog)
    targets = make_targets(total_counts, signature["set"], signature["hit_rate"])
    profile = _assemble(ordered, total_counts, signature, targets, overlap)
    profile["summary"] = render_summary(profile)
    profile["prompt_facts"] = render_facts(profile)
    return {
        "profile": profile,
        "packets": ordered,
        "catalog": catalog,
        "lines": lines_by_id,
        "lex": lex,
    }


def loo_targets(held_out: dict, packets: list[dict], catalog: dict) -> dict:
    """Targets fit on every anchor song except `held_out`."""
    others = [packet for packet in packets if packet is not held_out]
    counts = subtract_counts(sum_counts(packets), held_out["counts"])
    reduced_catalog = _sub_catalog(catalog, held_out["counts"])
    signature = build_signature(counts, others, reduced_catalog)
    return make_targets(counts, signature["set"], signature["hit_rate"])


def _assemble(packets: list[dict], counts: dict, signature: dict, targets: dict, overlap: dict) -> dict:
    songs = []
    raw_lines = unique_lines = 0
    for packet in packets:
        song, info = packet["song"], packet["info"]
        unique = len({p1.norm_line(text) for text in song["lines"] if p1.norm_line(text)})
        raw_lines += len(song["lines"])
        unique_lines += unique
        extra = overlap.get((song["title"], song["album"]), {})
        song_counts_row = packet["counts"]
        songs.append({
            "hint_title": song.get("hint_title", song["title"]),
            "hint_album": song.get("hint_album", song["album"]),
            "title": song["title"],
            "album": song["album"],
            "year": song.get("year") or "",
            "raw_lines": len(song["lines"]),
            "unique_lines": unique,
            "adlib_rate": _round(_div(song_counts_row["adlib_bars"], song_counts_row["lines"])),
            "detected_verse_bars": info["detected_verse_bars"],
            "hook_bars": info["hook_bars"],
            "other_bars": info["other_bars"],
            "fallback": info["fallback"],
            "pattern": info["pattern"],
            "first_hook_frac": info["first_hook_frac"],
            "overlap": extra.get("overlap", 0.0),
            "overlap_with": extra.get("overlap_with"),
            "album_note": song.get("album_note"),
        })
    syl = dist_numbers(expand_hist(counts["syl"]))
    half_before = dist_numbers(expand_hist(counts["half_before"]))
    half_after = dist_numbers(expand_hist(counts["half_after"]))
    verse_lengths = dist_numbers(list(counts["verse_lengths"]))
    hook_lengths = dist_numbers([length for packet in packets for length in packet["info"]["hook_lengths"]])
    hook_fracs = [song["first_hook_frac"] for song in songs if song["first_hook_frac"] is not None]
    patterns = Counter(song["pattern"] for song in songs if song["pattern"])
    vowel_n = sum(counts["vowels"].values()) or 1
    vowels = [
        {"text": text, "count": int(count), "share": round(count / vowel_n, 4)}
        for text, count in counts["vowels"].most_common(12)
    ]
    adlib_n = sum(counts["adlib_pos"].values())
    position = {
        key: round(_div(counts["adlib_pos"].get(key, 0), adlib_n), 4) for key in ("start", "middle", "end")
    }
    rhyme_links = counts["dist1_hits"] + counts["alt_hits"]
    identical_share = _round(_div(counts["identical_links"], rhyme_links))
    profile = {
        "schema": SCHEMA,
        "artist": "Gunna",
        "songs": songs,
        "totals": {
            "songs": len(songs),
            "raw_lines": raw_lines,
            "unique_lines": unique_lines,
            "style_lines": int(counts["lines"]),
            "measured_bars": int(counts["measured"]),
            "detected_verse_bars": sum(song["detected_verse_bars"] for song in songs),
            "hook_bars": sum(song["hook_bars"] for song in songs),
            "fallback_songs": sum(1 for song in songs if song["fallback"]),
            "chrome_lines_dropped": sum(int(packet["song"].get("chrome_dropped") or 0) for packet in packets),
        },
        "cadence": {
            "syl_mean": syl["mean"], "syl_median": syl["median"], "syl_std": syl["std"],
            "syl_p10": syl["p10"], "syl_p90": syl["p90"], "syl_min": syl["min"], "syl_max": syl["max"],
            "syl_hist": targets["syl_hist"],
            "comma_rate": targets["comma_rate"],
            "half_before_median": half_before["median"],
            "half_after_median": half_after["median"],
            "half_before_hist": targets["half_before_hist"],
            "half_after_hist": targets["half_after_hist"],
            "setup_shorter_rate": _round(_div(counts["setup_shorter"], counts["comma_bars"])),
        },
        "starts": {
            "first_word": _top(counts["openers"], 15),
            "first_two": _top(counts["openers2"], 12),
            "same_first_rate": targets["same_first_rate"],
            "same_first2_rate": targets["same_first2_rate"],
            "opener_hit_rate": targets["opener_hit_rate"],
        },
        "rhyme": {
            "dist1_rate": targets["dist1_rate"],
            "alt_rate": targets["alt_rate"],
            "run3_share": targets["run3_share"],
            "identical_share": identical_share,
            "internal_rate": targets["internal_rate"],
            "end_scored_rate": _round(_div(counts["end_scored"], counts["measured"])),
            "vowels": vowels,
        },
        "repetition": {
            "line_repeat_rate": targets["line_repeat_rate"],
            "trigram_repeat_rate": targets["trigram_repeat_rate"],
            "call_response_verses": int(counts["call_response_verses"]),
            "verses": int(counts["verses"]),
            "call_response_rate": _round(_div(counts["call_response_verses"], counts["verses"])),
        },
        "adlibs": {
            "rate": targets["adlib_rate"],
            "position": position,
            "common": _top(counts["adlib_texts"], 15, floor=2),
        },
        "vocabulary": {
            "lift_floor": signature["lift_floor"],
            "signature_unigrams": signature["unigrams"],
            "signature_phrases": signature["phrases"],
            "signature_hit_rate": _round(signature["hit_rate"]),
            "brands": _top(counts["brands"], 20, floor=2),
            "places": _top(counts["places"], 15, floor=2),
            "capitalized": _top(counts["caps"], 15, floor=2),
        },
        "shape": {
            "verse_n": verse_lengths["n"],
            "verse_median": verse_lengths["median"],
            "verse_p10": verse_lengths["p10"],
            "verse_p90": verse_lengths["p90"],
            "hook_n": hook_lengths["n"],
            "hook_median": hook_lengths["median"],
            "first_hook_median": round(sorted(hook_fracs)[len(hook_fracs) // 2], 3) if hook_fracs else None,
            "patterns": [{"text": text, "count": int(count)} for text, count in patterns.most_common(8)],
        },
        "targets": targets,
        "hard_rhyme": {
            "min_any_links": 1,
            "identical_only_ok": identical_share >= 0.2,
        },
    }
    return profile


def windows_from_lines(lines: list[str], size: int, cap: int = 3) -> list[list[str]]:
    info = style_lines_for(lines)
    sources = info["real_verses"] or info["style_verses"]
    found = []
    for verse in sources:
        if len(verse) < size:
            continue
        for start in range(0, len(verse) - size + 1, size):
            found.append(verse[start:start + size])
            if len(found) >= cap:
                return found
    return found


def _self_check() -> None:
    verse = [f"alpha line {index} walks across the room tonight" for index in range(8)]
    hook = ["same hook line alpha here", "same hook line beta here", "same hook line gamma here"]
    sections = segment_sections(verse + hook + [f"bravo line {index} keeps it moving tonight" for index in range(8)] + hook)
    kinds = "".join(section["kind"][0].upper() for section in sections)
    assert compress_pattern(kinds) == "VHVH", kinds
    assert sum(len(section["lines"]) for section in sections if section["kind"] == "hook") == 6
    doubled = style_lines_for((verse + hook) * 2)
    assert doubled["fallback"] is True
    assert doubled["real_verses"] == []
    assert len(doubled["style_verses"]) == 1
    plain = style_lines_for(verse)
    assert plain["fallback"] is False and plain["detected_verse_bars"] == 8
    curly = "Don\u2019t Give Up"
    assert norm_title(curly) == norm_title("Don't Give Up")
    songs = [
        {"title": "Phase", "album": "Unknown", "lines": ["one"], "artist": "Gunna", "year": ""},
        {"title": "idk that bitch", "album": "DRIP SEASON 4EVER", "lines": ["a"] * 10, "artist": "Gunna", "year": ""},
        {"title": "idk that bitch", "album": "DS4EVER", "lines": ["b"] * 3, "artist": "Gunna", "year": ""},
        {"title": curly, "album": "Unknown", "lines": ["c"], "artist": "Gunna", "year": ""},
    ]
    matched, missing = match_anchors(songs)
    by_hint = {song["hint_title"]: song for song in matched}
    assert by_hint["Phase"]["album"] == "Unknown"
    assert by_hint["Don't Give Up"]["title"] == curly
    assert by_hint["idk that bitch"]["album"] == "DRIP SEASON 4EVER"
    assert "Lie About You" not in ANCHOR_SONGS and len(missing) == len(ANCHOR_SONGS) - 3
    assert is_chrome_line("| aria-label: Cover art for Example by Someone |")
    assert not is_chrome_line("I got the work on my neck tonight")
    assert len(ANCHOR_SONGS) == 20

    class _Stub:
        def info(self, word):
            return (1, 0, "AY", None, True)

        def phones_for(self, word):
            return ["AY1"]

    feat = features_from_lines(["i stay", "i stay late", "she called"], _Stub())
    assert feat["consec"] == 2 and feat["same_first"] == 1 and feat["same_first2"] == 1, (
        feat["consec"], feat["same_first"], feat["same_first2"])
    shared = shared_long_line_keys([
        {"title": "A", "album": "1", "lines": ["run that back turbo now please", "only in a"]},
        {"title": "B", "album": "2", "lines": ["run that back turbo now please", "yeah"]},
    ])
    assert shared == {p1.norm_line("run that back turbo now please")}, shared
    print("anchor_lib self-check ok")


if __name__ == "__main__":
    _self_check()
