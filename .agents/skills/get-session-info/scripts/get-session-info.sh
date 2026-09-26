#!/bin/bash
# Look up Claude Code sessions from `claude agents --json --all`.
# Usage: get-session-info.sh [--session-id ID] [--cwd PATTERN] [--status STATUS]
#   --session-id and --cwd are substring matches, --status is an exact match.
#   Conditions are combined with AND. At least one condition is required.
set -euo pipefail

usage() {
  echo "Usage: get-session-info.sh [--session-id ID] [--cwd PATTERN] [--status STATUS]" >&2
}

SESSION_ID=""
CWD_PATTERN=""
STATUS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --session-id)
      [[ $# -ge 2 ]] || { echo "Error: --session-id requires a value." >&2; usage; exit 1; }
      SESSION_ID="$2"
      shift 2
      ;;
    --cwd)
      [[ $# -ge 2 ]] || { echo "Error: --cwd requires a value." >&2; usage; exit 1; }
      CWD_PATTERN="$2"
      shift 2
      ;;
    --status)
      [[ $# -ge 2 ]] || { echo "Error: --status requires a value." >&2; usage; exit 1; }
      STATUS="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$SESSION_ID" && -z "$CWD_PATTERN" && -z "$STATUS" ]]; then
  echo "Error: At least one of --session-id, --cwd, or --status is required." >&2
  usage
  exit 1
fi

claude agents --json --all | jq -r \
  --arg id "$SESSION_ID" \
  --arg cwd "$CWD_PATTERN" \
  --arg status "$STATUS" '
  map(select(
    ($id == "" or ((.sessionId // "") | contains($id))) and
    ($cwd == "" or ((.cwd // "") | contains($cwd))) and
    ($status == "" or .status == $status)
  ))
  | if length == 0 then
      "NOT_FOUND"
    else
      .[]
      | (if .startedAt then (.startedAt / 1000 | floor | strflocaltime("%Y-%m-%d %H:%M:%S")) else "" end) as $started
      | "SESSION|\(.sessionId)|\(.name // "")|\(.kind // "")|\(.status // "")|\(.pid // "")|\($started)|\(.cwd // "")"
    end'
