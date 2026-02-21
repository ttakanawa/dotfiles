# Commit

Review the currently staged changes and create an appropriate commit through an interactive process.

## Workflow Steps

1. Run  `git diff --staged` to understand the exact changes.
1. Analyze the nature of the changes.
1. Generate a commit message and present it to the user for review.

   ```
    Proposed commit message:

    ───────────────────────────────────────
    feat!: send an email to the customer when a product is shipped
    ───────────────────────────────────────
    ```

1. **CRITICAL: Wait for the user's explicit approval.** Do not proceed to commit until the user says "ok", "yes", or approves it.
1. Once approved, execute the commit with the reviewed message.
1. After creating the commit successfully, run `git show -s <commit-hash>` and display the output wrapped in clear visual dividers like this:

    ```
    Commit created successfully!

    ───────────────────────────────────────
    [Output of git show -s]
    ───────────────────────────────────────
    ```
