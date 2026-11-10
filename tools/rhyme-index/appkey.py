#!/usr/bin/env python3
"""App rhyme keys. Same rules as RhymeHighlighterEngine in ContentView.CCV.3.swift.

rime() is PhoneticSignature.rimeKey.
end_group_key() is RhymeHighlighterEngine.endGroupKey.
Phonemes follow phonemes(for:): spoken digits, the locked-slant slang
exception, CMU, the slang table, the letter heuristic, then the locked
IH1 T fallback.
"""
from __future__ import annotations

import cmudict

CMU = cmudict.dict()

RHYME_STOPWORDS = {
    "a", "an", "the", "of", "to", "in", "on", "and", "or", "but", "for", "with",
    "at", "by", "as", "is", "it", "be", "we", "my", "me", "you", "i", "im", "i'm",
    "so", "if", "do", "no", "it's", "its", "yeah", "yea", "got",
}
LOCKED_SLANT = {"militant", "idiot", "immigrant", "commits", "script", "shit"}
LOCKED_EXCLUSIONS = {"blink", "think", "pink", "link", "sink", "drink", "ink"}
IH_ALVEOLAR = "IH|ALVSTOP"
FEMININE_SUFFIX = "|Y"
STOP_SUFFIX = "|STOP-PBGK"
VOWELS = {"AA", "AE", "AH", "AO", "AW", "AY", "EH", "ER", "EY", "IH", "IY", "OW", "OY", "UH", "UW"}
LABIAL_VELAR = {"P", "B", "K", "G"}
SLANG = {
    "opp": ["AA1", "P"],
    "opps": ["AA1", "P", "S"],
    "blick": ["B", "L", "IH1", "K"],
    "switchy": ["S", "W", "IH1", "CH", "IY0"],
    "gangnem": ["G", "AE1", "NG", "N", "EH0", "M"],
    "perc": ["P", "ER1", "K"],
    "percs": ["P", "ER1", "K", "S"],
    "skrrt": ["S", "K", "R", "ER1", "T"],
    "skrt": ["S", "K", "R", "ER1", "T"],
    "drip": ["D", "R", "IH1", "P"],
    "glizzy": ["G", "L", "IH1", "Z", "IY0"],
    "bando": ["B", "AE1", "N", "D", "OW0"],
    "choppa": ["CH", "AA1", "P", "AH0"],
    "chopper": ["CH", "AA1", "P", "ER0"],
    "trap": ["T", "R", "AE1", "P"],
    "slatt": ["S", "L", "AE1", "T"],
    "slat": ["S", "L", "AE1", "T"],
    "cap": ["K", "AE1", "P"],
    "capping": ["K", "AE1", "P", "IH0", "NG"],
    "no cap": ["N", "OW1", "K", "AE1", "P"],
    "bussin": ["B", "AH1", "S", "IH0", "N"],
    "bussing": ["B", "AH1", "S", "IH0", "NG"],
    "lit": ["L", "IH1", "T"],
    "militant": ["M", "IH1", "L", "AH0", "T", "AH0", "N", "T"],
    "idiot": ["IH1", "D", "IY0", "AH0", "T"],
    "immigrant": ["IH1", "M", "AH0", "G", "R", "AH0", "N", "T"],
    "commits": ["K", "AH0", "M", "IH1", "T", "S"],
    "script": ["S", "K", "R", "IH1", "P", "T"],
    "shit": ["SH", "IH1", "T"],
    "flex": ["F", "L", "EH1", "K", "S"],
    "flexin": ["F", "L", "EH1", "K", "S", "IH0", "N"],
    "vibes": ["V", "AY1", "B", "Z"],
    "vibe": ["V", "AY1", "B"],
    "chelly": ["CH", "EH1", "L", "IY0"],
    "dummy": ["D", "AH1", "M", "IY0"],
    "money": ["M", "AH1", "N", "IY0"],
    "hip": ["HH", "IH1", "P"],
    "dick": ["D", "IH1", "K"],
    "pretty": ["P", "R", "IH1", "T", "IY0"],
    "clips": ["K", "L", "IH1", "P", "S"],
    "dancer": ["D", "AE1", "N", "S", "ER0"],
    "cancer": ["K", "AE1", "N", "S", "ER0"],
}
ONES = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
TEENS = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
TENS = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]


def _bare(phone: str) -> str:
    return "".join(ch for ch in phone if not ch.isdigit())


def spell_out(number: int) -> str:
    """en_US NumberFormatter.spellOut for the values the highlighter spells."""
    if number < 0:
        return "minus " + spell_out(-number)
    if number < 10:
        return ONES[number]
    if number < 20:
        return TEENS[number - 10]
    if number < 100:
        ten, one = divmod(number, 10)
        return TENS[ten] if one == 0 else f"{TENS[ten]}-{ONES[one]}"
    if number < 1000:
        hundred, rest = divmod(number, 100)
        head = ONES[hundred] + " hundred"
        return head if rest == 0 else head + " " + spell_out(rest)
    return str(number)


def spoken_digit_words(word: str):
    if not word or not word.isdigit():
        return None
    if len(word) == 1:
        return [ONES[int(word)]]
    spoken = spell_out(int(word)).lower()
    parts = []
    buf = []
    for ch in spoken:
        if ch.isalpha():
            buf.append(ch)
        elif buf:
            parts.append("".join(buf))
            buf = []
    if buf:
        parts.append("".join(buf))
    return parts or None


def _heuristic(word: str):
    if len(word) < 3 or not word.isalpha():
        return None
    phones = []
    vowel_count = 0
    i = 0
    chars = word
    while i < len(chars):
        c = chars[i]
        nxt = chars[i + 1] if i + 1 < len(chars) else ""
        if c == "c" and nxt == "h":
            phones.append("CH")
            i += 2
            continue
        if c == "s" and nxt == "h":
            phones.append("SH")
            i += 2
            continue
        if c == "t" and nxt == "h":
            phones.append("TH")
            i += 2
            continue
        if c == "p" and nxt == "h":
            phones.append("F")
            i += 2
            continue
        if c == "n" and nxt == "g":
            phones.append("NG")
            i += 2
            continue
        if c == "c" and nxt == "k":
            phones.append("K")
            i += 2
            continue
        if nxt == c and c not in "aeiouy":
            phones.append(_consonant(c))
            i += 2
            continue
        if c == "y" and i == len(chars) - 1:
            phones.append("IY0")
            i += 1
            continue
        if c in "aeiou":
            vowel_count += 1
            phones.append(_vowel(c, vowel_count == 1))
            i += 1
            continue
        phones.append(_consonant(c))
        i += 1
    if not any(phone[-1:].isdigit() for phone in phones):
        return None
    return phones


def _vowel(char: str, stressed: bool) -> str:
    mark = "1" if stressed else "0"
    return {"a": "AE", "e": "EH", "i": "IH", "o": "AA", "u": "AH"}.get(char, "AH") + mark


def _consonant(char: str) -> str:
    return {
        "b": "B", "c": "K", "d": "D", "f": "F", "g": "G", "h": "HH", "j": "JH",
        "k": "K", "l": "L", "m": "M", "n": "N", "p": "P", "q": "K", "r": "R",
        "s": "S", "t": "T", "v": "V", "w": "W", "x": "K", "z": "Z",
    }.get(char, "T")


def phonemes(word: str):
    w = word.lower()
    spoken = spoken_digit_words(w)
    if spoken is not None:
        phones = []
        for part in spoken:
            nxt = phonemes(part)
            if not nxt:
                return None
            phones.extend(nxt)
        return phones
    if w in LOCKED_SLANT:
        slang = SLANG.get(w)
        if slang:
            return list(slang)
    hit = CMU.get(w)
    if hit:
        return list(hit[0])
    slang = SLANG.get(w)
    if slang:
        return list(slang)
    guess = _heuristic(w)
    if guess:
        return guess
    if w in LOCKED_SLANT:
        return ["IH1", "T"]
    return None


def extract_signature(phones):
    idx = None
    for i, phone in enumerate(phones):
        if phone.endswith("1") or phone.endswith("2"):
            idx = i
    if idx is None:
        return None
    return phones[idx], list(phones[idx + 1:])


def rime_key(vowel: str, coda) -> str:
    bare = _bare(vowel)
    if not coda:
        return bare
    return bare + "|" + "-".join(coda)


def rime(word: str):
    phones = phonemes(word)
    if not phones:
        return None
    sig = extract_signature(phones)
    if sig is None:
        return None
    return rime_key(sig[0], sig[1])


def _stripped_coda(coda):
    phones = [_bare(phone) for phone in coda]
    while phones and phones[-1] in {"S", "Z"}:
        phones.pop()
    return phones


def _last_consonant(coda):
    for phone in reversed(coda):
        bare = _bare(phone)
        if bare in {"S", "Z"} or bare in VOWELS or not bare:
            continue
        return bare
    return None


def _feminine_family(vowel: str) -> str:
    bare = _bare(vowel)
    if bare in {"IH", "EH"}:
        return "IH-EH"
    return bare


def end_group_key(word: str, is_line_end: bool = False):
    """RhymeHighlighterEngine.endGroupKey. None when the word has no phonemes."""
    phones = phonemes(word)
    if not phones:
        return None
    sig = extract_signature(phones)
    if sig is None:
        return None
    vowel, coda = sig
    w = word.lower()
    if w in LOCKED_EXCLUSIONS:
        return rime_key(vowel, coda)
    if w in LOCKED_SLANT:
        return IH_ALVEOLAR
    stripped = _stripped_coda(coda)
    if stripped and stripped[-1] == "IY":
        return _feminine_family(vowel) + FEMININE_SUFFIX
    bare_v = _bare(vowel)
    last = _last_consonant(coda)
    if bare_v in {"IY", "IH"} and last in {"T", "CH"}:
        return bare_v + "|TCH"
    if is_line_end and bare_v in {"IH", "IY"} and last in {"T", "D"}:
        return IH_ALVEOLAR
    if is_line_end and last in {"T", "D"}:
        return IH_ALVEOLAR
    if "NG" not in stripped:
        consonants = [phone for phone in stripped if phone not in VOWELS]
        if len(consonants) == 1 and consonants[0] in LABIAL_VELAR:
            return bare_v + STOP_SUFFIX
    return rime_key(vowel, coda)


def _check():
    words = (
        "shit blink think pretty money cheat got hip dummy clips eight 8 ice life "
        "drip trap slatt wunna nigga phone tone alone microphone militant idiot "
        "immigrant commits script dick dancer cancer chelly flex bussin opp perc "
        "skrrt glizzy bando choppa cap lit vibe yeah the a me you don't ain't "
        "back ride time know down she they that with like this niggas gunna "
        "summer bird heard turn mitt ceilin position billion lamborghini zucchini "
        "water walk call talk girl world work first hurt night light right fight "
        "mind find kind line mine time game name same came fame pain rain brain "
        "street beat heat seat feet meat treat sweet creep sleep deep keep "
        "hop stop drop cop top shop rock lock clock block shock knock "
        "run gun fun son done one none ton won sun "
        "king ring sing thing bring string swing "
        "love dove above glove "
        "crazy lazy hazy "
        "baby maybe lady "
        "city pretty dirty thirty "
        "money honey funny "
        "please tease knees cheese trees breeze freeze "
        "go goat ghost "
        "man manage "
        "blue clue true shoe two through "
        "red bed head said dead "
        "black back sack pack rack stack "
        "green clean mean seen dream cream "
        "gold cold told sold fold hold "
        "high fly sky cry try die "
        "low slow blow flow glow show "
        "car star far bar scar jar "
        "dog log fog jog "
        "cat hat bat mat fat rat "
        "dogma sigma "
        "21 100"
    ).split()
    seen = []
    for word in words:
        if word not in seen:
            seen.append(word)
    for word in sorted(CMU):
        if len(seen) >= 200:
            break
        if word not in seen and word.isalpha():
            seen.append(word)
    seen = seen[:200]
    checks = {
        ("shit", True): "IH|ALVSTOP",
        ("shit", False): "IH|ALVSTOP",
        ("blink", True): "IH|NG-K",
        ("blink", False): "IH|NG-K",
        ("pretty", False): "IH-EH|Y",
        ("pretty", True): "IH-EH|Y",
        ("money", False): "AH|Y",
        ("cheat", True): "IY|TCH",
        ("cheat", False): "IY|TCH",
        ("got", True): "IH|ALVSTOP",
        ("got", False): "AA|T",
        ("hip", False): "IH|STOP-PBGK",
        ("dummy", False): "AH|Y",
        ("clips", False): "IH|STOP-PBGK",
    }
    failed = 0
    for (word, line_end), expect in checks.items():
        got = end_group_key(word, line_end)
        if got != expect:
            failed += 1
            print(f"FAIL {word} line_end={line_end} {got} != {expect}")
    eight = end_group_key("8", False)
    if eight != end_group_key("eight", False):
        failed += 1
        print("FAIL 8", eight)
    print(f"WORDS {len(seen)} CHECKS {len(checks)} FAILED {failed}")
    for word in seen:
        print(f"{word}\t{rime(word)}\t{end_group_key(word, False)}\t{end_group_key(word, True)}")
    if len(seen) != 200 or failed:
        raise SystemExit(1)


if __name__ == "__main__":
    _check()
