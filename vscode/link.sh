#!/bin/bash

EDITORS=(
    "Cursor:$HOME/Library/Application Support/Cursor/User"
    "VS Code:$HOME/Library/Application Support/Code/User"
)

EDITOR_CHOICE=$(printf '%s\n' "${EDITORS[@]}" | cut -d: -f1 | fzf --prompt="Select editor: " --height=40% --border)

if [ -z "$EDITOR_CHOICE" ]; then
    echo "No editor selected. Exiting."
    exit 1
fi

APP_DIR=$(printf '%s\n' "${EDITORS[@]}" | grep "^$EDITOR_CHOICE:" | cut -d: -f2-)

if [ -z "$APP_DIR" ]; then
    echo "Invalid editor selected. Exiting."
    exit 1
fi

cd "$APP_DIR"

if [ -f ./settings.json ]; then
  rm ./settings.json
fi
ln -s $HOME/dotfiles/vscode/settings.json ./settings.json

if [ -f ./keybindings.json ]; then
  rm ./keybindings.json
fi
ln -s $HOME/dotfiles/vscode/keybindings.json ./keybindings.json