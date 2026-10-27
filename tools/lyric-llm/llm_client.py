#!/usr/bin/env python3
"""llm_client.py
================
Unified, direct SDK client for Frontier v4.
Dispatches directly to Anthropic or OpenAI SDK based on model prefix.
OmniRoute is completely removed from generation paths.
Zero key logging in all error and telemetry paths.
"""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
from typing import Any, Optional

# Load ~/.env or repo root .env if present
try:
    for env_path in (Path(__file__).resolve().parent.parent.parent / ".env", Path.home() / ".env"):
        if env_path.is_file():
            with env_path.open("r", encoding="utf-8") as f:
                for line in f:
                    s_line = line.strip()
                    if s_line and not s_line.startswith("#") and "=" in s_line:
                        k, v = s_line.split("=", 1)
                        k, v = k.strip(), v.strip().strip("\"'")
                        if k not in os.environ and v:
                            os.environ[k] = v
except Exception:
    pass

try:
    import anthropic
except ImportError:
    anthropic = None

try:
    import openai
except ImportError:
    openai = None

# llama-cpp-python is heavy to load; keep instances cached by (model_path, lora_path).
_LLAMA_INSTANCES: dict[tuple, Any] = {}


def _get_llama_cpp(model_path: str, lora_path: str | None, n_ctx: int = 2048):
    key = (model_path, lora_path, n_ctx)
    inst = _LLAMA_INSTANCES.get(key)
    if inst is not None:
        return inst
    from llama_cpp import Llama  # noqa: WPS433
    kwargs = {
        "model_path": model_path,
        "n_ctx": n_ctx,
        "n_gpu_layers": -1,
        "verbose": False,
    }
    if lora_path:
        kwargs["lora_path"] = lora_path
    inst = Llama(**kwargs)
    _LLAMA_INSTANCES[key] = inst
    return inst


MODEL_ALIASES: dict[str, str] = {
    "claude-opus-4-7": os.environ.get("ANTHROPIC_OPUS_MODEL", "claude-3-opus-20240229"),
    "claude-sonnet-5-5": os.environ.get("ANTHROPIC_SONNET_MODEL", "claude-3-5-sonnet-20241022"),
    "auto/claude-opus": os.environ.get("ANTHROPIC_OPUS_MODEL", "claude-3-opus-20240229"),
    "auto/best-reasoning": os.environ.get("ANTHROPIC_OPUS_MODEL", "claude-3-opus-20240229"),
    "auto/pro-reasoning": os.environ.get("ANTHROPIC_OPUS_MODEL", "claude-3-opus-20240229"),
    "auto/best-coding": os.environ.get("ANTHROPIC_OPUS_MODEL", "claude-3-opus-20240229"),
    "auto/pro-coding": os.environ.get("ANTHROPIC_OPUS_MODEL", "claude-3-opus-20240229"),
    "auto/fast": os.environ.get("OPENAI_FAST_MODEL", "gpt-4o-mini"),
    "auto/best-fast": os.environ.get("OPENAI_FAST_MODEL", "gpt-4o-mini"),
    "gh/gpt-4o-mini": "gpt-4o-mini",
    "gh/gpt-4o": "gpt-4o",
}

# Resolved-model-id -> provider name. Populated from the registry so a
# bare model id (ft:... or user/repo-ft-123) can tell dispatch which base
# URL + key to use. Values: "openai", "together", "anthropic", "xai".
MODEL_PROVIDERS: dict[str, str] = {}

TOGETHER_BASE_URL = os.environ.get("TOGETHER_BASE_URL", "https://api.together.xyz/v1")
XAI_BASE_URL = os.environ.get("XAI_BASE_URL", "https://api.x.ai/v1")
FIREWORKS_BASE_URL = os.environ.get("FIREWORKS_BASE_URL", "https://api.fireworks.ai/inference/v1")


def _load_registry_aliases() -> None:
    """Register fine-tune aliases from tools/lyric-llm/model_registry.json.

    Each models.<alias> may carry either openai_id (OpenAI fine-tune) or
    together_id (Together.ai fine-tune) or model_id (provider-agnostic) plus
    an optional "provider" field. Missing or malformed file is silently
    skipped.
    """
    try:
        path = Path(__file__).resolve().parent / "model_registry.json"
        if not path.is_file():
            return
        data = json.loads(path.read_text(encoding="utf-8"))
        models = data.get("models") if isinstance(data, dict) else None
        if not isinstance(models, dict):
            return
        for alias, meta in models.items():
            if not isinstance(meta, dict):
                continue
            model_id = (
                meta.get("model_id")
                or meta.get("openai_id")
                or meta.get("together_id")
            )
            if not (isinstance(model_id, str) and model_id):
                continue
            MODEL_ALIASES.setdefault(alias, model_id)
            provider = meta.get("provider")
            if provider in {"openai", "together", "anthropic", "xai", "fireworks"}:
                MODEL_PROVIDERS[model_id] = provider
            elif meta.get("together_id"):
                MODEL_PROVIDERS[model_id] = "together"
            elif meta.get("openai_id"):
                MODEL_PROVIDERS[model_id] = "openai"
            elif meta.get("xai_id"):
                MODEL_PROVIDERS[model_id] = "xai"
    except Exception:
        return


_load_registry_aliases()


def _infer_provider(resolved: str) -> str:
    """Fallback provider inference by model-id shape when registry is silent."""
    if resolved in MODEL_PROVIDERS:
        return MODEL_PROVIDERS[resolved]
    if resolved.startswith("local/") or resolved.startswith("llamacpp/"):
        return "llamacpp"
    if resolved.startswith("together/"):
        return "together"
    if resolved.startswith("xai/") or resolved.startswith("grok"):
        return "xai"
    if resolved.startswith("fireworks/") or resolved.startswith("accounts/fireworks/") or resolved.startswith("accounts/"):
        return "fireworks"
    if resolved.startswith("claude") or "claude" in resolved:
        return "anthropic"
    if (
        resolved.startswith("gpt")
        or resolved.startswith("o1")
        or resolved.startswith("o3")
        or resolved.startswith("ft:")
        or "openai" in resolved
    ):
        return "openai"
    # Together namespace shapes: username/repo, meta-llama/*, Qwen/*, etc.
    if "/" in resolved and not resolved.startswith("ft:"):
        return "together"
    return "openai"


def resolve_model_name(model: str) -> str:
    """Resolve aliases to target SDK model identifiers."""
    cleaned = (model or "").strip()
    return MODEL_ALIASES.get(cleaned, cleaned)


def chat(
    model: str,
    system: str,
    user: str,
    max_tokens: int = 800,
    temperature: float = 0.7,
    api_key: Optional[str] = None,
    anthropic_client: Optional[Any] = None,
    openai_client: Optional[Any] = None,
) -> str:
    """Dispatches chat completions directly through Anthropic or OpenAI SDK.

    Args:
        model: Model identifier (e.g., 'claude-3-5-sonnet-20241022', 'gpt-4o', or alias).
        system: System instructions.
        user: User message content.
        max_tokens: Maximum output tokens.
        temperature: Sampling temperature.
        api_key: Optional explicit API key (defaults to provider env var).
        anthropic_client: Optional preconfigured anthropic.Anthropic client.
        openai_client: Optional preconfigured openai.OpenAI client.

    Returns:
        Generated text string.
    """
    resolved = resolve_model_name(model)
    provider = _infer_provider(resolved)
    if resolved.startswith("together/"):
        resolved = resolved[len("together/") :]
    if resolved.startswith("xai/"):
        resolved = resolved[len("xai/") :]
    if resolved.startswith("fireworks/"):
        resolved = resolved[len("fireworks/") :]
    if resolved.startswith("local/") or resolved.startswith("llamacpp/"):
        resolved = resolved.split("/", 1)[1]

    # Local llama-cpp provider: alias resolves to "<base_gguf_path>|<lora_gguf_path>"
    if provider == "llamacpp":
        if "|" in resolved:
            base_p, lora_p = resolved.split("|", 1)
        else:
            base_p, lora_p = resolved, None
        llm = _get_llama_cpp(base_p, lora_p)
        resp = llm.create_chat_completion(
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": user},
            ],
            max_tokens=max_tokens,
            temperature=temperature,
        )
        text = resp["choices"][0]["message"]["content"] or ""
        return _finish(resolved, system, user, text, resp)

    # 1. Anthropic Provider (claude-*)
    if provider == "anthropic":
        if anthropic_client is not None:
            client = anthropic_client
        else:
            if anthropic is None:
                raise RuntimeError("The 'anthropic' package is not installed. Install with: pip install anthropic")
            key = api_key or os.environ.get("ANTHROPIC_API_KEY")
            if not key:
                raise ValueError("ANTHROPIC_API_KEY is not set. Direct Anthropic SDK dispatch requires a valid key.")
            client = anthropic.Anthropic(api_key=key)

        response = client.messages.create(
            model=resolved,
            system=system,
            messages=[{"role": "user", "content": user}],
            max_tokens=max_tokens,
            temperature=temperature,
        )
        if response and response.content:
            return _finish(resolved, system, user, response.content[0].text or "", response)
        return _finish(resolved, system, user, "", response)

    # 2. OpenAI-compatible provider (OpenAI itself, Together, xAI, Fireworks)
    if provider in ("openai", "together", "xai", "fireworks"):
        if openai_client is not None:
            client = openai_client
        else:
            if openai is None:
                raise RuntimeError("The 'openai' package is not installed. Install with: pip install openai")
            if provider == "together":
                key = api_key or os.environ.get("TOGETHER_API_KEY")
                if not key:
                    raise ValueError("TOGETHER_API_KEY is not set. Together dispatch requires it.")
                client = openai.OpenAI(api_key=key, base_url=TOGETHER_BASE_URL)
            elif provider == "xai":
                key = api_key or os.environ.get("XAI_API_KEY") or os.environ.get("GROK_API_KEY")
                if not key:
                    raise ValueError("XAI_API_KEY (or GROK_API_KEY) is not set. xAI dispatch requires it.")
                client = openai.OpenAI(api_key=key, base_url=XAI_BASE_URL)
            elif provider == "fireworks":
                key = api_key or os.environ.get("FIREWORKS_API_KEY")
                if not key:
                    raise ValueError("FIREWORKS_API_KEY is not set. Fireworks dispatch requires it.")
                client = openai.OpenAI(api_key=key, base_url=FIREWORKS_BASE_URL)
            else:
                key = api_key or os.environ.get("OPENAI_API_KEY")
                if not key:
                    raise ValueError("OPENAI_API_KEY is not set. Direct OpenAI SDK dispatch requires a valid key.")
                client = openai.OpenAI(api_key=key)

        # Reasoning models (o1/o3) may not accept temperature
        kwargs: dict[str, Any] = {
            "model": resolved,
            "messages": [
                {"role": "system", "content": system},
                {"role": "user", "content": user},
            ],
            "max_tokens": max_tokens,
        }
        if not (resolved.startswith("o1") or resolved.startswith("o3")):
            kwargs["temperature"] = temperature

        response = client.chat.completions.create(**kwargs)
        if response and response.choices:
            return _finish(resolved, system, user, response.choices[0].message.content or "", response)
        return _finish(resolved, system, user, "", response)

    raise ValueError(f"Unsupported model provider for model '{model}'. Prefix must indicate claude or gpt.")


def _finish(model: str, system: str, user: str, text: str, response: Any) -> str:
    """Record tokens when a verse CostTracker is bound. A blown budget stays loud."""
    from cost_tracker import note_chat

    note_chat(model, system, user, text, response)
    return text
