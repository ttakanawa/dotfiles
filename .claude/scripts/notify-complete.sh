#!/bin/bash
TIME=$(date "+%-l:%M %p")

BODY=$(
  HOOK_INPUT=$(cat)
  TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')
  LAST_DATA=$(cat "$TRANSCRIPT_PATH" | jq -c 'select(.message.role == "assistant") | {cwd, text: .message.content[].text? // empty}' | tail -n 1)
  DIR_NAME=$(echo "$LAST_DATA" | jq -r '.cwd' | xargs basename)
  TEXT=$(echo "$LAST_DATA" | jq -r '.text // empty')
  SUMMARY=$(echo "$TEXT" | tr '\n' ' ' | awk '{for(i=1;i<=7&&i<=NF;i++) printf "%s ", $i}' | sed 's/ *$//')
  echo "[${DIR_NAME}] 🤖 ${SUMMARY}"
) 2>/dev/null || BODY=""

# WezTerm Notification
TITLE="Claude Code Finished - ${TIME}"
if [ -n "$TMUX" ]; then
  printf '\033]777;notify;%s;%s\033\\' "$TITLE" "$BODY" > "$(tmux display-message -p '#{client_tty}')"
else
  printf '\033]777;notify;%s;%s\033\\' "$TITLE" "$BODY" > /dev/tty
fi
