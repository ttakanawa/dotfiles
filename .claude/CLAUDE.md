# Vamos

## Clarify Before Proceeding

Proactively ask questions to clarify the user's intent before proceeding. When instructions are ambiguous or multiple interpretations are possible, do not assume — ask.

## Explain Before Asking

Before presenting choices, explain why the question matters:

- Why the decision is needed (background, concern, trade-off)
- What you have already considered or investigated

## Confirm Before Acting

Before making changes, explain the overall picture of what will change and how, then ask for confirmation before proceeding.

## Leverage Agents and Skills

Proactively use agents and skills — both user-level and project-level — whenever they can improve task quality or efficiency. Do not wait for the user to request them.

### Agents

- Use specialized agents for tasks matching their expertise
- Run multiple agents in parallel for independent subtasks

### Skills

- Invoke skills when they match the user's intent
- Trigger skills based on context, not only explicit slash commands

## Writing Style

### Mixed Japanese-English Text

When embedding English words in Japanese text, insert a half-width space on both sides of the English word.

- OK: `Claude Code は CLI ツールです`
- NG: `Claude Codeは CLIツールです`

Numbers do not require surrounding spaces.

- OK: `Claude Code で3つのファイルを作成した`
- NG: `Claude Codeで3つのファイルを作成した`

Punctuation (。、) follows the same rule as English periods and commas: no space before, space after.

- OK: `これは OK。 Claude Code を使う`
- NG: `これは OK。Claude Code を使う`
- OK: `まず、 Claude Code を使う`
  - NG: `まず、Claude Code を使う`


## Tools for AI

Guidelines for AI when using tools.
Always prefer built-in tools (Glob, Grep, Read, Edit, Write) over the Bash tool.

### Preferred Shell Tools

When using the Bash tool, prefer these over their alternatives.

| Use | Instead of | Description |
| ------ | ---------- | ------------- |
| `fd` | `find` | Simple file search |
| `rg` | `grep` | Fast text search |
| `jq` | manual JSON parsing | JSON extraction and transformation |
| `tree` | `ls -R` | Visual directory structure |
| `gh` | `git` commands for remote access | GitHub operations (PRs, issues, Actions) |
| `glab` | `git` commands for remote access | GitLab operations (MRs, issues, CI/CD) |
| `ghq` | manual clone paths | Git repository path management |
| `uv` | `python` / `python3` | Python package and project management |
| `bunx` | `bunx` | Package runner |

### Patterns

#### jq

  ```bash
  jq '.key' file.json                # Extract field
  jq '.items[] | .name' file.json    # Iterate array
  jq -r '.url' file.json             # Raw string output (no quotes)
  ```

#### gh / glab

Always prefer high-level subcommands over raw API calls.
`gh api` / `glab api` should only be used as a last resort when no dedicated subcommand exists.

  ```bash
  # Good
  gh pr list                           # List open PRs
  gh pr view 123                       # View PR details
  gh issue list --label bug            # Filter issues
  gh run list                          # List workflow runs
  glab mr list                         # List open MRs
  glab mr view 123                     # View MR details
  glab ci list                         # List CI pipelines

  # Bad - use subcommands instead
  gh api repos/{owner}/{repo}/pulls
  glab api projects/:id/merge_requests
  ```

#### ghq

  ```bash
  ghq root                  # Print the repo root directory
  ghq list                  # List all managed repositories
  ghq list -p               # List with full paths
  ```

## Git Worktree

Worktree base directory is `~/worktrees` (configured in gwq).

### Tools

| Use | Instead of | Description |
| ------ | ------------- | ------------- |
| `wtp` | `git worktree add/remove` | Worktree lifecycle with post_create hooks |
| `gwq` | `git worktree list` | Worktree listing (JSON output for fzf) |

### Shell Utilities

  ```bash
  gwa <branch>             # Create worktree for existing branch
  gwn <branch>             # Create worktree with new branch (-b)
  gwcd                     # Select and cd to a worktree (fzf)
  gwrm                     # Select and remove a worktree (fzf)
  gwp                      # cd to main worktree
  ```
