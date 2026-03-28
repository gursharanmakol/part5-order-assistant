# MCP Order Assistant (Part 5 Companion)

A minimal, fully local MCP (Model Context Protocol) demo: one stdio server + one stdio client that initializes, discovers capabilities, and invokes tools against a seeded JSON "orders" file.

## Prerequisites

- Python **3.10+**
- A bash shell to run `run.sh` (macOS/Linux Terminal, or Git Bash / WSL on Windows)

Note: on Windows, `mcp` may pull in `pywin32` automatically as a transitive dependency.

## Run (one command)

From the `part5-order-assistant/` folder:

```bash
bash run.sh
```

This will:

- Create a repo-local virtual environment in `.venv/` (if missing)
- Install pinned dependencies
- Seed local JSON data to `./data/orders.json`
- Run the MCP client, which launches the MCP server as a subprocess over stdio

Note: `cancel_order` intentionally modifies `data/orders.json`. Re-run `bash run.sh` any time to reset state automatically (it re-seeds the JSON on every run).

## What you'll see

Terminal output that follows an **initialize → list → call** pattern:

- Step 1: initialize session (prints negotiated protocol version, server info, capability summary)
- Step 2: list tools/resources/prompts
- Step 3: call three tools and print full JSON results

## Configuration

The server reads `DATA_PATH` from environment, defaulting to `./data/orders.json`.

An example env file is included:

- Copy `.env.example` to `.env` if you want to customize the data path.

## Using MCP Inspector (optional)

This server also works with the MCP Inspector for interactive exploration.

Inspector requires Node.js. If `npx` is not found, install Node.js from [nodejs.org](https://nodejs.org) first, then restart your terminal.

```bash
npx @modelcontextprotocol/inspector python server.py
```

## Connecting to Claude Desktop

This server has been validated with Claude Desktop. Add the following to your Claude Desktop config file.

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`

**Windows:** Open Claude Desktop → Settings → Developer → Edit Config

```json
{
  "mcpServers": {
    "order-assistant": {
      "command": "/absolute/path/to/.venv/bin/python",
      "args": ["/absolute/path/to/server.py"],
      "env": {
        "DATA_PATH": "/absolute/path/to/data/orders.json"
      }
    }
  }
}
```

**Windows paths** use escaped backslashes and should point to the venv Python directly:

```json
{
  "mcpServers": {
    "order-assistant": {
      "command": "C:\\absolute\\path\\to\\.venv\\Scripts\\python.exe",
      "args": ["C:\\absolute\\path\\to\\server.py"],
      "env": {
        "DATA_PATH": "C:\\absolute\\path\\to\\data\\orders.json"
      }
    }
  }
}
```

Three things that prevent most connection failures:

- **Use absolute paths.** Claude Desktop launches the server from an unpredictable working directory — relative paths silently fail.
- **Point `command` to the venv Python**, not just `python`. This ensures Claude Desktop uses the environment where `mcp` is installed.
- **Restart Claude Desktop** after every config change. There is no hot reload.

After restart, ask Claude: *"What is the status of order ORD-10042?"*

## Derived fields in prompts

The `summarize_order` prompt asks for fields like `item_count` and `total_amount`. These aren't stored directly in the JSON; they're meant to be derived from the order's `items`.

## Article

Placeholder link to Part 5 article: `<LINK-TBD>`
