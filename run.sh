#!/usr/bin/env bash
# NOTE: This file must use LF line endings (not CRLF) for bash.
set -euo pipefail

cd "$(dirname "$0")"

echo "Seeding local JSON data..."
uv run --locked python seed_data.py

echo "Running MCP client demo..."
uv run --locked python client.py
