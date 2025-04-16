#!/bin/bash

cd $HOME/Library/Application\ Support/Cursor/User

if [ -f ./settings.json ]; then
  rm ./settings.json
fi
ln -s $HOME/dotfiles/cursor/settings.json ./settings.json

if [ -f ./keybindings.json ]; then
  rm ./keybindings.json
fi
ln -s $HOME/dotfiles/cursor/keybindings.json ./keybindings.json