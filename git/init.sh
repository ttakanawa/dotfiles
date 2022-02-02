#!/bin/bash

rm $HOME/.gitconfig
ln -s $HOME/dotfiles/git/.gitconfig $HOME/.gitconfig

rm $HOME/.gitignore_global
ln -s $HOME/dotfiles/git/.gitignore_global $HOME/.gitignore_global
