#!/bin/bash

cd $HOME/dotfiles

if [ $(uname) = "Darwin" ]; then
  # If you generate ssh key
  # ssh-keygen -t rsa -b 4096 -C "takanawa@hey.com"
fi

./zsh/init.sh
./git/init.sh
./homebrew/init.sh
./vscode/init.sh
zsh

# put iCloud symlink
ln -s $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs $HOME/iCloud
# put Obsidian symlink
ln -s $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents $HOME/Obsidian
