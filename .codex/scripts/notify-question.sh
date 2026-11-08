#!/bin/bash
# Notify for both normal and asynchronous Codex questions.
source "$(dirname "$0")/lib/notify.sh"

notify_codex question "❓ question" Pop '
  select(.hook_event_name == "PreToolUse") |
  ({request_user_input: "question", request_user_input_async: "title"}[.tool_name]) as $field |
  select($field != null) |
  (.tool_input.questions // []) | select(type == "array") |
  map(select(type == "object") | .[$field] | select(type == "string" and length > 0)) |
  join(" / ") | select(length > 0)
'
