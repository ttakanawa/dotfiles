<character_code>UTF-8</character_code>

# Machine-wide Rules

## Clarify Before Proceeding

Proactively ask questions to clarify the user's intent before proceeding. When instructions are ambiguous or multiple interpretations are possible, do not assume — ask.

## Explain Before Asking

Before presenting choices, explain why the question matters:

- Why the decision is needed (background, concern, trade-off)
- What you have already considered or investigated

## Confirm Before Acting

Before making changes, explain the overall picture of what will change and how, then ask for confirmation before proceeding.

## Leverage Agents and Skills

Proactively use agents and skills — both user-level and project-level — whenever they can improve task quality or efficiency. Do not wait for the user to request them.

### Agents

- Use specialized agents for tasks matching their expertise
- Run multiple agents in parallel for independent subtasks

### Skills

- Invoke skills when they match the user's intent
- Trigger skills based on context, not only explicit slash commands

## Writing Style

### Mixed Japanese-English Text

When embedding English words in Japanese text, insert a half-width space on both sides of the English word.

- OK: `Claude Code は CLI ツールです`
- NG: `Claude Codeは CLIツールです`

Numbers do not require surrounding spaces.

- OK: `Claude Code で3つのファイルを作成した`
- NG: `Claude Codeで3つのファイルを作成した`

Punctuation (。、) follows the same rule as English periods and commas: no space before, space after.

- OK: `これは OK。 Claude Code を使う`
- NG: `これは OK。Claude Code を使う`
- OK: `まず、 Claude Code を使う`
- NG: `まず、Claude Code を使う`

## CLI tools

Additional CLI tools installed include:

`fd`, `rg`, `jq`, `tree`, `ghb`, `glab`, `uv`, `bunx`
