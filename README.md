# Order Support Agent

A customer support agent that answers questions like "Where is my order 1042?". The agent
reads order data through MCP tools exposed by an orders MCP server.

```
user ──POST /chat──▶ Order Support Agent (agent/) ──MCP──▶ Orders MCP Server (orders-mcp/)
                       Agent Manager, Python              Integrator, Ballerina
                              │                                 └─ mock orders and shipments, in memory
                              ▼
                       LLM provider (Agent Manager gateway)
```

| Component | Product | Path | Language |
|---|---|---|---|
| Orders MCP Server | Integrator, `MCP Server` component | `orders-mcp/` | Ballerina 2201.13.1 |
| Order Support Agent | Agent Manager, platform-hosted chat agent | `agent/` | Python 3.11 |
| LLM provider | Agent Manager | n/a | n/a |

## Deploy order

1. Create the LLM provider (or reuse an existing one).
2. Deploy the orders MCP server, then copy its endpoint URL.
3. Create the agent, bind the LLM provider, set `ORDERS_MCP_URL`, and deploy.
4. Open **Try It** and ask a sample question.

### 1. LLM provider

Create an OpenAI provider in Agent Manager. The agent uses `gpt-4o-mini` by default; set
`MODEL` to change it.

### 2. Orders MCP server (Integrator)

| Field | Value |
|---|---|
| Component type | MCP Server |
| Repository | this repository, branch `main` |
| Path | `orders-mcp` |
| Build | Ballerina buildpack |
| Port | `9090` (from `orders-mcp/workload.yaml`) |
| MCP path | `/mcp` |

No configuration or secrets are needed. The MCP endpoint is `<component URL>/mcp`.

Tools, all read-only:

| Tool | Input | Returns |
|---|---|---|
| `getOrder` | `orderId` | status, items, total, shipping address |
| `listCustomerOrders` | `customerEmail` | order summaries, newest first |
| `trackShipment` | `orderId` | carrier, tracking number, status, delivery date, events |

The endpoint has no authentication. That is acceptable only because every tool is
read-only and the data is fictional. Do not add write tools or real data without adding
auth.

### 3. Order Support Agent (Agent Manager)

| Field | Value |
|---|---|
| Agent type | Platform-Hosted Agent |
| Display name | `Order Support Agent` |
| Repository | this repository, branch `main` |
| App path | `agent` |
| Language | Python `3.11` |
| Start command | `python -m uvicorn app:app --host 0.0.0.0 --port 8000` |
| Port | `8000` |
| Agent interface | Chat Agent |
| Auto instrumentation | On |

Bind the LLM provider from step 1 with these environment variable names:

| Provider value | Env var name |
|---|---|
| URL | `LLM_PROVIDER_URL` |
| API key | `LLM_PROVIDER_KEY` |

Add this environment variable:

```env
ORDERS_MCP_URL=<orders MCP server URL>/mcp
```

The agent connects to the MCP server on the first chat, so either can start first. If the
MCP server is unreachable, `/chat` returns `503 orders system unavailable`.

### 4. Try it

```text
Where is order 1042?
What did I order? My email is alex.doe@example.com
Why is order 1047 late?
Has order 1045 shipped?
Can you cancel order 1042?
```

The last question checks that the agent declines actions it cannot take.

## Sample data

| Order | Customer | Status | Shipment |
|---|---|---|---|
| 1029 | sam.lee@example.com | CANCELLED | none |
| 1031 | priya.raman@example.com | DELIVERED | delivered 2026-10-12 |
| 1038 | alex.doe@example.com | DELIVERED | delivered 2026-10-18 |
| 1042 | alex.doe@example.com | SHIPPED | in transit, due 2026-11-04 |
| 1045 | priya.raman@example.com | PROCESSING | not shipped |
| 1047 | sam.lee@example.com | SHIPPED | delayed, due 2026-11-06 |
| 1050 | maria.garcia@example.com | DELIVERED | delivered 2026-10-30 |

## Agent configuration

| Variable | Required | Default | Purpose |
|---|---|---|---|
| `ORDERS_MCP_URL` | Yes | | Orders MCP endpoint, ending in `/mcp` |
| `LLM_PROVIDER_URL` / `LLM_PROVIDER_KEY` | Yes, when `USE_LLM_PROVIDER=true` | | Injected by Agent Manager when the provider is bound |
| `USE_LLM_PROVIDER` | No | `true` | Set `false` for a local run against OpenAI directly |
| `OPENAI_API_KEY` | When `USE_LLM_PROVIDER=false` | | Local runs only |
| `ORDERS_MCP_API_KEY` | No | | Sent as `X-API-Key`, for when the MCP server sits behind an Agent Manager MCP proxy |
| `MODEL` | No | `gpt-4o-mini` | Chat model |
| `COMPANY_NAME` | No | `Acme Retail` | Name used in the system prompt |

Conversation memory is per `session_id`, held in process, and lost on restart.

## Run locally

```bash
cd orders-mcp && bal run
```

```bash
cd agent
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export ORDERS_MCP_URL=http://localhost:9090/mcp USE_LLM_PROVIDER=false OPENAI_API_KEY=<your-key>
python -m uvicorn app:app --port 8000
```

```bash
curl -X POST http://localhost:8000/chat -H "Content-Type: application/json" \
  -d '{"message": "Where is order 1042?", "session_id": "demo"}'
```
