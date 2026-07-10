#!/bin/bash
# Stop hook — fires when Claude finishes a response.
source "$(dirname "$0")/lib/notify.sh"

hook_input=$(cat)

# Minimal hook profile (automated sessions such as the continuous-learning-v2
# observer): show a fixed message without sound.
if [ "${ECC_HOOK_PROFILE:-standard}" = "minimal" ]; then
  notify "🤖 finished" "Background session" "$hook_input"
  exit 0
fi

summary=$(echo "$hook_input" | jq -r '.last_assistant_message // empty')
[ -z "$summary" ] && summary="Task completed"

notify "🤖 finished" "$summary" "$hook_input"
afplay -v 0.7 /System/Library/Sounds/Purr.aiff &
