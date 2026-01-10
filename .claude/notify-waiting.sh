#!/bin/bash
TIME=$(date "+%-l:%M %p")

BODY=$(
  HOOK_INPUT=$(cat)
  TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')
  LAST_MSG=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
  DIR_NAME=$(echo "$LAST_MSG" | jq -r '.cwd' | xargs basename)
  TEXT=$(echo "$LAST_MSG" | jq -r '.message.content[] | select(.type=="text") | .text' | head -1)
  SUMMARY=$(echo "$TEXT" | tr '\n' ' ' | awk '{for(i=1;i<=7&&i<=NF;i++) printf "%s ", $i}' | sed 's/ *$//')
  echo "[${DIR_NAME}] 🤖 ${SUMMARY}"
) 2>/dev/null || BODY=""

# WezTerm Notification
printf "\033]777;notify;%s;%s\033\\" "Claude Code Waiting - ${TIME}" "$BODY" > /dev/tty
