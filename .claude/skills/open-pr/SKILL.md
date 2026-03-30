---
name: open-pr
description: Create a GitLab MR or GitHub PR interactively. Detects platform, handles templates, fills sections with user approval.
---

# Create PR

Create a GitLab MR or GitHub PR through an interactive workflow.

## Workflow

Copy this checklist to track progress:

  ```
  PR creation progress:
  - [ ] Step 1: Platform detection
  - [ ] Step 2: Context gathering
  - [ ] Step 3: Language detection
  - [ ] Step 4: Template handling
  - [ ] Step 5: Title
  - [ ] Step 6: Fill template sections
  - [ ] Step 7: Draft status + final review
  - [ ] Step 8: Push & create
  - [ ] Step 9: Confirmation
  ```

### Step 1: Platform Detection

Extract the hostname from the remote URL and check if it is a GitLab instance via `glab auth status`.

  ```bash
  # Get the remote URL and extract hostname
  url=$(git remote get-url origin)
  host=$(echo "$url" | sed -E 's#https?://([^/]+).*#\1#')

  # Check if the host is authenticated with glab
  glab auth status --hostname "$host" >/dev/null 2>&1
  ```

| Result | Platform | CLI tool |
| ------ | ------------- | -------- |
| `glab auth status` succeeds | GitLab | `glab` |
| `glab auth status` fails | GitHub | `gh` |

### Step 2: Context Gathering

Run the following commands in parallel to collect information.

**Default branch:**

  ```bash
  # GitHub
  gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'

  # GitLab
  glab repo view --output json | jq -r '.default_branch'
  ```

**Current branch:**

  ```bash
  git rev-parse --abbrev-ref HEAD
  ```

**Commits on this branch:**

  ```bash
  git log origin/<default_branch>..HEAD --format='%s%n%n%b---'
  ```

**Diff stat:**

  ```bash
  git diff origin/<default_branch>...HEAD --stat
  ```

**Target branch confirmation:**

Propose the default branch as the target and confirm with the user.

### Step 3: Language Detection

Detect the project language from the commit messages collected in Step 2.

- Commit messages contain Japanese characters → Japanese
- Commit messages are English only → English
- Ambiguous → ask the user

Write all subsequent section content in the detected language.

### Step 4: Template Handling

Check whether the project has MR/PR templates.

  ```bash
  # GitLab
  ls .gitlab/merge_request_templates/ 2>/dev/null

  # GitHub (directory)
  ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null

  # GitHub (single file)
  test -f .github/pull_request_template.md && echo "pull_request_template.md"
  ```

  **Templates found:**
Let the user choose:

- Each template file name
- "Use default template"

Read the selected template.

**No templates found:**

Use the bundled GitLab default MR template at `templates/gitlab-default.md` (relative to this skill directory).

> Source: <https://gitlab.com/gitlab-org/gitlab/-/raw/master/.gitlab/merge_request_templates/Default.md>

### Step 5: Title

Generate a title based on the template conventions. If the template does not specify a title format, use the first commit message as the default title.

Show the proposed title with preview. Confirm with Approve / Revise.

### Step 6: Fill Template Sections Interactively

Fill each section of the template **one by one** interactively.

1. For each section that needs content:
   - Read the heading to understand what content is expected
   - Analyze commits and diff to propose content
   - Present the proposal with preview, confirm with Approve / Revise
   - If the user selects Revise, incorporate feedback and re-propose
2. Sections that are static (e.g., reference links, already filled boilerplate) should be kept as-is without prompting
3. **Sections containing verification or pre-merge checklist items** — regardless of format (checkboxes `- [ ]`, bullet lists, numbered lists, or plain text) — require action before creating the MR/PR. Judge from heading names (e.g., "Checklist", "Before merge") and content (items that describe conditions to verify):
   - **Auto-verifiable items** (e.g., "tests pass", "no lint errors"): Run the relevant command (test suite, linter) and check the item based on the result. If verification fails, report the failure and let the user decide whether to fix it now or leave it unchecked
   - **Manual-only items** (e.g., "migration rollback documented", "screenshots attached"): Present all remaining unverified items to the user with multiSelect so they can confirm the applicable ones
4. If a section is clearly not applicable, propose "N/A" and let the user confirm or skip
5. Remove HTML comments from the final output

### Step 7: Draft Status + Final Review

**Draft confirmation:**

Ask whether to create as draft:

- "Ready for review"
- "Draft" or "WIP"

**Final review:**

Show the complete MR/PR title and body with preview for final approval.

### Step 8: Push & Create

**Push the branch:**

  ```bash
  git push -u origin <current_branch>
  ```

**Create the MR/PR:**

  ```bash
  # GitHub
  gh pr create --title "<title>" --body "$(cat <<'EOF'
  <body>
  EOF
  )" --base "<target>" --assignee "@me"
  # Add --draft if draft

  # GitLab
  glab mr create --title "<title>" --description "$(cat <<'EOF'
  <body>
  EOF
  )" --target-branch "<target>" --assignee "@me" --squash --remove-source-branch --no-editor
  # Add --draft if draft
  ```

**Important:** Always pass body/description via heredoc (`<<'EOF'`) to avoid shell escaping issues.

### Step 9: Confirmation

Display the created MR/PR URL.

  ```bash
  # The create command output includes the URL, but if needed:

  # GitHub
  gh pr view --json url --jq '.url'

  # GitLab
  glab mr view --output json | jq -r '.web_url'
  ```

## Important Notes

- **Never add a "Generated with Claude Code" footer**
- **Always assign to self** (`@me`)
- **Always confirm with the user before proceeding**
