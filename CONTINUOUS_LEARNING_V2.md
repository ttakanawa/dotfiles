# Continuous Learning v2 Lifecycle

`continuous-learning-v2` turns Claude Code sessions into reusable "instincts": small, evidence-backed behavior patterns with confidence scores. The system observes tool usage, detects repeated patterns, stores project-scoped and global instincts, and can later evolve those instincts into candidate skills, commands, or agents.

## Related Files

| Path | Purpose |
| ------ | ------------- |
| `.agents/skills/continuous-learning-v2/SKILL.md` | Main skill documentation and lifecycle overview |
| `.agents/skills/continuous-learning-v2/config.json` | Observer configuration (`enabled`, interval, minimum observations) |
| `.agents/skills/continuous-learning-v2/hooks/observe.sh` | `PreToolUse` / `PostToolUse` hook that captures tool observations |
| `.agents/skills/continuous-learning-v2/scripts/detect-project.sh` | Detects project context and creates project-scoped storage |
| `.agents/skills/continuous-learning-v2/scripts/lib/homunculus-dir.sh` | Resolves the `ecc-homunculus` data directory |
| `.agents/skills/continuous-learning-v2/scripts/instinct-cli.py` | CLI for `status`, `import`, `export`, `evolve`, `promote`, `projects`, and `prune` |
| `.agents/skills/continuous-learning-v2/agents/start-observer.sh` | Starts, stops, and checks the background observer |
| `.agents/skills/continuous-learning-v2/agents/observer-loop.sh` | Background loop that samples observations and runs analysis |
| `.agents/skills/continuous-learning-v2/agents/session-guardian.sh` | Gating for observer cycles: active hours, cooldown, and idle checks |
| `.agents/skills/continuous-learning-v2/agents/observer.md` | Observer agent instructions for pattern detection and instinct creation |
| `.agents/skills/instinct-status/SKILL.md` | Shows current project plus global instincts |
| `.agents/skills/evolve/SKILL.md` | Proposes or generates evolved skills, commands, and agents |
| `.agents/skills/instinct-export/SKILL.md` | Exports instincts without raw observations |
| `.agents/skills/instinct-import/SKILL.md` | Imports shared instincts into `inherited/` |
| `.agents/skills/promote/SKILL.md` | Promotes repeated project instincts to global scope |
| `.agents/skills/projects/SKILL.md` | Lists observed projects and per-project instinct counts |
| `.claude/settings.json` | Registers the observation hooks and allows the instinct CLI |

## Automatic Processing

- `observe.sh` runs from `.claude/settings.json` on `PreToolUse` and `PostToolUse`.
- The hook reads Claude Code hook JSON from stdin, extracts tool name, input, output, session ID, cwd, and project metadata, then appends JSONL observations.
- `detect-project.sh` scopes observations by project. It prefers `CLAUDE_PROJECT_DIR`, then git remote URL, then git repo root, and falls back to global storage when no project is available.
- Observation files rotate into `observations.archive/` when they become large, and old archived observation files are purged.
- When observer support is enabled, `observe.sh` lazily starts `start-observer.sh`, throttles observer signals, and wakes the observer after enough activity.
- `observer-loop.sh` samples recent observations, runs a Haiku Claude analysis session with observation hooks suppressed, and writes or updates instinct files.
- `instinct-cli.py prune --quiet` runs from the observer loop and deletes expired pending instincts.

## Manual Operations

- `/instinct-status` reviews current project and global instincts with confidence scores.
- `/evolve` proposes clusters that could become skills, commands, or agents. `--generate` writes candidate files and should only be used deliberately.
- `/promote` moves qualifying project-scoped instincts to global scope when the same pattern appears across projects with high confidence.
- `/projects` audits the project registry and instinct counts.
- Installing generated evolved files into active skills, commands, or agents is manual. Generated artifacts are stored as candidates, not auto-installed.
- `/instinct-export` exports instincts for backup or sharing. Raw observations are not exported.
- `/instinct-import <source>` imports shared instincts into `inherited/` so local `personal/` instincts are not overwritten.

## Data Storage

The data directory is resolved in this order:

1. `CLV2_HOMUNCULUS_DIR` when set to an absolute path
2. `$XDG_DATA_HOME/ecc-homunculus`
3. `$HOME/.local/share/ecc-homunculus`

The resulting structure is:

  ```text
  ${XDG_DATA_HOME:-~/.local/share}/ecc-homunculus/
  ├── projects.json
  ├── observations.jsonl
  ├── instincts/
  │   ├── personal/
  │   ├── inherited/
  │   └── pending/
  ├── evolved/
  │   ├── agents/
  │   ├── commands/
  │   └── skills/
  └── projects/
      └── <project-hash>/
          ├── project.json
          ├── observations.jsonl
          ├── observations.archive/
          ├── observer.log
          ├── observer-start.log
          ├── instincts/
          │   ├── personal/
          │   ├── inherited/
          │   └── pending/
          └── evolved/
              ├── agents/
              ├── commands/
              └── skills/
  ```

Stored data types:

- `projects.json` and each `project.json`: project ID, name, root, remote, created time, and last-seen time.
- `observations.jsonl`: timestamped tool observations with project metadata and scrubbed tool input/output.
- `instincts/personal/`: locally learned instincts created from session observations.
- `instincts/inherited/`: imported instincts from files, URLs, teammates, or backups.
- `instincts/pending/`: review queue for instincts that should expire if not accepted.
- `evolved/`: generated candidate skills, commands, and agents produced by `/evolve --generate`.
- Observer runtime files such as `.observer.pid`, `.observer-last-activity`, `.observer-signal-counter`, `observer.log`, and `.observer-tmp/`.
