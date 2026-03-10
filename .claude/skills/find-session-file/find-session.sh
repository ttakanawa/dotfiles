#!/bin/bash
# Find a Claude Code session file by session ID and project directory.
# Usage: find-session.sh <SESSION_ID> [CWD]
# Output: FOUND|<file_path> or NOT_FOUND

set -euo pipefail

SESSION_ID="${1:?Usage: find-session.sh <SESSION_ID> [CWD]}"
CWD="${2:-.}"

PROJECT_DIR="$HOME/.claude/projects/$(echo "$CWD" | sed 's|[^a-zA-Z0-9]|-|g')"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "NOT_FOUND|Project directory does not exist: $PROJECT_DIR"
  exit 0
fi

SESSION_FILE="$PROJECT_DIR/${SESSION_ID}.jsonl"

if [[ -f "$SESSION_FILE" ]]; then
  echo "FOUND|$SESSION_FILE"
else
  echo "NOT_FOUND|No session file for ID $SESSION_ID in $PROJECT_DIR"
fi
