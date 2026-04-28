#!/bin/bash
# Check whether the current Claude Code session is a fork.
# Usage: check-fork.sh SESSION_ID
set -euo pipefail

if [[ $# -lt 1 || -z "$1" ]]; then
  echo "Usage: check-fork.sh SESSION_ID" >&2
  echo "Error: SESSION_ID is required. Pass the current session ID as an argument." >&2
  exit 1
fi

SESSION_ID="$1"
PROJECT_DIR="$HOME/.claude/projects/$(echo "$PWD" | sed 's|[^a-zA-Z0-9]|-|g')"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "NO_SESSION"
  exit 0
fi

SESSION_FILE="$PROJECT_DIR/${SESSION_ID}.jsonl"
if [[ ! -f "$SESSION_FILE" ]]; then
  echo "NO_SESSION"
  exit 0
fi

FORKED_FROM=$(head -1 "$SESSION_FILE" | jq -r '.forkedFrom.sessionId // empty')

if [[ -n "$FORKED_FROM" ]]; then
  echo "FORKED|$SESSION_ID|$FORKED_FROM"
else
  echo "NOT_FORKED|$SESSION_ID"
fi
