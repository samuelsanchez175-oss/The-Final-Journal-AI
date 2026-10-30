#!/usr/bin/env python3
"""Steps 4-7, 9-10: text-only stats on Gunna's 31,508 lines.

Reads docs/flow-rules/gunna_lines.jsonl, writes:
  docs/flow-rules/gunna_stats.json
  docs/flow-rules/gunna_examples.jsonl
  docs/flow-rules/analysis.md            — human-readable summary

Does NOT make API calls, does NOT need the catalog SQLite.

Stress / triplet / syllable detection via lyriclib's CMU dict when present;
tagged ESTIMATE because CMU covers ~95% of common words and nothing else.
"""
from __future__ import annotations

import collections
import json
import math
import random
import re
import statistics
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
LLM = REPO / "tools" / "lyric-llm"
OUT = REPO / "docs" / "flow-rules"
sys.path.insert(0, str(LLM))

try:
    from lyriclib import load_cmudict, end_rime
    CMU_PATH = REPO / "XJournal AI" / "cmudict.txt"
    CMU = load_cmudict(CMU_PATH) if CMU_PATH.exists() else {}
except Exception:
    CMU = {}
    end_rime = lambda w, d: None  # type: ignore

_WORD = re.compile(r"[A-Za-z']+")


def _tokens(line: str) -> list[str]:
    return _WORD.findall(line or "")


def _syllables(word: str) -> int:
    """CMU count (stressed vowels in first pronunciation) with vowel-group fallback."""
    w = re.sub(r"[^A-Za-z']", "", word).lower()
    if not w:
        return 0
    phones = CMU.get(w)
    if phones:
        return sum(1 for ph in phones if any(c.isdigit() for c in ph))
    vowels = "aeiouy"
    count, prev = 0, False
    for c in w:
        is_v = c in vowels
        if is_v and not prev:
            count += 1
        prev = is_v
    return max(count, 1)


def _line_syllables(line: str) -> int:
    return sum(_syllables(w) for w in _tokens(line))


def _ends_terminal(line: str) -> bool:
    s = (line or "").rstrip()
    return bool(s) and s[-1] in ".!?"


def _starts_lower(line: str) -> bool:
    for ch in (line or ""):
        if ch.isalpha():
            return ch.islower()
    return False


_CONJ = {"and", "but", "or", "so", "yet", "if", "then", "when",
         "while", "though", "as", "because"}
_PREP = {"to", "of", "in", "on", "with", "by", "for", "at", "from",
         "into", "about", "over", "under", "through"}


def _conj_or_prep_start(line: str) -> bool:
    toks = _tokens(line)
    if not toks:
        return False
    return toks[0].lower() in (_CONJ | _PREP)


def analyze_commas(lines: list[dict]) -> dict:
    counts = collections.Counter()
    bucket_rates = collections.Counter()  # 0, 1, 2, 3+
    rel_positions: list[float] = []
    word_indices: list[int] = []
    syl_indices: list[int] = []
    for row in lines:
        line = row["line"]
        n = line.count(",")
        counts[n] += 1
        bucket_rates[min(n, 3)] += 1
        if n == 0:
            continue
        # per-comma word index, syllable index, relative position
        chars = list(line)
        word_idx = 0
        syl_idx = 0
        in_word = False
        for i, ch in enumerate(chars):
            if ch.isalpha() or ch == "'":
                if not in_word:
                    word_idx += 1
                    in_word = True
            else:
                in_word = False
            if ch == ",":
                rel_positions.append(round(i / max(len(chars) - 1, 1), 3))
                word_indices.append(word_idx)
                # approximate syllable index up to this char
                syl_idx = sum(_syllables(w) for w in _tokens(line[:i]))
                syl_indices.append(syl_idx)
    total = sum(counts.values())
    return {
        "line_count": total,
        "comma_counts": dict(counts),
        "0_1_2_3plus_rates": {str(k): round(v / max(total, 1), 4)
                              for k, v in sorted(bucket_rates.items())},
        "mean_commas_per_line": round(sum(k * v for k, v in counts.items()) / max(total, 1), 3),
        "word_index_distribution_quartiles": _quartiles(word_indices),
        "syllable_index_distribution_quartiles": _quartiles(syl_indices),
        "relative_position_quartiles": _quartiles(rel_positions),
    }


def _quartiles(xs: list[float]) -> dict | None:
    if not xs:
        return None
    s = sorted(xs)
    def q(p: float) -> float:
        if not s:
            return 0.0
        k = int(round((len(s) - 1) * p))
        return round(float(s[k]), 3)
    return {"n": len(s), "p25": q(0.25), "median": q(0.5), "p75": q(0.75), "p90": q(0.9)}


def analyze_carry(lines: list[dict]) -> dict:
    """Enjambment: non-terminal line followed by lowercase/conj/prep start."""
    # group by song, maintain order (rows are already sorted by rowid)
    by_song: dict[tuple, list[dict]] = {}
    for r in lines:
        by_song.setdefault((r["artist"], r["song"]), []).append(r)
    carry_count = 0; total = 0
    carry_lengths: list[int] = []
    carry_end_words: collections.Counter = collections.Counter()
    close_end_words: collections.Counter = collections.Counter()
    for seq in by_song.values():
        i = 0
        while i < len(seq) - 1:
            cur = seq[i]["line"]
            nxt = seq[i + 1]["line"]
            is_carry = (not _ends_terminal(cur)) and (
                _starts_lower(nxt) or _conj_or_prep_start(nxt))
            toks_cur = _tokens(cur)
            end_cur = toks_cur[-1].lower() if toks_cur else ""
            if is_carry:
                carry_count += 1
                carry_end_words[end_cur] += 1
                length = 2
                j = i + 1
                while j < len(seq) - 1:
                    nj = seq[j]["line"]
                    nj_next = seq[j + 1]["line"]
                    if (not _ends_terminal(nj)) and (
                        _starts_lower(nj_next) or _conj_or_prep_start(nj_next)):
                        length += 1
                        j += 1
                    else:
                        break
                carry_lengths.append(length)
                i = j + 1
            else:
                if end_cur:
                    close_end_words[end_cur] += 1
                i += 1
            total += 1
    length_hist = collections.Counter()
    for ln in carry_lengths:
        key = str(ln) if ln < 4 else "4+"
        length_hist[key] += 1
    return {
        "lines_examined": total,
        "carry_count": carry_count,
        "carry_rate": round(carry_count / max(total, 1), 4),
        "length_hist": dict(length_hist),
        "top_carry_end_words": carry_end_words.most_common(15),
        "top_close_end_words": close_end_words.most_common(15),
    }


_TRIPLET_SYL = 3


def analyze_triplets(lines: list[dict]) -> dict:
    """ESTIMATE: flag lines where a 3-token sequence of 1-syllable words
    recurs with similar stress — Migos-style triplet. Also flag high density
    (≥16 syllables with ≥3 commas) and repeated-word stacks (same word 3x)."""
    triplet_count = 0
    density_count = 0
    stack_count = 0
    syl_triplet: list[int] = []
    syl_normal: list[int] = []
    examples: list[dict] = []
    for r in lines:
        line = r["line"]
        toks = _tokens(line)
        syl = sum(_syllables(t) for t in toks)
        is_triplet = False
        # repeated-word stack
        for i in range(len(toks) - 2):
            if toks[i].lower() == toks[i + 1].lower() == toks[i + 2].lower():
                stack_count += 1
                is_triplet = True
                break
        # 3 adjacent short mono-syllabic words (triplet beat approximation)
        if not is_triplet:
            runs = 0
            for i in range(len(toks) - 2):
                if all(_syllables(t) == 1 for t in toks[i:i + 3]):
                    runs += 1
            # tightened: require ≥3 runs AND ≥8 tokens (post-fix the old
            # 2-run/6-token threshold fires on 73% of lines, since most
            # English short-content words are mono-syllabic).
            if runs >= 3 and len(toks) >= 8:
                triplet_count += 1
                is_triplet = True
        # high density
        if syl >= 16 and line.count(",") >= 3:
            density_count += 1
        if is_triplet:
            syl_triplet.append(syl)
            if len(examples) < 8:
                examples.append({"artist": r["artist"], "song": r["song"], "line": line})
        else:
            syl_normal.append(syl)
    n = len(lines)
    return {
        "lines": n,
        "triplet_flag_rate": round(triplet_count / max(n, 1), 4),
        "repeated_stack_rate": round(stack_count / max(n, 1), 4),
        "density_rate": round(density_count / max(n, 1), 4),
        "syllables_median_triplet": statistics.median(syl_triplet) if syl_triplet else None,
        "syllables_median_normal": statistics.median(syl_normal) if syl_normal else None,
        "sample_examples": examples,
        "ESTIMATE": True,
    }


def _end_rime(word: str) -> tuple[str, ...] | None:
    r = end_rime(word.lower(), CMU) if CMU else None
    return tuple(r) if r else None


def analyze_rhyme(lines: list[dict]) -> dict:
    """End-rime per block of 4, consecutive rime hits, inner rhyme per line,
    repeated end-word rate."""
    # group by song, keep order
    by_song: dict[tuple, list[dict]] = {}
    for r in lines:
        by_song.setdefault((r["artist"], r["song"]), []).append(r)
    one_rime_4block = 0; total_4block = 0
    consec_hits = 0; consec_total = 0
    repeated_end_runs = 0; repeat_total = 0
    all_end_words: collections.Counter = collections.Counter()
    for seq in by_song.values():
        ends = [t[-1].lower() if (t := _tokens(r["line"])) else "" for r in seq]
        for ew in ends:
            if ew:
                all_end_words[ew] += 1
        rimes = [_end_rime(ew) for ew in ends]
        # 4-line blocks
        for i in range(0, len(rimes) - 3, 4):
            blk = rimes[i:i + 4]
            if any(blk):
                total_4block += 1
                non_none = [r for r in blk if r]
                if non_none and all(r == non_none[0] for r in non_none):
                    one_rime_4block += 1
        for i in range(1, len(rimes)):
            if rimes[i] and rimes[i - 1]:
                consec_total += 1
                if rimes[i] == rimes[i - 1]:
                    consec_hits += 1
        for i in range(1, len(ends)):
            if ends[i] and ends[i] == ends[i - 1]:
                repeated_end_runs += 1
            if ends[i]:
                repeat_total += 1
    # inner rhyme per line (ESTIMATE): count content words sharing end_rime
    inner_counts: list[int] = []
    multisyl_hits = 0; multisyl_total = 0
    for r in lines:
        toks = _tokens(r["line"])
        if len(toks) < 3:
            continue
        rimes = [_end_rime(t) for t in toks]
        seen = {}
        hits = 0
        for rime in rimes:
            if not rime:
                continue
            seen[rime] = seen.get(rime, 0) + 1
            if seen[rime] == 2:
                hits += 1
        inner_counts.append(hits)
        # multisyllable: end word has ≥2 syllables and rhymes with another ≥2-syl word
        if toks:
            end_w = toks[-1]
            if _syllables(end_w) >= 2 and len(toks) > 1:
                multisyl_total += 1
                e_rime = _end_rime(end_w)
                for t in toks[:-1]:
                    if _syllables(t) >= 2 and _end_rime(t) == e_rime:
                        multisyl_hits += 1
                        break
    return {
        "one_rime_4bar_rate": round(one_rime_4block / max(total_4block, 1), 4),
        "one_rime_4bar_n": total_4block,
        "consecutive_rime_hit_rate": round(consec_hits / max(consec_total, 1), 4),
        "consecutive_pairs_examined": consec_total,
        "repeated_end_word_rate": round(repeated_end_runs / max(repeat_total, 1), 4),
        "repeated_end_word_pairs": repeat_total,
        "inner_rhyme_mean": round(statistics.mean(inner_counts), 3) if inner_counts else 0.0,
        "inner_rhyme_median": statistics.median(inner_counts) if inner_counts else 0.0,
        "multisyllable_rhyme_rate": round(multisyl_hits / max(multisyl_total, 1), 4),
        "multisyllable_rhyme_n": multisyl_total,
        "top_end_words": all_end_words.most_common(30),
        "ESTIMATE_inner_and_multisyl": True,
    }


_POV_I = {"i", "i'm", "im", "ima", "i'ma", "me", "my", "mine", "myself", "we", "us", "our"}
_POV_YOU = {"you", "you're", "your", "yours", "yourself", "u", "ur"}
_POV_THEY = {"they", "them", "their", "theirs", "themselves", "he", "she", "him", "her", "his", "hers"}


def analyze_pov_mood(lines: list[dict]) -> dict:
    pov = collections.Counter()
    moods = {
        "flex_luxury": {"racks", "bands", "mil", "mill", "million", "stacks", "jewelry", "iced",
                        "diamond", "chain", "lambo", "ferrari", "bentley", "wraith", "wock",
                        "rolex", "patek", "ap", "cuban", "range", "coupe", "fendi", "gucci",
                        "chanel", "designer"},
        "pain_loss": {"pain", "tears", "cry", "crying", "miss", "loss", "lost", "fallen",
                      "broken", "funeral", "grave", "regret", "hurt", "hurts", "bleed",
                      "lonely", "alone"},
        "love": {"love", "babe", "baby", "shawty", "boo", "wifey", "wife", "husband",
                 "kiss", "kissing", "miss", "forever", "soul", "heart"},
        "threat_violence": {"gun", "glock", "stick", "smoke", "pop", "shoot", "shootin",
                            "slide", "hit", "pistol", "blick", "drum", "ex", "k", "ar",
                            "rifle", "clip", "trigger", "chopper", "beam"},
    }
    mood_count = {k: 0 for k in moods}
    mood_examples: dict[str, list[dict]] = {k: [] for k in moods}
    for r in lines:
        toks = [t.lower() for t in _tokens(r["line"])]
        if not toks:
            continue
        pov_tag = None
        for t in toks:
            if t in _POV_I:
                pov_tag = "i"
                break
            if t in _POV_YOU and pov_tag is None:
                pov_tag = "you"
            if t in _POV_THEY and pov_tag is None:
                pov_tag = "they"
        pov[pov_tag or "none"] += 1
        for mood, lex in moods.items():
            if any(t in lex for t in toks):
                mood_count[mood] += 1
                if len(mood_examples[mood]) < 5:
                    mood_examples[mood].append(
                        {"artist": r["artist"], "song": r["song"], "line": r["line"]})
                break  # one tag per line keeps it clean
    total = sum(pov.values())
    return {
        "pov_rates": {k: round(v / max(total, 1), 4) for k, v in pov.items()},
        "pov_counts": dict(pov),
        "mood_counts": mood_count,
        "mood_rates": {k: round(v / max(total, 1), 4) for k, v in mood_count.items()},
        "mood_lexicons": {k: sorted(v) for k, v in moods.items()},
        "mood_examples": mood_examples,
        "LEXICON_BASED": True,
    }


def analyze_subtopics(lines: list[dict]) -> dict:
    clusters = {
        "brands": {"gucci", "fendi", "chanel", "louis", "prada", "versace", "balenciaga",
                   "dior", "ysl", "hermès", "hermes", "cartier", "burberry", "amiri"},
        "cars": {"lambo", "ferrari", "bentley", "wraith", "range", "porsche", "benz",
                 "chevy", "cadillac", "coupe", "maserati", "corvette", "scat"},
        "jewelry": {"chain", "iced", "diamond", "rolex", "patek", "ap", "watch",
                    "cuban", "pendant", "bust", "flooded", "vvs", "bezel"},
        "women": {"shawty", "wifey", "babe", "baby", "girl", "woman", "wife", "boo",
                  "ex", "ratchet", "bitch"},
        "drugs": {"wock", "lean", "perc", "percs", "molly", "xan", "xans", "percocet",
                  "weed", "zaza", "runtz", "backwoods", "swisher"},
        "loyalty": {"brother", "bro", "gang", "crew", "homie", "day one", "ride",
                    "trust", "loyal", "family", "fam"},
        "come_up": {"struggle", "hustle", "grind", "started", "trenches", "block",
                    "corner", "trap", "fiend", "work", "serve", "flip"},
    }
    counts = {k: 0 for k in clusters}
    examples: dict[str, list[dict]] = {k: [] for k in clusters}
    for r in lines:
        toks = [t.lower() for t in _tokens(r["line"])]
        for name, lex in clusters.items():
            if any(t in lex for t in toks):
                counts[name] += 1
                if len(examples[name]) < 5:
                    examples[name].append(
                        {"artist": r["artist"], "song": r["song"], "line": r["line"]})
    total = len(lines)
    return {
        "line_count": total,
        "counts": counts,
        "rates": {k: round(v / max(total, 1), 4) for k, v in counts.items()},
        "examples": examples,
        "lexicons": {k: sorted(v) for k, v in clusters.items()},
    }


def main() -> int:
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna"]
    stats = {
        "n_lines_total": len(lines),
        "n_lines_solo": len(solo),
        "n_songs": len({(r["artist"], r["song"]) for r in lines}),
        "cmudict_loaded": bool(CMU),
        "commas": analyze_commas(lines),
        "commas_solo": analyze_commas(solo),
        "carry": analyze_carry(lines),
        "carry_solo": analyze_carry(solo),
        "triplets": analyze_triplets(lines),
        "rhyme": analyze_rhyme(lines),
        "rhyme_solo": analyze_rhyme(solo),
        "pov_mood": analyze_pov_mood(lines),
        "subtopics": analyze_subtopics(lines),
    }
    (OUT / "gunna_stats.json").write_text(json.dumps(stats, indent=2, ensure_ascii=False))

    # pull 30 random examples with per-attribute tags for the examples file
    rng = random.Random(20261030)
    sample = rng.sample(solo, min(30, len(solo)))
    with (OUT / "gunna_examples.jsonl").open("w", encoding="utf-8") as f:
        for r in sample:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")

    # headline
    c = stats["commas_solo"]
    cr = stats["carry_solo"]
    tr = stats["triplets"]
    rh = stats["rhyme_solo"]
    print(f"n_lines={stats['n_lines_total']}  solo={stats['n_lines_solo']}  songs={stats['n_songs']}  CMU={bool(CMU)}")
    print(f"commas  mean/line={c['mean_commas_per_line']}  0_1_2_3+ rates={c['0_1_2_3plus_rates']}")
    print(f"carry   rate={cr['carry_rate']}  length_hist={cr['length_hist']}")
    print(f"triplet rate={tr['triplet_flag_rate']}  density_rate={tr['density_rate']}  stack_rate={tr['repeated_stack_rate']}")
    print(f"rhyme   1-rime 4bar rate={rh['one_rime_4bar_rate']}  consec={rh['consecutive_rime_hit_rate']}  "
          f"inner_mean={rh['inner_rhyme_mean']}  multisyl={rh['multisyllable_rhyme_rate']}")
    print(f"wrote gunna_stats.json, gunna_examples.jsonl")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
