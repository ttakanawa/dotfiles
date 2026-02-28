#!/bin/bash
#
# Inspired by lazygit's reword implementation:
#   https://github.com/jesseduffield/lazygit/blob/818ca17f9a91d9c4b3be22bfd6d08fabe9f8ff40/pkg/gui/controllers/local_commits_controller.go#L452-L452
#
# Usage:
#   ./git-reword.sh <commit-hash> <new-message>
#
# Examples:
#   # Single line message
#   ./git-reword.sh abc1234 "Fix typo in README"
#
#   # Multi-line message (using $'\n')
#   ./git-reword.sh abc1234 $'Fix typo in README\n\nThis fixes a spelling mistake in the installation section.'
#
#   # Multi-line message (using quotes with literal newlines)
#   ./git-reword.sh abc1234 "Fix typo in README
#
#   This fixes a spelling mistake in the installation section."
#
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <commit-hash> <new-message>" >&2
  exit 1
fi

commit_hash="$1"
new_message="$2"

if [ "$(git rev-parse HEAD)" = "$(git rev-parse "$commit_hash")" ]; then
  git commit --allow-empty --amend --only -m "$new_message"
else
  short_hash=$(git rev-parse --short "$commit_hash")
  GIT_SEQUENCE_EDITOR="sed -i '' 's/^pick ${short_hash}/edit ${short_hash}/'" \
    git rebase --interactive --autostash --keep-empty --no-autosquash --rebase-merges "${commit_hash}^" &&
    git commit --allow-empty --amend --only -m "$new_message" &&
    git rebase --continue
fi
