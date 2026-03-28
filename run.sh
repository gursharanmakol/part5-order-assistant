#!/usr/bin/env bash
# NOTE: This file must use LF line endings (not CRLF) for bash.
set -euo pipefail

cd "$(dirname "$0")"

PY=""
if command -v python3 >/dev/null 2>&1 && python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)' 2>/dev/null; then
  PY="python3"
elif command -v py >/dev/null 2>&1 && py -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)' 2>/dev/null; then
  PY="py"
elif command -v python >/dev/null 2>&1 && python -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)' 2>/dev/null; then
  PY="python"
else
  echo "Error: Python 3.10+ is required (python3, py, or python not found)." >&2
  exit 1
fi

# Validate version before creating a venv (avoid confusing failures on old Pythons).
if ! "$PY" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)'; then
  echo "Error: Python 3.10+ is required. Found: $("$PY" -V 2>&1)" >&2
  exit 1
fi

# Create a repo-local virtual environment if missing.
if [ ! -d ".venv" ]; then
  echo "Creating local virtual environment (.venv)..."
  "$PY" -m venv .venv
fi

# Pick the venv python path (works on macOS/Linux and Windows Git Bash).
if [ -x ".venv/bin/python" ]; then
  VENV_PY=".venv/bin/python"
else
  VENV_PY=".venv/Scripts/python.exe"
fi

echo "Installing dependencies into .venv..."
"$VENV_PY" -m pip install --upgrade pip >/dev/null
"$VENV_PY" -m pip install -r requirements.txt >/dev/null

echo "Seeding local JSON data..."
"$VENV_PY" seed_data.py

echo "Running MCP client demo..."
"$VENV_PY" client.py
