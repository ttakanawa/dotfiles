---
name: amiforked
description: Check if the current Claude Code session was forked from another session
allowed-tools: Bash(~/.claude/skills/amiforked/*)
model: haiku
---

# amiforked

Check whether the current session is a fork and display the original session ID.

## Instructions

1. Run the helper script:

  ```bash
  ~/.claude/skills/amiforked/check-fork.sh "$(pwd)"
  ```

1. Parse the output and respond using the templates below. Do not add any extra text.

## Output Templates

### `FORKED|{sessionId}|{forkedFromSessionId}`

  ```
  Yes, this session is forked.

  - Current session: {sessionId}
  - Forked from: {forkedFromSessionId}
  ```

### `NOT_FORKED|{sessionId}`

  ```
  No, this session is not forked.

  - Current session: {sessionId}
  ```

### `NO_SESSION`

  ```
  No, could not determine the session. No session file found.
  ```
