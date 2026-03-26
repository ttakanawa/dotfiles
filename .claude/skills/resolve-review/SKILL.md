---
name: resolve-review
description: Triage review findings interactively, fix approved items, commit, and reply to MR/PR threads. Supports GitHub PR, GitLab MR, /code-review output, and text input.
---

# Resolve Review

Triage review findings one by one, fix approved items, and reply to MR/PR threads.

## Workflow

### Step 1: Collect findings

Determine the input source:

1. **GitHub PR**: If on a branch with an open PR, fetch review comments via `gh`
2. **GitLab MR**: If on a branch with an open MR, fetch review comments via `glab`
3. **Conversation context**: If review findings exist from `/code-review`, use them
4. **Manual input**: Ask the user how to provide input (paste text, specify a file, etc.)

#### GitHub PR

  ```bash
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  gh pr list --head "$BRANCH"
  ```

Fetch review comments via `gh`.

#### GitLab MR

  ```bash
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  glab mr list --source-branch "$BRANCH"
  ```

Fetch human reviewer comments (exclude CI bots and system notes):

  ```bash
  glab api "projects/<project-url-encoded>/merge_requests/<iid>/notes?per_page=100&sort=asc" \
    | jq '[.[] | select(.author.username != "ci_user") | select(.system == false) | {id: .id, body: .body, position: .position}]'
  ```

Use each comment's `position` field to identify the target file and line number.

### Step 2: Organize and present overview

Structure each finding with:

- **Number** (sequential)
- **Severity**: CRITICAL / HIGH / MEDIUM / LOW
- **Category**: Architecture / Guidelines / Security / Code Quality / Performance / Readability / License
- **Summary**: One-line description
- **File**: Target file path:line number
- **Issue**: Detailed explanation
- **Fix**: Suggested fix

For MR/PR comments, infer severity and category from the comment content. If the comment is a simple question or suggestion, classify accordingly.

Display an overview:

  ```markdown
  ## Findings Overview

  | # | Severity | Category | Summary |
  | --- | -------- | -------- | ------- |
  | 1 | HIGH | Security | Tutor JWT allows access to arbitrary student data |
  | 2 | MEDIUM | Architecture | Domain defaults in Controller |
  | ... | ... | ... | ... |

  {total} findings to review one by one.
  ```

### Step 3: Interactive triage

Present findings one by one in order of severity (CRITICAL > HIGH > MEDIUM > LOW).

For each finding, display:

  ```markdown
  ### #{N} [{SEVERITY}][{Category}] {Summary}

  **File:** `{file_path}:{line}`

  **Issue:** {Detailed explanation}

  **Fix:** {Suggested fix}

  {Show NG/OK code examples if applicable}
  ```

After displaying, **always use the AskUserQuestion tool** to ask for a decision.

#### Option design

| Option | Description |
| ------ | ------------- |
| Fix | Fix the code (and reply to MR/PR thread if applicable) |
| Skip | Acknowledge but do not fix in this session |
| Free input | Provide a custom decision or opinion |

#### Notes

- If a finding has a counterargument or acceptable reason, add a "However, ..." note
- Respect the user's decisions and do not steer them
- Record free input content as-is in the Decision column
- When providing code examples, use a copy-pasteable format
- **Do not proceed to Step 4 until all findings have been triaged** — complete the entire triage loop before making any code changes

### Step 4: Fix code

For items marked "Fix", make code changes.

- Read target files before modifying
- Follow existing coding conventions and patterns
- Create or update tests if needed

### Step 5: Self-review

After all fixes are complete, run review agents in parallel to self-review the changes.

Process review results:

- **Auto-fixable issues** → Fix immediately
- **Design decisions needed** → Ask the user (note any conflicts with original review comments)

### Step 6: Commit

Split commits by finding unit where possible. When a single file contains fixes for multiple findings, commit at the file level — no need to split by line.

Track which commits correspond to which findings (used in Step 7).

### Step 7: Reply to MR/PR threads (MR/PR input only)

Skip this step if the input was not from an MR/PR.

#### GitHub PR

Create a pending review (draft) with all reply comments at once:

  ```bash
  gh api -X POST "repos/{owner}/{repo}/pulls/{pr_number}/reviews" \
    --input - <<'EOF'
  {
    "event": "PENDING",
    "comments": [
      {"path": "<file>", "line": <line>, "body": "Fixed. <commit-hash> <summary>"}
    ]
  }
  EOF
  ```

The user submits the pending review on GitHub when ready.

#### GitLab MR

1. Get discussion ID from note ID:

  ```bash
  glab api "projects/<project>/merge_requests/<iid>/discussions?per_page=100" \
    | jq -r '.[] | select(.notes[0].id == <note_id>) | .id'
  ```

2. Reply to the discussion as a draft note:

  ```bash
  glab api -X POST "projects/<project>/merge_requests/<iid>/draft_notes" \
    -f "note=Fixed. <commit-hash> <summary>" \
    -f "in_reply_to_discussion_id=<discussion_id>"
  ```

#### Reply format

- Use at least 8-character commit hashes (`git rev-parse --short=8 HEAD`) — GitLab requires 8+ hex characters for auto-linking
- Do not wrap commit hashes in backticks (let the platform render them as hyperlinks)
- One reply per thread
- Keep the summary concise (one sentence)

### Step 8: Summary

Display the final triage summary:

  ```markdown
  ## Resolve Review Summary

  | # | Severity | Category | Summary | Decision | Commit |
  | --- | -------- | -------- | ------- | -------- | ------ |
  | 1 | HIGH | Security | ... | Fix | abc1234 |
  | 2 | MEDIUM | Architecture | ... | Skip | — |
  | ... | ... | ... | ... | ... | ... |

  ### Statistics

  - Fix: {N}
  - Skip: {N}
  - Free input: {N}
  ```

## Error Handling

- MR/PR not found → Ask for branch name or MR/PR ID
- API error → Display error and suggest retry or manual action
- Commit hash link not working → Check for backtick wrapping
