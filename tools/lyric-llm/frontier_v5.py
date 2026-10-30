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
import sqlite3
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
    DB_PATH,
    detect_inner_rhymes,
    get_end_word_history,
    record_used_end_words,
    resolve_catalog_artist,
    retrieve_matching_catalog_lines,
    sample_end_words,
    token_levenshtein_distance,
)
from lyriclib import end_rime, estimate_syllables, load_cmudict, normalize, tempo_line_syllables, tokenize, words_rhyme
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


def _vowel_bases(word: str, cmu: dict | None) -> list[str]:
    phones = (cmu or {}).get((word or "").lower())
    if not phones:
        return []
    return [phone.rstrip("012") for phone in phones if phone[-1:] in "012"]


def _phonetic_rhyme(a: str, b: str, cmu: dict | None = None) -> bool:
    """Pure rime, slant, or a multi-syllable vowel tail from the same family."""
    aw, bw = _word(a), _word(b)
    if not aw or not bw:
        return False
    if aw == bw:
        return True
    dictionary = cmu if cmu is not None else _cmu()
    if dictionary and words_rhyme(aw, bw, dictionary):
        return True
    va = _vowel_bases(aw, dictionary)
    vb = _vowel_bases(bw, dictionary)
    # Multi: the last two vowel bases match even when the coda differs.
    if len(va) >= 2 and len(vb) >= 2 and tuple(va[-2:]) == tuple(vb[-2:]):
        return True
    if va or vb:
        return False
    try:
        from catalog_build.annotate import big_phoney
        return big_phoney(aw)[1] == big_phoney(bw)[1]
    except Exception:
        return False


def _family_rhyme(word: str, family: tuple[str, ...] | list[str], cmu: dict | None = None) -> bool:
    """True when the word is in the family or slant/multi-matches a member."""
    token = _word(word)
    if not token:
        return False
    members = [_word(item) for item in family if _word(item)]
    if token in members:
        return True
    return any(_phonetic_rhyme(token, member, cmu) for member in members)


def _couplets_rhyme(
    end_words: tuple[str, ...],
    cmu: dict | None = None,
    families: tuple | list | None = None,
) -> bool:
    for i in range(0, len(end_words) - 1, 2):
        left, right = end_words[i], end_words[i + 1]
        if _phonetic_rhyme(left, right, cmu):
            continue
        family = ()
        if families and (i // 2) < len(families):
            family = families[i // 2] or ()
        if family and any(
            _phonetic_rhyme(left, member, cmu) and _phonetic_rhyme(right, member, cmu)
            for member in family
            if _word(str(member))
        ):
            continue
        return False
    return True


# A 4-bar block is one rime family. These ends are filler unless the plan named them.
FILLER_END_WORDS = frozenset({"her", "it", "this", "now", "out", "shit", "yeah"})
# Abstract ends. They fail unless the word is an end word in that artist's vault.
GREETING_END_WORDS = frozenset({
    "conversation", "hesitation", "therapeutic", "destination",
})
BLOCK_BARS = 4
_VAULT_END_CACHE: dict[str, set[str]] = {}
_VAULT_TOPIC_CACHE: dict[str, list[str]] = {}
_VAULT_TOKEN_CACHE: dict[str, set[str]] = {}
_VAULT_FAMILY_CACHE: dict[str, list] = {}
_CONCRETE_NAME_TOKENS: set[str] | None = None
_STRONG_END_TOKENS: set[str] | None = None
_PLAN_RAW_LOGGED = False
# Opt-in. Unit tests leave this off so a shared night family is not consumed.
_RUN_RHYME_ONCE = False
_RUN_RHYME_USED: dict[tuple[str, ...], int] = {}
_RUN_RHYME_EXAMPLES: dict[tuple[str, ...], list[str]] = {}

# Contractions and closed-class words are not proper names.
_NOT_A_NAME = frozenset({
    "i", "a", "im", "ima", "imma", "youre", "were", "theyre", "hes", "shes",
    "its", "thats", "whats", "whos", "lets", "ill", "ive", "id", "youll",
    "youve", "youd", "well", "weve", "wed", "theyll", "theyve", "theyd",
    "aint", "cant", "dont", "wont", "isnt", "arent", "wasnt", "werent",
    "didnt", "couldnt", "wouldnt", "shouldnt", "hasnt", "havent", "hadnt",
    "yall", "gonna", "wanna", "gotta",
    "you", "we", "they", "he", "she", "it", "me", "my", "mine", "your",
    "yours", "his", "her", "hers", "our", "ours", "their", "theirs",
    "the", "an", "and", "but", "or", "nor", "so", "if", "to", "of", "in",
    "on", "for", "with", "at", "from", "by", "as", "up", "out", "now",
    "this", "that", "these", "those", "what", "who", "when", "where",
    "why", "how", "not", "no", "just", "than",
})
# Closed-class ends that must not lead a vault rime family. "know" and "way" stay.
_FAMILY_DROP = FILLER_END_WORDS | GREETING_END_WORDS | _NOT_A_NAME | frozenset({"be", "do", "go"})
# A bar that lands on one of these is unfinished.
DANGLING_END_WORDS = frozenset({"for", "to", "of", "with", "in", "at"})
# Stock phrases from the 2026-10-30 smoke arm logs (30 verses, 3 arms).
# Earlier smoke logs were overwritten by that run. A phrase is listed when it
# occurred in 3 or more of those verses and in under 0.01% of catalog_bars
# (231,278 lines, so fewer than 23.13 lines). Whole tokens only. Grams made
# only of closed-class words are not listed. Line-final rhyme landings that
# met the count are included (the coast, like a ghost, a cell, that cheese).
_CLICHE_RAW = """
the shadows
in the shadows
shadows where
the shadows where
chasing dreams
the game of
im stacking
every move
that cheese
i rise
the coast
game of
shadows where the
every move i
in the struggle
living lavish
move i make
raise a glass
struggle we
the struggle we
through the struggle
counting all
grinding hard
through the pain
stacking up
raise a
like a ghost
make a toast
move i
counting all the
i make im
lavish every
living lavish every
make im
on the coast
paper always
paper always chasing
roots run
roots run deep
stacking chips
up the clip
im draped in
stacking all
stacking paper
the chaos
this journey
always chasing
aiming for the
im draped
run deep
we rise
dreams in
aiming for
the lost
draped in
hustle hard
living life
the finest
a cell
im the king
ready for the
"""
CLICHE_PHRASES = tuple(
    tuple(line.split()) for line in _CLICHE_RAW.splitlines() if line.strip()
)


def _block_plan_ok(end_words: tuple[str, ...] | list[str], cmu: dict | None = None) -> bool:
    """Each 4-bar block is different words from one rime family.

    A short tail still cannot repeat, and its words still share a family.
    """
    words = list(end_words)
    for start in range(0, len(words), BLOCK_BARS):
        block = words[start:start + BLOCK_BARS]
        if len(block) < 2:
            continue
        if any(not word for word in block) or len(set(block)) != len(block):
            return False
        head = block[0]
        for word in block[1:]:
            if not _phonetic_rhyme(head, word, cmu):
                return False
    return True


def _menu_families(words: list[str]) -> list[list[str]]:
    groups: list[list[str]] = []
    for word in words:
        placed = False
        for group in groups:
            if _phonetic_rhyme(group[0], word):
                if word not in group:
                    group.append(word)
                placed = True
                break
        if not placed:
            groups.append([word])
    groups.sort(key=len, reverse=True)
    return groups


def block_end_problems(
    ends: list[str] | tuple[str, ...],
    planned: list[str] | tuple[str, ...] | None = None,
) -> list[tuple[int, str, str]]:
    """(bar index, kind, word) for a repeated end or an unplanned filler."""
    problems: list[tuple[int, str, str]] = []
    planned_words = list(planned or [])
    words = [_word(word) for word in ends]
    for start in range(0, len(words), BLOCK_BARS):
        block = words[start:start + BLOCK_BARS]
        counts: dict[str, int] = {}
        for word in block:
            if word:
                counts[word] = counts.get(word, 0) + 1
        for offset, word in enumerate(block):
            index = start + offset
            if word and counts.get(word, 0) > 1:
                problems.append((index, "repeated", word))
            plan_word = _word(planned_words[index]) if index < len(planned_words) else ""
            if word in FILLER_END_WORDS and word != plan_word:
                problems.append((index, "filler", word))
    return problems


def repeated_end_block_counts(bars: list[str]) -> tuple[int, int]:
    """(blocks that repeat an end word, blocks of at least 2 bars)."""
    ends = [_word(bar) for bar in bars]
    blocks = 0
    repeats = 0
    for start in range(0, len(ends), BLOCK_BARS):
        block = [word for word in ends[start:start + BLOCK_BARS] if word]
        if len(block) < 2:
            continue
        blocks += 1
        if len(block) != len(set(block)):
            repeats += 1
    return repeats, blocks


def _widen_block_families(families, end_words: tuple[str, ...]):
    fams = [list(family) for family in families]
    for start in range(0, len(end_words), BLOCK_BARS):
        block: list[str] = []
        for word in end_words[start:start + BLOCK_BARS]:
            if word and word not in block:
                block.append(word)
        last = min(len(fams), (start + BLOCK_BARS + 1) // 2)
        for couplet in range(start // 2, last):
            for word in block:
                if word not in fams[couplet]:
                    fams[couplet].append(word)
    return tuple(tuple(item) for item in fams)


# Spec pockets: syllable ranges. The third value (old Audamar 4x4 comma count) is
# no longer enforced; commas follow COMMA_MIX measured from the vault.
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
    blob = raw[start:end + 1]
    blob = re.sub(r",\s*([}\]])", r"\1", blob)
    try:
        data = json.loads(blob)
    except json.JSONDecodeError:
        return None
    return data if isinstance(data, dict) else None


def _plan_schema(bars: int, couplets: int, allowed: list[str]) -> dict:
    """Strict object the repair retry must match. End words are menu tokens."""
    word = {"type": "string"}
    if allowed:
        word = {"type": "string", "enum": list(allowed)}
    return {
        "type": "object",
        "additionalProperties": False,
        "required": [
            "motif_chain",
            "couplet_voices",
            "end_words",
            "rhyme_families",
            "double_meaning_slots",
        ],
        "properties": {
            "motif_chain": {
                "type": "array",
                "minItems": couplets,
                "maxItems": couplets,
                "items": {"type": "string"},
            },
            "couplet_voices": {
                "type": "array",
                "minItems": couplets,
                "maxItems": couplets,
                "items": {"type": "string"},
            },
            "end_words": {
                "type": "array",
                "minItems": bars,
                "maxItems": bars,
                "items": word,
            },
            "rhyme_families": {
                "type": "array",
                "minItems": couplets,
                "maxItems": couplets,
                "items": {"type": "array", "items": {"type": "string"}},
            },
            "double_meaning_slots": {
                "type": "array",
                "items": {"type": "integer"},
            },
            "wordplay_hint_index": {"type": ["integer", "null"]},
            "wordplay_bar_index": {"type": ["integer", "null"]},
        },
    }


def _plan_response_format(schema: dict) -> dict:
    """OpenAI strict json_schema. Length checks stay in _plan_from_json."""
    cleaned = json.loads(json.dumps(schema))

    def walk(node: Any) -> None:
        if not isinstance(node, dict):
            return
        kind = node.get("type")
        if isinstance(kind, list):
            options = []
            for item in kind:
                options.append({"type": item})
            node.pop("type", None)
            node["anyOf"] = options
            for child in options:
                walk(child)
            return
        if kind == "object":
            props = node.get("properties") or {}
            node["additionalProperties"] = False
            node["required"] = list(props.keys())
            for child in props.values():
                walk(child)
        if kind == "array":
            node.pop("minItems", None)
            node.pop("maxItems", None)
            walk(node.get("items"))

    walk(cleaned)
    return {
        "type": "json_schema",
        "json_schema": {"name": "v5_plan", "strict": True, "schema": cleaned},
    }


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
    if not _block_plan_ok(end_words):
        return None
    return Plan(
        motif_chain=motifs,
        end_words=end_words,
        couplet_voices=voices,
        rhyme_families=_widen_block_families(
            _families(data.get("rhyme_families"), end_words, couplets),
            end_words,
        ),
        double_meaning_slots=_slots(voice, blend, bars, data.get("double_meaning_slots")),
        planner_model=model,
        plan_valid=True,
    )


def _catalog_rows(sql: str, params: tuple) -> list:
    """Read-only catalog rows. An empty list on a missing index or a locked read."""
    path = Path(DB_PATH)
    if not path.exists():
        return []
    try:
        conn = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    except sqlite3.Error:
        return []
    try:
        return list(conn.execute(sql, params).fetchall())
    except sqlite3.Error:
        return []
    finally:
        conn.close()


def _vault_end_words(voice: str) -> set[str]:
    """End words in the catalog artist's vault. Chief Keef uses the Lil Wayne twin."""
    key = resolve_catalog_artist(voice)
    if key in _VAULT_END_CACHE:
        return _VAULT_END_CACHE[key]
    rows = _catalog_rows(
        """
        SELECT lower(end_word)
        FROM catalog_bars
        WHERE lower(artist) = ? AND end_word != ''
        GROUP BY lower(end_word)
        """,
        (key,),
    )
    words = {str(row[0]) for row in rows if row and row[0]}
    _VAULT_END_CACHE[key] = words
    return words


def _vault_topics(voice: str) -> list[str]:
    """Catalog topic keys for this voice, most-used first. Twins apply."""
    key = resolve_catalog_artist(voice)
    if key in _VAULT_TOPIC_CACHE:
        return _VAULT_TOPIC_CACHE[key]
    rows = _catalog_rows(
        """
        SELECT topic, COUNT(*) AS n
        FROM catalog_bars
        WHERE lower(artist) = ? AND topic != ''
        GROUP BY topic
        ORDER BY n DESC
        """,
        (key,),
    )
    topics: list[str] = []
    for row in rows:
        topic = str(row[0] or "").strip()
        if topic and topic not in topics:
            topics.append(topic)
    _VAULT_TOPIC_CACHE[key] = topics
    return topics


def _vault_motifs(voice: str, topic_hint: str, couplets: int) -> tuple[str, ...] | None:
    """Couplet topics from the vault. The hint leads when it is one of those keys."""
    topics = list(_vault_topics(voice))
    hint = (topic_hint or "").strip()
    ordered: list[str] = []
    by_low = {topic.lower(): topic for topic in topics}
    if hint and hint.lower() in by_low:
        ordered.append(by_low[hint.lower()])
    elif hint and not topics:
        ordered.append(hint)
    for topic in topics:
        if topic not in ordered:
            ordered.append(topic)
    if not ordered:
        return None
    return tuple(ordered[index % len(ordered)] for index in range(max(1, couplets)))


def _own_vault_tokens(voice: str) -> set[str]:
    """Tokens in this voice's own lines. The catalog twin is not used."""
    key = (voice or "").strip().lower()
    if not key:
        return set()
    if key in _VAULT_TOKEN_CACHE:
        return _VAULT_TOKEN_CACHE[key]
    rows = _catalog_rows(
        "SELECT text FROM catalog_bars WHERE lower(artist) = ?",
        (key,),
    )
    tokens: set[str] = set()
    for row in rows:
        for token in tokenize(normalize(row[0] or "")):
            if len(token) >= 3 and token not in _NOT_A_NAME:
                tokens.add(token)
    _VAULT_TOKEN_CACHE[key] = tokens
    return tokens


def _concrete_name_tokens() -> set[str]:
    """Brand, car, jewelry, jeweler, and place tokens from the chip bank."""
    global _CONCRETE_NAME_TOKENS
    if _CONCRETE_NAME_TOKENS is not None:
        return _CONCRETE_NAME_TOKENS
    tokens: set[str] = set()
    try:
        from taste.chips import CONCRETE_CHIP_CATEGORIES, ChipIndex

        index = ChipIndex.load()
        for row in index.rows:
            if (row.get("category") or "").lower() not in CONCRETE_CHIP_CATEGORIES:
                continue
            for token in tokenize(normalize(row.get("chip") or "")):
                if len(token) >= 3 and token not in _NOT_A_NAME:
                    tokens.add(token)
    except Exception:
        tokens = set()
    _CONCRETE_NAME_TOKENS = tokens
    return tokens


def _strong_end_tokens() -> set[str]:
    """Single-word brand, car, jewelry, and jeweler chips. Not a place or a phrase tail."""
    global _STRONG_END_TOKENS
    if _STRONG_END_TOKENS is not None:
        return _STRONG_END_TOKENS
    tokens: set[str] = set()
    try:
        from taste.chips import ChipIndex

        luxury = {"brands", "cars", "jewelry", "jewelers"}
        for row in ChipIndex.load().rows:
            if (row.get("category") or "").lower() not in luxury:
                continue
            parts = tokenize(normalize(row.get("chip") or ""))
            if len(parts) != 1:
                continue
            token = parts[0]
            if len(token) >= 4 and token not in _NOT_A_NAME:
                tokens.add(token)
    except Exception:
        tokens = set()
    _STRONG_END_TOKENS = tokens
    return tokens


def greeting_end_blocked(word: str, voice: str) -> bool:
    """True only for a greeting-card end that is not a vault end word."""
    token = _word(word)
    if token not in GREETING_END_WORDS:
        return False
    return token not in _vault_end_words(voice)


def _exact_families(words: list[str]) -> list[list[str]]:
    """Group by the CMU end rime. Slant vowel-class matches stay out of the menu."""
    buckets: dict[tuple[str, ...], list[str]] = {}
    order: list[tuple[str, ...]] = []
    dictionary = _cmu()
    for word in words:
        token = _word(word)
        if not token:
            continue
        key = end_rime(token, dictionary)
        if not key:
            continue
        if key not in buckets:
            buckets[key] = []
            order.append(key)
        if token not in buckets[key]:
            buckets[key].append(token)
    groups = [buckets[key] for key in order]
    groups.sort(key=len, reverse=True)
    return groups


def _usable_family(group: list[str]) -> list[str]:
    """Drop fillers and greeting-card ends. Keep the family only when 4 words remain."""
    cleaned: list[str] = []
    for word in group:
        token = _word(word)
        if not token or token in cleaned:
            continue
        if token in FILLER_END_WORDS or token in GREETING_END_WORDS:
            continue
        cleaned.append(token)
    if len(cleaned) < BLOCK_BARS:
        return []
    strong = _strong_end_tokens()
    return sorted(cleaned, key=lambda token: (0 if token in strong else 1))


def _ranked_families(words: list[str]) -> list[list[str]]:
    """Most-used brand families first, then the longest vault rime families."""
    order: dict[str, int] = {}
    for word in words:
        token = _word(word)
        if token and token not in order:
            order[token] = len(order)
    families = []
    for group in _exact_families(words):
        usable = _usable_family(group)
        if usable:
            families.append(usable)
    strong = _strong_end_tokens()
    branded = [group for group in families if any(token in strong for token in group)]
    plain = [group for group in families if group not in branded]

    def _luxury_key(group: list[str]) -> tuple[int, int]:
        hits = [token for token in group if token in strong]
        best = min(order.get(token, 10**9) for token in hits)
        return (best, -len(group))

    branded.sort(key=_luxury_key)
    plain.sort(key=len, reverse=True)
    return branded[:3] + plain


def _planner_menu(words: list[str], bars: int) -> list[str]:
    """Families of 4+ vault rimes. A menu with no such family is returned as given."""
    ranked = _ranked_families(words)
    if not ranked:
        original: list[str] = []
        for word in words:
            token = _word(word)
            if token and token not in original:
                original.append(token)
        return original
    need = max(2, (max(bars, 1) + BLOCK_BARS - 1) // BLOCK_BARS)
    chosen = ranked[: max(need, 6)]
    ordered: list[str] = []
    for group in chosen:
        for token in group[:8]:
            if token not in ordered:
                ordered.append(token)
    return ordered


def enable_run_rhyme_once(enabled: bool = True) -> None:
    """When on, a rhyme family is used at most once per process until reset."""
    global _RUN_RHYME_ONCE
    _RUN_RHYME_ONCE = bool(enabled)


def reset_run_rhyme_families() -> None:
    """Clear the families already used in this run."""
    _RUN_RHYME_USED.clear()
    _RUN_RHYME_EXAMPLES.clear()


def run_rhyme_family_report() -> list[dict]:
    """Families noted from returned plans. count > 1 is a reuse."""
    rows = []
    for key, count in _RUN_RHYME_USED.items():
        label = "/".join(_RUN_RHYME_EXAMPLES.get(key) or [])
        rows.append({"count": count, "label": label, "rime": "-".join(key)})
    rows.sort(key=lambda row: (-row["count"], row["label"]))
    return rows


def _family_keep(token: str) -> bool:
    if not token or len(token) < 2 or token in _FAMILY_DROP:
        return False
    return True


def _group_rime(group: list[str]) -> tuple[str, ...] | None:
    dictionary = _cmu()
    for word in group:
        key = end_rime(_word(word), dictionary)
        if key:
            return tuple(key)
    return None


def _block_rime_keys(end_words: tuple[str, ...] | list[str]) -> list[tuple[str, ...] | None]:
    dictionary = _cmu()
    keys: list[tuple[str, ...] | None] = []
    words = list(end_words)
    for start in range(0, len(words), BLOCK_BARS):
        block = [word for word in words[start:start + BLOCK_BARS] if word]
        if len(block) < 2:
            continue
        key = end_rime(block[0], dictionary)
        keys.append(tuple(key) if key else None)
    return keys


def _note_run_families(end_words: tuple[str, ...] | list[str]) -> None:
    """Record the families on the plan that was returned. Off unless the run opted in."""
    if not _RUN_RHYME_ONCE:
        return
    words = list(end_words)
    dictionary = _cmu()
    for start in range(0, len(words), BLOCK_BARS):
        block = [word for word in words[start:start + BLOCK_BARS] if word]
        if len(block) < 2:
            continue
        key = end_rime(block[0], dictionary)
        if not key:
            continue
        rime = tuple(key)
        _RUN_RHYME_USED[rime] = _RUN_RHYME_USED.get(rime, 0) + 1
        sample = _RUN_RHYME_EXAMPLES.setdefault(rime, [])
        for word in block:
            if word not in sample:
                sample.append(word)


def _family_is_blocked(
    end_words: tuple[str, ...] | list[str],
    groups: list[list[str]] | None = None,
) -> bool:
    """True when this plan spends a family that is already used and a fresh one remains.

    A repeated family inside the verse is blocked. Reuse is allowed only after
    this voice's unused vault families are gone.
    """
    if not _RUN_RHYME_ONCE:
        return False
    keys = _block_rime_keys(end_words)
    known = [key for key in keys if key]
    if len(known) != len(keys):
        return False
    if len(known) != len(set(known)):
        return True
    unused: list[tuple[str, ...]] = []
    for group in groups or []:
        key = _group_rime(group)
        if key and _RUN_RHYME_USED.get(key, 0) == 0 and key not in unused:
            unused.append(key)
    fresh = {key for key in known if _RUN_RHYME_USED.get(key, 0) == 0}
    reused = [key for key in known if _RUN_RHYME_USED.get(key, 0) > 0]
    left = [key for key in unused if key not in fresh]
    return bool(reused and left)


def _families_from_song_lines(
    songs: list[list[tuple[str, int]]],
    cmu: dict | None = None,
) -> list[tuple[tuple[str, ...], list[str], int]]:
    """Rank exact end-rime families by couplet count.

    A couplet is two neighboring lines in one song (line_seq differs by 1)
    that share an exact CMU end rime. Both end words have to survive the
    drop list. A family is kept when four different words remain. Words
    inside a family are most-used first.
    """
    dictionary = _cmu() if cmu is None else cmu
    counts: dict[tuple[str, ...], int] = {}
    freqs: dict[tuple[str, ...], dict[str, int]] = {}
    for song in songs:
        index = 0
        while index + 1 < len(song):
            word_a, seq_a = song[index]
            word_b, seq_b = song[index + 1]
            if seq_b != seq_a + 1:
                index += 1
                continue
            token_a = _word(word_a)
            token_b = _word(word_b)
            if not _family_keep(token_a) or not _family_keep(token_b):
                index += 1
                continue
            key_a = end_rime(token_a, dictionary)
            key_b = end_rime(token_b, dictionary)
            if not key_a or not key_b or tuple(key_a) != tuple(key_b):
                index += 1
                continue
            rime = tuple(key_a)
            counts[rime] = counts.get(rime, 0) + 1
            bucket = freqs.setdefault(rime, {})
            bucket[token_a] = bucket.get(token_a, 0) + 1
            bucket[token_b] = bucket.get(token_b, 0) + 1
            index += 2
    ranked: list[tuple[tuple[str, ...], list[str], int]] = []
    for rime, count in counts.items():
        words = freqs[rime]
        if len(words) < BLOCK_BARS:
            continue
        ordered = sorted(words, key=lambda token: (-words[token], token))
        ranked.append((rime, ordered, count))
    ranked.sort(key=lambda item: (-item[2], item[1][0]))
    return ranked


def _vault_rhyme_families(voice: str) -> list[tuple[tuple[str, ...], list[str], int]]:
    """End-rhyme families in this artist's vault, most-used first.

    Chief Keef uses the Lil Wayne twin, the same way end words and topics do.
    The twin is not an allow-list for names.
    """
    key = resolve_catalog_artist(voice)
    if key in _VAULT_FAMILY_CACHE:
        return _VAULT_FAMILY_CACHE[key]
    rows = _catalog_rows(
        """
        SELECT COALESCE(song_id, song), line_seq, lower(end_word)
        FROM catalog_bars
        WHERE lower(artist) = ? AND end_word != ''
        ORDER BY 1, line_seq
        """,
        (key,),
    )
    songs: list[list[tuple[str, int]]] = []
    current = None
    bucket: list[tuple[str, int]] = []
    for song_key, seq, word in rows:
        if song_key != current:
            if bucket:
                songs.append(bucket)
            bucket = []
            current = song_key
        token = _word(str(word or ""))
        if not token:
            continue
        try:
            number = int(seq or 0)
        except (TypeError, ValueError):
            number = 0
        bucket.append((token, number))
    if bucket:
        songs.append(bucket)
    ranked = _families_from_song_lines(songs)
    _VAULT_FAMILY_CACHE[key] = ranked
    return ranked


def _select_family_groups(
    groups: list[list[str]],
    bars: int,
    skip_used: bool,
) -> list[list[str]]:
    """Families to show the planner. Used families stay out until the fresh ones run out."""
    need = max(2, (max(bars, 1) + BLOCK_BARS - 1) // BLOCK_BARS)
    target = max(need, 6)
    chosen: list[list[str]] = []
    chosen_keys: set[tuple[str, ...]] = set()
    for group in groups:
        key = _group_rime(group)
        if skip_used and key and _RUN_RHYME_USED.get(key, 0) > 0:
            continue
        if key and key in chosen_keys:
            continue
        chosen.append(group)
        if key:
            chosen_keys.add(key)
        if len(chosen) >= target:
            return chosen
    if len(chosen) >= need or not skip_used:
        return chosen
    rest = []
    for index, group in enumerate(groups):
        key = _group_rime(group)
        if key and key in chosen_keys:
            continue
        rest.append((_RUN_RHYME_USED.get(key, 0) if key else 0, index, group, key))
    rest.sort()
    for _count, _index, group, key in rest:
        chosen.append(group)
        if key:
            chosen_keys.add(key)
        if len(chosen) >= target:
            break
    return chosen


def _take_family_words(group: list[str], need: int, rotate: int) -> list[str] | None:
    if len(group) < need:
        return None
    start = (max(0, rotate) * need) % len(group)
    picked: list[str] = []
    for offset in range(len(group)):
        token = group[(start + offset) % len(group)]
        if token not in picked:
            picked.append(token)
        if len(picked) == need:
            return picked
    return None


def _snap_diverse(groups: list[list[str]], bars: int) -> tuple[str, ...] | None:
    """One unused vault family per block. The least-used family fills in when none are left."""
    entries = []
    for index, group in enumerate(groups):
        key = _group_rime(group)
        if key and len(group) >= 2:
            entries.append((index, key, group))
    if not entries:
        return None
    used_here: set[tuple[str, ...]] = set()
    words: list[str] = []
    while len(words) < bars:
        need = min(BLOCK_BARS, bars - len(words))
        fresh = [
            (index, key, group)
            for index, key, group in entries
            if key not in used_here and _RUN_RHYME_USED.get(key, 0) == 0 and len(group) >= need
        ]
        if fresh:
            _index, key, group = fresh[0]
        else:
            pool = [
                (_RUN_RHYME_USED.get(key, 0), index, key, group)
                for index, key, group in entries
                if key not in used_here and len(group) >= need
            ]
            if not pool:
                pool = [
                    (_RUN_RHYME_USED.get(key, 0), index, key, group)
                    for index, key, group in entries
                    if len(group) >= need
                ]
            if not pool:
                return None
            pool.sort()
            _count, _index, key, group = pool[0]
        picked = _take_family_words(group, need, _RUN_RHYME_USED.get(key, 0))
        if not picked:
            return None
        words.extend(picked)
        used_here.add(key)
    snapped = tuple(words)
    if not _block_plan_ok(snapped):
        return None
    return snapped


def _snap_from_groups(groups: list[list[str]], bars: int) -> tuple[str, ...] | None:
    """Snap onto vault-ranked families. The once-per-run flag picks a new family per block."""
    families = [list(group) for group in groups if len(group) >= 2]
    if not families:
        return None
    if _RUN_RHYME_ONCE:
        return _snap_diverse(families, bars)
    words: list[str] = []
    block_index = 0
    while len(words) < bars:
        family = families[block_index % len(families)]
        need = min(BLOCK_BARS, bars - len(words))
        if len(family) < need:
            return None
        start = (block_index * BLOCK_BARS) % len(family)
        picked: list[str] = []
        for offset in range(len(family)):
            token = family[(start + offset) % len(family)]
            if token not in picked:
                picked.append(token)
            if len(picked) == need:
                break
        if len(picked) != need:
            return None
        words.extend(picked)
        block_index += 1
    snapped = tuple(words)
    if not _block_plan_ok(snapped):
        return None
    return snapped


def cliche_hits(text: str) -> list[str]:
    """Stock phrases in this bar, longest first. Whole tokens only."""
    tokens = tokenize(normalize(text or ""))
    if len(tokens) < 2:
        return []
    found: list[str] = []
    for phrase in sorted(CLICHE_PHRASES, key=len, reverse=True):
        width = len(phrase)
        if len(tokens) < width:
            continue
        for index in range(len(tokens) - width + 1):
            if tuple(tokens[index:index + width]) == phrase:
                found.append(" ".join(phrase))
                break
    return found


def _snap_end_words(menu: list[str], bars: int) -> tuple[str, ...] | None:
    """Four distinct words from one vault rime family per block."""
    families = _ranked_families(menu)
    if not families:
        return None
    words: list[str] = []
    block_index = 0
    while len(words) < bars:
        family = families[block_index % len(families)]
        need = min(BLOCK_BARS, bars - len(words))
        if len(family) < need:
            return None
        start = (block_index * BLOCK_BARS) % len(family)
        picked: list[str] = []
        for offset in range(len(family)):
            token = family[(start + offset) % len(family)]
            if token not in picked:
                picked.append(token)
            if len(picked) == need:
                break
        if len(picked) != need:
            return None
        words.extend(picked)
        block_index += 1
    snapped = tuple(words)
    if not _block_plan_ok(snapped):
        return None
    return snapped


def _plan_reject_reason(
    data: dict,
    bars: int,
    allowed: set[str],
    family_groups: list | None = None,
) -> str:
    try:
        end_words = tuple(_word(str(word)) for word in data["end_words"])
    except (KeyError, TypeError):
        return "missing end_words"
    if len(end_words) != bars or any(not word for word in end_words):
        return f"end_words length {len(end_words)} != {bars}"
    if allowed and any(word not in allowed for word in end_words):
        missing = [word for word in end_words if word not in allowed]
        return "end_words not in menu: " + ", ".join(missing[:8])
    try:
        motifs = list(data["motif_chain"])
        voices = list(data["couplet_voices"])
    except (KeyError, TypeError):
        return "missing motif_chain or couplet_voices"
    couplets = _couplets(bars)
    if len(motifs) != couplets or len(voices) != couplets:
        return "motif or voice length"
    if not _couplets_rhyme(end_words):
        return "couplets do not rhyme"
    if not _block_plan_ok(end_words):
        return "4-bar block is not one rime family"
    if _family_is_blocked(end_words, family_groups):
        return "rhyme family already used in this run"
    return "rejected"


def _log_rejected_plan(text: str, reason: str) -> None:
    """One raw body per process. Later rejects stay off the log."""
    global _PLAN_RAW_LOGGED
    if _PLAN_RAW_LOGGED:
        return
    _PLAN_RAW_LOGGED = True
    body = (text or "").strip().replace("\n", " ")
    if len(body) > 1500:
        body = body[:1500] + "..."
    print(f"[frontier_v5] plan raw response ({reason}): {body}", file=sys.stderr)


def _retopic(plan: Plan, voice: str, topic_hint: str) -> Plan:
    motifs = _vault_motifs(voice, topic_hint, len(plan.motif_chain) or _couplets(len(plan.end_words)))
    if not motifs or motifs == plan.motif_chain:
        return plan
    return Plan(
        motif_chain=motifs,
        end_words=plan.end_words,
        couplet_voices=plan.couplet_voices,
        rhyme_families=plan.rhyme_families,
        double_meaning_slots=plan.double_meaning_slots,
        planner_model=plan.planner_model,
        plan_valid=plan.plan_valid,
    )


def _snap_plan(
    data: dict,
    shape: Shape,
    voice: str,
    blend: str,
    topic_hint: str,
    menu: list[str],
    model: str,
    voices: list[str],
    family_groups: list | None = None,
) -> Plan | None:
    if family_groups:
        end_words = _snap_from_groups(family_groups, shape.bar_count)
    else:
        end_words = _snap_end_words(menu, shape.bar_count)
    if not end_words:
        return None
    couplets = _couplets(shape.bar_count)
    motifs = _vault_motifs(voice, topic_hint, couplets)
    if not motifs:
        hint = (topic_hint or "").strip()
        motifs = tuple((hint or "vault") for _ in range(couplets))
    voice_row = tuple(str(item) for item in voices[:couplets])
    while len(voice_row) < couplets:
        voice_row = voice_row + (voice,)
    return Plan(
        motif_chain=motifs,
        end_words=end_words,
        couplet_voices=voice_row,
        rhyme_families=_widen_block_families(_families(None, end_words, couplets), end_words),
        double_meaning_slots=_slots(
            voice, blend, shape.bar_count, data.get("double_meaning_slots") if isinstance(data, dict) else (),
        ),
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


def _call_model(
    call_fn: Callable[[str, str], str] | None,
    model: str,
    system: str,
    user: str,
    response_format: dict | None = None,
) -> str:
    if call_fn is not None:
        return call_fn(system, user) or ""
    from llm_client import chat

    return chat(
        model=model,
        system=system,
        user=user,
        max_tokens=900,
        temperature=0.4,
        response_format=response_format,
    ) or ""


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
    plan_extras: dict | None = None,
) -> Plan:
    """Stage 2. End words come from the catalog menu. The plan is not edited later."""

    def _finish(plan: Plan) -> Plan:
        _note_run_families(plan.end_words)
        return plan

    # Live plans use this artist's vault end-rhyme families, ranked by how
    # often that family closes a couplet. A passed-in sample_fn keeps the
    # old menu so the planner tests stay on their fixture.
    allowed: list[str] = []
    shown_groups: list[list[str]] | None = None
    family_groups: list[list[str]] | None = None
    if sample_fn is None:
        ranked = _vault_rhyme_families(voice)
        if ranked:
            family_groups = [words for _rime, words, _count in ranked]
            shown_groups = _select_family_groups(
                family_groups, shape.bar_count, skip_used=_RUN_RHYME_ONCE,
            )
            for group in shown_groups:
                for token in group[:8]:
                    if token not in allowed:
                        allowed.append(token)
            if not allowed:
                family_groups = None
                shown_groups = None
    if not allowed:
        sampler = sample_fn or sample_end_words
        # Deep menu so a rare vault end (patek, maybach) can join its rime family.
        menu_count = max(shape.bar_count, 4000)
        menu = list(sampler(voice, count=menu_count, dedupe_window=16) or [])
        if blend and blend.strip().lower() != voice.strip().lower():
            menu.extend(sampler(blend, count=menu_count, dedupe_window=16) or [])
        raw_allowed = []
        for word in menu:
            token = _word(word)
            if token and token not in raw_allowed:
                raw_allowed.append(token)
        if not raw_allowed:
            print("[frontier_v5] plan catalog menu empty; using the v3 motif fallback", file=sys.stderr)
            return _finish(_fallback_plan(shape, voice, blend, mix, topic_hint))
        allowed = _planner_menu(raw_allowed, shape.bar_count)

    couplets = _couplets(shape.bar_count)
    voices = [voice] * couplets
    try:
        from polish import allocate_bar_artists
        artists = allocate_bar_artists(voice=voice, blend=blend, mix=mix, bars_count=shape.bar_count)
        voices = [artists[min(index * 2, len(artists) - 1)] for index in range(couplets)]
    except Exception:
        voices = [voice] * couplets
    if shown_groups:
        family_block = "\n".join("- " + ", ".join(group[:8]) for group in shown_groups)
        family_note = (
            "These families are this voice's vault end-rhyme families, most-used first. "
            "Use each family at most once.\n"
        )
    else:
        family_block = "\n".join(
            "- " + ", ".join(group[:8])
            for group in _exact_families(allowed)
            if len(group) >= 2
        )
        family_note = ""
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
        f"end_words has length {shape.bar_count}.\n"
        "Rhyme rule: each 4-bar block (bars 0-3, then 4-7) uses 4 DIFFERENT menu words "
        "from ONE rime family. Do not repeat an end word inside a block. "
        "The next block uses a different family. "
        "Skip filler end words (her, it, this, now, out, shit, yeah) when another "
        "menu word shares that family. Do not use conversation, hesitation, "
        "therapeutic, or destination.\n"
        "motif_chain values are this voice's catalog topic keys. "
        "Start with the Topic above when it is one of them.\n"
        + family_note
        + "Menu rime families:\n"
        + family_block
    )
    catalog_topics = _vault_topics(voice)
    if catalog_topics:
        user += "\nCatalog topics: " + ", ".join(catalog_topics[:12])
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
        block_lines.append(
            "Add a JSON key `wordplay_hint_index` (int 1..N) naming which "
            "example you chose, or null if you did not use any. Add a JSON key "
            "`wordplay_bar_index` (0..bars-1) naming the bar that lands the "
            "payoff, or null."
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
            "Prefer brands, cars, jewelry, and places. "
            "Use a chip whose rime matches the plan. Do not copy any example bar text."
        )
        user = user + "\n" + "\n".join(chip_block)
    model = "custom_call_fn" if call_fn else PLAN_MODEL
    schema = _plan_schema(shape.bar_count, couplets, allowed)

    def _accept(data: dict | None) -> Plan | None:
        if not data:
            return None
        plan = _plan_from_json(data, shape.bar_count, voice, blend, set(allowed), model)
        if plan is None:
            return None
        if _family_is_blocked(plan.end_words, family_groups):
            return None
        if plan_extras is not None:
            plan_extras["end_words"] = list(plan.end_words)
            plan_extras["rhyme_families"] = [list(family) for family in plan.rhyme_families]
            raw_idx = data.get("wordplay_hint_index")
            if isinstance(raw_idx, int) and wordplay_hints and 1 <= raw_idx <= len(wordplay_hints):
                plan_extras["wordplay_hint_index"] = raw_idx - 1  # convert to 0-based
            raw_bar = data.get("wordplay_bar_index")
            if isinstance(raw_bar, int) and 0 <= raw_bar < shape.bar_count:
                plan_extras["wordplay_bar_index"] = raw_bar
        return plan

    last_text = ""
    for _attempt in range(2):
        try:
            text = _call_model(call_fn, PLAN_MODEL, system, user)
        except Exception as exc:
            print(f"[frontier_v5] plan call failed: {exc}", file=sys.stderr)
            text = ""
        last_text = text or last_text
        plan = _accept(_parse_json(text))
        if plan is not None:
            return _finish(_retopic(plan, voice, topic_hint))
    repair_system = (
        "You repair a rap-verse plan. Return one JSON object and no other text. "
        "The object must match the strict schema. End words must be copied from the enum."
    )
    repair_user = (
        "STRICT SCHEMA\n"
        f"{json.dumps(schema)}\n"
        "Repair the previous output into that schema. "
        f"end_words length {shape.bar_count}. motif_chain, couplet_voices, and "
        f"rhyme_families length {couplets}. Each 4-bar block is 4 DIFFERENT menu "
        "words from one rime family. Do not repeat an end word inside a block.\n"
        f"Previous output:\n{last_text or '(empty)'}"
    )
    repaired = ""
    try:
        repaired = _call_model(
            call_fn,
            PLAN_MODEL,
            repair_system,
            repair_user,
            response_format=_plan_response_format(schema),
        )
    except Exception as exc:
        print(f"[frontier_v5] plan schema call failed: {exc}", file=sys.stderr)
        try:
            repaired = _call_model(call_fn, PLAN_MODEL, repair_system, repair_user)
        except Exception as exc2:
            print(f"[frontier_v5] plan repair call failed: {exc2}", file=sys.stderr)
            repaired = ""
    parsed = _parse_json(repaired) or _parse_json(last_text)
    plan = _accept(parsed)
    if plan is not None:
        return _finish(_retopic(plan, voice, topic_hint))
    # Schema-valid JSON can still miss the 4-bar rime rule. Snap it onto a
    # vault family. Unparseable text keeps the v3 fallback.
    if isinstance(parsed, dict):
        reason = _plan_reject_reason(
            parsed, shape.bar_count, set(allowed), family_groups,
        )
        _log_rejected_plan(repaired or last_text, reason)
        snapped = _snap_plan(
            parsed, shape, voice, blend, topic_hint, allowed, model, voices,
            family_groups=family_groups,
        )
        if snapped is not None:
            return _finish(snapped)
    print("[frontier_v5] plan JSON failed after schema repair; using the v3 motif fallback", file=sys.stderr)
    return _finish(_fallback_plan(shape, voice, blend, mix, topic_hint))


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


# The edit prompt does not include vault line text. Novelty checks copying.
WRITER_SEES_VAULT_LINES = False


def _load_comma_mix() -> dict:
    """Comma mix measured from the vault (docs/flow-rules/gunna_stats.json).

    Falls back to the measured Gunna solo numbers if the stats file is absent.
    """
    fallback = {"rates": {"0": 0.4425, "1": 0.4065, "2": 0.1119, "3": 0.039},
                "median_rel": 0.56}
    try:
        stats_path = Path(__file__).resolve().parents[2] / "docs" / "flow-rules" / "gunna_stats.json"
        data = json.loads(stats_path.read_text())
        block = data.get("commas_solo") or data.get("commas") or {}
        rates = block.get("0_1_2_3plus_rates") or fallback["rates"]
        rel = (block.get("relative_position_quartiles") or {}).get("median", fallback["median_rel"])
        return {"rates": rates, "median_rel": float(rel)}
    except Exception:
        return fallback


COMMA_MIX = _load_comma_mix()


def _vault_comma_pattern(line: "CatalogLine | None") -> str:
    """Where commas fall in the matched vault line, as positions only (no text)."""
    text = getattr(line, "text", "") or ""
    if not text:
        return ""
    words = text.split()
    if not words:
        return ""
    spots = [round(100 * (i + 1) / len(words)) for i, w in enumerate(words[:-1]) if w.endswith(",")]
    if not spots:
        return "Matched vault bar breathes with no comma."
    where = ", ".join(f"~{pct}% in" for pct in spots)
    return f"Matched vault bar has {len(spots)} comma(s) at {where}."


def _comma_rule(shape: Shape, line: "CatalogLine | None" = None) -> str:
    """Optional vault guidance. A missing comma never fails and is never inserted."""
    del shape
    rates = COMMA_MIX.get("rates") or {}

    def pct(key: str) -> int:
        try:
            return round(100 * float(rates.get(key, 0)))
        except (TypeError, ValueError):
            return 0

    median = float(COMMA_MIX.get("median_rel") or 0)
    base = (
        "Comma rule: optional, from the vault. Put a comma only where the voice breathes. "
        f"Real bars: {pct('0')}% none, {pct('1')}% one, {pct('2')}% two, "
        f"{pct('3')}% three or more. When there is one it usually falls about "
        f"{round(100 * median)}% of the way into the bar, at a phrase break, "
        "never between a word and the noun it describes. No comma after the end word."
    )
    pattern = _vault_comma_pattern(line)
    return f"{base} {pattern}".strip()


def _rime_label(word: str) -> str:
    token = _word(word)
    if not token:
        return "unknown"
    phones = end_rime(token, _cmu())
    if not phones:
        return "unknown"
    return "-".join(phones)


def _edit_prompt(
    plan: Plan,
    scaffold: tuple[CatalogLine, ...],
    shape: Shape,
    voice: str,
    taste: str,
    only_index: int | None,
    violations: list[str] | None,
    wordplay_pick: dict | None = None,
    wordplay_bar_index: int | None = None,
    chip_hints: list[dict] | None = None,
    topic: str = "",
) -> str:
    """Writer brief: rimes, syllable targets, topic, and chips. No vault line text.

    `taste`, `wordplay_pick`, and `scaffold` stay in the signature so callers
    do not break. Their line text is not written into this prompt.
    """
    del taste, wordplay_pick, wordplay_bar_index
    indexes = [only_index] if only_index is not None else list(range(len(scaffold)))
    blocks = [
        f"Topic: {topic or 'none'}",
        _comma_rule(shape),
        "Write a new bar for each number. Do not reproduce a catalog line.",
        "End-word rule: each 4-bar block uses 4 different end words from one rime family. "
        "Do not repeat an end word in the block. Do not end on her, it, this, now, out, "
        "shit, or yeah unless that word is the planned end word. "
        "Do not end on conversation, hesitation, therapeutic, or destination unless "
        "that word is an end word in this voice's vault lines.",
        "Finish the bar. Do not end on for, to, of, with, in, or at.",
        "Do not use these stock phrases: "
        + ", ".join(" ".join(phrase) for phrase in CLICHE_PHRASES)
        + ".",
    ]
    if only_index is not None:
        blocks.append("retry this bar only — REWRITE it, do not reuse this phrasing")
        blocks.append("violations: " + ", ".join(violations or []))
    for index in indexes:
        line = scaffold[index]
        end_word = plan.end_words[index] if index < len(plan.end_words) else line.end_word
        couplet = index // 2
        motif = plan.motif_chain[couplet] if couplet < len(plan.motif_chain) else ""
        bar_topic = topic or motif or "none"
        blocks.append(
            f"Bar {index + 1}\n"
            f"  end word: {end_word}\n"
            f"  end rime: {_rime_label(end_word)}\n"
            f"  syllable target: {shape.syl_budget} (±1)\n"
            f"  topic: {bar_topic}\n"
            f"  {_vault_comma_pattern(line)} Land on the end word. "
            "Use new wording. Do not quote a vault line."
        )
    if chip_hints:
        chip_lines = []
        for chip in chip_hints[:6]:
            name = chip.get("chip") or "?"
            rime = "-".join(chip.get("end_rime") or []) or "?"
            chip_lines.append(f"{name} (rime {rime})")
        blocks.append("Chips (use 1-2 as whole words, not as a substring of a longer word): " + ", ".join(chip_lines))
    blocks.append("Return one line per bar, prefixed with its bar number.")
    return "\n\n".join(blocks)


_BAR_LABEL_ONLY = re.compile(r"^bar\s*,?\s*\d+\s*[:.\-—]*\s*$", re.IGNORECASE)
_BAR_LABEL_PREFIX = re.compile(r"^bar\s*,?\s*(\d+)\s*[:.\-—]+\s*(.*)$", re.IGNORECASE)


def strip_bar_label_line(line: str) -> str | None:
    """Drop a bare `Bar N` line. Strip a `Bar N:` prefix. None means drop the line."""
    text = (line or "").strip()
    if not text or text.startswith("```"):
        return None
    text = text.strip('"').strip("'").strip()
    if _BAR_LABEL_ONLY.match(text):
        return None
    match = _BAR_LABEL_PREFIX.match(text)
    if match:
        body = match.group(2).strip()
        return body or None
    text = re.sub(r"^\d+\.\s+", "", text).strip()
    return text or None


def strip_bar_labels(text: str) -> list[str]:
    """Lyric lines only. A `Bar N` line is not a bar."""
    lines = []
    for raw in (text or "").splitlines():
        cleaned = strip_bar_label_line(raw)
        if cleaned:
            lines.append(cleaned)
    return lines


def _parse_edit_lines(text: str, expected: int) -> list[str]:
    found: dict[int, str] = {}
    plain: list[str] = []
    for raw in (text or "").splitlines():
        line = (raw or "").strip()
        if not line or line.startswith("```"):
            continue
        line = line.strip('"').strip("'").strip()
        if _BAR_LABEL_ONLY.match(line):
            continue
        match = _BAR_LABEL_PREFIX.match(line)
        if match and match.group(2).strip():
            found[int(match.group(1))] = match.group(2).strip()
            continue
        if match:
            continue
        cleaned = re.sub(r"^\d+\.\s+", "", line).strip()
        if cleaned:
            plain.append(cleaned)
    if found and not plain:
        return [found.get(index + 1, "") for index in range(expected)]
    if found:
        slots = [found.get(index + 1, "") for index in range(expected)]
        extras = iter(plain)
        for index, slot in enumerate(slots):
            if not slot:
                slots[index] = next(extras, "")
        return slots
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
    wordplay_pick: dict | None = None,
    wordplay_bar_index: int | None = None,
    chip_hints: list[dict] | None = None,
    topic: str = "",
) -> Verse:
    """Stage 4. One polish pass. The prompt has no vault line. An empty bar keeps the end word."""
    system = (
        "You write new rap bars from an end-word rime, a syllable target, a topic, and chips. "
        "You are not given a catalog line. Do not reproduce a remembered bar. "
        "Return one line per bar, prefixed with its bar number."
    )
    user = _edit_prompt(plan, scaffold, shape, voice, taste, only_index, violations,
                       wordplay_pick=wordplay_pick,
                       wordplay_bar_index=wordplay_bar_index,
                       chip_hints=chip_hints,
                       topic=topic)
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
        end_word = plan.end_words[index] if index < len(plan.end_words) else line.end_word
        if only_index is not None and index != only_index:
            chosen = previous
        else:
            edited = parsed[index] if index < len(parsed) else ""
            if only_index is not None and not edited and parsed:
                edited = parsed[0]
            chosen = edited or previous
        if not chosen.strip():
            chosen = end_word
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
    """Exact family member, or a pure, slant, or multi rime against one member."""
    return _family_rhyme(end_word, family, cmu)


def repair_bar_commas(text: str, shape: Shape, cmu: dict | None = None) -> str:
    """Strip a trailing comma after the end word. Never insert a comma."""
    del shape, cmu
    if text.rstrip().endswith(","):
        return re.sub(r"[,\s]+$", "", text.rstrip())
    return text


def _unknown_names(text: str, voice: str) -> list[str]:
    try:
        from catalog_build.annotate import _whitelist
        allowed = set(_whitelist(voice))
    except Exception:
        allowed = set()
    for part in (voice or "").split():
        token = _word(part)
        if token:
            allowed.add(token)
    allowed.update(_concrete_name_tokens())
    allowed.update(_own_vault_tokens(voice))
    tokens = set(tokenize(normalize(text)))
    bad = []
    for index, raw in enumerate(text.split()):
        if index == 0:
            continue
        piece = raw.strip(".,;:!?\"'")
        if len(piece) < 2 or not piece[0].isupper():
            continue
        token = _word(piece)
        if token and token not in _NOT_A_NAME and token in tokens and token not in allowed:
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
    soft_codes: set[str] | None = None,
) -> dict[str, Any]:
    """One bar, every check. The checks do not depend on each other.

    `soft_codes` logs a score penalty instead of a hard failure. Smoke uses
    this for syllables and inner rhyme. End rhyme and name guard stay hard.
    A missing comma never fails.
    """
    dictionary = _cmu() if cmu is None else cmu
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
    bar_voice = scaffold.artist or ""
    couplet = index // 2
    if couplet < len(plan.couplet_voices) and plan.couplet_voices[couplet]:
        bar_voice = plan.couplet_voices[couplet]
    names = _unknown_names(text, bar_voice)
    punch = check_punch_demoted(text, end_word)
    commas = text.count(",")
    codes = []
    if scaffold.scaffold_source == "bank":
        codes.append("bank")
    # Distance is telemetry. The writer is not shown the vault line, so the
    # distance is not a failing gate. Novelty covers copying.
    if WRITER_SEES_VAULT_LINES and distance > cap_tokens:
        codes.append("scaffold")
    planned = _word(end_word)
    family_words = tuple(family) if family else ((planned,) if planned else ())
    slant_ok = _family_rhyme(actual_end, family_words, dictionary)
    if not rhyme_ok:
        codes.append("rhyme_family")
    if actual_end != planned and not slant_ok:
        codes.append("end_word")
    if greeting_end_blocked(actual_end, bar_voice):
        codes.append("vault_end")
    if (not rhyme_ok) or (actual_end != planned and not slant_ok):
        print(
            f"[frontier_v5] end-rhyme miss bar={index + 1} "
            f"planned={planned or 'none'} actual={actual_end or 'none'}",
            file=sys.stderr,
        )
    soft = {str(code) for code in (soft_codes or ())}
    penalties: list[str] = []
    if not (2 <= inner_count <= 4):
        if "inner_rhyme" in soft:
            penalties.append("inner_rhyme")
            print(
                f"[frontier_v5] soft inner_rhyme bar={index + 1} "
                f"count={inner_count} penalty=1.0",
                file=sys.stderr,
            )
        else:
            codes.append("inner_rhyme")
    if abs(delta) > 1:
        if "syllables" in soft:
            penalties.append("syllables")
            print(
                f"[frontier_v5] soft syllables bar={index + 1} "
                f"actual={actual_syl} target={shape.syl_budget} penalty=1.0",
                file=sys.stderr,
            )
        else:
            codes.append("syllables")
    # Commas are optional vault guidance. A missing comma never fails.
    hits = cliche_hits(text)
    if hits:
        codes.append("cliche")
        print(
            f"[frontier_v5] cliche bar={index + 1} phrase={hits[0]}",
            file=sys.stderr,
        )
    if actual_end in DANGLING_END_WORDS:
        codes.append("incomplete")
        print(
            f"[frontier_v5] incomplete end bar={index + 1} word={actual_end}",
            file=sys.stderr,
        )
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
        "cliche_phrases": hits,
        "plan_hit": not codes,
        "planned_end": planned,
        "actual_end": actual_end,
        "penalties": penalties,
        "soft_penalty": float(len(penalties)),
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
    soft_codes: set[str] | None = None,
) -> VerifiedVerse:
    """Stage 5. One gate. A miss retries that bar only, inside one shared budget."""
    dictionary = _cmu() if cmu is None else cmu
    budget = _retry_budget(max_retries)
    editor = edit_fn or edit_v5
    current = verse
    used = 0
    exhausted = False

    def _repair(target: Verse) -> None:
        for bar in target.bars:
            cleaned = strip_bar_label_line(bar.text)
            # A bare "Bar N" line is not the lyric. Land on the planned end word.
            bar.text = cleaned if cleaned is not None else (bar.end_word or "")
            bar.text = repair_bar_commas(bar.text, shape, dictionary)

    def _measure(target: Verse) -> list[dict]:
        _repair(target)
        rows = [
            measure_bar(
                bar.index, bar.text, plan, scaffold[bar.index], shape,
                dictionary, syllable_fn, inner_fn, rhyme_fn, soft_codes,
            )
            for bar in target.bars
        ]
        by_index = {row["bar_index"]: row for row in rows}
        for index, kind, word in block_end_problems(
            [bar.text for bar in target.bars], plan.end_words,
        ):
            row = by_index.get(index)
            if row is None:
                continue
            if "end_word" not in row["codes"]:
                row["codes"].append("end_word")
            row["end_word_ok"] = False
            row["plan_hit"] = False
            if kind == "repeated":
                print(
                    f"[frontier_v5] repeated end word bar={index + 1} "
                    f"word={word} block={index // BLOCK_BARS + 1}",
                    file=sys.stderr,
                )
            else:
                print(
                    f"[frontier_v5] filler end word bar={index + 1} word={word} "
                    f"planned={row.get('planned_end') or 'none'}",
                    file=sys.stderr,
                )
        return rows

    measures = _measure(current)
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
        extra = [f"stock phrase: {phrase}" for phrase in (target.get("cliche_phrases") or [])]
        if target.get("actual_end") in DANGLING_END_WORDS:
            extra.append(f"bar ends on {target.get('actual_end')}")
        current = editor(
            plan,
            scaffold,
            shape,
            voice,
            taste=taste,
            call_fn=call_fn,
            only_index=target["bar_index"],
            violations=list(target["codes"]) + extra,
            verse=current,
        )
        used += 1
        measures = _measure(current)
    else:
        if any(item["codes"] and "bank" not in item["codes"] for item in measures):
            exhausted = True
    if any(item["codes"] for item in measures) and used >= budget:
        exhausted = True
    violations = []
    for item in measures:
        if not item["codes"]:
            continue
        row = {"bar_index": item["bar_index"], "codes": list(item["codes"])}
        if "end_word" in item["codes"] or "rhyme_family" in item["codes"]:
            row["planned_end"] = item.get("planned_end") or ""
            row["actual_end"] = item.get("actual_end") or ""
        violations.append(row)
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
            base = float(score_fn(text))
            penalty = sum(float(measure.get("soft_penalty") or 0.0) for measure in (item.measures or []))
            if base != float("-inf"):
                base -= penalty
            item.style_score = base
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
        "soft_penalty": sum(float(measure.get("soft_penalty") or 0.0) for measure in winner.measures),
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


def _stamp_usage(result: dict[str, Any], tracker) -> None:
    events = list(getattr(tracker, "events", []) or [])
    result["prompt_tokens"] = sum(int(event.get("prompt_tokens") or 0) for event in events)
    result["completion_tokens"] = sum(int(event.get("completion_tokens") or 0) for event in events)
    result["thinking_tokens"] = sum(int(event.get("thinking_tokens") or 0) for event in events)
    result["cost_usd"] = round(float(tracker.total_usd()), 6)


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
    soft_codes: set[str] | None = None,
) -> dict[str, Any]:
    """Run the pre-gate and the seven stages. A cache hit returns the saved verse."""
    gid = generation_id or f"v5_{int(time.time())}_{uuid.uuid4().hex[:8]}"
    from cost_tracker import CostTracker, bind_cost_tracker, unbind_cost_tracker, current

    tracker = current()
    token = None
    if tracker is None:
        tracker = CostTracker(gid)
        token = bind_cost_tracker(tracker)
    try:
        result = _generate_v5_inner(
            user_input,
            voice=voice,
            blend=blend,
            mix=mix,
            chosen_albums=chosen_albums,
            topic_hint=topic_hint,
            use_cache=use_cache,
            call_fn=call_fn,
            candidates=candidates,
            generation_id=gid,
            sample_fn=sample_fn,
            retrieve_fn=retrieve_fn,
            score_fn=score_fn,
            gate_open=gate_open,
            telemetry_path=telemetry_path,
            history_path=history_path,
            cache_dir=cache_dir,
            db_path=db_path,
            max_retries=max_retries,
            syllable_fn=syllable_fn,
            inner_fn=inner_fn,
            rhyme_fn=rhyme_fn,
            cmu=cmu,
            soft_codes=soft_codes,
        )
        if token is not None and isinstance(result, dict) and not result.get("cached"):
            _stamp_usage(result, tracker)
        return result
    finally:
        if token is not None:
            unbind_cost_tracker(token)


def _generate_v5_inner(
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
    soft_codes: set[str] | None = None,
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
        plan_extras=user.get("plan_extras"),
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
    # Pull the planner's chosen wordplay example (if any) so the editor and
    # retry editor can target it. plan_extras is a mutable dict passed in by
    # the caller (generate_judged) and populated by _plan_from_json.
    plan_extras_in = user.get("plan_extras") or {}
    wp_hints = user.get("wordplay_hints") or []
    wp_idx = plan_extras_in.get("wordplay_hint_index")
    wordplay_pick = (wp_hints[wp_idx] if isinstance(wp_idx, int)
                     and 0 <= wp_idx < len(wp_hints) else None)
    wordplay_bar_index = plan_extras_in.get("wordplay_bar_index")
    chip_hints_in = user.get("chip_hints") or []

    import functools as _ft
    bound_edit = _ft.partial(edit_v5, wordplay_pick=wordplay_pick,
                             wordplay_bar_index=wordplay_bar_index,
                             chip_hints=chip_hints_in,
                             topic=topic)

    for _take in range(takes):
        draft = bound_edit(plan, scaffold, shape, voice, taste=taste, call_fn=call_fn)
        verified_list.append(verify_v5(
            draft,
            plan,
            scaffold,
            shape,
            voice,
            taste=taste,
            call_fn=call_fn,
            edit_fn=bound_edit,
            max_retries=max_retries,
            cmu=cmu,
            syllable_fn=syllable_fn,
            inner_fn=inner_fn,
            rhyme_fn=rhyme_fn,
            soft_codes=soft_codes,
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


def _bar_tokens(text: str) -> list[str]:
    """Whitespace words. Internal hyphens stay, so a stutter is one word."""
    tokens = []
    for raw in (text or "").lower().split():
        token = raw.strip(".,;:!?\"'()[]{}")
        if token:
            tokens.append(token)
    return tokens


def chip_matches_bar(chip: str, text: str) -> bool:
    """Whole-word chip hit. 'rat' does not match 'ratchet'."""
    needles = _bar_tokens(chip)
    if not needles:
        return False
    hay = _bar_tokens(text)
    width = len(needles)
    if len(hay) < width:
        return False
    for index in range(len(hay) - width + 1):
        if hay[index:index + width] == needles:
            return True
    return False


def _hard_check_bars(bars: list[str], voice: str, cmu: dict | None = None,
                     chip_words: list[str] | None = None,
                     shown_examples: list[str] | None = None,
                     novelty_on: bool = True,
                     rhyme_families: tuple | list | None = None,
                     planned_ends: list[str] | tuple | None = None) -> dict:
    """Return {'ok': bool, 'reasons': [str], 'novelty': {...}}.

    Hard rules (any one trips rejection). A missing comma is not one of them:
      - a 4-bar block repeats an end word, or a bar ends on an unplanned filler
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
    # end-rhyme couplets, plus identical ends and unplanned fillers
    try:
        ends = tuple(_word(b.rstrip(".,!?;:").split()[-1]) if b.strip() else "" for b in bars)
        if not _couplets_rhyme(ends, cmu or _cmu(), rhyme_families):
            reasons.append("end-rhyme couplet failure")
        seen_blocks = set()
        for index, kind, word in block_end_problems(ends, planned_ends or ()):
            if kind == "repeated":
                block = index // BLOCK_BARS + 1
                if block not in seen_blocks:
                    seen_blocks.add(block)
                    reasons.append(f"repeated end word in 4-bar block {block}")
            else:
                reasons.append(f"filler end word {word} bar {index}")
        for index, end in enumerate(ends):
            if greeting_end_blocked(end, voice):
                reasons.append(f"greeting-card end word {end} bar {index}")
    except Exception as exc:
        reasons.append(f"end-rhyme check error: {exc}")
    for index, bar in enumerate(bars):
        hits = cliche_hits(bar)
        if hits:
            reasons.append(f"cliche {hits[0]} bar {index}")
        end = _word(bar)
        if end in DANGLING_END_WORDS:
            reasons.append(f"incomplete end word {end} bar {index}")
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
    use_cache: bool = False,  # judged ≠ baseline — don't return cached unjudged verse
    **kwargs,
) -> dict[str, Any]:
    """Best-of-N wrapper over generate_v5.

    Hard checks (any trips rejection, no candidate shown). A missing comma is not one:
      - a 4-bar block repeats an end word, or a bar ends on an unplanned filler
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
                menu = list(sample_end_words(
                    voice, count=max(shape_preview.bar_count, 32), dedupe_window=16,
                ) or [])
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
    # plan_extras: shared dict so _plan_from_json can report the planner's
    # wordplay pick back to us (edited in-place inside plan_v5).
    plan_extras: dict = {}
    user_payload["plan_extras"] = plan_extras

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
                if chip_matches_bar(ch, text):
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
                                novelty_on=use_novelty,
                                rhyme_families=plan_extras.get("rhyme_families"),
                                planned_ends=plan_extras.get("end_words"))
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
        topic_hint=topic_hint, score_fn=_score, use_cache=use_cache, **kwargs,
    )
    # The planner may have named one of the hints as its chosen pattern;
    # surface that in the result (fall back to None, NOT hints[0]).
    chosen_idx = plan_extras.get("wordplay_hint_index")
    if isinstance(chosen_idx, int) and 0 <= chosen_idx < len(hints):
        pattern = {k: hints[chosen_idx].get(k) for k in
                   ("tab", "artist", "song", "line", "setup", "play", "heard_as")}
        pattern["chosen_hint_index"] = chosen_idx
    else:
        pattern = None
    bars_out = [ln.strip() for ln in (result.get("raw_text") or "").splitlines() if ln.strip()]
    hard = _hard_check_bars(
        bars_out, voice,
        chip_words=chip_words,
        shown_examples=shown_examples,
        novelty_on=use_novelty,
        rhyme_families=(result.get("plan") or {}).get("rhyme_families")
        or plan_extras.get("rhyme_families"),
        planned_ends=(result.get("plan") or {}).get("end_words")
        or plan_extras.get("end_words"),
    )
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
