# Tools for AI

Guidelines for AI when executing shell commands.

## Preferred Tools

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

## Patterns

### jq

  ```bash
  jq '.key' file.json                # Extract field
  jq '.items[] | .name' file.json    # Iterate array
  jq -r '.url' file.json             # Raw string output (no quotes)
  ```

### gh / glab

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

### ghq

  ```bash
  ghq root                  # Print the repo root directory
  ghq list                  # List all managed repositories
  ghq list -p               # List with full paths
  ```
