---
name: find-session-file
description: Find a Claude Code session file by session ID and project directory
allowed-tools: Bash(~/.claude/skills/find-session-file/scripts/*)
model: haiku
---

# find-session

Locate a Claude Code session file by session ID.

## Arguments

- `$ARGUMENTS` format: `<SESSION_ID> [CWD]`
- `SESSION_ID` (required): The session ID to search for
- `CWD` (optional): The project directory path. Defaults to the current working directory.

## Instructions

1. Run the helper script:

  ```bash
  ~/.claude/skills/find-session-file/scripts/find-session.sh $ARGUMENTS
  ```

  If only session ID is provided (no CWD), append `$(pwd)` as the second argument:

  ```bash
  ~/.claude/skills/find-session-file/scripts/find-session.sh <SESSION_ID> "$(pwd)"
  ```

1. Parse the output and respond using the templates below. Do not add any extra text.

## Output Templates

### `FOUND|{filePath}`

  ```
  Session file: {filePath}
  ```

### `NOT_FOUND|{reason}`

  ```
  Session not found. {reason}
  ```
