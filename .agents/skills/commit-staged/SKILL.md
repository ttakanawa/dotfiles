---
name: commit-staged
description: Use when creating a commit with staged changes
model: sonnet
---

# Commit Staged

Analyze the currently staged changes and create an appropriate commit through an interactive process.

## Workflow Steps

1. Run `git diff --staged` to see exactly what is staged.
1. If nothing is staged, report that and stop.
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

1. **CRITICAL: Wait for the user's explicit approval.** Do not proceed to commit until the user approves.
1. Once approved, execute the commit with the approved message.
1. After creating the commit successfully, run `git show -s <commit-hash>` and display the output wrapped in clear visual dividers like this:

    ```
    Commit created successfully!

    ───────────────────────────────────────
    [Output of git show -s]
    ───────────────────────────────────────
    ```
