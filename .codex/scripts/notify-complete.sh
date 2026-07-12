#!/bin/bash
# Stop hook — fires when Codex finishes a response.

source "$HOME/.agents/scripts/notification/notify.sh"

hook_input=$(cat)
cwd=$(printf '%s' "$hook_input" | jq -r '.cwd // empty')
session_id=$(printf '%s' "$hook_input" | jq -r '.session_id // empty')
summary=$(printf '%s' "$hook_input" | jq -r '.last_assistant_message // empty')
[ -z "$summary" ] && summary="Task completed"

notify "🤖 finished" "$summary" "$cwd" "$session_id" "codex" "/System/Library/Sounds/Purr.aiff" || true
exit 0
