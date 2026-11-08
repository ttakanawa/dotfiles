#!/bin/bash
# Notify when the main Codex response finishes.
source "$(dirname "$0")/lib/notify.sh"

notify_codex finished "🤖 finished" Purr '
  select(.hook_event_name == "Stop") |
  .last_assistant_message // "Task completed" |
  if . == "" then "Task completed" else . end
'
