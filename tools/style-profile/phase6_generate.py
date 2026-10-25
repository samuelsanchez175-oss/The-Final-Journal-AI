#!/usr/bin/env python3
"""AI Sparkler Phase 6: verse generation grounded in the artist's real lyrics.

Writes the whole verse in one model call so the rhyme scheme can be planned, seeds the
prompt with real passages by the artist (topic-matched where Phase 4 labels exist), then
checks every bar with CMUdict and retries with the measured violations.

Usage:
  python3 tools/style-profile/phase6_generate.py --artist "Gunna" --bars 4 --model opus
  python3 tools/style-profile/phase6_generate.py --artist "Gunna" --topic money_flex --scheme abab
  python3 tools/style-profile/phase6_generate.py --artist "Gunna" --mode mimic --bars 8 --closeness 0.7
  python3 tools/style-profile/phase6_generate.py --artist "Gunna" --mode mimic --bars 8 --sets 10 --seed 1 --out tools/style-profile/out/rater-batch
  python3 tools/style-profile/phase6_generate.py --artist "Gunna" --mode mimic --bars 8 --sets 25 --seed 11 --out tools/style-profile/out/rater-batch
  python3 tools/style-profile/phase6_generate.py --artist "Gunna" --mode mimic --bars 8 --closeness 0.7 --candidates 8 --sets 25 --seed 11 --caller omni --out tools/style-profile/out/rater-batch
  python3 tools/style-profile/phase6_generate.py self-check
"""

from __future__ import annotations

import argparse
import json
import random
import re
import socket
import sqlite3
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import phase1_song_metrics as p1
import phase4_topic_chain as p4
import feedback_store
import anchor_lib
import gunna_score
import style_scorer

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

SCHEMA_VERSION = "phase6.v2"
PROMPT_VERSION = "verse.v5"
MODELS = ("haiku", "sonnet", "opus")
MODEL_DEFAULT = "sonnet"
SCHEMES = ("aabb", "abab")
MODES = ("rewrite", "fresh", "mimic")
MIMIC_PROMPT_VERSION = "verse.mimic.v2"  # v2: rhyme-first end-word plan (DeepRapper idea)
MIMIC_BARS = (4, 8, 16)
MIMIC_ATTEMPTS = 3
# Soft target from Gunna's catalog: per-song mean syllables p10 ~8, median ~10, p90 ~12.5.
# Mimic mode does not use this band. It reads the anchor profile.
SYL_MIN, SYL_MAX = 8, 13
RATINGS_DIR = HERE / "rater" / "exports"
REASON_TEXT = {
    "no_sense": "doesn't make sense", "bad_rhyme": "forced or bad rhyme", "off_flow": "off flow",
    "off_topic": "off topic", "too_copied": "too copied", "cringe": "cringe",
}
COPY_NGRAM = 5
MAX_ATTEMPTS = 3
CALL_TIMEOUT = 300
OMNI_URL = "http://127.0.0.1:20128/v1/chat/completions"
OMNI_MODEL_DEFAULT = "gemini/gemini-3.1-flash-lite"
OMNI_TIMEOUT = 90
_CALLER = "claude"
_OMNI_KEY: str | None = None
_ANALYZE_LOCK = threading.Lock()
MIMIC_LEVELS = ("rhyme", "inner", "double", "story")
LEVEL_VERSION = {"rhyme": "verse.mimic.v2", "inner": "verse.mimic.v3", "double": "verse.mimic.v4",
                 "story": "verse.mimic.v5"}
# Spines are the real Gunna threads: a come-up arc, one recurring person, or his circle vs opps.
SPINES = (
    {"key": "come_up", "weight": 3,
     "text": "SPINE = come-up arc. This verse is ONE small story of then -> now. Open on where he came from (a specific room, car, block, or hustle), return to the grind once in the middle, land on where he is now. Use real places and at least one named person. Do not drift into a list of unrelated flexes; every bar is a beat in that one story."},
    {"key": "person", "weight": 3,
     "text": "SPINE = one recurring person: {who}. The verse is a small story about them. Name them or speak to them in at least 3 bars, spread across the verse (not all at the start). Give them something concrete to do or want. The other bars are details of that same scene, not separate boasts."},
    {"key": "circle", "weight": 2,
     "text": "SPINE = loyalty. One thread about his circle versus the ones who turned: who stayed down from the start, who switched, what he does about it now. Keep it to that one thread across the whole verse, with real people and moments, not scattered flexes."},
)
SPINE_PEOPLE = ("his mama", "his brother", "his cousin", "the woman he's with", "his day-one partner")
WORDPLAY_FILE = HERE.parents[1] / "docs" / "play-on-words" / "gunna-candidates.jsonl"
# Run-level memory so a batch spreads across rhyme families, end words and subjects.
_FAMILY_USE: Counter = Counter()
_WORD_USE: Counter = Counter()
_SUBJECT_USE: Counter = Counter()
BANNED = {"braggadocio"}
SKIP_TOPICS = {"filler_adlib", "other"}

TOPIC_BRIEF = {
    "money_flex": "money: counting it, spending it, showing it off",
    "luxury_brands": "designer clothes, jewelry, watches, cars",
    "braggadocio_skill": "being above everyone else, shown through specifics, never by saying 'I'm the best'",
    "come_up_hustle": "coming up from nothing, the grind, then and now",
    "sex": "women and sex",
    "women_romance": "a woman he's involved with",
    "drugs": "drugs and getting high",
    "violence_street": "the street, guns, opps",
    "betrayal_enemies": "fake friends, snakes, enemies",
    "loyalty_friends": "his gang and loyalty",
    "party_lifestyle": "partying, clubs, nightlife",
    "fame_industry": "fame and the music industry",
    "family_home": "family and where he's from",
    "social_commentary": "the world around him",
    "wordplay_punchline": "punchlines and double meanings",
    "faith_mortality": "God, death, survival",
}


# ---------------------------------------------------------------- corpus


class Corpus:
    """Artist's real bars (deduped, 1-indexed like Phase 4) plus topic labels and copy-check n-grams."""

    def __init__(self, artist: str, lex: p1.Lexicon, songs: list | None = None):
        self.artist = artist
        self.lex = lex
        if songs is None:
            self.songs = [
                (song, bars) for _, song, bars in p4.song_bars(p1.DEFAULT_CSV, {artist.lower()})
            ]
        else:
            self.songs = [(title, list(bars)) for title, bars in songs]
        if not self.songs:
            raise SystemExit(f"no lyrics for '{artist}' in {p1.DEFAULT_CSV}")
        self.topic_of: dict[tuple[str, int], str] = {}
        for line in open(OUT / "topic_cache.jsonl", encoding="utf-8"):
            r = json.loads(line)
            if r.get("artist") != artist or r.get("status") != "ok":
                continue
            for run in r["runs"]:
                for i in range(run["start"], run["end"] + 1):
                    self.topic_of[(r["song"], i)] = run["topic"]
        self.ngrams: set[str] = set()
        self.lines: set[str] = set()
        for _, bars in self.songs:
            for b in bars:
                self.lines.add(p1.norm_line(b))
                w = p1.norm_line(b).split()
                for i in range(len(w) - COPY_NGRAM + 1):
                    self.ngrams.add(" ".join(w[i:i + COPY_NGRAM]))

    def clean(self, bar: str) -> bool:
        b = p1.Bar(bar, self.lex)
        return len(b.words) >= 4 and 6 <= b.syl <= 20

    def topic_passages(self, topic: str, size: int = 4) -> list[dict]:
        out = []
        for song, bars in self.songs:
            run: list[str] = []
            for i, bar in enumerate(bars, 1):
                if self.topic_of.get((song, i)) == topic and self.clean(bar):
                    run.append(bar)
                    continue
                if len(run) >= size:
                    out.append({"song": song, "topic": topic, "bars": run[:8]})
                run = []
            if len(run) >= size:
                out.append({"song": song, "topic": topic, "bars": run[:8]})
        return out

    def voice_passages(self, rng: random.Random, n: int, size: int = 4) -> list[dict]:
        out = []
        for song, bars in rng.sample(self.songs, min(len(self.songs), n * 4)):
            starts = list(range(0, max(0, len(bars) - size), size))
            rng.shuffle(starts)
            for s in starts:
                chunk = bars[s:s + size]
                if len(chunk) == size and all(self.clean(b) for b in chunk):
                    out.append({"song": song, "topic": None, "bars": chunk})
                    break
            if len(out) >= n:
                break
        return out

    def full_copy(self, text: str) -> bool:
        return p1.norm_line(text) in self.lines

    def borrowed(self, text: str) -> str | None:
        w = p1.norm_line(text).split()
        for i in range(len(w) - COPY_NGRAM + 1):
            g = " ".join(w[i:i + COPY_NGRAM])
            if g in self.ngrams:
                return g
        return None


def clean_text(bar: str) -> str:
    return re.sub(r"\s+", " ", p1.ADLIB_RE.sub(" ", bar)).strip()


def find_couplets(corpus: Corpus, topic: str | None, rng: random.Random, n: int = 8) -> list[dict]:
    """Real back-to-back bar pairs that already end-rhyme, topic-matched first."""
    on, off = [], []
    for song, bars in corpus.songs:
        parsed = [p1.Bar(b, corpus.lex) for b in bars]
        for i in range(len(bars) - 1):
            a, b = parsed[i], parsed[i + 1]
            if not all(len(x.words) >= 4 and 6 <= x.syl <= 15 for x in (a, b)):
                continue
            if end_rhyme_kind(a, b) not in ("perfect", "slant"):
                continue
            item = {"song": song, "topic": corpus.topic_of.get((song, i + 1)),
                    "bars": [clean_text(bars[i]), clean_text(bars[i + 1])]}
            (on if topic and item["topic"] == topic else off).append(item)
    rng.shuffle(on)
    rng.shuffle(off)
    picked, songs = [], set()
    for c in on[:n - 3] + off:
        if c["song"] in songs:
            continue
        songs.add(c["song"])
        picked.append(c)
        if len(picked) >= n:
            break
    return picked


def load_taste(artist: str, limit: int = 20) -> dict:
    """Bars Samuel starred / thumbed up and thumbed down in rater exports (auto-grader files skipped).

    Keepers stay first. Past that, a higher verse_score comes first. Equal scores keep
    the order the exports were read. There is no alphabetical tiebreak.
    """
    # text -> (keeper, verse_score, first-seen order)
    liked: dict[str, tuple[bool, int, int]] = {}
    disliked: dict[str, set[str]] = {}
    seq = 0
    for path in sorted(RATINGS_DIR.glob("sparkler_ratings_*.json")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        if data.get("schema") != "sparkler.ratings.v1" or data.get("rater") == "sparkler-grader":
            continue
        for r in data.get("ratings", []):
            if r.get("artist") not in (None, artist):
                continue
            score = r.get("verse_score")
            score_n = score if isinstance(score, int) and not isinstance(score, bool) else 0
            for b in r.get("bar_votes", []):
                text = clean_text(b.get("text", ""))
                rewrite = clean_text(b.get("rewrite") or "")
                reasons = b.get("reasons") or r.get("verse_reasons") or []
                if text and (b.get("keeper") or b.get("vote") == 1):
                    _remember_like(liked, text, bool(b.get("keeper")), score_n, seq)
                    seq += 1
                elif text and b.get("vote") == -1:
                    disliked.setdefault(text, set()).update(reasons)
                if rewrite and rewrite != text:
                    _remember_like(liked, rewrite, False, score_n, seq)
                    seq += 1
    for text in liked:
        disliked.pop(text, None)
    loved = sorted(liked, key=lambda text: (not liked[text][0], -liked[text][1], liked[text][2]))[:limit]
    keepers = [text for text in loved if liked[text][0]]
    return {
        "liked": loved,
        "keepers": keepers,
        "disliked": [(t, sorted(rs)) for t, rs in list(disliked.items())[:limit]],
    }


def _remember_like(liked: dict[str, tuple[bool, int, int]], text: str,
                   keeper: bool, score: int, seq: int) -> None:
    prev = liked.get(text)
    if prev is None:
        liked[text] = (keeper, score, seq)
        return
    liked[text] = (prev[0] or keeper, max(prev[1], score), prev[2])


def load_style(artist: str) -> tuple[dict, dict, dict]:
    def find(path: Path) -> dict:
        for line in open(path, encoding="utf-8"):
            r = json.loads(line)
            if r.get("artist") == artist:
                return r
        return {}
    return find(OUT / "artist_grades.jsonl"), find(OUT / "artist_rollup.jsonl"), find(OUT / "topic_chain_artists.jsonl")


def pick_topic(chains: dict, corpus: Corpus, rng: random.Random) -> str:
    share = {t: p for t, p in chains.get("topic_share_pct", {}).items() if t not in SKIP_TOPICS}
    labeled = {t for t in corpus.topic_of.values()}
    pool = {t: p for t, p in share.items() if t in labeled} or share or {"money_flex": 1.0}
    return rng.choices(list(pool), weights=list(pool.values()))[0]


# ---------------------------------------------------------------- taste blocks

REASON_AVOID_TEXT = {
    "bad_rhyme": "weak or missing end rhyme",
    "no_sense": "lines that make no sense or have broken logic",
    "off_flow": "off-flow or awkward syllable rhythm",
    "off_topic": "drifting away from the topic",
    "too_copied": "lines copied too closely from source lyrics",
    "cringe": "forced clichés or unnatural phrasing",
}
REASONS = set(REASON_AVOID_TEXT.keys())


def scrub_bar_pii(text: str) -> str:
    """Removes emails, phone numbers, URLs, and social tags from a bar."""
    text = re.sub(r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+", "", text)
    text = re.sub(r"\b(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b", "", text)
    text = re.sub(r"https?://\S+|www\.\S+", "", text)
    text = re.sub(r"@\w+", "", text)
    return re.sub(r"\s+", " ", text).strip()


def build_taste_prompt_blocks(
    artist: str,
    store: feedback_store.FeedbackStore | None = None,
    k_bars: int = 6,
    k_reasons: int = 4,
    taste_on: bool = True,
    fallback_taste: dict | None = None,
) -> tuple[str | None, str | None]:
    """Queries feedback_store for top keeper bars and top avoid reason codes for an artist.

    Returns (keeper_block, avoid_block).
    """
    if not taste_on:
        return None, None

    if store is None:
        if fallback_taste is not None:
            return None, None
        db_path = OUT / "feedback.sqlite"
        if not db_path.exists() and (OUT / "feedback.db").exists():
            db_path = OUT / "feedback.db"
        if not db_path.exists():
            return None, None
        try:
            store = feedback_store.FeedbackStore(str(db_path))
        except Exception:
            return None, None

    # 1. Top K bars with highest positive weight()
    cur = store.db.cursor()
    cur.execute(
        """
        SELECT DISTINCT v.target_ref
        FROM votes v
        WHERE v.target_kind = 'bar' AND v.vote = 1 AND (v.artist = ? OR ? = '')
        """,
        (artist, artist),
    )
    bar_refs = [row[0] for row in cur.fetchall()]

    weighted_bars = []
    seen_texts = set()

    for bid in bar_refs:
        w = store.weight("bar", bid, artist=artist)
        if w <= 0.5:
            continue

        # Look up bar text (preferring user rewrite if present) from generation_bars
        cur.execute("PRAGMA table_info(generation_bars);")
        gb_cols = {r[1] for r in cur.fetchall()}
        if "rewrite" in gb_cols:
            cur.execute("SELECT text, rewrite FROM generation_bars WHERE id = ?", (bid,))
            row = cur.fetchone()
            raw_text = (row[1] if (row and len(row) > 1 and row[1]) else (row[0] if (row and row[0]) else ""))
        else:
            cur.execute("SELECT text FROM generation_bars WHERE id = ?", (bid,))
            row = cur.fetchone()
            raw_text = row[0] if (row and row[0]) else ""

        # Fallback to rating_cards payload if missing from generation_bars
        if not raw_text:
            gid = bid.split(":")[0] if ":" in bid else bid
            cur.execute("SELECT payload FROM rating_cards WHERE generation_id = ?", (gid,))
            p_row = cur.fetchone()
            if p_row and p_row[0]:
                try:
                    payload = json.loads(p_row[0])
                    for bv in payload.get("bar_votes", []):
                        if (bv.get("bar_id") == bid or f"{gid}:{bv.get('bar_index')}" == bid):
                            raw_text = bv.get("rewrite") or bv.get("text") or ""
                            if raw_text:
                                break
                except Exception:
                    pass

        if not raw_text:
            continue

        clean_t = scrub_bar_pii(clean_text(raw_text))
        if not clean_t:
            continue

        norm_key = re.sub(r"[^a-z0-9]", "", clean_t.lower())
        if norm_key in seen_texts:
            continue
        seen_texts.add(norm_key)

        weighted_bars.append((w, clean_t))

    weighted_bars.sort(key=lambda item: (-item[0], item[1]))

    keeper_block = None
    # Pitfall check: Don't let one super-upvoted bar dominate — if top-K is <2, fall back
    if len(weighted_bars) >= 2:
        top_k_bars = [bar_text for _, bar_text in weighted_bars[:k_bars]]
        keeper_block = (
            "WRITE LIKE THIS (keeper bars from this artist, rated by the writer):\n"
            + "\n".join(f"- {bar}" for bar in top_k_bars)
        )

    # 2. Top K reason codes among downvoted bars
    cur.execute(
        """
        SELECT reasons, reason FROM votes
        WHERE target_kind = 'bar' AND vote = -1 AND (artist = ? OR ? = '')
        """,
        (artist, artist),
    )
    reasons_counter = Counter()
    for r_json, r_single in cur.fetchall():
        if r_json:
            try:
                for c in json.loads(r_json):
                    if c in REASONS:
                        reasons_counter[c] += 1
            except Exception:
                pass
        elif r_single and r_single in REASONS:
            reasons_counter[r_single] += 1

    # If bar votes didn't carry explicit reason tags, check verse-level downvote reasons for this artist
    if not reasons_counter:
        cur.execute(
            """
            SELECT reasons, reason FROM votes
            WHERE target_kind = 'verse' AND (vote = -1 OR vote < 5) AND (artist = ? OR ? = '')
            """,
            (artist, artist),
        )
        for r_json, r_single in cur.fetchall():
            if r_json:
                try:
                    for c in json.loads(r_json):
                        if c in REASONS:
                            reasons_counter[c] += 1
                except Exception:
                    pass
            elif r_single and r_single in REASONS:
                reasons_counter[r_single] += 1

    avoid_block = None
    if reasons_counter:
        top_reasons = [code for code, _ in reasons_counter.most_common(k_reasons)]
        mapped_reasons = [REASON_AVOID_TEXT.get(code, code.replace("_", " ")) for code in top_reasons]
        avoid_block = (
            "AVOID (these problems hit before):\n"
            + "\n".join(f"- {exp}" for exp in mapped_reasons)
        )

    return keeper_block, avoid_block


# ---------------------------------------------------------------- prompt


def build_prompt(artist: str, n_bars: int, topic: str, scheme: str, exemplars: list[dict],
                 grades: dict, rollup: dict, mode: str = "rewrite", couplets: list[dict] | None = None,
                 taste: dict | None = None, taste_on: bool = True, taste_k: int = 6,
                 store: feedback_store.FeedbackStore | None = None) -> str:
    def block(p: dict) -> str:
        lines = (clean_text(b) for b in p["bars"])
        return f'"{p["song"]}"\n' + "\n".join(l for l in lines if l)

    brief = TOPIC_BRIEF.get(topic, topic.replace("_", " "))
    m = rollup.get("metrics", {})
    syl_med = m.get("cadence.syl_per_bar_mean", {}).get("median")
    shares = grades.get("end_rhyme_scheme_share", {})
    facts = []
    if syl_med:
        facts.append(f"Typical bar: about {syl_med:.0f} syllables. Short, conversational lines.")
    if shares:
        facts.append(f"End rhymes: {shares.get('couplet', 0)}% back-to-back couplets, "
                     f"{shares.get('alternate', 0)}% alternating.")
    facts.append("Internal rhymes are rare for him (a few percent of bars). Don't force them.")

    if scheme == "aabb":
        scheme_rule = "AABB: bars 1-2 share an end sound, bars 3-4 share a different end sound."
    else:
        scheme_rule = "ABAB: bars 1 and 3 share an end sound, bars 2 and 4 share a different end sound."
    if n_bars != 4:
        scheme_rule += f" Repeat the pattern for every group of 4 bars ({n_bars} bars total)."

    parts = [f"You are ghostwriting {n_bars} bars in the voice of {artist}. Below are real {artist} lyrics."]
    voice = [p for p in exemplars if p["bars"]]
    if voice:
        parts.append(f"REAL {artist.upper()} BARS (how he talks):\n\n" + "\n\n".join(block(p) for p in voice))
    if facts:
        parts.append(f"MEASURED ON {artist.upper()}'S CATALOG:\n" + "\n".join(f"- {f}" for f in facts))

    keeper_block, avoid_block = build_taste_prompt_blocks(
        artist, store=store, k_bars=taste_k, k_reasons=4, taste_on=taste_on, fallback_taste=taste,
    )
    if keeper_block:
        parts.append(keeper_block)
    elif taste and taste.get("liked"):
        parts.append("BARS THE USER LOVED. This is the target: plain speech, real places and people, "
                     "a small story, nothing bent to fit a rhyme.\n" + "\n".join(f"+ {t}" for t in taste["liked"]))

    if avoid_block:
        parts.append(avoid_block)
    elif taste and taste.get("disliked"):
        parts.append("BARS THE USER REJECTED. Never write like these:\n" + "\n".join(
            f"- {t}  ({', '.join(REASON_TEXT.get(r, r) for r in rs) or 'rejected'})" for t, rs in taste["disliked"]))

    if mode == "rewrite" and couplets:
        pairs = n_bars // 2
        order = ("Keep each couplet's two lines together (AABB)." if scheme == "aabb" else
                 "Order the lines ABAB: couplet 1 line 1, couplet 2 line 1, couplet 1 line 2, couplet 2 line 2, "
                 "and make sure it still reads naturally in that order.")
        parts.append(f"SOURCE COUPLETS (real {artist}; each pair already rhymes):\n" + "\n".join(
            f"{i}. {c['bars'][0]} / {c['bars'][1]}   (\"{c['song']}\")" for i, c in enumerate(couplets, 1)))
        parts.append(
            f"TASK: build {n_bars} bars about {brief} by REWRITING {pairs} of the source couplets. "
            f"Pick the {pairs} whose shape fits best. For each line keep {artist}'s sentence shape, rhythm and "
            f"roughly the same length; swap the specifics (cars, brands, places, people, numbers, actions) so the "
            f"verse is about the topic and tells one small story. Keep the couplet's end-rhyme sound, or replace "
            f"BOTH end words with a new pair that rhymes just as naturally. If a line already fits, keep most of it. "
            f"{order}")
    else:
        parts.append(f"TASK: write {n_bars} bars about {brief} that sound like they belong on his album. "
                     f"Borrowing his signature phrases is fine.")

    parts.append(
        "MOST IMPORTANT: read every bar out loud. It must be a sentence he would actually say, and the verse "
        "follows one thread. If a rhyme forces a weird word, change the rhyme, not the sense.\n\n"
        "MUST:\n"
        "1. One line per bar with exactly one comma (a setup, then the payoff).\n"
        f"2. End-rhyme scheme {scheme_rule}\n"
        "3. Every bar starts with a different word.\n"
        "4. No ad-libs in parentheses, and never paste a source line unchanged.\n"
        f"5. Never use the words: {', '.join(sorted(BANNED))}, or the topic label.\n\n"
        "AIM FOR (don't sacrifice sense for these):\n"
        f"- About {SYL_MIN}-{SYL_MAX} syllables per bar.\n"
        "- The setup before the comma usually shorter than the payoff after it.\n"
        "- Concrete images over abstract claims like \"I'm the best\".\n"
        "- Don't repeat content words across bars.\n\n"
        "For each bar give a one-line plain-English meaning; if you can't state a clear meaning, rewrite the "
        "bar. Return only JSON:\n"
        '{"plan": "...", "bars": [{"bar": "...", "meaning": "...", "source": <couplet number or null>}, ...]}'
    )
    return "\n\n".join(parts)


# ---------------------------------------------------------------- analysis


def syl(text: str, lex: p1.Lexicon) -> int:
    return p1.Bar(text, lex).syl


SLANG_PATH = HERE / "slang_phonemes.json"
_CMU_ALL_PRONS: dict[str, list[list[str]]] = {}
_CMU_LOADED = False


def load_all_cmu_pronunciations(cmu_path: Path | None = None) -> dict[str, list[list[str]]]:
    """Loads all pronunciations from CMUdict, merged with slang_phonemes.json fallback."""
    global _CMU_ALL_PRONS, _CMU_LOADED
    if _CMU_LOADED and _CMU_ALL_PRONS:
        return _CMU_ALL_PRONS
    path = cmu_path or p1.DEFAULT_CMU
    prons: dict[str, list[list[str]]] = defaultdict(list)
    if path.exists():
        with open(path, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                if line.startswith(";;;") or not line.strip():
                    continue
                parts = line.split()
                word = re.sub(r"\(\d+\)$", "", parts[0]).lower()
                prons[word].append(parts[1:])
    if SLANG_PATH.exists():
        try:
            with open(SLANG_PATH, encoding="utf-8") as fh:
                slang = json.load(fh)
            for word, phone_lists in slang.items():
                w = word.lower()
                for p in phone_lists:
                    if p not in prons[w]:
                        prons[w].append(p)
        except Exception as e:
            print(f"#warning: failed to load {SLANG_PATH}: {e}", file=sys.stderr)
    _CMU_ALL_PRONS = dict(prons)
    _CMU_LOADED = True
    return _CMU_ALL_PRONS


def get_lexicon(cmu_path: Path | None = None) -> p1.Lexicon:
    """Creates a Lexicon with single-pronunciation CMUdict plus slang_phonemes."""
    path = cmu_path or p1.DEFAULT_CMU
    table = p1.load_cmudict(path) if path.exists() else {}
    if SLANG_PATH.exists():
        try:
            with open(SLANG_PATH, encoding="utf-8") as fh:
                slang = json.load(fh)
            for word, phone_lists in slang.items():
                w = word.lower()
                if w not in table and phone_lists:
                    table[w] = phone_lists[0]
        except Exception:
            pass
    return p1.Lexicon(table)


def get_word_pronunciations(word: str, lex: p1.Lexicon | None = None) -> list[list[str]]:
    all_prons = load_all_cmu_pronunciations()
    w = word.lower().strip(" \t\n\r\"'.,!?;:()[]{}")
    if not w:
        return []
    for cand in p1.Lexicon._candidates(w):
        if cand in all_prons and all_prons[cand]:
            return all_prons[cand]
    if lex:
        phones = lex.phones_for(w)
        if phones:
            return [phones]
    return []


def check_rhyme_kind(word_a: str, word_b: str, lex: p1.Lexicon | None = None) -> str | None:
    wa = word_a.lower().strip(" \t\n\r\"'.,!?;:()[]{}")
    wb = word_b.lower().strip(" \t\n\r\"'.,!?;:()[]{}")
    if not wa or not wb:
        return None
    if wa == wb:
        return "identical"
    prons_a = get_word_pronunciations(wa, lex)
    prons_b = get_word_pronunciations(wb, lex)
    if not prons_a or not prons_b:
        return None
    best_kind = None
    for pa in prons_a:
        info_a = p1.analyze_phones(pa)
        ra = info_a[2]
        if not ra:
            continue
        for pb in prons_b:
            info_b = p1.analyze_phones(pb)
            rb = info_b[2]
            if not rb:
                continue
            if ra == rb:
                return "perfect"
            if ra.split()[0] == rb.split()[0] and p1.trailing_vowel_depth(pa, pb) >= 1:
                best_kind = "slant"
    return best_kind


def end_rhyme_kind(a: p1.Bar, b: p1.Bar) -> str | None:
    if not (a and b and a.end_word and b.end_word):
        return None
    res = check_rhyme_kind(a.end_word, b.end_word)
    if res is not None:
        return res
    if not (a.end_phones and b.end_phones and a.rime and b.rime and a.rime[-1] and b.rime[-1]):
        return None
    if a.end_word == b.end_word:
        return "identical"
    ra, rb = a.rime[-1], b.rime[-1]
    if ra == rb:
        return "perfect"
    if ra.split()[0] == rb.split()[0] and p1.trailing_vowel_depth(a.end_phones, b.end_phones) >= 1:
        return "slant"
    return None


def content(w: str) -> bool:
    return w not in p1.STOPWORDS and "'" not in w and len(w) > 2


def internal_pairs(b: p1.Bar) -> list[list[str]]:
    idx = [i for i, w in enumerate(b.words) if content(w) and b.rime[i]]
    pairs = []
    for x in range(len(idx)):
        for y in range(x + 1, len(idx)):
            i, j = idx[x], idx[y]
            wi, wj = b.words[i], b.words[j]
            if wi == wj:
                continue
            ri, rj = b.rime[i], b.rime[j]
            same = ri == rj or (b.v2[i] and b.v2[i] == b.v2[j]) or (
                ri.split()[0] == rj.split()[0] and ri.split()[-1] == rj.split()[-1])
            if same:
                pairs.append([wi, wj])
    return pairs


def scheme_pairs(n: int, scheme: str) -> list[tuple[int, int]]:
    pairs = []
    for g in range(0, n - n % 4, 4):
        pairs += [(g, g + 1), (g + 2, g + 3)] if scheme == "aabb" else [(g, g + 2), (g + 1, g + 3)]
    for i in range(n - n % 4, n - 1, 2):
        pairs.append((i, i + 1))
    return pairs


def analyze_verse(texts: list[str], scheme: str, corpus: Corpus,
                  meanings: list[str] | None = None) -> tuple[list[dict], list[str], list[str]]:
    """Returns (rows, problems, notes). Problems break a MUST rule and trigger a retry; notes are soft targets."""
    lex = corpus.lex
    bars = [p1.Bar(t, lex) for t in texts]
    rows, problems, notes = [], [], []
    letters: list[str] = []
    for k, (t, b) in enumerate(zip(texts, bars), 1):
        commas = t.count(",")
        halves = [h.strip() for h in t.split(",", 1)] if commas else [t.strip()]
        half_syl = [syl(h, lex) for h in halves]
        pairs = internal_pairs(b)
        copy = corpus.full_copy(t)
        borrowed = corpus.borrowed(t)
        banned = sorted(set(b.words) & BANNED)
        letter = None
        for j in range(k - 1):
            if end_rhyme_kind(bars[j], b) in ("perfect", "slant"):
                letter = letters[j]
                break
        letter = letter or chr(ord("A") + len(set(letters)))
        letters.append(letter)
        checks = {
            "one_comma": commas == 1,
            "syllables": SYL_MIN <= b.syl <= SYL_MAX,
            "internal_rhyme": bool(pairs),
            "setup_shorter": len(half_syl) == 2 and half_syl[0] < half_syl[1],
            "not_a_copy": not copy,
        }
        if commas != 1:
            problems.append(f"bar {k}: has {commas} commas, needs exactly 1")
        if not checks["syllables"]:
            notes.append(f"bar {k}: {b.syl} syllables ({' + '.join(map(str, half_syl))}), target {SYL_MIN}-{SYL_MAX}")
        if copy:
            problems.append(f"bar {k}: is a word-for-word copy of a real {corpus.artist} bar")
        if banned:
            problems.append(f"bar {k}: uses banned word(s) {', '.join(banned)}")
        rows.append({
            "text": t,
            "halves": [{"text": h, "syl": s} for h, s in zip(halves, half_syl)],
            "syllables": b.syl,
            "end_word": b.end_word,
            "rhyme_letter": letter,
            "internal": pairs,
            "borrowed": borrowed,
            "meaning": (meanings[k - 1] if meanings and k <= len(meanings) else ""),
            "checks": checks,
        })

    for i, j in scheme_pairs(len(bars), scheme):
        kind = end_rhyme_kind(bars[i], bars[j])
        if kind not in ("perfect", "slant"):
            why = "repeats the same end word" if kind == "identical" else "don't rhyme"
            problems.append(f"bars {i + 1} and {j + 1} must end-rhyme for {scheme.upper()}: "
                            f"\"{bars[i].end_word}\" / \"{bars[j].end_word}\" {why}")

    short_setup = [r["checks"]["setup_shorter"] for r in rows]
    if sum(short_setup) < len(rows) - 1:
        bad = [f"bar {k} ({r['halves'][0]['syl']} vs {r['halves'][-1]['syl']})"
               for k, r in enumerate(rows, 1) if not r["checks"]["setup_shorter"]]
        notes.append("setup longer than payoff in " + ", ".join(bad))
    openers = Counter(b.words[0] for b in bars if b.words)
    for w, c in openers.items():
        if c > 1:
            problems.append(f"{c} bars start with \"{w}\"; every bar needs a different first word")
    seen: dict[str, set[int]] = defaultdict(set)
    for k, b in enumerate(bars, 1):
        for w in b.words:
            if content(w):
                seen[w].add(k)
    repeats = sorted(w for w, ks in seen.items() if len(ks) > 1)
    if repeats:
        notes.append(f"content words reused across bars: {', '.join(repeats)}")
    return rows, problems, notes


# ---------------------------------------------------------------- model call


class OmniDown(RuntimeError):
    """OmniRoute rejected the key or is unreachable. Do not write an empty set."""


def _omni_key() -> str:
    global _OMNI_KEY
    if _OMNI_KEY:
        return _OMNI_KEY
    db_path = Path.home() / ".omniroute" / "storage.sqlite"
    con = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    try:
        row = con.execute(
            "select key from api_keys where name = ? and revoked_at is null",
            ("one 1",),
        ).fetchone()
    finally:
        con.close()
    if not row or not row[0]:
        raise OmniDown("omniroute manage key is missing")
    _OMNI_KEY = row[0]
    return _OMNI_KEY


def _clean_model_text(text: str) -> str:
    return re.sub(r"<think>.*?</think>", "", text, flags=re.S).strip()


def _call_omni(prompt: str, model: str) -> str | None:
    """One chat completion through local OmniRoute. The key stays out of logs."""
    payload = json.dumps({
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.85,
        "max_tokens": 4096,
        "tool_choice": "none",
    }).encode("utf-8")
    delays = (0, 3, 8, 15)
    last = "no attempt"
    for pause in delays:
        if pause:
            time.sleep(pause)
        request = urllib.request.Request(
            OMNI_URL,
            data=payload,
            headers={"Authorization": f"Bearer {_omni_key()}", "Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=OMNI_TIMEOUT) as response:
                body = json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:
            exc.read()
            last = f"HTTP {exc.code}"
            print(f"[{model}] {last}", file=sys.stderr, flush=True)
            if exc.code in (401, 403):
                raise OmniDown(f"{model} {last}") from exc
            if exc.code in (429, 500, 502, 503, 504):
                continue
            return None
        except (urllib.error.URLError, TimeoutError, socket.timeout, OSError, json.JSONDecodeError) as exc:
            last = type(exc).__name__
            print(f"[{model}] {last}", file=sys.stderr, flush=True)
            continue
        message = ((body.get("choices") or [{}])[0].get("message") or {})
        content = message.get("content")
        if isinstance(content, list):
            content = "".join(
                part if isinstance(part, str) else str(part.get("text") or "")
                for part in content
            )
        text = _clean_model_text(content or "")
        reasoning = message.get("reasoning_content") or ""
        if "{" not in text and isinstance(reasoning, str) and "{" in reasoning:
            text = _clean_model_text(reasoning)
        if text:
            return text
        last = "empty content"
        print(f"[{model}] empty content", file=sys.stderr, flush=True)
    print(f"[{model}] gave up ({last})", file=sys.stderr, flush=True)
    return None


def call_model(prompt: str, model: str) -> str | None:
    if _CALLER == "omni":
        return _call_omni(prompt, model)
    cmd = ["claude", "-p", "--model", model, "--no-session-persistence"]
    try:
        r = subprocess.run(cmd, input=prompt, capture_output=True, text=True, timeout=CALL_TIMEOUT)
    except subprocess.TimeoutExpired:
        print(f"[{model}] timed out after {CALL_TIMEOUT}s", file=sys.stderr)
        return None
    if r.returncode != 0 or not (r.stdout or "").strip():
        detail = (r.stderr or r.stdout or "").strip().replace("\n", " ")
        print(f"[{model}] failed ({r.returncode}): {detail[:300]}", file=sys.stderr, flush=True)
        if "session limit" in detail.lower():
            raise SystemExit(f"{model} hit the claude session limit. {detail[:300]}")
        return None
    return r.stdout


def parse_bars(raw: str | None, n: int) -> tuple[list[str], list[str]] | None:
    if not raw:
        return None
    a, b = raw.find("{"), raw.rfind("}")
    if a < 0 or b <= a:
        return None
    try:
        items = json.loads(raw[a:b + 1]).get("bars")
    except json.JSONDecodeError:
        return None
    if not isinstance(items, list):
        return None
    texts, meanings = [], []
    for x in items:
        text = x.get("bar", "") if isinstance(x, dict) else x
        text = re.sub(r"\s+", " ", str(text)).strip()
        if text:
            texts.append(text)
            meanings.append(str(x.get("meaning", "")).strip() if isinstance(x, dict) else "")
    return (texts[:n], meanings[:n]) if len(texts) >= n else None


def parse_field(raw: str | None, field: str, n: int) -> list:
    """Per-bar values of one JSON field (e.g. double_meaning); None where missing."""
    if not raw:
        return [None] * n
    a, b = raw.find("{"), raw.rfind("}")
    try:
        items = json.loads(raw[a:b + 1]).get("bars") if a >= 0 and b > a else None
    except json.JSONDecodeError:
        items = None
    values = []
    for item in items or []:
        if isinstance(item, dict):
            text = re.sub(r"\s+", " ", str(item.get("bar", ""))).strip()
            if text:
                values.append(item.get(field))
        else:
            text = re.sub(r"\s+", " ", str(item)).strip()
            if text:
                values.append(None)
    return (values + [None] * n)[:n]


def valid_double(dm, text: str) -> bool:
    if not isinstance(dm, dict):
        return False
    word = str(dm.get("word") or "").strip().lower()
    m1, m2 = str(dm.get("meaning_1") or "").strip(), str(dm.get("meaning_2") or "").strip()
    return bool(word) and word in text.lower() and bool(m1) and bool(m2) and m1.lower() != m2.lower()


def run_model(ctx: dict, model: str, corpus: Corpus) -> dict:
    t0 = time.time()
    prompt, best, attempts = ctx["prompt"], None, []
    for attempt in range(1, MAX_ATTEMPTS + 1):
        parsed = parse_bars(call_model(prompt, model), ctx["n_bars"])
        if not parsed:
            attempts.append({"attempt": attempt, "error": "no usable JSON"})
            continue
        texts, meanings = parsed
        rows, problems, notes = analyze_verse(texts, ctx["scheme"], corpus, meanings)
        attempts.append({"attempt": attempt, "bars": texts, "problems": problems, "notes": notes})
        if best is None or (len(problems), len(notes)) < (len(best[1]), len(best[2])):
            best = (rows, problems, notes)
        if not problems:
            break
        prompt = (ctx["prompt"] + "\n\nYOUR PREVIOUS ATTEMPT:\n" + "\n".join(f"{i}. {t}" for i, t in enumerate(texts, 1))
                  + "\n\nMUST-FIX PROBLEMS (rhymes measured with the CMU pronouncing dictionary):\n"
                  + "\n".join(f"- {p}" for p in problems)
                  + ("\n\nNice to fix if it doesn't hurt the sense:\n" + "\n".join(f"- {n}" for n in notes) if notes else "")
                  + "\n\nRewrite the whole verse fixing the must-fix problems. Sense comes first: read each bar out "
                    "loud. Return only the JSON.")
    rows, problems, notes = best if best else ([], ["no usable output from model"], [])
    for r in rows:
        r["topic"] = ctx["topic"]
    return {"model": model, "bars": rows, "problems": problems, "notes": notes, "passed": not problems and bool(rows),
            "attempts": attempts, "elapsed_s": round(time.time() - t0, 1)}


# ---------------------------------------------------------------- mimic


def anchor_verse_bank(songs: list[dict], skip_keys: set[str] | None = None) -> list[dict]:
    """8–16 line stretches from the anchor songs. Ad-libs stay in the text.

    Most of these files have no repeated hook, so the stretch is cut from the song.
    skip_keys are normalized lines shared with another song. Those lines are left out
    of the examples. The song itself stays in the set.
    """
    skip = skip_keys or set()
    bank = []
    for song in songs:
        info = anchor_lib.style_lines_for(song["lines"])
        sources = info["real_verses"] or info["style_verses"]
        for verse in sources:
            if skip:
                verse = [line for line in verse if p1.norm_line(line) not in skip]
            if len(verse) < 8:
                continue
            if len(verse) <= 16:
                bank.append({"song": song["title"], "bars": list(verse), "topic": None})
                continue
            made = 0
            for start in range(0, len(verse) - 7, 8):
                chunk = verse[start:start + 12]
                if len(chunk) < 8:
                    continue
                bank.append({"song": song["title"], "bars": chunk[:16], "topic": None})
                made += 1
                if made >= 4:
                    break
    return bank


def pick_exemplars(bank: list[dict], rng: random.Random, closeness: float, rotate: int) -> list[dict]:
    want = 2 if closeness >= 0.85 else 4
    by_song: dict[str, list[dict]] = defaultdict(list)
    for item in bank:
        by_song[item["song"]].append(item)
    names = list(by_song)
    rng.shuffle(names)
    if names:
        shift = rotate % len(names)
        names = names[shift:] + names[:shift]
    picked = []
    for name in names:
        picked.append(rng.choice(by_song[name]))
        if len(picked) >= want:
            break
    return picked


def _closeness_text(closeness: float) -> str:
    if closeness >= 0.85:
        return ("Stay on his line shapes and his wording. Swap the names, numbers, objects, and places "
                "so that no full line matches a real line. The scene can stay in the same world.")
    if closeness >= 0.45:
        return ("Same voice and the same way of building a line. You may reuse a few of his phrases. "
                "The scene and the details are new.")
    return "Same voice, new lines. Do not reuse his phrases. Match the measured habits only."


WEAK_END_WORDS = frozenset("""
cake sake mall wall day days way ways play plays stay stays say says pay pays lay
grind mind time line game name same fame place space face case chase wait late great
state rate hate gate date plate eight weight way ride side wide hide guide slide sliding tried
cool fool pool school rule do too two true blue through knew view new crew
go low slow flow know show grow throw bro though dough no toe
see be free tea three key me we she he key degree
down town crown clown around sound found ground
right night light sight might fight tight bright white
real steal deal feel heal meal wheel seal peel
""".split())


def end_rich(word: str, lex: p1.Lexicon) -> bool:
    """A rich end word is multi-syllable, or a single-syllable word that is not on the lazy list."""
    w = word.lower().strip("'")
    if w in WEAK_END_WORDS:
        return False
    syl = lex.info(w)[0]
    return syl >= 2 or len(w) >= 5


def build_rhyme_bank(anchor_songs: list[dict], lex: p1.Lexicon) -> list[dict]:
    """End-word rhyme families Gunna actually lands bars on in the anchor songs, most-linked first."""
    family: dict[str, Counter] = defaultdict(Counter)
    linked: Counter = Counter()
    songs_of: dict[str, set] = defaultdict(set)
    for song in anchor_songs:
        info = anchor_lib.style_lines_for(song["lines"])
        for verse in info["real_verses"] or info["style_verses"]:
            bars = [p1.Bar(line, lex) for line in verse]
            for i, bar in enumerate(bars):
                word = bar.end_word
                if not word or not content(word):
                    continue
                key = bar.rime[-1] if (bar.rime and bar.rime[-1]) else None
                if not key:
                    prons = get_word_pronunciations(word, lex)
                    if prons:
                        info_p = p1.analyze_phones(prons[0])
                        key = info_p[2]
                if not key:
                    continue
                family[key][word] += 1
                songs_of[key].add(song["title"])
                if i and end_rhyme_kind(bars[i - 1], bar) in ("perfect", "slant"):
                    linked[key] += 1
    bank = []
    for key, words in family.items():
        if len(words) < 2:
            continue
        ranked = [w for w, _ in words.most_common(12)]
        ranked.sort(key=lambda w: (not end_rich(w, lex), -words[w]))  # rich words first
        rich = [w for w in ranked if end_rich(w, lex)]
        bank.append({"key": key, "words": ranked[:8], "rich_words": rich[:8],
                     "uses": sum(words.values()), "linked": linked[key], "songs": sorted(songs_of[key])[:3]})
    bank.sort(key=lambda f: (-(2 * f["linked"] + f["uses"]), f["key"]))
    return bank


def _pick_family(bank: list[dict], rng: random.Random, used: set[str], size: int) -> dict | None:
    """Weighted by how much he leans on the family, down-weighted by how often this run already used it."""
    rich = [f for f in bank if f["key"] not in used and len(f.get("rich_words") or []) >= size]
    cands = rich or [f for f in bank if f["key"] not in used and len(f["words"]) >= max(size, 3)]
    cands = cands or [f for f in bank if f["key"] not in used and len(f["words"]) >= size]
    if not cands:
        rich = [f for f in bank if len(f.get("rich_words") or []) >= size]
        cands = rich or [f for f in bank if len(f["words"]) >= max(size, 3)]
        cands = cands or [f for f in bank if len(f["words"]) >= size]
    if not cands:
        return None
    weights = [(1 + f["linked"] + 0.3 * f["uses"]) * (1 + len(f.get("rich_words") or []))
               / (1 + _FAMILY_USE[f["key"]]) ** 2 for f in cands]
    return rng.choices(cands, weights=weights)[0]


def _pick_words(fam: dict, size: int, rng: random.Random) -> list[str]:
    rich = list(fam.get("rich_words") or [])
    rng.shuffle(rich)
    rich.sort(key=lambda w: _WORD_USE[w])
    picked = rich[:size]
    if len(picked) < size:
        rest = [w for w in fam["words"] if w not in picked]
        rng.shuffle(rest)
        picked += sorted(rest, key=lambda w: _WORD_USE[w])[:size - len(picked)]
    while len(picked) < size and fam.get("words"):
        picked.append(rng.choice(fam["words"]))
    return picked[:size]


def make_spine(rng: random.Random) -> dict:
    spine = rng.choices(SPINES, weights=[x["weight"] for x in SPINES])[0]
    who = rng.choice(SPINE_PEOPLE) if spine["key"] == "person" else None
    text = spine["text"].format(who=who) if who else spine["text"]
    return {"key": spine["key"], "who": who, "text": text}


def make_rhyme_plan(bank: list[dict], n_bars: int, rng: random.Random, profile: dict,
                    level: str = "rhyme", register: bool = True) -> dict:
    """Pick end words first. For each couplet or 4-bar quatrain (AABB or ABAB),
    assign chosen end words from Gunna's real rhyme families. Every bar has an
    assigned end position. Prefer CMU-perfect rhymes, allowing at most one slant."""
    slots: list[dict | None] = [None] * n_bars
    groups: list[dict] = []
    used: set[str] = set()

    bar_idx = 0
    while bar_idx < n_bars:
        remaining = n_bars - bar_idx
        if remaining >= 4:
            scheme = "aabb" if rng.random() < 0.65 else "abab"
            fam_a = _pick_family(bank, rng, used, 2)
            if fam_a:
                used.add(fam_a["key"])
            fam_b = _pick_family(bank, rng, used, 2)
            if fam_b:
                used.add(fam_b["key"])
            fam_a = fam_a or (bank[0] if bank else {"key": "none", "words": ["one", "run"], "songs": []})
            fam_b = fam_b or (bank[1] if len(bank) > 1 else fam_a)

            words_a = _pick_words(fam_a, 2, rng)
            words_b = _pick_words(fam_b, 2, rng)

            if scheme == "aabb":
                g_a = len(groups)
                slots[bar_idx] = {"group": g_a, "word": words_a[0]}
                slots[bar_idx + 1] = {"group": g_a, "word": words_a[1]}
                groups.append({"lines": [bar_idx, bar_idx + 1], "words": words_a,
                               "key": fam_a["key"], "family": fam_a["words"][:6], "songs": fam_a.get("songs", [])})
                g_b = len(groups)
                slots[bar_idx + 2] = {"group": g_b, "word": words_b[0]}
                slots[bar_idx + 3] = {"group": g_b, "word": words_b[1]}
                groups.append({"lines": [bar_idx + 2, bar_idx + 3], "words": words_b,
                               "key": fam_b["key"], "family": fam_b["words"][:6], "songs": fam_b.get("songs", [])})
            else:
                g_a = len(groups)
                slots[bar_idx] = {"group": g_a, "word": words_a[0]}
                slots[bar_idx + 2] = {"group": g_a, "word": words_a[1]}
                groups.append({"lines": [bar_idx, bar_idx + 2], "words": words_a,
                               "key": fam_a["key"], "family": fam_a["words"][:6], "songs": fam_a.get("songs", [])})
                g_b = len(groups)
                slots[bar_idx + 1] = {"group": g_b, "word": words_b[0]}
                slots[bar_idx + 3] = {"group": g_b, "word": words_b[1]}
                groups.append({"lines": [bar_idx + 1, bar_idx + 3], "words": words_b,
                               "key": fam_b["key"], "family": fam_b["words"][:6], "songs": fam_b.get("songs", [])})
            bar_idx += 4
        elif remaining >= 2:
            fam = _pick_family(bank, rng, used, 2)
            if fam:
                used.add(fam["key"])
            fam = fam or (bank[0] if bank else {"key": "none", "words": ["one", "run"], "songs": []})
            words = _pick_words(fam, 2, rng)
            g_idx = len(groups)
            slots[bar_idx] = {"group": g_idx, "word": words[0]}
            slots[bar_idx + 1] = {"group": g_idx, "word": words[1]}
            groups.append({"lines": [bar_idx, bar_idx + 1], "words": words,
                           "key": fam["key"], "family": fam["words"][:6], "songs": fam.get("songs", [])})
            bar_idx += 2
        else:
            if groups:
                last_g = groups[-1]
                extra_word = _pick_words(fam, 1, rng)[0] if fam else "one"
                last_g["lines"].append(bar_idx)
                last_g["words"].append(extra_word)
                slots[bar_idx] = {"group": len(groups) - 1, "word": extra_word}
            else:
                fam = bank[0] if bank else {"key": "none", "words": ["one"], "songs": []}
                words = _pick_words(fam, 1, rng)
                slots[bar_idx] = {"group": 0, "word": words[0]}
                groups.append({"lines": [bar_idx], "words": words, "key": fam["key"], "family": fam["words"][:6], "songs": []})
            bar_idx += 1

    inner: list[dict] = []
    if level in ("inner", "double"):
        want = max(1, n_bars // 4)
        indices = list(range(n_bars))
        rng.shuffle(indices)
        for i in indices[:want]:
            inner.append({"line": i, "type": "to_end"})
        inner.sort(key=lambda x: x["line"])

    spine = make_spine(rng) if level == "story" else None
    if register:
        with _ANALYZE_LOCK:
            for g in groups:
                _FAMILY_USE[g["key"]] += 1
                _WORD_USE.update(g["words"])
            for x in inner:
                if x.get("key"):
                    _FAMILY_USE[x["key"]] += 1

    return {
        "level": level, "slots": slots, "groups": groups, "inner": inner,
        "doubles": max(1, n_bars // 4) if level == "double" else 0, "spine": spine,
    }


def _plan_text(plan: dict) -> str:
    rows = []
    for i, slot in enumerate(plan["slots"], 1):
        if slot is None:
            rows.append(f"Bar {i}: free (end on any word; do not force a rhyme)")
            continue
        group = plan["groups"][slot["group"]]
        partners = [j + 1 for j in group["lines"] if j != i - 1]
        family_preview = ", ".join(group.get("family", [])[:4])
        if partners and partners[0] < i:
            rel = f"same family as Bar {partners[0]}"
        elif partners:
            rel = f"rhymes with Bar {partners[0]}"
        else:
            rel = "rhymes cleanly"
        rows.append(f"Bar {i} ends with \"{slot['word']}\" ({rel}; family: {family_preview})")
    inner_by_line = {x["line"]: x for x in plan.get("inner") or []}
    for i, row in enumerate(rows):
        x = inner_by_line.get(i)
        if not x:
            continue
        if x["type"] == "to_end":
            rows[i] = row + "; INNER RHYME: a word before the middle of this line rhymes with its end word"
        else:
            rows[i] = row + (f"; INNER RHYME: two words inside this line rhyme with each other "
                             f"(sound like: {', '.join(x['family'])})")
    return (
        "RHYME PLAN (HARD CONSTRAINT). Gunna picks the rhyme first. Every end word below is from a rhyme family "
        "he actually ends lines on in these songs. For each bar, start from the planned end word and write the line "
        "backwards so the sentence lands on it naturally, the way he would say it. If a planned word can't "
        "land without sounding forced, swap it for another word from the exact same family, never for a weird word. "
        "The plan already avoided lazy end words (cake, mall, days, way, place, grind, time, cool, right, slide, real...). "
        "Keep it that way: reach for sharper or longer words.\n"
        + "\n".join(rows)
    )


def build_mimic_prompt(artist: str, n_bars: int, exemplars: list[dict], profile: dict,
                       closeness: float, taste: dict | None = None, plan: dict | None = None,
                       taste_on: bool = True, taste_k: int = 6,
                       store: feedback_store.FeedbackStore | None = None) -> str:
    facts = list(profile.get("prompt_facts") or [])
    if plan and plan.get("inner"):
        facts = [
            fact.replace(
                " Do not force a rhyme inside the line.",
                " Plan an inner rhyme only on a line marked INNER RHYME.",
            )
            for fact in facts
        ]
    parts = [
        f"Write a new {n_bars}-bar verse that sounds like an unreleased outtake from these exact {artist} songs. "
        "A listener should think it was left off one of them.",
        "MEASURED ON THESE SONGS:\n" + "\n".join(f"- {fact}" for fact in facts),
        f"CLOSENESS {closeness:.2f} (0 = new lines in his voice, 1 = his shapes with the specifics swapped):\n"
        + _closeness_text(closeness),
    ]
    if exemplars:
        blocks = []
        for item in exemplars:
            lines = [re.sub(r"\s+", " ", bar).strip() for bar in item["bars"]]
            blocks.append(f'"{item["song"]}"\n' + "\n".join(line for line in lines if line))
        parts.append(
            "REAL VERSES from those songs. The first one is the shape to follow. "
            "Match the flow across the whole verse, not one couplet. Parentheses are his ad-libs; leave that habit.\n\n"
            + "\n\n".join(blocks)
        )

    keeper_block, avoid_block = build_taste_prompt_blocks(
        artist, store=store, k_bars=taste_k, k_reasons=4, taste_on=taste_on, fallback_taste=taste,
    )
    if keeper_block:
        parts.append(keeper_block)
    elif taste and taste.get("liked"):
        keepers = set(taste.get("keepers") or [])
        lines = [f"+ {text}" + ("  KEEPER" if text in keepers else "") for text in taste["liked"]]
        parts.append("BARS THE USER LOVED. This is the target: plain speech, a real place or object, "
                     "a line that makes sense out loud.\n" + "\n".join(lines))

    if avoid_block:
        parts.append(avoid_block)
    elif taste and taste.get("disliked"):
        parts.append("BARS THE USER REJECTED. Never write like these:\n" + "\n".join(
            f"- {text}  ({', '.join(REASON_TEXT.get(reason, reason) for reason in reasons) or 'rejected'})"
            for text, reasons in taste["disliked"]))
    if plan and plan.get("groups"):
        parts.append(_plan_text(plan))
    if plan and plan.get("inner") and plan.get("inner_examples"):
        parts.append("HOW HE DOES INNER RHYMES (real lines from these songs; the rhyming words are in caps):\n"
                     + "\n".join(f"- {line}" for line in plan["inner_examples"]))
    if plan and plan.get("doubles"):
        examples = plan.get("wordplay_examples") or []
        parts.append(
            f"DOUBLE MEANINGS: exactly {plan['doubles']} of the bars must carry a double meaning: one word or phrase "
            "that reads two ways at once (a slang word with two senses, a homophone, a name that is also a thing, "
            "an idiom taken literally). Both readings must make sense in the line and it must still sound like him, "
            "not like a pun contest. For those bars fill \"double_meaning\" with the word and both meanings; "
            "every other bar gets null."
            + ("\nReal examples from his songs, with the two readings:\n" + "\n".join(f"- {e}" for e in examples)
               if examples else ""))
    if plan and plan.get("avoid"):
        parts.append("ALREADY USED A LOT IN THIS BATCH. Pick different subjects, places and objects than: "
                     + ", ".join(plan["avoid"]))
    if plan and plan.get("spine"):
        parts.append(plan["spine"]["text"] + "\n\nThe spine is what the verse is ABOUT; the rhyme plan below is "
                     "only how the ends land. Serve the story first.")
    parts.append(
        "MOST IMPORTANT: read every bar out loud. It has to be a sentence he would actually say, "
        + ("and the verse is one connected story along the spine above, not 8 separate flexes. "
           if plan and plan.get("spine") else "and the verse follows one thread. ")
        + "If a rhyme forces a weird word, change the rhyme, not the sense.\n\n"
        "MUST:\n"
        "1. One line per bar. No line may be identical to a real line of his, including the examples above.\n"
        + ("2. Follow the RHYME PLAN above as a HARD CONSTRAINT: each bar MUST end with its planned end word "
           "(or a valid rhyming word from the same family). Every couplet must rhyme cleanly without exception. "
           if plan and plan.get("groups") else
           "2. Rhyme the way the measured facts describe. Do not force AABB or ABAB. ")
        + ("Follow the INNER RHYME note on each planned line. Lines without that note do not need a rhyme inside them. "
           if plan and plan.get("inner") else
           "Do not force a rhyme inside the line. ")
        + "Do not force a comma into every line.\n"
        "3. Ad-libs in parentheses are allowed, at about the measured rate, usually at the end of the line.\n"
        "4. For each bar write a one-line plain-English meaning. If you cannot say what the bar means, rewrite it.\n\n"
        "Return only JSON:\n"
        + ('{"plan": "...", "bars": [{"bar": "...", "meaning": "...", "double_meaning": '
           '{"word": "...", "meaning_1": "...", "meaning_2": "..."} or null}, ...]}'
           if plan and plan.get("doubles") else
           '{"plan": "...", "bars": [{"bar": "...", "meaning": "...", "source": null}, ...]}')
    )
    return "\n\n".join(parts)


def _rhyme_links(bars: list[p1.Bar]) -> tuple[int, int]:
    links = identical = 0
    for index in range(1, len(bars)):
        kind = end_rhyme_kind(bars[index - 1], bars[index])
        if not kind and index >= 2:
            kind = end_rhyme_kind(bars[index - 2], bars[index])
        if not kind:
            continue
        links += 1
        if kind == "identical":
            identical += 1
    return links, identical


def analyze_mimic(texts: list[str], corpus: Corpus, profile: dict,
                  meanings: list[str] | None = None,
                  plan: dict | None = None,
                  doubles: list | None = None) -> tuple[list[dict], list[str], list[str]]:
    """Hard fails: a copied line, a bar too short to say, page-chrome, or rhyme behavior this era does not use.

    A 4-bar verse with no end rhyme is allowed, because this era rhymes the line before only about
    30% of the time. Sense is not machine-checked. An empty meaning is a note.
    """
    lex = corpus.lex
    bars = [p1.Bar(text, lex) for text in texts]
    rows, problems, notes = [], [], []
    letters: list[str] = []
    for index, (text, bar) in enumerate(zip(texts, bars), 1):
        commas = text.count(",")
        halves = [part.strip() for part in text.split(",", 1)] if commas else [text.strip()]
        half_syl = [syl(part, lex) for part in halves]
        pairs = internal_pairs(bar)
        copied = corpus.full_copy(text)
        meaning = meanings[index - 1] if meanings and index <= len(meanings) else ""
        letter = None
        for earlier in range(index - 1):
            if end_rhyme_kind(bars[earlier], bar) in ("perfect", "slant", "identical"):
                letter = letters[earlier]
                break
        letter = letter or chr(ord("A") + len(set(letters)))
        letters.append(letter)
        if len(bar.words) < 3:
            problems.append(f"bar {index}: too short to be a bar ({len(bar.words)} words after ad-libs)")
        if copied:
            problems.append(f"bar {index}: is a word-for-word copy of a real {corpus.artist} bar")
        if anchor_lib.is_chrome_line(text):
            problems.append(f"bar {index}: looks like scraped page chrome, not a lyric")
        if not meaning.strip():
            notes.append(f"bar {index}: no plain-English meaning, so sense was not checked")
        rows.append({
            "text": text,
            "halves": [{"text": part, "syl": count} for part, count in zip(halves, half_syl)],
            "syllables": bar.syl,
            "end_word": bar.end_word,
            "rhyme_letter": letter,
            "internal": pairs,
            "borrowed": corpus.borrowed(text),
            "meaning": meaning,
            "topic": "mimic",
            "checks": {"not_a_copy": not copied, "long_enough": len(bar.words) >= 3, "has_meaning": bool(meaning.strip())},
        })

    links, identical = _rhyme_links(bars)
    rhyme = profile.get("rhyme") or {}
    dist1 = rhyme.get("dist1_rate") or 0.0
    expected = dist1 * max(0, len(bars) - 1)
    if expected >= 2 and links < 1:
        problems.append(
            f"no end-rhyme links in {len(bars)} bars; a verse this long in the anchor set usually has some "
            f"(about {dist1:.0%} of lines rhyme the line before)"
        )
    identical_only_ok = (profile.get("hard_rhyme") or {}).get("identical_only_ok", False)
    if links >= 3 and identical == links and not identical_only_ok:
        problems.append("every rhyme link repeats the same end word; this era does not rhyme that way")

    for x in (plan or {}).get("inner", []):
        i = x["line"]
        if i < len(bars) and not internal_pairs(bars[i]):
            want = ("a word before the middle that rhymes with the end word" if x["type"] == "to_end"
                    else f"two words inside the line that rhyme (sound like: {', '.join(x['family'])})")
            problems.append(f"line {i + 1} was planned to have an inner rhyme ({want}) but no two words in it rhyme")
    if (plan or {}).get("doubles"):
        dms = (list(doubles or []) + [None] * len(rows))[:len(rows)]
        good = 0
        for row, dm in zip(rows, dms):
            ok = valid_double(dm, row["text"])
            row["double_meaning"] = dm if ok else None
            row["checks"]["double_meaning"] = ok
            good += ok
        if good < plan["doubles"]:
            problems.append(f"needs {plan['doubles']} double meaning(s), found {good}. Each needs the word as it "
                            "appears in the bar plus two different readings that both make sense")
    for group in (plan or {}).get("groups", []):
        lines = [i for i in group["lines"] if i < len(bars)]
        for idx_a in range(len(lines)):
            for idx_b in range(idx_a + 1, len(lines)):
                a, b = lines[idx_a], lines[idx_b]
                kind = end_rhyme_kind(bars[a], bars[b])
                if kind not in ("perfect", "slant"):
                    why = f"repeats the same end word \"{bars[a].end_word}\"" if kind == "identical" else f"do not rhyme (\"{bars[a].end_word}\" / \"{bars[b].end_word}\")"
                    fam_str = ", ".join(group.get("family", [])[:4])
                    problems.append(
                        f"lines {a + 1} and {b + 1} were planned to rhyme (family: {fam_str}) but {why}"
                    )
        for i, want in zip(lines, group.get("words", [])):
            got = bars[i].end_word
            if not got:
                problems.append(f"line {i + 1} has no valid end word")
                continue
            if got != want:
                rhymes_with_plan = (got in group.get("family", [])) or (check_rhyme_kind(got, want, lex) in ("perfect", "slant"))
                if not rhymes_with_plan:
                    fam_str = ", ".join(group.get("family", [])[:4])
                    problems.append(
                        f"line {i + 1} ends on \"{got}\", not the planned \"{want}\" (family: {fam_str}) and does not rhyme with it"
                    )
                else:
                    notes.append(f"line {i + 1} swapped planned \"{want}\" for \"{got}\" (same rhyme family)")

    cadence = profile.get("cadence") or {}
    low, high = cadence.get("syl_p10"), cadence.get("syl_p90")
    if low is not None and high is not None:
        off = [str(index) for index, bar in enumerate(bars, 1) if bar.syl and not (low <= bar.syl <= high)]
        if off:
            notes.append(f"syllables outside the era's middle 80% ({low:.0f}-{high:.0f}) on bars {', '.join(off)}")
    target_rate = (profile.get("adlibs") or {}).get("rate")
    if texts and target_rate is not None:
        rate = sum(1 for text in texts if p1.ADLIB_RE.search(text)) / len(texts)
        if abs(rate - target_rate) > 0.35:
            notes.append(f"ad-lib rate {rate:.0%} vs the era's {target_rate:.0%}")
    weak_hits = [i + 1 for i, b in enumerate(bars) if b.end_word and b.end_word.lower().strip("'") in WEAK_END_WORDS]
    if len(weak_hits) >= max(2, len(bars) // 4):
        notes.append(f"too many lazy end words on lines {', '.join(map(str, weak_hits))}; reach for sharper or multi-syllable rhymes")
    spine = (plan or {}).get("spine")
    if spine and texts:
        joined = " ".join(t.lower() for t in texts)
        if spine["key"] == "come_up":
            if not re.search(r"\b(now|used to|back then|'fore|before|remember|came from|started|first)\b", joined):
                notes.append("spine is a come-up arc but no then/now words appear; the story should move from past to present")
        elif spine["key"] == "person":
            who = (spine.get("who") or "").split()[-1]
            kin = {"mama": ["mama", "momma", "mother"], "brother": ["brother", "bro"], "cousin": ["cousin"],
                   "with": ["she", "her", "shawty", "wife"], "partner": ["partner", "day-one", "nigga", "bro"]}.get(who, [who])
            hits = sum(1 for t in texts if any(re.search(r"\b"+re.escape(k)+r"\b", t.lower()) for k in kin))
            if hits < 2:
                notes.append(f"spine is a recurring person ({spine.get('who')}) but they appear in {hits} bar(s); aim for 3 spread across the verse")
    return rows, problems, notes


def _mimic_retry(prompt: str, texts: list[str], problems: list[str], notes: list[str]) -> str:
    extra = ""
    if notes:
        extra = "\n\nOptional, only if it does not hurt the sense:\n" + "\n".join(f"- {note}" for note in notes)
    return (
        prompt
        + "\n\nYOUR PREVIOUS ATTEMPT:\n"
        + "\n".join(f"{index}. {text}" for index, text in enumerate(texts, 1))
        + "\n\nMUST-FIX:\n"
        + "\n".join(f"- {problem}" for problem in problems)
        + extra
        + "\n\nRewrite the whole verse. Read each bar out loud. Return only the JSON."
    )


def _one_candidate(prompt: str, model: str, n_bars: int, corpus: Corpus, profile: dict,
                   plan: dict | None = None) -> dict:
    attempts = []
    best = None
    for attempt in range(1, MIMIC_ATTEMPTS + 1):
        raw = call_model(prompt, model)
        parsed = parse_bars(raw, n_bars)
        if not parsed:
            attempts.append({"attempt": attempt, "error": "no usable JSON"})
            continue
        texts, meanings = parsed
        doubles = parse_field(raw, "double_meaning", n_bars) if plan and plan.get("doubles") else None
        with _ANALYZE_LOCK:
            rows, problems, notes = analyze_mimic(texts, corpus, profile, meanings, plan, doubles)
        attempts.append({"attempt": attempt, "bars": texts, "problems": problems, "notes": notes})
        if best is None or (len(problems), len(notes)) < (len(best[1]), len(best[2])):
            best = (rows, problems, notes, texts)
        if not problems:
            break
        prompt = _mimic_retry(prompt, texts, problems, notes)
    if best is None:
        return {"bars": [], "problems": ["no usable output from model"], "notes": [], "passed": False, "attempts": attempts}
    rows, problems, notes, _texts = best
    if not problems and rows:
        with _ANALYZE_LOCK:
            _SUBJECT_USE.update({w for row in rows for w in p1.Bar(row["text"], corpus.lex).words
                                 if content(w) and len(w) > 3})
    return {"bars": rows, "problems": problems, "notes": notes, "passed": not problems and bool(rows), "attempts": attempts}


def run_mimic(ctx: dict, model: str, corpus: Corpus, profile: dict, n_candidates: int) -> dict:
    """Generate N verses, drop hard-rule failures and duplicate texts, rank the rest by gunna_score."""
    started = time.time()
    base_seed = ctx["seed"]
    master = random.Random(base_seed)
    candidates = []
    seen: set[tuple[str, ...]] = set()
    jobs = []
    for index in range(n_candidates):
        child_seed = master.randrange(1 << 30) if base_seed is None else base_seed + index * 17
        rng = random.Random(child_seed)
        exemplars = pick_exemplars(ctx["bank"], rng, ctx["closeness"], index)
        plan = make_rhyme_plan(ctx["rhyme_bank"], ctx["n_bars"], rng, profile, ctx.get("level", "rhyme"))
        if plan["inner"] and ctx.get("inner_examples"):
            plan["inner_examples"] = rng.sample(ctx["inner_examples"], min(5, len(ctx["inner_examples"])))
        if plan["doubles"] and ctx.get("wordplay_examples"):
            plan["wordplay_examples"] = rng.sample(ctx["wordplay_examples"], min(6, len(ctx["wordplay_examples"])))
        with _ANALYZE_LOCK:
            plan["avoid"] = [w for w, c in _SUBJECT_USE.most_common(14) if c >= 2]
        prompt = build_mimic_prompt(
            ctx["artist"], ctx["n_bars"], exemplars, profile, ctx["closeness"],
            ctx.get("taste"), plan,
            taste_on=ctx.get("taste_on", True),
            taste_k=ctx.get("taste_k", 6),
            store=ctx.get("store"),
        )
        jobs.append((index, prompt, exemplars, plan))

    def _run_job(job: tuple) -> tuple:
        index, prompt, exemplars, plan = job
        one = _one_candidate(prompt, model, ctx["n_bars"], corpus, profile, plan)
        one["rhyme_plan"] = {k: v for k, v in plan.items() if k not in ("inner_examples", "wordplay_examples")}
        return index, one, exemplars

    if _CALLER == "omni" and n_candidates > 1:
        with ThreadPoolExecutor(max_workers=min(4, n_candidates)) as pool:
            finished = list(pool.map(_run_job, jobs))
    else:
        finished = [_run_job(job) for job in jobs]
    finished.sort(key=lambda item: item[0])

    for index, one, exemplars in finished:
        texts = [row["text"] for row in one["bars"]]
        key = tuple(p1.norm_line(text) for text in texts)
        duplicate = bool(key) and key in seen
        if key and not duplicate:
            seen.add(key)
        style_score_val = style_scorer.score(texts) if texts else None
        scored = gunna_score.score_lines(texts, profile, corpus.lex) if texts else {"score": None, "parts": {}}
        one.update({
            "candidate": index + 1,
            "model": model,
            "duplicate": duplicate,
            "passed_hard": bool(one["passed"]) and not duplicate,
            "style_score": style_score_val,
            "gunna_score": round(style_score_val * 100.0, 1) if style_score_val is not None else scored.get("score"),
            "legacy_gunna_score": scored.get("score"),
            "score_parts": scored.get("parts") or {},
            "exemplar_songs": [item["song"] for item in exemplars],
            "exemplars": exemplars,
        })
        candidates.append(one)
        score_text = "n/a" if style_score_val is None else f"{style_score_val:.3f}"
        print(
            f"  candidate {index + 1}/{n_candidates}: "
            f"{'pass' if one['passed_hard'] else 'drop'} style_score {score_text}",
            file=sys.stderr, flush=True,
        )

    viable = [row for row in candidates if row["passed_hard"]]
    if not viable:
        print("#warning: no candidate passed hard rules; keeping candidate with fewest problems", file=sys.stderr, flush=True)
        viable = sorted([row for row in candidates if row.get("bars")], key=lambda r: (len(r.get("problems", [])), len(r.get("notes", []))))
    scorer_model = style_scorer.load()
    if scorer_model and style_scorer.passes_gate():
        ranked = sorted(
            viable,
            key=lambda row: (-(row.get("style_score") or -1.0), len(row["notes"]), row["candidate"]),
        )
    else:
        print("#warning: scorer below gate", file=sys.stderr, flush=True)
        ranked = sorted(viable, key=lambda row: (len(row["notes"]), row["candidate"]))
    produced = [tuple(p1.norm_line(bar["text"]) for bar in row["bars"]) for row in candidates if row["bars"]]
    all_identical = len(produced) > 1 and len(set(produced)) == 1
    winner = ranked[0] if ranked else None
    runner = ranked[1] if len(ranked) > 1 else None
    elapsed = round(time.time() - started, 1)

    def pack(row: dict | None) -> dict:
        if row is None:
            return {
                "model": model, "bars": [], "problems": ["no candidate passed the hard rules"],
                "notes": [], "passed": False, "attempts": [], "elapsed_s": elapsed,
                "gunna_score": None, "score_parts": {}, "exemplars": [], "exemplar_songs": [],
            }
        return {
            "model": model, "bars": row["bars"], "problems": row["problems"], "notes": row["notes"],
            "passed": True, "attempts": row["attempts"], "elapsed_s": elapsed,
            "gunna_score": row["gunna_score"], "score_parts": row["score_parts"],
            "exemplars": row["exemplars"], "exemplar_songs": row["exemplar_songs"],
            "rhyme_plan": row.get("rhyme_plan"),
        }

    public = []
    for row in candidates:
        public.append({
            "candidate": row["candidate"],
            "gunna_score": row["gunna_score"],
            "score_parts": row["score_parts"],
            "passed_hard": row["passed_hard"],
            "duplicate": row["duplicate"],
            "problems": row["problems"],
            "notes": row["notes"],
            "bars": [bar["text"] for bar in row["bars"]],
            "exemplar_songs": row["exemplar_songs"],
            "rhyme_plan": row.get("rhyme_plan"),
        })
    return {
        "winner": pack(winner),
        "runner_up": pack(runner) if runner else None,
        "candidates": public,
        "all_identical": all_identical,
        "elapsed_s": elapsed,
        "passed_n": len(ranked),
    }


def anchor_inner_examples(anchor_songs: list[dict], lex: p1.Lexicon, limit: int = 60) -> list[str]:
    """Real anchor-song lines with an inner rhyme, rhyming words in caps."""
    out: list[str] = []
    for song in anchor_songs:
        info = anchor_lib.style_lines_for(song["lines"])
        for verse in info["real_verses"] or info["style_verses"]:
            for line in verse:
                bar = p1.Bar(line, lex)
                pairs = internal_pairs(bar)
                if not pairs or len(bar.words) < 5:
                    continue
                marked = set(pairs[0])
                text = " ".join(w.upper() if w.lower().strip("',.!?()") in marked else w for w in line.split())
                out.append(text)
    seen, uniq = set(), []
    for text in out:
        if text.lower() not in seen:
            seen.add(text.lower())
            uniq.append(text)
    return uniq[:limit]


def load_wordplay_examples() -> list[str]:
    """Confirmed Gunna-song wordplay from Play-on-Words where both readings sit on the line."""
    if not WORDPLAY_FILE.exists():
        return []
    strong = {"double_meaning", "pun", "homophone", "sound_flip", "idiom_flip"}
    out, seen = [], set()
    for line in open(WORDPLAY_FILE, encoding="utf-8"):
        try:
            r = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not r.get("kept") or r.get("halves_class") != "BOTH_ON_LINE" or r.get("bar") in seen:
            continue
        note = (r.get("note_excerpt") or "").strip()
        if r.get("signal_type") not in strong and not re.search(r"double|play on|pun|also (means|refers)|two meanings",
                                                                 note.lower()):
            continue
        seen.add(r["bar"])
        first = re.split(r"(?<=[.!?])\s", note, maxsplit=1)[0][:180]
        out.append(f"\"{r['bar']}\": {r.get('partner') or ''}. {first}")
    return out


def _preview_plan(bank, n_bars, seed, profile, level, inner_examples, wordplay_examples) -> dict:
    rng = random.Random(seed)
    plan = make_rhyme_plan(bank, n_bars, rng, profile, level, register=False)
    plan["inner_examples"] = inner_examples[:5]
    plan["wordplay_examples"] = wordplay_examples[:6]
    return plan


def build_mimic_context(artist: str, n_bars: int, seed: int | None, closeness: float,
                        profile: dict, anchor_songs: list[dict], taste: dict | None = None,
                        skip_keys: set[str] | None = None, lex: p1.Lexicon | None = None,
                        level: str = "rhyme", taste_on: bool = True, taste_k: int = 6,
                        store: feedback_store.FeedbackStore | None = None) -> dict:
    bank = anchor_verse_bank(anchor_songs, skip_keys)
    rhyme_bank = build_rhyme_bank(anchor_songs, lex)
    inner_examples = anchor_inner_examples(anchor_songs, lex) if level in ("inner", "double") else []
    wordplay_examples = load_wordplay_examples() if level == "double" else []
    if not bank:
        raise SystemExit("no 8-bar stretch in the anchor songs")
    taste = taste if taste is not None else load_taste(artist)
    sample = pick_exemplars(bank, random.Random(seed), closeness, 0)
    return {
        "artist": artist,
        "n_bars": n_bars,
        "topic": "mimic",
        "scheme": "anchor",
        "seed": seed,
        "mode": "mimic",
        "closeness": closeness,
        "profile": profile,
        "bank": bank,
        "rhyme_bank": rhyme_bank,
        "level": level,
        "inner_examples": inner_examples,
        "wordplay_examples": wordplay_examples,
        "taste": taste,
        "taste_on": taste_on,
        "taste_k": taste_k,
        "store": store,
        "exemplars": sample,
        "couplets": [],
        "prompt_version": LEVEL_VERSION[level],
        "prompt": build_mimic_prompt(artist, n_bars, sample, profile, closeness, taste,
                                     _preview_plan(rhyme_bank, n_bars, seed, profile, level,
                                                   inner_examples, wordplay_examples),
                                     taste_on=taste_on, taste_k=taste_k, store=store),
    }


def log_mimic_result(store: feedback_store.FeedbackStore, ctx: dict, result: dict) -> str | None:
    bars = result.get("bars") or []
    if not bars:
        return None
    exemplars = result.get("exemplars") or ctx.get("exemplars") or []
    for row in bars:
        row["sources"] = [
            {"kind": "catalog_bar", "ref": item["song"], "category": "anchor"} for item in exemplars[:3]
        ]
        row["topic"] = "mimic"
    return store.log_generation(
        artist=ctx["artist"], bars=bars,
        request={
            "bars_requested": ctx["n_bars"], "topic": "mimic", "scheme": "anchor", "mode": "mimic",
            "seed": ctx["seed"], "closeness": ctx["closeness"], "problems": result.get("problems"),
            "gunna_score": result.get("gunna_score"),
        },
        model=result.get("model", ""), prompt_version=ctx.get("prompt_version", MIMIC_PROMPT_VERSION))


def mimic_document(ctx: dict, model: str, packed: dict, generation_ids: dict) -> dict:
    """phase6.v2 superset. `models` has the top two verses the rating page shows."""
    winner = packed["winner"]
    models = {}
    if winner["bars"]:
        models[model] = {**{key: winner[key] for key in (
            "model", "bars", "problems", "notes", "passed", "attempts", "elapsed_s", "gunna_score", "score_parts",
            "rhyme_plan")},
            "generation_id": generation_ids.get("winner")}
    runner = packed["runner_up"]
    if runner and runner["bars"]:
        models[f"{model}_2"] = {**{key: runner[key] for key in (
            "model", "bars", "problems", "notes", "passed", "attempts", "elapsed_s", "gunna_score", "score_parts",
            "rhyme_plan")},
            "generation_id": generation_ids.get("runner")}
    cadence = ctx["profile"].get("cadence") or {}
    return {
        "schema": SCHEMA_VERSION,
        "prompt_version": ctx.get("prompt_version", MIMIC_PROMPT_VERSION),
        "generation_id": generation_ids.get("winner"),
        "artist": ctx["artist"],
        "topic": "mimic",
        "topic_brief": "unreleased outtake from the anchor songs",
        "scheme": "anchor",
        "mode": "mimic",
        "closeness": ctx["closeness"],
        "bars_requested": ctx["n_bars"],
        "seed": ctx["seed"],
        "model": model,
        "bars": winner["bars"],
        "problems": winner["problems"],
        "notes": winner["notes"],
        "passed": winner["passed"],
        "attempts": winner["attempts"],
        "elapsed_s": packed["elapsed_s"],
        "gunna_score": winner.get("gunna_score"),
        "score_parts": winner.get("score_parts") or {},
        "rhyme_plan": winner.get("rhyme_plan"),
        "rhyme_first": bool(ctx.get("rhyme_bank")),
        "candidates_requested": len(packed["candidates"]),
        "candidates_passed": packed["passed_n"],
        "all_identical": packed["all_identical"],
        "candidates": packed["candidates"],
        "syl_range": [cadence.get("syl_p10"), cadence.get("syl_p90")],
        "exemplars": winner.get("exemplars") or ctx["exemplars"],
        "couplets": [],
        "models": models,
    }


# ---------------------------------------------------------------- context + main


def build_context(artist: str, n_bars: int, topic: str | None, scheme: str, seed: int | None,
                  corpus: Corpus, mode: str = "rewrite", closeness: float = 0.7,
                  profile: dict | None = None, n_candidates: int = 8,
                  taste_on: bool = True, taste_k: int = 6,
                  store: feedback_store.FeedbackStore | None = None) -> dict:
    if mode == "mimic":
        raise SystemExit("mimic mode uses build_mimic_context(), not build_context()")
    rng = random.Random(seed)
    grades, rollup, chains = load_style(artist)
    topic = topic or pick_topic(chains, corpus, rng)
    on_topic = corpus.topic_passages(topic)
    rng.shuffle(on_topic)
    if mode == "rewrite":
        exemplars = on_topic[:3] + corpus.voice_passages(rng, 4)
        couplets = find_couplets(corpus, topic, rng, n=8)
    else:
        exemplars = on_topic[:6] + corpus.voice_passages(rng, 10 if len(on_topic) < 3 else 6)
        couplets = []
    taste = load_taste(artist)
    return {
        "artist": artist, "n_bars": n_bars, "topic": topic, "scheme": scheme, "seed": seed, "mode": mode,
        "exemplars": exemplars, "couplets": couplets, "taste": taste,
        "taste_on": taste_on, "taste_k": taste_k, "store": store,
        "prompt": build_prompt(artist, n_bars, topic, scheme, exemplars, grades, rollup, mode, couplets, taste,
                               taste_on=taste_on, taste_k=taste_k, store=store),
    }


def blocks_in(text: str, catalog: dict) -> list[dict]:
    words = p1.norm_line(text).split()
    hits = []
    for n in range(min(4, len(words)), 0, -1):
        for i in range(len(words) - n + 1):
            g = " ".join(words[i:i + n])
            for blk in catalog.get(g, []):
                hits.append({"kind": "block", "ref": g, "category": blk.get("category")})
    return hits


def load_blocks_catalog() -> dict[str, list[dict]]:
    by_norm: dict[str, list[dict]] = defaultdict(list)
    path = OUT / "blocks_catalog.jsonl"
    if path.exists():
        for line in open(path, encoding="utf-8"):
            r = json.loads(line)
            by_norm[r["norm"]].append(r)
    return by_norm


def log_result(store: feedback_store.FeedbackStore, ctx: dict, result: dict, catalog: dict) -> str:
    for r in result["bars"]:
        r["sources"] = blocks_in(r["text"], catalog) + [
            {"kind": "catalog_bar", "ref": f'{p["song"]}', "category": p["topic"] or "voice"} for p in ctx["exemplars"][:3]]
    return store.log_generation(
        artist=ctx["artist"], bars=result["bars"],
        request={"bars_requested": ctx["n_bars"], "topic": ctx["topic"], "scheme": ctx["scheme"], "mode": ctx["mode"],
                 "seed": ctx["seed"], "problems": result["problems"]},
        model=result["model"], prompt_version=PROMPT_VERSION)


def _mimic_self_check() -> int:
    """Prompt and hard-rule checks on made-up lines. Does not read the lyric CSV or call a model."""

    class _Stub:
        def info(self, word):
            return (1, 0, "AY", None, True)

        def phones_for(self, word):
            return ["AY1"]

    lex = _Stub()
    real = "I left the spot with the roof down tonight"
    corpus = Corpus("Gunna", lex, songs=[("Example", [real, "another real line from the catalog here"])])
    profile = {
        "prompt_facts": ["Measured line length in this era: median 9 syllables."],
        "rhyme": {"dist1_rate": 0.29, "identical_share": 0.12},
        "hard_rhyme": {"min_any_links": 1, "identical_only_ok": False},
        "cadence": {"syl_p10": 5, "syl_p90": 15},
        "adlibs": {"rate": 0.39, "position": {"end": 0.94}},
        "targets": {},
    }
    exemplars = [{"song": "Example", "bars": ["I pulled up (yeah)", "she met me at the light"], "topic": None}]
    prompt = build_mimic_prompt("Gunna", 4, exemplars, profile, 0.7, {
        "liked": ["a keeper line"], "keepers": ["a keeper line"], "disliked": [("a bad line", ["no_sense"])],
    })
    assert "unreleased outtake" in prompt
    assert "money_flex" not in prompt
    assert "(yeah)" in prompt
    assert "KEEPER" in prompt
    assert "Measured line length" in prompt
    fresh = [
        "I left the meter running on the dash tonight",
        "she said the car was sitting on the side",
        "I told her pull it round the back and wait",
        "the light on the corner stayed on late",
    ]
    _rows, problems, _notes = analyze_mimic(fresh, corpus, profile, ["a", "b", "c", "d"])
    assert not problems, problems
    copied, problems, _notes = analyze_mimic([real, fresh[1], fresh[2], fresh[3]], corpus, profile, ["a"] * 4)
    assert any("word-for-word" in problem for problem in problems), problems
    _rows, problems, notes = analyze_mimic(["yeah", fresh[1], fresh[2], fresh[3]], corpus, profile, ["", "b", "c", "d"])
    assert any("too short" in problem for problem in problems)
    assert any("no plain-English" in note for note in notes)
    bank = anchor_verse_bank([{"title": "Example", "lines": [f"line {i} keeps moving through the night" for i in range(20)]}])
    assert bank and all(8 <= len(item["bars"]) <= 16 for item in bank)
    banned = p1.norm_line("line 3 keeps moving through the night")
    filtered = anchor_verse_bank(
        [{"title": "Example", "lines": [f"line {i} keeps moving through the night" for i in range(20)]}],
        {banned},
    )
    assert filtered and all(banned not in [p1.norm_line(bar) for bar in item["bars"]] for item in filtered)
    rhyme_bank = [{
        "key": "ay", "words": ["night", "light", "right", "tight", "sight", "fight"],
        "linked": 4, "uses": 3, "songs": ["Example"],
    }]
    rhyme_profile = {"rhyme": {"dist1_rate": 0.5, "alt_rate": 0.1, "run3_share": 0.2}}
    rhyme_plan = make_rhyme_plan(rhyme_bank, 8, random.Random(1), rhyme_profile, "rhyme", register=False)
    inner_plan = make_rhyme_plan(rhyme_bank, 8, random.Random(1), rhyme_profile, "inner", register=False)
    double_plan = make_rhyme_plan(rhyme_bank, 8, random.Random(1), rhyme_profile, "double", register=False)
    assert rhyme_plan["groups"] and not rhyme_plan["inner"] and rhyme_plan["doubles"] == 0
    assert inner_plan["inner"] and inner_plan["doubles"] == 0
    assert double_plan["doubles"] == 2 and double_plan["inner"]
    taste = {"liked": ["a keeper line"], "keepers": ["a keeper line"], "disliked": [("a bad line", ["no_sense"])]}
    inner_prompt = build_mimic_prompt("Gunna", 8, exemplars, profile, 0.7, taste, inner_plan)
    rhyme_prompt = build_mimic_prompt("Gunna", 8, exemplars, profile, 0.7, taste, rhyme_plan)
    double_prompt = build_mimic_prompt("Gunna", 8, exemplars, profile, 0.7, taste, {
        **double_plan, "wordplay_examples": ['"ice": frozen water / jewelry'],
    })
    assert "INNER RHYME" in inner_prompt
    assert "Do not force a rhyme inside the line" not in inner_prompt
    assert "Do not force a rhyme inside the line" in rhyme_prompt
    fact_profile = {
        **profile,
        "prompt_facts": ["Internal rhymes show up on 25% of lines. Do not force a rhyme inside the line."],
    }
    filtered = build_mimic_prompt("Gunna", 8, exemplars, fact_profile, 0.7, taste, inner_plan)
    kept_fact = build_mimic_prompt("Gunna", 8, exemplars, fact_profile, 0.7, taste, rhyme_plan)
    assert "Do not force a rhyme inside the line" not in filtered
    assert "marked INNER RHYME" in filtered
    assert "Do not force a rhyme inside the line" in kept_fact
    assert "DOUBLE MEANINGS" in double_prompt and "double_meaning" in double_prompt
    raw = json.dumps({"bars": [
        {"bar": "  ", "double_meaning": {"word": "skip", "meaning_1": "a", "meaning_2": "b"}},
        {"bar": fresh[0], "meaning": "a", "double_meaning": {
            "word": "meter", "meaning_1": "a taxi meter", "meaning_2": "a measurement"}},
    ]})
    parsed = parse_field(raw, "double_meaning", 1)
    assert valid_double(parsed[0], fresh[0]), parsed
    missing, problems, _notes = analyze_mimic(fresh, corpus, profile, ["a", "b", "c", "d"], {"doubles": 1}, [None] * 4)
    assert any("double meaning" in problem for problem in problems), problems
    kept, problems, _notes = analyze_mimic(
        fresh, corpus, profile, ["a", "b", "c", "d"], {"doubles": 1}, [parsed[0], None, None, None])
    assert not any("double meaning" in problem for problem in problems), problems
    assert kept[0]["checks"]["double_meaning"] is True
    _rows, problems, _notes = analyze_mimic(
        fresh, corpus, profile, ["a", "b", "c", "d"], {"inner": [{"line": 0, "type": "to_end"}]})
    assert not any("inner rhyme" in problem for problem in problems), problems
    print("phase6 mimic self-check ok")
    return 0


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] == "self-check":
        return _mimic_self_check()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--artist", required=True)
    ap.add_argument("--bars", type=int, default=4)
    ap.add_argument("--model", default=MODEL_DEFAULT, choices=MODELS)
    ap.add_argument("--caller", default="claude", choices=("claude", "omni"),
                    help="claude uses claude -p. omni uses local OmniRoute and stores that model name")
    ap.add_argument("--omni-model", default=OMNI_MODEL_DEFAULT,
                    help="OmniRoute model id used when --caller omni")
    ap.add_argument("--topic", help="Phase 4 topic label, e.g. money_flex (default: sampled from the artist's mix)")
    ap.add_argument("--scheme", default="aabb", choices=SCHEMES)
    ap.add_argument("--mode", default="rewrite", choices=MODES,
                    help="rewrite = adapt real couplets (default); fresh = write from scratch; mimic = anchor-set outtake")
    ap.add_argument("--closeness", type=float, default=0.7,
                    help="mimic only. 1 keeps his line shapes and swaps specifics; 0 is the same voice, new lines")
    ap.add_argument("--candidates", type=int, default=8,
                    help="mimic only. generate this many verses, keep the top 2 that pass the hard rules")
    ap.add_argument("--profile", type=Path, default=OUT / "anchor_profile_gunna.json")
    ap.add_argument("--seed", type=int)
    ap.add_argument("--level", default="rhyme", choices=MIMIC_LEVELS,
                    help="mimic only. rhyme = rhyme-first end words; inner = + planned inner rhymes; "
                         "double = + double meanings")
    ap.add_argument("--sets", type=int, default=1,
                    help="mimic only. write this many sets. seeds step by 1 from --seed (or from 1)")
    ap.add_argument("--out", type=Path, default=None,
                    help="mimic only. one set writes this file. several sets write mimic_01.json inside this directory")
    ap.add_argument("--taste", choices=("on", "off"), default="on",
                    help="feed keeper bars and avoid notes from feedback_store (default: on)")
    ap.add_argument("--taste-k", type=int, default=6,
                    help="number of keeper bars to include in prompt (default: 6)")
    ap.add_argument("--db", type=Path, default=OUT / "feedback.sqlite" if (OUT / "feedback.sqlite").exists() else OUT / "feedback.db")
    ap.add_argument("--show-prompt", action="store_true", help="print the prompt to stderr")
    args = ap.parse_args()

    if args.caller == "omni":
        global _CALLER
        _CALLER = "omni"
        args.model = args.omni_model
    if args.mode == "mimic":
        return _main_mimic(args)

    lex = get_lexicon()
    corpus = Corpus(args.artist, lex)
    store = feedback_store.FeedbackStore(str(args.db))
    ctx = build_context(args.artist, args.bars, args.topic, args.scheme, args.seed, corpus, args.mode,
                        taste_on=(args.taste == "on"), taste_k=args.taste_k, store=store)
    if args.show_prompt:
        print(ctx["prompt"], file=sys.stderr)
    result = run_model(ctx, args.model, corpus)
    gid = log_result(store, ctx, result, load_blocks_catalog())
    print(json.dumps({"schema": SCHEMA_VERSION, "generation_id": gid, "artist": args.artist,
                      "topic": ctx["topic"], "scheme": ctx["scheme"], **result}, ensure_ascii=False, indent=1))
    return 0


def _skipped_line_count(song: dict, skip: set[str]) -> int:
    seen: set[str] = set()
    count = 0
    for text in song["lines"]:
        key = p1.norm_line(text)
        if not key or key in seen:
            continue
        seen.add(key)
        if key in skip:
            count += 1
    return count


def _write_one_mimic(args, profile: dict, matched: list[dict], corpus: Corpus,
                     skip: set[str], seed: int | None, out_path: Path, dump_stdout: bool,
                     store: feedback_store.FeedbackStore | None = None) -> dict:
    if store is None:
        store = feedback_store.FeedbackStore(str(args.db))
    ctx = build_mimic_context(
        args.artist, args.bars, seed, args.closeness, profile, matched, skip_keys=skip,
        lex=corpus.lex, level=args.level,
        taste_on=(args.taste == "on"), taste_k=args.taste_k, store=store)
    print(
        f"SET_START seed {seed} level {args.level}  {len(ctx['bank'])} stretches, "
        f"{len(ctx['rhyme_bank'])} rhyme families, {len(ctx['inner_examples'])} inner examples, "
        f"{len(ctx['wordplay_examples'])} wordplay examples",
        file=sys.stderr, flush=True,
    )
    if args.show_prompt:
        print(ctx["prompt"], file=sys.stderr)
    try:
        packed = run_mimic(ctx, args.model, corpus, profile, args.candidates)
    except OmniDown as exc:
        raise SystemExit(f"BATCH_FAILED {exc}") from exc
    if not any(row.get("bars") for row in packed["candidates"]):
        raise SystemExit(
            f"BATCH_FAILED seed {seed}: model returned no verses. not writing {out_path.name}"
        )
    ids = {
        "winner": log_mimic_result(store, ctx, packed["winner"]),
        "runner": log_mimic_result(store, ctx, packed["runner_up"]) if packed["runner_up"] else None,
    }
    document = mimic_document(ctx, args.model, packed, ids)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(document, ensure_ascii=False, indent=1), encoding="utf-8")
    winner = packed["winner"]
    runner = packed["runner_up"] or {}
    summary = {
        "file": str(out_path.resolve()),
        "seed": seed,
        "model": args.model,
        "bars": args.bars,
        "closeness": args.closeness,
        "candidates_requested": args.candidates,
        "candidates_passed": packed["passed_n"],
        "all_identical": packed["all_identical"],
        "winner_id": ids["winner"],
        "runner_id": ids["runner"],
        "winner_score": winner.get("gunna_score"),
        "runner_score": runner.get("gunna_score"),
        "exemplar_songs": winner.get("exemplar_songs") or [],
        "winner_bars": len(winner.get("bars") or []),
        "runner_bars": len(runner.get("bars") or []),
    }
    print(
        f"SET_DONE seed {seed} passed {packed['passed_n']}/{args.candidates} "
        f"winner {ids['winner']} score {winner.get('gunna_score')} "
        f"runner {ids['runner']} wrote {out_path}",
        file=sys.stderr, flush=True,
    )
    if packed["all_identical"]:
        print("all candidates were the same verse. call_model has no temperature knob.", file=sys.stderr, flush=True)
    if dump_stdout:
        print(json.dumps(document, ensure_ascii=False, indent=1))
    return summary


def _main_mimic(args) -> int:
    if args.artist.lower() != "gunna":
        raise SystemExit("mimic mode is built for Gunna and the anchor set")
    if args.bars not in MIMIC_BARS:
        raise SystemExit("--bars for mimic must be 4, 8, or 16")
    if not 0.0 <= args.closeness <= 1.0:
        raise SystemExit("--closeness must be between 0 and 1")
    if args.candidates < 1:
        raise SystemExit("--candidates must be at least 1")
    if args.sets < 1:
        raise SystemExit("--sets must be at least 1")
    profile = gunna_score.load_profile(args.profile)
    calls = args.sets * args.candidates * MIMIC_ATTEMPTS
    print(
        f"mimic: {args.sets} set(s), {args.bars} bars, closeness {args.closeness}, "
        f"{args.candidates} candidates, up to {calls} {_CALLER} calls on {args.model}. "
        "Hard rules are copy, length, and rhyme behavior. Sense is not machine-checked.",
        file=sys.stderr, flush=True,
    )
    gunna = anchor_lib.load_gunna(p1.DEFAULT_CSV)
    matched, missing = anchor_lib.match_anchors(gunna)
    if missing:
        raise SystemExit("anchor titles not in the CSV: " + ", ".join(missing))
    skip = anchor_lib.shared_long_line_keys(gunna)
    for song in matched:
        dropped = _skipped_line_count(song, skip)
        if dropped:
            print(
                f"  exemplars skip {dropped} shared lines (4+ words) in "
                f"{song['title']} [{song['album']}]",
                file=sys.stderr, flush=True,
            )
    lex = get_lexicon()
    corpus = Corpus(args.artist, lex, songs=anchor_lib.copy_songs(gunna))
    store = feedback_store.FeedbackStore(str(args.db))
    if args.sets == 1:
        out_path = args.out or (OUT / "mimic_comparison.json")
        _write_one_mimic(args, profile, matched, corpus, skip, args.seed, out_path, True, store=store)
        print(f"wrote {out_path}  (drop this on the rating page; top 2 are under models)", file=sys.stderr, flush=True)
        return 0
    dest = args.out or (OUT / "rater-batch")
    if dest.suffix == ".json":
        raise SystemExit("--out must be a directory when --sets is greater than 1")
    dest.mkdir(parents=True, exist_ok=True)
    base = 1 if args.seed is None else args.seed
    manifest = []
    for index in range(args.sets):
        seed = base + index
        out_path = dest / f"mimic_{seed:02d}.json"
        manifest.append(_write_one_mimic(
            args, profile, matched, corpus, skip, seed, out_path, False, store=store))
    manifest_path = dest / "mimic_manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"BATCH_DONE {len(manifest)} sets, manifest {manifest_path}", file=sys.stderr, flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
