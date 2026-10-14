#!/bin/bash
# Get the file path of a Claude Code session by session ID.
# Usage: get-session-file.sh [SESSION_ID]
#   If SESSION_ID is omitted, $CLAUDE_SESSION_ID is used.
set -euo pipefail

SESSION_ID="${1:-${CLAUDE_SESSION_ID:-${CLAUDE_CODE_SESSION_ID:-}}}"

if [[ -z "$SESSION_ID" ]]; then
  echo "Usage: get-session-file.sh [SESSION_ID]" >&2
  echo "Error: SESSION_ID is required. Pass it as an argument or set CLAUDE_SESSION_ID." >&2
  exit 1
fi

PROJECT_DIR="$HOME/.claude/projects/$(echo "$PWD" | sed 's|[^a-zA-Z0-9]|-|g')"
SESSION_FILE="$PROJECT_DIR/${SESSION_ID}.jsonl"

if [[ -f "$SESSION_FILE" ]]; then
  echo "FOUND|$SESSION_FILE"
else
  echo "NOT_FOUND"
fi
