#!/bin/bash

EDITORS=(
    "Cursor:cursor"
    "VS Code:code"
    "Vim:vim"
    "Neovim:nvim"
)

EDITOR_CHOICE=$(printf '%s\n' "${EDITORS[@]}" | cut -d: -f1 | fzf --prompt="Select editor: " --height=40% --border)

if [ -z "$EDITOR_CHOICE" ]; then
    echo "No editor selected. Exiting."
    exit 1
fi

EDITOR_CMD=$(printf '%s\n' "${EDITORS[@]}" | grep "^$EDITOR_CHOICE:" | cut -d: -f2)

if [ -z "$EDITOR_CMD" ]; then
    echo "Invalid editor selected. Exiting."
    exit 1
fi

cat $HOME/dotfiles/vscode/extensions | while read line; do
  $EDITOR_CMD --install-extension $line
done