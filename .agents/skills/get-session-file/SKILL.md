---
name: get-session-file
description: Use in Claude Code when you need to get the file path of a Claude Code session by session ID
allowed-tools: Bash(~/.claude/skills/get-session-file/scripts/*)
model: haiku
effort: low
---

# get-session-file

Get the file path of a Claude Code session by session ID.

## Instructions

1. Run the helper script. Pass the session ID as an argument, or omit it to use the current session:

  ```bash
  ~/.claude/skills/get-session-file/scripts/get-session-file.sh ${SESSION_ID:-}
  ```

1. Parse the output and respond using the templates below. Do not add any extra text.

## Output Templates

### `FOUND|{path}`

  ```
  Session file: {path}
  ```

### `NOT_FOUND`

  ```
  Session file not found.
  ```
