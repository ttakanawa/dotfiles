---
description: Create a git commit with staged changes
argument-hint: optional message context
allowed-tools: Bash, Read
---

Review the currently staged changes and create an appropriate commit:

1. Use `git status` and `git diff --staged` to understand what's being committed
2. Analyze the nature of changes (new feature, bug fix, refactor, etc.)
3. Write a commit message following these rules:
   - **Subject line (first line)**:
     - Limit to 50 characters (aim for this as guideline, 72 is hard limit)
     - Capitalize the first letter
     - Do not end with a period
     - Use imperative mood (e.g., "Add feature" not "Added feature")
     - Should complete: "If applied, this commit will [your subject line]"
   - **Body (optional)**:
     - Separate from subject with a blank line
     - Wrap at 72 characters per line
     - Explain what and why (not how - code shows how)
     - Focus on the problem being solved and context
     - Use bullet points (hyphen or asterisk) if needed
     - Put issue tracker references at bottom if applicable
4. Do not add co-author attribution to the commit message
7. **Present the commit message to the user for review before committing**
   - Use the following format to clearly separate the commit message from explanations:

   Example:
   ```
   Proposed commit message:

   ───────────────────────────────────────
   Add feature X to handle user input

   Implement validation and error handling for the new input form.
   This improves user experience by providing immediate feedback
   when they enter invalid data.
   ───────────────────────────────────────

   Review notes:
   - Uses imperative mood ("Add" not "Added")
   - Subject line is 38 characters (within 50 char guideline)
   - Body wrapped at 72 characters per line
   - Explains what and why the change was made
   ```

8. Wait for the user's approval
9. Once approved, create the commit with the reviewed message
10. After creating the commit, run `git show -s <commit-hash>` and display the result with clear formatting:

   Example:
   ```
   Commit created successfully!

   ───────────────────────────────────────
   commit df9dda3 (HEAD -> master)
   Author: Your Name <email@example.com>
   Date:   Sat Jan 10 13:54:29 2026 +0800

       Add feature X to handle user input

       Implement validation and error handling for the new input form.
       This improves user experience by providing immediate feedback
       when they enter invalid data.
   ───────────────────────────────────────
   ```

Additional context from user: $ARGUMENTS

Ensure the commit message accurately reflects the changes and follows simple imperative style.
