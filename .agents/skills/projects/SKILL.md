---
name: projects
description: Use when the user wants to list all known projects tracked by the continuous-learning-v2 instinct system and see their instinct counts. Triggers include "list known projects", "which projects have I trained", or typing /projects.
---

# Projects

List every project the instinct system has observed, along with the number of instincts captured per project. Useful for finding promotion candidates or auditing per-project learning state.

## Run

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py projects
```

If `Bash(python3:*)` is denied, prefix with `uv run --no-project --with pyyaml ` instead of `python3 `.

Display the output verbatim.

## Output Contents

- Project hash id (e.g. `a1b2c3d4e5f6`) and human-readable name
- Per-project instinct count
- Last-seen timestamp
- Registry lives at `${XDG_DATA_HOME:-~/.local/share}/ecc-homunculus/projects.json`
