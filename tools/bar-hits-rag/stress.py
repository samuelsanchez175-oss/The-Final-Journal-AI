"""Primary-stress words in a bar — the punches the wrap has to match."""

from __future__ import annotations

from dataclasses import dataclass

from rhyme import WORD_RE, strip_adlib

FUNCTION = {
    "a", "an", "the", "of", "to", "in", "on", "and", "or", "but", "for", "with", "at", "by",
    "as", "is", "it", "be", "we", "my", "me", "you", "i", "im", "i'm", "i'ma", "ima", "so",
    "if", "do", "no", "that", "this", "they", "he", "she", "was", "got", "get", "gon", "gonna",
    "uh", "yeah", "ya", "yo", "oh", "ay", "ayy", "just", "from", "out", "up", "down", "not",
    "dont", "don't", "ain't", "aint", "it's", "its", "that's", "thats", "what", "when", "who",
}


def _clean(word: str) -> str:
    return word.lower().strip(".,!?;:\"()[]{}")


def has_primary(word: str, cmu: dict[str, list[str]]) -> bool:
    phones = cmu.get(_clean(word), [])
    return any(p[-1:] == "1" for p in phones)


def primary_vowel(word: str, cmu: dict[str, list[str]]) -> str:
    for p in cmu.get(_clean(word), []):
        if p[-1:] == "1":
            return "".join(ch for ch in p if not ch.isdigit())
    return ""


@dataclass
class StressProfile:
    words: list[str]
    count: int
    last: list[str]
    last_vowels: list[str]
    end_stressed: bool

    def label(self) -> str:
        return ", ".join(self.words) if self.words else "—"


def profile(line: str, cmu: dict[str, list[str]], end_word: str = "") -> StressProfile:
    tokens = [_clean(t) for t in WORD_RE.findall(strip_adlib(line))]
    tokens = [t for t in tokens if t]
    end = _clean(end_word) if end_word else (tokens[-1] if tokens else "")
    stressed: list[str] = []
    for t in tokens:
        if t in FUNCTION:
            continue
        if has_primary(t, cmu) or t == end:
            if t not in stressed:
                stressed.append(t)
    if end and end not in stressed:
        stressed.append(end)
    last = stressed[-2:] if stressed else []
    vowels = [primary_vowel(w, cmu) for w in last]
    end_stressed = bool(end) and (not stressed or stressed[-1] == end or has_primary(end, cmu))
    return StressProfile(
        words=stressed,
        count=len(stressed),
        last=last,
        last_vowels=vowels,
        end_stressed=end_stressed,
    )


def compare(host: StressProfile, cand: StressProfile) -> tuple[int, str]:
    """Higher is a closer wrap punch. Used to rank hits under the same rhyme family."""
    score = 0
    notes: list[str] = []
    if host.end_stressed and cand.end_stressed:
        score += 2
        notes.append("punch on landing")
    if host.count and abs(cand.count - host.count) <= 1:
        score += 1
        notes.append(f"stress×{cand.count}")
    if host.last_vowels and cand.last_vowels and host.last_vowels[-1:] == cand.last_vowels[-1:]:
        score += 1
        notes.append("last stress vowel")
    if host.last_vowels and host.last_vowels == cand.last_vowels and len(host.last_vowels) >= 2:
        score += 2
        notes.append("wrap stress match")
    return score, ", ".join(notes)
