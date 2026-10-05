"""Quality gate for generated bars. Terrible lines never reach the scorecard."""

from __future__ import annotations

from craft import syllable_count
from retrieve import opening_tokens, prefix_overlap, usable_bar, wrap_window
from rhyme import WORD_RE, classify_rhyme, consonant_coda, end_word, signature_for, strip_adlib

WEAK_ENDS = {
    "yeah", "yea", "uh", "woo", "ok", "okay", "hey", "ugh", "ah", "ooh", "ya",
}
DET = {"a", "an", "the", "of", "to", "my", "your", "that", "this"}
BAD_BIGRAMS = {
    ("the", "a"), ("a", "the"), ("the", "the"), ("a", "a"),
    ("of", "of"), ("the", "of"), ("a", "of"), ("to", "to"),
    ("the", "your"), ("the", "her"), ("a", "her"), ("the", "my"),
}


def well_formed(line: str) -> bool:
    w = tokens(line)
    if len(w) < 5:
        return False
    if line.count('"') % 2 or line.count("'") > 4:
        return False
    arts = {"a", "an", "the"}
    for i in range(len(w) - 1):
        if (w[i], w[i + 1]) in BAD_BIGRAMS:
            return False
        if w[i] in arts and w[i + 1] in arts:
            return False
    return True


def tokens(line: str) -> list[str]:
    return WORD_RE.findall(strip_adlib(line).lower())


LIGHT_VERBS = {
    "sprint", "crawl", "run", "ran", "walk", "walked", "push", "pulled", "took",
    "take", "make", "made", "got", "get", "had", "put", "sit", "let", "go",
    "went", "come", "came", "leave", "left", "keep", "kept",
}


def only_verb_swap(host: str, cand: str) -> bool:
    """I had to sprint … end → I had to crawl … end. Picture-noun swaps are allowed."""
    ha, hb = tokens(host), tokens(cand)
    if not ha or not hb:
        return False
    sa, sb = set(ha), set(hb)
    diff = (sa - sb) | (sb - sa)
    if not diff:
        return True
    return all(w in LIGHT_VERBS or w in {"a", "an", "the", "to", "my", "it"} for w in diff)


def is_last_word_swap(host: str, cand: str) -> bool:
    """I drip on my dawg's stage → I drip on my dawg's parade."""
    a, b = tokens(host), tokens(cand)
    if len(a) < 3 or len(b) < 3:
        return False
    return a[:-1] == b[:-1] and a[-1] != b[-1]


def tight_landing(host_end: str, cand_end: str, cmu: dict) -> bool:
    kind = classify_rhyme(host_end, cand_end, cmu)
    if kind == "perfect":
        return True
    if kind != "slant":
        return False
    sa, sb = signature_for(host_end, cmu), signature_for(cand_end, cmu)
    if not sa or not sb:
        return False
    ca, cb = consonant_coda(sa), consonant_coda(sb)
    if not ca or not cb:
        return max(len(ca), len(cb)) <= 1
    return len(ca) == 1 and len(cb) == 1


def bigrams_supported(cand: str, sources: list[str]) -> bool:
    """Every adjacent pair in cand must appear in the host or a donor. Kills Frankenstein grafts."""
    bag: set[tuple[str, str]] = set()
    for src in sources:
        w = tokens(src)
        bag.update(zip(w, w[1:]))
    cw = tokens(cand)
    if len(cw) < 2:
        return False
    return all(pair in bag for pair in zip(cw, cw[1:]))


def evaluate(host: str, cand: str, job: str, cmu: dict, host_syl: int, sources: list[str] | None = None) -> tuple[bool, list[str]]:
    fails: list[str] = []
    job = job.lower()
    if not usable_bar(cand):
        fails.append("unusable")
    if not well_formed(cand):
        fails.append("malformed")
    if sources is not None and not bigrams_supported(cand, sources):
        fails.append("frankenstein")
    if cand.strip().lower() == host.strip().lower():
        fails.append("duplicate host")
    if is_last_word_swap(host, cand):
        fails.append("last-word swap")
    if job.startswith("gen") and only_verb_swap(host, cand):
        fails.append("verb-only swap")
    if job.startswith("gen"):
        ha, hb = set(tokens(host)), set(tokens(cand))
        overlap = len(ha & hb) / max(len(ha | hb), 1)
        from craft import inner_rhyme_score
        if overlap >= 0.75 and inner_rhyme_score(cand, cmu) < 2:
            fails.append("too close to host")
    he, ce = end_word(host), end_word(cand)
    if ce in WEAK_ENDS:
        fails.append("weak landing")
    if not tight_landing(he, ce, cmu):
        fails.append("landing not in pocket")
    lo, hi = wrap_window(host_syl)
    cand_syl = syllable_count(cand, cmu)
    if cand_syl < lo or cand_syl > hi:
        fails.append("off wrap")
    if job.startswith("gen") and abs(cand_syl - host_syl) > 1:
        fails.append("wrap distance")
    n = prefix_overlap(opening_tokens(host), opening_tokens(cand))
    if job in {"replace", "gen-replace"}:
        if n < 1:
            fails.append("different start")
        counts: dict[str, int] = {}
        for t in tokens(cand):
            counts[t] = counts.get(t, 0) + 1
        if any(v >= 3 for v in counts.values()):
            fails.append("stutter")
    if job in {"next", "gen-next"}:
        if n >= 3:
            fails.append("same start — that's replace")
        if job.startswith("gen") and ce == he:
            fails.append("follow-up reused host landing")
    return (len(fails) == 0, fails)
