"""C2 — phonemes, rhyme families, syllables, and line flags."""

from __future__ import annotations

from collections import Counter

from catalog_build.paths import CMU_PATH
from catalog_build.schema import AnnotatedLine, RawLine
from lyriclib import RAP_VOWEL_CLASSES, end_rime, estimate_syllables, load_cmudict, normalize, tokenize

# Last-three-letter tails for words CMU does not know. drip/blick share a class.
# switchy and opp each land on one stable class.
_TAIL_CLASS = {
    "rip": "V_weak",
    "ick": "V_weak",
    "chy": "V_front_high",
    "opp": "V_broad",
    "eez": "V_front_high",
    "ies": "V_front_high",
    "een": "V_front_high",
    "eat": "V_front_high",
    "ame": "V_front_mid",
    "ade": "V_front_mid",
    "ake": "V_front_mid",
    "ite": "V_front_low",
    "ime": "V_front_low",
    "azz": "V_front_open",
    "ang": "V_front_open",
    "ore": "V_broad",
    "awd": "V_broad",
    "ock": "V_broad",
    "ung": "V_weak",
    "ill": "V_weak",
    "own": "V_round_mid",
    "oad": "V_round_mid",
    "ewd": "V_round_high",
    "uce": "V_round_high",
}

_VOWEL_LETTER = {
    "a": "V_front_open",
    "e": "V_front_open",
    "i": "V_weak",
    "o": "V_broad",
    "u": "V_weak",
    "y": "V_front_high",
}

_STOP = {
    "a", "an", "the", "and", "or", "in", "on", "at", "to", "for", "with",
    "is", "it", "of", "my", "me", "i", "you", "he", "she", "we", "they",
    "that", "this", "gotta", "been", "up", "has", "was", "be", "so", "as",
}

_CMU = None


def load_cmu() -> dict:
    global _CMU
    if _CMU is None:
        _CMU = load_cmudict(CMU_PATH) if CMU_PATH.exists() else {}
    return _CMU


def big_phoney(word: str) -> tuple[str, str]:
    """Approximate a vowel class from the last three characters."""
    token = (word or "").lower()
    tail = token[-3:] if len(token) >= 3 else token
    vowel = _TAIL_CLASS.get(tail)
    if vowel is None:
        for char in reversed(tail):
            if char in _VOWEL_LETTER:
                vowel = _VOWEL_LETTER[char]
                break
    if vowel is None:
        vowel = "V_other"
    return vowel, f"BP_{vowel}_{tail}"


def _arc(relative_pos: float) -> str:
    if relative_pos <= 0.25:
        return "intro"
    if relative_pos <= 0.50:
        return "verse_build"
    if relative_pos <= 0.75:
        return "verse_turn"
    return "climax_punch"


def _stressed_vowel(word: str, cmu: dict) -> str:
    phones = cmu.get(word.lower())
    if not phones:
        return ""
    vowels = [phone for phone in phones if any(char.isdigit() for char in phone)]
    if not vowels:
        return ""
    for phone in vowels:
        if phone[-1] in "12":
            return phone
    return vowels[-1]


def _syllables(tokens: list[str], cmu: dict) -> int:
    total = 0
    for token in tokens:
        phones = cmu.get(token)
        if phones:
            vowels = [phone for phone in phones if any(char.isdigit() for char in phone)]
            total += max(1, len(vowels))
        else:
            total += estimate_syllables(token)
    return max(1, total)


def _inner(tokens: list[str], cmu: dict) -> list[dict]:
    info = []
    for index, word in enumerate(tokens):
        if word in _STOP:
            continue
        vowel = _stressed_vowel(word, cmu)
        if vowel:
            v_class = RAP_VOWEL_CLASSES.get(vowel, "V_other")
            rime = end_rime(word, cmu)
            info.append({
                "word": word,
                "pos": index,
                "v_class": v_class,
                "rime": " ".join(rime) if rime else "",
            })
            continue
        v_class, _rime = big_phoney(word)
        info.append({
            "word": word,
            "pos": index,
            "v_class": v_class,
            "rime": "",
        })
    matches = []
    for left in range(len(info)):
        for right in range(left + 1, len(info)):
            a = info[left]
            b = info[right]
            same_rime = bool(a["rime"] and a["rime"] == b["rime"])
            same_vowel = bool(a["v_class"] and a["v_class"] == b["v_class"] and a["v_class"] != "V_other")
            if same_rime or same_vowel:
                matches.append({
                    "w1": a["word"],
                    "pos1": a["pos"],
                    "w2": b["word"],
                    "pos2": b["pos"],
                    "v_class": a["v_class"] or b["v_class"],
                    "exact_rime": same_rime,
                })
    return matches


def _dominant(matches: list[dict]) -> str:
    counts = Counter(item.get("v_class") or "" for item in matches)
    counts.pop("", None)
    if not counts:
        return ""
    return counts.most_common(1)[0][0]


def _whitelist(artist: str) -> set[str]:
    from entity_guard import ARTIST_CORE_ENTITIES, UNIVERSAL_LUXURY_BRANDS

    names = {item.lower() for item in UNIVERSAL_LUXURY_BRANDS}
    key = (artist or "").strip().lower()
    for alias, bucket in (
        ("gunna", "gunna"),
        ("thug", "young thug"),
        ("wayne", "lil wayne"),
        ("drake", "drake"),
        ("baby", "lil baby"),
        ("nocap", "nocap"),
    ):
        if alias in key:
            key = bucket
            break
    names.update(item.lower() for item in ARTIST_CORE_ENTITIES.get(key, set()))
    return names


def _proper(text: str, tokens: list[str], artist: str, whitelist: set[str] | None) -> bool:
    names = whitelist if whitelist is not None else _whitelist(artist)
    if any(token in names for token in tokens):
        return True
    raw_words = [piece.strip(".,;:!?\"'") for piece in text.split()]
    for index, raw in enumerate(raw_words):
        if index == 0 or len(raw) < 2 or not raw[0].isupper():
            continue
        token = normalize(raw)
        if token and token not in {"i", "a"} and token in tokens:
            return True
    return False


def annotate_line(
    line: RawLine,
    cmu: dict,
    blacklist: set[str],
    whitelist: set[str] | None = None,
) -> AnnotatedLine:
    tokens = tokenize(normalize(line.text))
    end_word = tokens[-1] if tokens else ""
    rime = end_rime(end_word, cmu) if end_word else None
    if rime:
        end_rime_text = " ".join(rime)
        vowel_phone = _stressed_vowel(end_word, cmu)
        vowel_class = RAP_VOWEL_CLASSES.get(vowel_phone, "V_other") if vowel_phone else "V_other"
    else:
        vowel_class, end_rime_text = big_phoney(end_word) if end_word else ("V_other", "")
    total = line.total_lines or 1
    relative = round((line.line_seq or 1) / float(total), 3)
    if relative > 1:
        relative = 1.0
    matches = _inner(tokens, cmu)
    return AnnotatedLine(
        raw=line,
        tokens=tokens,
        end_word=end_word,
        end_rime=end_rime_text,
        vowel_class=vowel_class,
        syllables=_syllables(tokens, cmu),
        inner_rhymes=matches[:8],
        inner_rhyme_count=len(matches),
        inner_vowel_class=_dominant(matches),
        is_generic=bool(end_word in blacklist or len(end_word) <= 2),
        is_proper_noun=_proper(line.text, tokens, line.artist, whitelist),
        chronological_arc=_arc(relative),
        relative_pos=relative,
    )


def link_couplets(lines: list[AnnotatedLine]) -> list[AnnotatedLine]:
    groups: dict[tuple[str, str], list[AnnotatedLine]] = {}
    for line in lines:
        key = (line.raw.artist, line.raw.song)
        groups.setdefault(key, []).append(line)
    for group in groups.values():
        group.sort(key=lambda item: item.raw.line_seq)
        for index, line in enumerate(group):
            nxt = group[index + 1] if index + 1 < len(group) else None
            line.next_bar_text = nxt.raw.text if nxt else ""
            line.next_bar_end_word = nxt.end_word if nxt else ""
    return lines


def annotate(lines: list[RawLine], cmu: dict | None = None) -> list[AnnotatedLine]:
    from polish import GENERIC_END_RHYME_BLACKLIST

    dictionary = load_cmu() if cmu is None else cmu
    whitelist_cache: dict[str, set[str]] = {}
    annotated = []
    for line in lines:
        key = line.artist.strip().lower()
        if key not in whitelist_cache:
            whitelist_cache[key] = _whitelist(line.artist)
        annotated.append(annotate_line(line, dictionary, GENERIC_END_RHYME_BLACKLIST, whitelist_cache[key]))
    return link_couplets(annotated)
