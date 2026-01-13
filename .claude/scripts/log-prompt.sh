#!/bin/bash

# Read JSON input and extract fields
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd')
PROMPT=$(echo "$INPUT" | jq -r '.prompt')

# Prepare paths
TODAY=$(date "+%Y-%m-%d")
JOURNAL_FILE="$ZK_NOTEBOOK_DIR/journal/${TODAY}.md"
TEMPLATE="$HOME/.config/zk/templates/daily.md"

# Create journal file if it doesn't exist
if [[ ! -f "$JOURNAL_FILE" ]]; then
  mkdir -p "$ZK_NOTEBOOK_DIR/journal"
  # Process template (replace {{ format-date now "long" }} with actual date)
  LONG_DATE=$(date "+%B %-d, %Y")
  sed "s/{{ format-date now \"long\" }}/$LONG_DATE/" "$TEMPLATE" > "$JOURNAL_FILE"
fi

# Append prompt log entry
TIME=$(date "+%-l:%M %p")
DIR_NAME=$(basename "$CWD")
{
  echo "${TIME} [${DIR_NAME}] $PROMPT"
  echo ""
} >> "$JOURNAL_FILE"
