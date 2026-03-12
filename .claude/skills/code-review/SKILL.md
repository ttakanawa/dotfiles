---
name: code-review
description: Unified code review for GitLab MRs, GitHub PRs, commit hashes, or git diffs. Covers architecture, guidelines, security, code quality, performance, readability, and licensing.
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

Before starting the review, ask the user how to execute it:

| Mode | Description | When available |
| ------ | ------------- | --------------- |
| **Subagents** | Spawn a subagent per checklist category for parallel review. **Note:** background subagents cannot request tool permissions interactively — if the user has not pre-approved Read/Bash, agents may fail. Warn the user of this risk when presenting this option. | Always |
| **Teammates** | Spawn a teammate per checklist category for parallel review | Only when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` env var is `"1"` or `"true"` |
| **Inline** | Review everything sequentially in the current conversation | Always |

Check the environment variable before presenting options:

```bash
echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
```

- If the value is `"1"` or `"true"`, present all three options.
- Otherwise, present only Subagents and Inline.

### Step 5: Execute review

#### Subagents / Teammates

Spawn one agent per checklist category using the dedicated review agents defined in `~/.claude/agents/`. Each agent has its own model and tools configured via frontmatter, so the correct model is used automatically.

| Agent | Category |
| ------ | ------ |
| `review-architecture` | Architecture |
| `review-guidelines` | Guidelines |
| `review-security` | Security |
| `review-code-quality` | Code Quality |
| `review-performance` | Performance |
| `review-readability` | Readability |
| `review-license` | License |

Each agent's prompt **must** include all of the following context so the agent can work without fetching it:

1. **Diff output** — The full diff from Step 2
2. **File list with line counts** — The `--stat` output from Step 3
3. **PR/MR description** — Title, description, and review points (if applicable)

Spawn all agents in parallel. Once all agents complete, aggregate their results.

#### Inline

Review everything sequentially in the current conversation:

1. **Prioritize review order**
   - Read test files first to understand expected behavior and specs.
   - If MR/PR description highlights specific areas, prioritize those.
   - Review files with the most changed lines first.

2. **Review file by file**

   For each file:

   ```bash
   git diff <target>...<source> -- <file_path>
   ```

   If the diff alone is insufficient, read the full file to understand imports, call sites, and surrounding context.

3. **Apply checklists** in order of severity:
   1. [security.md](checklists/security.md)
   2. [architecture.md](checklists/architecture.md)
   3. [guidelines.md](checklists/guidelines.md)
   4. [code-quality.md](checklists/code-quality.md)
   5. [performance.md](checklists/performance.md)
   6. [readability.md](checklists/readability.md)
   7. [license.md](checklists/license.md)

4. **Filter and consolidate**
   - **Report** only if >80% confident it is a real issue
   - **Skip** stylistic preferences unless they violate project conventions
   - **Skip** issues in unchanged code unless they are critical security issues
   - **Consolidate** similar issues (e.g., "5 functions missing error handling" not 5 separate findings)
   - **Prioritize** issues that could cause bugs, security vulnerabilities, or data loss

### Step 6: Report findings

Use the output format below. Organize findings by severity.

## Output Format

For each issue:

```
#N [SEVERITY][Category] Short description of the issue
File: path/to/file:line_number
Issue: Detailed explanation of the problem
Fix: How to fix it

// NG
problematic code

// OK
fixed code
```

Severity levels: `CRITICAL` > `HIGH` > `MEDIUM` > `LOW`

Categories: `Architecture` / `Guidelines` / `Security` / `Code Quality` / `Performance` / `Readability` / `License`

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
