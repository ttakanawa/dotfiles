#!/bin/bash
set -euo pipefail

CWD="${1:-.}"
PROJECT_DIR="$HOME/.claude/projects/$(echo "$CWD" | sed 's|[^a-zA-Z0-9]|-|g')"
SESSION_FILE=$(ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null | head -1)

if [[ -z "$SESSION_FILE" ]]; then
  echo "NO_SESSION"
  exit 0
fi

SESSION_ID=$(basename "$SESSION_FILE" .jsonl)
FORKED_FROM=$(head -1 "$SESSION_FILE" | jq -r '.forkedFrom.sessionId // empty')

if [[ -n "$FORKED_FROM" ]]; then
  echo "FORKED|$SESSION_ID|$FORKED_FROM"
else
  echo "NOT_FORKED|$SESSION_ID"
fi
