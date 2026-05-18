---
name: instinct-status
description: Use when the user wants to see learned instincts (project + global) with confidence scores. Triggers include "show my instincts", "what have I learned", "instinct status", or typing /instinct-status. Reads from the continuous-learning-v2 store.
---

# Instinct Status

Show learned instincts for the current project plus global instincts, grouped by domain with confidence bars.

## Run

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py status
```

If `Bash(python3:*)` is denied in the current environment, fall back to:

```bash
uv run --no-project --with pyyaml python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py status
```

Display the output verbatim to the user.

## What the CLI Does

1. Detects current project context (git remote URL hash, fallback to repo path).
2. Reads project instincts from `${XDG_DATA_HOME:-~/.local/share}/ecc-homunculus/projects/<project-id>/instincts/`.
3. Reads global instincts from `${XDG_DATA_HOME:-~/.local/share}/ecc-homunculus/instincts/`.
4. Merges with precedence rules (project overrides global on id conflict).
5. Prints them grouped by domain with confidence bars and observation stats.
