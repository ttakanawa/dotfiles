#!/bin/bash

cd $HOME/dotfiles/vscode

VSCODE_SETTING_DIR=$HOME/Library/Application\ Support/Code/User

rm "${VSCODE_SETTING_DIR}/settings.json"
ln -s $HOME/dotfiles/vscode/settings.json "${VSCODE_SETTING_DIR}/settings.json"

rm "${VSCODE_SETTING_DIR}/keybindings.json"
ln -s $HOME/dotfiles/vscode/keybindings.json "${VSCODE_SETTING_DIR}/keybindings.json"

cat $HOME/dotfiles/vscode/extensions | while read line
do
 code --install-extension $line
done
code --list-extensions > $HOME/dotfiles/vscode/extensions