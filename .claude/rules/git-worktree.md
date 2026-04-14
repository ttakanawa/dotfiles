# Git Worktree

Worktree base directory is `~/worktrees` (configured in gwq).

## Tools

| Use | Instead of | Description |
| ------ | ------------- | ------------- |
| `wtp` | `git worktree add/remove` | Worktree lifecycle with post_create hooks |
| `gwq` | `git worktree list` | Worktree listing (JSON output for fzf) |

## Shell Utilities

  ```bash
  gwa <branch>             # Create worktree for existing branch
  gwn <branch>             # Create worktree with new branch (-b)
  gwcd                     # Select and cd to a worktree (fzf)
  gwrm                     # Select and remove a worktree (fzf)
  gwp                      # cd to main worktree
  ```
