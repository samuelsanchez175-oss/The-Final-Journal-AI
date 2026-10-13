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
PROMPT_VERSION = "verse.v3"
MODELS = ("haiku", "sonnet", "opus")
MODEL_DEFAULT = "sonnet"
SCHEMES = ("aabb", "abab")
SYL_MIN, SYL_MAX = 12, 15
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
        for _, bars in self.songs:
            for b in bars:
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

    def copied(self, text: str) -> str | None:
        w = p1.norm_line(text).split()
        for i in range(len(w) - COPY_NGRAM + 1):
            g = " ".join(w[i:i + COPY_NGRAM])
            if g in self.ngrams:
                return g
        return None


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
                 grades: dict, rollup: dict) -> str:
    def block(p: dict) -> str:
        lines = (re.sub(r"\s+", " ", p1.ADLIB_RE.sub(" ", b)).strip() for b in p["bars"])
        return f'"{p["song"]}"\n' + "\n".join(l for l in lines if l)

    on_topic = [p for p in exemplars if p["topic"]]
    voice = [p for p in exemplars if not p["topic"]]
    m = rollup.get("metrics", {})
    syl_med = m.get("cadence.syl_per_bar_mean", {}).get("median")
    shares = grades.get("end_rhyme_scheme_share", {})
    facts = list(grades.get("style_card", []))
    if syl_med:
        facts.append(f"Median bar length across {rollup.get('confident_songs', '?')} songs: {syl_med:.0f} syllables.")
    if shares:
        facts.append(f"End-rhyme partners: {shares.get('couplet', 0)}% back-to-back, "
                     f"{shares.get('alternate', 0)}% alternating, {shares.get('far', 0)}% further apart.")

    if scheme == "aabb":
        scheme_rule = ("AABB: bars 1 and 2 end on the same sound (A), bars 3 and 4 end on a different "
                       "shared sound (B).")
    else:
        scheme_rule = ("ABAB: bars 1 and 3 end on the same sound (A), bars 2 and 4 end on a different "
                       "shared sound (B).")
    if n_bars != 4:
        scheme_rule += f" Repeat the pattern for every group of 4 bars ({n_bars} bars total)."

    parts = [
        f"You are ghostwriting {n_bars} bars in the voice of {artist}. Below are real {artist} lyrics. "
        f"Study them for vocabulary, slang, imagery, sentence shape and how the rhymes land, then write "
        f"NEW bars that sound like they belong on his album. Never copy a line or reuse a 5-word run from them.",
    ]
    if on_topic:
        parts.append(f"REAL {artist.upper()} BARS ON THIS TOPIC ({topic}):\n\n" + "\n\n".join(block(p) for p in on_topic))
    if voice:
        parts.append(f"MORE REAL {artist.upper()} BARS (voice reference, any topic):\n\n" + "\n\n".join(block(p) for p in voice))
    if facts:
        parts.append(f"MEASURED ON {artist.upper()}'S CATALOG:\n" + "\n".join(f"- {f}" for f in facts))
    parts.append(
        f"WRITE {n_bars} bars about: {TOPIC_BRIEF.get(topic, topic.replace('_', ' '))}.\n\n"
        f"Every bar must follow all of these:\n"
        f"1. One line with exactly one comma, splitting it into two halves.\n"
        f"2. {SYL_MIN}-{SYL_MAX} syllables total, roughly balanced across the two halves.\n"
        f"3. An internal rhyme: a word in the first half rhymes (slant is fine) with a word in the second half.\n"
        f"4. End-rhyme scheme {scheme_rule}\n"
        f"5. Every bar starts with a different word. Don't repeat a content word anywhere in the verse.\n"
        f"6. Concrete images (brands, objects, places, actions, numbers) over abstract claims like "
        f"\"I'm the best\" or \"I got skill\". Never use the words: {', '.join(sorted(BANNED))}, or the topic label.\n"
        f"7. No ad-libs in parentheses.\n\n"
        f"Plan the two end-rhyme sounds first, then write. Return only JSON, no commentary:\n"
        f'{{"rhyme_sounds": {{"A": "...", "B": "..."}}, "bars": ["bar 1", "bar 2", ...]}}'
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


def analyze_verse(texts: list[str], scheme: str, corpus: Corpus) -> tuple[list[dict], list[str]]:
    lex = corpus.lex
    bars = [p1.Bar(t, lex) for t in texts]
    rows, problems = [], []
    letters: list[str] = []
    for k, (t, b) in enumerate(zip(texts, bars), 1):
        commas = t.count(",")
        halves = [h.strip() for h in t.split(",", 1)] if commas else [t.strip()]
        half_syl = [syl(h, lex) for h in halves]
        pairs = internal_pairs(b)
        copy = corpus.copied(t)
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
            "original": copy is None,
        }
        if commas != 1:
            problems.append(f"bar {k}: has {commas} commas, needs exactly 1")
        if not checks["syllables"]:
            problems.append(f"bar {k}: {b.syl} syllables ({' + '.join(map(str, half_syl))}), needs {SYL_MIN}-{SYL_MAX}")
        if not pairs:
            problems.append(f"bar {k}: no internal rhyme found between two words inside the bar")
        if copy:
            problems.append(f"bar {k}: copies the real lyric run \"{copy}\"")
        if banned:
            problems.append(f"bar {k}: uses banned word(s) {', '.join(banned)}")
        rows.append({
            "text": t,
            "halves": [{"text": h, "syl": s} for h, s in zip(halves, half_syl)],
            "syllables": b.syl,
            "end_word": b.end_word,
            "rhyme_letter": letter,
            "internal": pairs,
            "checks": checks,
        })

    for i, j in scheme_pairs(len(bars), scheme):
        kind = end_rhyme_kind(bars[i], bars[j])
        if kind not in ("perfect", "slant"):
            why = "repeats the same end word" if kind == "identical" else "don't rhyme"
            problems.append(f"bars {i + 1} and {j + 1} must end-rhyme for {scheme.upper()}: "
                            f"\"{bars[i].end_word}\" / \"{bars[j].end_word}\" {why}")

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
        problems.append(f"content words reused across bars: {', '.join(repeats)}")
    return rows, problems


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


def parse_bars(raw: str | None, n: int) -> list[str] | None:
    if not raw:
        return None
    a, b = raw.find("{"), raw.rfind("}")
    if a < 0 or b <= a:
        return None
    try:
        bars = json.loads(raw[a:b + 1]).get("bars")
    except json.JSONDecodeError:
        return None
    if not isinstance(bars, list):
        return None
    bars = [re.sub(r"\s+", " ", str(x)).strip() for x in bars if str(x).strip()]
    return bars[:n] if len(bars) >= n else None


def run_model(ctx: dict, model: str, corpus: Corpus) -> dict:
    t0 = time.time()
    prompt, best, attempts = ctx["prompt"], None, []
    for attempt in range(1, MAX_ATTEMPTS + 1):
        texts = parse_bars(call_model(prompt, model), ctx["n_bars"])
        if not texts:
            attempts.append({"attempt": attempt, "error": "no usable JSON"})
            continue
        rows, problems = analyze_verse(texts, ctx["scheme"], corpus)
        attempts.append({"attempt": attempt, "bars": texts, "problems": problems})
        if best is None or len(problems) < len(best[1]):
            best = (rows, problems)
        if not problems:
            break
        prompt = (ctx["prompt"] + "\n\nYOUR PREVIOUS ATTEMPT:\n" + "\n".join(f"{i}. {t}" for i, t in enumerate(texts, 1))
                  + "\n\nPROBLEMS (syllables and rhymes measured with the CMU pronouncing dictionary):\n"
                  + "\n".join(f"- {p}" for p in problems)
                  + "\n\nRewrite the whole verse fixing every problem while keeping it sounding like the real lyrics above. "
                    "Return only the JSON.")
    rows, problems = best if best else ([], ["no usable output from model"])
    for r in rows:
        r["topic"] = ctx["topic"]
    return {"model": model, "bars": rows, "problems": problems, "passed": not problems and bool(rows),
            "attempts": attempts, "elapsed_s": round(time.time() - t0, 1)}


# ---------------------------------------------------------------- context + main


def build_context(artist: str, n_bars: int, topic: str | None, scheme: str, seed: int | None,
                  corpus: Corpus) -> dict:
    rng = random.Random(seed)
    grades, rollup, chains = load_style(artist)
    topic = topic or pick_topic(chains, corpus, rng)
    on_topic = corpus.topic_passages(topic)
    rng.shuffle(on_topic)
    exemplars = on_topic[:6] + corpus.voice_passages(rng, 10 if len(on_topic) < 3 else 6)
    return {
        "artist": artist, "n_bars": n_bars, "topic": topic, "scheme": scheme, "seed": seed,
        "exemplars": exemplars,
        "prompt": build_prompt(artist, n_bars, topic, scheme, exemplars, grades, rollup),
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
        request={"bars_requested": ctx["n_bars"], "topic": ctx["topic"], "scheme": ctx["scheme"],
                 "seed": ctx["seed"], "problems": result["problems"]},
        model=result["model"], prompt_version=PROMPT_VERSION)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--artist", required=True)
    ap.add_argument("--bars", type=int, default=4)
    ap.add_argument("--model", default=MODEL_DEFAULT, choices=MODELS)
    ap.add_argument("--topic", help="Phase 4 topic label, e.g. money_flex (default: sampled from the artist's mix)")
    ap.add_argument("--scheme", default="aabb", choices=SCHEMES)
    ap.add_argument("--seed", type=int)
    ap.add_argument("--db", type=Path, default=OUT / "feedback.db")
    ap.add_argument("--show-prompt", action="store_true", help="print the prompt to stderr")
    args = ap.parse_args()

    lex = p1.Lexicon(p1.load_cmudict(p1.DEFAULT_CMU))
    corpus = Corpus(args.artist, lex)
    ctx = build_context(args.artist, args.bars, args.topic, args.scheme, args.seed, corpus)
    if args.show_prompt:
        print(ctx["prompt"], file=sys.stderr)
    result = run_model(ctx, args.model, corpus)
    gid = log_result(feedback_store.FeedbackStore(str(args.db)), ctx, result, load_blocks_catalog())
    print(json.dumps({"schema": SCHEMA_VERSION, "generation_id": gid, "artist": args.artist,
                      "topic": ctx["topic"], "scheme": ctx["scheme"], **result}, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
