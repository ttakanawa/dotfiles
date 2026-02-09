#!/bin/bash
set -e

PLUGIN_DIR="$HOME/.config/tmux/plugins"

clone_plugin() {
  local url="$1"
  local dest="$2"

  if [ -d "$dest" ]; then
    echo "Skip: $dest already exists"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  echo "Cloning $url -> $dest"
  if ! git clone "$url" "$dest"; then
    echo "Error: Failed to clone $url" >&2
    exit 1
  fi
}

clone_plugin "https://github.com/catppuccin/tmux.git" "$PLUGIN_DIR/catppuccin/tmux"
clone_plugin "https://github.com/tmux-plugins/tmux-cpu.git" "$PLUGIN_DIR/tmux-cpu"
