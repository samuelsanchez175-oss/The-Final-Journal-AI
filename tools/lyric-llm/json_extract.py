#!/usr/bin/env python3
"""Tolerant JSON extraction for reasoning-model planner replies (Appendix A T2).

Stdlib only. Strips thinking tags and code fences, repairs trailing commas
and Python literals, then falls back to a small recursive-descent parser.
"""

from __future__ import annotations

import json
import re
from typing import Any, Callable, Optional

_THINKING = re.compile(r"<(?:thinking|think)>.*?</(?:thinking|think)>", re.IGNORECASE | re.DOTALL)
_FENCE = re.compile(r"```(?:json|JSON)?")


def extract_json(text: str, schema_hint: Optional[Any] = None, _depth: int = 0) -> Optional[dict]:
    """Return the first usable JSON object in text, or None."""
    if text is None or _depth > 3:
        return None
    cleaned = _prepare(str(text))
    if not cleaned:
        return None
    found: list[dict] = []
    try:
        whole = json.loads(cleaned)
    except Exception:
        whole = None
    if isinstance(whole, dict):
        found.append(whole)
    elif isinstance(whole, str):
        inner = extract_json(whole, schema_hint, _depth + 1)
        if inner is not None:
            found.append(inner)
    spans = _object_spans(cleaned)
    if not spans:
        start = cleaned.find("{")
        end = cleaned.rfind("}")
        if start >= 0 and end > start:
            spans = [cleaned[start : end + 1]]
    for span in spans:
        obj = _loads_span(span)
        if isinstance(obj, dict):
            found.append(obj)
    if not found:
        return None
    preferred = _prefer(found, schema_hint)
    return preferred


def extract_json_with_retry(
    text: str,
    call_model_fn: Optional[Callable[[str], str]] = None,
    max_retries: int = 1,
) -> Optional[dict]:
    """Parse text. On failure, ask the model once for JSON only."""
    found = extract_json(text)
    if found is not None:
        return found
    if max_retries < 1 or call_model_fn is None:
        return None
    try:
        follow = call_model_fn(
            "Previous response was not valid JSON. RESPOND WITH JSON ONLY, no prose, no code fences."
        )
    except Exception:
        return None
    return extract_json(follow if isinstance(follow, str) else "")


def _prepare(text: str) -> str:
    text = text.replace("\ufeff", "")
    text = _THINKING.sub("", text)
    text = _FENCE.sub("", text)
    text = text.replace("```", "")
    text = (
        text.replace("\u201c", '"')
        .replace("\u201d", '"')
        .replace("\u2018", "'")
        .replace("\u2019", "'")
    )
    return text.strip()


def _prefer(found: list[dict], schema_hint: Optional[Any]) -> dict:
    keys: list[str] = []
    if isinstance(schema_hint, (list, tuple)):
        keys = [str(k) for k in schema_hint]
    elif isinstance(schema_hint, dict):
        keys = [str(k) for k in schema_hint.keys()]
    if "end_words" not in keys:
        keys.append("end_words")
    for obj in found:
        if any(key in obj for key in keys if key != "end_words" or "end_words" in obj):
            if "end_words" in obj:
                return obj
    for obj in found:
        if "end_words" in obj:
            return obj
    if schema_hint:
        for obj in found:
            if isinstance(schema_hint, (list, tuple)) and all(k in obj for k in schema_hint):
                return obj
    return found[0]


def _loads_span(span: str, depth: int = 0) -> Optional[dict]:
    if depth > 3:
        return None
    repaired = _strip_trailing_commas(span)
    value: Any
    try:
        value = json.loads(repaired)
    except Exception:
        value = _tolerant_parse(span)
    if isinstance(value, str):
        return extract_json(value) if depth == 0 else _loads_span(value, depth + 1)
    if isinstance(value, dict):
        return value
    return None


def _strip_trailing_commas(text: str) -> str:
    return re.sub(r",(\s*[}\]])", r"\1", text)


def _object_spans(text: str) -> list[str]:
    spans: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        if text[i] == "{":
            end = _match_brace(text, i)
            if end is None:
                i += 1
                continue
            spans.append(text[i : end + 1])
            i = end + 1
            continue
        i += 1
    return spans


def _match_brace(text: str, start: int) -> Optional[int]:
    depth = 0
    i = start
    n = len(text)
    quote = ""
    while i < n:
        ch = text[i]
        if quote:
            if ch == "\\":
                i += 2
                continue
            if ch == quote:
                quote = ""
            i += 1
            continue
        if ch in ('"', "'"):
            quote = ch
            i += 1
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return None


def _tolerant_parse(text: str) -> Any:
    parser = _Parser(text)
    try:
        value = parser.parse_value()
    except Exception:
        return None
    return value


class _Parser:
    def __init__(self, text: str):
        self.text = text
        self.n = len(text)
        self.i = 0

    def parse_value(self) -> Any:
        self._skip()
        if self.i >= self.n:
            raise ValueError("empty")
        ch = self.text[self.i]
        if ch == "{":
            return self._object()
        if ch == "[":
            return self._array()
        if ch in ('"', "'"):
            return self._string()
        if ch == "-" or ch.isdigit():
            return self._number()
        word = self._word()
        low = word.lower()
        if low in ("true",):
            return True
        if low in ("false",):
            return False
        if low in ("null", "none"):
            return None
        raise ValueError(word)

    def _object(self) -> dict:
        self.i += 1
        obj: dict = {}
        while True:
            self._skip()
            if self.i < self.n and self.text[self.i] == "}":
                self.i += 1
                return obj
            key = self._string() if self.text[self.i] in ('"', "'") else self._bare_key()
            self._skip()
            if self.i >= self.n or self.text[self.i] != ":":
                raise ValueError("expected colon")
            self.i += 1
            obj[str(key)] = self.parse_value()
            self._skip()
            if self.i < self.n and self.text[self.i] == ",":
                self.i += 1
                self._skip()
                if self.i < self.n and self.text[self.i] == "}":
                    self.i += 1
                    return obj
                continue
            if self.i < self.n and self.text[self.i] == "}":
                self.i += 1
                return obj
            raise ValueError("expected comma or brace")

    def _array(self) -> list:
        self.i += 1
        arr: list = []
        while True:
            self._skip()
            if self.i < self.n and self.text[self.i] == "]":
                self.i += 1
                return arr
            arr.append(self.parse_value())
            self._skip()
            if self.i < self.n and self.text[self.i] == ",":
                self.i += 1
                self._skip()
                if self.i < self.n and self.text[self.i] == "]":
                    self.i += 1
                    return arr
                continue
            if self.i < self.n and self.text[self.i] == "]":
                self.i += 1
                return arr
            raise ValueError("expected comma or bracket")

    def _string(self) -> str:
        quote = self.text[self.i]
        self.i += 1
        chars: list[str] = []
        while self.i < self.n:
            ch = self.text[self.i]
            if ch == "\\":
                self.i += 1
                if self.i >= self.n:
                    break
                esc = self.text[self.i]
                mapping = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "'": "'", "\\": "\\", "/": "/"}
                chars.append(mapping.get(esc, esc))
                self.i += 1
                continue
            if ch == quote:
                self.i += 1
                return "".join(chars)
            chars.append(ch)
            self.i += 1
        raise ValueError("unterminated string")

    def _number(self) -> Any:
        start = self.i
        if self.text[self.i] == "-":
            self.i += 1
        while self.i < self.n and self.text[self.i].isdigit():
            self.i += 1
        if self.i < self.n and self.text[self.i] == ".":
            self.i += 1
            while self.i < self.n and self.text[self.i].isdigit():
                self.i += 1
            return float(self.text[start : self.i])
        return int(self.text[start : self.i])

    def _word(self) -> str:
        start = self.i
        while self.i < self.n and (self.text[self.i].isalpha() or self.text[self.i] == "_"):
            self.i += 1
        if start == self.i:
            raise ValueError("expected word")
        return self.text[start : self.i]

    def _bare_key(self) -> str:
        start = self.i
        while self.i < self.n and self.text[self.i] not in (":", "}", ",", " ", "\n", "\t"):
            self.i += 1
        if start == self.i:
            raise ValueError("expected key")
        return self.text[start : self.i]

    def _skip(self) -> None:
        while self.i < self.n and self.text[self.i] in " \t\r\n":
            self.i += 1
