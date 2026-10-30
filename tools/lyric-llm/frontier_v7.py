#!/usr/bin/env python3
"""Frontier V7 — line-by-line sequential grader generation.

Each bar is written, graded against the v7_spec targets, and failing bars
get a single targeted rewrite before the next bar is written. Chips are a
secondary ranking reward, never a hard requirement. Novelty gate stays
hard (reuse V5's near-dup check).

Target → implementation table

| target # | spec rule | implementation | enforcement |
| --- | --- | --- | --- |
| 1 | end-rhyme tiers (vowel match pass; exact preferred at bars 2 and 4) | `_grade_rhyme` + `_strong_bar_bonus` | HARD gate on couplet vowel; SOFT bonus for exact at strong bars |
| 2 | multisyllable internal rhyme (~30% on 2+syl-end lines) | `_score_multisyl` | SOFT bonus |
| 3 | inner rhyme per line (mean 1.0) | `_score_inner_rhyme` | SOFT bonus / prompt guidance |
| 4 | comma mix (44/41/11/4 for 0/1/2/3+) | `_score_commas` + prompt line | SOFT; a missing comma never fails |
| 5 | syllables per bar (10–14 default; density <2%) | `_grade_syllables` | HARD gate on 8..17; SOFT density penalty |
| 6 | carry rate | NOT implemented | BLOCKED — see `blocked_targets`; carry detector precision was 5.6% |
| 7 | ad-libs don't own end word | `_grade_filler_end` + `FILLER_END_WORDS` | HARD gate |
| 8 | first-person voice (62.67%) | `_score_pov` | SOFT verse-level |
| 9 | subject-driven mood (<5% mood words) | `_score_mood` | SOFT verse-level |
| 10 | subtopic mix (women/jewelry/cars/…) | `_score_chip_hit` | SOFT per-bar bonus if a planned chip lands |
| 11 | no vault copying | `_hard_check_bars` (reused from V5) | HARD gate (novelty + couplet rhyme) |

Caveat flags surfaced in `V7Result.blocked_targets`:
- `carry_rate` — grammar-only detector precision was 5.6%; needs a dep parser.
- `triplet_pocket` — text-only triplet detection can't distinguish Gunna from
  Migos (both ~50%); proxy marked ESTIMATE but kept in the soft score.
- `tempo_correlation` — GetSongBPM key not set; AcousticBrainz partial.
- `semantic_hooks` — fuzzy hook detector only catches ≥3 repeats at ≥0.8.

Not called from any Swift. Not wired into run_taste30. Does NOT edit V5.
"""
from __future__ import annotations

import json
import random
import re
import statistics
import sys
import uuid
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable, Iterable, Optional

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

# narrow imports from V5 — do NOT edit V5
from frontier_v5 import (  # type: ignore
    _cmu, _phonetic_rhyme, _cmu_rime, _word, _bar_tokens,
    chip_matches_bar, _hard_check_bars, shape_v5, Shape,
    FILLER_END_WORDS, COMMA_MIX,
)
from lyriclib import end_rime, load_cmudict  # type: ignore
from inner_rhyme_check import count_bar_syllables, audit_bar_structure  # type: ignore


# ---------- lexicons from v7_spec rules 8 / 9 / 10 ----------
_POV_I = {"i", "i'm", "im", "ima", "i'ma", "me", "my", "mine", "myself",
          "we", "us", "our"}
_POV_YOU = {"you", "you're", "your", "yours", "yourself", "u", "ur"}

MOOD_WORDS = {
    "flex": {"racks", "bands", "mil", "million", "stacks", "iced", "diamond",
             "chain", "designer", "patek", "rolex", "cuban", "flooded"},
    "pain": {"pain", "tears", "cry", "miss", "loss", "lost", "regret", "hurt",
             "bleed", "lonely", "alone", "funeral", "grave"},
    "love": {"love", "babe", "baby", "shawty", "wifey", "kiss", "forever",
             "soul", "heart"},
    "threat": {"gun", "glock", "stick", "smoke", "pop", "shoot", "slide",
               "pistol", "blick", "ar", "clip", "trigger", "chopper"},
}

SUBTOPIC_LEX = {
    "women":   {"shawty", "wifey", "babe", "baby", "girl", "woman", "wife", "boo", "ex"},
    "loyalty": {"brother", "bro", "gang", "crew", "homie", "trust", "loyal", "family", "fam"},
    "jewelry": {"chain", "iced", "diamond", "rolex", "patek", "ap", "watch",
                "cuban", "pendant", "bezel", "vvs"},
    "cars":    {"lambo", "ferrari", "bentley", "wraith", "range", "porsche", "benz",
                "coupe", "maserati", "corvette", "scat"},
    "brands":  {"gucci", "fendi", "chanel", "louis", "prada", "versace",
                "balenciaga", "dior", "ysl", "hermes", "cartier", "amiri"},
    "come_up": {"struggle", "hustle", "grind", "started", "trenches", "block",
                "corner", "trap", "flip"},
    "drugs":   {"wock", "lean", "perc", "percs", "molly", "xan", "xans",
                "percocet", "weed", "zaza", "runtz"},
}

AD_LIB_TOKENS = {"yeah", "uh", "woo", "huh", "what", "skrrt", "skrr", "ayy",
                 "ooh", "woah", "oh", "nah", "hey", "mm", "yuh", "yah",
                 "aye", "ay", "ye"}

INCOMPLETE_END_TOKENS = {
    "for", "to", "of", "with", "in", "at", "by", "on", "from", "into",
    "about", "over", "under", "through", "upon", "within",
}

#
# Cliché list — curated against the vault (1,708,472 bars).
# Threshold: a phrase counts as a cliché only if it appears in <0.01% of
# vault lines (<170 lines). Rap slang that appears often in the vault
# (`on god` 2172 / 0.13%, `no cap` 962 / 0.056%, `straight up` 1572 /
# 0.092%, `pop a perc` 178 / 0.0104%, etc.) is DROPPED from the list.
# Each entry's vault count is in CLICHE_VAULT_COUNTS below.
#
CLICHE_PHRASES = frozenset({
    # generic motivational / rock-the-sky filler (user-supplied, verified <0.01%)
    "chasing dreams", "in the shadows", "grinding hard", "hustle hard",
    "never fading", "rise above", "against all odds",
    "reach for the stars", "light in the dark",
    # more motivational filler verified <0.01%
    "shoot for the stars", "walking on sunshine", "break the chains",
    "turn the page", "feel the burn", "shining bright", "burning bright",
    "walk the line", "stand tall",
    # bag/money filler still <0.01% in the vault
    "chasing the bag", "secured the bag",
    # motivational phrases harvested from the first smoke run and measured
    # against the vault (all <0.01%)
    "every corner turned", "chasing green", "stacking blessings",
    "stacking wins", "every move's cash", "respect's my claim",
    "doubted me but now", "visions into gold", "shadows daily",
    "burdens but i know", "echoes of sorrow", "turning it around",
    "where the realness", "where the whispers", "watch for the lead",
    "where the shadows creep", "silence can blind", "built like a mountain",
    "building dreams", "lavish on me", "watching what's behind",
    "every step i take", "floating in air", "sun is shining",
    "shining like the sun", "counting blessings", "when the smoke clears",
    "lavish life", "in it to win it", "shine like a star",
    "stand my ground", "flexin' hard", "stacks on deck",
    "living lavish", "stay on top", "sky is the limit", "level up",
})

CLICHE_VAULT_COUNTS: dict[str, int] = {
    # original 20 (user-supplied + bag/money filler)
    "never fading": 0, "walking on sunshine": 0, "burning bright": 0,
    "feel the burn": 1, "break the chains": 3, "light in the dark": 4,
    "secured the bag": 6, "walk the line": 7, "against all odds": 8,
    "chasing the bag": 9, "grinding hard": 11, "in the shadows": 16,
    "reach for the stars": 19, "shining bright": 19, "turn the page": 22,
    "chasing dreams": 23, "rise above": 25, "shoot for the stars": 32,
    "hustle hard": 105, "stand tall": 121,
    # harvested from the first smoke run (all measured <171 lines, 0.01%)
    "every corner turned": 0, "chasing green": 0, "stacking blessings": 0,
    "stacking wins": 0, "every move's cash": 0, "respect's my claim": 0,
    "doubted me but now": 0, "visions into gold": 0, "shadows daily": 0,
    "burdens but i know": 0, "echoes of sorrow": 0, "turning it around": 0,
    "where the realness": 0, "where the whispers": 0, "watch for the lead": 0,
    "where the shadows creep": 0, "silence can blind": 0, "built like a mountain": 0,
    "building dreams": 0, "lavish on me": 0,
    "watching what's behind": 1, "every step i take": 1,
    "floating in air": 2, "sun is shining": 2,
    "shining like the sun": 3, "counting blessings": 3,
    "when the smoke clears": 5, "lavish life": 7,
    "in it to win it": 9, "shine like a star": 10,
    "stand my ground": 13, "flexin' hard": 15,
    "stacks on deck": 29, "living lavish": 37, "stay on top": 41,
    "sky is the limit": 44, "level up": 79,
}

# Per-voice syllable medians measured from the vault (non-triplet, triplet).
# Non-triplet median is V7's default per-bar target; triplet median is
# recorded for future use when the plan predicts a triplet bar.
VOICE_SYL_MEDIAN: dict[str, dict[str, int]] = {
    "gunna":      {"non_triplet": 9,  "triplet": 12, "overall": 11},
    "drake":      {"non_triplet": 8,  "triplet": 12, "overall": 11},
    "lil baby":   {"non_triplet": 9,  "triplet": 13, "overall": 11},
    "lil wayne":  {"non_triplet": 9,  "triplet": 12, "overall": 11},
    "nocap":      {"non_triplet": 10, "triplet": 14, "overall": 13},
    "young thug": {"non_triplet": 8,  "triplet": 12, "overall": 10},
    "chief keef": {"non_triplet": 8,  "triplet": 12, "overall": 11},
}
DEFAULT_SYL_MEDIAN = {"non_triplet": 9, "triplet": 12, "overall": 11}


def _voice_syl_target(voice: str, triplet: bool = False) -> int:
    """Return the vault-median syllable target for this voice. Honors V6
    twins (Chief Keef → Lil Wayne, Future → Gunna) via
    `catalog_retriever.resolve_catalog_artist` when the voice itself isn't
    in VOICE_SYL_MEDIAN."""
    key = (voice or "").strip().lower()
    med = VOICE_SYL_MEDIAN.get(key)
    if not med:
        try:
            from catalog_retriever import resolve_catalog_artist  # type: ignore
            key = resolve_catalog_artist(voice).lower()
            med = VOICE_SYL_MEDIAN.get(key)
        except Exception:
            pass
    med = med or DEFAULT_SYL_MEDIAN
    return med["triplet"] if triplet else med["non_triplet"]

_W = re.compile(r"[A-Za-z']+")

PLAN_MODEL = "V5_PLAN_MODEL"  # read at generation time
EDIT_MODEL = "V5_EDIT_MODEL"


# ---------- dataclasses ----------
@dataclass(frozen=True)
class BarTarget:
    index: int
    end_word: str
    rhyme_vowel: str
    syl_target: int
    syl_lo: int
    syl_hi: int
    strong: bool                 # bars 1 and 3 (0-indexed) of each couplet
    chip_targets: tuple[str, ...] = ()
    mood_tolerance: float = 0.05


@dataclass
class BarGrade:
    bar: str
    target: BarTarget
    ok: bool
    violations: list[str] = field(default_factory=list)
    soft_scores: dict[str, float] = field(default_factory=dict)
    notes: list[str] = field(default_factory=list)


@dataclass
class V7Result:
    bars: list[str]
    grades: list[BarGrade]
    verse_score: float
    verse_components: dict[str, float]
    verified: bool
    blocked_targets: list[dict[str, str]]
    generation_id: str
    plan: dict[str, Any] = field(default_factory=dict)
    violations_rolled_up: list[str] = field(default_factory=list)


# ---------- lightweight CMU helpers (correct usage) ----------
def _phones(word: str) -> list[str]:
    cmu = _cmu()
    w = re.sub(r"[^A-Za-z']", "", (word or "").lower())
    return list(cmu.get(w) or [])


def _syl(word: str) -> int:
    p = _phones(word)
    if p:
        return sum(1 for ph in p if any(c.isdigit() for c in ph))
    v = "aeiouy"
    c = 0; pv = False
    for ch in word.lower():
        iv = ch in v
        if iv and not pv:
            c += 1
        pv = iv
    return max(c, 1)


def _bar_syls(bar: str) -> int:
    try:
        return count_bar_syllables(bar, _cmu())
    except Exception:
        return sum(_syl(t) for t in _W.findall(bar or ""))


def _end_word(line: str) -> str:
    s = re.sub(r"\([^)]*\)|\[[^\]]*\]", "", line or "")
    toks = _W.findall(s)
    return toks[-1].lower() if toks else ""


def _anchor_vowel(line: str) -> str:
    toks = _W.findall(line or "")
    all_phones: list[str] = []
    for t in toks:
        all_phones.extend(_phones(t))
    for p in reversed(all_phones):
        if re.match(r"[AEIOU]", p) and p.endswith("1"):
            return re.sub(r"\d", "", p)
    for p in reversed(all_phones):
        if re.match(r"[AEIOU]", p):
            return re.sub(r"\d", "", p)
    return ""


# ---------- Target 1 — end-rhyme tier ----------
def _grade_rhyme(bar: str, target: BarTarget, prior_bars: list[str]) -> dict:
    """HARD: bar's end word must be in the planned rhyme FAMILY (same CMU
    rime as `target.end_word`), AND must share anchor vowel with the
    couplet partner.
    SOFT: exact-anchor bonus at strong bars (exact rime equality).
    """
    v = _anchor_vowel(bar)
    bar_end = _word(_end_word(bar))
    target_end = _word(target.end_word)
    reasons: list[str] = []
    bar_rime = _cmu_rime(bar_end)
    target_rime = _cmu_rime(target_end)
    # same word is always a pass
    family_ok = (bar_end == target_end)
    if not family_ok and bar_rime and target_rime and bar_rime == target_rime:
        family_ok = True
    if not family_ok:
        reasons.append(
            f"bar end {_end_word(bar)!r} not in rhyme family of planned "
            f"{target.end_word!r}"
        )
    # couplet partner check — bar i rhymes with bar i-1 if i is odd
    i = target.index
    if i >= 1 and i % 2 == 1 and prior_bars:
        partner_vowel = _anchor_vowel(prior_bars[-1])
        if partner_vowel and v and partner_vowel != v:
            reasons.append(f"anchor vowel {v!r} != couplet partner {partner_vowel!r}")
    # strong-bar exact-anchor bonus (rime equality on prior-bar end word)
    exact_bonus = 0.0
    if target.strong and prior_bars and i >= 1:
        a = _cmu_rime(_word(_end_word(prior_bars[-1])))
        if a and bar_rime and a == bar_rime:
            exact_bonus = 1.0
    return {"ok": not reasons, "reasons": reasons,
            "soft_exact": exact_bonus, "anchor_vowel": v}


# ---------- Target 2 — multisyllable internal rhyme ----------
def _score_multisyl(bar: str) -> float:
    toks = _W.findall(bar or "")
    if not toks:
        return 0.0
    end = toks[-1]
    if _syl(end) < 2:
        return 0.0
    end_rime = _cmu_rime(end.lower())
    if not end_rime:
        return 0.0
    for t in toks[:-1]:
        if _syl(t) >= 2 and _cmu_rime(t.lower()) == end_rime:
            return 1.0
    return 0.0


# ---------- Target 3 — inner rhyme ----------
def _score_inner_rhyme(bar: str) -> float:
    toks = _W.findall(bar or "")
    if len(toks) < 3:
        return 0.0
    rimes = [_cmu_rime(t.lower()) for t in toks]
    seen: dict[tuple, int] = {}
    hits = 0
    for r in rimes:
        if not r:
            continue
        seen[r] = seen.get(r, 0) + 1
        if seen[r] == 2:
            hits += 1
    return float(hits)


# ---------- Target 4 — commas ----------
def _comma_target_bucket(syl_target: int) -> int:
    """Vault mix: 44/41/11/4. Pick 1 as the modal default when the bar is
    long enough; 0 for short bars."""
    return 1 if syl_target >= 10 else 0


def _score_commas(bar: str, target: BarTarget) -> float:
    n = (bar or "").count(",")
    want = _comma_target_bucket(target.syl_target)
    if n == want:
        return 1.0
    if n == want + 1 or (n == want - 1 and want > 0):
        return 0.5
    if n > 3:
        return 0.0
    return 0.25


# ---------- Target 5 — syllables ----------
def _grade_syllables(bar: str, target: BarTarget) -> dict:
    n = _bar_syls(bar)
    reasons: list[str] = []
    if n < target.syl_lo or n > target.syl_hi:
        reasons.append(f"syllables {n} outside [{target.syl_lo}, {target.syl_hi}]")
    # density soft penalty: 16+ syllables with 3+ commas
    density_hit = (n >= 16 and (bar or "").count(",") >= 3)
    return {"ok": not reasons, "reasons": reasons, "syllables": n,
            "density_hit": density_hit}


# ---------- Target 7 — filler end words ----------
def _grade_filler_end(bar: str) -> dict:
    ew = _word(_end_word(bar))
    if ew in FILLER_END_WORDS or ew in AD_LIB_TOKENS:
        return {"ok": False, "reasons": [f"filler/adlib end word {ew!r}"]}
    return {"ok": True, "reasons": []}


# ---------- Incomplete bar + cliché gates ----------
def _grade_incomplete(bar: str) -> dict:
    """Bar must not end on a preposition / dangling particle."""
    ew = _word(_end_word(bar))
    if ew in INCOMPLETE_END_TOKENS:
        return {"ok": False, "reasons": [f"bar ends incomplete on {ew!r}"]}
    return {"ok": True, "reasons": []}


def _grade_cliches(bar: str) -> dict:
    low = (bar or "").lower()
    hits = [p for p in CLICHE_PHRASES if p in low]
    if hits:
        return {"ok": False,
                "reasons": [f"cliché phrase(s): {hits}"]}
    return {"ok": True, "reasons": []}


# ---------- Per-bar novelty gate ----------
def _grade_bar_novelty(bar: str, chip_names: list[str],
                       shown_examples: list[str] | None = None) -> dict:
    try:
        from taste.novelty import bar_novelty  # type: ignore
    except Exception:
        return {"ok": True, "reasons": []}
    r = bar_novelty(bar, chip_words=chip_names,
                    shown_examples=shown_examples or [])
    if r.get("is_near_dup"):
        return {"ok": False,
                "reasons": [f"bar is near-dup of vault: {r.get('reasons')}"]}
    return {"ok": True, "reasons": []}


# ---------- Target 8 — POV ----------
def _score_pov(bars: list[str]) -> float:
    if not bars:
        return 0.0
    hits = 0
    for b in bars:
        toks = [t.lower() for t in _W.findall(b or "")]
        if any(t in _POV_I for t in toks):
            hits += 1
    return hits / len(bars)


# ---------- Target 9 — mood words ----------
def _score_mood(bars: list[str]) -> dict:
    counts = {k: 0 for k in MOOD_WORDS}
    for b in bars:
        toks = [t.lower() for t in _W.findall(b or "")]
        for mood, lex in MOOD_WORDS.items():
            if any(t in lex for t in toks):
                counts[mood] += 1
                break
    total = len(bars) or 1
    rates = {k: v / total for k, v in counts.items()}
    overall = sum(rates.values())
    return {"rates": rates, "overall_mood_word_rate": overall}


# ---------- Target 10 — subtopic / chip hit ----------
def _score_chip_hit(bar: str, chips: Iterable[str]) -> float:
    for c in chips:
        if c and chip_matches_bar(c, bar):
            return 1.0
    return 0.0


def _detect_subtopic(bar: str) -> str | None:
    toks = {t.lower() for t in _W.findall(bar or "")}
    for name, lex in SUBTOPIC_LEX.items():
        if toks & lex:
            return name
    return None


# ---------- Repeated-end-word in 4-bar block ----------
def _repeated_end_in_block(bar: str, target: BarTarget, prior_bars: list[str]) -> list[str]:
    block_start = (target.index // 4) * 4
    block_bars = prior_bars[block_start:target.index]
    end = _word(_end_word(bar))
    for b in block_bars:
        if _word(_end_word(b)) == end and end:
            return [f"end word {end!r} repeats within 4-bar block"]
    return []


# ---------- Triplet pocket proxy (ESTIMATE) ----------
def _triplet_proxy(bar: str) -> float:
    toks = _W.findall(bar or "")
    if len(toks) < 8:
        return 0.0
    runs = 0
    for i in range(len(toks) - 2):
        if all(_syl(t) == 1 for t in toks[i:i + 3]):
            runs += 1
    return 1.0 if runs >= 3 else 0.0


# ---------- Grader ----------
def grade_bar(bar: str, target: BarTarget, prior_bars: list[str],
              chips: Iterable[str] = (), voice: str = "Gunna",
              check_novelty: bool = True) -> BarGrade:
    """Sequential grader. Hard gates (any one fails the bar):
      - rhyme vowel match with couplet partner (target 1)
      - syllables in range (target 5)
      - filler / ad-lib end word (target 7)
      - bar ends on an incomplete prep/particle
      - cliché phrase present
      - end word repeats within the current 4-bar block
      - bar is near-duplicate of a vault line (per-bar novelty, target 11a)
    Verse-level novelty gate still runs after the loop (target 11b).
    """
    violations: list[str] = []
    notes: list[str] = []
    r = _grade_rhyme(bar, target, prior_bars)
    if not r["ok"]:
        violations.extend(r["reasons"])
    s = _grade_syllables(bar, target)
    if not s["ok"]:
        violations.extend(s["reasons"])
    f = _grade_filler_end(bar)
    if not f["ok"]:
        violations.extend(f["reasons"])
    inc = _grade_incomplete(bar)
    if not inc["ok"]:
        violations.extend(inc["reasons"])
    cliche = _grade_cliches(bar)
    if not cliche["ok"]:
        violations.extend(cliche["reasons"])
    violations.extend(_repeated_end_in_block(bar, target, prior_bars))
    chip_list = list(chips)
    if check_novelty and bar:
        nv = _grade_bar_novelty(bar, chip_list)
        if not nv["ok"]:
            violations.extend(nv["reasons"])
    soft = {
        "multisyl": _score_multisyl(bar),
        "inner_rhyme": _score_inner_rhyme(bar),
        "commas": _score_commas(bar, target),
        "density_hit": float(s.get("density_hit") or 0),
        "chip_hit": _score_chip_hit(bar, chip_list),
        "triplet_proxy": _triplet_proxy(bar),
        "rhyme_exact_bonus": r["soft_exact"],
        "subtopic": _detect_subtopic(bar) or "",
    }
    return BarGrade(bar=bar, target=target, ok=not violations,
                    violations=violations, soft_scores=soft, notes=notes)


def _four_bar_vowel_share_rate(bars: list[str]) -> float:
    """Fraction of 4-bar windows where at least 2 bars share an anchor
    vowel. Spec target ≈ 91% on Gunna's clean subset."""
    vowels = [_anchor_vowel(b) for b in bars]
    windows = max(len(vowels) - 3, 0)
    if windows == 0:
        if len(vowels) < 2:
            return 0.0
        c = {}
        for v in vowels:
            if v:
                c[v] = c.get(v, 0) + 1
        return 1.0 if any(n >= 2 for n in c.values()) else 0.0
    hit = 0
    for i in range(windows):
        blk = [v for v in vowels[i:i + 4] if v]
        c = {}
        for v in blk:
            c[v] = c.get(v, 0) + 1
        if any(n >= 2 for n in c.values()):
            hit += 1
    return hit / windows


# ---------- Verse-level scoring ----------
def score_verse(bars: list[str], grades: list[BarGrade], voice: str) -> dict:
    pov_rate = _score_pov(bars)
    mood = _score_mood(bars)
    hits = set()
    for g in grades:
        s = g.soft_scores.get("subtopic", "")
        if s:
            hits.add(s)
    multisyl_rate = statistics.mean(g.soft_scores["multisyl"] for g in grades) if grades else 0.0
    inner_mean = statistics.mean(g.soft_scores["inner_rhyme"] for g in grades) if grades else 0.0
    comma_mean = statistics.mean(g.soft_scores["commas"] for g in grades) if grades else 0.0
    exact_bonus = sum(g.soft_scores["rhyme_exact_bonus"] for g in grades)
    chip_hits = sum(g.soft_scores["chip_hit"] for g in grades)
    density_hits = sum(g.soft_scores["density_hit"] for g in grades)
    vowel_share_rate = _four_bar_vowel_share_rate(bars)
    components = {
        "pov_rate": round(pov_rate, 4),
        "mood_word_rate": round(mood["overall_mood_word_rate"], 4),
        "mood_rates": {k: round(v, 4) for k, v in mood["rates"].items()},
        "subtopics_hit": sorted(hits),
        "multisyl_rate": round(multisyl_rate, 4),
        "inner_rhyme_mean": round(inner_mean, 4),
        "comma_fit_mean": round(comma_mean, 4),
        "exact_rhyme_bonus_total": round(exact_bonus, 2),
        "chip_hits_total": int(chip_hits),
        "density_hits_total": int(density_hits),
        "four_bar_vowel_share_rate": round(vowel_share_rate, 4),
    }
    score = (
        6.0 * (1.0 - min(1.0, density_hits / max(len(grades), 1)))
        + 4.0 * multisyl_rate
        + 2.0 * min(1.0, inner_mean / 2.0)
        + 3.0 * comma_mean
        + 2.0 * exact_bonus / max(len(grades) / 2.0, 1)
        + 2.0 * (1.0 if pov_rate >= 0.5 else pov_rate * 2)
        + 1.5 * (1.0 if 0 < len(hits) else 0.0)
        + 1.0 * (1.0 if mood["overall_mood_word_rate"] <= 0.05 else max(0, 0.1 - mood["overall_mood_word_rate"]) * 10)
        + 2.0 * vowel_share_rate  # SOFT bonus: spec rule 1 extension (4-bar vowel sharing ~91%)
    )
    return {"score": round(score, 3), "components": components}


BLOCKED_TARGETS: list[dict[str, str]] = [
    {"target": "6_carry_rate",
     "reason": "grammar-only detector precision 5.6% on 30-pair hand-check; "
               "needs dep parser or hand-marked data (carry_v2_handcheck.md)"},
    {"target": "caveat_triplet_pocket",
     "reason": "text-only runs-of-3-mono proxy; Gunna 53% ≈ Migos 48%, so "
               "the detector cannot distinguish rhythmic triplet flow — "
               "kept as a soft bonus only, flagged ESTIMATE"},
    {"target": "caveat_semantic_hooks",
     "reason": "fuzzy hook detector (SequenceMatcher ≥0.8, ≥3 copies) catches "
               "0.96% of lines; needs Genius section tags for full capture"},
]


def _vault_endword_families(voice: str, min_syls: int = 1) -> list[tuple[tuple, list[str]]]:
    """Pull voice's end-word families from BarHitsCatalog.sqlite (read-only).
    Groups end_words by their CMU rime, ranks by frequency.

    Honors V6's twin table via `catalog_retriever.resolve_catalog_artist`
    (Chief Keef → Lil Wayne, Future → Gunna, 21 Savage → Lil Baby, etc.)
    so results compare 1:1 with V6 outputs.

    Returns [(rime_tuple, [top end_words in that family])] sorted desc by
    family total frequency. Empty rime words are skipped.
    """
    import sqlite3
    repo = HERE.parent.parent
    db = repo / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite"
    if not db.exists():
        return []
    try:
        from catalog_retriever import resolve_catalog_artist  # type: ignore
        catalog_voice = resolve_catalog_artist(voice)
    except Exception:
        catalog_voice = (voice or "").lower()
    try:
        conn = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
        rows = conn.execute(
            "SELECT end_word, COUNT(*) FROM bars WHERE lower(artist) = lower(?) "
            "AND end_word IS NOT NULL AND length(end_word) > 0 "
            "GROUP BY end_word ORDER BY COUNT(*) DESC LIMIT 800",
            (catalog_voice,),
        ).fetchall()
        conn.close()
    except Exception:
        return []
    fams: dict[tuple, dict] = {}
    for word, cnt in rows:
        wl = _word(word)
        if not wl or wl in FILLER_END_WORDS or wl in AD_LIB_TOKENS:
            continue
        if _syl(wl) < min_syls:
            continue
        rime = _cmu_rime(wl)
        if not rime:
            continue
        bucket = fams.setdefault(rime, {"total": 0, "words": []})
        bucket["total"] += int(cnt)
        bucket["words"].append((wl, int(cnt)))
    ordered = sorted(fams.items(), key=lambda kv: -kv[1]["total"])
    return [(rime, [w for w, _ in sorted(b["words"], key=lambda x: -x[1])[:4]])
            for rime, b in ordered if len(b["words"]) >= 2]


# ---------- Plan ----------
def plan_v7(shape: Shape, voice: str, topic: str, end_words: list[str] | None = None,
            chip_hints: list[dict] | None = None, seed: int = 20261030,
            used_families: set[tuple] | None = None,
            family_runs: int = 10) -> dict:
    """Build a per-bar plan.

    When `end_words` is supplied, use them. Otherwise:
    1. Pull voice's vault end-rhyme families via `_vault_endword_families`,
       ranked by frequency.
    2. Fall back to the voice's twin ("Lil Baby" ↔ "Gunna", "Chief Keef" ↔
       "Lil Durk", "Young Thug" ↔ "Gunna") if the voice has no vault data.
    3. Each family may be used at most once per `family_runs` (default 10)
       — caller passes a shared `used_families` set, we add to it per plan.
    4. If chip_hints are present, prefer families that match a chip's
       end rime.
    """
    bars = shape.bar_count
    rng = random.Random(seed)
    chips_list = list(chip_hints or [])
    chip_names = [c.get("chip", "") for c in chips_list if c.get("chip")]
    uf = used_families if used_families is not None else set()

    pairs_needed = bars // 2
    pairs: list[tuple[str, str]] = []
    if not end_words:
        # V6 twin table (catalog_retriever.VOICE_CATALOG_TWINS) is applied
        # inside _vault_endword_families via resolve_catalog_artist, so a
        # local twin dict here is redundant. If the catalog returns zero
        # rows for the resolved artist, fall through to the heuristic pool.
        fams = _vault_endword_families(voice)
        # also prefer families whose rime matches a chip's end rime
        chip_rimes = {tuple(c.get("end_rime") or ()) for c in chips_list
                      if c.get("end_rime")}
        def _priority(f):
            rime, _words = f
            if rime in chip_rimes:
                return 0  # highest priority
            if rime in uf:
                return 2  # avoid re-use
            return 1
        fams_sorted = sorted(fams, key=_priority)
        # pull `pairs_needed` distinct families, filling in order
        chosen = []
        for rime, words in fams_sorted:
            if rime in uf:
                continue
            if len(words) < 2:
                continue
            chosen.append((rime, words))
            uf.add(rime)
            if len(chosen) >= pairs_needed:
                break
        if len(chosen) < pairs_needed:
            # if cap starved us, dip back into already-used families
            for rime, words in fams_sorted:
                if any(r == rime for r, _ in chosen):
                    continue
                if len(words) >= 2:
                    chosen.append((rime, words))
                if len(chosen) >= pairs_needed:
                    break
        if not chosen:
            # last-ditch literal fallback (only when vault returned nothing)
            chosen = [((), ["crown", "down"]), ((), ["money", "honey"]),
                      ((), ["sky", "high"]), ((), ["wave", "pave"])][:pairs_needed]
        for _rime, words in chosen:
            if len(words) >= 2:
                pairs.append((words[0], words[1]))
            else:
                pairs.append((words[0], words[0]))
        end_words = []
        for a, b in pairs:
            end_words.extend([a, b])
        while len(end_words) < bars:
            end_words.append(end_words[-1])
    targets: list[BarTarget] = []
    for i in range(bars):
        ew = end_words[i]
        rhyme_vowel = ""
        rime = _cmu_rime(_word(ew.split()[-1]))
        if rime:
            for ph in rime:
                if re.match(r"[AEIOU]", ph):
                    rhyme_vowel = re.sub(r"\d", "", ph)
                    break
        # Vault-median syllable target per voice (non-triplet by default).
        # User rule: "set the per-bar syllable target from the vault; keep
        # range ±2." No longer uses shape.syl_budget which was BPM-derived.
        syl_target = _voice_syl_target(voice, triplet=False)
        strong = (i % 2 == 1)
        targets.append(BarTarget(
            index=i, end_word=ew, rhyme_vowel=rhyme_vowel,
            syl_target=syl_target, syl_lo=max(6, syl_target - 2),
            syl_hi=syl_target + 2, strong=strong,
            chip_targets=tuple(chip_names[:4]),
        ))
    return {"targets": targets, "voice": voice, "topic": topic,
            "shape": shape, "end_words": end_words,
            "chip_names": chip_names}


# ---------- LLM glue ----------
def _default_call_fn(system: str, user: str, model: str = "gpt-4o-mini") -> str:
    """Default LLM call via llm_client; tests inject a stub via call_fn kwarg.
    Never prints or logs API keys."""
    import os
    try:
        from llm_client import chat
    except Exception as exc:
        raise RuntimeError(f"llm_client unavailable: {exc}") from exc
    return chat(model=model, system=system, user=user)


def _write_bar_prompt(target: BarTarget, voice: str, topic: str,
                      prior_bars: list[str], chip_names: list[str]) -> str:
    """Prompt the model to write ONE bar matching the target. No scaffold."""
    comma_hint = f"{_comma_target_bucket(target.syl_target)} comma(s)"
    strong = "strong-bar (land exact end rime)" if target.strong else "setup-bar (vowel match ok)"
    chip_line = (f"  Chip targets (use 1–2 as nouns): {', '.join(chip_names[:5])}"
                 if chip_names else "  Chip targets: none this bar")
    prior = "\n".join(f"  {i + 1}. {b}" for i, b in enumerate(prior_bars)) or "  (none yet)"
    return (f"Voice: {voice}. Topic: {topic}.\n"
            f"Writing bar {target.index + 1}.\n"
            f"End word must be exactly: {target.end_word!r} ({strong}).\n"
            f"Target syllables {target.syl_target} (range {target.syl_lo}..{target.syl_hi}). "
            f"{comma_hint} is modal; a missing comma does NOT fail.\n"
            f"Rhyme anchor vowel: {target.rhyme_vowel!r}.\n"
            f"Do NOT end on filler ({sorted(FILLER_END_WORDS)[:6]}, ...), ad-libs, or a word already used as an end word in this 4-bar block.\n"
            f"Do NOT copy any catalog line; write a new bar.\n"
            f"{chip_line}\n"
            f"Prior bars:\n{prior}\n"
            f"Return JSON: {{\"bar\": \"...\"}}")


def _rewrite_bar_prompt(bar: str, target: BarTarget, violations: list[str], voice: str,
                        topic: str, prior_bars: list[str]) -> str:
    return (f"Rewrite one bar for voice {voice}. Topic: {topic}.\n"
            f"Original bar: {bar!r}\n"
            f"Violations: {violations}\n"
            f"Keep end word {target.end_word!r}. "
            f"Fix the listed violations only — do not change the bar's picture.\n"
            f"Prior bars:\n" + ("\n".join(f"  {b}" for b in prior_bars) or "  (none)") +
            f"\nReturn JSON: {{\"bar\": \"...\"}}")


def _parse_bar_json(text: str) -> str:
    text = (text or "").strip()
    try:
        data = json.loads(text)
    except Exception:
        m = re.search(r"\{.*\}", text, re.DOTALL)
        if not m:
            return ""
        try:
            data = json.loads(m.group(0))
        except Exception:
            return ""
    bar = data.get("bar") if isinstance(data, dict) else ""
    return (bar or "").strip()


# ---------- Public entry ----------
def generate_v7(prompt: dict,
                voice: str = "Gunna",
                topic: str = "",
                candidates: int = 1,
                retries_per_bar: int = 1,
                call_fn: Optional[Callable[[str, str], str]] = None,
                chip_hints: list[dict] | None = None,
                seed: int = 20261030,
                used_families: set[tuple] | None = None) -> V7Result:
    """Sequential, line-by-line writer. Each bar is written, graded, and
    gets one rewrite if any hard gate fails. After the verse is complete,
    the novelty gate runs on the whole verse; failures surface in
    `violations_rolled_up` and `verified = False`.
    """
    shape = shape_v5(prompt)
    plan = plan_v7(shape, voice, topic, chip_hints=chip_hints, seed=seed,
                   used_families=used_families)
    targets: list[BarTarget] = plan["targets"]
    chip_names = plan["chip_names"]

    cf = call_fn or _default_call_fn

    def _write(target: BarTarget, prior: list[str]) -> str:
        user = _write_bar_prompt(target, voice, topic, prior, chip_names)
        text = cf(_v7_system(voice), user)
        return _parse_bar_json(text)

    def _rewrite(bar: str, target: BarTarget, violations: list[str], prior: list[str]) -> str:
        user = _rewrite_bar_prompt(bar, target, violations, voice, topic, prior)
        text = cf(_v7_system(voice), user)
        return _parse_bar_json(text) or bar

    bars: list[str] = []
    grades: list[BarGrade] = []
    for target in targets:
        bar = _write(target, bars)
        g = grade_bar(bar, target, bars, chips=chip_names, voice=voice)
        attempts = 0
        while not g.ok and attempts < retries_per_bar:
            bar = _rewrite(bar, target, g.violations, bars)
            g = grade_bar(bar, target, bars, chips=chip_names, voice=voice)
            attempts += 1
        bars.append(bar)
        grades.append(g)

    # Verse-level novelty + couplet rhyme gate (reuse V5)
    hard = _hard_check_bars(bars, voice, chip_words=chip_names, novelty_on=True)
    rolled = []
    for g in grades:
        rolled.extend([f"bar{g.target.index + 1}: {v}" for v in g.violations])
    if not hard["ok"]:
        rolled.extend([f"verse: {r}" for r in hard.get("reasons", [])])

    v = score_verse(bars, grades, voice=voice)
    return V7Result(
        bars=bars, grades=grades,
        verse_score=v["score"], verse_components=v["components"],
        verified=hard["ok"] and all(g.ok for g in grades),
        blocked_targets=list(BLOCKED_TARGETS),
        generation_id=f"v7-{uuid.uuid4().hex[:12]}",
        plan={"voice": voice, "topic": topic, "end_words": plan["end_words"],
              "chip_names": chip_names},
        violations_rolled_up=rolled,
    )


def _v7_system(voice: str) -> str:
    return (
        f"You write a single rap bar for voice {voice}. "
        "Target 10-14 syllables. Preserve the planned end word. "
        "Vowel match with the couplet partner is enough to rhyme; "
        "exact rhymes land at strong bars (even-indexed within a couplet). "
        "Never end on filler words or ad-libs. "
        "Never copy any catalog line verbatim. "
        "Reply with JSON only: {\"bar\": \"...\"}."
    )
