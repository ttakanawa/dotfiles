#!/bin/bash

cd $HOME/dotfiles

if [ `uname` = "Darwin" ]; then
  # If you generate ssh key
  # ssh-keygen -t rsa -b 4096 -C "takanawa@hey.com"
fi

./homebrew/init.sh
./git/init.sh
./vscode/init.sh
./zsh/init.sh
zsh