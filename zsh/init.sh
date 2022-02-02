#!/bin/bash

rm ~/.zshrc
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc

git submodule init
git submodule update
zsh
