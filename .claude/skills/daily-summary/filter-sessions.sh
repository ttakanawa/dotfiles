#!/bin/bash
# Filter sessions from history.jsonl for a given date.
# Usage: filter-sessions.sh <YYYY-MM-DD>
# Output: [{project: "...", sessions: ["uuid1", ...]}, ...]

set -euo pipefail

DATE="$1"
START_MS=$(( $(date -j -f "%Y-%m-%d" "$DATE" "+%s") * 1000 ))
END_MS=$(( $(date -j -v+1d -f "%Y-%m-%d" "$DATE" "+%s") * 1000 ))

jq -c "select(.timestamp >= ${START_MS} and .timestamp < ${END_MS}) | {project, sessionId}" \
  ~/.claude/history.jsonl \
  | sort -u \
  | jq -sc 'group_by(.project) | map({project: .[0].project, sessions: [.[].sessionId] | unique})'
