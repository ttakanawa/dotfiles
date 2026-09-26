---
name: get-session-info
description: Use in Claude Code when you need to look up Claude Code session info (name, status, kind, PID, start time, cwd) by session ID, cwd, or status. Also use when the user asks to send instructions to another session (e.g. "send instructions to this session"), to identify the target session first.
allowed-tools: Bash(~/.claude/skills/get-session-info/scripts/*)
---

# get-session-info

Look up Claude Code sessions from `claude agents --json --all`, filtered by session ID, cwd, or status.

## Instructions

1. Extract the filter conditions from the user's request. At least one is required:

    | Condition | Argument | Match |
    | --------- | -------- | ----- |
    | Session ID | `--session-id ID` | Substring |
    | cwd | `--cwd PATTERN` | Substring |
    | Status (e.g. `busy`, `idle`) | `--status STATUS` | Exact |

1. Run the helper script. Multiple conditions are combined with AND:

    ```bash
    ~/.claude/skills/get-session-info/scripts/get-session-info.sh [--session-id ID] [--cwd PATTERN] [--status STATUS]
    ```

1. Handle the output:
    - If the user asked to send instructions to a session, use the matched session's `name` to identify the target (e.g. as the `to` of `SendMessage`) and continue that task. Exclude the current session (`sessionId` equal to `${CLAUDE_SESSION_ID}`) and never message it; if it was the only match, tell the user. If multiple sessions match, ask the user which one to use.
    - Otherwise, respond using the templates below. Do not add any extra text.

## Output Templates

### `SESSION|{sessionId}|{name}|{kind}|{status}|{pid}|{startedAt}|{cwd}` (one line per session)

  ```
  Found {count} session(s).

  - {name} ({sessionId})
    - Status: {status}
    - Kind: {kind}
    - PID: {pid}
    - Started at: {startedAt}
    - CWD: {cwd}
  ```

Repeat the list item for each session.

### `NOT_FOUND`

  ```
  No matching session found.
  ```
