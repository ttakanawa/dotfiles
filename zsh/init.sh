#!/bin/bash

rm $HOME/.zshrc
ln -s $HOME/dotfiles/zsh/.zshrc $HOME/.zshrc

git submodule init
git submodule update
zsh
