#!/bin/bash

if [ -f $HOME/.zshrc ]; then
  rm $HOME/.zshrc
fi

ln -s $HOME/dotfiles/zsh/.zshrc $HOME/.zshrc

git submodule init
git submodule update
zsh
