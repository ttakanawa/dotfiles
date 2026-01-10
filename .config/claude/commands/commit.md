---
description: Create a git commit with staged changes
argument-hint: optional message context
allowed-tools: Bash, Read
---

Review the currently staged changes and create an appropriate commit:

1. Use `git status` and `git diff --staged` to understand what's being committed
2. Analyze the nature of changes (new feature, bug fix, refactor, etc.)
3. Write a concise commit message in imperative mood (e.g., "Add feature" not "Added feature")
4. Keep the subject line under 72 characters
5. If needed, add a body with additional context
6. Do not add co-author attribution to the commit message
7. **Present the commit message to the user for review before committing**
8. Wait for the user's approval
9. Once approved, create the commit with the reviewed message
10. After creating the commit, run `git show -s <commit-hash>` and display the commit message to the user

Additional context from user: $ARGUMENTS

Ensure the commit message accurately reflects the changes and follows simple imperative style.
