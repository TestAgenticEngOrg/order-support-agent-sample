"""Strands agent construction and the orders MCP connection."""

from __future__ import annotations

from mcp.client.streamable_http import streamablehttp_client
from strands import Agent
from strands.models.openai import OpenAIModel
from strands.tools.mcp import MCPClient

from config import Config

ORDER_TOOLS = ["getOrder", "listCustomerOrders", "trackShipment"]

SYSTEM_PROMPT = """You are the order support assistant for {company}.
You help customers with questions about their orders and deliveries.

- Use the order tools for every fact about an order or shipment. Never guess.
- To look anything up you need an order number or the customer's email. Ask for one if it is missing.
- You can only read order data. You cannot cancel, change, return or refund orders.
  For those requests, say a human agent will follow up.
- If a tool returns an error, explain it plainly and suggest what the customer can do next.
- Keep answers short and friendly. Give dates as written in the tool results.
"""


def create_mcp_client(cfg: Config) -> MCPClient:
    headers = {}
    if cfg.orders_mcp_api_key:
        headers["X-API-Key"] = cfg.orders_mcp_api_key
    return MCPClient(
        lambda: streamablehttp_client(cfg.orders_mcp_url, headers=headers),
        tool_filters={"allowed": ORDER_TOOLS},
    )


def build_model(cfg: Config) -> OpenAIModel:
    if cfg.use_llm_provider:
        # The Agent Manager LLM gateway expects its key in "API-Key", not a bearer token.
        client_args = {
            "base_url": cfg.llm_provider_url,
            "api_key": "not-used",
            "default_headers": {"API-Key": cfg.llm_provider_key, "Authorization": ""},
        }
    else:
        client_args = {"api_key": cfg.openai_api_key}
    return OpenAIModel(
        client_args=client_args, model_id=cfg.model, params={"temperature": 0}
    )


def build_agent(cfg: Config, tools: list) -> Agent:
    return Agent(
        model=build_model(cfg),
        tools=tools,
        system_prompt=SYSTEM_PROMPT.format(company=cfg.company_name),
        callback_handler=None,
    )
