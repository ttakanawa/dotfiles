#!/bin/bash
# Extract user messages from a session file.
# Usage: extract-user-messages.sh <SESSION_FILE>
# Output: {role, text, ts} JSON lines (exclude meta messages, truncate to 500 chars)

set -euo pipefail

SESSION_FILE="$1"

jq -c '
  select(.type == "user" and (.isMeta | not))
  | if (.message.content | type) == "string" then
      {role: "user", text: .message.content[:500], ts: .timestamp}
    else empty end
  | select(.text != "" and (.text | startswith("<") | not))
' "$SESSION_FILE"
