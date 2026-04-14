#!/bin/bash
# Notification hook — fires when Claude needs user attention
# (permission prompts, idle, auth success, elicitation).
source "$(dirname "$0")/lib/notify.sh"

hook_input=$(cat)

# Title resolution precedence (later wins):
#   1. default "🤖 waiting"
#   2. notification_type-specific emoji/label
#   3. explicit .title from the hook payload (if set)
#
# jq fields are fetched individually (not via @tsv) because .message and
# .title may contain control characters; @tsv would escape them to literal
# \n / \t sequences, which would then display verbatim in the notification.
title="🤖 waiting"
case "$(echo "$hook_input" | jq -r '.notification_type // empty')" in
  permission_prompt)  title="🔐 permission" ;;
  idle_prompt)        title="⏸️ idle" ;;
  auth_success)       title="✅ auth success" ;;
  elicitation_dialog) title="❓ question" ;;
esac
hook_title=$(echo "$hook_input" | jq -r '.title // empty')
[ -n "$hook_title" ] && title="$hook_title"

summary=$(echo "$hook_input" | jq -r '.message // empty')
[ -z "$summary" ] && summary="Waiting for input"

notify "$title" "$summary" "$hook_input"
afplay -v 0.7 /System/Library/Sounds/Pop.aiff &
