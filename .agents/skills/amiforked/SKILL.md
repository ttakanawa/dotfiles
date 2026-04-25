---
name: amiforked
description: Check if the current Claude Code session was forked from another session
allowed-tools: Bash(~/.claude/skills/amiforked/scripts/*)
model: haiku
---

# amiforked

Check whether the current session is a fork and display the original session ID.

## Instructions

1. Run the helper script:

  ```bash
  ~/.claude/skills/amiforked/scripts/check-fork.sh
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

## Limitations

- The script identifies the current session by picking the most recently
  modified `.jsonl` file in the project directory (computed from `$PWD`).
  When multiple sessions are running concurrently in the same project, it
  may pick a different session's file and return inaccurate results.
