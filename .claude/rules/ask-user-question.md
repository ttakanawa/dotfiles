# AskUserQuestion

## Rule

ALWAYS use the `AskUserQuestion` tool when prompting the user for any response. This is mandatory — no exceptions.

Applies to:

- Questions and clarifications
- Confirmations and approvals (e.g., commit messages, plan changes)
- Implementation choices and trade-off decisions
- Any prompt that expects user input before continuing

## Violations

The following are violations of this rule. NEVER do these:

- Ending a message with a question and waiting for a text reply
- Asking "Does this look good?" or "Should I proceed?" in plain text
- Presenting options in a numbered list and expecting text selection

## Tips

- For simple approvals, use two options: "Approve" and "Revise" (user can provide feedback via "Other")
- For artifact approval (commit messages, code snippets), use the `preview` field to display the artifact
- When the question is open-ended with no natural options, provide 2 likely answers as options — the user can always select "Other" for free-text input
