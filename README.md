# MCP Order Assistant (Part 5 Companion)

Verified with MCP revision 2026-07-28 and the Python SDK mcp 2.3.0.

Need the earlier 2025-11-25 version of this lab? Check out the tag `mcp-baseline-pre-2026-07-28`.

A minimal, fully local MCP (Model Context Protocol) demo: one stdio server + one stdio client that connects, lists capabilities, and invokes tools against a seeded JSON "orders" file.

## Prerequisites

- Python **3.11+** (default local version is 3.12 via `.python-version`)
- [uv](https://docs.astral.sh/uv/) for the recommended workflow
- A bash shell to run `run.sh` (macOS/Linux Terminal, or Git Bash / WSL on Windows)

`uv.lock` provides the reproducible environment for this lab.

Note: on Windows, `mcp` may pull in `pywin32` automatically as a transitive dependency.

## Run (recommended: uv)

From the `part5-order-assistant/` folder:

```bash
uv sync --locked
uv run --locked python client.py
```

Or one command via the helper script (seeds data, then runs the client):

```bash
bash run.sh
```

`run.sh` uses `uv run --locked` and does not create a separate pip-managed `.venv`.

This will:

- Use the locked environment from `uv.lock`
- Seed local JSON data to `./data/orders.json` (via `run.sh`)
- Run the MCP client, which launches the MCP server as a subprocess over stdio

Note: `cancel_order` intentionally modifies `data/orders.json`. Re-run `bash run.sh` (or re-seed with `uv run --locked python seed_data.py`) to reset state.

### Pip fallback (without uv)

`requirements.txt` is generated from `uv.lock`. Do not edit it by hand. If you change dependencies, edit `pyproject.toml`, run `uv lock`, then regenerate with `uv export`.

```bash
python -m venv .venv
# macOS/Linux: source .venv/bin/activate
# Windows: .venv\Scripts\activate
python -m pip install -r requirements.txt
python seed_data.py
python client.py
```

## What you'll see

Terminal output from a successful run looks like this:

```text
=== MCP Order Assistant - Part 5 Demo ===

[STEP 1] Connecting and discovering the server...
Connecting to order-assistant MCP server...
Protocol version: 2026-07-28
Server: order-assistant
Capabilities: tools, resources, prompts

[STEP 2] Listing tools, resources and prompts...
Tools:

- get_order_status (Order Status Lookup)
- get_order_items (Order Line Items)
- cancel_order (Cancel Order)

Resources:
- recent-orders://summary
- order://{id}

Prompts:
- summarize_order
- customer_friendly_response

[STEP 3] Invoking tools...

get_order_status(ORD-10042): {
  "carrier": "FedEx",
  "delivery_estimate": "2026-03-28",
  "order_id": "ORD-10042",
  "status": "shipped"
}

get_order_items(ORD-10042): {
  "items": [
    {
      "name": "Wireless Headphones",
      "price": 79.99,
      "quantity": 1
    },
    {
      "name": "Phone Case",
      "price": 12.99,
      "quantity": 2
    }
  ],
  "order_id": "ORD-10042"
}

cancel_order(ORD-10099): {
  "cancelled": true,
  "message": "Order cancelled successfully.",
  "order_id": "ORD-10099"
}

Interaction complete. Discover, list, call demonstrated.
```

## Configuration

The server reads `DATA_PATH` from environment, defaulting to `./data/orders.json`.

An example env file is included:

- Copy `.env.example` to `.env` if you want to customize the data path.

## Using MCP Inspector (optional)

This server also works with the MCP Inspector for interactive exploration.

Inspector requires Node.js. If `npx` is not found, install Node.js from [nodejs.org](https://nodejs.org) first, then restart your terminal.

```bash
npx @modelcontextprotocol/inspector@2.12.0 --protocol-era modern uv run --locked python server.py
```

Inspector opens in your browser; if the server shows Disconnected, turn on its switch. Connection Info should show protocol 2026-07-28 and era MODERN. Without `--protocol-era modern`, Inspector 2.12 uses the older 2025-11-25 handshake.

## Connecting to Claude Desktop

This server has been validated with Claude Desktop. Add the following to your Claude Desktop config file.

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`

**Windows:** Open Claude Desktop -> Settings -> Developer -> Edit Config

```json
{
  "mcpServers": {
    "order-assistant": {
      "command": "uv",
      "args": [
        "--directory",
        "C:\\absolute\\path\\to\\part5-order-assistant",
        "run",
        "--locked",
        "python",
        "server.py"
      ]
    }
  }
}
```

If Claude Desktop does not inherit your shell `PATH`, set `command` to the absolute path of the `uv` executable (for example `C:\\Users\\you\\.local\\bin\\uv.exe` on Windows).

Three things that prevent most connection failures:

- **Use an absolute `--directory` path** to the lab folder.
- **Restart Claude Desktop** after every config change. There is no hot reload.
- Keep `uv.lock` present so `uv run --locked` can resolve the same environment.

After restart, ask Claude: *"What is the status of order ORD-10042?"*

## Derived fields in prompts

The `summarize_order` prompt asks for fields like `item_count` and `total_amount`. These aren't stored directly in the JSON; they're meant to be derived from the order's `items`.

## Companion Article

This repository accompanies
[Part 5: Build Your First MCP Server (and Client)](https://aiinpracticehub.com/articles/build-your-first-mcp-server-and-client/)
in the
[MCP in Practice series](https://aiinpracticehub.com/series/mcp/)
on [AI in Practice Hub](https://aiinpracticehub.com/).
