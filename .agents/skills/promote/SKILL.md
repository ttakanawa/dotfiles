---
name: promote
description: Use when the user wants to promote project-scoped instincts to global scope so they apply across every project. Triggers include "promote instinct <id>", "promote all qualifying instincts to global", or typing /promote.
---

# Promote

Promote project-scoped instincts to global scope. An instinct becomes a candidate when the same id appears in 2+ projects with average confidence >= 0.8.

## Run

Auto-promote everything that qualifies (most common):

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py promote
```

Promote a specific instinct id (ask the user for the id if not given):

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py promote <instinct-id>
```

Dry-run preview (safe; no changes):

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py promote --dry-run
```

If `Bash(python3:*)` is denied, prefix with `uv run --no-project --with pyyaml ` instead of `python3 `.

When unsure about scope or which instincts to promote, run `--dry-run` first and show the user before committing.

## Effect

Promoted instincts move from `projects/<hash>/instincts/personal/` to the global `instincts/personal/` directory and gain `scope: global`. They then apply to every project.
