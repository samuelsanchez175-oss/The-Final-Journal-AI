"""CMU phonetic class + perfect / slant, matching Bar Hits + CCV.3 enough for the bench."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

WORD_RE = re.compile(r"[A-Za-z0-9']+")
VOWELS = {
    "AA", "AE", "AH", "AO", "AW", "AY", "EH", "ER", "EY",
    "IH", "IY", "OW", "OY", "UH", "UW",
}


@dataclass(frozen=True)
class Signature:
    vowel: str  # with stress digit if present, e.g. EY1
    coda: tuple[str, ...]

    @property
    def vowel_base(self) -> str:
        return "".join(ch for ch in self.vowel if not ch.isdigit())

    @property
    def rime_key(self) -> str:
        coda = "-".join(p for p in self.coda)
        return f"{self.vowel_base}|{coda}" if coda else self.vowel_base

    @property
    def class_key(self) -> str:
        """BarHitsCatalogStore.phoneticClass: phones from primary stress onward."""
        parts = [self.vowel, *self.coda]
        return " ".join(parts)

    @property
    def destressed_class(self) -> str:
        return " ".join(
            "".join(ch for ch in p if not ch.isdigit())
            for p in (self.vowel, *self.coda)
        )


def phonetic_class_from_phones(phones: list[str]) -> str:
    idx = 0
    for i, phone in enumerate(phones):
        if phone[-1:] == "1":
            idx = i
    return " ".join(phones[idx:])


def load_cmudict(path: Path) -> dict[str, list[str]]:
    out: dict[str, list[str]] = {}
    if not path.exists():
        return out
    with path.open("r", errors="replace") as handle:
        for raw in handle:
            line = raw.strip()
            if not line or line.startswith(";;;"):
                continue
            parts = line.split()
            if len(parts) < 2:
                continue
            word = parts[0].split("(", 1)[0].lower()
            if word in out:
                continue
            out[word] = parts[1:]
    return out


def strip_adlib(line: str) -> str:
    s = re.sub(r"\([^)]*\)", " ", line or "")
    s = re.sub(r"\[[^\]]*\]", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def end_word(line: str, rhyme_word: str = "") -> str:
    stripped = strip_adlib(line)
    hint = (rhyme_word or "").strip().lower().strip("'\"")
    if hint and WORD_RE.fullmatch(hint.replace("'", "")) and hint in stripped.lower():
        return hint
    tokens = WORD_RE.findall(stripped.lower())
    return tokens[-1] if tokens else ""


def signature_from_phones(phones: list[str]) -> Signature | None:
    if not phones:
        return None
    idx = 0
    for i, phone in enumerate(phones):
        base = "".join(ch for ch in phone if not ch.isdigit())
        if phone[-1:] == "1":
            idx = i
            break
        if base in VOWELS:
            idx = i
    vowel = phones[idx]
    coda = tuple(phones[idx + 1 :])
    return Signature(vowel=vowel, coda=coda)


def signature_for(word: str, cmu: dict[str, list[str]]) -> Signature | None:
    phones = cmu.get(word.lower().strip(".,!?;:\"()[]{}"))
    if not phones:
        return None
    return signature_from_phones(phones)


def consonant_coda(sig: Signature) -> tuple[str, ...]:
    """Coda consonants only (drop vowels + plural S/Z). Used to reject loose same-vowel hits."""
    phones = ["".join(ch for ch in p if not ch.isdigit()) for p in sig.coda]
    while phones and phones[-1] in {"S", "Z"}:
        phones.pop()
    return tuple(p for p in phones if p not in VOWELS)


def morph_kind(a: str, b: str) -> str | None:
    """today/day = perfect landing; payday/today = slant (shared stem)."""
    wa, wb = a.lower(), b.lower()
    if not wa or not wb or wa == wb:
        return None
    short, long_ = (wa, wb) if len(wa) <= len(wb) else (wb, wa)
    if len(short) >= 3 and long_.endswith(short):
        return "perfect"
    n = 0
    while n < min(len(wa), len(wb)) and wa[-(n + 1)] == wb[-(n + 1)]:
        n += 1
    if n >= 3:
        return "slant"
    return None


def morph_end_candidates(word: str) -> list[str]:
    """today → today, day. Used to search morphological landings across the roster."""
    w = (word or "").lower()
    out: list[str] = []
    if w:
        out.append(w)
    for n in range(3, min(6, len(w))):
        stem = w[-n:]
        if stem not in out:
            out.append(stem)
    return out


def classify_rhyme(a: str, b: str, cmu: dict[str, list[str]]) -> str | None:
    """perfect | slant | None.

    Slant is *tight*: same stressed vowel and a short coda (empty↔one consonant,
    or two single consonants). Same-vowel dumps like pavement/location are None.
    """
    wa, wb = a.lower(), b.lower()
    if not wa or not wb:
        return None
    if wa == wb:
        return "perfect"
    morph = morph_kind(wa, wb)
    if morph == "perfect":
        return "perfect"
    sa, sb = signature_for(wa, cmu), signature_for(wb, cmu)
    if sa is None or sb is None:
        return None
    if sa.rime_key == sb.rime_key:
        return "perfect"
    if sa.vowel_base != sb.vowel_base:
        return None
    ca, cb = consonant_coda(sa), consonant_coda(sb)
    if ca == cb:
        return "perfect"
    # today (∅) ↔ stage (JH); age (JH) ↔ today (∅)
    if not ca or not cb:
        return "slant" if max(len(ca), len(cb)) <= 1 else None
    # stage (JH) ↔ safe (F) / wave (V) — one coda each
    if len(ca) == 1 and len(cb) == 1:
        return "slant"
    # same first consonant, coda lengths within 1
    if ca[:1] == cb[:1] and abs(len(ca) - len(cb)) <= 1 and max(len(ca), len(cb)) <= 2:
        return "slant"
    if morph == "slant":
        return "slant"
    return None
