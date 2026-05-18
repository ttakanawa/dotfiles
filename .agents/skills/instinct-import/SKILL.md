---
name: instinct-import
description: Use when the user wants to import learned instincts from a file or URL into project/global scope. Triggers include "import instincts", "load instincts from <file>", or typing /instinct-import. The user must supply a path or URL.
---

# Instinct Import

Import instincts from a file (or URL) into the local store. Use this to load instincts shared by teammates or restored from backup.

## Argument

This skill requires a source path (or URL). If the user did not supply one, ask them before running.

## Run

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py import <source-path-or-url>
```

Optional scope override (ask the user when not obvious):

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py import <source> --scope project
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py import <source> --scope global
```

If `Bash(python3:*)` is denied, prefix with `uv run --no-project --with pyyaml ` instead of `python3 `.

Report the imported count and any skipped/conflicting instincts to the user.

## Safety

Imported instincts land in `inherited/` (not `personal/`) so they don't overwrite locally-learned ones. The user can review them with the instinct-status skill before promoting.
