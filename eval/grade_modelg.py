#!/usr/bin/env python3
"""
G0 — Model G Authenticity grading (baseline).

Scores a generated verse against the real Gunna/Young-Thug ground-truth corpus on
three computable-today axes from the grading rubric:

    A1  Cadence     (0-100)  syllables/bar vs. corpus distribution
    A2  Rhyme       (0-100)  slant-aware rhyme rate (2-line window) vs. corpus
    A7  Originality  (0-100)  similar style WITHOUT copying corpus lines

Reports each axis plus a partial Authenticity Score (the three weights, renormalised).
G1 will add A3 rhyme-quality, A4 flow/stress, A5 tone, A6 lexical authenticity, and the
"social action / exposure discipline" axis from the voice-theory notes. See eval/README.md.

Detection is intentionally simple and TRANSPARENT, and is applied identically to the
corpus and the verse so the comparison is apples-to-apples. Proper multisyllabic rhyme
(RhymeClusterEngine-grade) lands in G1.

Usage:
    python3 eval/grade_modelg.py --demo                  # score the bundled sample verse
    python3 eval/grade_modelg.py --verse path/to.txt     # score a verse file (one bar per line)
    python3 eval/grade_modelg.py --corpus-stats          # just print corpus baseline stats
    python3 eval/grade_modelg.py --verse v.txt --log     # append result to eval/grading_log.csv

No third-party deps. Reads the corpus + cmudict straight from the repo.
"""
import argparse
import csv
import os
import re
import statistics
import sys
from collections import defaultdict

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_CORPUS = os.path.join(REPO_ROOT, "XJournal AI", "ground_truth_rap_bars_MODEL_G.csv")
DEFAULT_CMUDICT = os.path.join(REPO_ROOT, "XJournal AI", "cmudict.txt")
DEFAULT_LEXICON = os.path.join(REPO_ROOT, "XJournal AI", "jargon_authority_lexicon_v8.csv")

# Axis weights (full rubric in eval/README.md). Now covers A1/A2/A5/A6/A7
# (A3 rhyme-quality and A4 flow/stress still pending).
WEIGHTS = {"A1": 0.20, "A2": 0.20, "A3": 0.15, "A5": 0.10, "A6": 0.10, "A7": 0.10}

# A5 tone proxy: the corpus-dominant register is confident + luxurious (see baseline). These
# word sets are a heuristic until a real tone classifier / theme emotional_tone is wired (G1+).
TONE_WORDS = {
    "confident": {"won", "boss", "top", "king", "best", "never", "came", "up", "run", "own", "real", "solid", "gang", "team"},
    "luxurious": {"diamond", "diamonds", "foreign", "designer", "rich", "mansion", "watch", "drip", "ice", "gold", "racks", "bands", "chain", "estate", "penthouse", "porsche", "rolex"},
    "aggressive": {"smoke", "opp", "opps", "clip", "war", "beam", "stick", "drum", "slide"},
}

# Realistic single-bar syllable band — mirrors the app's own clamp (8...18) but a bit
# wider; used to drop corrupt/extreme corpus rows so the cadence tolerance stays meaningful.
SYLL_CLIP = (3, 20)
RHYME_WINDOW = 2  # a bar counts as rhymed if it rhymes with either of the prior 2 bars
# G0 scores A2 against a fixed "clearly-rhyming verse" target. The corpus's OWN last-word
# end-rhyme rate is far lower (~0.12) because Gunna/Thug rhyme is largely INTERNAL and
# multisyllabic, which last-word matching misses. G1 measures that properly (RhymeClusterEngine).
RHYME_TARGET = 0.50
# A3 internal/multisyllabic rhyme: density of rhyming word-pairs within a short window.
# Real rap is internal-rhyme dense; ~0.12 = rich. Fixed target for now (corpus-grounded later).
INTERNAL_RHYME_TARGET = 0.12

PUNCT = ".,!?;:\"'()[]{}*—–-…"
ADLIB_RE = re.compile(r"\((.*?)\)")          # (Skrrt), (yeah) ...
WORD_RE = re.compile(r"[A-Za-z']+")


# ---------------------------------------------------------------- CMUDICT ----
def load_cmudict(path):
    """word(lowercase) -> list[phoneme]. Stress digits (0/1/2) mark vowels."""
    d = {}
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            if line.startswith(";;;") or not line.strip():
                continue
            parts = line.split()
            if len(parts) < 2:
                continue
            word = re.sub(r"\(\d+\)$", "", parts[0]).lower()
            if word not in d:                # keep first (primary) pronunciation
                d[word] = parts[1:]
    return d


def syllables(word, cmu):
    """Syllable count for a word: # of vowel phonemes, else vowel-group fallback."""
    w = word.lower().strip(PUNCT)
    if not w:
        return 0
    ph = cmu.get(w)
    if ph:
        return max(1, sum(1 for p in ph if p[-1].isdigit()))
    return max(1, len(re.findall(r"[aeiouy]+", w)))


def line_syllables(text, cmu):
    clean = ADLIB_RE.sub(" ", text)          # drop ad-libs like (Skrrt)
    return sum(syllables(w, cmu) for w in WORD_RE.findall(clean))


def last_word(text):
    clean = ADLIB_RE.sub(" ", text)          # ignore trailing ad-libs for rhyme
    words = WORD_RE.findall(clean)
    return words[-1].lower() if words else None


# ---- rhyme primitives (slant-aware) -----------------------------------------
def _last_stressed(phones):
    idx = None
    for i, p in enumerate(phones):
        if p[-1].isdigit():
            idx = i
    return idx


def _rime_strict(phones):
    i = _last_stressed(phones)
    if i is None:
        return None
    return tuple(re.sub(r"\d", "", p) for p in phones[i:])


def _vowel_and_coda(phones):
    i = _last_stressed(phones)
    if i is None:
        return None, None
    vowel = re.sub(r"\d", "", phones[i])
    coda = tuple(phones[i + 1:])
    return vowel, coda


def rhyme_phones(p1, p2):
    """Perfect OR reasonable slant rhyme."""
    if not p1 or not p2:
        return False
    if _rime_strict(p1) == _rime_strict(p2):
        return True                          # perfect rhyme
    v1, c1 = _vowel_and_coda(p1)
    v2, c2 = _vowel_and_coda(p2)
    if v1 and v1 == v2:                      # same stressed vowel -> assonant base
        if c1 == c2:
            return True
        if c1 and c2 and c1[-1] == c2[-1]:   # share final consonant
            return True
        if not c1 or not c2:                 # open vowel vs light coda
            return True
    return False


def rhyme_words(w1, w2, cmu):
    if not w1 or not w2 or w1 == w2:         # identical word = repetition, not rhyme
        return False
    p1, p2 = cmu.get(w1), cmu.get(w2)
    if p1 and p2:
        return rhyme_phones(p1, p2)
    return w1[-2:] == w2[-2:]                # OOV/slang fallback


def windowed_rhyme_rate(last_words, cmu, window=RHYME_WINDOW):
    """Fraction of bars (from the 2nd on) that rhyme with any of the prior `window` bars."""
    eligible = rhymed = 0
    for i in range(1, len(last_words)):
        if not last_words[i]:
            continue
        eligible += 1
        for j in range(max(0, i - window), i):
            if last_words[j] and rhyme_words(last_words[i], last_words[j], cmu):
                rhymed += 1
                break
    return (rhymed / eligible) if eligible else 0.0, eligible


# ----------------------------------------------------------------- CORPUS ----
def find_col(header, *cands):
    for cand in cands:
        for idx, name in enumerate(header):
            if cand in name.lower():
                return idx
    return None


def load_corpus(path):
    with open(path, newline="", encoding="utf-8", errors="replace") as f:
        rows = list(csv.reader(f))
    header_idx = 0
    for i, row in enumerate(rows[:5]):
        joined = ",".join(c.lower() for c in row)
        if "syllable_count" in joined and "rhyme_class" in joined and "primary_tone" in joined:
            header_idx = i
            break
    header = [c.strip() for c in rows[header_idx]]
    c_text = find_col(header, "text_bar_line", "text")
    c_syll = find_col(header, "syllable_count")
    c_tone = find_col(header, "primary_tone")
    c_id = find_col(header, "text_id") or 0

    bars = []
    for row in rows[header_idx + 1:]:
        if c_text is None or len(row) <= c_text:
            continue
        text = row[c_text].strip()
        if not text or text.lower() in ("text", "text_bar_line"):
            continue                          # skip stray header/metadata rows
        def cell(i):
            return row[i].strip() if (i is not None and i < len(row)) else ""
        syl = cell(c_syll)
        bars.append({
            "id": cell(c_id),
            "text": text,
            "syllables": int(syl) if syl.isdigit() else None,
            "tone": cell(c_tone),
        })
    return bars


def corpus_baseline(bars, cmu):
    syl = [b["syllables"] for b in bars
           if b["syllables"] and SYLL_CLIP[0] <= b["syllables"] <= SYLL_CLIP[1]]
    raw = [b["syllables"] for b in bars if b["syllables"]]
    mean = statistics.mean(syl) if syl else 10.0
    std = statistics.pstdev(syl) if len(syl) > 1 else 2.0

    # Reconstruct song sequences from text_id ("gunna.200forlunch.7") and measure the
    # windowed slant-rhyme rate -> the corpus's natural rhyme density.
    songs = defaultdict(list)
    for b in bars:
        m = re.match(r"^(.*)\.(\d+)$", b["id"])
        if m:
            songs[m.group(1)].append((int(m.group(2)), b["text"]))
    total_rhymed = total_eligible = 0
    for seq in songs.values():
        seq.sort(key=lambda t: t[0])
        lws = [last_word(t) for _, t in seq]
        rate, elig = windowed_rhyme_rate(lws, cmu)
        total_rhymed += rate * elig
        total_eligible += elig
    rhyme_rate = (total_rhymed / total_eligible) if total_eligible else 0.5

    tones = defaultdict(int)
    for b in bars:
        if b["tone"]:
            tones[b["tone"]] += 1

    return {
        "n_bars": len(bars), "n_syll_used": len(syl), "n_syll_dropped": len(raw) - len(syl),
        "syll_mean": mean, "syll_std": std,
        "rhyme_rate": rhyme_rate, "rhyme_pairs": total_eligible,
        "tones": dict(sorted(tones.items(), key=lambda kv: -kv[1])[:6]),
    }


# ----------------------------------------------------------------- SCORING ---
def score_cadence(lines, cmu, base):
    """A1: each bar's syllable count vs. corpus mean; tolerance ~ corpus std (floor 1.5)."""
    if not lines:
        return 0.0, []
    tol = max(1.5, base["syll_std"])
    counts = [line_syllables(ln, cmu) for ln in lines]
    per = [max(0.0, 100.0 - (abs(c - base["syll_mean"]) / tol) * 50.0) for c in counts]
    return statistics.mean(per), counts


def score_rhyme(lines, cmu, base):
    """A2: verse windowed slant-rhyme rate scored against the corpus rate (apples-to-apples)."""
    if len(lines) < 2:
        return 0.0, 0.0
    lws = [last_word(ln) for ln in lines]
    rate, _ = windowed_rhyme_rate(lws, cmu)
    score = 100.0 if rate >= RHYME_TARGET else (rate / RHYME_TARGET) * 100.0
    return score, rate


def score_rhyme_quality(lines, cmu):
    """A3: internal + multisyllabic rhyme richness (depth beyond the end-word adjacency of A2)."""
    words = []  # (word, rime tuple, rime-syllable count)
    for line in lines:
        for w in WORD_RE.findall(ADLIB_RE.sub(" ", line).lower()):
            ph = cmu.get(w)
            if ph:
                r = _rime_strict(ph)
                if r:
                    words.append((w, r, sum(1 for p in ph if p[-1].isdigit())))
    if len(words) < 2:
        return 0.0, {}
    internal_hits = multi_hits = total = 0
    n = len(words)
    for a in range(n):
        for b in range(a + 1, min(n, a + 8)):          # nearby word pairs (window 8)
            if words[a][0] == words[b][0]:
                continue
            total += 1
            if words[a][1] == words[b][1]:             # same rime = rhyme
                internal_hits += 1
                if min(words[a][2], words[b][2]) >= 2:  # multisyllabic rime
                    multi_hits += 1
    if total == 0:
        return 0.0, {}
    density = internal_hits / total
    base = min(100.0, (density / INTERNAL_RHYME_TARGET) * 100.0)
    multi_bonus = min(20.0, multi_hits * 6.0)
    score = min(100.0, base * 0.85 + multi_bonus)
    return score, {"internal_pairs": internal_hits, "multisyllabic_pairs": multi_hits,
                   "internal_density": round(density, 3)}


def build_originality_index(bars):
    corpus_lines, grams = set(), set()
    for b in bars:
        norm = " ".join(WORD_RE.findall(ADLIB_RE.sub(" ", b["text"]).lower()))
        if norm:
            corpus_lines.add(norm)
            toks = norm.split()
            for i in range(len(toks) - 3):
                grams.add(tuple(toks[i:i + 4]))
    return corpus_lines, grams


def score_originality(lines, corpus_lines, corpus_4grams):
    """A7: penalise near-duplicate lines and high 4-gram overlap with the corpus."""
    if not lines:
        return 0.0, {}
    penalty, dup_lines, overlaps = 0.0, 0, []
    for ln in lines:
        norm = " ".join(WORD_RE.findall(ADLIB_RE.sub(" ", ln).lower()))
        if not norm:
            continue
        if norm in corpus_lines:
            dup_lines += 1
            penalty += 35.0                  # verbatim corpus line = heavy hit
            continue
        toks = norm.split()
        grams = [tuple(toks[i:i + 4]) for i in range(len(toks) - 3)]
        if grams:
            hit = sum(1 for g in grams if g in corpus_4grams) / len(grams)
            overlaps.append(hit)
            if hit > 0.5:
                penalty += hit * 25.0        # heavily-borrowed phrasing
    avg_overlap = statistics.mean(overlaps) if overlaps else 0.0
    return max(0.0, 100.0 - penalty), {"duplicate_lines": dup_lines,
                                       "avg_4gram_overlap": round(avg_overlap, 3)}


# -------------------------------------------------------------------- MAIN ---
SAMPLE_VERSE_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sample_verse.txt")


def read_verse(path):
    with open(path, encoding="utf-8") as f:
        return [ln.strip() for ln in f if ln.strip()]


def load_lexicon_terms(path):
    """Distinct authentic jargon terms (the `term` column) for lexical-authenticity scoring."""
    terms = set()
    if not os.path.exists(path):
        return terms
    with open(path, newline="", encoding="utf-8", errors="replace") as f:
        rows = list(csv.reader(f))
    if not rows:
        return terms
    header = [c.strip().lower() for c in rows[0]]
    ti = header.index("term") if "term" in header else 0
    for row in rows[1:]:
        if ti < len(row):
            t = row[ti].strip().lower()
            if 2 < len(t) < 30 and " " not in t[:1]:
                terms.add(t)
    return terms


def score_lexical(lines, lexicon_terms):
    """A6: authentic-jargon coverage minus overuse (the lexicon's own overuse_penalty idea)."""
    if not lines or not lexicon_terms:
        return 0.0, {}
    text = " ".join(lines).lower()
    hits = {t: text.count(t) for t in lexicon_terms if text.count(t) > 0}
    distinct = len(hits)
    overuse = sum(max(0, n - 2) for n in hits.values()) * 10.0
    presence = min(100.0, distinct * 25.0)          # ~4 distinct authentic terms = full marks
    return max(0.0, presence - overuse), {"distinct_terms": distinct,
                                          "overused": [t for t, n in hits.items() if n > 2]}


def score_tone(lines):
    """A5 (proxy): density of corpus-dominant tone words (confident + luxurious)."""
    if not lines:
        return 0.0, {}
    words = re.findall(r"[a-z']+", " ".join(lines).lower())
    if not words:
        return 0.0, {}
    counts = {tone: sum(1 for w in words if w in vocab) for tone, vocab in TONE_WORDS.items()}
    density = (counts["confident"] + counts["luxurious"]) / len(words)
    return min(100.0, density * 600.0), counts      # ~1 tone word / 6 words ≈ full marks


def grade_verse(lines, cmu, base, lexicon_terms, corpus_lines, corpus_4grams):
    """Score a verse on all available axes. Returns (scores dict, details dict)."""
    a1, counts = score_cadence(lines, cmu, base)
    a2, rate = score_rhyme(lines, cmu, base)
    a3, rq = score_rhyme_quality(lines, cmu)
    a5, tone_counts = score_tone(lines)
    a6, lex = score_lexical(lines, lexicon_terms)
    a7, orig = score_originality(lines, corpus_lines, corpus_4grams)
    scores = {"A1": a1, "A2": a2, "A3": a3, "A5": a5, "A6": a6, "A7": a7}
    details = {"syllables": counts, "rhyme_rate": rate, "rhyme_quality": rq,
               "tone": tone_counts, "lexical": lex, "originality": orig}
    return scores, details


def partial_authenticity(scores):
    tw = sum(WEIGHTS.values())
    return sum(scores[k] * WEIGHTS[k] for k in WEIGHTS) / tw


def band(score):
    if score >= 90: return "A  (corpus-indistinguishable)"
    if score >= 80: return "B  (ship)"
    if score >= 70: return "C  (passable)"
    return "D  (needs work)"


def main():
    ap = argparse.ArgumentParser(description="G0 Model G authenticity grader")
    ap.add_argument("--verse", help="path to a verse file (one bar per line)")
    ap.add_argument("--demo", action="store_true", help="score the bundled sample verse")
    ap.add_argument("--corpus-stats", action="store_true", help="print corpus baseline only")
    ap.add_argument("--corpus", default=DEFAULT_CORPUS)
    ap.add_argument("--cmudict", default=DEFAULT_CMUDICT)
    ap.add_argument("--lexicon", default=DEFAULT_LEXICON)
    ap.add_argument("--log", action="store_true", help="append result to eval/grading_log.csv")
    ap.add_argument("--version-label", default="manual", help="pipeline label for the log")
    ap.add_argument("--compare", nargs="+", metavar="VERSE", help="grade multiple verse files side-by-side")
    args = ap.parse_args()

    for p in (args.corpus, args.cmudict):
        if not os.path.exists(p):
            sys.exit(f"missing required file: {p}")

    print("Loading CMUDICT + corpus ...", file=sys.stderr)
    cmu = load_cmudict(args.cmudict)
    bars = load_corpus(args.corpus)
    base = corpus_baseline(bars, cmu)

    print("\n=== CORPUS BASELINE (real Gunna/Thug ground truth) ===")
    print(f"  bars indexed         : {base['n_bars']}")
    print(f"  syllables/bar        : mean {base['syll_mean']:.2f}, std {base['syll_std']:.2f} "
          f"(used {base['n_syll_used']}, dropped {base['n_syll_dropped']} out-of-range)")
    print(f"  rhyme rate (end-word) : {base['rhyme_rate']:.2f}  (informational; end-word only — "
          f"undercounts internal/multisyllabic rhyme, see G1)")
    print(f"  top tones            : {base['tones']}")
    print(f"  cmudict words        : {len(cmu)}")

    if args.corpus_stats:
        return

    corpus_lines, corpus_4grams = build_originality_index(bars)
    lexicon_terms = load_lexicon_terms(args.lexicon)

    # Compare mode: grade several verses side-by-side (e.g. v2 output vs v3 output).
    if args.compare:
        print("\n=== COMPARE ===")
        cols = list(WEIGHTS.keys())
        print(f"{'verse':<26}" + "".join(f"{c:>6}" for c in cols) + f"{'PARTIAL':>9}  band")
        for path in args.compare:
            s, _ = grade_verse(read_verse(path), cmu, base, lexicon_terms, corpus_lines, corpus_4grams)
            p = partial_authenticity(s)
            print(f"{os.path.basename(path):<26}" + "".join(f"{s[c]:>6.1f}" for c in cols)
                  + f"{p:>9.1f}  {band(p).split()[0]}")
        return

    verse_path = args.verse or (SAMPLE_VERSE_PATH if args.demo else None)
    if not verse_path:
        ap.error("provide --verse PATH, --demo, or --compare")
    lines = read_verse(verse_path)

    scores, det = grade_verse(lines, cmu, base, lexicon_terms, corpus_lines, corpus_4grams)
    partial = partial_authenticity(scores)

    print(f"\n=== VERSE: {os.path.relpath(verse_path, REPO_ROOT)} ({len(lines)} bars) ===")
    print(f"  syllables/bar        : {det['syllables']}  (corpus mean {base['syll_mean']:.1f})")
    print(f"  rhyme rate (end-word) : {det['rhyme_rate']:.2f}  (A2 target {RHYME_TARGET:.2f})")
    print(f"  rhyme quality        : {det['rhyme_quality']}")
    print(f"  tone words           : {det['tone']}")
    print(f"  lexical              : {det['lexical']}  ({len(lexicon_terms)} lexicon terms loaded)")
    print(f"  originality          : {det['originality']}")
    print("\n  --- AXES (0-100) ---")
    print(f"  A1 Cadence             : {scores['A1']:6.1f}")
    print(f"  A2 Rhyme density       : {scores['A2']:6.1f}")
    print(f"  A3 Rhyme quality       : {scores['A3']:6.1f}")
    print(f"  A5 Tone                : {scores['A5']:6.1f}")
    print(f"  A6 Lexical authenticity: {scores['A6']:6.1f}")
    print(f"  A7 Originality         : {scores['A7']:6.1f}")
    print(f"\n  PARTIAL AUTHENTICITY   : {partial:6.1f}   {band(partial)}")
    print("  (partial = A1/A2/A3/A5/A6/A7; A4 flow/stress still pending)\n")

    if args.log:
        log_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "grading_log.csv")
        new = not os.path.exists(log_path)
        with open(log_path, "a", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            if new:
                w.writerow(["version_label", "verse"] + list(WEIGHTS.keys()) + ["partial_authenticity"])
            w.writerow([args.version_label, os.path.basename(verse_path)]
                       + [round(scores[k], 1) for k in WEIGHTS] + [round(partial, 1)])
        print(f"  logged -> {os.path.relpath(log_path, REPO_ROOT)}")


if __name__ == "__main__":
    main()
