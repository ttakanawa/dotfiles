#!/bin/bash -eu

cd $HOME/dotfiles

if [ `uname` = "Darwin" ]; then


  # If you generate ssh key
  # ssh-keygen -t rsa -b 4096 -C "takanawa@hey.com"
fi

git submodule init
git submodule update
zsh
