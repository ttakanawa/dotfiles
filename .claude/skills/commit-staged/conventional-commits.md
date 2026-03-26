# Conventional Commits

## Format

```
<type>(<optional scope>): <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

## Rules

- A scope MAY be provided after a type. A scope MUST consist of a noun describing a section of the codebase surrounded by parenthesis, e.g., fix(parser):
- Commits MUST be prefixed with a type, followed by the OPTIONAL `!`, and REQUIRED terminal colon and space.
- A description MUST immediately follow the colon and space after the type/scope prefix. The description is a short summary of the code changes, e.g., _fix: array parsing issue when multiple spaces were contained in string_.
- A longer commit body MAY be provided after the short description, providing additional contextual information about the code changes. The body MUST begin one blank line after the description.
- A commit body is free-form and MAY consist of any number of newline separated paragraphs.
- Breaking changes MUST be indicated by a `!` immediately before the `:`. If `!` is used, the commit description SHALL be used to describe the breaking change.
- The units of information that make up Conventional Commits MUST NOT be treated as case sensitive.

## Examples

### Good

```
feat(zsh): add fzf-based directory picker for tmux sessions
```

```
fix(nvim): correct telescope keymap conflict with flash.nvim
```

```
refactor(zsh): extract git helper functions into aliases.zsh
```

```
feat(tmux): add CPU usage indicator to status bar

Use tmux-cpu plugin to display real-time CPU percentage
in the right side of the status line.
```

```
feat!: migrate from .zshrc monolith to modular .config/zsh/ layout

Split environment, aliases, and plugin initialization into
separate files under .config/zsh/. Existing .zshrc now only
sources these modules.
```

### Bad

- `update stuff` — no type, vague description
- `feat: changes` — meaningless description
- `fix(nvim): fix the bug in the config that was causing issues with the thing` — too long, too vague
- `feat(zsh): Add new alias` — does not say what alias or why
- `refactor: refactor code` — tautological, says nothing about what was refactored
- `chore: update` — no scope, no useful description
