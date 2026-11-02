"""Agent configuration, read from env at startup."""

from __future__ import annotations

import os
from dataclasses import dataclass
from urllib.parse import urlparse


def _env(name: str, default: str | None = None) -> str:
    val = os.environ.get(name) or default
    if val is None:
        raise RuntimeError(f"Missing required env var: {name}")
    return val


def _validate_url(name: str, url: str) -> str:
    parsed = urlparse(url)
    if (
        parsed.scheme not in {"http", "https"}
        or not parsed.hostname
        or parsed.username
        or parsed.password
        or parsed.query
        or parsed.fragment
    ):
        raise RuntimeError(
            f"{name} must be an HTTP(S) URL without credentials, query, or fragment"
        )
    return url


@dataclass(frozen=True)
class Config:
    orders_mcp_url: str
    orders_mcp_api_key: str
    use_llm_provider: bool
    llm_provider_url: str
    llm_provider_key: str
    openai_api_key: str
    model: str
    company_name: str

    @classmethod
    def from_env(cls) -> "Config":
        use_llm_provider = _env("USE_LLM_PROVIDER", "true").lower()
        if use_llm_provider not in {"true", "false"}:
            raise RuntimeError("USE_LLM_PROVIDER must be true or false")
        use_provider = use_llm_provider == "true"
        return cls(
            orders_mcp_url=_validate_url("ORDERS_MCP_URL", _env("ORDERS_MCP_URL")),
            # Only needed when the MCP server sits behind an Agent Manager MCP proxy.
            orders_mcp_api_key=_env("ORDERS_MCP_API_KEY", ""),
            use_llm_provider=use_provider,
            # Injected by Agent Manager when an LLM provider is bound to the agent.
            llm_provider_url=_validate_url("LLM_PROVIDER_URL", _env("LLM_PROVIDER_URL"))
            if use_provider
            else "",
            llm_provider_key=_env("LLM_PROVIDER_KEY") if use_provider else "",
            # Local runs without Agent Manager only.
            openai_api_key=_env("OPENAI_API_KEY") if not use_provider else "",
            model=_env("MODEL", "gpt-4o-mini"),
            company_name=_env("COMPANY_NAME", "Acme Retail"),
        )
