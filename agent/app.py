import os

# Set before importing Strands: without it, tool input/output never reach span attributes.
os.environ.setdefault("OTEL_SEMCONV_STABILITY_OPT_IN", "gen_ai_latest_experimental")

import logging
import threading
import uuid
from collections import OrderedDict
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from strands import Agent

load_dotenv()

from config import Config
from support_agent import ORDER_TOOLS, build_agent, create_mcp_client

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("order-support-agent")

CONFIG = Config.from_env()

# Demo-grade memory: keyed on the caller-supplied session_id and lost on restart.
MAX_SESSIONS = 500
SESSIONS: "OrderedDict[str, Agent]" = OrderedDict()
_lock = threading.Lock()

_mcp_client = None
_tools: list | None = None


def _order_tools() -> list:
    """Connect to the orders MCP server on first use, so the agent can start before it."""
    global _mcp_client, _tools
    if _tools is None:
        client = create_mcp_client(CONFIG)
        client.start()
        try:
            tools = client.list_tools_sync()
            names = {t.tool_name for t in tools}
            if names != set(ORDER_TOOLS):
                raise RuntimeError(f"Orders MCP server exposed {sorted(names)}")
        except Exception:
            client.stop(None, None, None)
            raise
        _mcp_client, _tools = client, tools
        log.info("connected to orders MCP server, tools: %s", sorted(names))
    return _tools


@asynccontextmanager
async def lifespan(app):
    yield
    if _mcp_client is not None:
        _mcp_client.stop(None, None, None)


app = FastAPI(title="Order Support Agent", version="0.1.0", lifespan=lifespan)


class ChatRequest(BaseModel):
    message: str = Field(max_length=4000)
    session_id: str | None = Field(default=None, max_length=128)


class ChatResponse(BaseModel):
    response: str
    session_id: str


def _agent_for(session_id: str) -> Agent:
    # The sync endpoint runs on a threadpool, so lookup, insert and eviction share one lock.
    with _lock:
        agent = SESSIONS.get(session_id)
        if agent is None:
            agent = build_agent(CONFIG, _order_tools())
            SESSIONS[session_id] = agent
            while len(SESSIONS) > MAX_SESSIONS:
                SESSIONS.popitem(last=False)
        else:
            SESSIONS.move_to_end(session_id)
        return agent


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest) -> ChatResponse:
    if not req.message.strip():
        raise HTTPException(status_code=400, detail="message must not be empty")

    session_id = req.session_id or str(uuid.uuid4())

    try:
        agent = _agent_for(session_id)
    except Exception as exc:
        log.exception("orders MCP server unavailable")
        raise HTTPException(status_code=503, detail="orders system unavailable") from exc

    try:
        result = agent(req.message)
    except Exception as exc:
        # Upstream errors can carry gateway URLs and provider payloads, so log, do not return.
        log.exception("agent invocation failed", extra={"session_id": session_id})
        raise HTTPException(status_code=500, detail="agent invocation failed") from exc

    return ChatResponse(response=str(result), session_id=session_id)
