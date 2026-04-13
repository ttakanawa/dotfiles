#!/bin/bash
# Stop hook — fires when Claude finishes a response.
source "$(dirname "$0")/lib/notify.sh"

hook_input=$(cat)

summary=$(echo "$hook_input" | jq -r '.last_assistant_message // empty')
[ -z "$summary" ] && summary="Task completed"

notify "🤖 finished" "$summary" "$hook_input"
