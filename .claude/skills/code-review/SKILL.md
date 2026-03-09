---
name: code-review
description: Unified code review for GitLab MRs, GitHub PRs, commit hashes, or git diffs. Covers code quality, security, performance, readability, best practices, and licensing.
---

# Code Review

Senior code reviewer ensuring high standards of quality, security, and maintainability.

## Supported Review Targets

Determine the review target from user input or arguments:

| Target | How to detect | Command to get diff |
|--------|--------------|-------------------|
| GitLab MR | Numeric ID + `glab` available | `glab mr view -F json <ID>` then `git diff origin/<target>...origin/<source>` |
| GitHub PR | Numeric ID or URL + `gh` available | `gh pr view <ID> --json title,body,baseRefName,headRefName` then `git diff origin/<base>...origin/<head>` |
| Commit hash(es) | 1+ SHA strings (7-40 chars) | Single: `git diff <hash>^..<hash>` / Multiple: `git diff <first>^..<last>` |
| Git diff (default) | No arguments given | `git diff --staged` then `git diff` (fallback: `git log --oneline -5`) |

## Workflow

### Step 1: Identify review target

Parse arguments to determine which target type. If ambiguous, ask the user.

### Step 2: Gather context

- **MR/PR**: Fetch title, description, source/target branches. Read the description carefully for spec, implementation notes, and review points.
- **Commits/Diff**: Run the appropriate diff command.

### Step 3: Get the big picture

```bash
git diff <target>...<source> --stat
```

Review the file list and line counts to understand the scope.

### Step 4: Choose execution mode

Before starting the review, ask the user how to execute it using AskUserQuestion:

| Mode | Description | When available |
|------|-------------|---------------|
| **Subagents** | Spawn a subagent per checklist category for parallel review | Always |
| **Teammates** | Spawn a teammate per checklist category for parallel review | Only when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` env var is `"1"` or `"true"` |
| **Inline** | Review everything sequentially in the current conversation | Always |

Check the environment variable before presenting options:

```bash
echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
```

- If the value is `"1"` or `"true"`, present all three options.
- Otherwise, present only Subagents and Inline.

When using **Subagents** or **Teammates**, spawn one per checklist category (security, code-quality, performance, best-practices, readability, license). Each receives the diff context and its checklist, then reports findings independently. Aggregate all results at the end.

### Step 5: Prioritize review order

1. **Test files first** — Read tests to understand expected behavior and specs before reviewing implementation.
2. **Review points** — If MR/PR description highlights specific areas, prioritize those.
3. **Largest changes first** — Files with the most changed lines deserve the most attention.

### Step 6: Review file by file

For each file:

```bash
git diff <target>...<source> -- <file_path>
```

If the diff alone is insufficient, read the full file to understand:

- Imports and dependencies
- Call sites and callers
- Surrounding context

### Step 7: Apply checklists

Apply the checklists under [checklists/](checklists/) in order of severity:

1. [security.md](checklists/security.md) — CRITICAL
2. [code-quality.md](checklists/code-quality.md) — HIGH
3. [performance.md](checklists/performance.md) — MEDIUM
4. [best-practices.md](checklists/best-practices.md) — MEDIUM
5. [readability.md](checklists/readability.md) — LOW
6. [license.md](checklists/license.md) — LOW

### Step 8: Check project conventions

Read `CLAUDE.md` and any project-specific rules/guidelines. Check for violations of:

- File size limits
- Naming conventions
- Error handling patterns
- Database policies
- Any other project-established patterns

When in doubt, match what the rest of the codebase does.

### Step 9: Filter and consolidate

**IMPORTANT**: Do not flood the review with noise.

- **Report** only if >80% confident it is a real issue
- **Skip** stylistic preferences unless they violate project conventions
- **Skip** issues in unchanged code unless they are critical security issues
- **Consolidate** similar issues (e.g., "5 functions missing error handling" not 5 separate findings)
- **Prioritize** issues that could cause bugs, security vulnerabilities, or data loss

### Step 10: Report findings

Use the output format below. Organize findings by severity.

## Output Format

For each issue:

```
[SEVERITY][Category] Short description of the issue
File: path/to/file:line_number
Issue: Detailed explanation of the problem
Fix: How to fix it

// NG
problematic code

// OK
fixed code
```

Severity levels: `CRITICAL` > `HIGH` > `MEDIUM` > `LOW`

Categories: `Security` / `Code Quality` / `Performance` / `Best Practices` / `Readability` / `License` / `Project Convention`

### Summary Table

End every review with:

```
## Review Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 0     | pass   |
| HIGH     | 0     | pass   |
| MEDIUM   | 0     | info   |
| LOW      | 0     | note   |

Verdict: APPROVE / WARNING / BLOCK
```

## Approval Criteria

| Verdict | Condition |
|---------|-----------|
| APPROVE | No CRITICAL or HIGH issues |
| WARNING | HIGH issues only (can merge with caution) |
| BLOCK | CRITICAL issues found — must fix before merge |
