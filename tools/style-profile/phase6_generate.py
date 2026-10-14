#!/usr/bin/env python3
"""AI Sparkler Phase 6: verse generation grounded in the artist's real lyrics.

Writes the whole verse in one model call so the rhyme scheme can be planned, seeds the
prompt with real passages by the artist (topic-matched where Phase 4 labels exist), then
checks every bar with CMUdict and retries with the measured violations.

Usage:
  python3 tools/style-profile/phase6_generate.py --artist "Gunna" --bars 4 --model opus
  python3 tools/style-profile/phase6_generate.py --artist "Gunna" --topic money_flex --scheme abab
"""

from __future__ import annotations

import argparse
import json
import random
import re
import subprocess
import sys
import time
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import phase1_song_metrics as p1
import phase4_topic_chain as p4
import feedback_store

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

SCHEMA_VERSION = "phase6.v2"
PROMPT_VERSION = "verse.v5"
MODELS = ("haiku", "sonnet", "opus")
MODEL_DEFAULT = "sonnet"
SCHEMES = ("aabb", "abab")
MODES = ("rewrite", "fresh")
# Soft target from Gunna's catalog: per-song mean syllables p10 ~8, median ~10, p90 ~12.5.
SYL_MIN, SYL_MAX = 8, 13
RATINGS_DIR = HERE / "rater" / "exports"
REASON_TEXT = {
    "no_sense": "doesn't make sense", "bad_rhyme": "forced or bad rhyme", "off_flow": "off flow",
    "off_topic": "off topic", "too_copied": "too copied", "cringe": "cringe",
}
COPY_NGRAM = 5
MAX_ATTEMPTS = 3
CALL_TIMEOUT = 300
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

    def __init__(self, artist: str, lex: p1.Lexicon):
        self.artist = artist
        self.lex = lex
        self.songs: list[tuple[str, list[str]]] = [
            (song, bars) for _, song, bars in p4.song_bars(p1.DEFAULT_CSV, {artist.lower()})
        ]
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
    """Bars Samuel starred / thumbed up and thumbed down in rater exports (auto-grader files skipped)."""
    liked: dict[str, bool] = {}
    disliked: dict[str, set[str]] = {}
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
            for b in r.get("bar_votes", []):
                text = clean_text(b.get("text", ""))
                if not text:
                    continue
                if b.get("keeper") or b.get("vote") == 1:
                    liked[text] = liked.get(text, False) or bool(b.get("keeper"))
                elif b.get("vote") == -1:
                    disliked.setdefault(text, set()).update(b.get("reasons") or r.get("verse_reasons") or [])
    for text in liked:
        disliked.pop(text, None)
    loved = sorted(liked, key=lambda t: not liked[t])[:limit]
    return {"liked": loved, "disliked": [(t, sorted(rs)) for t, rs in list(disliked.items())[:limit]]}


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


def call_model(prompt: str, model: str) -> str | None:
    cmd = ["claude", "-p", "--model", model, "--no-session-persistence"]
    try:
        r = subprocess.run(cmd, input=prompt, capture_output=True, text=True, timeout=CALL_TIMEOUT)
    except subprocess.TimeoutExpired:
        print(f"[{model}] timed out after {CALL_TIMEOUT}s", file=sys.stderr)
        return None
    if r.returncode != 0 or not r.stdout.strip():
        print(f"[{model}] failed: {r.stderr[:300]}", file=sys.stderr)
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


# ---------------------------------------------------------------- context + main


def build_context(artist: str, n_bars: int, topic: str | None, scheme: str, seed: int | None,
                  corpus: Corpus, mode: str = "rewrite") -> dict:
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


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--artist", required=True)
    ap.add_argument("--bars", type=int, default=4)
    ap.add_argument("--model", default=MODEL_DEFAULT, choices=MODELS)
    ap.add_argument("--topic", help="Phase 4 topic label, e.g. money_flex (default: sampled from the artist's mix)")
    ap.add_argument("--scheme", default="aabb", choices=SCHEMES)
    ap.add_argument("--mode", default="rewrite", choices=MODES,
                    help="rewrite = adapt real couplets (default); fresh = write from scratch")
    ap.add_argument("--seed", type=int)
    ap.add_argument("--db", type=Path, default=OUT / "feedback.db")
    ap.add_argument("--show-prompt", action="store_true", help="print the prompt to stderr")
    args = ap.parse_args()

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


if __name__ == "__main__":
    sys.exit(main())
