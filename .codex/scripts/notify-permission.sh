#!/bin/bash
# PermissionRequest hook — fires when Codex is about to ask for approval.

source "$HOME/.agents/scripts/notification/notify.sh"

hook_input=$(cat)
cwd=$(printf '%s' "$hook_input" | jq -r '.cwd // empty')
session_id=$(printf '%s' "$hook_input" | jq -r '.session_id // empty')
summary=$(printf '%s' "$hook_input" | jq -r '.tool_input.description // empty')
[ -z "$summary" ] && summary=$(printf '%s' "$hook_input" | jq -r '.tool_name // empty')
[ -z "$summary" ] && summary="Waiting for approval"

notify "🔐 permission" "$summary" "$cwd" "$session_id" "codex" "/System/Library/Sounds/Pop.aiff" || true
exit 0
