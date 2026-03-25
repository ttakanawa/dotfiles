#!/bin/bash
# Check whether the current Claude Code session is a fork.
# Usage: check-fork.sh
# Requires CC_PROJECT_DIR environment variable (set by chpwd hook in environment.zsh)
set -euo pipefail

if [[ ! -d "$CC_PROJECT_DIR" ]]; then
  echo "NO_SESSION"
  exit 0
fi

SESSION_FILE=$(ls -t "$CC_PROJECT_DIR"/*.jsonl 2>/dev/null | head -1 || true)
if [[ -z "$SESSION_FILE" ]]; then
  echo "NO_SESSION"
  exit 0
fi

SESSION_ID="$(basename "$SESSION_FILE" .jsonl)"

FORKED_FROM=$(head -1 "$SESSION_FILE" | jq -r '.forkedFrom.sessionId // empty')

if [[ -n "$FORKED_FROM" ]]; then
  echo "FORKED|$SESSION_ID|$FORKED_FROM"
else
  echo "NOT_FORKED|$SESSION_ID"
fi
