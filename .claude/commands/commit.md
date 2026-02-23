# Commit

Analyze the currently staged changes and create an appropriate commit through an interactive process.

## Commit Message Format

```
<type>(<optional scope>): <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

- A scope MAY be provided after a type. A scope MUST consist of a noun describing a section of the codebase surrounded by parenthesis, e.g., fix(parser):
- Commits MUST be prefixed with a type, followed by the OPTIONAL `!`, and REQUIRED terminal colon and space.
- A description MUST immediately follow the colon and space after the type/scope prefix. The description is a short summary of the code changes, e.g., _fix: array parsing issue when multiple spaces were contained in string_.
- A longer commit body MAY be provided after the short description, providing additional contextual information about the code changes. The body MUST begin one blank line after the description.
- A commit body is free-form and MAY consist of any number of newline separated paragraphs.
- Breaking changes MUST be indicated by a `!` immediately before the `:`. If `!` is used, and the commit description SHALL be used to describe the breaking change.
- The units of information that make up Conventional Commits MUST NOT be treated as case sensitive.

Note: Attribution disabled globally via ~/.claude/settings.json.

## Workflow Steps

1. Run  `git diff --staged` to understand the exact changes.
1. Analyze the nature of the changes.
1. Generate a commit message and present it to the user for confirmation.

   ```
    Proposed commit message:

    ───────────────────────────────────────
    feat!: send an email to the customer when a product is shipped
    ───────────────────────────────────────
    ```

1. **CRITICAL: Wait for the user's explicit approval.** Do not proceed to commit until the user says "ok", "yes", or approves it.
1. Once approved, execute the commit with the approved message.
1. After creating the commit successfully, run `git show -s <commit-hash>` and display the output wrapped in clear visual dividers like this:

    ```
    Commit created successfully!

    ───────────────────────────────────────
    [Output of git show -s]
    ───────────────────────────────────────
    ```
