---
name: instinct-export
description: Use when the user wants to export learned instincts to a file for sharing or backup. Triggers include "export my instincts", "share instincts", "back up instincts", or typing /instinct-export. Supports filtering by scope/domain.
---

# Instinct Export

Export instincts (project, global, or both) to a single file. Useful for sharing patterns across machines or teammates.

## Run

Default (export everything for the current project + global):

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py export
```

Common flags (ask the user which scope/filter they want before running):

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py export --scope project
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py export --scope global
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py export --domain testing
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py export --output /path/to/file.yaml
```

If `Bash(python3:*)` is denied, prefix with `uv run --no-project --with pyyaml ` instead of `python3 `.

Report the export path to the user.

## Privacy Note

Only instincts (patterns) are exported — never raw observations or session content.
