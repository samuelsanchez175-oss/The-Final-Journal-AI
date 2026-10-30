#!/usr/bin/env python3
"""Frontier v5 generation. Seven stages and one cache pre-gate.

The catalog line is the floor. The plan is the contract: later stages read it
and do not change it. Shape.syl_budget is the only syllable budget.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import random
import re
import sys
import time
import uuid
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Callable, Optional

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from catalog_retriever import (
    detect_inner_rhymes,
    get_end_word_history,
    record_used_end_words,
    retrieve_matching_catalog_lines,
    sample_end_words,
    token_levenshtein_distance,
)
from lyriclib import end_rime, estimate_syllables, load_cmudict, normalize, tempo_line_syllables, tokenize
from prompt_cache import (
    CACHE_DIR,
    compute_cache_key,
    eval_disables_cache,
    get_cached_verse,
    save_cached_verse,
)
from telemetry import check_punch_demoted
from v5_policy import DOUBLE_MEANING_ANY_VOICE

OUT = HERE / "out"
TELEMETRY_PATH = OUT / "v5_telemetry.jsonl"
PLAN_MODEL = os.environ.get("V5_PLAN_MODEL", "claude-opus-4-7")
EDIT_MODEL = os.environ.get("V5_EDIT_MODEL", "claude-opus-4-7")
_CMU_CACHE: dict[str, list[str]] | None = None


def _cmu() -> dict[str, list[str]]:
    global _CMU_CACHE
    if _CMU_CACHE is None:
        path = HERE.parent.parent / "XJournal AI" / "cmudict.txt"
        _CMU_CACHE = load_cmudict(path) if path.exists() else {}
    return _CMU_CACHE


def _phonetic_rhyme(a: str, b: str, cmu: dict | None = None) -> bool:
    """Two words rhyme if their end rimes match in CMU, or big_phoney agrees."""
    aw, bw = _word(a), _word(b)
    if not aw or not bw:
        return False
    if aw == bw:
        return True
    dictionary = cmu if cmu is not None else _cmu()
    ra = end_rime(aw, dictionary) if dictionary else None
    rb = end_rime(bw, dictionary) if dictionary else None
    if ra and rb:
        return ra == rb
    try:
        from catalog_build.annotate import big_phoney
        return big_phoney(aw)[1] == big_phoney(bw)[1]
    except Exception:
        return False


def _couplets_rhyme(end_words: tuple[str, ...], cmu: dict | None = None) -> bool:
    for i in range(0, len(end_words) - 1, 2):
        if not _phonetic_rhyme(end_words[i], end_words[i + 1], cmu):
            return False
    return True

# Spec pockets. Verse is the Audamar 4x4 comma count. These are the only ranges.
SECTION_POCKET = {
    "verse": (15, 19, 3),
    "hook": (10, 14, 1),
    "bridge": (8, 12, 1),
    "outro": (6, 10, 0),
}

TELEMETRY_FIELDS = (
    "generation_id",
    "bar_index",
    "voice",
    "text",
    "scaffold_text",
    "scaffold_source",
    "scaffold_distance",
    "scaffold_cap",
    "end_word",
    "end_word_ok",
    "rhyme_family_ok",
    "inner_rhyme_count",
    "inner_rhyme_ok",
    "target_syl",
    "actual_syl",
    "delta",
    "syllable_ok",
    "commas",
    "comma_ok",
    "name_guard_ok",
    "punch_demoted",
    "violations",
    "verified",
    "retries_used",
    "style_score",
    "retrieval_id",
    "plan_hit",
)


@dataclass(frozen=True)
class Shape:
    syl_budget: int
    bar_count: int
    section_mode: str
    meter_commas: int
    bpm: float
    seed_line: str = ""


@dataclass(frozen=True)
class Plan:
    motif_chain: tuple[str, ...]
    end_words: tuple[str, ...]
    couplet_voices: tuple[str, ...]
    rhyme_families: tuple[tuple[str, ...], ...]
    double_meaning_slots: tuple[int, ...]
    planner_model: str
    plan_valid: bool


@dataclass(frozen=True)
class CatalogLine:
    text: str
    end_word: str
    artist: str
    song: str
    album: str
    retrieval_id: Any
    is_iconic_anthem: bool
    scaffold_source: str
    comma_count: int


@dataclass
class Bar:
    index: int
    text: str
    end_word: str
    voice: str


@dataclass
class Verse:
    bars: list[Bar]
    model: str


@dataclass
class VerifiedVerse:
    verse: Verse
    violations: list[dict[str, Any]]
    verified: bool
    retries_used: int
    retries_exhausted: bool
    measures: list[dict[str, Any]]
    style_score: Optional[float] = None
    plan: Optional[Plan] = None
    shape: Optional[Shape] = None
    scaffold: tuple[CatalogLine, ...] = ()
    gate_open: bool = False


def _section(mode: str) -> tuple[int, int, int]:
    return SECTION_POCKET.get((mode or "verse").strip().lower(), SECTION_POCKET["verse"])


def _clamp(value: int, lo: int, hi: int) -> int:
    return max(lo, min(hi, int(value)))


def shape_v5(user_input: dict[str, Any] | None = None) -> Shape:
    """Stage 1. One syllable budget, clamped to the section pocket."""
    user = dict(user_input or {})
    mode = str(user.get("section_mode") or user.get("section") or "verse").strip().lower()
    if mode not in SECTION_POCKET:
        mode = "verse"
    lo, hi, commas = _section(mode)
    bars = int(user.get("bar_count") or user.get("bars") or user.get("bars_count") or 8)
    bars = max(1, bars)
    seed_line = str(user.get("seed_line") or "").strip()
    flow = user.get("audio_flow")
    if flow is None and (user.get("seed_audio") or user.get("hum")):
        try:
            from whisper_seed import transcribe_and_extract_flow
            flow = transcribe_and_extract_flow(user.get("seed_audio") or user.get("hum"))
        except Exception as exc:
            print(f"[frontier_v5] whisper warning: {exc}", file=sys.stderr)
            flow = None
    if isinstance(flow, dict) and flow:
        bpm = float(flow.get("bpm_estimate") or user.get("bpm") or 130)
        proposed = int(flow.get("median_syl_per_line") or tempo_line_syllables(bpm))
        if not seed_line and flow.get("text"):
            seed_line = str(flow.get("text")).strip()
    else:
        bpm = float(user.get("bpm") or 130)
        proposed = tempo_line_syllables(bpm)
    return Shape(
        syl_budget=_clamp(proposed, lo, hi),
        bar_count=bars,
        section_mode=mode,
        meter_commas=commas,
        bpm=bpm,
        seed_line=seed_line,
    )


def cache_params_v5(
    shape: Shape,
    voice: str,
    blend: str = "",
    mix: int = 70,
    topic_hint: str = "",
    chosen_albums: list[str] | None = None,
    plan_hash: str = "",
) -> dict[str, Any]:
    """Pre-gate key. plan_hash is empty until a plan exists, so the lookup is the inputs."""
    albums = sorted(str(album).strip().lower() for album in (chosen_albums or []) if str(album).strip())
    return {
        "engine": "v5",
        "voice": (voice or "Gunna").strip(),
        "blend": (blend or "").strip(),
        "mix": int(mix),
        "shape": {
            "syl_budget": shape.syl_budget,
            "bar_count": shape.bar_count,
            "section_mode": shape.section_mode,
            "meter_commas": shape.meter_commas,
            "bpm": round(float(shape.bpm), 1),
        },
        "seed_line": shape.seed_line,
        "topic_hint": (topic_hint or "").strip().lower(),
        "chosen_albums": albums,
        "plan_hash": plan_hash or "",
    }


def _couplets(bars: int) -> int:
    return max(1, (bars + 1) // 2)


def _default_slots(bars: int) -> tuple[int, ...]:
    slots = tuple(index for index in range(bars) if (index + 1) % 4 == 0)
    if slots:
        return slots
    if bars > 0:
        return (bars - 1,)
    return ()


def _slots(voice: str, blend: str, bars: int, given: Any) -> tuple[int, ...]:
    cleaned: list[int] = []
    for item in given or []:
        try:
            index = int(item)
        except (TypeError, ValueError):
            continue
        if 0 <= index < bars and index not in cleaned:
            cleaned.append(index)
    if cleaned:
        return tuple(cleaned)
    if not DOUBLE_MEANING_ANY_VOICE:
        names = f"{voice} {blend}".lower().replace(" ", "")
        if "nocap" not in names and "lilwayne" not in names:
            return ()
    return _default_slots(bars)


def _word(value: str) -> str:
    tokens = tokenize(normalize(value or ""))
    return tokens[-1] if tokens else ""


def _parse_json(text: str) -> dict | None:
    raw = (text or "").strip()
    if not raw:
        return None
    raw = re.sub(r"^```(?:json)?|```$", "", raw, flags=re.IGNORECASE).strip()
    start = raw.find("{")
    end = raw.rfind("}")
    if start < 0 or end <= start:
        return None
    try:
        data = json.loads(raw[start:end + 1])
    except json.JSONDecodeError:
        return None
    return data if isinstance(data, dict) else None


def _families(raw: Any, end_words: tuple[str, ...], couplets: int) -> tuple[tuple[str, ...], ...]:
    families = []
    items = list(raw or [])
    for index in range(couplets):
        words: list[str] = []
        for offset in (0, 1):
            pos = index * 2 + offset
            if pos < len(end_words) and end_words[pos] not in words:
                words.append(end_words[pos])
        extra = items[index] if index < len(items) else []
        if isinstance(extra, str):
            extra = [extra]
        for item in extra or []:
            token = _word(str(item))
            if token and token not in words:
                words.append(token)
        families.append(tuple(words))
    return tuple(families)


def _plan_from_json(
    data: dict,
    bars: int,
    voice: str,
    blend: str,
    allowed: set[str],
    model: str,
) -> Plan | None:
    couplets = _couplets(bars)
    try:
        end_words = tuple(_word(str(word)) for word in data["end_words"])
        motifs = tuple(str(item).strip() for item in data["motif_chain"])
        voices = tuple(str(item).strip() for item in data["couplet_voices"])
    except (KeyError, TypeError):
        return None
    if len(end_words) != bars or any(not word for word in end_words):
        return None
    if allowed and any(word not in allowed for word in end_words):
        return None
    if len(motifs) != couplets or len(voices) != couplets:
        return None
    if not _couplets_rhyme(end_words):
        return None
    return Plan(
        motif_chain=motifs,
        end_words=end_words,
        couplet_voices=voices,
        rhyme_families=_families(data.get("rhyme_families"), end_words, couplets),
        double_meaning_slots=_slots(voice, blend, bars, data.get("double_meaning_slots")),
        planner_model=model,
        plan_valid=True,
    )


def _repair_rhyme_pairs(end_words: tuple[str, ...], menu: list[str]) -> tuple[str, ...]:
    """Walk couplet pairs, duplicate first word of the pair when they do not rhyme."""
    words = list(end_words)
    pool = [_word(w) for w in menu if _word(w)]
    for i in range(0, len(words) - 1, 2):
        if _phonetic_rhyme(words[i], words[i + 1]):
            continue
        match = next((w for w in pool if w != words[i] and _phonetic_rhyme(words[i], w)), None)
        words[i + 1] = match or words[i]
    return tuple(words)


def _fallback_plan(shape: Shape, voice: str, blend: str, mix: int, topic_hint: str) -> Plan:
    from planner import _fallback_plan as v3_fallback

    raw = v3_fallback(voice, blend, shape.bpm, shape.bar_count, topic_hint)
    end_words = tuple(_word(str(word)) for word in (raw.get("end_words") or []))
    while len(end_words) < shape.bar_count:
        end_words = end_words + ((end_words[-1] if end_words else "audamar"),)
    end_words = end_words[:shape.bar_count]
    end_words = _repair_rhyme_pairs(end_words, list(end_words))
    couplets = _couplets(shape.bar_count)
    motifs = tuple(str(item) for item in (raw.get("motif_chain") or ()))
    while len(motifs) < couplets:
        motifs = motifs + ("lavishness_money",)
    voices = tuple(str(item) for item in (raw.get("couplet_voices") or ()))
    while len(voices) < couplets:
        voices = voices + (voice,)
    return Plan(
        motif_chain=motifs[:couplets],
        end_words=end_words,
        couplet_voices=voices[:couplets],
        rhyme_families=_families(raw.get("rhyme_families"), end_words, couplets),
        double_meaning_slots=_slots(voice, blend, shape.bar_count, ()),
        planner_model="heuristic_fallback",
        plan_valid=True,
    )


def _call_model(call_fn: Callable[[str, str], str] | None, model: str, system: str, user: str) -> str:
    if call_fn is not None:
        return call_fn(system, user) or ""
    from llm_client import chat

    return chat(model=model, system=system, user=user, max_tokens=900, temperature=0.4) or ""


def plan_v5(
    shape: Shape,
    voice: str,
    blend: str = "",
    mix: int = 70,
    topic_hint: str = "",
    chosen_albums: list[str] | None = None,
    call_fn: Callable[[str, str], str] | None = None,
    sample_fn: Callable[..., list[str]] | None = None,
    wordplay_hints: list[dict] | None = None,
    chip_hints: list[dict] | None = None,
) -> Plan:
    """Stage 2. End words come from the catalog menu. The plan is not edited later."""
    sampler = sample_fn or sample_end_words
    menu = list(sampler(voice, count=shape.bar_count, dedupe_window=16) or [])
    if blend and blend.strip().lower() != voice.strip().lower():
        menu.extend(sampler(blend, count=shape.bar_count, dedupe_window=16) or [])
    allowed = []
    for word in menu:
        token = _word(word)
        if token and token not in allowed:
            allowed.append(token)
    if not allowed:
        print("[frontier_v5] plan catalog menu empty; using the v3 motif fallback", file=sys.stderr)
        return _fallback_plan(shape, voice, blend, mix, topic_hint)

    couplets = _couplets(shape.bar_count)
    voices = [voice] * couplets
    try:
        from polish import allocate_bar_artists
        artists = allocate_bar_artists(voice=voice, blend=blend, mix=mix, bars_count=shape.bar_count)
        voices = [artists[min(index * 2, len(artists) - 1)] for index in range(couplets)]
    except Exception:
        voices = [voice] * couplets
    system = (
        "You plan a rap verse. Return one JSON object and no other text. "
        "End words must be copied from the catalog menu. Do not invent an end word."
    )
    user = (
        "V5 PLAN\n"
        f"Voice: {voice}\n"
        f"Blend: {blend or 'none'} at mix {mix}\n"
        f"Section: {shape.section_mode}\n"
        f"Syllable budget: {shape.syl_budget}\n"
        f"Commas: {shape.meter_commas}\n"
        f"Bars: {shape.bar_count}\n"
        f"Topic: {topic_hint or 'none'}\n"
        f"Albums: {', '.join(chosen_albums or []) or 'none'}\n"
        f"Catalog end-word menu: {', '.join(allowed)}\n"
        f"Couplet voices to use: {', '.join(voices)}\n"
        "Double-meaning slots are open to this voice. Pick bar indexes or leave the list empty.\n"
        "JSON keys: motif_chain, couplet_voices, end_words, rhyme_families, double_meaning_slots.\n"
        f"motif_chain and couplet_voices and rhyme_families have length {couplets}. "
        f"end_words has length {shape.bar_count}. Repeat a menu word if the menu is short.\n"
        "Rhyme rule: paired end_words at positions (0,1), (2,3), (4,5), (6,7) MUST share the same "
        "end-rime phonetically. If no two menu words rhyme, repeat the same word for both bars in the pair."
    )
    if wordplay_hints:
        shown = wordplay_hints[:5]
        block_lines = ["", "WORDPLAY_EXAMPLES (Samuel-confirmed, use as PATTERNS not quotes):"]
        for idx, ex in enumerate(shown, 1):
            tab = ex.get("tab") or "?"
            setup = ex.get("setup") or ""
            play = ex.get("play") or ""
            heard = ex.get("heard_as") or ""
            block_lines.append(
                f"  {idx}. [{tab}] by {ex.get('artist','?')}: {ex.get('line','')!r}"
            )
            if setup or play:
                block_lines.append(f"     setup: {setup}  flip/play: {play}  heard_as: {heard}")
        block_lines.append(
            "Pick ONE example as a pattern. Plan a NEW line in this verse that "
            "runs setup -> flip -> payoff, where the payoff word is the end word "
            "of its bar and matches that bar's rhyme family. Never copy the example line."
        )
        user = user + "\n" + "\n".join(block_lines)
    if chip_hints:
        chip_block = ["", "CHIP_BANK (Samuel's noun bank — use 1-2 as end words or the punchline subject):"]
        for idx, ch in enumerate(chip_hints[:10], 1):
            rime_str = "-".join(ch.get("end_rime") or []) or "?"
            chip_block.append(
                f"  {idx}. '{ch.get('chip','?')}' [{ch.get('category','?')} / {ch.get('section','?')}] rime={rime_str}"
            )
        chip_block.append(
            "Prefer these chips as end words whose rime matches the plan's end-word menu. "
            "Keep concrete nouns from the bank; do not copy any example bar text."
        )
        user = user + "\n" + "\n".join(chip_block)
    model = "custom_call_fn" if call_fn else PLAN_MODEL
    for _attempt in range(2):
        try:
            text = _call_model(call_fn, PLAN_MODEL, system, user)
        except Exception as exc:
            print(f"[frontier_v5] plan call failed: {exc}", file=sys.stderr)
            text = ""
        data = _parse_json(text)
        if data is None:
            continue
        plan = _plan_from_json(data, shape.bar_count, voice, blend, set(allowed), model)
        if plan is not None:
            return plan
    print("[frontier_v5] plan JSON failed twice; using the v3 motif fallback", file=sys.stderr)
    return _fallback_plan(shape, voice, blend, mix, topic_hint)


def _softmax_one(rows: list[dict], temperature: float, rng: random.Random) -> dict | None:
    if not rows:
        return None
    if len(rows) == 1:
        return rows[0]
    scores = []
    for row in rows:
        scores.append(float(row.get("retrieval_rank") or row.get("match_score") or 1.0))
    peak = max(scores) if scores else 1.0
    if peak <= 0:
        peak = 1.0
    temp = temperature if temperature > 0 else 2.0
    weights = [math.exp(score / (peak * temp)) for score in scores]
    return rng.choices(list(rows), weights=weights, k=1)[0]


def _bank_line(voice: str, end_word: str) -> CatalogLine:
    print(
        f"[frontier_v5] scaffold_source=bank voice={voice} end_word={end_word}",
        file=sys.stderr,
    )
    text = f"No catalog line, bank lands {end_word}".strip()
    return CatalogLine(
        text=text,
        end_word=end_word,
        artist=voice,
        song="",
        album="",
        retrieval_id=None,
        is_iconic_anthem=False,
        scaffold_source="bank",
        comma_count=text.count(","),
    )


def _catalog_line(row: dict, end_word: str) -> CatalogLine:
    text = str(row.get("text") or "")
    return CatalogLine(
        text=text,
        end_word=str(row.get("end_word") or end_word),
        artist=str(row.get("artist") or ""),
        song=str(row.get("song") or ""),
        album=str(row.get("album") or ""),
        retrieval_id=row.get("id"),
        is_iconic_anthem=bool(row.get("is_iconic_anthem")),
        scaffold_source="catalog",
        comma_count=text.count(","),
    )


def retrieve_v5(
    plan: Plan,
    shape: Shape,
    voice: str,
    blend: str = "",
    chosen_albums: list[str] | None = None,
    retrieve_fn: Callable[..., list] | None = None,
    db_path: Path | None = None,
    rng: random.Random | None = None,
) -> tuple[CatalogLine, ...]:
    """Stage 3. One catalog line per bar. A miss is tagged bank and is not a new lyric."""
    del blend
    finder = retrieve_fn or retrieve_matching_catalog_lines
    recent = get_end_word_history(window_size=16)
    temp = float(os.environ.get("V5_RETRIEVAL_TEMP", "2.0") or 2.0)
    picker = rng or random.Random()
    lines: list[CatalogLine] = []
    for index in range(shape.bar_count):
        couplet = index // 2
        end_word = plan.end_words[index] if index < len(plan.end_words) else ""
        bar_voice = plan.couplet_voices[couplet] if couplet < len(plan.couplet_voices) else voice
        motif = plan.motif_chain[couplet] if couplet < len(plan.motif_chain) else ""
        pattern = {"end_word": end_word, "target_syllables": shape.syl_budget, "topic": motif}
        kwargs: dict[str, Any] = {
            "artist": bar_voice,
            "pattern": pattern,
            "chosen_albums": chosen_albums,
            "limit": 60,
            "bar_number": index + 1,
            "topic_hint": motif,
            "recent_end_words": recent,
            "end_word_dedupe_window": 16,
        }
        if db_path is not None:
            kwargs["db_path"] = db_path
        try:
            matches = finder(**kwargs) or []
        except TypeError:
            matches = finder(bar_voice, pattern) or []
        picked = _softmax_one([row for row in matches if isinstance(row, dict)], temp, picker)
        if picked and picked.get("text"):
            lines.append(_catalog_line(picked, end_word))
        else:
            lines.append(_bank_line(bar_voice, end_word))
    return tuple(lines)


def _edit_cap(line: CatalogLine) -> tuple[int, int]:
    count = max(1, len(tokenize(normalize(line.text))))
    percent = 15 if line.is_iconic_anthem else 30
    return max(1, int(round(count * percent / 100.0))), percent


def _edit_prompt(
    plan: Plan,
    scaffold: tuple[CatalogLine, ...],
    shape: Shape,
    voice: str,
    taste: str,
    only_index: int | None,
    violations: list[str] | None,
) -> str:
    indexes = [only_index] if only_index is not None else list(range(len(scaffold)))
    blocks = []
    if only_index is not None:
        blocks.append("retry this bar only")
        blocks.append("violations: " + ", ".join(violations or []))
    for index in indexes:
        line = scaffold[index]
        cap_tokens, cap_percent = _edit_cap(line)
        end_word = plan.end_words[index] if index < len(plan.end_words) else line.end_word
        bar_voice = plan.couplet_voices[index // 2] if plan.couplet_voices else voice
        blocks.append(
            f"Bar {index + 1} — EDIT this line, preserve the end word '{end_word}':\n"
            f"  \"{line.text}\"\n"
            "Rules (do not break any):\n"
            f"  • End word '{end_word}' stays exactly.\n"
            f"  • At most {cap_tokens} words changed ({cap_percent}%; anthem lines capped at 15%, others 30%).\n"
            f"  • Same comma count ({line.comma_count}), same syllable count ±1 of {shape.syl_budget}.\n"
            "  • Keep the picture — the object, place, or person named in the scaffold.\n"
            f"  • Voice: '{bar_voice}'. Use their slang bag '{bar_voice}'.\n"
            "  • Inner rhyme: 2–4 same-vowel-class content words before the end word.\n"
            "  • If you can't satisfy all rules, return the scaffold unchanged."
        )
    if taste:
        blocks.append("Taste:\n" + taste)
    blocks.append("Return one line per bar, prefixed with its bar number.")
    return "\n\n".join(blocks)


def _parse_edit_lines(text: str, expected: int) -> list[str]:
    found: dict[int, str] = {}
    plain: list[str] = []
    for raw in (text or "").splitlines():
        line = raw.strip()
        if not line or line.startswith("```"):
            continue
        match = re.match(r"^bar\s*(\d+)\s*[—:\-.]+\s*(.+)$", line, flags=re.IGNORECASE)
        if match:
            found[int(match.group(1))] = match.group(2).strip().strip('"')
        else:
            plain.append(line.strip('"'))
    if found:
        return [found.get(index + 1, "") for index in range(expected)]
    return plain


def edit_v5(
    plan: Plan,
    scaffold: tuple[CatalogLine, ...],
    shape: Shape,
    voice: str,
    taste: str = "",
    call_fn: Callable[[str, str], str] | None = None,
    only_index: int | None = None,
    violations: list[str] | None = None,
    verse: Verse | None = None,
) -> Verse:
    """Stage 4. One polish pass. A bar that comes back empty keeps its scaffold line."""
    system = "You edit catalog lines into a new sentence. You do not throw away the line."
    user = _edit_prompt(plan, scaffold, shape, voice, taste, only_index, violations)
    try:
        text = _call_model(call_fn, EDIT_MODEL, system, user)
    except Exception as exc:
        print(f"[frontier_v5] edit call failed: {exc}", file=sys.stderr)
        text = ""
    parsed = _parse_edit_lines(text, len(scaffold))
    bars: list[Bar] = []
    for index, line in enumerate(scaffold):
        previous = ""
        if verse is not None and index < len(verse.bars):
            previous = verse.bars[index].text
        if only_index is not None and index != only_index:
            chosen = previous or line.text
        else:
            edited = parsed[index] if index < len(parsed) else ""
            if only_index is not None and not edited and parsed:
                edited = parsed[0]
            chosen = edited or previous or line.text
        end_word = plan.end_words[index] if index < len(plan.end_words) else line.end_word
        bar_voice = plan.couplet_voices[index // 2] if plan.couplet_voices else voice
        bars.append(Bar(index=index, text=chosen, end_word=end_word, voice=bar_voice))
    model = "custom_call_fn" if call_fn else EDIT_MODEL
    return Verse(bars=bars, model=model)


def _word_syllables(word: str, cmu: dict) -> int:
    phones = cmu.get(word.lower()) if cmu else None
    if phones:
        vowels = [phone for phone in phones if phone[-1:] in "012"]
        if vowels:
            return len(vowels)
    return estimate_syllables(word)


def rhyme_family_ok(end_word: str, family: tuple[str, ...] | list[str], cmu: dict | None) -> bool:
    """The end word matches the family, and the word itself is at least two syllables."""
    word = _word(end_word)
    if not word or _word_syllables(word, cmu or {}) < 2:
        return False
    members = [_word(item) for item in family if _word(item)]
    if word in members:
        return True
    dictionary = cmu or {}
    mine = end_rime(word, dictionary) if dictionary else None
    for member in members:
        other = end_rime(member, dictionary) if dictionary else None
        if mine and other and mine == other:
            return True
        if mine is None or other is None:
            try:
                from catalog_build.annotate import big_phoney
            except Exception:
                continue
            if big_phoney(word)[1] == big_phoney(member)[1]:
                return True
    return False


def _unknown_names(text: str, voice: str) -> list[str]:
    try:
        from catalog_build.annotate import _whitelist
        allowed = _whitelist(voice)
    except Exception:
        allowed = set()
    tokens = set(tokenize(normalize(text)))
    bad = []
    for index, raw in enumerate(text.split()):
        if index == 0:
            continue
        piece = raw.strip(".,;:!?\"'")
        if len(piece) < 2 or not piece[0].isupper():
            continue
        token = _word(piece)
        if token and token not in {"i", "a"} and token in tokens and token not in allowed:
            bad.append(token)
    return bad


def _required_commas(shape: Shape, scaffold: CatalogLine) -> int:
    # The lower count is the stricter breath, floored at one so every bar breathes.
    return max(1, min(shape.meter_commas, scaffold.comma_count))


def measure_bar(
    index: int,
    text: str,
    plan: Plan,
    scaffold: CatalogLine,
    shape: Shape,
    cmu: dict | None = None,
    syllable_fn: Callable[[str], int] | None = None,
    inner_fn: Callable[[str, dict], list] | None = None,
    rhyme_fn: Callable[[str, tuple, dict], bool] | None = None,
) -> dict[str, Any]:
    """One bar, every check. The checks do not depend on each other."""
    dictionary = cmu or {}
    tokens_now = tokenize(normalize(text))
    tokens_src = tokenize(normalize(scaffold.text))
    distance = token_levenshtein_distance(tokens_src, tokens_now)
    cap_tokens, _percent = _edit_cap(scaffold)
    end_word = plan.end_words[index] if index < len(plan.end_words) else ""
    actual_end = _word(text)
    family = plan.rhyme_families[index // 2] if plan.rhyme_families else ()
    syl_fn = syllable_fn or estimate_syllables
    actual_syl = int(syl_fn(text))
    delta = actual_syl - shape.syl_budget
    inner = (inner_fn or detect_inner_rhymes)(text, dictionary)
    inner_count = len(inner)
    rhyme_ok = (rhyme_fn or rhyme_family_ok)(actual_end, family, dictionary)
    names = _unknown_names(text, scaffold.artist or "")
    punch = check_punch_demoted(text, end_word)
    required = _required_commas(shape, scaffold)
    commas = text.count(",")
    codes = []
    if scaffold.scaffold_source == "bank":
        codes.append("bank")
    if distance > cap_tokens:
        codes.append("scaffold")
    if actual_end != _word(end_word):
        codes.append("end_word")
    if not rhyme_ok:
        codes.append("rhyme_family")
    if not (2 <= inner_count <= 4):
        codes.append("inner_rhyme")
    if abs(delta) > 1:
        codes.append("syllables")
    if commas != required:
        codes.append("commas")
    if names:
        codes.append("name_guard")
    if punch:
        codes.append("punch")
    return {
        "bar_index": index,
        "codes": codes,
        "scaffold_distance": distance,
        "scaffold_cap": cap_tokens,
        "end_word_ok": "end_word" not in codes,
        "rhyme_family_ok": rhyme_ok,
        "inner_rhyme_count": inner_count,
        "inner_rhyme_ok": "inner_rhyme" not in codes,
        "actual_syl": actual_syl,
        "delta": delta,
        "syllable_ok": "syllables" not in codes,
        "commas": commas,
        "comma_ok": "commas" not in codes,
        "name_guard_ok": "name_guard" not in codes,
        "punch_demoted": punch,
        "plan_hit": not codes,
    }


def _retry_budget(max_retries: int | None) -> int:
    if max_retries is not None:
        return max(0, int(max_retries))
    raw = os.environ.get("V5_MAX_RETRIES", "8")
    try:
        return max(0, int(raw))
    except ValueError:
        return 8


def verify_v5(
    verse: Verse,
    plan: Plan,
    scaffold: tuple[CatalogLine, ...],
    shape: Shape,
    voice: str,
    taste: str = "",
    call_fn: Callable[[str, str], str] | None = None,
    edit_fn: Callable[..., Verse] | None = None,
    max_retries: int | None = None,
    cmu: dict | None = None,
    syllable_fn: Callable[[str], int] | None = None,
    inner_fn: Callable[[str, dict], list] | None = None,
    rhyme_fn: Callable[[str, tuple, dict], bool] | None = None,
) -> VerifiedVerse:
    """Stage 5. One gate. A miss retries that bar only, inside one shared budget."""
    dictionary = cmu if cmu is not None else {}
    budget = _retry_budget(max_retries)
    editor = edit_fn or edit_v5
    current = verse
    used = 0
    exhausted = False
    measures = [
        measure_bar(bar.index, bar.text, plan, scaffold[bar.index], shape, dictionary, syllable_fn, inner_fn, rhyme_fn)
        for bar in current.bars
    ]
    while used < budget:
        failing = [
            item for item in measures
            if item["codes"] and "bank" not in item["codes"]
        ]
        if not failing:
            break
        target = failing[0]
        if used + 1 > budget:
            exhausted = True
            break
        current = editor(
            plan,
            scaffold,
            shape,
            voice,
            taste=taste,
            call_fn=call_fn,
            only_index=target["bar_index"],
            violations=list(target["codes"]),
            verse=current,
        )
        used += 1
        measures = [
            measure_bar(bar.index, bar.text, plan, scaffold[bar.index], shape, dictionary, syllable_fn, inner_fn, rhyme_fn)
            for bar in current.bars
        ]
    else:
        if any(item["codes"] and "bank" not in item["codes"] for item in measures):
            exhausted = True
    if any(item["codes"] for item in measures) and used >= budget:
        exhausted = True
    violations = [
        {"bar_index": item["bar_index"], "codes": list(item["codes"])}
        for item in measures
        if item["codes"]
    ]
    return VerifiedVerse(
        verse=current,
        violations=violations,
        verified=not violations,
        retries_used=used,
        retries_exhausted=bool(exhausted and violations),
        measures=measures,
        plan=plan,
        shape=shape,
        scaffold=scaffold,
    )


def _style_score(text: str) -> tuple[float, bool]:
    try:
        style_dir = HERE.parent / "style-profile"
        if str(style_dir) not in sys.path:
            sys.path.insert(0, str(style_dir))
        import style_scorer
        gate = bool(style_scorer.passes_gate())
        value = float(style_scorer.score(text))
    except Exception:
        return 0.5, False
    if value < 0.0 or value > 1.0:
        value = 0.5
    return value, gate


def select_v5(
    candidates: list[VerifiedVerse],
    score_fn: Callable[[str], float] | None = None,
    gate_open: bool | None = None,
) -> VerifiedVerse:
    """Stage 6. The style score ranks only while its gate is open. The score is always stored."""
    if not candidates:
        raise ValueError("select_v5 needs a verse")
    if score_fn is None:
        def score_fn(text: str) -> float:
            value, _gate = _style_score(text)
            return value
    if gate_open is None:
        _value, gate_open = _style_score("")
    for item in candidates:
        if item.style_score is None:
            text = "\n".join(bar.text for bar in item.verse.bars)
            item.style_score = float(score_fn(text))
        item.gate_open = bool(gate_open)
    if len(candidates) > 1 and gate_open:
        return max(candidates, key=lambda item: item.style_score if item.style_score is not None else -1.0)
    for item in candidates:
        if item.verified:
            return item
    return candidates[0]


def _load_taste(voice: str) -> str:
    try:
        style_dir = HERE.parent / "style-profile"
        if str(style_dir) not in sys.path:
            sys.path.insert(0, str(style_dir))
        from phase6_generate import build_taste_prompt_blocks
        keeper, avoid = build_taste_prompt_blocks(voice)
        return "\n".join(part for part in (keeper, avoid) if part)
    except Exception:
        return ""


def _jsonable(value):
    """asdict on Python 3.9 keeps tuples. The verse result should be plain lists."""
    if isinstance(value, tuple):
        return [_jsonable(item) for item in value]
    if isinstance(value, list):
        return [_jsonable(item) for item in value]
    if isinstance(value, dict):
        return {key: _jsonable(item) for key, item in value.items()}
    return value


def record_v5(
    winner: VerifiedVerse,
    shape: Shape,
    plan: Plan,
    scaffold: tuple[CatalogLine, ...],
    voice: str,
    blend: str = "",
    mix: int = 70,
    topic_hint: str = "",
    chosen_albums: list[str] | None = None,
    generation_id: str = "",
    use_cache: bool = True,
    cache_key: str = "",
    cache_params: dict | None = None,
    telemetry_path: Path | None = None,
    history_path: Path | None = None,
    cache_dir: Path | None = None,
) -> dict[str, Any]:
    """Stage 7. Telemetry, end-word history, and the cache when the verse verified."""
    generation_id = generation_id or f"v5_{int(time.time())}_{uuid.uuid4().hex[:8]}"
    dest = telemetry_path or TELEMETRY_PATH
    dest.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    bar_payload = []
    for measure in winner.measures:
        index = measure["bar_index"]
        bar = winner.verse.bars[index]
        line = scaffold[index]
        row = {
            "generation_id": generation_id,
            "bar_index": index + 1,
            "voice": bar.voice or voice,
            "text": bar.text,
            "scaffold_text": line.text,
            "scaffold_source": line.scaffold_source,
            "scaffold_distance": measure["scaffold_distance"],
            "scaffold_cap": measure["scaffold_cap"],
            "end_word": bar.end_word,
            "end_word_ok": measure["end_word_ok"],
            "rhyme_family_ok": measure["rhyme_family_ok"],
            "inner_rhyme_count": measure["inner_rhyme_count"],
            "inner_rhyme_ok": measure["inner_rhyme_ok"],
            "target_syl": shape.syl_budget,
            "actual_syl": measure["actual_syl"],
            "delta": measure["delta"],
            "syllable_ok": measure["syllable_ok"],
            "commas": measure["commas"],
            "comma_ok": measure["comma_ok"],
            "name_guard_ok": measure["name_guard_ok"],
            "punch_demoted": measure["punch_demoted"],
            "violations": list(measure["codes"]),
            "verified": winner.verified,
            "retries_used": winner.retries_used,
            "style_score": winner.style_score,
            "retrieval_id": line.retrieval_id,
            "plan_hit": measure["plan_hit"],
        }
        rows.append(row)
        bar_payload.append({
            "index": index,
            "text": bar.text,
            "artist": bar.voice,
            "end_word": bar.end_word,
            "end_word_preserved": measure["end_word_ok"],
            "punch_demoted": measure["punch_demoted"],
            "violations": list(measure["codes"]),
            "scaffold_source": line.scaffold_source,
        })
    with dest.open("a", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")
    record_used_end_words([bar.end_word for bar in winner.verse.bars], history_path=history_path)
    result = {
        "ok": winner.verified,
        "version": "v5",
        "verified": winner.verified,
        "violations": winner.violations,
        "generation_id": generation_id,
        "voice": voice,
        "blend": blend,
        "mix": int(mix) if blend else None,
        "shape": _jsonable(asdict(shape)),
        "plan": _jsonable(asdict(plan)),
        "scaffold": _jsonable([asdict(line) for line in scaffold]),
        "bars": bar_payload,
        "raw_text": "\n".join(bar.text for bar in winner.verse.bars),
        "style_score": winner.style_score,
        "style_gate_open": winner.gate_open,
        "retries_used": winner.retries_used,
        "retries_exhausted_at": ["verify"] if winner.retries_exhausted else [],
        "cached": False,
        "cache_key": cache_key,
        "provider": f"frontier_v5 ({winner.verse.model})",
    }
    if not winner.verified:
        result["gates_failed"] = ["verify"]
    if use_cache and cache_key and cache_params is not None:
        save_cached_verse(
            cache_key=cache_key,
            params=cache_params,
            result=result,
            retrieved_catalog_bars=[asdict(line) for line in scaffold],
            plan=asdict(plan),
            cache_dir=cache_dir or CACHE_DIR,
        )
    return result


def generate_v5(
    user_input: dict[str, Any] | None = None,
    voice: str = "Gunna",
    blend: str = "",
    mix: int = 70,
    chosen_albums: list[str] | None = None,
    topic_hint: str = "",
    use_cache: bool = True,
    call_fn: Callable[[str, str], str] | None = None,
    candidates: int = 1,
    generation_id: str = "",
    sample_fn: Callable[..., list[str]] | None = None,
    retrieve_fn: Callable[..., list] | None = None,
    score_fn: Callable[[str], float] | None = None,
    gate_open: bool | None = None,
    telemetry_path: Path | None = None,
    history_path: Path | None = None,
    cache_dir: Path | None = None,
    db_path: Path | None = None,
    max_retries: int | None = None,
    syllable_fn: Callable[[str], int] | None = None,
    inner_fn: Callable[[str, dict], list] | None = None,
    rhyme_fn: Callable[[str, tuple, dict], bool] | None = None,
    cmu: dict | None = None,
) -> dict[str, Any]:
    """Run the pre-gate and the seven stages. A cache hit returns the saved verse."""
    if eval_disables_cache():
        use_cache = False
    user = dict(user_input or {})
    if topic_hint and "topic_hint" not in user:
        user["topic_hint"] = topic_hint
    shape = shape_v5(user)
    topic = str(user.get("topic_hint") or topic_hint or "")
    params = cache_params_v5(shape, voice, blend, mix, topic, chosen_albums, plan_hash="")
    cache_key = compute_cache_key(params)
    store = cache_dir or CACHE_DIR
    if use_cache:
        cached = get_cached_verse(cache_key, cache_dir=store)
        if cached is not None:
            return cached
    plan = plan_v5(
        shape,
        voice,
        blend=blend,
        mix=mix,
        topic_hint=topic,
        chosen_albums=chosen_albums,
        call_fn=call_fn,
        sample_fn=sample_fn,
        wordplay_hints=user.get("wordplay_hints"),
        chip_hints=user.get("chip_hints"),
    )
    scaffold = retrieve_v5(
        plan,
        shape,
        voice,
        blend=blend,
        chosen_albums=chosen_albums,
        retrieve_fn=retrieve_fn,
        db_path=db_path,
    )
    taste = _load_taste(voice)
    verified_list = []
    takes = max(1, int(candidates))
    for _take in range(takes):
        draft = edit_v5(plan, scaffold, shape, voice, taste=taste, call_fn=call_fn)
        verified_list.append(verify_v5(
            draft,
            plan,
            scaffold,
            shape,
            voice,
            taste=taste,
            call_fn=call_fn,
            max_retries=max_retries,
            cmu=cmu,
            syllable_fn=syllable_fn,
            inner_fn=inner_fn,
            rhyme_fn=rhyme_fn,
        ))
    winner = select_v5(verified_list, score_fn=score_fn, gate_open=gate_open)
    return record_v5(
        winner,
        shape,
        plan,
        scaffold,
        voice,
        blend=blend,
        mix=mix,
        topic_hint=topic,
        chosen_albums=chosen_albums,
        generation_id=generation_id,
        use_cache=use_cache,
        cache_key=cache_key,
        cache_params=params,
        telemetry_path=telemetry_path,
        history_path=history_path,
        cache_dir=store,
    )


def _hard_check_bars(bars: list[str], voice: str, cmu: dict | None = None,
                     chip_words: list[str] | None = None,
                     shown_examples: list[str] | None = None,
                     novelty_on: bool = True) -> dict:
    """Return {'ok': bool, 'reasons': [str], 'novelty': {...}}.

    Hard rules (any one trips rejection):
      - any bar missing a comma
      - couplet end-rhymes don't match phonetically
      - novelty check (if `novelty_on`): any bar is a near-dup of a vault
        line or a shown example (exact OR shared-run >= 6 words OR
        5-gram overlap >= 0.40 OR Jaccard >= 0.70). Chip words supplied via
        `chip_words` are excluded from the shared-run count so a shared
        chip alone can't trip the detector.
    """
    reasons: list[str] = []
    novelty_report: dict | None = None
    if not bars:
        return {"ok": False, "reasons": ["empty verse"], "novelty": None}
    # comma check
    for i, b in enumerate(bars):
        if b.count(",") < 1:
            reasons.append(f"bar {i} missing comma")
    # end-rhyme couplets
    try:
        ends = tuple(_word(b.rstrip(".,!?;:").split()[-1]) if b.strip() else "" for b in bars)
        if not _couplets_rhyme(ends, cmu or _cmu()):
            reasons.append("end-rhyme couplet failure")
    except Exception as exc:
        reasons.append(f"end-rhyme check error: {exc}")
    # novelty
    if novelty_on:
        try:
            from taste.novelty import verse_novelty
            novelty_report = verse_novelty(bars, chip_words=chip_words or [],
                                           shown_examples=shown_examples or [])
            if novelty_report["is_near_dup"]:
                bad = novelty_report["near_dup_bar_indexes"]
                reasons.append(f"novelty: near-duplicate bar(s) {bad}")
        except Exception as exc:
            reasons.append(f"novelty check error: {exc}")
    return {"ok": not reasons, "reasons": reasons, "novelty": novelty_report}


def generate_judged(
    user_input: dict[str, Any] | None = None,
    voice: str = "Gunna",
    candidates: int = 8,
    judge_weights_path: Path | None = None,
    topic_hint: str = "",
    use_wordplay_hints: bool = True,
    use_chip_hints: bool = True,
    use_novelty: bool = True,
    use_judge_ranker: bool = False,  # OFF by default; use deterministic tie-break
    **kwargs,
) -> dict[str, Any]:
    """Best-of-N wrapper over generate_v5.

    Hard checks (any trips rejection, no candidate shown):
      - every bar has >=1 comma
      - couplet end-rhymes match phonetically
      - novelty: no bar is a near-dup of a vault line or a shown example

    Ranking of surviving candidates:
      - the learned taste judge is OFF by default (not yet proven via grouped
        CV; see judge CV report). Opt in with use_judge_ranker=True.
      - default tie-break (higher is better): end-rhyme hit rate,
        -syl_variance, chip_used_at_end, chip_used, -novelty.max_fivegram_overlap.
    """
    try:
        from taste.judge import TasteJudge
        wpath = judge_weights_path or (HERE / "taste" / "weights.json")
        judge = TasteJudge.load(wpath) if wpath.exists() else None
    except Exception:
        judge = None

    # Wordplay few-shot (Samuel-approved only)
    hints: list[dict] = []
    pattern: dict | None = None
    shown_examples: list[str] = []
    if use_wordplay_hints:
        try:
            from taste.wordplay import WordplayIndex
            w_idx = WordplayIndex.build()
            hints = w_idx.retrieve(artist=voice, k=5)
            if hints:
                pattern = {k: hints[0].get(k) for k in
                           ("tab", "artist", "song", "line", "setup", "play", "heard_as")}
                shown_examples = [h.get("line", "") for h in hints if h.get("line")]
        except Exception as exc:
            print(f"[frontier_v5] wordplay hints unavailable: {exc}", file=sys.stderr)

    # Chip retrieval: pre-sample menu to get end-rimes, then pull chips
    chip_hints: list[dict] = []
    planned_chips: list[dict] = []
    chip_words: list[str] = []
    if use_chip_hints:
        try:
            from taste.chips import ChipIndex
            chips_idx = ChipIndex.load()
            if len(chips_idx):
                shape_preview = shape_v5(user_input or {})
                menu = list(sample_end_words(voice, count=shape_preview.bar_count,
                                             dedupe_window=16) or [])
                menu_rimes = [list(_cmu_rime(_word(w))) for w in menu if _word(w)]
                chip_hints = chips_idx.retrieve_many_rimes(
                    topic=topic_hint, end_rimes=[r for r in menu_rimes if r],
                    per_rime=2, k=10,
                )
                planned_chips = [{k: c.get(k) for k in ("chip", "category", "section",
                                                        "end_rime", "syllables")}
                                 for c in chip_hints[:4]]
                chip_words = [c.get("chip", "") for c in chip_hints if c.get("chip")]
        except Exception as exc:
            print(f"[frontier_v5] chip hints unavailable: {exc}", file=sys.stderr)

    user_payload = dict(user_input or {})
    if hints:
        user_payload["wordplay_hints"] = hints
    if chip_hints:
        user_payload["chip_hints"] = chip_hints

    def _tie_break(bars_list: list[str]) -> float:
        # Determinstic: lightweight scalar that mirrors Samuel's priors.
        if not bars_list:
            return float("-inf")
        try:
            from taste.features import extract
            f = extract(bars_list, voice=voice)
            score = (10.0 * f["end_rhyme_hit_rate"]
                     + 3.0 * f["multisyllable_rhyme"]
                     - 0.3 * f["syl_variance"]
                     - 1.5 * f["name_leak"])
            # chip-usage bonus (soft)
            text = " ".join(bars_list).lower()
            end_words = {bars_list[i].rstrip(".,!?;:").split()[-1].lower()
                         for i in range(len(bars_list)) if bars_list[i].strip()}
            for ch in chip_words:
                cl = ch.lower()
                if cl in text:
                    score += 0.4
                if cl in end_words:
                    score += 0.8
            return score
        except Exception:
            return 0.0

    def _score(text: str) -> float:
        bars_list = [ln.strip() for ln in text.splitlines() if ln.strip()]
        hard = _hard_check_bars(bars_list, voice,
                                chip_words=chip_words,
                                shown_examples=shown_examples,
                                novelty_on=use_novelty)
        if not hard["ok"]:
            return float("-inf")
        if use_judge_ranker and judge is not None:
            return judge.score_verse(bars_list, voice=voice)
        base = _tie_break(bars_list)
        # subtract scaled novelty overlap so near-copying can't win a tie
        nv = hard.get("novelty")
        if nv:
            base -= 2.0 * float(nv.get("max_fivegram_overlap") or 0.0)
            base -= 0.2 * float(nv.get("max_longest_run") or 0.0)
        return base

    kwargs.setdefault("gate_open", True)
    result = generate_v5(
        user_payload, voice=voice, candidates=max(1, int(candidates)),
        topic_hint=topic_hint, score_fn=_score, **kwargs,
    )
    bars_out = [ln.strip() for ln in (result.get("raw_text") or "").splitlines() if ln.strip()]
    hard = _hard_check_bars(bars_out, voice,
                            chip_words=chip_words,
                            shown_examples=shown_examples,
                            novelty_on=use_novelty)
    result["judge_score"] = judge.score_verse(bars_out, voice=voice) if (judge and bars_out) else None
    result["tie_break_score"] = _tie_break(bars_out) if bars_out else None
    result["judge_rejected"] = not hard["ok"]
    result["judge_reasons"] = hard["reasons"]
    result["wordplay_pattern"] = pattern
    result["wordplay_hints"] = hints
    result["chip_hints_shown"] = chip_hints
    result["planned_chips"] = planned_chips
    result["novelty_report"] = hard.get("novelty")
    if not hard["ok"]:
        result["verified"] = False
    return result


def _cmu_rime(word: str) -> tuple[str, ...]:
    """End-rime of a single word; empty tuple on OOV."""
    if not word:
        return ()
    cmu = _cmu()
    if not cmu:
        return ()
    r = end_rime(word, cmu)
    return tuple(r) if r else ()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="frontier_v5", description="Generate one verse with the v5 stages.")
    parser.add_argument("--voice", default="Gunna")
    parser.add_argument("--blend", default="")
    parser.add_argument("--mix", type=int, default=70)
    parser.add_argument("--bpm", type=float, default=140)
    parser.add_argument("--bars", type=int, default=8)
    parser.add_argument("--section", default="verse")
    parser.add_argument("--topic", default="")
    parser.add_argument("--seed-line", default="")
    parser.add_argument("--no-cache", action="store_true")
    parser.add_argument("--run", action="store_true", help="Call the model and write a verse.")
    args = parser.parse_args(argv)
    if not args.run:
        print("frontier_v5 stages: cache, shape, plan, retrieve, edit, verify, select, record")
        print("Pass --run to generate. This process did not call a model.")
        return 0
    result = generate_v5(
        {"bpm": args.bpm, "bars": args.bars, "section_mode": args.section, "seed_line": args.seed_line},
        voice=args.voice,
        blend=args.blend,
        mix=args.mix,
        topic_hint=args.topic,
        use_cache=not args.no_cache,
    )
    print(result.get("raw_text") or "")
    return 0 if result.get("verified") else 1


if __name__ == "__main__":
    raise SystemExit(main())
