---
name: update-commit-message
description: Use when changing a commit message
argument-hint: <commit-hash>
model: haiku
disable-model-invocation: true
allowed-tools: Bash(~/.claude/skills/update-commit-message/scripts/*)
---

# Update Commit Message

Analyze the specified commit changes and create an appropriate commit through an interactive process.

Note: Attribution disabled globally via ~/.claude/settings.json.

## Workflow Steps

1. Run `git show <commit-hash>` to see the commit's changes and current message.
1. If the commit does not exist, report that and stop.
1. Analyze the nature of the changes — what was added, modified, removed, and why.
   - If the motivation behind the changes is not self-evident from the diff (e.g., files moved to a different directory, dependencies updated, config values changed), ask the user for the reason before drafting the message.
1. Present the proposed message to the user:

   ```
    Proposed commit message:

    ───────────────────────────────────────
    <type>(scope>): <description>

    <optional body>
    ───────────────────────────────────────
    ```

   ```

1. **CRITICAL: Wait for the user's explicit approval.** Do not proceed to commit until the user approves.
1. Once approved, execute the update using the helper script:

    ```bash
    ~/.claude/skills/update-commit-message/scripts/git-reword.sh <commit-hash> "<commit-message>"
    ```

1. After updating the commit successfully, run `git show -s <new-commit-hash>` and display the output wrapped in clear visual dividers like this:

    ```
    Commit message updated successfully!

    ───────────────────────────────────────
    [Output of git show -s]
    ───────────────────────────────────────
    ```

    Note: The commit hash changes after rebase. Use the hash from the rebase output.
