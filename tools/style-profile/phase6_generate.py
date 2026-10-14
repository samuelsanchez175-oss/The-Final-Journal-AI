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

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

SCHEMA_VERSION = "phase6.v2"
PROMPT_VERSION = "verse.v5"
MODELS = ("haiku", "sonnet", "opus")
MODEL_DEFAULT = "sonnet"
SCHEMES = ("aabb", "abab")
MODES = ("rewrite", "fresh", "mimic")
MIMIC_PROMPT_VERSION = "verse.mimic.v1"
MIMIC_BARS = (4, 8, 16)
MIMIC_ATTEMPTS = 2
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


# ---------------------------------------------------------------- prompt


def build_prompt(artist: str, n_bars: int, topic: str, scheme: str, exemplars: list[dict],
                 grades: dict, rollup: dict, mode: str = "rewrite", couplets: list[dict] | None = None,
                 taste: dict | None = None) -> str:
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
    if taste and taste.get("liked"):
        parts.append("BARS THE USER LOVED. This is the target: plain speech, real places and people, "
                     "a small story, nothing bent to fit a rhyme.\n" + "\n".join(f"+ {t}" for t in taste["liked"]))
    if taste and taste.get("disliked"):
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


def end_rhyme_kind(a: p1.Bar, b: p1.Bar) -> str | None:
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


def build_mimic_prompt(artist: str, n_bars: int, exemplars: list[dict], profile: dict,
                       closeness: float, taste: dict | None) -> str:
    facts = profile.get("prompt_facts") or []
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
    if taste and taste.get("liked"):
        keepers = set(taste.get("keepers") or [])
        lines = [f"+ {text}" + ("  KEEPER" if text in keepers else "") for text in taste["liked"]]
        parts.append("BARS THE USER LOVED. This is the target: plain speech, a real place or object, "
                     "a line that makes sense out loud.\n" + "\n".join(lines))
    if taste and taste.get("disliked"):
        parts.append("BARS THE USER REJECTED. Never write like these:\n" + "\n".join(
            f"- {text}  ({', '.join(REASON_TEXT.get(reason, reason) for reason in reasons) or 'rejected'})"
            for text, reasons in taste["disliked"]))
    parts.append(
        "MOST IMPORTANT: read every bar out loud. It has to be a sentence he would actually say, "
        "and the verse follows one thread. If a rhyme forces a weird word, change the rhyme, not the sense.\n\n"
        "MUST:\n"
        "1. One line per bar. No line may be identical to a real line of his, including the examples above.\n"
        "2. Rhyme the way the measured facts describe. Do not force AABB or ABAB. "
        "Do not force a comma into every line. Do not force a rhyme inside the line.\n"
        "3. Ad-libs in parentheses are allowed, at about the measured rate, usually at the end of the line.\n"
        "4. For each bar write a one-line plain-English meaning. If you cannot say what the bar means, rewrite it.\n\n"
        "Return only JSON:\n"
        '{"plan": "...", "bars": [{"bar": "...", "meaning": "...", "source": null}, ...]}'
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
                  meanings: list[str] | None = None) -> tuple[list[dict], list[str], list[str]]:
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


def _one_candidate(prompt: str, model: str, n_bars: int, corpus: Corpus, profile: dict) -> dict:
    attempts = []
    best = None
    for attempt in range(1, MIMIC_ATTEMPTS + 1):
        parsed = parse_bars(call_model(prompt, model), n_bars)
        if not parsed:
            attempts.append({"attempt": attempt, "error": "no usable JSON"})
            continue
        texts, meanings = parsed
        with _ANALYZE_LOCK:
            rows, problems, notes = analyze_mimic(texts, corpus, profile, meanings)
        attempts.append({"attempt": attempt, "bars": texts, "problems": problems, "notes": notes})
        if best is None or (len(problems), len(notes)) < (len(best[1]), len(best[2])):
            best = (rows, problems, notes, texts)
        if not problems:
            break
        prompt = _mimic_retry(prompt, texts, problems, notes)
    if best is None:
        return {"bars": [], "problems": ["no usable output from model"], "notes": [], "passed": False, "attempts": attempts}
    rows, problems, notes, _texts = best
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
        prompt = build_mimic_prompt(ctx["artist"], ctx["n_bars"], exemplars, profile, ctx["closeness"], ctx["taste"])
        jobs.append((index, prompt, exemplars))

    def _run_job(job: tuple) -> tuple:
        index, prompt, exemplars = job
        one = _one_candidate(prompt, model, ctx["n_bars"], corpus, profile)
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
        scored = gunna_score.score_lines(texts, profile, corpus.lex) if texts else {"score": None, "parts": {}}
        one.update({
            "candidate": index + 1,
            "model": model,
            "duplicate": duplicate,
            "passed_hard": bool(one["passed"]) and not duplicate,
            "gunna_score": scored.get("score"),
            "score_parts": scored.get("parts") or {},
            "exemplar_songs": [item["song"] for item in exemplars],
            "exemplars": exemplars,
        })
        candidates.append(one)
        score_text = "n/a" if one["gunna_score"] is None else f"{one['gunna_score']}"
        print(
            f"  candidate {index + 1}/{n_candidates}: "
            f"{'pass' if one['passed_hard'] else 'drop'} score {score_text}",
            file=sys.stderr, flush=True,
        )

    viable = [row for row in candidates if row["passed_hard"]]
    ranked = sorted(viable, key=lambda row: (-(row["gunna_score"] or 0), len(row["notes"]), row["candidate"]))
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
        })
    return {
        "winner": pack(winner),
        "runner_up": pack(runner) if runner else None,
        "candidates": public,
        "all_identical": all_identical,
        "elapsed_s": elapsed,
        "passed_n": len(ranked),
    }


def build_mimic_context(artist: str, n_bars: int, seed: int | None, closeness: float,
                        profile: dict, anchor_songs: list[dict], taste: dict | None = None,
                        skip_keys: set[str] | None = None) -> dict:
    bank = anchor_verse_bank(anchor_songs, skip_keys)
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
        "taste": taste,
        "exemplars": sample,
        "couplets": [],
        "prompt_version": MIMIC_PROMPT_VERSION,
        "prompt": build_mimic_prompt(artist, n_bars, sample, profile, closeness, taste),
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
        model=result.get("model", ""), prompt_version=MIMIC_PROMPT_VERSION)


def mimic_document(ctx: dict, model: str, packed: dict, generation_ids: dict) -> dict:
    """phase6.v2 superset. `models` has the top two verses the rating page shows."""
    winner = packed["winner"]
    models = {}
    if winner["bars"]:
        models[model] = {**{key: winner[key] for key in (
            "model", "bars", "problems", "notes", "passed", "attempts", "elapsed_s", "gunna_score", "score_parts")},
            "generation_id": generation_ids.get("winner")}
    runner = packed["runner_up"]
    if runner and runner["bars"]:
        models[f"{model}_2"] = {**{key: runner[key] for key in (
            "model", "bars", "problems", "notes", "passed", "attempts", "elapsed_s", "gunna_score", "score_parts")},
            "generation_id": generation_ids.get("runner")}
    cadence = ctx["profile"].get("cadence") or {}
    return {
        "schema": SCHEMA_VERSION,
        "prompt_version": MIMIC_PROMPT_VERSION,
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
                  profile: dict | None = None, n_candidates: int = 8) -> dict:
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
        "prompt": build_prompt(artist, n_bars, topic, scheme, exemplars, grades, rollup, mode, couplets, taste),
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
    ap.add_argument("--sets", type=int, default=1,
                    help="mimic only. write this many sets. seeds step by 1 from --seed (or from 1)")
    ap.add_argument("--out", type=Path, default=None,
                    help="mimic only. one set writes this file. several sets write mimic_01.json inside this directory")
    ap.add_argument("--db", type=Path, default=OUT / "feedback.db")
    ap.add_argument("--show-prompt", action="store_true", help="print the prompt to stderr")
    args = ap.parse_args()

    if args.caller == "omni":
        global _CALLER
        _CALLER = "omni"
        args.model = args.omni_model
    if args.mode == "mimic":
        return _main_mimic(args)

    lex = p1.Lexicon(p1.load_cmudict(p1.DEFAULT_CMU))
    corpus = Corpus(args.artist, lex)
    ctx = build_context(args.artist, args.bars, args.topic, args.scheme, args.seed, corpus, args.mode)
    if args.show_prompt:
        print(ctx["prompt"], file=sys.stderr)
    result = run_model(ctx, args.model, corpus)
    gid = log_result(feedback_store.FeedbackStore(str(args.db)), ctx, result, load_blocks_catalog())
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
                     skip: set[str], seed: int | None, out_path: Path, dump_stdout: bool) -> dict:
    ctx = build_mimic_context(
        args.artist, args.bars, seed, args.closeness, profile, matched, skip_keys=skip)
    print(
        f"SET_START seed {seed}  {len(ctx['bank'])} stretches",
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
    store = feedback_store.FeedbackStore(str(args.db))
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
    lex = p1.Lexicon(p1.load_cmudict(p1.DEFAULT_CMU))
    corpus = Corpus(args.artist, lex, songs=anchor_lib.copy_songs(gunna))
    if args.sets == 1:
        out_path = args.out or (OUT / "mimic_comparison.json")
        _write_one_mimic(args, profile, matched, corpus, skip, args.seed, out_path, True)
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
            args, profile, matched, corpus, skip, seed, out_path, False))
    manifest_path = dest / "mimic_manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"BATCH_DONE {len(manifest)} sets, manifest {manifest_path}", file=sys.stderr, flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
