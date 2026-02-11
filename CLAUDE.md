# CLAUDE.md

Dotfiles repository.

## File Tree

```
.
├── .markdownlint.yaml           # markdownlint config
├── .zshenv                      # Sets XDG_CONFIG_HOME
├── .zshrc                       # Zsh main config (sources .config/zsh/)
├── .config/
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
│   │   ├── .gitignore           # Global gitignore (via core.excludesFile)
│   │   └── config
│   ├── lazygit/config.yml
│   ├── mise/config.toml         # Runtime version manager
│   ├── zk/                      # Zettelkasten note config & templates
│   └── raycast/script_commands/ # Raycast script commands
├── .claude/
│   ├── settings.json            # Claude Code hooks & status line
│   ├── commands/                # Slash commands
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

Allowlist pattern. When adding or removing tracked paths under the symlinked directories, update `.config/git/.gitignore` accordingly.

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

## tmux Plugins

- catppuccin/tmux
- tmux-plugins/tmux-cpu

## CLI Tools (Homebrew)

Keep this section in sync with brew formulae in `homebrew/Brewfile`. When formulae are added or removed, update this section accordingly. Casks are not covered here.

Prefer these tools over their traditional counterparts when running shell commands.

### Preferred replacements — always use these instead of the defaults

| Tool | Replaces | Description |
| ------ | ---------- | ------------- |
| `bat` | `cat` | File viewer with syntax highlighting and line numbers |
| `fd` | `find` | Fast, user-friendly file finder (e.g. `fd '\.json$'`) |
| `ripgrep` (`rg`) | `grep` | Fast regex search across files |
| `fzf` | — | Fuzzy finder for interactive filtering of any list |
| `zoxide` (`z`) | `cd` | Smart directory jumper that learns from usage |
| `jq` | — | JSON processor for querying and transforming JSON |
| `tree` | `ls -R` | Display directory structure as a tree |

### Git & GitHub

| Tool | Description |
| ------ | ------------- |
| `git` | Version control |
| `gh` | GitHub CLI — PRs, issues, releases, Actions, API calls |
| `ghq` | Git repository manager — clone/list repos under a unified root (`ghq get`, `ghq list`) |
| `lazygit` | Terminal UI for git — interactive staging, branching, rebasing |
| `diff-so-fancy` | Better-looking git diffs (configured as git pager) |

### Media & Files

| Tool | Description |
| ------ | ------------- |
| `ffmpeg` | Audio/video conversion, transcoding, and streaming |
| `imagemagick` (`magick`) | Image manipulation — resize, convert, composite |
| `exiftool` | Read/write metadata of images, videos, PDFs |
| `fselect` | SQL-like queries over files (e.g. `fselect name, size from . where name = '*.log'`) |

### Development & Infrastructure

| Tool | Description |
| ------ | ------------- |
| `neovim` (`nvim`) | Primary text editor (LazyVim config) |
| `tmux` | Terminal multiplexer — sessions, windows, panes |
| `direnv` | Auto-load/unload `.envrc` environment variables per directory |
| `sheldon` | Zsh plugin manager |
| `pipx` | Install and run Python CLI tools in isolated environments |
| `railway` | Railway.app CLI for deploying and managing services |
| `zk` | Zettelkasten plain-text note management |

### System & Monitoring

| Tool | Description |
| ------ | ------------- |
| `bottom` (`btm`) | System resource monitor (CPU, memory, network, processes) |
| `lazydocker` | Terminal UI for Docker — containers, images, volumes, logs |

### Hardware

| Tool | Description |
| ------ | ------------- |
| `qmk` | QMK keyboard firmware toolchain |
| `macism` | macOS input source (IME) switcher from the command line |
