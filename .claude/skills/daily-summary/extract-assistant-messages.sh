#!/bin/bash
# Extract assistant text responses from a session file.
# Usage: extract-assistant-messages.sh <SESSION_FILE>
# Output: {role, text, ts} JSON lines (exclude thinking/tool_use, truncate to 300 chars)

set -euo pipefail

SESSION_FILE="$1"

jq -c '
  select(.type == "assistant")
  | {role: "assistant", text: [.message.content[] | select(.type == "text") | .text[:300]] | join(" "), ts: .timestamp}
  | select(.text != "")
' "$SESSION_FILE"
