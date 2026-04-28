---
name: amiforked
description: Use in Claude Code when you need to check whether the current session was forked
allowed-tools: Bash(~/.claude/skills/amiforked/scripts/*)
model: haiku
effort: low
---

# amiforked

Check whether the current session is a fork and display the original session ID.

## Instructions

1. Run the helper script:

  ```bash
  ~/.claude/skills/amiforked/scripts/check-fork.sh ${CLAUDE_SESSION_ID}
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
