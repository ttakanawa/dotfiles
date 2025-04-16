#!/bin/bash

cd $HOME/Library/Application\ Support/Code/User

if [ -f ./settings.json ]; then
  rm ./settings.json
fi
ln -s $HOME/dotfiles/vscode/settings.json ./settings.json

if [ -f ./keybindings.json ]; then
  rm ./keybindings.json
fi
ln -s $HOME/dotfiles/vscode/keybindings.json ./keybindings.json