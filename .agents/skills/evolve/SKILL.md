---
name: evolve
description: Use when the user wants to analyze accumulated instincts and surface clusters that could become full Skills, Commands, or Agents. Triggers include "evolve my instincts", "what could become a skill", "suggest skills from my patterns", or typing /evolve. Add --generate when the user explicitly asks to write evolved files.
---

# Evolve

Cluster related instincts and propose evolved structures (Skill / Command / Agent). Without `--generate`, this is a **read-only proposal**.

## Run

Proposal only (default — start here):

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py evolve
```

Generate files into `evolved/{skills,commands,agents}/` (ask the user before doing this):

```bash
python3 ~/.agents/skills/continuous-learning-v2/scripts/instinct-cli.py evolve --generate
```

If `Bash(python3:*)` is denied, prefix with `uv run --no-project --with pyyaml ` instead of `python3 `.

## Evolution Rules (used by the CLI)

| Output | Trigger |
| --- | --- |
| Command | Multiple instincts about "when user asks to..." — explicit user-invoked workflows |
| Skill | Auto-trigger pattern clusters of 2+ instincts (code style, error handling, etc.) |
| Agent | Larger high-confidence clusters describing multi-step processes (debugging, refactoring) |

The CLI also surfaces promotion candidates (project → global) — relay them so the user can decide.

## Important

- Default behavior is **proposal only**. Do not pass `--generate` without explicit user confirmation, since it writes files into the homunculus store.
- Generated files live under `${XDG_DATA_HOME:-~/.local/share}/ecc-homunculus/projects/<hash>/evolved/` (project scope) or `.../ecc-homunculus/evolved/` (global). They are not auto-installed into `~/.claude/skills/` — the user copies them in deliberately.
