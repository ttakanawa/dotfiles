# Conventional Commits

## Format

```
<type>(<optional scope>): <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

## Rules

### General

- The units of information that make up Conventional Commits MUST NOT be treated as case sensitive.

### Type

- Commits MUST be prefixed with a type, followed by the OPTIONAL `!`, and REQUIRED terminal colon and space.
- Breaking changes MUST be indicated by a `!` immediately before the `:`. If `!` is used, the commit description SHALL be used to describe the breaking change.

### Scope

- A scope MAY be provided after a type. A scope MUST consist of a noun describing a section of the codebase surrounded by parenthesis, e.g., fix(parser):
- Prefer the affected subsystem (e.g., `notification`) over the directory the files happen to live in (e.g., `scripts`).

### Description

- A description MUST immediately follow the colon and space after the type/scope prefix. The description is a short summary of the code changes, e.g., _fix: array parsing issue when multiple spaces were contained in string_.
- Describe the user-visible outcome, not the refactoring mechanism. Verbs like "extract", "migrate", "consolidate" describe _how_ the code changed; lead with _what_ now works differently.
- Preserve the domain context that tells the reader which system is affected (e.g., "Claude Code notifications", not just "notifications").

### Body

- A body is STRONGLY DISCOURAGED. Omit it unless the change genuinely cannot be understood from the description and diff alone — for example, a non-obvious motivation, a breaking change whose impact needs spelling out, or a workaround whose rationale would otherwise be lost.
- When a body is truly warranted, it MUST begin one blank line after the description and explain WHY, not WHAT. Do not list files or restate the diff.

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
- `refactor(scripts): ...` — scope is the directory, not the subsystem
- `refactor(notification): extract shared library` — leads with the mechanism instead of the resulting capability
- `refactor(notification): focus tmux pane via terminal-notifier` — drops the "Claude Code" context that tells the reader which notifications this is about
