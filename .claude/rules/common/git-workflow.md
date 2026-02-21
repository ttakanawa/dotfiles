# Git Workflow

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

- Commits MUST be prefixed with a type, followed by the OPTIONAL `!`, and REQUIRED terminal colon and space.
- A description MUST immediately follow the colon and space after the type/scope prefix. The description is a short summary of the code changes, e.g., _fix: array parsing issue when multiple spaces were contained in string_.
- A longer commit body MAY be provided after the short description, providing additional contextual information about the code changes. The body MUST begin one blank line after the description.
- A commit body is free-form and MAY consist of any number of newline separated paragraphs.
- Breaking changes MUST be indicated by a `!` immediately before the `:`. If `!` is used, and the commit description SHALL be used to describe the breaking change.
- The units of information that make up Conventional Commits MUST NOT be treated as case sensitive.

Note: Attribution disabled globally via ~/.claude/settings.json.
