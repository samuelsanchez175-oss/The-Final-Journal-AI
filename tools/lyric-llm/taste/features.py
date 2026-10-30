"""Feature extraction for a verse (list of bar strings).

Each feature is scalar; downstream judge consumes the dict as-is.

Features:
  end_rhyme_hit_rate  — fraction of couplet pairs (AABB) phonetically rhyming
  multisyllable_rhyme — fraction of couplet pairs sharing 2+ phoneme-tail match
  inner_rhyme_mean    — avg inner-rhyme count per bar (capped at 4 by audit)
  syl_variance        — stdev of per-bar syllable count (lower is tighter)
  syl_mean            — mean per-bar syllable count
  commas_per_bar      — avg comma count per bar
  bar_count           — number of bars
  profanity_rate      — fraction of bars with slur/profanity (ex-grind words)
  name_leak           — count of celebrity names that aren't the voice artist
"""
from __future__ import annotations

import re
import statistics
from pathlib import Path
from typing import Iterable, Optional

HERE = Path(__file__).resolve().parent
LLM_ROOT = HERE.parent

import sys
sys.path.insert(0, str(LLM_ROOT))

from lyriclib import load_cmudict, end_rime  # type: ignore
from inner_rhyme_check import count_bar_syllables, audit_bar_structure, get_cmu_dict  # type: ignore

_CMU_PATH = LLM_ROOT.parent.parent / "XJournal AI" / "cmudict.txt"
_CMU: Optional[dict[str, list[str]]] = None


def _cmu() -> dict[str, list[str]]:
    global _CMU
    if _CMU is None:
        _CMU = load_cmudict(_CMU_PATH) if _CMU_PATH.exists() else {}
    return _CMU


_END_WORD_RE = re.compile(r"[A-Za-z']+")


def _end_word(bar: str) -> str:
    words = _END_WORD_RE.findall(bar)
    return words[-1].lower() if words else ""


def _phonetic_rhyme(a: str, b: str, cmu: dict | None = None) -> bool:
    if not a or not b:
        return False
    if a == b:
        return True
    d = cmu if cmu is not None else _cmu()
    ra = end_rime(a, d) if d else None
    rb = end_rime(b, d) if d else None
    if ra is not None and rb is not None:
        return ra == rb
    # OOV fallback
    return a[-3:] == b[-3:]


def _rime_tail(word: str, cmu: dict) -> tuple[str, ...]:
    r = end_rime(word, cmu) if cmu else None
    return r or ()


def _multisyl_match(a: str, b: str, cmu: dict) -> bool:
    """True iff the two end rimes share 2+ segments at the tail."""
    ra = _rime_tail(a, cmu)
    rb = _rime_tail(b, cmu)
    if len(ra) < 2 or len(rb) < 2:
        return False
    return ra[-2:] == rb[-2:]


# small, deliberately coarse. meant to flag Samuel's "cringe" / profanity concerns
_PROFANE = {"bitch", "nigga", "niggas", "fuck", "shit", "pussy", "hoe", "hoes"}
# high-profile peers that often bleed into Path B output (expand as needed)
_CELEBRITY_NAMES = {
    "drake", "jay-z", "kanye", "future", "eminem", "slim shady", "biggie",
    "nicki", "cardi", "beyonce", "rihanna", "kendrick", "cole", "weeknd",
    "pop smoke", "takeoff", "offset", "quavo", "21 savage", "lil durk",
    "chief keef", "young thug", "gunna", "lil wayne", "lil baby", "nocap",
    "travis", "scott", "kylie", "post malone",
}


def _bar_commas(bar: str) -> int:
    return bar.count(",")


def _bar_syllables(bar: str, cmu: dict) -> int:
    try:
        return count_bar_syllables(bar, cmu)
    except Exception:
        return len(_END_WORD_RE.findall(bar))


def extract(bars: Iterable[str], voice: str | None = None) -> dict:
    """Return feature dict for the verse.

    `voice`: name of the intended artist. Any mention of a different celebrity
    in the output is counted as a name leak.
    """
    bar_list = [b.strip() for b in bars if b and b.strip()]
    n = len(bar_list)
    if n == 0:
        return {
            "end_rhyme_hit_rate": 0.0, "multisyllable_rhyme": 0.0,
            "inner_rhyme_mean": 0.0, "syl_variance": 0.0, "syl_mean": 0.0,
            "commas_per_bar": 0.0, "bar_count": 0,
            "profanity_rate": 0.0, "name_leak": 0,
        }
    cmu = _cmu()
    # end rhymes — couplet pairs (0,1), (2,3), ...
    ends = [_end_word(b) for b in bar_list]
    pairs = [(ends[i], ends[i + 1]) for i in range(0, n - 1, 2)]
    hits = sum(1 for a, b in pairs if _phonetic_rhyme(a, b, cmu))
    multi = sum(1 for a, b in pairs if _multisyl_match(a, b, cmu))
    end_rate = hits / len(pairs) if pairs else 0.0
    multi_rate = multi / len(pairs) if pairs else 0.0
    # inner rhymes
    inner_counts = []
    for b in bar_list:
        try:
            res = audit_bar_structure(b, cmu=cmu)
            inner_counts.append(res.get("inner_rhyme_count", 0))
        except Exception:
            inner_counts.append(0)
    inner_mean = statistics.mean(inner_counts) if inner_counts else 0.0
    # syllables
    syls = [_bar_syllables(b, cmu) for b in bar_list]
    syl_mean = statistics.mean(syls)
    syl_var = statistics.pstdev(syls) if n > 1 else 0.0
    # commas
    commas = statistics.mean([_bar_commas(b) for b in bar_list])
    # profanity
    prof_hits = sum(1 for b in bar_list if any(w in b.lower() for w in _PROFANE))
    prof_rate = prof_hits / n
    # name leaks
    voice_norm = (voice or "").lower().strip()
    text_full = " \n ".join(bar_list).lower()
    name_leaks = 0
    for name in _CELEBRITY_NAMES:
        if name == voice_norm:
            continue
        # word-boundary match
        if re.search(rf"\b{re.escape(name)}\b", text_full):
            name_leaks += 1
    return {
        "end_rhyme_hit_rate": round(end_rate, 4),
        "multisyllable_rhyme": round(multi_rate, 4),
        "inner_rhyme_mean": round(inner_mean, 4),
        "syl_variance": round(syl_var, 4),
        "syl_mean": round(syl_mean, 4),
        "commas_per_bar": round(commas, 4),
        "bar_count": n,
        "profanity_rate": round(prof_rate, 4),
        "name_leak": name_leaks,
    }


FEATURE_KEYS = (
    "end_rhyme_hit_rate",
    "multisyllable_rhyme",
    "inner_rhyme_mean",
    "syl_variance",
    "syl_mean",
    "commas_per_bar",
    "profanity_rate",
    "name_leak",
)


def vector(features: dict) -> list[float]:
    return [float(features.get(k, 0.0)) for k in FEATURE_KEYS]
