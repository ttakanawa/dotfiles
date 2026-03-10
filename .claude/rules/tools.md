# Tools for AI

Guidelines for AI when executing shell commands.

## Preferred Tools

| Use | Instead of | Description |
| ------ | ---------- | ------------- |
| `fd` | `find` | Simple file search |
| `rg` | `grep` | Fast text search |
| `jq` | manual JSON parsing | JSON extraction and transformation |
| `tree` | `ls -R` | Visual directory structure |
| `gh` | `git` commands for remote access | GitHub operations (PRs, issues, Actions, API) |
| `glab` | `git` commands for remote access | GitLab operations (MRs, issues, CI/CD, API) |
| `ghq` | manual clone paths | Git repository path management |
| `bunx` | `bunx` | Package runner |

## Patterns

### jq

  ```bash
  jq '.key' file.json                # Extract field
  jq '.items[] | .name' file.json    # Iterate array
  jq -r '.url' file.json             # Raw string output (no quotes)
  ```

### gh

  ```bash
  gh pr list                           # List open PRs
  gh pr view 123                       # View PR details
  gh issue list --label bug            # Filter issues
  gh api repos/{owner}/{repo}/actions/runs  # Raw API call
  ```

### ghq

  ```bash
  ghq root                  # Print the repo root directory
  ghq list                  # List all managed repositories
  ghq list -p               # List with full paths
  ```
