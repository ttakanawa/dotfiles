---
name: commit-staged
description: Analyze staged changes and create a commit with a Conventional Commits message
model: sonnet
disable-model-invocation: true
allowed-tools: Bash(git commit:*)
---

# Commit Staged

Analyze the currently staged changes and create an appropriate commit through an interactive process.

Note: Attribution disabled globally via ~/.claude/settings.json.

## Workflow Steps

1. Run `git diff --staged` to see exactly what is staged.
1. If nothing is staged, report that and stop.
1. Analyze the nature of the changes — what was added, modified, removed, and why.
1. Present the proposed message to the user:

   ```
    Proposed commit message:

    ───────────────────────────────────────
    <message from agent>
    ───────────────────────────────────────
    ```

1. **CRITICAL: Wait for the user's explicit approval.** Do not proceed to commit until the user approves.
1. Once approved, execute the commit with the approved message.
1. After creating the commit successfully, run `git show -s <commit-hash>` and display the output wrapped in clear visual dividers like this:

    ```
    Commit created successfully!

    ───────────────────────────────────────
    [Output of git show -s]
    ───────────────────────────────────────
    ```

## Commit Message Format

Refer to [conventional-commits.md](conventional-commits.md) for formatting rules.
