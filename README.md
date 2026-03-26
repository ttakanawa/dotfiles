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
│   │   └── scripts/
│   │       ├── disk-usage.sh      # Disk usage display script
│   │       └── install-plugins.sh # Plugin installer
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
./.config/tmux/scripts/install-plugins.sh   # Install tmux plugins
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

## Terminal

zsh + tmux on WezTerm.

## Color Theme

Catppuccin Frappe across all tools (Neovim, tmux, WezTerm).

## Neovim Plugins

[LazyVim](https://github.com/LazyVim/LazyVim) base. Respect LazyVim and extras defaults; only add files under `lua/plugins/` when customization is needed.

- `catppuccin.lua`
  - catppuccin/nvim - Color scheme
  - LazyVim/LazyVim - Colorscheme setting
- `intelephense.lua`
  - neovim/nvim-lspconfig - PHP LSP (intelephense)
- `markdown.lua`
  - MeanderingProgrammer/render-markdown.nvim - In-buffer markdown rendering
- `snacks.lua`
  - folke/snacks.nvim - Utility collection
- `swift.lua`
  - neovim/nvim-lspconfig - Swift/sourcekit LSP
- `telescope.lua`
  - nvim-telescope/telescope.nvim - Fuzzy finder
- `minuet.lua`
  - milanglacier/minuet-ai.nvim - AI code completion (Ollama)
- `zk-nvim.lua`
  - zk-org/zk-nvim - Zettelkasten note management

## Claude Code

### Attribution

Never add attribution footers (e.g., "Generated with Claude Code") to any output — commits, PRs, MRs, comments, or any other artifacts.

### MCP Servers

Global MCP servers are configured in `~/.claude.json` under `mcpServers`.

### Rules

<https://code.claude.com/docs/en/memory>

| Rule | Description |
| ------ | ------------- |
| `agents.md` | Show available agents |
| `ask-user-question.md` | Use AskUserQuestion tool |
| `tools.md` | Preferred tools and patterns |
| `markdown.md` | Markdown file related rules (`**/*.md`) |
| `writing-style.md` | Writing style |

### Agents

<https://code.claude.com/docs/en/sub-agents>

Keep this section in sync with `.claude/agents/`. When agents are added or removed, update both this section and `.claude/rules/agents.md` accordingly.

| Agent | Description |
| ------ | ------------- |
| `architect` | System design, scalability |
| `tdd-guide` | Test-driven development |
| `review-architecture` | Layer violations, dependency direction |
| `review-guidelines` | Project rules, conventions compliance |
| `review-security` | Vulnerability patterns |
| `review-code-quality` | Function size, error handling, dead code |
| `review-performance` | Algorithms, caching, query optimization |
| `review-readability` | Complex logic, naming |
| `review-license` | License compatibility for new deps |

### Skills

<https://code.claude.com/docs/en/skills>

| Skill | Description |
| ------ | ------------- |
| `/code-review` | Review GitLab MRs, GitHub PRs, commits, or diffs |
| `/commit-staged` | Staged changes → Conventional Commits message |
| `/update-commit-message` | Regenerate commit message via rebase |
| `/v` | Neovim environment guide |
| `/daily-summary` | Summarize interactions for a date range |
| `/amiforked` | Check if session was forked |
| `/second-opinion` | Ask subagent/teammate a second opinion |
| `/find-session-file` | Locate session file by ID |
| `/resolve-review` | Triage review findings, fix code, and reply to MR/PR threads |

### Contexts

<https://code.claude.com/docs/en/cli-reference#cli-flags>

| Context | Description |
| ------ | ------------- |
| `dev` | Active development — implementation, coding |
| `research` | Exploration — understanding before acting |
| `review` | Code review — quality, security, maintainability |
