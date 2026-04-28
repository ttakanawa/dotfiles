---
name: handoff
description: Use when switching sessions or handing off work to a new session
model: sonnet
allowed-tools: Write, Bash(git branch:*), Bash(git status:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*)
---

# Handoff — Session Handoff

Generate a handoff document that a new session can act on immediately. The output is not a summary or a report — it is a direct instruction.

## Step 1 — Gather Git State

Run the following commands in parallel to capture the current git state:

  ```bash
  git branch --show-current
  git status --short
  git log --oneline -5
  ```

## Step 2 — Commit Uncommitted Changes

If `git status --short` from Step 1 shows any staged or unstaged changes, commit them:

  ```bash
  git add -A
  git commit -m "wip"
  ```

If the working tree is clean, skip this step.

## Step 3 — Analyze Conversation Context

Review the entire conversation and extract:

- **Goal**: The original request or objective. Include ticket numbers if mentioned.
- **Background**: Key decisions made, approaches tried and rejected, constraints discovered. Only include what a new session needs to know — skip routine steps.
- **Progress**: What has been completed vs. what remains. List every task as a checklist item (`[x]` for done, `[ ]` for remaining).
- **Open questions**: Undecided items, trade-offs, or concerns the next session should evaluate.
- **Relevant files**: Files that were changed or are central to the task. Not every file touched — only the ones the next session needs to know about.
- **Next steps**: Concrete, actionable items the new session should execute.

## Step 4 — Choose Output Method

Ask the user how to output the handoff document:

  - **Write to file** — save as `HANDOFF-<timestamp>.md` in the current working directory
  - **Output in session** — print the handoff document directly in the conversation without creating a file

## Step 5 — Write Handoff File or Output in Session

If the user chose **Write to file**, write the handoff document to a file in the current working directory.

If the user chose **Output in session**, render the handoff document in the conversation output and skip file creation.

### File Name

  ```
  HANDOFF-<YYYY-MM-DDThh-mm>.md
  ```

Use the current date and time (24-hour format, hyphen-separated). Example: `HANDOFF-2026-03-27T14-30.md`.

### Writing Rules

- **Write as instructions, not as a report.** The new session should be able to read this and immediately start working.
- **No preamble or meta-commentary.** The file must begin directly with `## Goal`.
- **No closing remarks.** End after the last next step.
- **Be specific.** Use exact file paths, function names, and error messages — not vague references.
- **Keep it concise.** Each section should contain only what the next session needs. Omit sections that have no meaningful content (e.g., if there is no background worth noting, skip it).

### Output Format

Use the template in [TEMPLATE.md](./TEMPLATE.md).

### After Writing (file only)

Print the file path so the user can pass it to a new session.
