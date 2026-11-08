#!/bin/bash
# Notify when Codex requests approval, before automatic review.
source "$(dirname "$0")/lib/notify.sh"

notify_codex permission "🔐 permission" Pop '
  select(.hook_event_name == "PermissionRequest") |
  (.tool_input // {}) |
  [.description, .justification, .command, .cmd] |
  map(select(type == "string" and length > 0)) |
  .[0] // "Approval requested"
'
