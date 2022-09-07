#!/bin/bash

if [ -f $HOME/.gitconfig ]; then
  rm $HOME/.gitconfig
fi
ln -s $HOME/dotfiles/git/.gitconfig $HOME/.gitconfig

if [ -f $HOME/.gitignore_global ]; then
  rm $HOME/.gitignore_global
fi
ln -s $HOME/dotfiles/git/.gitignore_global $HOME/.gitignore_global
