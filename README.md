# dotfiles

Configuration files for my computer.

All documentation and comments in this repository are written in English.

## File Tree

```
.
├── .markdownlint.yaml           # markdownlint config
├── .zshenv                      # Sets XDG_CONFIG_HOME
├── .zshrc                       # Zsh main config (sources .config/zsh/)
├── .config/
│   ├── .gitignore               # Ignore non-dotfiles dirs (gh, emacs, etc.)
│   ├── zsh/
│   │   ├── plugins.zsh          # sheldon, zoxide, direnv, mise init
│   │   ├── aliases.zsh          # Aliases & fzf utility functions
│   │   ├── environment.zsh      # PATH, env vars
│   │   └── secret_env.zsh       # Secrets (not tracked)
│   ├── nvim/                    # LazyVim-based Neovim config
│   │   ├── init.lua
│   │   ├── lua/config/          # autocmds, keymaps, lazy, options
│   │   └── lua/plugins/         # Per-plugin configs
│   ├── tmux/
│   │   ├── tmux.conf
│   │   └── install-plugins.sh   # TPM plugin installer
│   ├── wezterm/wezterm.lua
│   ├── sheldon/plugins.toml     # Zsh plugin manager config
│   ├── git/
│   │   ├── config
│   │   └── ignore               # Global gitignore (XDG standard, auto-loaded by git)
│   ├── lazygit/config.yml
│   ├── mise/config.toml         # Runtime version manager
│   ├── ssh/
│   │   └── config.base          # SSH base config (loaded via Include in ~/.ssh/config)
│   ├── zk/                      # Zettelkasten note config & templates
│   └── raycast/script_commands/ # Raycast script commands
├── .claude/
│   ├── .gitignore               # Allowlist for tracked Claude Code files
│   ├── CLAUDE.md                # Claude Code project instructions (communication rules)
│   ├── settings.json            # Hooks, status line, attribution, preferences
│   ├── agents/                  # Custom agents
│   ├── commands/                # Slash commands
│   ├── contexts/                # Context profiles (dev, research, review)
│   ├── rules/                   # Global rules (auto-loaded)
│   ├── skills/                  # Reusable skill definitions
│   └── scripts/                 # Hook scripts (notification, logging)
├── homebrew/
│   ├── Brewfile                 # Homebrew package list
│   └── install.sh / dump.sh     # Install / dump packages
├── vscode/
│   ├── settings.json            # VS Code / Cursor settings
│   ├── keybindings.json         # Keybindings
│   ├── extensions               # Extension list
│   ├── link.sh                  # Symlink settings
│   └── install.sh / dump.sh     # Install / dump extensions
├── link_dotfiles.sh             # Symlink dotfiles to $HOME
├── install-npx-for-claude.sh    # Install npx wrapper for Claude Code
└── Makefile                     # Upstream remote sync operations
```

## Setup

```bash
./link_dotfiles.sh                  # Symlink dotfiles to $HOME
./homebrew/install.sh               # Install Homebrew packages
./vscode/link.sh                    # Symlink VS Code/Cursor settings
./.config/tmux/install-plugins.sh   # Install tmux plugins
```

## Symlink Structure

`link_dotfiles.sh` symlinks the following into `$HOME`, so they act as global configs:

```
$HOME/
├── .markdownlint.yaml → dotfiles/.markdownlint.yaml
├── .zshrc             → dotfiles/.zshrc
├── .zshenv            → dotfiles/.zshenv
├── .config/           → dotfiles/.config/   # = ~/.config/ (XDG_CONFIG_HOME)
└── .claude/           → dotfiles/.claude/
```

## .gitignore

Allowlist pattern. When adding or removing tracked paths under the symlinked directories, update `.config/.gitignore` accordingly.

## Terminal

zsh + tmux on WezTerm.

## Color Theme

Catppuccin Frappe across all tools (Neovim, tmux, WezTerm).

## Neovim Plugins

[LazyVim](https://github.com/LazyVim/LazyVim) base. Respect LazyVim and extras defaults; only add files under `lua/plugins/` when customization is needed.

- `catppuccin.lua`
  - catppuccin/nvim - Color scheme
  - LazyVim/LazyVim - Colorscheme setting
- `lsp.lua`
  - neovim/nvim-lspconfig - LSP configuration
- `markdown.lua`
  - MeanderingProgrammer/render-markdown.nvim - In-buffer markdown rendering
- `snacks.lua`
  - folke/snacks.nvim - Utility collection
- `telescope.lua`
  - nvim-telescope/telescope.nvim - Fuzzy finder
- `zk-nvim.lua`
  - zk-org/zk-nvim - Zettelkasten note management

## Claude Code

### MCP Servers

Global MCP servers are configured in `~/.claude.json` under `mcpServers`.

### Rules

<https://code.claude.com/docs/en/memory>

| Rule | Description |
| ------ | ------------- |
| `agents.md` | Agent orchestration guidelines — when to use which agent, parallel execution |
| `ask-user-question.md` | Always use AskUserQuestion tool for user questions |
| `tools.md` | Tool preferences for AI — preferred tools, tools to avoid, useful patterns |
| `markdown.md` | Markdown formatting rules — code block indentation, table separators (scoped to `**/*.md`) |
| `writing-style.md` | Mixed Japanese-English text spacing conventions |

### Agents

<https://code.claude.com/docs/en/sub-agents>

Keep this section in sync with `.claude/agents/`. When agents are added or removed, update both this section and `.claude/rules/agents.md` accordingly.

| Agent | Model | Description |
| ------ | ------ | ------------- |
| `architect` | Opus | System design, scalability, technical decisions |
| `tdd-guide` | Sonnet | Test-driven development (write-tests-first) |
| `review-architecture` | Opus | Architecture review (layer violations, dependency direction, responsibility placement) |
| `review-guidelines` | Opus | Guidelines compliance review (project rules, conventions, established patterns) |
| `review-security` | Opus | Security review (OWASP Top 10, vulnerability patterns) |
| `review-code-quality` | Sonnet | Code quality review (function size, error handling, dead code) |
| `review-performance` | Sonnet | Performance review (algorithms, caching, N+1 queries) |
| `review-readability` | Haiku | Readability review (complex logic, unclear naming, duplication) |
| `review-license` | Haiku | License compatibility review for new dependencies |

### Skills

<https://code.claude.com/docs/en/skills>

| Skill | Description |
| ------ | ------------- |
| `/code-review` | Unified code review for GitLab MRs, GitHub PRs, commit hashes, or git diffs |
| `/commit-diff` | Analyze staged changes and create a commit with a Conventional Commits message |
| `/update-commit-message` | Regenerate a commit message and update via interactive rebase |
| `/v` | Neovim environment guide (plugins, keymaps, config) |
| `/daily-summary` | Summarize Claude Code interactions for a date range using Agent Teams |
| `/amiforked` | Check if the current session was forked and show the original session ID |
| `/second-opinion` | Consult teammate/subagent for a second opinion on implementation plans, code reviews, or problem-solving |

### Contexts

<https://code.claude.com/docs/en/cli-reference#cli-flags>

| Context | Mode | Focus |
| ------ | ------------- | ------ |
| `dev` | Active development | Implementation, coding, building features |
| `research` | Exploration | Understanding before acting |
| `review` | Code review | Quality, security, maintainability |
