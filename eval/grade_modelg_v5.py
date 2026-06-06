"""Model G v5 — recalibrated, section-aware, music/intent-ready grader (standalone eval).

Built from the 6-lyric ablation findings. Changes vs v4:
  - CUT Flow + Originality-as-a-score (flat; no signal).            (Originality -> plagiarism gate)
  - FIX Rhyme: slant + monorhyme + OOV aware, whole-family, not last-word-exact.
  - BROADEN Jargon -> Specificity: lexicon + proper nouns + numbers (not one subgenre's word-list).
  - RELAX Cadence -> Meter: reward a broad authentic band + consistency, not a rigid 9.7 mean.
    (If intent syllables / BPM are supplied, Meter targets THAT instead.)
  - SOFT Through-line: reward thematic cohesion, NEVER penalise (intentional association is fine).
  - SPLIT Repetition: refrain-exempt + lexical-monotony, softened per section, with a hard floor.
  - ROUTER: detect verse vs hook, switch active axes + weights; axes with no input stay OFF.

Pure text/number -> on-device-able. Audio axes (Pocket@BPM, Singability@Key) are stubs, OFF here.
No app code is touched.
"""
import os, re, sys, statistics
from collections import Counter
from itertools import combinations
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grade_modelg as G

WORD = re.compile(r"[A-Za-z']+")
ADLIB = re.compile(r"\([^)]*\)")
VOWELS = re.compile(r"[aeiouy]+")
STOP = G.STOPWORDS
SPELL_VOWEL = {"a": "AE", "e": "EH", "i": "AY", "o": "OW", "u": "UW", "y": "AY"}


def _words(text):
    return WORD.findall(ADLIB.sub(" ", text))


def _content(text):
    return [w.lower() for w in _words(text) if w.lower() not in STOP and len(w) > 2]


# ---------------- Rhyme: slant + monorhyme + OOV, whole-family ----------------
def _end_vowel(text, cmu):
    """Final stressed vowel class of the line's last word; OOV -> last vowel letter class."""
    w = G.last_word(text)
    if not w:
        return None
    ph = cmu.get(w)
    if ph:
        v, _ = G._vowel_and_coda(ph)
        if v:
            return v[:2]                      # AH/AE/AY/IH/OW...
    m = VOWELS.findall(w)
    return SPELL_VOWEL.get(m[-1][0], m[-1][0].upper()) if m else None


def rhyme_score(lines, cmu):
    ends = [_end_vowel(l, cmu) for l in lines]
    valid = [e for e in ends if e]
    if len(valid) < 2:
        return 0.0
    fam = Counter(valid)
    connected = sum(1 for e in ends if e and fam[e] >= 2)   # rhymes with >=1 other line
    rate = connected / len(valid)                            # coverage of the scheme
    dom = fam.most_common(1)[0][1] / len(valid)              # dominant family share
    return round(min(100.0, 100 * (0.7 * rate + 0.3 * dom)), 1)


# ---------------- Meter: broad band + consistency (or intent/BPM target) ------
def meter_score(lines, cmu, intent_syll=None, tol=2):
    counts = [c for c in (G.line_syllables(l, cmu) for l in lines) if c > 0]
    if not counts:
        return 0.0
    if intent_syll:                                          # user/BPM-supplied target
        inband = sum(1 for c in counts if abs(c - intent_syll) <= tol)
        return round(100 * inband / len(counts), 1)
    inband = sum(1 for c in counts if 4 <= c <= 18) / len(counts)   # generous pro band
    sd = statistics.pstdev(counts) if len(counts) > 1 else 0.0
    consistency = max(0.0, 1 - sd / 8.0)                     # gentle: sd 8 -> 0
    return round(min(100.0, 100 * (0.7 * inband + 0.3 * consistency)), 1)


# ---------------- Specificity: lexicon + proper nouns + numbers ---------------
def specificity_score(lines, lexicon_set):
    toks = _words(" ".join(lines))
    if not toks:
        return 0.0
    low = " ".join(lines).lower()
    tokset = {t.lower() for t in toks}
    lex = sum(1 for t in lexicon_set if (t in tokset) or (" " in t and t in low))
    propers = sum(1 for l in lines for k, w in enumerate(_words(l))
                  if k > 0 and w[0].isupper() and w.lower() not in STOP)
    nums = sum(1 for t in toks if any(ch.isdigit() for ch in t))
    per_line = (lex + propers + nums) / len(lines)
    return round(min(100.0, per_line * 45), 1)              # ~2.2 specifics/line -> 100


# ---------------- Through-line: reward-only thematic cohesion -----------------
def throughline_bonus(lines):
    sets = [set(_content(l)) for l in lines]
    sets = [s for s in sets if s]
    if len(sets) < 2:
        return 0.0
    sims = [len(a & b) / len(a | b) for a, b in combinations(sets, 2) if (a | b)]
    cohesion = sum(sims) / len(sims) if sims else 0.0
    return round(min(100.0, cohesion * 300), 1)             # reward-only, never negative


def craft_score(lines):
    cw = [w for l in lines for w in _content(l)]
    return round(min(100.0, 100 * len(set(cw)) / len(cw)), 1) if cw else 50.0


# ---------------- Repetition: refrain-exempt + monotony, section-softened -----
def repetition_penalty(lines, section):
    norm = [re.sub(r"\W+", " ", l.lower()).strip() for l in lines]
    refrains = {l for l, c in Counter(norm).items() if c >= 2}
    body = [l for l, n in zip(lines, norm) if n not in refrains]        # exempt repeated lines
    cw = [w for l in body for w in _content(l)]
    monotony = max(0.0, 0.6 - (len(set(cw)) / len(cw))) * 100 if cw else 0.0
    factor = 0.35 if section == "hook" else 1.0
    pen = monotony * factor * 0.4
    allcw = [w for l in lines for w in _content(l)]                     # degenerate floor
    if allcw and len(set(allcw)) / len(allcw) < 0.25:
        pen += 12
    return round(min(25.0, pen), 1)


def plagiarism_gate(lines, corpus_4grams):
    grams = set()
    for l in lines:
        ws = [w.lower() for w in _words(l)]
        grams.update(tuple(ws[k:k + 4]) for k in range(len(ws) - 3))
    if not grams:
        return 1.0
    overlap = sum(1 for g in grams if g in corpus_4grams) / len(grams)
    return 0.4 if overlap > 0.5 else 1.0


# ---------------- Router ------------------------------------------------------
def detect_section(lines):
    norm = [re.sub(r"\W+", " ", l.lower()).strip() for l in lines]
    if any(v >= 3 for v in Counter(norm).values()):
        return "hook"
    tails = Counter(tuple(_words(l.lower())[-2:]) for l in lines if len(_words(l)) >= 2)
    if tails and tails.most_common(1)[0][1] >= max(4, len(lines) * 0.4):
        return "hook"
    return "verse"


WEIGHTS = {
    "verse": {"Meter": 0.25, "Rhyme": 0.30, "Specificity": 0.27, "Throughline": 0.08, "Craft": 0.10},
    "hook":  {"Meter": 0.30, "Rhyme": 0.30, "Specificity": 0.20, "Throughline": 0.08, "Craft": 0.12},
}


def grade_v5(lines, cmu, corpus_4grams, lexicon_set, section=None, intent_syll=None):
    lines = [l for l in (x.strip() for x in lines) if l]
    if section is None:
        section = detect_section(lines)
    axes = {
        "Meter": meter_score(lines, cmu, intent_syll),
        "Rhyme": rhyme_score(lines, cmu),
        "Specificity": specificity_score(lines, lexicon_set),
        "Throughline": throughline_bonus(lines),
        "Craft": craft_score(lines),
    }
    W = WEIGHTS[section]
    pos = sum(axes[k] * W[k] for k in W)
    rep = repetition_penalty(lines, section)
    gate = plagiarism_gate(lines, corpus_4grams)
    net = max(0.0, min(100.0, (pos - rep) * gate))
    return {"section": section, "axes": axes, "weights": W, "rep": rep, "gate": gate, "net": round(net, 1)}


def _setup():
    cmu = G.load_cmudict(G.DEFAULT_CMUDICT)
    _, grams = G.build_originality_index(G.load_corpus(G.DEFAULT_CORPUS))
    lex = {t.lower() for t in G.load_lexicon_terms(G.DEFAULT_LEXICON) if len(t) > 2}
    return cmu, grams, lex


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description="Model G v5 grader — recalibrated, section-aware")
    ap.add_argument("--verse", required=True, help="verse file, one bar per line")
    ap.add_argument("--section", choices=["verse", "hook"], help="force section (default: auto-detect)")
    ap.add_argument("--intent-syll", type=int, help="target syllables/line (default: broad band)")
    a = ap.parse_args()
    cmu, grams, lex = _setup()
    lines = [l.strip() for l in open(a.verse, encoding="utf-8") if l.strip()]
    r = grade_v5(lines, cmu, grams, lex, section=a.section, intent_syll=a.intent_syll)
    print(f"\nModel G v5  —  section={r['section']}   NET = {r['net']}")
    for k, v in r["axes"].items():
        print(f"  {k:12}{v:6.1f}   w={r['weights'][k]:.2f}")
    print(f"  {'-Repetition':12}{r['rep']:6.1f}   (plagiarism gate ×{r['gate']})")
