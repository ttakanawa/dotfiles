---
name: daily-summary
description: Summarize Claude Code interactions for a given date using Agent Teams
argument-hint: "date: today, yesterday, or YYYY-MM-DD"
disable-model-invocation: true
allowed-tools: Bash(tmux display-message:*), Bash(date:*), Bash(mkdir:*), Bash(~/.claude/skills/daily-summary/*), Read, Write, AskUserQuestion, Agent, TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, SendMessage
---

# Daily Summary

Summarize Claude Code interactions for a given date by reading `history.jsonl`, grouping sessions by project, and generating per-project summaries in parallel using Agent Teams.

## Phase 0 — Pre-flight Check

Check if the current tmux window has multiple panes.

  ```bash
  tmux display-message -p '#{window_panes}' 2>/dev/null
  ```

- If the command fails (not in tmux) or returns `1` → proceed normally
- If the result is `2` or more → use `AskUserQuestion` to ask the user whether to continue, then stop and wait for their response:
  - Question: "Multiple tmux panes detected in the current window. Continue anyway?"
  - Options: "Continue" / "Abort"
  - If the user chooses "Abort", stop immediately

## Phase 1 — Parse Date from Arguments

Parse `$ARGUMENTS` to determine the target date.

- `today` → today's date
- `yesterday` → yesterday's date
- `YYYY-MM-DD` → specific date
- Empty → use `AskUserQuestion` to ask the user which date to summarize, then stop and wait for their response

For `today` and `yesterday`, resolve to `YYYY-MM-DD` first using `date "+%Y-%m-%d"` or `date -v-1d "+%Y-%m-%d"`.

Create the tmp directory for intermediate output:

  ```bash
  TMP_DIR=~/.claude/skills/daily-summary/tmp/$TARGET_DATE
  OUTPUT_DIR=~/.claude/skills/daily-summary/output
  mkdir -p "$TMP_DIR" "$OUTPUT_DIR"
  ```

## Phase 2 — Filter history.jsonl

Extract unique project + session pairs for the target date:

  ```bash
  ~/.claude/skills/daily-summary/filter-sessions.sh "$TARGET_DATE" > "$TMP_DIR/sessions.json"
  ```

This produces: `[{project: "/Users/.../dotfiles", sessions: ["uuid1", "uuid2"]}, ...]`

If the result is empty, report "No sessions found for the specified date" and stop.

## Phase 3 — Create Team and Tasks

1. Use `TeamCreate` to create a team named `daily-summary-YYYY-MM-DD` (use the start date).
2. For each project in the filtered results, use `TaskCreate`:
   - **subject**: `Summarize <project-basename>` (e.g. `Summarize dotfiles`)
   - **description**: Include the full project path, list of session IDs, and target date

## Phase 4 — Launch Teammates (One Per Project, in Parallel)

For each project, launch a teammate using the `Agent` tool with these settings:

- `subagent_type`: `"general-purpose"`
- `model`: `"haiku"`
- `team_name`: the team name from Phase 3
- Launch all teammates **in parallel** (single message with multiple Agent tool calls)

Each teammate's prompt must include:

### 4a. Project and Session Info

- Project path and session ID list
- Session file location: `~/.claude/projects/<escaped-path>/<sessionId>.jsonl`
  - Path escaping rule: replace every `/` with `-` (e.g. `/Users/tknw/dotfiles` → `-Users-tknw-dotfiles`)

### 4b. Project Context

Read project context files (if they exist) for a brief understanding of the project:

  ```bash
  head -50 <project-path>/README.md 2>/dev/null
  head -50 <project-path>/CLAUDE.md 2>/dev/null
  ```

### 4c. Session Message Extraction

Extract messages from each session file and save to tmp:

  ```bash
  TMP_DIR=~/.claude/skills/daily-summary/tmp/$TARGET_DATE
  ~/.claude/skills/daily-summary/extract-user-messages.sh "$SESSION_FILE" > "$TMP_DIR/${SESSION_ID}-user.jsonl"
  ~/.claude/skills/daily-summary/extract-assistant-messages.sh "$SESSION_FILE" > "$TMP_DIR/${SESSION_ID}-assistant.jsonl"
  ```

### 4d. Summary Format

Each teammate should produce a summary in this format:

  ```markdown
  <1-line project overview based on README/CLAUDE.md>

  ### Session `<sessionId-prefix>...` (HH:MM–HH:MM)

  - **Topics**: <bullet list of main topics discussed>
  - **Outcomes**: <bullet list of concrete outcomes/changes made>

  (repeat for each session)
  ```

The time range `(HH:MM–HH:MM)` is derived from the minimum and maximum `ts` values of the extracted messages for that session.

### 4e. Completion

After generating the summary:

1. Use `SendMessage` (type: `"message"`) to send the summary to the lead
2. Use `TaskUpdate` to mark the assigned task as `completed`

## Phase 5 — Assemble Report

After all teammates have reported back, combine their summaries into a single report using `~/.claude/skills/daily-summary/TEMPLATE.md` as the template.

Fill in:

1. **Header**: Date, total projects count, total sessions count
2. **Hourly Breakdown**: List all 24 hours (`00:00`–`23:00`). Using the session time ranges (`HH:MM–HH:MM`) from teammate summaries, group sessions into 1-hour buckets. For each hour with sessions, generate a table row with projects count, sessions count, and a brief summary. For hours without sessions, set projects to `0`, sessions to `0`, and summary to `N/A`. A session that spans multiple hours should appear in each hour it touches. Summary format: `[project-name] topic1, topic2; [project-name2] topic1` — wrap each project name in `[]`, list multiple topics with commas, and separate projects with semicolons.
3. **Per-project sections**: Insert each teammate's summary under its project heading

Write the report to `~/.claude/skills/daily-summary/output/YYYY-MM-DD.md`.

Display the full report content to the user, followed by the saved file path.

## Phase 6 — Cleanup

1. Send `shutdown_request` to all teammates
2. After all teammates have shut down, use `TeamDelete` to remove the team

$ARGUMENTS
